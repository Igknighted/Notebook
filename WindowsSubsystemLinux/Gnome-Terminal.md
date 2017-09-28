Ref: https://msdn.microsoft.com/en-us/commandline/wsl/reference

Run this in Powershell as Admin:
```
# Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
```

Run this to install linux:
```
# lxrun /install
```

Got VcXrv:
```
https://sourceforge.net/projects/vcxsrv/
```

To access linux from powershell:
```
# bash
```

Install gnome-terminal in ubuntu
```
# sudo apt-get update
# sudo apt-get install gnome-terminal ubuntu-desktop -y
```

Create a shortcut to open Gnome Terminal...
```
# powershell -windowstyle hidden -Command "iex \"bash ~ -l -c 'DISPLAY=:0.0 gnome-terminal'\" "
```

Or make `Gnome Terminal.vbs`
```
WScript.CreateObject("WScript.Shell").run "bash ~ -l -c 'DISPLAY=:0.0 gnome-terminal' ", 0
```

Additional stuff... because I hated the defaults...
In gnome-terminal, I went to Edit -> Preferences -> Profiles
I edited and renamed "Unnamed" to "Default"
Unchecked the Terminal Bell (it's annoying)
Selected the custom font "Ubuntu Mono Regular" at 12 pt.
