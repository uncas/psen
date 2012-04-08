$framework = '4.0'

. .\psake_ext.ps1

properties {
    $versionMajor = 0
    $versionMinor = 1
    $versionBuild = 0
    $year = (Get-Date).year
    $fullVersion = "$versionMajor.$versionMinor.$versionBuild.1"

    $configuration = "Release"

    $baseDir = ".\.."
    $srcDir = "$baseDir\src"
    $testDir = "$baseDir\tests"
    $outputDir = "$baseDir\output"
    $collectDir = "$outputDir\collect"
    $scriptDir = "$baseDir\scripts"

    $nugetExe = "$baseDir\.nuget\nuget.exe"

    $localNuGetPackageFolder = "C:\NuGetPackages"
}

task default -depends Test

task Clean {
    if (Test-Path $collectDir)
    {
        rmdir -force -recurse $collectDir
    }
    if (Test-Path $outputDir)
    {
        rmdir -force -recurse $outputDir
    }
}

task Init -depends Clean {
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
        -company "Uncas" `
        -product "Uncas.Psen" `
        -version "$versionMajor.$versionMinor.$versionBuild" `
        -copyright "Copyright (c) $year, Ole Lynge Sørensen"
}

task Collect -depends Init {
    copy $srcDir\*.* $collectDir
    copy "$scriptDir\psake_ext.ps1" $collectDir

    $fullVersion = $script:fullVersion
    Replace-FileContent "$collectDir\psen.ps1" "@PsenVersion@" $fullVersion
    $buildContent = "`$task = `$args[0]`
`
`$psenVersion = `"$fullVersion`"`
`
`$psenPath = `".\packages\psen.`$psenVersion\tools\psen.ps1`"`
if (!(Test-Path `$psenPath))`
{`
    .nuget\nuget.exe install psen -o packages -version `$psenVersion`
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
    # TODO: & $nugetExe push "$outputDir\*.nupkg"
    copy $outputDir\*.nupkg $localNuGetPackageFolder
}

task Test -depends Publish {
    # Set up test solution such that it can install psen and run the default scripts...
    Copy-Item $testDir\TestSolution $outputDir -recurse
    # Assumes that the user has installed nuget in .nuget folder:
    Copy-Item $baseDir\.nuget $outputDir\TestSolution -recurse

    cd $outputDir\TestSolution

    # Now execute the commands that the user should also do in order to install psen:
    & .nuget\nuget.exe install psen -version $script:fullVersion -source $localNuGetPackageFolder -o packages
    Copy-Item packages\psen.$script:fullVersion\tools\build.ps1 .

    # Now execute the psen script:
    Invoke-Psake packages\psen.$script:fullVersion\tools\default.ps1
    #exec { & .\build.ps1 }
    "Done testing"
}
