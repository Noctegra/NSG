/*
 * File: Noise_data.c
 *
 * Code generated for Simulink model 'Noise'.
 *
 * Model version                  : 1.32
 * Simulink Coder version         : 8.4 (R2013a) 13-Feb-2013
 * TLC version                    : 8.4 (Jan 19 2013)
 * C/C++ source code generated on : Thu Apr 03 23:16:58 2014
 *
 * Target selection: ert.tlc
 * Embedded hardware selection: 32-bit Generic
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#include "Noise.h"
#include "Noise_private.h"

/* Block parameters (auto storage) */
Parameters_Noise Noise_P = {
  0.0,                                 /* Expression: MinVal
                                        * Referenced by: '<S1>/Random Source'
                                        */
  4.0,                                 /* Expression: MaxVal
                                        * Referenced by: '<S1>/Random Source'
                                        */

  /*  Expression: NumCoeffs
   * Referenced by: '<S1>/Digital Filter - Highpass'
   */
  { -0.0051, 0.0181, -0.0069, -0.0283, -0.0061, 0.0549, 0.0579, -0.0826, -0.2992,
    0.5946, -0.2992, -0.0826, 0.0579, 0.0549, -0.0061, -0.0283, -0.0069, 0.0181,
    -0.0051 }
};

/*
 * File trailer for generated code.
 *
 * [EOF]
 */
