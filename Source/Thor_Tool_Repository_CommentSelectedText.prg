* Text of the new line to be inserted. Modify as desired.
* Set to .F. if you don't want to insert a new line

#Define		ccContainerClassName	'clsCommentSelectedText'
#Define		ccXToolName				'Comment Highlighted Text'

#Define		ccCommentText			'Comment Highlighted Text'
#Define		ccToggleComments		'Toggle Comments'

Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1								;
		And 'O' = Vartype(lxParam1)			;
		And 'thorinfo' = Lower(lxParam1.Class)

	With lxParam1

		* Required
		.Prompt		 = 'Comment highlighted lines'
		Text To .Description Noshow
An enhanced version of the 'Comment' menu item (in the default VFP right-click context menu in a code window) which comments a block of highlighted text.  

This tool handles indentation differently in that the commented code is kept aligned with the original code, instead of at the left margin.  

Optionally, it also inserts another comment line before the block of highlighted text and leaves the cursor at that position for additional comment		
		Endtext

		* For public tools, such as PEM Editor, etc.
		.Source		   = 'Thor Repository'
		.Category	   = 'Code|Highlighted text|Comment/Duplicate'
		.Author		   = 'Jim Nelson'
		.Sort		   = 30
		.Link		   = 'http://vfpx.codeplex.com/wikipage?title=Thor%20EditorWindow%20Object'
		.OptionClasses = 'clsAddComments, clsToggleComments'
		.OptionTool	   = 'Comment Highlighted Text'
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

	Local lcClipText, lcCommentString, lcNewLineText, lcNewText, lcOldClipText, lnCursorPosition
	Local loCommentText, loEditorWin, loHighlightedText

	loHighlightedText = Execscript(_Screen.cThorDispatcher, 'class= HighlightedText from Thor_Proc_HighlightedText.PRG', 'Whole Line')
	If Not Empty(loHighlightedText.cError)
		Messagebox(loHighlightedText.cError, 16, 'Error', 0)
		Return
	Endif

	loCommentText	= Execscript(_Screen.cThorDispatcher, 'class= CommentText from Thor_Proc_CommentText.PRG')
	lcCommentString	= Alltrim(loCommentText.cCommentString)

	lcNewLineText = Textmerge(ExecScript(_Screen.cThorDispatcher, "Get Option=", 'Comment Highlighted text', 'Comment Highlighted text'))

	lcClipText = loHighlightedText.cHighLightedText

	If ExecScript(_Screen.cThorDispatcher, "Get Option=", 'Toggle Comments', 'Comment Highlighted text')		;
			And Left(Ltrim(lcClipText,' ', chr[9]), Len(lcCommentString)) == lcCommentString
		loCommentText.RemoveComments(lcClipText, lcNewLineText)
	Else
		loCommentText.AddComments(lcClipText, lcNewLineText)
	Endif

	lcNewText		 = loCommentText.cClipText
	lnCursorPosition = loCommentText.nCursorPosition

	loHighlightedText.PasteText(lcNewText)
	loHighlightedText.ResetInsertionPoint(lnCursorPosition)

	Return
Endproc


Define Class clsAddComments As Custom

	Tool		  = ccXToolName
	Key			  = ccCommentText
	Value		  = '* Removed <<Date()>>'
	EditClassName = ccContainerClassName

Enddefine


Define Class clsToggleComments As Custom

	Tool		  = ccXToolName
	Key			  = ccToggleComments
	Value		  = .F.
	EditClassName = ccContainerClassName

Enddefine

****************************************************************
Define Class clsCommentSelectedText As Container

	Procedure Init
		loRenderEngine = Execscript(_Screen.cThorDispatcher, 'Class= OptionRenderEngine')

		Text To loRenderEngine.cBodyMarkup Noshow Textmerge
		
			.Class	   = 'Label'
			.Caption   = 'Text to be inserted as a new line before the first highlighted line. Passed as a parameter to TextMerge. Must begin with unique text so that it can be removed when un-commenting.'
			.Width	   = 300
			.Left	   = 25
			.WordWrap = .T.
			|	
			.Class	   = 'TextBox'
			.Width	   = 300
			.Anchor    = 10
			.Left	   = 25
			.cTool	   = ccXToolName
			.cKey	   = ccCommentText
			|	
			.Class	   = 'CheckBox'
			.Width	   = 300
			.Left	   = 25
			.Caption   = 'Use tool "Comment Highlighted Text" as a toggle? That is, if the highlighted text is already commented, remove the comments?'
			.WordWrap = .T.
			.cTool	   = ccXToolName
			.cKey	   = ccToggleComments
			
		Endtext

		loRenderEngine.Render(This, ccXToolName)

	Endproc

Enddefine

