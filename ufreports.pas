unit ufreports;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
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
    CheckBox5: TCheckBox;
    chkShowAcountsCeroBalance: TCheckBox;
    dt_dateTime: TDateTimePicker;
    dt_dateTime1: TDateTimePicker;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    procedure BitBtn1Click(Sender: TObject);
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
begin
  f.Add('<h1>Wallet balances</h1><br>');
  wallets := walletController.getWallets();
  cryptos := cryptoController.getCryptos();

  f.add('<table>');
  f.Add('<tr class="tableheader">');
  f.Add('<td>Public Key</td>');
  f.Add('<td>Acount name</td>');
  f.Add('<td>Balance</td>');
  f.Add('</tr>');
  for I := 0 to cryptos.count() -1 do
  begin

    something:=false;
    for J := 0 to wallets.count() -1 do
    begin
         if wallets.get(J).getCrypto() = cryptos.get(I).getId() then
         begin
             if (chkShowAcountsCeroBalance.Checked) or (wallets.get(J).getBalance() <> 0) then
             begin
                 something:=true;

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

                 f.Add('<td>'+wallets.get(J).getPk()+'</td>');
                 f.Add('<td>'+wallets.get(J).getName()+'</td>');
                 f.Add('<td>'+floatToSql(wallets.get(J).getBalance()) +' '+ cryptos.get(I).getShorName()+'</td>');
                 f.Add('</tr>');
                 if chkShowAcountMoves.Checked then
                 begin
                    f.Add('<tr><td colspan="3">'+getTableMovesForAcount(wallets.get(J).getPk())+'</td></tr>');
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
begin
  f.Add('<h1>Report profits</h1><br>');
end;

procedure TfReports.BitBtn1Click(Sender: TObject);
var
  f : TStringList;
  route: String;
begin
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
  f.Add('.tableheader {');
  f.Add('  background-color: #FFBBBB;');
  f.Add('}');
  f.Add('.tableLine1 {');
  f.Add('  background-color:  #BBBBBB;');
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

end;

end.

