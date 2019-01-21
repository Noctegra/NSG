/*
 * File: Source.c
 *
 * Code generated for Simulink model 'Source'.
 *
 * Model version                  : 1.32
 * Simulink Coder version         : 8.4 (R2013a) 13-Feb-2013
 * TLC version                    : 8.4 (Jan 19 2013)
 * C/C++ source code generated on : Thu Apr 03 23:17:23 2014
 *
 * Target selection: ert.tlc
 * Embedded hardware selection: 32-bit Generic
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#include "Source.h"
#include "Source_private.h"

/* Block states (auto storage) */
D_Work_Source Source_DWork;

/* External outputs (root outports fed by signals with auto storage) */
ExternalOutputs_Source Source_Y;

/* Real-time model */
RT_MODEL_Source Source_M_;
RT_MODEL_Source *const Source_M = &Source_M_;

/* Model step function */
void Source_step(void)
{
  /* Outport: '<Root>/Out1' incorporates:
   *  S-Function (sdspsine2): '<S1>/Sine Wave1'
   */
  Source_Y.Out1 = Source_P.SineWave1_Amplitude * sin
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
}

/* Model initialize function */
void Source_initialize(void)
{
  /* Registration code */

  /* initialize error status */
  rtmSetErrorStatus(Source_M, (NULL));

  /* states (dwork) */
  (void) memset((void *)&Source_DWork, 0,
                sizeof(D_Work_Source));

  /* external outputs */
  Source_Y.Out1 = 0.0;

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
}

/* Model terminate function */
void Source_terminate(void)
{
  /* (no terminate code required) */
}

/*
 * File trailer for generated code.
 *
 * [EOF]
 */
