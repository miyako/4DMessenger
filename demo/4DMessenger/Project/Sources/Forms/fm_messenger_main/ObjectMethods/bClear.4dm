
// METHOD : [projectForm]/fm_messenger_main/bClear
// CREATOR     : omarolleau
// DESCRIPTION :
// UPDATED     : Thu. 25 Sep. 2025 at 15:21 by omarolleau
// ----------------------------------------------------------------------------------

// declare vars

// ----------------------------------------------------------------------------------

// events

If (FORM Event:C1606.code=Sur clic:K2:4)
	
	Form:C1466.cs_interface.actioClearHistory()
	
End if 
