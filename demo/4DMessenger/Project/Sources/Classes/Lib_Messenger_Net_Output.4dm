
// CLASS       : Lib_Messenger_Net_Output
// CREATOR     : omarolleau
// DESCRIPTION :
// UPDATED     : Thu. 16 Oct. 2025 at 14:49 by omarolleau
// ----------------------------------------------------------------------------------

// declare properties

property connection : 4D:C1709.TCPConnection
property settings : Object
property requestDraw : Object
property requestPack : Blob

// ----------------------------------------------------------------------------------

// definition

Class constructor($settings : Object)
	
	var $bin : Blob
	
	This:C1470.connection:=Null:C1517
	This:C1470.settings:=$settings
	This:C1470.requestDraw:=New object:C1471()
	This:C1470.requestPack:=$bin
	
Function connect($adress : Text)
	
	If ($adress#"")
		This:C1470.connection:=4D:C1709.TCPConnection.new($adress; This:C1470.settings.comm.port; This:C1470)
	End if 
	
Function disconnect()
	
	var $bin : Blob
	
	This:C1470.connection.shutdown()
	This:C1470.connection:=Null:C1517
	This:C1470.requestDraw:=New object:C1471()
	This:C1470.requestPack:=$bin
	
Function send($requestDraw : Object; $requestPack : Blob)
	
	// send request
	
	This:C1470.requestDraw:=$requestDraw
	This:C1470.requestPack:=$requestPack
	
	This:C1470.connection.send($requestPack)
	
	
Function onConnection($connection : 4D:C1709.TCPConnection; $event : 4D:C1709.TCPEvent)
	
Function onShutdown($connection : 4D:C1709.TCPConnection; $event : 4D:C1709.TCPEvent)
	
Function onData($connection : 4D:C1709.TCPConnection; $event : 4D:C1709.TCPEvent)
	
	// var
	
	var $bin : Blob
	
	// blob contain somthings
	
	If (BLOB size:C605($event.data)>=1)
		
		$bin:=$event.data
		
		Case of 
			: ($bin{0}=0x0001)
				
				// update interface
				
				CALL FORM:C1391(Current form window:C827; "app_messenger_main"; False:C215; This:C1470.requestDraw)
				WA EXECUTE JAVASCRIPT FUNCTION:C1043(*; "zMessInput"; "clearInput"; *)
				GOTO OBJECT:C206(*; "zMessInput")
				
			: ($bin{0}=0x0002)
				
				DELETE FROM BLOB:C560($bin; 0; 1)
				BLOB TO DOCUMENT:C526(Get 4D folder:C485(Active 4D Folder:K5:10)+"Messenger"+Folder separator:K24:12+Form:C1466.cs_preferences.comm.nodes.query("address = :1"; $connection.address)[0].user+".png"; $bin)
				
		End case 
		
		SET BLOB SIZE:C606($bin; 0)
		
	End if 
	
Function onError($connection : 4D:C1709.TCPConnection; $event : 4D:C1709.TCPEvent)
	
	app_messenger_error($connection.errors)
	
Function onTerminate($connection : 4D:C1709.TCPConnection; $event : 4D:C1709.TCPEvent)
	