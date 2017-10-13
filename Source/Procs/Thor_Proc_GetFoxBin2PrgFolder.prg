* The simplest way to customize this plug-in is to specify the full
* path to your installation of FoxBin2Prg in this constant, something
* like the following (the final backslash is optional, since it will
* be added later if you don't include it):
*!*	#DEFINE FOXBIN2PRG_CUSTOM_INSTALL_FOLDER	"C:\SomeFolder\SomeOtherFolder\MyFoxBin2Prg\"
#DEFINE FOXBIN2PRG_CUSTOM_INSTALL_FOLDER	""

* The subfolder of Thor's tools folder where we expect to find FoxBin2Prg
* installed.
#DEFINE FOXBIN2PRG_THOR_TOOLS_SUBFOLDER		"Components\FoxBin2Prg\"

* The name of the main EXE file we expect to find in the FoxBin2Prg folder.
#DEFINE FOXBIN2PRG_MAIN_EXE_FILENAME		"FoxBin2Prg.EXE"

LPARAMETERS tlDoNotPrompt

LOCAL lcFoxBin2PRGFolder

IF NOT EMPTY( FOXBIN2PRG_CUSTOM_INSTALL_FOLDER ) ;
		AND FILE( ADDBS( FOXBIN2PRG_CUSTOM_INSTALL_FOLDER ) + FOXBIN2PRG_MAIN_EXE_FILENAME )
	* The developer edited this plug-in and specified a valid install
	* folder for FoxBin2Prg.
	lcFoxBin2PRGFolder = ADDBS( FOXBIN2PRG_CUSTOM_INSTALL_FOLDER )
ELSE
	* Look for FoxBin2Prg under the Thor Tools folder.
	lcFoxBin2PRGFolder = EXECSCRIPT( _Screen.cThorDispatcher, "Tool Folder=" )
	lcFoxBin2PRGFolder = ADDBS( m.lcFoxBin2PRGFolder ) + FOXBIN2PRG_THOR_TOOLS_SUBFOLDER
ENDIF

* Verify the FoxBin2Prg folder, or check for alternate locations.
DO CASE
	CASE FILE( m.lcFoxBin2PRGFolder + FOXBIN2PRG_MAIN_EXE_FILENAME )
		* FoxBin2Prg was installed by Thor where we expect it.

	CASE FILE( ADDBS( JUSTPATH( SYS(16) ) ) + FOXBIN2PRG_MAIN_EXE_FILENAME )
		* FoxBin2Prg is in the same folder as this program.
		lcFoxBin2PRGFolder = ADDBS( JUSTPATH( SYS(16) ) )

	CASE FILE( FOXBIN2PRG_MAIN_EXE_FILENAME )
		* FoxBin2Prg was found in the current VFP path.
		lcFoxBin2PRGFolder = ADDBS( JUSTPATH( FULLPATH( FOXBIN2PRG_MAIN_EXE_FILENAME ) ) )

	CASE m.tlDoNotPrompt 
		* FoxBin2Prg not found, and we are not to prompt
		lcFoxBin2PRGFolder = SPACE(0)

	OTHERWISE
		* We don't know where FoxBin2Prg is located, so if it's installed,
		* let the developer tell us where it is.
		lcFoxBin2PRGFolder = SPACE(0)
		DO WHILE NOT FILE( m.lcFoxBin2PRGFolder + FOXBIN2PRG_MAIN_EXE_FILENAME )
			lcFoxBin2PRGFolder = GETDIR( _VFP.DefaultFilePath, ;
					"Select the folder where FoxBin2Prg is installed", ;
					"Find FoxBin2Prg Folder", 1+64 )

			* If the user doesn't select a folder, there's nothing more
			* to do here.
			IF EMPTY( m.lcFoxBin2PRGFolder )
				EXIT
			ELSE
				lcFoxBin2PRGFolder = ADDBS( m.lcFoxBin2PRGFolder )
			ENDIF
		ENDDO
ENDCASE

* Return result, both if called directly or using _Screen.cThorDispatcher
Return ExecScript(_Screen.cThorDispatcher, 'Result=', m.lcFoxBin2PRGFolder )

