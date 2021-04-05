unit ucryptos;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, udatabaseconector, SQLDB, ucomunicacion, uconfig, utils;

type
  TCrypto = class(TObject)
  private
     _id : integer;
     _name : String;
     _shortName : String;
     _MarketPriceEuro : double;
     _MarketPriceDolar : double;
     _updateDate : double;


  public
    constructor create();
    procedure setId(__id : Integer);
    procedure setName(__name : String);
    procedure setShorName(__short : String);

    procedure setMarketPriceEuro(v : double);
    procedure setMarketPriceDolar(v : double);
    procedure setUpdateDate(v: double);

    function getId() : integer;
    function getName() : String;
    function getShorName() : String;
    function getMarketPrice(): double;

    function getMarketPriceEuro(): double;
    function getMarketPriceDolar(): double;
    function getUpdateDate(): double;

    procedure export(F : TStringList);
    procedure import(line: String);

    procedure refreshMarketValue();
    procedure save();

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
    function getById(_id: integer): TCrypto;
    procedure clearAll();


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
function TCrypto.getUpdateDate() : double;      begin           result := _updateDate;   end;

function TCrypto.getMarketPrice(): double;
var
   d : double;
begin

     if getConfig().useMarketSync then
     begin
        d := now() - _updateDate;
        if d > 0.000001 then
        begin
           refreshMarketValue();
        end;
     end;
     if getConfig().useCurrencyEuro then   result := _MarketPriceEuro
     else result := _MarketPriceDolar;
end;
function TCrypto.getMarketPriceEuro(): double;  begin          result := _MarketPriceEuro;    end;
function TCrypto.getMarketPriceDolar(): double;  begin          result := _MarketPriceDolar;    end;
procedure TCrypto.setMarketPriceEuro(v: double);begin         _MarketPriceEuro:=v;   end;
procedure TCrypto.setMarketPriceDolar(v: double);begin         _MarketPriceDolar:=v;   end;
procedure TCrypto.setUpdateDate(v: double);      begin         _updateDate:=v;         end;





procedure TCrypto.save();
begin
     cryptoController.save(self);
end;

procedure TCrypto.export(F : TStringList);
var str : String;
begin
     str := inttostr(_id) + '^';
     str := str +  _name + '^';
     str := str +  _shortName;
     F.Add(str);
end;

procedure TCrypto.import(line: String);
var
  str : TStringArray;
begin
     str := line.Split('^');
     if length(str) = 3 then
     begin
       _id := strtoint(str[0]);
       _name := str[1];
       _shortName := str[2];
     end;
end;


procedure TCrypto.refreshMarketValue();
begin
   _MarketPriceEuro := getMarketValue(LowerCase(_shortName)+'eur');
   _MarketPriceDolar := getMarketValue(LowerCase(_shortName)+'usd');
   _updateDate:=now();
   save();
end;

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

procedure TCryptoController.clearAll();
var
    sql : String;
begin
 sql := 'delete from "cryptocurrency"';
 db.launchSql(sql);
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
   Q : TSQLQuery;
   exists : Boolean;
begin
     if crypto <> nil then
     begin
          Q := db.getSqlQuery('select * from "cryptocurrency" where crypto_id = "'+inttostr(crypto.getId())+'"');
          exists := not Q.Eof;
          Q.free;
          if (crypto.getId() <= 0) or (not exists) then
          begin
            if (crypto.getId() <= 0) then crypto.setId(getNextId());
            sql := 'insert into "cryptocurrency" (crypto_id, crypto_marketvalueeuro, crypto_marketvaluedolar, crypto_updatedate, crypto_name, crypto_short) values(';
            sql := sql + inttostr(crypto.getId()) + ', ';
            sql := sql + floatToSql(crypto.getMarketPriceEuro()) + ', ';
            sql := sql + floatToSql(crypto.getMarketPriceDolar()) + ', ';
            sql := sql + dateToSql(crypto.getUpdateDate()) + ', ';
            sql := sql + '"' + crypto.getName() + '", ';
            sql := sql + '"' + crypto.getShorName() + '")';
            db.launchSql(sql);
          end
          else
          begin
               sql := 'update "cryptocurrency" set ';
               sql := sql + 'crypto_name = "' + crypto.getName() + '", ';
               sql := sql + 'crypto_short = "' + crypto.getShorName() + '", ';
               sql := sql + 'crypto_marketvalueeuro = ' + floatToSql(crypto.getMarketPriceEuro()) + ', ';
               sql := sql + 'crypto_marketvaluedolar = ' + floatToSql(crypto.getMarketPriceDolar()) + ', ';
               sql := sql + 'crypto_updatedate = ' + dateToSql(crypto.getUpdateDate()) ;
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

function TCryptoController.getById(_id: integer): TCrypto;
var
   Q : TSQLQuery;
begin
   result := TCrypto.create();
   Q := db.getSqlQuery('select * from "cryptocurrency" where crypto_id = ' + inttostr(_id));
   while not Q.Eof do
   begin
       result.setId(Q.FieldByName('crypto_id').AsInteger);
       result.setName(Q.FieldByName('crypto_name').AsString);
       result.setShorName(Q.FieldByName('crypto_short').AsString);
       result.setMarketPriceEuro(Q.FieldByName('crypto_marketvalueeuro').AsFloat);
       result.setMarketPriceDolar(Q.FieldByName('crypto_marketvaluedolar').AsFloat);
       result.setUpdateDate(Q.FieldByName('crypto_updatedate').AsFloat);
       Q.Next;
   end;
   Q.Close;
   Q.Free;
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
         crypto.setMarketPriceEuro(Q.FieldByName('crypto_marketvalueeuro').AsFloat);
         crypto.setMarketPriceDolar(Q.FieldByName('crypto_marketvaluedolar').AsFloat);
         crypto.setUpdateDate(Q.FieldByName('ccrypto_updatedate').AsFloat);
         result.push(crypto);
         Q.Next;
     end;
     Q.Close;
     Q.Free;
end;

end.

