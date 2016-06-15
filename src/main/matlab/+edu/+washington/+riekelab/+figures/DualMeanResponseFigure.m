classdef DualMeanResponseFigure < symphonyui.core.FigureHandler
    % Plots the mean response of two specified devices for all epochs run.
    
    properties (SetAccess = private)
        device1
        groupBy1
        sweepColor1
        storedSweepColor1
        
        device2
        groupBy2
        sweepColor2
        storedSweepColor2
    end
    
    properties (Access = private)
        axesHandle1
        sweeps1
        storedSweeps1
        
        axesHandle2
        sweeps2
        storedSweeps2
    end
    
    methods
        
        function obj = DualMeanResponseFigure(device1, device2, varargin)
            co = get(groot, 'defaultAxesColorOrder');
            
            ip = inputParser();
            ip.addParameter('groupBy1', [], @(x)iscellstr(x));
            ip.addParameter('sweepColor1', co(1,:), @(x)ischar(x) || isvector(x));
            ip.addParameter('storedSweepColor1', 'r', @(x)ischar(x) || isvector(x));
            ip.addParameter('groupBy2', [], @(x)iscellstr(x));
            ip.addParameter('sweepColor2', co(2,:), @(x)ischar(x) || isvector(x));
            ip.addParameter('storedSweepColor2', 'r', @(x)ischar(x) || isvector(x));
            ip.parse(varargin{:});
            
            obj.device1 = device1;
            obj.groupBy1 = ip.Results.groupBy1;
            obj.sweepColor1 = ip.Results.sweepColor1;
            obj.storedSweepColor1 = ip.Results.storedSweepColor1;
            
            obj.device2 = device2;
            obj.groupBy2 = ip.Results.groupBy2;
            obj.sweepColor2 = ip.Results.sweepColor2;
            obj.storedSweepColor2 = ip.Results.storedSweepColor2;
            
            obj.createUi();
        end
        
        function createUi(obj)
            import appbox.*;
            
            toolbar = findall(obj.figureHandle, 'Type', 'uitoolbar');
            storeSweepsButton = uipushtool( ...
                'Parent', toolbar, ...
                'TooltipString', 'Store Sweeps', ...
                'Separator', 'on', ...
                'ClickedCallback', @obj.onSelectedStoreSweeps);
            setIconImage(storeSweepsButton, symphonyui.app.App.getResource('icons', 'sweep_store.png'));
            
            mainLayout = uix.VBox('Parent', obj.figureHandle);
            
            obj.axesHandle1 = axes( ...
                'Parent', mainLayout, ...
                'FontName', get(obj.figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize'), ...
                'XTickMode', 'auto');
            xlabel(obj.axesHandle1, 'sec');
            title(obj.axesHandle1, [obj.device1.name ' Mean Response']);
            obj.sweeps1 = {};
            
            obj.axesHandle2 = axes( ...
                'Parent', mainLayout, ...
                'FontName', get(obj.figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize'), ...
                'XTickMode', 'auto');
            xlabel(obj.axesHandle2, 'sec');
            title(obj.axesHandle2, [obj.device2.name ' Mean Response']);
            obj.sweeps2 = {};
            
            set(obj.figureHandle, 'Name', [obj.device1.name ' and ' obj.device2.name ' Mean Response']);
        end
        
        function clear(obj)
            cla(obj.axesHandle1);
            obj.sweeps1 = {};
            
            cla(obj.axesHandle2);
            obj.sweeps2 = {};
        end
        
        function handleEpoch(obj, epoch)
            if ~epoch.hasResponse(obj.device1) || ~epoch.hasResponse(obj.device2)
                error(['Epoch does not contain a response for ' obj.device1.name ' or ' obj.device2.name]);
            end
            
            obj.sweeps1 = plotResponse(epoch.getResponse(obj.device1), epoch.parameters, obj.groupBy1, obj.device1.name, ...
                obj.axesHandle1, obj.sweeps1, obj.sweepColor1);
            obj.sweeps2 = plotResponse(epoch.getResponse(obj.device2), epoch.parameters, obj.groupBy2, obj.device2.name, ...
                obj.axesHandle2, obj.sweeps2, obj.sweepColor2);
            
            function sweeps = plotResponse(response, epochParameters, groupBy, deviceName, axesHandle, sweeps, sweepColor)
                [quantities, units] = response.getData();
                if numel(quantities) > 0
                    x = (1:numel(quantities)) / response.sampleRate.quantityInBaseUnits;
                    y = quantities;
                else
                    x = [];
                    y = [];
                end

                p = epochParameters;
                if isempty(groupBy) && isnumeric(groupBy)
                    parameters = p;
                else
                    parameters = containers.Map();
                    for i = 1:length(groupBy)
                        key = groupBy{i};
                        parameters(key) = p(key);
                    end
                end

                if isempty(parameters)
                    t = 'All epochs grouped together';
                else
                    t = ['Grouped by ' strjoin(parameters.keys, ', ')];
                end
                title(axesHandle, [deviceName ' Mean Response (' t ')']);

                sweepIndex = [];
                for i = 1:numel(sweeps)
                    if isequal(sweeps{i}.parameters, parameters)
                        sweepIndex = i;
                        break;
                    end
                end

                if isempty(sweepIndex)
                    sweep.line = line(x, y, 'Parent', axesHandle, 'Color', sweepColor);
                    sweep.parameters = parameters;
                    sweep.count = 1;
                    sweeps{end + 1} = sweep;
                else
                    sweep = sweeps{sweepIndex};
                    cy = get(sweep.line, 'YData');
                    set(sweep.line, 'YData', (cy * sweep.count + y) / (sweep.count + 1));
                    sweep.count = sweep.count + 1;
                    sweeps{sweepIndex} = sweep;
                end

                ylabel(axesHandle, units, 'Interpreter', 'none');
            end
        end
        
    end
    
    methods (Access = private)
        
        function onSelectedStoreSweeps(obj, ~, ~)
            if ~isempty(obj.storedSweeps1)
                for i = 1:numel(obj.storedSweeps1)
                    delete(obj.storedSweeps1{i});
                end
                obj.storedSweeps1 = {};
            end
            if ~isempty(obj.storedSweeps2)
                for i = 1:numel(obj.storedSweeps2)
                    delete(obj.storedSweeps2{i});
                end
                obj.storedSweeps2 = {};
            end
            
            obj.storedSweeps1 = storeSweeps(obj.sweeps1, obj.axesHandle1, obj.storedSweepColor1);
            obj.storedSweeps2 = storeSweeps(obj.sweeps2, obj.axesHandle2, obj.storedSweepColor2);
            
            function ss = storeSweeps(sweeps, axesHandle, storedSweepColor)         
                for k = 1:numel(sweeps)
                    ss{k} = copyobj(sweeps{k}.line, axesHandle); %#ok<AGROW>
                    set(ss{k}, ...
                        'Color', storedSweepColor, ...
                        'HandleVisibility', 'off');
                end
            end
        end
        
    end
        
end

