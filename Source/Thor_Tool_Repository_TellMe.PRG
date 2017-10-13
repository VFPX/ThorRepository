Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1						  ;
		And 'O' = Vartype (lxParam1)  ;
		And 'thorinfo' == Lower (lxParam1.Class)

	With lxParam1
	
		* Required
		.Prompt		   = 'Inspect properties of object under mouse' && used in menus
		
		* Optional
		Text to .Description NoShow && a description for the tool
Inspect major properties of object under mouse, and conditionally save into the clipboard

Can only be used by hot key.

See also tool "Insert full name of object under mouse".
		EndText 
		.StatusBarText = ''  
		.CanRunAtStartUp = .F.

		* These are used to group and sort tools when they are displayed in menus or the Thor form
		.Category      = 'Objects and PEMs' && creates categorization of tools; defaults to .Source if empty
		.Sort		   = 0 && the sort order for all items from the same Category
		
		* For public tools, such as PEM Editor, etc.
		.Author        = 'Andy Kramek, Copyright (c) 2002 Tightline Computers Ltd, All Rights Reserved'
		
	Endwith

	Return lxParam1
Endif

If Pcount() = 0
	Do ToolCode
Else
	Do ToolCode With lxParam1
Endif

Return

****************************************************************
****************************************************************
* Normal processing for this tool begins here.                  
Procedure ToolCode
	Lparameters lxParam1

	***********************************************************************
	* Program....: TELLME.PRG
	* Author.....: Andy Kramek
	* Date.......: 31 August 2002
	* Notice.....: Copyright (c) 2002 Tightline Computers Ltd, All Rights Reserved
	* Compiler...: Visual FoxPro 08.00.0000.1916
	* Purpose....: Details of the control under the mouse pointer
	***********************************************************************


	#Define CRLF Chr(13) + Chr(10)
	*** Get the object reference
	Local lcClib as String, ;
	lcClass as String, ;
	lcFile as String, ;
	lcLoc as String, ;
	lcParLib as String, ;
	lcParent as String, ;
	lcSource as String, ;
	lcStr as String, ;
	lnSave as Number, ;
	loObj as Object, ;
	loParent as Object

	loObj    = Sys( 1270 )

	If Vartype( m.loObj ) # "O"
	    Return
	Endif

	*** Get the associated information from the reference
	lcClass  = m.loObj.Class
	lcCLib   = m.loObj.ClassLibrary
	*** SYS(1271) gets us the File name
	lcFile = Sys( 1271, m.loObj )
	lcLoc = Sys(1272, m.loObj )
	If Type( "loObj.Parent" ) = "O" And Not Isnull( m.loObj.Parent )
	    loParent = m.loObj.Parent
	    lcParent = Alltrim( m.loParent.Class ) + "::" + Alltrim( m.loParent.Name )
	    lcParLib = Alltrim( m.loParent.ClassLibrary )
	Else
	    lcParent = ""
	    lcParLib = ""
	Endif
	lcSource = Iif( Pemstatus( m.loObj, 'controlsource', 5 ), Alltrim( m.loObj.ControlSource ), "" )
	If Empty( m.lcSource )
	    lcSource = Iif( Pemstatus( m.loObj, 'recordsource', 5 ), Alltrim( m.loObj.RecordSource ), "" )
	Endif
	*** Build the string
	lcStr = ""
	lcStr = m.lcStr + "Object: " + Alltrim( m.loObj.Name ) + CRLF
	lcStr = m.lcStr + "Class: " + Alltrim( m.lcClass ) + CRLF
	lcStr = m.lcStr + "ClassLib: " + Alltrim( m.lcCLib ) + CRLF
	lcStr = m.lcStr + "Location: " + Alltrim( m.lcLoc ) + CRLF
	lcStr = m.lcStr + Iif( Empty( m.lcSource ), "", "Source: " + Alltrim( m.lcSource ) + CRLF)
	lcStr = m.lcStr + Iif( Empty( m.lcParent ), "", "Parent: " + Alltrim( m.lcParent ) + CRLF)
	lcStr = m.lcStr + Iif( Empty( m.lcParLib ), "", "ClassLib: " + Alltrim( m.lcParLib )) + CRLF
	lcStr = m.lcStr + Iif( Empty( m.lcFile ), "", "SCX File: " + Alltrim( m.lcFile ))
	*** Display it
	lnSave = Messagebox( m.lcStr, 36, "Save Details to ClipBoard?" )
	If m.lnSave = 6
	** Save it 
	    _Cliptext = m.lcStr
	endif


EndProc 
