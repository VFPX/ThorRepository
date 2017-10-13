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
		.Prompt		   = 'Toggle tabs in pageframe' && used in menus

		* Optional
		Text To .Description Noshow && a description for the tool
Toggles display of tabs in the current pageframe.
		Endtext
		.StatusBarText	 = ''
		.CanRunAtStartUp = .F.

		* These are used to group and sort tools when they are displayed in menus or the Thor form
		.Category = 'Objects and PEMs' && creates categorization of tools; defaults to .Source if empty
		.Sort	  = 0 && the sort order for all items from the same Category

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

	Local laObject[1], loObject
	If 0 # Aselobj(laObject) Or 0 # Aselobj(laObject, 1)
		loObject = m.laObject[1]
		Do While .T.
			If Lower(m.loObject.BaseClass) = 'pageframe'
				Exit
			Endif
			If Type("m.loObject.Parent") = 'O'
				loObject = m.loObject.Parent
			Else
				Messagebox('No pageframe selected!', 16, 'Oops')
				Return
			Endif
		Enddo
		loObject.Tabs = Not m.loObject.Tabs
		If loObject.ActivePage = 0
			loObject.ActivePage = 1
		EndIf 
	Else
		Messagebox('No object selected!', 16, 'Oops')
	Endif

Endproc

