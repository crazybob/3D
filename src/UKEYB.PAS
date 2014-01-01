Unit UKeyb;

(***********************************************************************

 Fast! Keyboard handler.

 Written by:

 Francesco E. Carucci
 Anarchy's Art

 s75926@galileo.polito.it

 ***********************************************************************)

interface

const ESC_KEY    = 1;

      UP_KEY     = 72;
      DOWN_KEY   = 80;
      LEFT_KEY   = 75;
      RIGHT_KEY  = 77;

      INS_KEY    = 82;
      DEL_KEY    = 83;
      HOME_KEY   = 71;
      END_KEY    = 79;
      PGUP_KEY   = 73;
      PGDN_KEY   = 81;

      CTRL_KEY   = 29;
      ALT_KEY    = 56;
      LSHIFT_KEY = 42;
      RSHIFT_KEY = 56;

      F1_KEY     = 59;
      F2_KEY     = 60;
      F3_KEY     = 61;
      F4_KEY     = 62;
      F5_KEY     = 63;
      F6_KEY     = 64;
      F7_KEY     = 65;
      F8_KEY     = 66;
      F9_KEY     = 67;
      F10_KEY    = 68;
      F11_KEY    = 87;
      F12_KEY    = 88;

      A_KEY      = 30;
      B_KEY      = 48;
      C_KEY      = 46;
      D_KEY      = 32;
      E_KEY      = 18;
      F_KEY      = 33;
      G_KEY      = 34;
      H_KEY      = 35;
      I_KEY      = 23;
      J_KEY      = 36;
      K_KEY      = 37;
      L_KEY      = 38;
      M_KEY      = 50;
      N_KEY      = 49;
      O_KEY      = 24;
      P_KEY      = 25;
      Q_KEY      = 16;
      R_KEY      = 19;
      S_KEY      = 31;
      T_KEY      = 20;
      U_KEY      = 22;
      V_KEY      = 47;
      X_KEY      = 45;
      Y_KEY      = 21;
      Z_KEY      = 44;
      A1_KEY     = 2;
      A2_KEY     = 3;
      A3_KEY     = 4;
      A4_KEY     = 5;
      A5_KEY     = 6;
      A6_KEY     = 7;
      A7_KEY     = 8;
      A8_KEY     = 9;
      A9_KEY     = 10;
      A0_KEY     = 11;

var Pressed: array[0..255] of boolean;

procedure InstallKeybHandler;
procedure RestoreKeybHandler;

function IsPressed(AKey: byte): boolean;
function IsReleased(AKey: byte): boolean;

implementation

Uses Dos;

var SaveInt09 : Pointer;

procedure KeybHandler; interrupt;
begin
  asm
    xor ax, ax
    in al, 60h

    mov di, ax
    and di, 0FF7Fh
    mov bx, 7
  end;

  inline(
    $0F/$A3/$D8/                 (* cf=bit 7 *)
    $D6                          (* if cf=0, al=0. if cf=1, al=0FFh *)
  );

  asm
    not al
    lea bx, Pressed
    mov [bx+di], al

    mov al, 020h
    out 020h, al
  end;
end;


procedure InstallKeybHandler;
begin
  GetIntVec($9,SaveInt09);
  SetIntVec($9,@KeybHandler);
end;

procedure RestoreKeybHandler;
begin
  SetIntVec($9, SaveInt09);
end;

function IsPressed(AKey: byte): boolean;
begin
  IsPressed:=Pressed[AKey];
end;

function IsReleased(AKey: byte): boolean;
begin
  IsReleased:=Not Pressed[AKey];
end;

begin
  FillChar(Pressed, 256, 0);
end.