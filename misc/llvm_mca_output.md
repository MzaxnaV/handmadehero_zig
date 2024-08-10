
<details><summary>[0] Code Region - OPS_ClearingChannel</summary>

```
Iterations:        100
Instructions:      2500
Total Cycles:      456
Total uOps:        2700

Dispatch Width:    6
uOps Per Cycle:    5.92
IPC:               5.48
Block RThroughput: 4.5


No resource or data dependency bottlenecks discovered.


```

<details><summary>Instruction Info:</summary>

```
[1]: #uOps
[2]: Latency
[3]: RThroughput
[4]: MayLoad
[5]: MayStore
[6]: HasSideEffects (U)

[1]    [2]    [3]    [4]    [5]    [6]    Instructions:
 1      1     0.25                        test	ebx, ebx
 1      1     0.50                        je	.LBB10_13
 1      1     0.25                        cmp	ebx, 4
 1      1     0.50                        jne	.LBB10_5
 1      0     0.17                        xor	eax, eax
 1      1     0.25                        test	r14b, 1
 1      1     0.50                        jne	.LBB10_12
 1      1     0.50                        jmp	.LBB10_13
 1      1     0.25                        mov	eax, r14d
 1      1     0.25                        and	eax, -2
 1      1     0.50                        lea	rcx, [r14 - 2]
 1      1     0.25                        mov	edx, 16
 1      1     0.25                        cmp	rcx, 2
 1      1     0.50                        jae	.LBB10_6
 1      1     0.25                        test	cl, 2
 1      1     0.50                        je	.LBB10_10
 1      1     0.25                        test	r14b, 1
 1      1     0.50                        je	.LBB10_13
 1      1     0.50                        shl	rax, 4
 1      0     0.17                        vxorps	xmm1, xmm1, xmm1
 2      1     0.50           *            vmovaps	xmmword ptr [r15 + rax], xmm1
 2      1     0.50           *            vmovaps	xmmword ptr [rdi + rax], xmm1
 1      1     0.50           *            mov	dword ptr [rsp + 48], ebx
 1      1     0.50           *            mov	qword ptr [rsp + 96], r11
 1      1     0.50           *            mov	qword ptr [rsp + 112], r10


```
</details>

<details><summary>Dynamic Dispatch Stall Cycles:</summary>

```
RAT     - Register unavailable:                      0
RCU     - Retire tokens unavailable:                 0
SCHEDQ  - Scheduler full:                            0
LQ      - Load queue full:                           0
SQ      - Store queue full:                          0
GROUP   - Static restrictions on the dispatch group: 0
USH     - Uncategorised Structural Hazard:           0


```
</details>

<details><summary>Dispatch Logic - number of cycles where we saw N micro opcodes dispatched:</summary>

```
[# dispatched], [# cycles]
 0,              5  (1.1%)
 2,              1  (0.2%)
 5,              2  (0.4%)
 6,              448  (98.2%)


```
</details>

<details><summary>Schedulers - number of cycles where we saw N micro opcodes issued:</summary>

```
[# issued], [# cycles]
 0,          2  (0.4%)
 1,          2  (0.4%)
 3,          3  (0.7%)
 4,          100  (21.9%)
 5,          102  (22.4%)
 6,          98  (21.5%)
 7,          50  (11.0%)
 8,          50  (11.0%)
 9,          49  (10.7%)

```
</details>

<details><summary>Scheduler's queue usage:</summary>

```
[1] Resource name.
[2] Average number of used buffer entries.
[3] Maximum number of used buffer entries.
[4] Total number of buffer entries.

 [1]            [2]        [3]        [4]
ICXPortAny       11         15         60


```
</details>

<details><summary>Retire Control Unit - number of cycles where we saw N instructions retired:</summary>

```
[# retired], [# cycles]
 0,           3  (0.7%)
 1,           3  (0.7%)
 2,           102  (22.4%)
 3,           50  (11.0%)
 4,           99  (21.7%)
 5,           2  (0.4%)
 6,           49  (10.7%)
 7,           49  (10.7%)
 8,           48  (10.5%)
 14,          50  (11.0%)
 16,          1  (0.2%)

```
</details>

<details><summary>Total ROB Entries:                352</summary>

```
Max Used ROB Entries:             39  ( 11.1% )
Average Used ROB Entries per cy:  30  ( 8.5% )


```
</details>

<details><summary>Register File statistics:</summary>

```
Total number of mappings created:    1300
Max number of mappings used:         20


```
</details>

<details><summary>Resources:</summary>

```
[0]   - ICXDivider
[1]   - ICXFPDivider
[2]   - ICXPort0
[3]   - ICXPort1
[4]   - ICXPort2
[5]   - ICXPort3
[6]   - ICXPort4
[7]   - ICXPort5
[8]   - ICXPort6
[9]   - ICXPort7
[10]  - ICXPort8
[11]  - ICXPort9


Resource pressure per iteration:
[0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   
 -      -     4.51   4.49    -      -     2.50   4.49   4.51   2.50   2.50   2.50   

Resource pressure by instruction:
[0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   Instructions:
 -      -      -     0.50    -      -      -     0.49   0.01    -      -      -     test	ebx, ebx
 -      -     0.51    -      -      -      -      -     0.49    -      -      -     je	.LBB10_13
 -      -      -     0.49    -      -      -     0.51    -      -      -      -     cmp	ebx, 4
 -      -     0.49    -      -      -      -      -     0.51    -      -      -     jne	.LBB10_5
 -      -      -      -      -      -      -      -      -      -      -      -     xor	eax, eax
 -      -      -     0.51    -      -      -     0.49    -      -      -      -     test	r14b, 1
 -      -     0.51    -      -      -      -      -     0.49    -      -      -     jne	.LBB10_12
 -      -     0.49    -      -      -      -      -     0.51    -      -      -     jmp	.LBB10_13
 -      -      -     0.49    -      -      -     0.51    -      -      -      -     mov	eax, r14d
 -      -      -     0.49    -      -      -     0.51    -      -      -      -     and	eax, -2
 -      -      -     0.51    -      -      -     0.49    -      -      -      -     lea	rcx, [r14 - 2]
 -      -      -     0.51    -      -      -     0.49    -      -      -      -     mov	edx, 16
 -      -     0.01   0.49    -      -      -     0.50    -      -      -      -     cmp	rcx, 2
 -      -     1.00    -      -      -      -      -      -      -      -      -     jae	.LBB10_6
 -      -      -     0.50    -      -      -      -     0.50    -      -      -     test	cl, 2
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     je	.LBB10_10
 -      -     0.49    -      -      -      -     0.50   0.01    -      -      -     test	r14b, 1
 -      -     0.50    -      -      -      -      -     0.50    -      -      -     je	.LBB10_13
 -      -     0.50    -      -      -      -      -     0.50    -      -      -     shl	rax, 4
 -      -      -      -      -      -      -      -      -      -      -      -     vxorps	xmm1, xmm1, xmm1
 -      -      -      -      -      -     0.50    -      -     0.50   0.50   0.50   vmovaps	xmmword ptr [r15 + rax], xmm1
 -      -      -      -      -      -     0.50    -      -     0.50   0.50   0.50   vmovaps	xmmword ptr [rdi + rax], xmm1
 -      -      -      -      -      -     0.50    -      -     0.50   0.50   0.50   mov	dword ptr [rsp + 48], ebx
 -      -      -      -      -      -     0.50    -      -     0.50   0.50   0.50   mov	qword ptr [rsp + 96], r11
 -      -      -      -      -      -     0.50    -      -     0.50   0.50   0.50   mov	qword ptr [rsp + 112], r10


```
</details>

<details><summary>Timeline view:</summary>

```
                    0123456789          0123456789          0
Index     0123456789          0123456789          0123456789 

[0,0]     DeER .    .    .    .    .    .    .    .    .    .   test	ebx, ebx
[0,1]     D=eER.    .    .    .    .    .    .    .    .    .   je	.LBB10_13
[0,2]     DeE-R.    .    .    .    .    .    .    .    .    .   cmp	ebx, 4
[0,3]     D=eER.    .    .    .    .    .    .    .    .    .   jne	.LBB10_5
[0,4]     D---R.    .    .    .    .    .    .    .    .    .   xor	eax, eax
[0,5]     DeE-R.    .    .    .    .    .    .    .    .    .   test	r14b, 1
[0,6]     .D=eER    .    .    .    .    .    .    .    .    .   jne	.LBB10_12
[0,7]     .D=eER    .    .    .    .    .    .    .    .    .   jmp	.LBB10_13
[0,8]     .DeE-R    .    .    .    .    .    .    .    .    .   mov	eax, r14d
[0,9]     .D=eER    .    .    .    .    .    .    .    .    .   and	eax, -2
[0,10]    .DeE-R    .    .    .    .    .    .    .    .    .   lea	rcx, [r14 - 2]
[0,11]    .D=eER    .    .    .    .    .    .    .    .    .   mov	edx, 16
[0,12]    . D=eER   .    .    .    .    .    .    .    .    .   cmp	rcx, 2
[0,13]    . D==eER  .    .    .    .    .    .    .    .    .   jae	.LBB10_6
[0,14]    . D=eE-R  .    .    .    .    .    .    .    .    .   test	cl, 2
[0,15]    . D==eER  .    .    .    .    .    .    .    .    .   je	.LBB10_10
[0,16]    . D=eE-R  .    .    .    .    .    .    .    .    .   test	r14b, 1
[0,17]    . D===eER .    .    .    .    .    .    .    .    .   je	.LBB10_13
[0,18]    .  D==eER .    .    .    .    .    .    .    .    .   shl	rax, 4
[0,19]    .  D----R .    .    .    .    .    .    .    .    .   vxorps	xmm1, xmm1, xmm1
[0,20]    .  D===eER.    .    .    .    .    .    .    .    .   vmovaps	xmmword ptr [r15 + rax], xmm1
[0,21]    .  D===eER.    .    .    .    .    .    .    .    .   vmovaps	xmmword ptr [rdi + rax], xmm1
[0,22]    .   D===eER    .    .    .    .    .    .    .    .   mov	dword ptr [rsp + 48], ebx
[0,23]    .   D===eER    .    .    .    .    .    .    .    .   mov	qword ptr [rsp + 96], r11
[0,24]    .   D====eER   .    .    .    .    .    .    .    .   mov	qword ptr [rsp + 112], r10
[1,0]     .   DeE----R   .    .    .    .    .    .    .    .   test	ebx, ebx
[1,1]     .   D==eE--R   .    .    .    .    .    .    .    .   je	.LBB10_13
[1,2]     .   DeE----R   .    .    .    .    .    .    .    .   cmp	ebx, 4
[1,3]     .    D=eE--R   .    .    .    .    .    .    .    .   jne	.LBB10_5
[1,4]     .    D-----R   .    .    .    .    .    .    .    .   xor	eax, eax
[1,5]     .    DeE---R   .    .    .    .    .    .    .    .   test	r14b, 1
[1,6]     .    D==eE-R   .    .    .    .    .    .    .    .   jne	.LBB10_12
[1,7]     .    D==eE-R   .    .    .    .    .    .    .    .   jmp	.LBB10_13
[1,8]     .    DeE---R   .    .    .    .    .    .    .    .   mov	eax, r14d
[1,9]     .    .DeE--R   .    .    .    .    .    .    .    .   and	eax, -2
[1,10]    .    .DeE--R   .    .    .    .    .    .    .    .   lea	rcx, [r14 - 2]
[1,11]    .    .D=eE-R   .    .    .    .    .    .    .    .   mov	edx, 16
[1,12]    .    .D=eE-R   .    .    .    .    .    .    .    .   cmp	rcx, 2
[1,13]    .    .D==eER   .    .    .    .    .    .    .    .   jae	.LBB10_6
[1,14]    .    .D==eER   .    .    .    .    .    .    .    .   test	cl, 2
[1,15]    .    . D==eER  .    .    .    .    .    .    .    .   je	.LBB10_10
[1,16]    .    . D=eE-R  .    .    .    .    .    .    .    .   test	r14b, 1
[1,17]    .    . D===eER .    .    .    .    .    .    .    .   je	.LBB10_13
[1,18]    .    . D==eE-R .    .    .    .    .    .    .    .   shl	rax, 4
[1,19]    .    . D-----R .    .    .    .    .    .    .    .   vxorps	xmm1, xmm1, xmm1
[1,20]    .    .  D==eER .    .    .    .    .    .    .    .   vmovaps	xmmword ptr [r15 + rax], xmm1
[1,21]    .    .  D==eER .    .    .    .    .    .    .    .   vmovaps	xmmword ptr [rdi + rax], xmm1
[1,22]    .    .  D===eER.    .    .    .    .    .    .    .   mov	dword ptr [rsp + 48], ebx
[1,23]    .    .  D===eER.    .    .    .    .    .    .    .   mov	qword ptr [rsp + 96], r11
[1,24]    .    .   D===eER    .    .    .    .    .    .    .   mov	qword ptr [rsp + 112], r10
[2,0]     .    .   DeE---R    .    .    .    .    .    .    .   test	ebx, ebx
[2,1]     .    .   D=eE--R    .    .    .    .    .    .    .   je	.LBB10_13
[2,2]     .    .   DeE---R    .    .    .    .    .    .    .   cmp	ebx, 4
[2,3]     .    .   D==eE-R    .    .    .    .    .    .    .   jne	.LBB10_5
[2,4]     .    .   D-----R    .    .    .    .    .    .    .   xor	eax, eax
[2,5]     .    .    DeE--R    .    .    .    .    .    .    .   test	r14b, 1
[2,6]     .    .    D=eE-R    .    .    .    .    .    .    .   jne	.LBB10_12
[2,7]     .    .    D==eER    .    .    .    .    .    .    .   jmp	.LBB10_13
[2,8]     .    .    DeE--R    .    .    .    .    .    .    .   mov	eax, r14d
[2,9]     .    .    D=eE-R    .    .    .    .    .    .    .   and	eax, -2
[2,10]    .    .    D=eE-R    .    .    .    .    .    .    .   lea	rcx, [r14 - 2]
[2,11]    .    .    .D=eER    .    .    .    .    .    .    .   mov	edx, 16
[2,12]    .    .    .D=eER    .    .    .    .    .    .    .   cmp	rcx, 2
[2,13]    .    .    .D==eER   .    .    .    .    .    .    .   jae	.LBB10_6
[2,14]    .    .    .D=eE-R   .    .    .    .    .    .    .   test	cl, 2
[2,15]    .    .    .D==eER   .    .    .    .    .    .    .   je	.LBB10_10
[2,16]    .    .    .D==eER   .    .    .    .    .    .    .   test	r14b, 1
[2,17]    .    .    . D==eER  .    .    .    .    .    .    .   je	.LBB10_13
[2,18]    .    .    . D==eER  .    .    .    .    .    .    .   shl	rax, 4
[2,19]    .    .    . D----R  .    .    .    .    .    .    .   vxorps	xmm1, xmm1, xmm1
[2,20]    .    .    . D===eER .    .    .    .    .    .    .   vmovaps	xmmword ptr [r15 + rax], xmm1
[2,21]    .    .    .  D==eER .    .    .    .    .    .    .   vmovaps	xmmword ptr [rdi + rax], xmm1
[2,22]    .    .    .  D===eER.    .    .    .    .    .    .   mov	dword ptr [rsp + 48], ebx
[2,23]    .    .    .  D===eER.    .    .    .    .    .    .   mov	qword ptr [rsp + 96], r11
[2,24]    .    .    .  D====eER    .    .    .    .    .    .   mov	qword ptr [rsp + 112], r10
[3,0]     .    .    .  DeE----R    .    .    .    .    .    .   test	ebx, ebx
[3,1]     .    .    .   D=eE--R    .    .    .    .    .    .   je	.LBB10_13
[3,2]     .    .    .   DeE---R    .    .    .    .    .    .   cmp	ebx, 4
[3,3]     .    .    .   D=eE--R    .    .    .    .    .    .   jne	.LBB10_5
[3,4]     .    .    .   D-----R    .    .    .    .    .    .   xor	eax, eax
[3,5]     .    .    .   DeE---R    .    .    .    .    .    .   test	r14b, 1
[3,6]     .    .    .   D==eE-R    .    .    .    .    .    .   jne	.LBB10_12
[3,7]     .    .    .    D=eE-R    .    .    .    .    .    .   jmp	.LBB10_13
[3,8]     .    .    .    DeE--R    .    .    .    .    .    .   mov	eax, r14d
[3,9]     .    .    .    D=eE-R    .    .    .    .    .    .   and	eax, -2
[3,10]    .    .    .    DeE--R    .    .    .    .    .    .   lea	rcx, [r14 - 2]
[3,11]    .    .    .    D=eE-R    .    .    .    .    .    .   mov	edx, 16
[3,12]    .    .    .    D==eER    .    .    .    .    .    .   cmp	rcx, 2
[3,13]    .    .    .    .D==eER   .    .    .    .    .    .   jae	.LBB10_6
[3,14]    .    .    .    .D=eE-R   .    .    .    .    .    .   test	cl, 2
[3,15]    .    .    .    .D==eER   .    .    .    .    .    .   je	.LBB10_10
[3,16]    .    .    .    .D=eE-R   .    .    .    .    .    .   test	r14b, 1
[3,17]    .    .    .    .D===eER  .    .    .    .    .    .   je	.LBB10_13
[3,18]    .    .    .    .D=eE--R  .    .    .    .    .    .   shl	rax, 4
[3,19]    .    .    .    . D----R  .    .    .    .    .    .   vxorps	xmm1, xmm1, xmm1
[3,20]    .    .    .    . D=eE-R  .    .    .    .    .    .   vmovaps	xmmword ptr [r15 + rax], xmm1
[3,21]    .    .    .    . D=eE-R  .    .    .    .    .    .   vmovaps	xmmword ptr [rdi + rax], xmm1
[3,22]    .    .    .    . D==eER  .    .    .    .    .    .   mov	dword ptr [rsp + 48], ebx
[3,23]    .    .    .    .  D=eER  .    .    .    .    .    .   mov	qword ptr [rsp + 96], r11
[3,24]    .    .    .    .  D==eER .    .    .    .    .    .   mov	qword ptr [rsp + 112], r10
[4,0]     .    .    .    .  DeE--R .    .    .    .    .    .   test	ebx, ebx
[4,1]     .    .    .    .  D=eE-R .    .    .    .    .    .   je	.LBB10_13
[4,2]     .    .    .    .  DeE--R .    .    .    .    .    .   cmp	ebx, 4
[4,3]     .    .    .    .  D==eER .    .    .    .    .    .   jne	.LBB10_5
[4,4]     .    .    .    .   D---R .    .    .    .    .    .   xor	eax, eax
[4,5]     .    .    .    .   DeE-R .    .    .    .    .    .   test	r14b, 1
[4,6]     .    .    .    .   D=eER .    .    .    .    .    .   jne	.LBB10_12
[4,7]     .    .    .    .   D==eER.    .    .    .    .    .   jmp	.LBB10_13
[4,8]     .    .    .    .   DeE--R.    .    .    .    .    .   mov	eax, r14d
[4,9]     .    .    .    .   D=eE-R.    .    .    .    .    .   and	eax, -2
[4,10]    .    .    .    .    DeE-R.    .    .    .    .    .   lea	rcx, [r14 - 2]
[4,11]    .    .    .    .    D=eER.    .    .    .    .    .   mov	edx, 16
[4,12]    .    .    .    .    D=eER.    .    .    .    .    .   cmp	rcx, 2
[4,13]    .    .    .    .    D==eER    .    .    .    .    .   jae	.LBB10_6
[4,14]    .    .    .    .    D=eE-R    .    .    .    .    .   test	cl, 2
[4,15]    .    .    .    .    D==eER    .    .    .    .    .   je	.LBB10_10
[4,16]    .    .    .    .    .D=eER    .    .    .    .    .   test	r14b, 1
[4,17]    .    .    .    .    .D==eER   .    .    .    .    .   je	.LBB10_13
[4,18]    .    .    .    .    .D==eER   .    .    .    .    .   shl	rax, 4
[4,19]    .    .    .    .    .D----R   .    .    .    .    .   vxorps	xmm1, xmm1, xmm1
[4,20]    .    .    .    .    .D===eER  .    .    .    .    .   vmovaps	xmmword ptr [r15 + rax], xmm1
[4,21]    .    .    .    .    . D==eER  .    .    .    .    .   vmovaps	xmmword ptr [rdi + rax], xmm1
[4,22]    .    .    .    .    . D===eER .    .    .    .    .   mov	dword ptr [rsp + 48], ebx
[4,23]    .    .    .    .    . D===eER .    .    .    .    .   mov	qword ptr [rsp + 96], r11
[4,24]    .    .    .    .    . D====eER.    .    .    .    .   mov	qword ptr [rsp + 112], r10
[5,0]     .    .    .    .    . DeE----R.    .    .    .    .   test	ebx, ebx
[5,1]     .    .    .    .    .  D=eE--R.    .    .    .    .   je	.LBB10_13
[5,2]     .    .    .    .    .  DeE---R.    .    .    .    .   cmp	ebx, 4
[5,3]     .    .    .    .    .  D=eE--R.    .    .    .    .   jne	.LBB10_5
[5,4]     .    .    .    .    .  D-----R.    .    .    .    .   xor	eax, eax
[5,5]     .    .    .    .    .  DeE---R.    .    .    .    .   test	r14b, 1
[5,6]     .    .    .    .    .  D==eE-R.    .    .    .    .   jne	.LBB10_12
[5,7]     .    .    .    .    .   D=eE-R.    .    .    .    .   jmp	.LBB10_13
[5,8]     .    .    .    .    .   DeE--R.    .    .    .    .   mov	eax, r14d
[5,9]     .    .    .    .    .   D=eE-R.    .    .    .    .   and	eax, -2
[5,10]    .    .    .    .    .   DeE--R.    .    .    .    .   lea	rcx, [r14 - 2]
[5,11]    .    .    .    .    .   D=eE-R.    .    .    .    .   mov	edx, 16
[5,12]    .    .    .    .    .   D==eER.    .    .    .    .   cmp	rcx, 2
[5,13]    .    .    .    .    .    D==eER    .    .    .    .   jae	.LBB10_6
[5,14]    .    .    .    .    .    D=eE-R    .    .    .    .   test	cl, 2
[5,15]    .    .    .    .    .    D==eER    .    .    .    .   je	.LBB10_10
[5,16]    .    .    .    .    .    D=eE-R    .    .    .    .   test	r14b, 1
[5,17]    .    .    .    .    .    D===eER   .    .    .    .   je	.LBB10_13
[5,18]    .    .    .    .    .    D=eE--R   .    .    .    .   shl	rax, 4
[5,19]    .    .    .    .    .    .D----R   .    .    .    .   vxorps	xmm1, xmm1, xmm1
[5,20]    .    .    .    .    .    .D=eE-R   .    .    .    .   vmovaps	xmmword ptr [r15 + rax], xmm1
[5,21]    .    .    .    .    .    .D=eE-R   .    .    .    .   vmovaps	xmmword ptr [rdi + rax], xmm1
[5,22]    .    .    .    .    .    .D==eER   .    .    .    .   mov	dword ptr [rsp + 48], ebx
[5,23]    .    .    .    .    .    . D=eER   .    .    .    .   mov	qword ptr [rsp + 96], r11
[5,24]    .    .    .    .    .    . D==eER  .    .    .    .   mov	qword ptr [rsp + 112], r10
[6,0]     .    .    .    .    .    . DeE--R  .    .    .    .   test	ebx, ebx
[6,1]     .    .    .    .    .    . D=eE-R  .    .    .    .   je	.LBB10_13
[6,2]     .    .    .    .    .    . DeE--R  .    .    .    .   cmp	ebx, 4
[6,3]     .    .    .    .    .    . D==eER  .    .    .    .   jne	.LBB10_5
[6,4]     .    .    .    .    .    .  D---R  .    .    .    .   xor	eax, eax
[6,5]     .    .    .    .    .    .  DeE-R  .    .    .    .   test	r14b, 1
[6,6]     .    .    .    .    .    .  D=eER  .    .    .    .   jne	.LBB10_12
[6,7]     .    .    .    .    .    .  D==eER .    .    .    .   jmp	.LBB10_13
[6,8]     .    .    .    .    .    .  DeE--R .    .    .    .   mov	eax, r14d
[6,9]     .    .    .    .    .    .  D=eE-R .    .    .    .   and	eax, -2
[6,10]    .    .    .    .    .    .   DeE-R .    .    .    .   lea	rcx, [r14 - 2]
[6,11]    .    .    .    .    .    .   D=eER .    .    .    .   mov	edx, 16
[6,12]    .    .    .    .    .    .   D=eER .    .    .    .   cmp	rcx, 2
[6,13]    .    .    .    .    .    .   D==eER.    .    .    .   jae	.LBB10_6
[6,14]    .    .    .    .    .    .   D=eE-R.    .    .    .   test	cl, 2
[6,15]    .    .    .    .    .    .   D==eER.    .    .    .   je	.LBB10_10
[6,16]    .    .    .    .    .    .    D=eER.    .    .    .   test	r14b, 1
[6,17]    .    .    .    .    .    .    D==eER    .    .    .   je	.LBB10_13
[6,18]    .    .    .    .    .    .    D==eER    .    .    .   shl	rax, 4
[6,19]    .    .    .    .    .    .    D----R    .    .    .   vxorps	xmm1, xmm1, xmm1
[6,20]    .    .    .    .    .    .    D===eER   .    .    .   vmovaps	xmmword ptr [r15 + rax], xmm1
[6,21]    .    .    .    .    .    .    .D==eER   .    .    .   vmovaps	xmmword ptr [rdi + rax], xmm1
[6,22]    .    .    .    .    .    .    .D===eER  .    .    .   mov	dword ptr [rsp + 48], ebx
[6,23]    .    .    .    .    .    .    .D===eER  .    .    .   mov	qword ptr [rsp + 96], r11
[6,24]    .    .    .    .    .    .    .D====eER .    .    .   mov	qword ptr [rsp + 112], r10
[7,0]     .    .    .    .    .    .    .DeE----R .    .    .   test	ebx, ebx
[7,1]     .    .    .    .    .    .    . D=eE--R .    .    .   je	.LBB10_13
[7,2]     .    .    .    .    .    .    . DeE---R .    .    .   cmp	ebx, 4
[7,3]     .    .    .    .    .    .    . D=eE--R .    .    .   jne	.LBB10_5
[7,4]     .    .    .    .    .    .    . D-----R .    .    .   xor	eax, eax
[7,5]     .    .    .    .    .    .    . DeE---R .    .    .   test	r14b, 1
[7,6]     .    .    .    .    .    .    . D==eE-R .    .    .   jne	.LBB10_12
[7,7]     .    .    .    .    .    .    .  D=eE-R .    .    .   jmp	.LBB10_13
[7,8]     .    .    .    .    .    .    .  DeE--R .    .    .   mov	eax, r14d
[7,9]     .    .    .    .    .    .    .  D=eE-R .    .    .   and	eax, -2
[7,10]    .    .    .    .    .    .    .  DeE--R .    .    .   lea	rcx, [r14 - 2]
[7,11]    .    .    .    .    .    .    .  D=eE-R .    .    .   mov	edx, 16
[7,12]    .    .    .    .    .    .    .  D==eER .    .    .   cmp	rcx, 2
[7,13]    .    .    .    .    .    .    .   D==eER.    .    .   jae	.LBB10_6
[7,14]    .    .    .    .    .    .    .   D=eE-R.    .    .   test	cl, 2
[7,15]    .    .    .    .    .    .    .   D==eER.    .    .   je	.LBB10_10
[7,16]    .    .    .    .    .    .    .   D=eE-R.    .    .   test	r14b, 1
[7,17]    .    .    .    .    .    .    .   D===eER    .    .   je	.LBB10_13
[7,18]    .    .    .    .    .    .    .   D=eE--R    .    .   shl	rax, 4
[7,19]    .    .    .    .    .    .    .    D----R    .    .   vxorps	xmm1, xmm1, xmm1
[7,20]    .    .    .    .    .    .    .    D=eE-R    .    .   vmovaps	xmmword ptr [r15 + rax], xmm1
[7,21]    .    .    .    .    .    .    .    D=eE-R    .    .   vmovaps	xmmword ptr [rdi + rax], xmm1
[7,22]    .    .    .    .    .    .    .    D==eER    .    .   mov	dword ptr [rsp + 48], ebx
[7,23]    .    .    .    .    .    .    .    .D=eER    .    .   mov	qword ptr [rsp + 96], r11
[7,24]    .    .    .    .    .    .    .    .D==eER   .    .   mov	qword ptr [rsp + 112], r10
[8,0]     .    .    .    .    .    .    .    .DeE--R   .    .   test	ebx, ebx
[8,1]     .    .    .    .    .    .    .    .D=eE-R   .    .   je	.LBB10_13
[8,2]     .    .    .    .    .    .    .    .DeE--R   .    .   cmp	ebx, 4
[8,3]     .    .    .    .    .    .    .    .D==eER   .    .   jne	.LBB10_5
[8,4]     .    .    .    .    .    .    .    . D---R   .    .   xor	eax, eax
[8,5]     .    .    .    .    .    .    .    . DeE-R   .    .   test	r14b, 1
[8,6]     .    .    .    .    .    .    .    . D=eER   .    .   jne	.LBB10_12
[8,7]     .    .    .    .    .    .    .    . D==eER  .    .   jmp	.LBB10_13
[8,8]     .    .    .    .    .    .    .    . DeE--R  .    .   mov	eax, r14d
[8,9]     .    .    .    .    .    .    .    . D=eE-R  .    .   and	eax, -2
[8,10]    .    .    .    .    .    .    .    .  DeE-R  .    .   lea	rcx, [r14 - 2]
[8,11]    .    .    .    .    .    .    .    .  D=eER  .    .   mov	edx, 16
[8,12]    .    .    .    .    .    .    .    .  D=eER  .    .   cmp	rcx, 2
[8,13]    .    .    .    .    .    .    .    .  D==eER .    .   jae	.LBB10_6
[8,14]    .    .    .    .    .    .    .    .  D=eE-R .    .   test	cl, 2
[8,15]    .    .    .    .    .    .    .    .  D==eER .    .   je	.LBB10_10
[8,16]    .    .    .    .    .    .    .    .   D=eER .    .   test	r14b, 1
[8,17]    .    .    .    .    .    .    .    .   D==eER.    .   je	.LBB10_13
[8,18]    .    .    .    .    .    .    .    .   D==eER.    .   shl	rax, 4
[8,19]    .    .    .    .    .    .    .    .   D----R.    .   vxorps	xmm1, xmm1, xmm1
[8,20]    .    .    .    .    .    .    .    .   D===eER    .   vmovaps	xmmword ptr [r15 + rax], xmm1
[8,21]    .    .    .    .    .    .    .    .    D==eER    .   vmovaps	xmmword ptr [rdi + rax], xmm1
[8,22]    .    .    .    .    .    .    .    .    D===eER   .   mov	dword ptr [rsp + 48], ebx
[8,23]    .    .    .    .    .    .    .    .    D===eER   .   mov	qword ptr [rsp + 96], r11
[8,24]    .    .    .    .    .    .    .    .    D====eER  .   mov	qword ptr [rsp + 112], r10
[9,0]     .    .    .    .    .    .    .    .    DeE----R  .   test	ebx, ebx
[9,1]     .    .    .    .    .    .    .    .    .D=eE--R  .   je	.LBB10_13
[9,2]     .    .    .    .    .    .    .    .    .DeE---R  .   cmp	ebx, 4
[9,3]     .    .    .    .    .    .    .    .    .D=eE--R  .   jne	.LBB10_5
[9,4]     .    .    .    .    .    .    .    .    .D-----R  .   xor	eax, eax
[9,5]     .    .    .    .    .    .    .    .    .DeE---R  .   test	r14b, 1
[9,6]     .    .    .    .    .    .    .    .    .D==eE-R  .   jne	.LBB10_12
[9,7]     .    .    .    .    .    .    .    .    . D=eE-R  .   jmp	.LBB10_13
[9,8]     .    .    .    .    .    .    .    .    . DeE--R  .   mov	eax, r14d
[9,9]     .    .    .    .    .    .    .    .    . D=eE-R  .   and	eax, -2
[9,10]    .    .    .    .    .    .    .    .    . DeE--R  .   lea	rcx, [r14 - 2]
[9,11]    .    .    .    .    .    .    .    .    . D=eE-R  .   mov	edx, 16
[9,12]    .    .    .    .    .    .    .    .    . D==eER  .   cmp	rcx, 2
[9,13]    .    .    .    .    .    .    .    .    .  D==eER .   jae	.LBB10_6
[9,14]    .    .    .    .    .    .    .    .    .  D=eE-R .   test	cl, 2
[9,15]    .    .    .    .    .    .    .    .    .  D==eER .   je	.LBB10_10
[9,16]    .    .    .    .    .    .    .    .    .  D=eE-R .   test	r14b, 1
[9,17]    .    .    .    .    .    .    .    .    .  D===eER.   je	.LBB10_13
[9,18]    .    .    .    .    .    .    .    .    .  D=eE--R.   shl	rax, 4
[9,19]    .    .    .    .    .    .    .    .    .   D----R.   vxorps	xmm1, xmm1, xmm1
[9,20]    .    .    .    .    .    .    .    .    .   D=eE-R.   vmovaps	xmmword ptr [r15 + rax], xmm1
[9,21]    .    .    .    .    .    .    .    .    .   D=eE-R.   vmovaps	xmmword ptr [rdi + rax], xmm1
[9,22]    .    .    .    .    .    .    .    .    .   D==eER.   mov	dword ptr [rsp + 48], ebx
[9,23]    .    .    .    .    .    .    .    .    .    D=eER.   mov	qword ptr [rsp + 96], r11
[9,24]    .    .    .    .    .    .    .    .    .    D==eER   mov	qword ptr [rsp + 112], r10


```
</details>

<details><summary>Average Wait times (based on the timeline view):</summary>

```
[0]: Executions
[1]: Average time spent waiting in a scheduler's queue
[2]: Average time spent waiting in a scheduler's queue while ready
[3]: Average time elapsed from WB until retire stage

      [0]    [1]    [2]    [3]
0.     10    1.0    1.0    2.9       test	ebx, ebx
1.     10    2.1    0.5    1.5       je	.LBB10_13
2.     10    1.0    1.0    2.6       cmp	ebx, 4
3.     10    2.4    0.5    1.1       jne	.LBB10_5
4.     10    0.0    0.0    4.2       xor	eax, eax
5.     10    1.0    1.0    2.1       test	r14b, 1
6.     10    2.5    0.6    0.6       jne	.LBB10_12
7.     10    2.5    2.5    0.5       jmp	.LBB10_13
8.     10    1.0    1.0    2.0       mov	eax, r14d
9.     10    1.9    0.0    1.0       and	eax, -2
10.    10    1.1    1.1    1.5       lea	rcx, [r14 - 2]
11.    10    2.0    2.0    0.5       mov	edx, 16
12.    10    2.4    0.5    0.1       cmp	rcx, 2
13.    10    3.0    0.0    0.0       jae	.LBB10_6
14.    10    2.1    0.6    0.9       test	cl, 2
15.    10    3.0    0.0    0.0       je	.LBB10_10
16.    10    2.1    2.1    0.6       test	r14b, 1
17.    10    3.6    0.6    0.0       je	.LBB10_13
18.    10    2.6    1.2    0.9       shl	rax, 4
19.    10    0.0    0.0    4.1       vxorps	xmm1, xmm1, xmm1
20.    10    3.1    0.0    0.4       vmovaps	xmmword ptr [r15 + rax], xmm1
21.    10    2.7    0.0    0.4       vmovaps	xmmword ptr [rdi + rax], xmm1
22.    10    3.6    1.0    0.0       mov	dword ptr [rsp + 48], ebx
23.    10    3.2    0.0    0.0       mov	qword ptr [rsp + 96], r11
24.    10    4.1    1.0    0.0       mov	qword ptr [rsp + 112], r10
       10    2.2    0.7    1.1       <total>


```
</details>

</details>

<details><summary>[1] Code Region - OPS_Mixing</summary>

```
Iterations:        100
Instructions:      2600
Total Cycles:      613
Total uOps:        2700

Dispatch Width:    6
uOps Per Cycle:    4.40
IPC:               4.24
Block RThroughput: 6.0


Cycles with backend pressure increase [ 93.80% ]
Throughput Bottlenecks: 
  Resource Pressure       [ 93.64% ]
  - ICXPort2  [ 93.64% ]
  - ICXPort3  [ 93.64% ]
  Data Dependencies:      [ 93.80% ]
  - Register Dependencies [ 93.80% ]
  - Memory Dependencies   [ 0.00% ]

```

<details><summary>Critical sequence based on the simulation:</summary>

```

              Instruction                                 Dependency Information
 +----< 19.   vbroadcastss	xmm14, dword ptr [rip + .LCPI10_0]
 |
 |    < loop carried > 
 |
 +----> 0.    mov	rax, qword ptr [rsp + 56]         ## RESOURCE interference:  ICXPort3 [ probability: 98% ]
 |      1.    mov	rbx, qword ptr [rax + 96]
 |      2.    test	rbx, rbx
 |      3.    je	.LBB10_41
 +----> 4.    cmp	dword ptr [rsp + 48], 0           ## RESOURCE interference:  ICXPort2 [ probability: 99% ]
 |      5.    je	.LBB10_39
 +----> 6.    vmovss	xmm1, dword ptr [rip + .LCPI10_0] ## RESOURCE interference:  ICXPort3 [ probability: 99% ]
 |      7.    vdivss	xmm6, xmm1, xmm0
 +----> 8.    mov	rax, qword ptr [rsp + 56]         ## RESOURCE interference:  ICXPort2 [ probability: 99% ]
 |      9.    lea	rdx, [rax + 96]
 |      10.   lea	rax, [rsi + 40]
 |      11.   mov	qword ptr [rsp + 128], rax
 |      12.   mov	r13d, 1
 +----> 13.   vmovss	xmm7, dword ptr [rip + .LCPI10_1] ## RESOURCE interference:  ICXPort3 [ probability: 99% ]
 |      14.   vxorps	xmm8, xmm8, xmm8
 +----> 15.   vmovddup	xmm9, qword ptr [rip + .LCPI10_2] ## RESOURCE interference:  ICXPort2 [ probability: 99% ]
 +----> 16.   vpbroadcastd	xmm10, dword ptr [rip + .LCPI10_3] ## RESOURCE interference:  ICXPort3 [ probability: 99% ]
 +----> 17.   vpbroadcastd	xmm11, dword ptr [rip + .LCPI10_4] ## RESOURCE interference:  ICXPort2 [ probability: 99% ]
 +----> 18.   vmovss	xmm12, dword ptr [rip + .LCPI10_5] ## RESOURCE interference:  ICXPort2 [ probability: 99% ]
 +----> 19.   vbroadcastss	xmm14, dword ptr [rip + .LCPI10_0] ## RESOURCE interference:  ICXPort2 [ probability: 98% ]
 |      20.   mov	qword ptr [rsp + 64], r14
 |      21.   jmp	.LBB10_16
 |      22.   mov	rbx, qword ptr [rbx]
 |      23.   test	rbx, rbx
 |      24.   jne	.LBB10_39
 |      25.   mov	byte ptr [rsp + 47], 0
 |
 |    < loop carried > 
 |
 +----> 4.    cmp	dword ptr [rsp + 48], 0           ## RESOURCE interference:  ICXPort3 [ probability: 98% ]


```
</details>

<details><summary>Instruction Info:</summary>

```
[1]: #uOps
[2]: Latency
[3]: RThroughput
[4]: MayLoad
[5]: MayStore
[6]: HasSideEffects (U)

[1]    [2]    [3]    [4]    [5]    [6]    Instructions:
 1      5     0.50    *                   mov	rax, qword ptr [rsp + 56]
 1      5     0.50    *                   mov	rbx, qword ptr [rax + 96]
 1      1     0.25                        test	rbx, rbx
 1      1     0.50                        je	.LBB10_41
 2      6     0.50    *                   cmp	dword ptr [rsp + 48], 0
 1      1     0.50                        je	.LBB10_39
 1      5     0.50    *                   vmovss	xmm1, dword ptr [rip + .LCPI10_0]
 1      11    3.00                        vdivss	xmm6, xmm1, xmm0
 1      5     0.50    *                   mov	rax, qword ptr [rsp + 56]
 1      1     0.50                        lea	rdx, [rax + 96]
 1      1     0.50                        lea	rax, [rsi + 40]
 1      1     0.50           *            mov	qword ptr [rsp + 128], rax
 1      1     0.25                        mov	r13d, 1
 1      5     0.50    *                   vmovss	xmm7, dword ptr [rip + .LCPI10_1]
 1      0     0.17                        vxorps	xmm8, xmm8, xmm8
 1      6     0.50    *                   vmovddup	xmm9, qword ptr [rip + .LCPI10_2]
 1      6     0.50    *                   vpbroadcastd	xmm10, dword ptr [rip + .LCPI10_3]
 1      6     0.50    *                   vpbroadcastd	xmm11, dword ptr [rip + .LCPI10_4]
 1      5     0.50    *                   vmovss	xmm12, dword ptr [rip + .LCPI10_5]
 1      6     0.50    *                   vbroadcastss	xmm14, dword ptr [rip + .LCPI10_0]
 1      1     0.50           *            mov	qword ptr [rsp + 64], r14
 1      1     0.50                        jmp	.LBB10_16
 1      5     0.50    *                   mov	rbx, qword ptr [rbx]
 1      1     0.25                        test	rbx, rbx
 1      1     0.50                        jne	.LBB10_39
 1      1     0.50           *            mov	byte ptr [rsp + 47], 0


```
</details>

<details><summary>Dynamic Dispatch Stall Cycles:</summary>

```
RAT     - Register unavailable:                      0
RCU     - Retire tokens unavailable:                 0
SCHEDQ  - Scheduler full:                            549  (89.6%)
LQ      - Load queue full:                           0
SQ      - Store queue full:                          0
GROUP   - Static restrictions on the dispatch group: 0
USH     - Uncategorised Structural Hazard:           0


```
</details>

<details><summary>Dispatch Logic - number of cycles where we saw N micro opcodes dispatched:</summary>

```
[# dispatched], [# cycles]
 0,              25  (4.1%)
 2,              1  (0.2%)
 4,              275  (44.9%)
 5,              274  (44.7%)
 6,              38  (6.2%)


```
</details>

<details><summary>Schedulers - number of cycles where we saw N micro opcodes issued:</summary>

```
[# issued], [# cycles]
 0,          7  (1.1%)
 1,          4  (0.7%)
 2,          8  (1.3%)
 3,          9  (1.5%)
 4,          289  (47.1%)
 5,          286  (46.7%)
 6,          5  (0.8%)
 7,          3  (0.5%)
 8,          2  (0.3%)

```
</details>

<details><summary>Scheduler's queue usage:</summary>

```
[1] Resource name.
[2] Average number of used buffer entries.
[3] Maximum number of used buffer entries.
[4] Total number of buffer entries.

 [1]            [2]        [3]        [4]
ICXPortAny       56         60         60


```
</details>

<details><summary>Retire Control Unit - number of cycles where we saw N instructions retired:</summary>

```
[# retired], [# cycles]
 0,           411  (67.0%)
 1,           3  (0.5%)
 4,           99  (16.2%)
 19,          1  (0.2%)
 22,          98  (16.0%)
 26,          1  (0.2%)

```
</details>

<details><summary>Total ROB Entries:                352</summary>

```
Max Used ROB Entries:             130  ( 36.9% )
Average Used ROB Entries per cy:  114  ( 32.4% )


```
</details>

<details><summary>Register File statistics:</summary>

```
Total number of mappings created:    1800
Max number of mappings used:         88


```
</details>

<details><summary>Resources:</summary>

```
[0]   - ICXDivider
[1]   - ICXFPDivider
[2]   - ICXPort0
[3]   - ICXPort1
[4]   - ICXPort2
[5]   - ICXPort3
[6]   - ICXPort4
[7]   - ICXPort5
[8]   - ICXPort6
[9]   - ICXPort7
[10]  - ICXPort8
[11]  - ICXPort9


Resource pressure per iteration:
[0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   
 -     3.00   3.47   2.03   6.00   6.00   1.50   2.04   3.46   1.50   1.50   1.50   

Resource pressure by instruction:
[0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   Instructions:
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     mov	rax, qword ptr [rsp + 56]
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	rbx, qword ptr [rax + 96]
 -      -     0.01   0.02    -      -      -     0.97    -      -      -      -     test	rbx, rbx
 -      -     0.49    -      -      -      -      -     0.51    -      -      -     je	.LBB10_41
 -      -      -     0.03   0.01   0.99    -     0.96   0.01    -      -      -     cmp	dword ptr [rsp + 48], 0
 -      -      -      -      -      -      -      -     1.00    -      -      -     je	.LBB10_39
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     vmovss	xmm1, dword ptr [rip + .LCPI10_0]
 -     3.00   1.00    -      -      -      -      -      -      -      -      -     vdivss	xmm6, xmm1, xmm0
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	rax, qword ptr [rsp + 56]
 -      -      -     0.97    -      -      -     0.03    -      -      -      -     lea	rdx, [rax + 96]
 -      -      -     0.96    -      -      -     0.04    -      -      -      -     lea	rax, [rsi + 40]
 -      -      -      -      -      -     0.50    -      -     0.50   0.50   0.50   mov	qword ptr [rsp + 128], rax
 -      -     0.04   0.02    -      -      -     0.01   0.93    -      -      -     mov	r13d, 1
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     vmovss	xmm7, dword ptr [rip + .LCPI10_1]
 -      -      -      -      -      -      -      -      -      -      -      -     vxorps	xmm8, xmm8, xmm8
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     vmovddup	xmm9, qword ptr [rip + .LCPI10_2]
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     vpbroadcastd	xmm10, dword ptr [rip + .LCPI10_3]
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     vpbroadcastd	xmm11, dword ptr [rip + .LCPI10_4]
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     vmovss	xmm12, dword ptr [rip + .LCPI10_5]
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     vbroadcastss	xmm14, dword ptr [rip + .LCPI10_0]
 -      -      -      -      -      -     0.50    -      -     0.50   0.50   0.50   mov	qword ptr [rsp + 64], r14
 -      -     0.52    -      -      -      -      -     0.48    -      -      -     jmp	.LBB10_16
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	rbx, qword ptr [rbx]
 -      -     0.91   0.03    -      -      -     0.03   0.03    -      -      -     test	rbx, rbx
 -      -     0.50    -      -      -      -      -     0.50    -      -      -     jne	.LBB10_39
 -      -      -      -      -      -     0.50    -      -     0.50   0.50   0.50   mov	byte ptr [rsp + 47], 0


```
</details>

<details><summary>Timeline view:</summary>

```
                    0123456789          0123456789          0123456789          012
Index     0123456789          0123456789          0123456789          0123456789   

[0,0]     DeeeeeER  .    .    .    .    .    .    .    .    .    .    .    .    . .   mov	rax, qword ptr [rsp + 56]
[0,1]     D=====eeeeeER  .    .    .    .    .    .    .    .    .    .    .    . .   mov	rbx, qword ptr [rax + 96]
[0,2]     D==========eER .    .    .    .    .    .    .    .    .    .    .    . .   test	rbx, rbx
[0,3]     D===========eER.    .    .    .    .    .    .    .    .    .    .    . .   je	.LBB10_41
[0,4]     DeeeeeeE------R.    .    .    .    .    .    .    .    .    .    .    . .   cmp	dword ptr [rsp + 48], 0
[0,5]     .D=====eE-----R.    .    .    .    .    .    .    .    .    .    .    . .   je	.LBB10_39
[0,6]     .DeeeeeE------R.    .    .    .    .    .    .    .    .    .    .    . .   vmovss	xmm1, dword ptr [rip + .LCPI10_0]
[0,7]     .D=====eeeeeeeeeeeER.    .    .    .    .    .    .    .    .    .    . .   vdivss	xmm6, xmm1, xmm0
[0,8]     .DeeeeeE-----------R.    .    .    .    .    .    .    .    .    .    . .   mov	rax, qword ptr [rsp + 56]
[0,9]     .D=====eE----------R.    .    .    .    .    .    .    .    .    .    . .   lea	rdx, [rax + 96]
[0,10]    .DeE---------------R.    .    .    .    .    .    .    .    .    .    . .   lea	rax, [rsi + 40]
[0,11]    . D===eE-----------R.    .    .    .    .    .    .    .    .    .    . .   mov	qword ptr [rsp + 128], rax
[0,12]    . DeE--------------R.    .    .    .    .    .    .    .    .    .    . .   mov	r13d, 1
[0,13]    . DeeeeeE----------R.    .    .    .    .    .    .    .    .    .    . .   vmovss	xmm7, dword ptr [rip + .LCPI10_1]
[0,14]    . D----------------R.    .    .    .    .    .    .    .    .    .    . .   vxorps	xmm8, xmm8, xmm8
[0,15]    . DeeeeeeE---------R.    .    .    .    .    .    .    .    .    .    . .   vmovddup	xmm9, qword ptr [rip + .LCPI10_2]
[0,16]    . D=eeeeeeE--------R.    .    .    .    .    .    .    .    .    .    . .   vpbroadcastd	xmm10, dword ptr [rip + .LCPI10_3]
[0,17]    .  DeeeeeeE--------R.    .    .    .    .    .    .    .    .    .    . .   vpbroadcastd	xmm11, dword ptr [rip + .LCPI10_4]
[0,18]    .  D=eeeeeE--------R.    .    .    .    .    .    .    .    .    .    . .   vmovss	xmm12, dword ptr [rip + .LCPI10_5]
[0,19]    .  D=eeeeeeE-------R.    .    .    .    .    .    .    .    .    .    . .   vbroadcastss	xmm14, dword ptr [rip + .LCPI10_0]
[0,20]    .  D==eE-----------R.    .    .    .    .    .    .    .    .    .    . .   mov	qword ptr [rsp + 64], r14
[0,21]    .  DeE-------------R.    .    .    .    .    .    .    .    .    .    . .   jmp	.LBB10_16
[0,22]    .  D=======eeeeeE--R.    .    .    .    .    .    .    .    .    .    . .   mov	rbx, qword ptr [rbx]
[0,23]    .   D===========eE-R.    .    .    .    .    .    .    .    .    .    . .   test	rbx, rbx
[0,24]    .   D============eER.    .    .    .    .    .    .    .    .    .    . .   jne	.LBB10_39
[0,25]    .   D======eE------R.    .    .    .    .    .    .    .    .    .    . .   mov	byte ptr [rsp + 47], 0
[1,0]     .   D=eeeeeE-------R.    .    .    .    .    .    .    .    .    .    . .   mov	rax, qword ptr [rsp + 56]
[1,1]     .   D======eeeeeE--R.    .    .    .    .    .    .    .    .    .    . .   mov	rbx, qword ptr [rax + 96]
[1,2]     .   D===========eE-R.    .    .    .    .    .    .    .    .    .    . .   test	rbx, rbx
[1,3]     .    D===========eER.    .    .    .    .    .    .    .    .    .    . .   je	.LBB10_41
[1,4]     .    D=eeeeeeE-----R.    .    .    .    .    .    .    .    .    .    . .   cmp	dword ptr [rsp + 48], 0
[1,5]     .    D=======eE----R.    .    .    .    .    .    .    .    .    .    . .   je	.LBB10_39
[1,6]     .    D=eeeeeE------R.    .    .    .    .    .    .    .    .    .    . .   vmovss	xmm1, dword ptr [rip + .LCPI10_0]
[1,7]     .    D======eeeeeeeeeeeER.    .    .    .    .    .    .    .    .    . .   vdivss	xmm6, xmm1, xmm0
[1,8]     .    .D=eeeeeE----------R.    .    .    .    .    .    .    .    .    . .   mov	rax, qword ptr [rsp + 56]
[1,9]     .    .D======eE---------R.    .    .    .    .    .    .    .    .    . .   lea	rdx, [rax + 96]
[1,10]    .    .D=eE--------------R.    .    .    .    .    .    .    .    .    . .   lea	rax, [rsi + 40]
[1,11]    .    .D====eE-----------R.    .    .    .    .    .    .    .    .    . .   mov	qword ptr [rsp + 128], rax
[1,12]    .    .D=eE--------------R.    .    .    .    .    .    .    .    .    . .   mov	r13d, 1
[1,13]    .    .D=eeeeeE----------R.    .    .    .    .    .    .    .    .    . .   vmovss	xmm7, dword ptr [rip + .LCPI10_1]
[1,14]    .    . D----------------R.    .    .    .    .    .    .    .    .    . .   vxorps	xmm8, xmm8, xmm8
[1,15]    .    . D=eeeeeeE--------R.    .    .    .    .    .    .    .    .    . .   vmovddup	xmm9, qword ptr [rip + .LCPI10_2]
[1,16]    .    . D=eeeeeeE--------R.    .    .    .    .    .    .    .    .    . .   vpbroadcastd	xmm10, dword ptr [rip + .LCPI10_3]
[1,17]    .    . D==eeeeeeE-------R.    .    .    .    .    .    .    .    .    . .   vpbroadcastd	xmm11, dword ptr [rip + .LCPI10_4]
[1,18]    .    . D==eeeeeE--------R.    .    .    .    .    .    .    .    .    . .   vmovss	xmm12, dword ptr [rip + .LCPI10_5]
[1,19]    .    . D====eeeeeeE-----R.    .    .    .    .    .    .    .    .    . .   vbroadcastss	xmm14, dword ptr [rip + .LCPI10_0]
[1,20]    .    .  D===eE----------R.    .    .    .    .    .    .    .    .    . .   mov	qword ptr [rsp + 64], r14
[1,21]    .    .  DeE-------------R.    .    .    .    .    .    .    .    .    . .   jmp	.LBB10_16
[1,22]    .    .  D=======eeeeeE--R.    .    .    .    .    .    .    .    .    . .   mov	rbx, qword ptr [rbx]
[1,23]    .    .  D============eE-R.    .    .    .    .    .    .    .    .    . .   test	rbx, rbx
[1,24]    .    .  D=============eER.    .    .    .    .    .    .    .    .    . .   jne	.LBB10_39
[1,25]    .    .  D=======eE------R.    .    .    .    .    .    .    .    .    . .   mov	byte ptr [rsp + 47], 0
[2,0]     .    .   D==eeeeeE------R.    .    .    .    .    .    .    .    .    . .   mov	rax, qword ptr [rsp + 56]
[2,1]     .    .   D=======eeeeeE-R.    .    .    .    .    .    .    .    .    . .   mov	rbx, qword ptr [rax + 96]
[2,2]     .    .   D============eER.    .    .    .    .    .    .    .    .    . .   test	rbx, rbx
[2,3]     .    .   D=============eER    .    .    .    .    .    .    .    .    . .   je	.LBB10_41
[2,4]     .    .   D===eeeeeeE-----R    .    .    .    .    .    .    .    .    . .   cmp	dword ptr [rsp + 48], 0
[2,5]     .    .    D========eE----R    .    .    .    .    .    .    .    .    . .   je	.LBB10_39
[2,6]     .    .    D==eeeeeE------R    .    .    .    .    .    .    .    .    . .   vmovss	xmm1, dword ptr [rip + .LCPI10_0]
[2,7]     .    .    D=======eeeeeeeeeeeER    .    .    .    .    .    .    .    . .   vdivss	xmm6, xmm1, xmm0
[2,8]     .    .    D===eeeeeE----------R    .    .    .    .    .    .    .    . .   mov	rax, qword ptr [rsp + 56]
[2,9]     .    .    D========eE---------R    .    .    .    .    .    .    .    . .   lea	rdx, [rax + 96]
[2,10]    .    .    DeE-----------------R    .    .    .    .    .    .    .    . .   lea	rax, [rsi + 40]
[2,11]    .    .    .D=====eE-----------R    .    .    .    .    .    .    .    . .   mov	qword ptr [rsp + 128], rax
[2,12]    .    .    .DeE----------------R    .    .    .    .    .    .    .    . .   mov	r13d, 1
[2,13]    .    .    .D==eeeeeE----------R    .    .    .    .    .    .    .    . .   vmovss	xmm7, dword ptr [rip + .LCPI10_1]
[2,14]    .    .    .D------------------R    .    .    .    .    .    .    .    . .   vxorps	xmm8, xmm8, xmm8
[2,15]    .    .    .D===eeeeeeE--------R    .    .    .    .    .    .    .    . .   vmovddup	xmm9, qword ptr [rip + .LCPI10_2]
[2,16]    .    .    .D===eeeeeeE--------R    .    .    .    .    .    .    .    . .   vpbroadcastd	xmm10, dword ptr [rip + .LCPI10_3]
[2,17]    .    .    . D===eeeeeeE-------R    .    .    .    .    .    .    .    . .   vpbroadcastd	xmm11, dword ptr [rip + .LCPI10_4]
[2,18]    .    .    . D====eeeeeE-------R    .    .    .    .    .    .    .    . .   vmovss	xmm12, dword ptr [rip + .LCPI10_5]
[2,19]    .    .    . D=====eeeeeeE-----R    .    .    .    .    .    .    .    . .   vbroadcastss	xmm14, dword ptr [rip + .LCPI10_0]
[2,20]    .    .    . D=====eE----------R    .    .    .    .    .    .    .    . .   mov	qword ptr [rsp + 64], r14
[2,21]    .    .    . DeE---------------R    .    .    .    .    .    .    .    . .   jmp	.LBB10_16
[2,22]    .    .    . D=========eeeeeE--R    .    .    .    .    .    .    .    . .   mov	rbx, qword ptr [rbx]
[2,23]    .    .    .  D=============eE-R    .    .    .    .    .    .    .    . .   test	rbx, rbx
[2,24]    .    .    .  D==============eER    .    .    .    .    .    .    .    . .   jne	.LBB10_39
[2,25]    .    .    .  D========eE------R    .    .    .    .    .    .    .    . .   mov	byte ptr [rsp + 47], 0
[3,0]     .    .    .  D====eeeeeE------R    .    .    .    .    .    .    .    . .   mov	rax, qword ptr [rsp + 56]
[3,1]     .    .    .  D=========eeeeeE-R    .    .    .    .    .    .    .    . .   mov	rbx, qword ptr [rax + 96]
[3,2]     .    .    .  D==============eER    .    .    .    .    .    .    .    . .   test	rbx, rbx
[3,3]     .    .    .   D==============eER   .    .    .    .    .    .    .    . .   je	.LBB10_41
[3,4]     .    .    .   D====eeeeeeE-----R   .    .    .    .    .    .    .    . .   cmp	dword ptr [rsp + 48], 0
[3,5]     .    .    .   D==========eE----R   .    .    .    .    .    .    .    . .   je	.LBB10_39
[3,6]     .    .    .   D====eeeeeE------R   .    .    .    .    .    .    .    . .   vmovss	xmm1, dword ptr [rip + .LCPI10_0]
[3,7]     .    .    .   D=========eeeeeeeeeeeER   .    .    .    .    .    .    . .   vdivss	xmm6, xmm1, xmm0
[3,8]     .    .    .    D====eeeeeE----------R   .    .    .    .    .    .    . .   mov	rax, qword ptr [rsp + 56]
[3,9]     .    .    .    D=========eE---------R   .    .    .    .    .    .    . .   lea	rdx, [rax + 96]
[3,10]    .    .    .    DeE------------------R   .    .    .    .    .    .    . .   lea	rax, [rsi + 40]
[3,11]    .    .    .    D=======eE-----------R   .    .    .    .    .    .    . .   mov	qword ptr [rsp + 128], rax
[3,12]    .    .    .    DeE------------------R   .    .    .    .    .    .    . .   mov	r13d, 1
[3,13]    .    .    .    D====eeeeeE----------R   .    .    .    .    .    .    . .   vmovss	xmm7, dword ptr [rip + .LCPI10_1]
[3,14]    .    .    .    .D-------------------R   .    .    .    .    .    .    . .   vxorps	xmm8, xmm8, xmm8
[3,15]    .    .    .    .D====eeeeeeE--------R   .    .    .    .    .    .    . .   vmovddup	xmm9, qword ptr [rip + .LCPI10_2]
[3,16]    .    .    .    .D====eeeeeeE--------R   .    .    .    .    .    .    . .   vpbroadcastd	xmm10, dword ptr [rip + .LCPI10_3]
[3,17]    .    .    .    .D=====eeeeeeE-------R   .    .    .    .    .    .    . .   vpbroadcastd	xmm11, dword ptr [rip + .LCPI10_4]
[3,18]    .    .    .    .D======eeeeeE-------R   .    .    .    .    .    .    . .   vmovss	xmm12, dword ptr [rip + .LCPI10_5]
[3,19]    .    .    .    .D=======eeeeeeE-----R   .    .    .    .    .    .    . .   vbroadcastss	xmm14, dword ptr [rip + .LCPI10_0]
[3,20]    .    .    .    . D======eE----------R   .    .    .    .    .    .    . .   mov	qword ptr [rsp + 64], r14
[3,21]    .    .    .    . DeE----------------R   .    .    .    .    .    .    . .   jmp	.LBB10_16
[3,22]    .    .    .    . D==========eeeeeE--R   .    .    .    .    .    .    . .   mov	rbx, qword ptr [rbx]
[3,23]    .    .    .    . D===============eE-R   .    .    .    .    .    .    . .   test	rbx, rbx
[3,24]    .    .    .    . D================eER   .    .    .    .    .    .    . .   jne	.LBB10_39
[3,25]    .    .    .    . D==========eE------R   .    .    .    .    .    .    . .   mov	byte ptr [rsp + 47], 0
[4,0]     .    .    .    .  D=====eeeeeE------R   .    .    .    .    .    .    . .   mov	rax, qword ptr [rsp + 56]
[4,1]     .    .    .    .  D==========eeeeeE-R   .    .    .    .    .    .    . .   mov	rbx, qword ptr [rax + 96]
[4,2]     .    .    .    .  D===============eER   .    .    .    .    .    .    . .   test	rbx, rbx
[4,3]     .    .    .    .  D================eER  .    .    .    .    .    .    . .   je	.LBB10_41
[4,4]     .    .    .    .  D======eeeeeeE-----R  .    .    .    .    .    .    . .   cmp	dword ptr [rsp + 48], 0
[4,5]     .    .    .    .   D===========eE----R  .    .    .    .    .    .    . .   je	.LBB10_39
[4,6]     .    .    .    .   D=====eeeeeE------R  .    .    .    .    .    .    . .   vmovss	xmm1, dword ptr [rip + .LCPI10_0]
[4,7]     .    .    .    .   D==========eeeeeeeeeeeER  .    .    .    .    .    . .   vdivss	xmm6, xmm1, xmm0
[4,8]     .    .    .    .   D======eeeeeE----------R  .    .    .    .    .    . .   mov	rax, qword ptr [rsp + 56]
[4,9]     .    .    .    .   D===========eE---------R  .    .    .    .    .    . .   lea	rdx, [rax + 96]
[4,10]    .    .    .    .   DeE--------------------R  .    .    .    .    .    . .   lea	rax, [rsi + 40]
[4,11]    .    .    .    .    D========eE-----------R  .    .    .    .    .    . .   mov	qword ptr [rsp + 128], rax
[4,12]    .    .    .    .    DeE-------------------R  .    .    .    .    .    . .   mov	r13d, 1
[4,13]    .    .    .    .    D=====eeeeeE----------R  .    .    .    .    .    . .   vmovss	xmm7, dword ptr [rip + .LCPI10_1]
[4,14]    .    .    .    .    D---------------------R  .    .    .    .    .    . .   vxorps	xmm8, xmm8, xmm8
[4,15]    .    .    .    .    D======eeeeeeE--------R  .    .    .    .    .    . .   vmovddup	xmm9, qword ptr [rip + .LCPI10_2]
[4,16]    .    .    .    .    D======eeeeeeE--------R  .    .    .    .    .    . .   vpbroadcastd	xmm10, dword ptr [rip + .LCPI10_3]
[4,17]    .    .    .    .    .D======eeeeeeE-------R  .    .    .    .    .    . .   vpbroadcastd	xmm11, dword ptr [rip + .LCPI10_4]
[4,18]    .    .    .    .    .D=======eeeeeE-------R  .    .    .    .    .    . .   vmovss	xmm12, dword ptr [rip + .LCPI10_5]
[4,19]    .    .    .    .    .D========eeeeeeE-----R  .    .    .    .    .    . .   vbroadcastss	xmm14, dword ptr [rip + .LCPI10_0]
[4,20]    .    .    .    .    .D========eE----------R  .    .    .    .    .    . .   mov	qword ptr [rsp + 64], r14
[4,21]    .    .    .    .    .DeE------------------R  .    .    .    .    .    . .   jmp	.LBB10_16
[4,22]    .    .    .    .    .D============eeeeeE--R  .    .    .    .    .    . .   mov	rbx, qword ptr [rbx]
[4,23]    .    .    .    .    . D================eE-R  .    .    .    .    .    . .   test	rbx, rbx
[4,24]    .    .    .    .    . D=================eER  .    .    .    .    .    . .   jne	.LBB10_39
[4,25]    .    .    .    .    . D===========eE------R  .    .    .    .    .    . .   mov	byte ptr [rsp + 47], 0
[5,0]     .    .    .    .    . D=======eeeeeE------R  .    .    .    .    .    . .   mov	rax, qword ptr [rsp + 56]
[5,1]     .    .    .    .    . D============eeeeeE-R  .    .    .    .    .    . .   mov	rbx, qword ptr [rax + 96]
[5,2]     .    .    .    .    . D=================eER  .    .    .    .    .    . .   test	rbx, rbx
[5,3]     .    .    .    .    .  D=================eER .    .    .    .    .    . .   je	.LBB10_41
[5,4]     .    .    .    .    .  D=======eeeeeeE-----R .    .    .    .    .    . .   cmp	dword ptr [rsp + 48], 0
[5,5]     .    .    .    .    .  D=============eE----R .    .    .    .    .    . .   je	.LBB10_39
[5,6]     .    .    .    .    .  D=======eeeeeE------R .    .    .    .    .    . .   vmovss	xmm1, dword ptr [rip + .LCPI10_0]
[5,7]     .    .    .    .    .  D============eeeeeeeeeeeER .    .    .    .    . .   vdivss	xmm6, xmm1, xmm0
[5,8]     .    .    .    .    .   D=======eeeeeE----------R .    .    .    .    . .   mov	rax, qword ptr [rsp + 56]
[5,9]     .    .    .    .    .   D============eE---------R .    .    .    .    . .   lea	rdx, [rax + 96]
[5,10]    .    .    .    .    .   D=eE--------------------R .    .    .    .    . .   lea	rax, [rsi + 40]
[5,11]    .    .    .    .    .   D==========eE-----------R .    .    .    .    . .   mov	qword ptr [rsp + 128], rax
[5,12]    .    .    .    .    .   DeE---------------------R .    .    .    .    . .   mov	r13d, 1
[5,13]    .    .    .    .    .   D=======eeeeeE----------R .    .    .    .    . .   vmovss	xmm7, dword ptr [rip + .LCPI10_1]
[5,14]    .    .    .    .    .    D----------------------R .    .    .    .    . .   vxorps	xmm8, xmm8, xmm8
[5,15]    .    .    .    .    .    D=======eeeeeeE--------R .    .    .    .    . .   vmovddup	xmm9, qword ptr [rip + .LCPI10_2]
[5,16]    .    .    .    .    .    D=======eeeeeeE--------R .    .    .    .    . .   vpbroadcastd	xmm10, dword ptr [rip + .LCPI10_3]
[5,17]    .    .    .    .    .    D========eeeeeeE-------R .    .    .    .    . .   vpbroadcastd	xmm11, dword ptr [rip + .LCPI10_4]
[5,18]    .    .    .    .    .    D=========eeeeeE-------R .    .    .    .    . .   vmovss	xmm12, dword ptr [rip + .LCPI10_5]
[5,19]    .    .    .    .    .    D==========eeeeeeE-----R .    .    .    .    . .   vbroadcastss	xmm14, dword ptr [rip + .LCPI10_0]
[5,20]    .    .    .    .    .    .D=========eE----------R .    .    .    .    . .   mov	qword ptr [rsp + 64], r14
[5,21]    .    .    .    .    .    .DeE-------------------R .    .    .    .    . .   jmp	.LBB10_16
[5,22]    .    .    .    .    .    .D=============eeeeeE--R .    .    .    .    . .   mov	rbx, qword ptr [rbx]
[5,23]    .    .    .    .    .    .D==================eE-R .    .    .    .    . .   test	rbx, rbx
[5,24]    .    .    .    .    .    .D===================eER .    .    .    .    . .   jne	.LBB10_39
[5,25]    .    .    .    .    .    .D=============eE------R .    .    .    .    . .   mov	byte ptr [rsp + 47], 0
[6,0]     .    .    .    .    .    . D========eeeeeE------R .    .    .    .    . .   mov	rax, qword ptr [rsp + 56]
[6,1]     .    .    .    .    .    . D=============eeeeeE-R .    .    .    .    . .   mov	rbx, qword ptr [rax + 96]
[6,2]     .    .    .    .    .    . D==================eER .    .    .    .    . .   test	rbx, rbx
[6,3]     .    .    .    .    .    . D===================eER.    .    .    .    . .   je	.LBB10_41
[6,4]     .    .    .    .    .    . D=========eeeeeeE-----R.    .    .    .    . .   cmp	dword ptr [rsp + 48], 0
[6,5]     .    .    .    .    .    .  D==============eE----R.    .    .    .    . .   je	.LBB10_39
[6,6]     .    .    .    .    .    .  D========eeeeeE------R.    .    .    .    . .   vmovss	xmm1, dword ptr [rip + .LCPI10_0]
[6,7]     .    .    .    .    .    .  D=============eeeeeeeeeeeER.    .    .    . .   vdivss	xmm6, xmm1, xmm0
[6,8]     .    .    .    .    .    .  D=========eeeeeE----------R.    .    .    . .   mov	rax, qword ptr [rsp + 56]
[6,9]     .    .    .    .    .    .  D==============eE---------R.    .    .    . .   lea	rdx, [rax + 96]
[6,10]    .    .    .    .    .    .  DeE-----------------------R.    .    .    . .   lea	rax, [rsi + 40]
[6,11]    .    .    .    .    .    .   D===========eE-----------R.    .    .    . .   mov	qword ptr [rsp + 128], rax
[6,12]    .    .    .    .    .    .   DeE----------------------R.    .    .    . .   mov	r13d, 1
[6,13]    .    .    .    .    .    .   D========eeeeeE----------R.    .    .    . .   vmovss	xmm7, dword ptr [rip + .LCPI10_1]
[6,14]    .    .    .    .    .    .   D------------------------R.    .    .    . .   vxorps	xmm8, xmm8, xmm8
[6,15]    .    .    .    .    .    .   D=========eeeeeeE--------R.    .    .    . .   vmovddup	xmm9, qword ptr [rip + .LCPI10_2]
[6,16]    .    .    .    .    .    .   D=========eeeeeeE--------R.    .    .    . .   vpbroadcastd	xmm10, dword ptr [rip + .LCPI10_3]
[6,17]    .    .    .    .    .    .    D=========eeeeeeE-------R.    .    .    . .   vpbroadcastd	xmm11, dword ptr [rip + .LCPI10_4]
[6,18]    .    .    .    .    .    .    D==========eeeeeE-------R.    .    .    . .   vmovss	xmm12, dword ptr [rip + .LCPI10_5]
[6,19]    .    .    .    .    .    .    D===========eeeeeeE-----R.    .    .    . .   vbroadcastss	xmm14, dword ptr [rip + .LCPI10_0]
[6,20]    .    .    .    .    .    .    D===========eE----------R.    .    .    . .   mov	qword ptr [rsp + 64], r14
[6,21]    .    .    .    .    .    .    DeE---------------------R.    .    .    . .   jmp	.LBB10_16
[6,22]    .    .    .    .    .    .    D===============eeeeeE--R.    .    .    . .   mov	rbx, qword ptr [rbx]
[6,23]    .    .    .    .    .    .    .D===================eE-R.    .    .    . .   test	rbx, rbx
[6,24]    .    .    .    .    .    .    .D====================eER.    .    .    . .   jne	.LBB10_39
[6,25]    .    .    .    .    .    .    .D==============eE------R.    .    .    . .   mov	byte ptr [rsp + 47], 0
[7,0]     .    .    .    .    .    .    .D==========eeeeeE------R.    .    .    . .   mov	rax, qword ptr [rsp + 56]
[7,1]     .    .    .    .    .    .    .D===============eeeeeE-R.    .    .    . .   mov	rbx, qword ptr [rax + 96]
[7,2]     .    .    .    .    .    .    .D====================eER.    .    .    . .   test	rbx, rbx
[7,3]     .    .    .    .    .    .    . D====================eER    .    .    . .   je	.LBB10_41
[7,4]     .    .    .    .    .    .    . D==========eeeeeeE-----R    .    .    . .   cmp	dword ptr [rsp + 48], 0
[7,5]     .    .    .    .    .    .    . D================eE----R    .    .    . .   je	.LBB10_39
[7,6]     .    .    .    .    .    .    . D==========eeeeeE------R    .    .    . .   vmovss	xmm1, dword ptr [rip + .LCPI10_0]
[7,7]     .    .    .    .    .    .    . D===============eeeeeeeeeeeER    .    . .   vdivss	xmm6, xmm1, xmm0
[7,8]     .    .    .    .    .    .    .  D==========eeeeeE----------R    .    . .   mov	rax, qword ptr [rsp + 56]
[7,9]     .    .    .    .    .    .    .  D===============eE---------R    .    . .   lea	rdx, [rax + 96]
[7,10]    .    .    .    .    .    .    .  DeE------------------------R    .    . .   lea	rax, [rsi + 40]
[7,11]    .    .    .    .    .    .    .  D=============eE-----------R    .    . .   mov	qword ptr [rsp + 128], rax
[7,12]    .    .    .    .    .    .    .  DeE------------------------R    .    . .   mov	r13d, 1
[7,13]    .    .    .    .    .    .    .  D==========eeeeeE----------R    .    . .   vmovss	xmm7, dword ptr [rip + .LCPI10_1]
[7,14]    .    .    .    .    .    .    .   D-------------------------R    .    . .   vxorps	xmm8, xmm8, xmm8
[7,15]    .    .    .    .    .    .    .   D==========eeeeeeE--------R    .    . .   vmovddup	xmm9, qword ptr [rip + .LCPI10_2]
[7,16]    .    .    .    .    .    .    .   D==========eeeeeeE--------R    .    . .   vpbroadcastd	xmm10, dword ptr [rip + .LCPI10_3]
[7,17]    .    .    .    .    .    .    .   D===========eeeeeeE-------R    .    . .   vpbroadcastd	xmm11, dword ptr [rip + .LCPI10_4]
[7,18]    .    .    .    .    .    .    .   D============eeeeeE-------R    .    . .   vmovss	xmm12, dword ptr [rip + .LCPI10_5]
[7,19]    .    .    .    .    .    .    .   D=============eeeeeeE-----R    .    . .   vbroadcastss	xmm14, dword ptr [rip + .LCPI10_0]
[7,20]    .    .    .    .    .    .    .    D============eE----------R    .    . .   mov	qword ptr [rsp + 64], r14
[7,21]    .    .    .    .    .    .    .    DeE----------------------R    .    . .   jmp	.LBB10_16
[7,22]    .    .    .    .    .    .    .    D================eeeeeE--R    .    . .   mov	rbx, qword ptr [rbx]
[7,23]    .    .    .    .    .    .    .    D=====================eE-R    .    . .   test	rbx, rbx
[7,24]    .    .    .    .    .    .    .    D======================eER    .    . .   jne	.LBB10_39
[7,25]    .    .    .    .    .    .    .    D================eE------R    .    . .   mov	byte ptr [rsp + 47], 0
[8,0]     .    .    .    .    .    .    .    .D===========eeeeeE------R    .    . .   mov	rax, qword ptr [rsp + 56]
[8,1]     .    .    .    .    .    .    .    .D================eeeeeE-R    .    . .   mov	rbx, qword ptr [rax + 96]
[8,2]     .    .    .    .    .    .    .    .D=====================eER    .    . .   test	rbx, rbx
[8,3]     .    .    .    .    .    .    .    .D======================eER   .    . .   je	.LBB10_41
[8,4]     .    .    .    .    .    .    .    .D============eeeeeeE-----R   .    . .   cmp	dword ptr [rsp + 48], 0
[8,5]     .    .    .    .    .    .    .    . D=================eE----R   .    . .   je	.LBB10_39
[8,6]     .    .    .    .    .    .    .    . D===========eeeeeE------R   .    . .   vmovss	xmm1, dword ptr [rip + .LCPI10_0]
[8,7]     .    .    .    .    .    .    .    . D================eeeeeeeeeeeER   . .   vdivss	xmm6, xmm1, xmm0
[8,8]     .    .    .    .    .    .    .    . D============eeeeeE----------R   . .   mov	rax, qword ptr [rsp + 56]
[8,9]     .    .    .    .    .    .    .    . D=================eE---------R   . .   lea	rdx, [rax + 96]
[8,10]    .    .    .    .    .    .    .    . DeE--------------------------R   . .   lea	rax, [rsi + 40]
[8,11]    .    .    .    .    .    .    .    .  D==============eE-----------R   . .   mov	qword ptr [rsp + 128], rax
[8,12]    .    .    .    .    .    .    .    .  DeE-------------------------R   . .   mov	r13d, 1
[8,13]    .    .    .    .    .    .    .    .  D===========eeeeeE----------R   . .   vmovss	xmm7, dword ptr [rip + .LCPI10_1]
[8,14]    .    .    .    .    .    .    .    .  D---------------------------R   . .   vxorps	xmm8, xmm8, xmm8
[8,15]    .    .    .    .    .    .    .    .   D===========eeeeeeE--------R   . .   vmovddup	xmm9, qword ptr [rip + .LCPI10_2]
[8,16]    .    .    .    .    .    .    .    .   D===========eeeeeeE--------R   . .   vpbroadcastd	xmm10, dword ptr [rip + .LCPI10_3]
[8,17]    .    .    .    .    .    .    .    .   D============eeeeeeE-------R   . .   vpbroadcastd	xmm11, dword ptr [rip + .LCPI10_4]
[8,18]    .    .    .    .    .    .    .    .   D=============eeeeeE-------R   . .   vmovss	xmm12, dword ptr [rip + .LCPI10_5]
[8,19]    .    .    .    .    .    .    .    .    D=============eeeeeeE-----R   . .   vbroadcastss	xmm14, dword ptr [rip + .LCPI10_0]
[8,20]    .    .    .    .    .    .    .    .    D=============eE----------R   . .   mov	qword ptr [rsp + 64], r14
[8,21]    .    .    .    .    .    .    .    .    DeE-----------------------R   . .   jmp	.LBB10_16
[8,22]    .    .    .    .    .    .    .    .    D=================eeeeeE--R   . .   mov	rbx, qword ptr [rbx]
[8,23]    .    .    .    .    .    .    .    .    D======================eE-R   . .   test	rbx, rbx
[8,24]    .    .    .    .    .    .    .    .    .D======================eER   . .   jne	.LBB10_39
[8,25]    .    .    .    .    .    .    .    .    .D================eE------R   . .   mov	byte ptr [rsp + 47], 0
[9,0]     .    .    .    .    .    .    .    .    .D============eeeeeE------R   . .   mov	rax, qword ptr [rsp + 56]
[9,1]     .    .    .    .    .    .    .    .    .D=================eeeeeE-R   . .   mov	rbx, qword ptr [rax + 96]
[9,2]     .    .    .    .    .    .    .    .    .D======================eER   . .   test	rbx, rbx
[9,3]     .    .    .    .    .    .    .    .    . D======================eER  . .   je	.LBB10_41
[9,4]     .    .    .    .    .    .    .    .    . D============eeeeeeE-----R  . .   cmp	dword ptr [rsp + 48], 0
[9,5]     .    .    .    .    .    .    .    .    . D==================eE----R  . .   je	.LBB10_39
[9,6]     .    .    .    .    .    .    .    .    . D============eeeeeE------R  . .   vmovss	xmm1, dword ptr [rip + .LCPI10_0]
[9,7]     .    .    .    .    .    .    .    .    .  D================eeeeeeeeeeeER   vdivss	xmm6, xmm1, xmm0
[9,8]     .    .    .    .    .    .    .    .    .  D============eeeeeE----------R   mov	rax, qword ptr [rsp + 56]
[9,9]     .    .    .    .    .    .    .    .    .  D=================eE---------R   lea	rdx, [rax + 96]
[9,10]    .    .    .    .    .    .    .    .    .  DeE--------------------------R   lea	rax, [rsi + 40]
[9,11]    .    .    .    .    .    .    .    .    .   D==============eE-----------R   mov	qword ptr [rsp + 128], rax
[9,12]    .    .    .    .    .    .    .    .    .   DeE-------------------------R   mov	r13d, 1
[9,13]    .    .    .    .    .    .    .    .    .   D===========eeeeeE----------R   vmovss	xmm7, dword ptr [rip + .LCPI10_1]
[9,14]    .    .    .    .    .    .    .    .    .   D---------------------------R   vxorps	xmm8, xmm8, xmm8
[9,15]    .    .    .    .    .    .    .    .    .    D===========eeeeeeE--------R   vmovddup	xmm9, qword ptr [rip + .LCPI10_2]
[9,16]    .    .    .    .    .    .    .    .    .    D===========eeeeeeE--------R   vpbroadcastd	xmm10, dword ptr [rip + .LCPI10_3]
[9,17]    .    .    .    .    .    .    .    .    .    D============eeeeeeE-------R   vpbroadcastd	xmm11, dword ptr [rip + .LCPI10_4]
[9,18]    .    .    .    .    .    .    .    .    .    D=============eeeeeE-------R   vmovss	xmm12, dword ptr [rip + .LCPI10_5]
[9,19]    .    .    .    .    .    .    .    .    .    .D=============eeeeeeE-----R   vbroadcastss	xmm14, dword ptr [rip + .LCPI10_0]
[9,20]    .    .    .    .    .    .    .    .    .    .D=============eE----------R   mov	qword ptr [rsp + 64], r14
[9,21]    .    .    .    .    .    .    .    .    .    .DeE-----------------------R   jmp	.LBB10_16
[9,22]    .    .    .    .    .    .    .    .    .    .D=================eeeeeE--R   mov	rbx, qword ptr [rbx]
[9,23]    .    .    .    .    .    .    .    .    .    .D======================eE-R   test	rbx, rbx
[9,24]    .    .    .    .    .    .    .    .    .    . D======================eER   jne	.LBB10_39
[9,25]    .    .    .    .    .    .    .    .    .    . D================eE------R   mov	byte ptr [rsp + 47], 0


```
</details>

<details><summary>Average Wait times (based on the timeline view):</summary>

```
[0]: Executions
[1]: Average time spent waiting in a scheduler's queue
[2]: Average time spent waiting in a scheduler's queue while ready
[3]: Average time elapsed from WB until retire stage

      [0]    [1]    [2]    [3]
0.     10    7.0    7.0    5.5       mov	rax, qword ptr [rsp + 56]
1.     10    12.0   0.0    1.0       mov	rbx, qword ptr [rax + 96]
2.     10    17.0   0.0    0.1       test	rbx, rbx
3.     10    17.5   0.0    0.0       je	.LBB10_41
4.     10    7.4    7.4    5.1       cmp	dword ptr [rsp + 48], 0
5.     10    12.9   0.0    4.1       je	.LBB10_39
6.     10    7.0    7.0    6.0       vmovss	xmm1, dword ptr [rip + .LCPI10_0]
7.     10    11.9   0.0    0.0       vdivss	xmm6, xmm1, xmm0
8.     10    7.4    7.4    10.1      mov	rax, qword ptr [rsp + 56]
9.     10    12.4   0.0    9.1       lea	rdx, [rax + 96]
10.    10    1.2    1.2    20.3      lea	rax, [rsi + 40]
11.    10    9.9    0.0    11.0      mov	qword ptr [rsp + 128], rax
12.    10    1.1    1.1    19.8      mov	r13d, 1
13.    10    6.9    6.9    10.0      vmovss	xmm7, dword ptr [rip + .LCPI10_1]
14.    10    0.0    0.0    21.5      vxorps	xmm8, xmm8, xmm8
15.    10    7.2    7.2    8.1       vmovddup	xmm9, qword ptr [rip + .LCPI10_2]
16.    10    7.3    7.3    8.0       vpbroadcastd	xmm10, dword ptr [rip + .LCPI10_3]
17.    10    7.8    7.8    7.1       vpbroadcastd	xmm11, dword ptr [rip + .LCPI10_4]
18.    10    8.7    8.7    7.2       vmovss	xmm12, dword ptr [rip + .LCPI10_5]
19.    10    9.5    9.5    5.2       vbroadcastss	xmm14, dword ptr [rip + .LCPI10_0]
20.    10    9.2    0.0    10.1      mov	qword ptr [rsp + 64], r14
21.    10    1.0    1.0    18.3      jmp	.LBB10_16
22.    10    13.3   0.0    2.0       mov	rbx, qword ptr [rbx]
23.    10    17.9   0.0    1.0       test	rbx, rbx
24.    10    18.7   0.0    0.0       jne	.LBB10_39
25.    10    12.7   0.0    6.0       mov	byte ptr [rsp + 47], 0
       10    9.4    3.1    7.6       <total>


```
</details>

</details>

<details><summary>[2] Code Region - OPS_FillSoundBuffer</summary>

```
Iterations:        100
Instructions:      1600
Total Cycles:      371
Total uOps:        2000

Dispatch Width:    6
uOps Per Cycle:    5.39
IPC:               4.31
Block RThroughput: 3.3


No resource or data dependency bottlenecks discovered.


```

<details><summary>Instruction Info:</summary>

```
[1]: #uOps
[2]: Latency
[3]: RThroughput
[4]: MayLoad
[5]: MayStore
[6]: HasSideEffects (U)

[1]    [2]    [3]    [4]    [5]    [6]    Instructions:
 2      6     0.50    *                   cmp	dword ptr [rsp + 48], 0
 1      1     0.50                        je	.LBB10_44
 1      5     0.50    *                   mov	rax, qword ptr [rsp + 96]
 1      5     0.50    *                   mov	rax, qword ptr [rax]
 1      0     0.17                        xor	ecx, ecx
 1      6     0.50    *                   vmovaps	xmm0, xmmword ptr [r15 + rcx]
 1      4     0.50                        cvtps2dq	xmm0, xmm0
 1      6     0.50    *                   vmovaps	xmm1, xmmword ptr [rdi + rcx]
 1      4     0.50                        cvtps2dq	xmm1, xmm1
 1      1     0.50                        vpunpckhdq	xmm2, xmm0, xmm1
 1      1     0.50                        vpunpckldq	xmm0, xmm0, xmm1
 1      3     1.00                        vinserti128	ymm0, ymm0, xmm2, 1
 4      5     2.00           *            vpmovsdw	xmmword ptr [rax + rcx], ymm0
 1      1     0.25                        add	rcx, 16
 1      1     0.25                        add	r14, -1
 1      1     0.50                        jne	.LBB10_43


```
</details>

<details><summary>Dynamic Dispatch Stall Cycles:</summary>

```
RAT     - Register unavailable:                      0
RCU     - Retire tokens unavailable:                 0
SCHEDQ  - Scheduler full:                            0
LQ      - Load queue full:                           0
SQ      - Store queue full:                          0
GROUP   - Static restrictions on the dispatch group: 0
USH     - Uncategorised Structural Hazard:           0


```
</details>

<details><summary>Dispatch Logic - number of cycles where we saw N micro opcodes dispatched:</summary>

```
[# dispatched], [# cycles]
 0,              20  (5.4%)
 1,              1  (0.3%)
 3,              1  (0.3%)
 4,              49  (13.2%)
 6,              300  (80.9%)


```
</details>

<details><summary>Schedulers - number of cycles where we saw N micro opcodes issued:</summary>

```
[# issued], [# cycles]
 0,          8  (2.2%)
 1,          5  (1.3%)
 2,          8  (2.2%)
 3,          22  (5.9%)
 4,          67  (18.1%)
 5,          145  (39.1%)
 6,          19  (5.1%)
 7,          17  (4.6%)
 8,          33  (8.9%)
 9,          47  (12.7%)

```
</details>

<details><summary>Scheduler's queue usage:</summary>

```
[1] Resource name.
[2] Average number of used buffer entries.
[3] Maximum number of used buffer entries.
[4] Total number of buffer entries.

 [1]            [2]        [3]        [4]
ICXPortAny       25         28         60


```
</details>

<details><summary>Retire Control Unit - number of cycles where we saw N instructions retired:</summary>

```
[# retired], [# cycles]
 0,           265  (71.4%)
 1,           2  (0.5%)
 2,           2  (0.5%)
 3,           2  (0.5%)
 4,           1  (0.3%)
 16,          99  (26.7%)

```
</details>

<details><summary>Total ROB Entries:                352</summary>

```
Max Used ROB Entries:             130  ( 36.9% )
Average Used ROB Entries per cy:  110  ( 31.3% )


```
</details>

<details><summary>Register File statistics:</summary>

```
Total number of mappings created:    1400
Max number of mappings used:         89


```
</details>

<details><summary>Resources:</summary>

```
[0]   - ICXDivider
[1]   - ICXFPDivider
[2]   - ICXPort0
[3]   - ICXPort1
[4]   - ICXPort2
[5]   - ICXPort3
[6]   - ICXPort4
[7]   - ICXPort5
[8]   - ICXPort6
[9]   - ICXPort7
[10]  - ICXPort8
[11]  - ICXPort9


Resource pressure per iteration:
[0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   
 -      -     2.81   3.14   2.50   2.50   0.50   3.57   2.48   0.50   0.50   0.50   

Resource pressure by instruction:
[0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   Instructions:
 -      -     0.17   0.63   0.32   0.68    -     0.02   0.18    -      -      -     cmp	dword ptr [rsp + 48], 0
 -      -     0.34    -      -      -      -      -     0.66    -      -      -     je	.LBB10_44
 -      -      -      -     0.68   0.32    -      -      -      -      -      -     mov	rax, qword ptr [rsp + 96]
 -      -      -      -     0.18   0.82    -      -      -      -      -      -     mov	rax, qword ptr [rax]
 -      -      -      -      -      -      -      -      -      -      -      -     xor	ecx, ecx
 -      -      -      -     0.97   0.03    -      -      -      -      -      -     vmovaps	xmm0, xmmword ptr [r15 + rcx]
 -      -     0.81   0.19    -      -      -      -      -      -      -      -     cvtps2dq	xmm0, xmm0
 -      -      -      -     0.35   0.65    -      -      -      -      -      -     vmovaps	xmm1, xmmword ptr [rdi + rcx]
 -      -     0.67   0.33    -      -      -      -      -      -      -      -     cvtps2dq	xmm1, xmm1
 -      -      -     0.49    -      -      -     0.51    -      -      -      -     vpunpckhdq	xmm2, xmm0, xmm1
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     vpunpckldq	xmm0, xmm0, xmm1
 -      -      -      -      -      -      -     1.00    -      -      -      -     vinserti128	ymm0, ymm0, xmm2, 1
 -      -      -      -      -      -     0.50   2.00    -     0.50   0.50   0.50   vpmovsdw	xmmword ptr [rax + rcx], ymm0
 -      -     0.31   0.18    -      -      -     0.03   0.48    -      -      -     add	rcx, 16
 -      -     0.34   0.33    -      -      -      -     0.33    -      -      -     add	r14, -1
 -      -     0.17    -      -      -      -      -     0.83    -      -      -     jne	.LBB10_43


```
</details>

<details><summary>Timeline view:</summary>

```
                    0123456789          0123456789          012345
Index     0123456789          0123456789          0123456789      

[0,0]     DeeeeeeER .    .    .    .    .    .    .    .    .    .   cmp	dword ptr [rsp + 48], 0
[0,1]     D======eER.    .    .    .    .    .    .    .    .    .   je	.LBB10_44
[0,2]     DeeeeeE--R.    .    .    .    .    .    .    .    .    .   mov	rax, qword ptr [rsp + 96]
[0,3]     D=====eeeeeER  .    .    .    .    .    .    .    .    .   mov	rax, qword ptr [rax]
[0,4]     D-----------R  .    .    .    .    .    .    .    .    .   xor	ecx, ecx
[0,5]     .DeeeeeeE---R  .    .    .    .    .    .    .    .    .   vmovaps	xmm0, xmmword ptr [r15 + rcx]
[0,6]     .D======eeeeER .    .    .    .    .    .    .    .    .   cvtps2dq	xmm0, xmm0
[0,7]     .DeeeeeeE----R .    .    .    .    .    .    .    .    .   vmovaps	xmm1, xmmword ptr [rdi + rcx]
[0,8]     .D======eeeeER .    .    .    .    .    .    .    .    .   cvtps2dq	xmm1, xmm1
[0,9]     .D==========eER.    .    .    .    .    .    .    .    .   vpunpckhdq	xmm2, xmm0, xmm1
[0,10]    .D==========eER.    .    .    .    .    .    .    .    .   vpunpckldq	xmm0, xmm0, xmm1
[0,11]    . D==========eeeER  .    .    .    .    .    .    .    .   vinserti128	ymm0, ymm0, xmm2, 1
[0,12]    . D=============eeeeeER  .    .    .    .    .    .    .   vpmovsdw	xmmword ptr [rax + rcx], ymm0
[0,13]    . DeE-----------------R  .    .    .    .    .    .    .   add	rcx, 16
[0,14]    .  DeE----------------R  .    .    .    .    .    .    .   add	r14, -1
[0,15]    .  D=eE---------------R  .    .    .    .    .    .    .   jne	.LBB10_43
[1,0]     .  DeeeeeeE-----------R  .    .    .    .    .    .    .   cmp	dword ptr [rsp + 48], 0
[1,1]     .  D======eE----------R  .    .    .    .    .    .    .   je	.LBB10_44
[1,2]     .  DeeeeeE------------R  .    .    .    .    .    .    .   mov	rax, qword ptr [rsp + 96]
[1,3]     .   D====eeeeeE-------R  .    .    .    .    .    .    .   mov	rax, qword ptr [rax]
[1,4]     .   D-----------------R  .    .    .    .    .    .    .   xor	ecx, ecx
[1,5]     .   DeeeeeeE----------R  .    .    .    .    .    .    .   vmovaps	xmm0, xmmword ptr [r15 + rcx]
[1,6]     .   D======eeeeE------R  .    .    .    .    .    .    .   cvtps2dq	xmm0, xmm0
[1,7]     .   DeeeeeeE----------R  .    .    .    .    .    .    .   vmovaps	xmm1, xmmword ptr [rdi + rcx]
[1,8]     .   D======eeeeE------R  .    .    .    .    .    .    .   cvtps2dq	xmm1, xmm1
[1,9]     .    D=========eE-----R  .    .    .    .    .    .    .   vpunpckhdq	xmm2, xmm0, xmm1
[1,10]    .    D=========eE-----R  .    .    .    .    .    .    .   vpunpckldq	xmm0, xmm0, xmm1
[1,11]    .    D============eeeER  .    .    .    .    .    .    .   vinserti128	ymm0, ymm0, xmm2, 1
[1,12]    .    .D==============eeeeeER  .    .    .    .    .    .   vpmovsdw	xmmword ptr [rax + rcx], ymm0
[1,13]    .    .DeE------------------R  .    .    .    .    .    .   add	rcx, 16
[1,14]    .    .DeE------------------R  .    .    .    .    .    .   add	r14, -1
[1,15]    .    . DeE-----------------R  .    .    .    .    .    .   jne	.LBB10_43
[2,0]     .    . DeeeeeeE------------R  .    .    .    .    .    .   cmp	dword ptr [rsp + 48], 0
[2,1]     .    . D======eE-----------R  .    .    .    .    .    .   je	.LBB10_44
[2,2]     .    . DeeeeeE-------------R  .    .    .    .    .    .   mov	rax, qword ptr [rsp + 96]
[2,3]     .    . D=====eeeeeE--------R  .    .    .    .    .    .   mov	rax, qword ptr [rax]
[2,4]     .    .  D------------------R  .    .    .    .    .    .   xor	ecx, ecx
[2,5]     .    .  DeeeeeeE-----------R  .    .    .    .    .    .   vmovaps	xmm0, xmmword ptr [r15 + rcx]
[2,6]     .    .  D======eeeeE-------R  .    .    .    .    .    .   cvtps2dq	xmm0, xmm0
[2,7]     .    .  D=eeeeeeE----------R  .    .    .    .    .    .   vmovaps	xmm1, xmmword ptr [rdi + rcx]
[2,8]     .    .  D=======eeeeE------R  .    .    .    .    .    .   cvtps2dq	xmm1, xmm1
[2,9]     .    .  D===========eE-----R  .    .    .    .    .    .   vpunpckhdq	xmm2, xmm0, xmm1
[2,10]    .    .   D==========eE-----R  .    .    .    .    .    .   vpunpckldq	xmm0, xmm0, xmm1
[2,11]    .    .   D=============eeeER  .    .    .    .    .    .   vinserti128	ymm0, ymm0, xmm2, 1
[2,12]    .    .   D================eeeeeER  .    .    .    .    .   vpmovsdw	xmmword ptr [rax + rcx], ymm0
[2,13]    .    .    DeE-------------------R  .    .    .    .    .   add	rcx, 16
[2,14]    .    .    DeE-------------------R  .    .    .    .    .   add	r14, -1
[2,15]    .    .    D=eE------------------R  .    .    .    .    .   jne	.LBB10_43
[3,0]     .    .    D=eeeeeeE-------------R  .    .    .    .    .   cmp	dword ptr [rsp + 48], 0
[3,1]     .    .    D=======eE------------R  .    .    .    .    .   je	.LBB10_44
[3,2]     .    .    .DeeeeeE--------------R  .    .    .    .    .   mov	rax, qword ptr [rsp + 96]
[3,3]     .    .    .D=====eeeeeE---------R  .    .    .    .    .   mov	rax, qword ptr [rax]
[3,4]     .    .    .D--------------------R  .    .    .    .    .   xor	ecx, ecx
[3,5]     .    .    .D=eeeeeeE------------R  .    .    .    .    .   vmovaps	xmm0, xmmword ptr [r15 + rcx]
[3,6]     .    .    .D=======eeeeE--------R  .    .    .    .    .   cvtps2dq	xmm0, xmm0
[3,7]     .    .    .D==eeeeeeE-----------R  .    .    .    .    .   vmovaps	xmm1, xmmword ptr [rdi + rcx]
[3,8]     .    .    . D=======eeeeE-------R  .    .    .    .    .   cvtps2dq	xmm1, xmm1
[3,9]     .    .    . D===========eE------R  .    .    .    .    .   vpunpckhdq	xmm2, xmm0, xmm1
[3,10]    .    .    . D===========eE------R  .    .    .    .    .   vpunpckldq	xmm0, xmm0, xmm1
[3,11]    .    .    . D============eeeE---R  .    .    .    .    .   vinserti128	ymm0, ymm0, xmm2, 1
[3,12]    .    .    .  D==============eeeeeER.    .    .    .    .   vpmovsdw	xmmword ptr [rax + rcx], ymm0
[3,13]    .    .    .  DeE------------------R.    .    .    .    .   add	rcx, 16
[3,14]    .    .    .  DeE------------------R.    .    .    .    .   add	r14, -1
[3,15]    .    .    .   DeE-----------------R.    .    .    .    .   jne	.LBB10_43
[4,0]     .    .    .   D=eeeeeeE-----------R.    .    .    .    .   cmp	dword ptr [rsp + 48], 0
[4,1]     .    .    .   D=======eE----------R.    .    .    .    .   je	.LBB10_44
[4,2]     .    .    .   DeeeeeE-------------R.    .    .    .    .   mov	rax, qword ptr [rsp + 96]
[4,3]     .    .    .   D=====eeeeeE--------R.    .    .    .    .   mov	rax, qword ptr [rax]
[4,4]     .    .    .    D------------------R.    .    .    .    .   xor	ecx, ecx
[4,5]     .    .    .    DeeeeeeE-----------R.    .    .    .    .   vmovaps	xmm0, xmmword ptr [r15 + rcx]
[4,6]     .    .    .    D======eeeeE-------R.    .    .    .    .   cvtps2dq	xmm0, xmm0
[4,7]     .    .    .    D=eeeeeeE----------R.    .    .    .    .   vmovaps	xmm1, xmmword ptr [rdi + rcx]
[4,8]     .    .    .    D=======eeeeE------R.    .    .    .    .   cvtps2dq	xmm1, xmm1
[4,9]     .    .    .    D===========eE-----R.    .    .    .    .   vpunpckhdq	xmm2, xmm0, xmm1
[4,10]    .    .    .    .D===========eE----R.    .    .    .    .   vpunpckldq	xmm0, xmm0, xmm1
[4,11]    .    .    .    .D=============eeeER.    .    .    .    .   vinserti128	ymm0, ymm0, xmm2, 1
[4,12]    .    .    .    .D================eeeeeER.    .    .    .   vpmovsdw	xmmword ptr [rax + rcx], ymm0
[4,13]    .    .    .    . DeE-------------------R.    .    .    .   add	rcx, 16
[4,14]    .    .    .    . DeE-------------------R.    .    .    .   add	r14, -1
[4,15]    .    .    .    . D=eE------------------R.    .    .    .   jne	.LBB10_43
[5,0]     .    .    .    . D=eeeeeeE-------------R.    .    .    .   cmp	dword ptr [rsp + 48], 0
[5,1]     .    .    .    . D=======eE------------R.    .    .    .   je	.LBB10_44
[5,2]     .    .    .    .  DeeeeeE--------------R.    .    .    .   mov	rax, qword ptr [rsp + 96]
[5,3]     .    .    .    .  D=====eeeeeE---------R.    .    .    .   mov	rax, qword ptr [rax]
[5,4]     .    .    .    .  D--------------------R.    .    .    .   xor	ecx, ecx
[5,5]     .    .    .    .  D=eeeeeeE------------R.    .    .    .   vmovaps	xmm0, xmmword ptr [r15 + rcx]
[5,6]     .    .    .    .  D=======eeeeE--------R.    .    .    .   cvtps2dq	xmm0, xmm0
[5,7]     .    .    .    .  D==eeeeeeE-----------R.    .    .    .   vmovaps	xmm1, xmmword ptr [rdi + rcx]
[5,8]     .    .    .    .   D=======eeeeE-------R.    .    .    .   cvtps2dq	xmm1, xmm1
[5,9]     .    .    .    .   D===========eE------R.    .    .    .   vpunpckhdq	xmm2, xmm0, xmm1
[5,10]    .    .    .    .   D===========eE------R.    .    .    .   vpunpckldq	xmm0, xmm0, xmm1
[5,11]    .    .    .    .   D============eeeE---R.    .    .    .   vinserti128	ymm0, ymm0, xmm2, 1
[5,12]    .    .    .    .    D==============eeeeeER   .    .    .   vpmovsdw	xmmword ptr [rax + rcx], ymm0
[5,13]    .    .    .    .    DeE------------------R   .    .    .   add	rcx, 16
[5,14]    .    .    .    .    DeE------------------R   .    .    .   add	r14, -1
[5,15]    .    .    .    .    .DeE-----------------R   .    .    .   jne	.LBB10_43
[6,0]     .    .    .    .    .D=eeeeeeE-----------R   .    .    .   cmp	dword ptr [rsp + 48], 0
[6,1]     .    .    .    .    .D=======eE----------R   .    .    .   je	.LBB10_44
[6,2]     .    .    .    .    .DeeeeeE-------------R   .    .    .   mov	rax, qword ptr [rsp + 96]
[6,3]     .    .    .    .    .D=====eeeeeE--------R   .    .    .   mov	rax, qword ptr [rax]
[6,4]     .    .    .    .    . D------------------R   .    .    .   xor	ecx, ecx
[6,5]     .    .    .    .    . DeeeeeeE-----------R   .    .    .   vmovaps	xmm0, xmmword ptr [r15 + rcx]
[6,6]     .    .    .    .    . D======eeeeE-------R   .    .    .   cvtps2dq	xmm0, xmm0
[6,7]     .    .    .    .    . D=eeeeeeE----------R   .    .    .   vmovaps	xmm1, xmmword ptr [rdi + rcx]
[6,8]     .    .    .    .    . D=======eeeeE------R   .    .    .   cvtps2dq	xmm1, xmm1
[6,9]     .    .    .    .    . D===========eE-----R   .    .    .   vpunpckhdq	xmm2, xmm0, xmm1
[6,10]    .    .    .    .    .  D===========eE----R   .    .    .   vpunpckldq	xmm0, xmm0, xmm1
[6,11]    .    .    .    .    .  D=============eeeER   .    .    .   vinserti128	ymm0, ymm0, xmm2, 1
[6,12]    .    .    .    .    .  D================eeeeeER   .    .   vpmovsdw	xmmword ptr [rax + rcx], ymm0
[6,13]    .    .    .    .    .   DeE-------------------R   .    .   add	rcx, 16
[6,14]    .    .    .    .    .   DeE-------------------R   .    .   add	r14, -1
[6,15]    .    .    .    .    .   D=eE------------------R   .    .   jne	.LBB10_43
[7,0]     .    .    .    .    .   D=eeeeeeE-------------R   .    .   cmp	dword ptr [rsp + 48], 0
[7,1]     .    .    .    .    .   D=======eE------------R   .    .   je	.LBB10_44
[7,2]     .    .    .    .    .    DeeeeeE--------------R   .    .   mov	rax, qword ptr [rsp + 96]
[7,3]     .    .    .    .    .    D=====eeeeeE---------R   .    .   mov	rax, qword ptr [rax]
[7,4]     .    .    .    .    .    D--------------------R   .    .   xor	ecx, ecx
[7,5]     .    .    .    .    .    D=eeeeeeE------------R   .    .   vmovaps	xmm0, xmmword ptr [r15 + rcx]
[7,6]     .    .    .    .    .    D=======eeeeE--------R   .    .   cvtps2dq	xmm0, xmm0
[7,7]     .    .    .    .    .    D==eeeeeeE-----------R   .    .   vmovaps	xmm1, xmmword ptr [rdi + rcx]
[7,8]     .    .    .    .    .    .D=======eeeeE-------R   .    .   cvtps2dq	xmm1, xmm1
[7,9]     .    .    .    .    .    .D===========eE------R   .    .   vpunpckhdq	xmm2, xmm0, xmm1
[7,10]    .    .    .    .    .    .D===========eE------R   .    .   vpunpckldq	xmm0, xmm0, xmm1
[7,11]    .    .    .    .    .    .D============eeeE---R   .    .   vinserti128	ymm0, ymm0, xmm2, 1
[7,12]    .    .    .    .    .    . D==============eeeeeER .    .   vpmovsdw	xmmword ptr [rax + rcx], ymm0
[7,13]    .    .    .    .    .    . DeE------------------R .    .   add	rcx, 16
[7,14]    .    .    .    .    .    . DeE------------------R .    .   add	r14, -1
[7,15]    .    .    .    .    .    .  D=eE----------------R .    .   jne	.LBB10_43
[8,0]     .    .    .    .    .    .  DeeeeeeE------------R .    .   cmp	dword ptr [rsp + 48], 0
[8,1]     .    .    .    .    .    .  D======eE-----------R .    .   je	.LBB10_44
[8,2]     .    .    .    .    .    .  DeeeeeE-------------R .    .   mov	rax, qword ptr [rsp + 96]
[8,3]     .    .    .    .    .    .  D=====eeeeeE--------R .    .   mov	rax, qword ptr [rax]
[8,4]     .    .    .    .    .    .   D------------------R .    .   xor	ecx, ecx
[8,5]     .    .    .    .    .    .   DeeeeeeE-----------R .    .   vmovaps	xmm0, xmmword ptr [r15 + rcx]
[8,6]     .    .    .    .    .    .   D======eeeeE-------R .    .   cvtps2dq	xmm0, xmm0
[8,7]     .    .    .    .    .    .   DeeeeeeE-----------R .    .   vmovaps	xmm1, xmmword ptr [rdi + rcx]
[8,8]     .    .    .    .    .    .   D======eeeeE-------R .    .   cvtps2dq	xmm1, xmm1
[8,9]     .    .    .    .    .    .   D==========eE------R .    .   vpunpckhdq	xmm2, xmm0, xmm1
[8,10]    .    .    .    .    .    .    D==========eE-----R .    .   vpunpckldq	xmm0, xmm0, xmm1
[8,11]    .    .    .    .    .    .    D=============eeeER .    .   vinserti128	ymm0, ymm0, xmm2, 1
[8,12]    .    .    .    .    .    .    D================eeeeeER .   vpmovsdw	xmmword ptr [rax + rcx], ymm0
[8,13]    .    .    .    .    .    .    .DeE-------------------R .   add	rcx, 16
[8,14]    .    .    .    .    .    .    .DeE-------------------R .   add	r14, -1
[8,15]    .    .    .    .    .    .    .D=eE------------------R .   jne	.LBB10_43
[9,0]     .    .    .    .    .    .    .D=eeeeeeE-------------R .   cmp	dword ptr [rsp + 48], 0
[9,1]     .    .    .    .    .    .    .D=======eE------------R .   je	.LBB10_44
[9,2]     .    .    .    .    .    .    . DeeeeeE--------------R .   mov	rax, qword ptr [rsp + 96]
[9,3]     .    .    .    .    .    .    . D=====eeeeeE---------R .   mov	rax, qword ptr [rax]
[9,4]     .    .    .    .    .    .    . D--------------------R .   xor	ecx, ecx
[9,5]     .    .    .    .    .    .    . D=eeeeeeE------------R .   vmovaps	xmm0, xmmword ptr [r15 + rcx]
[9,6]     .    .    .    .    .    .    . D=======eeeeE--------R .   cvtps2dq	xmm0, xmm0
[9,7]     .    .    .    .    .    .    . D==eeeeeeE-----------R .   vmovaps	xmm1, xmmword ptr [rdi + rcx]
[9,8]     .    .    .    .    .    .    .  D=======eeeeE-------R .   cvtps2dq	xmm1, xmm1
[9,9]     .    .    .    .    .    .    .  D===========eE------R .   vpunpckhdq	xmm2, xmm0, xmm1
[9,10]    .    .    .    .    .    .    .  D===========eE------R .   vpunpckldq	xmm0, xmm0, xmm1
[9,11]    .    .    .    .    .    .    .  D============eeeE---R .   vinserti128	ymm0, ymm0, xmm2, 1
[9,12]    .    .    .    .    .    .    .   D==============eeeeeER   vpmovsdw	xmmword ptr [rax + rcx], ymm0
[9,13]    .    .    .    .    .    .    .   DeE------------------R   add	rcx, 16
[9,14]    .    .    .    .    .    .    .   D=eE-----------------R   add	r14, -1
[9,15]    .    .    .    .    .    .    .    D=eE----------------R   jne	.LBB10_43


```
</details>

<details><summary>Average Wait times (based on the timeline view):</summary>

```
[0]: Executions
[1]: Average time spent waiting in a scheduler's queue
[2]: Average time spent waiting in a scheduler's queue while ready
[3]: Average time elapsed from WB until retire stage

      [0]    [1]    [2]    [3]
0.     10    1.6    1.6    10.9      cmp	dword ptr [rsp + 48], 0
1.     10    7.6    0.0    10.0      je	.LBB10_44
2.     10    1.0    1.0    12.2      mov	rax, qword ptr [rsp + 96]
3.     10    5.9    0.0    7.5       mov	rax, qword ptr [rax]
4.     10    0.0    0.0    18.0      xor	ecx, ecx
5.     10    1.4    1.4    10.5      vmovaps	xmm0, xmmword ptr [r15 + rcx]
6.     10    7.4    0.0    6.6       cvtps2dq	xmm0, xmm0
7.     10    2.1    2.1    9.9       vmovaps	xmm1, xmmword ptr [rdi + rcx]
8.     10    7.7    0.0    5.9       cvtps2dq	xmm1, xmm1
9.     10    11.6   0.0    5.0       vpunpckhdq	xmm2, xmm0, xmm1
10.    10    11.5   0.3    4.7       vpunpckldq	xmm0, xmm0, xmm1
11.    10    13.2   0.8    1.2       vinserti128	ymm0, ymm0, xmm2, 1
12.    10    15.7   0.0    0.0       vpmovsdw	xmmword ptr [rax + rcx], ymm0
13.    10    1.0    1.0    18.3      add	rcx, 16
14.    10    1.1    1.1    18.1      add	r14, -1
15.    10    1.7    0.1    17.0      jne	.LBB10_43
       10    5.7    0.6    9.7       <total>


```
</details>

</details>

<details><summary>[3] Code Region - ProcessPixel</summary>

```
Iterations:        100
Instructions:      26000
Total Cycles:      16810
Total uOps:        29600

Dispatch Width:    6
uOps Per Cycle:    1.76
IPC:               1.55
Block RThroughput: 73.5


Cycles with backend pressure increase [ 95.52% ]
Throughput Bottlenecks: 
  Resource Pressure       [ 40.99% ]
  - ICXFPDivider  [ 1.20% ]
  - ICXPort0  [ 28.51% ]
  - ICXPort1  [ 29.11% ]
  - ICXPort2  [ 1.78% ]
  - ICXPort3  [ 1.78% ]
  - ICXPort5  [ 21.99% ]
  - ICXPort6  [ 1.78% ]
  Data Dependencies:      [ 69.41% ]
  - Register Dependencies [ 69.41% ]
  - Memory Dependencies   [ 0.00% ]

```

<details><summary>Critical sequence based on the simulation:</summary>

```

              Instruction                                 Dependency Information
        0.    cmp	r9d, ecx
        1.    jge	.LBB26_20
        2.    vmulps	xmm5, xmm2, xmm2
        3.    vmulss	xmm16, xmm3, xmm3
        4.    vmulss	xmm21, xmm1, xmm1
        5.    vaddss	xmm21, xmm21, xmm5
        6.    vmovss	xmm4, dword ptr [rip + .LCPI26_0]
        7.    vdivss	xmm21, xmm4, xmm21
        8.    vmovshdup	xmm22, xmm2
        9.    vmovshdup	xmm5, xmm5
        10.   vaddss	xmm5, xmm16, xmm5
        11.   vdivss	xmm16, xmm4, xmm5
        12.   vmulss	xmm1, xmm1, xmm21
        13.   vmulss	xmm2, xmm2, xmm21
        14.   vmovss	dword ptr [rsp + 68], xmm2
        15.   vmulss	xmm2, xmm22, xmm16
        16.   vmulss	xmm3, xmm3, xmm16
        17.   vmovss	dword ptr [rsp + 64], xmm3
        18.   vbroadcastss	xmm17, xmm17
        19.   vbroadcastss	xmm18, xmm18
        20.   vbroadcastss	xmm19, xmm19
        21.   vbroadcastss	xmm20, xmm20
        22.   vbroadcastss	xmm21, xmm1
        23.   vbroadcastss	xmm22, xmm2
        24.   vpbroadcastd	xmm23, r11d
        25.   add	r15d, -2
        26.   vcvtsi2ss	xmm1, xmm0, r15d
        27.   vbroadcastss	xmm24, xmm1
        28.   add	edi, -2
        29.   vcvtsi2ss	xmm1, xmm0, edi
        30.   vbroadcastss	xmm25, xmm1
        31.   lea	eax, [rbx + rbx]
        32.   lea	edx, [r9 + 1]
        33.   lea	esi, [r9 + 2]
        34.   lea	edi, [r9 + 3]
        35.   vmovd	xmm1, r9d
        36.   vpinsrd	xmm1, xmm1, edx, 1
        37.   vpinsrd	xmm1, xmm1, esi, 2
        38.   vpinsrd	xmm1, xmm1, edi, 3
        39.   vbroadcastss	xmm0, xmm0
        40.   vcvtdq2ps	xmm1, xmm1
        41.   vsubps	xmm0, xmm1, xmm0
        42.   vmovaps	xmmword ptr [rsp + 128], xmm0
        43.   mov	edx, r9d
        44.   mov	rsi, qword ptr [rsp + 96]
        45.   lea	rdx, [rsi + 4*rdx]
        46.   imul	ebx, r10d
        47.   add	rbx, rdx
        48.   vpbroadcastq	ymm27, r12
        49.   jmp	.LBB26_15
        50.   add	rbx, rax
        51.   add	r10d, 2
        52.   cmp	r10d, r8d
        53.   jge	.LBB26_20
        54.   vcvtsi2ss	xmm0, xmm28, r10d
        55.   vsubss	xmm0, xmm0, dword ptr [rsp + 144]
        56.   vmulss	xmm1, xmm0, dword ptr [rsp + 68]
        57.   vbroadcastss	xmm28, xmm1
        58.   vmulss	xmm0, xmm0, dword ptr [rsp + 64]
        59.   vbroadcastss	xmm29, xmm0
        60.   mov	edx, r9d
        61.   kmovq	k2, k0
        62.   vmovaps	xmm30, xmmword ptr [rsp + 128]
        63.   mov	r13, rbx
        64.   jmp	.LBB26_16
        65.   add	r13, 16
        66.   add	edx, 4
        67.   cmp	edx, ecx
        68.   jge	.LBB26_19
        69.   vmulps	xmm0, xmm21, xmm30
        70.   vaddps	xmm1, xmm28, xmm0
        71.   vmulps	xmm2, xmm22, xmm30
        72.   vbroadcastss	xmm0, dword ptr [rip + .LCPI26_0]
        73.   vaddps	xmm2, xmm29, xmm2
        74.   vcmpleps	k2 {k2}, xmm1, xmm0
        75.   vcmpleps	k2 {k2}, xmm6, xmm1
        76.   vcmpleps	k2 {k2}, xmm6, xmm2
        77.   vcmpleps	k2 {k2}, xmm2, xmm0
        78.   vmaxps	xmm1, xmm1, xmm6
        79.   vminps	xmm1, xmm1, xmm0
        80.   vmulps	xmm1, xmm24, xmm1
        81.   vmaxps	xmm2, xmm2, xmm6
        82.   vminps	xmm2, xmm2, xmm0
 +----< 83.   vbroadcastss	xmm3, dword ptr [rip + .LCPI26_1]
 |      84.   vmulps	xmm2, xmm25, xmm2
 |      85.   vaddps	xmm1, xmm1, xmm3
 +----> 86.   vaddps	xmm2, xmm2, xmm3                  ## REGISTER dependency:  xmm3
 |      87.   vcvttps2dq	xmm3, xmm1
 |      88.   vcvtdq2ps	xmm31, xmm3
 |      89.   vsubps	xmm31, xmm1, xmm31
 +----> 90.   vcvttps2dq	xmm1, xmm2                        ## REGISTER dependency:  xmm2
 |      91.   vcvtdq2ps	xmm7, xmm1
 |      92.   vsubps	xmm12, xmm2, xmm7
 |      93.   vpslld	xmm2, xmm3, 2
 +----> 94.   vpmulld	xmm1, xmm23, xmm1                 ## REGISTER dependency:  xmm1
 +----> 95.   vpaddd	xmm7, xmm2, xmm1                  ## REGISTER dependency:  xmm1
 |      96.   vpmovsxdq	ymm1, xmm7
 |      97.   vpaddq	ymm1, ymm27, ymm1
 |      98.   vpextrq	rsi, xmm1, 1
 |      99.   vmovq	rdi, xmm1
 |      100.  vextracti128	xmm1, ymm1, 1
 |      101.  vpextrq	r15, xmm1, 1
 |      102.  vmovq	r14, xmm1
 |      103.  vmovd	xmm1, dword ptr [rdi + 4]
 |      104.  vpinsrd	xmm1, xmm1, dword ptr [rsi + 4], 1
 |      105.  vpinsrd	xmm1, xmm1, dword ptr [r14 + 4], 2
 |      106.  vpinsrd	xmm1, xmm1, dword ptr [r15 + 4], 3
 |      107.  vpxor	xmm11, xmm11, xmm11
 |      108.  vmovd	xmm2, dword ptr [rdi + r11]
 |      109.  vpinsrd	xmm2, xmm2, dword ptr [rsi + r11], 1
 |      110.  vpinsrd	xmm2, xmm2, dword ptr [r14 + r11], 2
 |      111.  vpinsrd	xmm2, xmm2, dword ptr [r15 + r11], 3
 |      112.  kxnorw	k3, k0, k0
 |      113.  vmovd	xmm3, dword ptr [rdi + r11 + 4]
 |      114.  vpinsrd	xmm3, xmm3, dword ptr [rsi + r11 + 4], 1
 |      115.  vpinsrd	xmm3, xmm3, dword ptr [r14 + r11 + 4], 2
 |      116.  vpinsrd	xmm3, xmm3, dword ptr [r15 + r11 + 4], 3
 +----> 117.  vpgatherdd	xmm11 {k3}, xmmword ptr [r12 + xmm7] ## REGISTER dependency:  xmm7
 |      118.  vpbroadcastw	xmm7, word ptr [rip + .LCPI26_2]
 |      119.  vpand	xmm8, xmm11, xmm7
 |      120.  vpmullw	xmm13, xmm8, xmm8
 +----> 121.  vpsrlw	xmm8, xmm11, 8                    ## REGISTER dependency:  xmm11
 +----> 122.  vpmullw	xmm8, xmm8, xmm8                  ## REGISTER dependency:  xmm8
 |      123.  vpand	xmm14, xmm1, xmm7
 +----> 124.  vpmullw	xmm14, xmm14, xmm14               ## RESOURCE interference:  ICXPort0 [ probability: 100% ]
 |      125.  vpand	xmm15, xmm2, xmm7
 |      126.  vpmullw	xmm15, xmm15, xmm15
 |      127.  vpand	xmm7, xmm3, xmm7
 |      128.  vpmullw	xmm7, xmm7, xmm7
 |      129.  vpsrld	xmm4, xmm13, 16
 |      130.  vcvtdq2ps	xmm4, xmm4
 |      131.  vsubps	xmm5, xmm0, xmm31
 |      132.  vsubps	xmm16, xmm0, xmm12
 |      133.  vmulps	xmm26, xmm16, xmm5
 |      134.  vmulps	xmm16, xmm31, xmm16
 |      135.  vmulps	xmm5, xmm12, xmm5
 |      136.  vmulps	xmm12, xmm12, xmm31
 |      137.  vpsrld	xmm31, xmm14, 16
 |      138.  vcvtdq2ps	xmm31, xmm31
 |      139.  vmulps	xmm4, xmm26, xmm4
 |      140.  vmulps	xmm31, xmm16, xmm31
 |      141.  vaddps	xmm4, xmm4, xmm31
 |      142.  vpsrld	xmm31, xmm15, 16
 |      143.  vcvtdq2ps	xmm31, xmm31
 |      144.  vmulps	xmm31, xmm5, xmm31
 |      145.  vaddps	xmm4, xmm4, xmm31
 |      146.  vpsrld	xmm31, xmm7, 16
 |      147.  vcvtdq2ps	xmm31, xmm31
 |      148.  vmulps	xmm31, xmm12, xmm31
 |      149.  vaddps	xmm4, xmm4, xmm31
 |      150.  vpsrlw	xmm31, xmm1, 8
 +----> 151.  vpmullw	xmm9, xmm31, xmm31                ## RESOURCE interference:  ICXPort1 [ probability: 100% ]
 |      152.  vpblendw	xmm8, xmm8, xmm6, 170
 |      153.  vcvtdq2ps	xmm31, xmm8
 +----> 154.  vpblendw	xmm8, xmm9, xmm6, 170             ## REGISTER dependency:  xmm9
 +----> 155.  vcvtdq2ps	xmm8, xmm8                        ## REGISTER dependency:  xmm8
 |      156.  vmulps	xmm31, xmm26, xmm31
 +----> 157.  vmulps	xmm8, xmm16, xmm8                 ## REGISTER dependency:  xmm8
 |      158.  vaddps	xmm31, xmm31, xmm8
 |      159.  vpsrlw	xmm8, xmm2, 8
 |      160.  vpmullw	xmm8, xmm8, xmm8
 |      161.  vpblendw	xmm8, xmm8, xmm6, 170
 |      162.  vcvtdq2ps	xmm8, xmm8
 |      163.  vmulps	xmm8, xmm8, xmm5
 |      164.  vaddps	xmm31, xmm31, xmm8
 |      165.  vpsrlw	xmm8, xmm3, 8
 |      166.  vpmullw	xmm8, xmm8, xmm8
 |      167.  vpblendw	xmm8, xmm8, xmm6, 170
 |      168.  vcvtdq2ps	xmm8, xmm8
 |      169.  vmulps	xmm8, xmm12, xmm8
 |      170.  vaddps	xmm8, xmm31, xmm8
 |      171.  vpblendw	xmm9, xmm13, xmm6, 170
 +----> 172.  vcvtdq2ps	xmm31, xmm9                       ## RESOURCE interference:  ICXPort1 [ probability: 100% ]
 |      173.  vpblendw	xmm9, xmm14, xmm6, 170
 |      174.  vcvtdq2ps	xmm9, xmm9
 +----> 175.  vmulps	xmm31, xmm26, xmm31               ## REGISTER dependency:  xmm31
 |      176.  vmulps	xmm9, xmm16, xmm9
 |      177.  vaddps	xmm31, xmm31, xmm9
 |      178.  vpblendw	xmm9, xmm15, xmm6, 170
 |      179.  vcvtdq2ps	xmm9, xmm9
 |      180.  vmulps	xmm9, xmm9, xmm5
 |      181.  vaddps	xmm31, xmm31, xmm9
 |      182.  vpblendw	xmm7, xmm7, xmm6, 170
 |      183.  vcvtdq2ps	xmm7, xmm7
 |      184.  vmulps	xmm7, xmm12, xmm7
 |      185.  vaddps	xmm7, xmm31, xmm7
 |      186.  vpsrld	xmm31, xmm11, 24
 +----> 187.  vcvtdq2ps	xmm31, xmm31                      ## RESOURCE interference:  ICXPort0 [ probability: 100% ]
 +----> 188.  vmulps	xmm26, xmm26, xmm31               ## REGISTER dependency:  xmm31
 |      189.  vpsrld	xmm1, xmm1, 24
 |      190.  vcvtdq2ps	xmm1, xmm1
 |      191.  vmulps	xmm1, xmm16, xmm1
 |      192.  vaddps	xmm1, xmm26, xmm1
 +----> 193.  vpsrld	xmm2, xmm2, 24                    ## RESOURCE interference:  ICXPort0 [ probability: 100% ]
 +----> 194.  vcvtdq2ps	xmm2, xmm2                        ## REGISTER dependency:  xmm2
 |      195.  vmulps	xmm2, xmm5, xmm2
 |      196.  vaddps	xmm1, xmm1, xmm2
 |      197.  vmovdqu64	xmm31, xmmword ptr [r13]
 +----> 198.  vpsrld	xmm2, xmm3, 24                    ## RESOURCE interference:  ICXPort1 [ probability: 100% ]
 +----> 199.  vcvtdq2ps	xmm2, xmm2                        ## REGISTER dependency:  xmm2
 +----> 200.  vmulps	xmm2, xmm12, xmm2                 ## REGISTER dependency:  xmm2
 |      201.  vpandd	xmm3, xmm31, dword ptr [rip + .LCPI26_3]{1to4}
 |      202.  vmulps	xmm4, xmm17, xmm4
 |      203.  vmulps	xmm5, xmm18, xmm8
 |      204.  vmulps	xmm16, xmm19, xmm7
 +----> 205.  vaddps	xmm1, xmm1, xmm2                  ## REGISTER dependency:  xmm2
 |      206.  vmulps	xmm26, xmm20, xmm1
 |      207.  vmaxps	xmm1, xmm4, xmm6
 |      208.  vbroadcastss	xmm2, dword ptr [rip + .LCPI26_6]
 |      209.  vminps	xmm1, xmm1, xmm2
 |      210.  vmaxps	xmm4, xmm5, xmm6
 |      211.  vminps	xmm4, xmm4, xmm2
 |      212.  vmaxps	xmm5, xmm16, xmm6
 |      213.  vminps	xmm5, xmm5, xmm2
 |      214.  vmulps	xmm2, xmm26, dword ptr [rip + .LCPI26_7]{1to4}
 |      215.  vaddps	xmm16, xmm2, xmm0
 |      216.  vpshufb	xmm0, xmm31, xmm10
 |      217.  vcvtdq2ps	xmm0, xmm0
 |      218.  vmulps	xmm0, xmm0, xmm0
 |      219.  vmulps	xmm0, xmm0, xmm16
 |      220.  vaddps	xmm1, xmm0, xmm1
 |      221.  vpshufb	xmm0, xmm31, xmmword ptr [rip + .LCPI26_4]
 |      222.  vcvtdq2ps	xmm0, xmm0
 |      223.  vmulps	xmm0, xmm0, xmm0
 |      224.  vmulps	xmm0, xmm0, xmm16
 |      225.  vaddps	xmm2, xmm0, xmm4
 |      226.  vcvtdq2ps	xmm0, xmm3
 |      227.  vmulps	xmm0, xmm0, xmm0
 |      228.  vmulps	xmm0, xmm0, xmm16
 |      229.  vaddps	xmm3, xmm0, xmm5
 |      230.  vmovaps	xmm0, xmm1
 |      231.  rsqrtps	xmm0, xmm0
 |      232.  vmulps	xmm1, xmm0, xmm1
 |      233.  vmovaps	xmm0, xmm2
 |      234.  rsqrtps	xmm0, xmm0
 |      235.  vmulps	xmm2, xmm0, xmm2
 |      236.  vmovaps	xmm0, xmm3
 |      237.  rsqrtps	xmm0, xmm0
 |      238.  vmulps	xmm0, xmm0, xmm3
 |      239.  cvtps2dq	xmm1, xmm1
 |      240.  cvtps2dq	xmm2, xmm2
 |      241.  cvtps2dq	xmm0, xmm0
 |      242.  vpslld	xmm1, xmm1, 16
 |      243.  vpslld	xmm2, xmm2, 8
 |      244.  vpternlogd	xmm2, xmm0, xmm1, 254
 |      245.  vpsrld	xmm0, xmm31, 24
 |      246.  vcvtdq2ps	xmm0, xmm0
 |      247.  vmulps	xmm0, xmm16, xmm0
 |      248.  vaddps	xmm0, xmm26, xmm0
 |      249.  cvtps2dq	xmm0, xmm0
 |      250.  vpslld	xmm0, xmm0, 24
 |      251.  vpord	xmm31 {k2}, xmm2, xmm0
 |      252.  vmovdqa64	xmmword ptr [r13], xmm31
 |      253.  kxnorw	k2, k0, k0
 +----> 254.  vaddps	xmm30, xmm30, dword ptr [rip + .LCPI26_8]{1to4} ## RESOURCE interference:  ICXPort1 [ probability: 99% ]
 |      255.  lea	esi, [rdx + 8]
 |      256.  cmp	esi, ecx
 |      257.  jl	.LBB26_18
 |      258.  kmovq	k2, k1
 |      259.  jmp	.LBB26_18
 |
 |    < loop carried > 
 |
 +----> 31.   lea	eax, [rbx + rbx]                  ## RESOURCE interference:  ICXPort1 [ probability: 99% ]


```
</details>

<details><summary>Instruction Info:</summary>

```
[1]: #uOps
[2]: Latency
[3]: RThroughput
[4]: MayLoad
[5]: MayStore
[6]: HasSideEffects (U)

[1]    [2]    [3]    [4]    [5]    [6]    Instructions:
 1      1     0.25                        cmp	r9d, ecx
 1      1     0.50                        jge	.LBB26_20
 1      4     0.50                        vmulps	xmm5, xmm2, xmm2
 1      4     0.50                        vmulss	xmm16, xmm3, xmm3
 1      4     0.50                        vmulss	xmm21, xmm1, xmm1
 1      4     0.50                        vaddss	xmm21, xmm21, xmm5
 1      5     0.50    *                   vmovss	xmm4, dword ptr [rip + .LCPI26_0]
 1      11    3.00                        vdivss	xmm21, xmm4, xmm21
 1      1     0.50                        vmovshdup	xmm22, xmm2
 1      1     0.50                        vmovshdup	xmm5, xmm5
 1      4     0.50                        vaddss	xmm5, xmm16, xmm5
 1      11    3.00                        vdivss	xmm16, xmm4, xmm5
 1      4     0.50                        vmulss	xmm1, xmm1, xmm21
 1      4     0.50                        vmulss	xmm2, xmm2, xmm21
 2      1     0.50           *            vmovss	dword ptr [rsp + 68], xmm2
 1      4     0.50                        vmulss	xmm2, xmm22, xmm16
 1      4     0.50                        vmulss	xmm3, xmm3, xmm16
 2      1     0.50           *            vmovss	dword ptr [rsp + 64], xmm3
 1      3     1.00                        vbroadcastss	xmm17, xmm17
 1      3     1.00                        vbroadcastss	xmm18, xmm18
 1      3     1.00                        vbroadcastss	xmm19, xmm19
 1      3     1.00                        vbroadcastss	xmm20, xmm20
 1      3     1.00                        vbroadcastss	xmm21, xmm1
 1      3     1.00                        vbroadcastss	xmm22, xmm2
 1      1     1.00                        vpbroadcastd	xmm23, r11d
 1      1     0.25                        add	r15d, -2
 2      5     1.00                        vcvtsi2ss	xmm1, xmm0, r15d
 1      3     1.00                        vbroadcastss	xmm24, xmm1
 1      1     0.25                        add	edi, -2
 2      5     1.00                        vcvtsi2ss	xmm1, xmm0, edi
 1      3     1.00                        vbroadcastss	xmm25, xmm1
 1      1     0.50                        lea	eax, [rbx + rbx]
 1      1     0.50                        lea	edx, [r9 + 1]
 1      1     0.50                        lea	esi, [r9 + 2]
 1      1     0.50                        lea	edi, [r9 + 3]
 1      1     1.00                        vmovd	xmm1, r9d
 2      2     2.00                        vpinsrd	xmm1, xmm1, edx, 1
 2      2     2.00                        vpinsrd	xmm1, xmm1, esi, 2
 2      2     2.00                        vpinsrd	xmm1, xmm1, edi, 3
 1      1     0.50                        vbroadcastss	xmm0, xmm0
 1      4     0.50                        vcvtdq2ps	xmm1, xmm1
 1      4     0.50                        vsubps	xmm0, xmm1, xmm0
 2      1     0.50           *            vmovaps	xmmword ptr [rsp + 128], xmm0
 1      1     0.25                        mov	edx, r9d
 1      5     0.50    *                   mov	rsi, qword ptr [rsp + 96]
 1      1     0.50                        lea	rdx, [rsi + 4*rdx]
 1      3     1.00                        imul	ebx, r10d
 1      1     0.25                        add	rbx, rdx
 1      3     1.00                        vpbroadcastq	ymm27, r12
 1      1     0.50                        jmp	.LBB26_15
 1      1     0.25                        add	rbx, rax
 1      1     0.25                        add	r10d, 2
 1      1     0.25                        cmp	r10d, r8d
 1      1     0.50                        jge	.LBB26_20
 2      5     1.00                        vcvtsi2ss	xmm0, xmm28, r10d
 2      9     0.50    *                   vsubss	xmm0, xmm0, dword ptr [rsp + 144]
 2      9     0.50    *                   vmulss	xmm1, xmm0, dword ptr [rsp + 68]
 1      3     1.00                        vbroadcastss	xmm28, xmm1
 2      9     0.50    *                   vmulss	xmm0, xmm0, dword ptr [rsp + 64]
 1      3     1.00                        vbroadcastss	xmm29, xmm0
 1      1     0.25                        mov	edx, r9d
 1      1     1.00                        kmovq	k2, k0
 2      7     0.50    *                   vmovaps	xmm30, xmmword ptr [rsp + 128]
 1      1     0.25                        mov	r13, rbx
 1      1     0.50                        jmp	.LBB26_16
 1      1     0.25                        add	r13, 16
 1      1     0.25                        add	edx, 4
 1      1     0.25                        cmp	edx, ecx
 1      1     0.50                        jge	.LBB26_19
 1      4     0.50                        vmulps	xmm0, xmm21, xmm30
 1      4     0.50                        vaddps	xmm1, xmm28, xmm0
 1      4     0.50                        vmulps	xmm2, xmm22, xmm30
 1      6     0.50    *                   vbroadcastss	xmm0, dword ptr [rip + .LCPI26_0]
 1      4     0.50                        vaddps	xmm2, xmm29, xmm2
 1      4     1.00                        vcmpleps	k2 {k2}, xmm1, xmm0
 1      4     1.00                        vcmpleps	k2 {k2}, xmm6, xmm1
 1      4     1.00                        vcmpleps	k2 {k2}, xmm6, xmm2
 1      4     1.00                        vcmpleps	k2 {k2}, xmm2, xmm0
 1      4     0.50                        vmaxps	xmm1, xmm1, xmm6
 1      4     0.50                        vminps	xmm1, xmm1, xmm0
 1      4     0.50                        vmulps	xmm1, xmm24, xmm1
 1      4     0.50                        vmaxps	xmm2, xmm2, xmm6
 1      4     0.50                        vminps	xmm2, xmm2, xmm0
 1      6     0.50    *                   vbroadcastss	xmm3, dword ptr [rip + .LCPI26_1]
 1      4     0.50                        vmulps	xmm2, xmm25, xmm2
 1      4     0.50                        vaddps	xmm1, xmm1, xmm3
 1      4     0.50                        vaddps	xmm2, xmm2, xmm3
 1      4     0.50                        vcvttps2dq	xmm3, xmm1
 1      4     0.50                        vcvtdq2ps	xmm31, xmm3
 1      4     0.50                        vsubps	xmm31, xmm1, xmm31
 1      4     0.50                        vcvttps2dq	xmm1, xmm2
 1      4     0.50                        vcvtdq2ps	xmm7, xmm1
 1      4     0.50                        vsubps	xmm12, xmm2, xmm7
 1      1     0.50                        vpslld	xmm2, xmm3, 2
 2      10    1.00                        vpmulld	xmm1, xmm23, xmm1
 1      1     0.33                        vpaddd	xmm7, xmm2, xmm1
 1      3     1.00                        vpmovsxdq	ymm1, xmm7
 1      1     0.33                        vpaddq	ymm1, ymm27, ymm1
 2      3     1.00                        vpextrq	rsi, xmm1, 1
 1      2     1.00                        vmovq	rdi, xmm1
 1      3     1.00                        vextracti128	xmm1, ymm1, 1
 2      3     1.00                        vpextrq	r15, xmm1, 1
 1      2     1.00                        vmovq	r14, xmm1
 1      5     0.50    *                   vmovd	xmm1, dword ptr [rdi + 4]
 2      6     1.00    *                   vpinsrd	xmm1, xmm1, dword ptr [rsi + 4], 1
 2      6     1.00    *                   vpinsrd	xmm1, xmm1, dword ptr [r14 + 4], 2
 2      6     1.00    *                   vpinsrd	xmm1, xmm1, dword ptr [r15 + 4], 3
 1      0     0.17                        vpxor	xmm11, xmm11, xmm11
 1      5     0.50    *                   vmovd	xmm2, dword ptr [rdi + r11]
 2      6     1.00    *                   vpinsrd	xmm2, xmm2, dword ptr [rsi + r11], 1
 2      6     1.00    *                   vpinsrd	xmm2, xmm2, dword ptr [r14 + r11], 2
 2      6     1.00    *                   vpinsrd	xmm2, xmm2, dword ptr [r15 + r11], 3
 1      1     1.00                        kxnorw	k3, k0, k0
 1      5     0.50    *                   vmovd	xmm3, dword ptr [rdi + r11 + 4]
 2      6     1.00    *                   vpinsrd	xmm3, xmm3, dword ptr [rsi + r11 + 4], 1
 2      6     1.00    *                   vpinsrd	xmm3, xmm3, dword ptr [r14 + r11 + 4], 2
 2      6     1.00    *                   vpinsrd	xmm3, xmm3, dword ptr [r15 + r11 + 4], 3
 5      19    2.00    *                   vpgatherdd	xmm11 {k3}, xmmword ptr [r12 + xmm7]
 2      7     1.00    *                   vpbroadcastw	xmm7, word ptr [rip + .LCPI26_2]
 1      1     0.33                        vpand	xmm8, xmm11, xmm7
 1      5     0.50                        vpmullw	xmm13, xmm8, xmm8
 1      1     0.50                        vpsrlw	xmm8, xmm11, 8
 1      5     0.50                        vpmullw	xmm8, xmm8, xmm8
 1      1     0.33                        vpand	xmm14, xmm1, xmm7
 1      5     0.50                        vpmullw	xmm14, xmm14, xmm14
 1      1     0.33                        vpand	xmm15, xmm2, xmm7
 1      5     0.50                        vpmullw	xmm15, xmm15, xmm15
 1      1     0.33                        vpand	xmm7, xmm3, xmm7
 1      5     0.50                        vpmullw	xmm7, xmm7, xmm7
 1      1     0.50                        vpsrld	xmm4, xmm13, 16
 1      4     0.50                        vcvtdq2ps	xmm4, xmm4
 1      4     0.50                        vsubps	xmm5, xmm0, xmm31
 1      4     0.50                        vsubps	xmm16, xmm0, xmm12
 1      4     0.50                        vmulps	xmm26, xmm16, xmm5
 1      4     0.50                        vmulps	xmm16, xmm31, xmm16
 1      4     0.50                        vmulps	xmm5, xmm12, xmm5
 1      4     0.50                        vmulps	xmm12, xmm12, xmm31
 1      1     0.50                        vpsrld	xmm31, xmm14, 16
 1      4     0.50                        vcvtdq2ps	xmm31, xmm31
 1      4     0.50                        vmulps	xmm4, xmm26, xmm4
 1      4     0.50                        vmulps	xmm31, xmm16, xmm31
 1      4     0.50                        vaddps	xmm4, xmm4, xmm31
 1      1     0.50                        vpsrld	xmm31, xmm15, 16
 1      4     0.50                        vcvtdq2ps	xmm31, xmm31
 1      4     0.50                        vmulps	xmm31, xmm5, xmm31
 1      4     0.50                        vaddps	xmm4, xmm4, xmm31
 1      1     0.50                        vpsrld	xmm31, xmm7, 16
 1      4     0.50                        vcvtdq2ps	xmm31, xmm31
 1      4     0.50                        vmulps	xmm31, xmm12, xmm31
 1      4     0.50                        vaddps	xmm4, xmm4, xmm31
 1      1     0.50                        vpsrlw	xmm31, xmm1, 8
 1      5     0.50                        vpmullw	xmm9, xmm31, xmm31
 1      1     1.00                        vpblendw	xmm8, xmm8, xmm6, 170
 1      4     0.50                        vcvtdq2ps	xmm31, xmm8
 1      1     1.00                        vpblendw	xmm8, xmm9, xmm6, 170
 1      4     0.50                        vcvtdq2ps	xmm8, xmm8
 1      4     0.50                        vmulps	xmm31, xmm26, xmm31
 1      4     0.50                        vmulps	xmm8, xmm16, xmm8
 1      4     0.50                        vaddps	xmm31, xmm31, xmm8
 1      1     0.50                        vpsrlw	xmm8, xmm2, 8
 1      5     0.50                        vpmullw	xmm8, xmm8, xmm8
 1      1     1.00                        vpblendw	xmm8, xmm8, xmm6, 170
 1      4     0.50                        vcvtdq2ps	xmm8, xmm8
 1      4     0.50                        vmulps	xmm8, xmm8, xmm5
 1      4     0.50                        vaddps	xmm31, xmm31, xmm8
 1      1     0.50                        vpsrlw	xmm8, xmm3, 8
 1      5     0.50                        vpmullw	xmm8, xmm8, xmm8
 1      1     1.00                        vpblendw	xmm8, xmm8, xmm6, 170
 1      4     0.50                        vcvtdq2ps	xmm8, xmm8
 1      4     0.50                        vmulps	xmm8, xmm12, xmm8
 1      4     0.50                        vaddps	xmm8, xmm31, xmm8
 1      1     1.00                        vpblendw	xmm9, xmm13, xmm6, 170
 1      4     0.50                        vcvtdq2ps	xmm31, xmm9
 1      1     1.00                        vpblendw	xmm9, xmm14, xmm6, 170
 1      4     0.50                        vcvtdq2ps	xmm9, xmm9
 1      4     0.50                        vmulps	xmm31, xmm26, xmm31
 1      4     0.50                        vmulps	xmm9, xmm16, xmm9
 1      4     0.50                        vaddps	xmm31, xmm31, xmm9
 1      1     1.00                        vpblendw	xmm9, xmm15, xmm6, 170
 1      4     0.50                        vcvtdq2ps	xmm9, xmm9
 1      4     0.50                        vmulps	xmm9, xmm9, xmm5
 1      4     0.50                        vaddps	xmm31, xmm31, xmm9
 1      1     1.00                        vpblendw	xmm7, xmm7, xmm6, 170
 1      4     0.50                        vcvtdq2ps	xmm7, xmm7
 1      4     0.50                        vmulps	xmm7, xmm12, xmm7
 1      4     0.50                        vaddps	xmm7, xmm31, xmm7
 1      1     0.50                        vpsrld	xmm31, xmm11, 24
 1      4     0.50                        vcvtdq2ps	xmm31, xmm31
 1      4     0.50                        vmulps	xmm26, xmm26, xmm31
 1      1     0.50                        vpsrld	xmm1, xmm1, 24
 1      4     0.50                        vcvtdq2ps	xmm1, xmm1
 1      4     0.50                        vmulps	xmm1, xmm16, xmm1
 1      4     0.50                        vaddps	xmm1, xmm26, xmm1
 1      1     0.50                        vpsrld	xmm2, xmm2, 24
 1      4     0.50                        vcvtdq2ps	xmm2, xmm2
 1      4     0.50                        vmulps	xmm2, xmm5, xmm2
 1      4     0.50                        vaddps	xmm1, xmm1, xmm2
 2      7     0.50    *                   vmovdqu64	xmm31, xmmword ptr [r13]
 1      1     0.50                        vpsrld	xmm2, xmm3, 24
 1      4     0.50                        vcvtdq2ps	xmm2, xmm2
 1      4     0.50                        vmulps	xmm2, xmm12, xmm2
 2      7     0.50    *                   vpandd	xmm3, xmm31, dword ptr [rip + .LCPI26_3]{1to4}
 1      4     0.50                        vmulps	xmm4, xmm17, xmm4
 1      4     0.50                        vmulps	xmm5, xmm18, xmm8
 1      4     0.50                        vmulps	xmm16, xmm19, xmm7
 1      4     0.50                        vaddps	xmm1, xmm1, xmm2
 1      4     0.50                        vmulps	xmm26, xmm20, xmm1
 1      4     0.50                        vmaxps	xmm1, xmm4, xmm6
 1      6     0.50    *                   vbroadcastss	xmm2, dword ptr [rip + .LCPI26_6]
 1      4     0.50                        vminps	xmm1, xmm1, xmm2
 1      4     0.50                        vmaxps	xmm4, xmm5, xmm6
 1      4     0.50                        vminps	xmm4, xmm4, xmm2
 1      4     0.50                        vmaxps	xmm5, xmm16, xmm6
 1      4     0.50                        vminps	xmm5, xmm5, xmm2
 2      10    0.50    *                   vmulps	xmm2, xmm26, dword ptr [rip + .LCPI26_7]{1to4}
 1      4     0.50                        vaddps	xmm16, xmm2, xmm0
 1      1     0.50                        vpshufb	xmm0, xmm31, xmm10
 1      4     0.50                        vcvtdq2ps	xmm0, xmm0
 1      4     0.50                        vmulps	xmm0, xmm0, xmm0
 1      4     0.50                        vmulps	xmm0, xmm0, xmm16
 1      4     0.50                        vaddps	xmm1, xmm0, xmm1
 2      7     0.50    *                   vpshufb	xmm0, xmm31, xmmword ptr [rip + .LCPI26_4]
 1      4     0.50                        vcvtdq2ps	xmm0, xmm0
 1      4     0.50                        vmulps	xmm0, xmm0, xmm0
 1      4     0.50                        vmulps	xmm0, xmm0, xmm16
 1      4     0.50                        vaddps	xmm2, xmm0, xmm4
 1      4     0.50                        vcvtdq2ps	xmm0, xmm3
 1      4     0.50                        vmulps	xmm0, xmm0, xmm0
 1      4     0.50                        vmulps	xmm0, xmm0, xmm16
 1      4     0.50                        vaddps	xmm3, xmm0, xmm5
 1      1     0.33                        vmovaps	xmm0, xmm1
 1      4     1.00                        rsqrtps	xmm0, xmm0
 1      4     0.50                        vmulps	xmm1, xmm0, xmm1
 1      1     0.33                        vmovaps	xmm0, xmm2
 1      4     1.00                        rsqrtps	xmm0, xmm0
 1      4     0.50                        vmulps	xmm2, xmm0, xmm2
 1      1     0.33                        vmovaps	xmm0, xmm3
 1      4     1.00                        rsqrtps	xmm0, xmm0
 1      4     0.50                        vmulps	xmm0, xmm0, xmm3
 1      4     0.50                        cvtps2dq	xmm1, xmm1
 1      4     0.50                        cvtps2dq	xmm2, xmm2
 1      4     0.50                        cvtps2dq	xmm0, xmm0
 1      1     0.50                        vpslld	xmm1, xmm1, 16
 1      1     0.50                        vpslld	xmm2, xmm2, 8
 1      1     0.33                        vpternlogd	xmm2, xmm0, xmm1, 254
 1      1     0.50                        vpsrld	xmm0, xmm31, 24
 1      4     0.50                        vcvtdq2ps	xmm0, xmm0
 1      4     0.50                        vmulps	xmm0, xmm16, xmm0
 1      4     0.50                        vaddps	xmm0, xmm26, xmm0
 1      4     0.50                        cvtps2dq	xmm0, xmm0
 1      1     0.50                        vpslld	xmm0, xmm0, 24
 1      1     0.33                        vpord	xmm31 {k2}, xmm2, xmm0
 2      1     0.50           *            vmovdqa64	xmmword ptr [r13], xmm31
 1      1     1.00                        kxnorw	k2, k0, k0
 2      10    0.50    *                   vaddps	xmm30, xmm30, dword ptr [rip + .LCPI26_8]{1to4}
 1      1     0.50                        lea	esi, [rdx + 8]
 1      1     0.25                        cmp	esi, ecx
 1      1     0.50                        jl	.LBB26_18
 1      1     1.00                        kmovq	k2, k1
 1      1     0.50                        jmp	.LBB26_18


```
</details>

<details><summary>Dynamic Dispatch Stall Cycles:</summary>

```
RAT     - Register unavailable:                      0
RCU     - Retire tokens unavailable:                 0
SCHEDQ  - Scheduler full:                            16430  (97.7%)
LQ      - Load queue full:                           0
SQ      - Store queue full:                          0
GROUP   - Static restrictions on the dispatch group: 0
USH     - Uncategorised Structural Hazard:           0


```
</details>

<details><summary>Dispatch Logic - number of cycles where we saw N micro opcodes dispatched:</summary>

```
[# dispatched], [# cycles]
 0,              4139  (24.6%)
 1,              3394  (20.2%)
 2,              4082  (24.3%)
 3,              3284  (19.5%)
 4,              1487  (8.8%)
 5,              302  (1.8%)
 6,              122  (0.7%)


```
</details>

<details><summary>Schedulers - number of cycles where we saw N micro opcodes issued:</summary>

```
[# issued], [# cycles]
 0,          4205  (25.0%)
 1,          2806  (16.7%)
 2,          5101  (30.3%)
 3,          2898  (17.2%)
 4,          1302  (7.7%)
 5,          298  (1.8%)
 6,          200  (1.2%)

```
</details>

<details><summary>Scheduler's queue usage:</summary>

```
[1] Resource name.
[2] Average number of used buffer entries.
[3] Maximum number of used buffer entries.
[4] Total number of buffer entries.

 [1]            [2]        [3]        [4]
ICXPortAny       59         60         60


```
</details>

<details><summary>Retire Control Unit - number of cycles where we saw N instructions retired:</summary>

```
[# retired], [# cycles]
 0,           9905  (58.9%)
 1,           3303  (19.6%)
 2,           802  (4.8%)
 3,           599  (3.6%)
 4,           1000  (5.9%)
 6,           100  (0.6%)
 7,           200  (1.2%)
 8,           201  (1.2%)
 9,           200  (1.2%)
 10,          99  (0.6%)
 11,          201  (1.2%)
 21,          100  (0.6%)
 33,          1  (0.0%)
 46,          99  (0.6%)

```
</details>

<details><summary>Total ROB Entries:                352</summary>

```
Max Used ROB Entries:             160  ( 45.5% )
Average Used ROB Entries per cy:  112  ( 31.8% )


```
</details>

<details><summary>Register File statistics:</summary>

```
Total number of mappings created:    25700
Max number of mappings used:         130


```
</details>

<details><summary>Resources:</summary>

```
[0]   - ICXDivider
[1]   - ICXFPDivider
[2]   - ICXPort0
[3]   - ICXPort1
[4]   - ICXPort2
[5]   - ICXPort3
[6]   - ICXPort4
[7]   - ICXPort5
[8]   - ICXPort6
[9]   - ICXPort7
[10]  - ICXPort8
[11]  - ICXPort9


Resource pressure per iteration:
[0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   
 -     6.00   89.01  84.07  17.00  14.00  2.00   68.93  15.99  2.00   2.00   2.00   

Resource pressure by instruction:
[0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   Instructions:
 -      -      -      -      -      -      -     0.99   0.01    -      -      -     cmp	r9d, ecx
 -      -      -      -      -      -      -      -     1.00    -      -      -     jge	.LBB26_20
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm5, xmm2, xmm2
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulss	xmm16, xmm3, xmm3
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulss	xmm21, xmm1, xmm1
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddss	xmm21, xmm21, xmm5
 -      -      -      -      -     1.00    -      -      -      -      -      -     vmovss	xmm4, dword ptr [rip + .LCPI26_0]
 -     3.00   1.00    -      -      -      -      -      -      -      -      -     vdivss	xmm21, xmm4, xmm21
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovshdup	xmm22, xmm2
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmovshdup	xmm5, xmm5
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vaddss	xmm5, xmm16, xmm5
 -     3.00   1.00    -      -      -      -      -      -      -      -      -     vdivss	xmm16, xmm4, xmm5
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulss	xmm1, xmm1, xmm21
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulss	xmm2, xmm2, xmm21
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   vmovss	dword ptr [rsp + 68], xmm2
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulss	xmm2, xmm22, xmm16
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulss	xmm3, xmm3, xmm16
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     vmovss	dword ptr [rsp + 64], xmm3
 -      -      -      -      -      -      -     1.00    -      -      -      -     vbroadcastss	xmm17, xmm17
 -      -      -      -      -      -      -     1.00    -      -      -      -     vbroadcastss	xmm18, xmm18
 -      -      -      -      -      -      -     1.00    -      -      -      -     vbroadcastss	xmm19, xmm19
 -      -      -      -      -      -      -     1.00    -      -      -      -     vbroadcastss	xmm20, xmm20
 -      -      -      -      -      -      -     1.00    -      -      -      -     vbroadcastss	xmm21, xmm1
 -      -      -      -      -      -      -     1.00    -      -      -      -     vbroadcastss	xmm22, xmm2
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpbroadcastd	xmm23, r11d
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     add	r15d, -2
 -      -     1.00    -      -      -      -     1.00    -      -      -      -     vcvtsi2ss	xmm1, xmm0, r15d
 -      -      -      -      -      -      -     1.00    -      -      -      -     vbroadcastss	xmm24, xmm1
 -      -      -      -      -      -      -      -     1.00    -      -      -     add	edi, -2
 -      -     0.99   0.01    -      -      -     1.00    -      -      -      -     vcvtsi2ss	xmm1, xmm0, edi
 -      -      -      -      -      -      -     1.00    -      -      -      -     vbroadcastss	xmm25, xmm1
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     lea	eax, [rbx + rbx]
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     lea	edx, [r9 + 1]
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     lea	esi, [r9 + 2]
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	edi, [r9 + 3]
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovd	xmm1, r9d
 -      -      -      -      -      -      -     2.00    -      -      -      -     vpinsrd	xmm1, xmm1, edx, 1
 -      -      -      -      -      -      -     2.00    -      -      -      -     vpinsrd	xmm1, xmm1, esi, 2
 -      -      -      -      -      -      -     2.00    -      -      -      -     vpinsrd	xmm1, xmm1, edi, 3
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     vbroadcastss	xmm0, xmm0
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm1, xmm1
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vsubps	xmm0, xmm1, xmm0
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   vmovaps	xmmword ptr [rsp + 128], xmm0
 -      -      -      -      -      -      -      -     1.00    -      -      -     mov	edx, r9d
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	rsi, qword ptr [rsp + 96]
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	rdx, [rsi + 4*rdx]
 -      -      -     1.00    -      -      -      -      -      -      -      -     imul	ebx, r10d
 -      -      -      -      -      -      -      -     1.00    -      -      -     add	rbx, rdx
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpbroadcastq	ymm27, r12
 -      -      -      -      -      -      -      -     1.00    -      -      -     jmp	.LBB26_15
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     add	rbx, rax
 -      -      -      -      -      -      -      -     1.00    -      -      -     add	r10d, 2
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     cmp	r10d, r8d
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     jge	.LBB26_20
 -      -      -     1.00    -      -      -     1.00    -      -      -      -     vcvtsi2ss	xmm0, xmm28, r10d
 -      -     1.00    -     0.01   0.99    -      -      -      -      -      -     vsubss	xmm0, xmm0, dword ptr [rsp + 144]
 -      -     0.01   0.99    -     1.00    -      -      -      -      -      -     vmulss	xmm1, xmm0, dword ptr [rsp + 68]
 -      -      -      -      -      -      -     1.00    -      -      -      -     vbroadcastss	xmm28, xmm1
 -      -     0.99   0.01   1.00    -      -      -      -      -      -      -     vmulss	xmm0, xmm0, dword ptr [rsp + 64]
 -      -      -      -      -      -      -     1.00    -      -      -      -     vbroadcastss	xmm29, xmm0
 -      -      -      -      -      -      -      -     1.00    -      -      -     mov	edx, r9d
 -      -     1.00    -      -      -      -      -      -      -      -      -     kmovq	k2, k0
 -      -     0.01   0.99   0.99   0.01    -      -      -      -      -      -     vmovaps	xmm30, xmmword ptr [rsp + 128]
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     mov	r13, rbx
 -      -      -      -      -      -      -      -     1.00    -      -      -     jmp	.LBB26_16
 -      -     0.01    -      -      -      -     0.99    -      -      -      -     add	r13, 16
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     add	edx, 4
 -      -      -     0.01    -      -      -      -     0.99    -      -      -     cmp	edx, ecx
 -      -      -      -      -      -      -      -     1.00    -      -      -     jge	.LBB26_19
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm21, xmm30
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vaddps	xmm1, xmm28, xmm0
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmulps	xmm2, xmm22, xmm30
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     vbroadcastss	xmm0, dword ptr [rip + .LCPI26_0]
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vaddps	xmm2, xmm29, xmm2
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpleps	k2 {k2}, xmm1, xmm0
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpleps	k2 {k2}, xmm6, xmm1
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpleps	k2 {k2}, xmm6, xmm2
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpleps	k2 {k2}, xmm2, xmm0
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmaxps	xmm1, xmm1, xmm6
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vminps	xmm1, xmm1, xmm0
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulps	xmm1, xmm24, xmm1
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmaxps	xmm2, xmm2, xmm6
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vminps	xmm2, xmm2, xmm0
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     vbroadcastss	xmm3, dword ptr [rip + .LCPI26_1]
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmulps	xmm2, xmm25, xmm2
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vaddps	xmm1, xmm1, xmm3
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vaddps	xmm2, xmm2, xmm3
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vcvttps2dq	xmm3, xmm1
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm31, xmm3
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vsubps	xmm31, xmm1, xmm31
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vcvttps2dq	xmm1, xmm2
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm7, xmm1
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vsubps	xmm12, xmm2, xmm7
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vpslld	xmm2, xmm3, 2
 -      -     1.98   0.02    -      -      -      -      -      -      -      -     vpmulld	xmm1, xmm23, xmm1
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpaddd	xmm7, xmm2, xmm1
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpmovsxdq	ymm1, xmm7
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpaddq	ymm1, ymm27, ymm1
 -      -     1.00    -      -      -      -     1.00    -      -      -      -     vpextrq	rsi, xmm1, 1
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmovq	rdi, xmm1
 -      -      -      -      -      -      -     1.00    -      -      -      -     vextracti128	xmm1, ymm1, 1
 -      -     1.00    -      -      -      -     1.00    -      -      -      -     vpextrq	r15, xmm1, 1
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmovq	r14, xmm1
 -      -      -      -      -     1.00    -      -      -      -      -      -     vmovd	xmm1, dword ptr [rdi + 4]
 -      -      -      -     1.00    -      -     1.00    -      -      -      -     vpinsrd	xmm1, xmm1, dword ptr [rsi + 4], 1
 -      -      -      -      -     1.00    -     1.00    -      -      -      -     vpinsrd	xmm1, xmm1, dword ptr [r14 + 4], 2
 -      -      -      -     1.00    -      -     1.00    -      -      -      -     vpinsrd	xmm1, xmm1, dword ptr [r15 + 4], 3
 -      -      -      -      -      -      -      -      -      -      -      -     vpxor	xmm11, xmm11, xmm11
 -      -      -      -      -     1.00    -      -      -      -      -      -     vmovd	xmm2, dword ptr [rdi + r11]
 -      -      -      -      -     1.00    -     1.00    -      -      -      -     vpinsrd	xmm2, xmm2, dword ptr [rsi + r11], 1
 -      -      -      -      -     1.00    -     1.00    -      -      -      -     vpinsrd	xmm2, xmm2, dword ptr [r14 + r11], 2
 -      -      -      -     1.00    -      -     1.00    -      -      -      -     vpinsrd	xmm2, xmm2, dword ptr [r15 + r11], 3
 -      -     1.00    -      -      -      -      -      -      -      -      -     kxnorw	k3, k0, k0
 -      -      -      -     1.00    -      -      -      -      -      -      -     vmovd	xmm3, dword ptr [rdi + r11 + 4]
 -      -      -      -     1.00    -      -     1.00    -      -      -      -     vpinsrd	xmm3, xmm3, dword ptr [rsi + r11 + 4], 1
 -      -      -      -      -     1.00    -     1.00    -      -      -      -     vpinsrd	xmm3, xmm3, dword ptr [r14 + r11 + 4], 2
 -      -      -      -     1.00    -      -     1.00    -      -      -      -     vpinsrd	xmm3, xmm3, dword ptr [r15 + r11 + 4], 3
 -      -     1.00   1.00   4.00    -      -      -     1.00    -      -      -     vpgatherdd	xmm11 {k3}, xmmword ptr [r12 + xmm7]
 -      -      -      -      -     1.00    -     1.00    -      -      -      -     vpbroadcastw	xmm7, word ptr [rip + .LCPI26_2]
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpand	xmm8, xmm11, xmm7
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpmullw	xmm13, xmm8, xmm8
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpsrlw	xmm8, xmm11, 8
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpmullw	xmm8, xmm8, xmm8
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpand	xmm14, xmm1, xmm7
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpmullw	xmm14, xmm14, xmm14
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpand	xmm15, xmm2, xmm7
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpmullw	xmm15, xmm15, xmm15
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpand	xmm7, xmm3, xmm7
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpmullw	xmm7, xmm7, xmm7
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpsrld	xmm4, xmm13, 16
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm4, xmm4
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vsubps	xmm5, xmm0, xmm31
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vsubps	xmm16, xmm0, xmm12
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm26, xmm16, xmm5
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm16, xmm31, xmm16
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmulps	xmm5, xmm12, xmm5
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulps	xmm12, xmm12, xmm31
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpsrld	xmm31, xmm14, 16
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm31, xmm31
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm4, xmm26, xmm4
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm31, xmm16, xmm31
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm4, xmm4, xmm31
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpsrld	xmm31, xmm15, 16
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm31, xmm31
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm31, xmm5, xmm31
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm4, xmm4, xmm31
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpsrld	xmm31, xmm7, 16
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm31, xmm31
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm31, xmm12, xmm31
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm4, xmm4, xmm31
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpsrlw	xmm31, xmm1, 8
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpmullw	xmm9, xmm31, xmm31
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm8, xmm8, xmm6, 170
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm31, xmm8
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm8, xmm9, xmm6, 170
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm8, xmm8
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm31, xmm26, xmm31
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm8, xmm16, xmm8
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm31, xmm31, xmm8
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpsrlw	xmm8, xmm2, 8
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpmullw	xmm8, xmm8, xmm8
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm8, xmm8, xmm6, 170
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm8, xmm8
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm8, xmm8, xmm5
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm31, xmm31, xmm8
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpsrlw	xmm8, xmm3, 8
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpmullw	xmm8, xmm8, xmm8
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm8, xmm8, xmm6, 170
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm8, xmm8
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm8, xmm12, xmm8
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm8, xmm31, xmm8
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm9, xmm13, xmm6, 170
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm31, xmm9
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm9, xmm14, xmm6, 170
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm9, xmm9
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm31, xmm26, xmm31
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm9, xmm16, xmm9
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm31, xmm31, xmm9
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm9, xmm15, xmm6, 170
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm9, xmm9
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm9, xmm9, xmm5
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm31, xmm31, xmm9
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm7, xmm7, xmm6, 170
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm7, xmm7
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm7, xmm12, xmm7
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm7, xmm31, xmm7
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpsrld	xmm31, xmm11, 24
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm31, xmm31
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm26, xmm26, xmm31
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpsrld	xmm1, xmm1, 24
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm1, xmm1
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm1, xmm16, xmm1
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm1, xmm26, xmm1
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpsrld	xmm2, xmm2, 24
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm2, xmm2
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm2, xmm5, xmm2
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm1, xmm1, xmm2
 -      -      -      -      -     1.00    -     1.00    -      -      -      -     vmovdqu64	xmm31, xmmword ptr [r13]
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpsrld	xmm2, xmm3, 24
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm2, xmm2
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm2, xmm12, xmm2
 -      -      -      -      -     1.00    -     1.00    -      -      -      -     vpandd	xmm3, xmm31, dword ptr [rip + .LCPI26_3]{1to4}
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm4, xmm17, xmm4
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm5, xmm18, xmm8
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm16, xmm19, xmm7
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm1, xmm1, xmm2
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm26, xmm20, xmm1
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmaxps	xmm1, xmm4, xmm6
 -      -      -      -     1.00    -      -      -      -      -      -      -     vbroadcastss	xmm2, dword ptr [rip + .LCPI26_6]
 -      -      -     1.00    -      -      -      -      -      -      -      -     vminps	xmm1, xmm1, xmm2
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmaxps	xmm4, xmm5, xmm6
 -      -     1.00    -      -      -      -      -      -      -      -      -     vminps	xmm4, xmm4, xmm2
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmaxps	xmm5, xmm16, xmm6
 -      -     1.00    -      -      -      -      -      -      -      -      -     vminps	xmm5, xmm5, xmm2
 -      -      -     1.00   0.01   0.99    -      -      -      -      -      -     vmulps	xmm2, xmm26, dword ptr [rip + .LCPI26_7]{1to4}
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm16, xmm2, xmm0
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpshufb	xmm0, xmm31, xmm10
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm0, xmm0
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm0, xmm0, xmm0
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm0, xmm16
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vaddps	xmm1, xmm0, xmm1
 -      -      -      -     1.00    -      -     1.00    -      -      -      -     vpshufb	xmm0, xmm31, xmmword ptr [rip + .LCPI26_4]
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm0, xmm0
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm0, xmm0
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm0, xmm16
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vaddps	xmm2, xmm0, xmm4
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm0, xmm3
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm0, xmm0
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm0, xmm16
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vaddps	xmm3, xmm0, xmm5
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovaps	xmm0, xmm1
 -      -     1.00    -      -      -      -      -      -      -      -      -     rsqrtps	xmm0, xmm0
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm1, xmm0, xmm1
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmovaps	xmm0, xmm2
 -      -     1.00    -      -      -      -      -      -      -      -      -     rsqrtps	xmm0, xmm0
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm2, xmm0, xmm2
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovaps	xmm0, xmm3
 -      -     1.00    -      -      -      -      -      -      -      -      -     rsqrtps	xmm0, xmm0
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm0, xmm3
 -      -      -     1.00    -      -      -      -      -      -      -      -     cvtps2dq	xmm1, xmm1
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     cvtps2dq	xmm2, xmm2
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     cvtps2dq	xmm0, xmm0
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vpslld	xmm1, xmm1, 16
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vpslld	xmm2, xmm2, 8
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpternlogd	xmm2, xmm0, xmm1, 254
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpsrld	xmm0, xmm31, 24
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm0, xmm0
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm16, xmm0
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vaddps	xmm0, xmm26, xmm0
 -      -      -     1.00    -      -      -      -      -      -      -      -     cvtps2dq	xmm0, xmm0
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpslld	xmm0, xmm0, 24
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpord	xmm31 {k2}, xmm2, xmm0
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     vmovdqa64	xmmword ptr [r13], xmm31
 -      -     1.00    -      -      -      -      -      -      -      -      -     kxnorw	k2, k0, k0
 -      -      -     1.00   0.99   0.01    -      -      -      -      -      -     vaddps	xmm30, xmm30, dword ptr [rip + .LCPI26_8]{1to4}
 -      -      -      -      -      -      -     1.00    -      -      -      -     lea	esi, [rdx + 8]
 -      -      -      -      -      -      -      -     1.00    -      -      -     cmp	esi, ecx
 -      -      -      -      -      -      -      -     1.00    -      -      -     jl	.LBB26_18
 -      -     1.00    -      -      -      -      -      -      -      -      -     kmovq	k2, k1
 -      -      -      -      -      -      -      -     1.00    -      -      -     jmp	.LBB26_18


```
</details>

<details><summary>Timeline view:</summary>

```
                    0123456789          0123456789          0123456789          0123456789
Index     0123456789          0123456789          0123456789          0123456789          

[0,0]     DeER .    .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   cmp	r9d, ecx
[0,1]     D=eER.    .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   jge	.LBB26_20
[0,2]     DeeeeER   .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   vmulps	xmm5, xmm2, xmm2
[0,3]     DeeeeER   .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   vmulss	xmm16, xmm3, xmm3
[0,4]     D=eeeeER  .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   vmulss	xmm21, xmm1, xmm1
[0,5]     D=====eeeeER   .    .    .    .    .    .    .    .    .    .    .    .    .   .   vaddss	xmm21, xmm21, xmm5
[0,6]     .DeeeeeE---R   .    .    .    .    .    .    .    .    .    .    .    .    .   .   vmovss	xmm4, dword ptr [rip + .LCPI26_0]
[0,7]     .D========eeeeeeeeeeeER  .    .    .    .    .    .    .    .    .    .    .   .   vdivss	xmm21, xmm4, xmm21
[0,8]     .DeE------------------R  .    .    .    .    .    .    .    .    .    .    .   .   vmovshdup	xmm22, xmm2
[0,9]     .D===eE---------------R  .    .    .    .    .    .    .    .    .    .    .   .   vmovshdup	xmm5, xmm5
[0,10]    .D====eeeeE-----------R  .    .    .    .    .    .    .    .    .    .    .   .   vaddss	xmm5, xmm16, xmm5
[0,11]    .D===========eeeeeeeeeeeER    .    .    .    .    .    .    .    .    .    .   .   vdivss	xmm16, xmm4, xmm5
[0,12]    . D==================eeeeER   .    .    .    .    .    .    .    .    .    .   .   vmulss	xmm1, xmm1, xmm21
[0,13]    . D==================eeeeER   .    .    .    .    .    .    .    .    .    .   .   vmulss	xmm2, xmm2, xmm21
[0,14]    . D======================eER  .    .    .    .    .    .    .    .    .    .   .   vmovss	dword ptr [rsp + 68], xmm2
[0,15]    . D=====================eeeeER.    .    .    .    .    .    .    .    .    .   .   vmulss	xmm2, xmm22, xmm16
[0,16]    . D=====================eeeeER.    .    .    .    .    .    .    .    .    .   .   vmulss	xmm3, xmm3, xmm16
[0,17]    .  D========================eER    .    .    .    .    .    .    .    .    .   .   vmovss	dword ptr [rsp + 64], xmm3
[0,18]    .  DeeeE----------------------R    .    .    .    .    .    .    .    .    .   .   vbroadcastss	xmm17, xmm17
[0,19]    .  D=eeeE---------------------R    .    .    .    .    .    .    .    .    .   .   vbroadcastss	xmm18, xmm18
[0,20]    .  D==eeeE--------------------R    .    .    .    .    .    .    .    .    .   .   vbroadcastss	xmm19, xmm19
[0,21]    .  D===eeeE-------------------R    .    .    .    .    .    .    .    .    .   .   vbroadcastss	xmm20, xmm20
[0,22]    .   D====================eeeE-R    .    .    .    .    .    .    .    .    .   .   vbroadcastss	xmm21, xmm1
[0,23]    .   D=======================eeeER  .    .    .    .    .    .    .    .    .   .   vbroadcastss	xmm22, xmm2
[0,24]    .   D===eE----------------------R  .    .    .    .    .    .    .    .    .   .   vpbroadcastd	xmm23, r11d
[0,25]    .   DeE-------------------------R  .    .    .    .    .    .    .    .    .   .   add	r15d, -2
[0,26]    .   D====eeeeeE-----------------R  .    .    .    .    .    .    .    .    .   .   vcvtsi2ss	xmm1, xmm0, r15d
[0,27]    .    D========eeeE--------------R  .    .    .    .    .    .    .    .    .   .   vbroadcastss	xmm24, xmm1
[0,28]    .    DeE------------------------R  .    .    .    .    .    .    .    .    .   .   add	edi, -2
[0,29]    .    D====eeeeeE----------------R  .    .    .    .    .    .    .    .    .   .   vcvtsi2ss	xmm1, xmm0, edi
[0,30]    .    D=========eeeE-------------R  .    .    .    .    .    .    .    .    .   .   vbroadcastss	xmm25, xmm1
[0,31]    .    D=eE-----------------------R  .    .    .    .    .    .    .    .    .   .   lea	eax, [rbx + rbx]
[0,32]    .    .D=eE----------------------R  .    .    .    .    .    .    .    .    .   .   lea	edx, [r9 + 1]
[0,33]    .    .D==eE---------------------R  .    .    .    .    .    .    .    .    .   .   lea	esi, [r9 + 2]
[0,34]    .    .D====eE-------------------R  .    .    .    .    .    .    .    .    .   .   lea	edi, [r9 + 3]
[0,35]    .    .D====eE-------------------R  .    .    .    .    .    .    .    .    .   .   vmovd	xmm1, r9d
[0,36]    .    .D=====eeE-----------------R  .    .    .    .    .    .    .    .    .   .   vpinsrd	xmm1, xmm1, edx, 1
[0,37]    .    . D========eeE-------------R  .    .    .    .    .    .    .    .    .   .   vpinsrd	xmm1, xmm1, esi, 2
[0,38]    .    . D==========eeE-----------R  .    .    .    .    .    .    .    .    .   .   vpinsrd	xmm1, xmm1, edi, 3
[0,39]    .    . D====eE------------------R  .    .    .    .    .    .    .    .    .   .   vbroadcastss	xmm0, xmm0
[0,40]    .    . D============eeeeE-------R  .    .    .    .    .    .    .    .    .   .   vcvtdq2ps	xmm1, xmm1
[0,41]    .    .  D================eeeeE--R  .    .    .    .    .    .    .    .    .   .   vsubps	xmm0, xmm1, xmm0
[0,42]    .    .  D====================eE-R  .    .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [rsp + 128], xmm0
[0,43]    .    .  DeE---------------------R  .    .    .    .    .    .    .    .    .   .   mov	edx, r9d
[0,44]    .    .  DeeeeeE-----------------R  .    .    .    .    .    .    .    .    .   .   mov	rsi, qword ptr [rsp + 96]
[0,45]    .    .  D=====eE----------------R  .    .    .    .    .    .    .    .    .   .   lea	rdx, [rsi + 4*rdx]
[0,46]    .    .   D===eeeE---------------R  .    .    .    .    .    .    .    .    .   .   imul	ebx, r10d
[0,47]    .    .   D======eE--------------R  .    .    .    .    .    .    .    .    .   .   add	rbx, rdx
[0,48]    .    .   D==========eeeE--------R  .    .    .    .    .    .    .    .    .   .   vpbroadcastq	ymm27, r12
[0,49]    .    .   DeE--------------------R  .    .    .    .    .    .    .    .    .   .   jmp	.LBB26_15
[0,50]    .    .   D=======eE-------------R  .    .    .    .    .    .    .    .    .   .   add	rbx, rax
[0,51]    .    .   D=eE-------------------R  .    .    .    .    .    .    .    .    .   .   add	r10d, 2
[0,52]    .    .    D=eE------------------R  .    .    .    .    .    .    .    .    .   .   cmp	r10d, r8d
[0,53]    .    .    D==eE-----------------R  .    .    .    .    .    .    .    .    .   .   jge	.LBB26_20
[0,54]    .    .    D===========eeeeeE----R  .    .    .    .    .    .    .    .    .   .   vcvtsi2ss	xmm0, xmm28, r10d
[0,55]    .    .    D===========eeeeeeeeeER  .    .    .    .    .    .    .    .    .   .   vsubss	xmm0, xmm0, dword ptr [rsp + 144]
[0,56]    .    .    .D==============eeeeeeeeeER   .    .    .    .    .    .    .    .   .   vmulss	xmm1, xmm0, dword ptr [rsp + 68]
[0,57]    .    .    .D=======================eeeER.    .    .    .    .    .    .    .   .   vbroadcastss	xmm28, xmm1
[0,58]    .    .    .D==============eeeeeeeeeE---R.    .    .    .    .    .    .    .   .   vmulss	xmm0, xmm0, dword ptr [rsp + 64]
[0,59]    .    .    .D========================eeeER    .    .    .    .    .    .    .   .   vbroadcastss	xmm29, xmm0
[0,60]    .    .    . D=eE------------------------R    .    .    .    .    .    .    .   .   mov	edx, r9d
[0,61]    .    .    . D=eE------------------------R    .    .    .    .    .    .    .   .   kmovq	k2, k0
[0,62]    .    .    . D==eeeeeeeE-----------------R    .    .    .    .    .    .    .   .   vmovaps	xmm30, xmmword ptr [rsp + 128]
[0,63]    .    .    . D=====eE--------------------R    .    .    .    .    .    .    .   .   mov	r13, rbx
[0,64]    .    .    . D==eE-----------------------R    .    .    .    .    .    .    .   .   jmp	.LBB26_16
[0,65]    .    .    .  D=====eE-------------------R    .    .    .    .    .    .    .   .   add	r13, 16
[0,66]    .    .    .  D=eE-----------------------R    .    .    .    .    .    .    .   .   add	edx, 4
[0,67]    .    .    .  D==eE----------------------R    .    .    .    .    .    .    .   .   cmp	edx, ecx
[0,68]    .    .    .  D===eE---------------------R    .    .    .    .    .    .    .   .   jge	.LBB26_19
[0,69]    .    .    .  D==============eeeeE-------R    .    .    .    .    .    .    .   .   vmulps	xmm0, xmm21, xmm30
[0,70]    .    .    .  D========================eeeeER .    .    .    .    .    .    .   .   vaddps	xmm1, xmm28, xmm0
[0,71]    .    .    .   D================eeeeE-------R .    .    .    .    .    .    .   .   vmulps	xmm2, xmm22, xmm30
[0,72]    .    .    .   DeeeeeeE---------------------R .    .    .    .    .    .    .   .   vbroadcastss	xmm0, dword ptr [rip + .LCPI26_0]
[0,73]    .    .    .   D========================eeeeER.    .    .    .    .    .    .   .   vaddps	xmm2, xmm29, xmm2
[0,74]    .    .    .   D===========================eeeeER  .    .    .    .    .    .   .   vcmpleps	k2 {k2}, xmm1, xmm0
[0,75]    .    .    .   D===============================eeeeER   .    .    .    .    .   .   vcmpleps	k2 {k2}, xmm6, xmm1
[0,76]    .    .    .   D===================================eeeeER    .    .    .    .   .   vcmpleps	k2 {k2}, xmm6, xmm2
[0,77]    .    .    .    D======================================eeeeER.    .    .    .   .   vcmpleps	k2 {k2}, xmm2, xmm0
[0,78]    .    .    .    D==========================eeeeE------------R.    .    .    .   .   vmaxps	xmm1, xmm1, xmm6
[0,79]    .    .    .    D==============================eeeeE--------R.    .    .    .   .   vminps	xmm1, xmm1, xmm0
[0,80]    .    .    .    D==================================eeeeE----R.    .    .    .   .   vmulps	xmm1, xmm24, xmm1
[0,81]    .    .    .    D===========================eeeeE-----------R.    .    .    .   .   vmaxps	xmm2, xmm2, xmm6
[0,82]    .    .    .    D===============================eeeeE-------R.    .    .    .   .   vminps	xmm2, xmm2, xmm0
[0,83]    .    .    .    .DeeeeeeE-----------------------------------R.    .    .    .   .   vbroadcastss	xmm3, dword ptr [rip + .LCPI26_1]
[0,84]    .    .    .    .D==================================eeeeE---R.    .    .    .   .   vmulps	xmm2, xmm25, xmm2
[0,85]    .    .    .    .D=====================================eeeeER.    .    .    .   .   vaddps	xmm1, xmm1, xmm3
[0,86]    .    .    .    .D======================================eeeeER    .    .    .   .   vaddps	xmm2, xmm2, xmm3
[0,87]    .    .    .    .D=========================================eeeeER .    .    .   .   vcvttps2dq	xmm3, xmm1
[0,88]    .    .    .    .D=============================================eeeeER  .    .   .   vcvtdq2ps	xmm31, xmm3
[0,89]    .    .    .    . D================================================eeeeER   .   .   vsubps	xmm31, xmm1, xmm31
[0,90]    .    .    .    . D=========================================eeeeE-------R   .   .   vcvttps2dq	xmm1, xmm2
[0,91]    .    .    .    . D=============================================eeeeE---R   .   .   vcvtdq2ps	xmm7, xmm1
[0,92]    .    .    .    . D=================================================eeeeER  .   .   vsubps	xmm12, xmm2, xmm7
[0,93]    .    .    .    . D============================================eE--------R  .   .   vpslld	xmm2, xmm3, 2
[0,94]    .    .    .    .  D============================================eeeeeeeeeeER.   .   vpmulld	xmm1, xmm23, xmm1
[0,95]    .    .    .    .  D======================================================eER   .   vpaddd	xmm7, xmm2, xmm1
[0,96]    .    .    .    .  D=======================================================eeeER.   vpmovsxdq	ymm1, xmm7
[0,97]    .    .    .    .  D==========================================================eER   vpaddq	ymm1, ymm27, ymm1
Truncated display due to cycle limit


```
</details>

<details><summary>Average Wait times (based on the timeline view):</summary>

```
[0]: Executions
[1]: Average time spent waiting in a scheduler's queue
[2]: Average time spent waiting in a scheduler's queue while ready
[3]: Average time elapsed from WB until retire stage

      [0]    [1]    [2]    [3]
0.     10    1.0    1.0    47.7      cmp	r9d, ecx
1.     10    2.9    0.9    45.9      jge	.LBB26_20
2.     10    46.9   0.1    0.0       vmulps	xmm5, xmm2, xmm2
3.     10    34.3   1.0    12.6      vmulss	xmm16, xmm3, xmm3
4.     10    45.2   0.2    1.8       vmulss	xmm21, xmm1, xmm1
5.     10    51.0   0.0    0.0       vaddss	xmm21, xmm21, xmm5
6.     10    1.0    1.0    48.0      vmovss	xmm4, dword ptr [rip + .LCPI26_0]
7.     10    54.0   0.0    0.0       vdivss	xmm21, xmm4, xmm21
8.     10    46.9   1.0    17.1      vmovshdup	xmm22, xmm2
9.     10    49.0   0.0    14.1      vmovshdup	xmm5, xmm5
10.    10    50.0   0.0    10.1      vaddss	xmm5, xmm16, xmm5
11.    10    56.1   2.1    0.0       vdivss	xmm16, xmm4, xmm5
12.    10    64.0   0.0    0.0       vmulss	xmm1, xmm1, xmm21
13.    10    63.1   0.0    0.0       vmulss	xmm2, xmm2, xmm21
14.    10    67.1   0.0    0.0       vmovss	dword ptr [rsp + 68], xmm2
15.    10    65.2   0.0    0.0       vmulss	xmm2, xmm22, xmm16
16.    10    65.2   0.0    0.0       vmulss	xmm3, xmm3, xmm16
17.    10    68.2   0.0    0.0       vmovss	dword ptr [rsp + 64], xmm3
18.    10    1.0    1.0    65.2      vbroadcastss	xmm17, xmm17
19.    10    1.1    1.1    64.2      vbroadcastss	xmm18, xmm18
20.    10    2.1    2.1    63.2      vbroadcastss	xmm19, xmm19
21.    10    3.1    3.1    62.2      vbroadcastss	xmm20, xmm20
22.    10    63.3   0.0    1.0       vbroadcastss	xmm21, xmm1
23.    10    66.3   0.0    0.0       vbroadcastss	xmm22, xmm2
24.    10    3.1    3.1    65.2      vpbroadcastd	xmm23, r11d
25.    10    1.0    1.0    66.4      add	r15d, -2
26.    10    31.1   0.3    32.3      vcvtsi2ss	xmm1, xmm0, r15d
27.    10    36.0   0.0    29.3      vbroadcastss	xmm24, xmm1
28.    10    1.0    1.0    65.4      add	edi, -2
29.    10    31.1   1.2    31.3      vcvtsi2ss	xmm1, xmm0, edi
30.    10    36.1   0.0    28.3      vbroadcastss	xmm25, xmm1
31.    10    2.0    2.0    64.4      lea	eax, [rbx + rbx]
32.    10    2.0    2.0    63.4      lea	edx, [r9 + 1]
33.    10    3.0    3.0    62.4      lea	esi, [r9 + 2]
34.    10    3.2    3.2    62.2      lea	edi, [r9 + 3]
35.    10    4.1    4.1    61.3      vmovd	xmm1, r9d
36.    10    4.2    0.0    59.3      vpinsrd	xmm1, xmm1, edx, 1
37.    10    6.3    0.2    57.1      vpinsrd	xmm1, xmm1, esi, 2
38.    10    8.3    0.0    55.1      vpinsrd	xmm1, xmm1, edi, 3
39.    10    29.3   2.3    34.2      vbroadcastss	xmm0, xmm0
40.    10    9.4    0.0    51.1      vcvtdq2ps	xmm1, xmm1
41.    10    30.5   0.1    29.0      vsubps	xmm0, xmm1, xmm0
42.    10    60.6   0.0    1.9       vmovaps	xmmword ptr [rsp + 128], xmm0
43.    10    1.0    1.0    60.6      mov	edx, r9d
44.    10    1.0    1.0    56.6      mov	rsi, qword ptr [rsp + 96]
45.    10    6.0    0.0    55.6      lea	rdx, [rsi + 4*rdx]
46.    10    1.3    1.3    57.3      imul	ebx, r10d
47.    10    6.1    0.0    54.5      add	rbx, rdx
48.    10    6.5    6.5    52.1      vpbroadcastq	ymm27, r12
49.    10    1.0    1.0    58.7      jmp	.LBB26_15
50.    10    6.2    0.0    53.5      add	rbx, rax
51.    10    1.1    1.1    57.7      add	r10d, 2
52.    10    2.0    0.0    56.7      cmp	r10d, r8d
53.    10    2.1    0.0    55.7      jge	.LBB26_20
54.    10    3.9    3.7    49.0      vcvtsi2ss	xmm0, xmm28, r10d
55.    10    3.9    0.0    45.0      vsubss	xmm0, xmm0, dword ptr [rsp + 144]
56.    10    6.9    0.0    41.4      vmulss	xmm1, xmm0, dword ptr [rsp + 68]
57.    10    15.9   0.0    38.7      vbroadcastss	xmm28, xmm1
58.    10    6.0    0.0    41.7      vmulss	xmm0, xmm0, dword ptr [rsp + 64]
59.    10    17.8   2.8    36.0      vbroadcastss	xmm29, xmm0
60.    10    2.0    2.0    53.7      mov	edx, r9d
61.    10    1.1    1.1    53.7      kmovq	k2, k0
62.    10    1.2    1.2    47.6      vmovaps	xmm30, xmmword ptr [rsp + 128]
63.    10    1.5    0.0    53.3      mov	r13, rbx
64.    10    1.2    1.2    52.7      jmp	.LBB26_16
65.    10    1.5    0.0    52.3      add	r13, 16
66.    10    1.1    0.0    52.7      add	edx, 4
67.    10    2.1    0.0    51.7      cmp	edx, ecx
68.    10    2.2    0.0    50.7      jge	.LBB26_19
69.    10    50.1   0.0    0.7       vmulps	xmm0, xmm21, xmm30
70.    10    54.7   0.0    0.0       vaddps	xmm1, xmm28, xmm0
71.    10    53.0   0.0    1.6       vmulps	xmm2, xmm22, xmm30
72.    10    1.9    1.9    49.8      vbroadcastss	xmm0, dword ptr [rip + .LCPI26_0]
73.    10    55.6   0.0    0.0       vaddps	xmm2, xmm29, xmm2
74.    10    56.8   0.0    0.0       vcmpleps	k2 {k2}, xmm1, xmm0
75.    10    60.8   0.0    0.0       vcmpleps	k2 {k2}, xmm6, xmm1
76.    10    63.9   0.0    0.0       vcmpleps	k2 {k2}, xmm6, xmm2
77.    10    66.9   0.0    0.0       vcmpleps	k2 {k2}, xmm2, xmm0
78.    10    54.9   0.0    12.0      vmaxps	xmm1, xmm1, xmm6
79.    10    58.0   0.0    8.0       vminps	xmm1, xmm1, xmm0
80.    10    62.0   0.0    4.0       vmulps	xmm1, xmm24, xmm1
81.    10    54.1   0.0    9.2       vmaxps	xmm2, xmm2, xmm6
82.    10    58.1   0.0    5.2       vminps	xmm2, xmm2, xmm0
83.    10    1.0    1.0    59.3      vbroadcastss	xmm3, dword ptr [rip + .LCPI26_1]
84.    10    61.1   0.0    1.2       vmulps	xmm2, xmm25, xmm2
85.    10    61.4   0.0    0.0       vaddps	xmm1, xmm1, xmm3
86.    10    63.3   0.0    0.0       vaddps	xmm2, xmm2, xmm3
87.    10    63.6   0.0    0.0       vcvttps2dq	xmm3, xmm1
88.    10    67.6   0.0    0.0       vcvtdq2ps	xmm31, xmm3
89.    10    70.6   0.0    0.0       vsubps	xmm31, xmm1, xmm31
90.    10    65.4   0.0    5.2       vcvttps2dq	xmm1, xmm2
91.    10    69.4   0.0    1.2       vcvtdq2ps	xmm7, xmm1
92.    10    72.5   0.0    0.0       vsubps	xmm12, xmm2, xmm7
93.    10    65.7   0.0    9.8       vpslld	xmm2, xmm3, 2
94.    10    68.4   0.0    0.0       vpmulld	xmm1, xmm23, xmm1
95.    10    77.5   0.0    0.0       vpaddd	xmm7, xmm2, xmm1
96.    10    76.7   0.0    0.0       vpmovsxdq	ymm1, xmm7
97.    10    79.7   0.0    0.0       vpaddq	ymm1, ymm27, ymm1
98.    10    79.7   0.0    0.0       vpextrq	rsi, xmm1, 1
99.    10    80.7   1.0    0.0       vmovq	rdi, xmm1
100.   10    79.8   1.0    0.0       vextracti128	xmm1, ymm1, 1
101.   10    82.8   0.0    0.0       vpextrq	r15, xmm1, 1
102.   10    82.8   1.0    0.0       vmovq	r14, xmm1
103.   10    79.9   0.0    0.0       vmovd	xmm1, dword ptr [rdi + 4]
104.   10    79.9   0.0    0.0       vpinsrd	xmm1, xmm1, dword ptr [rsi + 4], 1
105.   10    83.0   0.0    0.0       vpinsrd	xmm1, xmm1, dword ptr [r14 + 4], 2
106.   10    83.0   0.0    0.0       vpinsrd	xmm1, xmm1, dword ptr [r15 + 4], 3
107.   10    0.0    0.0    89.0      vpxor	xmm11, xmm11, xmm11
108.   10    79.0   1.0    5.0       vmovd	xmm2, dword ptr [rdi + r11]
109.   10    79.1   1.0    3.0       vpinsrd	xmm2, xmm2, dword ptr [rsi + r11], 1
110.   10    82.1   2.0    0.0       vpinsrd	xmm2, xmm2, dword ptr [r14 + r11], 2
111.   10    82.2   0.0    0.0       vpinsrd	xmm2, xmm2, dword ptr [r15 + r11], 3
112.   10    1.0    1.0    86.2      kxnorw	k3, k0, k0
113.   10    75.3   1.0    7.0       vmovd	xmm3, dword ptr [rdi + r11 + 4]
114.   10    77.2   2.0    4.0       vpinsrd	xmm3, xmm3, dword ptr [rsi + r11 + 4], 1
115.   10    81.3   4.0    0.0       vpinsrd	xmm3, xmm3, dword ptr [r14 + r11 + 4], 2
116.   10    82.3   0.0    0.0       vpinsrd	xmm3, xmm3, dword ptr [r15 + r11 + 4], 3
117.   10    65.3   0.0    3.0       vpgatherdd	xmm11 {k3}, xmmword ptr [r12 + xmm7]
118.   10    1.1    1.1    78.2      vpbroadcastw	xmm7, word ptr [rip + .LCPI26_2]
119.   10    82.4   0.0    2.0       vpand	xmm8, xmm11, xmm7
120.   10    82.5   0.0    0.0       vpmullw	xmm13, xmm8, xmm8
121.   10    81.5   0.0    5.0       vpsrlw	xmm8, xmm11, 8
122.   10    81.6   0.0    0.0       vpmullw	xmm8, xmm8, xmm8
123.   10    76.8   0.0    6.0       vpand	xmm14, xmm1, xmm7
124.   10    77.1   2.0    0.0       vpmullw	xmm14, xmm14, xmm14
125.   10    68.9   0.0    5.0       vpand	xmm15, xmm2, xmm7
126.   10    69.9   0.0    0.0       vpmullw	xmm15, xmm15, xmm15
127.   10    68.2   0.0    3.0       vpand	xmm7, xmm3, xmm7
128.   10    69.1   0.0    0.0       vpmullw	xmm7, xmm7, xmm7
129.   10    70.1   0.0    2.0       vpsrld	xmm4, xmm13, 16
130.   10    71.1   0.0    0.0       vcvtdq2ps	xmm4, xmm4
131.   10    36.6   0.0    31.8      vsubps	xmm5, xmm0, xmm31
132.   10    39.3   0.0    29.0      vsubps	xmm16, xmm0, xmm12
133.   10    43.1   0.0    25.0      vmulps	xmm26, xmm16, xmm5
134.   10    42.7   0.0    25.0      vmulps	xmm16, xmm31, xmm16
135.   10    37.3   0.2    27.6      vmulps	xmm5, xmm12, xmm5
136.   10    34.8   0.0    29.0      vmulps	xmm12, xmm12, xmm31
137.   10    61.0   0.0    3.0       vpsrld	xmm31, xmm14, 16
138.   10    60.8   0.0    0.0       vcvtdq2ps	xmm31, xmm31
139.   10    63.8   0.0    0.0       vmulps	xmm4, xmm26, xmm4
140.   10    62.0   0.0    0.0       vmulps	xmm31, xmm16, xmm31
141.   10    64.8   0.0    0.0       vaddps	xmm4, xmm4, xmm31
142.   10    56.8   1.0    11.0      vpsrld	xmm31, xmm15, 16
143.   10    55.0   0.0    7.0       vcvtdq2ps	xmm31, xmm31
144.   10    57.8   0.0    3.0       vmulps	xmm31, xmm5, xmm31
145.   10    64.8   0.0    0.0       vaddps	xmm4, xmm4, xmm31
146.   10    51.0   0.0    14.0      vpsrld	xmm31, xmm7, 16
147.   10    50.8   0.0    10.0      vcvtdq2ps	xmm31, xmm31
148.   10    54.8   0.0    6.0       vmulps	xmm31, xmm12, xmm31
149.   10    62.0   0.0    0.0       vaddps	xmm4, xmm4, xmm31
150.   10    35.8   0.0    28.0      vpsrlw	xmm31, xmm1, 8
151.   10    37.0   3.0    20.0      vpmullw	xmm9, xmm31, xmm31
152.   10    38.8   0.0    21.0      vpblendw	xmm8, xmm8, xmm6, 170
153.   10    42.8   3.0    14.0      vcvtdq2ps	xmm31, xmm8
154.   10    38.0   0.0    19.0      vpblendw	xmm8, xmm9, xmm6, 170
155.   10    41.0   2.0    13.0      vcvtdq2ps	xmm8, xmm8
156.   10    42.8   0.0    10.0      vmulps	xmm31, xmm26, xmm31
157.   10    41.0   0.0    9.0       vmulps	xmm8, xmm16, xmm8
158.   10    43.8   0.0    5.0       vaddps	xmm31, xmm31, xmm8
159.   10    25.0   2.0    24.0      vpsrlw	xmm8, xmm2, 8
160.   10    26.0   0.0    19.0      vpmullw	xmm8, xmm8, xmm8
161.   10    29.9   0.0    18.0      vpblendw	xmm8, xmm8, xmm6, 170
162.   10    31.9   2.0    12.0      vcvtdq2ps	xmm8, xmm8
163.   10    35.0   0.0    8.0       vmulps	xmm8, xmm8, xmm5
164.   10    41.9   0.0    1.0       vaddps	xmm31, xmm31, xmm8
165.   10    23.0   2.0    22.0      vpsrlw	xmm8, xmm3, 8
166.   10    23.9   0.0    17.0      vpmullw	xmm8, xmm8, xmm8
167.   10    27.0   0.0    16.0      vpblendw	xmm8, xmm8, xmm6, 170
168.   10    28.0   1.0    11.0      vcvtdq2ps	xmm8, xmm8
169.   10    31.0   0.0    7.0       vmulps	xmm8, xmm12, xmm8
170.   10    41.0   0.0    0.0       vaddps	xmm8, xmm31, xmm8
171.   10    19.0   1.0    23.0      vpblendw	xmm9, xmm13, xmm6, 170
172.   10    27.0   7.0    12.0      vcvtdq2ps	xmm31, xmm9
173.   10    21.0   3.0    20.0      vpblendw	xmm9, xmm14, xmm6, 170
174.   10    28.0   6.0    10.0      vcvtdq2ps	xmm9, xmm9
175.   10    30.0   0.0    8.0       vmulps	xmm31, xmm26, xmm31
176.   10    31.0   0.0    6.0       vmulps	xmm9, xmm16, xmm9
177.   10    35.0   0.0    2.0       vaddps	xmm31, xmm31, xmm9
178.   10    21.0   5.0    18.0      vpblendw	xmm9, xmm15, xmm6, 170
179.   10    26.0   5.0    9.0       vcvtdq2ps	xmm9, xmm9
180.   10    29.0   0.0    5.0       vmulps	xmm9, xmm9, xmm5
181.   10    35.0   0.0    0.0       vaddps	xmm31, xmm31, xmm9
182.   10    18.0   4.0    19.0      vpblendw	xmm7, xmm7, xmm6, 170
183.   10    22.0   4.0    11.0      vcvtdq2ps	xmm7, xmm7
184.   10    25.0   0.0    7.0       vmulps	xmm7, xmm12, xmm7
185.   10    34.0   0.0    0.0       vaddps	xmm7, xmm31, xmm7
186.   10    6.0    5.0    31.0      vpsrld	xmm31, xmm11, 24
187.   10    20.0   14.0   13.0      vcvtdq2ps	xmm31, xmm31
188.   10    24.0   0.0    9.0       vmulps	xmm26, xmm26, xmm31
189.   10    20.0   20.0   15.0      vpsrld	xmm1, xmm1, 24
190.   10    22.0   1.0    10.0      vcvtdq2ps	xmm1, xmm1
191.   10    26.0   0.0    6.0       vmulps	xmm1, xmm16, xmm1
192.   10    29.0   0.0    2.0       vaddps	xmm1, xmm26, xmm1
193.   10    23.0   23.0   11.0      vpsrld	xmm2, xmm2, 24
194.   10    23.0   0.0    7.0       vcvtdq2ps	xmm2, xmm2
195.   10    27.0   0.0    3.0       vmulps	xmm2, xmm5, xmm2
196.   10    32.0   0.0    0.0       vaddps	xmm1, xmm1, xmm2
197.   10    1.0    1.0    27.0      vmovdqu64	xmm31, xmmword ptr [r13]
198.   10    22.0   22.0   12.0      vpsrld	xmm2, xmm3, 24
199.   10    23.0   1.0    7.0       vcvtdq2ps	xmm2, xmm2
200.   10    27.0   0.0    3.0       vmulps	xmm2, xmm12, xmm2
201.   10    9.0    8.0    18.0      vpandd	xmm3, xmm31, dword ptr [rip + .LCPI26_3]{1to4}
202.   10    22.0   0.0    7.0       vmulps	xmm4, xmm17, xmm4
203.   10    25.0   0.0    4.0       vmulps	xmm5, xmm18, xmm8
204.   10    31.0   0.0    0.0       vmulps	xmm16, xmm19, xmm7
205.   10    32.0   0.0    0.0       vaddps	xmm1, xmm1, xmm2
206.   10    36.0   0.0    0.0       vmulps	xmm26, xmm20, xmm1
207.   10    25.0   0.0    11.0      vmaxps	xmm1, xmm4, xmm6
208.   10    1.0    1.0    32.0      vbroadcastss	xmm2, dword ptr [rip + .LCPI26_6]
209.   10    28.0   0.0    7.0       vminps	xmm1, xmm1, xmm2
210.   10    27.0   0.0    8.0       vmaxps	xmm4, xmm5, xmm6
211.   10    30.0   0.0    4.0       vminps	xmm4, xmm4, xmm2
212.   10    32.0   0.0    2.0       vmaxps	xmm5, xmm16, xmm6
213.   10    36.0   0.0    0.0       vminps	xmm5, xmm5, xmm2
214.   10    34.0   0.0    0.0       vmulps	xmm2, xmm26, dword ptr [rip + .LCPI26_7]{1to4}
215.   10    43.0   0.0    0.0       vaddps	xmm16, xmm2, xmm0
216.   10    5.0    3.0    41.0      vpshufb	xmm0, xmm31, xmm10
217.   10    19.0   13.0   24.0      vcvtdq2ps	xmm0, xmm0
218.   10    22.0   0.0    20.0      vmulps	xmm0, xmm0, xmm0
219.   10    46.0   0.0    0.0       vmulps	xmm0, xmm0, xmm16
220.   10    50.0   0.0    0.0       vaddps	xmm1, xmm0, xmm1
221.   10    4.0    4.0    42.0      vpshufb	xmm0, xmm31, xmmword ptr [rip + .LCPI26_4]
222.   10    18.0   7.0    31.0      vcvtdq2ps	xmm0, xmm0
223.   10    22.0   0.0    27.0      vmulps	xmm0, xmm0, xmm0
224.   10    44.0   0.0    4.0       vmulps	xmm0, xmm0, xmm16
225.   10    48.0   0.0    0.0       vaddps	xmm2, xmm0, xmm4
226.   10    21.0   13.0   27.0      vcvtdq2ps	xmm0, xmm3
227.   10    24.0   0.0    23.0      vmulps	xmm0, xmm0, xmm0
228.   10    44.0   1.0    3.0       vmulps	xmm0, xmm0, xmm16
229.   10    48.0   0.0    0.0       vaddps	xmm3, xmm0, xmm5
230.   10    50.0   0.0    0.0       vmovaps	xmm0, xmm1
231.   10    51.0   0.0    0.0       rsqrtps	xmm0, xmm0
232.   10    55.0   0.0    0.0       vmulps	xmm1, xmm0, xmm1
233.   10    49.0   0.0    8.0       vmovaps	xmm0, xmm2
234.   10    51.0   1.0    3.0       rsqrtps	xmm0, xmm0
235.   10    55.0   0.0    0.0       vmulps	xmm2, xmm0, xmm2
236.   10    49.0   0.0    8.0       vmovaps	xmm0, xmm3
237.   10    51.0   1.0    3.0       rsqrtps	xmm0, xmm0
238.   10    54.0   0.0    0.0       vmulps	xmm0, xmm0, xmm3
239.   10    56.0   0.0    0.0       cvtps2dq	xmm1, xmm1
240.   10    56.0   0.0    0.0       cvtps2dq	xmm2, xmm2
241.   10    57.0   0.0    0.0       cvtps2dq	xmm0, xmm0
242.   10    58.0   0.0    1.0       vpslld	xmm1, xmm1, 16
243.   10    59.0   0.0    0.0       vpslld	xmm2, xmm2, 8
244.   10    59.0   0.0    0.0       vpternlogd	xmm2, xmm0, xmm1, 254
245.   10    15.0   15.0   44.0      vpsrld	xmm0, xmm31, 24
246.   10    15.0   0.0    40.0      vcvtdq2ps	xmm0, xmm0
247.   10    36.0   1.0    19.0      vmulps	xmm0, xmm16, xmm0
248.   10    39.0   0.0    15.0      vaddps	xmm0, xmm26, xmm0
249.   10    43.0   0.0    11.0      cvtps2dq	xmm0, xmm0
250.   10    46.0   0.0    10.0      vpslld	xmm0, xmm0, 24
251.   10    57.0   0.0    0.0       vpord	xmm31 {k2}, xmm2, xmm0
252.   10    57.0   0.0    0.0       vmovdqa64	xmmword ptr [r13], xmm31
253.   10    13.0   13.0   44.0      kxnorw	k2, k0, k0
254.   10    14.0   14.0   33.0      vaddps	xmm30, xmm30, dword ptr [rip + .LCPI26_8]{1to4}
255.   10    1.0    1.0    55.0      lea	esi, [rdx + 8]
256.   10    1.0    0.0    54.0      cmp	esi, ecx
257.   10    2.0    0.0    53.0      jl	.LBB26_18
258.   10    13.0   13.0   42.0      kmovq	k2, k1
259.   10    2.0    2.0    52.0      jmp	.LBB26_18
       10    37.9   1.3    18.6      <total>
```
</details>
</details>
