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
import SpecialFIFOs::*;
import RWire::*;

import MemTypes::*;
import ProcTypes::*;
import Def::*;
import Lookup::*;

interface NetConnect;
  
  //Interfaces at the Processor Side
  interface Put#(DataPacket) putDataPacket;
  interface Get#(DataPacket) getDataPacket;  
    
  //Interfaces at the Network Side
  interface Put#(NoCPacket) putNoCPacket;
  interface Get#(NoCPacket) getNoCPacket;

endinterface

(*synthesize*)
module mkNetConnect(NetConnect);
  
  FIFO#(DataPacket) dataPacketInQ  <- mkBypassFIFO();
  FIFO#(DataPacket) dataPacketOutQ <- mkBypassFIFO();
  
  FIFO#(NoCPacket) nocPacketInQ  <- mkBypassFIFO(); 
  FIFO#(NoCPacket) nocPacketOutQ <- mkBypassFIFO();
  
  
  //Outgoing from the Processor to the Network
  
  rule addLayer ;
    dataPacketInQ.deq();
    let datapacket = dataPacketInQ.first();

/*
    NoCPacketType currPacketType = ?;
    if(datapacket.isBroadcast == True) begin
      currPacketType = Broadcast;
      $display( "Broadcast Packet (%d,%d) Sending at network interface:  %d ",datapacket.src, datapacket.dest,datapacket.src);
    end else begin
      currPacketType = P2P;
    end	       
    
    NoCPacketDirection currPacketDir = Point2Line;
*/

//    nocPacketOutQ.enq( NoCPacket { src: lookupNoCAddr(datapacket.src), dest: lookupNoCAddr(datapacket.dest), payload: datapacket, nocPacketType: currPacketType, nocPacketDirection: currPacketDir} );  

    NoCArcId arc_id_netcon = lookupNoCArcId(datapacket.src, datapacket.dest, datapacket.data.pack_add);
    nocPacketOutQ.enq( NoCPacket { arcid: arc_id_netcon, payload: datapacket} );  

    $display( "Packet (%d,%d) Sending at network interface:  %d, alloted arc_id is %d ",datapacket.src, datapacket.dest, datapacket.src, arc_id_netcon );

  endrule
  
  
  //Incoming from the Network to the Processor
  rule removeLayer ;
    nocPacketInQ.deq();
    let nocPacket = nocPacketInQ.first();
    dataPacketOutQ.enq( nocPacket.payload );
    $display( "Packet (%d,%d) Receiving at network interface: %d ",nocPacket.payload.src, nocPacket.payload.dest,nocPacket.payload.dest);
  endrule
  
  //Methods
   //Interfaces at the Processor Side
  interface  putDataPacket = fifoToPut(dataPacketInQ);
  interface  getDataPacket = fifoToGet(dataPacketOutQ);
    
  //Interfaces at the Network Side
  interface  putNoCPacket =  fifoToPut(nocPacketInQ);
  interface  getNoCPacket =  fifoToGet(nocPacketOutQ);
  
endmodule
