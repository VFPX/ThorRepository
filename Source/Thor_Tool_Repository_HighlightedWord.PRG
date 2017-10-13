Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1								;
		And 'O' = Vartype(lxParam1)			;
		And 'thorinfo' == Lower(lxParam1.Class)

	With lxParam1

		* Required
		.Prompt		   = 'Highlight current word' && used in menus

		* Optional
		Text To .Description Noshow && a description for the tool
Highlights the current word. Keyboard version of double-clicking
		Endtext
		.StatusBarText = ''

		* These are used to group and sort tools when they are displayed in menus or the Thor form
		.Category      = 'Code|Highlighting Text' && creates categorization of tools; defaults to .Source if empty

		* For public tools, such as PEM Editor, etc.
		.Author        = 'Jim Nelson'
		.CanRunAtStartUp = .F.

	Endwith

	Return lxParam1
Endif

If Pcount() = 0
	Do ToolCode
Else
	Do ToolCode With lxParam1
Endif

Return

****************************************************************
****************************************************************
* Normal processing for this tool begins here.                  
Procedure ToolCode
	Lparameters lxParam1

	* editorwin home page = http://vfpx.codeplex.com/wikipage?title=thor%20editorwindow%20object
	Local loEditorWin As Editorwin Of 'c:\visual foxpro\programs\MyThor\thor\tools\apps\pem editor\source\peme_editorwin.vcx'
	Local lcChar, lnSelEnd, lnSelStart
	loEditorWin = Execscript(_Screen.cThorDispatcher, 'Class= editorwin from pemeditor')

	If loEditorWin.FindWindow() < 0
		Return
	Endif

	lnSelStart = loEditorWin.GetSelStart()
	*** JRN 2010-04-02 : add in preceding characters
	For lnSelStart = lnSelStart To 0 Step - 1
		If Not IsNameChar(loEditorWin.GetCharacter(lnSelStart - 1))
			Exit 
		Endif
	Endfor

	***************************
	For lnSelEnd = lnSelStart To 1000000
		lcChar = loEditorWin.GetCharacter(lnSelEnd)
		If Not IsNameChar(lcChar)
			Exit
		Endif
	EndFor

	***************************
	loEditorWin.Select(lnSelStart, lnSelEnd)
Endproc


Procedure IsNameChar
	Lparameters lcChar
	Return Isalpha(lcChar) Or Isdigit(lcChar) Or lcChar = '_'
Endproc