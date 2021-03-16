unit ucryptos;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, udatabaseconector, SQLDB;

type
  TCrypto = class(TObject)
  private
     _id : integer;
     _name : String;
     _shortName : String;
  public
    constructor create();
    procedure setId(__id : Integer);
    procedure setName(__name : String);
    procedure setShorName(__short : String);
    function getId() : integer;
    function getName() : String;
    function getShorName() : String;
  end;

  TCryptoArray = Array of TCrypto;


  TCryptoList = class(TObject)
  private
   list : TCryptoArray;
   _count : integer;
  public
    constructor create();
    destructor Destroy; override;
    function count(): integer;
    procedure push(item: TCrypto);
    procedure clear();
    function get(i : integer): TCrypto;
  end;

  TCryptoController = class(TObject)
  private
   db: TDatabaseConnector;
  public
    constructor create(_db: TDatabaseConnector);
    function getNextId(): integer;
    procedure save(crypto: TCrypto);
    procedure remove(crypto: TCrypto);
    function getCryptos(): TCryptoList;
  end;


var
  cryptoController : TCryptoController;
  procedure initCryptoController(db: TDatabaseConnector);


implementation

// *****************************************************************************
// *****************************************************************************
// *****************************************************************************


constructor TCrypto.create();
begin
     _id := -1;
     _name := '';
     _shortName := '';
end;

procedure TCrypto.setId(__id : Integer);        begin           _id := __id;            end;
procedure TCrypto.setName(__name : String);     begin           _name := __name;        end;
procedure TCrypto.setShorName(__short : String);begin           _shortName := __short;  end;
function TCrypto.getId() : integer;             begin           result := _id;          end;
function TCrypto.getName() : String;            begin           result := _name;        end;
function TCrypto.getShorName() : String;        begin           result := _shortName;   end;

// *****************************************************************************
// *****************************************************************************
// *****************************************************************************

constructor TCryptoList.create();
begin
     _count := 0;
     SetLength(list, 0);
end;

function TCryptoList.count(): integer;         begin           result := _count;        end;

procedure TCryptoList.push(item: TCrypto);
begin
     if item <> nil then
     begin
       _count := _count +1;
       SetLength(list, _count);
       list[count -1] := item;
     end;
end;

function TCryptoList.get(i : integer): TCrypto;
begin
     if (i < 0) or (i >= _count) then
     begin
       result := nil;
     end
     else
     begin
          result := list[i];
     end;
end;

procedure TCryptoList.clear();
var
    I : Integer;
begin
     for I := 0 to length(list) -1 do
         list[I].free;

     inherited;
end;

destructor TCryptoList.Destroy;
begin
     clear();
     inherited;
end;


// *****************************************************************************
// *****************************************************************************
// *****************************************************************************

procedure initCryptoController(db: TDatabaseConnector);
begin
     cryptoController := TCryptoController.create(db);

end;

constructor TCryptoController.create(_db: TDatabaseConnector);
begin
     db := _db;
end;

function TCryptoController.getNextId(): Integer;
var
   Q : TSqlQuery;
begin
     Q := db.getSqlQuery('select max(crypto_id) from "cryptocurrency"');
     while not Q.Eof do
     begin
          if Q.Fields[0].AsString = '' then result := 1
          else result := Q.Fields[0].AsInteger +1;
          Q.Next;
     end;
     Q.Close;
     Q.Free;
end;

procedure TCryptoController.save(crypto: TCrypto);
var
   sql : String;
begin
     if crypto <> nil then
     begin
          if crypto.getId() <= 0 then
          begin
            crypto.setId(getNextId());
            sql := 'insert into "cryptocurrency" (crypto_id, crypto_name, crypto_short) values(';
            sql := sql + inttostr(crypto.getId()) + ', ';
            sql := sql + '"' + crypto.getName() + '", ';
            sql := sql + '"' + crypto.getShorName() + '")';
            db.launchSql(sql);
          end
          else
          begin
               sql := 'update "cryptocurrency" set ';
               sql := sql + 'crypto_name = "' + crypto.getName() + '", ';
               sql := sql + 'crypto_short = "' + crypto.getShorName() + '" ';
               sql := sql + ' where crypto_id =' + inttostr(crypto.getId());
               db.launchSql(sql);
          end;
     end;
end;

procedure TCryptoController.remove(crypto: TCrypto);
var
   sql : string;
begin
     if crypto <> nil then
     begin
          if crypto.getId() <= 0 then
          begin
            sql := 'delete from "cryptocurrency" where crypto_id = ' + inttostr(crypto.getId());
            db.launchSql(sql);
          end;
     end;
end;

function TCryptoController.getCryptos(): TCryptoList;
var
   Q : TSQLQuery;
   crypto : TCrypto;
begin
     // refresh and returns crypto list
     result := TCryptoList.create;
     Q := db.getSqlQuery('select * from "cryptocurrency" order by crypto_name');
     while not Q.Eof do
     begin
         crypto := TCrypto.create;
         crypto.setId(Q.FieldByName('crypto_id').AsInteger);
         crypto.setName(Q.FieldByName('crypto_name').AsString);
         crypto.setShorName(Q.FieldByName('crypto_short').AsString);
         result.push(crypto);
         Q.Next;
     end;
     Q.Close;
     Q.Free;
end;

end.

