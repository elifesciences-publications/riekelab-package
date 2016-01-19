classdef PrimateSubject < edu.washington.rieke.sources.Subject
    
    methods
        
        function obj = PrimateSubject()
            import symphonyui.core.*;
            
            obj.propertyDescriptors = [ ...
                obj.propertyDescriptors, ...
                PropertyDescriptor('species', '', ...
                    'type', PropertyType('char', 'row', {'', 'M. mulatta', 'M. fascicularis', 'M. nemestrina'}), ... 
                    'description', 'Species'), ...
                ];
        end
        
    end
    
end

