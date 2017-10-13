Lparameters loException, lcTitleBar, lcPRGName, lcAddlInfo

#Define ccCRLF Chr[13]+ Chr[10]

Messagebox ('Error: ' + Transform (loException.ErrorNo) 	+ ccCRLF +								;
	  'Message: ' + loException.Message 					+ ccCRLF +								;
	  'Procedure: ' + Iif (Empty (lcPRGName), loException.Procedure, Justfname (lcPRGName)) + ccCRLF + ;
	  'Line: ' + Transform (loException.Lineno) 			+ ccCRLF +								;
	  'Code: ' + loException.LineContents															;
	  + Iif (Empty (lcAddlInfo), '', ccCRLF + 'NOTES: ' + lcAddlInfo)								;
	  , 48, Evl (lcTitleBar, 'Error'))
