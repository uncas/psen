# Original from https://github.com/ayende/rhino-mocks/blob/master/psake_ext.ps1

function Get-Git-Commit
{
    $gitLog = git log --oneline -1
    return $gitLog.Split(' ')[0]
}

function Get-Git-CommitCount
{
    $gitLog = git log --pretty=oneline
    return $gitLog.length
}

function Generate-Assembly-Info
{
param(
	[string]$company, 
	[string]$product, 
	[string]$copyright, 
	[string]$version,
	[string]$file = $(throw "file is a required parameter.")
)
  $commit = Get-Git-Commit
  $commitCount = Get-Git-CommitCount
  $fullVersion = "$version.$commitCount"
  $script:fullVersion = $fullVersion
  "Version $fullVersion (commit hash: $commit, commit log count: $commitCount)"
  $asmInfo = "using System;
using System.Reflection;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;

[assembly: AssemblyCompanyAttribute(""$company"")]
[assembly: AssemblyProductAttribute(""$product"")]
[assembly: AssemblyCopyrightAttribute(""$copyright"")]
[assembly: AssemblyVersionAttribute(""$fullVersion"")]
[assembly: AssemblyInformationalVersionAttribute(""$fullVersion ($commit)"")]
[assembly: AssemblyFileVersionAttribute(""$fullVersion"")]
[assembly: AssemblyDelaySignAttribute(false)]
"

	$dir = [System.IO.Path]::GetDirectoryName($file)
	if ([System.IO.Directory]::Exists($dir) -eq $false)
	{
		Write-Host "Creating directory $dir"
		[System.IO.Directory]::CreateDirectory($dir)
	}
	Write-Host "Generating assembly info file: $file"
	out-file -filePath $file -encoding UTF8 -inputObject $asmInfo
}

function Run-Test
{
    param(
        [string]$testProjectName = $(throw "file is a required parameter."),
        [string]$outDir = $(throw "out dir is a required parameter.")
    )

    $testResultFile = "$outDir\$testProjectName.TestResult.xml"
    & $nunitExe "$baseDir\test\$testProjectName\bin\$configuration\$testProjectName.dll" /xml=$testResultFile

    if ($lastExitCode -ne 0) {
        throw "One or more failures in tests - see details above."
    }
}

function Replace-FileContent
{
    param (
        [string]$sourceFile = $(throw "source file is required"),
        [string]$originalValue = $(throw "original value is required"),
        [string]$finalValue = $(throw "final value is required"),
        [string]$targetFile
    )

    if (!$targetFile)
    {
        $targetFile = $sourceFile
    }

    (cat $sourceFile) -replace '$originalValue', "$finalValue" > $targetFile
}