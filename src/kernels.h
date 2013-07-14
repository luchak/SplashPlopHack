#ifndef KERNELS_H_
#define KERNELS_H_

#include <algorithm>

#include "math.h"

namespace SPHack {

class KernelEvaluator {
 public:
  KernelEvaluator(Real h);

  inline Real Poly6NonNorm(const Vec2& r) const {
    const Real t = h2_ - r.squaredNorm();
    return std::max(static_cast<Real>(0.0), t*t*t);
  }

  inline Real Poly6(const Vec2& r) const {
    const Real t = h2_ - r.squaredNorm();
    return std::max(static_cast<Real>(0.0), t*t*t*poly6_norm_);
  }

  inline Real Poly6(const Vec2& pi, const Vec2& pj) const {
    return Poly6(pi - pj);
  }

  inline Vec2 SpikyGradNonNorm(const Vec2& r) const {
    Real r_len = std::max(r.norm(), static_cast<Real>(1e-8));
    const Real t = h_ - r_len;
    if (t <= 0.0) {
      return Vec2(0.0, 0.0);
    } else {
      return r*(t*t/r_len);
    }
  }

  inline Vec2 SpikyGrad(const Vec2& r) const {
    Real r_len = std::max(r.norm(), static_cast<Real>(1e-8));
    const Real t = h_ - r_len;
    if (t <= 0.0) {
      return Vec2(0.0, 0.0);
    } else {
      return r*(t*t*spiky_grad_norm_/r_len);
    }
  }

  inline Vec2 SpikyGrad(const Vec2& pi, const Vec2& pj) {
    return SpikyGrad(pi - pj);
  }

  inline Real poly6_norm() const { return poly6_norm_; }
  inline Real spiky_grad_norm() const { return spiky_grad_norm_; }

 private:
  Real h_;
  Real h2_;
  Real poly6_norm_;
  Real spiky_grad_norm_;
};
  
}  // namespace SPHack

#endif  // KERNELS_H_
