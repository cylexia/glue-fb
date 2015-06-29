#ifndef __LIBGLUE__
#include "../../../lib/libglue.bas"
#endif

' External platform module.
' (c)2014 by Cylexia
'
' Provides various platform specific operations.  All commands should be
'  available across platforms but can do nothing, show a warning or do the
'  closest thing/most sensible thing available.
'
' Frame support is built into this module as well as ExtFrame
'
' Generally included with any implentation


' Provides frame support, this is part of the platform subsystem but has
' the prefix frame.

namespace ExtPlatform
    declare function init() as integer
    declare function glueCommand( byref w as string, byref vars as string ) as integer

    declare function _readFromFile( n as string ) as string
    declare function _writeToFile( n as string, v as string ) as string
    declare function _listFilesIn( path as string ) as string
    declare function _loadConfig( n as string ) as string
    declare function _createDateSerial() as string
    
    declare function _lsfValue( value as string ) as string
    
'    declare function _browseTo( page as string, query as string ) as integer
'    declare function _download( file as string, d as DICTSTRING ptr, vars as DICTSTRING ptr ) as integer
'    declare function _pcEncode( p as string ) as string
 '   declare function _pcDecode( p as string ) as string

    function init() as integer
        'if( Glue.addPlugin( @ExtPlatform.glueCommand ) ) then
        '    return ExtFrame.init()
        'end if
        randomize timer()           ' for getRandomNumberFrom_upTo
        return Glue.addPlugin( @ExtPlatform.glueCommand )
    end function
    
    function glueCommand( byref w as string, byref vars as string ) as integer
        dim c as string = Dict.valueOf( w, "_" ), cs as string
        dim ts as string, tn as single, ti as integer
        if( instrrev( c, "platform.", 1 ) = 1 ) then
            cs = mid( c, 10 )
        else
            return -1
        end if
        dim as string wc = Dict.valueOf( w, c )
        select case cs
            case "pause"
                sleep
            case "readfromfile", "load"
                SET_INTO( ExtPlatform._readFromFile( wc ) )
            case "writetofile", "save"
                SET_INTO( ExtPlatform._writeToFile( wc, Dict.valueOf( w, "value" ) ) )
            case "currentpath"
                SET_INTO( curdir )
            case "setcurrentpathto"
                chdir wc
            case "listfilesin"
                SET_INTO( ExtPlatform._listFilesIn( wc ) )
                
            case "loadconfigfrom", "loadconfig"
                SET_INTO( _loadConfig( wc ) )
            case "dateserial", "getdateserial", "putdateserial"
                SET_INTO( _createDateSerial() )
            case "setenv", "setenvironmentvariable"
                setenviron (wc & "=" & Dict.valueOf( w, "to" ))
            case "getenv", "putenv", "getenvironmentvariable", "putenvironmentvariable"
                SET_INTO( environ( wc ) )
            case "exec"
                ts = Dict.valueOf( w, "ondonegoto" )
                if( exec( wc, Dict.valueOf( w, "args", Dict.valueOf( w, "withargs" ) ) ) = -1 ) then
                    ts = Dict.valueOf( w, "onerrorgoto", ts )
                end if
                Glue.setRedirectLabel( ts )
                return -2       ' redirect to label (can be 1 since above call will ensure redirect)
            case "getrandomnumberfrom":
                ti = Dict.intValueOf( w, c )
                SET_INTO( ((rnd() * (Dict.intValueOf( w, "upto" ) - ti)) + ti) )
                
'            case "browseto", "browsetourl"
'                ts = Dict.valueOf( w, "ondonegoto" )
'                if( ExtPlatform._browseTo( wc, Dict.valueOf( w, "query", Dict.valueOf( w, "withquery" ) ) ) = 0 ) then
'                    ts = Dict.valueOf( w, "onerrorgoto", ts )
'                end if
'                Glue.setRedirectLabel( ts )
'                return -2       ' redirect to label
'            case "download"
'                ts = Dict.valueOf( w, "ondonegoto" )
'                dim as string res = ""
'                if( ExtPlatform._download( wc, @w, @vars ) = 0 ) then
'                    ts = Dict.valueOf( w, "onerrorgoto", ts )
'                end if
'                Glue.setRedirectLabel( ts )
'                return -2       ' redirect to label
                
            'case "percentencode":
            '    SET_INTO( ExtPlatform._pcEncode( Dict.valueOf( w, c ) ) )
            'case "percentdecode":
            '    SET_INTO( ExtPlatform._pcDecode( Dict.valueOf( w, c ) ) )
                
            case "exit"
                return -254     ' any event loop should see this as exit
                
            case "getid"
                #ifdef __FB_WIN32__
                    SET_INTO( "native/w32" )
                #endif
                #ifdef __FB_LINUX__
                    SET_INTO( "native/linux" )
                #endif
                #ifdef __FB_DOS__
                    SET_INTO( "native/dos" )
                #endif
                
            case else:
                return -1       ' not ours
        end select
        return 1                ' we handled it
    end function
    
    function _readFromFile( n as string ) as string
        dim ff as integer = freefile()
        dim buf as string
        open n for binary access read as ff
        dim as integer l = lof( ff )
        if( l > 0 ) then
            buf = space( l )
            get #ff, , buf
        else
            buf = ""
        end if
        close #ff
        return buf
    end function
    
    function _writeToFile( n as string, v as string ) as string
        dim ff as integer = freefile()
        if( open( n for output as ff ) = 0 ) then
            close #ff       ' we only opened it to create or truncate it
            open n for binary access write as ff  ' now we will write it
            put #ff, , v
            close #ff
            return "1"
        end if
        return "0"
    end function
    
    function _listFilesIn( path as string ) as string
        if( len( path ) > 0 ) then
            #ifdef __FB_WIN32__
                if( mid( path, (len( path ) - 1) ) <> "\" ) then
                    path &= "\"
                end if
            #else
                if( mid( path, (len( path ) - 1) ) <> "/" ) then
                    path &= "/"
                end if
            #endif
        end if
        dim as string file = dir( (path & "*") )
        dim as string result = "", z
        dim as integer index = 0, l
        while( len( file ) > 0 )
            z = str( index )
            result &= (chr( (65 + len( z )) ) & z)        ' length always < 65
            result &= _lsfValue( file )
            file = dir()
            index += 1
        wend
        result &= _lsfValue( "count" )
        result &= _lsfValue( str( index ) )        
        return result
    end function
    
    function _lsfValue( value as string ) as string
        dim as integer l = len( value )
        dim as string z = chr( (65 + (l and 15)) )
        while( l > 15 )
            l = (l shr 4)
            z = (chr( (97 + (l and 15)) ) & z)
        wend
        return (z & value)
    end function
    
    function _loadConfig( n as string ) as string
        dim as string key = "", value, l
        dim as integer ff = freefile(), e
        dim as string prefix = "", result = ""
        if( open( n for input as ff ) = 0 ) then
            while( not eof( ff ) )
                line input #ff, l
                if( (asc( l, 1 ) = 91) and (asc( l, len( l ) ) = 93) ) then  '[ and ]
                    prefix = (mid( l, 2, (len( l ) - 2) ) & ".")
                elseif( asc( l, 1 ) = 35 ) then
                    ' comment
                else
                    e = instr( l, "=" )
                    if( e > 0 ) then
                        result &= ExtPlatform._lsfValue( (prefix & mid( l, 1, e )) )
                        result &= ExtPlatform._lsfValue( mid( l, (e + 1) ) )
                    end if
                end if
            wend
        end if
        return result
    end function
    
    function _createDateSerial() as string
        dim ts as string = (date() & time())
        return (mid( ts, 7, 4 ) & mid( ts, 1, 2 ) & mid( ts, 4, 2 ) & _
                mid( ts, 11, 2 ) & mid( ts, 14, 2 ) & mid( ts, 17, 2 ) )
    end function
/'
    ' page is the page before ?, query is a parts (LSF-array) list to be
    ' encoded and added, can be ""
    function _browseTo( page as string, query as string ) as integer
        if( query <> "" ) then
            dim as DICTSTRING qdict = Dict.createFromLSF( query )
            dim as DICTSTRING keys = Dict.keyDict( qdict )
            dim as integer i, l = (Dict.intValueOf( keys, "count" ) - 1)
            dim as string a = "?", k
            for i = 0 to l
                k = Dict.valueOf( keys, str( i ) )
                page &= (a & k & "=" & ExtPlatform._pcEncode( Dict.valueOf( qdict, k ) ))
                a = "&"
            next
        end if
        dim as string app = environ( "BROWSER" )
        dim as integer errcode = exec( app, ("""" & page & """") )
        if( errcode > -1 ) then
            return TRUE
        else
            return FALSE
        end if
    end function

    ' page is the page before ?, query is a parts (LSF-array) list to be
    ' encoded and added, can be ""
    function _download( page as string, d as DICTSTRING ptr, vars as DICTSTRING ptr ) as integer
        dim as string app = Dict.valueOf( *vars, "WGET", environ( "WGET" ) )
        if( app = "" ) then
            app = "wget.exe"            ' hope it's on the path
        end if
        dim as string query = Dict.valueOf( *d, "query", Dict.valueOf( *d, "withquery" ) )        
        if( query <> "" ) then
            dim as DICTSTRING qdict = Dict.createFromLSF( query )
            dim as DICTSTRING keys = Dict.keyDict( qdict )
            dim as integer i, l = (Dict.intValueOf( keys, "count" ) - 1)
            dim as string a = "?", k
            for i = 0 to l
                k = Dict.valueOf( keys, str( i ) )
                page &= (a & k & "=" & ExtPlatform._pcEncode( Dict.valueOf( qdict, k ) ))
                a = "&"
            next
        end if
        
        dim as string tmp = (curdir() & "temp.wget")
        dim as string args = "-qO """ & tmp & """ """ & page & """"
        dim as integer errcode = exec( app, args )
        if( errcode > -1 ) then
            if( open( tmp for binary access read as 1 ) = 0 ) then
                dim as string content = space( lof( 1 ) )
                get #1, , content
                close 1
                kill tmp
                Dict.set( *vars, Dict.valueOf( *d, "into" ), content )
                return TRUE
            end if
        end if
        return FALSE
    end function

    function _pcEncode( p as string ) as string
        dim as string nu = ""
        dim as string a = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-_.~"
        a &= lcase( a )
        dim as integer c, i
        for i = 1 to len( p )
            c = asc( p, i )
            if( instr( a, chr( c ) ) = 0 ) then
                nu &= "%"
                nu &= chr( asc( a, (((c shr 4) and &hF) + 1) ) )
                nu &= chr( asc( a, ((c and &hF) + 1) ) )
            else
                nu &= chr( c )
            end if
        next
        return nu
    end function
    
    function _pcDecode( p as string ) as string
        dim as string h = "0123456789ABCDEF", n = ""
        dim as integer i = 1, l = len( p ), c
        while( i <= l )
            c = asc( p, i )
            if( c = &h25 ) then
                c = ((instr( h, ucase( chr( asc( p, (i + 1) ) ) ) ) - 1) shl 4) or  _
                    (instr( h, ucase( chr( asc( p, (i + 2) ) ) ) ) - 1)
                i += 2
            end if
            n &= chr( c )
            i += 1
        wend
        return n
    end function
'/    
end namespace
