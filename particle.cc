#include "particle.h"

#include <algorithm>
#include <iostream>

namespace SPHack {

ParticleSystem::ParticleSystem(const AABB& bounds) : bounds_(bounds) {
  available_particles_.reserve(kMaxParticles);
  for (int i = 0; i < kMaxParticles; ++i) {
    available_particles_.push_back(i);
  }

  gravity_ = Vec2(0.0, -1.0);
}

void ParticleSystem::AddParticles(const AABB& region, Real radius) {
  AABB clipped_region = bounds_.Intersect(region);

  for (Real x = clipped_region.min()[0] + radius; x < clipped_region.max()[0] - radius; x += 2*radius) {
    for (Real y = clipped_region.min()[1] + radius; y < clipped_region.max()[1] - radius; y += 2*radius) {
      if (CreateParticle(Vec2(x, y), Vec2(0.0, 0.0), radius)) {
        //std::cerr << "Created particle at: " << x << " " << y << std::endl;
      } else {
        //std::cerr << "Failed to create particle at: " << x << " " << y << std::endl;
      }
    }
 }
}

void ParticleSystem::ApplyForces(Real dt) {
  for (size_t i = 0; i < size(); ++i) {
    vel_[i] += gravity_ * dt;
  }
}

void ParticleSystem::PredictPositions(Real dt) {
  for (size_t i = 0; i < size(); ++i) {
    predicted_pos_[i] = dt * vel_[i] + pos_[i];
  }
}

void ParticleSystem::EnforceConstraints() {
  AABB shrunk_bounds = bounds_.Shrink(1e-5);

  for (size_t i = 0; i < size(); ++i) {
    predicted_pos_[i] = shrunk_bounds.Clip(predicted_pos_[i]);
  }
}

void ParticleSystem::UpdateVelocitiesAndCommit(Real dt) {
  for (size_t i = 0; i < size(); ++i) {
    vel_[i] = (predicted_pos_[i] - pos_[i]) * (1.0 / dt);
  }
  pos_.swap(predicted_pos_);
}

void ParticleSystem::Step(Real dt) {
  ApplyForces(dt);
  PredictPositions(dt);
  EnforceConstraints();
  UpdateVelocitiesAndCommit(dt);
}

bool ParticleSystem::CreateParticle(const Vec2& pos, const Vec2& vel, Real radius) {
  if (available_particles_.empty()) {
    return false;
  }

  ParticleIDType id = available_particles_.back();
  available_particles_.pop_back();
  pos_[id] = pos;
  vel_[id] = vel;
  radius_[id] = radius;
  flag_[id] = PARTICLE_FLAG_ACTIVE;

  return true;
}
  
}  // namespace SPHack
