* Created: 02/25/12 06:33:34 PM
Lparameters lxParam1

#Define		ccTool	'Find All References'

#Define		ccKey	'Search Immediately'
#Define		ccCaption	'After opening GoFish, begin searching immediately'

#Define		ccKeyBeta	'GoFish Beta'
#Define		ccCaptionBeta	'Use Beta version of GoFish, if installed'


****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1								;
		And 'O' = Vartype (m.lxParam1)		;
		And 'thorinfo' = Lower (m.lxParam1.Class)

	With m.lxParam1

		* Required
		.Prompt		   = ccTool
		Text To .Description Noshow
Grabs the "word" at the current cursor position, or any explicitly selected text, and calls the GoFish search tool with that string.

Optionally begins searching immediately.

Works in the Command Window, or any editor window.
		Endtext

		* Optional
		.StatusBarText = .Description
		.Summary	   = .Description

		* For public tools, such as PEM Editor, etc.
		.Author			 = 'Jim Nelson'
		.Category		 = 'Code|Highlighted text'
		.CanRunAtStartUp = .F.

		.OptionClasses = 'clsSearchImmediate, clsBeta'
		.OptionTool	   = ccTool
	Endwith

	Return m.lxParam1
Endif

Do ToolCode

Return


****************************************************************
****************************************************************
* Normal processing for this tool begins here.                  
 Procedure ToolCode
	Local lcClipText, loForm, loHighlightedText, loSearchOptions

	loHighlightedText = Execscript (_Screen.cThorDispatcher, 'class= HighlightedText from Thor_Proc_HighlightedText.PRG', 'Word', .T.)
	If Not Empty (m.loHighlightedText.cError)
		Messagebox (m.loHighlightedText.cError, 16, 'Error', 0)
		Return
	Endif

	lcClipText = m.loHighlightedText.cHighLightedText

	* Start GoFish
	Do Case
		Case Nvl(Execscript(_Screen.cThorDispatcher, 'Get Option=', ccKeyBeta, ccTool), .F.)		;
				And Not Isnull (Execscript (_Screen.cThorDispatcher, 'Thor_TOOL_GoFish4_Beta'))

		Case Not Isnull (Execscript (_Screen.cThorDispatcher, 'Thor_TOOL_GoFish5'))

		Otherwise
			Messagebox ('GoFish is not installed; unable to proceed', 16, 'GoFish not installed', 0)
			Return
	Endcase

	* Get reference to GoFish form
	loForm			= _Screen._GoFish.oResultsForm
	loSearchOptions	= m.loForm.oSearchEngine.oSearchOptions

	*!* * Removed 2/27/2012 
	*!* * We will not want the setting to be saved.
	*!* loForm.lSaveSettings = .F.

	If Not Empty (m.lcClipText)
		m.loForm.SetSearchExpression (m.lcClipText)
	
		If Execscript(_Screen.cThorDispatcher, 'Get Option=', ccKey, ccTool)
			m.loForm.Search()
		Endif
	Endif
	
Endproc


Define Class clsSearchImmediate As Custom

	Tool		  = ccTool
	Key			  = ccKey
	Value		  = .T.
	EditClassName = 'clsSearch'

Enddefine


Define Class clsBeta As Custom

	Tool		  = ccTool
	Key			  = ccKeyBeta
	Value		  = .T.
	EditClassName = 'clsSearch'

Enddefine


Define Class clsSearch As Container

	Procedure Init
		Local loRenderEngine
		loRenderEngine = Execscript(_Screen.cThorDispatcher, 'Class= OptionRenderEngine')

		Text To m.loRenderEngine.cBodyMarkup Noshow Textmerge
		
			.Class	   = 'CheckBox'
			.Width	   = 300
			.Left	   = 25
			.Caption   = ccCaption
			.cTool	   = ccTool
			.cKey	   = ccKey
|
			.Class	   = 'CheckBox'
			.Width	   = 300
			.Left	   = 25
			.Caption   = ccCaptionBeta
			.cTool	   = ccTool
			.cKey	   = ccKeyBeta
		
		Endtext

		m.loRenderEngine.Render(This, ccTool)

	Endproc

 Enddefine
