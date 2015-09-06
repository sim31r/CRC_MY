object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 556
  ClientWidth = 633
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 16
  object Button1: TButton
    Left = 8
    Top = 504
    Width = 75
    Height = 25
    Caption = 'Start'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 8
    Top = 8
    Width = 330
    Height = 490
    Lines.Strings = (
      'Memo1')
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object Edit1: TEdit
    Left = 96
    Top = 505
    Width = 89
    Height = 24
    TabOrder = 2
    Text = '1'
  end
  object Memo2: TMemo
    Left = 344
    Top = 8
    Width = 265
    Height = 490
    Lines.Strings = (
      'Memo2')
    ScrollBars = ssVertical
    TabOrder = 3
  end
  object CheckBox1: TCheckBox
    Left = 191
    Top = 504
    Width = 66
    Height = 17
    Caption = 'TestId'
    TabOrder = 4
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 100
    OnTimer = Timer1Timer
    Left = 160
    Top = 472
  end
end
