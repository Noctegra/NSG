/*
 * File: Noise_private.h
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

#ifndef RTW_HEADER_Noise_private_h_
#define RTW_HEADER_Noise_private_h_
#include "rtwtypes.h"
#ifndef __RTWTYPES_H__
#error This file requires rtwtypes.h to be included
#else
#ifdef TMWTYPES_PREVIOUSLY_INCLUDED
#error This file requires rtwtypes.h to be included before tmwtypes.h
#else

/* Check for inclusion of an incorrect version of rtwtypes.h */
#ifndef RTWTYPES_ID_C08S16I32L32N32F1
#error This code was generated with a different "rtwtypes.h" than the file included
#endif                                 /* RTWTYPES_ID_C08S16I32L32N32F1 */
#endif                                 /* TMWTYPES_PREVIOUSLY_INCLUDED */
#endif                                 /* __RTWTYPES_H__ */

extern void RandSrcInitState_U_64(const uint32_T seed[], real_T state[], int32_T
  nChans);
extern void RandSrc_U_D(real_T y[], const real_T minVec[], int32_T minLen, const
  real_T maxVec[], int32_T maxLen, real_T state[], int32_T nChans, int32_T
  nSamps);
extern void RandSrcCreateSeeds_64(uint32_T initSeed, uint32_T seedArray[],
  int32_T numSeeds);

#endif                                 /* RTW_HEADER_Noise_private_h_ */

/*
 * File trailer for generated code.
 *
 * [EOF]
 */
