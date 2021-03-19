unit umovementManager;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Buttons, ubuycrypto;

type

  { TfMovementsManager }

  TfMovementsManager = class(TForm)
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    SpeedButton7: TSpeedButton;
    SpeedButton8: TSpeedButton;
    procedure SpeedButton1Click(Sender: TObject);
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
     application.createform(Tfbuycrypto, fbuycrypto);
     fbuycrypto.ShowModal;
     fbuycrypto.free;
end;

end.

