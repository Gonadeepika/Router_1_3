 module router_fsm_tb(); 
reg clock,resetn,pkt_valid,fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done,low_packet_valid;
 reg [1:0] data_in;
 wire write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy;
 parameter T = 10; 
router_fsm DUT(clock,resetn,pkt_valid,data_in,fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done,low_packet_valid,write_enb_reg,detect_add,ld_state,laf_state, lfd_state,full_state,rst_int_reg,busy);
parameter
 DECODE_ADDRESS = 3'b000,
LOAD_FIRST_DATA = 3'b001,
LOAD_DATA = 3'b010,
WAIT_TILL_EMPTY = 3'b011,
CHECK_PARITY_ERROR = 3'b100,
LOAD_PARITY = 3'b101,
FIFO_FULL_STATE = 3'b110,
 LOAD_AFTER_FULL = 3'b111;
reg [21*8:0]string_cmd;
always@(DUT.ps) // it used to call the ps in the dut 
begin 
case (DUT.ps)
DECODE_ADDRESS : string_cmd = "DECODER_ADDRESS_s1";
LOAD_FIRST_DATA : string_cmd = "LOAD_FIRST_DATA_s2";
LOAD_DATA : string_cmd = "LOAD_DATA_s3";
WAIT_TILL_EMPTY : string_cmd = "WAIT_TILL_EMPTY_si";
CHECK_PARITY_ERROR : string_cmd = "CHECK_PARITY_ERROR_s8";
LOAD_PARITY : string_cmd = "LOAD_PARITY_TB";
FIFO_FULL_STATE : string_cmd = "FIFO_FULL_STATE_TB";
 LOAD_AFTER_FULL : string_cmd = "LOAD_AFTER_FULL_TB"; 
endcase
 end
initial 
begin 
clock=1'b0;
forever #T clock = ~clock; 
end 
task initialize;
begin
{pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2,fifo_full,parity_done,low_packet_valid}=0;
 end 
endtask 
task DA_LFA_LD_FFS_LAF_DA;
 begin
{resetn,soft_reset_0,soft_reset_1,soft_reset_2} = 0; 
data_in = 0;
{pkt_valid,low_packet_valid} = 2'b01;
fifo_full = 0;
parity_done = 0;
{fifo_empty_0,fifo_empty_1,fifo_empty_2} = 3'b111;
 end 
endtask
 task rst;
 begin
 @(negedge clock)
 resetn=1'b0;
 @(negedge clock)
 resetn=1'b1;
 end 
endtask 
task DA_LFD_LD_LP_CPE_DA; 
begin
 @(negedge clock)
 begin pkt_valid=1'b1;
 data_in[1:0]=0;
 fifo_empty_0=1;
 end
@(negedge clock)
 @(negedge clock)
 begin
pkt_valid=0; 
end
@(negedge clock)
 @(negedge clock)
 fifo_full=0;
 end
 endtask
 task DA_LFA_LD_FFS_LAF_LP_CPE_DA;
 begin @(negedge clock) 
begin pkt_valid=1;
 data_in[1:0]=0;
 fifo_empty_0=1;
 end
@(negedge clock) 
@(negedge clock) 
fifo_full=1; 
@(negedge clock)
 fifo_full=0;
 @(negedge clock)
 begin
 parity_done=0; 
low_packet_valid=1; 
end
@(negedge clock)
 @(negedge clock)
 fifo_full=0;
 end 
endtask
 task DA_LFD_LD_FFS_LAF_LD_LP_CPE_DA; 
begin @(negedge clock)
 begin pkt_valid=1; 
data_in[1:0]=0;
 fifo_empty_0=1; 
end
@(negedge clock) 
@(negedge clock) 
fifo_full=1;
 @(negedge clock)
 fifo_full=0; 
@(negedge clock) 
begin low_packet_valid=0; 
parity_done=0; 
end 
@(negedge clock) 
begin fifo_full=0;
 pkt_valid=0;
 end
 @(negedge clock)
 @(negedge clock) 
fifo_full=0; 
end
 endtask
task DA_LFD_LD_LP_CPE_FFS_LAF_DA;
 begin
 @(negedge clock) 
begin pkt_valid=1;
 data_in[1:0]=0;
 fifo_empty_0=1;
 end @(negedge clock) 
@(negedge clock)
 begin fifo_full=0;
 pkt_valid=0;
 end
 @(negedge clock)
 @(negedge clock)
 fifo_full=1;
 @(negedge clock)
 fifo_full=0;
 @(negedge clock)
 parity_done=1;
 end 
endtask
 task soft_rst;
 begin 
@(negedge clock) 
soft_reset_0 = 1'b1;
 @(negedge clock) 
soft_reset_0 = 1'b0; 
#15; 
@(negedge clock)
 soft_reset_1 = 1'b1;
 @(negedge clock) 
soft_reset_1 = 1'b0;
 #15; 
@(negedge clock)
 soft_reset_2 = 1'b1;
 @(negedge clock)
 soft_reset_2 = 1'b0; 
@(negedge clock);
 end 
endtask 
initial 
begin
 rst; 
DA_LFA_LD_FFS_LAF_DA; 
#20; 
rst; 
@(negedge clock); 
initialize;
#20
$display("--------- DA_LFD_LD_LP_CPE_DA (1)--------");
DA_LFD_LD_LP_CPE_DA; 
rst;
 #30
 $display("--------- DA_LFA_LD_FFS_LAF_LP_CPE_DA (2)--------"); 
DA_LFA_LD_FFS_LAF_LP_CPE_DA; 
rst;
#30
$display("--------- DA_LFD_LD_FFS_LAF_LD_LP_CPE_DA (3)--------"); 
DA_LFD_LD_FFS_LAF_LD_LP_CPE_DA;
 rst;
#30
$display("--------- DA_LFD_LD_LP_CPE_FFS_LAF_DA (4)--------");       
DA_LFD_LD_LP_CPE_FFS_LAF_DA;
#30;
$display("---------three soft_reset conditions (5)--------"); 
soft_rst;
end
initial 
$monitor("Reset=%b, State=%s, det_add=%b, write_enb_reg=%b, full_state=%b, lfd_state=%b, busy=%b, ld_state=%b, laf_state=%b, rst_int_reg=%b, low_packet_valid=%b",resetn,string_cmd,detect_add,write_enb_reg,full_state,lfd_state,busy,ld_state,laf_state,rst_int_reg,low_packet_valid);
initial
 begin
$dumpfile("router_fsm.vcd");
$dumpvars(); 
#1000
 $finish; 
end
endmodule
