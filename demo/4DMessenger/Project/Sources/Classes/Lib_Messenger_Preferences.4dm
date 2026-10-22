
// CLASS       : Lib_Messenger_Preferences
// CREATOR     : omarolleau
// DESCRIPTION :
// UPDATED     : Tue. 7 Oct. 2025 at 15:48 by omarolleau
// ----------------------------------------------------------------------------------

// declare properties

property path : 4D:C1709.File
property comm : Object
property user : Object

// ----------------------------------------------------------------------------------

// definition

Class constructor()
	
	// declare vars
	
	var $avatar : Picture
	
	var $avatarPath : Text
	
	ARRAY TEXT:C222(mChannel; 0)
	
	// init folder preferences
	
	If (Folder:C1567(Get 4D folder:C485(Active 4D Folder:K5:10)+"Messenger"; fk platform path:K87:2).exists=False:C215)
		CREATE FOLDER:C475(Get 4D folder:C485(Active 4D Folder:K5:10)+"Messenger")
	End if 
	
	// init path prefs
	
	This:C1470.path:=File:C1566(Get 4D folder:C485(Active 4D Folder:K5:10)+"Messenger"+Folder separator:K24:12+"4D messenger - "+Current machine:C483+".json"; fk platform path:K87:2)
	
	// new preferences file
	
	If (This:C1470.path.exists=False:C215)
		
		// init default communication
		
		This:C1470.comm:=New object:C1471(\
			"key"; Generate UUID:C1066; \
			"address"; ""; \
			"port"; 19820; \
			"nodes"; New collection:C1472(); \
			"channels"; New collection:C1472(New object:C1471("name"; "Default"; "users"; "")); \
			"channel_curent"; "Default")
		
		// init default user
		
		This:C1470.user:=New object:C1471(\
			"name"; Current system user:C484)
		
		// init default icon
		
		$avatarPath:=Get 4D folder:C485(Active 4D Folder:K5:10)+"Messenger"+Folder separator:K24:12+This:C1470.user.name+".png"
		If (Test path name:C476($avatarPath)#Is a document:K24:1)
			
			READ PICTURE FILE:C678(Get 4D folder:C485(Current resources folder:K5:16)+"images"+Folder separator:K24:12+"defaults"+Folder separator:K24:12+"user.svg"; $avatar)
			WRITE PICTURE FILE:C680($avatarPath; $avatar; ".png")
			
		End if 
		
		OBJECT Get pointer:C1124(Object named:K67:5; "iUserAvatar")->:=$avatar
		
		// write file
		
		var $this : Object
		$this:=OB Copy:C1225(This:C1470)
		OB REMOVE:C1226($this; "path")
		
		TEXT TO DOCUMENT:C1237(This:C1470.path.platformPath; JSON Stringify:C1217($this; *); "UTF-8"; Document unchanged:K24:18)
		
	Else 
		
		This:C1470.comm:=New object:C1471(\
			"key"; Generate UUID:C1066; \
			"address"; ""; \
			"port"; 19820; \
			"nodes"; New collection:C1472(); \
			"channels"; New collection:C1472(New object:C1471("name"; "Default"; "users"; "")); \
			"channel_curent"; "Default")
		
		This:C1470.user:=New object:C1471(\
			"name"; Current system user:C484)
		
	End if 
	
Function save()
	
	// declare var
	
	var $bin : Blob
	
	var $store : Object
	
	var $avatarPath; $channelDefine : Text
	
	var $avatar : Picture
	
	// copy raw
	
	$store:=JSON Parse:C1218(JSON Stringify:C1217(This:C1470))
	
	// init channel
	
	If (Not:C34(Undefined:C82(mChannel)))
		$channelDefine:=mChannel{mChannel}
	End if 
	
	ARRAY TEXT:C222(mChannel; 0)
	COLLECTION TO ARRAY:C1562(This:C1470.comm.channels; mChannel; "name")
	SORT ARRAY:C229(mChannel; >)
	
	If (This:C1470.comm.channels.length=0)
		
		This:C1470.comm.channels:=New collection:C1472(New object:C1471("name"; "Default"; "users"; ""))
		This:C1470.comm.channel_curent:="Default"
		mChannel:=1
		
	End if 
	
	If (Find in array:C230(mChannel; $channelDefine)>0)
		
		mChannel:=Find in array:C230(mChannel; $channelDefine)
		This:C1470.comm.channel_curent:=$channelDefine
	Else 
		
		mChannel:=1
	End if 
	
	// update user icon
	
	$avatarPath:=Get 4D folder:C485(Active 4D Folder:K5:10)+"Messenger"+Folder separator:K24:12+Form:C1466.cs_preferences.user.name+".png"
	If (Test path name:C476($avatarPath)#Is a document:K24:1)
		
		$avatar:=OBJECT Get pointer:C1124(Object named:K67:5; "iUserAvatar")->
		
		If (Picture size:C356($avatar)=0)
			READ PICTURE FILE:C678(Get 4D folder:C485(Current resources folder:K5:16)+"images"+Folder separator:K24:12+"defaults"+Folder separator:K24:12+"user.svg"; $avatar)
			OBJECT Get pointer:C1124(Object named:K67:5; "iUserAvatar")->:=$avatar
		End if 
		
	Else 
		
		$avatar:=OBJECT Get pointer:C1124(Object named:K67:5; "iUserAvatar")->
	End if 
	
	WRITE PICTURE FILE:C680($avatarPath; $avatar; ".png")
	
	// write on disk
	
	var $this : Object
	$this:=OB Copy:C1225(This:C1470)
	OB REMOVE:C1226($this; "path")
	
	TEXT TO DOCUMENT:C1237(This:C1470.path.platformPath; JSON Stringify:C1217($this; *); "UTF-8"; Document unchanged:K24:18)
	
	// show preferences files ?
	
	If (Shift down:C543)
		SHOW ON DISK:C922(This:C1470.path.platformPath; *)
	End if 
	
Function load()
	
	// declare var
	
	var $store : Object
	
	var $avatarPath : Text
	
	var $avatar : Picture
	
	var $net : Variant
	
	// load from disk
	
	$store:=JSON Parse:C1218(Document to text:C1236(This:C1470.path.platformPath; "UTF-8"; Document unchanged:K24:18))
	
	// init path
	
	This:C1470.path:=File:C1566(Get 4D folder:C485(Active 4D Folder:K5:10)+"Messenger"+Folder separator:K24:12+"4D messenger - "+Current machine:C483+".json"; fk platform path:K87:2)
	
	This:C1470.comm.key:=$store.comm.key
	This:C1470.comm.address:=$store.comm.address
	This:C1470.comm.port:=$store.comm.port
	This:C1470.comm.nodes:=$store.comm.nodes
	This:C1470.comm.channels:=$store.comm.channels
	This:C1470.comm.channel_curent:=$store.comm.channel_curent
	
	This:C1470.user.name:=$store.user.name
	
	// init avatar
	
	$avatarPath:=Get 4D folder:C485(Active 4D Folder:K5:10)+"Messenger"+Folder separator:K24:12+Form:C1466.cs_preferences.user.name+".png"
	If (Test path name:C476($avatarPath)#Is a document:K24:1)
		
		READ PICTURE FILE:C678(Get 4D folder:C485(Current resources folder:K5:16)+"images"+Folder separator:K24:12+"defaults"+Folder separator:K24:12+"user.svg"; $avatar)
		WRITE PICTURE FILE:C680($avatarPath; $avatar; ".png")
	Else 
		
		READ PICTURE FILE:C678($avatarPath; $avatar)
	End if 
	
	OBJECT Get pointer:C1124(Object named:K67:5; "iUserAvatar")->:=$avatar
	
	// init channel
	
	ARRAY TEXT:C222(mChannel; 0)
	COLLECTION TO ARRAY:C1562(This:C1470.comm.channels; mChannel; "name")
	SORT ARRAY:C229(mChannel; >)
	
	If (This:C1470.comm.channels.length=0)
		
		This:C1470.comm.channels:=New collection:C1472(New object:C1471("name"; "Default"; "users"; ""))
		This:C1470.comm.channel_curent:="Default"
		mChannel:=1
		
	End if 
	
	If (Find in array:C230(mChannel; This:C1470.comm.channel_curent)>0)
		
		mChannel:=Find in array:C230(mChannel; This:C1470.comm.channel_curent)
	Else 
		
		mChannel:=1
	End if 
	
	// init ipp
	
	If (This:C1470.comm.address="")
		
		$net:=System info:C1571.networkInterfaces
		
		If ($net.length>0)
			
			$net:=$net[0].ipAddresses.query("type = ipv4")
			If ($net.length=1)
				
				This:C1470.comm.address:=$net[0].ip
				
			End if 
		End if 
	End if 
	