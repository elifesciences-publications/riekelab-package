classdef DualResponseFigure < symphonyui.core.FigureHandler
    % Plots the response of two specified devices in the most recent epoch.

    properties (SetAccess = private)
        device1
        sweepColor1
        storedSweepColor1
        
        device2
        sweepColor2
        storedSweepColor2
    end

    properties (Access = private)
        axesHandle1
        sweep1
        storedSweep1
        
        axesHandle2
        sweep2
        storedSweep2
    end

    methods

        function obj = DualResponseFigure(device1, device2, varargin)
            co = get(groot, 'defaultAxesColorOrder');
            
            ip = inputParser();
            ip.addParameter('sweepColor1', co(1,:), @(x)ischar(x) || isvector(x));
            ip.addParameter('storedSweepColor1', 'r', @(x)ischar(x) || isvector(x));
            ip.addParameter('sweepColor2', co(2,:), @(x)ischar(x) || isvector(x));
            ip.addParameter('storedSweepColor2', 'r', @(x)ischar(x) || isvector(x));
            ip.parse(varargin{:});

            obj.device1 = device1;
            obj.sweepColor1 = ip.Results.sweepColor1;
            obj.storedSweepColor1 = ip.Results.storedSweepColor1;
            
            obj.device2 = device2;
            obj.sweepColor2 = ip.Results.sweepColor2;
            obj.storedSweepColor2 = ip.Results.storedSweepColor2;

            obj.createUi();
        end

        function createUi(obj)
            import appbox.*;

            toolbar = findall(obj.figureHandle, 'Type', 'uitoolbar');
            storeSweepButton = uipushtool( ...
                'Parent', toolbar, ...
                'TooltipString', 'Store Sweep', ...
                'Separator', 'on', ...
                'ClickedCallback', @obj.onSelectedStoreSweep);
            setIconImage(storeSweepButton, symphonyui.app.App.getResource('icons', 'sweep_store.png'));
            
            obj.axesHandle1 = subplot(2, 1, 1, ...
                'Parent', obj.figureHandle, ...
                'FontUnits', get(obj.figureHandle, 'DefaultUicontrolFontUnits'), ...
                'FontName', get(obj.figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize'), ...
                'XTickMode', 'auto');
            xlabel(obj.axesHandle1, 'sec');
            title(obj.axesHandle1, [obj.device1.name ' Response']);
            
            obj.axesHandle2 = subplot(2, 1, 2, ...
                'Parent', obj.figureHandle, ...
                'FontUnits', get(obj.figureHandle, 'DefaultUicontrolFontUnits'), ...
                'FontName', get(obj.figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize'), ...
                'XTickMode', 'auto');
            xlabel(obj.axesHandle2, 'sec');
            title(obj.axesHandle2, [obj.device2.name ' Response']);

            set(obj.figureHandle, 'Name', [obj.device1.name ' and ' obj.device2.name ' Response']);
        end

        function clear(obj)
            cla(obj.axesHandle1);
            obj.sweep1 = [];
            
            cla(obj.axesHandle2);
            obj.sweep2 = [];
        end

        function handleEpoch(obj, epoch)
            if ~epoch.hasResponse(obj.device1) || ~epoch.hasResponse(obj.device2)
                error(['Epoch does not contain a response for ' obj.device1.name ' or ' obj.device2.name]);
            end
            
            obj.sweep1 = plotResponse(epoch.getResponse(obj.device1), obj.axesHandle1, obj.sweep1, obj.sweepColor1);
            obj.sweep2 = plotResponse(epoch.getResponse(obj.device2), obj.axesHandle2, obj.sweep2, obj.sweepColor2);
            
            function sweep = plotResponse(response, axesHandle, sweep, sweepColor)
                [quantities, units] = response.getData();
                if numel(quantities) > 0
                    x = (1:numel(quantities)) / response.sampleRate.quantityInBaseUnits;
                    y = quantities;
                else
                    x = [];
                    y = [];
                end
                if isempty(sweep)
                    sweep = line(x, y, 'Parent', axesHandle, 'Color', sweepColor);
                else
                    set(sweep, 'XData', x, 'YData', y);
                end
                ylabel(axesHandle, units, 'Interpreter', 'none');
            end
        end

    end

    methods (Access = private)

        function onSelectedStoreSweep(obj, ~, ~)
            if ~isempty(obj.storedSweep1)
                delete(obj.storedSweep1);
            end
            if ~isempty(obj.storedSweep2)
                delete(obj.storedSweep2);
            end
            
            obj.storedSweep1 = storeSweep(obj.sweep1, obj.axesHandle1, obj.storedSweepColor1);
            obj.storedSweep2 = storeSweep(obj.sweep2, obj.axesHandle2, obj.storedSweepColor2);
            
            function ss = storeSweep(sweep, axesHandle, storedSweepColor)
                ss = copyobj(sweep, axesHandle);
                set(ss, ...
                    'Color', storedSweepColor, ...
                    'HandleVisibility', 'off');
            end
        end

    end

end

