#                                  lab4  实验报告

## 一、实验内容

-实验2/3完成了物理和虚拟内存管理，这给创建内核线程（内核线程是一种特殊的进程）打下了提供内存管理的基础。当一个程序加载到内存中运行时，首先通过ucore OS的内存管理子系统分配合适的空间，然后就需要考虑如何分时使用CPU来“并发”执行多个程序，让每个运行的程序（这里用线程或进程表示）“感到”它们各自拥有“自己”的CPU。

-本次实验将首先接触的是内核线程的管理。内核线程是一种特殊的进程，内核线程与用户进程的区别有两个：

内核线程只运行在内核态，用户进程会在在用户态和内核态交替运行，所有内核线程共用ucore内核内存空间，不需为每个内核线程维护单独的内存空间，而用户进程需要维护各自的用户内存空间


## 二、实验过程

###  练习1：分配并初始化一个进程控制块（需要编码）

alloc_proc函数（位于kern/process/proc.c中）负责分配并返回一个新的struct proc_struct结构，用于存储新建立的内核线程的管理信息。ucore需要对这个结构进行最基本的初始化，你需要完成这个初始化过程。

> 【提示】在alloc_proc函数的实现中，需要初始化的proc_struct结构中的成员变量至少包括：state/pid/runs/kstack/need_resched/parent/mm/context/tf/cr3/flags/name。

请在实验报告中简要说明你的设计实现过程。请回答如下问题：

- 请说明proc_struct中`struct context context`和`struct trapframe *tf`成员变量含义和在本实验中的作用是啥？（提示通过看代码和编程调试可以判断出来）

#### 1.设计实现过程

```c
        proc->state = PROC_UNINIT; //设置进程为初始态,表示进程处于未初始化状态。
        proc->pid = -1; //设置进程pid的未初始化值
        proc->runs = 0;//初始化内核栈。
        proc->kstack = 0;
        proc->need_resched = 0;//初始化是否需要重新调度的标志。
        proc->parent = NULL;//将父进程指针设为 NULL。
        proc->mm = NULL;//将内存管理结构体指针设为 NULL。
        memset(&(proc->context), 0, sizeof(struct context));//使用 memset 将进程上下文结构体清零。
        proc->tf = NULL;
        proc->cr3 = boot_cr3; //使用内核页目录表的基址
        proc->flags = 0;//初始化进程标志。
        memset(proc->name, 0, PROC_NAME_LEN);//清零进程名字。
```

#### 2.作用

先找到相关函数

```c
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
    struct trapframe tf;//创建一个名为 tf 的结构体，用于保存线程的上下文信息。
    memset(&tf, 0, sizeof(struct trapframe));
    tf.gpr.s0 = (uintptr_t)fn;
    tf.gpr.s1 = (uintptr_t)arg;//置结构体中的通用寄存器 s0 和 s1 分别为传入函数指针 fn 和参数 arg 的地址
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;//将当前 CPU 的状态寄存器的 Supervisor Previous Privilege  和 Supervisor Previous Interrupt Enable  位设置为1，同时 Supervisor Interrupt Enable 位设置为0。

    tf.epc = (uintptr_t)kernel_thread_entry;//将 tf 结构体的 epc 字段设置为 kernel_thread_entry 函数的地址
    return do_fork(clone_flags | CLONE_VM, 0, &tf);//调用 do_fork 函数创建一个新的进程。clone_flags | CLONE_VM 表示创建一个与父进程共享虚拟内存的子进程，而 &tf 则传递了上下文信息给新的进程
}
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) 
{
    //将tf进行初始化
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
    *(proc->tf) = *tf;
    proc->tf->tf_regs.reg_eax = 0;
    //设置tf的esp，表示中断栈的信息
    proc->tf->tf_esp = esp;
    proc->tf->tf_eflags |= FL_IF;
    //对context进行设置
    //forkret主要对返回的中断处理，基本可以认为是一个中断处理并恢复
    proc->context.eip = (uintptr_t)forkret;
    proc->context.esp = (uintptr_t)(proc->tf);
}
```
proc_struct中的context ：context中保存了进程执行的上下文，也就是几个关键的寄存器的值。这些寄存器的值用于在进程切换中还原之前进程的运行状态
proc_struct中的tf：tf里保存了进程的中断帧。当进程从用户空间跳进内核空间的时候，进程的执行状态被保存在了中断帧中（注意这里需要保存的执行状态数量不同于上下文切换）。系统调用可能会改变用户寄存器的值，我们可以通过调整中断帧来使得系统调用返回特定的值。



### 练习2：为新创建的内核线程分配资源（需要编码）

创建一个内核线程需要分配和设置好很多资源。kernel_thread函数通过调用**do_fork**函数完成具体内核线程的创建工作。do_kernel函数会调用alloc_proc函数来分配并初始化一个进程控制块，但alloc_proc只是找到了一小块内存用以记录进程的必要信息，并没有实际分配这些资源。ucore一般通过do_fork实际创建新的内核线程。do_fork的作用是，创建当前内核线程的一个副本，它们的执行上下文、代码、数据都一样，但是存储位置不同。因此，我们**实际需要”fork”的东西就是stack和trapframe**。在这个过程中，需要给新内核线程分配资源，并且复制原进程的状态。你需要完成在kern/process/proc.c中的do_fork函数中的处理过程。它的大致执行步骤包括：

- 调用alloc_proc，首先获得一块用户信息块。
- 为进程分配一个内核栈。
- 复制原进程的内存管理信息到新进程（但内核线程不必做此事）
- 复制原进程上下文到新进程
- 将新进程添加到进程列表
- 唤醒新进程
- 返回新进程号

请在实验报告中简要说明你的设计实现过程。请回答如下问题：

- 请说明ucore是否做到给每个新fork的线程一个唯一的id？请说明你的分析和理由。

#### 1.设计实现过程

```c
    //    1. call alloc_proc to allocate a proc_struct
    proc = alloc_proc();
    if(proc == NULL){
        goto fork_out;
    }
    //    2. call setup_kstack to allocate a kernel stack for child process
    ret = setup_kstack(proc);
    if(ret != 0) {
        goto bad_fork_cleanup_proc;
    }
    //    3. call copy_mm to dup OR share mm according clone_flag
    ret = copy_mm(clone_flags,proc);
    if(ret != 0) {
        goto bad_fork_cleanup_kstack;
    }
    //    4. call copy_thread to setup tf & context in proc_struct
    copy_thread(proc,stack,tf);
    //    5. insert proc_struct into hash_list && proc_list
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        proc->pid = get_pid();
        hash_proc(proc);
        list_add(&proc_list,&(proc->list_link));
        nr_process++;
    }
    local_intr_restore(intr_flag);
    //    6. call wakeup_proc to make the new child process RUNNABLE
    wakeup_proc(proc);
    //    7. set ret vaule using child proc's pid
    ret = proc->pid;
```



#### 2.分析

首先查看函数`get_id`

```c
// get_pid - alloc a unique pid for process
static int
get_pid(void) {
    static_assert(MAX_PID > MAX_PROCESS);//静态断言确保 MAX_PID 大于 MAX_PROCESS，即进程的最大 PID 要大于最大进程数。这可以在编译时期确保最大 PID 足够容纳系统可能创建的进程数量。
    struct proc_struct *proc;//进程结构体指针。
    list_entry_t *list = &proc_list, *le;//指向进程列表的指针和迭代器指针。
    static int next_safe = MAX_PID, last_pid = MAX_PID;//两个静态变量，next_safe 和 last_pid 分别存储下一个安全的 PID 和上一个 PID。
    if (++ last_pid >= MAX_PID) {
        last_pid = 1;
        goto inside;//如果增加上一个 PID 后大于等于最大 PID，将上一个 PID 重置为 1，然后跳到标签 inside。
    }
    if (last_pid >= next_safe) {
    inside:
        next_safe = MAX_PID;//如果上一个 PID 大于等于下一个安全的 PID，则进入标签 inside。inside 初始化 next_safe 为最大 PID。
    repeat://用于重新检查 PID 的循环。
        le = list;
        while ((le = list_next(le)) != list) {//在循环中，遍历进程列表，检查当前 PID 是否被使用：
            proc = le2proc(le, list_link);
            if (proc->pid == last_pid) {
                if (++ last_pid >= next_safe) {
                    if (last_pid >= MAX_PID) {
                        last_pid = 1;
                    }
                    next_safe = MAX_PID;
                    goto repeat;//如果当前 PID 被使用，增加上一个 PID，并检查是否超出了下一个安全的 PID，如果是，则重新检查。
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
                next_safe = proc->pid;//如果当前 PID 没有被使用，但比上一个 PID 大，并且比下一个安全的 PID 小，则更新下一个安全的 PID 为当前 PID。
            }
        }
    }
    return last_pid;//返回上一个 PID。
}
```

get_id将为每个调用fock的线程返回不同的id

### 练习3：编写proc_run 函数（需要编码）

proc_run用于将指定的进程切换到CPU上运行。它的大致执行步骤包括：

- 检查要切换的进程是否与当前正在运行的进程相同，如果相同则不需要切换。
- 禁用中断。你可以使用`/kern/sync/sync.h`中定义好的宏`local_intr_save(x)`和`local_intr_restore(x)`来实现关、开中断。
- 切换当前进程为要运行的进程。
- 切换页表，以便使用新进程的地址空间。`/libs/riscv.h`中提供了`lcr3(unsigned int cr3)`函数，可实现修改CR3寄存器值的功能。
- 实现上下文切换。`/kern/process`中已经预先编写好了`switch.S`，其中定义了`switch_to()`函数。可实现两个进程的context切换。
- 允许中断。

请回答如下问题：

- 在本实验的执行过程中，创建且运行了几个内核线程？
    bool intr_flag;//保存中断状态的标志位。
        struct proc_struct* prev = current, * next = proc;//创建两个指针 prev 和 next，分别指向当前运行的进程和将要切换到的目标进程。
        local_intr_save(intr_flag);//禁用中断，保存当前中断状态。
        {
            current = proc;//将当前运行的进程指针更新为传入的目标进程指针。
            lcr3(next->cr3);//修改控制寄存器 CR3，用于切换页表，确保进程切换后使用正确的地址空间。
            switch_to(&(prev->context), &(next->context));//进行上下文切换，将当前进程的上下文保存到 prev，将目标进程的上下文加载到 CPU 寄存器中，实现进程切换。
        }//源上下文的寄存器状态保存到内存中，然后将目标上下文的寄存器状态从内存中恢复，以完成上下文切换。
        local_intr_restore(intr_flag);//在执行完关键代码后，重新启用之前保存的中断状态。
    }
}
通过kernel_thread函数、proc_init函数以及具体的实现结果可知，本次实验共建立了两个内核线程。首先是`idleproc`内核线程，该线程是最初的内核线程，完成内核中各个子线程的创建以及初始化。之后循环执行调度，执行其他进程。还有一个是`initproc`内核线程，该线程主要是为了显示实验的完成而打印出字符串"hello world"的内核线程。



# 二、扩展练习

### 扩展练习 Challenge：

##### 说明语句`local_intr_save(intr_flag);....local_intr_restore(intr_flag);`是如何实现开关中断的？

`local_intr_save(intr_flag);` 和 `local_intr_restore(intr_flag);` 是一对用于开关中断的函数。这两个函数通常在一段关键代码区域的开始和结束处使用，以防止该区域的代码在执行过程中被中断。

`local_intr_save(intr_flag);` 的作用是保存当前的中断状态并关闭中断。它首先将当前的中断状态保存到 `intr_flag` 变量中，然后关闭中断。

`local_intr_restore(intr_flag);` 的作用是恢复之前保存的中断状态。它将 `intr_flag` 变量中保存的中断状态恢复到当前的中断状态。

这两个函数的实现通常依赖于特定的硬件和操作系统，因此具体的实现代码可能会有所不同。在一些系统中，可能会使用特殊的硬件指令或系统调用来实现这两个函数。
