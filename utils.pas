unit utils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, dateutils, StdCtrls, Graphics, base64, ExtCtrls, strutils;

function floatToSql(v: double): String;
function sqlToFloat(str: String): double;
function floatToCurrency(v: double): String;
function slash(value:string):string;
function dateToSql(value  :double): String;
function checkKeyForNumber(Key: char): Boolean;
function StringToSql(data : String):String;
function IMGtoBASE64(img : TPicture): String;
function Base64ToIMG(base64: String):TPicture;
function MemoryStreamToString(M: TMemoryStream): string;
function getinstalldir:string;

implementation

function slash(value:string):string;
begin
  if (value='') then result:=''
    else begin
    {$IFDEF WINDOWS}
    if (value[length(value)]<>'\') then result:=value+'\'
    {$ELSE}
    if (value[length(value)]<>'/') then result:=value+'/'
    {$ENDIF}
    else result:=value;
  end;
end;

function getinstalldir:string;
begin
  result:=slash(extractfiledir(paramstr(0)));
end;

function IMGtoBASE64(img : TPicture): String;
var
  mem : TMemoryStream;
begin
  mem := TMemoryStream.create;
  img.SaveToStream(mem);
  result := EncodeStringBase64(MemoryStreamToString(mem));
  result := stringReplace(result, '+', '_', [rfreplaceall]);
  result := stringReplace(result, '=', '-', [rfreplaceall]);
  mem.free;
end;


function Base64ToIMG(base64: String):TPicture;
var
  mem : TMemoryStream;
  data : String;
begin
  data := stringReplace(base64, '_', '+', [rfreplaceall]);
  result := TPicture.create;
  mem := TMemoryStream.create;
  mem.WriteAnsiString(DecodeStringBase64(data));
  if mem.Size > 0 then result.LoadFromStream(mem);
  mem.free;
end;


function MemoryStreamToString(M: TMemoryStream): string;
begin
  SetString(Result, PChar(M.Memory), M.Size div SizeOf(Char));
end;

function StringToSql(data : String):String;
begin
  result := stringReplace(data, '"', '´', [rfreplaceall]);
  result := stringReplace(result, '''', '´', [rfreplaceall]);
end;

function floatToSql(v: double): String;
begin
  result := stringReplace(formatFloat('##0.00##########', v), ',', '.', [rfReplaceAll]) ;
end;

function floatToCurrency(v: double): String;
begin
  result := formatFloat('#,##0.00', v) ;
end;


function sqlToFloat(str: String): double;
begin
  result := strToFloat(stringReplace(str, '.', ',', [rfReplaceAll]) );
end;

function dateToSql(value  :double): String;
begin
     result := formatFloat('###0.000000000000', value);
     result := stringReplace(result, ',', '.', [rfReplaceAll]);
end;

function checkKeyForNumber(Key: char): Boolean;
begin
  result := ((key >= '0') and (key <= '9')) or (key = '.') or (key = #13) or (key = #8);
end;

function isValidFloat(str : string): Boolean;
var
  f : double;
begin
  try
     result := true;
     TryStrToFloat(str, f);
  except
     result := false;
  end;
end;

end.

