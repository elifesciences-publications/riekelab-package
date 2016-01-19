classdef (Abstract) RiekeRigDescription < symphonyui.core.descriptions.RigDescription
    % rig description superclass that will serve to delete the file
    % that contains information about the rig and is used to make a
    % customized list of fields for the source description window; also will
    % save a file with information about the rig (if called by the subclass)
    
    properties
        rigDetailsFilePath = 'C:\Users\Client Admin\Desktop\updatedCalibrationModule\calibrationUtilities\symphony\rigDetails.mat';
    end
    
    methods
        
        function obj = RiekeRigDescription()
            if exist(obj.rigDetailsFilePath, 'file')
                delete(obj.rigDetailsFilePath);
            end
        end
        
        function saveRigInfoFile(obj)
            % this will save information about the calibrated devices on
            % the rig; it will do so by going through and looking for
            % devices that have configuration parameters related to
            % calibration
            
            numDevices = numel(obj.devices);
            calibratedTFs = false(1,numDevices);
            for dv = 1:numDevices
                if obj.devices{dv}.configuration.isKey('CalibrationFolder')
                    calibratedTFs(dv) = true;
                end
            end
            
            if sum(calibratedTFs)
                calibratedDevices = obj.devices(calibratedTFs);
                numDevices = numel(calibratedDevices);
                deviceNames = cell(1,numDevices);
                deviceSettings = containers.Map;
                deviceCalibrationFolders = cell(1,numDevices);
                for dv = 1:numDevices
                    deviceNames{dv} = calibratedDevices{dv}.name;
                    devicePath = calibratedDevices{dv}.configuration('CalibrationFolder');
                    deviceSettings(deviceNames{dv}) = ...
                        readSettingsList([devicePath filesep 'settings.txt']);
                    deviceCalibrationFolders{dv} = devicePath;
                end
                save(obj.rigDetailsFilePath, 'deviceNames', 'deviceSettings', 'deviceCalibrationFolders');
            end
            
        end
        
    end
    
end

