unit ushellcryptos;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  ExtCtrls, DateTimePicker, ucryptos, uwallets, umovements, utils;

type

  { Tfshellcryptos }

  Tfshellcryptos = class(TForm)
    btnCancel: TBitBtn;
    btnOk: TBitBtn;
    dt_dateTime: TDateTimePicker;
    editCrypto: TEdit;
    editComision: TEdit;
    editTotalCefi: TEdit;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lblPrice: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    walletorigin: TComboBox;
    _short1: TLabel;
    procedure btnOkClick(Sender: TObject);
    procedure editCryptoKeyPress(Sender: TObject; var Key: char);
    procedure FormShow(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure walletoriginChange(Sender: TObject);
  private
    wallets : TWalletList;
    procedure updateWalletList();
    procedure checkStatus();
    procedure loadMove(id : integer);
  public
    moveId: integer;
    totalCryptos: double;
    totalCefi: double;
    TotalComision: double;

  end;

var
  fshellcryptos: Tfshellcryptos;

implementation

{$R *.lfm}

procedure Tfshellcryptos.loadMove(id : integer);
var
  mvnt : TMovement;
  I : integer;
begin
     mvnt := movementsController.getById(id);
     if mvnt.getType() = MV_SHELL then
     begin
          for I := 0 to wallets.count() -1 do
          begin
            if wallets.get(I).getPk() = mvnt.getWalletOutput() then
            begin
                 walletorigin.ItemIndex:=I;
            end;
          end;
          dt_dateTime.DateTime:=mvnt.getDateTime();
          editCrypto.text := floatToSql(mvnt.getOutputCryptos());
          editComision.text := floatToSql(mvnt.getComisionShell());
          editTotalCefi.text := floatToSql(mvnt.getCefiInput());
     end;
     mvnt.free;
end;

procedure Tfshellcryptos.FormShow(Sender: TObject);
begin
  dt_dateTime.DateTime:=now();
  updateWalletList();
  if moveId >= 0 then loadMove(moveId);
  checkStatus();
end;

procedure Tfshellcryptos.Label1Click(Sender: TObject);
begin
  if walletorigin.ItemIndex <> -1 then
  begin
       editCrypto.Text :=  floatToSql(wallets.get(walletorigin.ItemIndex).getBalance());
       checkStatus();
  end;
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

     if moveId >= 0 then mvnt.setId(moveId);
     mvnt.save();
end;

procedure Tfshellcryptos.editCryptoKeyPress(Sender: TObject; var Key: char);
begin
    if not checkKeyForNumber(key) then key := #0;
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

