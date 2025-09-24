;Copyright 2004-2021 John T. Haller
;Website: https://portableapps.com/go/jPortable

;This software is OSI Certified Open Source Software.
;OSI Certified is a certification mark of the Open Source Initiative.

;This program is free software; you can redistribute it and/or
;modify it under the terms of the GNU General Public License
;as published by the Free Software Foundation; either version 2
;of the License, or (at your option) any later version.

;This program is distributed in the hope that it will be useful,
;but WITHOUT ANY WARRANTY; without even the implied warranty of
;MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;GNU General Public License for more details.

;You should have received a copy of the GNU General Public License
;along with this program; if not, write to the Free Software
;Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

!define PORTABLEAPPNAME "jPortable Launcher"
!define NAME "JavaPortableLauncher"
!define APPNAME "Java Apps"
!define VER "6.0.0.0"
!define WEBSITE "https://portableapps.com/go/jPortableLauncher"
!define LAUNCHERLANGUAGE "English"

;=== Program Details
Name "${PORTABLEAPPNAME}"
OutFile "..\..\${NAME}.exe"
Caption "${PORTABLEAPPNAME} | PortableApps.com"
VIProductVersion "${VER}"
VIAddVersionKey ProductName "${PORTABLEAPPNAME}"
VIAddVersionKey Comments "Allows ${APPNAME} to be run from a removable drive.  For additional details, visit ${WEBSITE}"
VIAddVersionKey CompanyName "PortableApps.com"
VIAddVersionKey LegalCopyright "John T. Haller"
VIAddVersionKey FileDescription "${PORTABLEAPPNAME}"
VIAddVersionKey FileVersion "${VER}"
VIAddVersionKey ProductVersion "${VER}"
VIAddVersionKey InternalName "${PORTABLEAPPNAME}"
VIAddVersionKey LegalTrademarks "PortableApps.com is a Trademark of Rare Ideas, LLC."
VIAddVersionKey OriginalFilename "${NAME}.exe"
;VIAddVersionKey PrivateBuild ""
;VIAddVersionKey SpecialBuild ""

;=== Runtime Switches
Unicode true
ManifestDPIAware true
CRCCheck On
WindowIcon Off
SilentInstall Silent
AutoCloseWindow True
RequestExecutionLevel user
XPStyle On

; Best Compression
SetCompress Auto
SetCompressor /SOLID lzma
SetCompressorDictSize 32
SetDatablockOptimize On

;=== Include
;(Standard NSIS)
!include LogicLib.nsh
!include Registry.nsh
!include FileFunc.nsh
!insertmacro GetFilename
!insertmacro GetParameters
!insertmacro GetParent
!include WordFunc.nsh
!insertmacro WordReplace

;(Custom)
!include ReadINIStrWithDefault.nsh

;=== Program Icon
Icon "..\..\App\AppInfo\appicon.ico"

;=== Languages
LoadLanguageFile "${NSISDIR}\Contrib\Language files\${LAUNCHERLANGUAGE}.nlf"
!include PortableApps.comLauncherLANG_${LAUNCHERLANGUAGE}.nsh

Var PortableAppsPath
Var MISSINGFILEORPATH
Var JarPath
Var LastPathUsed
Var JavaPath
Var strAdditionalParameters
Var strExecString
Var strJARFilename
Var strJavaBitDepth
Var strJavaRuntime

Section "Main"
	${GetParent} $EXEDIR $PortableAppsPath

	;Get JAR passed in if present
	${GetParameters} $JarPath
	${WordReplace} $JarPath '"' "" "+" $JarPath ;Removes quotes
	
	${If} $JarPath == ""
		;Prompt the user for the JAR
		${ReadINIStrWithDefault} $LastPathUsed "$EXEDIR\Data\JavaPortableLauncher.ini" "JavaPortableLauncher" "LastPathUsed" ""
		${If} $LastPathUsed == ""
			StrCpy $LastPathUsed $0
		${Else}
			${IfNot} ${FileExists} $LastPathUsed
				StrCpy $1 $LastPathUsed "" 2
				${If} ${FileExists} "$0$1"
					StrCpy $LastPathUsed "$0$1"
				${Else}
					StrCpy $LastPathUsed $0
				${EndIf}
			${EndIf}
		${EndIf}
		nsDialogs::SelectFileDialog open $LastPathUsed "JAR Files|*.jar|All Files|*.*"
		Pop $JarPath
		${If} $JarPath != ""
			CreateDirectory "$EXEDIR\Data"
			${GetParent} $JarPath $0
			WriteINIStr "$EXEDIR\Data\JavaPortableLauncher.ini" "JavaPortableLauncher" "LastPathUsed" "$0"
		${EndIf}
	${EndIf}
	
	;Check For Additional Settings
	${If} ${FileExists} "$JarPath.portable.ini"
		${ReadINIStrWithDefault} $strAdditionalParameters "$JarPath.portable.ini" "jPortableLauncher" "AdditionalParamaters" ""
		${ReadINIStrWithDefault} $strJavaBitDepth "$JarPath.portable.ini" "jPortableLauncher" "JavaBitDepth" "auto"
		${ReadINIStrWithDefault} $strJavaRuntime "$JarPath.portable.ini" "jPortableLauncher" "JavaRuntime" "auto"
	${Else}
		StrCpy $strAdditionalParameters ""
		StrCpy $strJavaBitDepth "auto"
		StrCpy $strJavaRuntime "auto"
	${EndIf}
	
	${If} $strJavaBitDepth == "auto"
	${AndIf} $strJavaRuntime == "auto"
		${If} ${FileExists} "$PortableAppsPath\CommonFiles\OpenJDK64\bin\javaw.exe"
			StrCpy $JavaPath "$PortableAppsPath\CommonFiles\OpenJDK64"
		${ElseIf} ${FileExists} "$PortableAppsPath\CommonFiles\Java64\bin\javaw.exe"
			StrCpy $JavaPath "$PortableAppsPath\CommonFiles\Java64"
		${ElseIf} ${FileExists} "$PortableAppsPath\CommonFiles\JDK64\jre\bin\javaw.exe"
			StrCpy $JavaPath "$PortableAppsPath\CommonFiles\JDK64\jre"
		${ElseIf} ${FileExists} "$PortableAppsPath\CommonFiles\OpenJDKJRE64\bin\javaw.exe"
			StrCpy $JavaPath "$PortableAppsPath\CommonFiles\OpenJDKJRE64"
		${ElseIf} ${FileExists} "$PortableAppsPath\CommonFiles\OpenJDK\bin\javaw.exe"
			StrCpy $JavaPath "$PortableAppsPath\CommonFiles\OpenJDK"
		${ElseIf} ${FileExists} "$PortableAppsPath\CommonFiles\Java\bin\javaw.exe"
			StrCpy $JavaPath "$PortableAppsPath\CommonFiles\Java"
		${ElseIf} ${FileExists} "$PortableAppsPath\CommonFiles\JDK\jre\bin\javaw.exe"
			StrCpy $JavaPath "$PortableAppsPath\CommonFiles\JDK\jre"
		${ElseIf} ${FileExists} "$PortableAppsPath\CommonFiles\OpenJDKJRE\bin\javaw.exe"
			StrCpy $JavaPath "$PortableAppsPath\CommonFiles\OpenJDKJRE"
		${Else}
			StrCpy $JavaPath "NONE"
		${EndIf}
	${ElseIf} $strJavaRuntime == "auto"
	${AndIf} $strJavaBitDepth != "auto"
		${If} $strJavaBitDepth == "64"
			StrCpy $0 "64"
		${Else}
			StrCpy $0 ""
		${EndIf}
		${If} ${FileExists} "$PortableAppsPath\CommonFiles\OpenJDK$0\bin\javaw.exe"
			StrCpy $JavaPath "$PortableAppsPath\CommonFiles\OpenJDK$0"
		${ElseIf} ${FileExists} "$PortableAppsPath\CommonFiles\Java$0\bin\javaw.exe"
			StrCpy $JavaPath "$PortableAppsPath\CommonFiles\Java$0"
		${ElseIf} ${FileExists} "$PortableAppsPath\CommonFiles\JDK$0\jre\bin\javaw.exe"
			StrCpy $JavaPath "$PortableAppsPath\CommonFiles\JDK$0\jre"
		${ElseIf} ${FileExists} "$PortableAppsPath\CommonFiles\OpenJDKJRE$0\bin\javaw.exe"
			StrCpy $JavaPath "$PortableAppsPath\CommonFiles\OpenJDKJRE$0"
		${Else}
			StrCpy $JavaPath "NONE"
		${EndIf}
	${Else}
		${If} $strJavaBitDepth == "64"
			StrCpy $0 "64"
		${Else}
			StrCpy $0 ""
		${EndIf}
		${Switch} $strJavaRuntime
			${Case} "OpenJDK"
				StrCpy $JavaPath "$PortableAppsPath\CommonFiles\OpenJDK$0"
				${Break}
			${Case} "jdkPortable"
				StrCpy $JavaPath "$PortableAppsPath\CommonFiles\JDK$0\jre"
				${Break}
			${Case} "jPortable"
				StrCpy $JavaPath "$PortableAppsPath\CommonFiles\Java$0"
				${Break}
			${Case} "OpenJDKJRE"
				StrCpy $JavaPath "$PortableAppsPath\CommonFiles\OpenJDKJRE$0"
				${Break}
			${Default}
				StrCpy $JavaPath "NONE"
				${Break}
		${EndSwitch}
	${EndIf}

	${If} $JavaPath != "NONE"
		SetOutPath $0
		${WordReplace} $JarPath '"' "" "+" $JarPath ;Removes quotes
		${If} $JarPath != ""
			${If} ${FileExists} "$JavaPath\bin\javaw.exe"
				${If} ${FileExists} "$JarPath"
					;Set our environment variables
					System::Call 'Kernel32::SetEnvironmentVariable(t, t) i("JAVAHOME", "$JavaPath").r0'
					System::Call 'Kernel32::SetEnvironmentVariable(t, t) i("CLASSPATH", ".").r0'
					CreateDirectory "$EXEDIR\Data"
					CreateDirectory "$EXEDIR\Data\AppData"
					System::Call 'Kernel32::SetEnvironmentVariable(t, t) i("APPDATA", "$EXEDIR\Data\AppData").r0'
					

					StrCpy $strExecString `"$JavaPath\bin\javaw.exe"`

					
					;Run
					${GetFileName} $JarPath $strJARFilename

					StrCpy $9 $JarPath "" -4
					${If} $9 == "jnlp"
						StrCpy $strExecString `"$JavaPath\bin\javaws.exe" "$JarPath" -J`
					${Else}
						${If} $strAdditionalParameters != ""
							StrCpy $strExecString `"$JavaPath\bin\java.exe" -Duser.home="$EXEDIR\Data\AppData" $strAdditionalParameters -jar "$JarPath"`
							${Else}
							StrCpy $strExecString `"$JavaPath\bin\javaw.exe" -Duser.home="$EXEDIR\Data\AppData" -jar "$JarPath"`		
						${EndIf}
					${EndIf}

					ExecWait $strExecString
					
					;Cleanup ProgramData timestamps
					SetShellVarContext all
					StrCpy $9 $APPDATA
					SetShellVarContext current
					${If} ${FileExists} "$9\Oracle\Java\.oracle_jre_usage\*.timestamp"
						FindFirst $0 $1 "$9\Oracle\Java\.oracle_jre_usage\*.timestamp"
						CleanupProgramDataLoop:
							StrCmp $1 "" CleanupProgramDataLoopDone
							StrCmp $1 "." CleanupProgramDataLoopNext
							StrCmp $1 ".." CleanupProgramDataLoopNext
							${If} ${FileExists} "$9\Oracle\Java\.oracle_jre_usage\$1"
								ClearErrors
								StrCpy $3 ""
								FileOpen $2 "$9\Oracle\Java\.oracle_jre_usage\$1" r
								IfErrors DoneReadingArguments
									FileRead $2 $3
									FileClose $2
								DoneReadingArguments:
								${WordReplace} $3 "$\r$\n" "" "+" $3 ;Remove line break
								${If} $3 == $JavaPath
									Delete "$9\Oracle\Java\.oracle_jre_usage\$1"
								${EndIf}
							${EndIf}
							CleanupProgramDataLoopNext:
							FindNext $0 $1
							Goto CleanupProgramDataLoop
						CleanupProgramDataLoopDone:
						FindClose $0
					${EndIf}
					RMDir "$9\Oracle\Java\.oracle_jre_usage"
					RMDir "$9\Oracle\Java"
					RMDir "$9\Oracle"
				${Else}
					StrCpy $MISSINGFILEORPATH $JarPath
					MessageBox MB_OK|MB_ICONINFORMATION `$(LauncherFileNotFound)`
				${EndIf}
			${Else}
				StrCpy $MISSINGFILEORPATH "$JavaPath\bin\javaw.exe"
				MessageBox MB_OK|MB_ICONINFORMATION `$(LauncherFileNotFound)`
			${EndIf}
		${EndIf}
	${Else}
		StrCpy $MISSINGFILEORPATH "jPortable/jdkPortable/OpenJDK"
		MessageBox MB_OK|MB_ICONINFORMATION `$(LauncherFileNotFound)`
	${EndIf}
SectionEnd