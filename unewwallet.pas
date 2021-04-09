unit unewwallet;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Buttons, StdCtrls,
  ucryptos, uwallets, uconfig;

type

  { TfnewWallet }

  TfnewWallet = class(TForm)
    btnCancel: TBitBtn;
    btnok: TBitBtn;
    coins: TComboBox;
    editPk: TEdit;
    editName: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure coinsChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    destructor Destroy; override;
    procedure FormShow(Sender: TObject);

  private
    procedure checkSaveBtn();
    procedure fillCoins();
  public
    coinList : TCryptoList;

  end;

var
  fnewWallet: TfnewWallet;

implementation

{$R *.lfm}

procedure TfnewWallet.coinsChange(Sender: TObject);
begin
  checkSaveBtn();
end;


procedure TfnewWallet.FormCreate(Sender: TObject);
begin
  fillCoins();
end;

procedure TfnewWallet.fillCoins();
var
  I: Integer;
begin
     coins.Items.Clear;
     coinList := cryptoController.getCryptos();
     for I := 0 to coinList.count() -1 do
     begin
          coins.Items.Add(coinList.get(I).getName());
     end;
end;

procedure TfnewWallet.checkSaveBtn();
begin
  btnok.enabled := (coins.ItemIndex <> -1) and (trim(editPk.text) <> '' ) and (trim(editName.text) <> '' );
end;

destructor TfnewWallet.Destroy;
begin
  coinList.Free;
  inherited;
end;

procedure TfnewWallet.FormShow(Sender: TObject);
var
  I : Integer;
  w : TWallet;
begin
  if editPk.Text <> '' then
  begin
       w := walletController.getWallet(editPk.Text);
       editName.Text:=w.getName();
       for I := 0 to coinList.count() -1 do
       begin
            if coinList.get(i).getId() = w.getCrypto() then
            begin
                coins.ItemIndex:=I;
            end;
       end;
       w.Free;
       checkSaveBtn;
  end;

  self.color := getConfig().mainColor;

end;

end.

