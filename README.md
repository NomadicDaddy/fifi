# fifi

Find-InFiles (fifi) searches file contents using a regular expression and returns matching
`System.IO.FileInfo` objects. It can also match the full file path. The module manifest declares
version 1.2.

## Load the module

From a local checkout:

```powershell
Import-Module .\Find-InFiles.psd1
Get-Help Find-InFiles -Full
```

The documented gallery installation command is `Install-Module Find-InFiles`. Gallery availability
and parity with this checkout have not been verified here. Publishing is a separate maintainer action.

## Parameters

| Parameter | Behavior |
| --- | --- |
| `-Needle` | Required content regex; matching is case-insensitive by default. Position 0. |
| `-Haystacks` | Comma-separated paths; `%` requests recursion. Default: `.\%`. Omitting `%` did not disable recursion in the PowerShell 7.6.6 fixture check. |
| `-FileTypes` | Comma-separated filename filters. Default: `*.bat,*.cmd,*.ps1,*.psm1,*.sql`. |
| `-NameMatch` | Also accepts a case-insensitive regex match against the full path, not just the basename. |
| `-MaxAge` | Accepted integer parameter, default 0; currently unused and does not filter by age. |
| `-SubNeedle` | Optional second content regex. Both patterns must occur in the file, not necessarily on the same line. |
| `-Quiet` | Suppresses the function's console status output; matching file objects are still returned. |

With `-NameMatch`, a matching path can qualify even when the content patterns do not match, including
when `-SubNeedle` is supplied. Overlapping paths or file filters can return duplicates. This command
does not edit searched files. Filesystem and invalid-regex errors are not suppressed by `-Quiet`.

## Examples

Search the current directory and its descendants using the default file types:

```powershell
fifi 'waldo'
```

Find PowerShell files containing both patterns:

```powershell
fifi -Needle 'waldo' -SubNeedle 'where' -FileTypes '*.ps1,*.psm1'
```

Search two directories, explicitly requesting recursion for both:

```powershell
fifi -Needle 'error' -Haystacks 'C:\work\scripts\%,C:\work\logs\%' -FileTypes '*.ps1,*.log'
```

Collect matching objects without status output:

```powershell
$matches = @(fifi -Needle 'waldo' -Quiet)
$matches | Select-Object FullName, LastWriteTime
```

To search for regex punctuation literally, escape the input:

```powershell
fifi -Needle ([regex]::Escape('example.com')) -Quiet
```

## Development

`Find-InFiles.psm1` contains the implementation and alias; `Find-InFiles.psd1` defines the exported
function, alias and module version. There is no repository test suite, CI workflow or quality-gate
script. PowerShell compatibility beyond a tested host should be checked before distribution; the
manifest does not declare a minimum engine version.

## License

See [LICENSE](LICENSE).
