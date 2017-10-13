* For a block of code (presumably a procedure, but it could be an entire PRG)
*   returns a collection giving the line numbers for all RETURN statements
*   between WITH / ENDWITH blocks
*
* Handles embedded WITH/ENDWITH statements, line wraps, TEXT/ENDTEXT, etc

#Define DoubleAmps 	'&' + '&'
#Define ccTab		Chr[9]

Lparameters lcCodeBlock

Local loResult As 'Collection'
Local laLines[1], lcFirstWord, lcLine, llInText, lnI, lnLines, lnPOs, lnTryDepth, lnWithDepth

lnWithDepth	= 0
lnTryDepth	= 0
llInText	= .F.

lnLines	 = Alines(laLines, Chrtran(lcCodeBlock, ccTab + '(', '  '))
loResult = Createobject('Collection')

For lnI = 1 To lnLines
	lcLine = laLines[lnI]

	* Get the entire line, including continuation lines, handling ';' before '&&'
	Do While .T.
		lnPOs = At(DoubleAmps, lcLine)
		If lnPOs > 0
			lcLine = Trim(Left(lcLine, lnPOs - 1))
		Endif
		If ';' = Right(lcLine, 1) And lnI < lnLines
			lnI	   = lnI + 1
			lcLine = lcLine + ' ' + laLines[lnI]
		Else
			Exit
		Endif
	Enddo

	lcFirstWord = Getwordnum(lcLine, 1)

	Do Case

		Case Len(lcFirstWord) < 4 And Not Upper(lcFirstWord) == 'TRY'

		Case llInText And Atc(lcFirstWord, 'EndText') = 1
			llInText = .F.

		Case llInText

		Case Atc(lcFirstWord, 'Text') = 1
			llInText = .T.

		Case Atc(lcFirstWord, 'With') = 1
			lnWithDepth = lnWithDepth + 1

		Case Atc(lcFirstWord, 'EndWith') = 1
			lnWithDepth = lnWithDepth - 1

		Case Atc(lcFirstWord, 'Try') = 1
			lnTryDepth = lnTryDepth + 1

		Case Atc(lcFirstWord, 'EndTry') = 1
			lnTryDepth = lnTryDepth - 1

		Case Atc(lcFirstWord, 'Return') = 1 And (lnWithDepth > 0 Or lnTryDepth > 0)
			loResult.Add(lnI)

	Endcase

Endfor

Return Execscript(_Screen.Cthordispatcher, 'Result=', loResult)
