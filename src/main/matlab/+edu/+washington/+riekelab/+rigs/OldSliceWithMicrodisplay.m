classdef OldSliceWithMicrodisplay < edu.washington.riekelab.rigs.OldSlice
    
    methods
        
        function obj = OldSliceWithMicrodisplay()
            import symphonyui.builtin.devices.*;
            import edu.washington.*;
            
            daq = obj.daqController;
            
            ramps = containers.Map();
            ramps('minimum') = linspace(0, 65535, 256);
            ramps('low')     = 65535 * importdata(riekelab.Package.getResource('calibration', 'old_slice', 'microdisplay_low_gamma_ramp.txt'));
            ramps('medium')  = 65535 * importdata(riekelab.Package.getResource('calibration', 'old_slice', 'microdisplay_medium_gamma_ramp.txt'));
            ramps('high')    = 65535 * importdata(riekelab.Package.getResource('calibration', 'old_slice', 'microdisplay_high_gamma_ramp.txt'));
            ramps('maximum') = linspace(0, 65535, 256);
            microdisplay = riekelab.devices.MicrodisplayDevice('gammaRamps', ramps, 'micronsPerPixel', 1.2, 'comPort', 'COM3');
            microdisplay.bindStream(daq.getStream('DIGITAL_OUT.1'));
            daq.getStream('DIGITAL_OUT.1').setBitPosition(microdisplay, 15);
            obj.addDevice(microdisplay);
            
            frameMonitor = UnitConvertingDevice('Frame Monitor', 'V').bindStream(daq.getStream('ANALOG_IN.7'));
            obj.addDevice(frameMonitor);
        end
        
    end
    
end

