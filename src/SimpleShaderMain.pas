unit SimpleShaderMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, StrUtils, Math,
  FMX.Memo.Types, FMX.StdCtrls, FMX.Controls.Presentation, FMX.ScrollBox,
  FMX.Memo, FMX.TabControl, Skia, Skia.FMX, FMX.Layouts, FMX.MultiView;

type
  TForm14 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    OpenDialog1: TOpenDialog;
    Button2: TButton;
    Panel2: TPanel;
    SpeedButton1: TSpeedButton;
    MultiView1: TMultiView;
    SkAnimatedPaintBox1: TSkAnimatedPaintBox;
    SpeedButton2: TSpeedButton;
    Splitter1: TSplitter;
    procedure Button1Click(Sender: TObject);
    procedure SkAnimatedPaintBox1AnimationDraw(ASender: TObject;
      const ACanvas: ISkCanvas; const ADest: TRectF;
      const AProgress: Double; const AOpacity: Single);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure Splitter1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single);
    procedure Splitter1DblClick(Sender: TObject);
    procedure SkAnimatedPaintBox1MouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Single);
  private
    { Private declarations }
    FShader: ISkRuntimeEffect;
    FPaint: ISkPaint;
    procedure RunShader;
  public
    { Public declarations }
  end;

var
  Form14: TForm14;

implementation

{$R *.fmx}

procedure TForm14.RunShader;
begin
  SkAnimatedPaintBox1.Animate := False;
  FShader := nil;
  FPaint := nil;
  var AErrorText := '';
  FShader := TSkRuntimeEffect.MakeForShader(Memo1.Text, AErrorText);
  if AErrorText<>'' then
    raise Exception.Create(AErrorText);

  FPaint := TSkPaint.Create;
  Fpaint.Shader := Fshader.MakeShader(True);
  SkAnimatedPaintBox1.Duration := Double.MaxValue; // Run forever!
  SkAnimatedPaintBox1.Redraw;
  SkAnimatedPaintBox1.Animate := True;
end;

procedure TForm14.SkAnimatedPaintBox1AnimationDraw(ASender: TObject;
  const ACanvas: ISkCanvas; const ADest: TRectF; const AProgress: Double;
  const AOpacity: Single);
begin
  if Assigned(FShader) and Assigned(FPaint) then
  begin
    if FShader.UniformExists('iResolution') then
      FShader.SetUniform('iResolution', PointF(ADest.Width, ADest.Height));
    if FShader.UniformExists('iTime') then
      FShader.SetUniform('iTime', AProgress * SkAnimatedPaintBox1.Duration );
    ACanvas.DrawRect(ADest, FPaint);
  end;
end;

procedure TForm14.SkAnimatedPaintBox1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Single);
begin
  if FShader.UniformExists('iMouse') then
    FShader.SetUniform('iMouse', [X, Y, 0, Math.IfThen(ssLeft in Shift, 1, 0)]);
end;

procedure TForm14.Button1Click(Sender: TObject);
begin
  RunShader;
end;

procedure TForm14.Button2Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    Memo1.Lines.LoadFromFile(OpenDialog1.FileName);
    Memo1.Lines.Text := Memo1.Lines.Text.Replace(#9, #32);
    RunShader;
    MultiView1.HideMaster;
  end;
end;

procedure TForm14.FormCreate(Sender: TObject);
begin
  MultiView1.Mode := TMultiViewMode.Drawer;
  RunShader;
end;

procedure TForm14.SpeedButton2Click(Sender: TObject);
begin
  MultiView1.HideMaster;
end;

procedure TForm14.Splitter1DblClick(Sender: TObject);
begin
  MultiView1.HideMaster;
end;

procedure TForm14.Splitter1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Single);
begin
  if ssLeft in Shift then
  begin
    var coord := Splitter1.LocalToAbsolute(TPointF.Create(x,y));
    MultiView1.Width := coord.X;
  end;
end;

end.
