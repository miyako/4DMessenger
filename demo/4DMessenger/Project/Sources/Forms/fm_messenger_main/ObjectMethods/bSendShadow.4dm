
// METHOD : [projectForm]/fm_messenger_main/bSendShadow
// CREATOR     : omarolleau
// DESCRIPTION :
// UPDATED     : Thu. 25 Sep. 2025 at 15:19 by omarolleau
// ----------------------------------------------------------------------------------

// declare vars

// ----------------------------------------------------------------------------------

// events

If (FORM Event:C1606.code=Sur clic:K2:4)
	
	Form:C1466.cs_interface.actioSendMessage()
	
End if 
