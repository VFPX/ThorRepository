Lparameters tcCode, tlUpperCase

#Define ccTab  	Chr(9)
#Define ccLF	Chr(10)
#Define ccCR	Chr(13)
#Define ccCRLF	Chr(13) + Chr(10)

Local loRegExp As 'VBScript.RegExp'
Local lcArrayFunctions, lcArrayMatches, lcCodeBlock, lcLocal, lnFirstIndex, lnI, lnJ, loLocals
Local loMatches, loTools

* following one structure insures all CRs followed by LFs
lcCodeBlock = Strtran (Strtran (tcCode, ccCRLF, ccCR), ccCR, ccCRLF) + ' '

* tools home page = http://vfpx.codeplex.com/wikipage?title=thor%20tools%20object
loTools	 = Execscript (_Screen.cThorDispatcher, 'Class= tools from pemeditor')
loLocals = _oPEMEditor.oUtils.oBeautifyX.GetVariablesList (lcCodeBlock) && parameters, locals, and other assigned variables

If loLocals.Count = 0
	Execscript (_Screen.cThorDispatcher, 'Result=', lcCodeBlock)
Endif

Create Cursor crsr_Matches (Match N(6))
loRegExp = Createobject ('VBScript.RegExp')
With loRegExp
	.IgnoreCase	= .T.
	.Global		= .T.
	.MultiLine	= .T.
Endwith

For lnI = 1 To loLocals.Count
	lcLocal			 = loLocals (lnI)
	loRegExp.Pattern = '\W' + Iif (Lower (lcLocal) = 'm.', Substr (lcLocal, 3), lcLocal) + '(?=\W)'
	loMatches		 = loRegExp.Execute (lcCodeBlock)
	For lnJ = 0 To loMatches.Count - 1
		lnFirstIndex = loMatches.Item (lnJ).FirstIndex + 1 && add 1 to allow for leading character \W
		If Not Substr (lcCodeBlock, lnFirstIndex, 1) $ '.&'
			Insert Into crsr_Matches Values (lnFirstIndex)
		Endif
	Next lnJ
Next lnI

* note the STRTRAN use here handles line wraps so that continuation lines  ;
* for locals, parameters, etc, work as expected

lcArrayFunctions = 'aclass|acopy|adatabases|adbobjects|adir|adlls|adockstate|aerror|aevents|afields|' ;
	+ 'afont|agetclass|agetfileversion|ainstance|alanguage|alines|amembers|amouseobj|anetresources|aprinters|' ;
	+ 'aprocinfo|aselobj|asessions|asqlhandles|astackinfo|ataginfo|aused|avcxclasses'
lcArrayMatches = '\W(' + lcArrayFunctions + ')(\(|\s)*\w'

Execscript (_Screen.cThorDispatcher, 'Thor_Proc_FindNonCodeBlocks'				   ;
	, Strtran (lcCodeBlock, ';' + ccCRLF, Space(3))							   ;
	, 'crsr_NotCode'															   ;
	, [^\s*(Parameters|Lparameters|Parameter|Lparameter|Para|Lpar|Procedure|Proc|Function|Local|Private|Public|External|Declare)($|\W.*$)]  ;
	+ [|Into\s+Array\s+\w+]													   ;
	+ [|] + lcArrayMatches)

Select  Match																	   ;
	From crsr_Matches															   ;
	Join crsr_NotCode														   ;
	On Between (crsr_Matches.Match, crsr_NotCode.Start, crsr_NotCode.End)  ;
	Where Not crsr_NotCode.NotCode												   ;
	Order By Match Desc															   ;
	Into Cursor crsr_Matches

Scan
	lcCodeBlock = Stuff (lcCodeBlock, Match + 1, 0, Iif(tlUpperCase, 'M.', 'm.'))
Endscan

* Modified 18-May-2012 by TEG
* Remove MDots from left-hand side of assignments.
Local llMDotsWhereRequired
llMDotsWhereRequired  = ExecScript(_Screen.cThorDispatcher, "Get Option=", 'MDots where required', 'MDots')

If llMDotsWhereRequired

	Local laLines[1], lnLines, lnLine, lcNewBlock, lcLine, lcWordToFix, lcFixed, lcNewLine, lnEqualPos, llContinued

	lnLines = Alines(m.laLines, m.lcCodeBlock)
	lcNewBlock = ""
	llContinued = .F.

	For lnLine = 1 To m.lnLines
		lcLine = laLines[m.lnLine]
		If Not m.llContinued And "=" $ m.lcLine
			lnEqualPos = At("=", m.lcLine)
			Do Case
				Case lnEqualPos = 0
					* Nothing to change
					lcNewLine = m.lcLine
				Case Upper(Getwordnum(m.lcLine, 1)) = "FOR" and Upper(Getwordnum(m.lcLine, 2)) = "M."
					* FOR loop, so remove it.
					lcWordToFix = Substr(m.lcLine, 1, m.lnEqualPos-1)
					lcFixed = Strtran(m.lcWordToFix, "m.", "", 1, 1, 1)
					lcNewLine = m.lcFixed + Substr(m.lcLine, m.lnEqualPos)
				Case Upper(Getwordnum(m.lcLine, 1)) = "M."
					* Assignment statement
					lcWordToFix = Substr(m.lcLine, 1, m.lnEqualPos-1)
					lcFixed = Strtran(m.lcWordToFix, "m.", "", 1, 1, 1)
					lcNewLine = m.lcFixed + Substr(m.lcLine, m.lnEqualPos)
				Otherwise
					* Nothing to change
					lcNewLine = m.lcLine
			Endcase

			lcNewBlock = m.lcNewBlock + ccCR + m.lcNewLine

		Else
			* Just add the current line
			lcNewBlock = m.lcNewBlock + ccCR + m.lcLine
		Endif

		If Right(Alltrim(m.lcLine), 1) = ";"
			llContinued = .T.
		Else
			llContinued = .F.
		Endif

	Endfor

	lcCodeBlock = Substr(m.lcNewBlock, 2)

Endif

* Remove leading CRLF
Use In crsr_NotCode
Use In crsr_Matches

Execscript (_Screen.cThorDispatcher, 'Result=', Trim(lcCodeBlock, 1, ' ', ccTab)) 


