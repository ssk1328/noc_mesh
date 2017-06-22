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
import Arbiter::*;
import Vector::*;
import SpecialFIFOs::*;

import MemTypes::*;
import ProcTypes::*;
import NoCTypes::*;
import Def::*;
import Lookup::*;

/*
 0 - Home
 1 - North
 2 - South
 3 - East
 4 - West
*/

/* 
 
 Addressing of network in following manner:
  0 1 2 
0 A B C
1 D E F
2 G H I

*/

interface Node;
  interface Vector#(5,MeshDirection) channels;    
endinterface

(*synthesize*)
module mkNode#(NoCAddr2D thisRowAddr, NoCAddr2D thisColAddr )(Node);
  
  Vector#(Degree,FIFOF#(NoCPacket)) channelInQ   ;
  Vector#(Degree,FIFO#(NoCPacket)) channelOutQ   ;
  
  FIFOF#(NoCPacket) routePacketQ <- mkFIFOF();
  
  for (Integer i=0; i<valueof(Degree); i=i+1) begin 
    channelInQ[i]  <- mkSizedBypassFIFOF(1);
    channelOutQ[i] <- mkBypassFIFO();
  end
    
  //Arbiter to grant access to the appropriate channel wanting to transmit
  Arbiter_IFC#(Degree) inputChannelArbiter <- mkArbiter (False);
  Arbiter_IFC#(Degree) outputChannelArbiter <- mkArbiter (False);
  
  rule inputChannelArbiterRequest;
    for (Integer i=0; i<valueof(Degree); i=i+1) begin 
      if(channelInQ[i].notEmpty())
        inputChannelArbiter.clients[i].request;
    end
  endrule
  
  
  Rules inputArbitrateRuleSet = emptyRules; 
  for (Integer i=0; i<valueof(Degree); i=i+1) begin 
    Rules nextRule = rules
		  rule inputArbitratei(inputChannelArbiter.clients[i].grant);
        channelInQ[i].deq();
        routePacketQ.enq(channelInQ[i].first());
        NoCAddress thisNoCAddr= NoCAddress {rowAddr: thisRowAddr, colAddr: thisColAddr} ;
//        $display("Packet (%d,%d) with Destination Node %d in direction %s at Node %d",channelInQ[i].first().payload.src,channelInQ[i].first().payload.dest,lookupProcID(channelInQ[i].first().dest),getNoCPacketDir(channelInQ[i].first().nocPacketDirection),lookupProcID(thisNoCAddr));
      endrule
    endrules; 
    inputArbitrateRuleSet = rJoinMutuallyExclusive(inputArbitrateRuleSet,nextRule); 
  end 
  addRules(inputArbitrateRuleSet);


//Algorithm for routing followed : First the packet is sent horizontally, then vertically
   
  (*mutually_exclusive = "routePacketNorth,routePacketSouth,routePacketWest,routePacketEast,routePacketHome" *)
/*
  rule routePacketNorth (routePacketQ.notEmpty() && ( routePacketQ.first().dest.rowAddr < thisRowAddr ));
    routePacketQ.deq();
    channelOutQ[1].enq(routePacketQ.first());
  endrule
  
  rule routePacketSouth (routePacketQ.notEmpty() && ( routePacketQ.first().dest.rowAddr > thisRowAddr ));
    routePacketQ.deq();
    channelOutQ[2].enq(routePacketQ.first());
  endrule
  
  rule routePacketWest (routePacketQ.notEmpty() && (routePacketQ.first().dest.colAddr < thisColAddr) && ( routePacketQ.first().dest.rowAddr == thisRowAddr ));
    routePacketQ.deq();
    channelOutQ[4].enq(routePacketQ.first());
  endrule
  
  rule routePacketEast (routePacketQ.notEmpty() && (routePacketQ.first().dest.colAddr > thisColAddr) && ( routePacketQ.first().dest.rowAddr == thisRowAddr ));
    routePacketQ.deq();
    channelOutQ[3].enq(routePacketQ.first());
  endrule
  
  rule routePacketHome (routePacketQ.notEmpty() && ( routePacketQ.first().dest.rowAddr == thisRowAddr ) && (routePacketQ.first().dest.colAddr == thisColAddr) );
    routePacketQ.deq();
    channelOutQ[0].enq(routePacketQ.first());
  endrule
*/


// Algorithm for routing followed, packet is sent according to the arc plan is supposed to be sent on
  rule routePacketNorth (routePacketQ.notEmpty() && ( lookupArcDest( thisRowAddr, thisColAddr, routePacketQ.first().arcid ) == "N" ));
    routePacketQ.deq();
    channelOutQ[1].enq(routePacketQ.first());
	let noc_packet = routePacketQ.first();
    $display( "Packet (%d,%d) mesh location: (%d, %d),              for arc_id %d, loc %d , direction is N", noc_packet.payload.src, noc_packet.payload.dest, thisRowAddr, thisColAddr, noc_packet.arcid, noc_packet.payload.data.pack_add );
	endrule

  rule routePacketSouth (routePacketQ.notEmpty() && ( lookupArcDest( thisRowAddr, thisColAddr, routePacketQ.first().arcid ) == "S" ));
    routePacketQ.deq();
    channelOutQ[2].enq(routePacketQ.first());
	let noc_packet = routePacketQ.first();
    $display( "Packet (%d,%d) mesh location: (%d, %d),              for arc_id %d, loc %d , direction is S", noc_packet.payload.src, noc_packet.payload.dest, thisRowAddr, thisColAddr, noc_packet.arcid, noc_packet.payload.data.pack_add );
  endrule

  rule routePacketWest (routePacketQ.notEmpty() && ( lookupArcDest( thisRowAddr, thisColAddr, routePacketQ.first().arcid ) == "W" ));
    routePacketQ.deq();
    channelOutQ[4].enq(routePacketQ.first());
	let noc_packet = routePacketQ.first();
    $display( "Packet (%d,%d) mesh location: (%d, %d),              for arc_id %d, loc %d , direction is W", noc_packet.payload.src, noc_packet.payload.dest, thisRowAddr, thisColAddr, noc_packet.arcid, noc_packet.payload.data.pack_add );
  endrule

  rule routePacketEast (routePacketQ.notEmpty() && ( lookupArcDest( thisRowAddr, thisColAddr, routePacketQ.first().arcid ) == "E" ));
    routePacketQ.deq();
    channelOutQ[3].enq(routePacketQ.first());
	let noc_packet = routePacketQ.first();
    $display( "Packet (%d,%d) mesh location: (%d, %d),              for arc_id %d, loc %d , direction is E", noc_packet.payload.src, noc_packet.payload.dest, thisRowAddr, thisColAddr, noc_packet.arcid, noc_packet.payload.data.pack_add );
  endrule

  rule routePacketHome (routePacketQ.notEmpty() && ( lookupArcDest( thisRowAddr, thisColAddr, routePacketQ.first().arcid ) == "H" ));
    routePacketQ.deq();
    channelOutQ[0].enq(routePacketQ.first());
	let noc_packet = routePacketQ.first();
    $display( "Packet (%d,%d) mesh location: (%d, %d),              for arc_id %d, loc %d , direction is H", noc_packet.payload.src, noc_packet.payload.dest, thisRowAddr, thisColAddr, noc_packet.arcid, noc_packet.payload.data.pack_add );
  endrule


/* -----\/----- EXCLUDED -----\/-----

  
  
  rule routePacket (routePacketQ.notEmpty());
    let packet = routePacketQ.first();
    let destRow = packet.dest.rowAddr;
    let destCol = packet.dest.colAddr;
    let srcRow = packet.src.rowAddr;
    let srcCol = packet.src.colAddr;
      
//    if(destRow == 0 && destCol == 1 && srcRow ==0 && srcCol ==0)
//      $display("In Node (%d,%d),packet seen with src (%d,%d) and dest (%d,%d)  ",thisRowAddr,thisColAddr,srcRow,srcCol,destRow,destCol);
    if(destRow < thisRowAddr) //Send North
      outputChannelArbiter.clients[1].request;
    else if (destRow > thisRowAddr) //Send South
      outputChannelArbiter.clients[2].request;
    else if (destRow == thisRowAddr && destCol < thisColAddr) //Send West
      outputChannelArbiter.clients[4].request;
    else if (destRow == thisRowAddr && destCol > thisColAddr) //Send East
      outputChannelArbiter.clients[3].request;
    else if (destRow == thisRowAddr && destCol == thisColAddr) //Send Home
      outputChannelArbiter.clients[0].request;
    else begin
      $display("Error in Routing. Exiting.");
      $finish(0);
    end
      
  endrule
  
  Rules outputArbitrateRuleSet = emptyRules; 
  for (Integer i=0; i<valueof(Degree); i=i+1) begin 
    Rules nextRule = rules
		       rule outputArbitratei(outputChannelArbiter.clients[i].grant);
			 routePacketQ.deq();
			 channelOutQ[i].enq(routePacketQ.first());
		       endrule
		     endrules; 
    outputArbitrateRuleSet = rJoinMutuallyExclusive(outputArbitrateRuleSet,nextRule); 
  end 
  addRules(outputArbitrateRuleSet);
 -----/\----- EXCLUDED -----/\----- */
  
// Methods
  
  Vector#(Degree,MeshDirection) channelsTemp;    

  for (Integer i=0; i<valueOf(Degree); i=i+1) begin
    channelsTemp[i] = interface MeshDirection 
			interface Put putNoCPacket = fifoToPut(fifofToFifo(channelInQ[i]));
			interface Get getNoCPacket = fifoToGet(channelOutQ[i]);
		      endinterface;

  end 

  interface channels = channelsTemp;
    
endmodule
  
  
  
  

  
   

 


