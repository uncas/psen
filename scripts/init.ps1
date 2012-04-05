param($installPath, $toolsPath, $package, $project)

$rootPath = "$installPath\..\.."

#"Nuget debug:" > C:\temp\nugetdebug.txt
#"InstallPath=$installPath" >> C:\temp\nugetdebug.txt
#"ToolsPath=$toolsPath" >> C:\temp\nugetdebug.txt
#"Package=$package" >> C:\temp\nugetdebug.txt
#"Project=$project" >> C:\temp\nugetdebug.txt
#"RootPath=$rootPath" >> C:\temp\nugetdebug.txt

Copy $toolsPath\build.ps1 $rootPath
