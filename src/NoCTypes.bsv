// Network Connectivity Information
import Def::*;
import GetPut::*;
import MemTypes::*;

typedef 9 TotalNodes;
typedef 3 MeshSize;
typedef 5 Degree;
typedef 3 PGDegree;

Integer incidence[3] = {
  0, 1, 3
};


interface MeshDirection;
  interface Put#(NoCPacket) putNoCPacket;
  interface Get#(NoCPacket) getNoCPacket;
endinterface
  
