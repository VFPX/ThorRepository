#Define MaxFilesToShow 20
Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1								;
		And 'O' = Vartype (m.lxParam1)		;
		And 'thorinfo' = Lower (m.lxParam1.Class)

	With m.lxParam1

		* Required
		.Prompt		 = 'MRU tables' && used when tool appears in a menu
		.Description = 'Popup menu of MRU tables' && may be lengthy, including CRs, etc

		* For public tools, such as PEM Editor, etc.
		.Source			 = 'Thor Repository'
		.Category		 = 'Favorites, MRUs, etc'
		.Sort			 = 215
		.Author			 = 'Jim Nelson'
		.CanRunAtStartUp = .F.
	Endwith

	Return m.lxParam1
Endif


Do ToolCode

Return


****************************************************************
****************************************************************
* Normal processing for this tool begins here.                  
Procedure ToolCode

	* see	http://vfpx.codeplex.com/wikipage?title=Thor%20Tools%20Object
	Local loMenuItem As 'Empty'
	Local laDir[1], laMenuItems[1], lcDisplayName, lcFName, lcTableName, lnCount, lnI, loContextMenu
	Local loMRUItems, loPEME_Tools
	loPEME_Tools = Execscript (_Screen.cThorDispatcher, 'class= tools from pemeditor')

	loMRUItems = m.loPEME_Tools.GetMRUList ('DBF')
	If m.loMRUItems.Count = 0
		Messagebox ('No MRU tables found')
		Return
	Endif

	loContextMenu = Execscript (_Screen.cThorDispatcher, 'class= contextmenu')
	lnCount		  = 0

	For lnI = 1 To Min(m.loMRUItems.Count, MaxFilesToShow)
		lcTableName = m.loPEME_Tools.DiskFileName (m.loMRUItems[m.lnI])
		If 0 # Adir(laDir, m.lcTableName, '', 1)
			lcTableName	  = Addbs(Justpath(m.lcTableName)) + m.laDir[1, 1]
			lcDisplayName = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_RelativePath', m.lcTableName)
			lcFName		  = Justfname (m.lcDisplayName)
			If Len(m.lcFName) < Len(m.lcDisplayName)
				lcDisplayName = m.lcFName + '    from ' + Justpath (m.lcDisplayName)
			Endif

			loMenuItem = Createobject('Empty')
			AddProperty(m.loMenuItem, 'FName', m.lcFName)
			AddProperty(m.loMenuItem, 'DisplayName', m.lcDisplayName)
			AddProperty(m.loMenuItem, 'ClassLibName', m.lcTableName)
			lnCount = m.lnCount + 1
			Dimension m.laMenuItems[m.lncount, 2]
			laMenuItems[m.lncount, 1] = m.lcFName + ' ' + m.lcTableName
			laMenuItems[m.lncount, 2] = m.loMenuItem
		Endif
	Endfor

	*!* ******************** Removed 11/24/2014 *****************
	*!* Asort(m.laMenuItems, 1, -1, 0, 1)

	For lnI = 1 To Alen(m.laMenuItems, 1)
		loMenuItem = m.laMenuItems[m.lnI, 2]
		m.loContextMenu.AddMenuItem (m.loMenuItem.DisplayName, , , , m.loMenuItem.ClassLibName)
	Endfor

	If m.loContextMenu.Activate()
		lcTableName	= m.loContextMenu.Keyword
		m.loPEME_Tools.EditSourceX (m.lcTableName)
	Endif
Endproc
