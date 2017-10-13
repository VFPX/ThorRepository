LPARAMETERS lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

IF PCOUNT() = 1 ;
		AND 'O' = VARTYPE( m.lxParam1 ) ;
		AND 'thorinfo' == LOWER( m.lxParam1.Class )

	WITH lxParam1
	
		* Required
		.Prompt		   = 'Create/Edit FoxBin2Prg "SendTo" shortcuts' && used in menus
		
		* Optional
		TEXT TO .Description NOSHOW && a description for the tool
Allows you to create, edit, and remove shortcuts in the Windows Explorer "Send to" context menu for the following FoxBin2Prg functions:
	* Binary to Text
	* Text to Binary
	* Normalize FileNames
This tool works best if FoxBin2Prg has been installed by Thor, but you will be prompted for the FoxBin2Prg folder if this tool cannot find it.

Requires FoxBin2Prg version 1.19.39 or later.
		ENDTEXT
		.StatusBarText = ''
		.CanRunAtStartUp = .F.

		* These are used to group and sort tools when they are displayed in menus or the Thor form
		.Source		   = '' && where did this tool come from?  Your own initials, for instance
		.Category      = 'Applications|FoxBin2Prg' && creates categorization of tools; defaults to .Source if empty
		.Sort		   = 10 && the sort order for all items from the same Category
		
		* For public tools, such as PEM Editor, etc.
		.Version	   = 'Version 1.1, January 5, 2015' && e.g., 'Version 7, May 18, 2011'
		.Author        = 'Mike Potjer'
		.Link          = 'https://vfpx.codeplex.com/wikipage?title=Thor%20TWEeT%2025'

		.PlugInClasses   = 'clsGetFoxBin2PrgFolderPlugIn'
		.PlugIns		 = 'Get FoxBin2Prg Folder'
		
	ENDWITH

	RETURN m.lxParam1
ENDIF

IF PCOUNT() = 0
	DO ToolCode
ELSE
	DO ToolCode WITH m.lxParam1
ENDIF

RETURN

****************************************************************
****************************************************************
*{ MJP -- 12/23/2014 04:30:21 PM - Begin
* The name of the FoxBin2Prg executable.
#DEFINE FOXBIN2PRG_MAIN_EXE_FILENAME			"FoxBin2Prg.EXE"

* The parameters which can be passed to the EXE.
#DEFINE FOXBIN2PRG_BIN2PRG_ARGUMENT				"BIN2PRG"
#DEFINE FOXBIN2PRG_PRG2BIN_ARGUMENT				"PRG2BIN"
#DEFINE FOXBIN2PRG_INTERACTIVE_ARGUMENT			"INTERACTIVE"
#DEFINE FOXBIN2PRG_SHOWMESSAGE_ARGUMENT			"SHOWMSG"
*} MJP -- 12/23/2014 04:30:21 PM - End

* The names of script files we expect to find in the FoxBin2Prg folder.
#DEFINE FOXBIN2PRG_BIN2PRG_VBS_FILENAME			"Convert_VFP9_BIN_2_PRG.VBS"
#DEFINE FOXBIN2PRG_PRG2BIN_VBS_FILENAME			"Convert_VFP9_PRG_2_BIN.VBS"
#DEFINE FOXBIN2PRG_NORMALIZE_NAMES_VBS_FILENAME	"Normalize_Filenames.VBS"

* The default shortcut names to use.
#DEFINE FOXBIN2PRG_DEFAULT_BIN2TEXT_NAME	"FoxBin2Prg - Binary to Text"
#DEFINE FOXBIN2PRG_DEFAULT_TEXT2BIN_NAME	"FoxBin2Prg - Text to Binary"
#DEFINE FOXBIN2PRG_DEFAULT_CONVERT2WAY_NAME	"FoxBin2Prg - 2-Way Conversion"
#DEFINE FOXBIN2PRG_DEFAULT_NORMALIZE_NAME	"FoxBin2Prg - Normalize FileNames"

* The descriptions to use for the shortcuts.
#DEFINE FOXBIN2PRG_SHORTCUTDESC_BIN2TEXT	"Convert VFP binary files to FoxBin2Prg text files"
#DEFINE FOXBIN2PRG_SHORTCUTDESC_TEXT2BIN	"Convert FoxBin2Prg text files to VFP binary files"
#DEFINE FOXBIN2PRG_SHORTCUTDESC_CONVERT2WAY	"Convert to or from FoxBin2Prg text files"
#DEFINE FOXBIN2PRG_SHORTCUTDESC_NORMALIZE	"Normalize VFP file names for SCM"

* Define the type codes used for each shortcut.
#DEFINE FOXBIN2PRG_SHORTCUTTYPE_BIN2TEXT	"B"
#DEFINE FOXBIN2PRG_SHORTCUTTYPE_TEXT2BIN	"T"
#DEFINE FOXBIN2PRG_SHORTCUTTYPE_CONVERT2WAY	"2"
#DEFINE FOXBIN2PRG_SHORTCUTTYPE_NORMALIZE	"N"

* The WindowStyle settings used in shortcuts.  (This is for reference,
* since we really don't need them here.)
#DEFINE WINDOWSTYLE_NORMAL		1
#DEFINE WINDOWSTYLE_MAXIMIZE	3
#DEFINE WINDOWSTYLE_MINIMIZE	7

* Normal processing for this tool begins here.                  
PROCEDURE ToolCode
LPARAMETERS lxParam1

LOCAL loEngine AS FoxBin2Prg_EditShortcutsEngine OF "D:\Users\Mike\Documents\Repositories\SCM Tools\Thor_Tool_FoxBin2PrgCreateShortcuts.PRG"

loEngine = CREATEOBJECT( "FoxBin2Prg_EditShortcutsEngine" )

DO FORM ( EXECSCRIPT( _Screen.cThorDispatcher, "Full Path=Thor_Tool_FoxBin2PrgCreateShortcuts.SCX" ) ) WITH m.loEngine

* The commented code below is an example of loading the engine to
* programmatically create the shortcuts if they don't exist.

*!*	LOCAL loEngine AS FoxBin2Prg_EditShortcutsEngine OF "D:\Users\Mike\Documents\Repositories\SCM Tools\Thor_Tool_FoxBin2PrgCreateShortcuts.PRG", ;
*!*		lcMessage, ;
*!*		lnMessageIcon, ;
*!*		loErrorInfo AS Exception

*!*	lcMessage = SPACE(0)
*!*	lnMessageIcon = 64	&& Information icon

*!*	TRY
*!*		loEngine = CREATEOBJECT( "FoxBin2Prg_EditShortcutsEngine" )

*!*		*********************************************************************
*!*		* Create shortcut #1 - Binary to Text
*!*		*********************************************************************
*!*		* Initialize the message with the name of the shortcut being created.
*!*		lcMessage = m.lcMessage + "* " + m.loEngine.cBinToTextSCName + ": "

*!*		DO CASE
*!*			CASE NOT ISNULL( m.loEngine.oBinToTextShortcut )
*!*				* The shortcut already exists, so nothing to do.
*!*				lcMessage = m.lcMessage + "Already exists"

*!*			CASE m.loEngine.CreateShortcut( FOXBIN2PRG_SHORTCUTTYPE_BIN2TEXT )
*!*				* The shortcut was successfully created.
*!*				lcMessage = m.lcMessage + "Created"

*!*			OTHERWISE
*!*				* The CreateShortcut() method failed.
*!*				lcMessage = m.lcMessage + "Could not be created"
*!*		ENDCASE

*!*		lcMessage = m.lcMessage + CHR(13)

*!*		*********************************************************************
*!*		* Create shortcut #2 - Text to Binary
*!*		*********************************************************************
*!*		* Initialize the message with the name of the shortcut being created.
*!*		lcMessage = m.lcMessage + "* " + m.loEngine.cTextToBinSCName + ": "

*!*		DO CASE
*!*			CASE NOT ISNULL( m.loEngine.oTextToBinShortcut )
*!*				* The shortcut already exists, so nothing to do.
*!*				lcMessage = m.lcMessage + "Already exists"

*!*			CASE m.loEngine.CreateShortcut( FOXBIN2PRG_SHORTCUTTYPE_TEXT2BIN )
*!*				* The shortcut was successfully created.
*!*				lcMessage = m.lcMessage + "Created"

*!*			OTHERWISE
*!*				* The CreateShortcut() method failed.
*!*				lcMessage = m.lcMessage + "Could not be created"
*!*		ENDCASE

*!*		lcMessage = m.lcMessage + CHR(13)

*!*		*********************************************************************
*!*		* Create shortcut #3 - Normalize file names
*!*		*********************************************************************
*!*		* Initialize the message with the name of the shortcut being created.
*!*		lcMessage = m.lcMessage + "* " + m.loEngine.cNormalizeSCName + ": "

*!*		DO CASE
*!*			CASE NOT ISNULL( m.loEngine.oNormalizeShortcut )
*!*				* The shortcut already exists, so nothing to do.
*!*				lcMessage = m.lcMessage + "Already exists"

*!*			CASE m.loEngine.CreateShortcut( FOXBIN2PRG_SHORTCUTTYPE_NORMALIZE )
*!*				* The shortcut was successfully created.
*!*				lcMessage = m.lcMessage + "Created"

*!*			OTHERWISE
*!*				* The CreateShortcut() method failed.
*!*				lcMessage = m.lcMessage + "Could not be created"
*!*		ENDCASE

*!*		lcMessage = m.lcMessage + CHR(13)

*!*	CATCH TO loErrorInfo
*!*		* Some part of this process failed, so report the error.
*!*		lcMessage = m.loErrorInfo.Message
*!*		lnMessageIcon = 16	&& Stop sign icon
*!*	ENDTRY

*!*	* Display the results of this process.
*!*	MESSAGEBOX( m.lcMessage, m.lnMessageIcon, "Create FoxBin2Prg Shortcuts" )

ENDPROC

*********************************************************************
* This class defines the plug-in for returning the FoxBin2Prg folder,
* making it easy to point this tool at whatever folder you installed
* FoxBin2Prg into.
*********************************************************************
DEFINE CLASS clsGetFoxBin2PrgFolderPlugIn AS Custom

	Source				= 'Create/Edit FoxBin2Prg "SendTo" shortcuts'
	PlugIn				= 'Get FoxBin2Prg Folder'
	Description			= 'Returns the full path to the folder where FoxBin2Prg is installed'
	Tools				= 'Create/Edit FoxBin2Prg "SendTo" shortcuts' ;
						+ ', Convert Project files to FoxBin2Prg text' ;
						+ ', Generate Project files from FoxBin2Prg text'
	FileNames			= 'Thor_Proc_GetFoxBin2PrgFolder.PRG'
	DefaultFileName		= '*Thor_Proc_GetFoxBin2PrgFolder.PRG'
	DefaultFileContents	= ''
ENDDEFINE


*********************************************************************
* This class handles all the non-visual aspects of creating and maintaining
* the Windows "Send to" shortcuts for FoxBin2Prg.
*********************************************************************
DEFINE CLASS FoxBin2Prg_EditShortcutsEngine AS Custom

* Stores a reference to the Windows Script Host shell object, WScript.Shell,
* so that we don't need to recreate it every time it's needed.
PROTECTED oWSHShell
oWSHShell = .NULL.

* Stores a reference to the Shell.Application object used for certain
* functions of this class, so that it doesn't need to be recreated
* every time it's needed.
PROTECTED oShellApp
oShellApp = .NULL.

* Stores a reference to the Scripting.FileSystemObject class used for
* certain functions of this class, so that it doesn't need to be recreated
* every time it's needed.
PROTECTED oFileSystem
oFileSystem = .NULL.

* These properties store the full path to the Windows "Send to" folder
* for the current user, and the full path to the FoxBin2Prg app.
cUserSendToFolder = ""
cFoxBin2PrgFolder = ""

* These properties store the shortcut object, WScript.WshShortcut, for
* the "Binary to Text" shortcut, and the name used for the shortcut.
oBinToTextShortcut = .NULL.
cBinToTextSCName = ""
lBinToTextShowResultMessage = .F.

* These properties store the shortcut object for the "Text to Binary"
* shortcut, and the name used for the shortcut.
oTextToBinShortcut = .NULL.
cTextToBinSCName = ""
lTextToBinShowResultMessage = .F.

*{ MJP -- 12/23/2014 05:06:02 PM - Begin
* These properties store the shortcut object for the "Interactive"
* convertion shortcut, the name used for the shortcut, and whether a
* result message should be displayed.
oConvert2WayShortcut = .NULL.
cConvert2WaySCName = ""
lConvert2WayShowResultMessage = .F.
*} MJP -- 12/23/2014 05:06:02 PM - End

* These properties store the shortcut object for the "Normalize FileNames"
* shortcut, and the name used for the shortcut.
oNormalizeShortcut = .NULL.
cNormalizeSCName = ""

PROCEDURE Init
	LOCAL loWSHShell AS WSCRIPT.Shell

	* Instantiate the Windows objects used to interact with the file
	* system.
	This.oWSHShell = CREATEOBJECT( "WScript.Shell" )
	This.oShellApp = CREATEOBJECT( "Shell.Application" )
	This.oFileSystem = CREATEOBJECT( "Scripting.FileSystemObject" )

	* Attempt to retrieve the path to the "Send to" folder for the
	* current user.
	loWSHShell = This.oWSHShell
	This.cUserSendToFolder = ADDBS( m.loWSHShell.SpecialFolders( "SendTo" ) )

	* Attempt to retreive the full path to the folder where FoxBin2Prg
	* is installed.
	This.cFoxBin2PrgFolder = EXECSCRIPT( _Screen.cThorDispatcher, "Thor_Proc_GetFoxBin2PrgFolder" )

	* Initialize this class with the shortcuts that it maintains.
	This.LoadShortcuts()
ENDPROC

PROCEDURE Destroy
	* Clean up the object references stored in this class.
	STORE .NULL. TO This.oWSHShell, ;
					This.oShellApp, ;
					This.oFileSystem, ;
					This.oBinToTextShortcut, ;
					This.oTextToBinShortcut, ;
					This.oConvert2WayShortcut, ;
					This.oNormalizeShortcut
ENDPROC

*********************************************************************
* This method sets the default shortcut names to use for all the shortcuts
* maintained by this class.
*********************************************************************
PROCEDURE InitShortcutNames
	* Set a default shortcut name only if a name has not already been
	* been specified, and the shortcut doesn't exist.
	IF EMPTY( This.cBinToTextSCName ) ;
			AND ISNULL( This.oBinToTextShortcut )
		This.cBinToTextSCName = FOXBIN2PRG_DEFAULT_BIN2TEXT_NAME
	ENDIF

	IF EMPTY( This.cTextToBinSCName ) ;
			AND ISNULL( This.oTextToBinShortcut )
		This.cTextToBinSCName = FOXBIN2PRG_DEFAULT_TEXT2BIN_NAME
	ENDIF

	*{ MJP -- 12/23/2014 05:09:26 PM - Begin
	IF EMPTY( This.cConvert2WaySCName ) ;
			AND ISNULL( This.oConvert2WayShortcut )
		This.cConvert2WaySCName = FOXBIN2PRG_DEFAULT_CONVERT2WAY_NAME
	ENDIF
	*} MJP -- 12/23/2014 05:09:26 PM - End

	IF EMPTY( This.cNormalizeSCName ) ;
			AND ISNULL( This.oNormalizeShortcut )
		This.cNormalizeSCName = FOXBIN2PRG_DEFAULT_NORMALIZE_NAME
	ENDIF
ENDPROC

*********************************************************************
* This method attempts to find the shortcuts maintained by this class,
* and set the shortcut object and name properties for them.
*********************************************************************
PROCEDURE LoadShortcuts
	LOCAL laShortcuts[1], ;
		lnShortcutCount, ;
		loWSHShell AS WSCRIPT.Shell, ;
		loShortcut AS WSCRIPT.WshShortcut, ;
		lcTargetFileName, ;
		lcArguments, ;
		xx

	* Note that the shortcut object property will be NULL if the shortcut
	* doesn't exist.
	STORE .NULL. TO This.oBinToTextShortcut, ;
					This.oTextToBinShortcut, ;
					This.oNormalizeShortcut

	* Retrieve a list of all shortcut files in "Send to" folder.
	lnShortcutCount = ADIR( laShortcuts, This.cUserSendToFolder + "*.LNK", SPACE(0), 1 )

	* If there are no shortcuts there at all, make sure the names are
	* initialized, and exit.
	IF m.lnShortcutCount = 0
		This.InitShortcutNames()
		RETURN
	ENDIF

	loWSHShell = This.oWSHShell

	FOR xx = 1 TO m.lnShortcutCount
		* Retrieve the shortcut object for the current file, and get
		* just the file name of the program it runs.
		loShortcut = m.loWSHShell.CreateShortcut( This.cUserSendToFolder + laShortcuts[m.xx, 1] )
		lcTargetFileName = UPPER( JUSTFNAME( m.loShortcut.TargetPath ) )

		*{ MJP -- 12/23/2014 04:32:32 PM - Begin
		* Since the FoxBin2Prg executable can now be called directly
		* by passing parameters, we need to check the arguments being
		* passed to the target file.
		lcArguments = m.loShortcut.Arguments
		*} MJP -- 12/23/2014 04:32:32 PM - End

		* Check if the current shortcut file is one of the shortcuts
		* for FoxBin2Prg.  If so, we need to store a reference to the
		* shortcut object, and the current name of the shortcut.
		*-- MJP -- 12/23/2014 04:36:30 PM
		* Now that BIN2PRG and PRG2BIN can also be accomplished by
		* passing parameters to the EXE, the CASE statements need to
		* be modified to account for that.
		*-- MJP -- 01/02/2015 11:55:43 AM
		* The "show results" flags are now being set to match settings
		* in the shortcut.
		DO CASE
			CASE m.lcTargetFileName == UPPER( FOXBIN2PRG_BIN2PRG_VBS_FILENAME ) ;
					OR ( m.lcTargetFileName == UPPER( FOXBIN2PRG_MAIN_EXE_FILENAME ) ;
						AND ATC( FOXBIN2PRG_BIN2PRG_ARGUMENT, m.lcArguments ) > 0 )
				This.oBinToTextShortcut = m.loShortcut
				This.cBinToTextSCName = JUSTSTEM( m.loShortcut.FullName )
				This.lBinToTextShowResultMessage = ( ATC( FOXBIN2PRG_SHOWMESSAGE_ARGUMENT, m.lcArguments ) > 0 )

			CASE m.lcTargetFileName == UPPER( FOXBIN2PRG_PRG2BIN_VBS_FILENAME ) ;
					OR ( m.lcTargetFileName == UPPER( FOXBIN2PRG_MAIN_EXE_FILENAME ) ;
						AND ATC( FOXBIN2PRG_PRG2BIN_ARGUMENT, m.lcArguments ) > 0 )
				This.oTextToBinShortcut = m.loShortcut
				This.cTextToBinSCName = JUSTSTEM( m.loShortcut.FullName )
				This.lTextToBinShowResultMessage = ( ATC( FOXBIN2PRG_SHOWMESSAGE_ARGUMENT, m.lcArguments ) > 0 )

			*{ MJP -- 12/23/2014 05:15:53 PM - Begin
			* The 2-way converter is interactive, but does NOT include
			* either of the 1-way conversion keywords.
			CASE m.lcTargetFileName == UPPER( FOXBIN2PRG_MAIN_EXE_FILENAME ) ;
					AND ATC( FOXBIN2PRG_INTERACTIVE_ARGUMENT, m.lcArguments ) > 0 ;
					AND ATC( FOXBIN2PRG_BIN2PRG_ARGUMENT, m.lcArguments ) = 0 ;
					AND ATC( FOXBIN2PRG_PRG2BIN_ARGUMENT, m.lcArguments ) = 0
				This.oConvert2WayShortcut = m.loShortcut
				This.cConvert2WaySCName = JUSTSTEM( m.loShortcut.FullName )
				This.lConvert2WayShowResultMessage = ( ATC( FOXBIN2PRG_SHOWMESSAGE_ARGUMENT, m.lcArguments ) > 0 )
			*} MJP -- 12/23/2014 05:15:53 PM - End

			CASE m.lcTargetFileName == UPPER( FOXBIN2PRG_NORMALIZE_NAMES_VBS_FILENAME )
				This.oNormalizeShortcut = m.loShortcut
				This.cNormalizeSCName = JUSTSTEM( m.loShortcut.FullName )

			OTHERWISE
				* We're not interested in this shortcut, so ignore it.
		ENDCASE
	ENDFOR

	* Make sure any blank shortcut names are initialized.
	This.InitShortcutNames()
ENDPROC

*********************************************************************
* This method determines whether the specified shortcut exists.
*********************************************************************
FUNCTION ShortcutExists
	LPARAMETERS tcShortcutType AS String

	LOCAL lcShortcutType, ;
		llExists

	lcShortcutType = UPPER( LEFT( m.tcShortcutType, 1 ) )
	llExists = .F.

	* Check if the shortcut object exists for the specified type.
	DO CASE
		CASE m.lcShortcutType == FOXBIN2PRG_SHORTCUTTYPE_BIN2TEXT
			llExists = NOT ISNULL( This.oBinToTextShortcut )

		CASE m.lcShortcutType == FOXBIN2PRG_SHORTCUTTYPE_TEXT2BIN
			llExists = NOT ISNULL( This.oTextToBinShortcut )

		*{ MJP -- 12/23/2014 05:21:05 PM - Begin
		CASE m.lcShortcutType == FOXBIN2PRG_SHORTCUTTYPE_CONVERT2WAY
			llExists = NOT ISNULL( This.oConvert2WayShortcut )
		*} MJP -- 12/23/2014 05:21:05 PM - End

		CASE m.lcShortcutType == FOXBIN2PRG_SHORTCUTTYPE_NORMALIZE
			llExists = NOT ISNULL( This.oNormalizeShortcut )

		OTHERWISE
			* There is no such shortcut type, so treat it as if it
			* doesn't exist.
	ENDCASE

	RETURN m.llExists
ENDFUNC

*********************************************************************
* This method determines if the shortcut name property for a particular
* shortcut has been changed from the name currently used in the existing
* shortcut.
*********************************************************************
FUNCTION ShortcutNameChanged
	LPARAMETERS tcShortcutType AS String

	LOCAL lcShortcutType, ;
		llChanged, ;
		loShortcut AS WSCRIPT.WshShortcut, ;
		lcName

	lcShortcutType = UPPER( LEFT( m.tcShortcutType, 1 ) )
	llChanged = .F.

	* Retrieve the shortcut object and the name currently stored in its
	* associated property.
	DO CASE
		CASE m.lcShortcutType == FOXBIN2PRG_SHORTCUTTYPE_BIN2TEXT
			loShortcut = This.oBinToTextShortcut
			lcName = This.cBinToTextSCName

		CASE m.lcShortcutType == FOXBIN2PRG_SHORTCUTTYPE_TEXT2BIN
			loShortcut = This.oTextToBinShortcut
			lcName = This.cTextToBinSCName

		*{ MJP -- 12/23/2014 05:25:32 PM - Begin
		CASE m.lcShortcutType == FOXBIN2PRG_SHORTCUTTYPE_CONVERT2WAY
			loShortcut = This.oConvert2WayShortcut
			lcName = This.cConvert2WaySCName
		*} MJP -- 12/23/2014 05:25:32 PM - End

		CASE m.lcShortcutType == FOXBIN2PRG_SHORTCUTTYPE_NORMALIZE
			loShortcut = This.oNormalizeShortcut
			lcName = This.cNormalizeSCName

		OTHERWISE
			loShortcut = .NULL.
			lcName = SPACE(0)
	ENDCASE

	* If the shortcut exists, there is a shortcut name, and the name
	* of the shortcut is different from the name stored in the corresponding
	* property of this class, then the name has been changed and will
	* need to be saved.
	IF NOT ISNULL( m.loShortcut ) ;
			AND NOT EMPTY( m.lcName ) ;
			AND NOT ALLTRIM( m.lcName ) == ALLTRIM( JUSTSTEM( m.loShortcut.FullName ) )
		llChanged = .T.
	ENDIF

	RETURN m.llChanged
ENDFUNC

*********************************************************************
* This method if the show results flag for a specified shortcut is
* different from the current setting in the shortcut.
*********************************************************************
FUNCTION ShortcutShowResultsChanged
	LPARAMETERS tcShortcutType AS String

	LOCAL lcShortcutType, ;
		llChanged, ;
		loShortcut AS WSCRIPT.WshShortcut, ;
		llShowResults

	lcShortcutType = UPPER( LEFT( m.tcShortcutType, 1 ) )
	llChanged = .F.

	* Retrieve the shortcut object and the current show results setting
	* stored in its associated property.
	DO CASE
		CASE m.lcShortcutType == FOXBIN2PRG_SHORTCUTTYPE_BIN2TEXT
			loShortcut = This.oBinToTextShortcut
			llShowResults = This.lBinToTextShowResultMessage

		CASE m.lcShortcutType == FOXBIN2PRG_SHORTCUTTYPE_TEXT2BIN
			loShortcut = This.oTextToBinShortcut
			llShowResults = This.lTextToBinShowResultMessage

		CASE m.lcShortcutType == FOXBIN2PRG_SHORTCUTTYPE_CONVERT2WAY
			loShortcut = This.oConvert2WayShortcut
			llShowResults = This.lConvert2WayShowResultMessage

		OTHERWISE
			* The shortcut type is invalid, or doesn't have a show
			* results setting.
			loShortcut = .NULL.
			llShowResults = .NULL.
	ENDCASE

	* Determine if the flag has changed.
	DO CASE
		CASE ISNULL( m.loShortcut ) ;
				OR ISNULL( m.llShowResults )
			* There's no shortcut for this type, or the flag doesn't
			* apply.

		CASE m.llShowResults ;
				AND ATC( FOXBIN2PRG_SHOWMESSAGE_ARGUMENT, m.loShortcut.Arguments ) = 0
			* The flag is set in the property, but not set in the shortcut.
			llChanged = .T.

		CASE NOT m.llShowResults ;
				AND ATC( FOXBIN2PRG_SHOWMESSAGE_ARGUMENT, m.loShortcut.Arguments ) > 0
			* The flag is not set in the property, but is set in the
			* shortcut.
			llChanged = .T.

		OTHERWISE
			* The property and the shortcut match, no change.
	ENDCASE

	RETURN m.llChanged
ENDFUNC

*********************************************************************
* This method attempts to create the specified shortcut.
*********************************************************************
FUNCTION CreateShortcut
	LPARAMETERS tcShortcutType AS String

	LOCAL lcShortcutType, ;
		llCreated, ;
		loShortcut AS WSCRIPT.WshShortcut, ;
		lcName, ;
		lcObjectProperty, ;
		lcTargetFile, ;
		lcArguments, ;
		lcDescription, ;
		lcDefaultIcon

	lcShortcutType = UPPER( LEFT( m.tcShortcutType, 1 ) )
	llCreated = .F.

	* Make sure the shortcut names are populated before attempting to
	* create the shortcut.
	This.InitShortcutNames()

	* Determine which shortcut is to be created.  Set the name for the
	* shortcut, the target file, the description, and the name of the
	* property where the shortcut object is to be stored.
	*-- MJP -- 12/23/2014 04:44:48 PM
	* For the BIN2PRG and PRG2BIN shortcuts, use the EXE instead and
	* pass arguments to execute that task.
	DO CASE
		CASE m.lcShortcutType == FOXBIN2PRG_SHORTCUTTYPE_BIN2TEXT
			lcName = This.cBinToTextSCName
			lcTargetFile = FOXBIN2PRG_MAIN_EXE_FILENAME	&& FOXBIN2PRG_BIN2PRG_VBS_FILENAME
			lcArguments = ["] ;
					+ IIF( This.lBinToTextShowResultMessage, FOXBIN2PRG_SHOWMESSAGE_ARGUMENT + "-", SPACE(0) ) ;
					+ FOXBIN2PRG_BIN2PRG_ARGUMENT + ["]
			lcDescription = FOXBIN2PRG_SHORTCUTDESC_BIN2TEXT
			lcObjectProperty = "oBinToTextShortcut"

		CASE m.lcShortcutType == FOXBIN2PRG_SHORTCUTTYPE_TEXT2BIN
			lcName = This.cTextToBinSCName
			lcTargetFile = FOXBIN2PRG_MAIN_EXE_FILENAME	&& FOXBIN2PRG_PRG2BIN_VBS_FILENAME
			lcArguments = ["] ;
					+ IIF( This.lTextToBinShowResultMessage, FOXBIN2PRG_SHOWMESSAGE_ARGUMENT + "-", SPACE(0) ) ;
					+ FOXBIN2PRG_PRG2BIN_ARGUMENT + ["]
			lcDescription = FOXBIN2PRG_SHORTCUTDESC_TEXT2BIN
			lcObjectProperty = "oTextToBinShortcut"

		*{ MJP -- 12/23/2014 05:30:29 PM - Begin
		CASE m.lcShortcutType == FOXBIN2PRG_SHORTCUTTYPE_CONVERT2WAY
			lcName = This.cConvert2WaySCName
			lcTargetFile = FOXBIN2PRG_MAIN_EXE_FILENAME
			lcArguments = ["] ;
					+ IIF( This.lConvert2WayShowResultMessage, FOXBIN2PRG_SHOWMESSAGE_ARGUMENT + "-", SPACE(0) ) ;
					+ FOXBIN2PRG_INTERACTIVE_ARGUMENT + ["]
			lcDescription = FOXBIN2PRG_SHORTCUTDESC_CONVERT2WAY
			lcObjectProperty = "oConvert2WayShortcut"
		*} MJP -- 12/23/2014 05:30:29 PM - End

		CASE m.lcShortcutType == FOXBIN2PRG_SHORTCUTTYPE_NORMALIZE
			lcName = This.cNormalizeSCName
			lcTargetFile = FOXBIN2PRG_NORMALIZE_NAMES_VBS_FILENAME
			lcArguments = SPACE(0)
			lcDescription = FOXBIN2PRG_SHORTCUTDESC_NORMALIZE
			lcObjectProperty = "oNormalizeShortcut"

		OTHERWISE
			RETURN m.llCreated
	ENDCASE

	* Look for the folder where VFP 9.0 is installed.  If we can find
	* it, associate the VFP "fox head" icon with the shortcut being
	* created.
	IF FILE( HOME(1) + "VFP9.EXE" )
		lcDefaultIcon = HOME(1) + "VFP9.EXE" + ",0"
	ELSE
		lcDefaultIcon = SPACE(0)
	ENDIF

	* Generate the shortcut object and set its properties.
	loShortcut = This.oWSHShell.CreateShortcut( This.cUserSendToFolder + FORCEEXT( m.lcName, "lnk" ) )
	loShortcut.TargetPath = This.cFoxBin2PrgFolder + m.lcTargetFile
	*-- MJP -- 12/23/2014 04:51:46 PM
	* Include arguments specified for the shortcut.
	loShortcut.Arguments = m.lcArguments
	loShortcut.Description = m.lcDescription
	IF NOT EMPTY( m.lcDefaultIcon )
		loShortcut.IconLocation = m.lcDefaultIcon
	ENDIF

	* Attempt to save the shortcut, and check if we were successful.
	loShortcut.Save()
	llCreated = FILE( This.cUserSendToFolder + FORCEEXT( m.lcName, "lnk" ) )

	* If the shortcut was created, store a reference to the shortcut
	* object in a property of this class.
	IF m.llCreated
		STORE m.loShortcut TO ( "This." + m.lcObjectProperty )
	ENDIF

	RETURN m.llCreated
ENDFUNC

*********************************************************************
* This method attempts to save the name entered in the property of this
* class as the new name for the corresponding shortcut.
*********************************************************************
FUNCTION SaveShortcuts
	LPARAMETERS tcShortcutTypes AS String

	LOCAL lcShortcutTypes, ;
		loShortcut AS WSCRIPT.WshShortcut, ;
		lcFullName, ;
		llSuccess

	IF VARTYPE( m.tcShortcutTypes ) = "C" ;
			AND NOT EMPTY( m.tcShortcutTypes )
		* One or more specific shortcut types were specified, so format
		* that value and only process what was indicated.
		lcShortcutTypes = UPPER( m.tcShortcutTypes )
	ELSE
		*-- Nothing was specified, so save name changes for all shortcuts.
		lcShortcutTypes = FOXBIN2PRG_SHORTCUTTYPE_BIN2TEXT ;
				+ FOXBIN2PRG_SHORTCUTTYPE_TEXT2BIN ;
				+ FOXBIN2PRG_SHORTCUTTYPE_CONVERT2WAY ;
				+ FOXBIN2PRG_SHORTCUTTYPE_NORMALIZE
	ENDIF

	llSuccess = .T.

	* Check which shortcut types need to be saved.
	*!* *{ MJP -- 01/05/2015 11:36:30 - Begin
	*!* IF FOXBIN2PRG_SHORTCUTTYPE_BIN2TEXT $ m.lcShortcutTypes ;
	*!* 		AND This.ShortcutNameChanged( FOXBIN2PRG_SHORTCUTTYPE_BIN2TEXT )
	IF FOXBIN2PRG_SHORTCUTTYPE_BIN2TEXT $ m.lcShortcutTypes
		IF This.ShortcutNameChanged( FOXBIN2PRG_SHORTCUTTYPE_BIN2TEXT )
	*!* *} MJP -- 01/05/2015 11:36:30 - End
			* A new name was specified for the shortcut.  The only way
			* to apply the new name is to rename the file.  We don't
			* want to use VFP's RENAME command, because it doesn't
			* preserve the case of the file name, converting everything
			* to lowercase.
			loShortcut = This.oBinToTextShortcut
			lcFullName = This.cUserSendToFolder + FORCEEXT( This.cBinToTextSCName, "lnk" )
			This.oFileSystem.Movefile( m.loShortcut.FullName, m.lcFullName )

			* Check if the name was saved properly.
			IF FILE( m.lcFullName )
				This.oBinToTextShortcut = This.oWSHShell.CreateShortcut( m.lcFullName )
			ELSE
				llSuccess = .F.
				This.oBinToTextShortcut = .NULL.
			ENDIF
		ENDIF

		*{ MJP -- 01/05/2015 11:37:45 AM - Begin
		IF This.ShortcutShowResultsChanged( FOXBIN2PRG_SHORTCUTTYPE_BIN2TEXT )
			* The show results flag has changed for this shortcut type,
			* so update the shortcut arguments for the current setting.
			loShortcut = This.oBinToTextShortcut
			loShortcut.Arguments = ["] ;
					+ IIF( This.lBinToTextShowResultMessage, FOXBIN2PRG_SHOWMESSAGE_ARGUMENT + "-", SPACE(0) ) ;
					+ FOXBIN2PRG_BIN2PRG_ARGUMENT + ["]
			loShortcut.Save()
		ENDIF
		*} MJP -- 01/05/2015 11:37:45 AM - End
	ENDIF

	IF FOXBIN2PRG_SHORTCUTTYPE_TEXT2BIN $ m.lcShortcutTypes
		IF This.ShortcutNameChanged( FOXBIN2PRG_SHORTCUTTYPE_TEXT2BIN )
			loShortcut = This.oTextToBinShortcut
			lcFullName = This.cUserSendToFolder + FORCEEXT( This.cTextToBinSCName, "lnk" )
			This.oFileSystem.Movefile( m.loShortcut.FullName, m.lcFullName )

			IF FILE( m.lcFullName )
				This.oTextToBinShortcut = This.oWSHShell.CreateShortcut( m.lcFullName )
			ELSE
				llSuccess = .F.
				This.oTextToBinShortcut = .NULL.
			ENDIF
		ENDIF

		*{ MJP -- 01/05/2015 11:44:27 AM - Begin
		IF This.ShortcutShowResultsChanged( FOXBIN2PRG_SHORTCUTTYPE_TEXT2BIN )
			loShortcut = This.oTextToBinShortcut
			loShortcut.Arguments = ["] ;
					+ IIF( This.lTextToBinShowResultMessage, FOXBIN2PRG_SHOWMESSAGE_ARGUMENT + "-", SPACE(0) ) ;
					+ FOXBIN2PRG_PRG2BIN_ARGUMENT + ["]
			loShortcut.Save()
		ENDIF
		*} MJP -- 01/05/2015 11:44:27 AM - End
	ENDIF

	*{ MJP -- 12/23/2014 05:35:20 PM - Begin
	IF FOXBIN2PRG_SHORTCUTTYPE_CONVERT2WAY $ m.lcShortcutTypes
		IF This.ShortcutNameChanged( FOXBIN2PRG_SHORTCUTTYPE_CONVERT2WAY )
			loShortcut = This.oConvert2WayShortcut
			lcFullName = This.cUserSendToFolder + FORCEEXT( This.cConvert2WaySCName, "lnk" )
			This.oFileSystem.Movefile( m.loShortcut.FullName, m.lcFullName )

			IF FILE( m.lcFullName )
				This.oConvert2WayShortcut = This.oWSHShell.CreateShortcut( m.lcFullName )
			ELSE
				llSuccess = .F.
				This.oConvert2WayShortcut = .NULL.
			ENDIF
		ENDIF

		IF This.ShortcutShowResultsChanged( FOXBIN2PRG_SHORTCUTTYPE_CONVERT2WAY )
			loShortcut = This.oConvert2WayShortcut
			loShortcut.Arguments = ["] ;
					+ IIF( This.lConvert2WayShowResultMessage, FOXBIN2PRG_SHOWMESSAGE_ARGUMENT + "-", SPACE(0) ) ;
					+ FOXBIN2PRG_INTERACTIVE_ARGUMENT + ["]
			loShortcut.Save()
		ENDIF
	ENDIF
	*} MJP -- 12/23/2014 05:35:20 PM - End

	IF FOXBIN2PRG_SHORTCUTTYPE_NORMALIZE $ m.lcShortcutTypes ;
			AND This.ShortcutNameChanged( FOXBIN2PRG_SHORTCUTTYPE_NORMALIZE )
		loShortcut = This.oNormalizeShortcut
		lcFullName = This.cUserSendToFolder + FORCEEXT( This.cNormalizeSCName, "lnk" )
		This.oFileSystem.Movefile( m.loShortcut.FullName, m.lcFullName )

		IF FILE( m.lcFullName )
			This.oNormalizeShortcut = This.oWSHShell.CreateShortcut( m.lcFullName )
		ELSE
			llSuccess = .F.
			This.oNormalizeShortcut = .NULL.
		ENDIF
	ENDIF

	RETURN m.llSuccess
ENDFUNC

*********************************************************************
* This method attempts to open the file properties window for a shortcut
* to allow the user to edit any of the settings for the shortcut.
*********************************************************************
PROCEDURE EditShortcut
	LPARAMETERS tcShortcutType AS String

	LOCAL lcShortcutType, ;
		loShortcut AS WSCRIPT.WshShortcut

	lcShortcutType = UPPER( LEFT( m.tcShortcutType, 1 ) )

	* Get the shortcut object for the shortcut whose properties are to
	* be edited.
	DO CASE
		CASE m.lcShortcutType == FOXBIN2PRG_SHORTCUTTYPE_BIN2TEXT
			loShortcut = This.oBinToTextShortcut

		CASE m.lcShortcutType == FOXBIN2PRG_SHORTCUTTYPE_TEXT2BIN
			loShortcut = This.oTextToBinShortcut

		*{ MJP -- 12/23/2014 05:37:32 PM - Begin
		CASE m.lcShortcutType == FOXBIN2PRG_SHORTCUTTYPE_CONVERT2WAY
			loShortcut = This.oConvert2WayShortcut
		*} MJP -- 12/23/2014 05:37:32 PM - End

		CASE m.lcShortcutType == FOXBIN2PRG_SHORTCUTTYPE_NORMALIZE
			loShortcut = This.oNormalizeShortcut

		OTHERWISE
			loShortcut = .NULL.
	ENDCASE

	IF NOT ISNULL( m.loShortcut )
		* Make sure any name change has been saved before opening the
		* dialog.
		This.SaveShortcuts( m.lcShortcutType )

		* Use ShellExecute to run the task that normally occurs when
		* you select "Properties" from the context menu for the .LNK
		* file.
		This.oShellApp.ShellExecute( m.loShortcut.FullName, "", "", "Properties" )
	ENDIF
ENDPROC

*********************************************************************
* This method attempts to remove a shortcut.
*********************************************************************
PROCEDURE RemoveShortcut
	LPARAMETERS tcShortcutType AS String

	LOCAL lcShortcutType, ;
		loShortcut AS WScript.WshShortcut

	lcShortcutType = UPPER( LEFT( m.tcShortcutType, 1 ) )
	llRemoved = .F.

	* Determine which shortcut is being removed, and clear the shortcut
	* object stored in a property of this class.
	DO CASE
		CASE m.lcShortcutType == FOXBIN2PRG_SHORTCUTTYPE_BIN2TEXT
			loShortcut = This.oBinToTextShortcut
			This.oBinToTextShortcut = .NULL.

		CASE m.lcShortcutType == FOXBIN2PRG_SHORTCUTTYPE_TEXT2BIN
			loShortcut = This.oTextToBinShortcut
			This.oTextToBinShortcut = .NULL.

		*{ MJP -- 12/23/2014 05:38:18 PM - Begin
		CASE m.lcShortcutType == FOXBIN2PRG_SHORTCUTTYPE_CONVERT2WAY
			loShortcut = This.oConvert2WayShortcut
			This.oConvert2WayShortcut = .NULL.
		*} MJP -- 12/23/2014 05:38:18 PM - End

		CASE m.lcShortcutType == FOXBIN2PRG_SHORTCUTTYPE_NORMALIZE
			loShortcut = This.oNormalizeShortcut
			This.oNormalizeShortcut = .NULL.

		OTHERWISE
			loShortcut = .NULL.
	ENDCASE

	IF NOT ISNULL( m.loShortcut )
		* We just need to erase the .LNK file.  Discard it to the recycle
		* bin so that user can easily restore it.
		ERASE ( m.loShortcut.FullName ) RECYCLE
	ENDIF
ENDPROC

*{ MJP -- 12/16/2014 03:17:38 PM - Begin
*********************************************************************
* Displays the user's "Send to" folder in Windows Explorer.
*********************************************************************
PROCEDURE ViewSendToFolder
	* If the folder hasn't been found yet, do nothing, otherwise use
	* another Thor proc to display it.
	IF EMPTY( This.cUserSendToFolder )
		RETURN .F.
	ELSE
		EXECSCRIPT( _Screen.cThorDispatcher, 'Thor_Proc_OpenFolder', This.cUserSendToFolder )
	ENDIF
ENDPROC

*} MJP -- 12/16/2014 03:17:38 PM - End

ENDDEFINE
