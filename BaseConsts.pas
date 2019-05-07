{*------------------------------------------------------------------------------
Sta�e aplikacji
@author   Adam Pietrzko
@version  2007/11
@comment  AGAT IT S.A. 2010 (c) Wszystkie prawa zastrze�one
-------------------------------------------------------------------------------}

unit BaseConsts;

interface

uses
  Classes, DB, Graphics;
 const
  {*----------------------------------------------------------------------------
  Nazwa kolumny z precyzj� liczby zmiennoprzecinkowej
  -----------------------------------------------------------------------------}
  PRECISION_META_COLUMN = 'DATA_PRECISION';

  {*----------------------------------------------------------------------------
  Nazwa kolumny ze skal� liczby zmiennoprzecinkowej
  -----------------------------------------------------------------------------}
  SCALE_META_COLUMN = 'DATA_SCALE';

  {*----------------------------------------------------------------------------
  Nazwa kolumny z nazw� pola liczby zmiennoprzecinkowej
  -----------------------------------------------------------------------------}
  FIELD_NAME_META_COLUMN = 'COLUMN_NAME';

  {*----------------------------------------------------------------------------
  Szalon nazwy pliku do pomocy
  -----------------------------------------------------------------------------}
  sAppHelpKeyword = '%s.html';

  {*----------------------------------------------------------------------------
  Nazwa pliku z podstawowymi ustawieniami aplikacji
  -----------------------------------------------------------------------------}
  sIniFilename = 'Settings.ini';

  {*----------------------------------------------------------------------------
  Nazwa sekcji z parametrami po��czenia do bazy danych
  -----------------------------------------------------------------------------}
  sIniDBSection = 'Database';

  siniImportDBFSection = 'ImportDBF';

  sIniInitialDir = 'DefaultDir';
  {*----------------------------------------------------------------------------
  Parametr zawieraj�cy nazw� serwera bazy danych
  -----------------------------------------------------------------------------}
  sIniDBServerName = 'ServerName';

  {*----------------------------------------------------------------------------
  Parametr zawieraj�cy nazw� bazy danych
  -----------------------------------------------------------------------------}
  sIniDBName = 'Database';

  {*----------------------------------------------------------------------------
  Nazwa sekcji z parametrami po��czenia do bazy danych
  -----------------------------------------------------------------------------}
  sIniRemoteDBSection  = 'RemoteDatabase';

  {*----------------------------------------------------------------------------
  Parametr zawieraj�cy nazw� u�ytkownika bazodanowego dla aplikacji
  -----------------------------------------------------------------------------}
  sIniDBUser = 'User';

  {*----------------------------------------------------------------------------
  Parametr zawieraj�cy has�o u�ytkownika bazodanowego dla aplikacji
  -----------------------------------------------------------------------------}
  sIniDBPasswd = 'Passwd';

  {*----------------------------------------------------------------------------
  Nazwa sekcji z parametrami dla aplikacji wieloj�zycznych
  -----------------------------------------------------------------------------}
  sIniLangSection = 'Languages';

  {*----------------------------------------------------------------------------
  Parametr zawieraj�cy list� dost�pnych j�zyk�w dla aplikacji
  -----------------------------------------------------------------------------}
  sLangNames = 'Names';

  {*----------------------------------------------------------------------------
  Parametr zawieraj�cy list� identyfikator�w dla poszczeg�lnych j�zyk�w aplikacji
  -----------------------------------------------------------------------------}
  sLangIDs = 'IDs';

  {*----------------------------------------------------------------------------
  Parametr zawieraj�cy list� kod�w dla poszczeg�lnych j�zyk�w aplikacji
  -----------------------------------------------------------------------------}
  sLangCodes = 'Codes';

  {*----------------------------------------------------------------------------
  Parametr zawieraj�cy list� identyfikator�w ikon dla poszczeg�lnych j�zyk�w aplikacji
  -----------------------------------------------------------------------------}
  sLangImages = 'Images';

  {*----------------------------------------------------------------------------
  Nazwa sekcji z parametrami logowania do aplikacji
  -----------------------------------------------------------------------------}
  sIniLoginSection = 'Login';

  {*----------------------------------------------------------------------------
  Parametr zawieraj�cy nazw� u�ytkownika domy�lnie logowanego do aplikacji
  -----------------------------------------------------------------------------}
  sIniLoginName = 'Login';

  {*----------------------------------------------------------------------------
  Parametr zawieraj�cy has�o u�ytkownika domy�lnie logowanego do aplikacji
  -----------------------------------------------------------------------------}
  sIniLoginPasswodr = 'PassCoded';

  {*----------------------------------------------------------------------------
  Parametr okre�laj�cy mo�liwo�� logowania na u�ytkownika domy�lnego
  -----------------------------------------------------------------------------}
  sIniLoginAuto = 'AutoLogin';

  siniCurrentAlarmFrameSection = 'CurrentAlarmFrame';
  sIniCAFVisible = 'Visible';

  {*----------------------------------------------------------------------------
  Opis przy logowaniu na domy�lny jezyk u�ytkownika
  -----------------------------------------------------------------------------}
  sLangName = '-domy�lny-';

  {*----------------------------------------------------------------------------
  Identyfikator j�zyka przekazywany przy logowaniu na domy�lny j�zyk u�ytkownika
  -----------------------------------------------------------------------------}
  sLangID = '-1';

  {*----------------------------------------------------------------------------
  Identyfikator ikony przekazywany przy logowaniu na domy�lny j�zyk u�ytkownika
  -----------------------------------------------------------------------------}
  sLangImage = '-1';


resourcestring
  //podstawowe komunikaty wyj�tk�w
  {*----------------------------------------------------------------------------
  Podstawowa nazwa komunikatu o b��dzie
  -----------------------------------------------------------------------------}
  sError = 'B��d';

  {*----------------------------------------------------------------------------
  Szablon komunikatu o numerze b��du
  -----------------------------------------------------------------------------}
  sErrorNo = 'B��d %d';

  {*----------------------------------------------------------------------------
  Szablon komunikatu o klasie b��du
  -----------------------------------------------------------------------------}
  sErrorClass = 'B��d %s';

  {*----------------------------------------------------------------------------
  Podstawowy szablon informacji o wyj�tku
  -----------------------------------------------------------------------------}
  sException = 'Wyj�tek:' + #13#10 +'%s';

  {*----------------------------------------------------------------------------
  Podstawowa nazwa komunikatu z ostrze�eniem
  -----------------------------------------------------------------------------}
  sWarning = 'Ostrze�enie';

  
  {*----------------------------------------------------------------------------
  Szablon komunikatu o przekroczonym zakresie dopuszczalnych warto�ci pola
  -----------------------------------------------------------------------------}
  sFieldSize = 'Przekroczono maksymaln� d�ugo�� danych w polu "%s"!';



  {*----------------------------------------------------------------------------
  Nazwa przycisku akceptuj�cego
  -----------------------------------------------------------------------------}
  sOK = 'OK';

  {*----------------------------------------------------------------------------
  Nazwa przycisku akceptuj�cego
  -----------------------------------------------------------------------------}
  sYes = 'Tak';

  {*----------------------------------------------------------------------------
  Nazwa przycisku anuluj�cego
  -----------------------------------------------------------------------------}
  sNo = 'Nie';

  {*----------------------------------------------------------------------------
  Nazwa przycisku anuluj�cego
  -----------------------------------------------------------------------------}
  sCancel = 'Anuluj';


var
  {*----------------------------------------------------------------------------
  �cie�ka do katalogu z danymi aplikacji
  -----------------------------------------------------------------------------}
  sDataPath: string;

  {*----------------------------------------------------------------------------
  �cie�ka do katalogu z plikiem konfiguracyjnym aplikacji
  -----------------------------------------------------------------------------}
  sConfPath: string;

implementation

uses
  SysUtils;


initialization
  sDataPath := ExtractFilePath(ParamStr(0)) + 'Data\';
  sConfPath := ExtractFilePath(ParamStr(0)) + 'Config\';


  try
    CreateDir(sDataPath);
  except
  end;

finalization


end.
