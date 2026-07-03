library GeeGui;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  SysUtils,windows,Classes, Dialogs;
// 定义一个函数指针类型，接受两个 Integer，返回 Integer
type
  TGeeFun = function(Input: PByte; Output: PByte; Size:Integer; Key: PByte; IV: PByte): Integer;

const
  KeyData : array[0..147] of Byte = (
    $b8,$e8,$df,$b0,$78,$59,$f7,$52,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,
    $8f,$8f,$8f,$8f,$10,$c0,$90,$20,$83,$48,$4d,$00,$60,$d0,$80,$c8,
    $04,$8d,$41,$00,$a0,$8c,$c8,$a0,$08,$8a,$05,$05,$98,$a4,$10,$88,
    $41,$06,$42,$03,$40,$2c,$48,$28,$44,$07,$0a,$09,$48,$28,$c4,$08,
    $81,$c4,$0d,$42,$9c,$48,$48,$94,$80,$41,$09,$0a,$2c,$54,$24,$00,
    $c1,$01,$04,$c3,$34,$94,$04,$0c,$03,$40,$8d,$82,$14,$14,$40,$50,
    $80,$0e,$82,$88,$00,$fc,$24,$00,$0a,$8c,$82,$42,$a8,$88,$00,$54,
    $02,$ce,$48,$00,$8c,$a8,$24,$60,$ca,$43,$00,$84,$4c,$70,$10,$50,
    $48,$03,$ce,$00,$70,$30,$28,$20,$8c,$09,$4d,$04,$5c,$54,$b0,$20,
    $ce,$08,$01,$01);
var
  BaseAddr:HMODULE;
  GeeUnPack:TGeeFun;
  GeePack:TGeeFun;
{$R *.res}
function CloseDlg(): Integer; stdcall; external 'GuiEdit1.dll';
function GetDllBaseAddress(const DllName: string): HMODULE;
begin
  // GetModuleHandle 返回 HMODULE，它本质上就是基地址
  Result := GetModuleHandle(PChar(DllName));
  // 如果返回 nil，说明 DLL 未加载或名称错误
  if Result = 0 then
    RaiseLastOSError;
end;

function Pack(Input: PByte; Output: PByte; Size:Integer): Integer; stdcall;
var
  KeyDataCopy: array[0..147] of Byte;
begin
  Move(KeyData, KeyDataCopy, SizeOf(KeyData));
  Result := GeePack(Input, Output, Size, @KeyDataCopy, @KeyDataCopy[20]);
end;

function UnPack(Input: PByte; Output: PByte; Size:Integer): Integer; stdcall;
var
  KeyDataCopy: array[0..147] of Byte;
begin
  Move(KeyData, KeyDataCopy, SizeOf(KeyData));
  Result := GeeUnPack(Input, Output, Size, @KeyDataCopy, @KeyDataCopy[20]);
end;

exports
  Pack, UnPack, CloseDlg;

begin
  try
    BaseAddr := GetDllBaseAddress('GuiEdit1.dll');
    GeeUnPack := TGeeFun(BaseAddr + $101984);
    GeePack := TGeeFun(BaseAddr + $1018C4);
  except
    on E: Exception do
      ShowMessage(E.Message);
  end
end.
