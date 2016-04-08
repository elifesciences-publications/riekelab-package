classdef OldSliceWithLightCrafter < edu.washington.riekelab.rigs.OldSlice
    
    methods
        
        function obj = OldSliceWithLightCrafter()
            lightCrafter = edu.washington.riekelab.devices.LightCrafterDevice();
            lightCrafter.addConfigurationSetting('micronsPerPixel', 1.6, 'isReadOnly', true);
            obj.addDevice(lightCrafter);
        end
        
    end
    
end

