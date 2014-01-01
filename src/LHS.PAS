program lhs;

uses fpack, crt;

type
    textureptr = ^texture;
    texture = array[0..128*129-1] of byte;
    pointtype = record
        x, y, z: integer;
        end;
    polygon = record
        pt : array[1..5] of pointtype;
        {points 1..4 are points on the polygon, while 5 is the center}
        c : byte;
        {color}
        end;
    screentype = ^screen;
    screen = array[0..64000] of byte;

var
   Scr_Ofs : Array[0..199] of Word;
   i : integer;
   wall : textureptr;
   box, boxmain : array[1..6] of polygon;
   vir : screentype;
   virseg : word;

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


Procedure Hline (x1,x2,y:word;col:byte;where:word); assembler;
  { This draws a horizontal line from x1 to x2 on line y in color col }
asm
  mov   ax,$a000
  mov   es,ax
  mov   ax,y
  mov   di,ax
  shl   ax,8
  shl   di,6
  add   di,ax
  add   di,x1

  mov   al,1
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
var iy, ix, mny, mxy, mnx, mxx, dx : integer;
    dy14, dy21, dy32, dy43: integer;
    dx14, dx21, dx32, dx43: integer;
    tex1x, tex1y, tex2x, tex2y: integer;
    dtexx, dtexy : integer;
    x1, y1, x2, y2, x3, y3, x4, y4 : integer;
begin
     x1 := poly.pt[1].x;
     y1 := poly.pt[1].y;
     x2 := poly.pt[2].x;
     y2 := poly.pt[2].y;
     x3 := poly.pt[3].x;
     y3 := poly.pt[3].y;
     x4 := poly.pt[4].x;
     y4 := poly.pt[4].y;

     dy14 := y1 - y4;
     dy21 := y2 - y1;
     dy32 := y3 - y2;
     dy43 := y4 - y3;
     dx14 := x1 - x4;
     dx21 := x2 - x1;
     dx32 := x3 - x2;
     dx43 := x4 - x3;

     mny :=-32767;
     mxy := 32766;

     if y1 < mny then mny := y1;
     if y2 < mny then mny := y2;
     if y3 < mny then mny := y3;
     if y4 < mny then mny := y4;
     if y1 > mxy then mxy := y1;
     if y2 > mxy then mxy := y2;
     if y3 > mxy then mxy := y3;
     if y4 > mxy then mxy := y4;

     if mny < 0 then mny:=0;
     if mxy > 199 then mxy:=199;
     if mny > 199 then exit;
     if mxy < 0 then exit;

     for iy := mny to mxy do begin
         mnx := 32766;
         mxx := -32767;
         tex1x := 0;
         tex1y := 0;
         if (y4 >= iy) or (y1 >= iy) then
            if (y4 <= iy) or (y1 <= iy) then begin
               if dy14 <> 0 then begin
               ix := (iy-y4) * dx14 div dy14 + x4;
               if ix < mnx then begin
                  mnx := ix;
                  tex1y := abs((iy - y1) * 127 div dy14);
                  tex1x := 0;
               end;
               if ix > mxx then begin
                  mxx := ix;
                  tex2y := abs((iy - y1) * 127 div dy14);
                  tex2x := 0;
               end;
               end;
            end;
         if (y3 >= iy) or (y4 >= iy) then
            if (y3 <= iy) or (y4 <= iy) then begin
               if dy43 <> 0 then begin ix := (iy-y3) * dx43 div dy43 + x3;
               if ix < mnx then begin
                  mnx := ix;
                  tex1x := abs((iy - y4) * 127 div dy43);
                  tex1y := 127;
               end;
               if ix > mxx then begin
                  mxx := ix;
                  tex2x := abs((iy - y4) * 127 div dy43);
                  tex2y := 127;
               end;
               end;
            end;
         if (y2 >= iy) or (y3 >= iy) then
            if (y2 <= iy) or (y3 <= iy) then begin
               if dy32 <> 0 then begin
               ix := (iy-y2) * dx32 div dy32 + x2;
               if ix < mnx then begin
                  mnx := ix;
                  tex1y := abs((iy - y2) * 127 div dy32);
                  tex1x := 127;
               end;
               if ix > mxx then begin
                  mxx := ix;
                  tex2y := abs((iy - y2) * 127 div dy32);
                  tex2x := 127;
               end;
               end;
            end;
         if (y1 >= iy) or (y2 >= iy) then
            if (y1 <= iy) or (y2 <= iy) then begin
               if dy21 <> 0 then begin
               ix := (iy-y1) * dx21 div dy21 + x1;
               if ix < mnx then begin
                  mnx := ix;
                  tex1x := abs((iy - y1) * 127 div dy21);
                  tex1y := 0;
               end;
               if ix > mxx then begin
                  mxx := ix;
                  tex2x := abs((iy - y1) * 127 div dy21);
                  tex2y := 0;
               end;
               end;
            end;

         if mnx<0 then
            mnx:=0;
         if mxx>319 then
            mxx:=319;

         {putpixel(tex1x, tex1y, 16, $a000);
         putpixel(tex2x, tex2y, 16, $a000);}
         if mnx<mxx then begin
            dx := mxx - mnx;
            dtexy := (tex2y-tex1y) * 256 div dx;
            dtexx := (tex2x-tex1x) * 256 div dx;
            for i := 0 to dx-1 do
                putpixel(i+mnx, iy,
                wall^[(tex1y+(dtexy * i) div 256)*128+
                       tex1x+(dtexx * i) div 256],virseg);
{            hline(mnx, mxx, iy, 1, $a000);}
         end;
     end;
end;

Procedure Pal(ColorNo : Byte; R,G,B : Byte);
Begin
   Port[$3c8] := ColorNo;
   Port[$3c9] := R;
   Port[$3c9] := G;
   Port[$3c9] := B;
End;

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


var p, p2 : polygon;
    boxfile : text;
    temp : boolean;
    x, y, ang, new1, new2: integer;
    lookup : array[-360..360, 1..2] of integer;
begin
     asm
        mov ax, $13;
        int $10;
     end;

     for i := -360 to 360 do begin
         lookup[i, 1] := round(sin(i * pi / 180) * 256);
         lookup[i, 2] := round(cos(i * pi / 180) * 256);
     end;

     assign(boxfile, 'box.pol');
     reset(boxfile);
     for i := 1 to 6 do begin
         readln(boxfile, box[i].pt[1].x, box[i].pt[1].y, box[i].pt[1].z);
         readln(boxfile, box[i].pt[2].x, box[i].pt[2].y, box[i].pt[2].z);
         readln(boxfile, box[i].pt[3].x, box[i].pt[3].y, box[i].pt[3].z);
         readln(boxfile, box[i].pt[4].x, box[i].pt[4].y, box[i].pt[4].z);
         box[i].pt[5].x := (box[i].pt[1].x+box[i].pt[2].x+box[i].pt[3].x+
                           box[i].pt[4].x) div 4;
         box[i].pt[5].y := (box[i].pt[1].y+box[i].pt[2].y+box[i].pt[3].y+
                           box[i].pt[4].y) div 4;
         box[i].pt[5].z := (box[i].pt[1].z+box[i].pt[2].z+box[i].pt[3].z+
                           box[i].pt[4].z) div 4;
     end;
     close(boxfile);

     getmem(vir, 64000);
     virseg := seg(vir^);

     boxmain := box;

     For i := 0 to 199 do
         Scr_Ofs[i] := i * 320;

     total := 1;
     infodat[1] := 'snow.pcx';
     getmem(wall, 128*128);
     temp:=loadpcx(1,seg(wall^),true);

     for y := 0 to 127 do for x := 0 to 127 do
         putpixel(x, y, wall^[y * 128 + x], $a000);




     repeat until not keypressed;

     p.pt[1].x := -70;
     p.pt[1].y := -70;
     p.pt[1].z := 0;
     p.pt[2].x := 70;
     p.pt[2].y := -70;
     p.pt[2].z := 0;
     p.pt[3].x := 70;
     p.pt[3].y := 70;
     p.pt[3].z := 0;
     p.pt[4].x := -70;
     p.pt[4].y := 70;
     p.pt[4].z := 0;

     p2 := p;

     ang := 0;

     while not keypressed do begin

     p := p2;

     inc(ang,1);

     if ang > 360 then ang := -359;

     for i := 1 to 4 do begin
     new1 := (lookup[-ang,2] * p.pt[i].x - lookup[-ang,1] * (p.pt[i].y)) div 256;
     new2 := (lookup[-ang,1] * p.pt[i].x + lookup[-ang,2] * (p.pt[i].y)) div 256;
     p.pt[i].x := new1;
     p.pt[i].y := new2;
     new1 := (lookup[ang div 2,2] * p.pt[i].y - lookup[ang div 2,1] * (p.pt[i].z)) div 256;
     new2 := (lookup[ang div 2,1] * p.pt[i].y + lookup[ang div 2,2] * (p.pt[i].z)) div 256;
     p.pt[i].y := new1;
     p.pt[i].z := new2;
     new1 := (lookup[ang,2] * p.pt[i].x - lookup[ang,1] * (p.pt[i].z)) div 256;
     new2 := (lookup[ang,1] * p.pt[i].x + lookup[ang,2] * (p.pt[i].z)) div 256;
     p.pt[i].x := new1;
     p.pt[i].z := new2;
     end;

     for i := 1 to 4 do begin
         p.pt[i].x := p.pt[i].x * 200 div (p.pt[i].z + 250) + 160;
         p.pt[i].y := p.pt[i].y * 200 div (p.pt[i].z + 250) + 100;
     end;

     cls(virseg, 0);

     drawpoly(p);

     flip(virseg, $a000, 0);

{     for i := 1 to 6 do drawpoly(box[i]);}

     end;

     freemem(vir, 64000);

     asm
        mov ax, $03;
        int $10;
     end;

end.
