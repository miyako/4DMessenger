//%attributes = {"invisible":true}

// METHOD      : app_messenger_error
// CREATOR     : omarolleau
// DESCRIPTION :
// UPDATED     : Thu. 25 Sep. 2025 at 15:36 by omarolleau
// ----------------------------------------------------------------------------------

// declare parameters

#DECLARE($errors : Collection; $new : Boolean)

// declare vars

var $prc; $prcMain; $win; $left; $top; $right; $bottom; $width; $height; $w : Integer

// ----------------------------------------------------------------------------------

// process dsnt exists make it

$prc:=Process number:C372("app_messenger_error")
If ($prc=0)
	
	CALL WORKER:C1389("app_messenger_error"; "app_messenger_error"; $errors; True:C214)
	
Else 
	
	// query process windows
	
	$prcMain:=Process number:C372("app_messenger_main")
	
	ARRAY LONGINT:C221($_win; 0)
	WINDOW LIST:C442($_win; *)
	
	For ($w; Size of array:C274($_win); 0; -1)
		
		If (Window process:C446($_win{$w})=$prcMain)
			
			GET WINDOW RECT:C443($left; $top; $right; $bottom; $_win{$w})
			
			$width:=($right-$left)-640
			$height:=($bottom-$top)-280
			
			$left:=$left+($width/2)
			$top:=$top+($height/2)
			$right:=$left+640
			$bottom:=$top+280
			
			$win:=Open window:C153($left; $top; $right; $bottom; Dialogue modal déplaçable:K34:7; "app_messenger_error")
			DIALOG:C40("fm_messenger_errors"; New object:C1471("errors"; $errors))
			CLOSE WINDOW:C154($win)
			
			break
			
		End if 
	End for 
	
	KILL WORKER:C1390($prc)
	
End if 
