unit ucomunicacion;

{$mode objfpc}{$H+}

interface

// https://api.cryptowat.ch/markets/coinbase-pro/btceur/price  

uses
  Classes, SysUtils, fphttpclient, fpjson, jsonparser ,Dialogs;

function getUrl(url: string): string;
function postUrl(url: string; msg: string): string;
function getMarketValue(pair: string): double;


implementation


function getMarketValue(pair: string): double;
var
  jsonObj : TJSONObject;
  json : String;
begin
  json := getUrl('https://api.cryptowat.ch/markets/coinbase-pro/'+pair+'/price' );
  jsonObj := TJSONObject(GetJSON(json));
  if jsonObj.IndexOfName('result') <> -1 then
       begin
          jsonObj := jsonObj.Objects['result'];
          if jsonObj.IndexOfName('price') <> -1 then
               begin
                  result := jsonObj.Floats['price'];
               end;
       end;
end;


// Funcion generica que envia un Json stringificado (msg) a la (url) indicada
function postUrl(url: string; msg: string): string;
var
  conn : TFPHTTPClient;
begin
  conn := TFPHTTPClient.Create(nil);
  try
    try
       result:= conn.FormPost(url, msg);
    except
       result := 'error';
    end;
  finally
    conn.Free;
  end;
end;

// Funcion generica Get a la url indicada
function getUrl(url: string): string;
var
  conn : TFPHTTPClient;
begin
  conn := TFPHTTPClient.Create(nil);
  try
    try
       result:= conn.Get(url);
    except
       result := 'error';
    end;
  finally
    conn.Free;
  end;
end;

end.

