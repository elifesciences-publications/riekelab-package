classdef MicrodisplayDevice < symphonyui.core.Device
    
    properties (Access = private, Transient)
        stageClient
        microdisplay
    end
    
    methods
        
        function obj = MicrodisplayDevice(varargin)
            ip = inputParser();
            ip.addParameter('host', 'localhost', @ischar);
            ip.addParameter('port', 5678, @isnumeric);
            ip.addParameter('comPort', 'COM4', @ischar);
            ip.addParameter('gammaRamps', containers.Map( ...
                {'minimum', 'low', 'medium', 'high', 'maximum'}, ...
                {linspace(0, 65535, 256), linspace(0, 65535, 256), linspace(0, 65535, 256), linspace(0, 65535, 256), linspace(0, 65535, 256)}), ...
                @(r)isa(r, 'containers.Map'));
            ip.addParameter('micronsPerPixel', 1, @isnumeric);
            ip.parse(varargin{:});
            
            cobj = Symphony.Core.UnitConvertingExternalDevice(['Microdisplay Stage@' ip.Results.host], 'eMagin', Symphony.Core.Measurement(0, symphonyui.core.Measurement.UNITLESS));
            obj@symphonyui.core.Device(cobj);
            obj.cobj.MeasurementConversionTarget = symphonyui.core.Measurement.UNITLESS;
            
            brightness = edu.washington.riekelab.devices.MicrodisplayBrightness.MINIMUM;
            ramp = ip.Results.gammaRamps(char(brightness));
            
            obj.stageClient = stage.core.network.StageClient();
            obj.stageClient.connect(ip.Results.host, ip.Results.port);
            obj.stageClient.setMonitorGammaRamp(ramp, ramp, ramp);
            
            obj.microdisplay = Microdisplay(ip.Results.comPort);
            obj.microdisplay.connect();
            obj.microdisplay.setBrightness(uint8(brightness));
            
            trueCanvasSize = obj.stageClient.getCanvasSize();
            canvasSize = [trueCanvasSize(1) * 0.5, trueCanvasSize(2)];
            
            obj.addConfigurationSetting('canvasSize', canvasSize, 'isReadOnly', true);
            obj.addConfigurationSetting('trueCanvasSize', trueCanvasSize, 'isReadOnly', true);
            obj.addConfigurationSetting('monitorRefreshRate', obj.stageClient.getMonitorRefreshRate(), 'isReadOnly', true);
            obj.addConfigurationSetting('prerender', false, 'isReadOnly', true);
            obj.addConfigurationSetting('microdisplayBrightness', char(brightness), 'isReadOnly', true);
            obj.addConfigurationSetting('microdisplayBrightnessValue', uint8(brightness), 'isReadOnly', true);
            obj.addConfigurationSetting('micronsPerPixel', ip.Results.micronsPerPixel, 'isReadOnly', true);
            obj.addResource('gammaRamps', ip.Results.gammaRamps);
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
        
        function setPrerender(obj, tf)
            obj.setReadOnlyConfigurationSetting('prerender', logical(tf));
        end
        
        function tf = getPrerender(obj)
            tf = obj.getConfigurationSetting('prerender');
        end
        
        function play(obj, presentation)
            canvasSize = obj.getCanvasSize();
            
            background = stage.builtin.stimuli.Rectangle();
            background.size = canvasSize;
            background.position = canvasSize/2;
            background.color = presentation.backgroundColor;
            presentation.setBackgroundColor(0);
            presentation.insertStimulus(1, background);
            
            tracker = stage.builtin.stimuli.FrameTracker();
            tracker.size = canvasSize;
            tracker.position = [canvasSize(1) + (canvasSize(1)/2), canvasSize(2)/2];
            presentation.addStimulus(tracker);
            
            trackerColor = stage.builtin.controllers.PropertyController(tracker, 'color', @(s)double(s.time + (1/s.frameRate) < presentation.duration));
            presentation.addController(trackerColor);
            
            if obj.getPrerender()
                player = stage.builtin.players.PrerenderedPlayer(presentation);
            else
                player = stage.builtin.players.RealtimePlayer(presentation);
            end
            obj.stageClient.play(player);
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
            brightness = edu.washington.riekelab.devices.MicrodisplayBrightness(brightness);
            
            obj.microdisplay.setBrightness(uint8(brightness));
            obj.setReadOnlyConfigurationSetting('microdisplayBrightness', char(brightness));
            obj.setReadOnlyConfigurationSetting('microdisplayBrightnessValue', uint8(brightness));
            
            ramp = obj.gammaRampForBrightness(brightness);
            obj.stageClient.setMonitorGammaRamp(ramp, ramp, ramp);
        end
        
        function b = getBrightness(obj)
            value = obj.microdisplay.getBrightness();
            b = edu.washington.riekelab.devices.MicrodisplayBrightness(value);
        end
        
        function p = um2pix(obj, um)
            micronsPerPixel = obj.getConfigurationSetting('micronsPerPixel');
            p = round(um / micronsPerPixel);
        end
        
    end
    
end

