unit SimpleShaderMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, StrUtils, Math,
  FMX.Memo.Types, FMX.StdCtrls, FMX.Controls.Presentation, FMX.ScrollBox,
  FMX.Memo, FMX.TabControl, Skia, Skia.FMX, FMX.Layouts, FMX.MultiView,
  FMX.ListBox, FMX.Ani, FMX.Effects;

type
  TfrmShaderView = class(TForm)
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
    SpeedButton3: TSpeedButton;
    lbShaders: TListBox;
    SkSvg1: TSkSvg;
    FloatAnimation1: TFloatAnimation;
    ShadowEffect1: TShadowEffect;
    Splitter2: TSplitter;
    ckMouse: TCheckBox;
    Button3: TButton;
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
    procedure SpeedButton3Click(Sender: TObject);
    procedure lbShadersItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
  private
    { Private declarations }
    FEffect: ISkRuntimeEffect;
    FShader: ISkShader;
    FPaint: ISkPaint;
    procedure RunShader;
    procedure LoadShaders;
    procedure LoadShader(const AShaderFile: string);
  public
    { Public declarations }
  end;

var
  frmShaderView: TfrmShaderView;

implementation

{$R *.fmx}

uses
  IOUtils;

const
  ShaderPath = '..\..\..\Shaders';
  ShaderExt = '.sksl';

procedure TfrmShaderView.RunShader;
begin
  SkAnimatedPaintBox1.Animate := False;
  FEffect := nil;
  FPaint := nil;
  var AErrorText := '';
  FEffect := TSkRuntimeEffect.MakeForShader(Memo1.Text, AErrorText);
  if AErrorText<>'' then
    raise Exception.Create(AErrorText);

  FPaint := TSkPaint.Create;
  Fpaint.Shader := FEffect.MakeShader(True);

  if FEffect.UniformExists('iImage1') then
  begin
    var image1: ISkImage := TSkImage.MakeFromEncodedFile(
      'C:\Users\Jim\Desktop\Skia4Delphi Webinar\Demo\SimpleShader\media\cubemaps\cubemap4\488bd40303a2e2b9a71987e48c66ef41f5e937174bf316d3ed0e86410784b919_5.jpg');

    FEffect.ChildrenShaders['iImage1'] := image1.MakeShader(TSKSamplingOptions.High);
    if FEffect.UniformExists('iImage1Resolution') then
      case FEffect.UniformType['iImage1Resolution'] of
        TSkRuntimeEffectUniformType.Float2:
            FEffect.SetUniform('iImage1Resolution', [image1.Width, image1.Height]);
        TSkRuntimeEffectUniformType.Float3:
            FEffect.SetUniform('iImage1Resolution', [image1.Width, image1.Height, 0]);
      end;
  end;

  SkAnimatedPaintBox1.Duration := Double.MaxValue; // Run forever!
  SkAnimatedPaintBox1.Redraw;
  SkAnimatedPaintBox1.Animate := True;
end;

procedure TfrmShaderView.SkAnimatedPaintBox1AnimationDraw(ASender: TObject;
  const ACanvas: ISkCanvas; const ADest: TRectF; const AProgress: Double;
  const AOpacity: Single);
begin
  if Assigned(FEffect) and Assigned(FPaint) then
  begin
    if FEffect.UniformExists('iResolution') then
      FEffect.SetUniform('iResolution', PointF(ADest.Width, ADest.Height));
    if FEffect.UniformExists('iTime') then
      FEffect.SetUniform('iTime', AProgress * SkAnimatedPaintBox1.Duration );
    ACanvas.DrawRect(ADest, FPaint);
  end;
end;

procedure TfrmShaderView.SkAnimatedPaintBox1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Single);
begin
  if ckMouse.IsChecked and FEffect.UniformExists('iMouse') then
    FEffect.SetUniform('iMouse', [X, Y, 0, Math.IfThen(ssLeft in Shift, 1, 0)]);
end;

procedure TfrmShaderView.Button1Click(Sender: TObject);
begin
  RunShader;
end;

procedure TfrmShaderView.LoadShader(const AShaderFile: string);
begin
  Memo1.Lines.LoadFromFile(AShaderFile);
  Memo1.Lines.Text := Memo1.Lines.Text.Replace(#9, #32);
  RunShader;
  MultiView1.HideMaster;
end;

procedure TfrmShaderView.Button2Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    LoadShader(OpenDialog1.FileName);
  end;
end;

procedure TfrmShaderView.FormCreate(Sender: TObject);
begin
  LoadShaders;
  MultiView1.Mode := TMultiViewMode.Drawer;
end;

procedure TfrmShaderView.lbShadersItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin
  LoadShader(TPath.Combine(ShaderPath,Item.Text+ShaderExt));
end;

procedure TfrmShaderView.LoadShaders;
begin
  if not TDirectory.Exists(ShaderPath) then
  begin
    lbShaders.Visible := False;
    Splitter2.Visible := False;
    exit;
  end;

  var Shaders := TDirectory.GetFiles(ShaderPath,'*'+ShaderExt);
  for var shader in shaders do
  begin
    lbShaders.Items.Add(TPath.GetFileNameWithoutExtension(Shader));
  end;
  if lbShaders.Count > 0 then
  begin
    //lbShaders.ItemIndex := random(lbShaders.Count);
    lbShaders.ItemIndex := lbShaders.Items.IndexOf('Playing marble');
    LoadShader(TPath.Combine(ShaderPath,lbShaders.Items[lbShaders.ItemIndex]+ShaderExt));
  end;
end;

procedure TfrmShaderView.SpeedButton2Click(Sender: TObject);
begin
  MultiView1.HideMaster;
end;

procedure TfrmShaderView.SpeedButton3Click(Sender: TObject);
begin
  if BorderStyle = TFmxFormBorderStyle.Sizeable then
  begin
    FormStyle := TFormStyle.StayOnTop;
    BorderStyle := TFmxFormBorderStyle.None;
    WindowState := TWindowState.wsMaximized;
  end
  else
  begin
    Close;
  end;

end;

procedure TfrmShaderView.Splitter1DblClick(Sender: TObject);
begin
  MultiView1.HideMaster;
end;

procedure TfrmShaderView.Splitter1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Single);
begin
  if ssLeft in Shift then
  begin
    var coord := Splitter1.LocalToAbsolute(TPointF.Create(x,y));
    MultiView1.Width := coord.X;
  end;
end;

end.
