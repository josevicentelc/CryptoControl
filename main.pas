unit main;

{$mode objfpc}{$H+}

interface

// https://api.cryptowat.ch/markets/coinbase-pro/btceur/price

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Grids,
  Buttons, StdCtrls, Menus, udatabaseconector, ucryptomanager, ucryptos,
  uwallets, uwalletmanager, umovementManager, umovements, umovementscompute,
  uwallethistory, utils, uabout, ubuycrypto, utransfercrytos, ushellcryptos,
  uconfig, exportdata, ufsettings, ufreports, MetroButton;


type

  { Tmainform }

  Tmainform = class(TForm)
    color_grid_fixed: TShape;
    Label1: TLabel;
    MenuItem1: TMenuItem;
    MetroButton1: TMetroButton;
    MetroButton2: TMetroButton;
    MetroButton3: TMetroButton;
    MetroButton4: TMetroButton;
    MetroButton5: TMetroButton;
    Panel1: TPanel;
    Panel2: TPanel;
    color_background: TShape;
    color_grid_1: TShape;
    color_grid_2: TShape;
    PopupMenu1: TPopupMenu;
    Splitter1: TSplitter;
    gridWallets: TStringGrid;
    gridMovements: TStringGrid;
    procedure btn_add_movementClick(Sender: TObject);
    procedure btn_admin_cryptosClick(Sender: TObject);
    procedure btn_register_walletClick(Sender: TObject);
    procedure btn_settings1Click(Sender: TObject);
    procedure btn_settingsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure formatColors();
    procedure FormShow(Sender: TObject);
    procedure gridMovementsDblClick(Sender: TObject);
    procedure gridMovementsSelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
    procedure gridWalletsSelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
    procedure MenuItem1Click(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
  private
    selectedMoveRow: integer;
    selectedWalletRow: integer;

    db : TDatabaseConnector;
    form_admin_cryto : tfcryptomanager;
    form_admin_wallet : Tfwalletmanager;
    form_admin_movementst : TfMovementsManager;
    wallets: TWalletList;

  public
    procedure refreshWalletBalances();
    procedure refreshMoves();
    procedure showAbout();

  end;

var
  mainform: Tmainform;

implementation

{$R *.lfm}

{ Tmainform }

// *****************************************************************************
// *****************************************************************************

procedure Tmainform.refreshWalletBalances();
var
  I : Integer;
  crypto: TCrypto;
  c : String;

  totalValue : double;
  totalMarketPrice : double;
  totalProfit : double;

begin
     totalValue := 0; totalMarketPrice := 0; totalProfit := 0;
     c := getConfig().currency();
     wallets := walletController.getWallets();
     gridWallets.RowCount:=wallets.count() + 2;
     gridWallets.ColCount:= 7;

     for I := 0 to wallets.count() -1 do
     begin
       crypto := cryptoController.getById(wallets.get(i).getCrypto());
       crypto.refreshMarketValue();
       gridWallets.Cells[0, I+1] := wallets.get(I).getPk();
       gridWallets.Cells[1, I+1] := wallets.get(I).getName();
       gridWallets.Cells[2, I+1] := floatToSql(wallets.get(I).getBalance());
       gridWallets.Cells[3, I+1] := formatFloat('##0.00', wallets.get(I).getContableValue()) + c;
       gridWallets.Cells[4, I+1] := formatFloat('##0.00', crypto.getMarketPrice()) + c;
       gridWallets.Cells[5, I+1] := formatFloat('##0.00', crypto.getMarketPrice() * wallets.get(I).getBalance() ) + c;
       gridWallets.Cells[6, I+1] := formatFloat('##0.00', crypto.getMarketPrice() * wallets.get(I).getBalance() -  wallets.get(I).getContableValue()) + c;

       totalValue := totalValue + wallets.get(I).getContableValue();
       totalMarketPrice := totalMarketPrice + crypto.getMarketPrice() * wallets.get(I).getBalance();
       totalProfit := totalProfit + crypto.getMarketPrice() * wallets.get(I).getBalance() -  wallets.get(I).getContableValue();
     end;


     gridWallets.Cells[3, wallets.count() +1] := formatFloat('##0.00', totalValue) + c;
     gridWallets.Cells[5, wallets.count() +1] := formatFloat('##0.00', totalMarketPrice) + c;
     gridWallets.Cells[6, wallets.count() +1] := formatFloat('##0.00', totalProfit) + c;


end;

// *****************************************************************************
// *****************************************************************************

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

// *****************************************************************************
// *****************************************************************************

procedure Tmainform.showAbout();
var
  fAbout: TFAbout;
begin
     Application.createForm(TFAbout, fAbout);
     fAbout.ShowModal;
     fabout.free;
end;

// *****************************************************************************
// *****************************************************************************

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

// *****************************************************************************
// *****************************************************************************

procedure Tmainform.FormShow(Sender: TObject);
begin
  refreshWalletBalances();
  showAbout();
end;

// *****************************************************************************
// *****************************************************************************

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
                    frmTransfer.moveId:=movId;
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
             refreshMoves();
          end;
     end;
end;

// *****************************************************************************
// *****************************************************************************

procedure Tmainform.gridMovementsSelectCell(Sender: TObject; aCol,
  aRow: Integer; var CanSelect: Boolean);
begin
     selectedMoveRow:=aRow;
end;

// *****************************************************************************
// *****************************************************************************

procedure Tmainform.gridWalletsSelectCell(Sender: TObject; aCol, aRow: Integer;
  var CanSelect: Boolean);
begin
     selectedWalletRow:=aRow;
     refreshMoves;
end;

procedure Tmainform.MenuItem1Click(Sender: TObject);
var
  movid : integer;
begin
   movId := strtoint(gridMovements.Cells[5, selectedMoveRow]);
   movementsController.remove(movid);
   computeWalletBalances();
   refreshWalletBalances();
   refreshMoves();
end;

procedure Tmainform.PopupMenu1Popup(Sender: TObject);
begin
  MenuItem1.enabled := selectedMoveRow >= 0;
end;

procedure Tmainform.SpeedButton1Click(Sender: TObject);
begin

end;

procedure Tmainform.SpeedButton2Click(Sender: TObject);
begin

end;

procedure Tmainform.SpeedButton3Click(Sender: TObject);
begin

end;

// *****************************************************************************
// *****************************************************************************

procedure Tmainform.refreshMoves();
var
  wallet : String;
  history : THistoryList;
  I : Integer;
  c : String;
begin
     c := getConfig().currency();
     selectedMoveRow:=-1;
     wallet := gridWallets.Cells[0, selectedWalletRow];
     history := historyController.getFromWallet(wallet);
     gridMovements.RowCount:=history.count() + 1;
     for I := 0 to history.count() -1 do
     begin
        gridMovements.Cells[0, I+1] := history.get(i).getDateTimeToStr();
        gridMovements.Cells[1, I+1] := history.get(i).getDescription();
        gridMovements.Cells[2, I+1] := floatToSql(history.get(i).getImport());
        gridMovements.Cells[3, I+1] := floatToSql(history.get(i).getbalance());
        gridMovements.Cells[4, I+1] := floatToSql(history.get(i).getvalue())+ c;
        gridMovements.Cells[5, I+1] := inttostr(history.get(i).getMoveId());
     end;

end;

// *****************************************************************************
// *****************************************************************************

procedure Tmainform.btn_admin_cryptosClick(Sender: TObject);
begin
     if form_admin_cryto = nil then Application.CreateForm(Tfcryptomanager, form_admin_cryto);
     form_admin_cryto.setConnection(db);
     form_admin_cryto.showModal();

end;

// *****************************************************************************
// *****************************************************************************

procedure Tmainform.btn_add_movementClick(Sender: TObject);
begin
     if form_admin_movementst = nil then Application.CreateForm(TfMovementsManager, form_admin_movementst);
     form_admin_movementst.showModal();
     computeWalletBalances();
     refreshWalletBalances();
end;

// *****************************************************************************
// *****************************************************************************

procedure Tmainform.btn_register_walletClick(Sender: TObject);
begin
     if form_admin_wallet = nil then Application.CreateForm(Tfwalletmanager, form_admin_wallet);
     form_admin_wallet.showModal();
end;

procedure Tmainform.btn_settings1Click(Sender: TObject);
var
  fReports : TFReports;
begin
     application.createForm(TFReports, FReports);
     FReports.ShowModal;
     FReports.free;
end;

procedure Tmainform.btn_settingsClick(Sender: TObject);
var
  fsettings : TfSettings;
begin
     Application.CreateForm(TfSettings, fsettings);
     fsettings.ShowModal;
     fsettings.free;

     computeWalletBalances();
     refreshWalletBalances();
     refreshMoves();

end;

// *****************************************************************************
// *****************************************************************************

end.

