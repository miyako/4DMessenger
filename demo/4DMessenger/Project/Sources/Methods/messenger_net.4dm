//%attributes = {"invisible":true}

// METHOD      : messenger_net
// DESCRIPTION : entry point of the network worker. Can be called from any process:
//               the call is forwarded to the worker "messenger_net".
// ----------------------------------------------------------------------------------

// declare parameters

#DECLARE($action : Text; $params : Object)

// declare vars

var $service : cs:C1710.Lib_Messenger_Service

// ----------------------------------------------------------------------------------

If (Process number:C372("messenger_net")#Current process:C322)
	
	CALL WORKER:C1389("messenger_net"; "messenger_net"; $action; $params)
	
Else 
	
	$service:=cs:C1710.Lib_Messenger_Service.me
	
	Case of 
		: ($action="attach")
			
			$service.attach($params.window; $params.settings)
			
		: ($action="detach")
			
			$service.detach()
			
		: ($action="settings")
			
			$service.listen($params.settings)
			
		: ($action="send")
			
			$service.send($params.cargo; $params.recipients; $params.nodes)
			
		: ($action="clear")
			
			$service.clear()
			
	End case 
	
End if 
