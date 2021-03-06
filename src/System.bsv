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
import Core::*;
import NoCTypes::*;
import Node::*;
import Lookup::*;



interface System;

  interface Vector#(NumNodes,CheckStatus) coreStatus;
  interface Vector#(NumNodes,FinishSim) dumpDataMem;

endinterface

(*synthesize*)
module mkSystem(System);
  
  Vector#(NumNodes,Core) cores;
  for (Integer i=0; i< valueOf(NumNodes) ; i=i+1) begin
    cores[i] <- mkCore(fromInteger(i));
  end

  //Network Design
  
  Node node[valueOf(TotalNodes)];

  for(Integer i = 0; i < valueOf(MeshSize); i = i+1) begin
    for(Integer j = 0; j < valueOf(MeshSize); j = j+1) begin
      node[3*i+j] <- mkNode(fromInteger(i),fromInteger(j)); 
    end
  end
    
  //Making Horizontal Connections
  for(Integer i = 0; i < valueOf(MeshSize); i = i+1) begin
    for(Integer j = 0; j < valueOf(MeshSize)-1; j = j+1) begin
      //Connect(node[3*i+j].east,node[3*i+j+1].west)
      mkConnection(node[3*i+j].channels[3].getNoCPacket,node[3*i+j+1].channels[4].putNoCPacket);
      mkConnection(node[3*i+j+1].channels[4].getNoCPacket,node[3*i+j].channels[3].putNoCPacket);
    end
  end

  //Making Vertical Connections
  for(Integer i = 0; i < valueOf(MeshSize) -1; i = i+1) begin
    for(Integer j = 0; j < valueOf(MeshSize); j = j+1) begin
      //Connect(node[3*i+j].south,node[3*(i+1)+j].north)
      mkConnection(node[3*i+j].channels[2].getNoCPacket,node[3*(i+1)+j].channels[1].putNoCPacket);
      mkConnection(node[3*(i+1)+j].channels[1].getNoCPacket,node[3*i+j].channels[2].putNoCPacket);
    end
  end
  
  for (Integer core_id=0; core_id < valueOf(NumNodes) ; core_id=core_id+1) begin
    //Connection between the PG network and processors
    MeshID nodeIndex = lookupNoCAddr( fromInteger(core_id) );
    mkConnection(cores[core_id].getNoCPacket, node[nodeIndex].channels[0].putNoCPacket);
    mkConnection(node[nodeIndex].channels[0].getNoCPacket, cores[core_id].putNoCPacket);
  end
    
  //Network Done
    
  //Method Interfaces
  Vector#(NumNodes,CheckStatus) coreStatusTemp;
  Vector#(NumNodes,FinishSim)   dumpDataMemTemp;
  
  for (Integer i = 0; i< valueOf(NumNodes); i =i+1) begin
    coreStatusTemp[i]  = cores[i].checkStatus; 
    dumpDataMemTemp[i] = cores[i].dumpMem; 
  end
  
  interface coreStatus = coreStatusTemp;
  interface dumpDataMem= dumpDataMemTemp;
    
endmodule
