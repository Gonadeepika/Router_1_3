module router_fsm(clock,resetn,pkt_valid,data_in,fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done,low_packet_valid,write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy);
input clock,resetn,pkt_valid,fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2;
input soft_reset_0,soft_reset_1,soft_reset_2,parity_done,low_packet_valid; 
input [1:0] data_in;
 output write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy;
// parameter declaration for the states
 parameter
 DECODE_ADDRESS = 3'b000,
LOAD_FIRST_DATA = 3'b001, 
LOAD_DATA = 3'b010,
WAIT_TILL_EMPTY = 3'b011,
CHECK_PARITY_ERROR = 3'b100,
LOAD_PARITY = 3'b101,
FIFO_FULL_STATE = 3'b110,
LOAD_AFTER_FULL = 3'b111;
 reg [2:0] ps,ns;
 always@(posedge clock)
 begin 
if(!resetn || soft_reset_0 || soft_reset_1 || soft_reset_2) 
ps <= DECODE_ADDRESS;
 else
 ps <= ns;
 end 
always@(*) 
begin
 case(ps)
DECODE_ADDRESS :
begin 
if((pkt_valid && (data_in[1:0]==0) && fifo_empty_0)|| (pkt_valid && (data_in[1:0]==1) && fifo_empty_1)|| (pkt_valid && (data_in[1:0]==2) && fifo_empty_2)) 
ns = LOAD_FIRST_DATA;
else if((pkt_valid && (data_in[1:0]==0) && (~fifo_empty_0))||(pkt_valid && (data_in[1:0]==1) && (~fifo_empty_1))||(pkt_valid && (data_in[1:0]==2) && (~fifo_empty_2))) 
ns = WAIT_TILL_EMPTY;
else
 ns = DECODE_ADDRESS; 
end
LOAD_FIRST_DATA : ns = LOAD_DATA;
 LOAD_DATA :
 begin 
if(fifo_full)
 ns=FIFO_FULL_STATE;
 else if(!fifo_full && !pkt_valid)
 ns=LOAD_PARITY;
 else
 ns=LOAD_DATA; 
end
WAIT_TILL_EMPTY : 
begin
if((!fifo_empty_0) || (!fifo_empty_1) || (!fifo_empty_2))
 ns=WAIT_TILL_EMPTY;
else if(fifo_empty_0||fifo_empty_1||fifo_empty_2) 
ns=LOAD_FIRST_DATA;
 else
ns=WAIT_TILL_EMPTY;
 end
CHECK_PARITY_ERROR:
 begin
 if(fifo_full)
 ns=FIFO_FULL_STATE;
 else
 ns=DECODE_ADDRESS;
end
LOAD_PARITY :
 ns=CHECK_PARITY_ERROR; // unconditional 
FIFO_FULL_STATE :
 begin
 if(!fifo_full)
 ns=LOAD_AFTER_FULL; 
else if(fifo_full)
 ns=FIFO_FULL_STATE;
 end
LOAD_AFTER_FULL:
 begin
if((!parity_done) && (!low_packet_valid))
 ns=LOAD_DATA;
else if((!parity_done) && (low_packet_valid)) 
ns=LOAD_PARITY;
 else if(parity_done)
 ns=DECODE_ADDRESS; 
end
default : ns = DECODE_ADDRESS;
endcase
 // end 
// else ns <= DECODE_ADDRESS; // ?
 end
assign detect_add = ((ps==DECODE_ADDRESS)?1:0); 
assign write_enb_reg=((ps==LOAD_DATA||ps==LOAD_PARITY||ps==LOAD_AFTER_FULL)?1:0);
assign full_state=((ps==FIFO_FULL_STATE)?1:0); 
assign lfd_state=((ps==LOAD_FIRST_DATA)?1:0); 
assign busy=((ps==FIFO_FULL_STATE||ps==LOAD_AFTER_FULL||ps==WAIT_TILL_EMPTY|| ps==LOAD_FIRST_DATA||ps==LOAD_PARITY||ps==CHECK_PARITY_ERROR)1:0);
assign busy=((ps==LOAD_DATA || ps==DECODE_ADDRESS)?0:1);
 assign ld_state=((ps==LOAD_DATA)?1:0);
 assign laf_state=((ps==LOAD_AFTER_FULL)?1:0);
 assign rst_int_reg=((ps==CHECK_PARITY_ERROR)?1:0);
 endmodule

