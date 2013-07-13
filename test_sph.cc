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

  double ratio = 1.0 * w / h;

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  glViewport(0, 0, w, h);
  //gluPerspective(45.0, ratio, 5.0, 1000.0);
  if (ratio < 1.0) {
    gluOrtho2D(-0.1, 1.1, -0.1/ratio, 1.1/ratio);
  } else {
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
      glColor3f(density-1.0, 1.0-fabs(1.0-density), 1.0-density);
      DrawCircle(ps->pos(i)[0], ps->pos(i)[1], ps->radius()/2.0);
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
}

int main(int argc, char* argv[]) {
  paused = true;

  glutInit(&argc, argv);
  glutInitDisplayMode(GLUT_DEPTH | GLUT_DOUBLE | GLUT_RGBA);
  glutInitWindowPosition(100, 100);
  glutInitWindowSize(800, 800);
  glutCreateWindow("GLUT");

  glutReshapeFunc(&Reshape);
  glutDisplayFunc(&Render);

  glutKeyboardFunc(&KeyDown);

  glutMouseFunc(&MouseButton);

  glutTimerFunc(0, &TimedIdle, 0);

  ps.reset(
      new SPHack::ParticleSystem(
          SPHack::AABB(SPHack::Vec2(0.0, 0.0), SPHack::Vec2(1.0, 1.0)),
          0.03));
  ps->AddParticles(SPHack::AABB(SPHack::Vec2(0.0, 0.0), SPHack::Vec2(0.3, 0.7)));
  ps->InitDensity();

  glutMainLoop();
}
