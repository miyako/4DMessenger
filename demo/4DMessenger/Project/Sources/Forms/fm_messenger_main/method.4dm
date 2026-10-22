
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
		
		// cleanup cach, once per session (the history shown later uses the cached icons)
		
		If (Process number:C372("messenger_net")=0)
			Form:C1466.cs_interface.actionCleanupCach()
		End if 
		
		// connect to the network worker (it starts listening the first time)
		
		Form:C1466.cs_interface.actioAttach()
		
		// wait for the web areas
		
		SET TIMER(10)
		
	: ($evs=On Timer)
		
		Form:C1466.cs_interface.flush()
		
	: ($evs=On Unload:K2:2)
		
		// close extend properties
		
		Form:C1466.cs_interface.expansion(False:C215)
		
		// the network worker keeps listening
		
		Form:C1466.cs_interface.actioDetach()
		
End case 
