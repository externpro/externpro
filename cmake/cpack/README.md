# cmake/xpcpack

common cpack for projects that include xpcpack

## Table of Contents
- [Developing Packages](#developing-packages)
- [Building Packages](#building-packages)
  - Windows
  - Linux
- [Installing Packages](#installing-packages)
  - [Windows MSI](#windows-msi)
    - [Windows MSI troubleshooting](#windows-msi-troubleshooting)
  - [Windows ZIP](#windows-zip)
  - [Linux RPM](#linux-rpm)
  - [Linux TXZ](#linux-txz)

## Developing Packages
* use the [cmake `install()`](https://cmake.org/cmake/help/latest/command/install.html) command and as part of that command for
  * client files, specify
    ```cmake
    install(... DESTINATION bin COMPONENT client)
    ```
  * plugin files, specify
    ```cmake
    install(... DESTINATION bin COMPONENT plugin)
    ```
  * server files, specify
    ```cmake
    install(... DESTINATION bin COMPONENT server)
    ```
  * tool files (NOTE: setting `EXECUTABLE_OUTPUT_PATH` for tool files is no longer preferred), specify
    ```cmake
    install(... DESTINATION bintool COMPONENT tool)
    ```
* in the top level of the source tree (`CMAKE_SOURCE_DIR`), make sure required params are set
  and consider optional params to set (see head of [xpcpack.cmake](../xpcpack.cmake) file)
  * for example, one of the required params is `CPACK_COMPONENTS_ALL` --
    if your project contains both server and tool components
    ```cmake
    set(CPACK_COMPONENTS_ALL server tool)
    ```
    of if your project contains both plugin and tool components
    ```cmake
    set(CPACK_COMPONENTS_ALL plugin tool)
    ```
  * and then
    ```cmake
    include(xpcpack)
    ```

## Building Packages
In an out-of-source (binary) build directory where you've already ran cmake:

### Windows
Build the `PACKAGE` project of the `<CMAKE_PROJECT_NAME>.sln` in Microsoft Visual Studio, or from the command-line:

`cmake --build . --config Release --target PACKAGE -- /verbosity:minimal`

NOTE: Requires [WiX Toolset](http://wixtoolset.org/) to be installed (currently v3.8).

### Linux
`make -j4 package`

NOTE: Requires rpm-build to be installed (for example: `dnf install rpm-build`). The buildpro/public/rocky-pro docker image has rpm-build installed.

## Installing Packages

The [`CPACK_GENERATOR`](https://cmake.org/cmake/help/latest/manual/cpack-generators.7.html) list can include
* Windows: ZIP WIX
* Linux: TXZ RPM
* NOTES
  * TXZ: tar.xz files (Tar XZ compression)
  * WIX: creates .msi files via the WiX tools
  * WIX and RPM are only built for `COMPONENT client` and/or `COMPONENT server`
  * any COMPONENT other than `client server` only build the two archive formats (ZIP, TXZ)

### Windows MSI

Packages created using the WIX generator create a Windows Installer (previously known as Microsoft Installer, hence MSI) file. As an MSI file the installer can be launched, with options, from msiexec in a cmd.exe terminal. The `msiexec /q[n|b|r|f]` Display Options set the user interface level. For example:
```
msiexec /i \path\to\[CMAKE_PROJECT_NAME]-[version]-win64.msi /qr /log \path\to\install.log
```
executes the installer with a Reduced UI.
  * `/qn` - No UI
  * `/qb` - Basic UI
  * `/qr` - Reduced UI
  * `/qf` - Full UI (default)

#### Windows MSI Troubleshooting
How to enable Windows Installer logging https://support.microsoft.com/en-us/kb/223300
> Windows Installer can use logging to help assist in troubleshooting issues with installing software packages. This logging is enabled by adding keys and values to the registry. After the entries have been added and enabled, you can retry the problem installation and Windows Installer will track the progress and post it to the Temp folder. The new log's file name is random. However, the first letters are "Msi" and the file name has a ".log: extension. To locate the Temp folder, type `%temp%` in the Windows Explorer Address Bar.
> To enable Windows Installer logging yourself, open the registry by using Regedit.exe, and then create the following subkey and keys:
  ```
  HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\Installer
  Reg_SZ: Logging
  Value: voicewarmupx
  ```
> The letters in the value field can be in any order. Each letter turns on a different logging mode. Each letter's actual function is as follows for MSI version 1.1:
  ```
  v - Verbose output
  o - Out-of-disk-space messages
  i - Status messages
  c - Initial UI parameters
  e - All error messages
  w - Non-fatal warnings
  a - Start up of actions
  r - Action-specific records
  m - Out-of-memory or fatal exit information
  u - User requests
  p - Terminal properties
  + - Append to existing file
  ! - Flush each line to the log
  x - Extra debugging information.
  "*" - Wildcard: Log all information except the v and the x option.
        To include the v and the x option, specify "/l*vx".
  ```
> Note This change should be used only for troubleshooting and should not be left on because it will have adverse effects on system performance and disk space. Each time that you use the Add or Remove Programs item in Control Panel, a new Msi*.log file is created.

### Windows ZIP

Packages created using the ZIP generator create a .zip archive file.

Common commands
* list contents of package
  ```
  unzip -l /path/to/[CMAKE_PROJECT_NAME]-[version]-win64-[client|plugin|server|tool].zip
  ```
* extract package
  ```
  unzip /path/to/[CMAKE_PROJECT_NAME]-[version]-win64-[client|plugin|server|tool].zip -d /existing/path/to/extract/to/
  ```
* remove package
  ```
  rm -rf /path/where/package/was/extracted/
  ```

### Linux RPM

Packages created using the RPM generator create an RPM Package Manager (previously known as Red Hat Package Manager, now a recursive acronymn) file for RHEL-based Linux systems (Red Hat Enterprise Linux).

Websites with examples:
* [RPM Command: 15 Examples to Install, Uninstall, Upgrade, Query RPM Packages](http://www.thegeekstuff.com/2010/07/rpm-command-examples/)
* [How to use systemctl to manage Linux services](https://www.redhat.com/sysadmin/linux-systemctl-manage-services)

Common commands (NOTE: `[cmake_project_name]` below is all-lowercase version of `[CMAKE_PROJECT_NAME]`)
* list contents of package
  ```
  rpm -qlp /path/to/[CMAKE_PROJECT_NAME]-[version]-Linux-[client|server].rpm
  ```
* list scriptlets bundled in rpm
  ```
  rpm -qp --scripts /path/to/[CMAKE_PROJECT_NAME]-[version]-Linux-[client|server].rpm | less
  ```
* list package metadata
  ```
  rpm -qip /path/to/[CMAKE_PROJECT_NAME]-[version]-Linux-[client|server].rpm
  ```
* check if package is installed
  ```
  rpm -qa | grep [cmake_project_name]-[client|server]
  ```
* details of package installation (package already installed)
  ```
  rpm -qi [cmake_project_name]-[client|server]
  ```
* remove package
  ```
  sudo rpm -ev [cmake_project_name]-[client|server]
  ```
* install package
  ```
  sudo rpm -ivh /path/to/[CMAKE_PROJECT_NAME]-[version]-Linux-[client|server].rpm
  ```
* start, stop, or restart the daemon
  ```
  sudo systemctl [start|stop|restart] [cmake_project_name].service
  ```
* check status of daemon
  ```
  systemctl status [cmake_project_name].service
  ```
* check if processes are running
  ```
  ps -ef | grep -i [cmake_project_name]
  ```

### Linux TXZ

Packages created using the TXZ generator create a .tar.xz archive file.

Common commands
* list contents of package
  ```
  tar -tf /path/to/[CMAKE_PROJECT_NAME]-[version]-Linux-[client|plugin|server|tool].tar.xz
  ```
* extract package
  ```
  tar -xf /path/to/[CMAKE_PROJECT_NAME]-[version]-Linux-[client|plugin|server|tool].tar.xz --directory=/existing/path/to/extract/to/
  ```
* remove package
  ```
  rm -rf /path/where/package/was/extracted/
  ```
