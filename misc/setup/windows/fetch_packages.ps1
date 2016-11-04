param([String]$variant="minimal") #Must be the first statement in your script
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$modulesPath = join-path (get-item $scriptPath ).parent.parent.parent.FullName "modules"
Write-Host "Modules Root Directory: $modulesPath"


Write-Host "Fetching Ubitrack Core Modules"

cd $modulesPath

git clone https://github.com/Ubitrack/utcore.git utcore
git clone https://github.com/Ubitrack/utvision.git utvision
git clone https://github.com/Ubitrack/utdataflow.git utdataflow
git clone https://github.com/Ubitrack/utfacade.git utfacade
git clone https://github.com/Ubitrack/component_core.git component_core
git clone https://github.com/Ubitrack/component_vision.git component_vision
git clone https://github.com/Ubitrack/component_visualization.git component_visualization
git clone https://github.com/Ubitrack/device_camera_directshow.git device_camera_directshow
git clone https://github.com/Ubitrack/device_camera_directshow.git device_camera_flycapture
git clone https://github.com/Ubitrack/device_camera_directshow.git device_tracker_art
