
<details><summary>[0] Code Region - OPS_ClearingChannel</summary>

```
Iterations:        100
Instructions:      5200
Total Cycles:      1208
Total uOps:        7000

Dispatch Width:    6
uOps Per Cycle:    5.79
IPC:               4.30
Block RThroughput: 11.7


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
 1      1     0.50           *            mov	dword ptr [rsp + 48], esi
 1      1     0.25                        test	esi, esi
 1      1     0.50                        je	.LBB6_9
 2      6     0.50    *                   cmp	dword ptr [rsp + 48], 4
 1      1     0.50                        jne	.LBB6_5
 1      0     0.17                        xor	eax, eax
 2      6     0.50    *                   test	byte ptr [rsp + 72], 1
 1      1     0.50                        jne	.LBB6_8
 1      1     0.50                        jmp	.LBB6_9
 1      5     0.50    *                   mov	rcx, qword ptr [rsp + 72]
 1      1     0.25                        mov	eax, ecx
 1      1     0.25                        and	eax, -2
 1      1     0.25                        add	rcx, -2
 1      1     0.25                        mov	edx, 16
 1      1     0.25                        cmp	rcx, 2
 1      1     0.50                        jae	.LBB6_111
 1      1     0.25                        test	cl, 2
 1      1     0.50                        jne	.LBB6_7
 1      0     0.17                        vxorps	xmm1, xmm1, xmm1
 2      1     0.50           *            vmovaps	xmmword ptr [rbx + rdx - 16], xmm1
 2      1     0.50           *            vmovaps	xmmword ptr [r15 + rdx - 16], xmm1
 2      1     0.50           *            vmovaps	xmmword ptr [rbx + rdx], xmm1
 2      1     0.50           *            vmovaps	xmmword ptr [r15 + rdx], xmm1
 2      6     0.50    *                   test	byte ptr [rsp + 72], 1
 1      1     0.50                        jne	.LBB6_8
 1      1     0.50                        jmp	.LBB6_9
 1      1     0.25                        mov	r8, rcx
 1      1     0.50                        shr	r8
 1      1     0.25                        add	r8, 1
 1      1     0.25                        and	r8, -2
 1      1     0.25                        mov	edx, 48
 1      0     0.17                        vxorps	xmm1, xmm1, xmm1
 2      1     0.50           *            vmovaps	xmmword ptr [rbx + rdx - 48], xmm1
 2      1     0.50           *            vmovaps	xmmword ptr [r15 + rdx - 48], xmm1
 2      1     0.50           *            vmovaps	xmmword ptr [rbx + rdx - 32], xmm1
 2      1     0.50           *            vmovaps	xmmword ptr [r15 + rdx - 32], xmm1
 2      1     0.50           *            vmovaps	xmmword ptr [rbx + rdx - 16], xmm1
 2      1     0.50           *            vmovaps	xmmword ptr [r15 + rdx - 16], xmm1
 2      1     0.50           *            vmovaps	xmmword ptr [rbx + rdx], xmm1
 2      1     0.50           *            vmovaps	xmmword ptr [r15 + rdx], xmm1
 1      1     0.25                        add	rdx, 64
 1      1     0.25                        add	r8, -2
 1      1     0.50                        jne	.LBB6_112
 1      1     0.25                        add	rdx, -32
 1      1     0.25                        test	cl, 2
 1      1     0.50                        je	.LBB6_114
 2      6     0.50    *                   test	byte ptr [rsp + 72], 1
 1      1     0.50                        je	.LBB6_9
 1      1     0.50                        shl	rax, 4
 1      0     0.17                        vxorps	xmm1, xmm1, xmm1
 2      1     0.50           *            vmovaps	xmmword ptr [rbx + rax], xmm1
 2      1     0.50           *            vmovaps	xmmword ptr [r15 + rax], xmm1


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
 0,              8  (0.7%)
 4,              1  (0.1%)
 5,              198  (16.4%)
 6,              1001  (82.9%)


```
</details>

<details><summary>Schedulers - number of cycles where we saw N micro opcodes issued:</summary>

```
[# issued], [# cycles]
 0,          5  (0.4%)
 1,          2  (0.2%)
 2,          199  (16.5%)
 3,          1  (0.1%)
 4,          202  (16.7%)
 5,          102  (8.4%)
 6,          100  (8.3%)
 7,          199  (16.5%)
 8,          297  (24.6%)
 9,          100  (8.3%)
 10,          1  (0.1%)

```
</details>

<details><summary>Scheduler's queue usage:</summary>

```
[1] Resource name.
[2] Average number of used buffer entries.
[3] Maximum number of used buffer entries.
[4] Total number of buffer entries.

 [1]            [2]        [3]        [4]
ICXPortAny       12         17         60


```
</details>

<details><summary>Retire Control Unit - number of cycles where we saw N instructions retired:</summary>

```
[# retired], [# cycles]
 0,           107  (8.9%)
 1,           401  (33.2%)
 2,           1  (0.1%)
 3,           100  (8.3%)
 4,           100  (8.3%)
 5,           100  (8.3%)
 8,           299  (24.8%)
 12,          99  (8.2%)
 17,          1  (0.1%)

```
</details>

<details><summary>Total ROB Entries:                352</summary>

```
Max Used ROB Entries:             52  ( 14.8% )
Average Used ROB Entries per cy:  44  ( 12.5% )


```
</details>

<details><summary>Register File statistics:</summary>

```
Total number of mappings created:    3100
Max number of mappings used:         25


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
 -      -     8.50   6.99   2.50   2.50   7.50   8.00   8.51   7.50   7.50   7.50   

Resource pressure by instruction:
[0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   Instructions:
 -      -      -      -      -      -     0.50    -      -     0.50   0.50   0.50   mov	dword ptr [rsp + 48], esi
 -      -      -      -      -      -      -     0.99   0.01    -      -      -     test	esi, esi
 -      -     0.50    -      -      -      -      -     0.50    -      -      -     je	.LBB6_9
 -      -     0.49    -     0.50   0.50    -     0.01   0.50    -      -      -     cmp	dword ptr [rsp + 48], 4
 -      -     0.49    -      -      -      -      -     0.51    -      -      -     jne	.LBB6_5
 -      -      -      -      -      -      -      -      -      -      -      -     xor	eax, eax
 -      -      -     0.01   0.50   0.50    -     0.99    -      -      -      -     test	byte ptr [rsp + 72], 1
 -      -     0.49    -      -      -      -      -     0.51    -      -      -     jne	.LBB6_8
 -      -     0.50    -      -      -      -      -     0.50    -      -      -     jmp	.LBB6_9
 -      -      -      -     0.50   0.50    -      -      -      -      -      -     mov	rcx, qword ptr [rsp + 72]
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     mov	eax, ecx
 -      -      -      -      -      -      -     1.00    -      -      -      -     and	eax, -2
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     add	rcx, -2
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     mov	edx, 16
 -      -      -     1.00    -      -      -      -      -      -      -      -     cmp	rcx, 2
 -      -     0.49    -      -      -      -      -     0.51    -      -      -     jae	.LBB6_111
 -      -     0.51    -      -      -      -      -     0.49    -      -      -     test	cl, 2
 -      -     0.51    -      -      -      -      -     0.49    -      -      -     jne	.LBB6_7
 -      -      -      -      -      -      -      -      -      -      -      -     vxorps	xmm1, xmm1, xmm1
 -      -      -      -      -      -     0.50    -      -     0.50   0.50   0.50   vmovaps	xmmword ptr [rbx + rdx - 16], xmm1
 -      -      -      -      -      -     0.50    -      -     0.50   0.50   0.50   vmovaps	xmmword ptr [r15 + rdx - 16], xmm1
 -      -      -      -      -      -     0.50    -      -     0.50   0.50   0.50   vmovaps	xmmword ptr [rbx + rdx], xmm1
 -      -      -      -      -      -     0.50    -      -     0.50   0.50   0.50   vmovaps	xmmword ptr [r15 + rdx], xmm1
 -      -      -     0.01   0.50   0.50    -     0.99    -      -      -      -     test	byte ptr [rsp + 72], 1
 -      -     0.51    -      -      -      -      -     0.49    -      -      -     jne	.LBB6_8
 -      -     0.51    -      -      -      -      -     0.49    -      -      -     jmp	.LBB6_9
 -      -      -      -      -      -      -     1.00    -      -      -      -     mov	r8, rcx
 -      -     0.49    -      -      -      -      -     0.51    -      -      -     shr	r8
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     add	r8, 1
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     and	r8, -2
 -      -     0.51    -      -      -      -      -     0.49    -      -      -     mov	edx, 48
 -      -      -      -      -      -      -      -      -      -      -      -     vxorps	xmm1, xmm1, xmm1
 -      -      -      -      -      -     0.50    -      -     0.50   0.50   0.50   vmovaps	xmmword ptr [rbx + rdx - 48], xmm1
 -      -      -      -      -      -     0.50    -      -     0.50   0.50   0.50   vmovaps	xmmword ptr [r15 + rdx - 48], xmm1
 -      -      -      -      -      -     0.50    -      -     0.50   0.50   0.50   vmovaps	xmmword ptr [rbx + rdx - 32], xmm1
 -      -      -      -      -      -     0.50    -      -     0.50   0.50   0.50   vmovaps	xmmword ptr [r15 + rdx - 32], xmm1
 -      -      -      -      -      -     0.50    -      -     0.50   0.50   0.50   vmovaps	xmmword ptr [rbx + rdx - 16], xmm1
 -      -      -      -      -      -     0.50    -      -     0.50   0.50   0.50   vmovaps	xmmword ptr [r15 + rdx - 16], xmm1
 -      -      -      -      -      -     0.50    -      -     0.50   0.50   0.50   vmovaps	xmmword ptr [rbx + rdx], xmm1
 -      -      -      -      -      -     0.50    -      -     0.50   0.50   0.50   vmovaps	xmmword ptr [r15 + rdx], xmm1
 -      -      -     1.00    -      -      -      -      -      -      -      -     add	rdx, 64
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     add	r8, -2
 -      -     0.51    -      -      -      -      -     0.49    -      -      -     jne	.LBB6_112
 -      -     0.49   0.01    -      -      -      -     0.50    -      -      -     add	rdx, -32
 -      -     0.01    -      -      -      -     0.99    -      -      -      -     test	cl, 2
 -      -     0.50    -      -      -      -      -     0.50    -      -      -     je	.LBB6_114
 -      -      -      -     0.50   0.50    -     0.99   0.01    -      -      -     test	byte ptr [rsp + 72], 1
 -      -     0.49    -      -      -      -      -     0.51    -      -      -     je	.LBB6_9
 -      -     0.50    -      -      -      -      -     0.50    -      -      -     shl	rax, 4
 -      -      -      -      -      -      -      -      -      -      -      -     vxorps	xmm1, xmm1, xmm1
 -      -      -      -      -      -     0.50    -      -     0.50   0.50   0.50   vmovaps	xmmword ptr [rbx + rax], xmm1
 -      -      -      -      -      -     0.50    -      -     0.50   0.50   0.50   vmovaps	xmmword ptr [r15 + rax], xmm1


```
</details>

<details><summary>Timeline view:</summary>

```
                    0123456789          0123456789          0123456789          0123456789
Index     0123456789          0123456789          0123456789          0123456789          

[0,0]     DeER .    .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   mov	dword ptr [rsp + 48], esi
[0,1]     DeER .    .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   test	esi, esi
[0,2]     D=eER.    .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   je	.LBB6_9
[0,3]     DeeeeeeER .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   cmp	dword ptr [rsp + 48], 4
[0,4]     D======eER.    .    .    .    .    .    .    .    .    .    .    .    .    .   .   jne	.LBB6_5
[0,5]     .D-------R.    .    .    .    .    .    .    .    .    .    .    .    .    .   .   xor	eax, eax
[0,6]     .DeeeeeeER.    .    .    .    .    .    .    .    .    .    .    .    .    .   .   test	byte ptr [rsp + 72], 1
[0,7]     .D======eER    .    .    .    .    .    .    .    .    .    .    .    .    .   .   jne	.LBB6_8
[0,8]     .DeE------R    .    .    .    .    .    .    .    .    .    .    .    .    .   .   jmp	.LBB6_9
[0,9]     .DeeeeeE--R    .    .    .    .    .    .    .    .    .    .    .    .    .   .   mov	rcx, qword ptr [rsp + 72]
[0,10]    . D====eE-R    .    .    .    .    .    .    .    .    .    .    .    .    .   .   mov	eax, ecx
[0,11]    . D=====eER    .    .    .    .    .    .    .    .    .    .    .    .    .   .   and	eax, -2
[0,12]    . D====eE-R    .    .    .    .    .    .    .    .    .    .    .    .    .   .   add	rcx, -2
[0,13]    . DeE-----R    .    .    .    .    .    .    .    .    .    .    .    .    .   .   mov	edx, 16
[0,14]    . D=====eER    .    .    .    .    .    .    .    .    .    .    .    .    .   .   cmp	rcx, 2
[0,15]    . D======eER   .    .    .    .    .    .    .    .    .    .    .    .    .   .   jae	.LBB6_111
[0,16]    .  D====eE-R   .    .    .    .    .    .    .    .    .    .    .    .    .   .   test	cl, 2
[0,17]    .  D=====eER   .    .    .    .    .    .    .    .    .    .    .    .    .   .   jne	.LBB6_7
[0,18]    .  D-------R   .    .    .    .    .    .    .    .    .    .    .    .    .   .   vxorps	xmm1, xmm1, xmm1
[0,19]    .  DeE-----R   .    .    .    .    .    .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [rbx + rdx - 16], xmm1
[0,20]    .   DeE----R   .    .    .    .    .    .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [r15 + rdx - 16], xmm1
[0,21]    .   DeE----R   .    .    .    .    .    .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [rbx + rdx], xmm1
[0,22]    .   D=eE---R   .    .    .    .    .    .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [r15 + rdx], xmm1
[0,23]    .    DeeeeeeER .    .    .    .    .    .    .    .    .    .    .    .    .   .   test	byte ptr [rsp + 72], 1
[0,24]    .    D======eER.    .    .    .    .    .    .    .    .    .    .    .    .   .   jne	.LBB6_8
[0,25]    .    DeE------R.    .    .    .    .    .    .    .    .    .    .    .    .   .   jmp	.LBB6_9
[0,26]    .    D===eE---R.    .    .    .    .    .    .    .    .    .    .    .    .   .   mov	r8, rcx
[0,27]    .    D====eE--R.    .    .    .    .    .    .    .    .    .    .    .    .   .   shr	r8
[0,28]    .    .D====eE-R.    .    .    .    .    .    .    .    .    .    .    .    .   .   add	r8, 1
[0,29]    .    .D=====eER.    .    .    .    .    .    .    .    .    .    .    .    .   .   and	r8, -2
[0,30]    .    .DeE-----R.    .    .    .    .    .    .    .    .    .    .    .    .   .   mov	edx, 48
[0,31]    .    .D-------R.    .    .    .    .    .    .    .    .    .    .    .    .   .   vxorps	xmm1, xmm1, xmm1
[0,32]    .    .D=eE----R.    .    .    .    .    .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [rbx + rdx - 48], xmm1
[0,33]    .    . DeE----R.    .    .    .    .    .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [r15 + rdx - 48], xmm1
[0,34]    .    . D=eE---R.    .    .    .    .    .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [rbx + rdx - 32], xmm1
[0,35]    .    . D=eE---R.    .    .    .    .    .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [r15 + rdx - 32], xmm1
[0,36]    .    .  D=eE--R.    .    .    .    .    .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [rbx + rdx - 16], xmm1
[0,37]    .    .  D=eE--R.    .    .    .    .    .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [r15 + rdx - 16], xmm1
[0,38]    .    .  D==eE-R.    .    .    .    .    .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [rbx + rdx], xmm1
[0,39]    .    .   D=eE-R.    .    .    .    .    .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [r15 + rdx], xmm1
[0,40]    .    .   DeE--R.    .    .    .    .    .    .    .    .    .    .    .    .   .   add	rdx, 64
[0,41]    .    .   D===eER    .    .    .    .    .    .    .    .    .    .    .    .   .   add	r8, -2
[0,42]    .    .   D====eER   .    .    .    .    .    .    .    .    .    .    .    .   .   jne	.LBB6_112
[0,43]    .    .   D=eE---R   .    .    .    .    .    .    .    .    .    .    .    .   .   add	rdx, -32
[0,44]    .    .    DeE---R   .    .    .    .    .    .    .    .    .    .    .    .   .   test	cl, 2
[0,45]    .    .    D=eE--R   .    .    .    .    .    .    .    .    .    .    .    .   .   je	.LBB6_114
[0,46]    .    .    DeeeeeeER .    .    .    .    .    .    .    .    .    .    .    .   .   test	byte ptr [rsp + 72], 1
[0,47]    .    .    D======eER.    .    .    .    .    .    .    .    .    .    .    .   .   je	.LBB6_9
[0,48]    .    .    D==eE----R.    .    .    .    .    .    .    .    .    .    .    .   .   shl	rax, 4
[0,49]    .    .    .D-------R.    .    .    .    .    .    .    .    .    .    .    .   .   vxorps	xmm1, xmm1, xmm1
[0,50]    .    .    .D==eE---R.    .    .    .    .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [rbx + rax], xmm1
[0,51]    .    .    .D==eE---R.    .    .    .    .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [r15 + rax], xmm1
[1,0]     .    .    .D===eE--R.    .    .    .    .    .    .    .    .    .    .    .   .   mov	dword ptr [rsp + 48], esi
[1,1]     .    .    . DeE----R.    .    .    .    .    .    .    .    .    .    .    .   .   test	esi, esi
[1,2]     .    .    . D=eE---R.    .    .    .    .    .    .    .    .    .    .    .   .   je	.LBB6_9
[1,3]     .    .    . DeeeeeeER    .    .    .    .    .    .    .    .    .    .    .   .   cmp	dword ptr [rsp + 48], 4
[1,4]     .    .    . D======eER   .    .    .    .    .    .    .    .    .    .    .   .   jne	.LBB6_5
[1,5]     .    .    . D--------R   .    .    .    .    .    .    .    .    .    .    .   .   xor	eax, eax
[1,6]     .    .    .  DeeeeeeER   .    .    .    .    .    .    .    .    .    .    .   .   test	byte ptr [rsp + 72], 1
[1,7]     .    .    .  D======eER  .    .    .    .    .    .    .    .    .    .    .   .   jne	.LBB6_8
[1,8]     .    .    .  D=eE-----R  .    .    .    .    .    .    .    .    .    .    .   .   jmp	.LBB6_9
[1,9]     .    .    .  DeeeeeE--R  .    .    .    .    .    .    .    .    .    .    .   .   mov	rcx, qword ptr [rsp + 72]
[1,10]    .    .    .  D=====eE-R  .    .    .    .    .    .    .    .    .    .    .   .   mov	eax, ecx
[1,11]    .    .    .   D=====eER  .    .    .    .    .    .    .    .    .    .    .   .   and	eax, -2
[1,12]    .    .    .   D====eE-R  .    .    .    .    .    .    .    .    .    .    .   .   add	rcx, -2
[1,13]    .    .    .   DeE-----R  .    .    .    .    .    .    .    .    .    .    .   .   mov	edx, 16
[1,14]    .    .    .   D=====eER  .    .    .    .    .    .    .    .    .    .    .   .   cmp	rcx, 2
[1,15]    .    .    .   D======eER .    .    .    .    .    .    .    .    .    .    .   .   jae	.LBB6_111
[1,16]    .    .    .   D=====eE-R .    .    .    .    .    .    .    .    .    .    .   .   test	cl, 2
[1,17]    .    .    .    D=====eER .    .    .    .    .    .    .    .    .    .    .   .   jne	.LBB6_7
[1,18]    .    .    .    D-------R .    .    .    .    .    .    .    .    .    .    .   .   vxorps	xmm1, xmm1, xmm1
[1,19]    .    .    .    DeE-----R .    .    .    .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [rbx + rdx - 16], xmm1
[1,20]    .    .    .    DeE-----R .    .    .    .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [r15 + rdx - 16], xmm1
[1,21]    .    .    .    .DeE----R .    .    .    .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [rbx + rdx], xmm1
[1,22]    .    .    .    .DeE----R .    .    .    .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [r15 + rdx], xmm1
[1,23]    .    .    .    .DeeeeeeER.    .    .    .    .    .    .    .    .    .    .   .   test	byte ptr [rsp + 72], 1
[1,24]    .    .    .    . D=====eER    .    .    .    .    .    .    .    .    .    .   .   jne	.LBB6_8
[1,25]    .    .    .    . DeE-----R    .    .    .    .    .    .    .    .    .    .   .   jmp	.LBB6_9
[1,26]    .    .    .    . D===eE--R    .    .    .    .    .    .    .    .    .    .   .   mov	r8, rcx
[1,27]    .    .    .    . D====eE-R    .    .    .    .    .    .    .    .    .    .   .   shr	r8
[1,28]    .    .    .    . D=====eER    .    .    .    .    .    .    .    .    .    .   .   add	r8, 1
[1,29]    .    .    .    . D======eER   .    .    .    .    .    .    .    .    .    .   .   and	r8, -2
[1,30]    .    .    .    .  DeE-----R   .    .    .    .    .    .    .    .    .    .   .   mov	edx, 48
[1,31]    .    .    .    .  D-------R   .    .    .    .    .    .    .    .    .    .   .   vxorps	xmm1, xmm1, xmm1
[1,32]    .    .    .    .  D=eE----R   .    .    .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [rbx + rdx - 48], xmm1
[1,33]    .    .    .    .  D=eE----R   .    .    .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [r15 + rdx - 48], xmm1
[1,34]    .    .    .    .   D=eE---R   .    .    .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [rbx + rdx - 32], xmm1
[1,35]    .    .    .    .   D=eE---R   .    .    .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [r15 + rdx - 32], xmm1
[1,36]    .    .    .    .   D==eE--R   .    .    .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [rbx + rdx - 16], xmm1
[1,37]    .    .    .    .    D=eE--R   .    .    .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [r15 + rdx - 16], xmm1
[1,38]    .    .    .    .    D==eE-R   .    .    .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [rbx + rdx], xmm1
[1,39]    .    .    .    .    D==eE-R   .    .    .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [r15 + rdx], xmm1
[1,40]    .    .    .    .    .DeE--R   .    .    .    .    .    .    .    .    .    .   .   add	rdx, 64
[1,41]    .    .    .    .    .D===eER  .    .    .    .    .    .    .    .    .    .   .   add	r8, -2
[1,42]    .    .    .    .    .D====eER .    .    .    .    .    .    .    .    .    .   .   jne	.LBB6_112
[1,43]    .    .    .    .    .D=eE---R .    .    .    .    .    .    .    .    .    .   .   add	rdx, -32
[1,44]    .    .    .    .    .DeE----R .    .    .    .    .    .    .    .    .    .   .   test	cl, 2
[1,45]    .    .    .    .    .D==eE--R .    .    .    .    .    .    .    .    .    .   .   je	.LBB6_114
[1,46]    .    .    .    .    . DeeeeeeER    .    .    .    .    .    .    .    .    .   .   test	byte ptr [rsp + 72], 1
[1,47]    .    .    .    .    . D======eER   .    .    .    .    .    .    .    .    .   .   je	.LBB6_9
[1,48]    .    .    .    .    . D=eE-----R   .    .    .    .    .    .    .    .    .   .   shl	rax, 4
[1,49]    .    .    .    .    . D--------R   .    .    .    .    .    .    .    .    .   .   vxorps	xmm1, xmm1, xmm1
[1,50]    .    .    .    .    .  D=eE----R   .    .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [rbx + rax], xmm1
[1,51]    .    .    .    .    .  D=eE----R   .    .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [r15 + rax], xmm1
[2,0]     .    .    .    .    .  D==eE---R   .    .    .    .    .    .    .    .    .   .   mov	dword ptr [rsp + 48], esi
[2,1]     .    .    .    .    .  DeE-----R   .    .    .    .    .    .    .    .    .   .   test	esi, esi
[2,2]     .    .    .    .    .   DeE----R   .    .    .    .    .    .    .    .    .   .   je	.LBB6_9
[2,3]     .    .    .    .    .   DeeeeeeER  .    .    .    .    .    .    .    .    .   .   cmp	dword ptr [rsp + 48], 4
[2,4]     .    .    .    .    .   D======eER .    .    .    .    .    .    .    .    .   .   jne	.LBB6_5
[2,5]     .    .    .    .    .   D--------R .    .    .    .    .    .    .    .    .   .   xor	eax, eax
[2,6]     .    .    .    .    .    DeeeeeeER .    .    .    .    .    .    .    .    .   .   test	byte ptr [rsp + 72], 1
[2,7]     .    .    .    .    .    D======eER.    .    .    .    .    .    .    .    .   .   jne	.LBB6_8
[2,8]     .    .    .    .    .    DeE------R.    .    .    .    .    .    .    .    .   .   jmp	.LBB6_9
[2,9]     .    .    .    .    .    DeeeeeE--R.    .    .    .    .    .    .    .    .   .   mov	rcx, qword ptr [rsp + 72]
[2,10]    .    .    .    .    .    D=====eE-R.    .    .    .    .    .    .    .    .   .   mov	eax, ecx
[2,11]    .    .    .    .    .    .D=====eER.    .    .    .    .    .    .    .    .   .   and	eax, -2
[2,12]    .    .    .    .    .    .D====eE-R.    .    .    .    .    .    .    .    .   .   add	rcx, -2
[2,13]    .    .    .    .    .    .DeE-----R.    .    .    .    .    .    .    .    .   .   mov	edx, 16
[2,14]    .    .    .    .    .    .D=====eER.    .    .    .    .    .    .    .    .   .   cmp	rcx, 2
[2,15]    .    .    .    .    .    .D======eER    .    .    .    .    .    .    .    .   .   jae	.LBB6_111
[2,16]    .    .    .    .    .    .D=====eE-R    .    .    .    .    .    .    .    .   .   test	cl, 2
[2,17]    .    .    .    .    .    . D=====eER    .    .    .    .    .    .    .    .   .   jne	.LBB6_7
[2,18]    .    .    .    .    .    . D-------R    .    .    .    .    .    .    .    .   .   vxorps	xmm1, xmm1, xmm1
[2,19]    .    .    .    .    .    . DeE-----R    .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [rbx + rdx - 16], xmm1
[2,20]    .    .    .    .    .    . DeE-----R    .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [r15 + rdx - 16], xmm1
[2,21]    .    .    .    .    .    .  DeE----R    .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [rbx + rdx], xmm1
[2,22]    .    .    .    .    .    .  DeE----R    .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [r15 + rdx], xmm1
[2,23]    .    .    .    .    .    .  DeeeeeeER   .    .    .    .    .    .    .    .   .   test	byte ptr [rsp + 72], 1
[2,24]    .    .    .    .    .    .   D=====eER  .    .    .    .    .    .    .    .   .   jne	.LBB6_8
[2,25]    .    .    .    .    .    .   DeE-----R  .    .    .    .    .    .    .    .   .   jmp	.LBB6_9
[2,26]    .    .    .    .    .    .   D===eE--R  .    .    .    .    .    .    .    .   .   mov	r8, rcx
[2,27]    .    .    .    .    .    .   D====eE-R  .    .    .    .    .    .    .    .   .   shr	r8
[2,28]    .    .    .    .    .    .   D=====eER  .    .    .    .    .    .    .    .   .   add	r8, 1
[2,29]    .    .    .    .    .    .   D======eER .    .    .    .    .    .    .    .   .   and	r8, -2
[2,30]    .    .    .    .    .    .    DeE-----R .    .    .    .    .    .    .    .   .   mov	edx, 48
[2,31]    .    .    .    .    .    .    D-------R .    .    .    .    .    .    .    .   .   vxorps	xmm1, xmm1, xmm1
[2,32]    .    .    .    .    .    .    D=eE----R .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [rbx + rdx - 48], xmm1
[2,33]    .    .    .    .    .    .    D=eE----R .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [r15 + rdx - 48], xmm1
[2,34]    .    .    .    .    .    .    .D=eE---R .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [rbx + rdx - 32], xmm1
[2,35]    .    .    .    .    .    .    .D=eE---R .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [r15 + rdx - 32], xmm1
[2,36]    .    .    .    .    .    .    .D==eE--R .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [rbx + rdx - 16], xmm1
[2,37]    .    .    .    .    .    .    . D=eE--R .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [r15 + rdx - 16], xmm1
[2,38]    .    .    .    .    .    .    . D==eE-R .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [rbx + rdx], xmm1
[2,39]    .    .    .    .    .    .    . D==eE-R .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [r15 + rdx], xmm1
[2,40]    .    .    .    .    .    .    .  DeE--R .    .    .    .    .    .    .    .   .   add	rdx, 64
[2,41]    .    .    .    .    .    .    .  D===eER.    .    .    .    .    .    .    .   .   add	r8, -2
[2,42]    .    .    .    .    .    .    .  D====eER    .    .    .    .    .    .    .   .   jne	.LBB6_112
[2,43]    .    .    .    .    .    .    .  D=eE---R    .    .    .    .    .    .    .   .   add	rdx, -32
[2,44]    .    .    .    .    .    .    .  DeE----R    .    .    .    .    .    .    .   .   test	cl, 2
[2,45]    .    .    .    .    .    .    .  D==eE--R    .    .    .    .    .    .    .   .   je	.LBB6_114
[2,46]    .    .    .    .    .    .    .   DeeeeeeER  .    .    .    .    .    .    .   .   test	byte ptr [rsp + 72], 1
[2,47]    .    .    .    .    .    .    .   D======eER .    .    .    .    .    .    .   .   je	.LBB6_9
[2,48]    .    .    .    .    .    .    .   D=eE-----R .    .    .    .    .    .    .   .   shl	rax, 4
[2,49]    .    .    .    .    .    .    .   D--------R .    .    .    .    .    .    .   .   vxorps	xmm1, xmm1, xmm1
[2,50]    .    .    .    .    .    .    .    D=eE----R .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [rbx + rax], xmm1
[2,51]    .    .    .    .    .    .    .    D=eE----R .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [r15 + rax], xmm1
[3,0]     .    .    .    .    .    .    .    D==eE---R .    .    .    .    .    .    .   .   mov	dword ptr [rsp + 48], esi
[3,1]     .    .    .    .    .    .    .    DeE-----R .    .    .    .    .    .    .   .   test	esi, esi
[3,2]     .    .    .    .    .    .    .    .DeE----R .    .    .    .    .    .    .   .   je	.LBB6_9
[3,3]     .    .    .    .    .    .    .    .DeeeeeeER.    .    .    .    .    .    .   .   cmp	dword ptr [rsp + 48], 4
[3,4]     .    .    .    .    .    .    .    .D======eER    .    .    .    .    .    .   .   jne	.LBB6_5
[3,5]     .    .    .    .    .    .    .    .D--------R    .    .    .    .    .    .   .   xor	eax, eax
[3,6]     .    .    .    .    .    .    .    . DeeeeeeER    .    .    .    .    .    .   .   test	byte ptr [rsp + 72], 1
[3,7]     .    .    .    .    .    .    .    . D======eER   .    .    .    .    .    .   .   jne	.LBB6_8
[3,8]     .    .    .    .    .    .    .    . DeE------R   .    .    .    .    .    .   .   jmp	.LBB6_9
[3,9]     .    .    .    .    .    .    .    . DeeeeeE--R   .    .    .    .    .    .   .   mov	rcx, qword ptr [rsp + 72]
[3,10]    .    .    .    .    .    .    .    . D=====eE-R   .    .    .    .    .    .   .   mov	eax, ecx
[3,11]    .    .    .    .    .    .    .    .  D=====eER   .    .    .    .    .    .   .   and	eax, -2
[3,12]    .    .    .    .    .    .    .    .  D====eE-R   .    .    .    .    .    .   .   add	rcx, -2
[3,13]    .    .    .    .    .    .    .    .  DeE-----R   .    .    .    .    .    .   .   mov	edx, 16
[3,14]    .    .    .    .    .    .    .    .  D=====eER   .    .    .    .    .    .   .   cmp	rcx, 2
[3,15]    .    .    .    .    .    .    .    .  D======eER  .    .    .    .    .    .   .   jae	.LBB6_111
[3,16]    .    .    .    .    .    .    .    .  D=====eE-R  .    .    .    .    .    .   .   test	cl, 2
[3,17]    .    .    .    .    .    .    .    .   D=====eER  .    .    .    .    .    .   .   jne	.LBB6_7
[3,18]    .    .    .    .    .    .    .    .   D-------R  .    .    .    .    .    .   .   vxorps	xmm1, xmm1, xmm1
[3,19]    .    .    .    .    .    .    .    .   DeE-----R  .    .    .    .    .    .   .   vmovaps	xmmword ptr [rbx + rdx - 16], xmm1
[3,20]    .    .    .    .    .    .    .    .   DeE-----R  .    .    .    .    .    .   .   vmovaps	xmmword ptr [r15 + rdx - 16], xmm1
[3,21]    .    .    .    .    .    .    .    .    DeE----R  .    .    .    .    .    .   .   vmovaps	xmmword ptr [rbx + rdx], xmm1
[3,22]    .    .    .    .    .    .    .    .    DeE----R  .    .    .    .    .    .   .   vmovaps	xmmword ptr [r15 + rdx], xmm1
[3,23]    .    .    .    .    .    .    .    .    DeeeeeeER .    .    .    .    .    .   .   test	byte ptr [rsp + 72], 1
[3,24]    .    .    .    .    .    .    .    .    .D=====eER.    .    .    .    .    .   .   jne	.LBB6_8
[3,25]    .    .    .    .    .    .    .    .    .DeE-----R.    .    .    .    .    .   .   jmp	.LBB6_9
[3,26]    .    .    .    .    .    .    .    .    .D===eE--R.    .    .    .    .    .   .   mov	r8, rcx
[3,27]    .    .    .    .    .    .    .    .    .D====eE-R.    .    .    .    .    .   .   shr	r8
[3,28]    .    .    .    .    .    .    .    .    .D=====eER.    .    .    .    .    .   .   add	r8, 1
[3,29]    .    .    .    .    .    .    .    .    .D======eER    .    .    .    .    .   .   and	r8, -2
[3,30]    .    .    .    .    .    .    .    .    . DeE-----R    .    .    .    .    .   .   mov	edx, 48
[3,31]    .    .    .    .    .    .    .    .    . D-------R    .    .    .    .    .   .   vxorps	xmm1, xmm1, xmm1
[3,32]    .    .    .    .    .    .    .    .    . D=eE----R    .    .    .    .    .   .   vmovaps	xmmword ptr [rbx + rdx - 48], xmm1
[3,33]    .    .    .    .    .    .    .    .    . D=eE----R    .    .    .    .    .   .   vmovaps	xmmword ptr [r15 + rdx - 48], xmm1
[3,34]    .    .    .    .    .    .    .    .    .  D=eE---R    .    .    .    .    .   .   vmovaps	xmmword ptr [rbx + rdx - 32], xmm1
[3,35]    .    .    .    .    .    .    .    .    .  D=eE---R    .    .    .    .    .   .   vmovaps	xmmword ptr [r15 + rdx - 32], xmm1
[3,36]    .    .    .    .    .    .    .    .    .  D==eE--R    .    .    .    .    .   .   vmovaps	xmmword ptr [rbx + rdx - 16], xmm1
[3,37]    .    .    .    .    .    .    .    .    .   D=eE--R    .    .    .    .    .   .   vmovaps	xmmword ptr [r15 + rdx - 16], xmm1
[3,38]    .    .    .    .    .    .    .    .    .   D==eE-R    .    .    .    .    .   .   vmovaps	xmmword ptr [rbx + rdx], xmm1
[3,39]    .    .    .    .    .    .    .    .    .   D==eE-R    .    .    .    .    .   .   vmovaps	xmmword ptr [r15 + rdx], xmm1
[3,40]    .    .    .    .    .    .    .    .    .    DeE--R    .    .    .    .    .   .   add	rdx, 64
[3,41]    .    .    .    .    .    .    .    .    .    D===eER   .    .    .    .    .   .   add	r8, -2
[3,42]    .    .    .    .    .    .    .    .    .    D====eER  .    .    .    .    .   .   jne	.LBB6_112
[3,43]    .    .    .    .    .    .    .    .    .    D=eE---R  .    .    .    .    .   .   add	rdx, -32
[3,44]    .    .    .    .    .    .    .    .    .    DeE----R  .    .    .    .    .   .   test	cl, 2
[3,45]    .    .    .    .    .    .    .    .    .    D==eE--R  .    .    .    .    .   .   je	.LBB6_114
[3,46]    .    .    .    .    .    .    .    .    .    .DeeeeeeER.    .    .    .    .   .   test	byte ptr [rsp + 72], 1
[3,47]    .    .    .    .    .    .    .    .    .    .D======eER    .    .    .    .   .   je	.LBB6_9
[3,48]    .    .    .    .    .    .    .    .    .    .D=eE-----R    .    .    .    .   .   shl	rax, 4
[3,49]    .    .    .    .    .    .    .    .    .    .D--------R    .    .    .    .   .   vxorps	xmm1, xmm1, xmm1
[3,50]    .    .    .    .    .    .    .    .    .    . D=eE----R    .    .    .    .   .   vmovaps	xmmword ptr [rbx + rax], xmm1
[3,51]    .    .    .    .    .    .    .    .    .    . D=eE----R    .    .    .    .   .   vmovaps	xmmword ptr [r15 + rax], xmm1
[4,0]     .    .    .    .    .    .    .    .    .    . D==eE---R    .    .    .    .   .   mov	dword ptr [rsp + 48], esi
[4,1]     .    .    .    .    .    .    .    .    .    . DeE-----R    .    .    .    .   .   test	esi, esi
[4,2]     .    .    .    .    .    .    .    .    .    .  DeE----R    .    .    .    .   .   je	.LBB6_9
[4,3]     .    .    .    .    .    .    .    .    .    .  DeeeeeeER   .    .    .    .   .   cmp	dword ptr [rsp + 48], 4
[4,4]     .    .    .    .    .    .    .    .    .    .  D======eER  .    .    .    .   .   jne	.LBB6_5
[4,5]     .    .    .    .    .    .    .    .    .    .  D--------R  .    .    .    .   .   xor	eax, eax
[4,6]     .    .    .    .    .    .    .    .    .    .   DeeeeeeER  .    .    .    .   .   test	byte ptr [rsp + 72], 1
[4,7]     .    .    .    .    .    .    .    .    .    .   D======eER .    .    .    .   .   jne	.LBB6_8
[4,8]     .    .    .    .    .    .    .    .    .    .   DeE------R .    .    .    .   .   jmp	.LBB6_9
[4,9]     .    .    .    .    .    .    .    .    .    .   DeeeeeE--R .    .    .    .   .   mov	rcx, qword ptr [rsp + 72]
[4,10]    .    .    .    .    .    .    .    .    .    .   D=====eE-R .    .    .    .   .   mov	eax, ecx
[4,11]    .    .    .    .    .    .    .    .    .    .    D=====eER .    .    .    .   .   and	eax, -2
[4,12]    .    .    .    .    .    .    .    .    .    .    D====eE-R .    .    .    .   .   add	rcx, -2
[4,13]    .    .    .    .    .    .    .    .    .    .    DeE-----R .    .    .    .   .   mov	edx, 16
[4,14]    .    .    .    .    .    .    .    .    .    .    D=====eER .    .    .    .   .   cmp	rcx, 2
[4,15]    .    .    .    .    .    .    .    .    .    .    D======eER.    .    .    .   .   jae	.LBB6_111
[4,16]    .    .    .    .    .    .    .    .    .    .    D=====eE-R.    .    .    .   .   test	cl, 2
[4,17]    .    .    .    .    .    .    .    .    .    .    .D=====eER.    .    .    .   .   jne	.LBB6_7
[4,18]    .    .    .    .    .    .    .    .    .    .    .D-------R.    .    .    .   .   vxorps	xmm1, xmm1, xmm1
[4,19]    .    .    .    .    .    .    .    .    .    .    .DeE-----R.    .    .    .   .   vmovaps	xmmword ptr [rbx + rdx - 16], xmm1
[4,20]    .    .    .    .    .    .    .    .    .    .    .DeE-----R.    .    .    .   .   vmovaps	xmmword ptr [r15 + rdx - 16], xmm1
[4,21]    .    .    .    .    .    .    .    .    .    .    . DeE----R.    .    .    .   .   vmovaps	xmmword ptr [rbx + rdx], xmm1
[4,22]    .    .    .    .    .    .    .    .    .    .    . DeE----R.    .    .    .   .   vmovaps	xmmword ptr [r15 + rdx], xmm1
[4,23]    .    .    .    .    .    .    .    .    .    .    . DeeeeeeER    .    .    .   .   test	byte ptr [rsp + 72], 1
[4,24]    .    .    .    .    .    .    .    .    .    .    .  D=====eER   .    .    .   .   jne	.LBB6_8
[4,25]    .    .    .    .    .    .    .    .    .    .    .  DeE-----R   .    .    .   .   jmp	.LBB6_9
[4,26]    .    .    .    .    .    .    .    .    .    .    .  D===eE--R   .    .    .   .   mov	r8, rcx
[4,27]    .    .    .    .    .    .    .    .    .    .    .  D====eE-R   .    .    .   .   shr	r8
[4,28]    .    .    .    .    .    .    .    .    .    .    .  D=====eER   .    .    .   .   add	r8, 1
[4,29]    .    .    .    .    .    .    .    .    .    .    .  D======eER  .    .    .   .   and	r8, -2
[4,30]    .    .    .    .    .    .    .    .    .    .    .   DeE-----R  .    .    .   .   mov	edx, 48
[4,31]    .    .    .    .    .    .    .    .    .    .    .   D-------R  .    .    .   .   vxorps	xmm1, xmm1, xmm1
[4,32]    .    .    .    .    .    .    .    .    .    .    .   D=eE----R  .    .    .   .   vmovaps	xmmword ptr [rbx + rdx - 48], xmm1
[4,33]    .    .    .    .    .    .    .    .    .    .    .   D=eE----R  .    .    .   .   vmovaps	xmmword ptr [r15 + rdx - 48], xmm1
[4,34]    .    .    .    .    .    .    .    .    .    .    .    D=eE---R  .    .    .   .   vmovaps	xmmword ptr [rbx + rdx - 32], xmm1
[4,35]    .    .    .    .    .    .    .    .    .    .    .    D=eE---R  .    .    .   .   vmovaps	xmmword ptr [r15 + rdx - 32], xmm1
[4,36]    .    .    .    .    .    .    .    .    .    .    .    D==eE--R  .    .    .   .   vmovaps	xmmword ptr [rbx + rdx - 16], xmm1
[4,37]    .    .    .    .    .    .    .    .    .    .    .    .D=eE--R  .    .    .   .   vmovaps	xmmword ptr [r15 + rdx - 16], xmm1
[4,38]    .    .    .    .    .    .    .    .    .    .    .    .D==eE-R  .    .    .   .   vmovaps	xmmword ptr [rbx + rdx], xmm1
[4,39]    .    .    .    .    .    .    .    .    .    .    .    .D==eE-R  .    .    .   .   vmovaps	xmmword ptr [r15 + rdx], xmm1
[4,40]    .    .    .    .    .    .    .    .    .    .    .    . DeE--R  .    .    .   .   add	rdx, 64
[4,41]    .    .    .    .    .    .    .    .    .    .    .    . D===eER .    .    .   .   add	r8, -2
[4,42]    .    .    .    .    .    .    .    .    .    .    .    . D====eER.    .    .   .   jne	.LBB6_112
[4,43]    .    .    .    .    .    .    .    .    .    .    .    . D=eE---R.    .    .   .   add	rdx, -32
[4,44]    .    .    .    .    .    .    .    .    .    .    .    . DeE----R.    .    .   .   test	cl, 2
[4,45]    .    .    .    .    .    .    .    .    .    .    .    . D==eE--R.    .    .   .   je	.LBB6_114
[4,46]    .    .    .    .    .    .    .    .    .    .    .    .  DeeeeeeER   .    .   .   test	byte ptr [rsp + 72], 1
[4,47]    .    .    .    .    .    .    .    .    .    .    .    .  D======eER  .    .   .   je	.LBB6_9
[4,48]    .    .    .    .    .    .    .    .    .    .    .    .  D=eE-----R  .    .   .   shl	rax, 4
[4,49]    .    .    .    .    .    .    .    .    .    .    .    .  D--------R  .    .   .   vxorps	xmm1, xmm1, xmm1
[4,50]    .    .    .    .    .    .    .    .    .    .    .    .   D=eE----R  .    .   .   vmovaps	xmmword ptr [rbx + rax], xmm1
[4,51]    .    .    .    .    .    .    .    .    .    .    .    .   D=eE----R  .    .   .   vmovaps	xmmword ptr [r15 + rax], xmm1
[5,0]     .    .    .    .    .    .    .    .    .    .    .    .   D==eE---R  .    .   .   mov	dword ptr [rsp + 48], esi
[5,1]     .    .    .    .    .    .    .    .    .    .    .    .   DeE-----R  .    .   .   test	esi, esi
[5,2]     .    .    .    .    .    .    .    .    .    .    .    .    DeE----R  .    .   .   je	.LBB6_9
[5,3]     .    .    .    .    .    .    .    .    .    .    .    .    DeeeeeeER .    .   .   cmp	dword ptr [rsp + 48], 4
[5,4]     .    .    .    .    .    .    .    .    .    .    .    .    D======eER.    .   .   jne	.LBB6_5
[5,5]     .    .    .    .    .    .    .    .    .    .    .    .    D--------R.    .   .   xor	eax, eax
[5,6]     .    .    .    .    .    .    .    .    .    .    .    .    .DeeeeeeER.    .   .   test	byte ptr [rsp + 72], 1
[5,7]     .    .    .    .    .    .    .    .    .    .    .    .    .D======eER    .   .   jne	.LBB6_8
[5,8]     .    .    .    .    .    .    .    .    .    .    .    .    .DeE------R    .   .   jmp	.LBB6_9
[5,9]     .    .    .    .    .    .    .    .    .    .    .    .    .DeeeeeE--R    .   .   mov	rcx, qword ptr [rsp + 72]
[5,10]    .    .    .    .    .    .    .    .    .    .    .    .    .D=====eE-R    .   .   mov	eax, ecx
[5,11]    .    .    .    .    .    .    .    .    .    .    .    .    . D=====eER    .   .   and	eax, -2
[5,12]    .    .    .    .    .    .    .    .    .    .    .    .    . D====eE-R    .   .   add	rcx, -2
[5,13]    .    .    .    .    .    .    .    .    .    .    .    .    . DeE-----R    .   .   mov	edx, 16
[5,14]    .    .    .    .    .    .    .    .    .    .    .    .    . D=====eER    .   .   cmp	rcx, 2
[5,15]    .    .    .    .    .    .    .    .    .    .    .    .    . D======eER   .   .   jae	.LBB6_111
[5,16]    .    .    .    .    .    .    .    .    .    .    .    .    . D=====eE-R   .   .   test	cl, 2
[5,17]    .    .    .    .    .    .    .    .    .    .    .    .    .  D=====eER   .   .   jne	.LBB6_7
[5,18]    .    .    .    .    .    .    .    .    .    .    .    .    .  D-------R   .   .   vxorps	xmm1, xmm1, xmm1
[5,19]    .    .    .    .    .    .    .    .    .    .    .    .    .  DeE-----R   .   .   vmovaps	xmmword ptr [rbx + rdx - 16], xmm1
[5,20]    .    .    .    .    .    .    .    .    .    .    .    .    .  DeE-----R   .   .   vmovaps	xmmword ptr [r15 + rdx - 16], xmm1
[5,21]    .    .    .    .    .    .    .    .    .    .    .    .    .   DeE----R   .   .   vmovaps	xmmword ptr [rbx + rdx], xmm1
[5,22]    .    .    .    .    .    .    .    .    .    .    .    .    .   DeE----R   .   .   vmovaps	xmmword ptr [r15 + rdx], xmm1
[5,23]    .    .    .    .    .    .    .    .    .    .    .    .    .   DeeeeeeER  .   .   test	byte ptr [rsp + 72], 1
[5,24]    .    .    .    .    .    .    .    .    .    .    .    .    .    D=====eER .   .   jne	.LBB6_8
[5,25]    .    .    .    .    .    .    .    .    .    .    .    .    .    DeE-----R .   .   jmp	.LBB6_9
[5,26]    .    .    .    .    .    .    .    .    .    .    .    .    .    D===eE--R .   .   mov	r8, rcx
[5,27]    .    .    .    .    .    .    .    .    .    .    .    .    .    D====eE-R .   .   shr	r8
[5,28]    .    .    .    .    .    .    .    .    .    .    .    .    .    D=====eER .   .   add	r8, 1
[5,29]    .    .    .    .    .    .    .    .    .    .    .    .    .    D======eER.   .   and	r8, -2
[5,30]    .    .    .    .    .    .    .    .    .    .    .    .    .    .DeE-----R.   .   mov	edx, 48
[5,31]    .    .    .    .    .    .    .    .    .    .    .    .    .    .D-------R.   .   vxorps	xmm1, xmm1, xmm1
[5,32]    .    .    .    .    .    .    .    .    .    .    .    .    .    .D=eE----R.   .   vmovaps	xmmword ptr [rbx + rdx - 48], xmm1
[5,33]    .    .    .    .    .    .    .    .    .    .    .    .    .    .D=eE----R.   .   vmovaps	xmmword ptr [r15 + rdx - 48], xmm1
[5,34]    .    .    .    .    .    .    .    .    .    .    .    .    .    . D=eE---R.   .   vmovaps	xmmword ptr [rbx + rdx - 32], xmm1
[5,35]    .    .    .    .    .    .    .    .    .    .    .    .    .    . D=eE---R.   .   vmovaps	xmmword ptr [r15 + rdx - 32], xmm1
[5,36]    .    .    .    .    .    .    .    .    .    .    .    .    .    . D==eE--R.   .   vmovaps	xmmword ptr [rbx + rdx - 16], xmm1
[5,37]    .    .    .    .    .    .    .    .    .    .    .    .    .    .  D=eE--R.   .   vmovaps	xmmword ptr [r15 + rdx - 16], xmm1
[5,38]    .    .    .    .    .    .    .    .    .    .    .    .    .    .  D==eE-R.   .   vmovaps	xmmword ptr [rbx + rdx], xmm1
[5,39]    .    .    .    .    .    .    .    .    .    .    .    .    .    .  D==eE-R.   .   vmovaps	xmmword ptr [r15 + rdx], xmm1
[5,40]    .    .    .    .    .    .    .    .    .    .    .    .    .    .   DeE--R.   .   add	rdx, 64
[5,41]    .    .    .    .    .    .    .    .    .    .    .    .    .    .   D===eER   .   add	r8, -2
[5,42]    .    .    .    .    .    .    .    .    .    .    .    .    .    .   D====eER  .   jne	.LBB6_112
[5,43]    .    .    .    .    .    .    .    .    .    .    .    .    .    .   D=eE---R  .   add	rdx, -32
[5,44]    .    .    .    .    .    .    .    .    .    .    .    .    .    .   DeE----R  .   test	cl, 2
[5,45]    .    .    .    .    .    .    .    .    .    .    .    .    .    .   D==eE--R  .   je	.LBB6_114
[5,46]    .    .    .    .    .    .    .    .    .    .    .    .    .    .    DeeeeeeER.   test	byte ptr [rsp + 72], 1
[5,47]    .    .    .    .    .    .    .    .    .    .    .    .    .    .    D======eER   je	.LBB6_9
[5,48]    .    .    .    .    .    .    .    .    .    .    .    .    .    .    D=eE-----R   shl	rax, 4
[5,49]    .    .    .    .    .    .    .    .    .    .    .    .    .    .    D--------R   vxorps	xmm1, xmm1, xmm1
[5,50]    .    .    .    .    .    .    .    .    .    .    .    .    .    .    .D=eE----R   vmovaps	xmmword ptr [rbx + rax], xmm1
[5,51]    .    .    .    .    .    .    .    .    .    .    .    .    .    .    .D=eE----R   vmovaps	xmmword ptr [r15 + rax], xmm1
[6,0]     .    .    .    .    .    .    .    .    .    .    .    .    .    .    .D==eE---R   mov	dword ptr [rsp + 48], esi
[6,1]     .    .    .    .    .    .    .    .    .    .    .    .    .    .    .DeE-----R   test	esi, esi
[6,2]     .    .    .    .    .    .    .    .    .    .    .    .    .    .    . DeE----R   je	.LBB6_9
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
0.     10    2.9    1.0    2.6       mov	dword ptr [rsp + 48], esi
1.     10    1.0    1.0    4.4       test	esi, esi
2.     10    1.2    0.0    3.5       je	.LBB6_9
3.     10    1.0    1.0    0.0       cmp	dword ptr [rsp + 48], 4
4.     10    7.0    0.0    0.0       jne	.LBB6_5
5.     10    0.0    0.0    7.9       xor	eax, eax
6.     10    1.0    1.0    0.0       test	byte ptr [rsp + 72], 1
7.     10    7.0    0.0    0.0       jne	.LBB6_8
8.     10    1.1    1.1    5.9       jmp	.LBB6_9
9.     10    1.0    1.0    2.0       mov	rcx, qword ptr [rsp + 72]
10.    10    5.9    0.0    1.0       mov	eax, ecx
11.    10    6.0    0.0    0.0       and	eax, -2
12.    10    5.0    0.0    1.0       add	rcx, -2
13.    10    1.0    1.0    5.0       mov	edx, 16
14.    10    6.0    0.0    0.0       cmp	rcx, 2
15.    10    7.0    0.0    0.0       jae	.LBB6_111
16.    10    5.9    0.0    1.0       test	cl, 2
17.    10    6.0    0.0    0.0       jne	.LBB6_7
18.    10    0.0    0.0    7.0       vxorps	xmm1, xmm1, xmm1
19.    10    1.0    0.0    5.0       vmovaps	xmmword ptr [rbx + rdx - 16], xmm1
20.    10    1.0    0.1    4.9       vmovaps	xmmword ptr [r15 + rdx - 16], xmm1
21.    10    1.0    0.9    4.0       vmovaps	xmmword ptr [rbx + rdx], xmm1
22.    10    1.1    0.1    3.9       vmovaps	xmmword ptr [r15 + rdx], xmm1
23.    10    1.0    1.0    0.0       test	byte ptr [rsp + 72], 1
24.    10    6.1    0.0    0.0       jne	.LBB6_8
25.    10    1.0    1.0    5.1       jmp	.LBB6_9
26.    10    4.0    1.0    2.1       mov	r8, rcx
27.    10    5.0    0.0    1.1       shr	r8
28.    10    5.9    0.0    0.1       add	r8, 1
29.    10    6.9    0.0    0.0       and	r8, -2
30.    10    1.0    1.0    5.0       mov	edx, 48
31.    10    0.0    0.0    7.0       vxorps	xmm1, xmm1, xmm1
32.    10    2.0    0.0    4.0       vmovaps	xmmword ptr [rbx + rdx - 48], xmm1
33.    10    1.9    0.0    4.0       vmovaps	xmmword ptr [r15 + rdx - 48], xmm1
34.    10    2.0    1.0    3.0       vmovaps	xmmword ptr [rbx + rdx - 32], xmm1
35.    10    2.0    0.0    3.0       vmovaps	xmmword ptr [r15 + rdx - 32], xmm1
36.    10    2.9    1.0    2.0       vmovaps	xmmword ptr [rbx + rdx - 16], xmm1
37.    10    2.0    0.0    2.0       vmovaps	xmmword ptr [r15 + rdx - 16], xmm1
38.    10    3.0    1.0    1.0       vmovaps	xmmword ptr [rbx + rdx], xmm1
39.    10    2.9    0.0    1.0       vmovaps	xmmword ptr [r15 + rdx], xmm1
40.    10    1.0    1.0    2.0       add	rdx, 64
41.    10    4.0    0.0    0.0       add	r8, -2
42.    10    5.0    0.0    0.0       jne	.LBB6_112
43.    10    2.0    0.0    3.0       add	rdx, -32
44.    10    1.0    1.0    3.9       test	cl, 2
45.    10    2.9    0.9    2.0       je	.LBB6_114
46.    10    1.0    1.0    0.0       test	byte ptr [rsp + 72], 1
47.    10    7.0    0.0    0.0       je	.LBB6_9
48.    10    2.1    2.1    4.9       shl	rax, 4
49.    10    0.0    0.0    7.9       vxorps	xmm1, xmm1, xmm1
50.    10    2.1    0.0    3.9       vmovaps	xmmword ptr [rbx + rax], xmm1
51.    10    2.1    0.0    3.9       vmovaps	xmmword ptr [r15 + rax], xmm1
       10    2.9    0.4    2.5       <total>


```
</details>

</details>

<details><summary>[1] Code Region - OPS_Mixing</summary>

```
Iterations:        100
Instructions:      2800
Total Cycles:      713
Total uOps:        3000

Dispatch Width:    6
uOps Per Cycle:    4.21
IPC:               3.93
Block RThroughput: 7.0


Cycles with backend pressure increase [ 68.58% ]
Throughput Bottlenecks: 
  Resource Pressure       [ 68.58% ]
  - ICXPort0  [ 13.18% ]
  - ICXPort2  [ 68.58% ]
  - ICXPort3  [ 68.58% ]
  - ICXPort6  [ 13.04% ]
  Data Dependencies:      [ 68.58% ]
  - Register Dependencies [ 68.58% ]
  - Memory Dependencies   [ 0.00% ]

```

<details><summary>Critical sequence based on the simulation:</summary>

```

              Instruction                                 Dependency Information
 +----< 21.   vmovddup	xmm23, qword ptr [rip + .LCPI6_2]
 |
 |    < loop carried > 
 |
 +----> 0.    mov	rax, qword ptr [rsp + 88]         ## RESOURCE interference:  ICXPort2 [ probability: 99% ]
 |      1.    mov	r14, qword ptr [rax + 96]
 |      2.    test	r14, r14
 +----> 3.    mov	rax, qword ptr [rsp + 72]         ## RESOURCE interference:  ICXPort2 [ probability: 99% ]
 |      4.    je	.LBB6_14
 +----> 5.    cmp	dword ptr [rsp + 48], 0           ## RESOURCE interference:  ICXPort3 [ probability: 99% ]
 |      6.    je	.LBB6_12
 +----> 7.    vmovss	xmm1, dword ptr [rip + .LCPI6_0]  ## RESOURCE interference:  ICXPort2 [ probability: 99% ]
 |      8.    vdivss	xmm6, xmm1, xmm0
 +----> 9.    mov	rcx, qword ptr [rsp + 88]         ## RESOURCE interference:  ICXPort3 [ probability: 99% ]
 |      10.   add	rcx, 96
 |      11.   mov	qword ptr [rsp + 264], rcx
 |      12.   lea	rcx, [rdi + 40]
 |      13.   mov	qword ptr [rsp + 312], rcx
 |      14.   mov	r13d, 1
 +----> 15.   vmovss	xmm7, dword ptr [rip + .LCPI6_1]  ## RESOURCE interference:  ICXPort2 [ probability: 99% ]
 +----> 16.   vmovddup	xmm8, qword ptr [rip + .LCPI6_2]  ## RESOURCE interference:  ICXPort2 [ probability: 98% ]
 +----> 17.   vpbroadcastd	xmm9, dword ptr [rip + .LCPI6_3] ## RESOURCE interference:  ICXPort3 [ probability: 98% ]
 |      18.   vxorps	xmm10, xmm10, xmm10
 +----> 19.   vpbroadcastd	xmm11, dword ptr [rip + .LCPI6_4] ## RESOURCE interference:  ICXPort2 [ probability: 100% ]
 +----> 20.   vmovss	xmm12, dword ptr [rip + .LCPI6_5] ## RESOURCE interference:  ICXPort2 [ probability: 99% ]
 +----> 21.   vmovddup	xmm23, qword ptr [rip + .LCPI6_2] ## RESOURCE interference:  ICXPort3 [ probability: 99% ]
 +----> 22.   vbroadcastss	xmm14, dword ptr [rip + .LCPI6_0] ## RESOURCE interference:  ICXPort2 [ probability: 100% ]
 |      23.   jmp	.LBB6_26
 |      24.   mov	r14, qword ptr [r14]
 |      25.   test	r14, r14
 |      26.   jne	.LBB6_12
 |      27.   mov	byte ptr [rsp + 47], 0
 |
 |    < loop carried > 
 |
 +----> 3.    mov	rax, qword ptr [rsp + 72]         ## RESOURCE interference:  ICXPort3 [ probability: 99% ]


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
 1      5     0.50    *                   mov	rax, qword ptr [rsp + 88]
 1      5     0.50    *                   mov	r14, qword ptr [rax + 96]
 1      1     0.25                        test	r14, r14
 1      5     0.50    *                   mov	rax, qword ptr [rsp + 72]
 1      1     0.50                        je	.LBB6_14
 2      6     0.50    *                   cmp	dword ptr [rsp + 48], 0
 1      1     0.50                        je	.LBB6_12
 1      5     0.50    *                   vmovss	xmm1, dword ptr [rip + .LCPI6_0]
 1      11    3.00                        vdivss	xmm6, xmm1, xmm0
 1      5     0.50    *                   mov	rcx, qword ptr [rsp + 88]
 1      1     0.25                        add	rcx, 96
 1      1     0.50           *            mov	qword ptr [rsp + 264], rcx
 1      1     0.50                        lea	rcx, [rdi + 40]
 1      1     0.50           *            mov	qword ptr [rsp + 312], rcx
 1      1     0.25                        mov	r13d, 1
 1      5     0.50    *                   vmovss	xmm7, dword ptr [rip + .LCPI6_1]
 1      6     0.50    *                   vmovddup	xmm8, qword ptr [rip + .LCPI6_2]
 1      6     0.50    *                   vpbroadcastd	xmm9, dword ptr [rip + .LCPI6_3]
 1      0     0.17                        vxorps	xmm10, xmm10, xmm10
 1      6     0.50    *                   vpbroadcastd	xmm11, dword ptr [rip + .LCPI6_4]
 1      5     0.50    *                   vmovss	xmm12, dword ptr [rip + .LCPI6_5]
 2      7     0.50    *                   vmovddup	xmm23, qword ptr [rip + .LCPI6_2]
 1      6     0.50    *                   vbroadcastss	xmm14, dword ptr [rip + .LCPI6_0]
 1      1     0.50                        jmp	.LBB6_26
 1      5     0.50    *                   mov	r14, qword ptr [r14]
 1      1     0.25                        test	r14, r14
 1      1     0.50                        jne	.LBB6_12
 1      1     0.50           *            mov	byte ptr [rsp + 47], 0


```
</details>

<details><summary>Dynamic Dispatch Stall Cycles:</summary>

```
RAT     - Register unavailable:                      0
RCU     - Retire tokens unavailable:                 0
SCHEDQ  - Scheduler full:                            466  (65.4%)
LQ      - Load queue full:                           0
SQ      - Store queue full:                          0
GROUP   - Static restrictions on the dispatch group: 0
USH     - Uncategorised Structural Hazard:           0


```
</details>

<details><summary>Dispatch Logic - number of cycles where we saw N micro opcodes dispatched:</summary>

```
[# dispatched], [# cycles]
 0,              26  (3.6%)
 2,              93  (13.0%)
 3,              94  (13.2%)
 4,              186  (26.1%)
 5,              96  (13.5%)
 6,              218  (30.6%)


```
</details>

<details><summary>Schedulers - number of cycles where we saw N micro opcodes issued:</summary>

```
[# issued], [# cycles]
 0,          7  (1.0%)
 1,          4  (0.6%)
 2,          99  (13.9%)
 3,          204  (28.6%)
 4,          198  (27.8%)
 5,          5  (0.7%)
 6,          97  (13.6%)
 7,          5  (0.7%)
 8,          94  (13.2%)

```
</details>

<details><summary>Scheduler's queue usage:</summary>

```
[1] Resource name.
[2] Average number of used buffer entries.
[3] Maximum number of used buffer entries.
[4] Total number of buffer entries.

 [1]            [2]        [3]        [4]
ICXPortAny       57         60         60


```
</details>

<details><summary>Retire Control Unit - number of cycles where we saw N instructions retired:</summary>

```
[# retired], [# cycles]
 0,           606  (85.0%)
 1,           2  (0.3%)
 2,           1  (0.1%)
 4,           4  (0.6%)
 20,          1  (0.1%)
 24,          3  (0.4%)
 28,          96  (13.5%)

```
</details>

<details><summary>Total ROB Entries:                352</summary>

```
Max Used ROB Entries:             136  ( 38.6% )
Average Used ROB Entries per cy:  118  ( 33.5% )


```
</details>

<details><summary>Register File statistics:</summary>

```
Total number of mappings created:    2100
Max number of mappings used:         97


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
 -     3.00   3.01   2.98   7.00   7.00   1.50   2.99   3.02   1.50   1.50   1.50   

Resource pressure by instruction:
[0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   Instructions:
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     mov	rax, qword ptr [rsp + 88]
 -      -      -      -      -     1.00    -      -      -      -      -      -     mov	r14, qword ptr [rax + 96]
 -      -     0.01    -      -      -      -     0.99    -      -      -      -     test	r14, r14
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	rax, qword ptr [rsp + 72]
 -      -     0.03    -      -      -      -      -     0.97    -      -      -     je	.LBB6_14
 -      -     0.01   0.95   0.99   0.01    -     0.01   0.03    -      -      -     cmp	dword ptr [rsp + 48], 0
 -      -     0.96    -      -      -      -      -     0.04    -      -      -     je	.LBB6_12
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     vmovss	xmm1, dword ptr [rip + .LCPI6_0]
 -     3.00   1.00    -      -      -      -      -      -      -      -      -     vdivss	xmm6, xmm1, xmm0
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     mov	rcx, qword ptr [rsp + 88]
 -      -      -     0.01    -      -      -     0.05   0.94    -      -      -     add	rcx, 96
 -      -      -      -      -      -     0.50    -      -     0.50   0.50   0.50   mov	qword ptr [rsp + 264], rcx
 -      -      -     0.98    -      -      -     0.02    -      -      -      -     lea	rcx, [rdi + 40]
 -      -      -      -      -      -     0.50    -      -     0.50   0.50   0.50   mov	qword ptr [rsp + 312], rcx
 -      -     0.02   0.01    -      -      -     0.96   0.01    -      -      -     mov	r13d, 1
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     vmovss	xmm7, dword ptr [rip + .LCPI6_1]
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     vmovddup	xmm8, qword ptr [rip + .LCPI6_2]
 -      -      -      -     1.00    -      -      -      -      -      -      -     vpbroadcastd	xmm9, dword ptr [rip + .LCPI6_3]
 -      -      -      -      -      -      -      -      -      -      -      -     vxorps	xmm10, xmm10, xmm10
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     vpbroadcastd	xmm11, dword ptr [rip + .LCPI6_4]
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     vmovss	xmm12, dword ptr [rip + .LCPI6_5]
 -      -      -     0.99   1.00    -      -     0.01    -      -      -      -     vmovddup	xmm23, qword ptr [rip + .LCPI6_2]
 -      -      -      -      -     1.00    -      -      -      -      -      -     vbroadcastss	xmm14, dword ptr [rip + .LCPI6_0]
 -      -     0.03    -      -      -      -      -     0.97    -      -      -     jmp	.LBB6_26
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	r14, qword ptr [r14]
 -      -     0.01   0.04    -      -      -     0.95    -      -      -      -     test	r14, r14
 -      -     0.94    -      -      -      -      -     0.06    -      -      -     jne	.LBB6_12
 -      -      -      -      -      -     0.50    -      -     0.50   0.50   0.50   mov	byte ptr [rsp + 47], 0


```
</details>

<details><summary>Timeline view:</summary>

```
                    0123456789          0123456789          0123456789          0123456789
Index     0123456789          0123456789          0123456789          0123456789          

[0,0]     DeeeeeER  .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   mov	rax, qword ptr [rsp + 88]
[0,1]     D=====eeeeeER  .    .    .    .    .    .    .    .    .    .    .    .    .   .   mov	r14, qword ptr [rax + 96]
[0,2]     D==========eER .    .    .    .    .    .    .    .    .    .    .    .    .   .   test	r14, r14
[0,3]     DeeeeeE------R .    .    .    .    .    .    .    .    .    .    .    .    .   .   mov	rax, qword ptr [rsp + 72]
[0,4]     D===========eER.    .    .    .    .    .    .    .    .    .    .    .    .   .   je	.LBB6_14
[0,5]     .DeeeeeeE-----R.    .    .    .    .    .    .    .    .    .    .    .    .   .   cmp	dword ptr [rsp + 48], 0
[0,6]     .D======eE----R.    .    .    .    .    .    .    .    .    .    .    .    .   .   je	.LBB6_12
[0,7]     .DeeeeeE------R.    .    .    .    .    .    .    .    .    .    .    .    .   .   vmovss	xmm1, dword ptr [rip + .LCPI6_0]
[0,8]     .D=====eeeeeeeeeeeER.    .    .    .    .    .    .    .    .    .    .    .   .   vdivss	xmm6, xmm1, xmm0
[0,9]     .D=eeeeeE----------R.    .    .    .    .    .    .    .    .    .    .    .   .   mov	rcx, qword ptr [rsp + 88]
[0,10]    . D=====eE---------R.    .    .    .    .    .    .    .    .    .    .    .   .   add	rcx, 96
[0,11]    . D======eE--------R.    .    .    .    .    .    .    .    .    .    .    .   .   mov	qword ptr [rsp + 264], rcx
[0,12]    . DeE--------------R.    .    .    .    .    .    .    .    .    .    .    .   .   lea	rcx, [rdi + 40]
[0,13]    . D======eE--------R.    .    .    .    .    .    .    .    .    .    .    .   .   mov	qword ptr [rsp + 312], rcx
[0,14]    . DeE--------------R.    .    .    .    .    .    .    .    .    .    .    .   .   mov	r13d, 1
[0,15]    . DeeeeeE----------R.    .    .    .    .    .    .    .    .    .    .    .   .   vmovss	xmm7, dword ptr [rip + .LCPI6_1]
[0,16]    .  DeeeeeeE--------R.    .    .    .    .    .    .    .    .    .    .    .   .   vmovddup	xmm8, qword ptr [rip + .LCPI6_2]
[0,17]    .  DeeeeeeE--------R.    .    .    .    .    .    .    .    .    .    .    .   .   vpbroadcastd	xmm9, dword ptr [rip + .LCPI6_3]
[0,18]    .  D---------------R.    .    .    .    .    .    .    .    .    .    .    .   .   vxorps	xmm10, xmm10, xmm10
[0,19]    .  D=eeeeeeE-------R.    .    .    .    .    .    .    .    .    .    .    .   .   vpbroadcastd	xmm11, dword ptr [rip + .LCPI6_4]
[0,20]    .  D=eeeeeE--------R.    .    .    .    .    .    .    .    .    .    .    .   .   vmovss	xmm12, dword ptr [rip + .LCPI6_5]
[0,21]    .   D=eeeeeeeE-----R.    .    .    .    .    .    .    .    .    .    .    .   .   vmovddup	xmm23, qword ptr [rip + .LCPI6_2]
[0,22]    .   D==eeeeeeE-----R.    .    .    .    .    .    .    .    .    .    .    .   .   vbroadcastss	xmm14, dword ptr [rip + .LCPI6_0]
[0,23]    .   DeE------------R.    .    .    .    .    .    .    .    .    .    .    .   .   jmp	.LBB6_26
[0,24]    .   D======eeeeeE--R.    .    .    .    .    .    .    .    .    .    .    .   .   mov	r14, qword ptr [r14]
[0,25]    .   D===========eE-R.    .    .    .    .    .    .    .    .    .    .    .   .   test	r14, r14
[0,26]    .    D===========eER.    .    .    .    .    .    .    .    .    .    .    .   .   jne	.LBB6_12
[0,27]    .    D=====eE------R.    .    .    .    .    .    .    .    .    .    .    .   .   mov	byte ptr [rsp + 47], 0
[1,0]     .    D=eeeeeE------R.    .    .    .    .    .    .    .    .    .    .    .   .   mov	rax, qword ptr [rsp + 88]
[1,1]     .    D======eeeeeE-R.    .    .    .    .    .    .    .    .    .    .    .   .   mov	r14, qword ptr [rax + 96]
[1,2]     .    D===========eER.    .    .    .    .    .    .    .    .    .    .    .   .   test	r14, r14
[1,3]     .    D==eeeeeE-----R.    .    .    .    .    .    .    .    .    .    .    .   .   mov	rax, qword ptr [rsp + 72]
[1,4]     .    .D===========eER    .    .    .    .    .    .    .    .    .    .    .   .   je	.LBB6_14
[1,5]     .    .D=eeeeeeE-----R    .    .    .    .    .    .    .    .    .    .    .   .   cmp	dword ptr [rsp + 48], 0
[1,6]     .    .D=======eE----R    .    .    .    .    .    .    .    .    .    .    .   .   je	.LBB6_12
[1,7]     .    .D==eeeeeE-----R    .    .    .    .    .    .    .    .    .    .    .   .   vmovss	xmm1, dword ptr [rip + .LCPI6_0]
[1,8]     .    .D=======eeeeeeeeeeeER   .    .    .    .    .    .    .    .    .    .   .   vdivss	xmm6, xmm1, xmm0
[1,9]     .    . D=eeeeeE-----------R   .    .    .    .    .    .    .    .    .    .   .   mov	rcx, qword ptr [rsp + 88]
[1,10]    .    . D======eE----------R   .    .    .    .    .    .    .    .    .    .   .   add	rcx, 96
[1,11]    .    . D=======eE---------R   .    .    .    .    .    .    .    .    .    .   .   mov	qword ptr [rsp + 264], rcx
[1,12]    .    . D=eE---------------R   .    .    .    .    .    .    .    .    .    .   .   lea	rcx, [rdi + 40]
[1,13]    .    . D=======eE---------R   .    .    .    .    .    .    .    .    .    .   .   mov	qword ptr [rsp + 312], rcx
[1,14]    .    . DeE----------------R   .    .    .    .    .    .    .    .    .    .   .   mov	r13d, 1
[1,15]    .    .  D=eeeeeE----------R   .    .    .    .    .    .    .    .    .    .   .   vmovss	xmm7, dword ptr [rip + .LCPI6_1]
[1,16]    .    .  D=eeeeeeE---------R   .    .    .    .    .    .    .    .    .    .   .   vmovddup	xmm8, qword ptr [rip + .LCPI6_2]
[1,17]    .    .  D==eeeeeeE--------R   .    .    .    .    .    .    .    .    .    .   .   vpbroadcastd	xmm9, dword ptr [rip + .LCPI6_3]
[1,18]    .    .  D-----------------R   .    .    .    .    .    .    .    .    .    .   .   vxorps	xmm10, xmm10, xmm10
[1,19]    .    .  D===eeeeeeE-------R   .    .    .    .    .    .    .    .    .    .   .   vpbroadcastd	xmm11, dword ptr [rip + .LCPI6_4]
[1,20]    .    .  D====eeeeeE-------R   .    .    .    .    .    .    .    .    .    .   .   vmovss	xmm12, dword ptr [rip + .LCPI6_5]
[1,21]    .    .   D===eeeeeeeE-----R   .    .    .    .    .    .    .    .    .    .   .   vmovddup	xmm23, qword ptr [rip + .LCPI6_2]
[1,22]    .    .   D====eeeeeeE-----R   .    .    .    .    .    .    .    .    .    .   .   vbroadcastss	xmm14, dword ptr [rip + .LCPI6_0]
[1,23]    .    .   DeE--------------R   .    .    .    .    .    .    .    .    .    .   .   jmp	.LBB6_26
[1,24]    .    .   D=======eeeeeE---R   .    .    .    .    .    .    .    .    .    .   .   mov	r14, qword ptr [r14]
[1,25]    .    .   D============eE--R   .    .    .    .    .    .    .    .    .    .   .   test	r14, r14
[1,26]    .    .    D============eE-R   .    .    .    .    .    .    .    .    .    .   .   jne	.LBB6_12
[1,27]    .    .    D======eE-------R   .    .    .    .    .    .    .    .    .    .   .   mov	byte ptr [rsp + 47], 0
[2,0]     .    .    D===eeeeeE------R   .    .    .    .    .    .    .    .    .    .   .   mov	rax, qword ptr [rsp + 88]
[2,1]     .    .    D========eeeeeE-R   .    .    .    .    .    .    .    .    .    .   .   mov	r14, qword ptr [rax + 96]
[2,2]     .    .    D=============eER   .    .    .    .    .    .    .    .    .    .   .   test	r14, r14
[2,3]     .    .    D====eeeeeE-----R   .    .    .    .    .    .    .    .    .    .   .   mov	rax, qword ptr [rsp + 72]
[2,4]     .    .    .D=============eER  .    .    .    .    .    .    .    .    .    .   .   je	.LBB6_14
[2,5]     .    .    .D===eeeeeeE-----R  .    .    .    .    .    .    .    .    .    .   .   cmp	dword ptr [rsp + 48], 0
[2,6]     .    .    .D=========eE----R  .    .    .    .    .    .    .    .    .    .   .   je	.LBB6_12
[2,7]     .    .    .D====eeeeeE-----R  .    .    .    .    .    .    .    .    .    .   .   vmovss	xmm1, dword ptr [rip + .LCPI6_0]
[2,8]     .    .    .D==========eeeeeeeeeeeER.    .    .    .    .    .    .    .    .   .   vdivss	xmm6, xmm1, xmm0
[2,9]     .    .    . D===eeeeeE------------R.    .    .    .    .    .    .    .    .   .   mov	rcx, qword ptr [rsp + 88]
[2,10]    .    .    . D========eE-----------R.    .    .    .    .    .    .    .    .   .   add	rcx, 96
[2,11]    .    .    . D=========eE----------R.    .    .    .    .    .    .    .    .   .   mov	qword ptr [rsp + 264], rcx
[2,12]    .    .    . DeE-------------------R.    .    .    .    .    .    .    .    .   .   lea	rcx, [rdi + 40]
[2,13]    .    .    . D=========eE----------R.    .    .    .    .    .    .    .    .   .   mov	qword ptr [rsp + 312], rcx
[2,14]    .    .    . DeE-------------------R.    .    .    .    .    .    .    .    .   .   mov	r13d, 1
[2,15]    .    .    .  D===eeeeeE-----------R.    .    .    .    .    .    .    .    .   .   vmovss	xmm7, dword ptr [rip + .LCPI6_1]
[2,16]    .    .    .  D====eeeeeeE---------R.    .    .    .    .    .    .    .    .   .   vmovddup	xmm8, qword ptr [rip + .LCPI6_2]
[2,17]    .    .    .  D====eeeeeeE---------R.    .    .    .    .    .    .    .    .   .   vpbroadcastd	xmm9, dword ptr [rip + .LCPI6_3]
[2,18]    .    .    .  D--------------------R.    .    .    .    .    .    .    .    .   .   vxorps	xmm10, xmm10, xmm10
[2,19]    .    .    .  D=====eeeeeeE--------R.    .    .    .    .    .    .    .    .   .   vpbroadcastd	xmm11, dword ptr [rip + .LCPI6_4]
[2,20]    .    .    .  D======eeeeeE--------R.    .    .    .    .    .    .    .    .   .   vmovss	xmm12, dword ptr [rip + .LCPI6_5]
[2,21]    .    .    .   D=====eeeeeeeE------R.    .    .    .    .    .    .    .    .   .   vmovddup	xmm23, qword ptr [rip + .LCPI6_2]
[2,22]    .    .    .   D======eeeeeeE------R.    .    .    .    .    .    .    .    .   .   vbroadcastss	xmm14, dword ptr [rip + .LCPI6_0]
[2,23]    .    .    .   DeE-----------------R.    .    .    .    .    .    .    .    .   .   jmp	.LBB6_26
[2,24]    .    .    .   D=========eeeeeE----R.    .    .    .    .    .    .    .    .   .   mov	r14, qword ptr [r14]
[2,25]    .    .    .   D==============eE---R.    .    .    .    .    .    .    .    .   .   test	r14, r14
[2,26]    .    .    .    D==============eE--R.    .    .    .    .    .    .    .    .   .   jne	.LBB6_12
[2,27]    .    .    .    D========eE--------R.    .    .    .    .    .    .    .    .   .   mov	byte ptr [rsp + 47], 0
[3,0]     .    .    .    D=====eeeeeE-------R.    .    .    .    .    .    .    .    .   .   mov	rax, qword ptr [rsp + 88]
[3,1]     .    .    .    D==========eeeeeE--R.    .    .    .    .    .    .    .    .   .   mov	r14, qword ptr [rax + 96]
[3,2]     .    .    .    D===============eE-R.    .    .    .    .    .    .    .    .   .   test	r14, r14
[3,3]     .    .    .    D======eeeeeE------R.    .    .    .    .    .    .    .    .   .   mov	rax, qword ptr [rsp + 72]
[3,4]     .    .    .    .D===============eER.    .    .    .    .    .    .    .    .   .   je	.LBB6_14
[3,5]     .    .    .    .D=====eeeeeeE-----R.    .    .    .    .    .    .    .    .   .   cmp	dword ptr [rsp + 48], 0
[3,6]     .    .    .    .D===========eE----R.    .    .    .    .    .    .    .    .   .   je	.LBB6_12
[3,7]     .    .    .    .D======eeeeeE-----R.    .    .    .    .    .    .    .    .   .   vmovss	xmm1, dword ptr [rip + .LCPI6_0]
[3,8]     .    .    .    .D===========eeeeeeeeeeeER    .    .    .    .    .    .    .   .   vdivss	xmm6, xmm1, xmm0
[3,9]     .    .    .    . D=====eeeeeE-----------R    .    .    .    .    .    .    .   .   mov	rcx, qword ptr [rsp + 88]
[3,10]    .    .    .    . D==========eE----------R    .    .    .    .    .    .    .   .   add	rcx, 96
[3,11]    .    .    .    . D===========eE---------R    .    .    .    .    .    .    .   .   mov	qword ptr [rsp + 264], rcx
[3,12]    .    .    .    . DeE--------------------R    .    .    .    .    .    .    .   .   lea	rcx, [rdi + 40]
[3,13]    .    .    .    . D===========eE---------R    .    .    .    .    .    .    .   .   mov	qword ptr [rsp + 312], rcx
[3,14]    .    .    .    . DeE--------------------R    .    .    .    .    .    .    .   .   mov	r13d, 1
[3,15]    .    .    .    .  D=====eeeeeE----------R    .    .    .    .    .    .    .   .   vmovss	xmm7, dword ptr [rip + .LCPI6_1]
[3,16]    .    .    .    .  D======eeeeeeE--------R    .    .    .    .    .    .    .   .   vmovddup	xmm8, qword ptr [rip + .LCPI6_2]
[3,17]    .    .    .    .  D======eeeeeeE--------R    .    .    .    .    .    .    .   .   vpbroadcastd	xmm9, dword ptr [rip + .LCPI6_3]
[3,18]    .    .    .    .  D---------------------R    .    .    .    .    .    .    .   .   vxorps	xmm10, xmm10, xmm10
[3,19]    .    .    .    .  D=======eeeeeeE-------R    .    .    .    .    .    .    .   .   vpbroadcastd	xmm11, dword ptr [rip + .LCPI6_4]
[3,20]    .    .    .    .  D========eeeeeE-------R    .    .    .    .    .    .    .   .   vmovss	xmm12, dword ptr [rip + .LCPI6_5]
[3,21]    .    .    .    .   D=======eeeeeeeE-----R    .    .    .    .    .    .    .   .   vmovddup	xmm23, qword ptr [rip + .LCPI6_2]
[3,22]    .    .    .    .   D========eeeeeeE-----R    .    .    .    .    .    .    .   .   vbroadcastss	xmm14, dword ptr [rip + .LCPI6_0]
[3,23]    .    .    .    .   DeE------------------R    .    .    .    .    .    .    .   .   jmp	.LBB6_26
[3,24]    .    .    .    .   D===========eeeeeE---R    .    .    .    .    .    .    .   .   mov	r14, qword ptr [r14]
[3,25]    .    .    .    .   D================eE--R    .    .    .    .    .    .    .   .   test	r14, r14
[3,26]    .    .    .    .    D================eE-R    .    .    .    .    .    .    .   .   jne	.LBB6_12
[3,27]    .    .    .    .    D==========eE-------R    .    .    .    .    .    .    .   .   mov	byte ptr [rsp + 47], 0
[4,0]     .    .    .    .    D=======eeeeeE------R    .    .    .    .    .    .    .   .   mov	rax, qword ptr [rsp + 88]
[4,1]     .    .    .    .    D============eeeeeE-R    .    .    .    .    .    .    .   .   mov	r14, qword ptr [rax + 96]
[4,2]     .    .    .    .    D=================eER    .    .    .    .    .    .    .   .   test	r14, r14
[4,3]     .    .    .    .    D========eeeeeE-----R    .    .    .    .    .    .    .   .   mov	rax, qword ptr [rsp + 72]
[4,4]     .    .    .    .    .D=================eER   .    .    .    .    .    .    .   .   je	.LBB6_14
[4,5]     .    .    .    .    .D=======eeeeeeE-----R   .    .    .    .    .    .    .   .   cmp	dword ptr [rsp + 48], 0
[4,6]     .    .    .    .    .D=============eE----R   .    .    .    .    .    .    .   .   je	.LBB6_12
[4,7]     .    .    .    .    .D========eeeeeE-----R   .    .    .    .    .    .    .   .   vmovss	xmm1, dword ptr [rip + .LCPI6_0]
[4,8]     .    .    .    .    .D==============eeeeeeeeeeeER .    .    .    .    .    .   .   vdivss	xmm6, xmm1, xmm0
[4,9]     .    .    .    .    . D=======eeeeeE------------R .    .    .    .    .    .   .   mov	rcx, qword ptr [rsp + 88]
[4,10]    .    .    .    .    . D============eE-----------R .    .    .    .    .    .   .   add	rcx, 96
[4,11]    .    .    .    .    . D=============eE----------R .    .    .    .    .    .   .   mov	qword ptr [rsp + 264], rcx
[4,12]    .    .    .    .    . DeE-----------------------R .    .    .    .    .    .   .   lea	rcx, [rdi + 40]
[4,13]    .    .    .    .    . D=============eE----------R .    .    .    .    .    .   .   mov	qword ptr [rsp + 312], rcx
[4,14]    .    .    .    .    . DeE-----------------------R .    .    .    .    .    .   .   mov	r13d, 1
[4,15]    .    .    .    .    .  D=======eeeeeE-----------R .    .    .    .    .    .   .   vmovss	xmm7, dword ptr [rip + .LCPI6_1]
[4,16]    .    .    .    .    .  D========eeeeeeE---------R .    .    .    .    .    .   .   vmovddup	xmm8, qword ptr [rip + .LCPI6_2]
[4,17]    .    .    .    .    .  D========eeeeeeE---------R .    .    .    .    .    .   .   vpbroadcastd	xmm9, dword ptr [rip + .LCPI6_3]
[4,18]    .    .    .    .    .  D------------------------R .    .    .    .    .    .   .   vxorps	xmm10, xmm10, xmm10
[4,19]    .    .    .    .    .  D=========eeeeeeE--------R .    .    .    .    .    .   .   vpbroadcastd	xmm11, dword ptr [rip + .LCPI6_4]
[4,20]    .    .    .    .    .  D==========eeeeeE--------R .    .    .    .    .    .   .   vmovss	xmm12, dword ptr [rip + .LCPI6_5]
[4,21]    .    .    .    .    .   D=========eeeeeeeE------R .    .    .    .    .    .   .   vmovddup	xmm23, qword ptr [rip + .LCPI6_2]
[4,22]    .    .    .    .    .   D==========eeeeeeE------R .    .    .    .    .    .   .   vbroadcastss	xmm14, dword ptr [rip + .LCPI6_0]
[4,23]    .    .    .    .    .   DeE---------------------R .    .    .    .    .    .   .   jmp	.LBB6_26
[4,24]    .    .    .    .    .   D=============eeeeeE----R .    .    .    .    .    .   .   mov	r14, qword ptr [r14]
[4,25]    .    .    .    .    .   D==================eE---R .    .    .    .    .    .   .   test	r14, r14
[4,26]    .    .    .    .    .    D==================eE--R .    .    .    .    .    .   .   jne	.LBB6_12
[4,27]    .    .    .    .    .    D============eE--------R .    .    .    .    .    .   .   mov	byte ptr [rsp + 47], 0
[5,0]     .    .    .    .    .    D=========eeeeeE-------R .    .    .    .    .    .   .   mov	rax, qword ptr [rsp + 88]
[5,1]     .    .    .    .    .    D==============eeeeeE--R .    .    .    .    .    .   .   mov	r14, qword ptr [rax + 96]
[5,2]     .    .    .    .    .    D===================eE-R .    .    .    .    .    .   .   test	r14, r14
[5,3]     .    .    .    .    .    D==========eeeeeE------R .    .    .    .    .    .   .   mov	rax, qword ptr [rsp + 72]
[5,4]     .    .    .    .    .    .D===================eER .    .    .    .    .    .   .   je	.LBB6_14
[5,5]     .    .    .    .    .    .D=========eeeeeeE-----R .    .    .    .    .    .   .   cmp	dword ptr [rsp + 48], 0
[5,6]     .    .    .    .    .    .D===============eE----R .    .    .    .    .    .   .   je	.LBB6_12
[5,7]     .    .    .    .    .    .D==========eeeeeE-----R .    .    .    .    .    .   .   vmovss	xmm1, dword ptr [rip + .LCPI6_0]
[5,8]     .    .    .    .    .    .D================eeeeeeeeeeeER    .    .    .    .   .   vdivss	xmm6, xmm1, xmm0
[5,9]     .    .    .    .    .    . D=========eeeeeE------------R    .    .    .    .   .   mov	rcx, qword ptr [rsp + 88]
[5,10]    .    .    .    .    .    . D==============eE-----------R    .    .    .    .   .   add	rcx, 96
[5,11]    .    .    .    .    .    . D===============eE----------R    .    .    .    .   .   mov	qword ptr [rsp + 264], rcx
[5,12]    .    .    .    .    .    . DeE-------------------------R    .    .    .    .   .   lea	rcx, [rdi + 40]
[5,13]    .    .    .    .    .    . D===============eE----------R    .    .    .    .   .   mov	qword ptr [rsp + 312], rcx
[5,14]    .    .    .    .    .    . D=eE------------------------R    .    .    .    .   .   mov	r13d, 1
[5,15]    .    .    .    .    .    .  D=========eeeeeE-----------R    .    .    .    .   .   vmovss	xmm7, dword ptr [rip + .LCPI6_1]
[5,16]    .    .    .    .    .    .  D==========eeeeeeE---------R    .    .    .    .   .   vmovddup	xmm8, qword ptr [rip + .LCPI6_2]
[5,17]    .    .    .    .    .    .  D==========eeeeeeE---------R    .    .    .    .   .   vpbroadcastd	xmm9, dword ptr [rip + .LCPI6_3]
[5,18]    .    .    .    .    .    .  D--------------------------R    .    .    .    .   .   vxorps	xmm10, xmm10, xmm10
[5,19]    .    .    .    .    .    .  D===========eeeeeeE--------R    .    .    .    .   .   vpbroadcastd	xmm11, dword ptr [rip + .LCPI6_4]
[5,20]    .    .    .    .    .    .  D============eeeeeE--------R    .    .    .    .   .   vmovss	xmm12, dword ptr [rip + .LCPI6_5]
[5,21]    .    .    .    .    .    .   D===========eeeeeeeE------R    .    .    .    .   .   vmovddup	xmm23, qword ptr [rip + .LCPI6_2]
[5,22]    .    .    .    .    .    .   D============eeeeeeE------R    .    .    .    .   .   vbroadcastss	xmm14, dword ptr [rip + .LCPI6_0]
[5,23]    .    .    .    .    .    .   DeE-----------------------R    .    .    .    .   .   jmp	.LBB6_26
[5,24]    .    .    .    .    .    .   D===============eeeeeE----R    .    .    .    .   .   mov	r14, qword ptr [r14]
[5,25]    .    .    .    .    .    .   D====================eE---R    .    .    .    .   .   test	r14, r14
[5,26]    .    .    .    .    .    .    D====================eE--R    .    .    .    .   .   jne	.LBB6_12
[5,27]    .    .    .    .    .    .    D==============eE--------R    .    .    .    .   .   mov	byte ptr [rsp + 47], 0
[6,0]     .    .    .    .    .    .    D===========eeeeeE-------R    .    .    .    .   .   mov	rax, qword ptr [rsp + 88]
[6,1]     .    .    .    .    .    .    D================eeeeeE--R    .    .    .    .   .   mov	r14, qword ptr [rax + 96]
[6,2]     .    .    .    .    .    .    D=====================eE-R    .    .    .    .   .   test	r14, r14
[6,3]     .    .    .    .    .    .    D============eeeeeE------R    .    .    .    .   .   mov	rax, qword ptr [rsp + 72]
[6,4]     .    .    .    .    .    .    .D=====================eER    .    .    .    .   .   je	.LBB6_14
[6,5]     .    .    .    .    .    .    .D===========eeeeeeE-----R    .    .    .    .   .   cmp	dword ptr [rsp + 48], 0
[6,6]     .    .    .    .    .    .    .D=================eE----R    .    .    .    .   .   je	.LBB6_12
[6,7]     .    .    .    .    .    .    .D============eeeeeE-----R    .    .    .    .   .   vmovss	xmm1, dword ptr [rip + .LCPI6_0]
[6,8]     .    .    .    .    .    .    .D==================eeeeeeeeeeeER  .    .    .   .   vdivss	xmm6, xmm1, xmm0
[6,9]     .    .    .    .    .    .    . D===========eeeeeE------------R  .    .    .   .   mov	rcx, qword ptr [rsp + 88]
[6,10]    .    .    .    .    .    .    . D================eE-----------R  .    .    .   .   add	rcx, 96
[6,11]    .    .    .    .    .    .    . D=================eE----------R  .    .    .   .   mov	qword ptr [rsp + 264], rcx
[6,12]    .    .    .    .    .    .    . DeE---------------------------R  .    .    .   .   lea	rcx, [rdi + 40]
[6,13]    .    .    .    .    .    .    . D=================eE----------R  .    .    .   .   mov	qword ptr [rsp + 312], rcx
[6,14]    .    .    .    .    .    .    . DeE---------------------------R  .    .    .   .   mov	r13d, 1
[6,15]    .    .    .    .    .    .    .  D===========eeeeeE-----------R  .    .    .   .   vmovss	xmm7, dword ptr [rip + .LCPI6_1]
[6,16]    .    .    .    .    .    .    .  D============eeeeeeE---------R  .    .    .   .   vmovddup	xmm8, qword ptr [rip + .LCPI6_2]
[6,17]    .    .    .    .    .    .    .  D============eeeeeeE---------R  .    .    .   .   vpbroadcastd	xmm9, dword ptr [rip + .LCPI6_3]
[6,18]    .    .    .    .    .    .    .  D----------------------------R  .    .    .   .   vxorps	xmm10, xmm10, xmm10
[6,19]    .    .    .    .    .    .    .  D=============eeeeeeE--------R  .    .    .   .   vpbroadcastd	xmm11, dword ptr [rip + .LCPI6_4]
[6,20]    .    .    .    .    .    .    .  D==============eeeeeE--------R  .    .    .   .   vmovss	xmm12, dword ptr [rip + .LCPI6_5]
[6,21]    .    .    .    .    .    .    .   D=============eeeeeeeE------R  .    .    .   .   vmovddup	xmm23, qword ptr [rip + .LCPI6_2]
[6,22]    .    .    .    .    .    .    .   D==============eeeeeeE------R  .    .    .   .   vbroadcastss	xmm14, dword ptr [rip + .LCPI6_0]
[6,23]    .    .    .    .    .    .    .   D=eE------------------------R  .    .    .   .   jmp	.LBB6_26
[6,24]    .    .    .    .    .    .    .   D=================eeeeeE----R  .    .    .   .   mov	r14, qword ptr [r14]
[6,25]    .    .    .    .    .    .    .    D=====================eE---R  .    .    .   .   test	r14, r14
[6,26]    .    .    .    .    .    .    .    D======================eE--R  .    .    .   .   jne	.LBB6_12
[6,27]    .    .    .    .    .    .    .    D================eE--------R  .    .    .   .   mov	byte ptr [rsp + 47], 0
[7,0]     .    .    .    .    .    .    .    D=============eeeeeE-------R  .    .    .   .   mov	rax, qword ptr [rsp + 88]
[7,1]     .    .    .    .    .    .    .    .D=================eeeeeE--R  .    .    .   .   mov	r14, qword ptr [rax + 96]
[7,2]     .    .    .    .    .    .    .    .D======================eE-R  .    .    .   .   test	r14, r14
[7,3]     .    .    .    .    .    .    .    .D=============eeeeeE------R  .    .    .   .   mov	rax, qword ptr [rsp + 72]
[7,4]     .    .    .    .    .    .    .    .D=======================eER  .    .    .   .   je	.LBB6_14
[7,5]     .    .    .    .    .    .    .    .D=============eeeeeeE-----R  .    .    .   .   cmp	dword ptr [rsp + 48], 0
[7,6]     .    .    .    .    .    .    .    . D==================eE----R  .    .    .   .   je	.LBB6_12
[7,7]     .    .    .    .    .    .    .    . D=============eeeeeE-----R  .    .    .   .   vmovss	xmm1, dword ptr [rip + .LCPI6_0]
[7,8]     .    .    .    .    .    .    .    . D===================eeeeeeeeeeeER.    .   .   vdivss	xmm6, xmm1, xmm0
[7,9]     .    .    .    .    .    .    .    . D=============eeeeeE------------R.    .   .   mov	rcx, qword ptr [rsp + 88]
[7,10]    .    .    .    .    .    .    .    . D==================eE-----------R.    .   .   add	rcx, 96
[7,11]    .    .    .    .    .    .    .    .  D==================eE----------R.    .   .   mov	qword ptr [rsp + 264], rcx
[7,12]    .    .    .    .    .    .    .    .  DeE----------------------------R.    .   .   lea	rcx, [rdi + 40]
[7,13]    .    .    .    .    .    .    .    .  D==================eE----------R.    .   .   mov	qword ptr [rsp + 312], rcx
[7,14]    .    .    .    .    .    .    .    .  DeE----------------------------R.    .   .   mov	r13d, 1
[7,15]    .    .    .    .    .    .    .    .   D============eeeeeE-----------R.    .   .   vmovss	xmm7, dword ptr [rip + .LCPI6_1]
[7,16]    .    .    .    .    .    .    .    .   D=============eeeeeeE---------R.    .   .   vmovddup	xmm8, qword ptr [rip + .LCPI6_2]
[7,17]    .    .    .    .    .    .    .    .   D=============eeeeeeE---------R.    .   .   vpbroadcastd	xmm9, dword ptr [rip + .LCPI6_3]
[7,18]    .    .    .    .    .    .    .    .   D-----------------------------R.    .   .   vxorps	xmm10, xmm10, xmm10
[7,19]    .    .    .    .    .    .    .    .   D==============eeeeeeE--------R.    .   .   vpbroadcastd	xmm11, dword ptr [rip + .LCPI6_4]
[7,20]    .    .    .    .    .    .    .    .   D===============eeeeeE--------R.    .   .   vmovss	xmm12, dword ptr [rip + .LCPI6_5]
[7,21]    .    .    .    .    .    .    .    .    D==============eeeeeeeE------R.    .   .   vmovddup	xmm23, qword ptr [rip + .LCPI6_2]
[7,22]    .    .    .    .    .    .    .    .    D===============eeeeeeE------R.    .   .   vbroadcastss	xmm14, dword ptr [rip + .LCPI6_0]
[7,23]    .    .    .    .    .    .    .    .    .D=eE------------------------R.    .   .   jmp	.LBB6_26
[7,24]    .    .    .    .    .    .    .    .    .D=================eeeeeE----R.    .   .   mov	r14, qword ptr [r14]
[7,25]    .    .    .    .    .    .    .    .    . D=====================eE---R.    .   .   test	r14, r14
[7,26]    .    .    .    .    .    .    .    .    . D======================eE--R.    .   .   jne	.LBB6_12
[7,27]    .    .    .    .    .    .    .    .    . D================eE--------R.    .   .   mov	byte ptr [rsp + 47], 0
[8,0]     .    .    .    .    .    .    .    .    . D=============eeeeeE-------R.    .   .   mov	rax, qword ptr [rsp + 88]
[8,1]     .    .    .    .    .    .    .    .    .  D=================eeeeeE--R.    .   .   mov	r14, qword ptr [rax + 96]
[8,2]     .    .    .    .    .    .    .    .    .  D======================eE-R.    .   .   test	r14, r14
[8,3]     .    .    .    .    .    .    .    .    .  D=============eeeeeE------R.    .   .   mov	rax, qword ptr [rsp + 72]
[8,4]     .    .    .    .    .    .    .    .    .  D=======================eER.    .   .   je	.LBB6_14
[8,5]     .    .    .    .    .    .    .    .    .  D=============eeeeeeE-----R.    .   .   cmp	dword ptr [rsp + 48], 0
[8,6]     .    .    .    .    .    .    .    .    .   D==================eE----R.    .   .   je	.LBB6_12
[8,7]     .    .    .    .    .    .    .    .    .   D=============eeeeeE-----R.    .   .   vmovss	xmm1, dword ptr [rip + .LCPI6_0]
[8,8]     .    .    .    .    .    .    .    .    .   D===================eeeeeeeeeeeER  .   vdivss	xmm6, xmm1, xmm0
[8,9]     .    .    .    .    .    .    .    .    .   D=============eeeeeE------------R  .   mov	rcx, qword ptr [rsp + 88]
[8,10]    .    .    .    .    .    .    .    .    .   D==================eE-----------R  .   add	rcx, 96
[8,11]    .    .    .    .    .    .    .    .    .    D==================eE----------R  .   mov	qword ptr [rsp + 264], rcx
[8,12]    .    .    .    .    .    .    .    .    .    DeE----------------------------R  .   lea	rcx, [rdi + 40]
[8,13]    .    .    .    .    .    .    .    .    .    D==================eE----------R  .   mov	qword ptr [rsp + 312], rcx
[8,14]    .    .    .    .    .    .    .    .    .    DeE----------------------------R  .   mov	r13d, 1
[8,15]    .    .    .    .    .    .    .    .    .    .D============eeeeeE-----------R  .   vmovss	xmm7, dword ptr [rip + .LCPI6_1]
[8,16]    .    .    .    .    .    .    .    .    .    .D=============eeeeeeE---------R  .   vmovddup	xmm8, qword ptr [rip + .LCPI6_2]
[8,17]    .    .    .    .    .    .    .    .    .    .D=============eeeeeeE---------R  .   vpbroadcastd	xmm9, dword ptr [rip + .LCPI6_3]
[8,18]    .    .    .    .    .    .    .    .    .    .D-----------------------------R  .   vxorps	xmm10, xmm10, xmm10
[8,19]    .    .    .    .    .    .    .    .    .    .D==============eeeeeeE--------R  .   vpbroadcastd	xmm11, dword ptr [rip + .LCPI6_4]
[8,20]    .    .    .    .    .    .    .    .    .    .D===============eeeeeE--------R  .   vmovss	xmm12, dword ptr [rip + .LCPI6_5]
[8,21]    .    .    .    .    .    .    .    .    .    . D==============eeeeeeeE------R  .   vmovddup	xmm23, qword ptr [rip + .LCPI6_2]
[8,22]    .    .    .    .    .    .    .    .    .    . D===============eeeeeeE------R  .   vbroadcastss	xmm14, dword ptr [rip + .LCPI6_0]
[8,23]    .    .    .    .    .    .    .    .    .    .  D=eE------------------------R  .   jmp	.LBB6_26
[8,24]    .    .    .    .    .    .    .    .    .    .  D=================eeeeeE----R  .   mov	r14, qword ptr [r14]
[8,25]    .    .    .    .    .    .    .    .    .    .   D=====================eE---R  .   test	r14, r14
[8,26]    .    .    .    .    .    .    .    .    .    .   D======================eE--R  .   jne	.LBB6_12
[8,27]    .    .    .    .    .    .    .    .    .    .   D================eE--------R  .   mov	byte ptr [rsp + 47], 0
[9,0]     .    .    .    .    .    .    .    .    .    .   D=============eeeeeE-------R  .   mov	rax, qword ptr [rsp + 88]
[9,1]     .    .    .    .    .    .    .    .    .    .    D=================eeeeeE--R  .   mov	r14, qword ptr [rax + 96]
[9,2]     .    .    .    .    .    .    .    .    .    .    D======================eE-R  .   test	r14, r14
[9,3]     .    .    .    .    .    .    .    .    .    .    D=============eeeeeE------R  .   mov	rax, qword ptr [rsp + 72]
[9,4]     .    .    .    .    .    .    .    .    .    .    D=======================eER  .   je	.LBB6_14
[9,5]     .    .    .    .    .    .    .    .    .    .    D=============eeeeeeE-----R  .   cmp	dword ptr [rsp + 48], 0
[9,6]     .    .    .    .    .    .    .    .    .    .    .D==================eE----R  .   je	.LBB6_12
[9,7]     .    .    .    .    .    .    .    .    .    .    .D=============eeeeeE-----R  .   vmovss	xmm1, dword ptr [rip + .LCPI6_0]
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
0.     10    8.5    8.5    6.0       mov	rax, qword ptr [rsp + 88]
1.     10    13.2   0.0    1.5       mov	r14, qword ptr [rax + 96]
2.     10    18.2   0.0    0.6       test	r14, r14
3.     10    9.1    9.1    5.7       mov	rax, qword ptr [rsp + 72]
4.     10    18.6   0.0    0.0       je	.LBB6_14
5.     10    8.5    8.5    5.0       cmp	dword ptr [rsp + 48], 0
6.     10    14.2   0.0    4.0       je	.LBB6_12
7.     10    9.1    9.1    5.1       vmovss	xmm1, dword ptr [rip + .LCPI6_0]
8.     10    14.8   0.7    0.0       vdivss	xmm6, xmm1, xmm0
9.     10    8.6    8.6    11.6      mov	rcx, qword ptr [rsp + 88]
10.    10    13.5   0.0    10.6      add	rcx, 96
11.    10    14.2   0.0    9.6       mov	qword ptr [rsp + 264], rcx
12.    10    1.1    1.1    22.7      lea	rcx, [rdi + 40]
13.    10    14.2   0.0    9.6       mov	qword ptr [rsp + 312], rcx
14.    10    1.1    1.1    22.7      mov	r13d, 1
15.    10    8.2    8.2    10.7      vmovss	xmm7, dword ptr [rip + .LCPI6_1]
16.    10    9.0    9.0    8.8       vmovddup	xmm8, qword ptr [rip + .LCPI6_2]
17.    10    9.1    9.1    8.7       vpbroadcastd	xmm9, dword ptr [rip + .LCPI6_3]
18.    10    0.0    0.0    23.8      vxorps	xmm10, xmm10, xmm10
19.    10    10.1   10.1   7.7       vpbroadcastd	xmm11, dword ptr [rip + .LCPI6_4]
20.    10    11.0   11.0   7.8       vmovss	xmm12, dword ptr [rip + .LCPI6_5]
21.    10    10.1   10.1   5.7       vmovddup	xmm23, qword ptr [rip + .LCPI6_2]
22.    10    11.1   11.1   5.7       vbroadcastss	xmm14, dword ptr [rip + .LCPI6_0]
23.    10    1.4    1.4    20.1      jmp	.LBB6_26
24.    10    13.9   0.0    3.6       mov	r14, qword ptr [r14]
25.    10    18.5   0.0    2.6       test	r14, r14
26.    10    18.9   0.0    1.6       jne	.LBB6_12
27.    10    12.9   0.0    7.6       mov	byte ptr [rsp + 47], 0
       10    10.8   4.2    8.2       <total>


```
</details>

</details>

<details><summary>[2] Code Region - OPS_FillSoundBuffer</summary>

```
Iterations:        100
Instructions:      1700
Total Cycles:      421
Total uOps:        2100

Dispatch Width:    6
uOps Per Cycle:    4.99
IPC:               4.04
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
 2      6     0.50    *                   cmp	dword ptr [rsp + 48], 0
 1      1     0.50                        je	.LBB6_17
 1      1     0.25                        mov	rdx, rax
 1      5     0.50    *                   mov	rax, qword ptr [rsp + 248]
 1      5     0.50    *                   mov	rax, qword ptr [rax]
 1      0     0.17                        xor	ecx, ecx
 1      6     0.50    *                   vmovaps	xmm0, xmmword ptr [rbx + rcx]
 1      4     0.50                        cvtps2dq	xmm0, xmm0
 1      6     0.50    *                   vmovaps	xmm1, xmmword ptr [r15 + rcx]
 1      4     0.50                        cvtps2dq	xmm1, xmm1
 1      1     0.50                        vpunpckhdq	xmm2, xmm0, xmm1
 1      1     0.50                        vpunpckldq	xmm0, xmm0, xmm1
 1      3     1.00                        vinserti128	ymm0, ymm0, xmm2, 1
 4      5     2.00           *            vpmovsdw	xmmword ptr [rax + rcx], ymm0
 1      1     0.25                        add	rcx, 16
 1      1     0.25                        add	rdx, -1
 1      1     0.50                        jne	.LBB6_16


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
 0,              21  (5.0%)
 1,              1  (0.2%)
 3,              98  (23.3%)
 5,              1  (0.2%)
 6,              300  (71.3%)


```
</details>

<details><summary>Schedulers - number of cycles where we saw N micro opcodes issued:</summary>

```
[# issued], [# cycles]
 0,          11  (2.6%)
 1,          3  (0.7%)
 2,          8  (1.9%)
 3,          145  (34.4%)
 4,          53  (12.6%)
 5,          52  (12.4%)
 6,          53  (12.6%)
 7,          3  (0.7%)
 8,          47  (11.2%)
 9,          1  (0.2%)
 10,          45  (10.7%)

```
</details>

<details><summary>Scheduler's queue usage:</summary>

```
[1] Resource name.
[2] Average number of used buffer entries.
[3] Maximum number of used buffer entries.
[4] Total number of buffer entries.

 [1]            [2]        [3]        [4]
ICXPortAny       24         28         60


```
</details>

<details><summary>Retire Control Unit - number of cycles where we saw N instructions retired:</summary>

```
[# retired], [# cycles]
 0,           268  (63.7%)
 1,           49  (11.6%)
 2,           1  (0.2%)
 3,           3  (0.7%)
 4,           1  (0.2%)
 16,          47  (11.2%)
 17,          52  (12.4%)

```
</details>

<details><summary>Total ROB Entries:                352</summary>

```
Max Used ROB Entries:             123  ( 34.9% )
Average Used ROB Entries per cy:  98  ( 27.8% )


```
</details>

<details><summary>Register File statistics:</summary>

```
Total number of mappings created:    1500
Max number of mappings used:         87


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
 -      -     2.99   3.00   2.50   2.50   0.50   4.02   2.99   0.50   0.50   0.50   

Resource pressure by instruction:
[0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   Instructions:
 -      -     0.02   0.46   0.49   0.51    -     0.02   0.50    -      -      -     cmp	dword ptr [rsp + 48], 0
 -      -     0.05    -      -      -      -      -     0.95    -      -      -     je	.LBB6_17
 -      -     0.47   0.49    -      -      -     0.01   0.03    -      -      -     mov	rdx, rax
 -      -      -      -     0.03   0.97    -      -      -      -      -      -     mov	rax, qword ptr [rsp + 248]
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     mov	rax, qword ptr [rax]
 -      -      -      -      -      -      -      -      -      -      -      -     xor	ecx, ecx
 -      -      -      -     0.50   0.50    -      -      -      -      -      -     vmovaps	xmm0, xmmword ptr [rbx + rcx]
 -      -     0.97   0.03    -      -      -      -      -      -      -      -     cvtps2dq	xmm0, xmm0
 -      -      -      -     0.49   0.51    -      -      -      -      -      -     vmovaps	xmm1, xmmword ptr [r15 + rcx]
 -      -     0.97   0.03    -      -      -      -      -      -      -      -     cvtps2dq	xmm1, xmm1
 -      -      -     0.97    -      -      -     0.03    -      -      -      -     vpunpckhdq	xmm2, xmm0, xmm1
 -      -      -     0.06    -      -      -     0.94    -      -      -      -     vpunpckldq	xmm0, xmm0, xmm1
 -      -      -      -      -      -      -     1.00    -      -      -      -     vinserti128	ymm0, ymm0, xmm2, 1
 -      -      -      -      -      -     0.50   2.00    -     0.50   0.50   0.50   vpmovsdw	xmmword ptr [rax + rcx], ymm0
 -      -     0.46   0.02    -      -      -     0.02   0.50    -      -      -     add	rcx, 16
 -      -     0.03   0.94    -      -      -      -     0.03    -      -      -     add	rdx, -1
 -      -     0.02    -      -      -      -      -     0.98    -      -      -     jne	.LBB6_16


```
</details>

<details><summary>Timeline view:</summary>

```
                    0123456789          0123456789          0123456789 
Index     0123456789          0123456789          0123456789          0

[0,0]     DeeeeeeER .    .    .    .    .    .    .    .    .    .    .   cmp	dword ptr [rsp + 48], 0
[0,1]     D======eER.    .    .    .    .    .    .    .    .    .    .   je	.LBB6_17
[0,2]     DeE------R.    .    .    .    .    .    .    .    .    .    .   mov	rdx, rax
[0,3]     DeeeeeE--R.    .    .    .    .    .    .    .    .    .    .   mov	rax, qword ptr [rsp + 248]
[0,4]     D=====eeeeeER  .    .    .    .    .    .    .    .    .    .   mov	rax, qword ptr [rax]
[0,5]     .D----------R  .    .    .    .    .    .    .    .    .    .   xor	ecx, ecx
[0,6]     .DeeeeeeE---R  .    .    .    .    .    .    .    .    .    .   vmovaps	xmm0, xmmword ptr [rbx + rcx]
[0,7]     .D======eeeeER .    .    .    .    .    .    .    .    .    .   cvtps2dq	xmm0, xmm0
[0,8]     .DeeeeeeE----R .    .    .    .    .    .    .    .    .    .   vmovaps	xmm1, xmmword ptr [r15 + rcx]
[0,9]     .D======eeeeER .    .    .    .    .    .    .    .    .    .   cvtps2dq	xmm1, xmm1
[0,10]    .D==========eER.    .    .    .    .    .    .    .    .    .   vpunpckhdq	xmm2, xmm0, xmm1
[0,11]    . D=========eER.    .    .    .    .    .    .    .    .    .   vpunpckldq	xmm0, xmm0, xmm1
[0,12]    . D==========eeeER  .    .    .    .    .    .    .    .    .   vinserti128	ymm0, ymm0, xmm2, 1
[0,13]    . D=============eeeeeER  .    .    .    .    .    .    .    .   vpmovsdw	xmmword ptr [rax + rcx], ymm0
[0,14]    .  DeE----------------R  .    .    .    .    .    .    .    .   add	rcx, 16
[0,15]    .  DeE----------------R  .    .    .    .    .    .    .    .   add	rdx, -1
[0,16]    .  D=eE---------------R  .    .    .    .    .    .    .    .   jne	.LBB6_16
[1,0]     .  DeeeeeeE-----------R  .    .    .    .    .    .    .    .   cmp	dword ptr [rsp + 48], 0
[1,1]     .  D======eE----------R  .    .    .    .    .    .    .    .   je	.LBB6_17
[1,2]     .   D======eE---------R  .    .    .    .    .    .    .    .   mov	rdx, rax
[1,3]     .   DeeeeeE-----------R  .    .    .    .    .    .    .    .   mov	rax, qword ptr [rsp + 248]
[1,4]     .   D=====eeeeeE------R  .    .    .    .    .    .    .    .   mov	rax, qword ptr [rax]
[1,5]     .   D-----------------R  .    .    .    .    .    .    .    .   xor	ecx, ecx
[1,6]     .   DeeeeeeE----------R  .    .    .    .    .    .    .    .   vmovaps	xmm0, xmmword ptr [rbx + rcx]
[1,7]     .   D======eeeeE------R  .    .    .    .    .    .    .    .   cvtps2dq	xmm0, xmm0
[1,8]     .    DeeeeeeE---------R  .    .    .    .    .    .    .    .   vmovaps	xmm1, xmmword ptr [r15 + rcx]
[1,9]     .    D======eeeeE-----R  .    .    .    .    .    .    .    .   cvtps2dq	xmm1, xmm1
[1,10]    .    D==========eE----R  .    .    .    .    .    .    .    .   vpunpckhdq	xmm2, xmm0, xmm1
[1,11]    .    D===========eE---R  .    .    .    .    .    .    .    .   vpunpckldq	xmm0, xmm0, xmm1
[1,12]    .    D============eeeER  .    .    .    .    .    .    .    .   vinserti128	ymm0, ymm0, xmm2, 1
[1,13]    .    .D==============eeeeeER  .    .    .    .    .    .    .   vpmovsdw	xmmword ptr [rax + rcx], ymm0
[1,14]    .    .DeE------------------R  .    .    .    .    .    .    .   add	rcx, 16
[1,15]    .    .D=====eE-------------R  .    .    .    .    .    .    .   add	rdx, -1
[1,16]    .    . D=====eE------------R  .    .    .    .    .    .    .   jne	.LBB6_16
[2,0]     .    . DeeeeeeE------------R  .    .    .    .    .    .    .   cmp	dword ptr [rsp + 48], 0
[2,1]     .    . D======eE-----------R  .    .    .    .    .    .    .   je	.LBB6_17
[2,2]     .    . D=======eE----------R  .    .    .    .    .    .    .   mov	rdx, rax
[2,3]     .    . DeeeeeE-------------R  .    .    .    .    .    .    .   mov	rax, qword ptr [rsp + 248]
[2,4]     .    .  D====eeeeeE--------R  .    .    .    .    .    .    .   mov	rax, qword ptr [rax]
[2,5]     .    .  D------------------R  .    .    .    .    .    .    .   xor	ecx, ecx
[2,6]     .    .  DeeeeeeE-----------R  .    .    .    .    .    .    .   vmovaps	xmm0, xmmword ptr [rbx + rcx]
[2,7]     .    .  D======eeeeE-------R  .    .    .    .    .    .    .   cvtps2dq	xmm0, xmm0
[2,8]     .    .  DeeeeeeE-----------R  .    .    .    .    .    .    .   vmovaps	xmm1, xmmword ptr [r15 + rcx]
[2,9]     .    .  D=======eeeeE------R  .    .    .    .    .    .    .   cvtps2dq	xmm1, xmm1
[2,10]    .    .   D==========eE-----R  .    .    .    .    .    .    .   vpunpckhdq	xmm2, xmm0, xmm1
[2,11]    .    .   D==========eE-----R  .    .    .    .    .    .    .   vpunpckldq	xmm0, xmm0, xmm1
[2,12]    .    .   D=============eeeER  .    .    .    .    .    .    .   vinserti128	ymm0, ymm0, xmm2, 1
[2,13]    .    .    D===============eeeeeER  .    .    .    .    .    .   vpmovsdw	xmmword ptr [rax + rcx], ymm0
[2,14]    .    .    DeE-------------------R  .    .    .    .    .    .   add	rcx, 16
[2,15]    .    .    D=====eE--------------R  .    .    .    .    .    .   add	rdx, -1
[2,16]    .    .    .D=====eE-------------R  .    .    .    .    .    .   jne	.LBB6_16
[3,0]     .    .    .D=eeeeeeE------------R  .    .    .    .    .    .   cmp	dword ptr [rsp + 48], 0
[3,1]     .    .    .D=======eE-----------R  .    .    .    .    .    .   je	.LBB6_17
[3,2]     .    .    .D======eE------------R  .    .    .    .    .    .   mov	rdx, rax
[3,3]     .    .    .DeeeeeE--------------R  .    .    .    .    .    .   mov	rax, qword ptr [rsp + 248]
[3,4]     .    .    . D====eeeeeE---------R  .    .    .    .    .    .   mov	rax, qword ptr [rax]
[3,5]     .    .    . D-------------------R  .    .    .    .    .    .   xor	ecx, ecx
[3,6]     .    .    . D=eeeeeeE-----------R  .    .    .    .    .    .   vmovaps	xmm0, xmmword ptr [rbx + rcx]
[3,7]     .    .    . D=======eeeeE-------R  .    .    .    .    .    .   cvtps2dq	xmm0, xmm0
[3,8]     .    .    . D=eeeeeeE-----------R  .    .    .    .    .    .   vmovaps	xmm1, xmmword ptr [r15 + rcx]
[3,9]     .    .    . D========eeeeE------R  .    .    .    .    .    .   cvtps2dq	xmm1, xmm1
[3,10]    .    .    .  D===========eE-----R  .    .    .    .    .    .   vpunpckhdq	xmm2, xmm0, xmm1
[3,11]    .    .    .  D===========eE-----R  .    .    .    .    .    .   vpunpckldq	xmm0, xmm0, xmm1
[3,12]    .    .    .  D==============eeeER  .    .    .    .    .    .   vinserti128	ymm0, ymm0, xmm2, 1
[3,13]    .    .    .   D================eeeeeER  .    .    .    .    .   vpmovsdw	xmmword ptr [rax + rcx], ymm0
[3,14]    .    .    .   DeE--------------------R  .    .    .    .    .   add	rcx, 16
[3,15]    .    .    .   D====eE----------------R  .    .    .    .    .   add	rdx, -1
[3,16]    .    .    .    D====eE---------------R  .    .    .    .    .   jne	.LBB6_16
[4,0]     .    .    .    D=eeeeeeE-------------R  .    .    .    .    .   cmp	dword ptr [rsp + 48], 0
[4,1]     .    .    .    D=======eE------------R  .    .    .    .    .   je	.LBB6_17
[4,2]     .    .    .    D======eE-------------R  .    .    .    .    .   mov	rdx, rax
[4,3]     .    .    .    DeeeeeE---------------R  .    .    .    .    .   mov	rax, qword ptr [rsp + 248]
[4,4]     .    .    .    .D====eeeeeE----------R  .    .    .    .    .   mov	rax, qword ptr [rax]
[4,5]     .    .    .    .D--------------------R  .    .    .    .    .   xor	ecx, ecx
[4,6]     .    .    .    .D=eeeeeeE------------R  .    .    .    .    .   vmovaps	xmm0, xmmword ptr [rbx + rcx]
[4,7]     .    .    .    .D=======eeeeE--------R  .    .    .    .    .   cvtps2dq	xmm0, xmm0
[4,8]     .    .    .    .D=eeeeeeE------------R  .    .    .    .    .   vmovaps	xmm1, xmmword ptr [r15 + rcx]
[4,9]     .    .    .    .D=======eeeeE--------R  .    .    .    .    .   cvtps2dq	xmm1, xmm1
[4,10]    .    .    .    . D==========eE-------R  .    .    .    .    .   vpunpckhdq	xmm2, xmm0, xmm1
[4,11]    .    .    .    . D===========eE------R  .    .    .    .    .   vpunpckldq	xmm0, xmm0, xmm1
[4,12]    .    .    .    . D============eeeE---R  .    .    .    .    .   vinserti128	ymm0, ymm0, xmm2, 1
[4,13]    .    .    .    .  D==============eeeeeER.    .    .    .    .   vpmovsdw	xmmword ptr [rax + rcx], ymm0
[4,14]    .    .    .    .  DeE------------------R.    .    .    .    .   add	rcx, 16
[4,15]    .    .    .    .  D====eE--------------R.    .    .    .    .   add	rdx, -1
[4,16]    .    .    .    .   D====eE-------------R.    .    .    .    .   jne	.LBB6_16
[5,0]     .    .    .    .   D=eeeeeeE-----------R.    .    .    .    .   cmp	dword ptr [rsp + 48], 0
[5,1]     .    .    .    .   D=======eE----------R.    .    .    .    .   je	.LBB6_17
[5,2]     .    .    .    .   D======eE-----------R.    .    .    .    .   mov	rdx, rax
[5,3]     .    .    .    .   DeeeeeE-------------R.    .    .    .    .   mov	rax, qword ptr [rsp + 248]
[5,4]     .    .    .    .    D====eeeeeE--------R.    .    .    .    .   mov	rax, qword ptr [rax]
[5,5]     .    .    .    .    D------------------R.    .    .    .    .   xor	ecx, ecx
[5,6]     .    .    .    .    D=eeeeeeE----------R.    .    .    .    .   vmovaps	xmm0, xmmword ptr [rbx + rcx]
[5,7]     .    .    .    .    D=======eeeeE------R.    .    .    .    .   cvtps2dq	xmm0, xmm0
[5,8]     .    .    .    .    D=eeeeeeE----------R.    .    .    .    .   vmovaps	xmm1, xmmword ptr [r15 + rcx]
[5,9]     .    .    .    .    D========eeeeE-----R.    .    .    .    .   cvtps2dq	xmm1, xmm1
[5,10]    .    .    .    .    .D===========eE----R.    .    .    .    .   vpunpckhdq	xmm2, xmm0, xmm1
[5,11]    .    .    .    .    .D============eE---R.    .    .    .    .   vpunpckldq	xmm0, xmm0, xmm1
[5,12]    .    .    .    .    .D=============eeeER.    .    .    .    .   vinserti128	ymm0, ymm0, xmm2, 1
[5,13]    .    .    .    .    . D===============eeeeeER.    .    .    .   vpmovsdw	xmmword ptr [rax + rcx], ymm0
[5,14]    .    .    .    .    . DeE-------------------R.    .    .    .   add	rcx, 16
[5,15]    .    .    .    .    . D====eE---------------R.    .    .    .   add	rdx, -1
[5,16]    .    .    .    .    .  D====eE--------------R.    .    .    .   jne	.LBB6_16
[6,0]     .    .    .    .    .  DeeeeeeE-------------R.    .    .    .   cmp	dword ptr [rsp + 48], 0
[6,1]     .    .    .    .    .  D======eE------------R.    .    .    .   je	.LBB6_17
[6,2]     .    .    .    .    .  D======eE------------R.    .    .    .   mov	rdx, rax
[6,3]     .    .    .    .    .  DeeeeeE--------------R.    .    .    .   mov	rax, qword ptr [rsp + 248]
[6,4]     .    .    .    .    .   D====eeeeeE---------R.    .    .    .   mov	rax, qword ptr [rax]
[6,5]     .    .    .    .    .   D-------------------R.    .    .    .   xor	ecx, ecx
[6,6]     .    .    .    .    .   DeeeeeeE------------R.    .    .    .   vmovaps	xmm0, xmmword ptr [rbx + rcx]
[6,7]     .    .    .    .    .   D======eeeeE--------R.    .    .    .   cvtps2dq	xmm0, xmm0
[6,8]     .    .    .    .    .   D=eeeeeeE-----------R.    .    .    .   vmovaps	xmm1, xmmword ptr [r15 + rcx]
[6,9]     .    .    .    .    .   D=======eeeeE-------R.    .    .    .   cvtps2dq	xmm1, xmm1
[6,10]    .    .    .    .    .    D==========eE------R.    .    .    .   vpunpckhdq	xmm2, xmm0, xmm1
[6,11]    .    .    .    .    .    D==========eE------R.    .    .    .   vpunpckldq	xmm0, xmm0, xmm1
[6,12]    .    .    .    .    .    D===========eeeE---R.    .    .    .   vinserti128	ymm0, ymm0, xmm2, 1
[6,13]    .    .    .    .    .    .D=============eeeeeER   .    .    .   vpmovsdw	xmmword ptr [rax + rcx], ymm0
[6,14]    .    .    .    .    .    .DeE-----------------R   .    .    .   add	rcx, 16
[6,15]    .    .    .    .    .    .D====eE-------------R   .    .    .   add	rdx, -1
[6,16]    .    .    .    .    .    . D====eE------------R   .    .    .   jne	.LBB6_16
[7,0]     .    .    .    .    .    . D=eeeeeeE----------R   .    .    .   cmp	dword ptr [rsp + 48], 0
[7,1]     .    .    .    .    .    . D=======eE---------R   .    .    .   je	.LBB6_17
[7,2]     .    .    .    .    .    . D======eE----------R   .    .    .   mov	rdx, rax
[7,3]     .    .    .    .    .    . DeeeeeE------------R   .    .    .   mov	rax, qword ptr [rsp + 248]
[7,4]     .    .    .    .    .    .  D====eeeeeE-------R   .    .    .   mov	rax, qword ptr [rax]
[7,5]     .    .    .    .    .    .  D-----------------R   .    .    .   xor	ecx, ecx
[7,6]     .    .    .    .    .    .  D=eeeeeeE---------R   .    .    .   vmovaps	xmm0, xmmword ptr [rbx + rcx]
[7,7]     .    .    .    .    .    .  D=======eeeeE-----R   .    .    .   cvtps2dq	xmm0, xmm0
[7,8]     .    .    .    .    .    .  D=eeeeeeE---------R   .    .    .   vmovaps	xmm1, xmmword ptr [r15 + rcx]
[7,9]     .    .    .    .    .    .  D========eeeeE----R   .    .    .   cvtps2dq	xmm1, xmm1
[7,10]    .    .    .    .    .    .   D===========eE---R   .    .    .   vpunpckhdq	xmm2, xmm0, xmm1
[7,11]    .    .    .    .    .    .   D============eE--R   .    .    .   vpunpckldq	xmm0, xmm0, xmm1
[7,12]    .    .    .    .    .    .   D=============eeeER  .    .    .   vinserti128	ymm0, ymm0, xmm2, 1
[7,13]    .    .    .    .    .    .    D===============eeeeeER  .    .   vpmovsdw	xmmword ptr [rax + rcx], ymm0
[7,14]    .    .    .    .    .    .    DeE-------------------R  .    .   add	rcx, 16
[7,15]    .    .    .    .    .    .    D====eE---------------R  .    .   add	rdx, -1
[7,16]    .    .    .    .    .    .    .D====eE--------------R  .    .   jne	.LBB6_16
[8,0]     .    .    .    .    .    .    .DeeeeeeE-------------R  .    .   cmp	dword ptr [rsp + 48], 0
[8,1]     .    .    .    .    .    .    .D======eE------------R  .    .   je	.LBB6_17
[8,2]     .    .    .    .    .    .    .D======eE------------R  .    .   mov	rdx, rax
[8,3]     .    .    .    .    .    .    .DeeeeeE--------------R  .    .   mov	rax, qword ptr [rsp + 248]
[8,4]     .    .    .    .    .    .    . D====eeeeeE---------R  .    .   mov	rax, qword ptr [rax]
[8,5]     .    .    .    .    .    .    . D-------------------R  .    .   xor	ecx, ecx
[8,6]     .    .    .    .    .    .    . DeeeeeeE------------R  .    .   vmovaps	xmm0, xmmword ptr [rbx + rcx]
[8,7]     .    .    .    .    .    .    . D======eeeeE--------R  .    .   cvtps2dq	xmm0, xmm0
[8,8]     .    .    .    .    .    .    . D=eeeeeeE-----------R  .    .   vmovaps	xmm1, xmmword ptr [r15 + rcx]
[8,9]     .    .    .    .    .    .    . D=======eeeeE-------R  .    .   cvtps2dq	xmm1, xmm1
[8,10]    .    .    .    .    .    .    .  D==========eE------R  .    .   vpunpckhdq	xmm2, xmm0, xmm1
[8,11]    .    .    .    .    .    .    .  D==========eE------R  .    .   vpunpckldq	xmm0, xmm0, xmm1
[8,12]    .    .    .    .    .    .    .  D===========eeeE---R  .    .   vinserti128	ymm0, ymm0, xmm2, 1
[8,13]    .    .    .    .    .    .    .   D=============eeeeeER.    .   vpmovsdw	xmmword ptr [rax + rcx], ymm0
[8,14]    .    .    .    .    .    .    .   DeE-----------------R.    .   add	rcx, 16
[8,15]    .    .    .    .    .    .    .   D====eE-------------R.    .   add	rdx, -1
[8,16]    .    .    .    .    .    .    .    D====eE------------R.    .   jne	.LBB6_16
[9,0]     .    .    .    .    .    .    .    D=eeeeeeE----------R.    .   cmp	dword ptr [rsp + 48], 0
[9,1]     .    .    .    .    .    .    .    D=======eE---------R.    .   je	.LBB6_17
[9,2]     .    .    .    .    .    .    .    D======eE----------R.    .   mov	rdx, rax
[9,3]     .    .    .    .    .    .    .    DeeeeeE------------R.    .   mov	rax, qword ptr [rsp + 248]
[9,4]     .    .    .    .    .    .    .    .D====eeeeeE-------R.    .   mov	rax, qword ptr [rax]
[9,5]     .    .    .    .    .    .    .    .D-----------------R.    .   xor	ecx, ecx
[9,6]     .    .    .    .    .    .    .    .D=eeeeeeE---------R.    .   vmovaps	xmm0, xmmword ptr [rbx + rcx]
[9,7]     .    .    .    .    .    .    .    .D=======eeeeE-----R.    .   cvtps2dq	xmm0, xmm0
[9,8]     .    .    .    .    .    .    .    .D=eeeeeeE---------R.    .   vmovaps	xmm1, xmmword ptr [r15 + rcx]
[9,9]     .    .    .    .    .    .    .    .D========eeeeE----R.    .   cvtps2dq	xmm1, xmm1
[9,10]    .    .    .    .    .    .    .    . D===========eE---R.    .   vpunpckhdq	xmm2, xmm0, xmm1
[9,11]    .    .    .    .    .    .    .    . D============eE--R.    .   vpunpckldq	xmm0, xmm0, xmm1
[9,12]    .    .    .    .    .    .    .    . D=============eeeER    .   vinserti128	ymm0, ymm0, xmm2, 1
[9,13]    .    .    .    .    .    .    .    .  D===============eeeeeER   vpmovsdw	xmmword ptr [rax + rcx], ymm0
[9,14]    .    .    .    .    .    .    .    .  DeE-------------------R   add	rcx, 16
[9,15]    .    .    .    .    .    .    .    .  D====eE---------------R   add	rdx, -1
[9,16]    .    .    .    .    .    .    .    .   D====eE--------------R   jne	.LBB6_16


```
</details>

<details><summary>Average Wait times (based on the timeline view):</summary>

```
[0]: Executions
[1]: Average time spent waiting in a scheduler's queue
[2]: Average time spent waiting in a scheduler's queue while ready
[3]: Average time elapsed from WB until retire stage

      [0]    [1]    [2]    [3]
0.     10    1.5    1.5    10.5      cmp	dword ptr [rsp + 48], 0
1.     10    7.5    0.0    9.6       je	.LBB6_17
2.     10    6.5    0.1    10.5      mov	rdx, rax
3.     10    1.0    1.0    12.0      mov	rax, qword ptr [rsp + 248]
4.     10    5.2    0.0    7.3       mov	rax, qword ptr [rax]
5.     10    0.0    0.0    17.4      xor	ecx, ecx
6.     10    1.5    1.5    9.9       vmovaps	xmm0, xmmword ptr [rbx + rcx]
7.     10    7.5    0.0    6.0       cvtps2dq	xmm0, xmm0
8.     10    1.7    1.7    9.7       vmovaps	xmm1, xmmword ptr [r15 + rcx]
9.     10    8.2    0.5    5.2       cvtps2dq	xmm1, xmm1
10.    10    11.4   0.0    4.3       vpunpckhdq	xmm2, xmm0, xmm1
11.    10    11.8   0.5    3.8       vpunpckldq	xmm0, xmm0, xmm1
12.    10    13.2   0.4    0.9       vinserti128	ymm0, ymm0, xmm2, 1
13.    10    15.3   0.0    0.0       vpmovsdw	xmmword ptr [rax + rcx], ymm0
14.    10    1.0    1.0    18.2      add	rcx, 16
15.    10    4.8    0.1    14.4      add	rdx, -1
16.    10    4.9    0.0    13.4      jne	.LBB6_16
       10    6.1    0.5    9.0       <total>


```
</details>

</details>

<details><summary>[3] Code Region - ProcessPixel</summary>

```
Iterations:        100
Instructions:      27200
Total Cycles:      16814
Total uOps:        30800

Dispatch Width:    6
uOps Per Cycle:    1.83
IPC:               1.62
Block RThroughput: 73.5


Cycles with backend pressure increase [ 97.31% ]
Throughput Bottlenecks: 
  Resource Pressure       [ 43.37% ]
  - ICXFPDivider  [ 1.20% ]
  - ICXPort0  [ 30.31% ]
  - ICXPort1  [ 30.89% ]
  - ICXPort2  [ 1.78% ]
  - ICXPort3  [ 1.78% ]
  - ICXPort5  [ 23.79% ]
  - ICXPort6  [ 2.37% ]
  Data Dependencies:      [ 72.36% ]
  - Register Dependencies [ 72.36% ]
  - Memory Dependencies   [ 0.00% ]

```

<details><summary>Critical sequence based on the simulation:</summary>

```

              Instruction                                 Dependency Information
        0.    cmp	r10d, r15d
        1.    jle	.LBB16_20
        2.    vmulps	xmm5, xmm2, xmm2
        3.    vmulss	xmm16, xmm3, xmm3
        4.    vmulss	xmm21, xmm1, xmm1
        5.    vaddss	xmm21, xmm21, xmm5
        6.    vmovss	xmm4, dword ptr [rip + .LCPI16_0]
        7.    vdivss	xmm21, xmm4, xmm21
        8.    vmovshdup	xmm22, xmm2
        9.    vmovshdup	xmm5, xmm5
        10.   vaddss	xmm5, xmm16, xmm5
        11.   vdivss	xmm16, xmm4, xmm5
        12.   add	r14d, -2
        13.   add	r12d, -2
        14.   lea	edx, [r9 + r9]
        15.   lea	ecx, [r15 + 1]
        16.   lea	r8d, [r15 + 2]
        17.   lea	eax, [r15 + 3]
        18.   vmulss	xmm1, xmm1, xmm21
        19.   vmulss	xmm2, xmm2, xmm21
        20.   vmovss	dword ptr [rsp + 76], xmm2
        21.   vmulss	xmm2, xmm22, xmm16
        22.   vmulss	xmm3, xmm3, xmm16
        23.   vmovss	dword ptr [rsp + 72], xmm3
        24.   vbroadcastss	xmm17, xmm17
        25.   vbroadcastss	xmm18, xmm18
        26.   vbroadcastss	xmm19, xmm19
        27.   vbroadcastss	xmm20, xmm20
        28.   vbroadcastss	xmm21, xmm1
        29.   vbroadcastss	xmm22, xmm2
        30.   vpbroadcastd	xmm23, ebx
        31.   vcvtsi2ss	xmm1, xmm0, r14d
        32.   vbroadcastss	xmm24, xmm1
        33.   vcvtsi2ss	xmm1, xmm0, r12d
        34.   vbroadcastss	xmm25, xmm1
        35.   vmovd	xmm1, r15d
        36.   vpinsrd	xmm1, xmm1, ecx, 1
        37.   vpinsrd	xmm1, xmm1, r8d, 2
        38.   vpinsrd	xmm1, xmm1, eax, 3
        39.   vbroadcastss	xmm0, xmm0
        40.   vcvtdq2ps	xmm1, xmm1
        41.   vsubps	xmm0, xmm1, xmm0
        42.   vmovaps	xmmword ptr [rsp + 160], xmm0
        43.   mov	eax, r15d
        44.   lea	rax, [4*rax]
        45.   add	rax, rbp
        46.   imul	r9d, esi
        47.   add	r9, rax
        48.   vpbroadcastq	ymm27, rdi
        49.   jmp	.LBB16_15
        50.   add	r9, rdx
        51.   add	esi, 2
        52.   cmp	esi, r11d
        53.   jge	.LBB16_20
        54.   vcvtsi2ss	xmm0, xmm28, esi
        55.   vsubss	xmm0, xmm0, dword ptr [rsp + 176]
        56.   vmulss	xmm1, xmm0, dword ptr [rsp + 76]
        57.   vbroadcastss	xmm28, xmm1
        58.   vmulss	xmm0, xmm0, dword ptr [rsp + 72]
        59.   vbroadcastss	xmm29, xmm0
        60.   mov	r12d, r15d
        61.   kmovq	k2, k0
        62.   vmovaps	xmm30, xmmword ptr [rsp + 160]
        63.   mov	r14, r9
        64.   jmp	.LBB16_16
        65.   add	r14, 16
        66.   add	r12d, 4
        67.   cmp	r12d, r10d
        68.   jge	.LBB16_19
        69.   vmulps	xmm0, xmm21, xmm30
        70.   vaddps	xmm1, xmm28, xmm0
        71.   vmulps	xmm2, xmm22, xmm30
        72.   vbroadcastss	xmm0, dword ptr [rip + .LCPI16_0]
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
 +----< 83.   vbroadcastss	xmm3, dword ptr [rip + .LCPI16_1]
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
 |      98.   vpextrq	rax, xmm1, 1
 |      99.   vmovq	rbp, xmm1
 |      100.  vextracti128	xmm1, ymm1, 1
 |      101.  vpextrq	r8, xmm1, 1
 |      102.  vmovq	rcx, xmm1
 |      103.  vmovd	xmm1, dword ptr [rbp + 4]
 |      104.  vpinsrd	xmm1, xmm1, dword ptr [rax + 4], 1
 |      105.  vpinsrd	xmm1, xmm1, dword ptr [rcx + 4], 2
 |      106.  vpinsrd	xmm1, xmm1, dword ptr [r8 + 4], 3
 |      107.  vpxor	xmm11, xmm11, xmm11
 |      108.  vmovd	xmm2, dword ptr [rbp + rbx]
 |      109.  vpinsrd	xmm2, xmm2, dword ptr [rax + rbx], 1
 |      110.  vpinsrd	xmm2, xmm2, dword ptr [rcx + rbx], 2
 |      111.  vpinsrd	xmm2, xmm2, dword ptr [r8 + rbx], 3
 |      112.  kxnorw	k3, k0, k0
 |      113.  vmovd	xmm3, dword ptr [rbp + rbx + 4]
 |      114.  vpinsrd	xmm3, xmm3, dword ptr [rax + rbx + 4], 1
 |      115.  vpinsrd	xmm3, xmm3, dword ptr [rcx + rbx + 4], 2
 |      116.  vpinsrd	xmm3, xmm3, dword ptr [r8 + rbx + 4], 3
 +----> 117.  vpgatherdd	xmm11 {k3}, xmmword ptr [rdi + xmm7] ## REGISTER dependency:  xmm7
 |      118.  vpbroadcastw	xmm7, word ptr [rip + .LCPI16_2]
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
 |      197.  vmovdqu64	xmm31, xmmword ptr [r14]
 +----> 198.  vpsrld	xmm2, xmm3, 24                    ## RESOURCE interference:  ICXPort1 [ probability: 100% ]
 +----> 199.  vcvtdq2ps	xmm2, xmm2                        ## REGISTER dependency:  xmm2
 +----> 200.  vmulps	xmm2, xmm12, xmm2                 ## REGISTER dependency:  xmm2
 |      201.  vpandd	xmm3, xmm31, dword ptr [rip + .LCPI16_3]{1to4}
 |      202.  vmulps	xmm4, xmm17, xmm4
 |      203.  vmulps	xmm5, xmm18, xmm8
 |      204.  vmulps	xmm16, xmm19, xmm7
 +----> 205.  vaddps	xmm1, xmm1, xmm2                  ## REGISTER dependency:  xmm2
 |      206.  vmulps	xmm26, xmm20, xmm1
 |      207.  vmaxps	xmm1, xmm4, xmm6
 |      208.  vbroadcastss	xmm2, dword ptr [rip + .LCPI16_6]
 |      209.  vminps	xmm1, xmm1, xmm2
 |      210.  vmaxps	xmm4, xmm5, xmm6
 |      211.  vminps	xmm4, xmm4, xmm2
 |      212.  vmaxps	xmm5, xmm16, xmm6
 |      213.  vminps	xmm5, xmm5, xmm2
 |      214.  vmulps	xmm2, xmm26, dword ptr [rip + .LCPI16_7]{1to4}
 |      215.  vaddps	xmm16, xmm2, xmm0
 |      216.  vpshufb	xmm0, xmm31, xmm10
 |      217.  vcvtdq2ps	xmm0, xmm0
 |      218.  vmulps	xmm0, xmm0, xmm0
 |      219.  vmulps	xmm0, xmm0, xmm16
 |      220.  vaddps	xmm1, xmm0, xmm1
 |      221.  vpshufb	xmm0, xmm31, xmmword ptr [rip + .LCPI16_4]
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
 |      252.  vmovdqa64	xmmword ptr [r14], xmm31
 |      253.  kxnorw	k2, k0, k0
 +----> 254.  vaddps	xmm30, xmm30, dword ptr [rip + .LCPI16_8]{1to4} ## RESOURCE interference:  ICXPort1 [ probability: 99% ]
 |      255.  lea	eax, [r12 + 8]
 |      256.  cmp	eax, r10d
 |      257.  jl	.LBB16_18
 |      258.  kmovq	k2, k1
 |      259.  jmp	.LBB16_18
 |      260.  movsxd	rax, dword ptr [rsp + 64]
 |      261.  imul	rax, rax, 1717986919
 |      262.  mov	rcx, rax
 |      263.  shr	rcx, 63
 |      264.  sar	rax, 33
 |      265.  add	eax, ecx
 |      266.  mov	r8, qword ptr [rsp + 112]
 |      267.  add	r8d, eax
 |      268.  mov	r9, qword ptr [rsp + 104]
 |      269.  neg	r9d
 |      270.  shl	r9, 32
 |      271.  mov	ecx, dword ptr [rsp + 60]
 |
 |    < loop carried > 
 |
 +----> 16.   lea	r8d, [r15 + 2]                    ## RESOURCE interference:  ICXPort1 [ probability: 99% ]


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
 1      1     0.25                        cmp	r10d, r15d
 1      1     0.50                        jle	.LBB16_20
 1      4     0.50                        vmulps	xmm5, xmm2, xmm2
 1      4     0.50                        vmulss	xmm16, xmm3, xmm3
 1      4     0.50                        vmulss	xmm21, xmm1, xmm1
 1      4     0.50                        vaddss	xmm21, xmm21, xmm5
 1      5     0.50    *                   vmovss	xmm4, dword ptr [rip + .LCPI16_0]
 1      11    3.00                        vdivss	xmm21, xmm4, xmm21
 1      1     0.50                        vmovshdup	xmm22, xmm2
 1      1     0.50                        vmovshdup	xmm5, xmm5
 1      4     0.50                        vaddss	xmm5, xmm16, xmm5
 1      11    3.00                        vdivss	xmm16, xmm4, xmm5
 1      1     0.25                        add	r14d, -2
 1      1     0.25                        add	r12d, -2
 1      1     0.50                        lea	edx, [r9 + r9]
 1      1     0.50                        lea	ecx, [r15 + 1]
 1      1     0.50                        lea	r8d, [r15 + 2]
 1      1     0.50                        lea	eax, [r15 + 3]
 1      4     0.50                        vmulss	xmm1, xmm1, xmm21
 1      4     0.50                        vmulss	xmm2, xmm2, xmm21
 2      1     0.50           *            vmovss	dword ptr [rsp + 76], xmm2
 1      4     0.50                        vmulss	xmm2, xmm22, xmm16
 1      4     0.50                        vmulss	xmm3, xmm3, xmm16
 2      1     0.50           *            vmovss	dword ptr [rsp + 72], xmm3
 1      3     1.00                        vbroadcastss	xmm17, xmm17
 1      3     1.00                        vbroadcastss	xmm18, xmm18
 1      3     1.00                        vbroadcastss	xmm19, xmm19
 1      3     1.00                        vbroadcastss	xmm20, xmm20
 1      3     1.00                        vbroadcastss	xmm21, xmm1
 1      3     1.00                        vbroadcastss	xmm22, xmm2
 1      1     1.00                        vpbroadcastd	xmm23, ebx
 2      5     1.00                        vcvtsi2ss	xmm1, xmm0, r14d
 1      3     1.00                        vbroadcastss	xmm24, xmm1
 2      5     1.00                        vcvtsi2ss	xmm1, xmm0, r12d
 1      3     1.00                        vbroadcastss	xmm25, xmm1
 1      1     1.00                        vmovd	xmm1, r15d
 2      2     2.00                        vpinsrd	xmm1, xmm1, ecx, 1
 2      2     2.00                        vpinsrd	xmm1, xmm1, r8d, 2
 2      2     2.00                        vpinsrd	xmm1, xmm1, eax, 3
 1      1     0.50                        vbroadcastss	xmm0, xmm0
 1      4     0.50                        vcvtdq2ps	xmm1, xmm1
 1      4     0.50                        vsubps	xmm0, xmm1, xmm0
 2      1     0.50           *            vmovaps	xmmword ptr [rsp + 160], xmm0
 1      1     0.25                        mov	eax, r15d
 1      1     0.50                        lea	rax, [4*rax]
 1      1     0.25                        add	rax, rbp
 1      3     1.00                        imul	r9d, esi
 1      1     0.25                        add	r9, rax
 1      3     1.00                        vpbroadcastq	ymm27, rdi
 1      1     0.50                        jmp	.LBB16_15
 1      1     0.25                        add	r9, rdx
 1      1     0.25                        add	esi, 2
 1      1     0.25                        cmp	esi, r11d
 1      1     0.50                        jge	.LBB16_20
 2      5     1.00                        vcvtsi2ss	xmm0, xmm28, esi
 2      9     0.50    *                   vsubss	xmm0, xmm0, dword ptr [rsp + 176]
 2      9     0.50    *                   vmulss	xmm1, xmm0, dword ptr [rsp + 76]
 1      3     1.00                        vbroadcastss	xmm28, xmm1
 2      9     0.50    *                   vmulss	xmm0, xmm0, dword ptr [rsp + 72]
 1      3     1.00                        vbroadcastss	xmm29, xmm0
 1      1     0.25                        mov	r12d, r15d
 1      1     1.00                        kmovq	k2, k0
 2      7     0.50    *                   vmovaps	xmm30, xmmword ptr [rsp + 160]
 1      1     0.25                        mov	r14, r9
 1      1     0.50                        jmp	.LBB16_16
 1      1     0.25                        add	r14, 16
 1      1     0.25                        add	r12d, 4
 1      1     0.25                        cmp	r12d, r10d
 1      1     0.50                        jge	.LBB16_19
 1      4     0.50                        vmulps	xmm0, xmm21, xmm30
 1      4     0.50                        vaddps	xmm1, xmm28, xmm0
 1      4     0.50                        vmulps	xmm2, xmm22, xmm30
 1      6     0.50    *                   vbroadcastss	xmm0, dword ptr [rip + .LCPI16_0]
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
 1      6     0.50    *                   vbroadcastss	xmm3, dword ptr [rip + .LCPI16_1]
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
 2      3     1.00                        vpextrq	rax, xmm1, 1
 1      2     1.00                        vmovq	rbp, xmm1
 1      3     1.00                        vextracti128	xmm1, ymm1, 1
 2      3     1.00                        vpextrq	r8, xmm1, 1
 1      2     1.00                        vmovq	rcx, xmm1
 1      5     0.50    *                   vmovd	xmm1, dword ptr [rbp + 4]
 2      6     1.00    *                   vpinsrd	xmm1, xmm1, dword ptr [rax + 4], 1
 2      6     1.00    *                   vpinsrd	xmm1, xmm1, dword ptr [rcx + 4], 2
 2      6     1.00    *                   vpinsrd	xmm1, xmm1, dword ptr [r8 + 4], 3
 1      0     0.17                        vpxor	xmm11, xmm11, xmm11
 1      5     0.50    *                   vmovd	xmm2, dword ptr [rbp + rbx]
 2      6     1.00    *                   vpinsrd	xmm2, xmm2, dword ptr [rax + rbx], 1
 2      6     1.00    *                   vpinsrd	xmm2, xmm2, dword ptr [rcx + rbx], 2
 2      6     1.00    *                   vpinsrd	xmm2, xmm2, dword ptr [r8 + rbx], 3
 1      1     1.00                        kxnorw	k3, k0, k0
 1      5     0.50    *                   vmovd	xmm3, dword ptr [rbp + rbx + 4]
 2      6     1.00    *                   vpinsrd	xmm3, xmm3, dword ptr [rax + rbx + 4], 1
 2      6     1.00    *                   vpinsrd	xmm3, xmm3, dword ptr [rcx + rbx + 4], 2
 2      6     1.00    *                   vpinsrd	xmm3, xmm3, dword ptr [r8 + rbx + 4], 3
 5      19    2.00    *                   vpgatherdd	xmm11 {k3}, xmmword ptr [rdi + xmm7]
 2      7     1.00    *                   vpbroadcastw	xmm7, word ptr [rip + .LCPI16_2]
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
 2      7     0.50    *                   vmovdqu64	xmm31, xmmword ptr [r14]
 1      1     0.50                        vpsrld	xmm2, xmm3, 24
 1      4     0.50                        vcvtdq2ps	xmm2, xmm2
 1      4     0.50                        vmulps	xmm2, xmm12, xmm2
 2      7     0.50    *                   vpandd	xmm3, xmm31, dword ptr [rip + .LCPI16_3]{1to4}
 1      4     0.50                        vmulps	xmm4, xmm17, xmm4
 1      4     0.50                        vmulps	xmm5, xmm18, xmm8
 1      4     0.50                        vmulps	xmm16, xmm19, xmm7
 1      4     0.50                        vaddps	xmm1, xmm1, xmm2
 1      4     0.50                        vmulps	xmm26, xmm20, xmm1
 1      4     0.50                        vmaxps	xmm1, xmm4, xmm6
 1      6     0.50    *                   vbroadcastss	xmm2, dword ptr [rip + .LCPI16_6]
 1      4     0.50                        vminps	xmm1, xmm1, xmm2
 1      4     0.50                        vmaxps	xmm4, xmm5, xmm6
 1      4     0.50                        vminps	xmm4, xmm4, xmm2
 1      4     0.50                        vmaxps	xmm5, xmm16, xmm6
 1      4     0.50                        vminps	xmm5, xmm5, xmm2
 2      10    0.50    *                   vmulps	xmm2, xmm26, dword ptr [rip + .LCPI16_7]{1to4}
 1      4     0.50                        vaddps	xmm16, xmm2, xmm0
 1      1     0.50                        vpshufb	xmm0, xmm31, xmm10
 1      4     0.50                        vcvtdq2ps	xmm0, xmm0
 1      4     0.50                        vmulps	xmm0, xmm0, xmm0
 1      4     0.50                        vmulps	xmm0, xmm0, xmm16
 1      4     0.50                        vaddps	xmm1, xmm0, xmm1
 2      7     0.50    *                   vpshufb	xmm0, xmm31, xmmword ptr [rip + .LCPI16_4]
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
 2      1     0.50           *            vmovdqa64	xmmword ptr [r14], xmm31
 1      1     1.00                        kxnorw	k2, k0, k0
 2      10    0.50    *                   vaddps	xmm30, xmm30, dword ptr [rip + .LCPI16_8]{1to4}
 1      1     0.50                        lea	eax, [r12 + 8]
 1      1     0.25                        cmp	eax, r10d
 1      1     0.50                        jl	.LBB16_18
 1      1     1.00                        kmovq	k2, k1
 1      1     0.50                        jmp	.LBB16_18
 1      5     0.50    *                   movsxd	rax, dword ptr [rsp + 64]
 1      3     1.00                        imul	rax, rax, 1717986919
 1      1     0.25                        mov	rcx, rax
 1      1     0.50                        shr	rcx, 63
 1      1     0.50                        sar	rax, 33
 1      1     0.25                        add	eax, ecx
 1      5     0.50    *                   mov	r8, qword ptr [rsp + 112]
 1      1     0.25                        add	r8d, eax
 1      5     0.50    *                   mov	r9, qword ptr [rsp + 104]
 1      1     0.25                        neg	r9d
 1      1     0.50                        shl	r9, 32
 1      5     0.50    *                   mov	ecx, dword ptr [rsp + 60]


```
</details>

<details><summary>Dynamic Dispatch Stall Cycles:</summary>

```
RAT     - Register unavailable:                      0
RCU     - Retire tokens unavailable:                 0
SCHEDQ  - Scheduler full:                            16536  (98.3%)
LQ      - Load queue full:                           0
SQ      - Store queue full:                          0
GROUP   - Static restrictions on the dispatch group: 0
USH     - Uncategorised Structural Hazard:           0


```
</details>

<details><summary>Dispatch Logic - number of cycles where we saw N micro opcodes dispatched:</summary>

```
[# dispatched], [# cycles]
 0,              3942  (23.4%)
 1,              3192  (19.0%)
 2,              3987  (23.7%)
 3,              3485  (20.7%)
 4,              1884  (11.2%)
 5,              301  (1.8%)
 6,              23  (0.1%)


```
</details>

<details><summary>Schedulers - number of cycles where we saw N micro opcodes issued:</summary>

```
[# issued], [# cycles]
 0,          4008  (23.8%)
 1,          2807  (16.7%)
 2,          4703  (28.0%)
 3,          3295  (19.6%)
 4,          1503  (8.9%)
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
 0,           9907  (58.9%)
 1,           3204  (19.1%)
 2,           802  (4.8%)
 3,           599  (3.6%)
 4,           1000  (5.9%)
 6,           100  (0.6%)
 7,           300  (1.8%)
 8,           200  (1.2%)
 9,           200  (1.2%)
 11,          201  (1.2%)
 13,          2  (0.0%)
 20,          1  (0.0%)
 21,          100  (0.6%)
 22,          99  (0.6%)
 40,          99  (0.6%)

```
</details>

<details><summary>Total ROB Entries:                352</summary>

```
Max Used ROB Entries:             172  ( 48.9% )
Average Used ROB Entries per cy:  114  ( 32.4% )


```
</details>

<details><summary>Register File statistics:</summary>

```
Total number of mappings created:    27700
Max number of mappings used:         150


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
 -     6.00   90.99  85.06  17.00  17.00  2.00   72.96  17.99  2.00   2.00   2.00   

Resource pressure by instruction:
[0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   Instructions:
 -      -      -      -      -      -      -     0.99   0.01    -      -      -     cmp	r10d, r15d
 -      -      -      -      -      -      -      -     1.00    -      -      -     jle	.LBB16_20
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm5, xmm2, xmm2
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulss	xmm16, xmm3, xmm3
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulss	xmm21, xmm1, xmm1
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddss	xmm21, xmm21, xmm5
 -      -      -      -     0.50   0.50    -      -      -      -      -      -     vmovss	xmm4, dword ptr [rip + .LCPI16_0]
 -     3.00   1.00    -      -      -      -      -      -      -      -      -     vdivss	xmm21, xmm4, xmm21
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovshdup	xmm22, xmm2
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     vmovshdup	xmm5, xmm5
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vaddss	xmm5, xmm16, xmm5
 -     3.00   1.00    -      -      -      -      -      -      -      -      -     vdivss	xmm16, xmm4, xmm5
 -      -      -      -      -      -      -     0.01   0.99    -      -      -     add	r14d, -2
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     add	r12d, -2
 -      -      -      -      -      -      -     1.00    -      -      -      -     lea	edx, [r9 + r9]
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     lea	ecx, [r15 + 1]
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     lea	r8d, [r15 + 2]
 -      -      -      -      -      -      -     1.00    -      -      -      -     lea	eax, [r15 + 3]
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulss	xmm1, xmm1, xmm21
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmulss	xmm2, xmm2, xmm21
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   vmovss	dword ptr [rsp + 76], xmm2
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulss	xmm2, xmm22, xmm16
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulss	xmm3, xmm3, xmm16
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     vmovss	dword ptr [rsp + 72], xmm3
 -      -      -      -      -      -      -     1.00    -      -      -      -     vbroadcastss	xmm17, xmm17
 -      -      -      -      -      -      -     1.00    -      -      -      -     vbroadcastss	xmm18, xmm18
 -      -      -      -      -      -      -     1.00    -      -      -      -     vbroadcastss	xmm19, xmm19
 -      -      -      -      -      -      -     1.00    -      -      -      -     vbroadcastss	xmm20, xmm20
 -      -      -      -      -      -      -     1.00    -      -      -      -     vbroadcastss	xmm21, xmm1
 -      -      -      -      -      -      -     1.00    -      -      -      -     vbroadcastss	xmm22, xmm2
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpbroadcastd	xmm23, ebx
 -      -     1.00    -      -      -      -     1.00    -      -      -      -     vcvtsi2ss	xmm1, xmm0, r14d
 -      -      -      -      -      -      -     1.00    -      -      -      -     vbroadcastss	xmm24, xmm1
 -      -     0.99   0.01    -      -      -     1.00    -      -      -      -     vcvtsi2ss	xmm1, xmm0, r12d
 -      -      -      -      -      -      -     1.00    -      -      -      -     vbroadcastss	xmm25, xmm1
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovd	xmm1, r15d
 -      -      -      -      -      -      -     2.00    -      -      -      -     vpinsrd	xmm1, xmm1, ecx, 1
 -      -      -      -      -      -      -     2.00    -      -      -      -     vpinsrd	xmm1, xmm1, r8d, 2
 -      -      -      -      -      -      -     2.00    -      -      -      -     vpinsrd	xmm1, xmm1, eax, 3
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     vbroadcastss	xmm0, xmm0
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm1, xmm1
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vsubps	xmm0, xmm1, xmm0
 -      -      -      -      -      -      -      -      -      -     1.00   1.00   vmovaps	xmmword ptr [rsp + 160], xmm0
 -      -      -      -      -      -      -      -     1.00    -      -      -     mov	eax, r15d
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	rax, [4*rax]
 -      -     1.00    -      -      -      -      -      -      -      -      -     add	rax, rbp
 -      -      -     1.00    -      -      -      -      -      -      -      -     imul	r9d, esi
 -      -      -     1.00    -      -      -      -      -      -      -      -     add	r9, rax
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpbroadcastq	ymm27, rdi
 -      -      -      -      -      -      -      -     1.00    -      -      -     jmp	.LBB16_15
 -      -      -     1.00    -      -      -      -      -      -      -      -     add	r9, rdx
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     add	esi, 2
 -      -      -      -      -      -      -      -     1.00    -      -      -     cmp	esi, r11d
 -      -      -      -      -      -      -      -     1.00    -      -      -     jge	.LBB16_20
 -      -     0.99   0.01    -      -      -     1.00    -      -      -      -     vcvtsi2ss	xmm0, xmm28, esi
 -      -     0.01   0.99   0.49   0.51    -      -      -      -      -      -     vsubss	xmm0, xmm0, dword ptr [rsp + 176]
 -      -      -     1.00   0.50   0.50    -      -      -      -      -      -     vmulss	xmm1, xmm0, dword ptr [rsp + 76]
 -      -      -      -      -      -      -     1.00    -      -      -      -     vbroadcastss	xmm28, xmm1
 -      -     1.00    -     0.50   0.50    -      -      -      -      -      -     vmulss	xmm0, xmm0, dword ptr [rsp + 72]
 -      -      -      -      -      -      -     1.00    -      -      -      -     vbroadcastss	xmm29, xmm0
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     mov	r12d, r15d
 -      -     1.00    -      -      -      -      -      -      -      -      -     kmovq	k2, k0
 -      -     0.01    -     0.50   0.50    -     0.99    -      -      -      -     vmovaps	xmm30, xmmword ptr [rsp + 160]
 -      -      -     0.01    -      -      -      -     0.99    -      -      -     mov	r14, r9
 -      -      -      -      -      -      -      -     1.00    -      -      -     jmp	.LBB16_16
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     add	r14, 16
 -      -      -      -      -      -      -      -     1.00    -      -      -     add	r12d, 4
 -      -      -      -      -      -      -     0.99   0.01    -      -      -     cmp	r12d, r10d
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     jge	.LBB16_19
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm21, xmm30
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vaddps	xmm1, xmm28, xmm0
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmulps	xmm2, xmm22, xmm30
 -      -      -      -     0.50   0.50    -      -      -      -      -      -     vbroadcastss	xmm0, dword ptr [rip + .LCPI16_0]
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
 -      -      -      -     0.51   0.49    -      -      -      -      -      -     vbroadcastss	xmm3, dword ptr [rip + .LCPI16_1]
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
 -      -     1.00    -      -      -      -     1.00    -      -      -      -     vpextrq	rax, xmm1, 1
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmovq	rbp, xmm1
 -      -      -      -      -      -      -     1.00    -      -      -      -     vextracti128	xmm1, ymm1, 1
 -      -     1.00    -      -      -      -     1.00    -      -      -      -     vpextrq	r8, xmm1, 1
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmovq	rcx, xmm1
 -      -      -      -     0.50   0.50    -      -      -      -      -      -     vmovd	xmm1, dword ptr [rbp + 4]
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpinsrd	xmm1, xmm1, dword ptr [rax + 4], 1
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpinsrd	xmm1, xmm1, dword ptr [rcx + 4], 2
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpinsrd	xmm1, xmm1, dword ptr [r8 + 4], 3
 -      -      -      -      -      -      -      -      -      -      -      -     vpxor	xmm11, xmm11, xmm11
 -      -      -      -     0.50   0.50    -      -      -      -      -      -     vmovd	xmm2, dword ptr [rbp + rbx]
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpinsrd	xmm2, xmm2, dword ptr [rax + rbx], 1
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpinsrd	xmm2, xmm2, dword ptr [rcx + rbx], 2
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpinsrd	xmm2, xmm2, dword ptr [r8 + rbx], 3
 -      -     1.00    -      -      -      -      -      -      -      -      -     kxnorw	k3, k0, k0
 -      -      -      -     0.50   0.50    -      -      -      -      -      -     vmovd	xmm3, dword ptr [rbp + rbx + 4]
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpinsrd	xmm3, xmm3, dword ptr [rax + rbx + 4], 1
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpinsrd	xmm3, xmm3, dword ptr [rcx + rbx + 4], 2
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpinsrd	xmm3, xmm3, dword ptr [r8 + rbx + 4], 3
 -      -     1.00   1.00   2.00   2.00    -      -     1.00    -      -      -     vpgatherdd	xmm11 {k3}, xmmword ptr [rdi + xmm7]
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpbroadcastw	xmm7, word ptr [rip + .LCPI16_2]
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
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vmovdqu64	xmm31, xmmword ptr [r14]
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpsrld	xmm2, xmm3, 24
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm2, xmm2
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm2, xmm12, xmm2
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpandd	xmm3, xmm31, dword ptr [rip + .LCPI16_3]{1to4}
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm4, xmm17, xmm4
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm5, xmm18, xmm8
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm16, xmm19, xmm7
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm1, xmm1, xmm2
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm26, xmm20, xmm1
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmaxps	xmm1, xmm4, xmm6
 -      -      -      -     0.50   0.50    -      -      -      -      -      -     vbroadcastss	xmm2, dword ptr [rip + .LCPI16_6]
 -      -      -     1.00    -      -      -      -      -      -      -      -     vminps	xmm1, xmm1, xmm2
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmaxps	xmm4, xmm5, xmm6
 -      -     1.00    -      -      -      -      -      -      -      -      -     vminps	xmm4, xmm4, xmm2
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmaxps	xmm5, xmm16, xmm6
 -      -     1.00    -      -      -      -      -      -      -      -      -     vminps	xmm5, xmm5, xmm2
 -      -      -     1.00   0.51   0.49    -      -      -      -      -      -     vmulps	xmm2, xmm26, dword ptr [rip + .LCPI16_7]{1to4}
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm16, xmm2, xmm0
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpshufb	xmm0, xmm31, xmm10
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm0, xmm0
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm0, xmm0, xmm0
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm0, xmm16
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm1, xmm0, xmm1
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpshufb	xmm0, xmm31, xmmword ptr [rip + .LCPI16_4]
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm0, xmm0
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm0, xmm0
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm0, xmm0, xmm16
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm2, xmm0, xmm4
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm0, xmm3
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm0, xmm0
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm0, xmm16
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm3, xmm0, xmm5
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
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm0, xmm16, xmm0
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm0, xmm26, xmm0
 -      -      -     1.00    -      -      -      -      -      -      -      -     cvtps2dq	xmm0, xmm0
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpslld	xmm0, xmm0, 24
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpord	xmm31 {k2}, xmm2, xmm0
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     vmovdqa64	xmmword ptr [r14], xmm31
 -      -     1.00    -      -      -      -      -      -      -      -      -     kxnorw	k2, k0, k0
 -      -      -     1.00   0.49   0.51    -      -      -      -      -      -     vaddps	xmm30, xmm30, dword ptr [rip + .LCPI16_8]{1to4}
 -      -      -      -      -      -      -     1.00    -      -      -      -     lea	eax, [r12 + 8]
 -      -      -      -      -      -      -      -     1.00    -      -      -     cmp	eax, r10d
 -      -      -      -      -      -      -      -     1.00    -      -      -     jl	.LBB16_18
 -      -     1.00    -      -      -      -      -      -      -      -      -     kmovq	k2, k1
 -      -      -      -      -      -      -      -     1.00    -      -      -     jmp	.LBB16_18
 -      -      -      -     0.50   0.50    -      -      -      -      -      -     movsxd	rax, dword ptr [rsp + 64]
 -      -      -     1.00    -      -      -      -      -      -      -      -     imul	rax, rax, 1717986919
 -      -      -      -      -      -      -     0.01   0.99    -      -      -     mov	rcx, rax
 -      -      -      -      -      -      -      -     1.00    -      -      -     shr	rcx, 63
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     sar	rax, 33
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     add	eax, ecx
 -      -      -      -     0.50   0.50    -      -      -      -      -      -     mov	r8, qword ptr [rsp + 112]
 -      -      -     1.00    -      -      -      -      -      -      -      -     add	r8d, eax
 -      -      -      -     0.50   0.50    -      -      -      -      -      -     mov	r9, qword ptr [rsp + 104]
 -      -      -      -      -      -      -     1.00    -      -      -      -     neg	r9d
 -      -      -      -      -      -      -      -     1.00    -      -      -     shl	r9, 32
 -      -      -      -     0.50   0.50    -      -      -      -      -      -     mov	ecx, dword ptr [rsp + 60]


```
</details>

<details><summary>Timeline view:</summary>

```
                    0123456789          0123456789          0123456789          0123456789
Index     0123456789          0123456789          0123456789          0123456789          

[0,0]     DeER .    .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   cmp	r10d, r15d
[0,1]     D=eER.    .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   jle	.LBB16_20
[0,2]     DeeeeER   .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   vmulps	xmm5, xmm2, xmm2
[0,3]     DeeeeER   .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   vmulss	xmm16, xmm3, xmm3
[0,4]     D=eeeeER  .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   vmulss	xmm21, xmm1, xmm1
[0,5]     D=====eeeeER   .    .    .    .    .    .    .    .    .    .    .    .    .   .   vaddss	xmm21, xmm21, xmm5
[0,6]     .DeeeeeE---R   .    .    .    .    .    .    .    .    .    .    .    .    .   .   vmovss	xmm4, dword ptr [rip + .LCPI16_0]
[0,7]     .D========eeeeeeeeeeeER  .    .    .    .    .    .    .    .    .    .    .   .   vdivss	xmm21, xmm4, xmm21
[0,8]     .DeE------------------R  .    .    .    .    .    .    .    .    .    .    .   .   vmovshdup	xmm22, xmm2
[0,9]     .D===eE---------------R  .    .    .    .    .    .    .    .    .    .    .   .   vmovshdup	xmm5, xmm5
[0,10]    .D====eeeeE-----------R  .    .    .    .    .    .    .    .    .    .    .   .   vaddss	xmm5, xmm16, xmm5
[0,11]    .D===========eeeeeeeeeeeER    .    .    .    .    .    .    .    .    .    .   .   vdivss	xmm16, xmm4, xmm5
[0,12]    . DeE--------------------R    .    .    .    .    .    .    .    .    .    .   .   add	r14d, -2
[0,13]    . DeE--------------------R    .    .    .    .    .    .    .    .    .    .   .   add	r12d, -2
[0,14]    . D=eE-------------------R    .    .    .    .    .    .    .    .    .    .   .   lea	edx, [r9 + r9]
[0,15]    . D=eE-------------------R    .    .    .    .    .    .    .    .    .    .   .   lea	ecx, [r15 + 1]
[0,16]    . D==eE------------------R    .    .    .    .    .    .    .    .    .    .   .   lea	r8d, [r15 + 2]
[0,17]    . D===eE-----------------R    .    .    .    .    .    .    .    .    .    .   .   lea	eax, [r15 + 3]
[0,18]    .  D=================eeeeER   .    .    .    .    .    .    .    .    .    .   .   vmulss	xmm1, xmm1, xmm21
[0,19]    .  D=================eeeeER   .    .    .    .    .    .    .    .    .    .   .   vmulss	xmm2, xmm2, xmm21
[0,20]    .  D=====================eER  .    .    .    .    .    .    .    .    .    .   .   vmovss	dword ptr [rsp + 76], xmm2
[0,21]    .  D====================eeeeER.    .    .    .    .    .    .    .    .    .   .   vmulss	xmm2, xmm22, xmm16
[0,22]    .  D====================eeeeER.    .    .    .    .    .    .    .    .    .   .   vmulss	xmm3, xmm3, xmm16
[0,23]    .   D=======================eER    .    .    .    .    .    .    .    .    .   .   vmovss	dword ptr [rsp + 72], xmm3
[0,24]    .   D==eeeE-------------------R    .    .    .    .    .    .    .    .    .   .   vbroadcastss	xmm17, xmm17
[0,25]    .   D===eeeE------------------R    .    .    .    .    .    .    .    .    .   .   vbroadcastss	xmm18, xmm18
[0,26]    .   D====eeeE-----------------R    .    .    .    .    .    .    .    .    .   .   vbroadcastss	xmm19, xmm19
[0,27]    .   D=====eeeE----------------R    .    .    .    .    .    .    .    .    .   .   vbroadcastss	xmm20, xmm20
[0,28]    .    D===================eeeE-R    .    .    .    .    .    .    .    .    .   .   vbroadcastss	xmm21, xmm1
[0,29]    .    D======================eeeER  .    .    .    .    .    .    .    .    .   .   vbroadcastss	xmm22, xmm2
[0,30]    .    D=====eE-------------------R  .    .    .    .    .    .    .    .    .   .   vpbroadcastd	xmm23, ebx
[0,31]    .    D======eeeeeE--------------R  .    .    .    .    .    .    .    .    .   .   vcvtsi2ss	xmm1, xmm0, r14d
[0,32]    .    D===========eeeE-----------R  .    .    .    .    .    .    .    .    .   .   vbroadcastss	xmm24, xmm1
[0,33]    .    .D======eeeeeE-------------R  .    .    .    .    .    .    .    .    .   .   vcvtsi2ss	xmm1, xmm0, r12d
[0,34]    .    .D===========eeeE----------R  .    .    .    .    .    .    .    .    .   .   vbroadcastss	xmm25, xmm1
[0,35]    .    .D=======eE----------------R  .    .    .    .    .    .    .    .    .   .   vmovd	xmm1, r15d
[0,36]    .    .D========eeE--------------R  .    .    .    .    .    .    .    .    .   .   vpinsrd	xmm1, xmm1, ecx, 1
[0,37]    .    . D===========eeE----------R  .    .    .    .    .    .    .    .    .   .   vpinsrd	xmm1, xmm1, r8d, 2
[0,38]    .    . D=============eeE--------R  .    .    .    .    .    .    .    .    .   .   vpinsrd	xmm1, xmm1, eax, 3
[0,39]    .    . DeE----------------------R  .    .    .    .    .    .    .    .    .   .   vbroadcastss	xmm0, xmm0
[0,40]    .    . D===============eeeeE----R  .    .    .    .    .    .    .    .    .   .   vcvtdq2ps	xmm1, xmm1
[0,41]    .    .  D==================eeeeER  .    .    .    .    .    .    .    .    .   .   vsubps	xmm0, xmm1, xmm0
[0,42]    .    .  D======================eER .    .    .    .    .    .    .    .    .   .   vmovaps	xmmword ptr [rsp + 160], xmm0
[0,43]    .    .  DeE----------------------R .    .    .    .    .    .    .    .    .   .   mov	eax, r15d
[0,44]    .    .  D=eE---------------------R .    .    .    .    .    .    .    .    .   .   lea	rax, [4*rax]
[0,45]    .    .  D==eE--------------------R .    .    .    .    .    .    .    .    .   .   add	rax, rbp
[0,46]    .    .   D=eeeE------------------R .    .    .    .    .    .    .    .    .   .   imul	r9d, esi
[0,47]    .    .   D====eE-----------------R .    .    .    .    .    .    .    .    .   .   add	r9, rax
[0,48]    .    .   D=============eeeE------R .    .    .    .    .    .    .    .    .   .   vpbroadcastq	ymm27, rdi
[0,49]    .    .   DeE---------------------R .    .    .    .    .    .    .    .    .   .   jmp	.LBB16_15
[0,50]    .    .   D=====eE----------------R .    .    .    .    .    .    .    .    .   .   add	r9, rdx
[0,51]    .    .   D=eE--------------------R .    .    .    .    .    .    .    .    .   .   add	esi, 2
[0,52]    .    .    D=eE-------------------R .    .    .    .    .    .    .    .    .   .   cmp	esi, r11d
[0,53]    .    .    D==eE------------------R .    .    .    .    .    .    .    .    .   .   jge	.LBB16_20
[0,54]    .    .    D===============eeeeeE-R .    .    .    .    .    .    .    .    .   .   vcvtsi2ss	xmm0, xmm28, esi
[0,55]    .    .    D===============eeeeeeeeeER   .    .    .    .    .    .    .    .   .   vsubss	xmm0, xmm0, dword ptr [rsp + 176]
[0,56]    .    .    .D==================eeeeeeeeeER    .    .    .    .    .    .    .   .   vmulss	xmm1, xmm0, dword ptr [rsp + 76]
[0,57]    .    .    .D===========================eeeER .    .    .    .    .    .    .   .   vbroadcastss	xmm28, xmm1
[0,58]    .    .    .D==================eeeeeeeeeE---R .    .    .    .    .    .    .   .   vmulss	xmm0, xmm0, dword ptr [rsp + 72]
[0,59]    .    .    .D============================eeeER.    .    .    .    .    .    .   .   vbroadcastss	xmm29, xmm0
[0,60]    .    .    . D=eE----------------------------R.    .    .    .    .    .    .   .   mov	r12d, r15d
[0,61]    .    .    . D==eE---------------------------R.    .    .    .    .    .    .   .   kmovq	k2, k0
[0,62]    .    .    . D===eeeeeeeE--------------------R.    .    .    .    .    .    .   .   vmovaps	xmm30, xmmword ptr [rsp + 160]
[0,63]    .    .    . D===eE--------------------------R.    .    .    .    .    .    .   .   mov	r14, r9
[0,64]    .    .    . D=eE----------------------------R.    .    .    .    .    .    .   .   jmp	.LBB16_16
[0,65]    .    .    .  D===eE-------------------------R.    .    .    .    .    .    .   .   add	r14, 16
[0,66]    .    .    .  D=eE---------------------------R.    .    .    .    .    .    .   .   add	r12d, 4
[0,67]    .    .    .  D==eE--------------------------R.    .    .    .    .    .    .   .   cmp	r12d, r10d
[0,68]    .    .    .  D===eE-------------------------R.    .    .    .    .    .    .   .   jge	.LBB16_19
[0,69]    .    .    .  D==============eeeeE-----------R.    .    .    .    .    .    .   .   vmulps	xmm0, xmm21, xmm30
[0,70]    .    .    .  D============================eeeeER  .    .    .    .    .    .   .   vaddps	xmm1, xmm28, xmm0
[0,71]    .    .    .   D================eeeeE-----------R  .    .    .    .    .    .   .   vmulps	xmm2, xmm22, xmm30
[0,72]    .    .    .   DeeeeeeE-------------------------R  .    .    .    .    .    .   .   vbroadcastss	xmm0, dword ptr [rip + .LCPI16_0]
[0,73]    .    .    .   D============================eeeeER .    .    .    .    .    .   .   vaddps	xmm2, xmm29, xmm2
[0,74]    .    .    .   D===============================eeeeER   .    .    .    .    .   .   vcmpleps	k2 {k2}, xmm1, xmm0
[0,75]    .    .    .   D===================================eeeeER    .    .    .    .   .   vcmpleps	k2 {k2}, xmm6, xmm1
[0,76]    .    .    .   D=======================================eeeeER.    .    .    .   .   vcmpleps	k2 {k2}, xmm6, xmm2
[0,77]    .    .    .    D==========================================eeeeER .    .    .   .   vcmpleps	k2 {k2}, xmm2, xmm0
[0,78]    .    .    .    D==============================eeeeE------------R .    .    .   .   vmaxps	xmm1, xmm1, xmm6
[0,79]    .    .    .    D==================================eeeeE--------R .    .    .   .   vminps	xmm1, xmm1, xmm0
[0,80]    .    .    .    D======================================eeeeE----R .    .    .   .   vmulps	xmm1, xmm24, xmm1
[0,81]    .    .    .    D===============================eeeeE-----------R .    .    .   .   vmaxps	xmm2, xmm2, xmm6
[0,82]    .    .    .    D===================================eeeeE-------R .    .    .   .   vminps	xmm2, xmm2, xmm0
[0,83]    .    .    .    .DeeeeeeE---------------------------------------R .    .    .   .   vbroadcastss	xmm3, dword ptr [rip + .LCPI16_1]
[0,84]    .    .    .    .D======================================eeeeE---R .    .    .   .   vmulps	xmm2, xmm25, xmm2
[0,85]    .    .    .    .D=========================================eeeeER .    .    .   .   vaddps	xmm1, xmm1, xmm3
[0,86]    .    .    .    .D==========================================eeeeER.    .    .   .   vaddps	xmm2, xmm2, xmm3
[0,87]    .    .    .    .D=============================================eeeeER  .    .   .   vcvttps2dq	xmm3, xmm1
[0,88]    .    .    .    .D=================================================eeeeER   .   .   vcvtdq2ps	xmm31, xmm3
[0,89]    .    .    .    . D====================================================eeeeER   .   vsubps	xmm31, xmm1, xmm31
[0,90]    .    .    .    . D=============================================eeeeE-------R   .   vcvttps2dq	xmm1, xmm2
[0,91]    .    .    .    . D=================================================eeeeE---R   .   vcvtdq2ps	xmm7, xmm1
[0,92]    .    .    .    . D=====================================================eeeeER  .   vsubps	xmm12, xmm2, xmm7
[0,93]    .    .    .    . D================================================eE--------R  .   vpslld	xmm2, xmm3, 2
[0,94]    .    .    .    .  D================================================eeeeeeeeeeER.   vpmulld	xmm1, xmm23, xmm1
[0,95]    .    .    .    .  D==========================================================eER   vpaddd	xmm7, xmm2, xmm1
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
0.     10    1.0    1.0    45.0      cmp	r10d, r15d
1.     10    1.1    0.0    44.1      jle	.LBB16_20
2.     10    44.2   0.1    0.0       vmulps	xmm5, xmm2, xmm2
3.     10    31.6   1.0    12.6      vmulss	xmm16, xmm3, xmm3
4.     10    42.5   0.2    1.8       vmulss	xmm21, xmm1, xmm1
5.     10    47.4   0.0    0.0       vaddss	xmm21, xmm21, xmm5
6.     10    1.0    1.0    45.3      vmovss	xmm4, dword ptr [rip + .LCPI16_0]
7.     10    51.3   0.0    0.0       vdivss	xmm21, xmm4, xmm21
8.     10    43.3   1.0    17.1      vmovshdup	xmm22, xmm2
9.     10    46.3   0.0    14.1      vmovshdup	xmm5, xmm5
10.    10    47.3   0.0    10.1      vaddss	xmm5, xmm16, xmm5
11.    10    52.5   2.1    0.0       vdivss	xmm16, xmm4, xmm5
12.    10    1.0    1.0    61.4      add	r14d, -2
13.    10    1.0    1.0    60.5      add	r12d, -2
14.    10    2.0    0.2    59.5      lea	edx, [r9 + r9]
15.    10    2.9    2.9    58.6      lea	ecx, [r15 + 1]
16.    10    3.9    3.9    57.6      lea	r8d, [r15 + 2]
17.    10    4.0    4.0    56.6      lea	eax, [r15 + 3]
18.    10    58.5   0.0    0.0       vmulss	xmm1, xmm1, xmm21
19.    10    58.5   0.0    0.0       vmulss	xmm2, xmm2, xmm21
20.    10    62.5   0.0    0.0       vmovss	dword ptr [rsp + 76], xmm2
21.    10    60.6   0.0    0.0       vmulss	xmm2, xmm22, xmm16
22.    10    60.6   0.0    0.0       vmulss	xmm3, xmm3, xmm16
23.    10    64.5   0.0    0.0       vmovss	dword ptr [rsp + 72], xmm3
24.    10    3.0    3.0    58.6      vbroadcastss	xmm17, xmm17
25.    10    4.0    4.0    57.6      vbroadcastss	xmm18, xmm18
26.    10    5.0    5.0    56.6      vbroadcastss	xmm19, xmm19
27.    10    5.1    5.1    55.6      vbroadcastss	xmm20, xmm20
28.    10    59.6   0.0    1.0       vbroadcastss	xmm21, xmm1
29.    10    62.6   0.0    0.0       vbroadcastss	xmm22, xmm2
30.    10    5.1    5.1    58.6      vpbroadcastd	xmm23, ebx
31.    10    27.7   0.7    32.0      vcvtsi2ss	xmm1, xmm0, r14d
32.    10    31.8   0.0    29.0      vbroadcastss	xmm24, xmm1
33.    10    27.7   1.6    31.0      vcvtsi2ss	xmm1, xmm0, r12d
34.    10    31.8   0.0    28.0      vbroadcastss	xmm25, xmm1
35.    10    4.4    4.4    57.4      vmovd	xmm1, r15d
36.    10    5.4    0.0    55.4      vpinsrd	xmm1, xmm1, ecx, 1
37.    10    6.6    0.2    53.2      vpinsrd	xmm1, xmm1, r8d, 2
38.    10    7.7    0.0    51.2      vpinsrd	xmm1, xmm1, eax, 3
39.    10    25.3   1.9    34.6      vbroadcastss	xmm0, xmm0
40.    10    9.7    0.0    47.2      vcvtdq2ps	xmm1, xmm1
41.    10    27.1   0.0    28.8      vsubps	xmm0, xmm1, xmm0
42.    10    57.2   0.0    1.8       vmovaps	xmmword ptr [rsp + 160], xmm0
43.    10    1.0    1.0    58.0      mov	eax, r15d
44.    10    2.0    0.9    56.1      lea	rax, [4*rax]
45.    10    3.0    0.0    55.1      add	rax, rbp
46.    10    2.9    2.9    53.1      imul	r9d, esi
47.    10    5.0    0.0    52.1      add	r9, rax
48.    10    6.8    6.8    48.3      vpbroadcastq	ymm27, rdi
49.    10    1.0    1.0    55.2      jmp	.LBB16_15
50.    10    4.2    0.0    51.1      add	r9, rdx
51.    10    1.1    1.1    54.2      add	esi, 2
52.    10    2.0    0.0    53.2      cmp	esi, r11d
53.    10    3.0    0.0    52.2      jge	.LBB16_20
54.    10    5.2    4.1    45.1      vcvtsi2ss	xmm0, xmm28, esi
55.    10    4.3    0.0    41.4      vsubss	xmm0, xmm0, dword ptr [rsp + 176]
56.    10    8.2    0.0    37.8      vmulss	xmm1, xmm0, dword ptr [rsp + 76]
57.    10    16.3   0.0    35.1      vbroadcastss	xmm28, xmm1
58.    10    7.3    0.0    38.1      vmulss	xmm0, xmm0, dword ptr [rsp + 72]
59.    10    17.3   1.0    34.2      vbroadcastss	xmm29, xmm0
60.    10    1.1    1.1    51.4      mov	r12d, r15d
61.    10    2.1    2.1    50.4      kmovq	k2, k0
62.    10    2.2    2.2    44.3      vmovaps	xmm30, xmmword ptr [rsp + 160]
63.    10    1.3    0.9    50.3      mov	r14, r9
64.    10    2.0    2.0    49.6      jmp	.LBB16_16
65.    10    2.2    0.0    49.3      add	r14, 16
66.    10    2.0    1.8    48.6      add	r12d, 4
67.    10    3.0    0.0    47.6      cmp	r12d, r10d
68.    10    4.0    0.0    46.6      jge	.LBB16_19
69.    10    46.5   0.0    1.1       vmulps	xmm0, xmm21, xmm30
70.    10    51.5   0.0    0.0       vaddps	xmm1, xmm28, xmm0
71.    10    49.4   0.0    2.0       vmulps	xmm2, xmm22, xmm30
72.    10    1.0    1.0    48.4      vbroadcastss	xmm0, dword ptr [rip + .LCPI16_0]
73.    10    53.3   0.0    0.0       vaddps	xmm2, xmm29, xmm2
74.    10    54.5   0.0    0.0       vcmpleps	k2 {k2}, xmm1, xmm0
75.    10    58.5   0.0    0.0       vcmpleps	k2 {k2}, xmm6, xmm1
76.    10    62.5   0.0    0.0       vcmpleps	k2 {k2}, xmm6, xmm2
77.    10    65.5   0.0    0.0       vcmpleps	k2 {k2}, xmm2, xmm0
78.    10    53.5   0.0    12.0      vmaxps	xmm1, xmm1, xmm6
79.    10    57.5   0.0    8.0       vminps	xmm1, xmm1, xmm0
80.    10    60.6   0.0    4.0       vmulps	xmm1, xmm24, xmm1
81.    10    54.5   0.0    9.2       vmaxps	xmm2, xmm2, xmm6
82.    10    58.5   0.0    5.2       vminps	xmm2, xmm2, xmm0
83.    10    1.0    1.0    59.7      vbroadcastss	xmm3, dword ptr [rip + .LCPI16_1]
84.    10    61.5   0.0    1.2       vmulps	xmm2, xmm25, xmm2
85.    10    61.8   0.0    0.0       vaddps	xmm1, xmm1, xmm3
86.    10    62.8   0.0    0.0       vaddps	xmm2, xmm2, xmm3
87.    10    64.0   0.0    0.0       vcvttps2dq	xmm3, xmm1
88.    10    67.1   0.0    0.0       vcvtdq2ps	xmm31, xmm3
89.    10    71.0   0.0    0.0       vsubps	xmm31, xmm1, xmm31
90.    10    65.8   0.0    5.2       vcvttps2dq	xmm1, xmm2
91.    10    68.9   0.0    1.2       vcvtdq2ps	xmm7, xmm1
92.    10    72.9   0.0    0.0       vsubps	xmm12, xmm2, xmm7
93.    10    65.2   0.0    9.8       vpslld	xmm2, xmm3, 2
94.    10    67.9   0.0    0.0       vpmulld	xmm1, xmm23, xmm1
95.    10    77.0   0.0    0.0       vpaddd	xmm7, xmm2, xmm1
96.    10    77.1   0.0    0.0       vpmovsxdq	ymm1, xmm7
97.    10    80.1   0.0    0.0       vpaddq	ymm1, ymm27, ymm1
98.    10    80.1   0.0    0.0       vpextrq	rax, xmm1, 1
99.    10    81.1   1.0    0.0       vmovq	rbp, xmm1
100.   10    80.2   1.0    0.0       vextracti128	xmm1, ymm1, 1
101.   10    83.2   0.0    0.0       vpextrq	r8, xmm1, 1
102.   10    83.2   1.0    0.0       vmovq	rcx, xmm1
103.   10    80.3   0.0    0.0       vmovd	xmm1, dword ptr [rbp + 4]
104.   10    80.3   0.0    0.0       vpinsrd	xmm1, xmm1, dword ptr [rax + 4], 1
105.   10    83.4   0.0    0.0       vpinsrd	xmm1, xmm1, dword ptr [rcx + 4], 2
106.   10    83.4   0.0    0.0       vpinsrd	xmm1, xmm1, dword ptr [r8 + 4], 3
107.   10    0.0    0.0    89.4      vpxor	xmm11, xmm11, xmm11
108.   10    79.4   1.0    5.0       vmovd	xmm2, dword ptr [rbp + rbx]
109.   10    79.5   1.0    3.0       vpinsrd	xmm2, xmm2, dword ptr [rax + rbx], 1
110.   10    82.5   2.0    0.0       vpinsrd	xmm2, xmm2, dword ptr [rcx + rbx], 2
111.   10    82.6   0.0    0.0       vpinsrd	xmm2, xmm2, dword ptr [r8 + rbx], 3
112.   10    1.2    1.2    86.4      kxnorw	k3, k0, k0
113.   10    75.7   1.0    7.0       vmovd	xmm3, dword ptr [rbp + rbx + 4]
114.   10    77.6   2.0    4.0       vpinsrd	xmm3, xmm3, dword ptr [rax + rbx + 4], 1
115.   10    81.7   4.0    0.0       vpinsrd	xmm3, xmm3, dword ptr [rcx + rbx + 4], 2
116.   10    82.7   0.0    0.0       vpinsrd	xmm3, xmm3, dword ptr [r8 + rbx + 4], 3
117.   10    65.7   0.0    3.0       vpgatherdd	xmm11 {k3}, xmmword ptr [rdi + xmm7]
118.   10    1.1    1.1    78.6      vpbroadcastw	xmm7, word ptr [rip + .LCPI16_2]
119.   10    82.8   0.0    2.0       vpand	xmm8, xmm11, xmm7
120.   10    82.9   0.0    0.0       vpmullw	xmm13, xmm8, xmm8
121.   10    81.9   0.0    5.0       vpsrlw	xmm8, xmm11, 8
122.   10    82.0   0.0    0.0       vpmullw	xmm8, xmm8, xmm8
123.   10    77.2   0.0    6.0       vpand	xmm14, xmm1, xmm7
124.   10    77.5   2.0    0.0       vpmullw	xmm14, xmm14, xmm14
125.   10    69.2   0.0    5.0       vpand	xmm15, xmm2, xmm7
126.   10    70.2   0.0    0.0       vpmullw	xmm15, xmm15, xmm15
127.   10    68.4   0.0    3.0       vpand	xmm7, xmm3, xmm7
128.   10    69.4   0.0    0.0       vpmullw	xmm7, xmm7, xmm7
129.   10    70.5   0.0    2.0       vpsrld	xmm4, xmm13, 16
130.   10    71.3   0.0    0.0       vcvtdq2ps	xmm4, xmm4
131.   10    36.8   0.0    31.8      vsubps	xmm5, xmm0, xmm31
132.   10    39.5   0.0    29.0      vsubps	xmm16, xmm0, xmm12
133.   10    43.5   0.0    25.0      vmulps	xmm26, xmm16, xmm5
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
197.   10    1.0    1.0    27.0      vmovdqu64	xmm31, xmmword ptr [r14]
198.   10    22.0   22.0   12.0      vpsrld	xmm2, xmm3, 24
199.   10    23.0   1.0    7.0       vcvtdq2ps	xmm2, xmm2
200.   10    27.0   0.0    3.0       vmulps	xmm2, xmm12, xmm2
201.   10    9.0    8.0    18.0      vpandd	xmm3, xmm31, dword ptr [rip + .LCPI16_3]{1to4}
202.   10    22.0   0.0    7.0       vmulps	xmm4, xmm17, xmm4
203.   10    25.0   0.0    4.0       vmulps	xmm5, xmm18, xmm8
204.   10    31.0   0.0    0.0       vmulps	xmm16, xmm19, xmm7
205.   10    32.0   0.0    0.0       vaddps	xmm1, xmm1, xmm2
206.   10    36.0   0.0    0.0       vmulps	xmm26, xmm20, xmm1
207.   10    25.0   0.0    11.0      vmaxps	xmm1, xmm4, xmm6
208.   10    1.0    1.0    32.0      vbroadcastss	xmm2, dword ptr [rip + .LCPI16_6]
209.   10    28.0   0.0    7.0       vminps	xmm1, xmm1, xmm2
210.   10    27.0   0.0    8.0       vmaxps	xmm4, xmm5, xmm6
211.   10    30.0   0.0    4.0       vminps	xmm4, xmm4, xmm2
212.   10    32.0   0.0    2.0       vmaxps	xmm5, xmm16, xmm6
213.   10    36.0   0.0    0.0       vminps	xmm5, xmm5, xmm2
214.   10    34.0   0.0    0.0       vmulps	xmm2, xmm26, dword ptr [rip + .LCPI16_7]{1to4}
215.   10    43.0   0.0    0.0       vaddps	xmm16, xmm2, xmm0
216.   10    5.0    3.0    41.0      vpshufb	xmm0, xmm31, xmm10
217.   10    19.0   13.0   24.0      vcvtdq2ps	xmm0, xmm0
218.   10    22.0   0.0    20.0      vmulps	xmm0, xmm0, xmm0
219.   10    46.0   0.0    0.0       vmulps	xmm0, xmm0, xmm16
220.   10    50.0   0.0    0.0       vaddps	xmm1, xmm0, xmm1
221.   10    4.0    4.0    42.0      vpshufb	xmm0, xmm31, xmmword ptr [rip + .LCPI16_4]
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
252.   10    57.0   0.0    0.0       vmovdqa64	xmmword ptr [r14], xmm31
253.   10    13.0   13.0   44.0      kxnorw	k2, k0, k0
254.   10    14.0   14.0   33.0      vaddps	xmm30, xmm30, dword ptr [rip + .LCPI16_8]{1to4}
255.   10    1.0    1.0    55.0      lea	eax, [r12 + 8]
256.   10    1.0    0.0    54.0      cmp	eax, r10d
257.   10    2.0    0.0    53.0      jl	.LBB16_18
258.   10    13.0   13.0   42.0      kmovq	k2, k1
259.   10    2.0    2.0    52.0      jmp	.LBB16_18
260.   10    1.0    1.0    49.0      movsxd	rax, dword ptr [rsp + 64]
261.   10    14.0   8.0    38.0      imul	rax, rax, 1717986919
262.   10    16.0   0.0    37.0      mov	rcx, rax
263.   10    17.0   0.0    36.0      shr	rcx, 63
264.   10    17.0   1.0    36.0      sar	rax, 33
265.   10    18.0   0.0    35.0      add	eax, ecx
266.   10    1.0    1.0    47.0      mov	r8, qword ptr [rsp + 112]
267.   10    18.0   0.0    34.0      add	r8d, eax
268.   10    1.0    1.0    47.0      mov	r9, qword ptr [rsp + 104]
269.   10    5.0    0.0    46.0      neg	r9d
270.   10    6.0    0.0    45.0      shl	r9, 32
271.   10    1.0    1.0    46.0      mov	ecx, dword ptr [rsp + 60]
       10    36.4   1.3    18.9      <total>
```
</details>
</details>
