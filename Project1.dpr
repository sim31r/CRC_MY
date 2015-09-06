program Project1;

uses
  Forms,
  crc_my in 'crc_my.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
