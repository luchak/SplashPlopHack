#ifndef PARTICLE_H_
#define PARTICLE_H_

#include <array>
#include <vector>

#include "aabb.h"
#include "math.h"

namespace SPHack {

static const int kMaxParticles= 1 << 16;

typedef int ParticleIDType;
typedef char ParticleFlagType;

static const ParticleFlagType PARTICLE_FLAG_ACTIVE = 1 << 0;

class ParticleSystem {
 public:
  explicit ParticleSystem(const AABB& bounds);

  void AddParticles(const AABB& region, Real radius);

  void ApplyForces(Real dt);
  void PredictPositions(Real dt);
  void EnforceConstraints();
  void UpdateVelocitiesAndCommit(Real dt); 

  void Step(Real dt);

  bool isActive(ParticleIDType pid) const { return (flag_[pid] & PARTICLE_FLAG_ACTIVE) != 0; }
  Vec2 pos(ParticleIDType pid) const { return pos_[pid]; }
  Real radius(ParticleIDType pid) const { return radius_[pid]; }
  int size() const { return kMaxParticles; }

 private:
  bool CreateParticle(const Vec2& pos, const Vec2& vel, Real radius);

  AABB bounds_;

  std::array<Vec2, kMaxParticles> pos_;
  std::array<Vec2, kMaxParticles> predicted_pos_;
  std::array<Vec2, kMaxParticles> vel_;
  std::array<Real, kMaxParticles> radius_;
  std::array<ParticleFlagType, kMaxParticles> flag_;
  std::vector<ParticleIDType> available_particles_;

  Vec2 gravity_;
};
  
}  // namespace SPHack

#endif  // PARTICLE_H_
