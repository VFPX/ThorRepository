* To create additional options on the "Picker" page (top right),
* use the defined constant "AdditionalOptions"; separate the options with "|"
*
* Options should be brief as only about 15 characters fit
*
* Options are processed by method "MakeResultString".   Since there
* are six options by default, the first new option corresponds to
* a value of seven.

* There already is code here as a sample for the first new option. Try 
*   #Define AdditionalOptions 'AddCol()'

#Define AdditionalOptions ''


#Define CrLf Chr(13)+Chr(10)
#Define Tab  Chr(9)
#Define illegalchar Chr(124)

#Define cnFieldName 	3
#Define cnFieldType 	4
#Define cnFieldWidth 	5
#Define cnFieldDecimals	6
#Define cnFieldDesc		7


Define Class ResultString As Custom

	* Property to add additional options (separated by '|')
	cExtraOptions		= AdditionalOptions

	* Global properties, set by calling routine (properties on SuperBrowse form)
	nReturnType			= 1
	nLanguage			= 1
	nCaseSelection		= 1
	nBeautifyCaseOption	= 1
	lUseNVL				= .F.
	nCursor				= 1
	cTarget				= ''
	cAlias				= ''
	cPrefix				= ''
	nCastType			= 1
	lCommaFirst			= .F.
	lCloseAfter			= .F.
	lFrom				= .F.

	* Local properties, used like local variables
	cResult		= ''
	cSemiColon	= ';'
	cTabs		= ''
	nFieldCount	= 0
	Dimension aFieldsList[1]


	Procedure MakeResultString

		This.cResult	= ''
		This.cSemiColon	= Iif(This.nLanguage = 1, [;], [])

		Do Case
			Case This.nReturnType = 1
				This.GetFieldsResult(.F.)

			Case This.nReturnType = 2
				This.GetSelectResult()

			Case This.nReturnType = 3
				This.GetUpdateResult()

			Case This.nReturnType = 4
				This.GetInsertResult()

			Case This.nReturnType = 5 && Create
				This.GetCreateResult()

			Case This.nReturnType = 6 && Browse
				This.GetBrowseResult()

			Case This.nReturnType = 7 && AddCols
				This.GetAddColsResult()

		Endcase

		Return This.cResult

	Endproc


	* ================================================================================

	Procedure GetFieldsResult(tlUseTabs)

		Local lcAStext, lcCast1, lcCast2, lcField, lcFieldName, lcNvl1, lcNvl2, lcPrefix, lcTabs, lcType, lcTypeLength, lnI
		lcPrefix = Iif(Empty(This.cPrefix), '', Trim(This.cPrefix) + [.])
		lcTabs	 = Iif(m.tlUseTabs, This.cTabs, '')

		For lnI = 1 To This.nFieldCount
			lcFieldName	 = This.GetFieldName(m.lnI)
			lcField		 = m.lcPrefix + m.lcFieldName
			lcType		 = This.GetFieldType(m.lnI)
			lcTypeLength = Alltrim(Substr(This.GetFieldDesc(m.lnI), 2))
			lcNvl2		 = [,] + This.GetEmptyValue(m.lcType) + [)]
			If This.lUseNVL
				lcNvl1 = This.ChangeCaseOfString([nvl(])
				lcNvl2 = This.ChangeCaseOfString(m.lcNvl2)
			Else
				lcNvl1 = []
				lcNvl2 = []
			Endif
			This.MakeCastString(m.lcFieldName, m.lcType, m.lcTypeLength, @m.lcCast1, @m.lcCast2)
			If This.lUseNVL Or This.nCastType # 1
				lcAStext = This.ChangeCaseOfString([ as ]) + m.lcFieldName
			Else
				lcAStext = []
			Endif

			If m.lnI = 1
				This.AddText(m.lcCast1 + m.lcNvl1 + m.lcField + m.lcNvl2 + m.lcCast2 + m.lcAStext)
			Else
				If This.lCommaFirst
					This.AddText(This.cSemiColon + CrLf + m.lcTabs + [,] + m.lcCast1 + m.lcNvl1 + m.lcField + m.lcNvl2 + m.lcCast2 + m.lcAStext)
				Else
					This.AddText([,] + This.cSemiColon + CrLf + m.lcTabs + m.lcCast1 + m.lcNvl1 + m.lcField + m.lcNvl2 + m.lcCast2 + m.lcAStext)
				Endif
			Endif
		Endfor
	Endproc


	* ================================================================================

	Procedure GetSelectResult
		Local lcString
		This.AddText(This.ChangeCaseOfString([Select ]))

		This.GetFieldsResult(.T.)

		If This.lFrom
			This.AddText(This.cSemiColon + CrLf + This.cTabs + This.ChangeCaseOfString([From ]) + This.cAlias + Iif( ;
					Empty(This.cPrefix) Or Lower(Alltrim(This.cPrefix)) == Lower(Alltrim(This.cAlias)) ;
					, [], This.ChangeCaseOfString([ as ]) + Alltrim(This.cPrefix)))
		Endif

		If Not Empty(This.cTarget)
			If This.nCursor >= 2
				This.AddText(This.cSemiColon + CrLf + This.cTabs + This.ChangeCaseOfString([into cursor ]))
			Else
				This.AddText(This.cSemiColon + CrLf + This.cTabs + This.ChangeCaseOfString([into table ]))
			Endif
			This.AddText(Alltrim(This.cTarget))
			If This.nCursor = 3
				This.AddText(This.ChangeCaseOfString([ readwrite]))
			Endif
		Endif

		If This.lCloseAfter And Not Empty(This.cAlias)
			This.AddText(CrLf + This.ChangeCaseOfString([use in select(']) + This.cAlias + [')])
		Endif
	Endproc


	* ================================================================================

	Procedure GetUpdateResult
		Local lcComma, lcFieldName, lcFieldType, lcSet, lnI
		This.GetLocalAssignments()
		This.AddText(This.ChangeCaseOfString([Update ] + This.cAlias) + This.cSemiColon + CrLf)
		For lnI = 1 To This.nFieldCount
			lcFieldName	= This.GetFieldName(m.lnI)
			lcFieldType	= Lower(This.GetFieldType(m.lnI))

			lcSet		= Iif(m.lnI = 1, [Set ], '')
			This.AddText(This.cTabs + m.lcSet + m.lcFieldName + [ = l] + m.lcFieldType + m.lcFieldName)

			lcComma = Iif(m.lnI < This.nFieldCount, [,] + This.cSemiColon, [])
			This.AddText(m.lcComma + CrLf)
		Endfor
	Endproc


	* ================================================================================

	Procedure GetInsertResult
		Local lcFieldName, lcFieldType, lcFields, lcVar, lnI
		This.GetLocalAssignments()
		This.AddText(This.ChangeCaseOfString([Insert Into ] + This.cAlias + [ (]) + This.cSemiColon + CrLf)
		lcVar	 = ''
		lcFields = ''
		For lnI = 1 To This.nFieldCount
			lcFieldName	= This.GetFieldName(m.lnI)
			lcFieldType	= Lower(This.GetFieldType(m.lnI))
			lcVar		= m.lcVar + This.cTabs + [l] + m.lcFieldType + m.lcFieldName
			lcFields	= m.lcFields + This.cTabs + m.lcFieldName
			If m.lnI < This.nFieldCount
				lcVar	 = m.lcVar + [,] + This.cSemiColon + CrLf
				lcFields = m.lcFields + [,] + This.cSemiColon + CrLf
			Else
				lcVar	 = m.lcVar + [)]
				lcFields = m.lcFields + [);] + CrLf
			Endif
		Endfor
		This.AddText(m.lcFields + This.cTabs + This.ChangeCaseOfString([Values (;]) + CrLf + m.lcVar)
	Endproc


	* ================================================================================

	Procedure GetLocalAssignments
		Local lcFieldType, lcFieldName, lnI
		For lnI = 1 To This.nFieldCount
			lcFieldName	= This.GetFieldName(m.lnI)
			lcFieldType	= Lower(This.GetFieldType(m.lnI))
			This.AddText([l] + m.lcFieldType + m.lcFieldName + [ = ] + This.GetEmptyValue(m.lcFieldType) + CrLf)
		Endfor
	Endproc


	* ================================================================================

	Procedure GetCreateResult

		Local lcFieldType, lcNVL, lcShortFieldType, lnI, lnWidth1, lnWidth2
		lcNVL = Iif(This.lUseNVL, [ null], [])
		If This.nCursor >= 2
			This.AddText(This.ChangeCaseOfString([Create cursor ]) + Alltrim(This.cTarget) + [(] + This.cSemiColon + CrLf)
		Else
			This.AddText(This.ChangeCaseOfString([Create table ]) + Alltrim(This.cTarget) + [(] + This.cSemiColon + CrLf)
		Endif

		lnWidth1 = 1
		lnWidth2 = 1
		For lnI = 1 To This.nFieldCount
			lnWidth1 = Max(m.lnWidth1, Len(This.GetFieldName(m.lnI)))
			lnWidth2 = Max(m.lnWidth2, Len(This.GetFieldDesc(m.lnI)))
		Endfor
		For lnI = 1 To This.nFieldCount
			lcShortFieldType = This.GetFieldType(m.lnI)
			If This.nLanguage = 1
				lcFieldType = Left(This.GetFieldDesc(m.lnI), m.lnWidth2)
			Else
				lnWidth2 = Max(m.lnWidth2, 13)
				Do Case
					Case m.lcShortFieldType = [C]
						lcFieldType = [char] + Substr(This.GetFieldDesc(m.lnI), 2)
					Case m.lcShortFieldType = [N]
						lcFieldType = [numeric] + Substr(This.GetFieldDesc(m.lnI), 2)
					Case Inlist(m.lcShortFieldType, [D], [T])
						lcFieldType = [datetime]
					Case m.lcShortFieldType = [M]
						lcFieldType = [varchar(max)]
					Case m.lcShortFieldType = [L]
						lcFieldType = [bit]
					Case m.lcShortFieldType = [Y]
						lcFieldType = [money]
					Case m.lcShortFieldType = [B]
						lcFieldType = [bit]
					Case m.lcShortFieldType = [F]
						lcFieldType = [float]
					Case m.lcShortFieldType = [I]
						lcFieldType = [integer]
				Endcase
				lcFieldType = Padr(m.lcFieldType, m.lnWidth2)

			Endif
			This.AddText(This.cTabs + Padr(This.GetFieldName(m.lnI), m.lnWidth1) + [  ] + m.lcFieldType + m.lcNVL)
			If m.lnI < This.nFieldCount
				This.AddText([,] + This.cSemiColon + CrLf)
			Else
				This.AddText([)])
			Endif
		Endfor
	Endproc


	* ================================================================================

	Procedure GetBrowseResult
		Local lnI
		This.AddText(This.ChangeCaseOfString([Browse Fields ]) + This.cSemiColon + CrLf)
		For lnI = 1 To This.nFieldCount
			This.AddText(This.cTabs + This.GetFieldName(m.lnI))
			If m.lnI < This.nFieldCount
				This.AddText([,] + This.cSemiColon + CrLf)
			Endif
		Endfor
	Endproc


	* ================================================================================
	
	Procedure GetAddColsResult
		Local lcExec, lcFieldName, lcText, lcType, lnDecimals, lnI, lnWIdth
		This.AddText('With This' + CRLF + CRLF)
		This.AddText(Tab + 'lnBackColor = 0' + CRLF + CRLF)
		For lnI = 1 To This.nFieldCount
	
			lcFieldName	= Trim(This.GetFieldName(m.lnI))
			lcType		= This.GetFieldType(m.lnI)
			lnWIdth		= This.GetFieldWidth(m.lnI)
			lnDecimals	= This.GetFieldDecimals(m.lnI)
	
			lcExec = '^' + m.lcFieldName
	
			Do Case
	
				Case m.lcType = 'C'
					lcText = ".AddCol('" + m.lcExec + "', -" + Thorn (m.lnWIdth) + ", '" + m.lcFieldName + "', 'Char', 0, lnBackColor)"
	
				Case m.lcType = 'D'
					lcText = ".AddDateCol('" + m.lcExec + "', -10, '" + m.lcFieldName + "', 'Char', 0, lnBackColor)"
	
				Case m.lcType = 'T'
					lcText = ".AddCol('" + m.lcExec + "', -16, '" + m.lcFieldName + "', 'Char', 0, lnBackColor)"
	
				Case m.lcType = 'L'
					lcText = ".AddCol('" + m.lcExec + "', -8, '" + m.lcFieldName + "', 'YesNo', 0, lnBackColor)"
					lcText = m.lcText + CRLF + Tab + ".ColumnAlign('C')"
	
				Otherwise
					lcText = ".AddCol('" + m.lcExec + "', -" + Thorn (m.lnWIdth) + ", '" + m.lcFieldName + "', 'Num', 0, lnBackColor" ;
						+ Iif (m.lnDecimals = 0, ", '9')", ", '9." + Thorn (m.lnDecimals) + "')")
			Endcase
	
			This.AddText(Tab + m.lcText + CRLF + CRLF)
	
		Endfor
	
		This.AddText('EndWith')
	Endproc
	
	
	* ================================================================================
	* ================================================================================
	
	
	Procedure AddText(tcText)
		This.cResult = This.cResult + m.tcText
	Endproc


	Procedure ChangeCaseOfFieldName
		Lparameters tcText

		Local lcText
		lcText = _Screen.oISXOptions.oKeyWordList.FixCase(m.tcText, .F.)
		Do Case
			Case Not Empty(m.lcText)

			Case This.nCaseSelection = 1
				lcText = Lower (m.tcText)
			Case This.nCaseSelection = 2
				lcText = Upper (m.tcText)
			Case This.nCaseSelection = 3
				lcText = Proper (m.tcText)
			Case This.nCaseSelection = 4
				lcText = Lower (Left (m.tcText, 1)) + Proper (Substr (m.tcText, 2))
			Otherwise
				lcText = m.tcText
		Endcase

		Return m.lcText
	Endproc


	Procedure ChangeCaseOfString
		Lparameters tcText, tlFieldName

		Local lcText
		Do Case
			Case Isnull (This.nBeautifyCaseOption)
				lcText = This.ChangeCaseOfFieldName (m.tcText)
			Case This.nBeautifyCaseOption = 1
				lcText = Lower (m.tcText)
			Case This.nBeautifyCaseOption = 2
				lcText = Upper (m.tcText)
			Otherwise
				lcText = Proper (m.tcText)
		Endcase

		Return m.lcText
	Endproc


	Procedure GetFieldName(tnRow)
		Return Trim(This.ChangeCaseOfFieldName(This.aFieldsList[m.tnRow, cnFieldName]))
	Endproc


	Procedure GetFieldType(tnRow)
		Return This.aFieldsList[m.tnRow, cnFieldType]
	Endproc


	Procedure GetFieldWidth(tnRow)
		Return This.aFieldsList[m.tnRow, cnFieldWidth]
	Endproc


	Procedure GetFieldDecimals(tnRow)
		Return This.aFieldsList[m.tnRow, cnFieldDecimals]
	Endproc


	Procedure GetFieldDesc(tnRow)
		Return Trim(This.aFieldsList[m.tnRow, cnFieldDesc])
	Endproc


	Procedure GetEmptyValue(tcType)
		Local lcReturn, lcType
		lcType = Upper(m.tcType)
		Do Case
			Case Inlist(m.lcType, [C], [Q], [M], [W], [V], [G])
				lcReturn = [""]
			Case Inlist(m.lcType, [Y], [N], [I], [B], [F])
				lcReturn = [0]
			Case Inlist(m.lcType, [L])
				lcReturn = [.F.]
			Case Inlist(m.lcType, [D])
				lcReturn = [{}]
			Case Inlist(m.lcType, [T])
				lcReturn = [{-:}]
		Endcase
		Return m.lcReturn

	Endproc


	Procedure MakeCastString
		Lparameters tcFieldName, tcType, tcTypeLength, lcCast1, lcCast2
		Local lcFieldName, lcType, lcTypeLength
		lcFieldName	 = m.tcFieldName
		lcType		 = m.tcType
		lcTypeLength = m.tcTypeLength

		Do Case
			Case This.nCastType = 1
				lcCast1	= []
				lcCast2	= []
			Case This.nCastType = 2
				lcCast1	= [Cast(]
				Do Case
					Case m.lcType = [C]
						lcCast2 = [ As C] + m.lcTypeLength + [)]
					Case m.lcType = [N]
						lcCast2 = [ As N] + m.lcTypeLength + [)]
					Case m.lcType = [I]
						lcCast2 = [ As I)]
					Case m.lcType = [L]
						lcCast2 = [ As L)]
					Case m.lcType = [W]
						lcCast2 = [ As W)]
					Case m.lcType = [Q]
						lcCast2 = [ As Q] + m.lcTypeLength + [)]
					Case m.lcType = [V]
						lcCast2 = [ As V] + m.lcTypeLength + [)]
					Case m.lcType = [D]
						lcCast2 = [ As D)]
					Case m.lcType = [F]
						lcCast2 = [ As F] + m.lcTypeLength + [)]
					Case m.lcType = [G]
						lcCast2 = [ As G)]
					Case m.lcType = [Y]
						lcCast2 = [ As Y)]
					Case m.lcType = [T]
						lcCast2 = [ As T)]
					Case m.lcType = [B]
						lcCast2 = [ As B] + m.lcTypeLength + [)]
					Case m.lcType = [M]
						lcCast2 = [ As M)]
				Endcase
			Case This.nCastType = 3
				lcCast1	= [Cast(]
				Do Case
					Case m.lcType = [C]
						lcCast2 = [ As Character] + m.lcTypeLength + [)]
					Case m.lcType = [N]
						lcCast2 = [ As Numeric] + m.lcTypeLength + [)]
					Case m.lcType = [I]
						lcCast2 = [ As Integer)]
					Case m.lcType = [L]
						lcCast2 = [ As Logical)]
					Case m.lcType = [W]
						lcCast2 = [ As Blob)]
					Case m.lcType = [Q]
						lcCast2 = [ As Varbinary] + m.lcTypeLength + [)]
					Case m.lcType = [V]
						lcCast2 = [ As Varchar] + m.lcTypeLength + [)]
					Case m.lcType = [D]
						lcCast2 = [ As Date)]
					Case m.lcType = [F]
						lcCast2 = [ As Float] + m.lcTypeLength + [)]
					Case m.lcType = [G]
						lcCast2 = [ As General)]
					Case m.lcType = [Y]
						lcCast2 = [ As Currency)]
					Case m.lcType = [T]
						lcCast2 = [ As Datetime)]
					Case m.lcType = [B]
						lcCast2 = [ As Double)]
					Case m.lcType = [M]
						lcCast2 = [ As Memo)]
				Endcase

				lcCast1	= This.ChangeCaseOfString([Cast(])
				lcCast2	= This.ChangeCaseOfString(m.lcCast2)
		Endcase
	Endproc


Enddefine