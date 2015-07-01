#ifndef __LIBQUI__
#error Requires libqui
#endif

#ifndef __LIBGLUE__
#error Requires libglue
#endif

namespace ExtQUI
    declare function init() as integer
    declare function glueCommand( byref w as string, byref vars as string ) as integer
    
    dim as string last_value
    
    function init() as integer
        ExtQUI.last_value = ""
        return Glue.addPlugin( @ExtQUI.glueCommand )
    end function
    
    function glueCommand( byref w as string, byref vars as string ) as integer
        dim c as string = Dict.valueOf( w, "_" ), cs as string
        dim ts as string, tn as single, ti as integer
        if( instrrev( c, "qui.", 1 ) = 1 ) then
            cs = mid( c, 5 )
        else
            return -1
        end if
        dim as string wc = Dict.valueOf( w, c )
        dim as string lbl
        select case cs
            case "addmenuitemto", "additemto"
                ts = QUI.addMenuItem(   _
                        wc,  _
                        Dict.valueOf( w, "value" ),  _
                        Dict.valueOf( w, "goto", Dict.valueOf( w, "onclickgoto" ) )  _
                    )
                SET_INTO( ts )
                
            case "showmenuwithprompt", "menu"
                lbl = QUI.menu(  _
                        Dict.valueOf( w, "items" ),  _
                        Dict.valueOf( w, "title", Dict.valueOf( w, "withtitle", "Menu" ) ),  _
                        wc  _
                    )
                Glue.setRedirectLabel( lbl )
                return Glue.PLUGIN_INLINE_REDIRECT
                
            case "getvaluewithprompt", "value"
                lbl = Dict.valueOf( w, "ondonegoto" )
                ExtQUI.last_value = QUI.value(  _
                        Dict.valueOf( w, "title", Dict.valueOf( w, "withtitle", "Input" ) ),  _
                        wc  _
                    )
                Glue.setRedirectLabel( lbl )
                return Glue.PLUGIN_INLINE_REDIRECT
            case "getlastvalue"
                SET_INTO( ExtQUI.last_value )

            case "showmessage", "message", "showmessagewithprompt"
                if( cs = "showmessagewithprompt" ) then
                    wc = (wc & !"\n\n" & Dict.valueOf( w, "value" ))
                end if
                lbl = Dict.valueOf( w, "ondonegoto" )
                QUI.message(  _
                        Dict.valueOf( w, "title", Dict.valueOf( w, "withtitle", "Message" ) ),  _
                        wc  _
                    )
                    
                SET_INTO( ts )
                Glue.setRedirectLabel( lbl )
                return Glue.PLUGIN_INLINE_REDIRECT
                
            case "clear", "clearscreen"
                QUI.clear()
                
            case else:
                return -1       ' not ours
        end select
        return 1                ' we handled it
    end function
end namespace
