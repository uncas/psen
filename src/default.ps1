. .\psake_ext.ps1

properties {
    $versionMajor = 0
    $versionMinor = 1
    $versionBuild = 0
    $configuration = "Release"

    $baseDir = Resolve-Path ".\..\..\.."
    $srcDir = "$baseDir\src"
    $testDir = "$baseDir\test"
    $outputDir = "$baseDir\output"
    $collectDir = "$outputDir\collect"
    $scriptDir = "$baseDir\scripts"

    $defaultWebsitePort = 8100

    # Loads custom properties, from custom.ps1 which is put in version control:
    $customPath = "$scriptDir\custom.ps1"
    if (Test-Path $customPath) {
        . $customPath
        if (Test-Path function:LoadCustomProperties) { LoadCustomProperties }
    }

    # Loads private properties, from private.ps1 which is *not* put in version control:
    $privatePath = "$scriptDir\private.ps1"
    # Allows path to private properties to be overridden in custom.ps1:
    if ($script:privatePath) { $privatePath = $script:privatePath }
    if (Test-Path $privatePath) {
        . $privatePath
        if (Test-Path function:LoadPrivateProperties) { LoadPrivateProperties }
    }

    # Assigns values from custom and private properties:
    if ($script:configuration) { $configuration = $script:configuration }
    if ($script:versionMajor) { $versionMajor = $script:versionMajor }
    if ($script:versionMinor) { $versionMinor = $script:versionMinor }
    if ($script:versionBuild) { $versionBuild = $script:versionBuild }
    if ($script:defaultWebsitePort) { $defaultWebsitePort = $script:defaultWebsitePort }

    $solutionFileItem = (Get-Item $baseDir\*.sln)
    "SolutionFile:$solutionFileItem"
    $solutionFile = $solutionFileItem.FullName

    $solutionFileNameParts = $solutionFileItem.Name.Split('.')
    $companyName = $solutionFileNameParts[0]
    $productName = $solutionFileNameParts[1]

    $year = (Get-Date).year
    $fullVersion = "$versionMajor.$versionMinor.$versionBuild.1"

    $nunitFolder = "$baseDir\packages\NUnit.2.5.10.11092\tools"
    $nunitExe = "$nunitFolder\nunit-console.exe"
    $nugetExe = "$baseDir\.nuget\nuget.exe"
}

task default -depends Install, TestPacks, Test

task Clean -depends UnmountWebsites {
    Clean-Folder $collectDir
    Clean-Folder $outputDir
    gci -r -include *~ | Remove-Item
}

task Initialize-ConfigFiles {
}

task Init -depends Clean,Initialize-ConfigFiles {
    if (!(Test-Path $outputDir))
    {
        mkdir $outputDir
    }
    if (!(Test-Path $collectDir))
    {
        mkdir $collectDir
    }

    Generate-Assembly-Info `
        -file "$outputDir\VersionInfo.cs" `
        -company $companyName `
        -product $productName `
        -version "$versionMajor.$versionMinor.$versionBuild" `
        -copyright "Copyright (c) $year, $companyName"
}

task Compile -depends Init {
    msbuild $solutionFile /p:Configuration=$configuration
}

task Test -depends Compile {
    if (!(Test-Path $testDir)) { return }
    $testProjects = gci $testDir | Where-Object {$_.Name.EndsWith(".Tests")}
    if (!$testProjects) { return }
    "Testing with the following test projects: $testProjects"
    foreach ($testProject in $testProjects)
    {
        Run-Test $testProject $outputDir
    }
}

task Collect -depends Compile {
    $webProjects = gci $srcDir | Where-Object {$_.Name.EndsWith(".Web")}
    if (!$webProjects) { return }
    "Collecting the following web projects: $webProjects"
    foreach ($webProject in $webProjects)
    {
        Copy-WebApplication $srcDir $webProject $collectDir
    }
}

task GenerateNuspec -depends Collect {
    $dirs = gci $collectDir
    if (!$dirs) { return }
    foreach ($dir in $dirs)
    {
        $projectPath = $dir.FullName
        $projectName = $dir.Name
        $nuspecPath = "$collectDir\$projectName.nuspec"
        "Nuspecpath: $nuspecPath"
        $nuspec = "<?xml version=`"1.0`"?>`
<package>`
  <metadata>`
    <id>$projectName</id>`
    <version>$script:fullVersion</version>`
    <title>$projectName</title>`
    <authors>$companyName</authors>`
    <owners>$companyName</owners>`
    <copyright>Copyright $year</copyright>`
    <description>$projectName, a part of $productName</description>`
  </metadata>`
  <files>`
    <file src=`"$projectPath\**\*.*`" target=`"Content`" />`
  </files>`
</package>"
        "Nuspec: $nuspec"
        out-file -filePath $nuspecPath -encoding UTF8 -inputObject $nuspec
    }
}

task PackCollected -depends GenerateNuspec {
    $nuspecFiles = gci $collectDir | Where-Object {$_.Name.EndsWith(".nuspec")}
    if (!$nuspecFiles) { return }
    "Packaging for the following nuspecs: $nuspecFiles"
    foreach ($nuspecFile in $nuspecFiles)
    {
        & $nugetExe pack $nuspecFile.FullName -Version $script:fullVersion -OutputDirectory $outputDir
    }
}

task Pack -depends PackCollected {
    if (!(Test-Path $scriptDir)) { return }
    $nuspecFiles = gci $scriptDir | Where-Object {$_.Name.EndsWith(".nuspec")}
    if (!$nuspecFiles) { return }
    "Packaging for the following nuspecs: $nuspecFiles"
    foreach ($nuspecFile in $nuspecFiles)
    {
        & $nugetExe pack $nuspecFile.FullName -Version $script:fullVersion -OutputDirectory $outputDir
    }
}

task TestPacks -depends Pack {
    $nuspecs = gci $collectDir | Where-Object {$_.Name.EndsWith(".nuspec")}
    if (!$nuspecs) { return }
    foreach ($nuspec in $nuspecs)
    {
        $packageName = $nuspec.Name.Replace(".nuspec", "")
        & $nugetExe install $packageName -Source $outputDir -o $outputDir\packageTests
    }
}

task PublishNuGet -depends Pack, Test {
    $nupackages = gci $outputDir -include *.nupkg
    if (!$nupackages) { return }
    "Publishing the following NuGet packages: $nupackages"
    foreach ($nupackage in $nupackages)
    {
        #& $nugetExe push $nupackage
    }
}

task Publish -depends Pack, Test, PublishNuGet {
    if (Test-Path function:CustomPublish) { CustomPublish }
}

function GetWebProjects
{
    return gci $collectDir | Where-Object {$_.Name.EndsWith(".Web")}
}

task UnmountWebsites {
    if (!(Test-Path $collectDir)) { return }
    $webProjects = GetWebProjects
    if (!$webProjects) { return }
    foreach ($webProject in $webProjects)
    {
        Delete-Site $webProject.Name
    }
}

task Install -depends Collect, UnmountWebsites {
    $webProjects = GetWebProjects
    if (!$webProjects) { return }
    $websitePort = $defaultWebsitePort
    foreach ($webProject in $webProjects)
    {
        $webProjectName = $webProject.Name
        "Deleting existing site: $webProjectName"
        Delete-Site $webProjectName
        $physicalPath = $webProject.FullName
        "Mounts the web project $webProjectName at port $websitePort."
        Add-Site $webProjectName $physicalPath "http://*:$websitePort"
        $websitePort++
    }
}