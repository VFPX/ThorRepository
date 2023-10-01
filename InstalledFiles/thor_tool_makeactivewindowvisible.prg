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
		.Prompt		   = 'Move the active window (includes most system windows) home.'
		.AppID 		   = 'ThorRepository'

		Text To .Description Noshow
Makes the current window visible by moving it to 0, 0.

Applies to almost all windows (but not the debugger)
		Endtext
		.Category = 'Windows'
		.Author	  = 'JRN'
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

	Local lnHandle, lnI, loEditorWin, loWindow, loWindows

	loEditorWin = Execscript (_Screen.cThorDispatcher, 'class= editorwin from pemeditor')

	With m.loEditorWin
		loWindows = .GetOpenWindows()

		For lnI = 1 To m.loWindows.Count
			loWindow = m.loWindows(m.lnI)
			If m.loWindow.WindowName # 'Properties - Desktop'
				If Type('_Screen.ActiveForm') = 'O' And m.loWindow.WindowName == _Screen.ActiveForm.Caption
					With _Screen.ActiveForm
						.Top	= 0
						.Left	= 0
						.Height	= Min(.Height, _Screen.Height - 16 - Iif(Set("Status Bar")= 'ON', 24, 0))
						.Width	= Min(.Width, _Screen.Width - 16)
					Endwith
				Else
					lnHandle = m.loWindow.nWHAndle
					.SetHandle(m.lnHandle)
					.MoveWindow (0, 0)
					.ReSizeWindow(Min(m.loEditorWin.GetWidth(), _Screen.Width - 16), Min(m.loEditorWin.GetHeight(), _Screen.Height - 16))
				Endif
				Exit
			Endif
		Endfor
	Endwith

Endproc
