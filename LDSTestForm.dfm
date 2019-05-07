object frmTest: TfrmTest
  Left = 0
  Top = 0
  Anchors = [akLeft, akTop, akBottom]
  Caption = 'LDS Test'
  ClientHeight = 692
  ClientWidth = 991
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    991
    692)
  PixelsPerInch = 96
  TextHeight = 13
  object SmoothColorGraph1: TSmoothColorGraph
    Left = 319
    Top = 363
    Width = 664
    Height = 321
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ShowHint = False
    Anchors = [akLeft, akTop, akRight, akBottom]
    WasClicked = False
    AvailableBrushes = <>
    CaptionTransform.ScaleX = 1.000000000000000000
    CaptionTransform.ScaleY = 1.000000000000000000
    AllowPan = apVertical
    ShowTicks = False
    YAxis.YAxisAlign = aaLeft
    YAxis.YAxisValueFormat = 'HH:nn:ss.z'
    YAxis.YAxisValueDateTime = True
    YAxis.YAxisDataPPU = 100.000000000000000000
    YAxis.ClipValues = cvtNone
    XAxisCaption = 'SmoothGraph'
    XAxisValueDateTime = False
    ControlsVisible = False
    ControlAxisPan = False
    OnGetDataInThread = SmoothColorGraph1GetDataInThread
    XAxisDataPPU = 100.000000000000000000
    OnMouseButtonDown = SmoothColorGraph1MouseButtonDown
    Marks = <>
    ExplicitWidth = 661
    ExplicitHeight = 364
  end
  object btnPlotChunk: TButton
    Left = 326
    Top = 332
    Width = 131
    Height = 25
    Caption = 'Wczytaj detekcj'#281
    TabOrder = 0
    OnClick = btnPlotChunkClick
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 123
    Width = 305
    Height = 118
    Caption = 'Obszar'
    TabOrder = 1
    object Label1: TLabel
      Left = 13
      Top = 21
      Width = 146
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Start'
      Layout = tlCenter
    end
    object Label2: TLabel
      Left = 13
      Top = 76
      Width = 146
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Pr'#243'bek w czasie'
      Layout = tlCenter
    end
    object Label3: TLabel
      Left = 13
      Top = 49
      Width = 146
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Czas [s]'
      Layout = tlCenter
    end
    object dtStart: TcxDateEdit
      Left = 165
      Top = 22
      EditValue = 43367.4965277778d
      Properties.DateButtons = [btnNow]
      Properties.DateOnError = deNull
      Properties.ImmediatePost = True
      Properties.InputKind = ikStandard
      Properties.Kind = ckDateTime
      Properties.PostPopupValueOnTab = True
      TabOrder = 0
      Width = 129
    end
    object edtTimeResolution: TSpinEdit
      Left = 165
      Top = 75
      Width = 129
      Height = 22
      Increment = 10
      MaxValue = 0
      MinValue = 0
      TabOrder = 1
      Value = 600
    end
    object edtTime: TSpinEdit
      Left = 165
      Top = 47
      Width = 129
      Height = 22
      Increment = 100
      MaxValue = 0
      MinValue = 0
      TabOrder = 2
      Value = 180
    end
    object btnDate1: TButton
      Left = 13
      Top = 18
      Width = 28
      Height = 25
      Caption = 'S1a'
      TabOrder = 3
      OnClick = btnDate1Click
    end
    object btnDate2: TButton
      Left = 13
      Top = 49
      Width = 28
      Height = 25
      Caption = 'S2a'
      TabOrder = 4
      OnClick = btnDate2Click
    end
    object btnDate3: TButton
      Left = 47
      Top = 18
      Width = 28
      Height = 25
      Caption = 'S1b'
      TabOrder = 5
      OnClick = btnDate3Click
    end
    object btnDate4: TButton
      Left = 47
      Top = 49
      Width = 28
      Height = 25
      Caption = 'S2b'
      TabOrder = 6
      OnClick = btnDate4Click
    end
    object btnNow: TButton
      Left = 13
      Top = 80
      Width = 28
      Height = 25
      Caption = 'Now'
      TabOrder = 7
      OnClick = btnNowClick
    end
  end
  object GroupBox3: TGroupBox
    Left = 8
    Top = 471
    Width = 305
    Height = 211
    Caption = 'Metoda fali'
    TabOrder = 2
    object Label7: TLabel
      Left = 11
      Top = 19
      Width = 146
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Max [1/10000]'
      Layout = tlCenter
    end
    object Label11: TLabel
      Left = 11
      Top = 75
      Width = 146
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Min [1/10000]'
      Layout = tlCenter
    end
    object Label10: TLabel
      Left = 11
      Top = 158
      Width = 146
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Udzia'#322' [1/1000]'
      Layout = tlCenter
    end
    object Label13: TLabel
      Left = 11
      Top = 103
      Width = 146
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Preko'#347#263' fali [m/s]'
      Layout = tlCenter
    end
    object Label12: TLabel
      Left = 11
      Top = 131
      Width = 146
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'T'#322'umienie [1/100000]'
      Layout = tlCenter
    end
    object Label4: TLabel
      Left = 11
      Top = 47
      Width = 146
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Alarm [1/10000]'
      Layout = tlCenter
    end
    object edtDerivativeMax: TSpinEdit
      Left = 163
      Top = 17
      Width = 129
      Height = 22
      Increment = 100
      MaxValue = 0
      MinValue = 0
      TabOrder = 0
      Value = 15
    end
    object edtDerivativeMin: TSpinEdit
      Left = 163
      Top = 74
      Width = 129
      Height = 22
      Increment = 100
      MaxValue = 0
      MinValue = 0
      TabOrder = 1
      Value = 2
    end
    object edtProportion: TSpinEdit
      Left = 163
      Top = 158
      Width = 129
      Height = 22
      Increment = 100
      MaxValue = 0
      MinValue = 0
      TabOrder = 2
      Value = 500
    end
    object edtWaveSpeed: TSpinEdit
      Left = 163
      Top = 102
      Width = 129
      Height = 22
      Increment = 100
      MaxValue = 0
      MinValue = 0
      TabOrder = 3
      Value = 1160
    end
    object edtDumping: TSpinEdit
      Left = 163
      Top = 130
      Width = 129
      Height = 22
      Increment = 10
      MaxValue = 0
      MinValue = 0
      TabOrder = 4
      Value = 100
    end
    object edtDerivativeAlarm: TSpinEdit
      Left = 163
      Top = 45
      Width = 129
      Height = 22
      Increment = 100
      MaxValue = 0
      MinValue = 0
      TabOrder = 5
      Value = 15
    end
  end
  object btnRaw: TButton
    Left = 463
    Top = 332
    Width = 131
    Height = 25
    Caption = 'Pobierz zdarzenia'
    TabOrder = 3
    OnClick = btnRawClick
  end
  object cbDeriv1: TCheckBox
    Left = 810
    Top = 283
    Width = 42
    Height = 17
    Caption = 'PT1'#39
    TabOrder = 4
  end
  object cbDeriv2: TCheckBox
    Left = 810
    Top = 306
    Width = 42
    Height = 17
    Caption = 'PT2'#39
    TabOrder = 5
  end
  object cbDeriv3: TCheckBox
    Left = 913
    Top = 283
    Width = 43
    Height = 17
    Caption = 'PT3'#39
    TabOrder = 6
  end
  object cbDeriv4: TCheckBox
    Left = 914
    Top = 306
    Width = 43
    Height = 17
    Caption = 'PT4'#39
    TabOrder = 7
  end
  object pcTabs: TPageControl
    Left = 319
    Top = 8
    Width = 664
    Height = 322
    ActivePage = TabSheet1
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 8
    OnMouseDown = chaMouseDownOnTime
    object TabSheet1: TTabSheet
      Caption = 'Czasowe'
      object btnLoadTimePlot: TButton
        Left = 35
        Top = 3
        Width = 57
        Height = 25
        Caption = 'Wczytaj'
        TabOrder = 0
        OnClick = btnLoadTimePlotClick
      end
      object btnPrev: TButton
        Left = 3
        Top = 3
        Width = 26
        Height = 25
        Caption = '<'
        TabOrder = 1
        OnClick = btnPrevClick
      end
      object btnNext: TButton
        Left = 98
        Top = 3
        Width = 26
        Height = 25
        Caption = '>'
        TabOrder = 2
        OnClick = btnNextClick
      end
      object btnSaveToFile: TButton
        Left = 3
        Top = 34
        Width = 121
        Height = 25
        Caption = 'Zapisz do pliku'
        TabOrder = 3
        OnClick = btnSaveToFileClick
      end
      object chaTime: TChart
        Left = 130
        Top = 0
        Width = 526
        Height = 294
        Legend.Visible = False
        ScrollMouseButton = mbLeft
        Title.Text.Strings = (
          'Pressure 1')
        Title.Visible = False
        BottomAxis.Automatic = False
        BottomAxis.AutomaticMaximum = False
        BottomAxis.AutomaticMinimum = False
        BottomAxis.AxisValuesFormat = '#,##0.####'
        BottomAxis.DateTimeFormat = 'hh:mm:ss.zzz'
        BottomAxis.Increment = 0.000000011574074074
        BottomAxis.Maximum = 42987.000000000000000000
        BottomAxis.Minimum = 42963.000000000000000000
        LeftAxis.AxisValuesFormat = '#,##0.000000'
        View3D = False
        Zoom.MouseButton = mbRight
        Align = alRight
        TabOrder = 4
        Anchors = [akLeft, akTop, akRight, akBottom]
        OnMouseDown = chaMouseDownOnTime
        PrintMargins = (
          15
          31
          15
          31)
        ColorPaletteIndex = 13
        object FastLineSeries4: TFastLineSeries
          Marks.Arrow.Visible = True
          Marks.Callout.Brush.Color = clBlack
          Marks.Callout.Arrow.Visible = True
          Marks.Visible = False
          ShowInLegend = False
          Title = 'Pressure1'
          LinePen.Color = 10708548
          XValues.DateTime = True
          XValues.Name = 'X'
          XValues.Order = loAscending
          YValues.Name = 'Y'
          YValues.Order = loNone
          Data = {0000000000}
        end
        object LineSeries1: TLineSeries
          Marks.Arrow.Visible = True
          Marks.Callout.Brush.Color = clBlack
          Marks.Callout.Arrow.Visible = True
          Marks.Visible = False
          Title = 'Pressure2'
          Pointer.Brush.Gradient.EndColor = 3513587
          Pointer.Gradient.EndColor = 3513587
          Pointer.InflateMargins = True
          Pointer.Style = psRectangle
          Pointer.Visible = False
          XValues.DateTime = True
          XValues.Name = 'X'
          XValues.Order = loAscending
          YValues.Name = 'Y'
          YValues.Order = loNone
          Data = {
            01190000000000000060FAE44000000000004A90400000000080FAE440000000
            00009E914000000000A0FAE4400000000000A4904000000000C0FAE440000000
            0000A4904000000000E0FAE44000000000003091400000000000FBE440000000
            0000EA90400000000020FBE44000000000002092400000000040FBE440000000
            0000A693400000000060FBE44000000000002A92400000000080FBE440000000
            0000AC924000000000A0FBE440000000000006934000000000C0FBE440000000
            000042934000000000E0FBE4400000000000DE92400000000000FCE440000000
            00006291400000000020FCE44000000000008E92400000000040FCE440000000
            00007092400000000060FCE4400000000000E090400000000080FCE440000000
            00008C8E4000000000A0FCE44000000000009A904000000000C0FCE440000000
            0000C6914000000000E0FCE4400000000000B88F400000000000FDE440000000
            0000E88C400000000020FDE4400000000000B08D400000000040FDE440000000
            00009A90400000000060FDE44000000000000C9240}
        end
        object Series6: TLineSeries
          Marks.Arrow.Visible = True
          Marks.Callout.Brush.Color = clBlack
          Marks.Callout.Arrow.Visible = True
          Marks.Visible = False
          SeriesColor = clOlive
          Title = 'Pressure3'
          Pointer.InflateMargins = True
          Pointer.Style = psRectangle
          Pointer.Visible = False
          XValues.DateTime = True
          XValues.Name = 'X'
          XValues.Order = loAscending
          YValues.Name = 'Y'
          YValues.Order = loNone
        end
        object Series7: TLineSeries
          Marks.Arrow.Visible = True
          Marks.Callout.Brush.Color = clBlack
          Marks.Callout.Arrow.Visible = True
          Marks.Visible = False
          SeriesColor = clBlack
          Title = 'Pressure4'
          Pointer.InflateMargins = True
          Pointer.Style = psRectangle
          Pointer.Visible = False
          XValues.DateTime = True
          XValues.Name = 'X'
          XValues.Order = loAscending
          YValues.Name = 'Y'
          YValues.Order = loNone
        end
        object Series8: TLineSeries
          Marks.Arrow.Visible = True
          Marks.Callout.Brush.Color = clBlack
          Marks.Callout.Arrow.Visible = True
          Marks.Visible = False
          SeriesColor = 13553358
          Title = 'Deriv1'
          ValueFormat = '#,##0.####'
          VertAxis = aRightAxis
          Pointer.Brush.Gradient.EndColor = 13553358
          Pointer.Gradient.EndColor = 13553358
          Pointer.InflateMargins = True
          Pointer.Style = psRectangle
          Pointer.Visible = False
          XValues.DateTime = True
          XValues.Name = 'X'
          XValues.Order = loAscending
          YValues.Name = 'Y'
          YValues.Order = loNone
        end
        object Series1: TLineSeries
          Marks.Arrow.Visible = True
          Marks.Callout.Brush.Color = clBlack
          Marks.Callout.Arrow.Visible = True
          Marks.Visible = False
          SeriesColor = 13553358
          Title = 'Deriv2'
          ValueFormat = '#,##0.####'
          VertAxis = aRightAxis
          Pointer.Brush.Gradient.EndColor = 13553358
          Pointer.Gradient.EndColor = 13553358
          Pointer.InflateMargins = True
          Pointer.Style = psRectangle
          Pointer.Visible = False
          XValues.DateTime = True
          XValues.Name = 'X'
          XValues.Order = loAscending
          YValues.Name = 'Y'
          YValues.Order = loNone
        end
        object Series2: TLineSeries
          Marks.Arrow.Visible = True
          Marks.Callout.Brush.Color = clBlack
          Marks.Callout.Arrow.Visible = True
          Marks.Visible = False
          SeriesColor = 13553358
          Title = 'Deriv3'
          ValueFormat = '#,##0.####'
          VertAxis = aRightAxis
          Pointer.Brush.Gradient.EndColor = 13553358
          Pointer.Gradient.EndColor = 13553358
          Pointer.InflateMargins = True
          Pointer.Style = psRectangle
          Pointer.Visible = False
          XValues.DateTime = True
          XValues.Name = 'X'
          XValues.Order = loAscending
          YValues.Name = 'Y'
          YValues.Order = loNone
        end
        object Series9: TLineSeries
          Marks.Arrow.Visible = True
          Marks.Callout.Brush.Color = clBlack
          Marks.Callout.Arrow.Visible = True
          Marks.Visible = False
          SeriesColor = 13553358
          Title = 'Deriv4'
          VertAxis = aRightAxis
          Pointer.Brush.Gradient.EndColor = 13553358
          Pointer.Gradient.EndColor = 13553358
          Pointer.InflateMargins = True
          Pointer.Style = psRectangle
          Pointer.Visible = False
          XValues.DateTime = True
          XValues.Name = 'X'
          XValues.Order = loAscending
          YValues.Name = 'Y'
          YValues.Order = loNone
          Data = {
            01190000000000000060FAE4407F6ABC74F3BD7F400000000080FAE440B29DEF
            A786787B4000000000A0FAE440AAF1D24D72DF7A4000000000C0FAE440CFF753
            E38539784000000000E0FAE4407B14AE47A11A7A400000000000FBE440F0A7C6
            4BD79D7A400000000020FBE440B39DEFA786787B400000000040FBE440A01A2F
            DDB47477400000000060FBE440C520B072C8CE74400000000080FBE440C74B37
            8971A0774000000000A0FBE440FCA9F1D2AD2C764000000000C0FBE440068195
            436B97794000000000E0FBE440B0726891DDA678400000000000FCE440D9CEF7
            5343A47B400000000020FCE4409EEFA7C69B507F400000000040FCE4400AD7A3
            70BD5281400000000060FCE44066666666B60A80400000000080FCE440CAA145
            B6C3437D4000000000A0FCE440A3703D0A07187D4000000000C0FCE4408D976E
            127336804000000000E0FCE440CDCCCCCC6C2D82400000000000FDE440CDCCCC
            CC6C2D82400000000020FDE44023DBF97EFA1D83400000000040FDE440CDCCCC
            CC6C2D82400000000060FDE4408D976E1273368040}
        end
      end
      object lbTrends: TCheckListBox
        Left = 3
        Top = 65
        Width = 121
        Height = 226
        ItemHeight = 13
        TabOrder = 5
      end
    end
    object TimeSlice: TTabSheet
      Caption = 'Przekr'#243'j - czas'
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Label14: TLabel
        Left = 227
        Top = 278
        Width = 74
        Height = 13
        Alignment = taRightJustify
        Caption = 'Przekr'#243'j - czas:'
      end
      object lblSliceTime: TLabel
        Left = 328
        Top = 278
        Width = 119
        Height = 13
        AutoSize = False
      end
      object chaTimeSlice: TChart
        Left = 0
        Top = 0
        Width = 656
        Height = 260
        Legend.Visible = False
        ScrollMouseButton = mbLeft
        Title.Text.Strings = (
          'Pressure 1')
        Title.Visible = False
        BottomAxis.DateTimeFormat = 'hh:mm:ss.ms'
        LeftAxis.AxisValuesFormat = '#,##0.000000'
        View3D = False
        Zoom.MouseButton = mbRight
        Align = alTop
        TabOrder = 0
        OnMouseDown = chaMouseDownOnPos
        PrintMargins = (
          15
          24
          15
          24)
        ColorPaletteIndex = 13
        object FastLineSeries1: TFastLineSeries
          Marks.Arrow.Visible = True
          Marks.Callout.Brush.Color = clBlack
          Marks.Callout.Arrow.Visible = True
          Marks.Visible = False
          ShowInLegend = False
          Title = 'Correlation'
          LinePen.Color = 10708548
          XValues.Name = 'X'
          XValues.Order = loAscending
          YValues.Name = 'Y'
          YValues.Order = loNone
          Data = {0000000000}
        end
        object Series4: TFastLineSeries
          Marks.Arrow.Visible = True
          Marks.Callout.Brush.Color = clBlack
          Marks.Callout.Arrow.Visible = True
          Marks.Visible = False
          SeriesColor = clRed
          ShowInLegend = False
          Title = 'Correlation'
          LinePen.Color = clRed
          XValues.Name = 'X'
          XValues.Order = loAscending
          YValues.Name = 'Y'
          YValues.Order = loNone
          Data = {0000000000}
        end
      end
      object btnReadTimeSlice: TButton
        Left = 3
        Top = 266
        Width = 131
        Height = 25
        Caption = 'Wczytaj Przekr'#243'j 1'
        TabOrder = 1
        OnClick = btnReadTimeSliceClick
      end
      object btnReadTimeSliceMinus: TButton
        Left = 148
        Top = 266
        Width = 29
        Height = 25
        Caption = '-'
        TabOrder = 2
        OnClick = btnReadTimeSliceClick
      end
      object btnReadTimeSlicePlus: TButton
        Left = 183
        Top = 266
        Width = 29
        Height = 25
        Caption = '+'
        TabOrder = 3
        OnClick = btnReadTimeSliceClick
      end
    end
    object tabPosSlice: TTabSheet
      Caption = 'Przekr'#243'j - pozycja'
      ImageIndex = 3
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Label9: TLabel
        Left = 219
        Top = 278
        Width = 74
        Height = 13
        Alignment = taRightJustify
        Caption = 'Przekr'#243'j - poz.:'
      end
      object lblSlicePos: TLabel
        Left = 307
        Top = 278
        Width = 119
        Height = 13
        AutoSize = False
      end
      object chaPosSlice: TChart
        Left = 0
        Top = 0
        Width = 656
        Height = 260
        Legend.Visible = False
        ScrollMouseButton = mbLeft
        Title.Text.Strings = (
          'Pressure 1')
        Title.Visible = False
        BottomAxis.DateTimeFormat = 'hh:mm:ss.zzz'
        BottomAxis.Increment = 0.000000011574074074
        LeftAxis.AxisValuesFormat = '#,##0.000000'
        View3D = False
        Zoom.MouseButton = mbRight
        Align = alTop
        TabOrder = 0
        OnMouseDown = chaMouseDownOnTime
        PrintMargins = (
          15
          24
          15
          24)
        ColorPaletteIndex = 13
        object FastLineSeries3: TFastLineSeries
          Marks.Arrow.Visible = True
          Marks.Callout.Brush.Color = clBlack
          Marks.Callout.Arrow.Visible = True
          Marks.Visible = False
          ShowInLegend = False
          Title = 'Correlation'
          LinePen.Color = 10708548
          XValues.DateTime = True
          XValues.Name = 'X'
          XValues.Order = loAscending
          YValues.Name = 'Y'
          YValues.Order = loNone
          Data = {0000000000}
        end
        object Series5: TFastLineSeries
          Marks.Arrow.Visible = True
          Marks.Callout.Brush.Color = clBlack
          Marks.Callout.Arrow.Visible = True
          Marks.Visible = False
          SeriesColor = clRed
          ShowInLegend = False
          Title = 'Correlation'
          LinePen.Color = clRed
          XValues.DateTime = True
          XValues.Name = 'X'
          XValues.Order = loAscending
          YValues.Name = 'Y'
          YValues.Order = loNone
          Data = {0000000000}
        end
      end
      object btnReadPosSlice: TButton
        Left = 3
        Top = 266
        Width = 131
        Height = 25
        Caption = 'Wczytaj Przekr'#243'j'
        TabOrder = 1
        OnClick = btnReadPosSliceClick
      end
      object btnReadPosSliceMinus: TButton
        Left = 140
        Top = 266
        Width = 29
        Height = 25
        Caption = '-'
        TabOrder = 2
        OnClick = btnReadPosSliceClick
      end
      object btnReadPosSlicePlus: TButton
        Left = 175
        Top = 266
        Width = 29
        Height = 25
        Caption = '+'
        TabOrder = 3
        OnClick = btnReadPosSliceClick
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'Warto'#347#263' maks.'
      ImageIndex = 2
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        656
        294)
      object chaMaximum: TChart
        Left = 130
        Top = 0
        Width = 526
        Height = 260
        Legend.Visible = False
        ScrollMouseButton = mbLeft
        Title.Text.Strings = (
          'Pressure 1')
        Title.Visible = False
        BottomAxis.DateTimeFormat = 'hh:mm:ss.zzz'
        BottomAxis.Increment = 0.000000011574074074
        LeftAxis.AxisValuesFormat = '#,##0.000000'
        View3D = False
        Zoom.MouseButton = mbRight
        TabOrder = 0
        Anchors = [akLeft, akTop, akRight, akBottom]
        OnMouseDown = chaMouseDownOnTime
        PrintMargins = (
          15
          24
          15
          24)
        ColorPaletteIndex = 13
        object FastLineSeries2: TFastLineSeries
          Marks.Arrow.Visible = True
          Marks.Callout.Brush.Color = clBlack
          Marks.Callout.Arrow.Visible = True
          Marks.Visible = False
          SeriesColor = clRed
          ShowInLegend = False
          Title = 'MaxValue'
          LinePen.Color = clRed
          XValues.DateTime = True
          XValues.Name = 'X'
          XValues.Order = loAscending
          YValues.Name = 'Y'
          YValues.Order = loNone
          Data = {0000000000}
        end
        object Series3: TFastLineSeries
          Marks.Arrow.Visible = True
          Marks.Callout.Brush.Color = clBlack
          Marks.Callout.Arrow.Visible = True
          Marks.Visible = False
          SeriesColor = clBlue
          ShowInLegend = False
          Title = 'MaxPos'
          VertAxis = aRightAxis
          LinePen.Color = clBlue
          XValues.DateTime = True
          XValues.Name = 'X'
          XValues.Order = loAscending
          YValues.Name = 'Y'
          YValues.Order = loNone
          Data = {0000000000}
        end
      end
      object btnMax: TButton
        Left = 3
        Top = 266
        Width = 131
        Height = 25
        Caption = 'Szukaj maksim'#243'w'
        TabOrder = 1
        OnClick = btnMaxClick
      end
      object btnMax2D: TButton
        Left = 140
        Top = 266
        Width = 131
        Height = 25
        Caption = 'Szukaj maksim'#243'w 2D'
        TabOrder = 2
        OnClick = btnMax2DClick
      end
      object lbMaximums: TListBox
        Left = 3
        Top = 0
        Width = 121
        Height = 260
        Anchors = [akLeft, akTop, akBottom]
        ItemHeight = 13
        TabOrder = 3
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Odbicia'
      ImageIndex = 4
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        656
        294)
      object Label8: TLabel
        Left = 3
        Top = 243
        Width = 47
        Height = 13
        AutoSize = False
        Caption = 'Przes.(s):'
      end
      object Label15: TLabel
        Left = 3
        Top = 273
        Width = 47
        Height = 13
        AutoSize = False
        Caption = 'Wzmoc.:'
      end
      object chaReflections: TChart
        Left = 184
        Top = 0
        Width = 472
        Height = 294
        Legend.Visible = False
        ScrollMouseButton = mbLeft
        Title.Text.Strings = (
          'Pressure 1')
        Title.Visible = False
        BottomAxis.AxisValuesFormat = '#,##0.####'
        BottomAxis.DateTimeFormat = 'hh:mm:ss.zzz'
        BottomAxis.Increment = 0.000000011574074074
        LeftAxis.AxisValuesFormat = '#,##0.000000'
        View3D = False
        Zoom.MouseButton = mbRight
        OnAfterDraw = chaTimeAfterDraw
        Align = alRight
        TabOrder = 0
        Anchors = [akLeft, akTop, akRight, akBottom]
        OnMouseDown = chaMouseDownOnTime
        PrintMargins = (
          15
          31
          15
          31)
        ColorPaletteIndex = 13
      end
      object lbReflections: TCheckListBox
        Left = 3
        Top = 30
        Width = 175
        Height = 149
        OnClickCheck = lbReflectionsClickCheck
        Anchors = [akLeft, akTop, akBottom]
        ItemHeight = 13
        TabOrder = 1
        OnClick = lbReflectionsClick
      end
      object btnAddRef: TButton
        Left = 3
        Top = 185
        Width = 55
        Height = 25
        Caption = 'Dodaj'
        TabOrder = 2
        OnClick = btnAddRefClick
      end
      object btnDelRef: TButton
        Left = 64
        Top = 185
        Width = 49
        Height = 25
        Caption = 'Usu'#324
        TabOrder = 3
        OnClick = btnDelRefClick
      end
      object edtOffsetRef: TEdit
        Left = 56
        Top = 243
        Width = 122
        Height = 21
        TabOrder = 4
        Text = '0'
        OnExit = FloatEditExit
      end
      object edtFactorRef: TEdit
        Left = 56
        Top = 270
        Width = 122
        Height = 21
        TabOrder = 5
        Text = '1'
        OnExit = FloatEditExit
      end
      object cbTrendsRef: TComboBox
        Left = 3
        Top = 216
        Width = 175
        Height = 21
        Style = csDropDownList
        TabOrder = 6
      end
      object dtStartRef: TcxDateEdit
        Left = 3
        Top = 3
        EditValue = 43145.4298611111d
        Properties.DateButtons = [btnNow]
        Properties.DateOnError = deNull
        Properties.ImmediatePost = True
        Properties.InputKind = ikStandard
        Properties.Kind = ckDateTime
        Properties.PostPopupValueOnTab = True
        TabOrder = 7
        Width = 175
      end
      object btnUpdateRef: TButton
        Left = 119
        Top = 185
        Width = 51
        Height = 25
        Caption = 'Zapisz'
        TabOrder = 8
        OnClick = btnUpdateRefClick
      end
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 247
    Width = 305
    Height = 105
    Caption = 'Lista segment'#243'w'
    TabOrder = 9
    object lbSegments: TListBox
      Left = 13
      Top = 25
      Width = 279
      Height = 77
      ItemHeight = 13
      TabOrder = 0
      OnClick = lbSegmentsClick
    end
  end
  object GroupBox4: TGroupBox
    Left = 8
    Top = 8
    Width = 305
    Height = 109
    Caption = 'Zdarzenia'
    TabOrder = 10
    object ListBox2: TListBox
      Left = 13
      Top = 24
      Width = 279
      Height = 73
      ItemHeight = 13
      TabOrder = 0
    end
  end
  object GroupBox5: TGroupBox
    Left = 8
    Top = 358
    Width = 305
    Height = 107
    Caption = 'Segment'
    TabOrder = 11
    object Label18: TLabel
      Left = 11
      Top = 15
      Width = 146
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Pocz'#261'tek [m]'
      Layout = tlCenter
    end
    object Label6: TLabel
      Left = 11
      Top = 43
      Width = 146
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Koniec [m]'
      Layout = tlCenter
    end
    object Label5: TLabel
      Left = 11
      Top = 70
      Width = 146
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Pr'#243'bek w pozycji'
      Layout = tlCenter
    end
    object edtMinPos: TSpinEdit
      Left = 163
      Top = 15
      Width = 129
      Height = 22
      Increment = 100
      MaxValue = 0
      MinValue = 0
      TabOrder = 0
      Value = 0
    end
    object edtMaxPos: TSpinEdit
      Left = 163
      Top = 43
      Width = 129
      Height = 22
      Increment = 100
      MaxValue = 0
      MinValue = 0
      TabOrder = 1
      Value = 16000
    end
    object edtLengthResolution: TSpinEdit
      Left = 163
      Top = 70
      Width = 129
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 2
      Value = 1600
    end
  end
  object btnCalcWindow: TButton
    Left = 600
    Top = 332
    Width = 127
    Height = 25
    Caption = 'Przelicz okno'
    TabOrder = 12
    OnClick = btnCalcWindowClick
  end
  object cbMethods: TcxCheckComboBox
    Left = 733
    Top = 336
    Properties.Items = <
      item
        Description = 'Detekcja fali'
        ShortDescription = 'llWave'
      end
      item
        Description = 'Bilans'
        ShortDescription = 'llMass'
      end
      item
        Description = 'Maska ruch'#243'w technologicznych'
        ShortDescription = 'llMask'
      end>
    Properties.OnChange = cxCheckComboBox1PropertiesChange
    EditValue = 2
    TabOrder = 13
    Width = 121
  end
  object FileOpenDialog1: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoPickFolders]
    Left = 616
    Top = 88
  end
  object TeeGDIPlus1: TTeeGDIPlus
    Left = 672
    Top = 88
  end
  object conMain: TMSConnection
    Database = 'NefrytLDSKFR'
    Options.Provider = prNativeClient
    Options.NativeClientVerison = ncAuto
    Username = 'sa'
    Password = 'Onyks$us'
    Server = '10.80.30.96'
    ConnectDialog = MSConnectDialog1
    LoginPrompt = False
    Left = 832
    Top = 96
  end
  object AppLogs: TAppLogs
    MaxLogFileSize = 10
    MaxLogFileCount = 10
    MaxLogFileAge = 14
    VerbosityLevel = vlWarning
    WriteRepeatedMessages = True
    Left = 784
    Top = 80
  end
  object IniParamSet: TIniParamSet
    Left = 734
    Top = 96
  end
  object dlgSaveData: TSaveTextFileDialog
    DefaultExt = 'txt'
    Filter = 'Tekstowe|*.txt|Dane|*.dat'
    Left = 552
    Top = 88
  end
  object MSConnectDialog1: TMSConnectDialog
    Caption = 'Connect'
    UsernameLabel = 'User Name'
    PasswordLabel = 'Password'
    ServerLabel = 'Server'
    DatabaseLabel = 'Database'
    ConnectButton = 'Connect'
    CancelButton = 'Cancel'
    Left = 896
    Top = 176
  end
end
