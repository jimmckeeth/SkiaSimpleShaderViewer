program SimpleShader;



uses
  System.StartUpCopy,
  FMX.Forms,
  Skia.FMX,
  SimpleShaderMain in 'SimpleShaderMain.pas' {Form14};

{$R *.res}

begin
  GlobalUseSkia := True;
  // GPU is priorty everywhere but Windows,
  // this line improves Windows shader performance
  GlobalUseSkiaRasterWhenAvailable := False;
  Application.Initialize;
  Application.CreateForm(TForm14, Form14);
  Application.Run;
end.
