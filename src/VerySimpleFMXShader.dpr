program VerySimpleFMXShader;

uses
  System.StartUpCopy,
  FMX.Forms,
  FMX.Skia,
  VSShaderMainFMX in 'VSShaderMainFMX.pas' {frmVerySimpleShaderFMX};

{$R 'VerySimpleFMXShader.res' 'VerySimpleFMXShader.rc'}

begin
  GlobalUseSkia := True;
  Application.Initialize;
  Application.CreateForm(TfrmVerySimpleShaderFMX, frmVerySimpleShaderFMX);
  Application.Run;
end.
