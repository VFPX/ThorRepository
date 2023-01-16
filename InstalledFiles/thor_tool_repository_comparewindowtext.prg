Lparameters lxParam1


#Define ccTool 'Compare text in two windows'

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1								;
		And 'O' = Vartype (m.lxParam1)		;
		And 'thorinfo' = Lower (m.lxParam1.Class)

	With m.lxParam1

		* Required
		.Prompt		 = ccTool && used when tool appears in a menu
		Text To .Description Noshow
- Select one text window
- Execute this tool (hot key is recommended)
- Select a second text window
- Execute this tool again 
    -- and the contents of the two windows will be compared
    
Required!  Click Plug-Ins link (below) to identify the comparison tool (such as Beyond Compare) to be used.
		
		Endtext

		* For public tools, such as PEM Editor, etc.
		.Category		 = 'Miscellaneous'
		.Author			 = 'Jim Nelson'
		.CanRunAtStartUp = .F.

		.PlugInClasses = 'clsCompareTwoMethods'
		.PlugIns 		= ccTool
	Endwith

	Return m.lxParam1
Endif

Do ToolCode

Return


****************************************************************
****************************************************************
* Normal processing for this tool begins here.                  
Procedure ToolCode
	Local loEditorWin As Editorwin Of 'c:\visual foxpro\programs\mythor\thor\tools\apps\pem editor\source\peme_editorwin.vcx'
	Local lcBCompare, lcContents, lcFile1, lcFile2, lcText, lcTitle, lnType

	* editorwin home page = http://vfpx.codeplex.com/wikipage?title=thor%20editorwindow%20object
	loEditorWin = Execscript(_Screen.cThorDispatcher, 'Class= editorwin from pemeditor')

	lnType = m.loEditorWin.FindWindow()
	If Not Inlist(m.lnType, 1, 2, 8, 10, 12)
		Messagebox('Not a text window')
	Endif

	lcContents = m.loEditorWin.GetString(0, 1000000)
	lcTitle	   = JustStem(m.loEditorWin.GetTitle())
	lcTitle	   = Chrtran(m.lcTitle, '[\/-.():]', '')
	If Pemstatus(_vfp, 'cCompareTwoWindowsText', 5) = .F. Or Empty(_vfp.cCompareTwoWindowsText)
		AddProperty(_vfp, 'cCompareTwoWindowsText', m.lcContents)
		AddProperty(_vfp, 'cCompareTwoWindowsTitle', m.lcTitle)
		MessageBox('Text captured for comparison')
	Else
		lcFile2 = Forceext(Addbs(Sys(2023)) + 'Second-' + m.lcTitle + Sys(2015), 'prg')
		Strtofile(m.lcContents, m.lcFile2)

		lcFile1 = Forceext(Addbs(Sys(2023)) + 'First-' + _vfp.cCompareTwoWindowsTitle + Sys(2015), 'prg')
		Strtofile(_vfp.cCompareTwoWindowsText, m.lcFile1)

		AddProperty(_vfp, 'cCompareTwoWindowsText', '')
		AddProperty(_vfp, 'cCompareTwoWindowsTitle', '')

		ExecScript(_Screen.cThorDispatcher, 'Thor_Proc_CompareFiles', lcFile1, lcFile2)

	Endif


EndProc




* ================================================================================
* ================================================================================

Define Class clsCompareTwoMethods As Custom

	Source				= ccTool
	PlugIn				= ccTool
	Description			= 'Compares two files using the comparison tool of your choice.'
	Tools				= ccTool
	FileNames			= 'Thor_Proc_CompareFiles.PRG'
	DefaultFileName		= '*Thor_Proc_CompareFiles.PRG'
	DefaultFileContents	= ''

	Procedure Init
		****************************************************************
		****************************************************************
		Text To This.DefaultFileContents Noshow
Lparameters lcFile1, lcFile2

Local lcCompareEXE, lcText

lcCompareEXE = 'C:\Program Files (x86)\Beyond Compare 4\BCompare.exe'
lcText		 = Textmerge([Run /n "<<lcCompareEXE>>" "<<lcFile1>>" "<<lcFile2>>"])

Execscript(m.lcText)
Endtext
		****************************************************************
		****************************************************************
	Endproc

Enddefine
