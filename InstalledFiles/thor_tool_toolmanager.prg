#Define 	ccTool 				'Thor Tool Manager'
#Define 	ccKey 				'Thor Tool Manager'

#Define     ccEditClassName 	'clsEditExcludeNotAssigned'

Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1								;
		And 'O' = Vartype (m.lxParam1)		;
		And 'thorinfo' == Lower (m.lxParam1.Class)

	With m.lxParam1

		* Required
		.Prompt		   = ccTool
		.AppID 		   = 'ThorRepository'

		* Optional
		Text To .Description Noshow && a description for the tool
Thor Tool Manager
		Endtext
		.StatusBarText	 = ''
		.CanRunAtStartUp = .F.

		* These are used to group and sort tools when they are displayed in menus or the Thor form
		.Category = 'Objects and PEMs' && creates categorization of tools; defaults to .Source if empty
		.Sort	  = 0 && the sort order for all items from the same Category

		*!* ******** JRN Removed 2023-10-03 ********
		*!* .OptionClasses = 'clsExcludeNotAssigned'
		*!* .OptionTool	   = ccTool

		* For public tools, such as PEM Editor, etc.
		.Author        = 'Jim Nelson'

	Endwith

	Return m.lxParam1
Endif

If Pcount() = 0
	Do ToolCode
Else
	Do ToolCode With m.lxParam1
Endif

Return


****************************************************************
****************************************************************
* Normal processing for this tool begins here.                  
Procedure ToolCode
	Lparameters lxParam1

	Local lcAlias, lcSourceAlias, llExcludeNotUsed

	lcAlias		  = 'crsr_ThorToolManager'

	*!* ******** JRN Removed 2023-10-03 ********
	*!* llExcludeNotUsed = Execscript(_Screen.cThorDispatcher, 'Get Option=', ccTool, ccTool)

	lcSourceAlias = Sys(2015)
	Execscript(_Screen.cThorDispatcher, 'Thor_Proc_GetHotKeyDefs', m.lcSourceAlias) && , m.llExcludeNotUsed)

	Select  Descript                            As  ToolName,			;
			StatusBar                           As  Description,		;
			Category,													;
			MenuHotKey,													;
			HotKey,														;
			Source,														;
			Type,														;
			Favorite,													;
			StartUp,													;
			Iif(Empty(OptionTool), ' ', 'Y')    As  Options,			;
			Iif(Empty(PlugIns), ' ', 'Y')       As  HasPlugIns,			;
			Project,													;
			Ttod(Timestamp)                     As  Date,				;
			FolderName,													;
			PRGName,													;
			(100 * Evl(nKeyCode, 999)									;
				+ NShifts)                      As  HotKeySort,			;
			Id,															;
			Link,														;
			VideoLink,													;
			OptionTool,													;
			PlugIns,													;
			ToolPrompt,													;
			ToolDescription												;
		From (m.lcSourceAlias)											;
		Into Cursor (m.lcAlias) Readwrite

	Replace All Link With '' For Atc('codeplex.com', Link) # 0
	Goto Top

	Use In (m.lcSourceAlias)

	Execscript(_Screen.cThorDispatcher, 'Thor_Proc_SuperBrowse', m.lcAlias, .T., .T.)

Endproc

* ================================================================================
* ================================================================================

Define Class clsExcludeNotAssigned As Custom

	Tool		  = ccTool
	Key			  = ccKey
	Value		  = .F.
	EditClassName = ccEditClassName

Enddefine


****************************************************************
Define Class ccEditClassName As Container

	Procedure Init
		loRenderEngine = Execscript(_Screen.cThorDispatcher, 'Class= OptionRenderEngine')

		Text To m.loRenderEngine.cBodyMarkup Noshow Textmerge
		
			.Class	   = 'CheckBox'
			.Width	   = 300
			.Left	   = 25
			.Caption   = 'Exclude tools not assigned to hot keys, in tool bar, or in system of pop-up menus'
			.WordWrap = .T.
			.cTool	   = ccTool
			.cKey	   = ccKey
			
		Endtext

		m.loRenderEngine.Render(This, ccTool)

	Endproc

Enddefine
