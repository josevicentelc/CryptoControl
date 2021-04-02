program cryptocontrol;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, datetimectrls, main, ucryptomanager, ucryptos, uwallets, unewcrypto,
  uwalletmanager, unewwallet, utils, umovementManager, umovements, ubuycrypto,
  umovementscompute, utransfercrytos, uwallethistory, uabout, ureport, ushellcryptos
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(Tmainform, mainform);
  Application.CreateForm(Tfreport, freport);
  Application.CreateForm(Tfshellcryptos, fshellcryptos);
  Application.Run;
end.

