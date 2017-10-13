Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1								;
		And 'O' = Vartype(lxParam1)			;
		And 'thorinfo' == Lower(lxParam1.Class)

	With lxParam1

		* Required
		.Prompt		   = 'Duplicate line(s)' && used when tool appears in a menu
		Text To .Description Noshow
Creates a duplicate of the current line(s)
		Endtext

		* Optional
		.StatusBarText = .Description
		.Summary	   = .Description

		* For public tools, such as PEM Editor, etc.
		.Source	  = 'Thor Repository'
		.Category	   = 'Code|Highlighted text|Comment/Duplicate'
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

	* editorwin home page = http://vfpx.codeplex.com/wikipage?title=thor%20editorwindow%20object
	Local loEditorWin As Editorwin Of 'c:\visual foxpro\programs\MyThor\thor\tools\apps\pem editor\source\peme_editorwin.vcx'
	Local lcTextOfLine, lnCurrentLineStart, lnFollowingLineStart, lnSelEnd, lnSelStart
	loEditorWin = Execscript(_Screen.cThorDispatcher, 'Class= editorwin from pemeditor')

	If 0 > loEditorWin.FindWindow()
		Return
	Endif

	* current cursor position
	lnSelStart = loEditorWin.GetSelStart()
	lnSelEnd   = loEditorWin.GetSelEnd()
	* find the start of the current line
	lnCurrentLineStart = loEditorWin.SkipLine(lnSelStart, 0)
	* and of the following line
	lnFollowingLineStart = loEditorWin.SkipLine(lnSelEnd, 0)
	If lnFollowingLineStart < lnSelEnd or lnCurrentLineStart = lnFollowingLineStart
		lnFollowingLineStart = loEditorWin.SkipLine(lnSelEnd, 1)
	Endif
	* Get the desired text
	lcTextOfLine = loEditorWin.GetString(lnCurrentLineStart, lnFollowingLineStart - 1)
	* Move cursor to beginning of next line
	loEditorWin.Select(lnFollowingLineStart, lnFollowingLineStart)
	* And paste in the line
	loEditorWin.Paste(lcTextOfLine)
	* and move the cursor to the beginning of the inserted line
	loEditorWin.SetInsertionPoint(lnFollowingLineStart + Len(lcTextOfLine) - Len(Ltrim(lcTextOfLine, 1, ' ', Chr[9])))

Endproc

