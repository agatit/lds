object datLDS: TdatLDS
  OldCreateOrder = False
  Height = 373
  Width = 586
  object qryQuickTrendDefs: TMSQuery
    SQLInsert.Strings = (
      'INSERT INTO QUICK_TREND_DEFS'
      '  (ID, NAME, SAMPLES_PER_SEC)'
      'VALUES'
      '  (:ID, :NAME, :SAMPLES_PER_SEC)')
    SQLDelete.Strings = (
      'DELETE FROM QUICK_TREND_DEFS'
      'WHERE'
      '  ID = :Old_ID')
    SQLUpdate.Strings = (
      'UPDATE QUICK_TREND_DEFS'
      'SET'
      '  ID = :ID, NAME = :NAME, SAMPLES_PER_SEC = :SAMPLES_PER_SEC'
      'WHERE'
      '  ID = :Old_ID')
    SQLRefresh.Strings = (
      'SELECT ID, NAME, SAMPLES_PER_SEC FROM QUICK_TREND_DEFS'
      'WHERE'
      '  ID = :ID')
    SQLLock.Strings = (
      'SELECT * FROM QUICK_TREND_DEFS'
      'WITH (UPDLOCK, ROWLOCK, HOLDLOCK)'
      'WHERE'
      '  ID = :Old_ID')
    Connection = connTest
    SQL.Strings = (
      'SELECT'
      '    QTD.ID'
      '    ,QTD.NAME'
      '    ,QTD.TIME_EXPONENT'
      '    ,QTD.RAW_MIN'
      '    ,QTD.RAW_MAX'
      '    ,QTD.SCALED_MIN'
      '    ,QTD.SCALED_MAX'
      '    ,QMP.HOST_NAME'
      '    ,QMP.PORT_NO'
      '    ,QMP.SLAVE_ID'
      '    ,QTD.BEGIN_ADDR'
      '    ,QTD.SIUNIT_TID SIUNIT'
      'FROM QUICK_TREND_DEFS QTD'
      
        'LEFT JOIN QT_MODBUS_PARAMETERS QMP ON QTD.MODBUS_PARAMETER_ID = ' +
        'QMP.ID')
    Left = 184
    Top = 152
    object qryQuickTrendDefsID: TIntegerField
      FieldName = 'ID'
    end
    object qryQuickTrendDefsNAME: TStringField
      FieldName = 'NAME'
      Size = 30
    end
    object qryQuickTrendDefsTIME_EXPONENT: TIntegerField
      FieldName = 'TIME_EXPONENT'
    end
    object qryQuickTrendDefsRAW_MIN: TIntegerField
      FieldName = 'RAW_MIN'
    end
    object qryQuickTrendDefsRAW_MAX: TIntegerField
      FieldName = 'RAW_MAX'
    end
    object qryQuickTrendDefsSCALED_MIN: TFloatField
      FieldName = 'SCALED_MIN'
    end
    object qryQuickTrendDefsSCALED_MAX: TFloatField
      FieldName = 'SCALED_MAX'
    end
    object qryQuickTrendDefsHOST_NAME: TStringField
      FieldName = 'HOST_NAME'
      ReadOnly = True
      Size = 50
    end
    object qryQuickTrendDefsPORT_NO: TIntegerField
      FieldName = 'PORT_NO'
      ReadOnly = True
    end
    object qryQuickTrendDefsSLAVE_ID: TIntegerField
      FieldName = 'SLAVE_ID'
      ReadOnly = True
    end
    object qryQuickTrendDefsBEGIN_ADDR: TIntegerField
      FieldName = 'BEGIN_ADDR'
    end
    object qryQuickTrendDefsSIUNIT: TStringField
      FieldName = 'SIUNIT'
      FixedChar = True
      Size = 8
    end
  end
  object qryPipelines: TMSQuery
    SQLInsert.Strings = (
      'INSERT INTO QUICK_TRENDS'
      '  (TREND_DEF_ID, TIME, DATA)'
      'VALUES'
      '  (:TREND_DEF_ID, :TIME, :DATA)')
    SQLDelete.Strings = (
      'DELETE FROM QUICK_TRENDS'
      'WHERE'
      '  TREND_DEF_ID = :Old_TREND_DEF_ID AND TIME = :Old_TIME')
    SQLUpdate.Strings = (
      'UPDATE QUICK_TRENDS'
      'SET'
      '  TREND_DEF_ID = :TREND_DEF_ID, TIME = :TIME, DATA = :DATA'
      'WHERE'
      '  TREND_DEF_ID = :Old_TREND_DEF_ID AND TIME = :Old_TIME')
    SQLRefresh.Strings = (
      'SELECT TREND_DEF_ID, TIME, DATA FROM QUICK_TRENDS'
      'WHERE'
      '  TREND_DEF_ID = :TREND_DEF_ID AND TIME = :TIME')
    SQLLock.Strings = (
      'SELECT * FROM QUICK_TRENDS'
      'WITH (UPDLOCK, ROWLOCK, HOLDLOCK)'
      'WHERE'
      '  TREND_DEF_ID = :Old_TREND_DEF_ID AND TIME = :Old_TIME')
    Connection = connTest
    SQL.Strings = (
      'SELECT *'
      'FROM'
      '    lds.Pipelines')
    Left = 184
    Top = 96
    object qryPipelinesID: TIntegerField
      AutoGenerateValue = arAutoInc
      FieldName = 'ID'
      ReadOnly = True
    end
    object qryPipelinesPIPELINE_ID: TIntegerField
      FieldName = 'PIPELINE_ID'
    end
    object qryPipelinesSYMBOL: TStringField
      FieldName = 'SYMBOL'
      Size = 30
    end
    object qryPipelinesDESCRIPTION: TStringField
      FieldName = 'DESCRIPTION'
      Size = 100
    end
    object qryPipelinesPRESSURE1_ID: TIntegerField
      FieldName = 'PRESSURE1_ID'
    end
    object qryPipelinesTEMPERATURE1_ID: TIntegerField
      FieldName = 'TEMPERATURE1_ID'
    end
    object qryPipelinesFLOW1_ID: TIntegerField
      FieldName = 'FLOW1_ID'
    end
    object qryPipelinesDENSITY1_ID: TIntegerField
      FieldName = 'DENSITY1_ID'
    end
    object qryPipelinesVALVE1_ID: TIntegerField
      FieldName = 'VALVE1_ID'
    end
    object qryPipelinesPUMP1_ID: TIntegerField
      FieldName = 'PUMP1_ID'
    end
    object qryPipelinesPRESSURE2_ID: TIntegerField
      FieldName = 'PRESSURE2_ID'
    end
    object qryPipelinesTEMPERATURE2_ID: TIntegerField
      FieldName = 'TEMPERATURE2_ID'
    end
    object qryPipelinesFLOW2_ID: TIntegerField
      FieldName = 'FLOW2_ID'
    end
    object qryPipelinesDENSITY2_ID: TIntegerField
      FieldName = 'DENSITY2_ID'
    end
    object qryPipelinesVALVE2_ID: TIntegerField
      FieldName = 'VALVE2_ID'
    end
    object qryPipelinesPUMP2_ID: TIntegerField
      FieldName = 'PUMP2_ID'
    end
    object qryPipelinesBEGIN_POS: TFloatField
      FieldName = 'BEGIN_POS'
    end
    object qryPipelinesEND_POS: TFloatField
      FieldName = 'END_POS'
    end
    object qryPipelinesWAVE_METHOD_RATIO: TFloatField
      FieldName = 'WAVE_METHOD_RATIO'
    end
    object qryPipelinesMASS_METHOD_RATIO: TFloatField
      FieldName = 'MASS_METHOD_RATIO'
    end
    object qryPipelinesWAVE_METHOD_TYPE: TIntegerField
      FieldName = 'WAVE_METHOD_TYPE'
    end
    object qryPipelinesMASS_METHOD_TYPE: TIntegerField
      FieldName = 'MASS_METHOD_TYPE'
    end
    object qryPipelinesWAVE_METHOD_MIN: TFloatField
      FieldName = 'WAVE_METHOD_MIN'
    end
    object qryPipelinesWAVE_METHOD_MAX: TFloatField
      FieldName = 'WAVE_METHOD_MAX'
    end
    object qryPipelinesWAVE_METHOD_BASE_SPEED: TFloatField
      FieldName = 'WAVE_METHOD_BASE_SPEED'
    end
    object qryPipelinesWAVE_METHOD_ALARM: TFloatField
      FieldName = 'WAVE_METHOD_ALARM'
    end
  end
  object connTest: TMSConnection
    Database = 'NefrytLDSKFR'
    Options.Provider = prNativeClient
    Options.NativeClientVerison = ncAuto
    Username = 'sa'
    Password = 'Onyks$us'
    Server = '10.80.30.96'
    LoginPrompt = False
    Left = 320
    Top = 32
  end
  object qryQuickTrendCalcs: TMSQuery
    SQLInsert.Strings = (
      'INSERT INTO QUICK_TREND_DEFS'
      '  (ID, NAME, SAMPLES_PER_SEC)'
      'VALUES'
      '  (:ID, :NAME, :SAMPLES_PER_SEC)')
    SQLDelete.Strings = (
      'DELETE FROM QUICK_TREND_DEFS'
      'WHERE'
      '  ID = :Old_ID')
    SQLUpdate.Strings = (
      'UPDATE QUICK_TREND_DEFS'
      'SET'
      '  ID = :ID, NAME = :NAME, SAMPLES_PER_SEC = :SAMPLES_PER_SEC'
      'WHERE'
      '  ID = :Old_ID')
    SQLRefresh.Strings = (
      'SELECT ID, NAME, SAMPLES_PER_SEC FROM QUICK_TREND_DEFS'
      'WHERE'
      '  ID = :ID')
    SQLLock.Strings = (
      'SELECT * FROM QUICK_TREND_DEFS'
      'WITH (UPDLOCK, ROWLOCK, HOLDLOCK)'
      'WHERE'
      '  ID = :Old_ID')
    Connection = connTest
    SQL.Strings = (
      'SELECT *'
      'FROM QUICK_TREND_CALCS')
    Left = 320
    Top = 152
    object qryQuickTrendCalcsID: TIntegerField
      FieldName = 'ID'
    end
    object qryQuickTrendCalcsMETHOD: TStringField
      FieldName = 'METHOD'
      FixedChar = True
      Size = 5
    end
    object qryQuickTrendCalcsPARAM1: TIntegerField
      FieldName = 'PARAM1'
    end
    object qryQuickTrendCalcsPARAM2: TIntegerField
      FieldName = 'PARAM2'
    end
    object qryQuickTrendCalcsNAME: TStringField
      FieldName = 'NAME'
      Size = 30
    end
    object qryQuickTrendCalcsSIUNIT: TStringField
      FieldName = 'SIUNIT'
      FixedChar = True
      Size = 8
    end
    object qryQuickTrendCalcsWINDOW: TIntegerField
      FieldName = 'WINDOW'
    end
    object qryQuickTrendCalcsTIME_EXPONENT: TIntegerField
      FieldName = 'TIME_EXPONENT'
    end
  end
  object qryPipelineNodes: TMSQuery
    Connection = connTest
    SQL.Strings = (
      'select *'
      'from PIPELINE_NODES'
      'where PIPELINE_SEGMENT_ID = :PIPELINE_SEGMENT_ID')
    Left = 320
    Top = 96
    ParamData = <
      item
        DataType = ftInteger
        Name = 'PIPELINE_SEGMENT_ID'
      end>
    object qryPipelineNodesID: TIntegerField
      FieldName = 'ID'
    end
    object qryPipelineNodesTYPE: TStringField
      FieldName = 'TYPE'
      FixedChar = True
      Size = 5
    end
    object qryPipelineNodesPOSITION: TFloatField
      FieldName = 'POSITION'
    end
    object qryPipelineNodesTREND_ID: TIntegerField
      FieldName = 'TREND_ID'
    end
    object qryPipelineNodesCALC_TREND_ID: TIntegerField
      FieldName = 'CALC_TREND_ID'
    end
  end
end
