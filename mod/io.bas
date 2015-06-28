#ifndef __LIBGLUE__
#include "../libglue.bas"
#endif

' Standard IO module
' (c)2014 by Cylexia
'
' Provides read/write access to files
'
' ----------------------------------------------------------------- Standard IO
namespace StdIO
    declare function init( pf as string = "" ) as integer
    declare function glueCommand( byref w as string, byref vars as string ) as integer
    declare sub fPrint( fn as integer, s as string )
    declare function fInput( fn as integer ) as string

    dim prefix as string

    function init( pf as string = "" ) as integer
        prefix = pf
        return Glue.addPlugin( @StdIO.glueCommand )
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
            case "ffree"
                SET_INTO( str( freefile ) )
            case "fopen", "fopenread", "fopenwrite", "fopenappend"
                    'fopen FILE for READ|WRITE|APPEND|BINARY as N
                ti = Dict.intValueOf( w, "as", freefile )
                ts = Dict.valueOf( w, c )
                c &= Dict.valueOf( w, "for", "" )
                select case lcase( c )
                    case "fopenread":    open ts for binary access read as ti
                    case "fopenwrite":   open ts for binary access write as ti
                    case "fopenappend":    
                        open ts for binary access write as ti
                        if( err = 0 ) then
                            seek ti, lof( ti )
                        end if
                    case else: err = 102      ' FILE IO Error
                end select
                SET_INTO( str( ti ) )
            case "fclose"
                ti = Dict.intValueOf( w, "fclose" )
                close #ti
            case "fwrite", "fput"
                ti = Dict.intValueOf( w, "to" )
                put #ti, , Dict.valueOf( w, c )
            case "fread", "fget"        ' fread LENGTH from FILEID
                ts = string( Dict.intValueOf( w, c ), 0 )
                ti = Dict.intValueOf( w, "from" )
                get #ti, , ts
                SET_INTO( ts )
            case "fprint"               ' fprint STRING to FILEID
                fPrint( Dict.intValueOf( w, "to" ), Dict.valueOf( w, c ) )
            case "finput", "finputfrom" ' finput FILEID
                SET_INTO( fInput( Dict.intValueOf( w, c ) ) )
            case "flength", "flof", "flengthof"
                ti = Dict.intValueOf( w, c )
                SET_INTO( str( lof( ti ) ) )
            case "testifeof", "feof", "testfeof", "ftesteof", "ftestifatend"
                ti = Dict.intValueOf( w, c )
                if( eof( ti ) ) then
                    SET_INTO( "1" )
                else
                    SET_INTO( "0" )
                end if
            case "fseekto"
                ti = Dict.intValueOf( w, "in" )
                seek #ti, (Dict.intValueOf( w, "fseekto" ) + 1)    ' is 0 based in ours, 1 in fb
            case "fposition", "fptr", "fpositionin", "fptrin"
                ti = Dict.intValueOf( w, "in" )
                SET_INTO( str( seek( ti ) ) )
            case else:
                return -1       ' not ours
        end select
        return 1                ' we handled it
    end function
    
    sub fPrint( fn as integer, s as string )
        dim l as integer = len( s )
        dim z as string = chr( (65 + (l and 15)) )
        while( l > 15 )
            l = (l shr 4)
            z = (chr( (97 + (l and 15)) ) & z)
        wend
        put #fn, , z
        put #fn, , s
    end sub
    
    function fInput( fn as integer ) as string
        dim b as string = " "
        dim o as integer
        dim i as integer = 2
        dim l as integer = 0
        get #fn, , b
        o = asc( b )
        while( o >= 97 )
            l = (l + ((o - 97) shl 4))
            get #fn, , b
            o = asc( b )
            i += 1
        wend
        b = space( (l + (o - 65) ) )
        get #fn, , b
        return b
    end function
end namespace
