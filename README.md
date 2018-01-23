# Colour-Cube

This is a WebGL experiment which creates 3D "colour maps" of any image.

The red channel is the X axis, the green channel is the Y axis, and the blue channel is the Z axis. If the image imported contains a specific combination of red, green, and blue, a coloured square is rendered in the corresponding position in the colour cube. Many interesting shapes happen.

Renders pretty fast, even when rendering literally millions of squares. It's just GL_POINTS, so it's no surprise.

Uses [cors.io](http://cors.io) for now, so you can import images from other websites. Only sometimes works as a result.

[View the app](http://www.craighorwood.com/code/cube)
