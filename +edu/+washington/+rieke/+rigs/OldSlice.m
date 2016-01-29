classdef OldSlice < symphonyui.core.descriptions.RigDescription
    
    methods
        
        function obj = OldSlice()
            import symphonyui.builtin.daqs.*;
            import symphonyui.builtin.devices.*;
            import symphonyui.core.*;
            
            daq = HekaDaqController();
            
            amp = MultiClampDevice('Amp1', 1).bindStream(daq.getStream('ANALOG_OUT.0')).bindStream(daq.getStream('ANALOG_IN.0'));
            
            red = UnitConvertingDevice('Red LED', 'V').bindStream(daq.getStream('ANALOG_OUT.1'));
            red.addStaticConfigurationDescriptor(PropertyDescriptor('ndfs', {}, ...
                'type', PropertyType('cellstr', 'row', {'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7'})));
            red.addStaticConfigurationDescriptor(PropertyDescriptor('gain', '', ...
                'type', PropertyType('char', 'row', {'', 'low', 'medium', 'high'})));
            red.addStaticConfigurationDescriptor(PropertyDescriptor('powerToIntensity', 0));
            
            green = UnitConvertingDevice('Green LED', 'V').bindStream(daq.getStream('ANALOG_OUT.2'));
            green.addStaticConfigurationDescriptor(PropertyDescriptor('ndfs', {}, ...
                'type', PropertyType('cellstr', 'row', {'F1', 'F2', 'F3', 'F4', 'F5', 'F8', 'F9'})));
            green.addStaticConfigurationDescriptor(PropertyDescriptor('gain', '', ...
                'type', PropertyType('char', 'row', {'', 'low', 'medium', 'high'})));
            
            uv = UnitConvertingDevice('UV LED', 'V').bindStream(daq.getStream('ANALOG_OUT.3'));
            uv.addStaticConfigurationDescriptor(PropertyDescriptor('ndfs', {}, ...
                'type', PropertyType('cellstr', 'row', {'F1', 'F2', 'F3', 'F4', 'F5', 'F10', 'F11'})));
            uv.addStaticConfigurationDescriptor(PropertyDescriptor('gain', '', ...
                'type', PropertyType('char', 'row', {'', 'low', 'medium'})));
            
            obj.daqController = daq;
            obj.devices = {amp, red, green, uv};
        end
        
    end
    
end

