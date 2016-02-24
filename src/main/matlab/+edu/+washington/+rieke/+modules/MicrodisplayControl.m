classdef MicrodisplayControl < symphonyui.ui.Module
    
    properties (Access = private)
        microdisplay
        brightnessPopupMenu
    end
    
    methods
        
        function createUi(obj, figureHandle)
            import appbox.*;
            
            set(figureHandle, ...
                'Name', 'Microdisplay Control', ...
                'Position', screenCenter(250, 45));
            
            mainLayout = uix.HBox( ...
                'Parent', figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);
            
            microdisplayLayout = uix.Grid( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            Label( ...
                'Parent', microdisplayLayout, ...
                'String', 'Brightness:');
            obj.brightnessPopupMenu = MappedPopupMenu( ...
                'Parent', microdisplayLayout, ...
                'String', {' '}, ...
                'HorizontalAlignment', 'left', ...
                'Callback', @obj.onSelectedBrightness);
            
            set(microdisplayLayout, ...
                'Widths', [60 -1], ...
                'Heights', [23]);
        end
        
    end
        
    methods (Access = protected)

        function willGo(obj)
            devices = obj.configurationService.getDevices('Microdisplay');
            if isempty(devices)
                set(obj.brightnessPopupMenu, 'Enable', 'off');
                return;
            end
            
            obj.microdisplay = devices{1};
            obj.populateBrightnessList();
        end

    end
    
    methods (Access = private)
        
        function populateBrightnessList(obj)
            import edu.washington.rieke.devices.MicrodisplayBrightness;
            
            names = {'Minimum', 'Low', 'Medium', 'High', 'Maximum'};
            values = {MicrodisplayBrightness.MINIMUM, MicrodisplayBrightness.LOW, MicrodisplayBrightness.MEDIUM, MicrodisplayBrightness.HIGH, MicrodisplayBrightness.MAXIMUM};
            set(obj.brightnessPopupMenu, 'String', names);
            set(obj.brightnessPopupMenu, 'Values', values);
            
            brightness = obj.microdisplay.getBrightness();
            set(obj.brightnessPopupMenu, 'Value', brightness);
        end
        
        function onSelectedBrightness(obj, ~, ~)
            brightness = get(obj.brightnessPopupMenu, 'Value');
            obj.microdisplay.setBrightness(brightness);
        end
        
    end
    
end

