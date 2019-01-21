#include "xparameters.h"
#include "software_configuration.h"

// *** DEFINE YOUR CUSTOM INCLUDE FILES BELOW THIS LINE
#include "xparameters.h"
#include "stdio.h"

// *** DEFINE YOUR CUSTOM INCLUDE FILES ABOVE THIS LINE

// *****************************************************************************************************************************************
// *
// * Define dynamic process meta_information
// *
// * Channel priority
// * Length of message in words, excluding the 40-bit heartbeat clock (sent as 2x32 bit words)
// *****************************************************************************************************************************************

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
// Channel recv_channel_p3_from_p2 variable p3_in0
volatile double *p3_in0=(double *)NOC_PARAMETER_MAP(NOC_RNI_RECV_BASE(recv_channel_p3_from_p2),0);
volatile int *p3_in0_heartbeat=(int *)NOC_PARAMETER_MAP(NOC_RNI_RECV_BASE(recv_channel_p3_from_p2),sizeof(double)/4);

// *** DEFINE YOUR PROCESS INIT CODE BELOW THIS LINE
void p3_init(void)
{
      xil_printf("Inititating\n");
};
// *** DEFINE YOUR PROCESS INIT CODE ABOVE THIS LINE
// *** DEFINE YOUR PROCESS MAIN CODE BELOW THIS LINE
void p3_main(void)
{
   int input_from_p2 = NOC_RNI_CHK_MSG(NOC_RNI_BASE,recv_channel_p3_from_p2);
   if (input_from_p2 > 0)
   {
      int inp1_lsw = p3_in0[0];
      int inp1_msw = p3_in0[1];
      xil_printf("%08x%08x\n",inp1_msw,inp1_lsw);
   }
   else
   {
       IOWR(PIO_0_BASE,0,0xFF);
   }
};

// *** DEFINE YOUR PROCESS MAIN CODE ABOVE THIS LINE
