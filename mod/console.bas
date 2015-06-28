#ifndef __LIBGLUE__
#include "../libglue.bas"
#endif

' External console module
' (c)2014 by Cylexia
'
' Provides console and basic graphics under "console.X"
'

' ------------------------------------------------------ External Console Stuff
namespace ExtConsole
    declare function init( pf as string = "console." ) as integer
    declare function glueCommand( byref w as string, byref vars as string ) as integer
    declare sub drawFrame( x as integer, y as integer, w as integer, h as integer, f as integer )
    
    dim prefix as string

    function init( pf as string = "console." ) as integer
        prefix = pf
        return Glue.addPlugin( @ExtConsole.glueCommand )
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
            case "cls", "clearscreen", "clear"
                cls
            case "clswithtitle", "clearscreenwithtitle":
                ts = Dict.valueOf( w, c )
                ti = color()
                cls
                color hiword( ti ), loword( ti )
                print space( 83 );
                print ts; space( 157 - len( ts ) )
                color loword( ti ), hiword( ti )        
            case "setcolorto", "setcolourto"
                color Dict.intValueOf( w, c, loword( color() ) ), _
                        Dict.intValueOf( w, "backgroundto", hiword( color() ) )
            case "movetox", "atx"
                locate (Dict.intValueOf( w, "y" ) + 1), (Dict.intValueOf( w, c ) + 1)
            case "drawframeatx", "drawfilledframeatx", "fillframeatx", "drawemptyframeatx"
                if( cs = "drawemptyframeatx" ) then
                    ti = 0
                elseif( cs = "drawframeatx" ) then
                    ti = 1
                else
                    ti = 2
                end if
                drawFrame( Dict.intValueOf( w, c ), Dict.intValueOf( w, "y" ), _
                        Dict.intValueOf( w, "width" ), _
                        Dict.intValueOf( w, "height" ), ti )
            case "drawhlineatx"
                drawFrame( Dict.intValueOf( w, c ), Dict.intValueOf( w, "y" ), _
                        Dict.intValueOf( w, "width" ), 1, 0 )
            case "drawvlineatx"
                drawFrame( Dict.intValueOf( w, c ), Dict.intValueOf( w, "y" ), _
                        1, Dict.intValueOf( w, "height" ), 0 )
            case "printatx"
                locate (Dict.intValueOf( w, "y" ) + 1), (Dict.intValueOf( w, c ) + 1)
                print Dict.valueOf( w, "value" );
            case "print"
                print Dict.valueOf( w, c )
            case else:
                return -1       ' not ours
        end select
        return 1                ' we handled it
    end function
    
    sub drawFrame( x as integer, y as integer, w as integer, h as integer, f as integer )
        ' f is 0 for unfilled, 1 for backfilled and 2 for forefilled
        dim c as integer = color()  ' loword is fg, hiword is bg
        dim fg as integer = hiword( c ), bg as integer = loword( c )
        color( fg, bg )
        y += 1
        x += 1
        locate y, x
        print space( w );
        y += 1
        if( h > 1 ) then
            h = (h + y - 2)
            while( y < h )
                locate y, x
                select case f
                    case 0:
                        print " ";
                        if( w > 1 ) then
                            locate y, (x + (w - 1))
                            print " ";
                        end if
                    case 1:
                        print " ";
                        color( bg, fg )
                        print space( (w - 2) );
                        color( fg, bg )
                        if( w > 1 ) then
                            print " ";
                        end if
                    case 2:
                        print space( w );
                end select
                y += 1
            wend
            locate y, x
            print space( w );
        end if
        color( bg, fg )
    end sub
end namespace
