program cryptocontrol;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, main, ucryptomanager, ucryptos, uwallets, unewcrypto, uwalletmanager,
  unewwallet, utils, umovementManager
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(Tmainform, mainform);
  Application.CreateForm(Tfcryptomanager, fcryptomanager);
  Application.CreateForm(Tfnewcrypto, fnewcrypto);
  Application.CreateForm(Tfwalletmanager, fwalletmanager);
  Application.CreateForm(TfnewWallet, fnewWallet);
  Application.CreateForm(TfMovementsManager, fMovementsManager);
  Application.Run;
end.

