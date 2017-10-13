* This procedure analyzes the name entered to see if it looks
* like a name that would contain fields (such as This.oData
* from West Wind) and returns a result with field or property
* names to populate the listbox in IntellisenseX

* This is actually a sample, not intended to be used without customization
* to meet your specific needs. It looks for a property in the form/class 
* being edited that contains the implicit name of a table from
* which fields are to be selected.

* Local variables extracted from the parameter toParameters
* 	lcEntityName	= the full name preceding the just-entered DOT
* 	lcName       	= the text following the just-entered dot
*   					(non-empty only for IntellisenseX by hot key)
*   lcTextLeft      = full text of the line to the left of the entity name
*   loForm			= the form or class being edited (but not the current
*   					object in that form or class ... this is the top 
*						level object)
*	llForceit       = .T. if called by Intellisense by hot key

* Result may be any of:
*   .null. or logical -- no match found

*   An Object with a four dimensional array named aList:
*           aList[, 1] = Display Text (first column)
*           aList[, 2] = Second Column
*           aList[, 3] = Filter text
*           aList[, 4] = Icon file name

*   Character         -- alias for table from which fields are to be listed

*   Collection        -- collection of simple character data, each item to
*                        be displayed as a separate row. A single tab character
*                        may be used to create a two column display.

*   An Object         -- all properties, methods, and objects in the object 
*						 are displayed

Lparameters toParameters

Local lcAlias, lcEntityName, lcName, lcTextLeft, llForceit, loForm, lxResult

With toParameters

	* the full name preceding the just-entered DOT
	lcEntityName  = Lower(.cEntityName)

	* the text following the just-entered dot
	*   non-empty only for IntellisenseX by hot key
	lcName       = .cName

	* text to the left of the entity name
	lcTextLeft    = .cTextLeft

	*  the form or class being edited (but not the current
	*   object in that form or class ... this is the top level object)
	loForm	      = .oTopOfForm

	* .T. if called by Intellisense by hot key
	llForceit     = .lForceIt

Endwith

*******************************************************************************
***  End of setup section
*******************************************************************************

#Define PROPERTYNAME 'cAlias'
#Define ccTab Chr[9]

Do Case
	Case Vartype(loForm) # 'O'
		lcAlias = .F.

	Case lcEntityName == 'thisform.obusobj.odata'
		lcAlias = GetTableAlias(loForm, PROPERTYNAME, .T.)

	Case lcEntityName == 'this.obusobj.odata'
		lcAlias = GetTableAlias(loForm, PROPERTYNAME, .T.)

	Case lcEntityName == 'this.odata'
		lcAlias = GetTableAlias(loForm, PROPERTYNAME)

	Case lcEntityName == '@'
		lcAlias = GetTableAlias(loForm, PROPERTYNAME, .T.)

	Otherwise
		lcAlias = .F.

Endcase

Return Execscript(_Screen.cThorDispatcher, 'Result=', lcAlias)



Procedure GetTableAlias(loForm, tcPropertyName, tlCurrentAlias)
	* If property <tcPropertyName> exists in object <loForm>, 
	* calls plug-in <PEME_OpenTable> to select or open the table
	* with that alias.

	* If this does not result in the desired table, and if
	* <tlCurrentAlias> is .T., tries to use the current table

	Local lcAlias

	If Pemstatus(loForm, tcPropertyName, 5) And Vartype(loForm.&tcPropertyName) = 'C'
		lcAlias = loForm.&tcPropertyName
		If Empty(lcAlias) And Lower(loForm.Name) = 'bo_'
			lcAlias = Substr(loForm.Name, 4)
		Endif
	Else
		lcAlias = .F.
	Endif

	If Empty(lcAlias) And tlCurrentAlias And Not Empty(Alias())
		lcAlias = Alias()
	Endif

	Return lcAlias

Endproc

