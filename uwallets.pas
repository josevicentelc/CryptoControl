unit uwallets;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, udatabaseconector, sqldb, utils;

type

  TWallet = class(TObject)
  private
         pk : string;
         user: integer;
         wname: String;
         crypto: integer;
         balance: double;
         contable_value : double;
  public
    constructor create();
    procedure setPk(_pk : string);
    procedure setName(_name : string);
    procedure setUser(_user : integer);
    procedure setCrypto(_crypto : integer);
    procedure setBalance(_balance : double);
    procedure setContableValue(_value : double);

    function getPk(): string;
    function getUser(): integer;
    function getCrypto(): integer;
    function getName(): String;
    function getBalance(): double;
    function getContableValue(): double;

    procedure addBalance(_balance: double; _value: double);

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
  procedure remove(Wallet: TWallet);
  function getWallets(): TWalletList;
  function getWallet(pk: String): TWallet;
end;

var
  walletController : TwalletController;
  procedure initwalletController(db: TDatabaseConnector);

implementation

constructor TWallet.create();
begin
end;

procedure TWallet.setPk(_pk : string);             begin     pk := _pk;         end;
procedure TWallet.setName(_name : string);         begin     wname := _name;    end;
procedure TWallet.setUser(_user : integer);        begin     user := _user;     end;
procedure TWallet.setCrypto(_crypto : integer);    begin     crypto := _crypto; end;
function TWallet.getPk(): string;                  begin     result := pk;      end;
function TWallet.getName(): string;                begin     result := wname;   end;
function TWallet.getUser(): integer;               begin     result := user;    end;
function TWallet.getCrypto(): integer;             begin     result := crypto;  end;
procedure TWallet.setBalance(_balance : double);   begin     balance := _balance;end;
procedure TWallet.setContableValue(_value : double);begin    contable_value:=_value;end;
function TWallet.getBalance(): double;             begin     result := balance; end;
function TWallet.getContableValue(): double;       begin     result := contable_value;end;

procedure TWallet.addBalance(_balance: double; _value: double);
var
  f : double;
  newBalance : double;
  newValue : double;
begin
     newBalance := _balance + balance;
     f := _balance / newBalance;
     newValue:=_value*f + contable_value*(1-f);
     setBalance(newValue);
     setContableValue(newValue);
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

     inherited;
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
          sql := sql + 'wallet_user = ' + inttostr(Wallet.getUser());
          sql := sql + 'wallet_balance = '+ floatToSql(wallet.getBalance()) +',';
          sql := sql + 'wallet_contable_value = '+ floatToSql(wallet.getContableValue()) +',';
          sql := sql + ' where wallet_pk = "' + Wallet.getPk() + '"';
        end
        else
        begin
            sql := 'insert into "wallets" (Wallet_pk, Wallet_name, wallet_crypto, wallet_balance , wallet_contable_value, Wallet_user) values(';
            sql := sql + '"' + Wallet.getPk() + '", ';
            sql := sql + '"' + Wallet.getName() + '", ';
            sql := sql + inttostr(Wallet.getCrypto()) + ', ';
            sql := sql + floatToSql(wallet.getBalance()) +',';
            sql := sql + floatToSql(wallet.getContableValue()) +',';
            sql := sql + inttostr(Wallet.getUser()) + ')';
        end;
        db.launchSql(sql);
     end;
end;

procedure TWalletController.remove(Wallet: TWallet);
var
   sql : string;
begin
     if Wallet <> nil then
     begin
          if Wallet.getPk() <> '' then
          begin
            sql := 'delete from "Wallets" where Wallet_pk = "' + Wallet.getPk() +'"';
            db.launchSql(sql);
          end;
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
         result.setContableValue(Q.FieldByName('wallet_contable_value').AsFloat);
         result.setBalance(Q.FieldByName('wallet_balance').AsFloat);
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
         Wallet.setContableValue(Q.FieldByName('wallet_contable_value').AsFloat);
         Wallet.setBalance(Q.FieldByName('wallet_balance').AsFloat);
         result.push(Wallet);
         Q.Next;
     end;
     Q.Close;
     Q.Free;
end;

end.


