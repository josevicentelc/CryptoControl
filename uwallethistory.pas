unit uwallethistory;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, udatabaseconector, utils;

type
  THistoryLine = class(TObject)
  private
    _wallet: String;
    _id: integer;
    _datetime: double;
    _description: String;
    _concept: String;

    _import: double;
    _importValue: double;
    _importBuyFee: double;
    _importShellFee: double;
    _shellPrice: double;

    _balance: double;
    _value: double;
    _moveid: integer;
    _profit: double;
  public
    constructor create;
    procedure save();

    procedure setWallet(v: string);
    procedure setDateTime(v: double);
    procedure setDescription(v: string);
    procedure setConcept(v: string);
    procedure setId(v: integer);
    procedure setImport(v: double);
    procedure setImportValue(v: double);
    procedure setImportBuyFee(v: double);
    procedure setImportShellFee(v: double);
    procedure setShellPrice(v: double);
    procedure setbalance(v: double);
    procedure setProfit(v: double);
    procedure setvalue(v: double);
    procedure setMoveId(v: integer);

    function getWallet():string;
    function getDateTime(): double;
    function getDescription():string;
    function getConcept(): string;
    function getId(): integer;
    function getImport(): double;
    function getImportValue(): double;
    function getImportBuyFee(): double;
    function getImportShellFee(): double;
    function getShellPrice(): double;
    function getbalance(): double;
    function getProfit(): double;
    function getvalue(): double;
    function getMoveId(): integer;
    function getDateTimeToStr(): String;

  end;

  THistoryArray = Array of THistoryLine;

  THistoryList = class(TObject)
  private
    list : THistoryArray;
   _count : integer;
  public
    constructor create();
    destructor Destroy; override;
    function count(): integer;
    procedure push(item: THistoryLine);
    procedure clear();
    function get(i : integer): THistoryLine;
  end;

  THistoryController = class(TObject)
  private
   db: TDatabaseConnector;
  public
    constructor create(_db: TDatabaseConnector);
    procedure save(v: THistoryLine);
    procedure clear(w: String);
    procedure remove(v: THistoryLine);
    function getNextId(w: String): integer;
    function getFromWallet(w: String): THistoryList;
    function getById(id: integer): THistoryLine;
  end;

  var
    historyController : THistoryController;
    procedure initHistoryController(db: TDatabaseConnector);


// *****************************************************************************
// *****************************************************************************
// *****************************************************************************

implementation

procedure initHistoryController(db: TDatabaseConnector);
begin
     if historyController <> nil then historyController.Free;
     historyController := THistoryController.create(db);
end;

constructor THistoryLine.create;
begin
     // todo
end;

procedure THistoryLine.save();
begin
     historyController.save(self);
end;

procedure THistoryLine.setWallet(v: string);    begin           _wallet := v;           end;
procedure THistoryLine.setDateTime(v: double);  begin           _datetime:=v;           end;
procedure THistoryLine.setDescription(v: string);begin          _description:=v;        end;
procedure THistoryLine.setConcept(v: string);    begin          _concept:=v;            end;
procedure THistoryLine.setId(v: integer);        begin          _id:=v;                 end;
procedure THistoryLine.setImport(v: double);     begin          _import:=v;             end;
procedure THistoryLine.setImportValue(v: double);begin          _importValue:=v;        end;
procedure THistoryLine.setImportBuyFee(v: double);begin         _importBuyFee:=v;        end;
procedure THistoryLine.setImportShellFee(v: double);begin       _importShellFee:=v;        end;
procedure THistoryLine.setbalance(v: double);    begin          _balance:=v;            end;
procedure THistoryLine.setShellPrice(v: double); begin          _shellPrice:=v;            end;
procedure THistoryLine.setvalue(v: double);      begin          _value:=v;              end;
procedure THistoryLine.setMoveId(v: integer);    begin          _moveid:=v;              end;
procedure THistoryLine.setProfit(v: double);     begin          _profit:=v;             end;
function THistoryLine.getDateTimeToStr(): String; begin result := FormatDateTime('dd/mm/yyyy hh:nn:ss', _datetime); end;

function THistoryLine.getWallet():string;        begin          result:=_wallet;        end;
function THistoryLine.getDateTime(): double;     begin          result:=_datetime;      end;
function THistoryLine.getDescription():string;   begin          result:=_description;   end;
function THistoryLine.getConcept(): string;      begin          result:=_concept;       end;
function THistoryLine.getId(): integer;          begin          result:=_id;            end;
function THistoryLine.getImport(): double;       begin          result:=_import;        end;
function THistoryLine.getImportValue(): double;  begin          result:=_importValue;   end;
function THistoryLine.getImportBuyFee(): double; begin          result:=_importBuyFee;   end;
function THistoryLine.getImportShellFee(): double; begin        result:=_importShellFee; end;
function THistoryLine.getbalance(): double;      begin          result:=_balance;       end;
function THistoryLine.getShellPrice(): double;   begin          result:=_shellPrice;       end;
function THistoryLine.getvalue(): double;        begin          result:=_value;         end;
function THistoryLine.getMoveId(): integer;      begin          result:=_moveid;         end;
function THistoryLine.getProfit(): double;       begin          result:=_profit;       end;


// *****************************************************************************

constructor THistoryList.create();
begin
     _count := 0;
     SetLength(list, 0);
end;

function THistoryList.count(): integer;         begin           result := _count;        end;

procedure THistoryList.push(item: THistoryLine);
begin
     if item <> nil then
     begin
       _count := _count +1;
       SetLength(list, _count);
       list[count -1] := item;
     end;
end;

function THistoryList.get(i : integer): THistoryLine;
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

procedure THistoryList.clear();
var
    I : Integer;
begin
     for I := 0 to length(list) -1 do
         list[I].free;
     setLength(list, 0);
     _count := 0;
end;

destructor THistoryList.Destroy;
begin
     clear();
     inherited;
end;

// *****************************************************************************
// *****************************************************************************
// *****************************************************************************

constructor THistoryController.create(_db: TDatabaseConnector);
begin
     db := _db;
end;

procedure THistoryController.save(v: THistoryLine);
var
    Q : TSQLQuery;
    Exists : boolean;
    sql : String;
begin
     if (v <> nil) and (v.getWallet() <> '') then
     begin
        Q := db.getSqlQuery('select * from "walletshistory" where hist_pk = "'+v.getWallet()+'" and hist_id = ' + inttostr(v.getId()));
        exists := not Q.Eof;
        Q.close;
        Q.free;
        if Exists then
        begin
           sql := 'update "walletshistory" set';
           sql := sql + 'hist_datetime = ' + dateToSql(v.getDateTime()) + ', ';
           sql := sql + 'hist_description = "' + v.getDescription() + '", ';
           sql := sql + 'hist_concept = "' + v.getConcept() + '", ';
           sql := sql + 'hist_import = '+floatToSql(v.getImport()) + ', ';
           sql := sql + 'hist_importvalue = '+floatToSql(v.getImportValue()) + ', ';
           sql := sql + 'hist_importbuyfee = '+floatToSql(v.getImportBuyFee()) + ', ';
           sql := sql + 'hist_importshellfee = '+floatToSql(v.getImportShellFee()) + ', ';
           sql := sql + 'hist_shellprice = '+floatToSql(v.getShellPrice()) + ', ';
           sql := sql + 'hist_balance = '+ floatToSql(v.getbalance()) + ', ';
           sql := sql + 'hist_value = ' + floatToSql(v.getvalue()) + ', ' ;
           sql := sql + 'hist_moveid = ' + inttostr(v.getMoveId()) + ', ' ;
           sql := sql + 'hist_profit = ' + floatToSql(v.getProfit());

           sql := sql + ' where hist_pk = "' + v.getWallet() + '" and hist_id = ' + inttostr(v.getId());
             // update
        end
        else
        begin
             v.setId(getNextId(v.getWallet()));
             sql := 'insert into "walletshistory" (hist_pk, hist_id, hist_datetime, hist_description, hist_concept, hist_shellprice, hist_import, hist_importvalue, hist_importbuyfee, hist_importshellfee, hist_balance, hist_value,hist_profit, hist_moveid) values ( ';
             sql := sql + '"' + v.getWallet() + '", ';
             sql := sql + inttostr(v.getId()) + ', ';
             sql := sql + dateToSql( v.getDateTime()) + ', ';
             sql := sql + '"' + v.getDescription() + '", ';
             sql := sql + '"' + v.getConcept() + '", ';
             sql := sql + floatToSql(v.getShellPrice()) + ', ';
             sql := sql + floatToSql(v.getImport()) + ', ';
             sql := sql + floatToSql(v.getImportValue()) + ', ';
             sql := sql + floatToSql(v.getImportBuyFee()) + ', ';
             sql := sql + floatToSql(v.getImportShellFee()) + ', ';
             sql := sql + floatToSql(v.getbalance()) + ', ';
             sql := sql + floatToSql(v.getvalue()) + ',';
             sql := sql + floatToSql(v.getProfit()) + ',';
             sql := sql + inttostr(v.getMoveId()) + ')';
             // insert
        end;
        db.launchSql(sql);
     end;
end;

procedure THistoryController.remove(v: THistoryLine);
begin
     db.launchSql('delete from "walletshistory" where hist_pk = "'+v.getWallet()+'" and hist_id = '+inttostr(v.getId()));
end;

procedure THistoryController.clear(w: String);
begin
     db.launchSql('delete from "walletshistory" where hist_pk = "'+w+'"');
end;

function THistoryController.getFromWallet(w: String): THistoryList;
var
    line : THistoryLine;
    Q : TSQLQuery;
begin
     result := THistoryList.create;
     Q := db.getSqlQuery('select * from "walletshistory" where hist_pk = "'+w+'" order by hist_id');
     while not Q.Eof do
     begin
         line := THistoryLine.create;
         line.setWallet(Q.FieldByName('hist_pk').AsString);
         line.setId(Q.FieldByName('hist_id').AsInteger);
         line.setDateTime(Q.FieldByName('hist_datetime').AsFloat);
         line.setDescription(Q.FieldByName('hist_description').AsString);
         line.setConcept(Q.FieldByName('hist_concept').AsString);
         line.setImport(Q.FieldByName('hist_import').AsFloat);
         line.setShellPrice(Q.FieldByName('hist_shellprice').AsFloat);
         line.setImportValue(Q.FieldByName('hist_importvalue').AsFloat);
         line.setImportBuyFee(Q.FieldByName('hist_importbuyfee').AsFloat);
         line.setImportShellFee(Q.FieldByName('hist_importshellfee').AsFloat);
         line.setbalance(Q.FieldByName('hist_balance').AsFloat);
         line.setvalue(Q.FieldByName('hist_value').AsFloat);
         line.setProfit(Q.FieldByName('hist_profit').AsFloat);
         line.setMoveId(Q.FieldByName('hist_moveid').AsInteger);
         result.push(line);
         Q.Next;
     end;
     Q.Close;
     Q.Free;
end;


function THistoryController.getById(id: integer): THistoryLine;
var
    Q : TSQLQuery;
begin
     result := THistoryLine.create;
     Q := db.getSqlQuery('select * from "walletshistory" where hist_id = '+inttostr(id)+' order by hist_id');
     while not Q.Eof do
     begin
         result.setWallet(Q.FieldByName('hist_pk').AsString);
         result.setId(Q.FieldByName('hist_id').AsInteger);
         result.setDateTime(Q.FieldByName('hist_datetime').AsFloat);
         result.setDescription(Q.FieldByName('hist_description').AsString);
         result.setConcept(Q.FieldByName('hist_concept').AsString);
         result.setImport(Q.FieldByName('hist_import').AsFloat);
         result.setShellPrice(Q.FieldByName('hist_shellprice').AsFloat);
         result.setImportValue(Q.FieldByName('hist_importvalue').AsFloat);
         result.setImportBuyFee(Q.FieldByName('hist_importbuyfee').AsFloat);
         result.setImportshellFee(Q.FieldByName('hist_importshellfee').AsFloat);
         result.setbalance(Q.FieldByName('hist_balance').AsFloat);
         result.setvalue(Q.FieldByName('hist_value').AsFloat);
         result.setProfit(Q.FieldByName('hist_profit').AsFloat);
         result.setMoveId(Q.FieldByName('hist_moveid').AsInteger);
         Q.Next;
     end;
     Q.Close;
     Q.Free;
end;


function THistoryController.getNextId(w: String): integer;
var
   Q : TSqlQuery;
begin
     Q := db.getSqlQuery('select max(hist_id) from "walletsHistory" where hist_pk = "'+w+'"');
     while not Q.Eof do
     begin
          if Q.Fields[0].AsString = '' then result := 1
          else result := Q.Fields[0].AsInteger +1;
          Q.Next;
     end;
     Q.Close;
     Q.Free;
end;

end.

