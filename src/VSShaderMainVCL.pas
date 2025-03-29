unit VSShaderMainVCL;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Skia, Vcl.Skia,
  Vcl.ExtCtrls, Vcl.StdCtrls,
  System.Types;

type
  TfrmVerySimpleShaderVCL = class(TForm)
    Memo1: TMemo;
    Splitter1: TSplitter;
    SkAnimatedPaintBox1: TSkAnimatedPaintBox;
    procedure FormCreate(Sender: TObject);
    procedure SkAnimatedPaintBox1AnimationDraw(ASender: TObject;
      const ACanvas: ISkCanvas; const ADest: TRectF;
      const AProgress: Double; const AOpacity: Single);
    procedure Memo1Exit(Sender: TObject);
  private
    { Private declarations }
    FShaderBuilder: ISkRuntimeShaderBuilder;
    FPaint: ISkPaint;
    procedure RunShader;
  public
    { Public declarations }
  end;

var
  frmVerySimpleShaderVCL: TfrmVerySimpleShaderVCL;

implementation

{$R *.dfm}

uses
  System.Math;

procedure TfrmVerySimpleShaderVCL.FormCreate(Sender: TObject);
begin
  SkAnimatedPaintBox1.Animation.Duration := MaxSingle;
  RunShader;
end;

procedure TfrmVerySimpleShaderVCL.Memo1Exit(Sender: TObject);
begin
  RunShader;
end;

procedure TfrmVerySimpleShaderVCL.RunShader;
var
  LEffect: ISkRuntimeEffect;
begin
  SkAnimatedPaintBox1.Animation.StopAtCurrent;
  FShaderBuilder := nil;
  FPaint := nil;
  var AErrorText := '';
  LEffect := TSkRuntimeEffect.MakeForShader(Memo1.Text, AErrorText);
  if AErrorText <> '' then
    raise Exception.Create(AErrorText);

  FShaderBuilder := TSkRuntimeShaderBuilder.Create(LEffect);
  FPaint := TSkPaint.Create;
  FPaint.Shader := FShaderBuilder.MakeShader;
  SkAnimatedPaintBox1.Animation.Start;
end;

procedure TfrmVerySimpleShaderVCL.SkAnimatedPaintBox1AnimationDraw(ASender: TObject;
  const ACanvas: ISkCanvas; const ADest: TRectF; const AProgress: Double;
  const AOpacity: Single);
begin
  if Assigned(FShaderBuilder) and Assigned(FPaint) then
  begin
    if FShaderBuilder.Effect.UniformExists('iResolution') then
    begin
      if FShaderBuilder.Effect.UniformTypeByName['iResolution'] in [TSkRuntimeEffectUniformType.Float3,
          TSkRuntimeEffectUniformType.Int3] then
        FShaderBuilder.SetUniform('iResolution', [ADest.Width, ADest.Height, 0])
      else
        FShaderBuilder.SetUniform('iResolution', [ADest.Width, ADest.Height]);
    end;
    if FShaderBuilder.Effect.UniformExists('iTime') then
      FShaderBuilder.SetUniform('iTime', AProgress * SkAnimatedPaintBox1.Animation.Duration);
    FPaint.Shader := FShaderBuilder.MakeShader;
    ACanvas.DrawRect(ADest, FPaint);
  end;
end;

end.
