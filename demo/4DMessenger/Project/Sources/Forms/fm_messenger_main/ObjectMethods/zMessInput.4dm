
// METHOD : [projectForm]/fm_messenger_main/zMessInput
// CREATOR     : omarolleau
// DESCRIPTION :
// UPDATED     : Thu. 25 Sep. 2025 at 15:18 by omarolleau
// ----------------------------------------------------------------------------------

// declare vars

// ----------------------------------------------------------------------------------

// events

Case of 
	: (FORM Event:C1606.code=Sur ouverture lien externe:K2:50)
		
		Form:C1466.cs_interface.callContextMenu("zMessInput")
		
	: (FORM Event:C1606.code=On End URL Loading)
		
		// pass the strings of the current language to the page
		
		WA EXECUTE JAVASCRIPT FUNCTION:C1043(*; "zMessInput"; "setStrings"; *; New object:C1471(\
			"placeholder"; Localized string:C991("xWebPlaceholder"); \
			"fileTooLarge"; Localized string:C991("xWebFileTooLarge")))
		
End case 
