* Text of the new line to be inserted. Modify as desired.
* Set to .F. if you don't want to insert a new line

#Define		ccContainerClassName	'clsDuplicateSelectedText'
#Define		ccXToolName				'Duplicate Highlighted Text'

#Define		ccBeginningLines		'Beginning Lines'
#Define		ccEndingLines			'Ending Lines'

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
		.Prompt		 = 'Duplicate and comment highlighted lines'
		Text To .Description Noshow
Duplicates a block of highlighted text and comments the original text.

Optionally, it also inserts comment lines before the block of newly commented text and after the last line of duplicated text.
		Endtext

		* For public tools, such as PEM Editor, etc.
		.Source			 = 'Thor Repository'
		.Category	     = 'Code|Highlighted text|Comment/Duplicate'
		.Author			 = 'Jim Nelson'
		.Sort			 = 30
		.Link			 = 'http://vfpx.codeplex.com/wikipage?title=Thor%20EditorWindow%20Object'
		.OptionClasses	 = 'clsBeginningLines, clsEndingLines'
		.OptionTool		 = ccXToolName
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

	Local lcBeginningText, lcClipText, lcCommentString, lcEndingText, lcNewText, lnCursorPosition
	Local loCommentText, loHighlightedText

	loHighlightedText = Execscript(_Screen.cThorDispatcher, 'class= HighlightedText from Thor_Proc_HighlightedText.PRG', 'Whole Line')
	If Not Empty(loHighlightedText.cError)
		Messagebox(loHighlightedText.cError, 16, 'Error', 0)
		Return
	Endif

	loCommentText	= Execscript(_Screen.cThorDispatcher, 'class= CommentText from Thor_Proc_CommentText.PRG')
	lcCommentString	= Alltrim(loCommentText.cCommentString)

	lcBeginningText	= Textmerge(Execscript(_Screen.cThorDispatcher, 'Get Option=', ccBeginningLines, ccXToolName))
	lcEndingText	= Textmerge(Execscript(_Screen.cThorDispatcher, 'Get Option=', ccEndingLines, ccXToolName))

	lcClipText = loHighlightedText.cHighLightedText

	loCommentText.DuplicateComments(lcClipText, lcBeginningText, lcEndingText)

	lcNewText		 = loCommentText.cClipText
	lnCursorPosition = loCommentText.nCursorPosition

	loHighlightedText.PasteText(lcNewText)
	loHighlightedText.ResetInsertionPoint(lnCursorPosition)

	Return
Endproc


Define Class clsBeginningLines As Custom

	Tool		  = ccXToolName
	Key			  = ccBeginningLines
	Value		  = '****************************************'
	EditClassName = ccContainerClassName

Enddefine


Define Class clsEndingLines As Custom

	Tool		  = ccXToolName
	Key			  = ccEndingLines
	Value		  = '****************************************'
	EditClassName = ccContainerClassName

Enddefine


****************************************************************
Define Class clsDuplicateSelectedText As Container

	Procedure Init
		loRenderEngine = Execscript(_Screen.cThorDispatcher, 'Class= OptionRenderEngine')

		Text To loRenderEngine.cBodyMarkup Noshow Textmerge
		
			.Class	   = 'Label'
			.Caption   = 'Text to be inserted as a new line (or lines) before the first highlighted line. Passed as a parameter to TextMerge. Must begin with unique text so that it can be removed when un-commenting.'
			.Width	   = 300
			.Left	   = 25
			.WordWrap = .T.
			|	
			.Class	   = 'EditBox'
			.Width	   = 300
			.Height    = 100
			.Anchor    = 10
			.Left	   = 25
			.cTool	   = ccXToolName
			.cKey	   = ccBeginningLines
			|
			.Class	   = 'Label'
			.Caption   = 'Text to be inserted as a new line (or lines) after the last line. Passed as a parameter to TextMerge.'
			.Width	   = 300
			.Left	   = 25
			.WordWrap = .T.
			|	
			.Class	   = 'EditBox'
			.Width	   = 300
			.Height    = 100
			.Anchor    = 10
			.Left	   = 25
			.cTool	   = ccXToolName
			.cKey	   = ccEndingLines
			
		Endtext

		loRenderEngine.Render(This, ccXToolName)

	Endproc

Enddefine

