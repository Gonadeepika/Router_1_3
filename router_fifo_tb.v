module router_fifo_tb;
reg clock,resetn,soft_reset,write_enb,read_enb,lfd_state;
 reg [7:0] data_in; 
wire empty,full;
 wire [7:0] data_out; //dut instantiation 
router_fifo dut (clock,resetn,soft_reset,write_enb,read_enb,lfd_state,data_in,full,empty,data_out); 
initial
 begin
clock = 1'b0; 
forever #10 clock = ~clock; 
end //tasks 
task initialization;
 begin
resetn = 1'b0;
soft_reset = 1'b1; 

write_enb = 1'b0; 
read_enb = 1'b0;
end
 endtask 
task reset; 
begin
@(negedge clock); 

resetn = 1'b0;
@(negedge clock) resetn = 1'b1; 
end

 endtask
task soft_rst; 
begin
@(negedge clock) soft_reset = 1'b1;
@(negedge clock) soft_reset = 1'b0; 
end 
endtask 
task write_fifo(); begin : B1
 reg [7:0] payload_data,parity,header; 
reg [5:0] payload_len;
reg [1:0] addr;
integer i;
 @(negedge clock) payload_len = 6'd14; 
addr = 2'b01; 
header = {payload_len,addr};
 data_in = header; 
lfd_state = 1'b1;
 write_enb = 1'b1;
for (i = 0; i<payload_len; i=i+1 )
begin
@(negedge clock); 
lfd_state = 1'b0; 
payload_data = {$random}%256;
 data_in = payload_data;
 end
@(negedge clock);
 lfd_state = 1'b0;
 parity = {$random}%256; 
data_in = parity;
end 
endtask
task read_fifo();
begin
 @(negedge clock);
 write_enb = 1'b0;
 read_enb = 1'b1 ;
end 
endtask //Task for delay 
task delay;
 begin
#50;
 end 
endtask
 initial begin : B2 
integer i;
initialization;
 delay;
 reset; 
soft_rst; 
write_fifo; 
for (i = 0;i<17 ;i = i+1 ) 
begin read_fifo;
 end delay; 
read_enb = 1'b0;
end
 initial begin
$monitor($time,"-> data_out =%0b,full =%0b,empty =%0b,data_in =%0b,resetn =%0b,soft_reset=%0b,write_enb =%0b,read_enb =%0b,lfd_state=%0b",data_out,full,empty,data_in,resetn,soft_reset,write_enb,read_enb,lfd_state);
$dumpfile("router_fifo_tb.vcd");
$dumpvars;
#2000 $finish; 
end 
endmodule
