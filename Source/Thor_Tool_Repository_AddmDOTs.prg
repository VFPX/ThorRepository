Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

Local laHandles[1], laLines[1], laObjectInfo[1], lcClipText, lcFirstLine, lcIndent, lcNewCliptext
Local lcOldClipText, lcSourceFileName, lcThisFolder, lcWindowName, lcWonTop, llHasFocus
Local lnCursorPosition, lnI, lnLineCount, lnMatchIndex, lnWindowCount, loEditorWin, loThisForm
Local loWindow, loWindows
If Pcount() = 1								;
		And 'O' = Vartype (lxParam1)		;
		And 'thorinfo' = Lower (lxParam1.Class)

	With lxParam1

		* Required
		.Prompt		 = 'Add MDots to variable names'
		Text To .Description Noshow
Adds MDots to all references to parameters, locals, and other variables assigned values.
		Endtext
		* For public tools, such as PEM Editor, etc.
		.Source			 = 'Thor Repository'
		.Category		 = 'Code|MDots'
		.Author			 = 'Jim Nelson'
		.Link			 = 'http://vfpx.codeplex.com/wikipage?title=Thor%20EditorWindow%20Object'
		.OptionClasses	 = 'clsMDotsProperties, clsMDotsWhereRequired, clsMDotsinBeautifyX'
		.OptionTool		 = 'MDots'
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

	Local lcClipText, lcNewCliptext, lcOldClipText, lnMDotsUsage, lnSelEnd, lnSelStart, loEditorWin

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

	lnMDotsUsage  = ExecScript(_Screen.cThorDispatcher, "Get Option=", 'MDots Usage', 'MDots')
	lcNewCliptext = Execscript (_Screen.cThorDispatcher, 'Thor_Proc_AddMDotsMultipleProcs', lcClipText, lnMDotsUsage = 3)

	****************************************************************
	* This final block of code pastes in the modification (in <lcNewCliptext>)
	loEditorWin.Paste (lcNewCliptext)
	_Cliptext = lcOldClipText
	loEditorWin.Select (lnSelStart, lnSelStart)
	loEditorWin.SetInsertionPoint (lnSelStart)

	Return
Endproc


****************************************************************
****************************************************************
#Define		ccContainerName			'clsMDots'
#Define		ccToolName				'MDots'

#Define		ccKeyUsage				'MDots Usage'
#Define		ccKeyWhereRequired		'MDots where required'
#Define		ccKeyInBeautifyX		'MDots in BeautifyX'

Define Class clsMDotsProperties As Custom

	Tool		  = ccToolName
	Key			  = ccKeyUsage
	Value		  = 1
	EditClassName = ccContainerName

Enddefine

Define Class clsMDotsWhereRequired As Custom

	Tool		  = ccToolName
	Key			  = ccKeyWhereRequired
	Value		  = .F.
	EditClassName = ccContainerName

Enddefine

Define Class clsMDotsinBeautifyX As Custom

	Tool		  = ccToolName
	Key			  = ccKeyInBeautifyX
	Value		  = .F.
	EditClassName = ccContainerName

Enddefine

****************************************************************
****************************************************************
Define Class clsMDots As Container

	Procedure Init
		Local loRenderEngine
		loRenderEngine = Execscript(_Screen.cThorDispatcher, 'Class= OptionRenderEngine')

		Text To loRenderEngine.cBodyMarkup Noshow Textmerge
		
			.Name			  = 'optUsage'
			.Class			  = 'optiongroup'
			.cTool	  		  = ccToolName
			.cKey	          = ccKeyUsage
			.cCaptions		  = 'Not used\\m. (lowercase)\\M. (uppercase)'
			|
			.Class	  = 'CheckBox'
			.AutoSize = .T.
			.Caption  = 'Use MDots only where required'
			.cTool	  = ccToolName
			.cKey	  = ccKeyWhereRequired
			|
			.Class	  = 'CheckBox'
			.AutoSize = .T.
			.Caption  = 'Create MDots as part of BeautifyX'
			.cTool	  = ccToolName
			.cKey	  = ccKeyInBeautifyX
		Endtext

		loRenderEngine.Render(This, ccToolName)

		Bindevent(This.optUsage, 'InteractiveChange', This, 'ClearISXOptions')

	Endproc

	Procedure ClearISXOptions
		_Screen.AddProperty('oISXOptions', Null)
	Endproc

Enddefine

