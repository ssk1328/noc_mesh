
//Number of Nodes
typedef 7 NumNodes;

function ProcID lookupProcID(NoCAddress currNocAddr);
  return zeroExtend(currNocAddr.rowAddr)*3 + zeroExtend(currNocAddr.colAddr);
endfunction

function String toString(ProcID procId); 
  String res = ""; 
  case (procId) matches
    0 : return "0";
    1 : return "1";
    2 : return "2";
    3 : return "3";
    4 : return "4";
    5 : return "5";
    6 : return "6";   
    default : return "";
  endcase
endfunction 

function String getNoCPacketDir(NoCPacketDirection dir); 
  String res = ""; 
  case (dir) matches
    tagged Point2Line .direc  : return "Point2Line";
    tagged Line2Point .direc  : return "Line2Point";
    default : return "";
  endcase
endfunction 
