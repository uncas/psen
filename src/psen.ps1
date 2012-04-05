$task = $args[0]

$psakeVersion = "4.0.1.0"

$currentDir = Resolve-Path ".\"
"$currentDir"

nuget install psake -version $psakeVersion -o packages

Import-Module .\packages\psake.$psakeVersion\tools\psake.psm1

& ".\packages\psake.$psakeVersion\tools\psake.cmd" default.ps1 $task