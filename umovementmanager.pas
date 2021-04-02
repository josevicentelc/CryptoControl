unit umovementManager;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Buttons, ubuycrypto, utransfercrytos, ushellcryptos;

type

  { TfMovementsManager }

  TfMovementsManager = class(TForm)
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton6: TSpeedButton;
    SpeedButton8: TSpeedButton;
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
  private

  public

  end;

var
  fMovementsManager: TfMovementsManager;

implementation

{$R *.lfm}

{ TfMovementsManager }

procedure TfMovementsManager.SpeedButton1Click(Sender: TObject);
var
  form : Tfbuycrypto;
begin
     application.createform(Tfbuycrypto, form);
     form.ShowModal;
     form.free;
end;

procedure TfMovementsManager.SpeedButton2Click(Sender: TObject);
var
  form : Tftransfercrytps;
begin
     application.createform(Tftransfercrytps, form);
     form.ShowModal;
     form.free;
end;

procedure TfMovementsManager.SpeedButton3Click(Sender: TObject);
var
  form : Tfshellcryptos;
begin
     Application.createForm(Tfshellcryptos, form);
     form.showModal;
     form.free;
end;

end.

