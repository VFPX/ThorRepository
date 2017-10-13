Lparameters tcFile, tlOffset

* Selects the max timestamp row from a table, converts it to DateTime
* tlOffset = .T. to offset this time by the number of records found,
*    so that creation of text files (FoxBin2PRG) can use this
*    to learn if a file has changed.

Local laMaxDateTime[1], lcCursor, lcDateTime, lcFileDate, ldFileDate

lcCursor = 'csrGetMaxTimeStamp'

If Used(m.lcCursor)
	Use In (m.lcCursor)
Endif

*-- Open the table, read the max date of any row in the table ----------
Use (m.tcFile) Again In 0 Alias &lcCursor Shared
Select Max(Timestamp), Sum(Iif(Deleted(), 0, 1)) From (m.lcCursor) Into Array laMaxDateTime
If m.laMaxDateTime > 0
	*!* *{ MJP -- 2014/12/01 13:55:48 - Begin
	*!* lcDateTime = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_ConvertTimeStamp', m.laMaxDateTime[1])
	*!* ldFileDate = Ctot(m.lcDateTime)
	ldFileDate = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_ConvertTimeStamp', m.laMaxDateTime[1])
	*!* *} MJP -- 2014/12/01 13:55:48 - End
	If m.tlOffset
		ldFileDate = m.ldFileDate - 2 * m.laMaxDateTime[2]
	Endif
Else
	*!* *{ MJP -- 2014/12/01 13:56:08 - Begin
	* This was using the wrong variable name, and the data type being
	* saved here was a Date, not a DateTime as above.
	*!* lcFileDate = {//}
	ldFileDate = {//::}
	*!* *} MJP -- 2014/12/01 13:56:08 - End
Endif
Use In (m.lcCursor)

*!* *{ MJP -- 2014/12/01 13:57:38 - Begin
*!* Execscript (_Screen.cThorDispatcher, 'Result=', m.ldFileDate )
*!* Return m.ldFileDate
* This is a slightly cleaner way of doing this now.
Return Execscript( _Screen.cThorDispatcher, 'Result=', m.ldFileDate )
*!* *} MJP -- 2014/12/01 13:57:38 - End
