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
		.Prompt		   = 'Create sample menus' && used in menus

		* Optional
		Text To .Description Noshow && a description for the tool
Creates a number of sample menus, accessible from the first page of the Thor Configuration form.
		Endtext
		.StatusBarText	 = ''
		.CanRunAtStartUp = .T.

		* These are used to group and sort tools when they are displayed in menus or the Thor form
		.Category = 'Settings & Misc.'
		.Sort	  = 9999 && the sort order for all items from the same Category
		.CanRunAtStartUp = .F.

		* For public tools, such as PEM Editor, etc.
		.Author        = 'Jim Nelson'

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
	loSampleMenus = Newobject('SampleMenus')
	loSampleMenus.Run()

Endproc

Define Class SampleMenus As Session

	Procedure Init
		Set Deleted On
	Endproc


	Procedure Run
		This.OpenTables()
		This.CopyHeaderRecords()
		This.CopyDetailRecords()
		Messagebox('Sample menus created. See first page of the configuration form', 64, 'Created')
		Execscript(_Screen.cThorDispatcher)
	Endproc


	Procedure OpenTables
		Local lcToolFolder
		lcToolFolder  = Execscript(_Screen.cThorDispatcher, 'Tool Folder=')
		Use(lcToolFolder + '..\Tables\MenuDefinitions') Again In 0 Alias MenuDefinitions
		Use(lcToolFolder + '..\Tables\MenuTools') Again In 0 Alias MenuTools

		Use(lcToolFolder + 'Samples\MenuDefinitions') Again In 0 Alias SourceMenuDefinitions
		Use(lcToolFolder + 'Samples\MenuTools') Again In 0 Alias SourceMenuTools
	Endproc


	Procedure CopyHeaderRecords
		Select  *,													;
				0    As  Id											;
			From SourceMenuDefinitions								;
			Where Not PopUpName In(Select  PopUpName				;
									   From MenuDefinitions)		;
			Into Cursor cursor_NewMenus
		If _Tally > 0
			Select MenuDefinitions
			Append From(Dbf('cursor_NewMenus'))
		EndIf
		
		Update  MenuDefinitions						;
			Set MenuDefinitions.Popup = .T.			;
			From MenuDefinitions					;
				Join SourceMenuDefinitions On		;
					MenuDefinitions.PopUpName = SourceMenuDefinitions.PopUpName;
					and SourceMenuDefinitions.Popup = .T.
	Endproc


	Procedure CopyDetailRecords
		Local lnMenuID, loSourceDef
		Select  SourceMenuDefinitions.Id    As  SourceID,								;
				MenuDefinitions.Id														;
			From SourceMenuDefinitions													;
				Join MenuDefinitions													;
					On SourceMenuDefinitions.PopUpName = MenuDefinitions.PopUpName		;
			Into Cursor crsr_IDMap Readwrite

		Select SourceMenuDefinitions
		Scan
			Scatter Name loSourceDef
			Select MenuDefinitions
			Locate For PopUpName = loSourceDef.PopUpName
			lnMenuID = Id
			
			Replace all MenuID with -1 in MenuTools for MenuID = lnMenuID

			Select  lnMenuID                    As  MenuID,						;
					PRGname,													;
					Nvl(crsr_IDMap.Id, 0000)    As  submenid,					;
					Separator,													;
					sortorder,													;
					Prompt,														;
					StatusBar													;
				From SourceMenuTools											;
					Left Join crsr_IDMap										;
						On SourceMenuTools.SubMenuID = crsr_IDMap.SourceID		;
				Where MenuID = loSourceDef.Id									;
				Into Cursor crsr_NewItems Readwrite

			Select  *												;
				From crsr_NewItems									;
				Where Not Str(MenuID, 4) + Upper(PRGname) In		;
					(Select  Str(MenuID, 4) + Upper(PRGname)		;
						 From MenuTools								;
						 Where MenuID = lnMenuID)					;
				Into Cursor crsr_MissingItems
			If _Tally > 0
				Select MenuTools
				Append From(Dbf('crsr_MissingItems'))
			Endif
		Endscan
	Endproc

Enddefine