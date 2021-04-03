unit ubuycrypto;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  MaskEdit, Menus, ExtCtrls, JVEdit, DateTimePicker, utils, ucryptos, uwallets,
  umovements;

type

  { Tfbuycrypto }

  Tfbuycrypto = class(TForm)
    btnOk: TBitBtn;
    btnCancel: TBitBtn;
    Image1: TImage;
    lbConversion: TLabel;
    lbContableValue: TLabel;
    walletlist: TComboBox;
    dt_dateTime: TDateTimePicker;
    editConcept: TEdit;
    editCefiImport: TEdit;
    editCefiComision: TEdit;
    editTransactionFee: TEdit;
    editCryptoEarned: TEdit;
    Label1: TLabel;
    Label10: TLabel;
    _short1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    _short2: TLabel;
    Label9: TLabel;
    PopupMenu1: TPopupMenu;
    procedure btnOkClick(Sender: TObject);
    procedure editCefiImportChange(Sender: TObject);
    procedure editCefiImportKeyPress(Sender: TObject; var Key: char);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure walletlistChange(Sender: TObject);
  private

    cefiValue : double;
    cefiComision : double;
    feeValue : double;
    earnedValue : double;
    cefiMinusComision : double;
    earnedPlusFee : double;
    cryptoPrice : double;
    contableValue : double;


    wallets : TWalletList;
    crypto: TCrypto;
    procedure updateWalletList();
    procedure checkStatus();
    procedure loadMove(id : integer);
  public
    moveId: integer;

  end;

var
  fbuycrypto: Tfbuycrypto;

implementation

{$R *.lfm}

{ Tfbuycrypto }

// *****************************************************************************

procedure Tfbuycrypto.editCefiImportKeyPress(Sender: TObject; var Key: char);
begin
  if not checkKeyForNumber(key) then key := #0;
end;

// *****************************************************************************

procedure Tfbuycrypto.FormCreate(Sender: TObject);
begin
  moveId:=-1;
end;

// *****************************************************************************

procedure Tfbuycrypto.editCefiImportChange(Sender: TObject);
begin
  checkStatus();
end;

// *****************************************************************************

procedure Tfbuycrypto.btnOkClick(Sender: TObject);
var
  mvnt : TMovement;
begin
     mvnt := TMovement.create();
     mvnt.setType(MV_BUY);
     mvnt.setWalletInput(wallets.get(walletlist.ItemIndex).getPk());
     mvnt.setCefiOutput(cefiValue);
     mvnt.setComisionBuy(cefiComision);
     mvnt.setContableValueInput(contableValue);
     mvnt.setInputFee(feeValue);
     mvnt.setInputCryptos(earnedValue);
     mvnt.setDateTime(dt_dateTime.DateTime);

     if moveId >= 0 then mvnt.setId(moveId);

     mvnt.save();
end;

// *****************************************************************************

procedure Tfbuycrypto.loadMove(id : integer);
var
  mvnt : TMovement;
  I : integer;
begin
     mvnt := movementsController.getById(id);
     if mvnt.getType() = MV_BUY then
     begin
          for I := 0 to wallets.count() -1 do
          begin
            if wallets.get(I).getPk() = mvnt.getWalletInput() then
            begin
                 walletlist.ItemIndex:=I;
            end;
          end;
          if crypto <> nil then crypto.free;
          crypto := cryptoController.getById(wallets.get(walletlist.ItemIndex).getCrypto());
          _short1.caption := crypto.getShorName();
          _short2.caption := crypto.getShorName();

          dt_dateTime.DateTime:=mvnt.getDateTime();
          editCefiImport.text := floatToSql(mvnt.getComisionBuy() + mvnt.getCotnableValueInput());
          editCefiComision.text := floatToSql(mvnt.getComisionBuy());
          editTransactionFee.text := floatToSql(mvnt.getInputFee());
          editCryptoEarned.text := floatToSql(mvnt.getInputCryptos());
     end;
     mvnt.free;
end;

// *****************************************************************************

procedure Tfbuycrypto.FormShow(Sender: TObject);
begin
     dt_dateTime.DateTime:=now();
     updateWalletList();
     if moveId >= 0 then loadMove(moveId);
     checkStatus();
end;

// *****************************************************************************

procedure Tfbuycrypto.walletlistChange(Sender: TObject);
begin
  if crypto <> nil then crypto.free;
  crypto := cryptoController.getById(wallets.get(walletlist.ItemIndex).getCrypto());
  _short1.caption := crypto.getShorName();
  _short2.caption := crypto.getShorName();
  checkStatus();
end;

// *****************************************************************************

procedure Tfbuycrypto.updateWalletList();
var
  I : Integer;
  _crytp : TCrypto;
begin
  wallets := walletController.getWallets();
  walletlist.Items.Clear;
  for I := 0 to wallets.count() -1 do
  begin
    _crytp := cryptoController.getById(wallets.get(I).getCrypto());
    walletlist.Items.Add(wallets.get(i).getName() + ' ' +_crytp.getShorName());
    _crytp.Free;
    crypto.Free;
  end;
end;

// *****************************************************************************

procedure Tfbuycrypto.checkStatus();
begin
     if (walletlist.ItemIndex = -1) then
     begin
          editCefiImport.Enabled:=false;
          editCefiComision.Enabled:=false;
          editTransactionFee.enabled := false;
          editCryptoEarned.Enabled:=false;
          btnOk.Enabled:=false;
     end
     else
     begin
       editCefiImport.Enabled:=true;
       editCefiComision.Enabled:=true;
       editTransactionFee.enabled := true;
       editCryptoEarned.Enabled:=true;

       TryStrToFloat(StringReplace(editCefiImport.text, '.', ',', [rfreplaceall]), cefiValue);
       TryStrToFloat(StringReplace(editCefiComision.text, '.', ',', [rfreplaceall]), cefiComision);
       TryStrToFloat(StringReplace(editTransactionFee.text, '.', ',', [rfreplaceall]), feeValue);
       TryStrToFloat(StringReplace(editCryptoEarned.text, '.', ',', [rfreplaceall]), earnedValue);

       lbConversion.caption := '-';
       lbContableValue.caption := '-';
       btnOk.Enabled:=false;

       if (cefiValue > 0) and (earnedValue > 0) then
       begin
            earnedPlusFee:=earnedValue + feeValue;
            cefiMinusComision:=cefiValue - cefiComision;
            cryptoPrice := cefiMinusComision / earnedPlusFee ;

            contableValue:=cefiMinusComision - cefiMinusComision * (feeValue / (earnedPlusFee));

            lbConversion.caption := '1 '+crypto.getShorName() + ' = ' + FormatFloat('###,##0.00', cryptoPrice) + '$/€';
            lbContableValue.caption := 'Contable value: ' + FormatFloat('###,##0.00', contableValue) + '$/€';;

            btnOk.Enabled:=true;
       end;
     end;
end;
// *****************************************************************************

end.

