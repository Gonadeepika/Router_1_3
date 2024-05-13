 module router_top_tb();
reg clk, resetn, read_enb_0, read_enb_1, read_enb_2, packet_valid; 
reg [7:0]data_in;
 wire [7:0]data_out_0, data_out_1, data_out_2;
 wire vld_out_0, vld_out_1, vld_out_2, err, busy;
 integer i;
 parameter 
cycle=10;
 router_top DUT(.clock(clk), .resetn(resetn),.read_enb_0(read_enb_0),.read_enb_1(read_enb_1),.read_enb_2(read_enb_2),.pkt_valid(packet_valid),.data_in(data_in),.data_out_0(data_out_0),.data_out_1(data_out_1),.data_out_2(data_out_2),.vld_out_0(vld_out_0),.vld_out_1(vld_out_1),.vld_out_2(vld_out_2),.err(err),.busy(busy) );
//clock generation 
initial 
begin clk = 1;
 forever #5 clk = ~clk;
 end
task reset;
 begin 
@(negedge clk)
 resetn=1'b0; 
@(negedge clk)
 resetn=1'b1;
 end
 endtask
task initialize;
 begin
 resetn = 1'b1;
{read_enb_0, read_enb_1, read_enb_2, packet_valid}=0; 
end 
endtask
task pktm_gen_5; 
reg [7:0]header, payload_data, parity; 
reg [8:0]payloadlen;
begin parity=0;
 wait(!busy)
 begin @(negedge clk);
 payloadlen=5; 
packet_valid=1'b1;
 header={payloadlen,2'b10};
 data_in=header;
 parity=parity^data_in; 
end
 @(negedge clk);
for(i=0;i<payloadlen;i=i+1) 
begin
 wait(!busy)
 begin
 @(negedge clk);
 payload_data={$random}%256;
 data_in=payload_data; 
parity=parity^data_in; 
end
 end
wait(!busy)
 begin
@(negedge clk); 
packet_valid=0; 
data_in=parity;
 end 
repeat(2) 
@(negedge clk);
 read_enb_2=1'b1;
wait(DUT.FIFO_2.empty)
 @(negedge clk)
 read_enb_2=0; 
end 
endtask
task pktm_gen_14;
 reg [7:0]header, payload_data, parity; 
reg [8:0]payloadlen;
begin 
parity=0;
 wait(!busy)
 begin 
@(negedge clk); 
payloadlen=14; 
packet_valid=1'b1;
 header={payloadlen,2'b01};
 data_in=header;
 parity=parity^data_in;
 end 
@(negedge clk);
for(i=0;i<payloadlen;i=i+1) 
begin
 wait(!busy)
 begin
 @(negedge clk); 
payload_data={$random}%256;
 data_in=payload_data; 
parity=parity^data_in; 
end 
end
wait(!busy)
 begin
@(negedge clk); 
packet_valid=0;
 data_in=parity;
 end 
repeat(2)
 @(negedge clk);
 read_enb_1=1'b1;
wait(DUT.FIFO_1.empty)
 @(negedge clk) 
read_enb_1=0; 
end
endtask
task pktm_gen_16;
 reg [7:0]header, payload_data, parity; 
reg [8:0]payloadlen;
begin
 parity=0; 
wait(!busy) 
begin 
@(negedge clk); 
payloadlen=16;
 packet_valid=1'b1;
 header={payloadlen,2'b00};
 data_in=header; 
parity=parity^data_in;
 end 
@(negedge clk);
for(i=0;i<payloadlen;i=i+1) 
begin 
wait(!busy) 
begin
 @(negedge clk); 
payload_data={$random}%256;
 data_in=payload_data;
 parity=parity^data_in;
 end
 end
wait(!busy)
 begin
@(negedge clk);
 packet_valid=0;
 data_in=parity;
 end 
repeat(2)
 @(negedge clk);
 read_enb_0=1'b1; 
wait(DUT.FIFO_0.empty)
 @(negedge clk)
 read_enb_0=0;
 end 
endtask
initial
 begin
 initialize; 
reset;
 #10; 
pktm_gen_5;
 #100; 
reset;
 pktm_gen_14;
 #100;
 pktm_gen_16;
 #700;
 $finish;
 end
initial
 begin
$dumpfile("router_top_tb.vcd");
$dumpvars;
 end 
endmodule
