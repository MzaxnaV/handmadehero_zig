
<details><summary>[0] Code Region - OPS_ClearingChannel</summary>

```
Iterations:        100
Instructions:      2600
Total Cycles:      507
Total uOps:        2900

Dispatch Width:    6
uOps Per Cycle:    5.72
IPC:               5.13
Block RThroughput: 4.8


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
 1      1     0.50           *            mov	dword ptr [rsp + 44], ebp
 1      1     0.25                        test	ebp, ebp
 1      1     0.50                        je	.LBB6_13
 2      6     0.50    *                   cmp	dword ptr [rsp + 44], 4
 1      1     0.50                        jne	.LBB6_5
 1      0     0.17                        xor	eax, eax
 1      1     0.25                        test	dil, 1
 1      1     0.50                        jne	.LBB6_12
 1      1     0.50                        jmp	.LBB6_13
 1      1     0.25                        mov	eax, edi
 1      1     0.25                        and	eax, -2
 1      1     0.50                        lea	rcx, [rdi - 2]
 1      1     0.25                        mov	r9d, 16
 1      1     0.25                        cmp	rcx, 2
 1      1     0.50                        jae	.LBB6_6
 1      1     0.25                        test	cl, 2
 1      1     0.50                        je	.LBB6_10
 1      1     0.25                        test	dil, 1
 1      1     0.50                        je	.LBB6_13
 1      1     0.50                        shl	rax, 4
 1      0     0.17                        vxorps	xmm1, xmm1, xmm1
 2      1     0.50           *            vmovaps	xmmword ptr [r12 + rax], xmm1
 2      1     0.50           *            vmovaps	xmmword ptr [rbx + rax], xmm1
 1      1     0.50           *            mov	qword ptr [rsp + 224], rdi
 1      1     0.50           *            mov	qword ptr [rsp + 280], rdx
 1      1     0.50           *            mov	qword ptr [rsp + 296], r10


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
 0,              7  (1.4%)
 5,              100  (19.7%)
 6,              400  (78.9%)


```
</details>

<details><summary>Schedulers - number of cycles where we saw N micro opcodes issued:</summary>

```
[# issued], [# cycles]
 0,          3  (0.6%)
 1,          1  (0.2%)
 2,          3  (0.6%)
 3,          100  (19.7%)
 4,          1  (0.2%)
 5,          102  (20.1%)
 6,          99  (19.5%)
 7,          99  (19.5%)
 8,          99  (19.5%)

```
</details>

<details><summary>Scheduler's queue usage:</summary>

```
[1] Resource name.
[2] Average number of used buffer entries.
[3] Maximum number of used buffer entries.
[4] Total number of buffer entries.

 [1]            [2]        [3]        [4]
ICXPortAny       13         15         60


```
</details>

<details><summary>Retire Control Unit - number of cycles where we saw N instructions retired:</summary>

```
[# retired], [# cycles]
 0,           105  (20.7%)
 1,           102  (20.1%)
 2,           101  (19.9%)
 4,           99  (19.5%)
 19,          100  (19.7%)

```
</details>

<details><summary>Total ROB Entries:                352</summary>

```
Max Used ROB Entries:             48  ( 13.6% )
Average Used ROB Entries per cy:  39  ( 11.1% )


```
</details>

<details><summary>Register File statistics:</summary>

```
Total number of mappings created:    1300
Max number of mappings used:         24


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
 -      -     5.01   3.99   0.50   0.50   3.00   3.99   5.01   3.00   3.00   3.00   

Resource pressure by instruction:
[0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   Instructions:
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	dword ptr [rsp + 44], ebp
 -      -      -      -      -      -      -     0.99   0.01    -      -      -     test	ebp, ebp
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     je	.LBB6_13
 -      -      -     0.99   0.50   0.50    -     0.01    -      -      -      -     cmp	dword ptr [rsp + 44], 4
 -      -     1.00    -      -      -      -      -      -      -      -      -     jne	.LBB6_5
 -      -      -      -      -      -      -      -      -      -      -      -     xor	eax, eax
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     test	dil, 1
 -      -     1.00    -      -      -      -      -      -      -      -      -     jne	.LBB6_12
 -      -      -      -      -      -      -      -     1.00    -      -      -     jmp	.LBB6_13
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     mov	eax, edi
 -      -      -     0.99    -      -      -      -     0.01    -      -      -     and	eax, -2
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     lea	rcx, [rdi - 2]
 -      -      -      -      -      -      -     1.00    -      -      -      -     mov	r9d, 16
 -      -      -     1.00    -      -      -      -      -      -      -      -     cmp	rcx, 2
 -      -     1.00    -      -      -      -      -      -      -      -      -     jae	.LBB6_6
 -      -     1.00    -      -      -      -      -      -      -      -      -     test	cl, 2
 -      -      -      -      -      -      -      -     1.00    -      -      -     je	.LBB6_10
 -      -      -      -      -      -      -      -     1.00    -      -      -     test	dil, 1
 -      -      -      -      -      -      -      -     1.00    -      -      -     je	.LBB6_13
 -      -     1.00    -      -      -      -      -      -      -      -      -     shl	rax, 4
 -      -      -      -      -      -      -      -      -      -      -      -     vxorps	xmm1, xmm1, xmm1
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     vmovaps	xmmword ptr [r12 + rax], xmm1
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   vmovaps	xmmword ptr [rbx + rax], xmm1
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rsp + 224], rdi
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rsp + 280], rdx
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rsp + 296], r10


```
</details>

<details><summary>Timeline view:</summary>

```
                    0123456789          0123456789          0123456
Index     0123456789          0123456789          0123456789       

[0,0]     DeER .    .    .    .    .    .    .    .    .    .    ..   mov	dword ptr [rsp + 44], ebp
[0,1]     DeER .    .    .    .    .    .    .    .    .    .    ..   test	ebp, ebp
[0,2]     D=eER.    .    .    .    .    .    .    .    .    .    ..   je	.LBB6_13
[0,3]     DeeeeeeER .    .    .    .    .    .    .    .    .    ..   cmp	dword ptr [rsp + 44], 4
[0,4]     D======eER.    .    .    .    .    .    .    .    .    ..   jne	.LBB6_5
[0,5]     .D-------R.    .    .    .    .    .    .    .    .    ..   xor	eax, eax
[0,6]     .DeE-----R.    .    .    .    .    .    .    .    .    ..   test	dil, 1
[0,7]     .D=eE----R.    .    .    .    .    .    .    .    .    ..   jne	.LBB6_12
[0,8]     .DeE-----R.    .    .    .    .    .    .    .    .    ..   jmp	.LBB6_13
[0,9]     .DeE-----R.    .    .    .    .    .    .    .    .    ..   mov	eax, edi
[0,10]    .D=eE----R.    .    .    .    .    .    .    .    .    ..   and	eax, -2
[0,11]    . DeE----R.    .    .    .    .    .    .    .    .    ..   lea	rcx, [rdi - 2]
[0,12]    . DeE----R.    .    .    .    .    .    .    .    .    ..   mov	r9d, 16
[0,13]    . D=eE---R.    .    .    .    .    .    .    .    .    ..   cmp	rcx, 2
[0,14]    . D==eE--R.    .    .    .    .    .    .    .    .    ..   jae	.LBB6_6
[0,15]    . D=eE---R.    .    .    .    .    .    .    .    .    ..   test	cl, 2
[0,16]    . D==eE--R.    .    .    .    .    .    .    .    .    ..   je	.LBB6_10
[0,17]    .  DeE---R.    .    .    .    .    .    .    .    .    ..   test	dil, 1
[0,18]    .  D==eE-R.    .    .    .    .    .    .    .    .    ..   je	.LBB6_13
[0,19]    .  D==eE-R.    .    .    .    .    .    .    .    .    ..   shl	rax, 4
[0,20]    .  D-----R.    .    .    .    .    .    .    .    .    ..   vxorps	xmm1, xmm1, xmm1
[0,21]    .  D===eER.    .    .    .    .    .    .    .    .    ..   vmovaps	xmmword ptr [r12 + rax], xmm1
[0,22]    .   D==eER.    .    .    .    .    .    .    .    .    ..   vmovaps	xmmword ptr [rbx + rax], xmm1
[0,23]    .   D===eER    .    .    .    .    .    .    .    .    ..   mov	qword ptr [rsp + 224], rdi
[0,24]    .   D===eER    .    .    .    .    .    .    .    .    ..   mov	qword ptr [rsp + 280], rdx
[0,25]    .   D====eER   .    .    .    .    .    .    .    .    ..   mov	qword ptr [rsp + 296], r10
[1,0]     .   D====eER   .    .    .    .    .    .    .    .    ..   mov	dword ptr [rsp + 44], ebp
[1,1]     .    DeE---R   .    .    .    .    .    .    .    .    ..   test	ebp, ebp
[1,2]     .    D=eE--R   .    .    .    .    .    .    .    .    ..   je	.LBB6_13
[1,3]     .    DeeeeeeER .    .    .    .    .    .    .    .    ..   cmp	dword ptr [rsp + 44], 4
[1,4]     .    D======eER.    .    .    .    .    .    .    .    ..   jne	.LBB6_5
[1,5]     .    D--------R.    .    .    .    .    .    .    .    ..   xor	eax, eax
[1,6]     .    .DeE-----R.    .    .    .    .    .    .    .    ..   test	dil, 1
[1,7]     .    .D=eE----R.    .    .    .    .    .    .    .    ..   jne	.LBB6_12
[1,8]     .    .D=eE----R.    .    .    .    .    .    .    .    ..   jmp	.LBB6_13
[1,9]     .    .DeE-----R.    .    .    .    .    .    .    .    ..   mov	eax, edi
[1,10]    .    .D=eE----R.    .    .    .    .    .    .    .    ..   and	eax, -2
[1,11]    .    .D=eE----R.    .    .    .    .    .    .    .    ..   lea	rcx, [rdi - 2]
[1,12]    .    . D=eE---R.    .    .    .    .    .    .    .    ..   mov	r9d, 16
[1,13]    .    . D=eE---R.    .    .    .    .    .    .    .    ..   cmp	rcx, 2
[1,14]    .    . D==eE--R.    .    .    .    .    .    .    .    ..   jae	.LBB6_6
[1,15]    .    . D=eE---R.    .    .    .    .    .    .    .    ..   test	cl, 2
[1,16]    .    . D==eE--R.    .    .    .    .    .    .    .    ..   je	.LBB6_10
[1,17]    .    . D=eE---R.    .    .    .    .    .    .    .    ..   test	dil, 1
[1,18]    .    .  D==eE-R.    .    .    .    .    .    .    .    ..   je	.LBB6_13
[1,19]    .    .  D==eE-R.    .    .    .    .    .    .    .    ..   shl	rax, 4
[1,20]    .    .  D-----R.    .    .    .    .    .    .    .    ..   vxorps	xmm1, xmm1, xmm1
[1,21]    .    .  D===eER.    .    .    .    .    .    .    .    ..   vmovaps	xmmword ptr [r12 + rax], xmm1
[1,22]    .    .   D==eER.    .    .    .    .    .    .    .    ..   vmovaps	xmmword ptr [rbx + rax], xmm1
[1,23]    .    .   D===eER    .    .    .    .    .    .    .    ..   mov	qword ptr [rsp + 224], rdi
[1,24]    .    .   D===eER    .    .    .    .    .    .    .    ..   mov	qword ptr [rsp + 280], rdx
[1,25]    .    .   D====eER   .    .    .    .    .    .    .    ..   mov	qword ptr [rsp + 296], r10
[2,0]     .    .   D====eER   .    .    .    .    .    .    .    ..   mov	dword ptr [rsp + 44], ebp
[2,1]     .    .    DeE---R   .    .    .    .    .    .    .    ..   test	ebp, ebp
[2,2]     .    .    D=eE--R   .    .    .    .    .    .    .    ..   je	.LBB6_13
[2,3]     .    .    DeeeeeeER .    .    .    .    .    .    .    ..   cmp	dword ptr [rsp + 44], 4
[2,4]     .    .    D======eER.    .    .    .    .    .    .    ..   jne	.LBB6_5
[2,5]     .    .    D--------R.    .    .    .    .    .    .    ..   xor	eax, eax
[2,6]     .    .    .DeE-----R.    .    .    .    .    .    .    ..   test	dil, 1
[2,7]     .    .    .D=eE----R.    .    .    .    .    .    .    ..   jne	.LBB6_12
[2,8]     .    .    .D=eE----R.    .    .    .    .    .    .    ..   jmp	.LBB6_13
[2,9]     .    .    .DeE-----R.    .    .    .    .    .    .    ..   mov	eax, edi
[2,10]    .    .    .D=eE----R.    .    .    .    .    .    .    ..   and	eax, -2
[2,11]    .    .    .D=eE----R.    .    .    .    .    .    .    ..   lea	rcx, [rdi - 2]
[2,12]    .    .    . D=eE---R.    .    .    .    .    .    .    ..   mov	r9d, 16
[2,13]    .    .    . D=eE---R.    .    .    .    .    .    .    ..   cmp	rcx, 2
[2,14]    .    .    . D==eE--R.    .    .    .    .    .    .    ..   jae	.LBB6_6
[2,15]    .    .    . D=eE---R.    .    .    .    .    .    .    ..   test	cl, 2
[2,16]    .    .    . D==eE--R.    .    .    .    .    .    .    ..   je	.LBB6_10
[2,17]    .    .    . D=eE---R.    .    .    .    .    .    .    ..   test	dil, 1
[2,18]    .    .    .  D==eE-R.    .    .    .    .    .    .    ..   je	.LBB6_13
[2,19]    .    .    .  D==eE-R.    .    .    .    .    .    .    ..   shl	rax, 4
[2,20]    .    .    .  D-----R.    .    .    .    .    .    .    ..   vxorps	xmm1, xmm1, xmm1
[2,21]    .    .    .  D===eER.    .    .    .    .    .    .    ..   vmovaps	xmmword ptr [r12 + rax], xmm1
[2,22]    .    .    .   D==eER.    .    .    .    .    .    .    ..   vmovaps	xmmword ptr [rbx + rax], xmm1
[2,23]    .    .    .   D===eER    .    .    .    .    .    .    ..   mov	qword ptr [rsp + 224], rdi
[2,24]    .    .    .   D===eER    .    .    .    .    .    .    ..   mov	qword ptr [rsp + 280], rdx
[2,25]    .    .    .   D====eER   .    .    .    .    .    .    ..   mov	qword ptr [rsp + 296], r10
[3,0]     .    .    .   D====eER   .    .    .    .    .    .    ..   mov	dword ptr [rsp + 44], ebp
[3,1]     .    .    .    DeE---R   .    .    .    .    .    .    ..   test	ebp, ebp
[3,2]     .    .    .    D=eE--R   .    .    .    .    .    .    ..   je	.LBB6_13
[3,3]     .    .    .    DeeeeeeER .    .    .    .    .    .    ..   cmp	dword ptr [rsp + 44], 4
[3,4]     .    .    .    D======eER.    .    .    .    .    .    ..   jne	.LBB6_5
[3,5]     .    .    .    D--------R.    .    .    .    .    .    ..   xor	eax, eax
[3,6]     .    .    .    .DeE-----R.    .    .    .    .    .    ..   test	dil, 1
[3,7]     .    .    .    .D=eE----R.    .    .    .    .    .    ..   jne	.LBB6_12
[3,8]     .    .    .    .D=eE----R.    .    .    .    .    .    ..   jmp	.LBB6_13
[3,9]     .    .    .    .DeE-----R.    .    .    .    .    .    ..   mov	eax, edi
[3,10]    .    .    .    .D=eE----R.    .    .    .    .    .    ..   and	eax, -2
[3,11]    .    .    .    .D=eE----R.    .    .    .    .    .    ..   lea	rcx, [rdi - 2]
[3,12]    .    .    .    . D=eE---R.    .    .    .    .    .    ..   mov	r9d, 16
[3,13]    .    .    .    . D=eE---R.    .    .    .    .    .    ..   cmp	rcx, 2
[3,14]    .    .    .    . D==eE--R.    .    .    .    .    .    ..   jae	.LBB6_6
[3,15]    .    .    .    . D=eE---R.    .    .    .    .    .    ..   test	cl, 2
[3,16]    .    .    .    . D==eE--R.    .    .    .    .    .    ..   je	.LBB6_10
[3,17]    .    .    .    . D=eE---R.    .    .    .    .    .    ..   test	dil, 1
[3,18]    .    .    .    .  D==eE-R.    .    .    .    .    .    ..   je	.LBB6_13
[3,19]    .    .    .    .  D==eE-R.    .    .    .    .    .    ..   shl	rax, 4
[3,20]    .    .    .    .  D-----R.    .    .    .    .    .    ..   vxorps	xmm1, xmm1, xmm1
[3,21]    .    .    .    .  D===eER.    .    .    .    .    .    ..   vmovaps	xmmword ptr [r12 + rax], xmm1
[3,22]    .    .    .    .   D==eER.    .    .    .    .    .    ..   vmovaps	xmmword ptr [rbx + rax], xmm1
[3,23]    .    .    .    .   D===eER    .    .    .    .    .    ..   mov	qword ptr [rsp + 224], rdi
[3,24]    .    .    .    .   D===eER    .    .    .    .    .    ..   mov	qword ptr [rsp + 280], rdx
[3,25]    .    .    .    .   D====eER   .    .    .    .    .    ..   mov	qword ptr [rsp + 296], r10
[4,0]     .    .    .    .   D====eER   .    .    .    .    .    ..   mov	dword ptr [rsp + 44], ebp
[4,1]     .    .    .    .    DeE---R   .    .    .    .    .    ..   test	ebp, ebp
[4,2]     .    .    .    .    D=eE--R   .    .    .    .    .    ..   je	.LBB6_13
[4,3]     .    .    .    .    DeeeeeeER .    .    .    .    .    ..   cmp	dword ptr [rsp + 44], 4
[4,4]     .    .    .    .    D======eER.    .    .    .    .    ..   jne	.LBB6_5
[4,5]     .    .    .    .    D--------R.    .    .    .    .    ..   xor	eax, eax
[4,6]     .    .    .    .    .DeE-----R.    .    .    .    .    ..   test	dil, 1
[4,7]     .    .    .    .    .D=eE----R.    .    .    .    .    ..   jne	.LBB6_12
[4,8]     .    .    .    .    .D=eE----R.    .    .    .    .    ..   jmp	.LBB6_13
[4,9]     .    .    .    .    .DeE-----R.    .    .    .    .    ..   mov	eax, edi
[4,10]    .    .    .    .    .D=eE----R.    .    .    .    .    ..   and	eax, -2
[4,11]    .    .    .    .    .D=eE----R.    .    .    .    .    ..   lea	rcx, [rdi - 2]
[4,12]    .    .    .    .    . D=eE---R.    .    .    .    .    ..   mov	r9d, 16
[4,13]    .    .    .    .    . D=eE---R.    .    .    .    .    ..   cmp	rcx, 2
[4,14]    .    .    .    .    . D==eE--R.    .    .    .    .    ..   jae	.LBB6_6
[4,15]    .    .    .    .    . D=eE---R.    .    .    .    .    ..   test	cl, 2
[4,16]    .    .    .    .    . D==eE--R.    .    .    .    .    ..   je	.LBB6_10
[4,17]    .    .    .    .    . D=eE---R.    .    .    .    .    ..   test	dil, 1
[4,18]    .    .    .    .    .  D==eE-R.    .    .    .    .    ..   je	.LBB6_13
[4,19]    .    .    .    .    .  D==eE-R.    .    .    .    .    ..   shl	rax, 4
[4,20]    .    .    .    .    .  D-----R.    .    .    .    .    ..   vxorps	xmm1, xmm1, xmm1
[4,21]    .    .    .    .    .  D===eER.    .    .    .    .    ..   vmovaps	xmmword ptr [r12 + rax], xmm1
[4,22]    .    .    .    .    .   D==eER.    .    .    .    .    ..   vmovaps	xmmword ptr [rbx + rax], xmm1
[4,23]    .    .    .    .    .   D===eER    .    .    .    .    ..   mov	qword ptr [rsp + 224], rdi
[4,24]    .    .    .    .    .   D===eER    .    .    .    .    ..   mov	qword ptr [rsp + 280], rdx
[4,25]    .    .    .    .    .   D====eER   .    .    .    .    ..   mov	qword ptr [rsp + 296], r10
[5,0]     .    .    .    .    .   D====eER   .    .    .    .    ..   mov	dword ptr [rsp + 44], ebp
[5,1]     .    .    .    .    .    DeE---R   .    .    .    .    ..   test	ebp, ebp
[5,2]     .    .    .    .    .    D=eE--R   .    .    .    .    ..   je	.LBB6_13
[5,3]     .    .    .    .    .    DeeeeeeER .    .    .    .    ..   cmp	dword ptr [rsp + 44], 4
[5,4]     .    .    .    .    .    D======eER.    .    .    .    ..   jne	.LBB6_5
[5,5]     .    .    .    .    .    D--------R.    .    .    .    ..   xor	eax, eax
[5,6]     .    .    .    .    .    .DeE-----R.    .    .    .    ..   test	dil, 1
[5,7]     .    .    .    .    .    .D=eE----R.    .    .    .    ..   jne	.LBB6_12
[5,8]     .    .    .    .    .    .D=eE----R.    .    .    .    ..   jmp	.LBB6_13
[5,9]     .    .    .    .    .    .DeE-----R.    .    .    .    ..   mov	eax, edi
[5,10]    .    .    .    .    .    .D=eE----R.    .    .    .    ..   and	eax, -2
[5,11]    .    .    .    .    .    .D=eE----R.    .    .    .    ..   lea	rcx, [rdi - 2]
[5,12]    .    .    .    .    .    . D=eE---R.    .    .    .    ..   mov	r9d, 16
[5,13]    .    .    .    .    .    . D=eE---R.    .    .    .    ..   cmp	rcx, 2
[5,14]    .    .    .    .    .    . D==eE--R.    .    .    .    ..   jae	.LBB6_6
[5,15]    .    .    .    .    .    . D=eE---R.    .    .    .    ..   test	cl, 2
[5,16]    .    .    .    .    .    . D==eE--R.    .    .    .    ..   je	.LBB6_10
[5,17]    .    .    .    .    .    . D=eE---R.    .    .    .    ..   test	dil, 1
[5,18]    .    .    .    .    .    .  D==eE-R.    .    .    .    ..   je	.LBB6_13
[5,19]    .    .    .    .    .    .  D==eE-R.    .    .    .    ..   shl	rax, 4
[5,20]    .    .    .    .    .    .  D-----R.    .    .    .    ..   vxorps	xmm1, xmm1, xmm1
[5,21]    .    .    .    .    .    .  D===eER.    .    .    .    ..   vmovaps	xmmword ptr [r12 + rax], xmm1
[5,22]    .    .    .    .    .    .   D==eER.    .    .    .    ..   vmovaps	xmmword ptr [rbx + rax], xmm1
[5,23]    .    .    .    .    .    .   D===eER    .    .    .    ..   mov	qword ptr [rsp + 224], rdi
[5,24]    .    .    .    .    .    .   D===eER    .    .    .    ..   mov	qword ptr [rsp + 280], rdx
[5,25]    .    .    .    .    .    .   D====eER   .    .    .    ..   mov	qword ptr [rsp + 296], r10
[6,0]     .    .    .    .    .    .   D====eER   .    .    .    ..   mov	dword ptr [rsp + 44], ebp
[6,1]     .    .    .    .    .    .    DeE---R   .    .    .    ..   test	ebp, ebp
[6,2]     .    .    .    .    .    .    D=eE--R   .    .    .    ..   je	.LBB6_13
[6,3]     .    .    .    .    .    .    DeeeeeeER .    .    .    ..   cmp	dword ptr [rsp + 44], 4
[6,4]     .    .    .    .    .    .    D======eER.    .    .    ..   jne	.LBB6_5
[6,5]     .    .    .    .    .    .    D--------R.    .    .    ..   xor	eax, eax
[6,6]     .    .    .    .    .    .    .DeE-----R.    .    .    ..   test	dil, 1
[6,7]     .    .    .    .    .    .    .D=eE----R.    .    .    ..   jne	.LBB6_12
[6,8]     .    .    .    .    .    .    .D=eE----R.    .    .    ..   jmp	.LBB6_13
[6,9]     .    .    .    .    .    .    .DeE-----R.    .    .    ..   mov	eax, edi
[6,10]    .    .    .    .    .    .    .D=eE----R.    .    .    ..   and	eax, -2
[6,11]    .    .    .    .    .    .    .D=eE----R.    .    .    ..   lea	rcx, [rdi - 2]
[6,12]    .    .    .    .    .    .    . D=eE---R.    .    .    ..   mov	r9d, 16
[6,13]    .    .    .    .    .    .    . D=eE---R.    .    .    ..   cmp	rcx, 2
[6,14]    .    .    .    .    .    .    . D==eE--R.    .    .    ..   jae	.LBB6_6
[6,15]    .    .    .    .    .    .    . D=eE---R.    .    .    ..   test	cl, 2
[6,16]    .    .    .    .    .    .    . D==eE--R.    .    .    ..   je	.LBB6_10
[6,17]    .    .    .    .    .    .    . D=eE---R.    .    .    ..   test	dil, 1
[6,18]    .    .    .    .    .    .    .  D==eE-R.    .    .    ..   je	.LBB6_13
[6,19]    .    .    .    .    .    .    .  D==eE-R.    .    .    ..   shl	rax, 4
[6,20]    .    .    .    .    .    .    .  D-----R.    .    .    ..   vxorps	xmm1, xmm1, xmm1
[6,21]    .    .    .    .    .    .    .  D===eER.    .    .    ..   vmovaps	xmmword ptr [r12 + rax], xmm1
[6,22]    .    .    .    .    .    .    .   D==eER.    .    .    ..   vmovaps	xmmword ptr [rbx + rax], xmm1
[6,23]    .    .    .    .    .    .    .   D===eER    .    .    ..   mov	qword ptr [rsp + 224], rdi
[6,24]    .    .    .    .    .    .    .   D===eER    .    .    ..   mov	qword ptr [rsp + 280], rdx
[6,25]    .    .    .    .    .    .    .   D====eER   .    .    ..   mov	qword ptr [rsp + 296], r10
[7,0]     .    .    .    .    .    .    .   D====eER   .    .    ..   mov	dword ptr [rsp + 44], ebp
[7,1]     .    .    .    .    .    .    .    DeE---R   .    .    ..   test	ebp, ebp
[7,2]     .    .    .    .    .    .    .    D=eE--R   .    .    ..   je	.LBB6_13
[7,3]     .    .    .    .    .    .    .    DeeeeeeER .    .    ..   cmp	dword ptr [rsp + 44], 4
[7,4]     .    .    .    .    .    .    .    D======eER.    .    ..   jne	.LBB6_5
[7,5]     .    .    .    .    .    .    .    D--------R.    .    ..   xor	eax, eax
[7,6]     .    .    .    .    .    .    .    .DeE-----R.    .    ..   test	dil, 1
[7,7]     .    .    .    .    .    .    .    .D=eE----R.    .    ..   jne	.LBB6_12
[7,8]     .    .    .    .    .    .    .    .D=eE----R.    .    ..   jmp	.LBB6_13
[7,9]     .    .    .    .    .    .    .    .DeE-----R.    .    ..   mov	eax, edi
[7,10]    .    .    .    .    .    .    .    .D=eE----R.    .    ..   and	eax, -2
[7,11]    .    .    .    .    .    .    .    .D=eE----R.    .    ..   lea	rcx, [rdi - 2]
[7,12]    .    .    .    .    .    .    .    . D=eE---R.    .    ..   mov	r9d, 16
[7,13]    .    .    .    .    .    .    .    . D=eE---R.    .    ..   cmp	rcx, 2
[7,14]    .    .    .    .    .    .    .    . D==eE--R.    .    ..   jae	.LBB6_6
[7,15]    .    .    .    .    .    .    .    . D=eE---R.    .    ..   test	cl, 2
[7,16]    .    .    .    .    .    .    .    . D==eE--R.    .    ..   je	.LBB6_10
[7,17]    .    .    .    .    .    .    .    . D=eE---R.    .    ..   test	dil, 1
[7,18]    .    .    .    .    .    .    .    .  D==eE-R.    .    ..   je	.LBB6_13
[7,19]    .    .    .    .    .    .    .    .  D==eE-R.    .    ..   shl	rax, 4
[7,20]    .    .    .    .    .    .    .    .  D-----R.    .    ..   vxorps	xmm1, xmm1, xmm1
[7,21]    .    .    .    .    .    .    .    .  D===eER.    .    ..   vmovaps	xmmword ptr [r12 + rax], xmm1
[7,22]    .    .    .    .    .    .    .    .   D==eER.    .    ..   vmovaps	xmmword ptr [rbx + rax], xmm1
[7,23]    .    .    .    .    .    .    .    .   D===eER    .    ..   mov	qword ptr [rsp + 224], rdi
[7,24]    .    .    .    .    .    .    .    .   D===eER    .    ..   mov	qword ptr [rsp + 280], rdx
[7,25]    .    .    .    .    .    .    .    .   D====eER   .    ..   mov	qword ptr [rsp + 296], r10
[8,0]     .    .    .    .    .    .    .    .   D====eER   .    ..   mov	dword ptr [rsp + 44], ebp
[8,1]     .    .    .    .    .    .    .    .    DeE---R   .    ..   test	ebp, ebp
[8,2]     .    .    .    .    .    .    .    .    D=eE--R   .    ..   je	.LBB6_13
[8,3]     .    .    .    .    .    .    .    .    DeeeeeeER .    ..   cmp	dword ptr [rsp + 44], 4
[8,4]     .    .    .    .    .    .    .    .    D======eER.    ..   jne	.LBB6_5
[8,5]     .    .    .    .    .    .    .    .    D--------R.    ..   xor	eax, eax
[8,6]     .    .    .    .    .    .    .    .    .DeE-----R.    ..   test	dil, 1
[8,7]     .    .    .    .    .    .    .    .    .D=eE----R.    ..   jne	.LBB6_12
[8,8]     .    .    .    .    .    .    .    .    .D=eE----R.    ..   jmp	.LBB6_13
[8,9]     .    .    .    .    .    .    .    .    .DeE-----R.    ..   mov	eax, edi
[8,10]    .    .    .    .    .    .    .    .    .D=eE----R.    ..   and	eax, -2
[8,11]    .    .    .    .    .    .    .    .    .D=eE----R.    ..   lea	rcx, [rdi - 2]
[8,12]    .    .    .    .    .    .    .    .    . D=eE---R.    ..   mov	r9d, 16
[8,13]    .    .    .    .    .    .    .    .    . D=eE---R.    ..   cmp	rcx, 2
[8,14]    .    .    .    .    .    .    .    .    . D==eE--R.    ..   jae	.LBB6_6
[8,15]    .    .    .    .    .    .    .    .    . D=eE---R.    ..   test	cl, 2
[8,16]    .    .    .    .    .    .    .    .    . D==eE--R.    ..   je	.LBB6_10
[8,17]    .    .    .    .    .    .    .    .    . D=eE---R.    ..   test	dil, 1
[8,18]    .    .    .    .    .    .    .    .    .  D==eE-R.    ..   je	.LBB6_13
[8,19]    .    .    .    .    .    .    .    .    .  D==eE-R.    ..   shl	rax, 4
[8,20]    .    .    .    .    .    .    .    .    .  D-----R.    ..   vxorps	xmm1, xmm1, xmm1
[8,21]    .    .    .    .    .    .    .    .    .  D===eER.    ..   vmovaps	xmmword ptr [r12 + rax], xmm1
[8,22]    .    .    .    .    .    .    .    .    .   D==eER.    ..   vmovaps	xmmword ptr [rbx + rax], xmm1
[8,23]    .    .    .    .    .    .    .    .    .   D===eER    ..   mov	qword ptr [rsp + 224], rdi
[8,24]    .    .    .    .    .    .    .    .    .   D===eER    ..   mov	qword ptr [rsp + 280], rdx
[8,25]    .    .    .    .    .    .    .    .    .   D====eER   ..   mov	qword ptr [rsp + 296], r10
[9,0]     .    .    .    .    .    .    .    .    .   D====eER   ..   mov	dword ptr [rsp + 44], ebp
[9,1]     .    .    .    .    .    .    .    .    .    DeE---R   ..   test	ebp, ebp
[9,2]     .    .    .    .    .    .    .    .    .    D=eE--R   ..   je	.LBB6_13
[9,3]     .    .    .    .    .    .    .    .    .    DeeeeeeER ..   cmp	dword ptr [rsp + 44], 4
[9,4]     .    .    .    .    .    .    .    .    .    D======eER..   jne	.LBB6_5
[9,5]     .    .    .    .    .    .    .    .    .    D--------R..   xor	eax, eax
[9,6]     .    .    .    .    .    .    .    .    .    .DeE-----R..   test	dil, 1
[9,7]     .    .    .    .    .    .    .    .    .    .D=eE----R..   jne	.LBB6_12
[9,8]     .    .    .    .    .    .    .    .    .    .D=eE----R..   jmp	.LBB6_13
[9,9]     .    .    .    .    .    .    .    .    .    .DeE-----R..   mov	eax, edi
[9,10]    .    .    .    .    .    .    .    .    .    .D=eE----R..   and	eax, -2
[9,11]    .    .    .    .    .    .    .    .    .    .D=eE----R..   lea	rcx, [rdi - 2]
[9,12]    .    .    .    .    .    .    .    .    .    . D=eE---R..   mov	r9d, 16
[9,13]    .    .    .    .    .    .    .    .    .    . D=eE---R..   cmp	rcx, 2
[9,14]    .    .    .    .    .    .    .    .    .    . D==eE--R..   jae	.LBB6_6
[9,15]    .    .    .    .    .    .    .    .    .    . D=eE---R..   test	cl, 2
[9,16]    .    .    .    .    .    .    .    .    .    . D==eE--R..   je	.LBB6_10
[9,17]    .    .    .    .    .    .    .    .    .    . D=eE---R..   test	dil, 1
[9,18]    .    .    .    .    .    .    .    .    .    .  D==eE-R..   je	.LBB6_13
[9,19]    .    .    .    .    .    .    .    .    .    .  D==eE-R..   shl	rax, 4
[9,20]    .    .    .    .    .    .    .    .    .    .  D-----R..   vxorps	xmm1, xmm1, xmm1
[9,21]    .    .    .    .    .    .    .    .    .    .  D===eER..   vmovaps	xmmword ptr [r12 + rax], xmm1
[9,22]    .    .    .    .    .    .    .    .    .    .   D==eER..   vmovaps	xmmword ptr [rbx + rax], xmm1
[9,23]    .    .    .    .    .    .    .    .    .    .   D===eER.   mov	qword ptr [rsp + 224], rdi
[9,24]    .    .    .    .    .    .    .    .    .    .   D===eER.   mov	qword ptr [rsp + 280], rdx
[9,25]    .    .    .    .    .    .    .    .    .    .   D====eER   mov	qword ptr [rsp + 296], r10


```
</details>

<details><summary>Average Wait times (based on the timeline view):</summary>

```
[0]: Executions
[1]: Average time spent waiting in a scheduler's queue
[2]: Average time spent waiting in a scheduler's queue while ready
[3]: Average time elapsed from WB until retire stage

      [0]    [1]    [2]    [3]
0.     10    4.6    0.1    0.0       mov	dword ptr [rsp + 44], ebp
1.     10    1.0    1.0    2.7       test	ebp, ebp
2.     10    2.0    0.0    1.8       je	.LBB6_13
3.     10    1.0    1.0    0.0       cmp	dword ptr [rsp + 44], 4
4.     10    7.0    0.0    0.0       jne	.LBB6_5
5.     10    0.0    0.0    7.9       xor	eax, eax
6.     10    1.0    1.0    5.0       test	dil, 1
7.     10    2.0    0.0    4.0       jne	.LBB6_12
8.     10    1.9    1.9    4.1       jmp	.LBB6_13
9.     10    1.0    1.0    5.0       mov	eax, edi
10.    10    2.0    0.0    4.0       and	eax, -2
11.    10    1.9    1.9    4.0       lea	rcx, [rdi - 2]
12.    10    1.9    1.9    3.1       mov	r9d, 16
13.    10    2.0    0.0    3.0       cmp	rcx, 2
14.    10    3.0    0.0    2.0       jae	.LBB6_6
15.    10    2.0    0.0    3.0       test	cl, 2
16.    10    3.0    0.0    2.0       je	.LBB6_10
17.    10    1.9    1.9    3.0       test	dil, 1
18.    10    3.0    1.0    1.0       je	.LBB6_13
19.    10    3.0    2.0    1.0       shl	rax, 4
20.    10    0.0    0.0    5.0       vxorps	xmm1, xmm1, xmm1
21.    10    4.0    0.0    0.0       vmovaps	xmmword ptr [r12 + rax], xmm1
22.    10    3.0    0.0    0.0       vmovaps	xmmword ptr [rbx + rax], xmm1
23.    10    4.0    1.0    0.0       mov	qword ptr [rsp + 224], rdi
24.    10    4.0    0.0    0.0       mov	qword ptr [rsp + 280], rdx
25.    10    5.0    1.0    0.0       mov	qword ptr [rsp + 296], r10
       10    2.5    0.6    2.4       <total>


```
</details>

</details>

<details><summary>[1] Code Region - OPS_Mixing</summary>

```
Iterations:        100
Instructions:      90100
Total Cycles:      33995
Total uOps:        100700

Dispatch Width:    6
uOps Per Cycle:    2.96
IPC:               2.65
Block RThroughput: 167.8


Cycles with backend pressure increase [ 59.81% ]
Throughput Bottlenecks: 
  Resource Pressure       [ 18.58% ]
  - ICXPort0  [ 7.09% ]
  - ICXPort1  [ 8.55% ]
  - ICXPort2  [ 4.72% ]
  - ICXPort3  [ 4.72% ]
  - ICXPort4  [ 4.42% ]
  - ICXPort5  [ 8.25% ]
  - ICXPort6  [ 4.73% ]
  - ICXPort7  [ 4.42% ]
  - ICXPort8  [ 4.42% ]
  - ICXPort9  [ 4.42% ]
  Data Dependencies:      [ 55.08% ]
  - Register Dependencies [ 54.19% ]
  - Memory Dependencies   [ 1.77% ]

```

<details><summary>Critical sequence based on the simulation:</summary>

```

              Instruction                                 Dependency Information
        0.    mov	rax, qword ptr [rsp + 104]
        1.    mov	rdi, qword ptr [rax + 96]
        2.    test	rdi, rdi
        3.    je	.LBB6_28
        4.    cmp	dword ptr [rsp + 44], 0
        5.    je	.LBB6_26
        6.    vmovss	xmm1, dword ptr [rip + .LCPI6_0]
        7.    vdivss	xmm6, xmm1, xmm0
        8.    mov	rax, qword ptr [rsp + 104]
        9.    add	rax, 96
        10.   mov	qword ptr [rsp + 216], rax
        11.   lea	rax, [rsi + 40]
        12.   mov	qword ptr [rsp + 120], rax
        13.   lea	rax, [rsi + 8]
        14.   mov	qword ptr [rsp + 240], rax
        15.   mov	r15d, 1
        16.   vmovss	xmm7, dword ptr [rip + .LCPI6_1]
        17.   vmovddup	xmm8, qword ptr [rip + .LCPI6_2]
        18.   vpbroadcastd	xmm9, dword ptr [rip + .LCPI6_3]
        19.   vxorps	xmm10, xmm10, xmm10
        20.   vpbroadcastd	xmm11, dword ptr [rip + .LCPI6_4]
        21.   vmovss	xmm12, dword ptr [rip + .LCPI6_5]
        22.   vbroadcastss	xmm14, dword ptr [rip + .LCPI6_0]
        23.   mov	qword ptr [rsp + 232], r14
        24.   mov	byte ptr [rsp + 43], 0
        25.   mov	rax, qword ptr [rsp + 224]
        26.   mov	dword ptr [rsp + 112], eax
        27.   mov	edx, dword ptr [rdi + 40]
        28.   mov	rcx, qword ptr [rsi + 128]
        29.   xor	eax, eax
        30.   lock		cmpxchg	dword ptr [rsi + 332], r15d
        31.   jne	.LBB6_18
        32.   imul	rax, rdx, 56
        33.   cmp	dword ptr [rcx + rax], 2
        34.   jne	.LBB6_39
        35.   mov	r13, qword ptr [rcx + rax + 8]
        36.   mov	rdx, qword ptr [r13]
        37.   mov	r8, qword ptr [r13 + 8]
        38.   mov	qword ptr [r8], rdx
        39.   mov	r8, qword ptr [r13 + 8]
        40.   mov	qword ptr [rdx + 8], r8
        41.   mov	rdx, qword ptr [rsp + 120]
        42.   mov	qword ptr [r13 + 8], rdx
        43.   mov	rdx, qword ptr [rdx]
        44.   mov	qword ptr [r13], rdx
        45.   mov	qword ptr [rdx + 8], r13
        46.   mov	rdx, qword ptr [r13 + 8]
        47.   mov	qword ptr [rdx], r13
        48.   mov	rax, qword ptr [rcx + rax + 8]
        49.   cmp	dword ptr [rax + 56], r14d
        50.   jae	.LBB6_22
        51.   mov	dword ptr [rax + 56], r14d
        52.   mfence
        53.   mov	dword ptr [rsi + 332], 0
        54.   mov	eax, dword ptr [rdi + 40]
        55.   mov	r8, qword ptr [rsi + 128]
        56.   imul	rcx, rax, 56
        57.   mov	r11d, dword ptr [r8 + rcx + 40]
        58.   mov	bpl, 1
        59.   test	r11d, r11d
        60.   je	.LBB6_127
        61.   cmp	r11d, 1
        62.   jne	.LBB6_66
        63.   mov	r11d, eax
        64.   test	eax, eax
        65.   jne	.LBB6_67
        66.   xor	r11d, r11d
        67.   jmp	.LBB6_127
        68.   add	rax, 1
        69.   mov	r11d, eax
        70.   imul	r9, rax, 56
        71.   xor	ebp, ebp
        72.   xor	eax, eax
        73.   lock		cmpxchg	dword ptr [r8 + r9], r15d
        74.   jne	.LBB6_127
        75.   mov	rax, qword ptr [rsi]
        76.   cmp	byte ptr [rax + 80], 1
        77.   jne	.LBB6_69
        78.   cmp	byte ptr [rax + 136], 1
        79.   jne	.LBB6_71
        80.   cmp	byte ptr [rax + 192], 1
        81.   jne	.LBB6_73
        82.   cmp	byte ptr [rax + 248], 0
        83.   je	.LBB6_75
        84.   add	r8, r9
        85.   mov	dword ptr [r8], 0
        86.   xor	ebp, ebp
        87.   jmp	.LBB6_127
        88.   lea	rcx, [rax + 80]
        89.   xor	edx, edx
        90.   jmp	.LBB6_76
        91.   lea	rcx, [rax + 136]
        92.   mov	edx, 1
        93.   jmp	.LBB6_76
        94.   lea	rcx, [rax + 192]
        95.   mov	edx, 2
        96.   jmp	.LBB6_76
        97.   lea	rcx, [rax + 248]
        98.   mov	edx, 3
        99.   mov	dword ptr [rsp + 64], r11d
        100.  imul	rdx, rdx, 56
        101.  lea	r10, [rax + rdx]
        102.  add	r10, 32
        103.  mov	byte ptr [rcx], 1
        104.  mov	rcx, qword ptr [rax + rdx + 48]
        105.  add	dword ptr [rax + rdx + 56], 1
        106.  mov	qword ptr [rsp + 264], r10
        107.  mov	qword ptr [rax + rdx + 64], r10
        108.  mov	qword ptr [rax + rdx + 72], rcx
        109.  lea	rax, [r8 + r9]
        110.  add	rax, 32
        111.  mov	qword ptr [rsp + 48], rax
        112.  mov	edx, dword ptr [r8 + r9 + 32]
        113.  mov	qword ptr [rsp + 56], r8
        114.  mov	qword ptr [rsp + 96], r9
        115.  mov	ecx, dword ptr [r8 + r9 + 36]
        116.  xor	eax, eax
        117.  lock		cmpxchg	dword ptr [rsi + 332], r15d
        118.  jne	.LBB6_77
        119.  add	edx, edx
        120.  mov	dword ptr [rsp + 72], edx
        121.  imul	ecx, edx
        122.  lea	r15d, [rcx + 79]
        123.  and	r15d, -16
        124.  mov	r14, qword ptr [rsi + 16]
        125.  cmp	r14, qword ptr [rsp + 240]
        126.  mov	qword ptr [rsp + 272], rcx
        127.  jne	.LBB6_81
        128.  xor	r14d, r14d
        129.  jmp	.LBB6_80
        130.  mov	r14, qword ptr [r14 + 8]
        131.  cmp	r14, qword ptr [rsp + 240]
        132.  je	.LBB6_79
        133.  test	byte ptr [r14 + 16], 1
        134.  jne	.LBB6_82
        135.  cmp	qword ptr [r14 + 24], r15
        136.  jb	.LBB6_82
        137.  mov	rax, qword ptr [rsp + 56]
        138.  mov	rcx, qword ptr [rsp + 96]
        139.  add	rax, rcx
        140.  add	rax, 8
        141.  mov	qword ptr [rsp + 80], rax
        142.  jmp	.LBB6_91
        143.  mov	rdx, qword ptr [r14 + 8]
        144.  mov	rcx, rsi
        145.  mov	r8, r14
        146.  call	handmade_asset.MergeIfPossible
        147.  mov	dword ptr [rbp], 0
        148.  test	r14, r14
        149.  je	.LBB6_92
        150.  mov	rcx, qword ptr [r14 + 24]
        151.  sub	rcx, r15
        152.  jae	.LBB6_84
        153.  mov	rdx, qword ptr [rsi + 48]
        154.  mov	r14, qword ptr [rsp + 120]
        155.  cmp	rdx, r14
        156.  je	.LBB6_104
        157.  mov	r8, qword ptr [rsi + 128]
        158.  mov	rax, rdx
        159.  jmp	.LBB6_107
        160.  mov	rax, qword ptr [rax + 8]
        161.  cmp	rax, r14
        162.  je	.LBB6_106
        163.  mov	ecx, dword ptr [rax + 48]
        164.  imul	r10, rcx, 56
        165.  cmp	dword ptr [r8 + r10], 2
        166.  jb	.LBB6_112
        167.  lea	rbp, [r8 + r10]
        168.  lea	rcx, [r8 + r10]
        169.  add	rcx, 8
        170.  mov	r9d, dword ptr [rsi + 336]
        171.  test	r9, r9
        172.  je	.LBB6_89
        173.  mov	r10, qword ptr [r8 + r10 + 8]
        174.  mov	r10d, dword ptr [r10 + 56]
        175.  xor	r11d, r11d
        176.  cmp	dword ptr [rsi + 4*r11 + 340], r10d
        177.  je	.LBB6_112
        178.  add	r11, 1
        179.  cmp	r9, r11
        180.  jne	.LBB6_110
        181.  jmp	.LBB6_89
        182.  mov	rdx, qword ptr [rsi + 48]
        183.  mov	r14, qword ptr [rsp + 120]
        184.  cmp	rdx, r14
        185.  je	.LBB6_93
        186.  mov	r8, qword ptr [rsi + 128]
        187.  mov	rax, rdx
        188.  jmp	.LBB6_96
        189.  mov	rax, qword ptr [rax + 8]
        190.  cmp	rax, r14
        191.  je	.LBB6_95
        192.  mov	ecx, dword ptr [rax + 48]
        193.  imul	r10, rcx, 56
        194.  cmp	dword ptr [r8 + r10], 2
        195.  jb	.LBB6_101
        196.  lea	rbp, [r8 + r10]
        197.  lea	rcx, [r8 + r10]
        198.  add	rcx, 8
        199.  mov	r9d, dword ptr [rsi + 336]
        200.  test	r9, r9
        201.  je	.LBB6_89
        202.  mov	r10, qword ptr [r8 + r10 + 8]
        203.  mov	r10d, dword ptr [r10 + 56]
        204.  xor	r11d, r11d
        205.  cmp	dword ptr [rsi + 4*r11 + 340], r10d
        206.  je	.LBB6_101
        207.  add	r11, 1
        208.  cmp	r9, r11
        209.  jne	.LBB6_99
        210.  mov	rdx, qword ptr [rax]
        211.  mov	r8, qword ptr [rax + 8]
        212.  mov	qword ptr [r8], rdx
        213.  mov	rax, qword ptr [rax + 8]
        214.  mov	qword ptr [rdx + 8], rax
        215.  mov	rax, qword ptr [rcx]
        216.  lea	r14, [rax - 32]
        217.  mov	qword ptr [rax - 16], 0
        218.  mov	rdx, qword ptr [rax - 32]
        219.  mov	rcx, rsi
        220.  mov	r8, r14
        221.  call	handmade_asset.MergeIfPossible
        222.  test	al, 1
        223.  je	.LBB6_90
        224.  mov	r14, qword ptr [r14]
        225.  jmp	.LBB6_90
        226.  mov	qword ptr [r14 + 16], 1
        227.  lea	rax, [r14 + 32]
        228.  cmp	rcx, 4097
        229.  jb	.LBB6_86
        230.  mov	qword ptr [r14 + 24], r15
        231.  lea	rdx, [rax + r15]
        232.  mov	qword ptr [r14 + r15 + 48], 0
        233.  add	rcx, -32
        234.  mov	qword ptr [r14 + r15 + 56], rcx
        235.  mov	qword ptr [r14 + r15 + 32], r14
        236.  mov	rcx, qword ptr [r14 + 8]
        237.  mov	qword ptr [r14 + r15 + 40], rcx
        238.  mov	qword ptr [r14 + 8], rdx
        239.  mov	qword ptr [rcx], rdx
        240.  mov	ecx, dword ptr [rsp + 64]
        241.  mov	dword ptr [r14 + 80], ecx
        242.  mov	dword ptr [r14 + 84], r15d
        243.  mov	rcx, qword ptr [rsp + 120]
        244.  mov	qword ptr [r14 + 40], rcx
        245.  mov	rcx, qword ptr [rsi + 40]
        246.  mov	qword ptr [r14 + 32], rcx
        247.  mov	qword ptr [rcx + 8], rax
        248.  mov	rcx, qword ptr [r14 + 40]
        249.  mov	qword ptr [rcx], rax
        250.  mfence
        251.  mov	dword ptr [rsi + 332], 0
        252.  mov	r11, qword ptr [rsp + 80]
        253.  mov	qword ptr [r11], rax
        254.  mov	rcx, qword ptr [rsp + 48]
        255.  mov	eax, dword ptr [rcx]
        256.  mov	dword ptr [r14 + 64], eax
        257.  mov	ecx, dword ptr [rcx + 4]
        258.  mov	dword ptr [r14 + 68], ecx
        259.  mov	rbp, qword ptr [r11]
        260.  add	rbp, 64
        261.  test	rcx, rcx
        262.  je	.LBB6_126
        263.  mov	edx, dword ptr [rsp + 72]
        264.  cmp	ecx, 8
        265.  jae	.LBB6_114
        266.  xor	r8d, r8d
        267.  mov	rax, rbp
        268.  and	ecx, 7
        269.  jne	.LBB6_124
        270.  jmp	.LBB6_126
        271.  lea	r8, [rdx + rdx]
        272.  lea	rax, [rcx - 8]
        273.  cmp	rax, 8
        274.  jae	.LBB6_117
        275.  mov	r10, rbp
        276.  xor	r11d, r11d
        277.  jmp	.LBB6_120
        278.  mov	qword ptr [rsp + 248], rax
        279.  mov	r15, rax
        280.  shr	r15, 3
        281.  add	r15, 1
        282.  and	r15, -2
        283.  mov	rax, rdx
        284.  shl	rax, 5
        285.  sub	rax, r8
        286.  mov	qword ptr [rsp + 72], rax
        287.  lea	rax, [rdx + 8*rdx]
        288.  lea	rax, [rax + 2*rax]
        289.  add	rax, rdx
        290.  mov	qword ptr [rsp + 208], rax
        291.  lea	rax, [rdx + 4*rdx]
        292.  lea	r9, [rax + 4*rax]
        293.  add	r9, rdx
        294.  mov	qword ptr [rsp + 200], r9
        295.  lea	r9, [8*rdx]
        296.  mov	qword ptr [rsp + 192], r9
        297.  lea	r9, [r9 + 2*r9]
        298.  mov	qword ptr [rsp + 184], r9
        299.  lea	rax, [r8 + 4*rax]
        300.  mov	qword ptr [rsp + 176], rax
        301.  lea	rax, [4*rdx]
        302.  lea	r9, [rax + 4*rax]
        303.  mov	qword ptr [rsp + 160], r9
        304.  lea	r9, [r8 + 8*r8]
        305.  mov	qword ptr [rsp + 88], r9
        306.  mov	r10, rdx
        307.  shl	r10, 4
        308.  mov	r9, r10
        309.  mov	qword ptr [rsp + 48], r10
        310.  sub	r10, r8
        311.  mov	qword ptr [rsp + 152], r10
        312.  mov	qword ptr [rsp + 168], rax
        313.  lea	rax, [rax + 2*rax]
        314.  mov	qword ptr [rsp + 144], rax
        315.  lea	rax, [r8 + 4*r8]
        316.  mov	qword ptr [rsp + 136], rax
        317.  lea	rax, [r8 + 2*r8]
        318.  mov	qword ptr [rsp + 128], rax
        319.  mov	qword ptr [rsp + 256], rbp
        320.  mov	r10, rbp
        321.  xor	r11d, r11d
        322.  mov	qword ptr [r14 + 8*r11 + 48], r10
        323.  lea	rax, [r10 + r8]
        324.  mov	qword ptr [r14 + 8*r11 + 56], rax
        325.  add	rax, r8
        326.  mov	r9, qword ptr [rsp + 168]
        327.  lea	rbp, [r10 + r9]
        328.  mov	qword ptr [r14 + 8*r11 + 64], rbp
        329.  mov	r9, qword ptr [rsp + 128]
        330.  lea	rbp, [r10 + r9]
        331.  mov	qword ptr [r14 + 8*r11 + 72], rbp
        332.  lea	rbp, [r8 + r8]
        333.  mov	r9, qword ptr [rsp + 192]
        334.  add	r9, r10
        335.  mov	qword ptr [r14 + 8*r11 + 80], r9
        336.  mov	r9, qword ptr [rsp + 136]
        337.  lea	r9, [r10 + r9]
        338.  mov	qword ptr [r14 + 8*r11 + 88], r9
        339.  mov	r9, qword ptr [rsp + 144]
        340.  lea	r9, [r10 + r9]
        341.  mov	qword ptr [r14 + 8*r11 + 96], r9
        342.  mov	r9, qword ptr [rsp + 152]
        343.  lea	r9, [r10 + r9]
        344.  mov	qword ptr [r14 + 8*r11 + 104], r9
        345.  mov	r9, qword ptr [rsp + 48]
        346.  lea	r9, [r10 + r9]
        347.  mov	qword ptr [r14 + 8*r11 + 112], r9
        348.  mov	r9, qword ptr [rsp + 88]
        349.  lea	r9, [r10 + r9]
        350.  mov	qword ptr [r14 + 8*r11 + 120], r9
        351.  mov	r9, qword ptr [rsp + 160]
        352.  lea	r9, [r10 + r9]
        353.  mov	qword ptr [r14 + 8*r11 + 128], r9
        354.  mov	r9, qword ptr [rsp + 176]
        355.  add	r9, r10
        356.  mov	qword ptr [r14 + 8*r11 + 136], r9
        357.  mov	r9, qword ptr [rsp + 184]
        358.  add	r9, r10
        359.  mov	qword ptr [r14 + 8*r11 + 144], r9
        360.  mov	r9, qword ptr [rsp + 200]
        361.  add	r9, r10
        362.  mov	qword ptr [r14 + 8*r11 + 152], r9
        363.  lea	r9, [r8 + rbp]
        364.  add	rax, r9
        365.  add	r9, r8
        366.  add	rax, r9
        367.  add	r9, r8
        368.  add	r9, rax
        369.  mov	rax, qword ptr [rsp + 208]
        370.  add	rax, r10
        371.  mov	qword ptr [r14 + 8*r11 + 160], rax
        372.  add	r10, qword ptr [rsp + 72]
        373.  mov	qword ptr [r14 + 8*r11 + 168], r10
        374.  mov	r10, r9
        375.  add	r10, rbp
        376.  add	r11, 16
        377.  add	r15, -2
        378.  jne	.LBB6_118
        379.  mov	r15, r10
        380.  sub	r15, qword ptr [rsp + 48]
        381.  mov	rbp, qword ptr [rsp + 256]
        382.  mov	rax, qword ptr [rsp + 248]
        383.  test	al, 8
        384.  jne	.LBB6_122
        385.  mov	qword ptr [r14 + 8*r11 + 48], r10
        386.  lea	rax, [r10 + r8]
        387.  mov	qword ptr [r14 + 8*r11 + 56], rax
        388.  add	rax, r8
        389.  mov	qword ptr [r14 + 8*r11 + 64], rax
        390.  add	rax, r8
        391.  mov	qword ptr [r14 + 8*r11 + 72], rax
        392.  add	rax, r8
        393.  mov	qword ptr [r14 + 8*r11 + 80], rax
        394.  add	rax, r8
        395.  mov	qword ptr [r14 + 8*r11 + 88], rax
        396.  add	rax, r8
        397.  mov	qword ptr [r14 + 8*r11 + 96], rax
        398.  add	rax, r8
        399.  mov	qword ptr [r14 + 8*r11 + 104], rax
        400.  mov	r15, r10
        401.  mov	r8d, ecx
        402.  and	r8d, -8
        403.  mov	rax, rdx
        404.  shl	rax, 4
        405.  add	rax, r15
        406.  mov	r11, qword ptr [rsp + 80]
        407.  and	ecx, 7
        408.  je	.LBB6_126
        409.  lea	r8, [r14 + 8*r8]
        410.  add	r8, 48
        411.  add	rdx, rdx
        412.  xor	r9d, r9d
        413.  mov	qword ptr [r8 + 8*r9], rax
        414.  add	r9, 1
        415.  add	rax, rdx
        416.  cmp	rcx, r9
        417.  jne	.LBB6_125
        418.  mov	r10, qword ptr [rsp + 264]
        419.  mov	rcx, qword ptr [r10 + 16]
        420.  mov	rax, qword ptr [r10 + 8]
        421.  add	rax, rcx
        422.  mov	edx, eax
        423.  and	edx, 7
        424.  mov	r9d, 8
        425.  sub	r9, rdx
        426.  test	rdx, rdx
        427.  cmove	r9, rdx
        428.  lea	rcx, [rcx + r9 + 56]
        429.  lea	r8, [r9 + rax]
        430.  mov	qword ptr [r10 + 16], rcx
        431.  mov	qword ptr [r9 + rax], r10
        432.  mov	rcx, qword ptr [rsi + 128]
        433.  mov	rdx, qword ptr [rsp + 96]
        434.  add	rcx, rdx
        435.  mov	qword ptr [r9 + rax + 8], rcx
        436.  mov	rcx, qword ptr [rsp + 56]
        437.  mov	ecx, dword ptr [rcx + rdx + 52]
        438.  imul	rcx, rcx, 88
        439.  add	rcx, qword ptr [rsi + 104]
        440.  mov	qword ptr [r9 + rax + 16], rcx
        441.  mov	rcx, qword ptr [r11 + 8]
        442.  mov	qword ptr [r9 + rax + 24], rcx
        443.  mov	ecx, dword ptr [rsp + 272]
        444.  mov	qword ptr [r9 + rax + 32], rcx
        445.  mov	qword ptr [r9 + rax + 40], rbp
        446.  mov	dword ptr [r9 + rax + 48], 2
        447.  mov	byte ptr [r9 + rax + 52], 0
        448.  mov	rax, qword ptr [rsi]
        449.  mov	rcx, qword ptr [rax + 288]
        450.  lea	rdx, [rip + handmade_asset.LoadAssetWork]
        451.  call	qword ptr [rip + handmade_data.platformAPI]
        452.  xor	ebp, ebp
        453.  mov	r11d, dword ptr [rsp + 64]
        454.  vbroadcastss	xmm5, dword ptr [rdi + 8]
        455.  vbroadcastss	xmm1, dword ptr [rdi + 12]
        456.  vmovss	xmm2, dword ptr [rdi + 32]
        457.  vmovd	xmm0, dword ptr [rdi + 36]
        458.  vmulss	xmm17, xmm2, xmm7
        459.  mov	rax, qword ptr [rsp + 104]
        460.  vmovss	xmm3, dword ptr [rax + 112]
        461.  vmulss	xmm19, xmm6, dword ptr [rdi + 16]
        462.  vmovss	xmm4, dword ptr [rax + 116]
        463.  vmulss	xmm16, xmm19, xmm7
        464.  vmulss	xmm18, xmm6, dword ptr [rdi + 20]
        465.  mov	eax, dword ptr [r13 + 32]
        466.  vmovdqa64	xmm20, xmm11
        467.  vpternlogd	xmm20, xmm0, xmm9, 248
        468.  vaddss	xmm20, xmm0, xmm20
        469.  vrndscaless	xmm20, xmm20, xmm20, 11
        470.  vcvttss2usi	edx, xmm20
        471.  sub	eax, edx
        472.  vcvtusi2ss	xmm20, xmm23, eax
        473.  vdivss	xmm20, xmm20, xmm17
        474.  vmovdqa64	xmm21, xmm11
        475.  vpternlogd	xmm21, xmm20, xmm9, 248
        476.  vaddss	xmm20, xmm20, xmm21
        477.  vrndscaless	xmm20, xmm20, xmm20, 11
        478.  vcvttss2usi	eax, xmm20
        479.  mov	ecx, dword ptr [rsp + 112]
        480.  cmp	ecx, eax
        481.  mov	r10d, eax
        482.  cmovb	r10d, ecx
        483.  xor	edx, edx
        484.  vucomiss	xmm16, xmm10
        485.  jne	.LBB6_147
        486.  jnp	.LBB6_128
        487.  vmovss	xmm20, dword ptr [rdi + 24]
        488.  vsubss	xmm20, xmm20, xmm5
        489.  vdivss	xmm20, xmm20, xmm16
        490.  vaddss	xmm20, xmm20, xmm12
        491.  vcvttss2usi	r9d, xmm20
        492.  cmp	r10d, r9d
        493.  mov	r8d, 0
        494.  cmova	r8d, r9d
        495.  cmovae	r10d, r9d
        496.  vmulss	xmm20, xmm18, xmm7
        497.  vucomiss	xmm20, xmm10
        498.  jne	.LBB6_130
        499.  jnp	.LBB6_131
        500.  vmovss	xmm21, dword ptr [rdi + 28]
        501.  vsubss	xmm21, xmm21, xmm1
        502.  vdivss	xmm21, xmm21, xmm20
        503.  vaddss	xmm21, xmm21, xmm12
        504.  vcvttss2usi	r9d, xmm21
        505.  cmp	r10d, r9d
        506.  mov	edx, 0
        507.  cmova	edx, r9d
        508.  cmovae	r10d, r9d
        509.  mov	dword ptr [rsp + 56], ebp
        510.  mov	dword ptr [rsp + 64], r11d
        511.  vmulss	xmm13, xmm19, xmm10
 +----< 512.  vbroadcastss	xmm15, xmm19
 +----> 513.  vmulps	xmm19, xmm15, xmm8                ## REGISTER dependency:  xmm15
 |      514.  vblendps	xmm13, xmm13, xmm15, 2
 +----> 515.  vmovlhps	xmm19, xmm13, xmm19               ## REGISTER dependency:  xmm19
 |      516.  vaddps	xmm5, xmm5, xmm19
 |      517.  vmulss	xmm13, xmm18, xmm10
 |      518.  vbroadcastss	xmm15, xmm18
 |      519.  vmulps	xmm18, xmm15, xmm8
 |      520.  vblendps	xmm13, xmm13, xmm15, 2
 |      521.  vmovlhps	xmm18, xmm13, xmm18
 |      522.  vaddps	xmm15, xmm1, xmm18
 |      523.  vcvtusi2ss	xmm18, xmm23, r10d
 |      524.  vmulss	xmm1, xmm17, xmm18
 |      525.  vaddss	xmm1, xmm0, xmm1
 |      526.  mov	r9d, r10d
 |      527.  test	r10d, r10d
 |      528.  je	.LBB6_134
 |      529.  vbroadcastss	xmm3, xmm3
 |      530.  vbroadcastss	xmm16, xmm16
 |      531.  vbroadcastss	xmm4, xmm4
 |      532.  vbroadcastss	xmm17, xmm20
 |      533.  vsubss	xmm19, xmm1, xmm0
 |      534.  vdivss	xmm18, xmm19, xmm18
 |      535.  vmulss	xmm13, xmm10, xmm2
 +----> 536.  vbroadcastss	xmm2, xmm2                ## RESOURCE interference:  ICXPort5 [ probability: 99% ]
 |      537.  vmulps	xmm19, xmm2, xmmword ptr [rip + .LCPI6_6]
 +----> 538.  vblendps	xmm2, xmm13, xmm2, 2              ## REGISTER dependency:  xmm2
 |      539.  vmovlhps	xmm2, xmm2, xmm19
 |      540.  mov	r10, r9
 |      541.  shl	r10, 4
 |      542.  xor	r11d, r11d
 |      543.  xor	r14d, r14d
 +----> 544.  vcvtusi2ss	xmm19, xmm23, r14                 ## RESOURCE interference:  ICXPort0 [ probability: 99% ]
 +----> 545.  vmulss	xmm19, xmm18, xmm19               ## REGISTER dependency:  xmm19
 +----> 546.  vaddss	xmm19, xmm0, xmm19                ## REGISTER dependency:  xmm19
 +----> 547.  vbroadcastss	xmm19, xmm19              ## REGISTER dependency:  xmm19
 +----> 548.  vaddps	xmm19, xmm2, xmm19                ## REGISTER dependency:  xmm19
 +----> 549.  vcvttps2dq	xmm20, xmm19                      ## REGISTER dependency:  xmm19
 |      550.  mov	r15, qword ptr [r13 + 16]
 |      551.  vmovd	ebp, xmm20
 |      552.  movsxd	rbp, ebp
 |      553.  movsx	ecx, word ptr [r15 + 2*rbp]
 |      554.  vcvtsi2ss	xmm21, xmm23, ecx
 +----> 555.  vcvtdq2ps	xmm20, xmm20                      ## REGISTER dependency:  xmm20
 +----> 556.  vsubps	xmm19, xmm19, xmm20               ## REGISTER dependency:  xmm20
 |      557.  movsx	ecx, word ptr [r15 + 2*rbp + 2]
 |      558.  vbroadcastss	xmm20, xmm21
 |      559.  vcvtsi2ss	xmm21, xmm23, ecx
 |      560.  vbroadcastss	xmm21, xmm21
 +----> 561.  vsubps	xmm22, xmm14, xmm19               ## REGISTER dependency:  xmm19
 +----> 562.  vmulps	xmm20, xmm20, xmm22               ## REGISTER dependency:  xmm22
 |      563.  vmulps	xmm19, xmm21, xmm19
 +----> 564.  vaddps	xmm19, xmm19, xmm20               ## REGISTER dependency:  xmm20
 |      565.  vmulps	xmm20, xmm3, xmm5
 +----> 566.  vmulps	xmm20, xmm20, xmm19               ## REGISTER dependency:  xmm19
 |      567.  vaddps	xmm20, xmm20, xmmword ptr [r12 + r11]
 |      568.  vmulps	xmm21, xmm4, xmm15
 +----> 569.  vmulps	xmm19, xmm21, xmm19               ## RESOURCE interference:  ICXPort1 [ probability: 100% ]
        570.  vaddps	xmm19, xmm19, xmmword ptr [rbx + r11]
        571.  vmovaps	xmmword ptr [r12 + r11], xmm20
        572.  vaddps	xmm5, xmm16, xmm5
        573.  vmovaps	xmmword ptr [rbx + r11], xmm19
        574.  vaddps	xmm15, xmm17, xmm15
        575.  add	r14, 1
        576.  add	r11, 16
        577.  cmp	r10, r11
        578.  jne	.LBB6_133
        579.  vblendps	xmm0, xmm5, xmm15, 2
        580.  vmovlps	qword ptr [rdi + 8], xmm0
        581.  cmp	r8d, r9d
        582.  je	.LBB6_148
        583.  cmp	edx, r9d
        584.  mov	r14, qword ptr [rsp + 232]
        585.  mov	r15d, 1
        586.  je	.LBB6_136
        587.  vmovss	dword ptr [rdi + 36], xmm1
        588.  cmp	r9d, eax
        589.  je	.LBB6_140
        590.  jmp	.LBB6_138
        591.  vmovss	xmm0, dword ptr [rdi + 24]
        592.  vmovss	dword ptr [rdi + 8], xmm0
        593.  mov	dword ptr [rdi + 16], 0
        594.  cmp	edx, r9d
        595.  mov	r14, qword ptr [rsp + 232]
        596.  mov	r15d, 1
        597.  jne	.LBB6_137
        598.  vmovss	xmm0, dword ptr [rdi + 28]
        599.  vmovss	dword ptr [rdi + 12], xmm0
        600.  mov	dword ptr [rdi + 20], 0
        601.  vmovss	dword ptr [rdi + 36], xmm1
        602.  cmp	r9d, eax
        603.  jne	.LBB6_138
        604.  cmp	byte ptr [rsp + 56], 0
        605.  jne	.LBB6_143
        606.  mov	eax, dword ptr [rsp + 64]
        607.  mov	dword ptr [rdi + 40], eax
        608.  vcvtusi2ss	xmm0, xmm23, dword ptr [r13 + 32]
        609.  vsubss	xmm0, xmm1, xmm0
        610.  vmovss	dword ptr [rdi + 36], xmm0
        611.  vucomiss	xmm10, xmm0
        612.  jbe	.LBB6_138
        613.  mov	dword ptr [rdi + 36], 0
        614.  movzx	eax, byte ptr [rsp + 43]
        615.  sub	dword ptr [rsp + 112], r9d
        616.  je	.LBB6_37
        617.  test	al, 1
        618.  je	.LBB6_17
        619.  jmp	.LBB6_37
        620.  xor	r8d, r8d
        621.  vmulss	xmm20, xmm18, xmm7
        622.  vucomiss	xmm20, xmm10
        623.  jne	.LBB6_130
        624.  jp	.LBB6_130
        625.  jmp	.LBB6_131
        626.  mfence
        627.  mov	dword ptr [rsi + 332], 0
        628.  mov	eax, dword ptr [rdi + 40]
        629.  test	rax, rax
        630.  je	.LBB6_65
        631.  mov	r13, qword ptr [rsi + 128]
        632.  imul	r9, rax, 56
        633.  xor	eax, eax
        634.  lock		cmpxchg	dword ptr [r13 + r9], r15d
        635.  jne	.LBB6_65
        636.  mov	rax, qword ptr [rsi]
        637.  cmp	byte ptr [rax + 80], 1
        638.  jne	.LBB6_42
        639.  cmp	byte ptr [rax + 136], 1
        640.  jne	.LBB6_44
        641.  cmp	byte ptr [rax + 192], 1
        642.  jne	.LBB6_46
        643.  cmp	byte ptr [rax + 248], 0
        644.  je	.LBB6_48
        645.  add	r13, r9
        646.  mov	dword ptr [r13], 0
        647.  jmp	.LBB6_65
        648.  test	al, 1
        649.  jne	.LBB6_144
        650.  jmp	.LBB6_38
        651.  mov	byte ptr [rsp + 43], 1
        652.  jmp	.LBB6_144
        653.  lea	rcx, [rax + 80]
        654.  xor	edx, edx
        655.  jmp	.LBB6_49
        656.  lea	rcx, [rax + 136]
        657.  mov	edx, 1
        658.  jmp	.LBB6_49
        659.  lea	rcx, [rax + 192]
        660.  mov	edx, 2
        661.  jmp	.LBB6_49
        662.  lea	rcx, [rax + 248]
        663.  mov	edx, 3
        664.  imul	rdx, rdx, 56
        665.  lea	r8, [rax + rdx]
        666.  add	r8, 32
        667.  mov	byte ptr [rcx], 1
        668.  mov	rcx, qword ptr [rax + rdx + 48]
        669.  add	dword ptr [rax + rdx + 56], 1
        670.  mov	qword ptr [rsp + 144], r8
        671.  mov	qword ptr [rax + rdx + 64], r8
        672.  mov	qword ptr [rax + rdx + 72], rcx
        673.  mov	ebp, dword ptr [r13 + r9 + 32]
        674.  add	ebp, ebp
        675.  mov	eax, dword ptr [r13 + r9 + 36]
        676.  imul	eax, ebp
        677.  mov	qword ptr [rsp + 152], rax
        678.  lea	edx, [rax + 64]
        679.  mov	r8d, dword ptr [rdi + 40]
        680.  mov	rcx, rsi
        681.  mov	qword ptr [rsp + 88], r9
        682.  call	handmade_asset.AcquireAssetMemory
        683.  mov	r10, qword ptr [rsp + 88]
        684.  mov	qword ptr [r13 + r10 + 8], rax
        685.  mov	ecx, dword ptr [r13 + r10 + 32]
        686.  mov	dword ptr [rax + 32], ecx
        687.  mov	edx, dword ptr [r13 + r10 + 36]
        688.  mov	dword ptr [rax + 36], edx
        689.  mov	r11, qword ptr [r13 + r10 + 8]
        690.  add	r11, 64
        691.  test	rdx, rdx
        692.  je	.LBB6_64
        693.  mov	r8d, ebp
        694.  cmp	edx, 8
        695.  jae	.LBB6_52
        696.  xor	r9d, r9d
        697.  mov	rcx, r11
        698.  jmp	.LBB6_61
        699.  lea	r9, [r8 + r8]
        700.  lea	rcx, [rdx - 8]
        701.  cmp	rcx, 8
        702.  mov	qword ptr [rsp + 136], r11
        703.  jae	.LBB6_55
        704.  xor	r15d, r15d
        705.  jmp	.LBB6_58
        706.  mov	qword ptr [rsp + 128], r13
        707.  mov	qword ptr [rsp + 80], rcx
        708.  mov	r10, rcx
        709.  shr	r10, 3
        710.  add	r10, 1
        711.  and	r10, -2
        712.  mov	rcx, r8
        713.  shl	rcx, 5
        714.  sub	rcx, r9
        715.  mov	qword ptr [rsp + 112], rcx
        716.  lea	rcx, [r8 + 8*r8]
        717.  lea	rcx, [rcx + 2*rcx]
        718.  add	rcx, r8
        719.  mov	qword ptr [rsp + 64], rcx
        720.  lea	rcx, [r8 + 4*r8]
        721.  lea	r14, [rcx + 4*rcx]
        722.  add	r14, r8
        723.  mov	qword ptr [rsp + 56], r14
        724.  lea	r14, [8*r8]
        725.  mov	qword ptr [rsp + 96], r14
        726.  lea	r14, [r14 + 2*r14]
        727.  mov	qword ptr [rsp + 48], r14
        728.  lea	rcx, [r9 + 4*rcx]
        729.  mov	qword ptr [rsp + 72], rcx
        730.  lea	rcx, [4*r8]
        731.  lea	r14, [rcx + 4*rcx]
        732.  mov	qword ptr [rsp + 200], r14
        733.  lea	r14, [r9 + 8*r9]
        734.  mov	qword ptr [rsp + 192], r14
        735.  mov	rbp, r8
        736.  shl	rbp, 4
        737.  mov	r14, rbp
        738.  sub	r14, r9
        739.  mov	qword ptr [rsp + 184], r14
        740.  mov	qword ptr [rsp + 208], rcx
        741.  lea	rcx, [rcx + 2*rcx]
        742.  mov	qword ptr [rsp + 176], rcx
        743.  lea	rcx, [r9 + 4*r9]
        744.  mov	qword ptr [rsp + 168], rcx
        745.  lea	rcx, [r9 + 2*r9]
        746.  mov	qword ptr [rsp + 160], rcx
        747.  xor	r15d, r15d
        748.  mov	qword ptr [rax + 8*r15 + 16], r11
        749.  lea	r13, [r11 + r9]
        750.  mov	qword ptr [rax + 8*r15 + 24], r13
        751.  add	r13, r9
        752.  mov	rcx, qword ptr [rsp + 208]
        753.  add	rcx, r11
        754.  mov	qword ptr [rax + 8*r15 + 32], rcx
        755.  mov	rcx, qword ptr [rsp + 160]
        756.  lea	rcx, [r11 + rcx]
        757.  mov	qword ptr [rax + 8*r15 + 40], rcx
        758.  lea	rcx, [r9 + r9]
        759.  mov	r14, qword ptr [rsp + 96]
        760.  lea	r14, [r11 + r14]
        761.  mov	qword ptr [rax + 8*r15 + 48], r14
        762.  mov	r14, qword ptr [rsp + 168]
        763.  lea	r14, [r11 + r14]
        764.  mov	qword ptr [rax + 8*r15 + 56], r14
        765.  mov	r14, qword ptr [rsp + 176]
        766.  lea	r14, [r11 + r14]
        767.  mov	qword ptr [rax + 8*r15 + 64], r14
        768.  mov	r14, qword ptr [rsp + 184]
        769.  lea	r14, [r11 + r14]
        770.  mov	qword ptr [rax + 8*r15 + 72], r14
        771.  lea	r14, [r11 + rbp]
        772.  mov	qword ptr [rax + 8*r15 + 80], r14
        773.  mov	r14, qword ptr [rsp + 192]
        774.  lea	r14, [r11 + r14]
        775.  mov	qword ptr [rax + 8*r15 + 88], r14
        776.  mov	r14, qword ptr [rsp + 200]
        777.  lea	r14, [r11 + r14]
        778.  mov	qword ptr [rax + 8*r15 + 96], r14
        779.  mov	r14, qword ptr [rsp + 72]
        780.  add	r14, r11
        781.  mov	qword ptr [rax + 8*r15 + 104], r14
        782.  mov	r14, qword ptr [rsp + 48]
        783.  add	r14, r11
        784.  mov	qword ptr [rax + 8*r15 + 112], r14
        785.  mov	r14, qword ptr [rsp + 56]
        786.  add	r14, r11
        787.  mov	qword ptr [rax + 8*r15 + 120], r14
        788.  lea	r14, [rcx + r9]
        789.  add	r13, r14
        790.  add	r14, r9
        791.  add	r13, r14
        792.  add	r14, r9
        793.  add	r14, r13
        794.  mov	r13, qword ptr [rsp + 64]
        795.  add	r13, r11
        796.  mov	qword ptr [rax + 8*r15 + 128], r13
        797.  add	r11, qword ptr [rsp + 112]
        798.  mov	qword ptr [rax + 8*r15 + 136], r11
        799.  mov	r11, r14
        800.  add	r11, rcx
        801.  add	r15, 16
        802.  add	r10, -2
        803.  jne	.LBB6_56
        804.  mov	r10, r11
        805.  sub	r10, rbp
        806.  mov	r14, qword ptr [rsp + 232]
        807.  mov	r13, qword ptr [rsp + 128]
        808.  mov	rcx, qword ptr [rsp + 80]
        809.  test	cl, 8
        810.  jne	.LBB6_60
        811.  mov	qword ptr [rax + 8*r15 + 16], r11
        812.  lea	rcx, [r11 + r9]
        813.  mov	qword ptr [rax + 8*r15 + 24], rcx
        814.  add	rcx, r9
        815.  mov	qword ptr [rax + 8*r15 + 32], rcx
        816.  add	rcx, r9
        817.  mov	qword ptr [rax + 8*r15 + 40], rcx
        818.  add	rcx, r9
        819.  mov	qword ptr [rax + 8*r15 + 48], rcx
        820.  add	rcx, r9
        821.  mov	qword ptr [rax + 8*r15 + 56], rcx
        822.  add	rcx, r9
        823.  mov	qword ptr [rax + 8*r15 + 64], rcx
        824.  add	rcx, r9
        825.  mov	qword ptr [rax + 8*r15 + 72], rcx
        826.  mov	r10, r11
        827.  mov	r9d, edx
        828.  and	r9d, -8
        829.  mov	rcx, r8
        830.  shl	rcx, 4
        831.  add	rcx, r10
        832.  mov	r15d, 1
        833.  mov	r10, qword ptr [rsp + 88]
        834.  mov	r11, qword ptr [rsp + 136]
        835.  and	edx, 7
        836.  je	.LBB6_64
        837.  lea	rax, [rax + 8*r9]
        838.  add	rax, 16
        839.  add	r8, r8
        840.  xor	r9d, r9d
        841.  mov	qword ptr [rax + 8*r9], rcx
        842.  add	r9, 1
        843.  add	rcx, r8
        844.  cmp	rdx, r9
        845.  jne	.LBB6_63
        846.  mov	r8, qword ptr [rsp + 144]
        847.  mov	rcx, qword ptr [r8 + 16]
        848.  mov	rax, qword ptr [r8 + 8]
        849.  add	rax, rcx
        850.  mov	edx, eax
        851.  and	edx, 7
        852.  mov	r9d, 8
        853.  sub	r9, rdx
        854.  test	rdx, rdx
        855.  cmove	r9, rdx
        856.  lea	rdx, [r13 + r10 + 16]
        857.  lea	rcx, [rcx + r9 + 56]
        858.  mov	qword ptr [r8 + 16], rcx
        859.  mov	qword ptr [r9 + rax], r8
        860.  mov	ecx, dword ptr [rdi + 40]
        861.  imul	rcx, rcx, 56
        862.  add	rcx, qword ptr [rsi + 128]
        863.  lea	r8, [r9 + rax]
        864.  mov	qword ptr [r9 + rax + 8], rcx
        865.  mov	ecx, dword ptr [r13 + r10 + 52]
        866.  imul	rcx, rcx, 88
        867.  add	rcx, qword ptr [rsi + 104]
        868.  mov	qword ptr [r9 + rax + 16], rcx
        869.  mov	rcx, qword ptr [rdx]
        870.  mov	qword ptr [r9 + rax + 24], rcx
        871.  mov	ecx, dword ptr [rsp + 152]
        872.  mov	qword ptr [r9 + rax + 32], rcx
        873.  mov	qword ptr [r9 + rax + 40], r11
        874.  mov	dword ptr [r9 + rax + 48], 2
        875.  mov	byte ptr [r9 + rax + 52], 0
        876.  mov	rax, qword ptr [rsi]
        877.  mov	rcx, qword ptr [rax + 288]
        878.  lea	rdx, [rip + handmade_asset.LoadAssetWork]
        879.  call	qword ptr [rip + handmade_data.platformAPI]
        880.  cmp	byte ptr [rsp + 43], 0
        881.  je	.LBB6_38
        882.  mov	rax, qword ptr [rdi]
        883.  mov	rdx, qword ptr [rsp + 216]
        884.  mov	qword ptr [rdx], rax
        885.  mov	rcx, qword ptr [rsp + 104]
        886.  mov	rax, qword ptr [rcx + 104]
        887.  mov	qword ptr [rdi], rax
        888.  mov	qword ptr [rcx + 104], rdi
        889.  mov	rdi, rdx
        890.  mov	qword ptr [rsp + 216], rdi
        891.  mov	rdi, qword ptr [rdi]
        892.  test	rdi, rdi
        893.  jne	.LBB6_16
        894.  jmp	.LBB6_28
        895.  jmp	.LBB6_104
        896.  jmp	.LBB6_93
        897.  mov	rdi, qword ptr [rdi]
        898.  test	rdi, rdi
        899.  jne	.LBB6_26
        900.  mov	byte ptr [rsp + 43], 0


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
 1      5     0.50    *                   mov	rax, qword ptr [rsp + 104]
 1      5     0.50    *                   mov	rdi, qword ptr [rax + 96]
 1      1     0.25                        test	rdi, rdi
 1      1     0.50                        je	.LBB6_28
 2      6     0.50    *                   cmp	dword ptr [rsp + 44], 0
 1      1     0.50                        je	.LBB6_26
 1      5     0.50    *                   vmovss	xmm1, dword ptr [rip + .LCPI6_0]
 1      11    3.00                        vdivss	xmm6, xmm1, xmm0
 1      5     0.50    *                   mov	rax, qword ptr [rsp + 104]
 1      1     0.25                        add	rax, 96
 1      1     0.50           *            mov	qword ptr [rsp + 216], rax
 1      1     0.50                        lea	rax, [rsi + 40]
 1      1     0.50           *            mov	qword ptr [rsp + 120], rax
 1      1     0.50                        lea	rax, [rsi + 8]
 1      1     0.50           *            mov	qword ptr [rsp + 240], rax
 1      1     0.25                        mov	r15d, 1
 1      5     0.50    *                   vmovss	xmm7, dword ptr [rip + .LCPI6_1]
 1      6     0.50    *                   vmovddup	xmm8, qword ptr [rip + .LCPI6_2]
 1      6     0.50    *                   vpbroadcastd	xmm9, dword ptr [rip + .LCPI6_3]
 1      0     0.17                        vxorps	xmm10, xmm10, xmm10
 1      6     0.50    *                   vpbroadcastd	xmm11, dword ptr [rip + .LCPI6_4]
 1      5     0.50    *                   vmovss	xmm12, dword ptr [rip + .LCPI6_5]
 1      6     0.50    *                   vbroadcastss	xmm14, dword ptr [rip + .LCPI6_0]
 1      1     0.50           *            mov	qword ptr [rsp + 232], r14
 1      1     0.50           *            mov	byte ptr [rsp + 43], 0
 1      5     0.50    *                   mov	rax, qword ptr [rsp + 224]
 1      1     0.50           *            mov	dword ptr [rsp + 112], eax
 1      5     0.50    *                   mov	edx, dword ptr [rdi + 40]
 1      5     0.50    *                   mov	rcx, qword ptr [rsi + 128]
 1      0     0.17                        xor	eax, eax
 6      8     1.00    *      *            lock		cmpxchg	dword ptr [rsi + 332], r15d
 1      1     0.50                        jne	.LBB6_18
 1      3     1.00                        imul	rax, rdx, 56
 2      6     0.50    *                   cmp	dword ptr [rcx + rax], 2
 1      1     0.50                        jne	.LBB6_39
 1      5     0.50    *                   mov	r13, qword ptr [rcx + rax + 8]
 1      5     0.50    *                   mov	rdx, qword ptr [r13]
 1      5     0.50    *                   mov	r8, qword ptr [r13 + 8]
 1      1     0.50           *            mov	qword ptr [r8], rdx
 1      5     0.50    *                   mov	r8, qword ptr [r13 + 8]
 1      1     0.50           *            mov	qword ptr [rdx + 8], r8
 1      5     0.50    *                   mov	rdx, qword ptr [rsp + 120]
 1      1     0.50           *            mov	qword ptr [r13 + 8], rdx
 1      5     0.50    *                   mov	rdx, qword ptr [rdx]
 1      1     0.50           *            mov	qword ptr [r13], rdx
 1      1     0.50           *            mov	qword ptr [rdx + 8], r13
 1      5     0.50    *                   mov	rdx, qword ptr [r13 + 8]
 1      1     0.50           *            mov	qword ptr [rdx], r13
 1      5     0.50    *                   mov	rax, qword ptr [rcx + rax + 8]
 2      6     0.50    *                   cmp	dword ptr [rax + 56], r14d
 1      1     0.50                        jae	.LBB6_22
 1      1     0.50           *            mov	dword ptr [rax + 56], r14d
 3      3     1.00    *      *      U     mfence
 1      1     0.50           *            mov	dword ptr [rsi + 332], 0
 1      5     0.50    *                   mov	eax, dword ptr [rdi + 40]
 1      5     0.50    *                   mov	r8, qword ptr [rsi + 128]
 1      3     1.00                        imul	rcx, rax, 56
 1      5     0.50    *                   mov	r11d, dword ptr [r8 + rcx + 40]
 1      1     0.25                        mov	bpl, 1
 1      1     0.25                        test	r11d, r11d
 1      1     0.50                        je	.LBB6_127
 1      1     0.25                        cmp	r11d, 1
 1      1     0.50                        jne	.LBB6_66
 1      1     0.25                        mov	r11d, eax
 1      1     0.25                        test	eax, eax
 1      1     0.50                        jne	.LBB6_67
 1      0     0.17                        xor	r11d, r11d
 1      1     0.50                        jmp	.LBB6_127
 1      1     0.25                        add	rax, 1
 1      1     0.25                        mov	r11d, eax
 1      3     1.00                        imul	r9, rax, 56
 1      0     0.17                        xor	ebp, ebp
 1      0     0.17                        xor	eax, eax
 6      8     1.00    *      *            lock		cmpxchg	dword ptr [r8 + r9], r15d
 1      1     0.50                        jne	.LBB6_127
 1      5     0.50    *                   mov	rax, qword ptr [rsi]
 2      6     0.50    *                   cmp	byte ptr [rax + 80], 1
 1      1     0.50                        jne	.LBB6_69
 2      6     0.50    *                   cmp	byte ptr [rax + 136], 1
 1      1     0.50                        jne	.LBB6_71
 2      6     0.50    *                   cmp	byte ptr [rax + 192], 1
 1      1     0.50                        jne	.LBB6_73
 2      6     0.50    *                   cmp	byte ptr [rax + 248], 0
 1      1     0.50                        je	.LBB6_75
 1      1     0.25                        add	r8, r9
 1      1     0.50           *            mov	dword ptr [r8], 0
 1      0     0.17                        xor	ebp, ebp
 1      1     0.50                        jmp	.LBB6_127
 1      1     0.50                        lea	rcx, [rax + 80]
 1      0     0.17                        xor	edx, edx
 1      1     0.50                        jmp	.LBB6_76
 1      1     0.50                        lea	rcx, [rax + 136]
 1      1     0.25                        mov	edx, 1
 1      1     0.50                        jmp	.LBB6_76
 1      1     0.50                        lea	rcx, [rax + 192]
 1      1     0.25                        mov	edx, 2
 1      1     0.50                        jmp	.LBB6_76
 1      1     0.50                        lea	rcx, [rax + 248]
 1      1     0.25                        mov	edx, 3
 1      1     0.50           *            mov	dword ptr [rsp + 64], r11d
 1      3     1.00                        imul	rdx, rdx, 56
 1      1     0.50                        lea	r10, [rax + rdx]
 1      1     0.25                        add	r10, 32
 1      1     0.50           *            mov	byte ptr [rcx], 1
 1      5     0.50    *                   mov	rcx, qword ptr [rax + rdx + 48]
 3      7     0.50    *      *            add	dword ptr [rax + rdx + 56], 1
 1      1     0.50           *            mov	qword ptr [rsp + 264], r10
 1      1     0.50           *            mov	qword ptr [rax + rdx + 64], r10
 1      1     0.50           *            mov	qword ptr [rax + rdx + 72], rcx
 1      1     0.50                        lea	rax, [r8 + r9]
 1      1     0.25                        add	rax, 32
 1      1     0.50           *            mov	qword ptr [rsp + 48], rax
 1      5     0.50    *                   mov	edx, dword ptr [r8 + r9 + 32]
 1      1     0.50           *            mov	qword ptr [rsp + 56], r8
 1      1     0.50           *            mov	qword ptr [rsp + 96], r9
 1      5     0.50    *                   mov	ecx, dword ptr [r8 + r9 + 36]
 1      0     0.17                        xor	eax, eax
 6      8     1.00    *      *            lock		cmpxchg	dword ptr [rsi + 332], r15d
 1      1     0.50                        jne	.LBB6_77
 1      1     0.25                        add	edx, edx
 1      1     0.50           *            mov	dword ptr [rsp + 72], edx
 1      3     1.00                        imul	ecx, edx
 1      1     0.50                        lea	r15d, [rcx + 79]
 1      1     0.25                        and	r15d, -16
 1      5     0.50    *                   mov	r14, qword ptr [rsi + 16]
 2      6     0.50    *                   cmp	r14, qword ptr [rsp + 240]
 1      1     0.50           *            mov	qword ptr [rsp + 272], rcx
 1      1     0.50                        jne	.LBB6_81
 1      0     0.17                        xor	r14d, r14d
 1      1     0.50                        jmp	.LBB6_80
 1      5     0.50    *                   mov	r14, qword ptr [r14 + 8]
 2      6     0.50    *                   cmp	r14, qword ptr [rsp + 240]
 1      1     0.50                        je	.LBB6_79
 2      6     0.50    *                   test	byte ptr [r14 + 16], 1
 1      1     0.50                        jne	.LBB6_82
 2      6     0.50    *                   cmp	qword ptr [r14 + 24], r15
 1      1     0.50                        jb	.LBB6_82
 1      5     0.50    *                   mov	rax, qword ptr [rsp + 56]
 1      5     0.50    *                   mov	rcx, qword ptr [rsp + 96]
 1      1     0.25                        add	rax, rcx
 1      1     0.25                        add	rax, 8
 1      1     0.50           *            mov	qword ptr [rsp + 80], rax
 1      1     0.50                        jmp	.LBB6_91
 1      5     0.50    *                   mov	rdx, qword ptr [r14 + 8]
 1      1     0.25                        mov	rcx, rsi
 1      1     0.25                        mov	r8, r14
 4      3     0.50                        call	handmade_asset.MergeIfPossible
 1      1     0.50           *            mov	dword ptr [rbp], 0
 1      1     0.25                        test	r14, r14
 1      1     0.50                        je	.LBB6_92
 1      5     0.50    *                   mov	rcx, qword ptr [r14 + 24]
 1      1     0.25                        sub	rcx, r15
 1      1     0.50                        jae	.LBB6_84
 1      5     0.50    *                   mov	rdx, qword ptr [rsi + 48]
 1      5     0.50    *                   mov	r14, qword ptr [rsp + 120]
 1      1     0.25                        cmp	rdx, r14
 1      1     0.50                        je	.LBB6_104
 1      5     0.50    *                   mov	r8, qword ptr [rsi + 128]
 1      1     0.25                        mov	rax, rdx
 1      1     0.50                        jmp	.LBB6_107
 1      5     0.50    *                   mov	rax, qword ptr [rax + 8]
 1      1     0.25                        cmp	rax, r14
 1      1     0.50                        je	.LBB6_106
 1      5     0.50    *                   mov	ecx, dword ptr [rax + 48]
 1      3     1.00                        imul	r10, rcx, 56
 2      6     0.50    *                   cmp	dword ptr [r8 + r10], 2
 1      1     0.50                        jb	.LBB6_112
 1      1     0.50                        lea	rbp, [r8 + r10]
 1      1     0.50                        lea	rcx, [r8 + r10]
 1      1     0.25                        add	rcx, 8
 1      5     0.50    *                   mov	r9d, dword ptr [rsi + 336]
 1      1     0.25                        test	r9, r9
 1      1     0.50                        je	.LBB6_89
 1      5     0.50    *                   mov	r10, qword ptr [r8 + r10 + 8]
 1      5     0.50    *                   mov	r10d, dword ptr [r10 + 56]
 1      0     0.17                        xor	r11d, r11d
 2      6     0.50    *                   cmp	dword ptr [rsi + 4*r11 + 340], r10d
 1      1     0.50                        je	.LBB6_112
 1      1     0.25                        add	r11, 1
 1      1     0.25                        cmp	r9, r11
 1      1     0.50                        jne	.LBB6_110
 1      1     0.50                        jmp	.LBB6_89
 1      5     0.50    *                   mov	rdx, qword ptr [rsi + 48]
 1      5     0.50    *                   mov	r14, qword ptr [rsp + 120]
 1      1     0.25                        cmp	rdx, r14
 1      1     0.50                        je	.LBB6_93
 1      5     0.50    *                   mov	r8, qword ptr [rsi + 128]
 1      1     0.25                        mov	rax, rdx
 1      1     0.50                        jmp	.LBB6_96
 1      5     0.50    *                   mov	rax, qword ptr [rax + 8]
 1      1     0.25                        cmp	rax, r14
 1      1     0.50                        je	.LBB6_95
 1      5     0.50    *                   mov	ecx, dword ptr [rax + 48]
 1      3     1.00                        imul	r10, rcx, 56
 2      6     0.50    *                   cmp	dword ptr [r8 + r10], 2
 1      1     0.50                        jb	.LBB6_101
 1      1     0.50                        lea	rbp, [r8 + r10]
 1      1     0.50                        lea	rcx, [r8 + r10]
 1      1     0.25                        add	rcx, 8
 1      5     0.50    *                   mov	r9d, dword ptr [rsi + 336]
 1      1     0.25                        test	r9, r9
 1      1     0.50                        je	.LBB6_89
 1      5     0.50    *                   mov	r10, qword ptr [r8 + r10 + 8]
 1      5     0.50    *                   mov	r10d, dword ptr [r10 + 56]
 1      0     0.17                        xor	r11d, r11d
 2      6     0.50    *                   cmp	dword ptr [rsi + 4*r11 + 340], r10d
 1      1     0.50                        je	.LBB6_101
 1      1     0.25                        add	r11, 1
 1      1     0.25                        cmp	r9, r11
 1      1     0.50                        jne	.LBB6_99
 1      5     0.50    *                   mov	rdx, qword ptr [rax]
 1      5     0.50    *                   mov	r8, qword ptr [rax + 8]
 1      1     0.50           *            mov	qword ptr [r8], rdx
 1      5     0.50    *                   mov	rax, qword ptr [rax + 8]
 1      1     0.50           *            mov	qword ptr [rdx + 8], rax
 1      5     0.50    *                   mov	rax, qword ptr [rcx]
 1      1     0.50                        lea	r14, [rax - 32]
 1      1     0.50           *            mov	qword ptr [rax - 16], 0
 1      5     0.50    *                   mov	rdx, qword ptr [rax - 32]
 1      1     0.25                        mov	rcx, rsi
 1      1     0.25                        mov	r8, r14
 4      3     0.50                        call	handmade_asset.MergeIfPossible
 1      1     0.25                        test	al, 1
 1      1     0.50                        je	.LBB6_90
 1      5     0.50    *                   mov	r14, qword ptr [r14]
 1      1     0.50                        jmp	.LBB6_90
 1      1     0.50           *            mov	qword ptr [r14 + 16], 1
 1      1     0.50                        lea	rax, [r14 + 32]
 1      1     0.25                        cmp	rcx, 4097
 1      1     0.50                        jb	.LBB6_86
 1      1     0.50           *            mov	qword ptr [r14 + 24], r15
 1      1     0.50                        lea	rdx, [rax + r15]
 1      1     0.50           *            mov	qword ptr [r14 + r15 + 48], 0
 1      1     0.25                        add	rcx, -32
 1      1     0.50           *            mov	qword ptr [r14 + r15 + 56], rcx
 1      1     0.50           *            mov	qword ptr [r14 + r15 + 32], r14
 1      5     0.50    *                   mov	rcx, qword ptr [r14 + 8]
 1      1     0.50           *            mov	qword ptr [r14 + r15 + 40], rcx
 1      1     0.50           *            mov	qword ptr [r14 + 8], rdx
 1      1     0.50           *            mov	qword ptr [rcx], rdx
 1      5     0.50    *                   mov	ecx, dword ptr [rsp + 64]
 1      1     0.50           *            mov	dword ptr [r14 + 80], ecx
 1      1     0.50           *            mov	dword ptr [r14 + 84], r15d
 1      5     0.50    *                   mov	rcx, qword ptr [rsp + 120]
 1      1     0.50           *            mov	qword ptr [r14 + 40], rcx
 1      5     0.50    *                   mov	rcx, qword ptr [rsi + 40]
 1      1     0.50           *            mov	qword ptr [r14 + 32], rcx
 1      1     0.50           *            mov	qword ptr [rcx + 8], rax
 1      5     0.50    *                   mov	rcx, qword ptr [r14 + 40]
 1      1     0.50           *            mov	qword ptr [rcx], rax
 3      3     1.00    *      *      U     mfence
 1      1     0.50           *            mov	dword ptr [rsi + 332], 0
 1      5     0.50    *                   mov	r11, qword ptr [rsp + 80]
 1      1     0.50           *            mov	qword ptr [r11], rax
 1      5     0.50    *                   mov	rcx, qword ptr [rsp + 48]
 1      5     0.50    *                   mov	eax, dword ptr [rcx]
 1      1     0.50           *            mov	dword ptr [r14 + 64], eax
 1      5     0.50    *                   mov	ecx, dword ptr [rcx + 4]
 1      1     0.50           *            mov	dword ptr [r14 + 68], ecx
 1      5     0.50    *                   mov	rbp, qword ptr [r11]
 1      1     0.25                        add	rbp, 64
 1      1     0.25                        test	rcx, rcx
 1      1     0.50                        je	.LBB6_126
 1      5     0.50    *                   mov	edx, dword ptr [rsp + 72]
 1      1     0.25                        cmp	ecx, 8
 1      1     0.50                        jae	.LBB6_114
 1      0     0.17                        xor	r8d, r8d
 1      1     0.25                        mov	rax, rbp
 1      1     0.25                        and	ecx, 7
 1      1     0.50                        jne	.LBB6_124
 1      1     0.50                        jmp	.LBB6_126
 1      1     0.50                        lea	r8, [rdx + rdx]
 1      1     0.50                        lea	rax, [rcx - 8]
 1      1     0.25                        cmp	rax, 8
 1      1     0.50                        jae	.LBB6_117
 1      1     0.25                        mov	r10, rbp
 1      0     0.17                        xor	r11d, r11d
 1      1     0.50                        jmp	.LBB6_120
 1      1     0.50           *            mov	qword ptr [rsp + 248], rax
 1      1     0.25                        mov	r15, rax
 1      1     0.50                        shr	r15, 3
 1      1     0.25                        add	r15, 1
 1      1     0.25                        and	r15, -2
 1      1     0.25                        mov	rax, rdx
 1      1     0.50                        shl	rax, 5
 1      1     0.25                        sub	rax, r8
 1      1     0.50           *            mov	qword ptr [rsp + 72], rax
 1      1     0.50                        lea	rax, [rdx + 8*rdx]
 1      1     0.50                        lea	rax, [rax + 2*rax]
 1      1     0.25                        add	rax, rdx
 1      1     0.50           *            mov	qword ptr [rsp + 208], rax
 1      1     0.50                        lea	rax, [rdx + 4*rdx]
 1      1     0.50                        lea	r9, [rax + 4*rax]
 1      1     0.25                        add	r9, rdx
 1      1     0.50           *            mov	qword ptr [rsp + 200], r9
 1      1     0.50                        lea	r9, [8*rdx]
 1      1     0.50           *            mov	qword ptr [rsp + 192], r9
 1      1     0.50                        lea	r9, [r9 + 2*r9]
 1      1     0.50           *            mov	qword ptr [rsp + 184], r9
 1      1     0.50                        lea	rax, [r8 + 4*rax]
 1      1     0.50           *            mov	qword ptr [rsp + 176], rax
 1      1     0.50                        lea	rax, [4*rdx]
 1      1     0.50                        lea	r9, [rax + 4*rax]
 1      1     0.50           *            mov	qword ptr [rsp + 160], r9
 1      1     0.50                        lea	r9, [r8 + 8*r8]
 1      1     0.50           *            mov	qword ptr [rsp + 88], r9
 1      1     0.25                        mov	r10, rdx
 1      1     0.50                        shl	r10, 4
 1      1     0.25                        mov	r9, r10
 1      1     0.50           *            mov	qword ptr [rsp + 48], r10
 1      1     0.25                        sub	r10, r8
 1      1     0.50           *            mov	qword ptr [rsp + 152], r10
 1      1     0.50           *            mov	qword ptr [rsp + 168], rax
 1      1     0.50                        lea	rax, [rax + 2*rax]
 1      1     0.50           *            mov	qword ptr [rsp + 144], rax
 1      1     0.50                        lea	rax, [r8 + 4*r8]
 1      1     0.50           *            mov	qword ptr [rsp + 136], rax
 1      1     0.50                        lea	rax, [r8 + 2*r8]
 1      1     0.50           *            mov	qword ptr [rsp + 128], rax
 1      1     0.50           *            mov	qword ptr [rsp + 256], rbp
 1      1     0.25                        mov	r10, rbp
 1      0     0.17                        xor	r11d, r11d
 1      1     0.50           *            mov	qword ptr [r14 + 8*r11 + 48], r10
 1      1     0.50                        lea	rax, [r10 + r8]
 1      1     0.50           *            mov	qword ptr [r14 + 8*r11 + 56], rax
 1      1     0.25                        add	rax, r8
 1      5     0.50    *                   mov	r9, qword ptr [rsp + 168]
 1      1     0.50                        lea	rbp, [r10 + r9]
 1      1     0.50           *            mov	qword ptr [r14 + 8*r11 + 64], rbp
 1      5     0.50    *                   mov	r9, qword ptr [rsp + 128]
 1      1     0.50                        lea	rbp, [r10 + r9]
 1      1     0.50           *            mov	qword ptr [r14 + 8*r11 + 72], rbp
 1      1     0.50                        lea	rbp, [r8 + r8]
 1      5     0.50    *                   mov	r9, qword ptr [rsp + 192]
 1      1     0.25                        add	r9, r10
 1      1     0.50           *            mov	qword ptr [r14 + 8*r11 + 80], r9
 1      5     0.50    *                   mov	r9, qword ptr [rsp + 136]
 1      1     0.50                        lea	r9, [r10 + r9]
 1      1     0.50           *            mov	qword ptr [r14 + 8*r11 + 88], r9
 1      5     0.50    *                   mov	r9, qword ptr [rsp + 144]
 1      1     0.50                        lea	r9, [r10 + r9]
 1      1     0.50           *            mov	qword ptr [r14 + 8*r11 + 96], r9
 1      5     0.50    *                   mov	r9, qword ptr [rsp + 152]
 1      1     0.50                        lea	r9, [r10 + r9]
 1      1     0.50           *            mov	qword ptr [r14 + 8*r11 + 104], r9
 1      5     0.50    *                   mov	r9, qword ptr [rsp + 48]
 1      1     0.50                        lea	r9, [r10 + r9]
 1      1     0.50           *            mov	qword ptr [r14 + 8*r11 + 112], r9
 1      5     0.50    *                   mov	r9, qword ptr [rsp + 88]
 1      1     0.50                        lea	r9, [r10 + r9]
 1      1     0.50           *            mov	qword ptr [r14 + 8*r11 + 120], r9
 1      5     0.50    *                   mov	r9, qword ptr [rsp + 160]
 1      1     0.50                        lea	r9, [r10 + r9]
 1      1     0.50           *            mov	qword ptr [r14 + 8*r11 + 128], r9
 1      5     0.50    *                   mov	r9, qword ptr [rsp + 176]
 1      1     0.25                        add	r9, r10
 1      1     0.50           *            mov	qword ptr [r14 + 8*r11 + 136], r9
 1      5     0.50    *                   mov	r9, qword ptr [rsp + 184]
 1      1     0.25                        add	r9, r10
 1      1     0.50           *            mov	qword ptr [r14 + 8*r11 + 144], r9
 1      5     0.50    *                   mov	r9, qword ptr [rsp + 200]
 1      1     0.25                        add	r9, r10
 1      1     0.50           *            mov	qword ptr [r14 + 8*r11 + 152], r9
 1      1     0.50                        lea	r9, [r8 + rbp]
 1      1     0.25                        add	rax, r9
 1      1     0.25                        add	r9, r8
 1      1     0.25                        add	rax, r9
 1      1     0.25                        add	r9, r8
 1      1     0.25                        add	r9, rax
 1      5     0.50    *                   mov	rax, qword ptr [rsp + 208]
 1      1     0.25                        add	rax, r10
 1      1     0.50           *            mov	qword ptr [r14 + 8*r11 + 160], rax
 2      6     0.50    *                   add	r10, qword ptr [rsp + 72]
 1      1     0.50           *            mov	qword ptr [r14 + 8*r11 + 168], r10
 1      1     0.25                        mov	r10, r9
 1      1     0.25                        add	r10, rbp
 1      1     0.25                        add	r11, 16
 1      1     0.25                        add	r15, -2
 1      1     0.50                        jne	.LBB6_118
 1      1     0.25                        mov	r15, r10
 2      6     0.50    *                   sub	r15, qword ptr [rsp + 48]
 1      5     0.50    *                   mov	rbp, qword ptr [rsp + 256]
 1      5     0.50    *                   mov	rax, qword ptr [rsp + 248]
 1      1     0.25                        test	al, 8
 1      1     0.50                        jne	.LBB6_122
 1      1     0.50           *            mov	qword ptr [r14 + 8*r11 + 48], r10
 1      1     0.50                        lea	rax, [r10 + r8]
 1      1     0.50           *            mov	qword ptr [r14 + 8*r11 + 56], rax
 1      1     0.25                        add	rax, r8
 1      1     0.50           *            mov	qword ptr [r14 + 8*r11 + 64], rax
 1      1     0.25                        add	rax, r8
 1      1     0.50           *            mov	qword ptr [r14 + 8*r11 + 72], rax
 1      1     0.25                        add	rax, r8
 1      1     0.50           *            mov	qword ptr [r14 + 8*r11 + 80], rax
 1      1     0.25                        add	rax, r8
 1      1     0.50           *            mov	qword ptr [r14 + 8*r11 + 88], rax
 1      1     0.25                        add	rax, r8
 1      1     0.50           *            mov	qword ptr [r14 + 8*r11 + 96], rax
 1      1     0.25                        add	rax, r8
 1      1     0.50           *            mov	qword ptr [r14 + 8*r11 + 104], rax
 1      1     0.25                        mov	r15, r10
 1      1     0.25                        mov	r8d, ecx
 1      1     0.25                        and	r8d, -8
 1      1     0.25                        mov	rax, rdx
 1      1     0.50                        shl	rax, 4
 1      1     0.25                        add	rax, r15
 1      5     0.50    *                   mov	r11, qword ptr [rsp + 80]
 1      1     0.25                        and	ecx, 7
 1      1     0.50                        je	.LBB6_126
 1      1     0.50                        lea	r8, [r14 + 8*r8]
 1      1     0.25                        add	r8, 48
 1      1     0.25                        add	rdx, rdx
 1      0     0.17                        xor	r9d, r9d
 1      1     0.50           *            mov	qword ptr [r8 + 8*r9], rax
 1      1     0.25                        add	r9, 1
 1      1     0.25                        add	rax, rdx
 1      1     0.25                        cmp	rcx, r9
 1      1     0.50                        jne	.LBB6_125
 1      5     0.50    *                   mov	r10, qword ptr [rsp + 264]
 1      5     0.50    *                   mov	rcx, qword ptr [r10 + 16]
 1      5     0.50    *                   mov	rax, qword ptr [r10 + 8]
 1      1     0.25                        add	rax, rcx
 1      1     0.25                        mov	edx, eax
 1      1     0.25                        and	edx, 7
 1      1     0.25                        mov	r9d, 8
 1      1     0.25                        sub	r9, rdx
 1      1     0.25                        test	rdx, rdx
 1      1     0.50                        cmove	r9, rdx
 1      1     0.50                        lea	rcx, [rcx + r9 + 56]
 1      1     0.50                        lea	r8, [r9 + rax]
 1      1     0.50           *            mov	qword ptr [r10 + 16], rcx
 1      1     0.50           *            mov	qword ptr [r9 + rax], r10
 1      5     0.50    *                   mov	rcx, qword ptr [rsi + 128]
 1      5     0.50    *                   mov	rdx, qword ptr [rsp + 96]
 1      1     0.25                        add	rcx, rdx
 1      1     0.50           *            mov	qword ptr [r9 + rax + 8], rcx
 1      5     0.50    *                   mov	rcx, qword ptr [rsp + 56]
 1      5     0.50    *                   mov	ecx, dword ptr [rcx + rdx + 52]
 1      3     1.00                        imul	rcx, rcx, 88
 2      6     0.50    *                   add	rcx, qword ptr [rsi + 104]
 1      1     0.50           *            mov	qword ptr [r9 + rax + 16], rcx
 1      5     0.50    *                   mov	rcx, qword ptr [r11 + 8]
 1      1     0.50           *            mov	qword ptr [r9 + rax + 24], rcx
 1      5     0.50    *                   mov	ecx, dword ptr [rsp + 272]
 1      1     0.50           *            mov	qword ptr [r9 + rax + 32], rcx
 1      1     0.50           *            mov	qword ptr [r9 + rax + 40], rbp
 1      1     0.50           *            mov	dword ptr [r9 + rax + 48], 2
 1      1     0.50           *            mov	byte ptr [r9 + rax + 52], 0
 1      5     0.50    *                   mov	rax, qword ptr [rsi]
 1      5     0.50    *                   mov	rcx, qword ptr [rax + 288]
 1      1     0.50                        lea	rdx, [rip + handmade_asset.LoadAssetWork]
 5      7     1.00    *                   call	qword ptr [rip + handmade_data.platformAPI]
 1      0     0.17                        xor	ebp, ebp
 1      5     0.50    *                   mov	r11d, dword ptr [rsp + 64]
 1      6     0.50    *                   vbroadcastss	xmm5, dword ptr [rdi + 8]
 1      6     0.50    *                   vbroadcastss	xmm1, dword ptr [rdi + 12]
 1      5     0.50    *                   vmovss	xmm2, dword ptr [rdi + 32]
 1      5     0.50    *                   vmovd	xmm0, dword ptr [rdi + 36]
 1      4     0.50                        vmulss	xmm17, xmm2, xmm7
 1      5     0.50    *                   mov	rax, qword ptr [rsp + 104]
 1      5     0.50    *                   vmovss	xmm3, dword ptr [rax + 112]
 2      9     0.50    *                   vmulss	xmm19, xmm6, dword ptr [rdi + 16]
 1      5     0.50    *                   vmovss	xmm4, dword ptr [rax + 116]
 1      4     0.50                        vmulss	xmm16, xmm19, xmm7
 2      9     0.50    *                   vmulss	xmm18, xmm6, dword ptr [rdi + 20]
 1      5     0.50    *                   mov	eax, dword ptr [r13 + 32]
 1      1     0.33                        vmovdqa64	xmm20, xmm11
 1      1     0.33                        vpternlogd	xmm20, xmm0, xmm9, 248
 1      4     0.50                        vaddss	xmm20, xmm0, xmm20
 2      8     1.00                        vrndscaless	xmm20, xmm20, xmm20, 11
 2      6     1.00                        vcvttss2usi	edx, xmm20
 1      1     0.25                        sub	eax, edx
 2      5     1.00                        vcvtusi2ss	xmm20, xmm23, eax
 1      11    3.00                        vdivss	xmm20, xmm20, xmm17
 1      1     0.33                        vmovdqa64	xmm21, xmm11
 1      1     0.33                        vpternlogd	xmm21, xmm20, xmm9, 248
 1      4     0.50                        vaddss	xmm20, xmm20, xmm21
 2      8     1.00                        vrndscaless	xmm20, xmm20, xmm20, 11
 2      6     1.00                        vcvttss2usi	eax, xmm20
 1      5     0.50    *                   mov	ecx, dword ptr [rsp + 112]
 1      1     0.25                        cmp	ecx, eax
 1      1     0.25                        mov	r10d, eax
 1      1     0.50                        cmovb	r10d, ecx
 1      0     0.17                        xor	edx, edx
 1      2     1.00                        vucomiss	xmm16, xmm10
 1      1     0.50                        jne	.LBB6_147
 1      1     0.50                        jnp	.LBB6_128
 2      7     1.00    *                   vmovss	xmm20, dword ptr [rdi + 24]
 1      4     0.50                        vsubss	xmm20, xmm20, xmm5
 1      11    3.00                        vdivss	xmm20, xmm20, xmm16
 1      4     0.50                        vaddss	xmm20, xmm20, xmm12
 2      6     1.00                        vcvttss2usi	r9d, xmm20
 1      1     0.25                        cmp	r10d, r9d
 1      1     0.25                        mov	r8d, 0
 2      2     1.00                        cmova	r8d, r9d
 1      1     0.50                        cmovae	r10d, r9d
 1      4     0.50                        vmulss	xmm20, xmm18, xmm7
 1      2     1.00                        vucomiss	xmm20, xmm10
 1      1     0.50                        jne	.LBB6_130
 1      1     0.50                        jnp	.LBB6_131
 2      7     1.00    *                   vmovss	xmm21, dword ptr [rdi + 28]
 1      4     0.50                        vsubss	xmm21, xmm21, xmm1
 1      11    3.00                        vdivss	xmm21, xmm21, xmm20
 1      4     0.50                        vaddss	xmm21, xmm21, xmm12
 2      6     1.00                        vcvttss2usi	r9d, xmm21
 1      1     0.25                        cmp	r10d, r9d
 1      1     0.25                        mov	edx, 0
 2      2     1.00                        cmova	edx, r9d
 1      1     0.50                        cmovae	r10d, r9d
 1      1     0.50           *            mov	dword ptr [rsp + 56], ebp
 1      1     0.50           *            mov	dword ptr [rsp + 64], r11d
 1      4     0.50                        vmulss	xmm13, xmm19, xmm10
 1      3     1.00                        vbroadcastss	xmm15, xmm19
 1      4     0.50                        vmulps	xmm19, xmm15, xmm8
 1      1     0.33                        vblendps	xmm13, xmm13, xmm15, 2
 1      1     1.00                        vmovlhps	xmm19, xmm13, xmm19
 1      4     0.50                        vaddps	xmm5, xmm5, xmm19
 1      4     0.50                        vmulss	xmm13, xmm18, xmm10
 1      3     1.00                        vbroadcastss	xmm15, xmm18
 1      4     0.50                        vmulps	xmm18, xmm15, xmm8
 1      1     0.33                        vblendps	xmm13, xmm13, xmm15, 2
 1      1     1.00                        vmovlhps	xmm18, xmm13, xmm18
 1      4     0.50                        vaddps	xmm15, xmm1, xmm18
 2      5     1.00                        vcvtusi2ss	xmm18, xmm23, r10d
 1      4     0.50                        vmulss	xmm1, xmm17, xmm18
 1      4     0.50                        vaddss	xmm1, xmm0, xmm1
 1      1     0.25                        mov	r9d, r10d
 1      1     0.25                        test	r10d, r10d
 1      1     0.50                        je	.LBB6_134
 1      1     0.50                        vbroadcastss	xmm3, xmm3
 1      3     1.00                        vbroadcastss	xmm16, xmm16
 1      1     0.50                        vbroadcastss	xmm4, xmm4
 1      3     1.00                        vbroadcastss	xmm17, xmm20
 1      4     0.50                        vsubss	xmm19, xmm1, xmm0
 1      11    3.00                        vdivss	xmm18, xmm19, xmm18
 1      4     0.50                        vmulss	xmm13, xmm10, xmm2
 1      1     0.50                        vbroadcastss	xmm2, xmm2
 2      10    0.50    *                   vmulps	xmm19, xmm2, xmmword ptr [rip + .LCPI6_6]
 1      1     0.33                        vblendps	xmm2, xmm13, xmm2, 2
 1      1     1.00                        vmovlhps	xmm2, xmm2, xmm19
 1      1     0.25                        mov	r10, r9
 1      1     0.50                        shl	r10, 4
 1      0     0.17                        xor	r11d, r11d
 1      0     0.17                        xor	r14d, r14d
 3      6     2.00                        vcvtusi2ss	xmm19, xmm23, r14
 1      4     0.50                        vmulss	xmm19, xmm18, xmm19
 1      4     0.50                        vaddss	xmm19, xmm0, xmm19
 1      3     1.00                        vbroadcastss	xmm19, xmm19
 1      4     0.50                        vaddps	xmm19, xmm2, xmm19
 1      4     0.50                        vcvttps2dq	xmm20, xmm19
 1      5     0.50    *                   mov	r15, qword ptr [r13 + 16]
 1      2     1.00                        vmovd	ebp, xmm20
 1      1     0.25                        movsxd	rbp, ebp
 1      5     0.50    *                   movsx	ecx, word ptr [r15 + 2*rbp]
 2      5     1.00                        vcvtsi2ss	xmm21, xmm23, ecx
 1      4     0.50                        vcvtdq2ps	xmm20, xmm20
 1      4     0.50                        vsubps	xmm19, xmm19, xmm20
 1      5     0.50    *                   movsx	ecx, word ptr [r15 + 2*rbp + 2]
 1      3     1.00                        vbroadcastss	xmm20, xmm21
 2      5     1.00                        vcvtsi2ss	xmm21, xmm23, ecx
 1      3     1.00                        vbroadcastss	xmm21, xmm21
 1      4     0.50                        vsubps	xmm22, xmm14, xmm19
 1      4     0.50                        vmulps	xmm20, xmm20, xmm22
 1      4     0.50                        vmulps	xmm19, xmm21, xmm19
 1      4     0.50                        vaddps	xmm19, xmm19, xmm20
 1      4     0.50                        vmulps	xmm20, xmm3, xmm5
 1      4     0.50                        vmulps	xmm20, xmm20, xmm19
 2      10    0.50    *                   vaddps	xmm20, xmm20, xmmword ptr [r12 + r11]
 1      4     0.50                        vmulps	xmm21, xmm4, xmm15
 1      4     0.50                        vmulps	xmm19, xmm21, xmm19
 2      10    0.50    *                   vaddps	xmm19, xmm19, xmmword ptr [rbx + r11]
 2      1     0.50           *            vmovaps	xmmword ptr [r12 + r11], xmm20
 1      4     0.50                        vaddps	xmm5, xmm16, xmm5
 2      1     0.50           *            vmovaps	xmmword ptr [rbx + r11], xmm19
 1      4     0.50                        vaddps	xmm15, xmm17, xmm15
 1      1     0.25                        add	r14, 1
 1      1     0.25                        add	r11, 16
 1      1     0.25                        cmp	r10, r11
 1      1     0.50                        jne	.LBB6_133
 1      1     0.33                        vblendps	xmm0, xmm5, xmm15, 2
 2      1     0.50           *            vmovlps	qword ptr [rdi + 8], xmm0
 1      1     0.25                        cmp	r8d, r9d
 1      1     0.50                        je	.LBB6_148
 1      1     0.25                        cmp	edx, r9d
 1      5     0.50    *                   mov	r14, qword ptr [rsp + 232]
 1      1     0.25                        mov	r15d, 1
 1      1     0.50                        je	.LBB6_136
 2      1     0.50           *            vmovss	dword ptr [rdi + 36], xmm1
 1      1     0.25                        cmp	r9d, eax
 1      1     0.50                        je	.LBB6_140
 1      1     0.50                        jmp	.LBB6_138
 1      5     0.50    *                   vmovss	xmm0, dword ptr [rdi + 24]
 2      1     0.50           *            vmovss	dword ptr [rdi + 8], xmm0
 1      1     0.50           *            mov	dword ptr [rdi + 16], 0
 1      1     0.25                        cmp	edx, r9d
 1      5     0.50    *                   mov	r14, qword ptr [rsp + 232]
 1      1     0.25                        mov	r15d, 1
 1      1     0.50                        jne	.LBB6_137
 1      5     0.50    *                   vmovss	xmm0, dword ptr [rdi + 28]
 2      1     0.50           *            vmovss	dword ptr [rdi + 12], xmm0
 1      1     0.50           *            mov	dword ptr [rdi + 20], 0
 2      1     0.50           *            vmovss	dword ptr [rdi + 36], xmm1
 1      1     0.25                        cmp	r9d, eax
 1      1     0.50                        jne	.LBB6_138
 2      6     0.50    *                   cmp	byte ptr [rsp + 56], 0
 1      1     0.50                        jne	.LBB6_143
 1      5     0.50    *                   mov	eax, dword ptr [rsp + 64]
 1      1     0.50           *            mov	dword ptr [rdi + 40], eax
 2      9     1.00    *                   vcvtusi2ss	xmm0, xmm23, dword ptr [r13 + 32]
 1      4     0.50                        vsubss	xmm0, xmm1, xmm0
 2      1     0.50           *            vmovss	dword ptr [rdi + 36], xmm0
 1      2     1.00                        vucomiss	xmm10, xmm0
 1      1     0.50                        jbe	.LBB6_138
 1      1     0.50           *            mov	dword ptr [rdi + 36], 0
 1      5     0.50    *                   movzx	eax, byte ptr [rsp + 43]
 3      7     0.50    *      *            sub	dword ptr [rsp + 112], r9d
 1      1     0.50                        je	.LBB6_37
 1      1     0.25                        test	al, 1
 1      1     0.50                        je	.LBB6_17
 1      1     0.50                        jmp	.LBB6_37
 1      0     0.17                        xor	r8d, r8d
 1      4     0.50                        vmulss	xmm20, xmm18, xmm7
 1      2     1.00                        vucomiss	xmm20, xmm10
 1      1     0.50                        jne	.LBB6_130
 1      1     0.50                        jp	.LBB6_130
 1      1     0.50                        jmp	.LBB6_131
 3      3     1.00    *      *      U     mfence
 1      1     0.50           *            mov	dword ptr [rsi + 332], 0
 1      5     0.50    *                   mov	eax, dword ptr [rdi + 40]
 1      1     0.25                        test	rax, rax
 1      1     0.50                        je	.LBB6_65
 1      5     0.50    *                   mov	r13, qword ptr [rsi + 128]
 1      3     1.00                        imul	r9, rax, 56
 1      0     0.17                        xor	eax, eax
 6      8     1.00    *      *            lock		cmpxchg	dword ptr [r13 + r9], r15d
 1      1     0.50                        jne	.LBB6_65
 1      5     0.50    *                   mov	rax, qword ptr [rsi]
 2      6     0.50    *                   cmp	byte ptr [rax + 80], 1
 1      1     0.50                        jne	.LBB6_42
 2      6     0.50    *                   cmp	byte ptr [rax + 136], 1
 1      1     0.50                        jne	.LBB6_44
 2      6     0.50    *                   cmp	byte ptr [rax + 192], 1
 1      1     0.50                        jne	.LBB6_46
 2      6     0.50    *                   cmp	byte ptr [rax + 248], 0
 1      1     0.50                        je	.LBB6_48
 1      1     0.25                        add	r13, r9
 1      1     0.50           *            mov	dword ptr [r13], 0
 1      1     0.50                        jmp	.LBB6_65
 1      1     0.25                        test	al, 1
 1      1     0.50                        jne	.LBB6_144
 1      1     0.50                        jmp	.LBB6_38
 1      1     0.50           *            mov	byte ptr [rsp + 43], 1
 1      1     0.50                        jmp	.LBB6_144
 1      1     0.50                        lea	rcx, [rax + 80]
 1      0     0.17                        xor	edx, edx
 1      1     0.50                        jmp	.LBB6_49
 1      1     0.50                        lea	rcx, [rax + 136]
 1      1     0.25                        mov	edx, 1
 1      1     0.50                        jmp	.LBB6_49
 1      1     0.50                        lea	rcx, [rax + 192]
 1      1     0.25                        mov	edx, 2
 1      1     0.50                        jmp	.LBB6_49
 1      1     0.50                        lea	rcx, [rax + 248]
 1      1     0.25                        mov	edx, 3
 1      3     1.00                        imul	rdx, rdx, 56
 1      1     0.50                        lea	r8, [rax + rdx]
 1      1     0.25                        add	r8, 32
 1      1     0.50           *            mov	byte ptr [rcx], 1
 1      5     0.50    *                   mov	rcx, qword ptr [rax + rdx + 48]
 3      7     0.50    *      *            add	dword ptr [rax + rdx + 56], 1
 1      1     0.50           *            mov	qword ptr [rsp + 144], r8
 1      1     0.50           *            mov	qword ptr [rax + rdx + 64], r8
 1      1     0.50           *            mov	qword ptr [rax + rdx + 72], rcx
 1      5     0.50    *                   mov	ebp, dword ptr [r13 + r9 + 32]
 1      1     0.25                        add	ebp, ebp
 1      5     0.50    *                   mov	eax, dword ptr [r13 + r9 + 36]
 1      3     1.00                        imul	eax, ebp
 1      1     0.50           *            mov	qword ptr [rsp + 152], rax
 1      1     0.50                        lea	edx, [rax + 64]
 1      5     0.50    *                   mov	r8d, dword ptr [rdi + 40]
 1      1     0.25                        mov	rcx, rsi
 1      1     0.50           *            mov	qword ptr [rsp + 88], r9
 4      3     0.50                        call	handmade_asset.AcquireAssetMemory
 1      5     0.50    *                   mov	r10, qword ptr [rsp + 88]
 1      1     0.50           *            mov	qword ptr [r13 + r10 + 8], rax
 1      5     0.50    *                   mov	ecx, dword ptr [r13 + r10 + 32]
 1      1     0.50           *            mov	dword ptr [rax + 32], ecx
 1      5     0.50    *                   mov	edx, dword ptr [r13 + r10 + 36]
 1      1     0.50           *            mov	dword ptr [rax + 36], edx
 1      5     0.50    *                   mov	r11, qword ptr [r13 + r10 + 8]
 1      1     0.25                        add	r11, 64
 1      1     0.25                        test	rdx, rdx
 1      1     0.50                        je	.LBB6_64
 1      1     0.25                        mov	r8d, ebp
 1      1     0.25                        cmp	edx, 8
 1      1     0.50                        jae	.LBB6_52
 1      0     0.17                        xor	r9d, r9d
 1      1     0.25                        mov	rcx, r11
 1      1     0.50                        jmp	.LBB6_61
 1      1     0.50                        lea	r9, [r8 + r8]
 1      1     0.50                        lea	rcx, [rdx - 8]
 1      1     0.25                        cmp	rcx, 8
 1      1     0.50           *            mov	qword ptr [rsp + 136], r11
 1      1     0.50                        jae	.LBB6_55
 1      0     0.17                        xor	r15d, r15d
 1      1     0.50                        jmp	.LBB6_58
 1      1     0.50           *            mov	qword ptr [rsp + 128], r13
 1      1     0.50           *            mov	qword ptr [rsp + 80], rcx
 1      1     0.25                        mov	r10, rcx
 1      1     0.50                        shr	r10, 3
 1      1     0.25                        add	r10, 1
 1      1     0.25                        and	r10, -2
 1      1     0.25                        mov	rcx, r8
 1      1     0.50                        shl	rcx, 5
 1      1     0.25                        sub	rcx, r9
 1      1     0.50           *            mov	qword ptr [rsp + 112], rcx
 1      1     0.50                        lea	rcx, [r8 + 8*r8]
 1      1     0.50                        lea	rcx, [rcx + 2*rcx]
 1      1     0.25                        add	rcx, r8
 1      1     0.50           *            mov	qword ptr [rsp + 64], rcx
 1      1     0.50                        lea	rcx, [r8 + 4*r8]
 1      1     0.50                        lea	r14, [rcx + 4*rcx]
 1      1     0.25                        add	r14, r8
 1      1     0.50           *            mov	qword ptr [rsp + 56], r14
 1      1     0.50                        lea	r14, [8*r8]
 1      1     0.50           *            mov	qword ptr [rsp + 96], r14
 1      1     0.50                        lea	r14, [r14 + 2*r14]
 1      1     0.50           *            mov	qword ptr [rsp + 48], r14
 1      1     0.50                        lea	rcx, [r9 + 4*rcx]
 1      1     0.50           *            mov	qword ptr [rsp + 72], rcx
 1      1     0.50                        lea	rcx, [4*r8]
 1      1     0.50                        lea	r14, [rcx + 4*rcx]
 1      1     0.50           *            mov	qword ptr [rsp + 200], r14
 1      1     0.50                        lea	r14, [r9 + 8*r9]
 1      1     0.50           *            mov	qword ptr [rsp + 192], r14
 1      1     0.25                        mov	rbp, r8
 1      1     0.50                        shl	rbp, 4
 1      1     0.25                        mov	r14, rbp
 1      1     0.25                        sub	r14, r9
 1      1     0.50           *            mov	qword ptr [rsp + 184], r14
 1      1     0.50           *            mov	qword ptr [rsp + 208], rcx
 1      1     0.50                        lea	rcx, [rcx + 2*rcx]
 1      1     0.50           *            mov	qword ptr [rsp + 176], rcx
 1      1     0.50                        lea	rcx, [r9 + 4*r9]
 1      1     0.50           *            mov	qword ptr [rsp + 168], rcx
 1      1     0.50                        lea	rcx, [r9 + 2*r9]
 1      1     0.50           *            mov	qword ptr [rsp + 160], rcx
 1      0     0.17                        xor	r15d, r15d
 1      1     0.50           *            mov	qword ptr [rax + 8*r15 + 16], r11
 1      1     0.50                        lea	r13, [r11 + r9]
 1      1     0.50           *            mov	qword ptr [rax + 8*r15 + 24], r13
 1      1     0.25                        add	r13, r9
 1      5     0.50    *                   mov	rcx, qword ptr [rsp + 208]
 1      1     0.25                        add	rcx, r11
 1      1     0.50           *            mov	qword ptr [rax + 8*r15 + 32], rcx
 1      5     0.50    *                   mov	rcx, qword ptr [rsp + 160]
 1      1     0.50                        lea	rcx, [r11 + rcx]
 1      1     0.50           *            mov	qword ptr [rax + 8*r15 + 40], rcx
 1      1     0.50                        lea	rcx, [r9 + r9]
 1      5     0.50    *                   mov	r14, qword ptr [rsp + 96]
 1      1     0.50                        lea	r14, [r11 + r14]
 1      1     0.50           *            mov	qword ptr [rax + 8*r15 + 48], r14
 1      5     0.50    *                   mov	r14, qword ptr [rsp + 168]
 1      1     0.50                        lea	r14, [r11 + r14]
 1      1     0.50           *            mov	qword ptr [rax + 8*r15 + 56], r14
 1      5     0.50    *                   mov	r14, qword ptr [rsp + 176]
 1      1     0.50                        lea	r14, [r11 + r14]
 1      1     0.50           *            mov	qword ptr [rax + 8*r15 + 64], r14
 1      5     0.50    *                   mov	r14, qword ptr [rsp + 184]
 1      1     0.50                        lea	r14, [r11 + r14]
 1      1     0.50           *            mov	qword ptr [rax + 8*r15 + 72], r14
 1      1     0.50                        lea	r14, [r11 + rbp]
 1      1     0.50           *            mov	qword ptr [rax + 8*r15 + 80], r14
 1      5     0.50    *                   mov	r14, qword ptr [rsp + 192]
 1      1     0.50                        lea	r14, [r11 + r14]
 1      1     0.50           *            mov	qword ptr [rax + 8*r15 + 88], r14
 1      5     0.50    *                   mov	r14, qword ptr [rsp + 200]
 1      1     0.50                        lea	r14, [r11 + r14]
 1      1     0.50           *            mov	qword ptr [rax + 8*r15 + 96], r14
 1      5     0.50    *                   mov	r14, qword ptr [rsp + 72]
 1      1     0.25                        add	r14, r11
 1      1     0.50           *            mov	qword ptr [rax + 8*r15 + 104], r14
 1      5     0.50    *                   mov	r14, qword ptr [rsp + 48]
 1      1     0.25                        add	r14, r11
 1      1     0.50           *            mov	qword ptr [rax + 8*r15 + 112], r14
 1      5     0.50    *                   mov	r14, qword ptr [rsp + 56]
 1      1     0.25                        add	r14, r11
 1      1     0.50           *            mov	qword ptr [rax + 8*r15 + 120], r14
 1      1     0.50                        lea	r14, [rcx + r9]
 1      1     0.25                        add	r13, r14
 1      1     0.25                        add	r14, r9
 1      1     0.25                        add	r13, r14
 1      1     0.25                        add	r14, r9
 1      1     0.25                        add	r14, r13
 1      5     0.50    *                   mov	r13, qword ptr [rsp + 64]
 1      1     0.25                        add	r13, r11
 1      1     0.50           *            mov	qword ptr [rax + 8*r15 + 128], r13
 2      6     0.50    *                   add	r11, qword ptr [rsp + 112]
 1      1     0.50           *            mov	qword ptr [rax + 8*r15 + 136], r11
 1      1     0.25                        mov	r11, r14
 1      1     0.25                        add	r11, rcx
 1      1     0.25                        add	r15, 16
 1      1     0.25                        add	r10, -2
 1      1     0.50                        jne	.LBB6_56
 1      1     0.25                        mov	r10, r11
 1      1     0.25                        sub	r10, rbp
 1      5     0.50    *                   mov	r14, qword ptr [rsp + 232]
 1      5     0.50    *                   mov	r13, qword ptr [rsp + 128]
 1      5     0.50    *                   mov	rcx, qword ptr [rsp + 80]
 1      1     0.25                        test	cl, 8
 1      1     0.50                        jne	.LBB6_60
 1      1     0.50           *            mov	qword ptr [rax + 8*r15 + 16], r11
 1      1     0.50                        lea	rcx, [r11 + r9]
 1      1     0.50           *            mov	qword ptr [rax + 8*r15 + 24], rcx
 1      1     0.25                        add	rcx, r9
 1      1     0.50           *            mov	qword ptr [rax + 8*r15 + 32], rcx
 1      1     0.25                        add	rcx, r9
 1      1     0.50           *            mov	qword ptr [rax + 8*r15 + 40], rcx
 1      1     0.25                        add	rcx, r9
 1      1     0.50           *            mov	qword ptr [rax + 8*r15 + 48], rcx
 1      1     0.25                        add	rcx, r9
 1      1     0.50           *            mov	qword ptr [rax + 8*r15 + 56], rcx
 1      1     0.25                        add	rcx, r9
 1      1     0.50           *            mov	qword ptr [rax + 8*r15 + 64], rcx
 1      1     0.25                        add	rcx, r9
 1      1     0.50           *            mov	qword ptr [rax + 8*r15 + 72], rcx
 1      1     0.25                        mov	r10, r11
 1      1     0.25                        mov	r9d, edx
 1      1     0.25                        and	r9d, -8
 1      1     0.25                        mov	rcx, r8
 1      1     0.50                        shl	rcx, 4
 1      1     0.25                        add	rcx, r10
 1      1     0.25                        mov	r15d, 1
 1      5     0.50    *                   mov	r10, qword ptr [rsp + 88]
 1      5     0.50    *                   mov	r11, qword ptr [rsp + 136]
 1      1     0.25                        and	edx, 7
 1      1     0.50                        je	.LBB6_64
 1      1     0.50                        lea	rax, [rax + 8*r9]
 1      1     0.25                        add	rax, 16
 1      1     0.25                        add	r8, r8
 1      0     0.17                        xor	r9d, r9d
 1      1     0.50           *            mov	qword ptr [rax + 8*r9], rcx
 1      1     0.25                        add	r9, 1
 1      1     0.25                        add	rcx, r8
 1      1     0.25                        cmp	rdx, r9
 1      1     0.50                        jne	.LBB6_63
 1      5     0.50    *                   mov	r8, qword ptr [rsp + 144]
 1      5     0.50    *                   mov	rcx, qword ptr [r8 + 16]
 1      5     0.50    *                   mov	rax, qword ptr [r8 + 8]
 1      1     0.25                        add	rax, rcx
 1      1     0.25                        mov	edx, eax
 1      1     0.25                        and	edx, 7
 1      1     0.25                        mov	r9d, 8
 1      1     0.25                        sub	r9, rdx
 1      1     0.25                        test	rdx, rdx
 1      1     0.50                        cmove	r9, rdx
 1      1     0.50                        lea	rdx, [r13 + r10 + 16]
 1      1     0.50                        lea	rcx, [rcx + r9 + 56]
 1      1     0.50           *            mov	qword ptr [r8 + 16], rcx
 1      1     0.50           *            mov	qword ptr [r9 + rax], r8
 1      5     0.50    *                   mov	ecx, dword ptr [rdi + 40]
 1      3     1.00                        imul	rcx, rcx, 56
 2      6     0.50    *                   add	rcx, qword ptr [rsi + 128]
 1      1     0.50                        lea	r8, [r9 + rax]
 1      1     0.50           *            mov	qword ptr [r9 + rax + 8], rcx
 1      5     0.50    *                   mov	ecx, dword ptr [r13 + r10 + 52]
 1      3     1.00                        imul	rcx, rcx, 88
 2      6     0.50    *                   add	rcx, qword ptr [rsi + 104]
 1      1     0.50           *            mov	qword ptr [r9 + rax + 16], rcx
 1      5     0.50    *                   mov	rcx, qword ptr [rdx]
 1      1     0.50           *            mov	qword ptr [r9 + rax + 24], rcx
 1      5     0.50    *                   mov	ecx, dword ptr [rsp + 152]
 1      1     0.50           *            mov	qword ptr [r9 + rax + 32], rcx
 1      1     0.50           *            mov	qword ptr [r9 + rax + 40], r11
 1      1     0.50           *            mov	dword ptr [r9 + rax + 48], 2
 1      1     0.50           *            mov	byte ptr [r9 + rax + 52], 0
 1      5     0.50    *                   mov	rax, qword ptr [rsi]
 1      5     0.50    *                   mov	rcx, qword ptr [rax + 288]
 1      1     0.50                        lea	rdx, [rip + handmade_asset.LoadAssetWork]
 5      7     1.00    *                   call	qword ptr [rip + handmade_data.platformAPI]
 2      6     0.50    *                   cmp	byte ptr [rsp + 43], 0
 1      1     0.50                        je	.LBB6_38
 1      5     0.50    *                   mov	rax, qword ptr [rdi]
 1      5     0.50    *                   mov	rdx, qword ptr [rsp + 216]
 1      1     0.50           *            mov	qword ptr [rdx], rax
 1      5     0.50    *                   mov	rcx, qword ptr [rsp + 104]
 1      5     0.50    *                   mov	rax, qword ptr [rcx + 104]
 1      1     0.50           *            mov	qword ptr [rdi], rax
 1      1     0.50           *            mov	qword ptr [rcx + 104], rdi
 1      1     0.25                        mov	rdi, rdx
 1      1     0.50           *            mov	qword ptr [rsp + 216], rdi
 1      5     0.50    *                   mov	rdi, qword ptr [rdi]
 1      1     0.25                        test	rdi, rdi
 1      1     0.50                        jne	.LBB6_16
 1      1     0.50                        jmp	.LBB6_28
 1      1     0.50                        jmp	.LBB6_104
 1      1     0.50                        jmp	.LBB6_93
 1      5     0.50    *                   mov	rdi, qword ptr [rdi]
 1      1     0.25                        test	rdi, rdi
 1      1     0.50                        jne	.LBB6_26
 1      1     0.50           *            mov	byte ptr [rsp + 43], 0


```
</details>

<details><summary>Dynamic Dispatch Stall Cycles:</summary>

```
RAT     - Register unavailable:                      0
RCU     - Retire tokens unavailable:                 5569  (16.4%)
SCHEDQ  - Scheduler full:                            14538  (42.8%)
LQ      - Load queue full:                           0
SQ      - Store queue full:                          0
GROUP   - Static restrictions on the dispatch group: 0
USH     - Uncategorised Structural Hazard:           0


```
</details>

<details><summary>Dispatch Logic - number of cycles where we saw N micro opcodes dispatched:</summary>

```
[# dispatched], [# cycles]
 0,              10682  (31.4%)
 1,              3904  (11.5%)
 2,              2711  (8.0%)
 3,              1301  (3.8%)
 4,              1307  (3.8%)
 5,              2297  (6.8%)
 6,              11793  (34.7%)


```
</details>

<details><summary>Schedulers - number of cycles where we saw N micro opcodes issued:</summary>

```
[# issued], [# cycles]
 0,          8089  (23.8%)
 1,          5003  (14.7%)
 2,          4300  (12.6%)
 3,          3207  (9.4%)
 4,          3004  (8.8%)
 5,          3091  (9.1%)
 6,          3603  (10.6%)
 7,          1696  (5.0%)
 8,          1503  (4.4%)
 9,          499  (1.5%)

```
</details>

<details><summary>Scheduler's queue usage:</summary>

```
[1] Resource name.
[2] Average number of used buffer entries.
[3] Maximum number of used buffer entries.
[4] Total number of buffer entries.

 [1]            [2]        [3]        [4]
ICXPortAny       48         60         60


```
</details>

<details><summary>Retire Control Unit - number of cycles where we saw N instructions retired:</summary>

```
[# retired], [# cycles]
 0,           30168  (88.7%)
 1,           1512  (4.4%)
 2,           706  (2.1%)
 3,           201  (0.6%)
 4,           102  (0.3%)
 5,           101  (0.3%)
 6,           200  (0.6%)
 7,           200  (0.6%)
 10,          1  (0.0%)
 12,          100  (0.3%)
 13,          1  (0.0%)
 14,          100  (0.3%)
 17,          1  (0.0%)
 22,          1  (0.0%)
 23,          1  (0.0%)
 41,          100  (0.3%)
 43,          1  (0.0%)
 75,          100  (0.3%)
 94,          100  (0.3%)
 168,          99  (0.3%)
 197,          100  (0.3%)
 230,          100  (0.3%)

```
</details>

<details><summary>Total ROB Entries:                352</summary>

```
Max Used ROB Entries:             352  ( 100.0% )
Average Used ROB Entries per cy:  226  ( 64.2% )


```
</details>

<details><summary>Register File statistics:</summary>

```
Total number of mappings created:    71500
Max number of mappings used:         271


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
 -     15.00  155.98 143.99 100.00 100.00 97.00  134.02 130.01 99.00  98.00  97.00  

Resource pressure by instruction:
[0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   Instructions:
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     mov	rax, qword ptr [rsp + 104]
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	rdi, qword ptr [rax + 96]
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     test	rdi, rdi
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     je	.LBB6_28
 -      -      -     0.99   0.01   0.99    -      -     0.01    -      -      -     cmp	dword ptr [rsp + 44], 0
 -      -      -      -      -      -      -      -     1.00    -      -      -     je	.LBB6_26
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     vmovss	xmm1, dword ptr [rip + .LCPI6_0]
 -     3.00   1.00    -      -      -      -      -      -      -      -      -     vdivss	xmm6, xmm1, xmm0
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	rax, qword ptr [rsp + 104]
 -      -      -      -      -      -      -     1.00    -      -      -      -     add	rax, 96
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rsp + 216], rax
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     lea	rax, [rsi + 40]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rsp + 120], rax
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     lea	rax, [rsi + 8]
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rsp + 240], rax
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     mov	r15d, 1
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     vmovss	xmm7, dword ptr [rip + .LCPI6_1]
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     vmovddup	xmm8, qword ptr [rip + .LCPI6_2]
 -      -      -      -      -     1.00    -      -      -      -      -      -     vpbroadcastd	xmm9, dword ptr [rip + .LCPI6_3]
 -      -      -      -      -      -      -      -      -      -      -      -     vxorps	xmm10, xmm10, xmm10
 -      -      -      -     1.00    -      -      -      -      -      -      -     vpbroadcastd	xmm11, dword ptr [rip + .LCPI6_4]
 -      -      -      -      -     1.00    -      -      -      -      -      -     vmovss	xmm12, dword ptr [rip + .LCPI6_5]
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     vbroadcastss	xmm14, dword ptr [rip + .LCPI6_0]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rsp + 232], r14
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	byte ptr [rsp + 43], 0
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	rax, qword ptr [rsp + 224]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	dword ptr [rsp + 112], eax
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	edx, dword ptr [rdi + 40]
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     mov	rcx, qword ptr [rsi + 128]
 -      -      -      -      -      -      -      -      -      -      -      -     xor	eax, eax
 -      -     2.00    -     0.01   0.99    -     1.00    -      -     1.00   1.00   lock		cmpxchg	dword ptr [rsi + 332], r15d
 -      -     1.00    -      -      -      -      -      -      -      -      -     jne	.LBB6_18
 -      -      -     1.00    -      -      -      -      -      -      -      -     imul	rax, rdx, 56
 -      -      -      -      -     1.00    -     1.00    -      -      -      -     cmp	dword ptr [rcx + rax], 2
 -      -      -      -      -      -      -      -     1.00    -      -      -     jne	.LBB6_39
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	r13, qword ptr [rcx + rax + 8]
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	rdx, qword ptr [r13]
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	r8, qword ptr [r13 + 8]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [r8], rdx
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	r8, qword ptr [r13 + 8]
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rdx + 8], r8
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	rdx, qword ptr [rsp + 120]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [r13 + 8], rdx
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     mov	rdx, qword ptr [rdx]
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [r13], rdx
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rdx + 8], r13
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	rdx, qword ptr [r13 + 8]
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rdx], r13
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	rax, qword ptr [rcx + rax + 8]
 -      -      -      -      -     1.00    -     1.00    -      -      -      -     cmp	dword ptr [rax + 56], r14d
 -      -     1.00    -      -      -      -      -      -      -      -      -     jae	.LBB6_22
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	dword ptr [rax + 56], r14d
 -      -      -      -      -      -      -      -      -      -     2.00   1.00   mfence
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	dword ptr [rsi + 332], 0
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	eax, dword ptr [rdi + 40]
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	r8, qword ptr [rsi + 128]
 -      -      -     1.00    -      -      -      -      -      -      -      -     imul	rcx, rax, 56
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	r11d, dword ptr [r8 + rcx + 40]
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     mov	bpl, 1
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     test	r11d, r11d
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     je	.LBB6_127
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     cmp	r11d, 1
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     jne	.LBB6_66
 -      -     0.01    -      -      -      -     0.99    -      -      -      -     mov	r11d, eax
 -      -      -      -      -      -      -      -     1.00    -      -      -     test	eax, eax
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     jne	.LBB6_67
 -      -      -      -      -      -      -      -      -      -      -      -     xor	r11d, r11d
 -      -      -      -      -      -      -      -     1.00    -      -      -     jmp	.LBB6_127
 -      -     0.99    -      -      -      -     0.01    -      -      -      -     add	rax, 1
 -      -      -      -      -      -      -     0.99   0.01    -      -      -     mov	r11d, eax
 -      -      -     1.00    -      -      -      -      -      -      -      -     imul	r9, rax, 56
 -      -      -      -      -      -      -      -      -      -      -      -     xor	ebp, ebp
 -      -      -      -      -      -      -      -      -      -      -      -     xor	eax, eax
 -      -     1.01   0.01    -     1.00    -      -     1.98    -     1.00   1.00   lock		cmpxchg	dword ptr [r8 + r9], r15d
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     jne	.LBB6_127
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	rax, qword ptr [rsi]
 -      -     0.99    -      -     1.00    -     0.01    -      -      -      -     cmp	byte ptr [rax + 80], 1
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     jne	.LBB6_69
 -      -      -     0.01    -     1.00    -      -     0.99    -      -      -     cmp	byte ptr [rax + 136], 1
 -      -      -      -      -      -      -      -     1.00    -      -      -     jne	.LBB6_71
 -      -     0.01    -     1.00    -      -     0.99    -      -      -      -     cmp	byte ptr [rax + 192], 1
 -      -     1.00    -      -      -      -      -      -      -      -      -     jne	.LBB6_73
 -      -     0.99   0.01   1.00    -      -      -      -      -      -      -     cmp	byte ptr [rax + 248], 0
 -      -      -      -      -      -      -      -     1.00    -      -      -     je	.LBB6_75
 -      -      -      -      -      -      -     0.99   0.01    -      -      -     add	r8, r9
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	dword ptr [r8], 0
 -      -      -      -      -      -      -      -      -      -      -      -     xor	ebp, ebp
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     jmp	.LBB6_127
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     lea	rcx, [rax + 80]
 -      -      -      -      -      -      -      -      -      -      -      -     xor	edx, edx
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     jmp	.LBB6_76
 -      -      -      -      -      -      -     1.00    -      -      -      -     lea	rcx, [rax + 136]
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     mov	edx, 1
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     jmp	.LBB6_76
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     lea	rcx, [rax + 192]
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     mov	edx, 2
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     jmp	.LBB6_76
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	rcx, [rax + 248]
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     mov	edx, 3
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	dword ptr [rsp + 64], r11d
 -      -      -     1.00    -      -      -      -      -      -      -      -     imul	rdx, rdx, 56
 -      -      -      -      -      -      -     1.00    -      -      -      -     lea	r10, [rax + rdx]
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     add	r10, 32
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	byte ptr [rcx], 1
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	rcx, qword ptr [rax + rdx + 48]
 -      -     0.99   0.01    -     1.00    -      -      -      -     1.00   1.00   add	dword ptr [rax + rdx + 56], 1
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rsp + 264], r10
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rax + rdx + 64], r10
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rax + rdx + 72], rcx
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     lea	rax, [r8 + r9]
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     add	rax, 32
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rsp + 48], rax
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	edx, dword ptr [r8 + r9 + 32]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rsp + 56], r8
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rsp + 96], r9
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	ecx, dword ptr [r8 + r9 + 36]
 -      -      -      -      -      -      -      -      -      -      -      -     xor	eax, eax
 -      -     2.00   0.99    -     1.00   1.00   0.01    -     1.00    -      -     lock		cmpxchg	dword ptr [rsi + 332], r15d
 -      -     1.00    -      -      -      -      -      -      -      -      -     jne	.LBB6_77
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     add	edx, edx
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	dword ptr [rsp + 72], edx
 -      -      -     1.00    -      -      -      -      -      -      -      -     imul	ecx, edx
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     lea	r15d, [rcx + 79]
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     and	r15d, -16
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     mov	r14, qword ptr [rsi + 16]
 -      -      -     1.00   1.00    -      -      -      -      -      -      -     cmp	r14, qword ptr [rsp + 240]
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rsp + 272], rcx
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     jne	.LBB6_81
 -      -      -      -      -      -      -      -      -      -      -      -     xor	r14d, r14d
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     jmp	.LBB6_80
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	r14, qword ptr [r14 + 8]
 -      -     0.99    -     1.00    -      -     0.01    -      -      -      -     cmp	r14, qword ptr [rsp + 240]
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     je	.LBB6_79
 -      -      -      -     0.01   0.99    -     0.99   0.01    -      -      -     test	byte ptr [r14 + 16], 1
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     jne	.LBB6_82
 -      -     0.01    -     0.01   0.99    -     0.99    -      -      -      -     cmp	qword ptr [r14 + 24], r15
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     jb	.LBB6_82
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	rax, qword ptr [rsp + 56]
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	rcx, qword ptr [rsp + 96]
 -      -      -      -      -      -      -     0.99   0.01    -      -      -     add	rax, rcx
 -      -     0.99    -      -      -      -     0.01    -      -      -      -     add	rax, 8
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rsp + 80], rax
 -      -      -      -      -      -      -      -     1.00    -      -      -     jmp	.LBB6_91
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	rdx, qword ptr [r14 + 8]
 -      -      -      -      -      -      -     0.99   0.01    -      -      -     mov	rcx, rsi
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     mov	r8, r14
 -      -      -     1.00    -      -     1.00    -     1.00   1.00    -      -     call	handmade_asset.MergeIfPossible
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	dword ptr [rbp], 0
 -      -      -     1.00    -      -      -      -      -      -      -      -     test	r14, r14
 -      -      -      -      -      -      -      -     1.00    -      -      -     je	.LBB6_92
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	rcx, qword ptr [r14 + 24]
 -      -      -     1.00    -      -      -      -      -      -      -      -     sub	rcx, r15
 -      -     1.00    -      -      -      -      -      -      -      -      -     jae	.LBB6_84
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	rdx, qword ptr [rsi + 48]
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	r14, qword ptr [rsp + 120]
 -      -     0.99    -      -      -      -     0.01    -      -      -      -     cmp	rdx, r14
 -      -     1.00    -      -      -      -      -      -      -      -      -     je	.LBB6_104
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	r8, qword ptr [rsi + 128]
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     mov	rax, rdx
 -      -      -      -      -      -      -      -     1.00    -      -      -     jmp	.LBB6_107
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	rax, qword ptr [rax + 8]
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     cmp	rax, r14
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     je	.LBB6_106
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	ecx, dword ptr [rax + 48]
 -      -      -     1.00    -      -      -      -      -      -      -      -     imul	r10, rcx, 56
 -      -      -      -     0.01   0.99    -     1.00    -      -      -      -     cmp	dword ptr [r8 + r10], 2
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     jb	.LBB6_112
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	rbp, [r8 + r10]
 -      -      -      -      -      -      -     1.00    -      -      -      -     lea	rcx, [r8 + r10]
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     add	rcx, 8
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     mov	r9d, dword ptr [rsi + 336]
 -      -      -      -      -      -      -     1.00    -      -      -      -     test	r9, r9
 -      -      -      -      -      -      -      -     1.00    -      -      -     je	.LBB6_89
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     mov	r10, qword ptr [r8 + r10 + 8]
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	r10d, dword ptr [r10 + 56]
 -      -      -      -      -      -      -      -      -      -      -      -     xor	r11d, r11d
 -      -     0.99    -      -     1.00    -      -     0.01    -      -      -     cmp	dword ptr [rsi + 4*r11 + 340], r10d
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     je	.LBB6_112
 -      -      -      -      -      -      -     1.00    -      -      -      -     add	r11, 1
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     cmp	r9, r11
 -      -     1.00    -      -      -      -      -      -      -      -      -     jne	.LBB6_110
 -      -      -      -      -      -      -      -     1.00    -      -      -     jmp	.LBB6_89
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	rdx, qword ptr [rsi + 48]
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     mov	r14, qword ptr [rsp + 120]
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     cmp	rdx, r14
 -      -      -      -      -      -      -      -     1.00    -      -      -     je	.LBB6_93
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	r8, qword ptr [rsi + 128]
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     mov	rax, rdx
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     jmp	.LBB6_96
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	rax, qword ptr [rax + 8]
 -      -      -      -      -      -      -     0.01   0.99    -      -      -     cmp	rax, r14
 -      -      -      -      -      -      -      -     1.00    -      -      -     je	.LBB6_95
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	ecx, dword ptr [rax + 48]
 -      -      -     1.00    -      -      -      -      -      -      -      -     imul	r10, rcx, 56
 -      -      -      -     1.00    -      -     0.99   0.01    -      -      -     cmp	dword ptr [r8 + r10], 2
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     jb	.LBB6_101
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     lea	rbp, [r8 + r10]
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     lea	rcx, [r8 + r10]
 -      -     0.99    -      -      -      -     0.01    -      -      -      -     add	rcx, 8
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	r9d, dword ptr [rsi + 336]
 -      -      -      -      -      -      -     0.01   0.99    -      -      -     test	r9, r9
 -      -      -      -      -      -      -      -     1.00    -      -      -     je	.LBB6_89
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	r10, qword ptr [r8 + r10 + 8]
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	r10d, dword ptr [r10 + 56]
 -      -      -      -      -      -      -      -      -      -      -      -     xor	r11d, r11d
 -      -      -     0.01   1.00    -      -     0.99    -      -      -      -     cmp	dword ptr [rsi + 4*r11 + 340], r10d
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     je	.LBB6_101
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     add	r11, 1
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     cmp	r9, r11
 -      -     1.00    -      -      -      -      -      -      -      -      -     jne	.LBB6_99
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     mov	rdx, qword ptr [rax]
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	r8, qword ptr [rax + 8]
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [r8], rdx
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     mov	rax, qword ptr [rax + 8]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rdx + 8], rax
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	rax, qword ptr [rcx]
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     lea	r14, [rax - 32]
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rax - 16], 0
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	rdx, qword ptr [rax - 32]
 -      -      -      -      -      -      -     1.00    -      -      -      -     mov	rcx, rsi
 -      -     0.01    -      -      -      -     0.99    -      -      -      -     mov	r8, r14
 -      -     0.99   1.00    -      -     1.00    -     0.01   1.00    -      -     call	handmade_asset.MergeIfPossible
 -      -      -     0.01    -      -      -      -     0.99    -      -      -     test	al, 1
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     je	.LBB6_90
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	r14, qword ptr [r14]
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     jmp	.LBB6_90
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [r14 + 16], 1
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     lea	rax, [r14 + 32]
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     cmp	rcx, 4097
 -      -     1.00    -      -      -      -      -      -      -      -      -     jb	.LBB6_86
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [r14 + 24], r15
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	rdx, [rax + r15]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [r14 + r15 + 48], 0
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     add	rcx, -32
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [r14 + r15 + 56], rcx
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [r14 + r15 + 32], r14
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	rcx, qword ptr [r14 + 8]
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [r14 + r15 + 40], rcx
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [r14 + 8], rdx
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rcx], rdx
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	ecx, dword ptr [rsp + 64]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	dword ptr [r14 + 80], ecx
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	dword ptr [r14 + 84], r15d
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	rcx, qword ptr [rsp + 120]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [r14 + 40], rcx
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	rcx, qword ptr [rsi + 40]
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [r14 + 32], rcx
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rcx + 8], rax
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	rcx, qword ptr [r14 + 40]
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rcx], rax
 -      -      -      -      -      -     1.00    -      -     2.00    -      -     mfence
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	dword ptr [rsi + 332], 0
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	r11, qword ptr [rsp + 80]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [r11], rax
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     mov	rcx, qword ptr [rsp + 48]
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	eax, dword ptr [rcx]
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	dword ptr [r14 + 64], eax
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     mov	ecx, dword ptr [rcx + 4]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	dword ptr [r14 + 68], ecx
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	rbp, qword ptr [r11]
 -      -      -      -      -      -      -      -     1.00    -      -      -     add	rbp, 64
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     test	rcx, rcx
 -      -     1.00    -      -      -      -      -      -      -      -      -     je	.LBB6_126
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	edx, dword ptr [rsp + 72]
 -      -      -      -      -      -      -     0.99   0.01    -      -      -     cmp	ecx, 8
 -      -      -      -      -      -      -      -     1.00    -      -      -     jae	.LBB6_114
 -      -      -      -      -      -      -      -      -      -      -      -     xor	r8d, r8d
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     mov	rax, rbp
 -      -     0.99    -      -      -      -     0.01    -      -      -      -     and	ecx, 7
 -      -     1.00    -      -      -      -      -      -      -      -      -     jne	.LBB6_124
 -      -     1.00    -      -      -      -      -      -      -      -      -     jmp	.LBB6_126
 -      -      -      -      -      -      -     1.00    -      -      -      -     lea	r8, [rdx + rdx]
 -      -      -      -      -      -      -     1.00    -      -      -      -     lea	rax, [rcx - 8]
 -      -      -     0.99    -      -      -      -     0.01    -      -      -     cmp	rax, 8
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     jae	.LBB6_117
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     mov	r10, rbp
 -      -      -      -      -      -      -      -      -      -      -      -     xor	r11d, r11d
 -      -      -      -      -      -      -      -     1.00    -      -      -     jmp	.LBB6_120
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rsp + 248], rax
 -      -      -      -      -      -      -     1.00    -      -      -      -     mov	r15, rax
 -      -      -      -      -      -      -      -     1.00    -      -      -     shr	r15, 3
 -      -     1.00    -      -      -      -      -      -      -      -      -     add	r15, 1
 -      -     1.00    -      -      -      -      -      -      -      -      -     and	r15, -2
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     mov	rax, rdx
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     shl	rax, 5
 -      -      -      -      -      -      -     0.99   0.01    -      -      -     sub	rax, r8
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rsp + 72], rax
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     lea	rax, [rdx + 8*rdx]
 -      -      -      -      -      -      -     1.00    -      -      -      -     lea	rax, [rax + 2*rax]
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     add	rax, rdx
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rsp + 208], rax
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	rax, [rdx + 4*rdx]
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	r9, [rax + 4*rax]
 -      -      -      -      -      -      -     1.00    -      -      -      -     add	r9, rdx
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rsp + 200], r9
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	r9, [8*rdx]
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rsp + 192], r9
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     lea	r9, [r9 + 2*r9]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rsp + 184], r9
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     lea	rax, [r8 + 4*rax]
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rsp + 176], rax
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	rax, [4*rdx]
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     lea	r9, [rax + 4*rax]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rsp + 160], r9
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	r9, [r8 + 8*r8]
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rsp + 88], r9
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     mov	r10, rdx
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     shl	r10, 4
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     mov	r9, r10
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rsp + 48], r10
 -      -     1.00    -      -      -      -      -      -      -      -      -     sub	r10, r8
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rsp + 152], r10
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rsp + 168], rax
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     lea	rax, [rax + 2*rax]
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rsp + 144], rax
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     lea	rax, [r8 + 4*r8]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rsp + 136], rax
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     lea	rax, [r8 + 2*r8]
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rsp + 128], rax
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rsp + 256], rbp
 -      -     0.99    -      -      -      -     0.01    -      -      -      -     mov	r10, rbp
 -      -      -      -      -      -      -      -      -      -      -      -     xor	r11d, r11d
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [r14 + 8*r11 + 48], r10
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     lea	rax, [r10 + r8]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [r14 + 8*r11 + 56], rax
 -      -     1.00    -      -      -      -      -      -      -      -      -     add	rax, r8
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	r9, qword ptr [rsp + 168]
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     lea	rbp, [r10 + r9]
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [r14 + 8*r11 + 64], rbp
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	r9, qword ptr [rsp + 128]
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     lea	rbp, [r10 + r9]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [r14 + 8*r11 + 72], rbp
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     lea	rbp, [r8 + r8]
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	r9, qword ptr [rsp + 192]
 -      -      -      -      -      -      -      -     1.00    -      -      -     add	r9, r10
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [r14 + 8*r11 + 80], r9
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	r9, qword ptr [rsp + 136]
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     lea	r9, [r10 + r9]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [r14 + 8*r11 + 88], r9
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	r9, qword ptr [rsp + 144]
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     lea	r9, [r10 + r9]
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [r14 + 8*r11 + 96], r9
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	r9, qword ptr [rsp + 152]
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     lea	r9, [r10 + r9]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [r14 + 8*r11 + 104], r9
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	r9, qword ptr [rsp + 48]
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     lea	r9, [r10 + r9]
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [r14 + 8*r11 + 112], r9
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	r9, qword ptr [rsp + 88]
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     lea	r9, [r10 + r9]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [r14 + 8*r11 + 120], r9
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	r9, qword ptr [rsp + 160]
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     lea	r9, [r10 + r9]
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [r14 + 8*r11 + 128], r9
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	r9, qword ptr [rsp + 176]
 -      -      -      -      -      -      -      -     1.00    -      -      -     add	r9, r10
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [r14 + 8*r11 + 136], r9
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	r9, qword ptr [rsp + 184]
 -      -     1.00    -      -      -      -      -      -      -      -      -     add	r9, r10
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [r14 + 8*r11 + 144], r9
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	r9, qword ptr [rsp + 200]
 -      -      -      -      -      -      -      -     1.00    -      -      -     add	r9, r10
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [r14 + 8*r11 + 152], r9
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     lea	r9, [r8 + rbp]
 -      -     1.00    -      -      -      -      -      -      -      -      -     add	rax, r9
 -      -      -      -      -      -      -      -     1.00    -      -      -     add	r9, r8
 -      -     1.00    -      -      -      -      -      -      -      -      -     add	rax, r9
 -      -      -      -      -      -      -      -     1.00    -      -      -     add	r9, r8
 -      -     1.00    -      -      -      -      -      -      -      -      -     add	r9, rax
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	rax, qword ptr [rsp + 208]
 -      -     1.00    -      -      -      -      -      -      -      -      -     add	rax, r10
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [r14 + 8*r11 + 160], rax
 -      -      -      -     1.00    -      -      -     1.00    -      -      -     add	r10, qword ptr [rsp + 72]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [r14 + 8*r11 + 168], r10
 -      -     1.00    -      -      -      -      -      -      -      -      -     mov	r10, r9
 -      -     1.00    -      -      -      -      -      -      -      -      -     add	r10, rbp
 -      -     1.00    -      -      -      -      -      -      -      -      -     add	r11, 16
 -      -      -      -      -      -      -      -     1.00    -      -      -     add	r15, -2
 -      -      -      -      -      -      -      -     1.00    -      -      -     jne	.LBB6_118
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     mov	r15, r10
 -      -     0.99   0.01   0.01   0.99    -      -      -      -      -      -     sub	r15, qword ptr [rsp + 48]
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	rbp, qword ptr [rsp + 256]
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	rax, qword ptr [rsp + 248]
 -      -      -      -      -      -      -     1.00    -      -      -      -     test	al, 8
 -      -      -      -      -      -      -      -     1.00    -      -      -     jne	.LBB6_122
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [r14 + 8*r11 + 48], r10
 -      -      -      -      -      -      -     1.00    -      -      -      -     lea	rax, [r10 + r8]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [r14 + 8*r11 + 56], rax
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     add	rax, r8
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [r14 + 8*r11 + 64], rax
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     add	rax, r8
 -      -      -      -      -      -     0.99    -      -     0.99   0.01   0.01   mov	qword ptr [r14 + 8*r11 + 72], rax
 -      -     0.99    -      -      -      -     0.01    -      -      -      -     add	rax, r8
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [r14 + 8*r11 + 80], rax
 -      -     1.00    -      -      -      -      -      -      -      -      -     add	rax, r8
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [r14 + 8*r11 + 88], rax
 -      -      -      -      -      -      -     0.99   0.01    -      -      -     add	rax, r8
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [r14 + 8*r11 + 96], rax
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     add	rax, r8
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [r14 + 8*r11 + 104], rax
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     mov	r15, r10
 -      -     1.00    -      -      -      -      -      -      -      -      -     mov	r8d, ecx
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     and	r8d, -8
 -      -      -      -      -      -      -      -     1.00    -      -      -     mov	rax, rdx
 -      -      -      -      -      -      -      -     1.00    -      -      -     shl	rax, 4
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     add	rax, r15
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	r11, qword ptr [rsp + 80]
 -      -      -     1.00    -      -      -      -      -      -      -      -     and	ecx, 7
 -      -      -      -      -      -      -      -     1.00    -      -      -     je	.LBB6_126
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     lea	r8, [r14 + 8*r8]
 -      -      -      -      -      -      -     1.00    -      -      -      -     add	r8, 48
 -      -      -     1.00    -      -      -      -      -      -      -      -     add	rdx, rdx
 -      -      -      -      -      -      -      -      -      -      -      -     xor	r9d, r9d
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [r8 + 8*r9], rax
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     add	r9, 1
 -      -      -     0.99    -      -      -      -     0.01    -      -      -     add	rax, rdx
 -      -      -      -      -      -      -     1.00    -      -      -      -     cmp	rcx, r9
 -      -      -      -      -      -      -      -     1.00    -      -      -     jne	.LBB6_125
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	r10, qword ptr [rsp + 264]
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	rcx, qword ptr [r10 + 16]
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     mov	rax, qword ptr [r10 + 8]
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     add	rax, rcx
 -      -      -      -      -      -      -      -     1.00    -      -      -     mov	edx, eax
 -      -      -      -      -      -      -     0.01   0.99    -      -      -     and	edx, 7
 -      -      -     1.00    -      -      -      -      -      -      -      -     mov	r9d, 8
 -      -      -      -      -      -      -     0.99   0.01    -      -      -     sub	r9, rdx
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     test	rdx, rdx
 -      -      -      -      -      -      -      -     1.00    -      -      -     cmove	r9, rdx
 -      -      -      -      -      -      -     1.00    -      -      -      -     lea	rcx, [rcx + r9 + 56]
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	r8, [r9 + rax]
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [r10 + 16], rcx
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [r9 + rax], r10
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	rcx, qword ptr [rsi + 128]
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	rdx, qword ptr [rsp + 96]
 -      -      -     0.01    -      -      -      -     0.99    -      -      -     add	rcx, rdx
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [r9 + rax + 8], rcx
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     mov	rcx, qword ptr [rsp + 56]
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	ecx, dword ptr [rcx + rdx + 52]
 -      -      -     1.00    -      -      -      -      -      -      -      -     imul	rcx, rcx, 88
 -      -     1.00    -     1.00    -      -      -      -      -      -      -     add	rcx, qword ptr [rsi + 104]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [r9 + rax + 16], rcx
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	rcx, qword ptr [r11 + 8]
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [r9 + rax + 24], rcx
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	ecx, dword ptr [rsp + 272]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [r9 + rax + 32], rcx
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [r9 + rax + 40], rbp
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	dword ptr [r9 + rax + 48], 2
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	byte ptr [r9 + rax + 52], 0
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	rax, qword ptr [rsi]
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	rcx, qword ptr [rax + 288]
 -      -      -      -      -      -      -     1.00    -      -      -      -     lea	rdx, [rip + handmade_asset.LoadAssetWork]
 -      -     0.01   0.99   1.00    -     0.01    -     1.00   0.01   0.99   0.99   call	qword ptr [rip + handmade_data.platformAPI]
 -      -      -      -      -      -      -      -      -      -      -      -     xor	ebp, ebp
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	r11d, dword ptr [rsp + 64]
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     vbroadcastss	xmm5, dword ptr [rdi + 8]
 -      -      -      -     1.00    -      -      -      -      -      -      -     vbroadcastss	xmm1, dword ptr [rdi + 12]
 -      -      -      -      -     1.00    -      -      -      -      -      -     vmovss	xmm2, dword ptr [rdi + 32]
 -      -      -      -     1.00    -      -      -      -      -      -      -     vmovd	xmm0, dword ptr [rdi + 36]
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmulss	xmm17, xmm2, xmm7
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	rax, qword ptr [rsp + 104]
 -      -      -      -      -     1.00    -      -      -      -      -      -     vmovss	xmm3, dword ptr [rax + 112]
 -      -      -     1.00   0.99   0.01    -      -      -      -      -      -     vmulss	xmm19, xmm6, dword ptr [rdi + 16]
 -      -      -      -     1.00    -      -      -      -      -      -      -     vmovss	xmm4, dword ptr [rax + 116]
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulss	xmm16, xmm19, xmm7
 -      -     1.00    -     1.00    -      -      -      -      -      -      -     vmulss	xmm18, xmm6, dword ptr [rdi + 20]
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	eax, dword ptr [r13 + 32]
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovdqa64	xmm20, xmm11
 -      -     0.01    -      -      -      -     0.99    -      -      -      -     vpternlogd	xmm20, xmm0, xmm9, 248
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddss	xmm20, xmm0, xmm20
 -      -     2.00    -      -      -      -      -      -      -      -      -     vrndscaless	xmm20, xmm20, xmm20, 11
 -      -      -     2.00    -      -      -      -      -      -      -      -     vcvttss2usi	edx, xmm20
 -      -      -      -      -      -      -      -     1.00    -      -      -     sub	eax, edx
 -      -     0.01   0.99    -      -      -     1.00    -      -      -      -     vcvtusi2ss	xmm20, xmm23, eax
 -     3.00   1.00    -      -      -      -      -      -      -      -      -     vdivss	xmm20, xmm20, xmm17
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovdqa64	xmm21, xmm11
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vpternlogd	xmm21, xmm20, xmm9, 248
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddss	xmm20, xmm20, xmm21
 -      -      -     2.00    -      -      -      -      -      -      -      -     vrndscaless	xmm20, xmm20, xmm20, 11
 -      -     0.02   1.98    -      -      -      -      -      -      -      -     vcvttss2usi	eax, xmm20
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	ecx, dword ptr [rsp + 112]
 -      -      -      -      -      -      -     0.99   0.01    -      -      -     cmp	ecx, eax
 -      -      -      -      -      -      -     0.01   0.99    -      -      -     mov	r10d, eax
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     cmovb	r10d, ecx
 -      -      -      -      -      -      -      -      -      -      -      -     xor	edx, edx
 -      -     1.00    -      -      -      -      -      -      -      -      -     vucomiss	xmm16, xmm10
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     jne	.LBB6_147
 -      -      -      -      -      -      -      -     1.00    -      -      -     jnp	.LBB6_128
 -      -      -      -     1.00    -      -     1.00    -      -      -      -     vmovss	xmm20, dword ptr [rdi + 24]
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vsubss	xmm20, xmm20, xmm5
 -     3.00   1.00    -      -      -      -      -      -      -      -      -     vdivss	xmm20, xmm20, xmm16
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vaddss	xmm20, xmm20, xmm12
 -      -     1.98   0.02    -      -      -      -      -      -      -      -     vcvttss2usi	r9d, xmm20
 -      -      -      -      -      -      -     0.99   0.01    -      -      -     cmp	r10d, r9d
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     mov	r8d, 0
 -      -     2.00    -      -      -      -      -      -      -      -      -     cmova	r8d, r9d
 -      -      -      -      -      -      -      -     1.00    -      -      -     cmovae	r10d, r9d
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulss	xmm20, xmm18, xmm7
 -      -     1.00    -      -      -      -      -      -      -      -      -     vucomiss	xmm20, xmm10
 -      -      -      -      -      -      -      -     1.00    -      -      -     jne	.LBB6_130
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     jnp	.LBB6_131
 -      -      -      -      -     1.00    -     1.00    -      -      -      -     vmovss	xmm21, dword ptr [rdi + 28]
 -      -      -     1.00    -      -      -      -      -      -      -      -     vsubss	xmm21, xmm21, xmm1
 -     3.00   1.00    -      -      -      -      -      -      -      -      -     vdivss	xmm21, xmm21, xmm20
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vaddss	xmm21, xmm21, xmm12
 -      -     1.98   0.02    -      -      -      -      -      -      -      -     vcvttss2usi	r9d, xmm21
 -      -      -      -      -      -      -     1.00    -      -      -      -     cmp	r10d, r9d
 -      -     1.00    -      -      -      -      -      -      -      -      -     mov	edx, 0
 -      -      -      -      -      -      -      -     2.00    -      -      -     cmova	edx, r9d
 -      -     1.00    -      -      -      -      -      -      -      -      -     cmovae	r10d, r9d
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	dword ptr [rsp + 56], ebp
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	dword ptr [rsp + 64], r11d
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulss	xmm13, xmm19, xmm10
 -      -      -      -      -      -      -     1.00    -      -      -      -     vbroadcastss	xmm15, xmm19
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm19, xmm15, xmm8
 -      -      -      -      -      -      -     1.00    -      -      -      -     vblendps	xmm13, xmm13, xmm15, 2
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovlhps	xmm19, xmm13, xmm19
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm5, xmm5, xmm19
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulss	xmm13, xmm18, xmm10
 -      -      -      -      -      -      -     1.00    -      -      -      -     vbroadcastss	xmm15, xmm18
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulps	xmm18, xmm15, xmm8
 -      -     0.99    -      -      -      -     0.01    -      -      -      -     vblendps	xmm13, xmm13, xmm15, 2
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovlhps	xmm18, xmm13, xmm18
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm15, xmm1, xmm18
 -      -     1.00    -      -      -      -     1.00    -      -      -      -     vcvtusi2ss	xmm18, xmm23, r10d
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulss	xmm1, xmm17, xmm18
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddss	xmm1, xmm0, xmm1
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     mov	r9d, r10d
 -      -      -     1.00    -      -      -      -      -      -      -      -     test	r10d, r10d
 -      -      -      -      -      -      -      -     1.00    -      -      -     je	.LBB6_134
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     vbroadcastss	xmm3, xmm3
 -      -      -      -      -      -      -     1.00    -      -      -      -     vbroadcastss	xmm16, xmm16
 -      -      -     1.00    -      -      -      -      -      -      -      -     vbroadcastss	xmm4, xmm4
 -      -      -      -      -      -      -     1.00    -      -      -      -     vbroadcastss	xmm17, xmm20
 -      -      -     1.00    -      -      -      -      -      -      -      -     vsubss	xmm19, xmm1, xmm0
 -     3.00   1.00    -      -      -      -      -      -      -      -      -     vdivss	xmm18, xmm19, xmm18
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulss	xmm13, xmm10, xmm2
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     vbroadcastss	xmm2, xmm2
 -      -     1.00    -     0.99   0.01    -      -      -      -      -      -     vmulps	xmm19, xmm2, xmmword ptr [rip + .LCPI6_6]
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vblendps	xmm2, xmm13, xmm2, 2
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovlhps	xmm2, xmm2, xmm19
 -      -      -     0.99    -      -      -      -     0.01    -      -      -     mov	r10, r9
 -      -     1.00    -      -      -      -      -      -      -      -      -     shl	r10, 4
 -      -      -      -      -      -      -      -      -      -      -      -     xor	r11d, r11d
 -      -      -      -      -      -      -      -      -      -      -      -     xor	r14d, r14d
 -      -     0.01   0.99    -      -      -     2.00    -      -      -      -     vcvtusi2ss	xmm19, xmm23, r14
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulss	xmm19, xmm18, xmm19
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddss	xmm19, xmm0, xmm19
 -      -      -      -      -      -      -     1.00    -      -      -      -     vbroadcastss	xmm19, xmm19
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm19, xmm2, xmm19
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvttps2dq	xmm20, xmm19
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	r15, qword ptr [r13 + 16]
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmovd	ebp, xmm20
 -      -      -      -      -      -      -     1.00    -      -      -      -     movsxd	rbp, ebp
 -      -      -      -     1.00    -      -      -      -      -      -      -     movsx	ecx, word ptr [r15 + 2*rbp]
 -      -      -     1.00    -      -      -     1.00    -      -      -      -     vcvtsi2ss	xmm21, xmm23, ecx
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm20, xmm20
 -      -     1.00    -      -      -      -      -      -      -      -      -     vsubps	xmm19, xmm19, xmm20
 -      -      -      -      -     1.00    -      -      -      -      -      -     movsx	ecx, word ptr [r15 + 2*rbp + 2]
 -      -      -      -      -      -      -     1.00    -      -      -      -     vbroadcastss	xmm20, xmm21
 -      -      -     1.00    -      -      -     1.00    -      -      -      -     vcvtsi2ss	xmm21, xmm23, ecx
 -      -      -      -      -      -      -     1.00    -      -      -      -     vbroadcastss	xmm21, xmm21
 -      -     1.00    -      -      -      -      -      -      -      -      -     vsubps	xmm22, xmm14, xmm19
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm20, xmm20, xmm22
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm19, xmm21, xmm19
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm19, xmm19, xmm20
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm20, xmm3, xmm5
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm20, xmm20, xmm19
 -      -     1.00    -     1.00    -      -      -      -      -      -      -     vaddps	xmm20, xmm20, xmmword ptr [r12 + r11]
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulps	xmm21, xmm4, xmm15
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm19, xmm21, xmm19
 -      -     1.00    -      -     1.00    -      -      -      -      -      -     vaddps	xmm19, xmm19, xmmword ptr [rbx + r11]
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   vmovaps	xmmword ptr [r12 + r11], xmm20
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm5, xmm16, xmm5
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     vmovaps	xmmword ptr [rbx + r11], xmm19
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vaddps	xmm15, xmm17, xmm15
 -      -      -      -      -      -      -      -     1.00    -      -      -     add	r14, 1
 -      -      -      -      -      -      -     0.99   0.01    -      -      -     add	r11, 16
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     cmp	r10, r11
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     jne	.LBB6_133
 -      -      -      -      -      -      -     1.00    -      -      -      -     vblendps	xmm0, xmm5, xmm15, 2
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   vmovlps	qword ptr [rdi + 8], xmm0
 -      -      -      -      -      -      -     0.01   0.99    -      -      -     cmp	r8d, r9d
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     je	.LBB6_148
 -      -     0.01    -      -      -      -     0.99    -      -      -      -     cmp	edx, r9d
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	r14, qword ptr [rsp + 232]
 -      -      -      -      -      -      -     0.01   0.99    -      -      -     mov	r15d, 1
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     je	.LBB6_136
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     vmovss	dword ptr [rdi + 36], xmm1
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     cmp	r9d, eax
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     je	.LBB6_140
 -      -      -      -      -      -      -      -     1.00    -      -      -     jmp	.LBB6_138
 -      -      -      -      -     1.00    -      -      -      -      -      -     vmovss	xmm0, dword ptr [rdi + 24]
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   vmovss	dword ptr [rdi + 8], xmm0
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	dword ptr [rdi + 16], 0
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     cmp	edx, r9d
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	r14, qword ptr [rsp + 232]
 -      -      -      -      -      -      -      -     1.00    -      -      -     mov	r15d, 1
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     jne	.LBB6_137
 -      -      -      -      -     1.00    -      -      -      -      -      -     vmovss	xmm0, dword ptr [rdi + 28]
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   vmovss	dword ptr [rdi + 12], xmm0
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	dword ptr [rdi + 20], 0
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   vmovss	dword ptr [rdi + 36], xmm1
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     cmp	r9d, eax
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     jne	.LBB6_138
 -      -      -     0.99   1.00    -      -     0.01    -      -      -      -     cmp	byte ptr [rsp + 56], 0
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     jne	.LBB6_143
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	eax, dword ptr [rsp + 64]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	dword ptr [rdi + 40], eax
 -      -      -     1.00   1.00    -      -      -      -      -      -      -     vcvtusi2ss	xmm0, xmm23, dword ptr [r13 + 32]
 -      -     1.00    -      -      -      -      -      -      -      -      -     vsubss	xmm0, xmm1, xmm0
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   vmovss	dword ptr [rdi + 36], xmm0
 -      -     1.00    -      -      -      -      -      -      -      -      -     vucomiss	xmm10, xmm0
 -      -      -      -      -      -      -      -     1.00    -      -      -     jbe	.LBB6_138
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	dword ptr [rdi + 36], 0
 -      -      -      -      -     1.00    -      -      -      -      -      -     movzx	eax, byte ptr [rsp + 43]
 -      -      -     1.00   1.00    -      -      -      -      -     1.00   1.00   sub	dword ptr [rsp + 112], r9d
 -      -     1.00    -      -      -      -      -      -      -      -      -     je	.LBB6_37
 -      -      -      -      -      -      -     1.00    -      -      -      -     test	al, 1
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     je	.LBB6_17
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     jmp	.LBB6_37
 -      -      -      -      -      -      -      -      -      -      -      -     xor	r8d, r8d
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulss	xmm20, xmm18, xmm7
 -      -     1.00    -      -      -      -      -      -      -      -      -     vucomiss	xmm20, xmm10
 -      -      -      -      -      -      -      -     1.00    -      -      -     jne	.LBB6_130
 -      -     1.00    -      -      -      -      -      -      -      -      -     jp	.LBB6_130
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     jmp	.LBB6_131
 -      -      -      -      -      -     1.00    -      -     2.00    -      -     mfence
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	dword ptr [rsi + 332], 0
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	eax, dword ptr [rdi + 40]
 -      -      -      -      -      -      -     1.00    -      -      -      -     test	rax, rax
 -      -      -      -      -      -      -      -     1.00    -      -      -     je	.LBB6_65
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	r13, qword ptr [rsi + 128]
 -      -      -     1.00    -      -      -      -      -      -      -      -     imul	r9, rax, 56
 -      -      -      -      -      -      -      -      -      -      -      -     xor	eax, eax
 -      -     2.00    -      -     1.00   1.00    -     1.00   1.00    -      -     lock		cmpxchg	dword ptr [r13 + r9], r15d
 -      -     1.00    -      -      -      -      -      -      -      -      -     jne	.LBB6_65
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	rax, qword ptr [rsi]
 -      -      -      -     1.00    -      -      -     1.00    -      -      -     cmp	byte ptr [rax + 80], 1
 -      -     1.00    -      -      -      -      -      -      -      -      -     jne	.LBB6_42
 -      -     1.00    -      -     1.00    -      -      -      -      -      -     cmp	byte ptr [rax + 136], 1
 -      -      -      -      -      -      -      -     1.00    -      -      -     jne	.LBB6_44
 -      -      -      -     1.00    -      -     1.00    -      -      -      -     cmp	byte ptr [rax + 192], 1
 -      -     1.00    -      -      -      -      -      -      -      -      -     jne	.LBB6_46
 -      -      -     1.00    -     1.00    -      -      -      -      -      -     cmp	byte ptr [rax + 248], 0
 -      -      -      -      -      -      -      -     1.00    -      -      -     je	.LBB6_48
 -      -      -      -      -      -      -     1.00    -      -      -      -     add	r13, r9
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	dword ptr [r13], 0
 -      -      -      -      -      -      -      -     1.00    -      -      -     jmp	.LBB6_65
 -      -     1.00    -      -      -      -      -      -      -      -      -     test	al, 1
 -      -      -      -      -      -      -      -     1.00    -      -      -     jne	.LBB6_144
 -      -      -      -      -      -      -      -     1.00    -      -      -     jmp	.LBB6_38
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	byte ptr [rsp + 43], 1
 -      -      -      -      -      -      -      -     1.00    -      -      -     jmp	.LBB6_144
 -      -      -      -      -      -      -     1.00    -      -      -      -     lea	rcx, [rax + 80]
 -      -      -      -      -      -      -      -      -      -      -      -     xor	edx, edx
 -      -     1.00    -      -      -      -      -      -      -      -      -     jmp	.LBB6_49
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	rcx, [rax + 136]
 -      -      -      -      -      -      -     1.00    -      -      -      -     mov	edx, 1
 -      -      -      -      -      -      -      -     1.00    -      -      -     jmp	.LBB6_49
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	rcx, [rax + 192]
 -      -      -      -      -      -      -     1.00    -      -      -      -     mov	edx, 2
 -      -     1.00    -      -      -      -      -      -      -      -      -     jmp	.LBB6_49
 -      -      -      -      -      -      -     1.00    -      -      -      -     lea	rcx, [rax + 248]
 -      -      -      -      -      -      -      -     1.00    -      -      -     mov	edx, 3
 -      -      -     1.00    -      -      -      -      -      -      -      -     imul	rdx, rdx, 56
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	r8, [rax + rdx]
 -      -     1.00    -      -      -      -      -      -      -      -      -     add	r8, 32
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	byte ptr [rcx], 1
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	rcx, qword ptr [rax + rdx + 48]
 -      -      -      -     1.00    -     1.00    -     1.00   1.00    -      -     add	dword ptr [rax + rdx + 56], 1
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rsp + 144], r8
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rax + rdx + 64], r8
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rax + rdx + 72], rcx
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	ebp, dword ptr [r13 + r9 + 32]
 -      -      -      -      -      -      -     1.00    -      -      -      -     add	ebp, ebp
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	eax, dword ptr [r13 + r9 + 36]
 -      -      -     1.00    -      -      -      -      -      -      -      -     imul	eax, ebp
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rsp + 152], rax
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	edx, [rax + 64]
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	r8d, dword ptr [rdi + 40]
 -      -      -      -      -      -      -      -     1.00    -      -      -     mov	rcx, rsi
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rsp + 88], r9
 -      -      -      -      -      -     1.00   1.00   1.00   1.00    -      -     call	handmade_asset.AcquireAssetMemory
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	r10, qword ptr [rsp + 88]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [r13 + r10 + 8], rax
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	ecx, dword ptr [r13 + r10 + 32]
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	dword ptr [rax + 32], ecx
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	edx, dword ptr [r13 + r10 + 36]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	dword ptr [rax + 36], edx
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	r11, qword ptr [r13 + r10 + 8]
 -      -      -      -      -      -      -     1.00    -      -      -      -     add	r11, 64
 -      -     1.00    -      -      -      -      -      -      -      -      -     test	rdx, rdx
 -      -      -      -      -      -      -      -     1.00    -      -      -     je	.LBB6_64
 -      -      -      -      -      -      -     1.00    -      -      -      -     mov	r8d, ebp
 -      -      -      -      -      -      -      -     1.00    -      -      -     cmp	edx, 8
 -      -     1.00    -      -      -      -      -      -      -      -      -     jae	.LBB6_52
 -      -      -      -      -      -      -      -      -      -      -      -     xor	r9d, r9d
 -      -      -      -      -      -      -     1.00    -      -      -      -     mov	rcx, r11
 -      -     1.00    -      -      -      -      -      -      -      -      -     jmp	.LBB6_61
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	r9, [r8 + r8]
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	rcx, [rdx - 8]
 -      -      -      -      -      -      -     1.00    -      -      -      -     cmp	rcx, 8
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rsp + 136], r11
 -      -     1.00    -      -      -      -      -      -      -      -      -     jae	.LBB6_55
 -      -      -      -      -      -      -      -      -      -      -      -     xor	r15d, r15d
 -      -      -      -      -      -      -      -     1.00    -      -      -     jmp	.LBB6_58
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rsp + 128], r13
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rsp + 80], rcx
 -      -     1.00    -      -      -      -      -      -      -      -      -     mov	r10, rcx
 -      -      -      -      -      -      -      -     1.00    -      -      -     shr	r10, 3
 -      -      -      -      -      -      -     1.00    -      -      -      -     add	r10, 1
 -      -      -      -      -      -      -      -     1.00    -      -      -     and	r10, -2
 -      -      -      -      -      -      -      -     1.00    -      -      -     mov	rcx, r8
 -      -      -      -      -      -      -      -     1.00    -      -      -     shl	rcx, 5
 -      -      -      -      -      -      -     1.00    -      -      -      -     sub	rcx, r9
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rsp + 112], rcx
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	rcx, [r8 + 8*r8]
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	rcx, [rcx + 2*rcx]
 -      -      -      -      -      -      -     1.00    -      -      -      -     add	rcx, r8
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rsp + 64], rcx
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	rcx, [r8 + 4*r8]
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	r14, [rcx + 4*rcx]
 -      -      -      -      -      -      -      -     1.00    -      -      -     add	r14, r8
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rsp + 56], r14
 -      -      -      -      -      -      -     1.00    -      -      -      -     lea	r14, [8*r8]
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rsp + 96], r14
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	r14, [r14 + 2*r14]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rsp + 48], r14
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	rcx, [r9 + 4*rcx]
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rsp + 72], rcx
 -      -      -      -      -      -      -     1.00    -      -      -      -     lea	rcx, [4*r8]
 -      -      -      -      -      -      -     1.00    -      -      -      -     lea	r14, [rcx + 4*rcx]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rsp + 200], r14
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	r14, [r9 + 8*r9]
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rsp + 192], r14
 -      -     1.00    -      -      -      -      -      -      -      -      -     mov	rbp, r8
 -      -     1.00    -      -      -      -      -      -      -      -      -     shl	rbp, 4
 -      -      -      -      -      -      -      -     1.00    -      -      -     mov	r14, rbp
 -      -     1.00    -      -      -      -      -      -      -      -      -     sub	r14, r9
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rsp + 184], r14
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rsp + 208], rcx
 -      -      -      -      -      -      -     1.00    -      -      -      -     lea	rcx, [rcx + 2*rcx]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rsp + 176], rcx
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	rcx, [r9 + 4*r9]
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rsp + 168], rcx
 -      -      -      -      -      -      -     1.00    -      -      -      -     lea	rcx, [r9 + 2*r9]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rsp + 160], rcx
 -      -      -      -      -      -      -      -      -      -      -      -     xor	r15d, r15d
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rax + 8*r15 + 16], r11
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	r13, [r11 + r9]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rax + 8*r15 + 24], r13
 -      -     1.00    -      -      -      -      -      -      -      -      -     add	r13, r9
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	rcx, qword ptr [rsp + 208]
 -      -     1.00    -      -      -      -      -      -      -      -      -     add	rcx, r11
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rax + 8*r15 + 32], rcx
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	rcx, qword ptr [rsp + 160]
 -      -      -      -      -      -      -     1.00    -      -      -      -     lea	rcx, [r11 + rcx]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rax + 8*r15 + 40], rcx
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	rcx, [r9 + r9]
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	r14, qword ptr [rsp + 96]
 -      -      -      -      -      -      -     1.00    -      -      -      -     lea	r14, [r11 + r14]
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rax + 8*r15 + 48], r14
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	r14, qword ptr [rsp + 168]
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	r14, [r11 + r14]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rax + 8*r15 + 56], r14
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	r14, qword ptr [rsp + 176]
 -      -      -      -      -      -      -     1.00    -      -      -      -     lea	r14, [r11 + r14]
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rax + 8*r15 + 64], r14
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	r14, qword ptr [rsp + 184]
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	r14, [r11 + r14]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rax + 8*r15 + 72], r14
 -      -      -      -      -      -      -     1.00    -      -      -      -     lea	r14, [r11 + rbp]
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rax + 8*r15 + 80], r14
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	r14, qword ptr [rsp + 192]
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	r14, [r11 + r14]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rax + 8*r15 + 88], r14
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	r14, qword ptr [rsp + 200]
 -      -      -      -      -      -      -     1.00    -      -      -      -     lea	r14, [r11 + r14]
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rax + 8*r15 + 96], r14
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	r14, qword ptr [rsp + 72]
 -      -     1.00    -      -      -      -      -      -      -      -      -     add	r14, r11
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rax + 8*r15 + 104], r14
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	r14, qword ptr [rsp + 48]
 -      -      -      -      -      -      -      -     1.00    -      -      -     add	r14, r11
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rax + 8*r15 + 112], r14
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	r14, qword ptr [rsp + 56]
 -      -      -      -      -      -      -      -     1.00    -      -      -     add	r14, r11
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rax + 8*r15 + 120], r14
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	r14, [rcx + r9]
 -      -     1.00    -      -      -      -      -      -      -      -      -     add	r13, r14
 -      -      -      -      -      -      -      -     1.00    -      -      -     add	r14, r9
 -      -     1.00    -      -      -      -      -      -      -      -      -     add	r13, r14
 -      -      -      -      -      -      -      -     1.00    -      -      -     add	r14, r9
 -      -     1.00    -      -      -      -      -      -      -      -      -     add	r14, r13
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	r13, qword ptr [rsp + 64]
 -      -     1.00    -      -      -      -      -      -      -      -      -     add	r13, r11
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rax + 8*r15 + 128], r13
 -      -      -      -     1.00    -      -      -     1.00    -      -      -     add	r11, qword ptr [rsp + 112]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rax + 8*r15 + 136], r11
 -      -     1.00    -      -      -      -      -      -      -      -      -     mov	r11, r14
 -      -      -      -      -      -      -     1.00    -      -      -      -     add	r11, rcx
 -      -     1.00    -      -      -      -      -      -      -      -      -     add	r15, 16
 -      -      -      -      -      -      -      -     1.00    -      -      -     add	r10, -2
 -      -      -      -      -      -      -      -     1.00    -      -      -     jne	.LBB6_56
 -      -      -      -      -      -      -      -     1.00    -      -      -     mov	r10, r11
 -      -     1.00    -      -      -      -      -      -      -      -      -     sub	r10, rbp
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	r14, qword ptr [rsp + 232]
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	r13, qword ptr [rsp + 128]
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	rcx, qword ptr [rsp + 80]
 -      -     1.00    -      -      -      -      -      -      -      -      -     test	cl, 8
 -      -      -      -      -      -      -      -     1.00    -      -      -     jne	.LBB6_60
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rax + 8*r15 + 16], r11
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	rcx, [r11 + r9]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rax + 8*r15 + 24], rcx
 -      -      -      -      -      -      -      -     1.00    -      -      -     add	rcx, r9
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rax + 8*r15 + 32], rcx
 -      -     1.00    -      -      -      -      -      -      -      -      -     add	rcx, r9
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rax + 8*r15 + 40], rcx
 -      -     1.00    -      -      -      -      -      -      -      -      -     add	rcx, r9
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rax + 8*r15 + 48], rcx
 -      -     1.00    -      -      -      -      -      -      -      -      -     add	rcx, r9
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rax + 8*r15 + 56], rcx
 -      -      -     1.00    -      -      -      -      -      -      -      -     add	rcx, r9
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rax + 8*r15 + 64], rcx
 -      -      -      -      -      -      -     1.00    -      -      -      -     add	rcx, r9
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rax + 8*r15 + 72], rcx
 -      -      -      -      -      -      -     1.00    -      -      -      -     mov	r10, r11
 -      -     1.00    -      -      -      -      -      -      -      -      -     mov	r9d, edx
 -      -     1.00    -      -      -      -      -      -      -      -      -     and	r9d, -8
 -      -      -      -      -      -      -      -     1.00    -      -      -     mov	rcx, r8
 -      -      -      -      -      -      -      -     1.00    -      -      -     shl	rcx, 4
 -      -      -      -      -      -      -     1.00    -      -      -      -     add	rcx, r10
 -      -      -      -      -      -      -      -     1.00    -      -      -     mov	r15d, 1
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	r10, qword ptr [rsp + 88]
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	r11, qword ptr [rsp + 136]
 -      -      -      -      -      -      -     1.00    -      -      -      -     and	edx, 7
 -      -      -      -      -      -      -      -     1.00    -      -      -     je	.LBB6_64
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	rax, [rax + 8*r9]
 -      -      -      -      -      -      -     1.00    -      -      -      -     add	rax, 16
 -      -      -      -      -      -      -     1.00    -      -      -      -     add	r8, r8
 -      -      -      -      -      -      -      -      -      -      -      -     xor	r9d, r9d
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rax + 8*r9], rcx
 -      -      -     1.00    -      -      -      -      -      -      -      -     add	r9, 1
 -      -      -      -      -      -      -      -     1.00    -      -      -     add	rcx, r8
 -      -      -      -      -      -      -     1.00    -      -      -      -     cmp	rdx, r9
 -      -     1.00    -      -      -      -      -      -      -      -      -     jne	.LBB6_63
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	r8, qword ptr [rsp + 144]
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	rcx, qword ptr [r8 + 16]
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	rax, qword ptr [r8 + 8]
 -      -     1.00    -      -      -      -      -      -      -      -      -     add	rax, rcx
 -      -      -     1.00    -      -      -      -      -      -      -      -     mov	edx, eax
 -      -      -      -      -      -      -     1.00    -      -      -      -     and	edx, 7
 -      -      -     1.00    -      -      -      -      -      -      -      -     mov	r9d, 8
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     sub	r9, rdx
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     test	rdx, rdx
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     cmove	r9, rdx
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	rdx, [r13 + r10 + 16]
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     lea	rcx, [rcx + r9 + 56]
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [r8 + 16], rcx
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [r9 + rax], r8
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	ecx, dword ptr [rdi + 40]
 -      -      -     1.00    -      -      -      -      -      -      -      -     imul	rcx, rcx, 56
 -      -      -      -     1.00    -      -     1.00    -      -      -      -     add	rcx, qword ptr [rsi + 128]
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     lea	r8, [r9 + rax]
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [r9 + rax + 8], rcx
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	ecx, dword ptr [r13 + r10 + 52]
 -      -      -     1.00    -      -      -      -      -      -      -      -     imul	rcx, rcx, 88
 -      -      -      -      -     1.00    -      -     1.00    -      -      -     add	rcx, qword ptr [rsi + 104]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [r9 + rax + 16], rcx
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	rcx, qword ptr [rdx]
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [r9 + rax + 24], rcx
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	ecx, dword ptr [rsp + 152]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [r9 + rax + 32], rcx
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [r9 + rax + 40], r11
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	dword ptr [r9 + rax + 48], 2
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	byte ptr [r9 + rax + 52], 0
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	rax, qword ptr [rsi]
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	rcx, qword ptr [rax + 288]
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	rdx, [rip + handmade_asset.LoadAssetWork]
 -      -      -      -      -     1.00   1.00   1.00   1.00   1.00    -      -     call	qword ptr [rip + handmade_data.platformAPI]
 -      -      -      -     1.00    -      -     1.00    -      -      -      -     cmp	byte ptr [rsp + 43], 0
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     je	.LBB6_38
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	rax, qword ptr [rdi]
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	rdx, qword ptr [rsp + 216]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rdx], rax
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	rcx, qword ptr [rsp + 104]
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	rax, qword ptr [rcx + 104]
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rdi], rax
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rcx + 104], rdi
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     mov	rdi, rdx
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   mov	qword ptr [rsp + 216], rdi
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     mov	rdi, qword ptr [rdi]
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     test	rdi, rdi
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     jne	.LBB6_16
 -      -      -      -      -      -      -      -     1.00    -      -      -     jmp	.LBB6_28
 -      -     1.00    -      -      -      -      -      -      -      -      -     jmp	.LBB6_104
 -      -      -      -      -      -      -      -     1.00    -      -      -     jmp	.LBB6_93
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	rdi, qword ptr [rdi]
 -      -      -     1.00    -      -      -      -      -      -      -      -     test	rdi, rdi
 -      -      -      -      -      -      -      -     1.00    -      -      -     jne	.LBB6_26
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	byte ptr [rsp + 43], 0


```
</details>

<details><summary>Timeline view:</summary>

```
                    0123456789          0123456789          0123456789          0123456789
Index     0123456789          0123456789          0123456789          0123456789          

[0,0]     DeeeeeER  .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   mov	rax, qword ptr [rsp + 104]
[0,1]     D=====eeeeeER  .    .    .    .    .    .    .    .    .    .    .    .    .   .   mov	rdi, qword ptr [rax + 96]
[0,2]     D==========eER .    .    .    .    .    .    .    .    .    .    .    .    .   .   test	rdi, rdi
[0,3]     D===========eER.    .    .    .    .    .    .    .    .    .    .    .    .   .   je	.LBB6_28
[0,4]     DeeeeeeE------R.    .    .    .    .    .    .    .    .    .    .    .    .   .   cmp	dword ptr [rsp + 44], 0
[0,5]     .D=====eE-----R.    .    .    .    .    .    .    .    .    .    .    .    .   .   je	.LBB6_26
[0,6]     .DeeeeeE------R.    .    .    .    .    .    .    .    .    .    .    .    .   .   vmovss	xmm1, dword ptr [rip + .LCPI6_0]
[0,7]     .D=====eeeeeeeeeeeER.    .    .    .    .    .    .    .    .    .    .    .   .   vdivss	xmm6, xmm1, xmm0
[0,8]     .DeeeeeE-----------R.    .    .    .    .    .    .    .    .    .    .    .   .   mov	rax, qword ptr [rsp + 104]
[0,9]     .D=====eE----------R.    .    .    .    .    .    .    .    .    .    .    .   .   add	rax, 96
[0,10]    .D======eE---------R.    .    .    .    .    .    .    .    .    .    .    .   .   mov	qword ptr [rsp + 216], rax
[0,11]    . DeE--------------R.    .    .    .    .    .    .    .    .    .    .    .   .   lea	rax, [rsi + 40]
[0,12]    . D=====eE---------R.    .    .    .    .    .    .    .    .    .    .    .   .   mov	qword ptr [rsp + 120], rax
[0,13]    . DeE--------------R.    .    .    .    .    .    .    .    .    .    .    .   .   lea	rax, [rsi + 8]
[0,14]    . D======eE--------R.    .    .    .    .    .    .    .    .    .    .    .   .   mov	qword ptr [rsp + 240], rax
[0,15]    . DeE--------------R.    .    .    .    .    .    .    .    .    .    .    .   .   mov	r15d, 1
[0,16]    . DeeeeeE----------R.    .    .    .    .    .    .    .    .    .    .    .   .   vmovss	xmm7, dword ptr [rip + .LCPI6_1]
[0,17]    .  DeeeeeeE--------R.    .    .    .    .    .    .    .    .    .    .    .   .   vmovddup	xmm8, qword ptr [rip + .LCPI6_2]
[0,18]    .  DeeeeeeE--------R.    .    .    .    .    .    .    .    .    .    .    .   .   vpbroadcastd	xmm9, dword ptr [rip + .LCPI6_3]
[0,19]    .  D---------------R.    .    .    .    .    .    .    .    .    .    .    .   .   vxorps	xmm10, xmm10, xmm10
[0,20]    .  D=eeeeeeE-------R.    .    .    .    .    .    .    .    .    .    .    .   .   vpbroadcastd	xmm11, dword ptr [rip + .LCPI6_4]
[0,21]    .  D=eeeeeE--------R.    .    .    .    .    .    .    .    .    .    .    .   .   vmovss	xmm12, dword ptr [rip + .LCPI6_5]
[0,22]    .  D==eeeeeeE------R.    .    .    .    .    .    .    .    .    .    .    .   .   vbroadcastss	xmm14, dword ptr [rip + .LCPI6_0]
[0,23]    .   D====eE--------R.    .    .    .    .    .    .    .    .    .    .    .   .   mov	qword ptr [rsp + 232], r14
[0,24]    .   D=====eE-------R.    .    .    .    .    .    .    .    .    .    .    .   .   mov	byte ptr [rsp + 43], 0
[0,25]    .   D==eeeeeE------R.    .    .    .    .    .    .    .    .    .    .    .   .   mov	rax, qword ptr [rsp + 224]
[0,26]    .   D=======eE-----R.    .    .    .    .    .    .    .    .    .    .    .   .   mov	dword ptr [rsp + 112], eax
[0,27]    .   D======eeeeeE--R.    .    .    .    .    .    .    .    .    .    .    .   .   mov	edx, dword ptr [rdi + 40]
[0,28]    .   D==eeeeeE------R.    .    .    .    .    .    .    .    .    .    .    .   .   mov	rcx, qword ptr [rsi + 128]
[0,29]    .    D-------------R.    .    .    .    .    .    .    .    .    .    .    .   .   xor	eax, eax
[0,30]    .    .D=====eeeeeeeeER   .    .    .    .    .    .    .    .    .    .    .   .   lock		cmpxchg	dword ptr [rsi + 332], r15d
[0,31]    .    . D============eER  .    .    .    .    .    .    .    .    .    .    .   .   jne	.LBB6_18
[0,32]    .    . D========eeeE--R  .    .    .    .    .    .    .    .    .    .    .   .   imul	rax, rdx, 56
[0,33]    .    . D===========eeeeeeER   .    .    .    .    .    .    .    .    .    .   .   cmp	dword ptr [rcx + rax], 2
[0,34]    .    . D=================eER  .    .    .    .    .    .    .    .    .    .   .   jne	.LBB6_39
[0,35]    .    . D===========eeeeeE--R  .    .    .    .    .    .    .    .    .    .   .   mov	r13, qword ptr [rcx + rax + 8]
[0,36]    .    .  D===============eeeeeER    .    .    .    .    .    .    .    .    .   .   mov	rdx, qword ptr [r13]
[0,37]    .    .  D===============eeeeeER    .    .    .    .    .    .    .    .    .   .   mov	r8, qword ptr [r13 + 8]
[0,38]    .    .  D====================eER   .    .    .    .    .    .    .    .    .   .   mov	qword ptr [r8], rdx
[0,39]    .    .  D================eeeeeER   .    .    .    .    .    .    .    .    .   .   mov	r8, qword ptr [r13 + 8]
[0,40]    .    .  D=====================eER  .    .    .    .    .    .    .    .    .   .   mov	qword ptr [rdx + 8], r8
[0,41]    .    .  DeeeeeE-----------------R  .    .    .    .    .    .    .    .    .   .   mov	rdx, qword ptr [rsp + 120]
[0,42]    .    .   D====================eER  .    .    .    .    .    .    .    .    .   .   mov	qword ptr [r13 + 8], rdx
[0,43]    .    .   D====eeeeeE------------R  .    .    .    .    .    .    .    .    .   .   mov	rdx, qword ptr [rdx]
[0,44]    .    .   D=====================eER .    .    .    .    .    .    .    .    .   .   mov	qword ptr [r13], rdx
[0,45]    .    .   D=====================eER .    .    .    .    .    .    .    .    .   .   mov	qword ptr [rdx + 8], r13
[0,46]    .    .   D===============eeeeeE--R .    .    .    .    .    .    .    .    .   .   mov	rdx, qword ptr [r13 + 8]
[0,47]    .    .   D======================eER.    .    .    .    .    .    .    .    .   .   mov	qword ptr [rdx], r13
[0,48]    .    .    D=========eeeeeE--------R.    .    .    .    .    .    .    .    .   .   mov	rax, qword ptr [rcx + rax + 8]
[0,49]    .    .    D===============eeeeeeE-R.    .    .    .    .    .    .    .    .   .   cmp	dword ptr [rax + 56], r14d
[0,50]    .    .    D=====================eER.    .    .    .    .    .    .    .    .   .   jae	.LBB6_22
[0,51]    .    .    D=====================eER.    .    .    .    .    .    .    .    .   .   mov	dword ptr [rax + 56], r14d
[0,52]    .    .    .D=====================eeeER  .    .    .    .    .    .    .    .   .   mfence
[0,53]    .    .    .D========================eER .    .    .    .    .    .    .    .   .   mov	dword ptr [rsi + 332], 0
[0,54]    .    .    .D========================eeeeeER  .    .    .    .    .    .    .   .   mov	eax, dword ptr [rdi + 40]
[0,55]    .    .    .D========================eeeeeER  .    .    .    .    .    .    .   .   mov	r8, qword ptr [rsi + 128]
[0,56]    .    .    . D============================eeeER    .    .    .    .    .    .   .   imul	rcx, rax, 56
[0,57]    .    .    . D===============================eeeeeER    .    .    .    .    .   .   mov	r11d, dword ptr [r8 + rcx + 40]
[0,58]    .    .    . DeE-----------------------------------R    .    .    .    .    .   .   mov	bpl, 1
[0,59]    .    .    . D====================================eER   .    .    .    .    .   .   test	r11d, r11d
[0,60]    .    .    . D=====================================eER  .    .    .    .    .   .   je	.LBB6_127
[0,61]    .    .    . D====================================eE-R  .    .    .    .    .   .   cmp	r11d, 1
[0,62]    .    .    .  D====================================eER  .    .    .    .    .   .   jne	.LBB6_66
[0,63]    .    .    .  D===========================eE---------R  .    .    .    .    .   .   mov	r11d, eax
[0,64]    .    .    .  D===========================eE---------R  .    .    .    .    .   .   test	eax, eax
[0,65]    .    .    .  D============================eE--------R  .    .    .    .    .   .   jne	.LBB6_67
[0,66]    .    .    .  D--------------------------------------R  .    .    .    .    .   .   xor	r11d, r11d
[0,67]    .    .    .  DeE------------------------------------R  .    .    .    .    .   .   jmp	.LBB6_127
[0,68]    .    .    .   D==========================eE---------R  .    .    .    .    .   .   add	rax, 1
[0,69]    .    .    .   D===========================eE--------R  .    .    .    .    .   .   mov	r11d, eax
[0,70]    .    .    .   D===========================eeeE------R  .    .    .    .    .   .   imul	r9, rax, 56
[0,71]    .    .    .   D-------------------------------------R  .    .    .    .    .   .   xor	ebp, ebp
[0,72]    .    .    .   D-------------------------------------R  .    .    .    .    .   .   xor	eax, eax
[0,73]    .    .    .    D=============================eeeeeeeeER.    .    .    .    .   .   lock		cmpxchg	dword ptr [r8 + r9], r15d
[0,74]    .    .    .    .D====================================eER    .    .    .    .   .   jne	.LBB6_127
[0,75]    .    .    .    .D====================eeeeeE------------R    .    .    .    .   .   mov	rax, qword ptr [rsi]
[0,76]    .    .    .    .D=========================eeeeeeE------R    .    .    .    .   .   cmp	byte ptr [rax + 80], 1
[0,77]    .    .    .    .D===============================eE-----R    .    .    .    .   .   jne	.LBB6_69
[0,78]    .    .    .    . D=========================eeeeeeE-----R    .    .    .    .   .   cmp	byte ptr [rax + 136], 1
[0,79]    .    .    .    . D===============================eE----R    .    .    .    .   .   jne	.LBB6_71
[0,80]    .    .    .    . D=========================eeeeeeE-----R    .    .    .    .   .   cmp	byte ptr [rax + 192], 1
[0,81]    .    .    .    . D=================================eE--R    .    .    .    .   .   jne	.LBB6_73
[0,82]    .    .    .    .  D=========================eeeeeeE----R    .    .    .    .   .   cmp	byte ptr [rax + 248], 0
[0,83]    .    .    .    .  D================================eE--R    .    .    .    .   .   je	.LBB6_75
[0,84]    .    .    .    .  D==========================eE--------R    .    .    .    .   .   add	r8, r9
[0,85]    .    .    .    .  D===========================eE-------R    .    .    .    .   .   mov	dword ptr [r8], 0
[0,86]    .    .    .    .  D------------------------------------R    .    .    .    .   .   xor	ebp, ebp
[0,87]    .    .    .    .   DeE---------------------------------R    .    .    .    .   .   jmp	.LBB6_127
[0,88]    .    .    .    .   D=======================eE----------R    .    .    .    .   .   lea	rcx, [rax + 80]
[0,89]    .    .    .    .   D-----------------------------------R    .    .    .    .   .   xor	edx, edx
[0,90]    .    .    .    .   D=eE--------------------------------R    .    .    .    .   .   jmp	.LBB6_76
[0,91]    .    .    .    .   D========================eE---------R    .    .    .    .   .   lea	rcx, [rax + 136]
[0,92]    .    .    .    .   DeE---------------------------------R    .    .    .    .   .   mov	edx, 1
[0,93]    .    .    .    .    DeE--------------------------------R    .    .    .    .   .   jmp	.LBB6_76
[0,94]    .    .    .    .    D========================eE--------R    .    .    .    .   .   lea	rcx, [rax + 192]
[0,95]    .    .    .    .    DeE--------------------------------R    .    .    .    .   .   mov	edx, 2
[0,96]    .    .    .    .    D=eE-------------------------------R    .    .    .    .   .   jmp	.LBB6_76
[0,97]    .    .    .    .    D=========================eE-------R    .    .    .    .   .   lea	rcx, [rax + 248]
[0,98]    .    .    .    .    DeE--------------------------------R    .    .    .    .   .   mov	edx, 3
[0,99]    .    .    .    .    .D========================eE-------R    .    .    .    .   .   mov	dword ptr [rsp + 64], r11d
[0,100]   .    .    .    .    .DeeeE-----------------------------R    .    .    .    .   .   imul	rdx, rdx, 56
[0,101]   .    .    .    .    .D========================eE-------R    .    .    .    .   .   lea	r10, [rax + rdx]
[0,102]   .    .    .    .    .D=========================eE------R    .    .    .    .   .   add	r10, 32
[0,103]   .    .    .    .    .D=========================eE------R    .    .    .    .   .   mov	byte ptr [rcx], 1
[0,104]   .    .    .    .    .D====================eeeeeE-------R    .    .    .    .   .   mov	rcx, qword ptr [rax + rdx + 48]
[0,105]   .    .    .    .    . D========================eeeeeeeER    .    .    .    .   .   add	dword ptr [rax + rdx + 56], 1
[0,106]   .    .    .    .    . D=========================eE-----R    .    .    .    .   .   mov	qword ptr [rsp + 264], r10
[0,107]   .    .    .    .    . D=========================eE-----R    .    .    .    .   .   mov	qword ptr [rax + rdx + 64], r10
[0,108]   .    .    .    .    . D==========================eE----R    .    .    .    .   .   mov	qword ptr [rax + rdx + 72], rcx
[0,109]   .    .    .    .    .  D=======================eE------R    .    .    .    .   .   lea	rax, [r8 + r9]
[0,110]   .    .    .    .    .  D========================eE-----R    .    .    .    .   .   add	rax, 32
[0,111]   .    .    .    .    .  D=========================eE----R    .    .    .    .   .   mov	qword ptr [rsp + 48], rax
[0,112]   .    .    .    .    .  D======================eeeeeE---R    .    .    .    .   .   mov	edx, dword ptr [r8 + r9 + 32]
[0,113]   .    .    .    .    .   D=========================eE---R    .    .    .    .   .   mov	qword ptr [rsp + 56], r8
[0,114]   .    .    .    .    .   D=========================eE---R    .    .    .    .   .   mov	qword ptr [rsp + 96], r9
[0,115]   .    .    .    .    .    D====================eeeeeE---R    .    .    .    .   .   mov	ecx, dword ptr [r8 + r9 + 36]
[0,116]   .    .    .    .    .    D-----------------------------R    .    .    .    .   .   xor	eax, eax
[0,117]   .    .    .    .    .    .D=========================eeeeeeeeER   .    .    .   .   lock		cmpxchg	dword ptr [rsi + 332], r15d
[0,118]   .    .    .    .    .    . D================================eER  .    .    .   .   jne	.LBB6_77
[0,119]   .    .    .    .    .    . D=======================eE---------R  .    .    .   .   add	edx, edx
[0,120]   .    .    .    .    .    .   D======================eE--------R  .    .    .   .   mov	dword ptr [rsp + 72], edx
[0,121]   .    .    .    .    .    .    D=====================eeeE------R  .    .    .   .   imul	ecx, edx
[0,122]   .    .    .    .    .    .    D========================eE-----R  .    .    .   .   lea	r15d, [rcx + 79]
[0,123]   .    .    .    .    .    .    .D========================eE----R  .    .    .   .   and	r15d, -16
[0,124]   .    .    .    .    .    .    .D=====eeeeeE-------------------R  .    .    .   .   mov	r14, qword ptr [rsi + 16]
[0,125]   .    .    .    .    .    .    . D=====eeeeeeE-----------------R  .    .    .   .   cmp	r14, qword ptr [rsp + 240]
[0,126]   .    .    .    .    .    .    . D======================eE-----R  .    .    .   .   mov	qword ptr [rsp + 272], rcx
[0,127]   .    .    .    .    .    .    . D===========eE----------------R  .    .    .   .   jne	.LBB6_81
[0,128]   .    .    .    .    .    .    . D-----------------------------R  .    .    .   .   xor	r14d, r14d
[0,129]   .    .    .    .    .    .    .  DeE--------------------------R  .    .    .   .   jmp	.LBB6_80
[0,130]   .    .    .    .    .    .    .   D===eeeeeE------------------R  .    .    .   .   mov	r14, qword ptr [r14 + 8]
[0,131]   .    .    .    .    .    .    .    .D==eeeeeeE----------------R  .    .    .   .   cmp	r14, qword ptr [rsp + 240]
[0,132]   .    .    .    .    .    .    .    .D=========eE--------------R  .    .    .   .   je	.LBB6_79
[0,133]   .    .    .    .    .    .    .    .D==========eeeeeeE--------R  .    .    .   .   test	byte ptr [r14 + 16], 1
[0,134]   .    .    .    .    .    .    .    . D================eE------R  .    .    .   .   jne	.LBB6_82
[0,135]   .    .    .    .    .    .    .    . D==================eeeeeeER .    .    .   .   cmp	qword ptr [r14 + 24], r15
[0,136]   .    .    .    .    .    .    .    .  D=======================eER.    .    .   .   jb	.LBB6_82
[0,137]   .    .    .    .    .    .    .    .  DeeeeeE-------------------R.    .    .   .   mov	rax, qword ptr [rsp + 56]
[0,138]   .    .    .    .    .    .    .    .   DeeeeeE------------------R.    .    .   .   mov	rcx, qword ptr [rsp + 96]
[0,139]   .    .    .    .    .    .    .    .   D========eE--------------R.    .    .   .   add	rax, rcx
[0,140]   .    .    .    .    .    .    .    .    D========eE-------------R.    .    .   .   add	rax, 8
[0,141]   .    .    .    .    .    .    .    .    .D==============eE------R.    .    .   .   mov	qword ptr [rsp + 80], rax
[0,142]   .    .    .    .    .    .    .    .    .D=eE-------------------R.    .    .   .   jmp	.LBB6_91
[0,143]   .    .    .    .    .    .    .    .    .D===eeeeeE-------------R.    .    .   .   mov	rdx, qword ptr [r14 + 8]
[0,144]   .    .    .    .    .    .    .    .    .D==eE------------------R.    .    .   .   mov	rcx, rsi
[0,145]   .    .    .    .    .    .    .    .    . D=====eE--------------R.    .    .   .   mov	r8, r14
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
0.     10    1.0    1.0    83.7      mov	rax, qword ptr [rsp + 104]
1.     10    6.0    0.0    79.2      mov	rdi, qword ptr [rax + 96]
2.     10    10.1   0.0    78.3      test	rdi, rdi
3.     10    11.1   0.0    77.4      je	.LBB6_28
4.     10    1.0    1.0    82.5      cmp	dword ptr [rsp + 44], 0
5.     10    6.9    0.0    81.5      je	.LBB6_26
6.     10    1.0    1.0    83.4      vmovss	xmm1, dword ptr [rip + .LCPI6_0]
7.     10    5.1    0.0    72.9      vdivss	xmm6, xmm1, xmm0
8.     10    1.0    1.0    83.0      mov	rax, qword ptr [rsp + 104]
9.     10    6.0    0.0    82.0      add	rax, 96
10.    10    10.6   0.9    77.4      mov	qword ptr [rsp + 216], rax
11.    10    1.0    1.0    86.9      lea	rax, [rsi + 40]
12.    10    10.5   0.0    77.4      mov	qword ptr [rsp + 120], rax
13.    10    1.0    1.0    86.0      lea	rax, [rsi + 8]
14.    10    10.6   1.0    76.4      mov	qword ptr [rsp + 240], rax
15.    10    1.0    1.0    86.0      mov	r15d, 1
16.    10    1.0    1.0    82.0      vmovss	xmm7, dword ptr [rip + .LCPI6_1]
17.    10    1.0    1.0    80.9      vmovddup	xmm8, qword ptr [rip + .LCPI6_2]
18.    10    1.9    1.9    80.0      vpbroadcastd	xmm9, dword ptr [rip + .LCPI6_3]
19.    10    0.0    0.0    87.0      vxorps	xmm10, xmm10, xmm10
20.    10    2.9    2.9    78.1      vpbroadcastd	xmm11, dword ptr [rip + .LCPI6_4]
21.    10    2.9    2.9    79.1      vmovss	xmm12, dword ptr [rip + .LCPI6_5]
22.    10    3.9    3.9    77.1      vbroadcastss	xmm14, dword ptr [rip + .LCPI6_0]
23.    10    9.5    0.0    76.4      mov	qword ptr [rsp + 232], r14
24.    10    10.5   1.0    75.4      mov	byte ptr [rsp + 43], 0
25.    10    3.0    3.0    78.0      mov	rax, qword ptr [rsp + 224]
26.    10    9.8    0.0    75.2      mov	dword ptr [rsp + 112], eax
27.    10    6.1    0.0    74.9      mov	edx, dword ptr [rdi + 40]
28.    10    3.9    3.9    77.1      mov	rcx, qword ptr [rsi + 128]
29.    10    0.0    0.0    85.9      xor	eax, eax
30.    10    9.6    0.9    67.5      lock		cmpxchg	dword ptr [rsi + 332], r15d
31.    10    16.6   0.0    66.6      jne	.LBB6_18
32.    10    9.9    0.9    71.3      imul	rax, rdx, 56
33.    10    12.9   0.0    65.7      cmp	dword ptr [rcx + rax], 2
34.    10    18.9   0.0    64.8      jne	.LBB6_39
35.    10    12.9   0.0    66.8      mov	r13, qword ptr [rcx + rax + 8]
36.    10    16.9   0.0    62.1      mov	rdx, qword ptr [r13]
37.    10    16.9   0.0    62.1      mov	r8, qword ptr [r13 + 8]
38.    10    21.9   0.0    61.2      mov	qword ptr [r8], rdx
39.    10    17.9   1.0    61.2      mov	r8, qword ptr [r13 + 8]
40.    10    22.9   0.0    60.3      mov	qword ptr [rdx + 8], r8
41.    10    1.0    1.0    78.2      mov	rdx, qword ptr [rsp + 120]
42.    10    21.9   0.0    60.3      mov	qword ptr [r13 + 8], rdx
43.    10    5.0    0.0    73.2      mov	rdx, qword ptr [rdx]
44.    10    22.9   1.0    59.4      mov	qword ptr [r13], rdx
45.    10    22.9   0.0    59.4      mov	qword ptr [rdx + 8], r13
46.    10    16.9   1.0    61.4      mov	rdx, qword ptr [r13 + 8]
47.    10    23.9   1.0    58.5      mov	qword ptr [rdx], r13
48.    10    10.9   1.0    66.5      mov	rax, qword ptr [rcx + rax + 8]
49.    10    16.9   1.0    59.5      cmp	dword ptr [rax + 56], r14d
50.    10    22.9   0.0    58.5      jae	.LBB6_22
51.    10    22.9   0.0    58.5      mov	dword ptr [rax + 56], r14d
52.    10    22.9   1.0    55.8      mfence
53.    10    25.9   0.0    54.9      mov	dword ptr [rsi + 332], 0
54.    10    25.9   0.0    51.3      mov	eax, dword ptr [rdi + 40]
55.    10    25.9   0.0    51.3      mov	r8, qword ptr [rsi + 128]
56.    10    29.9   0.0    48.6      imul	rcx, rax, 56
57.    10    32.9   0.0    44.1      mov	r11d, dword ptr [r8 + rcx + 40]
58.    10    1.0    1.0    80.0      mov	bpl, 1
59.    10    37.9   0.0    43.2      test	r11d, r11d
60.    10    38.9   0.0    42.3      je	.LBB6_127
61.    10    37.9   0.0    43.3      cmp	r11d, 1
62.    10    37.9   0.0    42.3      jne	.LBB6_66
63.    10    28.9   0.0    51.3      mov	r11d, eax
64.    10    28.9   0.0    51.3      test	eax, eax
65.    10    29.9   0.0    50.3      jne	.LBB6_67
66.    10    0.0    0.0    81.2      xor	r11d, r11d
67.    10    1.0    1.0    79.2      jmp	.LBB6_127
68.    10    27.9   0.0    51.3      add	rax, 1
69.    10    28.9   0.0    50.3      mov	r11d, eax
70.    10    28.9   0.0    48.3      imul	r9, rax, 56
71.    10    0.0    0.0    80.2      xor	ebp, ebp
72.    10    0.0    0.0    80.2      xor	eax, eax
73.    10    30.9   0.0    40.5      lock		cmpxchg	dword ptr [r8 + r9], r15d
74.    10    37.9   0.0    39.6      jne	.LBB6_127
75.    10    21.9   1.0    51.6      mov	rax, qword ptr [rsi]
76.    10    26.9   0.0    45.6      cmp	byte ptr [rax + 80], 1
77.    10    32.9   0.0    44.6      jne	.LBB6_69
78.    10    26.9   1.0    44.6      cmp	byte ptr [rax + 136], 1
79.    10    32.9   0.0    43.6      jne	.LBB6_71
80.    10    26.9   1.0    44.6      cmp	byte ptr [rax + 192], 1
81.    10    33.1   0.2    43.4      jne	.LBB6_73
82.    10    26.9   2.0    43.6      cmp	byte ptr [rax + 248], 0
83.    10    33.9   1.0    41.6      je	.LBB6_75
84.    10    27.9   0.0    47.6      add	r8, r9
85.    10    28.9   0.0    46.6      mov	dword ptr [r8], 0
86.    10    0.0    0.0    76.5      xor	ebp, ebp
87.    10    1.0    1.0    73.5      jmp	.LBB6_127
88.    10    24.9   1.0    49.6      lea	rcx, [rax + 80]
89.    10    0.0    0.0    75.5      xor	edx, edx
90.    10    1.1    1.1    73.4      jmp	.LBB6_76
91.    10    25.9   2.0    48.6      lea	rcx, [rax + 136]
92.    10    1.0    1.0    73.5      mov	edx, 1
93.    10    1.0    1.0    72.5      jmp	.LBB6_76
94.    10    25.0   2.1    48.5      lea	rcx, [rax + 192]
95.    10    1.0    1.0    72.5      mov	edx, 2
96.    10    1.1    1.1    72.4      jmp	.LBB6_76
97.    10    26.0   3.1    47.5      lea	rcx, [rax + 248]
98.    10    1.0    1.0    72.5      mov	edx, 3
99.    10    25.9   0.0    46.6      mov	dword ptr [rsp + 64], r11d
100.   10    1.0    0.0    69.5      imul	rdx, rdx, 56
101.   10    25.9   4.0    46.6      lea	r10, [rax + rdx]
102.   10    26.9   0.0    45.6      add	r10, 32
103.   10    9.8    0.9    45.6      mov	byte ptr [rcx], 1
104.   10    4.8    0.0    46.6      mov	rcx, qword ptr [rax + rdx + 48]
105.   10    9.7    0.0    39.6      add	dword ptr [rax + rdx + 56], 1
106.   10    10.7   0.0    44.6      mov	qword ptr [rsp + 264], r10
107.   10    9.8    0.0    44.6      mov	qword ptr [rax + rdx + 64], r10
108.   10    10.8   1.0    43.6      mov	qword ptr [rax + rdx + 72], rcx
109.   10    7.8    0.1    46.5      lea	rax, [r8 + r9]
110.   10    8.8    0.0    45.5      add	rax, 32
111.   10    10.7   0.0    43.6      mov	qword ptr [rsp + 48], rax
112.   10    7.7    0.0    42.6      mov	edx, dword ptr [r8 + r9 + 32]
113.   10    10.7   1.0    42.6      mov	qword ptr [rsp + 56], r8
114.   10    10.7   0.0    42.6      mov	qword ptr [rsp + 96], r9
115.   10    6.6    0.0    42.6      mov	ecx, dword ptr [r8 + r9 + 36]
116.   10    0.0    0.0    54.2      xor	eax, eax
117.   10    10.7   1.1    35.1      lock		cmpxchg	dword ptr [rsi + 332], r15d
118.   10    17.7   0.0    34.2      jne	.LBB6_77
119.   10    9.6    0.0    42.3      add	edx, edx
120.   10    10.4   0.0    41.3      mov	dword ptr [rsp + 72], edx
121.   10    10.3   0.0    39.3      imul	ecx, edx
122.   10    13.3   0.0    38.3      lea	r15d, [rcx + 79]
123.   10    14.2   0.0    37.3      and	r15d, -16
124.   10    1.5    1.0    45.1      mov	r14, qword ptr [rsi + 16]
125.   10    3.3    1.9    42.2      cmp	r14, qword ptr [rsp + 240]
126.   10    12.2   0.0    38.3      mov	qword ptr [rsp + 272], rcx
127.   10    9.3    0.0    41.2      jne	.LBB6_81
128.   10    0.0    0.0    51.5      xor	r14d, r14d
129.   10    1.0    1.0    48.5      jmp	.LBB6_80
130.   10    3.1    2.9    42.3      mov	r14, qword ptr [r14 + 8]
131.   10    3.0    0.1    41.2      cmp	r14, qword ptr [rsp + 240]
132.   10    9.1    0.1    40.1      je	.LBB6_79
133.   10    7.4    0.4    35.9      test	byte ptr [r14 + 16], 1
134.   10    13.4   0.1    34.8      jne	.LBB6_82
135.   10    10.9   0.0    32.4      cmp	qword ptr [r14 + 24], r15
136.   10    16.8   0.0    31.5      jb	.LBB6_82
137.   10    1.9    1.9    41.5      mov	rax, qword ptr [rsp + 56]
138.   10    1.9    1.9    41.4      mov	rcx, qword ptr [rsp + 96]
139.   10    7.2    0.3    40.1      add	rax, rcx
140.   10    8.1    0.0    39.1      add	rax, 8
141.   10    9.6    0.0    37.5      mov	qword ptr [rsp + 80], rax
142.   10    4.7    4.7    42.4      jmp	.LBB6_91
143.   10    4.9    0.2    37.3      mov	rdx, qword ptr [r14 + 8]
144.   10    2.1    2.1    44.1      mov	rcx, rsi
145.   10    5.1    0.5    41.0      mov	r8, r14
146.   10    5.7    5.7    0.0       call	handmade_asset.MergeIfPossible
147.   10    7.7    0.0    97.0      mov	dword ptr [rbp], 0
148.   10    6.1    2.5    98.5      test	r14, r14
149.   10    6.3    0.1    97.4      je	.LBB6_92
150.   10    4.1    1.4    95.6      mov	rcx, qword ptr [r14 + 24]
151.   10    9.5    0.0    94.2      sub	rcx, r15
152.   10    10.5   0.0    93.2      jae	.LBB6_84
153.   10    1.4    1.4    98.3      mov	rdx, qword ptr [rsi + 48]
154.   10    2.3    2.3    97.3      mov	r14, qword ptr [rsp + 120]
155.   10    6.4    0.0    96.3      cmp	rdx, r14
156.   10    7.4    0.0    95.3      je	.LBB6_104
157.   10    1.4    1.4    97.3      mov	r8, qword ptr [rsi + 128]
158.   10    5.4    0.0    97.3      mov	rax, rdx
159.   10    4.6    4.6    98.0      jmp	.LBB6_107
160.   10    6.3    0.0    92.3      mov	rax, qword ptr [rax + 8]
161.   10    10.4   0.0    91.3      cmp	rax, r14
162.   10    11.4   0.0    90.3      je	.LBB6_106
163.   10    10.3   0.0    87.3      mov	ecx, dword ptr [rax + 48]
164.   10    15.3   0.0    84.3      imul	r10, rcx, 56
165.   10    18.3   0.0    78.3      cmp	dword ptr [r8 + r10], 2
166.   10    23.4   0.0    77.3      jb	.LBB6_112
167.   10    17.4   0.0    83.3      lea	rbp, [r8 + r10]
168.   10    18.3   1.0    82.3      lea	rcx, [r8 + r10]
169.   10    19.3   0.0    81.3      add	rcx, 8
170.   10    1.2    1.2    95.4      mov	r9d, dword ptr [rsi + 336]
171.   10    6.2    0.0    94.4      test	r9, r9
172.   10    6.3    0.0    93.4      je	.LBB6_89
173.   10    16.4   0.0    79.3      mov	r10, qword ptr [r8 + r10 + 8]
174.   10    21.3   0.0    74.3      mov	r10d, dword ptr [r10 + 56]
175.   10    0.0    0.0    100.6     xor	r11d, r11d
176.   10    21.3   0.0    73.3      cmp	dword ptr [rsi + 4*r11 + 340], r10d
177.   10    26.4   0.0    72.3      je	.LBB6_112
178.   10    2.0    2.0    96.7      add	r11, 1
179.   10    5.2    1.0    93.4      cmp	r9, r11
180.   10    6.2    0.0    92.4      jne	.LBB6_110
181.   10    2.6    2.6    96.0      jmp	.LBB6_89
182.   10    1.0    1.0    93.6      mov	rdx, qword ptr [rsi + 48]
183.   10    1.1    1.1    92.6      mov	r14, qword ptr [rsp + 120]
184.   10    6.2    0.1    91.5      cmp	rdx, r14
185.   10    7.1    0.0    90.5      je	.LBB6_93
186.   10    1.9    1.9    91.7      mov	r8, qword ptr [rsi + 128]
187.   10    5.3    0.3    92.3      mov	rax, rdx
188.   10    2.7    2.7    94.9      jmp	.LBB6_96
189.   10    5.4    0.0    87.3      mov	rax, qword ptr [rax + 8]
190.   10    10.4   0.0    86.3      cmp	rax, r14
191.   10    11.3   0.0    85.3      je	.LBB6_95
192.   10    10.3   0.0    82.3      mov	ecx, dword ptr [rax + 48]
193.   10    16.2   0.9    78.4      imul	r10, rcx, 56
194.   10    18.4   0.1    72.3      cmp	dword ptr [r8 + r10], 2
195.   10    24.4   0.0    71.3      jb	.LBB6_101
196.   10    18.2   0.0    77.4      lea	rbp, [r8 + r10]
197.   10    19.1   0.9    76.5      lea	rcx, [r8 + r10]
198.   10    20.1   0.0    75.5      add	rcx, 8
199.   10    1.0    1.0    89.7      mov	r9d, dword ptr [rsi + 336]
200.   10    6.0    0.0    88.7      test	r9, r9
201.   10    7.0    0.0    87.7      je	.LBB6_89
202.   10    17.3   0.1    73.3      mov	r10, qword ptr [r8 + r10 + 8]
203.   10    22.3   0.0    68.3      mov	r10d, dword ptr [r10 + 56]
204.   10    0.0    0.0    95.6      xor	r11d, r11d
205.   10    21.4   0.0    67.3      cmp	dword ptr [rsi + 4*r11 + 340], r10d
206.   10    27.4   0.0    66.3      je	.LBB6_101
207.   10    1.4    1.4    92.2      add	r11, 1
208.   10    5.1    0.0    88.5      cmp	r9, r11
209.   10    6.1    0.0    87.5      jne	.LBB6_99
210.   10    6.4    0.0    82.3      mov	rdx, qword ptr [rax]
211.   10    7.4    1.0    81.3      mov	r8, qword ptr [rax + 8]
212.   10    20.4   0.0    72.3      mov	qword ptr [r8], rdx
213.   10    7.3    1.0    81.3      mov	rax, qword ptr [rax + 8]
214.   10    20.3   0.0    72.3      mov	qword ptr [rdx + 8], rax
215.   10    18.1   0.0    70.5      mov	rax, qword ptr [rcx]
216.   10    22.2   0.0    69.5      lea	r14, [rax - 32]
217.   10    22.2   0.0    69.5      mov	qword ptr [rax - 16], 0
218.   10    22.2   0.0    65.5      mov	rdx, qword ptr [rax - 32]
219.   10    1.3    1.3    90.3      mov	rcx, rsi
220.   10    23.1   0.0    68.5      mov	r8, r14
221.   10    1.4    1.4    0.0       call	handmade_asset.MergeIfPossible
222.   10    21.1   0.0    79.2      test	al, 1
223.   10    22.1   0.0    78.2      je	.LBB6_90
224.   10    21.2   0.0    74.2      mov	r14, qword ptr [r14]
225.   10    1.4    1.4    98.0      jmp	.LBB6_90
226.   10    26.2   0.0    73.2      mov	qword ptr [r14 + 16], 1
227.   10    26.2   0.0    73.2      lea	rax, [r14 + 32]
228.   10    1.2    0.9    98.1      cmp	rcx, 4097
229.   10    3.2    1.0    96.1      jb	.LBB6_86
230.   10    25.2   0.0    73.2      mov	qword ptr [r14 + 24], r15
231.   10    26.2   0.0    72.2      lea	rdx, [rax + r15]
232.   10    26.2   1.0    72.2      mov	qword ptr [r14 + r15 + 48], 0
233.   10    1.3    1.0    97.1      add	rcx, -32
234.   10    26.1   0.0    72.2      mov	qword ptr [r14 + r15 + 56], rcx
235.   10    27.1   1.0    71.2      mov	qword ptr [r14 + r15 + 32], r14
236.   10    24.2   0.0    69.2      mov	rcx, qword ptr [r14 + 8]
237.   10    29.2   0.0    68.2      mov	qword ptr [r14 + r15 + 40], rcx
238.   10    29.2   0.0    68.2      mov	qword ptr [r14 + 8], rdx
239.   10    30.2   1.0    67.2      mov	qword ptr [rcx], rdx
240.   10    2.8    2.8    90.5      mov	ecx, dword ptr [rsp + 64]
241.   10    30.1   0.0    67.2      mov	dword ptr [r14 + 80], ecx
242.   10    30.2   1.0    66.2      mov	dword ptr [r14 + 84], r15d
243.   10    1.9    1.9    90.5      mov	rcx, qword ptr [rsp + 120]
244.   10    30.2   0.0    66.2      mov	qword ptr [r14 + 40], rcx
245.   10    3.8    3.8    88.6      mov	rcx, qword ptr [rsi + 40]
246.   10    31.1   1.0    65.2      mov	qword ptr [r14 + 32], rcx
247.   10    31.1   0.0    65.2      mov	qword ptr [rcx + 8], rax
248.   10    22.2   0.0    69.2      mov	rcx, qword ptr [r14 + 40]
249.   10    31.2   1.0    64.2      mov	qword ptr [rcx], rax
250.   10    31.1   0.0    62.2      mfence
251.   10    34.1   0.0    61.2      mov	dword ptr [rsi + 332], 0
252.   10    33.2   0.0    57.2      mov	r11, qword ptr [rsp + 80]
253.   10    38.2   0.0    56.2      mov	qword ptr [r11], rax
254.   10    33.2   0.1    57.1      mov	rcx, qword ptr [rsp + 48]
255.   10    38.2   0.0    52.1      mov	eax, dword ptr [rcx]
256.   10    43.1   0.0    51.1      mov	dword ptr [r14 + 64], eax
257.   10    38.1   0.0    52.1      mov	ecx, dword ptr [rcx + 4]
258.   10    42.2   0.0    51.1      mov	dword ptr [r14 + 68], ecx
259.   10    38.0   0.9    51.3      mov	rbp, qword ptr [r11]
260.   10    42.9   0.0    50.3      add	rbp, 64
261.   10    42.1   0.0    51.1      test	rcx, rcx
262.   10    43.1   0.0    50.1      je	.LBB6_126
263.   10    32.7   0.9    56.3      mov	edx, dword ptr [rsp + 72]
264.   10    41.0   0.0    51.1      cmp	ecx, 8
265.   10    42.9   0.9    49.2      jae	.LBB6_114
266.   10    0.0    0.0    93.1      xor	r8d, r8d
267.   10    42.7   0.0    49.3      mov	rax, rbp
268.   10    39.9   0.0    51.1      and	ecx, 7
269.   10    41.0   1.0    49.1      jne	.LBB6_124
270.   10    1.1    1.1    86.9      jmp	.LBB6_126
271.   10    32.7   0.0    55.3      lea	r8, [rdx + rdx]
272.   10    37.0   0.0    50.1      lea	rax, [rcx - 8]
273.   10    38.0   0.0    49.1      cmp	rax, 8
274.   10    38.9   0.0    48.1      jae	.LBB6_117
275.   10    38.7   1.0    48.3      mov	r10, rbp
276.   10    0.0    0.0    88.0      xor	r11d, r11d
277.   10    1.0    1.0    86.0      jmp	.LBB6_120
278.   10    37.0   0.0    49.1      mov	qword ptr [rsp + 248], rax
279.   10    37.8   0.9    48.2      mov	r15, rax
280.   10    37.9   0.0    47.2      shr	r15, 3
281.   10    38.0   0.0    46.2      add	r15, 1
282.   10    36.8   0.0    45.2      and	r15, -2
283.   10    10.5   0.0    55.3      mov	rax, rdx
284.   10    11.5   0.0    54.3      shl	rax, 5
285.   10    12.5   0.0    53.3      sub	rax, r8
286.   10    16.7   0.0    49.1      mov	qword ptr [rsp + 72], rax
287.   10    10.5   0.1    55.2      lea	rax, [rdx + 8*rdx]
288.   10    11.5   0.0    54.2      lea	rax, [rax + 2*rax]
289.   10    11.6   0.0    53.2      add	rax, rdx
290.   10    16.7   1.0    48.1      mov	qword ptr [rsp + 208], rax
291.   10    10.5   1.0    54.3      lea	rax, [rdx + 4*rdx]
292.   10    11.4   0.0    53.3      lea	r9, [rax + 4*rax]
293.   10    12.4   0.0    52.3      add	r9, rdx
294.   10    16.6   0.0    48.1      mov	qword ptr [rsp + 200], r9
295.   10    11.1   3.0    52.3      lea	r9, [8*rdx]
296.   10    16.2   1.0    47.1      mov	qword ptr [rsp + 192], r9
297.   10    12.0   0.0    51.3      lea	r9, [r9 + 2*r9]
298.   10    16.2   0.0    47.1      mov	qword ptr [rsp + 184], r9
299.   10    14.8   4.8    48.5      lea	rax, [r8 + 4*rax]
300.   10    17.2   1.0    46.1      mov	qword ptr [rsp + 176], rax
301.   10    11.9   4.9    50.4      lea	rax, [4*rdx]
302.   10    14.7   1.8    47.6      lea	r9, [rax + 4*rax]
303.   10    16.2   0.0    46.1      mov	qword ptr [rsp + 160], r9
304.   10    14.9   7.0    47.3      lea	r9, [r8 + 8*r8]
305.   10    16.8   1.0    45.1      mov	qword ptr [rsp + 88], r9
306.   10    6.6    0.0    55.3      mov	r10, rdx
307.   10    6.6    0.0    54.3      shl	r10, 4
308.   10    7.6    0.0    53.3      mov	r9, r10
309.   10    15.7   0.0    45.1      mov	qword ptr [rsp + 48], r10
310.   10    8.5    1.0    52.3      sub	r10, r8
311.   10    16.6   1.0    44.1      mov	qword ptr [rsp + 152], r10
312.   10    16.6   0.0    44.1      mov	qword ptr [rsp + 168], rax
313.   10    13.4   3.1    46.3      lea	rax, [rax + 2*rax]
314.   10    16.6   1.0    43.1      mov	qword ptr [rsp + 144], rax
315.   10    13.2   8.1    46.2      lea	rax, [r8 + 4*r8]
316.   10    16.3   0.0    43.1      mov	qword ptr [rsp + 136], rax
317.   10    14.1   9.0    45.3      lea	rax, [r8 + 2*r8]
318.   10    17.2   1.0    42.1      mov	qword ptr [rsp + 128], rax
319.   10    14.1   0.0    42.1      mov	qword ptr [rsp + 256], rbp
320.   10    9.0    2.1    47.2      mov	r10, rbp
321.   10    0.0    0.0    57.2      xor	r11d, r11d
322.   10    15.1   1.0    41.1      mov	qword ptr [r14 + 8*r11 + 48], r10
323.   10    10.1   1.0    45.2      lea	rax, [r10 + r8]
324.   10    14.2   0.0    41.1      mov	qword ptr [r14 + 8*r11 + 56], rax
325.   10    11.0   0.0    44.2      add	rax, r8
326.   10    1.0    1.0    50.2      mov	r9, qword ptr [rsp + 168]
327.   10    10.9   1.9    44.3      lea	rbp, [r10 + r9]
328.   10    14.2   1.0    40.1      mov	qword ptr [r14 + 8*r11 + 64], rbp
329.   10    1.0    1.0    49.3      mov	r9, qword ptr [rsp + 128]
330.   10    10.1   2.0    44.2      lea	rbp, [r10 + r9]
331.   10    14.1   0.0    40.1      mov	qword ptr [r14 + 8*r11 + 72], rbp
332.   10    10.9   10.9   43.3      lea	rbp, [r8 + r8]
333.   10    1.0    1.0    48.3      mov	r9, qword ptr [rsp + 192]
334.   10    7.1    0.0    46.2      add	r9, r10
335.   10    14.2   1.0    39.1      mov	qword ptr [r14 + 8*r11 + 80], r9
336.   10    1.0    1.0    48.3      mov	r9, qword ptr [rsp + 136]
337.   10    10.0   3.0    43.2      lea	r9, [r10 + r9]
338.   10    13.2   0.0    39.1      mov	qword ptr [r14 + 8*r11 + 88], r9
339.   10    1.0    1.0    47.3      mov	r9, qword ptr [rsp + 144]
340.   10    10.0   3.9    42.3      lea	r9, [r10 + r9]
341.   10    14.2   1.0    38.1      mov	qword ptr [r14 + 8*r11 + 96], r9
342.   10    1.0    1.0    47.3      mov	r9, qword ptr [rsp + 152]
343.   10    9.1    4.0    42.2      lea	r9, [r10 + r9]
344.   10    13.2   0.0    38.1      mov	qword ptr [r14 + 8*r11 + 104], r9
345.   10    1.0    1.0    46.3      mov	r9, qword ptr [rsp + 48]
346.   10    10.0   4.0    41.3      lea	r9, [r10 + r9]
347.   10    14.1   1.0    37.1      mov	qword ptr [r14 + 8*r11 + 112], r9
348.   10    1.0    1.0    46.2      mov	r9, qword ptr [rsp + 88]
349.   10    9.1    4.0    41.2      lea	r9, [r10 + r9]
350.   10    13.2   0.0    37.1      mov	qword ptr [r14 + 8*r11 + 120], r9
351.   10    1.0    1.0    45.2      mov	r9, qword ptr [rsp + 160]
352.   10    9.9    3.9    40.3      lea	r9, [r10 + r9]
353.   10    14.1   1.0    36.1      mov	qword ptr [r14 + 8*r11 + 128], r9
354.   10    1.0    1.0    45.2      mov	r9, qword ptr [rsp + 176]
355.   10    5.1    0.0    44.2      add	r9, r10
356.   10    13.2   0.0    36.1      mov	qword ptr [r14 + 8*r11 + 136], r9
357.   10    1.0    1.0    44.2      mov	r9, qword ptr [rsp + 184]
358.   10    6.0    0.0    43.2      add	r9, r10
359.   10    14.1   1.0    35.1      mov	qword ptr [r14 + 8*r11 + 144], r9
360.   10    1.0    1.0    44.2      mov	r9, qword ptr [rsp + 200]
361.   10    5.1    0.0    43.2      add	r9, r10
362.   10    13.2   0.0    35.1      mov	qword ptr [r14 + 8*r11 + 152], r9
363.   10    8.0    2.1    40.2      lea	r9, [r8 + rbp]
364.   10    9.0    0.0    39.2      add	rax, r9
365.   10    9.0    0.0    39.2      add	r9, r8
366.   10    10.0   0.0    38.2      add	rax, r9
367.   10    9.1    0.0    38.2      add	r9, r8
368.   10    10.1   0.0    37.2      add	r9, rax
369.   10    1.0    1.0    42.2      mov	rax, qword ptr [rsp + 208]
370.   10    6.0    0.0    41.2      add	rax, r10
371.   10    13.1   1.0    34.1      mov	qword ptr [r14 + 8*r11 + 160], rax
372.   10    1.1    1.1    40.2      add	r10, qword ptr [rsp + 72]
373.   10    12.2   0.0    34.1      mov	qword ptr [r14 + 8*r11 + 168], r10
374.   10    10.0   0.0    36.2      mov	r10, r9
375.   10    11.0   0.0    35.2      add	r10, rbp
376.   10    4.0    4.0    42.2      add	r11, 16
377.   10    3.1    2.0    42.2      add	r15, -2
378.   10    4.1    0.0    41.2      jne	.LBB6_118
379.   10    11.1   0.0    34.2      mov	r15, r10
380.   10    11.0   0.0    29.2      sub	r15, qword ptr [rsp + 48]
381.   10    1.0    1.0    40.2      mov	rbp, qword ptr [rsp + 256]
382.   10    1.0    1.0    39.3      mov	rax, qword ptr [rsp + 248]
383.   10    6.0    0.0    38.3      test	al, 8
384.   10    7.1    0.1    37.2      jne	.LBB6_122
385.   10    11.1   1.0    33.1      mov	qword ptr [r14 + 8*r11 + 48], r10
386.   10    10.1   0.1    34.1      lea	rax, [r10 + r8]
387.   10    11.1   0.0    33.1      mov	qword ptr [r14 + 8*r11 + 56], rax
388.   10    10.2   0.0    33.1      add	rax, r8
389.   10    11.2   0.0    32.1      mov	qword ptr [r14 + 8*r11 + 64], rax
390.   10    11.2   0.0    32.1      add	rax, r8
391.   10    12.1   0.0    31.1      mov	qword ptr [r14 + 8*r11 + 72], rax
392.   10    12.1   0.0    31.1      add	rax, r8
393.   10    13.1   0.0    30.1      mov	qword ptr [r14 + 8*r11 + 80], rax
394.   10    12.2   0.0    30.1      add	rax, r8
395.   10    13.2   0.0    29.1      mov	qword ptr [r14 + 8*r11 + 88], rax
396.   10    13.2   0.0    29.1      add	rax, r8
397.   10    14.1   0.0    28.1      mov	qword ptr [r14 + 8*r11 + 96], rax
398.   10    14.1   0.0    28.1      add	rax, r8
399.   10    15.1   0.0    27.1      mov	qword ptr [r14 + 8*r11 + 104], rax
400.   10    7.1    0.0    34.2      mov	r15, r10
401.   10    1.1    1.1    40.2      mov	r8d, ecx
402.   10    2.1    0.0    39.2      and	r8d, -8
403.   10    1.0    1.0    40.2      mov	rax, rdx
404.   10    5.0    3.0    36.2      shl	rax, 4
405.   10    8.0    0.0    33.2      add	rax, r15
406.   10    1.0    1.0    35.3      mov	r11, qword ptr [rsp + 80]
407.   10    1.0    1.0    39.3      and	ecx, 7
408.   10    5.1    3.1    35.2      je	.LBB6_126
409.   10    2.0    0.0    38.2      lea	r8, [r14 + 8*r8]
410.   10    3.0    0.0    37.2      add	r8, 48
411.   10    2.9    2.9    37.3      add	rdx, rdx
412.   10    0.0    0.0    40.3      xor	r9d, r9d
413.   10    12.2   0.0    27.1      mov	qword ptr [r8 + 8*r9], rax
414.   10    3.0    3.0    36.3      add	r9, 1
415.   10    7.0    0.0    32.2      add	rax, rdx
416.   10    3.9    0.0    35.3      cmp	rcx, r9
417.   10    5.9    1.0    33.3      jne	.LBB6_125
418.   10    1.0    1.0    33.3      mov	r10, qword ptr [rsp + 264]
419.   10    6.0    0.0    28.3      mov	rcx, qword ptr [r10 + 16]
420.   10    6.0    0.0    28.3      mov	rax, qword ptr [r10 + 8]
421.   10    10.9   0.0    27.3      add	rax, rcx
422.   10    11.9   0.0    26.3      mov	edx, eax
423.   10    12.9   0.0    25.3      and	edx, 7
424.   10    1.1    1.1    36.2      mov	r9d, 8
425.   10    13.0   0.0    24.3      sub	r9, rdx
426.   10    13.0   0.0    24.3      test	rdx, rdx
427.   10    13.9   0.0    23.3      cmove	r9, rdx
428.   10    14.9   0.0    22.3      lea	rcx, [rcx + r9 + 56]
429.   10    14.9   0.0    22.3      lea	r8, [r9 + rax]
430.   10    15.0   0.0    21.3      mov	qword ptr [r10 + 16], rcx
431.   10    15.0   0.0    21.3      mov	qword ptr [r9 + rax], r10
432.   10    1.0    1.0    31.3      mov	rcx, qword ptr [rsi + 128]
433.   10    1.0    1.0    31.2      mov	rdx, qword ptr [rsp + 96]
434.   10    6.0    0.0    30.2      add	rcx, rdx
435.   10    15.9   1.0    20.3      mov	qword ptr [r9 + rax + 8], rcx
436.   10    1.0    1.0    30.3      mov	rcx, qword ptr [rsp + 56]
437.   10    6.0    0.0    25.3      mov	ecx, dword ptr [rcx + rdx + 52]
438.   10    11.9   0.9    21.4      imul	rcx, rcx, 88
439.   10    11.8   0.0    18.4      add	rcx, qword ptr [rsi + 104]
440.   10    17.8   0.0    17.4      mov	qword ptr [r9 + rax + 16], rcx
441.   10    1.0    1.0    29.3      mov	rcx, qword ptr [r11 + 8]
442.   10    16.9   0.0    17.4      mov	qword ptr [r9 + rax + 24], rcx
443.   10    1.2    1.2    29.1      mov	ecx, dword ptr [rsp + 272]
444.   10    17.8   1.0    16.4      mov	qword ptr [r9 + rax + 32], rcx
445.   10    17.8   0.0    16.4      mov	qword ptr [r9 + rax + 40], rbp
446.   10    18.8   1.0    15.4      mov	dword ptr [r9 + rax + 48], 2
447.   10    17.9   0.0    15.4      mov	byte ptr [r9 + rax + 52], 0
448.   10    2.0    2.0    27.3      mov	rax, qword ptr [rsi]
449.   10    7.0    0.0    22.3      mov	rcx, qword ptr [rax + 288]
450.   10    1.9    1.9    31.3      lea	rdx, [rip + handmade_asset.LoadAssetWork]
451.   10    1.1    1.1    0.0       call	qword ptr [rip + handmade_data.platformAPI]
452.   10    0.0    0.0    101.0     xor	ebp, ebp
453.   10    1.0    1.0    94.1      mov	r11d, dword ptr [rsp + 64]
454.   10    1.1    1.1    93.0      vbroadcastss	xmm5, dword ptr [rdi + 8]
455.   10    2.1    2.1    92.0      vbroadcastss	xmm1, dword ptr [rdi + 12]
456.   10    3.0    3.0    92.1      vmovss	xmm2, dword ptr [rdi + 32]
457.   10    3.1    3.1    92.0      vmovd	xmm0, dword ptr [rdi + 36]
458.   10    8.8    0.9    87.2      vmulss	xmm17, xmm2, xmm7
459.   10    3.0    3.0    91.1      mov	rax, qword ptr [rsp + 104]
460.   10    8.0    0.0    86.1      vmovss	xmm3, dword ptr [rax + 112]
461.   10    3.1    3.1    87.0      vmulss	xmm19, xmm6, dword ptr [rdi + 16]
462.   10    8.0    0.0    86.1      vmovss	xmm4, dword ptr [rax + 116]
463.   10    12.0   0.0    83.0      vmulss	xmm16, xmm19, xmm7
464.   10    3.1    3.1    86.0      vmulss	xmm18, xmm6, dword ptr [rdi + 20]
465.   10    4.0    4.0    89.1      mov	eax, dword ptr [r13 + 32]
466.   10    1.0    1.0    96.1      vmovdqa64	xmm20, xmm11
467.   10    6.1    0.0    91.0      vpternlogd	xmm20, xmm0, xmm9, 248
468.   10    7.9    0.9    86.1      vaddss	xmm20, xmm0, xmm20
469.   10    11.0   0.0    78.1      vrndscaless	xmm20, xmm20, xmm20, 11
470.   10    19.0   0.0    72.1      vcvttss2usi	edx, xmm20
471.   10    25.0   0.0    71.1      sub	eax, edx
472.   10    25.0   0.0    66.1      vcvtusi2ss	xmm20, xmm23, eax
473.   10    30.0   0.0    55.1      vdivss	xmm20, xmm20, xmm17
474.   10    1.0    1.0    74.5      vmovdqa64	xmm21, xmm11
475.   10    21.4   0.0    54.1      vpternlogd	xmm21, xmm20, xmm9, 248
476.   10    22.4   0.0    50.1      vaddss	xmm20, xmm20, xmm21
477.   10    26.4   0.0    42.1      vrndscaless	xmm20, xmm20, xmm20, 11
478.   10    33.4   0.0    36.1      vcvttss2usi	eax, xmm20
479.   10    1.0    1.0    69.5      mov	ecx, dword ptr [rsp + 112]
480.   10    39.4   0.0    35.1      cmp	ecx, eax
481.   10    39.4   0.0    35.1      mov	r10d, eax
482.   10    40.4   0.0    34.1      cmovb	r10d, ecx
483.   10    0.0    0.0    74.5      xor	edx, edx
484.   10    1.0    1.0    71.5      vucomiss	xmm16, xmm10
485.   10    3.0    0.0    70.5      jne	.LBB6_147
486.   10    4.0    1.0    69.5      jnp	.LBB6_128
487.   10    1.0    1.0    66.5      vmovss	xmm20, dword ptr [rdi + 24]
488.   10    7.0    0.0    62.5      vsubss	xmm20, xmm20, xmm5
489.   10    11.0   0.0    51.5      vdivss	xmm20, xmm20, xmm16
490.   10    22.0   0.0    47.5      vaddss	xmm20, xmm20, xmm12
491.   10    26.0   0.0    41.5      vcvttss2usi	r9d, xmm20
492.   10    39.4   0.0    33.1      cmp	r10d, r9d
493.   10    1.0    1.0    70.5      mov	r8d, 0
494.   10    39.4   0.0    31.1      cmova	r8d, r9d
495.   10    39.4   0.0    32.1      cmovae	r10d, r9d
496.   10    1.1    1.1    67.4      vmulss	xmm20, xmm18, xmm7
497.   10    5.1    0.0    65.4      vucomiss	xmm20, xmm10
498.   10    6.1    0.0    64.4      jne	.LBB6_130
499.   10    7.0    0.9    63.5      jnp	.LBB6_131
500.   10    1.9    1.9    62.6      vmovss	xmm21, dword ptr [rdi + 28]
501.   10    8.9    0.0    58.6      vsubss	xmm21, xmm21, xmm1
502.   10    13.0   0.1    47.5      vdivss	xmm21, xmm21, xmm20
503.   10    23.2   0.2    43.3      vaddss	xmm21, xmm21, xmm12
504.   10    27.2   0.0    37.3      vcvttss2usi	r9d, xmm21
505.   10    38.6   0.0    30.9      cmp	r10d, r9d
506.   10    1.0    1.0    68.5      mov	edx, 0
507.   10    38.6   0.0    28.9      cmova	edx, r9d
508.   10    38.6   0.0    29.9      cmovae	r10d, r9d
509.   10    1.0    1.0    67.5      mov	dword ptr [rsp + 56], ebp
510.   10    1.0    0.0    67.5      mov	dword ptr [rsp + 64], r11d
511.   10    1.0    1.0    64.5      vmulss	xmm13, xmm19, xmm10
512.   10    1.0    1.0    64.5      vbroadcastss	xmm15, xmm19
513.   10    4.0    0.0    60.5      vmulps	xmm19, xmm15, xmm8
514.   10    4.0    0.0    63.5      vblendps	xmm13, xmm13, xmm15, 2
515.   10    8.0    0.0    59.5      vmovlhps	xmm19, xmm13, xmm19
516.   10    9.0    0.0    55.5      vaddps	xmm5, xmm5, xmm19
517.   10    1.0    1.0    63.5      vmulss	xmm13, xmm18, xmm10
518.   10    1.0    1.0    63.5      vbroadcastss	xmm15, xmm18
519.   10    4.0    0.0    59.5      vmulps	xmm18, xmm15, xmm8
520.   10    4.0    0.0    62.5      vblendps	xmm13, xmm13, xmm15, 2
521.   10    8.0    0.0    58.5      vmovlhps	xmm18, xmm13, xmm18
522.   10    9.0    0.0    54.5      vaddps	xmm15, xmm1, xmm18
523.   10    37.5   0.9    24.0      vcvtusi2ss	xmm18, xmm23, r10d
524.   10    42.5   0.0    20.0      vmulss	xmm1, xmm17, xmm18
525.   10    46.5   0.0    16.0      vaddss	xmm1, xmm0, xmm1
526.   10    36.6   0.0    28.9      mov	r9d, r10d
527.   10    36.7   0.1    28.8      test	r10d, r10d
528.   10    36.7   0.0    27.8      je	.LBB6_134
529.   10    2.1    2.1    62.4      vbroadcastss	xmm3, xmm3
530.   10    3.0    3.0    59.5      vbroadcastss	xmm16, xmm16
531.   10    4.0    4.0    60.5      vbroadcastss	xmm4, xmm4
532.   10    4.0    4.0    58.5      vbroadcastss	xmm17, xmm20
533.   10    49.5   0.0    12.0      vsubss	xmm19, xmm1, xmm0
534.   10    52.5   0.0    1.0       vdivss	xmm18, xmm19, xmm18
535.   10    3.0    3.0    57.5      vmulss	xmm13, xmm10, xmm2
536.   10    4.2    4.2    59.3      vbroadcastss	xmm2, xmm2
537.   10    4.3    0.1    50.2      vmulps	xmm19, xmm2, xmmword ptr [rip + .LCPI6_6]
538.   10    7.0    0.0    56.5      vblendps	xmm2, xmm13, xmm2, 2
539.   10    13.3   0.0    49.2      vmovlhps	xmm2, xmm2, xmm19
540.   10    34.6   0.0    27.9      mov	r10, r9
541.   10    35.6   0.0    26.9      shl	r10, 4
542.   10    0.0    0.0    63.5      xor	r11d, r11d
543.   10    0.0    0.0    63.5      xor	r14d, r14d
544.   10    5.1    5.1    51.4      vcvtusi2ss	xmm19, xmm23, r14
545.   10    61.5   0.0    0.0       vmulss	xmm19, xmm18, xmm19
546.   10    65.5   0.0    0.0       vaddss	xmm19, xmm0, xmm19
547.   10    69.5   0.0    0.0       vbroadcastss	xmm19, xmm19
548.   10    71.5   0.0    0.0       vaddps	xmm19, xmm2, xmm19
549.   10    75.5   0.0    0.0       vcvttps2dq	xmm20, xmm19
550.   10    1.0    1.0    73.5      mov	r15, qword ptr [r13 + 16]
551.   10    79.5   0.0    0.0       vmovd	ebp, xmm20
552.   10    81.5   0.0    0.0       movsxd	rbp, ebp
553.   10    82.5   0.0    0.0       movsx	ecx, word ptr [r15 + 2*rbp]
554.   10    86.5   0.0    0.0       vcvtsi2ss	xmm21, xmm23, ecx
555.   10    78.5   0.0    9.0       vcvtdq2ps	xmm20, xmm20
556.   10    82.5   0.0    5.0       vsubps	xmm19, xmm19, xmm20
557.   10    81.5   0.0    5.0       movsx	ecx, word ptr [r15 + 2*rbp + 2]
558.   10    91.5   0.0    0.0       vbroadcastss	xmm20, xmm21
559.   10    86.5   1.0    2.0       vcvtsi2ss	xmm21, xmm23, ecx
560.   10    91.5   0.0    0.0       vbroadcastss	xmm21, xmm21
561.   10    85.5   0.0    5.0       vsubps	xmm22, xmm14, xmm19
562.   10    93.5   0.0    0.0       vmulps	xmm20, xmm20, xmm22
563.   10    94.5   0.0    0.0       vmulps	xmm19, xmm21, xmm19
564.   10    97.5   0.0    0.0       vaddps	xmm19, xmm19, xmm20
565.   10    3.0    0.0    94.5      vmulps	xmm20, xmm3, xmm5
566.   10    101.5  0.0    0.0       vmulps	xmm20, xmm20, xmm19
567.   10    101.5  0.0    0.0       vaddps	xmm20, xmm20, xmmword ptr [r12 + r11]
568.   10    4.0    0.0    103.5     vmulps	xmm21, xmm4, xmm15
569.   10    101.5  1.0    5.0       vmulps	xmm19, xmm21, xmm19
570.   10    101.5  0.0    0.0       vaddps	xmm19, xmm19, xmmword ptr [rbx + r11]
571.   10    110.5  0.0    0.0       vmovaps	xmmword ptr [r12 + r11], xmm20
572.   10    2.2    0.2    105.3     vaddps	xmm5, xmm16, xmm5
573.   10    110.5  0.0    0.0       vmovaps	xmmword ptr [rbx + r11], xmm19
574.   10    3.0    1.0    104.5     vaddps	xmm15, xmm17, xmm15
575.   10    1.0    1.0    109.5     add	r14, 1
576.   10    1.1    1.1    109.4     add	r11, 16
577.   10    29.6   0.0    80.9      cmp	r10, r11
578.   10    29.6   0.0    79.9      jne	.LBB6_133
579.   10    6.0    0.0    103.5     vblendps	xmm0, xmm5, xmm15, 2
580.   10    109.5  0.0    0.0       vmovlps	qword ptr [rdi + 8], xmm0
581.   10    27.5   0.9    82.0      cmp	r8d, r9d
582.   10    27.7   0.1    80.9      je	.LBB6_148
583.   10    26.5   0.9    82.0      cmp	edx, r9d
584.   10    1.0    1.0    102.6     mov	r14, qword ptr [rsp + 232]
585.   10    1.0    1.0    106.5     mov	r15d, 1
586.   10    26.7   1.1    79.9      je	.LBB6_136
587.   10    107.6  1.0    0.0       vmovss	dword ptr [rdi + 36], xmm1
588.   10    23.7   1.0    82.9      cmp	r9d, eax
589.   10    25.7   2.0    79.9      je	.LBB6_140
590.   10    1.0    1.0    103.5     jmp	.LBB6_138
591.   10    1.0    1.0    99.4      vmovss	xmm0, dword ptr [rdi + 24]
592.   10    103.4  0.0    0.0       vmovss	dword ptr [rdi + 8], xmm0
593.   10    104.4  1.0    0.0       mov	dword ptr [rdi + 16], 0
594.   10    20.5   1.9    83.0      cmp	edx, r9d
595.   10    1.0    1.0    98.5      mov	r14, qword ptr [rsp + 232]
596.   10    1.0    1.0    101.5     mov	r15d, 1
597.   10    20.6   1.1    80.9      jne	.LBB6_137
598.   10    1.0    1.0    94.7      vmovss	xmm0, dword ptr [rdi + 28]
599.   10    98.7   0.0    0.0       vmovss	dword ptr [rdi + 12], xmm0
600.   10    98.5   1.0    0.0       mov	dword ptr [rdi + 20], 0
601.   10    93.1   0.0    0.0       vmovss	dword ptr [rdi + 36], xmm1
602.   10    9.2    2.0    83.9      cmp	r9d, eax
603.   10    11.2   2.0    80.9      jne	.LBB6_138
604.   10    1.0    1.0    85.1      cmp	byte ptr [rsp + 56], 0
605.   10    9.2    3.2    80.9      jne	.LBB6_143
606.   10    1.0    1.0    85.1      mov	eax, dword ptr [rsp + 64]
607.   10    91.1   1.0    0.0       mov	dword ptr [rdi + 40], eax
608.   10    1.0    1.0    81.1      vcvtusi2ss	xmm0, xmm23, dword ptr [r13 + 32]
609.   10    16.0   0.0    71.0      vsubss	xmm0, xmm1, xmm0
610.   10    89.0   0.0    0.0       vmovss	dword ptr [rdi + 36], xmm0
611.   10    19.9   1.0    68.0      vucomiss	xmm10, xmm0
612.   10    21.9   0.0    67.0      jbe	.LBB6_138
613.   10    88.9   1.0    0.0       mov	dword ptr [rdi + 36], 0
614.   10    1.0    1.0    83.9      movzx	eax, byte ptr [rsp + 43]
615.   10    87.9   0.0    0.0       sub	dword ptr [rsp + 112], r9d
616.   10    94.9   0.0    0.0       je	.LBB6_37
617.   10    5.0    0.0    89.9      test	al, 1
618.   10    6.0    0.0    88.9      je	.LBB6_17
619.   10    5.0    5.0    88.9      jmp	.LBB6_37
620.   10    0.0    0.0    94.9      xor	r8d, r8d
621.   10    26.9   0.0    64.0      vmulss	xmm20, xmm18, xmm7
622.   10    30.9   0.0    62.0      vucomiss	xmm20, xmm10
623.   10    32.9   0.0    61.0      jne	.LBB6_130
624.   10    32.0   0.0    61.0      jp	.LBB6_130
625.   10    5.0    5.0    87.9      jmp	.LBB6_131
626.   10    86.9   1.0    4.0       mfence
627.   10    89.9   0.0    3.0       mov	dword ptr [rsi + 332], 0
628.   10    88.9   0.0    0.0       mov	eax, dword ptr [rdi + 40]
629.   10    93.9   0.0    0.0       test	rax, rax
630.   10    93.9   0.0    0.0       je	.LBB6_65
631.   10    88.9   1.0    1.0       mov	r13, qword ptr [rsi + 128]
632.   10    92.0   0.0    0.0       imul	r9, rax, 56
633.   10    0.0    0.0    95.0      xor	eax, eax
634.   10    94.0   0.0    0.0       lock		cmpxchg	dword ptr [r13 + r9], r15d
635.   10    101.0  0.0    0.0       jne	.LBB6_65
636.   10    85.0   0.0    12.0      mov	rax, qword ptr [rsi]
637.   10    90.0   0.0    6.0       cmp	byte ptr [rax + 80], 1
638.   10    96.0   0.0    5.0       jne	.LBB6_42
639.   10    89.0   0.0    6.0       cmp	byte ptr [rax + 136], 1
640.   10    94.0   0.0    5.0       jne	.LBB6_44
641.   10    85.0   1.0    5.0       cmp	byte ptr [rax + 192], 1
642.   10    91.0   0.0    4.0       jne	.LBB6_46
643.   10    81.0   1.0    5.0       cmp	byte ptr [rax + 248], 0
644.   10    86.0   0.0    4.0       je	.LBB6_48
645.   10    80.0   0.0    8.0       add	r13, r9
646.   10    73.0   0.0    7.0       mov	dword ptr [r13], 0
647.   10    1.0    1.0    79.0      jmp	.LBB6_65
648.   10    69.0   1.0    10.0      test	al, 1
649.   10    67.0   0.0    9.0       jne	.LBB6_144
650.   10    1.0    1.0    75.0      jmp	.LBB6_38
651.   10    68.0   0.0    7.0       mov	byte ptr [rsp + 43], 1
652.   10    1.0    1.0    73.0      jmp	.LBB6_144
653.   10    65.0   2.0    9.0       lea	rcx, [rax + 80]
654.   10    0.0    0.0    75.0      xor	edx, edx
655.   10    1.0    1.0    72.0      jmp	.LBB6_49
656.   10    63.0   2.0    9.0       lea	rcx, [rax + 136]
657.   10    1.0    1.0    71.0      mov	edx, 1
658.   10    1.0    1.0    70.0      jmp	.LBB6_49
659.   10    62.0   3.0    8.0       lea	rcx, [rax + 192]
660.   10    1.0    1.0    68.0      mov	edx, 2
661.   10    1.0    1.0    67.0      jmp	.LBB6_49
662.   10    60.0   4.0    7.0       lea	rcx, [rax + 248]
663.   10    1.0    1.0    64.0      mov	edx, 3
664.   10    1.0    0.0    61.0      imul	rdx, rdx, 56
665.   10    56.0   4.0    7.0       lea	r8, [rax + rdx]
666.   10    55.0   0.0    6.0       add	r8, 32
667.   10    55.0   0.0    6.0       mov	byte ptr [rcx], 1
668.   10    50.0   2.0    5.0       mov	rcx, qword ptr [rax + rdx + 48]
669.   10    52.0   0.0    0.0       add	dword ptr [rax + rdx + 56], 1
670.   10    53.0   0.0    5.0       mov	qword ptr [rsp + 144], r8
671.   10    52.0   0.0    5.0       mov	qword ptr [rax + rdx + 64], r8
672.   10    49.0   0.0    4.0       mov	qword ptr [rax + rdx + 72], rcx
673.   10    46.0   0.0    3.0       mov	ebp, dword ptr [r13 + r9 + 32]
674.   10    50.0   0.0    2.0       add	ebp, ebp
675.   10    41.0   0.0    3.0       mov	eax, dword ptr [r13 + r9 + 36]
676.   10    46.0   0.0    0.0       imul	eax, ebp
677.   10    47.0   0.0    0.0       mov	qword ptr [rsp + 152], rax
678.   10    46.0   0.0    0.0       lea	edx, [rax + 64]
679.   10    25.0   1.0    13.0      mov	r8d, dword ptr [rdi + 40]
680.   10    1.0    1.0    37.0      mov	rcx, rsi
681.   10    38.0   0.0    0.0       mov	qword ptr [rsp + 88], r9
682.   10    1.0    1.0    0.0       call	handmade_asset.AcquireAssetMemory
683.   10    21.0   2.0    75.0      mov	r10, qword ptr [rsp + 88]
684.   10    38.0   1.0    62.0      mov	qword ptr [r13 + r10 + 8], rax
685.   10    29.0   2.0    66.0      mov	ecx, dword ptr [r13 + r10 + 32]
686.   10    29.0   0.0    62.0      mov	dword ptr [rax + 32], ecx
687.   10    19.0   1.0    67.0      mov	edx, dword ptr [r13 + r10 + 36]
688.   10    29.0   1.0    61.0      mov	dword ptr [rax + 36], edx
689.   10    19.0   2.0    66.0      mov	r11, qword ptr [r13 + r10 + 8]
690.   10    24.0   0.0    65.0      add	r11, 64
691.   10    22.0   0.0    66.0      test	rdx, rdx
692.   10    23.0   0.0    65.0      je	.LBB6_64
693.   10    21.0   0.0    66.0      mov	r8d, ebp
694.   10    21.0   0.0    66.0      cmp	edx, 8
695.   10    22.0   1.0    64.0      jae	.LBB6_52
696.   10    0.0    0.0    87.0      xor	r9d, r9d
697.   10    22.0   0.0    64.0      mov	rcx, r11
698.   10    1.0    1.0    84.0      jmp	.LBB6_61
699.   10    20.0   0.0    65.0      lea	r9, [r8 + r8]
700.   10    20.0   2.0    64.0      lea	rcx, [rdx - 8]
701.   10    21.0   0.0    63.0      cmp	rcx, 8
702.   10    20.0   0.0    61.0      mov	qword ptr [rsp + 136], r11
703.   10    19.0   0.0    62.0      jae	.LBB6_55
704.   10    0.0    0.0    82.0      xor	r15d, r15d
705.   10    1.0    1.0    80.0      jmp	.LBB6_58
706.   10    20.0   1.0    60.0      mov	qword ptr [rsp + 128], r13
707.   10    20.0   0.0    60.0      mov	qword ptr [rsp + 80], rcx
708.   10    17.0   0.0    63.0      mov	r10, rcx
709.   10    17.0   0.0    62.0      shr	r10, 3
710.   10    17.0   0.0    61.0      add	r10, 1
711.   10    16.0   0.0    60.0      and	r10, -2
712.   10    12.0   1.0    64.0      mov	rcx, r8
713.   10    13.0   0.0    63.0      shl	rcx, 5
714.   10    14.0   0.0    62.0      sub	rcx, r9
715.   10    16.0   1.0    59.0      mov	qword ptr [rsp + 112], rcx
716.   10    13.0   3.0    62.0      lea	rcx, [r8 + 8*r8]
717.   10    14.0   0.0    61.0      lea	rcx, [rcx + 2*rcx]
718.   10    15.0   0.0    60.0      add	rcx, r8
719.   10    15.0   0.0    59.0      mov	qword ptr [rsp + 64], rcx
720.   10    14.0   5.0    60.0      lea	rcx, [r8 + 4*r8]
721.   10    15.0   0.0    59.0      lea	r14, [rcx + 4*rcx]
722.   10    16.0   0.0    58.0      add	r14, r8
723.   10    16.0   0.0    57.0      mov	qword ptr [rsp + 56], r14
724.   10    14.0   6.0    59.0      lea	r14, [8*r8]
725.   10    16.0   0.0    57.0      mov	qword ptr [rsp + 96], r14
726.   10    14.0   0.0    58.0      lea	r14, [r14 + 2*r14]
727.   10    16.0   1.0    56.0      mov	qword ptr [rsp + 48], r14
728.   10    15.0   2.0    57.0      lea	rcx, [r9 + 4*rcx]
729.   10    16.0   0.0    56.0      mov	qword ptr [rsp + 72], rcx
730.   10    14.0   7.0    58.0      lea	rcx, [4*r8]
731.   10    15.0   0.0    57.0      lea	r14, [rcx + 4*rcx]
732.   10    16.0   1.0    55.0      mov	qword ptr [rsp + 200], r14
733.   10    15.0   8.0    56.0      lea	r14, [r9 + 8*r9]
734.   10    16.0   0.0    55.0      mov	qword ptr [rsp + 192], r14
735.   10    10.0   4.0    61.0      mov	rbp, r8
736.   10    10.0   0.0    60.0      shl	rbp, 4
737.   10    11.0   0.0    59.0      mov	r14, rbp
738.   10    12.0   0.0    58.0      sub	r14, r9
739.   10    16.0   1.0    54.0      mov	qword ptr [rsp + 184], r14
740.   10    16.0   0.0    54.0      mov	qword ptr [rsp + 208], rcx
741.   10    14.0   1.0    56.0      lea	rcx, [rcx + 2*rcx]
742.   10    16.0   1.0    53.0      mov	qword ptr [rsp + 176], rcx
743.   10    14.0   9.0    55.0      lea	rcx, [r9 + 4*r9]
744.   10    16.0   0.0    53.0      mov	qword ptr [rsp + 168], rcx
745.   10    12.0   9.0    55.0      lea	rcx, [r9 + 2*r9]
746.   10    14.0   1.0    52.0      mov	qword ptr [rsp + 160], rcx
747.   10    0.0    0.0    67.0      xor	r15d, r15d
748.   10    14.0   0.0    52.0      mov	qword ptr [rax + 8*r15 + 16], r11
749.   10    12.0   10.0   54.0      lea	r13, [r11 + r9]
750.   10    15.0   1.0    51.0      mov	qword ptr [rax + 8*r15 + 24], r13
751.   10    12.0   0.0    53.0      add	r13, r9
752.   10    1.0    1.0    60.0      mov	rcx, qword ptr [rsp + 208]
753.   10    6.0    0.0    59.0      add	rcx, r11
754.   10    14.0   0.0    51.0      mov	qword ptr [rax + 8*r15 + 32], rcx
755.   10    1.0    1.0    59.0      mov	rcx, qword ptr [rsp + 160]
756.   10    10.0   4.0    54.0      lea	rcx, [r11 + rcx]
757.   10    14.0   1.0    50.0      mov	qword ptr [rax + 8*r15 + 40], rcx
758.   10    11.0   11.0   53.0      lea	rcx, [r9 + r9]
759.   10    1.0    1.0    59.0      mov	r14, qword ptr [rsp + 96]
760.   10    10.0   5.0    53.0      lea	r14, [r11 + r14]
761.   10    13.0   0.0    50.0      mov	qword ptr [rax + 8*r15 + 48], r14
762.   10    1.0    1.0    58.0      mov	r14, qword ptr [rsp + 168]
763.   10    11.0   5.0    52.0      lea	r14, [r11 + r14]
764.   10    14.0   1.0    49.0      mov	qword ptr [rax + 8*r15 + 56], r14
765.   10    1.0    1.0    58.0      mov	r14, qword ptr [rsp + 176]
766.   10    10.0   5.0    52.0      lea	r14, [r11 + r14]
767.   10    13.0   0.0    49.0      mov	qword ptr [rax + 8*r15 + 64], r14
768.   10    1.0    1.0    57.0      mov	r14, qword ptr [rsp + 184]
769.   10    11.0   5.0    51.0      lea	r14, [r11 + r14]
770.   10    14.0   1.0    48.0      mov	qword ptr [rax + 8*r15 + 72], r14
771.   10    11.0   8.0    51.0      lea	r14, [r11 + rbp]
772.   10    13.0   0.0    48.0      mov	qword ptr [rax + 8*r15 + 80], r14
773.   10    1.0    1.0    56.0      mov	r14, qword ptr [rsp + 192]
774.   10    11.0   5.0    50.0      lea	r14, [r11 + r14]
775.   10    14.0   1.0    47.0      mov	qword ptr [rax + 8*r15 + 88], r14
776.   10    1.0    1.0    56.0      mov	r14, qword ptr [rsp + 200]
777.   10    11.0   5.0    50.0      lea	r14, [r11 + r14]
778.   10    13.0   0.0    47.0      mov	qword ptr [rax + 8*r15 + 96], r14
779.   10    1.0    1.0    55.0      mov	r14, qword ptr [rsp + 72]
780.   10    6.0    0.0    54.0      add	r14, r11
781.   10    14.0   1.0    46.0      mov	qword ptr [rax + 8*r15 + 104], r14
782.   10    1.0    1.0    55.0      mov	r14, qword ptr [rsp + 48]
783.   10    6.0    0.0    54.0      add	r14, r11
784.   10    13.0   0.0    46.0      mov	qword ptr [rax + 8*r15 + 112], r14
785.   10    1.0    1.0    54.0      mov	r14, qword ptr [rsp + 56]
786.   10    6.0    0.0    53.0      add	r14, r11
787.   10    14.0   1.0    45.0      mov	qword ptr [rax + 8*r15 + 120], r14
788.   10    10.0   3.0    49.0      lea	r14, [rcx + r9]
789.   10    11.0   0.0    48.0      add	r13, r14
790.   10    10.0   0.0    48.0      add	r14, r9
791.   10    11.0   0.0    47.0      add	r13, r14
792.   10    11.0   0.0    47.0      add	r14, r9
793.   10    12.0   0.0    46.0      add	r14, r13
794.   10    1.0    1.0    53.0      mov	r13, qword ptr [rsp + 64]
795.   10    6.0    0.0    52.0      add	r13, r11
796.   10    12.0   0.0    45.0      mov	qword ptr [rax + 8*r15 + 128], r13
797.   10    1.0    1.0    51.0      add	r11, qword ptr [rsp + 112]
798.   10    13.0   1.0    44.0      mov	qword ptr [rax + 8*r15 + 136], r11
799.   10    12.0   0.0    45.0      mov	r11, r14
800.   10    13.0   0.0    44.0      add	r11, rcx
801.   10    1.0    1.0    55.0      add	r15, 16
802.   10    1.0    1.0    55.0      add	r10, -2
803.   10    4.0    2.0    52.0      jne	.LBB6_56
804.   10    13.0   0.0    43.0      mov	r10, r11
805.   10    14.0   0.0    42.0      sub	r10, rbp
806.   10    1.0    1.0    51.0      mov	r14, qword ptr [rsp + 232]
807.   10    1.0    1.0    50.0      mov	r13, qword ptr [rsp + 128]
808.   10    1.0    1.0    50.0      mov	rcx, qword ptr [rsp + 80]
809.   10    6.0    0.0    49.0      test	cl, 8
810.   10    9.0    2.0    46.0      jne	.LBB6_60
811.   10    12.0   0.0    43.0      mov	qword ptr [rax + 8*r15 + 16], r11
812.   10    12.0   0.0    43.0      lea	rcx, [r11 + r9]
813.   10    12.0   0.0    42.0      mov	qword ptr [rax + 8*r15 + 24], rcx
814.   10    12.0   0.0    42.0      add	rcx, r9
815.   10    13.0   0.0    41.0      mov	qword ptr [rax + 8*r15 + 32], rcx
816.   10    13.0   0.0    41.0      add	rcx, r9
817.   10    14.0   0.0    40.0      mov	qword ptr [rax + 8*r15 + 40], rcx
818.   10    14.0   0.0    40.0      add	rcx, r9
819.   10    14.0   0.0    39.0      mov	qword ptr [rax + 8*r15 + 48], rcx
820.   10    14.0   0.0    39.0      add	rcx, r9
821.   10    15.0   0.0    38.0      mov	qword ptr [rax + 8*r15 + 56], rcx
822.   10    15.0   0.0    38.0      add	rcx, r9
823.   10    16.0   0.0    37.0      mov	qword ptr [rax + 8*r15 + 64], rcx
824.   10    16.0   0.0    37.0      add	rcx, r9
825.   10    16.0   0.0    36.0      mov	qword ptr [rax + 8*r15 + 72], rcx
826.   10    9.0    0.0    43.0      mov	r10, r11
827.   10    1.0    1.0    51.0      mov	r9d, edx
828.   10    2.0    0.0    50.0      and	r9d, -8
829.   10    1.0    1.0    51.0      mov	rcx, r8
830.   10    2.0    0.0    50.0      shl	rcx, 4
831.   10    9.0    0.0    42.0      add	rcx, r10
832.   10    2.0    2.0    49.0      mov	r15d, 1
833.   10    1.0    1.0    46.0      mov	r10, qword ptr [rsp + 88]
834.   10    1.0    1.0    46.0      mov	r11, qword ptr [rsp + 136]
835.   10    2.0    2.0    49.0      and	edx, 7
836.   10    6.0    3.0    45.0      je	.LBB6_64
837.   10    2.0    1.0    48.0      lea	rax, [rax + 8*r9]
838.   10    3.0    0.0    47.0      add	rax, 16
839.   10    2.0    2.0    48.0      add	r8, r8
840.   10    0.0    0.0    51.0      xor	r9d, r9d
841.   10    14.0   0.0    36.0      mov	qword ptr [rax + 8*r9], rcx
842.   10    3.0    3.0    47.0      add	r9, 1
843.   10    8.0    0.0    41.0      add	rcx, r8
844.   10    3.0    0.0    46.0      cmp	rdx, r9
845.   10    5.0    1.0    44.0      jne	.LBB6_63
846.   10    1.0    1.0    44.0      mov	r8, qword ptr [rsp + 144]
847.   10    6.0    0.0    39.0      mov	rcx, qword ptr [r8 + 16]
848.   10    6.0    0.0    39.0      mov	rax, qword ptr [r8 + 8]
849.   10    10.0   0.0    38.0      add	rax, rcx
850.   10    11.0   0.0    37.0      mov	edx, eax
851.   10    12.0   0.0    36.0      and	edx, 7
852.   10    2.0    2.0    46.0      mov	r9d, 8
853.   10    13.0   0.0    35.0      sub	r9, rdx
854.   10    13.0   0.0    35.0      test	rdx, rdx
855.   10    13.0   0.0    34.0      cmove	r9, rdx
856.   10    2.0    0.0    45.0      lea	rdx, [r13 + r10 + 16]
857.   10    14.0   0.0    33.0      lea	rcx, [rcx + r9 + 56]
858.   10    15.0   0.0    32.0      mov	qword ptr [r8 + 16], rcx
859.   10    15.0   0.0    32.0      mov	qword ptr [r9 + rax], r8
860.   10    1.0    1.0    42.0      mov	ecx, dword ptr [rdi + 40]
861.   10    5.0    0.0    39.0      imul	rcx, rcx, 56
862.   10    5.0    0.0    36.0      add	rcx, qword ptr [rsi + 128]
863.   10    13.0   0.0    33.0      lea	r8, [r9 + rax]
864.   10    15.0   1.0    31.0      mov	qword ptr [r9 + rax + 8], rcx
865.   10    1.0    0.0    41.0      mov	ecx, dword ptr [r13 + r10 + 52]
866.   10    5.0    0.0    38.0      imul	rcx, rcx, 88
867.   10    5.0    0.0    35.0      add	rcx, qword ptr [rsi + 104]
868.   10    14.0   0.0    31.0      mov	qword ptr [r9 + rax + 16], rcx
869.   10    1.0    0.0    40.0      mov	rcx, qword ptr [rdx]
870.   10    15.0   1.0    30.0      mov	qword ptr [r9 + rax + 24], rcx
871.   10    2.0    2.0    38.0      mov	ecx, dword ptr [rsp + 152]
872.   10    14.0   0.0    30.0      mov	qword ptr [r9 + rax + 32], rcx
873.   10    15.0   1.0    29.0      mov	qword ptr [r9 + rax + 40], r11
874.   10    15.0   0.0    29.0      mov	dword ptr [r9 + rax + 48], 2
875.   10    16.0   1.0    28.0      mov	byte ptr [r9 + rax + 52], 0
876.   10    2.0    2.0    38.0      mov	rax, qword ptr [rsi]
877.   10    6.0    0.0    33.0      mov	rcx, qword ptr [rax + 288]
878.   10    1.0    1.0    42.0      lea	rdx, [rip + handmade_asset.LoadAssetWork]
879.   10    3.0    3.0    0.0       call	qword ptr [rip + handmade_data.platformAPI]
880.   10    1.0    1.0    95.0      cmp	byte ptr [rsp + 43], 0
881.   10    7.0    0.0    94.0      je	.LBB6_38
882.   10    2.0    2.0    95.0      mov	rax, qword ptr [rdi]
883.   10    3.0    3.0    94.0      mov	rdx, qword ptr [rsp + 216]
884.   10    13.0   0.0    88.0      mov	qword ptr [rdx], rax
885.   10    2.0    2.0    94.0      mov	rcx, qword ptr [rsp + 104]
886.   10    7.0    0.0    89.0      mov	rax, qword ptr [rcx + 104]
887.   10    13.0   1.0    87.0      mov	qword ptr [rdi], rax
888.   10    13.0   0.0    87.0      mov	qword ptr [rcx + 104], rdi
889.   10    7.0    0.0    93.0      mov	rdi, rdx
890.   10    14.0   1.0    86.0      mov	qword ptr [rsp + 216], rdi
891.   10    7.0    0.0    88.0      mov	rdi, qword ptr [rdi]
892.   10    12.0   0.0    87.0      test	rdi, rdi
893.   10    13.0   0.0    86.0      jne	.LBB6_16
894.   10    1.0    1.0    98.0      jmp	.LBB6_28
895.   10    2.0    2.0    97.0      jmp	.LBB6_104
896.   10    2.0    2.0    97.0      jmp	.LBB6_93
897.   10    11.0   0.0    83.0      mov	rdi, qword ptr [rdi]
898.   10    16.0   0.0    82.0      test	rdi, rdi
899.   10    17.0   0.0    81.0      jne	.LBB6_26
900.   10    12.0   0.0    86.0      mov	byte ptr [rsp + 43], 0
       10    18.3   0.8    52.6      <total>


```
</details>

</details>

<details><summary>[2] Code Region - OPS_FillSoundBuffer</summary>

```
Iterations:        100
Instructions:      1700
Total Cycles:      420
Total uOps:        2100

Dispatch Width:    6
uOps Per Cycle:    5.00
IPC:               4.05
Block RThroughput: 3.5


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
 2      6     0.50    *                   cmp	dword ptr [rsp + 44], 0
 1      5     0.50    *                   mov	rdx, qword ptr [rsp + 224]
 1      1     0.50                        je	.LBB6_31
 1      5     0.50    *                   mov	rax, qword ptr [rsp + 280]
 1      5     0.50    *                   mov	rax, qword ptr [rax]
 1      0     0.17                        xor	ecx, ecx
 1      6     0.50    *                   vmovaps	xmm0, xmmword ptr [r12 + rcx]
 1      4     0.50                        cvtps2dq	xmm0, xmm0
 1      6     0.50    *                   vmovaps	xmm1, xmmword ptr [rbx + rcx]
 1      4     0.50                        cvtps2dq	xmm1, xmm1
 1      1     0.50                        vpunpckhdq	xmm2, xmm0, xmm1
 1      1     0.50                        vpunpckldq	xmm0, xmm0, xmm1
 1      3     1.00                        vinserti128	ymm0, ymm0, xmm2, 1
 4      5     2.00           *            vpmovsdw	xmmword ptr [rax + rcx], ymm0
 1      1     0.25                        add	rcx, 16
 1      1     0.25                        add	rdx, -1
 1      1     0.50                        jne	.LBB6_30


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
 0,              20  (4.8%)
 1,              1  (0.2%)
 3,              98  (23.3%)
 5,              1  (0.2%)
 6,              300  (71.4%)


```
</details>

<details><summary>Schedulers - number of cycles where we saw N micro opcodes issued:</summary>

```
[# issued], [# cycles]
 0,          10  (2.4%)
 1,          4  (1.0%)
 2,          70  (16.7%)
 3,          35  (8.3%)
 4,          102  (24.3%)
 5,          39  (9.3%)
 7,          96  (22.9%)
 8,          32  (7.6%)
 10,          32  (7.6%)

```
</details>

<details><summary>Scheduler's queue usage:</summary>

```
[1] Resource name.
[2] Average number of used buffer entries.
[3] Maximum number of used buffer entries.
[4] Total number of buffer entries.

 [1]            [2]        [3]        [4]
ICXPortAny       22         25         60


```
</details>

<details><summary>Retire Control Unit - number of cycles where we saw N instructions retired:</summary>

```
[# retired], [# cycles]
 0,           314  (74.8%)
 1,           2  (0.5%)
 2,           3  (0.7%)
 4,           1  (0.2%)
 5,           1  (0.2%)
 17,          99  (23.6%)

```
</details>

<details><summary>Total ROB Entries:                352</summary>

```
Max Used ROB Entries:             117  ( 33.2% )
Average Used ROB Entries per cy:  98  ( 27.8% )


```
</details>

<details><summary>Register File statistics:</summary>

```
Total number of mappings created:    1500
Max number of mappings used:         82


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
 -      -     2.65   2.67   3.00   3.00   0.50   4.03   2.65   0.50   0.50   0.50   

Resource pressure by instruction:
[0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   Instructions:
 -      -      -     0.01   0.99   0.01    -      -     0.99    -      -      -     cmp	dword ptr [rsp + 44], 0
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	rdx, qword ptr [rsp + 224]
 -      -     0.67    -      -      -      -      -     0.33    -      -      -     je	.LBB6_31
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     mov	rax, qword ptr [rsp + 280]
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     mov	rax, qword ptr [rax]
 -      -      -      -      -      -      -      -      -      -      -      -     xor	ecx, ecx
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     vmovaps	xmm0, xmmword ptr [r12 + rcx]
 -      -      -     1.00    -      -      -      -      -      -      -      -     cvtps2dq	xmm0, xmm0
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     vmovaps	xmm1, xmmword ptr [rbx + rcx]
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     cvtps2dq	xmm1, xmm1
 -      -      -     0.97    -      -      -     0.03    -      -      -      -     vpunpckhdq	xmm2, xmm0, xmm1
 -      -      -     0.36    -      -      -     0.64    -      -      -      -     vpunpckldq	xmm0, xmm0, xmm1
 -      -      -      -      -      -      -     1.00    -      -      -      -     vinserti128	ymm0, ymm0, xmm2, 1
 -      -      -      -      -      -     0.50   2.00    -     0.50   0.50   0.50   vpmovsdw	xmmword ptr [rax + rcx], ymm0
 -      -     0.33    -      -      -      -     0.35   0.32    -      -      -     add	rcx, 16
 -      -     0.33   0.32    -      -      -     0.01   0.34    -      -      -     add	rdx, -1
 -      -     0.33    -      -      -      -      -     0.67    -      -      -     jne	.LBB6_30


```
</details>

<details><summary>Timeline view:</summary>

```
                    0123456789          0123456789          0123456789
Index     0123456789          0123456789          0123456789          

[0,0]     DeeeeeeER .    .    .    .    .    .    .    .    .    .   .   cmp	dword ptr [rsp + 44], 0
[0,1]     DeeeeeE-R .    .    .    .    .    .    .    .    .    .   .   mov	rdx, qword ptr [rsp + 224]
[0,2]     D======eER.    .    .    .    .    .    .    .    .    .   .   je	.LBB6_31
[0,3]     D=eeeeeE-R.    .    .    .    .    .    .    .    .    .   .   mov	rax, qword ptr [rsp + 280]
[0,4]     D======eeeeeER .    .    .    .    .    .    .    .    .   .   mov	rax, qword ptr [rax]
[0,5]     .D-----------R .    .    .    .    .    .    .    .    .   .   xor	ecx, ecx
[0,6]     .DeeeeeeE----R .    .    .    .    .    .    .    .    .   .   vmovaps	xmm0, xmmword ptr [r12 + rcx]
[0,7]     .D======eeeeER .    .    .    .    .    .    .    .    .   .   cvtps2dq	xmm0, xmm0
[0,8]     .D=eeeeeeE---R .    .    .    .    .    .    .    .    .   .   vmovaps	xmm1, xmmword ptr [rbx + rcx]
[0,9]     .D=======eeeeER.    .    .    .    .    .    .    .    .   .   cvtps2dq	xmm1, xmm1
[0,10]    .D===========eER    .    .    .    .    .    .    .    .   .   vpunpckhdq	xmm2, xmm0, xmm1
[0,11]    . D==========eER    .    .    .    .    .    .    .    .   .   vpunpckldq	xmm0, xmm0, xmm1
[0,12]    . D===========eeeER .    .    .    .    .    .    .    .   .   vinserti128	ymm0, ymm0, xmm2, 1
[0,13]    . D==============eeeeeER .    .    .    .    .    .    .   .   vpmovsdw	xmmword ptr [rax + rcx], ymm0
[0,14]    .  DeE-----------------R .    .    .    .    .    .    .   .   add	rcx, 16
[0,15]    .  D==eE---------------R .    .    .    .    .    .    .   .   add	rdx, -1
[0,16]    .  D===eE--------------R .    .    .    .    .    .    .   .   jne	.LBB6_30
[1,0]     .  DeeeeeeE------------R .    .    .    .    .    .    .   .   cmp	dword ptr [rsp + 44], 0
[1,1]     .  DeeeeeE-------------R .    .    .    .    .    .    .   .   mov	rdx, qword ptr [rsp + 224]
[1,2]     .   D=====eE-----------R .    .    .    .    .    .    .   .   je	.LBB6_31
[1,3]     .   DeeeeeE------------R .    .    .    .    .    .    .   .   mov	rax, qword ptr [rsp + 280]
[1,4]     .   D=====eeeeeE-------R .    .    .    .    .    .    .   .   mov	rax, qword ptr [rax]
[1,5]     .   D------------------R .    .    .    .    .    .    .   .   xor	ecx, ecx
[1,6]     .   DeeeeeeE-----------R .    .    .    .    .    .    .   .   vmovaps	xmm0, xmmword ptr [r12 + rcx]
[1,7]     .   D======eeeeE-------R .    .    .    .    .    .    .   .   cvtps2dq	xmm0, xmm0
[1,8]     .    DeeeeeeE----------R .    .    .    .    .    .    .   .   vmovaps	xmm1, xmmword ptr [rbx + rcx]
[1,9]     .    D======eeeeE------R .    .    .    .    .    .    .   .   cvtps2dq	xmm1, xmm1
[1,10]    .    D==========eE-----R .    .    .    .    .    .    .   .   vpunpckhdq	xmm2, xmm0, xmm1
[1,11]    .    D==========eE-----R .    .    .    .    .    .    .   .   vpunpckldq	xmm0, xmm0, xmm1
[1,12]    .    D=============eeeER .    .    .    .    .    .    .   .   vinserti128	ymm0, ymm0, xmm2, 1
[1,13]    .    .D===============eeeeeER .    .    .    .    .    .   .   vpmovsdw	xmmword ptr [rax + rcx], ymm0
[1,14]    .    .DeE-------------------R .    .    .    .    .    .   .   add	rcx, 16
[1,15]    .    .D==eE-----------------R .    .    .    .    .    .   .   add	rdx, -1
[1,16]    .    . D==eE----------------R .    .    .    .    .    .   .   jne	.LBB6_30
[2,0]     .    . DeeeeeeE-------------R .    .    .    .    .    .   .   cmp	dword ptr [rsp + 44], 0
[2,1]     .    . DeeeeeE--------------R .    .    .    .    .    .   .   mov	rdx, qword ptr [rsp + 224]
[2,2]     .    . D======eE------------R .    .    .    .    .    .   .   je	.LBB6_31
[2,3]     .    . D=eeeeeE-------------R .    .    .    .    .    .   .   mov	rax, qword ptr [rsp + 280]
[2,4]     .    .  D=====eeeeeE--------R .    .    .    .    .    .   .   mov	rax, qword ptr [rax]
[2,5]     .    .  D-------------------R .    .    .    .    .    .   .   xor	ecx, ecx
[2,6]     .    .  DeeeeeeE------------R .    .    .    .    .    .   .   vmovaps	xmm0, xmmword ptr [r12 + rcx]
[2,7]     .    .  D======eeeeE--------R .    .    .    .    .    .   .   cvtps2dq	xmm0, xmm0
[2,8]     .    .  D=eeeeeeE-----------R .    .    .    .    .    .   .   vmovaps	xmm1, xmmword ptr [rbx + rcx]
[2,9]     .    .  D=======eeeeE-------R .    .    .    .    .    .   .   cvtps2dq	xmm1, xmm1
[2,10]    .    .   D==========eE------R .    .    .    .    .    .   .   vpunpckhdq	xmm2, xmm0, xmm1
[2,11]    .    .   D==========eE------R .    .    .    .    .    .   .   vpunpckldq	xmm0, xmm0, xmm1
[2,12]    .    .   D===========eeeE---R .    .    .    .    .    .   .   vinserti128	ymm0, ymm0, xmm2, 1
[2,13]    .    .    D=============eeeeeER    .    .    .    .    .   .   vpmovsdw	xmmword ptr [rax + rcx], ymm0
[2,14]    .    .    DeE-----------------R    .    .    .    .    .   .   add	rcx, 16
[2,15]    .    .    D==eE---------------R    .    .    .    .    .   .   add	rdx, -1
[2,16]    .    .    .D==eE--------------R    .    .    .    .    .   .   jne	.LBB6_30
[3,0]     .    .    .DeeeeeeE-----------R    .    .    .    .    .   .   cmp	dword ptr [rsp + 44], 0
[3,1]     .    .    .DeeeeeE------------R    .    .    .    .    .   .   mov	rdx, qword ptr [rsp + 224]
[3,2]     .    .    .D======eE----------R    .    .    .    .    .   .   je	.LBB6_31
[3,3]     .    .    .D=eeeeeE-----------R    .    .    .    .    .   .   mov	rax, qword ptr [rsp + 280]
[3,4]     .    .    . D=====eeeeeE------R    .    .    .    .    .   .   mov	rax, qword ptr [rax]
[3,5]     .    .    . D-----------------R    .    .    .    .    .   .   xor	ecx, ecx
[3,6]     .    .    . DeeeeeeE----------R    .    .    .    .    .   .   vmovaps	xmm0, xmmword ptr [r12 + rcx]
[3,7]     .    .    . D======eeeeE------R    .    .    .    .    .   .   cvtps2dq	xmm0, xmm0
[3,8]     .    .    . D=eeeeeeE---------R    .    .    .    .    .   .   vmovaps	xmm1, xmmword ptr [rbx + rcx]
[3,9]     .    .    . D=======eeeeE-----R    .    .    .    .    .   .   cvtps2dq	xmm1, xmm1
[3,10]    .    .    .  D==========eE----R    .    .    .    .    .   .   vpunpckhdq	xmm2, xmm0, xmm1
[3,11]    .    .    .  D===========eE---R    .    .    .    .    .   .   vpunpckldq	xmm0, xmm0, xmm1
[3,12]    .    .    .  D============eeeER    .    .    .    .    .   .   vinserti128	ymm0, ymm0, xmm2, 1
[3,13]    .    .    .   D==============eeeeeER    .    .    .    .   .   vpmovsdw	xmmword ptr [rax + rcx], ymm0
[3,14]    .    .    .   DeE------------------R    .    .    .    .   .   add	rcx, 16
[3,15]    .    .    .   D==eE----------------R    .    .    .    .   .   add	rdx, -1
[3,16]    .    .    .    D==eE---------------R    .    .    .    .   .   jne	.LBB6_30
[4,0]     .    .    .    DeeeeeeE------------R    .    .    .    .   .   cmp	dword ptr [rsp + 44], 0
[4,1]     .    .    .    DeeeeeE-------------R    .    .    .    .   .   mov	rdx, qword ptr [rsp + 224]
[4,2]     .    .    .    D======eE-----------R    .    .    .    .   .   je	.LBB6_31
[4,3]     .    .    .    D=eeeeeE------------R    .    .    .    .   .   mov	rax, qword ptr [rsp + 280]
[4,4]     .    .    .    .D=====eeeeeE-------R    .    .    .    .   .   mov	rax, qword ptr [rax]
[4,5]     .    .    .    .D------------------R    .    .    .    .   .   xor	ecx, ecx
[4,6]     .    .    .    .DeeeeeeE-----------R    .    .    .    .   .   vmovaps	xmm0, xmmword ptr [r12 + rcx]
[4,7]     .    .    .    .D======eeeeE-------R    .    .    .    .   .   cvtps2dq	xmm0, xmm0
[4,8]     .    .    .    .D=eeeeeeE----------R    .    .    .    .   .   vmovaps	xmm1, xmmword ptr [rbx + rcx]
[4,9]     .    .    .    .D=======eeeeE------R    .    .    .    .   .   cvtps2dq	xmm1, xmm1
[4,10]    .    .    .    . D==========eE-----R    .    .    .    .   .   vpunpckhdq	xmm2, xmm0, xmm1
[4,11]    .    .    .    . D==========eE-----R    .    .    .    .   .   vpunpckldq	xmm0, xmm0, xmm1
[4,12]    .    .    .    . D=============eeeER    .    .    .    .   .   vinserti128	ymm0, ymm0, xmm2, 1
[4,13]    .    .    .    .  D===============eeeeeER    .    .    .   .   vpmovsdw	xmmword ptr [rax + rcx], ymm0
[4,14]    .    .    .    .  DeE-------------------R    .    .    .   .   add	rcx, 16
[4,15]    .    .    .    .  D==eE-----------------R    .    .    .   .   add	rdx, -1
[4,16]    .    .    .    .   D==eE----------------R    .    .    .   .   jne	.LBB6_30
[5,0]     .    .    .    .   DeeeeeeE-------------R    .    .    .   .   cmp	dword ptr [rsp + 44], 0
[5,1]     .    .    .    .   DeeeeeE--------------R    .    .    .   .   mov	rdx, qword ptr [rsp + 224]
[5,2]     .    .    .    .   D======eE------------R    .    .    .   .   je	.LBB6_31
[5,3]     .    .    .    .   D=eeeeeE-------------R    .    .    .   .   mov	rax, qword ptr [rsp + 280]
[5,4]     .    .    .    .    D=====eeeeeE--------R    .    .    .   .   mov	rax, qword ptr [rax]
[5,5]     .    .    .    .    D-------------------R    .    .    .   .   xor	ecx, ecx
[5,6]     .    .    .    .    DeeeeeeE------------R    .    .    .   .   vmovaps	xmm0, xmmword ptr [r12 + rcx]
[5,7]     .    .    .    .    D======eeeeE--------R    .    .    .   .   cvtps2dq	xmm0, xmm0
[5,8]     .    .    .    .    D=eeeeeeE-----------R    .    .    .   .   vmovaps	xmm1, xmmword ptr [rbx + rcx]
[5,9]     .    .    .    .    D=======eeeeE-------R    .    .    .   .   cvtps2dq	xmm1, xmm1
[5,10]    .    .    .    .    .D==========eE------R    .    .    .   .   vpunpckhdq	xmm2, xmm0, xmm1
[5,11]    .    .    .    .    .D==========eE------R    .    .    .   .   vpunpckldq	xmm0, xmm0, xmm1
[5,12]    .    .    .    .    .D===========eeeE---R    .    .    .   .   vinserti128	ymm0, ymm0, xmm2, 1
[5,13]    .    .    .    .    . D=============eeeeeER  .    .    .   .   vpmovsdw	xmmword ptr [rax + rcx], ymm0
[5,14]    .    .    .    .    . DeE-----------------R  .    .    .   .   add	rcx, 16
[5,15]    .    .    .    .    . D==eE---------------R  .    .    .   .   add	rdx, -1
[5,16]    .    .    .    .    .  D==eE--------------R  .    .    .   .   jne	.LBB6_30
[6,0]     .    .    .    .    .  DeeeeeeE-----------R  .    .    .   .   cmp	dword ptr [rsp + 44], 0
[6,1]     .    .    .    .    .  DeeeeeE------------R  .    .    .   .   mov	rdx, qword ptr [rsp + 224]
[6,2]     .    .    .    .    .  D======eE----------R  .    .    .   .   je	.LBB6_31
[6,3]     .    .    .    .    .  D=eeeeeE-----------R  .    .    .   .   mov	rax, qword ptr [rsp + 280]
[6,4]     .    .    .    .    .   D=====eeeeeE------R  .    .    .   .   mov	rax, qword ptr [rax]
[6,5]     .    .    .    .    .   D-----------------R  .    .    .   .   xor	ecx, ecx
[6,6]     .    .    .    .    .   DeeeeeeE----------R  .    .    .   .   vmovaps	xmm0, xmmword ptr [r12 + rcx]
[6,7]     .    .    .    .    .   D======eeeeE------R  .    .    .   .   cvtps2dq	xmm0, xmm0
[6,8]     .    .    .    .    .   D=eeeeeeE---------R  .    .    .   .   vmovaps	xmm1, xmmword ptr [rbx + rcx]
[6,9]     .    .    .    .    .   D=======eeeeE-----R  .    .    .   .   cvtps2dq	xmm1, xmm1
[6,10]    .    .    .    .    .    D==========eE----R  .    .    .   .   vpunpckhdq	xmm2, xmm0, xmm1
[6,11]    .    .    .    .    .    D===========eE---R  .    .    .   .   vpunpckldq	xmm0, xmm0, xmm1
[6,12]    .    .    .    .    .    D============eeeER  .    .    .   .   vinserti128	ymm0, ymm0, xmm2, 1
[6,13]    .    .    .    .    .    .D==============eeeeeER  .    .   .   vpmovsdw	xmmword ptr [rax + rcx], ymm0
[6,14]    .    .    .    .    .    .DeE------------------R  .    .   .   add	rcx, 16
[6,15]    .    .    .    .    .    .D==eE----------------R  .    .   .   add	rdx, -1
[6,16]    .    .    .    .    .    . D==eE---------------R  .    .   .   jne	.LBB6_30
[7,0]     .    .    .    .    .    . DeeeeeeE------------R  .    .   .   cmp	dword ptr [rsp + 44], 0
[7,1]     .    .    .    .    .    . DeeeeeE-------------R  .    .   .   mov	rdx, qword ptr [rsp + 224]
[7,2]     .    .    .    .    .    . D======eE-----------R  .    .   .   je	.LBB6_31
[7,3]     .    .    .    .    .    . D=eeeeeE------------R  .    .   .   mov	rax, qword ptr [rsp + 280]
[7,4]     .    .    .    .    .    .  D=====eeeeeE-------R  .    .   .   mov	rax, qword ptr [rax]
[7,5]     .    .    .    .    .    .  D------------------R  .    .   .   xor	ecx, ecx
[7,6]     .    .    .    .    .    .  DeeeeeeE-----------R  .    .   .   vmovaps	xmm0, xmmword ptr [r12 + rcx]
[7,7]     .    .    .    .    .    .  D======eeeeE-------R  .    .   .   cvtps2dq	xmm0, xmm0
[7,8]     .    .    .    .    .    .  D=eeeeeeE----------R  .    .   .   vmovaps	xmm1, xmmword ptr [rbx + rcx]
[7,9]     .    .    .    .    .    .  D=======eeeeE------R  .    .   .   cvtps2dq	xmm1, xmm1
[7,10]    .    .    .    .    .    .   D==========eE-----R  .    .   .   vpunpckhdq	xmm2, xmm0, xmm1
[7,11]    .    .    .    .    .    .   D==========eE-----R  .    .   .   vpunpckldq	xmm0, xmm0, xmm1
[7,12]    .    .    .    .    .    .   D=============eeeER  .    .   .   vinserti128	ymm0, ymm0, xmm2, 1
[7,13]    .    .    .    .    .    .    D===============eeeeeER  .   .   vpmovsdw	xmmword ptr [rax + rcx], ymm0
[7,14]    .    .    .    .    .    .    DeE-------------------R  .   .   add	rcx, 16
[7,15]    .    .    .    .    .    .    D==eE-----------------R  .   .   add	rdx, -1
[7,16]    .    .    .    .    .    .    .D==eE----------------R  .   .   jne	.LBB6_30
[8,0]     .    .    .    .    .    .    .DeeeeeeE-------------R  .   .   cmp	dword ptr [rsp + 44], 0
[8,1]     .    .    .    .    .    .    .DeeeeeE--------------R  .   .   mov	rdx, qword ptr [rsp + 224]
[8,2]     .    .    .    .    .    .    .D======eE------------R  .   .   je	.LBB6_31
[8,3]     .    .    .    .    .    .    .D=eeeeeE-------------R  .   .   mov	rax, qword ptr [rsp + 280]
[8,4]     .    .    .    .    .    .    . D=====eeeeeE--------R  .   .   mov	rax, qword ptr [rax]
[8,5]     .    .    .    .    .    .    . D-------------------R  .   .   xor	ecx, ecx
[8,6]     .    .    .    .    .    .    . DeeeeeeE------------R  .   .   vmovaps	xmm0, xmmword ptr [r12 + rcx]
[8,7]     .    .    .    .    .    .    . D======eeeeE--------R  .   .   cvtps2dq	xmm0, xmm0
[8,8]     .    .    .    .    .    .    . D=eeeeeeE-----------R  .   .   vmovaps	xmm1, xmmword ptr [rbx + rcx]
[8,9]     .    .    .    .    .    .    . D=======eeeeE-------R  .   .   cvtps2dq	xmm1, xmm1
[8,10]    .    .    .    .    .    .    .  D==========eE------R  .   .   vpunpckhdq	xmm2, xmm0, xmm1
[8,11]    .    .    .    .    .    .    .  D==========eE------R  .   .   vpunpckldq	xmm0, xmm0, xmm1
[8,12]    .    .    .    .    .    .    .  D===========eeeE---R  .   .   vinserti128	ymm0, ymm0, xmm2, 1
[8,13]    .    .    .    .    .    .    .   D=============eeeeeER.   .   vpmovsdw	xmmword ptr [rax + rcx], ymm0
[8,14]    .    .    .    .    .    .    .   DeE-----------------R.   .   add	rcx, 16
[8,15]    .    .    .    .    .    .    .   D==eE---------------R.   .   add	rdx, -1
[8,16]    .    .    .    .    .    .    .    D==eE--------------R.   .   jne	.LBB6_30
[9,0]     .    .    .    .    .    .    .    DeeeeeeE-----------R.   .   cmp	dword ptr [rsp + 44], 0
[9,1]     .    .    .    .    .    .    .    DeeeeeE------------R.   .   mov	rdx, qword ptr [rsp + 224]
[9,2]     .    .    .    .    .    .    .    D======eE----------R.   .   je	.LBB6_31
[9,3]     .    .    .    .    .    .    .    D=eeeeeE-----------R.   .   mov	rax, qword ptr [rsp + 280]
[9,4]     .    .    .    .    .    .    .    .D=====eeeeeE------R.   .   mov	rax, qword ptr [rax]
[9,5]     .    .    .    .    .    .    .    .D-----------------R.   .   xor	ecx, ecx
[9,6]     .    .    .    .    .    .    .    .DeeeeeeE----------R.   .   vmovaps	xmm0, xmmword ptr [r12 + rcx]
[9,7]     .    .    .    .    .    .    .    .D======eeeeE------R.   .   cvtps2dq	xmm0, xmm0
[9,8]     .    .    .    .    .    .    .    .D=eeeeeeE---------R.   .   vmovaps	xmm1, xmmword ptr [rbx + rcx]
[9,9]     .    .    .    .    .    .    .    .D=======eeeeE-----R.   .   cvtps2dq	xmm1, xmm1
[9,10]    .    .    .    .    .    .    .    . D==========eE----R.   .   vpunpckhdq	xmm2, xmm0, xmm1
[9,11]    .    .    .    .    .    .    .    . D===========eE---R.   .   vpunpckldq	xmm0, xmm0, xmm1
[9,12]    .    .    .    .    .    .    .    . D============eeeER.   .   vinserti128	ymm0, ymm0, xmm2, 1
[9,13]    .    .    .    .    .    .    .    .  D==============eeeeeER   vpmovsdw	xmmword ptr [rax + rcx], ymm0
[9,14]    .    .    .    .    .    .    .    .  DeE------------------R   add	rcx, 16
[9,15]    .    .    .    .    .    .    .    .  D==eE----------------R   add	rdx, -1
[9,16]    .    .    .    .    .    .    .    .   D==eE---------------R   jne	.LBB6_30


```
</details>

<details><summary>Average Wait times (based on the timeline view):</summary>

```
[0]: Executions
[1]: Average time spent waiting in a scheduler's queue
[2]: Average time spent waiting in a scheduler's queue while ready
[3]: Average time elapsed from WB until retire stage

      [0]    [1]    [2]    [3]
0.     10    1.0    1.0    10.8      cmp	dword ptr [rsp + 44], 0
1.     10    1.0    1.0    11.8      mov	rdx, qword ptr [rsp + 224]
2.     10    6.9    0.0    9.9       je	.LBB6_31
3.     10    1.9    1.9    10.9      mov	rax, qword ptr [rsp + 280]
4.     10    6.1    0.0    6.3       mov	rax, qword ptr [rax]
5.     10    0.0    0.0    17.3      xor	ecx, ecx
6.     10    1.0    1.0    10.3      vmovaps	xmm0, xmmword ptr [r12 + rcx]
7.     10    7.0    0.0    6.3       cvtps2dq	xmm0, xmm0
8.     10    1.9    1.9    9.3       vmovaps	xmm1, xmmword ptr [rbx + rcx]
9.     10    7.9    0.0    5.4       cvtps2dq	xmm1, xmm1
10.    10    11.1   0.0    4.5       vpunpckhdq	xmm2, xmm0, xmm1
11.    10    11.3   0.3    4.2       vpunpckldq	xmm0, xmm0, xmm1
12.    10    12.9   0.6    0.9       vinserti128	ymm0, ymm0, xmm2, 1
13.    10    15.0   0.0    0.0       vpmovsdw	xmmword ptr [rax + rcx], ymm0
14.    10    1.0    1.0    17.9      add	rcx, 16
15.    10    3.0    0.0    15.9      add	rdx, -1
16.    10    3.1    0.0    14.9      jne	.LBB6_30
       10    5.4    0.5    9.2       <total>


```
</details>

</details>

<details><summary>[3] Code Region - ProcessPixel</summary>

```
Iterations:        100
Instructions:      20300
Total Cycles:      11145
Total uOps:        22700

Dispatch Width:    6
uOps Per Cycle:    2.04
IPC:               1.82
Block RThroughput: 66.5


Cycles with backend pressure increase [ 91.38% ]
Throughput Bottlenecks: 
  Resource Pressure       [ 53.64% ]
  - ICXPort0  [ 45.56% ]
  - ICXPort1  [ 42.88% ]
  - ICXPort2  [ 1.79% ]
  - ICXPort3  [ 1.79% ]
  - ICXPort5  [ 21.49% ]
  - ICXPort6  [ 0.89% ]
  Data Dependencies:      [ 56.55% ]
  - Register Dependencies [ 56.55% ]
  - Memory Dependencies   [ 0.00% ]

```

<details><summary>Critical sequence based on the simulation:</summary>

```

              Instruction                                 Dependency Information
        0.    mov	edx, ebp
        1.    sub	edx, r14d
        2.    jle	.LBB15_38
        3.    vcvtsi2ss	xmm0, xmm18, edi
        4.    vsubss	xmm0, xmm0, dword ptr [rsp + 112]
        5.    vmulss	xmm1, xmm0, dword ptr [rsp + 44]
        6.    vbroadcastss	xmm11, xmm1
        7.    vmulss	xmm0, xmm0, dword ptr [rsp + 40]
        8.    vbroadcastss	xmm12, xmm0
        9.    mov	r12d, r14d
        10.   kmovq	k2, k0
        11.   vmovaps	xmm13, xmmword ptr [rsp + 96]
        12.   mov	r11, r13
        13.   jmp	.LBB15_42
        14.   add	r11, 16
        15.   add	r12d, 4
        16.   cmp	r12d, ebp
        17.   jge	.LBB15_38
        18.   vmulps	xmm0, xmm28, xmm13
        19.   vaddps	xmm1, xmm11, xmm0
        20.   vmulps	xmm0, xmm29, xmm13
        21.   vaddps	xmm2, xmm12, xmm0
        22.   vbroadcastss	xmm0, dword ptr [rip + .LCPI15_4]
        23.   vcmpleps	k2 {k2}, xmm1, xmm0
        24.   vcmpleps	k2 {k2}, xmm6, xmm1
        25.   vcmpleps	k2 {k2}, xmm6, xmm2
        26.   vcmpleps	k2 {k2}, xmm2, xmm0
        27.   vmaxps	xmm1, xmm1, xmm6
        28.   vminps	xmm1, xmm1, xmm0
        29.   vmulps	xmm1, xmm31, xmm1
        30.   vmaxps	xmm2, xmm2, xmm6
        31.   vminps	xmm2, xmm2, xmm0
        32.   vmulps	xmm2, xmm16, xmm2
 +----< 33.   vbroadcastss	xmm3, dword ptr [rip + .LCPI15_5]
 |      34.   vaddps	xmm1, xmm1, xmm3
 +----> 35.   vaddps	xmm2, xmm2, xmm3                  ## REGISTER dependency:  xmm3
 |      36.   vcvttps2dq	xmm3, xmm1
 |      37.   vcvtdq2ps	xmm4, xmm3
 |      38.   vsubps	xmm15, xmm1, xmm4
 +----> 39.   vcvttps2dq	xmm1, xmm2                        ## REGISTER dependency:  xmm2
 +----> 40.   vcvtdq2ps	xmm4, xmm1                        ## REGISTER dependency:  xmm1
 |      41.   vsubps	xmm17, xmm2, xmm4
 |      42.   vpslld	xmm2, xmm3, 2
 +----> 43.   vpmulld	xmm1, xmm30, xmm1                 ## RESOURCE interference:  ICXPort0 [ probability: 100% ]
 +----> 44.   vpaddd	xmm4, xmm2, xmm1                  ## REGISTER dependency:  xmm1
 |      45.   vpmovsxdq	ymm1, xmm4
 |      46.   vpaddq	ymm1, ymm10, ymm1
 |      47.   vmovq	rcx, xmm1
 |      48.   vpextrq	r8, xmm1, 1
 |      49.   vextracti128	xmm1, ymm1, 1
 |      50.   vmovq	r10, xmm1
 |      51.   vpextrq	r15, xmm1, 1
 |      52.   vmovd	xmm1, dword ptr [rcx + 4]
 |      53.   vpinsrd	xmm1, xmm1, dword ptr [r8 + 4], 1
 |      54.   vpinsrd	xmm1, xmm1, dword ptr [r10 + 4], 2
 |      55.   kxnorw	k3, k0, k0
 |      56.   vpinsrd	xmm1, xmm1, dword ptr [r15 + 4], 3
 |      57.   vmovd	xmm2, dword ptr [rcx + rbx]
 |      58.   vpinsrd	xmm2, xmm2, dword ptr [r8 + rbx], 1
 |      59.   vpinsrd	xmm2, xmm2, dword ptr [r10 + rbx], 2
 |      60.   vpxor	xmm14, xmm14, xmm14
 |      61.   vpinsrd	xmm2, xmm2, dword ptr [r15 + rbx], 3
 |      62.   vmovd	xmm3, dword ptr [rcx + rbx + 4]
 |      63.   vpinsrd	xmm3, xmm3, dword ptr [r8 + rbx + 4], 1
 |      64.   vpinsrd	xmm3, xmm3, dword ptr [r10 + rbx + 4], 2
 |      65.   vpinsrd	xmm3, xmm3, dword ptr [r15 + rbx + 4], 3
 |      66.   vpbroadcastw	xmm9, word ptr [rip + .LCPI15_6]
 +----> 67.   vpgatherdd	xmm14 {k3}, xmmword ptr [rsi + xmm4] ## REGISTER dependency:  xmm4
 |      68.   vpand	xmm4, xmm14, xmm9
 |      69.   vpmullw	xmm7, xmm4, xmm4
 +----> 70.   vpsrlw	xmm4, xmm14, 8                    ## REGISTER dependency:  xmm14
 +----> 71.   vpmullw	xmm8, xmm4, xmm4                  ## REGISTER dependency:  xmm4
 |      72.   vpand	xmm4, xmm9, xmm1
 |      73.   vpmullw	xmm5, xmm4, xmm4
 |      74.   vpand	xmm4, xmm9, xmm2
 |      75.   vpmullw	xmm4, xmm4, xmm4
 |      76.   vpand	xmm9, xmm9, xmm3
 |      77.   vpmullw	xmm9, xmm9, xmm9
 |      78.   vpsrld	xmm21, xmm7, 16
 |      79.   vcvtdq2ps	xmm21, xmm21
 |      80.   vsubps	xmm22, xmm0, xmm15
 |      81.   vsubps	xmm23, xmm0, xmm17
 |      82.   vmulps	xmm20, xmm23, xmm22
 |      83.   vmulps	xmm23, xmm15, xmm23
 |      84.   vmulps	xmm22, xmm17, xmm22
 |      85.   vmulps	xmm17, xmm17, xmm15
 |      86.   vpsrld	xmm15, xmm5, 16
 |      87.   vcvtdq2ps	xmm15, xmm15
 |      88.   vmulps	xmm21, xmm20, xmm21
 |      89.   vmulps	xmm15, xmm23, xmm15
 |      90.   vaddps	xmm21, xmm21, xmm15
 |      91.   vpsrld	xmm15, xmm4, 16
 |      92.   vcvtdq2ps	xmm15, xmm15
 |      93.   vmulps	xmm15, xmm22, xmm15
 |      94.   vaddps	xmm21, xmm21, xmm15
 |      95.   vpsrld	xmm15, xmm9, 16
 |      96.   vcvtdq2ps	xmm15, xmm15
 |      97.   vmulps	xmm15, xmm17, xmm15
 |      98.   vaddps	xmm21, xmm21, xmm15
 |      99.   vpsrlw	xmm15, xmm1, 8
 |      100.  vpmullw	xmm15, xmm15, xmm15
 |      101.  vpblendw	xmm8, xmm8, xmm6, 170
 |      102.  vcvtdq2ps	xmm8, xmm8
 |      103.  vpblendw	xmm15, xmm15, xmm6, 170
 |      104.  vcvtdq2ps	xmm15, xmm15
 |      105.  vmulps	xmm8, xmm20, xmm8
 |      106.  vmulps	xmm15, xmm23, xmm15
 |      107.  vaddps	xmm8, xmm8, xmm15
 +----> 108.  vpsrlw	xmm15, xmm2, 8                    ## RESOURCE interference:  ICXPort0 [ probability: 100% ]
 +----> 109.  vpmullw	xmm15, xmm15, xmm15               ## REGISTER dependency:  xmm15
 +----> 110.  vpblendw	xmm15, xmm15, xmm6, 170           ## REGISTER dependency:  xmm15
 +----> 111.  vcvtdq2ps	xmm15, xmm15                      ## REGISTER dependency:  xmm15
 +----> 112.  vmulps	xmm15, xmm22, xmm15               ## REGISTER dependency:  xmm15
 |      113.  vaddps	xmm8, xmm8, xmm15
 |      114.  vpsrlw	xmm15, xmm3, 8
 +----> 115.  vpmullw	xmm15, xmm15, xmm15               ## RESOURCE interference:  ICXPort1 [ probability: 100% ]
 +----> 116.  vpblendw	xmm15, xmm15, xmm6, 170           ## REGISTER dependency:  xmm15
 +----> 117.  vcvtdq2ps	xmm15, xmm15                      ## REGISTER dependency:  xmm15
 +----> 118.  vmulps	xmm15, xmm17, xmm15               ## REGISTER dependency:  xmm15
 |      119.  vaddps	xmm8, xmm8, xmm15
 |      120.  vpblendw	xmm7, xmm7, xmm6, 170
 |      121.  vcvtdq2ps	xmm7, xmm7
 |      122.  vpblendw	xmm5, xmm5, xmm6, 170
 |      123.  vcvtdq2ps	xmm5, xmm5
 |      124.  vmulps	xmm7, xmm20, xmm7
 |      125.  vmulps	xmm5, xmm23, xmm5
 |      126.  vaddps	xmm5, xmm7, xmm5
 |      127.  vpblendw	xmm4, xmm4, xmm6, 170
 |      128.  vcvtdq2ps	xmm4, xmm4
 |      129.  vmulps	xmm4, xmm22, xmm4
 |      130.  vaddps	xmm4, xmm5, xmm4
 |      131.  vpblendw	xmm5, xmm9, xmm6, 170
 |      132.  vcvtdq2ps	xmm5, xmm5
 |      133.  vmulps	xmm5, xmm17, xmm5
 |      134.  vaddps	xmm5, xmm4, xmm5
 |      135.  vpsrld	xmm4, xmm14, 24
 |      136.  vcvtdq2ps	xmm4, xmm4
 |      137.  vmulps	xmm4, xmm20, xmm4
 |      138.  vpsrld	xmm1, xmm1, 24
 |      139.  vcvtdq2ps	xmm1, xmm1
 |      140.  vmulps	xmm1, xmm23, xmm1
 |      141.  vaddps	xmm1, xmm4, xmm1
 +----> 142.  vpsrld	xmm2, xmm2, 24                    ## RESOURCE interference:  ICXPort0 [ probability: 100% ]
 |      143.  vcvtdq2ps	xmm2, xmm2
 |      144.  vmulps	xmm2, xmm22, xmm2
 |      145.  vaddps	xmm1, xmm1, xmm2
 +----> 146.  vpsrld	xmm2, xmm3, 24                    ## RESOURCE interference:  ICXPort1 [ probability: 100% ]
 +----> 147.  vcvtdq2ps	xmm2, xmm2                        ## REGISTER dependency:  xmm2
 +----> 148.  vmulps	xmm2, xmm17, xmm2                 ## REGISTER dependency:  xmm2
 |      149.  vmovdqu	xmm4, xmmword ptr [r11]
 |      150.  vmulps	xmm3, xmm24, xmm21
 |      151.  vmulps	xmm17, xmm25, xmm8
 |      152.  vmulps	xmm5, xmm26, xmm5
 +----> 153.  vaddps	xmm1, xmm1, xmm2                  ## REGISTER dependency:  xmm2
 +----> 154.  vmulps	xmm20, xmm27, xmm1                ## REGISTER dependency:  xmm1
 |      155.  vmaxps	xmm1, xmm3, xmm6
 |      156.  vbroadcastss	xmm2, dword ptr [rip + .LCPI15_10]
 |      157.  vminps	xmm1, xmm1, xmm2
 |      158.  vmaxps	xmm3, xmm17, xmm6
 |      159.  vminps	xmm3, xmm3, xmm2
 |      160.  vmaxps	xmm5, xmm5, xmm6
 |      161.  vminps	xmm5, xmm5, xmm2
 +----> 162.  vmulps	xmm2, xmm20, dword ptr [rip + .LCPI15_11]{1to4} ## RESOURCE interference:  ICXPort0 [ probability: 99% ]
 +----> 163.  vaddps	xmm17, xmm2, xmm0                 ## REGISTER dependency:  xmm2
 |      164.  vpshufb	xmm0, xmm4, xmm19
 |      165.  vcvtdq2ps	xmm0, xmm0
 |      166.  vmulps	xmm0, xmm0, xmm0
 +----> 167.  vmulps	xmm0, xmm0, xmm17                 ## REGISTER dependency:  xmm17
 |      168.  vaddps	xmm1, xmm0, xmm1
 |      169.  vpshufb	xmm0, xmm4, xmm18
 |      170.  vcvtdq2ps	xmm0, xmm0
 |      171.  vmulps	xmm0, xmm0, xmm0
 |      172.  vmulps	xmm0, xmm0, xmm17
 |      173.  vaddps	xmm2, xmm0, xmm3
 |      174.  vpandd	xmm0, xmm4, dword ptr [rip + .LCPI15_7]{1to4}
 |      175.  vcvtdq2ps	xmm0, xmm0
 |      176.  vmulps	xmm0, xmm0, xmm0
 +----> 177.  vmulps	xmm0, xmm0, xmm17                 ## RESOURCE interference:  ICXPort1 [ probability: 99% ]
 |      178.  vaddps	xmm3, xmm0, xmm5
 |      179.  vmovaps	xmm0, xmm1
 |      180.  rsqrtps	xmm0, xmm0
 |      181.  vmulps	xmm1, xmm0, xmm1
 |      182.  vmovaps	xmm0, xmm2
 |      183.  rsqrtps	xmm0, xmm0
 |      184.  vmulps	xmm2, xmm0, xmm2
 |      185.  vmovaps	xmm0, xmm3
 |      186.  rsqrtps	xmm0, xmm0
 |      187.  vmulps	xmm0, xmm0, xmm3
 |      188.  cvtps2dq	xmm1, xmm1
 |      189.  cvtps2dq	xmm2, xmm2
 |      190.  cvtps2dq	xmm0, xmm0
 |      191.  vpslld	xmm1, xmm1, 16
 |      192.  vpslld	xmm2, xmm2, 8
 |      193.  vpternlogd	xmm2, xmm0, xmm1, 254
 |      194.  vpsrld	xmm0, xmm4, 24
 |      195.  vcvtdq2ps	xmm0, xmm0
 +----> 196.  vmulps	xmm0, xmm17, xmm0                 ## RESOURCE interference:  ICXPort1 [ probability: 99% ]
 +----> 197.  vaddps	xmm0, xmm20, xmm0                 ## REGISTER dependency:  xmm0
 +----> 198.  cvtps2dq	xmm0, xmm0                        ## REGISTER dependency:  xmm0
 +----> 199.  vpslld	xmm0, xmm0, 24                    ## REGISTER dependency:  xmm0
 +----> 200.  vpord	xmm4 {k2}, xmm2, xmm0             ## REGISTER dependency:  xmm0
 +----> 201.  vmovdqa	xmmword ptr [r11], xmm4           ## REGISTER dependency:  xmm4
        202.  kxnorw	k2, k0, k0


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
 1      1     0.25                        mov	edx, ebp
 1      1     0.25                        sub	edx, r14d
 1      1     0.50                        jle	.LBB15_38
 2      5     1.00                        vcvtsi2ss	xmm0, xmm18, edi
 2      9     0.50    *                   vsubss	xmm0, xmm0, dword ptr [rsp + 112]
 2      9     0.50    *                   vmulss	xmm1, xmm0, dword ptr [rsp + 44]
 1      1     0.50                        vbroadcastss	xmm11, xmm1
 2      9     0.50    *                   vmulss	xmm0, xmm0, dword ptr [rsp + 40]
 1      1     0.50                        vbroadcastss	xmm12, xmm0
 1      1     0.25                        mov	r12d, r14d
 1      1     1.00                        kmovq	k2, k0
 1      6     0.50    *                   vmovaps	xmm13, xmmword ptr [rsp + 96]
 1      1     0.25                        mov	r11, r13
 1      1     0.50                        jmp	.LBB15_42
 1      1     0.25                        add	r11, 16
 1      1     0.25                        add	r12d, 4
 1      1     0.25                        cmp	r12d, ebp
 1      1     0.50                        jge	.LBB15_38
 1      4     0.50                        vmulps	xmm0, xmm28, xmm13
 1      4     0.50                        vaddps	xmm1, xmm11, xmm0
 1      4     0.50                        vmulps	xmm0, xmm29, xmm13
 1      4     0.50                        vaddps	xmm2, xmm12, xmm0
 1      6     0.50    *                   vbroadcastss	xmm0, dword ptr [rip + .LCPI15_4]
 1      4     1.00                        vcmpleps	k2 {k2}, xmm1, xmm0
 1      4     1.00                        vcmpleps	k2 {k2}, xmm6, xmm1
 1      4     1.00                        vcmpleps	k2 {k2}, xmm6, xmm2
 1      4     1.00                        vcmpleps	k2 {k2}, xmm2, xmm0
 1      4     0.50                        vmaxps	xmm1, xmm1, xmm6
 1      4     0.50                        vminps	xmm1, xmm1, xmm0
 1      4     0.50                        vmulps	xmm1, xmm31, xmm1
 1      4     0.50                        vmaxps	xmm2, xmm2, xmm6
 1      4     0.50                        vminps	xmm2, xmm2, xmm0
 1      4     0.50                        vmulps	xmm2, xmm16, xmm2
 1      6     0.50    *                   vbroadcastss	xmm3, dword ptr [rip + .LCPI15_5]
 1      4     0.50                        vaddps	xmm1, xmm1, xmm3
 1      4     0.50                        vaddps	xmm2, xmm2, xmm3
 1      4     0.50                        vcvttps2dq	xmm3, xmm1
 1      4     0.50                        vcvtdq2ps	xmm4, xmm3
 1      4     0.50                        vsubps	xmm15, xmm1, xmm4
 1      4     0.50                        vcvttps2dq	xmm1, xmm2
 1      4     0.50                        vcvtdq2ps	xmm4, xmm1
 1      4     0.50                        vsubps	xmm17, xmm2, xmm4
 1      1     0.50                        vpslld	xmm2, xmm3, 2
 2      10    1.00                        vpmulld	xmm1, xmm30, xmm1
 1      1     0.33                        vpaddd	xmm4, xmm2, xmm1
 1      3     1.00                        vpmovsxdq	ymm1, xmm4
 1      1     0.33                        vpaddq	ymm1, ymm10, ymm1
 1      2     1.00                        vmovq	rcx, xmm1
 2      3     1.00                        vpextrq	r8, xmm1, 1
 1      3     1.00                        vextracti128	xmm1, ymm1, 1
 1      2     1.00                        vmovq	r10, xmm1
 2      3     1.00                        vpextrq	r15, xmm1, 1
 1      5     0.50    *                   vmovd	xmm1, dword ptr [rcx + 4]
 2      6     1.00    *                   vpinsrd	xmm1, xmm1, dword ptr [r8 + 4], 1
 2      6     1.00    *                   vpinsrd	xmm1, xmm1, dword ptr [r10 + 4], 2
 1      1     1.00                        kxnorw	k3, k0, k0
 2      6     1.00    *                   vpinsrd	xmm1, xmm1, dword ptr [r15 + 4], 3
 1      5     0.50    *                   vmovd	xmm2, dword ptr [rcx + rbx]
 2      6     1.00    *                   vpinsrd	xmm2, xmm2, dword ptr [r8 + rbx], 1
 2      6     1.00    *                   vpinsrd	xmm2, xmm2, dword ptr [r10 + rbx], 2
 1      0     0.17                        vpxor	xmm14, xmm14, xmm14
 2      6     1.00    *                   vpinsrd	xmm2, xmm2, dword ptr [r15 + rbx], 3
 1      5     0.50    *                   vmovd	xmm3, dword ptr [rcx + rbx + 4]
 2      6     1.00    *                   vpinsrd	xmm3, xmm3, dword ptr [r8 + rbx + 4], 1
 2      6     1.00    *                   vpinsrd	xmm3, xmm3, dword ptr [r10 + rbx + 4], 2
 2      6     1.00    *                   vpinsrd	xmm3, xmm3, dword ptr [r15 + rbx + 4], 3
 2      7     1.00    *                   vpbroadcastw	xmm9, word ptr [rip + .LCPI15_6]
 5      19    2.00    *                   vpgatherdd	xmm14 {k3}, xmmword ptr [rsi + xmm4]
 1      1     0.33                        vpand	xmm4, xmm14, xmm9
 1      5     0.50                        vpmullw	xmm7, xmm4, xmm4
 1      1     0.50                        vpsrlw	xmm4, xmm14, 8
 1      5     0.50                        vpmullw	xmm8, xmm4, xmm4
 1      1     0.33                        vpand	xmm4, xmm9, xmm1
 1      5     0.50                        vpmullw	xmm5, xmm4, xmm4
 1      1     0.33                        vpand	xmm4, xmm9, xmm2
 1      5     0.50                        vpmullw	xmm4, xmm4, xmm4
 1      1     0.33                        vpand	xmm9, xmm9, xmm3
 1      5     0.50                        vpmullw	xmm9, xmm9, xmm9
 1      1     0.50                        vpsrld	xmm21, xmm7, 16
 1      4     0.50                        vcvtdq2ps	xmm21, xmm21
 1      4     0.50                        vsubps	xmm22, xmm0, xmm15
 1      4     0.50                        vsubps	xmm23, xmm0, xmm17
 1      4     0.50                        vmulps	xmm20, xmm23, xmm22
 1      4     0.50                        vmulps	xmm23, xmm15, xmm23
 1      4     0.50                        vmulps	xmm22, xmm17, xmm22
 1      4     0.50                        vmulps	xmm17, xmm17, xmm15
 1      1     0.50                        vpsrld	xmm15, xmm5, 16
 1      4     0.50                        vcvtdq2ps	xmm15, xmm15
 1      4     0.50                        vmulps	xmm21, xmm20, xmm21
 1      4     0.50                        vmulps	xmm15, xmm23, xmm15
 1      4     0.50                        vaddps	xmm21, xmm21, xmm15
 1      1     0.50                        vpsrld	xmm15, xmm4, 16
 1      4     0.50                        vcvtdq2ps	xmm15, xmm15
 1      4     0.50                        vmulps	xmm15, xmm22, xmm15
 1      4     0.50                        vaddps	xmm21, xmm21, xmm15
 1      1     0.50                        vpsrld	xmm15, xmm9, 16
 1      4     0.50                        vcvtdq2ps	xmm15, xmm15
 1      4     0.50                        vmulps	xmm15, xmm17, xmm15
 1      4     0.50                        vaddps	xmm21, xmm21, xmm15
 1      1     0.50                        vpsrlw	xmm15, xmm1, 8
 1      5     0.50                        vpmullw	xmm15, xmm15, xmm15
 1      1     1.00                        vpblendw	xmm8, xmm8, xmm6, 170
 1      4     0.50                        vcvtdq2ps	xmm8, xmm8
 1      1     1.00                        vpblendw	xmm15, xmm15, xmm6, 170
 1      4     0.50                        vcvtdq2ps	xmm15, xmm15
 1      4     0.50                        vmulps	xmm8, xmm20, xmm8
 1      4     0.50                        vmulps	xmm15, xmm23, xmm15
 1      4     0.50                        vaddps	xmm8, xmm8, xmm15
 1      1     0.50                        vpsrlw	xmm15, xmm2, 8
 1      5     0.50                        vpmullw	xmm15, xmm15, xmm15
 1      1     1.00                        vpblendw	xmm15, xmm15, xmm6, 170
 1      4     0.50                        vcvtdq2ps	xmm15, xmm15
 1      4     0.50                        vmulps	xmm15, xmm22, xmm15
 1      4     0.50                        vaddps	xmm8, xmm8, xmm15
 1      1     0.50                        vpsrlw	xmm15, xmm3, 8
 1      5     0.50                        vpmullw	xmm15, xmm15, xmm15
 1      1     1.00                        vpblendw	xmm15, xmm15, xmm6, 170
 1      4     0.50                        vcvtdq2ps	xmm15, xmm15
 1      4     0.50                        vmulps	xmm15, xmm17, xmm15
 1      4     0.50                        vaddps	xmm8, xmm8, xmm15
 1      1     1.00                        vpblendw	xmm7, xmm7, xmm6, 170
 1      4     0.50                        vcvtdq2ps	xmm7, xmm7
 1      1     1.00                        vpblendw	xmm5, xmm5, xmm6, 170
 1      4     0.50                        vcvtdq2ps	xmm5, xmm5
 1      4     0.50                        vmulps	xmm7, xmm20, xmm7
 1      4     0.50                        vmulps	xmm5, xmm23, xmm5
 1      4     0.50                        vaddps	xmm5, xmm7, xmm5
 1      1     1.00                        vpblendw	xmm4, xmm4, xmm6, 170
 1      4     0.50                        vcvtdq2ps	xmm4, xmm4
 1      4     0.50                        vmulps	xmm4, xmm22, xmm4
 1      4     0.50                        vaddps	xmm4, xmm5, xmm4
 1      1     1.00                        vpblendw	xmm5, xmm9, xmm6, 170
 1      4     0.50                        vcvtdq2ps	xmm5, xmm5
 1      4     0.50                        vmulps	xmm5, xmm17, xmm5
 1      4     0.50                        vaddps	xmm5, xmm4, xmm5
 1      1     0.50                        vpsrld	xmm4, xmm14, 24
 1      4     0.50                        vcvtdq2ps	xmm4, xmm4
 1      4     0.50                        vmulps	xmm4, xmm20, xmm4
 1      1     0.50                        vpsrld	xmm1, xmm1, 24
 1      4     0.50                        vcvtdq2ps	xmm1, xmm1
 1      4     0.50                        vmulps	xmm1, xmm23, xmm1
 1      4     0.50                        vaddps	xmm1, xmm4, xmm1
 1      1     0.50                        vpsrld	xmm2, xmm2, 24
 1      4     0.50                        vcvtdq2ps	xmm2, xmm2
 1      4     0.50                        vmulps	xmm2, xmm22, xmm2
 1      4     0.50                        vaddps	xmm1, xmm1, xmm2
 1      1     0.50                        vpsrld	xmm2, xmm3, 24
 1      4     0.50                        vcvtdq2ps	xmm2, xmm2
 1      4     0.50                        vmulps	xmm2, xmm17, xmm2
 1      6     0.50    *                   vmovdqu	xmm4, xmmword ptr [r11]
 1      4     0.50                        vmulps	xmm3, xmm24, xmm21
 1      4     0.50                        vmulps	xmm17, xmm25, xmm8
 1      4     0.50                        vmulps	xmm5, xmm26, xmm5
 1      4     0.50                        vaddps	xmm1, xmm1, xmm2
 1      4     0.50                        vmulps	xmm20, xmm27, xmm1
 1      4     0.50                        vmaxps	xmm1, xmm3, xmm6
 1      6     0.50    *                   vbroadcastss	xmm2, dword ptr [rip + .LCPI15_10]
 1      4     0.50                        vminps	xmm1, xmm1, xmm2
 1      4     0.50                        vmaxps	xmm3, xmm17, xmm6
 1      4     0.50                        vminps	xmm3, xmm3, xmm2
 1      4     0.50                        vmaxps	xmm5, xmm5, xmm6
 1      4     0.50                        vminps	xmm5, xmm5, xmm2
 2      10    0.50    *                   vmulps	xmm2, xmm20, dword ptr [rip + .LCPI15_11]{1to4}
 1      4     0.50                        vaddps	xmm17, xmm2, xmm0
 1      1     0.50                        vpshufb	xmm0, xmm4, xmm19
 1      4     0.50                        vcvtdq2ps	xmm0, xmm0
 1      4     0.50                        vmulps	xmm0, xmm0, xmm0
 1      4     0.50                        vmulps	xmm0, xmm0, xmm17
 1      4     0.50                        vaddps	xmm1, xmm0, xmm1
 1      1     0.50                        vpshufb	xmm0, xmm4, xmm18
 1      4     0.50                        vcvtdq2ps	xmm0, xmm0
 1      4     0.50                        vmulps	xmm0, xmm0, xmm0
 1      4     0.50                        vmulps	xmm0, xmm0, xmm17
 1      4     0.50                        vaddps	xmm2, xmm0, xmm3
 2      7     0.50    *                   vpandd	xmm0, xmm4, dword ptr [rip + .LCPI15_7]{1to4}
 1      4     0.50                        vcvtdq2ps	xmm0, xmm0
 1      4     0.50                        vmulps	xmm0, xmm0, xmm0
 1      4     0.50                        vmulps	xmm0, xmm0, xmm17
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
 1      1     0.50                        vpsrld	xmm0, xmm4, 24
 1      4     0.50                        vcvtdq2ps	xmm0, xmm0
 1      4     0.50                        vmulps	xmm0, xmm17, xmm0
 1      4     0.50                        vaddps	xmm0, xmm20, xmm0
 1      4     0.50                        cvtps2dq	xmm0, xmm0
 1      1     0.50                        vpslld	xmm0, xmm0, 24
 1      1     0.33                        vpord	xmm4 {k2}, xmm2, xmm0
 2      1     0.50           *            vmovdqa	xmmword ptr [r11], xmm4
 1      1     1.00                        kxnorw	k2, k0, k0


```
</details>

<details><summary>Dynamic Dispatch Stall Cycles:</summary>

```
RAT     - Register unavailable:                      0
RCU     - Retire tokens unavailable:                 0
SCHEDQ  - Scheduler full:                            10471  (94.0%)
LQ      - Load queue full:                           0
SQ      - Store queue full:                          0
GROUP   - Static restrictions on the dispatch group: 0
USH     - Uncategorised Structural Hazard:           0


```
</details>

<details><summary>Dispatch Logic - number of cycles where we saw N micro opcodes dispatched:</summary>

```
[# dispatched], [# cycles]
 0,              1963  (17.6%)
 1,              1896  (17.0%)
 2,              3386  (30.4%)
 3,              2293  (20.6%)
 4,              994  (8.9%)
 5,              501  (4.5%)
 6,              112  (1.0%)


```
</details>

<details><summary>Schedulers - number of cycles where we saw N micro opcodes issued:</summary>

```
[# issued], [# cycles]
 0,          1934  (17.4%)
 1,          811  (7.3%)
 2,          4609  (41.4%)
 3,          2694  (24.2%)
 4,          996  (8.9%)
 5,          1  (0.0%)
 6,          100  (0.9%)

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
 0,           6432  (57.7%)
 1,           1811  (16.2%)
 2,           1100  (9.9%)
 3,           399  (3.6%)
 4,           401  (3.6%)
 5,           1  (0.0%)
 6,           100  (0.9%)
 7,           100  (0.9%)
 8,           200  (1.8%)
 9,           100  (0.9%)
 10,          101  (0.9%)
 11,          100  (0.9%)
 13,          1  (0.0%)
 15,          100  (0.9%)
 21,          100  (0.9%)
 40,          99  (0.9%)

```
</details>

<details><summary>Total ROB Entries:                352</summary>

```
Max Used ROB Entries:             137  ( 38.9% )
Average Used ROB Entries per cy:  105  ( 29.8% )


```
</details>

<details><summary>Register File statistics:</summary>

```
Total number of mappings created:    20200
Max number of mappings used:         114


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
 -      -     76.02  71.02  15.00  12.00  0.50   44.97  6.99   0.50   0.50   0.50   

Resource pressure by instruction:
[0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   Instructions:
 -      -      -      -      -      -      -      -     1.00    -      -      -     mov	edx, ebp
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     sub	edx, r14d
 -      -      -      -      -      -      -      -     1.00    -      -      -     jle	.LBB15_38
 -      -     0.99   0.01    -      -      -     1.00    -      -      -      -     vcvtsi2ss	xmm0, xmm18, edi
 -      -     0.99   0.01    -     1.00    -      -      -      -      -      -     vsubss	xmm0, xmm0, dword ptr [rsp + 112]
 -      -      -     1.00   0.01   0.99    -      -      -      -      -      -     vmulss	xmm1, xmm0, dword ptr [rsp + 44]
 -      -      -      -      -      -      -     1.00    -      -      -      -     vbroadcastss	xmm11, xmm1
 -      -     1.00    -     0.99   0.01    -      -      -      -      -      -     vmulss	xmm0, xmm0, dword ptr [rsp + 40]
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     vbroadcastss	xmm12, xmm0
 -      -      -      -      -      -      -     1.00    -      -      -      -     mov	r12d, r14d
 -      -     1.00    -      -      -      -      -      -      -      -      -     kmovq	k2, k0
 -      -      -      -     1.00    -      -      -      -      -      -      -     vmovaps	xmm13, xmmword ptr [rsp + 96]
 -      -      -      -      -      -      -     0.99   0.01    -      -      -     mov	r11, r13
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     jmp	.LBB15_42
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     add	r11, 16
 -      -      -      -      -      -      -     0.01   0.99    -      -      -     add	r12d, 4
 -      -      -      -      -      -      -     0.99   0.01    -      -      -     cmp	r12d, ebp
 -      -      -      -      -      -      -      -     1.00    -      -      -     jge	.LBB15_38
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm28, xmm13
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vaddps	xmm1, xmm11, xmm0
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm29, xmm13
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vaddps	xmm2, xmm12, xmm0
 -      -      -      -      -     1.00    -      -      -      -      -      -     vbroadcastss	xmm0, dword ptr [rip + .LCPI15_4]
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpleps	k2 {k2}, xmm1, xmm0
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpleps	k2 {k2}, xmm6, xmm1
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpleps	k2 {k2}, xmm6, xmm2
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpleps	k2 {k2}, xmm2, xmm0
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmaxps	xmm1, xmm1, xmm6
 -      -      -     1.00    -      -      -      -      -      -      -      -     vminps	xmm1, xmm1, xmm0
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm1, xmm31, xmm1
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmaxps	xmm2, xmm2, xmm6
 -      -     1.00    -      -      -      -      -      -      -      -      -     vminps	xmm2, xmm2, xmm0
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulps	xmm2, xmm16, xmm2
 -      -      -      -     1.00    -      -      -      -      -      -      -     vbroadcastss	xmm3, dword ptr [rip + .LCPI15_5]
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm1, xmm1, xmm3
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vaddps	xmm2, xmm2, xmm3
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vcvttps2dq	xmm3, xmm1
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm4, xmm3
 -      -      -     1.00    -      -      -      -      -      -      -      -     vsubps	xmm15, xmm1, xmm4
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvttps2dq	xmm1, xmm2
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm4, xmm1
 -      -     1.00    -      -      -      -      -      -      -      -      -     vsubps	xmm17, xmm2, xmm4
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpslld	xmm2, xmm3, 2
 -      -     2.00    -      -      -      -      -      -      -      -      -     vpmulld	xmm1, xmm30, xmm1
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpaddd	xmm4, xmm2, xmm1
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpmovsxdq	ymm1, xmm4
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpaddq	ymm1, ymm10, ymm1
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmovq	rcx, xmm1
 -      -     1.00    -      -      -      -     1.00    -      -      -      -     vpextrq	r8, xmm1, 1
 -      -      -      -      -      -      -     1.00    -      -      -      -     vextracti128	xmm1, ymm1, 1
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmovq	r10, xmm1
 -      -     1.00    -      -      -      -     1.00    -      -      -      -     vpextrq	r15, xmm1, 1
 -      -      -      -      -     1.00    -      -      -      -      -      -     vmovd	xmm1, dword ptr [rcx + 4]
 -      -      -      -     1.00    -      -     1.00    -      -      -      -     vpinsrd	xmm1, xmm1, dword ptr [r8 + 4], 1
 -      -      -      -      -     1.00    -     1.00    -      -      -      -     vpinsrd	xmm1, xmm1, dword ptr [r10 + 4], 2
 -      -     1.00    -      -      -      -      -      -      -      -      -     kxnorw	k3, k0, k0
 -      -      -      -     1.00    -      -     1.00    -      -      -      -     vpinsrd	xmm1, xmm1, dword ptr [r15 + 4], 3
 -      -      -      -     1.00    -      -      -      -      -      -      -     vmovd	xmm2, dword ptr [rcx + rbx]
 -      -      -      -      -     1.00    -     1.00    -      -      -      -     vpinsrd	xmm2, xmm2, dword ptr [r8 + rbx], 1
 -      -      -      -     1.00    -      -     1.00    -      -      -      -     vpinsrd	xmm2, xmm2, dword ptr [r10 + rbx], 2
 -      -      -      -      -      -      -      -      -      -      -      -     vpxor	xmm14, xmm14, xmm14
 -      -      -      -      -     1.00    -     1.00    -      -      -      -     vpinsrd	xmm2, xmm2, dword ptr [r15 + rbx], 3
 -      -      -      -      -     1.00    -      -      -      -      -      -     vmovd	xmm3, dword ptr [rcx + rbx + 4]
 -      -      -      -     1.00    -      -     1.00    -      -      -      -     vpinsrd	xmm3, xmm3, dword ptr [r8 + rbx + 4], 1
 -      -      -      -      -     1.00    -     1.00    -      -      -      -     vpinsrd	xmm3, xmm3, dword ptr [r10 + rbx + 4], 2
 -      -      -      -     1.00    -      -     1.00    -      -      -      -     vpinsrd	xmm3, xmm3, dword ptr [r15 + rbx + 4], 3
 -      -      -      -      -     1.00    -     1.00    -      -      -      -     vpbroadcastw	xmm9, word ptr [rip + .LCPI15_6]
 -      -     1.00   1.00   4.00    -      -      -     1.00    -      -      -     vpgatherdd	xmm14 {k3}, xmmword ptr [rsi + xmm4]
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpand	xmm4, xmm14, xmm9
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpmullw	xmm7, xmm4, xmm4
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpsrlw	xmm4, xmm14, 8
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpmullw	xmm8, xmm4, xmm4
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpand	xmm4, xmm9, xmm1
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpmullw	xmm5, xmm4, xmm4
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpand	xmm4, xmm9, xmm2
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpmullw	xmm4, xmm4, xmm4
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpand	xmm9, xmm9, xmm3
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpmullw	xmm9, xmm9, xmm9
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpsrld	xmm21, xmm7, 16
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm21, xmm21
 -      -      -     1.00    -      -      -      -      -      -      -      -     vsubps	xmm22, xmm0, xmm15
 -      -     1.00    -      -      -      -      -      -      -      -      -     vsubps	xmm23, xmm0, xmm17
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulps	xmm20, xmm23, xmm22
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmulps	xmm23, xmm15, xmm23
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm22, xmm17, xmm22
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm17, xmm17, xmm15
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpsrld	xmm15, xmm5, 16
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm15, xmm15
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm21, xmm20, xmm21
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm15, xmm23, xmm15
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm21, xmm21, xmm15
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpsrld	xmm15, xmm4, 16
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm15, xmm15
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm15, xmm22, xmm15
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm21, xmm21, xmm15
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpsrld	xmm15, xmm9, 16
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm15, xmm15
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm15, xmm17, xmm15
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm21, xmm21, xmm15
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpsrlw	xmm15, xmm1, 8
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpmullw	xmm15, xmm15, xmm15
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm8, xmm8, xmm6, 170
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm8, xmm8
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm15, xmm15, xmm6, 170
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm15, xmm15
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm8, xmm20, xmm8
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm15, xmm23, xmm15
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm8, xmm8, xmm15
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpsrlw	xmm15, xmm2, 8
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpmullw	xmm15, xmm15, xmm15
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm15, xmm15, xmm6, 170
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm15, xmm15
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm15, xmm22, xmm15
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm8, xmm8, xmm15
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpsrlw	xmm15, xmm3, 8
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpmullw	xmm15, xmm15, xmm15
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm15, xmm15, xmm6, 170
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm15, xmm15
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm15, xmm17, xmm15
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm8, xmm8, xmm15
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm7, xmm7, xmm6, 170
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm7, xmm7
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm5, xmm5, xmm6, 170
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm5, xmm5
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm7, xmm20, xmm7
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm5, xmm23, xmm5
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm5, xmm7, xmm5
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm4, xmm4, xmm6, 170
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm4, xmm4
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm4, xmm22, xmm4
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm4, xmm5, xmm4
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm5, xmm9, xmm6, 170
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm5, xmm5
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm5, xmm17, xmm5
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm5, xmm4, xmm5
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpsrld	xmm4, xmm14, 24
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm4, xmm4
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm4, xmm20, xmm4
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpsrld	xmm1, xmm1, 24
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm1, xmm1
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm1, xmm23, xmm1
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm1, xmm4, xmm1
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpsrld	xmm2, xmm2, 24
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm2, xmm2
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm2, xmm22, xmm2
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm1, xmm1, xmm2
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpsrld	xmm2, xmm3, 24
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm2, xmm2
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm2, xmm17, xmm2
 -      -      -      -      -     1.00    -      -      -      -      -      -     vmovdqu	xmm4, xmmword ptr [r11]
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm3, xmm24, xmm21
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm17, xmm25, xmm8
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm5, xmm26, xmm5
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vaddps	xmm1, xmm1, xmm2
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmulps	xmm20, xmm27, xmm1
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmaxps	xmm1, xmm3, xmm6
 -      -      -      -     1.00    -      -      -      -      -      -      -     vbroadcastss	xmm2, dword ptr [rip + .LCPI15_10]
 -      -      -     1.00    -      -      -      -      -      -      -      -     vminps	xmm1, xmm1, xmm2
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmaxps	xmm3, xmm17, xmm6
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vminps	xmm3, xmm3, xmm2
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmaxps	xmm5, xmm5, xmm6
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vminps	xmm5, xmm5, xmm2
 -      -     0.99   0.01   1.00    -      -      -      -      -      -      -     vmulps	xmm2, xmm20, dword ptr [rip + .LCPI15_11]{1to4}
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vaddps	xmm17, xmm2, xmm0
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpshufb	xmm0, xmm4, xmm19
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm0, xmm0
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm0, xmm0
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm0, xmm17
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm1, xmm0, xmm1
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpshufb	xmm0, xmm4, xmm18
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm0, xmm0
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm0, xmm0, xmm0
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm0, xmm0, xmm17
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm2, xmm0, xmm3
 -      -      -      -      -     1.00    -     1.00    -      -      -      -     vpandd	xmm0, xmm4, dword ptr [rip + .LCPI15_7]{1to4}
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm0, xmm0
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm0, xmm0
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm0, xmm17
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm3, xmm0, xmm5
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovaps	xmm0, xmm1
 -      -     1.00    -      -      -      -      -      -      -      -      -     rsqrtps	xmm0, xmm0
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmulps	xmm1, xmm0, xmm1
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmovaps	xmm0, xmm2
 -      -     1.00    -      -      -      -      -      -      -      -      -     rsqrtps	xmm0, xmm0
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmulps	xmm2, xmm0, xmm2
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovaps	xmm0, xmm3
 -      -     1.00    -      -      -      -      -      -      -      -      -     rsqrtps	xmm0, xmm0
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm0, xmm0, xmm3
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     cvtps2dq	xmm1, xmm1
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     cvtps2dq	xmm2, xmm2
 -      -      -     1.00    -      -      -      -      -      -      -      -     cvtps2dq	xmm0, xmm0
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vpslld	xmm1, xmm1, 16
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vpslld	xmm2, xmm2, 8
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpternlogd	xmm2, xmm0, xmm1, 254
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpsrld	xmm0, xmm4, 24
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm0, xmm0
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm0, xmm17, xmm0
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm0, xmm20, xmm0
 -      -      -     1.00    -      -      -      -      -      -      -      -     cvtps2dq	xmm0, xmm0
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vpslld	xmm0, xmm0, 24
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpord	xmm4 {k2}, xmm2, xmm0
 -      -      -      -      -      -     0.50    -      -     0.50   0.50   0.50   vmovdqa	xmmword ptr [r11], xmm4
 -      -     1.00    -      -      -      -      -      -      -      -      -     kxnorw	k2, k0, k0


```
</details>

<details><summary>Timeline view:</summary>

```
                    0123456789          0123456789          0123456789          0123456789
Index     0123456789          0123456789          0123456789          0123456789          

[0,0]     DeER .    .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   mov	edx, ebp
[0,1]     D=eER.    .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   sub	edx, r14d
[0,2]     D==eER    .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   jle	.LBB15_38
[0,3]     DeeeeeER  .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   vcvtsi2ss	xmm0, xmm18, edi
[0,4]     .DeeeeeeeeeER  .    .    .    .    .    .    .    .    .    .    .    .    .   .   vsubss	xmm0, xmm0, dword ptr [rsp + 112]
[0,5]     .D====eeeeeeeeeER   .    .    .    .    .    .    .    .    .    .    .    .   .   vmulss	xmm1, xmm0, dword ptr [rsp + 44]
[0,6]     .D=============eER  .    .    .    .    .    .    .    .    .    .    .    .   .   vbroadcastss	xmm11, xmm1
[0,7]     . D===eeeeeeeeeE-R  .    .    .    .    .    .    .    .    .    .    .    .   .   vmulss	xmm0, xmm0, dword ptr [rsp + 40]
[0,8]     . D============eER  .    .    .    .    .    .    .    .    .    .    .    .   .   vbroadcastss	xmm12, xmm0
[0,9]     . DeE------------R  .    .    .    .    .    .    .    .    .    .    .    .   .   mov	r12d, r14d
[0,10]    . DeE------------R  .    .    .    .    .    .    .    .    .    .    .    .   .   kmovq	k2, k0
[0,11]    . DeeeeeeE-------R  .    .    .    .    .    .    .    .    .    .    .    .   .   vmovaps	xmm13, xmmword ptr [rsp + 96]
[0,12]    .  DeE-----------R  .    .    .    .    .    .    .    .    .    .    .    .   .   mov	r11, r13
[0,13]    .  DeE-----------R  .    .    .    .    .    .    .    .    .    .    .    .   .   jmp	.LBB15_42
[0,14]    .  D=eE----------R  .    .    .    .    .    .    .    .    .    .    .    .   .   add	r11, 16
[0,15]    .  DeE-----------R  .    .    .    .    .    .    .    .    .    .    .    .   .   add	r12d, 4
[0,16]    .  D=eE----------R  .    .    .    .    .    .    .    .    .    .    .    .   .   cmp	r12d, ebp
[0,17]    .  D==eE---------R  .    .    .    .    .    .    .    .    .    .    .    .   .   jge	.LBB15_38
[0,18]    .   D====eeeeE---R  .    .    .    .    .    .    .    .    .    .    .    .   .   vmulps	xmm0, xmm28, xmm13
[0,19]    .   D===========eeeeER   .    .    .    .    .    .    .    .    .    .    .   .   vaddps	xmm1, xmm11, xmm0
[0,20]    .   D====eeeeE-------R   .    .    .    .    .    .    .    .    .    .    .   .   vmulps	xmm0, xmm29, xmm13
[0,21]    .   D===========eeeeER   .    .    .    .    .    .    .    .    .    .    .   .   vaddps	xmm2, xmm12, xmm0
[0,22]    .   DeeeeeeE---------R   .    .    .    .    .    .    .    .    .    .    .   .   vbroadcastss	xmm0, dword ptr [rip + .LCPI15_4]
[0,23]    .   D===============eeeeER    .    .    .    .    .    .    .    .    .    .   .   vcmpleps	k2 {k2}, xmm1, xmm0
[0,24]    .    D==================eeeeER.    .    .    .    .    .    .    .    .    .   .   vcmpleps	k2 {k2}, xmm6, xmm1
[0,25]    .    D======================eeeeER .    .    .    .    .    .    .    .    .   .   vcmpleps	k2 {k2}, xmm6, xmm2
[0,26]    .    D==========================eeeeER  .    .    .    .    .    .    .    .   .   vcmpleps	k2 {k2}, xmm2, xmm0
[0,27]    .    D==============eeeeE------------R  .    .    .    .    .    .    .    .   .   vmaxps	xmm1, xmm1, xmm6
[0,28]    .    D==================eeeeE--------R  .    .    .    .    .    .    .    .   .   vminps	xmm1, xmm1, xmm0
[0,29]    .    D======================eeeeE----R  .    .    .    .    .    .    .    .   .   vmulps	xmm1, xmm31, xmm1
[0,30]    .    .D=============eeeeE------------R  .    .    .    .    .    .    .    .   .   vmaxps	xmm2, xmm2, xmm6
[0,31]    .    .D=================eeeeE--------R  .    .    .    .    .    .    .    .   .   vminps	xmm2, xmm2, xmm0
[0,32]    .    .D=====================eeeeE----R  .    .    .    .    .    .    .    .   .   vmulps	xmm2, xmm16, xmm2
[0,33]    .    .DeeeeeeE-----------------------R  .    .    .    .    .    .    .    .   .   vbroadcastss	xmm3, dword ptr [rip + .LCPI15_5]
[0,34]    .    .D=========================eeeeER  .    .    .    .    .    .    .    .   .   vaddps	xmm1, xmm1, xmm3
[0,35]    .    .D=========================eeeeER  .    .    .    .    .    .    .    .   .   vaddps	xmm2, xmm2, xmm3
[0,36]    .    . D============================eeeeER   .    .    .    .    .    .    .   .   vcvttps2dq	xmm3, xmm1
[0,37]    .    . D================================eeeeER    .    .    .    .    .    .   .   vcvtdq2ps	xmm4, xmm3
[0,38]    .    . D====================================eeeeER.    .    .    .    .    .   .   vsubps	xmm15, xmm1, xmm4
[0,39]    .    . D============================eeeeE--------R.    .    .    .    .    .   .   vcvttps2dq	xmm1, xmm2
[0,40]    .    . D================================eeeeE----R.    .    .    .    .    .   .   vcvtdq2ps	xmm4, xmm1
[0,41]    .    . D====================================eeeeER.    .    .    .    .    .   .   vsubps	xmm17, xmm2, xmm4
[0,42]    .    .  D================================eE------R.    .    .    .    .    .   .   vpslld	xmm2, xmm3, 2
[0,43]    .    .  D================================eeeeeeeeeeER  .    .    .    .    .   .   vpmulld	xmm1, xmm30, xmm1
[0,44]    .    .  D==========================================eER .    .    .    .    .   .   vpaddd	xmm4, xmm2, xmm1
[0,45]    .    .  D===========================================eeeER   .    .    .    .   .   vpmovsxdq	ymm1, xmm4
[0,46]    .    .  D==============================================eER  .    .    .    .   .   vpaddq	ymm1, ymm10, ymm1
[0,47]    .    .   D==============================================eeER.    .    .    .   .   vmovq	rcx, xmm1
[0,48]    .    .   D===============================================eeeER   .    .    .   .   vpextrq	r8, xmm1, 1
[0,49]    .    .   D==============================================eeeE-R   .    .    .   .   vextracti128	xmm1, ymm1, 1
[0,50]    .    .   D=================================================eeER  .    .    .   .   vmovq	r10, xmm1
[0,51]    .    .    D=================================================eeeER.    .    .   .   vpextrq	r15, xmm1, 1
[0,52]    .    .    D===============================================eeeeeER.    .    .   .   vmovd	xmm1, dword ptr [rcx + 4]
[0,53]    .    .    D==================================================eeeeeeER .    .   .   vpinsrd	xmm1, xmm1, dword ptr [r8 + 4], 1
[0,54]    .    .    .D==================================================eeeeeeER.    .   .   vpinsrd	xmm1, xmm1, dword ptr [r10 + 4], 2
[0,55]    .    .    .DeE-------------------------------------------------------R.    .   .   kxnorw	k3, k0, k0
[0,56]    .    .    .D===================================================eeeeeeER    .   .   vpinsrd	xmm1, xmm1, dword ptr [r15 + 4], 3
[0,57]    .    .    .D==============================================eeeeeE------R    .   .   vmovd	xmm2, dword ptr [rcx + rbx]
[0,58]    .    .    . D===================================================eeeeeeER   .   .   vpinsrd	xmm2, xmm2, dword ptr [r8 + rbx], 1
[0,59]    .    .    . D====================================================eeeeeeER  .   .   vpinsrd	xmm2, xmm2, dword ptr [r10 + rbx], 2
[0,60]    .    .    . D-----------------------------------------------------------R  .   .   vpxor	xmm14, xmm14, xmm14
[0,61]    .    .    .  D====================================================eeeeeeER .   .   vpinsrd	xmm2, xmm2, dword ptr [r15 + rbx], 3
[0,62]    .    .    .  D=============================================eeeeeE--------R .   .   vmovd	xmm3, dword ptr [rcx + rbx + 4]
[0,63]    .    .    .  D=====================================================eeeeeeER.   .   vpinsrd	xmm3, xmm3, dword ptr [r8 + rbx + 4], 1
[0,64]    .    .    .   D=====================================================eeeeeeER   .   vpinsrd	xmm3, xmm3, dword ptr [r10 + rbx + 4], 2
[0,65]    .    .    .   D======================================================eeeeeeER  .   vpinsrd	xmm3, xmm3, dword ptr [r15 + rbx + 4], 3
[0,66]    .    .    .   D=eeeeeeeE----------------------------------------------------R  .   vpbroadcastw	xmm9, word ptr [rip + .LCPI15_6]
[0,67]    .    .    .    D====================================eeeeeeeeeeeeeeeeeeeE----R  .   vpgatherdd	xmm14 {k3}, xmmword ptr [rsi + xmm4]
[0,68]    .    .    .    D=======================================================eE---R  .   vpand	xmm4, xmm14, xmm9
[0,69]    .    .    .    .D=======================================================eeeeeER.   vpmullw	xmm7, xmm4, xmm4
[0,70]    .    .    .    .D======================================================eE-----R.   vpsrlw	xmm4, xmm14, 8
[0,71]    .    .    .    .D=======================================================eeeeeER.   vpmullw	xmm8, xmm4, xmm4
[0,72]    .    .    .    .D====================================================eE-------R.   vpand	xmm4, xmm9, xmm1
[0,73]    .    .    .    .D=====================================================eeeeeE--R.   vpmullw	xmm5, xmm4, xmm4
[0,74]    .    .    .    .D=======================================================eE----R.   vpand	xmm4, xmm9, xmm2
[0,75]    .    .    .    . D=======================================================eeeeeER   vpmullw	xmm4, xmm4, xmm4
[0,76]    .    .    .    . D=========================================================eE--R   vpand	xmm9, xmm9, xmm3
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
0.     10    1.0    1.0    51.3      mov	edx, ebp
1.     10    1.1    0.0    50.4      sub	edx, r14d
2.     10    2.1    0.0    49.5      jle	.LBB15_38
3.     10    10.9   10.9   36.9      vcvtsi2ss	xmm0, xmm18, edi
4.     10    11.8   1.9    31.5      vsubss	xmm0, xmm0, dword ptr [rsp + 112]
5.     10    15.8   0.0    27.9      vmulss	xmm1, xmm0, dword ptr [rsp + 44]
6.     10    24.8   0.0    27.0      vbroadcastss	xmm11, xmm1
7.     10    15.7   0.9    27.1      vmulss	xmm0, xmm0, dword ptr [rsp + 40]
8.     10    24.7   0.0    26.1      vbroadcastss	xmm12, xmm0
9.     10    1.0    1.0    49.8      mov	r12d, r14d
10.    10    10.9   10.9   39.0      kmovq	k2, k0
11.    10    1.0    1.0    43.9      vmovaps	xmm13, xmmword ptr [rsp + 96]
12.    10    1.0    1.0    48.8      mov	r11, r13
13.    10    1.0    1.0    47.9      jmp	.LBB15_42
14.    10    1.1    0.0    47.8      add	r11, 16
15.    10    1.9    1.8    47.0      add	r12d, 4
16.    10    2.9    0.0    46.0      cmp	r12d, ebp
17.    10    3.0    0.0    45.0      jge	.LBB15_38
18.    10    9.5    4.5    35.4      vmulps	xmm0, xmm28, xmm13
19.    10    21.9   0.0    23.4      vaddps	xmm1, xmm11, xmm0
20.    10    10.4   5.4    34.9      vmulps	xmm0, xmm29, xmm13
21.    10    21.9   0.0    22.5      vaddps	xmm2, xmm12, xmm0
22.    10    1.0    1.0    41.4      vbroadcastss	xmm0, dword ptr [rip + .LCPI15_4]
23.    10    25.0   0.0    19.8      vcmpleps	k2 {k2}, xmm1, xmm0
24.    10    28.0   0.0    16.2      vcmpleps	k2 {k2}, xmm6, xmm1
25.    10    33.8   1.8    10.8      vcmpleps	k2 {k2}, xmm6, xmm2
26.    10    37.8   0.0    7.2       vcmpleps	k2 {k2}, xmm2, xmm0
27.    10    25.8   1.8    19.2      vmaxps	xmm1, xmm1, xmm6
28.    10    28.9   0.0    15.2      vminps	xmm1, xmm1, xmm0
29.    10    32.9   0.0    11.2      vmulps	xmm1, xmm31, xmm1
30.    10    24.8   0.9    19.2      vmaxps	xmm2, xmm2, xmm6
31.    10    27.9   0.0    15.2      vminps	xmm2, xmm2, xmm0
32.    10    32.8   0.9    10.3      vmulps	xmm2, xmm16, xmm2
33.    10    1.0    1.0    39.2      vbroadcastss	xmm3, dword ptr [rip + .LCPI15_5]
34.    10    35.0   0.0    7.2       vaddps	xmm1, xmm1, xmm3
35.    10    35.0   0.0    6.3       vaddps	xmm2, xmm2, xmm3
36.    10    38.0   0.0    3.6       vcvttps2dq	xmm3, xmm1
37.    10    42.0   0.0    0.0       vcvtdq2ps	xmm4, xmm3
38.    10    45.1   0.0    0.0       vsubps	xmm15, xmm1, xmm4
39.    10    38.0   0.0    7.1       vcvttps2dq	xmm1, xmm2
40.    10    41.1   0.0    3.1       vcvtdq2ps	xmm4, xmm1
41.    10    45.1   0.0    0.0       vsubps	xmm17, xmm2, xmm4
42.    10    40.2   1.0    6.9       vpslld	xmm2, xmm3, 2
43.    10    41.1   1.0    0.0       vpmulld	xmm1, xmm30, xmm1
44.    10    50.2   0.0    0.0       vpaddd	xmm4, xmm2, xmm1
45.    10    51.2   0.0    0.0       vpmovsxdq	ymm1, xmm4
46.    10    53.3   0.0    0.0       vpaddq	ymm1, ymm10, ymm1
47.    10    53.3   0.0    0.0       vmovq	rcx, xmm1
48.    10    54.3   1.0    0.0       vpextrq	r8, xmm1, 1
49.    10    52.4   0.0    1.0       vextracti128	xmm1, ymm1, 1
50.    10    55.4   0.0    0.0       vmovq	r10, xmm1
51.    10    55.4   1.0    0.0       vpextrq	r15, xmm1, 1
52.    10    46.2   0.0    0.0       vmovd	xmm1, dword ptr [rcx + 4]
53.    10    48.3   1.0    0.0       vpinsrd	xmm1, xmm1, dword ptr [r8 + 4], 1
54.    10    49.2   0.0    0.0       vpinsrd	xmm1, xmm1, dword ptr [r10 + 4], 2
55.    10    1.0    1.0    53.2      kxnorw	k3, k0, k0
56.    10    49.3   0.0    0.0       vpinsrd	xmm1, xmm1, dword ptr [r15 + 4], 3
57.    10    44.3   0.0    6.0       vmovd	xmm2, dword ptr [rcx + rbx]
58.    10    47.5   4.0    0.0       vpinsrd	xmm2, xmm2, dword ptr [r8 + rbx], 1
59.    10    48.5   0.0    0.0       vpinsrd	xmm2, xmm2, dword ptr [r10 + rbx], 2
60.    10    0.0    0.0    54.5      vpxor	xmm14, xmm14, xmm14
61.    10    48.5   0.0    0.0       vpinsrd	xmm2, xmm2, dword ptr [r15 + rbx], 3
62.    10    41.5   1.0    8.0       vmovd	xmm3, dword ptr [rcx + rbx + 4]
63.    10    49.5   7.0    0.0       vpinsrd	xmm3, xmm3, dword ptr [r8 + rbx + 4], 1
64.    10    49.5   0.0    0.0       vpinsrd	xmm3, xmm3, dword ptr [r10 + rbx + 4], 2
65.    10    50.5   0.0    0.0       vpinsrd	xmm3, xmm3, dword ptr [r15 + rbx + 4], 3
66.    10    1.1    1.1    46.6      vpbroadcastw	xmm9, word ptr [rip + .LCPI15_6]
67.    10    30.7   0.0    4.0       vpgatherdd	xmm14 {k3}, xmmword ptr [rsi + xmm4]
68.    10    49.7   0.0    3.0       vpand	xmm4, xmm14, xmm9
69.    10    49.7   0.0    0.0       vpmullw	xmm7, xmm4, xmm4
70.    10    48.7   0.0    5.0       vpsrlw	xmm4, xmm14, 8
71.    10    49.7   0.0    0.0       vpmullw	xmm8, xmm4, xmm4
72.    10    46.7   0.0    7.0       vpand	xmm4, xmm9, xmm1
73.    10    47.7   0.0    2.0       vpmullw	xmm5, xmm4, xmm4
74.    10    47.9   0.0    4.0       vpand	xmm4, xmm9, xmm2
75.    10    48.8   0.0    0.0       vpmullw	xmm4, xmm4, xmm4
76.    10    49.9   0.0    2.0       vpand	xmm9, xmm9, xmm3
77.    10    50.9   0.0    0.0       vpmullw	xmm9, xmm9, xmm9
78.    10    51.9   0.0    3.0       vpsrld	xmm21, xmm7, 16
79.    10    52.0   0.0    0.0       vcvtdq2ps	xmm21, xmm21
80.    10    21.1   0.0    30.9      vsubps	xmm22, xmm0, xmm15
81.    10    21.9   0.0    30.0      vsubps	xmm23, xmm0, xmm17
82.    10    26.0   1.0    25.0      vmulps	xmm20, xmm23, xmm22
83.    10    26.0   1.0    25.0      vmulps	xmm23, xmm15, xmm23
84.    10    22.5   0.2    26.7      vmulps	xmm22, xmm17, xmm22
85.    10    19.3   0.1    29.9      vmulps	xmm17, xmm17, xmm15
86.    10    45.3   0.0    6.0       vpsrld	xmm15, xmm5, 16
87.    10    46.1   0.0    2.0       vcvtdq2ps	xmm15, xmm15
88.    10    52.1   0.0    0.0       vmulps	xmm21, xmm20, xmm21
89.    10    49.2   0.0    2.0       vmulps	xmm15, xmm23, xmm15
90.    10    54.8   0.0    0.0       vaddps	xmm21, xmm21, xmm15
91.    10    45.0   0.0    11.0      vpsrld	xmm15, xmm4, 16
92.    10    45.1   0.0    7.0       vcvtdq2ps	xmm15, xmm15
93.    10    48.7   0.0    3.0       vmulps	xmm15, xmm22, xmm15
94.    10    54.8   0.0    0.0       vaddps	xmm21, xmm21, xmm15
95.    10    45.8   0.0    12.0      vpsrld	xmm15, xmm9, 16
96.    10    44.6   0.0    8.0       vcvtdq2ps	xmm15, xmm15
97.    10    47.7   0.0    4.0       vmulps	xmm15, xmm17, xmm15
98.    10    55.7   0.0    0.0       vaddps	xmm21, xmm21, xmm15
99.    10    29.4   0.0    28.0      vpsrlw	xmm15, xmm1, 8
100.   10    30.4   0.0    23.0      vpmullw	xmm15, xmm15, xmm15
101.   10    37.0   0.0    20.0      vpblendw	xmm8, xmm8, xmm6, 170
102.   10    38.1   1.0    15.0      vcvtdq2ps	xmm8, xmm8
103.   10    35.0   1.0    21.0      vpblendw	xmm15, xmm15, xmm6, 170
104.   10    35.1   0.0    17.0      vcvtdq2ps	xmm15, xmm15
105.   10    39.9   0.0    11.0      vmulps	xmm8, xmm20, xmm8
106.   10    37.0   0.0    13.0      vmulps	xmm15, xmm23, xmm15
107.   10    39.9   0.0    7.0       vaddps	xmm8, xmm8, xmm15
108.   10    25.0   1.0    24.0      vpsrlw	xmm15, xmm2, 8
109.   10    25.9   0.0    19.0      vpmullw	xmm15, xmm15, xmm15
110.   10    28.0   0.0    18.0      vpblendw	xmm15, xmm15, xmm6, 170
111.   10    28.9   0.0    14.0      vcvtdq2ps	xmm15, xmm15
112.   10    32.0   0.0    10.0      vmulps	xmm15, xmm22, xmm15
113.   10    38.9   0.0    3.0       vaddps	xmm8, xmm8, xmm15
114.   10    22.0   0.0    22.0      vpsrlw	xmm15, xmm3, 8
115.   10    30.9   8.0    9.0       vpmullw	xmm15, xmm15, xmm15
116.   10    34.0   0.0    8.0       vpblendw	xmm15, xmm15, xmm6, 170
117.   10    34.0   0.0    4.0       vcvtdq2ps	xmm15, xmm15
118.   10    38.0   0.0    0.0       vmulps	xmm15, xmm17, xmm15
119.   10    41.0   0.0    0.0       vaddps	xmm8, xmm8, xmm15
120.   10    20.0   1.0    23.0      vpblendw	xmm7, xmm7, xmm6, 170
121.   10    27.0   6.0    13.0      vcvtdq2ps	xmm7, xmm7
122.   10    21.0   5.0    21.0      vpblendw	xmm5, xmm5, xmm6, 170
123.   10    26.0   4.0    13.0      vcvtdq2ps	xmm5, xmm5
124.   10    29.0   0.0    9.0       vmulps	xmm7, xmm20, xmm7
125.   10    28.0   0.0    9.0       vmulps	xmm5, xmm23, xmm5
126.   10    31.0   0.0    5.0       vaddps	xmm5, xmm7, xmm5
127.   10    18.0   3.0    20.0      vpblendw	xmm4, xmm4, xmm6, 170
128.   10    23.0   5.0    11.0      vcvtdq2ps	xmm4, xmm4
129.   10    26.0   0.0    7.0       vmulps	xmm4, xmm22, xmm4
130.   10    31.0   0.0    1.0       vaddps	xmm4, xmm5, xmm4
131.   10    15.0   1.0    19.0      vpblendw	xmm5, xmm9, xmm6, 170
132.   10    20.0   5.0    10.0      vcvtdq2ps	xmm5, xmm5
133.   10    23.0   0.0    6.0       vmulps	xmm5, xmm17, xmm5
134.   10    32.0   0.0    0.0       vaddps	xmm5, xmm4, xmm5
135.   10    2.0    0.0    33.0      vpsrld	xmm4, xmm14, 24
136.   10    4.0    2.0    27.0      vcvtdq2ps	xmm4, xmm4
137.   10    18.0   10.0   13.0      vmulps	xmm4, xmm20, xmm4
138.   10    21.0   21.0   12.0      vpsrld	xmm1, xmm1, 24
139.   10    22.0   0.0    8.0       vcvtdq2ps	xmm1, xmm1
140.   10    26.0   0.0    4.0       vmulps	xmm1, xmm23, xmm1
141.   10    29.0   0.0    0.0       vaddps	xmm1, xmm4, xmm1
142.   10    23.0   23.0   9.0       vpsrld	xmm2, xmm2, 24
143.   10    24.0   0.0    5.0       vcvtdq2ps	xmm2, xmm2
144.   10    27.0   0.0    1.0       vmulps	xmm2, xmm22, xmm2
145.   10    32.0   0.0    0.0       vaddps	xmm1, xmm1, xmm2
146.   10    21.0   20.0   13.0      vpsrld	xmm2, xmm3, 24
147.   10    22.0   0.0    9.0       vcvtdq2ps	xmm2, xmm2
148.   10    25.0   0.0    5.0       vmulps	xmm2, xmm17, xmm2
149.   10    1.0    1.0    27.0      vmovdqu	xmm4, xmmword ptr [r11]
150.   10    23.0   0.0    7.0       vmulps	xmm3, xmm24, xmm21
151.   10    26.0   0.0    3.0       vmulps	xmm17, xmm25, xmm8
152.   10    29.0   0.0    0.0       vmulps	xmm5, xmm26, xmm5
153.   10    33.0   0.0    0.0       vaddps	xmm1, xmm1, xmm2
154.   10    37.0   0.0    0.0       vmulps	xmm20, xmm27, xmm1
155.   10    25.0   0.0    11.0      vmaxps	xmm1, xmm3, xmm6
156.   10    1.0    1.0    33.0      vbroadcastss	xmm2, dword ptr [rip + .LCPI15_10]
157.   10    29.0   0.0    7.0       vminps	xmm1, xmm1, xmm2
158.   10    28.0   0.0    7.0       vmaxps	xmm3, xmm17, xmm6
159.   10    32.0   0.0    3.0       vminps	xmm3, xmm3, xmm2
160.   10    31.0   0.0    4.0       vmaxps	xmm5, xmm5, xmm6
161.   10    35.0   0.0    0.0       vminps	xmm5, xmm5, xmm2
162.   10    35.0   1.0    0.0       vmulps	xmm2, xmm20, dword ptr [rip + .LCPI15_11]{1to4}
163.   10    45.0   0.0    0.0       vaddps	xmm17, xmm2, xmm0
164.   10    4.0    1.0    44.0      vpshufb	xmm0, xmm4, xmm19
165.   10    19.0   15.0   25.0      vcvtdq2ps	xmm0, xmm0
166.   10    23.0   0.0    21.0      vmulps	xmm0, xmm0, xmm0
167.   10    48.0   0.0    0.0       vmulps	xmm0, xmm0, xmm17
168.   10    51.0   0.0    0.0       vaddps	xmm1, xmm0, xmm1
169.   10    3.0    2.0    51.0      vpshufb	xmm0, xmm4, xmm18
170.   10    18.0   14.0   33.0      vcvtdq2ps	xmm0, xmm0
171.   10    21.0   0.0    29.0      vmulps	xmm0, xmm0, xmm0
172.   10    46.0   0.0    4.0       vmulps	xmm0, xmm0, xmm17
173.   10    50.0   0.0    0.0       vaddps	xmm2, xmm0, xmm3
174.   10    2.0    2.0    44.0      vpandd	xmm0, xmm4, dword ptr [rip + .LCPI15_7]{1to4}
175.   10    21.0   12.0   28.0      vcvtdq2ps	xmm0, xmm0
176.   10    25.0   0.0    24.0      vmulps	xmm0, xmm0, xmm0
177.   10    45.0   1.0    3.0       vmulps	xmm0, xmm0, xmm17
178.   10    49.0   0.0    0.0       vaddps	xmm3, xmm0, xmm5
179.   10    52.0   0.0    0.0       vmovaps	xmm0, xmm1
180.   10    52.0   0.0    0.0       rsqrtps	xmm0, xmm0
181.   10    56.0   0.0    0.0       vmulps	xmm1, xmm0, xmm1
182.   10    51.0   0.0    8.0       vmovaps	xmm0, xmm2
183.   10    52.0   1.0    3.0       rsqrtps	xmm0, xmm0
184.   10    56.0   0.0    0.0       vmulps	xmm2, xmm0, xmm2
185.   10    50.0   0.0    8.0       vmovaps	xmm0, xmm3
186.   10    52.0   1.0    3.0       rsqrtps	xmm0, xmm0
187.   10    55.0   0.0    0.0       vmulps	xmm0, xmm0, xmm3
188.   10    57.0   0.0    0.0       cvtps2dq	xmm1, xmm1
189.   10    57.0   0.0    0.0       cvtps2dq	xmm2, xmm2
190.   10    58.0   0.0    0.0       cvtps2dq	xmm0, xmm0
191.   10    60.0   0.0    1.0       vpslld	xmm1, xmm1, 16
192.   10    60.0   0.0    0.0       vpslld	xmm2, xmm2, 8
193.   10    61.0   0.0    0.0       vpternlogd	xmm2, xmm0, xmm1, 254
194.   10    13.0   13.0   47.0      vpsrld	xmm0, xmm4, 24
195.   10    16.0   2.0    41.0      vcvtdq2ps	xmm0, xmm0
196.   10    37.0   1.0    19.0      vmulps	xmm0, xmm17, xmm0
197.   10    41.0   0.0    15.0      vaddps	xmm0, xmm20, xmm0
198.   10    44.0   0.0    11.0      cvtps2dq	xmm0, xmm0
199.   10    48.0   0.0    10.0      vpslld	xmm0, xmm0, 24
200.   10    58.0   0.0    0.0       vpord	xmm4 {k2}, xmm2, xmm0
201.   10    59.0   0.0    0.0       vmovdqa	xmmword ptr [r11], xmm4
202.   10    12.0   12.0   46.0      kxnorw	k2, k0, k0
       10    32.8   1.3    13.6      <total>
```
</details>
</details>
