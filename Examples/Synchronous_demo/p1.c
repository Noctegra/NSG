#include "system.h"
#include "alt_types.h"
#include "software_configuration.h"
#include <stdio.h>

// *** DEFINE YOUR CUSTOM INCLUDE FILES BELOW THIS LINE
#include <stdio.h>

// *** DEFINE YOUR CUSTOM INCLUDE FILES ABOVE THIS LINE

// *****************************************************************************************************************************************
// *
// * Define dynamic process meta_information
// *
// * Channel priority
// * Length of message in words, excluding the 40-bit heartbeat clock (sent as 2x32 bit words)
// *****************************************************************************************************************************************
int p1_out0_priority=0;
int p1_out0_msg_len=sizeof(int)/4;

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
// Channel send_channel_p1_to_p2 variable p1_out0
volatile int *p1_out0=(int *)NOC_PARAMETER_MAP(NOC_RNI_SEND_BASE(send_channel_p1_to_p2),0);
// Channel recv_channel_p1_from_p0 variable p1_in0
volatile int *p1_in0=(int *)NOC_PARAMETER_MAP(NOC_RNI_RECV_BASE(recv_channel_p1_from_p0),0);
volatile int *p1_in0_heartbeat=(int *)NOC_PARAMETER_MAP(NOC_RNI_RECV_BASE(recv_channel_p1_from_p0),sizeof(int)/4);

// *** DEFINE YOUR PROCESS INIT CODE BELOW THIS LINE
// *****************************************************************************************************************************************
// * 
// * Define reset, i.e., process initialization values
// *
// *****************************************************************************************************************************************
void p1_init(void) 
{
	(*p1_out0)=0;
	NOC_RNI_SEND(NOC_RNI_BASE,send_channel_p1_to_p2,p1_out0_priority,p1_out0_msg_len);
};
// *** DEFINE YOUR PROCESS INIT CODE ABOVE THIS LINE
// *** DEFINE YOUR PROCESS MAIN CODE BELOW THIS LINE
// *****************************************************************************************************************************************
// * 
// * Define the process main cycle function
// *
// *****************************************************************************************************************************************
void p1_main(void)
{
	int result=(*p1_in0);
	(*p1_out0)=result;
	IOWR(PIO_0_BASE,0,result);
	NOC_RNI_SEND(NOC_RNI_BASE,send_channel_p1_to_p2,p1_out0_priority,p1_out0_msg_len);
};
// *** DEFINE YOUR PROCESS MAIN CODE ABOVE THIS LINE
