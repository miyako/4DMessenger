
// CLASS       : Lib_Messenger_Net_Request
// CREATOR     : omarolleau
// DESCRIPTION :
// UPDATED     : Thu. 16 Oct. 2025 at 15:38 by omarolleau
// ----------------------------------------------------------------------------------

// declare properties

property way : Integer
property sender : Text
property recipient : Text
property recipient_list : Text
property date : Date
property time : Time
property id : Text
property cargo : Collection

// ----------------------------------------------------------------------------------

// definition

Class constructor()
	
	// define request struc
	
	This:C1470.way:=x Messenger Clear
	This:C1470.sender:=""
	This:C1470.recipient:=""
	This:C1470.recipient_list:=""
	This:C1470.date:=Current date:C33
	This:C1470.time:=Current time:C178
	This:C1470.id:=Generate UUID:C1066
	This:C1470.cargo:=New collection:C1472()
	
	
Function requestPack($key : Text)->$requestRaw : Blob
	
	// declare vars
	
	var $offset : Integer:=0
	
	var $salt; $originSize : Integer
	
	var $encrypted : Boolean
	
	var $originHash : Text
	
	// timestamp
	
	This:C1470.date:=Current date:C33
	This:C1470.time:=Current time:C178
	
	// define way
	
	INTEGER TO BLOB:C548(This:C1470.way; $requestRaw; Ordre octets PC:K22:3; *)
	
	// define sender
	
	TEXT TO BLOB:C554(This:C1470.sender; $requestRaw; UTF8 texte avec longueur:K22:16; *)
	
	// define recipient
	
	TEXT TO BLOB:C554(This:C1470.recipient; $requestRaw; UTF8 texte avec longueur:K22:16; *)
	
	// define recipient_list
	
	TEXT TO BLOB:C554(This:C1470.recipient_list; $requestRaw; UTF8 texte avec longueur:K22:16; *)
	
	// define date
	
	LONGINT TO BLOB:C550(Year of:C25(This:C1470.date); $requestRaw; Ordre octets PC:K22:3; *)
	INTEGER TO BLOB:C548(Month of:C24(This:C1470.date); $requestRaw; Ordre octets PC:K22:3; *)
	INTEGER TO BLOB:C548(Day of:C23(This:C1470.date); $requestRaw; Ordre octets PC:K22:3; *)
	
	// define time
	
	LONGINT TO BLOB:C550(This:C1470.time; $requestRaw; Ordre octets PC:K22:3; *)
	
	// define id
	
	TEXT TO BLOB:C554(This:C1470.id; $requestRaw; UTF8 texte avec longueur:K22:16; *)
	
	// define cargo
	
	TEXT TO BLOB:C554(JSON Stringify:C1217(This:C1470.cargo); $requestRaw; UTF8 texte sans longueur:K22:17; *)
	
	// secure raw size
	
	$offset:=0
	$originSize:=BLOB size:C605($requestRaw)
	INSERT IN BLOB:C559($requestRaw; 0; 4; 0x0000)
	LONGINT TO BLOB:C550($originSize; $requestRaw; Ordre octets PC:K22:3; $offset)
	
	// secure raw hash
	
	$originHash:=Generate digest:C1147($requestRaw; Digest MD5:K66:1)
	
	// encryption
	
	$salt:=Month of:C24(Current date:C33)
	$salt:=Choose:C955($salt ?? 3; $salt ?- 3; $salt ?+ 3)
	$encrypted:=Encrypt data BLOB:C1773($requestRaw; $key; $salt; $requestRaw)
	
	// secure raw hash write
	
	$offset:=0
	INSERT IN BLOB:C559($requestRaw; 0; 32; 0x0000)
	TEXT TO BLOB:C554($originHash; $requestRaw; Mac texte sans longueur:K22:10; $offset)
	
	// define length
	
	$offset:=0
	INSERT IN BLOB:C559($requestRaw; 0; 4; 0x0000)
	LONGINT TO BLOB:C550(BLOB size:C605($requestRaw); $requestRaw; Ordre octets PC:K22:3; $offset)
	
Function requestUnPack($key : Text; $requestRaw : Blob)->$success : Boolean
	
	// declare vars
	
	var $offset : Integer:=0
	var $salt : Integer
	var $originSize : Integer
	
	var $dateRaw : Text
	var $originHash : Text
	
	var $decrypted : Boolean
	
	// primary control
	
	$success:=False:C215
	ASSERT:C1129(BLOB size:C605($requestRaw)>37; "4D Messenger : Request bad format")
	
	// read length request
	
	$originSize:=BLOB to longint:C551($requestRaw; Ordre octets PC:K22:3)
	ASSERT:C1129(BLOB size:C605($requestRaw)=$originSize; "4D Messenger : Request corrupted")
	DELETE FROM BLOB:C560($requestRaw; 0; 4)
	
	// read secure hash
	
	$offset:=0
	
	$originHash:=BLOB to text:C555($requestRaw; Mac texte sans longueur:K22:10; $offset; 32)
	DELETE FROM BLOB:C560($requestRaw; 0; 32)
	
	// decryption
	
	$salt:=Month of:C24(Current date:C33)
	$salt:=Choose:C955($salt ?? 3; $salt ?- 3; $salt ?+ 3)
	$decrypted:=Decrypt data BLOB:C1774($requestRaw; $key; $salt; $requestRaw)
	
	If ($decrypted)
		
		// read secure length
		
		$offset:=0
		$originSize:=BLOB to longint:C551($requestRaw; Ordre octets PC:K22:3; $offset)
		If ($originSize>0)
			
			// restaure original size
			
			SET BLOB SIZE:C606($requestRaw; $originSize+4)
			
			If ($originHash=Generate digest:C1147($requestRaw; Digest MD5:K66:1))
				
				// cleanup
				
				DELETE FROM BLOB:C560($requestRaw; 0; 4)
				$offset:=0
				
				// read way
				
				This:C1470.way:=BLOB to integer:C549($requestRaw; Ordre octets PC:K22:3; $offset)
				
				// read sender
				
				This:C1470.sender:=BLOB to text:C555($requestRaw; UTF8 texte avec longueur:K22:16; $offset)
				
				// read recipient
				
				This:C1470.recipient:=BLOB to text:C555($requestRaw; UTF8 texte avec longueur:K22:16; $offset)
				
				// read recipient_list
				
				This:C1470.recipient_list:=BLOB to text:C555($requestRaw; UTF8 texte avec longueur:K22:16; $offset)
				
				// read date
				
				// built with Add to date: Date() of a text depends on the system date format
				
				var $year; $month; $day : Integer
				$year:=BLOB to longint:C551($requestRaw; Ordre octets PC:K22:3; $offset)
				$month:=BLOB to integer:C549($requestRaw; Ordre octets PC:K22:3; $offset)
				$day:=BLOB to integer:C549($requestRaw; Ordre octets PC:K22:3; $offset)
				This:C1470.date:=Add to date(!00-00-00!; $year; $month; $day)
				
				// read time
				
				This:C1470.time:=BLOB to longint:C551($requestRaw; Ordre octets PC:K22:3; $offset)
				
				// read id
				
				This:C1470.id:=BLOB to text:C555($requestRaw; UTF8 texte avec longueur:K22:16; $offset)
				
				// read cargo
				
				This:C1470.cargo:=JSON Parse:C1218(BLOB to text:C555($requestRaw; UTF8 texte sans longueur:K22:17; $offset))
				
				// unpack ok
				
				$success:=True:C214
				
			Else 
				
				// unpack ko
				
				$success:=False:C215
				
			End if 
			
		Else 
			
			// unpack ko
			
			$success:=False:C215
			
		End if 
		
	Else 
		
		// unpack ko
		
		$success:=False:C215
		
	End if 
	