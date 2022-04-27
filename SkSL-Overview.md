# Overview
<sub>[[Source](https://github.com/google/skia/blob/main/src/sksl/README)] [[Official Docs](https://skia.org/docs/user/sksl/)] [[Book of Shaders](https://thebookofshaders.com/)] [[Intro to Shader Programming](https://blog.grijjy.com/2021/01/14/shader-programming/)] [[Skia Shader Playground](https://shaders.skia.org/)] [[GLSL Shadertoy](https://www.shadertoy.com/)]</sub>

SkSL ("Skia Shading Language") is a variant of GLSL which is used as Skia's
internal shading language. SkSL is, at its heart, a single standardized version
of GLSL which avoids all of the various version and dialect differences found
in GLSL "in the wild", but it does bring a few of its own changes to the table.

Skia uses the SkSL compiler to convert SkSL code to GLSL, GLSL ES, or SPIR-V
before handing it over to the graphics driver.

## Differences from GLSL

* The entry point is `vec4 main( vec2 fragcoord )` instead of `void mainImage( out vec4 fragColor, in vec2 fragCoord )`,
  when translating you will need to change the fragColor assignment to a `return()` statement. 
* Macros (`#define`) are not supported. Either convert them to constats or functions.
* Precision modifiers are not used. `float`, `int`, and `uint` are always high
  precision. New types `half`, `short`, and `ushort` are medium precision (we
  do not use low precision).
* Vector types are named \<base type\>\<columns\>, so `float2` instead of `vec2` and
  `bool4` instead of `bvec4`
* Matrix types are named \<base type\>\<columns\>x\<rows\>, so `float2x3` instead of
  `mat2x3` and `double4x4` instead of `dmat4`.
* "`@if`" and "`@switch`" are static versions of `if` and `switch`. They behave exactly
  the same as if and switch in all respects other than it being a compile-time
  error to use a non-constant expression as a test.
* GLSL **caps** can be referenced via the syntax `sk_Caps.\<name\>`, e.g.
  `sk_Caps.canUseAnyFunctionInShader`. The value will be a constant `boolean` or `int`,
  as appropriate. As SkSL supports constant folding and branch elimination, this
  means that an `if` statement which statically queries a cap will collapse down
  to the chosen branch, meaning that:
```
    if (sk_Caps.externalTextureSupport)
        do_something();
    else
        do_something_else();
```
  will compile as if you had written either `do_something();` or
  `do_something_else();`, depending on whether that cap is enabled or not.
* No `#version` statement is required, and it will be ignored if present
* Use `sk_Position` instead of `gl_Position`. `sk_Position` is in device coordinates
  rather than normalized coordinates.
* Use `sk_PointSize` instead of `gl_PointSize`
* Use `sk_VertexID` instead of `gl_VertexID`
* Use sk_InstanceID instead of `gl_InstanceID`
* The fragment coordinate is `sk_FragCoord`, and is always relative to the upper
  left.
* Use `sk_Clockwise` instead of `gl_FrontFacing`. This is always relative to an
  upper left origin.
* You do not need to include `.0` to make a number a float (meaning that
  `float2(x, y) * 4` is perfectly legal in SkSL, unlike GLSL where it would
  often have to be expressed `float2(x, y) * 4.0`. There is no performance
  penalty for this, as the number is converted to a float at compile time)
* Type suffixes on numbers (`1.0f`, `0xFFu`) are both unnecessary and unsupported
* Creating a smaller vector from a larger vector (e.g. `float2(float3(1))`) is
  intentionally disallowed, as it is just a wordier way of performing a swizzle.
  Use swizzles instead.
* Swizzle components, in addition to the normal rgba / xyzw components, can also
  be LTRB (meaning "left/top/right/bottom", for when we store rectangles in
  vectors), and may also be the constants `0` or `1` to produce a constant 0 or
  1 in that channel instead of selecting anything from the source vector.
  `foo.rgb1` is equivalent to `float4(foo.rgb, 1)`.
* All texture functions are named "sample", e.g. sample(sampler2D, float3) is
  equivalent to GLSL's `textureProj(sampler2D, float3)`.
* Functions support the `inline` modifier, which causes the compiler to ignore
  its normal inlining heuristics and inline the function if at all possible
* Some built-in functions and one or two rarely-used language features are not
  yet supported (sorry!)
  
Refer to the [full documetation](https://skia.org/docs/user/sksl/) for more details.
