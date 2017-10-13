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
		.Prompt		   = 'Generate binary files from all text files' && used in menus
		
		* Optional
		TEXT TO .Description NOSHOW && a description for the tool

If there is a FoxBin2Prg text file for the ActiveProject, generate the VFP binary files for it.

If there is no ActiveProject, or a FoxBin2Prg text file is not found for it, you will be prompted for a FoxBin2Prg project file to generate.

When running this tool from the Tool Launcher or the Thor Toolbar, you should first close all projects and execute a CLEAR ALL.
		ENDTEXT
		.StatusBarText = ''
		.CanRunAtStartUp = .F.

		* These are used to group and sort tools when they are displayed in menus or the Thor form
		.Source		   = '' && where did this tool come from?  Your own initials, for instance
		.Category      = 'Applications|FoxBin2Prg|Projects' && creates categorization of tools; defaults to .Source if empty
		.Sort		   = 90 && the sort order for all items from the same Category
		
		* For public tools, such as PEM Editor, etc.
		.Version	   = '' && e.g., 'Version 7, May 18, 2011'
		.Author        = 'Mike Potjer'
		.Link          = 'https://vfpx.codeplex.com/wikipage?title=Thor%20TWEeT%2025'

*!*			.PlugInClasses   = 'clsGetFoxBin2PrgFolderPlugIn'
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
#DEFINE TOOL_CAPTION	"Generate Project from FoxBin2Prg Text"

* The names of files we expect to find in the FoxBin2Prg folder.
#DEFINE FOXBIN2PRG_MAIN_EXE_FILENAME	"FoxBin2Prg.EXE"
#DEFINE FOXBIN2PRG_PROJECTFILE_EXT		"PJ2"

* Normal processing for this tool begins here.                  
PROCEDURE ToolCode
LPARAMETERS lxParam1

LOCAL lcFoxBin2PRGFolder, ;
	lcProjectName, ;
	loProject AS VisualFoxPro.IFoxProject, ;
	llProjectOpen, ;
	lcMessage, ;
	lnMessageIcon, ;
	loErrorInfo AS Exception

lcMessage = SPACE(0)

TRY
	* Retrieve the FoxBin2Prg folder.  The default function code only
	* returns an empty value if the folder was not found and the user
	* didn't select anything when prompted.
	lcFoxBin2PRGFolder = EXECSCRIPT( _Screen.cThorDispatcher, "Thor_Proc_GetFoxBin2PrgFolder" )
	IF EMPTY( m.lcFoxBin2PRGFolder )
		ERROR "FoxBin2Prg folder not found and not selected."
	ENDIF

	DO CASE
		CASE VARTYPE( m.lxParam1 ) = "C" ;
				AND NOT EMPTY( m.lxParam1 ) ;
				AND FILE( FORCEEXT( m.lxParam1, FOXBIN2PRG_PROJECTFILE_EXT ) )
			* The calling code specified a project with a FoxBin2Prg
			* text file.
			lcProjectName = FORCEEXT( m.lxParam1, FOXBIN2PRG_PROJECTFILE_EXT )

		CASE _VFP.Projects.Count > 0 ;
				AND FILE( FORCEEXT( _VFP.ActiveProject.Name, FOXBIN2PRG_PROJECTFILE_EXT ) )
			* There is a project open, and there is a FoxBin2Prg text
			* file for the active project.
			lcProjectName = FORCEEXT( _VFP.ActiveProject.Name, FOXBIN2PRG_PROJECTFILE_EXT )

		OTHERWISE
			* Prompt the user to select a project, either from an MRU
			* list or via a file open dialog.
			lcProjectName = EXECSCRIPT( _SCREEN.cThorDispatcher, "Thor_Proc_GetProjectName" )

			DO CASE
				CASE EMPTY( m.lcProjectName )
					* The user didn't select anything, so abort.
					ERROR "No project file selected."

				CASE FILE( FORCEEXT( m.lcProjectName, FOXBIN2PRG_PROJECTFILE_EXT ) )
					* A FoxBin2Prg text file exists, so process it.
					lcProjectName = FORCEEXT( m.lcProjectName, FOXBIN2PRG_PROJECTFILE_EXT )

				OTHERWISE
					* The user did not select a project with a text file.
					ERROR "There is no FoxBin2Prg text file for " + m.lcProjectName
			ENDCASE
	ENDCASE

	* Check if the selected project is open in the Project Manager.
	TRY
		loProject = _VFP.Projects( FORCEEXT( m.lcProjectName, "PJX" ) )
		llProjectOpen = .T.
	CATCH
		loProject = .NULL.
		llProjectOpen = .F.
	ENDTRY

	* The project is open, so close it before attempting to regenerate it.
	IF m.llProjectOpen
		loProject.Close()
	ENDIF

	IF IsObjectInCallStack( "formruntool*.runtool" ) ;
			OR IsObjectInCallStack( "thor_toolbar.button*.click" )
		* This tool was called from the Tool Launcher or the Thor toolbar.
		* In either of those situations a CLEAR ALL will fail.  In the
		* case of the Tool Launcher, there will also be numerous other
		* errors.  Skip the CLEAR ALL, but generate a warning to prepare
		* the user for the error message they are likely to receive from
		* FoxBin2Prg.
		lcMessage = "WARNING: FoxBin2Prg sometimes requires a CLEAR ALL to reliably regenerate " ;
				+ ".VCX files."
		IF m.llProjectOpen
			lcMessage = m.lcMessage + "  Before running this tool from the Tool Launcher or the Thor " ;
					+ "toolbar you should close the Project Manager and execute a CLEAR ALL."
		ELSE
			lcMessage = m.lcMessage + "  If FoxBin2Prg fails to generate the .VCX files, you will " ;
					+ "need to execute a CLEAR ALL and re-run this tool."
		ENDIF

		MESSAGEBOX( m.lcMessage, 48, TOOL_CAPTION, 8000 )
		lcMessage = SPACE(0)
	ELSE
		* If class libraries are not completely cleared from memory,
		* FoxBin2Prg will fail when attempting to regenerate the .VCX
		* files.  For some reason, even just opening the project manager
		* can lead to .VCX files being in memory.  The only solution
		* I've found is issue a CLEAR ALL.  But before we do that, we
		* need to preserve some information that is still needed after
		* the CLEAR ALL.
		ADDPROPERTY( _VFP, "cText2Bin_FoxBin2PrgFolder", m.lcFoxBin2PRGFolder )
		ADDPROPERTY( _VFP, "cText2Bin_ProjectName", m.lcProjectName )
		ADDPROPERTY( _VFP, "lText2Bin_ProjectOpen", m.llProjectOpen )

		CLEAR ALL

		* Restore the variables that we need to complete this function.
		LOCAL lcFoxBin2PRGFolder, ;
			lcProjectName, ;
			llProjectOpen, ;
			loErrorInfo, ;
			lcMessage, ;
			lnMessageIcon

		lcFoxBin2PRGFolder = _VFP.cText2Bin_FoxBin2PrgFolder
		lcProjectName = _VFP.cText2Bin_ProjectName
		llProjectOpen = _VFP.lText2Bin_ProjectOpen
	ENDIF

	* Regenerate the .PJX file and all the binaries included in that
	* project.
	DO ( m.lcFoxBin2PRGFolder + FOXBIN2PRG_MAIN_EXE_FILENAME ) WITH m.lcProjectName, "*"

	* Attempt to re-open the project that we closed earlier.
	IF m.llProjectOpen
		MODIFY PROJECT ( FORCEEXT( m.lcProjectName, "PJX" ) ) NOWAIT
	ENDIF

CATCH TO loErrorInfo
	* Some part of this process failed, so report the error.
	lcMessage = m.loErrorInfo.Message
	lnMessageIcon = 16	&& Stop sign icon

FINALLY
	* If a CLEAR ALL was issued (as indicated by the existence of properties
	* added to _VFP), and Thor was running, then restore Thor items like
	* toolbars which are closed by a CLEAR ALL.
	IF TYPE( "_VFP.cText2Bin_FoxBin2PrgFolder" ) = "C" ;
			AND TYPE( "_SCREEN.cThorDispatcher" ) = "C" ;
			AND NOT EMPTY( _SCREEN.cThorDispatcher )
		EXECSCRIPT( _SCREEN.cThorDispatcher, "Run" )
	ENDIF

	* Remove the properties we created for the CLEAR ALL.
	REMOVEPROPERTY( _VFP, "cText2Bin_FoxBin2PrgFolder" )
	REMOVEPROPERTY( _VFP, "cText2Bin_ProjectName" )
	REMOVEPROPERTY( _VFP, "lText2Bin_ProjectOpen" )
ENDTRY

* Display the results of this process, if applicable.
IF NOT EMPTY( m.lcMessage )
	lnMessageIcon = EVL( m.lnMessageIcon, 64 )	&& Use Information icon if empty
	MESSAGEBOX( m.lcMessage, m.lnMessageIcon, TOOL_CAPTION )

*!*		ASSERT .F. MESSAGE ALLTRIM( PROGRAM() ) + " failed!" + CHR(13) ;
*!*				+ m.loErrorInfo.Message + CHR(13) ;
*!*				+ "Select <Debug> to check out the problem."
ENDIF

ENDPROC

*********************************************************************
* A function to check the call stack to determine if a specified object
* is currently running.
*********************************************************************
FUNCTION IsObjectInCallStack
LPARAMETERS tcObjectName AS String

LOCAL laCallStack[1], ;
	lnStackCount, ;
	lcObjectName, ;
	llUseLike, ;
	llInCallStack, ;
	xx

llInCallStack = .F.
lcObjectName = LOWER( m.tcObjectName )
lnStackCount = ASTACKINFO( laCallStack )

* Determine whether to use LIKE() or an exact match.
llUseLike = ( "*" $ m.lcObjectName OR "?" $ m.lcObjectName )

FOR xx = 1 TO m.lnStackCount
	* Check if the specified name is the current item in the call stack.
	* If we have a match, stop looking and immediately exit the loop.
	DO CASE
		CASE m.llUseLike ;
				AND LIKE( m.lcObjectName, LOWER( laCallStack[m.xx, 3] ) )
			llInCallStack = .T.
			EXIT

		CASE NOT m.llUseLike ;
				AND m.lcObjectName $ LOWER( laCallStack[m.xx, 3] )
			llInCallStack = .T.
			EXIT

		OTHERWISE
			* This is not a match, so keep looking.
	ENDCASE
ENDFOR

RETURN m.llInCallStack

ENDFUNC

*********************************************************************
* This class defines the plug-in for returning the FoxBin2Prg folder,
* making it easy to point this tool at whatever folder you installed
* FoxBin2Prg into.
*********************************************************************
*!*	DEFINE CLASS clsGetFoxBin2PrgFolderPlugIn AS Custom

*!*		Source				= 'Create FoxBin2Prg "SendTo" shortcuts'
*!*		PlugIn				= 'Get FoxBin2Prg Folder'
*!*		Description			= 'Returns the full path to the folder where FoxBin2Prg is installed'
*!*		Tools				= 'Create FoxBin2Prg "SendTo" shortcuts'
*!*		FileNames			= 'Thor_Proc_GetFoxBin2PrgFolder.PRG'
*!*		DefaultFileName		= '*Thor_Proc_GetFoxBin2PrgFolder.PRG'
*!*		DefaultFileContents	= ''
*!*	ENDDEFINE
