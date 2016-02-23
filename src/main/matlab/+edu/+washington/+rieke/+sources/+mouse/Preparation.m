classdef Preparation < edu.washington.rieke.sources.Preparation
    
    methods
        
        function obj = Preparation()
            import symphonyui.core.*;
            
            obj.addAllowableParentType('edu.washington.rieke.sources.mouse.Mouse');
        end
        
    end
    
end

