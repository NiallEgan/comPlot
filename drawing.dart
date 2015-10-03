//import 'dart:html';
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
   con..moveTo(from[0], from[1])
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

void plotArc(double theta, List<double> start, List<double> end, 
     bool cl) {
  double startA;
  double endA;
  double r;
  double x1 = start[0];
  double x2 = end[0];
  double y1 = start[1];
  double y2 = end[1];
  if(theta != 2 * PI) {
    r = sqrt((pow(x1 - x2, 2) + pow(y1 - y2, 2)) / 
        (2 * (1 - cos(theta))));
    endA = atan((x2 - x1) / (y1 - y2)) + theta / 2;
    if(!cl) startA = endA - theta;
    else startA = endA + theta;
  } else {
    r = sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2)) / 2;
    startA = 0;
    endA = 2 * PI;
  } 
  List <double> centre = [x1 - r * cos(startA), y1 - r * sin(startA)]; 
  canvasElement can = querySelector('#mainCan');
  var con = can.context2D;
  double i;
  if(endA < startA) {
    con.moveTo(r * cos(endA) + centre[0], -r * sin(endA) - centre[1]);
    // To avoid the drawing of the base line
    for(i = endA; i <= startA; i += 0.1) {
      con..lineTo(r * cos(i) + centre[0], -r * sin(i) - centre[1])
         ..moveTo(r * cos(i) + centre[0], -r * sin(i) - centre[1]);
    }
  } else {
    con..moveTo(r * cos(startA) + centre[0], - r * sin(i) - centre[1])
    for(i = startA; i <= endA; i += 0.1) {
      con..lineTo(r * cos(i) + centre[0], -r * sin(i) - centre[1])
         ..moveTo(r * cos(i) + centre[0], -r * sin(i) - centre[1]);
    }
  }
  con..closePath()
    ..stroke();
}


main() {
/*  double screenSize = 500;
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
  context.translate(xRange, yRange);*/
  plotArc(PI, [0, 0], [0, 4]);
}

