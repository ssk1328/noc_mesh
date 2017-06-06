/*
 * Generated by Bluespec Compiler, version 2014.05.C (build 33930, 2014-05-28)
 * 
 * On Tue Jun  6 22:50:48 IST 2017
 * 
 */

/* Generation options: keep-fires */
#ifndef __mkNetConnect_h__
#define __mkNetConnect_h__

#include "bluesim_types.h"
#include "bs_module.h"
#include "bluesim_primitives.h"
#include "bs_vcd.h"


/* Class declaration for the mkNetConnect module */
class MOD_mkNetConnect : public Module {
 
 /* Clock handles */
 private:
  tClock __clk_handle_0;
 
 /* Clock gate handles */
 public:
  tUInt8 *clk_gate[0];
 
 /* Instantiation parameters */
 public:
 
 /* Module state */
 public:
  MOD_CReg<tUInt64> INST_dataPacketInQ_rv;
  MOD_CReg<tUInt64> INST_dataPacketOutQ_rv;
  MOD_CReg<tUInt64> INST_nocPacketInQ_rv;
  MOD_CReg<tUInt64> INST_nocPacketOutQ_rv;
 
 /* Constructor */
 public:
  MOD_mkNetConnect(tSimStateHdl simHdl, char const *name, Module *parent);
 
 /* Symbol init methods */
 private:
  void init_symbols_0();
 
 /* Reset signal definitions */
 private:
  tUInt8 PORT_RST_N;
 
 /* Port definitions */
 public:
  tUInt8 PORT_EN_putNoCPacket_put;
  tUInt8 PORT_EN_getNoCPacket_get;
  tUInt8 PORT_EN_putDataPacket_put;
  tUInt8 PORT_EN_getDataPacket_get;
  tUInt64 PORT_putNoCPacket_put;
  tUInt64 PORT_putDataPacket_put;
  tUInt8 PORT_RDY_putNoCPacket_put;
  tUInt64 PORT_getNoCPacket_get;
  tUInt8 PORT_RDY_getNoCPacket_get;
  tUInt8 PORT_RDY_putDataPacket_put;
  tUInt64 PORT_getDataPacket_get;
  tUInt8 PORT_RDY_getDataPacket_get;
 
 /* Publicly accessible definitions */
 public:
  tUInt8 DEF_WILL_FIRE_getNoCPacket_get;
  tUInt8 DEF_WILL_FIRE_putNoCPacket_put;
  tUInt8 DEF_CAN_FIRE_getNoCPacket_get;
  tUInt8 DEF_CAN_FIRE_putNoCPacket_put;
  tUInt8 DEF_WILL_FIRE_getDataPacket_get;
  tUInt8 DEF_WILL_FIRE_putDataPacket_put;
  tUInt8 DEF_CAN_FIRE_getDataPacket_get;
  tUInt8 DEF_CAN_FIRE_putDataPacket_put;
  tUInt8 DEF_WILL_FIRE_RL_removeLayer;
  tUInt8 DEF_CAN_FIRE_RL_removeLayer;
  tUInt8 DEF_WILL_FIRE_RL_addLayer;
  tUInt8 DEF_CAN_FIRE_RL_addLayer;
  tUInt64 DEF_nocPacketOutQ_rv_port1__read____d71;
  tUInt64 DEF_dataPacketOutQ_rv_port1__read____d67;
  tUInt64 DEF_nocPacketInQ_rv_port1__read____d55;
  tUInt64 DEF_dataPacketInQ_rv_port1__read____d1;
 
 /* Local definitions */
 private:
  tUInt64 DEF__0_CONCAT_DONTCARE___d61;
  tUInt64 DEF__0_CONCAT_DONTCARE___d7;
 
 /* Rules */
 public:
  void RL_addLayer();
  void RL_removeLayer();
 
 /* Methods */
 public:
  void METH_putDataPacket_put(tUInt64 ARG_putDataPacket_put);
  tUInt8 METH_RDY_putDataPacket_put();
  tUInt64 METH_getDataPacket_get();
  tUInt8 METH_RDY_getDataPacket_get();
  void METH_putNoCPacket_put(tUInt64 ARG_putNoCPacket_put);
  tUInt8 METH_RDY_putNoCPacket_put();
  tUInt64 METH_getNoCPacket_get();
  tUInt8 METH_RDY_getNoCPacket_get();
 
 /* Reset routines */
 public:
  void reset_RST_N(tUInt8 ARG_rst_in);
 
 /* Static handles to reset routines */
 public:
 
 /* Pointers to reset fns in parent module for asserting output resets */
 private:
 
 /* Functions for the parent module to register its reset fns */
 public:
 
 /* Functions to set the elaborated clock id */
 public:
  void set_clk_0(char const *s);
 
 /* State dumping routine */
 public:
  void dump_state(unsigned int indent);
 
 /* VCD dumping routines */
 public:
  unsigned int dump_VCD_defs(unsigned int levels);
  void dump_VCD(tVCDDumpType dt, unsigned int levels, MOD_mkNetConnect &backing);
  void vcd_defs(tVCDDumpType dt, MOD_mkNetConnect &backing);
  void vcd_prims(tVCDDumpType dt, MOD_mkNetConnect &backing);
};

#endif /* ifndef __mkNetConnect_h__ */
