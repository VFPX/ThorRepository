Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1								;
		And 'O' = Vartype (m.lxParam1)		;
		And 'thorinfo' = Lower (m.lxParam1.Class)

	With m.lxParam1

		* Required
		.Prompt		 = 'Move all windows to top' && used when tool appears in a menu
		.AppID 		 = 'ThorRepository'
		.Description = 'Move Form and Class Designers to top of screen and align them horizontally.'  + Chr(13) + Chr(13) + 'Requires PEM Editor 7.'

		* Optional

		* For public tools, such as PEM Editor, etc.
		.Source	  = 'Thor Repository'
		.Category = 'Windows|Form/Class Designer Windows'
		.Sort	  = 550

		.VideoLink		 = 'http://vfpxrepository.com/dl/thorupdate/Videos/Repository.Windows.Management.wmv|3:33'
		.Author			 = 'Jim Nelson'
		.CanRunAtStartUp = .F.
	Endwith

	Return m.lxParam1
Endif


Do ToolCode

Return


****************************************************************
****************************************************************
* Normal processing for this tool begins here.                  
Procedure ToolCode
	Local laHandlers[1], lnHandle, lnI, lnWindowCount, loEditorWin, loWindow, loWindows

	* get the object which manages the editor window
	* see	http://vfpx.codeplex.com/wikipage?title=Thor%20EditorWindow%20Object
	loEditorWin = Execscript (_Screen.cThorDispatcher, 'class= editorwin from pemeditor')

	#Define cnMaxWidth 1200
	lnWindowCount = 0
	loWindows	  = m.loEditorWin.GetOpenWindows()

	With m.loEditorWin
		* create array, 5 elements per window: handle, top, left, height, width
		For lnI = 1 To m.loWindows.Count
			loWindow = m.loWindows (m.lnI)
			If m.loWindow.NWHandleType = 0 And 'Designer -' $ m.loWindow.WindowName
				lnWindowCount = m.lnWindowCount + 1
				Dimension m.laHandlers (m.lnWindowCount, 5)
				lnHandle = m.loWindows (m.lnI).nWHAndle

				.SetHandle (m.lnHandle)

				laHandlers (m.lnWindowCount, 1)	= m.lnHandle
				laHandlers (m.lnWindowCount, 2)	= .GetTop()
				laHandlers (m.lnWindowCount, 3)	= .GetLeft()
				laHandlers (m.lnWindowCount, 4)	= .GetHeight()
				laHandlers (m.lnWindowCount, 5)	= .GetWidth()
			Endif
		Endfor && lnI = 1 to loWindows.Count

		If m.lnWindowCount # 0
			Asort (m.laHandlers, 2) && topmost windows stay topmost
			For lnI = 1 To m.lnWindowCount
				.SetHandle (m.laHandlers (m.lnI, 1))
				.MoveWindow (50 + 50 * (m.lnWindowCount - m.lnI), 40 + 40 * (m.lnI - 1))
			Endfor
		Endif

	Endwith
Endproc
