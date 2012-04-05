#param($installPath, $toolsPath, $package, $project)

#Copy the -vsdoc-para file over the -vsdoc file
#$projectFolder = Split-Path -Parent $project.FileName
#$projectFolder = $project.Properties.Item("FullPath").Value
#$paraVsDocPath = Join-Path $toolsPath jquery-1.7.1-vsdoc-para.js
#$vsDocPath = Join-Path $projectFolder Scripts\jquery-1.7.1-vsdoc.js
#Copy-Item $paraVsDocPath $vsDocPath -Force

"Nuget debug:" > C:\temp\nugetdebug.txt

"InstallPath=$installPath" >> C:\temp\nugetdebug.txt
"ToolsPath=$toolsPath" >> C:\temp\nugetdebug.txt
"Package=$package" >> C:\temp\nugetdebug.txt
"Project=$project" >> C:\temp\nugetdebug.txt

#$installPath = "d:\projects\uncas\psen\scripts"

$rootPath = "$installPath\..\.."
"RootPath=$rootPath" >> C:\temp\nugetdebug.txt

#$toolsPath = "d:\projects\uncas\psen\scripts"

Copy $toolsPath\init.ps1 $rootPath