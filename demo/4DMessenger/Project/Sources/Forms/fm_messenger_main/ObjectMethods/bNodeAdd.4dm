
// METHOD : [projectForm]/fm_messenger_main/bNodeAdd
// CREATOR     : omarolleau
// DESCRIPTION :
// UPDATED     : Thu. 25 Sep. 2025 at 15:19 by omarolleau
// ----------------------------------------------------------------------------------

// declare vars

// ----------------------------------------------------------------------------------

// events

If (FORM Event:C1606.code=On Clicked:K2:4)
	
	Form:C1466.cs_preferences.comm.nodes.push(New object:C1471(\
		"address"; Localized string:C991("xTextNewNodeAddress"); \
		"user"; Localized string:C991("xTextNewNodeUser")))
	
End if 
