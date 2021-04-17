unit ufreports;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons, uconfig,
  ExtCtrls, DateTimePicker, LCLIntf, umovementscompute, utils, uwallets, ucryptos, uwallethistory;

type

  { TfReports }

  TfReports = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    chkShowAcounts: TCheckBox;
    chkShowAcountMoves: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    chkShowAcountsCeroBalance: TCheckBox;
    dt_from: TDateTimePicker;
    dt_to: TDateTimePicker;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label9: TLabel;
    procedure BitBtn1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
        procedure reportWalletBalances(f : TStringList);
        procedure reportprofits(f : TStringList);
        function getTableMovesForAcount(pk: String): string;
  public

  end;

var
  fReports: TfReports;

implementation

{$R *.lfm}

{ TfReports }


function TfReports.getTableMovesForAcount(pk : String): string;
var
  history : THistoryList;
  I : Integer;
  line : integer;
  cls : String;
begin
  history := historyController.getFromWallet(pk);
  if history.count() > 0 then
  begin
     result := '<table><tr><td width="5%">&nbsp</td>';
     result := result + '<td  class="tableheader" width="15%">Date/Time</td><td  class="tableheader" width="40%">Concept</td>';
     result := result + '<td  class="tableheader" width="20%">Amount</td><td  class="tableheader" width="20%">Balance</td></tr>';
     for I := 0 to history.count() -1 do
     begin
       if line = 1 then
       begin
         cls := 'tableline1';
         line := 0;
       end
       else
       begin
         cls := 'tableline2';
         line := 1;
       end;
       result := result + '<tr><td>&nbsp</td>';
       result := result + '<td class="'+cls+'">'+history.get(i).getDateTimeToStr()+'</td>';
       result := result + '<td class="'+cls+'">'+history.get(i).getDescription()+'</td>';
       result := result + '<td class="'+cls+'">'+floatToSql(history.get(i).getImport())+'</td>';
       result := result + '<td class="'+cls+'">'+floatToSql(history.get(i).getbalance())+'</td>';
       result := result + '</tr>';
     end;
     result := result + '</table>';
  end;

  history.Free;
end;

procedure TfReports.reportWalletBalances(f : TStringList);
var
  wallets : TWalletList;
  cryptos : TCryptoList;
  I, J : Integer;
  cryp: Integer;
  something : boolean;
  line : integer;
  c : string;
  isFirstLine : boolean;
begin
  c := getConfig().currency();
  f.Add('<h1>Wallet balances</h1><br>');
  wallets := walletController.getWallets();
  cryptos := cryptoController.getCryptos();

  f.add('<table>');
  for I := 0 to cryptos.count() -1 do
  begin

    something:=false;
    isFirstLine:=true;
    line := 0;
    for J := 0 to wallets.count() -1 do
    begin
         if wallets.get(J).getCrypto() = cryptos.get(I).getId() then
         begin
             if (chkShowAcountsCeroBalance.Checked) or (wallets.get(J).getBalance() <> 0) then
             begin
                 something:=true;

                 if isFirstLine then
                 begin
                    f.Add('<tr class="tableheader">');
                    f.Add('<td width="11%">'+cryptos.get(I).getName()+'</td>');
                    f.Add('<td width="15%">Acount name</td>');
                    f.Add('<td width="12%">Balance</td>');
                    f.Add('<td width="12%">Value</td>');
                    f.Add('<td width="50%">Public Key</td>');
                    f.Add('</tr>');
                    isFirstLine:=false;
                 end;

                 if line = 1 then
                 begin
                    f.Add('<tr class="tableline1">');
                    line := 0;
                 end
                 else
                 begin
                   f.Add('<tr class="tableline2">');
                   line := 1;
                 end;

                 f.Add('<td>&nbsp</td>');
                 f.Add('<td>'+wallets.get(J).getName()+'</td>');
                 f.Add('<td>'+floatToSql(wallets.get(J).getBalance()) +' '+ cryptos.get(I).getShorName()+'</td>');
                 f.Add('<td>'+floatToCurrency(wallets.get(J).getFifoValue())+ ' ' + c+  '</td>');
                 f.Add('<td>'+wallets.get(J).getPk()+'</td>');

                 f.Add('</tr>');
                 if chkShowAcountMoves.Checked then
                 begin
                    f.Add('<tr><td colspan="5">'+getTableMovesForAcount(wallets.get(J).getPk())+'</td></tr>');
                 end;
             end;
         end;
    end;
    if something then f.Add('<tr><td>&nbsp</td><td>&nbsp</td><td>&nbsp</td></tr>');
  end;

  f.add('</table>');
  wallets.Free;
  cryptos.Free;
end;

procedure TfReports.reportprofits(f : TStringList);
var
   wallets : TWalletList;
   lines : THistoryList;
   profit : double;
   hasProfits : boolean;
   I, J : Integer;
   c : String;

   adquisitionCosts: double;
   transmisionCosts: double;
   valueBuy: double;
   valueShell: double;

begin

  c := getConfig().currency();
  profit := 0;
  adquisitionCosts:=0;
  transmisionCosts:=0;
  valueBuy := 0;
  valueShell:=0;
  wallets := walletController.getWallets();
  f.Add('<h1>Report profits</h1><br>');
  f.add('<table>');
    for I := 0 to wallets.count() -1 do
    begin

      lines := historyController.getFromWallet(wallets.get(i).getPk());
      hasProfits := false;

      for J := 0 to lines.count() -1 do
      begin
        if (lines.get(J).getProfit() <> 0) and (lines.get(J).getDateTime() >= dt_from.Date) and (lines.get(J).getDateTime() <= dt_to.Date +1) then
            hasProfits := true;
      end;

      if hasProfits then
      begin
         f.Add('<tr class="tableheader">');
         f.Add('<td width="15%">Wallet</td>');
         f.Add('<td width="85%">'+wallets.get(i).getName()+'</td>');
         f.Add('</tr>');
         f.Add('<tr class="tableline1">');
         f.Add('<td width="15%">&nbsp</td>');
         f.Add('<td width="85%">');
         f.Add('<table>');

                  f.Add('<tr class="tablesubheader">');
                  f.Add('<td width="15%">Date</td>');
                  f.Add('<td width="14%">Quantity</td>');
                  f.Add('<td width="14%">Buy price</td>');
                  f.Add('<td width="14%">Buy fees</td>');
                  f.Add('<td width="14%">Shell fees</td>');
                  f.Add('<td width="14%">Shell price</td>');
                  f.Add('<td width="15%">Profit</td>');
                  f.Add('</tr>');

                  for J := 0 to lines.count() -1 do
                  begin
                    if (lines.get(J).getProfit() <> 0) and (lines.get(J).getDateTime() >= dt_from.Date) and (lines.get(J).getDateTime() <= dt_to.Date +1 ) then
                    begin

                       f.Add('<tr class="tableline1">');
                       f.Add('<td>'+lines.get(J).getDateTimeToStr()+'</td>'); // Date
                       f.Add('<td>'+floatToSql( lines.get(J).getImport())+'</td>');   // Quantity
                       f.Add('<td>'+floatToCurrency(lines.get(J).getImportValue())+ ' ' + c+'</td>');
                       f.Add('<td>'+floatToCurrency(lines.get(J).getImportBuyFee())+ ' ' + c+'</td>');
                       f.Add('<td>'+floatToCurrency(lines.get(J).getImportShellFee())+ ' ' + c+'</td>');
                       f.Add('<td>'+floatToCurrency(lines.get(J).getShellPrice())+ ' ' + c+'</td>');
                       f.Add('<td>'+floatToCurrency( lines.get(J).getProfit())+ ' ' + c+'</td>');
                       f.Add('</tr>');

                       profit := profit + lines.get(J).getProfit();
                       adquisitionCosts := adquisitionCosts + lines.get(J).getImportBuyFee();
                       transmisionCosts := transmisionCosts + lines.get(J).getImportShellFee();
                       valueBuy := valueBuy + lines.get(J).getImportValue();
                       valueShell := valueShell + lines.get(J).getShellPrice();

                    end;
                  end;
                  f.Add('<tr>');
                  f.Add('<td>&nbsp</td>');
                  f.Add('<td>&nbsp</td>');
                  f.Add('<td>&nbsp</td>');
                  f.Add('<td>&nbsp</td>');
                  f.Add('<td>&nbsp</td>');
                  f.Add('<td>&nbsp</td>');
                  f.Add('<td>&nbsp</td>');
                  f.Add('</tr>');

         f.Add('</table>');
         f.Add('</td>');
         f.Add('</tr>');
      end;


      lines.free;
    end;
  f.add('</table>');

  f.add('<table style="width : 500px"><tr class="sumatory"><td width=300>Sumatory</td><td width=200>&nbsp</td></tr>');
  f.add('<tr><td>Buy import</td><td>'+ floatToCurrency(valueBuy)+ ' ' + c +'</td></tr>');
  f.add('<tr><td>Buy fees</td><td>'+ floatToCurrency(adquisitionCosts)+ ' ' + c +'</td></tr>');
  f.add('<tr><td>Shell import</td><td>'+ floatToCurrency(valueShell)+ ' ' + c +'</td></tr>');
  f.add('<tr><td>Shell fees</td><td>'+ floatToCurrency(transmisionCosts)+ ' ' + c +'</td></tr>');
  f.add('<tr><td>Profit</td><td>'+ floatToCurrency(profit)+ ' ' + c +'</td></tr>');
  f.add('</table>');

  //  // profit

end;

procedure TfReports.BitBtn1Click(Sender: TObject);
var
  f : TStringList;
  route: String;
begin
  (sender as TBitBtn).enabled := false;
  computeWalletBalances();
  f := TStringList.Create;


  f.Add('<html>');
  f.Add('<head>');
  f.Add('<style>');
  f.Add('table, th {');
  f.Add('  border: 0px;');
  f.Add('  border-collapse:collapse;');
  f.Add('  width: 100%;');
  f.Add('}');
  f.Add('body {');
  f.Add('  font-family: sans-serif;');
  f.Add('}');
  f.Add('.tableheader {');
  f.Add('  background-color: #BBFFBB;');
  f.Add('}');
  f.Add('.sumatory {');
  f.Add('  background-color: #BBBBFF;');
  f.Add('}');
  f.Add('.tablesubheader {');
  f.Add('  background-color: #AADDAA;');
  f.Add('}');
  f.Add('.tableLine1 {');
  f.Add('  background-color:  #FFFFFF;');
  f.Add('}');
  f.Add('.tableline2 {');
  f.Add('  background-color: #EEEEEE;');
  f.Add('}');
  f.Add('</style>');
  f.Add('</head>');


  f.add('<body>');

  if chkShowAcounts.Checked then reportWalletBalances(f);

  reportprofits(f);


  f.Add('</body></html>');
  route := getinstalldir() + 'report.html';
  f.SaveToFile(route);
  f.free;
//  WinExec(PChar('explorer.exe /e, ' + getinstalldir()),SW_SHOWNORMAL);
  OpenURL(route);
  (sender as TBitBtn).enabled := true;


end;

procedure TfReports.FormShow(Sender: TObject);
begin
  dt_from.Date:=Now();
  dt_to.Date:=Now();
end;

end.

