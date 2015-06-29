#include "libmain.bas"
#include "libglue.bas"
#include "mod/platform.bas"

ExtPlatform.init()
Glue.init()

dim as string src = "tests/core.test"

dim as DICTSTRING vars = Dict.create()

Glue.load( Utils.readFile( src ), vars )
dim as integer result = Glue.run()

print !"\n\n\nGlue finished with result"; result
sleep
end
