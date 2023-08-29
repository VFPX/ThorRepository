Lparameters tcText

#Define 	CR 		Chr[13]
#Define		LF		Chr[10]
#Define 	Tab 	Chr[9]

Local loAddWordstoCKL As 'clsAddWordstoCKL'
Local laKeywords[1], lcCursor, lcForm

loAddWordstoCKL  = Createobject('clsAddWordstoCKL')
loAddWordstoCKL.Process(tcText)
loAddWordstoCKL.PostProcessing()

*!* ******************** Removed 2/6/2014 *****************
*!* lcCursor = loAddWordstoCKL.cResultCursor
*!* Select Keyword, Sum(1) From (lcCursor) Into Array laKeywords Group By 1 Order By 2 Desc
*!* Use In (lcCursor)

*!* lcForm = Execscript(_Screen.cThorDispatcher, 'Full Path= Thor_Proc_UpdateKeywordList.SCX')
*!* Do Form (lcForm) With laKeywords

Return


* --------------------------------------------------------------------------------
* --------------------------------------------------------------------------------

Define Class clsAddWordstoCKL As Custom
	cDelimiters		   = ''
	cAllKeywordsCursor = ''
	lPostProcessing	   = .T.
	oBeautify		   = Null
	cTextMarker		   = ''

	Procedure Init
		This.CreateAllKeywordsCursor()
		This.GetDelimiters()
	Endproc


	Procedure CreateAllKeywordsCursor
		This.cAllKeywordsCursor = 'KeywordList' + Sys(2015)
		Create Cursor (This.cAllKeywordsCursor) (Keyword C(60))
	Endproc


	Procedure ProcessText(tcText, tlShowAll, tlFresh)
		* --------------------------------------------------------------------------------
		*	Remove all comments, character strings, and # lines
		* 	Also gotta have CRLF's for next FindNoneCodeBlocks to work
		Local lcCursor, lcText, lcWord, lnI, lnLength
		If Empty(tcText)
			Return
		Endif

		lcText	 = Strtran(Strtran(tcText, CR + LF, CR), CR, CR + LF)
		lcCursor = Sys(2015)
		Execscript (_Screen.cThorDispatcher, 'Thor_Proc_FindNonCodeBlocks', lcText, lcCursor)

		Scan For NotCode
			lnLength = 2 + End - Start
			lcText	 = Stuff(lcText, Start, lnLength, Space(lnLength))
		Endscan
		Use In (lcCursor)

		* --------------------------------------------------------------------------------
		*	Blank out all non-word characters
		lcText		 = Chrtran(lcText, This.cDelimiters, Replicate(' ', Len(This.cDelimiters)))

		If tlFresh
			This.CreateAllKeywordsCursor()
		Endif

		* and build cursor of all words, except single character or all lower case
		For lnI = 1 To Getwordcount(lcText)
			lcWord = Getwordnum(lcText, lnI)
			If Len(lcWord) > 1 And (tlShowAll Or (lcWord # Lower(lcWord) and lcWord # Upper(lcWord))) And Not Isdigit(lcWord)
				Insert Into (This.cAllKeywordsCursor) Values (lcWord)
			Endif
		Endfor
	Endproc


	Procedure ProcessArray(laArray, tlShowAll)
		Local lcWord, lnI
		For lnI = 1 To Alen(laArray, 1)
			lcWord = Trim(laArray[lnI, 1])
			If Len(lcWord) > 1 And (tlShowAll Or (lcWord # Lower(lcWord) And lcWord # Upper(lcWord)))
				Insert Into (This.cAllKeywordsCursor) Values (lcWord)
			Endif
		Endfor
	Endproc


	Procedure CreateResultsCursor(tcDestAlias, tlShowAll)
		Local lcLastUpper, lcOldWord, lcWord, loKeywordList
		Create Cursor (tcDestAlias) (OldValue C(60), NewValue C(60), Change L)
		Select  Upper,															;
				Cast(This.CountUpperCase(Keyword) As N(4))    As  NUppers,		;
				Count,															;
				Keyword															;
			From (Select  Upper(Keyword)    As  Upper,							;
						  Keyword,												;
						  Sum(1)            As  Count							;
					  From (This.cAllKeywordsCursor)							;
					  Group By 1, 2)                             As  T			;
			Order By Upper, NUppers Desc, Count									;
			Having NUppers > 0													;
			Into Cursor crsr_Counts

		lcLastUpper	  = ''
		loKeywordList = This.GetISXOptions()
		Scan
			If lcLastUpper == Upper
				Loop
			Endif
			lcLastUpper = Upper

			lcWord = Alltrim(Keyword)
			If loKeywordList.IsReservedWord(lcWord)
				Loop
			Endif

			lcOldWord = loKeywordList.Fixcase(lcWord)
			Do Case
				Case Empty(lcOldWord)
					Insert Into (tcDestAlias) (NewValue, Change) Values (lcWord, Not lcWord == Lower(lcWord))
				Case loKeywordList.IsLocked(lcWord)

				Case This.CountUpperCase(lcWord) > This.CountUpperCase(lcOldWord)
					Insert Into (tcDestAlias) (OldValue, NewValue, Change) Values (lcOldWord, lcWord, .T.)
				Case tlShowAll
					Insert Into (tcDestAlias) (OldValue, NewValue, Change) Values (lcOldWord, lcWord, .F.)
			Endcase
		Endscan

		Use
		Use In (This.cAllKeywordsCursor)
		Select(tcDestAlias)
	Endproc


	Procedure OpenFormForEditing(lcSourceAlias, tlAddNewWithoutPrompting)
		Local lcForm, loKeywordList
		Local Custom
		lcForm = Execscript(_Screen.cThorDispatcher, 'Full Path= Thor_Proc_UpdateKeywordList.SCX')

		Select  *							;
			From (lcSourceAlias)			;
			Where Not Empty(OldValue)		;
			Into Cursor crsr_UpdateKCL
		If _Tally # 0
			Do Form (lcForm) With 'crsr_UpdateKCL', 'Update existing items in Custom Keyword List (' + Transform(_Tally) + ')'
		Endif

		Select  *						;
			From (lcSourceAlias)		;
			Where Empty(OldValue)		;
			Into Cursor crsr_NewKCL

		Do Case
			Case _Tally = 0

			Case tlAddNewWithoutPrompting
				loKeywordList = This.GetISXOptions()
				Scan
					loKeywordList.UpdateWord(Alltrim(NewValue), .T.)
				Endscan
			Otherwise
				Do Form (lcForm) With 'crsr_NewKCL', 'Add new items to Custom Keyword List (' + Transform(_Tally) + ')', .T.
		Endcase

		Use In (lcSourceAlias)
	Endproc


	Procedure CountUpperCase(tcText)
		#Define UPPERCASECHARS 'ABCDEFGHIJKLMNOPQRSTUVXWYZ'
		Return Len(tcText) - Len(Chrtran(tcText, UPPERCASECHARS, ''))
	Endproc


	Procedure GetDelimiters
		Local lcChar, lnI
		This.cDelimiters = ''
		For lnI = 0 To 127
			lcChar = Chr[lnI]
			If Isalpha(lcChar) Or Isdigit(lcChar) Or lcChar = '_'

			Else
				This.cDelimiters = This.cDelimiters + lcChar
			Endif
		Endfor
	Endproc


	Procedure GetISXOptions
		Local loISXOptions
		loISXOptions = Execscript (_Screen.cThorDispatcher, 'Thor_Proc_GetISXOptions')
		Return loISXOptions.oKeyWordList
	Endproc


	Procedure Process(toData)

		*-- The passed toData object will contain cFilename and the propertied from the
		*-- entire Rowfrom the table (if it was a scx, vcx, frx).
		*-- If it was a prg, it will contain the entire prg code in the cCode property.

		Local lcExtension, lcVfpData

		lcExtension = Upper(Justext(toData.cFileName))
		Do Case

			Case lcExtension = 'SCX' Or lcExtension = 'VCX'
				This.ProcessText(toData.Methods)
				This.ProcessText(toData.ObjName)

				If Not Empty(toData.Properties)
					This.ProcessText(Strextract(toData.Properties, 'controlsource', Chr[13], 1, 3))
					lcVfpData = Strextract(toData.Properties, '<VFPData>', '</VFPData>')
					lcVfpData = Strtran(lcVfpData, ["], ' ')
					This.ProcessText(lcVfpData)
				Endif

			Case lcExtension = 'FRX'
				This.ProcessText(toData.Expr + ' ' + toData.SupExpr)

			Case lcExtension = 'PRG'
				This.ProcessText(toData.Code)

			Otherwise

		Endcase

	Endproc


	Procedure PostProcessing(tlShowAll, tlAddNewWithoutPrompting)

		Local lcCursorName
		If Not This.lPostProcessing
			Return
		Endif

		lcCursorName = 'AddWordsToCKL' + Sys(2015)
		Use In (Select(lcCursorName))
		This.CreateResultsCursor(lcCursorName, tlShowAll)
		This.OpenFormForEditing(lcCursorName, tlAddNewWithoutPrompting)

	Endproc


	* --------------------------------------------------------------------------------
	* --------------------------------------------------------------------------------

	Procedure ApplyCKL
		Lparameters tcText
		* Applies the Custom Keyword List to a character string
		*  (assumed to be a block of code from an edit window)

		#Define Numeric1 Chr(1) + Chr(0) + Chr(0) + Chr(0)
		#Define Numeric2 Chr(2) + Chr(0) + Chr(0) + Chr(0)
		#Define Numeric3 Chr(3) + Chr(0) + Chr(0) + Chr(0)
		#Define Numeric4 Chr(4) + Chr(0) + Chr(0) + Chr(0)

		#Define		Delimiters	' ' + Tab + CR + LF
		#Define		ccTool 	'Apply Custom Keyword List to code window'
		#Define 	ccKey 	'Text/EndText'

		Local lcKeyWordList, lcNewText, lcOptions, lcText, llTextEndText, loBeautify
		Local loKeywordList

		llTextEndText = Execscript(_Screen.cThorDispatcher, 'Get Option=', ccKey, ccTool)
		If llTextEndText
			This.cTextMarker = Sys(2015)
			lcText			 = This.MarkTextEndText(tcText, This.cTextMarker)
		Else
			lcText = tcText
		Endif

		*!* ******************** Removed 2/9/2014 ********************
		*!* loKeywordList = This.GetISXOptions()
		*!* lcKeyWordList = loKeywordList.GetKeywordList()
		lcKeyWordList = This.GetKeywordList(lcText)
		*!* ******************** End of duplicated text ********************
		lcText		  = lcKeyWordList + lcText

		* Options to select first occurrence for Keywords and nothing else
		lcOptions =			;
			Numeric3 +		;
			Numeric4 +		;
			Numeric4 +		;
			Numeric3 +		;
			Numeric1 +		;
			Numeric1 +		;
			Numeric1 +		;
			Numeric1 +		;
			Numeric1

		If Isnull(This.oBeautify)
			This.oBeautify = Execscript(_Screen.cThorDispatcher, 'Class= cBeautify of PEME_BEAUTIFYCODE.PRG')
		Endif

		If This.oBeautify.Execute(@lcText, lcOptions)
			lcNewText = Substr(lcText, Len(lcKeyWordList) + 1)
			If llTextEndText
				lcNewText = Strtran(lcNewText, This.cTextMarker, '', 1, 9999)
			Endif

			If This.StripWhiteSpace(lcNewText) = This.StripWhiteSpace(tcText)
				Return Execscript(_Screen.cThorDispatcher, 'Result= ', lcNewText)
			Else
				Return Execscript(_Screen.cThorDispatcher, 'Result= ', -1)
			Endif
		Else
			Return Execscript(_Screen.cThorDispatcher, 'Result= ', .F.)
		Endif
	Endproc


	Procedure StripWhiteSpace
		Lparameters lcCode
		Return Lower(Chrtran(lcCode, ' ' + Tab + Chr[10], ''))
	Endproc


	Procedure MarkTextEndText(lcText, lcTextMarker)
		Local lcLowerText, lnI, lnPOs
		lcLowerText = Lower(lcText)
		For lnI = 1 To 10000
			lnPOs = Rat('text', Lower(lcLowerText), lnI)
			Do Case
				Case lnPOs = 0
					Exit
				Case Not Substr(lcText, lnPOs + 4, 1) $ Delimiters

				Case Substr(lcText, lnPOs - 1, 1) $ Delimiters
					lcText = Stuff(lcText, lnPOs + 4, 0, lcTextMarker)
				Case lnPOs > 4 And Substr(lcText, lnPOs - 4, 1) $ Delimiters And Lower(Substr(lcText, lnPOs - 3, 3)) = 'end'
					lcText = Stuff(lcText, lnPOs + 4, 0, lcTextMarker)
			Endcase

		Endfor
		Return lcText
	Endproc


	Procedure GetKeywordList(tcText)
		Local laMatches[1], lcResult, lnI

		lcResult = ''
		This.ProcessText(tcText, .T.)
		This.OpenMyKeywordList()
		Select  KeywordList.Keyword											;
			From (Select  Distinct Upper(Keyword)    As  Keyword			;
					  From (This.cAllKeywordsCursor))    As  Results		;
				Join KeywordList											;
					On Results.Keyword = Upper(KeywordList.Keyword)			;
			Into Array laMatches
		For lnI = 1 To _Tally
			lcResult = lcResult + Trim(laMatches[lnI]) + CR + LF
		Endfor
		Return lcResult
	Endproc

	Procedure OpenMyKeywordList
		Local lcFileName, lcToolFolder, loException
		lcToolFolder = Execscript(_Screen.cThorDispatcher, 'Tool Folder=')
		lcFileName	 = Addbs(lcToolFolder) + 'My Tools\KeywordList.DBF'
		If File (lcFileName)
			Try
				Use (lcFileName) In 0 Order Keyword Again Shared
			Catch To loException
				Messagebox('Unable to open Customer Keywords Table' + Chr(13) + Chr(13) + loException.Message + Chr(13) + Chr(13) + lcFileName, 16, 'Unable to open Custom Keywords Table')
			Endtry
		Else
			Create Table (lcFileName) (Keyword C(60))
			Index On Upper(Keyword) Tag Keyword
		Endif
	Endproc



	* --------------------------------------------------------------------------------
	* --------------------------------------------------------------------------------


Enddefine
