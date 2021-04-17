unit utransfercrytos;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, DateTimePicker, Forms, Controls, Graphics,
  Dialogs, StdCtrls, Buttons, ExtCtrls, uwallets, ucryptos, umovements, utils;

type

  { Tftransfercrytps }

  Tftransfercrytps = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    btnCancel: TBitBtn;
    btnOk: TBitBtn;
    dt_dateTime: TDateTimePicker;
    editConcept: TEdit;
    editWalletDestiny: TEdit;
    editCryptoEarned: TEdit;
    editTransactionFee: TEdit;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    lbloutput: TLabel;
    Label9: TLabel;
    Shape1: TShape;
    walletorigin: TComboBox;
    walletdestiny: TComboBox;
    _short1: TLabel;
    _short2: TLabel;
    procedure btnOkClick(Sender: TObject);
    procedure dt_dateTimeKeyPress(Sender: TObject; var Key: char);
    procedure FormShow(Sender: TObject);
    procedure walletoriginChange(Sender: TObject);
  private
    wallets : TWalletList;
    procedure updateWalletList();
    procedure checkStatus();
    procedure loadMove(id : integer);
  public
    fee: double;
    cryptos: double;
    moveId : Integer;


  end;

var
  ftransfercrytps: Tftransfercrytps;

implementation

{$R *.lfm}

procedure Tftransfercrytps.loadMove(id : integer);
var
  mvnt : TMovement;
  I : integer;
begin
     mvnt := movementsController.getById(id);
     if mvnt.getType() = MV_TRANSFER then
     begin
          for I := 0 to wallets.count() -1 do
          begin
            if wallets.get(I).getPk() = mvnt.getWalletOutput() then
            begin
                 walletorigin.ItemIndex:=I;
            end;
            if wallets.get(I).getPk() = mvnt.getWalletInput() then
            begin
                 walletdestiny.ItemIndex:=I;
            end;
          end;

          if  walletdestiny.ItemIndex = -1 then
          begin
               editWalletDestiny.Text:=mvnt.getWalletInput();
          end;
          editConcept.text := mvnt.getConcept();
          dt_dateTime.DateTime:=mvnt.getDateTime();
          editTransactionFee.text := floatToSql(mvnt.getOutputFee());
          editCryptoEarned.text := floatToSql(mvnt.getInputCryptos());

     end;
     mvnt.free;
     checkStatus();
end;

procedure Tftransfercrytps.FormShow(Sender: TObject);
begin
  dt_dateTime.DateTime:=now();
  updateWalletList();
  if moveId <> 0 then loadMove(moveId);
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
     mvnt.setConcept(editConcept.text);
     mvnt.setOutputCryptos(cryptos);
     mvnt.setOutputFee(fee);
     mvnt.setInputCryptos(cryptos);

     if moveId <> 0 then mvnt.setId(moveId);
     mvnt.save();
end;

procedure Tftransfercrytps.dt_dateTimeKeyPress(Sender: TObject; var Key: char);
begin
    if not checkKeyForNumber(key) then key := #0;
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
       lbloutput.Caption:=floatToSql(cryptos + fee);
       if (cryptos > 0) then
         begin
            isValid:=true;
         end;
    end;

    btnOk.Enabled:=isValid;


  //checkStatus();


end;

end.

