Lparameters lcDestAlias, llExcludeNotUsed

Local loObject As 'ThorTools'
Local loCloseTemps

loObject = Createobject('ThorTools')
m.loObject.Run(m.lcDestAlias, m.llExcludeNotUsed)
loCloseTemps  = Null

Endproc



Define Class ThorTools As Custom

	cDestAlias = ''
	oThorUtils = Null


	Procedure Run(lcDestAlias, llExcludeNotUsed)

		Local loCloseTemps

		This.oThorUtils  = Execscript (_Screen.cThorDispatcher, 'Thor_Proc_Utils')

		With  This.oThorUtils
			loCloseTemps = .CloseTempFiles(m.lcDestAlias)
			This.oThorUtils.OpenThorTables()
		Endwith &&  This.oThorUtils

		This.cDestAlias = m.lcDestAlias

		This.CreateResultCursor()

		This.AddSystemMenuItems()

		This.AddPopupMenus()

		This.AddToolBarItems()

		This.AddMissingHotKeys()

		This.AddHotKeys()

		This.AddOnKeyLabel()

		This.AddMacros()

		This.UpdateFavorites()

		This.UpdateStartUp()

		This.AddNotUsed(m.llExcludeNotUsed)

		This.UpdateType()

		*** JRN 2022-10-15 : KONG special
		Replace All MenuHotKey With Strtran(MenuHotKey, 'Alt+K', 'Ctrl+K') In (This.cDestAlias)

	Endproc



	* ================================================================================
	* ================================================================================

	Procedure CreateResultCursor
		Create Cursor (This.cDestAlias) (		;
			  Id			I,					;
			  Source 		C(60),				;
			  Type			C(20),				;
			  PRGName  		C(80),				;
			  Descript 		C(100),				;
			  HotKey 		C(20),				;
			  MenuHotKey	C(20),				;
			  nKeyCode 		I,					;
			  NShifts 		I,					;
			  Favorite 		L,					;
			  StartUp 		L,					;
			  StatusBar		C(100),				;
			  Timestamp	    T,					;
			  Category		C(100),				;
			  Link			C(200),				;
			  VideoLink		C(200),				;
			  OptionTool    C(40),				;
			  PlugIns		M,					;
			  ToolPrompt	M,					;
			  ToolDescription M,				;
			  Project		C(30),				;
			  FolderName	M)
	Endproc


	* ================================================================================
	* ================================================================================

	Procedure AddSystemMenuItems
		Local lcHotKey
		Select  *									;
			From MenuDefinitions					;
			Where TopLevel							;
				And Atc('Thor', PopupName) # 1		;
				And Not Internal					;
			Order By SortOrder						;
			Into Cursor MenuItems

		Scan
			lcHotKey = This.GetHotKey(Prompt)
			This.AddMenuItems(MenuItems.Id, Iif(Popup, 'Popup: ', 'SysMenu: ') + MenuItems.Prompt, Iif(Empty(m.lcHotKey), '', 'Alt+' + m.lcHotKey))
		Endscan

	Endproc


	Procedure AddMenuItems(lnMenuID, lcMenuPrompt, lcParentHotKey)
		Local laHotKeyDesc[1], laHotKeyID[1], laMenuItems[1], lcHotKey, lcNewHotkey, lcPRGName, lcPrompt
		Local lcStatusBar, llSeparator, lnI, lnID, lnSubMenuID

		Select  Separator,									;
				SubMenuID,									;
				Prompt,										;
				PRGName,									;
				Cast(StatusBar As M)    As  StatusBar,		;
				Id											;
			From MenuTools									;
			Where MenuID = m.lnMenuID						;
				And Separator = .F.							;
			Order By SortOrder								;
			Into Array laMenuItems

		For lnI = 1 To _Tally

			llSeparator	= m.laMenuItems[m.lnI, 1]
			lnSubMenuID	= m.laMenuItems[m.lnI, 2]
			lcPrompt	= m.laMenuItems[m.lnI, 3]
			lcPRGName	= m.laMenuItems[m.lnI, 4]
			lcStatusBar	= m.laMenuItems[m.lnI, 5]
			lnID		= m.laMenuItems[m.lnI, 6]

			lcHotKey = This.GetHotKey(m.lcPrompt)
			If (Not Empty(m.lcParentHotKey)) And (Not Empty(m.lcHotKey))
				lcNewHotkey = Trim(m.lcParentHotKey) + ', ' + m.lcHotKey
			Else
				lcNewHotkey = Trim(m.lcParentHotKey) + ' Menu'
			Endif

			Do Case
				Case m.llSeparator = .T. && Separator ... actually, this never happens (see Separator = .F. above)
					Insert Into (This.cDestAlias) (Descript) Values (Replicate('-', 20))
				Case m.lnSubMenuID # 0 && SubMenu
					This.AddMenuItems(m.lnSubMenuID, Trim(m.lcMenuPrompt) + ' => ' + m.lcPrompt, m.lcNewHotkey)
				Otherwise
					Insert Into (This.cDestAlias)											;
						(Source, Descript, PRGName, StatusBar, Id, HotKey, MenuHotKey)		;
						Values																;
						(Trim(m.lcMenuPrompt), m.lcPrompt, Forceext(m.lcPRGName, 'prg'), m.lcStatusBar, m.lnID, Iif(Len(m.lcHotKey) > 1, m.lcHotKey, ''), m.lcNewHotkey)
			Endcase
		Endfor

	Endproc


	* ================================================================================
	* ================================================================================

	Procedure AddToolBarItems

		Insert Into (This.cDestAlias)					;
			(Source, PRGName, Descript, StatusBar)		;
			Select  Padr('Toolbar', 60),				;
					PRGName,							;
					Caption,							;
					Trim(ToolTip)						;
				From ToolBarTools						;
				Where Enabled							;
				Order By Caption

	Endproc


	Procedure AddHotKeys
		Update  Result																		;
			Set HotKey = Nvl(HotKeyDefinitions.Descript, ''),								;
				nKeyCode = Nvl(HotKeyDefinitions.nKeyCode, 999),							;
				NShifts = Nvl(HotKeyDefinitions.NShifts, 0)									;
			From (This.cDestAlias)    As  Result											;
				Join ToolHotKeyAssignments													;
					On Upper(Result.PRGName) = Upper(ToolHotKeyAssignments.PRGName)			;
				Join HotKeyDefinitions														;
					On ToolHotKeyAssignments.HotKeyID = HotKeyDefinitions.Id
		
		Replace All														;
				HotKey	  With	Chrtran(Nvl(HotKey, ''), '-', '+')		;
				Descript  With	Strtran(Descript, '\<', '')				;
				Source	  With	Strtran(Source, '\<', '')				;
				PRGName	  With	Lower(PRGName)							;
			In (This.cDestAlias)

	Endproc


	Procedure AddPopupMenus
		Local loPopup

		Select  MenuDefinitions.Id,												;
				MenuDefinitions.Prompt,											;
				'Popup Menu'                                As  Source,			;
				Padr(Trim(Prompt) + ' [Popup Menu]', 60)    As  Descript,		;
				HotKeyDefinitions.Descript                  As  HotKey,			;
				HotKeyDefinitions.nKeyCode,										;
				HotKeyDefinitions.NShifts										;
			From MenuDefinitions												;
				Join HotKeyDefinitions											;
					On MenuDefinitions.HotKeyID = HotKeyDefinitions.Id			;
			Order By NShifts,													;
				Descript														;
			Into Cursor PopupMenus Readwrite
		Scan
			Scatter Name m.loPopup
			Select (This.cDestAlias)
			Append Blank
			Gather Name m.loPopup

			This.AddMenuItems(m.loPopup.Id, 'Popup: ' + m.loPopup.Prompt, Chrtran(m.loPopup.HotKey, '-', '+'))

		Endscan

	Endproc


	Procedure AddMissingHotKeys
		Insert Into (This.cDestAlias)															;
			(Source, Descript, PRGName)															;
			Select  'Hot Key'                                 As  Source,						;
					Padr(This.GetToolPrompt(PRGName), 100)    As  Descript,						;
					Forceext(PRGName, 'prg')                  As  PRGName						;
				From ToolHotKeyAssignments														;
				Where HotKeyID # 0																;
					And Not Lower(Forceext(ToolHotKeyAssignments.PRGName, 'prg')) In (Select  Lower(PRGName) ;
																						  From (This.cDestAlias))
	Endproc


	Procedure GetToolPrompt(lcPRGName)
		Local lcResult, loException, loThorInfo
		lcResult   = Trim(m.lcPRGName)
		Try
			loThorInfo = Execscript(_Screen.cThorDispatcher, 'ToolInfo=', m.lcResult)
			lcResult   = m.loThorInfo.Prompt
		Catch To m.loException

		Endtry
		Return m.lcResult
	Endproc


	Procedure GetHotKey(lcPrompt)
		Local lnPos
		lnPos = At('\<', m.lcPrompt)
		If m.lnPos > 0
			Return Upper(Substr(m.lcPrompt, 2 + m.lnPos, 1))
		Else
			Return ''
		Endif
	Endproc


	Procedure UpdateFavorites
		Update  Result Set Favorite = .T.														;
			From (This.cDestAlias)    As  Result												;
				Join Favorites																	;
					On Upper(Favorites.PRGName) = Upper(Evl(Result.PRGName, Result.HotKey))		;
					And Favorites.StartUp
	Endproc


	Procedure UpdateStartUp
		Update  Result Set StartUp = .T.														;
			From (This.cDestAlias)    As  Result												;
				Join StartupTools																;
					On Upper(StartupTools.PRGName) = Upper(Evl(Result.PRGName, Result.HotKey))	;
					And StartupTools.StartUp
	Endproc


	Procedure AddOnKeyLabel()
		Local laHotKeys[1], lcExec, lcHotKeyText, lcKey, lcStatus, lcTempFile, lnI, lnKeyCode, lnKeyCount
		Local lnShifts

		lcTempFile = Sys(2023) + '\' + Sys(2015) + '.dbf'
		Display Status To File (m.lcTempFile) Noconsole
		lcStatus = Filetostr(m.lcTempFile)
		Delete File (m.lcTempFile)

		lcHotKeyText = Strextract(m.lcStatus, 'ON KEY LABEL hot keys:', 'Textmerge Options', 1, 3)
		lnKeyCount	 = Alines(laHotKeys, m.lcHotKeyText)
		For lnI = 2 To m.lnKeyCount - 1
			lcKey  = Trim(Left(m.laHotKeys[m.lnI], 20))
			lcExec = Substr(m.laHotKeys[m.lnI], 21)
			Do Case
				Case m.lcExec = 'ExecScript' And ',' $ m.lcExec
					*	'Skipping ' + m.lcKey
				Case m.lcExec = '.'
					*	'Skipping ' + m.lcKey
				Otherwise
					If m.lcExec = 'Execscript'
						lcExec = 'Open Thor UI'
					Endif
					lcKey	  = Strtran(m.lcKey, 'CTRL', 'Ctrl', 1, 1, 1)
					lcKey	  = Strtran(m.lcKey, 'ALT', 'Alt', 1, 1, 1)
					lcKey	  = Strtran(m.lcKey, 'ENTER', 'Enter', 1, 1, 1)
					lnKeyCode = Val(Substr(m.lcKey, 2 + At('+F', m.lcKey)))
					lnShifts  = Icase('Ctrl' $ m.lcKey, 2, 'Alt' $ m.lcKey, 4, 0)
					Insert Into (This.cDestAlias)							;
						(Source, Descript, HotKey, nKeyCode, NShifts)		;
						Values												;
						('On Key Label', m.lcExec + ' [On Key Label]', m.lcKey, 111 + m.lnKeyCode, m.lnShifts)
			Endcase
		Endfor

	Endproc


	Procedure AddMacros
		Local loThorEngine As 'thor_engine' Of 'thor.vcx'
		Local laKeyCode[2], lcThorAPP, lnKeyCode, lnShifts, loMacro, loMacros

		lcThorAPP	 = _Screen.cThorFolder + '..\Thor.app'
		loThorEngine =  Newobject ('thor_engine', 'thor.vcx', m.lcThorAPP, _Screen.cThorFolder)
		loMacros	 = m.loThorEngine.GetMacroDefinitions ()
		For Each m.loMacro In m.loMacros FoxObject
			If Lower (m.loMacro.Name) # 'thor:'
				Select  nKeyCode,												;
						NShifts													;
					From HotKeyDefinitions										;
					Where Upper(Descript) = Upper(m.loMacro.Definition)			;
					Into Array laKeyCode
				If _Tally > 0
					lnKeyCode = Evl(m.laKeyCode[1], 0)
					lnShifts  = Evl(m.laKeyCode[2], 0)
				Else
					lnKeyCode = 0
					lnShifts  = 0
				Endif

				Insert Into (This.cDestAlias)													;
					(Source, Descript, HotKey, StatusBar,										;
					  nKeyCode, NShifts)														;
					Values																		;
					('Macro', m.loMacro.Name + ' [Macro]', m.loMacro.Definition, m.loMacro.Keystrokes, ;
					  M.lnKeyCode, m.lnShifts)
			Endif
		Endfor
	Endproc


	Procedure AddNotUsed(llExcludeNotUsed)
		Local lcCategory, lcToolFolder, lcType, loThor, loTool, loTools

		loThor		 = Execscript(_Screen.cThorDispatcher, 'Thor Engine=')
		lcToolFolder = Execscript(_Screen.cThorDispatcher, 'Tool Folder=')
		loTools		 = m.loThor.GetToolsCollection(Addbs(m.lcToolFolder))

		Select (This.cDestAlias)
		For Each m.loTool In m.loTools
			With m.loTool
				lcCategory = Strtran(.Category, '|', ' => ')
				If Empty(.AppID) And Atc('gofish', .FolderName) # 0
					.AppID = 'GoFish'
				Endif

				Replace	Category		 With  m.lcCategory,				;
						Link			 With  .Link,						;
						VideoLink		 With  .VideoLink,					;
						OptionTool		 With  Evl(.OptionTool, '')			;
						PlugIns			 With  Evl(.PlugIns, '')			;
						ToolPrompt		 With  Evl(.Prompt, '')				;
						ToolDescription	 With  Evl(.Description, '')		;
						FolderName		 With  Evl(.FolderName, '')			;
						Project			 With  Evl(.AppID, '')				;
					For Upper(PRGName) = Upper(.PRGName)

				If _Tally = 0 And Not m.llExcludeNotUsed
					lcType = Icase(.PrivateCopy = 0, '', .PrivateCopy = -1, 'Custom', .PrivateCopy = 1, 'Private', '')
					lcType = m.lcType + Iif(.PrivateCopy # 0 And Atc('My Tools', .FullFileName) = 0, ' (Path)', '')
					Insert Into (This.cDestAlias)												;
						(PRGName, Descript, StatusBar, Type, Category, Link,					;
						  VideoLink, OptionTool, PlugIns, ToolPrompt, ToolDescription, FolderName, Project) ;
						Values																	;
						(.PRGName, .Prompt, .Description, m.lcType, m.lcCategory, .Link,		;
						  .VideoLink, Evl(.OptionTool, ''), Evl(.PlugIns, ''), Evl(.Prompt, ''), Evl(.Description, ''), Evl(.FolderName, ''), Evl(.AppID, ''))
				Endif
			Endwith && loTool
		Endfor
	Endproc


	Procedure UpdateType

		This.oThorUtils.ADirCursor(_Screen.cThorFolder + 'Tools\*.prg', 'ThorTools')
		Update  Result																			;
			Set Timestamp =  Iif(Isnull(ThorTools.FileName), {}, ThorTools.Datetime)			;
			From (This.cDestAlias)    As  Result												;
				Join ThorTools																	;
					On Upper(Padr(Result.PRGName, 80)) = Upper(Padr(ThorTools.FileName, 80))	;
			Where (Not Empty(PRGName))

		This.oThorUtils.ADirCursor(_Screen.cThorFolder + 'Tools\My Tools\*.prg', 'MyThorTools')
		Update  Result																			;
			Set Type = Iif(Empty(Timestamp), 'Private (My Tools)', 'Custom (My Tools)'),		;
				Timestamp =  MyThorTools.Datetime												;
			From (This.cDestAlias)    As  Result												;
				Join MyThorTools																;
					On Upper(Padr(Result.PRGName, 80)) = Upper(Padr(MyThorTools.FileName, 80))	;
			Where Not Empty(PRGName)

		Replace All																				;
				Type	   With	 Icase(Type = 'Private' Or Empty(Timestamp), 'Private (In Path)', 'Custom (In Path)'), ;
				Timestamp  With	 Fdate(Trim(PRGName), 1)										;
			In (This.cDestAlias)																;
			For Not Empty(PRGName) And File(Trim(PRGName))

	Endproc

Enddefine

