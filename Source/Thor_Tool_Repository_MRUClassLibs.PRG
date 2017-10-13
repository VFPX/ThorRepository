#Define MaxFilesToShow 20
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
		.Prompt		 = 'MRU class libraries' && used when tool appears in a menu
		.Description = 'Popup menu of MRU class libraries' && may be lengthy, including CRs, etc

		* For public tools, such as PEM Editor, etc.
		.Source			 = 'Thor Repository'
		.Category		 = 'Favorites, MRUs, etc'
		.Sort			 = 220
		.Author			 = 'Jim Nelson'
		.CanRunAtStartUp = .F.
	Endwith

	Return lxParam1
Endif


Do ToolCode

Return


****************************************************************
****************************************************************
* Normal processing for this tool begins here.                  
Procedure ToolCode

	* see	http://vfpx.codeplex.com/wikipage?title=Thor%20Tools%20Object
	Local loMenuItem As 'Empty'
	Local laMenuItems[1], lcClassLibName, lcDisplayName, lcFName, lnI, loContextMenu, loMRUItems
	Local loPEME_Tools
	loPEME_Tools = Execscript (_Screen.cThorDispatcher, 'class= tools from pemeditor')

	loMRUItems = loPEME_Tools.GetMRUList ('MRU2')
	If loMRUItems.Count = 0
		Messagebox ('No MRU class libraries found')
		Return
	Endif

	loContextMenu = Execscript (_Screen.cThorDispatcher, 'class= contextmenu')

	For lnI = 1 To Min(loMRUItems.Count, MaxFilesToShow)
		lcClassLibName = loPEME_Tools.DiskFileName (loMRUItems[lnI])
		lcDisplayName  = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_RelativePath', lcClassLibName)
		lcFName		   = Justfname (lcDisplayName)
		If Len(lcFName) < Len(lcDisplayName) 
			lcDisplayName = lcFName + '    from ' + Justpath (lcDisplayName)
		Endif

		loMenuItem = Createobject('Empty')
		AddProperty(loMenuItem, 'FName', lcFName)
		AddProperty(loMenuItem, 'DisplayName', lcDisplayName)
		AddProperty(loMenuItem, 'ClassLibName', lcClassLibName)
		Dimension laMenuItems[lnI, 2]
		laMenuItems[lnI, 1]	= lcFName + ' ' + lcClassLibName
		laMenuItems[lnI, 2]	= loMenuItem
	Endfor

	Asort(laMenuItems, 1, -1, 0, 1)

	For lnI = 1 To Alen(laMenuItems, 1)
		loMenuItem = laMenuItems[lnI, 2]
		loContextMenu.AddMenuItem (loMenuItem.DisplayName, , , , loMenuItem.ClassLibName)
	Endfor

	If loContextMenu.Activate()
		lcClassLibName	= loContextMenu.KeyWord
		loPEME_Tools.EditSourceX (lcClassLibName)
	Endif
Endproc
