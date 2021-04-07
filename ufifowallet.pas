unit ufifowallet;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, udatabaseconector, utils, sqldb;

type

  TFifo = class(TObject)
  private
  public
    wallet : String;
    id : integer;
    amount : double;
    value : double;
  end;

  TFifoArray = Array of TFifo;

  TFifoList = class(TObject)
  private
   list : TFifoArray;
   _count : integer;
  public
    constructor create();
    destructor Destroy; override;
    function count(): integer;
    procedure push(item: TFifo);
    procedure clear();
    function get(i : integer): TFifo;
  end;


TFifoController = class(TObject)
private
 db: TDatabaseConnector;
public
  constructor create(_db: TDatabaseConnector);
  procedure save(fifolist: TFifoList);
  procedure remove(Wallet: String);
  function getFifoList(wallet: string): TFifoList;
  procedure clearAll();
end;

var
   fifoController : TFifoController;
   procedure initFifoController(db: TDatabaseConnector);

implementation

procedure initFifoController(db: TDatabaseConnector);
begin
   fifoController := TFifoController.create(db);
end;

// *****************************************************************************

constructor TFifoList.create();
begin
     _count := 0;
     SetLength(list, 0);
end;

function TFifoList.count(): integer;         begin           result := _count;        end;

procedure TFifoList.push(item: TFifo);
begin
     if item <> nil then
     begin
       _count := _count +1;
       SetLength(list, _count);
       list[count -1] := item;
     end;
end;

function TFifoList.get(i : integer): TFifo;
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

procedure TFifoList.clear();
var
    I : Integer;
begin
     for I := 0 to length(list) -1 do
         list[I].free;
     setLength(list, 0);
     _count := 0;
end;

destructor TFifoList.Destroy;
begin
     clear();
     inherited;
end;

// *****************************************************************************

constructor TFifoController.create(_db: TDatabaseConnector);
begin
     db := _db;
end;

procedure TFifoController.save(fifolist: TFifoList);
var
   I : integer;
   id : integer;
   sql : string;
   wallet : String;
begin
     id := 0;
     if fifolist.count() > 0 then
     begin
       wallet:=fifolist.get(0).wallet;
       remove(wallet);
       for I := 0 to fifolist.count() -1 do
           begin
                if fifolist.get(i).amount <> 0 then
                begin
                  id := id + 1;
                  sql := 'insert into "fifowallet" (fifo_pk, fifo_id, fifo_amount, fifo_value) values(';
                  sql := sql + '"' + wallet + '", ';
                  sql := sql + inttostr(id) + ', ';
                  sql := sql + floatToSql(fifolist.get(i).amount) + ', ';
                  sql := sql + floatToSql(fifolist.get(i).value) + '); ';
                  db.launchSql(sql);
                end;
           end;
     end;
end;

procedure TFifoController.remove(Wallet: String);
begin
   db.launchSql('delete from "fifowallet" where fifo_pk = "' + wallet +'"');
end;

function TFifoController.getFifoList(wallet: string): TFifoList;
var
   Q : TSqlQuery;
   fifo : TFifo;
begin
   result := TFifoList.create();

   Q := db.getSqlQuery('select * from "fifowallet" where fifo_pk = "' + wallet +'" order by fifo_id');
   while not Q.Eof do
   begin
       fifo := TFifo.create;
       fifo.wallet    :=   Q.FieldByName('fifo_pk').AsString;
       fifo.id        :=   Q.FieldByName('fifo_id').AsInteger;
       fifo.amount    :=   Q.FieldByName('fifo_amount').AsFloat;
       fifo.value     :=   Q.FieldByName('fifo_value').AsFloat;
       result.push(fifo);
       Q.Next;
   end;
   Q.Close;
   Q.Free;
end;

procedure TFifoController.clearAll();
begin
   db.launchSql('delete from "fifowallet"');
end;


end.

