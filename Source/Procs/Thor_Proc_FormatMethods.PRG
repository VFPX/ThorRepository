Define Class FormatMethods As Custom


	oUndo = .Null.
	Dimension aproclines[1]
	Dimension ahandlehistory[1]


	*================================================================================
	*================================================================================
	Procedure EmptyUndoBuffer
		If 'O' # Vartype (This.oUndo)
			This.oUndo = Createobject ('Collection')
		Else
			This.oUndo.Remove(-1)
		Endif

	Endproc


	*================================================================================
	*================================================================================
 	Procedure Format_Align_Bottom_Edges
		Lparameters lnShift

		Local lnBottom
		If This.SetupFormat() < 2
			Return .T.
		Endif

		Select crsr_FormatInfo
		If m.lnShift = 0
			Calculate Max (nBottom) To m.lnBottom For Not Isnull (nBottom)
		Else
			Calculate Min (nBottom) To m.lnBottom For Not Isnull (nBottom)
		Endif

		Replace All nNewTop With m.lnBottom - nHeight For Not Isnull (nBottom)

		This.PostFormat()

	Endproc


	*================================================================================
	*================================================================================
 	Procedure Format_Align_Horizontal_Centers
		Local lnLeft, lnRight
		If This.SetupFormat() < 2
			Return .T.
		Endif

		Select crsr_FormatInfo
		Calculate Min (nLeft), Max (nRight)			;
			To m.lnLeft, m.lnRight					;
			For Not Isnull (nLeft)

		Replace All nNewLeft With (m.lnLeft + m.lnRight - nWidth) / 2		;
			For Not Isnull (nLeft)

		This.PostFormat()

	Endproc


	*================================================================================
	*================================================================================
 	Procedure Format_Align_Left_Sides
		Lparameters lnShift

		Local lnLeft
		If This.SetupFormat() < 2
			Return .T.
		Endif

		Select crsr_FormatInfo
		If m.lnShift = 0
			Calculate Min (nLeft) To m.lnLeft For Not Isnull (nLeft)
		Else
			Calculate Max (nLeft) To m.lnLeft For Not Isnull (nLeft)
		Endif

		Replace All nNewLeft With m.lnLeft For Not Isnull (nLeft)

		This.PostFormat()

	Endproc


	*================================================================================
	*================================================================================
 	Procedure Format_Align_Right_Sides
		Lparameters lnShift

		Local lnRight
		If This.SetupFormat() < 2
			Return .T.
		Endif

		Select crsr_FormatInfo
		If m.lnShift = 0
			Calculate Max (nRight) To m.lnRight For Not Isnull (nRight)
		Else
			Calculate Min (nRight) To m.lnRight For Not Isnull (nRight)
		Endif

		Replace All nNewLeft With m.lnRight - nWidth For Not Isnull (nRight)

		This.PostFormat()

	Endproc


	*================================================================================
	*================================================================================
 	Procedure Format_Align_Top_Edges
		Lparameters lnShift

		Local lnTop
		If This.SetupFormat() < 2
			Return .T.
		Endif

		Select crsr_FormatInfo
		If m.lnShift = 0
			Calculate Min (nTop) To m.lnTop For Not Isnull (nTop)
		Else
			Calculate Max (nTop) To m.lnTop For Not Isnull (nTop)
		Endif

		Replace All nNewTop With m.lnTop For Not Isnull (nTop)

		This.PostFormat()

	Endproc


	*================================================================================
	*================================================================================
 	Procedure Format_Align_Vertical_Centers
		Local lnTop, lnBottom
		If This.SetupFormat() < 2
			Return .T.
		Endif

		Select crsr_FormatInfo
		Calculate Min (nTop), Max (nBottom)			;
			To m.lnTop, m.lnBottom					;
			For Not Isnull (nTop)

		Replace All nNewTop With (m.lnTop + m.lnBottom - nHeight) / 2		;
			For Not Isnull (nTop)

		This.PostFormat()

	Endproc


	*================================================================================
	*================================================================================
 	Procedure Format_BringToFront
		Local laObjects[1], lnObjects, loObject
		If This.SetupFormat() = 0
			Return .T.
		Endif

		Select crsr_FormatInfo
		lnObjects = Aselobj (laObjects)

		Scan
			loObject = m.laObjects (Recno)
			m.loObject.ZOrder(0)
		Endscan

	Endproc


	*================================================================================
	*================================================================================
 	Procedure Format_Center_Horizontally
		Local laObjects[1], lnObjects, lnParentWidth, lnRight, lnLeft, loParent
		If This.SetupFormat() = 0
			Return .T.
		Endif

		Select crsr_FormatInfo
		Calculate Min (nLeft), Max (nRight)			;
			To m.lnLeft, m.lnRight					;
			For Not Isnull (nLeft)

		lnObjects = Aselobj (laObjects)
		loParent  = m.laObjects(1).Parent
		If Pemstatus (m.loParent, 'Width', 5)
			lnParentWidth = m.loParent.Width
		Else
			lnParentWidth = m.loParent.Parent.PageWidth
		Endif

		Replace All nNewLeft With nLeft + (m.lnParentWidth - (m.lnLeft + m.lnRight)) / 2		;
			For Not Isnull (nLeft)

		This.PostFormat()

	Endproc


	*================================================================================
	*================================================================================
 	Procedure Format_Center_Vertically
		Local laObjects[1], lnBottom, lnObjects, lnParentHeight, lnTop, loParent

		If This.SetupFormat() = 0
			Return .T.
		Endif

		Select crsr_FormatInfo
		Calculate Min (nTop), Max (nBottom)			;
			To m.lnTop, m.lnBottom					;
			For Not Isnull (nTop)

		lnObjects = Aselobj (laObjects)
		loParent  = m.laObjects(1).Parent
		If Pemstatus (m.loParent, 'Height', 5)
			lnParentHeight = m.loParent.Height
		Else
			lnParentHeight = m.loParent.Parent.PageHeight
		Endif

		Replace All nNewTop With nTop + (m.lnParentHeight - (m.lnTop + m.lnBottom)) / 2			;
			For Not Isnull (nTop)

		This.PostFormat()

	Endproc


	*================================================================================
	*================================================================================
 	Procedure Format_Horizontal_Decrease
		Lparameters tnDecrease, tnGroup
		Local lnDecrease, lnIncremented, lnWidth1

		If 'N' = Vartype(m.tnDecrease)
			lnDecrease = m.tnDecrease
		Else
			lnDecrease = 1
		Endif

		If This.SetupFormat() < 2
			Return .T.
		Endif

		Select  *						;
			From crsr_FormatInfo		;
			Order By nLeft				;
			Into Cursor crsr_FormatInfo Readwrite

		lnIncremented = 0

		Scan
			Replace nNewLeft With nLeft + m.lnIncremented

			* Only change the position after the last item in the group
			If Mod(Recno(), m.tnGroup) = 0
				lnIncremented = m.lnIncremented - m.lnDecrease
			Endif

		Endscan

		This.PostFormat()

	Endproc


	*================================================================================
	*================================================================================
 	Procedure Format_Horizontal_Increase
		Lparameters tnIncrease, tnGroup
		Local lnIncrease, lnIncremented

		If 'N' = Vartype(m.tnIncrease)
			lnIncrease = m.tnIncrease
		Else
			lnIncrease = 1
		Endif

		If This.SetupFormat() < 2
			Return .T.
		Endif

		Select  *						;
			From crsr_FormatInfo		;
			Order By nLeft				;
			Into Cursor crsr_FormatInfo Readwrite

		lnIncremented = 0

		Scan
			Replace nNewLeft With nLeft + m.lnIncremented

			* Only change the position after the last item in the group
			If Mod(Recno(), m.tnGroup) = 0
				lnIncremented = m.lnIncremented + m.lnIncrease
			Endif

		Endscan

		This.PostFormat()

	Endproc


	*================================================================================
	*================================================================================
 	Procedure Format_Horizontal_Make_Equal
 		Lparameters tnGroup
 		Local lnIncrement, lnLeft1, lnNextLeft, lnOffsetThisGroup, lnWidth1
 	
 		If This.SetupFormat() < 3 * m.tnGroup
 			Return .T.
 		Endif
 	
 		Select  *								;
 			From crsr_FormatInfo				;
 			Order By nLeft, nWidth Desc			;
 			Into Cursor crsr_FormatInfo Readwrite
 	
 		Locate
 		lnLeft1	 = nLeft
 		lnWidth1 = nWidth
 	
 		Skip (m.tnGroup)
 		lnIncrement	= Max(0, nLeft - (m.lnLeft1 + m.lnWidth1))
 	
 		lnNextLeft = m.lnLeft1
 	
 		If m.tnGroup = 1
 			lnNextLeft = m.lnLeft1
 			Scan
 				Replace nNewLeft With m.lnNextLeft
 				lnNextLeft = nNewLeft + nWidth + m.lnIncrement
 			Endscan
 		Else
 			lnNextLeft = m.lnLeft1 + m.lnWidth1 + m.lnIncrement
 			Scan For Recno() > m.tnGroup
 				If Mod(Recno(), m.tnGroup) = 1
 					lnOffsetThisGroup = m.lnNextLeft - nLeft
 					lnNextLeft		  = m.lnNextLeft + nWidth + m.lnIncrement
 				Endif
 	
 				Replace nNewLeft With nNewLeft + m.lnOffsetThisGroup
 			Endscan
 		Endif
 	
 		This.PostFormat()
 	
 	Endproc
 	

	*================================================================================
	*================================================================================
 	Procedure Format_Increase
		Lparameters tcPropertyName, tnIncrease

		Local lcFromField, lcToField

		If This.SetupFormat() = 0
			Return .T.
		Endif

		lcFromField	= 'n' + m.tcPropertyName
		lcToField	= 'nNew' + m.tcPropertyName

		Select crsr_FormatInfo
		Scan
			Replace &lcToField With &lcFromField + m.tnIncrease
		Endscan

		This.PostFormat()

	Endproc


	*================================================================================
	*================================================================================
 	Procedure Format_SendToBack
		Local laObjects[1], lnObjects, loObject
		If This.SetupFormat() = 0
			Return .T.
		Endif

		Select crsr_FormatInfo
		lnObjects = Aselobj (laObjects)

		Scan
			loObject = m.laObjects (Recno)
			m.loObject.ZOrder(1)
		Endscan


	Endproc


	*================================================================================
	*================================================================================
 	Procedure Format_To_Narrowest
		Local lnWidth
		If This.SetupFormat() < 2
			Return .T.
		Endif

		Select crsr_FormatInfo
		Calculate Min (nWidth) To m.lnWidth For Not Isnull (nWidth)
		Replace All nNewWidth With m.lnWidth For Not Isnull (nWidth)

		This.PostFormat()

	Endproc


	*================================================================================
	*================================================================================
 	Procedure Format_To_Shortest
		Local lnHeight
		If This.SetupFormat() < 2
			Return .T.
		Endif

		Select crsr_FormatInfo
		Calculate Min (nHeight) To m.lnHeight For Not Isnull (nHeight)
		Replace All nNewHeight With m.lnHeight For Not Isnull (nHeight)

		This.PostFormat()

	Endproc


	*================================================================================
	*================================================================================
 	Procedure Format_To_Tallest
		Local lnHeight
		If This.SetupFormat() < 2
			Return .T.
		Endif

		Select crsr_FormatInfo
		Calculate Max (nHeight) To m.lnHeight For Not Isnull (nHeight)
		Replace All nNewHeight With m.lnHeight For Not Isnull (nHeight)

		This.PostFormat()

	Endproc


	*================================================================================
	*================================================================================
 	Procedure Format_To_Widest
		Local lnWidth
		If This.SetupFormat() < 2
			Return .T.
		Endif

		Select crsr_FormatInfo
		Calculate Max (nWidth) To m.lnWidth For Not Isnull (nWidth)
		Replace All nNewWidth With m.lnWidth For Not Isnull (nWidth)

		This.PostFormat()

	Endproc


	*================================================================================
	*================================================================================
 	Procedure Format_Undo
		Local lnIndex
		lnIndex = This.oUndo.Count

		If m.lnIndex # 0
			Use In crsr_FormatInfo
			Xmltocursor(This.oUndo.Item (m.lnIndex), 'crsr_FormatInfo')
			This.oUndo.Remove (m.lnIndex)
			This.PostFormat (.T.)
		Endif



	Endproc


	*================================================================================
	*================================================================================
 	Procedure Format_Vertical_Decrease
		Lparameters tnDecrease, tnGroup
		Local lnDecrease, lnIncremented, lnWidth1

		If 'N' = Vartype(m.tnDecrease)
			lnDecrease = m.tnDecrease
		Else
			lnDecrease = 1
		Endif

		If This.SetupFormat() < 2
			Return .T.
		Endif

		Select  *						;
			From crsr_FormatInfo		;
			Order By nTop				;
			Into Cursor crsr_FormatInfo Readwrite

		lnIncremented = 0

		Scan
			Replace nNewTop With nTop + m.lnIncremented

			* Only change the position after the last item in the group
			If Mod(Recno(), m.tnGroup) = 0
				lnIncremented = m.lnIncremented - m.lnDecrease
			Endif
		Endscan

		This.PostFormat()

	Endproc


	*================================================================================
	*================================================================================
 	Procedure Format_Vertical_Increase
		Lparameters tnIncrease, tnGroup
		Local lnIncrease, lnIncremented, lnWidth1

		If 'N' = Vartype(m.tnIncrease)
			lnIncrease = m.tnIncrease
		Else
			lnIncrease = 1
		Endif

		If This.SetupFormat() < 2
			Return .T.
		Endif

		Select  *						;
			From crsr_FormatInfo		;
			Order By nTop				;
			Into Cursor crsr_FormatInfo Readwrite

		lnIncremented = 0

		Scan
			Replace nNewTop With nTop + m.lnIncremented

			* Only change the position after the last item in the group
			If Mod(Recno(), m.tnGroup) = 0
				lnIncremented = m.lnIncremented + m.lnIncrease
			Endif

		Endscan

		This.PostFormat()

	Endproc

	*================================================================================
	*================================================================================
 	Procedure Format_Vertical_Make_Equal
		Lparameters tnGroup
		Local lnHeight1, lnIncrement, lnNextTop, lnOffsetThisGroup, lnTop1

		If This.SetupFormat() < 3 * m.tnGroup
			Return .T.
		Endif

		Select  *								;
			From crsr_FormatInfo				;
			Order By nTop, nHeight Desc			;
			Into Cursor crsr_FormatInfo Readwrite

		Locate
		lnTop1	  = nTop
		lnHeight1 = nHeight

		Skip (m.tnGroup)
		lnIncrement	   = Max(0, nTop - (m.lnTop1 + m.lnHeight1))

		If m.tnGroup = 1
			lnNextTop = m.lnTop1
			Scan
				Replace nNewTop With m.lnNextTop
				lnNextTop = nNewTop + nHeight + m.lnIncrement
			Endscan
		Else
			lnNextTop = m.lnTop1 + m.lnHeight1 + m.lnIncrement
			Scan For Recno() > m.tnGroup
				If Mod(Recno(), m.tnGroup) = 1
					lnOffsetThisGroup = m.lnNextTop - nTop
					lnNextTop		  = m.lnNextTop + nHeight + m.lnIncrement
				Endif

				Replace nNewTop With nNewTop + m.lnOffsetThisGroup
			Endscan
		Endif

		This.PostFormat()

	Endproc


	*================================================================================
	*================================================================================
 	Procedure PostFormat
		Lparameters tlUndo

		Local loObject As Object
		Local laObjects[1], lcPropName, lcXML, lnObjects, loException

		Select crsr_FormatInfo
		lnObjects = Aselobj (laObjects)

		Scan
			loObject = m.laObjects (Recno)

			Try
				If (Not Isnull (nTop)) And nTop # nNewTop
					lcPropName	 = 'Top'
					loObject.Top = Iif (m.tlUndo, nTop, nNewTop)
				Endif

				If (Not Isnull (nLeft)) And nLeft # nNewLeft
					lcPropName	  = 'Left'
					loObject.Left = Iif (m.tlUndo, nLeft, nNewLeft)
				Endif

				If (Not Isnull (nHeight)) And nHeight # nNewHeight
					lcPropName		= 'Height'
					loObject.Height	= Iif (m.tlUndo, nHeight, nNewHeight)
				Endif

				If (Not Isnull (nWidth)) And nWidth # nNewWidth
					lcPropName	   = 'Width'
					loObject.Width = Iif (m.tlUndo, nWidth, nNewWidth)
				Endif

			Catch To m.loException
				This.ShowErrorMsg (m.loException, , , 'Unable to set ' + m.lcPropName + ' for ' + This.GetObjectPath (m.loObject))
			Endtry

		Endscan

		If Not m.tlUndo
			Cursortoxml ('crsr_FormatInfo', 'lcXml', 1, 0, 0, '1')
			This.oUndo.Add (m.lcXML)
		Endif


	Endproc


	*================================================================================
	*================================================================================
 	Procedure SetupFormat
		Local laObjects[1], lnHeight, lnI, lnLeft, lnObjects, lnTop, lnWidth, loObject

		Create Cursor crsr_FormatInfo (			;
			  Recno			N(6),				;
			  nTop			N(6),				;
			  nLeft			N(6),				;
			  nHeight		N(6),				;
			  nWidth		N(6),				;
			  nBottom		N(6),				;
			  nRight		N(6),				;
			  nNewTop		N(6),				;
			  nNewLeft		N(6),				;
			  nNewHeight	N(6),				;
			  nNewWidth		N(6),				;
			  nNewBottom	N(6),				;
			  nNewRight		N(6)				;
			  )

		lnObjects = Aselobj (laObjects)
		For lnI = 1 To m.lnObjects
			loObject = m.laObjects (m.lnI)
			lnTop	 = Iif (Pemstatus (m.loObject, 'Top', 5), m.loObject.Top, .Null.)
			lnLeft	 = Iif (Pemstatus (m.loObject, 'Left', 5), m.loObject.Left, .Null.)
			lnHeight = Iif (Pemstatus (m.loObject, 'Height', 5), m.loObject.Height, .Null.)
			lnWidth	 = Iif (Pemstatus (m.loObject, 'Width', 5), m.loObject.Width, .Null.)
			Insert Into crsr_FormatInfo Values  (0,												;
				  m.lnTop, m.lnLeft, m.lnHeight, m.lnWidth, m.lnTop + m.lnHeight, m.lnLeft + m.lnWidth ;
				  , m.lnTop, m.lnLeft, m.lnHeight, m.lnWidth, m.lnTop + m.lnHeight, m.lnLeft + m.lnWidth ;
				  )
			Replace Recno With Recno()
		Endfor

		Return m.lnObjects

	Endproc

 Enddefine
