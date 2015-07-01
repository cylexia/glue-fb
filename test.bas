#include "lib/libmain.bas"
#include "lib/libglue.bas"
#include "lib/libqui.bas"
#include "mod/platform.bas"
#include "mod/qui.bas"

QUI.init()

Glue.init()
ExtPlatform.init()
ExtQUI.init()

dim as string m = ""
m = QUI.addMenuItem( m, "Core", "core" )
m = QUI.addMenuItem( m, "Platform", "platform" )
m = QUI.addMenuItem( m, "QUI", "qui" )
dim as string test = QUI.menu( m, "Glue Test Suite", "Select a test to run" )

QUI.clear()

dim as string src = ("tests/" + test + ".test")

dim as DICTSTRING vars = Dict.create()

Glue.load( Utils.readFile( src ), vars )
dim as integer result = Glue.run()

print !"\n\n\nGlue finished with result"; result
end
