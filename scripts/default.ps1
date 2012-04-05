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

task Collect -depends Compile {
    $files = @()
    $files += "$srcDir\Uncas.WebTester.ConsoleApp\bin\Release\Autofac.dll"
    $files += "$srcDir\Uncas.WebTester.ConsoleApp\bin\Release\Uncas.WebTester.ConsoleApp.exe"
    $files += "$srcDir\Uncas.WebTester.ConsoleApp\bin\Release\Uncas.WebTester.ConsoleApp.exe.config"
    $files += "$srcDir\Uncas.WebTester.NUnitRunner\bin\Release\Uncas.WebTester.NUnitRunner.dll"
    $files += "$srcDir\Uncas.WebTester.NUnitRunner\bin\Release\nunit.framework.dll"
    $files += "$srcDir\Uncas.WebTester\bin\Release\HtmlAgilityPack.dll"
    $files += "$srcDir\Uncas.WebTester\bin\Release\Uncas.WebTester.dll"
    $files += "$testDir\Uncas.WebTester.Tests.SimpleTestProject\bin\Release\Uncas.WebTester.Tests.SimpleTestProject.dll"
    $files += "$testDir\Uncas.WebTester.Tests.SimpleTestProject\bin\Release\Uncas.WebTester.Tests.SimpleTestProject.dll.config"
    copy $files $collectDir
}

task Pack -depends Init {
    $nuspecFile = "$scriptDir\psen.nuspec"
    $nuspecFile
    $script:fullVersion
    & $nugetExe pack $nuspecFile -Version $script:fullVersion -OutputDirectory $outputDir
}

task Publish -depends Pack {
#    & $nugetExe push "$outputDir\icrawl.$script:fullVersion.nupkg"
    copy $outputDir\*.nupkg C:\NuGetPackages
}
