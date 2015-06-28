' ExtCForm
' (c)2014 by Cylexia
'
' Console based form viewer, this blocks so isn't available on event queue
' based systems

#include "../../../lib/libform.bas"

namespace ExtCForm
    declare function init( pf as string = "cform" ) as integer
    declare function start( byref src as string, byref vars as DICTSTRING ) as integer
    
    declare function glueInit() as integer
    declare function glueCommand( byref w as string, byref vars as string ) as integer

    declare function _showForm( byref d as DICTSTRING ) as string
    declare function _selectFromList( items as string, index as integer ) as string
    
    dim as string prefix
    dim as DICTSTRING values
    dim as string title, message, extraData
    
    function init( pf as string ) as integer
        prefix = pf
        if( FastForm.init() = 0 ) then
            return 0
        end if
        ExtCForm.values = Dict.create()
        if( glueInit() = 1 ) then
            return Glue.addPlugin( @ExtCForm.glueCommand )
        end if
    end function

    function glueInit() as integer
        return 1
    end function
    
    function glueCommand( byref w as string, byref vars as string ) as integer
        dim c as string = Dict.valueOf( w, "_" ), cs as string
        dim ts as string, tn as single, ti as integer
        if( prefix <> "" ) then
            if( instrrev( c, prefix, 1 ) = 0 ) then
                return -1
            else
                cs = mid( c, (len( prefix ) + 1) )
            end if
        else 
            cs = c
        end if
        select case cs
            case "addtextfieldwithlabel"
                ts = Dict.valueOf( w, "id" )
                FastForm.addTextField( Dict.valueOf( w, c ), ts )
                Dict.set( ExtCForm.values, ts, Dict.valueOf( w, "value" ) )
                
            case "addlistfieldwithlabel"
                ts = Dict.valueOf( w, "id" )
                FastForm.addListField(  _
                        Dict.valueOf( w, c ),  _
                        ts,  _
                        Dict.valueOf( w, "items" )  _
                    )
                Dict.set( ExtCForm.values, ts, Dict.valueOf( w, "value", "0" ) )

            case "addactionwithlabel"
                ts = Dict.create()
                Dict.set( ts, "label", Dict.valueOf( w, "id" ) )
                Dict.set( ts, "data", Dict.valueOf( w, "data" ) )
                FastForm.addAction( Dict.valueOf( w, c ), ts )

            case "showwithtitle"
                Dict.set( w, "title", Dict.valueOf( w, c ) )
                SET_INTO( ExtCForm._showForm( w ) )
                
            case "getactiondata", "getdata"
                SET_INTO( ExtCForm.extraData )
            case "getformvalue"
                SET_INTO( Dict.valueOf( ExtCForm.values, Dict.valueOf( w, c ) ) )
            case "setformvalue"
                Dict.set( ExtCForm.values, Dict.valueOf( w, c ), Dict.valueOf( w, "to" ) )
            
            case "selectfromlist"
                SET_INTO( ExtCForm._selectFromList( Dict.valueOf( w, c ), Dict.intValueOf( w, "index" ) ) )

            case else:
                return -1       ' not ours
        end select
        return 1                ' we handled it
    end function
    
'== Show a form once an IRQ has been triggered
    function _showForm( byref d as DICTSTRING ) as string
        dim as DICTSTRING r
        r = FastForm.showForm(  _
                Dict.valueOf( d, "title" ),  _
                ExtCForm.values,  _
                Dict.valueOf( d, "message", "" )  _
            )
        ExtCForm.extraData = Dict.valueOf( r, "data" )
        return Dict.valueOf( r, "label" )
    end function


'== Select an item from a list by its index
    function _selectFromList( items as string, index as integer ) as string
        items = (items & "/")
        dim as integer s = 1, e = instr( items, "/" ), i = 0
        while( e > 1 )
            if( index = i ) then
                return mid( items, s, (e - s) )
            else
                s = (e + 1)
                e = instr( s, items, "/" )
                i += 1
            end if
        wend
        return ""
    end function

end namespace
