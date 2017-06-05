import Connectable::*;
import GetPut::*;
import ClientServer::*;
import RegFile::*;
import FIFO::*;
import FIFOF::*;
import SpecialFIFOs::*;
import RWire::*;
import Arbiter::*;

import MemTypes::*;
import ProcTypes::*;
import NoCTypes::*;
import Def::*;


interface PGEmulate;
  
  //Interfaces at the NetConnect Side
  interface Put#(NoCPacket) putNetConnectPacket;
  interface Get#(NoCPacket) getNetConnectPacket;  
    
  //Interfaces at the Network Side
  interface Put#(NoCPacket) putNoCPacket;
  interface Get#(NoCPacket) getNoCPacket;

endinterface

(*synthesize*)
module mkPGEmulate#(parameter ProcID thisProcID)(PGEmulate);
  
  FIFO#(NoCPacket) netConnectPacketInQ  <- mkBypassFIFO();
  FIFO#(NoCPacket) netConnectPacketOutQ <- mkBypassFIFO();
  
  FIFO#(NoCPacket) nocPacketInQ  <- mkBypassFIFO(); 
  FIFO#(NoCPacket) nocPacketOutQ <- mkBypassFIFO();
  
  //Registers to count the number of pacekts being sent out during Broadcast.
  Reg#(Int#(32)) countLinksP2L <- mkReg(0);
  Reg#(Int#(32)) countLinksL2P <- mkReg(0);
  
  Arbiter_IFC#(2) nocPacketOutQArbiter <- mkArbiter (False);
  FIFOF#(NoCPacket) nocPacketTempQ[2];
  for(Integer i =0; i < 2; i = i+1) begin
      nocPacketTempQ[i]  <- mkBypassFIFOF();
  end
  
  
  // Outgoing from the NetConnect to the Network
  // Specify the correct line node number for the packet

  // ************************************************************************************//
  // ***************************** P2P rules start here *********************************//
  // ************************************************************************************//


  // ****************************** NetConnect -> Network *******************************//
  
  rule fromNetConnectP2P (netConnectPacketInQ.first().nocPacketType == P2P) ;
    
    //Packet at Source Point node
    
    let netCPacket = netConnectPacketInQ.first(); netConnectPacketInQ.deq();
    
    NoCAddress newDest = netCPacket.dest;
    
    //decide on which Line Node the Packet should go to
    
    Integer totalPGNodes = (valueOf(NumNodes));
    ProcID distance = 0;
    if(netCPacket.payload.dest >= thisProcID) begin
      distance = netCPacket.payload.dest - thisProcID;
    end else begin
      distance  = fromInteger(totalPGNodes) + netCPacket.payload.dest - thisProcID;
    end
    // distance is the relative dest wrt to current ProcID
    // All the calculations below are done with respect to node 0 as reference node.

    for(Integer i=0; i<valueOf(PGDegree); i=i+1) begin
      for(Integer j=0; j<valueOf(PGDegree); j=j+1) begin

        if(fromInteger((totalPGNodes - incidence[j] + incidence[i])%totalPGNodes) == distance)
          // Packet needs to be sent on the "i"th edge from point node and over the 
          // jth edge from line node
          newDest = lookupNoCAddr((thisProcID + fromInteger(incidence[i]))%fromInteger(totalPGNodes));
          // newDest is the Line Node Address
      end
    end
    
    nocPacketTempQ[0].enq(NoCPacket { src: netCPacket.src, dest: newDest, payload: netCPacket.payload, nocPacketType: netCPacket.nocPacketType, nocPacketDirection: netCPacket.nocPacketDirection});
    $display("Packet (%d,%d) is at Source Point Node %d", netCPacket.payload.src,netCPacket.payload.dest,thisProcID ); 

  endrule
  

  // ****************************** Network -> NetConnect *******************************//

  rule fromNetworkP2P (nocPacketInQ.first().nocPacketType == P2P) ; 
    let  nocPacket = nocPacketInQ.first(); nocPacketInQ.deq();
    
    if(nocPacket.nocPacketDirection == Point2Line) begin

      //Packet at Line Node

      NoCAddress newDest = nocPacket.dest;
      
      //decide on which Point Node the Packet should go to
    
      Integer totalPGNodes = (valueOf(NumNodes)); 
      ProcID distance = 0;
      if(nocPacket.payload.dest >= thisProcID) begin
        distance = nocPacket.payload.dest - thisProcID;
      end else begin
        distance  = fromInteger(totalPGNodes) + nocPacket.payload.dest - thisProcID;
      end
      // distance is the relative dest wrt to current ProcID
      // All the calculations below are done with respect to node 0 as reference node.
      
      for(Integer i=0; i<valueOf(PGDegree); i=i+1) begin
 
        if(fromInteger((totalPGNodes - incidence[i])%totalPGNodes) == distance)
         // Packet needs to be sent on the "i"th edge from line node
          newDest = lookupNoCAddr((thisProcID + fromInteger(totalPGNodes - incidence[i]))%fromInteger(totalPGNodes)) ;
        // newDest is the Point Node Address
      end
      
      nocPacketTempQ[1].enq(NoCPacket { src: nocPacket.src, dest: newDest, payload: nocPacket.payload, nocPacketType: nocPacket.nocPacketType, nocPacketDirection: Line2Point});
        
    //  $display("Packet (%d,%d) is at Line Node %d", nocPacket.payload.src,nocPacket.payload.dest,thisProcID );

    end else if(nocPacket.nocPacketDirection == Line2Point) begin
      //Packet at Destination Point Node
      netConnectPacketOutQ.enq(nocPacket);
      $display("Packet (%d,%d) is at Destination Point Node %d", nocPacket.payload.src,nocPacket.payload.dest,thisProcID );						       
    end    
  endrule
  
  // ************************************************************************************//
  // ***************************** Broadcast rules start here ***************************//
  // ************************************************************************************//

  rule fromNetConnectBroadcast (netConnectPacketInQ.first().nocPacketType == Broadcast) ;
    
    //Packet at Source Point node
    
    Integer totalPGNodes = (valueOf(NumNodes));     
    let netCPacket = netConnectPacketInQ.first(); 
    Int#(32) nextCountLinks = ?;
    
    //decide on which Line Node the Packet should go to according to how many links have already been covered
    NoCAddress newDest = lookupNoCAddr((thisProcID + fromInteger(incidence[countLinksP2L]))%fromInteger(totalPGNodes));
  
    nocPacketTempQ[0].enq(NoCPacket { src: netCPacket.src, dest: newDest, payload: netCPacket.payload, nocPacketType: netCPacket.nocPacketType, nocPacketDirection: netCPacket.nocPacketDirection});
    
    $display("Broadcast Packet (%d,%d) is at Source Point Node %d to be routed to Line Node %d", netCPacket.payload.src,netCPacket.payload.dest,thisProcID,(thisProcID + fromInteger(incidence[countLinksP2L]))%fromInteger(totalPGNodes)); 
    
    if (countLinksP2L == fromInteger(valueOf(PGDegree)) - 1 ) begin
      netConnectPacketInQ.deq();
      nextCountLinks = 0;
    end else 
      nextCountLinks = countLinksP2L +1;
  
    countLinksP2L <= nextCountLinks;
  endrule
  
  rule fromNetworkBroadcast (nocPacketInQ.first().nocPacketType == Broadcast) ; 
    let  nocPacket = nocPacketInQ.first(); 
    
    if(nocPacket.nocPacketDirection == Point2Line) begin

      //Packet at Line Node
      
      Int#(32) nextCountLinks = ?;
      Integer totalPGNodes = (valueOf(NumNodes)); 
      
      //decide on which Point Node the Packet should go to
      
      let newDestProcID = (thisProcID + fromInteger(totalPGNodes - incidence[countLinksL2P]))%fromInteger(totalPGNodes);
      NoCAddress newDest = lookupNoCAddr(newDestProcID) ;

      if(newDestProcID != nocPacket.payload.src) begin // To ensure that the packet is not broadcasted back to the source
        nocPacketTempQ[1].enq(NoCPacket { src: nocPacket.src, dest: newDest, payload: nocPacket.payload, nocPacketType: nocPacket.nocPacketType, nocPacketDirection: Line2Point});
        $display("Broadcast Packet (%d,%d) is at Line Node %d to be routed to Point Node %d", nocPacket.payload.src,nocPacket.payload.dest,thisProcID,newDestProcID);      
      end
      
      if (countLinksL2P == fromInteger(valueOf(PGDegree)) - 1 ) begin
        nocPacketInQ.deq();
        nextCountLinks = 0;
      end else 
        nextCountLinks = countLinksL2P +1;
        countLinksL2P <= nextCountLinks;
    end else if(nocPacket.nocPacketDirection == Line2Point) begin
      //Packet at Destination Point Node      
      nocPacketInQ.deq();							      
      netConnectPacketOutQ.enq(nocPacket);
      $display("Broadcast Packet (%d,%d) is at Destination Point Node %d", nocPacket.payload.src,nocPacket.payload.dest,thisProcID );						       
    end    
  endrule

  
  // Generate arbitration requests 
  rule putArbiterReqTokens;
      for (Integer i = 0; i < 2; i = i + 1) begin
        if (nocPacketTempQ[i].notEmpty) begin
          nocPacketOutQArbiter.clients[i].request;
        end
      end
  endrule
  
  // Generate n rules; each rule forwards from one input FIFO to the common output FIFO
   Rules arbiterRespRuleSet = emptyRules; 
   for (Integer i=0; i<2; i=i+1) begin 
      Rules nextRule = 
        rules 
          rule getArbiterRespToken(nocPacketOutQArbiter.clients[i].grant);    // NOTE: rule conditioned on arbiter 'grant'
            nocPacketOutQ.enq(nocPacketTempQ[i].first()); nocPacketTempQ[i].deq();         
          endrule
        endrules; 
      arbiterRespRuleSet = rJoinMutuallyExclusive(arbiterRespRuleSet,nextRule); 
   end 
   addRules(arbiterRespRuleSet);

  //Methods
  //Interfaces at the NetConnect Side
  interface  putNetConnectPacket = fifoToPut(netConnectPacketInQ);
  interface  getNetConnectPacket = fifoToGet(netConnectPacketOutQ);
    
  //Interfaces at the Network Side
  interface  putNoCPacket =  fifoToPut(nocPacketInQ);
  interface  getNoCPacket =  fifoToGet(nocPacketOutQ);
  
endmodule



