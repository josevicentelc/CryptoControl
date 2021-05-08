unit exportdata;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, utils, uwallets, umovements, ucryptos;

procedure exportAll(filename: String);
procedure importAll(filename: String);

procedure exportCoins(filename: String);
procedure exportWallets(filename: String);
procedure exportMoves(filename: String);

procedure clearCoins();
procedure clearWallets();
procedure clearMoves();

procedure importCoins(fileName: String);
procedure importWallets(fileName: String);
procedure importMoves(fileName: String);

implementation

procedure exportAll(filename: String);
begin
  exportCoins(fileName+'_cryp.exp');
  exportWallets(fileName+'_wall.exp');
  exportMoves(fileName+'_movs.exp');
end;

procedure importAll(filename: String);
begin
  clearMoves();
  clearWallets();
  clearCoins();
  importCoins(fileName+'_cryp.exp');
  importWallets(fileName+'_wall.exp');
  importMoves(fileName+'_movs.exp');
end;

// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------

procedure exportCoins(filename: String);
var
  F : TSTringList;
  cryptos : TCryptoList;
  I : Integer;
begin
  f := TStringList.Create;
  cryptos := cryptoController.getCryptos();

  for I := 0 to cryptos.count() -1 do
  begin
    cryptos.get(I).export(f);
  end;

  f.SaveToFile(filename);
  f.free;
end;

procedure exportWallets(filename: String);
var
  F : TSTringList;
  wallets : TWalletList;
  I : Integer;
begin
  f := TStringList.Create;
  wallets := walletController.getWallets();

  for I := 0 to wallets.count() -1 do
  begin
    wallets.get(I).export(f);
  end;

  f.SaveToFile(filename);
  f.free;
end;

procedure exportMoves(filename: String);
var
  F : TSTringList;
  moves : TMovementList;
  I : Integer;
begin
  f := TStringList.Create;
  moves := movementsController.getAll();

  for I := 0 to moves.count() -1 do
  begin
    moves.get(I).export(f);
  end;

  f.SaveToFile(filename);
  f.free;
end;

// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------

procedure clearCoins();
begin
     cryptoController.clearAll();
end;
procedure clearWallets();
begin
     walletController.clearAll();
end;
procedure clearMoves();
begin
     movementsController.clearAll();
end;

// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------

procedure importCoins(fileName: String);
var
  F : TSTringList;
  crypto : TCrypto;
  I : Integer;
begin
  f := TStringList.Create;
  f.LoadFromFile(filename);
  crypto := TCrypto.create;

  for I := 0 to f.Count -1 do
  begin
    crypto.import(f[I]);
    crypto.save();
  end;
  f.free;
  crypto.free;
end;

procedure importWallets(fileName: String);
var
  F : TSTringList;
  wallet : TWallet;
  I : Integer;
begin
  f := TStringList.Create;
  f.LoadFromFile(filename);
  wallet := TWallet.create;

  for I := 0 to f.Count -1 do
  begin
    wallet.import(f[I]);
    walletController.addWallet(wallet.save());

  end;
  f.free;
end;

procedure importMoves(fileName: String);
var
  F : TSTringList;
  move : TMovement;
  I : Integer;
begin
  f := TStringList.Create;
  f.LoadFromFile(filename);
  move := TMovement.create;

  for I := 0 to f.Count -1 do
  begin
    move.import(f[I]);
    move.save();
  end;
  f.free;
  move.free;
end;


end.

