unit ucryptomanager;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Grids, ExtCtrls,
  Buttons, udatabaseconector, ucryptos;

type

  { Tfcryptomanager }

  Tfcryptomanager = class(TForm)
    cryptolist: TDrawGrid;
    Panel1: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    procedure FormShow(Sender: TObject);
  private
    db : TDatabaseConnector;
  public
    procedure setConnection(_db: TDatabaseConnector);
    procedure updateCryptoList();

  end;

var
  fcryptomanager: Tfcryptomanager;

implementation

{$R *.lfm}

procedure Tfcryptomanager.FormShow(Sender: TObject);
begin
  updateCryptoList();
end;

procedure Tfcryptomanager.updateCryptoList();
var
  cryptos : TCryptoList;
begin
  //db.getCryptoList();
end;

procedure  Tfcryptomanager.setConnection(_db: TDatabaseConnector);
begin
  db := _db;
end;

end.

