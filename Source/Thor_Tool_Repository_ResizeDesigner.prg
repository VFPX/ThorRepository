#Define 	ccTool 					'Resize Designer Window'
#Define     ccEditClassName 		'clsResizeDesigner from Thor_Options_ResizeDesignerWindow.VCX'

Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

Local laObjectInfo[1], lcSourceFileName, lcThisFolder, lcWindowName, lnI, lnNewHeight, lnNewWidth
Local loThisForm, loTools, loWindow, loWindows

If Pcount() = 1								;
		And 'O' = Vartype (lxParam1)		;
		And 'thorinfo' = Lower (lxParam1.Class)

	With lxParam1

		* Required
		.Prompt		 = 'Resize' && used when tool appears in a menu
		.Summary	 = 'Resize current Form / Class Designer window'
		.Description = 'Resize current Form / Class Designer window to show the entire form or class being edited'  + Chr(13) + Chr(13) + 'Requires PEM Editor 7.'

		* Optional

		* For public tools, such as PEM Editor, etc.
		.Source	  = 'Thor Repository'
		.Category = 'Windows|Form/Class Designer Windows'
		.Sort	  = 550

		.VideoLink	   = 'http://vfpxrepository.com/dl/thorupdate/Videos/Repository.Windows.Management.wmv|3:33'
		.Author		   = 'Jim Nelson'
		.OptionClasses = 'clsSetTopToZero, clsSetLeftToZero, clsMinimumHeight, clsMinimumWidth, clsExtraHeight, clsExtraWidth'
		.OptionTool		  = ccTool
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

	* get the object which manages the editor window
	* see	http://vfpx.codeplex.com/wikipage?title=Thor%20EditorWindow%20Object
	Local laObjectInfo[1], lcMinHeight, lcMinWidth, lcSourceFileName, lcWindowName, llResetLeftToZero
	Local llResetTopToZero, lnI, lnMinHeight, lnMinWidth, lnNewHeight, lnNewWidth, loEditorWin
	Local loThisForm, loThor, loTools, loWindow, loWindows
	loEditorWin = Execscript (_Screen.cThorDispatcher, 'class= editorwin from pemeditor')

	* see	http://vfpx.codeplex.com/wikipage?title=Thor%20Tools%20Object
	loTools = Execscript (_Screen.cThorDispatcher, 'class= tools from pemeditor')

	loThisForm	= loTools.GetCurrentObject (.T.) && current form being edited
	If 'O' # Vartype (loThisForm)
		Return
	Endif

	loThor			  = Execscript (_Screen.cThorDispatcher, 'Thor Engine=')
	llResetLeftToZero = loThor.GetOption ('Set left to zero',	ccTool)
	llResetTopToZero  = loThor.GetOption ('Set top to zero', 	ccTool)
	lnMinWidth		  = loThor.GetOption ('Minimum Width', 		ccTool)
	lnMinHeight		  = loThor.GetOption ('Minimum Height', 	ccTool)
	lnExtraWidth	  = loThor.GetOption ('Extra Width',	 	ccTool)
	lnExtraHeight	  = loThor.GetOption ('Extra Height', 	ccTool)

	Aselobj (laObjectInfo, 3)
	lcSourceFileName = Lower (laObjectInfo(2)) && name of SCX or VCX

	loWindows	= loEditorWin.GetOpenWindows()

	With loEditorWin
		* create array, 5 elements per window: handle, top, left, height, width
		For lnI = 1 To loWindows.Count
			loWindow	 = loWindows (lnI)
			lcWindowName = Lower (loWindow.WindowName)
			If loWindow.NWHandleType = 0 And 'designer -' $ lcWindowName
				If Justfname (lcSourceFileName) $ lcWindowName				;
						And (												;
						  Lower (loThisForm.Name) $ lcWindowName			;
						  Or Not 'vcx' $ Justext (lcSourceFileName)			;
						  )
					.SetHandle (loWindows (lnI).nwhandle)

					lnNewWidth	= Sysmetric(15) + loThisForm.Width + lnExtraWidth
					If Pemstatus (loThisForm, 'Left', 5)
						If llResetLeftToZero
							loThisForm.Left = 0
						Else
							lnNewWidth = lnNewWidth + Max (loThisForm.Left, 0)
						Endif
					Endif

					lnNewHeight	= (Sysmetric(9) * 2) + Sysmetric(14) + loThisForm.Height + lnExtraHeight
					If Pemstatus (loThisForm, 'Top', 5)
						If llResetTopToZero
							loThisForm.Top = 0
						Else
							lnNewHeight = lnNewHeight + Max (loThisForm.Top, 0)
						Endif
					Endif

					.ResizeWindow (Max (lnMinWidth, lnNewWidth), Max (lnMinHeight, lnNewHeight))
				Endif
			Endif
		Endfor && lnI = 1 to loWindows.Count
	Endwith

Endproc


Define Class clsSetTopToZero As Custom

	Tool		  = ccTool
	Key			  = 'Set Top to zero'
	Value		  = .F.
	EditClassName = ccEditClassName

Enddefine

Define Class clsSetLeftToZero As Custom

	Tool		  = ccTool
	Key			  = 'Set Left to zero'
	Value		  = .F.
	EditClassName = ccEditClassName

Enddefine

Define Class clsMinimumHeight As Custom

	Tool		  = ccTool
	Key			  = 'Minimum Height'
	Value		  = 100
	EditClassName = ccEditClassName

Enddefine

Define Class clsMinimumWidth As Custom

	Tool		  = ccTool
	Key			  = 'Minimum Width'
	Value		  = 300
	EditClassName = ccEditClassName

Enddefine

Define Class clsExtraHeight As Custom

	Tool		  = ccTool
	Key			  = 'Extra Height'
	Value		  = 16
	EditClassName = ccEditClassName

Enddefine

Define Class clsExtraWidth As Custom

	Tool		  = ccTool
	Key			  = 'Extra Width'
	Value		  = 16
	EditClassName = ccEditClassName

Enddefine
