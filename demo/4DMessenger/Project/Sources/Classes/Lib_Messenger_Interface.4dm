
// CLASS       : Lib_Messenger_Interface
// CREATOR     : omarolleau
// DESCRIPTION :
// UPDATED     : Thu. 16 Oct. 2025 at 16:33 by omarolleau
// ----------------------------------------------------------------------------------

// declare properties

property expansion_value : Integer
property listen_on : Boolean

// ----------------------------------------------------------------------------------

// definition

Class constructor()
	
	// init expansion properties
	
	This:C1470.expansion_value:=515
	This:C1470.listen_on:=False:C215
	
	// init area output
	
	WA SET PREFERENCE:C1041(*; "zMessOutput"; WA enable URL drop:K62:8; False:C215)
	WA SET PREFERENCE:C1041(*; "zMessOutput"; WA enable Web inspector:K62:7; True:C214)
	WA SET PREFERENCE:C1041(*; "zMessOutput"; WA enable contextual menu:K62:6; True:C214)
	
	WA OPEN URL:C1020(*; "zMessOutput"; Get 4D folder:C485(Current resources folder:K5:16)+"frames"+Folder separator:K24:12+"output.html")
	
	// init area input
	
	WA SET PREFERENCE:C1041(*; "zMessInput"; WA enable URL drop:K62:8; True:C214)
	WA SET PREFERENCE:C1041(*; "zMessInput"; WA enable Web inspector:K62:7; True:C214)
	WA SET PREFERENCE:C1041(*; "zMessInput"; WA enable contextual menu:K62:6; True:C214)
	
	WA OPEN URL:C1020(*; "zMessInput"; Get 4D folder:C485(Current resources folder:K5:16)+"frames"+Folder separator:K24:12+"input.html")
	
	// init menu remap
	
	ARRAY TEXT:C222($_filterPattern; 1)
	ARRAY BOOLEAN:C223($_filterAuth; 1)
	
	$_filterPattern{1}:="*callContextMenu?*"
	$_filterAuth{1}:=False:C215
	
	WA SET EXTERNAL LINKS FILTERS:C1032(*; "zMessOutput"; $_filterPattern; $_filterAuth)
	WA SET EXTERNAL LINKS FILTERS:C1032(*; "zMessInput"; $_filterPattern; $_filterAuth)
	
	// init interface button
	
	OBJECT SET ENABLED:C1123(*; "bNodeDel"; False:C215)
	OBJECT SET ENABLED:C1123(*; "bChannelDel"; False:C215)
	
	
Function expansion($expansion_properties : Boolean)
	
	// vars
	
	var $left; $top; $right; $bottom : Integer
	
	// calc
	
	If (Count parameters:C259=1)
		If ($expansion_properties)
			This:C1470.expansion_value:=515
		Else 
			This:C1470.expansion_value:=-515
		End if 
	End if 
	
	// apply
	
	GET WINDOW RECT:C443($left; $top; $right; $bottom; Current form window:C827)
	SET WINDOW RECT:C444($left; $top; $right+This:C1470.expansion_value; $bottom; Current form window:C827)
	This:C1470.expansion_value:=-This:C1470.expansion_value
	
	
Function actionCleanupCach()
	
	// declare var
	
	var $user : Text
	
	var $file : 4D:C1709.File
	
	var $i : Integer
	
	// cleanup icon cach
	
	ARRAY TEXT:C222($_files; 0)
	DOCUMENT LIST:C474(Get 4D folder:C485(Active 4D Folder:K5:10)+"Messenger"; $_files)
	
	For ($i; Size of array:C274($_files); 1; -1)
		
		$file:=File:C1566(Get 4D folder:C485(Active 4D Folder:K5:10)+"Messenger"+Folder separator:K24:12+$_files{$i}; fk platform path:K87:2)
		If (Form:C1466.cs_preferences.comm.nodes.query("user = :1"; $file.name).length=0)
			
			If ($file.extension=".png") & ($file.name#Form:C1466.cs_preferences.user.name)
				DELETE DOCUMENT:C159($file.platformPath)
			End if 
			
		End if 
	End for 
	
Function actioListenClose()
	
	If (This:C1470.listen_on=True:C214)
		Form:C1466.cs_net_input.terminate()
	End if 
	
Function actioListenMessage()
	
	If (This:C1470.listen_on=True:C214)
		Form:C1466.cs_net_input.terminate()
	End if 
	
	This:C1470.listen_on:=False:C215
	
	Case of 
		: (Form:C1466.cs_preferences.comm.address="")
			BEEP:C151
			
		: (Form:C1466.cs_preferences.comm.iPort=0)
			BEEP:C151
			
		: (Form:C1466.cs_preferences.user.name="")
			BEEP:C151
			
		Else 
			
			Form:C1466.cs_net_input:=cs:C1710.Lib_Messenger_Net_Input.new(Current form window:C827; Form:C1466.cs_preferences)
			This:C1470.listen_on:=True:C214
			
	End case 
	
Function actioClearHistory()
	
	WA EXECUTE JAVASCRIPT FUNCTION:C1043(*; "zMessOutput"; "clearOutput"; *)
	
	GOTO OBJECT:C206(*; "zMessInput")
	
Function actioSendMessage()
	
	// declare var
	
	var $cargo : Collection
	
	var $requestDraw; $sender : Object
	
	var $requestPack : Blob
	
	var $users; $node : Collection
	
	var $user; $userIconPath : Text
	
	// load users from channel
	
	If (This:C1470.listen_on=True:C214)
		
		$users:=Form:C1466.cs_preferences.comm.channels.query("name = :1"; mChannel{mChannel})
		If ($users.length=0)
			
			ALERT:C41(Localized string:C991("xErrorChannelMissing"))
			
		Else 
			
			// split users node for loop
			
			If ($users[0].users="")
				
				ALERT:C41(Localized string:C991("xErrorChannelNoUser"))
				
			Else 
				
				// init request
				
				$requestDraw:=cs:C1710.Lib_Messenger_Net_Request.new()
				
				// load cargo
				
				WA EXECUTE JAVASCRIPT FUNCTION:C1043(*; "zMessInput"; "grabCargo"; $cargo)
				$requestDraw.cargo:=$cargo
				
				// define coordinate
				
				$requestDraw.sender:=Form:C1466.cs_preferences.user.name
				$requestDraw.recipient_list:=$users[0].users
				
				// send on each node
				For each ($user; Split string:C1554($users[0].users; ","; sk ignore empty strings:K86:1))
					
					$node:=Form:C1466.cs_preferences.comm.nodes.query("user = :1"; $user)
					If ($node.length=1)
						
						// user icon missing ?
						$userIconPath:=Get 4D folder:C485(Active 4D Folder:K5:10)+"Messenger"+Folder separator:K24:12+$user+".png"
						If (Test path name:C476($userIconPath)#Is a document:K24:1)
							
							$requestDraw.way:=x Messenger Get user icon
							$requestDraw.recipient:=$user
							$requestPack:=$requestDraw.requestPack(Form:C1466.cs_preferences.comm.key)
							
							$sender:=cs:C1710.Lib_Messenger_Net_Output.new(Form:C1466.cs_preferences)
							
							$sender.connect($node[0].address)
							$sender.send(OB Copy:C1225($requestDraw); $requestPack)
							
						End if 
						
						// make request
						$requestDraw.way:=x Messenger Send
						$requestDraw.recipient:=$user
						$requestPack:=$requestDraw.requestPack(Form:C1466.cs_preferences.comm.key)
						
						$sender:=cs:C1710.Lib_Messenger_Net_Output.new(Form:C1466.cs_preferences)
						
						$sender.connect($node[0].address)
						$sender.send(OB Copy:C1225($requestDraw); $requestPack)
						
					End if 
				End for each 
				
			End if 
		End if 
		
	End if 
	
	
Function callContextMenu($area : Text)
	
	// declare var
	
	var $url; $menu; $menuChoice : Text
	
	var $target; $contents : Object
	
	var $downloaded : 4D:C1709.File
	
	var $bin : Blob
	
	// read url
	
	$url:=WA Get last filtered URL:C1035(*; $area)
	
	// retry parameter
	
	$target:=JSON Parse:C1218(Split string:C1554($url; "?")[1])
	
	// make menu
	
	$menu:=Create menu:C408
	
	If ($area="zMessOutput")
		
		APPEND MENU ITEM:C411($menu; $target.title)
		APPEND MENU ITEM:C411($menu; "-")
		APPEND MENU ITEM:C411($menu; Localized string:C991("xMenuDownload"))
		APPEND MENU ITEM:C411($menu; "-")
		APPEND MENU ITEM:C411($menu; Localized string:C991("CommonCancel"))
		
		SET MENU ITEM PARAMETER:C1004($menu; 3; "download")
		
		SET MENU ITEM STYLE:C425($menu; 1; Bold:K14:2)
		
		SET MENU ITEM ICON:C984($menu; 1; "path:/RESOURCES/images/lists/List_File_Win.svg")
		SET MENU ITEM ICON:C984($menu; 3; "path:/RESOURCES/images/lists/List_Folder_Win.svg")
		SET MENU ITEM ICON:C984($menu; 5; "path:/RESOURCES/images/lists/List_Cancel.svg")
		
	Else 
		
		APPEND MENU ITEM:C411($menu; $target.title)
		APPEND MENU ITEM:C411($menu; "-")
		APPEND MENU ITEM:C411($menu; Localized string:C991("xMenuDelete"))
		APPEND MENU ITEM:C411($menu; Localized string:C991("xMenuDeleteAll"))
		APPEND MENU ITEM:C411($menu; "-")
		APPEND MENU ITEM:C411($menu; Localized string:C991("xMenuDownload"))
		APPEND MENU ITEM:C411($menu; "-")
		APPEND MENU ITEM:C411($menu; Localized string:C991("CommonCancel"))
		
		SET MENU ITEM PARAMETER:C1004($menu; 3; "delete")
		SET MENU ITEM PARAMETER:C1004($menu; 4; "delete_all")
		SET MENU ITEM PARAMETER:C1004($menu; 6; "download")
		
		SET MENU ITEM STYLE:C425($menu; 1; Bold:K14:2)
		
		SET MENU ITEM ICON:C984($menu; 1; "path:/RESOURCES/images/lists/List_File_Win.svg")
		SET MENU ITEM ICON:C984($menu; 3; "path:/RESOURCES/images/lists/List_Delete.svg")
		SET MENU ITEM ICON:C984($menu; 4; "path:/RESOURCES/images/lists/List_Delete.svg")
		SET MENU ITEM ICON:C984($menu; 6; "path:/RESOURCES/images/lists/List_Folder_Win.svg")
		SET MENU ITEM ICON:C984($menu; 8; "path:/RESOURCES/images/lists/List_Cancel.svg")
		
	End if 
	
	$menuChoice:=Dynamic pop up menu:C1006($menu)
	
	RELEASE MENU:C978($menu)
	
	// action
	
	Case of 
		: ($menuChoice="delete")
			
			WA EXECUTE JAVASCRIPT FUNCTION:C1043(*; $area; "crateDelete"; *; $target.hash)
			
		: ($menuChoice="delete_all")
			
			WA EXECUTE JAVASCRIPT FUNCTION:C1043(*; $area; "crateDelete"; *; "")
			
		: ($menuChoice="download")
			
			WA EXECUTE JAVASCRIPT FUNCTION:C1043(*; $area; "crateDownload"; $contents; $target.hash)
			
			$downloaded:=File:C1566(System folder:C487(Home folder:K41:19)+"Downloads"+Folder separator:K24:12+$contents.title; fk platform path:K87:2)
			BASE64 DECODE:C896(Delete string:C232($contents.contents; 1; Position:C15("base64,"; $contents.contents)+6); $bin)
			
			BLOB TO DOCUMENT:C526($downloaded.platformPath; $bin)
			SET BLOB SIZE:C606($bin; 0)
			
			SHOW ON DISK:C922($downloaded.platformPath; *)
			
	End case 
	