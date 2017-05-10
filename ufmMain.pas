unit ufmMain;

interface

uses
  { EnterCriticalSection }
  Winapi.Windows,
  System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls,
  System.Generics.Collections,
  { IViewControl }
  uIViews;

type

  TfmMain = class(TForm, IViewControl)
    scrollBoxImages: TScrollBox;
    btnLoadImagesFromFolder: TButton;
    btnFreeImages: TButton;
    lblLoadingImagesProgress: TLabel;
    lblThreadsCompleted: TLabel;
    btnStopLoading: TButton;
    memHelp: TMemo;
    procedure btnLoadImagesFromFolderClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnFreeImagesClick(Sender: TObject);
    procedure btnStopLoadingClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
  private
    {$REGION 'Implements interface "IViewControl" '}
    procedure CreateControls;
    procedure UpdateImage(ABitmap: TBitmap);
    procedure ImageThreadComleted(const AThread: TThread);
    procedure UpdateLoadProgress(AValue: Integer);
	  function GetImageViewsControl: TWinControl;
    {$ENDREGION}

    procedure EnDsControls(AStatus: Boolean);
  public
  end;

var
  fmMain: TfmMain;

implementation

uses
  { CriticalSection }
  uCore.CriticalSection,
  uConsts,
  { TaskImages }
  uTask.Images,
  { WM_VSCROLL }
  Winapi.Messages;

{$R *.dfm}

procedure TfmMain.btnLoadImagesFromFolderClick(Sender: TObject);
begin
  EnDsControls(False);

  TaskImages.LoadAndDisplayImages('F:\Pictures\My Photos\Y2016', CONST_FILE_TYPES);
end;

procedure TfmMain.btnStopLoadingClick(Sender: TObject);
begin
  TaskImages.StopTasks;
end;

procedure TfmMain.btnFreeImagesClick(Sender: TObject);
begin
  TaskImages.FreeImages;
end;

procedure TfmMain.EnDsControls(AStatus: Boolean);
begin
  btnLoadImagesFromFolder.Enabled := AStatus;
  btnFreeImages.Enabled := AStatus;
end;

procedure TfmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  TaskImages.StopTasks;

  with CriticalSection do
    if FImagesThreadPool.LockList.Count > 0 then
      begin
        Action := caNone;
        EnterCriticalSection(Section);
        try
          FPostponedCloseOnceAllTaskCompleted := True;
        finally
          LeaveCriticalSection(Section);
        end;
      end;
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  TaskImages.FreeImages;
end;

procedure TfmMain.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
const
  CONST_SCROLL_LINES = 2;
var
  I, J: Integer;
  LScrollBox: TScrollBox;
  LControl: TWinControl;
begin
  LControl := FindVCLWindow(Mouse.CursorPos);
  Handled := LControl is TScrollBox;

  if not Handled then
    Exit;

  LScrollBox := LControl as TScrollBox;

  for I := 1 to Mouse.WheelScrollLines do
    try
      for J := 1 to CONST_SCROLL_LINES do
        if WheelDelta > 0 then
          LScrollBox.Perform(WM_VSCROLL, SB_LINEUP, 0)
        else
          LScrollBox.Perform(WM_VSCROLL, SB_LINEDOWN, 0);
    finally
      LScrollBox.Perform(WM_VSCROLL, SB_ENDSCROLL, 0);
    end;
end;

{$REGION 'Implements interface "IViewControl" '}
procedure TfmMain.CreateControls;
begin
end;

procedure TfmMain.UpdateImage(ABitmap: TBitmap);
begin
  with CriticalSection do
    begin
      EnterCriticalSection(Section);
      try
        if FImages.Count > 0 then
          begin
            FImages[FDisplayIndex].Picture.Assign(ABitmap);
            Inc(FDisplayIndex);
          end;
      finally
        LeaveCriticalSection(Section);
      end;
    end;
end;

procedure TfmMain.ImageThreadComleted(const AThread: TThread);

  function FormatProgressLabel(AValue: Integer): String;
  begin
    Result := Format('There are %d images loaded', [AValue]);
  end;

var
  LFileName: String;
  LIndex: Integer;
  LActionRequired: Boolean;
  LPostponedCloseOnceAllTaskCompleted: Boolean;
  LThreadsCompleted: Integer;
begin
  { Remove thread from pool list }
  LIndex := CriticalSection.FImagesThreadPool.LockList.IndexOf(AThread);

  if LIndex = -1 then
    Exit;

  CriticalSection.FImagesThreadPool.LockList.Remove(
    CriticalSection.FImagesThreadPool.LockList.Items[LIndex]);

  if CriticalSection.FImagesThreadPool.LockList.Count = 0 then
    EnDsControls(True);

  EnterCriticalSection(CriticalSection.Section);
  try
    LPostponedCloseOnceAllTaskCompleted :=
      CriticalSection.FPostponedCloseOnceAllTaskCompleted;
  finally
    LeaveCriticalSection(CriticalSection.Section);
  end;

  if LPostponedCloseOnceAllTaskCompleted then
    Close;

  { Should we run next thread? }
  EnterCriticalSection(CriticalSection.Section);
  try
    LActionRequired :=
      (CriticalSection.FImagesThreadPool.LockList.Count < CONST_MAX_THREADS)
      and (CriticalSection.FPendingFiles.Count > 0);
    Inc(CriticalSection.FThreadsCompleted);
    LThreadsCompleted := CriticalSection.FThreadsCompleted;
  finally
    LeaveCriticalSection(CriticalSection.Section);
  end;

  { GUI }
  lblThreadsCompleted.Caption := FormatProgressLabel(LThreadsCompleted);

  if not LActionRequired then
    Exit;

  with CriticalSection do
    begin
      EnterCriticalSection(CriticalSection.Section);
      try
        LFileName := FPendingFiles[FPendingFiles.Count - 1];
        FPendingFiles.Delete(FPendingFiles.Count - 1);
      finally
        LeaveCriticalSection(Section);
      end;
    end;

  { Run next thread }
  TaskImages.RunImageViewThread(LFileName, tpLowest);
end;

procedure TfmMain.UpdateLoadProgress(AValue: Integer);
begin
  lblLoadingImagesProgress.Caption := Format('There are %d images in folder',
    [AValue])
end;

function TfmMain.GetImageViewsControl: TWinControl;
begin
  Result := scrollBoxImages;
end;
{$ENDREGION}

end.
