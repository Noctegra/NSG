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
// Channel recv_channel_p2_from_p1 variable p2_in0
volatile neuron_values *p2_in0=(neuron_values *)NOC_PARAMETER_MAP(NOC_RNI_RECV_BASE(recv_channel_p2_from_p1),0);
volatile int *p2_in0_heartbeat=(int *)NOC_PARAMETER_MAP(NOC_RNI_RECV_BASE(recv_channel_p2_from_p1),sizeof(neuron_values)/4);
// Channel recv_channel_p2_from_p3 variable p2_in1
volatile neuron_values *p2_in1=(neuron_values *)NOC_PARAMETER_MAP(NOC_RNI_RECV_BASE(recv_channel_p2_from_p3),0);
volatile int *p2_in1_heartbeat=(int *)NOC_PARAMETER_MAP(NOC_RNI_RECV_BASE(recv_channel_p2_from_p3),sizeof(neuron_values)/4);

// *** DEFINE YOUR PROCESS INIT CODE BELOW THIS LINE
// *****************************************************************************************************************************************
// * 
// * Define reset, i.e., process initialization values
// *
// *****************************************************************************************************************************************
int alive;
void p2_init(void)
{
	alive=1;
	IOWR(PIO_0_BASE,0,alive);
}
// *** DEFINE YOUR PROCESS INIT CODE ABOVE THIS LINE
// *** DEFINE YOUR PROCESS MAIN CODE BELOW THIS LINE
// *****************************************************************************************************************************************
// * 
// * Define the process main cycle function
// *
// *****************************************************************************************************************************************
void print_double(double d)
{
	double tmp;
	int d1,d2,d3,d4;
	long int i;
	if (d<0)
	{
		tmp=-d;
		i=(int)tmp;
		tmp=10*(tmp-i);
		d1=(int)tmp;
		tmp=10*(tmp-d1);
		d2=(int)tmp;
		tmp=10*(tmp-d2);
		d3=(int)tmp;
		tmp=10*(tmp-d3);
		d4=(int)tmp;
		printf("-%ld.%d%d%d%d ",i,d1,d2,d3,d4);
	}
	else
	{
		tmp=d;
		i=(int)tmp;
		tmp=10*(tmp-i);
		d1=(int)tmp;
		tmp=10*(tmp-d1);
		d2=(int)tmp;
		tmp=10*(tmp-d2);
		d3=(int)tmp;
		tmp=10*(tmp-d3);
		d4=(int)tmp;
		printf(" %ld.%d%d%d%d ",i,d1,d2,d3,d4);
	}
}
void print_hex(double d)
{
	double *ptr=&d;
	int *convert=(int *)ptr;
	printf(" %08x%08x ",convert[1],convert[0]);
};
void p2_main(void)
{
	alive=1-alive;
	IOWR(PIO_0_BASE,0,alive);
	printf("     n0     n1     n2     n3     n4     n5     n6     n7     n8     n9\n");
	printf("----------------------------------------------------------------------\n");
	printf("HW::   ");
	print_double(p2_in0->n0);
	print_double(p2_in0->n1);
	print_double(p2_in0->n2);
	print_double(p2_in0->n3);
	print_double(p2_in0->n4);
	print_double(p2_in0->n5);
	print_double(p2_in0->n6);
	print_double(p2_in0->n7);
	print_double(p2_in0->n8);
	print_double(p2_in0->n9);
	printf("\n");
	printf("SW::   ");
	print_double(p2_in1->n0);
	print_double(p2_in1->n1);
	print_double(p2_in1->n2);
	print_double(p2_in1->n3);
	print_double(p2_in1->n4);
	print_double(p2_in1->n5);
	print_double(p2_in1->n6);
	print_double(p2_in1->n7);
	print_double(p2_in1->n8);
	print_double(p2_in1->n9);
	printf("----------------------------------------------------------------------\n");
	//(*p2_out0)=p2_receiver;
	//while (NOC_RNI_STATUS(NOC_RNI_BASE)!=0);
	//NOC_RNI_SEND(NOC_RNI_BASE,p2_out0_priority,p2_pid,_pid,send_channel_p2_to_,p2_out0_msg_len);
};
// *** DEFINE YOUR PROCESS MAIN CODE ABOVE THIS LINE
