
// METHOD : [projectForm]/fm_messenger_main/{formMethod}
// CREATOR     : omarolleau0
// DESCRIPTION :
// UPDATED     : Tue. 7 Oct. 2025 at 11:39 by omarolleau
// ----------------------------------------------------------------------------------

// declare vars

var $evs; xNode_pos; xChannel_pos : Integer

var xNode_set; xChannel_set : Collection

// ----------------------------------------------------------------------------------

// events

$evs:=FORM Event:C1606.code

Case of 
	: ($evs=On Load:K2:1)
		
		// init interface
		
		Form:C1466.cs_interface:=cs:C1710.Lib_Messenger_Interface.new()
		
		// init prefs
		
		Form:C1466.cs_preferences:=cs:C1710.Lib_Messenger_Preferences.new()
		Form:C1466.cs_preferences.load()
		
		// open listener
		
		Form:C1466.cs_interface.actioListenMessage()
		
		
	: ($evs=On Unload:K2:2)
		
		// cleanup cach
		
		Form:C1466.cs_interface.actionCleanupCach()
		
		// close extend properties
		
		Form:C1466.cs_interface.expansion(False:C215)
		
		// close listener
		
		Form:C1466.cs_interface.actioListenClose(False:C215)
		
		// clean worker
		
		KILL WORKER:C1390(Current process:C322)
		
End case 
