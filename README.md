# windows-aws-cli-utilities

### Update-AWSCLI.ps1
Compares the currently installed version to the latest version. Downloads and installs the latest version if an outdated version is detected.

Typical output
```powershell
PS C:\> .\Update-AWSCLI.ps1
VERBOSE: GET https://github.com/aws/aws-cli/releases with 0-byte payload
VERBOSE: received -1-byte response of content type text/html; charset=utf-8
VERBOSE: Latest version 1.17.8
VERBOSE: Current version 1.16.291
VERBOSE: Outdated version detected - currently 1.16.291; downloading 1.17.8
VERBOSE: GET https://s3.amazonaws.com/aws-cli/AWSCLI64PY3.msi with 0-byte payload
VERBOSE: received 22663168-byte response of content type application/x-msi

Handles  NPM(K)    PM(K)      WS(K)     CPU(s)     Id  SI ProcessName
-------  ------    -----      -----     ------     --  -- -----------
     28       5     5312       2744       0.03  14004   4 msiexec

PS C:\>
```

Output if AWS CLI not currently installed
```powershell
PS C:\> .\Update-AWSCLI.ps1 -Verbose
VERBOSE: GET https://github.com/aws/aws-cli/releases with 0-byte payload
VERBOSE: received -1-byte response of content type text/html; charset=utf-8
VERBOSE: Latest version 1.17.9
Compare-AWSCLIVersions : AWS CLI not found
At C:\Update-AWSCLI.ps1:101 char:1
+ Compare-AWSCLIVersions -Verbose -ErrorAction $NewInstallErrorAction
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (:) [Write-Error], WriteErrorException
    + FullyQualifiedErrorId : Microsoft.PowerShell.Commands.WriteErrorException,Compare-AWSCLIVersions

VERBOSE: Outdated version detected - currently 0.0.0; downloading 1.17.9
VERBOSE: GET https://s3.amazonaws.com/aws-cli/AWSCLI64PY3.msi with 0-byte payload
VERBOSE: received 22519808-byte response of content type application/x-msi

Handles  NPM(K)    PM(K)      WS(K)     CPU(s)     Id  SI ProcessName
-------  ------    -----      -----     ------     --  -- -----------
     29       4     4908       1792       0.05    176   2 msiexec

PS C:\>     
```
#### Q & A
- Q: Why not just use pip or chocolatey?
- A: Those are both great package managers. I was looking for something lightweight, with no additional dependencies.

- Q: Why does your code suck?
- A: This is what happens when a network engineer attempts development. :grimacing:
