classdef OldSliceOld < edu.washington.rieke.rigs.RiekeRigDescription
    
    methods
        
        function obj = OldSliceOld()
            import symphonyui.builtin.daqs.*;
            import symphonyui.builtin.devices.*;
            import symphonyui.core.*;
            
            daq = HekaSimulationDaqController();
            obj.daqController = daq;
            
            amp1 = MultiClampDevice('Amp', 1).bindStream(daq.getStream('ANALOG_OUT.0')).bindStream(daq.getStream('ANALOG_IN.0'));
            obj.addDevice(amp1);
            
            red = UnitConvertingDevice('Red LED', 'V').bindStream(daq.getStream('ANALOG_OUT.1'));
            addCalibrationDataToDevice(red, [calibrationDataPath filesep 'rigs\oldSlice\redLED']);
            obj.addDevice(red);
            
            green = UnitConvertingDevice('Green LED', 'V').bindStream(daq.getStream('ANALOG_OUT.2'));
            addCalibrationDataToDevice(green, [calibrationDataPath filesep 'rigs\oldSlice\greenLED']);
            obj.addDevice(green);
            
            uv = UnitConvertingDevice('UV LED', 'V').bindStream(daq.getStream('ANALOG_OUT.3'));
            addCalibrationDataToDevice(uv, [calibrationDataPath filesep 'rigs\oldSlice\uvLED']);
            obj.addDevice(uv);
           
            % call superclass method to save rig info file
            obj.saveRigInfoFile();
        end
        
    end
    
end

