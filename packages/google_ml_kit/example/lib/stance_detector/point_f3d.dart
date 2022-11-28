class PointF3D {
  final double x;
  final double y;
  final double z;

  PointF3D(this.x, this.y, this.z);

  factory PointF3D.from(
    double x,
    double y,
    double z,
  ) {
    return PointF3D(x, y, z);
  }

  double getX() {
    return x;
  }
  double getY() {
    return y;
  }
  double getZ() {
    return z;
  }
}
