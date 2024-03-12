# Create project for LFCPNX-EVN board

if { $argc != 1 } {
    puts "Name for the project must be provided!"
    exit 1
}

set project_name "[lindex $argv 0]"

prj_create \
    -name $project_name \
    -dir $project_name \
    -dev "LFCPNX-100-9LFG672C" \
    -performance "9_High-Performance_1.0V" \
    -impl "impl_1" \
    -synthesis "synplify"

source ../sources.tcl
foreach file $project_files {
    prj_add_source $file
}

prj_set_top_module lfcpnx_evn

prj_save
prj_close
