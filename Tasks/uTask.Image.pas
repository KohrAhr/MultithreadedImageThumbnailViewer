unit uTask.Image;

interface

uses
  { TThread }
  System.Classes,
  { IViewControl }
  uIViews,
  { TPicture }
  Vcl.Graphics;

type
  TTaskImage = class(TThread)
  protected
    FBitmap: TBitMap;
    FFileName: String;

    class var
      RMain: IViewControl;

    procedure Execute; override;
    procedure ThreadCompleted(Sender: TObject);
  public
    constructor Create(AFileName: String);
    destructor Destroy; override;
  end;

implementation

uses
  { FormHelper }
  uFunctions.Form,
  { FreeAndNil }
  System.SysUtils,
  uConsts,
  { ImageHelper }
  uFunctions.ImageHelper,
  { Not using directly, but required for JPEG file format support }
  Vcl.Imaging.jpeg,
  { Not using directly, but required for PNG file format support }
  Vcl.Imaging.pngimage;

constructor TTaskImage.Create(AFileName: String);
begin
  if RMain = nil then
    FormHelper.GetFirstForm(IViewControl, RMain);

  OnTerminate := ThreadCompleted;

  FFileName := AFileName;
  
  inherited Create(True);
end;

destructor TTaskImage.Destroy;
begin
  FBitmap.Free;

  inherited;
end;

procedure TTaskImage.Execute;
var
  LImageResize: TImageResize;
  LPicture: TPicture;
begin
  inherited;

  LPicture := nil;
  try
    LPicture := TPicture.Create;
    try
      LPicture.LoadFromFile(FFileName);

      FBitmap := TBitmap.Create;
      FBitmap.Width := CONST_IMAGE_WIDTH;
      FBitmap.Height := CONST_IMAGE_HEIGHT;

      with LImageResize do
        begin
          CurrentWidth := LPicture.Graphic.Width;
          CurrentHeight := LPicture.Graphic.Height;
          MaxWidth := CONST_IMAGE_WIDTH;
          MaxHeight := CONST_IMAGE_HEIGHT;
        end;
      ImageHelper.CalculateNewSize(LImageResize);

      FBitmap.Canvas.Lock;
      try
        FBitmap.Canvas.StretchDraw(Rect(0, 0, LImageResize.NewWidth,
          LImageResize.NewHeight), LPicture.Graphic);
      finally
        FBitmap.Canvas.UnLock;
      end;

      if RMain <> nil then
       Synchronize(
         procedure
         begin
           RMain.UpdateImage(FBitmap);
         end
       );
    except
      FBitmap.Free;
    end;
  finally
    FreeAndNil(LPicture);
  end;
end;

procedure TTaskImage.ThreadCompleted(Sender: TObject);
begin
  if RMain <> nil then
    Synchronize(
      procedure
      begin
        RMain.ImageThreadComleted(Self);
      end
    );
end;

end.
