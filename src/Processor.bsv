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
import Vector::*;
import Arbiter::*;

import MemTypes::*;
import ProcTypes::*;
import Def::*;


interface Proc;

  // Interface from processor to caches
  interface Client#(DataReq,DataResp) dmem_client;
  interface Client#(InstReq,InstResp) imem_client;

  // Interface to and from Network Wrapper
  interface Put#(DataPacket) putDataPacket;
  interface Get#(DataPacket) getDataPacket;
  
  //Interface to check Status
  interface CheckStatus checkStatus;
endinterface


typedef enum { PCgen, Exec, Writeback, ReadFIFO, FIFOWrite} Stage deriving(Eq,Bits);

//For Dump File state
typedef enum {OpenDump, CanDump, CloseDump, Inactive} DumpStage deriving(Eq,Bits);

//For Dump Packet Type
typedef enum {P2P, Broadcast} DumpPacketType deriving(Eq,Bits);

//-----------------------------------------------------------
// Register file module
//-----------------------------------------------------------

interface RFile;
    method Action   wr( Rindx rindx, Bit#(32) data );
    method Bit#(32) rd1( Rindx rindx );
    method Bit#(32) rd2( Rindx rindx );
endinterface

module mkRFile( RFile );

  RegFile#(Rindx,Bit#(32)) rfile <- mkRegFileFull();
 
  method Action wr( Rindx rindx, Bit#(32) data );
      rfile.upd( rindx, data );
  endmethod
 
  method Bit#(32) rd1( Rindx rindx );
      return ( rindx == 31 ) ? 0 : rfile.sub(rindx);
  endmethod
 
  method Bit#(32) rd2( Rindx rindx );
      return ( rindx == 31 ) ? 0 : rfile.sub(rindx);
  endmethod

endmodule


//---------------------------------------------------------------------
// Combinational Multiplication and Addition 32bit Functions
//---------------------------------------------------------------------

function Bit#(33) add32(Bit#(32)  a, Bit#(32) b);
  Bit#(1) carry = 0; 
  Bit#(32) sum =0;
  for(Integer i = 0; i < 32; i = i+1)
    begin
      sum[i] = a[i] ^ b[i] ^ carry; 
      carry = a[i] & b[i] | carry &(a[i] ^ b[i]) ;
    end

  return {carry,sum};
endfunction

function Bit#(64) mul32(Bit#(32) a, Bit#(32) b);
  Bit#(32) prod = 0; 
  Bit#(32) shift = 0;
  for(Integer i = 0; i < 32; i = i+1)
    begin
      Bit#(32) partial = (a[i]==0)? 0 : b;
      Bit#(33) sum = add32(partial,shift);
      prod[i] = sum[0];
      shift = truncateLSB(sum);
    end
  return {shift,prod};
endfunction


/* -----\/----- EXCLUDED -----\/-----
//-----------------------------------------------------------
// Helper functions
//-----------------------------------------------------------

function Bit#(32) slt( Bit#(32) val1, Bit#(32) val2 );
    return zeroExtend( pack( signedLT(val1,val2) ) );
endfunction

function Bit#(32) sltu( Bit#(32) val1, Bit#(32) val2 );
    return zeroExtend( pack( val1 < val2 ) );
endfunction

function Bit#(32) rshft( Bit#(32) val );
    return zeroExtend(val[4:0]);
endfunction
 -----/\----- EXCLUDED -----/\----- */

//-----------------------------------------------------------
// Reference processor
//-----------------------------------------------------------


(* doc = "synthesis attribute ram_style mkProc distributed;" *)
(* synthesize *)
module  mkProc#(parameter ProcID procId) ( Proc );


  let dumpFile <- mkReg(InvalidFile) ; //For writing Dump File, Ask Dump File to open

  Reg#(ProcID) dumpFIFOReadSrc   <- mkReg(0); //For remembering src of FIFO Read or dest of FIFO write so that dump rule can have access
  Reg#(ProcID) dumpFIFOWriteDest <- mkReg(0);
  Reg#(PacketLocation) dumpFIFOWriteLoc <- mkReg(0);
  Reg#(PacketLocation) dumpFIFOReadLoc <- mkReg(0);
  //FIFOF - means that it has notEmpty and notFull signals exposed in the interface
  //LFIFOF - L means that it has pipeline property, i.e. can be deq and enq on same cycle when full.
  //GLFIFOF -G means that its enq and deq guards can be specified. if deq is not guarded, the implicit conditions of deq not happening when Empty do not hold. You will have to manually check. This is useful when you have two FIFOs being deq in same rule, and you dont want implicit conditions to be applied blindly. Here (False, True) means enq is guarded as usual, but deq is not guarded. I have to explicitly ensure that deq is happening only when notEmpty.
  
  FIFOF#(DumpPacketType) dumpFIFORead  <- mkGLFIFOF(False,True); 
  FIFOF#(DumpPacketType) dumpFIFOWrite <- mkGLFIFOF(False,True);
  Reg#(DumpStage) dumpState <- mkReg(OpenDump);
  Reg#(Int#(32)) numCycles <- mkReg (0);

  //-----------------------------------------------------------
  // State
  // Standard processor state

  Reg#(Addr)  pc      <- mkReg(0);
  Reg#(Stage) stage   <- mkReg(PCgen);
  RFile       rf      <- mkRFile;
  Reg#(Status)  state <- mkReg(Running) ; 

  // ------------------------------------------------------------
  // FIFO_WRITE ISA instruction changes
  Reg#(Bit#(4)) fifoWriteCount <- mkReg(0);      // Counter to count number of packets already sent
  Reg#(ProcID)  fifoWriteDestProc <- mkReg(0);    // Store dest proc when in exec stage
  Reg#(Rindx)   fifoWriteSrcRindx <- mkReg(0);    // Store the the source Register file index


  // -------------------------------------------------------------
  // FIFO_READ ISA instruction changes
  // For packets recieved from ith processor
  // fifoReadPacketCount[i] counts how many packets have been recieved 
  // fifoReadDataReg[i] stores the partial data as DataPackets come in
  // fifoReadDestRindx[i] stores the the destination register for packets recieved from here

  Vector#(NumNodes, Reg#(Bit#(4)))  fifoReadPacketCount;
  Vector#(NumNodes, Reg#(Bit#(32))) fifoReadDataReg;
  Vector#(NumNodes, Reg#(Rindx))    fifoReadDestRindx;

  for(Integer i=0;i<valueof(NumNodes);i=i+1) begin 
    fifoReadPacketCount[i] <- mkReg(0);
    fifoReadDataReg[i] <- mkReg(0);
    fifoReadDestRindx[i] <- mkReg(0);
  end

  //FIFOF for pending FIFORead
  FIFOF#(Instr) pendingFIFORead <- mkSizedFIFOF(valueof(NumNodes));


  /* -----\/----- EXCLUDED -----\/-----
    Reg#(Bit#(32)) cp0_tohost   <- mkReg(0);
    Reg#(Bit#(32)) cp0_fromhost <- mkReg(0);
    Reg#(Bool)    cp0_statsEn  <- mkReg(False);
  -----/\----- EXCLUDED -----/\----- */

  // Memory request/response state
   
  FIFO#(InstReq)  instReqQ    <- mkFIFO();
  FIFO#(InstResp) instRespQ   <- mkFIFO();

  FIFO#(DataReq)  dataReqQ    <- mkFIFO();
  FIFO#(DataResp) dataRespQ   <- mkFIFO();
  
  
  // FIFO Read, Write Queues
  Vector#(NumNodes, FIFO#(DataPacket)) dataPacketInQ;

  for(Integer i=0;i<valueof(NumNodes);i=i+1) begin 
      dataPacketInQ[i]  <- mkSizedFIFO(valueof(NumPackets));
  end

  FIFOF#(DataPacket) dataPacketInFQ  <- mkSizedBypassFIFOF(valueof(NumPackets));
  FIFOF#(DataPacket) dataPacketOutFQ <- mkBypassFIFOF();

  // Arbiters for FIFO Operations
  Arbiter_IFC#(NumNodes) readFIFOArbiter <- mkArbiter (False);
  Arbiter_IFC#(NumNodes) fillFIFOArbiter <- mkArbiter (False);

  /* -----\/----- EXCLUDED -----\/-----
    // Statistics state
    Reg#(Stat) num_cycles <- mkReg(0);
    Reg#(Stat) num_inst <- mkReg(0);
  -----/\----- EXCLUDED -----/\----- */

  // Writeback an arithmetic instruction.
  function Action wba(Rindx dest, Bit#(32) data) = rf.wr(dest, data);

  //-----------------------------------------------------------
  // Rules

  let pc_plus1 = pc + 1;

  rule pcgen ( stage == PCgen );
    instReqQ.enq( LoadReq{ addr:pc, tag:0 } );
    stage   <= Exec;
    // $display("Core = %d, PC = %x",procId,pc);
  endrule

  rule exec ( stage == Exec );
    instRespQ.deq();
    Instr inst = case ( instRespQ.first() ) matches
       tagged LoadResp  .ld : return unpack(ld.data);
       tagged StoreResp .st : return ?;
    endcase;
    
    $display ("Instruction is Executing in Proc %d and the inst is %x",procId,inst);
    // Some abbreviations
    let sext = signExtend;
    let zext = zeroExtend;
    let sra  = signedShiftRight;

    // Get the instruction
    
    // Some default variables
    Stage next_stage = PCgen;
    Addr  next_pc    = pc_plus1;
    DumpStage next_dump_state  = CanDump;

    case ( inst ) matches

      // -- Memory Ops ------------------------------------------------      
      tagged LW .it: begin
        Addr addr = truncate(rf.rd1(it.rbase) + sext(it.offset));
        dataReqQ.enq(LoadReq{ addr:addr,tag:it.rdst });
        // $display ("Inst in Proc %d is  Load executing for addr %d",procId, addr);
        next_stage = Writeback;
      end

      tagged SW .it: begin
        Addr addr = truncate(rf.rd1(it.rbase) + sext(it.offset));
        dataReqQ.enq( StoreReq{ addr:addr, data:rf.rd2(it.rsrc) } );
        // $display ("Inst in Proc %d is  Store executing for addr %d with value",procId, addr,rf.rd2(it.rsrc));
        next_stage = Writeback;
      end
  
  
      // -- ALU ops ---------------------------------------------------
      tagged ADD  .it : begin
        wba( it.rdst, rf.rd1(it.rsrc1) + rf.rd2(it.rsrc2) );
        // $display ("Inst in Proc %d is Add executing with result",procId, rf.rd1(it.rsrc1) + rf.rd2(it.rsrc2) );
      end

      tagged SUB  .it : begin 
        wba( it.rdst, rf.rd1(it.rsrc1) - rf.rd2(it.rsrc2) );
        // $display ("Inst in Proc %d is Sub executing with result",procId, rf.rd1(it.rsrc1) - rf.rd2(it.rsrc2));
      end

      tagged MULT .it : begin
        //Implemented as only storing the lower 32 bits of the multiplied value
        let answer = mul32(rf.rd1(it.rsrc1),rf.rd2(it.rsrc2));
        wba( it.rdst, answer[31:0] );      
        // $display ("Inst in Proc %d is Mult executing with result",procId,answer[31:0] );
      end
    
      // -- FIFO Read and FIFO Write ops ------------------------------
      tagged FIFO_WRITE .it :  begin 
        // dataPacketOutFQ.enq( DataPacket { src:procId, dest:it.destProc, data:rf.rd1(it.rsrc), isBroadcast:False } );
        // $display( "Packet (%d,%d) Sending at Proc interface:  %d ",procId, it.destProc,procId);
        // $display ("Inst in Proc %d is FIFO_Write executing with written value",procId,rf.rd1(it.rsrc));
        fifoWriteCount <= 0 ;
        fifoWriteDestProc <= it.destProc ; 
        fifoWriteSrcRindx <= it.rsrc ;
        next_stage = FIFOWrite;
      end

      tagged FIFO_READ  .it :  begin
        $display("In Proc %d, Requesting Permission for fifo read from channel %d",procId,it.srcProc);        
        pendingFIFORead.enq(inst);
        next_stage = ReadFIFO;
      end
    /* -----\/----- EXCLUDED -----\/-----

      // -- For implementing Broadcast in the FIFO Read and FIFO Write --------------------
      tagged FIFO_WRITE_BROADCAST .it :  begin 
        dataPacketOutFQ.enq( DataPacket { src:procId, dest:procId, data:rf.rd1(it.rsrc), isBroadcast : True } );
        dumpFIFOWriteDest <= procId; //If src and dest same in Datapacket, means it is a broadcast packet
        dumpFIFOWrite.enq(Broadcast);
        $display( "Broadcast Packet (%d,%d) Sending at Proc interface:  %d ",procId, procId,procId);
        // $display ("Inst in Proc %d is FIFO_Write executing with written value",procId,rf.rd1(it.rsrc));
      end
  
      tagged FIFO_READ_BROADCAST  .it :  begin
        pendingFIFORead.enq(inst); 
        next_stage = ReadFIFO;
      end

     -----/\----- EXCLUDED -----/\----- */
  
      tagged HALT .it : begin
        next_pc = pc;
        state <= Halted; 
        next_dump_state = CloseDump; //Ask dump file to close
        // $display ("Proc %d got halted",procId);
      end
  
      // -- Illegal ---------------------------------------------------
      default : $display( " RTL-ERROR : Illegal instruction encountered in execution!");
    
    endcase

    stage    <= next_stage;
    pc       <= next_pc;
    dumpState <= next_dump_state;

  endrule
  
  rule writeback ( stage == Writeback );
    dataRespQ.deq();
      case ( dataRespQ.first() ) matches
        tagged LoadResp .ld  : rf.wr( ld.tag, ld.data );  
        tagged StoreResp .st : noAction;
      endcase
    stage <= PCgen;
  endrule

  // ------------------------------------------------------------------------------------------------------------------------------------------- //
  // Rules to specify packets written to output DataPacketOutFQ one after another as a part of FIFO_WRITE Instruction
  // Added for updated FIFO_WRITE Instruction  
  Rules fifoWriteRuleSet = emptyRules;
  for (Integer i = 0; i<valueof(NumPackets); i=i+1) begin 
    Rules nextRule = rules

      rule fifoWritePacketi(stage == FIFOWrite && fifoWriteCount == fromInteger(i) );

        Payload payload32 = ?;
        payload32.pack_data = rf.rd1(fifoWriteSrcRindx)[ 4*(fifoWriteCount)+3 : 4*fifoWriteCount ] ;
        payload32.pack_add = fifoWriteCount ;

        dataPacketOutFQ.enq( DataPacket { src:procId, dest:fifoWriteDestProc, data:payload32, isBroadcast:False } );
        // dataPacketOutFQ.enq( DataPacket { src:procId, dest:it.destProc, data:rf.rd1(it.rsrc), isBroadcast:False } );

        dumpFIFOWriteDest <= fifoWriteDestProc;
        dumpFIFOWrite.enq(P2P);
        dumpFIFOWriteLoc <= fifoWriteCount;
        
        if (fifoWriteCount == 7) begin
          fifoWriteCount <= 0;
          stage <= PCgen;
        end
        else begin
          fifoWriteCount <= fifoWriteCount+1 ;
          stage <= FIFOWrite;
        end
        
      endrule

    endrules; 
    fifoWriteRuleSet = rJoinMutuallyExclusive(fifoWriteRuleSet,nextRule); 
  end 

  addRules(fifoWriteRuleSet);

  //  rule fifoWriteRuleLast(stage == FIFOWrite && fifoWriteCount == fromInteger(7) );
  //  endrule

  // ------------------------------------------------------------------------------------------------------------------------------------------- //
  // Rule to specify which FIFOQ to read from . Arbiter used to prevent deq causing implicit conditions of FIFO being notEmpty being enforced on all the queues.
  rule servicePendingFIFORead (pendingFIFORead.notEmpty());
    let pendingInst = pendingFIFORead.first();
    case ( pendingInst ) matches

      tagged FIFO_READ  .it :  begin
        readFIFOArbiter.clients[it.srcProc].request;                 
      end

      tagged FIFO_READ_BROADCAST .it : begin
        readFIFOArbiter.clients[procId].request;                 
      end

      default : $display( " RTL-ERROR : %m : Illegal state encountered in rule servicePendingFIFORead !" );

    endcase
  endrule

  Rules readFIFORuleSet = emptyRules; 
  for (Integer i=0; i<valueof(NumNodes); i=i+1) begin 
    Rules nextRule = rules

      rule readFromFIFOi(stage == ReadFIFO && readFIFOArbiter.clients[i].grant);
        // wba( regDest, readDataPacket.data);
        // stage <= PCgen;
        let regDest = case ( pendingFIFORead.first() ) matches
          tagged FIFO_READ            .it: return it.rdst;
          tagged FIFO_READ_BROADCAST  .it: return it.rdst;
        endcase;

        dataPacketInQ[i].deq();
        DataPacket readDataPacket = dataPacketInQ[i].first();

        fifoReadDestRindx[i] <= regDest;
      
    $display( "Packet (%d,%d) In FIFO_READ Instruction: reading from %d, Packet count is %d loc is %d ", readDataPacket.src, readDataPacket.dest, i, fifoReadPacketCount[i], readDataPacket.data.pack_add);

    if (fifoReadPacketCount[i] == 7) begin
      $display("In Proc %d, ifpartloop ", procId);
        fifoReadPacketCount[i] <= 0 ;
        wba( fifoReadDestRindx[i], fifoReadDataReg[i]);
        stage <= PCgen;
          pendingFIFORead.deq();

    end
    else begin
      $display("In Proc %d, elsepartloop ", procId );
          fifoReadPacketCount[i] <= fifoReadPacketCount[i]+1 ;
          fifoReadDataReg[i][3 : 0] <= readDataPacket.data.pack_data ;
      stage <= ReadFIFO;
//          let regloc = readDataPacket.data.pack_add;
//          fifoReadDataReg[i][regloc*4+3 : regloc*4] <= readDataPacket.data.pack_data ;

    end
        
      endrule
    endrules; 
    readFIFORuleSet = rJoinMutuallyExclusive(readFIFORuleSet,nextRule); 
  end 
  addRules(readFIFORuleSet);

  // ------------------------------------------------------------------------------------------------------------------------------------------- //
  // Set of rules to specify whenever a DataReg is full
  // Added for updated FIFO_READ Instruction

  /*
  Rules fifoReadRuleSet = emptyRules;
  for (Integer i=0; i<valueof(NumNodes); i=i+1) begin
    Rules nextRule = rules
      rule fifotoDataRegi(stage == ReadFIFO && fifoReadPacketCount[i] == 8);

 
      endrule
    endrules;
    fifoReadRuleSet = rJoinMutuallyExclusive(fifoReadRuleSet, nextRule);
  end
  addRules(fifoReadRuleSet);
*/

  // ------------------------------------------------------------------------------------------------------------------------------------------- //
  // Rule to specify which FIFOQ to fill in. 

  rule deqDataPacketInFQ (dataPacketInFQ.notEmpty());
    let packet = dataPacketInFQ.first();
    if(packet.isBroadcast == False)
      fillFIFOArbiter.clients[packet.src].request;      
    else 
      fillFIFOArbiter.clients[procId].request; // Broadcast Packet needs to be sent to ProcId Queue. We are using that as the Broadcast Read Queue since that is vacant anyway.
  endrule

  Rules fillFIFORuleSet = emptyRules; 

  for (Integer i=0; i<valueof(NumNodes); i=i+1) begin 
    Rules nextRule = rules
      rule fillFIFOi(fillFIFOArbiter.clients[i].grant);
        dataPacketInFQ.deq();
        let packet = dataPacketInFQ.first();
        dataPacketInQ[i].enq(packet);
       
        DumpPacketType dumpType = ?;
        if (fromInteger(i) == procId) begin
         // $display( "Broadcast Packet (%d,%d) Receiving at Proc interface: %d ",packet.src, packet.dest,procId);
          dumpFIFOReadSrc <= packet.src;
          dumpType = Broadcast;
        end
        else begin 
          $display( "Packet (%d,%d) Inside at Proc interface:    %d ",packet.src, packet.dest,procId);
          dumpFIFOReadSrc <= fromInteger(i);
          dumpType = P2P;
          dumpFIFOReadLoc <= packet.data.pack_add;
        end
        dumpFIFORead.enq(dumpType); //Dump to File that FIFORead can happen now

      endrule
    endrules; 
    fillFIFORuleSet = rJoinMutuallyExclusive(fillFIFORuleSet,nextRule);
  end

  addRules(fillFIFORuleSet);
      
  //------------------------------------------------------------
  // Dump File Create

  rule openDumpFile (dumpState == OpenDump);

    String dumpFilename = "../dump/proc/proc_dump_"+toString(procId)+".txt"; 
    File dumpFileTemp <- $fopen( dumpFilename, "w" ) ;
    
    if ( dumpFileTemp == InvalidFile ) begin
      $display("cannot open %s. Error. Failed to Dump. Exiting", dumpFilename);
      $finish(1);
    end
    dumpFile <= dumpFileTemp; // Save the file in a Register
    dumpState <= CanDump;  

  endrule
  

  rule dumpMessage (dumpState == CanDump && (dumpFIFORead.notEmpty || dumpFIFOWrite.notEmpty()));
    let readDumpPacketType = dumpFIFORead.first();
    let writeDumpPacketType = dumpFIFOWrite.first();

    if (dumpFIFORead.notEmpty() && dumpFIFOWrite.notEmpty()) begin
    
      // If both FIFO Read and FIFO Write have caused dump message to be called at the same time.
      
      if(readDumpPacketType == Broadcast && writeDumpPacketType == Broadcast) //both are Bcast
        $fwrite(dumpFile, "Proc:%d,Cycle:%4d,Src:%d,Dest:%d,Received Broadcast\nProc:%d,Cycle:%4d,Src:%d,Dest:%d,Sent Broadcast\n",procId,numCycles,dumpFIFOReadSrc,procId,procId,numCycles,procId,dumpFIFOWriteDest);
      else if (readDumpPacketType == Broadcast) //One is Bcast and other P2P
        $fwrite(dumpFile, "Proc:%d,Cycle:%4d,Src:%d,Dest:%d,Received Broadcast\nProc:%d,Cycle:%4d,Src:%d,Dest:%d,Sent\n",procId,numCycles,dumpFIFOReadSrc,procId,procId,numCycles,procId,dumpFIFOWriteDest);
      else if (writeDumpPacketType == Broadcast) //One is P2P and other Bcast
        $fwrite(dumpFile, "Proc:%d,Cycle:%4d,Src:%d,Dest:%d,Received\nProc:%d,Cycle:%4d,Src:%d,Dest:%d,Sent Broadcast\n",procId,numCycles,dumpFIFOReadSrc,procId,procId,numCycles,procId,dumpFIFOWriteDest);
      else //Both P2P
        $fwrite(dumpFile, "Proc:%d,Cycle:%4d,Src:%d,Dest:%d,Loc:%d,Received\nProc:%d,Cycle:%4d,Src:%d,Dest:%d,Loc:%d,Sent\n",procId,numCycles,dumpFIFOReadSrc,procId,dumpFIFOReadLoc,procId,numCycles,procId,dumpFIFOWriteDest,dumpFIFOWriteLoc); 
      dumpFIFORead.deq();
      dumpFIFOWrite.deq();
    end
    
    // FIFO Read has called dump message
    else if(dumpFIFORead.notEmpty) begin
      
      if (readDumpPacketType == Broadcast) //if Bcast
        $fwrite(dumpFile, "Proc:%d,Cycle:%4d,Src:%d,Dest:%d,Received Broadcast\n",procId,numCycles,dumpFIFOReadSrc,procId);
      else  //if P2P
        $fwrite(dumpFile, "Proc:%d,Cycle:%4d,Src:%d,Dest:%d,Loc:%d,Received\n",procId,numCycles,dumpFIFOReadSrc,procId,dumpFIFOReadLoc);
      dumpFIFORead.deq();
    end

    // FIFO Write has called dump message    
    else if(dumpFIFOWrite.notEmpty) begin
      if (writeDumpPacketType == Broadcast) //if Bcast
        $fwrite(dumpFile, "Proc:%d,Cycle:%4d,Src:%d,Dest:%d,Sent Broadcast\n",procId,numCycles,procId,dumpFIFOWriteDest);
      else  // if P2P
        $fwrite(dumpFile, "Proc:%d,Cycle:%4d,Src:%d,Dest:%d,Loc:%d,Sent\n",procId,numCycles,procId,dumpFIFOWriteDest,dumpFIFOWriteLoc);
      dumpFIFOWrite.deq();
    end
    
  endrule
      
  rule closeDumpFile (dumpState == CloseDump);
    $fclose(dumpFile);
    dumpState <= Inactive;
    
  endrule
  
  rule countCycles;
    numCycles <= numCycles + 1;
  endrule
      
  //-----------------------------------------------------------
  // Methods

  interface putDataPacket = toPut(dataPacketInFQ); 
  interface getDataPacket = toGet(dataPacketOutFQ);
                
  interface Client imem_client;
      interface Get request  = toGet(instReqQ);
      interface Put response = toPut(instRespQ);
  endinterface

  interface Client dmem_client;
      interface Get request  = toGet(dataReqQ);
      interface Put response = toPut(dataRespQ);
  endinterface

  interface CheckStatus checkStatus;
      method Status getState();
          return state;
      endmethod
  endinterface


/* -----\/----- EXCLUDED -----\/-----
    interface Get statsEn_get = toGet(asReg(cp0_statsEn));

    interface ProcStats stats;
        interface Get num_cycles = toGet(asReg(num_cycles));
        interface Get num_inst = toGet(asReg(num_inst));
    endinterface

-----/\----- EXCLUDED -----/\----- */

endmodule

