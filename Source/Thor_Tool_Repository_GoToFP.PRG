#Define		ccContainerClassName	'clsDockable'
#Define		ccXToolName				'Super Browse'

#Define		ccOptionKey				'Dockable'
#Define		ccHelpKey				'Show Filter Help'
#Define		ccDynamicFormKey		'Use Dynamic Form'


Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1								;
		And 'O' = Vartype(lxParam1)			;
		And 'thorinfo' == Lower(lxParam1.Class)

	With lxParam1

		* Required
		.Prompt		 = ccXToolName
		Text To .Description Noshow
Super-Browse utility: opens the browse window / Field Picker (FP) for both browsing a table and creating code for SQL statements to be pasted into a code window.

Click on the alias of a table or cursor (you don't even have to highlight it).  If already opened, it will be browsed.  If not opened, every attempt is made to try to open it.  

Opening the table is handled by PEME_OpenTable.PRG, which you can customize.
		Endtext
		* Optional
		.StatusBarText = .Description
		.Summary	   = '' && if empty, first line of .Description is used

		* For public tools, such as PEM Editor, etc.
		.Source			 = 'Thor Repository' && e.g., 'PEM Editor'
		.Category		 = 'Tables'
		.Author			 = 'Tore Bleken'
		.Version		 = '1.3'
		.Sort			 = 10
		.Link			 = 'https://vfpx.codeplex.com/wikipage?title=Thor%20Super%20Browse'
		.CanRunAtStartUp = .F.
		.PlugInClasses   = 'clsSpellFieldNamesPlugIn, clsMakeResultStringPlugIn, clsOpenTablePlugIn, clsSuperBrowseBindEventsPlugIn, clsSuperBrowseContextMenuPlugIn, clsSuperBrowseEditOneRecordPlugIn'
		.PlugIns		 = 'Open Table, Spell Field Names, SB: Format Field Picker, SB: Bind column events, SB: Grid context menu, SB: Field definitions'

		.OptionClasses   = 'clsSB, clsFilterHelp, clsDynamicForm'
		.OptionTool	     = ccXToolName

	Endwith

	Return lxParam1
Endif

If Pcount() = 0
	Do ToolCode
Else
	Do ToolCode With lxParam1
Endif

Return


****************************************************************
****************************************************************
* Normal processing for this tool begins here.                  
Procedure ToolCode
	Lparameters lxParam1

	Local lcAlias, lnI, loForm, loTools

	* tools home page = http://vfpx.codeplex.com/wikipage?title=thor%20tools%20object
	loTools = Execscript(_Screen.cThorDispatcher, 'class= tools from pemeditor')
	loTools.UseHighlightedTable(Set('Datasession'))
	****************************************************************
	If Empty(Alias())
		Use Getfile('Table (dbf):dbf;Classlib (vcx):vcx;Form (scx):scx;Report (frx):frx', 'Select a table', 'OK', 0, 'SuperBrowse')
	Endif
	If Empty(Alias())
		Wait Window 'No table selected.' Timeout 2
	Else
		Execscript(_Screen.cThorDispatcher, 'Thor_Proc_SuperBrowse', Alias())
	Endif
Endproc

****************************************************************

Define Class clsSB As Custom

	Tool		  = ccXToolName
	Key			  = ccOptionKey
	Value		  = .T.
	EditClassName = ccContainerClassName

Enddefine

Define Class clsFilterHelp As Custom

	Tool		  = ccXToolName
	Key			  = ccHelpKey
	Value		  = .T.
	EditClassName = ccContainerClassName

Enddefine

Define Class clsDynamicForm As Custom

	Tool		  = ccXToolName
	Key			  = ccDynamicFormKey
	Value		  = 2
	EditClassName = ccContainerClassName

Enddefine

****************************************************************
Define Class clsDockable As Container

	Procedure Init
		Local loRenderEngine
		loRenderEngine = Execscript(_Screen.cThorDispatcher, 'Class= OptionRenderEngine')

		Text To loRenderEngine.cBodyMarkup Noshow Textmerge
		
			.Class	   = 'CheckBox'
			.Width	   = 300
			.Left	   = 25
			.Caption   = 'Supports docking'
			.WordWrap = .T.
			.cTool	   = ccXToolName
			.cKey	   = ccOptionKey
		|			
			.Class	   = 'Label'
			.Width	   = 300
			.Left	   = 40
			.Caption   = 'If the form supports docking and is dockable, the form may be moved outside of the FoxPro screen and is AlwaysOnTop.'
			.WordWrap = .T.
		|
			.Class	   = 'optiongroup'
			.Left      = 25
			.cTool	   = ccXToolName
			.cKey	   = ccDynamicFormKey
			.cCaptions = 'Edit records with native EDIT command\\Edit records with UI form created by DynamicForms'
		|
			.Class	   = 'CheckBox'
			.Width	   = 300
			.Left	   = 25
			.Caption   = 'Show help when option "Filter by Value" is chosen'
			.WordWrap = .T.
			.cTool	   = ccXToolName
			.cKey	   = ccHelpKey
		Endtext

		loRenderEngine.Render(This, ccXToolName)

	Endproc

Enddefine

****************************************************************
****************************************************************

Define Class clsSpellFieldNamesPlugIn As Custom

	Source				= 'SuperBrowse'
	PlugIn				= 'Spell Field Names'
	Description			= 'Determines the spelling of field names from tables. Note that options already provided are [lower | UPPER | Mixed | Hungarian (cName)]'
	Tools				= 'Super Browse and IntellisenseX, and editing ControlSource in PEM Editor'
	FileNames			= 'Thor_Proc_GetFieldNames.PRG'
	DefaultFileName		= '*Thor_Proc_GetFieldNames.PRG'
	DefaultFileContents	= ''
EndDefine 

****************************************************************
****************************************************************

Define Class clsMakeResultStringPlugIn As Custom

	Source				= 'SuperBrowse'
	PlugIn				= 'SB: Format Field Picker'
	Description			= 'Creates the "Field Picker" string for fields that have been selected in Super Browse.'
	Tools				= 'Super Browse'
	FileNames			= 'Thor_Proc_SuperBrowse_ResultString.PRG'
	DefaultFileName		= '*Thor_Proc_SuperBrowse_ResultString.PRG'
	DefaultFileContents	= ''
EndDefine 

****************************************************************
****************************************************************

Define Class clsSuperBrowseBindEventsPlugIn As Custom

	Source				= 'SuperBrowse'
	PlugIn				= 'SB: Bind column events'
	Description			= 'Binds events for columns in the Super Browse grid.'
	Tools				= 'Super Browse'
	FileNames			= 'Thor_Proc_SuperBrowseBindEvents.PRG'
	DefaultFileName		= 'Thor_Proc_SuperBrowseBindEvents.PRG'
	DefaultFileContents	= 'Lparameters loForm, loColumn, lcControlSource'
EndDefine 

****************************************************************
****************************************************************

Define Class clsSuperBrowseContextMenuPlugIn As Custom

	Source				= 'SuperBrowse'
	PlugIn				= 'SB: Grid context menu'
	Description			= 'Creates a context menu for cells in the grid'
	Tools				= 'Super Browse'
	FileNames			= 'Thor_Proc_SuperBrowseContextMenu.PRG'
	DefaultFileName		= 'Thor_Proc_SuperBrowseContextMenu.PRG'
	DefaultFileContents	= ''
EndDefine 

****************************************************************
****************************************************************

Define Class clsSuperBrowseEditOneRecordPlugIn As Custom

	Source				= 'SuperBrowse'
	PlugIn				= 'SB: Field definitions'
	Description			= 'Alternative field definitions (a la Dynamic Forms) when editing a single record'
	Tools				= 'Super Browse'
	FileNames			= 'Thor_Proc_SuperBrowseEditOneRecord.PRG'
	DefaultFileName		= 'Thor_Proc_SuperBrowseEditOneRecord.PRG'
	DefaultFileContents	= 'Lparameters lcAlias, lcFieldType, tcFieldName, lcLastlcFieldType'
EndDefine 

****************************************************************
****************************************************************

Define Class clsOpenTablePlugIn As Custom

	Source				= 'SuperBrowse'
	PlugIn				= 'Open Table'
	Description			= 'Opens a table given its alias. May be used to access SQL tables, for instance.'
	Tools				= 'IntellisenseX, Go To Definition, Super Browse, Insert Info Wizard, Create SQL from cursor, Schema, WLC Column Listing Utility'
	FileNames			= 'PEME_OpenTable.PRG'
	DefaultFileName		= '*PEME_OpenTable.PRG'
	DefaultFileContents	= ''

	Procedure Init
		****************************************************************
		****************************************************************
		Text To This.DefaultFileContents Noshow
* The core of this program is the procedure OpenMyTable -- it
* is called with the alias that is be opened, and if successfui,
* returns that alias (but, curiously, it can return the alias
* for any table).

Lparameters tcFileName, tcAlias

Local lcFileName

Do Case
	Case Empty(m.tcFileName)
		lcFileName = Alias()

	Case Used(m.tcFileName)
		lcFileName = m.tcFileName

	Otherwise
		lcFileName = OpenMyTable(m.tcFileName)
		Do Case
				* can return a different alias
			Case Vartype(m.lcFileName) = 'C' And Used(m.lcFileName)
				_oPEMEditor.oTools.AddMRUFile(Dbf(m.lcFileName))

				* if not, check that supplied alias was USEd
			Case Used(m.tcFileName)
				lcFileName = m.tcFileName
				_oPEMEditor.oTools.AddMRUFile(Dbf(m.lcFileName))

			Otherwise
				lcFileName = ''
		Endcase
Endcase

If Empty(m.lcFileName)
	lcFileName = Execscript(_Screen.cThorDispatcher, 'DoDefault()', m.tcFileName, m.tcAlias)
Endif

Return Execscript(_Screen.cThorDispatcher, 'Result=', m.lcFileName)

* ----------------------------------------------------------------
* ----------------------------------------------------------------

Procedure OpenMyTable(tcFileName)
	* may also return a result of a different alias!
EndProc

* ----------------------------------------------------------------
* Sample 1: Calls a UDF to open a table
* 	Procedure OpenMyTable(tcFileName)
*	 	If UseTable(tcFilename)
*	 		Return tcFilename
*	 	Else
*			Return ''
*		Endif
*	Endproc

* ----------------------------------------------------------------
* Sample 2: You’ve got VFP tables on an M:\ drive that can’t be found
* 	Procedure OpenMyTable(tcFileName)
*		Local loExcepion
*		Try 
*			Use in 0 ('m:\' + tcFileName)	
*		Catch to loException
*		
*		EndTry
*	Endproc

* ----------------------------------------------------------------
* Sample 3: You have multiple clients and need to open files in different ways. 
* If each client is in a distinct directories:
* 	Procedure OpenMyTable(tcFileName)
*		Do Case
*		
*			Case “CLIENT1” $ Curdir()
*				* This client has SQL tables, so you set the connection string
*				ExecScript(_Screen.cThorDispatcher, "Set Option=", 'Connection String', 'Opening Tables', 'MyConnectionString')
*		
*			Case “CLIENT2” $ Curdir()
*				* Maybe this client has VFP tables in a path ISX can’t find
*		
*		Endcase
*	Endproc


		Endtext
		****************************************************************
		****************************************************************
	Endproc



EndDefine 

