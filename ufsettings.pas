unit ufsettings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Buttons, MetroButton,
  exportdata, uconfig;

type

  { TfSettings }

  TfSettings = class(TForm)
    btn_showNonBalanceAccounts: TMetroButton;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    procedure btn_showNonBalanceAccountsClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
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

procedure TfSettings.FormShow(Sender: TObject);
begin
  btn_showNonBalanceAccounts.Selected:=getConfig().showNonBalanceAccounts;
end;

procedure TfSettings.btn_showNonBalanceAccountsClick(Sender: TObject);
begin
  btn_showNonBalanceAccounts.Selected := not btn_showNonBalanceAccounts.Selected;
  getConfig().showNonBalanceAccounts := btn_showNonBalanceAccounts.Selected;
  getConfig().save();
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

