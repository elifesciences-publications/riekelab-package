classdef MicrodisplayDevice < io.github.stage_vss.devices.StageDevice
    
    properties (Access = private)
        microdisplay
    end
    
    methods
        
        function obj = MicrodisplayDevice(gammaRamps)
            host = 'localhost';
            port = 5678;
            obj@io.github.stage_vss.devices.StageDevice(host, port, 'name', ['Microdisplay.Stage@' host]);
            
            obj.microdisplay = Microdisplay();
            obj.microdisplay.connect();
            
            obj.addConfigurationSetting('microdisplayBrightness', '', 'isReadOnly', true);
            obj.addConfigurationSetting('microdisplayBrightnessValue', 0, 'isReadOnly', true);
            obj.addResource('gammaRamps', gammaRamps);
            
            obj.setBrightness(edu.washington.rieke.devices.MicrodisplayBrightness.MINIMUM);
        end
        
        function close(obj)
            close@io.github.stage_vss.devices.StageDevice(obj);
            
            obj.microdisplay.disconnect();
        end
        
        function r = gammaRampForBrightness(obj, brightness)
            gammaRamps = obj.getResource('gammaRamps');
            if strcmp(gammaRamps.KeyType, 'char') 
                key = char(brightness);
            else
                key = brightness;
            end
            r = gammaRamps(key);
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

