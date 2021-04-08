unit umovementscompute;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, umovements, ucryptos, uwallets, uwallethistory, utils, uconfig, forms, ufifowallet;



procedure computeWalletBalances();
procedure processShellMove(mov: TMovement);
procedure processBuyMove(mov: TMovement);
procedure processTransferMove(mov: TMovement);


implementation

// *****************************************************************************
// *****************************************************************************

procedure processBuyMove(mov: TMovement);
var
 wallet : TWallet;
 histLine : THistoryLine;
 c : String;
begin
  c := getConfig().currency();
  wallet := walletController.getWallet(mov.getWalletInput());
  wallet.addFifoBalance(mov.getInputCryptos(), mov.getCefiOutput());

  histLine := THistoryLine.create();
  histLine.setWallet(wallet.getPk());
  histLine.setDateTime(mov.getDateTime());
  histLine.setDescription('Buy ' + floatToSql(mov.getInputCryptos())+ ' coins by '+floatToSql(mov.getCefiOutput()) + c);
  histLine.setConcept(mov.getConcept());
  histLine.setImport(mov.getInputCryptos());
  histLine.setbalance(wallet.getBalance());
  histLine.setvalue(wallet.getFifoValue());
  histLine.setMoveId(mov.getId());
  histLine.save();

  wallet.Free;
  histLine.Free;
end;

// *****************************************************************************
// *****************************************************************************

procedure processTransferMove(mov: TMovement);
var
 wallet : TWallet;
 transferValue : double;
 histLine : THistoryLine;
 oldBalance : double;
 newBalance : double;
 newValue : double;
 oldValue : double;

begin
  //origin
  wallet := walletController.getWallet(mov.getWalletOutput());
  if wallet <> nil then
       begin
             oldBalance:=wallet.getBalance();
             oldValue := wallet.getFifoValue();
             wallet.reduceFifoBalance(mov.getOutputFee());
             newBalance:=wallet.getBalance();
             newValue := wallet.getFifoValue();

             // Pay fee
             histLine := THistoryLine.create();
             histLine.setWallet(wallet.getPk());
             histLine.setDateTime(mov.getDateTime());
             histLine.setDescription('Pay Fee ' + floatToSql(mov.getOutputFee()));
             histLine.setConcept(mov.getConcept());
             histLine.setImport(mov.getOutputFee() * -1);
             histLine.setbalance(newBalance);
             histLine.setvalue(newValue);
             histLine.setMoveId(mov.getId());
             histLine.save();
             histLine.Free;

             oldBalance:=newBalance;
             oldValue := newValue;
             transferValue := wallet.reduceFifoBalance(mov.getOutputCryptos());
             newBalance:=wallet.getBalance();
             newValue := wallet.getFifoValue();

             // Transfer cryptos
             histLine := THistoryLine.create();
             histLine.setWallet(wallet.getPk());
             histLine.setDateTime(mov.getDateTime());
             histLine.setDescription('Send ' + floatToSql(mov.getOutputCryptos()) + ' to ' + mov.getWalletInput());
             histLine.setConcept(mov.getConcept());
             histLine.setImport(mov.getOutputCryptos() * -1);
             histLine.setbalance(newBalance);
             histLine.setvalue(newValue);
             histLine.setMoveId(mov.getId());
             histLine.save();
             histLine.Free;

             wallet.Free;
       end;
  //destiny
  wallet := walletController.getWallet(mov.getWalletInput());
  if wallet <> nil then
  begin
        wallet.addFifoBalance(mov.getInputCryptos(), transferValue);

        // input Transfer cryptos
        histLine := THistoryLine.create();
        histLine.setWallet(wallet.getPk());
        histLine.setDateTime(mov.getDateTime());
        histLine.setDescription('Input ' + floatToSql(mov.getInputCryptos()) + ' from ' + mov.getWalletOutput());
        histLine.setConcept(mov.getConcept());
        histLine.setImport(mov.getInputCryptos());
        histLine.setbalance(wallet.getBalance());
        histLine.setvalue(wallet.getFifoValue());
        histLine.setMoveId(mov.getId());
        histLine.save();
        histLine.Free;
  end;
end;

// *****************************************************************************
// *****************************************************************************

procedure processShellMove(mov: TMovement);
var
 wallet : TWallet;
 histLine : THistoryLine;
 shellValue: double;
 totalCefiGet : double;
 profit: double;
 c : String;
 fee : double;
begin
    c := getConfig().currency();
    totalCefiGet:= mov.getCefiInput();
    fee := mov.getComisionShell();
    wallet := walletController.getWallet(mov.getWalletOutput());
    shellValue := wallet.reduceFifoBalance(mov.getOutputCryptos());
    profit := totalCefiGet-shellValue;

    histLine := THistoryLine.create();
    histLine.setWallet(wallet.getPk());
    histLine.setDateTime( mov.getDateTime());
    histLine.setDescription('Shell ' + floatToSql(mov.getOutputCryptos())+ ' (value: '+floatToCurrency(shellValue)+ c +') for ' + floatToSql(totalCefiGet) + c+ ' (Profit: '+floatToCurrency(profit)+c+'), Fee: ' + floatToCurrency(fee)+' ' + c );
    histLine.setConcept(mov.getConcept());
    histLine.setProfit(profit);

    histLine.setImport(mov.getOutputCryptos() * -1);
    histLine.setbalance(wallet.getBalance());
    histLine.setvalue(wallet.getFifoValue());
    histLine.setMoveId(mov.getId());
    histLine.save();

    histLine.free;
    wallet.free;
end;


// *****************************************************************************
// *****************************************************************************


procedure computeWalletBalances();
var
 wallets : TWalletList;
 mov : TMovement;
 movements : TMovementList;
 I : Integer;
 movType : TMovementType;
begin


  // Remove all the history from all wallets
  wallets := walletController.getWallets();
  for I := 0 to wallets.count() -1 do
  begin
    wallets.get(I).clear();
    historyController.clear(wallets.get(i).getPk());
    wallets.get(I).save();
  end;

  // Remove all the FIFO values stored
  fifoController.clearAll();

  // Process all the movements to recompute the history and the balances/values
  movements := movementsController.getAll();
  for I := 0 to movements.count() -1 do
  begin
       application.ProcessMessages;
       mov := movements.get(I);
       movType := mov.getType();
       case movType of
         MV_SHELL:
            begin
               processShellMove(mov);
            end;
         MV_BUY:
            begin
               processBuyMove(mov);
            end;
         MV_TRANSFER:
            begin
               processTransferMove(mov);
            end;
       end;
  end;

end;

end.

