unit crc_my;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Edit1: TEdit;
    Timer1: TTimer;
    Memo2: TMemo;
    CheckBox1: TCheckBox;
    procedure Timer1Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation
Const
  Iterations=1*1000*1000;
  array_work=8; //100
Var

  MagikConst: word;

  pr_min:word=1;
  pr_max:word=1000;


  OnWork:byte=0;
  GlobalErrorCount:Cardinal=0;

{$R *.dfm}

// очень стабильная работа
function Crc8_8(data, c_pr:byte):byte;
Var
 ti:word;
Begin

{$OVERFLOWCHECKS OFF}
{$RANGECHECKS OFF}
  ti:=data*211 + c_pr;   // $99, 3, 7, 1,211

  // умножение можно заменить сложением
  //ti:=c_pr;
  //ti := (ti shl 3) + data;
  //ti := (ti shl 3) + data;

  result:=ti XOR (ti SHR 8);
{$OVERFLOWCHECKS ON}
{$RANGECHECKS ON}
End;



function Crc16_8(data, c_pr:word):word;
Var
 ti:cardinal;

Begin
{$OVERFLOWCHECKS OFF}
{$RANGECHECKS OFF}
  ti:=c_pr + data*44111; //VERY GOOD!
  // 211 упрощенный вариант, если умножение 8 бит например

  // вариант без умножения!
  //ti:=c_pr;
  //ti := (ti shl 2) + ti + data;
  //ti := (ti shl 2) + ti + data;

  result:=ti XOR (ti SHR 8);

{$OVERFLOWCHECKS ON}
{$RANGECHECKS ON}
End;

function Crc16_16(data, c_pr:word):word;
Var
 ti:cardinal;

Begin
{$OVERFLOWCHECKS OFF}
{$RANGECHECKS OFF}
  ti:=c_pr + data*44111; //VERY GOOD!
  result:=ti XOR (ti SHR 16);   //8-16 magik

{$OVERFLOWCHECKS ON}
{$RANGECHECKS ON}
End;


// тут вычисляем порциями по 8 бит
Function CRC32_8(data, c_pr:int64):cardinal;
Var
 ti:int64;
Begin
{$OVERFLOWCHECKS OFF}
{$RANGECHECKS OFF}

  ti:=c_pr+data*$990C9AB5;
  ti:=ti XOR (ti SHR 16); // 8?
//  ti:=ti XOR $0000DDDD;
//  c_pr:=(c_pr XOR $CCAAAADD);
  result:=ti AND $FFFFFF;
{$OVERFLOWCHECKS ON}
{$RANGECHECKS ON}
end;

// тут вычисляем сразу порциями по 32 бита
Function CRC32_32(data, c_pr:int64):cardinal;
Var
 ti:int64;
 i:integer;
Begin
{$OVERFLOWCHECKS OFF}
{$RANGECHECKS OFF}
//ti:=c_pr;
//for I := 1 to 1 do // не оказывает зн влияния или вредно

//    ti:=ti+data*$DAAAAAA;
    ti:=c_pr+data*$990C9AB5; // test (range over)
    ti:=ti XOR (ti SHR 16); // очень важно
//    ti:=ti XOR $AAAAAAAA; // не оказывает зн влияния
//    ti:=(c_pr + ti); // разрушительно

//result:=ti AND $FFFF; //16 bit 65 kilo
result:=ti AND $FFFFFF; //24 bit 16 mega
//result:=ti AND $FFFFF; //20 bit 1 mega удобно для тестировани
{$OVERFLOWCHECKS ON}
{$RANGECHECKS ON}
end;

// очень стабильная работа
Function CRC64_8(data, c_pr:int64):int64;
Var
 ti:int64;
Begin
{$OVERFLOWCHECKS OFF}
{$RANGECHECKS OFF}
    ti:=c_pr+data*$5FB7D03C81AE5243;
//    ti:=c_pr*211+data*$5FB7D03C81AE5243;
    ti:=ti XOR (ti SHR 8); // очень важно 1..20

//result:=ti AND $FFFFFF; //24 bit 16 mega удобно для тестировани
result:=ti AND $FFFFF; //20 bit 1 mega удобно для тестировани
//result:=ti;
{$OVERFLOWCHECKS ON}
{$RANGECHECKS ON}
result:=ti AND $FFFFF;
end;

// VERY GOOD 64 bit box
Function CRC64_64(data, c_pr:int64):int64;
Var
 ti:int64;
Begin
{$OVERFLOWCHECKS OFF}
{$RANGECHECKS OFF}
  ti:=c_pr+data*$5FB7D03C81AE5243;
  ti:=ti XOR (ti SHR 32); // очень важно 32

//result:=ti AND $FFFFFF; //24 bit 16 mega удобно для тестировани
result:=ti AND $FFFFF; //20 bit 1 mega удобно для тестировани
{$OVERFLOWCHECKS ON}
{$RANGECHECKS ON}

end;

Procedure TestMain;
Var
 i,j, er_c, e_num:integer;
 a,b:Int64;
 crc_rx, crc_tx:int64;
// TeleTX8: array [1..array_work] of Byte;
// TeleRX8: array [1..array_work] of Byte;

// TeleTX16: array [1..array_work] of Word;
// TeleRX16: array [1..array_work] of Word;

// TeleTX32: array [1..array_work] of Cardinal;
// TeleRX32: array [1..array_work] of Cardinal;

 TeleTX64: array [1..array_work] of Int64;
 TeleRX64: array [1..array_work] of Int64;


 delta:integer;
 odin_massiv:cardinal;
Begin
OnWork:=1;
randomize;
// generator
er_c:=0;
odin_massiv:=0;
for I := 1 to Iterations do // число телеграм
begin
//crc:=0;
  if (I mod 10) = 1 then // оптимизация цикла, особенно если телеграмма длинная
  for j := 1 to array_work do // число байт в телеграмме
  begin
    // 8 bit
    //a:=Random($FF+1);
    //TeleTX8[j] :=a;
    //TeleRX8[j]:=a;

    // 16 bit
    //a:=Random($FFFF+1);
    //TeleTX16[j] :=a;
    //TeleRX16[j]:=a;

    // ~32 bit
    //a:=Random(MaxInt);
    //TeleTX32[j]:=a;
    //TeleRX32[j]:=a;

    // ~64 bit
    a:=Random(MaxInt);
    a:=a SHL 32;
    a:=a +Random(MaxInt);
    TeleTX64[j]:=a;
    TeleRX64[j]:=a;
  end;

  // *************** add error ***************
  repeat
  for j := 1 to random(10)+1 do //************
    Begin
     e_num:=Random(array_work)+1;
     a:=random(64); // 8 16 32 64 !!!
     b:=1 SHL a;
     TeleTX64[e_num]:=TeleRX64[e_num] XOR b; // !!!
    end;

  delta:=0;
  for j := 1 to array_work do // число байт в телеграмме
    if TeleRX64[j]<>TeleTX64[j] then
      inc (delta);

  until (delta>0) or (Form1.CheckBox1.Checked=true);


  if delta=0 then
    inc(odin_massiv);


  // test CRC
  crc_rx:=0;
  crc_tx:=0;

  for j := 1 to array_work do // число байт в телеграмме
  begin

    //crc_tx:=CRC32_32 (TeleTX32[j],crc_tx);
    //crc_rx:=CRC32_32 (TeleRX32[j],crc_rx);

    //crc_old:=CRC32My (tele[j],crc_old); // VERY GOOD!
    //crc:=CRC32My (tele2[j],crc);

    //crc_old:=CRC16My (tele[j],crc_old);
    //crc:=CRC16My (tele2[j],crc);

    //crc_tx:=CRC16_16 (TeleTX16[j],crc_tx);
    //crc_rx:=CRC16_16 (TeleRX16[j],crc_rx);


    //crc_old:=CRC8My (tele[j],crc_old);
    //crc:=CRC8My (tele2[j],crc);

    // 64 bit array
    crc_tx:=CRC64_64 (TeleTX64[j],crc_tx);
    crc_rx:=CRC64_64 (TeleRX64[j],crc_rx);


  end;

//  if delta>=1 then массивы никогда не идентичны
  if crc_tx=crc_rx then
  Begin
    inc(er_c);
    inc(GlobalErrorCount);
    if er_c<=-1 then // пример ошибки  // -1 не нужна
    begin
      form1.memo1.Lines.add('************');
      form1.memo1.Lines.add('Пропущенна ошибка');
      form1.memo1.Lines.add('i= '+IntToStr(i));
      form1.memo1.Lines.add('crc= '+IntToStr(crc_rx) );
      form1.memo1.Lines.add('crc_old= '+IntToStr(crc_tx) );
      form1.memo1.Lines.add('error= '+IntToStr(b) );
      form1.memo1.Lines.add('delta= '+IntToStr(delta) );
    end;
  end;
// if (i mod (1000*1000) )=0 then
//       form1.memo1.Lines.add('I=' + IntToStr(i div (1000*1000)) );

end;
//  form1.memo1.Lines.add('************');
//  form1.memo1.Lines.add('пропущенно ошибок er_c= '+IntToStr(er_c) );
//  form1.memo1.Lines.add('циклов  '+IntToStr( Iterations ));
//  form1.memo1.Lines.add('%  '+FloatToStr( 100*er_c/Iterations ));
  if (er_c>=1) then
  Begin
    form1.memo1.Lines.add('1 : '+IntToStr( round(Iterations/(er_c)) ));
    form1.memo2.Lines.add('1 : '+IntToStr( round(Iterations/(er_c)) ));
    form1.memo2.Lines.add('error on: '+IntToStr(MagikConst) );
  end
  else
    form1.memo1.Lines.add('ok '+IntToStr(MagikConst) );

//  form1.memo1.Lines.add('MagikConst=' + IntToStr(MagikConst) );
//  form1.memo1.Lines.add(IntToStr(MagikConst)+';'+IntToStr(er_c)  );
    if odin_massiv >= 1 then
    form1.memo1.Lines.add('одинаковых телеграм = ' + IntToStr(odin_massiv));

OnWork:=0;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  Timer1.Enabled:=True;
  pr_max:=StrToInt(form1.Edit1.Text);
  GlobalErrorCount:=0;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  i,j,r,ti:integer;
  n:integer;
begin
// все таблицы умпешно заменены умножением!!!

n:=256; //16 256
for I := 1 to n do
Begin
end;
    //zam[i]:=i-1;

for I := 1 to n do
begin
//  r:=random(n-1)+1;
//  ti:=zam[r];
//  zam[r]:=zam[i];
//  zam[i]:=ti;
end;

  MagikConst:= pr_min;


end;

procedure TForm1.Timer1Timer(Sender: TObject);
//Var
begin
if OnWork=0 then
Begin

  edit1.Text:=IntToStr(MagikConst);
  TestMain;
  if MagikConst>=pr_max then
  begin
    Timer1.Enabled:=False;
    MagikConst:=pr_min;
    memo1.Lines.Add('end work, GlobalErrorCount= ' + IntToStr(GlobalErrorCount));
  end
  else
    inc(MagikConst);
end;

end;

end.
