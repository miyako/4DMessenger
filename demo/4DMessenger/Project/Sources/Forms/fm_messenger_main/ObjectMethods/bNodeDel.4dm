
// METHOD : [projectForm]/fm_messenger_main/bNodeDel
// CREATOR     : omarolleau
// DESCRIPTION :
// UPDATED     : Fri. 26 Sep. 2025 at 12:34 by omarolleau
// ----------------------------------------------------------------------------------

// declare vars

var $item : Object

// ----------------------------------------------------------------------------------

// events

If (FORM Event:C1606.code=Sur clic:K2:4)
	
	OBJECT SET ENABLED:C1123(*; "bNodeDel"; False:C215)
	OBJECT SET ENABLED:C1123(*; "bChannelDel"; False:C215)
	Form:C1466.cs_preferences.comm.nodes.remove(xNode_pos-1)
	
End if 
