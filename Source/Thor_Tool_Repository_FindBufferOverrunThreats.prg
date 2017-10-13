Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1								;
		And 'O' = Vartype(m.lxParam1)		;
		And 'thorinfo' == Lower(m.lxParam1.Class)

	With m.lxParam1

		* Required
		.Prompt		   = 'Find Buffer Overrun Threats'

		* Optional
		Text To .Description Noshow 
Prompts for a project or folder to search, and looks for possible buffer overrun threats.

Buffer overruns blow away your session just like C5 errors.  They occur if you have a long parameters list (> 255 characters, including all characters) when using a tool such as PEM Editor or IntellisenseX.
		Endtext
		.StatusBarText	 = ''
		.CanRunAtStartUp = .F.

		* These are used to group and sort tools when they are displayed in menus or the Thor form
		.Category = 'Applications' && creates categorization of tools; defaults to .Source if empty
		.Link	  = 'https://vfpx.codeplex.com/wikipage?title=Thor%20TWEeT%2023'

		* For public tools, such as PEM Editor, etc.
		.Author	   = 'Jim Nelson'

	Endwith

	Return m.lxParam1
Endif

If Pcount() = 0
	Do ToolCode
Else
	Do ToolCode With m.lxParam1
Endif

Return

****************************************************************
****************************************************************
* Normal processing for this tool begins here.                  
Procedure ToolCode
	Lparameters lxParam1

	#Define 	MaxLength 	250
	#Define 	Tab 		Chr[9]
	#Define 	CR 			Chr[13]
	#Define 	LF 			Chr[10]
	#Define 	DoubleAmps ('&' + '&')


	Local loOverruns As 'clsFindOverrunThreats'
	loOverruns = Newobject('clsFindOverrunThreats')
	If Execscript(_Screen.cThorDispatcher, 'Thor_Proc_ScopeProcessor', m.loOverruns)
		Goto top in (m.loOverruns.cAlias)
		Execscript(_Screen.cThorDispatcher, 'Thor_Proc_SuperBrowse', m.loOverruns.cAlias)
	Else
		Messagebox('No buffer over-run threats found', 64, 'None found')
	Endif
Endproc



Define Class clsFindOverrunThreats As Custom
	cAlias = ''

	Procedure Init
		This.cAlias = 'FindOverrunThreats' + Sys(2015)
		Create Cursor (This.cAlias) (FileName c(100), ObjectName c(100), Lineno N(6), Threat c(200))
		Index on Upper(FileName) tag FileName

	Procedure Process(toData)

		*-- The passed toData object will contain cFilename and the propertied from the
		*-- entire Rowfrom the table (if it was a scx, vcx, frx).
		*-- If it was a prg, it will contain the entire prg code in the cCode property.

		Local lcExtension, lcFileName, loThreats

		lcFileName	= m.toData.cFileName
		lcExtension	= Upper(Justext(m.lcFileName))
		Do Case
			Case m.lcExtension = 'PRG'
				loThreats = This.FindThreats(m.toData.Code)
				If m.loThreats.Count > 0
					This.AddThreats(m.loThreats, m.lcFileName)
				Endif

			Case m.lcExtension = 'SCX'
				loThreats = This.FindThreats(m.toData.Methods)
				If m.loThreats.Count > 0
					This.AddThreats(m.loThreats, m.lcFileName, m.toData.ObjName)
				Endif

			Case m.lcExtension = 'VCX'
				loThreats = This.FindThreats(m.toData.Methods)
				If m.loThreats.Count > 0
					This.AddThreats(m.loThreats, m.lcFileName, Iif(Empty(m.toData.Parent), '', m.toData.Parent + '.') + m.toData.ObjName)
				Endif

		Endcase

	Endproc


	Procedure PostProcessing

	Endproc


	Procedure FindThreats
		Lparameters lcCodeBlock

		Local loLinePositions As 'Collection'
		Local laLines[1], lcFirstWord, lcFullLine, lcLine, lnI, lnLineCount, lnStartIndex

		loLinePositions	= Createobject('Collection')
		If Len(m.lcCodeBlock) > MaxLength
			lnLineCount		= Alines(laLines, m.lcCodeBlock)
			For lnI = 1 To m.lnLineCount
				lnStartIndex = m.lnI
				lcLine		 = m.laLines[m.lnI]
				lcFullLine	 = m.lcLine
				Do While This.IsContinuation(m.lcLine) And m.lnI < m.lnLineCount
					lnI		   = m.lnI + 1
					lcLine	   = m.laLines[m.lnI]
					lcFullLine = m.lcFullLine + CR + LF + m.lcLine
				Enddo

				lcFirstWord	= Upper(Getwordnum(m.lcFullLine, 1))
				Do Case
					Case Len(m.lcFullLine) <= MaxLength

					Case Len(m.lcFirstWord) < 4

					Case m.lcFirstWord = 'PROCEDURE' And '(' $ m.lcFullLine
						m.loLinePositions.Add(This.AddItem(m.lnStartIndex, m.lcFullLine))

					Case m.lcFirstWord = 'FUNCTION' And '(' $ m.lcFullLine
						m.loLinePositions.Add(This.AddItem(m.lnStartIndex, m.lcFullLine))

					Case m.lcFirstWord = 'LPARAMETERS'
						m.loLinePositions.Add(This.AddItem(m.lnStartIndex, m.lcFullLine))

					Case m.lcFirstWord = 'PARAMETERS'
						m.loLinePositions.Add(This.AddItem(m.lnStartIndex, m.lcFullLine))

				Endcase
			Endfor && lnI = 1 to lnLineCount
		Endif && Len(m.lcCodeBlock) > MaxLength

		Return m.loLinePositions

	Endproc


	* ================================================================================ 
	* ================================================================================ 
	Procedure AddItem(lnStartIndex, lcFullLine))
		Local loResult As 'Empty'
		loResult = Createobject('Empty')
		AddProperty(m.loResult, 'LineNo', m.lnStartIndex)
		AddProperty(m.loResult, 'ThreatLine', m.lcFullLine)
		Return m.loResult
	Endproc



	* ================================================================================ 
	* ================================================================================ 
	Procedure IsContinuation(lcLine)
		If DoubleAmps $ m.lcLine
			lcLine = Left(m.lcLine, At(DoubleAmps, m.lcLine) - 1)
		Endif
		Return Right(Trim(m.lcLine), 1) = ';'
	Endproc


	* ================================================================================ 
	* ================================================================================ 
	Procedure AddThreats(loThreats, lcFileName, lcObjectName)
		Local lcThreatLine, lnI, lnLineNo
		For lnI = 1 To m.loThreats.Count
			lnLineNo	 = m.loThreats.Item[m.lnI].Lineno
			lcThreatLine = m.loThreats.Item[m.lnI].ThreatLine
			Insert Into (This.cAlias)						;
				(FileName, Lineno, ObjectName, Threat)		;
				Values										;
				(m.lcFileName, m.lnLineNo, Evl(m.lcObjectName, ''), m.lcThreatLine)
		Endfor
	Endproc

Enddefine
