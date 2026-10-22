
// METHOD : [projectForm]/fm_messenger_main/zMessOutput
// CREATOR     : omarolleau
// DESCRIPTION :
// UPDATED     : Mon. 6 Oct. 2025 at 09:54 by omarolleau
// ----------------------------------------------------------------------------------

// declare vars

var $evs

// ----------------------------------------------------------------------------------

// events

$evs:=FORM Event:C1606.code

Case of 
	: ($evs=Sur ouverture lien externe:K2:50)
		
		Form:C1466.cs_interface.callContextMenu("zMessOutput")
		
	: ($evs=On End URL Loading)
		
		// pass the strings of the current language to the page
		
		WA EXECUTE JAVASCRIPT FUNCTION:C1043(*; "zMessOutput"; "setStrings"; *; New object:C1471(\
			"dateFormat"; Localized string:C991("xWebDateFormat"); \
			"days"; Localized string:C991("xWebDays"); \
			"months"; Localized string:C991("xWebMonths")))
		
End case 
