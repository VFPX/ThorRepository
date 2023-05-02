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
		.Prompt		   = 'Install Thor Quick Menu'

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
	loCloseTempFiles = m.loThorUtils.CloseTempFiles()

	m.loThorUtils.OpenThorTables()

	lcDestFolder = _Screen.cThorFolder + 'Tools\Procs\'
	OpenSourceTables(m.lcDestFolder)

	If ReadyToInstall()

		UpdateMenuDefinitions()

		UpdateMenuTools()

		UpdateHotKeyAssignments()

		AssignAccessMethods()
		
		loCloseTempFiles = Null

		m.loThorUtils.CleanUpThorTables()

		RefreshThor()

		Messagebox('Thor Quick Menu installed', 64, 'Quick Menu installed', 5000)

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
		lcPrompt = 'Ready to install Thor Quick Menu?'
	Else
		lcPrompt = 'Thor Quick Menu has already been installed.' + ccCR + ccCR + 'Re-install it?'
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

	Local lcPrompt

	Text To m.lcPrompt Noshow Textmerge
Accept default Quick Menu hot key assignments?

This will NOT affect any hot key assignments you already have in place!

1) No tool that is already accessible by hot key will be changed.
2) No hot key already in use will be re-assigned.

	Endtext

	If Messagebox(m.lcPrompt, 3 + 32) # 6
		Return
	Endif

	Select  HotKeyID					;
		From ToolHotKeyAssignments		;
		Where HotKeyID # 0				;
	Union All							;
	Select  HotKeyID					;
		From MenuDefinitions			;
		Where HotKeyID # 0				;
		Into Cursor HotKeysInUse

	* pop up menus
	Update  MenuDefinitions											;
		Set MenuDefinitions.HotKeyID = NewMenuDefs.HotKeyID			;
		From MenuDefinitions										;
			Join NewMenuDefs										;
				On MenuDefinitions.Id = NewMenuDefs.NewMenuID		;
				And NewMenuDefs.HotKeyID # 0						;
		Where Not NewMenuDefs.HotKeyID In (Select  HotKeyID			;
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


* ================================================================================
* ================================================================================
Procedure AssignAccessMethods
	Text To m.lcPrompt Noshow Textmerge
The Thor Quick Menu can be accessed in either (or both) of these ways:

1) By assigning a hot key (creating a popup menu).
2) By adding it to the VFP system menu.

The prompts that follow will help you set this up.
	Endtext

	Messagebox(lcPrompt, 64)

	AssignPopupHotKey()

	AddToSystemMenu()

Endproc


Procedure AssignPopupHotKey

	Local loForm As 'SetHotKeyForm' Of 'Thor_UI.vcx'
	Local laHotKey[1], lcAlias, lcPrompt, lcThorAPP, lnDefaultHotKeyID, lnHotKeyID

	lcAlias = 'MenuDefinitions'
	Select (m.lcAlias)

	Locate For Id = 84
	lnDefaultHotKeyID = HotKeyID

	Locate For Popupname = 'SWF_Top'
	lnHotKeyID = HotKeyID

	If m.lnHotKeyID # 0
		lcPrompt = 'Thor Quick Menu accessed by ' + GetHotKeyDesc(m.lnHotKeyID)				;
			+ Iif(m.lnDefaultHotKeyID = m.lnHotKeyID, ' (assigned by default)', '')			;
			+ ccCR + ccCR + 'Use this hot key?'
		If Messagebox(m.lcPrompt, 3 + 32) = 6
			Return
		Endif
	Endif

	lcPrompt = 'Assign hot key to access the Thor Quick Menu?'
	If Messagebox(m.lcPrompt, 3 + 32) = 6
		lcThorAPP	 = _Screen.cThorFolder + '..\Thor.app'
		loForm		 = Newobject ('SetHotKeyForm',	'Thor_UI.vcx', 	m.lcThorAPP)
		loForm.oThor = Newobject ('Thor_Engine',	'Thor.vcx', 	m.lcThorAPP, _Screen.cThorFolder)

		m.loForm.ExecuteCommand (m.lcAlias, 'Set')
	Endif

Endproc


Procedure AddToSystemMenu
	Local lcAlias, lcPrompt, lnMax

	lcAlias = 'MenuDefinitions'
	Select (m.lcAlias)
	Calculate Max(SortOrder) To m.lnMax For TopLevel

	Locate For Popupname = 'SWF_Top'

	lcPrompt = 'Add Thor Quick Menu to VFP system menu?'
	If Messagebox(m.lcPrompt, 3 + 32) = 6
		Replace TopLevel With .T., SortOrder With m.lnMax + 1
	Else
		Replace TopLevel With .F., SortOrder With 0
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


