#Define ccTool 'Keyboard Macro Expansion'
Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1								;
		And 'O' = Vartype(m.lxParam1)		;
		And 'thorinfo' == Lower(m.lxParam1.Class)

	With m.lxParam1

		* Required
		.Prompt		   = ccTool && used in menus

		* Optional
		Text To .Description Noshow && a description for the tool
Provides for using Intellisense custom scripts in the middle of the line (instead of only at the beginnning)

Based on ISX.Prg by Christof
		Endtext
		.StatusBarText	 = ''
		.CanRunAtStartUp = .F.

		* These are used to group and sort tools when they are displayed in menus or the Thor form
		.Category = 'Code|IntellisenseX' && creates categorization of tools; defaults to .Source if empty
		.Sort	  = 90 && the sort order for all items from the same Category

		* For public tools, such as PEM Editor, etc.
		.Author		= 'Christof Wollenhaupt (enhancements for Thor by Jim Nelson)'
		.Link     = 'https://vfpx.codeplex.com/wikipage?title=Thor%20TWEeT%2024'
		.VideoLink	= 'http://vfpx.codeplex.com/wikipage?title=Thor%20IntellisenseX#Videos'
		.OptionTool	= 'IntellisenseX'
		
		.PlugInClasses = 'clsMacroExpandsionPlugIn'
		.PlugIns 		= ccTool

	Endwith

	Return m.lxParam1
Endif

If Pcount() = 0
	Do ToolCode
Else
	Do ToolCode With m.lxParam1
Endif

Return

****************************************************************
****************************************************************
* Normal processing for this tool begins here.                  
Procedure ToolCode
	Lparameters lxParam1

Local lcClipboard, lcHighLightedText, lcPasteText, lcWindowType, lnWordEnd, lnWordStart
Local loHighlightedText
	lcClipboard		  = _Cliptext
	loHighlightedText = Execscript (_Screen.cThorDispatcher, 'class= HighlightedText from Thor_Proc_HighlightedText.PRG', 'Word', .T.)

	If Not Empty (m.loHighlightedText.cError)
		Messagebox (m.loHighlightedText.cError, 16, 'Error', 0)
		Return
	Endif

	lcHighLightedText = m.loHighlightedText.cHighLightedText
	lcWindowType = m.loHighlightedText.oEditorWin.FindWindow()
	
	lcPasteText = ExecScript(_Screen.cThorDispatcher, 'Thor_Proc_MacroExpansion', lcHighLightedText, lcWindowType)

	If Vartype(m.lcPasteText) = 'C' and Not Empty(m.lcPasteText)
		lnWordStart	= m.loHighlightedText.nWordStart
		lnWordEnd	= m.loHighlightedText.nWordEnd
		m.loHighlightedText.SelectText(m.lnWordStart, m.lnWordEnd)
		If '~' $ m.lcPasteText
			m.loHighlightedText.PasteText(Chrtran(m.lcPasteText, '~', ''))
			m.loHighlightedText.oEditorWin.SetInsertionPoint(m.lnWordStart + At('~', m.lcPasteText) - 1)
		Else
			m.loHighlightedText.PasteText(m.lcPasteText)
			m.loHighlightedText.oEditorWin.SetInsertionPoint(m.lnWordStart + Len(m.lcPasteText))
		Endif
		_Cliptext = m.lcClipboard
	Endif

Endproc


* ================================================================================
* ================================================================================

Define Class clsMacroExpandsionPlugIn As Custom

	Source				= 'ISX'
	PlugIn				= 'Macro Expansion'
	Description			= 'Allows the replacement text in Macro Expansion to be determined programmatically.'
	Tools				= ccTool
	FileNames			= 'Thor_Proc_MacroExpansion.PRG'
	DefaultFileName		= '*Thor_Proc_MacroExpansion.PRG'
	DefaultFileContents	= ''

	Procedure Init
		****************************************************************
		****************************************************************
		Text To This.DefaultFileContents Noshow
Lparameters lcHighLightedText, lcWindowType

Local lcResult, lcTableName
Do Case

		* silly example, expands "ABCD" to "ZYXW123"
	Case Upper(m.lcHighLightedText) = 'ABCD'
		lcResult = 'ZY~XW123'

		* from Matt Slay, expands "loJob" to "Local loJob as Job of Job.prg"
	Case m.lcHighLightedText = 'lo' And m.lcWindowType > 0
		lcTableName	= Substr(m.lcHighLightedText, 3)
		lcResult	= Textmerge('Local <<lcHighlightedText>> as <<lcTableName>> of <<lcTableName>>.prg')

		* Default is to expand highlighted text based on FoxPro's normal Intellisense
	Otherwise
		lcResult      = Execscript(_Screen.cThorDispatcher, 'DoDefault()', m.lcHighLightedText, m.lcWindowType)

Endcase

Return Execscript(_Screen.cThorDispatcher, 'Result=', m.lcResult)
Endtext
		****************************************************************
		****************************************************************
	Endproc

Enddefine
