unit SimpleShaderMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, StrUtils, Math,
  FMX.Memo.Types, FMX.StdCtrls, FMX.Controls.Presentation, FMX.ScrollBox,
  FMX.TabControl, Skia, FMX.Skia, FMX.Layouts, FMX.MultiView,
  FMX.ListBox, FMX.Ani, FMX.Effects, FMX.Objects, FMX.Memo;

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
    ckMouse: TCheckBox;
    Button3: TButton;
    Splitter2: TSplitter;
    RectangleKeys: TRectangle;
    SkLabel1: TSkLabel;
    RectangleFps: TRectangle;
    LabelFPS: TSkLabel;
    AnimateKeys: TFloatAnimation;
    SaveDialog1: TSaveDialog;
    SkSvg1: TSkSvg;
    FloatAnimation1: TFloatAnimation;
    ShadowEffect1: TShadowEffect;
    procedure Button1Click(Sender: TObject);
    procedure SkAnimatedPaintBox1AnimationDraw(ASender: TObject;
      const ACanvas: ISkCanvas; const ADest: TRectF;
      const AProgress: Double; const AOpacity: Single);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
    procedure SpeedButton2Click(Sender: TObject);
    procedure Splitter1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single);
    procedure Splitter1DblClick(Sender: TObject);
    procedure SkAnimatedPaintBox1MouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Single);
    procedure SpeedButton3Click(Sender: TObject);
    procedure lbShadersItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
    procedure RectangleFpsClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure SkAnimatedPaintBox1Resize(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure SkAnimatedPaintBox1DblClick(Sender: TObject);
  private
    { Private declarations }
    FShaderBuilder: ISkRuntimeShaderBuilder;
    FPaint: ISkPaint;
    FPaintCount: Int64;
    FStopWatch: TDateTime;
    procedure RunShader;
    procedure LoadShaders;
    procedure LoadShader(const AShaderFile: string);
  public
    { Public declarations }
    procedure LoadSelectedShader;
    procedure RandomShader;
  end;

var
  frmShaderView: TfrmShaderView;

implementation

{$R *.fmx}

uses
  IOUtils, System.DateUtils, System.Generics.Collections, System.Generics.Defaults;

const
  ShaderExt = '.sksl';

function ShaderPath: string;
begin
	{$IFDEF MSWINDOWS}
	if TDirectory.Exists('shaders') then
		Result := TPath.GetFullPath('shaders')
	else
		Result := TPath.GetFullPath('..\..\..\shaders\');
	{$ELSEIF DEFINED(IOS) or DEFINED(ANDROID)}
	Result := TPath.GetDocumentsPath;
	{$ELSEIF defined(MACOS)}
	Result := TPath.GetFullPath('../Resources/');
	{$ELSE}
	Result := ExtractFilePath(ParamStr(0));
	{$ENDIF}
	if (Result <> '') and not Result.EndsWith(PathDelim) then
		Result := Result + PathDelim;
end;

function MediaPath: string;
begin
	{$IFDEF MSWINDOWS}
	if TDirectory.Exists('media') then
		Result := TPath.GetFullPath('media')
	else
		Result := TPath.GetFullPath('..\..\..\media\');
	{$ELSEIF DEFINED(IOS) or DEFINED(ANDROID)}
  Result := TPath.Combine(TPath.GetDocumentsPath, 'media');
  {$ELSEIF defined(MACOS)}
  Result := TPath.Combine(TPath.GetFullPath('../Resources/'), 'media');
  {$ELSE}
  Result := TPath.Combine(ExtractFilePath(ParamStr(0)), 'media');
  {$ENDIF}
  if (Result <> '') and not Result.EndsWith(PathDelim) then
    Result := Result + PathDelim;
end;

function MediaTexturesPath: string;
begin
  Result := TPath.Combine(MediaPath, 'textures');
end;

procedure TfrmShaderView.RunShader;
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

  if LEffect.ChildExists('iImage1') then
  begin
    var image1: ISkImage := TSkImage.MakeFromEncodedFile(
      TPath.Combine(MediaTexturesPath,
         '8de3a3924cb95bd0e95a443fff0326c869f9d4979cd1d5b6e94e2a01f5be53e9.jpg'));

    if Assigned(image1) then
    begin
      FShaderBuilder.SetChild('iImage1', image1.MakeShader(TSKSamplingOptions.High));
      if FShaderBuilder.Effect.UniformExists('iImage1Resolution') then
        case FShaderBuilder.Effect.UniformTypeByName['iImage1Resolution'] of
          TSkRuntimeEffectUniformType.Float2,
          TSkRuntimeEffectUniformType.Int2:
            FShaderBuilder.SetUniform('iImage1Resolution', [image1.Width, image1.Height]);
          TSkRuntimeEffectUniformType.Float3,
          TSkRuntimeEffectUniformType.Int3:
            FShaderBuilder.SetUniform('iImage1Resolution', [image1.Width, image1.Height, 0]);
        end;
    end;
  end;

  FPaint := TSkPaint.Create;
  FPaint.Shader := FShaderBuilder.MakeShader;
  SkAnimatedPaintBox1.Animation.Start;
end;

procedure TfrmShaderView.SkAnimatedPaintBox1AnimationDraw(ASender: TObject;
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

procedure TfrmShaderView.SkAnimatedPaintBox1DblClick(Sender: TObject);
begin
  var LBitmap := TBitmap.Create;
  try
    LBitmap.SetSize(floor(SkAnimatedPaintBox1.Width), floor(SkAnimatedPaintBox1.Height));
    LBitmap.SkiaDraw(procedure(const ACanvas: ISkCanvas)
    begin
      ACanvas.DrawRect(TRectF.Create(0,0,LBitmap.Width,LBitmap.Height), FPaint);
    end);
    LBitmap.ToSkImage.EncodeToFile(
      TPath.Combine(ShaderPath,
        TPath.ChangeExtension(lbShaders.Selected.Text, '.png')));
  finally
    LBitmap.Free;
  end;
end;

procedure TfrmShaderView.SkAnimatedPaintBox1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Single);
begin
  if ckMouse.IsChecked and FShaderBuilder.Effect.UniformExists('iMouse') and Assigned(FShaderBuilder) then
    FShaderBuilder.SetUniform('iMouse', [X, Y, 0, Math.IfThen(ssLeft in Shift, 1, 0)]);
end;

procedure TfrmShaderView.SkAnimatedPaintBox1Resize(Sender: TObject);
begin
  FPaintCount := 0;  // reset the fps counter after resizing the form
end;

procedure TfrmShaderView.Button1Click(Sender: TObject);
begin
  RunShader;
end;

procedure TfrmShaderView.LoadSelectedShader;
begin
  LoadShader(TPath.Combine(ShaderPath,lbShaders.Items[lbShaders.ItemIndex]+ShaderExt));
end;

procedure TfrmShaderView.LoadShader(const AShaderFile: string);
begin
  FPaintCount := 0;
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

procedure TfrmShaderView.Button3Click(Sender: TObject);
begin
  if SaveDialog1.Execute then
  begin
    Memo1.Lines.SaveToFile(SaveDialog1.FileName);
  end;
end;

procedure TfrmShaderView.FormCreate(Sender: TObject);
begin
  LoadShaders;
  MultiView1.Mode := TMultiViewMode.Drawer;
  SkAnimatedPaintBox1.Animation.Duration := MaxSingle;
end;

procedure TfrmShaderView.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if key = vkLeft then
  begin
    if lbShaders.ItemIndex > 0 then
      lbShaders.ItemIndex := Pred(lbShaders.ItemIndex)
    else
      lbShaders.ItemIndex := Pred(lbShaders.Items.Count);
    LoadSelectedShader;
    key := 0;
  end;
  if key = vkRight then
  begin
    if lbShaders.ItemIndex < Pred(lbShaders.Items.Count) then
      lbShaders.ItemIndex := Succ(lbShaders.ItemIndex)
    else
      lbShaders.ItemIndex := 0;
    LoadSelectedShader;
    key := 0;
  end;
  if keyChar = #32 then
  begin
    var progress := SkAnimatedPaintBox1.Animation.Progress;
    if SkAnimatedPaintBox1.Animation.Enabled then
      SkAnimatedPaintBox1.Animation.Stop
    else
      SkAnimatedPaintBox1.Animation.Start;
    SkAnimatedPaintBox1.Animation.Progress := progress;
  end;
  if UpCase(KeyChar) = 'F' then
    RectangleFps.Visible := not RectangleFps.Visible;
  if KeyChar = '?' then
  begin
    if Trunc(RectangleKeys.Opacity * 10) = 0 then
      TAnimator.AnimateFloat(RectangleKeys, 'Opacity',0.5,1)
    else
      TAnimator.AnimateFloat(RectangleKeys, 'Opacity',0,1);
  end;
  if UpCase(KeyChar) = 'M' then
    ckMouse.IsChecked := not ckMouse.IsChecked;
  if UpCase(KeyChar) = 'R' then
    RandomShader;
  if UpCase(KeyChar) = 'L' then
  begin
    if Trunc(SkSvg1.Opacity * 10) = 0 then
      TAnimator.AnimateFloat(SkSvg1, 'Opacity',1,1)
    else
      TAnimator.AnimateFloat(SkSvg1, 'Opacity',0,1);
  end;
end;

procedure TfrmShaderView.FormPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
begin
  if FPaintCount = 0 then
  begin
    FstopWatch := now;
  end;
  inc(FPaintCount);
  var LFps := FPaintCount / ((now - FstopWatch) * (1 / OneSecond));
  LabelFPS.Text := Format('%3.1f fps', [LFps]);
end;

procedure TfrmShaderView.lbShadersItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin
  LoadSelectedShader;
end;

procedure TfrmShaderView.LoadShaders;
begin
  if not TDirectory.Exists(ShaderPath) then
  begin
    lbShaders.Visible := False;
    Splitter2.Visible := False;
    exit;
  end;

  var Shaders := TDirectory.GetFiles(ShaderPath, '*' + ShaderExt);
  TArray.Sort<string>(Shaders, TComparer<string>.Construct(
    function (const Left, Right: string): Integer
    begin
      Result := TComparer<string>.Default.Compare(Left.ToLower, Right.ToLower);
    end));
  for var shader in Shaders do
    lbShaders.Items.Add(TPath.GetFileNameWithoutExtension(Shader));
  //RandomShader;
  lbShaders.ItemIndex := 0;
  LoadSelectedShader;
end;

procedure TfrmShaderView.RandomShader;
begin
  if lbShaders.Count > 0 then
  begin
    lbShaders.ItemIndex := random(lbShaders.Count);
    LoadSelectedShader;
  end;
end;

procedure TfrmShaderView.RectangleFpsClick(Sender: TObject);
begin
  RectangleFps.Visible := false;
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
