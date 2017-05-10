object fmMain: TfmMain
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 
    'Test application by Andrejs Zamkovojs, RIGA. LATVIA. ZAM@1CLICK.' +
    'LV. 23/Apr/2017. Sub-task: Browse single folder'
  ClientHeight = 312
  ClientWidth = 655
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnDestroy = FormDestroy
  OnMouseWheel = FormMouseWheel
  PixelsPerInch = 96
  TextHeight = 13
  object lblLoadingImagesProgress: TLabel
    Left = 8
    Top = 39
    Width = 3
    Height = 13
  end
  object lblThreadsCompleted: TLabel
    Left = 8
    Top = 58
    Width = 3
    Height = 13
  end
  object scrollBoxImages: TScrollBox
    Left = 303
    Top = 8
    Width = 346
    Height = 297
    Color = clAppWorkSpace
    ParentColor = False
    TabOrder = 0
  end
  object btnLoadImagesFromFolder: TButton
    Left = 8
    Top = 8
    Width = 156
    Height = 25
    Caption = 'Load images from folder'
    TabOrder = 1
    OnClick = btnLoadImagesFromFolderClick
  end
  object btnFreeImages: TButton
    Left = 8
    Top = 77
    Width = 75
    Height = 25
    Caption = 'Free'
    TabOrder = 2
    OnClick = btnFreeImagesClick
  end
  object btnStopLoading: TButton
    Left = 89
    Top = 77
    Width = 75
    Height = 25
    Caption = 'Stop'
    TabOrder = 3
    OnClick = btnStopLoadingClick
  end
  object memHelp: TMemo
    Left = 8
    Top = 120
    Width = 265
    Height = 184
    Color = clInfoBk
    Lines.Strings = (
      'NOTE:'
      'Main settings stored in unit "uConsts.pas"'
      ''
      '1) modify preferred image thumbnail size'
      '  CONST_IMAGE_HEIGHT = 64;'
      '  CONST_IMAGE_WIDTH = 64;'
      '2) count of threads'
      '  CONST_MAX_THREADS = 32'
      ''
      'P.S. In perfect world count of threads should '
      'be calculated.'
      'It should depend on count of CPU CORE.')
    ReadOnly = True
    TabOrder = 4
  end
end
