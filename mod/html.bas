namespace ExtHTML
    declare function init( pf as string = "html." ) as integer
    declare function glueCommand( byref w as string, byref vars as string ) as integer
    declare function createTag( byref w as string, tag as string, selfclose as integer = 0 ) as string
    declare sub writev( byref vars as string, s as string )
    
    dim prefix as string

    function init( pf as string = "html." ) as integer
        prefix = pf
        return Glue.addPlugin( @ExtHTML.glueCommand )
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
            case "beginpage", "startpage"
                ti = freefile()
                if( ti > 0 ) then
                    Dict.set( vars, "__html_f", str( ti ) )
                    if( open( Dict.valueOf( w, c ) for output as ti ) = 0 ) then
                        SET_INTO( "1" )
                    else
                        Glue.echo( ("Unable to open file: " & Dict.valueOf( w, c )) )
                        return 0
                    end if
                else
                    Glue.echo( "Too many file handles" )
                    return 0
                end if
            case "endpage", "finishpage"
                if( Dict.containsKey( vars, "__html_f" ) ) then
                    ti = Dict.intValueOf( vars, "__html_f" )
                    close #ti
                end if
                
            case "writeopentag"
                ExtHTML.writev( vars, ExtHTML.createTag( w, Dict.valueOf( w, c ) ) )
            case "opentag"
                SET_INTO( ExtHTML.createTag( w, Dict.valueOf( w, c ) ) )
            case "writeclosetag"
                ExtHTML.writev( vars, ("</" & Dict.valueOf( w, c ) & ">") )
            case "opentag"
                SET_INTO( ("</" & Dict.valueOf( w, c ) & ">") )
            case "writetag"
                ExtHTML.writev( vars, ExtHTML.createTag( w, Dict.valueOf( w, c ), 1 ) )
            case "tag"
                SET_INTO( ExtHTML.createTag( w, Dict.valueOf( w, c ), 1 ) )
            case "writewrap", "writewrapped"
                ExtHTML.writev( vars, ExtHTML.createTag( w, Dict.valueOf( w, "in" ) ) )
                ExtHTML.writev( vars, Dict.valueOf( w, c ) )
                ExtHTML.writev( vars, ("</" & Dict.valueOf( w, "in" ) & ">") )
            case "wrap"
                SET_INTO( (  _
                        ExtHTML.createTag( w, Dict.valueOf( w, "in" ) ) &  _
                        Dict.valueOf( w, c ) &  _
                        ("</" & Dict.valueOf( w, "in" ) & ">")) )
            case "write"
                ExtHTML.writev( vars, Dict.valueOf( w, c ) )
            case else:
                return -1       ' not ours
        end select
        return 1                ' we handled it
    end function
    
    function createTag( byref w as string, tag as string, selfclose as integer = 0 ) as string
        dim t as string = ("<" & tag)
        dim i as integer, k as string
        while( 1 )
            select case i
                case 0: k = "id"
                case 1: k = "name"
                case 2: k = "class"
                case 3: k = "style"
                case 4: k = "label"
                case 5: exit while
            end select
            if( Dict.containsKey( w, k ) ) then
                t = (t & " " & k & "=""" & Dict.valueOf( w, k ) & """")
            end if
            i += 1
        wend
        if( selfclose = 0 ) then
            return (t & ">")
        else
            return (t & "/>")
        end if
    end function
    
    sub writev( byref vars as string, s as string )
        dim f as integer = Dict.intValueOf( vars, "__html_f", 0 )
        if( f > 0 ) then
            'put( f, , s )
            print #f, s;
        else 
            Glue.echo( !"[Glue] ExtHTML: write without startPage\n" )
        end if
    end sub
    
end namespace
