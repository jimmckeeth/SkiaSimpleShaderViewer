program VerySimpleFMXShader;

uses
  System.StartUpCopy,
  FMX.Forms,
  FMX.Skia,
  VSShaderMainFMX in 'VSShaderMainFMX.pas' {frmVerySimpleShaderFMX};

{$R *.res}

begin
  GlobalUseSkia := True;
  Application.Initialize;
  Application.CreateForm(TfrmVerySimpleShaderFMX, frmVerySimpleShaderFMX);
  Application.Run;
end.
