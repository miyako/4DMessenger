
// CLASS       : Lib_Messenger_Stream
// CREATOR     : omarolleau
// DESCRIPTION :
// UPDATED     : Thu. 16 Oct. 2025 at 14:39 by omarolleau
// ----------------------------------------------------------------------------------

// declare properties

property listener : cs:C1710.Lib_Messenger_Net_Input
property data : Blob
property address : Text

// ----------------------------------------------------------------------------------

// definition

Class constructor($listener : cs:C1710.Lib_Messenger_Net_Input)
	
	var $bin : Blob
	
	This:C1470.listener:=$listener
	This:C1470.data:=$bin
	This:C1470.address:=""
	
	
Function onConnection($connection : 4D:C1709.TCPConnection; $event : 4D:C1709.TCPEvent)
	
	var $bin : Blob
	
	This:C1470.data:=$bin
	This:C1470.address:=$event.adress
	
Function onData($connection : 4D:C1709.TCPConnection; $event : 4D:C1709.TCPEvent)
	
	// declare vars
	
	var $binData; $binBuffer; $requestPack : Blob
	
	var $offset : Integer:=0
	
	var $request : Object
	var $requestDraw; $sender : Object
	
	var $user; $userIconPath; $userAddress : Text
	
	// remap data
	
	$binData:=This:C1470.data
	$binBuffer:=$event.data
	
	// conjonction bin
	
	COPY BLOB:C558($binBuffer; $binData; 0; BLOB size:C605($binData); BLOB size:C605($binBuffer))
	This:C1470.data:=$binData
	
	// end transmition
	
	If (BLOB size:C605($binData)>=4)
		If (BLOB size:C605($binData)=BLOB to longint:C551($binData; PC byte ordering:K22:3))
			
			// unpack request
			
			$request:=cs:C1710.Lib_Messenger_Net_Request.new()
			If ($request.requestUnPack(This:C1470.listener.settings.comm.key; This:C1470.data))
				
				// control trajectory
				
				If (This:C1470.listener.settings.comm.nodes.query("address = :1 or address = :2 and user = :3"; $event.address; Replace string:C233($event.address; "::ffff:"; ""; 1); $request.sender).length>0)
					
					// update interface
					
					If ($request.way=x Messenger Get user icon)
						
						DOCUMENT TO BLOB:C525(Get 4D folder:C485(Active 4D Folder:K5:10)+"Messenger"+Folder separator:K24:12+Form:C1466.cs_preferences.user.name+".png"; $binBuffer)
						INSERT IN BLOB:C559($binBuffer; 0; 1; 0x0002)
						$connection.send($binBuffer)
						
					Else 
						
						// send confirmation acquisition Ok
						
						$request.way:=x Messenger Receive
						
						SET BLOB SIZE:C606($binBuffer; 0)
						INSERT IN BLOB:C559($binBuffer; 0; 1; 0x0001)
						$connection.send($binBuffer)
						
						// icon missing
						
						$requestDraw:=cs:C1710.Lib_Messenger_Net_Request.new()
						$requestDraw.sender:=Form:C1466.cs_preferences.user.name
						
						For each ($user; Split string:C1554($request.recipient_list+","+$request.sender; ","; sk ignore empty strings:K86:1))
							
							$requestDraw.recipient_list:=$user
							
							$userIconPath:=Get 4D folder:C485(Active 4D Folder:K5:10)+"Messenger"+Folder separator:K24:12+$user+".png"
							If (Test path name:C476($userIconPath)#Is a document:K24:1)
								
								$requestDraw.way:=x Messenger Get user icon
								$requestDraw.recipient:=$user
								$requestPack:=$requestDraw.requestPack(Form:C1466.cs_preferences.comm.key)
								
								$sender:=cs:C1710.Lib_Messenger_Net_Output.new(Form:C1466.cs_preferences)
								
								If ($user=Form:C1466.cs_preferences.user.name)
									
									$sender.connect(Form:C1466.cs_preferences.comm.address)
									$sender.send(OB Copy:C1225($requestDraw); $requestPack)
								Else 
									
									If (Form:C1466.cs_preferences.comm.nodes.query("user = :1"; $user).length>0)
										
										$sender.connect(Form:C1466.cs_preferences.comm.nodes.query("user = :1"; $user)[0].address)
										$sender.send(OB Copy:C1225($requestDraw); $requestPack)
									End if 
								End if 
								
							End if 
						End for each 
						
						// update interface
						
						CALL FORM:C1391(This:C1470.listener.window; "app_messenger_main"; False:C215; $request)
						
					End if 
					
				End if 
			End if 
		End if 
	End if 
	
	// cleanup
	
	SET BLOB SIZE:C606($binData; 0)
	SET BLOB SIZE:C606($binBuffer; 0)
	
Function onError($connection : 4D:C1709.TCPConnection; $event : 4D:C1709.TCPEvent)
	
Function onShutdown($connection : 4D:C1709.TCPConnection; $event : 4D:C1709.TCPEvent)
	
Function onTerminate($connection : 4D:C1709.TCPConnection; $event : 4D:C1709.TCPEvent)
	
	