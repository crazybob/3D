program lhs;

uses fpack, { routines for loading PCX files by the Asphyxia group }
     crt,
     tmems, { public domain EMS routines }
     ukeyb; { advanced keyboard handler by Francesco E. Carucci }

const mxtex = 8; { maximum number of textures available, used in
                   memory allocation and texture initialization. }
      bit : array[0..15] of word = (1,2,4,8,16,32,64,128,256,512,1024,
            2048, 4096, 8192, 16384, 32768);
      { bit lookup table, simplifies outtext rountines }

type
    pointtype = record { 3d point }
        x, y, z: longint;
        end;
    polygon = record
        pt : array[1..5] of pointtype;
        { points 1..4 are points on the polygon, while 5 is the center }
        tex : byte;
        { polygon texture number }
        end;
    polptr = ^pol;
    pol = record
        p : polygon; { polygon data }
        n, l, r : polptr; { pointers for linked list and binary tree }
    end;
    screentype = ^screen;
    screen = array[0..64000] of byte; { virtual screen, swaps with vga
                                        memory }

var
   top, current, { main polygon tree structure }
   topt, currentt, { used in construction of polygon binary search tree }
   topm, currentm { default polygon information as read from file }
         : polptr;
   faddr : word; { EMS frame address }
   Scr_Ofs : Array[0..199] of Word; { VGA screen offset lookup table for
           putpixel routines }
   f : text; { polygon file }
   vir : screentype; { virtual screen }
   virseg : word; { virtual screen segment for assembly routines }
   font : array[0..255, 0..7] of byte; { font lookup table }
   Fseg,Fofs : word; { font table segment, offset in bios }
   templn : array[0..127] of byte; { used in texture scrolling as in the
          clouds and slime. }
   i, i2, { loop variables }
   x, y, { temporary variables }
   yang, ang, { rotation angles }
   new1, new2: {temporary variables for rotation routines }
         integer;
   lookup : array[-360..360, 1..2] of integer; { sin/cos lookup table }
   xoff, zoff : longint; { x and z offsets in 3d world, essentially
         player location }
   temp : boolean; { temporary variable }

procedure putpixel (x,y : integer; col : byte; where:word); assembler;
{ set pixel at (x, y) in vga memory or virtual screen to color col }
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
{ get font segment and offset }
  mov ax,1130h; mov bh,$03; int 10h; mov Fseg,es; mov Fofs,bp;
end;

procedure loadfont;
{ load font in to lookup table }
var x,y : integer;
begin
    for x := 0 to 255 do for y := 0 to 7 do
        font[x,y] := mem[fseg:fofs+x*8+y];
end;

procedure outchxy(x1, y1:integer; c, clr : byte);
{ write char c at (x1, y1) in color clr }
var x, y: integer;
begin
     for x := 0 to 7 do for y := 0 to 7 do
         if font[c, y] and bit[x] = bit[x] then putpixel(x1+7-x, y1+y, clr, virseg);
end;

procedure outtextxy(x1, y1:integer; s:string; clr : byte);
{ write string s at (x1, y1) in color clr }
var i: integer;
begin
     for i := 0 to length(s) - 1 do outchxy(x1 + i * 8, y1, ord(s[i+1]), clr);
end;

procedure drawpoly(poly : polygon);
{ draw polygon poly }
var iy, ix, mny, mxy, mnx, mxx, dx : integer;
    dy14, dy21, dy32, dy43: integer;
    dx14, dx21, dx32, dx43: integer;
    tex1x, tex1y, tex2x, tex2y: integer;
    dtexx, dtexy : integer;
    startx, endx, x1, y1, x2, y2, x3, y3, x4, y4 : integer;
    off, texx, texy : integer;
    col : byte;
begin
     { map EMS page to polygon texture }

     map_page(poly.tex, 0);

     { initialize variables }

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

     { scan polygon edges using line equations finding the start and end
       points for the horizontal scanline and their corresponding points
       on the texture map }

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

         { scan horizontal scanline plotting corresponding pixels from
           texture map }

         if mnx<mxx then begin
            dtexy := (tex2y-tex1y) * 256 div dx;
            dtexx := (tex2x-tex1x) * 256 div dx;
            texx := tex1x shl 8 + dtexx * (startx - mnx);
            texy := tex1y shl 8 + dtexy * (startx - mnx);
            off:=320*iy+startx;
            for i := startx to endx do begin
                asm
                mov ax,dtexx
                add texx,ax
                mov ax,dtexy
                add texy,ax
                mov si,texy
                shr si,8
                shl si,7
                mov ax,texx
                shr ax,8
                add si,ax
                mov es,virseg
                mov di,off
                push ds
                mov ds,faddr
                mov al,[ds:si]
                cmp al,4
                je @skip1
                mov [es:di],al
                @skip1:
                inc off
                pop ds
                end;
            end;
         end;
     end;
end;

procedure pal(colorno : byte; r,g,b : byte);
{ set palette of colorno to r, g, b (red, green blue) }
begin
   port[$3c8] := colorno;
   port[$3c9] := r;
   port[$3c9] := g;
   port[$3c9] := b;
end;

procedure cls (where:word; col : Byte); assembler;
{ clear 64000 byte memory location at segment where to color col }
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
{ copy 64000 bytes from src to dest at offset offs, used to copy virtual
  screen to vga memory }
  push ds; mov ds,[src]; mov si,[offs]; mov es,[dst]
  xor di,di; mov cx,320*200/2; rep movsw; pop ds; end;

procedure sort;
{ sort polygons, build binary search tree from polygon linked list,
  these two data structures are one in the same to conserve time and
  space.  they simply have different pointer variables for the list
  and the tree }
begin
     current := top;
     topt := top;
     topt^.l := nil;
     topt^.r := nil;
     repeat
            currentt := topt;
            repeat
                  if (current^.p.pt[5].z < currentt^.p.pt[5].z)
                     then
                          currentt := currentt^.l
                     else
                          currentt := currentt^.r;
            until ((currentt^.l = nil) and (current^.p.pt[5].z < currentt^.p.pt[5].z))
                  or ((currentt^.r = nil) and (current^.p.pt[5].z >= currentt^.p.pt[5].z));
            if (current^.p.pt[5].z < currentt^.p.pt[5].z)
                then begin
                     currentt^.l := current;
                     currentt := currentt^.l;
                end else begin
                     currentt^.r := current;
                     currentt := currentt^.r;
                end;
            currentt^.l := nil;
            currentt^.r := nil;
            current := current^.n;
     until current = nil;
end;

procedure travpoly(poly : polptr);
{ traverse the polygon structure and draw the polygons in the correct order }
begin
     if poly <> nil then begin
        travpoly(poly^.r);

        if (poly^.p.pt[1].z > 0) and (poly^.p.pt[2].z > 0) and
        (poly^.p.pt[3].z > 0) and (poly^.p.pt[4].z > 0) then

        if (poly^.p.pt[5].x > -300) and (poly^.p.pt[5].x < 620)
        and (poly^.p.pt[5].y > -170) and (poly^.p.pt[5].y < 370)

        then drawpoly(poly^.p);

        travpoly(poly^.l);
     end;
end;

procedure kill(var poly : polptr);
{ destroy the polygon structure and reclaim the memory for the pool }
begin
     if poly^.n <> nil then kill(poly^.n);
     dispose(poly);
end;

begin
     { check EMS memory status }
     pagestatus(x, y);
     writeln('EMS ver. ' + get_version_number + ' detected.');
     writeln(x * 16 div 1000, 'mb total available EMS memory, ', y * 16 div 1000, 'mb free.');
     allocate_pages(mxtex+1);
     writeln((mxtex+1) * 16384, ' bytes successfully allocated.');
     faddr := get_frame_address;
     writeln('Page frame located at segment ', faddr,'.');

     readln;

     { set graphics mode }
     asm
        mov ax, $13;
        int $10;
     end;

     { load font information for outtextxy }
     getfont;
     loadfont;


     { load PCX files into texture maps }
     total := mxtex;

     infodat[1] := '_brick.pcx';
     infodat[2] := '_ceiling.pcx';
     infodat[3] := '_clouds.pcx';
     infodat[4] := '_floor.pcx';
     infodat[5] := '_wall2.pcx';
     infodat[6] := '_wood.pcx';
     infodat[7] := '_keys.pcx';
     infodat[8] := '_mount.pcx';

     for i := 1 to mxtex do begin
         map_page(i, 0);
         temp:=loadpcx(i,faddr,true);
     end;

     { set pallete colors 254, 255 }
     pal(255,20,20,30);
     pal(254,33,33,63);

     { set up sin/cos lookup table }
     for i := -360 to 360 do begin
         lookup[i, 1] := round(sin(i * pi / 180) * 256);
         lookup[i, 2] := round(cos(i * pi / 180) * 256);
     end;

     { initialize virtual memory }
     getmem(vir, 64000);
     virseg := seg(vir^);
     cls(virseg, 255);

     { initialize polgon structure and read polygons from file }
     new(top);
     current := top;

     top^.n := nil;
     top^.l := nil;
     top^.r := nil;

     assign(f, 'map.pol');
     reset(f);

     while not eof(f) do begin
         readln(f, current^.p.tex);
         for i2 := 1 to 4 do
             readln(f, current^.p.pt[i2].x, current^.p.pt[i2].y,
                       current^.p.pt[i2].z);
         current^.p.pt[5].x := (current^.p.pt[1].x + current^.p.pt[2].x +
                            current^.p.pt[3].x + current^.p.pt[4].x) div 4;
         current^.p.pt[5].y := (current^.p.pt[1].y + current^.p.pt[2].y +
                            current^.p.pt[3].y + current^.p.pt[4].y) div 4;
         current^.p.pt[5].z := (current^.p.pt[1].z + current^.p.pt[2].z +
                            current^.p.pt[3].z + current^.p.pt[4].z) div 4;
         readln(f);

         if not eof(f) then begin
            new(current^.n);
            current := current^.n;
            current^.n := nil;
            current^.l := nil;
            current^.r := nil;
         end;
     end;

     close(f);

     { copy polygon structure to second constant structure }
     new(topm);
     currentm := topm;

     topm^.n := nil;
     topm^.l := nil;
     topm^.r := nil;

     current := top;
     repeat
           currentm^.p := current^.p;
           current := current^.n;
           new(currentm^.n);
           currentm := currentm^.n;
           currentm^.n := nil;
           currentm^.l := nil;
           currentm^.r := nil;
     until current = nil;

     { set up screen offset lookup table }
     for i := 0 to 199 do
         scr_ofs[i] := i * 320;

     repeat until not keypressed;

     ang := 0;
     yang := 0;

     xoff := 0;
     zoff := 0;

     installkeybhandler;

     while not ispressed(1) do begin

     { check keyboard and move player accordingly in 3d world }

     if ispressed(79) then begin inc(yang,3);
     end;

     if ispressed(71) then begin dec(yang,3);
     end;

     if ispressed(77) then begin inc(ang,3);
     end;

     if ispressed(75) then begin dec(ang,3);
     end;

     if ispressed(80) then begin
        xoff := (xoff + lookup[ang,1] * 15);
        zoff := (zoff + lookup[ang,2] * 15);
     end;

     if ispressed(72) then begin
        xoff := (xoff - lookup[ang,1] * 15);
        zoff := (zoff - lookup[ang,2] * 15);
     end;

     if zoff > 55 * 256 then zoff := 55 * 256;
     if zoff < -55 * 256 then zoff := -55 * 256;

     if xoff < -310 * 256 then xoff := -310 * 256;
     if xoff > 310 * 256 then xoff := 310 * 256;

     if ang > 180 then ang := -180;
     if ang < -180 then ang := 180;
     if yang > 180 then yang := -180;
     if yang < -180 then yang := 180;

     { scroll river texture }
     map_page(4, 0);
     move(mem[faddr:0],templn[0],128);
     move(mem[faddr:128],mem[faddr:0],128*127);
     move(templn[0],mem[faddr:127*128],128);

     { reset polygon structure to constant }
     current := top;
     currentm := topm;
     repeat
           current^.p := currentm^.p;
           current := current^.n;
           currentm := currentm^.n;
     until current = nil;

     current := top;
     repeat

     for i := 1 to 5 do begin

     { rotate points }
     current^.p.pt[i].x := current^.p.pt[i].x + xoff div 256;
     current^.p.pt[i].z := current^.p.pt[i].z + zoff div 256;
     current^.p.pt[i].y := current^.p.pt[i].y + 5;

     new1 := (lookup[ang,2] * (current^.p.pt[i].x) - lookup[ang,1] * (current^.p.pt[i].z)) div 256;
     new2 := (lookup[ang,1] * (current^.p.pt[i].x) + lookup[ang,2] * (current^.p.pt[i].z)) div 256;
     current^.p.pt[i].x := new1;
     current^.p.pt[i].z := new2;

     new1 := (lookup[yang,2] * (current^.p.pt[i].y) - lookup[yang,1] * (current^.p.pt[i].z)) div 256;
     new2 := (lookup[yang,1] * (current^.p.pt[i].y) + lookup[yang,2] * (current^.p.pt[i].z)) div 256;
     current^.p.pt[i].y := new1;
     current^.p.pt[i].z := new2;

     { compensate for z-distance perspective }
     if current^.p.pt[i].z > 0 then begin
     current^.p.pt[i].x := current^.p.pt[i].x * 350 div (current^.p.pt[i].z) + 160;
     current^.p.pt[i].y := current^.p.pt[i].y * 350 div (current^.p.pt[i].z) + 100;
     end;

     end;

     current := current^.n;
     until current = nil;

     { construct binary search tree }
     sort;

     current := top;

     { traverse polygon structure and draw polygons }
     travpoly(top);

     { copy virtual segment to vga memory }
     flip(virseg, $a000, 0);



     end;

     restorekeybhandler;

     { destroy structures }
     kill(top);
     kill(topm);

     { free virtual screen memory }
     freemem(vir, 64000);

     { set graphics to text mode }
     asm
        mov ax, $03;
        int $10;
     end;

     { deallocate EMS pages }
     deallocate_pages;
end.
