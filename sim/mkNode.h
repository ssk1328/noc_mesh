/*
 * Generated by Bluespec Compiler, version 2014.05.C (build 33930, 2014-05-28)
 * 
 * On Thu Jun 22 16:22:40 IST 2017
 * 
 */

/* Generation options: keep-fires */
#ifndef __mkNode_h__
#define __mkNode_h__

#include "bluesim_types.h"
#include "bs_module.h"
#include "bluesim_primitives.h"
#include "bs_vcd.h"


/* Class declaration for the mkNode module */
class MOD_mkNode : public Module {
 
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
  MOD_Wire<tUInt8> INST_channelInQ_0_dequeueing;
  MOD_Wire<tUInt64> INST_channelInQ_0_enqw;
  MOD_Fifo<tUInt64> INST_channelInQ_0_ff;
  MOD_Reg<tUInt8> INST_channelInQ_0_firstValid;
  MOD_Wire<tUInt8> INST_channelInQ_1_dequeueing;
  MOD_Wire<tUInt64> INST_channelInQ_1_enqw;
  MOD_Fifo<tUInt64> INST_channelInQ_1_ff;
  MOD_Reg<tUInt8> INST_channelInQ_1_firstValid;
  MOD_Wire<tUInt8> INST_channelInQ_2_dequeueing;
  MOD_Wire<tUInt64> INST_channelInQ_2_enqw;
  MOD_Fifo<tUInt64> INST_channelInQ_2_ff;
  MOD_Reg<tUInt8> INST_channelInQ_2_firstValid;
  MOD_Wire<tUInt8> INST_channelInQ_3_dequeueing;
  MOD_Wire<tUInt64> INST_channelInQ_3_enqw;
  MOD_Fifo<tUInt64> INST_channelInQ_3_ff;
  MOD_Reg<tUInt8> INST_channelInQ_3_firstValid;
  MOD_Wire<tUInt8> INST_channelInQ_4_dequeueing;
  MOD_Wire<tUInt64> INST_channelInQ_4_enqw;
  MOD_Fifo<tUInt64> INST_channelInQ_4_ff;
  MOD_Reg<tUInt8> INST_channelInQ_4_firstValid;
  MOD_CReg<tUInt64> INST_channelOutQ_0_rv;
  MOD_CReg<tUInt64> INST_channelOutQ_1_rv;
  MOD_CReg<tUInt64> INST_channelOutQ_2_rv;
  MOD_CReg<tUInt64> INST_channelOutQ_3_rv;
  MOD_CReg<tUInt64> INST_channelOutQ_4_rv;
  MOD_Wire<tUInt8> INST_inputChannelArbiter_grant_id_wire;
  MOD_Wire<tUInt8> INST_inputChannelArbiter_grant_vector;
  MOD_Reg<tUInt8> INST_inputChannelArbiter_priority_vector;
  MOD_Wire<tUInt8> INST_inputChannelArbiter_request_vector_0;
  MOD_Wire<tUInt8> INST_inputChannelArbiter_request_vector_1;
  MOD_Wire<tUInt8> INST_inputChannelArbiter_request_vector_2;
  MOD_Wire<tUInt8> INST_inputChannelArbiter_request_vector_3;
  MOD_Wire<tUInt8> INST_inputChannelArbiter_request_vector_4;
  MOD_Wire<tUInt8> INST_outputChannelArbiter_grant_id_wire;
  MOD_Wire<tUInt8> INST_outputChannelArbiter_grant_vector;
  MOD_Reg<tUInt8> INST_outputChannelArbiter_priority_vector;
  MOD_Wire<tUInt8> INST_outputChannelArbiter_request_vector_0;
  MOD_Wire<tUInt8> INST_outputChannelArbiter_request_vector_1;
  MOD_Wire<tUInt8> INST_outputChannelArbiter_request_vector_2;
  MOD_Wire<tUInt8> INST_outputChannelArbiter_request_vector_3;
  MOD_Wire<tUInt8> INST_outputChannelArbiter_request_vector_4;
  MOD_Fifo<tUInt64> INST_routePacketQ;
 
 /* Constructor */
 public:
  MOD_mkNode(tSimStateHdl simHdl,
	     char const *name,
	     Module *parent,
	     tUInt8 ARG_thisRowAddr,
	     tUInt8 ARG_thisColAddr);
 
 /* Symbol init methods */
 private:
  void init_symbols_0();
 
 /* Reset signal definitions */
 private:
  tUInt8 PORT_RST_N;
 
 /* Port definitions */
 public:
  tUInt8 PORT_thisRowAddr;
  tUInt8 PORT_thisColAddr;
  tUInt8 PORT_EN_channels_0_putNoCPacket_put;
  tUInt8 PORT_EN_channels_0_getNoCPacket_get;
  tUInt8 PORT_EN_channels_1_putNoCPacket_put;
  tUInt8 PORT_EN_channels_1_getNoCPacket_get;
  tUInt8 PORT_EN_channels_2_putNoCPacket_put;
  tUInt8 PORT_EN_channels_2_getNoCPacket_get;
  tUInt8 PORT_EN_channels_3_putNoCPacket_put;
  tUInt8 PORT_EN_channels_3_getNoCPacket_get;
  tUInt8 PORT_EN_channels_4_putNoCPacket_put;
  tUInt8 PORT_EN_channels_4_getNoCPacket_get;
  tUInt64 PORT_channels_0_putNoCPacket_put;
  tUInt64 PORT_channels_1_putNoCPacket_put;
  tUInt64 PORT_channels_2_putNoCPacket_put;
  tUInt64 PORT_channels_3_putNoCPacket_put;
  tUInt64 PORT_channels_4_putNoCPacket_put;
  tUInt8 PORT_RDY_channels_0_putNoCPacket_put;
  tUInt64 PORT_channels_0_getNoCPacket_get;
  tUInt8 PORT_RDY_channels_0_getNoCPacket_get;
  tUInt8 PORT_RDY_channels_1_putNoCPacket_put;
  tUInt64 PORT_channels_1_getNoCPacket_get;
  tUInt8 PORT_RDY_channels_1_getNoCPacket_get;
  tUInt8 PORT_RDY_channels_2_putNoCPacket_put;
  tUInt64 PORT_channels_2_getNoCPacket_get;
  tUInt8 PORT_RDY_channels_2_getNoCPacket_get;
  tUInt8 PORT_RDY_channels_3_putNoCPacket_put;
  tUInt64 PORT_channels_3_getNoCPacket_get;
  tUInt8 PORT_RDY_channels_3_getNoCPacket_get;
  tUInt8 PORT_RDY_channels_4_putNoCPacket_put;
  tUInt64 PORT_channels_4_getNoCPacket_get;
  tUInt8 PORT_RDY_channels_4_getNoCPacket_get;
 
 /* Publicly accessible definitions */
 public:
  tUInt8 DEF_WILL_FIRE_channels_4_getNoCPacket_get;
  tUInt8 DEF_WILL_FIRE_channels_4_putNoCPacket_put;
  tUInt8 DEF_WILL_FIRE_channels_3_getNoCPacket_get;
  tUInt8 DEF_WILL_FIRE_channels_3_putNoCPacket_put;
  tUInt8 DEF_WILL_FIRE_channels_2_getNoCPacket_get;
  tUInt8 DEF_WILL_FIRE_channels_2_putNoCPacket_put;
  tUInt8 DEF_WILL_FIRE_channels_1_getNoCPacket_get;
  tUInt8 DEF_WILL_FIRE_channels_1_putNoCPacket_put;
  tUInt8 DEF_WILL_FIRE_channels_0_getNoCPacket_get;
  tUInt8 DEF_WILL_FIRE_channels_0_putNoCPacket_put;
  tUInt8 DEF_WILL_FIRE___me_check_21;
  tUInt8 DEF_CAN_FIRE___me_check_21;
  tUInt8 DEF_WILL_FIRE___me_check_20;
  tUInt8 DEF_CAN_FIRE___me_check_20;
  tUInt8 DEF_WILL_FIRE___me_check_19;
  tUInt8 DEF_CAN_FIRE___me_check_19;
  tUInt8 DEF_WILL_FIRE___me_check_18;
  tUInt8 DEF_CAN_FIRE___me_check_18;
  tUInt8 DEF_WILL_FIRE___me_check_13;
  tUInt8 DEF_CAN_FIRE___me_check_13;
  tUInt8 DEF_WILL_FIRE_RL_routePacketHome;
  tUInt8 DEF_CAN_FIRE_RL_routePacketHome;
  tUInt8 DEF_WILL_FIRE_RL_routePacketEast;
  tUInt8 DEF_CAN_FIRE_RL_routePacketEast;
  tUInt8 DEF_WILL_FIRE_RL_routePacketWest;
  tUInt8 DEF_CAN_FIRE_RL_routePacketWest;
  tUInt8 DEF_WILL_FIRE_RL_routePacketSouth;
  tUInt8 DEF_CAN_FIRE_RL_routePacketSouth;
  tUInt8 DEF_WILL_FIRE_RL_routePacketNorth;
  tUInt8 DEF_CAN_FIRE_RL_routePacketNorth;
  tUInt8 DEF_WILL_FIRE_RL_inputArbitratei_4;
  tUInt8 DEF_CAN_FIRE_RL_inputArbitratei_4;
  tUInt8 DEF_WILL_FIRE_RL_inputArbitratei_3;
  tUInt8 DEF_CAN_FIRE_RL_inputArbitratei_3;
  tUInt8 DEF_WILL_FIRE_RL_inputArbitratei_2;
  tUInt8 DEF_CAN_FIRE_RL_inputArbitratei_2;
  tUInt8 DEF_WILL_FIRE_RL_inputArbitratei_1;
  tUInt8 DEF_CAN_FIRE_RL_inputArbitratei_1;
  tUInt8 DEF_WILL_FIRE_RL_inputArbitratei;
  tUInt8 DEF_CAN_FIRE_RL_inputArbitratei;
  tUInt8 DEF_WILL_FIRE_RL_inputChannelArbiterRequest;
  tUInt8 DEF_CAN_FIRE_RL_inputChannelArbiterRequest;
  tUInt8 DEF_WILL_FIRE_RL_outputChannelArbiter_every;
  tUInt8 DEF_CAN_FIRE_RL_outputChannelArbiter_every;
  tUInt8 DEF_WILL_FIRE_RL_inputChannelArbiter_every;
  tUInt8 DEF_CAN_FIRE_RL_inputChannelArbiter_every;
  tUInt8 DEF_WILL_FIRE_RL_channelInQ_4_dequeue;
  tUInt8 DEF_CAN_FIRE_RL_channelInQ_4_dequeue;
  tUInt8 DEF_WILL_FIRE_RL_channelInQ_4_enqueue;
  tUInt8 DEF_CAN_FIRE_RL_channelInQ_4_enqueue;
  tUInt8 DEF_WILL_FIRE_RL_channelInQ_3_dequeue;
  tUInt8 DEF_CAN_FIRE_RL_channelInQ_3_dequeue;
  tUInt8 DEF_WILL_FIRE_RL_channelInQ_3_enqueue;
  tUInt8 DEF_CAN_FIRE_RL_channelInQ_3_enqueue;
  tUInt8 DEF_WILL_FIRE_RL_channelInQ_2_dequeue;
  tUInt8 DEF_CAN_FIRE_RL_channelInQ_2_dequeue;
  tUInt8 DEF_WILL_FIRE_RL_channelInQ_2_enqueue;
  tUInt8 DEF_CAN_FIRE_RL_channelInQ_2_enqueue;
  tUInt8 DEF_WILL_FIRE_RL_channelInQ_1_dequeue;
  tUInt8 DEF_CAN_FIRE_RL_channelInQ_1_dequeue;
  tUInt8 DEF_WILL_FIRE_RL_channelInQ_1_enqueue;
  tUInt8 DEF_CAN_FIRE_RL_channelInQ_1_enqueue;
  tUInt8 DEF_WILL_FIRE_RL_channelInQ_0_dequeue;
  tUInt8 DEF_CAN_FIRE_RL_channelInQ_0_dequeue;
  tUInt8 DEF_WILL_FIRE_RL_channelInQ_0_enqueue;
  tUInt8 DEF_CAN_FIRE_RL_channelInQ_0_enqueue;
  tUInt8 DEF_CAN_FIRE_channels_4_getNoCPacket_get;
  tUInt64 DEF_channelOutQ_4_rv_port1__read____d696;
  tUInt8 DEF_CAN_FIRE_channels_4_putNoCPacket_put;
  tUInt8 DEF_CAN_FIRE_channels_3_getNoCPacket_get;
  tUInt64 DEF_channelOutQ_3_rv_port1__read____d695;
  tUInt8 DEF_CAN_FIRE_channels_3_putNoCPacket_put;
  tUInt8 DEF_CAN_FIRE_channels_2_getNoCPacket_get;
  tUInt64 DEF_channelOutQ_2_rv_port1__read____d694;
  tUInt8 DEF_CAN_FIRE_channels_2_putNoCPacket_put;
  tUInt8 DEF_CAN_FIRE_channels_1_getNoCPacket_get;
  tUInt64 DEF_channelOutQ_1_rv_port1__read____d693;
  tUInt8 DEF_CAN_FIRE_channels_1_putNoCPacket_put;
  tUInt8 DEF_CAN_FIRE_channels_0_getNoCPacket_get;
  tUInt64 DEF_channelOutQ_0_rv_port1__read____d692;
  tUInt8 DEF_CAN_FIRE_channels_0_putNoCPacket_put;
  tUInt64 DEF_routePacketQ_first____d329;
  tUInt8 DEF_channelInQ_4_enqw_whas____d33;
  tUInt8 DEF_channelInQ_4_ff_i_notEmpty____d36;
  tUInt8 DEF_channelInQ_3_enqw_whas____d25;
  tUInt8 DEF_channelInQ_3_ff_i_notEmpty____d28;
  tUInt8 DEF_channelInQ_2_enqw_whas____d17;
  tUInt8 DEF_channelInQ_2_ff_i_notEmpty____d20;
  tUInt8 DEF_channelInQ_1_enqw_whas____d9;
  tUInt8 DEF_channelInQ_1_ff_i_notEmpty____d12;
  tUInt8 DEF_channelInQ_0_enqw_whas____d1;
  tUInt8 DEF_channelInQ_0_ff_i_notEmpty____d4;
  tUInt8 DEF_routePacketQ_first__29_BITS_46_TO_41___d330;
 
 /* Local definitions */
 private:
  tUInt64 DEF_channelInQ_4_enqw_wget____d39;
  tUInt64 DEF_channelInQ_3_enqw_wget____d31;
  tUInt64 DEF_channelInQ_2_enqw_wget____d23;
  tUInt64 DEF_channelInQ_1_enqw_wget____d15;
  tUInt64 DEF_channelInQ_0_enqw_wget____d7;
  tUInt8 DEF_routePacketQ_first__29_BITS_40_TO_37___d476;
  tUInt8 DEF_routePacketQ_first__29_BITS_36_TO_33___d477;
  tUInt8 DEF_routePacketQ_first__29_BITS_28_TO_25___d478;
  tUInt64 DEF__1_CONCAT_routePacketQ_first__29___d475;
  tUInt64 DEF__0_CONCAT_DONTCARE___d691;
 
 /* Rules */
 public:
  void RL_channelInQ_0_enqueue();
  void RL_channelInQ_0_dequeue();
  void RL_channelInQ_1_enqueue();
  void RL_channelInQ_1_dequeue();
  void RL_channelInQ_2_enqueue();
  void RL_channelInQ_2_dequeue();
  void RL_channelInQ_3_enqueue();
  void RL_channelInQ_3_dequeue();
  void RL_channelInQ_4_enqueue();
  void RL_channelInQ_4_dequeue();
  void RL_inputChannelArbiter_every();
  void RL_outputChannelArbiter_every();
  void RL_inputChannelArbiterRequest();
  void RL_inputArbitratei();
  void RL_inputArbitratei_1();
  void RL_inputArbitratei_2();
  void RL_inputArbitratei_3();
  void RL_inputArbitratei_4();
  void RL_routePacketNorth();
  void RL_routePacketSouth();
  void RL_routePacketWest();
  void RL_routePacketEast();
  void RL_routePacketHome();
  void __me_check_13();
  void __me_check_18();
  void __me_check_19();
  void __me_check_20();
  void __me_check_21();
 
 /* Methods */
 public:
  void METH_channels_0_putNoCPacket_put(tUInt64 ARG_channels_0_putNoCPacket_put);
  tUInt8 METH_RDY_channels_0_putNoCPacket_put();
  tUInt64 METH_channels_0_getNoCPacket_get();
  tUInt8 METH_RDY_channels_0_getNoCPacket_get();
  void METH_channels_1_putNoCPacket_put(tUInt64 ARG_channels_1_putNoCPacket_put);
  tUInt8 METH_RDY_channels_1_putNoCPacket_put();
  tUInt64 METH_channels_1_getNoCPacket_get();
  tUInt8 METH_RDY_channels_1_getNoCPacket_get();
  void METH_channels_2_putNoCPacket_put(tUInt64 ARG_channels_2_putNoCPacket_put);
  tUInt8 METH_RDY_channels_2_putNoCPacket_put();
  tUInt64 METH_channels_2_getNoCPacket_get();
  tUInt8 METH_RDY_channels_2_getNoCPacket_get();
  void METH_channels_3_putNoCPacket_put(tUInt64 ARG_channels_3_putNoCPacket_put);
  tUInt8 METH_RDY_channels_3_putNoCPacket_put();
  tUInt64 METH_channels_3_getNoCPacket_get();
  tUInt8 METH_RDY_channels_3_getNoCPacket_get();
  void METH_channels_4_putNoCPacket_put(tUInt64 ARG_channels_4_putNoCPacket_put);
  tUInt8 METH_RDY_channels_4_putNoCPacket_put();
  tUInt64 METH_channels_4_getNoCPacket_get();
  tUInt8 METH_RDY_channels_4_getNoCPacket_get();
 
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
  void dump_VCD(tVCDDumpType dt, unsigned int levels, MOD_mkNode &backing);
  void vcd_defs(tVCDDumpType dt, MOD_mkNode &backing);
  void vcd_prims(tVCDDumpType dt, MOD_mkNode &backing);
};

#endif /* ifndef __mkNode_h__ */
