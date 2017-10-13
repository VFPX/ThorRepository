#Define		ccContainerClassName	'clsBreakHighlightedText'
#Define		ccXToolName				'Break Highlighted Text'
#Define		ccBreakText				'Break Highlighted Text'

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
		.Prompt		 = 'Break highlighted text'
		Text To .Description Noshow
Break the currently highlighted code segment out into a separate line (with semi-colons added for line ends).

This can be used to break long lines into shorter lines.

See related tools, under 'Highlighting Text': Highlight Parameter and Highlight Parentheses
		Endtext
		* For public tools, such as PEM Editor, etc.
		.Source		   = 'Thor Repository'
		.Category	   = 'Code|Highlighted text'
		.Author		   = 'Jim Nelson'
		.Sort		   = 20
		.Link		   = 'http://vfpx.codeplex.com/wikipage?title=Thor%20EditorWindow%20Object'
		.OptionClasses = 'clsBreakLine'
		.OptionTool		  = 'Break Highlighted Text'
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
	Local lcClipText, lcOldClipText, lnCursorPosition, loEditorWin
	loEditorWin = Execscript (_Screen.cThorDispatcher, 'class= editorwin from pemeditor')
	* locate the active editor window; exit if none active
	If loEditorWin.GetEnvironment(25) <= 0
		Return
	Endif

	lcOldClipText = _Cliptext
	* copy highlighted text into clipboard
	loEditorWin.Copy()
	lcClipText = _Cliptext

	lnCursorPosition = -1
	ModifySelectedText (loEditorWin, @lcClipText, @lnCursorPosition)

	****************************************************************
	* This final block of code pastes in the modification (in <lcNewCliptext>)
	loEditorWin.Paste (lcClipText)

	If lnCursorPosition >= 0
		loEditorWin.SetInsertionPoint (lnCursorPosition)
	Endif

	Return
Endproc


Procedure ModifySelectedText (loEditorWin, lcClipText, lnCursorPosition)
	* Parameters: 
	*	lcCliptext:  		Currently selected (or highlighted) text
	* 	lnCursorPosition: 	Where to place the cursor when done (Passed in by reference)

	#Define ccTab  	Chr(9)
	#Define ccCR	Chr(13)
	#Define ccLF	Chr(10)

	Local lcFirstChar, lcIndent, lcLastChar, lcText, lnLineEnd, lnLineStart, lnSelEnd, lnSelStart

	lnSelStart = loEditorWin.GetSelStart()
	lnSelEnd   = loEditorWin.GetSelEnd()

	If ExecScript(_Screen.cThorDispatcher, "Get Option=", 'Break Highlighted Text', 'Break Highlighted Text')
		lcFirstChar	= loEditorWin.GetCharacter (lnSelStart)
		lcLastChar	= loEditorWin.GetCharacter (lnSelEnd - 1)
		If Inlist (lcFirstChar + lcLastChar, '()', '[]')
			lnSelStart = lnSelStart + 1
			lnSelEnd   = lnSelEnd - 1
			loEditorWin.Select (lnSelStart, lnSelEnd)
			loEditorWin.Copy()
			lcClipText = _Cliptext
		Endif
	Endif

	lnLineStart	= loEditorWin.GetLineStart (lnSelStart, 0)
	lcText		= Ltrim (loEditorWin.GetString (lnLineStart, lnSelStart - 1), 1, ccCR, ccLF)
	lcIndent	= Left (lcText, Len (lcText) - Len (Ltrim (lcText, 1, ' ', ccTab)))
	If Not Empty (lcText)
		lcClipText = ';' + ccCR + lcIndent + ccTab + lcClipText
	Endif

	lnLineEnd = loEditorWin.GetLineStart (lnSelEnd, 1)
	lcText	  = Rtrim (loEditorWin.GetString (lnSelEnd, lnLineEnd), 1, ccCR, ccLF)
	If Not Empty (lcText)
		lcClipText =  lcClipText + ';' + ccCR + lcIndent + ccTab
	Endif

	Return lcClipText

Endproc


Define Class clsBreakLine As Custom

	Tool		 = ccXToolName
	Key			 = ccBreakText
	Value		 = .F.
	EditClassName = ccContainerClassName

Enddefine

****************************************************************
Define Class clsBreakHighlightedText As Container

	Procedure Init
		loRenderEngine = Execscript(_Screen.cThorDispatcher, 'Class= OptionRenderEngine')

		Text To loRenderEngine.cBodyMarkup Noshow Textmerge
		
			.Class	   = 'CheckBox'
			.Width	   = 300
			.Left	   = 25
			.Caption   = 'When the highlighted text begins and ends with parentheses or brackets, exclude them from the characters that are broken out into the new line.'
			.WordWrap = .T.
			.cTool	   = ccXToolName
			.cKey	   = ccBreakText
			
		Endtext

		loRenderEngine.Render(This, ccXToolName)

	Endproc

Enddefine

