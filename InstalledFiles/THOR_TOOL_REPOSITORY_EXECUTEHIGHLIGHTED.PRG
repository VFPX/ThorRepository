Lparameters lxParam1

#Define ccTool 'Execute highlighted text'
****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1								;
		And 'O' = Vartype (m.lxParam1)		;
		And 'thorinfo' = Lower (m.lxParam1.Class)

	With m.lxParam1

		* Required
		.Prompt		 = ccTool
		.AppID 		 = 'ThorRepository'
		Text To .Description Noshow
Executes the highlighted text.

If nothing highlighted, executes the current (possibly multiple line) statement.

Handles any defined constants from #Defines or #Includes.

Calls plugin "Thor_Proc_SaveExecuted" with parameter of the executed text.
		Endtext
		* For public tools, such as PEM Editor, etc.
		.Source			 = 'Thor Repository'
		.Category		 = 'Code|Highlighting text'
		.Author			 = 'Jim Nelson'
		.Link			 = 'https://github.com/VFPX/Thor/blob/master/Docs/NewsItems/Item_46.md'
		.CanRunAtStartUp = .F.
		
		.PlugInClasses  = 'clsPlugIn'
		.PlugIns 		= 'ExecuteSelection'
		
	Endwith

	Return m.lxParam1
Endif


Do ToolCode

Return


****************************************************************
****************************************************************
* Normal processing for this tool begins here.

#Define CR               	Chr(13)
#Define LF               	Chr(10)
#Define CRLF             	Chr(13)+Chr(10)
#Define Tab				    Chr(9)

#Define 	CommandWindow	0
#Define		PRGFile			1
#Define		ModifyFile		2
#Define		MenuCode		8
#Define		MethodCode		10
#Define		DBCCode			12

Procedure ToolCode

	Local lcClipText, loHighlightedText

	loHighlightedText = Execscript(_Screen.cThorDispatcher, 'class= HighlightedText from Thor_Proc_HighlightedText.PRG', 'Statement', .T.)
	If Not Empty(m.loHighlightedText.cError)
		Messagebox(m.loHighlightedText.cError, 16, 'Error', 0)
		Return
	Endif
	lcClipText = GetDefines() + m.loHighlightedText.cHighLightedText

	Execscript(_Screen.cThorDispatcher, 'Thor_Proc_SaveExecuted', m.lcClipText)

	Execscript(m.lcClipText)

Endproc


Procedure GetDefines

	Local lcDefines, lnWindowType, loEditorWin

	loEditorWin	 = Execscript (_Screen.cThorDispatcher, 'class= editorwin from pemeditor')
	lnWindowType = m.loEditorWin.GetEnvironment(25)

	lcDefines = ''

	If m.lnWindowType = MethodCode
		lcDefines = m.lcDefines + GetClassIncludeFile()
	Endif

	If m.lnWindowType # CommandWindow
		lcDefines = m.lcDefines + GetHashDefines(m.loEditorWin)
	Endif

	Return m.lcDefines
Endproc


Procedure GetClassIncludeFile
	Local laSelObj[1], lcFile, lcInclude, lnCount

	lcInclude = ''
	lnCount	  = Aselobj(laSelObj, 3)
	If m.lnCount > 0
		lcFile = m.laSelObj[3]
		If Not Empty(m.lcFile) And File(m.lcFile)
			lcInclude = "#Include '" + lcFile + "'" + CRLF
		Endif
	Endif
	Return m.lcInclude
Endproc


Procedure GetHashDefines(loEditorWin)
	Local loRegExp As 'VBScript.RegExp'
	Local lcDefines, lcMatchLine, lcTextBefore, lnI, loMatches

	lcTextBefore = m.loEditorWin.GetString(0, m.loEditorWin.GetSelStart())
	lcTextBefore = Strtran(m.lcTextBefore, CRLF, CR)
	lcTextBefore = Strtran(m.lcTextBefore, CR, CRLF)

	loRegExp  = Createobject ('VBScript.RegExp')
	With m.loRegExp
		.IgnoreCase	= .T.
		.Global		= .T.
		.MultiLine	= .T.
		.Pattern	= '^\s*#(Defi|Defin|Define|Incl|Inclu|Includ|Include).*$'

	Endwith
	loMatches = m.loRegExp.Execute (m.lcTextBefore)

	lcDefines = ''
	For lnI = 1 To m.loMatches.Count
		lcMatchLine	= m.loMatches.Item[m.lnI - 1].Value
		lcMatchLine	= Alltrim(m.lcMatchLine, 1, CR, LF, Tab, ' ')
		lcDefines	= m.lcDefines + m.lcMatchLine + CRLF
	Endfor

	Return m.lcDefines
Endproc


****************************************************************
****************************************************************

Define Class clsPlugIn As Custom

	Source				= 'ISX'
	PlugIn				= 'ExecuteSelection'
	Description			= 'xxxxAllows for modification of the drop down list from AutoComplete'
	Tools				= 'Execute highlighted text'
	FileNames			= 'Thor_Proc_SaveExecuted.PRG'
	DefaultFileName		= '*Thor_Proc_SaveExecuted.PRG'
	DefaultFileContents	= ''

	Procedure Init
		****************************************************************
		****************************************************************
		Text To This.DefaultFileContents Noshow
* Sample: save selected text to clipboard		
LParameters lcSelectedText
_cliptext = lcSelectedText
		Endtext
		****************************************************************
		****************************************************************
	Endproc

Enddefine

