#ifndef __LIBGLUE__
#include "../libglue.bas"
#endif

' v-- needed for fileexists()
#include "file.bi"

' External DataSet module
' (c)2014 by Cylexia
'
' Provides access to line delimited datasets under "dataset.X"
'

namespace ExtDataSet
    declare function init() as integer
    declare function connect( n as string, a as string ) as integer
    declare function load( a as string ) as integer
    declare function all() as integer
    declare function elementAt( i as integer ) as string
    declare function length() as integer
    declare function filter( f as string ) as integer
    declare function filterOut( f as string ) as integer
    declare function _filterMem( f as string, in as byte ) as integer
    declare function _filterDisc( f as string, in as byte ) as integer
    declare function _fInclude( haystack as string, needle as string, in as byte ) as byte
    declare function glueCommand( byref w as string, byref vars as string ) as integer

    dim selectedSet as string
    dim dsIsLoaded as byte       ' simulate a boolean
    dim dataset() as string
    dim dslength as integer
    dim dss as string
    
    dim prefix as string

    function init() as integer
        prefix = "ds."
        dss = Dict.create()
        return Glue.addPlugin( @ExtDataSet.glueCommand )
    end function
    
    function connect( n as string, a as string ) as integer
        if( fileexists( n ) ) then
            Dict.set( dss, a, n )
            return 1
        else
            return 0
        end if
    end function
    
    function load( a as string ) as integer
        if( Dict.containsKey( dss, a ) ) then
            selectedSet = Dict.valueOf( dss, a )
            dsIsLoaded = 0
            return 1
        else
            return 0
        end if
    end function
    
    function all() as integer
        open selectedSet for input as 1
        dslength = 0
        redim dataset( 10 ) as string
        dim l as string
        while( not eof( 1 ) )
            line input #1, l
            if( l <> "" ) then
                dataset( dslength ) = l
                dslength += 1
                if( dslength = ubound( dataset ) ) then
                    redim preserve dataset( (dslength + 10) ) as string
                end if
            end if
        wend
        close 1
        dsIsLoaded = 1
        return 1
    end function

    function elementAt( i as integer ) as string
        if( i <= dslength ) then
            return dataset( i )
        else
            return ""
        end if
    end function
    
    function length() as integer
        return dslength
    end function
    
    function filter( f as string ) as integer
        if( dsIsLoaded ) then
            return _filterMem( f, 1 )
        else
            return _filterDisc( f, 1 )
        end if
    end function
    
    function filterOut( f as string ) as integer
        if( dsIsLoaded ) then
            return _filterMem( f, 0 )
        else
            return _filterDisc( f, 0 )
        end if
    end function    
    
    function _filterMem( f as string, in as byte ) as integer
        dim ofs as integer = 0
        dim i as integer
        for i = 0 to (dslength - 1)
            if( _fInclude( dataset(i), f, in ) = 0 ) then
                ofs += 1
            else
                if( ofs <> 0 ) then
                    dataset(i - ofs) = dataset(i)
                end if
            end if
        next
        dslength -= ofs
        return dslength
    end function
    
    function _filterDisc( f as string, in as byte ) as integer
        open selectedSet for input as 1
        dslength = 0
        redim dataset( 10 ) as string
        dim l as string
        while( not eof( 1 ) )
            line input #1, l
            if( l <> "" ) then
                if( _fInclude( l, f, in ) = 1 ) then
                    dataset( dslength ) = l
                    dslength += 1
                    if( dslength = ubound( dataset ) ) then
                        redim preserve dataset( (dslength + 10) ) as string
                    end if
                end if
            end if
        wend
        close 1
        dsIsLoaded = 1
        return 1
    end function
    
    function _fInclude( haystack as string, needle as string, in as byte ) as byte
        if( in = 1 ) then
            if( instr( haystack, needle ) <> 0 ) then
                return 1
            else
                return 0
            end if
        else
            if( instr( haystack, needle ) = 0 ) then
                return 1
            else
                return 0
            end if
        end if
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
            case "connect"
                SET_INTO( str( connect( Dict.valueOf( w, c ), _
                        Dict.valueOf( w, "as" ) ) ) )
            case "load", "select"
                SET_INTO( str( load( Dict.valueOf( w, c ) ) ) )
            case "all"
                SET_INTO( str( all() ) )
            case "filter", "include", "allow"
                SET_INTO( str( filter( Dict.valueOf( w, c ) ) ) )
            case "filterout", "exclude", "remove"
                SET_INTO( str( filter( Dict.valueOf( w, c ) ) ) )
            case "getelementat":
                SET_INTO( elementAt( Dict.intValueOf( w, c ) ) )
            case "getelementcount"
                SET_INTO( str( length() ) )
            case else:
                return -1       ' not ours
        end select
        return 1                ' we handled it
    end function
end namespace