/*
 * File: Source.h
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

#ifndef RTW_HEADER_Source_h_
#define RTW_HEADER_Source_h_
#ifndef Source_COMMON_INCLUDES_
# define Source_COMMON_INCLUDES_
#include <stddef.h>
#include <math.h>
#include <string.h>
#include "rtwtypes.h"
#endif                                 /* Source_COMMON_INCLUDES_ */

#include "Source_types.h"

/* Macros for accessing real-time model data structure */
#ifndef rtmGetErrorStatus
# define rtmGetErrorStatus(rtm)        ((rtm)->errorStatus)
#endif

#ifndef rtmSetErrorStatus
# define rtmSetErrorStatus(rtm, val)   ((rtm)->errorStatus = (val))
#endif

/* Block states (auto storage) for system '<Root>' */
typedef struct {
  real_T SineWave1_AccFreqNorm;        /* '<S1>/Sine Wave1' */
} D_Work_Source;

/* External outputs (root outports fed by signals with auto storage) */
typedef struct {
  real_T Out1;                         /* '<Root>/Out1' */
} ExternalOutputs_Source;

/* Parameters (auto storage) */
struct Parameters_Source_ {
  real_T SineWave1_Amplitude;          /* Expression: Amplitude
                                        * Referenced by: '<S1>/Sine Wave1'
                                        */
  real_T SineWave1_Frequency;          /* Expression: Frequency
                                        * Referenced by: '<S1>/Sine Wave1'
                                        */
  real_T SineWave1_Phase;              /* Expression: Phase
                                        * Referenced by: '<S1>/Sine Wave1'
                                        */
};

/* Real-time Model Data Structure */
struct tag_RTM_Source {
  const char_T * volatile errorStatus;
};

/* Block parameters (auto storage) */
extern Parameters_Source Source_P;

/* Block states (auto storage) */
extern D_Work_Source Source_DWork;

/* External outputs (root outports fed by signals with auto storage) */
extern ExternalOutputs_Source Source_Y;

/* Model entry point functions */
extern void Source_initialize(void);
extern void Source_step(void);
extern void Source_terminate(void);

/* Real-time Model object */
extern RT_MODEL_Source *const Source_M;

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
 * hilite_system('fir_filter/Source')    - opens subsystem fir_filter/Source
 * hilite_system('fir_filter/Source/Kp') - opens and selects block Kp
 *
 * Here is the system hierarchy for this model
 *
 * '<Root>' : 'fir_filter'
 * '<S1>'   : 'fir_filter/Source'
 */
#endif                                 /* RTW_HEADER_Source_h_ */

/*
 * File trailer for generated code.
 *
 * [EOF]
 */
