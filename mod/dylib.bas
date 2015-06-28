#ifndef __LIBGLUE__
#include "../libglue.bas"
#endif

' External console module
' (c)2014 by Cylexia
'
' Provides console and basic graphics under "console.X"
'

' ----------------------------------------------------- Dynamic library support

namespace ExtDyLib
    declare function init( pf as string = "dylib." ) as integer
    declare function glueCommand( byref w as string, byref vars as string ) as integer
   
    dim prefix as string
    dim symmap as string
    dim symcall(0 to 20) as function( byref w as string, byref v as string ) as integer

    function init( pf as string = "dylib." ) as integer
        prefix = pf
        symmap = Dict.create()
        Dict.set( symmap, "_count", "0" )
        return Glue.addPlugin( @ExtDyLib.glueCommand )
    end function
    
    function glueCommand( byref w as string, byref vars as string ) as integer
        dim c as string = Dict.valueOf( w, "_" )
        dim ts as string, tn as single, ti as integer
        select case c
            case "dylib.load"
                dim library as any ptr = dylibload( Dict.valueOf( w, "dylib.load" ) )
                if( library <> 0 ) then
                    ti = Dict.intValueOf( symmap, "_count" )
                    if( ti <= ubound( symcall ) ) then
                        dim func as any ptr = dylibsymbol( library, "glueCommand" )
                        if( func <> 0 ) then
                            ' try initing the library
                            dim initfunc as function() as integer
                            initfunc = dylibsymbol( library, "glueInit" )
                            if( initfunc <> 0 ) then
                                if( initfunc() <> 0 ) then
                                    symcall(ti) = func
                                    Dict.set( symmap, (Dict.valueOf( w, "as" ) & "."), str( ti ) )
                                    ti += 1
                                    Dict.set( symmap, "_count", str( ti ) )
                                    return 1
                                else
                                    print "[Glue] DYLIB: library init() failed"
                                end if
                            else
                                print "[Glue] DYLIB: unable to load init() symbol"
                            end if
                        else
                            print "[Glue] DYLIB: unable to load call() symbol"
                        end if
                    else
                        print "[Glue] DYLIB: too many symbols"
                    end if
                else
                    print "[Glue] DYLIB: unable to load library"
                end if
                return 0
            case "dylib.unload"
                ' unsupported at the moment
            case else
                ti = instr( c, "." )
                if( ti > 0 ) then
                    ts = mid( c, 1, ti )
                    if( Dict.containsKey( symmap, ts ) ) then
                        dim nn as string = mid( Dict.valueOf( w, "_" ), (ti + 1) )
                        Dict.set( w, "_", nn )
                        Dict.set( w, nn, Dict.valueOf( w, "_" ) )
                        ti = Dict.intValueOf( symmap, ts, -1 )
                        return symcall(ti)( w, vars )
                    end if
                end if
                return -1
        end select
    end function
end namespace