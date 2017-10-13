Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

Local laHandles[1], laLines[1], laObjectInfo[1], lcClipText, lcFirstLine, lcIndent, lcNewCliptext
Local lcOldClipText, lcSourceFileName, lcThisFolder, lcWindowName, lcWonTop, llHasFocus
Local lnCursorPosition, lnI, lnLineCount, lnMatchIndex, lnWindowCount, loEditorWin, loThisForm
Local loWindow, loWindows
If Pcount() = 1						  ;
		And 'O' = Vartype (lxParam1)  ;
		And 'thorinfo' = Lower (lxParam1.Class)

	With lxParam1

		* Required
		.Prompt		 = 'Remove MDots from variable names'
		Text to .Description NoShow
Removes MDots from all references to parameters, locals, and other variables.
		EndText
		* For public tools, such as PEM Editor, etc.
		.Source	  = 'Thor Repository'
		.Category = 'Code|MDots'
		.Author	  = 'Jim Nelson'
		.Link	  = 'http://vfpx.codeplex.com/wikipage?title=Thor%20EditorWindow%20Object'
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

	Local lcClipText, lcNewCliptext, lcOldClipText, lnSelEnd, lnSelStart, loEditorWin

	* get the object which manages the editor window
	* see	http://vfpx.codeplex.com/wikipage?title=Thor%20EditorWindow%20Object
	loEditorWin = Execscript (_Screen.cThorDispatcher, 'class= editorwin from pemeditor')
	* locate the active editor window; exit if none active
	If loEditorWin.GetEnvironment(25) <= 0
		Return
	Endif

	lcOldClipText = _Cliptext
	lnSelStart	  = loEditorWin.GetSelStart()
	lnSelEnd	  = loEditorWin.GetSelEnd()
	If lnSelStart = lnSelEnd
		loEditorWin.Select(0, 1000000)
	Endif

	* copy highlighted text into clipboard
	loEditorWin.Copy()
	lcClipText = _Cliptext

	lcNewCliptext = ModifyTextBlock (lcClipText)

	****************************************************************
	* This final block of code pastes in the modification (in <lcNewCliptext>)
	loEditorWin.Paste (lcNewCliptext)
	_Cliptext = lcOldClipText
	loEditorWin.Select (lnSelStart, lnSelStart)
	loEditorWin.SetInsertionPoint (lnSelStart)

	Return
Endproc


Procedure ModifyTextBlock (tcClipText)

	#Define ccTab  	Chr(9)
	#Define ccLF	Chr(10)
	#Define ccCR	Chr(13)
	#Define ccCRLF	Chr(13) + Chr(10)

	Local loRegExp As 'VBScript.RegExp'
	Local lcCodeBlock, lcLocal, lnFirstIndex, lnI, lnJ, loLocals, loMatches, loTools

	* following one structure insures all CRs followed by LFs
	lcCodeBlock = Strtran (Strtran (tcClipText, ccCRLF, ccCR), ccCR, ccCRLF)

	* tools home page = http://vfpx.codeplex.com/wikipage?title=thor%20tools%20object
	loTools	 = Execscript (_Screen.cThorDispatcher, 'Class= tools from pemeditor')
	loLocals = _oPEMEditor.oUtils.oBeautifyX.GetVariablesList (lcCodeBlock, 'PL') && parameters and locals

	If loLocals.Count = 0
		Return lcCodeBlock
	Endif

	Create Cursor crsr_Matches (Match N(6))
	loRegExp = Createobject ('VBScript.RegExp')
	With loRegExp
		.IgnoreCase	= .T.
		.Global		= .T.
		.MultiLine	= .T.
	Endwith

	loRegExp.Pattern = '\Wm\.'
	loMatches		 = loRegExp.Execute (lcCodeBlock)
	For lnJ = 0 To loMatches.Count - 1
		lnFirstIndex = loMatches.Item (lnJ).FirstIndex + 1 && add 1 to allow for leading character \W
		Insert Into crsr_Matches Values (lnFirstIndex)
	Next lnJ

	Execscript (_Screen.cThorDispatcher, 'Thor_Proc_FindNonCodeBlocks', lcCodeBlock, 'crsr_NotCode')
	Select  Match																	   ;
		From crsr_Matches															   ;
			Join crsr_NotCode														   ;
				On Between (crsr_Matches.Match, crsr_NotCode.Start, crsr_NotCode.End)  ;
		Where Not crsr_NotCode.NotCode												   ;
		Order By Match Desc															   ;
		Into Cursor crsr_Matches

	Scan
		lcCodeBlock = Stuff (lcCodeBlock, Match + 1, 2, '')
	Endscan

	Use In crsr_NotCode
	Use In crsr_Matches

	Return lcCodeBlock
Endproc

