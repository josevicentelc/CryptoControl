unit MetroButton;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs,types, Buttons;

type
  TMetroColorStatus = (csOut, csIn, csDown);
  TMetroTextAlign = (
    mtaTopLeft,
    mtaTopMiddle,
    mtaTopRight,
    mtaMiddleLeft,
    mtaMiddleMiddle,
    mtaMiddleRight,
    mtaBottomLeft,
    mtaBottomMiddle,
    mtaBottomRight
  );

  TMetroGlyphAlign = (
    mgaTopLeft,
    mgaTopMiddle,
    mgaTopRight,
    mgaMiddleLeft,
    mgaMiddleMiddle,
    mgaMiddleRight,
    mgaBottomLeft,
    mgaBottomMiddle,
    mgaBottomRight
  );

  TMetroButton = class(TSpeedButton)
  private
    FMetroColorStatus : TMetroColorStatus;
    FMetroGlyphAlign : TMetroGlyphAlign;
    FMetroColorNormal : TColor;
    FMetroColorOver : TColor;
    FMetroColorDown : TCOlor;
    FMetroColorDisabled : TCOlor;
    FMetroTextAlign : TMetroTextAlign;
    FSelected : boolean;
    FLeftTextAnchor: integer;

  protected
    procedure paint; override;
    procedure MouseEnter; override;
    procedure MouseLeave; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;

    procedure SetMetroTextAlign(value : TMetroTextAlign);
    procedure SetMetroGlyphAlign(value : TMetroGlyphAlign);
    procedure setSelected(value : boolean);
    procedure setLeftTextAnchor(value : integer);


  public
    Constructor Create(AOwner: TComponent); override;

  published
    property MetroTextAlign: TMetroTextAlign read FMetroTextAlign write SetMetroTextAlign;
    property MetroGlyphAlign: TMetroGlyphAlign read FMetroGlyphAlign write SetMetroGlyphAlign;
    property MetroColorNormal: TColor read FMetroColorNormal write FMetroColorNormal;
    property MetroColorOver: TColor read FMetroColorOver write FMetroColorOver;
    property MetroColorDown: TColor read FMetroColorDown write FMetroColorDown;
    property MetroColorDisabled: TColor read FMetroColorDisabled write FMetroColorDisabled;
    property Selected: boolean read FSelected write setSelected;
    property LeftTextAnchor: integer read FLeftTextAnchor write setLeftTextAnchor;


  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('JVLC',[TMetroButton]);
end;

Constructor TMetroButton.Create(AOwner: TComponent);
Begin
  inherited create(AOwner);
  FMetroTextAlign:=mtaMiddleMiddle;
  FMetroColorNormal:=$00F2DF9D;
  FMetroColorOver:=$00C6F185;
  FMetroColorDown:=$00E7C245;
  FMetroColorDisabled:= clGray;
end;

procedure TMetroButton.SetMetroTextAlign(value : TMetroTextAlign);
begin
  FMetroTextAlign:=value;
  self.paint;
end;

procedure TMetroButton.SetMetroGlyphAlign(value : TMetroGlyphAlign);
begin
  FMetroGlyphAlign:=value;
  self.paint;
end;

procedure TMetroButton.setLeftTextAnchor(value : integer);
begin
  FLeftTextAnchor:=value;
  self.paint;
end;

procedure TMetroButton.setSelected(value : boolean);
begin
  if   FSelected <> value then
  begin
    FSelected:=value;
    self.paint;
  end;
end;

procedure TMetroButton.paint;
var
  TH : integer;
  TW : integer;
  cw2 : integer;
  ch2 : integer;
  X : integer;
  Y : integer;
  PaintRect: TRect;
  Offset: TPoint;
  glyphRect : TRect;
  GlyphSize: TSize;
  GlyphWidth, GlyptHeight : integer;

begin
  if canvas <> nil then
  begin
    //canvas.pen.color := self.Font.Color;

    if not Enabled then                        canvas.brush.color := FMetroColorDisabled
    else if FSelected then                          canvas.brush.color := FMetroColorDown
    else if FMetroColorStatus = csOut  then    canvas.brush.color := FMetroColorNormal
    else if FMetroColorStatus = csDown then    canvas.brush.color := FMetroColorDown
    else if FMetroColorStatus = csIn   then    canvas.brush.color := FMetroColorOver
    else canvas.brush.color := FMetroColorNormal;

    canvas.pen.color := canvas.brush.color;
    canvas.FillRect(0, 0, width, height);

    canvas.font := Font;
    TW := canvas.TextWidth(self.Caption);
    TH := canvas.TextHeight(self.caption);
    cw2 := Width div 2;
    ch2 := Height div 2;

    case FMetroTextAlign of
        mtaTopLeft:
        begin
          X := 5;
          Y := 5;
        end;
        mtaTopMiddle:
        begin
          X := cw2 - (TW div 2);
          Y := 5;
        end;
        mtaTopRight:
        begin
          X := self.Width - 5 - TW;
          Y := 5;
        end;
        mtaMiddleLeft:
        begin
          X := 5;
          Y := ch2 - (TH div 2);
        end;
        mtaMiddleMiddle:
        begin
          X := cw2 - (TW div 2);
          Y := ch2 - (TH div 2);
        end;
        mtaMiddleRight:
        begin
          X := self.Width - 5 - TW;
          Y := ch2 - (TH div 2);
        end;
        mtaBottomLeft:
        begin
          X := 5;
          Y := self.Height - 5 - TH;
        end;
        mtaBottomMiddle:
        begin
          X := cw2 - (TW div 2);
          Y := self.Height - 5 - TH;
        end;
        mtaBottomRight:
        begin
          X := self.Width - 5 - TW;
          Y := self.Height - 5 - TH;
        end;
    else
    end;
    if FLeftTextAnchor >= 1 then X := FLeftTextAnchor;

    canvas.TextOut(X, Y, caption);
    paintRect.Top := 0;
    paintRect.Left:= 0;
    paintRect.Right:= width;
    paintRect.Bottom:= height;
    offset.x := 0;
    offset.y := 0;

    GlyphSize := GetGlyphSize(true,GlyphRect);
    GlyphWidth := GlyphSize.CX;
    GlyptHeight := GlyphSize.CY;

    case FMetroGlyphAlign of
        mgaTopLeft:
        begin
        end;
        mgaTopMiddle:
        begin
         offset.x := cw2 - GlyphWidth div 2;
        end;
        mgaTopRight:
        begin
         offset.x := Width - GlyphWidth;
        end;
        mgaMiddleLeft:
        begin
         offSet.y := ch2 - GlyptHeight div 2;
        end;
        mgaMiddleMiddle:
        begin
         offset.x := cw2 - GlyphWidth div 2;
         offSet.y := ch2 - GlyptHeight div 2;
        end;
        mgaMiddleRight:
        begin
         offset.x := Width - GlyphWidth;
         offSet.y := ch2 - GlyptHeight div 2;
        end;
        mgaBottomLeft:
        begin
         offSet.y := Height - GlyptHeight;
        end;
        mgaBottomMiddle:
        begin
         offset.x := cw2 - GlyphWidth div 2;
         offSet.y := Height - GlyptHeight;
        end;
        mgaBottomRight:
        begin
         offset.x := Width - GlyphWidth;
         offSet.y := Height - GlyptHeight;
        end;
    else
    end;

    DrawGlyph(canvas, PaintRect, Offset, FState, true, 0);

  end;
end;

procedure TMetroButton.MouseEnter;
begin
     inherited MouseEnter;
     FMetroColorStatus := csIn;
end;

procedure TMetroButton.MouseLeave;
begin
     inherited MouseLeave;
     FMetroColorStatus := csOut;
end;

procedure TMetroButton.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseDown(button, shift, X, Y);
  FMetroColorStatus := csDown;
end;

procedure TMetroButton.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseUp(Button, shift, X, Y);
  FMetroColorStatus := csIn;
end;


end.

