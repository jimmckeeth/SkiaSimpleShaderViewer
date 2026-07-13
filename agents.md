# SkiaSimpleShaderViewer – Agent Guidance

## Project purpose and product shape
- This repository is a **demo collection** for Skia shaders in Delphi: simple code samples, visible shader power, and best-practice direction.
- The main user-facing workflow is in `SimpleShader`: browse `.sksl` shaders, edit source, recompile at runtime, and view animated output.
- `VerySimpleFMXShader` and `VerySimpleVCLShader` are intentionally minimal teaching demos. Keep them small and direct.

## Project variants and ownership boundaries
- `SimpleShader.dproj` (FMX): full sample viewer and primary reference for richer behaviors.
- `VerySimpleFMXShader.dproj` (FMX): minimal one-form runtime shader sample.
- `VerySimpleVCLShader.dproj` (VCL): minimal one-form runtime shader sample in VCL.

Boundary rule:
- Put richer UX/workflow changes in `SimpleShaderMain.pas` / `SimpleShaderMain.fmx`.
- Do **not** backport feature growth into VerySimple variants unless explicitly requested.

## Startup and runtime invariants
- `SimpleShader.dpr` sets Skia globals before app init (`GlobalUseSkia := True`, `GlobalUseMetal := True`, `GlobalUseSkiaRasterWhenAvailable := False`). Preserve this ordering unless there is a concrete platform reason.
- `VerySimpleFMXShader.dpr` enables `GlobalUseSkia := True` and creates `TfrmVerySimpleShaderFMX`.
- `VerySimpleVCLShader.dpr` uses normal VCL startup and creates `TfrmVerySimpleShaderVCL`.

Runtime shader invariants (`SimpleShaderMain.pas`):
- Shader source from `Memo1` is compiled with `TSkRuntimeEffect.MakeForShader` in `RunShader`.
- Uniform wiring is dynamic and name-based (`iResolution`, `iTime`, optional `iImage1`, `iImage1Resolution`); preserve this compatibility style when adding uniforms.
- Draw loop is driven through `SkAnimatedPaintBox1AnimationDraw` and `TSkRuntimeShaderBuilder.MakeShader`.

## Coupled files and fragile mappings
- Form code and designer files are paired and must stay synchronized:
  - `SimpleShaderMain.pas` <-> `SimpleShaderMain.fmx`
  - `VSShaderMainFMX.pas` <-> `VSShaderMainFMX.fmx`
  - `VSShaderMainVCL.pas` <-> `VSShaderMainVCL.dfm`
- Event handler renames/removals must be reflected in the form file event properties (`OnAnimationDraw`, `OnExit`, click handlers, etc.).
- Shader sample text is intentionally embedded in form resources (`Lines.Strings` in `.fmx/.dfm`) for demo readability; avoid moving this to a heavier content system unless requested.

## Paths, resources, and deployment assumptions
- `SimpleShaderMain.pas` path helpers (`ShaderPath`, `MediaPath`, `MediaTexturesPath`) assume specific layout and platform behavior (desktop relative paths, mobile documents path, macOS resources).
- Changes to shader/media folder layout must be treated as deployment-sensitive work and validated across target platforms.
- Main shader discovery path is file-based (`TDirectory.GetFiles(ShaderPath, '*.sksl')`), so folder naming and deployment packaging are functional behavior, not cosmetic structure.

## Change playbooks

### 1) Add or update shader runtime behavior in `SimpleShader`
Edit:
- `SimpleShaderMain.pas`: `RunShader`, `SkAnimatedPaintBox1AnimationDraw`, relevant input handlers.
- `SimpleShaderMain.fmx`: controls/events only if UI wiring changes.

Keep in sync:
- Uniform-name expectations between shader code and runtime setters.
- Optional texture child handling (`iImage1`) and resolution uniforms.

Verify:
- Shader compiles from memo and from file load.
- Animation updates (`iTime`) and resolution updates (`iResolution`) still render correctly.

### 2) Add demo shaders/content
Edit:
- `shaders/` files (`*.sksl`) for main catalog behavior.
- Embedded memo text in VerySimple form files only when intentionally changing minimal starter sample.

Keep in sync:
- Demo descriptions/expectations in `README.md` when user-visible behavior changes.

Verify:
- New shader appears in `lbShaders` list for `SimpleShader` and compiles.

### 3) Change VerySimple demos
Edit:
- FMX: `VSShaderMainFMX.pas` and `VSShaderMainFMX.fmx`
- VCL: `VSShaderMainVCL.pas` and `VSShaderMainVCL.dfm`

Rules:
- Keep logic form-local and straightforward (`RunShader` + draw callback + memo edit trigger).
- Do not introduce architecture layers or feature parity goals with `SimpleShader` unless asked.

## Dependencies and tooling signals
- Core dependency is Skia4Delphi usage through `FMX.Skia` / `Vcl.Skia` and runtime effect APIs.
- `.dproj` files contain large package/reference lists; when a task requires touching a `.dproj`, clean obviously unused/noisy references in the edited project file conservatively.

## Testing and verification
- No dedicated test project (DUnit/DUnitX) was found in this repo.
- Default verification is project compile/build for the touched app variant(s):
  - `SimpleShader.dproj`
  - `VerySimpleFMXShader.dproj`
  - `VerySimpleVCLShader.dproj`
- Prefer compile verification plus focused code-path checks over broad refactors.

## Known code pitfalls (preserve awareness)
- `SimpleShaderMain.pas` `TfrmShaderView.SkAnimatedPaintBox1MouseMove` checks `FShaderBuilder.Effect.UniformExists('iMouse')` before `Assigned(FShaderBuilder)`. If `FShaderBuilder` is nil, this can AV. If touching this handler, reorder the condition to check `Assigned(FShaderBuilder)` first.
- `SimpleShaderMain.pas` `LoadShaders` always sets `lbShaders.ItemIndex := 0` and calls `LoadSelectedShader`. If `ShaderPath` exists but contains zero `.sksl` files, `LoadSelectedShader` indexes an empty list. Guard empty-list behavior before selecting index 0.

## Conventions to preserve
- Unit and type naming are straightforward and demo-oriented; avoid churn-only renames.
- Keep demo code readable over abstract.
- Preserve keyboard/UX behavior documented in `README.md` when modifying `SimpleShader` interactions.

## Caveats / uncertainties
- Workspace tooling can intermittently report root-path glob/search issues; use project-aware file operations and explicit file paths.
- Platform packaging details should be treated carefully when changing shader/media path logic, even if only one desktop target is being edited.