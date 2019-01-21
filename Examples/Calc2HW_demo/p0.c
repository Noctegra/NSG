#include "system.h"
#include "altera_avalon_pio_regs.h"
#include "alt_types.h"
#include "software_configuration.h"

// *** DEFINE YOUR CUSTOM INCLUDE FILES BELOW THIS LINE
#include "channel_types.h"
#include "stdio.h"

// *** DEFINE YOUR CUSTOM INCLUDE FILES ABOVE THIS LINE

// *****************************************************************************************************************************************
// *
// * Define dynamic process meta_information
// *
// * Channel priority
// * Length of message in words, excluding the 40-bit heartbeat clock (sent as 2x32 bit words)
// *****************************************************************************************************************************************
int p0_out0_priority=0;
int p0_out0_msg_len=sizeof(neuron_values)/4;
int p0_out1_priority=0;
int p0_out1_msg_len=sizeof(neuron_values)/4;

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
// Channel send_channel_p0_to_p1 variable p0_out0
volatile neuron_values *p0_out0=(neuron_values *)NOC_PARAMETER_MAP(NOC_RNI_SEND_BASE(send_channel_p0_to_p1),0);
// Channel send_channel_p0_to_p3 variable p0_out1
volatile neuron_values *p0_out1=(neuron_values *)NOC_PARAMETER_MAP(NOC_RNI_SEND_BASE(send_channel_p0_to_p3),0);

// *** DEFINE YOUR PROCESS INIT CODE BELOW THIS LINE
// *****************************************************************************************************************************************
// * 
// * Define reset, i.e., process initialization values
// *
// *****************************************************************************************************************************************
int pio_value=1;
void p0_init(void)
{
	IOWR(PIO_0_BASE,0,pio_value);
	p0_out0->n0=0.0;
	p0_out0->n1=0.0;
	p0_out0->n2=0.0;
	p0_out0->n3=0.0;
	p0_out0->n4=0.0;
	p0_out0->n5=0.0;
	p0_out0->n6=0.0;
	p0_out0->n7=0.0;
	p0_out0->n8=0.0;
	p0_out0->n9=0.0;
	NOC_SWITCH_SEND(NOC_RNI_BASE,1,1,1,send_channel_p0_to_p1,2);
};
// *** DEFINE YOUR PROCESS INIT CODE ABOVE THIS LINE
// *** DEFINE YOUR PROCESS MAIN CODE BELOW THIS LINE
// *****************************************************************************************************************************************
// * 
// * Define the process main cycle function
// *
// *****************************************************************************************************************************************
int step=1.0;
void p0_main(void)
{
	pio_value=1-pio_value;
	IOWR(PIO_0_BASE,0,pio_value);
	p0_out0->n0=(step<10.0) ? -10+1.0*step : -10;
	p0_out0->n1=(step<10.0) ? -10+1.5*step : -10;
	p0_out0->n2=(step<10.0) ? -10+2.0*step : -10;
	p0_out0->n3=(step<10.0) ? -10+2.5*step : -10;
	p0_out0->n4=(step<10.0) ? -10+1.0*step : -10;
	p0_out0->n5=(step<10.0) ?  10-1.0*step : 10;
	p0_out0->n6=(step<10.0) ?  10-1.5*step : 10;
	p0_out0->n7=(step<10.0) ?  10-2.0*step : 10;
	p0_out0->n8=(step<10.0) ?  10+2.5*step : 10;
	p0_out0->n9=(step<10.0) ?  10+1.0*step : 10;
	if (step>15.0)
	{
		step=-15.0;
	}
	else
	{
		step+=1.0;
	};
	NOC_RNI_SEND(NOC_RNI_BASE,p0_out1_priority,p0_pid,p3_pid,send_channel_p0_to_p3,p0_out1_msg_len);
};
// *** DEFINE YOUR PROCESS MAIN CODE ABOVE THIS LINE
