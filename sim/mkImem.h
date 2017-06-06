/*
 * Generated by Bluespec Compiler, version 2014.05.C (build 33930, 2014-05-28)
 * 
 * On Tue Jun  6 22:50:48 IST 2017
 * 
 */

/* Generation options: keep-fires */
#ifndef __mkImem_h__
#define __mkImem_h__

#include "bluesim_types.h"
#include "bs_module.h"
#include "bluesim_primitives.h"
#include "bs_vcd.h"


/* Class declaration for the mkImem module */
class MOD_mkImem : public Module {
 
 /* Clock handles */
 private:
  tClock __clk_handle_0;
 
 /* Clock gate handles */
 public:
  tUInt8 *clk_gate[0];
 
 /* Instantiation parameters */
 public:
  tUInt8 const PARAM_procId;
 
 /* Module state */
 public:
  MOD_Fifo<tUInt8> INST_instReqQ;
  MOD_Fifo<tUInt64> INST_instRespQ;
  MOD_RegFile<tUInt8,tUInt32> INST_mem;
 
 /* Constructor */
 public:
  MOD_mkImem(tSimStateHdl simHdl, char const *name, Module *parent, tUInt8 ARG_procId);
 
 /* Symbol init methods */
 private:
  void init_symbols_0();
 
 /* Reset signal definitions */
 private:
  tUInt8 PORT_RST_N;
 
 /* Port definitions */
 public:
  tUInt8 PORT_EN_imem_server_request_put;
  tUInt8 PORT_EN_imem_server_response_get;
  tUInt8 PORT_imem_server_request_put;
  tUInt8 PORT_RDY_imem_server_request_put;
  tUInt64 PORT_imem_server_response_get;
  tUInt8 PORT_RDY_imem_server_response_get;
 
 /* Publicly accessible definitions */
 public:
  tUInt8 DEF_WILL_FIRE_RL_access;
  tUInt8 DEF_CAN_FIRE_RL_access;
  tUInt8 DEF_WILL_FIRE_imem_server_response_get;
  tUInt8 DEF_WILL_FIRE_imem_server_request_put;
  tUInt8 DEF_CAN_FIRE_imem_server_response_get;
  tUInt8 DEF_CAN_FIRE_imem_server_request_put;
 
 /* Local definitions */
 private:
 
 /* Rules */
 public:
  void RL_access();
 
 /* Methods */
 public:
  void METH_imem_server_request_put(tUInt8 ARG_imem_server_request_put);
  tUInt8 METH_RDY_imem_server_request_put();
  tUInt64 METH_imem_server_response_get();
  tUInt8 METH_RDY_imem_server_response_get();
 
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
  void dump_VCD(tVCDDumpType dt, unsigned int levels, MOD_mkImem &backing);
  void vcd_defs(tVCDDumpType dt, MOD_mkImem &backing);
  void vcd_prims(tVCDDumpType dt, MOD_mkImem &backing);
};

#endif /* ifndef __mkImem_h__ */
