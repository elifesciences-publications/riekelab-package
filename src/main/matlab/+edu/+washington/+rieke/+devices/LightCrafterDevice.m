classdef LightCrafterDevice < io.github.stage_vss.devices.StageDevice
    
    properties (Access = private)
        lightCrafter
        patternRatesToAttributes
    end
    
    methods
        
        function obj = LightCrafterDevice()
            host = 'localhost';
            port = 5678;
            obj@io.github.stage_vss.devices.StageDevice(host, port, 'name', ['LightCrafter.Stage@' host]);
            
            refreshRate = obj.stageClient.getMonitorRefreshRate();
            
            obj.lightCrafter = LightCrafter4500(refreshRate);
            obj.lightCrafter.connect();
            obj.lightCrafter.setMode('pattern');
            
            m = containers.Map('KeyType', 'double', 'ValueType', 'any');
            m(1 * refreshRate)  = {8, 'white', 1};
            m(2 * refreshRate)  = {8, 'white', 2};
            m(4 * refreshRate)  = {6, 'white', 4};
            m(6 * refreshRate)  = {4, 'white', 6};
            m(8 * refreshRate)  = {3, 'white', 8};
            m(12 * refreshRate) = {2, 'white', 12};
            m(24 * refreshRate) = {1, 'white', 24};
            obj.patternRatesToAttributes = m;
            
            obj.addConfigurationSetting('lightCrafterLedEnables', true(1, 4), 'isReadOnly', true);
            obj.addConfigurationSetting('lightCrafterPatternRate', 0, 'isReadOnly', true);
            
            obj.setLedEnables(true, true, true, true);
            obj.setPatternRate(refreshRate);
        end
        
        function close(obj)
            close@io.github.stage_vss.devices.StageDevice(obj);
            
            obj.lightCrafter.disconnect();
        end
        
        function setLedEnables(obj, auto, red, green, blue)
            obj.lightCrafter.setLedEnables(auto, red, green, blue);
            [a, r, g, b] = obj.lightCrafter.getLedEnables();
            obj.setReadOnlyConfigurationSetting('lightCrafterLedEnables', [a, r, g, b]);
        end
        
        function [auto, red, green, blue] = getLedEnables(obj)
            [auto, red, green, blue] = obj.lightCrafter.getLedEnables();
        end
        
        function r = availablePatternRates(obj)
            r = obj.patternRatesToAttributes.keys;
        end
        
        function setPatternRate(obj, rate)
            if ~obj.patternRatesToAttributes.isKey(rate)
                error([num2str(rate) ' is not an available pattern rate']);
            end
            attributes = obj.patternRatesToAttributes(rate);
            obj.lightCrafter.setPatternAttributes(attributes{:});
            obj.setReadOnlyConfigurationSetting('lightCrafterPatternRate', obj.lightCrafter.currentPatternRate());
        end
        
        function r = getPatternRate(obj)
            r = obj.lightCrafter.currentPatternRate();
        end
        
    end
    
end

