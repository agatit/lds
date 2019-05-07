//******************************************************************************
// Author:		    Stefan Marasek
//
// Maintainer:		Stefan Marasek
//
// Creation time:	20-02-2007
//
// Description:	Constants used in Onyks2.
//
// Project list:	OnyksDatalink
//
// Kody Ÿród³owe s¹ w³asnoœci¹ firmy AGAT sp. z o. o.
// Wykorzystanie poni¿szego kodu mo¿liwe jest na warunkach odpowiedniej umowy
// licencyjnej.
//******************************************************************************

unit OnyksDatalinkConst;

interface

const

{Event definition constants}
ALRH = '1';
ALRL = '2';
WRNH = '3';
WRNL = '4';
CRCT = '5';
INCR = '6';
FLDH = '13';
FLDL = '14';
EMRG = '15';

{Event state definition constants}
ACTV = '1';
ACKD = '2';
INCT = '3';

{SQL constansts}
TRENDSQL = 'INSERT INTO obj.Trend (TrendDefID, ObjectID, Date, Value) VALUES (';
EVENTSQL1 = 'EXECUTE [obj].[pLogEvent] @ObjectPLCID=';
EVENTSQL2 = ', @EventDefPLCID=';
EVENTSQL3 = ', @EventStateID=';
EVENTSQL4 = ', @Date=''';
EVENTSQL5 = ''', @UserID=';

//EVENTSQL = 'INSERT INTO Event (EventDefID, EventStateID, Date) VALUES (';

WATCHDOG_ITEM = '_System._Time_Second';

// Watchdog command to log arbitrary string
LOG_ADD = 'EVENT LOG ';

// Watchdog command to set control semaphore
SEM_REG = 'SEMAPHORE Register Sem';

// Watchdog command to set semaphore timeout
SEM_ADD_INT_1 = 'SEMAPHORE AddInterval Sem';

// Watchdog command to set semaphore timeout
SEM_ADD_INT_2 = ' 1 1 00:00:00 23:59:59 ';

// Watchdog command to generate semaphore signal
SEM_SET = 'SEMAPHORE SET Sem';

// String key for INI tags AES coding
AES_KEY = 'logger4logger';


// Error codes for watchdog (3 first event letters)

// Error while reading ini file configuration
ERROR_INI = 'INI';

// Error while writing local log
ERROR_LOG = 'LOG';

// Checksum computation error
ERROR_CSM = 'CRC';

// Error while executing stored DB procedure
ERROR_PROC_EXEC = 'PRO';

// Error while connecting to DB
ERROR_DB_CON = 'DBC';

// Error while disconnecting from DB
ERROR_DB_DISCON = 'DBD';

// Error - service was stopped
ERROR_STOPPED = 'STO';

// Error - service was paused
ERROR_PAUSED = 'PAU';

type

 {Class stores input parameters for database configuration}
  TDBConfig = record
    Server, Database, Username, Password, LogDirectory : string;
  end;

  {Class stores input parameters for OPC server configuration}
  TOPCConfig = record
    OPCComputerName, OPCServerName : string;
  end;

  {Class stores input parameters for text file log configuration}
  TLogConfig = record
    LogBadQuality, LogDirectory : string;
    LogFileHours : Integer;
  end;

  {Class stores input parameters for database backup configuration}
  TBackupConfig = record
    Backup : string;
    BackupHours : Integer;
  end;

  TOPCVariable = class(TObject)
    ID: Integer; //TrendDefID or EventDefID
    ObjectID: Integer;
    OPCName: String;
    OPCAckName: String;
    Caption: String;

    Value: Real;
    Date: TDateTime;
    Quality : Boolean;

    Active: Boolean;
    Acknowledged: Boolean;

    RangeLo: Real;
    RangeHi: Real;
    AlarmLo: Real;
    AlarmHi: Real;
    WarningLo: Real;
    WarningHi: Real;
    Threshold: Real;
    Interval: Integer;

    OldValue: Real;
    OldDate: TDateTime;
    OldQuality: Boolean;
    OldActive: Boolean;
    OldAcknowledged: Boolean;
    OldAlarmDef: String;
  end;


implementation

end.
