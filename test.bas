#include "libmain.bas"
#include "libglue.bas"
#include "mod/platform.bas"

Glue.init()
ExtPlatform.init()

dim as string src = "tests/platform.test"

dim as DICTSTRING vars = Dict.create()

Glue.load( Utils.readFile( src ), vars )
dim as integer result = Glue.run()

print !"\n\n\nGlue finished with result"; result
end
