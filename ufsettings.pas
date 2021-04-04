unit ufsettings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Buttons, exportdata;

type

  { TfSettings }

  TfSettings = class(TForm)
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
  private

  public

  end;

var
  fSettings: TfSettings;

implementation

{$R *.lfm}


{ TfSettings }

procedure TfSettings.SpeedButton1Click(Sender: TObject);
begin
  exportAll('saved');
end;

procedure TfSettings.SpeedButton2Click(Sender: TObject);
begin
  importAll('saved');
end;

procedure TfSettings.SpeedButton3Click(Sender: TObject);
begin
  clearMoves();
  clearWallets();
  clearCoins();
end;

end.

