unit unewwallet;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Buttons, StdCtrls,
  ucryptos;

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
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    destructor Destroy; override;

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

procedure TfnewWallet.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin

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

end.

