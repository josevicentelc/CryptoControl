unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Grids,
  Buttons, StdCtrls, udatabaseconector, ucryptomanager, ucryptos, uwallets,
  uwalletmanager, umovementManager, umovements, umovementscompute, uwallethistory, utils;

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
    Shape1: TShape;
    Shape2: TShape;
    Splitter1: TSplitter;
    gridWallets: TStringGrid;
    gridMovements: TStringGrid;
    procedure btn_add_movementClick(Sender: TObject);
    procedure btn_admin_cryptosClick(Sender: TObject);
    procedure btn_register_walletClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure formatColors();
    procedure FormShow(Sender: TObject);
    procedure gridWalletsClick(Sender: TObject);
    procedure gridWalletsSelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
  private
    db : TDatabaseConnector;
    form_admin_cryto : tfcryptomanager;
    form_admin_wallet : Tfwalletmanager;
    form_admin_movementst : TfMovementsManager;
    wallets: TWalletList;

  public
    procedure refreshWalletBalances();

  end;

var
  mainform: Tmainform;

implementation

{$R *.lfm}

{ Tmainform }

procedure Tmainform.refreshWalletBalances();
var
  I : Integer;
begin
     wallets := walletController.getWallets();
     gridWallets.RowCount:=wallets.count() + 1;
     gridWallets.ColCount:= 4;

     for I := 0 to wallets.count() -1 do
     begin
       gridWallets.Cells[0, I+1] := wallets.get(I).getPk();
       gridWallets.Cells[1, I+1] := wallets.get(I).getName();
       gridWallets.Cells[2, I+1] := formatFloat('##0.000000000000', wallets.get(I).getBalance());
       gridWallets.Cells[3, I+1] := formatFloat('##0.00', wallets.get(I).getContableValue());
     end;
end;


procedure Tmainform.formatColors();
begin
     self.Color:=Shape1.Brush.Color;

     gridWallets.Color:=shape1.Brush.color;
     gridMovements.Color:=shape1.Brush.color;
     gridWallets.FixedColor:=shape2.Brush.color;
     gridMovements.FixedColor:=shape2.Brush.color;
end;

procedure Tmainform.FormCreate(Sender: TObject);
begin
     formatColors();
     db := TDatabaseConnector.create('myfile.sql3');
     initCryptoController(db);
     initwalletController(db);
     initMovementsontroller(db);
     initHistoryController(db);
end;

procedure Tmainform.FormShow(Sender: TObject);
begin
  refreshWalletBalances();
end;

procedure Tmainform.gridWalletsClick(Sender: TObject);
begin

end;

procedure Tmainform.gridWalletsSelectCell(Sender: TObject; aCol, aRow: Integer;
  var CanSelect: Boolean);
var
  wallet : String;
  history : THistoryList;
  I : Integer;
begin
     wallet := gridWallets.Cells[0, aRow];
     history := historyController.getFromWallet(wallet);
     gridMovements.RowCount:=history.count() + 1;
     for I := 0 to history.count() -1 do
     begin
        gridMovements.Cells[0, I+1] := history.get(i).getDateTime();
        gridMovements.Cells[1, I+1] := history.get(i).getDescription();
        gridMovements.Cells[2, I+1] := floatToSql(history.get(i).getImport());
        gridMovements.Cells[3, I+1] := floatToSql(history.get(i).getbalance());
        gridMovements.Cells[4, I+1] := floatToSql(history.get(i).getvalue());
     end;

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
     computeWalletBalances();
     refreshWalletBalances();
end;

procedure Tmainform.btn_register_walletClick(Sender: TObject);
begin
     if form_admin_wallet = nil then Application.CreateForm(Tfwalletmanager, form_admin_wallet);
     form_admin_wallet.showModal();
end;

end.

