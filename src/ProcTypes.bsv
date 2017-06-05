
//----------------------------------------------------------------------
// CheckStatus interface used to check the status of the processor
//----------------------------------------------------------------------


interface CheckStatus;
    method Status getState();
endinterface

//----------------------------------------------------------------------
// FinishSim interface used to dump the condition of the data memory
//----------------------------------------------------------------------

interface FinishSim;
  method Action startDump () ; //Used to dump the memory contents at the end of simulation
  method Bool doneDump ();
endinterface

//----------------------------------------------------------------------
// Other typedefs
//----------------------------------------------------------------------


typedef 6 AddrSz;
//typedef 00 TagSz;
typedef 32 DataSz;
typedef 32 InstSz;

typedef Bit#(AddrSz) Addr;
typedef Int#(18) Stat;

//----------------------------------------------------------------------
// Basic instruction type
//----------------------------------------------------------------------

typedef Bit#(5)  Rindx;
typedef Bit#(16) Simm;
typedef Bit#(16) Zimm;
typedef Bit#(32) Epoch;
typedef Bit#(5)  Shamt;
typedef Bit#(26) Target;
typedef Bit#(5)  CP0indx;
typedef Bit#(32) Data;
typedef Bit#(4)  ProcID;
typedef enum { Running, Halted } Status deriving(Eq,Bits);

//----------------------------------------------------------------------
// Pipeline typedefs
//----------------------------------------------------------------------

typedef union tagged                
{

  struct { Rindx rbase; Rindx rdst;  Simm offset;  } LW;
  struct { Rindx rbase; Rindx rsrc;  Simm offset;  } SW; 
 
 /* -----\/----- EXCLUDED -----\/-----
  struct { Rindx rsrc;  Rindx rdst;  Simm imm;     } ADDIU;
  struct { Rindx rsrc;  Rindx rdst;  Simm imm;     } SLTI;
  struct { Rindx rsrc;  Rindx rdst;  Simm imm;     } SLTIU;
  struct { Rindx rsrc;  Rindx rdst;  Zimm imm;     } ANDI;
  struct { Rindx rsrc;  Rindx rdst;  Zimm imm;     } ORI;
  struct { Rindx rsrc;  Rindx rdst;  Zimm imm;     } XORI;
  struct {              Rindx rdst;  Zimm imm;     } LUI;

  struct { Rindx rsrc;  Rindx rdst;  Shamt shamt;  } SLL;
  struct { Rindx rsrc;  Rindx rdst;  Shamt shamt;  } SRL;
  struct { Rindx rsrc;  Rindx rdst;  Shamt shamt;  } SRA;
  struct { Rindx rsrc;  Rindx rdst;  Rindx rshamt; } SLLV;
  struct { Rindx rsrc;  Rindx rdst;  Rindx rshamt; } SRLV;
  struct { Rindx rsrc;  Rindx rdst;  Rindx rshamt; } SRAV;
  struct { Rindx rsrc1; Rindx rsrc2; Rindx rdst;   } ADDU;
  struct { Rindx rsrc1; Rindx rsrc2; Rindx rdst;   } SUBU;
  struct { Rindx rsrc1; Rindx rsrc2; Rindx rdst;   } AND;
  struct { Rindx rsrc1; Rindx rsrc2; Rindx rdst;   } OR;
  struct { Rindx rsrc1; Rindx rsrc2; Rindx rdst;   } XOR;
  struct { Rindx rsrc1; Rindx rsrc2; Rindx rdst;   } NOR;
  struct { Rindx rsrc1; Rindx rsrc2; Rindx rdst;   } SLT;
  struct { Rindx rsrc1; Rindx rsrc2; Rindx rdst;   } SLTU;
 
  struct { Rindx rdst;                             } MFHI;
  struct { Rindx rdst;                             } MFLO;                               
  struct { Rindx rsrc1; Rindx rsrc2;               } MULT;
  struct { Target target;                          } J;
  struct { Target target;                          } JAL;
  struct { Rindx rsrc;                             } JR;
  struct { Rindx rsrc;  Rindx rdst;                } JALR;
  struct { Rindx rsrc1; Rindx rsrc2; Simm offset;  } BEQ;
  struct { Rindx rsrc1; Rindx rsrc2; Simm offset;  } BNE;
  struct { Rindx rsrc;  Simm offset;               } BLEZ;
  struct { Rindx rsrc;  Simm offset;               } BGTZ;
  struct { Rindx rsrc;  Simm offset;               } BLTZ;
  struct { Rindx rsrc;  Simm offset;               } BGEZ;

  struct { Rindx rdst;  CP0indx cop0src;           } MFC0;
  struct { Rindx rsrc;  CP0indx cop0dst;           } MTC0; 
 -----/\----- EXCLUDED -----/\----- */
 
 struct { Rindx rsrc1; Rindx rsrc2; Rindx rdst;   } ADD;
 struct { Rindx rsrc1; Rindx rsrc2; Rindx rdst;   } SUB;
 struct { Rindx rsrc1; Rindx rsrc2; Rindx rdst;   } MULT;

 struct { Rindx rsrc; ProcID destProc;            } FIFO_WRITE;
 struct { Rindx rdst; ProcID srcProc;             } FIFO_READ;
 struct { Rindx rsrc;                             } FIFO_WRITE_BROADCAST;
 struct { Rindx rdst;                             } FIFO_READ_BROADCAST;
 void                                               HALT;
 void                                               ILLEGAL;

}
Instr deriving(Eq);

//----------------------------------------------------------------------
// Pack and Unpack
//----------------------------------------------------------------------

Bit#(6) opFUNC        = 6'b000000;  
Bit#(6) opLW          = 6'b100011;
Bit#(6) opSW          = 6'b101011;
//Bit#(6) opANDI        = 6'b001100;
Bit#(6) opFIFO_WRITE  = 6'b010111;
Bit#(6) opFIFO_READ   = 6'b010110;
Bit#(6) opFIFO_WRITE_BROADCAST  = 6'b110111;
Bit#(6) opFIFO_READ_BROADCAST   = 6'b110110;
Bit#(32) opHALT        = 32'b0;

Bit#(6) fcADD   = 6'b100000;
Bit#(6) fcSUB   = 6'b100010;
Bit#(6) fcMULT  = 6'b100001; //NOT compatible with MIPS
Bit#(6) fcHALT  = 6'b000000;

/* -----\/----- EXCLUDED -----\/-----

                              Bit#(6) fcSLL   = 6'b000000;
Bit#(6) opRT    = 6'b000001;  Bit#(6) fcSRL   = 6'b000010;
Bit#(6) opRS    = 6'b010000;  Bit#(6) fcSRA   = 6'b000011;
                              Bit#(6) fcSLLV  = 6'b000100;
                              Bit#(6) fcSRLV  = 6'b000110;
                              Bit#(6) fcSRAV  = 6'b000111;
                              Bit#(6) fcADDU  = 6'b100001;
Bit#(6) opADDIU = 6'b001001;  Bit#(6) fcSUBU  = 6'b100011;
Bit#(6) opSLTI  = 6'b001010;  Bit#(6) fcAND   = 6'b100100;
Bit#(6) opSLTIU = 6'b001011;  Bit#(6) fcOR    = 6'b100101;
                              Bit#(6) fcXOR   = 6'b100110;
Bit#(6) opORI   = 6'b001101;  Bit#(6) fcNOR   = 6'b100111;
Bit#(6) opXORI  = 6'b001110;  Bit#(6) fcSLT   = 6'b101010;
Bit#(6) opLUI   = 6'b001111;  Bit#(6) fcSLTU  = 6'b101011;

Bit#(6) fcMFHI  = 6'b010000;
Bit#(6) fcMFLO  = 6'b010010;
Bit#(6) fcMULT  = 6'b011000;

Bit#(6) opJ     = 6'b000010;
Bit#(6) opJAL   = 6'b000011;
Bit#(6) fcJR    = 6'b001000;
Bit#(6) fcJALR  = 6'b001001;
Bit#(6) opBEQ   = 6'b000100;
Bit#(6) opBNE   = 6'b000101;
Bit#(6) opBLEZ  = 6'b000110;
Bit#(6) opBGTZ  = 6'b000111;
Bit#(5) rtBLTZ  = 5'b00000;
Bit#(5) rtBGEZ  = 5'b00001;

Bit#(5) rsMFC0  = 5'b00000;
Bit#(5) rsMTC0  = 5'b00100;
 -----/\----- EXCLUDED -----/\----- */

instance Bits#(Instr,32);

  // Pack Function

  function Bit#(32) pack( Instr instr );

    case ( instr ) matches
      
      //Load Store
      tagged LW    .it : return { opLW,    it.rbase, it.rdst,  it.offset };
      tagged SW    .it : return { opSW,    it.rbase, it.rsrc,  it.offset };
      
      //ALU
      tagged ADD   .it : return { opFUNC,  it.rsrc1, it.rsrc2, it.rdst,   5'b0,     fcADD }; 
      tagged SUB   .it : return { opFUNC,  it.rsrc1, it.rsrc2, it.rdst,   5'b0,     fcSUB }; 
      tagged MULT   .it : return { opFUNC,  it.rsrc1, it.rsrc2, it.rdst,   5'b0,     fcMULT }; 
      
      //FIFO read write
      tagged FIFO_WRITE .it : return {opFIFO_WRITE, it.rsrc, 17'b0, it.destProc  };
      tagged FIFO_READ  .it : return {opFIFO_READ,  it.rdst, 17'b0, it.srcProc   }; 	
  
      ////FIFO read write Broadcast
      tagged FIFO_WRITE_BROADCAST .it : return {opFIFO_WRITE_BROADCAST, it.rsrc, 21'b0};
      tagged FIFO_READ_BROADCAST  .it : return {opFIFO_READ_BROADCAST,  it.rdst, 21'b0}; 	
          
      //Halt
      tagged HALT  .it : return { opHALT };
/* -----\/----- EXCLUDED -----\/-----
      tagged ADDIU .it : return { opADDIU, it.rsrc,  it.rdst,  it.imm                      }; 
      tagged SLTI  .it : return { opSLTI,  it.rsrc,  it.rdst,  it.imm                      }; 
      tagged SLTIU .it : return { opSLTIU, it.rsrc,  it.rdst,  it.imm                      }; 
      tagged ANDI  .it : return { opANDI,  it.rsrc,  it.rdst,  it.imm                      }; 
      tagged ORI   .it : return { opORI,   it.rsrc,  it.rdst,  it.imm                      }; 
      tagged XORI  .it : return { opXORI,  it.rsrc,  it.rdst,  it.imm                      }; 
      tagged LUI   .it : return { opLUI,   5'b0,     it.rdst,  it.imm                      };

      tagged SLL   .it : return { opFUNC,  5'b0,     it.rsrc,  it.rdst,   it.shamt, fcSLL  }; 
      tagged SRL   .it : return { opFUNC,  5'b0,     it.rsrc,  it.rdst,   it.shamt, fcSRL  }; 
      tagged SRA   .it : return { opFUNC,  5'b0,     it.rsrc,  it.rdst,   it.shamt, fcSRA  }; 

      tagged SLLV  .it : return { opFUNC,  it.rshamt, it.rsrc, it.rdst,   5'b0,     fcSLLV }; 
      tagged SRLV  .it : return { opFUNC,  it.rshamt, it.rsrc, it.rdst,   5'b0,     fcSRLV }; 
      tagged SRAV  .it : return { opFUNC,  it.rshamt, it.rsrc, it.rdst,   5'b0,     fcSRAV }; 

      tagged ADDU  .it : return { opFUNC,  it.rsrc1, it.rsrc2, it.rdst,   5'b0,     fcADDU }; 
      tagged SUBU  .it : return { opFUNC,  it.rsrc1, it.rsrc2, it.rdst,   5'b0,     fcSUBU }; 
      tagged AND   .it : return { opFUNC,  it.rsrc1, it.rsrc2, it.rdst,   5'b0,     fcAND  }; 
      tagged OR    .it : return { opFUNC,  it.rsrc1, it.rsrc2, it.rdst,   5'b0,     fcOR   }; 
      tagged XOR   .it : return { opFUNC,  it.rsrc1, it.rsrc2, it.rdst,   5'b0,     fcXOR  }; 
      tagged NOR   .it : return { opFUNC,  it.rsrc1, it.rsrc2, it.rdst,   5'b0,     fcNOR  }; 
      tagged SLT   .it : return { opFUNC,  it.rsrc1, it.rsrc2, it.rdst,   5'b0,     fcSLT  }; 
      tagged SLTU  .it : return { opFUNC,  it.rsrc1, it.rsrc2, it.rdst,   5'b0,     fcSLTU }; 
      
      tagged MFHI  .it : return { opFUNC,  5'b0,     5'b0,     it.rdst,   5'b0,     fcMFHI }; 
      tagged MFLO  .it : return { opFUNC,  5'b0,     5'b0,     it.rdst,   5'b0,     fcMFLO }; 
      tagged MULT  .it : return { opFUNC,  it.rsrc1, it.rsrc2, 5'b0,      5'b0,     fcMULT };       

      tagged J     .it : return { opJ,     it.target                                       }; 
      tagged JAL   .it : return { opJAL,   it.target                                       }; 
      tagged JR    .it : return { opFUNC,  it.rsrc,  5'b0,     5'b0,      5'b0,     fcJR   };
      tagged JALR  .it : return { opFUNC,  it.rsrc,  5'b0,     it.rdst,   5'b0,     fcJALR };
      tagged BEQ   .it : return { opBEQ,   it.rsrc1, it.rsrc2, it.offset                   }; 
      tagged BNE   .it : return { opBNE,   it.rsrc1, it.rsrc2, it.offset                   }; 
      tagged BLEZ  .it : return { opBLEZ,  it.rsrc,  5'b0,     it.offset                   }; 
      tagged BGTZ  .it : return { opBGTZ,  it.rsrc,  5'b0,     it.offset                   }; 
      tagged BLTZ  .it : return { opRT,    it.rsrc,  rtBLTZ,   it.offset                   }; 
      tagged BGEZ  .it : return { opRT,    it.rsrc,  rtBGEZ,   it.offset                   }; 

      tagged MFC0  .it : return { opRS,    rsMFC0,   it.rdst,  it.cop0src, 11'b0           }; 
      tagged MTC0  .it : return { opRS,    rsMTC0,   it.rsrc,  it.cop0dst, 11'b0           };  
 -----/\----- EXCLUDED -----/\----- */

    endcase

  endfunction

  // Unpack Function

  function Instr unpack( Bit#(32) instrBits );

    let opcode = instrBits[ 31 : 26 ];
    let rs     = instrBits[ 25 : 21 ];
    let rt     = instrBits[ 20 : 16 ];
    let rd     = instrBits[ 15 : 11 ];
    let shamt  = instrBits[ 10 :  6 ];
    let funct  = instrBits[  5 :  0 ];
    let imm    = instrBits[ 15 :  0 ];
    let target = instrBits[ 25 :  0 ];
    let targetProc = instrBits[ 3 : 0 ];

    case ( opcode )

      opLW        : return LW    { rbase:rs, rdst:rt,  offset:imm  };
      opSW        : return SW    { rbase:rs, rsrc:rt,  offset:imm  };
/* -----\/----- EXCLUDED -----\/-----
      opADDIU     : return ADDIU { rsrc:rs,  rdst:rt,  imm:imm     };
      opSLTI      : return SLTI  { rsrc:rs,  rdst:rt,  imm:imm     };
      opSLTIU     : return SLTIU { rsrc:rs,  rdst:rt,  imm:imm     };
      opANDI      : return ANDI  { rsrc:rs,  rdst:rt,  imm:imm     };
      opORI       : return ORI   { rsrc:rs,  rdst:rt,  imm:imm     };
      opXORI      : return XORI  { rsrc:rs,  rdst:rt,  imm:imm     };
      opLUI       : return LUI   {           rdst:rt,  imm:imm     };
      opJ         : return J     { target:target                   };
      opJAL       : return JAL   { target:target                   };
      opBEQ       : return BEQ   { rsrc1:rs, rsrc2:rt, offset:imm  };
      opBNE       : return BNE   { rsrc1:rs, rsrc2:rt, offset:imm  };
      opBLEZ      : return BLEZ  { rsrc:rs,  offset:imm            };
      opBGTZ      : return BGTZ  { rsrc:rs,  offset:imm            };
 -----/\----- EXCLUDED -----/\----- */

      opFUNC  : 
        case ( funct )
	  fcADD    :  return ADD   { rsrc1:rs,  rsrc2:rt,  rdst:rd   };
	  fcSUB    :  return SUB   { rsrc1:rs,  rsrc2:rt,  rdst:rd   };
	  fcMULT   :  return MULT   { rsrc1:rs,  rsrc2:rt,  rdst:rd   };
	  fcHALT   :  return HALT ;
/* -----\/----- EXCLUDED -----\/-----
          fcSLL   : return SLL   { rsrc:rt,  rdst:rd,  shamt:shamt };
          fcSRL   : return SRL   { rsrc:rt,  rdst:rd,  shamt:shamt };
          fcSRA   : return SRA   { rsrc:rt,  rdst:rd,  shamt:shamt };
          fcSLLV  : return SLLV  { rsrc:rt,  rdst:rd,  rshamt:rs   };
          fcSRLV  : return SRLV  { rsrc:rt,  rdst:rd,  rshamt:rs   };
          fcSRAV  : return SRAV  { rsrc:rt,  rdst:rd,  rshamt:rs   };
          fcADDU  : return ADDU  { rsrc1:rs, rsrc2:rt, rdst:rd     };
          fcSUBU  : return SUBU  { rsrc1:rs, rsrc2:rt, rdst:rd     };
          fcAND   : return AND   { rsrc1:rs, rsrc2:rt, rdst:rd     };
          fcOR    : return OR    { rsrc1:rs, rsrc2:rt, rdst:rd     };
          fcXOR   : return XOR   { rsrc1:rs, rsrc2:rt, rdst:rd     };
          fcNOR   : return NOR   { rsrc1:rs, rsrc2:rt, rdst:rd     };
          fcSLT   : return SLT   { rsrc1:rs, rsrc2:rt, rdst:rd     }; 
          fcSLTU  : return SLTU  { rsrc1:rs, rsrc2:rt, rdst:rd     };
	  fcMFHI  : return MFHI  { rdst:rd                         };
	  fcMFLO  : return MFLO  { rdst:rd                         };
	  fcMULT  : return MULT  { rsrc1:rs, rsrc2:rt              };
          fcJR    : return JR    { rsrc:rs                         };
          fcJALR  : return JALR  { rsrc:rs,  rdst:rd               };
 -----/\----- EXCLUDED -----/\----- */
          default : return ILLEGAL;
        endcase

/* -----\/----- EXCLUDED -----\/-----
      opRT : 
        case ( rt )
          rtBLTZ  : return BLTZ  { rsrc:rs,  offset:imm            };
          rtBGEZ  : return BGEZ  { rsrc:rs,  offset:imm            };
          default : return ILLEGAL;
        endcase

      opRS : 
        case ( rs )
          rsMFC0  : return MFC0  { rdst:rt,  cop0src:rd            };
          rsMTC0  : return MTC0  { rsrc:rt,  cop0dst:rd            };
          default : return ILLEGAL;
        endcase
 -----/\----- EXCLUDED -----/\----- */
      
      opFIFO_WRITE : return FIFO_WRITE { rsrc:rs, destProc:targetProc };   
      opFIFO_READ  : return FIFO_READ  { rdst:rs, srcProc:targetProc  };
      opFIFO_WRITE_BROADCAST : return FIFO_WRITE_BROADCAST { rsrc:rs};   
      opFIFO_READ_BROADCAST  : return FIFO_READ_BROADCAST  { rdst:rs};

      default      : return ILLEGAL;
      
    endcase

  endfunction

endinstance


