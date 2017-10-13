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
		.Prompt		   = 'List Status' && used in menus

		* Optional
		Text To .Description Noshow && a description for the tool
Displays results of List Status in a pop up window (instead of spilling onto the display)
		Endtext
		.CanRunAtStartUp = .F.

		* These are used to group and sort tools when they are displayed in menus or the Thor form
		.Source	  = '' && where did this tool come from?  Your own initials, for instance
		.Category = 'Code|Miscellaneous' && creates categorization of tools; defaults to .Source if empty
		.Sort	  = 0 && the sort order for all items from the same Category

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

	Local lcTempFile, lcText, lcTime, loEditorWin

	lcTime	   = Ttoc(Datetime(), 1)
	lcTempFile = Addbs(Sys(2023)) + 'List_Status_' + Left(lcTime, 8) + '_' + Right(lcTime, 6) + '.txt'
	List Status To (lcTempFile) Noconsole 
	lcText = Filetostr(lcTempFile)
	Erase (lcTempFile)

	Modify File (lcTempFile) Nowait 
	* editorwin home page = http://vfpx.codeplex.com/wikipage?title=thor%20editorwindow%20object
	loEditorWin = Execscript (_Screen.cThorDispatcher, 'Class= editorwin from pemeditor')
	loEditorWin.Paste (lcText)
	loEditorWin.SetInsertionPoint(0)

Endproc
