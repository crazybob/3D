program lhs;

uses fpack, crt, tmems;

const mxpoly = 22;
      mxtex = 13;
      bit : array[0..15] of word = (1,2,4,8,16,32,64,128,256,512,1024,
            2048, 4096, 8192, 16384, 32768);

type
    textureptr = ^texture;
    texture = array[0..128*129-1] of byte;
    pointtype = record
        x, y, z: longint;
        end;
    polygon = record
        pt : array[1..5] of pointtype;
        {points 1..4 are points on the polygon, while 5 is the center}
        tex : byte;
        {texture}
        end;
    screentype = ^screen;
    screen = array[0..64000] of byte;

var
   faddr : word;
   Scr_Ofs : Array[0..199] of Word;
   i : integer;
   wall : textureptr;
   box, boxmain : array[1..mxpoly] of polygon;
   vir : screentype;
   virseg : word;
   boxpt : array[1..mxpoly] of integer;
   font : array[0..255, 0..7] of byte;
   Fseg,Fofs : word;

Procedure Putpixel (X,Y : Integer; Col : Byte; where:word); assembler;
asm
   mov es, where
   mov bx,[y]
   shl bx,1
   mov di,word ptr [Scr_Ofs + bx]
   add di,[x]
   mov al,[col]
   stosb
end;

procedure Getfont; assembler; asm
  mov ax,1130h; mov bh,$03; int 10h; mov Fseg,es; mov Fofs,bp;
end;

procedure loadfont;
var x,y : integer;
begin
    for x := 0 to 255 do for y := 0 to 7 do
        font[x,y] := mem[fseg:fofs+x*8+y];
end;

procedure outchxy(x1, y1:integer; c, clr : byte);
var x, y: integer;
begin
     for x := 0 to 7 do for y := 0 to 7 do
         if font[c, y] and bit[x] = bit[x] then putpixel(x1+7-x, y1+y, clr, virseg);
end;

procedure drawpoly(poly : polygon);
var iy, ix, mny, mxy, mnx, mxx, dx : integer;
    dy14, dy21, dy32, dy43: integer;
    dx14, dx21, dx32, dx43: integer;
    tex1x, tex1y, tex2x, tex2y: integer;
    dtexx, dtexy : integer;
    startx, endx, x1, y1, x2, y2, x3, y3, x4, y4 : integer;
    texx, texy : integer;
    col : byte;
begin
     map_page(poly.tex, 0);

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
                  tex1y := (iy - y1) * 127 div dy14;
                  tex1x := 0;
               end;
               if ix > mxx then begin
                  mxx := ix;
                  tex2y := (iy - y1) * 127 div dy14;
                  tex2x := 0;
               end;
               end;
            end;
         if (y3 >= iy) or (y4 >= iy) then
            if (y3 <= iy) or (y4 <= iy) then begin
               if dy43 <> 0 then begin ix := (iy-y3) * dx43 div dy43 + x3;
               if ix < mnx then begin
                  mnx := ix;
                  tex1x := (iy - y4) * 127 div dy43;
                  tex1y := 127;
               end;
               if ix > mxx then begin
                  mxx := ix;
                  tex2x := (iy - y4) * 127 div dy43;
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
                  tex1y := (iy - y2) * 127 div dy32;
                  tex1x := 127;
               end;
               if ix > mxx then begin
                  mxx := ix;
                  tex2y := (iy - y2) * 127 div dy32;
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
                  tex1x := (iy - y1) * 127 div dy21;
                  tex1y := 0;
               end;
               if ix > mxx then begin
                  mxx := ix;
                  tex2x := (iy - y1) * 127 div dy21;
                  tex2y := 0;
               end;
               end;
            end;

         dx := mxx - mnx + 1;

         startx := mnx;
         endx := mxx;

         if startx<0 then
            startx:=0;
         if endx>319 then
            endx:=319;

         tex1x := abs(tex1x);
         tex1y := abs(tex1y);
         tex2x := abs(tex2x);
         tex2y := abs(tex2y);

         if mnx<mxx then begin
            dtexy := (tex2y-tex1y) * 256 div dx;
            dtexx := (tex2x-tex1x) * 256 div dx;
            texx := tex1x shl 8 + dtexx * (startx - mnx);
            texy := tex1y shl 8 + dtexy * (startx - mnx);
            for i := startx to endx do begin
                texx := texx + dtexx;
                texy := texy + dtexy;
                col := mem[faddr:texy div 256 * 128 +
                       texx shr 8];
                if col <> 2 then putpixel(i, iy, col, virseg);
            end;
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

procedure sort;
var b : boolean;
    i : integer;
procedure swap(a, b : integer);
{    box, box2 : array[1..16] of polygon;}
var p : integer;
begin
     p := boxpt[a];
     boxpt[a] := boxpt[b];
     boxpt[b] := p;
end;
begin
     for i := 1 to mxpoly do boxpt[i] := i;
     repeat
     b := true;
     for i := 1 to mxpoly-1 do begin
         if box[boxpt[i]].pt[5].z < box[boxpt[i+1]].pt[5].z then begin
            swap(i, i + 1);
            b := false;
         end;
     end;
     until b = true;
end;

var p, p2 : polygon;
    boxfile : text;
    temp : boolean;
    i2, x, y, ang, new1, new2: integer;
    lookup : array[-360..360, 1..2] of integer;
begin
     pagestatus(x, y);
     writeln('EMS ver. ' + get_version_number + ' detected.');
     writeln(x * 16 div 1000, 'mb total available EMS memory, ', y * 16 div 1000, 'mb free.');
     allocate_pages(mxtex);
     writeln(mxtex * 16384, ' bytes successfully allocated.');
     faddr := get_frame_address;
     writeln('Page frame located at segment ', faddr,'.');

     asm
        mov ax, $13;
        int $10;
     end;

     getfont;
     loadfont;

     total := mxtex;

     infodat[1] := '_panel.pcx';
     infodat[2] := '_yellow.pcx';
     infodat[3] := '_fire.pcx';
     infodat[4] := '_66.pcx';
     infodat[5] := '_head.pcx';
     infodat[6] := '_tire.pcx';
     infodat[7] := '_bottom.pcx';
     infodat[8] := '_tail.pcx';
     infodat[9] := '_window.pcx';
     infodat[10] := '_street.pcx';
     infodat[11] := '_snow.pcx';
     infodat[12] := '_sky.pcx';
     infodat[13] := '_tree.pcx';

     for i := 1 to mxtex do begin
         map_page(i, 0);
         temp:=loadpcx(i,faddr,true);
     end;

     pal(255,0,0,0);
     pal(254,63,63,63);

     for i := -360 to 360 do begin
         lookup[i, 1] := round(sin(i * pi / 180) * 256);
         lookup[i, 2] := round(cos(i * pi / 180) * 256);
     end;

     assign(boxfile, 'box.pol');
     reset(boxfile);
     for i := 1 to mxpoly do begin
         readln(boxfile, box[i].tex);
         readln(boxfile, box[i].pt[1].x, box[i].pt[1].y, box[i].pt[1].z);
         readln(boxfile, box[i].pt[2].x, box[i].pt[2].y, box[i].pt[2].z);
         readln(boxfile, box[i].pt[3].x, box[i].pt[3].y, box[i].pt[3].z);
         readln(boxfile, box[i].pt[4].x, box[i].pt[4].y, box[i].pt[4].z);
         box[i].pt[1].z := box[i].pt[1].z * 3 div 2;
         box[i].pt[2].z := box[i].pt[2].z * 3 div 2;
         box[i].pt[3].z := box[i].pt[3].z * 3 div 2;
         box[i].pt[4].z := box[i].pt[4].z * 3 div 2;
         box[i].pt[1].y := box[i].pt[1].y + 35;
         box[i].pt[2].y := box[i].pt[2].y + 35;
         box[i].pt[3].y := box[i].pt[3].y + 35;
         box[i].pt[4].y := box[i].pt[4].y + 35;
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

     repeat until not keypressed;

     ang := 0;

     while not keypressed do begin

     box := boxmain;

     inc(ang,1);

     if ang > 360 then ang := -359;

     for i2 := 1 to mxpoly do
     for i := 1 to 5 do begin

{     new1 := (lookup[-ang,2] * box[i2].pt[i].x - lookup[-ang,1] * (box[i2].pt[i].y)) div 256;
     new2 := (lookup[-ang,1] * box[i2].pt[i].x + lookup[-ang,2] * (box[i2].pt[i].y)) div 256;
     box[i2].pt[i].x := new1;
     box[i2].pt[i].y := new2;}
{     new1 := (lookup[ang div 2,2] * box[i2].pt[i].y - lookup[ang div 2,1] * (box[i2].pt[i].z)) div 256;
     new2 := (lookup[ang div 2,1] * box[i2].pt[i].y + lookup[ang div 2,2] * (box[i2].pt[i].z)) div 256;
     box[i2].pt[i].y := new1;
     box[i2].pt[i].z := new2;}
     new1 := (lookup[ang,2] * box[i2].pt[i].x - lookup[ang,1] * (box[i2].pt[i].z)) div 256;
     new2 := (lookup[ang,1] * box[i2].pt[i].x + lookup[ang,2] * (box[i2].pt[i].z)) div 256;
     box[i2].pt[i].x := new1;
     box[i2].pt[i].z := new2;

     box[i2].pt[i].x := box[i2].pt[i].x * 350 div (box[i2].pt[i].z + 450) + 160;
     box[i2].pt[i].y := box[i2].pt[i].y * 350 div (box[i2].pt[i].z + 450) + 100;
     end;

     sort;

     for i2 := 1 to mxpoly do
     if ((box[boxpt[i2]].pt[2].x - box[boxpt[i2]].pt[1].x) *
     (box[boxpt[i2]].pt[1].y - box[boxpt[i2]].pt[3].y) -
     (box[boxpt[i2]].pt[2].y - box[boxpt[i2]].pt[1].y)*
     (box[boxpt[i2]].pt[1].x - box[boxpt[i2]].pt[3].x)) > 0 then drawpoly(box[boxpt[i2]]);

     flip(virseg, $a000, 0);

     cls(virseg, 255);
{     for i := 1 to 6 do drawpoly(box[i]);}

     end;

     freemem(vir, 64000);

     asm
        mov ax, $03;
        int $10;
     end;

     deallocate_pages;
end.
