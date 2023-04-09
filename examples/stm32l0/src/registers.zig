pub fn Register(comptime R: type) type {
    return RegisterRW(R, R);
}

pub fn RegisterRW(comptime Read: type, comptime Write: type) type {
    return struct {
        raw_ptr: *volatile u32,

        const Self = @This();

        pub fn init(address: usize) Self {
            return Self{ .raw_ptr = @intToPtr(*volatile u32, address) };
        }

        pub fn initRange(address: usize, comptime dim_increment: usize, comptime num_registers: usize) [num_registers]Self {
            var registers: [num_registers]Self = undefined;
            var i: usize = 0;
            while (i < num_registers) : (i += 1) {
                registers[i] = Self.init(address + (i * dim_increment));
            }
            return registers;
        }

        pub fn read(self: Self) Read {
            return @bitCast(Read, self.raw_ptr.*);
        }

        pub fn write(self: Self, value: Write) void {
            // Forcing the alignment is a workaround for stores through
            // volatile pointers generating multiple loads and stores.
            // This is necessary for LLVM to generate code that can successfully
            // modify MMIO registers that only allow word-sized stores.
            // https://github.com/ziglang/zig/issues/8981#issuecomment-854911077
            const aligned: Write align(4) = value;
            self.raw_ptr.* = @ptrCast(*const u32, &aligned).*;
        }

        pub fn modify(self: Self, new_value: anytype) void {
            if (Read != Write) {
                @compileError("Can't modify because read and write types for this register aren't the same.");
            }
            var old_value = self.read();
            const info = @typeInfo(@TypeOf(new_value));
            inline for (info.Struct.fields) |field| {
                @field(old_value, field.name) = @field(new_value, field.name);
            }
            self.write(old_value);
        }

        pub fn read_raw(self: Self) u32 {
            return self.raw_ptr.*;
        }

        pub fn write_raw(self: Self, value: u32) void {
            self.raw_ptr.* = value;
        }

        pub fn default_read_value(_: Self) Read {
            return Read{};
        }

        pub fn default_write_value(_: Self) Write {
            return Write{};
        }
    };
}

pub const device_name = "STM32L0x2";
pub const device_revision = "1.3";
pub const device_description = "STM32L0x2";

pub const cpu = struct {
    pub const name = "CM0+";
    pub const revision = "r0p0";
    pub const endian = "little";
    pub const mpu_present = false;
    pub const fpu_present = false;
    pub const vendor_systick_config = false;
    pub const nvic_prio_bits = 3;
};

/// Advanced encryption standard hardware
pub const AES = struct {

const base_address = 0x40026000;
/// CR
const CR_val = packed struct {
/// EN [0:0]
/// AES enable
EN: u1 = 0,
/// DATATYPE [1:2]
/// Data type selection (for data in and
DATATYPE: u2 = 0,
/// MODE [3:4]
/// AES operating mode
MODE: u2 = 0,
/// CHMOD [5:6]
/// AES chaining mode
CHMOD: u2 = 0,
/// CCFC [7:7]
/// Computation Complete Flag
CCFC: u1 = 0,
/// ERRC [8:8]
/// Error clear
ERRC: u1 = 0,
/// CCFIE [9:9]
/// CCF flag interrupt enable
CCFIE: u1 = 0,
/// ERRIE [10:10]
/// Error interrupt enable
ERRIE: u1 = 0,
/// DMAINEN [11:11]
/// Enable DMA management of data input
DMAINEN: u1 = 0,
/// DMAOUTEN [12:12]
/// Enable DMA management of data output
DMAOUTEN: u1 = 0,
/// unused [13:31]
_unused13: u3 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register
pub const CR = Register(CR_val).init(base_address + 0x0);

/// SR
const SR_val = packed struct {
/// CCF [0:0]
/// Computation complete flag
CCF: u1 = 0,
/// RDERR [1:1]
/// Read error flag
RDERR: u1 = 0,
/// WRERR [2:2]
/// Write error flag
WRERR: u1 = 0,
/// unused [3:31]
_unused3: u5 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// status register
pub const SR = Register(SR_val).init(base_address + 0x4);

/// DINR
const DINR_val = packed struct {
/// AES_DINR [0:31]
/// Data Input Register.
AES_DINR: u32 = 0,
};
/// data input register
pub const DINR = Register(DINR_val).init(base_address + 0x8);

/// DOUTR
const DOUTR_val = packed struct {
/// AES_DOUTR [0:31]
/// Data output register
AES_DOUTR: u32 = 0,
};
/// data output register
pub const DOUTR = Register(DOUTR_val).init(base_address + 0xc);

/// KEYR0
const KEYR0_val = packed struct {
/// AES_KEYR0 [0:31]
/// Data Output Register (LSB key
AES_KEYR0: u32 = 0,
};
/// key register 0
pub const KEYR0 = Register(KEYR0_val).init(base_address + 0x10);

/// KEYR1
const KEYR1_val = packed struct {
/// AES_KEYR1 [0:31]
/// AES key register (key
AES_KEYR1: u32 = 0,
};
/// key register 1
pub const KEYR1 = Register(KEYR1_val).init(base_address + 0x14);

/// KEYR2
const KEYR2_val = packed struct {
/// AES_KEYR2 [0:31]
/// AES key register (key
AES_KEYR2: u32 = 0,
};
/// key register 2
pub const KEYR2 = Register(KEYR2_val).init(base_address + 0x18);

/// KEYR3
const KEYR3_val = packed struct {
/// AES_KEYR3 [0:31]
/// AES key register (MSB key
AES_KEYR3: u32 = 0,
};
/// key register 3
pub const KEYR3 = Register(KEYR3_val).init(base_address + 0x1c);

/// IVR0
const IVR0_val = packed struct {
/// AES_IVR0 [0:31]
/// initialization vector register (LSB IVR
AES_IVR0: u32 = 0,
};
/// initialization vector register
pub const IVR0 = Register(IVR0_val).init(base_address + 0x20);

/// IVR1
const IVR1_val = packed struct {
/// AES_IVR1 [0:31]
/// Initialization Vector Register (IVR
AES_IVR1: u32 = 0,
};
/// initialization vector register
pub const IVR1 = Register(IVR1_val).init(base_address + 0x24);

/// IVR2
const IVR2_val = packed struct {
/// AES_IVR2 [0:31]
/// Initialization Vector Register (IVR
AES_IVR2: u32 = 0,
};
/// initialization vector register
pub const IVR2 = Register(IVR2_val).init(base_address + 0x28);

/// IVR3
const IVR3_val = packed struct {
/// AES_IVR3 [0:31]
/// Initialization Vector Register (MSB IVR
AES_IVR3: u32 = 0,
};
/// initialization vector register
pub const IVR3 = Register(IVR3_val).init(base_address + 0x2c);
};

/// Digital-to-analog converter
pub const DAC = struct {

const base_address = 0x40007400;
/// CR
const CR_val = packed struct {
/// EN1 [0:0]
/// DAC channel1 enable
EN1: u1 = 0,
/// BOFF1 [1:1]
/// DAC channel1 output buffer
BOFF1: u1 = 0,
/// TEN1 [2:2]
/// DAC channel1 trigger
TEN1: u1 = 0,
/// TSEL1 [3:5]
/// DAC channel1 trigger
TSEL1: u3 = 0,
/// WAVE1 [6:7]
/// DAC channel1 noise/triangle wave
WAVE1: u2 = 0,
/// MAMP1 [8:11]
/// DAC channel1 mask/amplitude
MAMP1: u4 = 0,
/// DMAEN1 [12:12]
/// DAC channel1 DMA enable
DMAEN1: u1 = 0,
/// DMAUDRIE1 [13:13]
/// DAC channel1 DMA Underrun Interrupt
DMAUDRIE1: u1 = 0,
/// unused [14:31]
_unused14: u2 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register
pub const CR = Register(CR_val).init(base_address + 0x0);

/// SWTRIGR
const SWTRIGR_val = packed struct {
/// SWTRIG1 [0:0]
/// DAC channel1 software
SWTRIG1: u1 = 0,
/// unused [1:31]
_unused1: u7 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// software trigger register
pub const SWTRIGR = Register(SWTRIGR_val).init(base_address + 0x4);

/// DHR12R1
const DHR12R1_val = packed struct {
/// DACC1DHR [0:11]
/// DAC channel1 12-bit right-aligned
DACC1DHR: u12 = 0,
/// unused [12:31]
_unused12: u4 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel1 12-bit right-aligned data holding
pub const DHR12R1 = Register(DHR12R1_val).init(base_address + 0x8);

/// DHR12L1
const DHR12L1_val = packed struct {
/// unused [0:3]
_unused0: u4 = 0,
/// DACC1DHR [4:15]
/// DAC channel1 12-bit left-aligned
DACC1DHR: u12 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel1 12-bit left-aligned data holding
pub const DHR12L1 = Register(DHR12L1_val).init(base_address + 0xc);

/// DHR8R1
const DHR8R1_val = packed struct {
/// DACC1DHR [0:7]
/// DAC channel1 8-bit right-aligned
DACC1DHR: u8 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel1 8-bit right-aligned data holding
pub const DHR8R1 = Register(DHR8R1_val).init(base_address + 0x10);

/// DOR1
const DOR1_val = packed struct {
/// DACC1DOR [0:11]
/// DAC channel1 data output
DACC1DOR: u12 = 0,
/// unused [12:31]
_unused12: u4 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel1 data output register
pub const DOR1 = Register(DOR1_val).init(base_address + 0x2c);

/// SR
const SR_val = packed struct {
/// unused [0:12]
_unused0: u8 = 0,
_unused8: u5 = 0,
/// DMAUDR1 [13:13]
/// DAC channel1 DMA underrun
DMAUDR1: u1 = 0,
/// unused [14:31]
_unused14: u2 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// status register
pub const SR = Register(SR_val).init(base_address + 0x34);

/// DHR12R2
const DHR12R2_val = packed struct {
/// DACC2DHR [0:11]
/// DAC channel2 12-bit right-aligned
DACC2DHR: u12 = 0,
/// unused [12:31]
_unused12: u4 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel2 12-bit right-aligned data holding
pub const DHR12R2 = Register(DHR12R2_val).init(base_address + 0x14);

/// DHR12L2
const DHR12L2_val = packed struct {
/// unused [0:3]
_unused0: u4 = 0,
/// DACC2DHR [4:15]
/// DAC channel2 12-bit left-aligned
DACC2DHR: u12 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel2 12-bit left-aligned data holding
pub const DHR12L2 = Register(DHR12L2_val).init(base_address + 0x18);

/// DHR8R2
const DHR8R2_val = packed struct {
/// DACC2DHR [0:7]
/// DAC channel2 8-bit right-aligned
DACC2DHR: u8 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel2 8-bit right-aligned data holding
pub const DHR8R2 = Register(DHR8R2_val).init(base_address + 0x1c);

/// DHR12RD
const DHR12RD_val = packed struct {
/// DACC1DHR [0:11]
/// DAC channel1 12-bit right-aligned
DACC1DHR: u12 = 0,
/// unused [12:15]
_unused12: u4 = 0,
/// DACC2DHR [16:27]
/// DAC channel2 12-bit right-aligned
DACC2DHR: u12 = 0,
/// unused [28:31]
_unused28: u4 = 0,
};
/// Dual DAC 12-bit right-aligned data holding
pub const DHR12RD = Register(DHR12RD_val).init(base_address + 0x20);

/// DHR12LD
const DHR12LD_val = packed struct {
/// unused [0:3]
_unused0: u4 = 0,
/// DACC1DHR [4:15]
/// DAC channel1 12-bit left-aligned
DACC1DHR: u12 = 0,
/// unused [16:19]
_unused16: u4 = 0,
/// DACC2DHR [20:31]
/// DAC channel2 12-bit left-aligned
DACC2DHR: u12 = 0,
};
/// Dual DAC 12-bit left-aligned data holding
pub const DHR12LD = Register(DHR12LD_val).init(base_address + 0x24);

/// DHR8RD
const DHR8RD_val = packed struct {
/// DACC1DHR [0:7]
/// DAC channel1 8-bit right-aligned
DACC1DHR: u8 = 0,
/// DACC2DHR [8:15]
/// DAC channel2 8-bit right-aligned
DACC2DHR: u8 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Dual DAC 8-bit right-aligned data holding
pub const DHR8RD = Register(DHR8RD_val).init(base_address + 0x28);

/// DOR2
const DOR2_val = packed struct {
/// DACC2DOR [0:11]
/// DAC channel2 data output
DACC2DOR: u12 = 0,
/// unused [12:31]
_unused12: u4 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel2 data output register
pub const DOR2 = Register(DOR2_val).init(base_address + 0x30);
};

/// Direct memory access controller
pub const DMA1 = struct {

const base_address = 0x40020000;
/// ISR
const ISR_val = packed struct {
/// GIF1 [0:0]
/// Channel x global interrupt flag (x = 1
GIF1: u1 = 0,
/// TCIF1 [1:1]
/// Channel x transfer complete flag (x = 1
TCIF1: u1 = 0,
/// HTIF1 [2:2]
/// Channel x half transfer flag (x = 1
HTIF1: u1 = 0,
/// TEIF1 [3:3]
/// Channel x transfer error flag (x = 1
TEIF1: u1 = 0,
/// GIF2 [4:4]
/// Channel x global interrupt flag (x = 1
GIF2: u1 = 0,
/// TCIF2 [5:5]
/// Channel x transfer complete flag (x = 1
TCIF2: u1 = 0,
/// HTIF2 [6:6]
/// Channel x half transfer flag (x = 1
HTIF2: u1 = 0,
/// TEIF2 [7:7]
/// Channel x transfer error flag (x = 1
TEIF2: u1 = 0,
/// GIF3 [8:8]
/// Channel x global interrupt flag (x = 1
GIF3: u1 = 0,
/// TCIF3 [9:9]
/// Channel x transfer complete flag (x = 1
TCIF3: u1 = 0,
/// HTIF3 [10:10]
/// Channel x half transfer flag (x = 1
HTIF3: u1 = 0,
/// TEIF3 [11:11]
/// Channel x transfer error flag (x = 1
TEIF3: u1 = 0,
/// GIF4 [12:12]
/// Channel x global interrupt flag (x = 1
GIF4: u1 = 0,
/// TCIF4 [13:13]
/// Channel x transfer complete flag (x = 1
TCIF4: u1 = 0,
/// HTIF4 [14:14]
/// Channel x half transfer flag (x = 1
HTIF4: u1 = 0,
/// TEIF4 [15:15]
/// Channel x transfer error flag (x = 1
TEIF4: u1 = 0,
/// GIF5 [16:16]
/// Channel x global interrupt flag (x = 1
GIF5: u1 = 0,
/// TCIF5 [17:17]
/// Channel x transfer complete flag (x = 1
TCIF5: u1 = 0,
/// HTIF5 [18:18]
/// Channel x half transfer flag (x = 1
HTIF5: u1 = 0,
/// TEIF5 [19:19]
/// Channel x transfer error flag (x = 1
TEIF5: u1 = 0,
/// GIF6 [20:20]
/// Channel x global interrupt flag (x = 1
GIF6: u1 = 0,
/// TCIF6 [21:21]
/// Channel x transfer complete flag (x = 1
TCIF6: u1 = 0,
/// HTIF6 [22:22]
/// Channel x half transfer flag (x = 1
HTIF6: u1 = 0,
/// TEIF6 [23:23]
/// Channel x transfer error flag (x = 1
TEIF6: u1 = 0,
/// GIF7 [24:24]
/// Channel x global interrupt flag (x = 1
GIF7: u1 = 0,
/// TCIF7 [25:25]
/// Channel x transfer complete flag (x = 1
TCIF7: u1 = 0,
/// HTIF7 [26:26]
/// Channel x half transfer flag (x = 1
HTIF7: u1 = 0,
/// TEIF7 [27:27]
/// Channel x transfer error flag (x = 1
TEIF7: u1 = 0,
/// unused [28:31]
_unused28: u4 = 0,
};
/// interrupt status register
pub const ISR = Register(ISR_val).init(base_address + 0x0);

/// IFCR
const IFCR_val = packed struct {
/// CGIF1 [0:0]
/// Channel x global interrupt clear (x = 1
CGIF1: u1 = 0,
/// CTCIF1 [1:1]
/// Channel x transfer complete clear (x = 1
CTCIF1: u1 = 0,
/// CHTIF1 [2:2]
/// Channel x half transfer clear (x = 1
CHTIF1: u1 = 0,
/// CTEIF1 [3:3]
/// Channel x transfer error clear (x = 1
CTEIF1: u1 = 0,
/// CGIF2 [4:4]
/// Channel x global interrupt clear (x = 1
CGIF2: u1 = 0,
/// CTCIF2 [5:5]
/// Channel x transfer complete clear (x = 1
CTCIF2: u1 = 0,
/// CHTIF2 [6:6]
/// Channel x half transfer clear (x = 1
CHTIF2: u1 = 0,
/// CTEIF2 [7:7]
/// Channel x transfer error clear (x = 1
CTEIF2: u1 = 0,
/// CGIF3 [8:8]
/// Channel x global interrupt clear (x = 1
CGIF3: u1 = 0,
/// CTCIF3 [9:9]
/// Channel x transfer complete clear (x = 1
CTCIF3: u1 = 0,
/// CHTIF3 [10:10]
/// Channel x half transfer clear (x = 1
CHTIF3: u1 = 0,
/// CTEIF3 [11:11]
/// Channel x transfer error clear (x = 1
CTEIF3: u1 = 0,
/// CGIF4 [12:12]
/// Channel x global interrupt clear (x = 1
CGIF4: u1 = 0,
/// CTCIF4 [13:13]
/// Channel x transfer complete clear (x = 1
CTCIF4: u1 = 0,
/// CHTIF4 [14:14]
/// Channel x half transfer clear (x = 1
CHTIF4: u1 = 0,
/// CTEIF4 [15:15]
/// Channel x transfer error clear (x = 1
CTEIF4: u1 = 0,
/// CGIF5 [16:16]
/// Channel x global interrupt clear (x = 1
CGIF5: u1 = 0,
/// CTCIF5 [17:17]
/// Channel x transfer complete clear (x = 1
CTCIF5: u1 = 0,
/// CHTIF5 [18:18]
/// Channel x half transfer clear (x = 1
CHTIF5: u1 = 0,
/// CTEIF5 [19:19]
/// Channel x transfer error clear (x = 1
CTEIF5: u1 = 0,
/// CGIF6 [20:20]
/// Channel x global interrupt clear (x = 1
CGIF6: u1 = 0,
/// CTCIF6 [21:21]
/// Channel x transfer complete clear (x = 1
CTCIF6: u1 = 0,
/// CHTIF6 [22:22]
/// Channel x half transfer clear (x = 1
CHTIF6: u1 = 0,
/// CTEIF6 [23:23]
/// Channel x transfer error clear (x = 1
CTEIF6: u1 = 0,
/// CGIF7 [24:24]
/// Channel x global interrupt clear (x = 1
CGIF7: u1 = 0,
/// CTCIF7 [25:25]
/// Channel x transfer complete clear (x = 1
CTCIF7: u1 = 0,
/// CHTIF7 [26:26]
/// Channel x half transfer clear (x = 1
CHTIF7: u1 = 0,
/// CTEIF7 [27:27]
/// Channel x transfer error clear (x = 1
CTEIF7: u1 = 0,
/// unused [28:31]
_unused28: u4 = 0,
};
/// interrupt flag clear register
pub const IFCR = Register(IFCR_val).init(base_address + 0x4);

/// CCR1
const CCR1_val = packed struct {
/// EN [0:0]
/// Channel enable
EN: u1 = 0,
/// TCIE [1:1]
/// Transfer complete interrupt
TCIE: u1 = 0,
/// HTIE [2:2]
/// Half transfer interrupt
HTIE: u1 = 0,
/// TEIE [3:3]
/// Transfer error interrupt
TEIE: u1 = 0,
/// DIR [4:4]
/// Data transfer direction
DIR: u1 = 0,
/// CIRC [5:5]
/// Circular mode
CIRC: u1 = 0,
/// PINC [6:6]
/// Peripheral increment mode
PINC: u1 = 0,
/// MINC [7:7]
/// Memory increment mode
MINC: u1 = 0,
/// PSIZE [8:9]
/// Peripheral size
PSIZE: u2 = 0,
/// MSIZE [10:11]
/// Memory size
MSIZE: u2 = 0,
/// PL [12:13]
/// Channel priority level
PL: u2 = 0,
/// MEM2MEM [14:14]
/// Memory to memory mode
MEM2MEM: u1 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x configuration
pub const CCR1 = Register(CCR1_val).init(base_address + 0x8);

/// CNDTR1
const CNDTR1_val = packed struct {
/// NDT [0:15]
/// Number of data to transfer
NDT: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x number of data
pub const CNDTR1 = Register(CNDTR1_val).init(base_address + 0xc);

/// CPAR1
const CPAR1_val = packed struct {
/// PA [0:31]
/// Peripheral address
PA: u32 = 0,
};
/// channel x peripheral address
pub const CPAR1 = Register(CPAR1_val).init(base_address + 0x10);

/// CMAR1
const CMAR1_val = packed struct {
/// MA [0:31]
/// Memory address
MA: u32 = 0,
};
/// channel x memory address
pub const CMAR1 = Register(CMAR1_val).init(base_address + 0x14);

/// CCR2
const CCR2_val = packed struct {
/// EN [0:0]
/// Channel enable
EN: u1 = 0,
/// TCIE [1:1]
/// Transfer complete interrupt
TCIE: u1 = 0,
/// HTIE [2:2]
/// Half transfer interrupt
HTIE: u1 = 0,
/// TEIE [3:3]
/// Transfer error interrupt
TEIE: u1 = 0,
/// DIR [4:4]
/// Data transfer direction
DIR: u1 = 0,
/// CIRC [5:5]
/// Circular mode
CIRC: u1 = 0,
/// PINC [6:6]
/// Peripheral increment mode
PINC: u1 = 0,
/// MINC [7:7]
/// Memory increment mode
MINC: u1 = 0,
/// PSIZE [8:9]
/// Peripheral size
PSIZE: u2 = 0,
/// MSIZE [10:11]
/// Memory size
MSIZE: u2 = 0,
/// PL [12:13]
/// Channel priority level
PL: u2 = 0,
/// MEM2MEM [14:14]
/// Memory to memory mode
MEM2MEM: u1 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x configuration
pub const CCR2 = Register(CCR2_val).init(base_address + 0x1c);

/// CNDTR2
const CNDTR2_val = packed struct {
/// NDT [0:15]
/// Number of data to transfer
NDT: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x number of data
pub const CNDTR2 = Register(CNDTR2_val).init(base_address + 0x20);

/// CPAR2
const CPAR2_val = packed struct {
/// PA [0:31]
/// Peripheral address
PA: u32 = 0,
};
/// channel x peripheral address
pub const CPAR2 = Register(CPAR2_val).init(base_address + 0x24);

/// CMAR2
const CMAR2_val = packed struct {
/// MA [0:31]
/// Memory address
MA: u32 = 0,
};
/// channel x memory address
pub const CMAR2 = Register(CMAR2_val).init(base_address + 0x28);

/// CCR3
const CCR3_val = packed struct {
/// EN [0:0]
/// Channel enable
EN: u1 = 0,
/// TCIE [1:1]
/// Transfer complete interrupt
TCIE: u1 = 0,
/// HTIE [2:2]
/// Half transfer interrupt
HTIE: u1 = 0,
/// TEIE [3:3]
/// Transfer error interrupt
TEIE: u1 = 0,
/// DIR [4:4]
/// Data transfer direction
DIR: u1 = 0,
/// CIRC [5:5]
/// Circular mode
CIRC: u1 = 0,
/// PINC [6:6]
/// Peripheral increment mode
PINC: u1 = 0,
/// MINC [7:7]
/// Memory increment mode
MINC: u1 = 0,
/// PSIZE [8:9]
/// Peripheral size
PSIZE: u2 = 0,
/// MSIZE [10:11]
/// Memory size
MSIZE: u2 = 0,
/// PL [12:13]
/// Channel priority level
PL: u2 = 0,
/// MEM2MEM [14:14]
/// Memory to memory mode
MEM2MEM: u1 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x configuration
pub const CCR3 = Register(CCR3_val).init(base_address + 0x30);

/// CNDTR3
const CNDTR3_val = packed struct {
/// NDT [0:15]
/// Number of data to transfer
NDT: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x number of data
pub const CNDTR3 = Register(CNDTR3_val).init(base_address + 0x34);

/// CPAR3
const CPAR3_val = packed struct {
/// PA [0:31]
/// Peripheral address
PA: u32 = 0,
};
/// channel x peripheral address
pub const CPAR3 = Register(CPAR3_val).init(base_address + 0x38);

/// CMAR3
const CMAR3_val = packed struct {
/// MA [0:31]
/// Memory address
MA: u32 = 0,
};
/// channel x memory address
pub const CMAR3 = Register(CMAR3_val).init(base_address + 0x3c);

/// CCR4
const CCR4_val = packed struct {
/// EN [0:0]
/// Channel enable
EN: u1 = 0,
/// TCIE [1:1]
/// Transfer complete interrupt
TCIE: u1 = 0,
/// HTIE [2:2]
/// Half transfer interrupt
HTIE: u1 = 0,
/// TEIE [3:3]
/// Transfer error interrupt
TEIE: u1 = 0,
/// DIR [4:4]
/// Data transfer direction
DIR: u1 = 0,
/// CIRC [5:5]
/// Circular mode
CIRC: u1 = 0,
/// PINC [6:6]
/// Peripheral increment mode
PINC: u1 = 0,
/// MINC [7:7]
/// Memory increment mode
MINC: u1 = 0,
/// PSIZE [8:9]
/// Peripheral size
PSIZE: u2 = 0,
/// MSIZE [10:11]
/// Memory size
MSIZE: u2 = 0,
/// PL [12:13]
/// Channel priority level
PL: u2 = 0,
/// MEM2MEM [14:14]
/// Memory to memory mode
MEM2MEM: u1 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x configuration
pub const CCR4 = Register(CCR4_val).init(base_address + 0x44);

/// CNDTR4
const CNDTR4_val = packed struct {
/// NDT [0:15]
/// Number of data to transfer
NDT: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x number of data
pub const CNDTR4 = Register(CNDTR4_val).init(base_address + 0x48);

/// CPAR4
const CPAR4_val = packed struct {
/// PA [0:31]
/// Peripheral address
PA: u32 = 0,
};
/// channel x peripheral address
pub const CPAR4 = Register(CPAR4_val).init(base_address + 0x4c);

/// CMAR4
const CMAR4_val = packed struct {
/// MA [0:31]
/// Memory address
MA: u32 = 0,
};
/// channel x memory address
pub const CMAR4 = Register(CMAR4_val).init(base_address + 0x50);

/// CCR5
const CCR5_val = packed struct {
/// EN [0:0]
/// Channel enable
EN: u1 = 0,
/// TCIE [1:1]
/// Transfer complete interrupt
TCIE: u1 = 0,
/// HTIE [2:2]
/// Half transfer interrupt
HTIE: u1 = 0,
/// TEIE [3:3]
/// Transfer error interrupt
TEIE: u1 = 0,
/// DIR [4:4]
/// Data transfer direction
DIR: u1 = 0,
/// CIRC [5:5]
/// Circular mode
CIRC: u1 = 0,
/// PINC [6:6]
/// Peripheral increment mode
PINC: u1 = 0,
/// MINC [7:7]
/// Memory increment mode
MINC: u1 = 0,
/// PSIZE [8:9]
/// Peripheral size
PSIZE: u2 = 0,
/// MSIZE [10:11]
/// Memory size
MSIZE: u2 = 0,
/// PL [12:13]
/// Channel priority level
PL: u2 = 0,
/// MEM2MEM [14:14]
/// Memory to memory mode
MEM2MEM: u1 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x configuration
pub const CCR5 = Register(CCR5_val).init(base_address + 0x58);

/// CNDTR5
const CNDTR5_val = packed struct {
/// NDT [0:15]
/// Number of data to transfer
NDT: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x number of data
pub const CNDTR5 = Register(CNDTR5_val).init(base_address + 0x5c);

/// CPAR5
const CPAR5_val = packed struct {
/// PA [0:31]
/// Peripheral address
PA: u32 = 0,
};
/// channel x peripheral address
pub const CPAR5 = Register(CPAR5_val).init(base_address + 0x60);

/// CMAR5
const CMAR5_val = packed struct {
/// MA [0:31]
/// Memory address
MA: u32 = 0,
};
/// channel x memory address
pub const CMAR5 = Register(CMAR5_val).init(base_address + 0x64);

/// CCR6
const CCR6_val = packed struct {
/// EN [0:0]
/// Channel enable
EN: u1 = 0,
/// TCIE [1:1]
/// Transfer complete interrupt
TCIE: u1 = 0,
/// HTIE [2:2]
/// Half transfer interrupt
HTIE: u1 = 0,
/// TEIE [3:3]
/// Transfer error interrupt
TEIE: u1 = 0,
/// DIR [4:4]
/// Data transfer direction
DIR: u1 = 0,
/// CIRC [5:5]
/// Circular mode
CIRC: u1 = 0,
/// PINC [6:6]
/// Peripheral increment mode
PINC: u1 = 0,
/// MINC [7:7]
/// Memory increment mode
MINC: u1 = 0,
/// PSIZE [8:9]
/// Peripheral size
PSIZE: u2 = 0,
/// MSIZE [10:11]
/// Memory size
MSIZE: u2 = 0,
/// PL [12:13]
/// Channel priority level
PL: u2 = 0,
/// MEM2MEM [14:14]
/// Memory to memory mode
MEM2MEM: u1 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x configuration
pub const CCR6 = Register(CCR6_val).init(base_address + 0x6c);

/// CNDTR6
const CNDTR6_val = packed struct {
/// NDT [0:15]
/// Number of data to transfer
NDT: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x number of data
pub const CNDTR6 = Register(CNDTR6_val).init(base_address + 0x70);

/// CPAR6
const CPAR6_val = packed struct {
/// PA [0:31]
/// Peripheral address
PA: u32 = 0,
};
/// channel x peripheral address
pub const CPAR6 = Register(CPAR6_val).init(base_address + 0x74);

/// CMAR6
const CMAR6_val = packed struct {
/// MA [0:31]
/// Memory address
MA: u32 = 0,
};
/// channel x memory address
pub const CMAR6 = Register(CMAR6_val).init(base_address + 0x78);

/// CCR7
const CCR7_val = packed struct {
/// EN [0:0]
/// Channel enable
EN: u1 = 0,
/// TCIE [1:1]
/// Transfer complete interrupt
TCIE: u1 = 0,
/// HTIE [2:2]
/// Half transfer interrupt
HTIE: u1 = 0,
/// TEIE [3:3]
/// Transfer error interrupt
TEIE: u1 = 0,
/// DIR [4:4]
/// Data transfer direction
DIR: u1 = 0,
/// CIRC [5:5]
/// Circular mode
CIRC: u1 = 0,
/// PINC [6:6]
/// Peripheral increment mode
PINC: u1 = 0,
/// MINC [7:7]
/// Memory increment mode
MINC: u1 = 0,
/// PSIZE [8:9]
/// Peripheral size
PSIZE: u2 = 0,
/// MSIZE [10:11]
/// Memory size
MSIZE: u2 = 0,
/// PL [12:13]
/// Channel priority level
PL: u2 = 0,
/// MEM2MEM [14:14]
/// Memory to memory mode
MEM2MEM: u1 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x configuration
pub const CCR7 = Register(CCR7_val).init(base_address + 0x80);

/// CNDTR7
const CNDTR7_val = packed struct {
/// NDT [0:15]
/// Number of data to transfer
NDT: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// channel x number of data
pub const CNDTR7 = Register(CNDTR7_val).init(base_address + 0x84);

/// CPAR7
const CPAR7_val = packed struct {
/// PA [0:31]
/// Peripheral address
PA: u32 = 0,
};
/// channel x peripheral address
pub const CPAR7 = Register(CPAR7_val).init(base_address + 0x88);

/// CMAR7
const CMAR7_val = packed struct {
/// MA [0:31]
/// Memory address
MA: u32 = 0,
};
/// channel x memory address
pub const CMAR7 = Register(CMAR7_val).init(base_address + 0x8c);

/// CSELR
const CSELR_val = packed struct {
/// C1S [0:3]
/// DMA channel 1 selection
C1S: u4 = 0,
/// C2S [4:7]
/// DMA channel 2 selection
C2S: u4 = 0,
/// C3S [8:11]
/// DMA channel 3 selection
C3S: u4 = 0,
/// C4S [12:15]
/// DMA channel 4 selection
C4S: u4 = 0,
/// C5S [16:19]
/// DMA channel 5 selection
C5S: u4 = 0,
/// C6S [20:23]
/// DMA channel 6 selection
C6S: u4 = 0,
/// C7S [24:27]
/// DMA channel 7 selection
C7S: u4 = 0,
/// unused [28:31]
_unused28: u4 = 0,
};
/// channel selection register
pub const CSELR = Register(CSELR_val).init(base_address + 0xa8);
};

/// Cyclic redundancy check calculation
pub const CRC = struct {

const base_address = 0x40023000;
/// DR
const DR_val = packed struct {
/// DR [0:31]
/// Data register bits
DR: u32 = 4294967295,
};
/// Data register
pub const DR = Register(DR_val).init(base_address + 0x0);

/// IDR
const IDR_val = packed struct {
/// IDR [0:7]
/// General-purpose 8-bit data register
IDR: u8 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Independent data register
pub const IDR = Register(IDR_val).init(base_address + 0x4);

/// CR
const CR_val = packed struct {
/// RESET [0:0]
/// RESET bit
RESET: u1 = 0,
/// unused [1:2]
_unused1: u2 = 0,
/// POLYSIZE [3:4]
/// Polynomial size
POLYSIZE: u2 = 0,
/// REV_IN [5:6]
/// Reverse input data
REV_IN: u2 = 0,
/// REV_OUT [7:7]
/// Reverse output data
REV_OUT: u1 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Control register
pub const CR = Register(CR_val).init(base_address + 0x8);

/// INIT
const INIT_val = packed struct {
/// CRC_INIT [0:31]
/// Programmable initial CRC
CRC_INIT: u32 = 4294967295,
};
/// Initial CRC value
pub const INIT = Register(INIT_val).init(base_address + 0x10);

/// POL
const POL_val = packed struct {
/// Polynomialcoefficients [0:31]
/// Programmable polynomial
Polynomialcoefficients: u32 = 79764919,
};
/// polynomial
pub const POL = Register(POL_val).init(base_address + 0x14);
};

/// General-purpose I/Os
pub const GPIOA = struct {

const base_address = 0x50000000;
/// MODER
const MODER_val = packed struct {
/// MODE0 [0:1]
/// Port x configuration bits (y =
MODE0: u2 = 3,
/// MODE1 [2:3]
/// Port x configuration bits (y =
MODE1: u2 = 3,
/// MODE2 [4:5]
/// Port x configuration bits (y =
MODE2: u2 = 3,
/// MODE3 [6:7]
/// Port x configuration bits (y =
MODE3: u2 = 3,
/// MODE4 [8:9]
/// Port x configuration bits (y =
MODE4: u2 = 0,
/// MODE5 [10:11]
/// Port x configuration bits (y =
MODE5: u2 = 3,
/// MODE6 [12:13]
/// Port x configuration bits (y =
MODE6: u2 = 3,
/// MODE7 [14:15]
/// Port x configuration bits (y =
MODE7: u2 = 3,
/// MODE8 [16:17]
/// Port x configuration bits (y =
MODE8: u2 = 3,
/// MODE9 [18:19]
/// Port x configuration bits (y =
MODE9: u2 = 3,
/// MODE10 [20:21]
/// Port x configuration bits (y =
MODE10: u2 = 3,
/// MODE11 [22:23]
/// Port x configuration bits (y =
MODE11: u2 = 3,
/// MODE12 [24:25]
/// Port x configuration bits (y =
MODE12: u2 = 3,
/// MODE13 [26:27]
/// Port x configuration bits (y =
MODE13: u2 = 2,
/// MODE14 [28:29]
/// Port x configuration bits (y =
MODE14: u2 = 2,
/// MODE15 [30:31]
/// Port x configuration bits (y =
MODE15: u2 = 3,
};
/// GPIO port mode register
pub const MODER = Register(MODER_val).init(base_address + 0x0);

/// OTYPER
const OTYPER_val = packed struct {
/// OT0 [0:0]
/// Port x configuration bits (y =
OT0: u1 = 0,
/// OT1 [1:1]
/// Port x configuration bits (y =
OT1: u1 = 0,
/// OT2 [2:2]
/// Port x configuration bits (y =
OT2: u1 = 0,
/// OT3 [3:3]
/// Port x configuration bits (y =
OT3: u1 = 0,
/// OT4 [4:4]
/// Port x configuration bits (y =
OT4: u1 = 0,
/// OT5 [5:5]
/// Port x configuration bits (y =
OT5: u1 = 0,
/// OT6 [6:6]
/// Port x configuration bits (y =
OT6: u1 = 0,
/// OT7 [7:7]
/// Port x configuration bits (y =
OT7: u1 = 0,
/// OT8 [8:8]
/// Port x configuration bits (y =
OT8: u1 = 0,
/// OT9 [9:9]
/// Port x configuration bits (y =
OT9: u1 = 0,
/// OT10 [10:10]
/// Port x configuration bits (y =
OT10: u1 = 0,
/// OT11 [11:11]
/// Port x configuration bits (y =
OT11: u1 = 0,
/// OT12 [12:12]
/// Port x configuration bits (y =
OT12: u1 = 0,
/// OT13 [13:13]
/// Port x configuration bits (y =
OT13: u1 = 0,
/// OT14 [14:14]
/// Port x configuration bits (y =
OT14: u1 = 0,
/// OT15 [15:15]
/// Port x configuration bits (y =
OT15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port output type register
pub const OTYPER = Register(OTYPER_val).init(base_address + 0x4);

/// OSPEEDR
const OSPEEDR_val = packed struct {
/// OSPEED0 [0:1]
/// Port x configuration bits (y =
OSPEED0: u2 = 0,
/// OSPEED1 [2:3]
/// Port x configuration bits (y =
OSPEED1: u2 = 0,
/// OSPEED2 [4:5]
/// Port x configuration bits (y =
OSPEED2: u2 = 0,
/// OSPEED3 [6:7]
/// Port x configuration bits (y =
OSPEED3: u2 = 0,
/// OSPEED4 [8:9]
/// Port x configuration bits (y =
OSPEED4: u2 = 0,
/// OSPEED5 [10:11]
/// Port x configuration bits (y =
OSPEED5: u2 = 0,
/// OSPEED6 [12:13]
/// Port x configuration bits (y =
OSPEED6: u2 = 0,
/// OSPEED7 [14:15]
/// Port x configuration bits (y =
OSPEED7: u2 = 0,
/// OSPEED8 [16:17]
/// Port x configuration bits (y =
OSPEED8: u2 = 0,
/// OSPEED9 [18:19]
/// Port x configuration bits (y =
OSPEED9: u2 = 0,
/// OSPEED10 [20:21]
/// Port x configuration bits (y =
OSPEED10: u2 = 0,
/// OSPEED11 [22:23]
/// Port x configuration bits (y =
OSPEED11: u2 = 0,
/// OSPEED12 [24:25]
/// Port x configuration bits (y =
OSPEED12: u2 = 0,
/// OSPEED13 [26:27]
/// Port x configuration bits (y =
OSPEED13: u2 = 0,
/// OSPEED14 [28:29]
/// Port x configuration bits (y =
OSPEED14: u2 = 0,
/// OSPEED15 [30:31]
/// Port x configuration bits (y =
OSPEED15: u2 = 0,
};
/// GPIO port output speed
pub const OSPEEDR = Register(OSPEEDR_val).init(base_address + 0x8);

/// PUPDR
const PUPDR_val = packed struct {
/// PUPD0 [0:1]
/// Port x configuration bits (y =
PUPD0: u2 = 0,
/// PUPD1 [2:3]
/// Port x configuration bits (y =
PUPD1: u2 = 0,
/// PUPD2 [4:5]
/// Port x configuration bits (y =
PUPD2: u2 = 0,
/// PUPD3 [6:7]
/// Port x configuration bits (y =
PUPD3: u2 = 0,
/// PUPD4 [8:9]
/// Port x configuration bits (y =
PUPD4: u2 = 0,
/// PUPD5 [10:11]
/// Port x configuration bits (y =
PUPD5: u2 = 0,
/// PUPD6 [12:13]
/// Port x configuration bits (y =
PUPD6: u2 = 0,
/// PUPD7 [14:15]
/// Port x configuration bits (y =
PUPD7: u2 = 0,
/// PUPD8 [16:17]
/// Port x configuration bits (y =
PUPD8: u2 = 0,
/// PUPD9 [18:19]
/// Port x configuration bits (y =
PUPD9: u2 = 0,
/// PUPD10 [20:21]
/// Port x configuration bits (y =
PUPD10: u2 = 0,
/// PUPD11 [22:23]
/// Port x configuration bits (y =
PUPD11: u2 = 0,
/// PUPD12 [24:25]
/// Port x configuration bits (y =
PUPD12: u2 = 0,
/// PUPD13 [26:27]
/// Port x configuration bits (y =
PUPD13: u2 = 1,
/// PUPD14 [28:29]
/// Port x configuration bits (y =
PUPD14: u2 = 2,
/// PUPD15 [30:31]
/// Port x configuration bits (y =
PUPD15: u2 = 0,
};
/// GPIO port pull-up/pull-down
pub const PUPDR = Register(PUPDR_val).init(base_address + 0xc);

/// IDR
const IDR_val = packed struct {
/// ID0 [0:0]
/// Port input data bit (y =
ID0: u1 = 0,
/// ID1 [1:1]
/// Port input data bit (y =
ID1: u1 = 0,
/// ID2 [2:2]
/// Port input data bit (y =
ID2: u1 = 0,
/// ID3 [3:3]
/// Port input data bit (y =
ID3: u1 = 0,
/// ID4 [4:4]
/// Port input data bit (y =
ID4: u1 = 0,
/// ID5 [5:5]
/// Port input data bit (y =
ID5: u1 = 0,
/// ID6 [6:6]
/// Port input data bit (y =
ID6: u1 = 0,
/// ID7 [7:7]
/// Port input data bit (y =
ID7: u1 = 0,
/// ID8 [8:8]
/// Port input data bit (y =
ID8: u1 = 0,
/// ID9 [9:9]
/// Port input data bit (y =
ID9: u1 = 0,
/// ID10 [10:10]
/// Port input data bit (y =
ID10: u1 = 0,
/// ID11 [11:11]
/// Port input data bit (y =
ID11: u1 = 0,
/// ID12 [12:12]
/// Port input data bit (y =
ID12: u1 = 0,
/// ID13 [13:13]
/// Port input data bit (y =
ID13: u1 = 0,
/// ID14 [14:14]
/// Port input data bit (y =
ID14: u1 = 0,
/// ID15 [15:15]
/// Port input data bit (y =
ID15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port input data register
pub const IDR = Register(IDR_val).init(base_address + 0x10);

/// ODR
const ODR_val = packed struct {
/// OD0 [0:0]
/// Port output data bit (y =
OD0: u1 = 0,
/// OD1 [1:1]
/// Port output data bit (y =
OD1: u1 = 0,
/// OD2 [2:2]
/// Port output data bit (y =
OD2: u1 = 0,
/// OD3 [3:3]
/// Port output data bit (y =
OD3: u1 = 0,
/// OD4 [4:4]
/// Port output data bit (y =
OD4: u1 = 0,
/// OD5 [5:5]
/// Port output data bit (y =
OD5: u1 = 0,
/// OD6 [6:6]
/// Port output data bit (y =
OD6: u1 = 0,
/// OD7 [7:7]
/// Port output data bit (y =
OD7: u1 = 0,
/// OD8 [8:8]
/// Port output data bit (y =
OD8: u1 = 0,
/// OD9 [9:9]
/// Port output data bit (y =
OD9: u1 = 0,
/// OD10 [10:10]
/// Port output data bit (y =
OD10: u1 = 0,
/// OD11 [11:11]
/// Port output data bit (y =
OD11: u1 = 0,
/// OD12 [12:12]
/// Port output data bit (y =
OD12: u1 = 0,
/// OD13 [13:13]
/// Port output data bit (y =
OD13: u1 = 0,
/// OD14 [14:14]
/// Port output data bit (y =
OD14: u1 = 0,
/// OD15 [15:15]
/// Port output data bit (y =
OD15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port output data register
pub const ODR = Register(ODR_val).init(base_address + 0x14);

/// BSRR
const BSRR_val = packed struct {
/// BS0 [0:0]
/// Port x set bit y (y=
BS0: u1 = 0,
/// BS1 [1:1]
/// Port x set bit y (y=
BS1: u1 = 0,
/// BS2 [2:2]
/// Port x set bit y (y=
BS2: u1 = 0,
/// BS3 [3:3]
/// Port x set bit y (y=
BS3: u1 = 0,
/// BS4 [4:4]
/// Port x set bit y (y=
BS4: u1 = 0,
/// BS5 [5:5]
/// Port x set bit y (y=
BS5: u1 = 0,
/// BS6 [6:6]
/// Port x set bit y (y=
BS6: u1 = 0,
/// BS7 [7:7]
/// Port x set bit y (y=
BS7: u1 = 0,
/// BS8 [8:8]
/// Port x set bit y (y=
BS8: u1 = 0,
/// BS9 [9:9]
/// Port x set bit y (y=
BS9: u1 = 0,
/// BS10 [10:10]
/// Port x set bit y (y=
BS10: u1 = 0,
/// BS11 [11:11]
/// Port x set bit y (y=
BS11: u1 = 0,
/// BS12 [12:12]
/// Port x set bit y (y=
BS12: u1 = 0,
/// BS13 [13:13]
/// Port x set bit y (y=
BS13: u1 = 0,
/// BS14 [14:14]
/// Port x set bit y (y=
BS14: u1 = 0,
/// BS15 [15:15]
/// Port x set bit y (y=
BS15: u1 = 0,
/// BR0 [16:16]
/// Port x reset bit y (y =
BR0: u1 = 0,
/// BR1 [17:17]
/// Port x reset bit y (y =
BR1: u1 = 0,
/// BR2 [18:18]
/// Port x reset bit y (y =
BR2: u1 = 0,
/// BR3 [19:19]
/// Port x reset bit y (y =
BR3: u1 = 0,
/// BR4 [20:20]
/// Port x reset bit y (y =
BR4: u1 = 0,
/// BR5 [21:21]
/// Port x reset bit y (y =
BR5: u1 = 0,
/// BR6 [22:22]
/// Port x reset bit y (y =
BR6: u1 = 0,
/// BR7 [23:23]
/// Port x reset bit y (y =
BR7: u1 = 0,
/// BR8 [24:24]
/// Port x reset bit y (y =
BR8: u1 = 0,
/// BR9 [25:25]
/// Port x reset bit y (y =
BR9: u1 = 0,
/// BR10 [26:26]
/// Port x reset bit y (y =
BR10: u1 = 0,
/// BR11 [27:27]
/// Port x reset bit y (y =
BR11: u1 = 0,
/// BR12 [28:28]
/// Port x reset bit y (y =
BR12: u1 = 0,
/// BR13 [29:29]
/// Port x reset bit y (y =
BR13: u1 = 0,
/// BR14 [30:30]
/// Port x reset bit y (y =
BR14: u1 = 0,
/// BR15 [31:31]
/// Port x reset bit y (y =
BR15: u1 = 0,
};
/// GPIO port bit set/reset
pub const BSRR = Register(BSRR_val).init(base_address + 0x18);

/// LCKR
const LCKR_val = packed struct {
/// LCK0 [0:0]
/// Port x lock bit y (y=
LCK0: u1 = 0,
/// LCK1 [1:1]
/// Port x lock bit y (y=
LCK1: u1 = 0,
/// LCK2 [2:2]
/// Port x lock bit y (y=
LCK2: u1 = 0,
/// LCK3 [3:3]
/// Port x lock bit y (y=
LCK3: u1 = 0,
/// LCK4 [4:4]
/// Port x lock bit y (y=
LCK4: u1 = 0,
/// LCK5 [5:5]
/// Port x lock bit y (y=
LCK5: u1 = 0,
/// LCK6 [6:6]
/// Port x lock bit y (y=
LCK6: u1 = 0,
/// LCK7 [7:7]
/// Port x lock bit y (y=
LCK7: u1 = 0,
/// LCK8 [8:8]
/// Port x lock bit y (y=
LCK8: u1 = 0,
/// LCK9 [9:9]
/// Port x lock bit y (y=
LCK9: u1 = 0,
/// LCK10 [10:10]
/// Port x lock bit y (y=
LCK10: u1 = 0,
/// LCK11 [11:11]
/// Port x lock bit y (y=
LCK11: u1 = 0,
/// LCK12 [12:12]
/// Port x lock bit y (y=
LCK12: u1 = 0,
/// LCK13 [13:13]
/// Port x lock bit y (y=
LCK13: u1 = 0,
/// LCK14 [14:14]
/// Port x lock bit y (y=
LCK14: u1 = 0,
/// LCK15 [15:15]
/// Port x lock bit y (y=
LCK15: u1 = 0,
/// LCKK [16:16]
/// Port x lock bit y (y=
LCKK: u1 = 0,
/// unused [17:31]
_unused17: u7 = 0,
_unused24: u8 = 0,
};
/// GPIO port configuration lock
pub const LCKR = Register(LCKR_val).init(base_address + 0x1c);

/// AFRL
const AFRL_val = packed struct {
/// AFSEL0 [0:3]
/// Alternate function selection for port x
AFSEL0: u4 = 0,
/// AFSEL1 [4:7]
/// Alternate function selection for port x
AFSEL1: u4 = 0,
/// AFSEL2 [8:11]
/// Alternate function selection for port x
AFSEL2: u4 = 0,
/// AFSEL3 [12:15]
/// Alternate function selection for port x
AFSEL3: u4 = 0,
/// AFSEL4 [16:19]
/// Alternate function selection for port x
AFSEL4: u4 = 0,
/// AFSEL5 [20:23]
/// Alternate function selection for port x
AFSEL5: u4 = 0,
/// AFSEL6 [24:27]
/// Alternate function selection for port x
AFSEL6: u4 = 0,
/// AFSEL7 [28:31]
/// Alternate function selection for port x
AFSEL7: u4 = 0,
};
/// GPIO alternate function low
pub const AFRL = Register(AFRL_val).init(base_address + 0x20);

/// AFRH
const AFRH_val = packed struct {
/// AFSEL8 [0:3]
/// Alternate function selection for port x
AFSEL8: u4 = 0,
/// AFSEL9 [4:7]
/// Alternate function selection for port x
AFSEL9: u4 = 0,
/// AFSEL10 [8:11]
/// Alternate function selection for port x
AFSEL10: u4 = 0,
/// AFSEL11 [12:15]
/// Alternate function selection for port x
AFSEL11: u4 = 0,
/// AFSEL12 [16:19]
/// Alternate function selection for port x
AFSEL12: u4 = 0,
/// AFSEL13 [20:23]
/// Alternate function selection for port x
AFSEL13: u4 = 0,
/// AFSEL14 [24:27]
/// Alternate function selection for port x
AFSEL14: u4 = 0,
/// AFSEL15 [28:31]
/// Alternate function selection for port x
AFSEL15: u4 = 0,
};
/// GPIO alternate function high
pub const AFRH = Register(AFRH_val).init(base_address + 0x24);

/// BRR
const BRR_val = packed struct {
/// BR0 [0:0]
/// Port x Reset bit y (y= 0 ..
BR0: u1 = 0,
/// BR1 [1:1]
/// Port x Reset bit y (y= 0 ..
BR1: u1 = 0,
/// BR2 [2:2]
/// Port x Reset bit y (y= 0 ..
BR2: u1 = 0,
/// BR3 [3:3]
/// Port x Reset bit y (y= 0 ..
BR3: u1 = 0,
/// BR4 [4:4]
/// Port x Reset bit y (y= 0 ..
BR4: u1 = 0,
/// BR5 [5:5]
/// Port x Reset bit y (y= 0 ..
BR5: u1 = 0,
/// BR6 [6:6]
/// Port x Reset bit y (y= 0 ..
BR6: u1 = 0,
/// BR7 [7:7]
/// Port x Reset bit y (y= 0 ..
BR7: u1 = 0,
/// BR8 [8:8]
/// Port x Reset bit y (y= 0 ..
BR8: u1 = 0,
/// BR9 [9:9]
/// Port x Reset bit y (y= 0 ..
BR9: u1 = 0,
/// BR10 [10:10]
/// Port x Reset bit y (y= 0 ..
BR10: u1 = 0,
/// BR11 [11:11]
/// Port x Reset bit y (y= 0 ..
BR11: u1 = 0,
/// BR12 [12:12]
/// Port x Reset bit y (y= 0 ..
BR12: u1 = 0,
/// BR13 [13:13]
/// Port x Reset bit y (y= 0 ..
BR13: u1 = 0,
/// BR14 [14:14]
/// Port x Reset bit y (y= 0 ..
BR14: u1 = 0,
/// BR15 [15:15]
/// Port x Reset bit y (y= 0 ..
BR15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port bit reset register
pub const BRR = Register(BRR_val).init(base_address + 0x28);
};

/// General-purpose I/Os
pub const GPIOB = struct {

const base_address = 0x50000400;
/// MODER
const MODER_val = packed struct {
/// MODE0 [0:1]
/// Port x configuration bits (y =
MODE0: u2 = 3,
/// MODE1 [2:3]
/// Port x configuration bits (y =
MODE1: u2 = 3,
/// MODE2 [4:5]
/// Port x configuration bits (y =
MODE2: u2 = 3,
/// MODE3 [6:7]
/// Port x configuration bits (y =
MODE3: u2 = 3,
/// MODE4 [8:9]
/// Port x configuration bits (y =
MODE4: u2 = 3,
/// MODE5 [10:11]
/// Port x configuration bits (y =
MODE5: u2 = 3,
/// MODE6 [12:13]
/// Port x configuration bits (y =
MODE6: u2 = 3,
/// MODE7 [14:15]
/// Port x configuration bits (y =
MODE7: u2 = 3,
/// MODE8 [16:17]
/// Port x configuration bits (y =
MODE8: u2 = 3,
/// MODE9 [18:19]
/// Port x configuration bits (y =
MODE9: u2 = 3,
/// MODE10 [20:21]
/// Port x configuration bits (y =
MODE10: u2 = 3,
/// MODE11 [22:23]
/// Port x configuration bits (y =
MODE11: u2 = 3,
/// MODE12 [24:25]
/// Port x configuration bits (y =
MODE12: u2 = 3,
/// MODE13 [26:27]
/// Port x configuration bits (y =
MODE13: u2 = 3,
/// MODE14 [28:29]
/// Port x configuration bits (y =
MODE14: u2 = 3,
/// MODE15 [30:31]
/// Port x configuration bits (y =
MODE15: u2 = 3,
};
/// GPIO port mode register
pub const MODER = Register(MODER_val).init(base_address + 0x0);

/// OTYPER
const OTYPER_val = packed struct {
/// OT0 [0:0]
/// Port x configuration bits (y =
OT0: u1 = 0,
/// OT1 [1:1]
/// Port x configuration bits (y =
OT1: u1 = 0,
/// OT2 [2:2]
/// Port x configuration bits (y =
OT2: u1 = 0,
/// OT3 [3:3]
/// Port x configuration bits (y =
OT3: u1 = 0,
/// OT4 [4:4]
/// Port x configuration bits (y =
OT4: u1 = 0,
/// OT5 [5:5]
/// Port x configuration bits (y =
OT5: u1 = 0,
/// OT6 [6:6]
/// Port x configuration bits (y =
OT6: u1 = 0,
/// OT7 [7:7]
/// Port x configuration bits (y =
OT7: u1 = 0,
/// OT8 [8:8]
/// Port x configuration bits (y =
OT8: u1 = 0,
/// OT9 [9:9]
/// Port x configuration bits (y =
OT9: u1 = 0,
/// OT10 [10:10]
/// Port x configuration bits (y =
OT10: u1 = 0,
/// OT11 [11:11]
/// Port x configuration bits (y =
OT11: u1 = 0,
/// OT12 [12:12]
/// Port x configuration bits (y =
OT12: u1 = 0,
/// OT13 [13:13]
/// Port x configuration bits (y =
OT13: u1 = 0,
/// OT14 [14:14]
/// Port x configuration bits (y =
OT14: u1 = 0,
/// OT15 [15:15]
/// Port x configuration bits (y =
OT15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port output type register
pub const OTYPER = Register(OTYPER_val).init(base_address + 0x4);

/// OSPEEDR
const OSPEEDR_val = packed struct {
/// OSPEED0 [0:1]
/// Port x configuration bits (y =
OSPEED0: u2 = 0,
/// OSPEED1 [2:3]
/// Port x configuration bits (y =
OSPEED1: u2 = 0,
/// OSPEED2 [4:5]
/// Port x configuration bits (y =
OSPEED2: u2 = 0,
/// OSPEED3 [6:7]
/// Port x configuration bits (y =
OSPEED3: u2 = 0,
/// OSPEED4 [8:9]
/// Port x configuration bits (y =
OSPEED4: u2 = 0,
/// OSPEED5 [10:11]
/// Port x configuration bits (y =
OSPEED5: u2 = 0,
/// OSPEED6 [12:13]
/// Port x configuration bits (y =
OSPEED6: u2 = 0,
/// OSPEED7 [14:15]
/// Port x configuration bits (y =
OSPEED7: u2 = 0,
/// OSPEED8 [16:17]
/// Port x configuration bits (y =
OSPEED8: u2 = 0,
/// OSPEED9 [18:19]
/// Port x configuration bits (y =
OSPEED9: u2 = 0,
/// OSPEED10 [20:21]
/// Port x configuration bits (y =
OSPEED10: u2 = 0,
/// OSPEED11 [22:23]
/// Port x configuration bits (y =
OSPEED11: u2 = 0,
/// OSPEED12 [24:25]
/// Port x configuration bits (y =
OSPEED12: u2 = 0,
/// OSPEED13 [26:27]
/// Port x configuration bits (y =
OSPEED13: u2 = 0,
/// OSPEED14 [28:29]
/// Port x configuration bits (y =
OSPEED14: u2 = 0,
/// OSPEED15 [30:31]
/// Port x configuration bits (y =
OSPEED15: u2 = 0,
};
/// GPIO port output speed
pub const OSPEEDR = Register(OSPEEDR_val).init(base_address + 0x8);

/// PUPDR
const PUPDR_val = packed struct {
/// PUPD0 [0:1]
/// Port x configuration bits (y =
PUPD0: u2 = 0,
/// PUPD1 [2:3]
/// Port x configuration bits (y =
PUPD1: u2 = 0,
/// PUPD2 [4:5]
/// Port x configuration bits (y =
PUPD2: u2 = 0,
/// PUPD3 [6:7]
/// Port x configuration bits (y =
PUPD3: u2 = 0,
/// PUPD4 [8:9]
/// Port x configuration bits (y =
PUPD4: u2 = 0,
/// PUPD5 [10:11]
/// Port x configuration bits (y =
PUPD5: u2 = 0,
/// PUPD6 [12:13]
/// Port x configuration bits (y =
PUPD6: u2 = 0,
/// PUPD7 [14:15]
/// Port x configuration bits (y =
PUPD7: u2 = 0,
/// PUPD8 [16:17]
/// Port x configuration bits (y =
PUPD8: u2 = 0,
/// PUPD9 [18:19]
/// Port x configuration bits (y =
PUPD9: u2 = 0,
/// PUPD10 [20:21]
/// Port x configuration bits (y =
PUPD10: u2 = 0,
/// PUPD11 [22:23]
/// Port x configuration bits (y =
PUPD11: u2 = 0,
/// PUPD12 [24:25]
/// Port x configuration bits (y =
PUPD12: u2 = 0,
/// PUPD13 [26:27]
/// Port x configuration bits (y =
PUPD13: u2 = 0,
/// PUPD14 [28:29]
/// Port x configuration bits (y =
PUPD14: u2 = 0,
/// PUPD15 [30:31]
/// Port x configuration bits (y =
PUPD15: u2 = 0,
};
/// GPIO port pull-up/pull-down
pub const PUPDR = Register(PUPDR_val).init(base_address + 0xc);

/// IDR
const IDR_val = packed struct {
/// ID0 [0:0]
/// Port input data bit (y =
ID0: u1 = 0,
/// ID1 [1:1]
/// Port input data bit (y =
ID1: u1 = 0,
/// ID2 [2:2]
/// Port input data bit (y =
ID2: u1 = 0,
/// ID3 [3:3]
/// Port input data bit (y =
ID3: u1 = 0,
/// ID4 [4:4]
/// Port input data bit (y =
ID4: u1 = 0,
/// ID5 [5:5]
/// Port input data bit (y =
ID5: u1 = 0,
/// ID6 [6:6]
/// Port input data bit (y =
ID6: u1 = 0,
/// ID7 [7:7]
/// Port input data bit (y =
ID7: u1 = 0,
/// ID8 [8:8]
/// Port input data bit (y =
ID8: u1 = 0,
/// ID9 [9:9]
/// Port input data bit (y =
ID9: u1 = 0,
/// ID10 [10:10]
/// Port input data bit (y =
ID10: u1 = 0,
/// ID11 [11:11]
/// Port input data bit (y =
ID11: u1 = 0,
/// ID12 [12:12]
/// Port input data bit (y =
ID12: u1 = 0,
/// ID13 [13:13]
/// Port input data bit (y =
ID13: u1 = 0,
/// ID14 [14:14]
/// Port input data bit (y =
ID14: u1 = 0,
/// ID15 [15:15]
/// Port input data bit (y =
ID15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port input data register
pub const IDR = Register(IDR_val).init(base_address + 0x10);

/// ODR
const ODR_val = packed struct {
/// OD0 [0:0]
/// Port output data bit (y =
OD0: u1 = 0,
/// OD1 [1:1]
/// Port output data bit (y =
OD1: u1 = 0,
/// OD2 [2:2]
/// Port output data bit (y =
OD2: u1 = 0,
/// OD3 [3:3]
/// Port output data bit (y =
OD3: u1 = 0,
/// OD4 [4:4]
/// Port output data bit (y =
OD4: u1 = 0,
/// OD5 [5:5]
/// Port output data bit (y =
OD5: u1 = 0,
/// OD6 [6:6]
/// Port output data bit (y =
OD6: u1 = 0,
/// OD7 [7:7]
/// Port output data bit (y =
OD7: u1 = 0,
/// OD8 [8:8]
/// Port output data bit (y =
OD8: u1 = 0,
/// OD9 [9:9]
/// Port output data bit (y =
OD9: u1 = 0,
/// OD10 [10:10]
/// Port output data bit (y =
OD10: u1 = 0,
/// OD11 [11:11]
/// Port output data bit (y =
OD11: u1 = 0,
/// OD12 [12:12]
/// Port output data bit (y =
OD12: u1 = 0,
/// OD13 [13:13]
/// Port output data bit (y =
OD13: u1 = 0,
/// OD14 [14:14]
/// Port output data bit (y =
OD14: u1 = 0,
/// OD15 [15:15]
/// Port output data bit (y =
OD15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port output data register
pub const ODR = Register(ODR_val).init(base_address + 0x14);

/// BSRR
const BSRR_val = packed struct {
/// BS0 [0:0]
/// Port x set bit y (y=
BS0: u1 = 0,
/// BS1 [1:1]
/// Port x set bit y (y=
BS1: u1 = 0,
/// BS2 [2:2]
/// Port x set bit y (y=
BS2: u1 = 0,
/// BS3 [3:3]
/// Port x set bit y (y=
BS3: u1 = 0,
/// BS4 [4:4]
/// Port x set bit y (y=
BS4: u1 = 0,
/// BS5 [5:5]
/// Port x set bit y (y=
BS5: u1 = 0,
/// BS6 [6:6]
/// Port x set bit y (y=
BS6: u1 = 0,
/// BS7 [7:7]
/// Port x set bit y (y=
BS7: u1 = 0,
/// BS8 [8:8]
/// Port x set bit y (y=
BS8: u1 = 0,
/// BS9 [9:9]
/// Port x set bit y (y=
BS9: u1 = 0,
/// BS10 [10:10]
/// Port x set bit y (y=
BS10: u1 = 0,
/// BS11 [11:11]
/// Port x set bit y (y=
BS11: u1 = 0,
/// BS12 [12:12]
/// Port x set bit y (y=
BS12: u1 = 0,
/// BS13 [13:13]
/// Port x set bit y (y=
BS13: u1 = 0,
/// BS14 [14:14]
/// Port x set bit y (y=
BS14: u1 = 0,
/// BS15 [15:15]
/// Port x set bit y (y=
BS15: u1 = 0,
/// BR0 [16:16]
/// Port x reset bit y (y =
BR0: u1 = 0,
/// BR1 [17:17]
/// Port x reset bit y (y =
BR1: u1 = 0,
/// BR2 [18:18]
/// Port x reset bit y (y =
BR2: u1 = 0,
/// BR3 [19:19]
/// Port x reset bit y (y =
BR3: u1 = 0,
/// BR4 [20:20]
/// Port x reset bit y (y =
BR4: u1 = 0,
/// BR5 [21:21]
/// Port x reset bit y (y =
BR5: u1 = 0,
/// BR6 [22:22]
/// Port x reset bit y (y =
BR6: u1 = 0,
/// BR7 [23:23]
/// Port x reset bit y (y =
BR7: u1 = 0,
/// BR8 [24:24]
/// Port x reset bit y (y =
BR8: u1 = 0,
/// BR9 [25:25]
/// Port x reset bit y (y =
BR9: u1 = 0,
/// BR10 [26:26]
/// Port x reset bit y (y =
BR10: u1 = 0,
/// BR11 [27:27]
/// Port x reset bit y (y =
BR11: u1 = 0,
/// BR12 [28:28]
/// Port x reset bit y (y =
BR12: u1 = 0,
/// BR13 [29:29]
/// Port x reset bit y (y =
BR13: u1 = 0,
/// BR14 [30:30]
/// Port x reset bit y (y =
BR14: u1 = 0,
/// BR15 [31:31]
/// Port x reset bit y (y =
BR15: u1 = 0,
};
/// GPIO port bit set/reset
pub const BSRR = Register(BSRR_val).init(base_address + 0x18);

/// LCKR
const LCKR_val = packed struct {
/// LCK0 [0:0]
/// Port x lock bit y (y=
LCK0: u1 = 0,
/// LCK1 [1:1]
/// Port x lock bit y (y=
LCK1: u1 = 0,
/// LCK2 [2:2]
/// Port x lock bit y (y=
LCK2: u1 = 0,
/// LCK3 [3:3]
/// Port x lock bit y (y=
LCK3: u1 = 0,
/// LCK4 [4:4]
/// Port x lock bit y (y=
LCK4: u1 = 0,
/// LCK5 [5:5]
/// Port x lock bit y (y=
LCK5: u1 = 0,
/// LCK6 [6:6]
/// Port x lock bit y (y=
LCK6: u1 = 0,
/// LCK7 [7:7]
/// Port x lock bit y (y=
LCK7: u1 = 0,
/// LCK8 [8:8]
/// Port x lock bit y (y=
LCK8: u1 = 0,
/// LCK9 [9:9]
/// Port x lock bit y (y=
LCK9: u1 = 0,
/// LCK10 [10:10]
/// Port x lock bit y (y=
LCK10: u1 = 0,
/// LCK11 [11:11]
/// Port x lock bit y (y=
LCK11: u1 = 0,
/// LCK12 [12:12]
/// Port x lock bit y (y=
LCK12: u1 = 0,
/// LCK13 [13:13]
/// Port x lock bit y (y=
LCK13: u1 = 0,
/// LCK14 [14:14]
/// Port x lock bit y (y=
LCK14: u1 = 0,
/// LCK15 [15:15]
/// Port x lock bit y (y=
LCK15: u1 = 0,
/// LCKK [16:16]
/// Port x lock bit y (y=
LCKK: u1 = 0,
/// unused [17:31]
_unused17: u7 = 0,
_unused24: u8 = 0,
};
/// GPIO port configuration lock
pub const LCKR = Register(LCKR_val).init(base_address + 0x1c);

/// AFRL
const AFRL_val = packed struct {
/// AFSEL0 [0:3]
/// Alternate function selection for port x
AFSEL0: u4 = 0,
/// AFSEL1 [4:7]
/// Alternate function selection for port x
AFSEL1: u4 = 0,
/// AFSEL2 [8:11]
/// Alternate function selection for port x
AFSEL2: u4 = 0,
/// AFSEL3 [12:15]
/// Alternate function selection for port x
AFSEL3: u4 = 0,
/// AFSEL4 [16:19]
/// Alternate function selection for port x
AFSEL4: u4 = 0,
/// AFSEL5 [20:23]
/// Alternate function selection for port x
AFSEL5: u4 = 0,
/// AFSEL6 [24:27]
/// Alternate function selection for port x
AFSEL6: u4 = 0,
/// AFSEL7 [28:31]
/// Alternate function selection for port x
AFSEL7: u4 = 0,
};
/// GPIO alternate function low
pub const AFRL = Register(AFRL_val).init(base_address + 0x20);

/// AFRH
const AFRH_val = packed struct {
/// AFSEL8 [0:3]
/// Alternate function selection for port x
AFSEL8: u4 = 0,
/// AFSEL9 [4:7]
/// Alternate function selection for port x
AFSEL9: u4 = 0,
/// AFSEL10 [8:11]
/// Alternate function selection for port x
AFSEL10: u4 = 0,
/// AFSEL11 [12:15]
/// Alternate function selection for port x
AFSEL11: u4 = 0,
/// AFSEL12 [16:19]
/// Alternate function selection for port x
AFSEL12: u4 = 0,
/// AFSEL13 [20:23]
/// Alternate function selection for port x
AFSEL13: u4 = 0,
/// AFSEL14 [24:27]
/// Alternate function selection for port x
AFSEL14: u4 = 0,
/// AFSEL15 [28:31]
/// Alternate function selection for port x
AFSEL15: u4 = 0,
};
/// GPIO alternate function high
pub const AFRH = Register(AFRH_val).init(base_address + 0x24);

/// BRR
const BRR_val = packed struct {
/// BR0 [0:0]
/// Port x Reset bit y (y= 0 ..
BR0: u1 = 0,
/// BR1 [1:1]
/// Port x Reset bit y (y= 0 ..
BR1: u1 = 0,
/// BR2 [2:2]
/// Port x Reset bit y (y= 0 ..
BR2: u1 = 0,
/// BR3 [3:3]
/// Port x Reset bit y (y= 0 ..
BR3: u1 = 0,
/// BR4 [4:4]
/// Port x Reset bit y (y= 0 ..
BR4: u1 = 0,
/// BR5 [5:5]
/// Port x Reset bit y (y= 0 ..
BR5: u1 = 0,
/// BR6 [6:6]
/// Port x Reset bit y (y= 0 ..
BR6: u1 = 0,
/// BR7 [7:7]
/// Port x Reset bit y (y= 0 ..
BR7: u1 = 0,
/// BR8 [8:8]
/// Port x Reset bit y (y= 0 ..
BR8: u1 = 0,
/// BR9 [9:9]
/// Port x Reset bit y (y= 0 ..
BR9: u1 = 0,
/// BR10 [10:10]
/// Port x Reset bit y (y= 0 ..
BR10: u1 = 0,
/// BR11 [11:11]
/// Port x Reset bit y (y= 0 ..
BR11: u1 = 0,
/// BR12 [12:12]
/// Port x Reset bit y (y= 0 ..
BR12: u1 = 0,
/// BR13 [13:13]
/// Port x Reset bit y (y= 0 ..
BR13: u1 = 0,
/// BR14 [14:14]
/// Port x Reset bit y (y= 0 ..
BR14: u1 = 0,
/// BR15 [15:15]
/// Port x Reset bit y (y= 0 ..
BR15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port bit reset register
pub const BRR = Register(BRR_val).init(base_address + 0x28);
};

/// General-purpose I/Os
pub const GPIOC = struct {

const base_address = 0x50000800;
/// MODER
const MODER_val = packed struct {
/// MODE0 [0:1]
/// Port x configuration bits (y =
MODE0: u2 = 3,
/// MODE1 [2:3]
/// Port x configuration bits (y =
MODE1: u2 = 3,
/// MODE2 [4:5]
/// Port x configuration bits (y =
MODE2: u2 = 3,
/// MODE3 [6:7]
/// Port x configuration bits (y =
MODE3: u2 = 3,
/// MODE4 [8:9]
/// Port x configuration bits (y =
MODE4: u2 = 3,
/// MODE5 [10:11]
/// Port x configuration bits (y =
MODE5: u2 = 3,
/// MODE6 [12:13]
/// Port x configuration bits (y =
MODE6: u2 = 3,
/// MODE7 [14:15]
/// Port x configuration bits (y =
MODE7: u2 = 3,
/// MODE8 [16:17]
/// Port x configuration bits (y =
MODE8: u2 = 3,
/// MODE9 [18:19]
/// Port x configuration bits (y =
MODE9: u2 = 3,
/// MODE10 [20:21]
/// Port x configuration bits (y =
MODE10: u2 = 3,
/// MODE11 [22:23]
/// Port x configuration bits (y =
MODE11: u2 = 3,
/// MODE12 [24:25]
/// Port x configuration bits (y =
MODE12: u2 = 3,
/// MODE13 [26:27]
/// Port x configuration bits (y =
MODE13: u2 = 3,
/// MODE14 [28:29]
/// Port x configuration bits (y =
MODE14: u2 = 3,
/// MODE15 [30:31]
/// Port x configuration bits (y =
MODE15: u2 = 3,
};
/// GPIO port mode register
pub const MODER = Register(MODER_val).init(base_address + 0x0);

/// OTYPER
const OTYPER_val = packed struct {
/// OT0 [0:0]
/// Port x configuration bits (y =
OT0: u1 = 0,
/// OT1 [1:1]
/// Port x configuration bits (y =
OT1: u1 = 0,
/// OT2 [2:2]
/// Port x configuration bits (y =
OT2: u1 = 0,
/// OT3 [3:3]
/// Port x configuration bits (y =
OT3: u1 = 0,
/// OT4 [4:4]
/// Port x configuration bits (y =
OT4: u1 = 0,
/// OT5 [5:5]
/// Port x configuration bits (y =
OT5: u1 = 0,
/// OT6 [6:6]
/// Port x configuration bits (y =
OT6: u1 = 0,
/// OT7 [7:7]
/// Port x configuration bits (y =
OT7: u1 = 0,
/// OT8 [8:8]
/// Port x configuration bits (y =
OT8: u1 = 0,
/// OT9 [9:9]
/// Port x configuration bits (y =
OT9: u1 = 0,
/// OT10 [10:10]
/// Port x configuration bits (y =
OT10: u1 = 0,
/// OT11 [11:11]
/// Port x configuration bits (y =
OT11: u1 = 0,
/// OT12 [12:12]
/// Port x configuration bits (y =
OT12: u1 = 0,
/// OT13 [13:13]
/// Port x configuration bits (y =
OT13: u1 = 0,
/// OT14 [14:14]
/// Port x configuration bits (y =
OT14: u1 = 0,
/// OT15 [15:15]
/// Port x configuration bits (y =
OT15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port output type register
pub const OTYPER = Register(OTYPER_val).init(base_address + 0x4);

/// OSPEEDR
const OSPEEDR_val = packed struct {
/// OSPEED0 [0:1]
/// Port x configuration bits (y =
OSPEED0: u2 = 0,
/// OSPEED1 [2:3]
/// Port x configuration bits (y =
OSPEED1: u2 = 0,
/// OSPEED2 [4:5]
/// Port x configuration bits (y =
OSPEED2: u2 = 0,
/// OSPEED3 [6:7]
/// Port x configuration bits (y =
OSPEED3: u2 = 0,
/// OSPEED4 [8:9]
/// Port x configuration bits (y =
OSPEED4: u2 = 0,
/// OSPEED5 [10:11]
/// Port x configuration bits (y =
OSPEED5: u2 = 0,
/// OSPEED6 [12:13]
/// Port x configuration bits (y =
OSPEED6: u2 = 0,
/// OSPEED7 [14:15]
/// Port x configuration bits (y =
OSPEED7: u2 = 0,
/// OSPEED8 [16:17]
/// Port x configuration bits (y =
OSPEED8: u2 = 0,
/// OSPEED9 [18:19]
/// Port x configuration bits (y =
OSPEED9: u2 = 0,
/// OSPEED10 [20:21]
/// Port x configuration bits (y =
OSPEED10: u2 = 0,
/// OSPEED11 [22:23]
/// Port x configuration bits (y =
OSPEED11: u2 = 0,
/// OSPEED12 [24:25]
/// Port x configuration bits (y =
OSPEED12: u2 = 0,
/// OSPEED13 [26:27]
/// Port x configuration bits (y =
OSPEED13: u2 = 0,
/// OSPEED14 [28:29]
/// Port x configuration bits (y =
OSPEED14: u2 = 0,
/// OSPEED15 [30:31]
/// Port x configuration bits (y =
OSPEED15: u2 = 0,
};
/// GPIO port output speed
pub const OSPEEDR = Register(OSPEEDR_val).init(base_address + 0x8);

/// PUPDR
const PUPDR_val = packed struct {
/// PUPD0 [0:1]
/// Port x configuration bits (y =
PUPD0: u2 = 0,
/// PUPD1 [2:3]
/// Port x configuration bits (y =
PUPD1: u2 = 0,
/// PUPD2 [4:5]
/// Port x configuration bits (y =
PUPD2: u2 = 0,
/// PUPD3 [6:7]
/// Port x configuration bits (y =
PUPD3: u2 = 0,
/// PUPD4 [8:9]
/// Port x configuration bits (y =
PUPD4: u2 = 0,
/// PUPD5 [10:11]
/// Port x configuration bits (y =
PUPD5: u2 = 0,
/// PUPD6 [12:13]
/// Port x configuration bits (y =
PUPD6: u2 = 0,
/// PUPD7 [14:15]
/// Port x configuration bits (y =
PUPD7: u2 = 0,
/// PUPD8 [16:17]
/// Port x configuration bits (y =
PUPD8: u2 = 0,
/// PUPD9 [18:19]
/// Port x configuration bits (y =
PUPD9: u2 = 0,
/// PUPD10 [20:21]
/// Port x configuration bits (y =
PUPD10: u2 = 0,
/// PUPD11 [22:23]
/// Port x configuration bits (y =
PUPD11: u2 = 0,
/// PUPD12 [24:25]
/// Port x configuration bits (y =
PUPD12: u2 = 0,
/// PUPD13 [26:27]
/// Port x configuration bits (y =
PUPD13: u2 = 0,
/// PUPD14 [28:29]
/// Port x configuration bits (y =
PUPD14: u2 = 0,
/// PUPD15 [30:31]
/// Port x configuration bits (y =
PUPD15: u2 = 0,
};
/// GPIO port pull-up/pull-down
pub const PUPDR = Register(PUPDR_val).init(base_address + 0xc);

/// IDR
const IDR_val = packed struct {
/// ID0 [0:0]
/// Port input data bit (y =
ID0: u1 = 0,
/// ID1 [1:1]
/// Port input data bit (y =
ID1: u1 = 0,
/// ID2 [2:2]
/// Port input data bit (y =
ID2: u1 = 0,
/// ID3 [3:3]
/// Port input data bit (y =
ID3: u1 = 0,
/// ID4 [4:4]
/// Port input data bit (y =
ID4: u1 = 0,
/// ID5 [5:5]
/// Port input data bit (y =
ID5: u1 = 0,
/// ID6 [6:6]
/// Port input data bit (y =
ID6: u1 = 0,
/// ID7 [7:7]
/// Port input data bit (y =
ID7: u1 = 0,
/// ID8 [8:8]
/// Port input data bit (y =
ID8: u1 = 0,
/// ID9 [9:9]
/// Port input data bit (y =
ID9: u1 = 0,
/// ID10 [10:10]
/// Port input data bit (y =
ID10: u1 = 0,
/// ID11 [11:11]
/// Port input data bit (y =
ID11: u1 = 0,
/// ID12 [12:12]
/// Port input data bit (y =
ID12: u1 = 0,
/// ID13 [13:13]
/// Port input data bit (y =
ID13: u1 = 0,
/// ID14 [14:14]
/// Port input data bit (y =
ID14: u1 = 0,
/// ID15 [15:15]
/// Port input data bit (y =
ID15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port input data register
pub const IDR = Register(IDR_val).init(base_address + 0x10);

/// ODR
const ODR_val = packed struct {
/// OD0 [0:0]
/// Port output data bit (y =
OD0: u1 = 0,
/// OD1 [1:1]
/// Port output data bit (y =
OD1: u1 = 0,
/// OD2 [2:2]
/// Port output data bit (y =
OD2: u1 = 0,
/// OD3 [3:3]
/// Port output data bit (y =
OD3: u1 = 0,
/// OD4 [4:4]
/// Port output data bit (y =
OD4: u1 = 0,
/// OD5 [5:5]
/// Port output data bit (y =
OD5: u1 = 0,
/// OD6 [6:6]
/// Port output data bit (y =
OD6: u1 = 0,
/// OD7 [7:7]
/// Port output data bit (y =
OD7: u1 = 0,
/// OD8 [8:8]
/// Port output data bit (y =
OD8: u1 = 0,
/// OD9 [9:9]
/// Port output data bit (y =
OD9: u1 = 0,
/// OD10 [10:10]
/// Port output data bit (y =
OD10: u1 = 0,
/// OD11 [11:11]
/// Port output data bit (y =
OD11: u1 = 0,
/// OD12 [12:12]
/// Port output data bit (y =
OD12: u1 = 0,
/// OD13 [13:13]
/// Port output data bit (y =
OD13: u1 = 0,
/// OD14 [14:14]
/// Port output data bit (y =
OD14: u1 = 0,
/// OD15 [15:15]
/// Port output data bit (y =
OD15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port output data register
pub const ODR = Register(ODR_val).init(base_address + 0x14);

/// BSRR
const BSRR_val = packed struct {
/// BS0 [0:0]
/// Port x set bit y (y=
BS0: u1 = 0,
/// BS1 [1:1]
/// Port x set bit y (y=
BS1: u1 = 0,
/// BS2 [2:2]
/// Port x set bit y (y=
BS2: u1 = 0,
/// BS3 [3:3]
/// Port x set bit y (y=
BS3: u1 = 0,
/// BS4 [4:4]
/// Port x set bit y (y=
BS4: u1 = 0,
/// BS5 [5:5]
/// Port x set bit y (y=
BS5: u1 = 0,
/// BS6 [6:6]
/// Port x set bit y (y=
BS6: u1 = 0,
/// BS7 [7:7]
/// Port x set bit y (y=
BS7: u1 = 0,
/// BS8 [8:8]
/// Port x set bit y (y=
BS8: u1 = 0,
/// BS9 [9:9]
/// Port x set bit y (y=
BS9: u1 = 0,
/// BS10 [10:10]
/// Port x set bit y (y=
BS10: u1 = 0,
/// BS11 [11:11]
/// Port x set bit y (y=
BS11: u1 = 0,
/// BS12 [12:12]
/// Port x set bit y (y=
BS12: u1 = 0,
/// BS13 [13:13]
/// Port x set bit y (y=
BS13: u1 = 0,
/// BS14 [14:14]
/// Port x set bit y (y=
BS14: u1 = 0,
/// BS15 [15:15]
/// Port x set bit y (y=
BS15: u1 = 0,
/// BR0 [16:16]
/// Port x reset bit y (y =
BR0: u1 = 0,
/// BR1 [17:17]
/// Port x reset bit y (y =
BR1: u1 = 0,
/// BR2 [18:18]
/// Port x reset bit y (y =
BR2: u1 = 0,
/// BR3 [19:19]
/// Port x reset bit y (y =
BR3: u1 = 0,
/// BR4 [20:20]
/// Port x reset bit y (y =
BR4: u1 = 0,
/// BR5 [21:21]
/// Port x reset bit y (y =
BR5: u1 = 0,
/// BR6 [22:22]
/// Port x reset bit y (y =
BR6: u1 = 0,
/// BR7 [23:23]
/// Port x reset bit y (y =
BR7: u1 = 0,
/// BR8 [24:24]
/// Port x reset bit y (y =
BR8: u1 = 0,
/// BR9 [25:25]
/// Port x reset bit y (y =
BR9: u1 = 0,
/// BR10 [26:26]
/// Port x reset bit y (y =
BR10: u1 = 0,
/// BR11 [27:27]
/// Port x reset bit y (y =
BR11: u1 = 0,
/// BR12 [28:28]
/// Port x reset bit y (y =
BR12: u1 = 0,
/// BR13 [29:29]
/// Port x reset bit y (y =
BR13: u1 = 0,
/// BR14 [30:30]
/// Port x reset bit y (y =
BR14: u1 = 0,
/// BR15 [31:31]
/// Port x reset bit y (y =
BR15: u1 = 0,
};
/// GPIO port bit set/reset
pub const BSRR = Register(BSRR_val).init(base_address + 0x18);

/// LCKR
const LCKR_val = packed struct {
/// LCK0 [0:0]
/// Port x lock bit y (y=
LCK0: u1 = 0,
/// LCK1 [1:1]
/// Port x lock bit y (y=
LCK1: u1 = 0,
/// LCK2 [2:2]
/// Port x lock bit y (y=
LCK2: u1 = 0,
/// LCK3 [3:3]
/// Port x lock bit y (y=
LCK3: u1 = 0,
/// LCK4 [4:4]
/// Port x lock bit y (y=
LCK4: u1 = 0,
/// LCK5 [5:5]
/// Port x lock bit y (y=
LCK5: u1 = 0,
/// LCK6 [6:6]
/// Port x lock bit y (y=
LCK6: u1 = 0,
/// LCK7 [7:7]
/// Port x lock bit y (y=
LCK7: u1 = 0,
/// LCK8 [8:8]
/// Port x lock bit y (y=
LCK8: u1 = 0,
/// LCK9 [9:9]
/// Port x lock bit y (y=
LCK9: u1 = 0,
/// LCK10 [10:10]
/// Port x lock bit y (y=
LCK10: u1 = 0,
/// LCK11 [11:11]
/// Port x lock bit y (y=
LCK11: u1 = 0,
/// LCK12 [12:12]
/// Port x lock bit y (y=
LCK12: u1 = 0,
/// LCK13 [13:13]
/// Port x lock bit y (y=
LCK13: u1 = 0,
/// LCK14 [14:14]
/// Port x lock bit y (y=
LCK14: u1 = 0,
/// LCK15 [15:15]
/// Port x lock bit y (y=
LCK15: u1 = 0,
/// LCKK [16:16]
/// Port x lock bit y (y=
LCKK: u1 = 0,
/// unused [17:31]
_unused17: u7 = 0,
_unused24: u8 = 0,
};
/// GPIO port configuration lock
pub const LCKR = Register(LCKR_val).init(base_address + 0x1c);

/// AFRL
const AFRL_val = packed struct {
/// AFSEL0 [0:3]
/// Alternate function selection for port x
AFSEL0: u4 = 0,
/// AFSEL1 [4:7]
/// Alternate function selection for port x
AFSEL1: u4 = 0,
/// AFSEL2 [8:11]
/// Alternate function selection for port x
AFSEL2: u4 = 0,
/// AFSEL3 [12:15]
/// Alternate function selection for port x
AFSEL3: u4 = 0,
/// AFSEL4 [16:19]
/// Alternate function selection for port x
AFSEL4: u4 = 0,
/// AFSEL5 [20:23]
/// Alternate function selection for port x
AFSEL5: u4 = 0,
/// AFSEL6 [24:27]
/// Alternate function selection for port x
AFSEL6: u4 = 0,
/// AFSEL7 [28:31]
/// Alternate function selection for port x
AFSEL7: u4 = 0,
};
/// GPIO alternate function low
pub const AFRL = Register(AFRL_val).init(base_address + 0x20);

/// AFRH
const AFRH_val = packed struct {
/// AFSEL8 [0:3]
/// Alternate function selection for port x
AFSEL8: u4 = 0,
/// AFSEL9 [4:7]
/// Alternate function selection for port x
AFSEL9: u4 = 0,
/// AFSEL10 [8:11]
/// Alternate function selection for port x
AFSEL10: u4 = 0,
/// AFSEL11 [12:15]
/// Alternate function selection for port x
AFSEL11: u4 = 0,
/// AFSEL12 [16:19]
/// Alternate function selection for port x
AFSEL12: u4 = 0,
/// AFSEL13 [20:23]
/// Alternate function selection for port x
AFSEL13: u4 = 0,
/// AFSEL14 [24:27]
/// Alternate function selection for port x
AFSEL14: u4 = 0,
/// AFSEL15 [28:31]
/// Alternate function selection for port x
AFSEL15: u4 = 0,
};
/// GPIO alternate function high
pub const AFRH = Register(AFRH_val).init(base_address + 0x24);

/// BRR
const BRR_val = packed struct {
/// BR0 [0:0]
/// Port x Reset bit y (y= 0 ..
BR0: u1 = 0,
/// BR1 [1:1]
/// Port x Reset bit y (y= 0 ..
BR1: u1 = 0,
/// BR2 [2:2]
/// Port x Reset bit y (y= 0 ..
BR2: u1 = 0,
/// BR3 [3:3]
/// Port x Reset bit y (y= 0 ..
BR3: u1 = 0,
/// BR4 [4:4]
/// Port x Reset bit y (y= 0 ..
BR4: u1 = 0,
/// BR5 [5:5]
/// Port x Reset bit y (y= 0 ..
BR5: u1 = 0,
/// BR6 [6:6]
/// Port x Reset bit y (y= 0 ..
BR6: u1 = 0,
/// BR7 [7:7]
/// Port x Reset bit y (y= 0 ..
BR7: u1 = 0,
/// BR8 [8:8]
/// Port x Reset bit y (y= 0 ..
BR8: u1 = 0,
/// BR9 [9:9]
/// Port x Reset bit y (y= 0 ..
BR9: u1 = 0,
/// BR10 [10:10]
/// Port x Reset bit y (y= 0 ..
BR10: u1 = 0,
/// BR11 [11:11]
/// Port x Reset bit y (y= 0 ..
BR11: u1 = 0,
/// BR12 [12:12]
/// Port x Reset bit y (y= 0 ..
BR12: u1 = 0,
/// BR13 [13:13]
/// Port x Reset bit y (y= 0 ..
BR13: u1 = 0,
/// BR14 [14:14]
/// Port x Reset bit y (y= 0 ..
BR14: u1 = 0,
/// BR15 [15:15]
/// Port x Reset bit y (y= 0 ..
BR15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port bit reset register
pub const BRR = Register(BRR_val).init(base_address + 0x28);
};

/// General-purpose I/Os
pub const GPIOD = struct {

const base_address = 0x50000c00;
/// MODER
const MODER_val = packed struct {
/// MODE0 [0:1]
/// Port x configuration bits (y =
MODE0: u2 = 3,
/// MODE1 [2:3]
/// Port x configuration bits (y =
MODE1: u2 = 3,
/// MODE2 [4:5]
/// Port x configuration bits (y =
MODE2: u2 = 3,
/// MODE3 [6:7]
/// Port x configuration bits (y =
MODE3: u2 = 3,
/// MODE4 [8:9]
/// Port x configuration bits (y =
MODE4: u2 = 3,
/// MODE5 [10:11]
/// Port x configuration bits (y =
MODE5: u2 = 3,
/// MODE6 [12:13]
/// Port x configuration bits (y =
MODE6: u2 = 3,
/// MODE7 [14:15]
/// Port x configuration bits (y =
MODE7: u2 = 3,
/// MODE8 [16:17]
/// Port x configuration bits (y =
MODE8: u2 = 3,
/// MODE9 [18:19]
/// Port x configuration bits (y =
MODE9: u2 = 3,
/// MODE10 [20:21]
/// Port x configuration bits (y =
MODE10: u2 = 3,
/// MODE11 [22:23]
/// Port x configuration bits (y =
MODE11: u2 = 3,
/// MODE12 [24:25]
/// Port x configuration bits (y =
MODE12: u2 = 3,
/// MODE13 [26:27]
/// Port x configuration bits (y =
MODE13: u2 = 3,
/// MODE14 [28:29]
/// Port x configuration bits (y =
MODE14: u2 = 3,
/// MODE15 [30:31]
/// Port x configuration bits (y =
MODE15: u2 = 3,
};
/// GPIO port mode register
pub const MODER = Register(MODER_val).init(base_address + 0x0);

/// OTYPER
const OTYPER_val = packed struct {
/// OT0 [0:0]
/// Port x configuration bits (y =
OT0: u1 = 0,
/// OT1 [1:1]
/// Port x configuration bits (y =
OT1: u1 = 0,
/// OT2 [2:2]
/// Port x configuration bits (y =
OT2: u1 = 0,
/// OT3 [3:3]
/// Port x configuration bits (y =
OT3: u1 = 0,
/// OT4 [4:4]
/// Port x configuration bits (y =
OT4: u1 = 0,
/// OT5 [5:5]
/// Port x configuration bits (y =
OT5: u1 = 0,
/// OT6 [6:6]
/// Port x configuration bits (y =
OT6: u1 = 0,
/// OT7 [7:7]
/// Port x configuration bits (y =
OT7: u1 = 0,
/// OT8 [8:8]
/// Port x configuration bits (y =
OT8: u1 = 0,
/// OT9 [9:9]
/// Port x configuration bits (y =
OT9: u1 = 0,
/// OT10 [10:10]
/// Port x configuration bits (y =
OT10: u1 = 0,
/// OT11 [11:11]
/// Port x configuration bits (y =
OT11: u1 = 0,
/// OT12 [12:12]
/// Port x configuration bits (y =
OT12: u1 = 0,
/// OT13 [13:13]
/// Port x configuration bits (y =
OT13: u1 = 0,
/// OT14 [14:14]
/// Port x configuration bits (y =
OT14: u1 = 0,
/// OT15 [15:15]
/// Port x configuration bits (y =
OT15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port output type register
pub const OTYPER = Register(OTYPER_val).init(base_address + 0x4);

/// OSPEEDR
const OSPEEDR_val = packed struct {
/// OSPEED0 [0:1]
/// Port x configuration bits (y =
OSPEED0: u2 = 0,
/// OSPEED1 [2:3]
/// Port x configuration bits (y =
OSPEED1: u2 = 0,
/// OSPEED2 [4:5]
/// Port x configuration bits (y =
OSPEED2: u2 = 0,
/// OSPEED3 [6:7]
/// Port x configuration bits (y =
OSPEED3: u2 = 0,
/// OSPEED4 [8:9]
/// Port x configuration bits (y =
OSPEED4: u2 = 0,
/// OSPEED5 [10:11]
/// Port x configuration bits (y =
OSPEED5: u2 = 0,
/// OSPEED6 [12:13]
/// Port x configuration bits (y =
OSPEED6: u2 = 0,
/// OSPEED7 [14:15]
/// Port x configuration bits (y =
OSPEED7: u2 = 0,
/// OSPEED8 [16:17]
/// Port x configuration bits (y =
OSPEED8: u2 = 0,
/// OSPEED9 [18:19]
/// Port x configuration bits (y =
OSPEED9: u2 = 0,
/// OSPEED10 [20:21]
/// Port x configuration bits (y =
OSPEED10: u2 = 0,
/// OSPEED11 [22:23]
/// Port x configuration bits (y =
OSPEED11: u2 = 0,
/// OSPEED12 [24:25]
/// Port x configuration bits (y =
OSPEED12: u2 = 0,
/// OSPEED13 [26:27]
/// Port x configuration bits (y =
OSPEED13: u2 = 0,
/// OSPEED14 [28:29]
/// Port x configuration bits (y =
OSPEED14: u2 = 0,
/// OSPEED15 [30:31]
/// Port x configuration bits (y =
OSPEED15: u2 = 0,
};
/// GPIO port output speed
pub const OSPEEDR = Register(OSPEEDR_val).init(base_address + 0x8);

/// PUPDR
const PUPDR_val = packed struct {
/// PUPD0 [0:1]
/// Port x configuration bits (y =
PUPD0: u2 = 0,
/// PUPD1 [2:3]
/// Port x configuration bits (y =
PUPD1: u2 = 0,
/// PUPD2 [4:5]
/// Port x configuration bits (y =
PUPD2: u2 = 0,
/// PUPD3 [6:7]
/// Port x configuration bits (y =
PUPD3: u2 = 0,
/// PUPD4 [8:9]
/// Port x configuration bits (y =
PUPD4: u2 = 0,
/// PUPD5 [10:11]
/// Port x configuration bits (y =
PUPD5: u2 = 0,
/// PUPD6 [12:13]
/// Port x configuration bits (y =
PUPD6: u2 = 0,
/// PUPD7 [14:15]
/// Port x configuration bits (y =
PUPD7: u2 = 0,
/// PUPD8 [16:17]
/// Port x configuration bits (y =
PUPD8: u2 = 0,
/// PUPD9 [18:19]
/// Port x configuration bits (y =
PUPD9: u2 = 0,
/// PUPD10 [20:21]
/// Port x configuration bits (y =
PUPD10: u2 = 0,
/// PUPD11 [22:23]
/// Port x configuration bits (y =
PUPD11: u2 = 0,
/// PUPD12 [24:25]
/// Port x configuration bits (y =
PUPD12: u2 = 0,
/// PUPD13 [26:27]
/// Port x configuration bits (y =
PUPD13: u2 = 0,
/// PUPD14 [28:29]
/// Port x configuration bits (y =
PUPD14: u2 = 0,
/// PUPD15 [30:31]
/// Port x configuration bits (y =
PUPD15: u2 = 0,
};
/// GPIO port pull-up/pull-down
pub const PUPDR = Register(PUPDR_val).init(base_address + 0xc);

/// IDR
const IDR_val = packed struct {
/// ID0 [0:0]
/// Port input data bit (y =
ID0: u1 = 0,
/// ID1 [1:1]
/// Port input data bit (y =
ID1: u1 = 0,
/// ID2 [2:2]
/// Port input data bit (y =
ID2: u1 = 0,
/// ID3 [3:3]
/// Port input data bit (y =
ID3: u1 = 0,
/// ID4 [4:4]
/// Port input data bit (y =
ID4: u1 = 0,
/// ID5 [5:5]
/// Port input data bit (y =
ID5: u1 = 0,
/// ID6 [6:6]
/// Port input data bit (y =
ID6: u1 = 0,
/// ID7 [7:7]
/// Port input data bit (y =
ID7: u1 = 0,
/// ID8 [8:8]
/// Port input data bit (y =
ID8: u1 = 0,
/// ID9 [9:9]
/// Port input data bit (y =
ID9: u1 = 0,
/// ID10 [10:10]
/// Port input data bit (y =
ID10: u1 = 0,
/// ID11 [11:11]
/// Port input data bit (y =
ID11: u1 = 0,
/// ID12 [12:12]
/// Port input data bit (y =
ID12: u1 = 0,
/// ID13 [13:13]
/// Port input data bit (y =
ID13: u1 = 0,
/// ID14 [14:14]
/// Port input data bit (y =
ID14: u1 = 0,
/// ID15 [15:15]
/// Port input data bit (y =
ID15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port input data register
pub const IDR = Register(IDR_val).init(base_address + 0x10);

/// ODR
const ODR_val = packed struct {
/// OD0 [0:0]
/// Port output data bit (y =
OD0: u1 = 0,
/// OD1 [1:1]
/// Port output data bit (y =
OD1: u1 = 0,
/// OD2 [2:2]
/// Port output data bit (y =
OD2: u1 = 0,
/// OD3 [3:3]
/// Port output data bit (y =
OD3: u1 = 0,
/// OD4 [4:4]
/// Port output data bit (y =
OD4: u1 = 0,
/// OD5 [5:5]
/// Port output data bit (y =
OD5: u1 = 0,
/// OD6 [6:6]
/// Port output data bit (y =
OD6: u1 = 0,
/// OD7 [7:7]
/// Port output data bit (y =
OD7: u1 = 0,
/// OD8 [8:8]
/// Port output data bit (y =
OD8: u1 = 0,
/// OD9 [9:9]
/// Port output data bit (y =
OD9: u1 = 0,
/// OD10 [10:10]
/// Port output data bit (y =
OD10: u1 = 0,
/// OD11 [11:11]
/// Port output data bit (y =
OD11: u1 = 0,
/// OD12 [12:12]
/// Port output data bit (y =
OD12: u1 = 0,
/// OD13 [13:13]
/// Port output data bit (y =
OD13: u1 = 0,
/// OD14 [14:14]
/// Port output data bit (y =
OD14: u1 = 0,
/// OD15 [15:15]
/// Port output data bit (y =
OD15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port output data register
pub const ODR = Register(ODR_val).init(base_address + 0x14);

/// BSRR
const BSRR_val = packed struct {
/// BS0 [0:0]
/// Port x set bit y (y=
BS0: u1 = 0,
/// BS1 [1:1]
/// Port x set bit y (y=
BS1: u1 = 0,
/// BS2 [2:2]
/// Port x set bit y (y=
BS2: u1 = 0,
/// BS3 [3:3]
/// Port x set bit y (y=
BS3: u1 = 0,
/// BS4 [4:4]
/// Port x set bit y (y=
BS4: u1 = 0,
/// BS5 [5:5]
/// Port x set bit y (y=
BS5: u1 = 0,
/// BS6 [6:6]
/// Port x set bit y (y=
BS6: u1 = 0,
/// BS7 [7:7]
/// Port x set bit y (y=
BS7: u1 = 0,
/// BS8 [8:8]
/// Port x set bit y (y=
BS8: u1 = 0,
/// BS9 [9:9]
/// Port x set bit y (y=
BS9: u1 = 0,
/// BS10 [10:10]
/// Port x set bit y (y=
BS10: u1 = 0,
/// BS11 [11:11]
/// Port x set bit y (y=
BS11: u1 = 0,
/// BS12 [12:12]
/// Port x set bit y (y=
BS12: u1 = 0,
/// BS13 [13:13]
/// Port x set bit y (y=
BS13: u1 = 0,
/// BS14 [14:14]
/// Port x set bit y (y=
BS14: u1 = 0,
/// BS15 [15:15]
/// Port x set bit y (y=
BS15: u1 = 0,
/// BR0 [16:16]
/// Port x reset bit y (y =
BR0: u1 = 0,
/// BR1 [17:17]
/// Port x reset bit y (y =
BR1: u1 = 0,
/// BR2 [18:18]
/// Port x reset bit y (y =
BR2: u1 = 0,
/// BR3 [19:19]
/// Port x reset bit y (y =
BR3: u1 = 0,
/// BR4 [20:20]
/// Port x reset bit y (y =
BR4: u1 = 0,
/// BR5 [21:21]
/// Port x reset bit y (y =
BR5: u1 = 0,
/// BR6 [22:22]
/// Port x reset bit y (y =
BR6: u1 = 0,
/// BR7 [23:23]
/// Port x reset bit y (y =
BR7: u1 = 0,
/// BR8 [24:24]
/// Port x reset bit y (y =
BR8: u1 = 0,
/// BR9 [25:25]
/// Port x reset bit y (y =
BR9: u1 = 0,
/// BR10 [26:26]
/// Port x reset bit y (y =
BR10: u1 = 0,
/// BR11 [27:27]
/// Port x reset bit y (y =
BR11: u1 = 0,
/// BR12 [28:28]
/// Port x reset bit y (y =
BR12: u1 = 0,
/// BR13 [29:29]
/// Port x reset bit y (y =
BR13: u1 = 0,
/// BR14 [30:30]
/// Port x reset bit y (y =
BR14: u1 = 0,
/// BR15 [31:31]
/// Port x reset bit y (y =
BR15: u1 = 0,
};
/// GPIO port bit set/reset
pub const BSRR = Register(BSRR_val).init(base_address + 0x18);

/// LCKR
const LCKR_val = packed struct {
/// LCK0 [0:0]
/// Port x lock bit y (y=
LCK0: u1 = 0,
/// LCK1 [1:1]
/// Port x lock bit y (y=
LCK1: u1 = 0,
/// LCK2 [2:2]
/// Port x lock bit y (y=
LCK2: u1 = 0,
/// LCK3 [3:3]
/// Port x lock bit y (y=
LCK3: u1 = 0,
/// LCK4 [4:4]
/// Port x lock bit y (y=
LCK4: u1 = 0,
/// LCK5 [5:5]
/// Port x lock bit y (y=
LCK5: u1 = 0,
/// LCK6 [6:6]
/// Port x lock bit y (y=
LCK6: u1 = 0,
/// LCK7 [7:7]
/// Port x lock bit y (y=
LCK7: u1 = 0,
/// LCK8 [8:8]
/// Port x lock bit y (y=
LCK8: u1 = 0,
/// LCK9 [9:9]
/// Port x lock bit y (y=
LCK9: u1 = 0,
/// LCK10 [10:10]
/// Port x lock bit y (y=
LCK10: u1 = 0,
/// LCK11 [11:11]
/// Port x lock bit y (y=
LCK11: u1 = 0,
/// LCK12 [12:12]
/// Port x lock bit y (y=
LCK12: u1 = 0,
/// LCK13 [13:13]
/// Port x lock bit y (y=
LCK13: u1 = 0,
/// LCK14 [14:14]
/// Port x lock bit y (y=
LCK14: u1 = 0,
/// LCK15 [15:15]
/// Port x lock bit y (y=
LCK15: u1 = 0,
/// LCKK [16:16]
/// Port x lock bit y (y=
LCKK: u1 = 0,
/// unused [17:31]
_unused17: u7 = 0,
_unused24: u8 = 0,
};
/// GPIO port configuration lock
pub const LCKR = Register(LCKR_val).init(base_address + 0x1c);

/// AFRL
const AFRL_val = packed struct {
/// AFSEL0 [0:3]
/// Alternate function selection for port x
AFSEL0: u4 = 0,
/// AFSEL1 [4:7]
/// Alternate function selection for port x
AFSEL1: u4 = 0,
/// AFSEL2 [8:11]
/// Alternate function selection for port x
AFSEL2: u4 = 0,
/// AFSEL3 [12:15]
/// Alternate function selection for port x
AFSEL3: u4 = 0,
/// AFSEL4 [16:19]
/// Alternate function selection for port x
AFSEL4: u4 = 0,
/// AFSEL5 [20:23]
/// Alternate function selection for port x
AFSEL5: u4 = 0,
/// AFSEL6 [24:27]
/// Alternate function selection for port x
AFSEL6: u4 = 0,
/// AFSEL7 [28:31]
/// Alternate function selection for port x
AFSEL7: u4 = 0,
};
/// GPIO alternate function low
pub const AFRL = Register(AFRL_val).init(base_address + 0x20);

/// AFRH
const AFRH_val = packed struct {
/// AFSEL8 [0:3]
/// Alternate function selection for port x
AFSEL8: u4 = 0,
/// AFSEL9 [4:7]
/// Alternate function selection for port x
AFSEL9: u4 = 0,
/// AFSEL10 [8:11]
/// Alternate function selection for port x
AFSEL10: u4 = 0,
/// AFSEL11 [12:15]
/// Alternate function selection for port x
AFSEL11: u4 = 0,
/// AFSEL12 [16:19]
/// Alternate function selection for port x
AFSEL12: u4 = 0,
/// AFSEL13 [20:23]
/// Alternate function selection for port x
AFSEL13: u4 = 0,
/// AFSEL14 [24:27]
/// Alternate function selection for port x
AFSEL14: u4 = 0,
/// AFSEL15 [28:31]
/// Alternate function selection for port x
AFSEL15: u4 = 0,
};
/// GPIO alternate function high
pub const AFRH = Register(AFRH_val).init(base_address + 0x24);

/// BRR
const BRR_val = packed struct {
/// BR0 [0:0]
/// Port x Reset bit y (y= 0 ..
BR0: u1 = 0,
/// BR1 [1:1]
/// Port x Reset bit y (y= 0 ..
BR1: u1 = 0,
/// BR2 [2:2]
/// Port x Reset bit y (y= 0 ..
BR2: u1 = 0,
/// BR3 [3:3]
/// Port x Reset bit y (y= 0 ..
BR3: u1 = 0,
/// BR4 [4:4]
/// Port x Reset bit y (y= 0 ..
BR4: u1 = 0,
/// BR5 [5:5]
/// Port x Reset bit y (y= 0 ..
BR5: u1 = 0,
/// BR6 [6:6]
/// Port x Reset bit y (y= 0 ..
BR6: u1 = 0,
/// BR7 [7:7]
/// Port x Reset bit y (y= 0 ..
BR7: u1 = 0,
/// BR8 [8:8]
/// Port x Reset bit y (y= 0 ..
BR8: u1 = 0,
/// BR9 [9:9]
/// Port x Reset bit y (y= 0 ..
BR9: u1 = 0,
/// BR10 [10:10]
/// Port x Reset bit y (y= 0 ..
BR10: u1 = 0,
/// BR11 [11:11]
/// Port x Reset bit y (y= 0 ..
BR11: u1 = 0,
/// BR12 [12:12]
/// Port x Reset bit y (y= 0 ..
BR12: u1 = 0,
/// BR13 [13:13]
/// Port x Reset bit y (y= 0 ..
BR13: u1 = 0,
/// BR14 [14:14]
/// Port x Reset bit y (y= 0 ..
BR14: u1 = 0,
/// BR15 [15:15]
/// Port x Reset bit y (y= 0 ..
BR15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port bit reset register
pub const BRR = Register(BRR_val).init(base_address + 0x28);
};

/// General-purpose I/Os
pub const GPIOH = struct {

const base_address = 0x50001c00;
/// MODER
const MODER_val = packed struct {
/// MODE0 [0:1]
/// Port x configuration bits (y =
MODE0: u2 = 3,
/// MODE1 [2:3]
/// Port x configuration bits (y =
MODE1: u2 = 3,
/// MODE2 [4:5]
/// Port x configuration bits (y =
MODE2: u2 = 3,
/// MODE3 [6:7]
/// Port x configuration bits (y =
MODE3: u2 = 3,
/// MODE4 [8:9]
/// Port x configuration bits (y =
MODE4: u2 = 3,
/// MODE5 [10:11]
/// Port x configuration bits (y =
MODE5: u2 = 3,
/// MODE6 [12:13]
/// Port x configuration bits (y =
MODE6: u2 = 3,
/// MODE7 [14:15]
/// Port x configuration bits (y =
MODE7: u2 = 3,
/// MODE8 [16:17]
/// Port x configuration bits (y =
MODE8: u2 = 3,
/// MODE9 [18:19]
/// Port x configuration bits (y =
MODE9: u2 = 3,
/// MODE10 [20:21]
/// Port x configuration bits (y =
MODE10: u2 = 3,
/// MODE11 [22:23]
/// Port x configuration bits (y =
MODE11: u2 = 3,
/// MODE12 [24:25]
/// Port x configuration bits (y =
MODE12: u2 = 3,
/// MODE13 [26:27]
/// Port x configuration bits (y =
MODE13: u2 = 3,
/// MODE14 [28:29]
/// Port x configuration bits (y =
MODE14: u2 = 3,
/// MODE15 [30:31]
/// Port x configuration bits (y =
MODE15: u2 = 3,
};
/// GPIO port mode register
pub const MODER = Register(MODER_val).init(base_address + 0x0);

/// OTYPER
const OTYPER_val = packed struct {
/// OT0 [0:0]
/// Port x configuration bits (y =
OT0: u1 = 0,
/// OT1 [1:1]
/// Port x configuration bits (y =
OT1: u1 = 0,
/// OT2 [2:2]
/// Port x configuration bits (y =
OT2: u1 = 0,
/// OT3 [3:3]
/// Port x configuration bits (y =
OT3: u1 = 0,
/// OT4 [4:4]
/// Port x configuration bits (y =
OT4: u1 = 0,
/// OT5 [5:5]
/// Port x configuration bits (y =
OT5: u1 = 0,
/// OT6 [6:6]
/// Port x configuration bits (y =
OT6: u1 = 0,
/// OT7 [7:7]
/// Port x configuration bits (y =
OT7: u1 = 0,
/// OT8 [8:8]
/// Port x configuration bits (y =
OT8: u1 = 0,
/// OT9 [9:9]
/// Port x configuration bits (y =
OT9: u1 = 0,
/// OT10 [10:10]
/// Port x configuration bits (y =
OT10: u1 = 0,
/// OT11 [11:11]
/// Port x configuration bits (y =
OT11: u1 = 0,
/// OT12 [12:12]
/// Port x configuration bits (y =
OT12: u1 = 0,
/// OT13 [13:13]
/// Port x configuration bits (y =
OT13: u1 = 0,
/// OT14 [14:14]
/// Port x configuration bits (y =
OT14: u1 = 0,
/// OT15 [15:15]
/// Port x configuration bits (y =
OT15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port output type register
pub const OTYPER = Register(OTYPER_val).init(base_address + 0x4);

/// OSPEEDR
const OSPEEDR_val = packed struct {
/// OSPEED0 [0:1]
/// Port x configuration bits (y =
OSPEED0: u2 = 0,
/// OSPEED1 [2:3]
/// Port x configuration bits (y =
OSPEED1: u2 = 0,
/// OSPEED2 [4:5]
/// Port x configuration bits (y =
OSPEED2: u2 = 0,
/// OSPEED3 [6:7]
/// Port x configuration bits (y =
OSPEED3: u2 = 0,
/// OSPEED4 [8:9]
/// Port x configuration bits (y =
OSPEED4: u2 = 0,
/// OSPEED5 [10:11]
/// Port x configuration bits (y =
OSPEED5: u2 = 0,
/// OSPEED6 [12:13]
/// Port x configuration bits (y =
OSPEED6: u2 = 0,
/// OSPEED7 [14:15]
/// Port x configuration bits (y =
OSPEED7: u2 = 0,
/// OSPEED8 [16:17]
/// Port x configuration bits (y =
OSPEED8: u2 = 0,
/// OSPEED9 [18:19]
/// Port x configuration bits (y =
OSPEED9: u2 = 0,
/// OSPEED10 [20:21]
/// Port x configuration bits (y =
OSPEED10: u2 = 0,
/// OSPEED11 [22:23]
/// Port x configuration bits (y =
OSPEED11: u2 = 0,
/// OSPEED12 [24:25]
/// Port x configuration bits (y =
OSPEED12: u2 = 0,
/// OSPEED13 [26:27]
/// Port x configuration bits (y =
OSPEED13: u2 = 0,
/// OSPEED14 [28:29]
/// Port x configuration bits (y =
OSPEED14: u2 = 0,
/// OSPEED15 [30:31]
/// Port x configuration bits (y =
OSPEED15: u2 = 0,
};
/// GPIO port output speed
pub const OSPEEDR = Register(OSPEEDR_val).init(base_address + 0x8);

/// PUPDR
const PUPDR_val = packed struct {
/// PUPD0 [0:1]
/// Port x configuration bits (y =
PUPD0: u2 = 0,
/// PUPD1 [2:3]
/// Port x configuration bits (y =
PUPD1: u2 = 0,
/// PUPD2 [4:5]
/// Port x configuration bits (y =
PUPD2: u2 = 0,
/// PUPD3 [6:7]
/// Port x configuration bits (y =
PUPD3: u2 = 0,
/// PUPD4 [8:9]
/// Port x configuration bits (y =
PUPD4: u2 = 0,
/// PUPD5 [10:11]
/// Port x configuration bits (y =
PUPD5: u2 = 0,
/// PUPD6 [12:13]
/// Port x configuration bits (y =
PUPD6: u2 = 0,
/// PUPD7 [14:15]
/// Port x configuration bits (y =
PUPD7: u2 = 0,
/// PUPD8 [16:17]
/// Port x configuration bits (y =
PUPD8: u2 = 0,
/// PUPD9 [18:19]
/// Port x configuration bits (y =
PUPD9: u2 = 0,
/// PUPD10 [20:21]
/// Port x configuration bits (y =
PUPD10: u2 = 0,
/// PUPD11 [22:23]
/// Port x configuration bits (y =
PUPD11: u2 = 0,
/// PUPD12 [24:25]
/// Port x configuration bits (y =
PUPD12: u2 = 0,
/// PUPD13 [26:27]
/// Port x configuration bits (y =
PUPD13: u2 = 0,
/// PUPD14 [28:29]
/// Port x configuration bits (y =
PUPD14: u2 = 0,
/// PUPD15 [30:31]
/// Port x configuration bits (y =
PUPD15: u2 = 0,
};
/// GPIO port pull-up/pull-down
pub const PUPDR = Register(PUPDR_val).init(base_address + 0xc);

/// IDR
const IDR_val = packed struct {
/// ID0 [0:0]
/// Port input data bit (y =
ID0: u1 = 0,
/// ID1 [1:1]
/// Port input data bit (y =
ID1: u1 = 0,
/// ID2 [2:2]
/// Port input data bit (y =
ID2: u1 = 0,
/// ID3 [3:3]
/// Port input data bit (y =
ID3: u1 = 0,
/// ID4 [4:4]
/// Port input data bit (y =
ID4: u1 = 0,
/// ID5 [5:5]
/// Port input data bit (y =
ID5: u1 = 0,
/// ID6 [6:6]
/// Port input data bit (y =
ID6: u1 = 0,
/// ID7 [7:7]
/// Port input data bit (y =
ID7: u1 = 0,
/// ID8 [8:8]
/// Port input data bit (y =
ID8: u1 = 0,
/// ID9 [9:9]
/// Port input data bit (y =
ID9: u1 = 0,
/// ID10 [10:10]
/// Port input data bit (y =
ID10: u1 = 0,
/// ID11 [11:11]
/// Port input data bit (y =
ID11: u1 = 0,
/// ID12 [12:12]
/// Port input data bit (y =
ID12: u1 = 0,
/// ID13 [13:13]
/// Port input data bit (y =
ID13: u1 = 0,
/// ID14 [14:14]
/// Port input data bit (y =
ID14: u1 = 0,
/// ID15 [15:15]
/// Port input data bit (y =
ID15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port input data register
pub const IDR = Register(IDR_val).init(base_address + 0x10);

/// ODR
const ODR_val = packed struct {
/// OD0 [0:0]
/// Port output data bit (y =
OD0: u1 = 0,
/// OD1 [1:1]
/// Port output data bit (y =
OD1: u1 = 0,
/// OD2 [2:2]
/// Port output data bit (y =
OD2: u1 = 0,
/// OD3 [3:3]
/// Port output data bit (y =
OD3: u1 = 0,
/// OD4 [4:4]
/// Port output data bit (y =
OD4: u1 = 0,
/// OD5 [5:5]
/// Port output data bit (y =
OD5: u1 = 0,
/// OD6 [6:6]
/// Port output data bit (y =
OD6: u1 = 0,
/// OD7 [7:7]
/// Port output data bit (y =
OD7: u1 = 0,
/// OD8 [8:8]
/// Port output data bit (y =
OD8: u1 = 0,
/// OD9 [9:9]
/// Port output data bit (y =
OD9: u1 = 0,
/// OD10 [10:10]
/// Port output data bit (y =
OD10: u1 = 0,
/// OD11 [11:11]
/// Port output data bit (y =
OD11: u1 = 0,
/// OD12 [12:12]
/// Port output data bit (y =
OD12: u1 = 0,
/// OD13 [13:13]
/// Port output data bit (y =
OD13: u1 = 0,
/// OD14 [14:14]
/// Port output data bit (y =
OD14: u1 = 0,
/// OD15 [15:15]
/// Port output data bit (y =
OD15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port output data register
pub const ODR = Register(ODR_val).init(base_address + 0x14);

/// BSRR
const BSRR_val = packed struct {
/// BS0 [0:0]
/// Port x set bit y (y=
BS0: u1 = 0,
/// BS1 [1:1]
/// Port x set bit y (y=
BS1: u1 = 0,
/// BS2 [2:2]
/// Port x set bit y (y=
BS2: u1 = 0,
/// BS3 [3:3]
/// Port x set bit y (y=
BS3: u1 = 0,
/// BS4 [4:4]
/// Port x set bit y (y=
BS4: u1 = 0,
/// BS5 [5:5]
/// Port x set bit y (y=
BS5: u1 = 0,
/// BS6 [6:6]
/// Port x set bit y (y=
BS6: u1 = 0,
/// BS7 [7:7]
/// Port x set bit y (y=
BS7: u1 = 0,
/// BS8 [8:8]
/// Port x set bit y (y=
BS8: u1 = 0,
/// BS9 [9:9]
/// Port x set bit y (y=
BS9: u1 = 0,
/// BS10 [10:10]
/// Port x set bit y (y=
BS10: u1 = 0,
/// BS11 [11:11]
/// Port x set bit y (y=
BS11: u1 = 0,
/// BS12 [12:12]
/// Port x set bit y (y=
BS12: u1 = 0,
/// BS13 [13:13]
/// Port x set bit y (y=
BS13: u1 = 0,
/// BS14 [14:14]
/// Port x set bit y (y=
BS14: u1 = 0,
/// BS15 [15:15]
/// Port x set bit y (y=
BS15: u1 = 0,
/// BR0 [16:16]
/// Port x reset bit y (y =
BR0: u1 = 0,
/// BR1 [17:17]
/// Port x reset bit y (y =
BR1: u1 = 0,
/// BR2 [18:18]
/// Port x reset bit y (y =
BR2: u1 = 0,
/// BR3 [19:19]
/// Port x reset bit y (y =
BR3: u1 = 0,
/// BR4 [20:20]
/// Port x reset bit y (y =
BR4: u1 = 0,
/// BR5 [21:21]
/// Port x reset bit y (y =
BR5: u1 = 0,
/// BR6 [22:22]
/// Port x reset bit y (y =
BR6: u1 = 0,
/// BR7 [23:23]
/// Port x reset bit y (y =
BR7: u1 = 0,
/// BR8 [24:24]
/// Port x reset bit y (y =
BR8: u1 = 0,
/// BR9 [25:25]
/// Port x reset bit y (y =
BR9: u1 = 0,
/// BR10 [26:26]
/// Port x reset bit y (y =
BR10: u1 = 0,
/// BR11 [27:27]
/// Port x reset bit y (y =
BR11: u1 = 0,
/// BR12 [28:28]
/// Port x reset bit y (y =
BR12: u1 = 0,
/// BR13 [29:29]
/// Port x reset bit y (y =
BR13: u1 = 0,
/// BR14 [30:30]
/// Port x reset bit y (y =
BR14: u1 = 0,
/// BR15 [31:31]
/// Port x reset bit y (y =
BR15: u1 = 0,
};
/// GPIO port bit set/reset
pub const BSRR = Register(BSRR_val).init(base_address + 0x18);

/// LCKR
const LCKR_val = packed struct {
/// LCK0 [0:0]
/// Port x lock bit y (y=
LCK0: u1 = 0,
/// LCK1 [1:1]
/// Port x lock bit y (y=
LCK1: u1 = 0,
/// LCK2 [2:2]
/// Port x lock bit y (y=
LCK2: u1 = 0,
/// LCK3 [3:3]
/// Port x lock bit y (y=
LCK3: u1 = 0,
/// LCK4 [4:4]
/// Port x lock bit y (y=
LCK4: u1 = 0,
/// LCK5 [5:5]
/// Port x lock bit y (y=
LCK5: u1 = 0,
/// LCK6 [6:6]
/// Port x lock bit y (y=
LCK6: u1 = 0,
/// LCK7 [7:7]
/// Port x lock bit y (y=
LCK7: u1 = 0,
/// LCK8 [8:8]
/// Port x lock bit y (y=
LCK8: u1 = 0,
/// LCK9 [9:9]
/// Port x lock bit y (y=
LCK9: u1 = 0,
/// LCK10 [10:10]
/// Port x lock bit y (y=
LCK10: u1 = 0,
/// LCK11 [11:11]
/// Port x lock bit y (y=
LCK11: u1 = 0,
/// LCK12 [12:12]
/// Port x lock bit y (y=
LCK12: u1 = 0,
/// LCK13 [13:13]
/// Port x lock bit y (y=
LCK13: u1 = 0,
/// LCK14 [14:14]
/// Port x lock bit y (y=
LCK14: u1 = 0,
/// LCK15 [15:15]
/// Port x lock bit y (y=
LCK15: u1 = 0,
/// LCKK [16:16]
/// Port x lock bit y (y=
LCKK: u1 = 0,
/// unused [17:31]
_unused17: u7 = 0,
_unused24: u8 = 0,
};
/// GPIO port configuration lock
pub const LCKR = Register(LCKR_val).init(base_address + 0x1c);

/// AFRL
const AFRL_val = packed struct {
/// AFSEL0 [0:3]
/// Alternate function selection for port x
AFSEL0: u4 = 0,
/// AFSEL1 [4:7]
/// Alternate function selection for port x
AFSEL1: u4 = 0,
/// AFSEL2 [8:11]
/// Alternate function selection for port x
AFSEL2: u4 = 0,
/// AFSEL3 [12:15]
/// Alternate function selection for port x
AFSEL3: u4 = 0,
/// AFSEL4 [16:19]
/// Alternate function selection for port x
AFSEL4: u4 = 0,
/// AFSEL5 [20:23]
/// Alternate function selection for port x
AFSEL5: u4 = 0,
/// AFSEL6 [24:27]
/// Alternate function selection for port x
AFSEL6: u4 = 0,
/// AFSEL7 [28:31]
/// Alternate function selection for port x
AFSEL7: u4 = 0,
};
/// GPIO alternate function low
pub const AFRL = Register(AFRL_val).init(base_address + 0x20);

/// AFRH
const AFRH_val = packed struct {
/// AFSEL8 [0:3]
/// Alternate function selection for port x
AFSEL8: u4 = 0,
/// AFSEL9 [4:7]
/// Alternate function selection for port x
AFSEL9: u4 = 0,
/// AFSEL10 [8:11]
/// Alternate function selection for port x
AFSEL10: u4 = 0,
/// AFSEL11 [12:15]
/// Alternate function selection for port x
AFSEL11: u4 = 0,
/// AFSEL12 [16:19]
/// Alternate function selection for port x
AFSEL12: u4 = 0,
/// AFSEL13 [20:23]
/// Alternate function selection for port x
AFSEL13: u4 = 0,
/// AFSEL14 [24:27]
/// Alternate function selection for port x
AFSEL14: u4 = 0,
/// AFSEL15 [28:31]
/// Alternate function selection for port x
AFSEL15: u4 = 0,
};
/// GPIO alternate function high
pub const AFRH = Register(AFRH_val).init(base_address + 0x24);

/// BRR
const BRR_val = packed struct {
/// BR0 [0:0]
/// Port x Reset bit y (y= 0 ..
BR0: u1 = 0,
/// BR1 [1:1]
/// Port x Reset bit y (y= 0 ..
BR1: u1 = 0,
/// BR2 [2:2]
/// Port x Reset bit y (y= 0 ..
BR2: u1 = 0,
/// BR3 [3:3]
/// Port x Reset bit y (y= 0 ..
BR3: u1 = 0,
/// BR4 [4:4]
/// Port x Reset bit y (y= 0 ..
BR4: u1 = 0,
/// BR5 [5:5]
/// Port x Reset bit y (y= 0 ..
BR5: u1 = 0,
/// BR6 [6:6]
/// Port x Reset bit y (y= 0 ..
BR6: u1 = 0,
/// BR7 [7:7]
/// Port x Reset bit y (y= 0 ..
BR7: u1 = 0,
/// BR8 [8:8]
/// Port x Reset bit y (y= 0 ..
BR8: u1 = 0,
/// BR9 [9:9]
/// Port x Reset bit y (y= 0 ..
BR9: u1 = 0,
/// BR10 [10:10]
/// Port x Reset bit y (y= 0 ..
BR10: u1 = 0,
/// BR11 [11:11]
/// Port x Reset bit y (y= 0 ..
BR11: u1 = 0,
/// BR12 [12:12]
/// Port x Reset bit y (y= 0 ..
BR12: u1 = 0,
/// BR13 [13:13]
/// Port x Reset bit y (y= 0 ..
BR13: u1 = 0,
/// BR14 [14:14]
/// Port x Reset bit y (y= 0 ..
BR14: u1 = 0,
/// BR15 [15:15]
/// Port x Reset bit y (y= 0 ..
BR15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port bit reset register
pub const BRR = Register(BRR_val).init(base_address + 0x28);
};

/// General-purpose I/Os
pub const GPIOE = struct {

const base_address = 0x50001000;
/// MODER
const MODER_val = packed struct {
/// MODE0 [0:1]
/// Port x configuration bits (y =
MODE0: u2 = 3,
/// MODE1 [2:3]
/// Port x configuration bits (y =
MODE1: u2 = 3,
/// MODE2 [4:5]
/// Port x configuration bits (y =
MODE2: u2 = 3,
/// MODE3 [6:7]
/// Port x configuration bits (y =
MODE3: u2 = 3,
/// MODE4 [8:9]
/// Port x configuration bits (y =
MODE4: u2 = 3,
/// MODE5 [10:11]
/// Port x configuration bits (y =
MODE5: u2 = 3,
/// MODE6 [12:13]
/// Port x configuration bits (y =
MODE6: u2 = 3,
/// MODE7 [14:15]
/// Port x configuration bits (y =
MODE7: u2 = 3,
/// MODE8 [16:17]
/// Port x configuration bits (y =
MODE8: u2 = 3,
/// MODE9 [18:19]
/// Port x configuration bits (y =
MODE9: u2 = 3,
/// MODE10 [20:21]
/// Port x configuration bits (y =
MODE10: u2 = 3,
/// MODE11 [22:23]
/// Port x configuration bits (y =
MODE11: u2 = 3,
/// MODE12 [24:25]
/// Port x configuration bits (y =
MODE12: u2 = 3,
/// MODE13 [26:27]
/// Port x configuration bits (y =
MODE13: u2 = 3,
/// MODE14 [28:29]
/// Port x configuration bits (y =
MODE14: u2 = 3,
/// MODE15 [30:31]
/// Port x configuration bits (y =
MODE15: u2 = 3,
};
/// GPIO port mode register
pub const MODER = Register(MODER_val).init(base_address + 0x0);

/// OTYPER
const OTYPER_val = packed struct {
/// OT0 [0:0]
/// Port x configuration bits (y =
OT0: u1 = 0,
/// OT1 [1:1]
/// Port x configuration bits (y =
OT1: u1 = 0,
/// OT2 [2:2]
/// Port x configuration bits (y =
OT2: u1 = 0,
/// OT3 [3:3]
/// Port x configuration bits (y =
OT3: u1 = 0,
/// OT4 [4:4]
/// Port x configuration bits (y =
OT4: u1 = 0,
/// OT5 [5:5]
/// Port x configuration bits (y =
OT5: u1 = 0,
/// OT6 [6:6]
/// Port x configuration bits (y =
OT6: u1 = 0,
/// OT7 [7:7]
/// Port x configuration bits (y =
OT7: u1 = 0,
/// OT8 [8:8]
/// Port x configuration bits (y =
OT8: u1 = 0,
/// OT9 [9:9]
/// Port x configuration bits (y =
OT9: u1 = 0,
/// OT10 [10:10]
/// Port x configuration bits (y =
OT10: u1 = 0,
/// OT11 [11:11]
/// Port x configuration bits (y =
OT11: u1 = 0,
/// OT12 [12:12]
/// Port x configuration bits (y =
OT12: u1 = 0,
/// OT13 [13:13]
/// Port x configuration bits (y =
OT13: u1 = 0,
/// OT14 [14:14]
/// Port x configuration bits (y =
OT14: u1 = 0,
/// OT15 [15:15]
/// Port x configuration bits (y =
OT15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port output type register
pub const OTYPER = Register(OTYPER_val).init(base_address + 0x4);

/// OSPEEDR
const OSPEEDR_val = packed struct {
/// OSPEED0 [0:1]
/// Port x configuration bits (y =
OSPEED0: u2 = 0,
/// OSPEED1 [2:3]
/// Port x configuration bits (y =
OSPEED1: u2 = 0,
/// OSPEED2 [4:5]
/// Port x configuration bits (y =
OSPEED2: u2 = 0,
/// OSPEED3 [6:7]
/// Port x configuration bits (y =
OSPEED3: u2 = 0,
/// OSPEED4 [8:9]
/// Port x configuration bits (y =
OSPEED4: u2 = 0,
/// OSPEED5 [10:11]
/// Port x configuration bits (y =
OSPEED5: u2 = 0,
/// OSPEED6 [12:13]
/// Port x configuration bits (y =
OSPEED6: u2 = 0,
/// OSPEED7 [14:15]
/// Port x configuration bits (y =
OSPEED7: u2 = 0,
/// OSPEED8 [16:17]
/// Port x configuration bits (y =
OSPEED8: u2 = 0,
/// OSPEED9 [18:19]
/// Port x configuration bits (y =
OSPEED9: u2 = 0,
/// OSPEED10 [20:21]
/// Port x configuration bits (y =
OSPEED10: u2 = 0,
/// OSPEED11 [22:23]
/// Port x configuration bits (y =
OSPEED11: u2 = 0,
/// OSPEED12 [24:25]
/// Port x configuration bits (y =
OSPEED12: u2 = 0,
/// OSPEED13 [26:27]
/// Port x configuration bits (y =
OSPEED13: u2 = 0,
/// OSPEED14 [28:29]
/// Port x configuration bits (y =
OSPEED14: u2 = 0,
/// OSPEED15 [30:31]
/// Port x configuration bits (y =
OSPEED15: u2 = 0,
};
/// GPIO port output speed
pub const OSPEEDR = Register(OSPEEDR_val).init(base_address + 0x8);

/// PUPDR
const PUPDR_val = packed struct {
/// PUPD0 [0:1]
/// Port x configuration bits (y =
PUPD0: u2 = 0,
/// PUPD1 [2:3]
/// Port x configuration bits (y =
PUPD1: u2 = 0,
/// PUPD2 [4:5]
/// Port x configuration bits (y =
PUPD2: u2 = 0,
/// PUPD3 [6:7]
/// Port x configuration bits (y =
PUPD3: u2 = 0,
/// PUPD4 [8:9]
/// Port x configuration bits (y =
PUPD4: u2 = 0,
/// PUPD5 [10:11]
/// Port x configuration bits (y =
PUPD5: u2 = 0,
/// PUPD6 [12:13]
/// Port x configuration bits (y =
PUPD6: u2 = 0,
/// PUPD7 [14:15]
/// Port x configuration bits (y =
PUPD7: u2 = 0,
/// PUPD8 [16:17]
/// Port x configuration bits (y =
PUPD8: u2 = 0,
/// PUPD9 [18:19]
/// Port x configuration bits (y =
PUPD9: u2 = 0,
/// PUPD10 [20:21]
/// Port x configuration bits (y =
PUPD10: u2 = 0,
/// PUPD11 [22:23]
/// Port x configuration bits (y =
PUPD11: u2 = 0,
/// PUPD12 [24:25]
/// Port x configuration bits (y =
PUPD12: u2 = 0,
/// PUPD13 [26:27]
/// Port x configuration bits (y =
PUPD13: u2 = 0,
/// PUPD14 [28:29]
/// Port x configuration bits (y =
PUPD14: u2 = 0,
/// PUPD15 [30:31]
/// Port x configuration bits (y =
PUPD15: u2 = 0,
};
/// GPIO port pull-up/pull-down
pub const PUPDR = Register(PUPDR_val).init(base_address + 0xc);

/// IDR
const IDR_val = packed struct {
/// ID0 [0:0]
/// Port input data bit (y =
ID0: u1 = 0,
/// ID1 [1:1]
/// Port input data bit (y =
ID1: u1 = 0,
/// ID2 [2:2]
/// Port input data bit (y =
ID2: u1 = 0,
/// ID3 [3:3]
/// Port input data bit (y =
ID3: u1 = 0,
/// ID4 [4:4]
/// Port input data bit (y =
ID4: u1 = 0,
/// ID5 [5:5]
/// Port input data bit (y =
ID5: u1 = 0,
/// ID6 [6:6]
/// Port input data bit (y =
ID6: u1 = 0,
/// ID7 [7:7]
/// Port input data bit (y =
ID7: u1 = 0,
/// ID8 [8:8]
/// Port input data bit (y =
ID8: u1 = 0,
/// ID9 [9:9]
/// Port input data bit (y =
ID9: u1 = 0,
/// ID10 [10:10]
/// Port input data bit (y =
ID10: u1 = 0,
/// ID11 [11:11]
/// Port input data bit (y =
ID11: u1 = 0,
/// ID12 [12:12]
/// Port input data bit (y =
ID12: u1 = 0,
/// ID13 [13:13]
/// Port input data bit (y =
ID13: u1 = 0,
/// ID14 [14:14]
/// Port input data bit (y =
ID14: u1 = 0,
/// ID15 [15:15]
/// Port input data bit (y =
ID15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port input data register
pub const IDR = Register(IDR_val).init(base_address + 0x10);

/// ODR
const ODR_val = packed struct {
/// OD0 [0:0]
/// Port output data bit (y =
OD0: u1 = 0,
/// OD1 [1:1]
/// Port output data bit (y =
OD1: u1 = 0,
/// OD2 [2:2]
/// Port output data bit (y =
OD2: u1 = 0,
/// OD3 [3:3]
/// Port output data bit (y =
OD3: u1 = 0,
/// OD4 [4:4]
/// Port output data bit (y =
OD4: u1 = 0,
/// OD5 [5:5]
/// Port output data bit (y =
OD5: u1 = 0,
/// OD6 [6:6]
/// Port output data bit (y =
OD6: u1 = 0,
/// OD7 [7:7]
/// Port output data bit (y =
OD7: u1 = 0,
/// OD8 [8:8]
/// Port output data bit (y =
OD8: u1 = 0,
/// OD9 [9:9]
/// Port output data bit (y =
OD9: u1 = 0,
/// OD10 [10:10]
/// Port output data bit (y =
OD10: u1 = 0,
/// OD11 [11:11]
/// Port output data bit (y =
OD11: u1 = 0,
/// OD12 [12:12]
/// Port output data bit (y =
OD12: u1 = 0,
/// OD13 [13:13]
/// Port output data bit (y =
OD13: u1 = 0,
/// OD14 [14:14]
/// Port output data bit (y =
OD14: u1 = 0,
/// OD15 [15:15]
/// Port output data bit (y =
OD15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port output data register
pub const ODR = Register(ODR_val).init(base_address + 0x14);

/// BSRR
const BSRR_val = packed struct {
/// BS0 [0:0]
/// Port x set bit y (y=
BS0: u1 = 0,
/// BS1 [1:1]
/// Port x set bit y (y=
BS1: u1 = 0,
/// BS2 [2:2]
/// Port x set bit y (y=
BS2: u1 = 0,
/// BS3 [3:3]
/// Port x set bit y (y=
BS3: u1 = 0,
/// BS4 [4:4]
/// Port x set bit y (y=
BS4: u1 = 0,
/// BS5 [5:5]
/// Port x set bit y (y=
BS5: u1 = 0,
/// BS6 [6:6]
/// Port x set bit y (y=
BS6: u1 = 0,
/// BS7 [7:7]
/// Port x set bit y (y=
BS7: u1 = 0,
/// BS8 [8:8]
/// Port x set bit y (y=
BS8: u1 = 0,
/// BS9 [9:9]
/// Port x set bit y (y=
BS9: u1 = 0,
/// BS10 [10:10]
/// Port x set bit y (y=
BS10: u1 = 0,
/// BS11 [11:11]
/// Port x set bit y (y=
BS11: u1 = 0,
/// BS12 [12:12]
/// Port x set bit y (y=
BS12: u1 = 0,
/// BS13 [13:13]
/// Port x set bit y (y=
BS13: u1 = 0,
/// BS14 [14:14]
/// Port x set bit y (y=
BS14: u1 = 0,
/// BS15 [15:15]
/// Port x set bit y (y=
BS15: u1 = 0,
/// BR0 [16:16]
/// Port x reset bit y (y =
BR0: u1 = 0,
/// BR1 [17:17]
/// Port x reset bit y (y =
BR1: u1 = 0,
/// BR2 [18:18]
/// Port x reset bit y (y =
BR2: u1 = 0,
/// BR3 [19:19]
/// Port x reset bit y (y =
BR3: u1 = 0,
/// BR4 [20:20]
/// Port x reset bit y (y =
BR4: u1 = 0,
/// BR5 [21:21]
/// Port x reset bit y (y =
BR5: u1 = 0,
/// BR6 [22:22]
/// Port x reset bit y (y =
BR6: u1 = 0,
/// BR7 [23:23]
/// Port x reset bit y (y =
BR7: u1 = 0,
/// BR8 [24:24]
/// Port x reset bit y (y =
BR8: u1 = 0,
/// BR9 [25:25]
/// Port x reset bit y (y =
BR9: u1 = 0,
/// BR10 [26:26]
/// Port x reset bit y (y =
BR10: u1 = 0,
/// BR11 [27:27]
/// Port x reset bit y (y =
BR11: u1 = 0,
/// BR12 [28:28]
/// Port x reset bit y (y =
BR12: u1 = 0,
/// BR13 [29:29]
/// Port x reset bit y (y =
BR13: u1 = 0,
/// BR14 [30:30]
/// Port x reset bit y (y =
BR14: u1 = 0,
/// BR15 [31:31]
/// Port x reset bit y (y =
BR15: u1 = 0,
};
/// GPIO port bit set/reset
pub const BSRR = Register(BSRR_val).init(base_address + 0x18);

/// LCKR
const LCKR_val = packed struct {
/// LCK0 [0:0]
/// Port x lock bit y (y=
LCK0: u1 = 0,
/// LCK1 [1:1]
/// Port x lock bit y (y=
LCK1: u1 = 0,
/// LCK2 [2:2]
/// Port x lock bit y (y=
LCK2: u1 = 0,
/// LCK3 [3:3]
/// Port x lock bit y (y=
LCK3: u1 = 0,
/// LCK4 [4:4]
/// Port x lock bit y (y=
LCK4: u1 = 0,
/// LCK5 [5:5]
/// Port x lock bit y (y=
LCK5: u1 = 0,
/// LCK6 [6:6]
/// Port x lock bit y (y=
LCK6: u1 = 0,
/// LCK7 [7:7]
/// Port x lock bit y (y=
LCK7: u1 = 0,
/// LCK8 [8:8]
/// Port x lock bit y (y=
LCK8: u1 = 0,
/// LCK9 [9:9]
/// Port x lock bit y (y=
LCK9: u1 = 0,
/// LCK10 [10:10]
/// Port x lock bit y (y=
LCK10: u1 = 0,
/// LCK11 [11:11]
/// Port x lock bit y (y=
LCK11: u1 = 0,
/// LCK12 [12:12]
/// Port x lock bit y (y=
LCK12: u1 = 0,
/// LCK13 [13:13]
/// Port x lock bit y (y=
LCK13: u1 = 0,
/// LCK14 [14:14]
/// Port x lock bit y (y=
LCK14: u1 = 0,
/// LCK15 [15:15]
/// Port x lock bit y (y=
LCK15: u1 = 0,
/// LCKK [16:16]
/// Port x lock bit y (y=
LCKK: u1 = 0,
/// unused [17:31]
_unused17: u7 = 0,
_unused24: u8 = 0,
};
/// GPIO port configuration lock
pub const LCKR = Register(LCKR_val).init(base_address + 0x1c);

/// AFRL
const AFRL_val = packed struct {
/// AFSEL0 [0:3]
/// Alternate function selection for port x
AFSEL0: u4 = 0,
/// AFSEL1 [4:7]
/// Alternate function selection for port x
AFSEL1: u4 = 0,
/// AFSEL2 [8:11]
/// Alternate function selection for port x
AFSEL2: u4 = 0,
/// AFSEL3 [12:15]
/// Alternate function selection for port x
AFSEL3: u4 = 0,
/// AFSEL4 [16:19]
/// Alternate function selection for port x
AFSEL4: u4 = 0,
/// AFSEL5 [20:23]
/// Alternate function selection for port x
AFSEL5: u4 = 0,
/// AFSEL6 [24:27]
/// Alternate function selection for port x
AFSEL6: u4 = 0,
/// AFSEL7 [28:31]
/// Alternate function selection for port x
AFSEL7: u4 = 0,
};
/// GPIO alternate function low
pub const AFRL = Register(AFRL_val).init(base_address + 0x20);

/// AFRH
const AFRH_val = packed struct {
/// AFSEL8 [0:3]
/// Alternate function selection for port x
AFSEL8: u4 = 0,
/// AFSEL9 [4:7]
/// Alternate function selection for port x
AFSEL9: u4 = 0,
/// AFSEL10 [8:11]
/// Alternate function selection for port x
AFSEL10: u4 = 0,
/// AFSEL11 [12:15]
/// Alternate function selection for port x
AFSEL11: u4 = 0,
/// AFSEL12 [16:19]
/// Alternate function selection for port x
AFSEL12: u4 = 0,
/// AFSEL13 [20:23]
/// Alternate function selection for port x
AFSEL13: u4 = 0,
/// AFSEL14 [24:27]
/// Alternate function selection for port x
AFSEL14: u4 = 0,
/// AFSEL15 [28:31]
/// Alternate function selection for port x
AFSEL15: u4 = 0,
};
/// GPIO alternate function high
pub const AFRH = Register(AFRH_val).init(base_address + 0x24);

/// BRR
const BRR_val = packed struct {
/// BR0 [0:0]
/// Port x Reset bit y (y= 0 ..
BR0: u1 = 0,
/// BR1 [1:1]
/// Port x Reset bit y (y= 0 ..
BR1: u1 = 0,
/// BR2 [2:2]
/// Port x Reset bit y (y= 0 ..
BR2: u1 = 0,
/// BR3 [3:3]
/// Port x Reset bit y (y= 0 ..
BR3: u1 = 0,
/// BR4 [4:4]
/// Port x Reset bit y (y= 0 ..
BR4: u1 = 0,
/// BR5 [5:5]
/// Port x Reset bit y (y= 0 ..
BR5: u1 = 0,
/// BR6 [6:6]
/// Port x Reset bit y (y= 0 ..
BR6: u1 = 0,
/// BR7 [7:7]
/// Port x Reset bit y (y= 0 ..
BR7: u1 = 0,
/// BR8 [8:8]
/// Port x Reset bit y (y= 0 ..
BR8: u1 = 0,
/// BR9 [9:9]
/// Port x Reset bit y (y= 0 ..
BR9: u1 = 0,
/// BR10 [10:10]
/// Port x Reset bit y (y= 0 ..
BR10: u1 = 0,
/// BR11 [11:11]
/// Port x Reset bit y (y= 0 ..
BR11: u1 = 0,
/// BR12 [12:12]
/// Port x Reset bit y (y= 0 ..
BR12: u1 = 0,
/// BR13 [13:13]
/// Port x Reset bit y (y= 0 ..
BR13: u1 = 0,
/// BR14 [14:14]
/// Port x Reset bit y (y= 0 ..
BR14: u1 = 0,
/// BR15 [15:15]
/// Port x Reset bit y (y= 0 ..
BR15: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO port bit reset register
pub const BRR = Register(BRR_val).init(base_address + 0x28);
};

/// Low power timer
pub const LPTIM = struct {

const base_address = 0x40007c00;
/// ISR
const ISR_val = packed struct {
/// CMPM [0:0]
/// Compare match
CMPM: u1 = 0,
/// ARRM [1:1]
/// Autoreload match
ARRM: u1 = 0,
/// EXTTRIG [2:2]
/// External trigger edge
EXTTRIG: u1 = 0,
/// CMPOK [3:3]
/// Compare register update OK
CMPOK: u1 = 0,
/// ARROK [4:4]
/// Autoreload register update
ARROK: u1 = 0,
/// UP [5:5]
/// Counter direction change down to
UP: u1 = 0,
/// DOWN [6:6]
/// Counter direction change up to
DOWN: u1 = 0,
/// unused [7:31]
_unused7: u1 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Interrupt and Status Register
pub const ISR = Register(ISR_val).init(base_address + 0x0);

/// ICR
const ICR_val = packed struct {
/// CMPMCF [0:0]
/// compare match Clear Flag
CMPMCF: u1 = 0,
/// ARRMCF [1:1]
/// Autoreload match Clear
ARRMCF: u1 = 0,
/// EXTTRIGCF [2:2]
/// External trigger valid edge Clear
EXTTRIGCF: u1 = 0,
/// CMPOKCF [3:3]
/// Compare register update OK Clear
CMPOKCF: u1 = 0,
/// ARROKCF [4:4]
/// Autoreload register update OK Clear
ARROKCF: u1 = 0,
/// UPCF [5:5]
/// Direction change to UP Clear
UPCF: u1 = 0,
/// DOWNCF [6:6]
/// Direction change to down Clear
DOWNCF: u1 = 0,
/// unused [7:31]
_unused7: u1 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Interrupt Clear Register
pub const ICR = Register(ICR_val).init(base_address + 0x4);

/// IER
const IER_val = packed struct {
/// CMPMIE [0:0]
/// Compare match Interrupt
CMPMIE: u1 = 0,
/// ARRMIE [1:1]
/// Autoreload match Interrupt
ARRMIE: u1 = 0,
/// EXTTRIGIE [2:2]
/// External trigger valid edge Interrupt
EXTTRIGIE: u1 = 0,
/// CMPOKIE [3:3]
/// Compare register update OK Interrupt
CMPOKIE: u1 = 0,
/// ARROKIE [4:4]
/// Autoreload register update OK Interrupt
ARROKIE: u1 = 0,
/// UPIE [5:5]
/// Direction change to UP Interrupt
UPIE: u1 = 0,
/// DOWNIE [6:6]
/// Direction change to down Interrupt
DOWNIE: u1 = 0,
/// unused [7:31]
_unused7: u1 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Interrupt Enable Register
pub const IER = Register(IER_val).init(base_address + 0x8);

/// CFGR
const CFGR_val = packed struct {
/// CKSEL [0:0]
/// Clock selector
CKSEL: u1 = 0,
/// CKPOL [1:2]
/// Clock Polarity
CKPOL: u2 = 0,
/// CKFLT [3:4]
/// Configurable digital filter for external
CKFLT: u2 = 0,
/// unused [5:5]
_unused5: u1 = 0,
/// TRGFLT [6:7]
/// Configurable digital filter for
TRGFLT: u2 = 0,
/// unused [8:8]
_unused8: u1 = 0,
/// PRESC [9:11]
/// Clock prescaler
PRESC: u3 = 0,
/// unused [12:12]
_unused12: u1 = 0,
/// TRIGSEL [13:15]
/// Trigger selector
TRIGSEL: u3 = 0,
/// unused [16:16]
_unused16: u1 = 0,
/// TRIGEN [17:18]
/// Trigger enable and
TRIGEN: u2 = 0,
/// TIMOUT [19:19]
/// Timeout enable
TIMOUT: u1 = 0,
/// WAVE [20:20]
/// Waveform shape
WAVE: u1 = 0,
/// WAVPOL [21:21]
/// Waveform shape polarity
WAVPOL: u1 = 0,
/// PRELOAD [22:22]
/// Registers update mode
PRELOAD: u1 = 0,
/// COUNTMODE [23:23]
/// counter mode enabled
COUNTMODE: u1 = 0,
/// ENC [24:24]
/// Encoder mode enable
ENC: u1 = 0,
/// unused [25:31]
_unused25: u7 = 0,
};
/// Configuration Register
pub const CFGR = Register(CFGR_val).init(base_address + 0xc);

/// CR
const CR_val = packed struct {
/// ENABLE [0:0]
/// LPTIM Enable
ENABLE: u1 = 0,
/// SNGSTRT [1:1]
/// LPTIM start in single mode
SNGSTRT: u1 = 0,
/// CNTSTRT [2:2]
/// Timer start in continuous
CNTSTRT: u1 = 0,
/// unused [3:31]
_unused3: u5 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Control Register
pub const CR = Register(CR_val).init(base_address + 0x10);

/// CMP
const CMP_val = packed struct {
/// CMP [0:15]
/// Compare value.
CMP: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Compare Register
pub const CMP = Register(CMP_val).init(base_address + 0x14);

/// ARR
const ARR_val = packed struct {
/// ARR [0:15]
/// Auto reload value.
ARR: u16 = 1,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Autoreload Register
pub const ARR = Register(ARR_val).init(base_address + 0x18);

/// CNT
const CNT_val = packed struct {
/// CNT [0:15]
/// Counter value.
CNT: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Counter Register
pub const CNT = Register(CNT_val).init(base_address + 0x1c);
};

/// Random number generator
pub const RNG = struct {

const base_address = 0x40025000;
/// CR
const CR_val = packed struct {
/// unused [0:1]
_unused0: u2 = 0,
/// RNGEN [2:2]
/// Random number generator
RNGEN: u1 = 0,
/// IE [3:3]
/// Interrupt enable
IE: u1 = 0,
/// unused [4:31]
_unused4: u4 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register
pub const CR = Register(CR_val).init(base_address + 0x0);

/// SR
const SR_val = packed struct {
/// DRDY [0:0]
/// Data ready
DRDY: u1 = 0,
/// CECS [1:1]
/// Clock error current status
CECS: u1 = 0,
/// SECS [2:2]
/// Seed error current status
SECS: u1 = 0,
/// unused [3:4]
_unused3: u2 = 0,
/// CEIS [5:5]
/// Clock error interrupt
CEIS: u1 = 0,
/// SEIS [6:6]
/// Seed error interrupt
SEIS: u1 = 0,
/// unused [7:31]
_unused7: u1 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// status register
pub const SR = Register(SR_val).init(base_address + 0x4);

/// DR
const DR_val = packed struct {
/// RNDATA [0:31]
/// Random data
RNDATA: u32 = 0,
};
/// data register
pub const DR = Register(DR_val).init(base_address + 0x8);
};

/// Real-time clock
pub const RTC = struct {

const base_address = 0x40002800;
/// TR
const TR_val = packed struct {
/// SU [0:3]
/// Second units in BCD format
SU: u4 = 0,
/// ST [4:6]
/// Second tens in BCD format
ST: u3 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// MNU [8:11]
/// Minute units in BCD format
MNU: u4 = 0,
/// MNT [12:14]
/// Minute tens in BCD format
MNT: u3 = 0,
/// unused [15:15]
_unused15: u1 = 0,
/// HU [16:19]
/// Hour units in BCD format
HU: u4 = 0,
/// HT [20:21]
/// Hour tens in BCD format
HT: u2 = 0,
/// PM [22:22]
/// AM/PM notation
PM: u1 = 0,
/// unused [23:31]
_unused23: u1 = 0,
_unused24: u8 = 0,
};
/// RTC time register
pub const TR = Register(TR_val).init(base_address + 0x0);

/// DR
const DR_val = packed struct {
/// DU [0:3]
/// Date units in BCD format
DU: u4 = 0,
/// DT [4:5]
/// Date tens in BCD format
DT: u2 = 0,
/// unused [6:7]
_unused6: u2 = 0,
/// MU [8:11]
/// Month units in BCD format
MU: u4 = 0,
/// MT [12:12]
/// Month tens in BCD format
MT: u1 = 0,
/// WDU [13:15]
/// Week day units
WDU: u3 = 0,
/// YU [16:19]
/// Year units in BCD format
YU: u4 = 0,
/// YT [20:23]
/// Year tens in BCD format
YT: u4 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// RTC date register
pub const DR = Register(DR_val).init(base_address + 0x4);

/// CR
const CR_val = packed struct {
/// WUCKSEL [0:2]
/// Wakeup clock selection
WUCKSEL: u3 = 0,
/// TSEDGE [3:3]
/// Time-stamp event active
TSEDGE: u1 = 0,
/// REFCKON [4:4]
/// RTC_REFIN reference clock detection
REFCKON: u1 = 0,
/// BYPSHAD [5:5]
/// Bypass the shadow
BYPSHAD: u1 = 0,
/// FMT [6:6]
/// Hour format
FMT: u1 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// ALRAE [8:8]
/// Alarm A enable
ALRAE: u1 = 0,
/// ALRBE [9:9]
/// Alarm B enable
ALRBE: u1 = 0,
/// WUTE [10:10]
/// Wakeup timer enable
WUTE: u1 = 0,
/// TSE [11:11]
/// timestamp enable
TSE: u1 = 0,
/// ALRAIE [12:12]
/// Alarm A interrupt enable
ALRAIE: u1 = 0,
/// ALRBIE [13:13]
/// Alarm B interrupt enable
ALRBIE: u1 = 0,
/// WUTIE [14:14]
/// Wakeup timer interrupt
WUTIE: u1 = 0,
/// TSIE [15:15]
/// Time-stamp interrupt
TSIE: u1 = 0,
/// ADD1H [16:16]
/// Add 1 hour (summer time
ADD1H: u1 = 0,
/// SUB1H [17:17]
/// Subtract 1 hour (winter time
SUB1H: u1 = 0,
/// BKP [18:18]
/// Backup
BKP: u1 = 0,
/// COSEL [19:19]
/// Calibration output
COSEL: u1 = 0,
/// POL [20:20]
/// Output polarity
POL: u1 = 0,
/// OSEL [21:22]
/// Output selection
OSEL: u2 = 0,
/// COE [23:23]
/// Calibration output enable
COE: u1 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// RTC control register
pub const CR = Register(CR_val).init(base_address + 0x8);

/// ISR
const ISR_val = packed struct {
/// ALRAWF [0:0]
/// Alarm A write flag
ALRAWF: u1 = 0,
/// ALRBWF [1:1]
/// Alarm B write flag
ALRBWF: u1 = 0,
/// WUTWF [2:2]
/// Wakeup timer write flag
WUTWF: u1 = 0,
/// SHPF [3:3]
/// Shift operation pending
SHPF: u1 = 0,
/// INITS [4:4]
/// Initialization status flag
INITS: u1 = 0,
/// RSF [5:5]
/// Registers synchronization
RSF: u1 = 0,
/// INITF [6:6]
/// Initialization flag
INITF: u1 = 0,
/// INIT [7:7]
/// Initialization mode
INIT: u1 = 0,
/// ALRAF [8:8]
/// Alarm A flag
ALRAF: u1 = 0,
/// ALRBF [9:9]
/// Alarm B flag
ALRBF: u1 = 0,
/// WUTF [10:10]
/// Wakeup timer flag
WUTF: u1 = 0,
/// TSF [11:11]
/// Time-stamp flag
TSF: u1 = 0,
/// TSOVF [12:12]
/// Time-stamp overflow flag
TSOVF: u1 = 0,
/// TAMP1F [13:13]
/// RTC_TAMP1 detection flag
TAMP1F: u1 = 0,
/// TAMP2F [14:14]
/// RTC_TAMP2 detection flag
TAMP2F: u1 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// RTC initialization and status
pub const ISR = Register(ISR_val).init(base_address + 0xc);

/// PRER
const PRER_val = packed struct {
/// PREDIV_S [0:15]
/// Synchronous prescaler
PREDIV_S: u16 = 0,
/// PREDIV_A [16:22]
/// Asynchronous prescaler
PREDIV_A: u7 = 0,
/// unused [23:31]
_unused23: u1 = 0,
_unused24: u8 = 0,
};
/// RTC prescaler register
pub const PRER = Register(PRER_val).init(base_address + 0x10);

/// WUTR
const WUTR_val = packed struct {
/// WUT [0:15]
/// Wakeup auto-reload value
WUT: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// RTC wakeup timer register
pub const WUTR = Register(WUTR_val).init(base_address + 0x14);

/// ALRMAR
const ALRMAR_val = packed struct {
/// SU [0:3]
/// Second units in BCD
SU: u4 = 0,
/// ST [4:6]
/// Second tens in BCD format.
ST: u3 = 0,
/// MSK1 [7:7]
/// Alarm A seconds mask
MSK1: u1 = 0,
/// MNU [8:11]
/// Minute units in BCD
MNU: u4 = 0,
/// MNT [12:14]
/// Minute tens in BCD format.
MNT: u3 = 0,
/// MSK2 [15:15]
/// Alarm A minutes mask
MSK2: u1 = 0,
/// HU [16:19]
/// Hour units in BCD format.
HU: u4 = 0,
/// HT [20:21]
/// Hour tens in BCD format.
HT: u2 = 0,
/// PM [22:22]
/// AM/PM notation
PM: u1 = 0,
/// MSK3 [23:23]
/// Alarm A hours mask
MSK3: u1 = 0,
/// DU [24:27]
/// Date units or day in BCD
DU: u4 = 0,
/// DT [28:29]
/// Date tens in BCD format.
DT: u2 = 0,
/// WDSEL [30:30]
/// Week day selection
WDSEL: u1 = 0,
/// MSK4 [31:31]
/// Alarm A date mask
MSK4: u1 = 0,
};
/// RTC alarm A register
pub const ALRMAR = Register(ALRMAR_val).init(base_address + 0x1c);

/// ALRMBR
const ALRMBR_val = packed struct {
/// SU [0:3]
/// Second units in BCD format
SU: u4 = 0,
/// ST [4:6]
/// Second tens in BCD format
ST: u3 = 0,
/// MSK1 [7:7]
/// Alarm B seconds mask
MSK1: u1 = 0,
/// MNU [8:11]
/// Minute units in BCD format
MNU: u4 = 0,
/// MNT [12:14]
/// Minute tens in BCD format
MNT: u3 = 0,
/// MSK2 [15:15]
/// Alarm B minutes mask
MSK2: u1 = 0,
/// HU [16:19]
/// Hour units in BCD format
HU: u4 = 0,
/// HT [20:21]
/// Hour tens in BCD format
HT: u2 = 0,
/// PM [22:22]
/// AM/PM notation
PM: u1 = 0,
/// MSK3 [23:23]
/// Alarm B hours mask
MSK3: u1 = 0,
/// DU [24:27]
/// Date units or day in BCD
DU: u4 = 0,
/// DT [28:29]
/// Date tens in BCD format
DT: u2 = 0,
/// WDSEL [30:30]
/// Week day selection
WDSEL: u1 = 0,
/// MSK4 [31:31]
/// Alarm B date mask
MSK4: u1 = 0,
};
/// RTC alarm B register
pub const ALRMBR = Register(ALRMBR_val).init(base_address + 0x20);

/// WPR
const WPR_val = packed struct {
/// KEY [0:7]
/// Write protection key
KEY: u8 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// write protection register
pub const WPR = Register(WPR_val).init(base_address + 0x24);

/// SSR
const SSR_val = packed struct {
/// SS [0:15]
/// Sub second value
SS: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// RTC sub second register
pub const SSR = Register(SSR_val).init(base_address + 0x28);

/// SHIFTR
const SHIFTR_val = packed struct {
/// SUBFS [0:14]
/// Subtract a fraction of a
SUBFS: u15 = 0,
/// unused [15:30]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u7 = 0,
/// ADD1S [31:31]
/// Add one second
ADD1S: u1 = 0,
};
/// RTC shift control register
pub const SHIFTR = Register(SHIFTR_val).init(base_address + 0x2c);

/// TSTR
const TSTR_val = packed struct {
/// SU [0:3]
/// Second units in BCD
SU: u4 = 0,
/// ST [4:6]
/// Second tens in BCD format.
ST: u3 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// MNU [8:11]
/// Minute units in BCD
MNU: u4 = 0,
/// MNT [12:14]
/// Minute tens in BCD format.
MNT: u3 = 0,
/// unused [15:15]
_unused15: u1 = 0,
/// HU [16:19]
/// Hour units in BCD format.
HU: u4 = 0,
/// HT [20:21]
/// Hour tens in BCD format.
HT: u2 = 0,
/// PM [22:22]
/// AM/PM notation
PM: u1 = 0,
/// unused [23:31]
_unused23: u1 = 0,
_unused24: u8 = 0,
};
/// RTC timestamp time register
pub const TSTR = Register(TSTR_val).init(base_address + 0x30);

/// TSDR
const TSDR_val = packed struct {
/// DU [0:3]
/// Date units in BCD format
DU: u4 = 0,
/// DT [4:5]
/// Date tens in BCD format
DT: u2 = 0,
/// unused [6:7]
_unused6: u2 = 0,
/// MU [8:11]
/// Month units in BCD format
MU: u4 = 0,
/// MT [12:12]
/// Month tens in BCD format
MT: u1 = 0,
/// WDU [13:15]
/// Week day units
WDU: u3 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// RTC timestamp date register
pub const TSDR = Register(TSDR_val).init(base_address + 0x34);

/// TSSSR
const TSSSR_val = packed struct {
/// SS [0:15]
/// Sub second value
SS: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// RTC time-stamp sub second
pub const TSSSR = Register(TSSSR_val).init(base_address + 0x38);

/// CALR
const CALR_val = packed struct {
/// CALM [0:8]
/// Calibration minus
CALM: u9 = 0,
/// unused [9:12]
_unused9: u4 = 0,
/// CALW16 [13:13]
/// Use a 16-second calibration cycle
CALW16: u1 = 0,
/// CALW8 [14:14]
/// Use a 8-second calibration cycle
CALW8: u1 = 0,
/// CALP [15:15]
/// Increase frequency of RTC by 488.5
CALP: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// RTC calibration register
pub const CALR = Register(CALR_val).init(base_address + 0x3c);

/// TAMPCR
const TAMPCR_val = packed struct {
/// TAMP1E [0:0]
/// RTC_TAMP1 input detection
TAMP1E: u1 = 0,
/// TAMP1TRG [1:1]
/// Active level for RTC_TAMP1
TAMP1TRG: u1 = 0,
/// TAMPIE [2:2]
/// Tamper interrupt enable
TAMPIE: u1 = 0,
/// TAMP2E [3:3]
/// RTC_TAMP2 input detection
TAMP2E: u1 = 0,
/// TAMP2_TRG [4:4]
/// Active level for RTC_TAMP2
TAMP2_TRG: u1 = 0,
/// unused [5:6]
_unused5: u2 = 0,
/// TAMPTS [7:7]
/// Activate timestamp on tamper detection
TAMPTS: u1 = 0,
/// TAMPFREQ [8:10]
/// Tamper sampling frequency
TAMPFREQ: u3 = 0,
/// TAMPFLT [11:12]
/// RTC_TAMPx filter count
TAMPFLT: u2 = 0,
/// TAMPPRCH [13:14]
/// RTC_TAMPx precharge
TAMPPRCH: u2 = 0,
/// TAMPPUDIS [15:15]
/// RTC_TAMPx pull-up disable
TAMPPUDIS: u1 = 0,
/// TAMP1IE [16:16]
/// Tamper 1 interrupt enable
TAMP1IE: u1 = 0,
/// TAMP1NOERASE [17:17]
/// Tamper 1 no erase
TAMP1NOERASE: u1 = 0,
/// TAMP1MF [18:18]
/// Tamper 1 mask flag
TAMP1MF: u1 = 0,
/// TAMP2IE [19:19]
/// Tamper 2 interrupt enable
TAMP2IE: u1 = 0,
/// TAMP2NOERASE [20:20]
/// Tamper 2 no erase
TAMP2NOERASE: u1 = 0,
/// TAMP2MF [21:21]
/// Tamper 2 mask flag
TAMP2MF: u1 = 0,
/// unused [22:31]
_unused22: u2 = 0,
_unused24: u8 = 0,
};
/// RTC tamper configuration
pub const TAMPCR = Register(TAMPCR_val).init(base_address + 0x40);

/// ALRMASSR
const ALRMASSR_val = packed struct {
/// SS [0:14]
/// Sub seconds value
SS: u15 = 0,
/// unused [15:23]
_unused15: u1 = 0,
_unused16: u8 = 0,
/// MASKSS [24:27]
/// Mask the most-significant bits starting
MASKSS: u4 = 0,
/// unused [28:31]
_unused28: u4 = 0,
};
/// RTC alarm A sub second
pub const ALRMASSR = Register(ALRMASSR_val).init(base_address + 0x44);

/// ALRMBSSR
const ALRMBSSR_val = packed struct {
/// SS [0:14]
/// Sub seconds value
SS: u15 = 0,
/// unused [15:23]
_unused15: u1 = 0,
_unused16: u8 = 0,
/// MASKSS [24:27]
/// Mask the most-significant bits starting
MASKSS: u4 = 0,
/// unused [28:31]
_unused28: u4 = 0,
};
/// RTC alarm B sub second
pub const ALRMBSSR = Register(ALRMBSSR_val).init(base_address + 0x48);

/// OR
const OR_val = packed struct {
/// RTC_ALARM_TYPE [0:0]
/// RTC_ALARM on PC13 output
RTC_ALARM_TYPE: u1 = 0,
/// RTC_OUT_RMP [1:1]
/// RTC_ALARM on PC13 output
RTC_OUT_RMP: u1 = 0,
/// unused [2:31]
_unused2: u6 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// option register
pub const OR = Register(OR_val).init(base_address + 0x4c);

/// BKP0R
const BKP0R_val = packed struct {
/// BKP [0:31]
/// BKP
BKP: u32 = 0,
};
/// RTC backup registers
pub const BKP0R = Register(BKP0R_val).init(base_address + 0x50);

/// BKP1R
const BKP1R_val = packed struct {
/// BKP [0:31]
/// BKP
BKP: u32 = 0,
};
/// RTC backup registers
pub const BKP1R = Register(BKP1R_val).init(base_address + 0x54);

/// BKP2R
const BKP2R_val = packed struct {
/// BKP [0:31]
/// BKP
BKP: u32 = 0,
};
/// RTC backup registers
pub const BKP2R = Register(BKP2R_val).init(base_address + 0x58);

/// BKP3R
const BKP3R_val = packed struct {
/// BKP [0:31]
/// BKP
BKP: u32 = 0,
};
/// RTC backup registers
pub const BKP3R = Register(BKP3R_val).init(base_address + 0x5c);

/// BKP4R
const BKP4R_val = packed struct {
/// BKP [0:31]
/// BKP
BKP: u32 = 0,
};
/// RTC backup registers
pub const BKP4R = Register(BKP4R_val).init(base_address + 0x60);
};

/// Universal synchronous asynchronous receiver
pub const USART1 = struct {

const base_address = 0x40013800;
/// CR1
const CR1_val = packed struct {
/// UE [0:0]
/// USART enable
UE: u1 = 0,
/// UESM [1:1]
/// USART enable in Stop mode
UESM: u1 = 0,
/// RE [2:2]
/// Receiver enable
RE: u1 = 0,
/// TE [3:3]
/// Transmitter enable
TE: u1 = 0,
/// IDLEIE [4:4]
/// IDLE interrupt enable
IDLEIE: u1 = 0,
/// RXNEIE [5:5]
/// RXNE interrupt enable
RXNEIE: u1 = 0,
/// TCIE [6:6]
/// Transmission complete interrupt
TCIE: u1 = 0,
/// TXEIE [7:7]
/// interrupt enable
TXEIE: u1 = 0,
/// PEIE [8:8]
/// PE interrupt enable
PEIE: u1 = 0,
/// PS [9:9]
/// Parity selection
PS: u1 = 0,
/// PCE [10:10]
/// Parity control enable
PCE: u1 = 0,
/// WAKE [11:11]
/// Receiver wakeup method
WAKE: u1 = 0,
/// M0 [12:12]
/// Word length
M0: u1 = 0,
/// MME [13:13]
/// Mute mode enable
MME: u1 = 0,
/// CMIE [14:14]
/// Character match interrupt
CMIE: u1 = 0,
/// OVER8 [15:15]
/// Oversampling mode
OVER8: u1 = 0,
/// DEDT0 [16:16]
/// DEDT0
DEDT0: u1 = 0,
/// DEDT1 [17:17]
/// DEDT1
DEDT1: u1 = 0,
/// DEDT2 [18:18]
/// DEDT2
DEDT2: u1 = 0,
/// DEDT3 [19:19]
/// DEDT3
DEDT3: u1 = 0,
/// DEDT4 [20:20]
/// Driver Enable de-assertion
DEDT4: u1 = 0,
/// DEAT0 [21:21]
/// DEAT0
DEAT0: u1 = 0,
/// DEAT1 [22:22]
/// DEAT1
DEAT1: u1 = 0,
/// DEAT2 [23:23]
/// DEAT2
DEAT2: u1 = 0,
/// DEAT3 [24:24]
/// DEAT3
DEAT3: u1 = 0,
/// DEAT4 [25:25]
/// Driver Enable assertion
DEAT4: u1 = 0,
/// RTOIE [26:26]
/// Receiver timeout interrupt
RTOIE: u1 = 0,
/// EOBIE [27:27]
/// End of Block interrupt
EOBIE: u1 = 0,
/// M1 [28:28]
/// Word length
M1: u1 = 0,
/// unused [29:31]
_unused29: u3 = 0,
};
/// Control register 1
pub const CR1 = Register(CR1_val).init(base_address + 0x0);

/// CR2
const CR2_val = packed struct {
/// unused [0:3]
_unused0: u4 = 0,
/// ADDM7 [4:4]
/// 7-bit Address Detection/4-bit Address
ADDM7: u1 = 0,
/// LBDL [5:5]
/// LIN break detection length
LBDL: u1 = 0,
/// LBDIE [6:6]
/// LIN break detection interrupt
LBDIE: u1 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// LBCL [8:8]
/// Last bit clock pulse
LBCL: u1 = 0,
/// CPHA [9:9]
/// Clock phase
CPHA: u1 = 0,
/// CPOL [10:10]
/// Clock polarity
CPOL: u1 = 0,
/// CLKEN [11:11]
/// Clock enable
CLKEN: u1 = 0,
/// STOP [12:13]
/// STOP bits
STOP: u2 = 0,
/// LINEN [14:14]
/// LIN mode enable
LINEN: u1 = 0,
/// SWAP [15:15]
/// Swap TX/RX pins
SWAP: u1 = 0,
/// RXINV [16:16]
/// RX pin active level
RXINV: u1 = 0,
/// TXINV [17:17]
/// TX pin active level
TXINV: u1 = 0,
/// TAINV [18:18]
/// Binary data inversion
TAINV: u1 = 0,
/// MSBFIRST [19:19]
/// Most significant bit first
MSBFIRST: u1 = 0,
/// ABREN [20:20]
/// Auto baud rate enable
ABREN: u1 = 0,
/// ABRMOD0 [21:21]
/// ABRMOD0
ABRMOD0: u1 = 0,
/// ABRMOD1 [22:22]
/// Auto baud rate mode
ABRMOD1: u1 = 0,
/// RTOEN [23:23]
/// Receiver timeout enable
RTOEN: u1 = 0,
/// ADD0_3 [24:27]
/// Address of the USART node
ADD0_3: u4 = 0,
/// ADD4_7 [28:31]
/// Address of the USART node
ADD4_7: u4 = 0,
};
/// Control register 2
pub const CR2 = Register(CR2_val).init(base_address + 0x4);

/// CR3
const CR3_val = packed struct {
/// EIE [0:0]
/// Error interrupt enable
EIE: u1 = 0,
/// IREN [1:1]
/// Ir mode enable
IREN: u1 = 0,
/// IRLP [2:2]
/// Ir low-power
IRLP: u1 = 0,
/// HDSEL [3:3]
/// Half-duplex selection
HDSEL: u1 = 0,
/// NACK [4:4]
/// Smartcard NACK enable
NACK: u1 = 0,
/// SCEN [5:5]
/// Smartcard mode enable
SCEN: u1 = 0,
/// DMAR [6:6]
/// DMA enable receiver
DMAR: u1 = 0,
/// DMAT [7:7]
/// DMA enable transmitter
DMAT: u1 = 0,
/// RTSE [8:8]
/// RTS enable
RTSE: u1 = 0,
/// CTSE [9:9]
/// CTS enable
CTSE: u1 = 0,
/// CTSIE [10:10]
/// CTS interrupt enable
CTSIE: u1 = 0,
/// ONEBIT [11:11]
/// One sample bit method
ONEBIT: u1 = 0,
/// OVRDIS [12:12]
/// Overrun Disable
OVRDIS: u1 = 0,
/// DDRE [13:13]
/// DMA Disable on Reception
DDRE: u1 = 0,
/// DEM [14:14]
/// Driver enable mode
DEM: u1 = 0,
/// DEP [15:15]
/// Driver enable polarity
DEP: u1 = 0,
/// unused [16:16]
_unused16: u1 = 0,
/// SCARCNT [17:19]
/// Smartcard auto-retry count
SCARCNT: u3 = 0,
/// WUS [20:21]
/// Wakeup from Stop mode interrupt flag
WUS: u2 = 0,
/// WUFIE [22:22]
/// Wakeup from Stop mode interrupt
WUFIE: u1 = 0,
/// unused [23:31]
_unused23: u1 = 0,
_unused24: u8 = 0,
};
/// Control register 3
pub const CR3 = Register(CR3_val).init(base_address + 0x8);

/// BRR
const BRR_val = packed struct {
/// DIV_Fraction [0:3]
/// DIV_Fraction
DIV_Fraction: u4 = 0,
/// DIV_Mantissa [4:15]
/// DIV_Mantissa
DIV_Mantissa: u12 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Baud rate register
pub const BRR = Register(BRR_val).init(base_address + 0xc);

/// GTPR
const GTPR_val = packed struct {
/// PSC [0:7]
/// Prescaler value
PSC: u8 = 0,
/// GT [8:15]
/// Guard time value
GT: u8 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Guard time and prescaler
pub const GTPR = Register(GTPR_val).init(base_address + 0x10);

/// RTOR
const RTOR_val = packed struct {
/// RTO [0:23]
/// Receiver timeout value
RTO: u24 = 0,
/// BLEN [24:31]
/// Block Length
BLEN: u8 = 0,
};
/// Receiver timeout register
pub const RTOR = Register(RTOR_val).init(base_address + 0x14);

/// RQR
const RQR_val = packed struct {
/// ABRRQ [0:0]
/// Auto baud rate request
ABRRQ: u1 = 0,
/// SBKRQ [1:1]
/// Send break request
SBKRQ: u1 = 0,
/// MMRQ [2:2]
/// Mute mode request
MMRQ: u1 = 0,
/// RXFRQ [3:3]
/// Receive data flush request
RXFRQ: u1 = 0,
/// TXFRQ [4:4]
/// Transmit data flush
TXFRQ: u1 = 0,
/// unused [5:31]
_unused5: u3 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Request register
pub const RQR = Register(RQR_val).init(base_address + 0x18);

/// ISR
const ISR_val = packed struct {
/// PE [0:0]
/// PE
PE: u1 = 0,
/// FE [1:1]
/// FE
FE: u1 = 0,
/// NF [2:2]
/// NF
NF: u1 = 0,
/// ORE [3:3]
/// ORE
ORE: u1 = 0,
/// IDLE [4:4]
/// IDLE
IDLE: u1 = 0,
/// RXNE [5:5]
/// RXNE
RXNE: u1 = 0,
/// TC [6:6]
/// TC
TC: u1 = 1,
/// TXE [7:7]
/// TXE
TXE: u1 = 1,
/// LBDF [8:8]
/// LBDF
LBDF: u1 = 0,
/// CTSIF [9:9]
/// CTSIF
CTSIF: u1 = 0,
/// CTS [10:10]
/// CTS
CTS: u1 = 0,
/// RTOF [11:11]
/// RTOF
RTOF: u1 = 0,
/// EOBF [12:12]
/// EOBF
EOBF: u1 = 0,
/// unused [13:13]
_unused13: u1 = 0,
/// ABRE [14:14]
/// ABRE
ABRE: u1 = 0,
/// ABRF [15:15]
/// ABRF
ABRF: u1 = 0,
/// BUSY [16:16]
/// BUSY
BUSY: u1 = 0,
/// CMF [17:17]
/// CMF
CMF: u1 = 0,
/// SBKF [18:18]
/// SBKF
SBKF: u1 = 0,
/// RWU [19:19]
/// RWU
RWU: u1 = 0,
/// WUF [20:20]
/// WUF
WUF: u1 = 0,
/// TEACK [21:21]
/// TEACK
TEACK: u1 = 0,
/// REACK [22:22]
/// REACK
REACK: u1 = 0,
/// unused [23:31]
_unused23: u1 = 0,
_unused24: u8 = 0,
};
/// Interrupt &amp; status
pub const ISR = Register(ISR_val).init(base_address + 0x1c);

/// ICR
const ICR_val = packed struct {
/// PECF [0:0]
/// Parity error clear flag
PECF: u1 = 0,
/// FECF [1:1]
/// Framing error clear flag
FECF: u1 = 0,
/// NCF [2:2]
/// Noise detected clear flag
NCF: u1 = 0,
/// ORECF [3:3]
/// Overrun error clear flag
ORECF: u1 = 0,
/// IDLECF [4:4]
/// Idle line detected clear
IDLECF: u1 = 0,
/// unused [5:5]
_unused5: u1 = 0,
/// TCCF [6:6]
/// Transmission complete clear
TCCF: u1 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// LBDCF [8:8]
/// LIN break detection clear
LBDCF: u1 = 0,
/// CTSCF [9:9]
/// CTS clear flag
CTSCF: u1 = 0,
/// unused [10:10]
_unused10: u1 = 0,
/// RTOCF [11:11]
/// Receiver timeout clear
RTOCF: u1 = 0,
/// EOBCF [12:12]
/// End of block clear flag
EOBCF: u1 = 0,
/// unused [13:16]
_unused13: u3 = 0,
_unused16: u1 = 0,
/// CMCF [17:17]
/// Character match clear flag
CMCF: u1 = 0,
/// unused [18:19]
_unused18: u2 = 0,
/// WUCF [20:20]
/// Wakeup from Stop mode clear
WUCF: u1 = 0,
/// unused [21:31]
_unused21: u3 = 0,
_unused24: u8 = 0,
};
/// Interrupt flag clear register
pub const ICR = Register(ICR_val).init(base_address + 0x20);

/// RDR
const RDR_val = packed struct {
/// RDR [0:8]
/// Receive data value
RDR: u9 = 0,
/// unused [9:31]
_unused9: u7 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Receive data register
pub const RDR = Register(RDR_val).init(base_address + 0x24);

/// TDR
const TDR_val = packed struct {
/// TDR [0:8]
/// Transmit data value
TDR: u9 = 0,
/// unused [9:31]
_unused9: u7 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Transmit data register
pub const TDR = Register(TDR_val).init(base_address + 0x28);
};

/// Universal synchronous asynchronous receiver
pub const USART2 = struct {

const base_address = 0x40004400;
/// CR1
const CR1_val = packed struct {
/// UE [0:0]
/// USART enable
UE: u1 = 0,
/// UESM [1:1]
/// USART enable in Stop mode
UESM: u1 = 0,
/// RE [2:2]
/// Receiver enable
RE: u1 = 0,
/// TE [3:3]
/// Transmitter enable
TE: u1 = 0,
/// IDLEIE [4:4]
/// IDLE interrupt enable
IDLEIE: u1 = 0,
/// RXNEIE [5:5]
/// RXNE interrupt enable
RXNEIE: u1 = 0,
/// TCIE [6:6]
/// Transmission complete interrupt
TCIE: u1 = 0,
/// TXEIE [7:7]
/// interrupt enable
TXEIE: u1 = 0,
/// PEIE [8:8]
/// PE interrupt enable
PEIE: u1 = 0,
/// PS [9:9]
/// Parity selection
PS: u1 = 0,
/// PCE [10:10]
/// Parity control enable
PCE: u1 = 0,
/// WAKE [11:11]
/// Receiver wakeup method
WAKE: u1 = 0,
/// M0 [12:12]
/// Word length
M0: u1 = 0,
/// MME [13:13]
/// Mute mode enable
MME: u1 = 0,
/// CMIE [14:14]
/// Character match interrupt
CMIE: u1 = 0,
/// OVER8 [15:15]
/// Oversampling mode
OVER8: u1 = 0,
/// DEDT0 [16:16]
/// DEDT0
DEDT0: u1 = 0,
/// DEDT1 [17:17]
/// DEDT1
DEDT1: u1 = 0,
/// DEDT2 [18:18]
/// DEDT2
DEDT2: u1 = 0,
/// DEDT3 [19:19]
/// DEDT3
DEDT3: u1 = 0,
/// DEDT4 [20:20]
/// Driver Enable de-assertion
DEDT4: u1 = 0,
/// DEAT0 [21:21]
/// DEAT0
DEAT0: u1 = 0,
/// DEAT1 [22:22]
/// DEAT1
DEAT1: u1 = 0,
/// DEAT2 [23:23]
/// DEAT2
DEAT2: u1 = 0,
/// DEAT3 [24:24]
/// DEAT3
DEAT3: u1 = 0,
/// DEAT4 [25:25]
/// Driver Enable assertion
DEAT4: u1 = 0,
/// RTOIE [26:26]
/// Receiver timeout interrupt
RTOIE: u1 = 0,
/// EOBIE [27:27]
/// End of Block interrupt
EOBIE: u1 = 0,
/// M1 [28:28]
/// Word length
M1: u1 = 0,
/// unused [29:31]
_unused29: u3 = 0,
};
/// Control register 1
pub const CR1 = Register(CR1_val).init(base_address + 0x0);

/// CR2
const CR2_val = packed struct {
/// unused [0:3]
_unused0: u4 = 0,
/// ADDM7 [4:4]
/// 7-bit Address Detection/4-bit Address
ADDM7: u1 = 0,
/// LBDL [5:5]
/// LIN break detection length
LBDL: u1 = 0,
/// LBDIE [6:6]
/// LIN break detection interrupt
LBDIE: u1 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// LBCL [8:8]
/// Last bit clock pulse
LBCL: u1 = 0,
/// CPHA [9:9]
/// Clock phase
CPHA: u1 = 0,
/// CPOL [10:10]
/// Clock polarity
CPOL: u1 = 0,
/// CLKEN [11:11]
/// Clock enable
CLKEN: u1 = 0,
/// STOP [12:13]
/// STOP bits
STOP: u2 = 0,
/// LINEN [14:14]
/// LIN mode enable
LINEN: u1 = 0,
/// SWAP [15:15]
/// Swap TX/RX pins
SWAP: u1 = 0,
/// RXINV [16:16]
/// RX pin active level
RXINV: u1 = 0,
/// TXINV [17:17]
/// TX pin active level
TXINV: u1 = 0,
/// TAINV [18:18]
/// Binary data inversion
TAINV: u1 = 0,
/// MSBFIRST [19:19]
/// Most significant bit first
MSBFIRST: u1 = 0,
/// ABREN [20:20]
/// Auto baud rate enable
ABREN: u1 = 0,
/// ABRMOD0 [21:21]
/// ABRMOD0
ABRMOD0: u1 = 0,
/// ABRMOD1 [22:22]
/// Auto baud rate mode
ABRMOD1: u1 = 0,
/// RTOEN [23:23]
/// Receiver timeout enable
RTOEN: u1 = 0,
/// ADD0_3 [24:27]
/// Address of the USART node
ADD0_3: u4 = 0,
/// ADD4_7 [28:31]
/// Address of the USART node
ADD4_7: u4 = 0,
};
/// Control register 2
pub const CR2 = Register(CR2_val).init(base_address + 0x4);

/// CR3
const CR3_val = packed struct {
/// EIE [0:0]
/// Error interrupt enable
EIE: u1 = 0,
/// IREN [1:1]
/// Ir mode enable
IREN: u1 = 0,
/// IRLP [2:2]
/// Ir low-power
IRLP: u1 = 0,
/// HDSEL [3:3]
/// Half-duplex selection
HDSEL: u1 = 0,
/// NACK [4:4]
/// Smartcard NACK enable
NACK: u1 = 0,
/// SCEN [5:5]
/// Smartcard mode enable
SCEN: u1 = 0,
/// DMAR [6:6]
/// DMA enable receiver
DMAR: u1 = 0,
/// DMAT [7:7]
/// DMA enable transmitter
DMAT: u1 = 0,
/// RTSE [8:8]
/// RTS enable
RTSE: u1 = 0,
/// CTSE [9:9]
/// CTS enable
CTSE: u1 = 0,
/// CTSIE [10:10]
/// CTS interrupt enable
CTSIE: u1 = 0,
/// ONEBIT [11:11]
/// One sample bit method
ONEBIT: u1 = 0,
/// OVRDIS [12:12]
/// Overrun Disable
OVRDIS: u1 = 0,
/// DDRE [13:13]
/// DMA Disable on Reception
DDRE: u1 = 0,
/// DEM [14:14]
/// Driver enable mode
DEM: u1 = 0,
/// DEP [15:15]
/// Driver enable polarity
DEP: u1 = 0,
/// unused [16:16]
_unused16: u1 = 0,
/// SCARCNT [17:19]
/// Smartcard auto-retry count
SCARCNT: u3 = 0,
/// WUS [20:21]
/// Wakeup from Stop mode interrupt flag
WUS: u2 = 0,
/// WUFIE [22:22]
/// Wakeup from Stop mode interrupt
WUFIE: u1 = 0,
/// unused [23:31]
_unused23: u1 = 0,
_unused24: u8 = 0,
};
/// Control register 3
pub const CR3 = Register(CR3_val).init(base_address + 0x8);

/// BRR
const BRR_val = packed struct {
/// DIV_Fraction [0:3]
/// DIV_Fraction
DIV_Fraction: u4 = 0,
/// DIV_Mantissa [4:15]
/// DIV_Mantissa
DIV_Mantissa: u12 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Baud rate register
pub const BRR = Register(BRR_val).init(base_address + 0xc);

/// GTPR
const GTPR_val = packed struct {
/// PSC [0:7]
/// Prescaler value
PSC: u8 = 0,
/// GT [8:15]
/// Guard time value
GT: u8 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Guard time and prescaler
pub const GTPR = Register(GTPR_val).init(base_address + 0x10);

/// RTOR
const RTOR_val = packed struct {
/// RTO [0:23]
/// Receiver timeout value
RTO: u24 = 0,
/// BLEN [24:31]
/// Block Length
BLEN: u8 = 0,
};
/// Receiver timeout register
pub const RTOR = Register(RTOR_val).init(base_address + 0x14);

/// RQR
const RQR_val = packed struct {
/// ABRRQ [0:0]
/// Auto baud rate request
ABRRQ: u1 = 0,
/// SBKRQ [1:1]
/// Send break request
SBKRQ: u1 = 0,
/// MMRQ [2:2]
/// Mute mode request
MMRQ: u1 = 0,
/// RXFRQ [3:3]
/// Receive data flush request
RXFRQ: u1 = 0,
/// TXFRQ [4:4]
/// Transmit data flush
TXFRQ: u1 = 0,
/// unused [5:31]
_unused5: u3 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Request register
pub const RQR = Register(RQR_val).init(base_address + 0x18);

/// ISR
const ISR_val = packed struct {
/// PE [0:0]
/// PE
PE: u1 = 0,
/// FE [1:1]
/// FE
FE: u1 = 0,
/// NF [2:2]
/// NF
NF: u1 = 0,
/// ORE [3:3]
/// ORE
ORE: u1 = 0,
/// IDLE [4:4]
/// IDLE
IDLE: u1 = 0,
/// RXNE [5:5]
/// RXNE
RXNE: u1 = 0,
/// TC [6:6]
/// TC
TC: u1 = 1,
/// TXE [7:7]
/// TXE
TXE: u1 = 1,
/// LBDF [8:8]
/// LBDF
LBDF: u1 = 0,
/// CTSIF [9:9]
/// CTSIF
CTSIF: u1 = 0,
/// CTS [10:10]
/// CTS
CTS: u1 = 0,
/// RTOF [11:11]
/// RTOF
RTOF: u1 = 0,
/// EOBF [12:12]
/// EOBF
EOBF: u1 = 0,
/// unused [13:13]
_unused13: u1 = 0,
/// ABRE [14:14]
/// ABRE
ABRE: u1 = 0,
/// ABRF [15:15]
/// ABRF
ABRF: u1 = 0,
/// BUSY [16:16]
/// BUSY
BUSY: u1 = 0,
/// CMF [17:17]
/// CMF
CMF: u1 = 0,
/// SBKF [18:18]
/// SBKF
SBKF: u1 = 0,
/// RWU [19:19]
/// RWU
RWU: u1 = 0,
/// WUF [20:20]
/// WUF
WUF: u1 = 0,
/// TEACK [21:21]
/// TEACK
TEACK: u1 = 0,
/// REACK [22:22]
/// REACK
REACK: u1 = 0,
/// unused [23:31]
_unused23: u1 = 0,
_unused24: u8 = 0,
};
/// Interrupt &amp; status
pub const ISR = Register(ISR_val).init(base_address + 0x1c);

/// ICR
const ICR_val = packed struct {
/// PECF [0:0]
/// Parity error clear flag
PECF: u1 = 0,
/// FECF [1:1]
/// Framing error clear flag
FECF: u1 = 0,
/// NCF [2:2]
/// Noise detected clear flag
NCF: u1 = 0,
/// ORECF [3:3]
/// Overrun error clear flag
ORECF: u1 = 0,
/// IDLECF [4:4]
/// Idle line detected clear
IDLECF: u1 = 0,
/// unused [5:5]
_unused5: u1 = 0,
/// TCCF [6:6]
/// Transmission complete clear
TCCF: u1 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// LBDCF [8:8]
/// LIN break detection clear
LBDCF: u1 = 0,
/// CTSCF [9:9]
/// CTS clear flag
CTSCF: u1 = 0,
/// unused [10:10]
_unused10: u1 = 0,
/// RTOCF [11:11]
/// Receiver timeout clear
RTOCF: u1 = 0,
/// EOBCF [12:12]
/// End of block clear flag
EOBCF: u1 = 0,
/// unused [13:16]
_unused13: u3 = 0,
_unused16: u1 = 0,
/// CMCF [17:17]
/// Character match clear flag
CMCF: u1 = 0,
/// unused [18:19]
_unused18: u2 = 0,
/// WUCF [20:20]
/// Wakeup from Stop mode clear
WUCF: u1 = 0,
/// unused [21:31]
_unused21: u3 = 0,
_unused24: u8 = 0,
};
/// Interrupt flag clear register
pub const ICR = Register(ICR_val).init(base_address + 0x20);

/// RDR
const RDR_val = packed struct {
/// RDR [0:8]
/// Receive data value
RDR: u9 = 0,
/// unused [9:31]
_unused9: u7 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Receive data register
pub const RDR = Register(RDR_val).init(base_address + 0x24);

/// TDR
const TDR_val = packed struct {
/// TDR [0:8]
/// Transmit data value
TDR: u9 = 0,
/// unused [9:31]
_unused9: u7 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Transmit data register
pub const TDR = Register(TDR_val).init(base_address + 0x28);
};

/// Universal synchronous asynchronous receiver
pub const USART4 = struct {

const base_address = 0x40004c00;
/// CR1
const CR1_val = packed struct {
/// UE [0:0]
/// USART enable
UE: u1 = 0,
/// UESM [1:1]
/// USART enable in Stop mode
UESM: u1 = 0,
/// RE [2:2]
/// Receiver enable
RE: u1 = 0,
/// TE [3:3]
/// Transmitter enable
TE: u1 = 0,
/// IDLEIE [4:4]
/// IDLE interrupt enable
IDLEIE: u1 = 0,
/// RXNEIE [5:5]
/// RXNE interrupt enable
RXNEIE: u1 = 0,
/// TCIE [6:6]
/// Transmission complete interrupt
TCIE: u1 = 0,
/// TXEIE [7:7]
/// interrupt enable
TXEIE: u1 = 0,
/// PEIE [8:8]
/// PE interrupt enable
PEIE: u1 = 0,
/// PS [9:9]
/// Parity selection
PS: u1 = 0,
/// PCE [10:10]
/// Parity control enable
PCE: u1 = 0,
/// WAKE [11:11]
/// Receiver wakeup method
WAKE: u1 = 0,
/// M0 [12:12]
/// Word length
M0: u1 = 0,
/// MME [13:13]
/// Mute mode enable
MME: u1 = 0,
/// CMIE [14:14]
/// Character match interrupt
CMIE: u1 = 0,
/// OVER8 [15:15]
/// Oversampling mode
OVER8: u1 = 0,
/// DEDT0 [16:16]
/// DEDT0
DEDT0: u1 = 0,
/// DEDT1 [17:17]
/// DEDT1
DEDT1: u1 = 0,
/// DEDT2 [18:18]
/// DEDT2
DEDT2: u1 = 0,
/// DEDT3 [19:19]
/// DEDT3
DEDT3: u1 = 0,
/// DEDT4 [20:20]
/// Driver Enable de-assertion
DEDT4: u1 = 0,
/// DEAT0 [21:21]
/// DEAT0
DEAT0: u1 = 0,
/// DEAT1 [22:22]
/// DEAT1
DEAT1: u1 = 0,
/// DEAT2 [23:23]
/// DEAT2
DEAT2: u1 = 0,
/// DEAT3 [24:24]
/// DEAT3
DEAT3: u1 = 0,
/// DEAT4 [25:25]
/// Driver Enable assertion
DEAT4: u1 = 0,
/// RTOIE [26:26]
/// Receiver timeout interrupt
RTOIE: u1 = 0,
/// EOBIE [27:27]
/// End of Block interrupt
EOBIE: u1 = 0,
/// M1 [28:28]
/// Word length
M1: u1 = 0,
/// unused [29:31]
_unused29: u3 = 0,
};
/// Control register 1
pub const CR1 = Register(CR1_val).init(base_address + 0x0);

/// CR2
const CR2_val = packed struct {
/// unused [0:3]
_unused0: u4 = 0,
/// ADDM7 [4:4]
/// 7-bit Address Detection/4-bit Address
ADDM7: u1 = 0,
/// LBDL [5:5]
/// LIN break detection length
LBDL: u1 = 0,
/// LBDIE [6:6]
/// LIN break detection interrupt
LBDIE: u1 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// LBCL [8:8]
/// Last bit clock pulse
LBCL: u1 = 0,
/// CPHA [9:9]
/// Clock phase
CPHA: u1 = 0,
/// CPOL [10:10]
/// Clock polarity
CPOL: u1 = 0,
/// CLKEN [11:11]
/// Clock enable
CLKEN: u1 = 0,
/// STOP [12:13]
/// STOP bits
STOP: u2 = 0,
/// LINEN [14:14]
/// LIN mode enable
LINEN: u1 = 0,
/// SWAP [15:15]
/// Swap TX/RX pins
SWAP: u1 = 0,
/// RXINV [16:16]
/// RX pin active level
RXINV: u1 = 0,
/// TXINV [17:17]
/// TX pin active level
TXINV: u1 = 0,
/// TAINV [18:18]
/// Binary data inversion
TAINV: u1 = 0,
/// MSBFIRST [19:19]
/// Most significant bit first
MSBFIRST: u1 = 0,
/// ABREN [20:20]
/// Auto baud rate enable
ABREN: u1 = 0,
/// ABRMOD0 [21:21]
/// ABRMOD0
ABRMOD0: u1 = 0,
/// ABRMOD1 [22:22]
/// Auto baud rate mode
ABRMOD1: u1 = 0,
/// RTOEN [23:23]
/// Receiver timeout enable
RTOEN: u1 = 0,
/// ADD0_3 [24:27]
/// Address of the USART node
ADD0_3: u4 = 0,
/// ADD4_7 [28:31]
/// Address of the USART node
ADD4_7: u4 = 0,
};
/// Control register 2
pub const CR2 = Register(CR2_val).init(base_address + 0x4);

/// CR3
const CR3_val = packed struct {
/// EIE [0:0]
/// Error interrupt enable
EIE: u1 = 0,
/// IREN [1:1]
/// Ir mode enable
IREN: u1 = 0,
/// IRLP [2:2]
/// Ir low-power
IRLP: u1 = 0,
/// HDSEL [3:3]
/// Half-duplex selection
HDSEL: u1 = 0,
/// NACK [4:4]
/// Smartcard NACK enable
NACK: u1 = 0,
/// SCEN [5:5]
/// Smartcard mode enable
SCEN: u1 = 0,
/// DMAR [6:6]
/// DMA enable receiver
DMAR: u1 = 0,
/// DMAT [7:7]
/// DMA enable transmitter
DMAT: u1 = 0,
/// RTSE [8:8]
/// RTS enable
RTSE: u1 = 0,
/// CTSE [9:9]
/// CTS enable
CTSE: u1 = 0,
/// CTSIE [10:10]
/// CTS interrupt enable
CTSIE: u1 = 0,
/// ONEBIT [11:11]
/// One sample bit method
ONEBIT: u1 = 0,
/// OVRDIS [12:12]
/// Overrun Disable
OVRDIS: u1 = 0,
/// DDRE [13:13]
/// DMA Disable on Reception
DDRE: u1 = 0,
/// DEM [14:14]
/// Driver enable mode
DEM: u1 = 0,
/// DEP [15:15]
/// Driver enable polarity
DEP: u1 = 0,
/// unused [16:16]
_unused16: u1 = 0,
/// SCARCNT [17:19]
/// Smartcard auto-retry count
SCARCNT: u3 = 0,
/// WUS [20:21]
/// Wakeup from Stop mode interrupt flag
WUS: u2 = 0,
/// WUFIE [22:22]
/// Wakeup from Stop mode interrupt
WUFIE: u1 = 0,
/// unused [23:31]
_unused23: u1 = 0,
_unused24: u8 = 0,
};
/// Control register 3
pub const CR3 = Register(CR3_val).init(base_address + 0x8);

/// BRR
const BRR_val = packed struct {
/// DIV_Fraction [0:3]
/// DIV_Fraction
DIV_Fraction: u4 = 0,
/// DIV_Mantissa [4:15]
/// DIV_Mantissa
DIV_Mantissa: u12 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Baud rate register
pub const BRR = Register(BRR_val).init(base_address + 0xc);

/// GTPR
const GTPR_val = packed struct {
/// PSC [0:7]
/// Prescaler value
PSC: u8 = 0,
/// GT [8:15]
/// Guard time value
GT: u8 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Guard time and prescaler
pub const GTPR = Register(GTPR_val).init(base_address + 0x10);

/// RTOR
const RTOR_val = packed struct {
/// RTO [0:23]
/// Receiver timeout value
RTO: u24 = 0,
/// BLEN [24:31]
/// Block Length
BLEN: u8 = 0,
};
/// Receiver timeout register
pub const RTOR = Register(RTOR_val).init(base_address + 0x14);

/// RQR
const RQR_val = packed struct {
/// ABRRQ [0:0]
/// Auto baud rate request
ABRRQ: u1 = 0,
/// SBKRQ [1:1]
/// Send break request
SBKRQ: u1 = 0,
/// MMRQ [2:2]
/// Mute mode request
MMRQ: u1 = 0,
/// RXFRQ [3:3]
/// Receive data flush request
RXFRQ: u1 = 0,
/// TXFRQ [4:4]
/// Transmit data flush
TXFRQ: u1 = 0,
/// unused [5:31]
_unused5: u3 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Request register
pub const RQR = Register(RQR_val).init(base_address + 0x18);

/// ISR
const ISR_val = packed struct {
/// PE [0:0]
/// PE
PE: u1 = 0,
/// FE [1:1]
/// FE
FE: u1 = 0,
/// NF [2:2]
/// NF
NF: u1 = 0,
/// ORE [3:3]
/// ORE
ORE: u1 = 0,
/// IDLE [4:4]
/// IDLE
IDLE: u1 = 0,
/// RXNE [5:5]
/// RXNE
RXNE: u1 = 0,
/// TC [6:6]
/// TC
TC: u1 = 1,
/// TXE [7:7]
/// TXE
TXE: u1 = 1,
/// LBDF [8:8]
/// LBDF
LBDF: u1 = 0,
/// CTSIF [9:9]
/// CTSIF
CTSIF: u1 = 0,
/// CTS [10:10]
/// CTS
CTS: u1 = 0,
/// RTOF [11:11]
/// RTOF
RTOF: u1 = 0,
/// EOBF [12:12]
/// EOBF
EOBF: u1 = 0,
/// unused [13:13]
_unused13: u1 = 0,
/// ABRE [14:14]
/// ABRE
ABRE: u1 = 0,
/// ABRF [15:15]
/// ABRF
ABRF: u1 = 0,
/// BUSY [16:16]
/// BUSY
BUSY: u1 = 0,
/// CMF [17:17]
/// CMF
CMF: u1 = 0,
/// SBKF [18:18]
/// SBKF
SBKF: u1 = 0,
/// RWU [19:19]
/// RWU
RWU: u1 = 0,
/// WUF [20:20]
/// WUF
WUF: u1 = 0,
/// TEACK [21:21]
/// TEACK
TEACK: u1 = 0,
/// REACK [22:22]
/// REACK
REACK: u1 = 0,
/// unused [23:31]
_unused23: u1 = 0,
_unused24: u8 = 0,
};
/// Interrupt &amp; status
pub const ISR = Register(ISR_val).init(base_address + 0x1c);

/// ICR
const ICR_val = packed struct {
/// PECF [0:0]
/// Parity error clear flag
PECF: u1 = 0,
/// FECF [1:1]
/// Framing error clear flag
FECF: u1 = 0,
/// NCF [2:2]
/// Noise detected clear flag
NCF: u1 = 0,
/// ORECF [3:3]
/// Overrun error clear flag
ORECF: u1 = 0,
/// IDLECF [4:4]
/// Idle line detected clear
IDLECF: u1 = 0,
/// unused [5:5]
_unused5: u1 = 0,
/// TCCF [6:6]
/// Transmission complete clear
TCCF: u1 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// LBDCF [8:8]
/// LIN break detection clear
LBDCF: u1 = 0,
/// CTSCF [9:9]
/// CTS clear flag
CTSCF: u1 = 0,
/// unused [10:10]
_unused10: u1 = 0,
/// RTOCF [11:11]
/// Receiver timeout clear
RTOCF: u1 = 0,
/// EOBCF [12:12]
/// End of block clear flag
EOBCF: u1 = 0,
/// unused [13:16]
_unused13: u3 = 0,
_unused16: u1 = 0,
/// CMCF [17:17]
/// Character match clear flag
CMCF: u1 = 0,
/// unused [18:19]
_unused18: u2 = 0,
/// WUCF [20:20]
/// Wakeup from Stop mode clear
WUCF: u1 = 0,
/// unused [21:31]
_unused21: u3 = 0,
_unused24: u8 = 0,
};
/// Interrupt flag clear register
pub const ICR = Register(ICR_val).init(base_address + 0x20);

/// RDR
const RDR_val = packed struct {
/// RDR [0:8]
/// Receive data value
RDR: u9 = 0,
/// unused [9:31]
_unused9: u7 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Receive data register
pub const RDR = Register(RDR_val).init(base_address + 0x24);

/// TDR
const TDR_val = packed struct {
/// TDR [0:8]
/// Transmit data value
TDR: u9 = 0,
/// unused [9:31]
_unused9: u7 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Transmit data register
pub const TDR = Register(TDR_val).init(base_address + 0x28);
};

/// Universal synchronous asynchronous receiver
pub const USART5 = struct {

const base_address = 0x40005000;
/// CR1
const CR1_val = packed struct {
/// UE [0:0]
/// USART enable
UE: u1 = 0,
/// UESM [1:1]
/// USART enable in Stop mode
UESM: u1 = 0,
/// RE [2:2]
/// Receiver enable
RE: u1 = 0,
/// TE [3:3]
/// Transmitter enable
TE: u1 = 0,
/// IDLEIE [4:4]
/// IDLE interrupt enable
IDLEIE: u1 = 0,
/// RXNEIE [5:5]
/// RXNE interrupt enable
RXNEIE: u1 = 0,
/// TCIE [6:6]
/// Transmission complete interrupt
TCIE: u1 = 0,
/// TXEIE [7:7]
/// interrupt enable
TXEIE: u1 = 0,
/// PEIE [8:8]
/// PE interrupt enable
PEIE: u1 = 0,
/// PS [9:9]
/// Parity selection
PS: u1 = 0,
/// PCE [10:10]
/// Parity control enable
PCE: u1 = 0,
/// WAKE [11:11]
/// Receiver wakeup method
WAKE: u1 = 0,
/// M0 [12:12]
/// Word length
M0: u1 = 0,
/// MME [13:13]
/// Mute mode enable
MME: u1 = 0,
/// CMIE [14:14]
/// Character match interrupt
CMIE: u1 = 0,
/// OVER8 [15:15]
/// Oversampling mode
OVER8: u1 = 0,
/// DEDT0 [16:16]
/// DEDT0
DEDT0: u1 = 0,
/// DEDT1 [17:17]
/// DEDT1
DEDT1: u1 = 0,
/// DEDT2 [18:18]
/// DEDT2
DEDT2: u1 = 0,
/// DEDT3 [19:19]
/// DEDT3
DEDT3: u1 = 0,
/// DEDT4 [20:20]
/// Driver Enable de-assertion
DEDT4: u1 = 0,
/// DEAT0 [21:21]
/// DEAT0
DEAT0: u1 = 0,
/// DEAT1 [22:22]
/// DEAT1
DEAT1: u1 = 0,
/// DEAT2 [23:23]
/// DEAT2
DEAT2: u1 = 0,
/// DEAT3 [24:24]
/// DEAT3
DEAT3: u1 = 0,
/// DEAT4 [25:25]
/// Driver Enable assertion
DEAT4: u1 = 0,
/// RTOIE [26:26]
/// Receiver timeout interrupt
RTOIE: u1 = 0,
/// EOBIE [27:27]
/// End of Block interrupt
EOBIE: u1 = 0,
/// M1 [28:28]
/// Word length
M1: u1 = 0,
/// unused [29:31]
_unused29: u3 = 0,
};
/// Control register 1
pub const CR1 = Register(CR1_val).init(base_address + 0x0);

/// CR2
const CR2_val = packed struct {
/// unused [0:3]
_unused0: u4 = 0,
/// ADDM7 [4:4]
/// 7-bit Address Detection/4-bit Address
ADDM7: u1 = 0,
/// LBDL [5:5]
/// LIN break detection length
LBDL: u1 = 0,
/// LBDIE [6:6]
/// LIN break detection interrupt
LBDIE: u1 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// LBCL [8:8]
/// Last bit clock pulse
LBCL: u1 = 0,
/// CPHA [9:9]
/// Clock phase
CPHA: u1 = 0,
/// CPOL [10:10]
/// Clock polarity
CPOL: u1 = 0,
/// CLKEN [11:11]
/// Clock enable
CLKEN: u1 = 0,
/// STOP [12:13]
/// STOP bits
STOP: u2 = 0,
/// LINEN [14:14]
/// LIN mode enable
LINEN: u1 = 0,
/// SWAP [15:15]
/// Swap TX/RX pins
SWAP: u1 = 0,
/// RXINV [16:16]
/// RX pin active level
RXINV: u1 = 0,
/// TXINV [17:17]
/// TX pin active level
TXINV: u1 = 0,
/// TAINV [18:18]
/// Binary data inversion
TAINV: u1 = 0,
/// MSBFIRST [19:19]
/// Most significant bit first
MSBFIRST: u1 = 0,
/// ABREN [20:20]
/// Auto baud rate enable
ABREN: u1 = 0,
/// ABRMOD0 [21:21]
/// ABRMOD0
ABRMOD0: u1 = 0,
/// ABRMOD1 [22:22]
/// Auto baud rate mode
ABRMOD1: u1 = 0,
/// RTOEN [23:23]
/// Receiver timeout enable
RTOEN: u1 = 0,
/// ADD0_3 [24:27]
/// Address of the USART node
ADD0_3: u4 = 0,
/// ADD4_7 [28:31]
/// Address of the USART node
ADD4_7: u4 = 0,
};
/// Control register 2
pub const CR2 = Register(CR2_val).init(base_address + 0x4);

/// CR3
const CR3_val = packed struct {
/// EIE [0:0]
/// Error interrupt enable
EIE: u1 = 0,
/// IREN [1:1]
/// Ir mode enable
IREN: u1 = 0,
/// IRLP [2:2]
/// Ir low-power
IRLP: u1 = 0,
/// HDSEL [3:3]
/// Half-duplex selection
HDSEL: u1 = 0,
/// NACK [4:4]
/// Smartcard NACK enable
NACK: u1 = 0,
/// SCEN [5:5]
/// Smartcard mode enable
SCEN: u1 = 0,
/// DMAR [6:6]
/// DMA enable receiver
DMAR: u1 = 0,
/// DMAT [7:7]
/// DMA enable transmitter
DMAT: u1 = 0,
/// RTSE [8:8]
/// RTS enable
RTSE: u1 = 0,
/// CTSE [9:9]
/// CTS enable
CTSE: u1 = 0,
/// CTSIE [10:10]
/// CTS interrupt enable
CTSIE: u1 = 0,
/// ONEBIT [11:11]
/// One sample bit method
ONEBIT: u1 = 0,
/// OVRDIS [12:12]
/// Overrun Disable
OVRDIS: u1 = 0,
/// DDRE [13:13]
/// DMA Disable on Reception
DDRE: u1 = 0,
/// DEM [14:14]
/// Driver enable mode
DEM: u1 = 0,
/// DEP [15:15]
/// Driver enable polarity
DEP: u1 = 0,
/// unused [16:16]
_unused16: u1 = 0,
/// SCARCNT [17:19]
/// Smartcard auto-retry count
SCARCNT: u3 = 0,
/// WUS [20:21]
/// Wakeup from Stop mode interrupt flag
WUS: u2 = 0,
/// WUFIE [22:22]
/// Wakeup from Stop mode interrupt
WUFIE: u1 = 0,
/// unused [23:31]
_unused23: u1 = 0,
_unused24: u8 = 0,
};
/// Control register 3
pub const CR3 = Register(CR3_val).init(base_address + 0x8);

/// BRR
const BRR_val = packed struct {
/// DIV_Fraction [0:3]
/// DIV_Fraction
DIV_Fraction: u4 = 0,
/// DIV_Mantissa [4:15]
/// DIV_Mantissa
DIV_Mantissa: u12 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Baud rate register
pub const BRR = Register(BRR_val).init(base_address + 0xc);

/// GTPR
const GTPR_val = packed struct {
/// PSC [0:7]
/// Prescaler value
PSC: u8 = 0,
/// GT [8:15]
/// Guard time value
GT: u8 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Guard time and prescaler
pub const GTPR = Register(GTPR_val).init(base_address + 0x10);

/// RTOR
const RTOR_val = packed struct {
/// RTO [0:23]
/// Receiver timeout value
RTO: u24 = 0,
/// BLEN [24:31]
/// Block Length
BLEN: u8 = 0,
};
/// Receiver timeout register
pub const RTOR = Register(RTOR_val).init(base_address + 0x14);

/// RQR
const RQR_val = packed struct {
/// ABRRQ [0:0]
/// Auto baud rate request
ABRRQ: u1 = 0,
/// SBKRQ [1:1]
/// Send break request
SBKRQ: u1 = 0,
/// MMRQ [2:2]
/// Mute mode request
MMRQ: u1 = 0,
/// RXFRQ [3:3]
/// Receive data flush request
RXFRQ: u1 = 0,
/// TXFRQ [4:4]
/// Transmit data flush
TXFRQ: u1 = 0,
/// unused [5:31]
_unused5: u3 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Request register
pub const RQR = Register(RQR_val).init(base_address + 0x18);

/// ISR
const ISR_val = packed struct {
/// PE [0:0]
/// PE
PE: u1 = 0,
/// FE [1:1]
/// FE
FE: u1 = 0,
/// NF [2:2]
/// NF
NF: u1 = 0,
/// ORE [3:3]
/// ORE
ORE: u1 = 0,
/// IDLE [4:4]
/// IDLE
IDLE: u1 = 0,
/// RXNE [5:5]
/// RXNE
RXNE: u1 = 0,
/// TC [6:6]
/// TC
TC: u1 = 1,
/// TXE [7:7]
/// TXE
TXE: u1 = 1,
/// LBDF [8:8]
/// LBDF
LBDF: u1 = 0,
/// CTSIF [9:9]
/// CTSIF
CTSIF: u1 = 0,
/// CTS [10:10]
/// CTS
CTS: u1 = 0,
/// RTOF [11:11]
/// RTOF
RTOF: u1 = 0,
/// EOBF [12:12]
/// EOBF
EOBF: u1 = 0,
/// unused [13:13]
_unused13: u1 = 0,
/// ABRE [14:14]
/// ABRE
ABRE: u1 = 0,
/// ABRF [15:15]
/// ABRF
ABRF: u1 = 0,
/// BUSY [16:16]
/// BUSY
BUSY: u1 = 0,
/// CMF [17:17]
/// CMF
CMF: u1 = 0,
/// SBKF [18:18]
/// SBKF
SBKF: u1 = 0,
/// RWU [19:19]
/// RWU
RWU: u1 = 0,
/// WUF [20:20]
/// WUF
WUF: u1 = 0,
/// TEACK [21:21]
/// TEACK
TEACK: u1 = 0,
/// REACK [22:22]
/// REACK
REACK: u1 = 0,
/// unused [23:31]
_unused23: u1 = 0,
_unused24: u8 = 0,
};
/// Interrupt &amp; status
pub const ISR = Register(ISR_val).init(base_address + 0x1c);

/// ICR
const ICR_val = packed struct {
/// PECF [0:0]
/// Parity error clear flag
PECF: u1 = 0,
/// FECF [1:1]
/// Framing error clear flag
FECF: u1 = 0,
/// NCF [2:2]
/// Noise detected clear flag
NCF: u1 = 0,
/// ORECF [3:3]
/// Overrun error clear flag
ORECF: u1 = 0,
/// IDLECF [4:4]
/// Idle line detected clear
IDLECF: u1 = 0,
/// unused [5:5]
_unused5: u1 = 0,
/// TCCF [6:6]
/// Transmission complete clear
TCCF: u1 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// LBDCF [8:8]
/// LIN break detection clear
LBDCF: u1 = 0,
/// CTSCF [9:9]
/// CTS clear flag
CTSCF: u1 = 0,
/// unused [10:10]
_unused10: u1 = 0,
/// RTOCF [11:11]
/// Receiver timeout clear
RTOCF: u1 = 0,
/// EOBCF [12:12]
/// End of block clear flag
EOBCF: u1 = 0,
/// unused [13:16]
_unused13: u3 = 0,
_unused16: u1 = 0,
/// CMCF [17:17]
/// Character match clear flag
CMCF: u1 = 0,
/// unused [18:19]
_unused18: u2 = 0,
/// WUCF [20:20]
/// Wakeup from Stop mode clear
WUCF: u1 = 0,
/// unused [21:31]
_unused21: u3 = 0,
_unused24: u8 = 0,
};
/// Interrupt flag clear register
pub const ICR = Register(ICR_val).init(base_address + 0x20);

/// RDR
const RDR_val = packed struct {
/// RDR [0:8]
/// Receive data value
RDR: u9 = 0,
/// unused [9:31]
_unused9: u7 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Receive data register
pub const RDR = Register(RDR_val).init(base_address + 0x24);

/// TDR
const TDR_val = packed struct {
/// TDR [0:8]
/// Transmit data value
TDR: u9 = 0,
/// unused [9:31]
_unused9: u7 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Transmit data register
pub const TDR = Register(TDR_val).init(base_address + 0x28);
};

/// Touch sensing controller
pub const TSC = struct {

const base_address = 0x40024000;
/// CR
const CR_val = packed struct {
/// TSCE [0:0]
/// Touch sensing controller
TSCE: u1 = 0,
/// START [1:1]
/// Start a new acquisition
START: u1 = 0,
/// AM [2:2]
/// Acquisition mode
AM: u1 = 0,
/// SYNCPOL [3:3]
/// Synchronization pin
SYNCPOL: u1 = 0,
/// IODEF [4:4]
/// I/O Default mode
IODEF: u1 = 0,
/// MCV [5:7]
/// Max count value
MCV: u3 = 0,
/// unused [8:11]
_unused8: u4 = 0,
/// PGPSC [12:14]
/// pulse generator prescaler
PGPSC: u3 = 0,
/// SSPSC [15:15]
/// Spread spectrum prescaler
SSPSC: u1 = 0,
/// SSE [16:16]
/// Spread spectrum enable
SSE: u1 = 0,
/// SSD [17:23]
/// Spread spectrum deviation
SSD: u7 = 0,
/// CTPL [24:27]
/// Charge transfer pulse low
CTPL: u4 = 0,
/// CTPH [28:31]
/// Charge transfer pulse high
CTPH: u4 = 0,
};
/// control register
pub const CR = Register(CR_val).init(base_address + 0x0);

/// IER
const IER_val = packed struct {
/// EOAIE [0:0]
/// End of acquisition interrupt
EOAIE: u1 = 0,
/// MCEIE [1:1]
/// Max count error interrupt
MCEIE: u1 = 0,
/// unused [2:31]
_unused2: u6 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// interrupt enable register
pub const IER = Register(IER_val).init(base_address + 0x4);

/// ICR
const ICR_val = packed struct {
/// EOAIC [0:0]
/// End of acquisition interrupt
EOAIC: u1 = 0,
/// MCEIC [1:1]
/// Max count error interrupt
MCEIC: u1 = 0,
/// unused [2:31]
_unused2: u6 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// interrupt clear register
pub const ICR = Register(ICR_val).init(base_address + 0x8);

/// ISR
const ISR_val = packed struct {
/// EOAF [0:0]
/// End of acquisition flag
EOAF: u1 = 0,
/// MCEF [1:1]
/// Max count error flag
MCEF: u1 = 0,
/// unused [2:31]
_unused2: u6 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// interrupt status register
pub const ISR = Register(ISR_val).init(base_address + 0xc);

/// IOHCR
const IOHCR_val = packed struct {
/// G1_IO1 [0:0]
/// G1_IO1
G1_IO1: u1 = 1,
/// G1_IO2 [1:1]
/// G1_IO2
G1_IO2: u1 = 1,
/// G1_IO3 [2:2]
/// G1_IO3
G1_IO3: u1 = 1,
/// G1_IO4 [3:3]
/// G1_IO4
G1_IO4: u1 = 1,
/// G2_IO1 [4:4]
/// G2_IO1
G2_IO1: u1 = 1,
/// G2_IO2 [5:5]
/// G2_IO2
G2_IO2: u1 = 1,
/// G2_IO3 [6:6]
/// G2_IO3
G2_IO3: u1 = 1,
/// G2_IO4 [7:7]
/// G2_IO4
G2_IO4: u1 = 1,
/// G3_IO1 [8:8]
/// G3_IO1
G3_IO1: u1 = 1,
/// G3_IO2 [9:9]
/// G3_IO2
G3_IO2: u1 = 1,
/// G3_IO3 [10:10]
/// G3_IO3
G3_IO3: u1 = 1,
/// G3_IO4 [11:11]
/// G3_IO4
G3_IO4: u1 = 1,
/// G4_IO1 [12:12]
/// G4_IO1
G4_IO1: u1 = 1,
/// G4_IO2 [13:13]
/// G4_IO2
G4_IO2: u1 = 1,
/// G4_IO3 [14:14]
/// G4_IO3
G4_IO3: u1 = 1,
/// G4_IO4 [15:15]
/// G4_IO4
G4_IO4: u1 = 1,
/// G5_IO1 [16:16]
/// G5_IO1
G5_IO1: u1 = 1,
/// G5_IO2 [17:17]
/// G5_IO2
G5_IO2: u1 = 1,
/// G5_IO3 [18:18]
/// G5_IO3
G5_IO3: u1 = 1,
/// G5_IO4 [19:19]
/// G5_IO4
G5_IO4: u1 = 1,
/// G6_IO1 [20:20]
/// G6_IO1
G6_IO1: u1 = 1,
/// G6_IO2 [21:21]
/// G6_IO2
G6_IO2: u1 = 1,
/// G6_IO3 [22:22]
/// G6_IO3
G6_IO3: u1 = 1,
/// G6_IO4 [23:23]
/// G6_IO4
G6_IO4: u1 = 1,
/// G7_IO1 [24:24]
/// G7_IO1
G7_IO1: u1 = 1,
/// G7_IO2 [25:25]
/// G7_IO2
G7_IO2: u1 = 1,
/// G7_IO3 [26:26]
/// G7_IO3
G7_IO3: u1 = 1,
/// G7_IO4 [27:27]
/// G7_IO4
G7_IO4: u1 = 1,
/// G8_IO1 [28:28]
/// G8_IO1
G8_IO1: u1 = 1,
/// G8_IO2 [29:29]
/// G8_IO2
G8_IO2: u1 = 1,
/// G8_IO3 [30:30]
/// G8_IO3
G8_IO3: u1 = 1,
/// G8_IO4 [31:31]
/// G8_IO4
G8_IO4: u1 = 1,
};
/// I/O hysteresis control
pub const IOHCR = Register(IOHCR_val).init(base_address + 0x10);

/// IOASCR
const IOASCR_val = packed struct {
/// G1_IO1 [0:0]
/// G1_IO1
G1_IO1: u1 = 0,
/// G1_IO2 [1:1]
/// G1_IO2
G1_IO2: u1 = 0,
/// G1_IO3 [2:2]
/// G1_IO3
G1_IO3: u1 = 0,
/// G1_IO4 [3:3]
/// G1_IO4
G1_IO4: u1 = 0,
/// G2_IO1 [4:4]
/// G2_IO1
G2_IO1: u1 = 0,
/// G2_IO2 [5:5]
/// G2_IO2
G2_IO2: u1 = 0,
/// G2_IO3 [6:6]
/// G2_IO3
G2_IO3: u1 = 0,
/// G2_IO4 [7:7]
/// G2_IO4
G2_IO4: u1 = 0,
/// G3_IO1 [8:8]
/// G3_IO1
G3_IO1: u1 = 0,
/// G3_IO2 [9:9]
/// G3_IO2
G3_IO2: u1 = 0,
/// G3_IO3 [10:10]
/// G3_IO3
G3_IO3: u1 = 0,
/// G3_IO4 [11:11]
/// G3_IO4
G3_IO4: u1 = 0,
/// G4_IO1 [12:12]
/// G4_IO1
G4_IO1: u1 = 0,
/// G4_IO2 [13:13]
/// G4_IO2
G4_IO2: u1 = 0,
/// G4_IO3 [14:14]
/// G4_IO3
G4_IO3: u1 = 0,
/// G4_IO4 [15:15]
/// G4_IO4
G4_IO4: u1 = 0,
/// G5_IO1 [16:16]
/// G5_IO1
G5_IO1: u1 = 0,
/// G5_IO2 [17:17]
/// G5_IO2
G5_IO2: u1 = 0,
/// G5_IO3 [18:18]
/// G5_IO3
G5_IO3: u1 = 0,
/// G5_IO4 [19:19]
/// G5_IO4
G5_IO4: u1 = 0,
/// G6_IO1 [20:20]
/// G6_IO1
G6_IO1: u1 = 0,
/// G6_IO2 [21:21]
/// G6_IO2
G6_IO2: u1 = 0,
/// G6_IO3 [22:22]
/// G6_IO3
G6_IO3: u1 = 0,
/// G6_IO4 [23:23]
/// G6_IO4
G6_IO4: u1 = 0,
/// G7_IO1 [24:24]
/// G7_IO1
G7_IO1: u1 = 0,
/// G7_IO2 [25:25]
/// G7_IO2
G7_IO2: u1 = 0,
/// G7_IO3 [26:26]
/// G7_IO3
G7_IO3: u1 = 0,
/// G7_IO4 [27:27]
/// G7_IO4
G7_IO4: u1 = 0,
/// G8_IO1 [28:28]
/// G8_IO1
G8_IO1: u1 = 0,
/// G8_IO2 [29:29]
/// G8_IO2
G8_IO2: u1 = 0,
/// G8_IO3 [30:30]
/// G8_IO3
G8_IO3: u1 = 0,
/// G8_IO4 [31:31]
/// G8_IO4
G8_IO4: u1 = 0,
};
/// I/O analog switch control
pub const IOASCR = Register(IOASCR_val).init(base_address + 0x18);

/// IOSCR
const IOSCR_val = packed struct {
/// G1_IO1 [0:0]
/// G1_IO1
G1_IO1: u1 = 0,
/// G1_IO2 [1:1]
/// G1_IO2
G1_IO2: u1 = 0,
/// G1_IO3 [2:2]
/// G1_IO3
G1_IO3: u1 = 0,
/// G1_IO4 [3:3]
/// G1_IO4
G1_IO4: u1 = 0,
/// G2_IO1 [4:4]
/// G2_IO1
G2_IO1: u1 = 0,
/// G2_IO2 [5:5]
/// G2_IO2
G2_IO2: u1 = 0,
/// G2_IO3 [6:6]
/// G2_IO3
G2_IO3: u1 = 0,
/// G2_IO4 [7:7]
/// G2_IO4
G2_IO4: u1 = 0,
/// G3_IO1 [8:8]
/// G3_IO1
G3_IO1: u1 = 0,
/// G3_IO2 [9:9]
/// G3_IO2
G3_IO2: u1 = 0,
/// G3_IO3 [10:10]
/// G3_IO3
G3_IO3: u1 = 0,
/// G3_IO4 [11:11]
/// G3_IO4
G3_IO4: u1 = 0,
/// G4_IO1 [12:12]
/// G4_IO1
G4_IO1: u1 = 0,
/// G4_IO2 [13:13]
/// G4_IO2
G4_IO2: u1 = 0,
/// G4_IO3 [14:14]
/// G4_IO3
G4_IO3: u1 = 0,
/// G4_IO4 [15:15]
/// G4_IO4
G4_IO4: u1 = 0,
/// G5_IO1 [16:16]
/// G5_IO1
G5_IO1: u1 = 0,
/// G5_IO2 [17:17]
/// G5_IO2
G5_IO2: u1 = 0,
/// G5_IO3 [18:18]
/// G5_IO3
G5_IO3: u1 = 0,
/// G5_IO4 [19:19]
/// G5_IO4
G5_IO4: u1 = 0,
/// G6_IO1 [20:20]
/// G6_IO1
G6_IO1: u1 = 0,
/// G6_IO2 [21:21]
/// G6_IO2
G6_IO2: u1 = 0,
/// G6_IO3 [22:22]
/// G6_IO3
G6_IO3: u1 = 0,
/// G6_IO4 [23:23]
/// G6_IO4
G6_IO4: u1 = 0,
/// G7_IO1 [24:24]
/// G7_IO1
G7_IO1: u1 = 0,
/// G7_IO2 [25:25]
/// G7_IO2
G7_IO2: u1 = 0,
/// G7_IO3 [26:26]
/// G7_IO3
G7_IO3: u1 = 0,
/// G7_IO4 [27:27]
/// G7_IO4
G7_IO4: u1 = 0,
/// G8_IO1 [28:28]
/// G8_IO1
G8_IO1: u1 = 0,
/// G8_IO2 [29:29]
/// G8_IO2
G8_IO2: u1 = 0,
/// G8_IO3 [30:30]
/// G8_IO3
G8_IO3: u1 = 0,
/// G8_IO4 [31:31]
/// G8_IO4
G8_IO4: u1 = 0,
};
/// I/O sampling control register
pub const IOSCR = Register(IOSCR_val).init(base_address + 0x20);

/// IOCCR
const IOCCR_val = packed struct {
/// G1_IO1 [0:0]
/// G1_IO1
G1_IO1: u1 = 0,
/// G1_IO2 [1:1]
/// G1_IO2
G1_IO2: u1 = 0,
/// G1_IO3 [2:2]
/// G1_IO3
G1_IO3: u1 = 0,
/// G1_IO4 [3:3]
/// G1_IO4
G1_IO4: u1 = 0,
/// G2_IO1 [4:4]
/// G2_IO1
G2_IO1: u1 = 0,
/// G2_IO2 [5:5]
/// G2_IO2
G2_IO2: u1 = 0,
/// G2_IO3 [6:6]
/// G2_IO3
G2_IO3: u1 = 0,
/// G2_IO4 [7:7]
/// G2_IO4
G2_IO4: u1 = 0,
/// G3_IO1 [8:8]
/// G3_IO1
G3_IO1: u1 = 0,
/// G3_IO2 [9:9]
/// G3_IO2
G3_IO2: u1 = 0,
/// G3_IO3 [10:10]
/// G3_IO3
G3_IO3: u1 = 0,
/// G3_IO4 [11:11]
/// G3_IO4
G3_IO4: u1 = 0,
/// G4_IO1 [12:12]
/// G4_IO1
G4_IO1: u1 = 0,
/// G4_IO2 [13:13]
/// G4_IO2
G4_IO2: u1 = 0,
/// G4_IO3 [14:14]
/// G4_IO3
G4_IO3: u1 = 0,
/// G4_IO4 [15:15]
/// G4_IO4
G4_IO4: u1 = 0,
/// G5_IO1 [16:16]
/// G5_IO1
G5_IO1: u1 = 0,
/// G5_IO2 [17:17]
/// G5_IO2
G5_IO2: u1 = 0,
/// G5_IO3 [18:18]
/// G5_IO3
G5_IO3: u1 = 0,
/// G5_IO4 [19:19]
/// G5_IO4
G5_IO4: u1 = 0,
/// G6_IO1 [20:20]
/// G6_IO1
G6_IO1: u1 = 0,
/// G6_IO2 [21:21]
/// G6_IO2
G6_IO2: u1 = 0,
/// G6_IO3 [22:22]
/// G6_IO3
G6_IO3: u1 = 0,
/// G6_IO4 [23:23]
/// G6_IO4
G6_IO4: u1 = 0,
/// G7_IO1 [24:24]
/// G7_IO1
G7_IO1: u1 = 0,
/// G7_IO2 [25:25]
/// G7_IO2
G7_IO2: u1 = 0,
/// G7_IO3 [26:26]
/// G7_IO3
G7_IO3: u1 = 0,
/// G7_IO4 [27:27]
/// G7_IO4
G7_IO4: u1 = 0,
/// G8_IO1 [28:28]
/// G8_IO1
G8_IO1: u1 = 0,
/// G8_IO2 [29:29]
/// G8_IO2
G8_IO2: u1 = 0,
/// G8_IO3 [30:30]
/// G8_IO3
G8_IO3: u1 = 0,
/// G8_IO4 [31:31]
/// G8_IO4
G8_IO4: u1 = 0,
};
/// I/O channel control register
pub const IOCCR = Register(IOCCR_val).init(base_address + 0x28);

/// IOGCSR
const IOGCSR_val = packed struct {
/// G1E [0:0]
/// Analog I/O group x enable
G1E: u1 = 0,
/// G2E [1:1]
/// Analog I/O group x enable
G2E: u1 = 0,
/// G3E [2:2]
/// Analog I/O group x enable
G3E: u1 = 0,
/// G4E [3:3]
/// Analog I/O group x enable
G4E: u1 = 0,
/// G5E [4:4]
/// Analog I/O group x enable
G5E: u1 = 0,
/// G6E [5:5]
/// Analog I/O group x enable
G6E: u1 = 0,
/// G7E [6:6]
/// Analog I/O group x enable
G7E: u1 = 0,
/// G8E [7:7]
/// Analog I/O group x enable
G8E: u1 = 0,
/// unused [8:15]
_unused8: u8 = 0,
/// G1S [16:16]
/// Analog I/O group x status
G1S: u1 = 0,
/// G2S [17:17]
/// Analog I/O group x status
G2S: u1 = 0,
/// G3S [18:18]
/// Analog I/O group x status
G3S: u1 = 0,
/// G4S [19:19]
/// Analog I/O group x status
G4S: u1 = 0,
/// G5S [20:20]
/// Analog I/O group x status
G5S: u1 = 0,
/// G6S [21:21]
/// Analog I/O group x status
G6S: u1 = 0,
/// G7S [22:22]
/// Analog I/O group x status
G7S: u1 = 0,
/// G8S [23:23]
/// Analog I/O group x status
G8S: u1 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// I/O group control status
pub const IOGCSR = Register(IOGCSR_val).init(base_address + 0x30);

/// IOG1CR
const IOG1CR_val = packed struct {
/// CNT [0:13]
/// Counter value
CNT: u14 = 0,
/// unused [14:31]
_unused14: u2 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// I/O group x counter register
pub const IOG1CR = Register(IOG1CR_val).init(base_address + 0x34);

/// IOG2CR
const IOG2CR_val = packed struct {
/// CNT [0:13]
/// Counter value
CNT: u14 = 0,
/// unused [14:31]
_unused14: u2 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// I/O group x counter register
pub const IOG2CR = Register(IOG2CR_val).init(base_address + 0x38);

/// IOG3CR
const IOG3CR_val = packed struct {
/// CNT [0:13]
/// Counter value
CNT: u14 = 0,
/// unused [14:31]
_unused14: u2 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// I/O group x counter register
pub const IOG3CR = Register(IOG3CR_val).init(base_address + 0x3c);

/// IOG4CR
const IOG4CR_val = packed struct {
/// CNT [0:13]
/// Counter value
CNT: u14 = 0,
/// unused [14:31]
_unused14: u2 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// I/O group x counter register
pub const IOG4CR = Register(IOG4CR_val).init(base_address + 0x40);

/// IOG5CR
const IOG5CR_val = packed struct {
/// CNT [0:13]
/// Counter value
CNT: u14 = 0,
/// unused [14:31]
_unused14: u2 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// I/O group x counter register
pub const IOG5CR = Register(IOG5CR_val).init(base_address + 0x44);

/// IOG6CR
const IOG6CR_val = packed struct {
/// CNT [0:13]
/// Counter value
CNT: u14 = 0,
/// unused [14:31]
_unused14: u2 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// I/O group x counter register
pub const IOG6CR = Register(IOG6CR_val).init(base_address + 0x48);

/// IOG7CR
const IOG7CR_val = packed struct {
/// CNT [0:13]
/// Counter value
CNT: u14 = 0,
/// unused [14:31]
_unused14: u2 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// I/O group x counter register
pub const IOG7CR = Register(IOG7CR_val).init(base_address + 0x4c);

/// IOG8CR
const IOG8CR_val = packed struct {
/// CNT [0:13]
/// Counter value
CNT: u14 = 0,
/// unused [14:31]
_unused14: u2 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// I/O group x counter register
pub const IOG8CR = Register(IOG8CR_val).init(base_address + 0x50);
};

/// Independent watchdog
pub const IWDG = struct {

const base_address = 0x40003000;
/// KR
const KR_val = packed struct {
/// KEY [0:15]
/// Key value (write only, read
KEY: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Key register
pub const KR = Register(KR_val).init(base_address + 0x0);

/// PR
const PR_val = packed struct {
/// PR [0:2]
/// Prescaler divider
PR: u3 = 0,
/// unused [3:31]
_unused3: u5 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Prescaler register
pub const PR = Register(PR_val).init(base_address + 0x4);

/// RLR
const RLR_val = packed struct {
/// RL [0:11]
/// Watchdog counter reload
RL: u12 = 4095,
/// unused [12:31]
_unused12: u4 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Reload register
pub const RLR = Register(RLR_val).init(base_address + 0x8);

/// SR
const SR_val = packed struct {
/// PVU [0:0]
/// Watchdog prescaler value
PVU: u1 = 0,
/// RVU [1:1]
/// Watchdog counter reload value
RVU: u1 = 0,
/// WVU [2:2]
/// Watchdog counter window value
WVU: u1 = 0,
/// unused [3:31]
_unused3: u5 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Status register
pub const SR = Register(SR_val).init(base_address + 0xc);

/// WINR
const WINR_val = packed struct {
/// WIN [0:11]
/// Watchdog counter window
WIN: u12 = 4095,
/// unused [12:31]
_unused12: u4 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Window register
pub const WINR = Register(WINR_val).init(base_address + 0x10);
};

/// System window watchdog
pub const WWDG = struct {

const base_address = 0x40002c00;
/// CR
const CR_val = packed struct {
/// T [0:6]
/// 7-bit counter (MSB to LSB)
T: u7 = 127,
/// WDGA [7:7]
/// Activation bit
WDGA: u1 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Control register
pub const CR = Register(CR_val).init(base_address + 0x0);

/// CFR
const CFR_val = packed struct {
/// W [0:6]
/// 7-bit window value
W: u7 = 127,
/// WDGTB0 [7:7]
/// WDGTB0
WDGTB0: u1 = 0,
/// WDGTB1 [8:8]
/// Timer base
WDGTB1: u1 = 0,
/// EWI [9:9]
/// Early wakeup interrupt
EWI: u1 = 0,
/// unused [10:31]
_unused10: u6 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Configuration register
pub const CFR = Register(CFR_val).init(base_address + 0x4);

/// SR
const SR_val = packed struct {
/// EWIF [0:0]
/// Early wakeup interrupt
EWIF: u1 = 0,
/// unused [1:31]
_unused1: u7 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Status register
pub const SR = Register(SR_val).init(base_address + 0x8);
};

/// Universal serial bus full-speed device
pub const USB_FS = struct {

const base_address = 0x40005c00;
/// EP0R
const EP0R_val = packed struct {
/// EA [0:3]
/// EA
EA: u4 = 0,
/// STAT_TX [4:5]
/// STAT_TX
STAT_TX: u2 = 0,
/// DTOG_TX [6:6]
/// DTOG_TX
DTOG_TX: u1 = 0,
/// CTR_TX [7:7]
/// CTR_TX
CTR_TX: u1 = 0,
/// EP_KIND [8:8]
/// EP_KIND
EP_KIND: u1 = 0,
/// EPTYPE [9:10]
/// EPTYPE
EPTYPE: u2 = 0,
/// SETUP [11:11]
/// SETUP
SETUP: u1 = 0,
/// STAT_RX [12:13]
/// STAT_RX
STAT_RX: u2 = 0,
/// DTOG_RX [14:14]
/// DTOG_RX
DTOG_RX: u1 = 0,
/// CTR_RX [15:15]
/// CTR_RX
CTR_RX: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// endpoint register
pub const EP0R = Register(EP0R_val).init(base_address + 0x0);

/// EP1R
const EP1R_val = packed struct {
/// EA [0:3]
/// EA
EA: u4 = 0,
/// STAT_TX [4:5]
/// STAT_TX
STAT_TX: u2 = 0,
/// DTOG_TX [6:6]
/// DTOG_TX
DTOG_TX: u1 = 0,
/// CTR_TX [7:7]
/// CTR_TX
CTR_TX: u1 = 0,
/// EP_KIND [8:8]
/// EP_KIND
EP_KIND: u1 = 0,
/// EPTYPE [9:10]
/// EPTYPE
EPTYPE: u2 = 0,
/// SETUP [11:11]
/// SETUP
SETUP: u1 = 0,
/// STAT_RX [12:13]
/// STAT_RX
STAT_RX: u2 = 0,
/// DTOG_RX [14:14]
/// DTOG_RX
DTOG_RX: u1 = 0,
/// CTR_RX [15:15]
/// CTR_RX
CTR_RX: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// endpoint register
pub const EP1R = Register(EP1R_val).init(base_address + 0x4);

/// EP2R
const EP2R_val = packed struct {
/// EA [0:3]
/// EA
EA: u4 = 0,
/// STAT_TX [4:5]
/// STAT_TX
STAT_TX: u2 = 0,
/// DTOG_TX [6:6]
/// DTOG_TX
DTOG_TX: u1 = 0,
/// CTR_TX [7:7]
/// CTR_TX
CTR_TX: u1 = 0,
/// EP_KIND [8:8]
/// EP_KIND
EP_KIND: u1 = 0,
/// EPTYPE [9:10]
/// EPTYPE
EPTYPE: u2 = 0,
/// SETUP [11:11]
/// SETUP
SETUP: u1 = 0,
/// STAT_RX [12:13]
/// STAT_RX
STAT_RX: u2 = 0,
/// DTOG_RX [14:14]
/// DTOG_RX
DTOG_RX: u1 = 0,
/// CTR_RX [15:15]
/// CTR_RX
CTR_RX: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// endpoint register
pub const EP2R = Register(EP2R_val).init(base_address + 0x8);

/// EP3R
const EP3R_val = packed struct {
/// EA [0:3]
/// EA
EA: u4 = 0,
/// STAT_TX [4:5]
/// STAT_TX
STAT_TX: u2 = 0,
/// DTOG_TX [6:6]
/// DTOG_TX
DTOG_TX: u1 = 0,
/// CTR_TX [7:7]
/// CTR_TX
CTR_TX: u1 = 0,
/// EP_KIND [8:8]
/// EP_KIND
EP_KIND: u1 = 0,
/// EPTYPE [9:10]
/// EPTYPE
EPTYPE: u2 = 0,
/// SETUP [11:11]
/// SETUP
SETUP: u1 = 0,
/// STAT_RX [12:13]
/// STAT_RX
STAT_RX: u2 = 0,
/// DTOG_RX [14:14]
/// DTOG_RX
DTOG_RX: u1 = 0,
/// CTR_RX [15:15]
/// CTR_RX
CTR_RX: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// endpoint register
pub const EP3R = Register(EP3R_val).init(base_address + 0xc);

/// EP4R
const EP4R_val = packed struct {
/// EA [0:3]
/// EA
EA: u4 = 0,
/// STAT_TX [4:5]
/// STAT_TX
STAT_TX: u2 = 0,
/// DTOG_TX [6:6]
/// DTOG_TX
DTOG_TX: u1 = 0,
/// CTR_TX [7:7]
/// CTR_TX
CTR_TX: u1 = 0,
/// EP_KIND [8:8]
/// EP_KIND
EP_KIND: u1 = 0,
/// EPTYPE [9:10]
/// EPTYPE
EPTYPE: u2 = 0,
/// SETUP [11:11]
/// SETUP
SETUP: u1 = 0,
/// STAT_RX [12:13]
/// STAT_RX
STAT_RX: u2 = 0,
/// DTOG_RX [14:14]
/// DTOG_RX
DTOG_RX: u1 = 0,
/// CTR_RX [15:15]
/// CTR_RX
CTR_RX: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// endpoint register
pub const EP4R = Register(EP4R_val).init(base_address + 0x10);

/// EP5R
const EP5R_val = packed struct {
/// EA [0:3]
/// EA
EA: u4 = 0,
/// STAT_TX [4:5]
/// STAT_TX
STAT_TX: u2 = 0,
/// DTOG_TX [6:6]
/// DTOG_TX
DTOG_TX: u1 = 0,
/// CTR_TX [7:7]
/// CTR_TX
CTR_TX: u1 = 0,
/// EP_KIND [8:8]
/// EP_KIND
EP_KIND: u1 = 0,
/// EPTYPE [9:10]
/// EPTYPE
EPTYPE: u2 = 0,
/// SETUP [11:11]
/// SETUP
SETUP: u1 = 0,
/// STAT_RX [12:13]
/// STAT_RX
STAT_RX: u2 = 0,
/// DTOG_RX [14:14]
/// DTOG_RX
DTOG_RX: u1 = 0,
/// CTR_RX [15:15]
/// CTR_RX
CTR_RX: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// endpoint register
pub const EP5R = Register(EP5R_val).init(base_address + 0x14);

/// EP6R
const EP6R_val = packed struct {
/// EA [0:3]
/// EA
EA: u4 = 0,
/// STAT_TX [4:5]
/// STAT_TX
STAT_TX: u2 = 0,
/// DTOG_TX [6:6]
/// DTOG_TX
DTOG_TX: u1 = 0,
/// CTR_TX [7:7]
/// CTR_TX
CTR_TX: u1 = 0,
/// EP_KIND [8:8]
/// EP_KIND
EP_KIND: u1 = 0,
/// EPTYPE [9:10]
/// EPTYPE
EPTYPE: u2 = 0,
/// SETUP [11:11]
/// SETUP
SETUP: u1 = 0,
/// STAT_RX [12:13]
/// STAT_RX
STAT_RX: u2 = 0,
/// DTOG_RX [14:14]
/// DTOG_RX
DTOG_RX: u1 = 0,
/// CTR_RX [15:15]
/// CTR_RX
CTR_RX: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// endpoint register
pub const EP6R = Register(EP6R_val).init(base_address + 0x18);

/// EP7R
const EP7R_val = packed struct {
/// EA [0:3]
/// EA
EA: u4 = 0,
/// STAT_TX [4:5]
/// STAT_TX
STAT_TX: u2 = 0,
/// DTOG_TX [6:6]
/// DTOG_TX
DTOG_TX: u1 = 0,
/// CTR_TX [7:7]
/// CTR_TX
CTR_TX: u1 = 0,
/// EP_KIND [8:8]
/// EP_KIND
EP_KIND: u1 = 0,
/// EPTYPE [9:10]
/// EPTYPE
EPTYPE: u2 = 0,
/// SETUP [11:11]
/// SETUP
SETUP: u1 = 0,
/// STAT_RX [12:13]
/// STAT_RX
STAT_RX: u2 = 0,
/// DTOG_RX [14:14]
/// DTOG_RX
DTOG_RX: u1 = 0,
/// CTR_RX [15:15]
/// CTR_RX
CTR_RX: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// endpoint register
pub const EP7R = Register(EP7R_val).init(base_address + 0x1c);

/// CNTR
const CNTR_val = packed struct {
/// FRES [0:0]
/// FRES
FRES: u1 = 0,
/// PDWN [1:1]
/// PDWN
PDWN: u1 = 0,
/// LPMODE [2:2]
/// LPMODE
LPMODE: u1 = 0,
/// FSUSP [3:3]
/// FSUSP
FSUSP: u1 = 0,
/// RESUME [4:4]
/// RESUME
RESUME: u1 = 0,
/// L1RESUME [5:5]
/// L1RESUME
L1RESUME: u1 = 0,
/// unused [6:6]
_unused6: u1 = 0,
/// L1REQM [7:7]
/// L1REQM
L1REQM: u1 = 0,
/// ESOFM [8:8]
/// ESOFM
ESOFM: u1 = 0,
/// SOFM [9:9]
/// SOFM
SOFM: u1 = 0,
/// RESETM [10:10]
/// RESETM
RESETM: u1 = 0,
/// SUSPM [11:11]
/// SUSPM
SUSPM: u1 = 0,
/// WKUPM [12:12]
/// WKUPM
WKUPM: u1 = 0,
/// ERRM [13:13]
/// ERRM
ERRM: u1 = 0,
/// PMAOVRM [14:14]
/// PMAOVRM
PMAOVRM: u1 = 0,
/// CTRM [15:15]
/// CTRM
CTRM: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register
pub const CNTR = Register(CNTR_val).init(base_address + 0x40);

/// ISTR
const ISTR_val = packed struct {
/// EP_ID [0:3]
/// EP_ID
EP_ID: u4 = 0,
/// DIR [4:4]
/// DIR
DIR: u1 = 0,
/// unused [5:6]
_unused5: u2 = 0,
/// L1REQ [7:7]
/// L1REQ
L1REQ: u1 = 0,
/// ESOF [8:8]
/// ESOF
ESOF: u1 = 0,
/// SOF [9:9]
/// SOF
SOF: u1 = 0,
/// RESET [10:10]
/// RESET
RESET: u1 = 0,
/// SUSP [11:11]
/// SUSP
SUSP: u1 = 0,
/// WKUP [12:12]
/// WKUP
WKUP: u1 = 0,
/// ERR [13:13]
/// ERR
ERR: u1 = 0,
/// PMAOVR [14:14]
/// PMAOVR
PMAOVR: u1 = 0,
/// CTR [15:15]
/// CTR
CTR: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// interrupt status register
pub const ISTR = Register(ISTR_val).init(base_address + 0x44);

/// FNR
const FNR_val = packed struct {
/// FN [0:10]
/// FN
FN: u11 = 0,
/// LSOF [11:12]
/// LSOF
LSOF: u2 = 0,
/// LCK [13:13]
/// LCK
LCK: u1 = 0,
/// RXDM [14:14]
/// RXDM
RXDM: u1 = 0,
/// RXDP [15:15]
/// RXDP
RXDP: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// frame number register
pub const FNR = Register(FNR_val).init(base_address + 0x48);

/// DADDR
const DADDR_val = packed struct {
/// ADD [0:6]
/// ADD
ADD: u7 = 0,
/// EF [7:7]
/// EF
EF: u1 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// device address
pub const DADDR = Register(DADDR_val).init(base_address + 0x4c);

/// BTABLE
const BTABLE_val = packed struct {
/// unused [0:2]
_unused0: u3 = 0,
/// BTABLE [3:15]
/// BTABLE
BTABLE: u13 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Buffer table address
pub const BTABLE = Register(BTABLE_val).init(base_address + 0x50);

/// LPMCSR
const LPMCSR_val = packed struct {
/// LPMEN [0:0]
/// LPMEN
LPMEN: u1 = 0,
/// LPMACK [1:1]
/// LPMACK
LPMACK: u1 = 0,
/// unused [2:2]
_unused2: u1 = 0,
/// REMWAKE [3:3]
/// REMWAKE
REMWAKE: u1 = 0,
/// BESL [4:7]
/// BESL
BESL: u4 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// LPM control and status
pub const LPMCSR = Register(LPMCSR_val).init(base_address + 0x54);

/// BCDR
const BCDR_val = packed struct {
/// BCDEN [0:0]
/// BCDEN
BCDEN: u1 = 0,
/// DCDEN [1:1]
/// DCDEN
DCDEN: u1 = 0,
/// PDEN [2:2]
/// PDEN
PDEN: u1 = 0,
/// SDEN [3:3]
/// SDEN
SDEN: u1 = 0,
/// DCDET [4:4]
/// DCDET
DCDET: u1 = 0,
/// PDET [5:5]
/// PDET
PDET: u1 = 0,
/// SDET [6:6]
/// SDET
SDET: u1 = 0,
/// PS2DET [7:7]
/// PS2DET
PS2DET: u1 = 0,
/// unused [8:14]
_unused8: u7 = 0,
/// DPPU [15:15]
/// DPPU
DPPU: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Battery charging detector
pub const BCDR = Register(BCDR_val).init(base_address + 0x58);
};

/// Clock recovery system
pub const CRS = struct {

const base_address = 0x40006c00;
/// CR
const CR_val = packed struct {
/// SYNCOKIE [0:0]
/// SYNC event OK interrupt
SYNCOKIE: u1 = 0,
/// SYNCWARNIE [1:1]
/// SYNC warning interrupt
SYNCWARNIE: u1 = 0,
/// ERRIE [2:2]
/// Synchronization or trimming error
ERRIE: u1 = 0,
/// ESYNCIE [3:3]
/// Expected SYNC interrupt
ESYNCIE: u1 = 0,
/// unused [4:4]
_unused4: u1 = 0,
/// CEN [5:5]
/// Frequency error counter
CEN: u1 = 0,
/// AUTOTRIMEN [6:6]
/// Automatic trimming enable
AUTOTRIMEN: u1 = 0,
/// SWSYNC [7:7]
/// Generate software SYNC
SWSYNC: u1 = 0,
/// TRIM [8:13]
/// HSI48 oscillator smooth
TRIM: u6 = 32,
/// unused [14:31]
_unused14: u2 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register
pub const CR = Register(CR_val).init(base_address + 0x0);

/// CFGR
const CFGR_val = packed struct {
/// RELOAD [0:15]
/// Counter reload value
RELOAD: u16 = 47999,
/// FELIM [16:23]
/// Frequency error limit
FELIM: u8 = 34,
/// SYNCDIV [24:26]
/// SYNC divider
SYNCDIV: u3 = 0,
/// unused [27:27]
_unused27: u1 = 0,
/// SYNCSRC [28:29]
/// SYNC signal source
SYNCSRC: u2 = 2,
/// unused [30:30]
_unused30: u1 = 0,
/// SYNCPOL [31:31]
/// SYNC polarity selection
SYNCPOL: u1 = 0,
};
/// configuration register
pub const CFGR = Register(CFGR_val).init(base_address + 0x4);

/// ISR
const ISR_val = packed struct {
/// SYNCOKF [0:0]
/// SYNC event OK flag
SYNCOKF: u1 = 0,
/// SYNCWARNF [1:1]
/// SYNC warning flag
SYNCWARNF: u1 = 0,
/// ERRF [2:2]
/// Error flag
ERRF: u1 = 0,
/// ESYNCF [3:3]
/// Expected SYNC flag
ESYNCF: u1 = 0,
/// unused [4:7]
_unused4: u4 = 0,
/// SYNCERR [8:8]
/// SYNC error
SYNCERR: u1 = 0,
/// SYNCMISS [9:9]
/// SYNC missed
SYNCMISS: u1 = 0,
/// TRIMOVF [10:10]
/// Trimming overflow or
TRIMOVF: u1 = 0,
/// unused [11:14]
_unused11: u4 = 0,
/// FEDIR [15:15]
/// Frequency error direction
FEDIR: u1 = 0,
/// FECAP [16:31]
/// Frequency error capture
FECAP: u16 = 0,
};
/// interrupt and status register
pub const ISR = Register(ISR_val).init(base_address + 0x8);

/// ICR
const ICR_val = packed struct {
/// SYNCOKC [0:0]
/// SYNC event OK clear flag
SYNCOKC: u1 = 0,
/// SYNCWARNC [1:1]
/// SYNC warning clear flag
SYNCWARNC: u1 = 0,
/// ERRC [2:2]
/// Error clear flag
ERRC: u1 = 0,
/// ESYNCC [3:3]
/// Expected SYNC clear flag
ESYNCC: u1 = 0,
/// unused [4:31]
_unused4: u4 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// interrupt flag clear register
pub const ICR = Register(ICR_val).init(base_address + 0xc);
};

/// Firewall
pub const Firewall = struct {

const base_address = 0x40011c00;
/// FIREWALL_CSSA
const FIREWALL_CSSA_val = packed struct {
/// unused [0:7]
_unused0: u8 = 0,
/// ADD [8:23]
/// code segment start address
ADD: u16 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// Code segment start address
pub const FIREWALL_CSSA = Register(FIREWALL_CSSA_val).init(base_address + 0x0);

/// FIREWALL_CSL
const FIREWALL_CSL_val = packed struct {
/// unused [0:7]
_unused0: u8 = 0,
/// LENG [8:21]
/// code segment length
LENG: u14 = 0,
/// unused [22:31]
_unused22: u2 = 0,
_unused24: u8 = 0,
};
/// Code segment length
pub const FIREWALL_CSL = Register(FIREWALL_CSL_val).init(base_address + 0x4);

/// FIREWALL_NVDSSA
const FIREWALL_NVDSSA_val = packed struct {
/// unused [0:7]
_unused0: u8 = 0,
/// ADD [8:23]
/// Non-volatile data segment start
ADD: u16 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// Non-volatile data segment start
pub const FIREWALL_NVDSSA = Register(FIREWALL_NVDSSA_val).init(base_address + 0x8);

/// FIREWALL_NVDSL
const FIREWALL_NVDSL_val = packed struct {
/// unused [0:7]
_unused0: u8 = 0,
/// LENG [8:21]
/// Non-volatile data segment
LENG: u14 = 0,
/// unused [22:31]
_unused22: u2 = 0,
_unused24: u8 = 0,
};
/// Non-volatile data segment
pub const FIREWALL_NVDSL = Register(FIREWALL_NVDSL_val).init(base_address + 0xc);

/// FIREWALL_VDSSA
const FIREWALL_VDSSA_val = packed struct {
/// unused [0:5]
_unused0: u6 = 0,
/// ADD [6:15]
/// Volatile data segment start
ADD: u10 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Volatile data segment start
pub const FIREWALL_VDSSA = Register(FIREWALL_VDSSA_val).init(base_address + 0x10);

/// FIREWALL_VDSL
const FIREWALL_VDSL_val = packed struct {
/// unused [0:5]
_unused0: u6 = 0,
/// LENG [6:15]
/// Non-volatile data segment
LENG: u10 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Volatile data segment length
pub const FIREWALL_VDSL = Register(FIREWALL_VDSL_val).init(base_address + 0x14);

/// FIREWALL_CR
const FIREWALL_CR_val = packed struct {
/// FPA [0:0]
/// Firewall pre alarm
FPA: u1 = 0,
/// VDS [1:1]
/// Volatile data shared
VDS: u1 = 0,
/// VDE [2:2]
/// Volatile data execution
VDE: u1 = 0,
/// unused [3:31]
_unused3: u5 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Configuration register
pub const FIREWALL_CR = Register(FIREWALL_CR_val).init(base_address + 0x20);
};

/// Reset and clock control
pub const RCC = struct {

const base_address = 0x40021000;
/// CR
const CR_val = packed struct {
/// HSI16ON [0:0]
/// 16 MHz high-speed internal clock
HSI16ON: u1 = 0,
/// HSI16KERON [1:1]
/// High-speed internal clock enable bit for
HSI16KERON: u1 = 0,
/// HSI16RDYF [2:2]
/// Internal high-speed clock ready
HSI16RDYF: u1 = 0,
/// HSI16DIVEN [3:3]
/// HSI16DIVEN
HSI16DIVEN: u1 = 0,
/// HSI16DIVF [4:4]
/// HSI16DIVF
HSI16DIVF: u1 = 0,
/// HSI16OUTEN [5:5]
/// 16 MHz high-speed internal clock output
HSI16OUTEN: u1 = 0,
/// unused [6:7]
_unused6: u2 = 0,
/// MSION [8:8]
/// MSI clock enable bit
MSION: u1 = 1,
/// MSIRDY [9:9]
/// MSI clock ready flag
MSIRDY: u1 = 1,
/// unused [10:15]
_unused10: u6 = 0,
/// HSEON [16:16]
/// HSE clock enable bit
HSEON: u1 = 0,
/// HSERDY [17:17]
/// HSE clock ready flag
HSERDY: u1 = 0,
/// HSEBYP [18:18]
/// HSE clock bypass bit
HSEBYP: u1 = 0,
/// CSSLSEON [19:19]
/// Clock security system on HSE enable
CSSLSEON: u1 = 0,
/// RTCPRE [20:21]
/// TC/LCD prescaler
RTCPRE: u2 = 0,
/// unused [22:23]
_unused22: u2 = 0,
/// PLLON [24:24]
/// PLL enable bit
PLLON: u1 = 0,
/// PLLRDY [25:25]
/// PLL clock ready flag
PLLRDY: u1 = 0,
/// unused [26:31]
_unused26: u6 = 0,
};
/// Clock control register
pub const CR = Register(CR_val).init(base_address + 0x0);

/// ICSCR
const ICSCR_val = packed struct {
/// HSI16CAL [0:7]
/// nternal high speed clock
HSI16CAL: u8 = 0,
/// HSI16TRIM [8:12]
/// High speed internal clock
HSI16TRIM: u5 = 16,
/// MSIRANGE [13:15]
/// MSI clock ranges
MSIRANGE: u3 = 5,
/// MSICAL [16:23]
/// MSI clock calibration
MSICAL: u8 = 0,
/// MSITRIM [24:31]
/// MSI clock trimming
MSITRIM: u8 = 0,
};
/// Internal clock sources calibration
pub const ICSCR = Register(ICSCR_val).init(base_address + 0x4);

/// CRRCR
const CRRCR_val = packed struct {
/// HSI48ON [0:0]
/// 48MHz HSI clock enable bit
HSI48ON: u1 = 0,
/// HSI48RDY [1:1]
/// 48MHz HSI clock ready flag
HSI48RDY: u1 = 0,
/// HSI48DIV6EN [2:2]
/// 48 MHz HSI clock divided by 6 output
HSI48DIV6EN: u1 = 0,
/// unused [3:7]
_unused3: u5 = 0,
/// HSI48CAL [8:15]
/// 48 MHz HSI clock
HSI48CAL: u8 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Clock recovery RC register
pub const CRRCR = Register(CRRCR_val).init(base_address + 0x8);

/// CFGR
const CFGR_val = packed struct {
/// SW [0:1]
/// System clock switch
SW: u2 = 0,
/// SWS [2:3]
/// System clock switch status
SWS: u2 = 0,
/// HPRE [4:7]
/// AHB prescaler
HPRE: u4 = 0,
/// PPRE1 [8:10]
/// APB low-speed prescaler
PPRE1: u3 = 0,
/// PPRE2 [11:13]
/// APB high-speed prescaler
PPRE2: u3 = 0,
/// unused [14:14]
_unused14: u1 = 0,
/// STOPWUCK [15:15]
/// Wake-up from stop clock
STOPWUCK: u1 = 0,
/// PLLSRC [16:16]
/// PLL entry clock source
PLLSRC: u1 = 0,
/// unused [17:17]
_unused17: u1 = 0,
/// PLLMUL [18:21]
/// PLL multiplication factor
PLLMUL: u4 = 0,
/// PLLDIV [22:23]
/// PLL output division
PLLDIV: u2 = 0,
/// MCOSEL [24:27]
/// Microcontroller clock output
MCOSEL: u4 = 0,
/// MCOPRE [28:30]
/// Microcontroller clock output
MCOPRE: u3 = 0,
/// unused [31:31]
_unused31: u1 = 0,
};
/// Clock configuration register
pub const CFGR = Register(CFGR_val).init(base_address + 0xc);

/// CIER
const CIER_val = packed struct {
/// LSIRDYIE [0:0]
/// LSI ready interrupt flag
LSIRDYIE: u1 = 0,
/// LSERDYIE [1:1]
/// LSE ready interrupt flag
LSERDYIE: u1 = 0,
/// HSI16RDYIE [2:2]
/// HSI16 ready interrupt flag
HSI16RDYIE: u1 = 0,
/// HSERDYIE [3:3]
/// HSE ready interrupt flag
HSERDYIE: u1 = 0,
/// PLLRDYIE [4:4]
/// PLL ready interrupt flag
PLLRDYIE: u1 = 0,
/// MSIRDYIE [5:5]
/// MSI ready interrupt flag
MSIRDYIE: u1 = 0,
/// HSI48RDYIE [6:6]
/// HSI48 ready interrupt flag
HSI48RDYIE: u1 = 0,
/// CSSLSE [7:7]
/// LSE CSS interrupt flag
CSSLSE: u1 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Clock interrupt enable
pub const CIER = Register(CIER_val).init(base_address + 0x10);

/// CIFR
const CIFR_val = packed struct {
/// LSIRDYF [0:0]
/// LSI ready interrupt flag
LSIRDYF: u1 = 0,
/// LSERDYF [1:1]
/// LSE ready interrupt flag
LSERDYF: u1 = 0,
/// HSI16RDYF [2:2]
/// HSI16 ready interrupt flag
HSI16RDYF: u1 = 0,
/// HSERDYF [3:3]
/// HSE ready interrupt flag
HSERDYF: u1 = 0,
/// PLLRDYF [4:4]
/// PLL ready interrupt flag
PLLRDYF: u1 = 0,
/// MSIRDYF [5:5]
/// MSI ready interrupt flag
MSIRDYF: u1 = 0,
/// HSI48RDYF [6:6]
/// HSI48 ready interrupt flag
HSI48RDYF: u1 = 0,
/// CSSLSEF [7:7]
/// LSE Clock Security System Interrupt
CSSLSEF: u1 = 0,
/// CSSHSEF [8:8]
/// Clock Security System Interrupt
CSSHSEF: u1 = 0,
/// unused [9:31]
_unused9: u7 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Clock interrupt flag register
pub const CIFR = Register(CIFR_val).init(base_address + 0x14);

/// CICR
const CICR_val = packed struct {
/// LSIRDYC [0:0]
/// LSI ready Interrupt clear
LSIRDYC: u1 = 0,
/// LSERDYC [1:1]
/// LSE ready Interrupt clear
LSERDYC: u1 = 0,
/// HSI16RDYC [2:2]
/// HSI16 ready Interrupt
HSI16RDYC: u1 = 0,
/// HSERDYC [3:3]
/// HSE ready Interrupt clear
HSERDYC: u1 = 0,
/// PLLRDYC [4:4]
/// PLL ready Interrupt clear
PLLRDYC: u1 = 0,
/// MSIRDYC [5:5]
/// MSI ready Interrupt clear
MSIRDYC: u1 = 0,
/// HSI48RDYC [6:6]
/// HSI48 ready Interrupt
HSI48RDYC: u1 = 0,
/// CSSLSEC [7:7]
/// LSE Clock Security System Interrupt
CSSLSEC: u1 = 0,
/// CSSHSEC [8:8]
/// Clock Security System Interrupt
CSSHSEC: u1 = 0,
/// unused [9:31]
_unused9: u7 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Clock interrupt clear register
pub const CICR = Register(CICR_val).init(base_address + 0x18);

/// IOPRSTR
const IOPRSTR_val = packed struct {
/// IOPARST [0:0]
/// I/O port A reset
IOPARST: u1 = 0,
/// IOPBRST [1:1]
/// I/O port B reset
IOPBRST: u1 = 0,
/// IOPCRST [2:2]
/// I/O port A reset
IOPCRST: u1 = 0,
/// IOPDRST [3:3]
/// I/O port D reset
IOPDRST: u1 = 0,
/// IOPERST [4:4]
/// I/O port E reset
IOPERST: u1 = 0,
/// unused [5:6]
_unused5: u2 = 0,
/// IOPHRST [7:7]
/// I/O port H reset
IOPHRST: u1 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO reset register
pub const IOPRSTR = Register(IOPRSTR_val).init(base_address + 0x1c);

/// AHBRSTR
const AHBRSTR_val = packed struct {
/// DMARST [0:0]
/// DMA reset
DMARST: u1 = 0,
/// unused [1:7]
_unused1: u7 = 0,
/// MIFRST [8:8]
/// Memory interface reset
MIFRST: u1 = 0,
/// unused [9:11]
_unused9: u3 = 0,
/// CRCRST [12:12]
/// Test integration module
CRCRST: u1 = 0,
/// unused [13:15]
_unused13: u3 = 0,
/// TOUCHRST [16:16]
/// Touch Sensing reset
TOUCHRST: u1 = 0,
/// unused [17:19]
_unused17: u3 = 0,
/// RNGRST [20:20]
/// Random Number Generator module
RNGRST: u1 = 0,
/// unused [21:23]
_unused21: u3 = 0,
/// CRYPRST [24:24]
/// Crypto module reset
CRYPRST: u1 = 0,
/// unused [25:31]
_unused25: u7 = 0,
};
/// AHB peripheral reset register
pub const AHBRSTR = Register(AHBRSTR_val).init(base_address + 0x20);

/// APB2RSTR
const APB2RSTR_val = packed struct {
/// SYSCFGRST [0:0]
/// System configuration controller
SYSCFGRST: u1 = 0,
/// unused [1:1]
_unused1: u1 = 0,
/// TIM21RST [2:2]
/// TIM21 timer reset
TIM21RST: u1 = 0,
/// unused [3:4]
_unused3: u2 = 0,
/// TM12RST [5:5]
/// TIM22 timer reset
TM12RST: u1 = 0,
/// unused [6:8]
_unused6: u2 = 0,
_unused8: u1 = 0,
/// ADCRST [9:9]
/// ADC interface reset
ADCRST: u1 = 0,
/// unused [10:11]
_unused10: u2 = 0,
/// SPI1RST [12:12]
/// SPI 1 reset
SPI1RST: u1 = 0,
/// unused [13:13]
_unused13: u1 = 0,
/// USART1RST [14:14]
/// USART1 reset
USART1RST: u1 = 0,
/// unused [15:21]
_unused15: u1 = 0,
_unused16: u6 = 0,
/// DBGRST [22:22]
/// DBG reset
DBGRST: u1 = 0,
/// unused [23:31]
_unused23: u1 = 0,
_unused24: u8 = 0,
};
/// APB2 peripheral reset register
pub const APB2RSTR = Register(APB2RSTR_val).init(base_address + 0x24);

/// APB1RSTR
const APB1RSTR_val = packed struct {
/// TIM2RST [0:0]
/// Timer2 reset
TIM2RST: u1 = 0,
/// TIM3RST [1:1]
/// Timer3 reset
TIM3RST: u1 = 0,
/// unused [2:3]
_unused2: u2 = 0,
/// TIM6RST [4:4]
/// Timer 6 reset
TIM6RST: u1 = 0,
/// TIM7RST [5:5]
/// Timer 7 reset
TIM7RST: u1 = 0,
/// unused [6:10]
_unused6: u2 = 0,
_unused8: u3 = 0,
/// WWDRST [11:11]
/// Window watchdog reset
WWDRST: u1 = 0,
/// unused [12:13]
_unused12: u2 = 0,
/// SPI2RST [14:14]
/// SPI2 reset
SPI2RST: u1 = 0,
/// unused [15:16]
_unused15: u1 = 0,
_unused16: u1 = 0,
/// LPUART12RST [17:17]
/// UART2 reset
LPUART12RST: u1 = 0,
/// LPUART1RST [18:18]
/// LPUART1 reset
LPUART1RST: u1 = 0,
/// USART4RST [19:19]
/// USART4 reset
USART4RST: u1 = 0,
/// USART5RST [20:20]
/// USART5 reset
USART5RST: u1 = 0,
/// I2C1RST [21:21]
/// I2C1 reset
I2C1RST: u1 = 0,
/// I2C2RST [22:22]
/// I2C2 reset
I2C2RST: u1 = 0,
/// USBRST [23:23]
/// USB reset
USBRST: u1 = 0,
/// unused [24:26]
_unused24: u3 = 0,
/// CRSRST [27:27]
/// Clock recovery system
CRSRST: u1 = 0,
/// PWRRST [28:28]
/// Power interface reset
PWRRST: u1 = 0,
/// DACRST [29:29]
/// DAC interface reset
DACRST: u1 = 0,
/// I2C3RST [30:30]
/// I2C3 reset
I2C3RST: u1 = 0,
/// LPTIM1RST [31:31]
/// Low power timer reset
LPTIM1RST: u1 = 0,
};
/// APB1 peripheral reset register
pub const APB1RSTR = Register(APB1RSTR_val).init(base_address + 0x28);

/// IOPENR
const IOPENR_val = packed struct {
/// IOPAEN [0:0]
/// IO port A clock enable bit
IOPAEN: u1 = 0,
/// IOPBEN [1:1]
/// IO port B clock enable bit
IOPBEN: u1 = 0,
/// IOPCEN [2:2]
/// IO port A clock enable bit
IOPCEN: u1 = 0,
/// IOPDEN [3:3]
/// I/O port D clock enable
IOPDEN: u1 = 0,
/// IOPEEN [4:4]
/// I/O port E clock enable
IOPEEN: u1 = 0,
/// unused [5:6]
_unused5: u2 = 0,
/// IOPHEN [7:7]
/// I/O port H clock enable
IOPHEN: u1 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO clock enable register
pub const IOPENR = Register(IOPENR_val).init(base_address + 0x2c);

/// AHBENR
const AHBENR_val = packed struct {
/// DMAEN [0:0]
/// DMA clock enable bit
DMAEN: u1 = 0,
/// unused [1:7]
_unused1: u7 = 0,
/// MIFEN [8:8]
/// NVM interface clock enable
MIFEN: u1 = 1,
/// unused [9:11]
_unused9: u3 = 0,
/// CRCEN [12:12]
/// CRC clock enable bit
CRCEN: u1 = 0,
/// unused [13:15]
_unused13: u3 = 0,
/// TOUCHEN [16:16]
/// Touch Sensing clock enable
TOUCHEN: u1 = 0,
/// unused [17:19]
_unused17: u3 = 0,
/// RNGEN [20:20]
/// Random Number Generator clock enable
RNGEN: u1 = 0,
/// unused [21:23]
_unused21: u3 = 0,
/// CRYPEN [24:24]
/// Crypto clock enable bit
CRYPEN: u1 = 0,
/// unused [25:31]
_unused25: u7 = 0,
};
/// AHB peripheral clock enable
pub const AHBENR = Register(AHBENR_val).init(base_address + 0x30);

/// APB2ENR
const APB2ENR_val = packed struct {
/// SYSCFGEN [0:0]
/// System configuration controller clock
SYSCFGEN: u1 = 0,
/// unused [1:1]
_unused1: u1 = 0,
/// TIM21EN [2:2]
/// TIM21 timer clock enable
TIM21EN: u1 = 0,
/// unused [3:4]
_unused3: u2 = 0,
/// TIM22EN [5:5]
/// TIM22 timer clock enable
TIM22EN: u1 = 0,
/// unused [6:6]
_unused6: u1 = 0,
/// MIFIEN [7:7]
/// MiFaRe Firewall clock enable
MIFIEN: u1 = 0,
/// unused [8:8]
_unused8: u1 = 0,
/// ADCEN [9:9]
/// ADC clock enable bit
ADCEN: u1 = 0,
/// unused [10:11]
_unused10: u2 = 0,
/// SPI1EN [12:12]
/// SPI1 clock enable bit
SPI1EN: u1 = 0,
/// unused [13:13]
_unused13: u1 = 0,
/// USART1EN [14:14]
/// USART1 clock enable bit
USART1EN: u1 = 0,
/// unused [15:21]
_unused15: u1 = 0,
_unused16: u6 = 0,
/// DBGEN [22:22]
/// DBG clock enable bit
DBGEN: u1 = 0,
/// unused [23:31]
_unused23: u1 = 0,
_unused24: u8 = 0,
};
/// APB2 peripheral clock enable
pub const APB2ENR = Register(APB2ENR_val).init(base_address + 0x34);

/// APB1ENR
const APB1ENR_val = packed struct {
/// TIM2EN [0:0]
/// Timer2 clock enable bit
TIM2EN: u1 = 0,
/// TIM3EN [1:1]
/// Timer3 clock enable bit
TIM3EN: u1 = 0,
/// unused [2:3]
_unused2: u2 = 0,
/// TIM6EN [4:4]
/// Timer 6 clock enable bit
TIM6EN: u1 = 0,
/// TIM7EN [5:5]
/// Timer 7 clock enable bit
TIM7EN: u1 = 0,
/// unused [6:10]
_unused6: u2 = 0,
_unused8: u3 = 0,
/// WWDGEN [11:11]
/// Window watchdog clock enable
WWDGEN: u1 = 0,
/// unused [12:13]
_unused12: u2 = 0,
/// SPI2EN [14:14]
/// SPI2 clock enable bit
SPI2EN: u1 = 0,
/// unused [15:16]
_unused15: u1 = 0,
_unused16: u1 = 0,
/// USART2EN [17:17]
/// UART2 clock enable bit
USART2EN: u1 = 0,
/// LPUART1EN [18:18]
/// LPUART1 clock enable bit
LPUART1EN: u1 = 0,
/// USART4EN [19:19]
/// USART4 clock enable bit
USART4EN: u1 = 0,
/// USART5EN [20:20]
/// USART5 clock enable bit
USART5EN: u1 = 0,
/// I2C1EN [21:21]
/// I2C1 clock enable bit
I2C1EN: u1 = 0,
/// I2C2EN [22:22]
/// I2C2 clock enable bit
I2C2EN: u1 = 0,
/// USBEN [23:23]
/// USB clock enable bit
USBEN: u1 = 0,
/// unused [24:26]
_unused24: u3 = 0,
/// CRSEN [27:27]
/// Clock recovery system clock enable
CRSEN: u1 = 0,
/// PWREN [28:28]
/// Power interface clock enable
PWREN: u1 = 0,
/// DACEN [29:29]
/// DAC interface clock enable
DACEN: u1 = 0,
/// I2C3EN [30:30]
/// I2C3 clock enable bit
I2C3EN: u1 = 0,
/// LPTIM1EN [31:31]
/// Low power timer clock enable
LPTIM1EN: u1 = 0,
};
/// APB1 peripheral clock enable
pub const APB1ENR = Register(APB1ENR_val).init(base_address + 0x38);

/// IOPSMEN
const IOPSMEN_val = packed struct {
/// IOPASMEN [0:0]
/// IOPASMEN
IOPASMEN: u1 = 1,
/// IOPBSMEN [1:1]
/// IOPBSMEN
IOPBSMEN: u1 = 1,
/// IOPCSMEN [2:2]
/// IOPCSMEN
IOPCSMEN: u1 = 1,
/// IOPDSMEN [3:3]
/// IOPDSMEN
IOPDSMEN: u1 = 1,
/// IOPESMEN [4:4]
/// Port E clock enable during Sleep mode
IOPESMEN: u1 = 0,
/// unused [5:6]
_unused5: u2 = 0,
/// IOPHSMEN [7:7]
/// IOPHSMEN
IOPHSMEN: u1 = 1,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// GPIO clock enable in sleep mode
pub const IOPSMEN = Register(IOPSMEN_val).init(base_address + 0x3c);

/// AHBSMENR
const AHBSMENR_val = packed struct {
/// DMASMEN [0:0]
/// DMA clock enable during sleep mode
DMASMEN: u1 = 1,
/// unused [1:7]
_unused1: u7 = 0,
/// MIFSMEN [8:8]
/// NVM interface clock enable during sleep
MIFSMEN: u1 = 1,
/// SRAMSMEN [9:9]
/// SRAM interface clock enable during sleep
SRAMSMEN: u1 = 1,
/// unused [10:11]
_unused10: u2 = 0,
/// CRCSMEN [12:12]
/// CRC clock enable during sleep mode
CRCSMEN: u1 = 1,
/// unused [13:15]
_unused13: u3 = 0,
/// TOUCHSMEN [16:16]
/// Touch Sensing clock enable during sleep
TOUCHSMEN: u1 = 1,
/// unused [17:19]
_unused17: u3 = 0,
/// RNGSMEN [20:20]
/// Random Number Generator clock enable
RNGSMEN: u1 = 1,
/// unused [21:23]
_unused21: u3 = 0,
/// CRYPSMEN [24:24]
/// Crypto clock enable during sleep mode
CRYPSMEN: u1 = 1,
/// unused [25:31]
_unused25: u7 = 0,
};
/// AHB peripheral clock enable in sleep mode
pub const AHBSMENR = Register(AHBSMENR_val).init(base_address + 0x40);

/// APB2SMENR
const APB2SMENR_val = packed struct {
/// SYSCFGSMEN [0:0]
/// System configuration controller clock
SYSCFGSMEN: u1 = 1,
/// unused [1:1]
_unused1: u1 = 0,
/// TIM21SMEN [2:2]
/// TIM21 timer clock enable during sleep
TIM21SMEN: u1 = 1,
/// unused [3:4]
_unused3: u2 = 0,
/// TIM22SMEN [5:5]
/// TIM22 timer clock enable during sleep
TIM22SMEN: u1 = 1,
/// unused [6:8]
_unused6: u2 = 0,
_unused8: u1 = 0,
/// ADCSMEN [9:9]
/// ADC clock enable during sleep mode
ADCSMEN: u1 = 1,
/// unused [10:11]
_unused10: u2 = 0,
/// SPI1SMEN [12:12]
/// SPI1 clock enable during sleep mode
SPI1SMEN: u1 = 1,
/// unused [13:13]
_unused13: u1 = 0,
/// USART1SMEN [14:14]
/// USART1 clock enable during sleep mode
USART1SMEN: u1 = 1,
/// unused [15:21]
_unused15: u1 = 0,
_unused16: u6 = 0,
/// DBGSMEN [22:22]
/// DBG clock enable during sleep mode
DBGSMEN: u1 = 1,
/// unused [23:31]
_unused23: u1 = 0,
_unused24: u8 = 0,
};
/// APB2 peripheral clock enable in sleep mode
pub const APB2SMENR = Register(APB2SMENR_val).init(base_address + 0x44);

/// APB1SMENR
const APB1SMENR_val = packed struct {
/// TIM2SMEN [0:0]
/// Timer2 clock enable during sleep mode
TIM2SMEN: u1 = 1,
/// TIM3SMEN [1:1]
/// Timer3 clock enable during Sleep mode
TIM3SMEN: u1 = 0,
/// unused [2:3]
_unused2: u2 = 0,
/// TIM6SMEN [4:4]
/// Timer 6 clock enable during sleep mode
TIM6SMEN: u1 = 1,
/// TIM7SMEN [5:5]
/// Timer 7 clock enable during Sleep mode
TIM7SMEN: u1 = 0,
/// unused [6:10]
_unused6: u2 = 0,
_unused8: u3 = 2,
/// WWDGSMEN [11:11]
/// Window watchdog clock enable during
WWDGSMEN: u1 = 1,
/// unused [12:13]
_unused12: u2 = 0,
/// SPI2SMEN [14:14]
/// SPI2 clock enable during sleep mode
SPI2SMEN: u1 = 1,
/// unused [15:16]
_unused15: u1 = 0,
_unused16: u1 = 0,
/// USART2SMEN [17:17]
/// UART2 clock enable during sleep mode
USART2SMEN: u1 = 1,
/// LPUART1SMEN [18:18]
/// LPUART1 clock enable during sleep mode
LPUART1SMEN: u1 = 1,
/// USART4SMEN [19:19]
/// USART4 clock enable during Sleep mode
USART4SMEN: u1 = 0,
/// USART5SMEN [20:20]
/// USART5 clock enable during Sleep mode
USART5SMEN: u1 = 0,
/// I2C1SMEN [21:21]
/// I2C1 clock enable during sleep mode
I2C1SMEN: u1 = 1,
/// I2C2SMEN [22:22]
/// I2C2 clock enable during sleep mode
I2C2SMEN: u1 = 1,
/// USBSMEN [23:23]
/// USB clock enable during sleep mode
USBSMEN: u1 = 1,
/// unused [24:26]
_unused24: u3 = 0,
/// CRSSMEN [27:27]
/// Clock recovery system clock enable
CRSSMEN: u1 = 1,
/// PWRSMEN [28:28]
/// Power interface clock enable during
PWRSMEN: u1 = 1,
/// DACSMEN [29:29]
/// DAC interface clock enable during sleep
DACSMEN: u1 = 1,
/// I2C3SMEN [30:30]
/// 2C3 clock enable during Sleep mode
I2C3SMEN: u1 = 0,
/// LPTIM1SMEN [31:31]
/// Low power timer clock enable during
LPTIM1SMEN: u1 = 1,
};
/// APB1 peripheral clock enable in sleep mode
pub const APB1SMENR = Register(APB1SMENR_val).init(base_address + 0x48);

/// CCIPR
const CCIPR_val = packed struct {
/// USART1SEL0 [0:0]
/// USART1SEL0
USART1SEL0: u1 = 0,
/// USART1SEL1 [1:1]
/// USART1 clock source selection
USART1SEL1: u1 = 0,
/// USART2SEL0 [2:2]
/// USART2SEL0
USART2SEL0: u1 = 0,
/// USART2SEL1 [3:3]
/// USART2 clock source selection
USART2SEL1: u1 = 0,
/// unused [4:9]
_unused4: u4 = 0,
_unused8: u2 = 0,
/// LPUART1SEL0 [10:10]
/// LPUART1SEL0
LPUART1SEL0: u1 = 0,
/// LPUART1SEL1 [11:11]
/// LPUART1 clock source selection
LPUART1SEL1: u1 = 0,
/// I2C1SEL0 [12:12]
/// I2C1SEL0
I2C1SEL0: u1 = 0,
/// I2C1SEL1 [13:13]
/// I2C1 clock source selection
I2C1SEL1: u1 = 0,
/// unused [14:15]
_unused14: u2 = 0,
/// I2C3SEL [16:17]
/// I2C3 clock source selection
I2C3SEL: u2 = 0,
/// LPTIM1SEL0 [18:18]
/// LPTIM1SEL0
LPTIM1SEL0: u1 = 0,
/// LPTIM1SEL1 [19:19]
/// Low Power Timer clock source selection
LPTIM1SEL1: u1 = 0,
/// unused [20:25]
_unused20: u4 = 0,
_unused24: u2 = 0,
/// HSI48MSEL [26:26]
/// 48 MHz HSI48 clock source selection
HSI48MSEL: u1 = 0,
/// unused [27:31]
_unused27: u5 = 0,
};
/// Clock configuration register
pub const CCIPR = Register(CCIPR_val).init(base_address + 0x4c);

/// CSR
const CSR_val = packed struct {
/// LSION [0:0]
/// Internal low-speed oscillator
LSION: u1 = 0,
/// LSIRDY [1:1]
/// Internal low-speed oscillator ready
LSIRDY: u1 = 0,
/// unused [2:7]
_unused2: u6 = 0,
/// LSEON [8:8]
/// External low-speed oscillator enable
LSEON: u1 = 0,
/// LSERDY [9:9]
/// External low-speed oscillator ready
LSERDY: u1 = 0,
/// LSEBYP [10:10]
/// External low-speed oscillator bypass
LSEBYP: u1 = 0,
/// LSEDRV [11:12]
/// LSEDRV
LSEDRV: u2 = 0,
/// CSSLSEON [13:13]
/// CSSLSEON
CSSLSEON: u1 = 0,
/// CSSLSED [14:14]
/// CSS on LSE failure detection
CSSLSED: u1 = 0,
/// unused [15:15]
_unused15: u1 = 0,
/// RTCSEL [16:17]
/// RTC and LCD clock source selection
RTCSEL: u2 = 0,
/// RTCEN [18:18]
/// RTC clock enable bit
RTCEN: u1 = 0,
/// RTCRST [19:19]
/// RTC software reset bit
RTCRST: u1 = 0,
/// unused [20:23]
_unused20: u4 = 0,
/// RMVF [24:24]
/// Remove reset flag
RMVF: u1 = 0,
/// OBLRSTF [25:25]
/// OBLRSTF
OBLRSTF: u1 = 0,
/// PINRSTF [26:26]
/// PIN reset flag
PINRSTF: u1 = 1,
/// PORRSTF [27:27]
/// POR/PDR reset flag
PORRSTF: u1 = 1,
/// SFTRSTF [28:28]
/// Software reset flag
SFTRSTF: u1 = 0,
/// IWDGRSTF [29:29]
/// Independent watchdog reset
IWDGRSTF: u1 = 0,
/// WWDGRSTF [30:30]
/// Window watchdog reset flag
WWDGRSTF: u1 = 0,
/// LPWRSTF [31:31]
/// Low-power reset flag
LPWRSTF: u1 = 0,
};
/// Control and status register
pub const CSR = Register(CSR_val).init(base_address + 0x50);
};

/// System configuration controller and
pub const SYSCFG_COMP = struct {

const base_address = 0x40010000;
/// CFGR1
const CFGR1_val = packed struct {
/// MEM_MODE [0:1]
/// Memory mapping selection
MEM_MODE: u2 = 0,
/// unused [2:7]
_unused2: u6 = 0,
/// BOOT_MODE [8:9]
/// Boot mode selected by the boot pins
BOOT_MODE: u2 = 0,
/// unused [10:31]
_unused10: u6 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// SYSCFG configuration register
pub const CFGR1 = Register(CFGR1_val).init(base_address + 0x0);

/// CFGR2
const CFGR2_val = packed struct {
/// FWDISEN [0:0]
/// Firewall disable bit
FWDISEN: u1 = 0,
/// unused [1:7]
_unused1: u7 = 0,
/// I2C_PB6_FMP [8:8]
/// Fm+ drive capability on PB6 enable
I2C_PB6_FMP: u1 = 0,
/// I2C_PB7_FMP [9:9]
/// Fm+ drive capability on PB7 enable
I2C_PB7_FMP: u1 = 0,
/// I2C_PB8_FMP [10:10]
/// Fm+ drive capability on PB8 enable
I2C_PB8_FMP: u1 = 0,
/// I2C_PB9_FMP [11:11]
/// Fm+ drive capability on PB9 enable
I2C_PB9_FMP: u1 = 0,
/// I2C1_FMP [12:12]
/// I2C1 Fm+ drive capability enable
I2C1_FMP: u1 = 0,
/// I2C2_FMP [13:13]
/// I2C2 Fm+ drive capability enable
I2C2_FMP: u1 = 0,
/// unused [14:31]
_unused14: u2 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// SYSCFG configuration register
pub const CFGR2 = Register(CFGR2_val).init(base_address + 0x4);

/// EXTICR1
const EXTICR1_val = packed struct {
/// EXTI0 [0:3]
/// EXTI x configuration (x = 0 to
EXTI0: u4 = 0,
/// EXTI1 [4:7]
/// EXTI x configuration (x = 0 to
EXTI1: u4 = 0,
/// EXTI2 [8:11]
/// EXTI x configuration (x = 0 to
EXTI2: u4 = 0,
/// EXTI3 [12:15]
/// EXTI x configuration (x = 0 to
EXTI3: u4 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// external interrupt configuration register
pub const EXTICR1 = Register(EXTICR1_val).init(base_address + 0x8);

/// EXTICR2
const EXTICR2_val = packed struct {
/// EXTI4 [0:3]
/// EXTI x configuration (x = 4 to
EXTI4: u4 = 0,
/// EXTI5 [4:7]
/// EXTI x configuration (x = 4 to
EXTI5: u4 = 0,
/// EXTI6 [8:11]
/// EXTI x configuration (x = 4 to
EXTI6: u4 = 0,
/// EXTI7 [12:15]
/// EXTI x configuration (x = 4 to
EXTI7: u4 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// external interrupt configuration register
pub const EXTICR2 = Register(EXTICR2_val).init(base_address + 0xc);

/// EXTICR3
const EXTICR3_val = packed struct {
/// EXTI8 [0:3]
/// EXTI x configuration (x = 8 to
EXTI8: u4 = 0,
/// EXTI9 [4:7]
/// EXTI x configuration (x = 8 to
EXTI9: u4 = 0,
/// EXTI10 [8:11]
/// EXTI10
EXTI10: u4 = 0,
/// EXTI11 [12:15]
/// EXTI x configuration (x = 8 to
EXTI11: u4 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// external interrupt configuration register
pub const EXTICR3 = Register(EXTICR3_val).init(base_address + 0x10);

/// EXTICR4
const EXTICR4_val = packed struct {
/// EXTI12 [0:3]
/// EXTI12
EXTI12: u4 = 0,
/// EXTI13 [4:7]
/// EXTI13
EXTI13: u4 = 0,
/// EXTI14 [8:11]
/// EXTI14
EXTI14: u4 = 0,
/// EXTI15 [12:15]
/// EXTI x configuration (x = 12 to
EXTI15: u4 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// external interrupt configuration register
pub const EXTICR4 = Register(EXTICR4_val).init(base_address + 0x14);

/// CFGR3
const CFGR3_val = packed struct {
/// EN_BGAP [0:0]
/// Vref Enable bit
EN_BGAP: u1 = 0,
/// unused [1:3]
_unused1: u3 = 0,
/// SEL_VREF_OUT [4:5]
/// BGAP_ADC connection bit
SEL_VREF_OUT: u2 = 0,
/// unused [6:7]
_unused6: u2 = 0,
/// ENBUF_BGAP_ADC [8:8]
/// VREFINT reference for ADC enable
ENBUF_BGAP_ADC: u1 = 0,
/// ENBUF_SENSOR_ADC [9:9]
/// Sensor reference for ADC enable
ENBUF_SENSOR_ADC: u1 = 0,
/// unused [10:11]
_unused10: u2 = 0,
/// ENBUF_VREFINT_COMP [12:12]
/// VREFINT reference for comparator 2
ENBUF_VREFINT_COMP: u1 = 0,
/// ENREF_RC48MHz [13:13]
/// VREFINT reference for 48 MHz RC
ENREF_RC48MHz: u1 = 0,
/// unused [14:25]
_unused14: u2 = 0,
_unused16: u8 = 0,
_unused24: u2 = 0,
/// REF_RC48MHz_RDYF [26:26]
/// VREFINT for 48 MHz RC oscillator ready
REF_RC48MHz_RDYF: u1 = 0,
/// SENSOR_ADC_RDYF [27:27]
/// Sensor for ADC ready flag
SENSOR_ADC_RDYF: u1 = 0,
/// VREFINT_ADC_RDYF [28:28]
/// VREFINT for ADC ready flag
VREFINT_ADC_RDYF: u1 = 0,
/// VREFINT_COMP_RDYF [29:29]
/// VREFINT for comparator ready
VREFINT_COMP_RDYF: u1 = 0,
/// VREFINT_RDYF [30:30]
/// VREFINT ready flag
VREFINT_RDYF: u1 = 0,
/// REF_LOCK [31:31]
/// REF_CTRL lock bit
REF_LOCK: u1 = 0,
};
/// SYSCFG configuration register
pub const CFGR3 = Register(CFGR3_val).init(base_address + 0x20);

/// COMP1_CSR
const COMP1_CSR_val = packed struct {
/// COMP1EN [0:0]
/// Comparator 1 enable bit
COMP1EN: u1 = 0,
/// unused [1:3]
_unused1: u3 = 0,
/// COMP1INNSEL [4:5]
/// Comparator 1 Input Minus connection
COMP1INNSEL: u2 = 0,
/// unused [6:7]
_unused6: u2 = 0,
/// COMP1WM [8:8]
/// Comparator 1 window mode selection
COMP1WM: u1 = 0,
/// unused [9:11]
_unused9: u3 = 0,
/// COMP1LPTIMIN1 [12:12]
/// Comparator 1 LPTIM input propagation
COMP1LPTIMIN1: u1 = 0,
/// unused [13:14]
_unused13: u2 = 0,
/// COMP1POLARITY [15:15]
/// Comparator 1 polarity selection
COMP1POLARITY: u1 = 0,
/// unused [16:29]
_unused16: u8 = 0,
_unused24: u6 = 0,
/// COMP1VALUE [30:30]
/// Comparator 1 output status
COMP1VALUE: u1 = 0,
/// COMP1LOCK [31:31]
/// COMP1_CSR register lock
COMP1LOCK: u1 = 0,
};
/// Comparator 1 control and status
pub const COMP1_CSR = Register(COMP1_CSR_val).init(base_address + 0x18);

/// COMP2_CSR
const COMP2_CSR_val = packed struct {
/// COMP2EN [0:0]
/// Comparator 2 enable bit
COMP2EN: u1 = 0,
/// unused [1:2]
_unused1: u2 = 0,
/// COMP2SPEED [3:3]
/// Comparator 2 power mode selection
COMP2SPEED: u1 = 0,
/// COMP2INNSEL [4:6]
/// Comparator 2 Input Minus connection
COMP2INNSEL: u3 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// COMP2INPSEL [8:10]
/// Comparator 2 Input Plus connection
COMP2INPSEL: u3 = 0,
/// unused [11:11]
_unused11: u1 = 0,
/// COMP2LPTIMIN2 [12:12]
/// Comparator 2 LPTIM input 2 propagation
COMP2LPTIMIN2: u1 = 0,
/// COMP2LPTIMIN1 [13:13]
/// Comparator 2 LPTIM input 1 propagation
COMP2LPTIMIN1: u1 = 0,
/// unused [14:14]
_unused14: u1 = 0,
/// COMP2POLARITY [15:15]
/// Comparator 2 polarity selection
COMP2POLARITY: u1 = 0,
/// unused [16:19]
_unused16: u4 = 0,
/// COMP2VALUE [20:20]
/// Comparator 2 output status
COMP2VALUE: u1 = 0,
/// unused [21:30]
_unused21: u3 = 0,
_unused24: u7 = 0,
/// COMP2LOCK [31:31]
/// COMP2_CSR register lock
COMP2LOCK: u1 = 0,
};
/// Comparator 2 control and status
pub const COMP2_CSR = Register(COMP2_CSR_val).init(base_address + 0x1c);
};

/// Serial peripheral interface
pub const SPI1 = struct {

const base_address = 0x40013000;
/// CR1
const CR1_val = packed struct {
/// CPHA [0:0]
/// Clock phase
CPHA: u1 = 0,
/// CPOL [1:1]
/// Clock polarity
CPOL: u1 = 0,
/// MSTR [2:2]
/// Master selection
MSTR: u1 = 0,
/// BR [3:5]
/// Baud rate control
BR: u3 = 0,
/// SPE [6:6]
/// SPI enable
SPE: u1 = 0,
/// LSBFIRST [7:7]
/// Frame format
LSBFIRST: u1 = 0,
/// SSI [8:8]
/// Internal slave select
SSI: u1 = 0,
/// SSM [9:9]
/// Software slave management
SSM: u1 = 0,
/// RXONLY [10:10]
/// Receive only
RXONLY: u1 = 0,
/// DFF [11:11]
/// Data frame format
DFF: u1 = 0,
/// CRCNEXT [12:12]
/// CRC transfer next
CRCNEXT: u1 = 0,
/// CRCEN [13:13]
/// Hardware CRC calculation
CRCEN: u1 = 0,
/// BIDIOE [14:14]
/// Output enable in bidirectional
BIDIOE: u1 = 0,
/// BIDIMODE [15:15]
/// Bidirectional data mode
BIDIMODE: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register 1
pub const CR1 = Register(CR1_val).init(base_address + 0x0);

/// CR2
const CR2_val = packed struct {
/// RXDMAEN [0:0]
/// Rx buffer DMA enable
RXDMAEN: u1 = 0,
/// TXDMAEN [1:1]
/// Tx buffer DMA enable
TXDMAEN: u1 = 0,
/// SSOE [2:2]
/// SS output enable
SSOE: u1 = 0,
/// unused [3:3]
_unused3: u1 = 0,
/// FRF [4:4]
/// Frame format
FRF: u1 = 0,
/// ERRIE [5:5]
/// Error interrupt enable
ERRIE: u1 = 0,
/// RXNEIE [6:6]
/// RX buffer not empty interrupt
RXNEIE: u1 = 0,
/// TXEIE [7:7]
/// Tx buffer empty interrupt
TXEIE: u1 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register 2
pub const CR2 = Register(CR2_val).init(base_address + 0x4);

/// SR
const SR_val = packed struct {
/// RXNE [0:0]
/// Receive buffer not empty
RXNE: u1 = 0,
/// TXE [1:1]
/// Transmit buffer empty
TXE: u1 = 1,
/// CHSIDE [2:2]
/// Channel side
CHSIDE: u1 = 0,
/// UDR [3:3]
/// Underrun flag
UDR: u1 = 0,
/// CRCERR [4:4]
/// CRC error flag
CRCERR: u1 = 0,
/// MODF [5:5]
/// Mode fault
MODF: u1 = 0,
/// OVR [6:6]
/// Overrun flag
OVR: u1 = 0,
/// BSY [7:7]
/// Busy flag
BSY: u1 = 0,
/// TIFRFE [8:8]
/// TI frame format error
TIFRFE: u1 = 0,
/// unused [9:31]
_unused9: u7 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// status register
pub const SR = Register(SR_val).init(base_address + 0x8);

/// DR
const DR_val = packed struct {
/// DR [0:15]
/// Data register
DR: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// data register
pub const DR = Register(DR_val).init(base_address + 0xc);

/// CRCPR
const CRCPR_val = packed struct {
/// CRCPOLY [0:15]
/// CRC polynomial register
CRCPOLY: u16 = 7,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// CRC polynomial register
pub const CRCPR = Register(CRCPR_val).init(base_address + 0x10);

/// RXCRCR
const RXCRCR_val = packed struct {
/// RxCRC [0:15]
/// Rx CRC register
RxCRC: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// RX CRC register
pub const RXCRCR = Register(RXCRCR_val).init(base_address + 0x14);

/// TXCRCR
const TXCRCR_val = packed struct {
/// TxCRC [0:15]
/// Tx CRC register
TxCRC: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// TX CRC register
pub const TXCRCR = Register(TXCRCR_val).init(base_address + 0x18);

/// I2SCFGR
const I2SCFGR_val = packed struct {
/// CHLEN [0:0]
/// Channel length (number of bits per audio
CHLEN: u1 = 0,
/// DATLEN [1:2]
/// Data length to be
DATLEN: u2 = 0,
/// CKPOL [3:3]
/// Steady state clock
CKPOL: u1 = 0,
/// I2SSTD [4:5]
/// I2S standard selection
I2SSTD: u2 = 0,
/// unused [6:6]
_unused6: u1 = 0,
/// PCMSYNC [7:7]
/// PCM frame synchronization
PCMSYNC: u1 = 0,
/// I2SCFG [8:9]
/// I2S configuration mode
I2SCFG: u2 = 0,
/// I2SE [10:10]
/// I2S Enable
I2SE: u1 = 0,
/// I2SMOD [11:11]
/// I2S mode selection
I2SMOD: u1 = 0,
/// unused [12:31]
_unused12: u4 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// I2S configuration register
pub const I2SCFGR = Register(I2SCFGR_val).init(base_address + 0x1c);

/// I2SPR
const I2SPR_val = packed struct {
/// I2SDIV [0:7]
/// I2S Linear prescaler
I2SDIV: u8 = 16,
/// ODD [8:8]
/// Odd factor for the
ODD: u1 = 0,
/// MCKOE [9:9]
/// Master clock output enable
MCKOE: u1 = 0,
/// unused [10:31]
_unused10: u6 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// I2S prescaler register
pub const I2SPR = Register(I2SPR_val).init(base_address + 0x20);
};

/// Serial peripheral interface
pub const SPI2 = struct {

const base_address = 0x40003800;
/// CR1
const CR1_val = packed struct {
/// CPHA [0:0]
/// Clock phase
CPHA: u1 = 0,
/// CPOL [1:1]
/// Clock polarity
CPOL: u1 = 0,
/// MSTR [2:2]
/// Master selection
MSTR: u1 = 0,
/// BR [3:5]
/// Baud rate control
BR: u3 = 0,
/// SPE [6:6]
/// SPI enable
SPE: u1 = 0,
/// LSBFIRST [7:7]
/// Frame format
LSBFIRST: u1 = 0,
/// SSI [8:8]
/// Internal slave select
SSI: u1 = 0,
/// SSM [9:9]
/// Software slave management
SSM: u1 = 0,
/// RXONLY [10:10]
/// Receive only
RXONLY: u1 = 0,
/// DFF [11:11]
/// Data frame format
DFF: u1 = 0,
/// CRCNEXT [12:12]
/// CRC transfer next
CRCNEXT: u1 = 0,
/// CRCEN [13:13]
/// Hardware CRC calculation
CRCEN: u1 = 0,
/// BIDIOE [14:14]
/// Output enable in bidirectional
BIDIOE: u1 = 0,
/// BIDIMODE [15:15]
/// Bidirectional data mode
BIDIMODE: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register 1
pub const CR1 = Register(CR1_val).init(base_address + 0x0);

/// CR2
const CR2_val = packed struct {
/// RXDMAEN [0:0]
/// Rx buffer DMA enable
RXDMAEN: u1 = 0,
/// TXDMAEN [1:1]
/// Tx buffer DMA enable
TXDMAEN: u1 = 0,
/// SSOE [2:2]
/// SS output enable
SSOE: u1 = 0,
/// unused [3:3]
_unused3: u1 = 0,
/// FRF [4:4]
/// Frame format
FRF: u1 = 0,
/// ERRIE [5:5]
/// Error interrupt enable
ERRIE: u1 = 0,
/// RXNEIE [6:6]
/// RX buffer not empty interrupt
RXNEIE: u1 = 0,
/// TXEIE [7:7]
/// Tx buffer empty interrupt
TXEIE: u1 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register 2
pub const CR2 = Register(CR2_val).init(base_address + 0x4);

/// SR
const SR_val = packed struct {
/// RXNE [0:0]
/// Receive buffer not empty
RXNE: u1 = 0,
/// TXE [1:1]
/// Transmit buffer empty
TXE: u1 = 1,
/// CHSIDE [2:2]
/// Channel side
CHSIDE: u1 = 0,
/// UDR [3:3]
/// Underrun flag
UDR: u1 = 0,
/// CRCERR [4:4]
/// CRC error flag
CRCERR: u1 = 0,
/// MODF [5:5]
/// Mode fault
MODF: u1 = 0,
/// OVR [6:6]
/// Overrun flag
OVR: u1 = 0,
/// BSY [7:7]
/// Busy flag
BSY: u1 = 0,
/// TIFRFE [8:8]
/// TI frame format error
TIFRFE: u1 = 0,
/// unused [9:31]
_unused9: u7 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// status register
pub const SR = Register(SR_val).init(base_address + 0x8);

/// DR
const DR_val = packed struct {
/// DR [0:15]
/// Data register
DR: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// data register
pub const DR = Register(DR_val).init(base_address + 0xc);

/// CRCPR
const CRCPR_val = packed struct {
/// CRCPOLY [0:15]
/// CRC polynomial register
CRCPOLY: u16 = 7,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// CRC polynomial register
pub const CRCPR = Register(CRCPR_val).init(base_address + 0x10);

/// RXCRCR
const RXCRCR_val = packed struct {
/// RxCRC [0:15]
/// Rx CRC register
RxCRC: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// RX CRC register
pub const RXCRCR = Register(RXCRCR_val).init(base_address + 0x14);

/// TXCRCR
const TXCRCR_val = packed struct {
/// TxCRC [0:15]
/// Tx CRC register
TxCRC: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// TX CRC register
pub const TXCRCR = Register(TXCRCR_val).init(base_address + 0x18);

/// I2SCFGR
const I2SCFGR_val = packed struct {
/// CHLEN [0:0]
/// Channel length (number of bits per audio
CHLEN: u1 = 0,
/// DATLEN [1:2]
/// Data length to be
DATLEN: u2 = 0,
/// CKPOL [3:3]
/// Steady state clock
CKPOL: u1 = 0,
/// I2SSTD [4:5]
/// I2S standard selection
I2SSTD: u2 = 0,
/// unused [6:6]
_unused6: u1 = 0,
/// PCMSYNC [7:7]
/// PCM frame synchronization
PCMSYNC: u1 = 0,
/// I2SCFG [8:9]
/// I2S configuration mode
I2SCFG: u2 = 0,
/// I2SE [10:10]
/// I2S Enable
I2SE: u1 = 0,
/// I2SMOD [11:11]
/// I2S mode selection
I2SMOD: u1 = 0,
/// unused [12:31]
_unused12: u4 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// I2S configuration register
pub const I2SCFGR = Register(I2SCFGR_val).init(base_address + 0x1c);

/// I2SPR
const I2SPR_val = packed struct {
/// I2SDIV [0:7]
/// I2S Linear prescaler
I2SDIV: u8 = 16,
/// ODD [8:8]
/// Odd factor for the
ODD: u1 = 0,
/// MCKOE [9:9]
/// Master clock output enable
MCKOE: u1 = 0,
/// unused [10:31]
_unused10: u6 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// I2S prescaler register
pub const I2SPR = Register(I2SPR_val).init(base_address + 0x20);
};

/// Inter-integrated circuit
pub const I2C1 = struct {

const base_address = 0x40005400;
/// CR1
const CR1_val = packed struct {
/// PE [0:0]
/// Peripheral enable
PE: u1 = 0,
/// TXIE [1:1]
/// TX Interrupt enable
TXIE: u1 = 0,
/// RXIE [2:2]
/// RX Interrupt enable
RXIE: u1 = 0,
/// ADDRIE [3:3]
/// Address match interrupt enable (slave
ADDRIE: u1 = 0,
/// NACKIE [4:4]
/// Not acknowledge received interrupt
NACKIE: u1 = 0,
/// STOPIE [5:5]
/// STOP detection Interrupt
STOPIE: u1 = 0,
/// TCIE [6:6]
/// Transfer Complete interrupt
TCIE: u1 = 0,
/// ERRIE [7:7]
/// Error interrupts enable
ERRIE: u1 = 0,
/// DNF [8:11]
/// Digital noise filter
DNF: u4 = 0,
/// ANFOFF [12:12]
/// Analog noise filter OFF
ANFOFF: u1 = 0,
/// unused [13:13]
_unused13: u1 = 0,
/// TXDMAEN [14:14]
/// DMA transmission requests
TXDMAEN: u1 = 0,
/// RXDMAEN [15:15]
/// DMA reception requests
RXDMAEN: u1 = 0,
/// SBC [16:16]
/// Slave byte control
SBC: u1 = 0,
/// NOSTRETCH [17:17]
/// Clock stretching disable
NOSTRETCH: u1 = 0,
/// WUPEN [18:18]
/// Wakeup from STOP enable
WUPEN: u1 = 0,
/// GCEN [19:19]
/// General call enable
GCEN: u1 = 0,
/// SMBHEN [20:20]
/// SMBus Host address enable
SMBHEN: u1 = 0,
/// SMBDEN [21:21]
/// SMBus Device Default address
SMBDEN: u1 = 0,
/// ALERTEN [22:22]
/// SMBUS alert enable
ALERTEN: u1 = 0,
/// PECEN [23:23]
/// PEC enable
PECEN: u1 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// Control register 1
pub const CR1 = Register(CR1_val).init(base_address + 0x0);

/// CR2
const CR2_val = packed struct {
/// SADD [0:9]
/// Slave address bit (master
SADD: u10 = 0,
/// RD_WRN [10:10]
/// Transfer direction (master
RD_WRN: u1 = 0,
/// ADD10 [11:11]
/// 10-bit addressing mode (master
ADD10: u1 = 0,
/// HEAD10R [12:12]
/// 10-bit address header only read
HEAD10R: u1 = 0,
/// START [13:13]
/// Start generation
START: u1 = 0,
/// STOP [14:14]
/// Stop generation (master
STOP: u1 = 0,
/// NACK [15:15]
/// NACK generation (slave
NACK: u1 = 0,
/// NBYTES [16:23]
/// Number of bytes
NBYTES: u8 = 0,
/// RELOAD [24:24]
/// NBYTES reload mode
RELOAD: u1 = 0,
/// AUTOEND [25:25]
/// Automatic end mode (master
AUTOEND: u1 = 0,
/// PECBYTE [26:26]
/// Packet error checking byte
PECBYTE: u1 = 0,
/// unused [27:31]
_unused27: u5 = 0,
};
/// Control register 2
pub const CR2 = Register(CR2_val).init(base_address + 0x4);

/// OAR1
const OAR1_val = packed struct {
/// OA1 [0:9]
/// Interface address
OA1: u10 = 0,
/// OA1MODE [10:10]
/// Own Address 1 10-bit mode
OA1MODE: u1 = 0,
/// unused [11:14]
_unused11: u4 = 0,
/// OA1EN [15:15]
/// Own Address 1 enable
OA1EN: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Own address register 1
pub const OAR1 = Register(OAR1_val).init(base_address + 0x8);

/// OAR2
const OAR2_val = packed struct {
/// unused [0:0]
_unused0: u1 = 0,
/// OA2 [1:7]
/// Interface address
OA2: u7 = 0,
/// OA2MSK [8:10]
/// Own Address 2 masks
OA2MSK: u3 = 0,
/// unused [11:14]
_unused11: u4 = 0,
/// OA2EN [15:15]
/// Own Address 2 enable
OA2EN: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Own address register 2
pub const OAR2 = Register(OAR2_val).init(base_address + 0xc);

/// TIMINGR
const TIMINGR_val = packed struct {
/// SCLL [0:7]
/// SCL low period (master
SCLL: u8 = 0,
/// SCLH [8:15]
/// SCL high period (master
SCLH: u8 = 0,
/// SDADEL [16:19]
/// Data hold time
SDADEL: u4 = 0,
/// SCLDEL [20:23]
/// Data setup time
SCLDEL: u4 = 0,
/// unused [24:27]
_unused24: u4 = 0,
/// PRESC [28:31]
/// Timing prescaler
PRESC: u4 = 0,
};
/// Timing register
pub const TIMINGR = Register(TIMINGR_val).init(base_address + 0x10);

/// TIMEOUTR
const TIMEOUTR_val = packed struct {
/// TIMEOUTA [0:11]
/// Bus timeout A
TIMEOUTA: u12 = 0,
/// TIDLE [12:12]
/// Idle clock timeout
TIDLE: u1 = 0,
/// unused [13:14]
_unused13: u2 = 0,
/// TIMOUTEN [15:15]
/// Clock timeout enable
TIMOUTEN: u1 = 0,
/// TIMEOUTB [16:27]
/// Bus timeout B
TIMEOUTB: u12 = 0,
/// unused [28:30]
_unused28: u3 = 0,
/// TEXTEN [31:31]
/// Extended clock timeout
TEXTEN: u1 = 0,
};
/// Status register 1
pub const TIMEOUTR = Register(TIMEOUTR_val).init(base_address + 0x14);

/// ISR
const ISR_val = packed struct {
/// TXE [0:0]
/// Transmit data register empty
TXE: u1 = 1,
/// TXIS [1:1]
/// Transmit interrupt status
TXIS: u1 = 0,
/// RXNE [2:2]
/// Receive data register not empty
RXNE: u1 = 0,
/// ADDR [3:3]
/// Address matched (slave
ADDR: u1 = 0,
/// NACKF [4:4]
/// Not acknowledge received
NACKF: u1 = 0,
/// STOPF [5:5]
/// Stop detection flag
STOPF: u1 = 0,
/// TC [6:6]
/// Transfer Complete (master
TC: u1 = 0,
/// TCR [7:7]
/// Transfer Complete Reload
TCR: u1 = 0,
/// BERR [8:8]
/// Bus error
BERR: u1 = 0,
/// ARLO [9:9]
/// Arbitration lost
ARLO: u1 = 0,
/// OVR [10:10]
/// Overrun/Underrun (slave
OVR: u1 = 0,
/// PECERR [11:11]
/// PEC Error in reception
PECERR: u1 = 0,
/// TIMEOUT [12:12]
/// Timeout or t_low detection
TIMEOUT: u1 = 0,
/// ALERT [13:13]
/// SMBus alert
ALERT: u1 = 0,
/// unused [14:14]
_unused14: u1 = 0,
/// BUSY [15:15]
/// Bus busy
BUSY: u1 = 0,
/// DIR [16:16]
/// Transfer direction (Slave
DIR: u1 = 0,
/// ADDCODE [17:23]
/// Address match code (Slave
ADDCODE: u7 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// Interrupt and Status register
pub const ISR = Register(ISR_val).init(base_address + 0x18);

/// ICR
const ICR_val = packed struct {
/// unused [0:2]
_unused0: u3 = 0,
/// ADDRCF [3:3]
/// Address Matched flag clear
ADDRCF: u1 = 0,
/// NACKCF [4:4]
/// Not Acknowledge flag clear
NACKCF: u1 = 0,
/// STOPCF [5:5]
/// Stop detection flag clear
STOPCF: u1 = 0,
/// unused [6:7]
_unused6: u2 = 0,
/// BERRCF [8:8]
/// Bus error flag clear
BERRCF: u1 = 0,
/// ARLOCF [9:9]
/// Arbitration lost flag
ARLOCF: u1 = 0,
/// OVRCF [10:10]
/// Overrun/Underrun flag
OVRCF: u1 = 0,
/// PECCF [11:11]
/// PEC Error flag clear
PECCF: u1 = 0,
/// TIMOUTCF [12:12]
/// Timeout detection flag
TIMOUTCF: u1 = 0,
/// ALERTCF [13:13]
/// Alert flag clear
ALERTCF: u1 = 0,
/// unused [14:31]
_unused14: u2 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Interrupt clear register
pub const ICR = Register(ICR_val).init(base_address + 0x1c);

/// PECR
const PECR_val = packed struct {
/// PEC [0:7]
/// Packet error checking
PEC: u8 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// PEC register
pub const PECR = Register(PECR_val).init(base_address + 0x20);

/// RXDR
const RXDR_val = packed struct {
/// RXDATA [0:7]
/// 8-bit receive data
RXDATA: u8 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Receive data register
pub const RXDR = Register(RXDR_val).init(base_address + 0x24);

/// TXDR
const TXDR_val = packed struct {
/// TXDATA [0:7]
/// 8-bit transmit data
TXDATA: u8 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Transmit data register
pub const TXDR = Register(TXDR_val).init(base_address + 0x28);
};

/// Inter-integrated circuit
pub const I2C2 = struct {

const base_address = 0x40005800;
/// CR1
const CR1_val = packed struct {
/// PE [0:0]
/// Peripheral enable
PE: u1 = 0,
/// TXIE [1:1]
/// TX Interrupt enable
TXIE: u1 = 0,
/// RXIE [2:2]
/// RX Interrupt enable
RXIE: u1 = 0,
/// ADDRIE [3:3]
/// Address match interrupt enable (slave
ADDRIE: u1 = 0,
/// NACKIE [4:4]
/// Not acknowledge received interrupt
NACKIE: u1 = 0,
/// STOPIE [5:5]
/// STOP detection Interrupt
STOPIE: u1 = 0,
/// TCIE [6:6]
/// Transfer Complete interrupt
TCIE: u1 = 0,
/// ERRIE [7:7]
/// Error interrupts enable
ERRIE: u1 = 0,
/// DNF [8:11]
/// Digital noise filter
DNF: u4 = 0,
/// ANFOFF [12:12]
/// Analog noise filter OFF
ANFOFF: u1 = 0,
/// unused [13:13]
_unused13: u1 = 0,
/// TXDMAEN [14:14]
/// DMA transmission requests
TXDMAEN: u1 = 0,
/// RXDMAEN [15:15]
/// DMA reception requests
RXDMAEN: u1 = 0,
/// SBC [16:16]
/// Slave byte control
SBC: u1 = 0,
/// NOSTRETCH [17:17]
/// Clock stretching disable
NOSTRETCH: u1 = 0,
/// WUPEN [18:18]
/// Wakeup from STOP enable
WUPEN: u1 = 0,
/// GCEN [19:19]
/// General call enable
GCEN: u1 = 0,
/// SMBHEN [20:20]
/// SMBus Host address enable
SMBHEN: u1 = 0,
/// SMBDEN [21:21]
/// SMBus Device Default address
SMBDEN: u1 = 0,
/// ALERTEN [22:22]
/// SMBUS alert enable
ALERTEN: u1 = 0,
/// PECEN [23:23]
/// PEC enable
PECEN: u1 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// Control register 1
pub const CR1 = Register(CR1_val).init(base_address + 0x0);

/// CR2
const CR2_val = packed struct {
/// SADD [0:9]
/// Slave address bit (master
SADD: u10 = 0,
/// RD_WRN [10:10]
/// Transfer direction (master
RD_WRN: u1 = 0,
/// ADD10 [11:11]
/// 10-bit addressing mode (master
ADD10: u1 = 0,
/// HEAD10R [12:12]
/// 10-bit address header only read
HEAD10R: u1 = 0,
/// START [13:13]
/// Start generation
START: u1 = 0,
/// STOP [14:14]
/// Stop generation (master
STOP: u1 = 0,
/// NACK [15:15]
/// NACK generation (slave
NACK: u1 = 0,
/// NBYTES [16:23]
/// Number of bytes
NBYTES: u8 = 0,
/// RELOAD [24:24]
/// NBYTES reload mode
RELOAD: u1 = 0,
/// AUTOEND [25:25]
/// Automatic end mode (master
AUTOEND: u1 = 0,
/// PECBYTE [26:26]
/// Packet error checking byte
PECBYTE: u1 = 0,
/// unused [27:31]
_unused27: u5 = 0,
};
/// Control register 2
pub const CR2 = Register(CR2_val).init(base_address + 0x4);

/// OAR1
const OAR1_val = packed struct {
/// OA1 [0:9]
/// Interface address
OA1: u10 = 0,
/// OA1MODE [10:10]
/// Own Address 1 10-bit mode
OA1MODE: u1 = 0,
/// unused [11:14]
_unused11: u4 = 0,
/// OA1EN [15:15]
/// Own Address 1 enable
OA1EN: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Own address register 1
pub const OAR1 = Register(OAR1_val).init(base_address + 0x8);

/// OAR2
const OAR2_val = packed struct {
/// unused [0:0]
_unused0: u1 = 0,
/// OA2 [1:7]
/// Interface address
OA2: u7 = 0,
/// OA2MSK [8:10]
/// Own Address 2 masks
OA2MSK: u3 = 0,
/// unused [11:14]
_unused11: u4 = 0,
/// OA2EN [15:15]
/// Own Address 2 enable
OA2EN: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Own address register 2
pub const OAR2 = Register(OAR2_val).init(base_address + 0xc);

/// TIMINGR
const TIMINGR_val = packed struct {
/// SCLL [0:7]
/// SCL low period (master
SCLL: u8 = 0,
/// SCLH [8:15]
/// SCL high period (master
SCLH: u8 = 0,
/// SDADEL [16:19]
/// Data hold time
SDADEL: u4 = 0,
/// SCLDEL [20:23]
/// Data setup time
SCLDEL: u4 = 0,
/// unused [24:27]
_unused24: u4 = 0,
/// PRESC [28:31]
/// Timing prescaler
PRESC: u4 = 0,
};
/// Timing register
pub const TIMINGR = Register(TIMINGR_val).init(base_address + 0x10);

/// TIMEOUTR
const TIMEOUTR_val = packed struct {
/// TIMEOUTA [0:11]
/// Bus timeout A
TIMEOUTA: u12 = 0,
/// TIDLE [12:12]
/// Idle clock timeout
TIDLE: u1 = 0,
/// unused [13:14]
_unused13: u2 = 0,
/// TIMOUTEN [15:15]
/// Clock timeout enable
TIMOUTEN: u1 = 0,
/// TIMEOUTB [16:27]
/// Bus timeout B
TIMEOUTB: u12 = 0,
/// unused [28:30]
_unused28: u3 = 0,
/// TEXTEN [31:31]
/// Extended clock timeout
TEXTEN: u1 = 0,
};
/// Status register 1
pub const TIMEOUTR = Register(TIMEOUTR_val).init(base_address + 0x14);

/// ISR
const ISR_val = packed struct {
/// TXE [0:0]
/// Transmit data register empty
TXE: u1 = 1,
/// TXIS [1:1]
/// Transmit interrupt status
TXIS: u1 = 0,
/// RXNE [2:2]
/// Receive data register not empty
RXNE: u1 = 0,
/// ADDR [3:3]
/// Address matched (slave
ADDR: u1 = 0,
/// NACKF [4:4]
/// Not acknowledge received
NACKF: u1 = 0,
/// STOPF [5:5]
/// Stop detection flag
STOPF: u1 = 0,
/// TC [6:6]
/// Transfer Complete (master
TC: u1 = 0,
/// TCR [7:7]
/// Transfer Complete Reload
TCR: u1 = 0,
/// BERR [8:8]
/// Bus error
BERR: u1 = 0,
/// ARLO [9:9]
/// Arbitration lost
ARLO: u1 = 0,
/// OVR [10:10]
/// Overrun/Underrun (slave
OVR: u1 = 0,
/// PECERR [11:11]
/// PEC Error in reception
PECERR: u1 = 0,
/// TIMEOUT [12:12]
/// Timeout or t_low detection
TIMEOUT: u1 = 0,
/// ALERT [13:13]
/// SMBus alert
ALERT: u1 = 0,
/// unused [14:14]
_unused14: u1 = 0,
/// BUSY [15:15]
/// Bus busy
BUSY: u1 = 0,
/// DIR [16:16]
/// Transfer direction (Slave
DIR: u1 = 0,
/// ADDCODE [17:23]
/// Address match code (Slave
ADDCODE: u7 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// Interrupt and Status register
pub const ISR = Register(ISR_val).init(base_address + 0x18);

/// ICR
const ICR_val = packed struct {
/// unused [0:2]
_unused0: u3 = 0,
/// ADDRCF [3:3]
/// Address Matched flag clear
ADDRCF: u1 = 0,
/// NACKCF [4:4]
/// Not Acknowledge flag clear
NACKCF: u1 = 0,
/// STOPCF [5:5]
/// Stop detection flag clear
STOPCF: u1 = 0,
/// unused [6:7]
_unused6: u2 = 0,
/// BERRCF [8:8]
/// Bus error flag clear
BERRCF: u1 = 0,
/// ARLOCF [9:9]
/// Arbitration lost flag
ARLOCF: u1 = 0,
/// OVRCF [10:10]
/// Overrun/Underrun flag
OVRCF: u1 = 0,
/// PECCF [11:11]
/// PEC Error flag clear
PECCF: u1 = 0,
/// TIMOUTCF [12:12]
/// Timeout detection flag
TIMOUTCF: u1 = 0,
/// ALERTCF [13:13]
/// Alert flag clear
ALERTCF: u1 = 0,
/// unused [14:31]
_unused14: u2 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Interrupt clear register
pub const ICR = Register(ICR_val).init(base_address + 0x1c);

/// PECR
const PECR_val = packed struct {
/// PEC [0:7]
/// Packet error checking
PEC: u8 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// PEC register
pub const PECR = Register(PECR_val).init(base_address + 0x20);

/// RXDR
const RXDR_val = packed struct {
/// RXDATA [0:7]
/// 8-bit receive data
RXDATA: u8 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Receive data register
pub const RXDR = Register(RXDR_val).init(base_address + 0x24);

/// TXDR
const TXDR_val = packed struct {
/// TXDATA [0:7]
/// 8-bit transmit data
TXDATA: u8 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Transmit data register
pub const TXDR = Register(TXDR_val).init(base_address + 0x28);
};

/// Inter-integrated circuit
pub const I2C3 = struct {

const base_address = 0x40007800;
/// CR1
const CR1_val = packed struct {
/// PE [0:0]
/// Peripheral enable
PE: u1 = 0,
/// TXIE [1:1]
/// TX Interrupt enable
TXIE: u1 = 0,
/// RXIE [2:2]
/// RX Interrupt enable
RXIE: u1 = 0,
/// ADDRIE [3:3]
/// Address match interrupt enable (slave
ADDRIE: u1 = 0,
/// NACKIE [4:4]
/// Not acknowledge received interrupt
NACKIE: u1 = 0,
/// STOPIE [5:5]
/// STOP detection Interrupt
STOPIE: u1 = 0,
/// TCIE [6:6]
/// Transfer Complete interrupt
TCIE: u1 = 0,
/// ERRIE [7:7]
/// Error interrupts enable
ERRIE: u1 = 0,
/// DNF [8:11]
/// Digital noise filter
DNF: u4 = 0,
/// ANFOFF [12:12]
/// Analog noise filter OFF
ANFOFF: u1 = 0,
/// unused [13:13]
_unused13: u1 = 0,
/// TXDMAEN [14:14]
/// DMA transmission requests
TXDMAEN: u1 = 0,
/// RXDMAEN [15:15]
/// DMA reception requests
RXDMAEN: u1 = 0,
/// SBC [16:16]
/// Slave byte control
SBC: u1 = 0,
/// NOSTRETCH [17:17]
/// Clock stretching disable
NOSTRETCH: u1 = 0,
/// WUPEN [18:18]
/// Wakeup from STOP enable
WUPEN: u1 = 0,
/// GCEN [19:19]
/// General call enable
GCEN: u1 = 0,
/// SMBHEN [20:20]
/// SMBus Host address enable
SMBHEN: u1 = 0,
/// SMBDEN [21:21]
/// SMBus Device Default address
SMBDEN: u1 = 0,
/// ALERTEN [22:22]
/// SMBUS alert enable
ALERTEN: u1 = 0,
/// PECEN [23:23]
/// PEC enable
PECEN: u1 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// Control register 1
pub const CR1 = Register(CR1_val).init(base_address + 0x0);

/// CR2
const CR2_val = packed struct {
/// SADD [0:9]
/// Slave address bit (master
SADD: u10 = 0,
/// RD_WRN [10:10]
/// Transfer direction (master
RD_WRN: u1 = 0,
/// ADD10 [11:11]
/// 10-bit addressing mode (master
ADD10: u1 = 0,
/// HEAD10R [12:12]
/// 10-bit address header only read
HEAD10R: u1 = 0,
/// START [13:13]
/// Start generation
START: u1 = 0,
/// STOP [14:14]
/// Stop generation (master
STOP: u1 = 0,
/// NACK [15:15]
/// NACK generation (slave
NACK: u1 = 0,
/// NBYTES [16:23]
/// Number of bytes
NBYTES: u8 = 0,
/// RELOAD [24:24]
/// NBYTES reload mode
RELOAD: u1 = 0,
/// AUTOEND [25:25]
/// Automatic end mode (master
AUTOEND: u1 = 0,
/// PECBYTE [26:26]
/// Packet error checking byte
PECBYTE: u1 = 0,
/// unused [27:31]
_unused27: u5 = 0,
};
/// Control register 2
pub const CR2 = Register(CR2_val).init(base_address + 0x4);

/// OAR1
const OAR1_val = packed struct {
/// OA1 [0:9]
/// Interface address
OA1: u10 = 0,
/// OA1MODE [10:10]
/// Own Address 1 10-bit mode
OA1MODE: u1 = 0,
/// unused [11:14]
_unused11: u4 = 0,
/// OA1EN [15:15]
/// Own Address 1 enable
OA1EN: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Own address register 1
pub const OAR1 = Register(OAR1_val).init(base_address + 0x8);

/// OAR2
const OAR2_val = packed struct {
/// unused [0:0]
_unused0: u1 = 0,
/// OA2 [1:7]
/// Interface address
OA2: u7 = 0,
/// OA2MSK [8:10]
/// Own Address 2 masks
OA2MSK: u3 = 0,
/// unused [11:14]
_unused11: u4 = 0,
/// OA2EN [15:15]
/// Own Address 2 enable
OA2EN: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Own address register 2
pub const OAR2 = Register(OAR2_val).init(base_address + 0xc);

/// TIMINGR
const TIMINGR_val = packed struct {
/// SCLL [0:7]
/// SCL low period (master
SCLL: u8 = 0,
/// SCLH [8:15]
/// SCL high period (master
SCLH: u8 = 0,
/// SDADEL [16:19]
/// Data hold time
SDADEL: u4 = 0,
/// SCLDEL [20:23]
/// Data setup time
SCLDEL: u4 = 0,
/// unused [24:27]
_unused24: u4 = 0,
/// PRESC [28:31]
/// Timing prescaler
PRESC: u4 = 0,
};
/// Timing register
pub const TIMINGR = Register(TIMINGR_val).init(base_address + 0x10);

/// TIMEOUTR
const TIMEOUTR_val = packed struct {
/// TIMEOUTA [0:11]
/// Bus timeout A
TIMEOUTA: u12 = 0,
/// TIDLE [12:12]
/// Idle clock timeout
TIDLE: u1 = 0,
/// unused [13:14]
_unused13: u2 = 0,
/// TIMOUTEN [15:15]
/// Clock timeout enable
TIMOUTEN: u1 = 0,
/// TIMEOUTB [16:27]
/// Bus timeout B
TIMEOUTB: u12 = 0,
/// unused [28:30]
_unused28: u3 = 0,
/// TEXTEN [31:31]
/// Extended clock timeout
TEXTEN: u1 = 0,
};
/// Status register 1
pub const TIMEOUTR = Register(TIMEOUTR_val).init(base_address + 0x14);

/// ISR
const ISR_val = packed struct {
/// TXE [0:0]
/// Transmit data register empty
TXE: u1 = 1,
/// TXIS [1:1]
/// Transmit interrupt status
TXIS: u1 = 0,
/// RXNE [2:2]
/// Receive data register not empty
RXNE: u1 = 0,
/// ADDR [3:3]
/// Address matched (slave
ADDR: u1 = 0,
/// NACKF [4:4]
/// Not acknowledge received
NACKF: u1 = 0,
/// STOPF [5:5]
/// Stop detection flag
STOPF: u1 = 0,
/// TC [6:6]
/// Transfer Complete (master
TC: u1 = 0,
/// TCR [7:7]
/// Transfer Complete Reload
TCR: u1 = 0,
/// BERR [8:8]
/// Bus error
BERR: u1 = 0,
/// ARLO [9:9]
/// Arbitration lost
ARLO: u1 = 0,
/// OVR [10:10]
/// Overrun/Underrun (slave
OVR: u1 = 0,
/// PECERR [11:11]
/// PEC Error in reception
PECERR: u1 = 0,
/// TIMEOUT [12:12]
/// Timeout or t_low detection
TIMEOUT: u1 = 0,
/// ALERT [13:13]
/// SMBus alert
ALERT: u1 = 0,
/// unused [14:14]
_unused14: u1 = 0,
/// BUSY [15:15]
/// Bus busy
BUSY: u1 = 0,
/// DIR [16:16]
/// Transfer direction (Slave
DIR: u1 = 0,
/// ADDCODE [17:23]
/// Address match code (Slave
ADDCODE: u7 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// Interrupt and Status register
pub const ISR = Register(ISR_val).init(base_address + 0x18);

/// ICR
const ICR_val = packed struct {
/// unused [0:2]
_unused0: u3 = 0,
/// ADDRCF [3:3]
/// Address Matched flag clear
ADDRCF: u1 = 0,
/// NACKCF [4:4]
/// Not Acknowledge flag clear
NACKCF: u1 = 0,
/// STOPCF [5:5]
/// Stop detection flag clear
STOPCF: u1 = 0,
/// unused [6:7]
_unused6: u2 = 0,
/// BERRCF [8:8]
/// Bus error flag clear
BERRCF: u1 = 0,
/// ARLOCF [9:9]
/// Arbitration lost flag
ARLOCF: u1 = 0,
/// OVRCF [10:10]
/// Overrun/Underrun flag
OVRCF: u1 = 0,
/// PECCF [11:11]
/// PEC Error flag clear
PECCF: u1 = 0,
/// TIMOUTCF [12:12]
/// Timeout detection flag
TIMOUTCF: u1 = 0,
/// ALERTCF [13:13]
/// Alert flag clear
ALERTCF: u1 = 0,
/// unused [14:31]
_unused14: u2 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Interrupt clear register
pub const ICR = Register(ICR_val).init(base_address + 0x1c);

/// PECR
const PECR_val = packed struct {
/// PEC [0:7]
/// Packet error checking
PEC: u8 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// PEC register
pub const PECR = Register(PECR_val).init(base_address + 0x20);

/// RXDR
const RXDR_val = packed struct {
/// RXDATA [0:7]
/// 8-bit receive data
RXDATA: u8 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Receive data register
pub const RXDR = Register(RXDR_val).init(base_address + 0x24);

/// TXDR
const TXDR_val = packed struct {
/// TXDATA [0:7]
/// 8-bit transmit data
TXDATA: u8 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Transmit data register
pub const TXDR = Register(TXDR_val).init(base_address + 0x28);
};

/// Power control
pub const PWR = struct {

const base_address = 0x40007000;
/// CR
const CR_val = packed struct {
/// LPDS [0:0]
/// Low-power deep sleep
LPDS: u1 = 0,
/// PDDS [1:1]
/// Power down deepsleep
PDDS: u1 = 0,
/// CWUF [2:2]
/// Clear wakeup flag
CWUF: u1 = 0,
/// CSBF [3:3]
/// Clear standby flag
CSBF: u1 = 0,
/// PVDE [4:4]
/// Power voltage detector
PVDE: u1 = 0,
/// PLS [5:7]
/// PVD level selection
PLS: u3 = 0,
/// DBP [8:8]
/// Disable backup domain write
DBP: u1 = 0,
/// ULP [9:9]
/// Ultra-low-power mode
ULP: u1 = 0,
/// FWU [10:10]
/// Fast wakeup
FWU: u1 = 0,
/// VOS [11:12]
/// Voltage scaling range
VOS: u2 = 2,
/// DS_EE_KOFF [13:13]
/// Deep sleep mode with Flash memory kept
DS_EE_KOFF: u1 = 0,
/// LPRUN [14:14]
/// Low power run mode
LPRUN: u1 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// power control register
pub const CR = Register(CR_val).init(base_address + 0x0);

/// CSR
const CSR_val = packed struct {
/// WUF [0:0]
/// Wakeup flag
WUF: u1 = 0,
/// SBF [1:1]
/// Standby flag
SBF: u1 = 0,
/// PVDO [2:2]
/// PVD output
PVDO: u1 = 0,
/// BRR [3:3]
/// Backup regulator ready
BRR: u1 = 0,
/// VOSF [4:4]
/// Voltage Scaling select
VOSF: u1 = 0,
/// REGLPF [5:5]
/// Regulator LP flag
REGLPF: u1 = 0,
/// unused [6:7]
_unused6: u2 = 0,
/// EWUP [8:8]
/// Enable WKUP pin
EWUP: u1 = 0,
/// BRE [9:9]
/// Backup regulator enable
BRE: u1 = 0,
/// unused [10:31]
_unused10: u6 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// power control/status register
pub const CSR = Register(CSR_val).init(base_address + 0x4);
};

/// Flash
pub const Flash = struct {

const base_address = 0x40022000;
/// ACR
const ACR_val = packed struct {
/// LATENCY [0:0]
/// Latency
LATENCY: u1 = 0,
/// PRFTEN [1:1]
/// Prefetch enable
PRFTEN: u1 = 0,
/// unused [2:2]
_unused2: u1 = 0,
/// SLEEP_PD [3:3]
/// Flash mode during Sleep
SLEEP_PD: u1 = 0,
/// RUN_PD [4:4]
/// Flash mode during Run
RUN_PD: u1 = 0,
/// DESAB_BUF [5:5]
/// Disable Buffer
DESAB_BUF: u1 = 0,
/// PRE_READ [6:6]
/// Pre-read data address
PRE_READ: u1 = 0,
/// unused [7:31]
_unused7: u1 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Access control register
pub const ACR = Register(ACR_val).init(base_address + 0x0);

/// PECR
const PECR_val = packed struct {
/// PELOCK [0:0]
/// FLASH_PECR and data EEPROM
PELOCK: u1 = 1,
/// PRGLOCK [1:1]
/// Program memory lock
PRGLOCK: u1 = 1,
/// OPTLOCK [2:2]
/// Option bytes block lock
OPTLOCK: u1 = 1,
/// PROG [3:3]
/// Program memory selection
PROG: u1 = 0,
/// DATA [4:4]
/// Data EEPROM selection
DATA: u1 = 0,
/// unused [5:7]
_unused5: u3 = 0,
/// FTDW [8:8]
/// Fixed time data write for Byte, Half
FTDW: u1 = 0,
/// ERASE [9:9]
/// Page or Double Word erase
ERASE: u1 = 0,
/// FPRG [10:10]
/// Half Page/Double Word programming
FPRG: u1 = 0,
/// unused [11:14]
_unused11: u4 = 0,
/// PARALLELBANK [15:15]
/// Parallel bank mode
PARALLELBANK: u1 = 0,
/// EOPIE [16:16]
/// End of programming interrupt
EOPIE: u1 = 0,
/// ERRIE [17:17]
/// Error interrupt enable
ERRIE: u1 = 0,
/// OBL_LAUNCH [18:18]
/// Launch the option byte
OBL_LAUNCH: u1 = 0,
/// unused [19:31]
_unused19: u5 = 0,
_unused24: u8 = 0,
};
/// Program/erase control register
pub const PECR = Register(PECR_val).init(base_address + 0x4);

/// PDKEYR
const PDKEYR_val = packed struct {
/// PDKEYR [0:31]
/// RUN_PD in FLASH_ACR key
PDKEYR: u32 = 0,
};
/// Power down key register
pub const PDKEYR = Register(PDKEYR_val).init(base_address + 0x8);

/// PEKEYR
const PEKEYR_val = packed struct {
/// PEKEYR [0:31]
/// FLASH_PEC and data EEPROM
PEKEYR: u32 = 0,
};
/// Program/erase key register
pub const PEKEYR = Register(PEKEYR_val).init(base_address + 0xc);

/// PRGKEYR
const PRGKEYR_val = packed struct {
/// PRGKEYR [0:31]
/// Program memory key
PRGKEYR: u32 = 0,
};
/// Program memory key register
pub const PRGKEYR = Register(PRGKEYR_val).init(base_address + 0x10);

/// OPTKEYR
const OPTKEYR_val = packed struct {
/// OPTKEYR [0:31]
/// Option byte key
OPTKEYR: u32 = 0,
};
/// Option byte key register
pub const OPTKEYR = Register(OPTKEYR_val).init(base_address + 0x14);

/// SR
const SR_val = packed struct {
/// BSY [0:0]
/// Write/erase operations in
BSY: u1 = 0,
/// EOP [1:1]
/// End of operation
EOP: u1 = 0,
/// ENDHV [2:2]
/// End of high voltage
ENDHV: u1 = 1,
/// READY [3:3]
/// Flash memory module ready after low
READY: u1 = 0,
/// unused [4:7]
_unused4: u4 = 0,
/// WRPERR [8:8]
/// Write protected error
WRPERR: u1 = 0,
/// PGAERR [9:9]
/// Programming alignment
PGAERR: u1 = 0,
/// SIZERR [10:10]
/// Size error
SIZERR: u1 = 0,
/// OPTVERR [11:11]
/// Option validity error
OPTVERR: u1 = 0,
/// unused [12:13]
_unused12: u2 = 0,
/// RDERR [14:14]
/// RDERR
RDERR: u1 = 0,
/// unused [15:15]
_unused15: u1 = 0,
/// NOTZEROERR [16:16]
/// NOTZEROERR
NOTZEROERR: u1 = 0,
/// FWWERR [17:17]
/// FWWERR
FWWERR: u1 = 0,
/// unused [18:31]
_unused18: u6 = 0,
_unused24: u8 = 0,
};
/// Status register
pub const SR = Register(SR_val).init(base_address + 0x18);

/// OBR
const OBR_val = packed struct {
/// RDPRT [0:7]
/// Read protection
RDPRT: u8 = 0,
/// SPRMOD [8:8]
/// Selection of protection mode of WPR
SPRMOD: u1 = 0,
/// unused [9:15]
_unused9: u7 = 0,
/// BOR_LEV [16:19]
/// BOR_LEV
BOR_LEV: u4 = 8,
/// unused [20:31]
_unused20: u4 = 15,
_unused24: u8 = 0,
};
/// Option byte register
pub const OBR = Register(OBR_val).init(base_address + 0x1c);

/// WRPR
const WRPR_val = packed struct {
/// WRP [0:15]
/// Write protection
WRP: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Write protection register
pub const WRPR = Register(WRPR_val).init(base_address + 0x20);
};

/// External interrupt/event
pub const EXTI = struct {

const base_address = 0x40010400;
/// IMR
const IMR_val = packed struct {
/// IM0 [0:0]
/// Interrupt Mask on line 0
IM0: u1 = 0,
/// IM1 [1:1]
/// Interrupt Mask on line 1
IM1: u1 = 0,
/// IM2 [2:2]
/// Interrupt Mask on line 2
IM2: u1 = 0,
/// IM3 [3:3]
/// Interrupt Mask on line 3
IM3: u1 = 0,
/// IM4 [4:4]
/// Interrupt Mask on line 4
IM4: u1 = 0,
/// IM5 [5:5]
/// Interrupt Mask on line 5
IM5: u1 = 0,
/// IM6 [6:6]
/// Interrupt Mask on line 6
IM6: u1 = 0,
/// IM7 [7:7]
/// Interrupt Mask on line 7
IM7: u1 = 0,
/// IM8 [8:8]
/// Interrupt Mask on line 8
IM8: u1 = 0,
/// IM9 [9:9]
/// Interrupt Mask on line 9
IM9: u1 = 0,
/// IM10 [10:10]
/// Interrupt Mask on line 10
IM10: u1 = 0,
/// IM11 [11:11]
/// Interrupt Mask on line 11
IM11: u1 = 0,
/// IM12 [12:12]
/// Interrupt Mask on line 12
IM12: u1 = 0,
/// IM13 [13:13]
/// Interrupt Mask on line 13
IM13: u1 = 0,
/// IM14 [14:14]
/// Interrupt Mask on line 14
IM14: u1 = 0,
/// IM15 [15:15]
/// Interrupt Mask on line 15
IM15: u1 = 0,
/// IM16 [16:16]
/// Interrupt Mask on line 16
IM16: u1 = 0,
/// IM17 [17:17]
/// Interrupt Mask on line 17
IM17: u1 = 0,
/// IM18 [18:18]
/// Interrupt Mask on line 18
IM18: u1 = 1,
/// IM19 [19:19]
/// Interrupt Mask on line 19
IM19: u1 = 0,
/// IM20 [20:20]
/// Interrupt Mask on line 20
IM20: u1 = 0,
/// IM21 [21:21]
/// Interrupt Mask on line 21
IM21: u1 = 0,
/// IM22 [22:22]
/// Interrupt Mask on line 22
IM22: u1 = 0,
/// IM23 [23:23]
/// Interrupt Mask on line 23
IM23: u1 = 1,
/// IM24 [24:24]
/// Interrupt Mask on line 24
IM24: u1 = 1,
/// IM25 [25:25]
/// Interrupt Mask on line 25
IM25: u1 = 1,
/// IM26 [26:26]
/// Interrupt Mask on line 27
IM26: u1 = 1,
/// unused [27:27]
_unused27: u1 = 1,
/// IM28 [28:28]
/// Interrupt Mask on line 27
IM28: u1 = 1,
/// IM29 [29:29]
/// Interrupt Mask on line 27
IM29: u1 = 1,
/// unused [30:31]
_unused30: u2 = 3,
};
/// Interrupt mask register
pub const IMR = Register(IMR_val).init(base_address + 0x0);

/// EMR
const EMR_val = packed struct {
/// EM0 [0:0]
/// Event Mask on line 0
EM0: u1 = 0,
/// EM1 [1:1]
/// Event Mask on line 1
EM1: u1 = 0,
/// EM2 [2:2]
/// Event Mask on line 2
EM2: u1 = 0,
/// EM3 [3:3]
/// Event Mask on line 3
EM3: u1 = 0,
/// EM4 [4:4]
/// Event Mask on line 4
EM4: u1 = 0,
/// EM5 [5:5]
/// Event Mask on line 5
EM5: u1 = 0,
/// EM6 [6:6]
/// Event Mask on line 6
EM6: u1 = 0,
/// EM7 [7:7]
/// Event Mask on line 7
EM7: u1 = 0,
/// EM8 [8:8]
/// Event Mask on line 8
EM8: u1 = 0,
/// EM9 [9:9]
/// Event Mask on line 9
EM9: u1 = 0,
/// EM10 [10:10]
/// Event Mask on line 10
EM10: u1 = 0,
/// EM11 [11:11]
/// Event Mask on line 11
EM11: u1 = 0,
/// EM12 [12:12]
/// Event Mask on line 12
EM12: u1 = 0,
/// EM13 [13:13]
/// Event Mask on line 13
EM13: u1 = 0,
/// EM14 [14:14]
/// Event Mask on line 14
EM14: u1 = 0,
/// EM15 [15:15]
/// Event Mask on line 15
EM15: u1 = 0,
/// EM16 [16:16]
/// Event Mask on line 16
EM16: u1 = 0,
/// EM17 [17:17]
/// Event Mask on line 17
EM17: u1 = 0,
/// EM18 [18:18]
/// Event Mask on line 18
EM18: u1 = 0,
/// EM19 [19:19]
/// Event Mask on line 19
EM19: u1 = 0,
/// EM20 [20:20]
/// Event Mask on line 20
EM20: u1 = 0,
/// EM21 [21:21]
/// Event Mask on line 21
EM21: u1 = 0,
/// EM22 [22:22]
/// Event Mask on line 22
EM22: u1 = 0,
/// EM23 [23:23]
/// Event Mask on line 23
EM23: u1 = 0,
/// EM24 [24:24]
/// Event Mask on line 24
EM24: u1 = 0,
/// EM25 [25:25]
/// Event Mask on line 25
EM25: u1 = 0,
/// EM26 [26:26]
/// Event Mask on line 26
EM26: u1 = 0,
/// unused [27:27]
_unused27: u1 = 0,
/// EM28 [28:28]
/// Event Mask on line 28
EM28: u1 = 0,
/// EM29 [29:29]
/// Event Mask on line 29
EM29: u1 = 0,
/// unused [30:31]
_unused30: u2 = 0,
};
/// Event mask register (EXTI_EMR)
pub const EMR = Register(EMR_val).init(base_address + 0x4);

/// RTSR
const RTSR_val = packed struct {
/// RT0 [0:0]
/// Rising trigger event configuration of
RT0: u1 = 0,
/// RT1 [1:1]
/// Rising trigger event configuration of
RT1: u1 = 0,
/// RT2 [2:2]
/// Rising trigger event configuration of
RT2: u1 = 0,
/// RT3 [3:3]
/// Rising trigger event configuration of
RT3: u1 = 0,
/// RT4 [4:4]
/// Rising trigger event configuration of
RT4: u1 = 0,
/// RT5 [5:5]
/// Rising trigger event configuration of
RT5: u1 = 0,
/// RT6 [6:6]
/// Rising trigger event configuration of
RT6: u1 = 0,
/// RT7 [7:7]
/// Rising trigger event configuration of
RT7: u1 = 0,
/// RT8 [8:8]
/// Rising trigger event configuration of
RT8: u1 = 0,
/// RT9 [9:9]
/// Rising trigger event configuration of
RT9: u1 = 0,
/// RT10 [10:10]
/// Rising trigger event configuration of
RT10: u1 = 0,
/// RT11 [11:11]
/// Rising trigger event configuration of
RT11: u1 = 0,
/// RT12 [12:12]
/// Rising trigger event configuration of
RT12: u1 = 0,
/// RT13 [13:13]
/// Rising trigger event configuration of
RT13: u1 = 0,
/// RT14 [14:14]
/// Rising trigger event configuration of
RT14: u1 = 0,
/// RT15 [15:15]
/// Rising trigger event configuration of
RT15: u1 = 0,
/// RT16 [16:16]
/// Rising trigger event configuration of
RT16: u1 = 0,
/// RT17 [17:17]
/// Rising trigger event configuration of
RT17: u1 = 0,
/// unused [18:18]
_unused18: u1 = 0,
/// RT19 [19:19]
/// Rising trigger event configuration of
RT19: u1 = 0,
/// RT20 [20:20]
/// Rising trigger event configuration of
RT20: u1 = 0,
/// RT21 [21:21]
/// Rising trigger event configuration of
RT21: u1 = 0,
/// RT22 [22:22]
/// Rising trigger event configuration of
RT22: u1 = 0,
/// unused [23:31]
_unused23: u1 = 0,
_unused24: u8 = 0,
};
/// Rising Trigger selection register
pub const RTSR = Register(RTSR_val).init(base_address + 0x8);

/// FTSR
const FTSR_val = packed struct {
/// FT0 [0:0]
/// Falling trigger event configuration of
FT0: u1 = 0,
/// FT1 [1:1]
/// Falling trigger event configuration of
FT1: u1 = 0,
/// FT2 [2:2]
/// Falling trigger event configuration of
FT2: u1 = 0,
/// FT3 [3:3]
/// Falling trigger event configuration of
FT3: u1 = 0,
/// FT4 [4:4]
/// Falling trigger event configuration of
FT4: u1 = 0,
/// FT5 [5:5]
/// Falling trigger event configuration of
FT5: u1 = 0,
/// FT6 [6:6]
/// Falling trigger event configuration of
FT6: u1 = 0,
/// FT7 [7:7]
/// Falling trigger event configuration of
FT7: u1 = 0,
/// FT8 [8:8]
/// Falling trigger event configuration of
FT8: u1 = 0,
/// FT9 [9:9]
/// Falling trigger event configuration of
FT9: u1 = 0,
/// FT10 [10:10]
/// Falling trigger event configuration of
FT10: u1 = 0,
/// FT11 [11:11]
/// Falling trigger event configuration of
FT11: u1 = 0,
/// FT12 [12:12]
/// Falling trigger event configuration of
FT12: u1 = 0,
/// FT13 [13:13]
/// Falling trigger event configuration of
FT13: u1 = 0,
/// FT14 [14:14]
/// Falling trigger event configuration of
FT14: u1 = 0,
/// FT15 [15:15]
/// Falling trigger event configuration of
FT15: u1 = 0,
/// FT16 [16:16]
/// Falling trigger event configuration of
FT16: u1 = 0,
/// FT17 [17:17]
/// Falling trigger event configuration of
FT17: u1 = 0,
/// unused [18:18]
_unused18: u1 = 0,
/// FT19 [19:19]
/// Falling trigger event configuration of
FT19: u1 = 0,
/// FT20 [20:20]
/// Falling trigger event configuration of
FT20: u1 = 0,
/// FT21 [21:21]
/// Falling trigger event configuration of
FT21: u1 = 0,
/// FT22 [22:22]
/// Falling trigger event configuration of
FT22: u1 = 0,
/// unused [23:31]
_unused23: u1 = 0,
_unused24: u8 = 0,
};
/// Falling Trigger selection register
pub const FTSR = Register(FTSR_val).init(base_address + 0xc);

/// SWIER
const SWIER_val = packed struct {
/// SWI0 [0:0]
/// Software Interrupt on line
SWI0: u1 = 0,
/// SWI1 [1:1]
/// Software Interrupt on line
SWI1: u1 = 0,
/// SWI2 [2:2]
/// Software Interrupt on line
SWI2: u1 = 0,
/// SWI3 [3:3]
/// Software Interrupt on line
SWI3: u1 = 0,
/// SWI4 [4:4]
/// Software Interrupt on line
SWI4: u1 = 0,
/// SWI5 [5:5]
/// Software Interrupt on line
SWI5: u1 = 0,
/// SWI6 [6:6]
/// Software Interrupt on line
SWI6: u1 = 0,
/// SWI7 [7:7]
/// Software Interrupt on line
SWI7: u1 = 0,
/// SWI8 [8:8]
/// Software Interrupt on line
SWI8: u1 = 0,
/// SWI9 [9:9]
/// Software Interrupt on line
SWI9: u1 = 0,
/// SWI10 [10:10]
/// Software Interrupt on line
SWI10: u1 = 0,
/// SWI11 [11:11]
/// Software Interrupt on line
SWI11: u1 = 0,
/// SWI12 [12:12]
/// Software Interrupt on line
SWI12: u1 = 0,
/// SWI13 [13:13]
/// Software Interrupt on line
SWI13: u1 = 0,
/// SWI14 [14:14]
/// Software Interrupt on line
SWI14: u1 = 0,
/// SWI15 [15:15]
/// Software Interrupt on line
SWI15: u1 = 0,
/// SWI16 [16:16]
/// Software Interrupt on line
SWI16: u1 = 0,
/// SWI17 [17:17]
/// Software Interrupt on line
SWI17: u1 = 0,
/// unused [18:18]
_unused18: u1 = 0,
/// SWI19 [19:19]
/// Software Interrupt on line
SWI19: u1 = 0,
/// SWI20 [20:20]
/// Software Interrupt on line
SWI20: u1 = 0,
/// SWI21 [21:21]
/// Software Interrupt on line
SWI21: u1 = 0,
/// SWI22 [22:22]
/// Software Interrupt on line
SWI22: u1 = 0,
/// unused [23:31]
_unused23: u1 = 0,
_unused24: u8 = 0,
};
/// Software interrupt event register
pub const SWIER = Register(SWIER_val).init(base_address + 0x10);

/// PR
const PR_val = packed struct {
/// PIF0 [0:0]
/// Pending bit 0
PIF0: u1 = 0,
/// PIF1 [1:1]
/// Pending bit 1
PIF1: u1 = 0,
/// PIF2 [2:2]
/// Pending bit 2
PIF2: u1 = 0,
/// PIF3 [3:3]
/// Pending bit 3
PIF3: u1 = 0,
/// PIF4 [4:4]
/// Pending bit 4
PIF4: u1 = 0,
/// PIF5 [5:5]
/// Pending bit 5
PIF5: u1 = 0,
/// PIF6 [6:6]
/// Pending bit 6
PIF6: u1 = 0,
/// PIF7 [7:7]
/// Pending bit 7
PIF7: u1 = 0,
/// PIF8 [8:8]
/// Pending bit 8
PIF8: u1 = 0,
/// PIF9 [9:9]
/// Pending bit 9
PIF9: u1 = 0,
/// PIF10 [10:10]
/// Pending bit 10
PIF10: u1 = 0,
/// PIF11 [11:11]
/// Pending bit 11
PIF11: u1 = 0,
/// PIF12 [12:12]
/// Pending bit 12
PIF12: u1 = 0,
/// PIF13 [13:13]
/// Pending bit 13
PIF13: u1 = 0,
/// PIF14 [14:14]
/// Pending bit 14
PIF14: u1 = 0,
/// PIF15 [15:15]
/// Pending bit 15
PIF15: u1 = 0,
/// PIF16 [16:16]
/// Pending bit 16
PIF16: u1 = 0,
/// PIF17 [17:17]
/// Pending bit 17
PIF17: u1 = 0,
/// unused [18:18]
_unused18: u1 = 0,
/// PIF19 [19:19]
/// Pending bit 19
PIF19: u1 = 0,
/// PIF20 [20:20]
/// Pending bit 20
PIF20: u1 = 0,
/// PIF21 [21:21]
/// Pending bit 21
PIF21: u1 = 0,
/// PIF22 [22:22]
/// Pending bit 22
PIF22: u1 = 0,
/// unused [23:31]
_unused23: u1 = 0,
_unused24: u8 = 0,
};
/// Pending register (EXTI_PR)
pub const PR = Register(PR_val).init(base_address + 0x14);
};

/// Analog-to-digital converter
pub const ADC = struct {

const base_address = 0x40012400;
/// ISR
const ISR_val = packed struct {
/// ADRDY [0:0]
/// ADC ready
ADRDY: u1 = 0,
/// EOSMP [1:1]
/// End of sampling flag
EOSMP: u1 = 0,
/// EOC [2:2]
/// End of conversion flag
EOC: u1 = 0,
/// EOS [3:3]
/// End of sequence flag
EOS: u1 = 0,
/// OVR [4:4]
/// ADC overrun
OVR: u1 = 0,
/// unused [5:6]
_unused5: u2 = 0,
/// AWD [7:7]
/// Analog watchdog flag
AWD: u1 = 0,
/// unused [8:10]
_unused8: u3 = 0,
/// EOCAL [11:11]
/// End Of Calibration flag
EOCAL: u1 = 0,
/// unused [12:31]
_unused12: u4 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// interrupt and status register
pub const ISR = Register(ISR_val).init(base_address + 0x0);

/// IER
const IER_val = packed struct {
/// ADRDYIE [0:0]
/// ADC ready interrupt enable
ADRDYIE: u1 = 0,
/// EOSMPIE [1:1]
/// End of sampling flag interrupt
EOSMPIE: u1 = 0,
/// EOCIE [2:2]
/// End of conversion interrupt
EOCIE: u1 = 0,
/// EOSIE [3:3]
/// End of conversion sequence interrupt
EOSIE: u1 = 0,
/// OVRIE [4:4]
/// Overrun interrupt enable
OVRIE: u1 = 0,
/// unused [5:6]
_unused5: u2 = 0,
/// AWDIE [7:7]
/// Analog watchdog interrupt
AWDIE: u1 = 0,
/// unused [8:10]
_unused8: u3 = 0,
/// EOCALIE [11:11]
/// End of calibration interrupt
EOCALIE: u1 = 0,
/// unused [12:31]
_unused12: u4 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// interrupt enable register
pub const IER = Register(IER_val).init(base_address + 0x4);

/// CR
const CR_val = packed struct {
/// ADEN [0:0]
/// ADC enable command
ADEN: u1 = 0,
/// ADDIS [1:1]
/// ADC disable command
ADDIS: u1 = 0,
/// ADSTART [2:2]
/// ADC start conversion
ADSTART: u1 = 0,
/// unused [3:3]
_unused3: u1 = 0,
/// ADSTP [4:4]
/// ADC stop conversion
ADSTP: u1 = 0,
/// unused [5:27]
_unused5: u3 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u4 = 0,
/// ADVREGEN [28:28]
/// ADC Voltage Regulator
ADVREGEN: u1 = 0,
/// unused [29:30]
_unused29: u2 = 0,
/// ADCAL [31:31]
/// ADC calibration
ADCAL: u1 = 0,
};
/// control register
pub const CR = Register(CR_val).init(base_address + 0x8);

/// CFGR1
const CFGR1_val = packed struct {
/// DMAEN [0:0]
/// Direct memory access
DMAEN: u1 = 0,
/// DMACFG [1:1]
/// Direct memery access
DMACFG: u1 = 0,
/// SCANDIR [2:2]
/// Scan sequence direction
SCANDIR: u1 = 0,
/// RES [3:4]
/// Data resolution
RES: u2 = 0,
/// ALIGN [5:5]
/// Data alignment
ALIGN: u1 = 0,
/// EXTSEL [6:8]
/// External trigger selection
EXTSEL: u3 = 0,
/// unused [9:9]
_unused9: u1 = 0,
/// EXTEN [10:11]
/// External trigger enable and polarity
EXTEN: u2 = 0,
/// OVRMOD [12:12]
/// Overrun management mode
OVRMOD: u1 = 0,
/// CONT [13:13]
/// Single / continuous conversion
CONT: u1 = 0,
/// AUTDLY [14:14]
/// Auto-delayed conversion
AUTDLY: u1 = 0,
/// AUTOFF [15:15]
/// Auto-off mode
AUTOFF: u1 = 0,
/// DISCEN [16:16]
/// Discontinuous mode
DISCEN: u1 = 0,
/// unused [17:21]
_unused17: u5 = 0,
/// AWDSGL [22:22]
/// Enable the watchdog on a single channel
AWDSGL: u1 = 0,
/// AWDEN [23:23]
/// Analog watchdog enable
AWDEN: u1 = 0,
/// unused [24:25]
_unused24: u2 = 0,
/// AWDCH [26:30]
/// Analog watchdog channel
AWDCH: u5 = 0,
/// unused [31:31]
_unused31: u1 = 0,
};
/// configuration register 1
pub const CFGR1 = Register(CFGR1_val).init(base_address + 0xc);

/// CFGR2
const CFGR2_val = packed struct {
/// OVSE [0:0]
/// Oversampler Enable
OVSE: u1 = 0,
/// unused [1:1]
_unused1: u1 = 0,
/// OVSR [2:4]
/// Oversampling ratio
OVSR: u3 = 0,
/// OVSS [5:8]
/// Oversampling shift
OVSS: u4 = 0,
/// TOVS [9:9]
/// Triggered Oversampling
TOVS: u1 = 0,
/// unused [10:29]
_unused10: u6 = 0,
_unused16: u8 = 0,
_unused24: u6 = 0,
/// CKMODE [30:31]
/// ADC clock mode
CKMODE: u2 = 0,
};
/// configuration register 2
pub const CFGR2 = Register(CFGR2_val).init(base_address + 0x10);

/// SMPR
const SMPR_val = packed struct {
/// SMPR [0:2]
/// Sampling time selection
SMPR: u3 = 0,
/// unused [3:31]
_unused3: u5 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// sampling time register
pub const SMPR = Register(SMPR_val).init(base_address + 0x14);

/// TR
const TR_val = packed struct {
/// LT [0:11]
/// Analog watchdog lower
LT: u12 = 0,
/// unused [12:15]
_unused12: u4 = 0,
/// HT [16:27]
/// Analog watchdog higher
HT: u12 = 4095,
/// unused [28:31]
_unused28: u4 = 0,
};
/// watchdog threshold register
pub const TR = Register(TR_val).init(base_address + 0x20);

/// CHSELR
const CHSELR_val = packed struct {
/// CHSEL0 [0:0]
/// Channel-x selection
CHSEL0: u1 = 0,
/// CHSEL1 [1:1]
/// Channel-x selection
CHSEL1: u1 = 0,
/// CHSEL2 [2:2]
/// Channel-x selection
CHSEL2: u1 = 0,
/// CHSEL3 [3:3]
/// Channel-x selection
CHSEL3: u1 = 0,
/// CHSEL4 [4:4]
/// Channel-x selection
CHSEL4: u1 = 0,
/// CHSEL5 [5:5]
/// Channel-x selection
CHSEL5: u1 = 0,
/// CHSEL6 [6:6]
/// Channel-x selection
CHSEL6: u1 = 0,
/// CHSEL7 [7:7]
/// Channel-x selection
CHSEL7: u1 = 0,
/// CHSEL8 [8:8]
/// Channel-x selection
CHSEL8: u1 = 0,
/// CHSEL9 [9:9]
/// Channel-x selection
CHSEL9: u1 = 0,
/// CHSEL10 [10:10]
/// Channel-x selection
CHSEL10: u1 = 0,
/// CHSEL11 [11:11]
/// Channel-x selection
CHSEL11: u1 = 0,
/// CHSEL12 [12:12]
/// Channel-x selection
CHSEL12: u1 = 0,
/// CHSEL13 [13:13]
/// Channel-x selection
CHSEL13: u1 = 0,
/// CHSEL14 [14:14]
/// Channel-x selection
CHSEL14: u1 = 0,
/// CHSEL15 [15:15]
/// Channel-x selection
CHSEL15: u1 = 0,
/// CHSEL16 [16:16]
/// Channel-x selection
CHSEL16: u1 = 0,
/// CHSEL17 [17:17]
/// Channel-x selection
CHSEL17: u1 = 0,
/// CHSEL18 [18:18]
/// Channel-x selection
CHSEL18: u1 = 0,
/// unused [19:31]
_unused19: u5 = 0,
_unused24: u8 = 0,
};
/// channel selection register
pub const CHSELR = Register(CHSELR_val).init(base_address + 0x28);

/// DR
const DR_val = packed struct {
/// DATA [0:15]
/// Converted data
DATA: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// data register
pub const DR = Register(DR_val).init(base_address + 0x40);

/// CALFACT
const CALFACT_val = packed struct {
/// CALFACT [0:6]
/// Calibration factor
CALFACT: u7 = 0,
/// unused [7:31]
_unused7: u1 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// ADC Calibration factor
pub const CALFACT = Register(CALFACT_val).init(base_address + 0xb4);

/// CCR
const CCR_val = packed struct {
/// unused [0:17]
_unused0: u8 = 0,
_unused8: u8 = 0,
_unused16: u2 = 0,
/// PRESC [18:21]
/// ADC prescaler
PRESC: u4 = 0,
/// VREFEN [22:22]
/// VREFINT enable
VREFEN: u1 = 0,
/// TSEN [23:23]
/// Temperature sensor enable
TSEN: u1 = 0,
/// unused [24:24]
_unused24: u1 = 0,
/// LFMEN [25:25]
/// Low Frequency Mode enable
LFMEN: u1 = 0,
/// unused [26:31]
_unused26: u6 = 0,
};
/// ADC common configuration
pub const CCR = Register(CCR_val).init(base_address + 0x308);
};

/// Debug support
pub const DBGMCU = struct {

const base_address = 0x40015800;
/// IDCODE
const IDCODE_val = packed struct {
/// DEV_ID [0:11]
/// Device Identifier
DEV_ID: u12 = 0,
/// unused [12:15]
_unused12: u4 = 0,
/// REV_ID [16:31]
/// Revision Identifier
REV_ID: u16 = 0,
};
/// MCU Device ID Code Register
pub const IDCODE = Register(IDCODE_val).init(base_address + 0x0);

/// CR
const CR_val = packed struct {
/// DBG_SLEEP [0:0]
/// Debug Sleep Mode
DBG_SLEEP: u1 = 0,
/// DBG_STOP [1:1]
/// Debug Stop Mode
DBG_STOP: u1 = 0,
/// DBG_STANDBY [2:2]
/// Debug Standby Mode
DBG_STANDBY: u1 = 0,
/// unused [3:31]
_unused3: u5 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Debug MCU Configuration
pub const CR = Register(CR_val).init(base_address + 0x4);

/// APB1_FZ
const APB1_FZ_val = packed struct {
/// DBG_TIMER2_STOP [0:0]
/// Debug Timer 2 stopped when Core is
DBG_TIMER2_STOP: u1 = 0,
/// unused [1:3]
_unused1: u3 = 0,
/// DBG_TIMER6_STOP [4:4]
/// Debug Timer 6 stopped when Core is
DBG_TIMER6_STOP: u1 = 0,
/// unused [5:9]
_unused5: u3 = 0,
_unused8: u2 = 0,
/// DBG_RTC_STOP [10:10]
/// Debug RTC stopped when Core is
DBG_RTC_STOP: u1 = 0,
/// DBG_WWDG_STOP [11:11]
/// Debug Window Wachdog stopped when Core
DBG_WWDG_STOP: u1 = 0,
/// DBG_IWDG_STOP [12:12]
/// Debug Independent Wachdog stopped when
DBG_IWDG_STOP: u1 = 0,
/// unused [13:20]
_unused13: u3 = 0,
_unused16: u5 = 0,
/// DBG_I2C1_STOP [21:21]
/// I2C1 SMBUS timeout mode stopped when
DBG_I2C1_STOP: u1 = 0,
/// DBG_I2C2_STOP [22:22]
/// I2C2 SMBUS timeout mode stopped when
DBG_I2C2_STOP: u1 = 0,
/// unused [23:30]
_unused23: u1 = 0,
_unused24: u7 = 0,
/// DBG_LPTIMER_STOP [31:31]
/// LPTIM1 counter stopped when core is
DBG_LPTIMER_STOP: u1 = 0,
};
/// APB Low Freeze Register
pub const APB1_FZ = Register(APB1_FZ_val).init(base_address + 0x8);

/// APB2_FZ
const APB2_FZ_val = packed struct {
/// unused [0:1]
_unused0: u2 = 0,
/// DBG_TIMER21_STOP [2:2]
/// Debug Timer 21 stopped when Core is
DBG_TIMER21_STOP: u1 = 0,
/// unused [3:5]
_unused3: u3 = 0,
/// DBG_TIMER22_STO [6:6]
/// Debug Timer 22 stopped when Core is
DBG_TIMER22_STO: u1 = 0,
/// unused [7:31]
_unused7: u1 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// APB High Freeze Register
pub const APB2_FZ = Register(APB2_FZ_val).init(base_address + 0xc);
};

/// General-purpose-timers
pub const TIM2 = struct {

const base_address = 0x40000000;
/// CR1
const CR1_val = packed struct {
/// CEN [0:0]
/// Counter enable
CEN: u1 = 0,
/// UDIS [1:1]
/// Update disable
UDIS: u1 = 0,
/// URS [2:2]
/// Update request source
URS: u1 = 0,
/// OPM [3:3]
/// One-pulse mode
OPM: u1 = 0,
/// DIR [4:4]
/// Direction
DIR: u1 = 0,
/// CMS [5:6]
/// Center-aligned mode
CMS: u2 = 0,
/// ARPE [7:7]
/// Auto-reload preload enable
ARPE: u1 = 0,
/// CKD [8:9]
/// Clock division
CKD: u2 = 0,
/// unused [10:31]
_unused10: u6 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register 1
pub const CR1 = Register(CR1_val).init(base_address + 0x0);

/// CR2
const CR2_val = packed struct {
/// unused [0:2]
_unused0: u3 = 0,
/// CCDS [3:3]
/// Capture/compare DMA
CCDS: u1 = 0,
/// MMS [4:6]
/// Master mode selection
MMS: u3 = 0,
/// TI1S [7:7]
/// TI1 selection
TI1S: u1 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register 2
pub const CR2 = Register(CR2_val).init(base_address + 0x4);

/// SMCR
const SMCR_val = packed struct {
/// SMS [0:2]
/// Slave mode selection
SMS: u3 = 0,
/// unused [3:3]
_unused3: u1 = 0,
/// TS [4:6]
/// Trigger selection
TS: u3 = 0,
/// MSM [7:7]
/// Master/Slave mode
MSM: u1 = 0,
/// ETF [8:11]
/// External trigger filter
ETF: u4 = 0,
/// ETPS [12:13]
/// External trigger prescaler
ETPS: u2 = 0,
/// ECE [14:14]
/// External clock enable
ECE: u1 = 0,
/// ETP [15:15]
/// External trigger polarity
ETP: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// slave mode control register
pub const SMCR = Register(SMCR_val).init(base_address + 0x8);

/// DIER
const DIER_val = packed struct {
/// UIE [0:0]
/// Update interrupt enable
UIE: u1 = 0,
/// CC1IE [1:1]
/// Capture/Compare 1 interrupt
CC1IE: u1 = 0,
/// CC2IE [2:2]
/// Capture/Compare 2 interrupt
CC2IE: u1 = 0,
/// CC3IE [3:3]
/// Capture/Compare 3 interrupt
CC3IE: u1 = 0,
/// CC4IE [4:4]
/// Capture/Compare 4 interrupt
CC4IE: u1 = 0,
/// unused [5:5]
_unused5: u1 = 0,
/// TIE [6:6]
/// Trigger interrupt enable
TIE: u1 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// UDE [8:8]
/// Update DMA request enable
UDE: u1 = 0,
/// CC1DE [9:9]
/// Capture/Compare 1 DMA request
CC1DE: u1 = 0,
/// CC2DE [10:10]
/// Capture/Compare 2 DMA request
CC2DE: u1 = 0,
/// CC3DE [11:11]
/// Capture/Compare 3 DMA request
CC3DE: u1 = 0,
/// CC4DE [12:12]
/// Capture/Compare 4 DMA request
CC4DE: u1 = 0,
/// unused [13:13]
_unused13: u1 = 0,
/// TDE [14:14]
/// Trigger DMA request enable
TDE: u1 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// DMA/Interrupt enable register
pub const DIER = Register(DIER_val).init(base_address + 0xc);

/// SR
const SR_val = packed struct {
/// UIF [0:0]
/// Update interrupt flag
UIF: u1 = 0,
/// CC1IF [1:1]
/// Capture/compare 1 interrupt
CC1IF: u1 = 0,
/// CC2IF [2:2]
/// Capture/Compare 2 interrupt
CC2IF: u1 = 0,
/// CC3IF [3:3]
/// Capture/Compare 3 interrupt
CC3IF: u1 = 0,
/// CC4IF [4:4]
/// Capture/Compare 4 interrupt
CC4IF: u1 = 0,
/// unused [5:5]
_unused5: u1 = 0,
/// TIF [6:6]
/// Trigger interrupt flag
TIF: u1 = 0,
/// unused [7:8]
_unused7: u1 = 0,
_unused8: u1 = 0,
/// CC1OF [9:9]
/// Capture/Compare 1 overcapture
CC1OF: u1 = 0,
/// CC2OF [10:10]
/// Capture/compare 2 overcapture
CC2OF: u1 = 0,
/// CC3OF [11:11]
/// Capture/Compare 3 overcapture
CC3OF: u1 = 0,
/// CC4OF [12:12]
/// Capture/Compare 4 overcapture
CC4OF: u1 = 0,
/// unused [13:31]
_unused13: u3 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// status register
pub const SR = Register(SR_val).init(base_address + 0x10);

/// EGR
const EGR_val = packed struct {
/// UG [0:0]
/// Update generation
UG: u1 = 0,
/// CC1G [1:1]
/// Capture/compare 1
CC1G: u1 = 0,
/// CC2G [2:2]
/// Capture/compare 2
CC2G: u1 = 0,
/// CC3G [3:3]
/// Capture/compare 3
CC3G: u1 = 0,
/// CC4G [4:4]
/// Capture/compare 4
CC4G: u1 = 0,
/// unused [5:5]
_unused5: u1 = 0,
/// TG [6:6]
/// Trigger generation
TG: u1 = 0,
/// unused [7:31]
_unused7: u1 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// event generation register
pub const EGR = Register(EGR_val).init(base_address + 0x14);

/// CCMR1_Output
const CCMR1_Output_val = packed struct {
/// CC1S [0:1]
/// Capture/Compare 1
CC1S: u2 = 0,
/// OC1FE [2:2]
/// Output compare 1 fast
OC1FE: u1 = 0,
/// OC1PE [3:3]
/// Output compare 1 preload
OC1PE: u1 = 0,
/// OC1M [4:6]
/// Output compare 1 mode
OC1M: u3 = 0,
/// OC1CE [7:7]
/// Output compare 1 clear
OC1CE: u1 = 0,
/// CC2S [8:9]
/// Capture/Compare 2
CC2S: u2 = 0,
/// OC2FE [10:10]
/// Output compare 2 fast
OC2FE: u1 = 0,
/// OC2PE [11:11]
/// Output compare 2 preload
OC2PE: u1 = 0,
/// OC2M [12:14]
/// Output compare 2 mode
OC2M: u3 = 0,
/// OC2CE [15:15]
/// Output compare 2 clear
OC2CE: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare mode register 1 (output
pub const CCMR1_Output = Register(CCMR1_Output_val).init(base_address + 0x18);

/// CCMR1_Input
const CCMR1_Input_val = packed struct {
/// CC1S [0:1]
/// Capture/Compare 1
CC1S: u2 = 0,
/// IC1PSC [2:3]
/// Input capture 1 prescaler
IC1PSC: u2 = 0,
/// IC1F [4:7]
/// Input capture 1 filter
IC1F: u4 = 0,
/// CC2S [8:9]
/// Capture/compare 2
CC2S: u2 = 0,
/// IC2PSC [10:11]
/// Input capture 2 prescaler
IC2PSC: u2 = 0,
/// IC2F [12:15]
/// Input capture 2 filter
IC2F: u4 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare mode register 1 (input
pub const CCMR1_Input = Register(CCMR1_Input_val).init(base_address + 0x18);

/// CCMR2_Output
const CCMR2_Output_val = packed struct {
/// CC3S [0:1]
/// Capture/Compare 3
CC3S: u2 = 0,
/// OC3FE [2:2]
/// Output compare 3 fast
OC3FE: u1 = 0,
/// OC3PE [3:3]
/// Output compare 3 preload
OC3PE: u1 = 0,
/// OC3M [4:6]
/// Output compare 3 mode
OC3M: u3 = 0,
/// OC3CE [7:7]
/// Output compare 3 clear
OC3CE: u1 = 0,
/// CC4S [8:9]
/// Capture/Compare 4
CC4S: u2 = 0,
/// OC4FE [10:10]
/// Output compare 4 fast
OC4FE: u1 = 0,
/// OC4PE [11:11]
/// Output compare 4 preload
OC4PE: u1 = 0,
/// OC4M [12:14]
/// Output compare 4 mode
OC4M: u3 = 0,
/// OC4CE [15:15]
/// Output compare 4 clear
OC4CE: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare mode register 2 (output
pub const CCMR2_Output = Register(CCMR2_Output_val).init(base_address + 0x1c);

/// CCMR2_Input
const CCMR2_Input_val = packed struct {
/// CC3S [0:1]
/// Capture/Compare 3
CC3S: u2 = 0,
/// IC3PSC [2:3]
/// Input capture 3 prescaler
IC3PSC: u2 = 0,
/// IC3F [4:7]
/// Input capture 3 filter
IC3F: u4 = 0,
/// CC4S [8:9]
/// Capture/Compare 4
CC4S: u2 = 0,
/// IC4PSC [10:11]
/// Input capture 4 prescaler
IC4PSC: u2 = 0,
/// IC4F [12:15]
/// Input capture 4 filter
IC4F: u4 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare mode register 2 (input
pub const CCMR2_Input = Register(CCMR2_Input_val).init(base_address + 0x1c);

/// CCER
const CCER_val = packed struct {
/// CC1E [0:0]
/// Capture/Compare 1 output
CC1E: u1 = 0,
/// CC1P [1:1]
/// Capture/Compare 1 output
CC1P: u1 = 0,
/// unused [2:2]
_unused2: u1 = 0,
/// CC1NP [3:3]
/// Capture/Compare 1 output
CC1NP: u1 = 0,
/// CC2E [4:4]
/// Capture/Compare 2 output
CC2E: u1 = 0,
/// CC2P [5:5]
/// Capture/Compare 2 output
CC2P: u1 = 0,
/// unused [6:6]
_unused6: u1 = 0,
/// CC2NP [7:7]
/// Capture/Compare 2 output
CC2NP: u1 = 0,
/// CC3E [8:8]
/// Capture/Compare 3 output
CC3E: u1 = 0,
/// CC3P [9:9]
/// Capture/Compare 3 output
CC3P: u1 = 0,
/// unused [10:10]
_unused10: u1 = 0,
/// CC3NP [11:11]
/// Capture/Compare 3 output
CC3NP: u1 = 0,
/// CC4E [12:12]
/// Capture/Compare 4 output
CC4E: u1 = 0,
/// CC4P [13:13]
/// Capture/Compare 3 output
CC4P: u1 = 0,
/// unused [14:14]
_unused14: u1 = 0,
/// CC4NP [15:15]
/// Capture/Compare 4 output
CC4NP: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare enable
pub const CCER = Register(CCER_val).init(base_address + 0x20);

/// CNT
const CNT_val = packed struct {
/// CNT_L [0:15]
/// Low counter value
CNT_L: u16 = 0,
/// CNT_H [16:31]
/// High counter value (TIM2
CNT_H: u16 = 0,
};
/// counter
pub const CNT = Register(CNT_val).init(base_address + 0x24);

/// PSC
const PSC_val = packed struct {
/// PSC [0:15]
/// Prescaler value
PSC: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// prescaler
pub const PSC = Register(PSC_val).init(base_address + 0x28);

/// ARR
const ARR_val = packed struct {
/// ARR_L [0:15]
/// Low Auto-reload value
ARR_L: u16 = 0,
/// ARR_H [16:31]
/// High Auto-reload value (TIM2
ARR_H: u16 = 0,
};
/// auto-reload register
pub const ARR = Register(ARR_val).init(base_address + 0x2c);

/// CCR1
const CCR1_val = packed struct {
/// CCR1_L [0:15]
/// Low Capture/Compare 1
CCR1_L: u16 = 0,
/// CCR1_H [16:31]
/// High Capture/Compare 1 value (TIM2
CCR1_H: u16 = 0,
};
/// capture/compare register 1
pub const CCR1 = Register(CCR1_val).init(base_address + 0x34);

/// CCR2
const CCR2_val = packed struct {
/// CCR2_L [0:15]
/// Low Capture/Compare 2
CCR2_L: u16 = 0,
/// CCR2_H [16:31]
/// High Capture/Compare 2 value (TIM2
CCR2_H: u16 = 0,
};
/// capture/compare register 2
pub const CCR2 = Register(CCR2_val).init(base_address + 0x38);

/// CCR3
const CCR3_val = packed struct {
/// CCR3_L [0:15]
/// Low Capture/Compare value
CCR3_L: u16 = 0,
/// CCR3_H [16:31]
/// High Capture/Compare value (TIM2
CCR3_H: u16 = 0,
};
/// capture/compare register 3
pub const CCR3 = Register(CCR3_val).init(base_address + 0x3c);

/// CCR4
const CCR4_val = packed struct {
/// CCR4_L [0:15]
/// Low Capture/Compare value
CCR4_L: u16 = 0,
/// CCR4_H [16:31]
/// High Capture/Compare value (TIM2
CCR4_H: u16 = 0,
};
/// capture/compare register 4
pub const CCR4 = Register(CCR4_val).init(base_address + 0x40);

/// DCR
const DCR_val = packed struct {
/// DBA [0:4]
/// DMA base address
DBA: u5 = 0,
/// unused [5:7]
_unused5: u3 = 0,
/// DBL [8:12]
/// DMA burst length
DBL: u5 = 0,
/// unused [13:31]
_unused13: u3 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// DMA control register
pub const DCR = Register(DCR_val).init(base_address + 0x48);

/// DMAR
const DMAR_val = packed struct {
/// DMAB [0:15]
/// DMA register for burst
DMAB: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// DMA address for full transfer
pub const DMAR = Register(DMAR_val).init(base_address + 0x4c);

/// OR
const OR_val = packed struct {
/// ETR_RMP [0:2]
/// Timer2 ETR remap
ETR_RMP: u3 = 0,
/// TI4_RMP [3:4]
/// Internal trigger
TI4_RMP: u2 = 0,
/// unused [5:31]
_unused5: u3 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// TIM2 option register
pub const OR = Register(OR_val).init(base_address + 0x50);
};

/// General-purpose-timers
pub const TIM3 = struct {

const base_address = 0x40000400;
/// CR1
const CR1_val = packed struct {
/// CEN [0:0]
/// Counter enable
CEN: u1 = 0,
/// UDIS [1:1]
/// Update disable
UDIS: u1 = 0,
/// URS [2:2]
/// Update request source
URS: u1 = 0,
/// OPM [3:3]
/// One-pulse mode
OPM: u1 = 0,
/// DIR [4:4]
/// Direction
DIR: u1 = 0,
/// CMS [5:6]
/// Center-aligned mode
CMS: u2 = 0,
/// ARPE [7:7]
/// Auto-reload preload enable
ARPE: u1 = 0,
/// CKD [8:9]
/// Clock division
CKD: u2 = 0,
/// unused [10:31]
_unused10: u6 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register 1
pub const CR1 = Register(CR1_val).init(base_address + 0x0);

/// CR2
const CR2_val = packed struct {
/// unused [0:2]
_unused0: u3 = 0,
/// CCDS [3:3]
/// Capture/compare DMA
CCDS: u1 = 0,
/// MMS [4:6]
/// Master mode selection
MMS: u3 = 0,
/// TI1S [7:7]
/// TI1 selection
TI1S: u1 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register 2
pub const CR2 = Register(CR2_val).init(base_address + 0x4);

/// SMCR
const SMCR_val = packed struct {
/// SMS [0:2]
/// Slave mode selection
SMS: u3 = 0,
/// unused [3:3]
_unused3: u1 = 0,
/// TS [4:6]
/// Trigger selection
TS: u3 = 0,
/// MSM [7:7]
/// Master/Slave mode
MSM: u1 = 0,
/// ETF [8:11]
/// External trigger filter
ETF: u4 = 0,
/// ETPS [12:13]
/// External trigger prescaler
ETPS: u2 = 0,
/// ECE [14:14]
/// External clock enable
ECE: u1 = 0,
/// ETP [15:15]
/// External trigger polarity
ETP: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// slave mode control register
pub const SMCR = Register(SMCR_val).init(base_address + 0x8);

/// DIER
const DIER_val = packed struct {
/// UIE [0:0]
/// Update interrupt enable
UIE: u1 = 0,
/// CC1IE [1:1]
/// Capture/Compare 1 interrupt
CC1IE: u1 = 0,
/// CC2IE [2:2]
/// Capture/Compare 2 interrupt
CC2IE: u1 = 0,
/// CC3IE [3:3]
/// Capture/Compare 3 interrupt
CC3IE: u1 = 0,
/// CC4IE [4:4]
/// Capture/Compare 4 interrupt
CC4IE: u1 = 0,
/// unused [5:5]
_unused5: u1 = 0,
/// TIE [6:6]
/// Trigger interrupt enable
TIE: u1 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// UDE [8:8]
/// Update DMA request enable
UDE: u1 = 0,
/// CC1DE [9:9]
/// Capture/Compare 1 DMA request
CC1DE: u1 = 0,
/// CC2DE [10:10]
/// Capture/Compare 2 DMA request
CC2DE: u1 = 0,
/// CC3DE [11:11]
/// Capture/Compare 3 DMA request
CC3DE: u1 = 0,
/// CC4DE [12:12]
/// Capture/Compare 4 DMA request
CC4DE: u1 = 0,
/// unused [13:13]
_unused13: u1 = 0,
/// TDE [14:14]
/// Trigger DMA request enable
TDE: u1 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// DMA/Interrupt enable register
pub const DIER = Register(DIER_val).init(base_address + 0xc);

/// SR
const SR_val = packed struct {
/// UIF [0:0]
/// Update interrupt flag
UIF: u1 = 0,
/// CC1IF [1:1]
/// Capture/compare 1 interrupt
CC1IF: u1 = 0,
/// CC2IF [2:2]
/// Capture/Compare 2 interrupt
CC2IF: u1 = 0,
/// CC3IF [3:3]
/// Capture/Compare 3 interrupt
CC3IF: u1 = 0,
/// CC4IF [4:4]
/// Capture/Compare 4 interrupt
CC4IF: u1 = 0,
/// unused [5:5]
_unused5: u1 = 0,
/// TIF [6:6]
/// Trigger interrupt flag
TIF: u1 = 0,
/// unused [7:8]
_unused7: u1 = 0,
_unused8: u1 = 0,
/// CC1OF [9:9]
/// Capture/Compare 1 overcapture
CC1OF: u1 = 0,
/// CC2OF [10:10]
/// Capture/compare 2 overcapture
CC2OF: u1 = 0,
/// CC3OF [11:11]
/// Capture/Compare 3 overcapture
CC3OF: u1 = 0,
/// CC4OF [12:12]
/// Capture/Compare 4 overcapture
CC4OF: u1 = 0,
/// unused [13:31]
_unused13: u3 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// status register
pub const SR = Register(SR_val).init(base_address + 0x10);

/// EGR
const EGR_val = packed struct {
/// UG [0:0]
/// Update generation
UG: u1 = 0,
/// CC1G [1:1]
/// Capture/compare 1
CC1G: u1 = 0,
/// CC2G [2:2]
/// Capture/compare 2
CC2G: u1 = 0,
/// CC3G [3:3]
/// Capture/compare 3
CC3G: u1 = 0,
/// CC4G [4:4]
/// Capture/compare 4
CC4G: u1 = 0,
/// unused [5:5]
_unused5: u1 = 0,
/// TG [6:6]
/// Trigger generation
TG: u1 = 0,
/// unused [7:31]
_unused7: u1 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// event generation register
pub const EGR = Register(EGR_val).init(base_address + 0x14);

/// CCMR1_Output
const CCMR1_Output_val = packed struct {
/// CC1S [0:1]
/// Capture/Compare 1
CC1S: u2 = 0,
/// OC1FE [2:2]
/// Output compare 1 fast
OC1FE: u1 = 0,
/// OC1PE [3:3]
/// Output compare 1 preload
OC1PE: u1 = 0,
/// OC1M [4:6]
/// Output compare 1 mode
OC1M: u3 = 0,
/// OC1CE [7:7]
/// Output compare 1 clear
OC1CE: u1 = 0,
/// CC2S [8:9]
/// Capture/Compare 2
CC2S: u2 = 0,
/// OC2FE [10:10]
/// Output compare 2 fast
OC2FE: u1 = 0,
/// OC2PE [11:11]
/// Output compare 2 preload
OC2PE: u1 = 0,
/// OC2M [12:14]
/// Output compare 2 mode
OC2M: u3 = 0,
/// OC2CE [15:15]
/// Output compare 2 clear
OC2CE: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare mode register 1 (output
pub const CCMR1_Output = Register(CCMR1_Output_val).init(base_address + 0x18);

/// CCMR1_Input
const CCMR1_Input_val = packed struct {
/// CC1S [0:1]
/// Capture/Compare 1
CC1S: u2 = 0,
/// IC1PSC [2:3]
/// Input capture 1 prescaler
IC1PSC: u2 = 0,
/// IC1F [4:7]
/// Input capture 1 filter
IC1F: u4 = 0,
/// CC2S [8:9]
/// Capture/compare 2
CC2S: u2 = 0,
/// IC2PSC [10:11]
/// Input capture 2 prescaler
IC2PSC: u2 = 0,
/// IC2F [12:15]
/// Input capture 2 filter
IC2F: u4 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare mode register 1 (input
pub const CCMR1_Input = Register(CCMR1_Input_val).init(base_address + 0x18);

/// CCMR2_Output
const CCMR2_Output_val = packed struct {
/// CC3S [0:1]
/// Capture/Compare 3
CC3S: u2 = 0,
/// OC3FE [2:2]
/// Output compare 3 fast
OC3FE: u1 = 0,
/// OC3PE [3:3]
/// Output compare 3 preload
OC3PE: u1 = 0,
/// OC3M [4:6]
/// Output compare 3 mode
OC3M: u3 = 0,
/// OC3CE [7:7]
/// Output compare 3 clear
OC3CE: u1 = 0,
/// CC4S [8:9]
/// Capture/Compare 4
CC4S: u2 = 0,
/// OC4FE [10:10]
/// Output compare 4 fast
OC4FE: u1 = 0,
/// OC4PE [11:11]
/// Output compare 4 preload
OC4PE: u1 = 0,
/// OC4M [12:14]
/// Output compare 4 mode
OC4M: u3 = 0,
/// OC4CE [15:15]
/// Output compare 4 clear
OC4CE: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare mode register 2 (output
pub const CCMR2_Output = Register(CCMR2_Output_val).init(base_address + 0x1c);

/// CCMR2_Input
const CCMR2_Input_val = packed struct {
/// CC3S [0:1]
/// Capture/Compare 3
CC3S: u2 = 0,
/// IC3PSC [2:3]
/// Input capture 3 prescaler
IC3PSC: u2 = 0,
/// IC3F [4:7]
/// Input capture 3 filter
IC3F: u4 = 0,
/// CC4S [8:9]
/// Capture/Compare 4
CC4S: u2 = 0,
/// IC4PSC [10:11]
/// Input capture 4 prescaler
IC4PSC: u2 = 0,
/// IC4F [12:15]
/// Input capture 4 filter
IC4F: u4 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare mode register 2 (input
pub const CCMR2_Input = Register(CCMR2_Input_val).init(base_address + 0x1c);

/// CCER
const CCER_val = packed struct {
/// CC1E [0:0]
/// Capture/Compare 1 output
CC1E: u1 = 0,
/// CC1P [1:1]
/// Capture/Compare 1 output
CC1P: u1 = 0,
/// unused [2:2]
_unused2: u1 = 0,
/// CC1NP [3:3]
/// Capture/Compare 1 output
CC1NP: u1 = 0,
/// CC2E [4:4]
/// Capture/Compare 2 output
CC2E: u1 = 0,
/// CC2P [5:5]
/// Capture/Compare 2 output
CC2P: u1 = 0,
/// unused [6:6]
_unused6: u1 = 0,
/// CC2NP [7:7]
/// Capture/Compare 2 output
CC2NP: u1 = 0,
/// CC3E [8:8]
/// Capture/Compare 3 output
CC3E: u1 = 0,
/// CC3P [9:9]
/// Capture/Compare 3 output
CC3P: u1 = 0,
/// unused [10:10]
_unused10: u1 = 0,
/// CC3NP [11:11]
/// Capture/Compare 3 output
CC3NP: u1 = 0,
/// CC4E [12:12]
/// Capture/Compare 4 output
CC4E: u1 = 0,
/// CC4P [13:13]
/// Capture/Compare 3 output
CC4P: u1 = 0,
/// unused [14:14]
_unused14: u1 = 0,
/// CC4NP [15:15]
/// Capture/Compare 4 output
CC4NP: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare enable
pub const CCER = Register(CCER_val).init(base_address + 0x20);

/// CNT
const CNT_val = packed struct {
/// CNT_L [0:15]
/// Low counter value
CNT_L: u16 = 0,
/// CNT_H [16:31]
/// High counter value (TIM2
CNT_H: u16 = 0,
};
/// counter
pub const CNT = Register(CNT_val).init(base_address + 0x24);

/// PSC
const PSC_val = packed struct {
/// PSC [0:15]
/// Prescaler value
PSC: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// prescaler
pub const PSC = Register(PSC_val).init(base_address + 0x28);

/// ARR
const ARR_val = packed struct {
/// ARR_L [0:15]
/// Low Auto-reload value
ARR_L: u16 = 0,
/// ARR_H [16:31]
/// High Auto-reload value (TIM2
ARR_H: u16 = 0,
};
/// auto-reload register
pub const ARR = Register(ARR_val).init(base_address + 0x2c);

/// CCR1
const CCR1_val = packed struct {
/// CCR1_L [0:15]
/// Low Capture/Compare 1
CCR1_L: u16 = 0,
/// CCR1_H [16:31]
/// High Capture/Compare 1 value (TIM2
CCR1_H: u16 = 0,
};
/// capture/compare register 1
pub const CCR1 = Register(CCR1_val).init(base_address + 0x34);

/// CCR2
const CCR2_val = packed struct {
/// CCR2_L [0:15]
/// Low Capture/Compare 2
CCR2_L: u16 = 0,
/// CCR2_H [16:31]
/// High Capture/Compare 2 value (TIM2
CCR2_H: u16 = 0,
};
/// capture/compare register 2
pub const CCR2 = Register(CCR2_val).init(base_address + 0x38);

/// CCR3
const CCR3_val = packed struct {
/// CCR3_L [0:15]
/// Low Capture/Compare value
CCR3_L: u16 = 0,
/// CCR3_H [16:31]
/// High Capture/Compare value (TIM2
CCR3_H: u16 = 0,
};
/// capture/compare register 3
pub const CCR3 = Register(CCR3_val).init(base_address + 0x3c);

/// CCR4
const CCR4_val = packed struct {
/// CCR4_L [0:15]
/// Low Capture/Compare value
CCR4_L: u16 = 0,
/// CCR4_H [16:31]
/// High Capture/Compare value (TIM2
CCR4_H: u16 = 0,
};
/// capture/compare register 4
pub const CCR4 = Register(CCR4_val).init(base_address + 0x40);

/// DCR
const DCR_val = packed struct {
/// DBA [0:4]
/// DMA base address
DBA: u5 = 0,
/// unused [5:7]
_unused5: u3 = 0,
/// DBL [8:12]
/// DMA burst length
DBL: u5 = 0,
/// unused [13:31]
_unused13: u3 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// DMA control register
pub const DCR = Register(DCR_val).init(base_address + 0x48);

/// DMAR
const DMAR_val = packed struct {
/// DMAB [0:15]
/// DMA register for burst
DMAB: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// DMA address for full transfer
pub const DMAR = Register(DMAR_val).init(base_address + 0x4c);

/// OR
const OR_val = packed struct {
/// ETR_RMP [0:2]
/// Timer2 ETR remap
ETR_RMP: u3 = 0,
/// TI4_RMP [3:4]
/// Internal trigger
TI4_RMP: u2 = 0,
/// unused [5:31]
_unused5: u3 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// TIM2 option register
pub const OR = Register(OR_val).init(base_address + 0x50);
};

/// Basic-timers
pub const TIM6 = struct {

const base_address = 0x40001000;
/// CR1
const CR1_val = packed struct {
/// CEN [0:0]
/// Counter enable
CEN: u1 = 0,
/// UDIS [1:1]
/// Update disable
UDIS: u1 = 0,
/// URS [2:2]
/// Update request source
URS: u1 = 0,
/// OPM [3:3]
/// One-pulse mode
OPM: u1 = 0,
/// unused [4:6]
_unused4: u3 = 0,
/// ARPE [7:7]
/// Auto-reload preload enable
ARPE: u1 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register 1
pub const CR1 = Register(CR1_val).init(base_address + 0x0);

/// CR2
const CR2_val = packed struct {
/// unused [0:3]
_unused0: u4 = 0,
/// MMS [4:6]
/// Master mode selection
MMS: u3 = 0,
/// unused [7:31]
_unused7: u1 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register 2
pub const CR2 = Register(CR2_val).init(base_address + 0x4);

/// DIER
const DIER_val = packed struct {
/// UIE [0:0]
/// Update interrupt enable
UIE: u1 = 0,
/// unused [1:7]
_unused1: u7 = 0,
/// UDE [8:8]
/// Update DMA request enable
UDE: u1 = 0,
/// unused [9:31]
_unused9: u7 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// DMA/Interrupt enable register
pub const DIER = Register(DIER_val).init(base_address + 0xc);

/// SR
const SR_val = packed struct {
/// UIF [0:0]
/// Update interrupt flag
UIF: u1 = 0,
/// unused [1:31]
_unused1: u7 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// status register
pub const SR = Register(SR_val).init(base_address + 0x10);

/// EGR
const EGR_val = packed struct {
/// UG [0:0]
/// Update generation
UG: u1 = 0,
/// unused [1:31]
_unused1: u7 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// event generation register
pub const EGR = Register(EGR_val).init(base_address + 0x14);

/// CNT
const CNT_val = packed struct {
/// CNT [0:15]
/// Low counter value
CNT: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// counter
pub const CNT = Register(CNT_val).init(base_address + 0x24);

/// PSC
const PSC_val = packed struct {
/// PSC [0:15]
/// Prescaler value
PSC: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// prescaler
pub const PSC = Register(PSC_val).init(base_address + 0x28);

/// ARR
const ARR_val = packed struct {
/// ARR [0:15]
/// Low Auto-reload value
ARR: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// auto-reload register
pub const ARR = Register(ARR_val).init(base_address + 0x2c);
};

/// Basic-timers
pub const TIM7 = struct {

const base_address = 0x40001400;
/// CR1
const CR1_val = packed struct {
/// CEN [0:0]
/// Counter enable
CEN: u1 = 0,
/// UDIS [1:1]
/// Update disable
UDIS: u1 = 0,
/// URS [2:2]
/// Update request source
URS: u1 = 0,
/// OPM [3:3]
/// One-pulse mode
OPM: u1 = 0,
/// unused [4:6]
_unused4: u3 = 0,
/// ARPE [7:7]
/// Auto-reload preload enable
ARPE: u1 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register 1
pub const CR1 = Register(CR1_val).init(base_address + 0x0);

/// CR2
const CR2_val = packed struct {
/// unused [0:3]
_unused0: u4 = 0,
/// MMS [4:6]
/// Master mode selection
MMS: u3 = 0,
/// unused [7:31]
_unused7: u1 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register 2
pub const CR2 = Register(CR2_val).init(base_address + 0x4);

/// DIER
const DIER_val = packed struct {
/// UIE [0:0]
/// Update interrupt enable
UIE: u1 = 0,
/// unused [1:7]
_unused1: u7 = 0,
/// UDE [8:8]
/// Update DMA request enable
UDE: u1 = 0,
/// unused [9:31]
_unused9: u7 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// DMA/Interrupt enable register
pub const DIER = Register(DIER_val).init(base_address + 0xc);

/// SR
const SR_val = packed struct {
/// UIF [0:0]
/// Update interrupt flag
UIF: u1 = 0,
/// unused [1:31]
_unused1: u7 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// status register
pub const SR = Register(SR_val).init(base_address + 0x10);

/// EGR
const EGR_val = packed struct {
/// UG [0:0]
/// Update generation
UG: u1 = 0,
/// unused [1:31]
_unused1: u7 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// event generation register
pub const EGR = Register(EGR_val).init(base_address + 0x14);

/// CNT
const CNT_val = packed struct {
/// CNT [0:15]
/// Low counter value
CNT: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// counter
pub const CNT = Register(CNT_val).init(base_address + 0x24);

/// PSC
const PSC_val = packed struct {
/// PSC [0:15]
/// Prescaler value
PSC: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// prescaler
pub const PSC = Register(PSC_val).init(base_address + 0x28);

/// ARR
const ARR_val = packed struct {
/// ARR [0:15]
/// Low Auto-reload value
ARR: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// auto-reload register
pub const ARR = Register(ARR_val).init(base_address + 0x2c);
};

/// General-purpose-timers
pub const TIM21 = struct {

const base_address = 0x40010800;
/// CR1
const CR1_val = packed struct {
/// CEN [0:0]
/// Counter enable
CEN: u1 = 0,
/// UDIS [1:1]
/// Update disable
UDIS: u1 = 0,
/// URS [2:2]
/// Update request source
URS: u1 = 0,
/// OPM [3:3]
/// One-pulse mode
OPM: u1 = 0,
/// DIR [4:4]
/// Direction
DIR: u1 = 0,
/// CMS [5:6]
/// Center-aligned mode
CMS: u2 = 0,
/// ARPE [7:7]
/// Auto-reload preload enable
ARPE: u1 = 0,
/// CKD [8:9]
/// Clock division
CKD: u2 = 0,
/// unused [10:31]
_unused10: u6 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register 1
pub const CR1 = Register(CR1_val).init(base_address + 0x0);

/// CR2
const CR2_val = packed struct {
/// unused [0:3]
_unused0: u4 = 0,
/// MMS [4:6]
/// Master mode selection
MMS: u3 = 0,
/// unused [7:31]
_unused7: u1 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register 2
pub const CR2 = Register(CR2_val).init(base_address + 0x4);

/// SMCR
const SMCR_val = packed struct {
/// SMS [0:2]
/// Slave mode selection
SMS: u3 = 0,
/// unused [3:3]
_unused3: u1 = 0,
/// TS [4:6]
/// Trigger selection
TS: u3 = 0,
/// MSM [7:7]
/// Master/Slave mode
MSM: u1 = 0,
/// ETF [8:11]
/// External trigger filter
ETF: u4 = 0,
/// ETPS [12:13]
/// External trigger prescaler
ETPS: u2 = 0,
/// ECE [14:14]
/// External clock enable
ECE: u1 = 0,
/// ETP [15:15]
/// External trigger polarity
ETP: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// slave mode control register
pub const SMCR = Register(SMCR_val).init(base_address + 0x8);

/// DIER
const DIER_val = packed struct {
/// UIE [0:0]
/// Update interrupt enable
UIE: u1 = 0,
/// CC1IE [1:1]
/// Capture/Compare 1 interrupt
CC1IE: u1 = 0,
/// CC2IE [2:2]
/// Capture/Compare 2 interrupt
CC2IE: u1 = 0,
/// unused [3:5]
_unused3: u3 = 0,
/// TIE [6:6]
/// Trigger interrupt enable
TIE: u1 = 0,
/// unused [7:31]
_unused7: u1 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// DMA/Interrupt enable register
pub const DIER = Register(DIER_val).init(base_address + 0xc);

/// SR
const SR_val = packed struct {
/// UIF [0:0]
/// Update interrupt flag
UIF: u1 = 0,
/// CC1IF [1:1]
/// Capture/compare 1 interrupt
CC1IF: u1 = 0,
/// CC2IF [2:2]
/// Capture/Compare 2 interrupt
CC2IF: u1 = 0,
/// unused [3:5]
_unused3: u3 = 0,
/// TIF [6:6]
/// Trigger interrupt flag
TIF: u1 = 0,
/// unused [7:8]
_unused7: u1 = 0,
_unused8: u1 = 0,
/// CC1OF [9:9]
/// Capture/Compare 1 overcapture
CC1OF: u1 = 0,
/// CC2OF [10:10]
/// Capture/compare 2 overcapture
CC2OF: u1 = 0,
/// unused [11:31]
_unused11: u5 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// status register
pub const SR = Register(SR_val).init(base_address + 0x10);

/// EGR
const EGR_val = packed struct {
/// UG [0:0]
/// Update generation
UG: u1 = 0,
/// CC1G [1:1]
/// Capture/compare 1
CC1G: u1 = 0,
/// CC2G [2:2]
/// Capture/compare 2
CC2G: u1 = 0,
/// unused [3:5]
_unused3: u3 = 0,
/// TG [6:6]
/// Trigger generation
TG: u1 = 0,
/// unused [7:31]
_unused7: u1 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// event generation register
pub const EGR = Register(EGR_val).init(base_address + 0x14);

/// CCMR1_Output
const CCMR1_Output_val = packed struct {
/// CC1S [0:1]
/// Capture/Compare 1
CC1S: u2 = 0,
/// OC1FE [2:2]
/// Output Compare 1 fast
OC1FE: u1 = 0,
/// OC1PE [3:3]
/// Output Compare 1 preload
OC1PE: u1 = 0,
/// OC1M [4:6]
/// Output Compare 1 mode
OC1M: u3 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// CC2S [8:9]
/// Capture/Compare 2
CC2S: u2 = 0,
/// OC2FE [10:10]
/// Output Compare 2 fast
OC2FE: u1 = 0,
/// OC2PE [11:11]
/// Output Compare 2 preload
OC2PE: u1 = 0,
/// OC2M [12:14]
/// Output Compare 2 mode
OC2M: u3 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare mode register (output
pub const CCMR1_Output = Register(CCMR1_Output_val).init(base_address + 0x18);

/// CCMR1_Input
const CCMR1_Input_val = packed struct {
/// CC1S [0:1]
/// Capture/Compare 1
CC1S: u2 = 0,
/// IC1PSC [2:3]
/// Input capture 1 prescaler
IC1PSC: u2 = 0,
/// IC1F [4:7]
/// Input capture 1 filter
IC1F: u4 = 0,
/// CC2S [8:9]
/// Capture/Compare 2
CC2S: u2 = 0,
/// IC2PSC [10:11]
/// Input capture 2 prescaler
IC2PSC: u2 = 0,
/// IC2F [12:15]
/// Input capture 2 filter
IC2F: u4 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare mode register 1 (input
pub const CCMR1_Input = Register(CCMR1_Input_val).init(base_address + 0x18);

/// CCER
const CCER_val = packed struct {
/// CC1E [0:0]
/// Capture/Compare 1 output
CC1E: u1 = 0,
/// CC1P [1:1]
/// Capture/Compare 1 output
CC1P: u1 = 0,
/// unused [2:2]
_unused2: u1 = 0,
/// CC1NP [3:3]
/// Capture/Compare 1 output
CC1NP: u1 = 0,
/// CC2E [4:4]
/// Capture/Compare 2 output
CC2E: u1 = 0,
/// CC2P [5:5]
/// Capture/Compare 2 output
CC2P: u1 = 0,
/// unused [6:6]
_unused6: u1 = 0,
/// CC2NP [7:7]
/// Capture/Compare 2 output
CC2NP: u1 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare enable
pub const CCER = Register(CCER_val).init(base_address + 0x20);

/// CNT
const CNT_val = packed struct {
/// CNT [0:15]
/// counter value
CNT: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// counter
pub const CNT = Register(CNT_val).init(base_address + 0x24);

/// PSC
const PSC_val = packed struct {
/// PSC [0:15]
/// Prescaler value
PSC: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// prescaler
pub const PSC = Register(PSC_val).init(base_address + 0x28);

/// ARR
const ARR_val = packed struct {
/// ARR [0:15]
/// Auto-reload value
ARR: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// auto-reload register
pub const ARR = Register(ARR_val).init(base_address + 0x2c);

/// CCR1
const CCR1_val = packed struct {
/// CCR1 [0:15]
/// Capture/Compare 1 value
CCR1: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare register 1
pub const CCR1 = Register(CCR1_val).init(base_address + 0x34);

/// CCR2
const CCR2_val = packed struct {
/// CCR2 [0:15]
/// Capture/Compare 2 value
CCR2: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare register 2
pub const CCR2 = Register(CCR2_val).init(base_address + 0x38);

/// OR
const OR_val = packed struct {
/// ETR_RMP [0:1]
/// Timer21 ETR remap
ETR_RMP: u2 = 0,
/// TI1_RMP [2:4]
/// Timer21 TI1
TI1_RMP: u3 = 0,
/// TI2_RMP [5:5]
/// Timer21 TI2
TI2_RMP: u1 = 0,
/// unused [6:31]
_unused6: u2 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// TIM21 option register
pub const OR = Register(OR_val).init(base_address + 0x50);
};

/// General-purpose-timers
pub const TIM22 = struct {

const base_address = 0x40011400;
/// CR1
const CR1_val = packed struct {
/// CEN [0:0]
/// Counter enable
CEN: u1 = 0,
/// UDIS [1:1]
/// Update disable
UDIS: u1 = 0,
/// URS [2:2]
/// Update request source
URS: u1 = 0,
/// OPM [3:3]
/// One-pulse mode
OPM: u1 = 0,
/// DIR [4:4]
/// Direction
DIR: u1 = 0,
/// CMS [5:6]
/// Center-aligned mode
CMS: u2 = 0,
/// ARPE [7:7]
/// Auto-reload preload enable
ARPE: u1 = 0,
/// CKD [8:9]
/// Clock division
CKD: u2 = 0,
/// unused [10:31]
_unused10: u6 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register 1
pub const CR1 = Register(CR1_val).init(base_address + 0x0);

/// CR2
const CR2_val = packed struct {
/// unused [0:3]
_unused0: u4 = 0,
/// MMS [4:6]
/// Master mode selection
MMS: u3 = 0,
/// unused [7:31]
_unused7: u1 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register 2
pub const CR2 = Register(CR2_val).init(base_address + 0x4);

/// SMCR
const SMCR_val = packed struct {
/// SMS [0:2]
/// Slave mode selection
SMS: u3 = 0,
/// unused [3:3]
_unused3: u1 = 0,
/// TS [4:6]
/// Trigger selection
TS: u3 = 0,
/// MSM [7:7]
/// Master/Slave mode
MSM: u1 = 0,
/// ETF [8:11]
/// External trigger filter
ETF: u4 = 0,
/// ETPS [12:13]
/// External trigger prescaler
ETPS: u2 = 0,
/// ECE [14:14]
/// External clock enable
ECE: u1 = 0,
/// ETP [15:15]
/// External trigger polarity
ETP: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// slave mode control register
pub const SMCR = Register(SMCR_val).init(base_address + 0x8);

/// DIER
const DIER_val = packed struct {
/// UIE [0:0]
/// Update interrupt enable
UIE: u1 = 0,
/// CC1IE [1:1]
/// Capture/Compare 1 interrupt
CC1IE: u1 = 0,
/// CC2IE [2:2]
/// Capture/Compare 2 interrupt
CC2IE: u1 = 0,
/// unused [3:5]
_unused3: u3 = 0,
/// TIE [6:6]
/// Trigger interrupt enable
TIE: u1 = 0,
/// unused [7:31]
_unused7: u1 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// DMA/Interrupt enable register
pub const DIER = Register(DIER_val).init(base_address + 0xc);

/// SR
const SR_val = packed struct {
/// UIF [0:0]
/// Update interrupt flag
UIF: u1 = 0,
/// CC1IF [1:1]
/// Capture/compare 1 interrupt
CC1IF: u1 = 0,
/// CC2IF [2:2]
/// Capture/Compare 2 interrupt
CC2IF: u1 = 0,
/// unused [3:5]
_unused3: u3 = 0,
/// TIF [6:6]
/// Trigger interrupt flag
TIF: u1 = 0,
/// unused [7:8]
_unused7: u1 = 0,
_unused8: u1 = 0,
/// CC1OF [9:9]
/// Capture/Compare 1 overcapture
CC1OF: u1 = 0,
/// CC2OF [10:10]
/// Capture/compare 2 overcapture
CC2OF: u1 = 0,
/// unused [11:31]
_unused11: u5 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// status register
pub const SR = Register(SR_val).init(base_address + 0x10);

/// EGR
const EGR_val = packed struct {
/// UG [0:0]
/// Update generation
UG: u1 = 0,
/// CC1G [1:1]
/// Capture/compare 1
CC1G: u1 = 0,
/// CC2G [2:2]
/// Capture/compare 2
CC2G: u1 = 0,
/// unused [3:5]
_unused3: u3 = 0,
/// TG [6:6]
/// Trigger generation
TG: u1 = 0,
/// unused [7:31]
_unused7: u1 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// event generation register
pub const EGR = Register(EGR_val).init(base_address + 0x14);

/// CCMR1_Output
const CCMR1_Output_val = packed struct {
/// CC1S [0:1]
/// Capture/Compare 1
CC1S: u2 = 0,
/// OC1FE [2:2]
/// Output Compare 1 fast
OC1FE: u1 = 0,
/// OC1PE [3:3]
/// Output Compare 1 preload
OC1PE: u1 = 0,
/// OC1M [4:6]
/// Output Compare 1 mode
OC1M: u3 = 0,
/// unused [7:7]
_unused7: u1 = 0,
/// CC2S [8:9]
/// Capture/Compare 2
CC2S: u2 = 0,
/// OC2FE [10:10]
/// Output Compare 2 fast
OC2FE: u1 = 0,
/// OC2PE [11:11]
/// Output Compare 2 preload
OC2PE: u1 = 0,
/// OC2M [12:14]
/// Output Compare 2 mode
OC2M: u3 = 0,
/// unused [15:31]
_unused15: u1 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare mode register (output
pub const CCMR1_Output = Register(CCMR1_Output_val).init(base_address + 0x18);

/// CCMR1_Input
const CCMR1_Input_val = packed struct {
/// CC1S [0:1]
/// Capture/Compare 1
CC1S: u2 = 0,
/// IC1PSC [2:3]
/// Input capture 1 prescaler
IC1PSC: u2 = 0,
/// IC1F [4:7]
/// Input capture 1 filter
IC1F: u4 = 0,
/// CC2S [8:9]
/// Capture/Compare 2
CC2S: u2 = 0,
/// IC2PSC [10:11]
/// Input capture 2 prescaler
IC2PSC: u2 = 0,
/// IC2F [12:15]
/// Input capture 2 filter
IC2F: u4 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare mode register 1 (input
pub const CCMR1_Input = Register(CCMR1_Input_val).init(base_address + 0x18);

/// CCER
const CCER_val = packed struct {
/// CC1E [0:0]
/// Capture/Compare 1 output
CC1E: u1 = 0,
/// CC1P [1:1]
/// Capture/Compare 1 output
CC1P: u1 = 0,
/// unused [2:2]
_unused2: u1 = 0,
/// CC1NP [3:3]
/// Capture/Compare 1 output
CC1NP: u1 = 0,
/// CC2E [4:4]
/// Capture/Compare 2 output
CC2E: u1 = 0,
/// CC2P [5:5]
/// Capture/Compare 2 output
CC2P: u1 = 0,
/// unused [6:6]
_unused6: u1 = 0,
/// CC2NP [7:7]
/// Capture/Compare 2 output
CC2NP: u1 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare enable
pub const CCER = Register(CCER_val).init(base_address + 0x20);

/// CNT
const CNT_val = packed struct {
/// CNT [0:15]
/// counter value
CNT: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// counter
pub const CNT = Register(CNT_val).init(base_address + 0x24);

/// PSC
const PSC_val = packed struct {
/// PSC [0:15]
/// Prescaler value
PSC: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// prescaler
pub const PSC = Register(PSC_val).init(base_address + 0x28);

/// ARR
const ARR_val = packed struct {
/// ARR [0:15]
/// Auto-reload value
ARR: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// auto-reload register
pub const ARR = Register(ARR_val).init(base_address + 0x2c);

/// CCR1
const CCR1_val = packed struct {
/// CCR1 [0:15]
/// Capture/Compare 1 value
CCR1: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare register 1
pub const CCR1 = Register(CCR1_val).init(base_address + 0x34);

/// CCR2
const CCR2_val = packed struct {
/// CCR2 [0:15]
/// Capture/Compare 2 value
CCR2: u16 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// capture/compare register 2
pub const CCR2 = Register(CCR2_val).init(base_address + 0x38);

/// OR
const OR_val = packed struct {
/// ETR_RMP [0:1]
/// Timer22 ETR remap
ETR_RMP: u2 = 0,
/// TI1_RMP [2:3]
/// Timer22 TI1
TI1_RMP: u2 = 0,
/// unused [4:31]
_unused4: u4 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// TIM22 option register
pub const OR = Register(OR_val).init(base_address + 0x50);
};

/// Universal synchronous asynchronous receiver
pub const LPUSART1 = struct {

const base_address = 0x40004800;
/// CR1
const CR1_val = packed struct {
/// UE [0:0]
/// USART enable
UE: u1 = 0,
/// UESM [1:1]
/// USART enable in Stop mode
UESM: u1 = 0,
/// RE [2:2]
/// Receiver enable
RE: u1 = 0,
/// TE [3:3]
/// Transmitter enable
TE: u1 = 0,
/// IDLEIE [4:4]
/// IDLE interrupt enable
IDLEIE: u1 = 0,
/// RXNEIE [5:5]
/// RXNE interrupt enable
RXNEIE: u1 = 0,
/// TCIE [6:6]
/// Transmission complete interrupt
TCIE: u1 = 0,
/// TXEIE [7:7]
/// interrupt enable
TXEIE: u1 = 0,
/// PEIE [8:8]
/// PE interrupt enable
PEIE: u1 = 0,
/// PS [9:9]
/// Parity selection
PS: u1 = 0,
/// PCE [10:10]
/// Parity control enable
PCE: u1 = 0,
/// WAKE [11:11]
/// Receiver wakeup method
WAKE: u1 = 0,
/// M0 [12:12]
/// Word length
M0: u1 = 0,
/// MME [13:13]
/// Mute mode enable
MME: u1 = 0,
/// CMIE [14:14]
/// Character match interrupt
CMIE: u1 = 0,
/// unused [15:15]
_unused15: u1 = 0,
/// DEDT0 [16:16]
/// DEDT0
DEDT0: u1 = 0,
/// DEDT1 [17:17]
/// DEDT1
DEDT1: u1 = 0,
/// DEDT2 [18:18]
/// DEDT2
DEDT2: u1 = 0,
/// DEDT3 [19:19]
/// DEDT3
DEDT3: u1 = 0,
/// DEDT4 [20:20]
/// Driver Enable de-assertion
DEDT4: u1 = 0,
/// DEAT0 [21:21]
/// DEAT0
DEAT0: u1 = 0,
/// DEAT1 [22:22]
/// DEAT1
DEAT1: u1 = 0,
/// DEAT2 [23:23]
/// DEAT2
DEAT2: u1 = 0,
/// DEAT3 [24:24]
/// DEAT3
DEAT3: u1 = 0,
/// DEAT4 [25:25]
/// Driver Enable assertion
DEAT4: u1 = 0,
/// unused [26:27]
_unused26: u2 = 0,
/// M1 [28:28]
/// Word length
M1: u1 = 0,
/// unused [29:31]
_unused29: u3 = 0,
};
/// Control register 1
pub const CR1 = Register(CR1_val).init(base_address + 0x0);

/// CR2
const CR2_val = packed struct {
/// unused [0:3]
_unused0: u4 = 0,
/// ADDM7 [4:4]
/// 7-bit Address Detection/4-bit Address
ADDM7: u1 = 0,
/// unused [5:10]
_unused5: u3 = 0,
_unused8: u3 = 0,
/// CLKEN [11:11]
/// Clock enable
CLKEN: u1 = 0,
/// STOP [12:13]
/// STOP bits
STOP: u2 = 0,
/// unused [14:14]
_unused14: u1 = 0,
/// SWAP [15:15]
/// Swap TX/RX pins
SWAP: u1 = 0,
/// RXINV [16:16]
/// RX pin active level
RXINV: u1 = 0,
/// TXINV [17:17]
/// TX pin active level
TXINV: u1 = 0,
/// TAINV [18:18]
/// Binary data inversion
TAINV: u1 = 0,
/// MSBFIRST [19:19]
/// Most significant bit first
MSBFIRST: u1 = 0,
/// unused [20:23]
_unused20: u4 = 0,
/// ADD0_3 [24:27]
/// Address of the USART node
ADD0_3: u4 = 0,
/// ADD4_7 [28:31]
/// Address of the USART node
ADD4_7: u4 = 0,
};
/// Control register 2
pub const CR2 = Register(CR2_val).init(base_address + 0x4);

/// CR3
const CR3_val = packed struct {
/// EIE [0:0]
/// Error interrupt enable
EIE: u1 = 0,
/// unused [1:2]
_unused1: u2 = 0,
/// HDSEL [3:3]
/// Half-duplex selection
HDSEL: u1 = 0,
/// unused [4:5]
_unused4: u2 = 0,
/// DMAR [6:6]
/// DMA enable receiver
DMAR: u1 = 0,
/// DMAT [7:7]
/// DMA enable transmitter
DMAT: u1 = 0,
/// RTSE [8:8]
/// RTS enable
RTSE: u1 = 0,
/// CTSE [9:9]
/// CTS enable
CTSE: u1 = 0,
/// CTSIE [10:10]
/// CTS interrupt enable
CTSIE: u1 = 0,
/// unused [11:11]
_unused11: u1 = 0,
/// OVRDIS [12:12]
/// Overrun Disable
OVRDIS: u1 = 0,
/// DDRE [13:13]
/// DMA Disable on Reception
DDRE: u1 = 0,
/// DEM [14:14]
/// Driver enable mode
DEM: u1 = 0,
/// DEP [15:15]
/// Driver enable polarity
DEP: u1 = 0,
/// unused [16:19]
_unused16: u4 = 0,
/// WUS [20:21]
/// Wakeup from Stop mode interrupt flag
WUS: u2 = 0,
/// WUFIE [22:22]
/// Wakeup from Stop mode interrupt
WUFIE: u1 = 0,
/// unused [23:31]
_unused23: u1 = 0,
_unused24: u8 = 0,
};
/// Control register 3
pub const CR3 = Register(CR3_val).init(base_address + 0x8);

/// BRR
const BRR_val = packed struct {
/// BRR [0:19]
/// BRR
BRR: u20 = 0,
/// unused [20:31]
_unused20: u4 = 0,
_unused24: u8 = 0,
};
/// Baud rate register
pub const BRR = Register(BRR_val).init(base_address + 0xc);

/// RQR
const RQR_val = packed struct {
/// unused [0:0]
_unused0: u1 = 0,
/// SBKRQ [1:1]
/// Send break request
SBKRQ: u1 = 0,
/// MMRQ [2:2]
/// Mute mode request
MMRQ: u1 = 0,
/// RXFRQ [3:3]
/// Receive data flush request
RXFRQ: u1 = 0,
/// unused [4:31]
_unused4: u4 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Request register
pub const RQR = Register(RQR_val).init(base_address + 0x18);

/// ISR
const ISR_val = packed struct {
/// PE [0:0]
/// PE
PE: u1 = 0,
/// FE [1:1]
/// FE
FE: u1 = 0,
/// NF [2:2]
/// NF
NF: u1 = 0,
/// ORE [3:3]
/// ORE
ORE: u1 = 0,
/// IDLE [4:4]
/// IDLE
IDLE: u1 = 0,
/// RXNE [5:5]
/// RXNE
RXNE: u1 = 0,
/// TC [6:6]
/// TC
TC: u1 = 1,
/// TXE [7:7]
/// TXE
TXE: u1 = 1,
/// unused [8:8]
_unused8: u1 = 0,
/// CTSIF [9:9]
/// CTSIF
CTSIF: u1 = 0,
/// CTS [10:10]
/// CTS
CTS: u1 = 0,
/// unused [11:15]
_unused11: u5 = 0,
/// BUSY [16:16]
/// BUSY
BUSY: u1 = 0,
/// CMF [17:17]
/// CMF
CMF: u1 = 0,
/// SBKF [18:18]
/// SBKF
SBKF: u1 = 0,
/// RWU [19:19]
/// RWU
RWU: u1 = 0,
/// WUF [20:20]
/// WUF
WUF: u1 = 0,
/// TEACK [21:21]
/// TEACK
TEACK: u1 = 0,
/// REACK [22:22]
/// REACK
REACK: u1 = 0,
/// unused [23:31]
_unused23: u1 = 0,
_unused24: u8 = 0,
};
/// Interrupt &amp; status
pub const ISR = Register(ISR_val).init(base_address + 0x1c);

/// ICR
const ICR_val = packed struct {
/// PECF [0:0]
/// Parity error clear flag
PECF: u1 = 0,
/// FECF [1:1]
/// Framing error clear flag
FECF: u1 = 0,
/// NCF [2:2]
/// Noise detected clear flag
NCF: u1 = 0,
/// ORECF [3:3]
/// Overrun error clear flag
ORECF: u1 = 0,
/// IDLECF [4:4]
/// Idle line detected clear
IDLECF: u1 = 0,
/// unused [5:5]
_unused5: u1 = 0,
/// TCCF [6:6]
/// Transmission complete clear
TCCF: u1 = 0,
/// unused [7:8]
_unused7: u1 = 0,
_unused8: u1 = 0,
/// CTSCF [9:9]
/// CTS clear flag
CTSCF: u1 = 0,
/// unused [10:16]
_unused10: u6 = 0,
_unused16: u1 = 0,
/// CMCF [17:17]
/// Character match clear flag
CMCF: u1 = 0,
/// unused [18:19]
_unused18: u2 = 0,
/// WUCF [20:20]
/// Wakeup from Stop mode clear
WUCF: u1 = 0,
/// unused [21:31]
_unused21: u3 = 0,
_unused24: u8 = 0,
};
/// Interrupt flag clear register
pub const ICR = Register(ICR_val).init(base_address + 0x20);

/// RDR
const RDR_val = packed struct {
/// RDR [0:8]
/// Receive data value
RDR: u9 = 0,
/// unused [9:31]
_unused9: u7 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Receive data register
pub const RDR = Register(RDR_val).init(base_address + 0x24);

/// TDR
const TDR_val = packed struct {
/// TDR [0:8]
/// Transmit data value
TDR: u9 = 0,
/// unused [9:31]
_unused9: u7 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Transmit data register
pub const TDR = Register(TDR_val).init(base_address + 0x28);
};

/// Nested Vectored Interrupt
pub const NVIC = struct {

const base_address = 0xe000e100;
/// ISER
const ISER_val = packed struct {
/// SETENA [0:31]
/// SETENA
SETENA: u32 = 0,
};
/// Interrupt Set Enable Register
pub const ISER = Register(ISER_val).init(base_address + 0x0);

/// ICER
const ICER_val = packed struct {
/// CLRENA [0:31]
/// CLRENA
CLRENA: u32 = 0,
};
/// Interrupt Clear Enable
pub const ICER = Register(ICER_val).init(base_address + 0x80);

/// ISPR
const ISPR_val = packed struct {
/// SETPEND [0:31]
/// SETPEND
SETPEND: u32 = 0,
};
/// Interrupt Set-Pending Register
pub const ISPR = Register(ISPR_val).init(base_address + 0x100);

/// ICPR
const ICPR_val = packed struct {
/// CLRPEND [0:31]
/// CLRPEND
CLRPEND: u32 = 0,
};
/// Interrupt Clear-Pending
pub const ICPR = Register(ICPR_val).init(base_address + 0x180);

/// IPR0
const IPR0_val = packed struct {
/// PRI_0 [0:7]
/// priority for interrupt 0
PRI_0: u8 = 0,
/// PRI_1 [8:15]
/// priority for interrupt 1
PRI_1: u8 = 0,
/// PRI_2 [16:23]
/// priority for interrupt 2
PRI_2: u8 = 0,
/// PRI_3 [24:31]
/// priority for interrupt 3
PRI_3: u8 = 0,
};
/// Interrupt Priority Register 0
pub const IPR0 = Register(IPR0_val).init(base_address + 0x300);

/// IPR1
const IPR1_val = packed struct {
/// PRI_4 [0:7]
/// priority for interrupt n
PRI_4: u8 = 0,
/// PRI_5 [8:15]
/// priority for interrupt n
PRI_5: u8 = 0,
/// PRI_6 [16:23]
/// priority for interrupt n
PRI_6: u8 = 0,
/// PRI_7 [24:31]
/// priority for interrupt n
PRI_7: u8 = 0,
};
/// Interrupt Priority Register 1
pub const IPR1 = Register(IPR1_val).init(base_address + 0x304);

/// IPR2
const IPR2_val = packed struct {
/// PRI_8 [0:7]
/// priority for interrupt n
PRI_8: u8 = 0,
/// PRI_9 [8:15]
/// priority for interrupt n
PRI_9: u8 = 0,
/// PRI_10 [16:23]
/// priority for interrupt n
PRI_10: u8 = 0,
/// PRI_11 [24:31]
/// priority for interrupt n
PRI_11: u8 = 0,
};
/// Interrupt Priority Register 2
pub const IPR2 = Register(IPR2_val).init(base_address + 0x308);

/// IPR3
const IPR3_val = packed struct {
/// PRI_12 [0:7]
/// priority for interrupt n
PRI_12: u8 = 0,
/// PRI_13 [8:15]
/// priority for interrupt n
PRI_13: u8 = 0,
/// PRI_14 [16:23]
/// priority for interrupt n
PRI_14: u8 = 0,
/// PRI_15 [24:31]
/// priority for interrupt n
PRI_15: u8 = 0,
};
/// Interrupt Priority Register 3
pub const IPR3 = Register(IPR3_val).init(base_address + 0x30c);

/// IPR4
const IPR4_val = packed struct {
/// PRI_16 [0:7]
/// priority for interrupt n
PRI_16: u8 = 0,
/// PRI_17 [8:15]
/// priority for interrupt n
PRI_17: u8 = 0,
/// PRI_18 [16:23]
/// priority for interrupt n
PRI_18: u8 = 0,
/// PRI_19 [24:31]
/// priority for interrupt n
PRI_19: u8 = 0,
};
/// Interrupt Priority Register 4
pub const IPR4 = Register(IPR4_val).init(base_address + 0x310);

/// IPR5
const IPR5_val = packed struct {
/// PRI_20 [0:7]
/// priority for interrupt n
PRI_20: u8 = 0,
/// PRI_21 [8:15]
/// priority for interrupt n
PRI_21: u8 = 0,
/// PRI_22 [16:23]
/// priority for interrupt n
PRI_22: u8 = 0,
/// PRI_23 [24:31]
/// priority for interrupt n
PRI_23: u8 = 0,
};
/// Interrupt Priority Register 5
pub const IPR5 = Register(IPR5_val).init(base_address + 0x314);

/// IPR6
const IPR6_val = packed struct {
/// PRI_24 [0:7]
/// priority for interrupt n
PRI_24: u8 = 0,
/// PRI_25 [8:15]
/// priority for interrupt n
PRI_25: u8 = 0,
/// PRI_26 [16:23]
/// priority for interrupt n
PRI_26: u8 = 0,
/// PRI_27 [24:31]
/// priority for interrupt n
PRI_27: u8 = 0,
};
/// Interrupt Priority Register 6
pub const IPR6 = Register(IPR6_val).init(base_address + 0x318);

/// IPR7
const IPR7_val = packed struct {
/// PRI_28 [0:7]
/// priority for interrupt n
PRI_28: u8 = 0,
/// PRI_29 [8:15]
/// priority for interrupt n
PRI_29: u8 = 0,
/// PRI_30 [16:23]
/// priority for interrupt n
PRI_30: u8 = 0,
/// PRI_31 [24:31]
/// priority for interrupt n
PRI_31: u8 = 0,
};
/// Interrupt Priority Register 7
pub const IPR7 = Register(IPR7_val).init(base_address + 0x31c);
};

/// Universal serial bus full-speed device
pub const USB_SRAM = struct {

const base_address = 0x40006000;
/// EP0R
const EP0R_val = packed struct {
/// EA [0:3]
/// Endpoint address
EA: u4 = 0,
/// STAT_TX [4:5]
/// Status bits, for transmission
STAT_TX: u2 = 0,
/// DTOG_TX [6:6]
/// Data Toggle, for transmission
DTOG_TX: u1 = 0,
/// CTR_TX [7:7]
/// Correct Transfer for
CTR_TX: u1 = 0,
/// EP_KIND [8:8]
/// Endpoint kind
EP_KIND: u1 = 0,
/// EP_TYPE [9:10]
/// Endpoint type
EP_TYPE: u2 = 0,
/// SETUP [11:11]
/// Setup transaction
SETUP: u1 = 0,
/// STAT_RX [12:13]
/// Status bits, for reception
STAT_RX: u2 = 0,
/// DTOG_RX [14:14]
/// Data Toggle, for reception
DTOG_RX: u1 = 0,
/// CTR_RX [15:15]
/// Correct transfer for
CTR_RX: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// endpoint 0 register
pub const EP0R = Register(EP0R_val).init(base_address + 0x0);

/// EP1R
const EP1R_val = packed struct {
/// EA [0:3]
/// Endpoint address
EA: u4 = 0,
/// STAT_TX [4:5]
/// Status bits, for transmission
STAT_TX: u2 = 0,
/// DTOG_TX [6:6]
/// Data Toggle, for transmission
DTOG_TX: u1 = 0,
/// CTR_TX [7:7]
/// Correct Transfer for
CTR_TX: u1 = 0,
/// EP_KIND [8:8]
/// Endpoint kind
EP_KIND: u1 = 0,
/// EP_TYPE [9:10]
/// Endpoint type
EP_TYPE: u2 = 0,
/// SETUP [11:11]
/// Setup transaction
SETUP: u1 = 0,
/// STAT_RX [12:13]
/// Status bits, for reception
STAT_RX: u2 = 0,
/// DTOG_RX [14:14]
/// Data Toggle, for reception
DTOG_RX: u1 = 0,
/// CTR_RX [15:15]
/// Correct transfer for
CTR_RX: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// endpoint 1 register
pub const EP1R = Register(EP1R_val).init(base_address + 0x4);

/// EP2R
const EP2R_val = packed struct {
/// EA [0:3]
/// Endpoint address
EA: u4 = 0,
/// STAT_TX [4:5]
/// Status bits, for transmission
STAT_TX: u2 = 0,
/// DTOG_TX [6:6]
/// Data Toggle, for transmission
DTOG_TX: u1 = 0,
/// CTR_TX [7:7]
/// Correct Transfer for
CTR_TX: u1 = 0,
/// EP_KIND [8:8]
/// Endpoint kind
EP_KIND: u1 = 0,
/// EP_TYPE [9:10]
/// Endpoint type
EP_TYPE: u2 = 0,
/// SETUP [11:11]
/// Setup transaction
SETUP: u1 = 0,
/// STAT_RX [12:13]
/// Status bits, for reception
STAT_RX: u2 = 0,
/// DTOG_RX [14:14]
/// Data Toggle, for reception
DTOG_RX: u1 = 0,
/// CTR_RX [15:15]
/// Correct transfer for
CTR_RX: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// endpoint 2 register
pub const EP2R = Register(EP2R_val).init(base_address + 0x8);

/// EP3R
const EP3R_val = packed struct {
/// EA [0:3]
/// Endpoint address
EA: u4 = 0,
/// STAT_TX [4:5]
/// Status bits, for transmission
STAT_TX: u2 = 0,
/// DTOG_TX [6:6]
/// Data Toggle, for transmission
DTOG_TX: u1 = 0,
/// CTR_TX [7:7]
/// Correct Transfer for
CTR_TX: u1 = 0,
/// EP_KIND [8:8]
/// Endpoint kind
EP_KIND: u1 = 0,
/// EP_TYPE [9:10]
/// Endpoint type
EP_TYPE: u2 = 0,
/// SETUP [11:11]
/// Setup transaction
SETUP: u1 = 0,
/// STAT_RX [12:13]
/// Status bits, for reception
STAT_RX: u2 = 0,
/// DTOG_RX [14:14]
/// Data Toggle, for reception
DTOG_RX: u1 = 0,
/// CTR_RX [15:15]
/// Correct transfer for
CTR_RX: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// endpoint 3 register
pub const EP3R = Register(EP3R_val).init(base_address + 0xc);

/// EP4R
const EP4R_val = packed struct {
/// EA [0:3]
/// Endpoint address
EA: u4 = 0,
/// STAT_TX [4:5]
/// Status bits, for transmission
STAT_TX: u2 = 0,
/// DTOG_TX [6:6]
/// Data Toggle, for transmission
DTOG_TX: u1 = 0,
/// CTR_TX [7:7]
/// Correct Transfer for
CTR_TX: u1 = 0,
/// EP_KIND [8:8]
/// Endpoint kind
EP_KIND: u1 = 0,
/// EP_TYPE [9:10]
/// Endpoint type
EP_TYPE: u2 = 0,
/// SETUP [11:11]
/// Setup transaction
SETUP: u1 = 0,
/// STAT_RX [12:13]
/// Status bits, for reception
STAT_RX: u2 = 0,
/// DTOG_RX [14:14]
/// Data Toggle, for reception
DTOG_RX: u1 = 0,
/// CTR_RX [15:15]
/// Correct transfer for
CTR_RX: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// endpoint 4 register
pub const EP4R = Register(EP4R_val).init(base_address + 0x10);

/// EP5R
const EP5R_val = packed struct {
/// EA [0:3]
/// Endpoint address
EA: u4 = 0,
/// STAT_TX [4:5]
/// Status bits, for transmission
STAT_TX: u2 = 0,
/// DTOG_TX [6:6]
/// Data Toggle, for transmission
DTOG_TX: u1 = 0,
/// CTR_TX [7:7]
/// Correct Transfer for
CTR_TX: u1 = 0,
/// EP_KIND [8:8]
/// Endpoint kind
EP_KIND: u1 = 0,
/// EP_TYPE [9:10]
/// Endpoint type
EP_TYPE: u2 = 0,
/// SETUP [11:11]
/// Setup transaction
SETUP: u1 = 0,
/// STAT_RX [12:13]
/// Status bits, for reception
STAT_RX: u2 = 0,
/// DTOG_RX [14:14]
/// Data Toggle, for reception
DTOG_RX: u1 = 0,
/// CTR_RX [15:15]
/// Correct transfer for
CTR_RX: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// endpoint 5 register
pub const EP5R = Register(EP5R_val).init(base_address + 0x14);

/// EP6R
const EP6R_val = packed struct {
/// EA [0:3]
/// Endpoint address
EA: u4 = 0,
/// STAT_TX [4:5]
/// Status bits, for transmission
STAT_TX: u2 = 0,
/// DTOG_TX [6:6]
/// Data Toggle, for transmission
DTOG_TX: u1 = 0,
/// CTR_TX [7:7]
/// Correct Transfer for
CTR_TX: u1 = 0,
/// EP_KIND [8:8]
/// Endpoint kind
EP_KIND: u1 = 0,
/// EP_TYPE [9:10]
/// Endpoint type
EP_TYPE: u2 = 0,
/// SETUP [11:11]
/// Setup transaction
SETUP: u1 = 0,
/// STAT_RX [12:13]
/// Status bits, for reception
STAT_RX: u2 = 0,
/// DTOG_RX [14:14]
/// Data Toggle, for reception
DTOG_RX: u1 = 0,
/// CTR_RX [15:15]
/// Correct transfer for
CTR_RX: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// endpoint 6 register
pub const EP6R = Register(EP6R_val).init(base_address + 0x18);

/// EP7R
const EP7R_val = packed struct {
/// EA [0:3]
/// Endpoint address
EA: u4 = 0,
/// STAT_TX [4:5]
/// Status bits, for transmission
STAT_TX: u2 = 0,
/// DTOG_TX [6:6]
/// Data Toggle, for transmission
DTOG_TX: u1 = 0,
/// CTR_TX [7:7]
/// Correct Transfer for
CTR_TX: u1 = 0,
/// EP_KIND [8:8]
/// Endpoint kind
EP_KIND: u1 = 0,
/// EP_TYPE [9:10]
/// Endpoint type
EP_TYPE: u2 = 0,
/// SETUP [11:11]
/// Setup transaction
SETUP: u1 = 0,
/// STAT_RX [12:13]
/// Status bits, for reception
STAT_RX: u2 = 0,
/// DTOG_RX [14:14]
/// Data Toggle, for reception
DTOG_RX: u1 = 0,
/// CTR_RX [15:15]
/// Correct transfer for
CTR_RX: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// endpoint 7 register
pub const EP7R = Register(EP7R_val).init(base_address + 0x1c);

/// CNTR
const CNTR_val = packed struct {
/// FRES [0:0]
/// Force USB Reset
FRES: u1 = 1,
/// PDWN [1:1]
/// Power down
PDWN: u1 = 1,
/// LPMODE [2:2]
/// Low-power mode
LPMODE: u1 = 0,
/// FSUSP [3:3]
/// Force suspend
FSUSP: u1 = 0,
/// RESUME [4:4]
/// Resume request
RESUME: u1 = 0,
/// L1RESUME [5:5]
/// LPM L1 Resume request
L1RESUME: u1 = 0,
/// unused [6:6]
_unused6: u1 = 0,
/// L1REQM [7:7]
/// LPM L1 state request interrupt
L1REQM: u1 = 0,
/// ESOFM [8:8]
/// Expected start of frame interrupt
ESOFM: u1 = 0,
/// SOFM [9:9]
/// Start of frame interrupt
SOFM: u1 = 0,
/// RESETM [10:10]
/// USB reset interrupt mask
RESETM: u1 = 0,
/// SUSPM [11:11]
/// Suspend mode interrupt
SUSPM: u1 = 0,
/// WKUPM [12:12]
/// Wakeup interrupt mask
WKUPM: u1 = 0,
/// ERRM [13:13]
/// Error interrupt mask
ERRM: u1 = 0,
/// PMAOVRM [14:14]
/// Packet memory area over / underrun
PMAOVRM: u1 = 0,
/// CTRM [15:15]
/// Correct transfer interrupt
CTRM: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// control register
pub const CNTR = Register(CNTR_val).init(base_address + 0x40);

/// ISTR
const ISTR_val = packed struct {
/// EP_ID [0:3]
/// Endpoint Identifier
EP_ID: u4 = 0,
/// DIR [4:4]
/// Direction of transaction
DIR: u1 = 0,
/// unused [5:6]
_unused5: u2 = 0,
/// L1REQ [7:7]
/// LPM L1 state request
L1REQ: u1 = 0,
/// ESOF [8:8]
/// Expected start frame
ESOF: u1 = 0,
/// SOF [9:9]
/// start of frame
SOF: u1 = 0,
/// RESET [10:10]
/// reset request
RESET: u1 = 0,
/// SUSP [11:11]
/// Suspend mode request
SUSP: u1 = 0,
/// WKUP [12:12]
/// Wakeup
WKUP: u1 = 0,
/// ERR [13:13]
/// Error
ERR: u1 = 0,
/// PMAOVR [14:14]
/// Packet memory area over /
PMAOVR: u1 = 0,
/// CTR [15:15]
/// Correct transfer
CTR: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// interrupt status register
pub const ISTR = Register(ISTR_val).init(base_address + 0x44);

/// FNR
const FNR_val = packed struct {
/// FN [0:10]
/// Frame number
FN: u11 = 0,
/// LSOF [11:12]
/// Lost SOF
LSOF: u2 = 0,
/// LCK [13:13]
/// Locked
LCK: u1 = 0,
/// RXDM [14:14]
/// Receive data - line status
RXDM: u1 = 0,
/// RXDP [15:15]
/// Receive data + line status
RXDP: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// frame number register
pub const FNR = Register(FNR_val).init(base_address + 0x48);

/// DADDR
const DADDR_val = packed struct {
/// ADD [0:6]
/// Device address
ADD: u7 = 0,
/// EF [7:7]
/// Enable function
EF: u1 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// device address
pub const DADDR = Register(DADDR_val).init(base_address + 0x4c);

/// BTABLE
const BTABLE_val = packed struct {
/// unused [0:2]
_unused0: u3 = 0,
/// BTABLE [3:15]
/// Buffer table
BTABLE: u13 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Buffer table address
pub const BTABLE = Register(BTABLE_val).init(base_address + 0x50);

/// LPMCSR
const LPMCSR_val = packed struct {
/// LPMEN [0:0]
/// LPM support enable
LPMEN: u1 = 0,
/// LPMACK [1:1]
/// LPM Token acknowledge
LPMACK: u1 = 0,
/// unused [2:2]
_unused2: u1 = 0,
/// REMWAKE [3:3]
/// bRemoteWake value
REMWAKE: u1 = 0,
/// BESL [4:7]
/// BESL value
BESL: u4 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// LPM control and status
pub const LPMCSR = Register(LPMCSR_val).init(base_address + 0x54);

/// BCDR
const BCDR_val = packed struct {
/// BCDEN [0:0]
/// Battery charging detector
BCDEN: u1 = 0,
/// DCDEN [1:1]
/// Data contact detection
DCDEN: u1 = 0,
/// PDEN [2:2]
/// Primary detection
PDEN: u1 = 0,
/// SDEN [3:3]
/// Secondary detection
SDEN: u1 = 0,
/// DCDET [4:4]
/// Data contact detection
DCDET: u1 = 0,
/// PDET [5:5]
/// Primary detection
PDET: u1 = 0,
/// SDET [6:6]
/// Secondary detection
SDET: u1 = 0,
/// PS2DET [7:7]
/// DM pull-up detection
PS2DET: u1 = 0,
/// unused [8:14]
_unused8: u7 = 0,
/// DPPU [15:15]
/// DP pull-up control
DPPU: u1 = 0,
/// unused [16:31]
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Battery charging detector
pub const BCDR = Register(BCDR_val).init(base_address + 0x58);
};

/// Memory protection unit
pub const MPU = struct {

const base_address = 0xe000ed90;
/// MPU_TYPER
const MPU_TYPER_val = packed struct {
/// SEPARATE [0:0]
/// Separate flag
SEPARATE: u1 = 0,
/// unused [1:7]
_unused1: u7 = 0,
/// DREGION [8:15]
/// Number of MPU data regions
DREGION: u8 = 8,
/// IREGION [16:23]
/// Number of MPU instruction
IREGION: u8 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// MPU type register
pub const MPU_TYPER = Register(MPU_TYPER_val).init(base_address + 0x0);

/// MPU_CTRL
const MPU_CTRL_val = packed struct {
/// ENABLE [0:0]
/// Enables the MPU
ENABLE: u1 = 0,
/// HFNMIENA [1:1]
/// Enables the operation of MPU during hard
HFNMIENA: u1 = 0,
/// PRIVDEFENA [2:2]
/// Enable priviliged software access to
PRIVDEFENA: u1 = 0,
/// unused [3:31]
_unused3: u5 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// MPU control register
pub const MPU_CTRL = Register(MPU_CTRL_val).init(base_address + 0x4);

/// MPU_RNR
const MPU_RNR_val = packed struct {
/// REGION [0:7]
/// MPU region
REGION: u8 = 0,
/// unused [8:31]
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// MPU region number register
pub const MPU_RNR = Register(MPU_RNR_val).init(base_address + 0x8);

/// MPU_RBAR
const MPU_RBAR_val = packed struct {
/// REGION [0:3]
/// MPU region field
REGION: u4 = 0,
/// VALID [4:4]
/// MPU region number valid
VALID: u1 = 0,
/// ADDR [5:31]
/// Region base address field
ADDR: u27 = 0,
};
/// MPU region base address
pub const MPU_RBAR = Register(MPU_RBAR_val).init(base_address + 0xc);

/// MPU_RASR
const MPU_RASR_val = packed struct {
/// ENABLE [0:0]
/// Region enable bit.
ENABLE: u1 = 0,
/// SIZE [1:5]
/// Size of the MPU protection
SIZE: u5 = 0,
/// unused [6:7]
_unused6: u2 = 0,
/// SRD [8:15]
/// Subregion disable bits
SRD: u8 = 0,
/// B [16:16]
/// memory attribute
B: u1 = 0,
/// C [17:17]
/// memory attribute
C: u1 = 0,
/// S [18:18]
/// Shareable memory attribute
S: u1 = 0,
/// TEX [19:21]
/// memory attribute
TEX: u3 = 0,
/// unused [22:23]
_unused22: u2 = 0,
/// AP [24:26]
/// Access permission
AP: u3 = 0,
/// unused [27:27]
_unused27: u1 = 0,
/// XN [28:28]
/// Instruction access disable
XN: u1 = 0,
/// unused [29:31]
_unused29: u3 = 0,
};
/// MPU region attribute and size
pub const MPU_RASR = Register(MPU_RASR_val).init(base_address + 0x10);
};

/// SysTick timer
pub const STK = struct {

const base_address = 0xe000e010;
/// CSR
const CSR_val = packed struct {
/// ENABLE [0:0]
/// Counter enable
ENABLE: u1 = 0,
/// TICKINT [1:1]
/// SysTick exception request
TICKINT: u1 = 0,
/// CLKSOURCE [2:2]
/// Clock source selection
CLKSOURCE: u1 = 0,
/// unused [3:15]
_unused3: u5 = 0,
_unused8: u8 = 0,
/// COUNTFLAG [16:16]
/// COUNTFLAG
COUNTFLAG: u1 = 0,
/// unused [17:31]
_unused17: u7 = 0,
_unused24: u8 = 0,
};
/// SysTick control and status
pub const CSR = Register(CSR_val).init(base_address + 0x0);

/// RVR
const RVR_val = packed struct {
/// RELOAD [0:23]
/// RELOAD value
RELOAD: u24 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// SysTick reload value register
pub const RVR = Register(RVR_val).init(base_address + 0x4);

/// CVR
const CVR_val = packed struct {
/// CURRENT [0:23]
/// Current counter value
CURRENT: u24 = 0,
/// unused [24:31]
_unused24: u8 = 0,
};
/// SysTick current value register
pub const CVR = Register(CVR_val).init(base_address + 0x8);

/// CALIB
const CALIB_val = packed struct {
/// TENMS [0:23]
/// Calibration value
TENMS: u24 = 0,
/// unused [24:29]
_unused24: u6 = 0,
/// SKEW [30:30]
/// SKEW flag: Indicates whether the TENMS
SKEW: u1 = 0,
/// NOREF [31:31]
/// NOREF flag. Reads as zero
NOREF: u1 = 0,
};
/// SysTick calibration value
pub const CALIB = Register(CALIB_val).init(base_address + 0xc);
};

/// System control block
pub const SCB = struct {

const base_address = 0xe000ed00;
/// CPUID
const CPUID_val = packed struct {
/// Revision [0:3]
/// Revision number
Revision: u4 = 1,
/// PartNo [4:15]
/// Part number of the
PartNo: u12 = 3108,
/// Architecture [16:19]
/// Reads as 0xF
Architecture: u4 = 15,
/// Variant [20:23]
/// Variant number
Variant: u4 = 0,
/// Implementer [24:31]
/// Implementer code
Implementer: u8 = 65,
};
/// CPUID base register
pub const CPUID = Register(CPUID_val).init(base_address + 0x0);

/// ICSR
const ICSR_val = packed struct {
/// VECTACTIVE [0:8]
/// Active vector
VECTACTIVE: u9 = 0,
/// unused [9:10]
_unused9: u2 = 0,
/// RETTOBASE [11:11]
/// Return to base level
RETTOBASE: u1 = 0,
/// VECTPENDING [12:18]
/// Pending vector
VECTPENDING: u7 = 0,
/// unused [19:21]
_unused19: u3 = 0,
/// ISRPENDING [22:22]
/// Interrupt pending flag
ISRPENDING: u1 = 0,
/// unused [23:24]
_unused23: u1 = 0,
_unused24: u1 = 0,
/// PENDSTCLR [25:25]
/// SysTick exception clear-pending
PENDSTCLR: u1 = 0,
/// PENDSTSET [26:26]
/// SysTick exception set-pending
PENDSTSET: u1 = 0,
/// PENDSVCLR [27:27]
/// PendSV clear-pending bit
PENDSVCLR: u1 = 0,
/// PENDSVSET [28:28]
/// PendSV set-pending bit
PENDSVSET: u1 = 0,
/// unused [29:30]
_unused29: u2 = 0,
/// NMIPENDSET [31:31]
/// NMI set-pending bit.
NMIPENDSET: u1 = 0,
};
/// Interrupt control and state
pub const ICSR = Register(ICSR_val).init(base_address + 0x4);

/// VTOR
const VTOR_val = packed struct {
/// unused [0:6]
_unused0: u7 = 0,
/// TBLOFF [7:31]
/// Vector table base offset
TBLOFF: u25 = 0,
};
/// Vector table offset register
pub const VTOR = Register(VTOR_val).init(base_address + 0x8);

/// AIRCR
const AIRCR_val = packed struct {
/// unused [0:0]
_unused0: u1 = 0,
/// VECTCLRACTIVE [1:1]
/// VECTCLRACTIVE
VECTCLRACTIVE: u1 = 0,
/// SYSRESETREQ [2:2]
/// SYSRESETREQ
SYSRESETREQ: u1 = 0,
/// unused [3:14]
_unused3: u5 = 0,
_unused8: u7 = 0,
/// ENDIANESS [15:15]
/// ENDIANESS
ENDIANESS: u1 = 0,
/// VECTKEYSTAT [16:31]
/// Register key
VECTKEYSTAT: u16 = 0,
};
/// Application interrupt and reset control
pub const AIRCR = Register(AIRCR_val).init(base_address + 0xc);

/// SCR
const SCR_val = packed struct {
/// unused [0:0]
_unused0: u1 = 0,
/// SLEEPONEXIT [1:1]
/// SLEEPONEXIT
SLEEPONEXIT: u1 = 0,
/// SLEEPDEEP [2:2]
/// SLEEPDEEP
SLEEPDEEP: u1 = 0,
/// unused [3:3]
_unused3: u1 = 0,
/// SEVEONPEND [4:4]
/// Send Event on Pending bit
SEVEONPEND: u1 = 0,
/// unused [5:31]
_unused5: u3 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// System control register
pub const SCR = Register(SCR_val).init(base_address + 0x10);

/// CCR
const CCR_val = packed struct {
/// NONBASETHRDENA [0:0]
/// Configures how the processor enters
NONBASETHRDENA: u1 = 0,
/// USERSETMPEND [1:1]
/// USERSETMPEND
USERSETMPEND: u1 = 0,
/// unused [2:2]
_unused2: u1 = 0,
/// UNALIGN__TRP [3:3]
/// UNALIGN_ TRP
UNALIGN__TRP: u1 = 0,
/// DIV_0_TRP [4:4]
/// DIV_0_TRP
DIV_0_TRP: u1 = 0,
/// unused [5:7]
_unused5: u3 = 0,
/// BFHFNMIGN [8:8]
/// BFHFNMIGN
BFHFNMIGN: u1 = 0,
/// STKALIGN [9:9]
/// STKALIGN
STKALIGN: u1 = 0,
/// unused [10:31]
_unused10: u6 = 0,
_unused16: u8 = 0,
_unused24: u8 = 0,
};
/// Configuration and control
pub const CCR = Register(CCR_val).init(base_address + 0x14);

/// SHPR2
const SHPR2_val = packed struct {
/// unused [0:23]
_unused0: u8 = 0,
_unused8: u8 = 0,
_unused16: u8 = 0,
/// PRI_11 [24:31]
/// Priority of system handler
PRI_11: u8 = 0,
};
/// System handler priority
pub const SHPR2 = Register(SHPR2_val).init(base_address + 0x1c);

/// SHPR3
const SHPR3_val = packed struct {
/// unused [0:15]
_unused0: u8 = 0,
_unused8: u8 = 0,
/// PRI_14 [16:23]
/// Priority of system handler
PRI_14: u8 = 0,
/// PRI_15 [24:31]
/// Priority of system handler
PRI_15: u8 = 0,
};
/// System handler priority
pub const SHPR3 = Register(SHPR3_val).init(base_address + 0x20);
};
pub const interrupts = struct {
pub const SPI2 = 26;
pub const TIM22 = 22;
pub const TIM6_DAC = 17;
pub const DMA1_Channel1 = 9;
pub const I2C1 = 23;
pub const USART1 = 27;
pub const EXTI2_3 = 6;
pub const RTC = 2;
pub const USB = 31;
pub const I2C3 = 21;
pub const EXTI4_15 = 7;
pub const USART2 = 28;
pub const ADC_COMP = 12;
pub const WWDG = 0;
pub const USART4_USART5 = 14;
pub const TSC = 8;
pub const EXTI0_1 = 5;
pub const TIM7 = 18;
pub const SPI1 = 25;
pub const TIM3 = 16;
pub const TIM21 = 20;
pub const AES_RNG_LPUART1 = 29;
pub const RCC = 4;
pub const LPTIM1 = 13;
pub const I2C2 = 24;
pub const DMA1_Channel4_7 = 11;
pub const PVD = 1;
pub const TIM2 = 15;
pub const DMA1_Channel2_3 = 10;
};
