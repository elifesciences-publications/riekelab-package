classdef CalibratorOld < symphonyui.ui.Module
    
    properties
        % this is a structure that contains handles for many of the ui
        % elements
        ui
        
        % this will be a cell array of structures that will store device
        % information. there will be an element in the cell array for each
        % device for which calibration is being performed and each of
        % these structures will have a field for:settings, most recent
        % calibrations
        deviceData
        
        % a cell array of device objects
        deviceList
    end
    
    % values that will specify things about the current state of the ui
    % and/or rig
    properties (Access = private)
        % this will be a structure with the fields: 'device' and 'setting',
        % each of these will contain an index that will specify which
        % device/setting pair is currently selected (this will allow the ui
        % to make sure that the selection has actually changed when an
        % option in the box is clicked before it changes the right half of
        % the ui)
        currentSelection
        
        % some T/F values that will be used to provide context for ui
        % callbacks
        ledOn
        inputPanelVisible
        
        
        % this will be a cell array with an element for each device; each
        % of these elements themselves will be an array of trues or falses
        % that will specify if a given setting for a given device has been
        % calibrated (0 for no, 1 for yes)
        calibratedTFs
        
        % This will be a cell array of maps that will store all of the new
        % calibration values as they are entered.  They keys will be the
        % setting names and the values will be the calibration values.
        calibrationValues
        
        %         % this will be a cell array that will store all of the calibration
        %         % values as they are entered; it will have an element for each
        %         % device; each of these elements themselves will be an array of
        %         % calibration values; the units of these values will be
        %         % uW/(V*um^2) or uW/((input)*um^2), depending on the unit that is
        %         % used to specify an input signal to the device
        %         calibrationValues
        %
        %         % this will be a cell array that will store true/false values for
        %         % whether or not the calibration value in the cell array
        %         % 'obj.calibrationValues' is new, or if it came from a previously
        %         % collected calibration - this will control whether or not the
        %         % values for each device/setting are added to the devices log at
        %         % the conclusion of calibration
        %         newCalibrationValues
        
        % the 'deviceNames' and 'settingsNames' properties will hold
        % strings with the names of the devices and the settings,
        % respectively; they will be used for populating the listboxes; it
        % is necessary to save these to a property because the strings will
        % be modified as tick marks are added to show that a given device
        % or seting has been calibrated
        % this will be a cell array with an element for each device that
        % contains a string with its name
        deviceNames
        % a cell array of settings names; it will have an element for each
        % device; each of these elements themselves will be cell arrays
        % with elements for each setting for the given device; each of
        % these elements will contain a string with the setting name
        settingsNames
        
        rigName
        
    end
    
    % Stuff for the advanced settings window.
    properties
        % this will be a struct that will hold everything relating to the
        % advanced settings window
        advancedSettingsWindow
        
        % this will start as and empty string, if the user elects to apply
        % a spectral sensitivity correction for the device they are using,
        % it will store the device's name as a string
        calibrationDeviceName = ''
    end
    
    % Stuff for the calibration history viewer.
    properties
        % stores the calibration history viewer object
        calibrationHistoryViewer = []
    end
    
    properties (Dependent)
        numDevices
        deviceSelection
        settingSelection
        requestedDeviceSignal
        tickMarkPath
        skipString
        lastCalibrationDate
        inputBoxTitleString
        deviceName
        settingName
    end
    
    % default values
    properties
        defaultEditBoxColor = [0.94 0.94 0.94]
        
        % if a submitted calibration is sufficiently different than the
        % most recent calibration value, the user will be given a warning -
        % this property will set the threshold for when this warning is
        % generated = it will be in units of fraction of the old value
        % tolerated as a difference
        warningLargeChangeThreshold = 0.1 % tolerate 10% change
        
        advancedSettingsFunctional = false;
        
        % font size for advanced settings window
        advancedSettingsInstructionsFontSize = 10
        
        % this boolean will be used in the future once the ability to
        % correct for the spectral sensitivity of a device has been added
        useSpectralSensitivityCorrection = false
    end
    
    % Create the UI
    methods
        function createUi(obj, figureHandle)
            import appbox.*;
            
            % this method is called to create the UI, but the module does
            % not have access to some information - just use it to make the
            % UI, but populate the UI later
            
            
            set(figureHandle, ...
                'Name', 'Calibrator', ...
                'Position', screenCenter(500, 300));
            
            mainLayout = uix.HBox( ...
                'Parent', figureHandle, ...
                'Padding', 11, ...
                'Spacing', 11);
            
            ui.leftLayout = uix.VBox(...
                'Parent', mainLayout, ...
                'Spacing', 0);
            
            ui.listsLayout = uix.HBox(...
                'Parent', ui.leftLayout, ...
                'Spacing', 11);
            
            
            % make a layout that will hold the button for viewing the
            % advanced settings
            uix.Empty('Parent', ui.leftLayout); %#ok<*PROP>
            ui.advancedButton.layout = uix.HBox(...
                'Parent', ui.leftLayout);
            uix.Empty('Parent', ui.advancedButton.layout);
            ui.advancedButton.button = uicontrol(...
                'Parent', ui.advancedButton.layout, ...
                'Style', 'pushbutton', ...
                'String', 'Advanced', ...
                'Callback', @obj.advancedSettingsCallback);
            uix.Empty('Parent', ui.advancedButton.layout);
            set(ui.advancedButton.layout, 'Widths', [-1 -2 -1]);
            
            % make a layout that will hold the button for viewing the
            % calibration history
            uix.Empty('Parent', ui.leftLayout);
            ui.historyButton.layout = uix.HBox(...
                'Parent', ui.leftLayout);
            uix.Empty('Parent', ui.historyButton.layout);
            ui.historyButton.button = uicontrol(...
                'Parent', ui.historyButton.layout, ...
                'Style', 'pushbutton', ...
                'String', 'View History', ...
                'Callback', @obj.viewCalibrationHistoryCallback);
            uix.Empty('Parent', ui.historyButton.layout);
            set(ui.historyButton.layout, 'Widths', [-1 -2 -1]);
            
            % make the layout that will either hold the string instructing
            % the user to calibrate all devices, or the final submit
            % button; also make an empty space above it
            uix.Empty('Parent', ui.leftLayout);
            ui.instructionsSubmitLayout.layout = uix.HBox(...
                'Parent', ui.leftLayout);
            uix.Empty('Parent', ui.instructionsSubmitLayout.layout);
            instr = 'Please provide calibration values for all settings on all devices.';
            ui.instructionsSubmitLayout.uiElement = uicontrol(...
                'Parent', ui.instructionsSubmitLayout.layout, ...
                'Style', 'text', ...
                'String', instr, ...
                'FontSize', 10);
            uix.Empty('Parent', ui.instructionsSubmitLayout.layout);
            set(ui.instructionsSubmitLayout.layout, 'Widths', [1 -1 1]);
            
            % set left layout spacing
            set(ui.leftLayout, 'Heights', [-1 7 28 5 28 5 33]);
            
            ui.deviceList.layout = uix.VBox( ...
                'Parent', ui.listsLayout, ...
                'Spacing', 7);
            
            ui.deviceSettings.layout = uix.VBox( ...
                'Parent', ui.listsLayout, ...
                'Spacing', 7);
            
            ui.deviceList.title = uicontrol( ...
                'Parent', ui.deviceList.layout, ...
                'Style', 'Text', ...
                'String', 'Select Device', ...
                'FontSize', 12);
            ui.deviceList.box = uicontrol( ...
                'Parent', ui.deviceList.layout, ...
                'Style', 'listbox', ...
                'Callback', @obj.deviceBoxClicked);
            
            ui.deviceSettings.title = uicontrol( ...
                'Parent', ui.deviceSettings.layout, ...
                'Style', 'Text', ...
                'String', 'Select Setting', ...
                'FontSize', 12);
            ui.deviceSettings.box = uicontrol( ...
                'Parent', ui.deviceSettings.layout, ...
                'Style', 'listbox', ...
                'Callback', @obj.settingsBoxClicked);
            
            set(ui.deviceList.layout, ...
                'Heights', [25, -1]);
            set(ui.deviceSettings.layout, ...
                'Heights', [25 -1]);
            
            % create the panel that will store all of the ui components
            % related to calibration input
            ui.calibrationPanel.layout = uix.VBox( ...
                'Parent', mainLayout,...
                'Spacing', 7);
            
            set(mainLayout, ...
                'Widths', [-24 -30]);
            
            obj.ui = ui;
            
            % set the default values for the 'currentSelection'
            obj.currentSelection.device = 1;
            obj.currentSelection.setting = 1;
            
            % set the default values for the TF values used to provide
            % context to the callbacks for the ui elements
            obj.ledOn = false;
            obj.inputPanelVisible = false;
            
        end
    end
    
    % Initialize things
    methods (Access = protected)
        
        function onGoing(obj)
            % get a list of the devices
            obj.createDeviceList();
            obj.grabAndAddDeviceData();
            
            obj.settingsNames = obj.getSettingsNames();
            
            %             % make a cell array of the device names
            %             obj.deviceNames = obj.getDeviceNames;
            %
            %             % make a cell array with settings names
            %             obj.settingsNames = obj.getSettingsNames;
            
            
            
            % add the device names to the device list box
            obj.populateDeviceBox;
            
            % call the callback for the device box (because this is what
            % populates the settings box and calling it will populate it
            % for the first time)
            obj.populateSettingsList(get(obj.ui.deviceList.box, 'Value'));
            
            % create the stuff for the calibration input half of the ui
            obj.createInputBox;
            
            % make the cell array of TF values denoting if given
            % device/setting combinations have been calibrated, also
            % make the cell array to store calibration values, and make the
            % cell array to store whether or not a given calibration value
            % is new or from a stored value (controls whether or not the
            % value will be added to the log)
            obj.calibratedTFs = cell(1,obj.numDevices);
            obj.calibrationValues = cell(1,obj.numDevices);
            % obj.newCalibrationValues = cell(1,obj.numDevices);
            for dev = 1:obj.numDevices
                settingsForThisDevice = numel(obj.deviceData{dev}.settings);
                obj.calibratedTFs{dev} = false(1, settingsForThisDevice);
                obj.calibrationValues{dev} = containers.Map();
                % obj.calibrationValues{dev} = zeros(1,settingsForThisDevice);
                % obj.newCalibrationValues{dev} = false(1, settingsForThisDevice);
            end
        end
        
        function createDeviceList(obj)
            
            % get devices from rig config
            devices = obj.configurationService.getDevices();
            
            % get number of devices
            num = numel(devices);
            
            % make a vector of zeros with an element for each device (the
            % zeros will become ones if the device is to be used)
            use = false(1,num);
            
            % go through each device and determine if it has a pointer to a
            % calibrationFile
            for dv = 1:num
                % look for 'calibrationFile' in device configuration maps
                use(dv) = devices{dv}.configuration.isKey('CalibrationFolder');
            end
            
            % return all devices with a calibration file pointer
            obj.deviceList = devices(logical(use));
            
        end
        
        function grabAndAddDeviceData(obj)
            % once the devices with calibration folders have been identified
            % and stored as a cell in the property 'deviceList', this
            % function can go through and load each of their data files and
            % store them to the property 'deviceData' (a cell with an
            % element for each device)
            
            % start with the rig name
            if obj.numDevices > 0
                obj.rigName = obj.getRigName(obj.deviceList{1}.configuration('CalibrationFolder'));
            end
            
            obj.deviceData = cell(1,obj.numDevices);
            for dv = 1:obj.numDevices
                % get the calibrationFile location for this given device,
                % and load the file
                folderPath = obj.deviceList{dv}.configuration('CalibrationFolder');
                
                % store the data
                obj.deviceData{dv} = struct;
                obj.deviceData{dv}.settings = readSettingsList([folderPath filesep 'settings.txt']);
                % first column values, second column dates
                calibFolder = [folderPath filesep 'calibrations'];
                obj.deviceData{dv}.calibrations = cell(numel(obj.deviceData{dv}.settings), 2);
                for i = 1:numel(obj.deviceData{dv}.settings)
                    [obj.deviceData{dv}.calibrations{i,1}, obj.deviceData{dv}.calibrations{i,2}] = ...
                        readCalibrationValue(calibFolder, obj.deviceData{dv}.settings{i});
                end
                obj.deviceData{dv}.name = readDisplayName([folderPath filesep 'displayName.txt']);
            end
            
            obj.deviceNames = obj.getDeviceNames();
            
        end
        
        function name = getRigName(obj, calibFolderPath) %#ok<INUSL>
            splits = strsplit(calibFolderPath, filesep);
            name = splits{numel(splits)-1};
            
            switch name
                case 'oldSlice'
                    name = 'Old Slice';
                case 'confocal'
                    name = 'Confocal';
                case '2Photon'
                    name = '2 Photon';
                case 'suction'
                    name = 'Suction';
            end
        end
        
        function names = getDeviceNames(obj)
            names = cell(1, obj.numDevices);
            for i = 1:obj.numDevices
                names{i} = obj.deviceData{i}.name;
            end
        end
        
        function populateDeviceBox(obj)
            % use the function that gets the device names to populate the
            % list
            set(obj.ui.deviceList.box, 'String', obj.deviceNames);
        end
        
        function populateSettingsList(obj, deviceIndex)        
            % look up the settings for the specific device using the device
            % index
            settings = obj.settingsNames{deviceIndex};
            % populate settings list
            set(obj.ui.deviceSettings.box, 'String', settings);
        end
        
        function settings = getSettingsNames(obj)
            % make a cell array with an element for each device; each
            % element itself is a cell array with an element for each
            % setting for that given device
            settings = cell(1:obj.numDevices);
            for dev = 1:obj.numDevices
                settings{dev} = obj.deviceData{dev}.settings;
            end
        end
        
        function createInputBox(obj)
            % import stuff
            import appbox.*;
            
            % this is the function that is called to update the calibration
            % input portion of the ui; it will be called when the
            % device/setting selection changes
            
            % this is the layout that will contain everything:
            %     obj.ui.calibrationPanel.layout
            % the layout is a vertical box
            
            % store it as a variable within the function for convenience
            calibrationPanel.layout = obj.ui.calibrationPanel.layout;
            mainLayout = calibrationPanel.layout;
            
            
            %%%%%%%%%%
            
            
            % make a title for the entire panel
            calibrationPanel.panelTitle = uicontrol(...
                'Parent', mainLayout, ...
                'Style', 'text', ...
                'String', obj.inputBoxTitleString, ...
                'FontSize', 12);
            
            %%%%%%%%%%
            % add a title string for calibration section
            calibrationPanel.calibrationTitle = uicontrol(...
                'Parent', mainLayout,...
                'Style', 'text', ...
                'String', 'Perform New Calibration', ...
                'FontSize', 10, ...
                'FontWeight', 'bold');
            
            %%%%%%%%%%
            % add horizontal box for 'Calibrate using' string and a box to
            % enter voltage/input
            calibrationPanel.signalEntryRow.layout = uix.HBox(...
                'Parent', mainLayout);
            % add an empty space to help with appropriate spacing
            uix.Empty('Parent', calibrationPanel.signalEntryRow.layout);
            % add a string that labels the box for voltage/input entry
            calibrationPanel.signalEntryRow.label = Label(...
                'Parent', calibrationPanel.signalEntryRow.layout, ...
                'String', 'Calibrate using (V):');
            % add an empty space to help with appropriate spacing
            uix.Empty('Parent', calibrationPanel.signalEntryRow.layout);
            % add a box for the user to enter a voltage/input
            calibrationPanel.signalEntryRow.inputBox = uicontrol(...
                'Parent', calibrationPanel.signalEntryRow.layout, ...
                'Style', 'edit', ...
                'String', '1');
            % add an empty space to help with appropriate spacing
            uix.Empty('Parent', calibrationPanel.signalEntryRow.layout);
            % adjust the widths
            set(calibrationPanel.signalEntryRow.layout, 'Widths', [-15 -40 -5 -28 -12]);
            
            %%%%%%%%%%
            % add a horizontal box for the buttons to turn the device on or
            % off
            calibrationPanel.onOffButtons.layout = uix.HBox(...
                'Parent', mainLayout);
            % add an empty space to help with appropriate spacing
            uix.Empty('Parent', calibrationPanel.onOffButtons.layout);
            % make an on button
            calibrationPanel.onOffButtons.onButton = uicontrol(...
                'Parent', calibrationPanel.onOffButtons.layout, ...
                'Style', 'pushbutton', ...
                'String', 'Turn LED on', ...
                'FontSize', 8, ...
                'Callback', @obj.onButtonCallback);
            % add an empty space to help with appropriate spacing
            uix.Empty('Parent', calibrationPanel.onOffButtons.layout);
            % make an off button
            calibrationPanel.onOffButtons.offButton = uicontrol(...
                'Parent', calibrationPanel.onOffButtons.layout, ...
                'Style', 'pushbutton', ...
                'String', 'Turn LED off', ...
                'FontSize', 8, ...
                'Callback', @obj.offButtonCallback);
            % add an empty space to help with appropriate spacing
            uix.Empty('Parent', calibrationPanel.onOffButtons.layout);
            % adjust the widths
            set(calibrationPanel.onOffButtons.layout, 'Widths', [-27 -28 -5 -28 -12]);
            
            %%%%%%%%%%
            % add a horizontal box for an input box for the user to enter
            % the power reading as well as a label for the box
            calibrationPanel.powerEntry.layout = uix.HBox(...
                'Parent', mainLayout, ...
                'Visible', 'off');
            % add an empty space to help with appropriate spacing
            uix.Empty('Parent', calibrationPanel.powerEntry.layout);
            % make a string to label the input box
            calibrationPanel.powerEntry.label = Label(...
                'Parent', calibrationPanel.powerEntry.layout, ...
                'String', 'Power (nW)');
            % add an empty space to help with appropriate spacing
            uix.Empty('Parent', calibrationPanel.powerEntry.layout);
            % make the input box
            calibrationPanel.powerEntry.inputBox = uicontrol(...
                'Parent', calibrationPanel.powerEntry.layout, ...
                'Style', 'edit');
            % add an empty space to help with appropriate spacing
            uix.Empty('Parent', calibrationPanel.powerEntry.layout);
            % control widths
            set(calibrationPanel.powerEntry.layout, 'Widths', [-31 -24 -5 -28 -12]);
            
            %%%%%%%%%%
            % add a horizontal box for an input box for thte user to enter
            % the spot size as well as a label for the box
            calibrationPanel.spotSizeEntry.layout = uix.HBox(...
                'Parent', mainLayout, ...
                'Visible', 'off');
            % add an empty space to help with appropriate spacing
            uix.Empty('Parent', calibrationPanel.spotSizeEntry.layout);
            % make a string to label the input box
            calibrationPanel.spotSizeEntry.label = Label(...
                'Parent', calibrationPanel.spotSizeEntry.layout, ...
                'String', 'Spot diam. (um)');
            % add an empty space to help with appropriate spacing
            uix.Empty('Parent', calibrationPanel.spotSizeEntry.layout);
            % make the input box
            calibrationPanel.spotSizeEntry.inputBox = uicontrol(...
                'Parent', calibrationPanel.spotSizeEntry.layout, ...
                'Style', 'edit');
            % add an empty space to help with appropriate spacing
            uix.Empty('Parent', calibrationPanel.spotSizeEntry.layout);
            % control widths
            set(calibrationPanel.spotSizeEntry.layout, 'Widths', [-20 -35 -5 -28 -12]);
            
            %%%%%%%%%%
            % make a row for the submit and change voltage buttons
            calibrationPanel.submitChangeButtons.layout = uix.HBox(...
                'Parent', mainLayout, ...
                'Visible', 'off');
            % add an empty space to help with appropriate spacing
            uix.Empty('Parent', calibrationPanel.submitChangeButtons.layout);
            % make a change voltage button
            calibrationPanel.submitChangeButtons.changeButton = uicontrol(...
                'Parent', calibrationPanel.submitChangeButtons.layout, ...
                'Style', 'pushbutton', ...
                'String', 'New voltage', ...
                'FontSize', 8, ...
                'Callback', @obj.changeVoltageButtonCallback);
            % add an empty space to help with appropriate spacing
            uix.Empty('Parent', calibrationPanel.submitChangeButtons.layout);
            % make a submit values button
            calibrationPanel.submitChangeButtons.submitButton = uicontrol(...
                'Parent', calibrationPanel.submitChangeButtons.layout, ...
                'Style', 'pushbutton', ...
                'String', 'Submit', ...
                'FontSize', 8, ...
                'Callback', @obj.inputPanelSubmitCallback);
            % add an empty space to help with appropriate spacing
            uix.Empty('Parent', calibrationPanel.submitChangeButtons.layout);
            % adjust the widths
            set(calibrationPanel.submitChangeButtons.layout, 'Widths', [-27 -28 -5 -28 -12]);
            
            %%%%%%%%%%
            % make a title string for the skip calibrating section
            calibrationPanel.skipTitle = uicontrol(...
                'Parent', mainLayout, ...
                'Style', 'text', ...
                'String', obj.skipString, ...
                'FontSize', 10, ...
                'FontWeight', 'bold');
            
            %%%%%%%%%%
            % make a box for the string that says the last calibration
            % value as well as a button that says to use that value
            calibrationPanel.skipButton.layout = uix.HBox(...
                'Parent', mainLayout);
            % add an empty space to help with appropriate spacing
            uix.Empty('Parent', calibrationPanel.skipButton.layout);
            % make a string that shows the last calibration value
            str = ['Last Calibration: ' obj.lastCalibrationDate];
            calibrationPanel.skipButton.label = Label(...
                'Parent', calibrationPanel.skipButton.layout, ...
                'String', str);
            % add an empty space to help with appropriate spacing
            uix.Empty('Parent', calibrationPanel.skipButton.layout);
            % add the button
            calibrationPanel.skipButton.button = uicontrol(...
                'Parent', calibrationPanel.skipButton.layout, ...
                'Style', 'pushbutton', ...
                'String', 'Use This', ...
                'FontSize', 9, ...
                'Callback', @obj.useOldCalibrationCallback);
            % add an empty space to help with appropriate spacing
            uix.Empty('Parent', calibrationPanel.skipButton.layout);
            set(calibrationPanel.skipButton.layout, 'Widths', [-6 -49 -5 -28 -12]);
            
            % adjust the proportions of the uielements
            %%% ADD LATER %%%
            
            % adjust main layout sizes
            set(mainLayout, 'Heights', [25, -2, -4, -4, -4, -4, -4, -2, -4]);
            
            % store the calibration panel structure
            obj.ui.calibrationPanel.layout = mainLayout;
            obj.ui.calibrationPanel = calibrationPanel;
            
            
        end
        
    end
    
    % Methods for changing or keeping tabs on the UI
    methods
        function color = determineOnColor(obj)
            % when an LED/device is turned on, the background color for the
            % editable text box where a voltage/signal is specified will
            % become a different color - this will figure out what color to
            % use based on the LED
            
            % get the current device name
            name = char(obj.deviceList{obj.currentSelection.device}.name);
            
            if regexpi(name, 'red')
                color = [1 0 0.2];
            elseif regexpi(name, 'blue')
                color = [0 0.8 1];
            elseif regexpi(name, 'green')
                color = [0 1 0.2];
            elseif regexpi(name, 'uv')
                color = [0.8 0.6 1];
            else
                color = [1 1 0.4];
            end
            
        end
        
        function updateCurrentSelectionValue(obj)
            % this will update the values stored for the current selection
            obj.currentSelection.device = get(obj.ui.deviceList.box, 'Value');
            obj.currentSelection.setting = get(obj.ui.deviceSettings.box, 'Value');
        end
        
        function value = inputsAcceptable(obj)
            % this is a function that will look at the user inputs for spot
            % size and power and determine if they are acceptable; they
            % must both be positive numbers
            
            power = str2double(get(obj.ui.calibrationPanel.powerEntry.inputBox, 'String'));
            spotSize = str2double(get(obj.ui.calibrationPanel.spotSizeEntry.inputBox, 'String'));
            
            % str2double will return NaN if the entries in the boxes were
            % not numbers
            if isnan(power) || isnan(spotSize)
                value = false;
            else
                % make sure they are both positive values
                if power > 0 && spotSize > 0
                    value = true;
                else
                    value = false;
                end
            end
        end
        
        function value = useValue(obj)
            % this function will see if the device has been calibrated, if
            % it has, it will ask the user if they want to overwrite; it
            % will then return true or false based on the user's response
            % start by making sure this device has not already been
            % calibrated
            if obj.calibratedTFs{obj.currentSelection.device}(obj.currentSelection.setting)
                % it has already been calibrated, ask about overwrite
                str = ['A calibration value for this device has already been provided today. '...
                    'Would you like to overwrite that value?'];
                choice = questdlg(str, 'Overwrite?', 'Yes', 'No', 'No');
                if strcmp(choice, 'Yes')
                    value = true;
                else
                    value = false;
                end
            else
                value = true;
            end
        end
        
        function [TF, percent] = tooDifferentFromLastCalibrationValue(obj, newValue, device, setting)
            % compare new calibration value to most recent calibration
            % value
            oldValue = obj.deviceData{device}.calibrations{setting,1};
            fractionDiff = (newValue - oldValue)/oldValue;
            if fractionDiff > obj.warningLargeChangeThreshold
                TF = true;
            else
                TF = false;
            end
            % return percent regardless
            percent = fractionDiff * 100;
            percent = round(10 * percent) / 10;
        end
        
        function value = didSelectionChange(obj)
            % when the user clicks within the listbox, the callback will be
            % called to update the right half of the ui window for the newly
            % selected device; this function will be used to first
            % sure that the user didn't just select the currently selected
            % device/setting before update the ui window
            if obj.deviceSelection == obj.currentSelection.device
                if obj.settingSelection == obj.currentSelection.setting
                    value = false;
                else
                    value = true;
                end
            else
                value = true;
            end
            
        end
        
        function makeFinalSubmitButton(obj)
            % once values have been provided for all devices (either by
            % providing new calibration values or electing to use the most
            % recent value), a submit button will appear that will allow the
            % entire set of calibration values to be submitted
            
            % there is a UI element in the location that will eventually
            % store the submit button; currently that UI element is just a
            % string instructing the user to calibrate all settings for all
            % devices; switch that ui element to a pushbutton
            set(obj.ui.instructionsSubmitLayout.uiElement, ...
                'Style', 'pushbutton', ...
                'String', 'SUBMIT CALIBRATIONS', ...
                'FontWeight', 'bold', ...
                'Callback', @obj.submitAllCalibrationsButton);
            
            set(obj.ui.instructionsSubmitLayout.layout, 'Widths', [-1 -6 -1]);
            
        end
        
        function closeUI(obj)
            % this will close the UI when calibration is complete
            % use the superclass method
            obj.delete;
        end
        
        function moveToNext(obj)
            % this function will use the stored current selection and move
            % the ui to the next possible selection (if there are
            % additional settings for the given device, it will move the
            % user to the next setting for that device, if there are not
            % any more settings to calibrate for the given device, it will
            % move the ui to the next device)
            
            % first, make sure that all of the devices have not been
            % calibrated, if they have, allow the user to submit, if not,
            % move to the next device
            allCalibrated = true;
            dev = 0;
            while allCalibrated && obj.numDevices > dev
                dev = dev + 1;
                if sum(obj.calibratedTFs{dev} == false)
                    allCalibrated = false;
                end
            end
            
            if allCalibrated
                %%%% FIGURE OUT WHAT TO DO %%%%
                
                % turn the current device off
                obj.turnOffSelectedDevice;
                
                % make a button appear to submit everything
                obj.makeFinalSubmitButton
            else
                
                % then, check to see if there are any settings for the current
                % device that have not been calibrated
                if sum(obj.calibratedTFs{obj.currentSelection.device} == false);
                    % there are some that have yet to be calibrated; find the
                    % first
                    found = false;
                    nextSetting = 0;
                    while found == false
                        nextSetting = nextSetting + 1;
                        if obj.calibratedTFs{obj.currentSelection.device}(nextSetting) == false
                            found = true;
                        end
                    end
                    
                    % since a setting was found that still needs calibrating
                    % for this device, the device doesn't need to change
                    nextDevice = obj.currentSelection.device;
                else
                    % all of the settings for the current device have been
                    % calibrated, first see if there were any settings skipped
                    % on previous devices
                    found = false;
                    nextDevice = 0;
                    while ~found
                        nextDevice = nextDevice + 1;
                        if nextDevice ~= obj.currentSelection.device
                            nextSetting = 0;
                            while ~found && nextSetting < numel(obj.calibratedTFs{nextDevice})
                                nextSetting = nextSetting + 1;
                                if ~obj.calibratedTFs{nextDevice}(nextSetting)
                                    found = true;
                                end
                            end
                        end
                    end
                end
                
                % now that the appropriate next device and setting have
                % been determined, move the ui to those devices and call
                % the callbacks for changing of those selections
                set(obj.ui.deviceList.box, 'Value', nextDevice);
                obj.deviceBoxClicked();
                set(obj.ui.deviceSettings.box, 'Value', nextSetting);
                obj.settingsBoxClicked();
                
            end
            
        end
        
        function markAsCompleted(obj, device, setting)
            % this function will make the entry for the given device/setting
            % green and bold in the listbox; this will show that it has been
            % completed
            
            % first check if the device has already been marked as completed
            if ~obj.calibratedTFs{device}(setting)
                % it has not been marked as completed (because the first
                % time a calibration value is provided for a device, the
                % calibratedTF value becomes true; but, this method is
                % called first - therefore, the only time it will be called
                % when this value is still false is the first time a
                % calibration value is provided for a device)
                obj.settingsNames{device}(setting) = ...
                    obj.makeColoredAndBold(obj.settingsNames{device}(setting));
                
                % refresh the settings list to show changes
                obj.populateSettingsList(device);
                
                % if this is the final setting that needed calibrating for
                % the given device, the device should also be marked as
                % completed; check for that here
                if sum(obj.calibratedTFs{device} == false) == 1
                    % this means there is only 1 left false - and based on
                    % statement above, it is know that it must be the
                    % current device/setting, so this device is complete
                    obj.deviceNames{device} = ...
                        obj.makeColoredAndBold(obj.deviceNames{device});
                    
                    % refresh device list to show changes
                    obj.populateDeviceBox;
                end
                
            end
            
        end
        
        function str = makeColoredAndBold(obj, str) %#ok<INUSL>
            % this will format a string using html to make it green and
            % bold
            str = strcat('<html><font color="green"><b>', str);
        end
        
        function updateInputBox(obj)
            % this will update all of the appropriate values in the input box
            
            % update the input panel title
            set(obj.ui.calibrationPanel.panelTitle, 'String', obj.inputBoxTitleString);
            
            % update section on skipping calibration
            set(obj.ui.calibrationPanel.skipTitle, 'String', obj.skipString);
            
            % update last calibration date
            str = ['Last Calibration: ' obj.lastCalibrationDate];
            set(obj.ui.calibrationPanel.skipButton.label, 'String', str);
            
            % clear all windows, set input to default value of 1
            set(obj.ui.calibrationPanel.signalEntryRow.inputBox , 'String', '1');
            set(obj.ui.calibrationPanel.powerEntry.inputBox , 'String', '');
            set(obj.ui.calibrationPanel.spotSizeEntry.inputBox , 'String', '');
            
            % remove the input portion of the panel
            obj.changeInputPanelVisibility('off');
            
        end
        
        function changeInputPanelVisibility(obj, newState)
            % this function will change the visibility of the input panel
            if strcmp(newState, 'on')
                % turn them on
                set(obj.ui.calibrationPanel.powerEntry.layout, ...
                    'Visible', 'on');
                set(obj.ui.calibrationPanel.spotSizeEntry.layout, ...
                    'Visible', 'on');
                set(obj.ui.calibrationPanel.submitChangeButtons.layout, ...
                    'Visible', 'on');
                % change the TF value to reflect the change
                obj.inputPanelVisible = true;
                
                % disable the input window for voltage/signal - this is
                % important because it makes certain symphony knows the
                % voltage/input signal used to generate any reading the user
                % enters
                set(obj.ui.calibrationPanel.signalEntryRow.inputBox, 'enable', 'off');
                
            elseif strcmp(newState, 'off')
                % turn them off
                set(obj.ui.calibrationPanel.powerEntry.layout, ...
                    'Visible', 'off');
                set(obj.ui.calibrationPanel.spotSizeEntry.layout, ...
                    'Visible', 'off');
                set(obj.ui.calibrationPanel.submitChangeButtons.layout, ...
                    'Visible', 'off');
                % change the TF value to reflect the change
                obj.inputPanelVisible = false;
                
                % if the input panel is going away, the user should be able
                % to edit the signal used for calibration, reenable that ui
                % element
                set(obj.ui.calibrationPanel.signalEntryRow.inputBox, 'enable', 'on');
            end
            
        end
    end
    
    % UI callback methods
    methods
        function settingsBoxClicked(obj,~,~)
            % callback for when settings box is clicked
            
            % only do something if the click that called the callback
            % actually changed the current selection
            if obj.didSelectionChange()
                % if selection changed, shut off led
                obj.setDeviceToValue(obj.deviceList{obj.currentSelection.device}, 0);
                
                % since the setting changed, update what is stored as the
                % current selection
                obj.updateCurrentSelectionValue;
                
                % the calibration input component of the ui needs to be
                % updated to reflect the new selection
                obj.updateInputBox;
                
                if ~isempty(obj.calibrationHistoryViewer)
                    obj.showCurrentSelectionsCalibrationHistory;
                end
                
            end
        end
        
        function deviceBoxClicked(obj,~,~)
            % callback for when devices box is clicked
            
            % only do something if the click that called the callback
            % actually changed the current selection
            if obj.didSelectionChange()
                % if device changed, shut off previous device
                obj.setDeviceToValue(obj.deviceList{obj.currentSelection.device}, 0);
                
                % if the device changed, the settings list needs to be
                % updated
                obj.populateSettingsList(get(obj.ui.deviceList.box, 'Value'));
                % select first setting
                set(obj.ui.deviceSettings.box, 'Value', 1);
                
                % since the setting changed, update what is stored as the
                % current selection (NOTE: this must be done after updating
                % the settings list, or else if will take whatever was the
                % selection from the old settings list)
                obj.updateCurrentSelectionValue;
                
                % the calibration input component of the ui needs to be
                % updated to reflect the new selection
                obj.updateInputBox;
                
                if ~isempty(obj.calibrationHistoryViewer)
                    obj.showCurrentSelectionsCalibrationHistory;
                end
                
            end
            
        end
        
        function onButtonCallback(obj, ~, ~)
            % this function will serve as the callback for the 'Turn LED
            % on' button - its behavior will depend on whether or not it is
            % the first time that LED is being turned on or whether or not
            % the user is just toggling the LED power during the
            % calibration
            
            % this callback will always turn the LED on - its behavior
            % beyond that will depend on context; start by turning the LED
            % on
            obj.turnOnSelectedDevice(obj.requestedDeviceSignal)
            
            % if it is the first time the LED has been turned on, make the
            % input panel visible, otherwise do nothing more
            if ~obj.inputPanelVisible
                % make the panel visible - note that the input panel
                % visibility function also controls the ability of the user
                % to change the voltage value (that way symphony for
                % certain knows the voltage values associated with a given
                % entered reading) - therefore, this function call will
                % also disable that uicontrol element
                obj.changeInputPanelVisibility('on');
                
            end
            
            
        end
        
        function offButtonCallback(obj, ~, ~)
            % this function will serve as the callback for the 'Turn LED
            % off' button - it will likely never need to do anything beyond
            % turning the device off
            
            % turn off the device
            obj.turnOffSelectedDevice;
            
        end
        
        function changeVoltageButtonCallback(obj, ~, ~)
            % this is the callback for the change voltage button - it
            % should make the input panel invisible (which will also
            % reenable the box in which the user can change the voltage);
            % additionally, it should clear the values in the power and
            % spot size boxes
            
            % make the panel invisible/reenable voltage box
            obj.changeInputPanelVisibility('off');
            
            % clear any entered values
            set(obj.ui.calibrationPanel.powerEntry.inputBox, 'String', '');
            set(obj.ui.calibrationPanel.spotSizeEntry.inputBox, 'String', '');
            
            % shut off the LED
            obj.turnOffSelectedDevice;
            
        end
        
        function inputPanelSubmitCallback(obj, ~, ~)
            % this is the callback for the submit button the user will use
            % after submitting their calibration values for a given
            % device/setting (not the one they will use to submit the
            % calibration once all device/setting combinations have been
            % calibrated)
            
            if obj.inputsAcceptable
                if obj.useValue
                    % the selected setting for the selected device has either
                    % not had a calibration value stored before, or the user is
                    % electing to overwrite the previous one
                    
                    % throughout a calibration session, calibration values will be
                    % stored to obj.calibrationValues, which is a cell array that
                    % has an element for each device, and each of these elements is
                    % a vector of length equal to the number of setings for that
                    % given device - calibration values will be stored here in
                    % units of nW/(input*um^2); for LEDs, this input will be V, but
                    % it will be different for other devices
                    
                    % convert the entered values into the standardized units
                    power = str2double(get(obj.ui.calibrationPanel.powerEntry.inputBox, 'String'));
                    spotDiam = str2double(get(obj.ui.calibrationPanel.spotSizeEntry.inputBox, 'String'));
                    voltage = str2double(get(obj.ui.calibrationPanel.signalEntryRow.inputBox, 'String'));
                    
                    spotSize = pi * spotDiam * spotDiam / 4;
                    
                    calibrationValue = power /(spotSize * voltage);
                    
                    dev = obj.currentSelection.device;
                    sett = obj.currentSelection.setting;
                    
                    
                    % check if this value is too different than last
                    % calibration value
                    [tooDifferent, percent] = obj.tooDifferentFromLastCalibrationValue(calibrationValue, dev, sett);
                    
                    if tooDifferent
                        % make a warning message
                        if percent > 0
                            greaterOrLess = 'greater';
                        else
                            greaterOrLess = 'less';
                        end
                        warningStr = ['The calibration value just entered is: '...
                            num2str(percent) ' percent ' greaterOrLess ' than the most '...
                            'recent calibration value for this device.  Do you '...
                            'still wish to use this value?'];
                        choice = questdlg(warningStr, 'Use value?', 'Yes', 'No', 'No');
                        if strcmp(choice, 'Yes')
                            use = true;
                        else
                            use = false;
                        end
                    else
                        % no warning or issues
                        use = true;
                    end
                    
                    if use
                        % store the new calibration value
                        obj.calibrationValues{dev}(obj.settingsNames{dev}{sett}) = calibrationValue;
                        
                        % mark the setting as calibrated in the listbox THIS
                        % MUST COME BEFORE THE calibratedTFs ARE CHANGED!!!
                        obj.markAsCompleted(dev, sett);
                        
                        % change the TF property to show that the given selection has
                        % been calibrated
                        obj.calibratedTFs{dev}(sett) = true;
                        
                        %                     % because the user is submitting a new calibration value,
                        %                     % change the associated value in obj.newCalibrationValues
                        %                     % to true
                        %                     obj.newCalibrationValues{dev}(sett) = true;
                        
                        % move to the next value
                        obj.moveToNext;
                    else
                        % user chose to not use the value because it was
                        % too different from past values
                        % clear the values
                        set(obj.ui.calibrationPanel.powerEntry.inputBox, 'String', '');
                        set(obj.ui.calibrationPanel.spotSizeEntry.inputBox, 'String', '');
                    end
                    
                end
            else
                % clear the values
                set(obj.ui.calibrationPanel.powerEntry.inputBox, 'String', '');
                set(obj.ui.calibrationPanel.spotSizeEntry.inputBox, 'String', '');
                % inputs were not acceptable, make a warning box
                str = ['The inputs just submitted were not acceptable. '...
                    'Both the power and the spot size must be positive numbers.'];
                msgbox(str);
            end
            
        end
        
        function useOldCalibrationCallback(obj, ~, ~)
            % this is the callback for the button for using the most recent
            % calibration value
            
            % check if a calibration value has already been submitted for
            % this
            if obj.useValue
                
                dev = obj.currentSelection.device;
                sett = obj.currentSelection.setting;
                
                if obj.calibrationValues{dev}.isKey(sett)
                    remove(obj.calibrationValues{dev}, sett);
                end
                
                % mark the setting as calibrated in the listbox THIS
                % MUST COME BEFORE THE calibratedTFs ARE CHANGED!!!
                obj.markAsCompleted(dev, sett);
                
                % change the TF property to show that the given selection has
                % been calibrated
                obj.calibratedTFs{dev}(sett) = true;
                
                % move to the next value
                obj.moveToNext;
                
            end
        end
        
        function submitAllCalibrationsButton(obj, ~, ~)
            % this is the callback for the submit button that will appear
            % once the user has calibrated all of the devices -  this
            % function will be responsible for saving all of the values to
            % the calibration logs for each of the devices and also for
            % saving the calibration values in the proper location within
            % symphony
            
            % store the values
            obj.storeFinalValues;
            
            % close the ui
            obj.closeUI;
        end
        
        function storeFinalValues(obj)
            % this function will store the final calibration values to symphony
            % and the logs
            
            % Get the current date and time.
            time = datetime;
            time.Format = 'uuuu-MM-dd HH:mm:ss';
            timeFull = char(time);
            time = removeTimePunctuation(timeFull);
            
            for dev = 1:obj.numDevices
                if ~obj.calibrationValues{dev}.isempty()
                    % there are new values to save
                    basePath = obj.deviceList{dev}.configuration('CalibrationFolder');
                    calibPath = [basePath filesep 'calibrations'];
                    filePath = [calibPath filesep time '.txt'];
                    
                    % open a file to write to
                    fileID = ...
                        makeFileWithRigHeader(filePath, obj.rigName, obj.deviceData{dev}.name, timeFull);
                    
                    % get the keys and go through and write the information
                    % to the file
                    keys = obj.calibrationValues{dev}.keys();
                    for i = 1:numel(keys)
                        fprintf(fileID, '%s\n', keys{i});
                        fprintf(fileID, '%.10f\n', obj.calibrationValues{dev}(keys{i}));
                    end
                    fclose(fileID);
                end
            end
            
            function time = removeTimePunctuation(time)
                time = [time(1:4) time(6:7) time(9:10) time(12:13) time(15:16) time(18:19)];
            end
            
        end
    end
    
    % Methods that control the devices
    methods
        function setDeviceToValue(obj, dev, value)
            % this will take the device object provided, and set its
            % background to the specified value
            
            % create a measurement object and assign to device background
            dev.background = symphonyui.core.Measurement(value, dev.background.displayUnits);
            % apply background
            dev.applyBackground();
            
            % whenever the device background is set to a nonzero value,
            % make the on button colored
            if value == 0
                set(obj.ui.calibrationPanel.onOffButtons.onButton, 'BackgroundColor', obj.defaultEditBoxColor);
            elseif value > 0
                set(obj.ui.calibrationPanel.onOffButtons.onButton, 'BackgroundColor', obj.determineOnColor);
            end
            
        end
        
        function turnOffSelectedDevice(obj)
            % this function will figure out what the current selected device
            % is and shut it off
            
            % turn off the device
            obj.setCurrentDeviceToValue(0);
            
            % change the TF property to reflect the LED being off
            obj.ledOn = false;
            
            
        end
        
        function turnOnSelectedDevice(obj, signal)
            % this function will figure out what the currently selected
            % device is and turn it on using the signal provided as an
            % input argument (units will vary based on device type, e.g. V
            % for LEDs)
            
            % turn on the device
            obj.setCurrentDeviceToValue(signal);
            
            % change the TF property to reflect sthe LED being on
            obj.ledOn = true;
            
        end
        
        function setCurrentDeviceToValue(obj, value)
            % there is some overlap between turning the current device off
            % and on so both are performed with this function
            
            % get the currently selected device
            dev = obj.deviceList{obj.currentSelection.device};
            
            % set background
            obj.setDeviceToValue(dev, value);
            
        end
    end
    
    % For dependent properties
    methods
        function value = get.deviceSelection(obj)
            value = get(obj.ui.deviceList.box, 'Value');
        end
        
        function value = get.settingSelection(obj)
            value = get(obj.ui.deviceSettings.box, 'Value');
        end
        
        function value = get.numDevices(obj)
            % get the number of devices that are needing calibrating
            value = numel(obj.deviceList);
        end
        
        function value = get.requestedDeviceSignal(obj)
            % this simply returns the value in the box where the user
            % requests a signal to use for calibration - it was made into
            % a dependent parameter for clarity above
            value = str2double(get(obj.ui.calibrationPanel.signalEntryRow.inputBox, 'String'));
            
        end
        
        function value = get.tickMarkPath(obj) %#ok<MANU>
            % the tick mark image is in the same folder as the file of this
            % calibrator
            value =  mfilename('fullpath');
            [value,~,~] = fileparts(value);
            value = [value '\tick.png'];
        end
        
        function value = get.skipString(obj)
            % figure out strings for device name and setting to use in
            % title; make the title string
            value = ['Skip calibrating ' obj.deviceName ', ' obj.settingName];
        end
        
        function value = get.lastCalibrationDate(obj)
            % get the last calibration date for the currently selected device
            device = obj.currentSelection.device;
            setting = obj.currentSelection.setting;
            longDate = obj.deviceData{device}.calibrations{setting, 2};
            value = longDate(1:8);
        end
        
        function value = get.inputBoxTitleString(obj)
            % figure out strings for device name and setting to use in
            % title; make the title string
            value = ['Calibrate ' obj.deviceName ', ' obj.settingName];
        end
        
        function value = get.deviceName(obj)
            deviceName = obj.getDeviceNames;
            value = deviceName{obj.deviceSelection};
        end
        
        function value = get.settingName(obj)
            deviceSetting = obj.deviceData{obj.deviceSelection}.settings;
            value = deviceSetting{obj.settingSelection};
        end
    end
    
    
    %%%%%% THESE NEED TO BE UPDATED TO WORK WITH THE NEW FILE SYSTEM
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % methods to control the calibration history viewer interaction
    methods
        
        function viewCalibrationHistoryCallback(obj, ~, ~)
            % launch the viewer (if not already launched) and have it
            % display calibration history for currently selected device and
            % setting
            
            if isempty(obj.calibrationHistoryViewer)
                
                if obj.checkAllSameRig
                    % get current rig
                    devicePath = obj.deviceList{1}.configuration('CalibrationFolder');
                    [folderPath, ~, ~] = fileparts(devicePath);
                    folders = strsplit(folderPath, filesep);
                    rig = folders{end};
                    
                    % get device and setting
                    [device, setting] = obj.getCurrentDeviceAndSettingForCalibrationHistory;
                    % launch the viewer and have it show given device/setting
                    obj.calibrationHistoryViewer = calibrationHistoryViewer(rig,device,setting); %#ok<CPROP>
                    
                    % set the callback for the deletion of the calibration history
                    % window so that the calibrator module will know if it has been
                    % deleted and needs regenerating
                    set(obj.calibrationHistoryViewer.ui.figure, ...
                        'DeleteFcn', @obj.calibrationHistoryClosingCallback)
                else
                    % warn that from multiple rigs
                    error(['The calibration viewer cannot be launched. '...
                        'All of the devices currently being calibrated '...
                        'do not point to the same rig folder.']);
                end
            end
        end
        
        function value = checkAllSameRig(obj)
            % when the calibration history viewer is launched, it takes a
            % rig name as a input; it will just pull the rig name from one
            % of the calibration data paths on one of the devices; this
            % function makes certain that the identified rig for all of the
            % functions is the same
            
            numDevices = numel(obj.deviceData);
            if numDevices == 1
                value = true;
            else
                value = true;
                rigName = [];
                for dv = 1:numDevices
                    devicePath = obj.deviceList{dv}.configuration('CalibrationFolder');
                    [folderPath, ~, ~] = fileparts(devicePath);
                    folders = strsplit(folderPath, filesep);
                    deviceFolder = folders{end};
                    if dv == 1
                        rigName = deviceFolder;
                    else
                        if ~strcmpi(rigName, deviceFolder)
                            value = false;
                        end
                    end
                end
            end
        end
        
        function [device, setting] = getCurrentDeviceAndSettingForCalibrationHistory(obj)
            % get the device
            deviceIndex = get(obj.ui.deviceList.box, 'Value');
            filePath = obj.deviceList{deviceIndex}.configuration('CalibrationFolder');
            [~,device,~] = fileparts(filePath);
            % get the setting
            settingIndex = get(obj.ui.deviceSettings.box, 'Value');
            setting = obj.settingsNames{deviceIndex}{settingIndex};
        end
        
        function showCurrentSelectionsCalibrationHistory(obj)
            [device, setting] = obj.getCurrentDeviceAndSettingForCalibrationHistory;
            obj.calibrationHistoryViewer.changeToDeviceSetting(device,setting);
        end
        
        function calibrationHistoryClosingCallback(obj, ~, ~)
            % this will add a callback for the closure of the figure window
            % the callback will delete the calibration history object
            obj.calibrationHistoryViewer = [];
        end
        
    end
    
    
    
    %%%%%% FUTURE FEATURES %%%%%%
    methods
        %%%%
        function value = correctForSpectralSensitivity(obj, input, spectrum)
            %%%%%% THIS FUNCTION WILL EVENTUALLY BE USED TO CORRECT FOR THE
            %%%%%% SPECTRAL SENSITIVITY OF A CALIBRATION DEVICE RELATIVE TO
            %%%%%% THE OUTPUT OF THE CALIBRATED DEVICE - CURRENTLY,
            %%%%%% EVERYTHING SHOULD RUN FINE WITHOUT IT
            value = input;
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%% THE CODE BELOW IS FOR THE ADVANCED SETTINGS WINDOW %%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    methods
        
        function advancedSettingsCallback(obj, ~, ~)
            % this will be the callback for the advanced settings button
            if obj.advancedSettingsFunctional
                % create a structure for all ui-related handles
                obj.advancedSettingsWindow.ui = struct;
                % create the UI
                obj.createAdvancedSettingsUI;
            end
        end
        
        function createAdvancedSettingsUI(obj)
            % import symphony ui stuff
            import appbox.*;
            
            % make the figure
            obj.advancedSettingsWindow.ui.figureHandle = figure(...
                'MenuBar', 'none', ...
                'Toolbar', 'none', ...
                'Name', 'Advanced Settings', ...
                'Position', screenCenter(500, 125), ...
                'WindowStyle', 'modal', ...
                'DeleteFcn', @obj.deleteAdvancedSettingsWindowCallback);
            
            % make main layout a vertical box
            obj.advancedSettingsWindow.ui.mainLayout = uix.VBox(...
                'Parent', obj.advancedSettingsWindow.ui.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 11);
            
            % add a horizontal box for the title
            obj.advancedSettingsWindow.ui.titleBox.layout = uix.HBox(...
                'Parent', obj.advancedSettingsWindow.ui.mainLayout);
            % add empty space to the left of the title
            uix.Empty('Parent', obj.advancedSettingsWindow.ui.titleBox.layout);
            % make the title
            obj.advancedSettingsWindow.ui.titleBox.title = uicontrol(...
                'Parent', obj.advancedSettingsWindow.ui.titleBox.layout, ...
                'Style', 'text', ...
                'FontSize', 12, ...
                'FontWeight', 'bold', ...
                'String', 'Calibration Module Advanced Settings');
            % make an empty space to the right of the title
            uix.Empty('Parent', obj.advancedSettingsWindow.ui.titleBox.layout);
            % adjust title box widths
            set(obj.advancedSettingsWindow.ui.titleBox.layout, 'Widths', [-1 -10 -1]);
            
            
            % make a horizontal box for the spectral correction ui
            % component
            spectralCorrectionUIStrField = 'spectralCorrectionBox';
            
            spectralCorrectionLayout = uix.HBox(...
                'Parent', obj.advancedSettingsWindow.ui.mainLayout);
            % create the spectral correction component
            obj.createSpectralCorrectionUIComponent(spectralCorrectionLayout, spectralCorrectionUIStrField)
            
            % make a horizontal box for the button that will close the
            % window
            obj.advancedSettingsWindow.ui.closeWindowButton.layout = uix.HBox(...
                'Parent', obj.advancedSettingsWindow.ui.mainLayout);
            % make an empty space to the left of the button
            uix.Empty('Parent', obj.advancedSettingsWindow.ui.closeWindowButton.layout);
            % make the button
            obj.advancedSettingsWindow.ui.closeWindowButton.button = uicontrol(...
                'Parent', obj.advancedSettingsWindow.ui.closeWindowButton.layout, ...
                'Style', 'pushbutton', ...
                'String', 'Close', ...
                'Callback', @obj.closeAdvancedSettingsWindowCallback);
            % make an empty space to the right of the button
            uix.Empty('Parent', obj.advancedSettingsWindow.ui.closeWindowButton.layout);
            % set widths for the close button horizontal box
            set(obj.advancedSettingsWindow.ui.closeWindowButton.layout, 'Widths', [-4 -2 -4]);
            
            % set heights for the main layout
            set(obj.advancedSettingsWindow.ui.mainLayout, 'Heights', [20 -1 30]);
        end
        
        function closeAdvancedSettingsWindowCallback(obj, ~, ~)
            % this is the callback for the button that will close the
            % figure window and return the user to the calibration module
            close(obj.advancedSettingsWindow.ui.figureHandle)
            
        end
        
        function deleteAdvancedSettingsWindowCallback(obj, ~, ~)
            % called when advanced settings window is deleted, cleans
            % things up
            
            % clear the advancedSettingsWindow struct
            obj.advancedSettingsWindow = struct;
            
        end
        
        function createSpectralCorrectionUIComponent(obj, hbox, uiStrField)
            % this will take a horizontal box as a input: hbox, and make
            % the spectral correction ui component within it
            handles = struct;
            handles.layout = hbox;
            
            %%% SET DEFAULT VALUE %%%
            
            % control spacing of the horizontal box
            set(handles.layout, ...
                'Spacing', 11);
            
            % make an empty space to the left
            uix.Empty('Parent', handles.layout);
            % make an instructions string
            instr = ['To correct for the spectral sensitivity of a given device '...
                'select it and press ''Apply''.'];
            handles.instructions = uicontrol(...
                'Parent', handles.layout, ...
                'Style', 'text', ...
                'FontSize', obj.advancedSettingsInstructionsFontSize, ...
                'String', instr);
            % make a dropdown list with device names for which there are
            % corrections
            handles.devicesDropdown.layout = uix.VBox('Parent', handles.layout);
            uix.Empty('Parent', handles.devicesDropdown.layout);
            deviceOptions = ['none' obj.getCorrectableDevicesList];
            handles.devicesDropdown.dropdown = uicontrol(...
                'Parent', handles.devicesDropdown.layout, ...
                'Style', 'popupmenu', ...
                'String', deviceOptions, ...
                'Value', obj.getSpectralCorrectionSetting);
            uix.Empty('Parent', handles.devicesDropdown.layout);
            % center the dropdown
            set(handles.devicesDropdown.layout, 'Heights', [-1 -4 -1]);
            % make an apply button
            handles.applyButton = uicontrol(...
                'Parent', handles.layout, ...
                'Style', 'pushbutton', ...
                'String', 'Apply', ...
                'Callback', @obj.applySpectralCorrectionCallback);
            
            
            % make an empty space to the right
            uix.Empty('Parent', handles.layout);
            
            % set widths for this ui component
            set(handles.layout, 'Widths', [5 -40 -16 -10 5]);
            
            % store the handles for these ui elements
            obj.advancedSettingsWindow.ui.(uiStrField) = handles;
        end
        
        function value = getSpectralCorrectionSetting(obj)
            % when the UI is made, this will determine what the default
            % option in the correctable devices dropdown is - it will
            % return the index for that value
            options = ['none' obj.getCorrectableDevicesList];
            selection = obj.calibrationDeviceName;
            
            if strcmp(selection, '')
                value = 1;
            else
                found = false;
                dev = 1;
                num = length(options);
                while found == false && dev < num
                    dev = dev + 1;
                    if strcmp(options{dev}, selection)
                        found = true;
                        value = dev;
                    end
                end
                
            end
            
        end
        
        function applySpectralCorrectionCallback(obj, ~, ~)
            % this is the callback for the apply button from the spectral
            % correction component of the ui - it will store the user's
            % selection back to the calibration module
            
            % the user could have selected a specific device or selected
            % 'none', check if none was the selection
            options = get(obj.advancedSettingsWindow.ui.spectralCorrectionBox.devicesDropdown.dropdown, 'String');
            selection = options{get(obj.advancedSettingsWindow.ui.spectralCorrectionBox.devicesDropdown.dropdown, 'Value')};
            
            if strcmp(selection, 'none')
                % the user does not want a correction to be used
                
                % set to false the boolean on the calibration module object that
                % controls if a spectral sensitivity correction is used
                obj.useSpectralSensitivityCorrection = false;
                % make the string that contains the name of the device for
                % the correction (a property of the calibration module
                % object) an empty string
                obj.calibrationDeviceName = '';
            else
                % the user selected a specific device
                
                % set to true the boolean on the calibration module object that
                % controls if a spectral sensitivity correction is used
                obj.useSpectralSensitivityCorrection = true;
                % store the name of the device the user selected to the
                % 'calibrationDeviceName' property of the calibration
                % module object
                obj.calibrationDeviceName = selection;
            end
            
        end
        
        function value = getCorrectableDevicesList(obj)
            % this function will get a list of the devices for which there
            % are corrections for their spectral sensitivity
            
            %%%% A FILE NEEDS TO BE MADE THAT HAS THE CORRECTIONS, BUT
            %%%% CURRENTLY THIS WILL JUST RETURN A CELL ARRAY OF STRINGS TO
            %%%% ALLOW THE REST OF THE UI TO BE DEVELOPED
            
            value = {'photometer 1', 'photometer 2'};
        end
        
    end
    
end