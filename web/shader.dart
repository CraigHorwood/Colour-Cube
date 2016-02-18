part of colourcube;
WebGL.Program program;
int posLocation;
WebGL.UniformLocation prLocation, mvLocation;
void initShaders()
{
  String vertexShaderCode = """
    precision mediump float;
    attribute vec3 a_pos;
    uniform mat4 u_pr;
    uniform mat4 u_mv;
    varying vec3 v_pos;
    void main()
    {
      v_pos = a_pos + 0.5;
      vec4 pos = u_pr * u_mv * vec4(a_pos, 1.0);
      gl_Position = pos;
      gl_PointSize = 16.0 / pos.z;
    }
""";
  String fragmentShaderCode = """
    precision mediump float;
    varying vec3 v_pos;
    void main()
    {
      gl_FragColor = vec4(v_pos, 1.0);
    }
""";
  WebGL.Shader vertexShader = compileShader(vertexShaderCode, WebGL.VERTEX_SHADER);
  WebGL.Shader fragmentShader = compileShader(fragmentShaderCode, WebGL.FRAGMENT_SHADER);
  program = gl.createProgram();
  gl.attachShader(program, vertexShader);
  gl.attachShader(program, fragmentShader);
  gl.linkProgram(program);
  if (!gl.getProgramParameter(program, WebGL.LINK_STATUS)) throw gl.getProgramInfoLog(program);
  gl.useProgram(program);
  posLocation = gl.getAttribLocation(program, "a_pos");
  gl.enableVertexAttribArray(posLocation);
  prLocation = gl.getUniformLocation(program, "u_pr");
  mvLocation = gl.getUniformLocation(program, "u_mv");
}
WebGL.Shader compileShader(String source, int type)
{
  WebGL.Shader shader = gl.createShader(type);
  gl.shaderSource(shader, source);
  gl.compileShader(shader);
  if (!gl.getShaderParameter(shader, WebGL.COMPILE_STATUS)) throw gl.getShaderInfoLog(shader);
  return shader;
}