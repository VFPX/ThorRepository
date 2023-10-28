* Registered with Thor: 10/22/23 10:01:44 AM
Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1										;
		And 'O' = Vartype(m.lxParam1)				;
		And Pemstatus(m.lxParam1, 'Class', 5)		;
		And 'thorinfo' = Lower(m.lxParam1.Class)

	With m.lxParam1

		* Required
		.Prompt             = 'MRUs' && used when tool appears in a menu
		Text To .Description Noshow
Pop-up menu to access MRUs for classes, forms, class libraries, etc..

Full list of MRUs is:
        Classes
        Forms
        PRGs
        Class Libraries
        Projects
        Reports
        Menus
        Other Files

These lists are maintained by anything opened from the command line, by files opened by any of the tool 'Open Files'; from Code References version 1.2; and by files opened within the Project Manager using the ProjectHooks class provided with PEM editor.

The MRU lists are maintained in your resource file.
		Endtext
		.PRGName            = 'Thor_Tool_PEME_OpenMRUS' && a unique name for the tool; note the required prefix

		* Optional
		.StatusBarText	 = 'Pop-up menu to access MRUs for classes, forms, class libraries, etc.'
		.Summary		 = 'Pop-up menu to access MRUs for classes, forms, class libraries, etc.' && if empty, first line of .Description is used
		.AppID			 = 'ThorRepository'
		.CanRunAtStartUp = .F.

		* For public tools, such as PEM Editor, etc.
		.Category = 'Favorites, MRUs, etc'
		.Source	  = 'IDE Tools' && Deprecated; use .Category instead
		.Sort	  = 200 && the sort order for all items from the same .Source
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

	Local loMRUS As 'MRUs'

	loMRUS = Newobject('MRUs')
	m.loMRUS.Run()

Endproc

* ================================================================================
* ================================================================================
* lifted from PEMEditor_Idex
Define Class MRUs As Custom

	oMenu	   = Null
	oThorUtils = ''

	Procedure Init
		This.oMenu		= Execscript(_Screen.cThorDispatcher, 'Class= ContextMenu')
		This.oThorUtils	= Execscript (_Screen.cThorDispatcher, 'Thor_Proc_Utils')
	Endproc


	Procedure Run
		Local lcKeyWord, lcParameters

		This.AddMRUMenus

		If This.oMenu.Activate()
			lcKeyWord	 = This.oMenu.KeyWord
			lcParameters = This.oMenu.Parameters
			This.ProcessOpenMRUMenuItems(m.lcKeyWord, m.lcParameters)
		Endif

	Endproc


	Procedure Delete
		This.oMenu		= Null
		This.oThorUtils	= Null
	Endproc


	Procedure AddMRUMenus

		With This
			.AddVFPMRUs(.oMenu, 'Class \<Libraries', 'MRU2')
			.AddVFPMRUs(.oMenu, '\<Classes', 'VCX')
			.AddVFPMRUs(.oMenu, '\<Forms', 'SCX')
			.AddVFPMRUs(.oMenu, '\<PRGs', 'PRG')

			.oMenu.AddMenuItem()

			.AddVFPMRUs(.oMenu, 'Pro\<Jects', 'PJX')
			.AddVFPMRUs(.oMenu, '\<Reports', 'FRX')
			.AddVFPMRUs(.oMenu, '\<Menus', 'MNX')
			.AddVFPMRUs(.oMenu, '\<Text Files', 'XXX')

		Endwith
	Endproc


	Procedure AddVFPMRUs
		Lparameters loMenu, lcPrompt, lcID

		Local lcClass, lcFileName, lnI, lnPos, loCollection

		If This.oMenu.AddSubMenu(m.lcPrompt)

			loCollection = This.oThorUtils.GetMRUList(m.lcID)
			For lnI = 1 To m.loCollection.Count
				lcFileName = m.loCollection.Item(m.lnI)
				Do Case
					Case Empty(m.lcFileName)
						Loop
					Case m.lcFileName = '\-'
						lcPrompt = '\-'
					Case '|' $ m.lcFileName
						lnPos	   = At('|', m.lcFileName)
						lcClass	   = Substr(m.lcFileName, m.lnPos + 1)
						lcFileName = Left (m.lcFileName, m.lnPos - 1)
						If Not File(m.lcFileName)
							Loop
						Endif
						lcPrompt = This.oThorUtils.GetDisplayRelativePath(m.lcFileName)
						lcPrompt = Lower(Evl(m.lcClass, '?')) + '  of  ' + m.lcPrompt
					Otherwise
						If Not File(m.lcFileName)
							Loop
						Endif
						lcPrompt = This.oThorUtils.GetDisplayRelativePath(m.lcFileName)
						lcClass	 = ''
				Endcase

				This.oMenu.AddMenuItem(m.lcPrompt, , , , 'MRU', m.lcFileName + '|' + Evl(m.lcClass, ' '))

			Endfor
			This.oMenu.EndSubMenu()

		Endif
	Endproc


	Procedure ProcessOpenMRUMenuItems
		Lparameters lcChoice, lxParameters
	
		Local laMRU[1], lcClass, lcFileName, loTools
	
		If m.lcChoice = 'MRU'
			Alines (laMRU, m.lxParameters + ' ', .T., '|')
			lcFileName = m.laMRU(1)
			lcClass	   = Alltrim (m.laMRU(2))
	
			loTools = Execscript (_Screen.cThorDispatcher, 'Class= tools from pemeditor')
			m.loTools.EditSourceX(m.lcFileName, m.lcClass)
		Endif
	
	Endproc
		

Enddefine
