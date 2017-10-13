Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1                          ;
        And 'O' = Vartype (lxParam1)  ;
        And 'thorinfo' == Lower (lxParam1.Class)

    With lxParam1
   
        * Required
        .Prompt           = 'Split a procedure file' && used in menus
       
        * Optional
        Text to .Description NoShow && a description for the tool
Splits a specified procedure file into separate PRGs, with one for each procedure in the file.
        EndText
        .StatusBarText = ''
        .CanRunAtStartUp = .F.

        * These are used to group and sort tools when they are displayed in menus or the Thor form
        .Source           = '' && where did this tool come from?  Your own initials, for instance
        .Category      = 'Applications' && creates categorization of tools; defaults to .Source if empty
        .Sort           = 0 && the sort order for all items from the same Category
       
        * For public tools, such as PEM Editor, etc.
        .Version       = '' && e.g., 'Version 7, May 18, 2011'
        .Author        = 'Tamar E. Granor'
        .Link          = '' && link to a page for this tool
        .VideoLink     = '' && link to a video for this tool
       
    Endwith

    Return lxParam1
Endif

If Pcount() = 0
    Do ToolCode
Else
    Do ToolCode With lxParam1
Endif

Wait Clear

Return

****************************************************************
****************************************************************
* Normal processing for this tool begins here.                  
Procedure ToolCode
    Lparameters lxParam1

* Split a procedure file into one file
* per procedure, using the procedure name
* as the file name. 

LOCAL cProcFile, aProcs[1], nProcs, nProc, cProcName
LOCAL cPath, cContent, nStartProc, nEndProc, aProcLines[1], nTotalLines
LOCAL cProcText, nLine, cFileName, lProceed
LOCAL cMessage
LOCAL cDirectives
Local cLine, cWord2, nAdjust
Local cDestFolder

cProcFile = GETFILE("prg","File name", "Split", 0, "Select procedure file to split")
cDestFolder	= Getdir(JustPath(cProcFile))
IF NOT EMPTY(m.cProcFile) AND file(m.cProcFile) and not Empty(cdestFolder)
    cPath = m.cDestFolder   
    nProcs = APROCINFO(aProcs, m.cProcFile)
   
    * Read the whole file and split it in lines
    cContent = FILETOSTR(m.cProcFile)
    nTotalLines = ALINES(aProcLines, m.cContent)
   
    * Collect all compiler directives as top of file
    * for insertion into all new files
    cDirectives = ''
    nProc = 1
    DO WHILE nProc <= m.nProcs AND aProcs[m.nProc,3] = "Directive"
        cDirectives = aProcLines[aProcs[m.nProc,2]] + CHR(13) + CHR(10)
        nProc = m.nProc + 1
    ENDDO
   
    FOR nProc = 1 TO m.nProcs
        * Look only at procs and functions. Don't include methods
        IF aProcs[m.nProc, 3] = "Procedure" AND ;
           NOT ("." $ aProcs[m.nProc, 1])
            cProcName = aProcs[m.nProc, 1]
            cFileName = FORCEPATH(FORCEEXT(m.cProcName, "prg"), m.cPath)
            * Prompt if we have an existing file
            IF FILE(m.cFileName)
                cMessage = m.cFileName + " already exists. Overwrite it?"
                IF MESSAGEBOX(m.cMessage, 4 + 32, "Overwrite existing program?") = 6
                    lProceed = .T.
                ELSE
                    lProceed = .F.
                ENDIF
            ELSE
                lProceed = .T.
            ENDIF
       
            IF m.lProceed
                nStartProc = aProcs[m.nProc, 2]
               
                * Make sure we have the actual PROC or FUNC line.
                * There's a bug in AProcInfo() that sometimes specifies
                * the first line as too low down.
                nStartProc = FindDefLine(m.cProcName, m.nStartProc, aProcs[m.nProc,3], @aProcLines)
   
                * Search backward for comment lines
                DO WHILE nStartProc > 1 AND (EMPTY(aProcLines[m.nStartProc-1]) OR LEFT(aProcLines[m.nStartProc-1],1) = "*")
                    nStartProc = m.nStartProc - 1
                ENDDO

                IF m.nProc < m.nProcs
                    * Find actual start of next proc
                    nEndProc = FindDefLine(aProcs[m.nProc + 1, 1], aProcs[m.nProc+1, 2], aProcs[m.nProc+1, 3], @aProcLines) - 1
               
                ELSE
                    nEndProc = m.nTotalLines
                ENDIF

                * Search backward to ignore trailing comment lines
                DO WHILE nEndProc > m.nStartProc AND (EMPTY(aProcLines[m.nEndProc]) OR LEFT(aProcLines[m.nEndProc],1) = "*")
                    nEndProc = m.nEndProc -1
                ENDDO
                   
               
                * Now grab the relevant lines
                cProcText = m.cDirectives
                FOR nLine = m.nStartProc TO m.nEndProc
                    cProcText = m.cProcText + aProcLines[m.nLine] + CHR(13) + CHR(10)
                ENDFOR
               
                * Save
            Wait Window m.cFileName Nowait
                STRTOFILE(m.cProcText, m.cFileName, 0)
            ENDIF
        ENDIF
    ENDFOR
   
ENDIF

RETURN
       
EndProc

* ================================================================================

PROCEDURE FindDefLine(cProcName, nStartsOn, cType, aProcLines)
* Find the actual line on which the specified proc starts.
* It may be nStartsOn, but due to a bug in AProcInfo, might
* be an earlier line.
 
LOCAL cLine, cWord2, nAdjust
LOCAL cDefinitionCondition

DO CASE
CASE m.cType = 'Procedure'
    cDefinitionCondition = [NOT INLIST(LEFT(m.cLine,4),"PROC","FUNC") OR NOT (m.cWord2 == UPPER(m.cProcName))]

CASE m.cType = 'Class'
    cDefinitionCondition = [NOT ("DEFI"$GETWORDNUM(m.cLine,1) AND m.cWord2 == "CLASS") ];
                           + [OR NOT GETWORDNUM(m.cLine,3) == UPPER(ALLTRIM(STREXTRACT(m.cProcName,'', 'AS')))]
   
CASE m.cType = 'Directive'
    cDefinitionCondition = [NOT (LEFT(m.cLine,1) = "#" ] + ;
                           [OR NOT INLIST(GETWORDNUM(m.cLine,1), "INCLUDE", "IF", "ELIF", "ELSE", "ENDIF", "IFDEF", "IFNDEF", "UNDEF"))]
   
CASE m.cType = 'Define'
    cDefinitionCondition = [NOT (LEFT(m.cLine,1) = "#" OR NOT (m.cWord2 == UPPER(m.cProcName)))]
ENDCASE

nAdjust = 0
cLine = UPPER(ALLTRIM(aProcLines[m.nStartsOn]))
cWord2 = GETWORDNUM(m.cLine,2)
IF "(" $ m.cWord2
    cWord2 = STREXTRACT(m.cWord2, '', '(')
ENDIF
DO WHILE &cDefinitionCondition
    nAdjust = m.nAdjust + 1
    cLine = UPPER(aProcLines[m.nStartsOn - m.nAdjust])
    cWord2 = GETWORDNUM(m.cLine,2)
    IF "(" $ m.cWord2
        cWord2 = STREXTRACT(m.cWord2, '', '(')
    ENDIF
ENDDO  

RETURN m.nStartsOn - m.nAdjust            
