classdef TwoPhotonWithMicrodisplayBelow < edu.washington.riekelab.rigs.TwoPhoton
    
    methods
        
        function obj = TwoPhotonWithMicrodisplayBelow()
            import symphonyui.builtin.devices.*;
            import symphonyui.core.*;
            import edu.washington.*;
            
            daq = obj.daqController;
            
            ramps = containers.Map();
            ramps('minimum') = linspace(0, 65535, 256);
            ramps('low')     = 65535 * importdata(riekelab.Package.getCalibrationResource('rigs', 'two_photon', 'microdisplay_below_low_gamma_ramp.txt'));
            ramps('medium')  = 65535 * importdata(riekelab.Package.getCalibrationResource('rigs', 'two_photon', 'microdisplay_below_medium_gamma_ramp.txt'));
            ramps('high')    = 65535 * importdata(riekelab.Package.getCalibrationResource('rigs', 'two_photon', 'microdisplay_below_high_gamma_ramp.txt'));
            ramps('maximum') = linspace(0, 65535, 256);
            microdisplay = riekelab.devices.MicrodisplayDevice('gammaRamps', ramps, 'micronsPerPixel', 1.8, 'comPort', 'COM3');
            microdisplay.bindStream(daq.getStream('doport1'));
            daq.getStream('doport1').setBitPosition(microdisplay, 15);
            microdisplay.addConfigurationSetting('ndfs', {}, ...
                'type', PropertyType('cellstr', 'row', {'B1', 'B2', 'B3', 'B4', 'B5'}));
            microdisplay.addResource('fluxFactorPaths', containers.Map( ...
                {'low', 'medium', 'high'}, { ...
                riekelab.Package.getCalibrationResource('rigs', 'two_photon', 'microdisplay_below_low_flux_factors.txt'), ...
                riekelab.Package.getCalibrationResource('rigs', 'two_photon', 'microdisplay_below_medium_flux_factors.txt'), ...
                riekelab.Package.getCalibrationResource('rigs', 'two_photon', 'microdisplay_below_high_flux_factors.txt')}));
            microdisplay.addConfigurationSetting('lightPath', 'below', 'isReadOnly', true);
            obj.addDevice(microdisplay);
            
            frameMonitor = UnitConvertingDevice('Frame Monitor', 'V').bindStream(daq.getStream('ai7'));
            obj.addDevice(frameMonitor);
        end
        
    end
    
end

