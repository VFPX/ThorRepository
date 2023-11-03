#Define ccHelpURL 'https://github.com/VFPX/ThorNews/blob/main/NewsItems/Item_52.md'
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
		.Prompt	= 'Install Quick Access Menu'
		.AppID	= 'ThorRepository'

		.Description =  'See ' + ccHelpURL
		.Link		 = 'https://github.com/VFPX/ThorNews/blob/main/NewsItems/Item_52.md'

		.Category = 'Miscellaneous'

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

	Local lcBackupFolder, lcDestFolder, lcHotKeyDesc, lcInstallType, loCloseTempFiles, loThorUtils

	* when loCloseTempFiles goes out of scope, it closes any newly opened tables
	loThorUtils		 = Execscript(_Screen.cThorDispatcher, 'thor_proc_utils')
	loCloseTempFiles = m.loThorUtils.CloseTempFiles()
	m.loThorUtils.OpenThorTables()

	* and open all Thor's tables
	lcDestFolder = _Screen.cThorFolder + 'Tools\Procs\'
	OpenSourceTables(m.lcDestFolder)

	If ReviewDocumentation() = .F. && Cancelled
		Return
	Endif

	lcInstallType = ReadyToInstall()

	If lcInstallType = 'Cancel'
		Return
	Endif

	lcBackupFolder = m.loThorUtils.BackupThorTables()

	ReadHotKeysInUse()

	UpdateHotKeyDefinitions()

	If m.lcInstallType = 'Install'

		UpdateMenuDefinitions()

		UpdateMenuTools()

		AddToSystemMenu()

	Endif

	UpdateHotKeyAssignments()

	ReadHotKeysInUse()

	lcHotKeyDesc = AssignPopupHotKey()

	loCloseTempFiles = Null

	AllDone(m.lcBackupFolder, m.lcHotKeyDesc)

Endproc


Procedure ReviewDocumentation
	Local lcPrompt, lcResponse, lcURL, loThorUtils

	* ================================================================================ 
	lcPrompt   = 'Review Quick Access Menu documentation before installing?'
	lcResponse = Execscript(_Screen.cThorDispatcher, 'THOR_Proc_MessageBox', m.lcPrompt, 3)

	Do Case
		Case m.lcResponse = 'Y'
			lcURL		= ccHelpURL
			loThorUtils	= Execscript(_Screen.cThorDispatcher, 'thor_proc_utils')
			m.loThorUtils.GoURL(m.lcURL)
			Return .T.
		Case m.lcResponse = 'N'
			Return .T.

		Otherwise
			Return .F.
	Endcase
Endproc


Procedure ReadyToInstall

	Local lcCaptions, lcPrompt, lcResponse

	* ================================================================================

	Select  New.*,														;
			Cast(Nvl(Current.Id, 0) As I)    As  NewMenuID				;
		From SWFSessionMenuDefinitions       As  New					;
			Join MenuDefinitions             As  Current				;
				On Upper(New.PopupName) = Upper(Current.PopupName)		;
		Into Cursor NewMenuDefs Readwrite

	If _Tally = 0
		lcPrompt   = 'Ready to install Quick Access Menu?'
		lcResponse = Execscript(_Screen.cThorDispatcher, 'THOR_Proc_MessageBox', m.lcPrompt, 3)
		Return Iif(m.lcResponse = 'Y', 'Install', 'Cancel')
	Else
		lcPrompt   = 'Quick Access Menu has already been installed.'
		lcCaptions = [Full re-install == 'Install';Hot Keys Only == 'Hot Keys';|^Cancel == 'Cancel']
		lcResponse = Execscript(_Screen.cThorDispatcher, 'THOR_Proc_MessageBox', m.lcPrompt, m.lcCaptions)
		Return lcResponse
	Endif

Endproc


* ================================================================================
* ================================================================================
Procedure ReadHotKeysInUse
	Select  HotKeyID						;
		From ToolHotKeyAssignments			;
		Where HotKeyID # 0					;
	Union All								;
	Select  HotKeyID						;
		From MenuDefinitions				;
		Where HotKeyID # 0					;
			And PopupName # 'SWF_Top'		;
		Into Cursor HotKeysInUse
Endproc


* ================================================================================
* ================================================================================
Procedure UpdateHotKeyDefinitions

	Select  *											;
		From SWFSessionHotKeyDefinitions				;
		Where Not (100 * nKeyCode + NShifts)			;
			In (Select  100 * nKeyCode + NShifts		;
					From HotKeyDefinitions)				;
		Into Cursor NewHotKeyDefs

	Insert Into HotKeyDefinitions						;
		(nKeyCode, NShifts, Descript, FKYValue)			;
		Select  nKeyCode,								;
				NShifts,								;
				Descript,								;
				FKYValue								;
			From NewHotKeyDefs

	Select  NewHotKeyDefs.*,															;
			HotKeyDefinitions.Id    As  NewHotKeyID										;
		From NewHotKeyDefs																;
			Join HotKeyDefinitions On													;
				(100 * NewHotKeyDefs.nKeyCode + NewHotKeyDefs.NShifts)					;
				= (100 * HotKeyDefinitions.nKeyCode + HotKeyDefinitions.NShifts)		;
		Into Cursor MapHotKeyIDs

Endproc


* ================================================================================
* ================================================================================
* ================================================================================
* ================================================================================

Procedure UpdateMenuDefinitions
	Local lnNewID, loMenuDef

	Select  New.*,														;
			Cast(Nvl(Current.Id, 0) As I)    As  NewMenuID				;
		From SWFSessionMenuDefinitions       As  New					;
			Left Join MenuDefinitions        As  Current				;
				On Upper(New.PopupName) = Upper(Current.PopupName)		;
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

	* menus
	Update  Current														;
		Set HotKeyID = MapHotKeyIDs.NewHotKeyID							;
		From SWFSessionMenuDefinitions    As  New						;
			Join MenuDefinitions          As  Current					;
				On Upper(New.PopupName) = Upper(Current.PopupName)		;
				And Current.HotKeyID = 0								;
			Join MapHotKeyIDs											;
				On New.HotKeyID = Evl(MapHotKeyIDs.Id, -1)

	* tools
	Insert Into ToolHotKeyAssignments (PRGName)							;
		Select  PRGName													;
			From  SWFSessionToolHotKeyAssignments						;
			Where Not PRGName In (Select  PRGName						;
									  From ToolHotKeyAssignments)		

	Update  Current														;
		Set HotKeyID = MapHotKeyIDs.NewHotKeyID							;
		From SWFSessionToolHotKeyAssignments As  New						;
			Join ToolHotKeyAssignments As  Current					;
				On Upper(New.PrgName) = Upper(Current.PrgName)		;
				And Current.HotKeyID = 0								;
			Join MapHotKeyIDs											;
				On New.HotKeyID = Evl(MapHotKeyIDs.Id, -1)

Endproc


* ================================================================================
* ================================================================================


Procedure AssignPopupHotKey

	Local lcAlias

	Select  *											;
		From HotKeyDefinitions							;
		Where Not Id In (Select  HotKeyID				;
							 From HotKeysInUse)			;
		Into Cursor HotKeysAvailable

	Select  Main.*,											;
			HKA.Id                   As  MainHotKey			;
		From SWFSESSIONMainHotKey    As  Main				;
			Join HotKeysAvailable    As  HKA				;
				On 100 * Main.nKeyCode + Main.NShifts		;
				=  100 * HKA.nKeyCode  + HKA.NShifts		;
		Order By Main.Order									;
		Into Cursor MainHotKeys Readwrite
	Goto Top

	lcAlias = 'MenuDefinitions'
	Select (m.lcAlias)

	Locate For PopupName = 'SWF_Top'
	Replace HotKeyID With MainHotKeys.MainHotKey
	Return MainHotKeys.Descript

Endproc


Procedure AddToSystemMenu
	Local lcAlias, lcPrompt, lnMax

	lcAlias = 'MenuDefinitions'
	Select (m.lcAlias)
	Calculate Max(SortOrder) To m.lnMax For TopLevel

	Locate For PopupName = 'SWF_Top'

	Replace TopLevel With .T., SortOrder With m.lnMax + 1

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
Procedure OpenSourceTables(lcDestFolder)
	UseIfNotOpen (m.lcDestFolder + 'SWFSessionMenuDefinitions')
	UseIfNotOpen (m.lcDestFolder + 'SWFSessionMenuTools')
	UseIfNotOpen (m.lcDestFolder + 'SWFSessionToolHotKeyAssignments')
	UseIfNotOpen (m.lcDestFolder + 'SWFSessionMainHotKey')
	UseIfNotOpen (m.lcDestFolder + 'SWFSessionHotKeyDefinitions')
Endproc


Procedure UseIfNotOpen (lcFileName)
	If Used(m.lcFileName)
		Return
	Endif
	Use (m.lcFileName) Again Shared In 0
Endproc


* ================================================================================
* ================================================================================
Procedure AllDone(lcBackupFolder, lcHotKeyDesc)

	Local lcBackup, lcDescription, lcFormName

	RefreshThor()

	lcBackup = Strtran(FullPath(m.lcBackupFolder), FullPath(_Screen.cThorFolder), [_Screen.cThorFolder + '], 1, 1, 1) + [']

	Text To m.lcDescription Noshow Textmerge
Quick Access Menu installed.

It is accessible:
    - From the System Menu ("Quick Access")
    - Or by using hot key   <<Evl(m.lcHotKeyDesc, '(Not assigned)')>>.
    
Backup of modified Thor tables saved in
     <<m.lcBackup>>
     
	Endtext

	lcFormName = Execscript(_Screen.cThorDispatcher, 'Full Path=Thor_proc_showtoolhelp.SCX')
	Do Form (m.lcFormName) With 'Quick Access Menu', 'Quick Access Menu', m.lcDescription

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


