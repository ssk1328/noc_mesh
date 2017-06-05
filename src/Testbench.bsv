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

import Connectable::*;
import GetPut::*;
import ClientServer::*;
import RegFile::*;
import FIFO::*;
import FIFOF::*;
import RWire::*;
import Vector::*;

import Def::*;
import ProcTypes::*;
import MemTypes::*;
import System::*;



module mkTestBench (Empty);
  
  System dut <- mkSystem();
  Reg#(Bool) done <- mkReg(False);
  Reg#(Int#(32)) cycleCount <- mkReg(0);
  
  rule checkHalt (done == False);
    Bool halted = True;
    for(Integer i=0; i< valueOf(NumNodes) ; i=i+1) begin
      if(dut.coreStatus[i].getState() == Running)
        halted = False;	
    end
    if(halted == True) begin      
      for(Integer i=0; i< valueOf(NumNodes) ; i=i+1) begin
        dut.dumpDataMem[i].startDump();
      end      
      done <= True;
    end
  endrule
  
  rule finishSim (done == True);
    Bool dumped = True   ;
    for(Integer i=0; i< valueOf(NumNodes) ; i=i+1) begin
      if(dut.dumpDataMem[i].doneDump() == False) 
        dumped = False;
    end
    if (dumped == True) begin
      $display ("Simulation Completed **SUCESSFULLY**");
      $finish(1);
    end
    
  endrule
  
  rule countCycles ;
    cycleCount <= cycleCount +1 ;
    $display("Cycle : %d \n",cycleCount);
  endrule
  
endmodule

