/// <summary>
/// </summary>
unit uTask.Images;

interface

uses
  { Rect tpNormal }
  System.Classes,
  { IViewControl }
  uIViews;

type
  /// <summary>
  /// </summary>
  TaskImages = class
    /// <summary>
    /// </summary>
    class var
      FNextLeft,
      FNextTop: Integer;

    /// <summary>
    /// </summary>
		class var RMain: IViewControl;

    /// <summary>
    /// </summary>
    class procedure InitImages;

    /// <summary>
    /// </summary>
    class procedure FreeImages;

    /// <summary>
    /// </summary>
    class procedure StopTasks;

    /// <summary>
    /// </summary>
    class function LoadAndDisplayImages(APath: String;
      AExtension: array of String): Integer;

    /// <summary>
    /// </summary>

    class procedure LoadAndDisplayImageAsync(AFileName: String);

    /// <summary>
    /// </summary>
{$WARNINGS OFF}
    class procedure RunImageViewThread(AFileName: String;
      APriority: TThreadPriority);
{$WARNINGS ON}
  end;

implementation

uses
  { EnterCriticalSection }
  Winapi.Windows,
  { CriticalSection }
  uCore.CriticalSection,
  { FreeAndNil }
  System.SysUtils,
  uConsts,
  { TTaskImage }
  uTask.Image,
  Vcl.Imaging.jpeg,
  { clRed }
  Vcl.Graphics,
  { TImage }
  Vcl.ExtCtrls,
  { FormHelper }
  uFunctions.Form;

class procedure TaskImages.FreeImages;
begin
  EnterCriticalSection(CriticalSection.Section);
  try
    FreeAndNil(CriticalSection.FImages);
  finally
    LeaveCriticalSection(CriticalSection.Section);
  end;
end;

class procedure TaskImages.StopTasks;
var
  I: Integer;
begin
  EnterCriticalSection(CriticalSection.Section);
  try
    CriticalSection.FPendingFiles.Clear;

    for I := 0 to CriticalSection.FImagesThreadPool.LockList.Count - 1 do
      CriticalSection.FImagesThreadPool.LockList.Items[I].Terminate;
  finally
    LeaveCriticalSection(CriticalSection.Section);
  end;
end;

class procedure TaskImages.InitImages;
begin
  EnterCriticalSection(CriticalSection.Section);
  try
    with CriticalSection do
      begin
        FImages := TImages.Create;
        FDisplayIndex := 0;
      end;
  finally
    LeaveCriticalSection(CriticalSection.Section);
  end;
end;

{$WARNINGS OFF}
class procedure TaskImages.RunImageViewThread(AFileName: String;
  APriority: TThreadPriority);
{$WARNINGS ON}
var
  LImageViewThread: TTaskImage;
begin
  try
    { Run new thread }
    LImageViewThread := TTaskImage.Create(AFileName);
    with LImageViewThread do
      begin
        FreeOnTerminate := True;
        Priority := tpNormal;
        Start;
      end;
  except
    FreeAndNil(LImageViewThread);
    raise;
  end;

  { Add new thread into pool list }
  CriticalSection.FImagesThreadPool.LockList;
  try
    CriticalSection.FImagesThreadPool.Add(LImageViewThread);
  finally
    CriticalSection.FImagesThreadPool.UnlockList;
  end;
end;


class function TaskImages.LoadAndDisplayImages(APath: String;
  AExtension: array of String): Integer;
var
  LFileType: String;
  LImages: Integer;
  LSearchRec: TSearchRec;
begin
  { Just to be sure }
  APath := IncludeTrailingPathDelimiter(APath);

  // Not perfect for reload
  TaskImages.StopTasks;
  TaskImages.FreeImages;
  TaskImages.InitImages;

  FNextLeft := CONST_MARGIN_LEFT;
  FNextTop := CONST_MARGIN_TOP;

  EnterCriticalSection(CriticalSection.Section);
  try
    CriticalSection.FPostponedCloseOnceAllTaskCompleted := False;
    CriticalSection.FThreadsCompleted := 0;
  finally
    LeaveCriticalSection(CriticalSection.Section);
  end;

  LImages := 0;

  for LFileType in AExtension do
    try
      if FindFirst(APath + '*.' + LFileType, faAnyFile, LSearchRec) = 0 then
        repeat
          Inc(LImages);
          if LImages mod 5 = 0 then
            if RMain <> nil then
              RMain.UpdateLoadProgress(LImages);

          LoadAndDisplayImageAsync(APath + LSearchRec.Name);
        until FindNext(LSearchRec) <> 0;

        if RMain <> nil then
          RMain.UpdateLoadProgress(LImages);
    finally
      FindClose(LSearchRec);
    end;

  Result := LImages;
end;


class procedure TaskImages.LoadAndDisplayImageAsync(AFileName: String);
var
  LImage: TImage;
  LMaxParentWidth,
  LMaxParentHeight: Integer;
  LPartialVisible: Boolean;
begin
  FormHelper.GetFirstForm(IViewControl, RMain);

  if RMain <> nil then
    begin
      LMaxParentWidth := RMain.GetImageViewsControl.ClientWidth;
      LMaxParentHeight := RMain.GetImageViewsControl.ClientHeight;
    end
  else
    begin
      LMaxParentWidth := (CONST_IMAGE_WIDTH + CONST_MARGIN_LEFT) * 3;
      LMaxParentHeight := (CONST_IMAGE_HEIGHT + CONST_MARGIN_TOP) * 3;
    end;

  if FNextLeft + CONST_IMAGE_WIDTH + CONST_MARGIN_LEFT >= LMaxParentWidth then
    begin
      FNextLeft := CONST_MARGIN_LEFT;
      FNextTop := FNextTop + CONST_IMAGE_HEIGHT + CONST_MARGIN_TOP;
    end;

  if FNextTop >= LMaxParentHeight then
    LPartialVisible := False
  else
    LPartialVisible := True;

  try
    { Create image }
    LImage := TImage.Create(nil);
    with LImage do
      begin
        Width := CONST_IMAGE_WIDTH;
        Height := CONST_IMAGE_HEIGHT;
        Center := True;
        Stretch := True;
        Proportional := True;
        Left := FNextLeft;
        Top := FNextTop;
        with Canvas do
          begin
            Brush.Color := clRed;
            Pen.Color := clBlack;
            FillRect(Rect(0, 0, CONST_IMAGE_WIDTH, CONST_IMAGE_HEIGHT));
          end;
      end;

    FNextLeft := FNextLeft + CONST_IMAGE_WIDTH + CONST_MARGIN_LEFT;

    if RMain <> nil then
      LImage.Parent := RMain.GetImageViewsControl;
  except
    FreeAndNil(LImage);
  end;

  { Thread count control }
  EnterCriticalSection(CriticalSection.Section);
  try
    CriticalSection.FImages.Add(LImage);
    if (CriticalSection.FImagesThreadPool.LockList.Count > CONST_MAX_THREADS)
      or (not LPartialVisible) then
      begin
        if CriticalSection.FPendingFiles.IndexOf(AFileName) = -1 then
          CriticalSection.FPendingFiles.Add(AFileName);
        Exit;
      end;
  finally
    LeaveCriticalSection(CriticalSection.Section);
  end;

  if LPartialVisible then
    RunImageViewThread(AFileName, tpHigher);
end;

end.
