unit VSShaderMainFMX;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  System.Skia, FMX.Memo.Types, FMX.Controls.Presentation, FMX.ScrollBox,
  FMX.Memo, FMX.Skia, FMX.StdCtrls;

type
  TfrmVerySimpleShaderFMX = class(TForm)
    SkAnimatedPaintBox1: TSkAnimatedPaintBox;
    Memo1: TMemo;
    Splitter1: TSplitter;
    procedure SkAnimatedPaintBox1AnimationDraw(ASender: TObject;
      const ACanvas: ISkCanvas; const ADest: TRectF;
      const AProgress: Double; const AOpacity: Single);
    procedure FormCreate(Sender: TObject);
    procedure Splitter1DblClick(Sender: TObject);
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
  frmVerySimpleShaderFMX: TfrmVerySimpleShaderFMX;

implementation

{$R *.fmx}

uses
  System.Math;

procedure TfrmVerySimpleShaderFMX.FormCreate(Sender: TObject);
begin
  SkAnimatedPaintBox1.Animation.Duration := MaxSingle;
  RunShader;
end;

procedure TfrmVerySimpleShaderFMX.Memo1Exit(Sender: TObject);
begin
  RunShader;
end;

procedure TfrmVerySimpleShaderFMX.RunShader;
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

procedure TfrmVerySimpleShaderFMX.SkAnimatedPaintBox1AnimationDraw(ASender: TObject;
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

procedure TfrmVerySimpleShaderFMX.Splitter1DblClick(Sender: TObject);
begin
  Memo1.Visible := not Memo1.Visible;
end;

end.
