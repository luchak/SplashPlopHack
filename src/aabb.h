#ifndef AABB_H_
#define AABB_H_

#include <algorithm>

#include "math.h"

namespace SPHack {

class AABB {
 public:
  AABB() : min_(0.0, 0.0), max_(0.0, 0.0) { }
  AABB(const Vec2& min, const Vec2& max) : min_(min), max_(max) { }

  inline Vec2 Clip(const Vec2& point) const {
    return Vec2(std::min(max_[0], std::max(min_[0], point[0])),
                std::min(max_[1], std::max(min_[1], point[1])));
  }

  inline AABB Shrink(Real margin) const {
    return AABB(min_ + Vec2(margin, margin), max_ - Vec2(margin, margin));
  }

  inline AABB Intersect(const AABB& other) const {
    return AABB(Clip(other.min_), Clip(other.max_));
  }

  inline bool Intersects(const AABB& other) const {
    bool x_overlap = !((min_[0] > other.max_[0]) || (max_[0] < other.min_[0]));
    bool y_overlap = !((min_[1] > other.max_[1]) || (max_[1] < other.min_[1]));
    return x_overlap && y_overlap;
  }

  inline bool IsInside(const Vec2& point) const {
    bool x_inside = (min_[0] <= point[0]) && (max_[1] >= point[0]);
    bool y_inside = (min_[0] <= point[1]) && (max_[1] >= point[1]);
    return x_inside && y_inside;
  }

  inline const Vec2& min() const { return min_; }
  inline const Vec2& max() const { return max_; }

  inline Vec2 size() const { return max_ - min_; }
  inline Real width() const { return max_[0] - min_[0]; }
  inline Real height() const { return max_[1] - min_[1]; }

 private:
  Vec2 min_;
  Vec2 max_;
};

}  // namespace SPHack

#endif  // AABB_H_
