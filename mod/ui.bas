#ifndef __LIBSCRIPTRT__
#error -1: Unable to build "ExtUI" with libglue, use libscriptrt instead
#endif

#ifndef __LIBMAIN__
#include "../../lib/libmain.bas"
#endif

#include "../../lib/libui2.bas"

#ifdef __FB_WIN32__
#include "windows.bi"
#endif

' External UI module
' (c)2014 by Cylexia
'
' Provides a unified menu, form and text UI
'

namespace ExtUI
    const CBVARID = "__extui_cb"
    
    declare function init( pf as string = "ui." ) as integer
    declare sub destroy()
    declare function glueCommand( byref w as string, byref vars as string ) as integer
    declare function _rtCallBackHandler( byref d as string, byref label as string ) as integer
    
    dim prefix as string
    dim cbhid as integer        ' id of handler to allow it to be unregistered
    dim formvalues as string
    
    function init( pf as string ) as integer
        prefix = pf
        cbhid = -1      ' > -1 if up
        return Glue.addPlugin( @ExtUI.glueCommand )
    end function
    
    sub destroy()
        if( cbhid > -1 ) then
            RT.unregisterCallBackHandler( cbhid )
            cbhid = -1      ' > -1 if up
        end if
        UI.destroy()
    end sub
    
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
            case "start", "init", "startwithtitle", "initwithtitle"
                UI.init(  _
                        Dict.valueOf( w, c ),  _
                        Dict.intValueOf( w, "cols", 80 ),  _
                        Dict.intValueOf( w, "rows", 25 )  _
                    )
                cbhid = RT.registerCallBackHandler( @ExtUI._rtCallBackHandler )
            case "settitle"
                UI.setTitle( Dict.valueOf( w, c ) )
            case "removewindowwidgets", "removewidgets"
                UI.removeWindowWidgets()
                
            case "usecolourschemewithname"
                select case Dict.valueOf( w, c )
                    case "default", "black"
                        UI.setDefaultColourScheme( 1 )
                    case "white"
                        UI.setDefaultColourScheme( 1 )
                    case "light"
                        UI.setLightColourScheme()
                    case "grey"
                        UI.setColourScheme( "habaapialhiaala" )
                end select
            case "usecolourscheme"
                UI.setColourScheme( Dict.valueOf( w, c ) )
            
            case "testisstarted", "testifisstarted"
                if( cbhid > -1 ) then
                    SET_INTO( "1" )
                else
                    SET_INTO( "0" )
                end if
            case "testisnotstarted", "testifisnotstarted"
                if( cbhid = -1 ) then
                    SET_INTO( "1" )
                else
                    SET_INTO( "0" )
                end if
            case "getdata", "putdata"
                SET_INTO( UI.getStoredData() )
                
            case "getformvalue", "putformvalue"
                SET_INTO( Dict.valueOf( ExtUI.formvalues, Dict.valueOf( w, c ) ) )
                
            case "freeconsole"
                #ifdef __FB_WIN32__
                    #ifdef _LIBUI_USEVC
                        #ifdef _EXTUI_FREECONSOLE 
                            FreeConsole()
                        #endif
                    #endif
                #endif
                return 1
                
            case "addmenuactionwithlabel", "addmenuaction"
                UI.addMenuAction( Dict.valueOf( w, c ),  _
                        Dict.valueOf( w, "goto" ),  _
                        Dict.valueOf( w, "data" )  _
                    )
            'case "setmenuactions"
            '    UI.setMenuActions( Dict.valueOf( w, c ) )
            case "showmenuwithtitle", "showmenu"
                if( Dict.containsKey( w, "withitems" ) ) then
                    UI.setMenuActions( Dict.valueOf( w, "withitems" ) )
                end if
                'SET_INTO( UI.showMenu( Dict.valueOf( w, c ) ) )
                ts = Dict.create()
                Dict.set( ts, "mode", "menu" )
                Dict.set( ts, "title", Dict.valueOf( w, c ) )
                Dict.set( ts, "message", Dict.valueOf( w, "message" ) )
                Dict.set( vars, CBVARID, ts )
                DEBUGMSG( "data is: " & ts )
                ' user must call "stop" for the ui to appear, in non-modal langs
                ' the ui would go up then expect stop to be called to allow
                ' event handling
                
            case "addformtextfieldwithlabel", "addtextfieldwithlabel", "addtextfield"
                UI.addFormTextField( Dict.valueOf( w, c ), Dict.valueOf( w, "as" ) )
            case "addformlistfieldwithlabel", "addlistfieldwithlabel", "addlistfield"
                UI.addFormListField( Dict.valueOf( w, c ), Dict.valueOf( w, "as" ), Dict.valueOf( w, "list" ) )
            case "addformactionwithlabel", "addformaction"
                UI.addFormAction( Dict.valueOf( w, c ),  _
                        Dict.valueOf( w, "goto" ),  _
                        Dict.valueOf( w, "data" )  _
                    )
            case "showformwithtitle", "showform"
                ts = Dict.create()
                Dict.set( ts, "mode", "form" )
                Dict.set( ts, "title", Dict.valueOf( w, c ) )
                Dict.set( ts, "message", Dict.valueOf( w, "message" ) )
                Dict.set( ts, "into", Dict.valueOf( w, "into" ) )
                DEBUGMSG( ts )
                Dict.set( vars, CBVARID, ts )
            
            case "addtextactionwithlabel", "addtextaction"
                UI.addTextAction( Dict.valueOf( w, c ),  _
                        Dict.valueOf( w, "goto" ),  _
                        Dict.valueOf( w, "data" )  _
                    )            
            case "showtextwithtitle", "showtext"
                'SET_INTO( UI.showText( Dict.valueOf( w, c ), Dict.valueOf( w, "text" ) ) )
                ts = Dict.create()
                Dict.set( ts, "mode", "text" )
                Dict.set( ts, "title", Dict.valueOf( w, c ) )
                Dict.set( ts, "message", Dict.valueOf( w, "message" ) )
                Dict.set( ts, "text", Dict.valueOf( w, "text" ) )
                Dict.set( vars, CBVARID, ts )
                
            case "showbusywithtitle", "showbusy"
                UI.showBusy(  _
                        Dict.valueOf( w, c ),  _
                        Dict.valueOf( w, "text" ),  _
                        Dict.valueOf( w, "message" )  _
                    )

            case "promptwithtitle"
                SET_INTO( UI.prompt(  _
                        Dict.valueOf( w, c ),  _
                        Dict.valueOf( w, "message" ),  _
                        Dict.valueOf( w, "existing", "" )  _
                    ) )
                    
            case "stopui", "stop"
                UI.destroy()
                
            case else:
                return -1       ' not ours
        end select
        return 1                ' we handled it
    end function
    
    function _rtCallBackHandler( byref vars as string, byref label as string ) as integer
        dim dd as string = Dict.valueOf( vars, CBVARID )
        Dict.set( vars, CBVARID, "" )       ' clear this
        DEBUGMSG( "mode is: " & Dict.valueOf( dd, "mode" ) )
        select case Dict.valueOf( dd, "mode" )
            case "menu"
                dim as string r = UI.showMenu(  _
                        Dict.valueOf( dd, "title" ),  _
                        Dict.valueOf( dd, "message" )  _
                    )
                if( r <> "" ) then
                    label = Dict.valueOf( r, "_action" )
                else
                    label = ""
                end if
                return 1
                
            case "text"
                dim as string r = UI.showText(  _
                        Dict.valueOf( dd, "title" ),  _
                        Dict.valueOf( dd, "text" ),  _
                        Dict.valueOf( dd, "message" )  _
                    )
                label = Dict.valueOf( r, "_action" )
                return 1
                       
            case "form"
                dim r as string = UI.showForm(  _
                        Dict.valueOf( dd, "title" ),  _
                        vars,  _
                        Dict.valueOf( dd, "message" )  _
                    )
                if( Dict.valueOf( r, "_action" ) <> "" ) then
                    'Dict.copyInto( r, vars )
                    ExtUI.formvalues = r
                    label = Dict.valueOf( r, "_action" )
                else
                    ExtUI.formValues = Dict.create()
                    label = ""
                end if
                return 1
                
            case else:
                return 0
        end select
    end function
end namespace
