#include "../lib/libmain.bas"
#include "../lib/libglue.bas"
#include "mod/platform.bas"

namespace StdG
    declare function init( pf as string = "" ) as integer
 
    declare function glueInit() as integer
    declare function glueCommand( byref w as string, byref vars as string ) as integer

    dim as string prefix
    
    function init( pf as string ) as integer
        prefix = pf
        if( glueInit() = 1 ) then
            return Glue.addPlugin( @StdG.glueCommand )
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
            case "g.ask", "g.input"
                print Dict.valueOf( w, cs ); 
                line input "", ts
                SET_INTO( ts )
                Dict.set( vars, "__cont", Dict.valueOf( w, "onokgoto" ) )
                return -2       ' redirect to label in "onokgoto"
                
            case "g.cls"
                cls
                
            case else:
                return -1       ' not ours
        end select
        return 1                ' we handled it
    end function
    
    
end namespace

' Entry point
print !"Glue Console v1.00\n(c)2014 by Cylexia\n"
Glue.printPoweredBy()
print

'Init the Glue engine, attach modules and the app
Glue.init()
ExtPlatform.init()
StdG.init()

' Load and run the script
dim as integer result = 0
dim as string src = ""

dim cmdline as string = Utils.parseCommandLine()
dim srcfile as string = Dict.valueOf( cmdline, "_" )
if( srcfile = "." ) then
    Glue.runInteractiveMode( cmdline )
elseif( srcfile <> "" ) then
    dim er as integer = 0
    src = Utils.readFile( srcfile, er )
    if( er = 0 ) then
        dim as string label = ""
        Glue.load( src, cmdline )
    
        result = Glue.run( label )

    else
        Glue.echo( ("Unable to load script " & srcfile) )
    end if
else
    Glue.echo( !"Use: g <scriptfile> [-key value -key value...] to run <scriptfile>\n" )
    Glue.echo( !" or: g . [-key value -key value...] to start interactive mode\n" )
end if


if( Dict.valueOf( cmdline, "pause" ) = "1" ) then
    print "Press a key..."
    sleep
end if
