unit utils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

function floatToSql(v: double): String;

implementation

function floatToSql(v: double): String;
begin
  result := stringReplace(formatFloat('##0.000000000000', v), ',', '.', [rfReplaceAll]) ;
end;

end.

