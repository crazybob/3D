program game;

{ my 3d game!!!! }

uses ukeyb, crt, dos, fpackship;

const x1 = 50;
      numpoints = 4;
      pi = 3.14159265;
      mnpoly = 1;
      mxpoly = 24;

type
    tileptr = ^tiletype;
    tiletype = array[0..128*128] of byte;

    pointtype = record
        x, y, z: LongInt;
        end;

    polygon = record
        pt : array[1..4] of pointtype;
        {points 1..4 are points on the polygon, while 5 is the center}
        c : byte;
        {color}
        end;

    screentype = ^screen;
    screen = array[0..64000] of byte;
    shiptype = array[mnpoly..mxpoly] of polygon;

const
      mainship : shiptype =
      (
{back left}
(pt:((x:0;y:7;z:5),(x:20;y:0;z:0),(x:0;y:0;z:-5),(x:0;y:7;z:5));c:0),
{front phaser}
(pt:((x:5;y:0;z:70),(x:-5;y:0;z:70),(x:0;y:-3;z:65),(x:0;y:7;z:5));c:2),
{left phaser panel}
(pt:((x:0;y:-3;z:65),(x:-5;y:0;z:70),(x:0;y:0;z:-5),(x:0;y:7;z:5));c:0),
{right phaser panel}
(pt:((x:5;y:0;z:70),(x:0;y:-3;z:65),(x:0;y:0;z:-5),(x:0;y:7;z:5));c:0),
{center windshield}
(pt:((x:-5;y:0;z:70),(x:5;y:0;z:70),(x:0;y:11;z:30),(x:0;y:7;z:5));c:3),
{left windshield}
(pt:((x:5;y:0;z:70),(x:10;y:0;z:45),(x:0;y:11;z:30),(x:0;y:7;z:5));c:3),
{right windshield}
(pt:((x:-10;y:0;z:45),(x:-5;y:0;z:70),(x:0;y:11;z:30),(x:0;y:7;z:5));c:3),
{right wing front-top}
(pt:((x:5;y:0;z:70),(x:40;y:-10;z:5),(x:10;y:0;z:45),(x:0;y:7;z:5));c:0),
{left wing front-top}
(pt:((x:-5;y:0;z:70),(x:-10;y:0;z:45),(x:-40;y:-10;z:5),(x:0;y:7;z:5));c:0),
{right side-body}
(pt:((x:0;y:11;z:30),(x:10;y:0;z:45),(x:20;y:0;z:0),(x:0;y:7;z:5));c:0),
{left side-body}
(pt:((x:0;y:11;z:30),(x:-20;y:0;z:0),(x:-10;y:0;z:45),(x:0;y:7;z:5));c:0),
{bottom left side-body}
(pt:((x:-20;y:0;z:0),(x:0;y:0;z:-5),(x:-5;y:0;z:70),(x:0;y:7;z:5));c:0),
{bottom right side-body}
(pt:((x:0;y:0;z:-5),(x:20;y:0;z:0),(x:5;y:0;z:70),(x:0;y:7;z:5));c:0),
{back}
(pt:((x:0;y:7;z:5),(x:0;y:0;z:-5),(x:-20;y:0;z:0),(x:0;y:7;z:5));c:0),
{right wing}
(pt:((x:20;y:0;z:0),(x:10;y:0;z:45),(x:40;y:-10;z:5),(x:0;y:7;z:5));c:0),
{left wing}
(pt:((x:-40;y:-10;z:5),(x:-10;y:0;z:45),(x:-20;y:0;z:0),(x:0;y:7;z:5));c:0),
{left back}
(pt:((x:0;y:11;z:30),(x:20;y:0;z:0),(x:0;y:7;z:5),(x:0;y:7;z:5));c:0),
{right back}
(pt:((x:0;y:11;z:30),(x:0;y:7;z:5),(x:-20;y:0;z:0),(x:0;y:7;z:5));c:0),
{left booster}
(pt:((x:-40;y:-10;z:5),(x:-20;y:0;z:0),(x:-25;y:-8;z:10),(x:0;y:7;z:5));c:4),
{left wing bottom 2}
(pt:((x:-5;y:0;z:70),(x:-40;y:-10;z:5),(x:-25;y:-8;z:10),(x:0;y:7;z:5));c:0),
{left wing bottom 3}
(pt:((x:-5;y:0;z:70),(x:-25;y:-8;z:10),(x:-20;y:0;z:0),(x:0;y:7;z:5));c:0),
{right booster}
(pt:((x:40;y:-10;z:5),(x:25;y:-8;z:10),(x:20;y:0;z:0),(x:0;y:7;z:5));c:4),
{right wing bottom 2}
(pt:((x:5;y:0;z:70),(x:25;y:-8;z:10),(x:40;y:-10;z:5),(x:0;y:7;z:5));c:0),
{right wing bottom 3}
(pt:((x:5;y:0;z:70),(x:20;y:0;z:0),(x:25;y:-8;z:10),(x:0;y:7;z:5));c:0)
);

var vir, back : screentype;
    virseg : word;
    tile, window, fire : tileptr;
    xoff, yoff, new1, new2: integer;
    xang, yang, zang: integer;
    lookup : array[-360..360, 1..2] of integer;
    i : integer;
    Scr_Ofs : Array[0..199] of Word;
    ship, ship2 : shiptype;
    viewpt : integer;
    boostlvl : integer;
    shippt : array[mnpoly..mxpoly] of integer;

Procedure Putpixel (X,Y : Integer; Col : Byte; where:word); assembler;
asm
   mov  ax,where
   mov  es,ax
   mov  bx,[y]
   shl  bx,1
   mov  di,word ptr [Scr_Ofs + bx]
   add  di,[x]
   mov  al,[col]
   mov  es:[di],al
end;

procedure getpal(col : Byte; var R,G,B : Byte);
var
   rr,gg,bb : Byte;
begin
   asm
      mov    dx,3c7h
      mov    al,col
      out    dx,al
      add    dx,2
      in     al,dx
      mov    [rr],al
      in     al,dx
      mov    [gg],al
      in     al,dx
      mov    [bb],al
   end;
   r := rr;
   g := gg;
   b := bb;
end;


procedure retrace; assembler; asm
  mov dx,03dah; @l1: in al,dx; test al,8; jnz @l1
  @l2: in al,dx; test al,8; jz @l2; end;

procedure setgraph;
begin
     asm
        mov ax,$13
        int $10
     end;
end;

procedure settext;
begin
     asm
        mov ax,$03
        int $10
     end;
end;

Procedure Pal(ColorNo : Byte; R,G,B : Byte);
Begin
   Port[$3c8] := ColorNo;
   Port[$3c9] := R;
   Port[$3c9] := G;
   Port[$3c9] := B;
End;

procedure swap(var a, b: integer);
var c : integer;
begin
     c := a; a := b; b := c;
end;

Procedure Hline (x1,x2,y:word;col:byte;where:word); assembler;
  { This draws a horizontal line from x1 to x2 on line y in color col }
asm
  mov   ax,where
  mov   es,ax
  mov   ax,y
  mov   di,ax
  shl   ax,8
  shl   di,6
  add   di,ax
  add   di,x1

  mov   al,col
  mov   ah,al
  mov   cx,x2
  sub   cx,x1
  shr   cx,1
  jnc   @start
  stosb
@Start :
  rep   stosw
end;

procedure drawpoly(poly : polygon; clr, texnum : byte);
var iy, ix, mny, mxy, mnx, mxx : integer;
    x1, y1, x2, y2, x3, y3 : longint;
    x1t, y1t, x2t, y2t, x3t, y3t : integer;
    dtexx, dtexy, i, tex1x, tex2x, tex1y, tex2y : integer;
begin
     x1 := poly.pt[1].x;
     y1 := poly.pt[1].y;
     x2 := poly.pt[2].x;
     y2 := poly.pt[2].y;
     x3 := poly.pt[3].x;
     y3 := poly.pt[3].y;

     mny :=-32767;
     mxy := 32766;
     if y1 < mny then mny := y1;
     if y2 < mny then mny := y2;
     if y3 < mny then mny := y3;
     if y1 > mxy then mxy := y1;
     if y2 > mxy then mxy := y2;
     if y3 > mxy then mxy := y3;

     if mny < 0 then mny:=0;
     if mxy > 199 then mxy:=199;
     if mny > 199 then exit;
     if mxy < 0 then exit;

     for iy := mny to mxy do begin
         mnx := 32766;
         mxx := -32767;
         if (y3 >= iy) or (y1 >= iy) then
            if (y3 <= iy) or (y1 <= iy) then begin
               if (y1 - y3) <> 0 then begin ix := round((iy-y3) * (x1-x3) / (y1-y3) + x3);
               if ix < mnx then begin
                  mnx := ix;
                  tex1y := abs(iy - y1) * 127 div abs(y3 - y1);
                  tex1x := 64 - abs(iy - y1) * 63 div abs(y3 - y1);
{                  putpixel(tex1x, tex1y, 33, $a000);}
               end;
               if ix > mxx then begin
                  mxx := ix;
                  tex2y := abs(iy - y1) * 127 div abs(y3 - y1);
                  tex2x := 64 - abs(iy - y1) * 63 div abs(y3 - y1);
{                  putpixel(tex2x, tex2y, 33, $a000);}
               end;
               end;
            end;
         if (y2 >= iy) or (y3 >= iy) then
            if (y2 <= iy) or (y3 <= iy) then begin
               if (y3 - y2) <> 0 then begin ix := round((iy-y2) * (x3-x2) / (y3-y2) + x2);
               if ix < mnx then begin
                  mnx := ix;
                  tex1y := 127;
                  tex1x := 127 - abs(iy - y2) * 127 div abs(y3 - y2);
{                  putpixel(tex1x, tex1y, 33, $a000);}
               end;
               if ix > mxx then begin
                  mxx := ix;
                  tex2y := 127;
                  tex2x := 127 - abs(iy - y2) * 127 div abs(y3 - y2);
{                  putpixel(tex2x, tex2y, 33, $a000);}
               end;
               end;
            end;
         if (y1 >= iy) or (y2 >= iy) then
            if (y1 <= iy) or (y2 <= iy) then begin
               if (y2 - y1) <> 0 then begin ix := round((iy-y1) * (x2-x1) / (y2-y1) + x1);
               if ix < mnx then begin
                  mnx := ix;
                  tex1x := 63 + abs(iy - y1) * 63 div abs(y2 - y1);
                  tex1y := abs(iy - y1) * 127 div abs(y2 - y1);
{                  putpixel(tex1x, tex1y, 33, $a000);}
               end;
               if ix > mxx then begin
                  mxx := ix;
                  tex2x := 63 + abs(iy - y1) * 63 div abs(y2 - y1);
                  tex2y := abs(iy - y1) * 127 div abs(y2 - y1);
{                  putpixel(tex2x, tex2y, 33, $a000);}
               end; end;
            end;
         if mnx<0 then
            mnx:=0;
         if mxx>319 then
            mxx:=319;

         if mnx<mxx then begin
            dtexy := (tex2y-tex1y) * 256 div (mxx-mnx);
            dtexx := (tex2x-tex1x) * 256 div (mxx-mnx);
            for i := 0 to (mxx - mnx) do
                if texnum = 1 then
                putpixel(i+mnx, iy,
                tile^[(tex1y+(dtexy * i) div 256)*128+
                       tex1x+(dtexx * i) div 256],virseg)
                else
                if texnum = 2 then putpixel(i+mnx, iy,
                window^[(tex1y+(dtexy * i) div 256)*128+
                       tex1x+(dtexx * i) div 256],virseg)
                else
                putpixel(i+mnx, iy,
                fire^[(tex1y+(dtexy * i) div 256)*128+
                       tex1x+(dtexx * i) div 256],virseg);
         end;

     end;
end;

Procedure Cls (Where:word;Col : Byte); assembler;
asm
   push    es
   mov     cx, 32000;
   mov     es,[where]
   xor     di,di
   mov     al,[col]
   mov     ah,al
   rep     stosw
   pop     es
End;

procedure flip(src,dst,offs:word); assembler; asm
  push ds; mov ds,[src]; mov si,[offs]; mov es,[dst]
  xor di,di; mov cx,320*200/2; rep movsw; pop ds; end;

procedure sort;
var b : boolean;
    i : integer;
procedure swap(a, b : integer);
{    ship, ship2 : array[1..16] of polygon;}
var p : integer;
begin
     p := shippt[a];
     shippt[a] := shippt[b];
     shippt[b] := p;
end;
begin
     for i := mnpoly to mxpoly do shippt[i] := i;
     repeat
     b := true;
     for i := mnpoly to mxpoly-1 do begin
         if ship[shippt[i]].pt[4].z < ship[shippt[i+1]].pt[4].z then begin
            swap(i, i + 1);
            b := false;
         end;
     end;
     until b = true;
end;


var x, y, i2 : integer;
    r, g, b, r2, g2, b2, clr : byte;
    temp, bb : boolean;
begin
     getmem(vir, 64000);
     getmem(back, 64000);
     fillchar(vir^, 64000, 0);
     for y := 0 to 199 do for x := 0 to 319 do back^[y * 320 + x] :=0;

     virseg := seg(vir^);

     viewpt := 0;

     for i := -180 to 180 do begin
         lookup[i, 1] := round(sin(i * pi / 180) * 256);
         lookup[i, 2] := round(cos(i * pi / 180) * 256);
     end;

     For i := 0 to 199 do
         Scr_Ofs[i] := i * 320;

     yoff := 0;
     xoff := 0;

     ship := mainship;

     for i := mnpoly to mxpoly do begin
     ship[i].pt[4].x := 0;
     ship[i].pt[4].y := 0;
     ship[i].pt[4].z := 0;
     for i2 := 1 to 3 do
     begin
     ship[i].pt[i2].y := -ship[i].pt[i2].y + 5;
     ship[i].pt[i2].z := ship[i].pt[i2].z - 24;
     ship[i].pt[4].x := ship[i].pt[4].x + ship[i].pt[i2].x;
     ship[i].pt[4].y := ship[i].pt[4].y + ship[i].pt[i2].y;
     ship[i].pt[4].z := ship[i].pt[4].z + ship[i].pt[i2].z;
     end;
     ship[i].pt[4].x := ship[i].pt[4].x div 3;
     ship[i].pt[4].y := ship[i].pt[4].y div 3;
     ship[i].pt[4].z := ship[i].pt[4].z div 3;
     end;

     ship2 := ship;

     setgraph;

     total := 3;
     infodat[1] := 'win.pcx';
     infodat[2] := 'panel2.pcx';
     infodat[3] := 'fire.pcx';

{     infodat[2] := 'win.pcx';
     infodat[3] := 'fire.pcx';}

     getmem(fire, 128*128);
     getmem(window, 128*128);
     getmem(tile, 128*128);

     temp:=loadpcx(3,seg(fire^),true);

     for i := 0 to 15 do begin
         getpal(i, r, g, b); pal(i+32,r, g, b);
     end;
     for i := 0 to 128*128-1 do fire^[i] := fire^[i] + 32;

     temp:=loadpcx(1,seg(window^),true);

     for i := 0 to 15 do begin
         getpal(i, r, g, b); pal(i+16,r, g, b);
     end;
     for i := 0 to 128*128-1 do window^[i] := window^[i] + 16;

     temp:=loadpcx(2,seg(tile^),true);

     xang := 0;
     yang := 0;
     zang := 0;

     boostlvl := -63;

     repeat until not keypressed;
     installkeybhandler;
     boostlvl := 0;

     repeat

{           inc(boostlvl, 1);
           if boostlvl > 10 then boostlvl := -10;

           getpal(32, r2, g2, b2);
           for i := 33 to 45 do begin
               getpal(i, r, g, b); pal(i-1,r, g, b);
           end;
           pal(45,r2, g2, b2);

           pal(255,63,abs(boostlvl),0);}

           ship := ship2;

           for i2 := mnpoly to mxpoly do begin
           for i := 1 to 4 do begin
              if zang <> 0 then begin
              new1 := (lookup[zang,2] * ship[i2].pt[i].x - lookup[zang,1] * (ship[i2].pt[i].y)) div 256;
              new2 := (lookup[zang,1] * ship[i2].pt[i].x + lookup[zang,2] * (ship[i2].pt[i].y)) div 256;
              ship[i2].pt[i].x := new1;
              ship[i2].pt[i].y := new2;
              end;

              if yang <> 0 then begin
              new1 := (lookup[yang,2] * ship[i2].pt[i].x - lookup[yang,1] * ship[i2].pt[i].z) div 256;
              new2 := (lookup[yang,1] * ship[i2].pt[i].x + lookup[yang,2] * ship[i2].pt[i].z) div 256;
              ship[i2].pt[i].x := new1;
              ship[i2].pt[i].z := new2;
              end;

              if xang <> 0 then begin
              new1 := (lookup[xang,2] * (ship[i2].pt[i].y ) - lookup[xang,1] * ship[i2].pt[i].z) div 256;
              new2 := (lookup[xang,1] * (ship[i2].pt[i].y ) + lookup[xang,2] * ship[i2].pt[i].z) div 256;
              ship[i2].pt[i].y := new1;
              ship[i2].pt[i].z := new2;
              end;

              ship[i2].pt[i].z := ship[i2].pt[i].z + 300;
                            if ship[i2].pt[i].z > 0 then begin
              ship[i2].pt[i].x := ((ship[i2].pt[i].x + xoff) * viewpt div ship[i2].pt[i].z + 160);
              ship[i2].pt[i].y := ((ship[i2].pt[i].y + yoff) * viewpt div ship[i2].pt[i].z) + 100;
              end;
           end;
           end;

            cls(virseg, 0);

           sort;

           for i2 := mnpoly to mxpoly do begin

           if ((ship[shippt[i2]].pt[2].x-ship[shippt[i2]].pt[1].x)*(ship[shippt[i2]].pt[1].y-ship[shippt[i2]].pt[3].y)-
           (ship[shippt[i2]].pt[2].y-ship[shippt[i2]].pt[1].y)*(ship[shippt[i2]].pt[1].x-ship[shippt[i2]].pt[3].x) <= 0)
           then
           if shippt[i2] in [5, 6, 7] then drawpoly(ship[shippt[i2]], clr, 2) else
           if shippt[i2] in [19, 22] then drawpoly(ship[shippt[i2]],clr,3)
           else drawpoly(ship[shippt[i2]],clr,1);

           end;

           if viewpt < 500 then inc(viewpt,8);
           for i := 0 to 47 do putpixel(i*2, 0, i, virseg);
           flip(virseg, $a000, 0);

           if ispressed(72) then begin
              dec(xang, 2);
           end;
           if ispressed(80) then begin
              inc(xang, 2);
           end;
           if ispressed(77) then begin
              inc(zang, 2);
{              dec(yang, 2);}
           end;
           if ispressed(75) then begin
              dec(zang, 2);
{              inc(yang, 2);}
           end;

{           if xoff > 1 then dec(xoff, 1) else
           if xoff < -1 then inc(xoff, 1);
           if yoff > 30 then dec(yoff, 1) else
           if yoff < 30 then inc(yoff, 1);

           if xang > 0 then dec(xang, 1);
           if xang < 0 then inc(xang, 1);
           if zang > 0 then dec(zang, 1);
           if zang < 0 then inc(zang, 1);
           if yang > 0 then dec(yang, 1);
           if yang < 0 then inc(yang, 1);}

           if xang > 180 then xang := -179;
           if yang > 180 then yang := -179;
           if zang > 180 then zang := -179;
           if xang < -180 then xang := 179;
           if yang < -180 then yang := 179;
           if zang < -180 then zang := 179;
     until ispressed(1);
     restorekeybhandler;
{     freemem(fire, 128*128);}
     freemem(window, 128*128);
     freemem(tile, 128*128);
     freemem(back, 64000);
     freemem(vir, 64000);
     settext;
end.