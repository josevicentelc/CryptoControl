unit JVStringGrid;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, Grids;

type
  TJVStringGrid = class(TStringGrid)
  private
         selRow : Integer;
  protected
    procedure DrawCell(aCol,aRow: Integer; aRect: TRect; aState:TGridDrawState); override;
    function SelectCell(aCol, aRow: Integer): boolean; override;
  public
    constructor create(aOwner:TComponent);
    procedure setSelectedRow(arow:Integer);
    function getSelectedRow():Integer;
  published
    property selectedRow: integer read selRow write selRow;

  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('JVLC',[TJVStringGrid]);
end;

constructor TJVStringGrid.create(aOwner:TComponent);
begin
  inherited Create(aOwner);
  selRow:=2;
end;

function TJVStringGrid.SelectCell(aCol, aRow: Integer): boolean;
begin
  selRow:=aRow;
  result := inherited;
end;


procedure TJVStringGrid.DrawCell(aCol,aRow: Integer; aRect: TRect; aState:TGridDrawState);
   var   S: string;
begin
   s := Cells[aCol, aRow];

   if (aCol < FixedCols) or (aRow < FixedRows) then
   begin
     canvas.Pen.color := FixedColor;
     Canvas.Brush.Color:=FixedColor;
   end
   else
   begin
     if (aRow = selRow)  then
     begin
       canvas.Pen.color := selectedColor;
       Canvas.Brush.Color:=selectedColor;
     end
     else
     begin
       canvas.Pen.color := Color;
       Canvas.Brush.Color:=Color;
     end;
   end;
   Canvas.FillRect(aRect);
   canvas.Pen.color := clBtnFace;
   //Canvas.Rectangle(aRect);
   Canvas.Line(aRect.Left + Width, aRect.Top, aRect.Left + Width, aRect.top + Height);
   Canvas.Line(aRect.Left, aRect.top + Height, aRect.Left + Width, aRect.Top + Height);
   canvas.TextRect(aRect,aRect.Left +2, aRect.Top + 2, S);

end;

procedure TJVStringGrid.setSelectedRow(arow:Integer);
begin
   selRow:=arow;
   Repaint;
end;


function TJVStringGrid.getSelectedRow():Integer;
begin
   result := selRow;
end;

end.

