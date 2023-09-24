# lab0.5和lab1实验报告

## 一、lab0.5实验内容

实验 0.5 主要讲解最小可执行内核和启动流程。我们的内核主要在 Qemu 模拟器上运行，它可以模拟一台 64位 RISC-V 计算机。为了让我们的内核能够正确对接到 Qemu 模拟器上，需要了解 Qemu 模拟器的启动流程，还需要一些程序内存布局和编译流程（特别是链接）相关知识, 以及通过 opensbi 固件来服务。

### 练习1: 使用GDB验证启动流程
为了熟悉使用qemu和gdb进行调试工作,使用gdb调试QEMU模拟的RISC-V计算机加电开始运行到执行应用程序的第一条指令（即跳转到0x80200000）这个阶段的执行过程，说明RISC-V硬件加电后的几条指令在哪里？完成了哪些功能？要求在报告中简要写出练习过程和回答

#### (1)说明RISC-V硬件加电后的几条指令在哪里？

通过make debug指令查看计算机运行开始时的前十条指令如下：

```assembly
(gdb) x/10i $pc
=> 0x1000:	auipc	t0,0x0 #将全局地址的上半部分加载到寄存器t0中
   0x1004:	addi	a2,t0,40 #从mhartid CSR中读取值，然后将其存储在寄存器a0中。
   0x1008:	csrr	a0,mhartid
   0x100c:	ld	a1,32(t0)
   0x1010:	ld	t0,24(t0)
   0x1014:	jr	t0 #跳转到t0寄存器的位置
   0x1018:	unimp
   0x101a:	0x8000 
   0x101c:	unimp 
   0x101e:	unimp 
```

然而当输入x/20i $pc时我们注意到后续还有指令，并未结束，因此开始逐步调试，调试后发现加电前的指令除了储存在0x1000~0x101a之间，在0x0000~0x1000中还有需要多次执行的指令，因此得出结论：

**加电后执行的指令在地址0x00000000~0x00001014之间**

#### (2)说明RISC-V硬件加电后的几条指令完成了哪些功能？

通过输入`break *0x80200000`在0x80200000处设置断点

```assembly
Breakpoint 2 at 0x80200000: file kern/init/entry.S, line 7.
```

检查该地址的代码发现：

```assembly
(gdb) disassemble kern_init
Dump of assembler code for function kern_init:
   0x000000008020000c <+0>:	auipc	a0,0x3
   0x0000000080200010 <+4>:	addi	a0,a0,-4 # 0x80203008
   0x0000000080200014 <+8>:	auipc	a2,0x3
   0x0000000080200018 <+12>:	addi	a2,a2,-12 # 0x80203008
   0x000000008020001c <+16>:	addi	sp,sp,-16
   0x000000008020001e <+18>:	li	a1,0
   0x0000000080200020 <+20>:	sub	a2,a2,a0
   0x0000000080200022 <+22>:	sd	ra,8(sp)
   0x0000000080200024 <+24>:	jal	ra,0x802004ce <memset>
   0x0000000080200028 <+28>:	auipc	a1,0x0
   0x000000008020002c <+32>:	addi	a1,a1,1208 # 0x802004e0
   0x0000000080200030 <+36>:	auipc	a0,0x0
   0x0000000080200034 <+40>:	addi	a0,a0,1232 # 0x80200500
   0x0000000080200038 <+44>:	jal	ra,0x80200058 <cprintf>
   0x000000008020003c <+48>:	j	0x8020003c <kern_init+48>
```
这就是kern_init的代码入口，同时这也是实验运行的第一个程序。
我们发现程序在0x00001014处执行的跳转指令最终将引领程序跳转到0x80200000处，于是得出结论：

**加电后的指令帮助计算机完成运行程序前的准备工作，并跳转到程序入口地址0x80200000**

## 二、lab1实验内容

实验1主要讲解的是中断处理机制。通过本章的学习，我们了解了 riscv 的中断处理机制、相关寄存器与指令。我们知道在中断前后需要恢复上下文环境，用 一个名为中断帧（TrapFrame）的结构体存储了要保存的各寄存器，并用了很大篇幅解释如何通过精巧的汇编代码实现上下文环境保存与恢复机制。最终，我们通过处理断点和时钟中断验证了我们正确实现了中断机制。

### 练习1：理解内核启动中的程序入口操作
阅读 kern/init/entry.S内容代码，结合操作系统内核启动流程，说明指令 la sp, bootstacktop 完成了什么操作，目的是什么？ tail kern_init 完成了什么操作，目的是什么？

#### (1)说明指令 la sp, bootstacktop 完成了什么操作，目的是什么？
通过设置断点`break *0x80200000`我们找到了即将执行的汇编指令

```assembly
(gdb) x/10i $pc
=> 0x80200000 <kern_entry>:	auipc	sp,0x3
   0x80200004 <kern_entry+4>:	mv	sp,sp
   0x80200008 <kern_entry+8>:	j	0x8020000c <kern_init>
   0x8020000c <kern_init>:	auipc	a0,0x3
   0x80200010 <kern_init+4>:	addi	a0,a0,-4
   0x80200014 <kern_init+8>:	auipc	a2,0x3
   0x80200018 <kern_init+12>:	addi	a2,a2,-12
   0x8020001c <kern_init+16>:	addi	sp,sp,-16
   0x8020001e <kern_init+18>:	li	a1,0
   0x80200020 <kern_init+20>:	sub	a2,a2,a0
```

可以看出`auipc	sp,0x3`和`mv	sp,sp`两条指令是指令`la sp, bootstacktop`对应的汇编代码，看起来是对sp寄存器做出了改动，我们通过`info r`指令来观察sp寄存器的值，输出如下：
```assembly
(gdb) info r
ra             0x0000000080000a02	2147486210
sp             0x0000000080203000	2149593088
gp             0x0000000000000000	0
tp             0x000000008001be00	2147597824
t0             0x0000000080200000	2149580800
.......
```

可以看出sp寄存器的值加上了0x0000000000003000，确实有改动。
通过上网查询指令功能，我们得出答案：

**la sp, bootstacktop该指令是把栈顶的返回值保存进sp寄存器中**

#### (2)说明指令 tail kern_init 完成了什么操作，目的是什么？

通过继续调试发现指令`j	0x8020000c <kern_init>`是指令`tail kern_init`对应的汇编代码，由此得出答案：

**tail kern_init该指令是令语句跳转到地址0x8020000c对应的kern_init函数开始处**

### 练习2：完善中断处理

请编程完善trap.c中的中断处理函数trap，在对时钟中断进行处理的部分填写kern/trap/trap.c函数中处理时钟中断的部分，使操作系统每遇到100次时钟中断后，调用print_ticks子程序，向屏幕上打印一行文字”100 ticks”，在打印完10行后调用sbi.h中的shut_down()函数关机。

要求完成问题1提出的相关函数实现，提交改进后的源代码包（可以编译执行），并在实验报告中简要说明实现过程和定时器中断中断处理的流程。实现要求的部分代码后，运行整个系统，大约每1秒会输出一次”100 ticks”，输出10行。

#### (1)完善trap函数

定义全局变量
`volatile size_t ticks=0;`
在修改代码处将代码修改为：
```
case IRQ_S_TIMER:
    clock_set_next_event();
    ticks++;
    if(ticks == TICK_NUM){
    	ticks = 0;
    	print_ticks();
    	num++;
    }
    if(num == 10)
    	sbi_shutdown();
     break;
```

**完善后执行make，输出结果符合预期**

### 练习3：描述与理解中断流程
描述ucore中处理中断异常的流程（从异常的产生开始），其中mov a0，sp的目的是什么？SAVE_ALL中寄寄存器保存在栈中的位置是什么确定的？对于任何中断，__alltraps 中都需要保存所有寄存器吗？请说明理由。

#### (1)描述ucore中处理中断异常的流程（从异常的产生开始）
trap函数（定义在trap.c中）是对中断进行处理的过程，所有的中断在经过中断入口函数__alltraps预处理后 (定义在 trapentry.S中) ，都会跳转到这里。在处理过程中，根据不同的中断类型，进行相应的处理。在相应的处理过程结束以后，trap将会返回，被中断的程序会继续运行。

#### (2)其中mov a0，sp的目的是什么
为了用a0储存器记录当前函数的值，方便错误处理完后返回中断点。

#### (3)SAVE_ALL中寄存器保存在栈中的位置是什么确定的？
由当前栈顶位置栈顶确定。

#### (4)__alltraps中都需要保存所有寄存器吗？请说明理由。
需要，这是因为任何处理机制都有可能对寄存器的值进行修改，从而导致安全性隐患。

### 练习4：理解上下文切换机制
在trapentry.S中汇编代码 csrw sscratch, sp；csrrw s0, sscratch, x0实现了什么操作，目的是什么？save all里面保存了stval scause这些csr，而在restore all里面却不还原它们？那这样store的意义何在呢？

#### (1)在trapentry.S中汇编代码 csrw sscratch, sp；csrrw s0, sscratch, x0实现了什么操作，目的是什么？
`csrw sscratch, sp`操作是将sp寄存器的值写入sscratch寄存器，这是异常处理开始时的操作，能够提供一个空寄存器进行处理。

#### (2)save all里面保存了stval scause这些csr，而在restore all里面却不还原它们？
因为没有必要还原，下一次中断就会覆盖为新的值

#### (3)那这样store的意义何在呢？
即为临时储存所有的值，为了回复之前的状态

### 练习5：完善异常中断
编程完善在触发一条非法指令异常 mret和，在 kern/trap/trap.c的异常处理函数中捕获，并对其进行处理，简单输出异常类型和异常指令触发地址，即“Illegal instruction caught at 0x(地址)”，“ebreak caught at 0x（地址）”与“Exception type:Illegal instruction"，“Exception type: breakpoint”。

#### (1)完善trap函数

```
case CAUSE_ILLEGAL_INSTRUCTION:
   cprintf("Illegal instruction at 0x%01611x\n",tf->epc);
   tf->epc += 4;
case CAUSE_BREAKPOINT:
   cprintf("breakpoint at 0x%01611x\n",tf->epc);
   tf->epc += 2;
```

首先tf->epc的值为当前代码所指的汇编语句地址，每一条汇编语句长度不一，因此调用tf->epc来获取当前执行语句的地址。
随后我们注意到Illegal instruction指令长度为四个字节，然而breakpoint指令长度为两个字节，因此我们在执行语句处理之后需要将epc的值后跳相应字节，至此处理完毕。

**完善后执行make，输出结果符合预期**

## 三、与答案对比差异

实验较为简单，并无明显差异。

## 四、实验中的知识点

- 异常：程序执行中内部指令执行时出现的错误，例如发生缺页、非法指令等。
- 中断：CPU 的执行过程被外设发来的信号打断，例如时钟中断等。