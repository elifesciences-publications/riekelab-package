classdef (Abstract) RiekeStageProtocol < edu.washington.rieke.protocols.RiekeProtocol
    
    methods (Abstract)
        p = createPresentation(obj);
    end
    
    methods
        
        function prepareEpoch(obj, epoch)
            prepareEpoch@edu.washington.rieke.protocols.RiekeProtocol(obj, epoch);
            epoch.shouldWaitForTrigger = true;
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
    
end

