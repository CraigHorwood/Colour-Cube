library colourcube;
import 'dart:convert';
import 'dart:html';
import 'dart:math' as Math;
import 'dart:typed_data';
import 'dart:web_gl' as WebGL;
import 'package:vector_math/vector_math.dart';
part 'shader.dart';
CanvasElement canvas;
WebGL.RenderingContext gl;
Math.Random random = new Math.Random(400);
Float32List points;
bool initGL()
{
  canvas = document.getElementById("main_canvas");
  gl = canvas.getContext("webgl");
  if (gl == null) gl = canvas.getContext("experimental-webgl");
  if (gl != null)
  {
    gl.enable(WebGL.DEPTH_TEST);
    gl.depthFunc(WebGL.LESS);
    gl.clearColor(0.0, 0.0, 0.0, 1.0);
    return true;
  }
  return false;
}
bool mouseDown = false;
int lastX, lastY;
double xRot = 0.0, yRot = 0.0;
void initMain()
{
  lastX = canvas.width ~/ 2;
  lastY = canvas.height ~/ 2;
  canvas.onMouseDown.listen((e) {
    onMouseDown(e.offset.x, e.offset.y);
  });
  canvas.onMouseUp.listen((e) {
    onMouseUp();
  });
  canvas.onMouseMove.listen((e) {
    onMouseMove(e.offset.x, e.offset.y);
  });
  canvas.onTouchStart.listen((e) {
    onMouseDown(e.touches[0].page.x, e.touches[0].page.y);
  });
  canvas.onTouchEnd.listen((e) {
    onMouseUp();
  });
  canvas.onTouchMove.listen((e) {
    onMouseMove(e.touches[0].page.x, e.touches[0].page.y);
  });
  document.getElementById("url_submit").onClick.listen((e) {
    InputElement input = querySelector("#url_text");
    String url = input.value;
    if (!url.isEmpty) loadImage("http://cors.io/?u=" + url);
  });
  points = new Float32List(0);
  Matrix4 projectionMatrix = makePerspectiveMatrix(45.0 * Math.PI / 180.0, canvas.width / canvas.height, 0.01, 3.0);
  gl.uniformMatrix4fv(prLocation, false, projectionMatrix.storage);
}
void onMouseDown(int x, int y)
{
  mouseDown = true;
  lastX = x;
  lastY = y;
}
void onMouseUp()
{
  mouseDown = false;
}
void onMouseMove(int x, int y)
{
  if (mouseDown)
  {
    xRot += (y - lastY) * Math.PI / 180.0;
    yRot += (x - lastX) * Math.PI / 180.0;
    lastX = x;
    lastY = y;
  }
}
void trace(String msg)
{
  querySelector("#status").setInnerHtml("<p>" + msg + "</p>");
}
void loadImage(String url)
{
  try
  {
    trace("Getting image...");
    ImageElement img = new ImageElement();
    img.crossOrigin = "Anonymous";
    img.src = url;
    img.onLoad.listen((e) {
      CanvasElement c = new CanvasElement(width: img.width, height: img.height);
      CanvasRenderingContext2D context = c.getContext("2d");
      context.drawImage(img, 0, 0);
      List<int> pixels = context.getImageData(0, 0, canvas.width, canvas.height).data;
      List<bool> hasColours = new List<bool>(256 * 256 * 256);
      hasColours.fillRange(0, hasColours.length, false);
      for (int i = 0; i < pixels.length; i += 4)
      {
        int r = pixels[i];
        int g = pixels[i + 1];
        int b = pixels[i + 2];
        hasColours[(r << 16) | (g << 8) | b] = true;
      }
      trace("Finished reading image.");
      rebuildCube(hasColours);
    });
  }
  catch (e)
  {
    throw e;
  }
}
void rebuildCube(List<bool> hasColours)
{
  List<double> pointList = new List<double>();
  for (int y = 0; y < 256; y++)
  {
    for (int x = 0; x < 256; x++)
    {
      for (int z = 0; z < 256; z++)
      {
        if (hasColours[(x << 16) | (y << 8) | z]) pointList.addAll([x / 255.0 - 0.5, y / 255.0 - 0.5, z / 255.0 - 0.5]);
      }
    }
  }
  points = new Float32List.fromList(pointList);
  gl.bindBuffer(WebGL.ARRAY_BUFFER, gl.createBuffer());
  gl.bufferDataTyped(WebGL.ARRAY_BUFFER, points, WebGL.STATIC_DRAW);
  gl.vertexAttribPointer(posLocation, 3, WebGL.FLOAT, false, 0, 0);
}
void animate(double time)
{
  tick();
  render(time);
  window.requestAnimationFrame(animate);
}
void tick()
{
}
Matrix4 modelviewMatrix;
void render(double time)
{
  gl.viewport(0, 0, canvas.width, canvas.height);
  gl.clear(WebGL.COLOR_BUFFER_BIT | WebGL.DEPTH_BUFFER_BIT);
  modelviewMatrix = new Matrix4.identity();
  modelviewMatrix.translate(0.0, 0.0, -2.0);
  modelviewMatrix.rotate(new Vector3(1.0, 0.0, 0.0), xRot);
  modelviewMatrix.rotate(new Vector3(0.0, 1.0, 0.0), yRot);
  gl.uniformMatrix4fv(mvLocation, false, modelviewMatrix.storage);
  gl.drawArrays(WebGL.POINTS, 0, points.length ~/ 3);
}
void crashNoWebGL()
{
  querySelector("#main_canvas").remove();
  final NodeValidatorBuilder _htmlValidator = new NodeValidatorBuilder.common()..allowElement('a', attributes: ['href']);
  querySelector("#error_log").setInnerHtml("<pre>No WebGL support detected.\rPlease see <a href=\"http://get.webgl.org/\">get.webgl.org</a>.</pre>", validator: _htmlValidator);
}
void crash(e)
{
  querySelector("#main_canvas").remove();
  String message = new HtmlEscape().convert(e.toString());
  querySelector("#error_log").setInnerHtml("<pre><b>ERROR</b>\r\r$message</pre>");
}
void main()
{
  try
  {
    if (initGL())
    {
      initShaders();
      initMain();
      window.requestAnimationFrame(animate);
    }
    else crashNoWebGL();
  }
  catch (e)
  {
    crash(e);
    rethrow;
  }
}