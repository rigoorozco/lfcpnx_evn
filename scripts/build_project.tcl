# Build a previously created project

if { $argc != 1 } {
    puts "Path to the project file must be provided!"
    exit 1
}

prj_open "[lindex $argv 0]"

prj_run_synthesis
prj_run_map
prj_run_par
prj_run_bitstream

prj_save
prj_close
