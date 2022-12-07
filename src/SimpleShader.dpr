program SimpleShader;



uses
  System.StartUpCopy,
  FMX.Forms,
  Skia.FMX,
  FMX.Types,
  SimpleShaderMain in 'SimpleShaderMain.pas' {frmShaderView};

{$R *.res}

begin
  GlobalUseSkia := True;

  // To use Skia's Metal backend in macOS/iOS and improve performance
  GlobalUseMetal := True;

  // GPU is priorty in all platform except in Windows, but adding this
  // line will force GPU backend and improves Windows shader performance
  GlobalUseSkiaRasterWhenAvailable := False;

  Application.Initialize;
  Application.CreateForm(TfrmShaderView, frmShaderView);
  Application.Run;
end.
