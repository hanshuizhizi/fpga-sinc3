// ****************************************************** //
// AHB Master Wrapper Test Bench for EFLX Cores		      // 
// Copyright 2016 & 2017 Flex Logix Technologies, Inc.    //
//                                                        // 
//--------------------------------------------------------//
//														  //
//                                                        //
//========================================================//    	



`timescale 1ns/10ps
`define	CYCLE   2.0
`define	H_CYCLE 0.5*`CYCLE
`define DLY 0.2

/* ============================================ */
module ahbmaster_wrapper_tb ;


parameter  ADDR_WIDTH = 32 ; 
parameter  DATA_WIDTH =  32 ; 

 //AHB ports	
reg HCLK; 									// clock
reg HRESETn;									// active low reset
wire [DATA_WIDTH-1:0]HWDATA;							// data output
wire  HWRITE;									// write/read enable
wire [2:0]HBURST;								// burst type
wire [2:0]HSIZE;								// data size
wire [1:0]HTRANS;								// type of transfer
wire  HSEL;									// slave select 
wire [ADDR_WIDTH-1:0]HADDR;							// address bus	
reg [DATA_WIDTH-1:0]HRDATA;							// data input 
wire [1:0]HRESP;								// Slave response
reg HREADY;	


// EFLX Interface with master wrapper
reg [ADDR_WIDTH-1:0] 	TARGET_ADDRESS;
reg [DATA_WIDTH-1:0] eflx_rdata;
reg [DATA_WIDTH-1:0] eflx_rdata_i;
reg writereq;
reg readreq;
wire eflx_rvalid_data;
wire eflx_wvalid_data;
wire [DATA_WIDTH-1:0] eflx_wdata ;
reg [3:0] count;
	



/* ========== Module Under Test ========== */

ahbmaster_wrapper ahbmaster_i  (

.HCLK(HCLK),
.HRESETn(HRESETn),
.HADDR(HADDR),
.HTRANS(HTRANS),
.HWRITE(HWRITE),
.HSIZE(HSIZE),
.HBURST(HBURST),
.HSEL(HSEL),
.HWDATA(HWDATA),
.HRDATA(HRDATA),
.HRESP(HRESP),
.HREADY(HREADY),
.TARGET_ADDRESS(TARGET_ADDRESS),
.eflx_rdata(eflx_rdata),
.writereq(writereq),
.readreq(readreq),
.eflx_rvalid_data(eflx_rvalid_data),
.eflx_wvalid_data(eflx_wvalid_data),
.eflx_wdata(eflx_wdata)

);
 
    
   
   
/* ======================================= */

// ********** Clock ********** //
always #(`H_CYCLE) HCLK = ~HCLK ;

//EFLX Data Simulation on master side


always @(posedge HCLK)
if (!HRESETn) count<=0;
else if (writereq & count<7)
begin
eflx_rdata<=eflx_rdata +1;
count<=count+1;
end



always @(posedge eflx_wvalid_data)
HRDATA<=HRDATA +1;





// ********** Simulation Start ********** //
initial
  begin

   	HCLK=0;
	eflx_rdata=32'hffffffff;
	HRDATA=32'h00000000;
	writereq=0;
	readreq=0;
	HRESETn = 1 ;
    	TARGET_ADDRESS=0;
	HREADY=0;
	HRDATA=0;


	
    # (`H_CYCLE)
    HRESETn = 0 ;
    # (10 * `CYCLE)
    HRESETn = 1 ;
    # (10* `CYCLE)
    # (`DLY) 
   
//Single write cycle
    	TARGET_ADDRESS=32'ha0000000;
	writereq=1;
	# (1* `CYCLE)
	writereq=0;
    	# (2* `CYCLE)
	HREADY=1;
	# (1* `CYCLE)
	HREADY=0;
	# (10* `CYCLE)
// Single read cycle
	TARGET_ADDRESS=32'hb0000000;
	readreq=1;
	# (1* `CYCLE)
	readreq=0;
	# (4* `CYCLE)
	HREADY=1;
	# (1* `CYCLE)
	HREADY=0;
	# (10* `CYCLE)
//write burst 	
TARGET_ADDRESS=32'hc0000000;
	writereq=1;
	eflx_rdata=00000001;
	# (4* `CYCLE)
	HREADY=1;
    	# (13* `CYCLE)
	writereq=0;
	# (2* `CYCLE)
	HREADY=0;
	# (20* `CYCLE)
//read burst
	TARGET_ADDRESS=32'hd0000000;
	readreq=1;
	# (4* `CYCLE)
	HREADY=1;
    	# (13* `CYCLE)
	readreq=0;



	//# (1* `CYCLE)
    
		
end

 
endmodule