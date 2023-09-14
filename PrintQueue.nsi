;ReportQueue Installer
;Dont forget to change config version if ReportQueue is updated

;You'll want to change this to be the root of your SVN trunk directory
;!define SVN_ITRACK_TRUNK_DIR "C:\SVN\General\Installer"
!define SVN_ITRACK_TRUNK_DIR ..\components
!define REPORT_QUEUE_SOURCE_DIR ..\


;--------------------------------
;Lets add the plugin and include directories from SVN since they already have what we need
!addincludedir .\Include
!addplugindir .\Plugins

;!addincludedir "$EXEDIR\Include"
;!addplugindir "$EXEDIR\Include\Plugins"

;--------------------------------
;Includes

!include MUI.nsh
!include LogicLib.nsh
!include InstallOptions.nsh
!include Sections.nsh
!include FontRegAdv.nsh
!include FontName.nsh
!include StrFunc.nsh
!include x64.nsh

;--------------------------------
;Company

!define PRODUCT_NAME "ReportQueue"
!define PRODUCT_PUBLISHER "ISoft Data Systems"
!define PRODUCT_WEB_SITE "http://wikido.isoftdata.com/index.php"
!define WIKI_URL "${PRODUCT_WEB_SITE}/Internal:Print_Queue_Information"
;define SSL_Path "ca-cert.pem"

;---------------
;Directories

!define ROOT_FILES_DIR ..\components
!define COMPONENTS_DIR ..\components



!define CONFIG_PAGE_INI_NAME "PrintQueueConfigPage.ini"
;!define MYSQL_CONNECTOR_PYTHON_DIR "C:\Users\Robert McCown\Documents\Installers\Connector"

;--------------------------------

; General

;Installer Name
Name "${PRODUCT_NAME}"

;Where the compiled exe will be written to.
OutFile "${ROOT_FILES_DIR}\complete\${PRODUCT_NAME}Setup.exe"

; Do a CRC check when initializing setup.
CRCCheck On

;Default installation directory.  Can be changed by the user.
InstallDir "$PROGRAMFILES\${PRODUCT_PUBLISHER}\${PRODUCT_NAME}\"

;Lets hide the tech details during install.  User can show them if they want.
ShowInstDetails hide

;Lets hide the tech details during uninstall.  User can show them if they want.
;ShowUnInstDetails hide

BrandingText "${PRODUCT_PUBLISHER}, Inc."

;Request application privileges for Windows Vista/7.
RequestExecutionLevel admin

ReserveFile "PrintQueueConfigPage.ini"

Var mysql_database

;--------------------------------
;Interface Settings

; The bitmap image that appears on the first page on the left. Specific to a ITrack product.
;!define MUI_WELCOMEFINISHPAGE_BITMAP "Images\${PRODUCT_SPECIFIC_NAME}_Welcome.bmp"

;Lets use a header image
;!define MUI_HEADERIMAGE

;Tell it which image file to use for the header
;!define MUI_HEADERIMAGE_BITMAP "Images\${PRODUCT_SPECIFIC_NAME}_Header.bmp"

;Align the header image to the right
;!define MUI_HEADERIMAGE_RIGHT

; Causes yes/no dialog appear if the user presses cancel on the installer.
!define MUI_ABORTWARNING

; Text for bottom link on last page
!define MUI_FINISHPAGE_LINK "Visit the ${PRODUCT_PUBLISHER} Wiki for more information."

; Bottom link on last page
!define MUI_FINISHPAGE_LINK_LOCATION "${WIKI_URL}"

; Run PrintQueue Diagnostics Test
; !define MUI_FINISHPAGE_RUN "$PROGRAMFILES\${PRODUCT_PUBLISHER}\${PRODUCT_NAME}\PrintQueueDiagnostics.exe"
; !define MUI_FINISHPAGE_RUN_Text "Launch PrintQueueDiagnostics.exe"

;Installer icon
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"

; Make the description field be at the bottom and smaller on the components selection page.
!define MUI_COMPONENTSPAGE_SMALLDESC

;Uninstaller icon
;!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"

;--------------------------------
;Pages

; Welcome page
!insertmacro MUI_PAGE_WELCOME
; Directory page
!insertmacro MUI_PAGE_DIRECTORY
; Components page
;Page custom ConfigPage
Page custom SetCustom
!insertmacro MUI_PAGE_COMPONENTS
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
; Finish page
!insertmacro MUI_PAGE_FINISH
; Language
!insertmacro MUI_LANGUAGE "English"
; Uninstaller pages
;!insertmacro MUI_UNPAGE_INSTFILES

;--------------------------------

Section "Print Queue Python Script" SEC01


        BringToFront
        
        SectionIn RO ;Make this section read only(ie. required so it can't be unselected on the components page)
	DetailPrint "Debug install dir: $INSTDIR"
	DetailPrint "Debug rq dir: ${REPORT_QUEUE_SOURCE_DIR}"

        SetOutPath "$INSTDIR"
		File "${REPORT_QUEUE_SOURCE_DIR}\ReportQueueService.bat"
        ;File /nonfatal /a /r "${REPORT_QUEUE_SOURCE_DIR}\PrintQueue\"
        ;File "${REPORT_QUEUE_SOURCE_DIR}\PrintQueue.exe"

		File "${ROOT_FILES_DIR}\ca-cert.pem"
        File "${REPORT_QUEUE_SOURCE_DIR}\readme.md"
        ;File "${REPORT_QUEUE_SOURCE_DIR}\reportqueue_2020_03_20.zip"
        ;File "${REPORT_QUEUE_SOURCE_DIR}\reportqueue_dist_windowed.zip"
        ;File "${REPORT_QUEUE_SOURCE_DIR}\reportqueueservice.log"

        ;unzip reportqueuediagnostics
        SetOutPath "$INSTDIR\reportqueuediagnostics"
        File /nonfatal /a /r "${REPORT_QUEUE_SOURCE_DIR}\reportqueuediagnostics\"

        ;unzip nssm
        SetOutPath "$INSTDIR\nssm-2.24"	
		File /nonfatal /a /r "${REPORT_QUEUE_SOURCE_DIR}\nssm-2.24\" 

        ;unzip ReportQueue dist folder
        SetOutPath "$INSTDIR\"	
		File /nonfatal /a /r "${REPORT_QUEUE_SOURCE_DIR}\dist\"

        ;Make sure to give them the 3of9 barcode font
        StrCpy $FONT_DIR $FONTS

        !insertmacro InstallTTF '${COMPONENTS_DIR}\3OF9.TTF'

        SendMessage ${HWND_BROADCAST} ${WM_FONTCHANGE} 0 0 /TIMEOUT=5000
        
        ;Create ReportQueue and ReportQueueDiagnostics config file

        ;[database]
        ;sqlhost
        ReadINIStr $0 $PLUGINSDIR\PrintQueueConfigPage.ini "Field 3" "State"
        WriteINIStr $INSTDIR\config.ini database sqlhost $0

        ;sqluser
        ReadINIStr $0 $PLUGINSDIR\PrintQueueConfigPage.ini "Field 5" "State"
        WriteINIStr $INSTDIR\config.ini database sqluser $0

        ;sqlpassword
        ReadINIStr $0 $PLUGINSDIR\PrintQueueConfigPage.ini "Field 7" "State"
        WriteINIStr $INSTDIR\config.ini database sqlpassword $0
        
        ;database
        ReadINIStr $0 $PLUGINSDIR\PrintQueueConfigPage.ini "Field 9" "State"
        WriteINIStr $INSTDIR\config.ini database database $0
        
        ;odbcalias
        WriteINIStr $INSTDIR\config.ini database odbcalias "rq_$0"
		
		;use SSL
		ReadINIStr $0 $PLUGINSDIR\PrintQueueConfigPage.ini "Field 31" "State"
		 ${If} $0 == 1
              WriteINIStr $INSTDIR\config.ini database sslCA  "$INSTDIR\ca-cert.pem"
        ${ElseIf} $0 == 0
              WriteINIStr $INSTDIR\config.ini database sslCA  ""
        ${EndIf}
		
        ;[email]
        ;smtp server address
        ReadINIStr $0 $PLUGINSDIR\PrintQueueConfigPage.ini "Field 12" "State"
        WriteINIStr $INSTDIR\config.ini email emailserver $0
        
        ;from email address
        ReadINIStr $0 $PLUGINSDIR\PrintQueueConfigPage.ini "Field 14" "State"
        WriteINIStr $INSTDIR\config.ini email emailfrom $0		
		
		;username
		ReadINIStr $0 $PLUGINSDIR\PrintQueueConfigPage.ini "Field 16" "State"
		WriteINIStr $INSTDIR\config.ini email emailuser $0
        
		;password
		ReadINIStr $0 $PLUGINSDIR\PrintQueueConfigPage.ini "Field 18" "State"
		WriteINIStr $INSTDIR\config.ini email emailpassword $0     
		
        ;[other]
        ;polling time
        ReadINIStr $0 $PLUGINSDIR\PrintQueueConfigPage.ini "Field 24" "State"
        WriteINIStr $INSTDIR\config.ini other pollingtimeseconds $0
        
        ;path to commandlinebuilder.exe
        ReadINIStr $0 $PLUGINSDIR\PrintQueueConfigPage.ini "Field 26" "State"
        WriteINIStr $INSTDIR\config.ini other reportcommanderpath "$0"
        
        ;printer update refresh time
        ReadINIStr $0 $PLUGINSDIR\PrintQueueConfigPage.ini "Field 23" "State"
        WriteINIStr $INSTDIR\config.ini other statusdelayseconds $0

        ;enable default printer mode
        ReadINIStr $0 $PLUGINSDIR\PrintQueueConfigPage.ini "Field 30" "State"
        ${If} $0 == 1
            WriteINIStr $INSTDIR\config.ini other defaultprintermode "True"
        ${ElseIf} $0 == 0
              WriteINIStr $INSTDIR\config.ini other defaultprintermode "False"
        ${EndIf}

        ;enable adjustParameter mode (formerly strict mode)

        WriteINIStr $INSTDIR\config.ini other adjustreportparameters "True"

        ;product with additions for Presage
        ReadINIStr $0 $PLUGINSDIR\PrintQueueConfigPage.ini "Field 28" "State"
        ;WriteINIStr $INSTDIR\config.ini other product $0
		${If} $0 == "presage"
			;supposedly needed for Presage
            WriteINIStr $INSTDIR\config.ini other productcode "1"
            WriteINIStr $INSTDIR\config.ini other product $0	

        ${Else} 
            WriteINIStr $INSTDIR\config.ini other product $0	
        ${EndIf}
		
        ;write in remaining config defaults
        WriteINIStr $INSTDIR\config.ini other legacyprinting "True"
        WriteINIStr $INSTDIR\config.ini other rctimeout "300"
        WriteINIStr $INSTDIR\config.ini other compression "False"
        WriteINIStr $INSTDIR\config.ini other removefile "True"
        WriteINIStr $INSTDIR\config.ini other version "2023.04.10"


        WriteINIStr $INSTDIR\config.ini logging verbosesetting "True"
        WriteINIStr $INSTDIR\config.ini logging outputlevel "10"
        WriteINIStr $INSTDIR\config.ini logging csvlogging "False"
        WriteINIStr $INSTDIR\config.ini logging reportcommanderlogfile "rcLog.txt"
        WriteINIStr $INSTDIR\config.ini logging reportcommanderlogging "True"
        WriteINIStr $INSTDIR\config.ini logging reportcommanderlogappend "True"
        WriteINIStr $INSTDIR\config.ini logging reportcommanderdebug "False"

		;CALL InstallMicrosoftRedistributablePackages


        
SectionEnd

Section "InstallMicrosoftRedistributablePackages" SEC02
        BringToFront

        SetOutPath "$TEMP"

		; ${If} ${RunningX64}
		; 	File "${COMPONENTS_DIR}\vcredist_x64_2013.exe"
		; 	ExecWait '"msiexec" /i "$TEMP\vcredist_x64_2013.exe"'
		; ${Else}
		; 	File "${COMPONENTS_DIR}\vcredist_x86_2013.exe"
		; 	ExecWait '"msiexec" /i "$TEMP\vcredist_x86_2013.exe"'
		; ${EndIf}
        ;Microsoft Visual C++ 2010 x86 redistributable for ODBC driver (32 bit version)
	    File "${COMPONENTS_DIR}\vcredist_x86_2010.exe"
	    ExecWait "$TEMP\vcredist_x86_2010.exe /passive /norestart"

        ;Microsoft Visual C++ 2013 x86 redistributable for ODBC driver
		File "${COMPONENTS_DIR}\vcredist_x86_2013.exe"
		ExecWait "$TEMP\vcredist_x86_2013.exe /install /passive /norestart"


SectionEnd

	
;Section "MySQL ODBC Driver" SEC05
Section "MySQL ODBC Driver" SEC03
        BringToFront

        SetOutPath "$TEMP"

        File "${COMPONENTS_DIR}\mysql-connector-odbc-5.3.4-win32.msi"
        ExecWait '"msiexec" /i "$TEMP\mysql-connector-odbc-5.3.4-win32.msi"'
        
        ;Read in the database name from the ini file
        ReadINIStr $mysql_database "$INSTDIR\config.ini" "database" "database"
        ;Write out the entry for the new data source name
        WriteRegStr HKLM "Software\WOW6432Node\ODBC\ODBC.INI\ODBC Data Sources\" "rq_$mysql_database" "MySQL ODBC 5.3 ANSI Driver"
        
        ;Get the driver path
        ReadRegStr $0 HKLM "SOFTWARE\WOW6432Node\ODBC\ODBCINST.INI\MySQL ODBC 5.3 ANSI Driver" "Driver"
        ;Write the driver path for the new odbc configuration
        WriteRegStr HKLM "Software\WOW6432Node\ODBC\ODBC.INI\rq_$mysql_database" "Driver" "$0"
        
        ;Get the server name or ip
        ReadINIStr $0 "$INSTDIR\config.ini" "database" "sqlhost"
        ;Write the server name to odbc 
        WriteRegStr HKLM "Software\WOW6432Node\ODBC\ODBC.INI\rq_$mysql_database" "SERVER" "$0"
        
        ;Write the database name to odbc
        WriteRegStr HKLM "Software\WOW6432Node\ODBC\ODBC.INI\rq_$mysql_database" "DATABASE" "$mysql_database"

        ;Write the port number to odbc entry
        WriteRegStr HKLM "Software\WOW6432Node\ODBC\ODBC.INI\rq_$mysql_database" "PORT" "3306"
        
        ;Get the username
        ReadINIStr $0 "$INSTDIR\config.ini" "database" "sqluser"
        ;Write the username to odbc entry
        WriteRegStr HKLM "Software\WOW6432Node\ODBC\ODBC.INI\rq_$mysql_database" "UID" "$0"

        ;MySQL Password
        ReadINIStr $0 "$INSTDIR\config.ini" "database" "sqlpassword"
        ;Write the password to odbc entry
        WriteRegStr HKLM "Software\WOW6432Node\ODBC\ODBC.INI\rq_$mysql_database" "PWD" "$0"

        ;These are MySQL ODBC driver options we usually enable
        ;Allow big result sets
        WriteRegStr HKLM "Software\WOW6432Node\ODBC\ODBC.INI\rq_$mysql_database" "BIG_PACKETS" "1"
        ;Use compression
        WriteRegStr HKLM "Software\WOW6432Node\ODBC\ODBC.INI\rq_$mysql_database" "COMPRESSED_PROTO" "1"
        ;Enable automatic reconnect
        WriteRegStr HKLM "Software\WOW6432Node\ODBC\ODBC.INI\rq_$mysql_database" "AUTO_RECONNECT" "1"
        ;Don't prompt when connecting
        WriteRegStr HKLM "Software\WOW6432Node\ODBC\ODBC.INI\rq_$mysql_database" "NO_PROMPT" "1"
		
		; ReadINIStr $0 "$INSTDIR\config.ini" "database" "sslCA"
		; ${If} $0 > 1
		; 	;if sslCA field is filled out, add ODBC SSL CA entry
		; 	WriteRegStr HKLM "Software\WOW6432Node\ODBC\ODBC.INI\reportqueue_$mysql_database" "SSLCA" "$0"
		; ${EndIf}

        ReadINIStr $0 $PLUGINSDIR\PrintQueueConfigPage.ini "Field 30" "State"
        ${If} $0 == 1
            WriteRegStr HKLM "Software\WOW6432Node\ODBC\ODBC.INI\rq_$mysql_database" "SSLCA" "$INSTDIR\ca-cert.pem" 
        ${EndIf}    
			
    
SectionEnd

;Section "Scheduled Task or Windows Service" SEC04
Section "Run ReportQueue Diagnostics" SEC04
    ExecShell "runas" "$InstDir\reportqueuediagnostics\reportqueuediagnostics.exe"

SectionEnd

Section "Scheduled Task or Windows Service" SEC05

    ;ExecShell "" "$InstDir\taskschd.msc"
    ;ExecShell "" "$InstDir\ReportQueueService.bat"
    ExecWait "$InstDir\ReportQueueService.bat"


SectionEnd



!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC01} "Installs ${PRODUCT_NAME} and all of its required components."
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC02} "Installs dependencies for ${PRODUCT_NAME} and its components."
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC03} "Installs drivers used by ${PRODUCT_NAME} to make a connection to the server and access information."
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC04} "Runs ${PRODUCT_NAME} test script."
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC05} "Creates ${PRODUCT_NAME} service to run."
!insertmacro MUI_FUNCTION_DESCRIPTION_END

;Get the input
Function .onInit

        ;Extract InstallOptions files
        ;$PLUGINSDIR will automatically be removed when the installer closes
        InitPluginsDir
        File /oname=$PLUGINSDIR\PrintQueueConfigPage.ini "PrintQueueConfigPage.ini"

        SetOutPath "$TEMP"

        File "${ROOT_FILES_DIR}\ReportCommander_2.6_win32.exe"
        ExecWait "$TEMP\ReportCommander_2.6_win32.exe"

        ;ShowWindow $HWNDPARENT ${SW_SHOW}


FunctionEnd

Function SetCustom

         ;Display the InstallOptions dialog

         Push $1

         InstallOptions::dialog "$PLUGINSDIR\PrintQueueConfigPage.ini"
         Pop $1

         Pop $1

FunctionEnd
