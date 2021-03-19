unit ubuycrypto;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  MaskEdit, Menus, JVEdit, DateTimePicker, utils;

type

  { Tfbuycrypto }

  Tfbuycrypto = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    ComboBox1: TComboBox;
    DateTimePicker1: TDateTimePicker;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    PopupMenu1: TPopupMenu;
    procedure Edit2KeyPress(Sender: TObject; var Key: char);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  fbuycrypto: Tfbuycrypto;

implementation

{$R *.lfm}

{ Tfbuycrypto }

procedure Tfbuycrypto.Edit2KeyPress(Sender: TObject; var Key: char);
begin

if not checkKeyForNumber(key) then key := #0;
end;

procedure Tfbuycrypto.FormShow(Sender: TObject);
begin
DateTimePicker1.DateTime:=now();
end;

end.

