* Returns a collection indicating the beginning of each procedure / class / etc
* Each member in the collection has these properties:
*   .Type == 'Procedure' (Procedures and Functions)
*         == 'Class'     (Class Definition)
*         == 'End Class' (End of Class Definition)
*         == 'Method'    (Procedures and Functions within a class)
*   .StartByte == starts at zero; thus, # of chars preceding start position
*   .Name
*   .ClassName

****************************************************************

#Include FoxPro.h

#Define ccTab  	Chr(9)
#Define ccLF	Chr(10)
#Define ccCR	Chr(13)
#Define ccCRLF	Chr(13) + Chr(10)

Lparameters tcCode

Local loObject As 'Empty'
Local loRegExp As 'VBScript.RegExp'
Local loResult As 'Collection'
Local lcClassName, lcDelim, lcLine, lcMatch, lcName, lcParentClass, lcParentClassLoc, lcPattern
Local lcType, lcWord1, llClassDef, llTextEndText, lnI, lnStartByte, loException, loMatches
Local illTextEndText

loRegExp = Createobject ('VBScript.RegExp')
With loRegExp
	.IgnoreCase	= .T.
	.Global		= .T.
	.MultiLine	= .T.
Endwith

lcPattern = 'PROC(|E|ED|EDU|EDUR|EDURE)\s+(\w|\.)+'
lcPattern = lcPattern + '|' + 'FUNC(|T|TI|TIO|TION)\s+(\w|\.)+'
lcPattern = lcPattern + '|' + 'DEFINE\s+CLASS\s+\w+'
lcPattern = lcPattern + '|' + 'DEFI\s+CLAS\s+\w+'
lcPattern = lcPattern + '|' + 'ENDD(E|EF|EFI|EFIN|EFINE)\s+'
lcPattern = lcPattern + '|' + 'PROT(|E|EC|ECT|ECTE|ECTED)\s+\w+\s+\w+'
lcPattern = lcPattern + '|' + 'HIDD(|E|EN)\s+\w+\s+\w+'

With loRegExp
	.Pattern	= '^\s*(' + lcPattern + ')'
Endwith

loMatches = loRegExp.Execute (tcCode)
****************************************************************

loResult = Createobject ('Collection')

llClassDef		 = .F. && currently within a class?
illTextEndText	 = .F. && currently within a Text/EndText block?
lcClassName		 = ''
lcParentClass	 = ''
lcParentClassLoc = ''

For lnI = 1 To loMatches.Count

	* .Value
	* .FirstIndex
	* .Length
	With loMatches.Item (lnI - 1)
		lnStartByte	= .FirstIndex
		lcMatch		= Chrtran (.Value, ccCR + ccLF, '  ')
		lcName		= Getwordnum (lcMatch, Getwordcount (lcMatch))
		lcWord1		= Upper (Getwordnum (lcMatch, Max(1, Getwordcount (lcMatch) - 1)))
	Endwith

	* ignore leading CRLF's
	Do While Substr (tcCode, lnStartByte + 1, 1) $ ccCR + ccLF
		lnStartByte = lnStartByte + 1
	Enddo

	loObject = Createobject ('Empty')
	AddProperty (loObject, 'Type')
	AddProperty (loObject, 'StartByte')
	AddProperty (loObject, 'Name')
	AddProperty (loObject, 'ClassName')
	AddProperty (loObject, 'ParentClass')
	AddProperty (loObject, 'ParentClassLoc')

	Do Case
		Case llTextEndText
			If 'ENDTEXT' = lcWord1
				llTextEndText = .F.
			Endif
			Loop

		Case llClassDef
			If 'ENDDEFINE' = lcWord1
				llClassDef	= .F.
				lcType		= 'End Class'
				lcName		= lcClassName + '.-EndDefine'
				lcClassName	= ''
			Else
				lcType = 'Method'
				lcName = lcClassName + '.' + lcName
			Endif

		Case 'CLASS' = lcWord1
			llClassDef	= .T.
			lcType		= 'Class'
			lcClassName	= lcName

			lcLine		  = Chrtran(Substr(tcCode, lnStartByte + 1, 200), ccCR + ccLF, '  ')
			lcParentClass = Getwordnum(lcLine, 5)
			If 'OF' == Upper(Getwordnum(lcLine, 6))
				lcParentClassLoc = Getwordnum(lcLine, 7)
				lcDelim			 = Left(lcParentClassLoc, 1)
				Do Case
					Case lcDelim $ ['"]
						lcParentClassLoc = Strextract(lcParentClassLoc, lcDelim, lcDelim)
					Case lcDelim = '['
						lcParentClassLoc = Strextract(lcParentClassLoc, '[', ']')
				Endcase
			Else
				lcParentClassLoc = ''
			Endif

		Otherwise
		
			lcType = 'Procedure'

	Endcase

	With loObject
		.StartByte		= lnStartByte
		.Type			= lcType
		.Name			= lcName
		.ClassName		= lcClassName
		.ParentClass	= lcParentClass
		.ParentClassLoc	= lcParentClassLoc
	Endwith

	Try
		loResult.Add (loObject, lcName)
	Catch To loException When loException.ErrorNo = 2062
		loResult.Add (loObject, lcName + ' ' + Transform (lnStartByte))
	Catch To loException
		ShowErrorMsg(loException)
	Endtry


Endfor

Execscript(_Screen.cThorDispatcher, 'Result=', loResult)

Return




Procedure ShowErrorMsg
	Lparameters loException

	Messagebox ('Error: ' + Transform (loException.ErrorNo) 	+ ccCRLF +		;
		  'Message: ' + loException.Message 					+ ccCRLF +		;
		  'Procedure: ' + loException.Procedure 				+ ccCRLF +		;
		  'Line: ' + Transform (loException.Lineno) 			+ ccCRLF +		;
		  'Code: ' + loException.LineContents									;
		  , MB_OK + MB_ICONEXCLAMATION, 'Error')
Endproc
