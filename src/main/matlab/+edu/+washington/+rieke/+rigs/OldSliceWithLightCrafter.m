classdef OldSliceWithLightCrafter < edu.washington.rieke.rigs.OldSlice
    
    methods
        
        function obj = OldSliceWithLightCrafter()
            lightCrafter = edu.washington.rieke.devices.LightCrafterDevice();
            lightCrafter.addConfigurationSetting('micronsPerPixel', 1.6, 'isReadOnly', true);
            obj.addDevice(lightCrafter);
        end
        
    end
    
end

