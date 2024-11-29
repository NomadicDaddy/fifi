function Find-InFiles {
<#
.SYNOPSIS
	Find in files.
.DESCRIPTION
	Finds a string within files of a specific type within the given locations and/or files with names containing that string.
.PARAMETER Needle
	<string to find>
.PARAMETER SubNeedle
    <optional second string to find within files that match the primary Needle pattern. When specified, files must contain both strings to be considered a match>
.PARAMETER Haystacks
	<paths to check>
.PARAMETER FileTypes
	<types of files to search through>
.PARAMETER MaxAge
	<maximum age in days>
.PARAMETER Quiet
	<do not output results to console>
.EXAMPLE
	Find-InFiles 'waldo'
.EXAMPLE
	Find-InFiles -Haystacks $($env:PSModulePath + ',' -replace(';', ',') -replace(',', '\%,') -replace('\\\\%', '\%') | Sort-Object -Unique) -FileTypes '*.ps1,*.psm1' -Needle 'waldo' -NameMatch
.EXAMPLE
	Find-InFiles -Haystacks "$($env:UserProfile)\Source\%" -FileTypes '*.ps1,*.psm1,*.cmd,*.bat,*.sql' -Needle 'waldo'
.EXAMPLE
	Find-InFiles -Needle 'error' -SubNeedle 'critical' -FileTypes '*.log'
.NOTES
	20170117	NomadicDaddy	Initial release.
	20170224	NomadicDaddy	Added recursion per haystack (append % to haystack to recurse).
	20170325	NomadicDaddy	Added NameMatch.
	20180814	NomadicDaddy	Added MaxAge.
	20180909	NomadicDaddy	Converted to function/module.
	20180910	NomadicDaddy	Returning an object would be more helpful. Doh!
	20241129	NomadicDaddy	Added SubNeedle.
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
		[int]$MaxAge = 0,
	[Parameter(Mandatory = $false, Position = 5)]
		[string]$SubNeedle,
	[Parameter(Mandatory = $false, Position = 6)]
		[switch]$Quiet
)

$HeapArray = @()

foreach ($Haystack in ($Haystacks -split ',')) {
	$Recurse = $false
	$hl = $Haystack.Length
	($Haystack, $Recurse) = $Haystack -split '%'
	if ($hl -ne $Haystack.Length) {
		$Recurse = $true
	}
	if (-not $Quiet) {
		Write-Host ("`r`nLOOKING FOR '{0}' IN: {1} {2} $(if ($Recurse) { ' (RECURSIVE)' } else { '' })" -f $Needle, $Haystack, $FileTypes) -ForegroundColor 'White'
	}
	foreach ($FileType in ($FileTypes -split ',')) {
		Get-ChildItem -Path $Haystack -Filter $FileType -Recurse:$Recurse -File |
			ForEach-Object {
				try {
					$content = (Get-Content -Path $_.FullName)
				} catch {
					$content = ''
				}
				if (($content | Select-String -Pattern $Needle) -and ($SubNeedle -eq '' -or ($content | Select-String -Pattern $SubNeedle))) {
					if (-not $Quiet) {
						Write-Host "+ "  -ForegroundColor 'Green' -NoNewLine
						Write-Host ("{0,22}  " -f $_.LastWriteTime) -ForegroundColor 'Green' -NoNewLine
						Write-Host $_.FullName -ForegroundColor 'Green'
					}
					$HeapArray += $_
				} elseif ($NameMatch -and $_.FullName -imatch $Needle) {
					if (-not $Quiet) {
						Write-Host "+ "  -ForegroundColor 'Cyan' -NoNewLine
						Write-Host ("{0,22}  " -f $_.LastWriteTime) -ForegroundColor 'Cyan' -NoNewLine
						Write-Host $_.FullName -ForegroundColor 'Cyan'
					}
					$HeapArray += $_
				} else {
					if (-not $Quiet) {
						Write-Host "+ "  -ForegroundColor 'Gray' -NoNewLine
						Write-Host ("{0,22}  " -f $_.LastWriteTime) -ForegroundColor 'DarkGray' -NoNewLine
						Write-Host $_.FullName -ForegroundColor 'Gray'
					}
				}
			}
	}
}

if (-not $Quiet) {

	if ($NameMatch -eq $true) {
		Write-Host ("`r`n{0} files containing or named like '{1}':`r`n" -f $HeapArray.Count, $Needle) -ForegroundColor 'White'
	} else {
		if ($SubNeedle) {
			Write-Host ("`r`n{0} files containing both '{1}' and '{2}':`r`n" -f $HeapArray.Count, $Needle, $SubNeedle) -ForegroundColor 'White'
		} else {
			Write-Host ("`r`n{0} files containing '{1}':`r`n" -f $HeapArray.Count, $Needle) -ForegroundColor 'White'
		}
	}

	foreach ($file in $HeapArray) {
		Write-Host $file.FullName
	}

}

return $HeapArray

}

Set-Alias -Name 'fifi' -Value 'Find-InFiles'
