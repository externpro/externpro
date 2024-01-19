function(xpStringIndentAppend appendTo indent str)
  math(EXPR indent ${indent})
  if(${indent} GREATER "0")
    foreach(i RANGE 1 ${indent})
      set(spaces "${spaces}  ") # 2 spaces per indent level
    endforeach()
    set(${appendTo} "${${appendTo}}${spaces}${str}\n" PARENT_SCOPE)
  else()
    set(${appendTo} "${${appendTo}}${str}\n" PARENT_SCOPE)
  endif()
endfunction()

function(xpCpackWixMsm mergeModuleIds appendTo) # optional ARGV2
  if(${ARGC} EQUAL 3 AND ARGV2)
    set(base ${ARGV2})
  else()
    set(base 4) # main.wxs.in
  endif()
  if(MSVC_VERSION GREATER 1900) # newer than Visual Studio 2015
    # merge modules relocated with Visual Studio 2017
    # https://github.com/smanders/externpro/issues/214
    if(NOT DEFINED msmDir)
      message(FATAL_ERROR "must define msmDir to a valid merge module directory")
    endif()
    if(NOT EXISTS ${msmDir} OR NOT IS_DIRECTORY ${msmDir})
      message(FATAL_ERROR "msmDir ('${msmDir}') does not exist or is not a directory")
    endif()
  else()
    set(PFX86 "ProgramFiles(x86)")
    file(TO_CMAKE_PATH "$ENV{${PFX86}}/Common Files/Merge Modules" msmDir)
  endif()
  xpGetCompilerPrefix(compiler)
  string(TOUPPER ${compiler} COMPILER)
  if(MSVC AND CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(ARCH x64)
  elseif(MSVC)
    set(ARCH x86)
  endif()
  set(xml "\n")
  xpStringIndentAppend(xml ${base}+0 "<DirectoryRef Id='TARGETDIR'>")
  foreach(id ${mergeModuleIds})
    set(msmPath ${msmDir}/Microsoft_${COMPILER}_${id}_${ARCH}.msm)
    if(EXISTS ${msmPath})
      xpStringIndentAppend(xml ${base}+1 "<Merge Id='${id}' SourceFile='${msmPath}' DiskId='1' Language='0'/>")
    else()
      message(AUTHOR_WARNING "merge module ${id} not found: ${msmPath}")
    endif()
  endforeach()
  xpStringIndentAppend(xml ${base}+0 "</DirectoryRef>")
  xpStringIndentAppend(xml ${base}+0 "<Feature Id='MergeModules' Title='Merge Modules' AllowAdvertise='no' Display='hidden' Level='1'>")
  foreach(id ${mergeModuleIds})
    xpStringIndentAppend(xml ${base}+1 "<MergeRef Id='${id}'/>")
  endforeach()
  xpStringIndentAppend(xml ${base}+0 "</Feature>")
  set(${appendTo} "${${appendTo}}${xml}" PARENT_SCOPE)
endfunction()

function(xpCpackWixDisableRM appendTo) # optional ARGV1
  if(${ARGC} EQUAL 2 AND ARGV1)
    set(base ${ARGV1})
  else()
    set(base 4) # main.wxs.in
  endif()
  set(xml "\n")
  xpStringIndentAppend(xml ${base}+0 "<Property Id='MSIRESTARTMANAGERCONTROL' Value='Disable'/>")
  set(${appendTo} "${${appendTo}}${xml}" PARENT_SCOPE)
endfunction()

function(xpCpackWixUpgradeCondition appendTo guid id prod) # optional ARGV4
  if(${ARGC} EQUAL 5 AND ARGV4)
    set(base ${ARGV4})
  else()
    set(base 4) # main.wxs.in
  endif()
  string(TOUPPER ${id} ID)
  set(xml "\n")
  xpStringIndentAppend(xml ${base}+0 "<Upgrade Id='${guid}'>")
  xpStringIndentAppend(xml ${base}+1 "<UpgradeVersion OnlyDetect='yes' Property='${ID}' Minimum='0.0.0000' />")
  xpStringIndentAppend(xml ${base}+0 "</Upgrade>")
  xpStringIndentAppend(xml ${base}+0 "<Condition Message='${prod} must be uninstalled prior to installation of this product.'>")
  xpStringIndentAppend(xml ${base}+1 "NOT ${ID}")
  xpStringIndentAppend(xml ${base}+0 "</Condition>")
  set(${appendTo} "${${appendTo}}${xml}" PARENT_SCOPE)
endfunction()

function(xpCpackWixUpgradeReplace appendTo guid ver4) # optional ARGV3
  if(${ARGC} EQUAL 4 AND ARGV3)
    set(base ${ARGV3})
  else()
    set(base 4) # main.wxs.in
  endif()
  set(xml "\n")
  # if ver4 looks like 1.2.3.10, ver3 would be 1.2.3
  string(REGEX REPLACE "([0-9]+)\\.([0-9]+)\\.([0-9]+)(\\.[0-9]+)?" "\\1.\\2.\\3" ver3 ${ver4})
  xpStringIndentAppend(xml ${base}+0 "<Upgrade Id='${guid}'>")
  # http://wix.tramontana.co.hu/tutorial/upgrades-and-modularization/replacing-ourselves
  xpStringIndentAppend(xml ${base}+1 "<UpgradeVersion OnlyDetect='no' Property='PREVIOUSFOUND' Minimum='0.0.0000' IncludeMinimum='yes'")
  xpStringIndentAppend(xml ${base}+2 "Maximum='${ver3}' IncludeMaximum='no' />")
  # http://windows-installer-xml-wix-toolset.687559.n2.nabble.com/Preventing-downgrades-as-a-launch-condition-tp4661741p4665418.html
  # TRICKY: msi sees 1.2.3.10 and 1.2.3.9 as 1.2.3 - they appear as the same
  # version. In order to prevent a downgrade on a 4th field change, rely on the
  # documented fact that msi ignores the 4th field to prevent installs where
  # the version numbers are identical to Windows Installer.
  xpStringIndentAppend(xml ${base}+1 "<UpgradeVersion OnlyDetect='yes' Property='ANOTHERBUILDINSTALLED' Minimum='${ver3}' Maximum='${ver3}'")
  xpStringIndentAppend(xml ${base}+2 "IncludeMinimum='yes' IncludeMaximum='yes' />")
  xpStringIndentAppend(xml ${base}+0 "</Upgrade>")
  xpStringIndentAppend(xml ${base}+0 "<CustomAction Id='BlockAnotherBuildInstall'")
  xpStringIndentAppend(xml ${base}+1 "Error='Another version of ${ver3} is already installed. Please uninstall ${ver3}.x before installing ${ver4}.' />")
  xpStringIndentAppend(xml ${base}+0 "<InstallExecuteSequence>")
  xpStringIndentAppend(xml ${base}+1 "<Custom Action='BlockAnotherBuildInstall' After='FindRelatedProducts'>")
  xpStringIndentAppend(xml ${base}+2 "<![CDATA[ANOTHERBUILDINSTALLED]]>")
  xpStringIndentAppend(xml ${base}+1 "</Custom>")
  xpStringIndentAppend(xml ${base}+0 "</InstallExecuteSequence>")
  set(${appendTo} "${${appendTo}}${xml}" PARENT_SCOPE)
endfunction()

function(xpCpackWixRunApp appendTo exe text) # optional ARGV3
  if(${ARGC} EQUAL 4 AND ARGV3)
    set(base ${ARGV3})
  else()
    set(base 2) # ca.wxs
  endif()
  set(xml "\n")
  # http://wixtoolset.org/documentation/manual/v3/howtos/ui_and_localization/run_program_after_install.html
  # Step 2: Add UI to your installer / Step 4: Trigger the custom action
  xpStringIndentAppend(xml ${base}+0 "<UI>")
  xpStringIndentAppend(xml ${base}+1 "<Publish")
  xpStringIndentAppend(xml ${base}+2 "Dialog='ExitDialog'")
  xpStringIndentAppend(xml ${base}+2 "Control='Finish'")
  xpStringIndentAppend(xml ${base}+2 "Event='DoAction'")
  xpStringIndentAppend(xml ${base}+2 "Value='LaunchApplication'")
  xpStringIndentAppend(xml ${base}+1 ">WIXUI_EXITDIALOGOPTIONALCHECKBOX = 1 and NOT Installed</Publish>")
  xpStringIndentAppend(xml ${base}+0 "</UI>")
  xpStringIndentAppend(xml ${base}+0 "<Property Id='WIXUI_EXITDIALOGOPTIONALCHECKBOX' Value='1' />")
  # How to disable "WIXUI_EXITDIALOGOPTIONALCHECKBOX" in exit dialog according to the condition?
  # http://wix-users.narkive.com/mX8KS6dB/how-to-disable-wixui-exitdialogoptionalcheckbox-in-exit-dialog-according-to-the-condition
  xpStringIndentAppend(xml ${base}+0 "<SetProperty Id='WIXUI_EXITDIALOGOPTIONALCHECKBOXTEXT' Value='${text}'")
  xpStringIndentAppend(xml ${base}+1 "After='ExecuteAction' Sequence='ui'")
  xpStringIndentAppend(xml ${base}+0 "><![CDATA[$CM_CP_${exe} = 3]]></SetProperty>")
  # Step 3: Include the custom action
  xpStringIndentAppend(xml ${base}+0 "<Property Id='WixShellExecTarget' Value='[#CM_FP_${exe}]' />")
  # http://stackoverflow.com/questions/2325459/executing-a-custom-action-that-requires-elevation-after-install
  xpStringIndentAppend(xml ${base}+0 "<CustomAction Id='LaunchApplication'")
  xpStringIndentAppend(xml ${base}+1 "BinaryKey='WixCA'")
  xpStringIndentAppend(xml ${base}+1 "DllEntry='WixShellExec'")
  xpStringIndentAppend(xml ${base}+1 "Impersonate='yes'")
  xpStringIndentAppend(xml ${base}+0 "/>")
  set(${appendTo} "${${appendTo}}${xml}" PARENT_SCOPE)
endfunction()

function(xpCpackWixCAFeature appendTo) # optional ARGV1
  if(${ARGC} EQUAL 2 AND ARGV1)
    set(base ${ARGV1})
  else()
    set(base 4) # main.wxs.in
  endif()
  set(xml "\n")
  xpStringIndentAppend(xml ${base}+0 "<Feature Id='CAFeature' Title='Custom Actions' AllowAdvertise='no' Display='hidden' Level='1'>")
  xpStringIndentAppend(xml ${base}+1 "<ComponentGroupRef Id='CAGroup'/>")
  xpStringIndentAppend(xml ${base}+0 "</Feature>")
  set(${appendTo} "${${appendTo}}${xml}" PARENT_SCOPE)
endfunction()

function(xpCpackWixCASet id exe args when _act _seq) # optional ARGV6
  set(base 2) # ca.wxs
  # CustomAction
  xpStringIndentAppend(act ${base}+0 "<CustomAction Id='${id}' Execute='deferred' Impersonate='no'")
  xpStringIndentAppend(act ${base}+1 "FileKey='CM_FP_${exe}' ExeCommand='${args}'")
  xpStringIndentAppend(act ${base}+0 "/>")
  set(${_act} "${${_act}}${act}" PARENT_SCOPE)
  # InstallExecuteSequence
  if(${ARGC} EQUAL 7 AND ARGV6)
    xpCpackWixCASeq(${id} ${exe} ${when} seq ${ARGV6})
  else()
    xpCpackWixCASeq(${id} ${exe} ${when} seq)
  endif()
  set(${_seq} "${${_seq}}${seq}" PARENT_SCOPE)
endfunction()

function(xpCpackWixCASetQt id exe args when _act _seq) # optional ARGV6
  set(base 2) # ca.wxs
  # CustomAction
  xpStringIndentAppend(act ${base}+0 "<CustomAction Id='${id}Cmd' Property='${id}'")
  xpStringIndentAppend(act ${base}+1 "Value='&quot\;[#CM_FP_${exe}]&quot\; ${args}'")
  xpStringIndentAppend(act ${base}+0 "/>")
  xpStringIndentAppend(act ${base}+0 "<CustomAction Id='${id}' Execute='deferred' Impersonate='no'")
  xpStringIndentAppend(act ${base}+1 "BinaryKey='WixCA' DllEntry='CAQuietExec64'")
  xpStringIndentAppend(act ${base}+0 "/>")
  set(${_act} "${${_act}}${act}" PARENT_SCOPE)
  # InstallExecuteSequence
  if(${ARGC} EQUAL 7 AND ARGV6)
    xpCpackWixCASeq(${id}Cmd ${exe} ${when} seq1 ${ARGV6})
  else()
    xpCpackWixCASeq(${id}Cmd ${exe} ${when} seq1)
  endif()
  xpCpackWixCASeq(${id} ${exe} ${when} seq2 ${id}Cmd)
  set(${_seq} "${${_seq}}${seq1}${seq2}" PARENT_SCOPE)
endfunction()

function(xpCpackWixCASeq id exe when _seq) # optional ARGV4
  set(base 2) # ca.wxs
  xpStringIndentAppend(seq ${base}+1 "<Custom Action='${id}'")
  # Conditional Statement Syntax (Access Prefixes, Feature and Component State Values)
  # https://msdn.microsoft.com/en-us/library/aa368012(VS.85).aspx
  if(${when} STREQUAL INS)
    set(before RegisterUser)
    set(condition "$CM_CP_${exe}&gt\;2")
  elseif(${when} STREQUAL SILENT_INS)
    set(before RegisterUser)
    # INSTALLUILEVEL_[NONE|BASIC|REDUCED|FULL] = [2|3|4|5]
    set(condition "$CM_CP_${exe}&gt\;2 AND UILevel&gt\;4")
  elseif(${when} STREQUAL UNINS)
    set(before UnpublishFeatures)
    set(condition "?CM_CP_${exe}=3 OR $CM_CP_${exe}=2")
  endif()
  if(${ARGC} EQUAL 5 AND ARGV4)
    xpStringIndentAppend(seq ${base}+2 "After='${ARGV4}'>")
  else()
    xpStringIndentAppend(seq ${base}+2 "Before='${before}'>")
  endif()
  xpStringIndentAppend(seq ${base}+2 "${condition}")
  xpStringIndentAppend(seq ${base}+1 "</Custom>")
  set(${_seq} "${seq}" PARENT_SCOPE)
endfunction()

function(xpCpackWixCAGroup filename) # optional ARGV1, ARGV2
  set(base 0) # ca.wxs
  xpStringIndentAppend(xml ${base}+0 "<?xml version='1.0' encoding='UTF-8'?>")
  xpStringIndentAppend(xml ${base}+0 "<Wix xmlns='http://schemas.microsoft.com/wix/2006/wi'")
  xpStringIndentAppend(xml ${base}+2 "xmlns:util='http://schemas.microsoft.com/wix/UtilExtension'>")
  xpStringIndentAppend(xml ${base}+1 "<Fragment>")
  xpStringIndentAppend(xml ${base}+2 "<ComponentGroup Id='CAGroup'/>")
  if(ARGV1) # custom action xml
    set(xml "${xml}${ARGV1}")
  endif()
  if(ARGV2) # install execute sequence xml
    xpStringIndentAppend(xml ${base}+2 "<InstallExecuteSequence>")
    set(xml "${xml}${ARGV2}")
    xpStringIndentAppend(xml ${base}+2 "</InstallExecuteSequence>")
  endif()
  xpStringIndentAppend(xml ${base}+1 "</Fragment>")
  xpStringIndentAppend(xml ${base}+0 "</Wix>")
  file(WRITE ${filename} ${xml})
endfunction()
