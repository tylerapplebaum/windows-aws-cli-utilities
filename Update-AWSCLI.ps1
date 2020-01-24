#Example version number - 1.17.8 and 1.16.291
#<Major>.<Minor>.<Patch/Upgrade>
#Compare Minor fields (ex. 17 to 16), if same, compare Patch/Upgrade fields

Function Get-RunAsAdminStatus {
$AdminStatus = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    If ( -NOT ($AdminStatus)) {
        Write-Error "Please relaunch PowerShell as administrator" -ErrorAction Stop
    }
    Else {
    
    }
} #End Get-RunAsAdminStatus

Function Get-LatestAWSCLIVersion {
[CmdletBinding()]
param(
    [Parameter(HelpMessage="Specify the GitHub URL of the AWS CLI release page")]
    [ValidateNotNullOrEmpty()]$GitHubURL = "https://github.com/aws/aws-cli/releases"
)
$VersionCheck = Invoke-WebRequest $GitHubURL -UseBasicParsing
$VersionPaths = $VersionCheck.Links.href | Select-String -Pattern '/tag/1\.'
$script:LatestVersion = $VersionPaths[0].ToString().Trim('/aws/aws-cli/releases/tag/')
Write-Verbose "Latest version $LatestVersion"
} #End Get-LatestAWSCLIVersion

Function Compare-AWSCLIVersions {
[CmdletBinding()]
param(
    [Parameter(HelpMessage="Specify the S3 URL of the 64-bit AWS CLI MSI download")]
    [ValidateNotNullOrEmpty()]$AWSCLI64bitDownload = "https://s3.amazonaws.com/aws-cli/AWSCLI64PY3.msi",

    [Parameter(HelpMessage="Specify the local path to save the AWS CLI download")]
    [ValidateScript({Test-Path $_ -PathType Container})]$script:DownloadLocation = [Environment]::GetFolderPath("UserProfile") + "\Downloads"
)
$CurrentVersion = $(aws --version).Split(' ')[0].Split('/')[1]
Write-Verbose "Current version $CurrentVersion"
    If ($LatestVersion.split('.')[1] -gt $CurrentVersion.split('.')[1]) { # Case where Minor version is higher
        Write-Verbose "Outdated version detected - currently $CurrentVersion; downloading $LatestVersion"
        Invoke-WebRequest $AWSCLI64bitDownload -OutFile $DownloadLocation\AWSCLI64PY3.msi
    }

    ElseIf ($LatestVersion.split('.')[2] -gt $CurrentVersion.split('.')[2]) { # Case where Minor version isn't higher; check Patch/Upgrade fields
        Write-Verbose "Outdated version detected - currently $CurrentVersion; downloading $LatestVersion"
        Invoke-WebRequest $AWSCLI64bitDownload -OutFile $DownloadLocation\AWSCLI64PY3.msi
    }

    Else {
        Write-Verbose "Could not detect difference in versions; no action"
    }
} #End Compare-AWSCLIVersions

Function Install-LatestAWSCLI {
    If ((Test-Path $DownloadLocation\AWSCLI64PY3.msi) -AND ($LastExitCode -eq 0)) {
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/qn /i $DownloadLocation\AWSCLI64PY3.msi /L*V $DownloadLocation\AWSCLI64PY3_$LatestVersion.log" -Wait -Passthru 
    }
    Else {
        Write-Error "$DownloadLocation\AWSCLI64PY3.msi not found"
    }
} #End Install-LatestAWSCLI

Get-RunAsAdminStatus
Get-LatestAWSCLIVersion -Verbose
Compare-AWSCLIVersions -Verbose
Install-LatestAWSCLI
