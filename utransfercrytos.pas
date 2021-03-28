unit utransfercrytos;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, DateTimePicker, Forms, Controls, Graphics,
  Dialogs, StdCtrls, Buttons, ExtCtrls, uwallets, ucryptos, umovements;

type

  { Tftransfercrytps }

  Tftransfercrytps = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    btnCancel: TBitBtn;
    btnOk: TBitBtn;
    dt_dateTime: TDateTimePicker;
    editConcept: TEdit;
    editWalletDestiny: TEdit;
    editCryptoEarned: TEdit;
    editTransactionFee: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    walletorigin: TComboBox;
    walletdestiny: TComboBox;
    _short1: TLabel;
    _short2: TLabel;
    procedure btnOkClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure walletoriginChange(Sender: TObject);
  private
    wallets : TWalletList;
    //crypto: TCrypto;
    procedure updateWalletList();
    procedure checkStatus();
  public
    fee: double;
    cryptos: double;


  end;

var
  ftransfercrytps: Tftransfercrytps;

implementation

{$R *.lfm}

procedure Tftransfercrytps.FormShow(Sender: TObject);
begin
    updateWalletList();
end;

procedure Tftransfercrytps.btnOkClick(Sender: TObject);
var
  mvnt : TMovement;
begin
     mvnt := TMovement.create();
     mvnt.setType(MV_TRANSFER);

     mvnt.setWalletOutput(wallets.get(walletorigin.ItemIndex).getPk());
     if (editWalletDestiny.text <> '') then
     begin
        mvnt.setWalletInput(editWalletDestiny.text);
     end
     else
     begin
        mvnt.setWalletInput(wallets.get(walletdestiny.ItemIndex).getPk());
     end;

     mvnt.setDateTime(dt_dateTime.DateTime);
     mvnt.setOutputCryptos(cryptos);
     mvnt.setOutputFee(fee);
     mvnt.setInputCryptos(cryptos);

     mvnt.save();
end;

procedure Tftransfercrytps.walletoriginChange(Sender: TObject);
begin
  checkStatus();
end;

procedure Tftransfercrytps.updateWalletList();
var
  I : Integer;
  _crytp : TCrypto;
begin
  wallets := walletController.getWallets();
  walletorigin.Items.Clear;
  walletdestiny.Items.Clear;
  for I := 0 to wallets.count() -1 do
  begin
    _crytp := cryptoController.getById(wallets.get(I).getCrypto());
    walletorigin.Items.Add(wallets.get(i).getName() + ' ' +_crytp.getShorName());
    walletdestiny.Items.Add(wallets.get(i).getName() + ' ' +_crytp.getShorName());
    _crytp.Free;
  end;
end;

procedure Tftransfercrytps.checkStatus();
var
  crypto: TCrypto;
  isValid : Boolean;
begin

  isValid := false;
  crypto := cryptoController.getById(wallets.get(walletorigin.ItemIndex).getCrypto());
  _short1.Caption:=crypto.getShorName();
  _short2.Caption:=crypto.getShorName();

  if (walletorigin.ItemIndex <> -1) and
     (((walletdestiny.ItemIndex <> -1) and (walletorigin.ItemIndex <> walletdestiny.ItemIndex))
        or (editWalletDestiny.Text <> '')
          ) then
    begin
       _short1.caption := crypto.getShorName();
       _short2.caption := crypto.getShorName();
       TryStrToFloat(StringReplace(editTransactionFee.text, '.', ',', [rfreplaceall]), fee);
       TryStrToFloat(StringReplace(editCryptoEarned.text, '.', ',', [rfreplaceall]), cryptos);
       if (cryptos > 0) then
         begin
            isValid:=true;
         end;
    end;

    btnOk.Enabled:=isValid;


  //checkStatus();


end;

end.

