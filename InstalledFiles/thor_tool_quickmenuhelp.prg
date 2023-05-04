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

	Local laMenuid[1], lcContextMenuFileName, lcLink, lcResult, loContextMenu, loThorUtils, loToolInfo

	lcContextMenuFileName = Execscript(_Screen.cThorDispatcher, 'Full Path= Thor_Proc_Contextmenu.vcx')
	loContextMenu		  = Newobject ('ContextMenu', m.lcContextMenuFileName)

	* ================================================================================
	* Open Thor tables
	loThorUtils = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_Utils')
	m.loThorUtils.CloseTempFiles()
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
		lcResult   = m.loContextMenu.Parameters
		loToolInfo = Execscript(_Screen.cThorDispatcher, 'ToolInfo=', m.lcResult)
		
		lcLink	   = GetLink(m.loToolInfo.Link, m.lcResult)
		If Not Empty(m.lcLink)
			GoURL(m.lcLink)
		Else
			Messagebox(m.loToolInfo.Description, 0, m.loToolInfo.Prompt)
		Endif

	Endif

Endproc


* ================================================================================
* ================================================================================

Procedure AddMenuItems(loContextMenu, lnMenuID)

	Local laMenuTools[1], lcKeyStroke, lcMenuStatusBar, lcPRGName, lcPrompt, lcStatusBar, llSeparator
	Local lnI, lnSubMenuID

	Select  MenuTools.Prompt,															;
			Separator,																	;
			SubMenuID,																	;
			PRGName,																	;
			MenuTools.StatusBar,														;
			Cast (Nvl (MenuDefinitions.StatusBar, '') As M)   As  MenuStatusBar			;
		From MenuTools																	;
			Left Join MenuDefinitions													;
				On SubMenuID = MenuDefinitions.Id										;
		Where MenuID = m.lnMenuID														;
			And Upper(PRGName) # Upper('thor_tool_quickmenuhelp.prg')					;
		Order By MenuTools.SortOrder													;
		Into Array laMenuTools

	For lnI = 1 To _Tally
		lcPrompt		= Alltrim (m.laMenuTools (m.lnI, 1))
		llSeparator		= m.laMenuTools (m.lnI, 2)
		lnSubMenuID		= m.laMenuTools (m.lnI, 3)
		lcPRGName		= Alltrim (m.laMenuTools (m.lnI, 4))
		lcStatusBar		= Strtran (Left (Alltrim (m.laMenuTools (m.lnI, 5)), 250), ccCRLF, ' ')
		lcMenuStatusBar	= Strtran (Left (Alltrim (m.laMenuTools (m.lnI, 6)), 250), ccCRLF, ' ')

		Do Case
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
				If Indexseek (Upper (m.lcPRGName), .T., 'ToolHotKeyAssignments', 'PrgName') And ToolHotKeyAssignments.HotKeyID # 0
					Indexseek (ToolHotKeyAssignments.HotKeyID, .T., 'HotKeyDefinitions', 'ID')
					lcKeyStroke = Alltrim (HotKeyDefinitions.Descript)
				Else
					lcKeyStroke = ''
				Endif

				m.loContextMenu.AddMenuItem (m.lcPrompt, , m.lcStatusBar, m.lcKeyStroke, , m.lcPRGName, , 'I')
		Endcase
	Endfor

Endproc


Procedure GetLink(lcLink, lcFileName)
	Local lcTemp, lcURLFolder, lcURL, llSuccess

	* Is there a link supplied?
	If Not Empty(m.lcLink)
		If CheckLink(m.lcLink)
			Return m.lcLink
		Endif
	Endif

	* Else is there a md file (with name of tool) in the docs folder for ThorRepository?
	lcURLFolder	= 'https://github.com/VFPX/ThorRepository/blob/master/docs/'
	lcLink		= m.lcURLFolder + Lower(Juststem(m.lcFileName)) + '.md'
	If CheckLink(m.lcLink)
		Return m.lcLink
	Endif

	* Else is there a txt file containing a link?
	lcURLFolder	= 'https://raw.githubusercontent.com/VFPX/ThorRepository/master/docs/'
	lcLink		= m.lcURLFolder + Lower(Juststem(m.lcFileName)) + '.txt'
	lcTemp		= Addbs(Sys(2023)) + Sys(2015)
	llSuccess	= Execscript (_Screen.cThorDispatcher, 'Thor_Proc_DownloadFileFromURL', m.lcLink, m.lcTemp)

	If m.llSuccess
		lcURL = Alltrim(Getwordnum(Filetostr(m.lcTemp), 2, '='), ' ', Chr[13], Chr[10], Chr[9])
		If Not Empty(m.lcURL)
			Return m.lcURL
		Endif
	Endif
	Return ''

Endproc


Procedure CheckLink(lcLink)
	Local lcDownloaded, lcTemp, lcTitle, llSuccess

	lcTemp	  = Addbs(Sys(2023)) + Sys(2015)
	llSuccess = Execscript (_Screen.cThorDispatcher, 'Thor_Proc_DownloadFileFromURL', m.lcLink, m.lcTemp)
	Wait Clear
	If m.llSuccess
		lcDownloaded = Filetostr(m.lcTemp)
		Erase (m.lcTemp)
		lcTitle = Strextract(m.lcDownloaded, '<title>', '</title>', 1, 1)
		If Atc('page not found', m.lcDownloaded) # 0
			llSuccess = .F.
		Endif
	Endif

	Return m.llSuccess
Endproc

