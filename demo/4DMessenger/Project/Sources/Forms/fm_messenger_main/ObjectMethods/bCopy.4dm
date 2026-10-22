
// METHOD : [projectForm]/fm_messenger_main/bSend2
// CREATOR     : omarolleau
// DESCRIPTION :
// UPDATED     : Thu. 25 Sep. 2025 at 15:18 by omarolleau
// ----------------------------------------------------------------------------------

// declare vars

// ----------------------------------------------------------------------------------

// events

If (FORM Event:C1606.code=Sur clic:K2:4)
	
	SET TEXT TO PASTEBOARD:C523(Form:C1466.cs_preferences.comm.key)
	
End if 
