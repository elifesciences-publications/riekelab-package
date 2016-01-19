classdef MouseSubject < edu.washington.rieke.sources.Subject
    
    methods
        
        function obj = MouseSubject()
            import symphonyui.core.*;
            
            obj.propertyDescriptors = [ ...
                obj.propertyDescriptors, ...
                PropertyDescriptor('genotype', {}, ...
                    'type', PropertyType('cellstr', 'row', {'C57B6', 'Rho 19', 'Rho 18', 'STM', 'TTM', 'Arr1 KO', 'GRK1 KO', 'GCAP KO', 'GJD2-GFP', 'DACT2-GFP', 'PLCXD2-GFP', 'NeuroD6 Cre', 'Grm6-tdTomato', 'Grm6-cre1', 'Ai27 (floxed ChR2-tdTomato)', 'Cx36-/-'}), ... 
                    'description', 'Genetic strain'), ...
                ];
        end
        
    end
    
end

