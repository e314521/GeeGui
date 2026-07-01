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
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
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
const
  Input1 : array[0..39] of Byte = (
    $F8, $66, $72, $F0, $41, $16, $FE, $45, $D3, $8F, $8F, $8F, $31, $8F, $8F, $8F, 
	  $9F, $8F, $8F, $8F, $EE, $4F, $4B, $D9, $EF, $BA, $42, $5F, $D9, $8F, $8F, $8F,
	  $31, $8F, $8F, $8F, $9F, $8F, $8F, $8F);
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

end.
