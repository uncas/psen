$task = $args[0]
$psakeVersion = "4.1.0"
Import-Module .\packages\psake.$psakeVersion\tools\psake.psm1
& ".\packages\psake.$psakeVersion\tools\psake.cmd" ".\packages\psen.@PsenVersion@\tools\default.ps1" $task