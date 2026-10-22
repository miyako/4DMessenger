
// METHOD : [projectForm]/fm_messenger_main/bSend
// CREATOR     : omarolleau
// DESCRIPTION :
// UPDATED     : Fri. 26 Sep. 2025 at 11:07 by omarolleau
// ----------------------------------------------------------------------------------

// declare vars

// ----------------------------------------------------------------------------------

// events

If (FORM Event:C1606.code=Sur clic:K2:4)
	
	Form:C1466.cs_interface.actioSendMessage()
	
End if 
