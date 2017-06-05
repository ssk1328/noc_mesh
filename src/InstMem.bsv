// The MIT License

// Copyright (c) 2009 Massachusetts Institute of Technology

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


//**********************************************************************

//**********************************************************************

import Connectable::*;
import GetPut::*;
import ClientServer::*;
import RegFile::*;
import FIFO::*;
import FIFOF::*;
import RWire::*;


import MemTypes::*;
import ProcTypes::*;
import Def::*;


interface Imem;
   interface Server#(InstReq,InstResp) imem_server;
endinterface

(*synthesize*)
module mkImem#(parameter ProcID procId)( Imem ) ;

  String init_filename = "../data/imem/imem_init_"+toString(procId)+".txt"; 
  RegFile#(Bit#(InstMemBitSz),Bit#(32)) mem <- mkRegFileLoad ( init_filename,0,63);
  
  FIFO#(InstReq)  instReqQ  <- mkFIFO();
  FIFO#(InstResp) instRespQ <- mkFIFO();


  rule access ;

    instReqQ.deq();
    let req = instReqQ.first();
//    $display("Inst Mem in Core %d dequing",procId);
    case (req) matches 

// Check LoadReq addr size for using it as reference pointer to mem[.]

      tagged LoadReq  .ld : 
        begin
	  let inst = mem.sub(ld.addr);
//	  $display("Inst Mem in Core %d dequing inst %x",procId,inst);	  
	  instRespQ.enq(LoadResp { addr:ld.addr, data: inst, tag:0 } );
	end
      
      tagged StoreReq .st : noAction;
   
    endcase

  endrule
  
/* -----\/----- EXCLUDED -----\/-----
  rule instRespQisNotEmpty ;
    case ( instRespQ.first() ) matches
      tagged LoadResp  .ld : $display ("In inst Mem in core %d, inst resp Q is not empty with inst : %x",procId, ld.data);
      tagged StoreResp .st : noAction ;
    endcase
  endrule
  -----/\----- EXCLUDED -----/\----- */
  
//----------------------------------------------
// Methods

  interface Server imem_server;
    interface Put request  = fifoToPut(instReqQ);
    interface Get response = fifoToGet(instRespQ);
  endinterface

endmodule