classdef OldSliceWithLightCrafter < edu.washington.riekelab.rigs.OldSlice
    
    methods
        
        function obj = OldSliceWithLightCrafter()
            import symphonyui.builtin.devices.*;
            import edu.washington.*;
            
            daq = obj.daqController;
            
            lightCrafter = riekelab.devices.LightCrafterDevice('micronsPerPixel', 1.6);
            lightCrafter.bindStream(daq.getStream('DIGITAL_OUT.1'));
            daq.getStream('DIGITAL_OUT.1').setBitPosition(lightCrafter, 15);
            obj.addDevice(lightCrafter);
            
            frameMonitor = UnitConvertingDevice('Frame Monitor', 'V').bindStream(daq.getStream('ANALOG_IN.7'));
            obj.addDevice(frameMonitor);
        end
        
    end
    
end

