
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
#include <memlayout.h>

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    la sp, bootstacktop
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp

    tail kern_init
    80200008:	0040006f          	j	8020000c <kern_init>

000000008020000c <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    8020000c:	00004517          	auipc	a0,0x4
    80200010:	00450513          	addi	a0,a0,4 # 80204010 <edata>
    80200014:	00004617          	auipc	a2,0x4
    80200018:	01460613          	addi	a2,a2,20 # 80204028 <end>
int kern_init(void) {
    8020001c:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
    8020001e:	8e09                	sub	a2,a2,a0
    80200020:	4581                	li	a1,0
int kern_init(void) {
    80200022:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200024:	22d000ef          	jal	ra,80200a50 <memset>

    cons_init();  // init the console
    80200028:	14c000ef          	jal	ra,80200174 <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002c:	00001597          	auipc	a1,0x1
    80200030:	a3c58593          	addi	a1,a1,-1476 # 80200a68 <etext+0x6>
    80200034:	00001517          	auipc	a0,0x1
    80200038:	a5450513          	addi	a0,a0,-1452 # 80200a88 <etext+0x26>
    8020003c:	030000ef          	jal	ra,8020006c <cprintf>

    print_kerninfo();
    80200040:	060000ef          	jal	ra,802000a0 <print_kerninfo>

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200044:	140000ef          	jal	ra,80200184 <idt_init>

    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    80200048:	0e8000ef          	jal	ra,80200130 <clock_init>

    intr_enable();  // enable irq interrupt
    8020004c:	132000ef          	jal	ra,8020017e <intr_enable>
    
    while (1)
        ;
    80200050:	a001                	j	80200050 <kern_init+0x44>

0000000080200052 <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    80200052:	1141                	addi	sp,sp,-16
    80200054:	e022                	sd	s0,0(sp)
    80200056:	e406                	sd	ra,8(sp)
    80200058:	842e                	mv	s0,a1
    cons_putc(c);
    8020005a:	11c000ef          	jal	ra,80200176 <cons_putc>
    (*cnt)++;
    8020005e:	401c                	lw	a5,0(s0)
}
    80200060:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    80200062:	2785                	addiw	a5,a5,1
    80200064:	c01c                	sw	a5,0(s0)
}
    80200066:	6402                	ld	s0,0(sp)
    80200068:	0141                	addi	sp,sp,16
    8020006a:	8082                	ret

000000008020006c <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    8020006c:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    8020006e:	02810313          	addi	t1,sp,40 # 80204028 <end>
int cprintf(const char *fmt, ...) {
    80200072:	f42e                	sd	a1,40(sp)
    80200074:	f832                	sd	a2,48(sp)
    80200076:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200078:	862a                	mv	a2,a0
    8020007a:	004c                	addi	a1,sp,4
    8020007c:	00000517          	auipc	a0,0x0
    80200080:	fd650513          	addi	a0,a0,-42 # 80200052 <cputch>
    80200084:	869a                	mv	a3,t1
int cprintf(const char *fmt, ...) {
    80200086:	ec06                	sd	ra,24(sp)
    80200088:	e0ba                	sd	a4,64(sp)
    8020008a:	e4be                	sd	a5,72(sp)
    8020008c:	e8c2                	sd	a6,80(sp)
    8020008e:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    80200090:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    80200092:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200094:	5b6000ef          	jal	ra,8020064a <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    80200098:	60e2                	ld	ra,24(sp)
    8020009a:	4512                	lw	a0,4(sp)
    8020009c:	6125                	addi	sp,sp,96
    8020009e:	8082                	ret

00000000802000a0 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
    802000a0:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
    802000a2:	00001517          	auipc	a0,0x1
    802000a6:	9ee50513          	addi	a0,a0,-1554 # 80200a90 <etext+0x2e>
void print_kerninfo(void) {
    802000aa:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000ac:	fc1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000b0:	00000597          	auipc	a1,0x0
    802000b4:	f5c58593          	addi	a1,a1,-164 # 8020000c <kern_init>
    802000b8:	00001517          	auipc	a0,0x1
    802000bc:	9f850513          	addi	a0,a0,-1544 # 80200ab0 <etext+0x4e>
    802000c0:	fadff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000c4:	00001597          	auipc	a1,0x1
    802000c8:	99e58593          	addi	a1,a1,-1634 # 80200a62 <etext>
    802000cc:	00001517          	auipc	a0,0x1
    802000d0:	a0450513          	addi	a0,a0,-1532 # 80200ad0 <etext+0x6e>
    802000d4:	f99ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000d8:	00004597          	auipc	a1,0x4
    802000dc:	f3858593          	addi	a1,a1,-200 # 80204010 <edata>
    802000e0:	00001517          	auipc	a0,0x1
    802000e4:	a1050513          	addi	a0,a0,-1520 # 80200af0 <etext+0x8e>
    802000e8:	f85ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000ec:	00004597          	auipc	a1,0x4
    802000f0:	f3c58593          	addi	a1,a1,-196 # 80204028 <end>
    802000f4:	00001517          	auipc	a0,0x1
    802000f8:	a1c50513          	addi	a0,a0,-1508 # 80200b10 <etext+0xae>
    802000fc:	f71ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    80200100:	00004597          	auipc	a1,0x4
    80200104:	32758593          	addi	a1,a1,807 # 80204427 <end+0x3ff>
    80200108:	00000797          	auipc	a5,0x0
    8020010c:	f0478793          	addi	a5,a5,-252 # 8020000c <kern_init>
    80200110:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200114:	43f7d593          	srai	a1,a5,0x3f
}
    80200118:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020011a:	3ff5f593          	andi	a1,a1,1023
    8020011e:	95be                	add	a1,a1,a5
    80200120:	85a9                	srai	a1,a1,0xa
    80200122:	00001517          	auipc	a0,0x1
    80200126:	a0e50513          	addi	a0,a0,-1522 # 80200b30 <etext+0xce>
}
    8020012a:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020012c:	f41ff06f          	j	8020006c <cprintf>

0000000080200130 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    80200130:	1141                	addi	sp,sp,-16
    80200132:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    80200134:	02000793          	li	a5,32
    80200138:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    8020013c:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200140:	67e1                	lui	a5,0x18
    80200142:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    80200146:	953e                	add	a0,a0,a5
    80200148:	0ab000ef          	jal	ra,802009f2 <sbi_set_timer>
}
    8020014c:	60a2                	ld	ra,8(sp)
    ticks = 0;
    8020014e:	00004797          	auipc	a5,0x4
    80200152:	ec07b523          	sd	zero,-310(a5) # 80204018 <ticks>
    cprintf("++ setup timer interrupts\n");
    80200156:	00001517          	auipc	a0,0x1
    8020015a:	a0a50513          	addi	a0,a0,-1526 # 80200b60 <etext+0xfe>
}
    8020015e:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
    80200160:	f0dff06f          	j	8020006c <cprintf>

0000000080200164 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200164:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200168:	67e1                	lui	a5,0x18
    8020016a:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    8020016e:	953e                	add	a0,a0,a5
    80200170:	0830006f          	j	802009f2 <sbi_set_timer>

0000000080200174 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    80200174:	8082                	ret

0000000080200176 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    80200176:	0ff57513          	andi	a0,a0,255
    8020017a:	05d0006f          	j	802009d6 <sbi_console_putchar>

000000008020017e <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
    8020017e:	100167f3          	csrrsi	a5,sstatus,2
    80200182:	8082                	ret

0000000080200184 <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    80200184:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    80200188:	00000797          	auipc	a5,0x0
    8020018c:	3a078793          	addi	a5,a5,928 # 80200528 <__alltraps>
    80200190:	10579073          	csrw	stvec,a5
}
    80200194:	8082                	ret

0000000080200196 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200196:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    80200198:	1141                	addi	sp,sp,-16
    8020019a:	e022                	sd	s0,0(sp)
    8020019c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    8020019e:	00001517          	auipc	a0,0x1
    802001a2:	b0a50513          	addi	a0,a0,-1270 # 80200ca8 <etext+0x246>
void print_regs(struct pushregs *gpr) {
    802001a6:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001a8:	ec5ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001ac:	640c                	ld	a1,8(s0)
    802001ae:	00001517          	auipc	a0,0x1
    802001b2:	b1250513          	addi	a0,a0,-1262 # 80200cc0 <etext+0x25e>
    802001b6:	eb7ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001ba:	680c                	ld	a1,16(s0)
    802001bc:	00001517          	auipc	a0,0x1
    802001c0:	b1c50513          	addi	a0,a0,-1252 # 80200cd8 <etext+0x276>
    802001c4:	ea9ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001c8:	6c0c                	ld	a1,24(s0)
    802001ca:	00001517          	auipc	a0,0x1
    802001ce:	b2650513          	addi	a0,a0,-1242 # 80200cf0 <etext+0x28e>
    802001d2:	e9bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001d6:	700c                	ld	a1,32(s0)
    802001d8:	00001517          	auipc	a0,0x1
    802001dc:	b3050513          	addi	a0,a0,-1232 # 80200d08 <etext+0x2a6>
    802001e0:	e8dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001e4:	740c                	ld	a1,40(s0)
    802001e6:	00001517          	auipc	a0,0x1
    802001ea:	b3a50513          	addi	a0,a0,-1222 # 80200d20 <etext+0x2be>
    802001ee:	e7fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001f2:	780c                	ld	a1,48(s0)
    802001f4:	00001517          	auipc	a0,0x1
    802001f8:	b4450513          	addi	a0,a0,-1212 # 80200d38 <etext+0x2d6>
    802001fc:	e71ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    80200200:	7c0c                	ld	a1,56(s0)
    80200202:	00001517          	auipc	a0,0x1
    80200206:	b4e50513          	addi	a0,a0,-1202 # 80200d50 <etext+0x2ee>
    8020020a:	e63ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    8020020e:	602c                	ld	a1,64(s0)
    80200210:	00001517          	auipc	a0,0x1
    80200214:	b5850513          	addi	a0,a0,-1192 # 80200d68 <etext+0x306>
    80200218:	e55ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    8020021c:	642c                	ld	a1,72(s0)
    8020021e:	00001517          	auipc	a0,0x1
    80200222:	b6250513          	addi	a0,a0,-1182 # 80200d80 <etext+0x31e>
    80200226:	e47ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    8020022a:	682c                	ld	a1,80(s0)
    8020022c:	00001517          	auipc	a0,0x1
    80200230:	b6c50513          	addi	a0,a0,-1172 # 80200d98 <etext+0x336>
    80200234:	e39ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    80200238:	6c2c                	ld	a1,88(s0)
    8020023a:	00001517          	auipc	a0,0x1
    8020023e:	b7650513          	addi	a0,a0,-1162 # 80200db0 <etext+0x34e>
    80200242:	e2bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    80200246:	702c                	ld	a1,96(s0)
    80200248:	00001517          	auipc	a0,0x1
    8020024c:	b8050513          	addi	a0,a0,-1152 # 80200dc8 <etext+0x366>
    80200250:	e1dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    80200254:	742c                	ld	a1,104(s0)
    80200256:	00001517          	auipc	a0,0x1
    8020025a:	b8a50513          	addi	a0,a0,-1142 # 80200de0 <etext+0x37e>
    8020025e:	e0fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    80200262:	782c                	ld	a1,112(s0)
    80200264:	00001517          	auipc	a0,0x1
    80200268:	b9450513          	addi	a0,a0,-1132 # 80200df8 <etext+0x396>
    8020026c:	e01ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    80200270:	7c2c                	ld	a1,120(s0)
    80200272:	00001517          	auipc	a0,0x1
    80200276:	b9e50513          	addi	a0,a0,-1122 # 80200e10 <etext+0x3ae>
    8020027a:	df3ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    8020027e:	604c                	ld	a1,128(s0)
    80200280:	00001517          	auipc	a0,0x1
    80200284:	ba850513          	addi	a0,a0,-1112 # 80200e28 <etext+0x3c6>
    80200288:	de5ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    8020028c:	644c                	ld	a1,136(s0)
    8020028e:	00001517          	auipc	a0,0x1
    80200292:	bb250513          	addi	a0,a0,-1102 # 80200e40 <etext+0x3de>
    80200296:	dd7ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    8020029a:	684c                	ld	a1,144(s0)
    8020029c:	00001517          	auipc	a0,0x1
    802002a0:	bbc50513          	addi	a0,a0,-1092 # 80200e58 <etext+0x3f6>
    802002a4:	dc9ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002a8:	6c4c                	ld	a1,152(s0)
    802002aa:	00001517          	auipc	a0,0x1
    802002ae:	bc650513          	addi	a0,a0,-1082 # 80200e70 <etext+0x40e>
    802002b2:	dbbff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002b6:	704c                	ld	a1,160(s0)
    802002b8:	00001517          	auipc	a0,0x1
    802002bc:	bd050513          	addi	a0,a0,-1072 # 80200e88 <etext+0x426>
    802002c0:	dadff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002c4:	744c                	ld	a1,168(s0)
    802002c6:	00001517          	auipc	a0,0x1
    802002ca:	bda50513          	addi	a0,a0,-1062 # 80200ea0 <etext+0x43e>
    802002ce:	d9fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002d2:	784c                	ld	a1,176(s0)
    802002d4:	00001517          	auipc	a0,0x1
    802002d8:	be450513          	addi	a0,a0,-1052 # 80200eb8 <etext+0x456>
    802002dc:	d91ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002e0:	7c4c                	ld	a1,184(s0)
    802002e2:	00001517          	auipc	a0,0x1
    802002e6:	bee50513          	addi	a0,a0,-1042 # 80200ed0 <etext+0x46e>
    802002ea:	d83ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002ee:	606c                	ld	a1,192(s0)
    802002f0:	00001517          	auipc	a0,0x1
    802002f4:	bf850513          	addi	a0,a0,-1032 # 80200ee8 <etext+0x486>
    802002f8:	d75ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    802002fc:	646c                	ld	a1,200(s0)
    802002fe:	00001517          	auipc	a0,0x1
    80200302:	c0250513          	addi	a0,a0,-1022 # 80200f00 <etext+0x49e>
    80200306:	d67ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    8020030a:	686c                	ld	a1,208(s0)
    8020030c:	00001517          	auipc	a0,0x1
    80200310:	c0c50513          	addi	a0,a0,-1012 # 80200f18 <etext+0x4b6>
    80200314:	d59ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    80200318:	6c6c                	ld	a1,216(s0)
    8020031a:	00001517          	auipc	a0,0x1
    8020031e:	c1650513          	addi	a0,a0,-1002 # 80200f30 <etext+0x4ce>
    80200322:	d4bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    80200326:	706c                	ld	a1,224(s0)
    80200328:	00001517          	auipc	a0,0x1
    8020032c:	c2050513          	addi	a0,a0,-992 # 80200f48 <etext+0x4e6>
    80200330:	d3dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    80200334:	746c                	ld	a1,232(s0)
    80200336:	00001517          	auipc	a0,0x1
    8020033a:	c2a50513          	addi	a0,a0,-982 # 80200f60 <etext+0x4fe>
    8020033e:	d2fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    80200342:	786c                	ld	a1,240(s0)
    80200344:	00001517          	auipc	a0,0x1
    80200348:	c3450513          	addi	a0,a0,-972 # 80200f78 <etext+0x516>
    8020034c:	d21ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200350:	7c6c                	ld	a1,248(s0)
}
    80200352:	6402                	ld	s0,0(sp)
    80200354:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200356:	00001517          	auipc	a0,0x1
    8020035a:	c3a50513          	addi	a0,a0,-966 # 80200f90 <etext+0x52e>
}
    8020035e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200360:	d0dff06f          	j	8020006c <cprintf>

0000000080200364 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    80200364:	1141                	addi	sp,sp,-16
    80200366:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    80200368:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    8020036a:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    8020036c:	00001517          	auipc	a0,0x1
    80200370:	c3c50513          	addi	a0,a0,-964 # 80200fa8 <etext+0x546>
void print_trapframe(struct trapframe *tf) {
    80200374:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    80200376:	cf7ff0ef          	jal	ra,8020006c <cprintf>
    print_regs(&tf->gpr);
    8020037a:	8522                	mv	a0,s0
    8020037c:	e1bff0ef          	jal	ra,80200196 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    80200380:	10043583          	ld	a1,256(s0)
    80200384:	00001517          	auipc	a0,0x1
    80200388:	c3c50513          	addi	a0,a0,-964 # 80200fc0 <etext+0x55e>
    8020038c:	ce1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    80200390:	10843583          	ld	a1,264(s0)
    80200394:	00001517          	auipc	a0,0x1
    80200398:	c4450513          	addi	a0,a0,-956 # 80200fd8 <etext+0x576>
    8020039c:	cd1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    802003a0:	11043583          	ld	a1,272(s0)
    802003a4:	00001517          	auipc	a0,0x1
    802003a8:	c4c50513          	addi	a0,a0,-948 # 80200ff0 <etext+0x58e>
    802003ac:	cc1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b0:	11843583          	ld	a1,280(s0)
}
    802003b4:	6402                	ld	s0,0(sp)
    802003b6:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b8:	00001517          	auipc	a0,0x1
    802003bc:	c5050513          	addi	a0,a0,-944 # 80201008 <etext+0x5a6>
}
    802003c0:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003c2:	cabff06f          	j	8020006c <cprintf>

00000000802003c6 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    802003c6:	11853783          	ld	a5,280(a0)
    802003ca:	577d                	li	a4,-1
    802003cc:	8305                	srli	a4,a4,0x1
    802003ce:	8ff9                	and	a5,a5,a4
    switch (cause) {
    802003d0:	472d                	li	a4,11
    802003d2:	08f76963          	bltu	a4,a5,80200464 <interrupt_handler+0x9e>
    802003d6:	00000717          	auipc	a4,0x0
    802003da:	7a670713          	addi	a4,a4,1958 # 80200b7c <etext+0x11a>
    802003de:	078a                	slli	a5,a5,0x2
    802003e0:	97ba                	add	a5,a5,a4
    802003e2:	439c                	lw	a5,0(a5)
    802003e4:	97ba                	add	a5,a5,a4
    802003e6:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003e8:	00001517          	auipc	a0,0x1
    802003ec:	87050513          	addi	a0,a0,-1936 # 80200c58 <etext+0x1f6>
    802003f0:	c7dff06f          	j	8020006c <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003f4:	00001517          	auipc	a0,0x1
    802003f8:	84450513          	addi	a0,a0,-1980 # 80200c38 <etext+0x1d6>
    802003fc:	c71ff06f          	j	8020006c <cprintf>
            cprintf("User software interrupt\n");
    80200400:	00000517          	auipc	a0,0x0
    80200404:	7f850513          	addi	a0,a0,2040 # 80200bf8 <etext+0x196>
    80200408:	c65ff06f          	j	8020006c <cprintf>
            cprintf("Supervisor software interrupt\n");
    8020040c:	00001517          	auipc	a0,0x1
    80200410:	80c50513          	addi	a0,a0,-2036 # 80200c18 <etext+0x1b6>
    80200414:	c59ff06f          	j	8020006c <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
    80200418:	00001517          	auipc	a0,0x1
    8020041c:	87050513          	addi	a0,a0,-1936 # 80200c88 <etext+0x226>
    80200420:	c4dff06f          	j	8020006c <cprintf>
void interrupt_handler(struct trapframe *tf) {
    80200424:	1141                	addi	sp,sp,-16
    80200426:	e022                	sd	s0,0(sp)
    80200428:	e406                	sd	ra,8(sp)
            clock_set_next_event();
    8020042a:	d3bff0ef          	jal	ra,80200164 <clock_set_next_event>
            ticks++;
    8020042e:	00004717          	auipc	a4,0x4
    80200432:	bea70713          	addi	a4,a4,-1046 # 80204018 <ticks>
    80200436:	631c                	ld	a5,0(a4)
            if(ticks == TICK_NUM){
    80200438:	06400693          	li	a3,100
    8020043c:	00004417          	auipc	s0,0x4
    80200440:	bd440413          	addi	s0,s0,-1068 # 80204010 <edata>
            ticks++;
    80200444:	0785                	addi	a5,a5,1
    80200446:	00004617          	auipc	a2,0x4
    8020044a:	bcf63923          	sd	a5,-1070(a2) # 80204018 <ticks>
            if(ticks == TICK_NUM){
    8020044e:	631c                	ld	a5,0(a4)
    80200450:	00d78c63          	beq	a5,a3,80200468 <interrupt_handler+0xa2>
            if(num == 10)
    80200454:	6018                	ld	a4,0(s0)
    80200456:	47a9                	li	a5,10
    80200458:	02f70b63          	beq	a4,a5,8020048e <interrupt_handler+0xc8>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    8020045c:	60a2                	ld	ra,8(sp)
    8020045e:	6402                	ld	s0,0(sp)
    80200460:	0141                	addi	sp,sp,16
    80200462:	8082                	ret
            print_trapframe(tf);
    80200464:	f01ff06f          	j	80200364 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
    80200468:	06400593          	li	a1,100
    8020046c:	00001517          	auipc	a0,0x1
    80200470:	80c50513          	addi	a0,a0,-2036 # 80200c78 <etext+0x216>
            	ticks = 0;
    80200474:	00004797          	auipc	a5,0x4
    80200478:	ba07b223          	sd	zero,-1116(a5) # 80204018 <ticks>
    cprintf("%d ticks\n", TICK_NUM);
    8020047c:	bf1ff0ef          	jal	ra,8020006c <cprintf>
            	num++;
    80200480:	601c                	ld	a5,0(s0)
    80200482:	0785                	addi	a5,a5,1
    80200484:	00004717          	auipc	a4,0x4
    80200488:	b8f73623          	sd	a5,-1140(a4) # 80204010 <edata>
    8020048c:	b7e1                	j	80200454 <interrupt_handler+0x8e>
}
    8020048e:	6402                	ld	s0,0(sp)
    80200490:	60a2                	ld	ra,8(sp)
    80200492:	0141                	addi	sp,sp,16
            	sbi_shutdown();
    80200494:	57a0006f          	j	80200a0e <sbi_shutdown>

0000000080200498 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
    80200498:	11853783          	ld	a5,280(a0)
    8020049c:	472d                	li	a4,11
    8020049e:	02f76863          	bltu	a4,a5,802004ce <exception_handler+0x36>
    802004a2:	4705                	li	a4,1
    802004a4:	00f71733          	sll	a4,a4,a5
    802004a8:	6785                	lui	a5,0x1
    802004aa:	17cd                	addi	a5,a5,-13
    802004ac:	8ff9                	and	a5,a5,a4
    802004ae:	ef99                	bnez	a5,802004cc <exception_handler+0x34>
void exception_handler(struct trapframe *tf) {
    802004b0:	1141                	addi	sp,sp,-16
    802004b2:	e022                	sd	s0,0(sp)
    802004b4:	e406                	sd	ra,8(sp)
    802004b6:	00877793          	andi	a5,a4,8
    802004ba:	842a                	mv	s0,a0
    802004bc:	ef85                	bnez	a5,802004f4 <exception_handler+0x5c>
    802004be:	8b11                	andi	a4,a4,4
    802004c0:	eb09                	bnez	a4,802004d2 <exception_handler+0x3a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    802004c2:	6402                	ld	s0,0(sp)
    802004c4:	60a2                	ld	ra,8(sp)
    802004c6:	0141                	addi	sp,sp,16
            print_trapframe(tf);
    802004c8:	e9dff06f          	j	80200364 <print_trapframe>
    802004cc:	8082                	ret
    802004ce:	e97ff06f          	j	80200364 <print_trapframe>
            cprintf("Illegal instruction at 0x%01611x\n",tf->epc);
    802004d2:	10853583          	ld	a1,264(a0)
    802004d6:	00000517          	auipc	a0,0x0
    802004da:	6da50513          	addi	a0,a0,1754 # 80200bb0 <etext+0x14e>
    802004de:	b8fff0ef          	jal	ra,8020006c <cprintf>
            tf->epc += 4;
    802004e2:	10843783          	ld	a5,264(s0)
}
    802004e6:	60a2                	ld	ra,8(sp)
            tf->epc += 4;
    802004e8:	0791                	addi	a5,a5,4
    802004ea:	10f43423          	sd	a5,264(s0)
}
    802004ee:	6402                	ld	s0,0(sp)
    802004f0:	0141                	addi	sp,sp,16
    802004f2:	8082                	ret
            cprintf("breakpoint at 0x%01611x\n",tf->epc);
    802004f4:	10853583          	ld	a1,264(a0)
    802004f8:	00000517          	auipc	a0,0x0
    802004fc:	6e050513          	addi	a0,a0,1760 # 80200bd8 <etext+0x176>
    80200500:	b6dff0ef          	jal	ra,8020006c <cprintf>
            tf->epc += 2;
    80200504:	10843783          	ld	a5,264(s0)
}
    80200508:	60a2                	ld	ra,8(sp)
            tf->epc += 2;
    8020050a:	0789                	addi	a5,a5,2
    8020050c:	10f43423          	sd	a5,264(s0)
}
    80200510:	6402                	ld	s0,0(sp)
    80200512:	0141                	addi	sp,sp,16
    80200514:	8082                	ret

0000000080200516 <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    80200516:	11853783          	ld	a5,280(a0)
    8020051a:	0007c463          	bltz	a5,80200522 <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
    8020051e:	f7bff06f          	j	80200498 <exception_handler>
        interrupt_handler(tf);
    80200522:	ea5ff06f          	j	802003c6 <interrupt_handler>
	...

0000000080200528 <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    80200528:	14011073          	csrw	sscratch,sp
    8020052c:	712d                	addi	sp,sp,-288
    8020052e:	e002                	sd	zero,0(sp)
    80200530:	e406                	sd	ra,8(sp)
    80200532:	ec0e                	sd	gp,24(sp)
    80200534:	f012                	sd	tp,32(sp)
    80200536:	f416                	sd	t0,40(sp)
    80200538:	f81a                	sd	t1,48(sp)
    8020053a:	fc1e                	sd	t2,56(sp)
    8020053c:	e0a2                	sd	s0,64(sp)
    8020053e:	e4a6                	sd	s1,72(sp)
    80200540:	e8aa                	sd	a0,80(sp)
    80200542:	ecae                	sd	a1,88(sp)
    80200544:	f0b2                	sd	a2,96(sp)
    80200546:	f4b6                	sd	a3,104(sp)
    80200548:	f8ba                	sd	a4,112(sp)
    8020054a:	fcbe                	sd	a5,120(sp)
    8020054c:	e142                	sd	a6,128(sp)
    8020054e:	e546                	sd	a7,136(sp)
    80200550:	e94a                	sd	s2,144(sp)
    80200552:	ed4e                	sd	s3,152(sp)
    80200554:	f152                	sd	s4,160(sp)
    80200556:	f556                	sd	s5,168(sp)
    80200558:	f95a                	sd	s6,176(sp)
    8020055a:	fd5e                	sd	s7,184(sp)
    8020055c:	e1e2                	sd	s8,192(sp)
    8020055e:	e5e6                	sd	s9,200(sp)
    80200560:	e9ea                	sd	s10,208(sp)
    80200562:	edee                	sd	s11,216(sp)
    80200564:	f1f2                	sd	t3,224(sp)
    80200566:	f5f6                	sd	t4,232(sp)
    80200568:	f9fa                	sd	t5,240(sp)
    8020056a:	fdfe                	sd	t6,248(sp)
    8020056c:	14001473          	csrrw	s0,sscratch,zero
    80200570:	100024f3          	csrr	s1,sstatus
    80200574:	14102973          	csrr	s2,sepc
    80200578:	143029f3          	csrr	s3,stval
    8020057c:	14202a73          	csrr	s4,scause
    80200580:	e822                	sd	s0,16(sp)
    80200582:	e226                	sd	s1,256(sp)
    80200584:	e64a                	sd	s2,264(sp)
    80200586:	ea4e                	sd	s3,272(sp)
    80200588:	ee52                	sd	s4,280(sp)

    move  a0, sp
    8020058a:	850a                	mv	a0,sp
    jal trap
    8020058c:	f8bff0ef          	jal	ra,80200516 <trap>

0000000080200590 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    80200590:	6492                	ld	s1,256(sp)
    80200592:	6932                	ld	s2,264(sp)
    80200594:	10049073          	csrw	sstatus,s1
    80200598:	14191073          	csrw	sepc,s2
    8020059c:	60a2                	ld	ra,8(sp)
    8020059e:	61e2                	ld	gp,24(sp)
    802005a0:	7202                	ld	tp,32(sp)
    802005a2:	72a2                	ld	t0,40(sp)
    802005a4:	7342                	ld	t1,48(sp)
    802005a6:	73e2                	ld	t2,56(sp)
    802005a8:	6406                	ld	s0,64(sp)
    802005aa:	64a6                	ld	s1,72(sp)
    802005ac:	6546                	ld	a0,80(sp)
    802005ae:	65e6                	ld	a1,88(sp)
    802005b0:	7606                	ld	a2,96(sp)
    802005b2:	76a6                	ld	a3,104(sp)
    802005b4:	7746                	ld	a4,112(sp)
    802005b6:	77e6                	ld	a5,120(sp)
    802005b8:	680a                	ld	a6,128(sp)
    802005ba:	68aa                	ld	a7,136(sp)
    802005bc:	694a                	ld	s2,144(sp)
    802005be:	69ea                	ld	s3,152(sp)
    802005c0:	7a0a                	ld	s4,160(sp)
    802005c2:	7aaa                	ld	s5,168(sp)
    802005c4:	7b4a                	ld	s6,176(sp)
    802005c6:	7bea                	ld	s7,184(sp)
    802005c8:	6c0e                	ld	s8,192(sp)
    802005ca:	6cae                	ld	s9,200(sp)
    802005cc:	6d4e                	ld	s10,208(sp)
    802005ce:	6dee                	ld	s11,216(sp)
    802005d0:	7e0e                	ld	t3,224(sp)
    802005d2:	7eae                	ld	t4,232(sp)
    802005d4:	7f4e                	ld	t5,240(sp)
    802005d6:	7fee                	ld	t6,248(sp)
    802005d8:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    802005da:	10200073          	sret

00000000802005de <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    802005de:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802005e2:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    802005e4:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802005e8:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    802005ea:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    802005ee:	f022                	sd	s0,32(sp)
    802005f0:	ec26                	sd	s1,24(sp)
    802005f2:	e84a                	sd	s2,16(sp)
    802005f4:	f406                	sd	ra,40(sp)
    802005f6:	e44e                	sd	s3,8(sp)
    802005f8:	84aa                	mv	s1,a0
    802005fa:	892e                	mv	s2,a1
    802005fc:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    80200600:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
    80200602:	03067e63          	bleu	a6,a2,8020063e <printnum+0x60>
    80200606:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    80200608:	00805763          	blez	s0,80200616 <printnum+0x38>
    8020060c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    8020060e:	85ca                	mv	a1,s2
    80200610:	854e                	mv	a0,s3
    80200612:	9482                	jalr	s1
        while (-- width > 0)
    80200614:	fc65                	bnez	s0,8020060c <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    80200616:	1a02                	slli	s4,s4,0x20
    80200618:	020a5a13          	srli	s4,s4,0x20
    8020061c:	00001797          	auipc	a5,0x1
    80200620:	b9478793          	addi	a5,a5,-1132 # 802011b0 <error_string+0x38>
    80200624:	9a3e                	add	s4,s4,a5
}
    80200626:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200628:	000a4503          	lbu	a0,0(s4)
}
    8020062c:	70a2                	ld	ra,40(sp)
    8020062e:	69a2                	ld	s3,8(sp)
    80200630:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200632:	85ca                	mv	a1,s2
    80200634:	8326                	mv	t1,s1
}
    80200636:	6942                	ld	s2,16(sp)
    80200638:	64e2                	ld	s1,24(sp)
    8020063a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    8020063c:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
    8020063e:	03065633          	divu	a2,a2,a6
    80200642:	8722                	mv	a4,s0
    80200644:	f9bff0ef          	jal	ra,802005de <printnum>
    80200648:	b7f9                	j	80200616 <printnum+0x38>

000000008020064a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    8020064a:	7119                	addi	sp,sp,-128
    8020064c:	f4a6                	sd	s1,104(sp)
    8020064e:	f0ca                	sd	s2,96(sp)
    80200650:	e8d2                	sd	s4,80(sp)
    80200652:	e4d6                	sd	s5,72(sp)
    80200654:	e0da                	sd	s6,64(sp)
    80200656:	fc5e                	sd	s7,56(sp)
    80200658:	f862                	sd	s8,48(sp)
    8020065a:	f06a                	sd	s10,32(sp)
    8020065c:	fc86                	sd	ra,120(sp)
    8020065e:	f8a2                	sd	s0,112(sp)
    80200660:	ecce                	sd	s3,88(sp)
    80200662:	f466                	sd	s9,40(sp)
    80200664:	ec6e                	sd	s11,24(sp)
    80200666:	892a                	mv	s2,a0
    80200668:	84ae                	mv	s1,a1
    8020066a:	8d32                	mv	s10,a2
    8020066c:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    8020066e:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
    80200670:	00001a17          	auipc	s4,0x1
    80200674:	9aca0a13          	addi	s4,s4,-1620 # 8020101c <etext+0x5ba>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
    80200678:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    8020067c:	00001c17          	auipc	s8,0x1
    80200680:	afcc0c13          	addi	s8,s8,-1284 # 80201178 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200684:	000d4503          	lbu	a0,0(s10)
    80200688:	02500793          	li	a5,37
    8020068c:	001d0413          	addi	s0,s10,1
    80200690:	00f50e63          	beq	a0,a5,802006ac <vprintfmt+0x62>
            if (ch == '\0') {
    80200694:	c521                	beqz	a0,802006dc <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200696:	02500993          	li	s3,37
    8020069a:	a011                	j	8020069e <vprintfmt+0x54>
            if (ch == '\0') {
    8020069c:	c121                	beqz	a0,802006dc <vprintfmt+0x92>
            putch(ch, putdat);
    8020069e:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006a0:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    802006a2:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006a4:	fff44503          	lbu	a0,-1(s0)
    802006a8:	ff351ae3          	bne	a0,s3,8020069c <vprintfmt+0x52>
    802006ac:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    802006b0:	02000793          	li	a5,32
        lflag = altflag = 0;
    802006b4:	4981                	li	s3,0
    802006b6:	4801                	li	a6,0
        width = precision = -1;
    802006b8:	5cfd                	li	s9,-1
    802006ba:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
    802006bc:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
    802006c0:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
    802006c2:	fdd6069b          	addiw	a3,a2,-35
    802006c6:	0ff6f693          	andi	a3,a3,255
    802006ca:	00140d13          	addi	s10,s0,1
    802006ce:	20d5e563          	bltu	a1,a3,802008d8 <vprintfmt+0x28e>
    802006d2:	068a                	slli	a3,a3,0x2
    802006d4:	96d2                	add	a3,a3,s4
    802006d6:	4294                	lw	a3,0(a3)
    802006d8:	96d2                	add	a3,a3,s4
    802006da:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    802006dc:	70e6                	ld	ra,120(sp)
    802006de:	7446                	ld	s0,112(sp)
    802006e0:	74a6                	ld	s1,104(sp)
    802006e2:	7906                	ld	s2,96(sp)
    802006e4:	69e6                	ld	s3,88(sp)
    802006e6:	6a46                	ld	s4,80(sp)
    802006e8:	6aa6                	ld	s5,72(sp)
    802006ea:	6b06                	ld	s6,64(sp)
    802006ec:	7be2                	ld	s7,56(sp)
    802006ee:	7c42                	ld	s8,48(sp)
    802006f0:	7ca2                	ld	s9,40(sp)
    802006f2:	7d02                	ld	s10,32(sp)
    802006f4:	6de2                	ld	s11,24(sp)
    802006f6:	6109                	addi	sp,sp,128
    802006f8:	8082                	ret
    if (lflag >= 2) {
    802006fa:	4705                	li	a4,1
    802006fc:	008a8593          	addi	a1,s5,8
    80200700:	01074463          	blt	a4,a6,80200708 <vprintfmt+0xbe>
    else if (lflag) {
    80200704:	26080363          	beqz	a6,8020096a <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
    80200708:	000ab603          	ld	a2,0(s5)
    8020070c:	46c1                	li	a3,16
    8020070e:	8aae                	mv	s5,a1
    80200710:	a06d                	j	802007ba <vprintfmt+0x170>
            goto reswitch;
    80200712:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    80200716:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200718:	846a                	mv	s0,s10
            goto reswitch;
    8020071a:	b765                	j	802006c2 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
    8020071c:	000aa503          	lw	a0,0(s5)
    80200720:	85a6                	mv	a1,s1
    80200722:	0aa1                	addi	s5,s5,8
    80200724:	9902                	jalr	s2
            break;
    80200726:	bfb9                	j	80200684 <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200728:	4705                	li	a4,1
    8020072a:	008a8993          	addi	s3,s5,8
    8020072e:	01074463          	blt	a4,a6,80200736 <vprintfmt+0xec>
    else if (lflag) {
    80200732:	22080463          	beqz	a6,8020095a <vprintfmt+0x310>
        return va_arg(*ap, long);
    80200736:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
    8020073a:	24044463          	bltz	s0,80200982 <vprintfmt+0x338>
            num = getint(&ap, lflag);
    8020073e:	8622                	mv	a2,s0
    80200740:	8ace                	mv	s5,s3
    80200742:	46a9                	li	a3,10
    80200744:	a89d                	j	802007ba <vprintfmt+0x170>
            err = va_arg(ap, int);
    80200746:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    8020074a:	4719                	li	a4,6
            err = va_arg(ap, int);
    8020074c:	0aa1                	addi	s5,s5,8
            if (err < 0) {
    8020074e:	41f7d69b          	sraiw	a3,a5,0x1f
    80200752:	8fb5                	xor	a5,a5,a3
    80200754:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200758:	1ad74363          	blt	a4,a3,802008fe <vprintfmt+0x2b4>
    8020075c:	00369793          	slli	a5,a3,0x3
    80200760:	97e2                	add	a5,a5,s8
    80200762:	639c                	ld	a5,0(a5)
    80200764:	18078d63          	beqz	a5,802008fe <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
    80200768:	86be                	mv	a3,a5
    8020076a:	00001617          	auipc	a2,0x1
    8020076e:	af660613          	addi	a2,a2,-1290 # 80201260 <error_string+0xe8>
    80200772:	85a6                	mv	a1,s1
    80200774:	854a                	mv	a0,s2
    80200776:	240000ef          	jal	ra,802009b6 <printfmt>
    8020077a:	b729                	j	80200684 <vprintfmt+0x3a>
            lflag ++;
    8020077c:	00144603          	lbu	a2,1(s0)
    80200780:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200782:	846a                	mv	s0,s10
            goto reswitch;
    80200784:	bf3d                	j	802006c2 <vprintfmt+0x78>
    if (lflag >= 2) {
    80200786:	4705                	li	a4,1
    80200788:	008a8593          	addi	a1,s5,8
    8020078c:	01074463          	blt	a4,a6,80200794 <vprintfmt+0x14a>
    else if (lflag) {
    80200790:	1e080263          	beqz	a6,80200974 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
    80200794:	000ab603          	ld	a2,0(s5)
    80200798:	46a1                	li	a3,8
    8020079a:	8aae                	mv	s5,a1
    8020079c:	a839                	j	802007ba <vprintfmt+0x170>
            putch('0', putdat);
    8020079e:	03000513          	li	a0,48
    802007a2:	85a6                	mv	a1,s1
    802007a4:	e03e                	sd	a5,0(sp)
    802007a6:	9902                	jalr	s2
            putch('x', putdat);
    802007a8:	85a6                	mv	a1,s1
    802007aa:	07800513          	li	a0,120
    802007ae:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    802007b0:	0aa1                	addi	s5,s5,8
    802007b2:	ff8ab603          	ld	a2,-8(s5)
            goto number;
    802007b6:	6782                	ld	a5,0(sp)
    802007b8:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
    802007ba:	876e                	mv	a4,s11
    802007bc:	85a6                	mv	a1,s1
    802007be:	854a                	mv	a0,s2
    802007c0:	e1fff0ef          	jal	ra,802005de <printnum>
            break;
    802007c4:	b5c1                	j	80200684 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
    802007c6:	000ab603          	ld	a2,0(s5)
    802007ca:	0aa1                	addi	s5,s5,8
    802007cc:	1c060663          	beqz	a2,80200998 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
    802007d0:	00160413          	addi	s0,a2,1
    802007d4:	17b05c63          	blez	s11,8020094c <vprintfmt+0x302>
    802007d8:	02d00593          	li	a1,45
    802007dc:	14b79263          	bne	a5,a1,80200920 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802007e0:	00064783          	lbu	a5,0(a2)
    802007e4:	0007851b          	sext.w	a0,a5
    802007e8:	c905                	beqz	a0,80200818 <vprintfmt+0x1ce>
    802007ea:	000cc563          	bltz	s9,802007f4 <vprintfmt+0x1aa>
    802007ee:	3cfd                	addiw	s9,s9,-1
    802007f0:	036c8263          	beq	s9,s6,80200814 <vprintfmt+0x1ca>
                    putch('?', putdat);
    802007f4:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    802007f6:	18098463          	beqz	s3,8020097e <vprintfmt+0x334>
    802007fa:	3781                	addiw	a5,a5,-32
    802007fc:	18fbf163          	bleu	a5,s7,8020097e <vprintfmt+0x334>
                    putch('?', putdat);
    80200800:	03f00513          	li	a0,63
    80200804:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200806:	0405                	addi	s0,s0,1
    80200808:	fff44783          	lbu	a5,-1(s0)
    8020080c:	3dfd                	addiw	s11,s11,-1
    8020080e:	0007851b          	sext.w	a0,a5
    80200812:	fd61                	bnez	a0,802007ea <vprintfmt+0x1a0>
            for (; width > 0; width --) {
    80200814:	e7b058e3          	blez	s11,80200684 <vprintfmt+0x3a>
    80200818:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    8020081a:	85a6                	mv	a1,s1
    8020081c:	02000513          	li	a0,32
    80200820:	9902                	jalr	s2
            for (; width > 0; width --) {
    80200822:	e60d81e3          	beqz	s11,80200684 <vprintfmt+0x3a>
    80200826:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    80200828:	85a6                	mv	a1,s1
    8020082a:	02000513          	li	a0,32
    8020082e:	9902                	jalr	s2
            for (; width > 0; width --) {
    80200830:	fe0d94e3          	bnez	s11,80200818 <vprintfmt+0x1ce>
    80200834:	bd81                	j	80200684 <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200836:	4705                	li	a4,1
    80200838:	008a8593          	addi	a1,s5,8
    8020083c:	01074463          	blt	a4,a6,80200844 <vprintfmt+0x1fa>
    else if (lflag) {
    80200840:	12080063          	beqz	a6,80200960 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
    80200844:	000ab603          	ld	a2,0(s5)
    80200848:	46a9                	li	a3,10
    8020084a:	8aae                	mv	s5,a1
    8020084c:	b7bd                	j	802007ba <vprintfmt+0x170>
    8020084e:	00144603          	lbu	a2,1(s0)
            padc = '-';
    80200852:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
    80200856:	846a                	mv	s0,s10
    80200858:	b5ad                	j	802006c2 <vprintfmt+0x78>
            putch(ch, putdat);
    8020085a:	85a6                	mv	a1,s1
    8020085c:	02500513          	li	a0,37
    80200860:	9902                	jalr	s2
            break;
    80200862:	b50d                	j	80200684 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
    80200864:	000aac83          	lw	s9,0(s5)
            goto process_precision;
    80200868:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    8020086c:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
    8020086e:	846a                	mv	s0,s10
            if (width < 0)
    80200870:	e40dd9e3          	bgez	s11,802006c2 <vprintfmt+0x78>
                width = precision, precision = -1;
    80200874:	8de6                	mv	s11,s9
    80200876:	5cfd                	li	s9,-1
    80200878:	b5a9                	j	802006c2 <vprintfmt+0x78>
            goto reswitch;
    8020087a:	00144603          	lbu	a2,1(s0)
            padc = '0';
    8020087e:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
    80200882:	846a                	mv	s0,s10
            goto reswitch;
    80200884:	bd3d                	j	802006c2 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
    80200886:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
    8020088a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    8020088e:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    80200890:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    80200894:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    80200898:	fcd56ce3          	bltu	a0,a3,80200870 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
    8020089c:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    8020089e:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
    802008a2:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
    802008a6:	0196873b          	addw	a4,a3,s9
    802008aa:	0017171b          	slliw	a4,a4,0x1
    802008ae:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
    802008b2:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
    802008b6:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
    802008ba:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    802008be:	fcd57fe3          	bleu	a3,a0,8020089c <vprintfmt+0x252>
    802008c2:	b77d                	j	80200870 <vprintfmt+0x226>
            if (width < 0)
    802008c4:	fffdc693          	not	a3,s11
    802008c8:	96fd                	srai	a3,a3,0x3f
    802008ca:	00ddfdb3          	and	s11,s11,a3
    802008ce:	00144603          	lbu	a2,1(s0)
    802008d2:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
    802008d4:	846a                	mv	s0,s10
    802008d6:	b3f5                	j	802006c2 <vprintfmt+0x78>
            putch('%', putdat);
    802008d8:	85a6                	mv	a1,s1
    802008da:	02500513          	li	a0,37
    802008de:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    802008e0:	fff44703          	lbu	a4,-1(s0)
    802008e4:	02500793          	li	a5,37
    802008e8:	8d22                	mv	s10,s0
    802008ea:	d8f70de3          	beq	a4,a5,80200684 <vprintfmt+0x3a>
    802008ee:	02500713          	li	a4,37
    802008f2:	1d7d                	addi	s10,s10,-1
    802008f4:	fffd4783          	lbu	a5,-1(s10)
    802008f8:	fee79de3          	bne	a5,a4,802008f2 <vprintfmt+0x2a8>
    802008fc:	b361                	j	80200684 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    802008fe:	00001617          	auipc	a2,0x1
    80200902:	95260613          	addi	a2,a2,-1710 # 80201250 <error_string+0xd8>
    80200906:	85a6                	mv	a1,s1
    80200908:	854a                	mv	a0,s2
    8020090a:	0ac000ef          	jal	ra,802009b6 <printfmt>
    8020090e:	bb9d                	j	80200684 <vprintfmt+0x3a>
                p = "(null)";
    80200910:	00001617          	auipc	a2,0x1
    80200914:	93860613          	addi	a2,a2,-1736 # 80201248 <error_string+0xd0>
            if (width > 0 && padc != '-') {
    80200918:	00001417          	auipc	s0,0x1
    8020091c:	93140413          	addi	s0,s0,-1743 # 80201249 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200920:	8532                	mv	a0,a2
    80200922:	85e6                	mv	a1,s9
    80200924:	e032                	sd	a2,0(sp)
    80200926:	e43e                	sd	a5,8(sp)
    80200928:	102000ef          	jal	ra,80200a2a <strnlen>
    8020092c:	40ad8dbb          	subw	s11,s11,a0
    80200930:	6602                	ld	a2,0(sp)
    80200932:	01b05d63          	blez	s11,8020094c <vprintfmt+0x302>
    80200936:	67a2                	ld	a5,8(sp)
    80200938:	2781                	sext.w	a5,a5
    8020093a:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
    8020093c:	6522                	ld	a0,8(sp)
    8020093e:	85a6                	mv	a1,s1
    80200940:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200942:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    80200944:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200946:	6602                	ld	a2,0(sp)
    80200948:	fe0d9ae3          	bnez	s11,8020093c <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020094c:	00064783          	lbu	a5,0(a2)
    80200950:	0007851b          	sext.w	a0,a5
    80200954:	e8051be3          	bnez	a0,802007ea <vprintfmt+0x1a0>
    80200958:	b335                	j	80200684 <vprintfmt+0x3a>
        return va_arg(*ap, int);
    8020095a:	000aa403          	lw	s0,0(s5)
    8020095e:	bbf1                	j	8020073a <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
    80200960:	000ae603          	lwu	a2,0(s5)
    80200964:	46a9                	li	a3,10
    80200966:	8aae                	mv	s5,a1
    80200968:	bd89                	j	802007ba <vprintfmt+0x170>
    8020096a:	000ae603          	lwu	a2,0(s5)
    8020096e:	46c1                	li	a3,16
    80200970:	8aae                	mv	s5,a1
    80200972:	b5a1                	j	802007ba <vprintfmt+0x170>
    80200974:	000ae603          	lwu	a2,0(s5)
    80200978:	46a1                	li	a3,8
    8020097a:	8aae                	mv	s5,a1
    8020097c:	bd3d                	j	802007ba <vprintfmt+0x170>
                    putch(ch, putdat);
    8020097e:	9902                	jalr	s2
    80200980:	b559                	j	80200806 <vprintfmt+0x1bc>
                putch('-', putdat);
    80200982:	85a6                	mv	a1,s1
    80200984:	02d00513          	li	a0,45
    80200988:	e03e                	sd	a5,0(sp)
    8020098a:	9902                	jalr	s2
                num = -(long long)num;
    8020098c:	8ace                	mv	s5,s3
    8020098e:	40800633          	neg	a2,s0
    80200992:	46a9                	li	a3,10
    80200994:	6782                	ld	a5,0(sp)
    80200996:	b515                	j	802007ba <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
    80200998:	01b05663          	blez	s11,802009a4 <vprintfmt+0x35a>
    8020099c:	02d00693          	li	a3,45
    802009a0:	f6d798e3          	bne	a5,a3,80200910 <vprintfmt+0x2c6>
    802009a4:	00001417          	auipc	s0,0x1
    802009a8:	8a540413          	addi	s0,s0,-1883 # 80201249 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802009ac:	02800513          	li	a0,40
    802009b0:	02800793          	li	a5,40
    802009b4:	bd1d                	j	802007ea <vprintfmt+0x1a0>

00000000802009b6 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009b6:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    802009b8:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009bc:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802009be:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009c0:	ec06                	sd	ra,24(sp)
    802009c2:	f83a                	sd	a4,48(sp)
    802009c4:	fc3e                	sd	a5,56(sp)
    802009c6:	e0c2                	sd	a6,64(sp)
    802009c8:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    802009ca:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802009cc:	c7fff0ef          	jal	ra,8020064a <vprintfmt>
}
    802009d0:	60e2                	ld	ra,24(sp)
    802009d2:	6161                	addi	sp,sp,80
    802009d4:	8082                	ret

00000000802009d6 <sbi_console_putchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
    802009d6:	00003797          	auipc	a5,0x3
    802009da:	62a78793          	addi	a5,a5,1578 # 80204000 <bootstacktop>
    __asm__ volatile (
    802009de:	6398                	ld	a4,0(a5)
    802009e0:	4781                	li	a5,0
    802009e2:	88ba                	mv	a7,a4
    802009e4:	852a                	mv	a0,a0
    802009e6:	85be                	mv	a1,a5
    802009e8:	863e                	mv	a2,a5
    802009ea:	00000073          	ecall
    802009ee:	87aa                	mv	a5,a0
}
    802009f0:	8082                	ret

00000000802009f2 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
    802009f2:	00003797          	auipc	a5,0x3
    802009f6:	62e78793          	addi	a5,a5,1582 # 80204020 <SBI_SET_TIMER>
    __asm__ volatile (
    802009fa:	6398                	ld	a4,0(a5)
    802009fc:	4781                	li	a5,0
    802009fe:	88ba                	mv	a7,a4
    80200a00:	852a                	mv	a0,a0
    80200a02:	85be                	mv	a1,a5
    80200a04:	863e                	mv	a2,a5
    80200a06:	00000073          	ecall
    80200a0a:	87aa                	mv	a5,a0
}
    80200a0c:	8082                	ret

0000000080200a0e <sbi_shutdown>:


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
    80200a0e:	00003797          	auipc	a5,0x3
    80200a12:	5fa78793          	addi	a5,a5,1530 # 80204008 <SBI_SHUTDOWN>
    __asm__ volatile (
    80200a16:	6398                	ld	a4,0(a5)
    80200a18:	4781                	li	a5,0
    80200a1a:	88ba                	mv	a7,a4
    80200a1c:	853e                	mv	a0,a5
    80200a1e:	85be                	mv	a1,a5
    80200a20:	863e                	mv	a2,a5
    80200a22:	00000073          	ecall
    80200a26:	87aa                	mv	a5,a0
    80200a28:	8082                	ret

0000000080200a2a <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
    80200a2a:	c185                	beqz	a1,80200a4a <strnlen+0x20>
    80200a2c:	00054783          	lbu	a5,0(a0)
    80200a30:	cf89                	beqz	a5,80200a4a <strnlen+0x20>
    size_t cnt = 0;
    80200a32:	4781                	li	a5,0
    80200a34:	a021                	j	80200a3c <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
    80200a36:	00074703          	lbu	a4,0(a4)
    80200a3a:	c711                	beqz	a4,80200a46 <strnlen+0x1c>
        cnt ++;
    80200a3c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    80200a3e:	00f50733          	add	a4,a0,a5
    80200a42:	fef59ae3          	bne	a1,a5,80200a36 <strnlen+0xc>
    }
    return cnt;
}
    80200a46:	853e                	mv	a0,a5
    80200a48:	8082                	ret
    size_t cnt = 0;
    80200a4a:	4781                	li	a5,0
}
    80200a4c:	853e                	mv	a0,a5
    80200a4e:	8082                	ret

0000000080200a50 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    80200a50:	ca01                	beqz	a2,80200a60 <memset+0x10>
    80200a52:	962a                	add	a2,a2,a0
    char *p = s;
    80200a54:	87aa                	mv	a5,a0
        *p ++ = c;
    80200a56:	0785                	addi	a5,a5,1
    80200a58:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    80200a5c:	fec79de3          	bne	a5,a2,80200a56 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    80200a60:	8082                	ret
