$framework = '4.0'

. .\psake_ext.ps1

properties {
    $versionMajor = 1
    $versionMinor = 0
    $versionBuild = 0
    $year = (Get-Date).year
    $fullVersion = "$versionMajor.$versionMinor.$versionBuild.1"

    $configuration = "Release"

    $baseDir = ".\.."
    $srcDir = "$baseDir\src"
    $testDir = "$baseDir\test"
    $outputDir = "$baseDir\output"
    $collectDir = "$outputDir\collect"
    $scriptDir = "$baseDir\scripts"

    $solutionFile = "$baseDir\Uncas.NowSite.sln"
    $nunitFolder = "$baseDir\packages\NUnit.2.5.10.11092\tools"
    $nunitExe = "$nunitFolder\nunit-console.exe"
    $nugetExe = "$baseDir\.nuget\nuget.exe"

    $websitePort = "963"
    $websitePath = "$baseDir\src\Uncas.WebTester.Web"
    $websiteName = "WebTesterWeb"
}

task default -depends Publish

task Clean {
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
        -file "$baseDir\VersionInfo.cs" `
        -company "Uncas" `
        -product "Uncas.NowSite" `
        -version "$versionMajor.$versionMinor.$versionBuild" `
        -copyright "Copyright (c) $year, Ole Lynge Sørensen"
}

task Compile -depends Init {
    msbuild $solutionFile /p:Configuration=$configuration
}

task Test -depends Compile {
    Run-Test "Uncas.NowSite.Tests" $outputDir
}

task Collect -depends Init {
    copy $scriptDir\*.* $collectDir

    $fullVersion = $script:fullVersion
    $buildContent = "`$task = `$args[0]`
`
`$psenVersion = $fullVersion`
`
`$psenPath = `".\packages\psen.$psenVersion\tools\psen.ps1`"`
if (!(Test-Path `$psenPath))`
{`
    nuget install psen -o packages -version `$psenVersion`
}`
`
& `$psenPath `$task"

    New-Item $collectDir\build.ps1 -type file -value $buildContent -force
}

task Pack -depends Collect {
    $nuspecFile = "$scriptDir\psen.nuspec"
    $nuspecFile
    $script:fullVersion
    & $nugetExe pack $nuspecFile -Version $script:fullVersion -OutputDirectory $outputDir
}

task Publish -depends Pack {
#    & $nugetExe push "$outputDir\icrawl.$fullVersion.nupkg"
    copy $outputDir\*.nupkg C:\NuGetPackages
}
