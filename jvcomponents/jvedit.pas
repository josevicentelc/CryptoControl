unit JVEdit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls;

type
  TJVEdit = class(TEdit)
  private
    FIsPassword: boolean;
    FPlaceHolder: String;
    FNextDialogWhenIntro : Boolean;
    FPlaceHolderFontColor: TColor;
    FFontColor: TColor;
    FOwner : TComponent;
    FIsNumericValue: boolean;


    FShapeRelated: TShape;
    FShapePenFocusColor: TColor;
    FShapeBrushFocusColor: TColor;
    FShapePenUnfocusColor: TColor;
    FShapeBrushUnfocusColor: TColor;

  protected
    procedure SetIsPassword(value: boolean);
    procedure SetIsNumericValue(value: boolean);
    procedure SetPlaceHolder(value: string);
    procedure SetPlaceHolderFontColor(value: TColor);
    procedure SetFontColor(value: TColor);
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;

  public
    constructor create(AOwner: TComponent); override;
    Destructor Destroy; Override;
    procedure checkPlaceHolder;
    procedure checkNumericValue;
    procedure check;
    function GetFloatValue(): double;
    function GetValue(): String;

  published
    property isPassword: Boolean read FIsPassword write SetIsPassword default false;
    property isNumeric: Boolean read FIsNumericValue write SetIsNumericValue default false;
    property PlaceHolder: String read FPlaceHolder write SetPlaceHolder;
    property PlaceHolderFontColor: TColor read FPlaceHolderFontColor write SetPlaceHolderFontColor;
    property FontColor: TColor read FFontColor write SetFontColor;
    property NextDialogWhenIntro: Boolean read FNextDialogWhenIntro write FNextDialogWhenIntro default true;


    property ShapeRelated: TShape read FShapeRelated write FShapeRelated;
    property ShapePenFocusColor: TColor read FShapePenFocusColor write FShapePenFocusColor;
    property ShapeBrushFocusColor: TColor read FShapeBrushFocusColor write FShapeBrushFocusColor;
    property ShapePenUnfocusColor: TColor read FShapePenUnfocusColor write FShapePenUnfocusColor;
    property ShapeBrushUnfocusColor: TColor read FShapeBrushUnfocusColor write FShapeBrushUnfocusColor;


  end;

procedure Register;

implementation

//******************************************************************************
procedure Register;
begin
  RegisterComponents('JVLC',[TJVEdit]);
end;

//******************************************************************************
Constructor TJVEdit.Create(AOwner: TComponent);
Begin
  inherited create(AOwner);
  FNextDialogWhenIntro:=true;
  FIsPassword:=false;
  FPlaceHolder:='';
  FPlaceHolderFontColor:=$00000000;
  FFontColor:=$00FFFFFF;
  FOwner := AOwner;
  FIsNumericValue:=false;

  FShapeRelated := nil;
  FShapePenFocusColor := $004CB122;
  FShapeBrushFocusColor := $004CB122;
  FShapePenUnfocusColor := $007A88E7;
  FShapeBrushUnfocusColor := $007A88E7;

  check;

end;

//******************************************************************************
Destructor TJVEdit.Destroy;
begin
  Inherited destroy;
end;

//******************************************************************************
procedure TJVEdit.SetIsPassword(value: boolean);
begin
  FIsPassword:=value;
  check;
end;

//******************************************************************************
procedure TJVEdit.SetIsNumericValue(value: boolean);
begin
  FIsNumericValue:=value;
  check;
end;

//******************************************************************************
procedure TJVEdit.SetPlaceHolder(value: string);
begin
  FPlaceHolder:=value;
  check;
end;

//******************************************************************************
procedure TJVEdit.SetFontColor(value: TColor);
begin
  FFontColor:=value;
  check;
end;

//******************************************************************************
procedure TJVEdit.SetPlaceHolderFontColor(value: TColor);
begin
  FPlaceHolderFontColor:=value;
  check;
end;

//******************************************************************************
Procedure TJVEdit.DoEnter;
begin
  if (trim(FPlaceHolder) <> '') and (LowerCase(self.text) = lowerCase(FPlaceHolder)) then
  begin
       self.text := '';
  end;
  if FIsPassword then self.PasswordChar:=char(42);
  self.font.color := FFontColor;

  if FShapeRelated <> nil then
  begin
    FShapeRelated.Pen.color := FShapePenFocusColor;
    FShapeRelated.Brush.color := FShapeBrushFocusColor;
  end;

  Inherited DoEnter;
end;
//******************************************************************************
procedure TJVEdit.check;
begin
     checkNumericValue;
     checkPlaceHolder;
end;

//******************************************************************************
procedure TJVEdit.checkNumericValue;
var
  N : double;
  T : String;
begin
     if FIsNumericValue then
     begin
          if (trim(self.text) <> '') and ((lowerCase(FPlaceHolder) <> LowerCase(self.text))) then
          begin
            T := stringReplace(self.text, '.', ',', [rfReplaceAll]);
            try
               N := StrToFloat(T);
               self.text := formatFloat('##0.00', N);
            except
              self.Text := '';
            end;
          end;
     end;
end;

//******************************************************************************
procedure TJVEdit.checkPlaceHolder;
var
  t : String;
begin
  t := self.Text;
  if (trim(FPlaceHolder) <> '') and ((trim(t) = '') or (lowerCase(FPlaceHolder) = LowerCase(t))) then
  begin
    self.Font.color:=FPlaceHolderFontColor;
    self.text := FPlaceHolder;
    if FIsPassword then self.PasswordChar:=#0;
  end
  else
  begin
    if FIsPassword then  self.PasswordChar:=char(42);
  end;
end;

//******************************************************************************
procedure TJVEdit.DoExit;
begin
  self.check;
  if FShapeRelated <> nil then
  begin
    FShapeRelated.Pen.color := FShapePenUnfocusColor;
    FShapeRelated.Brush.color := FShapeBrushUnfocusColor;
  end;
  Inherited DoExit;
end;
//******************************************************************************
procedure TJVEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
   inherited KeyDown(Key, Shift);
end;

function TJVEdit.GetFloatValue: double;
var
  T : String;
begin
  result := 0;
  if (trim(self.text) <> '') and ((lowerCase(FPlaceHolder) <> LowerCase(self.text))) then
  begin
      T := stringReplace(self.text, '.', ',', [rfReplaceAll]);
      try
       result:= StrToFloat(T);
      except
       result := 0;
      end;
  end;
end;

function TJVedit.GetValue(): String;
begin
  if (trim(self.text) = '') or (trim(lowercase(self.text)) = trim(lowercase(FPlaceHolder))) then
     result := ''
  else
      result := self.text;
end;

end.

