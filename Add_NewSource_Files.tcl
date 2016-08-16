set myScript "Add_NewSource_Files.tcl"
set myProject "ADQ214_devkit"
set myFPGA "alg_sx50t"
set DesignName "adq_alg_fpga"

# 
# add_source_files
# 
# This procedure add the source files that were known to the project at the
# time this script was generated.
# 
proc add_newsource {} {

   global myScript
   global myProject
   global myFPGA
   global DesignName

   putstatus $myScript "Adding sources to project..."
   project open ../implementation/xilinx/${myProject}.xise
   
   xfile add "../../source/FIFO_In.v"
   xfile add "../../source/FIFO_TC.v"
   xfile add "../../source/Group_Ctrl.v"
   xfile add "../../source/Power_Spec_Cal.v"
   xfile add "../../source/Pulse_Counter.v"
   xfile add "../../source/RangeBin_Counter.v"
   xfile add "../../source/SPEC_Acc.v"
   xfile add "../../source/Trigger_Decoder.v"
   xfile add "../../source/userlogical_processing_tb.v"
   xfile add "../../source/ipcore_dir/DPRAM_Buffer.xco"
   xfile add "../../source/ipcore_dir/DPRAM_Buffer_BG.xco"
   xfile add "../../source/ipcore_dir/fifo_Buffer_in.xco"
   xfile add "../../source/ipcore_dir/Fifo_Buffer_Tc.xco"
   xfile add "../../source/ipcore_dir/Multiplier_16.xco"
   xfile add "../../source/ipcore_dir/xfft_v7_1.xco"
   

   # Set the Top Module as well...
   project set top "adq_alg_fpga"

   putstatus $myScript "Project sources reloaded."

} ; # end add_source_files

proc putstatus {ScriptName Status} {
    set CurrentTime [clock format [clock seconds] -format {%Y-%m-%d %H:%M:%S}]
    puts "$ScriptName: $CurrentTime $Status"
}
