classdef ConfocalWithLightCrafter < edu.washington.riekelab.rigs.Confocal
    
    methods
        
        function obj = ConfocalWithLightCrafter()
            daq = obj.daqController;
            
            lightCrafter = edu.washington.riekelab.devices.LightCrafterDevice('micronsPerPixel', 1.3);
            lightCrafter.bindStream(daq.getStream('DIGITAL_OUT.1'));
            daq.getStream('DIGITAL_OUT.1').setBitPosition(lightCrafter, 15);
            obj.addDevice(lightCrafter);
            
            frameMonitor = UnitConvertingDevice('Frame Monitor', 'V').bindStream(daq.getStream('ANALOG_IN.7'));
            obj.addDevice(frameMonitor);
        end
        
    end
    
end

