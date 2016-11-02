classdef DeviceCalibrator < symphonyui.ui.Module
    
    properties (Access = private)
        leds
        stage
        calibrations
        previousCalibrations
    end
    
    properties (Access = private)
        wizardCardPanel
        instructionsCard
        calibrationCard
        backButton
        nextButton
        cancelButton
    end
    
    methods
        
        function createUi(obj, figureHandle)
            import appbox.*;
            
            set(figureHandle, ...
                'Name', 'Device Calibrator', ...
                'Position', screenCenter(475, 294), ...
                'WindowStyle', 'modal', ...
                'Resize', 'off');
            
            mainLayout = uix.VBox( ...
                'Parent', figureHandle);
            
            wizardLayout = uix.VBox( ...
                'Parent', mainLayout);
            
            obj.wizardCardPanel = uix.CardPanel( ...
                'Parent', wizardLayout);
            
            % Instructions card.
            instructionsLayout = uix.VBox( ...
                'Parent', obj.wizardCardPanel, ...
                'Padding', 11);
            Label( ...
                'Parent', instructionsLayout, ...
                'String', sprintf(['<html><b>Instructions:</b><br>' ...
                    '&emsp;1. Tape the wand to the stage, face down.<br>' ...
                    '&emsp;2. Connect the wand BNC cable to the light meter input on front of the box.<br>' ...
                    '&emsp;3. Close the curtains and dim the lights.<br>' ...
                    '&emsp;4. Turn on the power meter and set the gain to 10^-3.<br>' ...
                    '&emsp;5. Make sure the current (background) reading is ~0.01 or lower.<br>' ...
                    '&emsp;6. Turn on the stimulation device to a reasonably bright setting.<br>' ...
                    '&emsp;7. Center and focus the wand relative to the spot:<br>' ...
                    '&emsp;&emsp;7.1. Move the stage in the X direction until you find the peak power reading.<br>' ...
                    '&emsp;&emsp;7.2. Move the stage in the Y direction until you find the peak power reading.<br>' ...
                    '&emsp;&emsp;7.3. Move the stage in the Z direction until the power reading stops increasing.<br>' ...
                    '&emsp;&emsp;7.4. Move the stage up a bit so the wand is not pushing on the condenser.<br>' ...
                    '&emsp;8. Press "Next" to start calibrating.</html>']));
            
            % Calibration card.
            calibrationLayout = uix.HBox( ...
                'Parent', obj.wizardCardPanel, ...
                'Padding', 11, ...
                'Spacing', 7);
            
            masterLayout = uix.VBox( ...
                'Parent', calibrationLayout);
            
            obj.calibrationCard.deviceListBox = MappedListBox( ...
                'Parent', masterLayout, ...
                'Callback', @obj.onSelectedDevice);
            
            detailLayout = uix.VBox( ...
                'Parent', calibrationLayout, ...
                'Spacing', 7);
            
            lastCalibratedLayout = uix.HBox( ...
                'Parent', detailLayout);
            Label( ...
                'Parent', lastCalibratedLayout, ...
                'String', 'Last calibrated:');
            obj.calibrationCard.lastCalibratedField = uicontrol( ...
                'Parent', lastCalibratedLayout, ...
                'Style', 'edit', ...
                'Enable', 'off', ...
                'HorizontalAlignment', 'left');
            set(lastCalibratedLayout, 'Widths', [115 -1]);
            
            useLayout = uix.HBox( ...
                'Parent', detailLayout);
            uix.Empty('Parent', useLayout);
            obj.calibrationCard.useButton = uicontrol( ...
                'Parent', useLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Use', ...
                'Interruptible', 'off', ...
                'Callback', @obj.onSelectedUse);
            set(useLayout, 'Widths', [-1 75]);
            
            javacomponent(com.jidesoft.swing.TitledSeparator('Or', com.jidesoft.swing.TitledSeparator.TYPE_PARTIAL_LINE, javax.swing.SwingConstants.CENTER), [], detailLayout);
            
            calibrateLayout = uix.HBox( ...
                'Parent', detailLayout);
            Label( ...
                'Parent', calibrateLayout, ...
                'String', 'Calibrate using (V):');
            obj.calibrationCard.calibrationVoltageField = uicontrol( ...
                'Parent', calibrateLayout, ...
                'Style', 'edit', ...
                'String', '1', ...
                'HorizontalAlignment', 'left');
            set(calibrateLayout, 'Widths', [115 -1]);
            
            ledLayout = uix.HBox( ...
                'Parent', detailLayout);
            uix.Empty('Parent', ledLayout);
            obj.calibrationCard.ledOnButton = uicontrol( ...
                'Parent', ledLayout, ...
                'Style', 'togglebutton', ...
                'String', 'LED On', ...
                'Interruptible', 'off', ...
                'Callback', @obj.onSelectedLedOn);
            set(ledLayout, 'Widths', [-1 75]);
            
            powerLayout = uix.HBox( ...
                'Parent', detailLayout); 
            Label( ...
                'Parent', powerLayout, ...
                'String', 'Power reading (nW):');
            obj.calibrationCard.powerReadingField = uicontrol( ...
                'Parent', powerLayout, ...
                'Style', 'edit', ...
                'HorizontalAlignment', 'left');
            set(powerLayout, 'Widths', [115 -1]);
            
            spotLayout = uix.HBox( ...
                'Parent', detailLayout);
            Label( ...
                'Parent', spotLayout, ...
                'String', 'Spot diameter (um):');
            obj.calibrationCard.spotDiameterField = uicontrol( ...
                'Parent', spotLayout, ...
                'Style', 'edit', ...
                'HorizontalAlignment', 'left');
            set(spotLayout, 'Widths', [115 -1]);
            
            submitLayout = uix.HBox( ...
                'Parent', detailLayout);
            uix.Empty('Parent', submitLayout);
            obj.calibrationCard.submitButton = uicontrol( ...
                'Parent', submitLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Submit', ...
                'Interruptible', 'off', ...
                'Callback', @obj.onSelectedSubmit);
            set(submitLayout, 'Widths', [-1 75]);
            
            set(detailLayout, 'Heights', [23 23 17 23 23 23 23 23]);
            
            set(calibrationLayout, 'Widths', [-1 -2]);
            
            set(obj.wizardCardPanel, 'Selection', 1);
                
            javacomponent('javax.swing.JSeparator', [], wizardLayout);
            
            set(wizardLayout, 'Heights', [-1 1]);
            
            controlsLayout = uix.HBox( ...
                'Parent', mainLayout, ...
                'Padding', 11);
            uix.Empty('Parent', controlsLayout);
            obj.backButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', '< Back', ...
                'Interruptible', 'off', ...
                'Callback', @obj.onSelectedBack);
            obj.nextButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Next >', ...
                'Interruptible', 'off', ...
                'Callback', @obj.onSelectedNext);
            uix.Empty('Parent', controlsLayout);
            obj.cancelButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Cancel', ...
                'Interruptible', 'off', ...
                'Callback', @obj.onSelectedCancel);
            set(controlsLayout, 'Widths', [-1 75 75 7 75]);
            
            set(mainLayout, 'Heights', [-1 11+23+11]);
            
            % Set next button to appear as the default button.
            try %#ok<TRYNC>
                h = handle(figureHandle);
                h.setDefaultButton(obj.nextButton);
            end
        end
        
    end
    
    methods (Access = protected)
        
        function willGo(obj)
            obj.leds = obj.configurationService.getDevices('LED');
            stages = obj.configurationService.getDevices('Stage');
            if isempty(stages)
                obj.stage = [];
            else
                obj.stage = stages{1};
            end
            
            obj.calibrations = containers.Map();
            obj.previousCalibrations = containers.Map();
            for i = 1:numel(obj.leds)
                led = obj.leds{i};
                
                if ~any(strcmp('fluxFactorPaths', led.getResourceNames()))
                    continue;
                end
                paths = led.getResource('fluxFactorPaths');
                
                m = containers.Map();
                gains = paths.keys;
                for k = 1:numel(gains)
                    gain = gains{k};
                    if ~exist(paths(gain), 'file')
                        continue;
                    end
                    m(gain) = importdata(paths(gain));
                end
                
                obj.previousCalibrations(led.name) = m;
            end
            
            obj.populateDeviceList();
            obj.updateStateOfControls();
        end
        
        function onViewSelectedClose(obj, ~, ~)
            obj.close();
        end
        
    end
    
    methods (Access = private)
        
        function populateDeviceList(obj)
            devices = containers.Map();
            gains = {};
            for i = 1:numel(obj.leds)
                led = obj.leds{i};
                
                desc = led.getConfigurationSettingDescriptors().findByName('gain');
                if isempty(desc)
                    if devices.isKey('none')
                        devices('none') = [devices('none') {led}];
                    else
                        devices('none') = {led};
                    end
                    continue;
                end
                
                availableGains = desc.type.domain;
                for k = 1:numel(availableGains)
                    gain = availableGains{k};
                    if isempty(gain)
                        continue;
                    end
                    
                    if devices.isKey(gain)
                        devices(gain) = [devices(gain) {led}];
                    else
                        devices(gain) = {led};
                        gains{end + 1} = gain; %#ok<AGROW>
                    end
                end
            end
            
            keys = gains;
            if devices.isKey('none')
                keys{end + 1} = 'none';
            end
            
            names = {};
            values = {};
            for i = 1:numel(keys)
                gain = keys{i};
                devs = devices(gain);
                for k = 1:numel(devs)
                    d = devs{k};
                    if obj.isDeviceCalibrated(d, gain)
                        n = ['<html><font color="green"><b>' d.name];
                    else
                        n = d.name;
                    end
                    if ~strcmp(gain, 'none')
                        n = [n ' - ' gain]; %#ok<AGROW>
                    end
                    names{end + 1} = n; %#ok<AGROW>
                    values{end + 1} = struct('device', d, 'gain', gain); %#ok<AGROW>
                end
            end
            set(obj.calibrationCard.deviceListBox, 'String', names);
            set(obj.calibrationCard.deviceListBox, 'Values', values);
        end
        
        function onSelectedDevice(obj, ~, ~)            
            [device, gain] = obj.getSelectedDevice();
            obj.selectDevice(device, gain);
        end
        
        function selectDevice(obj, device, gain)
            obj.turnOffAllLeds();
            
            turnOn = get(obj.calibrationCard.ledOnButton, 'Value');
            if turnOn
                voltage = str2double(get(obj.calibrationCard.calibrationVoltageField, 'String'));
                isOn = obj.turnOnLed(device, voltage);
                set(obj.calibrationCard.ledOnButton, 'Value', isOn);
            end
            
            obj.setSelectedDevice(device, gain);
            obj.populateDetailsForDevice(device, gain);
            obj.updateStateOfControls();
        end
        
        function selectNextDevice(obj)
            old = get(obj.calibrationCard.deviceListBox, 'Value');
            old = old{1};
            
            values = get(obj.calibrationCard.deviceListBox, 'Values');
            i = find(cellfun(@(v)isequal(v, old), values), 1) + 1;
            new = values{mod(i - 1, numel(values)) + 1};
            
            obj.selectDevice(new.device, new.gain);
        end
        
        function setSelectedDevice(obj, device, gain)
            v = struct('device', device, 'gain', gain);
            set(obj.calibrationCard.deviceListBox, 'Value', v);
        end
        
        function [device, gain] = getSelectedDevice(obj)
            v = get(obj.calibrationCard.deviceListBox, 'Value');
            if isempty(v)
                device = [];
                gain = [];
                return;
            end
            v = v{1};
            device = v.device;
            gain = v.gain;
        end
        
        function populateDetailsForDevice(obj, device, gain)
            [~, date] = obj.getLastCalibrationValue(device, gain);
            if isempty(date)
                lastCalibrated = 'Never';
            else
                lastCalibrated = datestr(date, 'dd-mmm-yyyy HH:MM:SS PM');
            end
            set(obj.calibrationCard.lastCalibratedField, 'String', lastCalibrated);
        end
        
        function [v, d] = getLastCalibrationValue(obj, device, gain)
            v = [];
            d = [];
            if obj.previousCalibrations.isKey(device.name) && obj.previousCalibrations(device.name).isKey(gain)
                m = obj.previousCalibrations(device.name);
                factors = m(gain);
                v = factors(end, 2);
                d = factors(end, 1);
            end
        end
        
        function onSelectedUse(obj, ~, ~)
            [device, gain] = obj.getSelectedDevice();
            
            value = obj.getLastCalibrationValue(device, gain);
            obj.calibrateDevice(device, gain, value);
            
            obj.selectNextDevice();
            obj.updateStateOfControls();
        end
        
        function calibrateDevice(obj, device, gain, value)
            if obj.isDeviceCalibrated(device, gain)
                result = obj.view.showMessage( ...
                    'This device has already been calibrated. Are you sure you want overwrite the current value?', ...
                    'Overwrite', ...
                    'button1', 'Cancel', ...
                    'button2', 'Overwrite');
                if ~strcmp(result, 'Overwrite')
                    return;
                end
            end
            
            if obj.calibrations.isKey(device.name)
                m = obj.calibrations(device.name);
            else
                m = containers.Map();
            end
            m(gain) = value;
            obj.calibrations(device.name) = m;
            obj.setDeviceCalibrated(device, gain);
        end
        
        function tf = isDeviceCalibrated(obj, device, gain)
            tf = any(strcmp('calibrations', device.getResourceNames())) || ...
                (obj.calibrations.isKey(device.name) && obj.calibrations(device.name).isKey(gain));
        end
        
        function setDeviceCalibrated(obj, device, gain)
            names = get(obj.calibrationCard.deviceListBox, 'String');
            values = get(obj.calibrationCard.deviceListBox, 'Values');
            
            i = cellfun(@(v)isequal(v, struct('device', device, 'gain', gain)), values);
            n = ['<html><font color="green"><b>' device.name];
            if ~strcmp(gain, 'none')
                n = [n ' - ' gain];
            end
            names{i} = n;
            
            set(obj.calibrationCard.deviceListBox, 'String', names);
            set(obj.calibrationCard.deviceListBox, 'Values', values);
        end
        
        function onSelectedLedOn(obj, ~, ~)
            obj.turnOffAllLeds();
            
            turnOn = get(obj.calibrationCard.ledOnButton, 'Value');
            if turnOn
                led = obj.getSelectedDevice();
                voltage = str2double(get(obj.calibrationCard.calibrationVoltageField, 'String'));
                isOn = obj.turnOnLed(led, voltage);
                set(obj.calibrationCard.ledOnButton, 'Value', isOn);
            end
            
            obj.updateStateOfControls();
        end
        
        function success = turnOnLed(obj, led, quantity)
            success = true;
            try
                led.background = symphonyui.core.Measurement(quantity, led.background.displayUnits);
                led.applyBackground();
            catch x
                obj.view.showError(['Unable to turn on LED: ' x.message]);
                led.background = symphonyui.core.Measurement(0, led.background.displayUnits);
                success = false;
                return;
            end
        end
        
        function turnOffAllLeds(obj)
            for i = 1:numel(obj.leds)
                led = obj.leds{i};
                led.background = symphonyui.core.Measurement(0, led.background.displayUnits);
                led.applyBackground();
            end
        end
        
        function onSelectedSubmit(obj, ~, ~)
            [device, gain] = obj.getSelectedDevice();
            
            voltage = str2double(get(obj.calibrationCard.calibrationVoltageField, 'String'));            
            power = str2double(get(obj.calibrationCard.powerReadingField, 'String'));
            diameter = str2double(get(obj.calibrationCard.spotDiameterField, 'String'));
            
            if isnan(power) || isnan(diameter)
                obj.view.showError('Could not parse power or diameter to a valid scalar value.');
                return;
            end
            
            ssize = pi * diameter * diameter / 4;
            value = power / (ssize * voltage);
            obj.calibrateDevice(device, gain, value);
            
            obj.selectNextDevice();
            obj.updateStateOfControls();
        end
        
        function onSelectedBack(obj, ~, ~)
            selection = get(obj.wizardCardPanel, 'Selection');
            set(obj.wizardCardPanel, 'Selection', selection - 1);
            
            obj.updateStateOfControls();
        end
        
        function onSelectedNext(obj, ~, ~)
            selection = get(obj.wizardCardPanel, 'Selection');
            if selection < numel(get(obj.wizardCardPanel, 'Children'))
                set(obj.wizardCardPanel, 'Selection', selection + 1);
            end
            
            if strcmp(get(obj.nextButton, 'String'), 'Finish')
                obj.saveCalibration();
                obj.turnOffAllLeds();
                obj.stop();
            else
                [device, gain] = obj.getSelectedDevice();
                obj.selectDevice(device, gain);
            end
        end
        
        function saveCalibration(obj)
            keys = obj.calibrations.keys;
            for i = 1:numel(keys)
                name = keys{i};
                led = obj.leds{cellfun(@(l)strcmp(l.name, name), obj.leds)};
                
                if any(strcmp('calibrations', led.getResourceNames()))
                    led.removeResource('calibrations');
                end
                if ~obj.calibrations.isKey(name)
                    continue;
                end
                cal = obj.calibrations(name);
                led.addResource('calibrations', cal);
                
                if ~obj.previousCalibrations.isKey(name)
                    continue;
                end
                prevCal = obj.previousCalibrations(name);
                
                if ~any(strcmp('fluxFactorPaths', led.getResourceNames()))
                    continue;
                end
                paths = led.getResource('fluxFactorPaths');
                
                gains = cal.keys;
                for k = 1:numel(gains)
                    gain = gains{k};
                    if prevCal.isKey(gain)
                        history = prevCal(gain);
                    else
                        history = [];
                    end
                    history(end + 1, 1) = now(); %#ok<AGROW>
                    history(end, 2) = cal(gain);
                    save(paths(gain), 'history', '-ascii', '-double', '-tabs');
                    prevCal(gain) = history;
                end
                
                obj.previousCalibrations(name) = prevCal;
            end
        end
        
        function onSelectedCancel(obj, ~, ~)
            obj.close();
        end
        
        function close(obj)
            shouldClose = true;
            if ~isempty(obj.calibrations)
                result = obj.view.showMessage( ...
                    ['You have calibrated some devices. You will lose these values if you close the calibrator. ' ...
                    'Are you sure you want to close?'], 'Close', ...
                    'button1', 'Cancel', ...
                    'button2', 'Close');
                shouldClose = strcmp(result, 'Close');
            end
            if shouldClose
                obj.stop();
            end
        end
        
        function updateStateOfControls(obj)
            import appbox.*;
            
            [device, gain] = obj.getSelectedDevice();
            
            hasDevice = ~isempty(device);
            hasLastCalibration = hasDevice && ~isempty(obj.getLastCalibrationValue(device, gain));
            isLedOn = get(obj.calibrationCard.ledOnButton, 'Value');
            isLastCard = get(obj.wizardCardPanel, 'Selection') >= numel(get(obj.wizardCardPanel, 'Children'));
            allCalibrated = all(cellfun(@(s)obj.isDeviceCalibrated(s.device, s.gain), ...
                get(obj.calibrationCard.deviceListBox, 'Values')));
            
            set(obj.calibrationCard.useButton, 'Enable', onOff(hasLastCalibration));
            set(obj.calibrationCard.calibrationVoltageField, 'Enable', onOff(hasDevice && ~isLedOn));
            set(obj.calibrationCard.ledOnButton, 'Enable', onOff(hasDevice));
            set(obj.calibrationCard.powerReadingField, 'Enable', onOff(hasDevice && isLedOn));
            set(obj.calibrationCard.spotDiameterField, 'Enable', onOff(hasDevice && isLedOn));
            set(obj.calibrationCard.submitButton, 'Enable', onOff(hasDevice && isLedOn));
            set(obj.backButton, 'Enable', onOff(isLastCard));
            set(obj.nextButton, 'Enable', onOff(~isLastCard || allCalibrated));
            if isLastCard
                set(obj.nextButton, 'String', 'Finish');
            else
                set(obj.nextButton, 'String', 'Next >');
            end
        end
        
    end
    
end

