#include "kernels.h"

#include <cmath>

namespace SPHack {

KernelEvaluator::KernelEvaluator(Real h) : h_(h) {
  h2_ = h*h;
  const Real h3 = h2_*h;
  const Real h6 = h3*h3;
  const Real h9 = h6*h3;
  poly6_norm_ = 315.0 / (64.0 * M_PI * h9);
  spiky_grad_norm_ = -45.0 / (M_PI * h6);
}
  
}  // namespace SPHack
