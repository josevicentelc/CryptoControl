unit uabout;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls;

type

  { TfAbout }

  TfAbout = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Label10: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Shape1: TShape;
    procedure Label2Click(Sender: TObject);
    procedure Label8Click(Sender: TObject);
  private

  public

  end;

var
  fAbout: TfAbout;

implementation

{$R *.lfm}

{ TfAbout }

procedure TfAbout.Label2Click(Sender: TObject);
begin

end;

procedure TfAbout.Label8Click(Sender: TObject);
begin

end;

end.

