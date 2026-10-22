
// CLASS       : Lib_Messenger_Service
// DESCRIPTION : network side of the messenger, one instance in the worker "messenger_net".
//               Listens, sends and keeps the message history, whether the window is open or not.
// ----------------------------------------------------------------------------------

// declare properties

property settings : Object
property listener : cs:C1710.Lib_Messenger_Net_Input
property on_air : Boolean
property window : Integer
property history : Collection

// ----------------------------------------------------------------------------------

// definition

singleton Class constructor()
	
	This:C1470.settings:=Null:C1517
	This:C1470.listener:=Null:C1517
	This:C1470.on_air:=False:C215
	This:C1470.window:=0
	This:C1470.history:=New collection:C1472()
	
	// received user icons are saved here
	
	If (Test path name:C476(Get 4D folder:C485(Active 4D Folder:K5:10)+"Messenger"+Folder separator:K24:12)#Is a folder:K24:2)
		CREATE FOLDER:C475(Get 4D folder:C485(Active 4D Folder:K5:10)+"Messenger")
	End if 
	
Function attach($window : Integer; $settings : Object)
	
	// a window opens: start listening the first time, then show the history
	
	var $update : Object
	
	This:C1470.window:=$window
	
	If (Not:C34(This:C1470.on_air))
		This:C1470.listen($settings)
	Else 
		This:C1470.status()
	End if 
	
	For each ($update; This:C1470.history)
		CALL FORM:C1391(This:C1470.window; "messenger_ui"; "draw"; New object:C1471("update"; $update; "sent"; False:C215))
	End for each 
	
Function detach()
	
	// the window closes: keep listening
	
	This:C1470.window:=0
	
Function listen($settings : Object)
	
	// (re)open the listener with the current settings
	
	This:C1470.stop()
	This:C1470.settings:=$settings
	
	Case of 
		: (This:C1470.settings=Null:C1517)
			
		: (String:C10(This:C1470.settings.comm.address)="")
			BEEP:C151
			
		: (Num(This:C1470.settings.comm.port)=0)
			BEEP:C151
			
		: (String:C10(This:C1470.settings.user.name)="")
			BEEP:C151
			
		Else 
			
			This:C1470.listener:=cs:C1710.Lib_Messenger_Net_Input.new(This:C1470.settings)
			This:C1470.on_air:=True:C214
			
	End case 
	
	This:C1470.status()
	
Function stop()
	
	If (This:C1470.on_air)
		This:C1470.listener.terminate()
	End if 
	
	This:C1470.listener:=Null:C1517
	This:C1470.on_air:=False:C215
	
Function status()
	
	If (This:C1470.window#0)
		CALL FORM:C1391(This:C1470.window; "messenger_ui"; "status"; New object:C1471("on_air"; This:C1470.on_air))
	End if 
	
Function deliver($update : Object; $sent : Boolean)
	
	// a message was received, or a recipient confirmed a message we sent
	
	This:C1470.history.push($update)
	
	If (This:C1470.window#0)
		CALL FORM:C1391(This:C1470.window; "messenger_ui"; "draw"; New object:C1471("update"; $update; "sent"; $sent))
	End if 
	
Function clear()
	
	This:C1470.history:=New collection:C1472()
	
Function send($cargo : Collection; $recipients : Text; $nodes : Collection)
	
	// declare var
	
	var $requestDraw; $sender : Object
	
	var $requestPack : Blob
	
	var $node : Collection
	
	var $user; $userIconPath : Text
	
	If (Not:C34(This:C1470.on_air))
		return 
	End if 
	
	// nodes added in the window apply without saving
	
	This:C1470.settings.comm.nodes:=$nodes
	
	// init request
	
	$requestDraw:=cs:C1710.Lib_Messenger_Net_Request.new()
	$requestDraw.cargo:=$cargo
	
	// define coordinate
	
	$requestDraw.sender:=This:C1470.settings.user.name
	$requestDraw.recipient_list:=$recipients
	
	// send on each node
	
	For each ($user; Split string:C1554($recipients; ","; sk ignore empty strings:K86:1))
		
		$node:=This:C1470.settings.comm.nodes.query("user = :1"; $user)
		If ($node.length=1)
			
			// user icon missing ?
			
			$userIconPath:=Get 4D folder:C485(Active 4D Folder:K5:10)+"Messenger"+Folder separator:K24:12+$user+".png"
			If (Test path name:C476($userIconPath)#Is a document:K24:1)
				
				$requestDraw.way:=x Messenger Get user icon
				$requestDraw.recipient:=$user
				$requestPack:=$requestDraw.requestPack(This:C1470.settings.comm.key)
				
				$sender:=cs:C1710.Lib_Messenger_Net_Output.new(This:C1470.settings)
				
				$sender.connect($node[0].address)
				$sender.send(OB Copy:C1225($requestDraw); $requestPack)
				
			End if 
			
			// make request
			
			$requestDraw.way:=x Messenger Send
			$requestDraw.recipient:=$user
			$requestPack:=$requestDraw.requestPack(This:C1470.settings.comm.key)
			
			$sender:=cs:C1710.Lib_Messenger_Net_Output.new(This:C1470.settings)
			
			$sender.connect($node[0].address)
			$sender.send(OB Copy:C1225($requestDraw); $requestPack)
			
		End if 
	End for each 
