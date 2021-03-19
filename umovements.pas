unit umovements;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;


type

  TMovementType=(MV_BUY, MV_TRANSFER, MV_SHELL, MV_SWAP, MV_MINING, MV_RECEIVE, MV_SEND, MV_LOSS);

  TMovement = class(TObject)
  private
     _id : integer;
     _type : TMovementType;
     _datetime : double;
     _concept : String;
     _wallet_destiny : String;
     _cefi_import: double;
     _comision_buy: double;
     _transaction_fee: double;
  public
    constructor create();
    procedure setId(id: integer);
    procedure setType(t: TMovementType);
    procedure setDateTime(dt: double);
    procedure setConcept(cn: String);
    procedure setWalletDestiny(pk: String);
    procedure setCefiImport(value: Double);
    procedure setComisionBuy(value : double);
    procedure setTransactionFee(value: double);
    function getId(): integer;
    function getType(): TMovementType;
    function getDateTime(): double;
    function getConcept(): String;
    function getWalletDestiny(): String;
    function getCefiImport(): Double;
    function getComisionBuy(): double;
    function getTransactionFee(): double;

  end;

implementation

constructor TMovement.create();                          begin          end;
procedure TMovement.setId(id: integer);                  begin          _id := id;             end;
procedure TMovement.setType(t: TMovementType);           begin          _type := t;            end;
procedure TMovement.setDateTime(dt: double);             begin          _datetime:=dt;         end;
procedure TMovement.setConcept(cn: String);              begin          _concept := cn;        end;
procedure TMovement.setWalletDestiny(pk: String);        begin          _wallet_destiny:=pk;   end;
procedure TMovement.setCefiImport(value: double);        begin          _cefi_import:=value;   end;
procedure TMovement.setComisionBuy(value : double);      begin          _comision_buy:=value;  end;
procedure TMovement.setTransactionFee(value: double);    begin          _transaction_fee:=value;end;
function TMovement.getId(): integer;                     begin          result:=_id;           end;
function TMovement.getType(): TMovementType;             begin          result := _type;       end;
function TMovement.getDateTime(): double;                begin          result := _datetime;   end;
function TMovement.getConcept(): String;                 begin          result:=_concept;      end;
function TMovement.getWalletDestiny(): String;           begin          result := _wallet_destiny; end;
function TMovement.getCefiImport(): Double;              begin          result:=_cefi_import;      end;
function TMovement.getComisionBuy(): double;             begin          result:=_comision_buy;     end;
function TMovement.getTransactionFee(): double;          begin          result := _transaction_fee;end;



end.

