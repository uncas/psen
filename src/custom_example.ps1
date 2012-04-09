# Example of loading custom properties
# Usage: Create or copy file to '[baseDir]\scripts\custom.ps1' and add or edit properties as required

function LoadCustomProperties {
    $script:configuration = "Debug"
    $script:versionMajor = 1
    $script:versionMinor = 2
    $script:versionBuild = 3
    $script:defaultWebsitePort = 8381
    $script:FtpHost = "ftp.example.com"

    # This method might also call another file for secrets like passwords or API keys, for example:
    if (Test-Path "my-secrets.ps1") {
        LoadMySecrets
    }
}

# Contents of my-secrets.ps1, which is not committed to version control:
function LoadMySecrets {
    $script:FtpUser = "ExampleFtpUser"
    $script:FtpPassword = "ExampleFtpPassword"
}