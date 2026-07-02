unit testdll;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Memo2: TMemo;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
function Pack(Input: PByte; Output: PByte; Size:Integer): Integer; stdcall; external 'GeeGui.dll';
function UnPack(Input: PByte; Output: PByte; Size:Integer): Integer; stdcall; external 'GeeGui.dll';
implementation

{$R *.dfm}
function BytesToHex(const Buf; const Size: Integer): string;
const
  HexChars: array[0..15] of Char = '0123456789ABCDEF';
var
  P: PByte;
  I: Integer;
begin
  SetLength(Result, Size * 2);
  P := @Buf;
  for I := 0 to Size - 1 do
  begin
    Result[I * 2 + 1] := HexChars[P^ shr 4];   // 高4位
    Result[I * 2 + 2] := HexChars[P^ and $0F];  // 低4位
    Inc(P);
  end;
end;
procedure TForm1.Button1Click(Sender: TObject);
var
  Input : array[0..65535] of Byte;
  Output : array[0..65535] of Byte;
  HexStr: string;
  Len: Integer;
begin
  Memo2.Text := '';
  HexStr := Memo1.Lines.Text;
  HexStr := StringReplace(HexStr, #13#10, '', [rfReplaceAll]);
  Len := Length(HexStr);
  if Len mod 2 <> 0 then
    begin
      ShowMessage('错误：十六进制字符串长度必须为偶数！');
      Exit;
    end;
  Len := HexToBin(PChar(HexStr), @Input, Len div 2);
  UnPack(@Input, @Output, Len);
  HexStr := BytesToHex(Output, Len);
  Memo2.Text := HexStr;

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Position := poScreenCenter;
end;



procedure TForm1.Button2Click(Sender: TObject);
var
  Input : array[0..65535] of Byte;
  Output : array[0..65535] of Byte;
  HexStr: string;
  Len: Integer;
begin
  Memo2.Text := '';
  HexStr := Memo1.Lines.Text;
  HexStr := StringReplace(HexStr, #13#10, '', [rfReplaceAll]);
  Len := Length(HexStr);
  if Len mod 2 <> 0 then
    begin
      ShowMessage('错误：十六进制字符串长度必须为偶数！');
      Exit;
    end;
  Len := HexToBin(PChar(HexStr), @Input, Len div 2);
  Pack(@Input, @Output, Len);
  HexStr := BytesToHex(Output, Len);
  Memo2.Text := HexStr;

end;

end.


