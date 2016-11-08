classdef OldSliceWithLightCrafter < edu.washington.riekelab.rigs.OldSlice
    
    methods
        
        function obj = OldSliceWithLightCrafter()
            import symphonyui.builtin.devices.*;
            import edu.washington.*;
            
            daq = obj.daqController;
            
            lightCrafter = riekelab.devices.LightCrafterDevice('micronsPerPixel', 1.6);
            lightCrafter.bindStream(daq.getStream('doport1'));
            daq.getStream('doport1').setBitPosition(lightCrafter, 15);
            lightCrafter.addResource('fluxFactorPaths', containers.Map( ...
                {'auto', 'red', 'green', 'blue'}, { ...
                riekelab.Package.getCalibrationResource('rigs', 'old_slice', 'lightcrafter_auto_flux_factors.txt'), ...
                riekelab.Package.getCalibrationResource('rigs', 'old_slice', 'lightcrafter_red_flux_factors.txt'), ...
                riekelab.Package.getCalibrationResource('rigs', 'old_slice', 'lightcrafter_green_flux_factors.txt'), ...
                riekelab.Package.getCalibrationResource('rigs', 'old_slice', 'lightcrafter_blue_flux_factors.txt')}));
            obj.addDevice(lightCrafter);
            
            frameMonitor = UnitConvertingDevice('Frame Monitor', 'V').bindStream(daq.getStream('ai7'));
            obj.addDevice(frameMonitor);
        end
        
    end
    
end

