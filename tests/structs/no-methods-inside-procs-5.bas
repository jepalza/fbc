' TEST_MODE : COMPILE_ONLY_FAIL

sub test( )
	type UDT
		dummy as integer
		declare constructor( )
	end type
end sub
