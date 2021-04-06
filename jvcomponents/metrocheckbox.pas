unit MetroCheckbox;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, Buttons;

type
  TMetroCheckbox = class(TSpeedButton)
  private
    FChecked : boolean;
    FColorOn : Tcolor;
    FColorOff : TColor;
    FColorSwichOn : TColor;
    FColorSwichOff : TColor;
    FFontColorFromSwich : boolean;
    FMargin : integer;
    FTextOn : String;
    FTextOff : String;
  protected
    procedure setChecked(value : boolean);
    procedure setColorOn(value : Tcolor);
    procedure setColorOff(value : Tcolor);
    procedure setColorSwichOn(value : Tcolor);
    procedure setColorSwichOff(value : Tcolor);
    procedure setMargin(value : integer);
    procedure setTextOn(value : string);
    procedure setTextOff(value : string);
    procedure setFontColorFromSwich(value : boolean);
    procedure paint; override;
  public
    constructor create(_owner : TComponent); override;
    procedure click; override;

  published
    property checked : boolean read FChecked write setChecked;
    property ColorOn: TColor read FColorOn write setColorOn;
    property ColorOff: TColor read FColorOff write setColorOff;
    property ColorSwichOn: TColor read FColorSwichOn write setColorSwichOn;
    property ColorSwichOff: TColor read FColorSwichOff write setColorSwichOff;
    property TextOn: String read FTextOn write setTextOn;
    property TextOff: String read FTextOff write setTextOff;
    property FontColorFromSich: boolean read FFontColorFromSwich write setFontColorFromSwich;
    property Margin : Integer read fMargin write setMargin;

  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('JVLC',[TMetroCheckbox]);
end;

constructor TMetroCheckbox.create(_owner : Tcomponent);
begin
  inherited create(_owner);
  fchecked := false;
  FColorOn := $00394901;
  FColorOff := $00182885;
  FColorSwichOn:=$007EA303;
  FColorSwichOff:=$007EA303;
  FMargin:=6;
  FTextOn := 'ON';
  FTextOff := 'OFF';
  FFontColorFromSwich:=true;
  self.font.Size:=10;
  self.width := 50;
  self.height := 25;
end;

procedure TMetroCheckbox.setChecked(value : boolean);
begin
  FChecked := value;
  self.paint;
end;

procedure TMetroCheckbox.setFontColorFromSwich(value:boolean);
begin
  FFontColorFromSwich:=value;
  self.paint;
end;

procedure TMetroCheckbox.setMargin(value : integer);
begin
  if value >= 0 then
  begin
    FMargin:=value;
    self.paint;
  end;
end;

procedure TMetroCheckbox.setColorOn(value : TColor);
begin
  FColorOn := value;
  self.paint;
end;

procedure TMetroCheckbox.setColorOff(value : TColor);
begin
  FColorOff := value;
  self.paint;
end;

procedure TMetroCheckbox.setColorSwichOn(value : TColor);
begin
  FColorSwichOn := value;
  self.paint;
end;
procedure TMetroCheckbox.setColorSwichOff(value : TColor);
begin
  FColorSwichOff := value;
  self.paint;
end;

procedure TMetroCheckbox.setTextOn(value:string);
begin
  FTextOn:=value;
  self.paint;
end;

procedure TMetroCheckbox.setTextOff(value:string);
begin
  FTextOff:=value;
  self.paint;
end;

procedure TMetroCheckbox.click;
begin
  if not self.Enabled then exit;
  fChecked := not fChecked;
  inherited click;
  paint;
end;

procedure TMetroCheckbox.paint;
var
  w4 : integer;
  maxMargin : integer;
  curmargin : integer;
  X, Y: integer;
  TW, TH: integer;
begin
  if self.canvas <> nil then
  begin
    canvas.Clear;
    canvas.Brush.color := self.Color;
    canvas.FillRect(0, 0, self.Width, self.Height);

    if not self.Enabled then
    begin
      canvas.pen.color := $AAAAAA;
      canvas.brush.color := $AAAAAA;
    end
    else
    begin
      if fchecked then
      begin
        canvas.pen.color := FColorOn;
        canvas.brush.color := FColorOn;
      end
      else
      begin
        canvas.pen.color := FColorOff;
        canvas.brush.color := FColorOff;
      end;
    end;

    w4 := self.Width div 4;
    canvas.Ellipse(0, 0, w4 * 2, self.Height);
    canvas.Ellipse(w4 * 2, 0, self.Width, self.Height);
    canvas.FillRect(w4, 0, w4 * 3, self.Height);

    if self.Height < self.Width then maxMargin:= (self.Height div 2) -1
    else maxMargin:= (self.width div 2) -1;


    if FMargin > maxMargin then curmargin:=maxMargin
    else curmargin := fMargin;

    if FChecked then
    begin
      // Swich derecha, ON

      if not self.enabled then
      begin
        canvas.pen.color := $555555;
        canvas.brush.color := $555555;
      end
      else
      begin
        canvas.pen.color := FColorSwichOn;
        canvas.brush.color := FColorSwichOn;
      end;

      canvas.Ellipse(w4 * 2 + curmargin, curmargin, self.Width - curmargin, self.Height - curmargin);
      if FTextOn <> '' then
      begin
            canvas.font := self.Font;
            if FFontColorFromSwich then canvas.Font.Color:=FColorSwichOn;
            if not self.enabled then canvas.font.color := $555555;

            canvas.Brush.color := FColorOn;
            if not self.enabled then canvas.brush.color := $AAAAAA;

            TW := canvas.TextWidth(FTextOn);
            TH := canvas.TextHeight(FTextOn);
            X := w4 - (TW div 2);
            Y := (self.Height div 2) - (TH div 2);
            canvas.TextOut(X, Y, FTextOn);
      end;
    end
    else
    begin
      // Swich izquierda, OFF
      if not self.enabled then
      begin
        canvas.pen.color := $555555;
        canvas.brush.color := $555555;
      end
      else
      begin
        canvas.pen.color := FColorSwichOff;
        canvas.brush.color := FColorSwichOff;
      end;

      canvas.Ellipse(curmargin, curmargin, w4 * 2 - curmargin, self.Height - curmargin);
      if FTextOff <> '' then
      begin
            canvas.font := self.Font;

            if FFontColorFromSwich then canvas.Font.Color:=FColorSwichOff;
            if not self.enabled then canvas.font.color := $555555;

            canvas.Brush.color := FColorOff;
            if not self.enabled then canvas.brush.color := $AAAAAA;

            TW := canvas.TextWidth(FTextOff);
            TH := canvas.TextHeight(FTextOff);
            X := (w4 * 3) - (TW div 2);
            Y := (self.Height div 2) - (TH div 2);
            canvas.TextOut(X, Y, FTextOff);
      end;
    end;

  end;
end;

end.

