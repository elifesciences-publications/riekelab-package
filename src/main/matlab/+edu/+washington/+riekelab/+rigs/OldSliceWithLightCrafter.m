classdef OldSliceWithLightCrafter < edu.washington.riekelab.rigs.OldSlice
    
    methods
        
        function obj = OldSliceWithLightCrafter()
            lightCrafter = edu.washington.riekelab.devices.LightCrafterDevice();
            lightCrafter.addConfigurationSetting('micronsPerPixel', 1.6, 'isReadOnly', true);
            
            % Binding the lightCrafter to an unused stream only so its configuration settings are written to each epoch.
            daq = obj.daqController;
            lightCrafter.bindStream(daq.getStream('DIGITAL_OUT.1'));
            daq.getStream('DIGITAL_OUT.1').setBitPosition(lightCrafter, 15);
            
            obj.addDevice(lightCrafter);
        end
        
    end
    
end

