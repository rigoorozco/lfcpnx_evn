# Create project for LFCPNX-EVN board

if { $argc != 3 } {
    puts "Usage:"
    puts "   create_project.tcl <project_name> <use_ip_eval (bool)> <firmware path>"
    exit 1
}

set project_name "[lindex $argv 0]"
set use_ip_eval "[lindex $argv 1]"
set firmware_path "[lindex $argv 2]"

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

prj_set_strategy_value bit_ip_eval=$use_ip_eval

prj_set_impl_opt "include path" $firmware_path

prj_save
prj_close
