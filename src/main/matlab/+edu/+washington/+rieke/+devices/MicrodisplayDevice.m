classdef MicrodisplayDevice < symphonyui.core.Device
    
    properties (Access = private)
        stageClient
        microdisplay
    end
    
    methods
        
        function obj = MicrodisplayDevice(gammaRamps)            
            host = 'localhost';
            port = 5678;
            
            cobj = Symphony.Core.UnitConvertingExternalDevice(['Microdisplay.Stage@' host], 'Unspecified', Symphony.Core.Measurement(0, symphonyui.core.Measurement.UNITLESS));
            obj@symphonyui.core.Device(cobj);
            obj.cobj.MeasurementConversionTarget = symphonyui.core.Measurement.UNITLESS;
            
            brightness = edu.washington.rieke.devices.MicrodisplayBrightness.MINIMUM;
            ramp = gammaRamps(char(brightness));
            
            obj.stageClient = stage.core.network.StageClient();
            obj.stageClient.connect(host, port);
            obj.stageClient.setMonitorGammaRamp(ramp, ramp, ramp);
            
            obj.microdisplay = Microdisplay();
            obj.microdisplay.connect();
            obj.microdisplay.setBrightness(uint8(brightness));
            
            trueCanvasSize = obj.stageClient.getCanvasSize();
            canvasSize = [trueCanvasSize(1) * 0.5, trueCanvasSize(2)];
            
            obj.addConfigurationSetting('canvasSize', canvasSize, 'isReadOnly', true);
            obj.addConfigurationSetting('trueCanvasSize', trueCanvasSize, 'isReadOnly', true);
            obj.addConfigurationSetting('monitorRefreshRate', obj.stageClient.getMonitorRefreshRate(), 'isReadOnly', true);
            obj.addConfigurationSetting('microdisplayBrightness', char(brightness), 'isReadOnly', true);
            obj.addConfigurationSetting('microdisplayBrightnessValue', uint8(brightness), 'isReadOnly', true);
            obj.addResource('gammaRamps', gammaRamps);
        end
        
        function close(obj)
            if ~isempty(obj.stageClient)
                obj.stageClient.disconnect();
            end
            if ~isempty(obj.microdisplay)
                obj.microdisplay.disconnect();
            end
        end
        
        function s = getCanvasSize(obj)
            s = obj.getConfigurationSetting('canvasSize');
        end
        
        function s = getTrueCanvasSize(obj)
            s = obj.getConfigurationSetting('trueCanvasSize');
        end
        
        function r = getMonitorRefreshRate(obj)
            r = obj.getConfigurationSetting('monitorRefreshRate');
        end
        
        function play(obj, presentation, prerender)
            if nargin < 3
                prerender = false;
            end
            
            canvasSize = obj.getCanvasSize();
            
            tracker = stage.builtin.stimuli.FrameTracker();
            tracker.size = canvasSize;
            tracker.position = [canvasSize(1) + (canvasSize(1)/2), canvasSize(2)/2];
            presentation.addStimulus(tracker);
            
            obj.stageClient.play(presentation, prerender);
        end
        
        function replay(obj)
            obj.stageClient.replay();
        end
        
        function i = getPlayInfo(obj)
            i = obj.stageClient.getPlayInfo();
        end
        
        function clearMemory(obj)
           obj.stageClient.clearMemory();
        end
        
        function r = gammaRampForBrightness(obj, brightness)
            gammaRamps = obj.getResource('gammaRamps');
            r = gammaRamps(char(brightness));
        end
        
        function setBrightness(obj, brightness)
            brightness = edu.washington.rieke.devices.MicrodisplayBrightness(brightness);
            
            obj.microdisplay.setBrightness(uint8(brightness));
            obj.setReadOnlyConfigurationSetting('microdisplayBrightness', char(brightness));
            obj.setReadOnlyConfigurationSetting('microdisplayBrightnessValue', uint8(brightness));
            
            ramp = obj.gammaRampForBrightness(brightness);
            obj.stageClient.setMonitorGammaRamp(ramp, ramp, ramp);
        end
        
        function b = getBrightness(obj)
            value = obj.microdisplay.getBrightness();
            b = edu.washington.rieke.devices.MicrodisplayBrightness(value);
        end
        
    end
    
end

