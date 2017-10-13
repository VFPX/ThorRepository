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
		.Prompt		 = 'Cycle Thru'
		.Description = 'Cycle thru Form Designer and Class Designer windows'  + Chr(13) + Chr(13) + 'Requires PEM Editor 7.'

		* Optional

		* For public tools, such as PEM Editor, etc.
		.Source		 = 'Thor Repository'
		.Category	 = 'Windows|Form/Class Designer Windows'
		.Sort		 = 550

		.Author		 = 'Jim Nelson'
		.VideoLink   = 'http://vfpxrepository.com/dl/thorupdate/Videos/Repository.Windows.Management.wmv|3:33'
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
	Local laHandles[1], laObjectInfo[1], lcSourceFileName, lcWindowName, lcWonTop
	Local llHasFocus, lnI, lnMatchIndex, lnWindowCount, loEditorWin, loThisForm, loTools, loWindow
	Local loWindows

	* make sure PEM Editor tools are available
	Execscript (_Screen.cThorDispatcher, 'PEMEditor_StartIDETools')

	* get the object which manages the editor window
	* see	http://vfpx.codeplex.com/wikipage?title=Thor%20EditorWindow%20Object
	loEditorWin = Execscript (_Screen.cThorDispatcher, 'class= editorwin from pemeditor')

	* see	http://vfpx.codeplex.com/wikipage?title=Thor%20Tools%20Object
	loTools = Execscript (_Screen.cThorDispatcher, 'class= tools from pemeditor')

	loThisForm	= loTools.GetCurrentObject (.T.) && current form being edited
	If 'O' # Vartype (loThisForm)
		Return
	Endif

	lcWonTop	  = Lower (Wontop())
	lnWindowCount = 0
	loWindows	  = loEditorWin.GetOpenWindows()
	lnMatchIndex  = 0

	Aselobj (laObjectInfo, 3)
	lcSourceFileName = Lower (laObjectInfo(2)) && name of SCX or VCX

	With loEditorWin
		For lnI = 1 To loWindows.Count
			loWindow	 = loWindows (lnI)
			lcWindowName = Lower (loWindow.WindowName)
			If loWindow.NWHandleType = 0 And 'designer -' $ lcWindowName
				lnWindowCount = lnWindowCount + 1
				Dimension laHandles (lnWindowCount)
				laHandles (lnWindowCount) = loWindows (lnI).nwhandle

				If Justfname (lcSourceFileName) $ lcWindowName		 ;
						And (										 ;
						  Lower (loThisForm.Name) $ lcWindowName	 ;
						  Or Not 'vcx' $ Justext (lcSourceFileName)	 ;
						  )
					lnMatchIndex = lnWindowCount
					llHasFocus	 = Justfname (lcSourceFileName) $ lcWonTop
				Endif
			Endif
		Endfor && lnI = 1 to loWindows.Count

		Do Case
			Case lnMatchIndex = 0

			Case Not llHasFocus
				loEditorWin.SelectWindow (laHandles (lnMatchIndex))
			Case lnMatchIndex = 1
				loEditorWin.SelectWindow (laHandles (lnWindowCount))
			Otherwise
				loEditorWin.SelectWindow (laHandles (1))
		Endcase
	Endwith

Endproc
