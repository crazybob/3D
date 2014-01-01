program oz;

uses ukeyb, fpack;

const maxpoly = 1;

type
    tileptr = ^tiletype;
    tiletype = array[0..128*128] of byte;
    pointtype = record
        x, y, z: LongInt;
        end;
    polygon = record
        pt : array[1..5] of pointtype;
        t : tileptr;
        end;
    screentype = ^screen;
    screen = array[0..64000] of byte;

var
   wall : tileptr;
   lookup : array[-360..360, 1..2] of integer;
   scr_ofs : array[0..199] of word;
   i : integer;
   world : array[1..maxpoly] of polygon;

procedure putpixel (x,y : integer; col : byte; where:word); assembler;
asm
   mov  ax,where
   mov  es,ax
   mov  bx,[y]
   shl  bx,1
   mov  di,word ptr [scr_ofs + bx]
   add  di,[x]
   mov  al,[col]
   mov  es:[di],al
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

procedure drawpoly(poly : polygon);
var iy, ix, mny, mxy, mnx, mxx : integer;
    x1, y1, x2, y2, x3, y3, x4, y4 : longint;
    x1t, y1t, x2t, y2t, x3t, y3t : integer;
    dtexx, dtexy, i, tex1x, tex2x, tex1y, tex2y : integer;
begin
     x1 := poly.pt[1].x; y1 := poly.pt[1].y;
     x2 := poly.pt[2].x; y2 := poly.pt[2].y;
     x3 := poly.pt[3].x; y3 := poly.pt[3].y;
     x4 := poly.pt[4].x; y4 := poly.pt[4].y;

     mny :=-32767; mxy := 32766;

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
         if (y4 >= iy) or (y1 >= iy) then
            if (y4 <= iy) or (y1 <= iy) then begin
               if (y1 - y4) <> 0 then begin
               ix := round((iy-y4) * (x1-x4) / (y1-y4) + x4);
               if ix < mnx then begin
                  mnx := ix;
                  tex1y := abs(iy - y1) * 127 div abs(y4 - y1);
                  tex1x := 0{64 - abs(iy - y1) * 64 div abs(y4 - y1)};
{                  putpixel(tex1x, tex1y, 33, $a000);}
               end;
               if ix > mxx then begin
                  mxx := ix;
                  tex2y := abs(iy - y1) * 127 div abs(y4 - y1);
                  tex2x := 0{64 - abs(iy - y1) * 64 div abs(y4 - y1)};
{                  putpixel(tex2x, tex2y, 33, $a000);}
               end;
               end;
            end;

         if (y3 >= iy) or (y4 >= iy) then
            if (y3 <= iy) or (y4 <= iy) then begin
               if (y4 - y3) <> 0 then begin ix := round((iy-y3) * (x4-x3) / (y4-y3) + x3);
               if ix < mnx then begin
                  mnx := ix;
                  tex1y := 127;
                  tex1x := 127 - abs(iy - y3) * 127 div abs(y4 - y3);
{                  putpixel(tex1x, tex1y, 33, $a000);}
               end;
               if ix > mxx then begin
                  mxx := ix;
                  tex2y := 127;
                  tex2x := 127 - abs(iy - y3) * 127 div abs(y4 - y3);
{                  putpixel(tex2x, tex2y, 33, $a000);}
               end;
               end;
            end;

         if (y2 >= iy) or (y3 >= iy) then
            if (y2 <= iy) or (y3 <= iy) then begin
               if (y3 - y2) <> 0 then begin ix := round((iy-y2) * (x3-x2) / (y3-y2) + x2);
               if ix < mnx then begin
                  mnx := ix;
                  tex1y := 127 - abs(iy - y3) * 127 div abs(y2 - y3);
                  tex1x := 127;
{                  putpixel(tex1x, tex1y, 33, $a000);}
               end;
               if ix > mxx then begin
                  mxx := ix;
                  tex2y := 127 - abs(iy - y3) * 127 div abs(y2 - y3);
                  tex2x := 127;
{                  putpixel(tex2x, tex2y, 33, $a000);}
               end;
               end;
            end;
         if (y1 >= iy) or (y2 >= iy) then
            if (y1 <= iy) or (y2 <= iy) then begin
               if (y2 - y1) <> 0 then begin ix := round((iy-y1) * (x2-x1) / (y2-y1) + x1);
               if ix < mnx then begin
                  mnx := ix;
                  tex1x := abs(iy - y1) * 127 div abs(y2 - y1);
                  tex1y := 0;
{                 putpixel(tex1x, tex1y, 33, $a000);}
               end;
               if ix > mxx then begin
                  mxx := ix;
                  tex2x := abs(iy - y1) * 127 div abs(y2 - y1);
                  tex2y := 0;
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
                putpixel(i+mnx, iy,
                poly.t^[(tex1y+(dtexy * i) div 256)*128+
                       tex1x+(dtexx * i) div 256], $a000)
         end;
     end;
end;


begin
     asm
        mov ax, $10;
        int $10;
     end;
     for i := -360 to 360 do begin
         lookup[i, 1] := round(sin(i * pi / 180) * 256);
         lookup[i, 2] := round(cos(i * pi / 180) * 256);
     end;
     for i := 0 to 199 do
         scr_ofs[i] := i * 320;
     total := 1;
     infodat[1] := 'panel2.pcx';
     getmem(wall, 128*128);
     if not loadpcx(1,seg(wall^),true) then halt(0);

     world[1].pt[1].x := -10 +100;
     world[1].pt[1].y := -10 +100;
     world[1].pt[1].z := 50 +100;
     world[1].pt[2].x := 10 +100;
     world[1].pt[2].y := -10 +100;
     world[1].pt[2].z := 50 +100;
     world[1].pt[3].x := 10 +100;
     world[1].pt[3].y := 20 +100;
     world[1].pt[3].z := 50 +100;
     world[1].pt[4].x := -10 +100;
     world[1].pt[4].y := 10 +100;
     world[1].pt[4].z := 50 +100;
     world[1].pt[5].x := -20 +100;
     world[1].pt[5].y := -20 +100;
     world[1].pt[5].z := -20 +100;

     for i := 1 to 4 do begin
         world[1].pt[5].x := world[1].pt[5].x + world[1].pt[i].x;
         world[1].pt[5].y := world[1].pt[5].y + world[1].pt[i].y;
         world[1].pt[5].z := world[1].pt[5].z + world[1].pt[i].z;
     end;
     world[1].pt[5].x := world[1].pt[5].x div 4;
     world[1].pt[5].y := world[1].pt[5].y div 4;
     world[1].pt[5].z := world[1].pt[5].z div 4;

     drawpoly(world[1]);
     readln;

     asm
        mov ax, $03;
        int $10;
     end;
end.