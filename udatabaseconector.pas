unit udatabaseconector;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqlite3conn, sqldb, dialogs, FileUtil, Graphics,ExtCtrls, db;

type
  TDatabaseConnector = class(TObject)
  private
    fileName : STring;
    database : TSQLite3Connection;
    transaction : TSQLTransaction;

  public
    constructor create(_fileName: String);
    function build(): boolean;
    procedure update();
    function buildIfNoExists(): boolean;
    function connected(): boolean;
    function connect(): Boolean;
    procedure launchSql(_sql : String);
    function getSqlQuery(_sql : string) : TSQLQuery;
    procedure saveImage(picture: TPicture; tableName: String; fieldName : String; where: String);
    function getImage(tableName: String; fieldName : String; where: String): TPicture;
    procedure doBackup(askForpath : boolean);
    procedure recoverBackup();

  end;


implementation

constructor TDatabaseConnector.create(_fileName : String);
begin
  if _fileName = '' then fileName := 'localdata.data'
  else fileName := _fileName;
  transaction := TSQLTransaction.create(nil);
  database := TSQLite3Connection.create(nil);
  database.Transaction := transaction;
  database.DatabaseName:=fileName;
  buildIfNoExists();
  connect();
end;

function TDatabaseConnector.connected(): boolean;
begin
     result :=  (database <> nil) and (database.Connected);
end;

function TDatabaseConnector.build(): boolean;
begin
  result := true;
  if database = nil then
  begin
     result := false;
  end
  else
  begin
    try
      database.Open;
      transaction.Active := true;

      // Userlist
      database.ExecuteDirect('CREATE TABLE "users"('+
                 ' "user_id" integer not null PRIMARY KEY,'+                   // Unique user id
                 ' "user_name" char(100) NOT NULL,'+                            // Real user name
                 ' "user_surname" char(10),'+                                   // Real user surname
                 ' "user_password" char(10),'+                                  // SHA256(user_id + password)
                 ' "user_identity_number" char(100)); ');                       // National identity card, used to fill documents
     database.ExecuteDirect('CREATE UNIQUE INDEX "users_idx" ON "users"( "user_id" );');

     // Crypto list
      database.ExecuteDirect('CREATE TABLE "cryptocurrency"('+
                  ' "crypto_id" integer not null PRIMARY KEY,'+                     // Internal identifier for the crypto
                  ' "crypto_name" char(100) NOT NULL,'+                             // Crpyto name
                  ' "crypto_short" char(10) NOT NULL,'+                                      // Crypto short name e.j BTC
                  ' "crypto_marketvalueeuro" numeric(16, 2) not null default 0,'+   // Market Value in ???
                  ' "crypto_marketvaluedolar" numeric(16, 2) not null default 0,'+  // Market Value in $
                  ' "crypto_updatedate" numeric(18,6) not null default 0,'+         // Last update date
                  ' "crypto_usesync" integer not null default 0,'+                  // sync market value
                  ' "crypto_logo" blob); ');                                        // Crpyot image logo
      database.ExecuteDirect('CREATE UNIQUE INDEX "cryptocurrency_idx" ON "cryptocurrency"( "crypto_id" );');

      // Wallet list
      database.ExecuteDirect('CREATE TABLE "wallets"('+
                  ' "wallet_pk" char(100) not null PRIMARY KEY,'+
                  ' "wallet_name" char(100),'+
                  ' "wallet_user" integer NOT NULL,'+
                  ' "wallet_crypto" integer not null,'+
                  ' FOREIGN KEY (wallet_crypto) REFERENCES cryptocurrency (crypto_id),'+
                  ' FOREIGN KEY (wallet_user) REFERENCES users (user_id));');
      database.ExecuteDirect('CREATE UNIQUE INDEX "wallets_pkx" ON "wallets"( "wallet_pk" );');


      // FIFO values
      database.ExecuteDirect('CREATE TABLE "fifowallet"('+
                  ' "fifo_pk" char(100) not null,'+
                  ' "fifo_id" integer not null,'+
                  ' "fifo_amount" numeric(9, 16) not null default 0,'+
                  ' "fifo_value" numeric(16, 2) not null default 0,'+
                  ' "fifo_buyfee" numeric(16, 2) not null default 0,'+
                  ' PRIMARY KEY("fifo_pk", "fifo_id"));');

      // Wallet history
      database.ExecuteDirect('CREATE TABLE "walletshistory"('+
                  ' "hist_pk" char(100) not null,'+
                  ' "hist_id" integer not null,'+
                  ' "hist_datetime" numeric(18,6) not null default 0,'+
                  ' "hist_description" char(100),'+
                  ' "hist_concept" char(100),'+
                  ' "hist_import" numeric(9, 16) NOT NULL default 0,'+
                  ' "hist_importvalue" numeric(16, 2) NOT NULL default 0,'+
                  ' "hist_importbuyfee" numeric(16, 2) NOT NULL default 0,'+
                  ' "hist_importshellfee" numeric(16, 2) NOT NULL default 0,'+
                  ' "hist_shellprice" numeric(16, 2) NOT NULL default 0,'+

                  ' "hist_balance" numeric(9, 16) NOT NULL default 0,'+
                  ' "hist_value" numeric(16, 2) NOT NULL default 0,'+
                  ' "hist_moveid" integer NOT NULL default 0,'+
                  ' "hist_profit" numeric(16, 2) NOT NULL default 0,'+
                  ' PRIMARY KEY("hist_pk", "hist_id"));');
      database.ExecuteDirect('CREATE UNIQUE INDEX "wallets_history_pkx" ON "walletshistory"( "hist_pk", "hist_id" );');


      // Crypto movements
      database.ExecuteDirect('CREATE TABLE "moves"('+
                  ' "move_id" integer not null PRIMARY KEY,'+
                  ' "move_type" integer not null,'+
                  ' "move_datetime" numeric(18,6) not null default 0,'+
                  ' "move_concept" char(100),'+

                  ' "move_wallet_output" char(100),'+
                  ' "move_wallet_input" char(100),'+

                  ' "move_cefi_input" numeric(10, 2) NOT NULL default 0,'+
                  ' "move_cefi_output" numeric(10, 2) NOT NULL default 0,'+

                  ' "move_contable_value_input" numeric(10, 2) NOT NULL default 0,'+
                  ' "move_contable_value_output" numeric(10, 2) NOT NULL default 0,'+

                  ' "move_comision_buy" numeric(10, 2) NOT NULL default 0,'+
                  ' "move_comision_shell" numeric(10, 2) NOT NULL default 0,'+

                  ' "move_input_fee" numeric(9, 16) NOT NULL default 0,'+
                  ' "move_output_fee" numeric(9, 16) NOT NULL default 0,'+

                  ' "move_input_cryptos" numeric(9, 16) NOT NULL default 0,'+
                  ' "move_output_cryptos" numeric(9, 16) NOT NULL default 0);');

      database.ExecuteDirect('CREATE UNIQUE INDEX "moves_idx" ON "moves"( "move_id" );');






      // Default crypto list
      database.ExecuteDirect('insert into cryptocurrency (crypto_id, crypto_name, crypto_short) values (1, "Bitcoin", "BTC")');
      database.ExecuteDirect('insert into cryptocurrency (crypto_id, crypto_name, crypto_short) values (2, "Bitcoin Cash", "BCH")');
      database.ExecuteDirect('insert into cryptocurrency (crypto_id, crypto_name, crypto_short) values (3, "Ethereum", "ETH")');
      database.ExecuteDirect('insert into cryptocurrency (crypto_id, crypto_name, crypto_short) values (4, "Uniswap", "UNI")');
      database.ExecuteDirect('insert into cryptocurrency (crypto_id, crypto_name, crypto_short) values (5, "Litecoin", "LTC")');
      database.ExecuteDirect('insert into cryptocurrency (crypto_id, crypto_name, crypto_short) values (6, "Chainlink", "LINK")');
      database.ExecuteDirect('insert into cryptocurrency (crypto_id, crypto_name, crypto_short) values (7, "USD Coin", "USDC")');
      database.ExecuteDirect('insert into cryptocurrency (crypto_id, crypto_name, crypto_short) values (8, "Stellar Lumens", "XLM")');
      database.ExecuteDirect('insert into cryptocurrency (crypto_id, crypto_name, crypto_short) values (9, "Wrapped Bitcoin", "WBTC")');
      database.ExecuteDirect('insert into cryptocurrency (crypto_id, crypto_name, crypto_short) values (10, "Aave", "AAVE")');
      database.ExecuteDirect('insert into cryptocurrency (crypto_id, crypto_name, crypto_short) values (11, "Cosmos", "ATOM")');
      database.ExecuteDirect('insert into cryptocurrency (crypto_id, crypto_name, crypto_short) values (12, "Tron", "TRX")');
      database.ExecuteDirect('insert into cryptocurrency (crypto_id, crypto_name, crypto_short) values (13, "Cardano", "ADA")');
      database.ExecuteDirect('insert into cryptocurrency (crypto_id, crypto_name, crypto_short) values (14, "Filecoin", "FIL")');
      database.ExecuteDirect('insert into cryptocurrency (crypto_id, crypto_name, crypto_short) values (15, "EOS", "EOS")');
      database.ExecuteDirect('insert into cryptocurrency (crypto_id, crypto_name, crypto_short) values (16, "Tezos", "XTZ")');
      database.ExecuteDirect('insert into cryptocurrency (crypto_id, crypto_name, crypto_short) values (17, "Algorand", "ALGO")');
      database.ExecuteDirect('insert into cryptocurrency (crypto_id, crypto_name, crypto_short) values (18, "Dai", "DAI")');
      database.ExecuteDirect('insert into cryptocurrency (crypto_id, crypto_name, crypto_short) values (19, "Dash", "DASH")');
      database.ExecuteDirect('insert into cryptocurrency (crypto_id, crypto_name, crypto_short) values (20, "Maker", "MKR")');
      database.ExecuteDirect('insert into cryptocurrency (crypto_id, crypto_name, crypto_short) values (21, "ZCash", "ZEC")');
      database.ExecuteDirect('insert into cryptocurrency (crypto_id, crypto_name, crypto_short) values (22, "Compound", "COMP")');
      database.ExecuteDirect('insert into cryptocurrency (crypto_id, crypto_name, crypto_short) values (23, "Ethereum Classic", "ETC")');
      database.ExecuteDirect('insert into cryptocurrency (crypto_id, crypto_name, crypto_short) values (24, "The Graph", "GRT")');

      // Debug data
      //database.ExecuteDirect('insert into wallets (wallet_pk, wallet_name, wallet_user, wallet_crypto) values ("0xDdfGDSFfgSDgfgFd", "Bitcoin wallet", 0, 1)');
      //database.ExecuteDirect('insert into wallets (wallet_pk, wallet_name, wallet_user, wallet_crypto) values ("FF5wGgewgh6F", "Bitcoin Cash wallet", 0, 2)');
      //database.ExecuteDirect('insert into wallets (wallet_pk, wallet_name, wallet_user, wallet_crypto) values ("DFdfwq45wG54gvgx0x", "Ethereum wallet", 0, 3)');
      //database.ExecuteDirect('insert into wallets (wallet_pk, wallet_name, wallet_user, wallet_crypto) values ("0xDdfGDSdFGDFG", "Cold Bitcoin wallet", 0, 1)');

      transaction.Commit;

    except
      Result := false;;
    end;

  end;
end;

function TDatabaseConnector.buildIfNoExists(): boolean;
begin
  result := true;
  if not FileExists(fileName) then result := build;
end;

procedure TDatabaseConnector.update();
var
  version : integer;
  Q : TSQLQuery;
begin
     if connected() then
     begin
       database.ExecuteDirect('create table if not exists dbversion( '+
        'version integer not null, '+
        'primary key (version));');


       Q := TSQLQuery.Create(nil);
       Q.SQL.Text := 'select max(version) from dbversion ';
       Q.Database := database;
       Q.Open;
          if (Q.Fields[0].AsString = '') then version := 0
          else version:=Q.fields[0].AsInteger;
       Q.Close;

       if (version < 1) then
       begin
         //transaction.Active := true;
         //database.ExecuteDirect('alter table "walletshistory" add hist_shellprice numeric (16, 2) not null default 0');
         //transaction.Commit;
       end;

       Q.free;

     end;
end;

function TDatabaseConnector.connect():Boolean;
begin
  database.open;
  update;
  result := connected();
end;

procedure TDatabaseConnector.launchSql(_sql : String);
begin
  transaction.Active := true;
  database.ExecuteDirect(_sql);
  transaction.Commit;
end;

function TDatabaseConnector.getSqlQuery(_sql : string) : TSQLQuery;
var
  Q : TSQLQuery;
begin
  Q := TSQLQuery.Create(nil);
  Q.SQL.Text := _sql;
  Q.Database := database;
  if trim(_sql) <> '' then
  begin
    try
      Q.Open;
    except
      Q.Close;
    end;
  end;
  result := Q;
end;

procedure TDataBaseConnector.saveImage(picture: TPicture; tableName: String; fieldName : String; where: String);
var
  sql : String;
  Q : TSqlQuery;
  mem : TStream;
begin
  if picture <> nil then
  begin
    Q := getSqlQuery('');
    sql := 'update ' + tableName + ' set ' + fieldName + ' = :picture where ' + where;
    Q.sql.Text := sql;
    mem := TMemoryStream.create;
    picture.PNG.SaveToStream(mem);
    Q.ParamByName('picture').LoadFromStream(mem, ftBlob);
    mem.free;
    transaction.Active := true;
    Q.execSql;
    transaction.Commit;
    Q.free;
  end;
end;

function TDataBaseConnector.getImage(tableName: String; fieldName : String; where: String): TPicture;
var
  Q : TSqlQuery;
  mem : TStream;
begin
  result := TPicture.create;
  Q := getSqlQuery('select ' + fieldname + ' from ' + tableName + ' where ' + where);
  while not Q.Eof do
  begin
       mem := TMemoryStream.create;
       TBlobField(Q.FieldByName(fieldName)).SaveToStream(mem);
       mem.position := 0;
       if mem.Size > 0 then result.LoadFromStream(mem);
       Q.next;
  end;
  Q.free;

end;


procedure TDatabaseConnector.doBackup(askForpath : boolean);
var
  diag : TSaveDialog;
  bfilename : String;
  YY,MM,DD : Word;
  HH,SS,MS: Word;
begin
     if (askForpath) then
     begin
         diag := TSaveDialog.Create(nil);
         if diag.Execute then
         begin
            bfilename:=diag.FileName;
         end;
         diag.free;
     end
     else
     begin

          bfilename:=GetCurrentDir + '\backup';
          DecodeDate(Date,YY,MM,DD);
          bfilename:=bfilename+'-'+format('%d_%d_%d', [DD, MM, YY]);
          DecodeTime(Time,HH,MM,SS,MS);
          bfilename:=bfilename+'-'+format('%d_%d_%d', [HH,MM,SS]);
     end;

     if (bfilename <> '') then
     begin
       database.CloseDataSets;
       database.CloseTransactions;
       database.Close(true);
       CopyFile(database.DatabaseName, bfilename);
       database.open;
     end;
end;

procedure TDatabaseConnector.recoverBackup();
var
  diag : TOpenDialog;
begin
     diag := TOpenDialog.Create(nil);
     if diag.Execute then
     begin
       database.CloseDataSets;
       database.CloseTransactions;
       database.Close(true);
       DeleteFile(database.DatabaseName);
       CopyFile( diag.FileName, database.DatabaseName);
       connect();
     end;
end;

end.

