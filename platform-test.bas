'platform test
#include "libmain.bas"

dim as integer i = 1
dim as string cmd = ""
while( len( command( i ) ) > 0 )
    if( i > 1 ) then
        cmd &= " "
    end if
    cmd &= command( i )
    i += 1
wend

dim as string rev = ""
i = (len( cmd ) - 1)
while( i > 0 )
    rev &= chr( asc( cmd, i ) )
    i -= 1
wend

Utils.writeFile( "exec.txt", rev )
end

