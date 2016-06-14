classdef OldSliceTwoAmp < edu.washington.riekelab.rigs.OldSlice
    
    methods
        
        function obj = OldSliceTwoAmp()
            import symphonyui.builtin.devices.*;
            import symphonyui.core.*;
            
            daq = obj.daqController;
            
            % Remove any device bound to the analog input 1 channel
            for i = 1:numel(obj.devices)
                dev = obj.devices{i};
                s = dev.outputStreams;
                if ~isempty(s) && strcmp(s{1}.name, 'ANALOG_OUT.1')
                    dev.unbindStream('ANALOG_OUT.1');
                    obj.removeDevice(dev);
                    break;
                end
            end
            
            amp2 = MultiClampDevice('Amp2', 2).bindStream(daq.getStream('ANALOG_OUT.1')).bindStream(daq.getStream('ANALOG_IN.3'));
            obj.addDevice(amp2);
        end
        
    end
    
end

