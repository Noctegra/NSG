#include "system.h"
#include "altera_avalon_pio_regs.h"
#include "alt_types.h"
#include "software_configuration.h"

// *** DEFINE YOUR CUSTOM INCLUDE FILES BELOW THIS LINE
#include "channel_types.h"

// *** DEFINE YOUR CUSTOM INCLUDE FILES ABOVE THIS LINE

// *****************************************************************************************************************************************
// *
// * Define dynamic process meta_information
// *
// * Channel priority
// * Length of message in words, excluding the 40-bit heartbeat clock (sent as 2x32 bit words)
// *****************************************************************************************************************************************
int p3_out0_priority=0;
int p3_out0_msg_len=sizeof(neuron_values)/4;

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
// Channel send_channel_p3_to_p2 variable p3_out0
volatile neuron_values *p3_out0=(neuron_values *)NOC_PARAMETER_MAP(NOC_RNI_SEND_BASE(send_channel_p3_to_p2),0);
// Channel recv_channel_p3_from_p0 variable p3_in0
volatile neuron_values *p3_in0=(neuron_values *)NOC_PARAMETER_MAP(NOC_RNI_RECV_BASE(recv_channel_p3_from_p0),0);
volatile int *p3_in0_heartbeat=(int *)NOC_PARAMETER_MAP(NOC_RNI_RECV_BASE(recv_channel_p3_from_p0),sizeof(neuron_values)/4);

// *** DEFINE YOUR PROCESS INIT CODE BELOW THIS LINE
// *****************************************************************************************************************************************
// * 
// * Define reset, i.e., process initialization values
// *
// *****************************************************************************************************************************************
// Declare State variables
int alive;
// Declare Weights
neuron_weights w0={ 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0 };
neuron_weights w1={ 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0 };
neuron_weights w2={ 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0 };
neuron_weights w3={ 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0 };
neuron_weights w4={ 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0 };
neuron_weights w5={ 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0 };
neuron_weights w6={ 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0 };
neuron_weights w7={ 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0 };
neuron_weights w8={ 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0 };
neuron_weights w9={ 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0 };
void p3_init(void)
{
	alive=1;
	IOWR(PIO_0_BASE,0,alive);
	p3_out0->n0=0.0;
	p3_out0->n1=0.0;
	p3_out0->n2=0.0;
	p3_out0->n3=0.0;
	p3_out0->n4=0.0;
	p3_out0->n5=0.0;
	p3_out0->n6=0.0;
	p3_out0->n7=0.0;
	p3_out0->n8=0.0;
	p3_out0->n9=0.0;
	NOC_RNI_SEND(NOC_RNI_BASE,p3_out0_priority,p3_pid,p2_pid,send_channel_p3_to_p2,p3_out0_msg_len);
};
// *** DEFINE YOUR PROCESS INIT CODE ABOVE THIS LINE
// *** DEFINE YOUR PROCESS MAIN CODE BELOW THIS LINE
// *****************************************************************************************************************************************
// * 
// * Define the process main cycle function
// *
// *****************************************************************************************************************************************
void p3_main(void)
{
	alive=1-alive;
	IOWR(PIO_0_BASE,0,alive);
	p3_out0->n0=p3_in0->n0 * w0.w0 +
				p3_in0->n1 * w0.w1 +
				p3_in0->n2 * w0.w2 +
				p3_in0->n3 * w0.w3 +
				p3_in0->n4 * w0.w4 +
				p3_in0->n5 * w0.w5 +
				p3_in0->n6 * w0.w6 +
				p3_in0->n7 * w0.w7 +
				p3_in0->n8 * w0.w8 +
				p3_in0->n9 * w0.w9 ;
	p3_out0->n1=p3_in0->n0*w1.w0+
				p3_in0->n1*w1.w1+
				p3_in0->n2*w1.w2+
				p3_in0->n3*w1.w3+
				p3_in0->n4*w1.w4+
				p3_in0->n5*w1.w5+
				p3_in0->n6*w1.w6+
				p3_in0->n7*w1.w7+
				p3_in0->n8*w1.w8+
				p3_in0->n9*w1.w9;
	p3_out0->n2=p3_in0->n0*w2.w0+
				p3_in0->n1*w2.w1+
				p3_in0->n2*w2.w2+
				p3_in0->n3*w2.w3+
				p3_in0->n4*w2.w4+
				p3_in0->n5*w2.w5+
				p3_in0->n6*w2.w6+
				p3_in0->n7*w2.w7+
				p3_in0->n8*w2.w8+
				p3_in0->n9*w2.w9;
	p3_out0->n3=p3_in0->n0*w3.w0+
				p3_in0->n1*w3.w1+
				p3_in0->n2*w3.w2+
				p3_in0->n3*w3.w3+
				p3_in0->n4*w3.w4+
				p3_in0->n5*w3.w5+
				p3_in0->n6*w3.w6+
				p3_in0->n7*w3.w7+
				p3_in0->n8*w3.w8+
				p3_in0->n9*w3.w9;
	p3_out0->n4=p3_in0->n0*w4.w0+
				p3_in0->n1*w4.w1+
				p3_in0->n2*w4.w2+
				p3_in0->n3*w4.w3+
				p3_in0->n4*w4.w4+
				p3_in0->n5*w4.w5+
				p3_in0->n6*w4.w6+
				p3_in0->n7*w4.w7+
				p3_in0->n8*w4.w8+
				p3_in0->n9*w4.w9;
	p3_out0->n5=p3_in0->n0*w5.w0+
				p3_in0->n1*w5.w1+
				p3_in0->n2*w5.w2+
				p3_in0->n3*w5.w3+
				p3_in0->n4*w5.w4+
				p3_in0->n5*w5.w5+
				p3_in0->n6*w5.w6+
				p3_in0->n7*w5.w7+
				p3_in0->n8*w5.w8+
				p3_in0->n9*w5.w9;
	p3_out0->n6=p3_in0->n0*w6.w0+
				p3_in0->n1*w6.w1+
				p3_in0->n2*w6.w2+
				p3_in0->n3*w6.w3+
				p3_in0->n4*w6.w4+
				p3_in0->n5*w6.w5+
				p3_in0->n6*w6.w6+
				p3_in0->n7*w6.w7+
				p3_in0->n8*w6.w8+
				p3_in0->n9*w6.w9;
	p3_out0->n7=p3_in0->n0*w7.w0+
				p3_in0->n1*w7.w1+
				p3_in0->n2*w7.w2+
				p3_in0->n3*w7.w3+
				p3_in0->n4*w7.w4+
				p3_in0->n5*w7.w5+
				p3_in0->n6*w7.w6+
				p3_in0->n7*w7.w7+
				p3_in0->n8*w7.w8+
				p3_in0->n9*w7.w9;
	p3_out0->n8=p3_in0->n0*w8.w0+
				p3_in0->n1*w8.w1+
				p3_in0->n2*w8.w2+
				p3_in0->n3*w8.w3+
				p3_in0->n4*w8.w4+
				p3_in0->n5*w8.w5+
				p3_in0->n6*w8.w6+
				p3_in0->n7*w8.w7+
				p3_in0->n8*w8.w8+
				p3_in0->n9*w8.w9;
	p3_out0->n9=p3_in0->n0*w9.w0+
				p3_in0->n1*w9.w1+
				p3_in0->n2*w9.w2+
				p3_in0->n3*w9.w3+
				p3_in0->n4*w9.w4+
				p3_in0->n5*w9.w5+
				p3_in0->n6*w9.w6+
				p3_in0->n7*w9.w7+
				p3_in0->n8*w9.w8+
				p3_in0->n9*w9.w9;
	NOC_RNI_SEND(NOC_RNI_BASE,p3_out0_priority,p3_pid,p2_pid,send_channel_p3_to_p2,p3_out0_msg_len);
};
// *** DEFINE YOUR PROCESS MAIN CODE ABOVE THIS LINE
