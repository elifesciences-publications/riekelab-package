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
                obj.ledListeners{end + 1} = obj.addListener(obj.leds{i}, 'SetConfigurationSetting', @obj.onLedSetConfigurationSetting);
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
            
            converterLayout = uix.Grid( ...
                'Parent', obj.converterControls.box, ...
                'Spacing', 7);
            
            text = '';
            led = get(obj.parametersControls.ledPopupMenu, 'Value');
            if isempty(led)
                text = 'LED must not be empty';
            elseif isempty(obj.species)
                text = 'Species must not be empty';
            else
                ndfs = led.getConfigurationSetting('ndfs');
                gain = led.getConfigurationSetting('gain');
                if isempty(gain)
                    text = 'Gain must not be empty';
                end
                path = led.getConfigurationSetting('lightPath');
                if isempty(path)
                    text = 'Light path must not be empty';
                end
                photoreceptors = obj.species.getResource('photoreceptors');
            end
            
            if isempty(text)
                obj.converterControls.fields = containers.Map();
                
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
                    obj.converterControls.fields(k) = uicontrol( ...
                        'Parent', layout, ...
                        'Style', 'edit', ...
                        'HorizontalAlignment', 'left');
                    Button( ...
                        'Parent', layout, ...
                        'Icon', symphonyui.app.App.getResource('icons', 'copy.png'), ...
                        'TooltipString', 'Copy To Clipboard', ...
                        'Callback', @(h,d)obj.onSelectedCopy(h, struct('key', k)));
                    set(layout, 'Widths', [70 -1 22]);
                end
                set(converterLayout, 'Heights', ones(1, numel(keys))*23);
            else
                Label( ...
                    'Parent', converterLayout, ...
                    'String', text, ...
                    'HorizontalAlignment', 'center');
                set(converterLayout, 'Heights', 23);
            end
            
            h = get(obj.mainLayout, 'Heights');
            set(obj.mainLayout, 'Heights', [h(1) 25+11+layoutHeight(converterLayout)+11]);
        end
        
        function onSelectedCopy(obj, ~, event)
            obj.requestFigureFocus();
            obj.view.update();
            
            field = obj.converterControls.fields(event.key);
            value = get(field, 'String');
            disp(value);
            clipboard('copy', value);
        end
        
        function requestFigureFocus(obj)
            warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
            javaFrame = get(obj.view.getFigureHandle(), 'JavaFrame');
            warning('on','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
            javaFrame.getAxisComponent().requestFocus();
        end
        
        function pack(obj)
            f = obj.view.getFigureHandle();
            p = get(f, 'Position');
            h = appbox.layoutHeight(obj.mainLayout);
            delta = p(4) - h;
            set(f, 'Position', [p(1) p(2)+delta p(3) h]);
        end
        
        function onLedSetConfigurationSetting(obj, ~, event)
            setting = event.data;
            switch setting.name
                case 'ndfs'
                    obj.populateNdfs();
                case 'gain'
                    obj.populateGain();
                case 'lightPath'
                    obj.populateLightPath();
            end
            
            obj.populateConverterBox();
            obj.pack();
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
