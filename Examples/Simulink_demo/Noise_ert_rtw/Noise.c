/*
 * File: Noise.c
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

/* Block signals (auto storage) */
BlockIO_Noise Noise_B;

/* Block states (auto storage) */
D_Work_Noise Noise_DWork;

/* External inputs (root inport signals with auto storage) */
ExternalInputs_Noise Noise_U;

/* External outputs (root outports fed by signals with auto storage) */
ExternalOutputs_Noise Noise_Y;

/* Real-time model */
RT_MODEL_Noise Noise_M_;
RT_MODEL_Noise *const Noise_M = &Noise_M_;
void RandSrcInitState_U_64(const uint32_T seed[], real_T state[], int32_T nChans)
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
}

void RandSrc_U_D(real_T y[], const real_T minVec[], int32_T minLen, const real_T
                 maxVec[], int32_T maxLen, real_T state[], int32_T nChans,
                 int32_T nSamps)
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
}

void RandSrcCreateSeeds_64(uint32_T initSeed, uint32_T seedArray[], int32_T
  numSeeds)
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
}

/* Model step function */
void Noise_step(void)
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
  Noise_Y.Out1 = Noise_B.DigitalFilterHighpass + Noise_U.In1;
}

/* Model initialize function */
void Noise_initialize(void)
{
  /* Registration code */

  /* initialize error status */
  rtmSetErrorStatus(Noise_M, (NULL));

  /* block I/O */
  (void) memset(((void *) &Noise_B), 0,
                sizeof(BlockIO_Noise));

  /* states (dwork) */
  (void) memset((void *)&Noise_DWork, 0,
                sizeof(D_Work_Noise));

  /* external inputs */
  Noise_U.In1 = 0.0;

  /* external outputs */
  Noise_Y.Out1 = 0.0;
  
  /* Start for S-Function (sdsprandsrc2): '<S1>/Random Source' */
  RandSrcCreateSeeds_64((uint32_T)(100000 * rand()),
                        &Noise_DWork.RandomSource_SEED_DWORK, 1);
  RandSrcInitState_U_64(&Noise_DWork.RandomSource_SEED_DWORK,
                        Noise_DWork.RandomSource_STATE_DWORK, 1);
}

/* Model terminate function */
void Noise_terminate(void)
{
  /* (no terminate code required) */
}

/*
 * File trailer for generated code.
 *
 * [EOF]
 */
