#include "../../math/const.glsl"

// Henyey-Greenstein phase function factor [-1, 1]
// represents the average cosine of the scattered directions
// 0 is isotropic scattering
// > 1 is forward scattering, < 1 is backwards
#ifndef HENYEYGREENSTEIN_SCATTERING
#define HENYEYGREENSTEIN_SCATTERING 0.76
#endif

#ifndef FNC_HENYEYGREENSTEIN
#define FNC_HENYEYGREENSTEIN
float henyeyGreenstein(float mu) {
    return max(0.0, (1.0 - HENYEYGREENSTEIN_SCATTERING*HENYEYGREENSTEIN_SCATTERING) / ((4. + PI) * pow(1.0 + HENYEYGREENSTEIN_SCATTERING*HENYEYGREENSTEIN_SCATTERING - 2.0 * HENYEYGREENSTEIN_SCATTERING * mu, 1.5)));
}
#endif