Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1								;
		And 'O' = Vartype (lxParam1)		;
		And 'thorinfo' == Lower (lxParam1.Class)

	With lxParam1

		* Required
		.Prompt		   = 'Moves focus to the current form or class, moves it to a standard position, and resizes it.'
		.AppID 		   = 'ThorRepository'
		
		.Description = .Prompt

		* These are used to group and sort tools when they are displayed in menus or the Thor form
		.Category      = 'Windows|Code Windows' && creates categorization of tools; defaults to .Source if empty
		.CanRunAtStartUp = .F.

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
	Execscript (_Screen.cThorDispatcher, 'Thor_Tool_Repository_CycleDesignerWindows')
	Execscript (_Screen.cThorDispatcher, 'Thor_Tool_Repository_MoveDesignersToTop')
	Execscript (_Screen.cThorDispatcher, 'Thor_Tool_Repository_ResizeDesigner')
Endproc

