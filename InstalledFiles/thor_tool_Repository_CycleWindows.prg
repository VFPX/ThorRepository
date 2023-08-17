* Registered with Thor: 02/07/23 09:07:00 AM
Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1						  ;
		And 'O' = Vartype (lxParam1)  ;
		And 'thorinfo' = Lower (lxParam1.Class)

	With lxParam1

		* Required
		.Prompt             = 'Cycle through code windows.'
		.AppID              = 'ThorRepository'
		.Description        = 'Cycle through code windows.'

		.CanRunAtStartup    = .F. 

		* For public tools, such as PEM Editor, etc.
		.Source	  = 'Thor Repository'
		.Category = 'Windows'
		.Author	  = 'Jim Nelson'
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

	Local lnI, loEditorWin, loWindow, loWindows

	loEditorWin	= Execscript(_Screen.cThorDispatcher, 'Thor_Proc_EditorWin')
	loWindows	= m.loEditorWin.GetOpenWindows()

	For lnI = m.loWindows.Count To 1 Step - 1
		loWindow = m.loWindows[m.lnI]
		If m.loWindow.NWHandleType > 0
			m.loEditorWin.SelectWindow (m.loWindow.nWHAndle)
			Return
		Endif
	Endfor

Endproc
