program test;

uses tmems,crt;

var i, a, b : integer;
    faddr : word;

begin
     clrscr;
     pagestatus(a,b);
     writeln('EMS ver. ' + get_version_number + ' detected.');
     writeln(a, ' pages total available EMS memory, ', b, ' pages free.');
     faddr := get_frame_address;
     writeln('Page frame located at segment ', faddr,'.');
     allocate_pages(10);
     writeln(4, ' pages successfully allocated.');
     writeln;
     for i := 1 to 9 do begin
         map_page(i, 0);
         mem[faddr:100] := i;
         writeln(i);
     end;
     writeln;
     for i := 9 downto 1 do begin
         map_page(i, 0);
         writeln(mem[faddr:100]);
     end;
     readln;
     deallocate_pages;
end.