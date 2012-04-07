$framework = '4.0'

. .\psake_ext.ps1

properties {
    $versionMajor = 0
    $versionMinor = 1
    $versionBuild = 0
    $baseDir = Resolve-Path ".\.."
    $solutionFileItem = (Get-Item $baseDir\*.sln)
    $solutionFile = $solutionFileItem.FullName

    $solutionFileNameParts = $solutionFileItem.Name.Split('.')
    $companyName = $solutionFileNameParts[0]
    $productName = $solutionFileNameParts[1]

    $year = (Get-Date).year
    $fullVersion = "$versionMajor.$versionMinor.$versionBuild.1"

    $configuration = "Release"

    $srcDir = "$baseDir\src"
    $testDir = "$baseDir\test"
    $outputDir = "$baseDir\output"
    $collectDir = "$outputDir\collect"
    $scriptDir = "$baseDir\scripts"

    $nunitFolder = "$baseDir\packages\NUnit.2.5.10.11092\tools"
    $nunitExe = "$nunitFolder\nunit-console.exe"
    $nugetExe = "$baseDir\.nuget\nuget.exe"
    $defaultWebsitePort = 8100
}

task default -depends Install, TestPacks, Test

task Clean -depends UnmountWebsites {
    if (Test-Path $collectDir)
    {
        rmdir -force -recurse $collectDir
    }
    if (Test-Path $outputDir)
    {
        rmdir -force -recurse $outputDir
    }
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
        -file "$srcDir\VersionInfo.cs" `
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

task Publish -depends Pack, Test {
    $nupackages = gci $outputDir -include *.nupkg
    if (!$nupackages) { return }
    "Publishing the following NuGet packages: $nupackages"
    foreach ($nupackage in $nupackages)
    {
        #& $nugetExe push $nupackage
    }
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
        $physicalPath = $webProject.FullName
        "Mounts the web project $webProjectName at port $websitePort."
        Add-Site $webProjectName $physicalPath "http://*:$websitePort"
        $websitePort++
    }
}