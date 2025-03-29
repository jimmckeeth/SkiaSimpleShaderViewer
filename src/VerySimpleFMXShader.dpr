program VerySimpleFMXShader;

uses
  System.StartUpCopy,
  FMX.Forms,
  VSShaderMainFMX in 'VSShaderMainFMX.pas' {frmVerySimpleShaderFMX};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmVerySimpleShaderFMX, frmVerySimpleShaderFMX);
  Application.Run;
end.
