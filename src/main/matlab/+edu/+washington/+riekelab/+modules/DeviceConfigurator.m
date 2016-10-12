classdef DeviceConfigurator < symphonyui.ui.Module
    
    properties (Access = private)
        leds
        stage
        deviceListeners
    end
    
    properties (Access = private)
        mainLayout
        ndfsControls
        gainControls
        lightPathControls
    end
    
    methods
        
        function createUi(obj, figureHandle)
            import appbox.*;
            
            set(figureHandle, ...
                'Name', 'Device Configurator', ...
                'Position', screenCenter(330, 300), ...
                'Resize', 'off');
            
            obj.mainLayout = uix.VBox( ...
                'Parent', figureHandle);
            
            obj.ndfsControls.box = uix.BoxPanel( ...
                'Parent', obj.mainLayout, ...
                'Title', 'ND Filters', ...
                'BorderType', 'none', ...
                'FontUnits', get(figureHandle, 'DefaultUicontrolFontUnits'), ...
                'FontName', get(figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(figureHandle, 'DefaultUicontrolFontSize'), ...
                'Padding', 11);
            
            obj.gainControls.box = uix.BoxPanel( ...
                'Parent', obj.mainLayout, ...
                'Title', 'Gain', ...
                'BorderType', 'none', ...
                'FontUnits', get(figureHandle, 'DefaultUicontrolFontUnits'), ...
                'FontName', get(figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(figureHandle, 'DefaultUicontrolFontSize'), ...
                'Padding', 11);
            
            obj.lightPathControls.box = uix.BoxPanel( ...
                'Parent', obj.mainLayout, ...
                'Title', 'Light Path', ...
                'BorderType', 'none', ...
                'FontUnits', get(figureHandle, 'DefaultUicontrolFontUnits'), ...
                'FontName', get(figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(figureHandle, 'DefaultUicontrolFontSize'), ...
                'Padding', 11);
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
            
            obj.populateNdfsBox();
            obj.populateGainBox();
            obj.populateLightPathBox();
            
            obj.pack();
        end
        
        function bind(obj)
            bind@symphonyui.ui.Module(obj);
            
            obj.bindDevices();
            
            c = obj.configurationService;
            obj.addListener(c, 'InitializedRig', @obj.onServiceInitializedRig);
        end
        
    end
    
    methods (Access = private)
        
        function bindDevices(obj)
            devices = obj.leds;
            if ~isempty(obj.stage)
                devices = [{} devices {obj.stage}];
            end
            for i = 1:numel(devices)
                obj.deviceListeners{end + 1} = obj.addListener(devices{i}, 'SetConfigurationSetting', @obj.onDeviceSetConfigurationSetting);
            end
        end
        
        function unbindDevices(obj)
            while ~isempty(obj.deviceListeners)
                obj.removeListener(obj.deviceListeners{1});
                obj.deviceListeners(1) = [];
            end
        end
        
        function populateNdfsBox(obj)
            import appbox.*;
            
            obj.ndfsControls.popupMenus = containers.Map();
            
            ndfsLayout = uix.VBox( ...
                'Parent', obj.ndfsControls.box, ...
                'Spacing', 7);
            
            for i = 1:numel(obj.leds)
                led = obj.leds{i};
                
                desc = led.getConfigurationSettingDescriptors().findByName('ndfs');
                if isempty(desc)
                    continue;
                end
                availableNdfs = desc.type.domain;
                activeNdfs = desc.value;
                
                ledLayout = uix.HBox( ...
                    'Parent', ndfsLayout, ...
                    'Spacing', 7);
                Label( ...
                    'Parent', ledLayout, ...
                    'String', [led.name ':']);
                obj.ndfsControls.popupMenus(led.name) = CheckBoxPopupMenu( ...
                    'Parent', ledLayout, ...
                    'String', availableNdfs, ...
                    'Value', find(cellfun(@(n)any(strcmp(n, activeNdfs)), availableNdfs)), ...
                    'Callback', @(h,d)obj.onSelectedNdfs(h, struct('led', led, 'ndfs', {h.String(h.Value)})));
                Label( ...
                    'Parent', ledLayout, ...
                    'String', ['<html><font color="' colorFromLedName(led.name) '">&#9632;</font></html>']);
                
                set(ledLayout, 'Widths', [60 -1 9]);
            end
            
            set(ndfsLayout, 'Heights', ones(1, numel(ndfsLayout.Children)) * 23);
            
            h = get(obj.mainLayout, 'Heights');
            set(obj.mainLayout, 'Heights', [25+11+layoutHeight(ndfsLayout)+11 h(2) h(3)]);
        end
        
        function updateNdfsBox(obj)
            for i = 1:numel(obj.leds)
                led = obj.leds{i};
                
                desc = led.getConfigurationSettingDescriptors().findByName('ndfs');
                if isempty(desc)
                    continue;
                end
                availableNdfs = desc.type.domain;
                activeNdfs = desc.value;
                
                menu = obj.ndfsControls.popupMenus(led.name);
                set(menu, 'Value', find(cellfun(@(n)any(strcmp(n, activeNdfs)), availableNdfs)));
            end
        end
        
        function onSelectedNdfs(obj, ~, event)
            led = event.led;
            ndfs = event.ndfs;
            try
                led.setConfigurationSetting('ndfs', ndfs);
            catch x
                obj.view.showError(x.message);
                obj.updateNdfsBox();
                return;
            end
        end
        
        function populateGainBox(obj)
            import appbox.*;
            
            obj.gainControls.buttonGroups = containers.Map();
            
            gainLayout = uix.VBox( ...
                'Parent', obj.gainControls.box, ...
                'Spacing', 7);
            
            for i = 1:numel(obj.leds)
                led = obj.leds{i};
                
                desc = led.getConfigurationSettingDescriptors().findByName('gain');
                if isempty(desc)
                    continue;
                end
                availableGains = desc.type.domain;
                
                ledLayout = uix.HBox( ...
                    'Parent', gainLayout, ...
                    'Spacing', 7);
                Label( ...
                    'Parent', ledLayout, ...
                    'String', [led.name ':']);
                obj.gainControls.buttonGroups(led.name) = uix.HButtonGroup( ...
                    'Parent', ledLayout, ...
                    'ButtonStyle', 'toggle', ...
                    'Buttons', {'low', 'medium', 'high'}, ...
                    'ButtonSize', [75 23], ...
                    'Enable', { ...
                        onOff(any(strcmp('low', availableGains))), ...
                        onOff(any(strcmp('medium', availableGains))), ...
                        onOff(any(strcmp('high', availableGains)))}, ...
                    'HorizontalAlignment', 'left', ...
                    'Selection', find(strcmp(desc.value, {'low', 'medium', 'high'}), 1), ...
                    'SelectionChangeFcn', @(h,d)obj.onSelectedGain(h, struct('led', led, 'gain', h.Buttons{h.Selection})));
                Label( ...
                    'Parent', ledLayout, ...
                    'String', ['<html><font color="' colorFromLedName(led.name) '">&#9632;</font></html>']);
                
                set(ledLayout, 'Widths', [60 -1 9]);
            end
            
            set(gainLayout, 'Heights', ones(1, numel(gainLayout.Children)) * 23);
            
            h = get(obj.mainLayout, 'Heights');
            set(obj.mainLayout, 'Heights', [h(1) 25+11+layoutHeight(gainLayout)+11 h(3)]);
        end
        
        function updateGainBox(obj)
            for i = 1:numel(obj.leds)
                led = obj.leds{i};
                
                desc = led.getConfigurationSettingDescriptors().findByName('gain');
                if isempty(desc)
                    continue;
                end
                
                group = obj.gainControls.buttonGroups(led.name);
                set(group, 'Selection', find(strcmp(desc.value, {'low', 'medium', 'high'}), 1));
            end
        end
        
        function onSelectedGain(obj, ~, event)
            led = event.led;
            gain = event.gain;
            try
                led.setConfigurationSetting('gain', gain);
            catch x
                obj.view.showError(x.message);
                obj.updateGainBox();
                return;
            end
        end
        
        function populateLightPathBox(obj)
            import appbox.*;
            
            lightPathLayout = uix.VBox( ...
                'Parent', obj.lightPathControls.box, ...
                'Spacing', 7);
            
            commonPath = [];
            for i = 1:numel(obj.leds)
                led = obj.leds{i};
                
                desc = led.getConfigurationSettingDescriptors().findByName('lightPath');
                if isempty(desc)
                    commonPath = [];
                    break;
                end
                
                if ~ischar(commonPath)
                    commonPath = desc.value;
                end
                
                if ~strcmp(desc.value, commonPath)
                    commonPath = [];
                    break;
                end
            end
            
            allLayout = uix.HBox( ...
                'Parent', lightPathLayout, ...
                'Spacing', 7);
            Label( ...
                'Parent', allLayout, ...
                'String', 'All:');
            obj.lightPathControls.popupMenu = MappedPopupMenu( ...
                'Parent', allLayout, ...
                'Style', 'popupmenu', ...
                'String', {'', 'above', 'below'}, ...
                'HorizontalAlignment', 'left', ...
                'Callback', @obj.onSelectedLightPath);
            set(obj.lightPathControls.popupMenu, 'Values', get(obj.lightPathControls.popupMenu, 'String'));
            if ischar(commonPath)
                set(obj.lightPathControls.popupMenu, 'Value', commonPath);
                set(obj.lightPathControls.popupMenu, 'Enable', 'on');
            else
                set(obj.lightPathControls.popupMenu, 'Value', '');
                set(obj.lightPathControls.popupMenu, 'Enable', 'off');
            end
            uix.Empty('Parent', allLayout);
            set(allLayout, 'Widths', [60 -1 9]);
            
            set(lightPathLayout, 'Heights', 23);
            
            h = get(obj.mainLayout, 'Heights');
            set(obj.mainLayout, 'Heights', [h(1) h(2) 25+11+layoutHeight(lightPathLayout)+11]);
        end
        
        function updateLightPathBox(obj)
            commonPath = [];
            for i = 1:numel(obj.leds)
                led = obj.leds{i};
                
                desc = led.getConfigurationSettingDescriptors().findByName('lightPath');
                if isempty(desc)
                    commonPath = [];
                    break;
                end
                
                if ~ischar(commonPath)
                    commonPath = desc.value;
                end
                
                if ~strcmp(desc.value, commonPath)
                    commonPath = [];
                    break;
                end
            end
            
            if ischar(commonPath)
                set(obj.lightPathControls.popupMenu, 'Value', commonPath);
                set(obj.lightPathControls.popupMenu, 'Enable', 'on');
            else
                set(obj.lightPathControls.popupMenu, 'Value', '');
                set(obj.lightPathControls.popupMenu, 'Enable', 'off');
            end
        end
        
        function onSelectedLightPath(obj, ~, ~)
            path = get(obj.lightPathControls.popupMenu, 'Value');           
            for i = 1:numel(obj.leds)
                try
                    obj.leds{i}.setConfigurationSetting('lightPath', path);
                catch x
                    obj.view.showError(x.message);
                    obj.updateLightPathBox();
                    return;
                end
            end
        end
        
        function pack(obj)
            f = obj.view.getFigureHandle();
            p = get(f, 'Position');
            set(f, 'Position', [p(1) p(2) p(3) appbox.layoutHeight(obj.mainLayout)]);
        end
        
        function onDeviceSetConfigurationSetting(obj, ~, event)
            setting = event.data;
            switch setting.name
                case 'ndfs'
                    obj.updateNdfsBox();
                case 'gain'
                    obj.updateGainBox();
                case 'lightPath'
                    obj.updateLightPathBox();
            end
        end
        
        function onServiceInitializedRig(obj, ~, ~)
            obj.unbindDevices();
            
            obj.leds = obj.configurationService.getDevices('LED');
            stages = obj.configurationService.getDevices('Stage');
            if isempty(stages)
                obj.stage = [];
            else
                obj.stage = stages{1};
            end
            
            obj.populateNdfsBox();
            obj.populateGainBox();
            obj.populateLightPathBox();
            
            obj.pack();
            
            obj.bindDevices();
        end
        
    end
    
end

function c = colorFromLedName(name)
    split = strsplit(name);
    c = split{1};
    if strcmpi(c, 'uv')
        c = '#EE82EE'; % violet
    end
end
