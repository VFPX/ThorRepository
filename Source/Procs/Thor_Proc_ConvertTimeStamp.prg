*  Thor_Proc_ConvertTimeStamp
*
*  AUTHOR: Richard A. Schummer            September 1994
*
*  Integrted with Thor 2011-11-04 by Matt Slay
*
*
*  COPYRIGHT (c) 1994-2001    Richard A. Schummer
*     42759 Flis Dr  
*     Sterling Heights, MI  48314-2850
*     RSchummer@CompuServe.com
*
*  METHOD DESCRIPTION: 
*!* *{ MJP -- 2014/12/01 13:46:40 - Begin
*!* *     This procedure handles the conversion of the FoxPro TIMESTAMP field to 
*!* *     a readable (and understandable) date and time.  The procedure will return
*!* *     the date/time in three formats based on the cStyle parameter.  Timestamp 
*!* *     field is a 32-bit (numeric compressed) system that the FoxPro development
*!* *     team created to save on file space in the projects, screens, reports, and
*!* *     label databases.  This field is used to determine if objects need to be 
*!* *     recompiled (project manager), or syncronized across platforms (screens,
*!* *     reports, and labels).
*     This procedure handles the conversion of the FoxPro TIMESTAMP field to 
*     a readable (and understandable) date and time.  The procedure will return
*     the date/time as a VFP DateTime value.  Timestamp field is a 32-bit
*     (numeric compressed) system that the FoxPro development team created to
*     save on file space in the projects, screens, reports, and label databases.
*     This field is used to determine if objects need to be recompiled (project
*     manager), or syncronized across platforms (screens, reports, and labels).
*!* *} MJP -- 2014/12/01 13:46:40 - End
* 
*  CALLING SYNTAX: 
*!* *{ MJP -- 2014/12/01 13:48:06 - Begin
*!* *     <variable> = Thor_Proc_ConvertTimeStamp(<nTimeStamp>)
*     <variable> = (<nTimeStamp>,<cStyle>)
*!* *} MJP -- 2014/12/01 13:48:06 - End
*
*     Sample:
*!* *{ MJP -- 2014/12/01 13:49:08 - Begin
*!* *     ltDateTime = ctrMetaDecode.TimeStamp2Date(TimeStamp,"DATETIME")
*     ltDateTime = Thor_Proc_ConvertTimeStamp(TimeStamp)
*!* *} MJP -- 2014/12/01 13:49:08 - End
* 
*  INPUT PARAMETERS: 
*     nTimeStamp = Required field, must be numeric, no check to verify the
*                  data passed is valid FoxPro Timestamp, just be sure it is
*!* MJP -- Removed 2014/12/01 13:49:42
*!* *     cStyle     = Not required (defaults to "DATETIME"), must be character, 
*!* *                  and must be one of the following:
*!* *                   "DATETIME" will return the date/time in MM/DD/YY HH:MM:SS
*!* *                   "DATE"     will return the date in MM/DD/YY format
*!* *                   "TIME"     will return the time in HH:MM:SS format
*
*  OUTPUT PARAMETERS:
*!* *{ MJP -- 2014/12/01 13:49:55 - Begin
*!* *     lcRetval    = The date/time (in requested format) is returned in 
*!* *                   character type.  Must be converted and parsed to be
*!* *                   used as date type.
*     ltRetval    = The date/time is returned as a VFP DateTime value.
*!* *} MJP -- 2014/12/01 13:49:55 - End
*


*=============================================================
* Tried to use this FFC class, but it sometimes gave an error:
* This.oFrxCursor.GetTimeStampString(timestamp)
*=============================================================


*-- MJP -- 12/01/2014 01:50:42 PM
Lparameter tnTimeStamp	&&, tcStyle

*-- MJP -- 12/01/2014 01:51:05 PM
Local ltRetVal, ;	&& lcRetVal        &&  Requested data returned from procedure
	lnYear, ;
	lnMonth, ;
	lnDay, ;
	lnHour, ;
	lnMinute, ;
	lnSecond

If Type('tnTimeStamp') != "N"          &&  Timestamp must be numeric
	Wait Window "Time stamp passed is not numeric"
	Return ""
Endif

If tnTimeStamp = 0                     &&  Timestamp is zero until built in project
	Return "Not built into App"
Endif

*!* MJP -- Removed 2014/12/01 13:52:02
*!* If Type('tcStyle') != "C"              &&  Default return style to both date and time
*!* 	tcStyle = "DATETIME"
*!* Endif

*!* If !Inlist(Upper(tcStyle), "DATE", "TIME", "DATETIME")
*!* 	Wait Window "Style parameter must be DATE, TIME, or DATETIME"
*!* 	Return ""
*!* Endif

lnYear   = ((tnTimeStamp / (2 ** 25) + 1980))
lnMonth  = ((lnYear - Int(lnYear)    ) * (2 ** 25)) / (2 ** 21)
lnDay    = ((lnMonth - Int(lnMonth)  ) * (2 ** 21)) / (2 ** 16)

lnHour   = ((lnDay - Int(lnDay)      ) * (2 ** 16)) / (2 ** 11)
lnMinute = ((lnHour - Int(lnHour)    ) * (2 ** 11)) / (2 ** 05)
lnSecond = ((lnMinute - Int(lnMinute)) * (2 ** 05)) * 2       &&  Multiply by two to correct
&&  truncation problem built in
&&  to the creation algorithm
&&  (Source: Microsoft Tech Support)

*!* MJP -- Removed 2014/12/01 13:52:31                                                               
*!* lcRetVal = ""

*!* If "DATE" $ Upper(tcStyle)
*!* *< 4-Feb-2001 Fixed to display date in machine designated format (Regional Settings)
*!* *< lcRetVal = lcRetVal + RIGHT("0"+ALLTRIM(STR(INT(lnMonth))),2) + "/" + ;
*!* *<                       RIGHT("0"+ALLTRIM(STR(INT(lnDay))),2)   + "/" + ;
*!* *<                       RIGHT("0"+ALLTRIM(STR(INT(lnYear))), IIF(SET("CENTURY") = "ON", 4, 2))

*!* *< RAS 23-Nov-2004, change to work around behavior change in VFP 9.
*!* *< lcRetVal = lcRetVal + DTOC(DATE(lnYear, lnMonth, lnDay))
*!* 	lcRetVal = lcRetVal + Dtoc(Date(Int(lnYear), Int(lnMonth), Int(lnDay)))
*!* Endif

*!* If "TIME" $ Upper(tcStyle)
*!* 	lcRetVal = lcRetVal + Iif("DATE" $ Upper(tcStyle), " ", "")
*!* 	lcRetVal = lcRetVal + Right("0" + Alltrim(Str(Int(lnHour))), 2)   + ":" + ;
*!* 		Right("0" + Alltrim(Str(Int(lnMinute))), 2) + ":" + ;
*!* 		Right("0" + Alltrim(Str(Int(lnSecond))), 2)
*!* Endif


*!* Execscript (_Screen.cThorDispatcher, 'Result=', lcRetVal)
*!* Return lcRetVal

*-- MJP -- 12/01/2014 01:54:28 PM
* Just generate the DateTime value from the parts extracted from the
* timestamp, and return it to the calling code.
ltRetVal = DATETIME( Int(m.lnYear), Int(m.lnMonth), Int(m.lnDay), Int(m.lnHour), int(m.lnMinute), Int(m.lnSecond) )

RETURN EXECSCRIPT( _Screen.cThorDispatcher, 'Result=', m.ltRetVal )
