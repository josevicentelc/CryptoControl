unit ucomunicacion;

{$mode objfpc}{$H+}

interface

// https://api.cryptowat.ch/markets/coinbase-pro/btceur/price  

uses
  Classes, SysUtils, fphttpclient, fpjson, jsonparser ,Dialogs;

function getUrl(url: string): string;
function postUrl(url: string; msg: string): string;
function getCurrentCompanies(): TJsonArray;

var


implementation


{
  Solicita al middleware la lista de empresas autorizadas para el usuario logeado
}
function getCurrentCompanies(): TJsonArray;
var
    msg : String;
    json : String;
    jsonObj : TJSONObject;
begin
  result := nil;
  if (currentUser <> '') and (currentSession <> '') then
  begin
     msg := '{';
     msg:= msg + '"email":"'+currentUser+'",';
     msg:= msg + '"sesion":"'+currentSession+'"';
     msg:= msg + '}';
     try
       json := postUrl('http://localhost:3001/usercompanies', msg);
       jsonObj := TJSONObject(GetJSON(json));
       if jsonObj.IndexOfName('companies') <> -1 then
       begin
          result := jsonObj.Arrays['companies'];
       end;
     except
        result := nil;
     end;
  end;
end;



{
  Solicitud de login en el middleware
  Si el login es correcto, se recibira un hash de sesion que almacenaremos
  y que debera acompañar a cada llamada que se haga al middleware
}
//function login(usr: String; pass : String): String;
//var
//  jData : TJSONData;
//  jObject : TJSONObject;
//  loginRes : String;
//  msg : String;
//  json : String;
//begin
{  msg := '{';
  msg:= msg + '"email":"'+usr+'",';
  msg:= msg + '"password":"'+pass+'"';
  msg:= msg + '}';
  json := postUrl('http://localhost:3001/login', msg);
  result := TJSONObject(GetJSON(json)).Strings['result'];
  if result = 'LOGIN_SUCCESS' then
  begin
        jData := GetJSON(json);
        jObject := TJSONObject(jdata);
        loginRes := jObject.Strings['result'];
        currentSession := jObject.Strings['sesion'];
        currentUser := usr;
        result := loginRes;
  end;}
//end;

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

