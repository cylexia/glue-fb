#ifndef __LIBGLUE__
#include "../libglue.bas"
#endif

' Standard string module
' (c)2014 by Cylexia
'
' Provides string operations
'

' ------------------------------------------------------------ Standard Strings
namespace StdString
    declare function init( pf as string = "string." ) as integer
    declare function glueCommand( byref w as string, byref vars as string ) as integer

    dim prefix as string
    
    function init( pf as string = "string." ) as integer
        prefix = pf
        return Glue.addPlugin( @StdString.glueCommand )
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
            case "trim":         SET_INTO( trim( Dict.valueOf( w, c ) ) )
            case "ucase", "touppercase":
                SET_INTO( ucase( Dict.valueOf( w, c ) ) )
            case "lcase", "tolowercase":
                SET_INTO( lcase( Dict.valueOf( w, c ) ) )
            case "asc", "toasc": SET_INTO( str( asc( Dict.valueOf( w, c ) ) ) )
            case "chr", "tochr": SET_INTO( chr( Dict.intValueOf( w, c ) ) )
            case "string", "stringof"
                ts = Dict.valueOf( w, c )
                SET_INTO( string( Dict.intValueOf( w, "length" ), ts ) )
            case "instr", "indexof"
                if( Dict.containsKey( w, "from" ) ) then
                    ti = instr( (Dict.intValueOf( w, "from" ) + 1), _
                            Dict.valueOf( w, c ), _
                            Dict.valueOf( w, "in" ) )    ' 0 based
                else
                    ti = instr( Dict.valueOf( w, "in" ), Dict.valueOf( w, c ) )
                end if
                SET_INTO( str( (ti - 1) ) )     ' 0 based, -1 for not found
            case "instrrev", "lastindexof"
                if( Dict.containsKey( w, "from" ) ) then
                    ti = instrrev( Dict.valueOf( w, "in" ), _
                            Dict.valueOf( w, c ), _
                            (Dict.intValueOf( w, "from" ) + 1) )    ' 0 based
                else
                    ti = instrrev( Dict.valueOf( w, "in" ), Dict.valueOf( w, c ) )
                end if
                SET_INTO( str( (ti - 1) ) )     ' 0 based, -1 for not found
            case "mid", "strmid", "substr", "strleft", "cut"
				ts = Dict.valueOf( w, c )
                ts = mid( ts, _
                        (Dict.intValueOf( w, "from", 0 ) + 1), _
                        Dict.intValueOf( w, "length", len( ts ) ) )
                SET_INTO( ts )
            case "strright"
                ts = right( Dict.valueOf( w, c ), Dict.intValueOf( w, "length" ) )
                SET_INTO( ts )
			case "strlen"
                ts = Dict.valueOf( w, c )
				SET_INTO( str( len( ts ) ) )
            case "testifstartof"
                ts = Dict.valueOf( w, "is" )
                if( mid( Dict.valueOf( w, c ), 1, len( ts ) ) = ts ) then
                    SET_INTO( "1" )
                else
                    SET_INTO( "0" )
                end if
            case "testifendof"
                ts = Dict.valueOf( w, c )
                ti = len( ts )      ' compiler bug won't allow Dict.valueOf to appear here
                ts = Dict.valueOf( w, "is" )
                if( mid( Dict.valueOf( w, c ), (ti - len( ts )) ) = ts ) then
                    SET_INTO( "1" )
                else
                    SET_INTO( "0" )
                end if
                
            case else:
                return -1       ' not ours
        end select
        return 1                ' we handled it
    end function
end namespace
