unit main;

{$mode objfpc}{$H+}

interface

// https://api.cryptowat.ch/markets/coinbase-pro/btceur/price

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Grids,
  Buttons, StdCtrls, udatabaseconector, ucryptomanager, ucryptos, uwallets,
  uwalletmanager, umovementManager, umovements, umovementscompute, uwallethistory, utils, uabout,
  ubuycrypto, utransfercrytos, ushellcryptos
  ;

type

  { Tmainform }

  Tmainform = class(TForm)
    btn_settings1: TSpeedButton;
    color_grid_fixed: TShape;
    Label1: TLabel;
    Panel1: TPanel;
    btn_register_wallet: TSpeedButton;
    btn_admin_cryptos: TSpeedButton;
    btn_add_movement: TSpeedButton;
    btn_settings: TSpeedButton;
    Panel2: TPanel;
    color_background: TShape;
    color_grid_1: TShape;
    color_grid_2: TShape;
    Splitter1: TSplitter;
    gridWallets: TStringGrid;
    gridMovements: TStringGrid;
    procedure btn_add_movementClick(Sender: TObject);
    procedure btn_admin_cryptosClick(Sender: TObject);
    procedure btn_admin_exchangesClick(Sender: TObject);
    procedure btn_register_walletClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure formatColors();
    procedure FormShow(Sender: TObject);
    procedure gridMovementsDblClick(Sender: TObject);
    procedure gridMovementsSelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
    procedure gridWalletsClick(Sender: TObject);
    procedure gridWalletsSelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
  private
    selectedMoveRow: integer;
    db : TDatabaseConnector;
    form_admin_cryto : tfcryptomanager;
    form_admin_wallet : Tfwalletmanager;
    form_admin_movementst : TfMovementsManager;
    wallets: TWalletList;

  public
    procedure refreshWalletBalances();
    procedure showAbout();

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
     gridWallets.ColCount:= 6;

     for I := 0 to wallets.count() -1 do
     begin
       gridWallets.Cells[0, I+1] := wallets.get(I).getPk();
       gridWallets.Cells[1, I+1] := wallets.get(I).getName();
       gridWallets.Cells[2, I+1] := floatToSql(wallets.get(I).getBalance());
       gridWallets.Cells[3, I+1] := formatFloat('##0.00', wallets.get(I).getContableValue()) + ' €';
     end;
end;


procedure Tmainform.formatColors();
begin
     self.Color:=color_background.Brush.Color;

     gridWallets.Color:=color_grid_1.Brush.color;
     gridMovements.Color:=color_grid_1.Brush.color;

     gridWallets.AlternateColor:=color_grid_2.Brush.color;
     gridMovements.AlternateColor:=color_grid_2.Brush.color;

     gridWallets.FixedColor:=color_grid_fixed.Brush.color;
     gridMovements.FixedColor:=color_grid_fixed.Brush.color;

end;


procedure Tmainform.showAbout();
var
  fAbout: TFAbout;
begin
     Application.createForm(TFAbout, fAbout);
     fAbout.ShowModal;
     fabout.free;
end;

procedure Tmainform.FormCreate(Sender: TObject);
begin
     selectedMoveRow:=-1;
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
  showAbout();
end;

procedure Tmainform.gridMovementsDblClick(Sender: TObject);
var
  movId : integer;
  mov : TMovement;
  movType : TMovementType;
  frmBuy : Tfbuycrypto;
  frmTransfer : Tftransfercrytps;
  frmShell : Tfshellcryptos;
begin
  if gridMovements.Cells[5, selectedMoveRow] <> '' then
     begin
       movId := strtoint(gridMovements.Cells[5, selectedMoveRow]);
       mov := movementsController.getById(movId);
       if mov <> nil then
          begin
             movType := mov.getType();
             if movType = MV_BUY then
                begin
                    application.CreateForm(Tfbuycrypto, frmBuy);
                    frmBuy.moveId:=movId;
                    frmBuy.ShowModal;
                    frmBuy.free;
                end;
             if movType = MV_TRANSFER then
                begin
                    application.CreateForm(Tftransfercrytps, frmTransfer);
                    frmTransfer.ShowModal;
                    frmTransfer.free;
                end;
             if movType = MV_SHELL then
                begin
                    application.CreateForm(Tfshellcryptos, frmShell);
                    frmShell.moveId:=movId;
                    frmShell.ShowModal;
                    frmShell.free;
                end;

             computeWalletBalances();
             refreshWalletBalances();
          end;
     end;
end;

procedure Tmainform.gridMovementsSelectCell(Sender: TObject; aCol,
  aRow: Integer; var CanSelect: Boolean);
begin
     selectedMoveRow:=aRow;
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
     selectedMoveRow:=-1;
     wallet := gridWallets.Cells[0, aRow];
     history := historyController.getFromWallet(wallet);
     gridMovements.RowCount:=history.count() + 1;
     for I := 0 to history.count() -1 do
     begin
        gridMovements.Cells[0, I+1] := history.get(i).getDateTime();
        gridMovements.Cells[1, I+1] := history.get(i).getDescription();
        gridMovements.Cells[2, I+1] := floatToSql(history.get(i).getImport());
        gridMovements.Cells[3, I+1] := floatToSql(history.get(i).getbalance());
        gridMovements.Cells[4, I+1] := floatToSql(history.get(i).getvalue())+ ' €';
        gridMovements.Cells[5, I+1] := inttostr(history.get(i).getMoveId());
     end;

end;

procedure Tmainform.btn_admin_cryptosClick(Sender: TObject);
begin
     if form_admin_cryto = nil then Application.CreateForm(Tfcryptomanager, form_admin_cryto);
     form_admin_cryto.setConnection(db);
     form_admin_cryto.showModal();

end;

procedure Tmainform.btn_admin_exchangesClick(Sender: TObject);
begin

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

