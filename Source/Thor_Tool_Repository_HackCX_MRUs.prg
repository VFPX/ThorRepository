#Define		ccCURRENTFILE		'*** Current File ***'
#Define 	ccPROMPTFORFILE 	'*** Prompt ***'

#Define		ccThorKey			'File name'
#Define		ccThorTool			'HackCX'


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
		.Prompt	 = 'HackCX4 from MRU forms or classes' && used when tool appears in a menu
		.Summary = 'HackCX: Pop-up menu to select form or class to be opened with HackCX4'
		Text To .Description Noshow
HackCX: Pop-up menu to select form or class to be opened with HackCX4.

Requires separate installation of HackCX4 from WhiteLightComputing.Com
		Endtext

		* For public tools, such as PEM Editor, etc.
		.Source	  = 'Thor Repository'
		.Category = 'Applications'
		.Link     = 'https://vfpx.codeplex.com/wikipage?title=Thor%20TWEeT%2024'
		.Author	  = 'Rick Schummer / White Light Computing'
		.CanRunAtStartUp = .F.
	Endwith

	Return lxParam1
Endif

Do ToolCode With Sys(16)

Return


****************************************************************
****************************************************************
* Normal processing for this tool begins here.                  
Procedure ToolCode (lcPRGName)

	* ContextMenu home page = http://vfpx.codeplex.com/wikipage?title=Thor%20Framework%20ContextMenu
	Local loContextMenu As ContextMenu Of 'C:\VISUAL FOXPRO\PROGRAMS\MyThor\Thor\Source\Thor_Menu.vcx'
	Local loParameters As 'lcCurrentFile'
	Local loTools As Pemeditor_tools Of 'c:\visual foxpro\programs\MyThor\thor\tools\apps\pem editor\source\peme_tools.vcx'
	Local laObjects[1], lcCurrentFile, lcExecutableFile, lcFile, lcFileName, lcForm, lcPrompt, loFindEXE
	Local loMRUClasses, loMRUForms, loObject
	* tools home page = http://vfpx.codeplex.com/wikipage?title=thor%20tools%20object


	* --------------------------------------------------------------------------------
	lcExecutableFile = ExecScript(_Screen.cThorDispatcher, 'Thor_Proc_GetHackCX')
	If Empty(lcExecutableFile)
		Return
	Endif
	* --------------------------------------------------------------------------------

	loTools = Execscript (_Screen.cThorDispatcher, 'class= tools from pemeditor')
	If 'O' # Vartype (loTools)
		Return
	Endif

	loContextMenu = Execscript (_Screen.cThorDispatcher, 'class= contextmenu')

	If 0 # Aselobj(laObjects, 3)
		lcCurrentFile = laObjects[2]
		loParameters  = Createobject('Empty')
		AddProperty(loParameters, 'FileName', lcCurrentFile)
		lcPrompt = Upper(Justfname(lcCurrentFile))
		If 'VCX' == Upper(Justext(lcCurrentFile))
			loObject = loTools.GetCurrentObject(.T.)
			AddProperty(loParameters, 'ClassName', loObject.Name)
			lcPrompt = 'Library ' + lcPrompt
		Else
			AddProperty(loParameters, 'ClassName')
			lcPrompt = 'Form ' + lcPrompt
		Endif
		loContextMenu.AddMenuItem (lcPrompt, , , , ccCURRENTFILE, loParameters)
	Endif

	loContextMenu.AddMenuItem ('Prompt for file', , , , ccPROMPTFORFILE)

	loMRUForms = loTools.GetMRUList ('SCX')
	If loContextMenu.AddSubMenu ('Forms')
		For Each lcFile In loMRUForms FoxObject
			AddItem(loTools, loContextMenu, lcFile)
		Endfor
		loContextMenu.EndSubMenu ()
	Endif

	loMRUClasses = loTools.GetMRUList ('MRU2')
	If loContextMenu.AddSubMenu ('ClassLibs')
		For Each lcFile In loMRUClasses FoxObject
			If '|' $ lcFile
				lcFile = Left (lcFile, At ('|', lcFile) - 1)
			Endif
			AddItem(loTools, loContextMenu, lcFile)
		Endfor
		loContextMenu.EndSubMenu ()
	Endif

	If loContextMenu.Activate()
		lcFileName = loContextMenu.KeyWord
		Do Case
			Case lcFileName = ccCURRENTFILE
				lcFileName = loContextMenu.Parameters
				lcForm	   = Execscript(_Screen.cThorDispatcher, 'Full Path=Thor_Proc_Use_HackCX.SCX')
				Do Form (lcForm) With lcFileName
				Return
			Case lcFileName == ccPROMPTFORFILE
				lcFileName = Getfile('?CX', 'Form or Class Library', 'Open', 0, 'Get file for HackCX')
			Otherwise
		Endcase

		Do (lcExecutableFile) With (lcFileName)

	Endif

Endproc


Procedure AddItem(loTools, loContextMenu, lcFile)
	Local lcDisplayName, lcFName
	lcFile		  = loTools.DiskFileName(lcFile)
	lcDisplayName = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_RelativePath', lcFile)
	lcFName		  = Justfname (lcDisplayName)
	If Not lcFName == lcDisplayName
		lcDisplayName = lcFName + '    from  ' + Justpath (lcDisplayName)
	Endif
	loContextMenu.AddMenuItem (lcDisplayName, , , , lcFile)
Endproc


*!* ******************** Removed 5/4/2013 *****************
*!* Procedure GetEXEFileName
*!* 	Local lcDisplayName, lcExecutable, lcFile, lcFileName, lnMsgBoxAns
*!* 	lcExecutable = Execscript(_Screen.cThorDispatcher, 'Get Option=', ccThorKey, ccThorTool)
*!* 	If File(Nvl(lcExecutable, ''))
*!* 		Return lcExecutable
*!* 	Endif
*!* 	If File('HACKCX4.EXE')
*!* 		lcFile		  = Fullpath('HACKCX4.EXE')
*!* 		lcDisplayName = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_RelativePath', lcFile)
*!* 		lnMsgBoxAns	  = Messagebox('Use ' + lcDisplayName + '?', 35, 'Looking for HackCX')
*!* 		Do Case
*!* 			Case lnMsgBoxAns = 6 && Yes
*!* 				Execscript(_Screen.cThorDispatcher, 'Set Option=', ccThorKey, ccThorTool, lcFile)
*!* 				Return lcFile
*!* 			Case lnMsgBoxAns = 2 && Cancel
*!* 				Return ''
*!* 		Endcase
*!* 	Endif

*!* 	lcFile = Getfile('EXE', 'HackCX Executable', 'OK', 0, 'Find HackCX')
*!* 	If File(lcFile)
*!* 		Execscript(_Screen.cThorDispatcher, 'Set Option=', ccThorKey, ccThorTool, lcFile)
*!* 		Return lcFile
*!* 	Else
*!* 		Return ''
*!* 	Endif

*!* Endproc

