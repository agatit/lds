{*------------------------------------------------------------------------------
Sta³e aplikacji
@author   Adam Pietrzko
@version  2007/11
@comment  AGAT IT S.A. 2010 (c) Wszystkie prawa zastrze¿one
-------------------------------------------------------------------------------}

unit BaseConsts;

interface

uses
  Classes, DB, Graphics;
 const
  {*----------------------------------------------------------------------------
  Nazwa kolumny z precyzj¹ liczby zmiennoprzecinkowej
  -----------------------------------------------------------------------------}
  PRECISION_META_COLUMN = 'DATA_PRECISION';

  {*----------------------------------------------------------------------------
  Nazwa kolumny ze skal¹ liczby zmiennoprzecinkowej
  -----------------------------------------------------------------------------}
  SCALE_META_COLUMN = 'DATA_SCALE';

  {*----------------------------------------------------------------------------
  Nazwa kolumny z nazw¹ pola liczby zmiennoprzecinkowej
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
  Nazwa sekcji z parametrami po³¹czenia do bazy danych
  -----------------------------------------------------------------------------}
  sIniDBSection = 'Database';

  siniImportDBFSection = 'ImportDBF';

  sIniInitialDir = 'DefaultDir';
  {*----------------------------------------------------------------------------
  Parametr zawieraj¹cy nazwê serwera bazy danych
  -----------------------------------------------------------------------------}
  sIniDBServerName = 'ServerName';

  {*----------------------------------------------------------------------------
  Parametr zawieraj¹cy nazwê bazy danych
  -----------------------------------------------------------------------------}
  sIniDBName = 'Database';

  {*----------------------------------------------------------------------------
  Nazwa sekcji z parametrami po³¹czenia do bazy danych
  -----------------------------------------------------------------------------}
  sIniRemoteDBSection  = 'RemoteDatabase';

  {*----------------------------------------------------------------------------
  Parametr zawieraj¹cy nazwê u¿ytkownika bazodanowego dla aplikacji
  -----------------------------------------------------------------------------}
  sIniDBUser = 'User';

  {*----------------------------------------------------------------------------
  Parametr zawieraj¹cy has³o u¿ytkownika bazodanowego dla aplikacji
  -----------------------------------------------------------------------------}
  sIniDBPasswd = 'Passwd';

  {*----------------------------------------------------------------------------
  Nazwa sekcji z parametrami dla aplikacji wielojêzycznych
  -----------------------------------------------------------------------------}
  sIniLangSection = 'Languages';

  {*----------------------------------------------------------------------------
  Parametr zawieraj¹cy listê dostêpnych jêzyków dla aplikacji
  -----------------------------------------------------------------------------}
  sLangNames = 'Names';

  {*----------------------------------------------------------------------------
  Parametr zawieraj¹cy listê identyfikatorów dla poszczególnych jêzyków aplikacji
  -----------------------------------------------------------------------------}
  sLangIDs = 'IDs';

  {*----------------------------------------------------------------------------
  Parametr zawieraj¹cy listê kodów dla poszczególnych jêzyków aplikacji
  -----------------------------------------------------------------------------}
  sLangCodes = 'Codes';

  {*----------------------------------------------------------------------------
  Parametr zawieraj¹cy listê identyfikatorów ikon dla poszczególnych jêzyków aplikacji
  -----------------------------------------------------------------------------}
  sLangImages = 'Images';

  {*----------------------------------------------------------------------------
  Nazwa sekcji z parametrami logowania do aplikacji
  -----------------------------------------------------------------------------}
  sIniLoginSection = 'Login';

  {*----------------------------------------------------------------------------
  Parametr zawieraj¹cy nazwê u¿ytkownika domyœlnie logowanego do aplikacji
  -----------------------------------------------------------------------------}
  sIniLoginName = 'Login';

  {*----------------------------------------------------------------------------
  Parametr zawieraj¹cy has³o u¿ytkownika domyœlnie logowanego do aplikacji
  -----------------------------------------------------------------------------}
  sIniLoginPasswodr = 'PassCoded';

  {*----------------------------------------------------------------------------
  Parametr okreœlaj¹cy mo¿liwoœæ logowania na u¿ytkownika domyœlnego
  -----------------------------------------------------------------------------}
  sIniLoginAuto = 'AutoLogin';

  siniCurrentAlarmFrameSection = 'CurrentAlarmFrame';
  sIniCAFVisible = 'Visible';

  {*----------------------------------------------------------------------------
  Opis przy logowaniu na domyœlny jezyk u¿ytkownika
  -----------------------------------------------------------------------------}
  sLangName = '-domyœlny-';

  {*----------------------------------------------------------------------------
  Identyfikator jêzyka przekazywany przy logowaniu na domyœlny jêzyk u¿ytkownika
  -----------------------------------------------------------------------------}
  sLangID = '-1';

  {*----------------------------------------------------------------------------
  Identyfikator ikony przekazywany przy logowaniu na domyœlny jêzyk u¿ytkownika
  -----------------------------------------------------------------------------}
  sLangImage = '-1';


resourcestring
  //podstawowe komunikaty wyj¹tków
  {*----------------------------------------------------------------------------
  Podstawowa nazwa komunikatu o b³êdzie
  -----------------------------------------------------------------------------}
  sError = 'B³¹d';

  {*----------------------------------------------------------------------------
  Szablon komunikatu o numerze b³êdu
  -----------------------------------------------------------------------------}
  sErrorNo = 'B³¹d %d';

  {*----------------------------------------------------------------------------
  Szablon komunikatu o klasie b³êdu
  -----------------------------------------------------------------------------}
  sErrorClass = 'B³¹d %s';

  {*----------------------------------------------------------------------------
  Podstawowy szablon informacji o wyj¹tku
  -----------------------------------------------------------------------------}
  sException = 'Wyj¹tek:' + #13#10 +'%s';

  {*----------------------------------------------------------------------------
  Podstawowa nazwa komunikatu z ostrze¿eniem
  -----------------------------------------------------------------------------}
  sWarning = 'Ostrze¿enie';

  
  {*----------------------------------------------------------------------------
  Szablon komunikatu o przekroczonym zakresie dopuszczalnych wartoœci pola
  -----------------------------------------------------------------------------}
  sFieldSize = 'Przekroczono maksymaln¹ d³ugoœæ danych w polu "%s"!';



  {*----------------------------------------------------------------------------
  Nazwa przycisku akceptuj¹cego
  -----------------------------------------------------------------------------}
  sOK = 'OK';

  {*----------------------------------------------------------------------------
  Nazwa przycisku akceptuj¹cego
  -----------------------------------------------------------------------------}
  sYes = 'Tak';

  {*----------------------------------------------------------------------------
  Nazwa przycisku anuluj¹cego
  -----------------------------------------------------------------------------}
  sNo = 'Nie';

  {*----------------------------------------------------------------------------
  Nazwa przycisku anuluj¹cego
  -----------------------------------------------------------------------------}
  sCancel = 'Anuluj';


var
  {*----------------------------------------------------------------------------
  Œcie¿ka do katalogu z danymi aplikacji
  -----------------------------------------------------------------------------}
  sDataPath: string;

  {*----------------------------------------------------------------------------
  Œcie¿ka do katalogu z plikiem konfiguracyjnym aplikacji
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
