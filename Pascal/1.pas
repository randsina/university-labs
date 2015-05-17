program z1;
const
  n=8;
var
  i,k,m:integer;
  a,c:array [1..n] of integer;
begin
  k:=0;
  for i:=1 to n do
  begin
    read(a[i]);
  end;
  for i:=1 to n do
  begin
    read(m);
    if(m > a[i]) then
      c[i]:=m
    else
    begin
      c[i]:=a[i];
      inc(k);
    end;
    writeln(c[i]);
  end;
  writeln(k);
end.
