classdef Preparation < edu.washington.rieke.sources.Preparation
    
    methods
        
        function obj = Preparation()
            import symphonyui.core.*;
            
            obj.addAllowableParentType('edu.washington.rieke.sources.primate.Primate');
        end
        
    end
    
end

