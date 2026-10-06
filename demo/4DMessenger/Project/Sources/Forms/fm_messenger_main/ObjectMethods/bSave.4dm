
// METHOD : [projectForm]/fm_messenger_main/bSave
// CREATOR     : omarolleau
// DESCRIPTION :
// UPDATED     : Wed. 15 Oct. 2025 at 15:12 by omarolleau
// ----------------------------------------------------------------------------------

// declare vars


// ----------------------------------------------------------------------------------

// events

If (FORM Event:C1606.code=Sur clic:K2:4)
	
	// save preference
	
	Form:C1466.cs_preferences.save()
	
	// terminate and relaunch socket
	
	Form:C1466.cs_interface.actioListenMessage()
	
	ALERT:C41(Localized string:C991("xTextSaved"))
	
End if 
