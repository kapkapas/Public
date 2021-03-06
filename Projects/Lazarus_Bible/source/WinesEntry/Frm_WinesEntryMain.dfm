object MainForm: TMainForm
  Left = 202
  Top = 132
  Caption = 'Wines Database Entry Demonstration'
  ClientHeight = 255
  ClientWidth = 440
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 64
    Width = 52
    Height = 20
    Caption = 'Name:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clMaroon
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 16
    Top = 96
    Width = 68
    Height = 20
    Caption = 'Number:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clMaroon
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 16
    Top = 128
    Width = 63
    Height = 20
    Caption = 'Source:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clMaroon
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label4: TLabel
    Left = 16
    Top = 160
    Width = 68
    Height = 20
    Caption = 'Vintage:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clMaroon
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label5: TLabel
    Left = 16
    Top = 192
    Width = 91
    Height = 20
    Caption = 'Purchased:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clMaroon
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object DBNavigator1: TDBNavigator
    Left = 8
    Top = 8
    Width = 240
    Height = 25
    DataSource = DataSource1
    Kind = dbnHorizontal
    TabOrder = 0
  end
  object DBEdit1: TDBEdit
    Left = 128
    Top = 64
    Width = 201
    Height = 21
    DataField = 'Name'
    DataSource = DataSource1
    TabOrder = 1
  end
  object DBEdit2: TDBEdit
    Left = 128
    Top = 96
    Width = 33
    Height = 21
    DataField = 'Number'
    DataSource = DataSource1
    TabOrder = 2
  end
  object DBEdit3: TDBEdit
    Left = 128
    Top = 128
    Width = 265
    Height = 21
    DataField = 'Source'
    DataSource = DataSource1
    TabOrder = 3
  end
  object DBEdit4: TDBEdit
    Left = 128
    Top = 160
    Width = 57
    Height = 21
    DataField = 'Vintage'
    DataSource = DataSource1
    TabOrder = 4
  end
  object DBEdit5: TDBEdit
    Left = 128
    Top = 192
    Width = 57
    Height = 21
    DataField = 'Purchased'
    DataSource = DataSource1
    TabOrder = 5
  end
  object BitBtn1: TBitBtn
    Left = 296
    Top = 184
    Width = 75
    Height = 25
    Kind = bkClose
    NumGlyphs = 2
    TabOrder = 6
  end
  object DataSource1: TDataSource
    DataSet = ADOTable1
    Left = 296
    Top = 8
  end
  object ADOTable1: TADOTable
    ConnectionString = 'FILE NAME=..\bin\wines.udl'
    TableName = 'Wines'
    Left = 368
    Top = 32
  end
end
