#ifndef MATH_H_
#define MATH_H_

namespace SPHack {

typedef float Real;

struct Vec2 {
   Vec2() : x(0.0), y(0.0) { }
   Vec2(Real x_in, Real y_in) : x(x_in), y(y_in) { }

   inline Real operator[](size_t idx) const {
     switch(idx) {
       case 0:
         return x;
         break;

       case 1:
         return y;
         break;

       default:
         break;
     }

     return 0.0;
   }

   Real x;
   Real y;
};

inline Vec2 operator+(const Vec2& a, const Vec2& b) { return Vec2(a.x + b.x, a.y + b.y); }
inline Vec2 operator-(const Vec2& a, const Vec2& b) { return Vec2(a.x - b.x, a.y - b.y); }
inline Vec2 operator*(const Vec2& a, Real b) { return Vec2(a.x * b, a.y * b); }
inline Vec2 operator*(Real a, const Vec2& b) { return b*a; }
inline Vec2 operator/(const Vec2& a, Real b) { return Vec2(a.x / b, a.y / b); }
inline Vec2 operator-(const Vec2& a) { return Vec2(-a.x, -a.y); }

inline bool operator==(const Vec2& a, const Vec2& b) { return (a.x == b.x) && (a.y == b.y); }
inline bool operator!=(const Vec2& a, const Vec2& b) { return !(a == b); }

inline Vec2& operator+=(Vec2& a, const Vec2& b) {
  a.x += b.x;
  a.y += b.y;
  return a;
}

inline Vec2& operator-=(Vec2& a, const Vec2& b) {
  a.x -= b.x;
  a.y -= b.y;
  return a;
}

inline Vec2& operator*=(Vec2& a, Real b) {
  a.x *= b;
  a.y *= b;
  return a;
}

inline Vec2& operator/=(Vec2& a, Real b) {
  a.x *= b;
  a.y *= b;
  return a;
}


}  // namespace SPHack

#endif  // MATH_H_
