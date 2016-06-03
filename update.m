function status = update(path)
    if nargin < 1
        path = fileparts(mfilename('fullpath'));
    end
    
    [~, repo] = fileparts(path);
    
    git = ['git -C "' path '"'];
    
    disp(['Fetching and integrating changes for ' repo '...']);
    execute([git ' pull']);
    
    disp(['Updating submodules in ' repo '...']);
    execute([git ' submodule foreach --recursive "git pull";']);
    
    status = execute([git ' status --porcelain']);
end

function out = execute(cmd)
    if nargout == 0
        status = system(cmd);
    else
        [status, out] = system(cmd);
    end
    if status
        error(['Failed to execute ''' cmd '''']);
    end
end