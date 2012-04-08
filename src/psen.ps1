$task = $args[0]
"Task: $task"
$psakeVersion = "4.0.1.0"
"Psake version: $psakeVersion"
nuget install psake -version $psakeVersion -o packages
"Importing psake module"
Import-Module .\packages\psake.$psakeVersion\tools\psake.psm1
"Calling default"
& ".\packages\psake.$psakeVersion\tools\psake.cmd" ".\packages\psen.@PsenVersion@\tools\default.ps1" $task