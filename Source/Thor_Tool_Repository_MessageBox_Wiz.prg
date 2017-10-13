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
		.Prompt	 = 'Open Messagebox Wizard' && used when tool appears in a menu
		.Summary = 'Open Messagebox Wizard'

		* Optional
		.Description   = 'Insert code for a Messagebox at cursor by running a wizard' && a more complete description; may be lengthy, including CRs, etc
		.StatusBarText = ''

		* These are used to group and sort tools when they are displayed in menus or the Thor form
		.Source	  = 'Thor Repository' && Internet
		.Category = 'Code|Inserting text'
		.Sort	  = 0 && the sort order for all items from the same Source, Category and Sub-Category

		* For public tools, such as PEM Editor, etc.
		.Version = '1.1' && e.g., 'Version 7, May 18, 2011'
		.Author	 = 'Francis Coppage (supplied as a Thor tool by BBout)'
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
	Local lcClipText, lcFormFileName, lnPos, lnSelStart, loEditorWin
	lcClipText	   = _Cliptext
	lcFormFileName = Execscript (_Screen.cThorDispatcher, 'Full Path=Msgboxwiz.scx')
	Do form (lcFormFileName)

	If Not lcClipText == Evl (_Cliptext, lcClipText)
		* editorwin home page = http://vfpx.codeplex.com/wikipage?title=thor%20editorwindow%20object
		loEditorWin = Execscript (_Screen.cThorDispatcher, 'Class= editorwin from pemeditor')
		If '^^^' $ _Cliptext
			lnSelStart = loEditorWin.GetSelStart()
			lnPos	   = At ('^^^', _Cliptext)
			_Cliptext  = Strtran (_Cliptext, '^^^', '')
			loEditorWin.Paste()
			loEditorWin.SetInsertionPoint (lnSelStart + lnPos -1 )
		Else
			loEditorWin.Paste()
		Endif
	Endif
	_Cliptext = lcClipText
Endproc
