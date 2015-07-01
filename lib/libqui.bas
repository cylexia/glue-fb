' Fast UI
'
' Really quick and dirty UI - console only
' Stores no internal state
'

#ifndef __LIBQUI__
#define __LIBQUI__

namespace QUI
    declare sub _showPage( title as string, text as string )
    declare function init( t as string = "" ) as integer
    declare sub setTitle( t as string )
    declare sub clearMenuItems()
    declare function addMenuItem( items as string, text as string, label as string ) as string
    declare function menu( items as string, title as string, prompt as string = "" ) as string
    declare function value( title as string, prompt as string = "" ) as string
    declare sub message( title as string, prompt as string = "" )
    declare sub clear()
    
    function init( t as string = "" ) as integer
        return -1
    end function

    function addMenuItem( items as string, text as string, label as string ) as string
        items &= (chr( (len( text ) + 33) ) & text)
        items &= (chr( (len( label ) + 33) ) & label)
        return items
    end function
        
    function menu( items as string, title as string, prompt as string = "" ) as string
        dim as string text = prompt
        if( len( text ) > 0 ) then
            text &= !"\n\n"
        end if
        dim as integer l, i = 1, li = 1
        dim as string lbls(1 to 10)
        while( i < len( items ) )
            l = (asc( items, i ) - 33)
            if( li <= 10 ) then
                text &= (" " & li)
            else
                text &= li
            end if
            text &= (".  " & mid( items, (i + 1), l ) & !"\n")
            i += (l + 1)
            l = (asc( items, i ) - 33)
            lbls(li) = mid( items, (i + 1), l )
            i += (l + 1)
            li += 1
        wend
        dim as string res
        dim as integer resi
        while( 1 )
            QUI._showPage( title, text )
            line input ">", res
            resi = val( res )
            if( (resi >= 1) and (resi <= ubound( lbls )) ) then
                if( len( lbls(resi) ) > 0 ) then
                    return lbls(resi)
                end if
            end if
        wend
    end function
    
    function value( title as string, prompt as string = "" ) as string
        dim as string res
        QUI._showPage( title, prompt )
        line input ">", res
        return res
    end function
    
    sub message( title as string, prompt as string = "" )
        QUI._showPage( title, prompt )
        print "[Press any key]";
        getkey()
    end sub
    
    sub clear()
        dim as integer i = (HIWORD( width() ) + 2)
        while( i > 0 ) 
            print
            i -= 1
        wend
    end sub

    sub _showPage( title as string, text as string )
        dim as integer i, height = HIWORD( width() )
        for i = 0 to 5
            print
        next
        print " "; title
        print " "; string( len( title ), "=" )
        print
        text &= !"\n"
        dim as integer lidx = 4, s = 1, e = instr( text, !"\n" )
        dim as integer lmax = (height - 2)
        while( e > 0 )
            print " "; mid( text, s, (e - s) )
            s = (e + 1)
            e = instr( s, text, !"\n" )
            lidx += 1
            if( (lmax > 0) and (lidx >= lmax) ) then
                exit while
            end if
        wend
        if( lmax > 0 ) then
            while( lidx < lmax )
                print
                lidx += 1
            wend
        end if
    end sub
end namespace

#endif