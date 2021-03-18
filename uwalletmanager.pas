unit uwalletmanager;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Grids,
  Buttons, uwallets, ucryptos, unewwallet;

type

  { Tfwalletmanager }

  Tfwalletmanager = class(TForm)
    btnAddWallet: TBitBtn;
    btnRemoveWallet: TBitBtn;
    Panel1: TPanel;
    walletlist: TStringGrid;
    procedure btnAddWalletClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
      procedure formatgrid();
      procedure updateWalletList();
  public

  end;

var
  fwalletmanager: Tfwalletmanager;

implementation

{$R *.lfm}

{ Tfwalletmanager }

procedure Tfwalletmanager.formatGrid();
begin
  walletlist.ColWidths[0] := 15;
  walletlist.ColWidths[1] := 500; // wallet pk
  walletlist.ColWidths[2] := 200; // Name
  walletlist.ColWidths[3] := 150; // crypto
  walletlist.Cells[1, 0] := 'Wallet Id (Pub.Key)';
  walletlist.Cells[2, 0] := 'Wallet Name';
  walletlist.Cells[3, 0] := 'Coin';

end;

procedure Tfwalletmanager.updateWalletList();
var
  wallets : TWalletList;
  I : Integer;
  crypto: TCrypto;
begin
  wallets := walletController.getWallets();
  walletlist.RowCount:=wallets.count() + 1;
  for I := 0 to wallets.count() -1 do
  begin
    walletlist.cells[1, I+1] := wallets.get(I).getPk();
    walletlist.cells[2, I+1] := wallets.get(I).getName();
    crypto := cryptoController.getById(wallets.get(I).getCrypto());
    walletlist.cells[3, I+1] := crypto.getName();
    crypto.Free;
  end;
end;

procedure Tfwalletmanager.FormShow(Sender: TObject);
begin
     formatgrid();
     updateWalletList();
end;

procedure Tfwalletmanager.btnAddWalletClick(Sender: TObject);
var
  fnewwallet : TfnewWallet;
  newWallet : TWallet;
begin
     Application.createForm(TFNewWallet, fNewWallet);
     if fnewwallet.ShowModal = MrYes then
     begin
       // Insert
       newWallet := TWallet.create();
       newWallet.setPk(fnewwallet.editPk.text);
       newWallet.setName(fnewwallet.editName.text);
       newWallet.setCrypto(fnewwallet.coinList.get(fnewwallet.coins.ItemIndex).getId());
       walletController.save(newWallet);
       newWallet.free;
       updateWalletList();
     end;
     fnewwallet.free;
end;

end.

