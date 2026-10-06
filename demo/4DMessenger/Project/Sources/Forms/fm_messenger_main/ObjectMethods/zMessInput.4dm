
// METHOD : [projectForm]/fm_messenger_main/zMessInput
// CREATOR     : omarolleau
// DESCRIPTION :
// UPDATED     : Thu. 25 Sep. 2025 at 15:18 by omarolleau
// ----------------------------------------------------------------------------------

// declare vars

// ----------------------------------------------------------------------------------

// events

If (FORM Event:C1606.code=Sur ouverture lien externe:K2:50)
	
	Form:C1466.cs_interface.callContextMenu("zMessInput")
	
End if 
