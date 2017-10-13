#Define ccTool 'Extract to Variable'


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
		.Prompt      = ccTool
		Text To .Description Noshow
Extracts the currently highlighted code segment into a new variable.

You are first prompted for the name of the new variable. 

A line is inserted before the current line with the assignment of the variable, and the original reference is replaced with the just-created variable. 

Note: To replace ALL references to the highlighted text, precede the variable name with an exclamation point (!).
		Endtext

		* For public tools, such as PEM Editor, etc.
		.Source			 = 'Thor Repository'
		.Category		 = 'Code|Highlighted text|Extract to'
		.Sort			 = 1000
		.Author			 = 'Jim Nelson'
		.Link          = 'https://vfpx.codeplex.com/wikipage?title=Thor%20TWEeT%209'
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

	#Define ccTab  	Chr(9)
	#Define ccCR	Chr(13)
	#Define ccLF	Chr(10)

	* get the object which manages the editor window
	* see	http://vfpx.codeplex.com/wikipage?title=Thor%20EditorWindow%20Object

	Local lcAssignment, lcClipText, lcEndText, lcIndent, lcNewText, lcOldClipText, lcPrevChars
	Local lcStartValue, lcThisLine, lcVariableName, llCreateLocals, llReplaceAll, lnLineOffset
	Local lnMDotsUsage, lnReplacements, lnStartByte, lnStartPos, loEditorWin

	loEditorWin = Execscript (_Screen.cThorDispatcher, 'class= editorwin from pemeditor')
	* locate the active editor window; exit if none active
	If loEditorWin.GetEnvironment(25) <= 0
		Return
	Endif

	lcOldClipText = _Cliptext
	* copy highlighted text into clipboard
	loEditorWin.Copy()
	lcClipText = _Cliptext
	If Empty (lcClipText)
		Return
	Endif

	lcStartValue   = Chrtran(lcClipText, ' ' + ccTab + ccCR + ccLF, '')
	lcVariableName = ''

	llReplaceAll   = Nvl(Execscript(_Screen.cThorDispatcher, 'Get Option=', 'Replace all', ccTool), .F.)
	llCreateLocals = Nvl(Execscript(_Screen.cThorDispatcher, 'Get Option=', 'Create Locals', ccTool), .F.)

	If Not PromptForVariableName(loEditorWin, lcStartValue, @lcVariableName, @llReplaceAll, @llCreateLocals)
		Return
	Endif

	Do Case
		Case Empty (lcVariableName)
			Return
		Case llReplaceAll
			lcVariableName = Strtran (lcVariableName, '!', '')
			lnReplacements = 1000
		Otherwise
			lnReplacements = 1
	Endcase

	lnMDotsUsage = Execscript(_Screen.cThorDispatcher, 'Get Option=', 'MDots Usage', 'MDots')
	Do Case
		Case lnMDotsUsage = 2
			lcVariableName = 'm.' + lcVariableName
		Case lnMDotsUsage = 3
			lcVariableName = 'M.' + lcVariableName
	Endcase


	* get text to end of file, make replacement(s), paste it back
	lnStartPos = loEditorWin.GetSelStart()
	loEditorWin.Select (lnStartPos, 1000000)
	lcEndText = loEditorWin.GetString (lnStartPos, 1000000)
	lcNewText = Strtran (lcEndText, lcClipText, lcVariableName, 1, lnReplacements, 0)
	loEditorWin.Paste (lcNewText)
	loEditorWin.SetInsertionPoint (lnStartPos)

	* find beginning of this line, accounting for continuation lines	
	For lnLineOffset = 0 To 10000
		lnStartByte = loEditorWin.GetLineStart (lnStartPos, - lnLineOffset)
		If lnStartByte = 0
			Exit
		Endif
		lcPrevChars = loEditorWin.GetString (Max(0, lnStartByte - 3), lnStartByte - 1)
		If Right (Trim (lcPrevChars, 1, ccCR, ccLF), 1) # ';'
			Exit
		Endif
	Endfor && lnLineOffset = 0 to 10000

	lcThisLine = loEditorWin.GetString (lnStartByte, lnStartByte + 100)
	lcIndent   = Left (lcThisLine, Len (lcThisLine) - Len (Ltrim (lcThisLine, 1, ' ', ccTab)))

	loEditorWin.Select (lnStartByte, lnStartByte)
	lcAssignment = lcIndent + lcVariableName + ' = ' + lcClipText + ccCR
	loEditorWin.Paste (lcAssignment)
	loEditorWin.SetInsertionPoint (lnStartPos + Len (lcAssignment) + Len (lcVariableName))

	If llCreateLocals
		Execscript(_Screen.cThorDispatcher, 'Thor_Tool_PEME_CreateLocals')
	Endif

	Execscript(_Screen.cThorDispatcher, 'Set Option=', 'Replace all', ccTool, llReplaceAll)
	Execscript(_Screen.cThorDispatcher, 'Set Option=', 'Create Locals', ccTool, llCreateLocals)

	Return

Endproc


Procedure PromptForVariableName
	Parameters loEditorWin, lcStartValue, lcVariableName, llReplaceAll, llCreateLocals

	Local llHighlighted, loForm
	Private lcValue
	loForm	= Execscript(_Screen.cThorDispatcher, 'Class= DynamicFormDeskTop')
	lcValue	= lcStartValue

	With loForm
		.Caption	 = 'Extract to Variable'
		.MinWidth	 = 275
		.MinHeight	 = 100
		.MinButton	 = .F.
		.MaxButton	 = .F.
		.BorderStyle = 2

		.cHeading			= 'Extract ' + lcStartValue
		.cSaveButtonCaption	= 'Apply'
	Endwith


	Text To loForm.cBodyMarkup Noshow Textmerge
	lcValue 	.class 				= 'TextBox'
				.caption			= 'To Variable:'
				.width				= 200
				.Increment			= 1			
				|
	llReplaceAll	.class 			= 'CheckBox'
				.caption			= 'Replace \<All Occurrences'
				.Width				= 200
				|
	llCreateLocals	.class 			= 'CheckBox'
				.caption			= 'Create \<Locals'
				.Width				= 200
	Endtext

	loForm.Render()
	loForm.AlignToEditWindow(loEditorWin)
	loForm.Show(1, .T.)

	If 'O' = Vartype(loForm) And loForm.lSaveClicked
		lcVariableName = Alltrim(lcValue)
	Else
		Return .F.
	Endif

Endproc