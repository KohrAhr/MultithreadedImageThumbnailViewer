unit uFunctions.Form;

interface

type
  FormHelper = class
  private
    class var FLastInterface: TGUID;
    class var FLastObject: IInterface;
  public
    class function GetFirstForm(const AInterface: TGUID; out RI): Boolean;
  end;

implementation

uses
  { Screen }
  Vcl.Forms,
  { Supports }
  System.SysUtils;

class function FormHelper.GetFirstForm(const AInterface: TGUID; out RI): Boolean;
var
  LCycle: Integer;
begin
  Result := False;

  { Simple cache }
  if AInterface = FLastInterface then
      if FLastObject <> nil then
        if Supports(FLastObject, AInterface, RI) then
          Exit(True);

  { Search for form which are implement required interface }
  for LCycle := 0 to Screen.FormCount - 1 do
    if Supports(Screen.Forms[LCycle], AInterface, RI) then
      begin
      	{ Store founded form for cache purpose }
      	FLastInterface := AInterface;
        FLastObject := Screen.Forms[LCycle];

        Exit(True);
      end;
end;

end.
