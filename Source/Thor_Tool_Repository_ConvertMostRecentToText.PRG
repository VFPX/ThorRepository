LPARAMETERS lxParam1

#Define		ccToolName		'FoxBin2PRG recently changed binary files'

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

IF PCOUNT() = 1 ;
		AND 'O' = VARTYPE( m.lxParam1 ) ;
		AND 'thorinfo' == LOWER( m.lxParam1.Class )

	WITH lxParam1
	
		* Required
		.Prompt		   = 'Convert most recently changed binary files'
		
		* Optional
		TEXT TO .Description NOSHOW && a description for the tool
Converts the ten most recently changed files in the ActiveProject to FoxBin2Prg text format.

If there is no ActiveProject, you will be prompted for a project to convert.
		ENDTEXT
		.StatusBarText = ''
		.CanRunAtStartUp = .F.

		* These are used to group and sort tools when they are displayed in menus or the Thor form
		.Source		   = '' && where did this tool come from?  Your own initials, for instance
		.Category      = 'Applications|FoxBin2Prg|Projects' && creates categorization of tools; defaults to .Source if empty
		.Sort		   = 50 && the sort order for all items from the same Category
		
		* For public tools, such as PEM Editor, etc.
		.Version	   = '' && e.g., 'Version 7, May 18, 2011'
		.Author        = 'Jim Nelson'
		.Link          = 'https://vfpx.codeplex.com/wikipage?title=Thor%20TWEeT%2025'
		.OptionClasses	 = 'clsAskEachTime, clsFilesOrDays, clsNumberFiles, clsNumberDays'
		.OptionTool	   = ccToolName


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
	lcSourceCursor, ;
	loErrorInfo AS Exception

lcMessage = SPACE(0)
lnMessageIcon = 64	&& Information icon

If Execscript(_Screen.cThorDispatcher, 'Get Option=', 'Ask each time', ccToolName)
	If Not AskEachTime()
		Return
	Endif
Endif
	
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
	EndIf
	
	lcSourceCursor = 'crsrSource'
	Execscript (_Screen.cThorDispatcher, 'Thor_Proc_GetFilesFromProjectForScc', m.lcProjectName, m.lcSourceCursor )
	
	Local lnChoice, lnDayCount, lnFileCount, ltDate
	lnChoice = Execscript(_Screen.cThorDispatcher, 'Get Option=', 'Files or Days', ccToolName)
	Do Case
		Case m.lnChoice = 1
			lnFileCount = Execscript(_Screen.cThorDispatcher, 'Get Option=', 'Number of files', ccToolName)
			Select  Top (m.lnFileCount) *		;
				From crsrSource					;
				Order By LastChange Desc		;
				Into Cursor crsr_Files
		Case m.lnChoice = 2
			lnDayCount = Execscript(_Screen.cThorDispatcher, 'Get Option=', 'Number of days', ccToolName)
			ltDate	   = Date() - m.lnDayCount
			Select  *									;
				From crsrSource							;
				Where LastChange >= m.ltDate			;
				Order By LastChange Desc				;
				Into Cursor crsr_Files
	Endcase
	
	Execscript(_Screen.cThorDispatcher, 'Thor_Proc_FoxBin2PRGChangedFilesInProject.PRG', 'crsr_Files', .T.)
	
	Use In (Select ('crsrSource'))
	Use In (Select ('crsr_Files'))
	
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


Procedure AskEachTime
	Parameters loEditorWin, lcStartValue, lcVariableName, llReplaceAll, llCreateLocals

	Local loForm
	loForm	= Execscript(_Screen.cThorDispatcher, 'Class= DynamicFormDeskTop')

	With m.loForm
		.Caption			= 'FoxBin2PRG: determine files to convert'
		.cHeading			= 'Determine files to convert'
		.cSaveButtonCaption	= 'Apply'
	Endwith

	loForm.cBodyMarkup = GetMarkup()

	m.loForm.Render()
	loEditorWin = Execscript (_Screen.cThorDispatcher, 'class= editorwin from pemeditor')

	m.loForm.AlignToEditWindow(m.loEditorWin)
	m.loForm.Show(1, .T.)

	If 'O' = Vartype(m.loForm) And m.loForm.lSaveClicked
		Return .T.
	Else
		Return .F.
	Endif

Endproc

* ================================================================================
* ================================================================================

#Define		ccContainerName	'clsRecentlyChanged'

Define Class clsAskEachTime As Custom

	Tool		  = ccToolName
	Key			  = 'Ask each time'
	Value		  = .T.
	EditClassName = ccContainerName

Enddefine

Define Class clsFilesOrDays As Custom

	Tool		  = ccToolName
	Key			  = 'Files or Days'
	Value		  =  1
	EditClassName = ccContainerName

Enddefine

Define Class clsNumberFiles As Custom

	Tool		  = ccToolName
	Key			  = 'Number of files'
	Value		  = 10
	EditClassName = ccContainerName

Enddefine

Define Class clsNumberDays As Custom

	Tool		  = ccToolName
	Key			  = 'Number of days'
	Value		  = 2
	EditClassName = ccContainerName

Enddefine

****************************************************************
****************************************************************
Define Class clsRecentlyChanged as Container

	Procedure Init
		Local loRenderEngine
		loRenderEngine = Execscript(_Screen.cThorDispatcher, 'Class= OptionRenderEngine')
		loRenderEngine.cBodyMarkup = GetMarkup()
		loRenderEngine.Render(This, ccToolName)

	Endproc

Enddefine


Procedure GetMarkup
	Local lcBodyMarkup 
		Text To lcBodyMarkup Noshow Textmerge
		
			.Class		= 'Label'
			.Caption	= 'Select based on:'
			.FontBold	= .T.
			|			
			.Name		= 'optGroup'
			.Class		= 'Thor_Proc_Optiongroup'
			.cTool	  	= ccToolName
			.cKey	    = 'Files or Days'
			.cCaptions	= 'Number of Files\\Number of Days'
			.Left		= (.left - 20)
			.Top		= (.top - 20)
			.Width		= (.Width + 40)
			|
			.Class	  = 'Thor_Proc_CheckBox'
			.AutoSize = .T.
			.Caption  = 'Ask each time'
			.cTool	  = ccToolName
			.cKey	  = 'Ask each time'
			|
			.Class	  = 'Thor_Proc_TextBox'
			.AutoSize = .T.
			.Caption  = ''
			.cTool	  = ccToolName
			.cKey	  = 'Number of files'
			.Inputmask = '999'
			.Width    = 35
			.Top      = (.Parent.optGroup.Top + 9)
			.Left	  = (.Parent.optGroup.Left + .Parent.optGroup.Width - 50)

			|
			.Class	  = 'Thor_Proc_TextBox'
			.AutoSize = .T.
			.Caption  = ''
			.cTool	  = ccToolName
			.cKey	  = 'Number of days'
			.Inputmask = '999'
			.Width    = 35
			.Top      = (.Parent.optGroup.Top + 34)
			.Left	  = (.Parent.optGroup.Left + .Parent.optGroup.Width - 50)

		Endtext

	Return lcBodyMarkup 
EndProc 