classdef Electrophysiology < symphonyui.core.persistent.descriptions.ExperimentDescription
    
    methods
        
        function obj = Electrophysiology()
            import symphonyui.core.*;
            
            obj.addProperty('experimenter', '', ...
                'description', 'Who performed the experiment');
            obj.addProperty('project', '', ...
                'description', 'Project the experiment belongs to');
            obj.addProperty('institution', 'UW', ...
                'description', 'Institution where the experiment was performed');
            obj.addProperty('lab', 'Rieke Lab', ...
                'description', 'Lab where experiment was performed');
            obj.addProperty('rig', '', ...
                'type', PropertyType('char', 'row', {'', 'B (two photon)', 'C (suction)', 'E (confocal)', 'F (old slice)', 'G (shared two photon)'}), ...
                'description', 'Rig where experiment was performed');
        end
        
    end
    
end

