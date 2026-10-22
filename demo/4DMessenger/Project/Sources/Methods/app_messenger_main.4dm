//%attributes = {}

// METHOD      : app_messenger_main
// CREATOR     : omarolleau
// DESCRIPTION :
// UPDATED     : Thu. 16 Oct. 2025 at 16:28 by omarolleau
// ----------------------------------------------------------------------------------

// declare vars

var $win; $w : Integer

ARRAY LONGINT:C221($_win; 0)

// ----------------------------------------------------------------------------------

// the window lives in the worker "app_messenger_main"

If (Process number:C372("app_messenger_main")#Current process:C322)
	
	CALL WORKER:C1389("app_messenger_main"; "app_messenger_main")
	
Else 
	
	// one window at most
	
	WINDOW LIST:C442($_win; *)
	For ($w; 1; Size of array:C274($_win))
		If (Window process:C446($_win{$w})=Current process:C322)
			$win:=$_win{$w}
		End if 
	End for 
	
	If ($win#0)
		
		BRING TO FRONT:C326(Current process:C322)
		
	Else 
		
		$win:=Open form window:C675("fm_messenger_main"; Palette form window:K39:9; Horizontally centered:K39:1; Vertically centered:K39:4)
		SET WINDOW TITLE:C213(Localized string:C991("xTitleApp"); $win)
		DIALOG:C40("fm_messenger_main"; *)
		
	End if 
	
End if 
