#Define 	CommandWindow	0
#Define		PRGFile			1
#Define		ModifyFile		2
#Define		MenuCode		8
#Define		MethodCode		10
#Define		DBCCode			12

Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1								;
		And 'O' = Vartype (lxParam1)		;
		And 'thorinfo' = Lower (lxParam1.Class)

	With lxParam1

		* Required
		.Prompt		 = 'Insert full name of object under mouse'
		Text To .Description Noshow
Pastes the full path name of the object under the mouse into the code window.

This tool is used when you want to insert a reference to an object into a code window.  Hover the mouse over the object you want to refer to and then use this tool; a relative reference to the object is inserted into the code window.

Can only be used by hot key.

See also tool "Inspect properties of object under mouse".
		Endtext
		* For public tools, such as PEM Editor, etc.
		.Source			 = 'Thor Repository'
		.Category		 = 'Code|Inserting text'
		.Author			 = 'Bernard Bout'
		.CanRunAtStartUp = .F.
		.Link			 = 'https://vfpx.codeplex.com/wikipage?title=Thor%20TWEeT%204'
	Endwith

	Return lxParam1
Endif

Do ToolCode

Return


****************************************************************
****************************************************************
* Normal processing for this tool begins here.
Procedure ToolCode

	Local loEditorWin As Editorwin Of 'c:\visual foxpro\programs\MyThor\thor\tools\apps\pem editor\source\peme_editorwin.vcx'
	Local lnWindowType, loSys1270
	loSys1270	  = Sys(1270)
	If 'O' # Vartype (loSys1270)
		Return
	Endif

	* editorwin home page = http://vfpx.codeplex.com/wikipage?title=thor%20editorwindow%20object
	loEditorWin = Execscript(_Screen.cThorDispatcher, 'Class= editorwin from pemeditor')

	lnWindowType = loEditorWin.GetEnvironment(25)
	Do Case
		Case lnWindowType = MethodCode
			WithinMethodWindow(loEditorWin, loSys1270)
		Case lnWindowType = CommandWindow
			WithinCommandWindow(loEditorWin, loSys1270)
		Otherwise
			Return
	Endcase

Endproc


Procedure WithinMethodWindow(loEditorWin, loSys1270)
	* see	http://vfpx.codeplex.com/wikipage?title=Thor%20Tools%20Object
	Local laObjects[1], lcMyName, lcName, lcOrigName, lcText, loTools
	loTools = Execscript (_Screen.cThorDispatcher, 'class= tools from pemeditor')

	lcName	   = loTools.GetFullObjectName (loSys1270)
	lcOrigName = lcName
	lcMyName   = loTools.GetFullObjectName (loTools.GetThis())

	Do While Getwordcount (lcMyName, '.') > 0		;
			And Upper (Getwordnum (lcMyName, 1, '.')) == Upper (Getwordnum (lcName, 1, '.'))
		lcName	 = Substr (lcName, At ('.', lcName, 2))
		lcMyName = Substr (lcMyName, At ('.', lcMyName, 2))
	Enddo
	lcText = 'This' + Replicate ('.Parent', Occurs ('.', lcMyName)) + lcName

	Aselobj (laObjects, 3)
	If Upper (Justext (laObjects[2])) == 'SCX' And Len('Thisform' + lcOrigName) <= Len(lcText)
		lcText = 'Thisform' + lcOrigName
	Endif

	loEditorWin.Paste (lcText)

	Return

Endproc


Procedure WithinCommandWindow(loEditorWin, loObject)
	Local lcName, lnHwnd, lnI
	lcName = loObject.Name
	Do While Lower(loObject.BaseClass) # 'form' And Pemstatus(loObject, 'Parent', 5)
		loObject = loObject.Parent
		lcName	 = loObject.Name + '.' + lcName
	Enddo

	If Pemstatus(loObject, 'Hwnd', 5)
		lnHwnd = loObject.HWnd
		For lnI = 1 To _Screen.FormCount
			If lnHwnd = _Screen.Forms[lnI].HWnd
				lcName = '_Screen.Forms[' + Transform(lnI) + ']' + Substr(lcName, Evl(At('.', lcName), 1000))
				Exit
			Endif
		Endfor
	Endif && PemStatus(loObject, 'Hwnd', 5)

	loEditorWin.Paste(lcName)

Endproc
