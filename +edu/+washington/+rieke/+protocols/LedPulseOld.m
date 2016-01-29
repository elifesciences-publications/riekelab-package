classdef LedPulseOld < symphonyui.core.Protocol
    
    properties
        led                             % Output LED
        referenceCell = 'Rod'           % This is the cell type in reference to which isomerizations/second will be specified.
        preTime = 10                    % Pulse leading duration (ms)
        stimTime = 100                  % Pulse duration (ms)
        tailTime = 400                  % Pulse trailing duration (ms)
        stimulusMean = 0                % Mean background on which the stimulus is delivered 
        stepAmplitude = 1               % Amplitude of stimulus given on background 
        amp                             % Input amplifier
        numberOfAverages = uint16(5)    % Number of epochs
        interpulseInterval = 0          % Duration between pulses (s)
    end
    
    properties (Hidden)
        ledType %= symphonyui.core.PropertyType('char', 'row', {'Green LED', 'Blue LED'}); % need to get this from the rig
        ampType = symphonyui.core.PropertyType('char', 'row', {'Amp1', 'Amp2'});
        referenceCellType %= symphonyui.core.PropertyType('char', 'row', {'Rod', 'S Cone', 'L Cone', 'M Cone'}); % need to get this from the species
    end
    
    properties (Dependent = true, Hidden = true)
        canUseIsomerizations
    end
    
    methods
        
        function onSetRig(obj)
            onSetRig@symphonyui.core.Protocol(obj);
            
            amps = appbox.firstNonEmpty(obj.rig.getDeviceNames('Amp'), {'(None)'});
            obj.amp = amps{1};
            obj.ampType = symphonyui.core.PropertyType('char', 'row', amps);
            
            leds = appbox.firstNonEmpty(obj.rig.getDeviceNames('LED'), {'(None)'});
            obj.led = leds{1};
            obj.ledType = symphonyui.core.PropertyType('char', 'row', leds);
        end
        
        function onSetPersistor(obj)
            onSetPersistor@symphonyui.core.Protocol(obj);
            
            cellTypes = appbox.firstNonEmpty(obj.possibleCellTypes, {'(None)'});
            obj.referenceCellType = symphonyui.core.PropertyType('char', 'row', cellTypes);
            obj.referenceCell = cellTypes{1};
        end
        
        function [tf,msg] = isValid(obj)
            if numel(obj.rig.getDevices('led'))
                tf = true;
                msg = [];
            else
                tf = false;
                msg = 'There are no LEDs.';
            end
        end
            
        function d = getPropertyDescriptor(obj, name)
            d = getPropertyDescriptor@symphonyui.core.Protocol(obj, name);
%             switch name
%                 case {'stimulusMean', 'stepAmplitude'}
%                     if obj.canUseIsomerizations
%                         unit = '(isom/s)';
%                     else
%                         unit = '(V)';
%                     end
%                     d.description = [d.description ' ' unit];
%             end
        end
        
        function p = getPreview(obj, panel)
            p = symphonyui.builtin.previews.StimuliPreview(panel, @()createPreviewStimuli(obj));
            function s = createPreviewStimuli(obj)
                s = {obj.ledStimulus()};
            end
        end
        
        function prepareRun(obj)
            prepareRun@symphonyui.core.Protocol(obj);
            
            obj.showFigure('symphonyui.builtin.figures.ResponseFigure', obj.rig.getDevice(obj.amp));
        end
        
        function stim = ledStimulus(obj)
            p = symphonyui.builtin.stimuli.PulseGenerator();
            
            p.preTime = obj.preTime;
            p.stimTime = obj.stimTime;
            p.tailTime = obj.tailTime;
            if obj.canUseIsomerizations
                p.amplitude = obj.isomToV(obj.stepAmplitude);
                p.mean = obj.isomToV(obj.stimulusMean);
                disp(['Amp: ' num2str(p.amplitude)]);
            else
                p.amplitude = obj.stepAmplitude;
                p.mean = obj.stimulusMean;
            end
            p.sampleRate = obj.sampleRate;
            p.units = obj.rig.getDevice(obj.led).background.displayUnits;
            
            stim = p.generate();
        end
        
        function prepareEpoch(obj, epoch)
            prepareEpoch@symphonyui.core.Protocol(obj, epoch);
            
            epoch.addStimulus(obj.rig.getDevice(obj.led), obj.ledStimulus());
            epoch.addResponse(obj.rig.getDevice(obj.amp));
        end
        
        function tf = shouldContinuePreparingEpochs(obj)
            tf = obj.numEpochsPrepared < obj.numberOfAverages;
        end
        
        function tf = shouldContinueRun(obj)
            tf = obj.numEpochsCompleted < obj.numberOfAverages;
        end
        
        % isom stuff
        function value = isomToV(obj, isom)
            % this function should convert a stimulus specified in
            % isomerizations into the appropriate voltage signal to send to
            % the specified LED; there is a chance, though, that there will
            % be insufficient information to specify stimulus in
            % isomerizations; in this case, the function should just return
            % its input as its output because the rest of the protocol
            % should have reverted to operating in units of volts
            
            % get the selected device
            device = obj.rig.getDevice(obj.led);
            
            % get LED setting
            ledSetting = obj.determineLEDSetting(obj.led);
            deviceCalibration = device.configuration(['CalibrationValue' ledSetting]);
            deviceCalibrationDataPath = device.configuration('CalibrationFolder');
            
            photoreceptorType = obj.referenceCell;
            NDFs = obj.getCurrentNDFs(obj.led);
            species = obj.getCurrentSpecies;
            
            
            % use the converting function
            value = symphonyIsomToV(deviceCalibration, deviceCalibrationDataPath, ...
                photoreceptorType, NDFs, species, ledSetting, isom);
        end
        
        function value = determineLEDSetting(obj, ledString)
            propertyDescriptorName = [ledString ' Setting'];
            
            value = obj.findSourcePropertyDescriptor(propertyDescriptorName);
        end
            
        function species = getCurrentSpecies(obj)
            % use the source for the current epoch to determine the
            % species; there is a chance that a source has not been defined
            % and therefore there will not be a species - in this case,
            % return an empty variable
            species = obj.findSourcePropertyDescriptor('species');
        end
        
        function value = findSourcePropertyDescriptor(obj, descriptor)
            % sources exist within a heirarchical structure; this function
            % will look at the lowest level for a given property descriptor
            % and if it doesn't find it, it will look at progressively
            % higher and higher levels until it finds it (or reaches the
            % top)
            if obj.currentEpochGroupExists
                % this
                currSource = obj.persistor.currentEpochGroup.source;
                found = false;
                parent = true;
                while ~found && parent
                    % search property descriptors 
                    currKeys = currSource.propertyMap.keys;
                    numDescr = numel(currKeys);
                    ii = 0;
                    while ~found && ii < numDescr
                        ii = ii + 1;
                        if strcmpi(descriptor, currKeys{ii})
                            found = true;
                            value = currSource.propertyMap(currKeys{ii});
                        end
                    end                    
                    if ~found
                        if isempty(currSource.parent)
                            parent = false;
                        else
                            parent = true;
                            currSource = currSource.parent;
                        end
                    end
                end
                
                if ~found
                    value = [];
                end
            else
                value = [];
            end
        end
        
        function NDFs = getCurrentNDFs(obj, ledString)
            % use the source for the current epoch to determine the
            % NDFs; there is a chance that a source has not been defined
            % and therefore there will not be a species - in this case,
            % return an empty variable; each device can have ndfs
            % specific to that device and ndfs that are common to all
            % devices; this will get both
            
            commonNDFs = obj.findSourcePropertyDescriptor('ndfs');
            
            specificNDFs = obj.findSourcePropertyDescriptor([ledString ' NDFs']);
            
            if ~isempty(commonNDFs)
                if ~isempty(specificNDFs)
                    NDFs = [commonNDFs ', ' specificNDFs];
                else
                    NDFs = commonNDFs;
                end
            elseif ~isempty(specificNDFs)
                NDFs = specificNDFs;
            else 
                NDFs = [];
            end
            if ~isempty(NDFs)
                NDFs = obj.ndfStringToCell(NDFs);
            end
        end
        
        function ndfsCell = ndfStringToCell(obj, ndfsString) %#ok<INUSL>
            ndfsCell = strsplit(ndfsString, ',');
            for i = 1:numel(ndfsCell)
                ndfsCell{i} = strtrim(ndfsCell{i});
            end
        end
        
        function tf =  currentEpochGroupExists(obj)
            if ~isempty(obj.persistor)
                if ~isempty(obj.persistor.currentEpochGroup)
                    tf = true;
                else
                    tf = false;
                end
            else
                tf = false;
            end
        end
        
        function tf = get.canUseIsomerizations(obj)
            % this will determine if sufficient information is available to
            % specify stimuli using isomerizations/second; if not, the
            % protocol should revert to volts
            
            % GET THE OBJECT
            device = obj.rig.getDevice(obj.led);
            species = obj.getCurrentSpecies;
            calibrationDataBasePath = 'C:\Users\Client Admin\Documents\MATLAB\calibrationUtilities\data';
            NDFs = obj.getCurrentNDFs(obj.led);
            % starts true, will become false if something is encountered
            % that makes using isomerizations not possible
            tf = true;
            
            % check for stuff related to photoreceptor
            photoreceptorFolderPath = [calibrationDataBasePath filesep 'photoreceptors'];
            if ~isempty(species)
                if isdir([photoreceptorFolderPath filesep species])
                    photoreceptorTypes = dir([photoreceptorFolderPath filesep species]);
                    if numel(photoreceptorTypes) > 2
                        photoreceptorTypes = photoreceptorTypes(3:end);
                        found = false;
                        for ii = 1:numel(photoreceptorTypes)
                            [~,currName,~] = fileparts(photoreceptorTypes(ii).name);
                            sNames = {'sCone', 'Scone', 'SCone', 'scone', 'S Cone', 's cone', 's Cone', 's Cone'};
                            mNames = {'mCone', 'Mcone', 'MCone', 'mcone', 'M Cone', 'M cone', 'm Cone', 'm cone'};
                            lNames = {'lCone', 'Lcone', 'LCone', 'lcone', 'L Cone', 'L cone', 'l Cone', 'l Cone'};
                            rodNames = {'rod', 'Rod'};
                            switch currName
                                case sNames
                                    potentialNames = sNames;
                                case mNames
                                    potentialNames = mNames;
                                case lNames
                                    potentialNames = lNames;
                                case rodNames
                                    potentialNames = rodNames;
                            end
                            for jj = 1:numel(potentialNames)
                                if strcmpi(potentialNames{jj}, obj.referenceCell)
                                    found = true;
                                end
                            end
                        end
                        if found
                            if ~isempty(species)
                                photoreceptorPath = [photoreceptorFolderPath filesep species filesep obj.referenceCell];
                                if ~sum(exist([photoreceptorPath filesep 'spectrum.txt'], 'file')) || ...
                                    ~sum(exist([photoreceptorPath filesep 'collectingArea.txt'], 'file'))
                                    tf = false;
                                end
                            else
                                tf = false;
                            end
                        else
                            tf = false;
                        end
                    else
                        tf = false;
                    end
                else
                    tf = false;
                end
            else
                tf = false;
            end
            % check for stuff related to device
            if tf
                ledSetting = obj.determineLEDSetting(obj.led);
                if ~device.configuration.isKey(['CalibrationValue' ledSetting])
                    tf = false;
                end
                
                if device.configuration.isKey('CalibrationFolder')
                    
                    % look for spectrum file
                    spectrumFileExists = ...
                        exist([device.configuration('CalibrationFolder') filesep 'spectrum.txt'], 'file');
                    
                    if ~spectrumFileExists
                        tf = false;
                    end
                    
                    % this file also contains the NDFs for this device - check
                    % that the appropriate NDF attenuations are available
                    if ~isempty(NDFs)
                        
                        ndfFileExists = ...
                            exist([device.configuration('CalibrationFolder') filesep 'ndfs.txt'], 'file');
                        
                        if ndfFileExists
                            % ndfs should be a string split by commas, start by
                            % splitting on commas
                            ndfList = NDFs;
                            ndfMap = ...
                                readNDFList([device.configuration('CalibrationFolder') filesep 'ndfs.txt']);
                            numNDFs = numel(ndfList);
                            for ii = 1:numNDFs
                                % make sure there are no spaces
                                ndfList{ii} = strtrim(ndfList{ii});
                                % check each NDF to see if it can be found as a key
                                % in this map
                                if ndfMap.isKey(ndfList{ii})
                                    if isnumeric(ndfMap(ndfList{ii}))
                                        if ndfMap(ndfList{ii}) < 0
                                            tf = false;
                                        end
                                    else
                                        tf = false;
                                    end
                                elseif ~isnan(str2double(ndfList{ii}))
                                    if str2double(ndfList{ii}) > 5
                                        tf = false;
                                    end
                                else
                                    tf = false;
                                end
                            end
                        else
                            tf = false;
                        end
                    end
                else
                    tf = false;
                end 
            end
        end
        
        function value = possibleCellTypes(obj)
            % pull the possible cell types from the species
            species = obj.getCurrentSpecies;
            speciesBasePath = 'C:\Users\Client Admin\Documents\MATLAB\calibrationUtilities\data\photoreceptors';
            
            primateStrings = {'primate', 'macaque', 'Primate', 'Macaque'};
            mouseStrings = {'mouse', 'Mouse'};
            zebrafishStrings = {'zebrafish', 'Zebrafish'};
            
            if ~isempty(species)
                switch species
                    case primateStrings
                        folder = 'primate';
                    case mouseStrings
                        folder = 'mouse';
                    case zebrafishStrings
                        folder = 'zebrafish';
                end
                
                photoreceptors = dir([speciesBasePath filesep folder]);
                
                if numel(photoreceptors) > 2
                    photoreceptors = photoreceptors(3:end);
                    num = numel(photoreceptors);
                    value = cell(1,num);
                    for ii = 1:num
                        [~, value{ii}, ~] = fileparts(photoreceptors(ii).name);
                    end
                else
                    value = [];
                end
            else
                value = [];
            end
        end
        
    end
    
end