#ifndef __LIBGLUE__
#include "../libglue.bas"
#endif

' Standard date/time module
' (c)2014 by Cylexia
'
' Provides access to date and time
'

' ------------------------------------------------------ Standard Date and Time
namespace StdDateTime
    declare function init( pf as string = "" ) as integer
    declare function glueCommand( byref w as string, byref vars as string ) as integer

    dim prefix as string
    
    function init( pf as string = "" ) as integer
        prefix = pf
        return 1
    end function
    
    function glueCommand( byref w as string, byref vars as string ) as integer
        dim c as string = Dict.valueOf( w, "_" ), cs as string
        dim ts as string, tn as single
        if( prefix <> "" ) then
            if( instrrev( c, prefix ) = 0 ) then
                return -1
            else
                cs = mid( c, (len( prefix ) + 1) )
            end if
        else 
            cs = c
        end if
        select case cs
            case "hour":    SET_INTO( mid( time(), 1, 2 ) )
            case "minute":  SET_INTO( mid( time(), 4, 2 ) )
            case "second":  SET_INTO( mid( time(), 7, 2 ) )
            case "day":     SET_INTO( mid( date(), 4, 2 ) )
            case "month":   SET_INTO( mid( date(), 1, 2 ) )
            case "year":    SET_INTO( mid( date(), 7, 4 ) )
            case "dateserial"
                ts = (date() & time())
                ts = mid( ts, 7, 4 ) & mid( ts, 1, 2 ) & mid( ts, 4, 2 ) & _
                        mid( ts, 11, 2 ) & mid( ts, 14, 2 ) & mid( ts, 17, 2 )
                SET_INTO( ts )
            ' timer is in StdBasic
            case else:
                return -1       ' not ours
        end select
        return 1                ' we handled it
    end function
end namespace

