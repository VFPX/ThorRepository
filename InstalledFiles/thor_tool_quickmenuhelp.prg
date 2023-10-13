Lparameters lxParam1

#Define CR Chr[13]

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

Local lcDescription

If Pcount() = 1								;
		And 'O' = Vartype (m.lxParam1)		;
		And 'thorinfo' == Lower (m.lxParam1.Class)

	With m.lxParam1

		* Required
		.Prompt	= 'Shift+Click any item for help/context menu'
		.AppID	= 'ThorRepository'

		Text To .Description Noshow Textmerge
Thor provides context menus for all items in the Quick Access Menu. Hold down the Shift key while selecting a menu item to get this context menu.

Actually, this works for all items in ANY menu created by Thor, including those in "Thor Tools", any others in the system menu pad, and any custom pop-up menus.
     
		Endtext

		.Link = 'https://github.com/VFPX/ThorNews/blob/main/NewsItems/Item_53.md'

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

	Local lcDescription, lcFormName

	Text To m.lcDescription Noshow Textmerge

Thor provides context menus for all items in the Quick Access Menu. Hold down the Shift key while selecting a menu item to get this context menu.

Actually, this works for all items in ANY menu created by Thor, including those in "Thor Tools", any others in the system menu pad, and any custom pop-up menus.

	Endtext

	lcFormName = Execscript(_Screen.cThorDispatcher, 'Full Path=Thor_proc_showtoolhelp.SCX')
	Do Form (m.lcFormName) With 'thor_tool_quickmenuhelp', 'Hidden Context Menu', m.lcDescription

Endproc

