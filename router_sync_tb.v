 module router_sync_tb();
wire [2:0]write_enb;
 wire fifo_full;
wire vld_out_0,vld_out_1,vld_out_2;
 wire soft_reset_0,soft_reset_1,soft_reset_2;
 reg clock,resetn,detect_add; 
reg [1:0]data_in; 
reg full_0,full_1,full_2;
 reg empty_0,empty_1,empty_2; 
reg write_enb_reg;
reg read_enb_0,read_enb_1,read_enb_2; 
parameter T=20;
router_sync DUT(clock,resetn,data_in,detect_add,full_0,full_1,full_2,empty_0,empty_1,empty_2,write_enb_reg ==1'b1,read_enb_0,read_enb_1,read_enb_2,write_enb,fifo_full,vld_out_0,vld_out_1,vld_out_2,soft_reset_0,soft_reset_1,soft_reset_2);
initial begin 
clock=1'b0;
forever #(T/2) clock = ~clock; 
end
//task initialize
 task initialize;
begin
{detect_add,data_in,full_0,full_1,full_2}=0;
{write_enb_reg,read_enb_0,read_enb_1,read_enb_2,empty_0,empty_1,empty_2}=0;
 end
 endtask
//task reset
 task reset_dut();
 begin
@(negedge clock)
 resetn=1'b0;
 @(negedge clock)
 resetn=1'b1; 
end 
endtask
//task read_enb_X ,here X = 0,1,2
 task readenb(input r1,r2,r3);
begin
{read_enb_0,read_enb_1,read_enb_2}={r1,r2,r3}; 
end 
endtask
//task input and detect addresee
 task input_detect (input [1:0] d1,input detect_ad1);
 begin data_in=d1; 
detect_add=detect_ad1; 
end
 endtask
//task fifo_full 
task fifo_ful(input f1,f2,f3);
begin 
full_0=f1; 
full_1=f2;
 full_2=f3;
 end 
endtask
//task empty 
task empty_dut(input e1,e2,e3);
begin 
empty_0=e1;
 empty_1=e2;
 empty_2=e3;
 end 
endtask
//task write enb reg
 task write_enable_reg (input l1);
begin
 write_enb_reg =l1;
 end

 endtask
 initial
 begin 
initialize;
 reset_dut;
#20;
$display("-------------------------------------------------------------------------------------");
 @(negedge clock)
 readenb(1,0,0); 
input_detect(2'b00,1); 
fifo_ful(0,0,0);
 write_enable_reg (1);
 empty_dut(0,0,0);
#20;
 reset_dut;
#20;
 @(negedge clock)
 input_detect(2'b10,1);
 write_enable_reg(1'b1);
$display("--------------------------------at full_1 then, fifo_full = 1-----------------------------------------------------");
 full_0 = 1;
@(negedge clock)
 full_2 = 1; 
@(negedge clock)
 full_1 = 1;
$display("--------------------------------------soft reset = 0-----------------------------------------------");
#310; 
read_enb_0 = 1'b1;
$display("----------------------------soft reset = 1 if there is no change in the inputs-----------------------------"); 
#900; 
$finish; 
end
initial
begin
$monitor($time,"-data_in = %b, detect_add = %b, write_enb = %b, write_enb_reg == 1'b1 = %b,full_0 = %b,full_1 = %b,full_2 = %b, fifo_full = %b, vld_out_0 = %b, soft_reset_1 = %b,clk = %b ",data_in,detect_add,write_enb,write_enb_reg,full_0,full_1,full_2,fifo_full,vld_out_0,soft_reset_1,clock);
$dumpfile("router_sync_tb.vcd");
$dumpvars;
end
endmodule 

