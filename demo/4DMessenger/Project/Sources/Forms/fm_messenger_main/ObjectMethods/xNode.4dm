
// METHOD : [projectForm]/fm_messenger_main/xNode
// CREATOR     : omarolleau
// DESCRIPTION :
// UPDATED     : Fri. 26 Sep. 2025 at 12:33 by omarolleau
// ----------------------------------------------------------------------------------

// declare vars

var $evs : Integer

// ----------------------------------------------------------------------------------

// events

$evs:=FORM Event:C1606.code

Case of 
	: ($evs=Sur nouvelle sélection:K2:29)
		
		OBJECT SET ENABLED:C1123(*; "bNodeDel"; (xNode_set.length>0))
		
End case 
