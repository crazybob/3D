program map;

const mxpoly = 288;

type
    pointtype = record
        x, y, z: longint;
        end;
    polygon = record
        pt : array[1..5] of pointtype;
        {points 1..4 are points on the polygon, while 5 is the center}
        tex : byte;
        {texture}
        end;

var
   box : array[1..mxpoly] of polygon;
   f : text;
   i, i2 : integer;
   temp : pointtype;
begin
    for i := 1 to 16 do begin
             box[i].pt[1].x := i * 50 - 450;
             box[i].pt[1].y := -25;
             box[i].pt[1].z := 160;

             box[i].pt[2].x := i * 50 + 50 - 450;
             box[i].pt[2].y := -25;
             box[i].pt[2].z := 160;

             box[i].pt[3].x := i * 50 + 50 - 450;
             box[i].pt[3].y := 25;
             box[i].pt[3].z := 130;

             box[i].pt[4].x := i * 50 - 450;
             box[i].pt[4].y := 25;
             box[i].pt[4].z := 130;

             box[i].pt[5].x := i * 50 + 25 - 450;
             box[i].pt[5].y := 13;
             box[i].pt[5].z := 145;

             box[i].tex := 2;
         end;

     for i := 17 to 32 do begin
             box[i].pt[1].x := (i-16) * 50 - 450;
             box[i].pt[1].y := 25;
             box[i].pt[1].z := 130;

             box[i].pt[2].x := (i-16) * 50 + 50 - 450;
             box[i].pt[2].y := 25;
             box[i].pt[2].z := 130;

             box[i].pt[3].x := (i-16) * 50 + 50 - 450;
             box[i].pt[3].y := 25;
             box[i].pt[3].z := 80;

             box[i].pt[4].x := (i-16) * 50 - 450;
             box[i].pt[4].y := 25;
             box[i].pt[4].z := 80;

             box[i].pt[5].x := (i-16) * 50 + 25  - 450;
             box[i].pt[5].y := 25;
             box[i].pt[5].z := 105;

             box[i].tex := 6;
         end;

     for i := 33 to 48 do begin
             box[i].pt[1].x := (i-32) * 50 - 450;
             box[i].pt[1].y := 25;
             box[i].pt[1].z := 80;

             box[i].pt[2].x := (i-32) * 50 + 50 - 450;
             box[i].pt[2].y := 25;
             box[i].pt[2].z := 80;

             box[i].pt[3].x := (i-32) * 50 + 50 - 450;
             box[i].pt[3].y := 30;
             box[i].pt[3].z := 80;

             box[i].pt[4].x := (i-32) * 50 - 450;
             box[i].pt[4].y := 30;
             box[i].pt[4].z := 80;

             box[i].pt[5].x := (i-32) * 50 + 25  - 450;
             box[i].pt[5].y := 25;
             box[i].pt[5].z := 55;

             box[i].tex := 1;
         end;

     for i := 49 to 64 do begin
             box[i].pt[1].x := (i-48) * 50 + 50 - 450;
             box[i].pt[1].y := 30;
             box[i].pt[1].z := 80;

             box[i].pt[2].x := (i-48) * 50 + 50 - 450;
             box[i].pt[2].y := 30;
             box[i].pt[2].z := 30;

             box[i].pt[3].x := (i-48) * 50 - 450;
             box[i].pt[3].y := 30;
             box[i].pt[3].z := 30;

             box[i].pt[4].x := (i-48) * 50 - 450;
             box[i].pt[4].y := 30;
             box[i].pt[4].z := 80;

             box[i].pt[5].x := (i-48) * 50 + 25  - 450;
             box[i].pt[5].y := 30;
             box[i].pt[5].z := 55;

             box[i].tex := 4;
         end;

    for i := 65 to 80 do begin
             box[i].pt[1].x := (i-64) * 50 - 450;
             box[i].pt[1].y := -75;
             box[i].pt[1].z := 160;

             box[i].pt[2].x := (i-64) * 50 + 50 - 450;
             box[i].pt[2].y := -75;
             box[i].pt[2].z := 160;

             box[i].pt[3].x := (i-64) * 50 + 50 - 450;
             box[i].pt[3].y := -25;
             box[i].pt[3].z := 160;

             box[i].pt[4].x := (i-64) * 50 - 450;
             box[i].pt[4].y := -25;
             box[i].pt[4].z := 160;

             box[i].tex := 2;
         end;

    for i := 81 to 96 do begin
             box[i].pt[1].x := (i-80) * 50 - 450;
             box[i].pt[1].y := -125;
             box[i].pt[1].z := 130;

             box[i].pt[2].x := (i-80) * 50 + 50 - 450;
             box[i].pt[2].y := -125;
             box[i].pt[2].z := 130;

             box[i].pt[3].x := (i-80) * 50 + 50 - 450;
             box[i].pt[3].y := -75;
             box[i].pt[3].z := 160;

             box[i].pt[4].x := (i-80) * 50 - 450;
             box[i].pt[4].y := -75;
             box[i].pt[4].z := 160;

             box[i].tex := 2;
         end;

             box[97].pt[1].x := 50 - 450;
             box[97].pt[1].y := -125;
             box[97].pt[1].z := 80;

             box[97].pt[2].x := 50 - 450;
             box[97].pt[2].y := -125;
             box[97].pt[2].z := 130;

             box[97].pt[3].x := 50 - 450;
             box[97].pt[3].y := -75;
             box[97].pt[3].z := 160;

             box[97].pt[4].x := 50 - 450;
             box[97].pt[4].y := -75;
             box[97].pt[4].z := 80;

             box[97].tex := 6;

             box[98].pt[1].x := 50 - 450;
             box[98].pt[1].y := -75;
             box[98].pt[1].z := 80;

             box[98].pt[2].x := 50 - 450;
             box[98].pt[2].y := -75;
             box[98].pt[2].z := 160;

             box[98].pt[3].x := 50 - 450;
             box[98].pt[3].y := -25;
             box[98].pt[3].z := 160;

             box[98].pt[4].x := 50 - 450;
             box[98].pt[4].y := -25;
             box[98].pt[4].z := 80;

             box[98].tex := 6;


             box[99].pt[1].x := 50 - 450;
             box[99].pt[1].y := -25;
             box[99].pt[1].z := 80;

             box[99].pt[2].x := 50 - 450;
             box[99].pt[2].y := -25;
             box[99].pt[2].z := 160;

             box[99].pt[3].x := 50 - 450;
             box[99].pt[3].y := 25;
             box[99].pt[3].z := 130;

             box[99].pt[4].x := 50 - 450;
             box[99].pt[4].y := 25;
             box[99].pt[4].z := 80;

             box[99].tex := 6;

         for i := 97 to 99 do begin
             box[i + 3] := box[i];
             box[i + 3].pt[1].x := 16 * 50 + 50 - 450;
             box[i + 3].pt[2].x := 16 * 50 + 50 - 450;
             box[i + 3].pt[3].x := 16 * 50 + 50 - 450;
             box[i + 3].pt[4].x := 16 * 50 + 50 - 450;
         end;

             box[103].pt[1].x := 50 - 450;
             box[103].pt[1].y := -25;
             box[103].pt[1].z := 30;

             box[103].pt[2].x := 50 - 450;
             box[103].pt[2].y := -25;
             box[103].pt[2].z := 80;

             box[103].pt[3].x := 50 - 450;
             box[103].pt[3].y := 30;
             box[103].pt[3].z := 80;

             box[103].pt[4].x := 50 - 450;
             box[103].pt[4].y := 30;
             box[103].pt[4].z := 30;

             box[103].tex := 5;

             box[104].pt[1].x := 50 - 450 - 75;
             box[104].pt[1].y := -25;
             box[104].pt[1].z := 30;

             box[104].pt[2].x := 50 - 450;
             box[104].pt[2].y := -25;
             box[104].pt[2].z := 80;

             box[104].pt[3].x := 50 - 450;
             box[104].pt[3].y := 30;
             box[104].pt[3].z := 80;

             box[104].pt[4].x := 50 - 450 - 75;
             box[104].pt[4].y := 30;
             box[104].pt[4].z := 30;

             box[104].tex := 6;

             box[105].pt[1].x := 50 - 450;
             box[105].pt[1].y := -125;
             box[105].pt[1].z := 80;

             box[105].pt[2].x := 50 - 450;
             box[105].pt[2].y := -25;
             box[105].pt[2].z := 80;

             box[105].pt[3].x := 50 - 450;
             box[105].pt[3].y := -25;
             box[105].pt[3].z := 30;

             box[105].pt[4].x := 50 - 450;
             box[105].pt[4].y := -125;
             box[105].pt[4].z := 30;

             box[105].tex := 1;

             box[106].pt[1].x := 50 - 450 - 75;
             box[106].pt[1].y := -25;
             box[106].pt[1].z := 30;

             box[106].pt[2].x := 50 - 450;
             box[106].pt[2].y := -25;
             box[106].pt[2].z := 80;

             box[106].pt[3].x := 50 - 450;
             box[106].pt[3].y := -25;
             box[106].pt[3].z := 80;

             box[106].pt[4].x := 50 - 450;
             box[106].pt[4].y := -25;
             box[106].pt[4].z := 30;

             box[106].tex := 6;

             box[107].pt[1].x := 50 - 450;
             box[107].pt[1].y := 30;
             box[107].pt[1].z := 80;

             box[107].pt[2].x := 50 - 450;
             box[107].pt[2].y := 30;
             box[107].pt[2].z := 80;

             box[107].pt[3].x := 50 - 450;
             box[107].pt[3].y := 30;
             box[107].pt[3].z := 30;

             box[107].pt[4].x := 50 - 450 - 75;
             box[107].pt[4].y := 30;
             box[107].pt[4].z := 30;

             box[107].tex := 4;

             for i := 103 to 107 do begin
                 box[i + 5] := box[i];
                 box[i + 5].pt[1].x := abs(box[i].pt[1].x);
                 box[i + 5].pt[2].x := abs(box[i].pt[2].x);
                 box[i + 5].pt[3].x := abs(box[i].pt[3].x);
                 box[i + 5].pt[4].x := abs(box[i].pt[4].x);
             end;

     for i := 113 to 128 do begin
             box[i].pt[1].x := (i-112) * 50 - 450;
             box[i].pt[1].y := -125;
             box[i].pt[1].z := 130;

             box[i].pt[2].x := (i-112) * 50 + 50 - 450;
             box[i].pt[2].y := -125;
             box[i].pt[2].z := 130;

             box[i].pt[3].x := (i-112) * 50 + 50 - 450;
             box[i].pt[3].y := -125;
             box[i].pt[3].z := 80;

             box[i].pt[4].x := (i-112) * 50 - 450;
             box[i].pt[4].y := -125;
             box[i].pt[4].z := 80;

             box[i].pt[5].x := (i-112) * 50 + 25  - 450;
             box[i].pt[5].y := -125;
             box[i].pt[5].z := 105;

             box[i].tex := 2;
         end;

     for i := 129 to 144 do begin
             box[i].pt[1].x := (i-128) * 50 - 450;
             box[i].pt[1].y := -125;
             box[i].pt[1].z := 80;

             box[i].pt[2].x := (i-128) * 50 + 50 - 450;
             box[i].pt[2].y := -125;
             box[i].pt[2].z := 80;

             box[i].pt[3].x := (i-128) * 50 + 50 - 450;
             box[i].pt[3].y := -125;
             box[i].pt[3].z := 30;

             box[i].pt[4].x := (i-128) * 50 - 450;
             box[i].pt[4].y := -125;
             box[i].pt[4].z := 30;

             box[i].tex := 1;
         end;

         for i := 1 to 144 do
             for i2 := 1 to 4 do
                 box[i].pt[i2].z := box[i].pt[i2].z - 30;

         for i := 1 to 144 do
             box[i + 144] := box[i];

         for i := 145 to 288 do
             for i2 := 1 to 4 do
                 box[i].pt[i2].z := -box[i].pt[i2].z;

         for i := 145 to 288 do
             begin
             temp := box[i].pt[1];
             box[i].pt[1] := box[i].pt[2];
             box[i].pt[2] := temp;
             temp := box[i].pt[3];
             box[i].pt[3] := box[i].pt[4];
             box[i].pt[4] := temp;
             end;

         assign(f, 'map.pol');
         rewrite(f);

         for i := 1 to mxpoly do begin
             writeln(f, box[i].tex);
             for i2 := 1 to 4 do
                 writeln(f, box[i].pt[i2].x, ' ', box[i].pt[i2].y, ' ',
                            box[i].pt[i2].z);
             writeln(f);
         end;

         close(f);
end.