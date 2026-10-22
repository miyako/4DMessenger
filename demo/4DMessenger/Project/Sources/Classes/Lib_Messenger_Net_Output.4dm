
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
property received : Blob

// ----------------------------------------------------------------------------------

// definition

Class constructor($settings : Object)
	
	var $bin : Blob
	
	This:C1470.connection:=Null:C1517
	This:C1470.settings:=$settings
	This:C1470.requestDraw:=New object:C1471()
	This:C1470.requestPack:=$bin
	This:C1470.received:=$bin
	
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
	
	var $bin; $buffer : Blob
	
	var $size : Integer
	
	var $user : Text
	
	// an icon can arrive in several packets: append them
	
	$bin:=This:C1470.received
	$buffer:=$event.data
	COPY BLOB:C558($buffer; $bin; 0; BLOB size:C605($bin); BLOB size:C605($buffer))
	This:C1470.received:=$bin
	
	$size:=BLOB size:C605($bin)
	
	// blob contain somthings
	
	If ($size>=1)
		
		Case of 
			: ($bin{0}=0x0001)
				
				// update interface
				
				cs:C1710.Lib_Messenger_Service.me.deliver(This:C1470.requestDraw; True:C214)
				SET BLOB SIZE:C606($bin; 0)
				
			: ($bin{0}=0x0002)
				
				// complete when the PNG ends with its IEND chunk (49 45 4E 44 AE 42 60 82)
				
				If ($size>=9)
					If (($bin{$size-8}=0x0049) & ($bin{$size-7}=0x0045) & ($bin{$size-6}=0x004E) & ($bin{$size-5}=0x0044) \
						 & ($bin{$size-4}=0x00AE) & ($bin{$size-3}=0x0042) & ($bin{$size-2}=0x0060) & ($bin{$size-1}=0x0082))
						
						// save it under the name of the user it was requested from
						
						$user:=String:C10(This:C1470.requestDraw.recipient)
						If ($user#"")
							DELETE FROM BLOB:C560($bin; 0; 1)
							BLOB TO DOCUMENT:C526(Get 4D folder:C485(Active 4D Folder:K5:10)+"Messenger"+Folder separator:K24:12+$user+".png"; $bin)
							cs:C1710.Lib_Messenger_Service.me.iconSaved($user)
						End if 
						
						SET BLOB SIZE:C606($bin; 0)
						
					End if 
				End if 
				
			Else 
				
				SET BLOB SIZE:C606($bin; 0)
				
		End case 
		
		This:C1470.received:=$bin
		
	End if 
	
Function onError($connection : 4D:C1709.TCPConnection; $event : 4D:C1709.TCPEvent)
	
	app_messenger_error($connection.errors)
	
Function onTerminate($connection : 4D:C1709.TCPConnection; $event : 4D:C1709.TCPEvent)
	