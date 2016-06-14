classdef SharedTwoPhoton < symphonyui.core.descriptions.RigDescription
    
    methods
        
        function obj = SharedTwoPhoton()
            import symphonyui.builtin.daqs.*;
            import symphonyui.builtin.devices.*;
            import symphonyui.core.*;
            import edu.washington.*;
            
            daq = HekaDaqController();
            obj.daqController = daq;
            
            amp1 = MultiClampDevice('Amp1', 1).bindStream(daq.getStream('ANALOG_OUT.0')).bindStream(daq.getStream('ANALOG_IN.0'));
            obj.addDevice(amp1);
            
            redRamp = importdata(riekelab.Package.getResource('calibration', 'shared_two_photon', 'red_led_gamma_ramp.txt'));
            red = CalibratedDevice('Red LED', Measurement.NORMALIZED, redRamp(:, 1), redRamp(:, 2)).bindStream(daq.getStream('ANALOG_OUT.1'));
            red.addConfigurationSetting('ndfs', {}, ...
                'type', PropertyType('cellstr', 'row', {'G1', 'G2', 'G3', 'G4', 'G5'}));
            red.addResource('ndfAttenuations', containers.Map( ...
                {'G1', 'G2', 'G3', 'G4', 'G5'}, ...
                {0.9884, 0.9910, 1.9023, 2.0200, 3.9784}));
            red.addResource('spectrum', importdata(riekelab.Package.getResource('calibration', 'shared_two_photon', 'red_led_spectrum.txt')));            
            obj.addDevice(red);
            
            uvRamp = importdata(riekelab.Package.getResource('calibration', 'shared_two_photon', 'uv_led_gamma_ramp.txt'));
            uv = CalibratedDevice('UV LED', Measurement.NORMALIZED, uvRamp(:, 1), uvRamp(:, 2)).bindStream(daq.getStream('ANALOG_OUT.2'));
            uv.addConfigurationSetting('ndfs', {}, ...
                'type', PropertyType('cellstr', 'row', {'G1', 'G2', 'G3', 'G4'}));
            uv.addResource('ndfAttenuations', containers.Map( ...
                {'G1', 'G2', 'G3', 'G4'}, ...
                {1.0060, 1.0524, 2.1342, 2.6278}));
            uv.addResource('spectrum', importdata(riekelab.Package.getResource('calibration', 'shared_two_photon', 'uv_led_spectrum.txt')));          
            obj.addDevice(uv);
            
            blueRamp = importdata(riekelab.Package.getResource('calibration', 'shared_two_photon', 'blue_led_gamma_ramp.txt'));
            blue = CalibratedDevice('Blue LED', Measurement.NORMALIZED, blueRamp(:, 1), blueRamp(:, 2)).bindStream(daq.getStream('ANALOG_OUT.3'));
            blue.addConfigurationSetting('ndfs', {}, ...
                'type', PropertyType('cellstr', 'row', {'G1', 'G2', 'G3', 'G4', 'G5'}));
            blue.addResource('ndfAttenuations', containers.Map( ...
                {'G1', 'G2', 'G3', 'G4', 'G5'}, ...
                {1.0171, 1.0428, 2.0749, 2.1623, 4.2439}));
            blue.addResource('spectrum', importdata(riekelab.Package.getResource('calibration', 'shared_two_photon', 'blue_led_spectrum.txt')));                       
            obj.addDevice(blue);
            
            temperature = UnitConvertingDevice('Temperature Controller', 'V', 'manufacturer', 'Warner Instruments').bindStream(daq.getStream('ANALOG_IN.6'));
            obj.addDevice(temperature);
            
            trigger = UnitConvertingDevice('Oscilloscope Trigger', Measurement.UNITLESS).bindStream(daq.getStream('DIGITAL_OUT.1'));
            daq.getStream('DIGITAL_OUT.1').setBitPosition(trigger, 0);
            obj.addDevice(trigger);
        end
        
    end
    
end