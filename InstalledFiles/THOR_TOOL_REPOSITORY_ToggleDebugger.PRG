Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1								;
		And 'O' = Vartype(m.lxParam1)		;
		And 'thorinfo' == Lower(m.lxParam1.Class)

	With m.lxParam1

		* Required
		.Prompt		   = 'Toggle Debugger'
		.AppID 		   = 'ThorRepository'

		* Optional
		Text To .Description Noshow && a description for the tool
Toggles the debugger windows on/off

		Endtext
		.StatusBarText	 = ''
		.CanRunAtStartUp = .F.

		* These are used to group and sort tools when they are displayed in menus or the Thor form
		.Category = 'Windows' && creates categorization of tools; defaults to .Source if empty

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

	Local llToggleISX

	llToggleISX = Pemstatus(_Screen, 'lThorDebuggerOpen', 5) And _Screen.lThorDebuggerOpen

	If Wexist('WATCH') Or Wexist('TRACE')						;
			Or Wexist('CALL STACK') Or Wexist('LOCALS')			;
			Or Wexist('DEBUG OUTPUT')
		Close Debugger
		If m.llToggleISX
			Execscript(_Screen.cThorDispatcher, 'THOR_PROC_IntellisenseXTimer', 'Start')
		Endif
	Else
		If m.llToggleISX
			Execscript(_Screen.cThorDispatcher, 'THOR_PROC_IntellisenseXTimer', 'Stop')
		Endif
		Debug
		Execscript(_Screen.cThorDispatcher, 'THOR_TOOL_FixDebuggerWindows')
	Endif

Endproc


