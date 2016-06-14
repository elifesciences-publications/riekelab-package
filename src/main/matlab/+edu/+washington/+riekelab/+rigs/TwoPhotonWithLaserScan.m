classdef TwoPhotonWithLaserScan < edu.washington.riekelab.rigs.TwoPhoton
    
    methods
        
        function obj = TwoPhotonWithLaserScan()
            import symphonyui.builtin.devices.*;
            import symphonyui.core.*;
            
            daq = obj.daqController;
            
            scan = UnitConvertingDevice('Scan Trigger', Measurement.UNITLESS).bindStream(daq.getStream('DIGITAL_OUT.1'));
            daq.getStream('DIGITAL_OUT.1').setBitPosition(scan, 1);
            obj.addDevice(scan);   
        end
        
    end
    
end

