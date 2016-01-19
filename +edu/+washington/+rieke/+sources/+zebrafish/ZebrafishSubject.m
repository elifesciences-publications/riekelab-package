classdef ZebrafishSubject < edu.washington.rieke.sources.Subject
    
    methods
        
        function obj = ZebrafishSubject()
            import symphonyui.core.*;
            
            obj.propertyDescriptors = [ ...
                obj.propertyDescriptors, ...
                PropertyDescriptor('genotype', {}, ...
                    'type', PropertyType('cellstr', 'row', {'wild type', 'VSX1:mCerulean', 'VSX2:?'}), ... 
                    'description', 'Genetic strain'), ...
                ];
        end
        
    end
    
end

