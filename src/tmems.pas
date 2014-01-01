Unit TMEMS;

INTERFACE

Var Handle : integer;
{by declaring this a public variable I assume that you will only be allocating
 EMS pages ONCE during a program.
 It saves you from having to pass the handle to a couple of functions every
 time you call them.
 But then you can't fx. allocate 10 pages at the beginning of the program -
 and then allocate 15 more later.
 If you wan't to do that you'll have to rewrite a couple of the routines so
 that the correct handle must be passed to them when called.}

Function Hex_String (Number: Integer): String;
Function EMS_AreYouThere : Boolean;
Procedure Pagestatus(Var Total, Available: Integer);
Procedure Allocate_Pages(Needed: Integer);
Procedure Map_Page(Logical : Integer;Physical : byte);
Function Get_Frame_Address : Integer;
Procedure Deallocate_Pages;
Function Get_Version_Number : string;

IMPLEMENTATION

Function Hex_String (Number: Integer): string;
   Function Hex_Char (Number: Integer): Char;
     Begin
       If Number < 10 then  Hex_Char := Char (Number + 48)
        else Hex_Char := Char (Number + 55);
     end; { Function Hex_char }

   Var
    S: string;
   Begin
    S := '';
    S := Hex_Char ((Number shr 1) div 2048);
    Number := (((Number shr 1) mod 2048) shl 1) + (Number and 1);
    S := S + Hex_Char (Number div 256);
    Number := Number mod 256;
    S := S + Hex_Char (Number div 16);
    Number := Number mod 16;
    S := S + Hex_Char (Number);
    Hex_String := S + 'h';
   end; { Function Hex_String }

{uhm... this procedure is ripped from the file ems4spec.doc }


 {***********************}

Function EMS_AreYouThere : Boolean;
  Var
   EMS_Name          : string[8];
   Returned_Name     : string[8];
   Position          : integer;
   segm              : word;

  Begin
   Returned_Name := '';
   EMS_Name      := 'EMMXXXX0';     {this is the ID string that SHOULD appear
                                     in the code segment of int 67h}
    asm
     mov ah,35h
     mov al,67h
     int 21h
     mov segm,es
    end;

   For Position := 0 to 7 do
     Returned_Name := Returned_Name + Chr (mem[segm:Position + $0A]);

   {This call will return the segment address where the ID string SHOULD
    be.
    If the ID string is there it'll be placed from offset $0A to $11}


   If Returned_Name = EMS_Name
         then EMS_AreYouThere := true
         else EMS_AreYouThere := false;
  end; { Function EMS_AreYouThere }


    {*******************}

Procedure Pagestatus(Var Total, Available: Integer);
  Var
   HowManyInAll     : word;
   HowManyAvailable : word;
  Begin
    asm
     mov ah,42h        {this is EMS function nr. 42h }
     int 67h
     mov HowManyAvailable,bx
     mov HowManyInAll,dx
    end;
   Available:=HowManyAvailable;
   Total:=HowManyInAll;
  end; { Function Pagestatus }


{This Procedure is nice when you want to know if there is enough free EMS
 memory to run your program.}


     {*************}

Procedure Allocate_Pages(Needed: Integer);
Assembler;
     asm
      mov ah,43h             {this is EMS function nr. 43h}
      mov bx,[Needed]
      int 67h
      mov [handle],dx        {NOT very nice... but heck... I like it this way}
     end; { Function Allocate_Pages }

{When you run this procedure you allocate a certain amount of EMS pages.
 A handle is then assigned to these pages. Those of you who code TASM know of
 handles from file handling routines.
 But those of you who just use Pascal are'nt used to having a number assigned
 to a file or a piece of memory. Well.. its basicly the same thing as when you
 use the Assign comand in TP. Here you assign a string - namely the filename -
 to a var of the type : file (or file of bla bla bla). Later you use this var
 when you want to manipulate with the file.
 Same thing here - don't think about it.}


{*****************}

procedure Map_Page(Logical : Integer;Physical : byte);
Assembler;
      asm
       mov ah,44h                   {EMS function nr. 44h}
       mov dx,[handle]              {humm... NO comments :) }
       mov bx,[logical]
       mov al,[Physical]
       int 67h
      end; { Function Map_Page }

{This procedure sets a window in the page frame to a certain logical page
 in EMS memory.
 From now on, when you manipulate with the physical page in the page frame
 you manipulate with the mapped logical page in EMS}

{****************}


Function Get_Frame_Address : Integer;
Assembler;
 asm
  mov ah,41h    {EMS function nr. 41h}
  int 67h
  mov ax,bx
 end;

{This function returns the segment address of the page frame.
 Now this one is VERY!! important. When mapping logical pages into physical
 pages the programmer needs to know where to address the physical pages.
 Each physical page in the page frame has its own segement address.
 Physical page nr. 0 has THE SAME ADDRESS AS THE PAGE FRAME.
 From then on the physical pages are $400 (1Kb) apart - ie :
  (say that the page frame address is $D000 - it often is )

     physical page nr.         segment address
           0                      $D000
           1                      $D400
           2                      $D800
           3                      $DC00
           4                      $E000
}

{*****************}

Procedure Deallocate_Pages;
Assembler;
     asm
      mov ah,45h
      mov dx,[handle]      {humm... keeps popping up everywhere   }
      int 67h
     end; { Procedure Deallocate_Pages }

{This returns the allocated EMS pages to the memory pool.
 If you don't call this when closing a program down the EMS
 memory will be useless to all other programs too }


{************}

Function Get_Version_Number : String;
  Var
   Integer_Part, Fractional_Part: byte;

  Begin
    asm
     mov ah,46h
     int 67h
     cmp ah,0
     jne @error
     mov bl,al
     shr bl,4
     add bl,48
     mov Integer_part,bl
     mov bl,al
     and bl,$F
     add bl,48
     mov Fractional_Part,bl
  @error :
    end;
   Get_version_number:=chr(Integer_part)+'.'+chr(Fractional_part);
  end; { Function Get_Version_Number }

begin
end.