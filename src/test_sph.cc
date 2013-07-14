#include <cmath>
#include <cstdlib>
#//include <iostream>
#//include <memory>

#ifdef __APPLE__
#include <OpenGL/OpenGL.h>
#include <GLUT/GLUT.h>
#elif defined __linux__
#include <GL/gl.h>
#include <GL/glut.h>
#else
#error "unsupported platform"
#endif

#include <google/profiler.h>

#include "aabb.h"
#include "math.h"
#include "particle.h"

static const double target_fps = 60.0;
static const double ms_per_frame = 1000.0 / target_fps;

bool paused;
std::unique_ptr<SPHack::ParticleSystem> ps;
int window_w;
int window_h;
float world_x_min;
float world_y_min;
float world_x_size;
float world_y_size;
int selected_particle;

void Tick() {
  ps->Step(1.0 / target_fps);
}

void TimedIdle(int flag) {
  // needs better resolution timer
  int start = glutGet(GLUT_ELAPSED_TIME);
  if (!paused) {
    Tick();
  }
  int end = glutGet(GLUT_ELAPSED_TIME);

  glutPostRedisplay();
  int delay_ms = round(ms_per_frame - (end - start));
  glutTimerFunc(delay_ms > 0 ? delay_ms : 0, &TimedIdle, 0);
}

void DrawCircle(float center_x, float center_y, float radius) {
  glPushMatrix();
  glTranslatef(center_x, center_y, 0.0);
  glBegin(GL_TRIANGLE_FAN);
  glVertex2f(0.0, 0.0);
  for (int i = 0; i <= 12; ++i) {
    glVertex2f(cos(i * (M_PI / 6.0))*radius, sin(i * (M_PI / 6.0))*radius); 
  }
  glEnd();
  glPopMatrix();
}

void Reshape(int w, int h) {
  if (h == 0) {
    h = 1;
  }

  window_w = w;
  window_h = h;

  double ratio = 1.0 * w / h;

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  glViewport(0, 0, w, h);
  //gluPerspective(45.0, ratio, 5.0, 1000.0);
  if (ratio < 1.0) {
    world_x_min = -0.1;
    world_y_min = -0.1/ratio;
    world_x_size = 1.2;
    world_y_size = 1.2/ratio;
    gluOrtho2D(-0.1, 1.1, -0.1/ratio, 1.1/ratio);
  } else {
    world_y_min = -0.1;
    world_x_min = -0.1*ratio;
    world_y_size = 1.2;
    world_x_size = 1.2*ratio;
    gluOrtho2D(-ratio*0.1, ratio*1.1, -0.1, 1.1);
  }
  glMatrixMode(GL_MODELVIEW);
}

void Render() {
  glClearColor(0.0, 0.0, 0.0, 1.0);
  glClear(GL_COLOR_BUFFER_BIT);
  glColor3f(1.0, 1.0, 1.0);
  glBegin(GL_LINE_LOOP);
    glVertex2f(0.0, 0.0);
    glVertex2f(0.0,  1.0);
    glVertex2f(1.0, 1.0);
    glVertex2f(1.0, 0.0);
  glEnd();

  for (int i = 0; i < ps->size(); ++i) {
    if (ps->isActive(i)) {
      SPHack::Real density = ps->density(i);
      if (i == selected_particle) {
        glColor3f(1.0, 1.0, 1.0);
      } else {
        glColor3f(density-1.0, 1.0-fabs(1.0-density), 1.0-density);
      }
      DrawCircle(ps->pos(i)[0], ps->pos(i)[1], ps->radius()/4.0);
    }
  }

  glutSwapBuffers();
}

void KeyDown(unsigned char key, int x, int y) {
  switch (key) {
    case 27:
      ProfilerFlush();
      exit(0);
      break;

    case 'n':
      Tick();
      break;

    case ' ':
      paused = !paused;
      break;

    default:
      break;
  }
}

void MouseButton(int button, int state, int x, int y) {
  if (state == GLUT_DOWN) {
    float world_x = x*world_x_size / window_w + world_x_min;
    float world_y = (window_h - y)*world_y_size / window_h + world_y_min;
    SPHack::Vec2 world_pos(world_x, world_y);

    selected_particle = -1;
    float closest_sq_dist = 1e20;
    for (int i = 0; i < ps->size(); ++i) {
      if (ps->isActive(i)) {
        SPHack::Real sq_dist = (world_pos - ps->pos(i)).squaredNorm();
        
        if (sq_dist < closest_sq_dist) {
          closest_sq_dist = sq_dist;
          selected_particle = i;
        }
      }
    }

    std::cerr << "clicked particle id " << selected_particle << std::endl;
  }
}

int main(int argc, char* argv[]) {
  paused = true;

  glutInit(&argc, argv);
  glutInitDisplayMode(GLUT_DEPTH | GLUT_DOUBLE | GLUT_RGBA);
  glutInitWindowPosition(100, 100);
  window_w = 1000;
  window_h = 1000;
  glutInitWindowSize(window_w, window_h);
  glutCreateWindow("SPHack");

  glutReshapeFunc(&Reshape);
  glutDisplayFunc(&Render);

  glutKeyboardFunc(&KeyDown);

  glutMouseFunc(&MouseButton);

  glutTimerFunc(0, &TimedIdle, 0);

  ps.reset(
      new SPHack::ParticleSystem(
          SPHack::AABB(SPHack::Vec2(0.0, 0.0), SPHack::Vec2(1.0, 1.0)),
          0.016));
  ps->AddParticles(SPHack::AABB(SPHack::Vec2(0.0, 0.0), SPHack::Vec2(0.3, 0.7)));
  ps->InitDensity();
  ps->Clear();
  ps->AddParticles(SPHack::AABB(SPHack::Vec2(0.0, 0.0), SPHack::Vec2(0.3, 0.7)));

  Reshape(window_w, window_h);
  selected_particle = -1;

  glutMainLoop();
}
