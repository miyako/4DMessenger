//%attributes = {"invisible":true}

// METHOD      : messenger_ui
// DESCRIPTION : called by the network worker (CALL FORM) to update the messenger window
// ----------------------------------------------------------------------------------

// declare parameters

#DECLARE($action : Text; $params : Object)

// ----------------------------------------------------------------------------------

Case of 
	: ($action="status")
		
		Form:C1466.cs_interface.listen_on:=$params.on_air
		
	: ($action="draw")
		
		Form:C1466.cs_interface.pending.push($params)
		Form:C1466.cs_interface.flush()
		
	: ($action="icon")
		
		If (Form:C1466.cs_interface.output_ready)
			WA EXECUTE JAVASCRIPT FUNCTION:C1043(*; "zMessOutput"; "avatarRefresh"; *; $params.user)
		End if 
		
End case 
