#include <cmath>
#include <cstdlib>

#ifdef __APPLE__
#include <OpenGL/OpenGL.h>
#include <GLUT/GLUT.h>
#elif defined __linux__
#include <GL/gl.h>
#include <GL/glut.h>
#else
#error "unsupported platform"
#endif

static const double target_fps = 60.0;
static const double ms_per_frame = 1000.0 / target_fps;

bool paused;

void Tick() {
  ;
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
    gluOrtho2D(-1.1, 1.1, -1.1/ratio, 1.1/ratio);
  } else {
    gluOrtho2D(-ratio*1.1, ratio*1.1, -1.1, 1.1);
  }
  glMatrixMode(GL_MODELVIEW);
}

void Render() {
  glClearColor(0.0, 0.0, 0.0, 1.0);
  glClear(GL_COLOR_BUFFER_BIT);
  glColor3f(1.0, 1.0, 1.0);
  glBegin(GL_LINE_LOOP);
    glVertex2f(-1.0, -1.0);
    glVertex2f(-1.0,  1.0);
    glVertex2f( 1.0,  1.0);
    glVertex2f( 1.0, -1.0);
  glEnd();
  glutSwapBuffers();
}

void KeyDown(unsigned char key, int x, int y) {
  switch (key) {
    case 27:
      exit(0);
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
  paused = false;

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
  glutMainLoop();
}
