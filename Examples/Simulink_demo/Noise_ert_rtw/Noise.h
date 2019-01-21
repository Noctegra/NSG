/*
 * File: Noise.h
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

#ifndef RTW_HEADER_Noise_h_
#define RTW_HEADER_Noise_h_
#ifndef Noise_COMMON_INCLUDES_
# define Noise_COMMON_INCLUDES_
#include <math.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include "rtwtypes.h"
#include "stdlib.h"
#endif                                 /* Noise_COMMON_INCLUDES_ */

#include "Noise_types.h"

/* Macros for accessing real-time model data structure */
#ifndef rtmGetErrorStatus
# define rtmGetErrorStatus(rtm)        ((rtm)->errorStatus)
#endif

#ifndef rtmSetErrorStatus
# define rtmSetErrorStatus(rtm, val)   ((rtm)->errorStatus = (val))
#endif

/* Block signals (auto storage) */
typedef struct {
  real_T RandomSource;                 /* '<S1>/Random Source' */
  real_T DigitalFilterHighpass;        /* '<S1>/Digital Filter - Highpass' */
} BlockIO_Noise;

/* Block states (auto storage) for system '<Root>' */
typedef struct {
  real_T DigitalFilterHighpass_FILT_STAT[19];/* '<S1>/Digital Filter - Highpass' */
  real_T RandomSource_STATE_DWORK[35]; /* '<S1>/Random Source' */
  uint32_T RandomSource_SEED_DWORK;    /* '<S1>/Random Source' */
} D_Work_Noise;

/* External inputs (root inport signals with auto storage) */
typedef struct {
  real_T In1;                          /* '<Root>/In1' */
} ExternalInputs_Noise;

/* External outputs (root outports fed by signals with auto storage) */
typedef struct {
  real_T Out1;                         /* '<Root>/Out1' */
} ExternalOutputs_Noise;

/* Parameters (auto storage) */
struct Parameters_Noise_ {
  real_T RandomSource_MinRTP;          /* Expression: MinVal
                                        * Referenced by: '<S1>/Random Source'
                                        */
  real_T RandomSource_MaxRTP;          /* Expression: MaxVal
                                        * Referenced by: '<S1>/Random Source'
                                        */
  real_T DigitalFilterHighpass_RTP1COEFF[19];/* Expression: NumCoeffs
                                              * Referenced by: '<S1>/Digital Filter - Highpass'
                                              */
};

/* Real-time Model Data Structure */
struct tag_RTM_Noise {
  const char_T * volatile errorStatus;
};

/* Block parameters (auto storage) */
extern Parameters_Noise Noise_P;

/* Block signals (auto storage) */
extern BlockIO_Noise Noise_B;

/* Block states (auto storage) */
extern D_Work_Noise Noise_DWork;

/* External inputs (root inport signals with auto storage) */
extern ExternalInputs_Noise Noise_U;

/* External outputs (root outports fed by signals with auto storage) */
extern ExternalOutputs_Noise Noise_Y;

/* Model entry point functions */
extern void Noise_initialize(void);
extern void Noise_step(void);
extern void Noise_terminate(void);

/* Real-time Model object */
extern RT_MODEL_Noise *const Noise_M;

/*-
 * The generated code includes comments that allow you to trace directly
 * back to the appropriate location in the model.  The basic format
 * is <system>/block_name, where system is the system number (uniquely
 * assigned by Simulink) and block_name is the name of the block.
 *
 * Note that this particular code originates from a subsystem build,
 * and has its own system numbers different from the parent model.
 * Refer to the system hierarchy for this subsystem below, and use the
 * MATLAB hilite_system command to trace the generated code back
 * to the parent model.  For example,
 *
 * hilite_system('fir_filter/Noise')    - opens subsystem fir_filter/Noise
 * hilite_system('fir_filter/Noise/Kp') - opens and selects block Kp
 *
 * Here is the system hierarchy for this model
 *
 * '<Root>' : 'fir_filter'
 * '<S1>'   : 'fir_filter/Noise'
 */
#endif                                 /* RTW_HEADER_Noise_h_ */

/*
 * File trailer for generated code.
 *
 * [EOF]
 */
