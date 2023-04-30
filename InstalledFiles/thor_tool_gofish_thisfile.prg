Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1								;
		And 'O' = Vartype (m.lxParam1)		;
		And 'thorinfo' == Lower (m.lxParam1.Class)

	With m.lxParam1

		* Required
		.Prompt		   = 'GoFish / this SCX or VCX'

		.Category      = 'Applications|GoFish'
		
		Text To .Description Noshow Textmerge
Invokes GF to search for the currently highlighted text in only the current SCX or VCX.
Steps:
    1) Call this tool (it opens GF for you)
    2) Save and close the SCX / VCX you are editing (GF cannot search it if it's open.)
    3) Run GF
    4) Call this tool again (restores GF to its prior state)
		Endtext

		.Author	  = 'JRN'
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

	Local laSelObj[1], lcHighLighted, lcOldClipText, loEditorWin

	loEditorWin = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_EditorWin')
	If m.loEditorWin.GetEnvironment(25) > 0
		lcOldClipText = _Cliptext
		m.loEditorWin.Copy()
		lcHighLighted = _Cliptext
		_Cliptext	  = m.lcOldClipText
	Else
		lcHighLighted = ''
	Endif

	Do Case
		Case 0 # Aselobj(laSelObj, 3) and Type('_Screen._GoFishThisFile') # 'O'

			TurnItOn(m.laSelObj[2], m.lcHighLighted)

		Case Type('_Screen._GoFish.oResultsForm') = 'O'			;
				And Type('_Screen._GoFishThisFile') = 'O'

			TurnItOff()

	Endcase

Endproc


Procedure TurnItOn(lcFileName, lcHighLighted)
	Local loGoFishThisFile As 'Empty'
	Local lcFileName, loGoFishForm

	Do (_Screen.cThorFolder + 'TOOLS\APPS\GOFISH5\GOFISH5.APP')

	loGoFishForm = _Screen._GoFish.oResultsForm

	loGoFishThisFile = Newobject('Empty')

	With m.loGoFishForm.oSearchOptions
		AddProperty(m.loGoFishThisFile, 'nSearchScope', .nSearchScope)
		AddProperty(m.loGoFishThisFile, 'cPath', .cPath)
		AddProperty(m.loGoFishThisFile, 'cFileTemplate', .cFileTemplate)
		AddProperty(m.loGoFishThisFile, 'cSearchExpression', .cSearchExpression)
		AddProperty(m.loGoFishThisFile, 'cRecentScope', .cRecentScope)

		_Screen.AddProperty('_GoFishThisFile', m.loGoFishThisFile)

		.nSearchScope	   = 4
		.cPath			   = Justpath(m.lcFileName)
		.cFileTemplate	   = Justfname(m.lcFileName)
		.cSearchExpression = m.lcHighLighted
	Endwith

	m.loGoFishForm.Refresh()

Endproc


Procedure TurnItOff
	Local loGoFishForm, loGoFishThisFile

	loGoFishForm	 = _Screen._GoFish.oResultsForm
	loGoFishThisFile = _Screen._GoFishThisFile

	With m.loGoFishForm.oSearchOptions
		.nSearchScope	   = m.loGoFishThisFile.nSearchScope
		.cPath			   = m.loGoFishThisFile.cPath
		.cFileTemplate	   = m.loGoFishThisFile.cFileTemplate
		.cSearchExpression = m.loGoFishThisFile.cSearchExpression
		.cRecentScope	   = m.loGoFishThisFile.cRecentScope
	Endwith

	_Screen._GoFishThisFile = Null

	m.loGoFishForm.Refresh()

Endproc