import 'dart:math';

import './point_f3d.dart';

class PoseMath {
  static double distance3D(PointF3D a, PointF3D b) {
    final dx = a.x - b.x;
    final dy = a.y - b.y;
    final dz = a.z - b.z;
    return sqrt((dx * dx) + (dy * dy) + (dz * dz));
  }

  static double distance2D(PointF3D a, PointF3D b) {
    final dx = b.x - a.x;
    final dy = b.y - a.y;
    return sqrt((dx * dx) + (dy * dy));
  }

  static double hypot(double x, double y) {
    var first = x.abs();
    var second = y.abs();

    if (y > x) {
      first = y.abs();
      second = x.abs();
    }

    if (first == 0.0) {
      return second;
    }

    final t = second / first;
    return first * sqrt(1.0 + t * t);
  }

  static PointF3D add(PointF3D a, PointF3D b) {
    return PointF3D.from(a.getX() + b.getX(), a.getY() + b.getY(), a.getZ() + b.getZ());
  }

  static PointF3D subtract(PointF3D b, PointF3D a) {
    return PointF3D.from(a.getX() - b.getX(), a.getY() - b.getY(), a.getZ() - b.getZ());
  }

  static PointF3D multiplyX(PointF3D a, double multiple) {
    return PointF3D.from(a.getX() * multiple, a.getY() * multiple, a.getZ() * multiple);
  }

  static PointF3D multiply(PointF3D a, PointF3D multiple) {
    return PointF3D.from(a.getX() * multiple.getX(), a.getY() * multiple.getY(), a.getZ() * multiple.getZ());
  }

  static PointF3D average(PointF3D a, PointF3D b) {
    return PointF3D.from((a.getX() + b.getX()) * 0.5, (a.getY() + b.getY()) * 0.5, (a.getZ() + b.getZ()) * 0.5);
  }

  static double l2Norm2D(PointF3D point) {
    return PoseMath.hypot(point.getX(), point.getY());
  }

  static double maxAbs(PointF3D point) {
    return max(point.getX().abs(), max(point.getY().abs(), point.getZ().abs()));
  }

  static double sumAbs(PointF3D point) {
    return point.getX().abs() + point.getY().abs() + point.getZ().abs();
  }

  static List<PointF3D> addAll(List<PointF3D> pointsList, PointF3D p) {
    return pointsList.map((e) => PoseMath.add(e, p)).toList();
    // ListIterator<PointF3D> iterator = pointsList.listIterator();
    // while (iterator.hasNext()) {
    //   iterator.set(add(iterator.next(), p));
    // }
  }

  //
  static List<PointF3D> subtractAll(PointF3D p, List<PointF3D> pointsList) {
    return pointsList.map((e) => subtract(p, e)).toList();
    // var iterator = pointsList.iterator;
    // while (iterator.moveNext()) {
    //   iterator.set(subtract(p, iterator.next()));
    // }
  }

  //
  static List<PointF3D> multiplyAllX(List<PointF3D> pointsList, double multiple) {
    return pointsList.map((e) => multiplyX(e, multiple)).toList();
    // var iterator = pointsList.iterator;
    // while (iterator.moveNext()) {
    //   iterator.set(multiply(iterator.next(), multiple));
    // }
  }

  //
  static List<PointF3D> multiplyAll(List<PointF3D> pointsList, PointF3D multiple) {
    return pointsList.map((e) => multiply(e, multiple)).toList();
    // var iterator = pointsList.iterator;
    // while (iterator.moveNext()) {
    //   iterator.set(multiply(iterator.next(), multiple));
    // }
  }
}
