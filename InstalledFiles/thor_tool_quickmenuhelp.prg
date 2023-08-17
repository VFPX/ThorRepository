Lparameters lxParam1

#Define CR Chr[13]

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1								;
		And 'O' = Vartype (m.lxParam1)		;
		And 'thorinfo' == Lower (m.lxParam1.Class)

	With m.lxParam1

		* Required
		.Prompt	  = 'Quick Menu Help'
		.AppID 	  = 'ThorRepository'

		.Category = 'Code'
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

	#Define ccCRLF Chr[13] + Chr[10]

	Local laMenuid[1], lcContextMenuFileName, loCloseTables, loContextMenu, loThorUtils

	lcContextMenuFileName = Execscript(_Screen.cThorDispatcher, 'Full Path= Thor_Proc_Contextmenu.vcx')
	loContextMenu		  = Newobject ('ContextMenu', m.lcContextMenuFileName)

	* ================================================================================
	* Open Thor tables
	loThorUtils	  = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_Utils')
	loCloseTables = m.loThorUtils.CloseTempFiles()
	m.loThorUtils.OpenThorTables()

	Select  Id								;
		From MenuDefinitions				;
		Where Popupname = 'SWF_Top'			;
		Into Array laMenuid
	If _Tally = 0
		Return
	Endif

	AddMenuItems (m.loContextMenu, m.laMenuid)

	If m.loContextMenu.Activate()
		Execscript(_Screen.cThorDispatcher, 'Thor_Proc_ProcessContextMenuItem', m.loContextMenu.Parameters, .T.)
	Endif

Endproc


* ================================================================================
* ================================================================================

Procedure AddMenuItems(loContextMenu, lnMenuID)

	Local laMenuTools[1], lcKeyStroke, lcMenuStatusBar, lcPRGName, lcPrompt, lcStatusBar, llFavorite
	Local llSeparator, lnCount, lnI, lnSubMenuID

	Select  MenuTools.Prompt,															;
			Separator,																	;
			SubMenuID,																	;
			MenuTools.PRGName,															;
			MenuTools.StatusBar,														;
			Cast (Nvl (MenuDefinitions.StatusBar, '') As M)   As  MenuStatusBar,		;
			Nvl(Favorites.StartUp, .F.)                       As  Favorite				;
		From MenuTools																	;
			Left Join MenuDefinitions													;
				On SubMenuID = MenuDefinitions.Id										;
			Left Join Favorites															;
				On Lower(MenuTools.PRGName) = Lower(Favorites.PRGName)					;
		Where MenuID = m.lnMenuID														;
			And Upper(MenuTools.PRGName) # Upper('thor_tool_quickmenuhelp.prg')			;
		Order By MenuTools.SortOrder													;
		Into Array laMenuTools

	lnCount = _Tally
	For lnI = 1 To m.lnCount
		lcPrompt		= Alltrim (m.laMenuTools (m.lnI, 1))
		llSeparator		= m.laMenuTools (m.lnI, 2)
		lnSubMenuID		= m.laMenuTools (m.lnI, 3)
		lcPRGName		= Alltrim (m.laMenuTools (m.lnI, 4))
		lcStatusBar		= Strtran (Left (Alltrim (m.laMenuTools (m.lnI, 5)), 250), ccCRLF, ' ')
		lcMenuStatusBar	= Strtran (Left (Alltrim (m.laMenuTools (m.lnI, 6)), 250), ccCRLF, ' ')
		llFavorite		= m.laMenuTools (m.lnI, 7)

		Do Case
			Case m.llSeparator And m.lnI = m.lnCount

			Case m.llSeparator
				m.loContextMenu.AddMenuItem ()

			Case m.lnSubMenuID # 0
				If Indexseek (m.lnSubMenuID, .T., 'MenuDefinitions', 'ID')		;
						And MenuDefinitions.HotKeyID # 0
					Indexseek (MenuDefinitions.HotKeyID, .T., 'HotKeyDefinitions', 'ID')
					lcKeyStroke = Alltrim (HotKeyDefinitions.Descript)
				Else
					lcKeyStroke = ''
				Endif

				m.loContextMenu.AddSubMenu (m.lcPrompt, m.lcMenuStatusBar, m.lcKeyStroke)
				AddMenuItems (m.loContextMenu, m.lnSubMenuID)
				m.loContextMenu.EndSubMenu ()
			Otherwise
				*!* ******** JRN Removed 2023-05-19 ********
				*!* If Indexseek (Upper (m.lcPRGName), .T., 'ToolHotKeyAssignments', 'PrgName') And ToolHotKeyAssignments.HotKeyID # 0
				*!* 	Indexseek (ToolHotKeyAssignments.HotKeyID, .T., 'HotKeyDefinitions', 'ID')
				*!* 	lcKeyStroke = Alltrim (HotKeyDefinitions.Descript)
				*!* Else
					lcKeyStroke = ''
				*!* ******** JRN Removed 2023-05-19 ********
				*!* Endif

				m.loContextMenu.AddMenuItem (m.lcPrompt, , m.lcStatusBar, m.lcKeyStroke, , m.lcPRGName, , Iif(m.llFavorite, 'B', ''))
		Endcase
	Endfor

Endproc

