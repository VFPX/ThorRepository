Local laHotKey[1], lcKeyWord, llNewValue, lnSelect, loCloseTemps, loContextMenu, loThisTable
Local loThorUtils

#Define CR               	Chr(13)
#Define LF               	Chr(10)
#Define CRLF             	Chr(13)+Chr(10)
#Define Tab				    Chr(9)

lnSelect = Select()

Scatter Name m.loThisTable Memo

loThorUtils  = Execscript (_Screen.cThorDispatcher, 'Thor_Proc_Utils')

loCloseTemps = m.loThorUtils.CloseTempFiles()
m.loThorUtils.OpenThorTables()

loContextMenu = Execscript (_Screen.cThorDispatcher, 'class= Contextmenu')

With m.loContextMenu

	* ================================================================================

	If Not Empty(m.loThisTable.PRGName)

		.AddMenuItem('Run', , , , 'Run')

		.AddMenuItem('\<Help', , , , 'URL')

		If Not Empty(m.loThisTable.FolderName)
			.AddMenuItem('\<Installation Folder', , , , 'FolderName')
		Endif

		If Not Empty(m.loThisTable.VideoLink + m.loThisTable.OptionTool + m.loThisTable.PlugIns)
			.AddMenuItem()
			If Not Empty(m.loThisTable.VideoLink)
				.AddMenuItem('\<Video', , , , 'Video')
			Endif

			If Not Empty(m.loThisTable.OptionTool)
				.AddMenuItem('\<Options', , , , 'Options')
			Endif

			If Not Empty(m.loThisTable.PlugIns)
				.AddMenuItem('\<Plug-Ins', , , , 'Plug-Ins')
			Endif
		Endif

		.AddMenuItem()
		.AddMenuItem('\<Set hot key', , , , 'SetHotKey')

		Select  HotKeyID												;
			From ToolHotKeyAssignments									;
			Where Upper(PRGName) = Upper(m.loThisTable.PRGName)			;
				And HotKeyID # 0										;
			Into Array laHotKey
		If Not Empty(m.laHotKey)
			.AddMenuItem('\<Clear hot key', , , , 'ClearHotKey')
		Endif

		.AddMenuItem()

		If Not Empty(m.loThisTable.MenuHotKey)
			.AddMenuItem('\<Menu caption', , , , 'Menu')
		Endif

		.AddMenuItem('\<Favorite', , , , 'Favorite', , GetStatus('Favorites', 'StartUp', m.loThisTable.PRGName))

		.AddMenuItem('Start \<Up', , , , 'Start Up', , GetStatus('StartupTools', 'StartUp', m.loThisTable.PRGName))

		.AddMenuItem('\<Toolbar', , , , 'ToolBar', , GetStatus('ToolBarTools', 'Enabled', m.loThisTable.PRGName))

	Endif && not Empty(m.loThisTable.PRGName)

	.AddMenuItem()
	Do Case
		Case m.loThisTable.Type = 'Custom'
			.AddMenuItem('Edit Custom Version', , , , 'Edit')
			.AddMenuItem('Delete Custom Version', , , , 'DeleteTool')
			.AddMenuItem('View Published Version (Read-Only)', , , , 'Original')
			.AddMenuItem('Compare Versions', , , , 'CompareTools')
		Case m.loThisTable.Type = 'Private'
			.AddMenuItem('Edit Private Version', , , , 'Edit')
			.AddMenuItem('Delete Private Version', , , , 'DeleteTool')
		Case Type("GoVars.UserNumber") = 'N' and GoVars.UserNumber = 63
			.AddMenuItem('Create Custom Version', , , , 'CreateCustom')
			.AddMenuItem('Edit Published Version', , , , 'Edit')
		Otherwise
			.AddMenuItem('View Published Version (Read-Only)', , , , 'Original')
			.AddMenuItem('Create Custom Version', , , , 'CreateCustom')
	Endcase

	.AddMenuItem()

	.AddMenuItem('Refresh menus and hotkeys', , , , 'RefreshThor')

	* ================================================================================

	If .Activate()
		lcKeyWord = .KeyWord
		Select(m.lnSelect)
		Do Case

			Case m.lcKeyWord == 'Run'
				loCloseTemps = Null
				RunTool(m.loThisTable)

			Case m.lcKeyWord == 'Edit'
				EditTool(m.loThisTable, m.loThorUtils)

			Case m.lcKeyWord == 'DeleteTool'
				DeleteTool(m.loThisTable, m.loThorUtils)

			Case m.lcKeyWord == 'CompareTools'
				CompareTools(m.loThisTable, m.loThorUtils)

			Case m.lcKeyWord == 'CreateCustom'
				CreateCustomTool(m.loThisTable, m.loThorUtils)

			Case m.lcKeyWord == 'Original'
				EditOriginalTool(m.loThisTable, m.loThorUtils)

			Case m.lcKeyWord == 'URL'
				Execscript(_Screen.cThorDispatcher, 'Thor_proc_showtoolhelp', m.loThisTable.PrgName)

			Case m.lcKeyWord == 'FolderName'
				ExecScript(_Screen.cThorDispatcher, 'Thor_Proc_OpenFolder', Alltrim(m.loThisTable.FolderName)) 

			Case m.lcKeyWord == 'Video'
				GoURL(m.loThisTable.VideoLink)

			Case m.lcKeyWord == 'SetHotKey'
				SetHotKey(m.loThisTable, 'Set')

			Case m.lcKeyWord == 'ClearHotKey'
				ClearHotKey(m.loThisTable)

			Case m.lcKeyWord == 'Options'
				EditOptions(m.loThisTable)

			Case m.lcKeyWord == 'Plug-Ins'
				ManagePlugIns(m.loThisTable)

			Case m.lcKeyWord == 'Menu'
				EditMenuCaption(m.loThisTable)

			Case m.lcKeyWord == 'ToolBar'
				EditToolBar(m.loThisTable)

			Case m.lcKeyWord == 'Favorite'
				llNewValue = ToggleStatus('Favorites', 'StartUp', m.loThisTable.PRGName)
				Select(m.lnSelect)
				Replace Favorite With m.llNewValue

			Case m.lcKeyWord == 'Start Up'
				llNewValue = ToggleStatus('StartupTools', 'StartUp', m.loThisTable.PRGName)
				Select(m.lnSelect)
				Replace StartUp With m.llNewValue

			Case m.lcKeyWord == 'RefreshThor'
				m.loThorUtils.WaitWindow('Refreshing')
				RefreshThor()
				Wait Clear

		Endcase
	Endif
Endwith


* ================================================================================
* ================================================================================
Procedure RunTool(loThisTable)
	Local loForm
	loForm = _Screen.ActiveForm
	m.loForm.Hide()
	Execscript(_Screen.cThorDispatcher, Trim(m.loThisTable.PRGName))
	m.loForm.Release()
Endproc


* ================================================================================
* ================================================================================
Procedure GoURL(lcURL)
	Declare Integer ShellExecute		;
		In SHELL32.Dll					;
		Integer nWinHandle,				;
		String cOperation,				;
		String cFileName,				;
		String cParameters,				;
		String cDirectory,				;
		Integer nShowWindow

	ShellExecute(0,				;
		  'OPEN', m.lcURL,		;
		  '', Sys(2023), 1)
Endproc


* ================================================================================
* ================================================================================
Procedure EditTool(loThisTable, loThorUtils)
	Local lcFullFileName

	lcFullFileName = ThorFileName(m.loThisTable.PRGName)
	Modify Command (m.lcFullFileName) Nowait
	MoveWindow(m.lcFullFileName)
	AddMRU(m.lcFullFileName)
Endproc


* ================================================================================
* ================================================================================
Procedure DeleteTool(loThisTable, loThorUtils)
	Local lcFileName, lcFullFileName, lcParent, lcRelative, llCustom

	lcFullFileName = ThorFileName(m.loThisTable.PRGName)
	lcRelative	   = ParentFolder(m.lcFullFileName)
	If Messagebox('Delete tool "' + Trim(m.loThisTable.ToolPrompt) + '"' + CR + 'from folder "' + m.lcRelative + '"?', 3 + 32) = 6
		Erase(m.lcFullFileName)

		* so, what's left?
		lcFileName = ThorFileName(m.loThisTable.PRGName)
		If Empty(m.lcFileName) or Isnull(m.lcFileName) 
			Delete
		Else
			lcParent = Upper(ParentFolder(m.lcFileName))
			llCustom = Type = 'Custom'
			Do Case
				Case m.lcParent == 'TOOLS'
					Replace Type With ''
				Case m.lcParent == 'MY TOOLS'
					Replace Type With Iif(m.llCustom, 'Custom', 'Private')
				Otherwise
					Replace Type With Iif(m.llCustom, 'Custom', 'Private') + ' (In Path)'
			Endcase
		Endif
	Endif
Endproc


	* ================================================================================
	* ================================================================================
Procedure CompareTools(loThisTable, loThorUtils)
	Local lcCustomFileName, lcPublFileName

	lcCustomFileName = ThorFileName(m.loThisTable.PRGName)
	lcPublFileName	 = _Screen.cThorFolder + 'Tools\' + Trim(m.loThisTable.PRGName)

	Execscript(_Screen.cThorDispatcher, 'Thor_Proc_CompareFiles', m.lcCustomFileName, m.lcPublFileName)
Endproc


	* ================================================================================
	* ================================================================================
Procedure CreateCustomTool(loThisTable, loThorUtils)
	Local lcClipText, lcFullFileName, lcFullFilePath, lcPrivateFile, lcToolFolder, loEditorWin, loTools

	loTools		   = Execscript (_Screen.cThorDispatcher, 'class= tools from pemeditor')
	lcFullFileName = ThorFileName(m.loThisTable.PRGName)
	lcFullFilePath = Upper (Addbs (Justpath (m.lcFullFileName)))
	lcToolFolder   = Execscript (_Screen.cThorDispatcher, 'Tool Folder=')

	lcPrivateFile = Forcepath (m.lcFullFileName, m.lcToolFolder + 'My Tools\')
	Modify Command (m.lcPrivateFile) Nowait

	lcClipText = Filetostr (m.lcFullFileName)
	* editorwin home page = http://vfpx.codeplex.com/wikipage?title=thor%20editorwindow%20object
	loEditorWin = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_EditorWin')
	m.loEditorWin.Paste (m.lcClipText)
	m.loEditorWin.SetInsertionPoint(0)

	MoveWindow(m.lcPrivateFile)
	AddMRU(m.lcPrivateFile)

Endproc


* ================================================================================
* ================================================================================
Procedure EditOriginalTool(loThisTable, loThorUtils)
	Local lcFullFileName

	lcFullFileName = _Screen.cThorFolder + 'Tools\' + Trim(m.loThisTable.PRGName)
	Modify Command (m.lcFullFileName) Nowait NoEdit 
	MoveWindow(m.lcFullFileName)
	AddMRU(m.lcFullFileName)
Endproc


* ================================================================================
* ================================================================================
Procedure MoveWindow(lcFileName)
	Execscript (_Screen.cThorDispatcher, 'PEMEditor_StartIDETools')
	_oPEMEditor.oUtils.oIDEx.MoveWindow()
Endproc
	

* ================================================================================
* ================================================================================
Procedure AddMRU(lcFile, lcClass)

	Local loTools
	loTools = Execscript (_Screen.cThorDispatcher, 'class= tools from pemeditor')
	m.loTools.AddMRUFile(m.lcFile)
	If Pcount() > 1
		m.loTools.AddMRUFile(m.lcFile, m.lcClass)
	Endif

Endproc


* ================================================================================
* ================================================================================
Procedure GetStatus(lcTable, lcField, lcPRGName)
	Local laStatus[1]

	Select  &lcField									;
		From &lcTable									;
		Where Upper(PRGName) =  Upper(m.lcPRGName)		;
		Into Array laStatus
	Return m.laStatus
	Return
Endproc


* ================================================================================
* ================================================================================
Procedure EditOptions(loThisTable)
	ExecScript(_Screen.cThorDispatcher, 'Thor_Proc_OpenOptionsPage', Trim(m.loThisTable.OptionTool))
Endproc


* ================================================================================
* ================================================================================
Procedure ManagePlugIns(loThisTable)
	Local lcFileName

	lcFileName = ThorFileName('Thor_Tool_ThorInternalManagePlugIns.SCX')
	Do Form  (m.lcFileName) With m.loThisTable.PlugIns
Endproc


* ================================================================================
* ================================================================================
Procedure ToggleStatus(lcTable, lcField, lcPRGName)

	Local llNewValue

	Select &lcTable
	Locate For Upper(PRGName) =  Upper(m.lcPRGName)
	If Found()
		llNewValue = Not &lcField
		Replace &lcField With m.llNewValue
	Else
		llNewValue = .T.
		Insert Into &lcTable (PRGName, &lcField) Values (m.lcPRGName, m.llNewValue)
	Endif
	Return m.llNewValue
Endproc


* ================================================================================
* ================================================================================
Procedure EditToolBar(loThisTable)
	Local lcAlias, llContinue, lnSelect
	Local poToolBarTools
	lnSelect = Select()

	lcAlias = 'ToolBarTools'

	Select (m.lcAlias)
	Locate For Upper(PRGName) = Upper(m.loThisTable.PRGName)
	If Found()
		llContinue = .T.
	Else
		llContinue = Messagebox('Create toolbar entry for this tool?', 3 + 32 + 256) = 6
		If m.llContinue
			Insert Into (m.lcAlias)							;
				(PRGName, Caption, ToolTip, Enabled)		;
				Values										;
				(m.loThisTable.PRGName, m.loThisTable.ToolName, m.loThisTable.Description, .T.)
		Endif
	Endif

	If m.llContinue
		poToolBarTools = EditToolBarItem()
		If Not Isnull(m.poToolBarTools)
			Select (m.lcAlias)
			Gather Name m.poToolBarTools Fields Except Id
			Select (m.lnSelect)
			Replace	ToolName	 With  m.poToolBarTools.Caption,		;
					Description	 With  m.poToolBarTools.ToolTip,		;
					Source		 With  'Toolbar' + Iif(m.poToolBarTools.Enabled, '', ' - disabled')
		Endif
		Select (m.lnSelect)
	Endif

Endproc


* ================================================================================
* ================================================================================
Procedure EditMenuCaption(loThisTable)
	Local lcAlias, lnMenuID, lnSelect
	Local poMenuTools
	lnSelect = Select()
	lnMenuID = Id

	lcAlias = 'MenuTools'

	Select (m.lcAlias)
	Locate For Id = m.lnMenuID

	If Found()

		poMenuTools = EditMenuItem()
		If Not Isnull(m.poMenuTools)
			Select (m.lcAlias)
			Gather Name m.poMenuTools Memo Fields Except Id
			Select (m.lnSelect)
			Replace	ToolName	 With  m.poMenuTools.Prompt,		;
					Description	 With  m.poMenuTools.StatusBar
		Endif
	Else
		Messagebox('Internal error -- menu item not found')
	Endif
	Select (m.lnSelect)
Endproc



* ================================================================================
* ================================================================================
Procedure SetHotKey(loThisTable, lcAction)

	Local loForm As 'SetHotKeyForm' Of 'Thor_UI.vcx'
	Local lcAlias, lcHotKey, lcThorAPP, lnSelect

	lnSelect = Select()

	lcAlias = 'ToolHotKeyAssignments'
	Select (m.lcAlias)
	Locate For Upper(PRGName) = Upper(m.loThisTable.PRGName)

	If Not Found()
		Insert Into (m.lcAlias) (PRGName) Values (m.loThisTable.PRGName)
	Endif

	lcThorAPP	 = _Screen.cThorFolder + '..\Thor.app'
	loForm		 = Newobject ('SetHotKeyForm',	'Thor_UI.vcx', 	m.lcThorAPP)
	loForm.oThor = Newobject ('Thor_Engine',	'Thor.vcx', 	m.lcThorAPP, _Screen.cThorFolder)

	m.loForm.ExecuteCommand (m.lcAlias, m.lcAction)
	lcHotKey = m.loForm.HotKeyControls1.txtHotKey.Value
	m.loForm.Release()
	loForm = .Null.

	Select (m.lnSelect)
	Replace HotKey With Strtran(m.lcHotKey, '-', '+')
Endproc


* ================================================================================
* ================================================================================
Procedure ClearHotKey(loThisTable)

	Replace HotKey With ''
	Replace	PRGName	  With	''			;
			HotKeyID  With	0			;
		In ToolHotKeyAssignments		;
		For Upper(PRGName) = Upper(m.loThisTable.PRGName)

Endproc


* ================================================================================
* ================================================================================
Procedure RefreshThor
	Local loThor As 'clsRunThor'

	loThor = Newobject('clsRunThor')
	m.loThor.Run()
Endproc


* ================================================================================
* ================================================================================
Procedure ThorFileName(lcFileName)
	Return Execscript(_Screen.cThorDispatcher, 'Full Path=' + Alltrim(m.lcFileName))
Endproc


* ================================================================================
* ================================================================================
Procedure ParentFolder(lcFileName)
	Return JustStem(JustPath(m.lcFileName)) 
Endproc


* ================================================================================
* ================================================================================

Procedure EditToolBarItem
	Private poToolBarTools

	Local loForm, loResult
	Scatter Name m.poToolBarTools

	loForm	= Execscript(_Screen.cThorDispatcher, 'Class= DynamicForm')

	With m.loForm
		.Caption	 = 'Edit Toolbar Item'
		.MinWidth	 = 700
		.MinButton	 = .F.
		.MaxButton	 = .F.
		.MaxHeight	 = 180
		.MinHeight	 = 180
		.BorderStyle = 3
		.Height		 = 150
	Endwith

	Text To m.loForm.cBodyMarkup Noshow Textmerge
	poToolBarTools.Caption	
				.class 				= 'TextBox'
				.caption 		    = 'Caption'
				.Left				= 100
				.Width				= 200
	|
	poToolBarTools.Tooltip	
				.class 				= 'TextBox'
				.caption 		    = 'ToolTip'
				.Left				= 100
				.Width				= 700
				.Anchor 			= 10
	|
	poToolBarTools.Enabled	
				.class 				= 'CheckBox'
				.caption 		    = 'Enabled'
				.Left				= 100
				.Width				= 400
	Endtext

	If ShowDynamicForm(m.loForm)
		loResult =  m.poToolBarTools
	Else
		loResult =  Null
	Endif

	loForm = Null
	Return m.loResult

Endproc


* ================================================================================
* ================================================================================

Procedure EditMenuItem
	Private poMenuTools

	Local loForm, loResult
	Scatter Name m.poMenuTools Memo
	loForm	= Execscript(_Screen.cThorDispatcher, 'Class= DynamicForm')

	With m.loForm
		.Caption	 = 'Edit Menu Item'
		.MinWidth	 = 700
		.MinButton	 = .F.
		.MaxButton	 = .F.
		.MaxHeight	 = 180
		.MinHeight	 = 180
		.BorderStyle = 3
		.Height		 = 150
	Endwith

	Text To m.loForm.cBodyMarkup Noshow Textmerge
	poMenuTools.Prompt	
				.class 				= 'TextBox'
				.caption 		    = 'Menu Caption'
				.Left				= 100
				.Width				= 600
	|
	poMenuTools.Statusbar	
				.class 				= 'TextBox'
				.caption 		    = 'Status bar tip'
				.Left				= 100
				.Width				= 600
				.Anchor 			= 10

	Endtext

	If ShowDynamicForm(m.loForm)
		loResult =  m.poMenuTools
	Else
		loResult =  Null
	Endif

	loForm = Null
	Return m.loResult

Endproc


* ================================================================================
* ================================================================================

Procedure ShowDynamicForm(loDynamicForm)

	m.loDynamicForm.Render()

	m.loDynamicForm.Show(1, _Screen.ActiveForm)

	If 'O' = Vartype(m.loDynamicForm) And m.loDynamicForm.lSaveClicked
		m.loDynamicForm.Release()
		Return .T.
	Else
		Return .F.
	Endif

Endproc


* ================================================================================
* ================================================================================
Define Class clsRunThor As Session

	Procedure Run
		Local loRunThor As 'Thor_Run' Of 'thor_run.vcx'
		Local lcApp, lcFolder, lcThorFolder

		lcThorFolder  = _Screen.cThorFolder + '..\'

		lcApp	  = m.lcThorFolder + 'Thor.App'
		lcFolder  = m.lcThorFolder + 'Thor\'
		loRunThor = Newobject ('Thor_Run', 'thor_run.vcx', m.lcApp, m.lcApp, m.lcFolder)
		m.loRunThor.AddProperty('cApplication', m.lcApp)
		m.loRunThor.Run(.T.) && but no startups
	Endproc

	Procedure Destroy
		Close Tables
	Endproc

Enddefine
