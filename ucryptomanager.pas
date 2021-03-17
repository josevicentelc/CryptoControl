unit ucryptomanager;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Grids, ExtCtrls,
  Buttons, udatabaseconector, ucryptos, unewcrypto;

type

  { Tfcryptomanager }

  Tfcryptomanager = class(TForm)
    Panel1: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    cryptolist: TStringGrid;
    procedure cryptolistClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    db : TDatabaseConnector;
  public
    procedure setConnection(_db: TDatabaseConnector);
    procedure updateCryptoList();
    procedure formatGrid();

  end;

var
  fcryptomanager: Tfcryptomanager;

implementation

{$R *.lfm}

procedure Tfcryptomanager.FormShow(Sender: TObject);
begin
  formatGrid();
  updateCryptoList();
end;

procedure Tfcryptomanager.SpeedButton1Click(Sender: TObject);
var
  fnewcrypto : Tfnewcrypto;
  newc : TCrypto;
begin
  Application.CreateForm(TFnewCrypto, fNewCrypto);
  if fnewcrypto.ShowModal = mryes then
  begin
    newc := TCrypto.create();
    newc.setName(fnewcrypto.text_crypto_name.Text);
    newc.setShorName(fnewcrypto.text_short_name.Text);
    cryptoController.save(newc);
    updateCryptoList();
    newc.Free;
  end;
  fnewcrypto.free;

end;

procedure Tfcryptomanager.cryptolistClick(Sender: TObject);
begin

end;

procedure Tfcryptomanager.updateCryptoList();
var
  cryptos : TCryptoList;
  I : Integer;
begin
  cryptos := cryptoController.getCryptos();
  cryptolist.RowCount:=cryptos.count() + 1;
  for I := 0 to cryptos.count() -1 do
  begin
    cryptolist.cells[1, I+1] := cryptos.get(I).getName();
    cryptolist.cells[2, I+1] := cryptos.get(I).getShorName();
  end;
end;

procedure Tfcryptomanager.formatGrid();
begin
  cryptolist.ColWidths[0] := 15;
  cryptolist.ColWidths[1] := 200;
  cryptolist.ColWidths[2] := 60;
end;

procedure  Tfcryptomanager.setConnection(_db: TDatabaseConnector);
begin
  db := _db;
end;

end.

