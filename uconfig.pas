unit uconfig;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type

  TContableType=(CT_FIFO, CT_LIFO, CT_PMP);

  TConfig = class(TObject)
   private
     procedure processParameter(str: TStringArray);
   public
     useMarketSync : boolean;
     useCurrencyEuro: boolean;
     contableType : TContableType;
     mainColor: integer;
     alternateColor: integer;
     fixedColor: integer;
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
     useMarketSync:=true;
     useCurrencyEuro:=true;
     contableType:=CT_FIFO;
     mainColor:=$004B2F26;
     alternateColor:=$0043281F;
     fixedColor:=$006D4132;
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
       if str[0] = 'contableType' then
       begin
         if str[1] = 'FIFO' then contableType:=CT_FIFO
         else if str[1] = 'LIFO' then  contableType:=CT_LIFO
           else if str[1] = 'PMP' then contableType:=CT_PMP;
       end;
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

     if contableType=CT_FIFO then lines.Add('contableType=FIFO')
     else if contableType=CT_LIFO then lines.Add('contableType=LIFO')
     else if contableType=CT_PMP then lines.Add('contableType=PMP');

     lines.SaveToFile('config.cfg');
end;

end.

