* If both new GoFish and old GoFish5 still around,
* ask user if old GoFish5 should be uninstalled.

Local lcNewGoFish, lcNewGoFishTool, lcNewGoFishVersion, lcOldGoFish, lcOldGoFish5Tool
Local lcOldGoFishVersion, lcRecycle, lcToolFolder, loCloseTempFiles, loTools

lcToolFolder  = Execscript(_Screen.cThorDispatcher, 'Tool Folder=')

* ================================================================================ 
* Is old GoFish5 even installed?
lcOldGoFish = m.lcToolFolder + '\Apps\GoFish5\GoFishVersionFile.txt'
If File(m.lcOldGoFish)
	lcOldGoFishVersion = Filetostr(m.lcOldGoFish)
	lcOldGoFish5Tool   = 'Thor_Tool_Gofish5.prg'
Else
	Return
Endif

* ================================================================================ 
* Is current GoFish even installed?
lcNewGoFish = m.lcToolFolder + '\Apps\GoFish\GoFishVersionFile.txt'
If File(m.lcNewGoFish)
	lcNewGoFishVersion = Filetostr(m.lcNewGoFish)
	lcNewGoFishTool	   = 'Thor_Tool_Gofish.prg'
Else
	Return
Endif

* ================================================================================ 
If AskToUnInstall(m.lcOldGoFishVersion, m.lcNewGoFishVersion)

	* Open all Thor tables, and close them when loCloseTempFiles go out of scope
	loTools = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_utils')
	loCloseTempFiles = m.loTools.CloseTempFiles()
	m.loTools.OpenThorTables()

	UpdateHotKeys(m.lcOldGoFish5Tool, m.lcNewGoFishTool)
	UpdateMenus(m.lcOldGoFish5Tool, m.lcNewGoFishTool)

	lcRecycle = CreateRecycleFolder(m.lcToolFolder)
	RemoveTools(m.lcToolFolder, m.lcOldGoFish5Tool, m.lcRecycle)
	RemoveFolder(m.lcOldGoFish, m.lcRecycle)

	Execscript(_Screen.cThorDispatcher, 'Thor_proc_messagebox', 'GoFish5 un-installed')
Endif


* ================================================================================
* ================================================================================

Procedure AskToUnInstall(lcOldGoFishVersion, lcNewGoFishVersion)
	Local lcPrompt, lcResponse

	Text To m.lcPrompt Noshow Textmerge
GoFish5 (<<GetVersionNumber(lcOldGoFishVersion)>>) is deprecated but still installed.
Do you want to un-install GoFish5 and replace all references to it
with references to current GoFish (<<GetVersionNumber(lcNewGoFishVersion)>>) ?
	Endtext

	lcResponse = Execscript(_Screen.cThorDispatcher, 'Thor_proc_messagebox', m.lcPrompt, 3, 'Un-Install GoFish5?')
	Return m.lcResponse = 'Y'
Endproc


Procedure GetVersionNumber(lcVersion)
	Local lcDate

	lcDate = Alltrim(Getwordnum(m.lcVersion, 4, '-' ))
	lcDate = Substr(m.lcDate, 1, 4) + '/' + Substr(m.lcDate, 5, 2) + '/' + Substr(m.lcDate, 7, 2)
	Return Getwordnum(m.lcVersion, 2, '-' ) + ' - ' + m.lcDate
Endproc

* ================================================================================
* ================================================================================

Procedure UpdateHotKeys(lcOldGoFish5Tool, lcNewGoFishTool)
	Select ToolHotKeyAssignments
	Locate For Upper(PRGName) = Upper(m.lcNewGoFishTool)
	If Found() && Current GF already has a hot key
		Replace HotKeyID With 0 For Upper(PRGName) = Upper(m.lcOldGoFish5Tool)
	Else && re-assign key for old GF5 to current GF
		Replace PRGName With m.lcNewGoFishTool For Upper(PRGName) = Upper(m.lcOldGoFish5Tool)
	Endif
Endproc

Procedure UpdateMenus(lcOldGoFish5Tool, lcNewGoFishTool)
	Select MenuTools
	Replace	PRGName	 With  m.lcNewGoFishTool,							;
			Prompt	 With  Strtran(Prompt, 'GoFish5', 'GoFish')			;
		For Upper(PRGName) = Upper(m.lcOldGoFish5Tool)
Endproc

Procedure RemoveTools(lcToolFolder, lcOldGoFish5Tool, lcRecycle)
	Local laFiles[1], lcFileName, lcStem, lnCount, lnI

	lcStem	= Juststem(m.lcOldGoFish5Tool)
	lnCount	= Adir(laFiles, m.lcToolFolder + m.lcStem + '*.*')
	For lnI = 1 To m.lnCount
		lcFileName = Trim(m.laFiles[m.lnI, 1])
		MoveFile(m.lcToolFolder + m.lcFileName, Addbs(m.lcRecycle) + m.lcFileName)
	Endfor
Endproc

Procedure RemoveFolder(lcOldGoFish, lcRecycle)
	Local lcDest, lcSource

	lcSource = Justpath(m.lcOldGoFish)
	lcDest	 = Addbs(m.lcRecycle) + Juststem(m.lcSource)
	MoveFile(m.lcSource, m.lcDest)
Endproc

* ================================================================================
* ================================================================================

Procedure CreateRecycleFolder(lcToolFolder)
	Local lcRecyle, loException

	lcRecyle = Addbs(m.lcToolFolder) + 'Recycle'
	Try
		Mkdir(m.lcRecyle)
	Catch To m.loException

	Endtry
	Return m.lcRecyle
Endproc


Procedure MoveFile(lcOldName, lcNewName)
	Local Success

	Declare Integer MoveFile In win32api String @ src, String @ Dest

	Success = Not Empty(MoveFile(m.lcOldName, m.lcNewName))

	Return m.Success
Endproc


