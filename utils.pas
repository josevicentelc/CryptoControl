unit utils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StdCtrls;

function floatToSql(v: double): String;
function checkKeyForNumber(Key: char): Boolean;

implementation

function floatToSql(v: double): String;
begin
  result := stringReplace(formatFloat('##0.000000000000', v), ',', '.', [rfReplaceAll]) ;
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

