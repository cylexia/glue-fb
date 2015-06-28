' sample
' (c)2014 by Cylexia
'
' desc
'

namespace Ext<sample>
    declare function init( pf as string = "ui." ) as integer
    declare function glueInit() as integer
    declare function glueCommand( byref w as string, byref vars as string ) as integer
    declare function _rtCallBackHandler( byref d as string, byref label as string ) as integer
    
    dim prefix as string
    
    function init( pf as string ) as integer
        prefix = pf
        if( glueInit() = 1 ) then
            return Glue.addPlugin( @ExtUI.glueCommand )
        end if
    end function
    
    function glueInit() as integer
        return 1
    end function
    
    function glueCommand( byref w as string, byref vars as string ) as integer
        dim c as string = Dict.valueOf( w, "_" ), cs as string
        dim ts as string, tn as single, ti as integer
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
            case "command"
                ' do something
                
            case else:
                return -1       ' not ours
        end select
        return 1                ' we handled it
    end function
end namespace
