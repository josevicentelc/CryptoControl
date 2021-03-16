unit uwallets;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, udatabaseconector, sqldb;

type

  TWallet = class(TObject)
  private
         pk : string;
         user: integer;
         crypto: integer;
  public
    constructor create();
    procedure setPk(_pk : string);
    procedure setUser(_user : integer);
    procedure setCrypto(_crypto : integer);
    function getPk(): string;
    function getUser(): integer;
    function getCrypto(): integer;
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
end;

var
  walletController : TwalletController;
  procedure initwalletController(db: TDatabaseConnector);

implementation

constructor TWallet.create();
begin
end;

procedure TWallet.setPk(_pk : string);
begin
     pk := _pk;
end;

procedure TWallet.setUser(_user : integer);
begin
     user := _user;
end;

procedure TWallet.setCrypto(_crypto : integer);
begin
     crypto := _crypto;
end;

function TWallet.getPk(): string;
begin
     result := pk;
end;

function TWallet.getUser(): integer;
begin
     result := user;
end;

function TWallet.getCrypto(): integer;
begin
     result := crypto;;
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
          sql := sql + 'wallet_user = ' + inttostr(Wallet.getUser());
          sql := sql + ' where wallet_pk = "' + Wallet.getPk() + '"';
        end
        else
        begin
            sql := 'insert into "wallets" (Wallet_pk, wallet_crypto, Wallet_user) values(';
            sql := sql + '"' + Wallet.getPk() + '", ';
            sql := sql + inttostr(Wallet.getCrypto()) + ', ';
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

function TWalletController.getWallets(): TWalletList;
var
   Q : TSQLQuery;
   Wallet : TWallet;
begin
     // refresh and returns Wallet list
     result := TWalletList.create;
     Q := db.getSqlQuery('select * from Walletcurrency order by Wallet_name');
     while not Q.Eof do
     begin
         Wallet := TWallet.create;
         Wallet.setpk(Q.FieldByName('Wallet_pk').AsString);
         Wallet.setCrypto(Q.FieldByName('Wallet_crypto').Asinteger);
         Wallet.setUser(Q.FieldByName('Wallet_user').Asinteger);
         result.push(Wallet);
         Q.Next;
     end;
     Q.Close;
     Q.Free;
end;

end.


