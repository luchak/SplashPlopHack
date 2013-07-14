#ifndef PARTICLE_H_
#define PARTICLE_H_

#include <array>
#include <memory>
#include <random>
#include <vector>

#include "aabb.h"
#include "kernels.h"
#include "math.h"
#include "particle_types.h"

namespace SPHack {

static const int kMaxParticles= 1 << 12;

static const ParticleFlagType PARTICLE_FLAG_ACTIVE = 1 << 0;

struct PressureParticle {
  Vec2 pos;
  Vec2 pos_delta;

  Real lambda;

  ParticleIDType id;
};

class ParticleSystem {
 public:
  ParticleSystem(const AABB& bounds, Real radius);

  void AddParticles(const AABB& region);

  void Step(Real dt);

  bool isActive(ParticleIDType pid) const { return (flag_[pid] & PARTICLE_FLAG_ACTIVE) != 0; }
  Vec2 pos(ParticleIDType pid) const { return pos_[pid]; }
  Vec2 predicted_pos(ParticleIDType pid) const { return predicted_pos_[pid]; }
  Real radius() const { return radius_; }
  int size() const { return kMaxParticles; }
  const AABB& bounds() const { return bounds_; }
  Real density(ParticleIDType pid) const { return density_[pid]; }

  void setGravity(const Vec2& gravity) { gravity_ = gravity; }

  void InitDensity();

 private:
  bool CreateParticle(const Vec2& pos, const Vec2& vel);

  void ApplyForces(Real dt);
  void PredictPositions(Real dt);
  void UpdateVelocities(Real dt); 
  void CommitPositions();

  void BuildGrid();
  Real CalculateParticleLambda(const PressureParticle& pi, int x, int y);
  void CalculateLambdaOnGrid();
  Vec2 CalculateParticlePressureDelta(const PressureParticle& pj, int x, int y);
  void AccumulatePressureDelta(PressureParticle& pi, PressureParticle& pj);
  void CalculatePressureDeltaOnGrid();
  void ApplyPressureDeltaOnGrid();
  void EnforceBoundariesOnGrid();
  void CopyPositionsFromGrid();
  void ApplyViscosityOnGrid(Real dt);

  inline int CellID(int x, int y) const { return y*grid_width_ + x; }

  AABB bounds_;

  Real radius_;
  Real radius2_;
  KernelEvaluator kernel_;
  std::array<Vec2, kMaxParticles> pos_;
  std::array<Vec2, kMaxParticles> predicted_pos_;
  std::array<Vec2, kMaxParticles> vel_;
  std::array<Real, kMaxParticles> density_;
  std::array<ParticleFlagType, kMaxParticles> flag_;
  std::vector<ParticleIDType> available_particles_;

  Real grid_delta_;
  std::vector<std::vector<PressureParticle>> grid_;
  int grid_width_;
  int grid_height_;

  Real cfm_epsilon_;
  Real density_inv_;

  Vec2 gravity_;

  Real boundary_margin_;

  std::mt19937 random_;
  std::uniform_real_distribution<> jitter_dist_;
};
  
}  // namespace SPHack

#endif  // PARTICLE_H_
