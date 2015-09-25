import 'dart:html';
import 'dart:math';

double xRange;
double yRange;

void plotLine(double m, double c){
  CanvasElement can = querySelector('#mainCan');
  var con = can.context2D;
  con..strokeStyle = '#FFF';
     ..beginPath();

  List <double> from = [xRange + 1, yRange + 1];
  List <double> to = [xRange + 1, yRange + 1];

  if(-xRange * m + c <= yRange && -xRange * m + c >= -yRange) {
    from[0] = -xRange;
    from[1] = -(-xRange * m + c);
  }
  if(xRange * m + c <= yRange & xRange  m + c >= -yRange) {
    if(from[0] = xRange + 1) {
      from[0] = xRange;
      from[1] = -(xRange * m + c);
    } else if(to[0] == xRange + 1) {
      to[0] = xRange;
      to[1] = -(xRange * m  + c);
    } 
  }
  if((yRange - c) / m <= xRange && (yRange - c) / m >= -xRange) {
    if(from[0] == xRange + 1) {
      from[0] = (yRange - c) / m;
      from[1] = -yRange;
    } else if(to[0] == xRange + 1) {
      to[0] = (yRange - c) / m;
      to[1] = -yRange;
    } 
  }
  if((-yRange - c) / m  <= xRange && (-yRange - c) / m >= -xRange) {
    if(from[0] == xRange + 1) {
      from[0] = (-yRange - c) / m;
      from[1] = yRange;
    } else if(to[0] == xRange + 1) {
      to[0] = (-yRange - c) / m;
      to[1] = yRange;
    }
  }
   con..moveTo(from[0], from[1]
      ..lineTo(to[0], to[1])
      ..stroke()
      ..closePath();
}

void plotCircle(double x, double y, double r) {
  CanvasElement can = querySelector('#mainCan');
  var con = can.context2D;
  con..strokeStyle = '#FFF'
     ..beginPath()
     ..arc(x, -y, r, 0, 2 * PI)
     ..closePath()
     ..stroke();
}

void plotHalfLine(double x, double y, double m, double c, bool dircn) {
  CanvasElement can = querySelector('#mainCan');
  var con = can.context2D;
  con..strokeStyle ='#FFF'
     ..beginPath()
     ..moveTo(x, -y);
  List <double> to = [xRange + 1, xRange + 1];

  if(-xRange * m + c <= yRange && -xRange * m + c >= -yRange && 
      !dircn) {
      to[0] = -xRange;
      to[1] = -(-xRange * m + c);
  }
  if(xRange * m + c <= yRange && xRange * m + c >= -yRange && dircn) { 
    to[0] = xRange;
    to[1] = -(xRange * m + c);
  }
  if((yRange - c) / m <= xRange && (yRange - c) / m >= -xRange &&
    (((yRange - c) / m < x && !dircn) || ((yRange - c) / m && dircn))) {      to[0] = (yRange - c) / m;
      to[1] = -yRange;
  }
  if((-yRange - c) / m <= xRange && (-yRange - c) / m >= -xRange &&
    (((-yRange - c) / m < x && !dircn) || 
     ((-yRange - c / m) > x && dircn))) {
       to[0] = (-yRange - c) / m;
       to[1] = yRange;
  }
  con..lineTo(to[0], to[1])
     ..stroke()
     ..closePath();
}

/*void plotArc(List <double> from, List <double> to, double r) {
  List <double> centre = [(from[0]+to[0]) / 2, (from[1]+to[1])/2)];
  double fromA = asin((from[1] - centre[1] */

main() {
  double screenSize = 500;
  CanvasElement can = querySelector('#mainCan');
  var context = can.context2D;
  for(double x = 10.5; x < gridSize; x += 10) {
    context..moveTo(x, 0)
           ..lineTo(x, gridSize)
           ..moveTo(0, x)
           ..lineTo(gridSize, x);
  } 
  context..stroke()
         ..closePath()
         ..beginPath()
         ..strokeStyle = '#29261F'
         ..lineWidth = 3
         ..moveTo(0, gridSize / 2)
         ..lineTo(gridSize, gridSize / 2)
         ..stroke()
         ..closePath()
         ..beginPath()
         ..moveTo(gridSize / 2, 0)
         ..lineTo(gridSize / 2, gridSize)
         ..stoke();
  xRange = gridSize / 2;
  yRange = gridSize / 2;
  context.translate(xRange, yRange);
}

