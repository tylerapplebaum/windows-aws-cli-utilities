<#
.SYNOPSIS
Keep AWS CLI up to date
Written by Tyler Applebaum
Version 0.2

.LINK
https://github.com/tylerapplebaum/windows-aws-cli-utilities

.DESCRIPTION
Keeps AWS CLI up to date. Can install AWS CLI for the first time as well.
Example version number - 1.17.8 and 1.16.291
<Major>.<Minor>.<Patch/Upgrade>
Compare Minor fields (ex. 17 to 16), if same, compare Patch/Upgrade fields

.PARAMETER NewInstallErrorAction
Specify a PowerShell ErrorAction value.

.EXAMPLE
PS C:\> .\Update-AWSCLI.ps1 -Verbose
#>
#Requires -RunAsAdministrator

[CmdletBinding()]
Param(
    [Parameter(HelpMessage="If set to 'Continue' - force download and install even if AWS CLI not installed")]
    [ValidateSet('Continue','Ignore','Inquire','SilentlyContinue','Stop','Suspend')]$NewInstallErrorAction = "Continue"
)

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
        Write-Error "Could not parse version number from GitHub - check reachability"
        Break
    }

} #End Get-LatestAWSCLIVersion

Function Compare-AWSCLIVersions {
[CmdletBinding()]
Param(
    [Parameter(HelpMessage="Specify the S3 URL of the 64-bit AWS CLI MSI download")]
    [ValidateNotNullOrEmpty()]$AWSCLI64bitDownload = "https://s3.amazonaws.com/aws-cli/AWSCLI64PY3.msi",

    [Parameter(HelpMessage="Specify the local path to save the AWS CLI download")]
    [ValidateScript({Test-Path $_ -PathType Container})]$script:DownloadLocation = [Environment]::GetFolderPath("UserProfile") + "\Downloads"
)
    Try {
        $CurrentVersion = $(aws --version).Split(' ')[0].Split('/')[1]
        Write-Verbose "Current version $CurrentVersion"
    }

    Catch [System.Management.Automation.CommandNotFoundException] {
        Write-Error "AWS CLI not found"
        If ($NewInstallErrorAction -eq "Continue") {
            $CurrentVersion = "0.0.0"
        }
        Else {
            Break
        }
    }
    Try {
        $VersionArr = @(($LatestVersion.Split('.')),($CurrentVersion.Split('.')))
    }

    Catch [System.Management.Automation.RuntimeException] {
        If ($null -eq $LatestVersion) {
            Write-Error "Could not detect latest version"
        }
        Break
    }

    Catch {
        Write-Error "Omar comin'"
        Break
    }

    $i = 1 #We can skip evaluating the first number due to AWS CLI versioning scheme
    Do {
        If ([int]$VersionArr[0][$i] -gt [int]$VersionArr[1][$i]) {
            $ShouldDownload = $True
            Write-Verbose "Outdated version detected - currently $CurrentVersion; $LatestVersion is newer"
            Break
        }

    $i++ #Increment after $i is evaluated
    }
    Until ($i -eq $VersionArr[0].Length)

    If ($ShouldDownload) {
        Invoke-WebRequest $AWSCLI64bitDownload -OutFile $DownloadLocation\AWSCLI64PY3.msi
    }

    Else {
        Write-Verbose "Could not detect difference in versions; no action"
        Break
    }

} #End Compare-AWSCLIVersions

Function Install-LatestAWSCLI {
    If (Test-Path $DownloadLocation\AWSCLI64PY3.msi) {
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/qn /i $DownloadLocation\AWSCLI64PY3.msi /L*V $DownloadLocation\AWSCLI64PY3_$LatestVersion.log" -Wait -Passthru
    }
    Else {
        Write-Error "$DownloadLocation\AWSCLI64PY3.msi not found"
    }
} #End Install-LatestAWSCLI

Get-LatestAWSCLIVersion -Verbose
Compare-AWSCLIVersions -Verbose -ErrorAction $NewInstallErrorAction
Install-LatestAWSCLI
