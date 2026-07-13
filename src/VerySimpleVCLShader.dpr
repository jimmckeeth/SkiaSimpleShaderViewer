program VerySimpleVCLShader;

uses
  Vcl.Forms,
  VSShaderMainVCL in 'VSShaderMainVCL.pas' {frmVerySimpleShaderVCL};

{$R 'VerySimpleVCLShader.res' 'VerySimpleVCLShader.rc'}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmVerySimpleShaderVCL, frmVerySimpleShaderVCL);
  Application.Run;
end.
