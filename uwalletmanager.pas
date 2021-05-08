unit uwalletmanager;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Grids,
  Buttons, uwallets, ucryptos, unewwallet, uconfig, MetroButton;

type

  { Tfwalletmanager }

  Tfwalletmanager = class(TForm)
    MetroButton3: TMetroButton;
    btn_editwallet: TMetroButton;
    btn_deletewallet: TMetroButton;
    Panel1: TPanel;
    walletlist: TStringGrid;
    procedure btnAddWalletClick(Sender: TObject);
    procedure btn_deletewalletClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure walletlistSelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
  private
      procedure formatgrid();
      procedure updateWalletList();
  public
    selectedWallet : String;

  end;

var
  fwalletmanager: Tfwalletmanager;

implementation

{$R *.lfm}

{ Tfwalletmanager }

procedure Tfwalletmanager.formatGrid();
begin
  walletlist.ColWidths[0] := 500; // wallet pk
  walletlist.ColWidths[1] := 200; // Name
  walletlist.ColWidths[2] := 150; // crypto
  walletlist.Cells[0, 0] := 'Wallet Id (Pub.Key)';
  walletlist.Cells[1, 0] := 'Wallet Name';
  walletlist.Cells[2, 0] := 'Coin';

  walletList.Color:=getConfig().mainColor;
  walletList.AlternateColor:=getConfig().alternateColor;
  walletList.FixedColor:=getConfig().fixedColor;

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
    walletlist.cells[0, I+1] := wallets.get(I).getPk();
    walletlist.cells[1, I+1] := wallets.get(I).getName();
    crypto := cryptoController.getById(wallets.get(I).getCrypto());
    walletlist.cells[2, I+1] := crypto.getName();
    crypto.Free;
  end;
end;

procedure Tfwalletmanager.FormShow(Sender: TObject);
begin
     formatgrid();
     updateWalletList();
end;

procedure Tfwalletmanager.walletlistSelectCell(Sender: TObject; aCol,
  aRow: Integer; var CanSelect: Boolean);
begin
  selectedWallet:=walletlist.Cells[0, aRow];
end;

procedure Tfwalletmanager.btnAddWalletClick(Sender: TObject);
var
  fnewwallet : TfnewWallet;
  newWallet : TWallet;
begin
     Application.createForm(TFNewWallet, fNewWallet);
     if (Sender = btn_editwallet) and (selectedWallet <> '') then
     begin
       fnewwallet.editPk.Text := selectedWallet;
     end;
     if fnewwallet.ShowModal = MrYes then
     begin
       // Insert
       newWallet := TWallet.create();
       newWallet.setPk(fnewwallet.editPk.text);
       newWallet.setName(fnewwallet.editName.text);
       newWallet.setCrypto(fnewwallet.coinList.get(fnewwallet.coins.ItemIndex).getId());
       walletController.writeWallet(newWallet);
       newWallet.free;
       updateWalletList();
     end;
     fnewwallet.free;
end;

procedure Tfwalletmanager.btn_deletewalletClick(Sender: TObject);
begin
  if selectedWallet <> '' then
  begin
    walletController.remove(selectedWallet);
    selectedWallet:='';
    updateWalletList();
  end;
end;

end.

