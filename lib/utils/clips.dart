import 'package:flutter/material.dart';

class CustomShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    /*final Path path = Path();
    path.lineTo(150.0, size.height - 300);
    var secondEndpoint = Offset(size.width, size.height - 100.0);
    var secondControlPoint = Offset(size.width * .10, size.height - 50);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndpoint.dx, secondEndpoint.dy);
    path.lineTo(size.width, 0.0);

    path.close();
    return path;*/
    Path path = Path();
    /* path.lineTo(0, size.height);
    path.quadraticBezierTo(
        size.width / 2, size.height - 100, size.width, size.height);
    path.lineTo(size.width, 0);*/
    path.moveTo(size.width / 4, 0.0);

    path.quadraticBezierTo(0.0, size.height / 4, 0.0, size.height / 2);
    path.quadraticBezierTo(0.0, size.height * 3 / 4, size.width / 3, size.height);

    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0.0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class CustomShapeClipper2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.lineTo(0.0, size.height - 105);
    var secondEndpoint = Offset(size.width, size.height - 40.0);
    var secondControlPoint = Offset(size.width * .50, size.height - 30);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndpoint.dx, secondEndpoint.dy);
    path.lineTo(size.width, 0.0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
