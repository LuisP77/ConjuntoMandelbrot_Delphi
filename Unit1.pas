unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls;

type
  TForm1 = class(TForm)
    Image1: TImage;
    procedure FormCreate(Sender: TObject);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  NPixelX, NPixelY, xo, yo, xc, yc : integer;
  DXmax,DXmin,DYmax,DYmin : double;
  botónPresionado : boolean;
const
  maxIteraciones = 1000;
implementation

{$R *.dfm}

////////////////////////////////////////////////////////////////////////////////
procedure CONVERGENCIA(xo,yo:double; var converge: boolean; var N:integer);
var
  x,y,xaux : double;
begin
  N := 0;
  x := 0;
  y := 0;
  while (x*x + y*y < 4) and (N < maxIteraciones) do begin
    xaux := x*x - y*y + xo;
    y := 2*x*y + yo;
    x := xaux;
    N := N + 1;
  end;
  if N<maxIteraciones then
    converge := false
  else
    converge := true;
end;
////////////////////////////////////////////////////////////////////////////////
function color(iteraciones:integer):byte;
const
  factor = 35;
begin
  if factor*iteraciones > maxIteraciones then
    iteraciones := maxIteraciones;
  result := trunc(255*(factor*iteraciones-maxIteraciones)/maxIteraciones);
end;
////////////////////////////////////////////////////////////////////////////////
procedure ConjuntoMandelbrot(NpixelX,NpixelY:integer; image : TImage);
var
  x,y : double;
  pixelX,pixelY, iteraciones : integer;
  converge : boolean;
begin
  for pixelX := 0 to NpixelX do
    for pixelY := 0 to NPixelY do begin
      x := (DXmax-DXmin)/NpixelX* pixelX + DXmin;
      y := -(DYmax-DYmin)/NpixelY* pixelY + DYmax;
      CONVERGENCIA(x,y,converge,iteraciones);
      if  converge then
         image.Canvas.Pixels[pixelX,pixelY] := clBlack
      else
         image.Canvas.Pixels[pixelX,pixelY] := rgb(0,0,color(iteraciones));
    end;
end;
////////////////////////////////////////////////////////////////////////////////
procedure InicializaDimensiones();
begin
  DXmin := -2.20; DXmax := 0.80;
  DYmin := -1.5; DYmax := 1.5;
end;
////////////////////////////////////////////////////////////////////////////////
procedure TForm1.FormCreate(Sender: TObject);
begin
  NPixelX := Image1.Width;
  NPixelY := Image1.Height;
  InicializaDimensiones();
  ConjuntoMandelbrot(NPixelX,NPixelY,Image1);
  botónPresionado := false;
end;
////////////////////////////////////////////////////////////////////////////////
procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then begin
    botónPresionado := true;
    xo := X;
    yo := Y;
  end;
end;
////////////////////////////////////////////////////////////////////////////////
procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if botónPresionado then begin
    Image1.Canvas.DrawFocusRect(rect(xo,yo,xc,yc));
    Image1.Canvas.DrawFocusRect(rect(xo,yo,X,Y));
  end;
  xc:=x;
  yc:=y;
end;
////////////////////////////////////////////////////////////////////////////////
procedure TForm1.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  m, a : double;
begin

  botónPresionado := false;

  if (Button = mbRight)or(Button = mbMiddle) then
    InicializaDimensiones();

  if (Button = mbLeft)and(X>xo)and(Y>yo) then begin

      m := (DXmax-DXmin)/NpixelX; a := DXmin;
      DXmin := m * xo + a;
      DXmax := m * X + a;

      m := -(DYmax-DYmin)/NpixelY; a := DYmax;
      DYmin := m * Y + a;
      DYmax := m * yo + a;

  end;

  ConjuntoMandelbrot(NPixelX,NPixelY,Image1);

end;

end.
