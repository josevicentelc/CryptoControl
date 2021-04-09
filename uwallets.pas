unit uwallets;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, udatabaseconector, sqldb, utils, ufifowallet;

type

  TWallet = class(TObject)
  private
         pk : string;
         user: integer;
         wname: String;
         crypto: integer;
         _computedBalance: double;
         _computedValue : double;
         _hasBalanceBeenComputed : boolean;
         _hasValueBeenComputed : boolean;
  public
    constructor create();
    procedure setPk(_pk : string);
    procedure setName(_name : string);
    procedure setUser(_user : integer);
    procedure setCrypto(_crypto : integer);
    procedure clear();
    procedure save();

    function getPk(): string;
    function getUser(): integer;
    function getCrypto(): integer;
    function getName(): String;
    function getBalance(): double;

    procedure addFifoBalance(_balance: double; _value: double);
    function reduceFifoBalance(_balance: double): double;
    function getFifoValue(): double;

    procedure export(F : TStringList);
    procedure import(line: String);

  end;


TWalletArray = Array of TWallet;


TWalletList = class(TObject)
private
 list : TWalletArray;
 _count : integer;
public
  constructor create();
  destructor Destroy; override;
  function count(): integer;
  procedure push(item: TWallet);
  procedure clear();
  function get(i : integer): TWallet;
end;

TWalletController = class(TObject)
private
 db: TDatabaseConnector;
public
  constructor create(_db: TDatabaseConnector);
  procedure save(Wallet: TWallet);
  procedure remove(wallet: string);
  function getWallets(): TWalletList;
  function getWallet(pk: String): TWallet;
  procedure clearAll();
end;

var
  walletController : TwalletController;
  procedure initwalletController(db: TDatabaseConnector);

implementation

constructor TWallet.create();
begin
     _hasBalanceBeenComputed:=false;
     _hasValueBeenComputed:=false;
end;

function TWallet.getBalance(): double;
var
  i : Integer;
  list : TFifoList;
begin
     if _hasBalanceBeenComputed then result := _computedBalance
     else
       begin
         list := fifoController.getFifoList(pk);
         _hasBalanceBeenComputed:=true;
         Result:=0;
         for I := 0 to list.count() -1 do
          begin
            result := result + list.get(I).amount;
          end;
         _computedBalance:=result;
       end;
end;

procedure TWallet.setPk(_pk : string);             begin     pk := _pk;         end;
procedure TWallet.setName(_name : string);         begin     wname := _name;    end;
procedure TWallet.setUser(_user : integer);        begin     user := _user;     end;
procedure TWallet.setCrypto(_crypto : integer);    begin     crypto := _crypto; end;
function TWallet.getPk(): string;                  begin     result := pk;      end;
function TWallet.getName(): string;                begin     result := wname;   end;
function TWallet.getUser(): integer;               begin     result := user;    end;
function TWallet.getCrypto(): integer;             begin     result := crypto;  end;

procedure TWallet.save();
begin
     walletController.save(self);
end;
procedure TWallet.clear();
begin
     fifoController.remove(pk);
end;

function TWallet.reduceFifoBalance(_balance: double) : double;
var
  fifolist : TFifoList;
  toreduce : double;
  I : Integer;
  fifo : TFifo;
begin
  result := 0;
  if _balance > 0 then
  begin
    toreduce:=_balance;
    fifolist := fifoController.getFifoList(pk);
    for I := 0 to fifolist.count() -1 do
     begin
       if toreduce > 0 then
       begin
         fifo := fifolist.get(I);
         if fifo.amount > toreduce then
         begin
           result := result + fifo.value * (toreduce / fifo.amount);
           fifo.value := fifo.value - fifo.value * (toreduce / fifo.amount);
           fifo.amount := fifo.amount - toreduce;
           toreduce:=0;
         end
         else
         if fifo.amount > 0 then
         begin
           toreduce:=toreduce - fifo.amount;
           result := result + fifo.value;
           fifo.amount:=0;
           fifo.value:=0;
         end;
       end;
     end;
    fifoController.save(fifolist);
  end;
  _computedBalance := _computedBalance - _balance;
  _computedValue := _computedValue - Result;
end;

procedure TWallet.addFifoBalance(_balance: double; _value: double);
var
  fifolist : TFifoList;
  fifo : TFifo;
begin
  if _balance > 0 then
       begin
          fifolist := fifoController.getFifoList(pk);
          fifo := TFifo.create;
          fifo.wallet:=pk;
          fifo.amount:=_balance;
          fifo.value:=_value;
          fifolist.push(fifo);
          fifoController.save(fifolist);
          fifolist.free;
          _computedValue:=_computedValue + _value;
          _computedBalance:=_computedBalance + _balance;
       end;
end;

function TWallet.getFifoValue(): double;
var
    fifolist : TFifoList;
    I : Integer;
begin
  if _hasValueBeenComputed then result := _computedValue
  else
    begin
      result := 0;
      fifolist := fifoController.getFifoList(pk);
      for I := 0 to fifolist.count() -1 do
       begin
         result := result + fifolist.get(I).value;
       end;
      _computedValue:=result;
      _hasValueBeenComputed:=true;
      fifolist.Free;
    end;
end;


procedure TWallet.export(F : TStringList);
var
  str : String;
begin
     str := pk + '^';
     str := str + wname + '^';
     str := str + inttostr(user) + '^';
     str := str + inttostr(crypto);
     F.add(str);
end;

procedure TWallet.import(line: String);
var
  str : TStringArray;
begin
     str := line.split('^');
     if length(str) = 4 then
     begin
       pk := str[0];
       wname := str[1];
       user := strtoint(str[2]);
       crypto := strtoint(str[3]);
     end;
end;

// *****************************************************************************

constructor TWalletList.create();
begin
     _count := 0;
     SetLength(list, 0);
end;

function TWalletList.count(): integer;         begin           result := _count;        end;

procedure TWalletList.push(item: TWallet);
begin
     if item <> nil then
     begin
       _count := _count +1;
       SetLength(list, _count);
       list[count -1] := item;
     end;
end;

function TWalletList.get(i : integer): TWallet;
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

procedure TWalletList.clear();
var
    I : Integer;
begin
     for I := 0 to length(list) -1 do
         list[I].free;
     setLength(list, 0);
     _count := 0;
end;

destructor TWalletList.Destroy;
begin
     clear();
     inherited;
end;


// *****************************************************************************
// *****************************************************************************
// *****************************************************************************

procedure initWalletController(db: TDatabaseConnector);
begin
     WalletController := TWalletController.create(db);
end;

constructor TWalletController.create(_db: TDatabaseConnector);
begin
     db := _db;
end;

procedure TWalletController.clearAll();
var
    sql : String;
begin
     sql := 'delete from "Wallets"';
     db.launchSql(sql)
end;

procedure TWalletController.save(Wallet: TWallet);
var
   sql : String;
   Q : TSQLQuery;
   exists : Boolean;
begin
     if (Wallet <> nil) and (wallet.getPk() <> '') and (Wallet.getCrypto() > 0) then
     begin
        Q := db.getSqlQuery('select * from "wallets" where wallet_pk = "'+Wallet.getPk()+'"');
        exists := not Q.Eof;
        Q.close;
        Q.free;
        if (exists) then
        begin
          sql := 'update "wallets" set ';
          sql := sql + 'wallet_crypto = ' + inttostr(Wallet.getCrypto()) + ', ';
          sql := sql + 'wallet_name = "' + Wallet.getName() +'",';
          sql := sql + 'wallet_user = ' + inttostr(Wallet.getUser()) + ' ';
          sql := sql + ' where wallet_pk = "' + Wallet.getPk() + '"';
        end
        else
        begin
            sql := 'insert into "wallets" (Wallet_pk, Wallet_name, wallet_crypto, Wallet_user) values(';
            sql := sql + '"' + Wallet.getPk() + '", ';
            sql := sql + '"' + Wallet.getName() + '", ';
            sql := sql + inttostr(Wallet.getCrypto()) + ', ';
            sql := sql + inttostr(Wallet.getUser()) + ')';
        end;
        db.launchSql(sql);
     end;
end;

procedure TWalletController.remove(Wallet: string);
var
   sql : string;
begin
   if Wallet <> '' then
   begin
      sql := 'delete from "Wallets" where Wallet_pk = "' + Wallet +'"';
      db.launchSql(sql);
   end;
end;

function TWalletController.getWallet(pk: String): TWallet;
var
   Q : TSQLQuery;
begin
     // refresh and returns Wallet list
     result := TWallet.create;
     Q := db.getSqlQuery('select * from "Wallets" where Wallet_pk = "'+pk+'"');
     while not Q.Eof do
     begin
         result.setpk(Q.FieldByName('Wallet_pk').AsString);
         result.setName(Q.FieldByName('Wallet_name').AsString);
         result.setCrypto(Q.FieldByName('Wallet_crypto').Asinteger);
         result.setUser(Q.FieldByName('Wallet_user').Asinteger);
         Q.Next;
     end;
     Q.Close;
     Q.Free;
end;


function TWalletController.getWallets(): TWalletList;
var
   Q : TSQLQuery;
   Wallet : TWallet;
begin
     // refresh and returns Wallet list
     result := TWalletList.create;
     Q := db.getSqlQuery('select * from "Wallets" order by Wallet_pk');
     while not Q.Eof do
     begin
         Wallet := TWallet.create;
         Wallet.setpk(Q.FieldByName('Wallet_pk').AsString);
         Wallet.setName(Q.FieldByName('Wallet_name').AsString);
         Wallet.setCrypto(Q.FieldByName('Wallet_crypto').Asinteger);
         Wallet.setUser(Q.FieldByName('Wallet_user').Asinteger);
         result.push(Wallet);
         Q.Next;
     end;
     Q.Close;
     Q.Free;
end;

end.


