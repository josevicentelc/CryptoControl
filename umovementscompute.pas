unit umovementscompute;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, umovements, ucryptos, uwallets;



  procedure computeWalletBalances();
  //cryptoController : TCryptoController;
  //procedure initCryptoController(db: TDatabaseConnector);


implementation

procedure computeWalletBalances();
var
 wallets : TWalletList;
 wallet : TWallet;
 mov : TMovement;
 movements : TMovementList;
 I : Integer;
 movType : TMovementType;
 totalvalue : double;
 inputvalue : double;
 outputvalue : double;
 totalcryptos: double;
 f : double;

 outputcryptos: double;
begin

  wallets := walletController.getWallets();
  for I := 0 to wallets.count() -1 do
  begin
    wallets.get(I).clear();
    wallets.get(I).save();
  end;

  movements := movementsController.getAll();
  for I := 0 to movements.count() -1 do
  begin
       mov := movements.get(I);
       movType := mov.getType();
       case movType of
            MV_BUY:
                begin
                     wallet := walletController.getWallet(mov.getWalletInput());
                     wallet.addBalance(mov.getInputCryptos(), mov.getCotnableValueInput());
                     wallet.save();
                end;
            MV_TRANSFER:
                begin
                     inputvalue:=0; outputvalue:=0; totalcryptos:=0;outputcryptos:=0;
                     //origin
                     wallet := walletController.getWallet(mov.getWalletOutput());
                     if wallet <> nil then
                          begin
                                totalcryptos:=wallet.getBalance();
                                outputcryptos:=mov.getOutputCryptos() + mov.getOutputFee();
                                totalvalue:=wallet.getContableValue();
                                if totalcryptos > 0 then
                                begin
                                    outputvalue :=  totalvalue* (outputcryptos / totalcryptos);
                                    inputvalue:=  totalvalue * (mov.getOutputCryptos() / totalcryptos);
                                end;

                                wallet.setBalance(wallet.getBalance() - outputcryptos);
                                wallet.setContableValue(wallet.getContableValue() - outputvalue);
                                wallet.save();
                                wallet.Free;
                          end;
                     //destiny
                     wallet := walletController.getWallet(mov.getWalletInput());
                     if wallet <> nil then
                          begin
                                wallet.addBalance(mov.getInputCryptos(), inputvalue);
                                wallet.save();
                          end;
                end;
       end;
  end;

end;

end.

