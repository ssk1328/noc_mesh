

import ProcTypes::*;
//----------------------------------------------------------------------
// Basic memory requests and responses
//----------------------------------------------------------------------

typedef union tagged
{
    struct { Bit#(addrSz) addr;Bit#(tagSz) tag;                   } LoadReq;
    struct { Bit#(addrSz) addr;Bit#(dataSz) data;} StoreReq;  
}
MemReq#( type addrSz, type dataSz, type tagSz ) 
deriving(Eq,Bits);

typedef union tagged
{
    struct {Bit#(addrSz) addr; Bit#(dataSz) data; Bit#(tagSz) tag;} LoadResp;
    struct {Bit#(addrSz) addr;}                                     StoreResp;
}
MemResp#( type addrSz, type dataSz, type tagSz  )
deriving(Eq,Bits);

//----------------------------------------------------------------------
// Specialized req/resp for inst/data/host
//----------------------------------------------------------------------

typedef MemReq#(AddrSz,0,0)                 InstReq;
typedef MemResp#(AddrSz,InstSz,0)           InstResp;

typedef MemReq#(AddrSz,DataSz,5)            DataReq;
typedef MemResp#(AddrSz,DataSz,5)           DataResp;

/* -----\/----- EXCLUDED -----\/-----
typedef MemReq#(AddrSz,TagSz,HostDataSz) HostReq;
typedef MemResp#(TagSz,HostDataSz)       HostResp;
 -----/\----- EXCLUDED -----/\----- */

//----------------------------------------------------------------------
// Sizes for Data Memory and Instruction Memory
//----------------------------------------------------------------------

typedef 6  DataMemBitSz ;
typedef 6  InstMemBitSz ;

typedef struct { 

   ProcID src; 
   ProcID dest; 
   Bit#(DataSz) data;
   Bool isBroadcast; 
} DataPacket deriving(Eq,Bits);


typedef Bit#(2) NoCAddr2D;

typedef struct { NoCAddr2D rowAddr; NoCAddr2D colAddr; } NoCAddress deriving (Eq,Bits);

typedef enum{ P2P, Broadcast } NoCPacketType deriving(Eq,Bits); //Used to determine whether the pacekt is point to point or broadcast

typedef enum{ Point2Line, Line2Point } NoCPacketDirection deriving(Eq,Bits); //Used to determine whether the packet is going from Point to Line or Line to Point

typedef struct {
  NoCAddress src;
  NoCAddress dest; 
  DataPacket payload;
  NoCPacketType nocPacketType;
  NoCPacketDirection nocPacketDirection; 
} NoCPacket deriving(Eq, Bits);


//art from here
//----------------------------------------------------------------------
// Specialized req/resp for main memory
//----------------------------------------------------------------------

/* -----\/----- EXCLUDED -----\/-----
typedef 32 MainMemAddrSz;
typedef 0 MainMemTagSz;
typedef 32 MainMemDataSz;

typedef MemReq#(MainMemAddrSz,MainMemTagSz,MainMemDataSz) MainMemReq;
typedef MemResp#(MainMemTagSz,MainMemDataSz)              MainMemResp;
 -----/\----- EXCLUDED -----/\----- */

//---------------------------------------------------------------------
// Helper functions 
//---------------------------------------------------------------------
/* -----\/----- EXCLUDED -----\/-----
function String getStateMSI(TagState givenState);
  case (givenState) 
    M: return "M";
    S: return "S";
    I: return "I";
    P: return "P";
  endcase
endfunction
 -----/\----- EXCLUDED -----/\----- */
  

//----------------------------------------------------------------------
// Tracing Functions
//----------------------------------------------------------------------

/* -----\/----- EXCLUDED -----\/-----
instance Traceable#(MemReq#(a,b,c));

    function Action traceTiny( String loc, String ttag, MemReq#(a,b,c) req );
        case ( req ) matches
            tagged LoadReq  .ld : $fdisplay(stderr,  " => %s:%s l%2x", loc, ttag, ld.tag );
            tagged StoreReq .st : $fdisplay(stderr,  " => %s:%s s%2x", loc, ttag, st.tag );
        endcase
    endfunction

    function Action traceFull( String loc, String ttag, MemReq#(a,b,c) req );
        case ( req ) matches
            tagged LoadReq  .ld : $fdisplay(stderr,  " => %s:%s Ld { addr=%x, tag=%x }",  loc, ttag, ld.addr, ld.tag );
            tagged StoreReq .st : $fdisplay(stderr,  " => %s:%s St { addr=%x, tag=%x, data=%x }", loc, ttag, st.addr, st.tag, st.data );
        endcase
    endfunction

endinstance

instance Traceable#(MemResp#(a,b));

    function Action traceTiny( String loc, String ttag, MemResp#(a,b) resp );
        case ( resp ) matches
            tagged LoadResp  .ld : $fdisplay(stderr,  " => %s:%s l%2x", loc, ttag, ld.tag );
            tagged StoreResp .st : $fdisplay(stderr,  " => %s:%s s%2x", loc, ttag, st.tag );
        endcase
    endfunction

    function Action traceFull( String loc, String ttag, MemResp#(a,b) resp );
        case ( resp ) matches
            tagged LoadResp  .ld : $fdisplay(stderr,  " => %s:%s Ld { tag=%x, data=%x }",  loc, ttag, ld.tag, ld.data );
            tagged StoreResp .st : $fdisplay(stderr,  " => %s:%s St { tag=%x  }", loc, ttag, st.tag );
        endcase
    endfunction

endinstance

 -----/\----- EXCLUDED -----/\----- */
