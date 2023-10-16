
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	01e31313          	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000c:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200010:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200014:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200018:	03f31313          	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc020001c:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200020:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200024:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200028:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	00006517          	auipc	a0,0x6
ffffffffc020003a:	fda50513          	addi	a0,a0,-38 # ffffffffc0206010 <edata>
ffffffffc020003e:	00006617          	auipc	a2,0x6
ffffffffc0200042:	43260613          	addi	a2,a2,1074 # ffffffffc0206470 <end>
int kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	27b010ef          	jal	ra,ffffffffc0201ac8 <memset>
    cons_init();  // init the console
ffffffffc0200052:	3fe000ef          	jal	ra,ffffffffc0200450 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00002517          	auipc	a0,0x2
ffffffffc020005a:	a8a50513          	addi	a0,a0,-1398 # ffffffffc0201ae0 <etext+0x6>
ffffffffc020005e:	090000ef          	jal	ra,ffffffffc02000ee <cputs>

    print_kerninfo();
ffffffffc0200062:	0dc000ef          	jal	ra,ffffffffc020013e <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	404000ef          	jal	ra,ffffffffc020046a <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	336010ef          	jal	ra,ffffffffc02013a0 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006e:	3fc000ef          	jal	ra,ffffffffc020046a <idt_init>

    clock_init();   // init clock interrupt
ffffffffc0200072:	39a000ef          	jal	ra,ffffffffc020040c <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200076:	3e8000ef          	jal	ra,ffffffffc020045e <intr_enable>



    /* do nothing */
    while (1)
        ;
ffffffffc020007a:	a001                	j	ffffffffc020007a <kern_init+0x44>

ffffffffc020007c <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc020007c:	1141                	addi	sp,sp,-16
ffffffffc020007e:	e022                	sd	s0,0(sp)
ffffffffc0200080:	e406                	sd	ra,8(sp)
ffffffffc0200082:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200084:	3ce000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200088:	401c                	lw	a5,0(s0)
}
ffffffffc020008a:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc020008c:	2785                	addiw	a5,a5,1
ffffffffc020008e:	c01c                	sw	a5,0(s0)
}
ffffffffc0200090:	6402                	ld	s0,0(sp)
ffffffffc0200092:	0141                	addi	sp,sp,16
ffffffffc0200094:	8082                	ret

ffffffffc0200096 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200096:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	86ae                	mv	a3,a1
ffffffffc020009a:	862a                	mv	a2,a0
ffffffffc020009c:	006c                	addi	a1,sp,12
ffffffffc020009e:	00000517          	auipc	a0,0x0
ffffffffc02000a2:	fde50513          	addi	a0,a0,-34 # ffffffffc020007c <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a6:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a8:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000aa:	510010ef          	jal	ra,ffffffffc02015ba <vprintfmt>
    return cnt;
}
ffffffffc02000ae:	60e2                	ld	ra,24(sp)
ffffffffc02000b0:	4532                	lw	a0,12(sp)
ffffffffc02000b2:	6105                	addi	sp,sp,32
ffffffffc02000b4:	8082                	ret

ffffffffc02000b6 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b6:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b8:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000bc:	f42e                	sd	a1,40(sp)
ffffffffc02000be:	f832                	sd	a2,48(sp)
ffffffffc02000c0:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c2:	862a                	mv	a2,a0
ffffffffc02000c4:	004c                	addi	a1,sp,4
ffffffffc02000c6:	00000517          	auipc	a0,0x0
ffffffffc02000ca:	fb650513          	addi	a0,a0,-74 # ffffffffc020007c <cputch>
ffffffffc02000ce:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d0:	ec06                	sd	ra,24(sp)
ffffffffc02000d2:	e0ba                	sd	a4,64(sp)
ffffffffc02000d4:	e4be                	sd	a5,72(sp)
ffffffffc02000d6:	e8c2                	sd	a6,80(sp)
ffffffffc02000d8:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000da:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000dc:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000de:	4dc010ef          	jal	ra,ffffffffc02015ba <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e2:	60e2                	ld	ra,24(sp)
ffffffffc02000e4:	4512                	lw	a0,4(sp)
ffffffffc02000e6:	6125                	addi	sp,sp,96
ffffffffc02000e8:	8082                	ret

ffffffffc02000ea <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000ea:	3680006f          	j	ffffffffc0200452 <cons_putc>

ffffffffc02000ee <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ee:	1101                	addi	sp,sp,-32
ffffffffc02000f0:	e822                	sd	s0,16(sp)
ffffffffc02000f2:	ec06                	sd	ra,24(sp)
ffffffffc02000f4:	e426                	sd	s1,8(sp)
ffffffffc02000f6:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f8:	00054503          	lbu	a0,0(a0)
ffffffffc02000fc:	c51d                	beqz	a0,ffffffffc020012a <cputs+0x3c>
ffffffffc02000fe:	0405                	addi	s0,s0,1
ffffffffc0200100:	4485                	li	s1,1
ffffffffc0200102:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200104:	34e000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200112:	f96d                	bnez	a0,ffffffffc0200104 <cputs+0x16>
ffffffffc0200114:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200118:	4529                	li	a0,10
ffffffffc020011a:	338000ef          	jal	ra,ffffffffc0200452 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011e:	8522                	mv	a0,s0
ffffffffc0200120:	60e2                	ld	ra,24(sp)
ffffffffc0200122:	6442                	ld	s0,16(sp)
ffffffffc0200124:	64a2                	ld	s1,8(sp)
ffffffffc0200126:	6105                	addi	sp,sp,32
ffffffffc0200128:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc020012a:	4405                	li	s0,1
ffffffffc020012c:	b7f5                	j	ffffffffc0200118 <cputs+0x2a>

ffffffffc020012e <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012e:	1141                	addi	sp,sp,-16
ffffffffc0200130:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200132:	328000ef          	jal	ra,ffffffffc020045a <cons_getc>
ffffffffc0200136:	dd75                	beqz	a0,ffffffffc0200132 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200138:	60a2                	ld	ra,8(sp)
ffffffffc020013a:	0141                	addi	sp,sp,16
ffffffffc020013c:	8082                	ret

ffffffffc020013e <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013e:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200140:	00002517          	auipc	a0,0x2
ffffffffc0200144:	9f050513          	addi	a0,a0,-1552 # ffffffffc0201b30 <etext+0x56>
void print_kerninfo(void) {
ffffffffc0200148:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020014a:	f6dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014e:	00000597          	auipc	a1,0x0
ffffffffc0200152:	ee858593          	addi	a1,a1,-280 # ffffffffc0200036 <kern_init>
ffffffffc0200156:	00002517          	auipc	a0,0x2
ffffffffc020015a:	9fa50513          	addi	a0,a0,-1542 # ffffffffc0201b50 <etext+0x76>
ffffffffc020015e:	f59ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200162:	00002597          	auipc	a1,0x2
ffffffffc0200166:	97858593          	addi	a1,a1,-1672 # ffffffffc0201ada <etext>
ffffffffc020016a:	00002517          	auipc	a0,0x2
ffffffffc020016e:	a0650513          	addi	a0,a0,-1530 # ffffffffc0201b70 <etext+0x96>
ffffffffc0200172:	f45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200176:	00006597          	auipc	a1,0x6
ffffffffc020017a:	e9a58593          	addi	a1,a1,-358 # ffffffffc0206010 <edata>
ffffffffc020017e:	00002517          	auipc	a0,0x2
ffffffffc0200182:	a1250513          	addi	a0,a0,-1518 # ffffffffc0201b90 <etext+0xb6>
ffffffffc0200186:	f31ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc020018a:	00006597          	auipc	a1,0x6
ffffffffc020018e:	2e658593          	addi	a1,a1,742 # ffffffffc0206470 <end>
ffffffffc0200192:	00002517          	auipc	a0,0x2
ffffffffc0200196:	a1e50513          	addi	a0,a0,-1506 # ffffffffc0201bb0 <etext+0xd6>
ffffffffc020019a:	f1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019e:	00006597          	auipc	a1,0x6
ffffffffc02001a2:	6d158593          	addi	a1,a1,1745 # ffffffffc020686f <end+0x3ff>
ffffffffc02001a6:	00000797          	auipc	a5,0x0
ffffffffc02001aa:	e9078793          	addi	a5,a5,-368 # ffffffffc0200036 <kern_init>
ffffffffc02001ae:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b2:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b6:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b8:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001bc:	95be                	add	a1,a1,a5
ffffffffc02001be:	85a9                	srai	a1,a1,0xa
ffffffffc02001c0:	00002517          	auipc	a0,0x2
ffffffffc02001c4:	a1050513          	addi	a0,a0,-1520 # ffffffffc0201bd0 <etext+0xf6>
}
ffffffffc02001c8:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ca:	eedff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02001ce <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001ce:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001d0:	00002617          	auipc	a2,0x2
ffffffffc02001d4:	93060613          	addi	a2,a2,-1744 # ffffffffc0201b00 <etext+0x26>
ffffffffc02001d8:	04e00593          	li	a1,78
ffffffffc02001dc:	00002517          	auipc	a0,0x2
ffffffffc02001e0:	93c50513          	addi	a0,a0,-1732 # ffffffffc0201b18 <etext+0x3e>
void print_stackframe(void) {
ffffffffc02001e4:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e6:	1c6000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001ea <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001ea:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001ec:	00002617          	auipc	a2,0x2
ffffffffc02001f0:	af460613          	addi	a2,a2,-1292 # ffffffffc0201ce0 <commands+0xe0>
ffffffffc02001f4:	00002597          	auipc	a1,0x2
ffffffffc02001f8:	b0c58593          	addi	a1,a1,-1268 # ffffffffc0201d00 <commands+0x100>
ffffffffc02001fc:	00002517          	auipc	a0,0x2
ffffffffc0200200:	b0c50513          	addi	a0,a0,-1268 # ffffffffc0201d08 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200204:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200206:	eb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020020a:	00002617          	auipc	a2,0x2
ffffffffc020020e:	b0e60613          	addi	a2,a2,-1266 # ffffffffc0201d18 <commands+0x118>
ffffffffc0200212:	00002597          	auipc	a1,0x2
ffffffffc0200216:	b2e58593          	addi	a1,a1,-1234 # ffffffffc0201d40 <commands+0x140>
ffffffffc020021a:	00002517          	auipc	a0,0x2
ffffffffc020021e:	aee50513          	addi	a0,a0,-1298 # ffffffffc0201d08 <commands+0x108>
ffffffffc0200222:	e95ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200226:	00002617          	auipc	a2,0x2
ffffffffc020022a:	b2a60613          	addi	a2,a2,-1238 # ffffffffc0201d50 <commands+0x150>
ffffffffc020022e:	00002597          	auipc	a1,0x2
ffffffffc0200232:	b4258593          	addi	a1,a1,-1214 # ffffffffc0201d70 <commands+0x170>
ffffffffc0200236:	00002517          	auipc	a0,0x2
ffffffffc020023a:	ad250513          	addi	a0,a0,-1326 # ffffffffc0201d08 <commands+0x108>
ffffffffc020023e:	e79ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    }
    return 0;
}
ffffffffc0200242:	60a2                	ld	ra,8(sp)
ffffffffc0200244:	4501                	li	a0,0
ffffffffc0200246:	0141                	addi	sp,sp,16
ffffffffc0200248:	8082                	ret

ffffffffc020024a <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020024a:	1141                	addi	sp,sp,-16
ffffffffc020024c:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020024e:	ef1ff0ef          	jal	ra,ffffffffc020013e <print_kerninfo>
    return 0;
}
ffffffffc0200252:	60a2                	ld	ra,8(sp)
ffffffffc0200254:	4501                	li	a0,0
ffffffffc0200256:	0141                	addi	sp,sp,16
ffffffffc0200258:	8082                	ret

ffffffffc020025a <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020025a:	1141                	addi	sp,sp,-16
ffffffffc020025c:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020025e:	f71ff0ef          	jal	ra,ffffffffc02001ce <print_stackframe>
    return 0;
}
ffffffffc0200262:	60a2                	ld	ra,8(sp)
ffffffffc0200264:	4501                	li	a0,0
ffffffffc0200266:	0141                	addi	sp,sp,16
ffffffffc0200268:	8082                	ret

ffffffffc020026a <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020026a:	7115                	addi	sp,sp,-224
ffffffffc020026c:	e962                	sd	s8,144(sp)
ffffffffc020026e:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200270:	00002517          	auipc	a0,0x2
ffffffffc0200274:	9d850513          	addi	a0,a0,-1576 # ffffffffc0201c48 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200278:	ed86                	sd	ra,216(sp)
ffffffffc020027a:	e9a2                	sd	s0,208(sp)
ffffffffc020027c:	e5a6                	sd	s1,200(sp)
ffffffffc020027e:	e1ca                	sd	s2,192(sp)
ffffffffc0200280:	fd4e                	sd	s3,184(sp)
ffffffffc0200282:	f952                	sd	s4,176(sp)
ffffffffc0200284:	f556                	sd	s5,168(sp)
ffffffffc0200286:	f15a                	sd	s6,160(sp)
ffffffffc0200288:	ed5e                	sd	s7,152(sp)
ffffffffc020028a:	e566                	sd	s9,136(sp)
ffffffffc020028c:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020028e:	e29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200292:	00002517          	auipc	a0,0x2
ffffffffc0200296:	9de50513          	addi	a0,a0,-1570 # ffffffffc0201c70 <commands+0x70>
ffffffffc020029a:	e1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc020029e:	000c0563          	beqz	s8,ffffffffc02002a8 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002a2:	8562                	mv	a0,s8
ffffffffc02002a4:	3a6000ef          	jal	ra,ffffffffc020064a <print_trapframe>
ffffffffc02002a8:	00002c97          	auipc	s9,0x2
ffffffffc02002ac:	958c8c93          	addi	s9,s9,-1704 # ffffffffc0201c00 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002b0:	00002997          	auipc	s3,0x2
ffffffffc02002b4:	9e898993          	addi	s3,s3,-1560 # ffffffffc0201c98 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b8:	00002917          	auipc	s2,0x2
ffffffffc02002bc:	9e890913          	addi	s2,s2,-1560 # ffffffffc0201ca0 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02002c0:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002c2:	00002b17          	auipc	s6,0x2
ffffffffc02002c6:	9e6b0b13          	addi	s6,s6,-1562 # ffffffffc0201ca8 <commands+0xa8>
    if (argc == 0) {
ffffffffc02002ca:	00002a97          	auipc	s5,0x2
ffffffffc02002ce:	a36a8a93          	addi	s5,s5,-1482 # ffffffffc0201d00 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d2:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002d4:	854e                	mv	a0,s3
ffffffffc02002d6:	670010ef          	jal	ra,ffffffffc0201946 <readline>
ffffffffc02002da:	842a                	mv	s0,a0
ffffffffc02002dc:	dd65                	beqz	a0,ffffffffc02002d4 <kmonitor+0x6a>
ffffffffc02002de:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002e2:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e4:	c999                	beqz	a1,ffffffffc02002fa <kmonitor+0x90>
ffffffffc02002e6:	854a                	mv	a0,s2
ffffffffc02002e8:	7c2010ef          	jal	ra,ffffffffc0201aaa <strchr>
ffffffffc02002ec:	c925                	beqz	a0,ffffffffc020035c <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02002ee:	00144583          	lbu	a1,1(s0)
ffffffffc02002f2:	00040023          	sb	zero,0(s0)
ffffffffc02002f6:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002f8:	f5fd                	bnez	a1,ffffffffc02002e6 <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc02002fa:	dce9                	beqz	s1,ffffffffc02002d4 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002fc:	6582                	ld	a1,0(sp)
ffffffffc02002fe:	00002d17          	auipc	s10,0x2
ffffffffc0200302:	902d0d13          	addi	s10,s10,-1790 # ffffffffc0201c00 <commands>
    if (argc == 0) {
ffffffffc0200306:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200308:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020030a:	0d61                	addi	s10,s10,24
ffffffffc020030c:	774010ef          	jal	ra,ffffffffc0201a80 <strcmp>
ffffffffc0200310:	c919                	beqz	a0,ffffffffc0200326 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200312:	2405                	addiw	s0,s0,1
ffffffffc0200314:	09740463          	beq	s0,s7,ffffffffc020039c <kmonitor+0x132>
ffffffffc0200318:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020031c:	6582                	ld	a1,0(sp)
ffffffffc020031e:	0d61                	addi	s10,s10,24
ffffffffc0200320:	760010ef          	jal	ra,ffffffffc0201a80 <strcmp>
ffffffffc0200324:	f57d                	bnez	a0,ffffffffc0200312 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200326:	00141793          	slli	a5,s0,0x1
ffffffffc020032a:	97a2                	add	a5,a5,s0
ffffffffc020032c:	078e                	slli	a5,a5,0x3
ffffffffc020032e:	97e6                	add	a5,a5,s9
ffffffffc0200330:	6b9c                	ld	a5,16(a5)
ffffffffc0200332:	8662                	mv	a2,s8
ffffffffc0200334:	002c                	addi	a1,sp,8
ffffffffc0200336:	fff4851b          	addiw	a0,s1,-1
ffffffffc020033a:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020033c:	f8055ce3          	bgez	a0,ffffffffc02002d4 <kmonitor+0x6a>
}
ffffffffc0200340:	60ee                	ld	ra,216(sp)
ffffffffc0200342:	644e                	ld	s0,208(sp)
ffffffffc0200344:	64ae                	ld	s1,200(sp)
ffffffffc0200346:	690e                	ld	s2,192(sp)
ffffffffc0200348:	79ea                	ld	s3,184(sp)
ffffffffc020034a:	7a4a                	ld	s4,176(sp)
ffffffffc020034c:	7aaa                	ld	s5,168(sp)
ffffffffc020034e:	7b0a                	ld	s6,160(sp)
ffffffffc0200350:	6bea                	ld	s7,152(sp)
ffffffffc0200352:	6c4a                	ld	s8,144(sp)
ffffffffc0200354:	6caa                	ld	s9,136(sp)
ffffffffc0200356:	6d0a                	ld	s10,128(sp)
ffffffffc0200358:	612d                	addi	sp,sp,224
ffffffffc020035a:	8082                	ret
        if (*buf == '\0') {
ffffffffc020035c:	00044783          	lbu	a5,0(s0)
ffffffffc0200360:	dfc9                	beqz	a5,ffffffffc02002fa <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc0200362:	03448863          	beq	s1,s4,ffffffffc0200392 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc0200366:	00349793          	slli	a5,s1,0x3
ffffffffc020036a:	0118                	addi	a4,sp,128
ffffffffc020036c:	97ba                	add	a5,a5,a4
ffffffffc020036e:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200372:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200376:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200378:	e591                	bnez	a1,ffffffffc0200384 <kmonitor+0x11a>
ffffffffc020037a:	b749                	j	ffffffffc02002fc <kmonitor+0x92>
            buf ++;
ffffffffc020037c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020037e:	00044583          	lbu	a1,0(s0)
ffffffffc0200382:	ddad                	beqz	a1,ffffffffc02002fc <kmonitor+0x92>
ffffffffc0200384:	854a                	mv	a0,s2
ffffffffc0200386:	724010ef          	jal	ra,ffffffffc0201aaa <strchr>
ffffffffc020038a:	d96d                	beqz	a0,ffffffffc020037c <kmonitor+0x112>
ffffffffc020038c:	00044583          	lbu	a1,0(s0)
ffffffffc0200390:	bf91                	j	ffffffffc02002e4 <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d21ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020039a:	b7f1                	j	ffffffffc0200366 <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00002517          	auipc	a0,0x2
ffffffffc02003a2:	92a50513          	addi	a0,a0,-1750 # ffffffffc0201cc8 <commands+0xc8>
ffffffffc02003a6:	d11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    return 0;
ffffffffc02003aa:	b72d                	j	ffffffffc02002d4 <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ac:	00006317          	auipc	t1,0x6
ffffffffc02003b0:	06430313          	addi	t1,t1,100 # ffffffffc0206410 <is_panic>
ffffffffc02003b4:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	02031c63          	bnez	t1,ffffffffc0200400 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	8432                	mv	s0,a2
ffffffffc02003d0:	00006717          	auipc	a4,0x6
ffffffffc02003d4:	04f72023          	sw	a5,64(a4) # ffffffffc0206410 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d8:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02003da:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003dc:	85aa                	mv	a1,a0
ffffffffc02003de:	00002517          	auipc	a0,0x2
ffffffffc02003e2:	9a250513          	addi	a0,a0,-1630 # ffffffffc0201d80 <commands+0x180>
    va_start(ap, fmt);
ffffffffc02003e6:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e8:	ccfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003ec:	65a2                	ld	a1,8(sp)
ffffffffc02003ee:	8522                	mv	a0,s0
ffffffffc02003f0:	ca7ff0ef          	jal	ra,ffffffffc0200096 <vcprintf>
    cprintf("\n");
ffffffffc02003f4:	00002517          	auipc	a0,0x2
ffffffffc02003f8:	80450513          	addi	a0,a0,-2044 # ffffffffc0201bf8 <etext+0x11e>
ffffffffc02003fc:	cbbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200400:	064000ef          	jal	ra,ffffffffc0200464 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200404:	4501                	li	a0,0
ffffffffc0200406:	e65ff0ef          	jal	ra,ffffffffc020026a <kmonitor>
ffffffffc020040a:	bfed                	j	ffffffffc0200404 <__panic+0x58>

ffffffffc020040c <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc020040c:	1141                	addi	sp,sp,-16
ffffffffc020040e:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc0200410:	02000793          	li	a5,32
ffffffffc0200414:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200418:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020041c:	67e1                	lui	a5,0x18
ffffffffc020041e:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc0200422:	953e                	add	a0,a0,a5
ffffffffc0200424:	5fc010ef          	jal	ra,ffffffffc0201a20 <sbi_set_timer>
}
ffffffffc0200428:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042a:	00006797          	auipc	a5,0x6
ffffffffc020042e:	0007b323          	sd	zero,6(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200432:	00002517          	auipc	a0,0x2
ffffffffc0200436:	96e50513          	addi	a0,a0,-1682 # ffffffffc0201da0 <commands+0x1a0>
}
ffffffffc020043a:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc020043c:	c7bff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc0200440 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200440:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200444:	67e1                	lui	a5,0x18
ffffffffc0200446:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc020044a:	953e                	add	a0,a0,a5
ffffffffc020044c:	5d40106f          	j	ffffffffc0201a20 <sbi_set_timer>

ffffffffc0200450 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200450:	8082                	ret

ffffffffc0200452 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200452:	0ff57513          	andi	a0,a0,255
ffffffffc0200456:	5ae0106f          	j	ffffffffc0201a04 <sbi_console_putchar>

ffffffffc020045a <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020045a:	5e20106f          	j	ffffffffc0201a3c <sbi_console_getchar>

ffffffffc020045e <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200464:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200468:	8082                	ret

ffffffffc020046a <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020046a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020046e:	00000797          	auipc	a5,0x0
ffffffffc0200472:	30e78793          	addi	a5,a5,782 # ffffffffc020077c <__alltraps>
ffffffffc0200476:	10579073          	csrw	stvec,a5
}
ffffffffc020047a:	8082                	ret

ffffffffc020047c <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020047e:	1141                	addi	sp,sp,-16
ffffffffc0200480:	e022                	sd	s0,0(sp)
ffffffffc0200482:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200484:	00002517          	auipc	a0,0x2
ffffffffc0200488:	a3450513          	addi	a0,a0,-1484 # ffffffffc0201eb8 <commands+0x2b8>
void print_regs(struct pushregs *gpr) {
ffffffffc020048c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048e:	c29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200492:	640c                	ld	a1,8(s0)
ffffffffc0200494:	00002517          	auipc	a0,0x2
ffffffffc0200498:	a3c50513          	addi	a0,a0,-1476 # ffffffffc0201ed0 <commands+0x2d0>
ffffffffc020049c:	c1bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a0:	680c                	ld	a1,16(s0)
ffffffffc02004a2:	00002517          	auipc	a0,0x2
ffffffffc02004a6:	a4650513          	addi	a0,a0,-1466 # ffffffffc0201ee8 <commands+0x2e8>
ffffffffc02004aa:	c0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004ae:	6c0c                	ld	a1,24(s0)
ffffffffc02004b0:	00002517          	auipc	a0,0x2
ffffffffc02004b4:	a5050513          	addi	a0,a0,-1456 # ffffffffc0201f00 <commands+0x300>
ffffffffc02004b8:	bffff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004bc:	700c                	ld	a1,32(s0)
ffffffffc02004be:	00002517          	auipc	a0,0x2
ffffffffc02004c2:	a5a50513          	addi	a0,a0,-1446 # ffffffffc0201f18 <commands+0x318>
ffffffffc02004c6:	bf1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004ca:	740c                	ld	a1,40(s0)
ffffffffc02004cc:	00002517          	auipc	a0,0x2
ffffffffc02004d0:	a6450513          	addi	a0,a0,-1436 # ffffffffc0201f30 <commands+0x330>
ffffffffc02004d4:	be3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d8:	780c                	ld	a1,48(s0)
ffffffffc02004da:	00002517          	auipc	a0,0x2
ffffffffc02004de:	a6e50513          	addi	a0,a0,-1426 # ffffffffc0201f48 <commands+0x348>
ffffffffc02004e2:	bd5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e6:	7c0c                	ld	a1,56(s0)
ffffffffc02004e8:	00002517          	auipc	a0,0x2
ffffffffc02004ec:	a7850513          	addi	a0,a0,-1416 # ffffffffc0201f60 <commands+0x360>
ffffffffc02004f0:	bc7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f4:	602c                	ld	a1,64(s0)
ffffffffc02004f6:	00002517          	auipc	a0,0x2
ffffffffc02004fa:	a8250513          	addi	a0,a0,-1406 # ffffffffc0201f78 <commands+0x378>
ffffffffc02004fe:	bb9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200502:	642c                	ld	a1,72(s0)
ffffffffc0200504:	00002517          	auipc	a0,0x2
ffffffffc0200508:	a8c50513          	addi	a0,a0,-1396 # ffffffffc0201f90 <commands+0x390>
ffffffffc020050c:	babff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200510:	682c                	ld	a1,80(s0)
ffffffffc0200512:	00002517          	auipc	a0,0x2
ffffffffc0200516:	a9650513          	addi	a0,a0,-1386 # ffffffffc0201fa8 <commands+0x3a8>
ffffffffc020051a:	b9dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020051e:	6c2c                	ld	a1,88(s0)
ffffffffc0200520:	00002517          	auipc	a0,0x2
ffffffffc0200524:	aa050513          	addi	a0,a0,-1376 # ffffffffc0201fc0 <commands+0x3c0>
ffffffffc0200528:	b8fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052c:	702c                	ld	a1,96(s0)
ffffffffc020052e:	00002517          	auipc	a0,0x2
ffffffffc0200532:	aaa50513          	addi	a0,a0,-1366 # ffffffffc0201fd8 <commands+0x3d8>
ffffffffc0200536:	b81ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020053a:	742c                	ld	a1,104(s0)
ffffffffc020053c:	00002517          	auipc	a0,0x2
ffffffffc0200540:	ab450513          	addi	a0,a0,-1356 # ffffffffc0201ff0 <commands+0x3f0>
ffffffffc0200544:	b73ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200548:	782c                	ld	a1,112(s0)
ffffffffc020054a:	00002517          	auipc	a0,0x2
ffffffffc020054e:	abe50513          	addi	a0,a0,-1346 # ffffffffc0202008 <commands+0x408>
ffffffffc0200552:	b65ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200556:	7c2c                	ld	a1,120(s0)
ffffffffc0200558:	00002517          	auipc	a0,0x2
ffffffffc020055c:	ac850513          	addi	a0,a0,-1336 # ffffffffc0202020 <commands+0x420>
ffffffffc0200560:	b57ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200564:	604c                	ld	a1,128(s0)
ffffffffc0200566:	00002517          	auipc	a0,0x2
ffffffffc020056a:	ad250513          	addi	a0,a0,-1326 # ffffffffc0202038 <commands+0x438>
ffffffffc020056e:	b49ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200572:	644c                	ld	a1,136(s0)
ffffffffc0200574:	00002517          	auipc	a0,0x2
ffffffffc0200578:	adc50513          	addi	a0,a0,-1316 # ffffffffc0202050 <commands+0x450>
ffffffffc020057c:	b3bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200580:	684c                	ld	a1,144(s0)
ffffffffc0200582:	00002517          	auipc	a0,0x2
ffffffffc0200586:	ae650513          	addi	a0,a0,-1306 # ffffffffc0202068 <commands+0x468>
ffffffffc020058a:	b2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020058e:	6c4c                	ld	a1,152(s0)
ffffffffc0200590:	00002517          	auipc	a0,0x2
ffffffffc0200594:	af050513          	addi	a0,a0,-1296 # ffffffffc0202080 <commands+0x480>
ffffffffc0200598:	b1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059c:	704c                	ld	a1,160(s0)
ffffffffc020059e:	00002517          	auipc	a0,0x2
ffffffffc02005a2:	afa50513          	addi	a0,a0,-1286 # ffffffffc0202098 <commands+0x498>
ffffffffc02005a6:	b11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005aa:	744c                	ld	a1,168(s0)
ffffffffc02005ac:	00002517          	auipc	a0,0x2
ffffffffc02005b0:	b0450513          	addi	a0,a0,-1276 # ffffffffc02020b0 <commands+0x4b0>
ffffffffc02005b4:	b03ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b8:	784c                	ld	a1,176(s0)
ffffffffc02005ba:	00002517          	auipc	a0,0x2
ffffffffc02005be:	b0e50513          	addi	a0,a0,-1266 # ffffffffc02020c8 <commands+0x4c8>
ffffffffc02005c2:	af5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c6:	7c4c                	ld	a1,184(s0)
ffffffffc02005c8:	00002517          	auipc	a0,0x2
ffffffffc02005cc:	b1850513          	addi	a0,a0,-1256 # ffffffffc02020e0 <commands+0x4e0>
ffffffffc02005d0:	ae7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d4:	606c                	ld	a1,192(s0)
ffffffffc02005d6:	00002517          	auipc	a0,0x2
ffffffffc02005da:	b2250513          	addi	a0,a0,-1246 # ffffffffc02020f8 <commands+0x4f8>
ffffffffc02005de:	ad9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e2:	646c                	ld	a1,200(s0)
ffffffffc02005e4:	00002517          	auipc	a0,0x2
ffffffffc02005e8:	b2c50513          	addi	a0,a0,-1236 # ffffffffc0202110 <commands+0x510>
ffffffffc02005ec:	acbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f0:	686c                	ld	a1,208(s0)
ffffffffc02005f2:	00002517          	auipc	a0,0x2
ffffffffc02005f6:	b3650513          	addi	a0,a0,-1226 # ffffffffc0202128 <commands+0x528>
ffffffffc02005fa:	abdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200600:	00002517          	auipc	a0,0x2
ffffffffc0200604:	b4050513          	addi	a0,a0,-1216 # ffffffffc0202140 <commands+0x540>
ffffffffc0200608:	aafff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060c:	706c                	ld	a1,224(s0)
ffffffffc020060e:	00002517          	auipc	a0,0x2
ffffffffc0200612:	b4a50513          	addi	a0,a0,-1206 # ffffffffc0202158 <commands+0x558>
ffffffffc0200616:	aa1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020061a:	746c                	ld	a1,232(s0)
ffffffffc020061c:	00002517          	auipc	a0,0x2
ffffffffc0200620:	b5450513          	addi	a0,a0,-1196 # ffffffffc0202170 <commands+0x570>
ffffffffc0200624:	a93ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200628:	786c                	ld	a1,240(s0)
ffffffffc020062a:	00002517          	auipc	a0,0x2
ffffffffc020062e:	b5e50513          	addi	a0,a0,-1186 # ffffffffc0202188 <commands+0x588>
ffffffffc0200632:	a85ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200638:	6402                	ld	s0,0(sp)
ffffffffc020063a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063c:	00002517          	auipc	a0,0x2
ffffffffc0200640:	b6450513          	addi	a0,a0,-1180 # ffffffffc02021a0 <commands+0x5a0>
}
ffffffffc0200644:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200646:	a71ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020064a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020064a:	1141                	addi	sp,sp,-16
ffffffffc020064c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020064e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200650:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200652:	00002517          	auipc	a0,0x2
ffffffffc0200656:	b6650513          	addi	a0,a0,-1178 # ffffffffc02021b8 <commands+0x5b8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020065a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020065c:	a5bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200660:	8522                	mv	a0,s0
ffffffffc0200662:	e1bff0ef          	jal	ra,ffffffffc020047c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200666:	10043583          	ld	a1,256(s0)
ffffffffc020066a:	00002517          	auipc	a0,0x2
ffffffffc020066e:	b6650513          	addi	a0,a0,-1178 # ffffffffc02021d0 <commands+0x5d0>
ffffffffc0200672:	a45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200676:	10843583          	ld	a1,264(s0)
ffffffffc020067a:	00002517          	auipc	a0,0x2
ffffffffc020067e:	b6e50513          	addi	a0,a0,-1170 # ffffffffc02021e8 <commands+0x5e8>
ffffffffc0200682:	a35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200686:	11043583          	ld	a1,272(s0)
ffffffffc020068a:	00002517          	auipc	a0,0x2
ffffffffc020068e:	b7650513          	addi	a0,a0,-1162 # ffffffffc0202200 <commands+0x600>
ffffffffc0200692:	a25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	11843583          	ld	a1,280(s0)
}
ffffffffc020069a:	6402                	ld	s0,0(sp)
ffffffffc020069c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069e:	00002517          	auipc	a0,0x2
ffffffffc02006a2:	b7a50513          	addi	a0,a0,-1158 # ffffffffc0202218 <commands+0x618>
}
ffffffffc02006a6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a8:	a0fff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02006ac <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006ac:	11853783          	ld	a5,280(a0)
ffffffffc02006b0:	577d                	li	a4,-1
ffffffffc02006b2:	8305                	srli	a4,a4,0x1
ffffffffc02006b4:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02006b6:	472d                	li	a4,11
ffffffffc02006b8:	08f76563          	bltu	a4,a5,ffffffffc0200742 <interrupt_handler+0x96>
ffffffffc02006bc:	00001717          	auipc	a4,0x1
ffffffffc02006c0:	70070713          	addi	a4,a4,1792 # ffffffffc0201dbc <commands+0x1bc>
ffffffffc02006c4:	078a                	slli	a5,a5,0x2
ffffffffc02006c6:	97ba                	add	a5,a5,a4
ffffffffc02006c8:	439c                	lw	a5,0(a5)
ffffffffc02006ca:	97ba                	add	a5,a5,a4
ffffffffc02006cc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006ce:	00001517          	auipc	a0,0x1
ffffffffc02006d2:	78250513          	addi	a0,a0,1922 # ffffffffc0201e50 <commands+0x250>
ffffffffc02006d6:	9e1ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006da:	00001517          	auipc	a0,0x1
ffffffffc02006de:	75650513          	addi	a0,a0,1878 # ffffffffc0201e30 <commands+0x230>
ffffffffc02006e2:	9d5ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006e6:	00001517          	auipc	a0,0x1
ffffffffc02006ea:	70a50513          	addi	a0,a0,1802 # ffffffffc0201df0 <commands+0x1f0>
ffffffffc02006ee:	9c9ff06f          	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006f2:	00001517          	auipc	a0,0x1
ffffffffc02006f6:	77e50513          	addi	a0,a0,1918 # ffffffffc0201e70 <commands+0x270>
ffffffffc02006fa:	9bdff06f          	j	ffffffffc02000b6 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006fe:	1141                	addi	sp,sp,-16
ffffffffc0200700:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200702:	d3fff0ef          	jal	ra,ffffffffc0200440 <clock_set_next_event>
            ticks++;
ffffffffc0200706:	00006717          	auipc	a4,0x6
ffffffffc020070a:	d2a70713          	addi	a4,a4,-726 # ffffffffc0206430 <ticks>
ffffffffc020070e:	631c                	ld	a5,0(a4)
            if (ticks == 100)
ffffffffc0200710:	06400693          	li	a3,100
            ticks++;
ffffffffc0200714:	0785                	addi	a5,a5,1
ffffffffc0200716:	00006617          	auipc	a2,0x6
ffffffffc020071a:	d0f63d23          	sd	a5,-742(a2) # ffffffffc0206430 <ticks>
            if (ticks == 100)
ffffffffc020071e:	631c                	ld	a5,0(a4)
ffffffffc0200720:	02d78363          	beq	a5,a3,ffffffffc0200746 <interrupt_handler+0x9a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200724:	60a2                	ld	ra,8(sp)
ffffffffc0200726:	0141                	addi	sp,sp,16
ffffffffc0200728:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc020072a:	00001517          	auipc	a0,0x1
ffffffffc020072e:	76e50513          	addi	a0,a0,1902 # ffffffffc0201e98 <commands+0x298>
ffffffffc0200732:	985ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200736:	00001517          	auipc	a0,0x1
ffffffffc020073a:	6da50513          	addi	a0,a0,1754 # ffffffffc0201e10 <commands+0x210>
ffffffffc020073e:	979ff06f          	j	ffffffffc02000b6 <cprintf>
            print_trapframe(tf);
ffffffffc0200742:	f09ff06f          	j	ffffffffc020064a <print_trapframe>
}
ffffffffc0200746:	60a2                	ld	ra,8(sp)
                ticks = 0;
ffffffffc0200748:	00006797          	auipc	a5,0x6
ffffffffc020074c:	ce07b423          	sd	zero,-792(a5) # ffffffffc0206430 <ticks>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200750:	06400593          	li	a1,100
ffffffffc0200754:	00001517          	auipc	a0,0x1
ffffffffc0200758:	73450513          	addi	a0,a0,1844 # ffffffffc0201e88 <commands+0x288>
}
ffffffffc020075c:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020075e:	959ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc0200762 <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200762:	11853783          	ld	a5,280(a0)
ffffffffc0200766:	0007c863          	bltz	a5,ffffffffc0200776 <trap+0x14>
    switch (tf->cause) {
ffffffffc020076a:	472d                	li	a4,11
ffffffffc020076c:	00f76363          	bltu	a4,a5,ffffffffc0200772 <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200770:	8082                	ret
            print_trapframe(tf);
ffffffffc0200772:	ed9ff06f          	j	ffffffffc020064a <print_trapframe>
        interrupt_handler(tf);
ffffffffc0200776:	f37ff06f          	j	ffffffffc02006ac <interrupt_handler>
	...

ffffffffc020077c <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc020077c:	14011073          	csrw	sscratch,sp
ffffffffc0200780:	712d                	addi	sp,sp,-288
ffffffffc0200782:	e002                	sd	zero,0(sp)
ffffffffc0200784:	e406                	sd	ra,8(sp)
ffffffffc0200786:	ec0e                	sd	gp,24(sp)
ffffffffc0200788:	f012                	sd	tp,32(sp)
ffffffffc020078a:	f416                	sd	t0,40(sp)
ffffffffc020078c:	f81a                	sd	t1,48(sp)
ffffffffc020078e:	fc1e                	sd	t2,56(sp)
ffffffffc0200790:	e0a2                	sd	s0,64(sp)
ffffffffc0200792:	e4a6                	sd	s1,72(sp)
ffffffffc0200794:	e8aa                	sd	a0,80(sp)
ffffffffc0200796:	ecae                	sd	a1,88(sp)
ffffffffc0200798:	f0b2                	sd	a2,96(sp)
ffffffffc020079a:	f4b6                	sd	a3,104(sp)
ffffffffc020079c:	f8ba                	sd	a4,112(sp)
ffffffffc020079e:	fcbe                	sd	a5,120(sp)
ffffffffc02007a0:	e142                	sd	a6,128(sp)
ffffffffc02007a2:	e546                	sd	a7,136(sp)
ffffffffc02007a4:	e94a                	sd	s2,144(sp)
ffffffffc02007a6:	ed4e                	sd	s3,152(sp)
ffffffffc02007a8:	f152                	sd	s4,160(sp)
ffffffffc02007aa:	f556                	sd	s5,168(sp)
ffffffffc02007ac:	f95a                	sd	s6,176(sp)
ffffffffc02007ae:	fd5e                	sd	s7,184(sp)
ffffffffc02007b0:	e1e2                	sd	s8,192(sp)
ffffffffc02007b2:	e5e6                	sd	s9,200(sp)
ffffffffc02007b4:	e9ea                	sd	s10,208(sp)
ffffffffc02007b6:	edee                	sd	s11,216(sp)
ffffffffc02007b8:	f1f2                	sd	t3,224(sp)
ffffffffc02007ba:	f5f6                	sd	t4,232(sp)
ffffffffc02007bc:	f9fa                	sd	t5,240(sp)
ffffffffc02007be:	fdfe                	sd	t6,248(sp)
ffffffffc02007c0:	14001473          	csrrw	s0,sscratch,zero
ffffffffc02007c4:	100024f3          	csrr	s1,sstatus
ffffffffc02007c8:	14102973          	csrr	s2,sepc
ffffffffc02007cc:	143029f3          	csrr	s3,stval
ffffffffc02007d0:	14202a73          	csrr	s4,scause
ffffffffc02007d4:	e822                	sd	s0,16(sp)
ffffffffc02007d6:	e226                	sd	s1,256(sp)
ffffffffc02007d8:	e64a                	sd	s2,264(sp)
ffffffffc02007da:	ea4e                	sd	s3,272(sp)
ffffffffc02007dc:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007de:	850a                	mv	a0,sp
    jal trap
ffffffffc02007e0:	f83ff0ef          	jal	ra,ffffffffc0200762 <trap>

ffffffffc02007e4 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007e4:	6492                	ld	s1,256(sp)
ffffffffc02007e6:	6932                	ld	s2,264(sp)
ffffffffc02007e8:	10049073          	csrw	sstatus,s1
ffffffffc02007ec:	14191073          	csrw	sepc,s2
ffffffffc02007f0:	60a2                	ld	ra,8(sp)
ffffffffc02007f2:	61e2                	ld	gp,24(sp)
ffffffffc02007f4:	7202                	ld	tp,32(sp)
ffffffffc02007f6:	72a2                	ld	t0,40(sp)
ffffffffc02007f8:	7342                	ld	t1,48(sp)
ffffffffc02007fa:	73e2                	ld	t2,56(sp)
ffffffffc02007fc:	6406                	ld	s0,64(sp)
ffffffffc02007fe:	64a6                	ld	s1,72(sp)
ffffffffc0200800:	6546                	ld	a0,80(sp)
ffffffffc0200802:	65e6                	ld	a1,88(sp)
ffffffffc0200804:	7606                	ld	a2,96(sp)
ffffffffc0200806:	76a6                	ld	a3,104(sp)
ffffffffc0200808:	7746                	ld	a4,112(sp)
ffffffffc020080a:	77e6                	ld	a5,120(sp)
ffffffffc020080c:	680a                	ld	a6,128(sp)
ffffffffc020080e:	68aa                	ld	a7,136(sp)
ffffffffc0200810:	694a                	ld	s2,144(sp)
ffffffffc0200812:	69ea                	ld	s3,152(sp)
ffffffffc0200814:	7a0a                	ld	s4,160(sp)
ffffffffc0200816:	7aaa                	ld	s5,168(sp)
ffffffffc0200818:	7b4a                	ld	s6,176(sp)
ffffffffc020081a:	7bea                	ld	s7,184(sp)
ffffffffc020081c:	6c0e                	ld	s8,192(sp)
ffffffffc020081e:	6cae                	ld	s9,200(sp)
ffffffffc0200820:	6d4e                	ld	s10,208(sp)
ffffffffc0200822:	6dee                	ld	s11,216(sp)
ffffffffc0200824:	7e0e                	ld	t3,224(sp)
ffffffffc0200826:	7eae                	ld	t4,232(sp)
ffffffffc0200828:	7f4e                	ld	t5,240(sp)
ffffffffc020082a:	7fee                	ld	t6,248(sp)
ffffffffc020082c:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc020082e:	10200073          	sret

ffffffffc0200832 <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {  //
    elm->prev = elm->next = elm;
ffffffffc0200832:	00006797          	auipc	a5,0x6
ffffffffc0200836:	c0678793          	addi	a5,a5,-1018 # ffffffffc0206438 <free_area>
ffffffffc020083a:	e79c                	sd	a5,8(a5)
ffffffffc020083c:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc020083e:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200842:	8082                	ret

ffffffffc0200844 <best_fit_nr_free_pages>:
}

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200844:	00006517          	auipc	a0,0x6
ffffffffc0200848:	c0456503          	lwu	a0,-1020(a0) # ffffffffc0206448 <free_area+0x10>
ffffffffc020084c:	8082                	ret

ffffffffc020084e <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc020084e:	c15d                	beqz	a0,ffffffffc02008f4 <best_fit_alloc_pages+0xa6>
    if (n > nr_free) {
ffffffffc0200850:	00006617          	auipc	a2,0x6
ffffffffc0200854:	be860613          	addi	a2,a2,-1048 # ffffffffc0206438 <free_area>
ffffffffc0200858:	01062803          	lw	a6,16(a2)
ffffffffc020085c:	86aa                	mv	a3,a0
ffffffffc020085e:	02081793          	slli	a5,a6,0x20
ffffffffc0200862:	9381                	srli	a5,a5,0x20
ffffffffc0200864:	08a7e663          	bltu	a5,a0,ffffffffc02008f0 <best_fit_alloc_pages+0xa2>
    size_t min_size = nr_free + 1;
ffffffffc0200868:	0018059b          	addiw	a1,a6,1
ffffffffc020086c:	1582                	slli	a1,a1,0x20
ffffffffc020086e:	9181                	srli	a1,a1,0x20
    list_entry_t *le = &free_list;
ffffffffc0200870:	87b2                	mv	a5,a2
    struct Page *page = NULL;
ffffffffc0200872:	4501                	li	a0,0
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200874:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200876:	00c78e63          	beq	a5,a2,ffffffffc0200892 <best_fit_alloc_pages+0x44>
        if ((p->property >= n)&&(p->property < min_size)) {
ffffffffc020087a:	ff87e703          	lwu	a4,-8(a5)
ffffffffc020087e:	fed76be3          	bltu	a4,a3,ffffffffc0200874 <best_fit_alloc_pages+0x26>
ffffffffc0200882:	feb779e3          	bleu	a1,a4,ffffffffc0200874 <best_fit_alloc_pages+0x26>
        struct Page *p = le2page(le, page_link);
ffffffffc0200886:	fe878513          	addi	a0,a5,-24
ffffffffc020088a:	679c                	ld	a5,8(a5)
ffffffffc020088c:	85ba                	mv	a1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc020088e:	fec796e3          	bne	a5,a2,ffffffffc020087a <best_fit_alloc_pages+0x2c>
    if (page != NULL) {
ffffffffc0200892:	c125                	beqz	a0,ffffffffc02008f2 <best_fit_alloc_pages+0xa4>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200894:	7118                	ld	a4,32(a0)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc0200896:	6d10                	ld	a2,24(a0)
        if (page->property > n) {
ffffffffc0200898:	490c                	lw	a1,16(a0)
ffffffffc020089a:	0006889b          	sext.w	a7,a3
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020089e:	e618                	sd	a4,8(a2)
    next->prev = prev;
ffffffffc02008a0:	e310                	sd	a2,0(a4)
ffffffffc02008a2:	02059713          	slli	a4,a1,0x20
ffffffffc02008a6:	9301                	srli	a4,a4,0x20
ffffffffc02008a8:	02e6f863          	bleu	a4,a3,ffffffffc02008d8 <best_fit_alloc_pages+0x8a>
            struct Page *p = page + n;
ffffffffc02008ac:	00269713          	slli	a4,a3,0x2
ffffffffc02008b0:	9736                	add	a4,a4,a3
ffffffffc02008b2:	070e                	slli	a4,a4,0x3
ffffffffc02008b4:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc02008b6:	411585bb          	subw	a1,a1,a7
ffffffffc02008ba:	cb0c                	sw	a1,16(a4)
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02008bc:	4689                	li	a3,2
ffffffffc02008be:	00870593          	addi	a1,a4,8
ffffffffc02008c2:	40d5b02f          	amoor.d	zero,a3,(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc02008c6:	6614                	ld	a3,8(a2)
            list_add(prev, &(p->page_link));
ffffffffc02008c8:	01870593          	addi	a1,a4,24
    prev->next = next->prev = elm;
ffffffffc02008cc:	0107a803          	lw	a6,16(a5)
ffffffffc02008d0:	e28c                	sd	a1,0(a3)
ffffffffc02008d2:	e60c                	sd	a1,8(a2)
    elm->next = next;
ffffffffc02008d4:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc02008d6:	ef10                	sd	a2,24(a4)
        nr_free -= n;
ffffffffc02008d8:	4118083b          	subw	a6,a6,a7
ffffffffc02008dc:	00006797          	auipc	a5,0x6
ffffffffc02008e0:	b707a623          	sw	a6,-1172(a5) # ffffffffc0206448 <free_area+0x10>
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02008e4:	57f5                	li	a5,-3
ffffffffc02008e6:	00850713          	addi	a4,a0,8
ffffffffc02008ea:	60f7302f          	amoand.d	zero,a5,(a4)
ffffffffc02008ee:	8082                	ret
        return NULL;
ffffffffc02008f0:	4501                	li	a0,0
}
ffffffffc02008f2:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc02008f4:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02008f6:	00002697          	auipc	a3,0x2
ffffffffc02008fa:	93a68693          	addi	a3,a3,-1734 # ffffffffc0202230 <commands+0x630>
ffffffffc02008fe:	00002617          	auipc	a2,0x2
ffffffffc0200902:	93a60613          	addi	a2,a2,-1734 # ffffffffc0202238 <commands+0x638>
ffffffffc0200906:	06e00593          	li	a1,110
ffffffffc020090a:	00002517          	auipc	a0,0x2
ffffffffc020090e:	94650513          	addi	a0,a0,-1722 # ffffffffc0202250 <commands+0x650>
best_fit_alloc_pages(size_t n) {
ffffffffc0200912:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200914:	a99ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200918 <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc0200918:	715d                	addi	sp,sp,-80
ffffffffc020091a:	f84a                	sd	s2,48(sp)
    return listelm->next;
ffffffffc020091c:	00006917          	auipc	s2,0x6
ffffffffc0200920:	b1c90913          	addi	s2,s2,-1252 # ffffffffc0206438 <free_area>
ffffffffc0200924:	00893783          	ld	a5,8(s2)
ffffffffc0200928:	e486                	sd	ra,72(sp)
ffffffffc020092a:	e0a2                	sd	s0,64(sp)
ffffffffc020092c:	fc26                	sd	s1,56(sp)
ffffffffc020092e:	f44e                	sd	s3,40(sp)
ffffffffc0200930:	f052                	sd	s4,32(sp)
ffffffffc0200932:	ec56                	sd	s5,24(sp)
ffffffffc0200934:	e85a                	sd	s6,16(sp)
ffffffffc0200936:	e45e                	sd	s7,8(sp)
ffffffffc0200938:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020093a:	2d278363          	beq	a5,s2,ffffffffc0200c00 <best_fit_check+0x2e8>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020093e:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200942:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200944:	8b05                	andi	a4,a4,1
ffffffffc0200946:	2c070163          	beqz	a4,ffffffffc0200c08 <best_fit_check+0x2f0>
    int count = 0, total = 0;
ffffffffc020094a:	4401                	li	s0,0
ffffffffc020094c:	4481                	li	s1,0
ffffffffc020094e:	a031                	j	ffffffffc020095a <best_fit_check+0x42>
ffffffffc0200950:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0200954:	8b09                	andi	a4,a4,2
ffffffffc0200956:	2a070963          	beqz	a4,ffffffffc0200c08 <best_fit_check+0x2f0>
        count ++, total += p->property;
ffffffffc020095a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020095e:	679c                	ld	a5,8(a5)
ffffffffc0200960:	2485                	addiw	s1,s1,1
ffffffffc0200962:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200964:	ff2796e3          	bne	a5,s2,ffffffffc0200950 <best_fit_check+0x38>
ffffffffc0200968:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc020096a:	1f7000ef          	jal	ra,ffffffffc0201360 <nr_free_pages>
ffffffffc020096e:	37351d63          	bne	a0,s3,ffffffffc0200ce8 <best_fit_check+0x3d0>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200972:	4505                	li	a0,1
ffffffffc0200974:	163000ef          	jal	ra,ffffffffc02012d6 <alloc_pages>
ffffffffc0200978:	8a2a                	mv	s4,a0
ffffffffc020097a:	3a050763          	beqz	a0,ffffffffc0200d28 <best_fit_check+0x410>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020097e:	4505                	li	a0,1
ffffffffc0200980:	157000ef          	jal	ra,ffffffffc02012d6 <alloc_pages>
ffffffffc0200984:	89aa                	mv	s3,a0
ffffffffc0200986:	38050163          	beqz	a0,ffffffffc0200d08 <best_fit_check+0x3f0>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020098a:	4505                	li	a0,1
ffffffffc020098c:	14b000ef          	jal	ra,ffffffffc02012d6 <alloc_pages>
ffffffffc0200990:	8aaa                	mv	s5,a0
ffffffffc0200992:	30050b63          	beqz	a0,ffffffffc0200ca8 <best_fit_check+0x390>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200996:	293a0963          	beq	s4,s3,ffffffffc0200c28 <best_fit_check+0x310>
ffffffffc020099a:	28aa0763          	beq	s4,a0,ffffffffc0200c28 <best_fit_check+0x310>
ffffffffc020099e:	28a98563          	beq	s3,a0,ffffffffc0200c28 <best_fit_check+0x310>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02009a2:	000a2783          	lw	a5,0(s4)
ffffffffc02009a6:	2a079163          	bnez	a5,ffffffffc0200c48 <best_fit_check+0x330>
ffffffffc02009aa:	0009a783          	lw	a5,0(s3)
ffffffffc02009ae:	28079d63          	bnez	a5,ffffffffc0200c48 <best_fit_check+0x330>
ffffffffc02009b2:	411c                	lw	a5,0(a0)
ffffffffc02009b4:	28079a63          	bnez	a5,ffffffffc0200c48 <best_fit_check+0x330>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02009b8:	00006797          	auipc	a5,0x6
ffffffffc02009bc:	ab078793          	addi	a5,a5,-1360 # ffffffffc0206468 <pages>
ffffffffc02009c0:	639c                	ld	a5,0(a5)
ffffffffc02009c2:	00002717          	auipc	a4,0x2
ffffffffc02009c6:	8a670713          	addi	a4,a4,-1882 # ffffffffc0202268 <commands+0x668>
ffffffffc02009ca:	630c                	ld	a1,0(a4)
ffffffffc02009cc:	40fa0733          	sub	a4,s4,a5
ffffffffc02009d0:	870d                	srai	a4,a4,0x3
ffffffffc02009d2:	02b70733          	mul	a4,a4,a1
ffffffffc02009d6:	00002697          	auipc	a3,0x2
ffffffffc02009da:	f5268693          	addi	a3,a3,-174 # ffffffffc0202928 <nbase>
ffffffffc02009de:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02009e0:	00006697          	auipc	a3,0x6
ffffffffc02009e4:	a3868693          	addi	a3,a3,-1480 # ffffffffc0206418 <npage>
ffffffffc02009e8:	6294                	ld	a3,0(a3)
ffffffffc02009ea:	06b2                	slli	a3,a3,0xc
ffffffffc02009ec:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc02009ee:	0732                	slli	a4,a4,0xc
ffffffffc02009f0:	26d77c63          	bleu	a3,a4,ffffffffc0200c68 <best_fit_check+0x350>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02009f4:	40f98733          	sub	a4,s3,a5
ffffffffc02009f8:	870d                	srai	a4,a4,0x3
ffffffffc02009fa:	02b70733          	mul	a4,a4,a1
ffffffffc02009fe:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200a00:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200a02:	42d77363          	bleu	a3,a4,ffffffffc0200e28 <best_fit_check+0x510>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200a06:	40f507b3          	sub	a5,a0,a5
ffffffffc0200a0a:	878d                	srai	a5,a5,0x3
ffffffffc0200a0c:	02b787b3          	mul	a5,a5,a1
ffffffffc0200a10:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200a12:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200a14:	3ed7fa63          	bleu	a3,a5,ffffffffc0200e08 <best_fit_check+0x4f0>
    assert(alloc_page() == NULL);
ffffffffc0200a18:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200a1a:	00093c03          	ld	s8,0(s2)
ffffffffc0200a1e:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200a22:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200a26:	00006797          	auipc	a5,0x6
ffffffffc0200a2a:	a127bd23          	sd	s2,-1510(a5) # ffffffffc0206440 <free_area+0x8>
ffffffffc0200a2e:	00006797          	auipc	a5,0x6
ffffffffc0200a32:	a127b523          	sd	s2,-1526(a5) # ffffffffc0206438 <free_area>
    nr_free = 0;
ffffffffc0200a36:	00006797          	auipc	a5,0x6
ffffffffc0200a3a:	a007a923          	sw	zero,-1518(a5) # ffffffffc0206448 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200a3e:	099000ef          	jal	ra,ffffffffc02012d6 <alloc_pages>
ffffffffc0200a42:	3a051363          	bnez	a0,ffffffffc0200de8 <best_fit_check+0x4d0>
    free_page(p0);
ffffffffc0200a46:	4585                	li	a1,1
ffffffffc0200a48:	8552                	mv	a0,s4
ffffffffc0200a4a:	0d1000ef          	jal	ra,ffffffffc020131a <free_pages>
    free_page(p1);
ffffffffc0200a4e:	4585                	li	a1,1
ffffffffc0200a50:	854e                	mv	a0,s3
ffffffffc0200a52:	0c9000ef          	jal	ra,ffffffffc020131a <free_pages>
    free_page(p2);
ffffffffc0200a56:	4585                	li	a1,1
ffffffffc0200a58:	8556                	mv	a0,s5
ffffffffc0200a5a:	0c1000ef          	jal	ra,ffffffffc020131a <free_pages>
    assert(nr_free == 3);
ffffffffc0200a5e:	01092703          	lw	a4,16(s2)
ffffffffc0200a62:	478d                	li	a5,3
ffffffffc0200a64:	36f71263          	bne	a4,a5,ffffffffc0200dc8 <best_fit_check+0x4b0>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200a68:	4505                	li	a0,1
ffffffffc0200a6a:	06d000ef          	jal	ra,ffffffffc02012d6 <alloc_pages>
ffffffffc0200a6e:	89aa                	mv	s3,a0
ffffffffc0200a70:	32050c63          	beqz	a0,ffffffffc0200da8 <best_fit_check+0x490>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200a74:	4505                	li	a0,1
ffffffffc0200a76:	061000ef          	jal	ra,ffffffffc02012d6 <alloc_pages>
ffffffffc0200a7a:	8aaa                	mv	s5,a0
ffffffffc0200a7c:	30050663          	beqz	a0,ffffffffc0200d88 <best_fit_check+0x470>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200a80:	4505                	li	a0,1
ffffffffc0200a82:	055000ef          	jal	ra,ffffffffc02012d6 <alloc_pages>
ffffffffc0200a86:	8a2a                	mv	s4,a0
ffffffffc0200a88:	2e050063          	beqz	a0,ffffffffc0200d68 <best_fit_check+0x450>
    assert(alloc_page() == NULL);
ffffffffc0200a8c:	4505                	li	a0,1
ffffffffc0200a8e:	049000ef          	jal	ra,ffffffffc02012d6 <alloc_pages>
ffffffffc0200a92:	2a051b63          	bnez	a0,ffffffffc0200d48 <best_fit_check+0x430>
    free_page(p0);
ffffffffc0200a96:	4585                	li	a1,1
ffffffffc0200a98:	854e                	mv	a0,s3
ffffffffc0200a9a:	081000ef          	jal	ra,ffffffffc020131a <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200a9e:	00893783          	ld	a5,8(s2)
ffffffffc0200aa2:	1f278363          	beq	a5,s2,ffffffffc0200c88 <best_fit_check+0x370>
    assert((p = alloc_page()) == p0);
ffffffffc0200aa6:	4505                	li	a0,1
ffffffffc0200aa8:	02f000ef          	jal	ra,ffffffffc02012d6 <alloc_pages>
ffffffffc0200aac:	54a99e63          	bne	s3,a0,ffffffffc0201008 <best_fit_check+0x6f0>
    assert(alloc_page() == NULL);
ffffffffc0200ab0:	4505                	li	a0,1
ffffffffc0200ab2:	025000ef          	jal	ra,ffffffffc02012d6 <alloc_pages>
ffffffffc0200ab6:	52051963          	bnez	a0,ffffffffc0200fe8 <best_fit_check+0x6d0>
    assert(nr_free == 0);
ffffffffc0200aba:	01092783          	lw	a5,16(s2)
ffffffffc0200abe:	50079563          	bnez	a5,ffffffffc0200fc8 <best_fit_check+0x6b0>
    free_page(p);
ffffffffc0200ac2:	854e                	mv	a0,s3
ffffffffc0200ac4:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200ac6:	00006797          	auipc	a5,0x6
ffffffffc0200aca:	9787b923          	sd	s8,-1678(a5) # ffffffffc0206438 <free_area>
ffffffffc0200ace:	00006797          	auipc	a5,0x6
ffffffffc0200ad2:	9777b923          	sd	s7,-1678(a5) # ffffffffc0206440 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200ad6:	00006797          	auipc	a5,0x6
ffffffffc0200ada:	9767a923          	sw	s6,-1678(a5) # ffffffffc0206448 <free_area+0x10>
    free_page(p);
ffffffffc0200ade:	03d000ef          	jal	ra,ffffffffc020131a <free_pages>
    free_page(p1);
ffffffffc0200ae2:	4585                	li	a1,1
ffffffffc0200ae4:	8556                	mv	a0,s5
ffffffffc0200ae6:	035000ef          	jal	ra,ffffffffc020131a <free_pages>
    free_page(p2);
ffffffffc0200aea:	4585                	li	a1,1
ffffffffc0200aec:	8552                	mv	a0,s4
ffffffffc0200aee:	02d000ef          	jal	ra,ffffffffc020131a <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200af2:	4515                	li	a0,5
ffffffffc0200af4:	7e2000ef          	jal	ra,ffffffffc02012d6 <alloc_pages>
ffffffffc0200af8:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200afa:	4a050763          	beqz	a0,ffffffffc0200fa8 <best_fit_check+0x690>
ffffffffc0200afe:	651c                	ld	a5,8(a0)
ffffffffc0200b00:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200b02:	8b85                	andi	a5,a5,1
ffffffffc0200b04:	48079263          	bnez	a5,ffffffffc0200f88 <best_fit_check+0x670>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200b08:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200b0a:	00093b03          	ld	s6,0(s2)
ffffffffc0200b0e:	00893a83          	ld	s5,8(s2)
ffffffffc0200b12:	00006797          	auipc	a5,0x6
ffffffffc0200b16:	9327b323          	sd	s2,-1754(a5) # ffffffffc0206438 <free_area>
ffffffffc0200b1a:	00006797          	auipc	a5,0x6
ffffffffc0200b1e:	9327b323          	sd	s2,-1754(a5) # ffffffffc0206440 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200b22:	7b4000ef          	jal	ra,ffffffffc02012d6 <alloc_pages>
ffffffffc0200b26:	44051163          	bnez	a0,ffffffffc0200f68 <best_fit_check+0x650>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc0200b2a:	4589                	li	a1,2
ffffffffc0200b2c:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc0200b30:	01092b83          	lw	s7,16(s2)
    free_pages(p0 + 4, 1);
ffffffffc0200b34:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc0200b38:	00006797          	auipc	a5,0x6
ffffffffc0200b3c:	9007a823          	sw	zero,-1776(a5) # ffffffffc0206448 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc0200b40:	7da000ef          	jal	ra,ffffffffc020131a <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0200b44:	8562                	mv	a0,s8
ffffffffc0200b46:	4585                	li	a1,1
ffffffffc0200b48:	7d2000ef          	jal	ra,ffffffffc020131a <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200b4c:	4511                	li	a0,4
ffffffffc0200b4e:	788000ef          	jal	ra,ffffffffc02012d6 <alloc_pages>
ffffffffc0200b52:	3e051b63          	bnez	a0,ffffffffc0200f48 <best_fit_check+0x630>
ffffffffc0200b56:	0309b783          	ld	a5,48(s3)
ffffffffc0200b5a:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200b5c:	8b85                	andi	a5,a5,1
ffffffffc0200b5e:	3c078563          	beqz	a5,ffffffffc0200f28 <best_fit_check+0x610>
ffffffffc0200b62:	0389a703          	lw	a4,56(s3)
ffffffffc0200b66:	4789                	li	a5,2
ffffffffc0200b68:	3cf71063          	bne	a4,a5,ffffffffc0200f28 <best_fit_check+0x610>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200b6c:	4505                	li	a0,1
ffffffffc0200b6e:	768000ef          	jal	ra,ffffffffc02012d6 <alloc_pages>
ffffffffc0200b72:	8a2a                	mv	s4,a0
ffffffffc0200b74:	38050a63          	beqz	a0,ffffffffc0200f08 <best_fit_check+0x5f0>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200b78:	4509                	li	a0,2
ffffffffc0200b7a:	75c000ef          	jal	ra,ffffffffc02012d6 <alloc_pages>
ffffffffc0200b7e:	36050563          	beqz	a0,ffffffffc0200ee8 <best_fit_check+0x5d0>
    assert(p0 + 4 == p1);
ffffffffc0200b82:	354c1363          	bne	s8,s4,ffffffffc0200ec8 <best_fit_check+0x5b0>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0200b86:	854e                	mv	a0,s3
ffffffffc0200b88:	4595                	li	a1,5
ffffffffc0200b8a:	790000ef          	jal	ra,ffffffffc020131a <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200b8e:	4515                	li	a0,5
ffffffffc0200b90:	746000ef          	jal	ra,ffffffffc02012d6 <alloc_pages>
ffffffffc0200b94:	89aa                	mv	s3,a0
ffffffffc0200b96:	30050963          	beqz	a0,ffffffffc0200ea8 <best_fit_check+0x590>
    assert(alloc_page() == NULL);
ffffffffc0200b9a:	4505                	li	a0,1
ffffffffc0200b9c:	73a000ef          	jal	ra,ffffffffc02012d6 <alloc_pages>
ffffffffc0200ba0:	2e051463          	bnez	a0,ffffffffc0200e88 <best_fit_check+0x570>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc0200ba4:	01092783          	lw	a5,16(s2)
ffffffffc0200ba8:	2c079063          	bnez	a5,ffffffffc0200e68 <best_fit_check+0x550>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200bac:	4595                	li	a1,5
ffffffffc0200bae:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200bb0:	00006797          	auipc	a5,0x6
ffffffffc0200bb4:	8977ac23          	sw	s7,-1896(a5) # ffffffffc0206448 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200bb8:	00006797          	auipc	a5,0x6
ffffffffc0200bbc:	8967b023          	sd	s6,-1920(a5) # ffffffffc0206438 <free_area>
ffffffffc0200bc0:	00006797          	auipc	a5,0x6
ffffffffc0200bc4:	8957b023          	sd	s5,-1920(a5) # ffffffffc0206440 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0200bc8:	752000ef          	jal	ra,ffffffffc020131a <free_pages>
    return listelm->next;
ffffffffc0200bcc:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bd0:	01278963          	beq	a5,s2,ffffffffc0200be2 <best_fit_check+0x2ca>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200bd4:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200bd8:	679c                	ld	a5,8(a5)
ffffffffc0200bda:	34fd                	addiw	s1,s1,-1
ffffffffc0200bdc:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bde:	ff279be3          	bne	a5,s2,ffffffffc0200bd4 <best_fit_check+0x2bc>
    }
    assert(count == 0);
ffffffffc0200be2:	26049363          	bnez	s1,ffffffffc0200e48 <best_fit_check+0x530>
    assert(total == 0);
ffffffffc0200be6:	e06d                	bnez	s0,ffffffffc0200cc8 <best_fit_check+0x3b0>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc0200be8:	60a6                	ld	ra,72(sp)
ffffffffc0200bea:	6406                	ld	s0,64(sp)
ffffffffc0200bec:	74e2                	ld	s1,56(sp)
ffffffffc0200bee:	7942                	ld	s2,48(sp)
ffffffffc0200bf0:	79a2                	ld	s3,40(sp)
ffffffffc0200bf2:	7a02                	ld	s4,32(sp)
ffffffffc0200bf4:	6ae2                	ld	s5,24(sp)
ffffffffc0200bf6:	6b42                	ld	s6,16(sp)
ffffffffc0200bf8:	6ba2                	ld	s7,8(sp)
ffffffffc0200bfa:	6c02                	ld	s8,0(sp)
ffffffffc0200bfc:	6161                	addi	sp,sp,80
ffffffffc0200bfe:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200c00:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200c02:	4401                	li	s0,0
ffffffffc0200c04:	4481                	li	s1,0
ffffffffc0200c06:	b395                	j	ffffffffc020096a <best_fit_check+0x52>
        assert(PageProperty(p));
ffffffffc0200c08:	00001697          	auipc	a3,0x1
ffffffffc0200c0c:	66868693          	addi	a3,a3,1640 # ffffffffc0202270 <commands+0x670>
ffffffffc0200c10:	00001617          	auipc	a2,0x1
ffffffffc0200c14:	62860613          	addi	a2,a2,1576 # ffffffffc0202238 <commands+0x638>
ffffffffc0200c18:	10d00593          	li	a1,269
ffffffffc0200c1c:	00001517          	auipc	a0,0x1
ffffffffc0200c20:	63450513          	addi	a0,a0,1588 # ffffffffc0202250 <commands+0x650>
ffffffffc0200c24:	f88ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200c28:	00001697          	auipc	a3,0x1
ffffffffc0200c2c:	6d868693          	addi	a3,a3,1752 # ffffffffc0202300 <commands+0x700>
ffffffffc0200c30:	00001617          	auipc	a2,0x1
ffffffffc0200c34:	60860613          	addi	a2,a2,1544 # ffffffffc0202238 <commands+0x638>
ffffffffc0200c38:	0d900593          	li	a1,217
ffffffffc0200c3c:	00001517          	auipc	a0,0x1
ffffffffc0200c40:	61450513          	addi	a0,a0,1556 # ffffffffc0202250 <commands+0x650>
ffffffffc0200c44:	f68ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200c48:	00001697          	auipc	a3,0x1
ffffffffc0200c4c:	6e068693          	addi	a3,a3,1760 # ffffffffc0202328 <commands+0x728>
ffffffffc0200c50:	00001617          	auipc	a2,0x1
ffffffffc0200c54:	5e860613          	addi	a2,a2,1512 # ffffffffc0202238 <commands+0x638>
ffffffffc0200c58:	0da00593          	li	a1,218
ffffffffc0200c5c:	00001517          	auipc	a0,0x1
ffffffffc0200c60:	5f450513          	addi	a0,a0,1524 # ffffffffc0202250 <commands+0x650>
ffffffffc0200c64:	f48ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200c68:	00001697          	auipc	a3,0x1
ffffffffc0200c6c:	70068693          	addi	a3,a3,1792 # ffffffffc0202368 <commands+0x768>
ffffffffc0200c70:	00001617          	auipc	a2,0x1
ffffffffc0200c74:	5c860613          	addi	a2,a2,1480 # ffffffffc0202238 <commands+0x638>
ffffffffc0200c78:	0dc00593          	li	a1,220
ffffffffc0200c7c:	00001517          	auipc	a0,0x1
ffffffffc0200c80:	5d450513          	addi	a0,a0,1492 # ffffffffc0202250 <commands+0x650>
ffffffffc0200c84:	f28ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200c88:	00001697          	auipc	a3,0x1
ffffffffc0200c8c:	76868693          	addi	a3,a3,1896 # ffffffffc02023f0 <commands+0x7f0>
ffffffffc0200c90:	00001617          	auipc	a2,0x1
ffffffffc0200c94:	5a860613          	addi	a2,a2,1448 # ffffffffc0202238 <commands+0x638>
ffffffffc0200c98:	0f500593          	li	a1,245
ffffffffc0200c9c:	00001517          	auipc	a0,0x1
ffffffffc0200ca0:	5b450513          	addi	a0,a0,1460 # ffffffffc0202250 <commands+0x650>
ffffffffc0200ca4:	f08ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ca8:	00001697          	auipc	a3,0x1
ffffffffc0200cac:	63868693          	addi	a3,a3,1592 # ffffffffc02022e0 <commands+0x6e0>
ffffffffc0200cb0:	00001617          	auipc	a2,0x1
ffffffffc0200cb4:	58860613          	addi	a2,a2,1416 # ffffffffc0202238 <commands+0x638>
ffffffffc0200cb8:	0d700593          	li	a1,215
ffffffffc0200cbc:	00001517          	auipc	a0,0x1
ffffffffc0200cc0:	59450513          	addi	a0,a0,1428 # ffffffffc0202250 <commands+0x650>
ffffffffc0200cc4:	ee8ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == 0);
ffffffffc0200cc8:	00002697          	auipc	a3,0x2
ffffffffc0200ccc:	85868693          	addi	a3,a3,-1960 # ffffffffc0202520 <commands+0x920>
ffffffffc0200cd0:	00001617          	auipc	a2,0x1
ffffffffc0200cd4:	56860613          	addi	a2,a2,1384 # ffffffffc0202238 <commands+0x638>
ffffffffc0200cd8:	14f00593          	li	a1,335
ffffffffc0200cdc:	00001517          	auipc	a0,0x1
ffffffffc0200ce0:	57450513          	addi	a0,a0,1396 # ffffffffc0202250 <commands+0x650>
ffffffffc0200ce4:	ec8ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == nr_free_pages());
ffffffffc0200ce8:	00001697          	auipc	a3,0x1
ffffffffc0200cec:	59868693          	addi	a3,a3,1432 # ffffffffc0202280 <commands+0x680>
ffffffffc0200cf0:	00001617          	auipc	a2,0x1
ffffffffc0200cf4:	54860613          	addi	a2,a2,1352 # ffffffffc0202238 <commands+0x638>
ffffffffc0200cf8:	11000593          	li	a1,272
ffffffffc0200cfc:	00001517          	auipc	a0,0x1
ffffffffc0200d00:	55450513          	addi	a0,a0,1364 # ffffffffc0202250 <commands+0x650>
ffffffffc0200d04:	ea8ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d08:	00001697          	auipc	a3,0x1
ffffffffc0200d0c:	5b868693          	addi	a3,a3,1464 # ffffffffc02022c0 <commands+0x6c0>
ffffffffc0200d10:	00001617          	auipc	a2,0x1
ffffffffc0200d14:	52860613          	addi	a2,a2,1320 # ffffffffc0202238 <commands+0x638>
ffffffffc0200d18:	0d600593          	li	a1,214
ffffffffc0200d1c:	00001517          	auipc	a0,0x1
ffffffffc0200d20:	53450513          	addi	a0,a0,1332 # ffffffffc0202250 <commands+0x650>
ffffffffc0200d24:	e88ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200d28:	00001697          	auipc	a3,0x1
ffffffffc0200d2c:	57868693          	addi	a3,a3,1400 # ffffffffc02022a0 <commands+0x6a0>
ffffffffc0200d30:	00001617          	auipc	a2,0x1
ffffffffc0200d34:	50860613          	addi	a2,a2,1288 # ffffffffc0202238 <commands+0x638>
ffffffffc0200d38:	0d500593          	li	a1,213
ffffffffc0200d3c:	00001517          	auipc	a0,0x1
ffffffffc0200d40:	51450513          	addi	a0,a0,1300 # ffffffffc0202250 <commands+0x650>
ffffffffc0200d44:	e68ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200d48:	00001697          	auipc	a3,0x1
ffffffffc0200d4c:	68068693          	addi	a3,a3,1664 # ffffffffc02023c8 <commands+0x7c8>
ffffffffc0200d50:	00001617          	auipc	a2,0x1
ffffffffc0200d54:	4e860613          	addi	a2,a2,1256 # ffffffffc0202238 <commands+0x638>
ffffffffc0200d58:	0f200593          	li	a1,242
ffffffffc0200d5c:	00001517          	auipc	a0,0x1
ffffffffc0200d60:	4f450513          	addi	a0,a0,1268 # ffffffffc0202250 <commands+0x650>
ffffffffc0200d64:	e48ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200d68:	00001697          	auipc	a3,0x1
ffffffffc0200d6c:	57868693          	addi	a3,a3,1400 # ffffffffc02022e0 <commands+0x6e0>
ffffffffc0200d70:	00001617          	auipc	a2,0x1
ffffffffc0200d74:	4c860613          	addi	a2,a2,1224 # ffffffffc0202238 <commands+0x638>
ffffffffc0200d78:	0f000593          	li	a1,240
ffffffffc0200d7c:	00001517          	auipc	a0,0x1
ffffffffc0200d80:	4d450513          	addi	a0,a0,1236 # ffffffffc0202250 <commands+0x650>
ffffffffc0200d84:	e28ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d88:	00001697          	auipc	a3,0x1
ffffffffc0200d8c:	53868693          	addi	a3,a3,1336 # ffffffffc02022c0 <commands+0x6c0>
ffffffffc0200d90:	00001617          	auipc	a2,0x1
ffffffffc0200d94:	4a860613          	addi	a2,a2,1192 # ffffffffc0202238 <commands+0x638>
ffffffffc0200d98:	0ef00593          	li	a1,239
ffffffffc0200d9c:	00001517          	auipc	a0,0x1
ffffffffc0200da0:	4b450513          	addi	a0,a0,1204 # ffffffffc0202250 <commands+0x650>
ffffffffc0200da4:	e08ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200da8:	00001697          	auipc	a3,0x1
ffffffffc0200dac:	4f868693          	addi	a3,a3,1272 # ffffffffc02022a0 <commands+0x6a0>
ffffffffc0200db0:	00001617          	auipc	a2,0x1
ffffffffc0200db4:	48860613          	addi	a2,a2,1160 # ffffffffc0202238 <commands+0x638>
ffffffffc0200db8:	0ee00593          	li	a1,238
ffffffffc0200dbc:	00001517          	auipc	a0,0x1
ffffffffc0200dc0:	49450513          	addi	a0,a0,1172 # ffffffffc0202250 <commands+0x650>
ffffffffc0200dc4:	de8ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 3);
ffffffffc0200dc8:	00001697          	auipc	a3,0x1
ffffffffc0200dcc:	61868693          	addi	a3,a3,1560 # ffffffffc02023e0 <commands+0x7e0>
ffffffffc0200dd0:	00001617          	auipc	a2,0x1
ffffffffc0200dd4:	46860613          	addi	a2,a2,1128 # ffffffffc0202238 <commands+0x638>
ffffffffc0200dd8:	0ec00593          	li	a1,236
ffffffffc0200ddc:	00001517          	auipc	a0,0x1
ffffffffc0200de0:	47450513          	addi	a0,a0,1140 # ffffffffc0202250 <commands+0x650>
ffffffffc0200de4:	dc8ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200de8:	00001697          	auipc	a3,0x1
ffffffffc0200dec:	5e068693          	addi	a3,a3,1504 # ffffffffc02023c8 <commands+0x7c8>
ffffffffc0200df0:	00001617          	auipc	a2,0x1
ffffffffc0200df4:	44860613          	addi	a2,a2,1096 # ffffffffc0202238 <commands+0x638>
ffffffffc0200df8:	0e700593          	li	a1,231
ffffffffc0200dfc:	00001517          	auipc	a0,0x1
ffffffffc0200e00:	45450513          	addi	a0,a0,1108 # ffffffffc0202250 <commands+0x650>
ffffffffc0200e04:	da8ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200e08:	00001697          	auipc	a3,0x1
ffffffffc0200e0c:	5a068693          	addi	a3,a3,1440 # ffffffffc02023a8 <commands+0x7a8>
ffffffffc0200e10:	00001617          	auipc	a2,0x1
ffffffffc0200e14:	42860613          	addi	a2,a2,1064 # ffffffffc0202238 <commands+0x638>
ffffffffc0200e18:	0de00593          	li	a1,222
ffffffffc0200e1c:	00001517          	auipc	a0,0x1
ffffffffc0200e20:	43450513          	addi	a0,a0,1076 # ffffffffc0202250 <commands+0x650>
ffffffffc0200e24:	d88ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200e28:	00001697          	auipc	a3,0x1
ffffffffc0200e2c:	56068693          	addi	a3,a3,1376 # ffffffffc0202388 <commands+0x788>
ffffffffc0200e30:	00001617          	auipc	a2,0x1
ffffffffc0200e34:	40860613          	addi	a2,a2,1032 # ffffffffc0202238 <commands+0x638>
ffffffffc0200e38:	0dd00593          	li	a1,221
ffffffffc0200e3c:	00001517          	auipc	a0,0x1
ffffffffc0200e40:	41450513          	addi	a0,a0,1044 # ffffffffc0202250 <commands+0x650>
ffffffffc0200e44:	d68ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(count == 0);
ffffffffc0200e48:	00001697          	auipc	a3,0x1
ffffffffc0200e4c:	6c868693          	addi	a3,a3,1736 # ffffffffc0202510 <commands+0x910>
ffffffffc0200e50:	00001617          	auipc	a2,0x1
ffffffffc0200e54:	3e860613          	addi	a2,a2,1000 # ffffffffc0202238 <commands+0x638>
ffffffffc0200e58:	14e00593          	li	a1,334
ffffffffc0200e5c:	00001517          	auipc	a0,0x1
ffffffffc0200e60:	3f450513          	addi	a0,a0,1012 # ffffffffc0202250 <commands+0x650>
ffffffffc0200e64:	d48ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200e68:	00001697          	auipc	a3,0x1
ffffffffc0200e6c:	5c068693          	addi	a3,a3,1472 # ffffffffc0202428 <commands+0x828>
ffffffffc0200e70:	00001617          	auipc	a2,0x1
ffffffffc0200e74:	3c860613          	addi	a2,a2,968 # ffffffffc0202238 <commands+0x638>
ffffffffc0200e78:	14300593          	li	a1,323
ffffffffc0200e7c:	00001517          	auipc	a0,0x1
ffffffffc0200e80:	3d450513          	addi	a0,a0,980 # ffffffffc0202250 <commands+0x650>
ffffffffc0200e84:	d28ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200e88:	00001697          	auipc	a3,0x1
ffffffffc0200e8c:	54068693          	addi	a3,a3,1344 # ffffffffc02023c8 <commands+0x7c8>
ffffffffc0200e90:	00001617          	auipc	a2,0x1
ffffffffc0200e94:	3a860613          	addi	a2,a2,936 # ffffffffc0202238 <commands+0x638>
ffffffffc0200e98:	13d00593          	li	a1,317
ffffffffc0200e9c:	00001517          	auipc	a0,0x1
ffffffffc0200ea0:	3b450513          	addi	a0,a0,948 # ffffffffc0202250 <commands+0x650>
ffffffffc0200ea4:	d08ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200ea8:	00001697          	auipc	a3,0x1
ffffffffc0200eac:	64868693          	addi	a3,a3,1608 # ffffffffc02024f0 <commands+0x8f0>
ffffffffc0200eb0:	00001617          	auipc	a2,0x1
ffffffffc0200eb4:	38860613          	addi	a2,a2,904 # ffffffffc0202238 <commands+0x638>
ffffffffc0200eb8:	13c00593          	li	a1,316
ffffffffc0200ebc:	00001517          	auipc	a0,0x1
ffffffffc0200ec0:	39450513          	addi	a0,a0,916 # ffffffffc0202250 <commands+0x650>
ffffffffc0200ec4:	ce8ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 + 4 == p1);
ffffffffc0200ec8:	00001697          	auipc	a3,0x1
ffffffffc0200ecc:	61868693          	addi	a3,a3,1560 # ffffffffc02024e0 <commands+0x8e0>
ffffffffc0200ed0:	00001617          	auipc	a2,0x1
ffffffffc0200ed4:	36860613          	addi	a2,a2,872 # ffffffffc0202238 <commands+0x638>
ffffffffc0200ed8:	13400593          	li	a1,308
ffffffffc0200edc:	00001517          	auipc	a0,0x1
ffffffffc0200ee0:	37450513          	addi	a0,a0,884 # ffffffffc0202250 <commands+0x650>
ffffffffc0200ee4:	cc8ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200ee8:	00001697          	auipc	a3,0x1
ffffffffc0200eec:	5e068693          	addi	a3,a3,1504 # ffffffffc02024c8 <commands+0x8c8>
ffffffffc0200ef0:	00001617          	auipc	a2,0x1
ffffffffc0200ef4:	34860613          	addi	a2,a2,840 # ffffffffc0202238 <commands+0x638>
ffffffffc0200ef8:	13300593          	li	a1,307
ffffffffc0200efc:	00001517          	auipc	a0,0x1
ffffffffc0200f00:	35450513          	addi	a0,a0,852 # ffffffffc0202250 <commands+0x650>
ffffffffc0200f04:	ca8ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200f08:	00001697          	auipc	a3,0x1
ffffffffc0200f0c:	5a068693          	addi	a3,a3,1440 # ffffffffc02024a8 <commands+0x8a8>
ffffffffc0200f10:	00001617          	auipc	a2,0x1
ffffffffc0200f14:	32860613          	addi	a2,a2,808 # ffffffffc0202238 <commands+0x638>
ffffffffc0200f18:	13200593          	li	a1,306
ffffffffc0200f1c:	00001517          	auipc	a0,0x1
ffffffffc0200f20:	33450513          	addi	a0,a0,820 # ffffffffc0202250 <commands+0x650>
ffffffffc0200f24:	c88ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200f28:	00001697          	auipc	a3,0x1
ffffffffc0200f2c:	55068693          	addi	a3,a3,1360 # ffffffffc0202478 <commands+0x878>
ffffffffc0200f30:	00001617          	auipc	a2,0x1
ffffffffc0200f34:	30860613          	addi	a2,a2,776 # ffffffffc0202238 <commands+0x638>
ffffffffc0200f38:	13000593          	li	a1,304
ffffffffc0200f3c:	00001517          	auipc	a0,0x1
ffffffffc0200f40:	31450513          	addi	a0,a0,788 # ffffffffc0202250 <commands+0x650>
ffffffffc0200f44:	c68ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0200f48:	00001697          	auipc	a3,0x1
ffffffffc0200f4c:	51868693          	addi	a3,a3,1304 # ffffffffc0202460 <commands+0x860>
ffffffffc0200f50:	00001617          	auipc	a2,0x1
ffffffffc0200f54:	2e860613          	addi	a2,a2,744 # ffffffffc0202238 <commands+0x638>
ffffffffc0200f58:	12f00593          	li	a1,303
ffffffffc0200f5c:	00001517          	auipc	a0,0x1
ffffffffc0200f60:	2f450513          	addi	a0,a0,756 # ffffffffc0202250 <commands+0x650>
ffffffffc0200f64:	c48ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f68:	00001697          	auipc	a3,0x1
ffffffffc0200f6c:	46068693          	addi	a3,a3,1120 # ffffffffc02023c8 <commands+0x7c8>
ffffffffc0200f70:	00001617          	auipc	a2,0x1
ffffffffc0200f74:	2c860613          	addi	a2,a2,712 # ffffffffc0202238 <commands+0x638>
ffffffffc0200f78:	12300593          	li	a1,291
ffffffffc0200f7c:	00001517          	auipc	a0,0x1
ffffffffc0200f80:	2d450513          	addi	a0,a0,724 # ffffffffc0202250 <commands+0x650>
ffffffffc0200f84:	c28ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!PageProperty(p0));
ffffffffc0200f88:	00001697          	auipc	a3,0x1
ffffffffc0200f8c:	4c068693          	addi	a3,a3,1216 # ffffffffc0202448 <commands+0x848>
ffffffffc0200f90:	00001617          	auipc	a2,0x1
ffffffffc0200f94:	2a860613          	addi	a2,a2,680 # ffffffffc0202238 <commands+0x638>
ffffffffc0200f98:	11a00593          	li	a1,282
ffffffffc0200f9c:	00001517          	auipc	a0,0x1
ffffffffc0200fa0:	2b450513          	addi	a0,a0,692 # ffffffffc0202250 <commands+0x650>
ffffffffc0200fa4:	c08ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != NULL);
ffffffffc0200fa8:	00001697          	auipc	a3,0x1
ffffffffc0200fac:	49068693          	addi	a3,a3,1168 # ffffffffc0202438 <commands+0x838>
ffffffffc0200fb0:	00001617          	auipc	a2,0x1
ffffffffc0200fb4:	28860613          	addi	a2,a2,648 # ffffffffc0202238 <commands+0x638>
ffffffffc0200fb8:	11900593          	li	a1,281
ffffffffc0200fbc:	00001517          	auipc	a0,0x1
ffffffffc0200fc0:	29450513          	addi	a0,a0,660 # ffffffffc0202250 <commands+0x650>
ffffffffc0200fc4:	be8ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200fc8:	00001697          	auipc	a3,0x1
ffffffffc0200fcc:	46068693          	addi	a3,a3,1120 # ffffffffc0202428 <commands+0x828>
ffffffffc0200fd0:	00001617          	auipc	a2,0x1
ffffffffc0200fd4:	26860613          	addi	a2,a2,616 # ffffffffc0202238 <commands+0x638>
ffffffffc0200fd8:	0fb00593          	li	a1,251
ffffffffc0200fdc:	00001517          	auipc	a0,0x1
ffffffffc0200fe0:	27450513          	addi	a0,a0,628 # ffffffffc0202250 <commands+0x650>
ffffffffc0200fe4:	bc8ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fe8:	00001697          	auipc	a3,0x1
ffffffffc0200fec:	3e068693          	addi	a3,a3,992 # ffffffffc02023c8 <commands+0x7c8>
ffffffffc0200ff0:	00001617          	auipc	a2,0x1
ffffffffc0200ff4:	24860613          	addi	a2,a2,584 # ffffffffc0202238 <commands+0x638>
ffffffffc0200ff8:	0f900593          	li	a1,249
ffffffffc0200ffc:	00001517          	auipc	a0,0x1
ffffffffc0201000:	25450513          	addi	a0,a0,596 # ffffffffc0202250 <commands+0x650>
ffffffffc0201004:	ba8ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201008:	00001697          	auipc	a3,0x1
ffffffffc020100c:	40068693          	addi	a3,a3,1024 # ffffffffc0202408 <commands+0x808>
ffffffffc0201010:	00001617          	auipc	a2,0x1
ffffffffc0201014:	22860613          	addi	a2,a2,552 # ffffffffc0202238 <commands+0x638>
ffffffffc0201018:	0f800593          	li	a1,248
ffffffffc020101c:	00001517          	auipc	a0,0x1
ffffffffc0201020:	23450513          	addi	a0,a0,564 # ffffffffc0202250 <commands+0x650>
ffffffffc0201024:	b88ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201028 <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc0201028:	1141                	addi	sp,sp,-16
ffffffffc020102a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020102c:	18058063          	beqz	a1,ffffffffc02011ac <best_fit_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc0201030:	00259693          	slli	a3,a1,0x2
ffffffffc0201034:	96ae                	add	a3,a3,a1
ffffffffc0201036:	068e                	slli	a3,a3,0x3
ffffffffc0201038:	96aa                	add	a3,a3,a0
ffffffffc020103a:	02d50d63          	beq	a0,a3,ffffffffc0201074 <best_fit_free_pages+0x4c>
ffffffffc020103e:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201040:	8b85                	andi	a5,a5,1
ffffffffc0201042:	14079563          	bnez	a5,ffffffffc020118c <best_fit_free_pages+0x164>
ffffffffc0201046:	651c                	ld	a5,8(a0)
ffffffffc0201048:	8385                	srli	a5,a5,0x1
ffffffffc020104a:	8b85                	andi	a5,a5,1
ffffffffc020104c:	14079063          	bnez	a5,ffffffffc020118c <best_fit_free_pages+0x164>
ffffffffc0201050:	87aa                	mv	a5,a0
ffffffffc0201052:	a809                	j	ffffffffc0201064 <best_fit_free_pages+0x3c>
ffffffffc0201054:	6798                	ld	a4,8(a5)
ffffffffc0201056:	8b05                	andi	a4,a4,1
ffffffffc0201058:	12071a63          	bnez	a4,ffffffffc020118c <best_fit_free_pages+0x164>
ffffffffc020105c:	6798                	ld	a4,8(a5)
ffffffffc020105e:	8b09                	andi	a4,a4,2
ffffffffc0201060:	12071663          	bnez	a4,ffffffffc020118c <best_fit_free_pages+0x164>
        p->flags = 0;
ffffffffc0201064:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201068:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020106c:	02878793          	addi	a5,a5,40
ffffffffc0201070:	fed792e3          	bne	a5,a3,ffffffffc0201054 <best_fit_free_pages+0x2c>
    base->property = n;
ffffffffc0201074:	2581                	sext.w	a1,a1
ffffffffc0201076:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0201078:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020107c:	4789                	li	a5,2
ffffffffc020107e:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201082:	00005697          	auipc	a3,0x5
ffffffffc0201086:	3b668693          	addi	a3,a3,950 # ffffffffc0206438 <free_area>
ffffffffc020108a:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020108c:	669c                	ld	a5,8(a3)
ffffffffc020108e:	9db9                	addw	a1,a1,a4
ffffffffc0201090:	00005717          	auipc	a4,0x5
ffffffffc0201094:	3ab72c23          	sw	a1,952(a4) # ffffffffc0206448 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201098:	08d78f63          	beq	a5,a3,ffffffffc0201136 <best_fit_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc020109c:	fe878713          	addi	a4,a5,-24
ffffffffc02010a0:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02010a2:	4801                	li	a6,0
ffffffffc02010a4:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02010a8:	00e56a63          	bltu	a0,a4,ffffffffc02010bc <best_fit_free_pages+0x94>
    return listelm->next;
ffffffffc02010ac:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02010ae:	02d70563          	beq	a4,a3,ffffffffc02010d8 <best_fit_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02010b2:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02010b4:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02010b8:	fee57ae3          	bleu	a4,a0,ffffffffc02010ac <best_fit_free_pages+0x84>
ffffffffc02010bc:	00080663          	beqz	a6,ffffffffc02010c8 <best_fit_free_pages+0xa0>
ffffffffc02010c0:	00005817          	auipc	a6,0x5
ffffffffc02010c4:	36b83c23          	sd	a1,888(a6) # ffffffffc0206438 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02010c8:	638c                	ld	a1,0(a5)
    prev->next = next->prev = elm;
ffffffffc02010ca:	e390                	sd	a2,0(a5)
ffffffffc02010cc:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc02010ce:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02010d0:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc02010d2:	02d59163          	bne	a1,a3,ffffffffc02010f4 <best_fit_free_pages+0xcc>
ffffffffc02010d6:	a091                	j	ffffffffc020111a <best_fit_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc02010d8:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02010da:	f114                	sd	a3,32(a0)
ffffffffc02010dc:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02010de:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc02010e0:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02010e2:	00d70563          	beq	a4,a3,ffffffffc02010ec <best_fit_free_pages+0xc4>
ffffffffc02010e6:	4805                	li	a6,1
ffffffffc02010e8:	87ba                	mv	a5,a4
ffffffffc02010ea:	b7e9                	j	ffffffffc02010b4 <best_fit_free_pages+0x8c>
ffffffffc02010ec:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc02010ee:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc02010f0:	02d78163          	beq	a5,a3,ffffffffc0201112 <best_fit_free_pages+0xea>
        if(p + p->property == base){
ffffffffc02010f4:	ff85a803          	lw	a6,-8(a1)
        p = le2page(le, page_link);
ffffffffc02010f8:	fe858613          	addi	a2,a1,-24
        if(p + p->property == base){
ffffffffc02010fc:	02081713          	slli	a4,a6,0x20
ffffffffc0201100:	9301                	srli	a4,a4,0x20
ffffffffc0201102:	00271793          	slli	a5,a4,0x2
ffffffffc0201106:	97ba                	add	a5,a5,a4
ffffffffc0201108:	078e                	slli	a5,a5,0x3
ffffffffc020110a:	97b2                	add	a5,a5,a2
ffffffffc020110c:	02f50e63          	beq	a0,a5,ffffffffc0201148 <best_fit_free_pages+0x120>
ffffffffc0201110:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201112:	fe878713          	addi	a4,a5,-24
ffffffffc0201116:	00d78d63          	beq	a5,a3,ffffffffc0201130 <best_fit_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc020111a:	490c                	lw	a1,16(a0)
ffffffffc020111c:	02059613          	slli	a2,a1,0x20
ffffffffc0201120:	9201                	srli	a2,a2,0x20
ffffffffc0201122:	00261693          	slli	a3,a2,0x2
ffffffffc0201126:	96b2                	add	a3,a3,a2
ffffffffc0201128:	068e                	slli	a3,a3,0x3
ffffffffc020112a:	96aa                	add	a3,a3,a0
ffffffffc020112c:	04d70063          	beq	a4,a3,ffffffffc020116c <best_fit_free_pages+0x144>
}
ffffffffc0201130:	60a2                	ld	ra,8(sp)
ffffffffc0201132:	0141                	addi	sp,sp,16
ffffffffc0201134:	8082                	ret
ffffffffc0201136:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201138:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc020113c:	e398                	sd	a4,0(a5)
ffffffffc020113e:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201140:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201142:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201144:	0141                	addi	sp,sp,16
ffffffffc0201146:	8082                	ret
            p->property += base->property;
ffffffffc0201148:	491c                	lw	a5,16(a0)
ffffffffc020114a:	0107883b          	addw	a6,a5,a6
ffffffffc020114e:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201152:	57f5                	li	a5,-3
ffffffffc0201154:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201158:	01853803          	ld	a6,24(a0)
ffffffffc020115c:	7118                	ld	a4,32(a0)
            base = p;
ffffffffc020115e:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc0201160:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc0201164:	659c                	ld	a5,8(a1)
ffffffffc0201166:	01073023          	sd	a6,0(a4)
ffffffffc020116a:	b765                	j	ffffffffc0201112 <best_fit_free_pages+0xea>
            base->property += p->property;
ffffffffc020116c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201170:	ff078693          	addi	a3,a5,-16
ffffffffc0201174:	9db9                	addw	a1,a1,a4
ffffffffc0201176:	c90c                	sw	a1,16(a0)
ffffffffc0201178:	5775                	li	a4,-3
ffffffffc020117a:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020117e:	6398                	ld	a4,0(a5)
ffffffffc0201180:	679c                	ld	a5,8(a5)
}
ffffffffc0201182:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201184:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201186:	e398                	sd	a4,0(a5)
ffffffffc0201188:	0141                	addi	sp,sp,16
ffffffffc020118a:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020118c:	00001697          	auipc	a3,0x1
ffffffffc0201190:	3a468693          	addi	a3,a3,932 # ffffffffc0202530 <commands+0x930>
ffffffffc0201194:	00001617          	auipc	a2,0x1
ffffffffc0201198:	0a460613          	addi	a2,a2,164 # ffffffffc0202238 <commands+0x638>
ffffffffc020119c:	09500593          	li	a1,149
ffffffffc02011a0:	00001517          	auipc	a0,0x1
ffffffffc02011a4:	0b050513          	addi	a0,a0,176 # ffffffffc0202250 <commands+0x650>
ffffffffc02011a8:	a04ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc02011ac:	00001697          	auipc	a3,0x1
ffffffffc02011b0:	08468693          	addi	a3,a3,132 # ffffffffc0202230 <commands+0x630>
ffffffffc02011b4:	00001617          	auipc	a2,0x1
ffffffffc02011b8:	08460613          	addi	a2,a2,132 # ffffffffc0202238 <commands+0x638>
ffffffffc02011bc:	09200593          	li	a1,146
ffffffffc02011c0:	00001517          	auipc	a0,0x1
ffffffffc02011c4:	09050513          	addi	a0,a0,144 # ffffffffc0202250 <commands+0x650>
ffffffffc02011c8:	9e4ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02011cc <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc02011cc:	1141                	addi	sp,sp,-16
ffffffffc02011ce:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02011d0:	c1fd                	beqz	a1,ffffffffc02012b6 <best_fit_init_memmap+0xea>
    for (; p != base + n; p ++) {
ffffffffc02011d2:	00259693          	slli	a3,a1,0x2
ffffffffc02011d6:	96ae                	add	a3,a3,a1
ffffffffc02011d8:	068e                	slli	a3,a3,0x3
ffffffffc02011da:	96aa                	add	a3,a3,a0
ffffffffc02011dc:	02d50463          	beq	a0,a3,ffffffffc0201204 <best_fit_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02011e0:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc02011e2:	87aa                	mv	a5,a0
ffffffffc02011e4:	8b05                	andi	a4,a4,1
ffffffffc02011e6:	e709                	bnez	a4,ffffffffc02011f0 <best_fit_init_memmap+0x24>
ffffffffc02011e8:	a07d                	j	ffffffffc0201296 <best_fit_init_memmap+0xca>
ffffffffc02011ea:	6798                	ld	a4,8(a5)
ffffffffc02011ec:	8b05                	andi	a4,a4,1
ffffffffc02011ee:	c745                	beqz	a4,ffffffffc0201296 <best_fit_init_memmap+0xca>
        p->flags = p->property = 0;
ffffffffc02011f0:	0007a823          	sw	zero,16(a5)
ffffffffc02011f4:	0007b423          	sd	zero,8(a5)
ffffffffc02011f8:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02011fc:	02878793          	addi	a5,a5,40
ffffffffc0201200:	fed795e3          	bne	a5,a3,ffffffffc02011ea <best_fit_init_memmap+0x1e>
    base->property = n;
ffffffffc0201204:	2581                	sext.w	a1,a1
ffffffffc0201206:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201208:	4789                	li	a5,2
ffffffffc020120a:	00850713          	addi	a4,a0,8
ffffffffc020120e:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201212:	00005697          	auipc	a3,0x5
ffffffffc0201216:	22668693          	addi	a3,a3,550 # ffffffffc0206438 <free_area>
ffffffffc020121a:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020121c:	669c                	ld	a5,8(a3)
ffffffffc020121e:	9db9                	addw	a1,a1,a4
ffffffffc0201220:	00005717          	auipc	a4,0x5
ffffffffc0201224:	22b72423          	sw	a1,552(a4) # ffffffffc0206448 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201228:	04d78a63          	beq	a5,a3,ffffffffc020127c <best_fit_init_memmap+0xb0>
            struct Page* page = le2page(le, page_link);
ffffffffc020122c:	fe878713          	addi	a4,a5,-24
ffffffffc0201230:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201232:	4801                	li	a6,0
ffffffffc0201234:	01850613          	addi	a2,a0,24
            if (base < page) 
ffffffffc0201238:	00e56a63          	bltu	a0,a4,ffffffffc020124c <best_fit_init_memmap+0x80>
    return listelm->next;
ffffffffc020123c:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc020123e:	02d70563          	beq	a4,a3,ffffffffc0201268 <best_fit_init_memmap+0x9c>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201242:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201244:	fe878713          	addi	a4,a5,-24
            if (base < page) 
ffffffffc0201248:	fee57ae3          	bleu	a4,a0,ffffffffc020123c <best_fit_init_memmap+0x70>
ffffffffc020124c:	00080663          	beqz	a6,ffffffffc0201258 <best_fit_init_memmap+0x8c>
ffffffffc0201250:	00005717          	auipc	a4,0x5
ffffffffc0201254:	1eb73423          	sd	a1,488(a4) # ffffffffc0206438 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201258:	6398                	ld	a4,0(a5)
}
ffffffffc020125a:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020125c:	e390                	sd	a2,0(a5)
ffffffffc020125e:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201260:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201262:	ed18                	sd	a4,24(a0)
ffffffffc0201264:	0141                	addi	sp,sp,16
ffffffffc0201266:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201268:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020126a:	f114                	sd	a3,32(a0)
ffffffffc020126c:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020126e:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201270:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201272:	00d70e63          	beq	a4,a3,ffffffffc020128e <best_fit_init_memmap+0xc2>
ffffffffc0201276:	4805                	li	a6,1
ffffffffc0201278:	87ba                	mv	a5,a4
ffffffffc020127a:	b7e9                	j	ffffffffc0201244 <best_fit_init_memmap+0x78>
}
ffffffffc020127c:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020127e:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201282:	e398                	sd	a4,0(a5)
ffffffffc0201284:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201286:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201288:	ed1c                	sd	a5,24(a0)
}
ffffffffc020128a:	0141                	addi	sp,sp,16
ffffffffc020128c:	8082                	ret
ffffffffc020128e:	60a2                	ld	ra,8(sp)
ffffffffc0201290:	e290                	sd	a2,0(a3)
ffffffffc0201292:	0141                	addi	sp,sp,16
ffffffffc0201294:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201296:	00001697          	auipc	a3,0x1
ffffffffc020129a:	2c268693          	addi	a3,a3,706 # ffffffffc0202558 <commands+0x958>
ffffffffc020129e:	00001617          	auipc	a2,0x1
ffffffffc02012a2:	f9a60613          	addi	a2,a2,-102 # ffffffffc0202238 <commands+0x638>
ffffffffc02012a6:	04a00593          	li	a1,74
ffffffffc02012aa:	00001517          	auipc	a0,0x1
ffffffffc02012ae:	fa650513          	addi	a0,a0,-90 # ffffffffc0202250 <commands+0x650>
ffffffffc02012b2:	8faff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc02012b6:	00001697          	auipc	a3,0x1
ffffffffc02012ba:	f7a68693          	addi	a3,a3,-134 # ffffffffc0202230 <commands+0x630>
ffffffffc02012be:	00001617          	auipc	a2,0x1
ffffffffc02012c2:	f7a60613          	addi	a2,a2,-134 # ffffffffc0202238 <commands+0x638>
ffffffffc02012c6:	04700593          	li	a1,71
ffffffffc02012ca:	00001517          	auipc	a0,0x1
ffffffffc02012ce:	f8650513          	addi	a0,a0,-122 # ffffffffc0202250 <commands+0x650>
ffffffffc02012d2:	8daff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02012d6 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02012d6:	100027f3          	csrr	a5,sstatus
ffffffffc02012da:	8b89                	andi	a5,a5,2
ffffffffc02012dc:	eb89                	bnez	a5,ffffffffc02012ee <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc02012de:	00005797          	auipc	a5,0x5
ffffffffc02012e2:	17a78793          	addi	a5,a5,378 # ffffffffc0206458 <pmm_manager>
ffffffffc02012e6:	639c                	ld	a5,0(a5)
ffffffffc02012e8:	0187b303          	ld	t1,24(a5)
ffffffffc02012ec:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc02012ee:	1141                	addi	sp,sp,-16
ffffffffc02012f0:	e406                	sd	ra,8(sp)
ffffffffc02012f2:	e022                	sd	s0,0(sp)
ffffffffc02012f4:	842a                	mv	s0,a0
        intr_disable();
ffffffffc02012f6:	96eff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02012fa:	00005797          	auipc	a5,0x5
ffffffffc02012fe:	15e78793          	addi	a5,a5,350 # ffffffffc0206458 <pmm_manager>
ffffffffc0201302:	639c                	ld	a5,0(a5)
ffffffffc0201304:	8522                	mv	a0,s0
ffffffffc0201306:	6f9c                	ld	a5,24(a5)
ffffffffc0201308:	9782                	jalr	a5
ffffffffc020130a:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc020130c:	952ff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201310:	8522                	mv	a0,s0
ffffffffc0201312:	60a2                	ld	ra,8(sp)
ffffffffc0201314:	6402                	ld	s0,0(sp)
ffffffffc0201316:	0141                	addi	sp,sp,16
ffffffffc0201318:	8082                	ret

ffffffffc020131a <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020131a:	100027f3          	csrr	a5,sstatus
ffffffffc020131e:	8b89                	andi	a5,a5,2
ffffffffc0201320:	eb89                	bnez	a5,ffffffffc0201332 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201322:	00005797          	auipc	a5,0x5
ffffffffc0201326:	13678793          	addi	a5,a5,310 # ffffffffc0206458 <pmm_manager>
ffffffffc020132a:	639c                	ld	a5,0(a5)
ffffffffc020132c:	0207b303          	ld	t1,32(a5)
ffffffffc0201330:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0201332:	1101                	addi	sp,sp,-32
ffffffffc0201334:	ec06                	sd	ra,24(sp)
ffffffffc0201336:	e822                	sd	s0,16(sp)
ffffffffc0201338:	e426                	sd	s1,8(sp)
ffffffffc020133a:	842a                	mv	s0,a0
ffffffffc020133c:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc020133e:	926ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201342:	00005797          	auipc	a5,0x5
ffffffffc0201346:	11678793          	addi	a5,a5,278 # ffffffffc0206458 <pmm_manager>
ffffffffc020134a:	639c                	ld	a5,0(a5)
ffffffffc020134c:	85a6                	mv	a1,s1
ffffffffc020134e:	8522                	mv	a0,s0
ffffffffc0201350:	739c                	ld	a5,32(a5)
ffffffffc0201352:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201354:	6442                	ld	s0,16(sp)
ffffffffc0201356:	60e2                	ld	ra,24(sp)
ffffffffc0201358:	64a2                	ld	s1,8(sp)
ffffffffc020135a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020135c:	902ff06f          	j	ffffffffc020045e <intr_enable>

ffffffffc0201360 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201360:	100027f3          	csrr	a5,sstatus
ffffffffc0201364:	8b89                	andi	a5,a5,2
ffffffffc0201366:	eb89                	bnez	a5,ffffffffc0201378 <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201368:	00005797          	auipc	a5,0x5
ffffffffc020136c:	0f078793          	addi	a5,a5,240 # ffffffffc0206458 <pmm_manager>
ffffffffc0201370:	639c                	ld	a5,0(a5)
ffffffffc0201372:	0287b303          	ld	t1,40(a5)
ffffffffc0201376:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0201378:	1141                	addi	sp,sp,-16
ffffffffc020137a:	e406                	sd	ra,8(sp)
ffffffffc020137c:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc020137e:	8e6ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201382:	00005797          	auipc	a5,0x5
ffffffffc0201386:	0d678793          	addi	a5,a5,214 # ffffffffc0206458 <pmm_manager>
ffffffffc020138a:	639c                	ld	a5,0(a5)
ffffffffc020138c:	779c                	ld	a5,40(a5)
ffffffffc020138e:	9782                	jalr	a5
ffffffffc0201390:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201392:	8ccff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201396:	8522                	mv	a0,s0
ffffffffc0201398:	60a2                	ld	ra,8(sp)
ffffffffc020139a:	6402                	ld	s0,0(sp)
ffffffffc020139c:	0141                	addi	sp,sp,16
ffffffffc020139e:	8082                	ret

ffffffffc02013a0 <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02013a0:	00001797          	auipc	a5,0x1
ffffffffc02013a4:	1c878793          	addi	a5,a5,456 # ffffffffc0202568 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02013a8:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02013aa:	1101                	addi	sp,sp,-32
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02013ac:	00001517          	auipc	a0,0x1
ffffffffc02013b0:	20c50513          	addi	a0,a0,524 # ffffffffc02025b8 <best_fit_pmm_manager+0x50>
void pmm_init(void) {
ffffffffc02013b4:	ec06                	sd	ra,24(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02013b6:	00005717          	auipc	a4,0x5
ffffffffc02013ba:	0af73123          	sd	a5,162(a4) # ffffffffc0206458 <pmm_manager>
void pmm_init(void) {
ffffffffc02013be:	e822                	sd	s0,16(sp)
ffffffffc02013c0:	e426                	sd	s1,8(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02013c2:	00005417          	auipc	s0,0x5
ffffffffc02013c6:	09640413          	addi	s0,s0,150 # ffffffffc0206458 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02013ca:	cedfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc02013ce:	601c                	ld	a5,0(s0)
ffffffffc02013d0:	679c                	ld	a5,8(a5)
ffffffffc02013d2:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02013d4:	57f5                	li	a5,-3
ffffffffc02013d6:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02013d8:	00001517          	auipc	a0,0x1
ffffffffc02013dc:	1f850513          	addi	a0,a0,504 # ffffffffc02025d0 <best_fit_pmm_manager+0x68>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02013e0:	00005717          	auipc	a4,0x5
ffffffffc02013e4:	08f73023          	sd	a5,128(a4) # ffffffffc0206460 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc02013e8:	ccffe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc02013ec:	46c5                	li	a3,17
ffffffffc02013ee:	06ee                	slli	a3,a3,0x1b
ffffffffc02013f0:	40100613          	li	a2,1025
ffffffffc02013f4:	16fd                	addi	a3,a3,-1
ffffffffc02013f6:	0656                	slli	a2,a2,0x15
ffffffffc02013f8:	07e005b7          	lui	a1,0x7e00
ffffffffc02013fc:	00001517          	auipc	a0,0x1
ffffffffc0201400:	1ec50513          	addi	a0,a0,492 # ffffffffc02025e8 <best_fit_pmm_manager+0x80>
ffffffffc0201404:	cb3fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201408:	777d                	lui	a4,0xfffff
ffffffffc020140a:	00006797          	auipc	a5,0x6
ffffffffc020140e:	06578793          	addi	a5,a5,101 # ffffffffc020746f <end+0xfff>
ffffffffc0201412:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201414:	00088737          	lui	a4,0x88
ffffffffc0201418:	00005697          	auipc	a3,0x5
ffffffffc020141c:	00e6b023          	sd	a4,0(a3) # ffffffffc0206418 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201420:	4601                	li	a2,0
ffffffffc0201422:	00005717          	auipc	a4,0x5
ffffffffc0201426:	04f73323          	sd	a5,70(a4) # ffffffffc0206468 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020142a:	4681                	li	a3,0
ffffffffc020142c:	00005897          	auipc	a7,0x5
ffffffffc0201430:	fec88893          	addi	a7,a7,-20 # ffffffffc0206418 <npage>
ffffffffc0201434:	00005597          	auipc	a1,0x5
ffffffffc0201438:	03458593          	addi	a1,a1,52 # ffffffffc0206468 <pages>
ffffffffc020143c:	4805                	li	a6,1
ffffffffc020143e:	fff80537          	lui	a0,0xfff80
ffffffffc0201442:	a011                	j	ffffffffc0201446 <pmm_init+0xa6>
ffffffffc0201444:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc0201446:	97b2                	add	a5,a5,a2
ffffffffc0201448:	07a1                	addi	a5,a5,8
ffffffffc020144a:	4107b02f          	amoor.d	zero,a6,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020144e:	0008b703          	ld	a4,0(a7)
ffffffffc0201452:	0685                	addi	a3,a3,1
ffffffffc0201454:	02860613          	addi	a2,a2,40
ffffffffc0201458:	00a707b3          	add	a5,a4,a0
ffffffffc020145c:	fef6e4e3          	bltu	a3,a5,ffffffffc0201444 <pmm_init+0xa4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201460:	6190                	ld	a2,0(a1)
ffffffffc0201462:	00271793          	slli	a5,a4,0x2
ffffffffc0201466:	97ba                	add	a5,a5,a4
ffffffffc0201468:	fec006b7          	lui	a3,0xfec00
ffffffffc020146c:	078e                	slli	a5,a5,0x3
ffffffffc020146e:	96b2                	add	a3,a3,a2
ffffffffc0201470:	96be                	add	a3,a3,a5
ffffffffc0201472:	c02007b7          	lui	a5,0xc0200
ffffffffc0201476:	08f6e863          	bltu	a3,a5,ffffffffc0201506 <pmm_init+0x166>
ffffffffc020147a:	00005497          	auipc	s1,0x5
ffffffffc020147e:	fe648493          	addi	s1,s1,-26 # ffffffffc0206460 <va_pa_offset>
ffffffffc0201482:	609c                	ld	a5,0(s1)
    if (freemem < mem_end) {
ffffffffc0201484:	45c5                	li	a1,17
ffffffffc0201486:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201488:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc020148a:	04b6e963          	bltu	a3,a1,ffffffffc02014dc <pmm_init+0x13c>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020148e:	601c                	ld	a5,0(s0)
ffffffffc0201490:	7b9c                	ld	a5,48(a5)
ffffffffc0201492:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201494:	00001517          	auipc	a0,0x1
ffffffffc0201498:	1ec50513          	addi	a0,a0,492 # ffffffffc0202680 <best_fit_pmm_manager+0x118>
ffffffffc020149c:	c1bfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02014a0:	00004697          	auipc	a3,0x4
ffffffffc02014a4:	b6068693          	addi	a3,a3,-1184 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02014a8:	00005797          	auipc	a5,0x5
ffffffffc02014ac:	f6d7bc23          	sd	a3,-136(a5) # ffffffffc0206420 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02014b0:	c02007b7          	lui	a5,0xc0200
ffffffffc02014b4:	06f6e563          	bltu	a3,a5,ffffffffc020151e <pmm_init+0x17e>
ffffffffc02014b8:	609c                	ld	a5,0(s1)
}
ffffffffc02014ba:	6442                	ld	s0,16(sp)
ffffffffc02014bc:	60e2                	ld	ra,24(sp)
ffffffffc02014be:	64a2                	ld	s1,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02014c0:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc02014c2:	8e9d                	sub	a3,a3,a5
ffffffffc02014c4:	00005797          	auipc	a5,0x5
ffffffffc02014c8:	f8d7b623          	sd	a3,-116(a5) # ffffffffc0206450 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02014cc:	00001517          	auipc	a0,0x1
ffffffffc02014d0:	1d450513          	addi	a0,a0,468 # ffffffffc02026a0 <best_fit_pmm_manager+0x138>
ffffffffc02014d4:	8636                	mv	a2,a3
}
ffffffffc02014d6:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02014d8:	bdffe06f          	j	ffffffffc02000b6 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02014dc:	6785                	lui	a5,0x1
ffffffffc02014de:	17fd                	addi	a5,a5,-1
ffffffffc02014e0:	96be                	add	a3,a3,a5
ffffffffc02014e2:	77fd                	lui	a5,0xfffff
ffffffffc02014e4:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02014e6:	00c6d793          	srli	a5,a3,0xc
ffffffffc02014ea:	04e7f663          	bleu	a4,a5,ffffffffc0201536 <pmm_init+0x196>
    pmm_manager->init_memmap(base, n);
ffffffffc02014ee:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02014f0:	97aa                	add	a5,a5,a0
ffffffffc02014f2:	00279513          	slli	a0,a5,0x2
ffffffffc02014f6:	953e                	add	a0,a0,a5
ffffffffc02014f8:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02014fa:	8d95                	sub	a1,a1,a3
ffffffffc02014fc:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02014fe:	81b1                	srli	a1,a1,0xc
ffffffffc0201500:	9532                	add	a0,a0,a2
ffffffffc0201502:	9782                	jalr	a5
ffffffffc0201504:	b769                	j	ffffffffc020148e <pmm_init+0xee>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201506:	00001617          	auipc	a2,0x1
ffffffffc020150a:	11260613          	addi	a2,a2,274 # ffffffffc0202618 <best_fit_pmm_manager+0xb0>
ffffffffc020150e:	06e00593          	li	a1,110
ffffffffc0201512:	00001517          	auipc	a0,0x1
ffffffffc0201516:	12e50513          	addi	a0,a0,302 # ffffffffc0202640 <best_fit_pmm_manager+0xd8>
ffffffffc020151a:	e93fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc020151e:	00001617          	auipc	a2,0x1
ffffffffc0201522:	0fa60613          	addi	a2,a2,250 # ffffffffc0202618 <best_fit_pmm_manager+0xb0>
ffffffffc0201526:	08900593          	li	a1,137
ffffffffc020152a:	00001517          	auipc	a0,0x1
ffffffffc020152e:	11650513          	addi	a0,a0,278 # ffffffffc0202640 <best_fit_pmm_manager+0xd8>
ffffffffc0201532:	e7bfe0ef          	jal	ra,ffffffffc02003ac <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201536:	00001617          	auipc	a2,0x1
ffffffffc020153a:	11a60613          	addi	a2,a2,282 # ffffffffc0202650 <best_fit_pmm_manager+0xe8>
ffffffffc020153e:	06b00593          	li	a1,107
ffffffffc0201542:	00001517          	auipc	a0,0x1
ffffffffc0201546:	12e50513          	addi	a0,a0,302 # ffffffffc0202670 <best_fit_pmm_manager+0x108>
ffffffffc020154a:	e63fe0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020154e <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020154e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201552:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201554:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201558:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020155a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020155e:	f022                	sd	s0,32(sp)
ffffffffc0201560:	ec26                	sd	s1,24(sp)
ffffffffc0201562:	e84a                	sd	s2,16(sp)
ffffffffc0201564:	f406                	sd	ra,40(sp)
ffffffffc0201566:	e44e                	sd	s3,8(sp)
ffffffffc0201568:	84aa                	mv	s1,a0
ffffffffc020156a:	892e                	mv	s2,a1
ffffffffc020156c:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201570:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0201572:	03067e63          	bleu	a6,a2,ffffffffc02015ae <printnum+0x60>
ffffffffc0201576:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201578:	00805763          	blez	s0,ffffffffc0201586 <printnum+0x38>
ffffffffc020157c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020157e:	85ca                	mv	a1,s2
ffffffffc0201580:	854e                	mv	a0,s3
ffffffffc0201582:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201584:	fc65                	bnez	s0,ffffffffc020157c <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201586:	1a02                	slli	s4,s4,0x20
ffffffffc0201588:	020a5a13          	srli	s4,s4,0x20
ffffffffc020158c:	00001797          	auipc	a5,0x1
ffffffffc0201590:	2e478793          	addi	a5,a5,740 # ffffffffc0202870 <error_string+0x38>
ffffffffc0201594:	9a3e                	add	s4,s4,a5
}
ffffffffc0201596:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201598:	000a4503          	lbu	a0,0(s4)
}
ffffffffc020159c:	70a2                	ld	ra,40(sp)
ffffffffc020159e:	69a2                	ld	s3,8(sp)
ffffffffc02015a0:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02015a2:	85ca                	mv	a1,s2
ffffffffc02015a4:	8326                	mv	t1,s1
}
ffffffffc02015a6:	6942                	ld	s2,16(sp)
ffffffffc02015a8:	64e2                	ld	s1,24(sp)
ffffffffc02015aa:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02015ac:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02015ae:	03065633          	divu	a2,a2,a6
ffffffffc02015b2:	8722                	mv	a4,s0
ffffffffc02015b4:	f9bff0ef          	jal	ra,ffffffffc020154e <printnum>
ffffffffc02015b8:	b7f9                	j	ffffffffc0201586 <printnum+0x38>

ffffffffc02015ba <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02015ba:	7119                	addi	sp,sp,-128
ffffffffc02015bc:	f4a6                	sd	s1,104(sp)
ffffffffc02015be:	f0ca                	sd	s2,96(sp)
ffffffffc02015c0:	e8d2                	sd	s4,80(sp)
ffffffffc02015c2:	e4d6                	sd	s5,72(sp)
ffffffffc02015c4:	e0da                	sd	s6,64(sp)
ffffffffc02015c6:	fc5e                	sd	s7,56(sp)
ffffffffc02015c8:	f862                	sd	s8,48(sp)
ffffffffc02015ca:	f06a                	sd	s10,32(sp)
ffffffffc02015cc:	fc86                	sd	ra,120(sp)
ffffffffc02015ce:	f8a2                	sd	s0,112(sp)
ffffffffc02015d0:	ecce                	sd	s3,88(sp)
ffffffffc02015d2:	f466                	sd	s9,40(sp)
ffffffffc02015d4:	ec6e                	sd	s11,24(sp)
ffffffffc02015d6:	892a                	mv	s2,a0
ffffffffc02015d8:	84ae                	mv	s1,a1
ffffffffc02015da:	8d32                	mv	s10,a2
ffffffffc02015dc:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02015de:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015e0:	00001a17          	auipc	s4,0x1
ffffffffc02015e4:	100a0a13          	addi	s4,s4,256 # ffffffffc02026e0 <best_fit_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02015e8:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02015ec:	00001c17          	auipc	s8,0x1
ffffffffc02015f0:	24cc0c13          	addi	s8,s8,588 # ffffffffc0202838 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02015f4:	000d4503          	lbu	a0,0(s10)
ffffffffc02015f8:	02500793          	li	a5,37
ffffffffc02015fc:	001d0413          	addi	s0,s10,1
ffffffffc0201600:	00f50e63          	beq	a0,a5,ffffffffc020161c <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0201604:	c521                	beqz	a0,ffffffffc020164c <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201606:	02500993          	li	s3,37
ffffffffc020160a:	a011                	j	ffffffffc020160e <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc020160c:	c121                	beqz	a0,ffffffffc020164c <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc020160e:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201610:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201612:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201614:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201618:	ff351ae3          	bne	a0,s3,ffffffffc020160c <vprintfmt+0x52>
ffffffffc020161c:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201620:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201624:	4981                	li	s3,0
ffffffffc0201626:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0201628:	5cfd                	li	s9,-1
ffffffffc020162a:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020162c:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0201630:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201632:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0201636:	0ff6f693          	andi	a3,a3,255
ffffffffc020163a:	00140d13          	addi	s10,s0,1
ffffffffc020163e:	20d5e563          	bltu	a1,a3,ffffffffc0201848 <vprintfmt+0x28e>
ffffffffc0201642:	068a                	slli	a3,a3,0x2
ffffffffc0201644:	96d2                	add	a3,a3,s4
ffffffffc0201646:	4294                	lw	a3,0(a3)
ffffffffc0201648:	96d2                	add	a3,a3,s4
ffffffffc020164a:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020164c:	70e6                	ld	ra,120(sp)
ffffffffc020164e:	7446                	ld	s0,112(sp)
ffffffffc0201650:	74a6                	ld	s1,104(sp)
ffffffffc0201652:	7906                	ld	s2,96(sp)
ffffffffc0201654:	69e6                	ld	s3,88(sp)
ffffffffc0201656:	6a46                	ld	s4,80(sp)
ffffffffc0201658:	6aa6                	ld	s5,72(sp)
ffffffffc020165a:	6b06                	ld	s6,64(sp)
ffffffffc020165c:	7be2                	ld	s7,56(sp)
ffffffffc020165e:	7c42                	ld	s8,48(sp)
ffffffffc0201660:	7ca2                	ld	s9,40(sp)
ffffffffc0201662:	7d02                	ld	s10,32(sp)
ffffffffc0201664:	6de2                	ld	s11,24(sp)
ffffffffc0201666:	6109                	addi	sp,sp,128
ffffffffc0201668:	8082                	ret
    if (lflag >= 2) {
ffffffffc020166a:	4705                	li	a4,1
ffffffffc020166c:	008a8593          	addi	a1,s5,8
ffffffffc0201670:	01074463          	blt	a4,a6,ffffffffc0201678 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0201674:	26080363          	beqz	a6,ffffffffc02018da <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0201678:	000ab603          	ld	a2,0(s5)
ffffffffc020167c:	46c1                	li	a3,16
ffffffffc020167e:	8aae                	mv	s5,a1
ffffffffc0201680:	a06d                	j	ffffffffc020172a <vprintfmt+0x170>
            goto reswitch;
ffffffffc0201682:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201686:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201688:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020168a:	b765                	j	ffffffffc0201632 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc020168c:	000aa503          	lw	a0,0(s5)
ffffffffc0201690:	85a6                	mv	a1,s1
ffffffffc0201692:	0aa1                	addi	s5,s5,8
ffffffffc0201694:	9902                	jalr	s2
            break;
ffffffffc0201696:	bfb9                	j	ffffffffc02015f4 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201698:	4705                	li	a4,1
ffffffffc020169a:	008a8993          	addi	s3,s5,8
ffffffffc020169e:	01074463          	blt	a4,a6,ffffffffc02016a6 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc02016a2:	22080463          	beqz	a6,ffffffffc02018ca <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc02016a6:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc02016aa:	24044463          	bltz	s0,ffffffffc02018f2 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc02016ae:	8622                	mv	a2,s0
ffffffffc02016b0:	8ace                	mv	s5,s3
ffffffffc02016b2:	46a9                	li	a3,10
ffffffffc02016b4:	a89d                	j	ffffffffc020172a <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc02016b6:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02016ba:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02016bc:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02016be:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02016c2:	8fb5                	xor	a5,a5,a3
ffffffffc02016c4:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02016c8:	1ad74363          	blt	a4,a3,ffffffffc020186e <vprintfmt+0x2b4>
ffffffffc02016cc:	00369793          	slli	a5,a3,0x3
ffffffffc02016d0:	97e2                	add	a5,a5,s8
ffffffffc02016d2:	639c                	ld	a5,0(a5)
ffffffffc02016d4:	18078d63          	beqz	a5,ffffffffc020186e <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc02016d8:	86be                	mv	a3,a5
ffffffffc02016da:	00001617          	auipc	a2,0x1
ffffffffc02016de:	24660613          	addi	a2,a2,582 # ffffffffc0202920 <error_string+0xe8>
ffffffffc02016e2:	85a6                	mv	a1,s1
ffffffffc02016e4:	854a                	mv	a0,s2
ffffffffc02016e6:	240000ef          	jal	ra,ffffffffc0201926 <printfmt>
ffffffffc02016ea:	b729                	j	ffffffffc02015f4 <vprintfmt+0x3a>
            lflag ++;
ffffffffc02016ec:	00144603          	lbu	a2,1(s0)
ffffffffc02016f0:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016f2:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02016f4:	bf3d                	j	ffffffffc0201632 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc02016f6:	4705                	li	a4,1
ffffffffc02016f8:	008a8593          	addi	a1,s5,8
ffffffffc02016fc:	01074463          	blt	a4,a6,ffffffffc0201704 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0201700:	1e080263          	beqz	a6,ffffffffc02018e4 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0201704:	000ab603          	ld	a2,0(s5)
ffffffffc0201708:	46a1                	li	a3,8
ffffffffc020170a:	8aae                	mv	s5,a1
ffffffffc020170c:	a839                	j	ffffffffc020172a <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc020170e:	03000513          	li	a0,48
ffffffffc0201712:	85a6                	mv	a1,s1
ffffffffc0201714:	e03e                	sd	a5,0(sp)
ffffffffc0201716:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201718:	85a6                	mv	a1,s1
ffffffffc020171a:	07800513          	li	a0,120
ffffffffc020171e:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201720:	0aa1                	addi	s5,s5,8
ffffffffc0201722:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0201726:	6782                	ld	a5,0(sp)
ffffffffc0201728:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020172a:	876e                	mv	a4,s11
ffffffffc020172c:	85a6                	mv	a1,s1
ffffffffc020172e:	854a                	mv	a0,s2
ffffffffc0201730:	e1fff0ef          	jal	ra,ffffffffc020154e <printnum>
            break;
ffffffffc0201734:	b5c1                	j	ffffffffc02015f4 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201736:	000ab603          	ld	a2,0(s5)
ffffffffc020173a:	0aa1                	addi	s5,s5,8
ffffffffc020173c:	1c060663          	beqz	a2,ffffffffc0201908 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0201740:	00160413          	addi	s0,a2,1
ffffffffc0201744:	17b05c63          	blez	s11,ffffffffc02018bc <vprintfmt+0x302>
ffffffffc0201748:	02d00593          	li	a1,45
ffffffffc020174c:	14b79263          	bne	a5,a1,ffffffffc0201890 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201750:	00064783          	lbu	a5,0(a2)
ffffffffc0201754:	0007851b          	sext.w	a0,a5
ffffffffc0201758:	c905                	beqz	a0,ffffffffc0201788 <vprintfmt+0x1ce>
ffffffffc020175a:	000cc563          	bltz	s9,ffffffffc0201764 <vprintfmt+0x1aa>
ffffffffc020175e:	3cfd                	addiw	s9,s9,-1
ffffffffc0201760:	036c8263          	beq	s9,s6,ffffffffc0201784 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0201764:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201766:	18098463          	beqz	s3,ffffffffc02018ee <vprintfmt+0x334>
ffffffffc020176a:	3781                	addiw	a5,a5,-32
ffffffffc020176c:	18fbf163          	bleu	a5,s7,ffffffffc02018ee <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0201770:	03f00513          	li	a0,63
ffffffffc0201774:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201776:	0405                	addi	s0,s0,1
ffffffffc0201778:	fff44783          	lbu	a5,-1(s0)
ffffffffc020177c:	3dfd                	addiw	s11,s11,-1
ffffffffc020177e:	0007851b          	sext.w	a0,a5
ffffffffc0201782:	fd61                	bnez	a0,ffffffffc020175a <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0201784:	e7b058e3          	blez	s11,ffffffffc02015f4 <vprintfmt+0x3a>
ffffffffc0201788:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020178a:	85a6                	mv	a1,s1
ffffffffc020178c:	02000513          	li	a0,32
ffffffffc0201790:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201792:	e60d81e3          	beqz	s11,ffffffffc02015f4 <vprintfmt+0x3a>
ffffffffc0201796:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201798:	85a6                	mv	a1,s1
ffffffffc020179a:	02000513          	li	a0,32
ffffffffc020179e:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02017a0:	fe0d94e3          	bnez	s11,ffffffffc0201788 <vprintfmt+0x1ce>
ffffffffc02017a4:	bd81                	j	ffffffffc02015f4 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02017a6:	4705                	li	a4,1
ffffffffc02017a8:	008a8593          	addi	a1,s5,8
ffffffffc02017ac:	01074463          	blt	a4,a6,ffffffffc02017b4 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc02017b0:	12080063          	beqz	a6,ffffffffc02018d0 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc02017b4:	000ab603          	ld	a2,0(s5)
ffffffffc02017b8:	46a9                	li	a3,10
ffffffffc02017ba:	8aae                	mv	s5,a1
ffffffffc02017bc:	b7bd                	j	ffffffffc020172a <vprintfmt+0x170>
ffffffffc02017be:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc02017c2:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017c6:	846a                	mv	s0,s10
ffffffffc02017c8:	b5ad                	j	ffffffffc0201632 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc02017ca:	85a6                	mv	a1,s1
ffffffffc02017cc:	02500513          	li	a0,37
ffffffffc02017d0:	9902                	jalr	s2
            break;
ffffffffc02017d2:	b50d                	j	ffffffffc02015f4 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc02017d4:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc02017d8:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02017dc:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017de:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc02017e0:	e40dd9e3          	bgez	s11,ffffffffc0201632 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc02017e4:	8de6                	mv	s11,s9
ffffffffc02017e6:	5cfd                	li	s9,-1
ffffffffc02017e8:	b5a9                	j	ffffffffc0201632 <vprintfmt+0x78>
            goto reswitch;
ffffffffc02017ea:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc02017ee:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017f2:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02017f4:	bd3d                	j	ffffffffc0201632 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc02017f6:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc02017fa:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017fe:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201800:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201804:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201808:	fcd56ce3          	bltu	a0,a3,ffffffffc02017e0 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc020180c:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020180e:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0201812:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201816:	0196873b          	addw	a4,a3,s9
ffffffffc020181a:	0017171b          	slliw	a4,a4,0x1
ffffffffc020181e:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0201822:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0201826:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc020182a:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020182e:	fcd57fe3          	bleu	a3,a0,ffffffffc020180c <vprintfmt+0x252>
ffffffffc0201832:	b77d                	j	ffffffffc02017e0 <vprintfmt+0x226>
            if (width < 0)
ffffffffc0201834:	fffdc693          	not	a3,s11
ffffffffc0201838:	96fd                	srai	a3,a3,0x3f
ffffffffc020183a:	00ddfdb3          	and	s11,s11,a3
ffffffffc020183e:	00144603          	lbu	a2,1(s0)
ffffffffc0201842:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201844:	846a                	mv	s0,s10
ffffffffc0201846:	b3f5                	j	ffffffffc0201632 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0201848:	85a6                	mv	a1,s1
ffffffffc020184a:	02500513          	li	a0,37
ffffffffc020184e:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201850:	fff44703          	lbu	a4,-1(s0)
ffffffffc0201854:	02500793          	li	a5,37
ffffffffc0201858:	8d22                	mv	s10,s0
ffffffffc020185a:	d8f70de3          	beq	a4,a5,ffffffffc02015f4 <vprintfmt+0x3a>
ffffffffc020185e:	02500713          	li	a4,37
ffffffffc0201862:	1d7d                	addi	s10,s10,-1
ffffffffc0201864:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0201868:	fee79de3          	bne	a5,a4,ffffffffc0201862 <vprintfmt+0x2a8>
ffffffffc020186c:	b361                	j	ffffffffc02015f4 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020186e:	00001617          	auipc	a2,0x1
ffffffffc0201872:	0a260613          	addi	a2,a2,162 # ffffffffc0202910 <error_string+0xd8>
ffffffffc0201876:	85a6                	mv	a1,s1
ffffffffc0201878:	854a                	mv	a0,s2
ffffffffc020187a:	0ac000ef          	jal	ra,ffffffffc0201926 <printfmt>
ffffffffc020187e:	bb9d                	j	ffffffffc02015f4 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201880:	00001617          	auipc	a2,0x1
ffffffffc0201884:	08860613          	addi	a2,a2,136 # ffffffffc0202908 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc0201888:	00001417          	auipc	s0,0x1
ffffffffc020188c:	08140413          	addi	s0,s0,129 # ffffffffc0202909 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201890:	8532                	mv	a0,a2
ffffffffc0201892:	85e6                	mv	a1,s9
ffffffffc0201894:	e032                	sd	a2,0(sp)
ffffffffc0201896:	e43e                	sd	a5,8(sp)
ffffffffc0201898:	1c2000ef          	jal	ra,ffffffffc0201a5a <strnlen>
ffffffffc020189c:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02018a0:	6602                	ld	a2,0(sp)
ffffffffc02018a2:	01b05d63          	blez	s11,ffffffffc02018bc <vprintfmt+0x302>
ffffffffc02018a6:	67a2                	ld	a5,8(sp)
ffffffffc02018a8:	2781                	sext.w	a5,a5
ffffffffc02018aa:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc02018ac:	6522                	ld	a0,8(sp)
ffffffffc02018ae:	85a6                	mv	a1,s1
ffffffffc02018b0:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02018b2:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02018b4:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02018b6:	6602                	ld	a2,0(sp)
ffffffffc02018b8:	fe0d9ae3          	bnez	s11,ffffffffc02018ac <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02018bc:	00064783          	lbu	a5,0(a2)
ffffffffc02018c0:	0007851b          	sext.w	a0,a5
ffffffffc02018c4:	e8051be3          	bnez	a0,ffffffffc020175a <vprintfmt+0x1a0>
ffffffffc02018c8:	b335                	j	ffffffffc02015f4 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc02018ca:	000aa403          	lw	s0,0(s5)
ffffffffc02018ce:	bbf1                	j	ffffffffc02016aa <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc02018d0:	000ae603          	lwu	a2,0(s5)
ffffffffc02018d4:	46a9                	li	a3,10
ffffffffc02018d6:	8aae                	mv	s5,a1
ffffffffc02018d8:	bd89                	j	ffffffffc020172a <vprintfmt+0x170>
ffffffffc02018da:	000ae603          	lwu	a2,0(s5)
ffffffffc02018de:	46c1                	li	a3,16
ffffffffc02018e0:	8aae                	mv	s5,a1
ffffffffc02018e2:	b5a1                	j	ffffffffc020172a <vprintfmt+0x170>
ffffffffc02018e4:	000ae603          	lwu	a2,0(s5)
ffffffffc02018e8:	46a1                	li	a3,8
ffffffffc02018ea:	8aae                	mv	s5,a1
ffffffffc02018ec:	bd3d                	j	ffffffffc020172a <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc02018ee:	9902                	jalr	s2
ffffffffc02018f0:	b559                	j	ffffffffc0201776 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc02018f2:	85a6                	mv	a1,s1
ffffffffc02018f4:	02d00513          	li	a0,45
ffffffffc02018f8:	e03e                	sd	a5,0(sp)
ffffffffc02018fa:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02018fc:	8ace                	mv	s5,s3
ffffffffc02018fe:	40800633          	neg	a2,s0
ffffffffc0201902:	46a9                	li	a3,10
ffffffffc0201904:	6782                	ld	a5,0(sp)
ffffffffc0201906:	b515                	j	ffffffffc020172a <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0201908:	01b05663          	blez	s11,ffffffffc0201914 <vprintfmt+0x35a>
ffffffffc020190c:	02d00693          	li	a3,45
ffffffffc0201910:	f6d798e3          	bne	a5,a3,ffffffffc0201880 <vprintfmt+0x2c6>
ffffffffc0201914:	00001417          	auipc	s0,0x1
ffffffffc0201918:	ff540413          	addi	s0,s0,-11 # ffffffffc0202909 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020191c:	02800513          	li	a0,40
ffffffffc0201920:	02800793          	li	a5,40
ffffffffc0201924:	bd1d                	j	ffffffffc020175a <vprintfmt+0x1a0>

ffffffffc0201926 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201926:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201928:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020192c:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020192e:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201930:	ec06                	sd	ra,24(sp)
ffffffffc0201932:	f83a                	sd	a4,48(sp)
ffffffffc0201934:	fc3e                	sd	a5,56(sp)
ffffffffc0201936:	e0c2                	sd	a6,64(sp)
ffffffffc0201938:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020193a:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020193c:	c7fff0ef          	jal	ra,ffffffffc02015ba <vprintfmt>
}
ffffffffc0201940:	60e2                	ld	ra,24(sp)
ffffffffc0201942:	6161                	addi	sp,sp,80
ffffffffc0201944:	8082                	ret

ffffffffc0201946 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201946:	715d                	addi	sp,sp,-80
ffffffffc0201948:	e486                	sd	ra,72(sp)
ffffffffc020194a:	e0a2                	sd	s0,64(sp)
ffffffffc020194c:	fc26                	sd	s1,56(sp)
ffffffffc020194e:	f84a                	sd	s2,48(sp)
ffffffffc0201950:	f44e                	sd	s3,40(sp)
ffffffffc0201952:	f052                	sd	s4,32(sp)
ffffffffc0201954:	ec56                	sd	s5,24(sp)
ffffffffc0201956:	e85a                	sd	s6,16(sp)
ffffffffc0201958:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc020195a:	c901                	beqz	a0,ffffffffc020196a <readline+0x24>
        cprintf("%s", prompt);
ffffffffc020195c:	85aa                	mv	a1,a0
ffffffffc020195e:	00001517          	auipc	a0,0x1
ffffffffc0201962:	fc250513          	addi	a0,a0,-62 # ffffffffc0202920 <error_string+0xe8>
ffffffffc0201966:	f50fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc020196a:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020196c:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020196e:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201970:	4aa9                	li	s5,10
ffffffffc0201972:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201974:	00004b97          	auipc	s7,0x4
ffffffffc0201978:	69cb8b93          	addi	s7,s7,1692 # ffffffffc0206010 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020197c:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201980:	faefe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201984:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201986:	00054b63          	bltz	a0,ffffffffc020199c <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020198a:	00a95b63          	ble	a0,s2,ffffffffc02019a0 <readline+0x5a>
ffffffffc020198e:	029a5463          	ble	s1,s4,ffffffffc02019b6 <readline+0x70>
        c = getchar();
ffffffffc0201992:	f9cfe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201996:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201998:	fe0559e3          	bgez	a0,ffffffffc020198a <readline+0x44>
            return NULL;
ffffffffc020199c:	4501                	li	a0,0
ffffffffc020199e:	a099                	j	ffffffffc02019e4 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02019a0:	03341463          	bne	s0,s3,ffffffffc02019c8 <readline+0x82>
ffffffffc02019a4:	e8b9                	bnez	s1,ffffffffc02019fa <readline+0xb4>
        c = getchar();
ffffffffc02019a6:	f88fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc02019aa:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02019ac:	fe0548e3          	bltz	a0,ffffffffc020199c <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02019b0:	fea958e3          	ble	a0,s2,ffffffffc02019a0 <readline+0x5a>
ffffffffc02019b4:	4481                	li	s1,0
            cputchar(c);
ffffffffc02019b6:	8522                	mv	a0,s0
ffffffffc02019b8:	f32fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc02019bc:	009b87b3          	add	a5,s7,s1
ffffffffc02019c0:	00878023          	sb	s0,0(a5)
ffffffffc02019c4:	2485                	addiw	s1,s1,1
ffffffffc02019c6:	bf6d                	j	ffffffffc0201980 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc02019c8:	01540463          	beq	s0,s5,ffffffffc02019d0 <readline+0x8a>
ffffffffc02019cc:	fb641ae3          	bne	s0,s6,ffffffffc0201980 <readline+0x3a>
            cputchar(c);
ffffffffc02019d0:	8522                	mv	a0,s0
ffffffffc02019d2:	f18fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc02019d6:	00004517          	auipc	a0,0x4
ffffffffc02019da:	63a50513          	addi	a0,a0,1594 # ffffffffc0206010 <edata>
ffffffffc02019de:	94aa                	add	s1,s1,a0
ffffffffc02019e0:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02019e4:	60a6                	ld	ra,72(sp)
ffffffffc02019e6:	6406                	ld	s0,64(sp)
ffffffffc02019e8:	74e2                	ld	s1,56(sp)
ffffffffc02019ea:	7942                	ld	s2,48(sp)
ffffffffc02019ec:	79a2                	ld	s3,40(sp)
ffffffffc02019ee:	7a02                	ld	s4,32(sp)
ffffffffc02019f0:	6ae2                	ld	s5,24(sp)
ffffffffc02019f2:	6b42                	ld	s6,16(sp)
ffffffffc02019f4:	6ba2                	ld	s7,8(sp)
ffffffffc02019f6:	6161                	addi	sp,sp,80
ffffffffc02019f8:	8082                	ret
            cputchar(c);
ffffffffc02019fa:	4521                	li	a0,8
ffffffffc02019fc:	eeefe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc0201a00:	34fd                	addiw	s1,s1,-1
ffffffffc0201a02:	bfbd                	j	ffffffffc0201980 <readline+0x3a>

ffffffffc0201a04 <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc0201a04:	00004797          	auipc	a5,0x4
ffffffffc0201a08:	60478793          	addi	a5,a5,1540 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc0201a0c:	6398                	ld	a4,0(a5)
ffffffffc0201a0e:	4781                	li	a5,0
ffffffffc0201a10:	88ba                	mv	a7,a4
ffffffffc0201a12:	852a                	mv	a0,a0
ffffffffc0201a14:	85be                	mv	a1,a5
ffffffffc0201a16:	863e                	mv	a2,a5
ffffffffc0201a18:	00000073          	ecall
ffffffffc0201a1c:	87aa                	mv	a5,a0
}
ffffffffc0201a1e:	8082                	ret

ffffffffc0201a20 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc0201a20:	00005797          	auipc	a5,0x5
ffffffffc0201a24:	a0878793          	addi	a5,a5,-1528 # ffffffffc0206428 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc0201a28:	6398                	ld	a4,0(a5)
ffffffffc0201a2a:	4781                	li	a5,0
ffffffffc0201a2c:	88ba                	mv	a7,a4
ffffffffc0201a2e:	852a                	mv	a0,a0
ffffffffc0201a30:	85be                	mv	a1,a5
ffffffffc0201a32:	863e                	mv	a2,a5
ffffffffc0201a34:	00000073          	ecall
ffffffffc0201a38:	87aa                	mv	a5,a0
}
ffffffffc0201a3a:	8082                	ret

ffffffffc0201a3c <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201a3c:	00004797          	auipc	a5,0x4
ffffffffc0201a40:	5c478793          	addi	a5,a5,1476 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc0201a44:	639c                	ld	a5,0(a5)
ffffffffc0201a46:	4501                	li	a0,0
ffffffffc0201a48:	88be                	mv	a7,a5
ffffffffc0201a4a:	852a                	mv	a0,a0
ffffffffc0201a4c:	85aa                	mv	a1,a0
ffffffffc0201a4e:	862a                	mv	a2,a0
ffffffffc0201a50:	00000073          	ecall
ffffffffc0201a54:	852a                	mv	a0,a0
ffffffffc0201a56:	2501                	sext.w	a0,a0
ffffffffc0201a58:	8082                	ret

ffffffffc0201a5a <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201a5a:	c185                	beqz	a1,ffffffffc0201a7a <strnlen+0x20>
ffffffffc0201a5c:	00054783          	lbu	a5,0(a0)
ffffffffc0201a60:	cf89                	beqz	a5,ffffffffc0201a7a <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0201a62:	4781                	li	a5,0
ffffffffc0201a64:	a021                	j	ffffffffc0201a6c <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201a66:	00074703          	lbu	a4,0(a4)
ffffffffc0201a6a:	c711                	beqz	a4,ffffffffc0201a76 <strnlen+0x1c>
        cnt ++;
ffffffffc0201a6c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201a6e:	00f50733          	add	a4,a0,a5
ffffffffc0201a72:	fef59ae3          	bne	a1,a5,ffffffffc0201a66 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0201a76:	853e                	mv	a0,a5
ffffffffc0201a78:	8082                	ret
    size_t cnt = 0;
ffffffffc0201a7a:	4781                	li	a5,0
}
ffffffffc0201a7c:	853e                	mv	a0,a5
ffffffffc0201a7e:	8082                	ret

ffffffffc0201a80 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201a80:	00054783          	lbu	a5,0(a0)
ffffffffc0201a84:	0005c703          	lbu	a4,0(a1)
ffffffffc0201a88:	cb91                	beqz	a5,ffffffffc0201a9c <strcmp+0x1c>
ffffffffc0201a8a:	00e79c63          	bne	a5,a4,ffffffffc0201aa2 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0201a8e:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201a90:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0201a94:	0585                	addi	a1,a1,1
ffffffffc0201a96:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201a9a:	fbe5                	bnez	a5,ffffffffc0201a8a <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201a9c:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201a9e:	9d19                	subw	a0,a0,a4
ffffffffc0201aa0:	8082                	ret
ffffffffc0201aa2:	0007851b          	sext.w	a0,a5
ffffffffc0201aa6:	9d19                	subw	a0,a0,a4
ffffffffc0201aa8:	8082                	ret

ffffffffc0201aaa <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201aaa:	00054783          	lbu	a5,0(a0)
ffffffffc0201aae:	cb91                	beqz	a5,ffffffffc0201ac2 <strchr+0x18>
        if (*s == c) {
ffffffffc0201ab0:	00b79563          	bne	a5,a1,ffffffffc0201aba <strchr+0x10>
ffffffffc0201ab4:	a809                	j	ffffffffc0201ac6 <strchr+0x1c>
ffffffffc0201ab6:	00b78763          	beq	a5,a1,ffffffffc0201ac4 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0201aba:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201abc:	00054783          	lbu	a5,0(a0)
ffffffffc0201ac0:	fbfd                	bnez	a5,ffffffffc0201ab6 <strchr+0xc>
    }
    return NULL;
ffffffffc0201ac2:	4501                	li	a0,0
}
ffffffffc0201ac4:	8082                	ret
ffffffffc0201ac6:	8082                	ret

ffffffffc0201ac8 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201ac8:	ca01                	beqz	a2,ffffffffc0201ad8 <memset+0x10>
ffffffffc0201aca:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201acc:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201ace:	0785                	addi	a5,a5,1
ffffffffc0201ad0:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201ad4:	fec79de3          	bne	a5,a2,ffffffffc0201ace <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201ad8:	8082                	ret
