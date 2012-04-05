$task = $args[0]

$psenVersion = 1.0.0.2

$psenPath = ".\packages\psen.$psenVersion\tools\psen.ps1"
if (!(Test-Path $psenPath))
{
    nuget install psen -o packages -version $psenVersion
}

& $psenPath $task