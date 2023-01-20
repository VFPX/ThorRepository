#Define CR						Chr(13)
#Define PF_FontSizeSmall		7

****************************************************************
* Highlighting Page

#Define PF_STR_NONE				'None'
#Define PF_STR_FORECOLOR		'ForeColor'
#Define PF_STR_BACKCOLOR		'BackColor'
#Define PF_STR_BOLD				'Bold'
#Define PF_STR_ITALIC			'Italic'

#Define PF_CAP_PROPERTIES		'Properties'
#Define PF_CAP_METHODS			'Methods'
#Define PF_CAP_CUSTOM			'Custom'
*#Define PF_CAP_INHERITED		'Inherited'
*#Define PF_CAP_NATIVE			'Native'

#Define PF_CAP_NONDefault		'Non-Default'
#Define PF_CAP_FAVORITES		'Favorites'

#Define PF_CAP_Local			'Local Code'
#Define PF_CAP_Inherited		'Inherited Code'
#Define PF_CAP_With_Code		'With Code:'
#Define PF_CAP_NonNative		'Non-Native:'
#Define PF_CAP_Native		 	'Native:'

#Define PF_CAP_SAMPLE_1			'Sample 1'
#Define PF_CAP_SAMPLE_2			'Sample 2'
#Define PF_CAP_SAMPLE_3			'Sample 3'
#Define PF_CAP_SAMPLE_4			'Sample 4'

****************************************************************
#Define pf_LOC_CMA_Edit			'Edit default code'
#Define pf_LOC_CMA_Reset		'Reset to default'

*******************************************************************************************************************
*******************************************************************************************************************
*******************************************************************************************************************




****************************************************************
****************************************************************
* Hot Key assignments
*
****************************************************************
* Normal mode (neither adding nor editing)

* 	A	N\<ative
* 	B	Visi\<bility
* 	C	\<Custom
* 	D	\<Description
* 	E	Nam\<e
* 	F	\<Find
* 	G	Assi\<gn
* 	H	Met\<hods
* 	I	\<Inherited
* 	J
* 	K
* 	L	Va\<lue
* 	M	Add \<Method
* 	N	Eve\<nts
* 	O	Fav\<orites
* 	P	Add \<Property
* 	Q
* 	R	P\<roperties
* 	S	Acce\<ss
* 	T	Rese\<t Filters
* 	U	Non-Defa\<ult
* 	V	Remo\<ve
* 	W
* 	X
* 	Y
* 	Z

****************************************************************
* Adding or editing mode

* 	A	S\<ave
* 	B	Visi\<bility
* 	C	\<Cancel
* 	D	\<Description
* 	E	Nam\e
* 	F	
* 	G	Assi\<gn
* 	H	
* 	I	
* 	J
* 	K
* 	L	Va\<lue
* 	M	Save, then Edit \<Method (adding mode only)
* 	N	
* 	O	Fav\<orites
* 	P	
* 	Q
* 	R	
* 	S	Acce\<ss
* 	T	
* 	U	
* 	V	
* 	W
* 	X
* 	Y
* 	Z


*==============================
* Localization strings
*==============================

****************************************************************
* Context Menu ... Property Window
#Define ccLOC_CM_ResetToDefault			["\<Reset to Default"]
#Define ccLOC_CM_ZOOM					["\<Zoom..."]
#Define ccLOC_CM_ExpressionBuilder		["Expression \<Builder..."]
#Define ccLOC_CM_PEM_Editor				["\<PEM Editor..."]

#Define ccLOC_CM_MemberData				["\<MemberData Editor..."]
#Define ccLOC_CM_AddToFavorites			["Add to \<Favorites"]
#Define ccLOC_CM_Help					["\<Help"]

****************************************************************
* Context Menu ... grid
#Define ccLOC_CMG_EDIT_METHOD			'\<Edit Method (Double-Click)'
#Define ccLOC_CMG_VIEW_PARENT_CODE		'Vie\<w Parent Code (Ctrl-Click)'
#Define ccLOC_CMG_COLORS				'\<Colors... (Double-Click)'
#Define ccLOC_CMG_ZOOM					'\<Zoom... (Double-Click)'
#Define ccLOC_CMG_GetExpr				'Expression \<Builder...'
#Define ccLOC_CMG_ResetToDefault		'\<Reset To Default'
#Define ccLOC_CMG_Remove				'Remo\<ve'
#Define ccLOC_CMG_ViewParentage			'Parentage (Alt-Click)'
#Define ccLOC_CMG_FONT					'\<Font...'
#Define ccLOC_CMG_Copy					'Copy (for pasting or comparing)'
#Define ccLOC_CMG_Compare				'Compare with copied object'
#Define ccLOC_CMG_CopyFiltered			'Copy filtered properties and method code'
#Define ccLOC_CMG_Paste					'Paste properties and method code'
#Define ccLOC_CMG_CopyObject			'Copy object'
#Define ccLOC_CMG_PasteObject			'Paste object'
#Define ccLOC_CMG_ChangeClass			'Re-Define Parent Class'
#Define ccLOC_CMG_CompareClass			'Compare with Parent Class'
#Define ccLOC_CMG_EventHandlersEnabled	'Event Handlers Enabled'

#Define ccLOC_CMG_PREFERENCES			'\<Preferences...'
#Define ccLOC_CMG_Close_All				'Close all listings'
#Define ccLOC_CMG_MemberDataTools		"MemberData Tools"
#Define ccLOC_CMG_MemberData2			"\<MemberData Editor..."
#Define ccLOC_CMG_Help2					"VFP \<Help"
#Define ccLOC_CMG_Videos				"PEM Editor Help Videos"
#Define ccLOC_CMG_About					"About PEM Editor"

****************************************************************
* Grid Column Headers and tooltips
*   .Columns(1) ... ColName
#Define ccLOC_GCH_Name					'Name'
#Define ccLOC_GCH_Control				'Object'
#Define ccLOC_GCH_NameTip				'Property, event, or method of the object'

*   .Columns(2) ... ColType
#Define ccLOC_GCH_Type					'Type'
#Define ccLOC_GCH_TypeA					'Typ'
#Define ccLOC_GCH_TypeTip 				'Property (P), Method (M), or Event (E)'

*   .Columns(3) ... ColAccess
#Define ccLOC_GCH_Access				'Access'
#Define ccLOC_GCH_AccessA				'Acc'
#Define ccLOC_GCH_AccessTip				'Has Access Method'

*   .Columns(4) ... ColAssign
#Define ccLOC_GCH_Assign				'Assign'
#Define ccLOC_GCH_AssignA				'Asn'
#Define ccLOC_GCH_AssignTip				'Has Assign Method'

*   .Columns(5) ... ColVisibility
#Define ccLOC_GCH_Visibility			'Visibility'
#Define ccLOC_GCH_VisibilityA			'Vis'
#Define ccLOC_GCH_VisibilityTip			'Public (blank), Protected (P), or Hidden (H)'

*   .Columns(6) ... Hierarchy
#Define ccLOC_GCH_Hierarchy				'Origin'
#Define ccLOC_GCH_HierarchyA			'Org'
#Define ccLOC_GCH_HierarchyTip			'Custom (added to this <insert2>), Inherited (from parent class), or Native to VFP'

*   .Columns(7) ... ColFavorite
#Define ccLOC_GCH_Favorite				'Favorite'
#Define ccLOC_GCH_FavoriteA				'Fav'
#Define ccLOC_GCH_FavoriteTip			'Favorites'

*   .Columns(8) ... NonDefault
#Define ccLOC_GCH_NonDefault			'NonDefault'
#Define ccLOC_GCH_NonDefaultA			'N-D'
#Define ccLOC_GCH_NonDefaultTip			'Non-Default'

*   .Columns(9) ... ColTypeIcon

*   .Columns(10) ... ColValue
#Define ccLOC_GCH_Value					'Value'
#Define ccLOC_GCH_ValueTip				'Specifies the current setting of the property for the object'

*   .Columns(11) ... ColCode
#Define ccLOC_GCH_CodeOrigin			'Code'
#Define ccLOC_GCH_CodeOriginA			'Cod'
#Define ccLOC_GCH_CodeOriginTip			'Indicates whether there is code, either defined in this <insert2>, or inherited from a parent class'

****************************************************************
****************************************************************
*  Preferences Form
#Define ccLOC_Pref_CAP_PREFERENCES				'Preferences'
#Define ccLOC_Pref_CAP_IDE_Settings				'Settings for IDE Tools'

#Define ccLOC_Pref_Cap_RestartAfterClearAll		'Survives "Clear All"'
#Define ccLOC_Pref_Cap_UseDefaultFilters		'Reset filters when PEM Editor starts'
#Define ccLOC_Pref_Cap_DebugMode				'Debug mode (for Builders and Event Handlers)'
#Define ccLOC_Pref_Tip_DebugMode				'Assists in debugging when creating Builders and Event  Handlers (errors are NOT trapped)'
#Define ccLOC_Pref_CAP_ALLOW_DESCRIPTION_CRS 	'Allow CRs in descriptions'
#Define ccLOC_Pref_CAP_Dockable					'Dockable'

#Define ccLOC_Pref_CAP_EscClosesForm			'Esc closes PEM Editor'

#Define ccLOC_Pref_CAP_MRUOpenClasses			'Open Class'
#Define ccLOC_Pref_CAP_MRUOpenForms				'Open Form'
#Define ccLOC_Pref_CAP_MRUOpenProject			'Open Project'
#Define ccLOC_Pref_CAP_MRUOpenOther				'Open Other Files'
#Define ccLOC_Pref_CAP_MRUForms					'MRU Forms'
#Define ccLOC_Pref_CAP_MRUClasses				'MRU Classes'
#Define ccLOC_Pref_CAP_MRUClassLibs				'MRU ClassLibs'
#Define ccLOC_Pref_CAP_MRUProjects				'MRU Projects'
#Define ccLOC_Pref_CAP_MRUFiles					'MRU Files'
#Define ccLOC_Pref_CAP_MRUFavorites				'Favorites'
#Define ccLOC_Pref_CAP_MRUAddForm				'Add this form'
#Define ccLOC_Pref_CAP_MRURemoveForm			'Remove this form'
#Define ccLOC_Pref_CAP_MRUAddClass				'Add this class'
#Define ccLOC_Pref_CAP_MRURemoveClass			'Remove this class'
#Define ccLOC_Pref_CAP_MRUAddClassLib			'Add this class library'
#Define ccLOC_Pref_CAP_MRURemoveClassLib		'Remove this class library'

#Define ccLOC_Pref_CAP_DocumentTreeView			'Open Document TreeView when PEM Editor starts'

#Define ccLOC_Pref_Tip_RestartAfterClearAll		'Causes PEM Editor to restart after a "Clear All" command'
#Define ccLOC_Pref_Tip_UseDefaultFilters		'If not, use the filters in effect when PEM Editor closed.'
#Define ccLOC_Pref_Tip_ALLOW_DESCRIPTION_CRS 	'Descriptions can not normally contain CRs.  This option allows you to enter CRs in descriptions (they are saved as \n).'

#Define ccLOC_Pref_Tip_EscClosesForm			'Allows the use of the Esc-key to close PEM Editor'

#Define ccLOC_Pref_CAP_GRIDHIGHLIGHTING		' Grid Highlighting '
#Define ccLOC_Pref_CAP_DEFAULT				'Sample 1'
#Define ccLOC_Pref_CAP_SAMPLE_2				'Sample 2'
#Define ccLOC_Pref_CAP_SAMPLE_3				'Sample 3'
#Define ccLOC_Pref_CAP_SAMPLE_4				'Sample 4'

#Define ccLOC_Pref_CAP_PROPERTIES			'Properties'
#Define ccLOC_Pref_CAP_METHODS				'Methods'
#Define ccLOC_Pref_CAP_EVENTS				'Events'
#Define ccLOC_Pref_CAP_NATIVE				'Native'
#Define ccLOC_Pref_CAP_INHERITED			'Inherited'
#Define ccLOC_Pref_CAP_CUSTOM				'Custom'

#Define ccLOC_Pref_CAP_MV_Local				'Local Code'
#Define ccLOC_Pref_CAP_MV_Inherited			'Inherited Code'
#Define ccLOC_Pref_CAP_MV_With_Code			'With Code:'
#Define ccLOC_Pref_CAP_MV_None				'Without Code:'
#Define ccLOC_Pref_CAP_MV_NoMethod			'Non-Native'
#Define ccLOC_Pref_CAP_MV_NoEvent			'Native'

#Define ccLOC_Pref_CAP_OK					'OK'
#Define ccLOC_Pref_CAP_RESETALLDEFAULTS		"Reset all Defaults"
#Define ccLOC_Pref_CAP_OPTIONS				' Options '
#Define ccLOC_Pref_CAP_FAVORITES			'Favorites'
#Define ccLOC_Pref_CAP_FC_Class				'class'
#Define ccLOC_Pref_CAP_FC_Form				'form'

#Define ccLOC_Pref_CAP_ResetToDefault		'Reset To Default'
#Define ccLOC_Pref_ASK_ResetAllDefaults		'Are you sure you want to reset ALL PEM Editor preferences' + CR + 'to their default values?'

****************************************************************
****************************************************************

#Define ccLOC_CAP_TITLE					'PEM Editor'
#Define ccLOC_CAP_DocTreeViewTITLE		'Document TreeView'

#Define ccLOC_CAP_MRU_List				'MRU forms/classes/projects/files' + CR + 'Favorites' + CR + 'Open Form/Class/Files'
#Define ccLOC_CAP_Find					'Find object(s)'
#Define ccLOC_CAP_NEW_PEM				'\<Add'
#Define ccLOC_CAP_NEW_PROPERTY			'Add \<Prop.'
#Define ccLOC_CAP_NEW_METHOD			'Add \<Method'
#define ccLOC_CAP_Apply_And_Add			'S\<ave'
#define ccLOC_TIP_Apply_And_Add			'Also Ctrl+Enter'

*	#define ccLOC_TIP_Apply_And_Add			'Apply changes and then add another'
#define ccLOC_CAP_Apply_And_Edit		'Save, then Edit \<Method'
#define ccLOC_TIP_Apply_And_Edit		'Add and then edit method code'
#Define ccLOC_CAP_NAME					'Nam\<e:'
#Define ccLOC_CAP_VISIBILITY			'Visi\<bility:'
#Define ccLOC_CAP_ACCESS				'Acce\<ss'
#Define ccLOC_CAP_ASSIGN				'Assi\<gn'
#Define ccLOC_CAP_FAVORITES				'Fav\<orites only'
#Define ccLOC_CAP_FAVORITES2			'Favorites'
#Define ccLOC_CAP_DEFAULT_VALUE			'Default Va\<lue:'
#Define ccLOC_CAP_DEFAULT_VALUE_Form	'Va\<lue:'
#Define ccLOC_CAP_Reset_Filters			'Rese\<t Filters'
#Define ccLOC_CAP_DESCRIPTION			'\<Description:'
#Define ccLOC_CAP_MEMBER_TYPE			'Type:'
#Define ccLOC_CAP_PROPERTY				'Property'
#Define ccLOC_CAP_METHOD				'Method'
* #Define ccLOC_CAP_SUBSTRING			'C\<ontains'
#Define ccLOC_CAP_ResetToDefault		'Reset To Default'

#Define ccLOC_CAP_NonDefaultPr			'Non-Defa\<ult only'

#Define ccLOC_CAP_APPLY					'S\<ave'
#Define ccLOC_CAP_REFRESH   			'Refresh'
#Define ccLOC_CAP_REFRESHF5   			'Refresh (F5)'
#Define ccLOC_CAP_Preferences   		'Pref.'
#Define ccLOC_Tip_Preferences			'Preferences'
#Define ccLOC_CAP_Help   				'Help'
#Define ccLOC_CAP_ContextHelp   		'Context-sensitive Help'
#define ccLOC_CAP_BackToAll				'Back to ALL properties'
#Define ccLOC_CAP_Cancel				'\<Cancel'
#Define ccLOC_CAP_Cancel1				'\<Cancel'
#Define ccLOC_CAP_CancelAdd				'\<Cancel Add Mode'
#Define ccLOC_CAP_CancelEdit			'\<Cancel Edit Mode'
#Define ccLOC_CAP_REMOVE				'Remo\<ve'

#Define ccLOC_CAP_FILTERS				'Filters'
#Define ccLOC_CAP_PROPERTIES			'P\<roperties'
#Define ccLOC_CAP_METHODS				'Met\<hods'
#Define ccLOC_CAP_EVENTS				'Eve\<nts'
#Define ccLOC_CAP_NATIVE				'Native'
#Define ccLOC_CAP_INHERITED				'\<Inherited'
#Define ccLOC_CAP_CUSTOM				'\<Custom'
#Define ccLOC_CAP_NONDefault			'Non-Defa\<ult'

#Define ccLOC_CAP_MV_Local				'Local Code'
#Define ccLOC_CAP_MV_Inherited			'Inherited Code'
#Define ccLOC_CAP_MV_With_Code			'With Code:'
#Define ccLOC_CAP_MV_None				'Without Code:'
#Define ccLOC_CAP_MV_NoMethod			'Non-Native'
#Define ccLOC_CAP_MV_NoEvent			'Native'

#Define ccLOC_CAP_FC_Class				'class'
#Define ccLOC_CAP_FC_Form				'form'
#Define ccLOC_TIP_NEW_PEM				'Adds a new method or property to the <insert2>.'
#Define ccLOC_TIP_NEW_PEM_ADDING		"Adds '<insert1>' to the <insert2>, then adds another new method or property to the <insert2>."
#Define ccLOC_CAP_METHOD_CODE_ADDING	"Adds '<insert1>' to the <insert2>, then opens it up for editing."

#Define ccLOC_CAP_MV_LocalTip			'Methods and Events that have custom code in this <insert2>'
#Define ccLOC_CAP_MV_InheritedTip		'Methods and Events that have inherited code from a parent class, but do not have custom code in this <insert2>'
#Define ccLOC_CAP_MV_NoMethodTip		'Non-Native Methods that do not have any code'
#Define ccLOC_CAP_MV_NoEventTip			'Events and Native Methods that do not have any code'

#Define ccLOC_CAP_MV_LocalTitle			'Local Code'
#Define ccLOC_CAP_MV_InheritedTitle		'Inherited Code'
#Define ccLOC_CAP_MV_NoMethodTitle		'Non-Native'
#Define ccLOC_CAP_MV_NoEventTitle		'Native'


#Define ccLOC_CAP_Hierarchy_Native		'Native'
#Define ccLOC_CAP_Hierarchy_NativeA		'N'
#Define ccLOC_CAP_Hierarchy_Inherited	'Inherited'
#Define ccLOC_CAP_Hierarchy_InheritedA	'I'
#Define ccLOC_CAP_Hierarchy_Custom		'Custom'
#Define ccLOC_CAP_Hierarchy_CustomA		'C'

#Define ccLOC_CAP_Type_Property			'Property'
#Define ccLOC_CAP_Type_PropertyA		'P'
#Define ccLOC_CAP_Type_Method			'Method'
#Define ccLOC_CAP_Type_MethodA			'M'
#Define ccLOC_CAP_Type_Event			'Event'
#Define ccLOC_CAP_Type_EventA			'E'

#Define ccLOC_CAP_Vis_Public			''
#Define ccLOC_CAP_Vis_PublicA			''
#Define ccLOC_CAP_Vis_Protected			'Protected'
#Define ccLOC_CAP_Vis_ProtectedA		'P'
#Define ccLOC_CAP_Vis_Hidden			'Hidden'
#Define ccLOC_CAP_Vis_HiddenA			'H'
#Define ccLOC_STR_PUBLIC				'Public'

#Define ccLOC_CAP_CO_Local				'Local'
#Define ccLOC_CAP_CO_Inherited			'Inherited'

#Define ccLOC_CAP_Yes					'Yes'
#Define ccLOC_CAP_YesA					'Y'
#Define ccLOC_CAP_No					''
#Define ccLOC_CAP_NoA					''
#Define ccLOC_CAP_FONT					'\<Font...'

#Define ccLOC_CAP_USE_CSO				'Current Object'
#Define ccLOC_CAP_USE_CSO_Plural		'Current Objects'
#Define ccLOC_CAP_NormalView			'Normal View'
#Define ccLOC_CAP_MethodView			'Method View'

#Define ccLOC_Tip_USE_CSO				"The 'Classic' view shows PEMs for the <insert2>, NOT the currently select object." + ;
	CR + CR + "This option allows you to see the PEMs for the currently selected object, as occurs in the Property Sheet."
#Define ccLOC_Tip_NormalView			'Normal View shows all Properties, Methods, and Events (as selected by the filters).'
*  #Define ccLOC_Tip_MethodView			'Method View shows only Methods and Events, with a different set of filters, something like a mini-Document View.'

#Define ccLOC_CAP_FONTSIZE				'Font Size'
#Define ccLOC_CAP_OK					'OK'
#Define ccLOC_CAP_Search				'Search'

#Define ccLOC_CAP_RESETALLDEFAULTS		"Reset all Defaults"
#Define ccLOC_CAP_RESETFilterDEFAULTS	"Reset filters to system defaults"
#Define ccLOC_CAP_OPTIONS				' Options '
#Define ccLOC_CAP_Exported 				'Exported to _cliptext'
#Define ccLOC_CAP_Remove_Property 		'Remove Property: '
#Define ccLOC_CAP_Remove_Method 		'Remove Method: '

#Define ccLOC_CAP_REMOVE_ACCESS			'Remove Method PEM_Name_Place_Holder_access' + Chr(13) + 'from Property PEM_Name_Place_Holder?'
#Define ccLOC_CAP_REMOVE_ASSIGN			'Remove Method PEM_Name_Place_Holder_assign' + Chr(13) + 'from Property PEM_Name_Place_Holder?'

#Define ccLOC_CAP_REMOVEPROMPT			'Remo\<ve PEM_Name_Place_Holder?'

#Define ccLOC_CAP_ZOOM					'ZOOM: '

#Define ccLOC_MENU_UNDO					'\<Undo'
#Define ccLOC_MENU_CUT					'Cu\<t'
#Define ccLOC_MENU_COPY					'\<Copy'
#Define ccLOC_MENU_PASTE				'\<Paste'
#Define ccLOC_MENU_CLEAR				'Cle\<ar'
#Define ccLOC_MENU_SELECT_ALL			'Se\<lect All'

#Define ccLOC_STR_DESCRIPTION			'Description'
#Define ccLOC_STR_DESCRIPTION_Max_Length	100
#Define ccLOC_STR_DEFAULT_VALUE			'Default Value'

#Define ccLOC_VFP_Base_Class			'VFP Base Class: '

* Messages

#Define ccLOC_STRING_TOO_LONG			"The member data for this class is over 8K in size, which is too long, so the display and favorites settings won't be saved."
#Define ccLOC_INVALID_XML				'The _MemberData property of this object contains invalid XML.'
#Define ccLOC_DIALOG_REGISTERED			'PEM Editor has been registered.' + CR + CR + 'StartPEMEditor.PRG has been created.' + CR + CR + 'Backup of _FoxCode has been saved in folder "FoxCode Backup".'
#Define ccLOC_DIALOG_Failed				'PEM Editor registration failed.' + CR + CR + 'Problem accessing _FoxCode.'
#Define ccLOC_DIALOG_REGISTERED_V8		'StartPEMEditor.PRG has been created.'
#Define ccLOC_MEMBER_EXISTS				'PEM_Name_Place_Holder already exists.'
#Define ccLOC_INVALID_CHAR				"That character isn't valid in a member name."
#Define ccLOC_NO_OBJECT					"There's no object to create a new property or method for."
#Define ccLOC_NO_FILTER_MATCHES			'There are no PEMs found to match your filters.'
#Define ccLOC_INVALID_NAME				'Not a valid name (possibly bad array)'
#Define ccLOC_AddProperty_Failed		'Unable to add/set Property' 			;
	+ CR + '   Possibly incorrect data type';
	+ CR + '   Possibly out of range'
	
#Define ccLOC_ViewParentCode_File_Failed	'Unable to open file <FileName>'
#Define ccLOC_ViewParentCode_Class_Failed	'Unable to find <ClassName> in file <FileName>'


* Tooltips.

#Define ccLOC_TOOLTIP_SPLITTER_Vertical		'Drag this splitter up or down to resize the grid'
#Define ccLOC_TOOLTIP_SPLITTER_Horizontal	'Drag this splitter left or right to resize the grid'
#Define ccLOC_TOOLTIP_SPLITTER_VertTextBoxes	'Drag this splitter up or down to resize the description editbox'
#Define ccLOC_TOOLTIP_ADDITIONAL_OPTIONS	'Click for other options'

* Localized VFP IDE window names.

#Define ccLOC_WINDOW_DEBUGGER			'Debugger'
#Define ccLOC_WINDOW_TRACE				'Trace'
#Define ccLOC_WINDOW_WATCH				'Watch'
#Define ccLOC_WINDOW_LOCALS				'Locals'
#Define ccLOC_WINDOW_CALL_STACK			'Call'
#Define ccLOC_WINDOW_DEBUG_OUTPUT		'Debug Output'
#Define ccLOC_WINDOW_Data_Session		'View'

#Define ccLOC_WINDOW_CLASS_DESIGNER		'Class Designer'

*** DH 12/30/2008: added new constants
#Define ccLOC_MENU_NEW_PROPERTY         'New Property...'
#Define ccLOC_MENU_NEW_METHOD           'New Method...'
#Define ccLOC_MSG_USE_PEME_FOR_NEW 		'PEM Editor will be installed as a replacement for Edit Property/Method.';
	+ CR + CR + 'Do you also wish to install PEM Editor as a replacement';
	+ CR + 'for the New Property and New Method tools?'
#Define ccLOC_PR_NotifyNewPemsHidden	"<insert3> PEM_Name_Place_Holder has been added to the <insert2>" + CR + ;
	"but is not currently shown in the grid" + CR + "because of the filter(s) you have selected."
#Define ccLOC_PR_NotifyNewPemsHiddenCSO	"<insert3> PEM_Name_Place_Holder has been added to the <insert2>" + CR + ;
	"but is not currently shown in the grid because the grid "  + CR +  ;
	"is showing the currently selected object, not the <insert2> itself."

*** DH 12/30/2008: end of new code


****************************************************************
****************************************************************
* Added in release 3.01

#Define ccLOC_CAP_Cant_Edit				'Unable to edit any method or event code' + Chr(13) + 'until you have first saved this form.'
#Define ccLOC_CAP_Apply_Open			'If you apply your changes when you have a window open' + Chr(13) + 'to edit the method code for method PEM_Name_Place_Holder,' + Chr(13) + 'any changes you have made to the method code will be lost.' + Chr(13) + Chr(13) + 'Do you still want to apply changes?'
#Define ccLOC_CAP_VIEW_METHOD_CODE		'Code:'


****************************************************************
****************************************************************
* Added in release 4.00
#Define ccLOC_CM_Remove					["Remo\<ve"]
#Define ccLOC_CMG_CleanseMemberData		"Cleanse MemberData"
#Define ccLOC_CMG_CleanseMemberStats	"MemberData Statistics"
#Define ccLOC_CMG_VIEW_PARENT_Values	'Parent Values (Ctrl-Click)'

#Define ccLOC_CMG_Exports				'Listings'
#Define ccLOC_CMG_ExportPEMList			'List of PEMs and descriptions'
#Define ccLOC_CMG_ExportPEMListText		'as Text'
#Define ccLOC_CMG_ExportPEMListHTML		'as HTML'

#Define ccLOC_CMG_ExportMethods			'Code for all methods'
#Define ccLOC_CMG_ExportChildMethods	'Code for all methods, including child objects'
#Define ccLOC_CMG_ExportParentMethods	'Code + Parent code for all methods'

#Define ccLOC_Tip_MethodView			'Method View is something like a mini-Document View - it shows only methods and events. It provides different filters, columns, sort order, and grid highlighting than the normal view.'

#Define ccLOC_CMV_Character				'Character = blank'
#Define ccLOC_CMV_Logical				'Logical = .F.'
#Define ccLOC_CMV_Numeric				'Numeric = 0'
#Define ccLOC_CMV_Date					'Date = {//}'
#Define ccLOC_CMV_DateTime				'DateTime = {// :}'
#Define ccLOC_CMV_Null					'Null = .NULL.'

#Define ccLOC_CAP_SUBSTRING				'\<Find'
#Define ccLoc_CMSrch_NameContains		'Name contains .. N$'
#Define ccLoc_CMSrch_NameStart			'Name starts with .. N='
#Define ccLoc_CMSrch_DescContains		'Description contains .. D$'
#Define ccLoc_CMSrch_DescStart			'Description starts with .. D='
#Define ccLoc_CMSrch_ValueContains		'Value contains .. V$'
#Define ccLoc_CMSrch_ValueStart			'Value starts with .. V='
#Define ccLoc_CMSrch_StartsUpper		'Starts w/Uppercase .. U='
#Define ccLoc_CMSrch_AnyUpper			'Uppercase anywhere .. U$'
#Define ccLoc_CMSrch_StartsLower		'Starts w/Lowercase .. L='
#Define ccLoc_CMSrch_AllLower			'All Lowercase .. L$'
#Define ccLoc_CMSrch_Clear				'Clear'


#Define ccLOC_Pref_CAP_Keep_Style	    "Are you using VFP-Style property editors, which use the Memberdata 'script' attribute?"
#Define ccLOC_Pref_Tip_Keep_Style  		'If so, they will be disabled by the MemberData management tools unless this is checked.'

#Define ccLOC_Pref_CAP_Buffer_OverRuns  "Will you be working on a class or form which gets 'Buffer Overrun' problems?"
#Define ccLOC_Pref_Tip_Buffer_OverRuns  'If so, they can be circumvented by checking here; note that descriptions for properties and methods will be disabled while this is in effect.'

#Define ccLOC_Pref_Tip_Buffer_OverRuns_Unavailable  'Descriptions are unavailable.  See table "Buffer Overrun Avoidance List" in the folder where PEM Editor is installed.'

#Define ccLoc_CMT_SortOrderMethods		'Method Sort Order'
#Define ccLoc_CMT_SortOrder				'Object Sort Order'
#Define ccLoc_CMT_Natural				'Unsorted'
#Define ccLoc_CMT_Alphabetical			'Alphabetical (case sensitive)'
#Define ccLoc_CMT_AlphabeticalUseCase	'Alphabetical (case insensitive)'
#Define ccLoc_CMT_TabIndex				'TabIndex'
#Define ccLoc_CMT_TopToBottom			'Top to Bottom'
#Define ccLoc_CMT_LeftToRight			'Left to Right'
#Define ccLoc_CMT_MemberSort			'MemberClasses -- ordered'
#Define ccLoc_CMT_ShowClassName			'Show class name'
#Define ccLoc_CMT_ShowClassLib			'Show class library and name'
#Define ccLoc_CMT_ShowCaptions			'Show Caption, ControlSource '
#Define ccLoc_CMT_ShowEntireTree		'Show entire tree'
#Define ccLoc_CMT_ShowPartialTree		'Show tree starting with this node'
#Define ccLoc_CMT_ShowParentPartialTree	'Show tree starting with parent node'
#Define ccLoc_CMT_ExpandAllNodes		'Always expand all nodes'
#Define ccLOC_CMG_DeleteControl			"Remove this object"
#Define ccLOC_CMG_ChangeBaseClass		"Change baseclass from '<old>' to '<new>'?"
#Define ccLOC_CMG_Rename				"Rename"

#Define ccLOC_CMG_AutoRenameThis		"Auto-rename this object"
#Define ccLOC_CMG_AutoRenameKids		"Auto-rename this object and its children"
#Define ccLOC_CMG_AutoRename			"Auto-rename"
#Define ccLOC_CMG_AutoRenameThisSub		"This object"
#Define ccLOC_CMG_AutoRenameKidsSub		"This object and its children"

#Define ccLOC_ASK_CMG_AutoRenameThis	'Auto-renaming will change the name of this object' + CR + CR + '********** WARNING: ********** ' + CR + 'This will NOT change any references to this object in method code!' + CR + '********** WARNING: ********** ' + CR + CR + 'Do you want to continue?'
#Define ccLOC_ASK_CMG_AutoRename		'Auto-renaming will change the name of this object (and any objects it' + CR + 'contains) IF the name of the object is the default name created by VFP;' + CR + 'that is, if the name is the class name followed by a number.' + CR + CR + '********** WARNING: ********** ' + CR + 'This will NOT change any references to these objects in method code!' + CR + '********** WARNING: ********** ' + CR + CR + 'Do you want to continue?'

#Define ccLOC_CMG_DocumentTreeView		"Start Document TreeView (as separate form)"
#Define ccLOC_CMT_DataEnvironment		"Data Environment"
#Define ccLOC_CMG_NameToClipBoard		"Copy full object name to clipboard"
#Define ccLOC_ASK_CMG_DeleteControl		'Are you sure you want to delete this object?' + CR + CR + 'Full name = <insert1>'
#Define ccLOC_DIALOG_UNINSTALLED		'PEM Editor has been uninstalled.'
#Define ccLOC_CMG_ToggleEditor			'Toggle Editor (Double-Click)'
#Define ccLOC_CMG_PropertyEditor		'Edit... (Double-Click)'
#Define ccLOC_CMG_ZoomBox				'Edit (using EditBox)'
#Define ccLOC_CMG_BrowseMemberData		'Browse _MemberData'

#Define ccLOC_TOOLTIP_SPLITTER_DownArrow	'Click here to expand the grid, hiding the objects below'
#Define ccLOC_TOOLTIP_SPLITTER_UpArrow		'Click here to contract the grid, displaying the hidden objects'
#Define ccLOC_TOOLTIP_SPLITTER_RightArrow	'Click here to expand the grid, hiding the objects to the right'
#Define ccLOC_TOOLTIP_SPLITTER_LeftArrow	'Click here to contract the grid, displaying the hidden objects'
#Define ccLOC_Pref_CAP_CloseTrace			'Close all debugger windows when PEM Editor opens'
#Define ccLOC_Pref_Tip_CloseTrace			'Execution may slow dramatically if there are debugger windows open.  If this is checked so that PEM Editor close any debugger windows, they will be re-opened when PEM Editor is closed or becomes inactive.'
****************************************************************

#Define ccLOC_CAP_Vis_Protected			'Protected'
#Define ccLOC_CAP_Vis_ProtectedA		'P'
#Define ccLOC_CAP_Vis_Hidden			'Hidden'
#Define ccLOC_CAP_Vis_HiddenA			'H'
#Define ccLOC_STR_PUBLIC				'Public'

#Define ccLOC_Cap_Fav_None				''
#Define ccLOC_Cap_Fav_Local				'Local'
#Define ccLOC_Cap_Fav_Global			'Global'
#Define ccLOC_Cap_Fav_Both				'\Both'

#Define ccLOC_Cap_Fav_None2				'Not Used'
#Define ccLOC_Cap_Fav_Local2			'Saved in _MemberData property'
#Define ccLOC_Cap_Fav_Global2			'Saved in (_FoxCode) file'
#Define ccLOC_Cap_Fav_Both2				'\Both'

#Define ccLOC_Cap_Fav_NoneA				''
#Define ccLOC_Cap_Fav_LocalA			'L'
#Define ccLOC_Cap_Fav_GlobalA			'G'
#Define ccLOC_Cap_Fav_BothA				'B'

#Define ccLoc_Cap_MultSelect			' Objects'
#Define ccLoc_Cap_FoundForAll			'Only properties found for ALL objects'
#Define ccLoc_Tip_FoundForAll			'If unchecked, properties found for ANY object will be listed.'
#Define ccLOC_CMG_EditByControl1		'Edit for each control (Ctrl-Click)'
#Define ccLOC_CMG_EditByControl2		'Edit in Search Results (Ctrl-Click)'
#Define ccLOC_CMG_EditByProperty		'Edit all properties'
#Define ccLOC_CMG_Cycle					'Cycle thru values (Shift-Click)'

#Define ccLOC_Tip_Description			'Description Oriented Property Editors (DOPEs):'		+ CR + 	;
										'After the description: ' 								+ CR + 	;
										'     ListBox      *** 1 = A; 2 = B, 26 = Z ...' 		+ CR + 	;
										'     Spinner      *** Spinner 0, 255, 1' 				+ CR +  ;
										'     GetColor     *** Color'							+ CR +  ;
										'     Function     *** = SomeFunction (Parameters ... luValue)' 	+ CR +  ;
										'     Method       *** .SomeMethod ()'
#Define ccLoc_CMG_ResetSort				'Reset sort to default'										  

#Define ccLOC_Cap_Sort					'Sort on this column'
#Define ccLOC_Cap_Sort_Alpha_Reverse	'Case-insensitive sort on this column'
#Define ccLOC_Cap_Sort_Reverse			'Reverse sort on this column'

#Define ccLOC_CAP_Show_Methods			'Methods'
#Define ccLOC_Tip_Show_Methods			'Show all methods for the <insert2> (like Document View)'
#Define ccLOC_CAP_All_Controls			'All objects'
#Define ccLOC_Tip_All_Controls			'Show all objects, including those that do not have any custom methods'
#Define ccLOC_Tip_Parent				'Parent'

#Define ccLOC_CMG_EDIT_Object_Tree		'\<Edit (Click)'
#Define ccLOC_CMG_EDIT_METHOD_Tree		'\<Edit Method (Click)'
#Define ccLOC_CMG_VIEW_PARENT_Tree		'Vie\<w Parent Code (Ctrl-Click)'
#Define ccLOG_CMG_Show_TreeView			'Show TreeView (Click)'
#Define ccLOG_CMG_Hide_TreeView			'Hide TreeView'
#Define ccLOG_CMG_TreeView_ExpandChildren	'Expand child nodes (one level)'
#Define ccLOG_CMG_TreeView_ExpandAll		'Expand child nodes (all levels)'
#Define ccLOC_CAP_MDCleaner				'MemberData Cleaner:' + CR + CR	+	;
										'  - Removes entries for all inherited members' + CR + ;
										'  - Removes "dead" entries' + CR  +;
										'  - Removes "Type" attribute' + CR + CR  +;
										'Old Length = XXX' + CR	+;
										'New Length = YYY' + CR +;
										'Savings = ZZZ%' + CR + CR  +;
										'Proceed?'
#Define ccLOC_CAP_MDCleaner_Title		'PEM Editor / MemberData Cleaner'

#define ccLOC_Paste_Select				'Select'
#define ccLOC_Paste_DeSelect			'De-Select'
#define ccLOC_Paste_Paste				'Paste'
#define ccLOC_Paste_ResetSelected		'Reset Selected Items to Default'
#define ccLOC_Paste_Cancel				'Cancel'
#define ccLOC_Paste_Tip					' See also the context menu for sub-groupings. '

#define ccLOC_Paste_Properties			'Properties'
#define ccLOC_Paste_Methods				'Methods'
#define ccLOC_Paste_Events				'Events'
#define ccLOC_Paste_Methods_and_Events	'Methods and Events'
#define ccLOC_Paste_PositionAndSize		'Top, Left, Height, Width'
#define ccLOC_Paste_All					'All'

#define ccLOC_VFP_Default				'VFP default "Edit Property/Method..."'
#define ccLOC_VFP_Default_Prompt		'PEM Editor can reconfigure itself so that the next time' 		+ CR + ;
										'that you use "Edit Property/Method..." from the system' 		+ CR + ;
										'menu, you will get the VFP default.'							+ CR + CR + ;
										'(This will be for one time only.)'								+ CR + CR + ;
										'Are you ready for PEM Editor to close to accomplish this?'

#Define ccLOC_Cap_Search_Caption		'PEM Editor - Open'
#Define ccLOC_Cap_Search_ExactMatch1	'Exact Match'
#Define ccLOC_Cap_Search_ExactMatch2	'Exact Match'
#Define ccLOC_Cap_Search_LimitSearch 	'Limit searc\<h to project home directory and subfolders'
#Define ccLOC_Cap_Search_Scope 			'Sco\<pe:'
#Define ccLOC_Cap_Search_LookIn		 	'\<Look in:'
#Define ccLOC_Cap_Search_FileName 		'File Name:'
#Define ccLOC_Tip_Search_FileName 		'Enter all or part of file name'
#Define ccLOC_Cap_Search_FileTypes	 	'File Types:'
#Define ccLOC_Cap_Search_Class	 		'Class:'
#Define ccLOC_Tip_Search_Class	 		'Enter all or part of class name'
#Define ccLOC_Cap_Search_BaseClass	 	'Base Class:'
#Define ccLOC_Cap_Search_Search 		'\<Search'
#Define ccLOC_Cap_Search_CurrentFolder 	'Current Folder'
#Define ccLOC_Cap_Search_Cancel 		'Cancel'
#Define ccLOC_Cap_Search_SubFolders		'Searc\<h subfolders'
#Define ccLOC_Cap_Search_MarkAll		'Mark All'
#Define ccLOC_Cap_Search_ClearAll		'Clear All'
#Define ccLOC_Cap_Search_Tip_Drag		"Drag class '<insert>' to drop onto your form or class"

#define SCOPE_PROJECT		'P'
#define SCOPE_FOLDER		'D'


****************************************************************
#Define ccLoc_NotProportional			' ... only works for fixed-width fonts'
#Define ccLOC_Pref_Cap_AlignSpacing_1 	"1 space"
#Define ccLOC_Pref_Cap_AlignSpacing_2 	"2 spaces"
#Define ccLOC_Pref_Cap_AlignSpacing_3 	"3 spaces"
#Define ccLOC_Pref_Cap_AlignSpacing_4 	"4 spaces"
#Define ccLOC_Pref_Cap_AlignSpacing_5	"1 tab"
#Define ccLOC_Pref_Cap_AlignSpacing_6	"2 tabs"

#Define ccLOC_Pref_CAP_AlignWith 		'Align WITH keywords'
#Define ccLOC_Pref_Tip_AlignWith		'Causes WITH keywords to be aligned to the same column' + ccLoc_NotProportional

#Define ccLOC_Pref_Cap_AlignBefore		"Spacing before WITH:"
#Define ccLOC_Pref_Tip_AlignBefore		"Spacing between the longest field name and the WITH that follows."

#Define ccLOC_Pref_Cap_AlignAfter		"Spacing after WITH:"
#Define ccLOC_Pref_Tip_AlignAfter		"Spacing after each WITH phrase"

#Define ccLOC_Pref_CAP_AlignAS 			'Align AS keywords?'
#Define ccLOC_Pref_Tip_AlignAS			'Causes AS keywords to be aligned to the same column' 

#Define ccLOC_Pref_CAP_AlignASFieldBlocks	"Use blocks of AS phrases "
#Define ccLOC_Pref_Tip_AlignASFieldBlocks	"AS phrases will be alligned in blocks." + 0h0D0A + "Each block contains of a related group of fields" + 0h0D0A + "or a related group of FROM and JOINS."

#Define ccLOC_Pref_Cap_AlignBeforeAS	"Spacing before AS:"
#Define ccLOC_Pref_Tip_AlignBeforeAS	"Spacing between each field expression and the AS that follows."

#Define ccLOC_Pref_Cap_AlignAfterAS		"Spacing after AS:"
#Define ccLOC_Pref_Tip_AlignAfterAS		"Spacing after each AS phrase"

#Define ccLOC_Pref_Cap_SelectMenu 		"Indentation method"
#Define ccLOC_Pref_Cap_SelectMenu_1 	"Use native Beautify indentation"
#Define ccLOC_Pref_Cap_SelectMenu_2		"Keep original indentation"
#Define ccLOC_Pref_Cap_SelectMenu_3		"Customizable indentation (below)"
#Define ccLOC_Pref_Cap_ReplaceMenu 		"Indentation method for REPLACE"

#Define ccLOC_Pref_CAP_FixAssignments	"Align '='"
#Define ccLOC_Pref_Tip_FixAssignments	'Aligns equal signs for assignments on consecutive lines' + ccLoc_NotProportional

#Define ccLOC_Pref_CAP_AlignSemicolons	'Align semicolons'
#Define ccLOC_Pref_Tip_AlignSemicolons	'Causes semicolons to be aligned to the same column' + ccLoc_NotProportional

#Define ccLOC_Pref_Cap_SemiColonCol		"Maximum column for semicolon"
#Define ccLOC_Pref_Tip_SemiColonCol		"The rightmost column where semi-colons will be placed for alignment." + ccLoc_NotProportional

#Define ccLOC_Pref_Cap_CharsAfterSelect	"Indentation after initial SELECT"
#Define ccLOC_Pref_Tip_CharsAfterSelect	"The number of spaces after the initial SELECT, allowing alignment with following fields"

#Define ccLOC_Pref_Cap_CharsAfterSET	"Indent after SET"
#Define ccLOC_Pref_Tip_CharsAfterSET	"The number of spaces after UPDATE / SET keyword, allowing alignment with following fields"

#Define ccLOC_Pref_Cap_FieldIndent		"Indent for each new field"
#Define ccLOC_Pref_Tip_FieldIndent		"Indentation for each field that starts on a new line (meaning the previous line terminated with a comma)"

#Define ccLOC_Pref_Cap_SingleFieldIndent	"Indent for continuation of a field"
#Define ccLOC_Pref_Tip_SingleFieldIndent	"Additional indentation for continuation lines for a field (previous line did not terminate in a comma)"

#Define ccLOC_Pref_Cap_CommaOnLineStart	"Position commas separating fields at beginning of line"
#Define ccLOC_Pref_Tip_CommaOnLineStart	"Place comma on begin of line. Valid for ORDER BY, GROUP or FROM and items."

**
#Define ccLOC_Pref_Cap_SelectExpandJoin	"JOINs"
#Define ccLOC_Pref_Tip_SelectExpandJoin	"Expand each JOIN to a new line."

#Define ccLOC_Pref_Cap_SelectExpandOn	"ONs"
#Define ccLOC_Pref_Tip_SelectExpandOn	"Expand each ON to a new line."

#Define ccLOC_Pref_Cap_SelectExpandAndOr	"AND & ORs"
#Define ccLOC_Pref_Tip_SelectExpandAndOr	"Expand each AND and OR to a new line."

#Define ccLOC_Pref_Cap_SelectExpandFields	"Fields"
#Define ccLOC_Pref_Tip_SelectExpandFields	"Expand each field to a new line, special see below."

#Define ccLOC_Pref_Cap_SelectExpandSelectItem	"Select Items"
#Define ccLOC_Pref_Tip_SelectExpandSelectItem	"Expand each field defining a Select Item to a new line."

#Define ccLOC_Pref_Cap_SelectExpandFrom	"FROMs"
#Define ccLOC_Pref_Tip_SelectExpandFrom	"Expand each table in FROM clause to a new line."

#Define ccLOC_Pref_Cap_SelectExpandOrderBy	"ORDER BYs"
#Define ccLOC_Pref_Tip_SelectExpandOrderBy	"Expand each field in ORDER BY to a new line."

#Define ccLOC_Pref_Cap_SelectExpandGroupBy	"GROUP BYs"
#Define ccLOC_Pref_Tip_SelectExpandGroupBy	"Expand each field in GROUP BY to a new line."

**
#Define ccLOC_Pref_Cap_ParenIndent		"Indent for each level of parentheses"
#Define ccLOC_Pref_Tip_ParenIndent		"Additional indentation for each level of parenthesis nesting"

#Define ccLOC_Pref_Cap_ASColumn			"Maximum column for 'AS' phrase"
#Define ccLOC_Pref_Tip_ASColumn			"This is the maximum column where 'AS' phrases are placed (unless the line is too long).  Enter 0, if you want the 'AS' phrases to be aligned regardless of the length of the longest line." + ccLoc_NotProportional

#Define ccLOC_Pref_Cap_WITHColumn		"Preferred column for 'WITH'"
#Define ccLOC_Pref_Tip_WITHColumn		"NOTE: Does not work for proportional fonts"

#Define ccLOC_Pref_Cap_AfterWithColumn	"Preferred column for expression after 'WITH'"
#Define ccLOC_Pref_Tip_AfterWithColumn	"NOTE: Does not work for proportional fonts"

#Define ccLOC_Pref_CAP_SingleLineSQL	"Format single line SQL"
#Define ccLOC_Pref_Tip_SingleLineSQL	"Format SQL commands that are noted on a sinlge line."

#Define ccLOC_Pref_Cap_KeyWordIndent	"Indent for SELECT /" + 0h0D0A +;
										"UPDATE key words "
#Define ccLOC_Pref_Tip_KeyWordIndent	"Indentation for primary key words (WHERE, FROM, INTO, etc.)"

#Define ccLOC_Pref_Cap_ReplaceKeyWords	"Indent for REPLACE key words"
#Define ccLOC_Pref_Tip_ReplaceKeyWords	"Indentation for primary key words (FOR, WHILE, IN)"

#Define ccLOC_Pref_Cap_JOINIndent		"Indent for JOIN key words"
#Define ccLOC_Pref_Tip_JOINIndent		"Indentation for LEFT|RIGHT|INNER|OUTER|FULL JOINs"

#Define ccLOC_Pref_Cap_UNIONIndent		"Indent for UNION "
#Define ccLOC_Pref_Tip_UNIONIndent		"Indent for UNION keyword"
 
#Define ccLOC_Pref_Cap_SETIndent		"Indent before SET"
#Define ccLOC_Pref_Tip_SETIndent		"Indent before SET keyword on separeted line."

#Define ccLOC_Pref_Cap_SELECTIndent		"Indent for SELECT key word after UNION "
#Define ccLOC_Pref_Tip_SELECTIndent		"Indentation for SELECT key word following UNION key word," + 0h0D0A +;
										"not the whole SELECT statement. "
*SF
#Define ccLOC_Pref_Cap_SELECTIndent_01	"Indent all SELECT in UNION "
#Define ccLOC_Pref_Tip_SELECTIndent_01	"On SQL SELECT combined with UNION, " + 0h0D0A +;
										"indentation of SELECT statements. " + 0h0D0A0D0A +;
										"Additional ident for anything except UNION. "
*/SF

#Define ccLOC_Pref_Cap_HangingIndent	"Addtional indent for continuation lines"
#Define ccLOC_Pref_Tip_HangingIndent	"Indentation for continuation lines of key word phrases"

#Define ccLOC_Pref_CAP_IndentON			"Indent ON like JOIN "
#Define ccLOC_Pref_Tip_IndentON			"Move the indentation of the ON clause on the same level as the JOIN and FROM. "
#Define ccLOC_Pref_CAP_UnionIndentAlter	"Optional UNION Indentation "
#Define ccLOC_Pref_Tip_UnionIndentAlter	"Indent method for SELECT with UNIONS," + 0h0D0A +;
										'if OFF, "Indent for SELECT key word after UNION" will indent a single line after each UNION,' + 0h0D0A +;
										'if ON, "Indent all SELECT in UNION" will indent all SELECT statements except UNION.'

****************************************************************
#Define ccLOC_Pref_Cap_ToolsMenu 		"Menu for PEM Editor Tools"
#Define ccLOC_Pref_Cap_ToolsMenu_1 		"VFP main menu"
#Define ccLOC_Pref_Cap_ToolsMenu_2		"Tools menu"
#Define ccLOC_Pref_Cap_ToolsMenu_3		"<no menu>"
#Define ccLOC_Pref_Cap_ToolsMenu_4		"Maintained by THOR"
#Define ccLOC_Pref_Cap_ToolsMenuWarning "This may not take effect until you close PEM Editor and restart VFP."

#Define ccLOC_Pref_Tip_KeystrokePage	"Hot Key definitions" + CR + "Features enabled when PEM Editor does not have focus."
#Define ccLOC_Pref_CAP_Header1		    "Hot Key definitions"
#Define ccLOC_Pref_CAP_Header2		    "To activate any hot key, enter a key definition valid for ON KEY LABEL. Suggested hot keys are shown, but are not valid (due to the leading *)"
#Define ccLOC_Pref_CAP_Header2a		    "Double-click a hot key to activate / de-activate the default definition."

#Define ccLOC_Pref_Cap_KeyLaunch 		"Launch PEM Editor"
#Define ccLOC_Pref_Tip_KeyLaunch 		""

#Define ccLOC_Pref_Cap_KeyOpenMenu 		"'Open' Menu"
#Define ccLOC_Pref_Tip_KeyOpenMenu 		"Brings up the 'Open' Menu (for MRU lists, opening forms, classes, etc.) at the current cursor position."

#Define ccLOC_Pref_CAP_KeyViewDef	    "Go To Definition"
#Define ccLOC_Pref_Tip_KeyViewDef  		"Goes to the definition of the method / property / object" + CR + "that is currently highlighted."

#Define ccLOC_Pref_CAP_Back			    "Back (previous method)"
#Define ccLOC_Pref_Tip_Back		  		"Moves back to the previous method code window"

#Define ccLOC_Pref_CAP_Forward		    "Forward (next method)"
#Define ccLOC_Pref_Tip_Forward  		"Moves forward to the next method code window"

#Define ccLOC_Pref_CAP_CloseAllWindows  "Close all method windows"
#Define ccLOC_Pref_Tip_CloseAllWindows	""

#Define ccLOC_Pref_CAP_CtrlC		    "Enhanced Copy"
#Define ccLOC_Pref_Tip_CtrlC	  		"Works exactly like Ctrl+C, except that " + CR + "if NO text is highlighted, the entire line is copied."

#Define ccLOC_Pref_CAP_CtrlX	    	"Enhanced Cut"
#Define ccLOC_Pref_Tip_CtrlX  			"Works exactly like Ctrl+X, except that " + CR + "if NO text is highlighted, the entire line is cut."

#Define ccLOC_Pref_CAP_CtrlCAdditive		    "Enhanced Copy / Additive"
#Define ccLOC_Pref_Tip_CtrlCAdditive	  		"Like Ctrl+C, but text as added to _ClipText " + CR + " and if NO text is highlighted, the entire line is copied."

#Define ccLOC_Pref_CAP_CtrlXAdditive	    	"Enhanced Cut"
#Define ccLOC_Pref_Tip_CtrlXAdditive  			"Like Ctrl+X, but text as added to _ClipText " + CR + "if NO text is highlighted, the entire line is cut."

#Define ccLOC_Pref_CAP_MoveWindow	   	"Move/Resize Window"
#Define ccLOC_Pref_Tip_MoveWindow  		"Moves and/or resizes the currently active window."

#Define ccLOC_Pref_CAP_ExtractToMethod 	"Extract To Method"
#Define ccLOC_Pref_Tip_ExtractToMethod	"Extracts highlighted text into a new method and the replaces the highlighted text with a call to the new method"

#Define ccLOC_Pref_CAP_Beautify		   	"BeautifyX"
#Define ccLOC_Pref_Tip_Beautify  		"Cleans up white space; spaces around operators, custom indentations for SELECT, UPDATE, and REPLACE statements"

#Define ccLOC_Pref_CAP_Locals		   	"Create LOCAL Declarations"
#Define ccLOC_Pref_Tip_Locals  			""

#Define ccLOC_Pref_CAP_IDList		   	"External IDs List"
#Define ccLOC_Pref_Tip_IDList  			"Shows list of identifiers referenced (other than locals, parameters, and reserved words)"

#Define ccLOC_Pref_CAP_BeautifyLocals	"Create LOCALs as part of BeautifyX  "
#Define ccLOC_Pref_Tip_BeautifyLocals  	""
#Define ccLOC_Pref_CAP_LocalsAllProcs	"In PRGS, create LOCALs for ALL procedures  "
#Define ccLOC_Pref_Tip_LocalsAllProcs  	""
#Define ccLOC_Pref_Cap_SelectionofVariables 'Selection of variables'
#Define ccLOC_Pref_Cap_VarSelect1		"Lowercase 'L' variables only"
#Define ccLOC_Pref_Cap_VarSelect2		"Lowercase 'L' variables only; commented list of others"
#Define ccLOC_Pref_Cap_VarSelect3		"All variables, lowercase 'L' variables separately"
#Define ccLOC_Pref_Cap_VarSelect4		"All variables, merged"
#Define ccLOC_Pref_CAP_MultLocalsPerLine 'Multiple variables per line  '
#Define ccLOC_Pref_TIP_MultLocalsPerLine ''
#Define ccLOC_Pref_CAP_LineWidth		'Line Width'
#Define ccLOC_Pref_CAP_MoveLocals		"Move/merge LOCALs statements to top  "
#Define ccLOC_Pref_TIP_MoveLocals		"Move all LOCALs statements so that they are together at the top of the procedure and merge them with any new variables that are to be added."
#Define ccLOC_Pref_CAP_RemoveOrphanLocals		"Remove orphan LOCALs  "
#Define ccLOC_Pref_TIP_RemoveOrphanLocals		"Orphan locals are names that appear in the LOCALs list but are never assigned values. This option only takes effect if the option to Move/merge LOCALs statements to top (above) is also chosen."
#Define ccLOC_Pref_CAP_LocalsUseAS		"All variables use 'AS datatype' phrase  "
#Define ccLOC_Pref_TIP_LocalsUseAS		"All variables in the LOCALs statements are shown with the 'AS datatype', one per line, where the datatype is determined by the second letter of the variable name"

#Define ccLOC_Pref_CAP_Native_Beautify	"Apply native VFP Beautify"
#Define ccLOC_Pref_Tip_Native_Beautify	"using the current options (i.e., w/o prompting)"
#Define ccLOC_Pref_CAP_NoMultiLineSelect	" ... but preserve indentation for multi-line Selects"
#Define ccLOC_Pref_Tip_NoMultiLineSelect	"Preserves the relative indentation for multi-line SQL-Select statements"
#Define ccLOC_Pref_CAP_AddOperatorSpace	"Add space around operators"
#Define ccLOC_Pref_Tip_AddOperatorSpace	"+ - * / = # $ % < > !"
#Define ccLOC_Pref_CAP_AddCommaSpace	"Remove spaces before commas"
#Define ccLOC_Pref_Tip_AddCommaSpace	"Remove spaces before commas, add space after"

#Define ccLoc_Pref_Cap_StringDelimiters	"String Delimiters"
#Define ccLoc_Pref_Cap_DefForNOT		"Definition for NOT"
#Define ccLoc_Pref_Cap_DefForNOTEQUAL	"Definition for NOT EQUAL"
#Define ccLoc_Pref_Cap_LeftParens		"Space before left parenthesis"

#Define ccLOC_Pref_Cap_NoChange_1		' No Change'
#Define ccLOC_Pref_Cap_SingleQuote_2	" ' = single quote"
#Define ccLOC_Pref_Cap_DoubleQuote_3	' " = double quote'
#Define ccLOC_Pref_Cap_Brackets_4		' [] = Brackets'
#Define ccLOC_Pref_Cap_NOT_2			" Not"
#Define ccLOC_Pref_Cap_NOT_3			' !'
#Define ccLOC_Pref_Cap_NOTEQUAL_2		" #"
#Define ccLOC_Pref_Cap_NOTEQUAL_3		' !='
#Define ccLOC_Pref_Cap_NOTEQUAL_4		' <>'
#Define ccLOC_Pref_Cap_LeftParen_2		" Remove"
#Define ccLOC_Pref_Cap_LeftParen_3		' Add'

#Define ccLOC_Pref_Other_CAP_Locals		'Create LOCALs'
#Define ccLOC_Pref_Other_Tip_Locals		'Run the "Create LOCALs" tool in BeautifyX. See there'

#Define ccLOC_Pref_Other_CAP_MDots		'Add MDots'
#Define ccLOC_Pref_Other_Tip_MDots		'Run the "MDots" tool in BeautifyX. See there'

#Define ccLOC_Pref_Other_CAP_Returns	'Check for RETURNs between WITH/ENDWITH'
#Define ccLOC_Pref_Other_Tip_Returns	'Run the "RETURNs between WITH/ENDWITH" tool in BeautifyX. See there'

#Define ccLOC_Pref_Other_CAP_CustKey	'Apply Custom Keyword List'
#Define ccLOC_Pref_Other_Tip_CustKey	'Run the "Custom Keyword List" tool in BeautifyX. See there'

#Define ccLOC_Pref_Other_CAP_AddCustKey	'Add words to Custom Keyword List'
#Define ccLOC_Pref_Other_Tip_AddCustKey	'Add to the "Custom Keyword List" in BeautifyX. See there'

#Define ccLOC_Pref_CAP_WindowDims	    "Window Dimensions"
#Define ccLOC_Pref_Tip_WindowDims  		"For moving / resizing the current window " + CR + "Left, Top, Width, Height - in pixels " + CR + "Omitted dimensions are ignored."

#Define ccLOC_Pref_CAP_AutoMove		    "Automatically move/resize windows on opening"
#Define ccLOC_Pref_Tip_AutoMove  		""

#Define ccLOC_Title_DefNotFound			"Definition not found"
#Define ccLOC_Cap_DefNotFound			"Definition for '<insert>' not found"

#Define ccLOC_MB_ChangeClass1			"There are significant restrictions in changing "
#Define ccLOC_MB_ChangeClass2			CR + "as is noted when changing them using Property Window." + CR + CR + "Would you like to proceed with changing them anyway?"
#Define ccLOC_MB_ChangeHeaderClass		ccLOC_MB_ChangeClass1 + "MemberClass and MemberClassLibrary" + ccLOC_MB_ChangeClass2
#Define ccLOC_MB_ChangeMemberClass		ccLOC_MB_ChangeClass1 + "MemberClass and MemberClassLibrary" + ccLOC_MB_ChangeClass2


****************************************************************
****************************************************************
*********  System Menu
#Define ccLoc_SysMenu_Main				"PE\<MEditor"
#Define ccLoc_SysMenu_GoToDef			"Go To Definition"
#Define ccLoc_SysMenu_Back				"Back (previous method)"
#Define ccLoc_SysMenu_Next				"Forward (next method)"
#Define ccLoc_SysMenu_CloseAllWindows	"Close all method windows"
#Define ccLoc_SysMenu_ExtractToMethod	"Extract To Method"
#Define ccLoc_SysMenu_MoveWindow		"Move/Resize Window"
#Define ccLoc_SysMenu_CtrlC				"Enhanced Copy"
#Define ccLoc_SysMenu_CtrlX				"Enhanced Cut"
#Define ccLoc_SysMenu_CtrlCAdditive		"Enhanced Copy / Additive"
#Define ccLoc_SysMenu_CtrlXAdditive		"Enhanced Cut / Additive"
#Define ccLoc_SysMenu_Prefs				"Edit Hot Key Assignments"
#Define ccLoc_SysMenu_Beautify			"BeautifyX"
#Define ccLoc_SysMenu_Locals			"Create LOCALs"
#Define ccLoc_SysMenu_Launch			"Launch PEM Editor"
#Define ccLoc_SysMenu_LaunchDocTreeView	"Launch Document TreeView"

****************************************************************
****************************************************************
*********  Preferences form

*********     General
*********        Display
#Define ccLOC_Pref_CAP_GridAbove				'Position other objects below grid (vertical orientation)'
#Define ccLOC_Pref_Tip_GridAbove				'Positioning the other objects below the grid creates a more vertical orientation, allowing it to dock better on either the right or left.  It also looks more like the Property Window'
#Define ccLOC_Pref_Tip_GridAboveDocked			'Cannot be changed when the PEM Editor is docked.'

#Define ccLOC_Pref_Tip_UseAbbreviations			''
#Define ccLOC_Pref_CAP_UseAbbreviations			'Use abbreviations in grid columns'

#Define ccLOC_Pref_CAP_FontSize					'Overall Font Size:'
#Define ccLOC_Pref_Cap_FontSizeNote				'NOTE: changing the fontsize used by PEM Editor only takes effect after PEM Editor has been closed and re-opened.'

*********        Processing
#Define ccLOC_Pref_CAP_No_MemberData			'Allow creation of _MemberData'
#Define ccLOC_Pref_Tip_No_MemberData			''

#Define ccLOC_Pref_CAP_StayOnSamePEM	'When moving to a new object, stay on same PEM'
#Define ccLOC_Pref_Tip_StayOnSamePEM	'When moving to a new object, should the grid stay on the same PEM name?'

#Define ccLOC_Pref_CAP_ASSIGN_DEFAULT_VALUE		'Assign default value to new properties'
#Define ccLOC_Pref_Tip_ASSIGN_DEFAULT_VALUE		"Assign default value to new properties based on the first character of the property name, if it is lowercase:" + ;
	CR + CR + "'l'   for .F." + CR + "'c'   for character (blank)" + CR +  "'n', 'i', 'b' or 'y'   for numeric 0" + CR +  "'d'   for empty date" + CR +  "'t'   for empty datetime" + CR +  "'o'   for .null"

#Define ccLOC_Pref_CAP_NotifyNewPemsHidden		'Notify when new PEM will not appear in grid'
#Define ccLOC_Pref_Tip_NotifyNewPemsHidden		'Issues a reminder prompt whenever a new property or method is created and it will not show in the grid.' 		;
												+ CR + CR +;
												'This can occur if the current filters do not show the new PEM or if the grid is showing PEMs for the currently selected object, not for the <insert2>. ' 

#Define ccLOC_Pref_CAP_REMOVALPROMPT			'Prompt before removing PEMs'
#Define ccLOC_Pref_Tip_REMOVALPROMPT			''

#Define ccLOC_Pref_Cap_AutoRenamePrompt			'Prompt before auto-renaming objects'
#Define ccLOC_Pref_Tip_AutoRenamePrompt			'When auto-renaming objects, there is normally a prompt that warns that no changes will be made to any references to the objects in method code.'

#Define ccLOC_Pref_CAP_ToggleEditor	   			'Apply toggle editor for non-native logical properties'
#Define ccLOC_Pref_Tip_ToggleEditor  			'For non-native properties that have a logical value, toggle the value when you double-click on it?'

#Define ccLOC_Pref_CAP_AnchorEditor 			'Anchor Editor to use:'
#Define ccLOC_Cap_Anchor_None					'None'
#Define ccLOC_Cap_Anchor_VFP					'VFP Default'
#Define ccLOC_Cap_Anchor_AnchorBuilder			'df Anchor Builder'

#Define ccLOC_Pref_CAP_Default_Access			'Default _Access Code'
#Define ccLOC_Pref_CAP_Default_Assign			'Default _Assign Code'
					
* the code to put into the Access method
#Define ccLOC_Pref_ACCESS_CODE_Scalar			'return This.PEM_Name_Place_Holder'
#Define ccLOC_Pref_ID_Default_Access			'_Access'
#Define ccLOC_Pref_Tip_Default_Access			'Modify the default code used when creating the _Access Method for a property' + CR + CR + 'See context menu for array properties.'

#Define ccLOC_Pref_ACCESS_CODE_Array			'LParameters tnDim1, tnDim2'			 			+ CR + ;
	CR +										        	   ;
	'Do Case '								 			+ CR + ;
	CR +										        	   ;
	'    * Normal (not an array) ' 							+ CR + ;
	'    Case PCount() = 0' 							+ CR + ;
	'        return This.PEM_Name_Place_Holder' 		+ CR + ;
	CR +										        	   ;
	'    * Array, one dimension ' 			 			+ CR + ;
	'    Case PCount() = 1' 							+ CR + ;
	'        return This.PEM_Name_Place_Holder(tnDim1)' + CR + ;
	CR +										        	   ;
	'    * Array, two dimensions ' 						+ CR + ;
	'    Case PCount() = 2 ' 							+ CR + ;
	'        return This.PEM_Name_Place_Holder(tnDim1, tnDim2)' + CR + ;
	CR +										        	   ;
	'EndCase' + CR

#Define ccLOC_Pref_ID_Default_Assign	'_Assign'
#Define ccLOC_Pref_Tip_Default_Assign	'Modify the default code used when creating the _Assign Method for a property' + CR + CR + 'See context menu for array properties.'

* the code to put into the Assign method
#Define ccLOC_Pref_ASSIGN_CODE_Scalar			'lparameters tPEM_Name_Place_Holder' + Chr(13) + 'This.PEM_Name_Place_Holder = tPEM_Name_Place_Holder'
#Define ccLOC_Pref_Assign_CODE_Array			'LParameters tPEM_Name_Place_Holder, tnDim1, tnDim2'+ CR + ;
	CR +										        	   ;
	'Do Case '								 			+ CR + ;
	CR +										        	   ;
	'    * Normal (not an array) ' 							+ CR + ;
	'    Case PCount() = 1' 							+ CR + ;
	'        This.PEM_Name_Place_Holder = tPEM_Name_Place_Holder' 		+ CR + ;
	CR +										        	   ;
	'    * Array, one dimension ' 			 			+ CR + ;
	'    Case PCount() = 2' 							+ CR + ;
	'        This.PEM_Name_Place_Holder (tnDim1) = tPEM_Name_Place_Holder' + CR + ;
	CR +										        	   ;
	'    * Array, two dimensions ' 						+ CR + ;
	'    Case PCount() = 3 ' 							+ CR + ;
	'        This.PEM_Name_Place_Holder (tnDim1, tnDim2) = tPEM_Name_Place_Holder' + CR + ;
	CR +										        	   ;
	'EndCase' + CR

#Define ccLOC_CMA_Edit					'Edit default code (scalar properties)'
#Define ccLOC_CMA_Reset					'Reset to default (scalar properties)'
#Define ccLOC_CMA_EditArray				'Edit default code (array properties)'
#Define ccLOC_CMA_ResetArray			'Reset to default (array properties)'

#Define ccLOC_Pref_Cap_HandlersEnabled	'Event Handlers enabled'
#Define ccLOC_Pref_Tip_HandlersEnabled	"This enables all of the event handlers below, as well as any custom event handlers." + CR + CR + "It is also available in the right-click context menu of the combobox." + CR + CR + "The intent is to be able to temporarily disable the anchor/resize handler."

#Define ccLOC_Pref_Cap_EventResize		'Anchor/Resize handler'
#Define ccLOC_Pref_Tip_EventResize		'This changes the size/position of child objects based on the values of their Anchor properties.  Thus, changing the size of a form will change the sizes/positions of all the child objects within the form, just as they would change at run time.'

#Define ccLOC_Pref_Cap_EventCaption		'Caption handler (right-aligned)'
#Define ccLOC_Pref_Tip_EventCaption		'For checkboxes and labels that are right-aligned, keeps the right border constant when their captions change.'

#Define ccLOC_Pref_CAP_BeatifyTEXTasSelect	'Include SELECTs / UPDATEs   found within TEXT/ENDTEXT  '
#Define ccLOC_Pref_Tip_BeatifyTEXTasSelect	'Includes text within TEXT/ENDTEXT statements that begin with SELECT or UPDATE'
#Define ccLOC_Pref_CAP_IgnoreTextOperators	'Operators within TEXT/ENDTEXT' + CR + 'NOT to be surrounded by spaces'
#Define ccLOC_Pref_Tip_IgnoreTextOperators	'Some operators, such as $, may have special significance when constructing SQL Select statements, and adding spaces around them may kill the SQL statements.'
#Define ccLOC_CAP_FindObjects			;
"The search expression is executed for each object.  It is handled by EVAL(), so any valid expression will work; any non-empty result indicates a match.";
+ CR + CR + "This occurs within a WITH/ENDWITH structure, so property/method names are referred to with a leading dot (.ControlSource, .Caption, etc.)  It also occurs within a TRY/CATCH structure, so you need not check to see that the names exist." ;
+ CR + CR + "There are some auxiliary functions as well: " ;
+ CR + "     EQ(text1, text2)  ...  like = but not case sensitive" ;
+ CR + "     Contains(text1, text2)  ...  like $ but not case sensitive" ;
+ CR + "     Exists('SomeName')" ;
+ CR + "     NonDefault('SomeName')" ;
+ CR + "     HasCode('SomeName')" ;
+ CR + "     FullPathName  ...  fully qualified name for object being searched" ;
+ CR + CR + "Examples:" ;
+ CR + "     .ControlSource  ...  non-empty .ControlSources" ;
+ CR + "     NonDefault('Alignment')" ;
+ CR + "     EQ(.BaseClass, 'textbox')" ;
+ CR + "     Contains('product', .caption)" ;
+ CR + "     Contains('update', .ReadMethod('Click'))" ;
+ CR + "     Contains('.page1', FullPathName)" ;
+ CR + "     YourUDF(.ControlSource) ... Calls YourUDF, which may set properties"

****************************************************************
****************************************************************
****************************************************************
#Define ccLOC_Pref_Key_Back				"* F7"
#Define ccLOC_Pref_Key_Beautify			"* F6"
#Define ccLOC_Pref_Key_CloseAllWindows	"* Shift+F8"
#Define ccLOC_Pref_Key_CtrlC			"* Alt+C"
#Define ccLOC_Pref_Key_CtrlCAdditive	""
#Define ccLOC_Pref_Key_CtrlX			"* Ctrl+X"
#Define ccLOC_Pref_Key_CtrlXAdditive	"* Alt+X"
#Define ccLOC_Pref_Key_DoubleHash		"* F5"
#Define ccLOC_Pref_Key_ExtractToMethod	"* Ctrl+F8"
#Define ccLOC_Pref_Key_Forward			"* F8"
#Define ccLOC_Pref_Key_GoToDef			"* F12"
#Define ccLOC_Pref_Key_IDList			"* Ctrl+F6"
#Define ccLOC_Pref_Key_Locals			"* Shift+F6"
#Define ccLOC_Pref_Key_Launch			"* Alt+F12"
#Define ccLOC_Pref_Key_OpenMenu			"* Ctrl+0"
#Define ccLOC_Pref_Key_MoveWindow		"* F11"
#Define ccLoc_SortOrder1				'+cName'
#Define ccLoc_SortOrder2				[+IIF(cType = 'P', '0', IIF(lNonDefault, '1', IIF(lHasCode, '2', IIF(Not lNative, '3', '4')))) + CName]

#Define ccLOC_STR_NONE					'None'
#Define ccLOC_STR_FORECOLOR				'ForeColor'
#Define ccLOC_STR_BACKCOLOR				'BackColor'
#Define ccLOC_STR_BOLD					'Bold'
#Define ccLOC_STR_ITALIC				'Italic'
