classdef OldSlice < edu.washington.rieke.rigs.RiekeRigDescription
    
    methods
        
        function obj = OldSlice()
            import symphonyui.builtin.daqs.*;
            import symphonyui.builtin.devices.*;
            
            daq = HekaSimulationDaqController();
            
            amp = MultiClampDevice('Amp', 1).bindStream(daq.getStream('ANALOG_OUT.0')).bindStream(daq.getStream('ANALOG_IN.0'));
            
            red = UnitConvertingDevice('Red LED', 'V').bindStream(daq.getStream('ANALOG_OUT.1'));
            addCalibrationDataToDevice(red, [calibrationDataPath filesep 'rigs\oldSlice\redLED']);
           
            green = UnitConvertingDevice('Green LED', 'V').bindStream(daq.getStream('ANALOG_OUT.2'));
            addCalibrationDataToDevice(green, [calibrationDataPath filesep 'rigs\oldSlice\greenLED']);
            
            uv = UnitConvertingDevice('UV LED', 'V').bindStream(daq.getStream('ANALOG_OUT.3'));
            addCalibrationDataToDevice(uv, [calibrationDataPath filesep 'rigs\oldSlice\uvLED']);
           
            trigger1 = UnitConvertingDevice('Trigger1', symphonyui.core.Measurement.UNITLESS).bindStream(daq.getStream('DIGITAL_OUT.1'));
            daq.getStream('DIGITAL_OUT.1').setBitPosition(trigger1, 0);
            
            trigger2 = UnitConvertingDevice('Trigger2', symphonyui.core.Measurement.UNITLESS).bindStream(daq.getStream('DIGITAL_OUT.1'));
            daq.getStream('DIGITAL_OUT.1').setBitPosition(trigger2, 2);
            
            obj.daqController = daq;
            obj.devices = {amp, red, green, uv, trigger1, trigger2};
           
            % call superclass method to save rig info file
            obj.saveRigInfoFile();
        end
        
    end
    
end

