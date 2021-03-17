unit unewcrypto;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons;

type

  { Tfnewcrypto }

  Tfnewcrypto = class(TForm)
    btnCancel: TBitBtn;
    btnAdd: TBitBtn;
    text_crypto_name: TEdit;
    text_short_name: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    procedure text_crypto_nameChange(Sender: TObject);
  private

  public

  end;

var
  fnewcrypto: Tfnewcrypto;

implementation

{$R *.lfm}

{ Tfnewcrypto }

procedure Tfnewcrypto.text_crypto_nameChange(Sender: TObject);
begin
  btnAdd.Enabled := (trim(text_crypto_name.text) <> '') and (trim(text_short_name.text) <> '') ;
end;

end.

