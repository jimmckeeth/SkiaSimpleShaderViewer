object frmVerySimpleShaderVCL: TfrmVerySimpleShaderVCL
  Left = 0
  Top = 0
  Margins.Left = 5
  Margins.Top = 5
  Margins.Right = 5
  Margins.Bottom = 5
  Caption = 'Very Simple VCL Shader Viewer'
  ClientHeight = 664
  ClientWidth = 938
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -18
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  PixelsPerInch = 144
  TextHeight = 25
  object Splitter1: TSplitter
    Left = 540
    Top = 0
    Width = 12
    Height = 664
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Align = alRight
    MinSize = 45
  end
  object Memo1: TMemo
    Left = 552
    Top = 0
    Width = 386
    Height = 664
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Align = alRight
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -18
    Font.Name = 'Consolas'
    Font.Style = []
    Lines.Strings = (
      'uniform float iTime;'
      'uniform float2 iResolution;'
      ''
      '// simple plasma '
      '// Created by Kastor in 2013-10-22'
      '// https://www.shadertoy.com/view/ldBGRR'
      ''
      'vec4 main( in vec2 fragCoord )'
      '{'
      #9'vec2 p = -1.0 + 2.0 * fragCoord.xy / iResolution.xy;'
      #9#9
      
        #9'// main code, *original shader by: '#39'Plasma'#39' by Viktor Korsun (2' +
        '011)'
      #9'float x = p.x;'
      #9'float y = p.y;'
      #9'float mov0 = x+y+cos(sin(iTime)*2.0)*100.+sin(x/100.)*1000.;'
      #9'float mov1 = y / 0.9 +  iTime;'
      #9'float mov2 = x / 0.2;'
      #9'float c1 = abs(sin(mov1+iTime)/2.+mov2/2.-mov1-mov2+iTime);'
      
        #9'float c2 = abs(sin(c1+sin(mov0/1000.+iTime)+sin(y/40.+iTime)+si' +
        'n((x+y)/100.)*3.));'
      
        #9'float c3 = abs(sin(c2+cos(mov1+mov2+c2)+cos(mov2)+sin(x/1000.))' +
        ');'
      #9'return vec4(c1,c2,c3,1);'#9#9
      '}'
      '')
    ParentFont = False
    TabOrder = 0
    WordWrap = False
    OnDblClick = Memo1Exit
    OnExit = Memo1Exit
  end
  object SkAnimatedPaintBox1: TSkAnimatedPaintBox
    Left = 0
    Top = 0
    Width = 540
    Height = 664
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Align = alClient
    BackendRender = HardwareAcceleration
    OnAnimationDraw = SkAnimatedPaintBox1AnimationDraw
  end
end
