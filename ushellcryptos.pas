unit ushellcryptos;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  DateTimePicker, ucryptos, uwallets, umovements;

type

  { Tfshellcryptos }

  Tfshellcryptos = class(TForm)
    btnCancel: TBitBtn;
    btnOk: TBitBtn;
    dt_dateTime: TDateTimePicker;
    editCrypto: TEdit;
    editComision: TEdit;
    editTotalCefi: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    lblPrice: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    walletorigin: TComboBox;
    _short1: TLabel;
    procedure btnOkClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure walletoriginChange(Sender: TObject);
  private
    wallets : TWalletList;
    procedure updateWalletList();
    procedure checkStatus();
  public
    totalCryptos: double;
    totalCefi: double;
    TotalComision: double;

  end;

var
  fshellcryptos: Tfshellcryptos;

implementation

{$R *.lfm}

procedure Tfshellcryptos.FormShow(Sender: TObject);
begin
  dt_dateTime.DateTime:=now();
  updateWalletList();
  checkStatus();
end;

procedure Tfshellcryptos.btnOkClick(Sender: TObject);
var
  mvnt : TMovement;
begin
     mvnt := TMovement.create();
     mvnt.setType(MV_SHELL);

     mvnt.setWalletOutput(wallets.get(walletorigin.ItemIndex).getPk());
     mvnt.setDateTime(dt_dateTime.DateTime);

     mvnt.setOutputCryptos(totalCryptos);
     mvnt.setComisionShell(TotalComision);
     mvnt.setCefiInput(totalCefi);
     mvnt.setContableValueInput(totalCefi + TotalComision);
     mvnt.save();
end;

procedure Tfshellcryptos.walletoriginChange(Sender: TObject);
begin
  checkStatus();
end;

procedure Tfshellcryptos.updateWalletList();
var
  I : Integer;
  _crytp : TCrypto;
begin
  wallets := walletController.getWallets();
  walletorigin.Items.Clear;
  for I := 0 to wallets.count() -1 do
  begin
    _crytp := cryptoController.getById(wallets.get(I).getCrypto());
    walletorigin.Items.Add(wallets.get(i).getName() + ' ' +_crytp.getShorName());
    _crytp.Free;
  end;
end;

procedure Tfshellcryptos.checkStatus();
var
  crypto: TCrypto;
  isValid : Boolean;
  totalCefiSold : double;
  price : double;
  wallet: TWallet;
  cryptoName : String;
begin

  isValid := false;
  wallet :=wallets.get(walletorigin.ItemIndex);
  if wallet <> nil then
  begin
     crypto := cryptoController.getById(wallet.getCrypto());
     if crypto <> nil then cryptoName:=crypto.getShorName();
     _short1.Caption := cryptoName;
     if crypto <> nil then crypto.Free;
  end;


  if (walletorigin.ItemIndex <> -1) then
    begin
       editTotalCefi.Enabled:=true;
       editComision.enabled := true;
       editCrypto.enabled := true;
       TryStrToFloat(StringReplace(editCrypto.text, '.', ',', [rfreplaceall]), totalCryptos);
       TryStrToFloat(StringReplace(editComision.text, '.', ',', [rfreplaceall]), TotalComision);
       TryStrToFloat(StringReplace(editTotalCefi.text, '.', ',', [rfreplaceall]), totalCefi);

       lblPrice.caption := 'Price:';
       if (totalCryptos > 0) and (totalCefi > 0) then
         begin
            isValid:=true;

            totalCefiSold:=TotalComision + totalCefi;
            price := totalCefiSold / totalCryptos;
            lblPrice.caption := 'Price: 1 ' + cryptoName + ' = ' + FormatFloat('##0.00', price) + ' €';

         end;
    end
  else
  begin
    editTotalCefi.Enabled:=false;
    editComision.enabled := false;
    editCrypto.enabled := false;
  end;

  btnOk.Enabled:=isValid;


end;

end.

