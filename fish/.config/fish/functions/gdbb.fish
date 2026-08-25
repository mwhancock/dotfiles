function gdbb --description 'Run a program in GDB with a backtrace on crash and exit'
    gdb --batch --ex run --ex bt --ex q --args $argv
end
