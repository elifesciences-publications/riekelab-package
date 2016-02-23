classdef MicrodisplayDevice < io.github.stage_vss.devices.StageDevice
    
    properties (Access = private)
        microdisplay
    end
    
    methods
        
        function obj = MicrodisplayDevice(gammaRamps)
            obj@io.github.stage_vss.devices.StageDevice();
            obj.cobj.Name = ['Microdisplay.' obj.name];
            
            obj.microdisplay = Microdisplay();
            obj.microdisplay.connect();
            
            obj.addConfigurationSetting('brightness', '', 'isReadOnly', true);
            obj.addConfigurationSetting('brightnessValue', 0, 'isReadOnly', true);
            obj.addResource('gammaRamps', gammaRamps);
            
            obj.setBrightness(edu.washington.rieke.devices.MicrodisplayBrightness.MINIMUM);
        end
        
        function close(obj)
            close@io.github.stage_vss.devices.StageDevice(obj);
            
            obj.microdisplay.disconnect();
        end
        
        function r = gammaRampForBrightness(obj, b)
            gammaRamps = obj.getResource('gammaRamps');
            if strcmp(gammaRamps.KeyType, 'char') 
                key = char(b);
            else
                key = b;
            end
            r = gammaRamps(key);
        end
        
        function setBrightness(obj, b)
            b = edu.washington.rieke.devices.MicrodisplayBrightness(b);
            
            obj.microdisplay.setBrightness(uint8(b));
            obj.setReadOnlyConfigurationSetting('brightness', char(b));
            obj.setReadOnlyConfigurationSetting('brightnessValue', uint8(b));
            
            ramp = obj.gammaRampForBrightness(b);
            obj.stageClient.setMonitorGammaRamp(ramp, ramp, ramp);
        end
        
        function b = getBrightness(obj)
            value = obj.microdisplay.getBrightness();
            b = edu.washington.rieke.devices.MicrodisplayBrightness(value);
        end
        
    end
    
end

