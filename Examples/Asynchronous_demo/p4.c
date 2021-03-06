#include "xparameters.h"
#include "software_configuration.h"

// *** DEFINE YOUR CUSTOM INCLUDE FILES BELOW THIS LINE

// *** DEFINE YOUR CUSTOM INCLUDE FILES ABOVE THIS LINE

// *****************************************************************************************************************************************
// *
// * Define dynamic process meta_information
// *
// * Channel priority
// * Length of message in words, excluding the 40-bit heartbeat clock (sent as 2x32 bit words)
// *****************************************************************************************************************************************
int p4_out0_priority=0;
int p4_out0_msg_len=sizeof(int)/4;

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
// Channel send_channel_p4_to_p0 variable p4_out0
volatile int *p4_out0=(int *)NOC_PARAMETER_MAP(NOC_RNI_SEND_BASE(send_channel_p4_to_p0),0);
// Channel recv_channel_p4_from_p5 variable p4_in0
volatile int *p4_in0=(int *)NOC_PARAMETER_MAP(NOC_RNI_RECV_BASE(recv_channel_p4_from_p5),0);
volatile int *p4_in0_heartbeat=(int *)NOC_PARAMETER_MAP(NOC_RNI_RECV_BASE(recv_channel_p4_from_p5),sizeof(int)/4);

// *** DEFINE YOUR PROCESS INIT CODE BELOW THIS LINE
// *****************************************************************************************************************************************
// * 
// * Define reset, i.e., process initialization values
// *
// *****************************************************************************************************************************************
void p4_init(void)
{
//	(*p4_out0)=0;
	NOC_RNI_SEND(NOC_RNI_BASE,send_channel_p4_to_p0,p4_out0_priority,p4_out0_msg_len);
};
// *** DEFINE YOUR PROCESS INIT CODE ABOVE THIS LINE
// *** DEFINE YOUR PROCESS MAIN CODE BELOW THIS LINE
// *****************************************************************************************************************************************
// * 
// * Define the process main cycle function
// *
// *****************************************************************************************************************************************
void p4_main(void)
{
     if (NOC_RNI_RECV_CHANNEL_STATUS(NOC_RNI_BASE,recv_channel_p4_from_p5)>0)
     {
	(*p4_out0)=(*p4_in0);
	NOC_RNI_SEND(NOC_RNI_BASE,send_channel_p4_to_p0,p4_out0_priority,p4_out0_msg_len);
               NOC_RNI_CLEAR_SYNCHRONIZER_FLAG(NOC_RNI_BASE,recv_channel_p4_from_p5);
     };
};
// *** DEFINE YOUR PROCESS MAIN CODE ABOVE THIS LINE
