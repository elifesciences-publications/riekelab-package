classdef DeviceCalibrator < symphonyui.ui.Module
    
    properties (Access = private)
        leds
        stage
        isLedOn
        isStageOn
        calibrations
        previousCalibrations
    end
    
    properties (Access = private)
        wizardCardPanel
        instructionsCard
        calibrationCard
        backButton
        nextButton
        cancelButton
    end
    
    methods
        
        function createUi(obj, figureHandle)
            import appbox.*;
            
            set(figureHandle, ...
                'Name', 'Device Calibrator', ...
                'Position', screenCenter(475, 294), ...
                'WindowStyle', 'modal', ...
                'Resize', 'off');
            
            mainLayout = uix.VBox( ...
                'Parent', figureHandle);
            
            wizardLayout = uix.VBox( ...
                'Parent', mainLayout);
            
            obj.wizardCardPanel = uix.CardPanel( ...
                'Parent', wizardLayout);
            
            % Instructions card.
            instructionsLayout = uix.VBox( ...
                'Parent', obj.wizardCardPanel, ...
                'Padding', 11);
            Label( ...
                'Parent', instructionsLayout, ...
                'String', sprintf(['<html><b>Instructions:</b><br>' ...
                    '&emsp;1. Tape the wand to the stage, face down.<br>' ...
                    '&emsp;2. Connect the wand BNC cable to the light meter input on front of the box.<br>' ...
                    '&emsp;3. Close the curtains and dim the lights.<br>' ...
                    '&emsp;4. Turn on the power meter and set the gain to 10^-3.<br>' ...
                    '&emsp;5. Make sure the current (background) reading is ~0.01 or lower.<br>' ...
                    '&emsp;6. Turn on the stimulation device to a reasonably bright setting.<br>' ...
                    '&emsp;7. Center and focus the wand relative to the spot:<br>' ...
                    '&emsp;&emsp;7.1. Move the stage in the X direction until you find the peak power reading.<br>' ...
                    '&emsp;&emsp;7.2. Move the stage in the Y direction until you find the peak power reading.<br>' ...
                    '&emsp;&emsp;7.3. Move the stage in the Z direction until the power reading stops increasing.<br>' ...
                    '&emsp;&emsp;7.4. Move the stage up a bit so the wand is not pushing on the condenser.<br>' ...
                    '&emsp;8. Press "Next" to start calibrating.</html>']));
            
            % Calibration card.
            calibrationLayout = uix.HBox( ...
                'Parent', obj.wizardCardPanel, ...
                'Padding', 11, ...
                'Spacing', 7);
            
            masterLayout = uix.VBox( ...
                'Parent', calibrationLayout);
            
            obj.calibrationCard.deviceListBox = MappedListBox( ...
                'Parent', masterLayout, ...
                'Callback', @obj.onSelectedDevice);
            
            detailLayout = uix.VBox( ...
                'Parent', calibrationLayout, ...
                'Spacing', 7);
            
            obj.calibrationCard.detailCardPanel = uix.CardPanel( ...
                'Parent', detailLayout);
            
            % LED calibration card.
            ledLayout = uix.VBox( ...
                'Parent', obj.calibrationCard.detailCardPanel, ...
                'Spacing', 7);
            
            useCalibrationLayout = uix.HBox( ...
                'Parent', ledLayout);
            Label( ...
                'Parent', useCalibrationLayout, ...
                'String', 'Use calibration:');
            obj.calibrationCard.ledCard.useCalibrationPopupMenu = MappedPopupMenu( ...
                'Parent', useCalibrationLayout, ...
                'String', {' '}, ...
                'HorizontalAlignment', 'left');
            set(useCalibrationLayout, 'Widths', [90 -1]);
            
            useLayout = uix.HBox( ...
                'Parent', ledLayout);
            uix.Empty('Parent', useLayout);
            obj.calibrationCard.ledCard.useButton = uicontrol( ...
                'Parent', useLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Use', ...
                'Interruptible', 'off', ...
                'Callback', @obj.onSelectedLedUse);
            set(useLayout, 'Widths', [-1 75]);
            
            javacomponent(com.jidesoft.swing.TitledSeparator('Or', com.jidesoft.swing.TitledSeparator.TYPE_PARTIAL_LINE, javax.swing.SwingConstants.CENTER), [], ledLayout);
            
            calibrateLayout = uix.HBox( ...
                'Parent', ledLayout, ...
                'Spacing', 5);
            Label( ...
                'Parent', calibrateLayout, ...
                'String', 'Calibrate using:');
            obj.calibrationCard.ledCard.calibrationIntensityField = uicontrol( ...
                'Parent', calibrateLayout, ...
                'Style', 'edit', ...
                'String', '1', ...
                'HorizontalAlignment', 'left');
            obj.calibrationCard.ledCard.calibrationUnitsField = uicontrol( ...
                'Parent', calibrateLayout, ...
                'Style', 'edit', ...
                'Enable', 'off', ...
                'HorizontalAlignment', 'left');
            set(calibrateLayout, 'Widths', [85 -1 -1]);
            
            ledOnLayout = uix.HBox( ...
                'Parent', ledLayout);
            uix.Empty('Parent', ledOnLayout);
            obj.calibrationCard.ledCard.ledOnButton = uicontrol( ...
                'Parent', ledOnLayout, ...
                'Style', 'togglebutton', ...
                'String', 'LED On', ...
                'Interruptible', 'off', ...
                'Callback', @obj.onSelectedLedOn);
            set(ledOnLayout, 'Widths', [-1 75]);
            
            spotLayout = uix.HBox( ...
                'Parent', ledLayout, ...
                'Spacing', 5);
            Label( ...
                'Parent', spotLayout, ...
                'String', 'Spot diameter:');
            obj.calibrationCard.ledCard.spotDiameterField = uicontrol( ...
                'Parent', spotLayout, ...
                'Style', 'edit', ...
                'HorizontalAlignment', 'left');
            obj.calibrationCard.ledCard.spotUnitsField = uicontrol( ...
                'Parent', spotLayout, ...
                'Style', 'edit', ...
                'String', 'um', ...
                'Enable', 'off', ...
                'HorizontalAlignment', 'left');
            set(spotLayout, 'Widths', [85 -1 -1]);
            
            powerLayout = uix.HBox( ...
                'Parent', ledLayout, ...
                'Spacing', 5); 
            Label( ...
                'Parent', powerLayout, ...
                'String', 'Power reading:');
            obj.calibrationCard.ledCard.powerReadingField = uicontrol( ...
                'Parent', powerLayout, ...
                'Style', 'edit', ...
                'HorizontalAlignment', 'left');
            obj.calibrationCard.ledCard.powerUnitsField = uicontrol( ...
                'Parent', powerLayout, ...
                'Style', 'edit', ...
                'String', 'nW', ...
                'Enable', 'off', ...
                'HorizontalAlignment', 'left');
            set(powerLayout, 'Widths', [85 -1 -1]);
            
            submitLayout = uix.HBox( ...
                'Parent', ledLayout);
            uix.Empty('Parent', submitLayout);
            obj.calibrationCard.ledCard.submitButton = uicontrol( ...
                'Parent', submitLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Submit', ...
                'Interruptible', 'off', ...
                'Callback', @obj.onSelectedLedSubmit);
            set(submitLayout, 'Widths', [-1 75]);
            
            set(ledLayout, 'Heights', [23 23 17 23 23 23 23 23]);
            
            % Stage calibration card.
            stageLayout = uix.VBox( ...
                'Parent', obj.calibrationCard.detailCardPanel, ...
                'Spacing', 7);
            
            useCalibrationLayout = uix.HBox( ...
                'Parent', stageLayout);
            Label( ...
                'Parent', useCalibrationLayout, ...
                'String', 'Use calibration:');
            obj.calibrationCard.stageCard.useCalibrationPopupMenu = MappedPopupMenu( ...
                'Parent', useCalibrationLayout, ...
                'String', {' '}, ...
                'HorizontalAlignment', 'left');
            set(useCalibrationLayout, 'Widths', [90 -1]);
            
            useLayout = uix.HBox( ...
                'Parent', stageLayout);
            uix.Empty('Parent', useLayout);
            obj.calibrationCard.stageCard.useButton = uicontrol( ...
                'Parent', useLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Use', ...
                'Interruptible', 'off', ...
                'Callback', @obj.onSelectedStageUse);
            set(useLayout, 'Widths', [-1 75]);
            
            javacomponent(com.jidesoft.swing.TitledSeparator('Or', com.jidesoft.swing.TitledSeparator.TYPE_PARTIAL_LINE, javax.swing.SwingConstants.CENTER), [], stageLayout);
            
            calibrateLayout = uix.HBox( ...
                'Parent', stageLayout, ...
                'Spacing', 5);
            Label( ...
                'Parent', calibrateLayout, ...
                'String', 'Calibrate using:');
            obj.calibrationCard.stageCard.calibrationIntensityField = uicontrol( ...
                'Parent', calibrateLayout, ...
                'Style', 'edit', ...
                'String', '1', ...
                'HorizontalAlignment', 'left');
            obj.calibrationCard.stageCard.calibrationUnitsField = uicontrol( ...
                'Parent', calibrateLayout, ...
                'Style', 'edit', ...
                'String', '_normalized_', ...
                'Enable', 'off', ...
                'HorizontalAlignment', 'left');
            set(calibrateLayout, 'Widths', [85 -1 -1]);
            
            spotLayout = uix.HBox( ...
                'Parent', stageLayout, ...
                'Spacing', 5);
            Label( ...
                'Parent', spotLayout, ...
                'String', 'Spot diameter:');
            obj.calibrationCard.stageCard.spotDiameterField = uicontrol( ...
                'Parent', spotLayout, ...
                'Style', 'edit', ...
                'String', '500', ...
                'HorizontalAlignment', 'left');
            obj.calibrationCard.stageCard.spotUnitsField = uicontrol( ...
                'Parent', spotLayout, ...
                'Style', 'edit', ...
                'String', 'um', ...
                'Enable', 'off', ...
                'HorizontalAlignment', 'left');
            set(spotLayout, 'Widths', [85 -1 -1]);
            
            stageOnLayout = uix.HBox( ...
                'Parent', stageLayout);
            uix.Empty('Parent', stageOnLayout);
            obj.calibrationCard.stageCard.stageOnButton = uicontrol( ...
                'Parent', stageOnLayout, ...
                'Style', 'togglebutton', ...
                'String', 'Stage On', ...
                'Interruptible', 'off', ...
                'Callback', @obj.onSelectedStageOn);
            set(stageOnLayout, 'Widths', [-1 75]);
            
            powerLayout = uix.HBox( ...
                'Parent', stageLayout, ...
                'Spacing', 5); 
            Label( ...
                'Parent', powerLayout, ...
                'String', 'Power reading:');
            obj.calibrationCard.stageCard.powerReadingField = uicontrol( ...
                'Parent', powerLayout, ...
                'Style', 'edit', ...
                'HorizontalAlignment', 'left');
            obj.calibrationCard.stageCard.powerUnitsField = uicontrol( ...
                'Parent', powerLayout, ...
                'Style', 'edit', ...
                'String', 'nW', ...
                'Enable', 'off', ...
                'HorizontalAlignment', 'left');
            set(powerLayout, 'Widths', [85 -1 -1]);
            
            submitLayout = uix.HBox( ...
                'Parent', stageLayout);
            uix.Empty('Parent', submitLayout);
            obj.calibrationCard.stageCard.submitButton = uicontrol( ...
                'Parent', submitLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Submit', ...
                'Interruptible', 'off', ...
                'Callback', @obj.onSelectedStageSubmit);
            set(submitLayout, 'Widths', [-1 75]);
            
            set(stageLayout, 'Heights', [23 23 17 23 23 23 23 23]);
            
            set(calibrationLayout, 'Widths', [-1 -2]);
            
            set(obj.wizardCardPanel, 'Selection', 1);
                
            javacomponent('javax.swing.JSeparator', [], wizardLayout);
            
            set(wizardLayout, 'Heights', [-1 1]);
            
            controlsLayout = uix.HBox( ...
                'Parent', mainLayout, ...
                'Padding', 11);
            uix.Empty('Parent', controlsLayout);
            obj.backButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', '< Back', ...
                'Interruptible', 'off', ...
                'Callback', @obj.onSelectedBack);
            obj.nextButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Next >', ...
                'Interruptible', 'off', ...
                'Callback', @obj.onSelectedNext);
            uix.Empty('Parent', controlsLayout);
            obj.cancelButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Cancel', ...
                'Interruptible', 'off', ...
                'Callback', @obj.onSelectedCancel);
            set(controlsLayout, 'Widths', [-1 75 75 7 75]);
            
            set(mainLayout, 'Heights', [-1 11+23+11]);
            
            % Set next button to appear as the default button.
            try %#ok<TRYNC>
                h = handle(figureHandle);
                h.setDefaultButton(obj.nextButton);
            end
        end
        
    end
    
    methods (Access = protected)
        
        function willGo(obj)
            obj.leds = obj.configurationService.getDevices('LED');
            stages = obj.configurationService.getDevices('Stage');
            if isempty(stages)
                obj.stage = [];
            else
                obj.stage = stages{1};
            end
            
            obj.isLedOn = false;
            obj.isStageOn = false;
            
            obj.calibrations = containers.Map();
            obj.previousCalibrations = containers.Map();
            for i = 1:numel(obj.allDevices)
                device = obj.allDevices{i};
                
                if ~any(strcmp('fluxFactorPaths', device.getResourceNames()))
                    continue;
                end
                paths = device.getResource('fluxFactorPaths');
                
                m = containers.Map();
                settings = paths.keys;
                for k = 1:numel(settings)
                    setting = settings{k};
                    if ~exist(paths(setting), 'file')
                        continue;
                    end
                    t = readtable(paths(setting));
                    t.date = datetime(t.date);
                    m(setting) = t;
                end
                
                obj.previousCalibrations(device.name) = m;
            end
            
            obj.populateDeviceList();
            obj.updateStateOfControls();
        end
        
        function onViewSelectedClose(obj, ~, ~)
            obj.close();
        end
        
    end
    
    methods (Access = private)
        
        function populateDeviceList(obj)
            settingToDevices = containers.Map();
            settings = {};
            for i = 1:numel(obj.allDevices)
                device = obj.allDevices{i};
                
                desc = device.getConfigurationSettingDescriptors().findByName('gain');
                if isempty(desc)
                    if settingToDevices.isKey('none')
                        settingToDevices('none') = [settingToDevices('none') {device}];
                    else
                        settingToDevices('none') = {device};
                    end
                    continue;
                end
                
                availableGains = desc.type.domain;
                for k = 1:numel(availableGains)
                    gain = availableGains{k};
                    if isempty(gain)
                        continue;
                    end
                    
                    if settingToDevices.isKey(gain)
                        settingToDevices(gain) = [settingToDevices(gain) {device}];
                    else
                        settingToDevices(gain) = {device};
                        settings{end + 1} = gain; %#ok<AGROW>
                    end
                end
            end
            
            if settingToDevices.isKey('none')
                settings{end + 1} = 'none';
            end
            
            names = {};
            values = {};
            for i = 1:numel(settings)
                setting = settings{i};
                devices = settingToDevices(setting);
                for k = 1:numel(devices)
                    d = devices{k};
                    if obj.isDeviceCalibrated(d, setting)
                        n = ['<html><font color="green"><b>' d.name];
                    else
                        n = d.name;
                    end
                    if ~strcmp(setting, 'none')
                        n = [n ' - ' setting]; %#ok<AGROW>
                    end
                    names{end + 1} = n; %#ok<AGROW>
                    values{end + 1} = struct('device', d, 'setting', setting); %#ok<AGROW>
                end
            end
            set(obj.calibrationCard.deviceListBox, 'String', names);
            set(obj.calibrationCard.deviceListBox, 'Values', values);
        end
        
        function d = allDevices(obj)
            d = obj.leds;
            if ~isempty(obj.stage)
                d = [{} d {obj.stage}];
            end
        end
        
        function onSelectedDevice(obj, ~, ~)            
            [device, setting] = obj.getSelectedDevice();
            obj.selectDevice(device, setting);
        end
        
        function selectDevice(obj, device, setting)
            turnOn = obj.isLedOn || obj.isStageOn;
            obj.turnOffAllDevices();
            
            obj.setSelectedDevice(device, setting);
            if device == obj.stage
                if turnOn
                    intensity = str2double(get(obj.calibrationCard.stageCard.calibrationIntensityField, 'String'));
                    diameter = str2double(get(obj.calibrationCard.stageCard.spotDiameterField, 'String'));
                    obj.turnOnStage(device, intensity, diameter);
                end
                obj.populateDetailsForStage(device, setting);
            else
                if turnOn
                    intensity = str2double(get(obj.calibrationCard.ledCard.calibrationIntensityField, 'String'));
                    obj.turnOnLed(device, intensity);
                end
                obj.populateDetailsForLed(device, setting);
            end
            obj.updateStateOfControls();
        end
        
        function selectNextDevice(obj)
            old = get(obj.calibrationCard.deviceListBox, 'Value');
            old = old{1};
            
            values = get(obj.calibrationCard.deviceListBox, 'Values');
            i = find(cellfun(@(v)isequal(v, old), values), 1) + 1;
            new = values{mod(i - 1, numel(values)) + 1};
            
            obj.selectDevice(new.device, new.setting);
        end
        
        function setSelectedDevice(obj, device, setting)
            v = struct('device', device, 'setting', setting);
            set(obj.calibrationCard.deviceListBox, 'Value', v);
        end
        
        function [device, setting] = getSelectedDevice(obj)
            v = get(obj.calibrationCard.deviceListBox, 'Value');
            if isempty(v)
                device = [];
                setting = [];
                return;
            end
            v = v{1};
            device = v.device;
            setting = v.setting;
        end
        
        function populateDetailsForLed(obj, led, setting)
            table = obj.getPreviousCalibrationTable(led, setting);
            if isempty(table)
                names = {'(None)'};
                values = {[]};
            else
                table = sortrows(table, 'date', 'descend');
                names = cell(1, height(table));
                values = cell(1, height(table));
                for i = 1:height(table)
                    names{i} = [datestr(table.date(i), 'dd-mmm-yyyy HH:MM PM') ' (' table.user{i} ')'];
                    values{i} = table(i, :);
                end
            end
            set(obj.calibrationCard.ledCard.useCalibrationPopupMenu, 'String', names);
            set(obj.calibrationCard.ledCard.useCalibrationPopupMenu, 'Values', values);
            set(obj.calibrationCard.ledCard.useCalibrationPopupMenu, 'Enable', appbox.onOff(~isempty(table)));
            set(obj.calibrationCard.ledCard.useButton, 'Enable', appbox.onOff(~isempty(table)));
            if isempty(led)
                set(obj.calibrationCard.ledCard.calibrationUnitsField, 'String', '');
            else
                set(obj.calibrationCard.ledCard.calibrationUnitsField, 'String', led.background.displayUnits);
            end
            
            set(obj.calibrationCard.detailCardPanel, 'Selection', 1);
        end
        
        function populateDetailsForStage(obj, stage, setting)
            table = obj.getPreviousCalibrationTable(stage, setting);
            if isempty(table)
                names = {'(None)'};
                values = {[]};
            else
                table = sortrows(table, 'date', 'descend');
                names = cell(1, height(table));
                values = cell(1, height(table));
                for i = 1:height(table)
                    names{i} = [datestr(table.date(i), 'dd-mmm-yyyy HH:MM PM') ' (' table.user{i} ')'];
                    values{i} = table(i, :);
                end
            end
            set(obj.calibrationCard.stageCard.useCalibrationPopupMenu, 'String', names);
            set(obj.calibrationCard.stageCard.useCalibrationPopupMenu, 'Values', values);
            set(obj.calibrationCard.stageCard.useCalibrationPopupMenu, 'Enable', appbox.onOff(~isempty(table)));
            set(obj.calibrationCard.stageCard.useButton, 'Enable', appbox.onOff(~isempty(table)));
            
            set(obj.calibrationCard.detailCardPanel, 'Selection', 2);
        end
        
        function t = getPreviousCalibrationTable(obj, device, setting)
            t = [];
            if ~isempty(device) && obj.previousCalibrations.isKey(device.name) && obj.previousCalibrations(device.name).isKey(setting)
                m = obj.previousCalibrations(device.name);
                t = m(setting);
            end
        end
        
        function onSelectedLedUse(obj, ~, ~)
            [device, setting] = obj.getSelectedDevice();
            if device == obj.stage
                return;
            end
            
            entry = get(obj.calibrationCard.ledCard.useCalibrationPopupMenu, 'Value');
            success = obj.calibrateDevice(device, setting, entry.intensity, entry.diameter, entry.power, true);
            if ~success
                return;
            end
            
            obj.selectNextDevice();
            obj.updateStateOfControls();
        end
        
        function success = calibrateDevice(obj, device, setting, intensity, diameter, power, reused)
            if nargin < 7
                reused = false;
            end
            
            if obj.isDeviceCalibrated(device, setting)
                result = obj.view.showMessage( ...
                    'This device has already been calibrated. Are you sure you want overwrite the current value?', ...
                    'Overwrite', ...
                    'button1', 'Cancel', ...
                    'button2', 'Overwrite');
                if ~strcmp(result, 'Overwrite')
                    success = false;
                    return;
                end
            end
            
            ssize = pi * diameter * diameter / 4;
            factor = power / (ssize * intensity);
            
            if obj.calibrations.isKey(device.name)
                m = obj.calibrations(device.name);
            else
                m = containers.Map();
            end
            m(setting) = struct( ...
                'date', datetime(), ...
                'user', char(System.Environment.UserName), ...
                'intensity', intensity, ...
                'diameter', diameter, ...
                'power', power, ...
                'factor', factor, ...
                'reused', reused);
            obj.calibrations(device.name) = m;
            obj.setDeviceCalibrated(device, setting);
            success = true;
        end
        
        function tf = isDeviceCalibrated(obj, device, setting)
            tf = any(strcmp('calibrations', device.getResourceNames())) || ...
                (obj.calibrations.isKey(device.name) && obj.calibrations(device.name).isKey(setting));
        end
        
        function setDeviceCalibrated(obj, device, setting)
            names = get(obj.calibrationCard.deviceListBox, 'String');
            values = get(obj.calibrationCard.deviceListBox, 'Values');
            
            i = cellfun(@(v)isequal(v, struct('device', device, 'setting', setting)), values);
            n = ['<html><font color="green"><b>' device.name];
            if ~strcmp(setting, 'none')
                n = [n ' - ' setting];
            end
            names{i} = n;
            
            set(obj.calibrationCard.deviceListBox, 'String', names);
            set(obj.calibrationCard.deviceListBox, 'Values', values);
        end
        
        function onSelectedLedOn(obj, ~, ~)
            obj.turnOffAllDevices();
            
            turnOn = get(obj.calibrationCard.ledCard.ledOnButton, 'Value');
            if turnOn
                led = obj.getSelectedDevice();
                intensity = str2double(get(obj.calibrationCard.ledCard.calibrationIntensityField, 'String'));
                obj.turnOnLed(led, intensity);
            end
            
            obj.updateStateOfControls();
        end
        
        function turnOnLed(obj, led, intensity)
            try
                led.background = symphonyui.core.Measurement(intensity, led.background.displayUnits);
                led.applyBackground();
                obj.isLedOn = true;
            catch x
                obj.view.showError(['Unable to turn on LED: ' x.message]);
                led.background = symphonyui.core.Measurement(0, led.background.displayUnits);
                obj.isLedOn = false;
                return;
            end
        end
        
        function turnOffLeds(obj, force)
            if ~obj.isLedOn && ~force
                return;
            end
            for i = 1:numel(obj.leds)
                led = obj.leds{i};
                led.background = symphonyui.core.Measurement(0, led.background.displayUnits);
                led.applyBackground();
            end
            obj.isLedOn = false;
        end
        
        function onSelectedStageUse(obj, ~, ~)
            [device, setting] = obj.getSelectedDevice();
            if device ~= obj.stage
                return;
            end
            
            entry = get(obj.calibrationCard.stageCard.useCalibrationPopupMenu, 'Value');
            success = obj.calibrateDevice(device, setting, entry.intensity, entry.diameter, entry.power, true);
            if ~success
                return;
            end
            
            obj.selectNextDevice();
            obj.updateStateOfControls();
        end
        
        function onSelectedStageOn(obj, ~, ~)
            obj.turnOffAllDevices();
            
            turnOn = get(obj.calibrationCard.stageCard.stageOnButton, 'Value');
            if turnOn
                device = obj.getSelectedDevice();
                intensity = str2double(get(obj.calibrationCard.stageCard.calibrationIntensityField, 'String'));
                diameter = str2double(get(obj.calibrationCard.stageCard.spotDiameterField, 'String'));
                obj.turnOnStage(device, intensity, diameter);
            end
            
            obj.updateStateOfControls();
        end
        
        function turnOnStage(obj, device, intensity, diameter)
            try
                p = stage.core.Presentation(1/device.getMonitorRefreshRate()); %#ok<PROPLC>

                spot = stage.builtin.stimuli.Ellipse(); %#ok<PROPLC>
                spot.position = device.getCanvasSize()/2;
                spot.color = intensity;
                spot.radiusX = device.um2pix(diameter/2);
                spot.radiusY = device.um2pix(diameter/2);
                p.addStimulus(spot);
                
                device.play(p);
                info = device.getPlayInfo();
                if isa(info, 'MException')
                    error(info.message);
                end
                obj.isStageOn = true;
            catch x
                obj.view.showError(['Unable to turn on stage: ' x.message]);
                device.play(stage.core.Presentation(1/device.getMonitorRefreshRate())); %#ok<PROPLC>
                device.getPlayInfo();
                obj.isStageOn = false;
                return;
            end
        end
        
        function turnOffStage(obj, force)
            if isempty(obj.stage) || (~obj.isStageOn && ~force)
                return;
            end
            obj.stage.play(stage.core.Presentation(1/obj.stage.getMonitorRefreshRate())); %#ok<PROPLC>
            obj.stage.getPlayInfo();
            obj.isStageOn = false;
        end
        
        function turnOffAllDevices(obj, force)
            if nargin < 2
                force = false;
            end
            obj.turnOffLeds(force);
            obj.turnOffStage(force);
        end
        
        function onSelectedLedSubmit(obj, ~, ~)            
            [device, setting] = obj.getSelectedDevice();
            if device == obj.stage
                return;
            end
            
            intensity = str2double(get(obj.calibrationCard.ledCard.calibrationIntensityField, 'String'));
            diameter = str2double(get(obj.calibrationCard.ledCard.spotDiameterField, 'String'));
            power = str2double(get(obj.calibrationCard.ledCard.powerReadingField, 'String'));
            if isnan(intensity) || isnan(diameter) || isnan(power)
                obj.view.showError('Could not parse intensity, power, or diameter to a valid scalar value.');
                return;
            end
            
            obj.submit(device, setting, intensity, diameter, power);
        end
        
        function onSelectedStageSubmit(obj, ~, ~)
            [device, setting] = obj.getSelectedDevice();
            if device ~= obj.stage
                return;
            end
            
            intensity = str2double(get(obj.calibrationCard.stageCard.calibrationIntensityField, 'String'));
            diameter = str2double(get(obj.calibrationCard.stageCard.spotDiameterField, 'String'));
            power = str2double(get(obj.calibrationCard.stageCard.powerReadingField, 'String'));
            if isnan(intensity) || isnan(diameter) || isnan(power)
                obj.view.showError('Could not parse intensity, power, or diameter to a valid scalar value.');
                return;
            end
            
            obj.submit(device, setting, intensity, diameter, power);
        end
        
        function submit(obj, device, setting, intensity, diameter, power)
            success = obj.calibrateDevice(device, setting, intensity, diameter, power);
            if ~success
                return;
            end
            
            obj.selectNextDevice();
            obj.updateStateOfControls();
        end
        
        function onSelectedBack(obj, ~, ~)
            selection = get(obj.wizardCardPanel, 'Selection');
            set(obj.wizardCardPanel, 'Selection', selection - 1);
            
            obj.updateStateOfControls();
        end
        
        function onSelectedNext(obj, ~, ~)
            selection = get(obj.wizardCardPanel, 'Selection');
            if selection < numel(get(obj.wizardCardPanel, 'Children'))
                set(obj.wizardCardPanel, 'Selection', selection + 1);
            end
            
            if strcmp(get(obj.nextButton, 'String'), 'Finish')
                obj.saveCalibration();
                obj.turnOffAllDevices();
                obj.stop();
            else
                obj.turnOffAllDevices(true);
                [device, setting] = obj.getSelectedDevice();
                obj.selectDevice(device, setting);
            end
        end
        
        function saveCalibration(obj)
            keys = obj.calibrations.keys;
            for i = 1:numel(keys)
                name = keys{i};
                device = obj.allDevices{cellfun(@(l)strcmp(l.name, name), obj.allDevices)};
                
                if any(strcmp('calibrations', device.getResourceNames()))
                    device.removeResource('calibrations');
                end
                if ~obj.calibrations.isKey(name)
                    continue;
                end
                cal = obj.calibrations(name);
                device.addResource('calibrations', cal);
                
                if ~obj.previousCalibrations.isKey(name)
                    continue;
                end
                prevCal = obj.previousCalibrations(name);
                
                if ~any(strcmp('fluxFactorPaths', device.getResourceNames()))
                    continue;
                end
                paths = device.getResource('fluxFactorPaths');
                
                settings = cal.keys;
                for k = 1:numel(settings)
                    setting = settings{k};
                    if prevCal.isKey(setting)
                        t = prevCal(setting);
                    else
                        t = table();
                    end
                    entry = struct2table(cal(setting));
                    if entry.reused
                        continue;
                    end
                    entry.user = {entry.user};
                    entry.reused = [];
                    t(end + 1, :) = entry; %#ok<AGROW>
                    writetable(t, paths(setting), 'Delimiter', 'tab');
                    prevCal(setting) = t;
                end
                
                obj.previousCalibrations(name) = prevCal;
            end
        end
        
        function onSelectedCancel(obj, ~, ~)
            obj.close();
        end
        
        function close(obj)
            shouldClose = true;
            if ~isempty(obj.calibrations)
                result = obj.view.showMessage( ...
                    ['You have calibrated some devices. You will lose these values if you close the calibrator. ' ...
                    'Are you sure you want to close?'], 'Close', ...
                    'button1', 'Cancel', ...
                    'button2', 'Close');
                shouldClose = strcmp(result, 'Close');
            end
            if shouldClose
                obj.stop();
            end
        end
        
        function updateStateOfControls(obj)
            import appbox.*;
            
            device = obj.getSelectedDevice();
            
            hasDevice = ~isempty(device);
            isLastCard = get(obj.wizardCardPanel, 'Selection') >= numel(get(obj.wizardCardPanel, 'Children'));
            allCalibrated = all(cellfun(@(s)obj.isDeviceCalibrated(s.device, s.setting), ...
                get(obj.calibrationCard.deviceListBox, 'Values')));
            
            set(obj.calibrationCard.ledCard.calibrationIntensityField, 'Enable', onOff(hasDevice && ~obj.isLedOn));
            set(obj.calibrationCard.ledCard.ledOnButton, 'Enable', onOff(hasDevice));
            set(obj.calibrationCard.ledCard.ledOnButton, 'Value', obj.isLedOn);
            set(obj.calibrationCard.ledCard.spotDiameterField, 'Enable', onOff(hasDevice && obj.isLedOn));
            set(obj.calibrationCard.ledCard.powerReadingField, 'Enable', onOff(hasDevice && obj.isLedOn));
            set(obj.calibrationCard.ledCard.submitButton, 'Enable', onOff(hasDevice && obj.isLedOn));
            set(obj.calibrationCard.stageCard.calibrationIntensityField, 'Enable', onOff(hasDevice && ~obj.isStageOn));
            set(obj.calibrationCard.stageCard.spotDiameterField, 'Enable', onOff(hasDevice && ~obj.isStageOn));
            set(obj.calibrationCard.stageCard.stageOnButton, 'Enable', onOff(hasDevice));
            set(obj.calibrationCard.stageCard.stageOnButton, 'Value', obj.isStageOn);
            set(obj.calibrationCard.stageCard.powerReadingField, 'Enable', onOff(hasDevice && obj.isStageOn));
            set(obj.calibrationCard.stageCard.submitButton, 'Enable', onOff(hasDevice && obj.isStageOn));
            set(obj.backButton, 'Enable', onOff(isLastCard));
            set(obj.nextButton, 'Enable', onOff(~isLastCard || allCalibrated));
            if isLastCard
                set(obj.nextButton, 'String', 'Finish');
            else
                set(obj.nextButton, 'String', 'Next >');
            end
        end
        
    end
    
end

