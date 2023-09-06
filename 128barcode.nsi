;Barcode Installer

;--------------------------------
;Directories that may need to be edited by whoever is creating the installer
;You'll want to change this to be the root of your SVN trunk directory

!define SVN_ITRACK_TRUNK_DIR "C:\SVN\"

;Additional directories, see https://wikido.isoftdata.com/index.php?title=Internal:Maintaining_Installers
;for a list of files that are expected in each and where to get them

;Folder for additional installed components such as redistributables and additional tools, change to match your location

!define COMPONENTS_DIR "C:\installerComponents"

;Lets add the plugin and include directories from SVN since they already have the shit we need

!addincludedir ${SVN_ITRACK_TRUNK_DIR}\General\Installer\Include
!addplugindir ${SVN_ITRACK_TRUNK_DIR}\General\Installer\Plugins

;--------------------------------
;Includes for NSIS 

!include ${SVN_ITRACK_TRUNK_DIR}\General\Installer\Include\MUI.nsh
!include ${SVN_ITRACK_TRUNK_DIR}\General\Installer\Include\ZipDLL.nsh
!include ${SVN_ITRACK_TRUNK_DIR}\General\Installer\Include\LogicLib.nsh
!include ${SVN_ITRACK_TRUNK_DIR}\General\Installer\Include\InstallOptions.nsh
!include ${SVN_ITRACK_TRUNK_DIR}\General\Installer\Include\Sections.nsh
!include ${SVN_ITRACK_TRUNK_DIR}\General\Installer\Include\FontRegAdv.nsh
!include ${SVN_ITRACK_TRUNK_DIR}\General\Installer\Include\FontName.nsh

;---------------
; General

;Installer Name
Name "Barcode 128 Font Installer"
RequestExecutionLevel admin

;Where the compiled exe will be written to.  Change if it errors when writing file.
OutFile "${COMPONENTS_DIR}\${PRODUCT_NAME} Setup.exe"

; Do a CRC check when initializing setup.
CRCCheck On

;Lets hide the tech details during install.  User can show them if they want.
ShowInstDetails hide

;--------------------------------
;Interface Settings

;Lets use a header image
!define MUI_HEADERIMAGE

;Align the header image to the right
!define MUI_HEADERIMAGE_RIGHT

; Causes yes/no dialog appear if the user presses cancel on the installer.
!define MUI_ABORTWARNING

;Installer icon
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\orange-install.ico"

; Make the description field be at the bottom and smaller on the components selection page.
!define MUI_COMPONENTSPAGE_SMALLDESC

;Uninstaller icon
;!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\orange-uninstall.ico"

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
;Main Section

Section "Barcode 128 Font Installer" SEC01

        SectionIn RO ;Make this section read only(ie. required so it can't be unselected on the components page)
        
        ;They selected that they want Crystal, so lets give them the barcode font here too, that way if they ever print a tag they won't call us bitching
        StrCpy $FONT_DIR $FONTS

        !insertmacro InstallTTF '${COMPONENTS_DIR}\3OF9.TTF'

        SendMessage ${HWND_BROADCAST} ${WM_FONTCHANGE} 0 0 /TIMEOUT=5000

SectionEnd

        !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
               !insertmacro MUI_DESCRIPTION_TEXT ${SEC01} "Installs font barcode for ${PRODUCT_NAME}."
        !insertmacro MUI_FUNCTION_DESCRIPTION_END

;Get the input
Function .onInit

        ;Extract InstallOptions files
        ;$PLUGINSDIR will automatically be removed when the installer closes
        InitPluginsDir
        File /oname=$PLUGINSDIR\${PRODUCT_NAME}ConfigPage.ini "${PRODUCT_NAME}ConfigPage.ini"

        WriteINIStr $PLUGINSDIR\${PRODUCT_NAME}ConfigPage.ini "Field 7" "State" ${DEFAULT_PRODUCT_DATABASE_NAME}

FunctionEnd

Function SetCustom

         ;Display the InstallOptions dialog

         Push $1

         InstallOptions::dialog "$PLUGINSDIR\${PRODUCT_NAME}ConfigPage.ini"
         Pop $1

         Pop $1

FunctionEnd