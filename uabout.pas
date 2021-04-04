unit uabout;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Buttons, Clipbrd, ubarcodes;

type

  { TfAbout }

  TfAbout = class(TForm)
    BarcodeQR1: TBarcodeQR;
    BarcodeQR2: TBarcodeQR;
    BarcodeQR3: TBarcodeQR;
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
    procedure Label6Click(Sender: TObject);
    procedure Label6MouseEnter(Sender: TObject);
    procedure Label6MouseLeave(Sender: TObject);
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

procedure TfAbout.Label6Click(Sender: TObject);
begin
  Clipboard.AsText := (sender as TLabel).caption;
end;


procedure TfAbout.Label6MouseLeave(Sender: TObject);
 var
     I: Integer;
  begin
       Cursor := crDefault;
       for I := 0 to ControlCount - 1 do
       begin
           Controls[I].Cursor := crDefault;
       end;
end;


procedure TfAbout.Label6MouseEnter(Sender: TObject);
 var
     I: Integer;
  begin
       Cursor := crHandPoint;
       for I := 0 to ControlCount - 1 do
       begin
           Controls[I].Cursor := crHandPoint;
       end;
end;


end.

