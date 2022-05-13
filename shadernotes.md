Textures are images, it is simple to use them. You need to download the image, then declare your uniform of type shader, like “uniform shader iChannel0;”

In your code you can load a the image in a SkImage and convert it do shader by calling “YourSKImage.MakeShader(TSkSamplingOptions.High);”

Then pass it to your shader code as input, since it's a uniform (ie an input of your shader code).

declare the uniforms in first line of your sksl code:

uniform shader iChannel0;
uniform shader iChannel1;
uniform shader iChannel2;

After make your runtime effect by calling: TSkRuntimeEffect.MakeForShader(SKSL code), inform the input parameters of your shader (that is, all the uniforms he will use).

For shader uniforms, like your iChannel0, iChannel1 and iChannel2, you need to call:

FRuntimeEffect.ChildrenShaders['iChannel0'] := TSkImage.MakeFromEncodedFile('iChannel0.png').MakeShader(TSkSamplingOptions.High);

All others uniform types (like "uniform vec2 iResolution;"), you need to inform by calling:

FRuntimeEffect.SetUniform('iResolution', [Width, Height]);

“texture(“ is the function to read a pixel.

The "texture(iChannel0, rd).rgb;" can be replaced by “iChannel0.eval(rd).rgb;” 

but now the parameter rd is wrong because texture( function use percentage parameter (0..1, 0..1), and “eval(“ function use the pixel coordinates parameter (0..iChannel0 width, 0..iChannel0 height)

How can we fix the parameter value in eval function?

Multiplying to the image size. So I declare a new uniform like:

“uniform float2 iImage1Resolution;”

And change the eval line to:
iImage1.eval(rd.xy * iImage1Resolution.xy).rgb;

Shadertoy downloads
https://shadertoyunofficial.wordpress.com/2019/07/23/shadertoy-media-files/