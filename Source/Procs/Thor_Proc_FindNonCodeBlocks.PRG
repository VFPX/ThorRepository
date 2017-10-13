#Define ccTab  	Chr(9)
#Define ccLF	Chr(10)
#Define ccCR	Chr(13)
#Define ccCRLF	Chr(13) + Chr(10)

Lparameters lcCodeBlock, lcAlias, lcDelimiters

* Creates a cursor which identifies blocks of text that are not code ... comments or character

Local loRegExp As 'VBScript.RegExp'
Local lcClosingChar, lcValue, lnFirstIndex, lnI, lnLength, loMatch, loMatches

loRegExp = Createobject ('VBScript.RegExp')
With loRegExp
	.IgnoreCase	= .T.
	.Global		= .T.
	.MultiLine	= .T.
Endwith

loRegExp.Pattern = [(^\s*(\*|\#).*$|\&\&.*$|'|"|] + '\[|\]' + Iif (Empty (lcDelimiters), '', '|' + lcDelimiters) + ')'
* next line takes care of continuation lines of comments
lcCodeBlock		 = Strtran(lcCodeBlock, ';' + ccCR + ccLF, '   ', 1, -1)
loMatches		 = loRegExp.Execute (lcCodeBlock)

Create Cursor (lcAlias) (Start N(8), End N(8), NotCode L)
Insert Into (lcAlias) (Start) Values (1)
For lnI = 1 To loMatches.Count
	loMatch		 = loMatches.Item (lnI - 1)
	lnFirstIndex = loMatch.FirstIndex
	lcValue		 = loMatch.Value
	Replace End With lnFirstIndex
	lcClosingChar = lcValue
	Do Case
		Case lcValue = '['
			If IsNameChar (Right (Trim (Left (lcCodeBlock, lnFirstIndex)), 1))
				Loop
			Endif
			lcClosingChar = ']'
		Case lcValue $ ['"]

		Case lcValue = ']'
			Loop
		Otherwise
			lnLength = Len (lcValue) + Iif (Right (lcValue, 1) $ ccCRLF, 0, 1)
			Insert Into (lcAlias) (Start, End, NotCode) Values (lnFirstIndex + 1, lnFirstIndex + lnLength, .T.)
			Insert Into (lcAlias) (Start) Values (lnFirstIndex + lnLength + 1)
			Loop
	Endcase
	Insert Into (lcAlias) (Start) Values (lnFirstIndex + 1)
	If lcClosingChar $ ['"] + ']'
		Replace NotCode With .T.
		For lnI = lnI + 1 To loMatches.Count
			lcValue = Alltrim(loMatches.Item (lnI - 1).Value, ' ', ccTab, ccCR, ccLF)
			If lcValue = lcClosingChar Or lcValue = '#'
				loMatch		 = loMatches.Item (lnI - 1)
				lnFirstIndex = loMatch.FirstIndex
				lcValue		 = loMatch.Value
				Replace End With lnFirstIndex
				Insert Into (lcAlias) (Start) Values (lnFirstIndex + 1)
				Exit
			Endif
		Endfor
	Endif
Endfor

Replace End With Len(lcCodeBlock)

Return


Procedure IsNameChar
	Lparameters lcChar

	Return Isalpha (lcChar) Or Isdigit (lcChar) Or lcChar = '_'
Endproc


