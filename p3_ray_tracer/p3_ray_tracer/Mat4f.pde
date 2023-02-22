public class Mat4f {
  private float[][] data = new float[4][4];

  public Mat4f(float[][] data) {
    copyData(data);
  }

  public Mat4f(Mat4f other) {  //Copy constructor
    copyData(other.data);
  }

  public Mat4f() {
    this(new float[4][4]);
  }

  private void copyData(float[][] data) {
    if (data.length != 4 || data[0].length != 4) {
      throw new IllegalArgumentException("Matrix data must be 4x4");
    }

    this.data = new float[4][4];
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        this.data[i][j] = data[i][j];
      }
    }
  }

  public Mat4f multiply(Mat4f other) {
    Mat4f result = new Mat4f();
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        float sum = 0;
        for (int k = 0; k < 4; k++) {
          sum += data[i][k] * other.data[k][j];
        }

        result.data[i][j] = sum;
      }
    }

    return result;
  }

  public Float3 multiply(Float3 other, float w) {
    //Assumes 4th coordinate is a 1
    float newX = data[0][0]*other.x + data[0][1]*other.y + data[0][2]*other.z + w * data[0][3];
    float newY = data[1][0]*other.x + data[1][1]*other.y + data[1][2]*other.z + w * data[1][3];
    float newZ = data[2][0]*other.x + data[2][1]*other.y + data[2][2]*other.z + w * data[2][3];

    return new Float3(newX, newY, newZ);
  }
  
  public Point3 multiply(Point3 other) {
    //Assumes 4th coordinate is a 0
    Float3 result = multiply(other, 1f);

    return new Point3(result.x, result.y, result.z);
  }
  
  public Vector3 multiply(Vector3 other) {
    Float3 result = multiply(other, 0f);
    
    return new Vector3(result.x, result.y, result.z);
  }

  public Mat4f transpose() {
    return new Mat4f(new float[][] {
      {data[0][0], data[1][0], data[2][0], data[3][0]},
      {data[0][1], data[1][1], data[2][1], data[3][1]},
      {data[0][2], data[1][2], data[2][2], data[3][2]},
      {data[0][3], data[1][3], data[2][3], data[3][3]},
    });
  }
  
  public Mat4f invert() {
    PMatrix3D pMat = new PMatrix3D(data[0][0], data[0][1], data[0][2], data[0][3],
                                data[1][0], data[1][1], data[1][2], data[1][3],
                                data[2][0], data[2][1], data[2][2], data[2][3],
                                data[3][0], data[3][1], data[3][2], data[3][3]);
    if (!pMat.invert()) {
      println("Matrix cannot be inverted because it is singular");
    }
    
    return new Mat4f(new float[][] {
      {pMat.m00, pMat.m01, pMat.m02, pMat.m03},
      {pMat.m10, pMat.m11, pMat.m12, pMat.m13},
      {pMat.m20, pMat.m21, pMat.m22, pMat.m23},
      {pMat.m30, pMat.m31, pMat.m32, pMat.m33}
    });
  }

  public String toString() {
    String[] strs = new String[4];
    for (int i = 0; i < 4; i++) {
      strs[i] = String.format("(%.2f, %.2f, %.2f, %.2f)", data[i][0], data[i][1], data[i][2], data[i][3]);
    }

    return String.join("\n", strs[0], strs[1], strs[2], strs[3]);
  }
}

public Mat4f matIdentity() {
  return new Mat4f(new float[][] {
    {1, 0, 0, 0},
    {0, 1, 0, 0},
    {0, 0, 1, 0},
    {0, 0, 0, 1}
    });
}

public Mat4f matTranslate(float x, float y, float z) {
  return new Mat4f(new float[][] {
    {1, 0, 0, x},
    {0, 1, 0, y},
    {0, 0, 1, z},
    {0, 0, 0, 1}
    });
}

public Mat4f matScale(float sx, float sy, float sz) {
  return new Mat4f(new float[][] {
    {sx, 0, 0, 0},
    {0, sy, 0, 0},
    {0, 0, sz, 0},
    {0, 0, 0, 1}
    });
}

public Mat4f matRotateX(float angle) {
  float c = cos(DEG2RAD * angle);
  float s = sin(DEG2RAD * angle);

  return new Mat4f(new float[][] {
    {1, 0, 0, 0},
    {0, c, -s, 0},
    {0, s, c, 0},
    {0, 0, 0, 1}
    });
}

public Mat4f matRotateY(float angle) {
  float c = cos(DEG2RAD * angle);
  float s = sin(DEG2RAD * angle);

  return new Mat4f(new float[][] {
    {c, 0, s, 0},
    {0, 1, 0, 0},
    {-s, 0, c, 0},
    {0, 0, 0, 1}
    });
}

public Mat4f matRotateZ(float angle) {
  float c = cos(DEG2RAD * angle);
  float s = sin(DEG2RAD * angle);

  return new Mat4f(new float[][] {
    {c, -s, 0, 0},
    {s, c, 0, 0},
    {0, 0, 1, 0},
    {0, 0, 0, 1}
    });
}
