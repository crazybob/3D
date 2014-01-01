UNIT FPack;

INTERFACE

USES crt;

VAR InfoDat : array [1..25] of string[12];
      Total : Integer;

Function LoadData (num:integer; p:pointer):Boolean;
  { Load raw data into data at pointer "p" }
Function LoadCel  (num:integer; p:pointer):Boolean;
  { Load in a cel into pointer "p" }
Function LoadPCX  (num:integer; where:word; dopal : Boolean):Boolean;
  { Load a PCX file to the screen "where"
    Dopal = True sets up the correct PCX pallette, otherwise it leaves
            the pallette alone }

IMPLEMENTATION


VAR pack:boolean;
    InfoPos:Array[1..25] of longint;

Procedure DoSinglePal(Col,R,G,B : Byte); assembler;
asm
   mov    dx,3c8h
   mov    al,[col]
   out    dx,al
   inc    dx
   mov    al,[r]
   out    dx,al
   mov    al,[g]
   out    dx,al
   mov    al,[b]
   out    dx,al
end;


Function LoadData (num:integer; p:pointer):Boolean;
VAR f:file;
BEGIN
  If num>Total then BEGIN
    LoadData:=FALSE;
    exit;
  END;
  If pack then BEGIN
    assign (f,paramstr(0));
    reset (f,1);
    seek (f,infopos[num]);
    blockread (f, p^, infopos[num+1]-infopos[num]);
    close (f);
  END else BEGIN
    assign (f,infodat[num]);
    reset (f,1);
    blockread (f, p^, filesize (f));
    close (f);
  END;
END;

Function LoadCel (num:integer; p:pointer):Boolean;
VAR f:file;
BEGIN
  If num>Total then BEGIN
    LoadCel:=FALSE;
    exit;
  END;
  If pack then BEGIN
    assign (f,paramstr(0));
    reset (f,1);
    seek (f,infopos[num]+800);
    blockread (f, p^, infopos[num+1]-infopos[num]-800);
    close (f);
  END else BEGIN
    assign (f,infodat[num]);
    reset (f,1);
    seek (f,800);
    blockread (f, p^, filesize (f));
    close (f);
  END;
END;

Function LoadPCX (num:integer; where:word; dopal : Boolean):Boolean;
VAR f:file;
    res,loop1:word;
    temp:pointer;
    pallette: Array[0..767] Of Byte;
BEGIN
  If num>Total then BEGIN
    LoadPCX:=FALSE;
    exit;
  END;
  If pack then BEGIN
    assign (f,paramstr(0));
    reset (f,1);
    if dopal then BEGIN
      Seek(f,infopos[num+1]-768);
      BlockRead(f,pallette,768);
      For loop1:=0 To 255 Do
        dosinglepal (loop1,pallette[loop1*3] shr 2,pallette[loop1*3+1] shr 2,pallette[loop1*3+2] shr 2);
    END;
    seek (f,infopos[num]+128);
  END else BEGIN
    assign (f,infodat[num]);
    reset (f,1);
    if dopal then BEGIN
      Seek(f,FileSize(f)-768);
      BlockRead(f,pallette,768);
      For loop1:=0 To 255 Do
        dosinglepal (loop1,pallette[loop1*3] shr 2,pallette[loop1*3+1] shr 2,pallette[loop1*3+2] shr 2);
    END;
    seek (f,128);
  END;
  getmem (temp,65535);
  blockread (f,temp^,65535,res);
  asm
    push ds
    mov  ax,where
    mov  es,ax
    xor  di,di
    xor  ch,ch
    lds  si,temp
@Loop1 :
    lodsb
    mov  bl,al
    and  bl,$c0
    cmp  bl,$c0
    jne  @Single

    mov  cl,al
    and  cl,$3f
    lodsb
    rep  stosb
    jmp  @Fin
@Single :
    stosb
@Fin :
    cmp  di,63999
    jbe  @Loop1
    pop  ds
  end;
  freemem (temp,65535);
  close (f);
END;




Procedure Startup;
CONST header : String[42] = '(c) Asphyxia 1995 The Asphyxia File Packer';
VAR buf : String[43];
    f : file;
    ch:byte;
BEGIN
  Total:=0;
  Fillchar (infodat, sizeof(infodat), 0);
  assign (f,paramstr(0));
  reset (f,1);
  seek (f,filesize(f)-43);
  blockread (f,buf,43);
  if buf=header then BEGIN
    seek (f,filesize(f)-44-100);
    blockread (f,ch,1);
    blockread (f,infopos,sizeof(infopos));
    Pack:=TRUE;
  END else BEGIN
    Pack:=FALSE;
  END;
  close (f);
END;

BEGIN
  Startup;
END.