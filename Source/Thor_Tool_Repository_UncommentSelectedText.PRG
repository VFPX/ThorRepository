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
		.Prompt		 = 'Un-comment highlighted lines'
		Text To .Description Noshow
An enhanced version of the 'UnComment' menu item (in the default VFP right-click context menu in a code window) which removes comments from a block of highlighted text. 

It corrects the default behavior where comments are not removed if there are any leading tabs.
		Endtext
		* For public tools, such as PEM Editor, etc.
		.Source	  = 'Thor Repository'
		.Category = 'Code|Highlighted text|Comment/Duplicate'
		.Author	  = 'Jim Nelson'
		.Sort	  = 40
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

	Local lcClipText, lcNewLineText, lcNewText, lcOldClipText, lnCursorPosition, loCommentText
	Local loEditorWin, loHighlightedTex

	loHighlightedText = Execscript(_Screen.cThorDispatcher, 'class= HighlightedText from Thor_Proc_HighlightedText.PRG', 'Whole Line')
	If Not Empty(loHighlightedText.cError)
		Messagebox(loHighlightedText.cError, 16, 'Error', 0)
		Return
	Endif

	loCommentText = Execscript(_Screen.cThorDispatcher, 'class= CommentText from Thor_Proc_CommentText.PRG')

	lcNewLineText = Textmerge(ExecScript(_Screen.cThorDispatcher, "Get Option=", 'Comment Highlighted text', 'Comment Highlighted text'))

	lcClipText = loHighlightedText.cHighLightedText
	loCommentText.RemoveComments(lcClipText, lcNewLineText)
	lcNewText		 = loCommentText.cClipText
	lnCursorPosition = loCommentText.nCursorPosition

	loHighlightedText.PasteText(lcNewText)
	loHighlightedText.ResetInsertionPoint(lnCursorPosition)

	Return
Endproc


