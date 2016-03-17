classdef (Abstract) RiekeStageProtocol < edu.washington.rieke.protocols.RiekeProtocol
    
    methods (Abstract)
        p = createPresentation(obj);
    end
    
    methods
        
        function prepareEpoch(obj, epoch)
            prepareEpoch@edu.washington.rieke.protocols.RiekeProtocol(obj, epoch);
            epoch.shouldWaitForTrigger = true;
            
            frameMonitor = obj.rig.getDevices('Frame Monitor');
            if ~isempty(frameMonitor)
                epoch.addResponse(frameMonitor{1});
            end
        end
        
        function controllerDidStartHardware(obj)
            controllerDidStartHardware@edu.washington.rieke.protocols.RiekeProtocol(obj);
            obj.rig.getDevice('Stage').play(obj.createPresentation());
        end
        
        function tf = shouldContinuePreloadingEpochs(obj) %#ok<MANU>
            tf = false;
        end
        
        function tf = shouldWaitToContinuePreparingEpochs(obj)
            tf = obj.numEpochsPrepared > obj.numEpochsCompleted || obj.numIntervalsPrepared > obj.numIntervalsCompleted;
        end
        
        function completeRun(obj)
            completeRun@edu.washington.rieke.protocols.RiekeProtocol(obj);
            obj.rig.getDevice('Stage').clearMemory();
        end
        
        function [tf, msg] = isValid(obj)
            [tf, msg] = isValid@edu.washington.rieke.protocols.RiekeProtocol(obj);
            if tf
                tf = ~isempty(obj.rig.getDevices('Stage'));
                msg = 'No stage';
            end
        end
        
    end
    
    methods (Access = protected)
        
        function p = um2pix(obj, um)
            stages = obj.rig.getDevices('Stage');
            if isempty(stages)
                micronsPerPixel = 1;
            else
                micronsPerPixel = stages{1}.getConfigurationSetting('micronsPerPixel');
            end
            p = round(um / micronsPerPixel);
        end
        
    end
    
end

