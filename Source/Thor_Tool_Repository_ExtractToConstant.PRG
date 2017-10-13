#Define ccTool 'Extract to Constant'

#Define ccTab  	Chr(9)
#Define ccCR	Chr(13)
#Define ccLF	Chr(10)

Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1								;
		And 'O' = Vartype (lxParam1)		;
		And 'thorinfo' = Lower (lxParam1.Class)

	With lxParam1

		* Required
		.Prompt      = ccTool
		Text To .Description Noshow
Extracts the currently highlighted code segment into a new constant (#Define).

You are first prompted for the name of the new constant.

If you are editing a PRG, a #Define statement is inserted at the beginning of the PRG. 

If you are editing method code, you will be provided the opportunity to indicate whether to insert the new constant into the Include file for the form or class or at the beginning of the method.

Then the original reference is replaced with the just-created constant. 

Note: To replace ALL references to the highlighted text, precede the variable name with an exclamation point (!).	
		Endtext
		* For public tools, such as PEM Editor, etc.
		.Source			 = 'Thor Repository'
		.Category		 = 'Code|Highlighted text|Extract to'
		.Author			 = 'Jim Nelson'
		.Sort			 = 1100
		.Link          = 'https://vfpx.codeplex.com/wikipage?title=Thor%20TWEeT%209'
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

	Local laSelObj[1], lcAssignment, lcClipText, lcIncludeFile, lcStartValue, lcVariableName
	Local llReplaceAll, llThisMethod, lnReplacements, lnResponse, lnStartByte, lnStartPos, loEditorWin

	* See editorwin home page http://vfpx.codeplex.com/wikipage?title=thor%20editorwindow%20object
	loEditorWin = Execscript (_Screen.cThorDispatcher, 'Class= editorwin from pemeditor')

	* locate the active editor window; exit if none active
	If loEditorWin.GetEnvironment(25) <= 0
		Return
	Endif

	* copy highlighted text into clipboard
	loEditorWin.Copy()
	lcClipText = _Cliptext
	If Empty (lcClipText)
		Return
	Endif

	*!* ******************** Removed 11/11/2013 *****************
	*!* loConstants = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_ZDef')

	lnStartPos	 = loEditorWin.GetSelStart()
	lcStartValue = Chrtran(lcClipText, ' ' + ccTab + ccCR + ccLF, '')

	lcVariableName = ''
	llReplaceAll   = Nvl(Execscript(_Screen.cThorDispatcher, 'Get Option=', 'Replace all', ccTool), .F.)
	llThisMethod   = .F.
	lcIncludeFile  = ''

	If Not PromptForConstantName(loEditorWin, lcStartValue, @lcVariableName, @llReplaceAll, @llThisMethod, @lcIncludeFile)
		Return
	Endif

	If llReplaceAll
		lnReplacements = 1000
	Else
		lnReplacements = 1
	Endif

	lcAssignment = '#Define ' + lcVariableName + ' ' + lcClipText + ccCR
	MakeReplacements (loEditorWin, lnStartPos, lcClipText, lcVariableName, lnReplacements)

	If llThisMethod
		lnStartByte = 0
		loEditorWin.Select (lnStartByte, lnStartByte)
		loEditorWin.Paste (lcAssignment)
		loEditorWin.SetInsertionPoint (lnStartPos + Len (lcAssignment) + Len (lcVariableName))
	Else
		If not ccCR $ Right(FileToStr(lcIncludeFile), 2) 
			Strtofile (ccCR + ccLF, lcIncludeFile, 1)
		EndIf 
		Strtofile (lcAssignment, lcIncludeFile, 1)
	Endif

	Return

Endproc


Procedure MakeReplacements (loEditorWin, lnStartPos, lcClipText, lcVariableName, lnReplacements)
	* get text to end of file, make replacement(s), paste it back
	Local lcEndText, lcIndent, lcNewText, lcThisLine, lnStartByte, lnStartPos
	loEditorWin.Select (lnStartPos, 1000000)
	lcEndText = loEditorWin.GetString (lnStartPos, 1000000)
	lcNewText = Strtran (lcEndText, lcClipText, lcVariableName, 1, lnReplacements, 0)
	loEditorWin.Paste (lcNewText)
	loEditorWin.SetInsertionPoint (lnStartPos)
Endproc


Procedure PromptForConstantName
	Parameters loEditorWin, lcStartValue, lcVariableName, llReplaceAll, llThisMethod, lcIncludeFile

	Local llHighlighted, lnI, loConstants, loForm
	Private lcValue, pnInclude, paIncludeFiles[1]

	lcValue		= lcStartValue
	pnInclude	= 1
	loConstants	= Execscript(_Screen.cThorDispatcher, 'Thor_Proc_ZDef')
	Dimension paIncludeFiles[loConstants.FileList.Count + 1]
	paIncludeFiles[1] = 'This Procedure'
	For lnI = 1 To loConstants.FileList.Count
		paIncludeFiles[lnI + 1] = JustFname(loConstants.FileList[lnI])
	EndFor 

	loForm	= Execscript(_Screen.cThorDispatcher, 'Class= DynamicFormDeskTop')

	With loForm
		.Caption	 = 'Extract to Constant'
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
	pnInclude		.class 			= 'ComboBox'
				.caption			= 'Add to:'
				.Width				= 200
				.RowSourceType      = 5
				.RowSource			= 'paIncludeFiles'
	Endtext

	loForm.Render()
	loForm.AlignToEditWindow(loEditorWin)
	loForm.Show(1, .T.)

	If 'O' = Vartype(loForm) And loForm.lSaveClicked
		lcVariableName = Alltrim(lcValue)
		If pnInclude = 1
			llThisMethod = .T.
		Else
			lcIncludeFile = loConstants.FileList[pnInclude - 1]
		EndIf 
	Else
		Return .F.
	Endif

Endproc