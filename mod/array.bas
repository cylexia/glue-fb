#ifndef __LIBGLUE__
#include "../libglue.bas"
#endif

' Standard array module
' (c)2014 by Cylexia
'
' Provides array functionality
'

' ------------------------------------------------------ Standard Date and Time
namespace StdArray
    declare function init( pf as string = "" ) as integer
    declare function glueCommand( byref w as string, byref vars as string ) as integer
    declare sub arraySet( byref a as string, index as integer, value as string )
    declare function arrayGet( byref a as string, index as integer ) as string
    declare function arrayLength( byref a as string ) as integer
    declare function arrayReadElement( byref a as string, byref ofs as integer ) as string
    declare sub arrayWriteElement( byref a as string, s as string )
    declare sub arraySkipElement( byref a as string, byref ofs as integer )
    declare function arrayCreate( l as integer = 0, byref c as string = "" ) as string
    declare function explode( byref d as string, byref sep as string ) as string
    declare function implode( byref a as string, byref sep as string ) as string
    
    dim prefix as string

    function init( pf as string = "" ) as integer
        prefix = pf
        return Glue.addPlugin( @StdArray.glueCommand )
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
            case "arrayof", "array":
                SET_INTO( arrayCreate( Dict.intValueOf( w, c ), _
                        Dict.valueOf( w, "extend", "" ) ) )
            case "elementat":
                ts = Dict.valueOf( w, "in" )
                SET_INTO( arrayGet( ts, Dict.intValueOf( w, c ) ) )
            case "setelementat":
                ts = Dict.valueOf( w, "in" )
                arraySet( ts, Dict.intValueOf( w, c ), Dict.valueOf( w, "to" ) )
                SET_INTO( ts )
            case "count", "countof"
                ts = Dict.valueOf( w, c )
                SET_INTO( str( arrayLength( ts ) ) )
            case "explode"
                SET_INTO( explode( Dict.valueOf( w, c ), Dict.valueOf( w, "on" ) ) )
            case "implode"
                SET_INTO( implode( Dict.valueOf( w, c ), Dict.valueOf( w, "with" ) ) )
            case else:
                return -1       ' not ours
        end select
        return 1                ' we handled it
    end function
    
    function arrayCreate( l as integer = 0, byref c as string = "" ) as string
        dim a as string
        if( l = 0 ) then
            return ""
        end if
        if( c <> "" ) then          ' extend an existing array
            dim i as integer = arrayLength( c )
            if( i <= l ) then       ' existing is smaller so add it...
                a = c
                l -= i              ' ...and modify the length to add
            else                    ' the new array is longer, truncate it...
                for i = 0 to (l - 1)
                    arraySet( a, i, arrayGet( c, i ) )
                next
                return a            ' ...and return the truncated data
            end if
        end if
        a += string( l, "A" )       ' add "l" empty items (quickly)
        return a
    end function

    sub arraySet( byref a as string, index as integer, value as string )
        dim na as string = ""
        dim set as ubyte = 0
        dim el as string
        dim count as integer = 0
        dim i as integer = 1
        while( i <= len( a ) )
            el = arrayReadElement( a, i )
            if( count <> index ) then
                arrayWriteElement( na, el )
            else 
                arrayWriteElement( na, value )
                set = 1
            end if
            count += 1
        wend
        if( set = 0 ) then
            if( index > count ) then
                while( count > 0 )
                    arrayWriteElement( na, "" )
                    count -= 1
                wend
            end if
            arrayWriteElement( na, value )
        end if
        a = na
    end sub
    
    function arrayGet( byref a as string, index as integer ) as string
        dim i as integer = 1
        while( i <= len( a ) )
            if( index = 0 ) then
                return arrayReadElement( a, i )
            else
                arraySkipElement( a, i )
            end if
            index -= 1
        wend
        return ""       ' out of bounds
    end function
    
    function arrayLength( byref a as string ) as integer
        dim i as integer = 1
        dim l as integer = 0
        while( i <= len( a ) )
            arraySkipElement( a, i )
            l += 1
        wend
        return l
    end function
    
    function arrayReadElement( byref a as string, byref ofs as integer ) as string
        dim o as integer
        dim l as integer = 0
        dim b as string = mid( a, ofs, 1 )
        o = asc( b )
        ofs += 1
        while( o >= 97 )
            l = (l + ((o - 97) shl 4))
            o = asc( mid( a, ofs, 1 ) )
            ofs += 1
        wend    
        l += (o - 65)
        o = ofs
        ofs += l
        return mid( a, o, l )
    end function
    
    sub arraySkipElement( byref a as string, byref ofs as integer )
        dim o as integer
        dim l as integer = 0
        dim b as string = mid( a, ofs, 1 )
        o = asc( b )
        ofs += 1
        while( o >= 97 )
            l = (l + ((o - 97) shl 4))
            o = asc( mid( a, ofs, 1 ) )
            ofs += 1
        wend    
        ofs += (o - 65)
    end sub

    sub arrayWriteElement( byref a as string, s as string )
        dim l as integer = len( s )
        dim z as string = chr( (65 + (l and 15)) )
        while( l > 15 )
            l = (l shr 4)
            z = (chr( (97 + (l and 15)) ) & z)
        wend
        a += z
        a += s
    end sub
    
    function explode( byref d as string, byref sep as string ) as string
        dim a as string = ""
        dim s as integer = 1, e as integer, l as integer = len( sep )
        e = instr( d, sep )
        if( e > 0 ) then
            while( e > 0 )
                arrayWriteElement( a, mid( d, s, (e - s) ) )
                s = (e + l)
                e = instr( s, d, sep )
            wend
            arrayWriteElement( a, mid( d, s ) )
        end if
        return a
    end function

    function implode( byref a as string, byref sep as string ) as string
        dim i as integer = 1
        dim l as integer = 0
        dim s as string
        if( a = "" ) then
            return ""
        end if
        s = arrayReadElement( a, i )
        while( i <= len( a ) )
            s += sep
            s += arrayReadElement( a, i )
        wend
        return s
    end function

end namespace
