/// <summary>
///   Test application by Andrejs Zamkovojs, RIGA. LATVIA. ZAM@1CLICK.LV.
///   23/Apr/2017.
///   Sub-task: Browse single folder
///   Powered on: Delphi DX10 Seattle Pro 23.0.21418.4207
/// </summary>
program C1;

uses
  Vcl.Forms,
  ufmMain in 'ufmMain.pas' {fmMain},
  uTask.Image in 'Tasks\uTask.Image.pas',
  uFunctions.Form in 'Functions\uFunctions.Form.pas',
  uIViews in 'Views\uIViews.pas',
  uCore.CriticalSection in 'Core\uCore.CriticalSection.pas',
  uConsts in 'uConsts.pas',
  uFunctions.ImageHelper in 'Functions\uFunctions.ImageHelper.pas',
  uTask.Images in 'Tasks\uTask.Images.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
