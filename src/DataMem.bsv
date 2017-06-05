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



interface Dmem;
  interface Server#(DataReq,DataResp) dmem_server;
  interface FinishSim dumpMem; //To be used only at the end of the simulation
endinterface

//Enum for keeping state of Dumping
typedef enum {OpenDump, Dumping, CloseDump, Inactive} DumpStage deriving(Eq,Bits);

(*synthesize*)
module mkDmem#(parameter ProcID procId)( Dmem ) ;
  
  let dumpFile <- mkReg(InvalidFile) ; //For writing Dump File
  
  String init_filename = "../data/dmem/dmem_init_"+toString(procId)+".txt"; 
  RegFile#(Bit#(DataMemBitSz),Bit#(32)) mem <- mkRegFileLoad ( init_filename,0,63);
  
  FIFO#(DataReq)  dataReqQ <- mkFIFO();
  FIFO#(DataResp) dataRespQ <- mkFIFO();

  Reg#(DumpStage) dumpState  <- mkReg(Inactive); //specifies whether dump should happen or not
  Reg#(Int#(DataMemBitSz)) counter <- mkReg(0);
  
  rule access ;

    dataReqQ.deq();
    let req = dataReqQ.first();
//    $display("Data Mem in Core %d dequing",procId);
    case (req) matches 

      tagged LoadReq  .ld : 
        begin
	  let loadedData = mem.sub(ld.addr);
//	  $display("Data Mem in Core %d dequing data %x",procId,loadedData);	
	  dataRespQ.enq(LoadResp{ addr : ld.addr, data : loadedData, tag:ld.tag });
	end

      tagged StoreReq .st : 	
	begin
	  mem.upd(st.addr, st.data);
	  dataRespQ.enq(StoreResp{addr : st.addr});
	end
   
    endcase

  endrule
  
  rule openDumpFile (dumpState == OpenDump);
    String dumpFilename = "../dump/dmem/dmem_dump_"+toString(procId)+".txt"; 
    File dumpFileTemp <- $fopen( dumpFilename, "w" ) ;

    let nextDumpState = Dumping;

    if ( dumpFileTemp == InvalidFile ) begin
      $display("cannot open %s. Error. Failed to Dump. Exiting", dumpFilename);
      nextDumpState = Inactive;
    end
    dumpFile <= dumpFileTemp; // Save the file in a Register
    dumpState <= nextDumpState;  
  endrule
  
  rule dumpMemory (dumpState == Dumping);
    let nextCount = counter +1;    
    let nextDumpState = Dumping;
    
    if (pack(counter)  == 63) begin
      nextCount = 0;
      nextDumpState = CloseDump;
    end
    
    let dumpData = mem.sub(pack(counter));
    if(counter%16 == 0) begin
//      $display("In datamem  %d dump @%x\n%8x\n",procId,counter,dumpData );
      $fwrite( dumpFile , "@%x\n%8x\n",counter,dumpData);
    end
    else begin
//      $display("In datamem  %d dump %8x\n",procId,dumpData );
      $fwrite( dumpFile , "%8x\n",dumpData);
    end  
    
  //  $display ("In dmem %d, counter value is %d", counter);
    counter <= nextCount;
    dumpState <= nextDumpState;  
      
  endrule
  
  rule closeDumpFile (dumpState == CloseDump);
    $fclose(dumpFile);
    dumpState <= Inactive;
    
  endrule
    
//----------------------------------------------
// Methods

  interface Server dmem_server;
    interface Put request  = fifoToPut(dataReqQ);
    interface Get response = fifoToGet(dataRespQ);
  endinterface
  
  interface FinishSim dumpMem;
    method Action startDump ();
      dumpState <= OpenDump;
//      $display("Dumpmem called in DataMem %d",procId);
    endmethod
    
    method Bool doneDump ();
    let ret = False;
      if(dumpState == Inactive)
	ret = True;
      return ret;
    endmethod
    
  endinterface

endmodule