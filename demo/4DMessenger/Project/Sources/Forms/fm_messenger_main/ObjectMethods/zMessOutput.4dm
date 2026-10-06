
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
		
End case 
