unit uFunctions.ImageHelper;

interface

type
  TImageResize = record
    CurrentWidth, CurrentHeight,
    MaxWidth, MaxHeight,
    NewWidth, NewHeight: Integer;
  end;

  ImageHelper = class
    class procedure CalculateNewSize(var AImageResize: TImageResize);
  end;

implementation

{ ImageHelper }

class procedure ImageHelper.CalculateNewSize(var AImageResize: TImageResize);
var
  LValue: Integer;
begin
  with AImageResize do
    if CurrentWidth > CurrentHeight then
      begin
        LValue := Round(CurrentHeight * MaxWidth / CurrentWidth);
        NewWidth := MaxWidth;
        NewHeight := LValue;
      end
    else
      begin
        LValue := Round(CurrentWidth * MaxHeight / CurrentHeight);
        NewWidth := LValue;
        NewHeight := MaxHeight;
      end;
end;

end.
