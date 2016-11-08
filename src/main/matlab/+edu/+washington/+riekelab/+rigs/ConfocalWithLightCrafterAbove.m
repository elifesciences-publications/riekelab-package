classdef ConfocalWithLightCrafterAbove < edu.washington.riekelab.rigs.Confocal
    
    methods
        
        function obj = ConfocalWithLightCrafterAbove()
            import symphonyui.builtin.devices.*;
            import symphonyui.core.*;
            import edu.washington.*;
            
            daq = obj.daqController;
            
            lightCrafter = riekelab.devices.LightCrafterDevice('micronsPerPixel', 1.3);
            lightCrafter.bindStream(daq.getStream('doport1'));
            daq.getStream('doport1').setBitPosition(lightCrafter, 15);
            lightCrafter.addConfigurationSetting('ndfs', {}, ...
                'type', PropertyType('cellstr', 'row', {'EL1', 'EL2', 'EL3'}));
            lightCrafter.addResource('fluxFactorPaths', containers.Map( ...
                {'auto', 'red', 'green', 'blue'}, { ...
                riekelab.Package.getCalibrationResource('rigs', 'confocal', 'lightcrafter_above_auto_flux_factors.txt'), ...
                riekelab.Package.getCalibrationResource('rigs', 'confocal', 'lightcrafter_above_red_flux_factors.txt'), ...
                riekelab.Package.getCalibrationResource('rigs', 'confocal', 'lightcrafter_above_green_flux_factors.txt'), ...
                riekelab.Package.getCalibrationResource('rigs', 'confocal', 'lightcrafter_above_blue_flux_factors.txt')}));
            lightCrafter.addConfigurationSetting('lightPath', 'above', 'isReadOnly', true);
            obj.addDevice(lightCrafter);
            
            frameMonitor = UnitConvertingDevice('Frame Monitor', 'V').bindStream(daq.getStream('ai7'));
            obj.addDevice(frameMonitor);
        end
        
    end
    
end

