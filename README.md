# windows-aws-cli-utilities

### Update-AWSCLI.ps1
Compares currently installed version to latest version and downloads and installs latest version if an outdated version is detected.

Typical output
```
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
