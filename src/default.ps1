$framework = '4.0'

. .\psake_ext.ps1

properties {
    $versionMajor = 1
    $versionMinor = 0
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
}

task default -depends Compile

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
        -company $companyName `
        -product $productName `
        -version "$versionMajor.$versionMinor.$versionBuild" `
        -copyright "Copyright (c) $year, $companyName"
}

task Compile -depends Init {
    msbuild $solutionFile /p:Configuration=$configuration
}

task Test -depends Compile {
    Run-Test "Uncas.NowSite.Tests" $outputDir
}

task Collect -depends Init {
}

task Pack -depends Collect {
    #& $nugetExe pack $nuspecFile -Version $script:fullVersion -OutputDirectory $outputDir
}

task Publish -depends Pack {
    #& $nugetExe push "$outputDir\icrawl.$fullVersion.nupkg"
}
