/*
 * File: Filter0.c
 *
 * Code generated for Simulink model 'Filter0'.
 *
 * Model version                  : 1.32
 * Simulink Coder version         : 8.4 (R2013a) 13-Feb-2013
 * TLC version                    : 8.4 (Jan 19 2013)
 * C/C++ source code generated on : Thu Apr 03 23:16:15 2014
 *
 * Target selection: ert.tlc
 * Embedded hardware selection: 32-bit Generic
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#include "Filter0.h"
#include "Filter0_private.h"

/* Block states (auto storage) */
D_Work_Filter0 Filter0_DWork;

/* External inputs (root inport signals with auto storage) */
ExternalInputs_Filter0 Filter0_U;

/* External outputs (root outports fed by signals with auto storage) */
ExternalOutputs_Filter0 Filter0_Y;

/* Real-time model */
RT_MODEL_Filter0 Filter0_M_;
RT_MODEL_Filter0 *const Filter0_M = &Filter0_M_;

/* Model step function */
void Filter0_step(void)
{
  real_T accum;
  int32_T cfIdx;
  int32_T memIdx;
  int32_T j;
  int32_T nextMemIdx;

  /* S-Function (sdspfilter2): '<S1>/Digital Filter - Lowpass' */
  cfIdx = 1;
  memIdx = 0;
  nextMemIdx = 0;

  /* Outport: '<Root>/Out1' incorporates:
   *  Inport: '<Root>/In1'
   *  S-Function (sdspfilter2): '<S1>/Digital Filter - Lowpass'
   */
  Filter0_Y.Out1 = Filter0_U.In1 * Filter0_P.DigitalFilterLowpass_RTP1COEFF[0] +
    Filter0_DWork.DigitalFilterLowpass_FILT_STATE[0];

  /* S-Function (sdspfilter2): '<S1>/Digital Filter - Lowpass' incorporates:
   *  Inport: '<Root>/In1'
   */
  for (j = 0; j < 16; j++) {
    accum = Filter0_DWork.DigitalFilterLowpass_FILT_STATE[nextMemIdx + 1];
    nextMemIdx++;
    accum += Filter0_U.In1 * Filter0_P.DigitalFilterLowpass_RTP1COEFF[cfIdx];
    cfIdx++;
    Filter0_DWork.DigitalFilterLowpass_FILT_STATE[memIdx] = accum;
    memIdx++;
  }
}

/* Model initialize function */
void Filter0_initialize(void)
{
  /* Registration code */

  /* initialize error status */
  rtmSetErrorStatus(Filter0_M, (NULL));

  /* states (dwork) */
  (void) memset((void *)&Filter0_DWork, 0,
                sizeof(D_Work_Filter0));

  /* external inputs */
  Filter0_U.In1 = 0.0;

  /* external outputs */
  Filter0_Y.Out1 = 0.0;
}

/* Model terminate function */
void Filter0_terminate(void)
{
  /* (no terminate code required) */
}

/*
 * File trailer for generated code.
 *
 * [EOF]
 */
