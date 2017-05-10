/// <summary>
/// </summary>
unit uIViews;

interface

uses
  { TThread }
  System.Classes,
  { TImage }
  Vcl.ExtCtrls,
  { TPicture }
  Vcl.Graphics,
  { TWinControl }
  Vcl.Controls;

type
  /// <summary>
  /// </summary>
  IViewControl = interface
    ['{BAC7364A-63E3-4B7D-9052-598859E174EA}']

    /// <summary>
    /// </summary>
    procedure CreateControls;

    /// <summary>
    /// </summary>
    procedure UpdateImage(ABitmap: TBitmap);

    /// <summary>
    /// </summary>
    procedure ImageThreadComleted(const AThread: TThread);

    /// <summary>
    /// </summary>
    procedure UpdateLoadProgress(AValue: Integer);

    /// <summary>
    /// </summary>
    function GetImageViewsControl: TWinControl;
  end;

implementation

end.
