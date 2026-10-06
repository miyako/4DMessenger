//%attributes = {}

// METHOD      : app_messenger_main
// CREATOR     : omarolleau
// DESCRIPTION :
// UPDATED     : Thu. 16 Oct. 2025 at 16:28 by omarolleau
// ----------------------------------------------------------------------------------

// declare parameters

#DECLARE($new : Boolean; $update : Object)

// declare vars

var $prc; $win; $prm : Integer

var $request; $pathIcon : Text

var $requestDraw; $sender : Object

var $requestPack : Blob

// ----------------------------------------------------------------------------------

// found process

$prc:=Process number:C372("app_messenger_main")
$prm:=Count parameters:C259

// exec

Case of 
	: ($prc=0)
		
		// process not found make it
		
		CALL WORKER:C1389("app_messenger_main"; "app_messenger_main"; True:C214)
		
	: ($prm=0)
		
		// pass to front process
		
		BRING TO FRONT:C326($prc)
		
	: ($prm=1)
		
		// make new windows
		
		If ($new)
			
			$win:=Open form window:C675("fm_messenger_main"; Palette form window:K39:9; Horizontally centered:K39:1; Vertically centered:K39:4; *)
			SET WINDOW TITLE:C213("4D Messager | PRC:"+String:C10($prc)+" | WIN:"+String:C10($win); $win)
			DIALOG:C40("fm_messenger_main"; *)
			
		End if 
		
	: ($prm=2)
		
		// init user icon path
		
		$pathIcon:=Get 4D folder:C485(Active 4D Folder:K5:10)+"Messenger"+Folder separator:K24:12
		If (Test path name:C476($pathIcon)#Is a folder:K24:2)
			CREATE FOLDER:C475(Get 4D folder:C485(Active 4D Folder:K5:10)+"Messenger")
		End if 
		
		// init var area
		
		WA EXECUTE JAVASCRIPT FUNCTION:C1043(*; "zMessOutput"; "avatarPathSet"; *; Convert path system to POSIX:C1106(Get 4D folder:C485(Active 4D Folder:K5:10)+"Messenger"))
		
		// update content windows
		
		WA EXECUTE JAVASCRIPT FUNCTION:C1043(*; "zMessOutput"; "drawMessage"; *; $update)
		
End case 
