# fifi
Find-InFiles (aka fifi) - Finds a string within files of a specific type within the given locations and/or files with names containing that string.

# parameters

-Needle		<string to find>
  
-Haystacks	<paths to check> (default to current directory, recursive on)
  
-FileTypes	<types of files to search through> (defaults to bat/cmd/ps1/psm1/sql)
  
-MaxAge		<maximum age in days>
  

# examples

0. Import the module.

  Import-Module .\Find-InFiles.psm1

1. To find files in your current directory (and any below) containing the string 'waldo':

  fifi waldo

2. To find 'waldo' inside PowerShell files within your PSModulePath:

  Find-InFiles -Haystacks $($env:PSModulePath + ',' -replace(';', ',') -replace(',', '\%,') -replace('\\\\%', '\%') | Sort-Object -Unique) -FileTypes '*.ps1,*.psm1' -Needle 'waldo' -NameMatch
