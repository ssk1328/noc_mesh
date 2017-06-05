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

import MemTypes::*;
import ProcTypes::*;
import Processor::*;
import DataMem::*;
import InstMem::*;
import NetConnect::*;
import PGEmulate::*;
import Def::*;

interface Core;
  
  interface Put#(NoCPacket) putNoCPacket;
  interface Get#(NoCPacket) getNoCPacket;

  interface CheckStatus checkStatus;
  interface FinishSim dumpMem;
endinterface

(*synthesize*)
module mkCore#(parameter ProcID procId)( Core);

  Dmem dataMemory         <- mkDmem(procId);
  Imem instMemory         <- mkImem(procId);
  Proc cpu 	          <- mkProc(procId);
  NetConnect cpuToNetwork <- mkNetConnect();
  PGEmulate netConnectToNetwork <- mkPGEmulate(procId);
  
  mkConnection(cpu.dmem_client,dataMemory.dmem_server);
  mkConnection(cpu.imem_client,instMemory.imem_server);
  
  mkConnection(cpuToNetwork.getDataPacket,cpu.putDataPacket); //network to cpu
  mkConnection(cpu.getDataPacket,cpuToNetwork.putDataPacket); //cpu to network
  
  mkConnection(netConnectToNetwork.getNetConnectPacket,cpuToNetwork.putNoCPacket);
  mkConnection(cpuToNetwork.getNoCPacket, netConnectToNetwork.putNetConnectPacket); 
  
//Methods  
//  interface putNoCPacket = cpuToNetwork.putNoCPacket;
//  interface getNoCPacket = cpuToNetwork.getNoCPacket;
  interface putNoCPacket = netConnectToNetwork.putNoCPacket;
  interface getNoCPacket = netConnectToNetwork.getNoCPacket;
  interface checkStatus  = cpu.checkStatus; 
  interface dumpMem      = dataMemory.dumpMem;
endmodule
  