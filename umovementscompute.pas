unit umovementscompute;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, umovements, ucryptos, uwallets, uwallethistory, utils;



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
 feeValue: double;
 outputvalue : double;
 totalcryptos: double;
 f : double;

 outputcryptos: double;
 histLine : THistoryLine;
begin

  wallets := walletController.getWallets();
  for I := 0 to wallets.count() -1 do
  begin
    wallets.get(I).clear();
    historyController.clear(wallets.get(i).getPk());
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

                     histLine := THistoryLine.create();
                     histLine.setWallet(wallet.getPk());
                     histLine.setDateTime(FormatDateTime('dd/mm/yyyy hh:nn:ss', mov.getDateTime()));
                     histLine.setDescription('Buy ' + floatToSql(mov.getInputCryptos())+ ' coins');
                     histLine.setConcept(mov.getConcept());
                     histLine.setImport(mov.getInputCryptos());
                     histLine.setbalance(wallet.getBalance());
                     histLine.setvalue(wallet.getContableValue());
                     histLine.save();

                     wallet.Free;
                     histLine.Free;
                end;
            MV_TRANSFER:
                begin
                     inputvalue:=0; outputvalue:=0; totalcryptos:=0;outputcryptos:=0; feeValue:=0;
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
                                  feeValue := totalvalue * (mov.getOutputFee() / totalcryptos);
                                  inputvalue:=  totalvalue * (mov.getOutputCryptos() / totalcryptos);
                                end;

                                // Pay fee
                                histLine := THistoryLine.create();
                                histLine.setWallet(wallet.getPk());
                                histLine.setDateTime(FormatDateTime('dd/mm/yyyy hh:nn:ss', mov.getDateTime()));
                                histLine.setDescription('Pay Fee' + floatToSql(mov.getOutputFee()));
                                histLine.setConcept(mov.getConcept());
                                histLine.setImport(mov.getOutputFee() * -1);
                                histLine.setbalance(totalcryptos - mov.getOutputFee());
                                histLine.setvalue(totalvalue - feeValue);
                                histLine.save();
                                histLine.Free;

                                // Transfer cryptos
                                histLine := THistoryLine.create();
                                histLine.setWallet(wallet.getPk());
                                histLine.setDateTime(FormatDateTime('dd/mm/yyyy hh:nn:ss', mov.getDateTime()));
                                histLine.setDescription('Send ' + floatToSql(mov.getOutputCryptos()) + ' to ' + mov.getWalletInput());
                                histLine.setConcept(mov.getConcept());
                                histLine.setImport(mov.getOutputCryptos() * -1);
                                histLine.setbalance(wallet.getBalance() - outputcryptos);
                                histLine.setvalue(wallet.getContableValue() - outputvalue);
                                histLine.save();
                                histLine.Free;


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

                           // input Transfer cryptos
                           histLine := THistoryLine.create();
                           histLine.setWallet(wallet.getPk());
                           histLine.setDateTime(FormatDateTime('dd/mm/yyyy hh:nn:ss', mov.getDateTime()));
                           histLine.setDescription('Input ' + floatToSql(mov.getInputCryptos()) + ' from ' + mov.getWalletOutput());
                           histLine.setConcept(mov.getConcept());
                           histLine.setImport(mov.getInputCryptos());
                           histLine.setbalance(wallet.getBalance());
                           histLine.setvalue(wallet.getContableValue());
                           histLine.save();
                           histLine.Free;
                     end;
                end;
       end;
  end;

end;

end.

