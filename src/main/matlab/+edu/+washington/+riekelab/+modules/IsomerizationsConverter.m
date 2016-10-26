classdef IsomerizationsConverter < symphonyui.ui.Module

    properties (Access = private)
        leds
        ledListeners
        species
    end

    properties (Access = private)
        mainLayout
        parametersControls
        converterControls
    end

    methods

        function createUi(obj, figureHandle)
            import appbox.*;
            import symphonyui.app.App;

            set(figureHandle, ...
                'Name', 'Isomerizations Converter', ...
                'Position', screenCenter(273, 313), ...
                'Resize', 'off');

            obj.mainLayout = uix.VBox( ...
                'Parent', figureHandle);

            obj.parametersControls.box = uix.BoxPanel( ...
                'Parent', obj.mainLayout, ...
                'Title', 'Parameters', ...
                'BorderType', 'none', ...
                'FontUnits', get(figureHandle, 'DefaultUicontrolFontUnits'), ...
                'FontName', get(figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(figureHandle, 'DefaultUicontrolFontSize'), ...
                'Padding', 11);
            parametersLayout = uix.Grid( ...
                'Parent', obj.parametersControls.box, ...
                'Spacing', 7);
            Label( ...
                'Parent', parametersLayout, ...
                'String', 'LED:');
            Label( ...
                'Parent', parametersLayout, ...
                'String', 'NDFs:');
            Label( ...
                'Parent', parametersLayout, ...
                'String', 'Gain:');
            Label( ...
                'Parent', parametersLayout, ...
                'String', 'Light Path:');
            Label( ...
                'Parent', parametersLayout, ...
                'String', 'Species:');
            obj.parametersControls.ledPopupMenu = MappedPopupMenu( ...
                'Parent', parametersLayout, ...
                'String', {' '}, ...
                'HorizontalAlignment', 'left', ...
                'Callback', @obj.onSelectedLed);
            obj.parametersControls.ndfsField = uicontrol( ...
                'Parent', parametersLayout, ...
                'Style', 'edit', ...
                'HorizontalAlignment', 'left', ...
                'Enable', 'off');
            obj.parametersControls.gainField = uicontrol( ...
                'Parent', parametersLayout, ...
                'Style', 'edit', ...
                'HorizontalAlignment', 'left', ...
                'Enable', 'off');
            obj.parametersControls.lightPathField = uicontrol( ...
                'Parent', parametersLayout, ...
                'Style', 'edit', ...
                'HorizontalAlignment', 'left', ...
                'Enable', 'off');
            obj.parametersControls.speciesField = uicontrol( ...
                'Parent', parametersLayout, ...
                'Style', 'edit', ...
                'HorizontalAlignment', 'left', ...
                'Enable', 'off');
            Button( ...
                'Parent', parametersLayout, ...
                'Icon', App.getResource('icons', 'help.png'), ...
                'TooltipString', 'LED Help', ...
                'Callback', @obj.onSelectedLedHelp);
            Button( ...
                'Parent', parametersLayout, ...
                'Icon', App.getResource('icons', 'help.png'), ...
                'TooltipString', 'NDFs Help', ...
                'Callback', @obj.onSelectedNdfsHelp);
            Button( ...
                'Parent', parametersLayout, ...
                'Icon', App.getResource('icons', 'help.png'), ...
                'TooltipString', 'Gain Help', ...
                'Callback', @obj.onSelectedGainHelp);
            Button( ...
                'Parent', parametersLayout, ...
                'Icon', App.getResource('icons', 'help.png'), ...
                'TooltipString', 'Light Path Help', ...
                'Callback', @obj.onSelectedLightPathHelp);
            Button( ...
                'Parent', parametersLayout, ...
                'Icon', App.getResource('icons', 'help.png'), ...
                'TooltipString', 'Species Help', ...
                'Callback', @obj.onSelectedSpeciesHelp);
            set(parametersLayout, ...
                'Widths', [70 -1 22], ...
                'Heights', [23 23 23 23 23]);

            obj.converterControls.box = uix.BoxPanel( ...
                'Parent', obj.mainLayout, ...
                'Title', 'Converter', ...
                'BorderType', 'none', ...
                'FontUnits', get(figureHandle, 'DefaultUicontrolFontUnits'), ...
                'FontName', get(figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(figureHandle, 'DefaultUicontrolFontSize'), ...
                'Padding', 11);

            set(obj.mainLayout, 'Heights', [25+11+layoutHeight(parametersLayout)+11 -1]);
        end

    end

    methods (Access = protected)

        function willGo(obj)
            obj.leds = obj.configurationService.getDevices('LED');
            obj.species = obj.findSpecies();
            
            obj.populateParametersBox();
            obj.populateConverterBox();
            
            obj.pack();
        end

        function bind(obj)
            bind@symphonyui.ui.Module(obj);

            obj.bindLeds();

            d = obj.documentationService;
            obj.addListener(d, 'BeganEpochGroup', @obj.onServiceBeganEpochGroup);
            obj.addListener(d, 'EndedEpochGroup', @obj.onServiceEndedEpochGroup);
            obj.addListener(d, 'ClosedFile', @obj.onServiceClosedFile);

            c = obj.configurationService;
            obj.addListener(c, 'InitializedRig', @obj.onServiceInitializedRig);
        end

    end

    methods (Access = private)

        function bindLeds(obj)
            for i = 1:numel(obj.leds)
                obj.ledListeners{end + 1} = obj.addListener(obj.leds{i}, 'AddedConfigurationSetting', @obj.onLedChangedConfigurationSetting);
                obj.ledListeners{end + 1} = obj.addListener(obj.leds{i}, 'SetConfigurationSetting', @obj.onLedChangedConfigurationSetting);
                obj.ledListeners{end + 1} = obj.addListener(obj.leds{i}, 'RemovedConfigurationSetting', @obj.onLedChangedConfigurationSetting);
                obj.ledListeners{end + 1} = obj.addListener(obj.leds{i}, 'AddedResource', @obj.onLedAddedResource);
            end
        end

        function unbindLeds(obj)
            while ~isempty(obj.ledListeners)
                obj.removeListener(obj.ledListeners{1});
                obj.ledListeners(1) = [];
            end
        end
        
        function populateParametersBox(obj)
            obj.populateLedList();
            obj.populateNdfs();
            obj.populateGain();
            obj.populateLightPath();
            obj.populateSpecies();
        end

        function populateLedList(obj)
            names = cell(1, numel(obj.leds));
            for i = 1:numel(obj.leds)
                names{i} = obj.leds{i}.name;
            end

            if numel(obj.leds) > 0
                set(obj.parametersControls.ledPopupMenu, 'String', names);
                set(obj.parametersControls.ledPopupMenu, 'Values', obj.leds);
            else
                set(obj.parametersControls.ledPopupMenu, 'String', {' '});
                set(obj.parametersControls.ledPopupMenu, 'Values', {[]});
            end
            set(obj.parametersControls.ledPopupMenu, 'Enable', appbox.onOff(numel(obj.leds) > 0));
        end

        function onSelectedLed(obj, ~, ~)
            obj.populateNdfs();
            obj.populateGain();
            obj.populateLightPath();
            obj.populateConverterBox();
            obj.pack();
        end

        function onSelectedLedHelp(obj, ~, ~)
            obj.view.showMessage(['Select the LED for which to perform isomerizations conversions. This popup menu ' ...
                'is populated based on the LEDs in the currently initialized rig.'], 'LED Help');
        end

        function populateNdfs(obj)
            led = get(obj.parametersControls.ledPopupMenu, 'Value');
            if isempty(led)
                set(obj.parametersControls.ndfsField, 'String', '');
            else
                ndfs = led.getConfigurationSetting('ndfs');
                set(obj.parametersControls.ndfsField, 'String', strjoin(ndfs, '; '));
            end
        end

        function onSelectedNdfsHelp(obj, ~, ~)
            obj.view.showMessage(['The ndfs field is auto-populated by the value of the ''ndfs'' configuration ' ...
                'setting on the selected LED. Device configuration settings may be changed through the ''Device ' ...
                'Configurator'' module.'], 'NDFs Help');
        end

        function populateGain(obj)
            led = get(obj.parametersControls.ledPopupMenu, 'Value');
            if isempty(led)
                set(obj.parametersControls.gainField, 'String', '');
            else
                gain = led.getConfigurationSetting('gain');
                set(obj.parametersControls.gainField, 'String', gain);
            end
        end

        function onSelectedGainHelp(obj, ~, ~)
            obj.view.showMessage(['The gain field is auto-populated by the value of the ''gain'' configuration ' ...
                'setting on the selected LED. Device configuration settings may be changed through the ''Device ' ...
                'Configurator'' module.'], 'Gain Help');
        end
        
        function populateLightPath(obj)
            led = get(obj.parametersControls.ledPopupMenu, 'Value');
            if isempty(led)
                set(obj.parametersControls.lightPathField, 'String', '');
            else
                path = led.getConfigurationSetting('lightPath');
                set(obj.parametersControls.lightPathField, 'String', path);
            end
        end

        function onSelectedLightPathHelp(obj, ~, ~)
            obj.view.showMessage(['The light path field is auto-populated by the value of the ''lightPath'' configuration ' ...
                'setting on the selected LED. Device configuration settings may be changed through the ''Device ' ...
                'Configurator'' module.'], 'Light Path Help');
        end

        function populateSpecies(obj)
            if isempty(obj.species)
                set(obj.parametersControls.speciesField, 'String', '');
            else
                set(obj.parametersControls.speciesField, 'String', obj.species.label);
            end
        end

        function s = findSpecies(obj)
            s = [];
            if ~obj.documentationService.hasOpenFile()
                return;
            end

            group = obj.documentationService.getCurrentEpochGroup();
            if isempty(group)
                return;
            end

            source = group.source;
            while ~isempty(source) && ~any(strcmp(source.getResourceNames(), 'photoreceptors'))
                source = source.parent;
            end
            s = source;
        end

        function onSelectedSpeciesHelp(obj, ~, ~)
            obj.view.showMessage(['The species field is auto-populated based on the species of the source of the ' ...
                'current epoch group. If there is no current epoch group, this field will be empty.'], 'Species Help');
        end
        
        function populateConverterBox(obj)
            import appbox.*;
            
            converterLayout = uix.VBox( ...
                'Parent', obj.converterControls.box, ...
                'Spacing', 7);
            
            obj.converterControls.fields = containers.Map();            
            
            [tf, msg] = obj.isValid();
            if ~tf
                Label( ...
                    'Parent', converterLayout, ...
                    'String', msg, ...
                    'HorizontalAlignment', 'center');
                set(converterLayout, 'Heights', 23);
                
                h = get(obj.mainLayout, 'Heights');
                set(obj.mainLayout, 'Heights', [h(1) 25+11+23+11]);
                return;
            end
            
            photoreceptors = obj.species.getResource('photoreceptors');
            keys = [{} {'volts'} photoreceptors.keys];
            for i = 1:numel(keys)
                k = keys{i};
                layout = uix.HBox( ...
                    'Parent', converterLayout, ...
                    'Spacing', 7);
                if i == 1
                    label = [capitalize(humanize(k)) ':']; 
                else
                    label = [capitalize(humanize(k)) ' R*/s:'];
                end
                Label( ...
                    'Parent', layout, ...
                    'String', label);
                f.control = uicontrol( ...
                    'Parent', layout, ...
                    'Style', 'edit', ...
                    'String', '0', ...
                    'HorizontalAlignment', 'left', ...
                    'KeyPressFcn', @(h,d)obj.onFieldKeyPress(h, struct('fieldName', k)));
                obj.converterControls.fields(k) = f; 
                Button( ...
                    'Parent', layout, ...
                    'Icon', symphonyui.app.App.getResource('icons', 'copy.png'), ...
                    'TooltipString', 'Copy To Clipboard', ...
                    'Callback', @(h,d)obj.onSelectedCopy(h, struct('fieldName', k)));
                set(layout, 'Widths', [70 -1 22]);
            end
            set(converterLayout, 'Heights', ones(1, numel(keys))*23);
            
            h = get(obj.mainLayout, 'Heights');
            set(obj.mainLayout, 'Heights', [h(1) 25+11+layoutHeight(converterLayout)+11]);
        end
        
        function [tf, msg] = isValid(obj)
            msg = '';
            led = get(obj.parametersControls.ledPopupMenu, 'Value');
            if isempty(led)
                msg = 'LED must not be empty';
            elseif ~any(strcmp('spectrum', led.getResourceNames()))
                msg = 'LED is missing spectrum';
            elseif ~any(strcmp('ndfAttenuations', led.getResourceNames()))
                msg = 'LED is missing ndf attentuations';
            elseif ~any(strcmp('calibrations', led.getResourceNames()))
                msg = 'LED must be calibrated';
            elseif ~led.hasConfigurationSetting('ndfs')
                msg = 'LED is missing ndfs setting';
            elseif ~led.hasConfigurationSetting('gain')
                msg = 'LED is missing gain setting';
            elseif isempty(led.getConfigurationSetting('gain'))
                msg = 'Gain must not be empty';
            elseif ~led.hasConfigurationSetting('lightPath')
                msg = 'LED is missing light path setting';
            elseif isempty(led.getConfigurationSetting('lightPath'))
                msg = 'Light path must not be empty';
            elseif isempty(obj.species)
                msg = 'Species must not be empty';
            elseif ~any(strcmp('photoreceptors', obj.species.getResourceNames()))
                msg = 'Species is missing photoreceptors';
            end
            tf = isempty(msg);
        end
        
        function onFieldKeyPress(obj, ~, event)
            field = obj.converterControls.fields(event.fieldName);
            if ~isfield(field, 'jcontrol')
                field.jcontrol = findjobj(field.control);
                obj.converterControls.fields(event.fieldName) = field;
            end
            value = char(field.jcontrol.getText());
            
            led = get(obj.parametersControls.ledPopupMenu, 'Value');
            spectrum = led.getResource('spectrum');
            attenuations = led.getResource('ndfAttenuations');
            calibrations = led.getResource('calibrations');
            ndfs = led.getConfigurationSetting('ndfs');
            gain = led.getConfigurationSetting('gain');
            path = led.getConfigurationSetting('lightPath');
            photoreceptors = obj.species.getResource('photoreceptors');
            
            if strcmp(event.fieldName, 'volts')
                volts = str2double(value);
            else
                isom = str2double(value);
                volts = edu.washington.riekelab.baudin.modules.IsomerizationsConverterUtilities.SymphonyIsomerizationsConverter( ...
                    calibrations(gain), ...
                    spectrum, ...
                    photoreceptors(event.fieldName).spectrum, ...
                    photoreceptors(event.fieldName).collectingArea, ...
                    strjoin(ndfs, ';'), ...
                    attenuations, ...
                    'isomtovolts', ...
                    isom);
                set(obj.converterControls.fields('volts').control, 'String', num2str(volts));
            end
            
            names = photoreceptors.keys;
            names(strcmp(names, event.fieldName)) = [];
            for i = 1:numel(names)
                n = names{i};
                v = edu.washington.riekelab.baudin.modules.IsomerizationsConverterUtilities.SymphonyIsomerizationsConverter( ...
                    calibrations(gain), ...
                    spectrum, ...
                    photoreceptors(n).spectrum, ...
                    photoreceptors(n).collectingArea, ...
                    strjoin(ndfs, ';'), ...
                    attenuations, ...
                    'voltstoisom', ...
                    volts);
                set(obj.converterControls.fields(n).control, 'String', num2str(round(v)));
            end
        end
        
        function onSelectedCopy(obj, ~, event)
            field = obj.converterControls.fields(event.fieldName);
            if ~isfield(field, 'jcontrol')
                field.jcontrol = findjobj(field.control);
                obj.converterControls.fields(event.fieldName) = field;
            end
            value = char(field.jcontrol.getText());
            clipboard('copy', value);
            disp(['Copied: ' value]);
        end
        
        function pack(obj)
            f = obj.view.getFigureHandle();
            p = get(f, 'Position');
            h = appbox.layoutHeight(obj.mainLayout);
            delta = p(4) - h;
            set(f, 'Position', [p(1) p(2)+delta p(3) h]);
        end
        
        function onLedChangedConfigurationSetting(obj, handle, event)
            if handle ~= get(obj.parametersControls.ledPopupMenu, 'Value')
                return;
            end
            
            setting = event.data;
            if any(strcmp(setting.name, {'ndfs', 'gain', 'lightPath'}))
                obj.populateNdfs();
                obj.populateGain();
                obj.populateLightPath();
                obj.populateConverterBox();
                obj.pack();
            end
        end
        
        function onLedAddedResource(obj, handle, event)
            if handle ~= get(obj.parametersControls.ledPopupMenu, 'Value')
                return;
            end
            
            resource = event.data;
            if strcmp(resource.name, 'calibrations')
                obj.populateConverterBox();
                obj.pack();
            end
        end

        function onServiceBeganEpochGroup(obj, ~, ~)
            obj.species = obj.findSpecies();
            
            obj.populateSpecies();
            obj.populateConverterBox();
            
            obj.pack();
        end

        function onServiceEndedEpochGroup(obj, ~, ~)
            obj.species = obj.findSpecies();
            
            obj.populateSpecies();
            obj.populateConverterBox();
            
            obj.pack();
        end

        function onServiceClosedFile(obj, ~, ~)
            obj.species = [];
            
            obj.populateSpecies();
            obj.populateConverterBox();
            
            obj.pack();
        end

        function onServiceInitializedRig(obj, ~, ~)
            obj.unbindLeds();
            
            obj.leds = obj.configurationService.getDevices('LED');
            
            obj.populateParametersBox();
            obj.populateConverterBox();
            
            obj.pack();
            
            obj.bindLeds();
        end

    end

end
