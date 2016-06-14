classdef OldSlice < symphonyui.core.descriptions.RigDescription
    
    methods
        
        function obj = OldSlice()
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
                'type', PropertyType('cellstr', 'row', {'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7'}));
            red.addResource('ndfAttenuations', containers.Map( ...
                {'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7'}, ...
                {0.3081, 0.2842, 0.6371, 1.0571, 1.8768, 1.9440, 3.7520}));
            red.addConfigurationSetting('gain', '', ...
                'type', PropertyType('char', 'row', {'', 'low', 'medium', 'high'}));
            red.addResource('spectrum', importdata(riekelab.Package.getResource('calibration', 'old_slice', 'red_led_spectrum.txt')));            
            obj.addDevice(red);
            
            green = UnitConvertingDevice('Green LED', 'V').bindStream(daq.getStream('ANALOG_OUT.2'));
            green.addConfigurationSetting('ndfs', {}, ...
                'type', PropertyType('cellstr', 'row', {'F1', 'F2', 'F3', 'F4', 'F5', 'F8', 'F9'}));
            green.addResource('ndfAttenuations', containers.Map( ...
                {'F1', 'F2', 'F3', 'F4', 'F5', 'F8', 'F9'}, ...
                {0.3059, 0.2862, 0.5869, 1.0955, 1.9804, 1.8555, 3.6936}));
            green.addConfigurationSetting('gain', '', ...
                'type', PropertyType('char', 'row', {'', 'low', 'medium', 'high'}));
            green.addResource('spectrum', importdata(riekelab.Package.getResource('calibration', 'old_slice', 'green_led_spectrum.txt')));                       
            obj.addDevice(green);
            
            uv = UnitConvertingDevice('UV LED', 'V').bindStream(daq.getStream('ANALOG_OUT.3'));
            uv.addConfigurationSetting('ndfs', {}, ...
                'type', PropertyType('cellstr', 'row', {'F1', 'F2', 'F3', 'F4', 'F5', 'F10', 'F11'}));
            uv.addResource('ndfAttenuations', containers.Map( ...
                {'F1', 'F2', 'F3', 'F4', 'F5', 'F10', 'F11'}, ...
                {0.3011, 0.2828, 0.5367, 1.1270, 2.0587, 1.7208, 3.7415}));
            uv.addConfigurationSetting('gain', '', ...
                'type', PropertyType('char', 'row', {'', 'medium', 'high'}));
            uv.addResource('spectrum', importdata(riekelab.Package.getResource('calibration', 'old_slice', 'uv_led_spectrum.txt')));          
            obj.addDevice(uv);
            
            temperature = UnitConvertingDevice('Temperature Controller', 'V', 'manufacturer', 'Warner Instruments').bindStream(daq.getStream('ANALOG_IN.6'));
            obj.addDevice(temperature);
            
            trigger = UnitConvertingDevice('Oscilloscope Trigger', Measurement.UNITLESS).bindStream(daq.getStream('DIGITAL_OUT.1'));
            daq.getStream('DIGITAL_OUT.1').setBitPosition(trigger, 0);
            obj.addDevice(trigger);        
        end
        
    end
    
end