#Define 	ccTool 				'Highlight Next Parentheses'
#Define 	ccKey 				'Highlight Next Parentheses'

#Define     ccEditClassName 	'clsEditHighlightNext'


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
		.Prompt		 = ccTool
		Text To .Description Noshow
Highlights text between matching parentheses (including the parentheses), starting with the next left parenthesis.

Repeated usage highlights the next set of parentheses.

Optionally, start with next right parenthesis.
		Endtext
		* For public tools, such as PEM Editor, etc.
		.Source		   = 'Thor Repository'
		.Category	   = 'Code|Highlighting text'
		.Author		   = 'Jim Nelson'
		.Link		   = 'http://vfpx.codeplex.com/wikipage?title=Thor%20EditorWindow%20Object'
		.OptionClasses = 'clsHighlightNext'
		.OptionTool		  = ccTool
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
	Local lcChar, lcMatchChar, lcOldClipText, llMatchEnd, lnBegin, lnEnd, lnInsertPoint, lnLastByte
	Local lnParens, lnPosition, lnStartPosition, loEditorWin

	loEditorWin = Execscript (_Screen.cThorDispatcher, 'class= editorwin from pemeditor')
	* locate the active editor window; exit if none active
	If loEditorWin.GetEnvironment(25) <= 0
		Return
	Endif

	lnLastByte		= loEditorWin.GetFileSize()

	llMatchEnd = ExecScript(_Screen.cThorDispatcher, "Get Option=", ccTool, ccTool)

	If llMatchEnd
		lcMatchChar		= ')'
		lnStartPosition	= loEditorWin.GetSelEnd()
	Else
		lcMatchChar		= '('
		lnStartPosition	= loEditorWin.GetSelStart() + 1
	Endif

	For lnPosition = lnStartPosition To lnLastByte
		If loEditorWin.GetCharacter (lnPosition) = lcMatchChar
			If llMatchEnd
				lnInsertPoint = lnPosition
			Else
				lnInsertPoint = lnPosition + 1
			Endif
			Exit
		Endif
	Endfor

	If Empty (lnInsertPoint)
		Return
	Endif

	loEditorWin.Select (lnInsertPoint, lnInsertPoint)
	loEditorWin.SetInsertionPoint (lnInsertPoint)

	Execscript (_Screen.cThorDispatcher, 'Thor_Tool_Repository_HighlightParenthesis')
	Return
Endproc


Define Class clsHighlightNext As Custom

	Tool		 	= ccTool
	Key			 	= ccKey
	Value		 	= .F.
	EditClassName 	= ccEditClassName 

Enddefine


****************************************************************
Define Class ccEditClassName As Container

	Procedure Init
		loRenderEngine = Execscript(_Screen.cThorDispatcher, 'Class= OptionRenderEngine')

		TEXT To loRenderEngine.cBodyMarkup Noshow Textmerge
		
			.Class	   = 'CheckBox'
			.Width	   = 300
			.Left	   = 25
			.Caption   = 'Match up to the next RIGHT parenthesis. (This option alters the order in which embedded parentheses are matched)'
			.WordWrap = .T.
			.cTool	   = ccTool
			.cKey	   = ccKey
			
		ENDTEXT

		loRenderEngine.Render(This, ccTool)

	Endproc

Enddefine

