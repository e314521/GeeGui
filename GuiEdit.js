// 第一步 获取GuiEdit.dll的句柄
var GuiEdit = Process.findModuleByName("GuiEdit.dll");
// 第二步 获取GuiEdit.dll的UnPackUi函数地址
var UnPackPtr = GuiEdit.base.add(0x101984)
// 第三步 hook UnPackUi函数
function dumpKey() {

    function compareArrayBuffers(buf1, buf2) {
        // 1. 首先检查长度是否一致
        if (buf1.byteLength !== buf2.byteLength) {
            return false;
        }

        // 2. 创建 Uint8Array 视图
        const view1 = new Uint8Array(buf1);
        const view2 = new Uint8Array(buf2);

        // 3. 逐字节比较
        for (let i = 0; i < view1.length; i++) {
            if (view1[i] !== view2[i]) {
                console.log("不同位置: ", i, " 值1: ", view1[i], " 值2: ", view2[i]);
                return false;
            }
        }
        return true;
    }
    function arrayBufferToHex(buffer) {
        const bytes = new Uint8Array(buffer);
        return Array.prototype.reduce.call(bytes, (acc, x, index) => {
            if (index == 0) {
                acc = '  KeyData : array[0..147] of Byte = (\n    '
            }
            // 将当前字节转换为 "$xx" 格式
            const hex = "$" + ('00' + x.toString(16)).slice(-2);
            acc += hex;
            // 如果不是第一个字节，需要添加逗号分隔符
            if (index !== bytes.length - 1) {
                acc += ',';
            }
            if (index == bytes.length - 1) {
                acc += ');';
            }else if ((index + 1) % 16 === 0) {
                acc += '\n    ';
            }
            return acc;
        }, '');
    }


    var keys = []
    Interceptor.attach(UnPackPtr, {
        onEnter: function (args) {
            // 获取参数
            this.arg1 = this.context.eax;
            this.arg2 = this.context.edx;
            this.arg3 = this.context.ecx;
            this.arg4 = args[1];
            this.arg5 = args[0];
            // 打印参数
            var find = false
            var key_bytes = this.arg4.readByteArray(148)
            if (keys.length == 0) {
                keys.push(key_bytes)
                find = true
            } else {
                for (var i = 0; i < keys.length; i++) {
                    if (compareArrayBuffers(key_bytes, keys[i])){
                        return
                    }
                }
            }
            console.log(arrayBufferToHex(key_bytes))
        },
        onLeave: function (retval) {
        }
    })
}
dumpKey()



// var GuiDll = Process.findModuleByName("dll.dll");

// var PackUiPtr = GuiDll.findExportByName("PackUi")
// var CloseDlgPtr = GuiDll.findExportByName("CloseDlg")
// const PackUi = new NativeFunction(PackUiPtr, 'void', ['int', 'int', 'int', 'int']);
// const CloseDlg = new NativeFunction(CloseDlgPtr, 'int', []);







// function hexToUint8Array(hexStr) {
//     // 1. 去除可能存在的空格、0x 前缀，并转为小写（容错处理）
//     var cleanHex = hexStr.replace(/\s/g, '').replace(/^0x/i, '').toLowerCase();

//     // 2. 每两个字符切分，转为 16 进制数字
//     var bytes = cleanHex.match(/.{1,2}/g).map(byte => parseInt(byte, 16));
//     var uint8 = new Uint8Array(bytes);
//     var arrayBuffer = new ArrayBuffer(uint8.length);
//     let newUint8 = new Uint8Array(arrayBuffer);
//     newUint8.set(uint8);

//     // 3. 转为 Uint8Array
//     return arrayBuffer;
// }


// var p = Memory.alloc(0x30);
// var uint8Arr = hexToUint8Array("9F50566BD7C11CCE9E8F8F8F8F8A8F8F4F8C8F8FB5B5B2EB6CF206E3978F8F8FE3804E834D8C8F8F");
// p.writeByteArray(uint8Arr)

// //PackUi(0, p, p, 0x28)
// console.log(CloseDlg())
// console.log(Process.findModuleByName("GuiEdit.dll").base.add(0x101A98))
// console.log(Process.findModuleByName("GuiEdit.dll").base.add(0x101984))



// // Interceptor.replace(Process.findModuleByName("GuiEdit.dll").base.add(0x101984), new NativeCallback(function () {
// //     console.log("hooked")
// //     var arg1 = this.context.eax;
// //     var arg2 = this.context.edx;
// //     var arg3 = this.context.ecx;
// //     console.log(arg1,arg2, arg3)
// //     console.log(hexdump(arg1))
// // }, 'void', []));


// Interceptor.attach(Process.findModuleByName("GuiEdit.dll").base.add(0x101984), {
//     onEnter: function (args) {
//         this.arg1 = this.context.eax;
//         this.arg2 = this.context.edx;
//         this.arg3 = this.context.ecx;
//         this.arg4 = args[0];
//         console.log(hexdump(this.arg1))
//     },
//     onLeave: function (retval) {
//         try {
//             console.log("[*] " + "0x06221984" + " called arg1:" + this.arg1, " arg2:" + this.arg2 + ", arg3:" + this.arg3 + ", arg4:" + this.arg4);
//             console.log(hexdump(this.arg1))
//         } catch (e) {
//             console.log("[!] Error reading string arguments: " + e.message);
//         }

//     }
// });

// /*
// Interceptor.attach(Process.findModuleByName("GuiEdit.dll").base.add(0x101440), {
//     onEnter: function(args) {
//         // int *__usercall sub_6221440@<eax>(int *a1@<eax>, int *a2@<edx>, int a3@<ecx>)
//         // 注意：这是 __usercall，寄存器传参
//         this.a1 = this.context.eax; // 密文指针 (输入)
//         this.a2 = this.context.edx; // 明文指针 (输出)
//         this.a3 = this.context.ecx; // 轮密钥指针

//         // 读取 16 字节密文
//         console.log("[SM4 Decrypt] Ciphertext (a1):");
//         console.log(hexdump(this.a1, { length: 16 }));

//         // 读取前几个轮密钥 (SM4 需要 32 个 32bit 轮密钥，共 128 字节)
//         console.log("[SM4 Decrypt] Round Keys (a3):");
//         console.log(hexdump(this.a3, { length: 128 }));
//     },
//     onLeave: function(retval) {
//         // 解密完成后，a2 指向的内存已经是明文了
//         console.log("[SM4 Decrypt] Plaintext (a2):");
//         console.log(hexdump(this.a2, { length: 16 }));
//     }
// });*/

// // Interceptor.replace(PackUiPtr, new NativeCallback(function (a1, a2, a3, a4) {
// //     console.log(a1, a2, a3, a4);
// //     return PackUi(a1, a2, a3, a4);
// // }, 'void', ['int', 'int', 'int', 'int']));

// //PackUi(Process.findModuleByName("GuiEdit.dll").base.add(0x100A98), p, p, 0x28)


// //PackUi(0,0,0,0)





// //console.log(hexdump(p))



// // console.log(uint8Arr);
// // // 输出: 72,101,108,108,111,32,119,111,114,108,100

// // // 验证：将其转回字符串看看
// // console.log(String.fromCharCode.apply(null, uint8Arr)); 