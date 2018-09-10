function Find-InFiles {
<#
.SYNOPSIS
	Find in files.
.DESCRIPTION
	Finds a string within files of a specific type within the given locations and/or files with names containing that string.
.PARAMETER Needle
	<string to find>
.PARAMETER Haystacks
	<paths to check>
.PARAMETER FileTypes
	<types of files to search through>
.PARAMETER MaxAge
	<maximum age in days>
.EXAMPLE
	Find-InFiles 'waldo'
.EXAMPLE
	Find-InFiles -Haystacks $($env:PSModulePath + ',' -replace(';', ',') -replace(',', '\%,') -replace('\\\\%', '\%') | Sort-Object -Unique) -FileTypes '*.ps1,*.psm1' -Needle 'waldo' -NameMatch
.EXAMPLE
	Find-InFiles -Haystacks "$($env:UserProfile)\Source\%" -FileTypes '*.ps1,*.psm1,*.cmd,*.bat,*.sql' -Needle 'waldo'
.NOTES
	01/17/2017	lordbeazley		Initial release.
	02/24/2017	lordbeazley		Added recursion per haystack (append % to haystack to recurse).
	03/25/2017	lordbeazley		Added NameMatch.
	08/14/2018	lordbeazley		Added MaxAge.
	09/09/2018	lordbeazley		Converted to function/module.
	09/10/2018	lordbeazley		Returning an object would be more helpful. Doh!
#>
[CmdletBinding(SupportsShouldProcess = $false, PositionalBinding = $false, ConfirmImpact = 'Low')]
Param(
	[Parameter(Mandatory = $true, ValueFromPipeLine = $true, ValueFromPipeLineByPropertyName = $true, Position = 0)]
		[string]$Needle,
	[Parameter(Mandatory = $false, Position = 1)]
		[string]$Haystacks = ".\%",
	[Parameter(Mandatory = $false, Position = 2)]
		[string]$FileTypes = '*.bat,*.cmd,*.ps1,*.psm1,*.sql',
	[Parameter(Mandatory = $false, Position = 3)]
		[switch]$NameMatch,
	[Parameter(Mandatory = $false, Position = 4)]
		[int]$MaxAge = 0
)

$HeapArray = @()

foreach ($Haystack in ($Haystacks -split ',')) {
	($Haystack, $Recurse) = $Haystack -split '%'
	if ($Recurse -eq '') {
		Write-Host ("`r`nLOOKING FOR '{0}' IN: {1} (RECURSIVE) {2}" -f $Needle, $Haystack, $FileTypes) -ForegroundColor 'White'
		foreach ($FileType in ($FileTypes -split ',')) {
			Get-ChildItem -Path $Haystack -Filter $FileType -Recurse -File |
				ForEach-Object {
					if (Get-Content -Path $_.FullName | Select-String -Pattern $Needle) {
						Write-Host "+ "  -ForegroundColor 'Green' -NoNewLine
						Write-Host ("{0,22}  " -f $_.LastWriteTime) -ForegroundColor 'Green' -NoNewLine
						Write-Host $_.FullName -ForegroundColor 'Green'
#						$HeapArray += "($($_.LastWriteTime)) $($_.FullName)"
						$HeapArray += $_
					} elseif ($NameMatch -and $_.FullName -imatch $Needle) {
						Write-Host "+ "  -ForegroundColor 'Yellow' -NoNewLine
						Write-Host ("{0,22}  " -f $_.LastWriteTime) -ForegroundColor 'Yellow' -NoNewLine
						Write-Host $_.FullName -ForegroundColor 'Yellow'
#						$HeapArray += "($($_.LastWriteTime)) $($_.FullName)"
						$HeapArray += $_
					} else {
						Write-Host "+ "  -ForegroundColor 'Gray' -NoNewLine
						Write-Host ("{0,22}  " -f $_.LastWriteTime) -ForegroundColor 'DarkGray' -NoNewLine
						Write-Host $_.FullName -ForegroundColor 'Gray'
					}
				}
		}
	} else {
		Write-Host ("`r`nLOOKING FOR '{0}' IN: {1} {2}" -f $Needle, $Haystack, $FileTypes) -ForegroundColor 'White'
		foreach ($FileType in ($FileTypes -split ',')) {
			Get-ChildItem -Path $Haystack -Filter $FileType -File |
				ForEach-Object {
					if (Get-Content -Path $_.FullName | Select-String -Pattern $Needle) {
						Write-Host "+ "  -ForegroundColor 'Green' -NoNewLine
						Write-Host ("{0,22}  " -f $_.LastWriteTime) -ForegroundColor 'DarkGray' -NoNewLine
						Write-Host $_.FullName -ForegroundColor 'Green'
#						$HeapArray += "($($_.LastWriteTime)) $($_.FullName)"
						$HeapArray += $_
					} elseif ($NameMatch -and $_.FullName -imatch $Needle) {
						Write-Host "+ "  -ForegroundColor 'Yellow' -NoNewLine
						Write-Host ("{0,22}  " -f $_.LastWriteTime) -ForegroundColor 'DarkGray' -NoNewLine
						Write-Host $_.FullName -ForegroundColor 'Yellow'
#						$HeapArray += "($($_.LastWriteTime)) $($_.FullName)"
						$HeapArray += $_
					} else {
						Write-Host "+ "  -ForegroundColor 'Gray' -NoNewLine
						Write-Host ("{0,22}  " -f $_.LastWriteTime) -ForegroundColor 'DarkGray' -NoNewLine
						Write-Host $_.FullName -ForegroundColor 'Gray'
					}
				}
		}
	}
}

if ($NameMatch -eq $true) {
	Write-Host ("`r`n{0} files containing or named like '{1}':`r`n" -f $HeapArray.Count, $Needle) -ForegroundColor 'White'
} else {
	Write-Host ("`r`n{0} files containing '{1}':`r`n" -f $HeapArray.Count, $Needle) -ForegroundColor 'White'
}

foreach ($file in $HeapArray) {
	Write-Host $file.FullName
}

return $HeapArray

}

Set-Alias -Name 'fifi' -Value 'Find-InFiles'
