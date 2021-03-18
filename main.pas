unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Grids,
  Buttons, StdCtrls, udatabaseconector, ucryptomanager, ucryptos, uwallets,
  uwalletmanager, umovementManager;

type

  { Tmainform }

  Tmainform = class(TForm)
    Label1: TLabel;
    Panel1: TPanel;
    btn_register_wallet: TSpeedButton;
    btn_admin_cryptos: TSpeedButton;
    btn_admin_exchanges: TSpeedButton;
    btn_add_movement: TSpeedButton;
    btn_settings: TSpeedButton;
    Panel2: TPanel;
    Splitter1: TSplitter;
    StringGrid1: TStringGrid;
    StringGrid2: TStringGrid;
    procedure btn_add_movementClick(Sender: TObject);
    procedure btn_admin_cryptosClick(Sender: TObject);
    procedure btn_register_walletClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    db : TDatabaseConnector;
    form_admin_cryto : tfcryptomanager;
    form_admin_wallet : Tfwalletmanager;
    form_admin_movementst : TfMovementsManager;
  public

  end;

var
  mainform: Tmainform;

implementation

{$R *.lfm}

{ Tmainform }


procedure Tmainform.FormCreate(Sender: TObject);
begin
     db := TDatabaseConnector.create('myfile.sql3');
     initCryptoController(db);
     initwalletController(db);
end;

procedure Tmainform.btn_admin_cryptosClick(Sender: TObject);
begin
     if form_admin_cryto = nil then Application.CreateForm(Tfcryptomanager, form_admin_cryto);
     form_admin_cryto.setConnection(db);
     form_admin_cryto.showModal();

end;

procedure Tmainform.btn_add_movementClick(Sender: TObject);
begin
     if form_admin_movementst = nil then Application.CreateForm(TfMovementsManager, form_admin_movementst);
     form_admin_movementst.showModal();
end;

procedure Tmainform.btn_register_walletClick(Sender: TObject);
begin
     if form_admin_wallet = nil then Application.CreateForm(Tfwalletmanager, form_admin_wallet);
     form_admin_wallet.showModal();
end;

end.

