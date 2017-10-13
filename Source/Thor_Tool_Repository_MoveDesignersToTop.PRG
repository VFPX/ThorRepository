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
		.Prompt		 = 'Move all windows to top' && used when tool appears in a menu
		.Description = 'Move Form and Class Designers to top of screen and align them horizontally.'  + Chr(13) + Chr(13) + 'Requires PEM Editor 7.'

		* Optional

		* For public tools, such as PEM Editor, etc.
		.Source	  = 'Thor Repository'
		.Category	 = 'Windows|Form/Class Designer Windows'
		.Sort		 = 550

		.VideoLink   = 'http://vfpxrepository.com/dl/thorupdate/Videos/Repository.Windows.Management.wmv|3:33'
		.Author	  = 'Jim Nelson'
		.CanRunAtStartUp = .F.
	Endwith

	Return lxParam1
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
	loWindows	  = loEditorWin.GetOpenWindows()

	With loEditorWin
		* create array, 5 elements per window: handle, top, left, height, width
		For lnI = 1 To loWindows.Count
			loWindow = loWindows (lnI)
			If loWindow.NWHandleType = 0 And 'Designer -' $ loWindow.WindowName
				lnWindowCount = lnWindowCount + 1
				Dimension laHandlers (lnWindowCount, 5)
				lnHandle = loWindows (lnI).nwhandle

				.SetHandle (lnHandle)

				laHandlers (lnWindowCount, 1) = lnHandle
				laHandlers (lnWindowCount, 2) = .GetTop()
				laHandlers (lnWindowCount, 3) = .GetLeft()
				laHandlers (lnWindowCount, 4) = .GetHeight()
				laHandlers (lnWindowCount, 5) = .GetWidth()
			Endif
		Endfor && lnI = 1 to loWindows.Count

		If lnWindowCount # 0
			Asort (laHandlers, 3) && leftmost windows stay leftmost
			For lnI = 1 To lnWindowCount)
				.SetHandle (laHandlers (lnI, 1))
				.MoveWindow (cnMaxWidth * (lnI - 1) / lnWindowCount, 0)
			Endfor
		Endif

	Endwith
EndProc
