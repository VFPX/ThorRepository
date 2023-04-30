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
		.Prompt		   = 'Install Southwest Fox Demo Menus'

		Text To .Description Noshow
Describe it!		
		Endtext
		.Category = 'JRN'
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

#Define ccTab  	Chr(9)
#Define ccLF	Chr(10)
#Define ccCR	Chr(13)
#Define ccCRLF	Chr(13) + Chr(10)

****************************************************************
****************************************************************
* Normal processing for this tool begins here.                  
Procedure ToolCode
	Lparameters lxParam1

	Local lcDestFolder, loThorUtils

	loThorUtils = Execscript(_Screen.cThorDispatcher, 'thor_proc_utils')
	* when loCloseTempFiles goes out of scope, it closes any newly opened tables
	*	loCloseTempFiles = m.loThorUtils.CloseTempFiles()

	m.loThorUtils.OpenThorTables()

	lcDestFolder = _Screen.cThorFolder + 'Tools\Procs\'
	OpenSourceTables(m.lcDestFolder)

	If ReadyToInstall()

		UpdateMenuDefinitions()

		UpdateMenuTools()

		UpdateHotKeyAssignments()

		AssignStartingHotKey()

		RefreshThor()

	Endif

Endproc


Procedure ReadyToInstall

	Local lcPrompt

	Select  New.*,														;
			Cast(Nvl(Current.Id, 0) As I)    As  NewMenuID				;
		From SWFSessionMenuDefinitions       As  New					;
			Join MenuDefinitions             As  Current				;
				On Upper(New.Popupname) = Upper(Current.Popupname)		;
		Into Cursor NewMenuDefs Readwrite

	If _Tally = 0
		lcPrompt = 'Ready to install SWF Popup menu for Thor?'
	Else
		lcPrompt = 'SWF Popup menu for Thor has already been installed.' + ccCR + ccCR + 'Re-install it ?'
	Endif

	Return Messagebox(m.lcPrompt, 3 + 32) = 6
Endproc


Procedure UpdateMenuDefinitions
	Local lnNewID, loMenuDef

	Select  New.*,														;
			Cast(Nvl(Current.Id, 0) As I)    As  NewMenuID				;
		From SWFSessionMenuDefinitions       As  New					;
			Left Join MenuDefinitions        As  Current				;
				On Upper(New.Popupname) = Upper(Current.Popupname)		;
		Into Cursor NewMenuDefs Readwrite

	Scan For NewMenuID = 0
		Scatter Name m.loMenuDef Memo Fields Except Id, HotKeyID
		Select MenuDefinitions
		Append Blank
		Gather Name m.loMenuDef Memo
		lnNewID = Id
		Select NewMenuDefs
		Replace NewMenuID With m.lnNewID
	Endscan

Endproc


Procedure UpdateMenuTools
	Select  New.*,													;
			NMD1.NewMenuID                       As  MenuID,		;
			Cast(Nvl(NMD2.NewMenuID, 0) As I)    As  SubMenuID		;
		From SWFSessionMenuTools                 As  New			;
			Left Join NewMenuDefs                As  NMD1			;
				On New.OldMenuID = NMD1.Id							;
			Left Join NewMenuDefs                As  NMD2			;
				On New.OldSubMenu = NMD2.Id							;
		Into Cursor NewMenuTools

	Insert Into MenuTools															;
		(PRGName, SubMenuID, Separator, SortOrder, Prompt, StatusBar, MenuID)		;
		Select  NewMenuTools.PRGName,												;
				NewMenuTools.SubMenuID,												;
				NewMenuTools.Separator,												;
				NewMenuTools.SortOrder,												;
				NewMenuTools.Prompt,												;
				NewMenuTools.StatusBar,												;
				NewMenuTools.MenuID													;
			From NewMenuTools														;
				Left Join MenuTools													;
					On NewMenuTools.MenuID = MenuTools.MenuID						;
					And Lower(NewMenuTools.PRGName) = Lower(MenuTools.PRGName)		;
			Where Isnull(MenuTools.Id)
Endproc


Procedure UpdateHotKeyAssignments
	Select  HotKeyID					;
		From ToolHotKeyAssignments		;
		Where HotKeyID # 0				;
	Union All							;
	Select  HotKeyID					;
		From MenuDefinitions			;
		Where HotKeyID # 0				;
		Into Cursor HotKeysInUse

	* pop up menus
	Update  MenuDefinitions														;
		Set MenuDefinitions.HotKeyID = SWFSessionMenuDefinitions.HotKeyID		;
		From MenuDefinitions													;
			Join SWFSessionMenuDefinitions										;
				On MenuDefinitions.Id = SWFSessionMenuDefinitions.Id			;
				And SWFSessionMenuDefinitions.HotKeyID # 0						;
		Where Not SWFSessionMenuDefinitions.HotKeyID In (Select  HotKeyID		;
															 From HotKeysInUse)

	* tools
	Select  *												;
		From  SWFSessionToolHotKeyAssignments				;
		Where Not HotKeyID In (Select  HotKeyID				;
								   From HotKeysInUse)		;
		Into Cursor CanAssign

	Update  ToolHotKeyAssignments														;
		Set ToolHotKeyAssignments.HotKeyID = CanAssign.HotKeyID							;
		From CanAssign																	;
			Join ToolHotKeyAssignments													;
				On Lower(CanAssign.PRGName) = Lower(ToolHotKeyAssignments.PRGName)		;
				And ToolHotKeyAssignments.HotKeyID = 0

	Insert Into ToolHotKeyAssignments											;
		(PRGName, HotKeyID)														;
		Select  *																;
			From CanAssign														;
			Where Not Lower(CanAssign.PRGName) In (Select  Lower(PRGName)		;
													   From ToolHotKeyAssignments)

Endproc


Procedure AssignStartingHotKey()

	Local loForm As 'SetHotKeyForm' Of 'Thor_UI.vcx'
	Local laHotKey[1], lcAlias, lcPrompt, lcThorAPP, lnDefaultHotKeyID, lnHotKeyID

	lcAlias = 'MenuDefinitions'
	Select (m.lcAlias)

	Locate For Id = 84
	lnDefaultHotKeyID = HotKeyID

	Locate For Popupname = 'SWF_Top'
	lnHotKeyID = HotKeyID

	If m.lnHotKeyID # 0
		lcPrompt = 'New Popup Menu accessed by ' + GetHotKeyDesc(m.lnHotKeyID) + ccCR + ccCR + 'Use this hot key?'
		If Messagebox(m.lcPrompt, 3 + 32) = 6
			Return
		Endif
	Endif

	lcPrompt = 'Default hot key (' + GetHotKeyDesc(m.lnDefaultHotKeyID) + ') already in use'	;
		+ ccCR + ccCR + 'Assign hot key to access the new Popup Menu?'
	If Messagebox(m.lcPrompt, 3 + 32) = 6
		lcThorAPP	 = _Screen.cThorFolder + '..\Thor.app'
		loForm		 = Newobject ('SetHotKeyForm',	'Thor_UI.vcx', 	m.lcThorAPP)
		loForm.oThor = Newobject ('Thor_Engine',	'Thor.vcx', 	m.lcThorAPP, _Screen.cThorFolder)

		m.loForm.ExecuteCommand (m.lcAlias, 'Set')
	Endif

Endproc


Procedure GetHotKeyDesc(lnHotKeyID)
	Local laHotKey[1]

	Select  Descript					;
		From HotKeyDefinitions			;
		Where Id = m.lnHotKeyID			;
		Into Array laHotKey
	Return Trim(Evl(m.laHotKey, ''))
Endproc


* ================================================================================
* ================================================================================
Procedure RefreshThor
	Local loThor As 'clsRunThor'

	Wait 'Refreshing Thor' Window At 30, 30 Nowait
	loThor = Newobject('clsRunThor')
	m.loThor.Run()
	Wait Clear
Endproc


Define Class clsRunThor As Session

	Procedure Run
		Local loRunThor As 'Thor_Run' Of 'thor_run.vcx'
		Local lcApp, lcFolder, lcThorFolder

		lcThorFolder  = _Screen.cThorFolder + '..\'

		lcApp	  = m.lcThorFolder + 'Thor.App'
		lcFolder  = m.lcThorFolder + 'Thor\'
		loRunThor = Newobject ('Thor_Run', 'thor_run.vcx', m.lcApp, m.lcApp, m.lcFolder)
		m.loRunThor.AddProperty('cApplication', m.lcApp)
		m.loRunThor.Run(.T.) && but no startups
	Endproc

	Procedure Destroy
		Close Tables
	Endproc

Enddefine


* ================================================================================
* ================================================================================
Procedure OpenSourceTables(lcDestFolder)
	UseIfNotOpen (m.lcDestFolder + 'SWFSessionMenuDefinitions')
	UseIfNotOpen (m.lcDestFolder + 'SWFSessionMenuTools')
	UseIfNotOpen (m.lcDestFolder + 'SWFSessionToolHotKeyAssignments')
Endproc

Procedure UseIfNotOpen (lcFileName)
	If Used(m.lcFileName)
		Return
	Endif
	Use (m.lcFileName) Again Shared In 0
Endproc


