# CrashPlan-HardLink
A Powershell module to create hardlinks to files so CrashPlan can back them up

## Reason
Despite their advertising (“Never worry about losing business-critical data again”, “Confidence that your files are backed up safely”, “Simplifies and streamlines all of your data backups”, …) [CrashPlan](https://www.crashplan.com/) actually restricts the types of files that can be backed up, so cannot be used as a complete backup solution.

See [What am I not allowed to back up?](https://support.code42.com/CrashPlan/6/Troubleshooting/What_is_not_backing_up) for a list of all the things you are not able to backup using CrashPlan.

This Powershell script will create hardlinks to some of the file types that CrashPlan refuses to back up, using filenames that CrashPlan will back up, so that they can be backed up.

## Usage

Open Powershell, navigate to the directory containing the files you wish to rename, and type:

```powershell
CrashPlan-HardLink [-Create] [-Remove] [-Force] [-WhatIf]
```

This will search the current directory and all child directories for any files matching any of the forbidden filetypes, and will:

### Default
By default this will list any found files, and any existing hardlink files previously created by this.

### -Create

With the `-Create` flag, hardlinks to the existing forbidden files will be created.

### -Remove

With the `-Remove` flag, previously created hardflink files will be removed.

### -Force

The `-Force` flag will skip confirmation.

### -WhatIf

The `-WhatIf` flag shows what would happen if run, but does not actually do it.

## How It Works

Hardlinks to forbidden filetypes are created as below:

`My Important Data.vhd` → `My Important Data.hardlink-vhd`

A log file `CrashPlan-HardLink.log` is created in the directory the command is run from, listing all the files that were created or removed.

## Installation

The simplest way is to [Download](https://github.com/ned-martin/CrashPlan-/archive/main.zip) this module and put it in one of the default module locations. Powershell will then autoload the module.

Alternatively, one can manually load the module.

### Autoload

1. To view the default module locations, type:
	```powershell
	$Env:PSModulePath
	```
	1. To add a default module location, type:
		```powershell
		$Env:PSModulePath = $Env:PSModulePath + ";<path>"
		```
	1. To create a Modules directory for the current user if one does not exist, type:
		```powershell
		New-Item -Type Directory -Path $HOME\Documents\WindowsPowerShell\Modules
		```
1. Copy the entire module folder into the Modules directory.
1. You should now be able to use the module:
	```powershell
	CrashPlan-HardLink [-Create] [-Remove] [-Force] [-WhatIf]
	```


### Manual Load

To import a module that is not in a default module location, use the fully qualified path to the module folder in the command.

For example, to add the Rename-Crashplan module in the C:\My-Modules directory to your session, type:
```powershell
Import-Module C:\My-Modules\Rename-Crashplan
```

### Running Scripts is Disabled

If you get an error similar to `The 'Rename-CrashPlan' command was found in the module 'Rename-CrashPlan', but the module could not be loaded.` or `Rename-CrashPlan.psm1 cannot be loaded because running scripts is disabled on this system` then you may need to enable the running of unsigned scripts on your system:

1. To get the effective execution policy for the current PowerShell session:
	```powershell
	Get-ExecutionPolicy
	```
1. To permanently change the execution policy:
	```powershell
	Set-ExecutionPolicy -ExecutionPolicy <PolicyName>
	```
1. To temporarily bypass the execution policy to allow running all scripts:
	```powershell
	powershell -ExecutionPolicy Bypass
	```

## Forbidden Filetypes

The filetypes which are handled by this script:

```powershell
".bck",
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
```