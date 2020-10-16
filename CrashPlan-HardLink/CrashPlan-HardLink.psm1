<#
.Synopsis
	Creates hard links to files so CrashPlan can back them up

.Description
	Create hard links to files so CrashPlan can back them up
	https://support.code42.com/CrashPlan/6/Troubleshooting/What_is_not_backing_up

.Parameter WhatIf
	Shows what would happen if the cmdlet runs. The cmdlet is not run.

.Parameter Create
	Creates hard links

.Parameter Remove
	Removes hard links

.Parameter Force
	Removes hard links without confirmation
#>

function CrashPlan-HardLink {
	param(
		[Switch] $WhatIf,
		[Switch] $Create,
		[Switch] $Remove,
		[Switch] $Force
	)

	$Extensions = ".bck",
	".bkf",
	".hdd",
	".hds",
	".nvram",
	".ost",
	".part",
	".pvm",
	".pvs",
	".rbf",
	".sparseimage",
	".tib",
	".tmp",
	".vdi",
	".vfd",
	".vhd",
	".vhdx",
	".vmc",
	".vmdk",
	".vmem",
	".vmsd",
	".vmsn",
	".vmss",
	".vmtm",
	".vmwarevm",
	".vmx",
	".vmxf",
	".vsv",
	".vud",
	".xva"

	$LogFile = "CrashPlan-HardLink.log";
	$Pattern = (($Extensions | % { "\" + $_ + "$|\.hardlink-" + ($_).subString(1) + "$" }) -join "|")
	$FoundFiles = @()
	$FoundHardLinks = @()

	if(!$WhatIf -And ($Create -Or $Remove)) {
		if($Create) {
			$mode = 'Create'
		}
		if($Remove) {
			$mode = 'Remove'
		}
		Write-Host ($log = ("`r`nStart Crashplan-HardLink " + $mode + " " + (Get-Date)))
		Add-Content $LogFile $log
	}

	Get-ChildItem -Force -Recurse | Where{$_.Name -match $Pattern } | % {

		if($Matches[0] -match "\.hardlink-.*") {
			# Find hardlinks
			$HardLinkMode = $true
			$FoundHardLinks += $_.FullName
			$FileName = $_.DirectoryName + "\" + ($_.Name -Replace "\.hardlink-.+$", ($Matches[0].replace(".hardlink-", ".")))
		}
		else {
			# Find files
			$HardLinkMode = $false
			$FoundFiles += $_.FullName
			$HardLinkName = $_.DirectoryName + "\" + ($_.Name -Replace ("\" + $Matches[0] + "$"), (".hardlink-" + $Matches[0].subString(1)))
		}

		if($Create) {
			# Create hardlinks

			if($HardLinkMode) {
				# Write-Host "SKipped " $_.FullName " Already a hardlink file"
			} else {
				if(Test-Path $HardLinkName) {
					Write-Host "Skipped" $HardLinkName " File already exists" -ForegroundColor Yellow
				} else {
					if($WhatIf) {
						# Rename-Item $_.FullName -NewName $NewName -WhatIf
						New-Item -WhatIf -ItemType HardLink -Path $HardLinkName -Target $_.FullName
					} else {
						# Rename-Item $_.FullName -NewName $NewName
						if(!$Force) {
							$confirm = Read-Host "Create $HardLinkName >" $_.FullName "[Y/N]"
						}
						if($Force -Or ($confirm -eq 'y')) {
							New-Item -ItemType HardLink -Path $HardLinkName -Target $_.FullName
							Write-Host "Created $HardLinkName ->" $_.FullName -ForegroundColor Green
							Add-Content $LogFile ("Created " + $HardLinkName + " -> " + $_.FullName)
						}
					}
				}
			}
		} elseif($Remove) {
			# Remove

			if(!$HardLinkMode) {
				# Write-Host "Skipped " $_.FullName " not a hardlink file"
			} else {
				# Check if file exists
				# Get HardLink target
				if($_.LinkType -eq "HardLink") {
					$HardLinkTarget = $_.target
					if(Test-Path $HardLinkTarget) {
						# Remove hardlink
						if($WhatIf) {
							Remove-Item -WhatIf -Path $_.FullName
						} else {
							if(!$Force) {
								$confirm = Read-Host "Remove" $_.FullName " > $HardLinkTarget [Y/N]"
							}
							if($Force -Or ($confirm -eq 'y')) {
								Remove-Item -Path $_.FullName
								Write-Host "Removed" $_.FullName -ForegroundColor Green
								Add-Content $LogFile ("Removed " + $_.FullName + " > " + $HardLinkTarget)
							}
						}
					} else {
						Write-Host "Skipped" $_.FullName " - " $HardLinkTarget " did not exist" -ForegroundColor Red
					}
				} else {
					Write-Host "Skipped" $_.FullName " was not a hardlink" -ForegroundColor Red
				}
			}
		} else {
			# List
		}
	}


	if($Create) {
		# Handled in loop
	} elseif($Remove) {
		# Handled in loop
	} else {
		# List
		Write-Host "Use -Create or -Remove [-Force] to add or remove hardlinks, and -WhatIf to test"
		Write-Host $FoundFiles.Length " files found:" -ForegroundColor Yellow
		Write-Host ($FoundFiles -Join "`n")
		Write-Host " "
		Write-Host $FoundHardLinks.Length " hardlinks found:" -ForegroundColor Yellow
		Write-Host ($FoundHardLinks -Join "`n")
	}
}

Export-ModuleMember -Function 'CrashPlan-HardLink'