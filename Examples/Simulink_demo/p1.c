#include "xparameters.h"
#include "software_configuration.h"

// *** DEFINE YOUR CUSTOM INCLUDE FILES BELOW THIS LINE
#include "xparameters.h"
#include "rtwtypes.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

// *** DEFINE YOUR CUSTOM INCLUDE FILES ABOVE THIS LINE

// *****************************************************************************************************************************************
// *
// * Define dynamic process meta_information
// *
// * Channel priority
// * Length of message in words, excluding the 40-bit heartbeat clock (sent as 2x32 bit words)
// *****************************************************************************************************************************************
typedef struct {
  real_T In1;                          /* '<Root>/In1' */
} ExternalInputs_Noise;

/* External outputs (root outports fed by signals with auto storage) */
typedef struct {
  real_T Out1;                         /* '<Root>/Out1' */
} ExternalOutputs_Noise;

int p1_out0_priority=0;
int p1_out0_msg_len=sizeof(ExternalOutputs_Noise);

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
// Channel send_channel_p1_to_p2 variable Noise_Y
int p1_out0_priority=0;
int p1_out0_msg_len=sizeof(ExternalOutputs_Noise);

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
// Channel send_channel_p1_to_p2 variable Noise_Y
volatile ExternalOutputs_Noise *Noise_Y=(ExternalOutputs_Noise *)NOC_PARAMETER_MAP(NOC_RNI_SEND_BASE(send_channel_p1_to_p2),0);
// Channel recv_channel_p1_from_p0 variable Noise_U
volatile ExternalInputs_Noise *Noise_U=(ExternalInputs_Noise *)NOC_PARAMETER_MAP(NOC_RNI_RECV_BASE(recv_channel_p1_from_p0),0);
volatile int *Noise_U_heartbeat=(int *)NOC_PARAMETER_MAP(NOC_RNI_RECV_BASE(recv_channel_p1_from_p0),sizeof(ExternalInputs_Noise)/4);

// *** DEFINE YOUR PROCESS INIT CODE BELOW THIS LINE
// *****************************************************************************************************************************************
// * 
// * Define reset, i.e., process initialization values
// *
// *****************************************************************************************************************************************
// * Simulink specific data types
typedef struct {
      real_T RandomSource;
      real_T DigitalFilterHighpass;
} BlockIO_Noise;
typedef struct {
      real_T DigitalFilterHighpass_FILT_STAT[19];
      real_T RandomSource_STATE_DWORK[35];
      uint32_T RandomSource_SEED_DWORK;
} D_Work_Noise;
typedef struct {
      real_T RandomSource_MinRTP;
      real_T RandomSource_MaxRTP;
      real_T DigitalFilterHighpass_RTP1COEFF[19];
} Parameters_Noise;
// * Global variables
BlockIO_Noise Noise_B;
D_Work_Noise Noise_DWork;
Parameters_Noise Noise_P={
   0.00000000000000000e+000,
   4.00000000000000000e+000,
   {
      -5.10000000000000040e-003,
      1.81000000000000020e-002,
      -6.89999999999999990e-003,
      -2.82999999999999990e-002,
      -6.10000000000000040e-003,
      5.48999999999999970e-002,
      5.79000000000000000e-002,
      -8.26000000000000070e-002,
      -2.99200000000000020e-001,
      5.94600000000000020e-001,
      -2.99200000000000020e-001,
      -8.26000000000000070e-002,
      5.79000000000000000e-002,
      5.48999999999999970e-002,
      -6.10000000000000040e-003,
      -2.82999999999999990e-002,
      -6.89999999999999990e-003,
      1.81000000000000020e-002,
      -5.10000000000000040e-003
   }
};
// * Simulink Inbuilt Functions
void RandSrcInitState_U_64(uint32_T seed[],real_T state[],int32_T nChans)
{
  int32_T i;
  uint32_T j;
  int32_T k;
  int32_T n;
  real_T d;

  /* Start for S-Function (sdsprandsrc2): '<S1>/Random Source' */
  /* RandSrcInitState_U_64 */
  for (i = 0; i < nChans; i++) {
    j = seed[i] != 0U ? seed[i] : 2147483648U;
    state[35 * i + 34] = j;
    for (k = 0; k < 32; k++) {
      d = 0.0;
      for (n = 0; n < 53; n++) {
        j ^= j << 13;
        j ^= j >> 17;
        j ^= j << 5;
        d = (real_T)((int32_T)(j >> 19) & 1) + (d + d);
      }

      state[35 * i + k] = ldexp(d, -53);
    }

    state[35 * i + 32] = 0.0;
    state[35 * i + 33] = 0.0;
  }

  /* End of Start for S-Function (sdsprandsrc2): '<S1>/Random Source' */
};
void RandSrc_U_D(real_T y[],real_T minVec[],int32_T minLen,real_T maxVec[],int32_T maxLen,real_T state[],int32_T nChans,int32_T nSamps)
{
  int32_T one;
  int32_T lsw;
  int8_T (*onePtr)[];
  int32_T chan;
  real_T min;
  real_T max;
  int32_T samps;
  real_T d;
  int32_T i;
  uint32_T j;

  /* Start for S-Function (sdsprandsrc2): '<S1>/Random Source' */
  /* RandSrc_U_D */
  one = 1;
  onePtr = (int8_T (*)[])&one;
  lsw = ((*onePtr)[0U] == 0);
  for (chan = 0; chan < nChans; chan++) {
    min = minVec[minLen > 1 ? chan : 0];
    max = maxVec[maxLen > 1 ? chan : 0];
    max -= min;
    i = (int32_T)((uint32_T)state[chan * 35 + 33] & 31U);
    j = (uint32_T)state[chan * 35 + 34];
    for (samps = 0; samps < nSamps; samps++) {
      /* "Subtract with borrow" generator */
      d = state[((i + 20) & 31) + chan * 35];
      d -= state[((i + 5) & 31) + chan * 35];
      d -= state[chan * 35 + 32];
      if (d >= 0.0) {
        state[chan * 35 + 32] = 0.0;
      } else {
        d++;

        /* set 1 in LSB */
        state[chan * 35 + 32] = 1.1102230246251565E-16;
      }

      state[chan * 35 + i] = d;
      i = (i + 1) & 31;

      /* XOR with shift register sequence */
      (*(int32_T (*)[])&d)[lsw] ^= j;
      j ^= j << 13;
      j ^= j >> 17;
      j ^= j << 5;
      (*(int32_T (*)[])&d)[lsw ^ 1] ^= j & 1048575U;
      y[chan * nSamps + samps] = max * d + min;
    }

    state[chan * 35 + 33] = i;
    state[chan * 35 + 34] = j;
  }

  /* End of Start for S-Function (sdsprandsrc2): '<S1>/Random Source' */
};
void RandSrcCreateSeeds_64(uint32_T initSeed,uint32_T seedArray[],int32_T numSeeds)
{
  real_T state[35];
  real_T tmp;
  real_T min;
  real_T max;
  int32_T i;

  /* Start for S-Function (sdsprandsrc2): '<S1>/Random Source' */
  /* RandSrcCreateSeeds_64 */
  min = 0.0;
  max = 1.0;
  RandSrcInitState_U_64(&initSeed, state, 1);
  for (i = 0; i < numSeeds; i++) {
    RandSrc_U_D(&tmp, &min, 1, &max, 1, state, 1, 1);
    seedArray[i] = (uint32_T)(tmp * 2.147483648E+9);
  }

  /* End of Start for S-Function (sdsprandsrc2): '<S1>/Random Source' */
};
void Noise_initialize()
{
  /* Registration code */

  /* initialize error status */
  // rtmSetErrorStatus(Noise_M, (NULL));

  /* block I/O */
  (void) memset(((void *) &Noise_B), 0,
                sizeof(BlockIO_Noise));

  /* states (dwork) */
  (void) memset((void *)&Noise_DWork, 0,
                sizeof(D_Work_Noise));

  /* external inputs */
  Noise_U->In1 = 0.0;

  /* external outputs */
  Noise_Y->Out1 = 0.0;
  
  /* Start for S-Function (sdsprandsrc2): '<S1>/Random Source' */
  RandSrcCreateSeeds_64((uint32_T)(100000 * rand()),
                        &Noise_DWork.RandomSource_SEED_DWORK, 1);
  RandSrcInitState_U_64(&Noise_DWork.RandomSource_SEED_DWORK,
                        Noise_DWork.RandomSource_STATE_DWORK, 1);
};
void p1_init(void)
{
   Noise_initialize();
	NOC_RNI_SEND(NOC_RNI_BASE,send_channel_p1_to_p2,p1_out0_priority,p1_out0_msg_len);
}
// *** DEFINE YOUR PROCESS INIT CODE ABOVE THIS LINE
// *** DEFINE YOUR PROCESS MAIN CODE BELOW THIS LINE
// *****************************************************************************************************************************************
// * 
// * Define the process main cycle function
// *
// *****************************************************************************************************************************************
void Noise_step()
{
  real_T accum;
  int32_T cfIdx;
  int32_T memIdx;
  int32_T j;
  int32_T nextMemIdx;

  /* S-Function (sdsprandsrc2): '<S1>/Random Source' */
  RandSrc_U_D(&Noise_B.RandomSource, &Noise_P.RandomSource_MinRTP, 1,
              &Noise_P.RandomSource_MaxRTP, 1,
              Noise_DWork.RandomSource_STATE_DWORK, 1, 1);

  /* S-Function (sdspfilter2): '<S1>/Digital Filter - Highpass' */
  cfIdx = 1;
  memIdx = 0;
  nextMemIdx = 0;
  Noise_B.DigitalFilterHighpass = Noise_B.RandomSource *
    Noise_P.DigitalFilterHighpass_RTP1COEFF[0] +
    Noise_DWork.DigitalFilterHighpass_FILT_STAT[0];
  for (j = 0; j < 18; j++) {
    accum = Noise_DWork.DigitalFilterHighpass_FILT_STAT[nextMemIdx + 1];
    nextMemIdx++;
    accum += Noise_B.RandomSource *
      Noise_P.DigitalFilterHighpass_RTP1COEFF[cfIdx];
    cfIdx++;
    Noise_DWork.DigitalFilterHighpass_FILT_STAT[memIdx] = accum;
    memIdx++;
  }

  /* End of S-Function (sdspfilter2): '<S1>/Digital Filter - Highpass' */

  /* Outport: '<Root>/Out1' incorporates:
   *  Inport: '<Root>/In1'
   *  Sum: '<S1>/Add'
   */
  Noise_Y->Out1 = Noise_B.DigitalFilterHighpass + Noise_U->In1;
};
void p1_main(void)
{
   Noise_step();
	NOC_RNI_SEND(NOC_RNI_BASE,send_channel_p1_to_p2,p1_out0_priority,p1_out0_msg_len);
}
// *** DEFINE YOUR PROCESS MAIN CODE ABOVE THIS LINE
