
// METHOD : [projectForm]/fm_messenger_main/bChannelAdd
// CREATOR     : omarolleau
// DESCRIPTION :
// UPDATED     : Thu. 25 Sep. 2025 at 16:32 by omarolleau
// ----------------------------------------------------------------------------------

// declare vars

// ----------------------------------------------------------------------------------

// events

If (FORM Event:C1606.code=On Clicked:K2:4)
	
	Form:C1466.cs_preferences.comm.channels.push(New object:C1471(\
		"name"; "Enter channel name here"; \
		"users"; "Enter users here"))
	
End if 
