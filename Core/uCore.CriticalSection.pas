unit uCore.CriticalSection;

interface

uses
  { TThread }
  System.Classes,
  { TThreadList }
  System.Generics.Collections,
  { TRTLCriticalSection }
  WinApi.Windows,
  { TImage }
  Vcl.ExtCtrls;

type
  /// <summary>
  ///   Class instance for "Critical Sections" -- for manage shared objects for multithread application
  /// </summary>
  CriticalSection = class
  public
    type
      TImages = TObjectList<TImage>;
      TImagesThreadPool = TThreadList<TThread>;
  public
    /// <summary>
    ///   Just informative counter
    /// </summary>
    class var FThreadsCompleted: Integer;

    class var FPostponedCloseOnceAllTaskCompleted: Boolean;

    class var FImages: TImages;
    class var FImagesThreadPool: TImagesThreadPool;

    class var FPendingFiles: TStringList;

    class var FDisplayIndex: Integer;

    class var Section: TRTLCriticalSection;

    class constructor Create;
    class destructor Destroy;
  end;

implementation

uses
  { FreeAndNil }
  System.SysUtils;

class constructor CriticalSection.Create;
begin
  inherited;

  try
    FImages := TImages.Create;

    FImagesThreadPool := TImagesThreadPool.Create;

    FPendingFiles := TStringList.Create;
  except
    raise;
  end;
end;

class destructor CriticalSection.Destroy;
begin
  FPendingFiles.Free;

  FImagesThreadPool.Free;

  FreeAndNil(FImages);

  inherited;
end;

initialization
  InitializeCriticalSection(CriticalSection.Section);

finalization
  DeleteCriticalSection(CriticalSection.Section);

end.
