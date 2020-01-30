#Example version number - 1.17.8 and 1.16.291
#<Major>.<Minor>.<Patch/Upgrade>
#Compare Minor fields (ex. 17 to 16), if same, compare Patch/Upgrade fields

[CmdletBinding()]
Param(
    [Parameter(HelpMessage="Force download and install even if AWS CLI not installed")]
    $DownloadErrorAction = "Continue"
)

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
Param(
    [Parameter(HelpMessage="Specify the GitHub URL of the AWS CLI release page")]
    [ValidateNotNullOrEmpty()]$GitHubURL = "https://github.com/aws/aws-cli/releases"
)
    Try {
        $VersionCheck = Invoke-WebRequest $GitHubURL -UseBasicParsing
        $VersionPaths = $VersionCheck.Links.href | Select-String -Pattern '/tag/1\.'
        $script:LatestVersion = $VersionPaths[0].ToString().Trim('/aws/aws-cli/releases/tag/')
        Write-Verbose "Latest version $LatestVersion"
    }
    Catch {

    }

} #End Get-LatestAWSCLIVersion

Function Compare-AWSCLIVersions {
[CmdletBinding()]
Param(
    [Parameter(HelpMessage="Specify the S3 URL of the 64-bit AWS CLI MSI download")]
    [ValidateNotNullOrEmpty()]$AWSCLI64bitDownload = "https://s3.amazonaws.com/aws-cli/AWSCLI64PY3.msi",

    [Parameter(HelpMessage="Specify the local path to save the AWS CLI download")]
    [ValidateScript({Test-Path $_ -PathType Container})]$script:DownloadLocation = [Environment]::GetFolderPath("UserProfile") + "\Downloads",
    
    [Parameter(HelpMessage="Check whether or not the version string received from Get-LatestAWSCLIVersion is null")]
    [ValidateNotNullOrEmpty()]$LatestVersion
)
    Try {
        $CurrentVersion = $(aws --version).Split(' ')[0].Split('/')[1]
        Write-Verbose "Current version $CurrentVersion"
    }

    Catch [System.Management.Automation.CommandNotFoundException]
    {
        Write-Error "AWS CLI not found"
    }

    If ([int]$LatestVersion.split('.')[1] -gt [int]$CurrentVersion.split('.')[1]) { # Case where Minor version is higher
        Write-Verbose "Outdated version detected - currently $CurrentVersion; downloading $LatestVersion"
        Try {
            Invoke-WebRequest $AWSCLI64bitDownload -OutFile $DownloadLocation\AWSCLI64PY3.msi
        }
        Catch {
        
        }
    }

    ElseIf ([int]$LatestVersion.split('.')[2] -gt [int]$CurrentVersion.split('.')[2]) { # Case where Minor version isn't higher; check Patch/Upgrade fields
        Write-Verbose "Outdated version detected - currently $CurrentVersion; downloading $LatestVersion"
        Try {
            Invoke-WebRequest $AWSCLI64bitDownload -OutFile $DownloadLocation\AWSCLI64PY3.msi
        }
        Catch {
        
        }
    }

    Else {
        Write-Verbose "Could not detect difference in versions; no action"
        Break
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
Compare-AWSCLIVersions -Verbose -ErrorAction Continue
Install-LatestAWSCLI
