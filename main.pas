unit main;

{$mode objfpc}{$H+}

interface

// https://api.cryptowat.ch/markets/coinbase-pro/btceur/price

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Grids,
  Buttons, StdCtrls, Menus, udatabaseconector, ucryptomanager, ucryptos,
  uwallets, uwalletmanager, umovementManager, umovements, umovementscompute,
  uwallethistory, utils, uabout, ubuycrypto, utransfercrytos, ushellcryptos,
  uconfig, ufsettings, ufreports, MetroButton, JVStringGrid, ufifowallet, Types;


type

  { Tmainform }

  Tmainform = class(TForm)
    color_grid_fixed: TShape;
    edit_filter_pk: TEdit;
    edit_filter_name: TEdit;
    gridWallets: TStringGrid;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    MenuItem1: TMenuItem;
    MetroButton1: TMetroButton;
    MetroButton2: TMetroButton;
    MetroButton3: TMetroButton;
    MetroButton4: TMetroButton;
    MetroButton5: TMetroButton;
    btnShowMoves: TMetroButton;
    btnShowFifo: TMetroButton;
    btnrefresh: TMetroButton;
    Panel1: TPanel;
    Panel2: TPanel;
    color_background: TShape;
    color_grid_1: TShape;
    color_grid_2: TShape;
    Panel3: TPanel;
    PopupMenu1: TPopupMenu;
    Splitter1: TSplitter;
    gridMovements: TStringGrid;
    procedure btnrefreshClick(Sender: TObject);
    procedure btnShowMovesClick(Sender: TObject);
    procedure btn_add_movementClick(Sender: TObject);
    procedure btn_admin_cryptosClick(Sender: TObject);
    procedure btn_register_walletClick(Sender: TObject);
    procedure btn_settings1Click(Sender: TObject);
    procedure btn_settingsClick(Sender: TObject);
    procedure edit_filter_pkChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure formatColors();
    procedure FormShow(Sender: TObject);
    procedure gridMovementsDblClick(Sender: TObject);
    procedure gridMovementsSelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
    procedure gridWalletsDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure gridWalletsSelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
    procedure MenuItem1Click(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
  private
    selectedMoveRow: integer;
    selectedWalletRow: integer;

    db : TDatabaseConnector;
    form_admin_cryto : tfcryptomanager;
    form_admin_wallet : Tfwalletmanager;
    form_admin_movementst : TfMovementsManager;
    wallets: TWalletList;

  public
    procedure refreshWalletBalances(fastMode: boolean);
    procedure refreshMoves();
    procedure refreshFifo();
    procedure refreshSubGrid();
    procedure showAbout();
    procedure recomputeAll();

  end;

var
  mainform: Tmainform;
  bussy : boolean;

implementation

{$R *.lfm}

{ Tmainform }

// *****************************************************************************
// *****************************************************************************

procedure Tmainform.refreshWalletBalances(fastMode: boolean);
var
  I : Integer;
  crypto: TCrypto;
  c : String;

  totalValue : double;
  totalMarketPrice : double;
  totalProfit : double;

  filterPk : String;
  filterName : String;
  wpk : String;
  wname : String;
  row : integer;
  useMarketPrice : boolean;

  thisValue : double;
  thisMarketPrice : double;
  thisProfit : double;
  showByBalanceFilter : boolean;
  originalUsePriceSync : boolean;
begin

     // Si fast mode es True, desactivo la actualización de precios desde internet
     // Así evito retardos durante la actualización del listado
     originalUsePriceSync:=getConfig().useMarketSync;
     getConfig().useMarketSync := not fastMode;


     totalValue := 0; totalMarketPrice := 0; totalProfit := 0;
     c := getConfig().currency();
     wallets := walletController.getWallets();
     gridWallets.RowCount:=1;
     row := 0;
     gridWallets.ColCount:= 7;

     filterPk := lowercase(trim(edit_filter_pk.text));
     filtername := lowercase(trim(edit_filter_name.text));

     for I := 0 to wallets.count() -1 do
     begin

       wpk := LowerCase(wallets.get(I).getPk());
       wname := LowerCase(wallets.get(I).getName());
       showByBalanceFilter:= (wallets.get(I).getBalance() <> 0) or (getConfig().showNonBalanceAccounts);

       if ((filterPk = '') or (wpk.Contains(filterPk))) and (showByBalanceFilter) then
       begin
          if (filterName = '') or (wname.Contains(filterName)) then
          begin
             gridWallets.RowCount:=gridWallets.RowCount+1;
             row := row + 1;

             crypto := cryptoController.getById(wallets.get(i).getCrypto());
             crypto.refreshMarketValue();
             useMarketPrice:=crypto.getUseSync();

             gridWallets.Cells[6, row] := wallets.get(I).getPk();
             gridWallets.Cells[0, row] := wallets.get(I).getName();
             gridWallets.Cells[1, row] := floatToSql(wallets.get(I).getBalance());
             gridWallets.Cells[2, row] := floatToCurrency(wallets.get(I).getFifoValue()) + c;

             thisValue := wallets.get(I).getFifoValue();
             if useMarketPrice then
             begin
                thisMarketPrice := crypto.getMarketPrice() * wallets.get(I).getBalance();
                thisProfit := crypto.getMarketPrice() * wallets.get(I).getBalance() -  wallets.get(I).getFifoValue();
                gridWallets.Cells[3, row] := floatToCurrency(crypto.getMarketPrice()) + c;
                gridWallets.Cells[4, row] := floatToCurrency(thisMarketPrice) + c;
                gridWallets.Cells[5, row] := floatToCurrency(thisProfit) + c;
             end
             else
             begin
               thisMarketPrice := 0;
               thisProfit := 0;
               gridWallets.Cells[3, row] := '----' + c;
               gridWallets.Cells[4, row] := '----' + c;
               gridWallets.Cells[5, row] := '----' + c;
             end;


             totalValue := totalValue + thisValue;
             totalMarketPrice := totalMarketPrice + thisMarketPrice;
             totalProfit := totalProfit + thisProfit;
          end;
       end;
     end;


     gridWallets.RowCount:=gridWallets.RowCount+1;
     row := row + 1;
     gridWallets.Cells[2, row] := floatToCurrency(totalValue) + c;
     gridWallets.Cells[4, row] := floatToCurrency(totalMarketPrice) + c;
     gridWallets.Cells[5, row] := floatToCurrency(totalProfit) + c;

     getConfig().useMarketSync := originalUsePriceSync;

end;

// *****************************************************************************
// *****************************************************************************

procedure Tmainform.formatColors();
begin
     self.Color:=getConfig().mainColor;

     gridWallets.Color:=getConfig().mainColor;
     gridMovements.Color:=getConfig().mainColor;

     gridWallets.AlternateColor:=getConfig().alternateColor;
     gridMovements.AlternateColor:=getConfig().alternateColor;

     gridWallets.FixedColor:=getConfig().fixedColor;
     gridMovements.FixedColor:=getConfig().fixedColor;

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

procedure Tmainform.recomputeAll();
begin
  gridWallets.Visible:=false;
  gridMovements.Visible:=false;
  computeWalletBalances();
  refreshWalletBalances(false);
  refreshSubGrid();
  gridWallets.Visible:=true;
  gridMovements.Visible:=true;
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
     initFifoController(db);
end;

// *****************************************************************************
// *****************************************************************************

procedure Tmainform.FormShow(Sender: TObject);
begin
  refreshWalletBalances(false);
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
  mr : integer;
begin
  if (btnShowMoves.Selected) and (gridMovements.Cells[5, selectedMoveRow] <> '') then
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
                    mr := frmBuy.ShowModal;
                    frmBuy.free;
                end;
             if movType = MV_TRANSFER then
                begin
                    application.CreateForm(Tftransfercrytps, frmTransfer);
                    frmTransfer.moveId:=movId;
                    mr := frmTransfer.ShowModal;
                    frmTransfer.free;
                end;
             if movType = MV_SHELL then
                begin
                    application.CreateForm(Tfshellcryptos, frmShell);
                    frmShell.moveId:=movId;
                     mr := frmShell.ShowModal;
                    frmShell.free;
                end;

             if mr = mryes then recomputeAll();
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

procedure Tmainform.gridWalletsDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
var
  val : double;
  texto : String;
  grid : TStringGrid;
begin
  grid := (sender as TStringGrid);
  if (aCol = 5) and (aRow > 0) then
     begin
        texto := trim( stringReplace( grid.Cells[aCol, aRow], '€', '', [rfreplaceall] ) );
        texto := stringReplace(texto, '.', '', [rfreplaceall]);
        if texto <> '' then
        begin
            trystrtofloat(texto, val);
            grid.Canvas.FillRect(aRect);

            if val > 0 then   grid.Canvas.Font.color := clGreen
            else if val < 0 then grid.Canvas.Font.color := $3333BB
            else grid.Canvas.Font.color := clWhite;

            Grid.canvas.TextRect(aRect,aRect.Left +2, aRect.Top + 2, grid.Cells[aCol, aRow]);
        end;
     end;
end;

// *****************************************************************************
// *****************************************************************************

procedure Tmainform.gridWalletsSelectCell(Sender: TObject; aCol, aRow: Integer;
  var CanSelect: Boolean);
begin
     selectedWalletRow:=aRow;
     refreshSubGrid();
end;

procedure Tmainform.MenuItem1Click(Sender: TObject);
var
  movid : integer;
begin
   movId := strtoint(gridMovements.Cells[5, selectedMoveRow]);
   movementsController.remove(movid);
   computeWalletBalances();
   refreshWalletBalances(false);
   refreshSubGrid();
end;

procedure Tmainform.PopupMenu1Popup(Sender: TObject);
begin
  MenuItem1.enabled := selectedMoveRow >= 0;
end;



// *****************************************************************************
// *****************************************************************************

procedure Tmainform.refreshSubGrid();
begin
  if btnShowMoves.Selected then refreshMoves()
  else if btnShowFifo.Selected then refreshFifo();
end;

procedure Tmainform.refreshFifo();
var
  pk : String;
  wallet : TWallet;
  list : TFifoList;
  crypto : TCrypto;
  I : Integer;
  c : String;
  amount, value, price, profit, cryptoMarketPrice : double;
begin

  gridMovements.ColCount:=6;
  gridMovements.RowCount:= 1;

  gridMovements.Cells[0, 0] := 'Id';
  gridMovements.Cells[1, 0] := 'Amount';
  gridMovements.Cells[2, 0] := 'Value';
  gridMovements.Cells[3, 0] := 'Buy fee';
  gridMovements.Cells[4, 0] := 'Market price';
  gridMovements.Cells[5, 0] := 'Profit';

  gridMovements.ColWidths[0] := 75;
  gridMovements.ColWidths[1] := 250;
  gridMovements.ColWidths[2] := 175;
  gridMovements.ColWidths[3] := 175;
  gridMovements.ColWidths[4] := 175;
  gridMovements.ColWidths[5] := 175;

  if selectedWalletRow >= gridWallets.RowCount then selectedWalletRow:=0;
  if (selectedWalletRow > 0)  and (gridWallets.Cells[6, selectedWalletRow] <> '') then
       begin

          c := getConfig().currency();
          selectedMoveRow:=-1;
          pk := gridWallets.Cells[6, selectedWalletRow];
          wallet := walletController.getWallet(pk);
          crypto := cryptoController.getById(wallet.getCrypto());
          list := fifoController.getFifoList(pk);
          cryptoMarketPrice:=crypto.getMarketPrice();
          wallet.Free;
          crypto.Free;

          gridMovements.RowCount:=list.count() + 1;
          for I := 0 to list.count() -1 do
          begin
            if I+1 < gridMovements.RowCount then
            begin
               amount := list.get(i).amount;
               value := list.get(i).value;
               price := amount * cryptoMarketPrice;
               profit := price - value;
               gridMovements.Cells[0, I+1] := inttostr(list.get(i).id);
               gridMovements.Cells[1, I+1] := floatToSql(amount);
               gridMovements.Cells[2, I+1] := floatToCurrency(value) + ' '+ c;
               gridMovements.Cells[3, I+1] := floatToCurrency(list.get(i).buyfee) + ' '+ c;
               gridMovements.Cells[4, I+1] := floatToCurrency(price) + ' ' + c;
               gridMovements.Cells[5, I+1] := floatToCurrency(profit) + ' '+ c;
            end;
          end;
       end;
end;

procedure Tmainform.refreshMoves();
var
  wallet : String;
  history : THistoryList;
  I : Integer;
  c : String;
begin

   //while bussy do
   //application.ProcessMessages;

   bussy := true;

  if selectedWalletRow >= gridWallets.RowCount then selectedWalletRow:=0;

  if selectedWalletRow > 0 then
     begin
        gridMovements.ColCount:=6;
        gridMovements.RowCount:= 1;
        gridMovements.Cells[0, 0] := 'Date/Time';
        gridMovements.Cells[1, 0] := 'Action';
        gridMovements.Cells[2, 0] := 'Amount';
        gridMovements.Cells[3, 0] := 'Balance';
        gridMovements.Cells[4, 0] := 'Value';
        gridMovements.Cells[5, 0] := 'Id';
        gridMovements.ColWidths[0] := 175;
        gridMovements.ColWidths[1] := 600;
        gridMovements.ColWidths[2] := 130;
        gridMovements.ColWidths[3] := 130;
        gridMovements.ColWidths[4] := 130;
        gridMovements.ColWidths[5] := 130;

        c := getConfig().currency();
        selectedMoveRow:=-1;
        wallet := gridWallets.Cells[6, selectedWalletRow];
        history := historyController.getFromWallet(wallet);
        gridMovements.RowCount:=history.count() + 1;
        for I := 0 to history.count() -1 do
        begin
           gridMovements.Cells[0, I+1] := history.get(i).getDateTimeToStr();
           gridMovements.Cells[1, I+1] := history.get(i).getDescription();
           gridMovements.Cells[2, I+1] := floatToSql(history.get(i).getImport());
           gridMovements.Cells[3, I+1] := floatToSql(history.get(i).getbalance());
           gridMovements.Cells[4, I+1] := floatToCurrency(history.get(i).getvalue())+ c;
           gridMovements.Cells[5, I+1] := inttostr(history.get(i).getMoveId());
        end;
     end;
   bussy := false;

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
     recomputeAll();
end;

procedure Tmainform.btnShowMovesClick(Sender: TObject);
begin
  if sender = btnShowMoves then
     begin
        btnShowMoves.Selected:=true;
        btnShowFifo.Selected:=false;
     end
  else
  begin
    btnShowMoves.Selected:=false;
    btnShowFifo.Selected:=true;
  end;
  refreshSubGrid();
end;

procedure Tmainform.btnrefreshClick(Sender: TObject);
begin
     refreshWalletBalances(false);
     refreshSubGrid();
end;

// *****************************************************************************
// *****************************************************************************

procedure Tmainform.btn_register_walletClick(Sender: TObject);
begin
     if form_admin_wallet = nil then Application.CreateForm(Tfwalletmanager, form_admin_wallet);
     form_admin_wallet.showModal();
     computeWalletBalances();
     refreshWalletBalances(false);
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
     refreshWalletBalances(false);
     refreshSubGrid();

end;

procedure Tmainform.edit_filter_pkChange(Sender: TObject);
begin
     refreshWalletBalances(true);
     refreshSubGrid();
end;

// *****************************************************************************
// *****************************************************************************

end.

