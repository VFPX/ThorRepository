* These constants will be used to define the "Browse" option on the
* popup menu.
#DEFINE BROWSE_OPTION_CAPTION		"Browse..."
#DEFINE BROWSE_OPTION_RETURNVALUE	"(Browse)"

* This just makes it easy to limit the number of items to include in
* the list.
#DEFINE MAX_ITEMS_IN_LIST	20

* see	http://vfpx.codeplex.com/wikipage?title=Thor%20Tools%20Object
LOCAL loMenuItem As 'Empty', ;
	laMenuItems[1], ;
	lcProjectName, ;
	lcDisplayName, ;
	lcFName, ;
	xx, ;
	loContextMenu, ;
	loMRUItems AS Collection, ;
	loPEME_Tools

* There are a couple of tools that are part of PEMEditor which we want
* to use here.
loPEME_Tools = EXECSCRIPT( _Screen.cThorDispatcher, 'Class= Tools From PEMEditor' )

* Get a list of the most recently used projects.
loMRUItems = loPEME_Tools.GetMRUList( 'PJX' )

IF loMRUItems.Count = 0
	* There are no projects in the MRU list, so force the file open
	* dialog to browse for a file.
	lcProjectName = BROWSE_OPTION_RETURNVALUE
ELSE
	* Create a context menu for the list of projects to display.
	loContextMenu = EXECSCRIPT( _Screen.cThorDispatcher, 'Class= ContextMenu' )

	FOR xx = 1 TO MIN( m.loMRUItems.Count, MAX_ITEMS_IN_LIST )
		* Get the name of the project as it's define in the file system.
		lcProjectName = m.loPEME_Tools.DiskFileName( m.loMRUItems( m.xx ) )

		* Get the file name alone, for display and sorting, and build
		* a longer display name that includes the full path.
		lcFName = JUSTFNAME( m.lcProjectName )
		lcDisplayName = m.lcFName + "   from " + JUSTPATH( m.lcProjectName )

		* Create a data object containing the info for this menu item.
		loMenuItem = CREATEOBJECT( 'Empty' )
		ADDPROPERTY( m.loMenuItem, 'FName', m.lcFName )
		ADDPROPERTY( m.loMenuItem, 'DisplayName', m.lcDisplayName )
		ADDPROPERTY( m.loMenuItem, 'ProjectName', m.lcProjectName )

		* Add a sort name and the menu item info to an array for sorting.
		DIMENSION laMenuItems[xx, 2]
		laMenuItems[xx, 1] = m.lcFName + ' ' + m.lcProjectName
		laMenuItems[xx, 2] = m.loMenuItem
	ENDFOR

	ASORT( laMenuItems, 1, -1, 0, 1 )

	* Populate the context menu object.
	FOR xx = 1 To ALEN( laMenuItems, 1)
		loMenuItem = laMenuItems[xx, 2]
		loContextMenu.AddMenuItem( loMenuItem.DisplayName, , , , loMenuItem.ProjectName )
	ENDFOR

	* Add an item to the end of the list so that the user can choose
	* to browse for a project file.
	loContextMenu.AddMenuItem( BROWSE_OPTION_CAPTION, , , , BROWSE_OPTION_RETURNVALUE )

	* If the menu was successfully activated, and the user selected
	* something, get the user's selection.
	IF m.loContextMenu.Activate()
		lcProjectName = m.loContextMenu.KeyWord
	ELSE
		lcProjectName = SPACE(0)
	ENDIF
ENDIF

* We need to present a file open dialog, either because the user chose
* to do so, or there was no MRU list to display.
IF m.lcProjectName == BROWSE_OPTION_RETURNVALUE
	lcProjectName = GETFILE( "PJX", "", "", 0, "Select a Project to Convert" )
ENDIF

* Populating _SCREEN.xThorResult allows us to retrieve the project name
* using a Thor call like the following:
* lcProjectName = EXECSCRIPT( _Screen.cThorDispatcher, "Thor_Proc_GetProjectName" )
*!*	ADDPROPERTY( _SCREEN, "xThorResult", m.lcProjectName )
* I believe this is the way I should actually be populating the return
* value for Thor.
EXECSCRIPT( _SCREEN.cThorDispatcher, "Result=", m.lcProjectName )

RETURN m.lcProjectName
