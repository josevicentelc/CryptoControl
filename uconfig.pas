unit uconfig;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type

  TConfig = class(TObject)
   private
     procedure processParameter(str: TStringArray);
   public
     useMarketSync : boolean;
     useCurrencyEuro: boolean;
     constructor create;
     procedure load();
     procedure save();
     function currency(): String;
   end;

var
  _config : TConfig;
  function getConfig(): TConfig;

implementation

function getConfig(): TConfig;
begin
     if _config = nil then
     begin
       _config := TConfig.create;
       _config.load();
     end;
     result := _config;
end;

constructor TConfig.create;
begin
     useMarketSync:=false;
     useCurrencyEuro:=true;
end;

function TConfig.currency(): String;
begin
     if useCurrencyEuro then result := ' €'
     else result := ' $';
end;

procedure TConfig.load();
var
  lines : TStringList;
  I : Integer;
  strs : TStringArray;
begin
     if FileExists('config.cfg') then
     begin
       lines := TStringList.Create;
       lines.LoadFromFile('config.cfg');
       for I := 0 to lines.Count -1 do
       begin
         strs := lines[i].Split('=');
         processParameter(strs);
       end;
     end;
end;

procedure TConfig.processParameter(str: TStringArray);
begin
     if length(str) = 2 then
     begin
       if str[0] = 'useMarketSync' then useMarketSync:=str[1] = 'true';
       if str[0] = 'useCurrencyEuro' then useCurrencyEuro:=str[1] = 'true';
     end;
end;


procedure TConfig.save();
var
  lines : TStringList;
begin
     lines := TStringList.create;
     if useMarketSync then
     begin
       lines.Add('useMarketSync=true');
     end
     else
     begin
       lines.Add('useMarketSync=false');
     end;

     if useCurrencyEuro then
     begin
       lines.Add('useCurrencyEuro=true');
     end
     else
     begin
       lines.Add('useCurrencyEuro=false');
     end;

     lines.SaveToFile('config.cfg');
end;

end.

