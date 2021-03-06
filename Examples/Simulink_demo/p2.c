// ************************************************************************
// * File generated by Simulink C Parser
// ************************************************************************
#include "software_configuration.h"

// *** DEFINE YOUR CUSTOM INCLUDE FILES BELOW THIS LINE
#include <stdio.h>
#include <stddef.h>
#include <string.h>
// *** DEFINE YOUR CUSTOM INCLUDE FILES ABOVE THIS LINE

// *****************************************************************************************************************************************
// *
// * Define dynamic process meta_information
// *
// * Channel priority
// * Length of message in words, excluding the 40-bit heartbeat clock (sent as 2x32 bit words)
// *****************************************************************************************************************************************
int p2_out0_priority=0;
int p2_out0_msg_len=sizeof(double)/4;
// *****************************************************************************************************************************************
// * #define Parameter Memory map to speed up execution of program
// * A parameter map is a pointer to the RNI where communication data is stored
// * A parameter map consist of a base address, a channel number, and the offset to the start of the parameter (based on previous parameters)
// *
// * Naming convention <process_name>_<direction>_<parameter_name>
// * Each transmission has a heartbeat number associated with it, counting the number of heartbeats since last reset, to make debugging easier
// *
// * Parameters defined for each Send/Recv channel:
// * <channel_type> *<channel_variable_name>
// * int <channel_variable_name>_heartbeat
// *
// *****************************************************************************************************************************************
// * Simulink specific port types
typedef struct {
      double In1;
} ExternalInputs_Filter0;
typedef struct {
      double Out1;
} ExternalOutputs_Filter0;
// *****************************************************************************************************************************************
// Map input channel recv_channel_p2_to_p1 to variable Filter0_U
volatile ExternalInputs_Filter0 *Filter0_U=(ExternalInputs_Filter0 *)NOC_PARAMETER_MAP(NOC_RNI_RECV_BASE(recv_channel_p2_from_p1),0);
volatile int *Filter0_U_heartbeat=(int *)NOC_PARAMETER_MAP(NOC_RNI_RECV_BASE(recv_channel_p2_from_p1),sizeof(ExternalInputs_Filter0)/4);
// Map output channel send_channel_p2_to_p3 to variable Filter0_Y
volatile ExternalOutputs_Filter0 *Filter0_Y=(ExternalOutputs_Filter0 *)NOC_PARAMETER_MAP(NOC_RNI_SEND_BASE(send_channel_p2_to_p3),0);

// *** DEFINE YOUR PROCESS INIT CODE BELOW THIS LINE
// *****************************************************************************************************************************************
// * 
// * Define reset, i.e., process initialization values
// *
// *****************************************************************************************************************************************
// * Simulink specific data types
typedef struct {
      double DigitalFilterLowpass_FILT_STATE[17];
} D_Work_Filter0;
typedef struct {
      double DigitalFilterLowpass_RTP1COEFF[17];
} Parameters_Filter0;
// * Global variables
D_Work_Filter0 Filter0_DWork;
Parameters_Filter0 Filter0_P={
   {
      -2.09999999999999990e-003,
      -1.08000000000000010e-002,
      -2.74000000000000010e-002,
      -4.08999999999999990e-002,
      -2.65999999999999990e-002,
      3.74000000000000030e-002,
      1.43499999999999990e-001,
      2.46500000000000000e-001,
      2.89600000000000020e-001,
      2.46500000000000000e-001,
      1.43499999999999990e-001,
      3.74000000000000030e-002,
      -2.65999999999999990e-002,
      -4.08999999999999990e-002,
      -2.74000000000000010e-002,
      -1.08000000000000010e-002,
      -2.09999999999999990e-003
   }
};
// * Simulink Inbuilt Functions
void p2_init(void)
{
   {
      Filter0_DWork.DigitalFilterLowpass_FILT_STATE[0]=0.0;
      Filter0_DWork.DigitalFilterLowpass_FILT_STATE[1]=0.0;
      Filter0_DWork.DigitalFilterLowpass_FILT_STATE[2]=0.0;
      Filter0_DWork.DigitalFilterLowpass_FILT_STATE[3]=0.0;
      Filter0_DWork.DigitalFilterLowpass_FILT_STATE[4]=0.0;
      Filter0_DWork.DigitalFilterLowpass_FILT_STATE[5]=0.0;
      Filter0_DWork.DigitalFilterLowpass_FILT_STATE[6]=0.0;
      Filter0_DWork.DigitalFilterLowpass_FILT_STATE[7]=0.0;
      Filter0_DWork.DigitalFilterLowpass_FILT_STATE[8]=0.0;
      Filter0_DWork.DigitalFilterLowpass_FILT_STATE[9]=0.0;
      Filter0_DWork.DigitalFilterLowpass_FILT_STATE[10]=0.0;
      Filter0_DWork.DigitalFilterLowpass_FILT_STATE[11]=0.0;
      Filter0_DWork.DigitalFilterLowpass_FILT_STATE[12]=0.0;
      Filter0_DWork.DigitalFilterLowpass_FILT_STATE[13]=0.0;
      Filter0_DWork.DigitalFilterLowpass_FILT_STATE[14]=0.0;
      Filter0_DWork.DigitalFilterLowpass_FILT_STATE[15]=0.0;
      Filter0_DWork.DigitalFilterLowpass_FILT_STATE[16]=0.0;
      Filter0_U->In1=0.00000000000000000e+000;
      Filter0_Y->Out1=0.00000000000000000e+000;
   }
   NOC_RNI_SEND(NOC_RNI_BASE,p2_out0_priority,p2_pid,p3_pid,send_channel_p2_to_p3,p2_out0_msg_len);
}
// *** DEFINE YOUR PROCESS INIT CODE ABOVE THIS LINE
// *** DEFINE YOUR PROCESS MAIN CODE BELOW THIS LINE
// *****************************************************************************************************************************************
// * 
// * Define the process main cycle function
// *
// *****************************************************************************************************************************************
void p2_main(void)
{
   {
      double accum;
      Filter0_Y->Out1=Filter0_U->In1*Filter0_P.DigitalFilterLowpass_RTP1COEFF[0]+Filter0_DWork.DigitalFilterLowpass_FILT_STATE[0];
      {
         accum=Filter0_DWork.DigitalFilterLowpass_FILT_STATE[1];
         accum=accum+(Filter0_U->In1*Filter0_P.DigitalFilterLowpass_RTP1COEFF[1]);
         Filter0_DWork.DigitalFilterLowpass_FILT_STATE[0]=accum;
      }
      {
         accum=Filter0_DWork.DigitalFilterLowpass_FILT_STATE[2];
         accum=accum+(Filter0_U->In1*Filter0_P.DigitalFilterLowpass_RTP1COEFF[2]);
         Filter0_DWork.DigitalFilterLowpass_FILT_STATE[1]=accum;
      }
      {
         accum=Filter0_DWork.DigitalFilterLowpass_FILT_STATE[3];
         accum=accum+(Filter0_U->In1*Filter0_P.DigitalFilterLowpass_RTP1COEFF[3]);
         Filter0_DWork.DigitalFilterLowpass_FILT_STATE[2]=accum;
      }
      {
         accum=Filter0_DWork.DigitalFilterLowpass_FILT_STATE[4];
         accum=accum+(Filter0_U->In1*Filter0_P.DigitalFilterLowpass_RTP1COEFF[4]);
         Filter0_DWork.DigitalFilterLowpass_FILT_STATE[3]=accum;
      }
      {
         accum=Filter0_DWork.DigitalFilterLowpass_FILT_STATE[5];
         accum=accum+(Filter0_U->In1*Filter0_P.DigitalFilterLowpass_RTP1COEFF[5]);
         Filter0_DWork.DigitalFilterLowpass_FILT_STATE[4]=accum;
      }
      {
         accum=Filter0_DWork.DigitalFilterLowpass_FILT_STATE[6];
         accum=accum+(Filter0_U->In1*Filter0_P.DigitalFilterLowpass_RTP1COEFF[6]);
         Filter0_DWork.DigitalFilterLowpass_FILT_STATE[5]=accum;
      }
      {
         accum=Filter0_DWork.DigitalFilterLowpass_FILT_STATE[7];
         accum=accum+(Filter0_U->In1*Filter0_P.DigitalFilterLowpass_RTP1COEFF[7]);
         Filter0_DWork.DigitalFilterLowpass_FILT_STATE[6]=accum;
      }
      {
         accum=Filter0_DWork.DigitalFilterLowpass_FILT_STATE[8];
         accum=accum+(Filter0_U->In1*Filter0_P.DigitalFilterLowpass_RTP1COEFF[8]);
         Filter0_DWork.DigitalFilterLowpass_FILT_STATE[7]=accum;
      }
      {
         accum=Filter0_DWork.DigitalFilterLowpass_FILT_STATE[9];
         accum=accum+(Filter0_U->In1*Filter0_P.DigitalFilterLowpass_RTP1COEFF[9]);
         Filter0_DWork.DigitalFilterLowpass_FILT_STATE[8]=accum;
      }
      {
         accum=Filter0_DWork.DigitalFilterLowpass_FILT_STATE[10];
         accum=accum+(Filter0_U->In1*Filter0_P.DigitalFilterLowpass_RTP1COEFF[10]);
         Filter0_DWork.DigitalFilterLowpass_FILT_STATE[9]=accum;
      }
      {
         accum=Filter0_DWork.DigitalFilterLowpass_FILT_STATE[11];
         accum=accum+(Filter0_U->In1*Filter0_P.DigitalFilterLowpass_RTP1COEFF[11]);
         Filter0_DWork.DigitalFilterLowpass_FILT_STATE[10]=accum;
      }
      {
         accum=Filter0_DWork.DigitalFilterLowpass_FILT_STATE[12];
         accum=accum+(Filter0_U->In1*Filter0_P.DigitalFilterLowpass_RTP1COEFF[12]);
         Filter0_DWork.DigitalFilterLowpass_FILT_STATE[11]=accum;
      }
      {
         accum=Filter0_DWork.DigitalFilterLowpass_FILT_STATE[13];
         accum=accum+(Filter0_U->In1*Filter0_P.DigitalFilterLowpass_RTP1COEFF[13]);
         Filter0_DWork.DigitalFilterLowpass_FILT_STATE[12]=accum;
      }
      {
         accum=Filter0_DWork.DigitalFilterLowpass_FILT_STATE[14];
         accum=accum+(Filter0_U->In1*Filter0_P.DigitalFilterLowpass_RTP1COEFF[14]);
         Filter0_DWork.DigitalFilterLowpass_FILT_STATE[13]=accum;
      }
      {
         accum=Filter0_DWork.DigitalFilterLowpass_FILT_STATE[15];
         accum=accum+(Filter0_U->In1*Filter0_P.DigitalFilterLowpass_RTP1COEFF[15]);
         Filter0_DWork.DigitalFilterLowpass_FILT_STATE[14]=accum;
      }
      {
         accum=Filter0_DWork.DigitalFilterLowpass_FILT_STATE[16];
         accum=accum+(Filter0_U->In1*Filter0_P.DigitalFilterLowpass_RTP1COEFF[16]);
         Filter0_DWork.DigitalFilterLowpass_FILT_STATE[15]=accum;
      }
   }
   NOC_RNI_SEND(NOC_RNI_BASE,p2_out0_priority,p2_pid,p3_pid,send_channel_p2_to_p3,p2_out0_msg_len);
}
// *** DEFINE YOUR PROCESS MAIN CODE ABOVE THIS LINE
