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
                'Callback', @obj.onSelectedLedHelp);
            Button( ...
                'Parent', parametersLayout, ...
                'Icon', App.getResource('icons', 'help.png'), ...
                'Callback', @obj.onSelectedNdfsHelp);
            Button( ...
                'Parent', parametersLayout, ...
                'Icon', App.getResource('icons', 'help.png'), ...
                'Callback', @obj.onSelectedGainHelp);
            Button( ...
                'Parent', parametersLayout, ...
                'Icon', App.getResource('icons', 'help.png'), ...
                'Callback', @obj.onSelectedLightPathHelp);
            Button( ...
                'Parent', parametersLayout, ...
                'Icon', App.getResource('icons', 'help.png'), ...
                'Callback', @obj.onSelectedSpeciesHelp);
            set(parametersLayout, ...
                'Widths', [65 -1 22], ...
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
        end

        function onSelectedLedHelp(obj, ~, ~)
            obj.view.showMessage('onSelectedLedHelp');
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
            obj.view.showMessage('onSelectedNdfsHelp');
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
            obj.view.showMessage('onSelectedGainHelp');
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
            obj.view.showMessage('onSelectedLightPathHelp');
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
            obj.view.showMessage('onSelectedSpeciesHelp');
        end
        
        function populateConverterBox(obj)
            import appbox.*;
            
            converterLayout = uix.Grid( ...
                'Parent', obj.converterControls.box, ...
                'Spacing', 7);
            
            h = get(obj.mainLayout, 'Heights');
            set(obj.mainLayout, 'Heights', [h(1) 25+11+layoutHeight(converterLayout)+11]);
        end
        
        function pack(obj)
            f = obj.view.getFigureHandle();
            p = get(f, 'Position');
            set(f, 'Position', [p(1) p(2) p(3) appbox.layoutHeight(obj.mainLayout)]);
        end

        function onServiceBeganEpochGroup(obj, ~, ~)
            obj.species = obj.findSpecies();
            obj.populateSpecies();
            %obj.populatePhotoreceptorList();
        end

        function onServiceEndedEpochGroup(obj, ~, ~)
            obj.species = obj.findSpecies();
            obj.populateSpecies();
            %obj.populatePhotoreceptorList();
        end

        function onServiceClosedFile(obj, ~, ~)
            obj.species = [];
            obj.populateSpecies();
        end

        function onServiceInitializedRig(obj, ~, ~)
            obj.unbindLeds();
            obj.leds = obj.configurationService.getDevices('LED');
            obj.populateLedList();
            obj.bindLeds();
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
        end

    end

end
