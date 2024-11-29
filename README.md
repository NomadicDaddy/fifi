# fifi

Find-InFiles (aka fifi) - Finds a string within files of a specific type within the given locations and/or files with names containing that string.

## installation

Install-Module Find-InFiles

## parameters

-Needle  `<string to find>`

-Haystacks `<paths to check>` (default to current directory, recursive on)

-FileTypes `<types of files to search through>` (defaults to bat/cmd/ps1/psm1/sql)

-MaxAge  `<maximum age in days>`

-SubNeedle `<additional string to find>` (optional second string that must also be present in matching files)

-Quiet (optional switch to not output results to console)

## examples

- To find files in your current directory (and any below) containing the string '`waldo`':

```console
fifi waldo
```

- To find files containing both '`waldo`' and '`where`':

```console
fifi -Needle 'waldo' -SubNeedle 'where'
```

- To find '`waldo`' inside PowerShell files within your PSModulePath:

```console
Find-InFiles -Haystacks $($env:PSModulePath + ',' -replace(';', ',') -replace(',', '\%,') -replace('\\\\%', '\%') | Sort-Object -Unique) -FileTypes '*.ps1,*.psm1' -Needle '`waldo`' -NameMatch
``` 
