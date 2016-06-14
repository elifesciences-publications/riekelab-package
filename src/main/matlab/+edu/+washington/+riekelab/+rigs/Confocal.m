classdef Confocal < symphonyui.core.descriptions.RigDescription
    
    methods
        
        function obj = Confocal()
            import symphonyui.builtin.daqs.*;
            import symphonyui.builtin.devices.*;
            import symphonyui.core.*;
            import edu.washington.*;
            
            daq = HekaDaqController();
            obj.daqController = daq;
            
            amp1 = MultiClampDevice('Amp1', 1).bindStream(daq.getStream('ANALOG_OUT.0')).bindStream(daq.getStream('ANALOG_IN.0'));
            obj.addDevice(amp1);
            
            red = UnitConvertingDevice('Red LED', 'V').bindStream(daq.getStream('ANALOG_OUT.1'));
            red.addConfigurationSetting('ndfs', {}, ...
                'type', PropertyType('cellstr', 'row', {'E1', 'E2', 'E3', 'E4', 'E5', 'E10', 'E11'}));
            red.addResource('ndfAttenuations', containers.Map( ...
                {'E1', 'E2', 'E3', 'E4', 'E5', 'E10', 'E11'}, ...
                {0.24, 0.63, 0.94, 2.02, 3.43, 1.86, 3.73}));
            red.addConfigurationSetting('gain', '', ...
                'type', PropertyType('char', 'row', {'', 'low', 'medium', 'high'}));
            red.addResource('spectrum', importdata(riekelab.Package.getResource('calibration', 'confocal', 'red_led_spectrum.txt')));
            obj.addDevice(red);
            
            uv = UnitConvertingDevice('UV LED', 'V').bindStream(daq.getStream('ANALOG_OUT.2'));
            uv.addConfigurationSetting('ndfs', {}, ...
                'type', PropertyType('cellstr', 'row', {'E1', 'E2', 'E3', 'E4', 'E5', 'E6', 'E7'}));
            uv.addResource('ndfAttenuations', containers.Map( ...
                {'E1', 'E2', 'E3', 'E4', 'E5', 'E6', 'E7'}, ...
                {0.26, 0.52, 0.89, 2.30, 4.20, 1.88, 3.92}));
            uv.addConfigurationSetting('gain', '', ...
                'type', PropertyType('char', 'row', {'', 'low', 'medium', 'high'}));
            uv.addResource('spectrum', importdata(riekelab.Package.getResource('calibration', 'confocal', 'uv_led_spectrum.txt')));
            obj.addDevice(uv);
            
            blue = UnitConvertingDevice('Blue LED', 'V').bindStream(daq.getStream('ANALOG_OUT.3'));
            blue.addConfigurationSetting('ndfs', {}, ...
                'type', PropertyType('cellstr', 'row', {'E1', 'E2', 'E3', 'E4', 'E5', 'E8', 'E9'}));
            blue.addResource('ndfAttenuations', containers.Map( ...
                {'E1', 'E2', 'E3', 'E4', 'E5', 'E8', 'E9'}, ...
                {0.26, 0.55, 0.93, 2.25, 4.17, 1.88, 3.99}));
            blue.addConfigurationSetting('gain', '', ...
                'type', PropertyType('char', 'row', {'', 'low', 'medium', 'high'}));
            blue.addResource('spectrum', importdata(riekelab.Package.getResource('calibration', 'confocal', 'blue_led_spectrum.txt')));
            obj.addDevice(blue);
            
            temperature = UnitConvertingDevice('Temperature Controller', 'V', 'manufacturer', 'Warner Instruments').bindStream(daq.getStream('ANALOG_IN.6'));
            obj.addDevice(temperature);
            
            trigger = UnitConvertingDevice('Oscilloscope Trigger', Measurement.UNITLESS).bindStream(daq.getStream('DIGITAL_OUT.1'));
            daq.getStream('DIGITAL_OUT.1').setBitPosition(trigger, 0);
            obj.addDevice(trigger);        
        end
        
    end
    
end