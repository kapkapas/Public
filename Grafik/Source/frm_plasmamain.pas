unit Frm_PlasmaMain;

{$IFDEF FPC}
{$mode delphi}{$H+}
{$ENDIF}

interface

uses
  Classes, SysUtils, {$IFDEF FPC} FileUtil,  {$ENDIF}Forms, Controls,
  Graphics, Dialogs, ExtCtrls,
  Buttons, StdCtrls;

type
  TFloatPoint = record
    x, y: double;
  end;

  TGradient = array of array of TFloatPoint;
  TNoiseFktn = function(x, y: single; const Gradient: TGradient): single;
  { TForm1 }

  TForm1 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    IdleTimer1: TIdleTimer;
    PaintBox1: TPaintBox;
    Timer1: TTimer;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { private declarations }
    Fw: double;
    FGradient: TGradient;
    FBitmap: TBitmap;
    FNoiseFkt: TNoiseFktn;
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}


function iff(s: boolean; tv, fv: integer): integer; overload;
begin
  if s then
    Result := tv
  else
    Result := fv;
end;

function iff(s: boolean; tv, fv: double): double; overload;
begin
  if s then
    Result := tv
  else
    Result := fv;
end;

// Function to linearly interpolate between a0 and a1
// Weight w should be in the range [0.0, 1.0]
function lerp(a0, a1, w: single): single;
begin
  Result := (1.0 - w) * a0 + w * a1;
end;

// Computes the dot product of the distance and gradient vectors.
function dotGridGradient(ix, iy: integer; x, y: double;
  const Gradient: TGradient): double;
var
  dx: double;
  dy: double;
begin

  // Precomputed (or otherwise) gradient vectors at each grid point X,Y
  //  extern float Gradient[Y][X][2];

  // Compute the distance vector
  dx := x - ix;
  dy := y - iy;

  // Compute the dot-product
  Result := (dx * Gradient[iy + 1, ix + 1].x + dy * Gradient[iy + 1, ix + 1].y);
end;

// Computes the dot product of the distance and gradient vectors.
function dotGridGradient2(ix, iy: integer; dx, dy: double;
  const Gradient: TGradient): double;
begin
  // Precomputed (or otherwise) gradient vectors at each grid point X,Y
  //  extern float Gradient[Y][X][2];

  // Compute the dot-product
  Result := (dx * Gradient[iy + 1, ix + 1].x + dy * Gradient[iy + 1, ix + 1].y);
end;
// Compute Perlin noise at coordinates x, y
function perlin(x, y: single; const Gradient: TGradient): single;
var
  x0: integer;
  x1: integer;
  y0: integer;
  y1: integer;
  sx: extended;
  sy: extended;
  n0, n1, ix0, ix1: extended;
begin

  // Determine grid cell coordinates
  x0 := iff(x > 0.0, trunc(x), trunc(x) - 1);
  x1 := x0 + 1;
  y0 := iff(y > 0.0, trunc(y), trunc(y) - 1);
  y1 := y0 + 1;

  // Determine interpolation weights
  // Could also use higher order polynomial/s-curve here

  sx := 0.5 - cos((x - x0) * pi) * 0.5;
  sy := 0.5 - cos((y - y0) * pi) * 0.5;


  // Interpolate between grid point gradients

  n0 := dotGridGradient(x0, y0, x, y, gradient);
  n1 := dotGridGradient(x1, y0, x, y, gradient);
  ix0 := lerp(n0, n1, sx);
  n0 := dotGridGradient(x0, y1, x, y, gradient);
  n1 := dotGridGradient(x1, y1, x, y, gradient);
  ix1 := lerp(n0, n1, sx);
  Result := lerp(ix0, ix1, sy);

end;

// Compute xGrad noise at coordinates x, y
function xGrad(x, y: single; const Gradient: TGradient): single;
var
  x0: integer;
  x1: integer;
  y0: integer;
  y1: integer;
  sx: extended;
  sy: extended;
  n0, n1, ix0, ix1: extended;
begin

  // Determine grid cell coordinates
  y0 := iff(y > 0.0, trunc(y), trunc(y) - 1);
  y1 := y0 + 1;
  //    if y1 mod 2 = 0 then
  x0 := iff(x > 0.0, trunc(x), trunc(x) - 1);
  //    else
  //      x0 := iff(x > 0.0 , trunc(x+0.5) , trunc(x+0.5) - 1);
  x1 := x0 + 1;

  // Determine interpolation weights
  // Could also use higher order polynomial/s-curve here
  sx := 0.5 - cos((x - x0) * pi) * 0.5;
  sy := 0.5 - cos((y - y0) * pi) * 0.5;

  // Interpolate between grid point gradients

  n0 := Gradient[x0 + 1, y0 + 1].x;
  n1 := Gradient[x1 + 1, y0 + 1].x;
  ix0 := lerp(n0, n1, sx);
  n0 := Gradient[x0 + 1, y1 + 1].x;
  n1 := Gradient[x1 + 1, y1 + 1].x;
  ix1 := lerp(n0, n1, sx);
  Result := lerp(ix0, ix1, sy);

end;

// Compute yGrad noise at coordinates x, y
function yGrad(x, y: single; const Gradient: TGradient): single;
var
  x0: integer;
  x1: integer;
  y0: integer;
  y1: integer;
  sx: extended;
  sy: extended;
  n0, n1, ix0, ix1: extended;
begin

  // Determine grid cell coordinates
  x0 := iff(x > 0.0, trunc(x), trunc(x) - 1);
  x1 := x0 + 1;
  y0 := iff(y > 0.0, trunc(y), trunc(y) - 1);
  y1 := y0 + 1;

  // Determine interpolation weights
  // Could also use higher order polynomial/s-curve here
  sx := 0.5 - cos((x - x0) * pi) * 0.5;
  sy := 0.5 - cos((y - y0) * pi) * 0.5;

  // Interpolate between grid point gradients

  n0 := Gradient[x0 + 1, y0 + 1].y;
  n1 := Gradient[x1 + 1, y0 + 1].y;
  ix0 := lerp(n0, n1, sx);
  n0 := Gradient[x0 + 1, y1 + 1].y;
  n1 := Gradient[x1 + 1, y1 + 1].y;
  ix1 := lerp(n0, n1, sx);
  Result := lerp(ix0, ix1, sy);

end;

function HexGrad0(x, y: single; const Gradient: TGradient): single;
var
  x0: integer;
  x1: integer;
  y0: integer;
  y1: integer;
  sx: extended;
  sy: extended;
  n0, n1, ix0, ix1: extended;
  xx: extended;
  yy: extended;
begin
  xx := x - int(x / 2) * 2;
  if xx >= 1 then
    yy := y + (2 - xx) * 0.5
  else
    yy := y + xx * 0.5;

  // Determine grid cell coordinates
  x0 := iff(x > 0.0, trunc(x) mod 30, trunc(x) + 30);
  x1 := x0 + 1;
  y0 := iff(yy > 0.0, trunc(yy) mod 30, trunc(yy) - 1);
  y1 := y0 + 1;

  // Determine interpolation weights
  // Could also use higher order polynomial/s-curve here
  sx := 0.5 - cos((x - x0) * pi) * 0.5;
  sy := 0.5 - cos((yy - y0) * pi) * 0.5;
  // if sx>sy then
  // Interpolate between grid point gradients

  n0 := Gradient[x0 + 1, y0 + 1].y;
  n1 := Gradient[x1 + 1, y0 + 1].y;
  ix0 := lerp(n0, n1, sx);
  n0 := Gradient[x0 + 1, y1 + 1].y;
  n1 := Gradient[x1 + 1, y1 + 1].y;
  ix1 := lerp(n0, n1, sx);
  Result := lerp(ix0, ix1, sy);

end;

// Compute HexGrad noise at coordinates x, y
function HexGrad(x, y: single; const Gradient: TGradient): single;
var
  x0: integer;
  x1: integer;
  y0: integer;
  y1: integer;
  sx: extended;
  sy: extended;
  n0, n1, ix0, n2: extended;
  xx: extended;
  yy: extended;
  f0: ValReal;
  f1: ValReal;
  f2: ValReal;
begin
  xx := x - int(x / 2) * 2;
  if xx >= 1 then
    yy := y + (2 - xx) * 0.5
  else
    yy := y + xx * 0.5;

  // Determine grid cell coordinates
  x0 := iff(x > 0.0, trunc(x) mod 30, trunc(x) + 30);
  x1 := x0 + 1;
  y0 := iff(yy > 0.0, trunc(yy) mod 30, trunc(yy) - 1);
  y1 := y0 + 1;

  // Determine interpolation weights
  // Could also use higher order polynomial/s-curve here
  //    sx := 0.5-cos((x - x0)*pi)*0.5;
  //    sy := 0.5-cos((yy - y0)*pi)*0.5;
  sx := (x - x0);
  sy := (yy - y0);
  // if sx>sy then
  // Interpolate between grid point gradients

  if ((sx > sy) and (xx < 1)) or ((sx + sy < 1) and (xx >= 1)) then
  begin
    if xx < 1 then
    begin
      n0 := Gradient[x1 + 1, y0 + 1].y;
      n1 := Gradient[x1 + 1, y1 + 1].y;
      n2 := Gradient[x0 + 1, y0 + 1].y;
      f0 := sqrt(sqr(x - x1) + sqr(y - y0 + 0.5) * 1.2);
      f1 := sqrt(sqr(x - x1) + sqr(y - y1 + 0.5) * 1.2);
      f2 := sqrt(sqr(x - x0) + sqr(y - y0) * 1.2);
    end
    else
    begin
      n0 := Gradient[x0 + 1, y0 + 1].y;
      n1 := Gradient[x0 + 1, y1 + 1].y;
      n2 := Gradient[x1 + 1, y0 + 1].y;
      f0 := sqrt(sqr(x - x0) + sqr(y - y0 + 0.5) * 1.2);
      f1 := sqrt(sqr(x - x0) + sqr(y - y1 + 0.5) * 1.2);
      f2 := sqrt(sqr(x - x1) + sqr(y - y0) * 1.2);
    end;

  end
  else
  begin
    if xx >= 1 then
    begin
      n0 := Gradient[x1 + 1, y0 + 1].y;
      n1 := Gradient[x1 + 1, y1 + 1].y;
      n2 := Gradient[x0 + 1, y1 + 1].y;
      f0 := sqrt(sqr(x - x1) + sqr(y - y0) * 1.2);
      f1 := sqrt(sqr(x - x1) + sqr(y - y1) * 1.2);
      f2 := sqrt(sqr(x - x0) + sqr(y - y1 + 0.5) * 1.2);
    end
    else
    begin
      n0 := Gradient[x0 + 1, y0 + 1].y;
      n1 := Gradient[x0 + 1, y1 + 1].y;
      n2 := Gradient[x1 + 1, y1 + 1].y;
      f0 := sqrt(sqr(x - x0) + sqr(y - y0) * 1.2);
      f1 := sqrt(sqr(x - x0) + sqr(y - y1) * 1.2);
      f2 := sqrt(sqr(x - x1) + sqr(y - y0 - 0.5) * 1.2);
    end;
  end;
  if f0 > 1.0 then
    f0 := 1.0;
  if f1 > 1.0 then
    f1 := 1.0;
  if f2 > 1.0 then
    f2 := 1.0;
  f0 := cos((f0) * pi) * 0.5 + 0.5;
  f1 := cos((f1) * pi) * 0.5 + 0.5;
  f2 := cos((f2) * pi) * 0.5 + 0.5;
  Result := (n0 * (f0) + n1 * (f1) + n2 * (f2)) / (f0 + f1 + f2);
end;

// Compute HexGrad noise at coordinates x, y
function HexGrad2(x, y: single; const Gradient: TGradient): single;
var
  x0: integer;
  x1: integer;
  y0: integer;
  y1: integer;
  sx: extended;
  sy: extended;
  n0, n1, ix0, n2: extended;
  xx: extended;
  yy: extended;
  f0: ValReal;
  f1: ValReal;
  f2: ValReal;
begin
  xx := x - int(x / 2) * 2;
  if xx >= 1 then
    yy := y + (2 - xx) * 0.5
  else
    yy := y + xx * 0.5;

  // Determine grid cell coordinates
  x0 := iff(x > 0.0, trunc(x) mod 30, trunc(x) + 30);
  x1 := x0 + 1;
  y0 := iff(yy > 0.0, trunc(yy) mod 30, trunc(yy) - 1);
  y1 := y0 + 1;

  // Determine interpolation weights
  // Could also use higher order polynomial/s-curve here
  //    sx := 0.5-cos((x - x0)*pi)*0.5;
  //    sy := 0.5-cos((yy - y0)*pi)*0.5;
  sx := (x - x0);
  sy := (yy - y0);
  // if sx>sy then
  // Interpolate between grid point gradients

  if ((sx > sy) and (xx < 1)) or ((sx + sy < 1) and (xx >= 1)) then
  begin
    if xx < 1 then
    begin
      n0 := dotGridGradient2(x1, y0, x - x1, y - y0 + 0.5, Gradient);
      n1 := dotGridGradient2(x1, y1, x - x1, y - y1 + 0.5, Gradient);
      n2 := dotGridGradient2(x0, y0, x - x0, y - y0, Gradient);
      f0 := sqrt(sqr(x - x1) + sqr(y - y0 + 0.5) * 1.2);
      f1 := sqrt(sqr(x - x1) + sqr(y - y1 + 0.5) * 1.2);
      f2 := sqrt(sqr(x - x0) + sqr(y - y0) * 1.2);
    end
    else
    begin
      n0 := dotGridGradient2(x0, y0, x - x0, y - y0 + 0.5, Gradient);
      n1 := dotGridGradient2(x0, y1, x - x0, y - y1 + 0.5, Gradient);
      n2 := dotGridGradient2(x1, y0, x - x1, y - y0, Gradient);
      f0 := sqrt(sqr(x - x0) + sqr(y - y0 + 0.5) * 1.2);
      f1 := sqrt(sqr(x - x0) + sqr(y - y1 + 0.5) * 1.2);
      f2 := sqrt(sqr(x - x1) + sqr(y - y0) * 1.2);
    end;

  end
  else
  begin
    if xx >= 1 then
    begin
      n0 := dotGridGradient2(x1, y0, x - x1, y - y0 , Gradient);
      n1 := dotGridGradient2(x1, y1, x - x1, y - y1 , Gradient);
      n2 := dotGridGradient2(x0, y1, x - x0, y - y1+ 0.5, Gradient);
      f0 := sqrt(sqr(x - x1) + sqr(y - y0) * 1.2);
      f1 := sqrt(sqr(x - x1) + sqr(y - y1) * 1.2);
      f2 := sqrt(sqr(x - x0) + sqr(y - y1 + 0.5) * 1.2);
    end
    else
    begin
      n0 := dotGridGradient2(x0, y0, x - x0, y - y0 , Gradient);
      n1 := dotGridGradient2(x0, y1, x - x0, y - y1 , Gradient);
      n2 := dotGridGradient2(x1, y1, x - x1, y - y1+ 0.5, Gradient);
      f0 := sqrt(sqr(x - x0) + sqr(y - y0) * 1.2);
      f1 := sqrt(sqr(x - x0) + sqr(y - y1) * 1.2);
      f2 := sqrt(sqr(x - x1) + sqr(y - y1 + 0.5) * 1.2);
    end;
  end;
  if f0 > 1.0 then
    f0 := 1.0;
  if f1 > 1.0 then
    f1 := 1.0;
  if f2 > 1.0 then
    f2 := 1.0;
  f0 := cos((f0) * pi) * 0.5 + 0.5;
  f1 := cos((f1) * pi) * 0.5 + 0.5;
  f2 := cos((f2) * pi) * 0.5 + 0.5;
  Result := (n0 * (f0) + n1 * (f1) + n2 * (f2)) / (f0 + f1 + f2);
end;


{ TForm1 }

procedure TForm1.PaintBox1Paint(Sender: TObject);
var
  cc, rr, gg: byte;
  ix: integer;
  iy: integer;
  x0: integer;
  y0: integer;
begin
  // Debug
  FGradient[12, 22].x := sin(fw);
  FGradient[12, 22].y := cos(fw);
  FGradient[13, 25].x := cos(fw);
  FGradient[13, 25].y := sin(fw);

  if assigned(FNoiseFkt) then
  begin
    case trunc(fw * 10) mod 4 of
      0:
      begin
        x0 := 0;
        y0 := 0;
      end;
      1:
      begin
        x0 := 1;
        y0 := 0;
      end;
      2:
      begin
        x0 := 1;
        y0 := 1;
      end;
      3:
      begin
        x0 := 0;
        y0 := 1;
      end;
    end;
    for ix := 0 to PaintBox1.Width div 2 do
      for iy := 0 to PaintBox1.Height div 2 do
      begin
        cc := trunc(sin(FNoiseFkt(ix * 0.02 + sin(Fw * 0.001) * 10 +
          10, iy * 0.02 + cos(Fw * 0.001) * 10 + 10, FGradient) *
          15 * pi + Fw * 1) * 63) + 192;
        FBitmap.Canvas.Pixels[ix * 2 + x0, iy * 2 + y0] := RGBToColor(cc, cc, cc);
      end;
  end;
  PaintBox1.canvas.Draw(0, 0, FBitmap);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Fw := fw + 0.1;
  PaintBox1.Invalidate;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  x: integer;
  y: integer;
  ww: extended;
begin
  RandSeed := 0;
  FBitmap := TBitmap.Create;
  FBitmap.Width := PaintBox1.Width;
  FBitmap.Height := PaintBox1.Height;
  setlength(FGradient, 32, 32);
  ww := 0.0;
  FNoiseFkt := perlin;
  for x := 0 to 31 do
    for y := 0 to 31 do
    begin
      //        ww:=x*pi-y*pi;
      //        ww:= random*2*pi;
      //        FGradient[x,y].x := sin(ww);
      //        FGradient[x,y].y := cos(ww);
      FGradient[x, y].x := random * 2 - 1;
      FGradient[x, y].y := random * 2 - 1;
    end;
end;

procedure TForm1.BitBtn1Click(Sender: TObject);
begin
  FNoiseFkt := perlin;
end;

procedure TForm1.BitBtn2Click(Sender: TObject);
begin
  FNoiseFkt := yGrad;
end;

procedure TForm1.BitBtn3Click(Sender: TObject);
begin
  FNoiseFkt := HexGrad;
end;

procedure TForm1.BitBtn4Click(Sender: TObject);
begin
  FNoiseFkt := HexGrad0;
end;

procedure TForm1.BitBtn5Click(Sender: TObject);
begin
  FNoiseFkt := HexGrad2;
end;


end.
