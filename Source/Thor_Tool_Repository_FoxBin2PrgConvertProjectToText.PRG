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
		.Prompt		   = 'Convert all binary files to text files'
		
		* Optional
		TEXT TO .Description NOSHOW && a description for the tool
Convert all VFP binary files in the ActiveProject to FoxBin2Prg text format.
If there is no ActiveProject, you will be prompted for a project to convert.
		ENDTEXT
		.StatusBarText = ''
		.CanRunAtStartUp = .F.

		* These are used to group and sort tools when they are displayed in menus or the Thor form
		.Source		   = '' && where did this tool come from?  Your own initials, for instance
		.Category      = 'Applications|FoxBin2Prg|Projects' && creates categorization of tools; defaults to .Source if empty
		.Sort		   = 20 && the sort order for all items from the same Category
		
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
* The names of files we expect to find in the FoxBin2Prg folder.
#DEFINE FOXBIN2PRG_MAIN_EXE_FILENAME			"FoxBin2Prg.EXE"

* Normal processing for this tool begins here.                  
PROCEDURE ToolCode
LPARAMETERS lxParam1

LOCAL lcFoxBin2PRGFolder, ;
	lcProjectName, ;
	lcMessage, ;
	lnMessageIcon, ;
	loErrorInfo AS Exception

lcMessage = SPACE(0)
lnMessageIcon = 64	&& Information icon

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
				AND FILE( m.lxParam1 )
			* The code that called this tool specified the name of the
			* project to convert.
			lcProjectName = m.lxParam1

		CASE _VFP.Projects.Count > 0
			* There is an active project, so convert it to text.
			lcProjectName = _VFP.ActiveProject.Name

		OTHERWISE
			* There aren't any projects open, so ask the user to select
			* one to convert to text.
			lcProjectName = EXECSCRIPT( _SCREEN.cThorDispatcher, "Thor_Proc_GetProjectName" )
	ENDCASE

	* If no project was selected, abort.
	IF EMPTY( m.lcProjectName )
		ERROR "No project file selected."
	ENDIF

	DO ( m.lcFoxBin2PRGFolder + FOXBIN2PRG_MAIN_EXE_FILENAME ) WITH m.lcProjectName, "*"

CATCH TO loErrorInfo
	* Some part of this process failed, so report the error.
	lcMessage = m.loErrorInfo.Message
	lnMessageIcon = 16	&& Stop sign icon
ENDTRY

* Display the results of this process, if applicable.
IF NOT EMPTY( m.lcMessage )
	MESSAGEBOX( m.lcMessage, m.lnMessageIcon, "Create Project to FoxBin2Prg Text" )
ENDIF

ENDPROC

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
