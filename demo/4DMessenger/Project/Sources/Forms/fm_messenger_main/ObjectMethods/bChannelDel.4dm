
// METHOD : [projectForm]/fm_messenger_main/bChannelDel
// CREATOR     : omarolleau
// DESCRIPTION :
// UPDATED     : Thu. 25 Sep. 2025 at 16:32 by omarolleau
// ----------------------------------------------------------------------------------

// declare vars

var $item : Object

// ----------------------------------------------------------------------------------

// events

If (FORM Event:C1606.code=Sur clic:K2:4)
	
	OBJECT SET ENABLED:C1123(*; "bChannelDel"; False:C215)
	Form:C1466.cs_preferences.comm.channels.remove(xChannel_pos-1)
	
End if 
