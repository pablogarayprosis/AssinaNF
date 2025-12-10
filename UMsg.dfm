object FmMsg: TFmMsg
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsNone
  ClientHeight = 115
  ClientWidth = 400
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 400
    Height = 115
    Align = alClient
    BorderStyle = bsSingle
    TabOrder = 0
    object MmMsg: TMemo
      Left = 1
      Top = 1
      Width = 394
      Height = 77
      Align = alClient
      BorderStyle = bsNone
      Color = clMoneyGreen
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      ReadOnly = True
      TabOrder = 0
      StyleElements = []
      OnKeyDown = MmMsgKeyDown
    end
    object Panel13: TPanel
      Left = 1
      Top = 78
      Width = 394
      Height = 32
      Align = alBottom
      BevelInner = bvRaised
      BevelOuter = bvLowered
      Color = clMoneyGreen
      TabOrder = 1
      StyleElements = [seFont, seBorder]
      DesignSize = (
        394
        32)
      object BtOK: TNewBtn
        Left = 181
        Top = 4
        Width = 33
        Height = 25
        Cursor = crHandPoint
        Anchors = [akBottom]
        Caption = '&OK'
        Flat = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clNavy
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        StyleElements = []
        OnClick = BtOKClick
      end
    end
  end
end
