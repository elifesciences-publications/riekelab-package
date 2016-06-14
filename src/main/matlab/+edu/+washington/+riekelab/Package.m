classdef Package < handle
    
    methods (Static)
        
        function p = getResource(varargin)
            resourcesPath = fullfile(fileparts(fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))))), 'resources');
            p = fullfile(resourcesPath, varargin{:});
        end
        
    end
    
end

