#include "xparameters.h"
#include "software_configuration.h"

// *** DEFINE YOUR CUSTOM INCLUDE FILES BELOW THIS LINE
#include "xparameters.h"
#include "rtwtypes.h"
#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

// *** DEFINE YOUR CUSTOM INCLUDE FILES ABOVE THIS LINE

// *****************************************************************************************************************************************
// *
// * Define dynamic process meta_information
// *
// * Channel priority
// * Length of message in words, excluding the 40-bit heartbeat clock (sent as 2x32 bit words)
// *****************************************************************************************************************************************
typedef struct {
  real_T Out1;                         /* '<Root>/Out1' */
} ExternalOutputs_Source;
int p0_out0_priority=0;
int p0_out0_msg_len=sizeof(ExternalOutputs_Source);

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
// Channel send_channel_p0_to_p1 variable Source_Y
int p0_out0_priority=0;
int p0_out0_msg_len=sizeof(ExternalOutputs_Source);

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
// Channel send_channel_p0_to_p1 variable Source_Y
volatile ExternalOutputs_Source *Source_Y=(ExternalOutputs_Source *)NOC_PARAMETER_MAP(NOC_RNI_SEND_BASE(send_channel_p0_to_p1),0);

// *** DEFINE YOUR PROCESS INIT CODE BELOW THIS LINE
// *****************************************************************************************************************************************
// * 
// * Define reset, i.e., process initialization values
// *
// *****************************************************************************************************************************************
// * Simulink specific data types
typedef struct {
      real_T SineWave1_AccFreqNorm;
} D_Work_Source;
typedef struct {
      real_T SineWave1_Amplitude;
      real_T SineWave1_Frequency;
      real_T SineWave1_Phase;
} Parameters_Source;
// * Global variables
D_Work_Source Source_DWork;
Parameters_Source Source_P={
   1.00000000000000000e+000,
   7.50000000000000000e+001,
   0.00000000000000000e+000
};
// * Simulink Inbuilt Functions
void Source_initialize()
{
  /* Registration code */

  /* initialize error status */
  // // // // // // // rtmSetErrorStatus(Source_M, (NULL));

  /* states (dwork) */
  (void) memset((void *)&Source_DWork, 0,
                sizeof(D_Work_Source));

  /* external outputs */
  Source_Y->Out1 = 0.0;

  {
    real_T arg;

    /* Start for S-Function (sdspsine2): '<S1>/Sine Wave1' */
    /* Trigonometric mode: compute accumulated
       normalized trig fcn argument for each channel */
    /* Keep normalized value in range [0 2*pi) */
    for (arg = Source_P.SineWave1_Phase; arg >= 6.2831853071795862; arg -=
         6.2831853071795862) {
    }

    while (arg < 0.0) {
      arg += 6.2831853071795862;
    }

    Source_DWork.SineWave1_AccFreqNorm = arg;

    /* End of Start for S-Function (sdspsine2): '<S1>/Sine Wave1' */
  }

  {
    real_T arg;

    /* InitializeConditions for S-Function (sdspsine2): '<S1>/Sine Wave1' */
    /* This code only executes when block is re-enabled in an
       enabled subsystem when the enabled subsystem states on
       re-enabling are set to 'Reset' */
    /* Reset to time zero on re-enable */
    /* Trigonometric mode: compute accumulated
       normalized trig fcn argument for each channel */
    /* Keep normalized value in range [0 2*pi) */
    for (arg = Source_P.SineWave1_Phase; arg >= 6.2831853071795862; arg -=
         6.2831853071795862) {
    }

    while (arg < 0.0) {
      arg += 6.2831853071795862;
    }

    Source_DWork.SineWave1_AccFreqNorm = arg;

    /* End of InitializeConditions for S-Function (sdspsine2): '<S1>/Sine Wave1' */
  }
};
void p0_init(void)
{
   Source_initialize();
	NOC_RNI_SEND(NOC_RNI_BASE,send_channel_p0_to_p1,p0_out0_priority,p0_out0_msg_len);
}
// *** DEFINE YOUR PROCESS INIT CODE ABOVE THIS LINE
// *** DEFINE YOUR PROCESS MAIN CODE BELOW THIS LINE
// *****************************************************************************************************************************************
// * 
// * Define the process main cycle function
// *
// *****************************************************************************************************************************************
void Source_step()
{
  /* Outport: '<Root>/Out1' incorporates:
   *  S-Function (sdspsine2): '<S1>/Sine Wave1'
   */
  Source_Y->Out1 = Source_P.SineWave1_Amplitude * sin
    (Source_DWork.SineWave1_AccFreqNorm);

  /* S-Function (sdspsine2): '<S1>/Sine Wave1' */
  /* Update accumulated normalized freq value
     for next sample.  Keep in range [0 2*pi) */
  Source_DWork.SineWave1_AccFreqNorm += Source_P.SineWave1_Frequency *
    0.0062831853071795866;
  if (Source_DWork.SineWave1_AccFreqNorm >= 6.2831853071795862) {
    Source_DWork.SineWave1_AccFreqNorm -= 6.2831853071795862;
  } else {
    if (Source_DWork.SineWave1_AccFreqNorm < 0.0) {
      Source_DWork.SineWave1_AccFreqNorm += 6.2831853071795862;
    }
  }
};
void p0_main(void)
{
   Source_step();
	NOC_RNI_SEND(NOC_RNI_BASE,send_channel_p0_to_p1,p0_out0_priority,p0_out0_msg_len);
}
// *** DEFINE YOUR PROCESS MAIN CODE ABOVE THIS LINE
