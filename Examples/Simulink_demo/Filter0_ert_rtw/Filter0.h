/*
 * File: Filter0.h
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

#ifndef RTW_HEADER_Filter0_h_
#define RTW_HEADER_Filter0_h_
#ifndef Filter0_COMMON_INCLUDES_
# define Filter0_COMMON_INCLUDES_
#include <stddef.h>
#include <string.h>
#include "rtwtypes.h"
#endif                                 /* Filter0_COMMON_INCLUDES_ */

#include "Filter0_types.h"

/* Macros for accessing real-time model data structure */
#ifndef rtmGetErrorStatus
# define rtmGetErrorStatus(rtm)        ((rtm)->errorStatus)
#endif

#ifndef rtmSetErrorStatus
# define rtmSetErrorStatus(rtm, val)   ((rtm)->errorStatus = (val))
#endif

/* Block states (auto storage) for system '<Root>' */
typedef struct {
  real_T DigitalFilterLowpass_FILT_STATE[17];/* '<S1>/Digital Filter - Lowpass' */
} D_Work_Filter0;

/* External inputs (root inport signals with auto storage) */
typedef struct {
  real_T In1;                          /* '<Root>/In1' */
} ExternalInputs_Filter0;

/* External outputs (root outports fed by signals with auto storage) */
typedef struct {
  real_T Out1;                         /* '<Root>/Out1' */
} ExternalOutputs_Filter0;

/* Parameters (auto storage) */
struct Parameters_Filter0_ {
  real_T DigitalFilterLowpass_RTP1COEFF[17];/* Expression: NumCoeffs
                                             * Referenced by: '<S1>/Digital Filter - Lowpass'
                                             */
};

/* Real-time Model Data Structure */
struct tag_RTM_Filter0 {
  const char_T * volatile errorStatus;
};

/* Block parameters (auto storage) */
extern Parameters_Filter0 Filter0_P;

/* Block states (auto storage) */
extern D_Work_Filter0 Filter0_DWork;

/* External inputs (root inport signals with auto storage) */
extern ExternalInputs_Filter0 Filter0_U;

/* External outputs (root outports fed by signals with auto storage) */
extern ExternalOutputs_Filter0 Filter0_Y;

/* Model entry point functions */
extern void Filter0_initialize(void);
extern void Filter0_step(void);
extern void Filter0_terminate(void);

/* Real-time Model object */
extern RT_MODEL_Filter0 *const Filter0_M;

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
 * hilite_system('fir_filter/Filter')    - opens subsystem fir_filter/Filter
 * hilite_system('fir_filter/Filter/Kp') - opens and selects block Kp
 *
 * Here is the system hierarchy for this model
 *
 * '<Root>' : 'fir_filter'
 * '<S1>'   : 'fir_filter/Filter'
 */
#endif                                 /* RTW_HEADER_Filter0_h_ */

/*
 * File trailer for generated code.
 *
 * [EOF]
 */
