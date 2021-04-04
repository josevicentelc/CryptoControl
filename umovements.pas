unit umovements;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, udatabaseconector, sqldb, utils;


type

  TMovementType=(MV_BUY, MV_TRANSFER, MV_SHELL, MV_SWAP, MV_MINING, MV_RECEIVE, MV_SEND, MV_LOSS);

  TMovement = class(TObject)
  private
     _id : integer;
     _type : TMovementType;
     _datetime : double;
     _concept : String;

     _wallet_output : String;
     _wallet_input : String; // <-

     _cefi_input: double;
     _cefi_output: double;

     _comision_buy: double;  // <-
     _comision_Shell: double;

     _contable_value_output: double;
     _contable_value_input: double; // <-

     _input_fee: double;  // <-
     _output_fee: double;  // <-
     _inputCryptos: double;  // <-
     _outputCryptos: double;

  public
    constructor create();
    procedure setId(id: integer);
    procedure setType(t: TMovementType);
    procedure setTypeInt(v : integer);
    procedure setDateTime(dt: double);
    procedure setConcept(cn: String);
    procedure setWalletOutput(pk: String);
    procedure setWalletInput(pk: String);
    procedure setCefiInput(value: Double);
    procedure setCefiOutput(value: Double);
    procedure setComisionBuy(value : double);
    procedure setComisionShell(value : double);
    procedure setInputFee(value: double);
    procedure setOutputFee(value: double);
    procedure setInputCryptos(value: double);
    procedure setOutputCryptos(value: double);
    procedure setContableValueOutput(value: double);
    procedure setContableValueInput(value: double);


    function getId(): integer;
    function getType(): TMovementType;
    function getTypeInt(): Integer;
    function getDateTime(): double;
    function getConcept(): String;
    function getWalletInput(): String;
    function getWalletOutput(): String;
    function getCefiInput(): Double;
    function getCefiOutput(): Double;
    function getComisionBuy(): double;
    function getComisionShell(): double;
    function getInputFee(): double;
    function getOutputFee(): double;
    function getInputCryptos(): double;
    function getOutputCryptos(): double;
    function getCotnableValueOutput(): double;
    function getCotnableValueInput(): double;

    function getPriceInputCrypto(): double;
    function getPriceOutputCrypto(): double;

    procedure export(F : TStringList);
    procedure import(line: String);

    procedure save();

  end;


  TMovementArray = Array of TMovement;


  TMovementList = class(TObject)
  private
   list : TMovementArray;
   _count : integer;
  public
    constructor create();
    destructor Destroy; override;
    function count(): integer;
    procedure push(item: TMovement);
    procedure clear();
    function get(i : integer): TMovement;
  end;

  TMovementsController = class(TObject)
  private
   db: TDatabaseConnector;
  public
    constructor create(_db: TDatabaseConnector);
    function getNextId(): integer;

    procedure save(mvnt: TMovement);
    function getById(_id: integer): TMovement;
    function getAll(): TMovementList;
    function getByWallet(w: String): TMovementList;
    procedure remove(id: integer);
    procedure clearAll();

  end;


var
  movementsController : TMovementsController;
  procedure initMovementsontroller(db: TDatabaseConnector);

implementation

procedure initMovementsontroller(db: TDatabaseConnector);
begin
     if movementsController <> nil then movementsController.Free;
     movementsController := TMovementsController.create(db);
end;

constructor TMovement.create();                          begin          end;
procedure TMovement.setId(id: integer);                  begin          _id := id;             end;
procedure TMovement.setType(t: TMovementType);           begin          _type := t;            end;
procedure TMovement.setDateTime(dt: double);             begin          _datetime:=dt;         end;
procedure TMovement.setConcept(cn: String);              begin          _concept := cn;        end;
procedure TMovement.setWalletInput(pk: String);          begin          _wallet_input:=pk;   end;
procedure TMovement.setWalletOutput(pk: String);         begin          _wallet_output:=pk;    end;
procedure TMovement.setCefiInput(value: double);         begin          _cefi_input:=value;   end;
procedure TMovement.setCefiOutput(value: double);        begin          _cefi_output:=value;   end;
procedure TMovement.setComisionBuy(value : double);      begin          _comision_buy:=value;  end;
procedure TMovement.setComisionShell(value : double);    begin          _comision_Shell:=value;end;
procedure TMovement.setInputFee(value: double);          begin          _input_fee := value;   end;
procedure TMovement.setOutputFee(value: double);          begin          _output_fee := value;   end;
procedure TMovement.setInputCryptos(value: double);     begin          _inputCryptos:=value; end;
procedure TMovement.setOutputCryptos(value: double);     begin          _outputCryptos:=value; end;
procedure TMovement.setContableValueOutput(value: double); begin        _contable_value_output:=value; end;
procedure TMovement.setContableValueInput(value: double); begin        _contable_value_input:=value; end;

procedure TMovement.setTypeInt(v: integer);
begin
     case v of
          0: _type := MV_BUY;
          1: _type := MV_TRANSFER;
          2: _type := MV_SHELL;
          3: _type := MV_SWAP;
          4: _type := MV_MINING;
          5: _type := MV_RECEIVE;
          6: _type := MV_SEND;
          7: _type := MV_LOSS;
          end;
end;

function TMovement.getId(): integer;                     begin          result:=_id;           end;
function TMovement.getType(): TMovementType;             begin          result := _type;       end;
function TMovement.getDateTime(): double;                begin          result := _datetime;   end;
function TMovement.getConcept(): String;                 begin          result:=_concept;      end;
function TMovement.getWalletInput(): String;             begin          result := _wallet_Input; end;
function TMovement.getWalletOutput(): String;            begin          result := _wallet_output; end;
function TMovement.getCefiInput(): Double;               begin          result:=_cefi_input;      end;
function TMovement.getCefiOutput(): Double;              begin          result:=_cefi_output;      end;
function TMovement.getComisionBuy(): double;             begin          result:=_comision_buy;     end;
function TMovement.getComisionShell(): double;           begin          result:=_comision_Shell;   end;
function TMovement.getInputFee(): double;                begin          result := _input_fee;      end;
function TMovement.getOutputFee(): double;               begin          result := _output_fee;      end;
function TMovement.getInputCryptos(): double;            begin          result := _InputCryptos;end;
function TMovement.getOutputCryptos(): double;           begin          result := _OutputCryptos;end;
function TMovement.getCotnableValueOutput(): double;     begin          result := _contable_value_output;  end;
function TMovement.getCotnableValueInput(): double;      begin          result := _contable_value_input;   end;

procedure TMovement.export(F : TStringList);
var
  str : String;
begin
     str := inttostr(_id) + '^';
     str := str + inttostr(getTypeInt()) + '^';
     str := str + dateToSql(_datetime) + '^';
     str := str + _concept + '^';
     str := str + _wallet_input + '^';
     str := str + _wallet_output + '^';
     str := str + floatToSql(_cefi_input) + '^';
     str := str + floatToSql(_cefi_output) + '^';
     str := str + floatToSql(_comision_buy) + '^';
     str := str + floatToSql(_comision_Shell) + '^';
     str := str + floatToSql(_input_fee) + '^';
     str := str + floatToSql(_output_fee) + '^';
     str := str + floatToSql(_inputCryptos) + '^';
     str := str + floatToSql(_outputCryptos) + '^';
     str := str + floatToSql(_contable_value_input) + '^';
     str := str + floatToSql(_contable_value_output) + '^';
     F.add(str);
end;

procedure TMovement.import(line: String);
var
  str : TStringArray;
begin
     str := line.Split('^');
     if length(str) = 16 then
     begin
          _id := strtoint(str[0]);
          setTypeInt(strtoint(str[1]));
          _datetime:=sqlToFloat(str[2]);
          _concept:=str[3];
          _wallet_input:=str[4];
          _wallet_output:=str[5];
          _cefi_input:=sqlToFloat(str[6]);
          _cefi_output:=sqlToFloat(str[7]);
          _comision_buy:=sqlToFloat(str[8]);
          _comision_Shell:=sqlToFloat(str[9]);
          _input_fee:=sqlToFloat(str[10]);
          _output_fee:=sqlToFloat(str[11]);
          _inputCryptos:=sqlToFloat(str[12]);
          _outputCryptos:=sqlToFloat(str[13]);
          _contable_value_input:=sqlToFloat(str[14]);
          _contable_value_output:=sqlToFloat(str[15]);
     end;
end;

function TMovement.getTypeInt(): Integer;
begin
     result := -1;
     case _type of
          MV_BUY:  result := 0;
          MV_TRANSFER: result := 1;
          MV_SHELL : result := 2;
          MV_SWAP: result := 3;
          MV_MINING: result := 4;
          MV_RECEIVE: result := 5;
          MV_SEND: result := 6;
          MV_LOSS: Result:= 7;
     end;
end;

function TMovement.getPriceInputCrypto(): double;
begin
     result := _contable_value_input / _inputCryptos;
end;

function TMovement.getPriceOutputCrypto(): double;
begin
  result := _contable_value_output / _outputCryptos;
end;

procedure TMovement.save();     begin         movementsController.save(self); end;


// *********************************************************************************************************************

constructor TMovementsController.create(_db: TDatabaseConnector);
begin
     db := _db;
end;

function TMovementsController.getNextId(): integer;
var
   Q : TSqlQuery;
begin
     Q := db.getSqlQuery('select max(move_id) from "moves"');
     while not Q.Eof do
     begin
          if Q.Fields[0].AsString = '' then result := 1
          else result := Q.Fields[0].AsInteger +1;
          Q.Next;
     end;
     Q.Close;
     Q.Free;
end;

procedure TMovementsController.remove(id: integer);
var
   sql : String;
begin
     sql := 'delete from "moves" where move_id = ' + inttostr(id);
     db.launchSql(sql);
end;

procedure TMovementsController.clearAll();
var
   sql : String;
begin
     sql := 'delete from "moves"';
     db.launchSql(sql);
end;

procedure TMovementsController.save(mvnt: TMovement);
var
   sql : String;
   Q : TSQLQuery;
   exists : Boolean;
begin

     if mvnt <> nil then
     begin
          Q := db.getSqlQuery('select * from "moves" where move_id = "'+inttostr(mvnt.getId())+'"');
          exists := not Q.Eof;
          if (mvnt.getId() <= 0) or (not exists) then
          begin
            if (mvnt.getId() <= 0) then mvnt.setId(getNextId());
            sql := 'insert into "moves" (move_id, move_type, move_datetime,move_concept,move_wallet_Input,move_wallet_output,';
            sql := sql + 'move_cefi_input,move_cefi_output,move_contable_value_input,move_contable_value_output,move_comision_buy,move_comision_shell,';
            sql := sql + 'move_input_fee,move_output_fee,move_input_cryptos,move_output_cryptos) values (';
            sql := sql + inttostr(mvnt.getId()) + ', ';                         // Move_id
            sql := sql + IntToStr(mvnt.getTypeInt()) +', ';                     // Move Type
            sql := sql + dateToSql(mvnt.getDateTime()) +', ';                   // Move Date Time
            sql := sql + '"' + StringToSql(mvnt.getConcept()) + '",';           // Concept
            sql := sql + '"' + mvnt.getWalletInput() + '",';                    // Wallet input
            sql := sql + '"' + mvnt.getWalletOutput() + '",';                   // Wallet Output
            sql := sql + floatToSql(mvnt.getCefiInput()) + ', ';                // move_cefi_input
            sql := sql + floatToSql(mvnt.getCefiOutput()) + ', ';               // move_cefi_output
            sql := sql + floatToSql(mvnt.getCotnableValueInput()) + ', ';       // move_contable_value_input
            sql := sql + floatToSql(mvnt.getCotnableValueOutput()) + ', ';      // move_contable_value_output
            sql := sql + floatToSql(mvnt.getComisionBuy()) + ', ';              // move_comision_buy
            sql := sql + floatToSql(mvnt.getComisionShell()) + ', ';            // move_comision_shell
            sql := sql + floatToSql(mvnt.getInputFee()) + ', ';                 // move_input_fee
            sql := sql + floatToSql(mvnt.getOutputFee()) + ', ';                // move_output_fee
            sql := sql + floatToSql(mvnt.getInputCryptos()) + ', ';             // move_input_cryptos
            sql := sql + floatToSql(mvnt.getOutputCryptos()) + ');';            // move_output_cryptos
            db.launchSql(sql);
          end
          else
          begin
               sql := 'update "moves" set ';
               sql := sql + 'move_type = ' + IntToStr(mvnt.getTypeInt()) +', ';
               sql := sql + 'move_datetime = ' + dateToSql(mvnt.getDateTime()) + ', ';
               sql := sql + 'move_concept = "' +StringToSql(mvnt.getConcept()) +  '", ';
               sql := sql + 'move_wallet_Input = "' + mvnt.getWalletInput() + '", ';
               sql := sql + 'move_wallet_Output = "' + mvnt.getWalletOutput() +'", ';
               sql := sql + 'move_cefi_input = ' + floatToSql(mvnt.getCefiInput()) +', ';
               sql := sql + 'move_cefi_output = ' + floatToSql(mvnt.getCefiOutput()) +', ';
               sql := sql + 'move_contable_value_input = ' + floatToSql(mvnt.getCotnableValueInput()) +', ';
               sql := sql + 'move_contable_value_output = ' + floatToSql(mvnt.getCotnableValueOutput()) +  ', ';
               sql := sql + 'move_comision_buy = ' + floatToSql(mvnt.getComisionBuy()) + ', ';
               sql := sql + 'move_comision_shell = ' + floatToSql(mvnt.getComisionShell()) + ', ';
               sql := sql + 'move_input_fee = ' + floatToSql(mvnt.getInputFee()) + ', ';
               sql := sql + 'move_output_fee = ' + floatToSql(mvnt.getOutputFee()) + ', ';
               sql := sql + 'move_input_cryptos = ' + floatToSql(mvnt.getInputCryptos()) + ', ';
               sql := sql + 'move_output_cryptos = ' + floatToSql(mvnt.getOutputCryptos()) + ' ';
               sql := sql + ' where move_id = ' + inttostr(mvnt.getId());
               db.launchSql(sql);
          end;
     end;
end;

function TMovementsController.getById(_id: integer): TMovement;
var
   Q : TSQLQuery;
begin
     result := TMovement.create;
     Q := db.getSqlQuery('select * from "moves" where move_id = '+inttostr(_id));
     while not Q.Eof do
     begin
         result.setId(Q.FieldByName('move_id').AsInteger);
         result.setDateTime(Q.FieldByName('move_datetime').AsFloat);
         result.setConcept(Q.FieldByName('move_concept').AsString);
         result.setTypeInt(Q.FieldByName('move_type').AsInteger);
         result.setWalletInput(Q.FieldByName('move_wallet_Input').AsString);
         result.setWalletOutput(Q.FieldByName('move_wallet_Output').AsString);

         result.setCefiInput(Q.FieldByName('move_cefi_input').AsFloat);
         result.setCefiOutput(Q.FieldByName('move_cefi_output').AsFloat);
         result.setContableValueInput(Q.FieldByName('move_contable_value_input').AsFloat);
         result.setContableValueOutput(Q.FieldByName('move_contable_value_output').AsFloat);
         result.setComisionBuy(Q.FieldByName('move_comision_buy').AsFloat);
         result.setComisionShell(Q.FieldByName('move_comision_shell').AsFloat);
         result.setInputFee(Q.FieldByName('move_input_fee').AsFloat);
         result.setOutputFee(Q.FieldByName('move_output_fee').AsFloat);
         result.setInputCryptos(Q.FieldByName('move_input_cryptos').AsFloat);
         result.setOutputCryptos(Q.FieldByName('move_output_cryptos').AsFloat);
         Q.Next;
     end;
     Q.Close;
     Q.Free;
end;


function TMovementsController.getAll(): TMovementList;
var
   Q : TSQLQuery;
begin
     result := TMovementList.create;
     Q := db.getSqlQuery('select move_id from "moves" order by move_datetime');
     while not Q.Eof do
     begin
         result.push(getById(Q.FieldByName('move_id').AsInteger));
         Q.Next;
     end;
     Q.Close;
     Q.Free;
end;

function TMovementsController.getByWallet(w: String): TMovementList;
var
   Q : TSQLQuery;
begin
     result := TMovementList.create;
     Q := db.getSqlQuery('select move_id from "moves" where move_wallet_input = "'+w+'" or move_wallet_output = "'+w+'" order by move_datetime');
     while not Q.Eof do
     begin
         result.push(getById(Q.FieldByName('move_id').AsInteger));
         Q.Next;
     end;
     Q.Close;
     Q.Free;
end;

// *****************************************************************************
// *****************************************************************************
// *****************************************************************************

constructor TMovementList.create();
begin
     _count := 0;
     SetLength(list, 0);
end;

destructor TMovementList.Destroy;
begin
     clear();
     inherited;
end;

function TMovementList.count(): integer;
begin
     result := _count;
end;

procedure TMovementList.push(item: TMovement);
begin
     if item <> nil then
        begin
          _count := _count +1;
          SetLength(list, _count);
          list[count -1] := item;
        end;
end;

procedure TMovementList.clear();
var
    I : Integer;
begin
     for I := 0 to length(list) -1 do
         list[I].free;
     setLength(list, 0);
     _count := 0;
end;

function TMovementList.get(i : integer): TMovement;
begin
     if (i < 0) or (i >= _count) then
     begin
        result := nil;
     end
     else
     begin
        result := list[i];
     end;
end;

end.

