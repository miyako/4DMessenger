
// CLASS       : Lib_Messenger_Net_Input
// CREATOR     : omarolleau
// DESCRIPTION :
// UPDATED     : Thu. 16 Oct. 2025 at 13:36 by omarolleau
// ----------------------------------------------------------------------------------

// declare properties

property listener : 4D:C1709.TCPListener
property window : Integer
property settings : Object

// ----------------------------------------------------------------------------------

// definition

Class constructor($window : Integer; $settings : Object)
	
	This:C1470.listener:=4D:C1709.TCPListener.new($settings.comm.port; This:C1470)
	This:C1470.window:=$window
	This:C1470.settings:=$settings
	
Function terminate()
	
	// clear listener
	
	This:C1470.listener.terminate()
	
Function onConnection($listener : 4D:C1709.TCPListener; $event : 4D:C1709.TCPEvent)->$result
	
	// control issuer authenticity
	
	If (This:C1470.settings.comm.nodes.query("address = :1 or address = :2"; $event.address; Replace string:C233($event.address; "::ffff:"; ""; 1)).length=1)
		
		$result:=cs:C1710.Lib_Messenger_Stream.new(This:C1470)
		
	End if 
	
Function onError($listener : 4D:C1709.TCPListener; $event : 4D:C1709.TCPEvent)
	
Function onTerminate($listener : 4D:C1709.TCPListener; $event : 4D:C1709.TCPEvent)
	