## Execution Units in [Tiger Lake (Ice Lake)](https://www.agner.org/optimize/microarchitecture.pdf) 
![Block Diagram](https://upload.wikimedia.org/wikipedia/commons/d/d5/Sunny_cove_block_diagram.png)

<details>
<summary>Table</summary>

| Port  |                    Operations                     |
|-------|---------------------------------------------------|
|    0  | integer arithmetic, logic, shift                  |
|    0  | vector arithmetic, logic, shift. 256 bits         |
|    0  | vector string instructions                        |
|    0  | floating point add, multiply, FMA. 256 bits       |
|    0  | integer vector multiplication. 256 bits           |
|    0  | floating point division, square root. 256 bits    |
|    0  | AES encryption                                    |
|    0  | jump and branch                                   |
|    1  | integer arithmetic, logic                         |
|    1  | integer vector arithmetic, logic, shift. 256 bits |
|    1  | integer multiplication, bit scan                  |
|    1  | floating point add, multiply, FMA. 256 bits       |
|    1  | integer vector multiplication. 256 bits           |
|    1  | integer division variable                         |
|    1  | AES encryption                                    |
|    5  | integer arithmetic, logic, shift                  |
|    5  | integer vector arithmetic, logic. 512 bits        |
|    5  | vector permute                                    |
|    6  | integer arithmetic, logic                         |
|    6  | jump and branch                                   |
|    2  | address generation and read. 512 bits             |
|    3  | address generation and read. 512 bits             |
|    7  | address generation for write                      |
|    8  | address generation for write                      |
|    4  | memory write. 256 bits                            |
|    9  | memory write. 256 bits                            |

</details>

## LLVM-MCA outputs

### change computer

<details><summary>[0] Code Region - ProcessPixel</summary>

```
Iterations:        100
Instructions:      20600
Total Cycles:      11337
Total uOps:        22700

Dispatch Width:    6
uOps Per Cycle:    2.00
IPC:               1.82
Block RThroughput: 61.0


Cycles with backend pressure increase [ 94.28% ]
Throughput Bottlenecks: 
  Resource Pressure       [ 52.81% ]
  - ICXPort0  [ 38.71% ]
  - ICXPort1  [ 36.08% ]
  - ICXPort5  [ 20.26% ]
  Data Dependencies:      [ 66.12% ]
  - Register Dependencies [ 66.12% ]
  - Memory Dependencies   [ 0.00% ]

```

<details><summary>Critical sequence based on the simulation:</summary>

```

              Instruction                                 Dependency Information
        0.    vmulps	xmm0, xmm23, xmm24
        1.    vmulps	xmm1, xmm25, xmm24
        2.    vaddps	xmm1, xmm30, xmm1
        3.    vaddps	xmm2, xmm29, xmm0
        4.    vcmpordps	k1, xmm2, xmm2
 +----< 5.    vbroadcastss	xmm9, dword ptr [rip + .LCPI3_0]
 |      6.    vmaxps	xmm3 {k1} {z}, xmm15, xmm2
 |      7.    vminps	xmm7, xmm9, xmm3
 |      8.    vcmpunordps	k1, xmm3, xmm3
 |      9.    vcmpordps	k2, xmm1, xmm1
 +----> 10.   vmovaps	xmm7 {k1}, xmm9                   ## REGISTER dependency:  xmm9
 |      11.   vmaxps	xmm3 {k2} {z}, xmm15, xmm1
 |      12.   vminps	xmm6, xmm9, xmm3
 |      13.   vcmpunordps	k1, xmm3, xmm3
 +----> 14.   vmulps	xmm3, xmm26, xmm7                 ## REGISTER dependency:  xmm7
 |      15.   vmovaps	xmm6 {k1}, xmm9
 |      16.   vmulps	xmm7, xmm27, xmm6
 |      17.   vcvttps2dq	xmm6, xmm7
 +----> 18.   vcvttps2dq	xmm4, xmm3                        ## REGISTER dependency:  xmm3
 +----> 19.   vcvtdq2ps	xmm31, xmm4                       ## REGISTER dependency:  xmm4
 |      20.   vpmulld	xmm5, xmm28, xmm6
 +----> 21.   vpslld	xmm4, xmm4, 2                     ## RESOURCE interference:  ICXPort0 [ probability: 99% ]
 |      22.   vcvtdq2ps	xmm13, xmm6
 +----> 23.   vpaddd	xmm4, xmm5, xmm4                  ## REGISTER dependency:  xmm4
 |      24.   vpsubd	xmm5, xmm15, xmm4
 |      25.   vpmovsxdq	ymm5, xmm5
 |      26.   vpcmpgtd	k1, xmm4, xmm15
 |      27.   vpsubq	ymm5, ymm16, ymm5
 +----> 28.   vpmovsxdq	ymm5 {k1}, xmm4                   ## REGISTER dependency:  xmm4
 |      29.   vmovq	rsi, xmm5
 |      30.   lea	r12, [rdi + rsi]
 |      31.   vpextrq	rcx, xmm5, 1
 +----> 32.   vextracti128	xmm4, ymm5, 1             ## REGISTER dependency:  ymm5
 |      33.   lea	rax, [rdi + rcx]
 +----> 34.   vmovq	r8, xmm4                          ## REGISTER dependency:  xmm4
 |      35.   vpextrq	r9, xmm4, 1
 +----> 36.   lea	rbx, [rdi + r8]                   ## REGISTER dependency:  r8
 |      37.   vmovd	xmm4, dword ptr [rdi + rsi]
 |      38.   vmovd	xmm5, dword ptr [rdi + rsi + 4]
 |      39.   vpinsrd	xmm4, xmm4, dword ptr [rdi + rcx], 1
 |      40.   vpinsrd	xmm5, xmm5, dword ptr [rdi + rcx + 4], 1
 |      41.   vpinsrd	xmm4, xmm4, dword ptr [rdi + r8], 2
 |      42.   vpinsrd	xmm5, xmm5, dword ptr [rdi + r8 + 4], 2
 |      43.   vmovd	xmm6, dword ptr [r13 + r12]
 |      44.   lea	rsi, [rdi + r9]
 |      45.   vpinsrd	xmm6, xmm6, dword ptr [r13 + rax], 1
 +----> 46.   vpinsrd	xmm17, xmm6, dword ptr [r13 + rbx], 2 ## REGISTER dependency:  rbx
 |      47.   vcmpleps	k1, xmm15, xmm2
 |      48.   vcmpleps	k1 {k1}, xmm2, xmm9
 +----> 49.   vpinsrd	xmm14, xmm4, dword ptr [rdi + r9], 3 ## RESOURCE interference:  ICXPort5 [ probability: 100% ]
 |      50.   vcmpleps	k1 {k1}, xmm15, xmm1
 |      51.   vcmpleps	k1 {k1}, xmm1, xmm9
 +----> 52.   vpinsrd	xmm11, xmm5, dword ptr [rdi + r9 + 4], 3 ## RESOURCE interference:  ICXPort5 [ probability: 100% ]
 |      53.   vsubps	xmm4, xmm3, xmm31
 |      54.   vsubps	xmm5, xmm7, xmm13
 +----> 55.   vpinsrd	xmm17, xmm17, dword ptr [r13 + rsi], 3 ## RESOURCE interference:  ICXPort5 [ probability: 100% ]
 |      56.   vpbroadcastw	xmm31, word ptr [rip + .LCPI3_16]
 |      57.   vpandq	xmm7, xmm14, xmm31
 |      58.   vpmullw	xmm12, xmm7, xmm7
 |      59.   vpsrlw	xmm7, xmm14, 8
 |      60.   vpmullw	xmm13, xmm7, xmm7
 |      61.   vsubps	xmm7, xmm9, xmm4
 |      62.   vpsrld	xmm3, xmm12, 16
 |      63.   vsubps	xmm1, xmm9, xmm5
 |      64.   vmulps	xmm18, xmm1, xmm7
 |      65.   vmulps	xmm1, xmm4, xmm1
 |      66.   vcvtdq2ps	xmm3, xmm3
 |      67.   vmulps	xmm7, xmm5, xmm7
 |      68.   vmulps	xmm4, xmm5, xmm4
 |      69.   vmulps	xmm5, xmm18, xmm3
 |      70.   vmulps	xmm16, xmm1, xmm3
 |      71.   vaddps	xmm5, xmm5, xmm16
 |      72.   vpsrlw	xmm2, xmm11, 8
 |      73.   vpmullw	xmm2, xmm2, xmm2
 |      74.   vpblendw	xmm6, xmm13, xmm15, 170
 |      75.   vcvtdq2ps	xmm6, xmm6
 |      76.   vpblendw	xmm2, xmm2, xmm15, 170
 |      77.   vcvtdq2ps	xmm2, xmm2
 |      78.   vmulps	xmm6, xmm18, xmm6
 |      79.   vmulps	xmm2, xmm1, xmm2
 |      80.   vaddps	xmm2, xmm6, xmm2
 |      81.   vmulps	xmm6, xmm7, xmm3
 |      82.   vaddps	xmm5, xmm6, xmm5
 +----> 83.   vpsrlw	xmm6, xmm17, 8                    ## REGISTER dependency:  xmm17
 +----> 84.   vpmullw	xmm6, xmm6, xmm6                  ## REGISTER dependency:  xmm6
 |      85.   vpblendw	xmm6, xmm6, xmm15, 170
 |      86.   vcvtdq2ps	xmm6, xmm6
 |      87.   vmulps	xmm6, xmm7, xmm6
 |      88.   vaddps	xmm16, xmm6, xmm2
 |      89.   vpandq	xmm6, xmm11, xmm31
 +----> 90.   vpmullw	xmm6, xmm6, xmm6                  ## RESOURCE interference:  ICXPort1 [ probability: 100% ]
 |      91.   vpblendw	xmm2, xmm12, xmm15, 170
 |      92.   vcvtdq2ps	xmm2, xmm2
 |      93.   vpblendw	xmm6, xmm6, xmm15, 170
 |      94.   vcvtdq2ps	xmm6, xmm6
 |      95.   vmulps	xmm2, xmm18, xmm2
 |      96.   vmulps	xmm6, xmm1, xmm6
 |      97.   vaddps	xmm2, xmm2, xmm6
 |      98.   vmovd	xmm6, dword ptr [r13 + r12 + 4]
 |      99.   vpinsrd	xmm6, xmm6, dword ptr [r13 + rax + 4], 1
 |      100.  vpinsrd	xmm6, xmm6, dword ptr [r13 + rbx + 4], 2
 |      101.  vpinsrd	xmm6, xmm6, dword ptr [r13 + rsi + 4], 3
 |      102.  vmulps	xmm3, xmm4, xmm3
 |      103.  vaddps	xmm12, xmm3, xmm5
 |      104.  vpandq	xmm5, xmm17, xmm31
 +----> 105.  vpmullw	xmm5, xmm5, xmm5                  ## RESOURCE interference:  ICXPort0 [ probability: 100% ]
 |      106.  vpblendw	xmm5, xmm5, xmm15, 170
 |      107.  vcvtdq2ps	xmm5, xmm5
 |      108.  vmulps	xmm5, xmm7, xmm5
 |      109.  vaddps	xmm2, xmm5, xmm2
 |      110.  vpsrlw	xmm5, xmm6, 8
 |      111.  vpmullw	xmm5, xmm5, xmm5
 |      112.  vpblendw	xmm5, xmm5, xmm15, 170
 |      113.  vcvtdq2ps	xmm5, xmm5
 |      114.  vmulps	xmm5, xmm4, xmm5
 |      115.  vaddps	xmm5, xmm5, xmm16
 +----> 116.  vpsrld	xmm3, xmm14, 24                   ## RESOURCE interference:  ICXPort1 [ probability: 100% ]
 +----> 117.  vcvtdq2ps	xmm3, xmm3                        ## REGISTER dependency:  xmm3
 |      118.  vmulps	xmm3, xmm18, xmm3
 +----> 119.  vpsrld	xmm0, xmm11, 24                   ## RESOURCE interference:  ICXPort1 [ probability: 100% ]
 +----> 120.  vcvtdq2ps	xmm0, xmm0                        ## REGISTER dependency:  xmm0
 +----> 121.  vmulps	xmm0, xmm1, xmm0                  ## REGISTER dependency:  xmm0
 |      122.  vaddps	xmm0, xmm3, xmm0
 +----> 123.  vpsrld	xmm1, xmm17, 24                   ## RESOURCE interference:  ICXPort1 [ probability: 100% ]
 +----> 124.  vcvtdq2ps	xmm1, xmm1                        ## REGISTER dependency:  xmm1
 |      125.  vmulps	xmm1, xmm7, xmm1
 |      126.  vpandq	xmm3, xmm6, xmm31
 +----> 127.  vpmullw	xmm3, xmm3, xmm3                  ## RESOURCE interference:  ICXPort1 [ probability: 100% ]
 |      128.  vpblendw	xmm3, xmm3, xmm15, 170
 |      129.  vcvtdq2ps	xmm3, xmm3
 |      130.  vmulps	xmm3, xmm4, xmm3
 |      131.  vaddps	xmm2, xmm3, xmm2
 |      132.  vaddps	xmm0, xmm1, xmm0
 +----> 133.  vpsrld	xmm1, xmm6, 24                    ## RESOURCE interference:  ICXPort1 [ probability: 100% ]
 +----> 134.  vcvtdq2ps	xmm1, xmm1                        ## REGISTER dependency:  xmm1
 |      135.  vmulps	xmm3, xmm20, xmm12
 |      136.  vmulps	xmm5, xmm21, xmm5
 |      137.  vmulps	xmm1, xmm4, xmm1
 |      138.  vaddps	xmm0, xmm1, xmm0
 |      139.  vmulps	xmm1, xmm22, xmm2
 |      140.  vmulps	xmm16, xmm19, xmm0
 |      141.  vbroadcastss	xmm0, dword ptr [rip + .LCPI3_20]
 |      142.  vcmpordps	k2, xmm3, xmm3
 |      143.  vmaxps	xmm2 {k2} {z}, xmm15, xmm3
 |      144.  vminps	xmm3, xmm0, xmm2
 |      145.  vcmpordps	k2, xmm5, xmm5
 |      146.  vcmpunordps	k3, xmm2, xmm2
 |      147.  vmaxps	xmm2 {k2} {z}, xmm15, xmm5
 |      148.  vminps	xmm5, xmm0, xmm2
 |      149.  vcmpordps	k2, xmm1, xmm1
 |      150.  vmovaps	xmm3 {k3}, xmm0
 |      151.  vmaxps	xmm1 {k2} {z}, xmm15, xmm1
 |      152.  vcmpunordps	k2, xmm2, xmm2
 |      153.  vminps	xmm7, xmm0, xmm1
 |      154.  vmovaps	xmm5 {k2}, xmm0
 |      155.  vcmpunordps	k2, xmm1, xmm1
 |      156.  vmulps	xmm1, xmm16, dword ptr [rip + .LCPI3_21]{1to4}
 |      157.  vmovaps	xmm7 {k2}, xmm0
 |      158.  vmovdqu	xmm6, xmmword ptr [rdx]
 |      159.  vaddps	xmm4, xmm9, xmm1
 |      160.  vpshufb	xmm0, xmm6, xmm10
 |      161.  vcvtdq2ps	xmm0, xmm0
 |      162.  vmulps	xmm0, xmm0, xmm0
 |      163.  vmulps	xmm0, xmm0, xmm4
 |      164.  vaddps	xmm1, xmm0, xmm3
 |      165.  vpshufb	xmm0, xmm6, xmmword ptr [rip + .LCPI3_18]
 +----> 166.  vcvtdq2ps	xmm0, xmm0                        ## RESOURCE interference:  ICXPort1 [ probability: 100% ]
 +----> 167.  vmulps	xmm0, xmm0, xmm0                  ## REGISTER dependency:  xmm0
 |      168.  vmulps	xmm0, xmm0, xmm4
 |      169.  vaddps	xmm2, xmm0, xmm5
 |      170.  vpandd	xmm0, xmm6, dword ptr [rip + .LCPI3_17]{1to4}
 |      171.  vcvtdq2ps	xmm0, xmm0
 |      172.  vmulps	xmm0, xmm0, xmm0
 |      173.  vmulps	xmm0, xmm0, xmm4
 |      174.  vaddps	xmm3, xmm0, xmm7
 |      175.  vmovaps	xmm0, xmm1
 |      176.  rsqrtps	xmm0, xmm0
 |      177.  vmulps	xmm1, xmm0, xmm1
 |      178.  vmovaps	xmm0, xmm2
 |      179.  rsqrtps	xmm0, xmm0
 |      180.  vmulps	xmm2, xmm0, xmm2
 |      181.  vmovaps	xmm0, xmm3
 |      182.  rsqrtps	xmm0, xmm0
 |      183.  vmulps	xmm3, xmm0, xmm3
 |      184.  vmovaps	xmm0, xmm1
 |      185.  cvtps2dq	xmm0, xmm0
 |      186.  vmovdqa	xmm1, xmm0
 |      187.  vmovaps	xmm0, xmm2
 |      188.  cvtps2dq	xmm0, xmm0
 |      189.  vmovdqa	xmm2, xmm0
 |      190.  vmovaps	xmm0, xmm3
 |      191.  cvtps2dq	xmm0, xmm0
 |      192.  vpslld	xmm1, xmm1, 16
 |      193.  vpslld	xmm2, xmm2, 8
 |      194.  vpternlogd	xmm2, xmm0, xmm1, 254
 +----> 195.  vpsrld	xmm0, xmm6, 24                    ## RESOURCE interference:  ICXPort0 [ probability: 100% ]
 +----> 196.  vcvtdq2ps	xmm0, xmm0                        ## REGISTER dependency:  xmm0
 +----> 197.  vmulps	xmm0, xmm4, xmm0                  ## REGISTER dependency:  xmm0
 +----> 198.  vaddps	xmm0, xmm16, xmm0                 ## REGISTER dependency:  xmm0
 |      199.  vxorps	xmm16, xmm16, xmm16
 +----> 200.  cvtps2dq	xmm0, xmm0                        ## REGISTER dependency:  xmm0
 +----> 201.  vpslld	xmm0, xmm0, 24                    ## REGISTER dependency:  xmm0
 +----> 202.  vpord	xmm6 {k1}, xmm2, xmm0             ## REGISTER dependency:  xmm0
 |      203.  vmovdqu	xmmword ptr [rdx], xmm6
 |      204.  vaddps	xmm24, xmm24, dword ptr [rip + .LCPI3_22]{1to4}
 |      205.  add	rdx, 16
 |
 |    < loop carried > 
 |
 +----> 53.   vsubps	xmm4, xmm3, xmm31                 ## RESOURCE interference:  ICXPort1 [ probability: 99% ]


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
 1      4     0.50                        vmulps	xmm0, xmm23, xmm24
 1      4     0.50                        vmulps	xmm1, xmm25, xmm24
 1      4     0.50                        vaddps	xmm1, xmm30, xmm1
 1      4     0.50                        vaddps	xmm2, xmm29, xmm0
 1      4     1.00                        vcmpordps	k1, xmm2, xmm2
 1      6     0.50    *                   vbroadcastss	xmm9, dword ptr [rip + .LCPI3_0]
 1      4     0.50                        vmaxps	xmm3 {k1} {z}, xmm15, xmm2
 1      4     0.50                        vminps	xmm7, xmm9, xmm3
 1      4     1.00                        vcmpunordps	k1, xmm3, xmm3
 1      4     1.00                        vcmpordps	k2, xmm1, xmm1
 1      1     0.33                        vmovaps	xmm7 {k1}, xmm9
 1      4     0.50                        vmaxps	xmm3 {k2} {z}, xmm15, xmm1
 1      4     0.50                        vminps	xmm6, xmm9, xmm3
 1      4     1.00                        vcmpunordps	k1, xmm3, xmm3
 1      4     0.50                        vmulps	xmm3, xmm26, xmm7
 1      1     0.33                        vmovaps	xmm6 {k1}, xmm9
 1      4     0.50                        vmulps	xmm7, xmm27, xmm6
 1      4     0.50                        vcvttps2dq	xmm6, xmm7
 1      4     0.50                        vcvttps2dq	xmm4, xmm3
 1      4     0.50                        vcvtdq2ps	xmm31, xmm4
 2      10    1.00                        vpmulld	xmm5, xmm28, xmm6
 1      1     0.50                        vpslld	xmm4, xmm4, 2
 1      4     0.50                        vcvtdq2ps	xmm13, xmm6
 1      1     0.33                        vpaddd	xmm4, xmm5, xmm4
 1      1     0.33                        vpsubd	xmm5, xmm15, xmm4
 1      3     1.00                        vpmovsxdq	ymm5, xmm5
 1      4     1.00                        vpcmpgtd	k1, xmm4, xmm15
 1      1     0.33                        vpsubq	ymm5, ymm16, ymm5
 1      3     1.00                        vpmovsxdq	ymm5 {k1}, xmm4
 1      2     1.00                        vmovq	rsi, xmm5
 1      1     0.50                        lea	r12, [rdi + rsi]
 2      3     1.00                        vpextrq	rcx, xmm5, 1
 1      3     1.00                        vextracti128	xmm4, ymm5, 1
 1      1     0.50                        lea	rax, [rdi + rcx]
 1      2     1.00                        vmovq	r8, xmm4
 2      3     1.00                        vpextrq	r9, xmm4, 1
 1      1     0.50                        lea	rbx, [rdi + r8]
 1      5     0.50    *                   vmovd	xmm4, dword ptr [rdi + rsi]
 1      5     0.50    *                   vmovd	xmm5, dword ptr [rdi + rsi + 4]
 2      6     1.00    *                   vpinsrd	xmm4, xmm4, dword ptr [rdi + rcx], 1
 2      6     1.00    *                   vpinsrd	xmm5, xmm5, dword ptr [rdi + rcx + 4], 1
 2      6     1.00    *                   vpinsrd	xmm4, xmm4, dword ptr [rdi + r8], 2
 2      6     1.00    *                   vpinsrd	xmm5, xmm5, dword ptr [rdi + r8 + 4], 2
 1      5     0.50    *                   vmovd	xmm6, dword ptr [r13 + r12]
 1      1     0.50                        lea	rsi, [rdi + r9]
 2      6     1.00    *                   vpinsrd	xmm6, xmm6, dword ptr [r13 + rax], 1
 2      6     1.00    *                   vpinsrd	xmm17, xmm6, dword ptr [r13 + rbx], 2
 1      4     1.00                        vcmpleps	k1, xmm15, xmm2
 1      4     1.00                        vcmpleps	k1 {k1}, xmm2, xmm9
 2      6     1.00    *                   vpinsrd	xmm14, xmm4, dword ptr [rdi + r9], 3
 1      4     1.00                        vcmpleps	k1 {k1}, xmm15, xmm1
 1      4     1.00                        vcmpleps	k1 {k1}, xmm1, xmm9
 2      6     1.00    *                   vpinsrd	xmm11, xmm5, dword ptr [rdi + r9 + 4], 3
 1      4     0.50                        vsubps	xmm4, xmm3, xmm31
 1      4     0.50                        vsubps	xmm5, xmm7, xmm13
 2      6     1.00    *                   vpinsrd	xmm17, xmm17, dword ptr [r13 + rsi], 3
 2      7     1.00    *                   vpbroadcastw	xmm31, word ptr [rip + .LCPI3_16]
 1      1     0.33                        vpandq	xmm7, xmm14, xmm31
 1      5     0.50                        vpmullw	xmm12, xmm7, xmm7
 1      1     0.50                        vpsrlw	xmm7, xmm14, 8
 1      5     0.50                        vpmullw	xmm13, xmm7, xmm7
 1      4     0.50                        vsubps	xmm7, xmm9, xmm4
 1      1     0.50                        vpsrld	xmm3, xmm12, 16
 1      4     0.50                        vsubps	xmm1, xmm9, xmm5
 1      4     0.50                        vmulps	xmm18, xmm1, xmm7
 1      4     0.50                        vmulps	xmm1, xmm4, xmm1
 1      4     0.50                        vcvtdq2ps	xmm3, xmm3
 1      4     0.50                        vmulps	xmm7, xmm5, xmm7
 1      4     0.50                        vmulps	xmm4, xmm5, xmm4
 1      4     0.50                        vmulps	xmm5, xmm18, xmm3
 1      4     0.50                        vmulps	xmm16, xmm1, xmm3
 1      4     0.50                        vaddps	xmm5, xmm5, xmm16
 1      1     0.50                        vpsrlw	xmm2, xmm11, 8
 1      5     0.50                        vpmullw	xmm2, xmm2, xmm2
 1      1     1.00                        vpblendw	xmm6, xmm13, xmm15, 170
 1      4     0.50                        vcvtdq2ps	xmm6, xmm6
 1      1     1.00                        vpblendw	xmm2, xmm2, xmm15, 170
 1      4     0.50                        vcvtdq2ps	xmm2, xmm2
 1      4     0.50                        vmulps	xmm6, xmm18, xmm6
 1      4     0.50                        vmulps	xmm2, xmm1, xmm2
 1      4     0.50                        vaddps	xmm2, xmm6, xmm2
 1      4     0.50                        vmulps	xmm6, xmm7, xmm3
 1      4     0.50                        vaddps	xmm5, xmm6, xmm5
 1      1     0.50                        vpsrlw	xmm6, xmm17, 8
 1      5     0.50                        vpmullw	xmm6, xmm6, xmm6
 1      1     1.00                        vpblendw	xmm6, xmm6, xmm15, 170
 1      4     0.50                        vcvtdq2ps	xmm6, xmm6
 1      4     0.50                        vmulps	xmm6, xmm7, xmm6
 1      4     0.50                        vaddps	xmm16, xmm6, xmm2
 1      1     0.33                        vpandq	xmm6, xmm11, xmm31
 1      5     0.50                        vpmullw	xmm6, xmm6, xmm6
 1      1     1.00                        vpblendw	xmm2, xmm12, xmm15, 170
 1      4     0.50                        vcvtdq2ps	xmm2, xmm2
 1      1     1.00                        vpblendw	xmm6, xmm6, xmm15, 170
 1      4     0.50                        vcvtdq2ps	xmm6, xmm6
 1      4     0.50                        vmulps	xmm2, xmm18, xmm2
 1      4     0.50                        vmulps	xmm6, xmm1, xmm6
 1      4     0.50                        vaddps	xmm2, xmm2, xmm6
 1      5     0.50    *                   vmovd	xmm6, dword ptr [r13 + r12 + 4]
 2      6     1.00    *                   vpinsrd	xmm6, xmm6, dword ptr [r13 + rax + 4], 1
 2      6     1.00    *                   vpinsrd	xmm6, xmm6, dword ptr [r13 + rbx + 4], 2
 2      6     1.00    *                   vpinsrd	xmm6, xmm6, dword ptr [r13 + rsi + 4], 3
 1      4     0.50                        vmulps	xmm3, xmm4, xmm3
 1      4     0.50                        vaddps	xmm12, xmm3, xmm5
 1      1     0.33                        vpandq	xmm5, xmm17, xmm31
 1      5     0.50                        vpmullw	xmm5, xmm5, xmm5
 1      1     1.00                        vpblendw	xmm5, xmm5, xmm15, 170
 1      4     0.50                        vcvtdq2ps	xmm5, xmm5
 1      4     0.50                        vmulps	xmm5, xmm7, xmm5
 1      4     0.50                        vaddps	xmm2, xmm5, xmm2
 1      1     0.50                        vpsrlw	xmm5, xmm6, 8
 1      5     0.50                        vpmullw	xmm5, xmm5, xmm5
 1      1     1.00                        vpblendw	xmm5, xmm5, xmm15, 170
 1      4     0.50                        vcvtdq2ps	xmm5, xmm5
 1      4     0.50                        vmulps	xmm5, xmm4, xmm5
 1      4     0.50                        vaddps	xmm5, xmm5, xmm16
 1      1     0.50                        vpsrld	xmm3, xmm14, 24
 1      4     0.50                        vcvtdq2ps	xmm3, xmm3
 1      4     0.50                        vmulps	xmm3, xmm18, xmm3
 1      1     0.50                        vpsrld	xmm0, xmm11, 24
 1      4     0.50                        vcvtdq2ps	xmm0, xmm0
 1      4     0.50                        vmulps	xmm0, xmm1, xmm0
 1      4     0.50                        vaddps	xmm0, xmm3, xmm0
 1      1     0.50                        vpsrld	xmm1, xmm17, 24
 1      4     0.50                        vcvtdq2ps	xmm1, xmm1
 1      4     0.50                        vmulps	xmm1, xmm7, xmm1
 1      1     0.33                        vpandq	xmm3, xmm6, xmm31
 1      5     0.50                        vpmullw	xmm3, xmm3, xmm3
 1      1     1.00                        vpblendw	xmm3, xmm3, xmm15, 170
 1      4     0.50                        vcvtdq2ps	xmm3, xmm3
 1      4     0.50                        vmulps	xmm3, xmm4, xmm3
 1      4     0.50                        vaddps	xmm2, xmm3, xmm2
 1      4     0.50                        vaddps	xmm0, xmm1, xmm0
 1      1     0.50                        vpsrld	xmm1, xmm6, 24
 1      4     0.50                        vcvtdq2ps	xmm1, xmm1
 1      4     0.50                        vmulps	xmm3, xmm20, xmm12
 1      4     0.50                        vmulps	xmm5, xmm21, xmm5
 1      4     0.50                        vmulps	xmm1, xmm4, xmm1
 1      4     0.50                        vaddps	xmm0, xmm1, xmm0
 1      4     0.50                        vmulps	xmm1, xmm22, xmm2
 1      4     0.50                        vmulps	xmm16, xmm19, xmm0
 1      6     0.50    *                   vbroadcastss	xmm0, dword ptr [rip + .LCPI3_20]
 1      4     1.00                        vcmpordps	k2, xmm3, xmm3
 1      4     0.50                        vmaxps	xmm2 {k2} {z}, xmm15, xmm3
 1      4     0.50                        vminps	xmm3, xmm0, xmm2
 1      4     1.00                        vcmpordps	k2, xmm5, xmm5
 1      4     1.00                        vcmpunordps	k3, xmm2, xmm2
 1      4     0.50                        vmaxps	xmm2 {k2} {z}, xmm15, xmm5
 1      4     0.50                        vminps	xmm5, xmm0, xmm2
 1      4     1.00                        vcmpordps	k2, xmm1, xmm1
 1      1     0.33                        vmovaps	xmm3 {k3}, xmm0
 1      4     0.50                        vmaxps	xmm1 {k2} {z}, xmm15, xmm1
 1      4     1.00                        vcmpunordps	k2, xmm2, xmm2
 1      4     0.50                        vminps	xmm7, xmm0, xmm1
 1      1     0.33                        vmovaps	xmm5 {k2}, xmm0
 1      4     1.00                        vcmpunordps	k2, xmm1, xmm1
 2      10    0.50    *                   vmulps	xmm1, xmm16, dword ptr [rip + .LCPI3_21]{1to4}
 1      1     0.33                        vmovaps	xmm7 {k2}, xmm0
 1      6     0.50    *                   vmovdqu	xmm6, xmmword ptr [rdx]
 1      4     0.50                        vaddps	xmm4, xmm9, xmm1
 1      1     0.50                        vpshufb	xmm0, xmm6, xmm10
 1      4     0.50                        vcvtdq2ps	xmm0, xmm0
 1      4     0.50                        vmulps	xmm0, xmm0, xmm0
 1      4     0.50                        vmulps	xmm0, xmm0, xmm4
 1      4     0.50                        vaddps	xmm1, xmm0, xmm3
 2      7     0.50    *                   vpshufb	xmm0, xmm6, xmmword ptr [rip + .LCPI3_18]
 1      4     0.50                        vcvtdq2ps	xmm0, xmm0
 1      4     0.50                        vmulps	xmm0, xmm0, xmm0
 1      4     0.50                        vmulps	xmm0, xmm0, xmm4
 1      4     0.50                        vaddps	xmm2, xmm0, xmm5
 2      7     0.50    *                   vpandd	xmm0, xmm6, dword ptr [rip + .LCPI3_17]{1to4}
 1      4     0.50                        vcvtdq2ps	xmm0, xmm0
 1      4     0.50                        vmulps	xmm0, xmm0, xmm0
 1      4     0.50                        vmulps	xmm0, xmm0, xmm4
 1      4     0.50                        vaddps	xmm3, xmm0, xmm7
 1      1     0.33                        vmovaps	xmm0, xmm1
 1      4     1.00                        rsqrtps	xmm0, xmm0
 1      4     0.50                        vmulps	xmm1, xmm0, xmm1
 1      1     0.33                        vmovaps	xmm0, xmm2
 1      4     1.00                        rsqrtps	xmm0, xmm0
 1      4     0.50                        vmulps	xmm2, xmm0, xmm2
 1      1     0.33                        vmovaps	xmm0, xmm3
 1      4     1.00                        rsqrtps	xmm0, xmm0
 1      4     0.50                        vmulps	xmm3, xmm0, xmm3
 1      1     0.33                        vmovaps	xmm0, xmm1
 1      4     0.50                        cvtps2dq	xmm0, xmm0
 1      1     0.33                        vmovdqa	xmm1, xmm0
 1      1     0.33                        vmovaps	xmm0, xmm2
 1      4     0.50                        cvtps2dq	xmm0, xmm0
 1      1     0.33                        vmovdqa	xmm2, xmm0
 1      1     0.33                        vmovaps	xmm0, xmm3
 1      4     0.50                        cvtps2dq	xmm0, xmm0
 1      1     0.50                        vpslld	xmm1, xmm1, 16
 1      1     0.50                        vpslld	xmm2, xmm2, 8
 1      1     0.33                        vpternlogd	xmm2, xmm0, xmm1, 254
 1      1     0.50                        vpsrld	xmm0, xmm6, 24
 1      4     0.50                        vcvtdq2ps	xmm0, xmm0
 1      4     0.50                        vmulps	xmm0, xmm4, xmm0
 1      4     0.50                        vaddps	xmm0, xmm16, xmm0
 1      0     0.17                        vxorps	xmm16, xmm16, xmm16
 1      4     0.50                        cvtps2dq	xmm0, xmm0
 1      1     0.50                        vpslld	xmm0, xmm0, 24
 1      1     0.33                        vpord	xmm6 {k1}, xmm2, xmm0
 2      1     1.00           *            vmovdqu	xmmword ptr [rdx], xmm6
 2      10    0.50    *                   vaddps	xmm24, xmm24, dword ptr [rip + .LCPI3_22]{1to4}
 1      1     0.25                        add	rdx, 16


```
</details>

<details><summary>Dynamic Dispatch Stall Cycles:</summary>

```
RAT     - Register unavailable:                      0
RCU     - Retire tokens unavailable:                 0
SCHEDQ  - Scheduler full:                            11272  (99.4%)
LQ      - Load queue full:                           0
SQ      - Store queue full:                          0
GROUP   - Static restrictions on the dispatch group: 0
USH     - Uncategorised Structural Hazard:           0


```
</details>

<details><summary>Dispatch Logic - number of cycles where we saw N micro opcodes dispatched:</summary>

```
[# dispatched], [# cycles]
 0,              1353  (11.9%)
 1,              2595  (22.9%)
 2,              3691  (32.6%)
 3,              2096  (18.5%)
 4,              1588  (14.0%)
 5,              1  (0.0%)
 6,              13  (0.1%)


```
</details>

<details><summary>Schedulers - number of cycles where we saw N micro opcodes issued:</summary>

```
[# issued], [# cycles]
 0,          1324  (11.7%)
 1,          1618  (14.3%)
 2,          5100  (45.0%)
 3,          2397  (21.1%)
 4,          799  (7.0%)
 5,          99  (0.9%)

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
 0,           6127  (54.0%)
 1,           1603  (14.1%)
 2,           905  (8.0%)
 3,           1002  (8.8%)
 4,           601  (5.3%)
 6,           200  (1.8%)
 7,           100  (0.9%)
 8,           200  (1.8%)
 9,           100  (0.9%)
 10,          200  (1.8%)
 15,          100  (0.9%)
 16,          100  (0.9%)
 23,          99  (0.9%)

```
</details>

<details><summary>Total ROB Entries:                224</summary>

```
Max Used ROB Entries:             117  ( 52.2% )
Average Used ROB Entries per cy:  97  ( 43.3% )


```
</details>

<details><summary>Register File statistics:</summary>

```
Total number of mappings created:    20500
Max number of mappings used:         111


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
 -      -     69.99  71.01  12.00  12.00  1.00   58.00  1.00   1.00    -      -     

Resource pressure by instruction:
[0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   Instructions:
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm23, xmm24
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm1, xmm25, xmm24
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vaddps	xmm1, xmm30, xmm1
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vaddps	xmm2, xmm29, xmm0
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpordps	k1, xmm2, xmm2
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     vbroadcastss	xmm9, dword ptr [rip + .LCPI3_0]
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmaxps	xmm3 {k1} {z}, xmm15, xmm2
 -      -      -     1.00    -      -      -      -      -      -      -      -     vminps	xmm7, xmm9, xmm3
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpunordps	k1, xmm3, xmm3
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpordps	k2, xmm1, xmm1
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     vmovaps	xmm7 {k1}, xmm9
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmaxps	xmm3 {k2} {z}, xmm15, xmm1
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vminps	xmm6, xmm9, xmm3
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpunordps	k1, xmm3, xmm3
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulps	xmm3, xmm26, xmm7
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmovaps	xmm6 {k1}, xmm9
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulps	xmm7, xmm27, xmm6
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvttps2dq	xmm6, xmm7
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vcvttps2dq	xmm4, xmm3
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm31, xmm4
 -      -      -     2.00    -      -      -      -      -      -      -      -     vpmulld	xmm5, xmm28, xmm6
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vpslld	xmm4, xmm4, 2
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm13, xmm6
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpaddd	xmm4, xmm5, xmm4
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpsubd	xmm5, xmm15, xmm4
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpmovsxdq	ymm5, xmm5
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpcmpgtd	k1, xmm4, xmm15
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vpsubq	ymm5, ymm16, ymm5
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpmovsxdq	ymm5 {k1}, xmm4
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmovq	rsi, xmm5
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	r12, [rdi + rsi]
 -      -     1.00    -      -      -      -     1.00    -      -      -      -     vpextrq	rcx, xmm5, 1
 -      -      -      -      -      -      -     1.00    -      -      -      -     vextracti128	xmm4, ymm5, 1
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	rax, [rdi + rcx]
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmovq	r8, xmm4
 -      -     1.00    -      -      -      -     1.00    -      -      -      -     vpextrq	r9, xmm4, 1
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	rbx, [rdi + r8]
 -      -      -      -      -     1.00    -      -      -      -      -      -     vmovd	xmm4, dword ptr [rdi + rsi]
 -      -      -      -     1.00    -      -      -      -      -      -      -     vmovd	xmm5, dword ptr [rdi + rsi + 4]
 -      -      -      -      -     1.00    -     1.00    -      -      -      -     vpinsrd	xmm4, xmm4, dword ptr [rdi + rcx], 1
 -      -      -      -     1.00    -      -     1.00    -      -      -      -     vpinsrd	xmm5, xmm5, dword ptr [rdi + rcx + 4], 1
 -      -      -      -      -     1.00    -     1.00    -      -      -      -     vpinsrd	xmm4, xmm4, dword ptr [rdi + r8], 2
 -      -      -      -     1.00    -      -     1.00    -      -      -      -     vpinsrd	xmm5, xmm5, dword ptr [rdi + r8 + 4], 2
 -      -      -      -      -     1.00    -      -      -      -      -      -     vmovd	xmm6, dword ptr [r13 + r12]
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	rsi, [rdi + r9]
 -      -      -      -      -     1.00    -     1.00    -      -      -      -     vpinsrd	xmm6, xmm6, dword ptr [r13 + rax], 1
 -      -      -      -     1.00    -      -     1.00    -      -      -      -     vpinsrd	xmm17, xmm6, dword ptr [r13 + rbx], 2
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpleps	k1, xmm15, xmm2
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpleps	k1 {k1}, xmm2, xmm9
 -      -      -      -      -     1.00    -     1.00    -      -      -      -     vpinsrd	xmm14, xmm4, dword ptr [rdi + r9], 3
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpleps	k1 {k1}, xmm15, xmm1
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpleps	k1 {k1}, xmm1, xmm9
 -      -      -      -     1.00    -      -     1.00    -      -      -      -     vpinsrd	xmm11, xmm5, dword ptr [rdi + r9 + 4], 3
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vsubps	xmm4, xmm3, xmm31
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vsubps	xmm5, xmm7, xmm13
 -      -      -      -      -     1.00    -     1.00    -      -      -      -     vpinsrd	xmm17, xmm17, dword ptr [r13 + rsi], 3
 -      -      -      -     1.00    -      -     1.00    -      -      -      -     vpbroadcastw	xmm31, word ptr [rip + .LCPI3_16]
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpandq	xmm7, xmm14, xmm31
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpmullw	xmm12, xmm7, xmm7
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpsrlw	xmm7, xmm14, 8
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpmullw	xmm13, xmm7, xmm7
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vsubps	xmm7, xmm9, xmm4
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpsrld	xmm3, xmm12, 16
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vsubps	xmm1, xmm9, xmm5
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmulps	xmm18, xmm1, xmm7
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulps	xmm1, xmm4, xmm1
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm3, xmm3
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulps	xmm7, xmm5, xmm7
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmulps	xmm4, xmm5, xmm4
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm5, xmm18, xmm3
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm16, xmm1, xmm3
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm5, xmm5, xmm16
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpsrlw	xmm2, xmm11, 8
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpmullw	xmm2, xmm2, xmm2
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm6, xmm13, xmm15, 170
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm6, xmm6
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm2, xmm2, xmm15, 170
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm2, xmm2
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm6, xmm18, xmm6
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm2, xmm1, xmm2
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm2, xmm6, xmm2
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm6, xmm7, xmm3
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm5, xmm6, xmm5
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpsrlw	xmm6, xmm17, 8
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpmullw	xmm6, xmm6, xmm6
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm6, xmm6, xmm15, 170
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm6, xmm6
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm6, xmm7, xmm6
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm16, xmm6, xmm2
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpandq	xmm6, xmm11, xmm31
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpmullw	xmm6, xmm6, xmm6
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm2, xmm12, xmm15, 170
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm2, xmm2
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm6, xmm6, xmm15, 170
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm6, xmm6
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm2, xmm18, xmm2
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm6, xmm1, xmm6
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm2, xmm2, xmm6
 -      -      -      -     1.00    -      -      -      -      -      -      -     vmovd	xmm6, dword ptr [r13 + r12 + 4]
 -      -      -      -     1.00    -      -     1.00    -      -      -      -     vpinsrd	xmm6, xmm6, dword ptr [r13 + rax + 4], 1
 -      -      -      -      -     1.00    -     1.00    -      -      -      -     vpinsrd	xmm6, xmm6, dword ptr [r13 + rbx + 4], 2
 -      -      -      -     1.00    -      -     1.00    -      -      -      -     vpinsrd	xmm6, xmm6, dword ptr [r13 + rsi + 4], 3
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm3, xmm4, xmm3
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm12, xmm3, xmm5
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpandq	xmm5, xmm17, xmm31
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpmullw	xmm5, xmm5, xmm5
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm5, xmm5, xmm15, 170
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm5, xmm5
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm5, xmm7, xmm5
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm2, xmm5, xmm2
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpsrlw	xmm5, xmm6, 8
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpmullw	xmm5, xmm5, xmm5
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm5, xmm5, xmm15, 170
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm5, xmm5
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm5, xmm4, xmm5
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm5, xmm5, xmm16
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpsrld	xmm3, xmm14, 24
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm3, xmm3
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm3, xmm18, xmm3
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpsrld	xmm0, xmm11, 24
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm0, xmm0
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm1, xmm0
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm0, xmm3, xmm0
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpsrld	xmm1, xmm17, 24
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm1, xmm1
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm1, xmm7, xmm1
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpandq	xmm3, xmm6, xmm31
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpmullw	xmm3, xmm3, xmm3
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm3, xmm3, xmm15, 170
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm3, xmm3
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm3, xmm4, xmm3
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm2, xmm3, xmm2
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm0, xmm1, xmm0
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpsrld	xmm1, xmm6, 24
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm1, xmm1
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm3, xmm20, xmm12
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm5, xmm21, xmm5
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm1, xmm4, xmm1
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm0, xmm1, xmm0
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm1, xmm22, xmm2
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm16, xmm19, xmm0
 -      -      -      -      -     1.00    -      -      -      -      -      -     vbroadcastss	xmm0, dword ptr [rip + .LCPI3_20]
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpordps	k2, xmm3, xmm3
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmaxps	xmm2 {k2} {z}, xmm15, xmm3
 -      -     1.00    -      -      -      -      -      -      -      -      -     vminps	xmm3, xmm0, xmm2
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpordps	k2, xmm5, xmm5
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpunordps	k3, xmm2, xmm2
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmaxps	xmm2 {k2} {z}, xmm15, xmm5
 -      -     1.00    -      -      -      -      -      -      -      -      -     vminps	xmm5, xmm0, xmm2
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpordps	k2, xmm1, xmm1
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovaps	xmm3 {k3}, xmm0
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmaxps	xmm1 {k2} {z}, xmm15, xmm1
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpunordps	k2, xmm2, xmm2
 -      -     1.00    -      -      -      -      -      -      -      -      -     vminps	xmm7, xmm0, xmm1
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmovaps	xmm5 {k2}, xmm0
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpunordps	k2, xmm1, xmm1
 -      -      -     1.00   0.01   0.99    -      -      -      -      -      -     vmulps	xmm1, xmm16, dword ptr [rip + .LCPI3_21]{1to4}
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovaps	xmm7 {k2}, xmm0
 -      -      -      -     1.00    -      -      -      -      -      -      -     vmovdqu	xmm6, xmmword ptr [rdx]
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm4, xmm9, xmm1
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpshufb	xmm0, xmm6, xmm10
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm0, xmm0
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm0, xmm0, xmm0
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm0, xmm0, xmm4
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vaddps	xmm1, xmm0, xmm3
 -      -      -      -      -     1.00    -     1.00    -      -      -      -     vpshufb	xmm0, xmm6, xmmword ptr [rip + .LCPI3_18]
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm0, xmm0
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm0, xmm0, xmm0
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm0, xmm4
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vaddps	xmm2, xmm0, xmm5
 -      -      -      -     1.00    -      -     1.00    -      -      -      -     vpandd	xmm0, xmm6, dword ptr [rip + .LCPI3_17]{1to4}
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm0, xmm0
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm0, xmm0, xmm0
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm0, xmm4
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm3, xmm0, xmm7
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovaps	xmm0, xmm1
 -      -     1.00    -      -      -      -      -      -      -      -      -     rsqrtps	xmm0, xmm0
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmulps	xmm1, xmm0, xmm1
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmovaps	xmm0, xmm2
 -      -     1.00    -      -      -      -      -      -      -      -      -     rsqrtps	xmm0, xmm0
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmulps	xmm2, xmm0, xmm2
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovaps	xmm0, xmm3
 -      -     1.00    -      -      -      -      -      -      -      -      -     rsqrtps	xmm0, xmm0
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmulps	xmm3, xmm0, xmm3
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovaps	xmm0, xmm1
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     cvtps2dq	xmm0, xmm0
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     vmovdqa	xmm1, xmm0
 -      -     0.99    -      -      -      -     0.01    -      -      -      -     vmovaps	xmm0, xmm2
 -      -      -     1.00    -      -      -      -      -      -      -      -     cvtps2dq	xmm0, xmm0
 -      -     0.99    -      -      -      -     0.01    -      -      -      -     vmovdqa	xmm2, xmm0
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovaps	xmm0, xmm3
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     cvtps2dq	xmm0, xmm0
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vpslld	xmm1, xmm1, 16
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vpslld	xmm2, xmm2, 8
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpternlogd	xmm2, xmm0, xmm1, 254
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpsrld	xmm0, xmm6, 24
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm0, xmm0
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm0, xmm4, xmm0
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm0, xmm16, xmm0
 -      -      -      -      -      -      -      -      -      -      -      -     vxorps	xmm16, xmm16, xmm16
 -      -      -     1.00    -      -      -      -      -      -      -      -     cvtps2dq	xmm0, xmm0
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vpslld	xmm0, xmm0, 24
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpord	xmm6 {k1}, xmm2, xmm0
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     vmovdqu	xmmword ptr [rdx], xmm6
 -      -      -     1.00    -     1.00    -      -      -      -      -      -     vaddps	xmm24, xmm24, dword ptr [rip + .LCPI3_22]{1to4}
 -      -      -      -      -      -      -      -     1.00    -      -      -     add	rdx, 16


```
</details>

<details><summary>Timeline view:</summary>

```
                    0123456789          0123456789          0123456789          0123456789
Index     0123456789          0123456789          0123456789          0123456789          

[0,0]     DeeeeER   .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   vmulps	xmm0, xmm23, xmm24
[0,1]     DeeeeER   .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   vmulps	xmm1, xmm25, xmm24
[0,2]     D====eeeeER    .    .    .    .    .    .    .    .    .    .    .    .    .   .   vaddps	xmm1, xmm30, xmm1
[0,3]     D====eeeeER    .    .    .    .    .    .    .    .    .    .    .    .    .   .   vaddps	xmm2, xmm29, xmm0
[0,4]     D========eeeeER.    .    .    .    .    .    .    .    .    .    .    .    .   .   vcmpordps	k1, xmm2, xmm2
[0,5]     DeeeeeeE------R.    .    .    .    .    .    .    .    .    .    .    .    .   .   vbroadcastss	xmm9, dword ptr [rip + .LCPI3_0]
[0,6]     .D===========eeeeER .    .    .    .    .    .    .    .    .    .    .    .   .   vmaxps	xmm3 {k1} {z}, xmm15, xmm2
[0,7]     .D===============eeeeER  .    .    .    .    .    .    .    .    .    .    .   .   vminps	xmm7, xmm9, xmm3
[0,8]     .D===============eeeeER  .    .    .    .    .    .    .    .    .    .    .   .   vcmpunordps	k1, xmm3, xmm3
[0,9]     .D========eeeeE-------R  .    .    .    .    .    .    .    .    .    .    .   .   vcmpordps	k2, xmm1, xmm1
[0,10]    .D===================eER .    .    .    .    .    .    .    .    .    .    .   .   vmovaps	xmm7 {k1}, xmm9
[0,11]    .D============eeeeE----R .    .    .    .    .    .    .    .    .    .    .   .   vmaxps	xmm3 {k2} {z}, xmm15, xmm1
[0,12]    . D===============eeeeER .    .    .    .    .    .    .    .    .    .    .   .   vminps	xmm6, xmm9, xmm3
[0,13]    . D===============eeeeER .    .    .    .    .    .    .    .    .    .    .   .   vcmpunordps	k1, xmm3, xmm3
[0,14]    . D===================eeeeER  .    .    .    .    .    .    .    .    .    .   .   vmulps	xmm3, xmm26, xmm7
[0,15]    . D===================eE---R  .    .    .    .    .    .    .    .    .    .   .   vmovaps	xmm6 {k1}, xmm9
[0,16]    . D====================eeeeER .    .    .    .    .    .    .    .    .    .   .   vmulps	xmm7, xmm27, xmm6
[0,17]    . D========================eeeeER  .    .    .    .    .    .    .    .    .   .   vcvttps2dq	xmm6, xmm7
[0,18]    .  D======================eeeeE-R  .    .    .    .    .    .    .    .    .   .   vcvttps2dq	xmm4, xmm3
[0,19]    .  D==========================eeeeER    .    .    .    .    .    .    .    .   .   vcvtdq2ps	xmm31, xmm4
[0,20]    .  D===========================eeeeeeeeeeER  .    .    .    .    .    .    .   .   vpmulld	xmm5, xmm28, xmm6
[0,21]    .  D==========================eE----------R  .    .    .    .    .    .    .   .   vpslld	xmm4, xmm4, 2
[0,22]    .  D===========================eeeeE------R  .    .    .    .    .    .    .   .   vcvtdq2ps	xmm13, xmm6
[0,23]    .   D====================================eER .    .    .    .    .    .    .   .   vpaddd	xmm4, xmm5, xmm4
[0,24]    .   D=====================================eER.    .    .    .    .    .    .   .   vpsubd	xmm5, xmm15, xmm4
[0,25]    .   D======================================eeeER  .    .    .    .    .    .   .   vpmovsxdq	ymm5, xmm5
[0,26]    .   D=======================================eeeeER.    .    .    .    .    .   .   vpcmpgtd	k1, xmm4, xmm15
[0,27]    .   D=========================================eE-R.    .    .    .    .    .   .   vpsubq	ymm5, ymm16, ymm5
[0,28]    .   D===========================================eeeER  .    .    .    .    .   .   vpmovsxdq	ymm5 {k1}, xmm4
[0,29]    .    D=============================================eeER.    .    .    .    .   .   vmovq	rsi, xmm5
[0,30]    .    D===============================================eER    .    .    .    .   .   lea	r12, [rdi + rsi]
[0,31]    .    D==============================================eeeER   .    .    .    .   .   vpextrq	rcx, xmm5, 1
[0,32]    .    D=============================================eeeE-R   .    .    .    .   .   vextracti128	xmm4, ymm5, 1
[0,33]    .    D=================================================eER  .    .    .    .   .   lea	rax, [rdi + rcx]
[0,34]    .    .D===============================================eeER  .    .    .    .   .   vmovq	r8, xmm4
[0,35]    .    .D================================================eeeER.    .    .    .   .   vpextrq	r9, xmm4, 1
[0,36]    .    .D=================================================eE-R.    .    .    .   .   lea	rbx, [rdi + r8]
[0,37]    .    .D==============================================eeeeeER.    .    .    .   .   vmovd	xmm4, dword ptr [rdi + rsi]
[0,38]    .    .D==============================================eeeeeER.    .    .    .   .   vmovd	xmm5, dword ptr [rdi + rsi + 4]
[0,39]    .    . D================================================eeeeeeER .    .    .   .   vpinsrd	xmm4, xmm4, dword ptr [rdi + rcx], 1
[0,40]    .    . D=================================================eeeeeeER.    .    .   .   vpinsrd	xmm5, xmm5, dword ptr [rdi + rcx + 4], 1
[0,41]    .    . D==================================================eeeeeeER    .    .   .   vpinsrd	xmm4, xmm4, dword ptr [rdi + r8], 2
[0,42]    .    .  D==================================================eeeeeeER   .    .   .   vpinsrd	xmm5, xmm5, dword ptr [rdi + r8 + 4], 2
[0,43]    .    .  D=============================================eeeeeE------R   .    .   .   vmovd	xmm6, dword ptr [r13 + r12]
[0,44]    .    .  D=================================================eE------R   .    .   .   lea	rsi, [rdi + r9]
[0,45]    .    .  D===================================================eeeeeeER  .    .   .   vpinsrd	xmm6, xmm6, dword ptr [r13 + rax], 1
[0,46]    .    .   D===================================================eeeeeeER .    .   .   vpinsrd	xmm17, xmm6, dword ptr [r13 + rbx], 2
[0,47]    .    .   D=eeeeE----------------------------------------------------R .    .   .   vcmpleps	k1, xmm15, xmm2
[0,48]    .    .   D=====eeeeE------------------------------------------------R .    .   .   vcmpleps	k1 {k1}, xmm2, xmm9
[0,49]    .    .   D====================================================eeeeeeER.    .   .   vpinsrd	xmm14, xmm4, dword ptr [rdi + r9], 3
[0,50]    .    .    D========eeeeE---------------------------------------------R.    .   .   vcmpleps	k1 {k1}, xmm15, xmm1
[0,51]    .    .    D============eeeeE-----------------------------------------R.    .   .   vcmpleps	k1 {k1}, xmm1, xmm9
[0,52]    .    .    D====================================================eeeeeeER    .   .   vpinsrd	xmm11, xmm5, dword ptr [rdi + r9 + 4], 3
[0,53]    .    .    D=======================eeeeE-------------------------------R    .   .   vsubps	xmm4, xmm3, xmm31
[0,54]    .    .    D========================eeeeE------------------------------R    .   .   vsubps	xmm5, xmm7, xmm13
[0,55]    .    .    .D====================================================eeeeeeER   .   .   vpinsrd	xmm17, xmm17, dword ptr [r13 + rsi], 3
[0,56]    .    .    .DeeeeeeeE---------------------------------------------------R   .   .   vpbroadcastw	xmm31, word ptr [rip + .LCPI3_16]
[0,57]    .    .    .D========================================================eE-R   .   .   vpandq	xmm7, xmm14, xmm31
[0,58]    .    .    .D=========================================================eeeeeER   .   vpmullw	xmm12, xmm7, xmm7
[0,59]    .    .    . D=======================================================eE-----R   .   vpsrlw	xmm7, xmm14, 8
[0,60]    .    .    . D========================================================eeeeeER   .   vpmullw	xmm13, xmm7, xmm7
[0,61]    .    .    . D=========================eeeeE--------------------------------R   .   vsubps	xmm7, xmm9, xmm4
[0,62]    .    .    . D=============================================================eER  .   vpsrld	xmm3, xmm12, 16
[0,63]    .    .    . D==========================eeeeE--------------------------------R  .   vsubps	xmm1, xmm9, xmm5
[0,64]    .    .    . D==============================eeeeE----------------------------R  .   vmulps	xmm18, xmm1, xmm7
[0,65]    .    .    .  D=============================eeeeE----------------------------R  .   vmulps	xmm1, xmm4, xmm1
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
0.     10    10.9   0.1    29.7      vmulps	xmm0, xmm23, xmm24
1.     10    10.9   0.1    29.7      vmulps	xmm1, xmm25, xmm24
2.     10    14.9   0.0    26.1      vaddps	xmm1, xmm30, xmm1
3.     10    14.9   0.0    26.1      vaddps	xmm2, xmm29, xmm0
4.     10    18.0   0.0    22.5      vcmpordps	k1, xmm2, xmm2
5.     10    1.0    1.0    37.5      vbroadcastss	xmm9, dword ptr [rip + .LCPI3_0]
6.     10    21.0   0.0    18.9      vmaxps	xmm3 {k1} {z}, xmm15, xmm2
7.     10    25.0   0.0    15.3      vminps	xmm7, xmm9, xmm3
8.     10    25.0   0.0    15.3      vcmpunordps	k1, xmm3, xmm3
9.     10    18.0   1.0    22.3      vcmpordps	k2, xmm1, xmm1
10.    10    28.1   0.0    14.4      vmovaps	xmm7 {k1}, xmm9
11.    10    21.1   0.9    17.5      vmaxps	xmm3 {k2} {z}, xmm15, xmm1
12.    10    23.2   0.0    13.5      vminps	xmm6, xmm9, xmm3
13.    10    23.2   0.0    13.5      vcmpunordps	k1, xmm3, xmm3
14.    10    25.4   0.0    10.8      vmulps	xmm3, xmm26, xmm7
15.    10    26.3   0.0    12.9      vmovaps	xmm6 {k1}, xmm9
16.    10    27.3   0.9    8.1       vmulps	xmm7, xmm27, xmm6
17.    10    31.3   0.0    4.5       vcvttps2dq	xmm6, xmm7
18.    10    26.6   0.0    7.3       vcvttps2dq	xmm4, xmm3
19.    10    30.6   0.0    3.6       vcvtdq2ps	xmm31, xmm4
20.    10    34.3   0.9    0.0       vpmulld	xmm5, xmm28, xmm6
21.    10    29.7   0.9    11.8      vpslld	xmm4, xmm4, 2
22.    10    33.4   1.8    5.1       vcvtdq2ps	xmm13, xmm6
23.    10    42.4   0.0    0.0       vpaddd	xmm4, xmm5, xmm4
24.    10    41.6   0.0    0.0       vpsubd	xmm5, xmm15, xmm4
25.    10    42.6   0.0    0.0       vpmovsxdq	ymm5, xmm5
26.    10    41.8   2.0    0.0       vpcmpgtd	k1, xmm4, xmm15
27.    10    43.8   0.0    1.0       vpsubq	ymm5, ymm16, ymm5
28.    10    44.9   0.0    0.0       vpmovsxdq	ymm5 {k1}, xmm4
29.    10    46.9   0.0    0.0       vmovq	rsi, xmm5
30.    10    47.1   0.0    0.0       lea	r12, [rdi + rsi]
31.    10    45.2   1.0    0.0       vpextrq	rcx, xmm5, 1
32.    10    44.2   0.0    1.0       vextracti128	xmm4, ymm5, 1
33.    10    48.2   0.0    0.0       lea	rax, [rdi + rcx]
34.    10    46.2   0.0    0.0       vmovq	r8, xmm4
35.    10    47.2   1.0    0.0       vpextrq	r9, xmm4, 1
36.    10    48.2   0.0    1.0       lea	rbx, [rdi + r8]
37.    10    44.3   0.0    0.0       vmovd	xmm4, dword ptr [rdi + rsi]
38.    10    43.4   0.0    0.0       vmovd	xmm5, dword ptr [rdi + rsi + 4]
39.    10    45.4   1.0    0.0       vpinsrd	xmm4, xmm4, dword ptr [rdi + rcx], 1
40.    10    46.4   2.0    0.0       vpinsrd	xmm5, xmm5, dword ptr [rdi + rcx + 4], 1
41.    10    46.5   1.0    0.0       vpinsrd	xmm4, xmm4, dword ptr [rdi + r8], 2
42.    10    47.4   1.0    0.0       vpinsrd	xmm5, xmm5, dword ptr [rdi + r8 + 4], 2
43.    10    41.5   0.0    6.0       vmovd	xmm6, dword ptr [r13 + r12]
44.    10    45.5   0.0    6.0       lea	rsi, [rdi + r9]
45.    10    46.6   4.0    0.0       vpinsrd	xmm6, xmm6, dword ptr [r13 + rax], 1
46.    10    47.5   0.0    0.0       vpinsrd	xmm17, xmm6, dword ptr [r13 + rbx], 2
47.    10    3.8    3.8    44.8      vcmpleps	k1, xmm15, xmm2
48.    10    7.8    0.0    40.8      vcmpleps	k1 {k1}, xmm2, xmm9
49.    10    46.7   3.0    0.0       vpinsrd	xmm14, xmm4, dword ptr [rdi + r9], 3
50.    10    10.8   0.0    37.8      vcmpleps	k1 {k1}, xmm15, xmm1
51.    10    14.8   0.0    33.8      vcmpleps	k1 {k1}, xmm1, xmm9
52.    10    46.7   3.0    0.0       vpinsrd	xmm11, xmm5, dword ptr [rdi + r9 + 4], 3
53.    10    16.8   1.8    31.9      vsubps	xmm4, xmm3, xmm31
54.    10    19.6   0.0    29.1      vsubps	xmm5, xmm7, xmm13
55.    10    46.7   2.0    0.0       vpinsrd	xmm17, xmm17, dword ptr [r13 + rsi], 3
56.    10    1.9    1.9    43.8      vpbroadcastw	xmm31, word ptr [rip + .LCPI3_16]
57.    10    49.8   0.0    1.0       vpandq	xmm7, xmm14, xmm31
58.    10    50.8   0.0    0.0       vpmullw	xmm12, xmm7, xmm7
59.    10    48.8   0.0    5.0       vpsrlw	xmm7, xmm14, 8
60.    10    49.8   0.0    0.0       vpmullw	xmm13, xmm7, xmm7
61.    10    17.9   0.0    32.9      vsubps	xmm7, xmm9, xmm4
62.    10    53.9   0.0    0.0       vpsrld	xmm3, xmm12, 16
63.    10    19.8   0.0    31.1      vsubps	xmm1, xmm9, xmm5
64.    10    22.9   0.0    27.1      vmulps	xmm18, xmm1, xmm7
65.    10    22.8   0.0    27.1      vmulps	xmm1, xmm4, xmm1
66.    10    53.0   0.0    0.0       vcvtdq2ps	xmm3, xmm3
67.    10    19.1   0.0    33.9      vmulps	xmm7, xmm5, xmm7
68.    10    17.0   0.0    35.1      vmulps	xmm4, xmm5, xmm4
69.    10    55.2   0.0    0.0       vmulps	xmm5, xmm18, xmm3
70.    10    55.1   0.0    0.0       vmulps	xmm16, xmm1, xmm3
71.    10    58.1   0.0    0.0       vaddps	xmm5, xmm5, xmm16
72.    10    44.9   1.0    16.0      vpsrlw	xmm2, xmm11, 8
73.    10    45.9   0.0    11.0      vpmullw	xmm2, xmm2, xmm2
74.    10    47.9   0.0    12.0      vpblendw	xmm6, xmm13, xmm15, 170
75.    10    48.9   0.0    8.0       vcvtdq2ps	xmm6, xmm6
76.    10    49.8   0.0    10.0      vpblendw	xmm2, xmm2, xmm15, 170
77.    10    49.7   0.0    6.0       vcvtdq2ps	xmm2, xmm2
78.    10    51.7   1.0    3.0       vmulps	xmm6, xmm18, xmm6
79.    10    51.8   0.0    2.0       vmulps	xmm2, xmm1, xmm2
80.    10    55.7   0.0    0.0       vaddps	xmm2, xmm6, xmm2
81.    10    49.8   1.0    5.0       vmulps	xmm6, xmm7, xmm3
82.    10    56.5   0.0    0.0       vaddps	xmm5, xmm6, xmm5
83.    10    39.4   0.0    20.0      vpsrlw	xmm6, xmm17, 8
84.    10    39.2   0.0    15.0      vpmullw	xmm6, xmm6, xmm6
85.    10    45.2   1.0    13.0      vpblendw	xmm6, xmm6, xmm15, 170
86.    10    45.2   0.0    9.0       vcvtdq2ps	xmm6, xmm6
87.    10    49.2   0.0    5.0       vmulps	xmm6, xmm7, xmm6
88.    10    55.0   0.0    0.0       vaddps	xmm16, xmm6, xmm2
89.    10    33.1   0.0    23.0      vpandq	xmm6, xmm11, xmm31
90.    10    34.9   2.0    16.0      vpmullw	xmm6, xmm6, xmm6
91.    10    35.1   1.0    17.0      vpblendw	xmm2, xmm12, xmm15, 170
92.    10    36.1   0.0    13.0      vcvtdq2ps	xmm2, xmm2
93.    10    37.0   1.0    14.0      vpblendw	xmm6, xmm6, xmm15, 170
94.    10    39.9   2.0    8.0       vcvtdq2ps	xmm6, xmm6
95.    10    40.0   2.0    7.0       vmulps	xmm2, xmm18, xmm2
96.    10    42.0   0.0    4.0       vmulps	xmm6, xmm1, xmm6
97.    10    45.1   0.0    0.0       vaddps	xmm2, xmm2, xmm6
98.    10    10.1   0.0    34.0      vmovd	xmm6, dword ptr [r13 + r12 + 4]
99.    10    21.0   9.0    22.0      vpinsrd	xmm6, xmm6, dword ptr [r13 + rax + 4], 1
100.   10    20.0   0.0    21.0      vpinsrd	xmm6, xmm6, dword ptr [r13 + rbx + 4], 2
101.   10    19.0   0.0    20.0      vpinsrd	xmm6, xmm6, dword ptr [r13 + rsi + 4], 3
102.   10    32.0   4.0    6.0       vmulps	xmm3, xmm4, xmm3
103.   10    40.0   0.0    0.0       vaddps	xmm12, xmm3, xmm5
104.   10    18.0   0.0    24.0      vpandq	xmm5, xmm17, xmm31
105.   10    19.0   1.0    18.0      vpmullw	xmm5, xmm5, xmm5
106.   10    26.0   2.0    15.0      vpblendw	xmm5, xmm5, xmm15, 170
107.   10    31.0   4.0    7.0       vcvtdq2ps	xmm5, xmm5
108.   10    34.0   0.0    3.0       vmulps	xmm5, xmm7, xmm5
109.   10    39.0   0.0    0.0       vaddps	xmm2, xmm5, xmm2
110.   10    19.0   0.0    23.0      vpsrlw	xmm5, xmm6, 8
111.   10    19.0   0.0    18.0      vpmullw	xmm5, xmm5, xmm5
112.   10    25.0   1.0    16.0      vpblendw	xmm5, xmm5, xmm15, 170
113.   10    28.0   3.0    9.0       vcvtdq2ps	xmm5, xmm5
114.   10    32.0   0.0    5.0       vmulps	xmm5, xmm4, xmm5
115.   10    36.0   0.0    0.0       vaddps	xmm5, xmm5, xmm16
116.   10    15.0   5.0    23.0      vpsrld	xmm3, xmm14, 24
117.   10    18.0   2.0    17.0      vcvtdq2ps	xmm3, xmm3
118.   10    27.0   6.0    7.0       vmulps	xmm3, xmm18, xmm3
119.   10    17.0   8.0    19.0      vpsrld	xmm0, xmm11, 24
120.   10    17.0   0.0    15.0      vcvtdq2ps	xmm0, xmm0
121.   10    24.0   4.0    7.0       vmulps	xmm0, xmm1, xmm0
122.   10    27.0   0.0    3.0       vaddps	xmm0, xmm3, xmm0
123.   10    23.0   17.0   9.0       vpsrld	xmm1, xmm17, 24
124.   10    25.0   2.0    3.0       vcvtdq2ps	xmm1, xmm1
125.   10    28.0   0.0    0.0       vmulps	xmm1, xmm7, xmm1
126.   10    6.0    0.0    24.0      vpandq	xmm3, xmm6, xmm31
127.   10    23.0   17.0   2.0       vpmullw	xmm3, xmm3, xmm3
128.   10    28.0   0.0    1.0       vpblendw	xmm3, xmm3, xmm15, 170
129.   10    28.0   0.0    0.0       vcvtdq2ps	xmm3, xmm3
130.   10    32.0   0.0    0.0       vmulps	xmm3, xmm4, xmm3
131.   10    36.0   0.0    0.0       vaddps	xmm2, xmm3, xmm2
132.   10    28.0   0.0    7.0       vaddps	xmm0, xmm1, xmm0
133.   10    22.0   19.0   16.0      vpsrld	xmm1, xmm6, 24
134.   10    24.0   1.0    11.0      vcvtdq2ps	xmm1, xmm1
135.   10    24.0   0.0    10.0      vmulps	xmm3, xmm20, xmm12
136.   10    26.0   0.0    8.0       vmulps	xmm5, xmm21, xmm5
137.   10    26.0   0.0    7.0       vmulps	xmm1, xmm4, xmm1
138.   10    30.0   0.0    3.0       vaddps	xmm0, xmm1, xmm0
139.   10    36.0   0.0    0.0       vmulps	xmm1, xmm22, xmm2
140.   10    33.0   0.0    3.0       vmulps	xmm16, xmm19, xmm0
141.   10    1.0    1.0    33.0      vbroadcastss	xmm0, dword ptr [rip + .LCPI3_20]
142.   10    25.0   0.0    10.0      vcmpordps	k2, xmm3, xmm3
143.   10    29.0   0.0    6.0       vmaxps	xmm2 {k2} {z}, xmm15, xmm3
144.   10    33.0   0.0    2.0       vminps	xmm3, xmm0, xmm2
145.   10    27.0   0.0    8.0       vcmpordps	k2, xmm5, xmm5
146.   10    32.0   0.0    2.0       vcmpunordps	k3, xmm2, xmm2
147.   10    30.0   0.0    4.0       vmaxps	xmm2 {k2} {z}, xmm15, xmm5
148.   10    34.0   0.0    0.0       vminps	xmm5, xmm0, xmm2
149.   10    37.0   0.0    0.0       vcmpordps	k2, xmm1, xmm1
150.   10    35.0   0.0    5.0       vmovaps	xmm3 {k3}, xmm0
151.   10    41.0   0.0    0.0       vmaxps	xmm1 {k2} {z}, xmm15, xmm1
152.   10    32.0   0.0    8.0       vcmpunordps	k2, xmm2, xmm2
153.   10    44.0   0.0    0.0       vminps	xmm7, xmm0, xmm1
154.   10    36.0   0.0    11.0      vmovaps	xmm5 {k2}, xmm0
155.   10    43.0   0.0    0.0       vcmpunordps	k2, xmm1, xmm1
156.   10    28.0   0.0    9.0       vmulps	xmm1, xmm16, dword ptr [rip + .LCPI3_21]{1to4}
157.   10    47.0   0.0    0.0       vmovaps	xmm7 {k2}, xmm0
158.   10    1.0    1.0    40.0      vmovdqu	xmm6, xmmword ptr [rdx]
159.   10    37.0   0.0    6.0       vaddps	xmm4, xmm9, xmm1
160.   10    7.0    0.0    39.0      vpshufb	xmm0, xmm6, xmm10
161.   10    12.0   5.0    30.0      vcvtdq2ps	xmm0, xmm0
162.   10    16.0   0.0    26.0      vmulps	xmm0, xmm0, xmm0
163.   10    40.0   0.0    2.0       vmulps	xmm0, xmm0, xmm4
164.   10    44.0   0.0    0.0       vaddps	xmm1, xmm0, xmm3
165.   10    1.0    1.0    39.0      vpshufb	xmm0, xmm6, xmmword ptr [rip + .LCPI3_18]
166.   10    14.0   6.0    29.0      vcvtdq2ps	xmm0, xmm0
167.   10    17.0   0.0    25.0      vmulps	xmm0, xmm0, xmm0
168.   10    38.0   0.0    4.0       vmulps	xmm0, xmm0, xmm4
169.   10    42.0   0.0    0.0       vaddps	xmm2, xmm0, xmm5
170.   10    1.0    1.0    37.0      vpandd	xmm0, xmm6, dword ptr [rip + .LCPI3_17]{1to4}
171.   10    13.0   5.0    28.0      vcvtdq2ps	xmm0, xmm0
172.   10    16.0   0.0    24.0      vmulps	xmm0, xmm0, xmm0
173.   10    37.0   1.0    3.0       vmulps	xmm0, xmm0, xmm4
174.   10    42.0   0.0    0.0       vaddps	xmm3, xmm0, xmm7
175.   10    43.0   0.0    1.0       vmovaps	xmm0, xmm1
176.   10    44.0   0.0    0.0       rsqrtps	xmm0, xmm0
177.   10    47.0   0.0    0.0       vmulps	xmm1, xmm0, xmm1
178.   10    42.0   0.0    8.0       vmovaps	xmm0, xmm2
179.   10    44.0   1.0    3.0       rsqrtps	xmm0, xmm0
180.   10    47.0   0.0    0.0       vmulps	xmm2, xmm0, xmm2
181.   10    43.0   0.0    7.0       vmovaps	xmm0, xmm3
182.   10    43.0   0.0    3.0       rsqrtps	xmm0, xmm0
183.   10    47.0   0.0    0.0       vmulps	xmm3, xmm0, xmm3
184.   10    48.0   0.0    1.0       vmovaps	xmm0, xmm1
185.   10    49.0   0.0    0.0       cvtps2dq	xmm0, xmm0
186.   10    52.0   0.0    0.0       vmovdqa	xmm1, xmm0
187.   10    48.0   0.0    4.0       vmovaps	xmm0, xmm2
188.   10    48.0   0.0    0.0       cvtps2dq	xmm0, xmm0
189.   10    52.0   0.0    0.0       vmovdqa	xmm2, xmm0
190.   10    47.0   0.0    4.0       vmovaps	xmm0, xmm3
191.   10    48.0   0.0    0.0       cvtps2dq	xmm0, xmm0
192.   10    50.0   0.0    0.0       vpslld	xmm1, xmm1, 16
193.   10    51.0   0.0    0.0       vpslld	xmm2, xmm2, 8
194.   10    51.0   0.0    0.0       vpternlogd	xmm2, xmm0, xmm1, 254
195.   10    5.0    5.0    46.0      vpsrld	xmm0, xmm6, 24
196.   10    5.0    0.0    42.0      vcvtdq2ps	xmm0, xmm0
197.   10    27.0   2.0    20.0      vmulps	xmm0, xmm4, xmm0
198.   10    30.0   0.0    16.0      vaddps	xmm0, xmm16, xmm0
199.   10    0.0    0.0    50.0      vxorps	xmm16, xmm16, xmm16
200.   10    34.0   0.0    12.0      cvtps2dq	xmm0, xmm0
201.   10    38.0   0.0    11.0      vpslld	xmm0, xmm0, 24
202.   10    49.0   0.0    0.0       vpord	xmm6 {k1}, xmm2, xmm0
203.   10    50.0   0.0    0.0       vmovdqu	xmmword ptr [rdx], xmm6
204.   10    3.0    3.0    37.0      vaddps	xmm24, xmm24, dword ptr [rip + .LCPI3_22]{1to4}
205.   10    1.0    1.0    48.0      add	rdx, 16
       10    33.0   0.9    10.9      <total>
```

</details>
</details>

### Performance check for after fillRect

<details><summary>[0] Code Region - ProcessPixel</summary>

```
Iterations:        100
Instructions:      21200
Total Cycles:      11139
Total uOps:        23000

Dispatch Width:    6
uOps Per Cycle:    2.06
IPC:               1.90
Block RThroughput: 61.0


Cycles with backend pressure increase [ 91.48% ]
Throughput Bottlenecks: 
  Resource Pressure       [ 52.84% ]
  - ICXPort0  [ 42.09% ]
  - ICXPort1  [ 42.09% ]
  - ICXPort2  [ 2.69% ]
  - ICXPort3  [ 2.69% ]
  - ICXPort5  [ 31.36% ]
  Data Dependencies:      [ 55.63% ]
  - Register Dependencies [ 55.63% ]
  - Memory Dependencies   [ 0.00% ]

```

<details><summary>Critical sequence based on the simulation:</summary>

```

              Instruction                                 Dependency Information
 +----< 211.  vaddps	xmm19, xmm19, xmm2
 |
 |    < loop carried > 
 |
 |      0.    vmulps	xmm0, xmm27, xmm19
 +----> 1.    vmulps	xmm1, xmm7, xmm19                 ## REGISTER dependency:  xmm19
 |      2.    vaddps	xmm26, xmm0, xmmword ptr [rsp + 96]
 +----> 3.    vaddps	xmm15, xmm1, xmmword ptr [rsp + 80] ## RESOURCE interference:  ICXPort0 [ probability: 1% ]
 |      4.    vcmpordps	k1, xmm26, xmm26
 |      5.    vmaxps	xmm0 {k1} {z}, xmm10, xmm26
 |      6.    vminps	xmm1, xmm28, xmm0
 |      7.    vcmpunordps	k1, xmm0, xmm0
 |      8.    vcmpordps	k2, xmm15, xmm15
 +----> 9.    vmaxps	xmm0 {k2} {z}, xmm10, xmm15       ## REGISTER dependency:  xmm15
 |      10.   vmovaps	xmm1 {k1}, xmm28
 |      11.   vminps	xmm2, xmm28, xmm0
 +----> 12.   vcmpunordps	k1, xmm0, xmm0            ## REGISTER dependency:  xmm0
 +----> 13.   vmovaps	xmm2 {k1}, xmm28                  ## REGISTER dependency:  k1
 |      14.   vmulps	xmm0, xmm29, xmm1
 +----> 15.   vmulps	xmm6, xmm18, xmm2                 ## REGISTER dependency:  xmm2
 |      16.   vcvttps2dq	xmm1, xmm0
 +----> 17.   vcvttps2dq	xmm2, xmm6                        ## REGISTER dependency:  xmm6
 |      18.   vcvtdq2ps	xmm3, xmm1
 |      19.   vpslld	xmm1, xmm1, 2
 +----> 20.   vpmulld	xmm7, xmm30, xmm2                 ## REGISTER dependency:  xmm2
 +----> 21.   vpaddd	xmm1, xmm1, xmm7                  ## REGISTER dependency:  xmm7
 |      22.   vpcmpgtd	k1, xmm1, xmm10
 |      23.   vpsubd	xmm7, xmm10, xmm1
 |      24.   vpmovsxdq	ymm7, xmm7
 |      25.   vpsubq	ymm7, ymm5, ymm7
 |      26.   vcvtdq2ps	xmm5, xmm2
 +----> 27.   vpmovsxdq	ymm7 {k1}, xmm1                   ## REGISTER dependency:  xmm1
 +----> 28.   vpextrq	rsi, xmm7, 1                      ## REGISTER dependency:  ymm7
 |      29.   vsubps	xmm3, xmm0, xmm3
 |      30.   vmovq	rdi, xmm7
 +----> 31.   vextracti128	xmm0, ymm7, 1             ## RESOURCE interference:  ICXPort5 [ probability: 100% ]
 +----> 32.   vpextrq	r14, xmm0, 1                      ## REGISTER dependency:  xmm0
 |      33.   lea	rbp, [rcx + rdi]
 |      34.   vmovd	xmm1, dword ptr [rcx + rdi]
 |      35.   vpinsrd	xmm1, xmm1, dword ptr [rcx + rsi], 1
 +----> 36.   vmovq	rbx, xmm0                         ## RESOURCE interference:  ICXPort0 [ probability: 100% ]
 |      37.   vmovd	xmm0, dword ptr [rcx + rdi + 4]
 +----> 38.   vpinsrd	xmm1, xmm1, dword ptr [rcx + rbx], 2 ## REGISTER dependency:  rbx
 |      39.   vpinsrd	xmm0, xmm0, dword ptr [rcx + rsi + 4], 1
 +----> 40.   vpinsrd	xmm0, xmm0, dword ptr [rcx + rbx + 4], 2 ## RESOURCE interference:  ICXPort5 [ probability: 100% ]
 |      41.   lea	rdi, [rcx + rsi]
 |      42.   vmovd	xmm7, dword ptr [rdx + rbp]
 +----> 43.   vpinsrd	xmm2, xmm1, dword ptr [rcx + r14], 3 ## RESOURCE interference:  ICXPort5 [ probability: 100% ]
 |      44.   vpinsrd	xmm7, xmm7, dword ptr [rdx + rdi], 1
 |      45.   vmovaps	xmm25, xmm21
 |      46.   vpinsrd	xmm21, xmm0, dword ptr [rcx + r14 + 4], 3
 |      47.   lea	rbx, [rcx + rbx]
 |      48.   vpinsrd	xmm0, xmm7, dword ptr [rdx + rbx], 2
 |      49.   vsubps	xmm5, xmm6, xmm5
 |      50.   lea	rsi, [rcx + r14]
 |      51.   vmovaps	xmm23, xmm20
 |      52.   vpinsrd	xmm20, xmm0, dword ptr [rdx + rsi], 3
 +----> 53.   vpand	xmm6, xmm9, xmm2                  ## REGISTER dependency:  xmm2
 |      54.   vmovaps	xmm22, xmm8
 +----> 55.   vpmullw	xmm8, xmm6, xmm6                  ## REGISTER dependency:  xmm6
 |      56.   vpsrlw	xmm6, xmm2, 8
 |      57.   vpmullw	xmm1, xmm6, xmm6
 +----> 58.   vpsrld	xmm6, xmm8, 16                    ## REGISTER dependency:  xmm8
 |      59.   vsubps	xmm7, xmm28, xmm3
 |      60.   vsubps	xmm31, xmm28, xmm5
 |      61.   vmovaps	xmm24, xmm16
 |      62.   vmulps	xmm16, xmm31, xmm7
 +----> 63.   vcvtdq2ps	xmm6, xmm6                        ## REGISTER dependency:  xmm6
 |      64.   vmulps	xmm4, xmm3, xmm31
 |      65.   vmulps	xmm7, xmm5, xmm7
 |      66.   vmulps	xmm3, xmm5, xmm3
 |      67.   vmulps	xmm5, xmm16, xmm6
 |      68.   vmulps	xmm0, xmm4, xmm6
 |      69.   vaddps	xmm0, xmm5, xmm0
 |      70.   vmulps	xmm5, xmm7, xmm6
 |      71.   vaddps	xmm0, xmm5, xmm0
 |      72.   vpsrlw	xmm5, xmm21, 8
 |      73.   vpmullw	xmm5, xmm5, xmm5
 |      74.   vpblendw	xmm1, xmm1, xmm10, 170
 |      75.   vcvtdq2ps	xmm1, xmm1
 |      76.   vpblendw	xmm5, xmm5, xmm10, 170
 |      77.   vcvtdq2ps	xmm5, xmm5
 |      78.   vmulps	xmm1, xmm16, xmm1
 |      79.   vmulps	xmm5, xmm4, xmm5
 |      80.   vaddps	xmm1, xmm1, xmm5
 |      81.   vpsrlw	xmm5, xmm20, 8
 |      82.   vpmullw	xmm5, xmm5, xmm5
 |      83.   vpblendw	xmm5, xmm5, xmm10, 170
 |      84.   vcvtdq2ps	xmm5, xmm5
 |      85.   vmulps	xmm5, xmm7, xmm5
 |      86.   vaddps	xmm1, xmm1, xmm5
 |      87.   vmovd	xmm5, dword ptr [rdx + rbp + 4]
 |      88.   vpinsrd	xmm5, xmm5, dword ptr [rdx + rdi + 4], 1
 |      89.   vpinsrd	xmm5, xmm5, dword ptr [rdx + rbx + 4], 2
 |      90.   vpinsrd	xmm5, xmm5, dword ptr [rdx + rsi + 4], 3
 |      91.   vmulps	xmm6, xmm3, xmm6
 |      92.   vaddps	xmm0, xmm6, xmm0
 |      93.   vpsrlw	xmm6, xmm5, 8
 +----> 94.   vpmullw	xmm6, xmm6, xmm6                  ## RESOURCE interference:  ICXPort0 [ probability: 100% ]
 +----> 95.   vpblendw	xmm6, xmm6, xmm10, 170            ## REGISTER dependency:  xmm6
 +----> 96.   vcvtdq2ps	xmm6, xmm6                        ## REGISTER dependency:  xmm6
 |      97.   vmulps	xmm6, xmm3, xmm6
 |      98.   vaddps	xmm31, xmm1, xmm6
 |      99.   vpandq	xmm1, xmm21, xmm9
 |      100.  vpmullw	xmm1, xmm1, xmm1
 |      101.  vpblendw	xmm6, xmm8, xmm10, 170
 |      102.  vmovaps	xmm8, xmm22
 |      103.  vcvtdq2ps	xmm6, xmm6
 |      104.  vpblendw	xmm1, xmm1, xmm10, 170
 +----> 105.  vcvtdq2ps	xmm1, xmm1                        ## RESOURCE interference:  ICXPort1 [ probability: 100% ]
 +----> 106.  vmulps	xmm6, xmm16, xmm6                 ## RESOURCE interference:  ICXPort1 [ probability: 100% ]
 |      107.  vmulps	xmm1, xmm4, xmm1
 |      108.  vaddps	xmm1, xmm6, xmm1
 |      109.  vpandq	xmm6, xmm20, xmm9
 |      110.  vpmullw	xmm6, xmm6, xmm6
 |      111.  vpblendw	xmm6, xmm6, xmm10, 170
 +----> 112.  vcvtdq2ps	xmm6, xmm6                        ## RESOURCE interference:  ICXPort0 [ probability: 100% ]
 |      113.  vmulps	xmm6, xmm7, xmm6
 |      114.  vaddps	xmm1, xmm1, xmm6
 |      115.  vpand	xmm6, xmm9, xmm5
 |      116.  vpmullw	xmm6, xmm6, xmm6
 |      117.  vpblendw	xmm6, xmm6, xmm10, 170
 +----> 118.  vcvtdq2ps	xmm6, xmm6                        ## RESOURCE interference:  ICXPort1 [ probability: 100% ]
 |      119.  vmulps	xmm6, xmm3, xmm6
 |      120.  vaddps	xmm6, xmm1, xmm6
 |      121.  vpsrld	xmm1, xmm2, 24
 +----> 122.  vcvtdq2ps	xmm1, xmm1                        ## RESOURCE interference:  ICXPort1 [ probability: 100% ]
 +----> 123.  vmulps	xmm1, xmm16, xmm1                 ## REGISTER dependency:  xmm1
 |      124.  vmovaps	xmm16, xmm24
 |      125.  vpsrld	xmm2, xmm21, 24
 |      126.  vmovaps	xmm21, xmm25
 |      127.  vcvtdq2ps	xmm2, xmm2
 |      128.  vmulps	xmm2, xmm4, xmm2
 |      129.  vaddps	xmm1, xmm1, xmm2
 +----> 130.  vpsrld	xmm2, xmm20, 24                   ## RESOURCE interference:  ICXPort0 [ probability: 100% ]
 |      131.  vmovaps	xmm20, xmm23
 +----> 132.  vcvtdq2ps	xmm2, xmm2                        ## REGISTER dependency:  xmm2
 |      133.  vmulps	xmm2, xmm7, xmm2
 +----> 134.  vpsrld	xmm4, xmm5, 24                    ## RESOURCE interference:  ICXPort1 [ probability: 100% ]
 |      135.  vaddps	xmm1, xmm1, xmm2
 |      136.  vmovdqu	xmm5, xmmword ptr [r13 + 4*rax]
 +----> 137.  vcvtdq2ps	xmm2, xmm4                        ## REGISTER dependency:  xmm4
 |      138.  vmulps	xmm2, xmm3, xmm2
 |      139.  vpshufb	xmm3, xmm5, xmm13
 +----> 140.  vcvtdq2ps	xmm3, xmm3                        ## RESOURCE interference:  ICXPort0 [ probability: 100% ]
 |      141.  vmulps	xmm0, xmm23, xmm0
 |      142.  vaddps	xmm1, xmm1, xmm2
 |      143.  vmulps	xmm4, xmm22, xmm1
 |      144.  vcmpordps	k1, xmm0, xmm0
 |      145.  vmaxps	xmm0 {k1} {z}, xmm10, xmm0
 |      146.  vminps	xmm1, xmm14, xmm0
 +----> 147.  vmulps	xmm2, xmm3, xmm3                  ## REGISTER dependency:  xmm3
 |      148.  vcmpunordps	k1, xmm0, xmm0
 |      149.  vmulps	xmm0, xmm4, xmm17
 |      150.  vaddps	xmm7, xmm0, xmm28
 |      151.  vmulps	xmm0, xmm2, xmm7
 |      152.  vmovaps	xmm1 {k1}, xmm14
 |      153.  vaddps	xmm1, xmm1, xmm0
 |      154.  vpshufb	xmm0, xmm5, xmm12
 |      155.  vmulps	xmm2, xmm24, xmm31
 |      156.  vcvtdq2ps	xmm0, xmm0
 |      157.  vcmpordps	k1, xmm2, xmm2
 |      158.  vmaxps	xmm2 {k1} {z}, xmm10, xmm2
 |      159.  vcmpunordps	k1, xmm2, xmm2
 |      160.  vminps	xmm2, xmm14, xmm2
 |      161.  vmovaps	xmm2 {k1}, xmm14
 |      162.  vmulps	xmm0, xmm0, xmm0
 |      163.  vmulps	xmm0, xmm0, xmm7
 |      164.  vaddps	xmm2, xmm0, xmm2
 |      165.  vpand	xmm0, xmm11, xmm5
 +----> 166.  vcvtdq2ps	xmm0, xmm0                        ## RESOURCE interference:  ICXPort1 [ probability: 100% ]
 |      167.  vmulps	xmm3, xmm25, xmm6
 |      168.  vcmpordps	k1, xmm3, xmm3
 |      169.  vmaxps	xmm3 {k1} {z}, xmm10, xmm3
 |      170.  vcmpunordps	k1, xmm3, xmm3
 |      171.  vminps	xmm3, xmm14, xmm3
 |      172.  vmovaps	xmm3 {k1}, xmm14
 |      173.  vmulps	xmm0, xmm0, xmm0
 |      174.  vmulps	xmm0, xmm0, xmm7
 |      175.  vaddps	xmm3, xmm0, xmm3
 |      176.  vmovaps	xmm0, xmm1
 |      177.  rsqrtps	xmm0, xmm0
 |      178.  vmulps	xmm1, xmm0, xmm1
 |      179.  vmovaps	xmm0, xmm2
 |      180.  rsqrtps	xmm0, xmm0
 |      181.  vmulps	xmm2, xmm0, xmm2
 |      182.  vmovaps	xmm0, xmm3
 |      183.  rsqrtps	xmm0, xmm0
 |      184.  vmulps	xmm3, xmm0, xmm3
 |      185.  vmovaps	xmm0, xmm1
 |      186.  cvtps2dq	xmm0, xmm0
 |      187.  vmovdqa	xmm1, xmm0
 |      188.  vmovaps	xmm0, xmm2
 |      189.  cvtps2dq	xmm0, xmm0
 |      190.  vmovdqa	xmm2, xmm0
 |      191.  vmovaps	xmm0, xmm3
 |      192.  cvtps2dq	xmm0, xmm0
 |      193.  vpslld	xmm1, xmm1, 16
 |      194.  vpslld	xmm2, xmm2, 8
 |      195.  vpternlogd	xmm2, xmm0, xmm1, 254
 |      196.  vcmpleps	k1, xmm10, xmm26
 |      197.  vcmpleps	k1 {k1}, xmm26, xmm28
 |      198.  vcmpleps	k1 {k1}, xmm10, xmm15
 |      199.  vcmpleps	k1 {k1}, xmm15, xmm28
 +----> 200.  vpsrld	xmm0, xmm5, 24                    ## RESOURCE interference:  ICXPort1 [ probability: 100% ]
 +----> 201.  vcvtdq2ps	xmm0, xmm0                        ## REGISTER dependency:  xmm0
 +----> 202.  vmulps	xmm0, xmm7, xmm0                  ## REGISTER dependency:  xmm0
 +----> 203.  vaddps	xmm0, xmm4, xmm0                  ## REGISTER dependency:  xmm0
 +----> 204.  cvtps2dq	xmm0, xmm0                        ## REGISTER dependency:  xmm0
 +----> 205.  vpslld	xmm0, xmm0, 24                    ## REGISTER dependency:  xmm0
 +----> 206.  vpord	xmm5 {k1}, xmm2, xmm0             ## REGISTER dependency:  xmm0
 |      207.  vmovaps	xmm2, xmmword ptr [rsp + 48]
 +----> 208.  vmovdqu	xmmword ptr [r13 + 4*rax], xmm5   ## REGISTER dependency:  xmm5
        209.  vpxor	xmm5, xmm5, xmm5
        210.  vmovaps	xmm7, xmmword ptr [rsp + 64]
        211.  vaddps	xmm19, xmm19, xmm2


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
 1      4     0.50                        vmulps	xmm0, xmm27, xmm19
 1      4     0.50                        vmulps	xmm1, xmm7, xmm19
 2      10    0.50    *                   vaddps	xmm26, xmm0, xmmword ptr [rsp + 96]
 2      10    0.50    *                   vaddps	xmm15, xmm1, xmmword ptr [rsp + 80]
 1      4     1.00                        vcmpordps	k1, xmm26, xmm26
 1      4     0.50                        vmaxps	xmm0 {k1} {z}, xmm10, xmm26
 1      4     0.50                        vminps	xmm1, xmm28, xmm0
 1      4     1.00                        vcmpunordps	k1, xmm0, xmm0
 1      4     1.00                        vcmpordps	k2, xmm15, xmm15
 1      4     0.50                        vmaxps	xmm0 {k2} {z}, xmm10, xmm15
 1      1     0.33                        vmovaps	xmm1 {k1}, xmm28
 1      4     0.50                        vminps	xmm2, xmm28, xmm0
 1      4     1.00                        vcmpunordps	k1, xmm0, xmm0
 1      1     0.33                        vmovaps	xmm2 {k1}, xmm28
 1      4     0.50                        vmulps	xmm0, xmm29, xmm1
 1      4     0.50                        vmulps	xmm6, xmm18, xmm2
 1      4     0.50                        vcvttps2dq	xmm1, xmm0
 1      4     0.50                        vcvttps2dq	xmm2, xmm6
 1      4     0.50                        vcvtdq2ps	xmm3, xmm1
 1      1     0.50                        vpslld	xmm1, xmm1, 2
 2      10    1.00                        vpmulld	xmm7, xmm30, xmm2
 1      1     0.33                        vpaddd	xmm1, xmm1, xmm7
 1      4     1.00                        vpcmpgtd	k1, xmm1, xmm10
 1      1     0.33                        vpsubd	xmm7, xmm10, xmm1
 1      3     1.00                        vpmovsxdq	ymm7, xmm7
 1      1     0.33                        vpsubq	ymm7, ymm5, ymm7
 1      4     0.50                        vcvtdq2ps	xmm5, xmm2
 1      3     1.00                        vpmovsxdq	ymm7 {k1}, xmm1
 2      3     1.00                        vpextrq	rsi, xmm7, 1
 1      4     0.50                        vsubps	xmm3, xmm0, xmm3
 1      2     1.00                        vmovq	rdi, xmm7
 1      3     1.00                        vextracti128	xmm0, ymm7, 1
 2      3     1.00                        vpextrq	r14, xmm0, 1
 1      1     0.50                        lea	rbp, [rcx + rdi]
 1      5     0.50    *                   vmovd	xmm1, dword ptr [rcx + rdi]
 2      6     1.00    *                   vpinsrd	xmm1, xmm1, dword ptr [rcx + rsi], 1
 1      2     1.00                        vmovq	rbx, xmm0
 1      5     0.50    *                   vmovd	xmm0, dword ptr [rcx + rdi + 4]
 2      6     1.00    *                   vpinsrd	xmm1, xmm1, dword ptr [rcx + rbx], 2
 2      6     1.00    *                   vpinsrd	xmm0, xmm0, dword ptr [rcx + rsi + 4], 1
 2      6     1.00    *                   vpinsrd	xmm0, xmm0, dword ptr [rcx + rbx + 4], 2
 1      1     0.50                        lea	rdi, [rcx + rsi]
 1      5     0.50    *                   vmovd	xmm7, dword ptr [rdx + rbp]
 2      6     1.00    *                   vpinsrd	xmm2, xmm1, dword ptr [rcx + r14], 3
 2      6     1.00    *                   vpinsrd	xmm7, xmm7, dword ptr [rdx + rdi], 1
 1      1     0.33                        vmovaps	xmm25, xmm21
 2      6     1.00    *                   vpinsrd	xmm21, xmm0, dword ptr [rcx + r14 + 4], 3
 1      1     0.50                        lea	rbx, [rcx + rbx]
 2      6     1.00    *                   vpinsrd	xmm0, xmm7, dword ptr [rdx + rbx], 2
 1      4     0.50                        vsubps	xmm5, xmm6, xmm5
 1      1     0.50                        lea	rsi, [rcx + r14]
 1      1     0.33                        vmovaps	xmm23, xmm20
 2      6     1.00    *                   vpinsrd	xmm20, xmm0, dword ptr [rdx + rsi], 3
 1      1     0.33                        vpand	xmm6, xmm9, xmm2
 1      1     0.33                        vmovaps	xmm22, xmm8
 1      5     0.50                        vpmullw	xmm8, xmm6, xmm6
 1      1     0.50                        vpsrlw	xmm6, xmm2, 8
 1      5     0.50                        vpmullw	xmm1, xmm6, xmm6
 1      1     0.50                        vpsrld	xmm6, xmm8, 16
 1      4     0.50                        vsubps	xmm7, xmm28, xmm3
 1      4     0.50                        vsubps	xmm31, xmm28, xmm5
 1      1     0.33                        vmovaps	xmm24, xmm16
 1      4     0.50                        vmulps	xmm16, xmm31, xmm7
 1      4     0.50                        vcvtdq2ps	xmm6, xmm6
 1      4     0.50                        vmulps	xmm4, xmm3, xmm31
 1      4     0.50                        vmulps	xmm7, xmm5, xmm7
 1      4     0.50                        vmulps	xmm3, xmm5, xmm3
 1      4     0.50                        vmulps	xmm5, xmm16, xmm6
 1      4     0.50                        vmulps	xmm0, xmm4, xmm6
 1      4     0.50                        vaddps	xmm0, xmm5, xmm0
 1      4     0.50                        vmulps	xmm5, xmm7, xmm6
 1      4     0.50                        vaddps	xmm0, xmm5, xmm0
 1      1     0.50                        vpsrlw	xmm5, xmm21, 8
 1      5     0.50                        vpmullw	xmm5, xmm5, xmm5
 1      1     1.00                        vpblendw	xmm1, xmm1, xmm10, 170
 1      4     0.50                        vcvtdq2ps	xmm1, xmm1
 1      1     1.00                        vpblendw	xmm5, xmm5, xmm10, 170
 1      4     0.50                        vcvtdq2ps	xmm5, xmm5
 1      4     0.50                        vmulps	xmm1, xmm16, xmm1
 1      4     0.50                        vmulps	xmm5, xmm4, xmm5
 1      4     0.50                        vaddps	xmm1, xmm1, xmm5
 1      1     0.50                        vpsrlw	xmm5, xmm20, 8
 1      5     0.50                        vpmullw	xmm5, xmm5, xmm5
 1      1     1.00                        vpblendw	xmm5, xmm5, xmm10, 170
 1      4     0.50                        vcvtdq2ps	xmm5, xmm5
 1      4     0.50                        vmulps	xmm5, xmm7, xmm5
 1      4     0.50                        vaddps	xmm1, xmm1, xmm5
 1      5     0.50    *                   vmovd	xmm5, dword ptr [rdx + rbp + 4]
 2      6     1.00    *                   vpinsrd	xmm5, xmm5, dword ptr [rdx + rdi + 4], 1
 2      6     1.00    *                   vpinsrd	xmm5, xmm5, dword ptr [rdx + rbx + 4], 2
 2      6     1.00    *                   vpinsrd	xmm5, xmm5, dword ptr [rdx + rsi + 4], 3
 1      4     0.50                        vmulps	xmm6, xmm3, xmm6
 1      4     0.50                        vaddps	xmm0, xmm6, xmm0
 1      1     0.50                        vpsrlw	xmm6, xmm5, 8
 1      5     0.50                        vpmullw	xmm6, xmm6, xmm6
 1      1     1.00                        vpblendw	xmm6, xmm6, xmm10, 170
 1      4     0.50                        vcvtdq2ps	xmm6, xmm6
 1      4     0.50                        vmulps	xmm6, xmm3, xmm6
 1      4     0.50                        vaddps	xmm31, xmm1, xmm6
 1      1     0.33                        vpandq	xmm1, xmm21, xmm9
 1      5     0.50                        vpmullw	xmm1, xmm1, xmm1
 1      1     1.00                        vpblendw	xmm6, xmm8, xmm10, 170
 1      1     0.33                        vmovaps	xmm8, xmm22
 1      4     0.50                        vcvtdq2ps	xmm6, xmm6
 1      1     1.00                        vpblendw	xmm1, xmm1, xmm10, 170
 1      4     0.50                        vcvtdq2ps	xmm1, xmm1
 1      4     0.50                        vmulps	xmm6, xmm16, xmm6
 1      4     0.50                        vmulps	xmm1, xmm4, xmm1
 1      4     0.50                        vaddps	xmm1, xmm6, xmm1
 1      1     0.33                        vpandq	xmm6, xmm20, xmm9
 1      5     0.50                        vpmullw	xmm6, xmm6, xmm6
 1      1     1.00                        vpblendw	xmm6, xmm6, xmm10, 170
 1      4     0.50                        vcvtdq2ps	xmm6, xmm6
 1      4     0.50                        vmulps	xmm6, xmm7, xmm6
 1      4     0.50                        vaddps	xmm1, xmm1, xmm6
 1      1     0.33                        vpand	xmm6, xmm9, xmm5
 1      5     0.50                        vpmullw	xmm6, xmm6, xmm6
 1      1     1.00                        vpblendw	xmm6, xmm6, xmm10, 170
 1      4     0.50                        vcvtdq2ps	xmm6, xmm6
 1      4     0.50                        vmulps	xmm6, xmm3, xmm6
 1      4     0.50                        vaddps	xmm6, xmm1, xmm6
 1      1     0.50                        vpsrld	xmm1, xmm2, 24
 1      4     0.50                        vcvtdq2ps	xmm1, xmm1
 1      4     0.50                        vmulps	xmm1, xmm16, xmm1
 1      1     0.33                        vmovaps	xmm16, xmm24
 1      1     0.50                        vpsrld	xmm2, xmm21, 24
 1      1     0.33                        vmovaps	xmm21, xmm25
 1      4     0.50                        vcvtdq2ps	xmm2, xmm2
 1      4     0.50                        vmulps	xmm2, xmm4, xmm2
 1      4     0.50                        vaddps	xmm1, xmm1, xmm2
 1      1     0.50                        vpsrld	xmm2, xmm20, 24
 1      1     0.33                        vmovaps	xmm20, xmm23
 1      4     0.50                        vcvtdq2ps	xmm2, xmm2
 1      4     0.50                        vmulps	xmm2, xmm7, xmm2
 1      1     0.50                        vpsrld	xmm4, xmm5, 24
 1      4     0.50                        vaddps	xmm1, xmm1, xmm2
 1      6     0.50    *                   vmovdqu	xmm5, xmmword ptr [r13 + 4*rax]
 1      4     0.50                        vcvtdq2ps	xmm2, xmm4
 1      4     0.50                        vmulps	xmm2, xmm3, xmm2
 1      1     0.50                        vpshufb	xmm3, xmm5, xmm13
 1      4     0.50                        vcvtdq2ps	xmm3, xmm3
 1      4     0.50                        vmulps	xmm0, xmm23, xmm0
 1      4     0.50                        vaddps	xmm1, xmm1, xmm2
 1      4     0.50                        vmulps	xmm4, xmm22, xmm1
 1      4     1.00                        vcmpordps	k1, xmm0, xmm0
 1      4     0.50                        vmaxps	xmm0 {k1} {z}, xmm10, xmm0
 1      4     0.50                        vminps	xmm1, xmm14, xmm0
 1      4     0.50                        vmulps	xmm2, xmm3, xmm3
 1      4     1.00                        vcmpunordps	k1, xmm0, xmm0
 1      4     0.50                        vmulps	xmm0, xmm4, xmm17
 1      4     0.50                        vaddps	xmm7, xmm0, xmm28
 1      4     0.50                        vmulps	xmm0, xmm2, xmm7
 1      1     0.33                        vmovaps	xmm1 {k1}, xmm14
 1      4     0.50                        vaddps	xmm1, xmm1, xmm0
 1      1     0.50                        vpshufb	xmm0, xmm5, xmm12
 1      4     0.50                        vmulps	xmm2, xmm24, xmm31
 1      4     0.50                        vcvtdq2ps	xmm0, xmm0
 1      4     1.00                        vcmpordps	k1, xmm2, xmm2
 1      4     0.50                        vmaxps	xmm2 {k1} {z}, xmm10, xmm2
 1      4     1.00                        vcmpunordps	k1, xmm2, xmm2
 1      4     0.50                        vminps	xmm2, xmm14, xmm2
 1      1     0.33                        vmovaps	xmm2 {k1}, xmm14
 1      4     0.50                        vmulps	xmm0, xmm0, xmm0
 1      4     0.50                        vmulps	xmm0, xmm0, xmm7
 1      4     0.50                        vaddps	xmm2, xmm0, xmm2
 1      1     0.33                        vpand	xmm0, xmm11, xmm5
 1      4     0.50                        vcvtdq2ps	xmm0, xmm0
 1      4     0.50                        vmulps	xmm3, xmm25, xmm6
 1      4     1.00                        vcmpordps	k1, xmm3, xmm3
 1      4     0.50                        vmaxps	xmm3 {k1} {z}, xmm10, xmm3
 1      4     1.00                        vcmpunordps	k1, xmm3, xmm3
 1      4     0.50                        vminps	xmm3, xmm14, xmm3
 1      1     0.33                        vmovaps	xmm3 {k1}, xmm14
 1      4     0.50                        vmulps	xmm0, xmm0, xmm0
 1      4     0.50                        vmulps	xmm0, xmm0, xmm7
 1      4     0.50                        vaddps	xmm3, xmm0, xmm3
 1      1     0.33                        vmovaps	xmm0, xmm1
 1      4     1.00                        rsqrtps	xmm0, xmm0
 1      4     0.50                        vmulps	xmm1, xmm0, xmm1
 1      1     0.33                        vmovaps	xmm0, xmm2
 1      4     1.00                        rsqrtps	xmm0, xmm0
 1      4     0.50                        vmulps	xmm2, xmm0, xmm2
 1      1     0.33                        vmovaps	xmm0, xmm3
 1      4     1.00                        rsqrtps	xmm0, xmm0
 1      4     0.50                        vmulps	xmm3, xmm0, xmm3
 1      1     0.33                        vmovaps	xmm0, xmm1
 1      4     0.50                        cvtps2dq	xmm0, xmm0
 1      1     0.33                        vmovdqa	xmm1, xmm0
 1      1     0.33                        vmovaps	xmm0, xmm2
 1      4     0.50                        cvtps2dq	xmm0, xmm0
 1      1     0.33                        vmovdqa	xmm2, xmm0
 1      1     0.33                        vmovaps	xmm0, xmm3
 1      4     0.50                        cvtps2dq	xmm0, xmm0
 1      1     0.50                        vpslld	xmm1, xmm1, 16
 1      1     0.50                        vpslld	xmm2, xmm2, 8
 1      1     0.33                        vpternlogd	xmm2, xmm0, xmm1, 254
 1      4     1.00                        vcmpleps	k1, xmm10, xmm26
 1      4     1.00                        vcmpleps	k1 {k1}, xmm26, xmm28
 1      4     1.00                        vcmpleps	k1 {k1}, xmm10, xmm15
 1      4     1.00                        vcmpleps	k1 {k1}, xmm15, xmm28
 1      1     0.50                        vpsrld	xmm0, xmm5, 24
 1      4     0.50                        vcvtdq2ps	xmm0, xmm0
 1      4     0.50                        vmulps	xmm0, xmm7, xmm0
 1      4     0.50                        vaddps	xmm0, xmm4, xmm0
 1      4     0.50                        cvtps2dq	xmm0, xmm0
 1      1     0.50                        vpslld	xmm0, xmm0, 24
 1      1     0.33                        vpord	xmm5 {k1}, xmm2, xmm0
 1      6     0.50    *                   vmovaps	xmm2, xmmword ptr [rsp + 48]
 2      1     1.00           *            vmovdqu	xmmword ptr [r13 + 4*rax], xmm5
 1      0     0.17                        vpxor	xmm5, xmm5, xmm5
 1      6     0.50    *                   vmovaps	xmm7, xmmword ptr [rsp + 64]
 1      4     0.50                        vaddps	xmm19, xmm19, xmm2


```
</details>

<details><summary>Dynamic Dispatch Stall Cycles:</summary>

```
RAT     - Register unavailable:                      0
RCU     - Retire tokens unavailable:                 0
SCHEDQ  - Scheduler full:                            10976  (98.5%)
LQ      - Load queue full:                           0
SQ      - Store queue full:                          0
GROUP   - Static restrictions on the dispatch group: 0
USH     - Uncategorised Structural Hazard:           0


```
</details>

<details><summary>Dispatch Logic - number of cycles where we saw N micro opcodes dispatched:</summary>

```
[# dispatched], [# cycles]
 0,              1453  (13.0%)
 1,              2199  (19.7%)
 2,              3389  (30.4%)
 3,              2793  (25.1%)
 4,              993  (8.9%)
 5,              200  (1.8%)
 6,              112  (1.0%)


```
</details>

<details><summary>Schedulers - number of cycles where we saw N micro opcodes issued:</summary>

```
[# issued], [# cycles]
 0,          1428  (12.8%)
 1,          1515  (13.6%)
 2,          4202  (37.7%)
 3,          2995  (26.9%)
 4,          899  (8.1%)
 5,          100  (0.9%)

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
 0,           6527  (58.6%)
 1,           1107  (9.9%)
 2,           1003  (9.0%)
 3,           1001  (9.0%)
 4,           302  (2.7%)
 5,           100  (0.9%)
 6,           400  (3.6%)
 7,           100  (0.9%)
 11,          100  (0.9%)
 15,          200  (1.8%)
 16,          100  (0.9%)
 22,          100  (0.9%)
 24,          99  (0.9%)

```
</details>

<details><summary>Total ROB Entries:                224</summary>

```
Max Used ROB Entries:             123  ( 54.9% )
Average Used ROB Entries per cy:  100  ( 44.6% )


```
</details>

<details><summary>Register File statistics:</summary>

```
Total number of mappings created:    21000
Max number of mappings used:         120


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
 -      -     70.02  73.01  10.50  10.50  1.00   62.97   -     1.00    -      -     

Resource pressure by instruction:
[0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   Instructions:
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm27, xmm19
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm1, xmm7, xmm19
 -      -     0.99   0.01   0.50   0.50    -      -      -      -      -      -     vaddps	xmm26, xmm0, xmmword ptr [rsp + 96]
 -      -     0.01   0.99   0.50   0.50    -      -      -      -      -      -     vaddps	xmm15, xmm1, xmmword ptr [rsp + 80]
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpordps	k1, xmm26, xmm26
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmaxps	xmm0 {k1} {z}, xmm10, xmm26
 -      -      -     1.00    -      -      -      -      -      -      -      -     vminps	xmm1, xmm28, xmm0
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpunordps	k1, xmm0, xmm0
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpordps	k2, xmm15, xmm15
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmaxps	xmm0 {k2} {z}, xmm10, xmm15
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     vmovaps	xmm1 {k1}, xmm28
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vminps	xmm2, xmm28, xmm0
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpunordps	k1, xmm0, xmm0
 -      -     0.01    -      -      -      -     0.99    -      -      -      -     vmovaps	xmm2 {k1}, xmm28
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm29, xmm1
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulps	xmm6, xmm18, xmm2
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvttps2dq	xmm1, xmm0
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vcvttps2dq	xmm2, xmm6
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm3, xmm1
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpslld	xmm1, xmm1, 2
 -      -      -     2.00    -      -      -      -      -      -      -      -     vpmulld	xmm7, xmm30, xmm2
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpaddd	xmm1, xmm1, xmm7
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpcmpgtd	k1, xmm1, xmm10
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpsubd	xmm7, xmm10, xmm1
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpmovsxdq	ymm7, xmm7
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpsubq	ymm7, ymm5, ymm7
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm5, xmm2
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpmovsxdq	ymm7 {k1}, xmm1
 -      -     1.00    -      -      -      -     1.00    -      -      -      -     vpextrq	rsi, xmm7, 1
 -      -      -     1.00    -      -      -      -      -      -      -      -     vsubps	xmm3, xmm0, xmm3
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmovq	rdi, xmm7
 -      -      -      -      -      -      -     1.00    -      -      -      -     vextracti128	xmm0, ymm7, 1
 -      -     1.00    -      -      -      -     1.00    -      -      -      -     vpextrq	r14, xmm0, 1
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	rbp, [rcx + rdi]
 -      -      -      -     0.50   0.50    -      -      -      -      -      -     vmovd	xmm1, dword ptr [rcx + rdi]
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpinsrd	xmm1, xmm1, dword ptr [rcx + rsi], 1
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmovq	rbx, xmm0
 -      -      -      -     0.50   0.50    -      -      -      -      -      -     vmovd	xmm0, dword ptr [rcx + rdi + 4]
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpinsrd	xmm1, xmm1, dword ptr [rcx + rbx], 2
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpinsrd	xmm0, xmm0, dword ptr [rcx + rsi + 4], 1
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpinsrd	xmm0, xmm0, dword ptr [rcx + rbx + 4], 2
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	rdi, [rcx + rsi]
 -      -      -      -     0.50   0.50    -      -      -      -      -      -     vmovd	xmm7, dword ptr [rdx + rbp]
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpinsrd	xmm2, xmm1, dword ptr [rcx + r14], 3
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpinsrd	xmm7, xmm7, dword ptr [rdx + rdi], 1
 -      -     0.99    -      -      -      -     0.01    -      -      -      -     vmovaps	xmm25, xmm21
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpinsrd	xmm21, xmm0, dword ptr [rcx + r14 + 4], 3
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	rbx, [rcx + rbx]
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpinsrd	xmm0, xmm7, dword ptr [rdx + rbx], 2
 -      -     1.00    -      -      -      -      -      -      -      -      -     vsubps	xmm5, xmm6, xmm5
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	rsi, [rcx + r14]
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovaps	xmm23, xmm20
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpinsrd	xmm20, xmm0, dword ptr [rdx + rsi], 3
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpand	xmm6, xmm9, xmm2
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmovaps	xmm22, xmm8
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpmullw	xmm8, xmm6, xmm6
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpsrlw	xmm6, xmm2, 8
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpmullw	xmm1, xmm6, xmm6
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpsrld	xmm6, xmm8, 16
 -      -      -     1.00    -      -      -      -      -      -      -      -     vsubps	xmm7, xmm28, xmm3
 -      -     1.00    -      -      -      -      -      -      -      -      -     vsubps	xmm31, xmm28, xmm5
 -      -     0.01    -      -      -      -     0.99    -      -      -      -     vmovaps	xmm24, xmm16
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm16, xmm31, xmm7
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm6, xmm6
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm4, xmm3, xmm31
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm7, xmm5, xmm7
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm3, xmm5, xmm3
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm5, xmm16, xmm6
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm4, xmm6
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm0, xmm5, xmm0
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm5, xmm7, xmm6
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm0, xmm5, xmm0
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpsrlw	xmm5, xmm21, 8
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpmullw	xmm5, xmm5, xmm5
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm1, xmm1, xmm10, 170
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm1, xmm1
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm5, xmm5, xmm10, 170
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm5, xmm5
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm1, xmm16, xmm1
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm5, xmm4, xmm5
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm1, xmm1, xmm5
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpsrlw	xmm5, xmm20, 8
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpmullw	xmm5, xmm5, xmm5
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm5, xmm5, xmm10, 170
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm5, xmm5
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm5, xmm7, xmm5
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm1, xmm1, xmm5
 -      -      -      -     0.50   0.50    -      -      -      -      -      -     vmovd	xmm5, dword ptr [rdx + rbp + 4]
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpinsrd	xmm5, xmm5, dword ptr [rdx + rdi + 4], 1
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpinsrd	xmm5, xmm5, dword ptr [rdx + rbx + 4], 2
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpinsrd	xmm5, xmm5, dword ptr [rdx + rsi + 4], 3
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm6, xmm3, xmm6
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm0, xmm6, xmm0
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpsrlw	xmm6, xmm5, 8
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpmullw	xmm6, xmm6, xmm6
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm6, xmm6, xmm10, 170
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm6, xmm6
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm6, xmm3, xmm6
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm31, xmm1, xmm6
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpandq	xmm1, xmm21, xmm9
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpmullw	xmm1, xmm1, xmm1
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm6, xmm8, xmm10, 170
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmovaps	xmm8, xmm22
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm6, xmm6
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm1, xmm1, xmm10, 170
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm1, xmm1
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm6, xmm16, xmm6
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm1, xmm4, xmm1
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm1, xmm6, xmm1
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpandq	xmm6, xmm20, xmm9
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpmullw	xmm6, xmm6, xmm6
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm6, xmm6, xmm10, 170
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm6, xmm6
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm6, xmm7, xmm6
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm1, xmm1, xmm6
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpand	xmm6, xmm9, xmm5
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpmullw	xmm6, xmm6, xmm6
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm6, xmm6, xmm10, 170
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm6, xmm6
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm6, xmm3, xmm6
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm6, xmm1, xmm6
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpsrld	xmm1, xmm2, 24
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm1, xmm1
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm1, xmm16, xmm1
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovaps	xmm16, xmm24
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpsrld	xmm2, xmm21, 24
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovaps	xmm21, xmm25
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm2, xmm2
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm2, xmm4, xmm2
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm1, xmm1, xmm2
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpsrld	xmm2, xmm20, 24
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovaps	xmm20, xmm23
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm2, xmm2
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm2, xmm7, xmm2
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpsrld	xmm4, xmm5, 24
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm1, xmm1, xmm2
 -      -      -      -     0.50   0.50    -      -      -      -      -      -     vmovdqu	xmm5, xmmword ptr [r13 + 4*rax]
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm2, xmm4
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm2, xmm3, xmm2
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpshufb	xmm3, xmm5, xmm13
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm3, xmm3
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm23, xmm0
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm1, xmm1, xmm2
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm4, xmm22, xmm1
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpordps	k1, xmm0, xmm0
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmaxps	xmm0 {k1} {z}, xmm10, xmm0
 -      -     1.00    -      -      -      -      -      -      -      -      -     vminps	xmm1, xmm14, xmm0
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm2, xmm3, xmm3
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpunordps	k1, xmm0, xmm0
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm4, xmm17
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vaddps	xmm7, xmm0, xmm28
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm2, xmm7
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmovaps	xmm1 {k1}, xmm14
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vaddps	xmm1, xmm1, xmm0
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpshufb	xmm0, xmm5, xmm12
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm2, xmm24, xmm31
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm0, xmm0
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpordps	k1, xmm2, xmm2
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmaxps	xmm2 {k1} {z}, xmm10, xmm2
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpunordps	k1, xmm2, xmm2
 -      -     1.00    -      -      -      -      -      -      -      -      -     vminps	xmm2, xmm14, xmm2
 -      -     0.01    -      -      -      -     0.99    -      -      -      -     vmovaps	xmm2 {k1}, xmm14
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm0, xmm0, xmm0
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm0, xmm7
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vaddps	xmm2, xmm0, xmm2
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpand	xmm0, xmm11, xmm5
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm0, xmm0
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm3, xmm25, xmm6
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpordps	k1, xmm3, xmm3
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmaxps	xmm3 {k1} {z}, xmm10, xmm3
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpunordps	k1, xmm3, xmm3
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vminps	xmm3, xmm14, xmm3
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovaps	xmm3 {k1}, xmm14
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm0, xmm0
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm0, xmm7
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vaddps	xmm3, xmm0, xmm3
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovaps	xmm0, xmm1
 -      -     1.00    -      -      -      -      -      -      -      -      -     rsqrtps	xmm0, xmm0
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmulps	xmm1, xmm0, xmm1
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmovaps	xmm0, xmm2
 -      -     1.00    -      -      -      -      -      -      -      -      -     rsqrtps	xmm0, xmm0
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmulps	xmm2, xmm0, xmm2
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovaps	xmm0, xmm3
 -      -     1.00    -      -      -      -      -      -      -      -      -     rsqrtps	xmm0, xmm0
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulps	xmm3, xmm0, xmm3
 -      -     0.99    -      -      -      -     0.01    -      -      -      -     vmovaps	xmm0, xmm1
 -      -      -     1.00    -      -      -      -      -      -      -      -     cvtps2dq	xmm0, xmm0
 -      -     0.01    -      -      -      -     0.99    -      -      -      -     vmovdqa	xmm1, xmm0
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovaps	xmm0, xmm2
 -      -     1.00    -      -      -      -      -      -      -      -      -     cvtps2dq	xmm0, xmm0
 -      -     0.99    -      -      -      -     0.01    -      -      -      -     vmovdqa	xmm2, xmm0
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovaps	xmm0, xmm3
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     cvtps2dq	xmm0, xmm0
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpslld	xmm1, xmm1, 16
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpslld	xmm2, xmm2, 8
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpternlogd	xmm2, xmm0, xmm1, 254
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpleps	k1, xmm10, xmm26
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpleps	k1 {k1}, xmm26, xmm28
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpleps	k1 {k1}, xmm10, xmm15
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpleps	k1 {k1}, xmm15, xmm28
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpsrld	xmm0, xmm5, 24
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm0, xmm0
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm7, xmm0
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vaddps	xmm0, xmm4, xmm0
 -      -      -     1.00    -      -      -      -      -      -      -      -     cvtps2dq	xmm0, xmm0
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vpslld	xmm0, xmm0, 24
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     vpord	xmm5 {k1}, xmm2, xmm0
 -      -      -      -     0.50   0.50    -      -      -      -      -      -     vmovaps	xmm2, xmmword ptr [rsp + 48]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     vmovdqu	xmmword ptr [r13 + 4*rax], xmm5
 -      -      -      -      -      -      -      -      -      -      -      -     vpxor	xmm5, xmm5, xmm5
 -      -      -      -     0.50   0.50    -      -      -      -      -      -     vmovaps	xmm7, xmmword ptr [rsp + 64]
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm19, xmm19, xmm2


```
</details>

<details><summary>Timeline view:</summary>

```
                    0123456789          0123456789          0123456789          0123456789
Index     0123456789          0123456789          0123456789          0123456789          

[0,0]     DeeeeER   .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   vmulps	xmm0, xmm27, xmm19
[0,1]     DeeeeER   .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   vmulps	xmm1, xmm7, xmm19
[0,2]     D=eeeeeeeeeeER .    .    .    .    .    .    .    .    .    .    .    .    .   .   vaddps	xmm26, xmm0, xmmword ptr [rsp + 96]
[0,3]     D=eeeeeeeeeeER .    .    .    .    .    .    .    .    .    .    .    .    .   .   vaddps	xmm15, xmm1, xmmword ptr [rsp + 80]
[0,4]     .D==========eeeeER  .    .    .    .    .    .    .    .    .    .    .    .   .   vcmpordps	k1, xmm26, xmm26
[0,5]     .D==============eeeeER   .    .    .    .    .    .    .    .    .    .    .   .   vmaxps	xmm0 {k1} {z}, xmm10, xmm26
[0,6]     .D==================eeeeER    .    .    .    .    .    .    .    .    .    .   .   vminps	xmm1, xmm28, xmm0
[0,7]     .D==================eeeeER    .    .    .    .    .    .    .    .    .    .   .   vcmpunordps	k1, xmm0, xmm0
[0,8]     .D===========eeeeE-------R    .    .    .    .    .    .    .    .    .    .   .   vcmpordps	k2, xmm15, xmm15
[0,9]     .D===============eeeeE---R    .    .    .    .    .    .    .    .    .    .   .   vmaxps	xmm0 {k2} {z}, xmm10, xmm15
[0,10]    . D=====================eER   .    .    .    .    .    .    .    .    .    .   .   vmovaps	xmm1 {k1}, xmm28
[0,11]    . D==================eeeeER   .    .    .    .    .    .    .    .    .    .   .   vminps	xmm2, xmm28, xmm0
[0,12]    . D==================eeeeER   .    .    .    .    .    .    .    .    .    .   .   vcmpunordps	k1, xmm0, xmm0
[0,13]    . D======================eER  .    .    .    .    .    .    .    .    .    .   .   vmovaps	xmm2 {k1}, xmm28
[0,14]    . D======================eeeeER    .    .    .    .    .    .    .    .    .   .   vmulps	xmm0, xmm29, xmm1
[0,15]    . D=======================eeeeER   .    .    .    .    .    .    .    .    .   .   vmulps	xmm6, xmm18, xmm2
[0,16]    .  D=========================eeeeER.    .    .    .    .    .    .    .    .   .   vcvttps2dq	xmm1, xmm0
[0,17]    .  D==========================eeeeER    .    .    .    .    .    .    .    .   .   vcvttps2dq	xmm2, xmm6
[0,18]    .  D=============================eeeeER .    .    .    .    .    .    .    .   .   vcvtdq2ps	xmm3, xmm1
[0,19]    .  D=============================eE---R .    .    .    .    .    .    .    .   .   vpslld	xmm1, xmm1, 2
[0,20]    .  D==============================eeeeeeeeeeER    .    .    .    .    .    .   .   vpmulld	xmm7, xmm30, xmm2
[0,21]    .   D=======================================eER   .    .    .    .    .    .   .   vpaddd	xmm1, xmm1, xmm7
[0,22]    .   D========================================eeeeER    .    .    .    .    .   .   vpcmpgtd	k1, xmm1, xmm10
[0,23]    .   D========================================eE---R    .    .    .    .    .   .   vpsubd	xmm7, xmm10, xmm1
[0,24]    .   D=========================================eeeER    .    .    .    .    .   .   vpmovsxdq	ymm7, xmm7
[0,25]    .   D============================================eER   .    .    .    .    .   .   vpsubq	ymm7, ymm5, ymm7
[0,26]    .   D=============================eeeeE------------R   .    .    .    .    .   .   vcvtdq2ps	xmm5, xmm2
[0,27]    .    D============================================eeeER.    .    .    .    .   .   vpmovsxdq	ymm7 {k1}, xmm1
[0,28]    .    D===============================================eeeER  .    .    .    .   .   vpextrq	rsi, xmm7, 1
[0,29]    .    D===============================eeeeE---------------R  .    .    .    .   .   vsubps	xmm3, xmm0, xmm3
[0,30]    .    D================================================eeER  .    .    .    .   .   vmovq	rdi, xmm7
[0,31]    .    D================================================eeeER .    .    .    .   .   vextracti128	xmm0, ymm7, 1
[0,32]    .    .D==================================================eeeER   .    .    .   .   vpextrq	r14, xmm0, 1
[0,33]    .    .D=================================================eE---R   .    .    .   .   lea	rbp, [rcx + rdi]
[0,34]    .    .D=================================================eeeeeER  .    .    .   .   vmovd	xmm1, dword ptr [rcx + rdi]
[0,35]    .    .D=================================================eeeeeeER .    .    .   .   vpinsrd	xmm1, xmm1, dword ptr [rcx + rsi], 1
[0,36]    .    . D==================================================eeE--R .    .    .   .   vmovq	rbx, xmm0
[0,37]    .    . D=================================================eeeeeER .    .    .   .   vmovd	xmm0, dword ptr [rcx + rdi + 4]
[0,38]    .    . D====================================================eeeeeeER  .    .   .   vpinsrd	xmm1, xmm1, dword ptr [rcx + rbx], 2
[0,39]    .    . D==================================================eeeeeeE--R  .    .   .   vpinsrd	xmm0, xmm0, dword ptr [rcx + rsi + 4], 1
[0,40]    .    .  D====================================================eeeeeeER .    .   .   vpinsrd	xmm0, xmm0, dword ptr [rcx + rbx + 4], 2
[0,41]    .    .  D================================================eE---------R .    .   .   lea	rdi, [rcx + rsi]
[0,42]    .    .  D================================================eeeeeE-----R .    .   .   vmovd	xmm7, dword ptr [rdx + rbp]
[0,43]    .    .  D=====================================================eeeeeeER.    .   .   vpinsrd	xmm2, xmm1, dword ptr [rcx + r14], 3
[0,44]    .    .   D=================================================eeeeeeE---R.    .   .   vpinsrd	xmm7, xmm7, dword ptr [rdx + rdi], 1
[0,45]    .    .   DeE---------------------------------------------------------R.    .   .   vmovaps	xmm25, xmm21
[0,46]    .    .   D=====================================================eeeeeeER    .   .   vpinsrd	xmm21, xmm0, dword ptr [rcx + r14 + 4], 3
[0,47]    .    .   D==================================================eE--------R    .   .   lea	rbx, [rcx + rbx]
[0,48]    .    .    D=====================================================eeeeeeER   .   .   vpinsrd	xmm0, xmm7, dword ptr [rdx + rbx], 2
[0,49]    .    .    D===========================eeeeE----------------------------R   .   .   vsubps	xmm5, xmm6, xmm5
[0,50]    .    .    D==================================================eE--------R   .   .   lea	rsi, [rcx + r14]
[0,51]    .    .    DeE----------------------------------------------------------R   .   .   vmovaps	xmm23, xmm20
[0,52]    .    .    .D=====================================================eeeeeeER  .   .   vpinsrd	xmm20, xmm0, dword ptr [rdx + rsi], 3
[0,53]    .    .    .D========================================================eE--R  .   .   vpand	xmm6, xmm9, xmm2
[0,54]    .    .    .DeE----------------------------------------------------------R  .   .   vmovaps	xmm22, xmm8
[0,55]    .    .    .D=========================================================eeeeeER   .   vpmullw	xmm8, xmm6, xmm6
[0,56]    .    .    .D========================================================eE-----R   .   vpsrlw	xmm6, xmm2, 8
[0,57]    .    .    . D========================================================eeeeeER   .   vpmullw	xmm1, xmm6, xmm6
[0,58]    .    .    . D=============================================================eER  .   vpsrld	xmm6, xmm8, 16
[0,59]    .    .    . D============================eeeeE------------------------------R  .   vsubps	xmm7, xmm28, xmm3
[0,60]    .    .    . D=============================eeeeE-----------------------------R  .   vsubps	xmm31, xmm28, xmm5
[0,61]    .    .    . DeE-------------------------------------------------------------R  .   vmovaps	xmm24, xmm16
[0,62]    .    .    . D=================================eeeeE-------------------------R  .   vmulps	xmm16, xmm31, xmm7
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
0.     10    9.1    0.1    30.6      vmulps	xmm0, xmm27, xmm19
1.     10    10.0   1.0    29.7      vmulps	xmm1, xmm7, xmm19
2.     10    8.3    0.1    25.2      vaddps	xmm26, xmm0, xmmword ptr [rsp + 96]
3.     10    11.0   1.9    22.5      vaddps	xmm15, xmm1, xmmword ptr [rsp + 80]
4.     10    19.1   0.9    20.7      vcmpordps	k1, xmm26, xmm26
5.     10    24.0   0.9    16.2      vmaxps	xmm0 {k1} {z}, xmm10, xmm26
6.     10    26.2   0.0    12.6      vminps	xmm1, xmm28, xmm0
7.     10    26.2   0.0    12.6      vcmpunordps	k1, xmm0, xmm0
8.     10    18.3   0.1    19.6      vcmpordps	k2, xmm15, xmm15
9.     10    22.3   0.0    15.6      vmaxps	xmm0 {k2} {z}, xmm10, xmm15
10.    10    29.2   0.0    11.7      vmovaps	xmm1 {k1}, xmm28
11.    10    25.3   0.0    11.7      vminps	xmm2, xmm28, xmm0
12.    10    24.4   0.0    11.7      vcmpunordps	k1, xmm0, xmm0
13.    10    27.5   0.0    10.8      vmovaps	xmm2 {k1}, xmm28
14.    10    27.5   0.0    8.1       vmulps	xmm0, xmm29, xmm1
15.    10    27.6   0.0    7.2       vmulps	xmm6, xmm18, xmm2
16.    10    30.5   0.0    4.5       vcvttps2dq	xmm1, xmm0
17.    10    30.6   0.0    3.6       vcvttps2dq	xmm2, xmm6
18.    10    34.5   0.9    0.0       vcvtdq2ps	xmm3, xmm1
19.    10    34.5   1.8    2.1       vpslld	xmm1, xmm1, 2
20.    10    34.6   0.9    0.0       vpmulld	xmm7, xmm30, xmm2
21.    10    44.5   0.0    0.0       vpaddd	xmm1, xmm1, xmm7
22.    10    44.6   0.0    0.0       vpcmpgtd	k1, xmm1, xmm10
23.    10    44.6   0.0    3.0       vpsubd	xmm7, xmm10, xmm1
24.    10    44.7   0.0    0.0       vpmovsxdq	ymm7, xmm7
25.    10    47.7   0.0    0.0       vpsubq	ymm7, ymm5, ymm7
26.    10    32.7   1.8    11.1      vcvtdq2ps	xmm5, xmm2
27.    10    47.7   0.0    0.0       vpmovsxdq	ymm7 {k1}, xmm1
28.    10    48.0   0.0    0.0       vpextrq	rsi, xmm7, 1
29.    10    32.0   0.0    15.0      vsubps	xmm3, xmm0, xmm3
30.    10    49.0   1.0    0.0       vmovq	rdi, xmm7
31.    10    45.4   1.0    0.0       vextracti128	xmm0, ymm7, 1
32.    10    48.3   0.0    0.0       vpextrq	r14, xmm0, 1
33.    10    47.3   0.0    3.0       lea	rbp, [rcx + rdi]
34.    10    46.4   0.0    0.0       vmovd	xmm1, dword ptr [rcx + rdi]
35.    10    46.4   0.0    0.0       vpinsrd	xmm1, xmm1, dword ptr [rcx + rsi], 1
36.    10    48.3   1.0    2.0       vmovq	rbx, xmm0
37.    10    45.5   1.0    0.0       vmovd	xmm0, dword ptr [rcx + rdi + 4]
38.    10    47.6   0.0    0.0       vpinsrd	xmm1, xmm1, dword ptr [rcx + rbx], 2
39.    10    45.6   1.0    2.0       vpinsrd	xmm0, xmm0, dword ptr [rcx + rsi + 4], 1
40.    10    47.6   1.0    0.0       vpinsrd	xmm0, xmm0, dword ptr [rcx + rbx + 4], 2
41.    10    43.6   1.0    9.0       lea	rdi, [rcx + rsi]
42.    10    42.7   0.0    5.0       vmovd	xmm7, dword ptr [rdx + rbp]
43.    10    46.8   1.0    0.0       vpinsrd	xmm2, xmm1, dword ptr [rcx + r14], 3
44.    10    42.8   1.0    3.0       vpinsrd	xmm7, xmm7, dword ptr [rdx + rdi], 1
45.    10    3.7    3.7    47.1      vmovaps	xmm25, xmm21
46.    10    45.9   1.0    0.0       vpinsrd	xmm21, xmm0, dword ptr [rcx + r14 + 4], 3
47.    10    42.9   0.0    8.0       lea	rbx, [rcx + rbx]
48.    10    46.8   3.0    0.0       vpinsrd	xmm0, xmm7, dword ptr [rdx + rbx], 2
49.    10    20.8   0.0    27.1      vsubps	xmm5, xmm6, xmm5
50.    10    42.9   1.0    8.0       lea	rsi, [rcx + r14]
51.    10    1.9    1.9    49.0      vmovaps	xmm23, xmm20
52.    10    45.9   0.0    0.0       vpinsrd	xmm20, xmm0, dword ptr [rdx + rsi], 3
53.    10    48.9   0.0    2.0       vpand	xmm6, xmm9, xmm2
54.    10    1.0    1.0    49.9      vmovaps	xmm22, xmm8
55.    10    49.0   0.0    0.0       vpmullw	xmm8, xmm6, xmm6
56.    10    48.0   0.0    5.0       vpsrlw	xmm6, xmm2, 8
57.    10    48.9   0.0    0.0       vpmullw	xmm1, xmm6, xmm6
58.    10    53.0   0.0    0.0       vpsrld	xmm6, xmm8, 16
59.    10    20.0   0.0    30.0      vsubps	xmm7, xmm28, xmm3
60.    10    21.0   0.0    28.1      vsubps	xmm31, xmm28, xmm5
61.    10    1.9    1.9    50.2      vmovaps	xmm24, xmm16
62.    10    24.1   0.0    24.1      vmulps	xmm16, xmm31, xmm7
63.    10    52.1   0.0    0.0       vcvtdq2ps	xmm6, xmm6
64.    10    24.0   0.0    28.1      vmulps	xmm4, xmm3, xmm31
65.    10    21.2   0.0    30.0      vmulps	xmm7, xmm5, xmm7
66.    10    19.1   0.0    32.1      vmulps	xmm3, xmm5, xmm3
67.    10    54.3   0.0    0.0       vmulps	xmm5, xmm16, xmm6
68.    10    53.4   0.0    0.0       vmulps	xmm0, xmm4, xmm6
69.    10    57.3   0.0    0.0       vaddps	xmm0, xmm5, xmm0
70.    10    53.2   1.0    3.0       vmulps	xmm5, xmm7, xmm6
71.    10    60.1   0.0    0.0       vaddps	xmm0, xmm5, xmm0
72.    10    42.8   1.0    20.0      vpsrlw	xmm5, xmm21, 8
73.    10    42.9   0.0    15.0      vpmullw	xmm5, xmm5, xmm5
74.    10    45.8   0.0    16.0      vpblendw	xmm1, xmm1, xmm10, 170
75.    10    45.0   0.0    12.0      vcvtdq2ps	xmm1, xmm1
76.    10    44.8   0.0    14.0      vpblendw	xmm5, xmm5, xmm10, 170
77.    10    45.7   0.0    10.0      vcvtdq2ps	xmm5, xmm5
78.    10    47.8   1.0    7.0       vmulps	xmm1, xmm16, xmm1
79.    10    48.7   0.0    6.0       vmulps	xmm5, xmm4, xmm5
80.    10    51.5   0.0    2.0       vaddps	xmm1, xmm1, xmm5
81.    10    37.4   0.0    19.0      vpsrlw	xmm5, xmm20, 8
82.    10    38.1   0.0    14.0      vpmullw	xmm5, xmm5, xmm5
83.    10    42.2   0.0    13.0      vpblendw	xmm5, xmm5, xmm10, 170
84.    10    43.1   0.0    9.0       vcvtdq2ps	xmm5, xmm5
85.    10    46.2   0.0    5.0       vmulps	xmm5, xmm7, xmm5
86.    10    52.0   0.0    0.0       vaddps	xmm1, xmm1, xmm5
87.    10    19.1   1.0    30.0      vmovd	xmm5, dword ptr [rdx + rbp + 4]
88.    10    25.0   8.0    21.0      vpinsrd	xmm5, xmm5, dword ptr [rdx + rdi + 4], 1
89.    10    24.1   0.0    20.0      vpinsrd	xmm5, xmm5, dword ptr [rdx + rbx + 4], 2
90.    10    25.1   0.0    19.0      vpinsrd	xmm5, xmm5, dword ptr [rdx + rsi + 4], 3
91.    10    37.0   2.0    8.0       vmulps	xmm6, xmm3, xmm6
92.    10    46.0   0.0    0.0       vaddps	xmm0, xmm6, xmm0
93.    10    29.0   0.0    20.0      vpsrlw	xmm6, xmm5, 8
94.    10    31.0   1.0    14.0      vpmullw	xmm6, xmm6, xmm6
95.    10    35.0   0.0    13.0      vpblendw	xmm6, xmm6, xmm10, 170
96.    10    35.1   0.0    9.0       vcvtdq2ps	xmm6, xmm6
97.    10    39.1   0.0    5.0       vmulps	xmm6, xmm3, xmm6
98.    10    44.0   0.0    0.0       vaddps	xmm31, xmm1, xmm6
99.    10    19.0   0.0    27.0      vpandq	xmm1, xmm21, xmm9
100.   10    17.0   0.0    22.0      vpmullw	xmm1, xmm1, xmm1
101.   10    21.0   1.0    21.0      vpblendw	xmm6, xmm8, xmm10, 170
102.   10    1.0    1.0    41.0      vmovaps	xmm8, xmm22
103.   10    21.0   0.0    17.0      vcvtdq2ps	xmm6, xmm6
104.   10    22.0   3.0    18.0      vpblendw	xmm1, xmm1, xmm10, 170
105.   10    27.0   4.0    10.0      vcvtdq2ps	xmm1, xmm1
106.   10    28.0   4.0    9.0       vmulps	xmm6, xmm16, xmm6
107.   10    30.0   0.0    6.0       vmulps	xmm1, xmm4, xmm1
108.   10    34.0   0.0    2.0       vaddps	xmm1, xmm6, xmm1
109.   10    14.0   0.0    25.0      vpandq	xmm6, xmm20, xmm9
110.   10    15.0   0.0    20.0      vpmullw	xmm6, xmm6, xmm6
111.   10    21.0   2.0    17.0      vpblendw	xmm6, xmm6, xmm10, 170
112.   10    26.0   4.0    9.0       vcvtdq2ps	xmm6, xmm6
113.   10    30.0   0.0    5.0       vmulps	xmm6, xmm7, xmm6
114.   10    36.0   0.0    0.0       vaddps	xmm1, xmm1, xmm6
115.   10    17.0   3.0    21.0      vpand	xmm6, xmm9, xmm5
116.   10    18.0   0.0    16.0      vpmullw	xmm6, xmm6, xmm6
117.   10    22.0   0.0    15.0      vpblendw	xmm6, xmm6, xmm10, 170
118.   10    24.0   1.0    10.0      vcvtdq2ps	xmm6, xmm6
119.   10    27.0   0.0    6.0       vmulps	xmm6, xmm3, xmm6
120.   10    36.0   0.0    0.0       vaddps	xmm6, xmm1, xmm6
121.   10    9.0    5.0    29.0      vpsrld	xmm1, xmm2, 24
122.   10    21.0   12.0   13.0      vcvtdq2ps	xmm1, xmm1
123.   10    24.0   0.0    9.0       vmulps	xmm1, xmm16, xmm1
124.   10    3.0    3.0    32.0      vmovaps	xmm16, xmm24
125.   10    5.0    4.0    29.0      vpsrld	xmm2, xmm21, 24
126.   10    4.0    4.0    30.0      vmovaps	xmm21, xmm25
127.   10    20.0   14.0   11.0      vcvtdq2ps	xmm2, xmm2
128.   10    23.0   0.0    7.0       vmulps	xmm2, xmm4, xmm2
129.   10    27.0   0.0    3.0       vaddps	xmm1, xmm1, xmm2
130.   10    21.0   19.0   12.0      vpsrld	xmm2, xmm20, 24
131.   10    3.0    3.0    29.0      vmovaps	xmm20, xmm23
132.   10    22.0   1.0    7.0       vcvtdq2ps	xmm2, xmm2
133.   10    26.0   0.0    3.0       vmulps	xmm2, xmm7, xmm2
134.   10    22.0   19.0   9.0       vpsrld	xmm4, xmm5, 24
135.   10    29.0   0.0    0.0       vaddps	xmm1, xmm1, xmm2
136.   10    1.0    1.0    26.0      vmovdqu	xmm5, xmmword ptr [r13 + 4*rax]
137.   10    22.0   0.0    6.0       vcvtdq2ps	xmm2, xmm4
138.   10    26.0   0.0    2.0       vmulps	xmm2, xmm3, xmm2
139.   10    8.0    2.0    23.0      vpshufb	xmm3, xmm5, xmm13
140.   10    22.0   13.0   6.0       vcvtdq2ps	xmm3, xmm3
141.   10    22.0   0.0    5.0       vmulps	xmm0, xmm23, xmm0
142.   10    31.0   0.0    0.0       vaddps	xmm1, xmm1, xmm2
143.   10    35.0   0.0    0.0       vmulps	xmm4, xmm22, xmm1
144.   10    25.0   0.0    9.0       vcmpordps	k1, xmm0, xmm0
145.   10    29.0   0.0    5.0       vmaxps	xmm0 {k1} {z}, xmm10, xmm0
146.   10    33.0   0.0    1.0       vminps	xmm1, xmm14, xmm0
147.   10    23.0   0.0    10.0      vmulps	xmm2, xmm3, xmm3
148.   10    32.0   0.0    1.0       vcmpunordps	k1, xmm0, xmm0
149.   10    37.0   0.0    0.0       vmulps	xmm0, xmm4, xmm17
150.   10    40.0   0.0    0.0       vaddps	xmm7, xmm0, xmm28
151.   10    44.0   0.0    0.0       vmulps	xmm0, xmm2, xmm7
152.   10    35.0   0.0    12.0      vmovaps	xmm1 {k1}, xmm14
153.   10    47.0   0.0    0.0       vaddps	xmm1, xmm1, xmm0
154.   10    5.0    4.0    45.0      vpshufb	xmm0, xmm5, xmm12
155.   10    20.0   0.0    27.0      vmulps	xmm2, xmm24, xmm31
156.   10    19.0   14.0   27.0      vcvtdq2ps	xmm0, xmm0
157.   10    23.0   0.0    23.0      vcmpordps	k1, xmm2, xmm2
158.   10    27.0   0.0    19.0      vmaxps	xmm2 {k1} {z}, xmm10, xmm2
159.   10    30.0   0.0    15.0      vcmpunordps	k1, xmm2, xmm2
160.   10    30.0   0.0    15.0      vminps	xmm2, xmm14, xmm2
161.   10    34.0   0.0    14.0      vmovaps	xmm2 {k1}, xmm14
162.   10    21.0   0.0    23.0      vmulps	xmm0, xmm0, xmm0
163.   10    40.0   0.0    4.0       vmulps	xmm0, xmm0, xmm7
164.   10    44.0   0.0    0.0       vaddps	xmm2, xmm0, xmm2
165.   10    3.0    3.0    43.0      vpand	xmm0, xmm11, xmm5
166.   10    18.0   14.0   25.0      vcvtdq2ps	xmm0, xmm0
167.   10    22.0   0.0    21.0      vmulps	xmm3, xmm25, xmm6
168.   10    26.0   1.0    16.0      vcmpordps	k1, xmm3, xmm3
169.   10    30.0   0.0    12.0      vmaxps	xmm3 {k1} {z}, xmm10, xmm3
170.   10    34.0   0.0    8.0       vcmpunordps	k1, xmm3, xmm3
171.   10    33.0   0.0    8.0       vminps	xmm3, xmm14, xmm3
172.   10    37.0   0.0    7.0       vmovaps	xmm3 {k1}, xmm14
173.   10    21.0   1.0    20.0      vmulps	xmm0, xmm0, xmm0
174.   10    37.0   1.0    3.0       vmulps	xmm0, xmm0, xmm7
175.   10    41.0   0.0    0.0       vaddps	xmm3, xmm0, xmm3
176.   10    44.0   0.0    0.0       vmovaps	xmm0, xmm1
177.   10    44.0   0.0    0.0       rsqrtps	xmm0, xmm0
178.   10    48.0   0.0    0.0       vmulps	xmm1, xmm0, xmm1
179.   10    42.0   0.0    8.0       vmovaps	xmm0, xmm2
180.   10    44.0   1.0    3.0       rsqrtps	xmm0, xmm0
181.   10    47.0   0.0    0.0       vmulps	xmm2, xmm0, xmm2
182.   10    42.0   0.0    8.0       vmovaps	xmm0, xmm3
183.   10    43.0   1.0    3.0       rsqrtps	xmm0, xmm0
184.   10    47.0   0.0    0.0       vmulps	xmm3, xmm0, xmm3
185.   10    48.0   0.0    1.0       vmovaps	xmm0, xmm1
186.   10    49.0   0.0    0.0       cvtps2dq	xmm0, xmm0
187.   10    52.0   0.0    0.0       vmovdqa	xmm1, xmm0
188.   10    48.0   0.0    4.0       vmovaps	xmm0, xmm2
189.   10    48.0   0.0    0.0       cvtps2dq	xmm0, xmm0
190.   10    52.0   0.0    0.0       vmovdqa	xmm2, xmm0
191.   10    47.0   0.0    4.0       vmovaps	xmm0, xmm3
192.   10    48.0   0.0    0.0       cvtps2dq	xmm0, xmm0
193.   10    50.0   0.0    0.0       vpslld	xmm1, xmm1, 16
194.   10    51.0   0.0    0.0       vpslld	xmm2, xmm2, 8
195.   10    51.0   0.0    0.0       vpternlogd	xmm2, xmm0, xmm1, 254
196.   10    1.0    1.0    47.0      vcmpleps	k1, xmm10, xmm26
197.   10    5.0    1.0    42.0      vcmpleps	k1 {k1}, xmm26, xmm28
198.   10    9.0    0.0    38.0      vcmpleps	k1 {k1}, xmm10, xmm15
199.   10    15.0   2.0    32.0      vcmpleps	k1 {k1}, xmm15, xmm28
200.   10    4.0    4.0    45.0      vpsrld	xmm0, xmm5, 24
201.   10    5.0    0.0    41.0      vcvtdq2ps	xmm0, xmm0
202.   10    24.0   1.0    21.0      vmulps	xmm0, xmm7, xmm0
203.   10    28.0   0.0    17.0      vaddps	xmm0, xmm4, xmm0
204.   10    31.0   0.0    13.0      cvtps2dq	xmm0, xmm0
205.   10    35.0   0.0    12.0      vpslld	xmm0, xmm0, 24
206.   10    47.0   0.0    0.0       vpord	xmm5 {k1}, xmm2, xmm0
207.   10    1.0    1.0    41.0      vmovaps	xmm2, xmmword ptr [rsp + 48]
208.   10    48.0   0.0    0.0       vmovdqu	xmmword ptr [r13 + 4*rax], xmm5
209.   10    0.0    0.0    49.0      vpxor	xmm5, xmm5, xmm5
210.   10    1.0    1.0    41.0      vmovaps	xmm7, xmmword ptr [rsp + 64]
211.   10    6.0    0.0    38.0      vaddps	xmm19, xmm19, xmm2
       10    31.5   1.0    12.3      <total>
```
</details>
</details>

### using hm.Y(origin) instead of originy_4x


<details><summary>[0] Code Region - ProcessPixel</summary>

```
Iterations:        100
Instructions:      21600
Total Cycles:      11139
Total uOps:        23400

Dispatch Width:    6
uOps Per Cycle:    2.10
IPC:               1.94
Block RThroughput: 61.0


Cycles with backend pressure increase [ 91.49% ]
Throughput Bottlenecks: 
  Resource Pressure       [ 53.74% ]
  - ICXPort0  [ 42.98% ]
  - ICXPort1  [ 41.21% ]
  - ICXPort2  [ 2.69% ]
  - ICXPort3  [ 2.69% ]
  - ICXPort5  [ 30.49% ]
  Data Dependencies:      [ 55.62% ]
  - Register Dependencies [ 55.62% ]
  - Memory Dependencies   [ 0.00% ]

```

<details><summary>Critical sequence based on the simulation:</summary>

```

              Instruction                                 Dependency Information
 +----< 215.  vaddps	xmm18, xmm18, xmm2
 |
 |    < loop carried > 
 |
 |      0.    vmulps	xmm0, xmm4, xmm18
 +----> 1.    vmulps	xmm1, xmm6, xmm18                 ## REGISTER dependency:  xmm18
 |      2.    vaddps	xmm15, xmm0, xmmword ptr [rsp + 96]
 +----> 3.    vaddps	xmm14, xmm1, xmmword ptr [rsp + 80] ## RESOURCE interference:  ICXPort0 [ probability: 1% ]
 |      4.    vcmpordps	k1, xmm15, xmm15
 |      5.    vmaxps	xmm0 {k1} {z}, xmm9, xmm15
 |      6.    vminps	xmm1, xmm25, xmm0
 |      7.    vcmpunordps	k1, xmm0, xmm0
 |      8.    vcmpordps	k2, xmm14, xmm14
 +----> 9.    vmaxps	xmm0 {k2} {z}, xmm9, xmm14        ## REGISTER dependency:  xmm14
 |      10.   vmovaps	xmm1 {k1}, xmm25
 |      11.   vminps	xmm2, xmm25, xmm0
 +----> 12.   vcmpunordps	k1, xmm0, xmm0            ## REGISTER dependency:  xmm0
 +----> 13.   vmovaps	xmm2 {k1}, xmm25                  ## REGISTER dependency:  k1
 |      14.   vmulps	xmm0, xmm28, xmm1
 +----> 15.   vmulps	xmm7, xmm17, xmm2                 ## REGISTER dependency:  xmm2
 |      16.   vcvttps2dq	xmm1, xmm0
 +----> 17.   vcvttps2dq	xmm2, xmm7                        ## REGISTER dependency:  xmm7
 |      18.   vcvtdq2ps	xmm3, xmm1
 |      19.   vpslld	xmm1, xmm1, 2
 +----> 20.   vpmulld	xmm6, xmm29, xmm2                 ## REGISTER dependency:  xmm2
 +----> 21.   vpaddd	xmm1, xmm1, xmm6                  ## REGISTER dependency:  xmm6
 |      22.   vpcmpgtd	k1, xmm1, xmm9
 |      23.   vpsubd	xmm6, xmm9, xmm1
 |      24.   vpmovsxdq	ymm6, xmm6
 |      25.   vpsubq	ymm6, ymm5, ymm6
 |      26.   vcvtdq2ps	xmm5, xmm2
 +----> 27.   vpmovsxdq	ymm6 {k1}, xmm1                   ## REGISTER dependency:  xmm1
 +----> 28.   vpextrq	rax, xmm6, 1                      ## REGISTER dependency:  ymm6
 |      29.   vsubps	xmm3, xmm0, xmm3
 |      30.   vmovq	rsi, xmm6
 +----> 31.   vextracti128	xmm0, ymm6, 1             ## RESOURCE interference:  ICXPort5 [ probability: 100% ]
 +----> 32.   vpextrq	rdi, xmm0, 1                      ## REGISTER dependency:  xmm0
 |      33.   lea	rbx, [rcx + rsi]
 |      34.   vmovd	xmm1, dword ptr [rcx + rsi]
 |      35.   vpinsrd	xmm1, xmm1, dword ptr [rcx + rax], 1
 +----> 36.   vmovq	rdx, xmm0                         ## RESOURCE interference:  ICXPort0 [ probability: 100% ]
 |      37.   vmovd	xmm0, dword ptr [rcx + rsi + 4]
 +----> 38.   vpinsrd	xmm1, xmm1, dword ptr [rcx + rdx], 2 ## REGISTER dependency:  rdx
 |      39.   vpinsrd	xmm0, xmm0, dword ptr [rcx + rax + 4], 1
 +----> 40.   vpinsrd	xmm0, xmm0, dword ptr [rcx + rdx + 4], 2 ## RESOURCE interference:  ICXPort5 [ probability: 100% ]
 |      41.   lea	rsi, [rcx + rax]
 |      42.   vmovd	xmm6, dword ptr [r10 + rbx]
 +----> 43.   vpinsrd	xmm2, xmm1, dword ptr [rcx + rdi], 3 ## RESOURCE interference:  ICXPort5 [ probability: 100% ]
 |      44.   vpinsrd	xmm6, xmm6, dword ptr [r10 + rsi], 1
 |      45.   vpinsrd	xmm1, xmm0, dword ptr [rcx + rdi + 4], 3
 |      46.   lea	rax, [rcx + rdx]
 |      47.   vpinsrd	xmm0, xmm6, dword ptr [r10 + rax], 2
 |      48.   vsubps	xmm5, xmm7, xmm5
 |      49.   lea	r14, [rcx + rdi]
 |      50.   vmovaps	xmm24, xmm22
 |      51.   vmovaps	xmm22, xmm20
 |      52.   vpinsrd	xmm20, xmm0, dword ptr [r10 + r14], 3
 +----> 53.   vpand	xmm6, xmm8, xmm2                  ## REGISTER dependency:  xmm2
 +----> 54.   vpmullw	xmm10, xmm6, xmm6                 ## REGISTER dependency:  xmm6
 |      55.   vpsrlw	xmm6, xmm2, 8
 |      56.   vpmullw	xmm0, xmm6, xmm6
 +----> 57.   vpsrld	xmm6, xmm10, 16                   ## REGISTER dependency:  xmm10
 |      58.   vmovdqa64	xmm19, xmm23
 |      59.   vmovaps	xmm23, xmm21
 |      60.   vmovaps	xmm21, xmm27
 |      61.   vsubps	xmm27, xmm25, xmm3
 |      62.   vsubps	xmm30, xmm25, xmm5
 |      63.   vmulps	xmm31, xmm30, xmm27
 +----> 64.   vcvtdq2ps	xmm6, xmm6                        ## REGISTER dependency:  xmm6
 |      65.   vmovaps	xmm16, xmm4
 |      66.   vmulps	xmm4, xmm3, xmm30
 |      67.   vmulps	xmm27, xmm5, xmm27
 |      68.   vmulps	xmm3, xmm5, xmm3
 |      69.   vmulps	xmm5, xmm31, xmm6
 |      70.   vmulps	xmm7, xmm4, xmm6
 |      71.   vaddps	xmm5, xmm5, xmm7
 |      72.   vmulps	xmm7, xmm27, xmm6
 |      73.   vaddps	xmm5, xmm7, xmm5
 |      74.   vpsrlw	xmm7, xmm1, 8
 |      75.   vpmullw	xmm7, xmm7, xmm7
 |      76.   vpblendw	xmm0, xmm0, xmm9, 170
 |      77.   vcvtdq2ps	xmm0, xmm0
 |      78.   vpblendw	xmm7, xmm7, xmm9, 170
 |      79.   vcvtdq2ps	xmm7, xmm7
 |      80.   vmulps	xmm0, xmm31, xmm0
 |      81.   vmulps	xmm7, xmm4, xmm7
 |      82.   vaddps	xmm0, xmm0, xmm7
 |      83.   vpsrlw	xmm7, xmm20, 8
 |      84.   vpmullw	xmm7, xmm7, xmm7
 |      85.   vpblendw	xmm7, xmm7, xmm9, 170
 |      86.   vcvtdq2ps	xmm7, xmm7
 |      87.   vmulps	xmm7, xmm27, xmm7
 |      88.   vaddps	xmm0, xmm0, xmm7
 |      89.   vmovd	xmm7, dword ptr [r10 + rbx + 4]
 |      90.   vpinsrd	xmm7, xmm7, dword ptr [r10 + rsi + 4], 1
 |      91.   vpinsrd	xmm7, xmm7, dword ptr [r10 + rax + 4], 2
 |      92.   vpinsrd	xmm7, xmm7, dword ptr [r10 + r14 + 4], 3
 |      93.   vmulps	xmm6, xmm3, xmm6
 |      94.   vaddps	xmm5, xmm6, xmm5
 |      95.   vpsrlw	xmm6, xmm7, 8
 +----> 96.   vpmullw	xmm6, xmm6, xmm6                  ## RESOURCE interference:  ICXPort0 [ probability: 100% ]
 +----> 97.   vpblendw	xmm6, xmm6, xmm9, 170             ## REGISTER dependency:  xmm6
 +----> 98.   vcvtdq2ps	xmm6, xmm6                        ## REGISTER dependency:  xmm6
 |      99.   vmulps	xmm6, xmm3, xmm6
 |      100.  vaddps	xmm30, xmm0, xmm6
 |      101.  vpand	xmm6, xmm8, xmm1
 |      102.  vpmullw	xmm6, xmm6, xmm6
 |      103.  vpblendw	xmm0, xmm10, xmm9, 170
 |      104.  vcvtdq2ps	xmm0, xmm0
 |      105.  vpblendw	xmm6, xmm6, xmm9, 170
 +----> 106.  vcvtdq2ps	xmm6, xmm6                        ## RESOURCE interference:  ICXPort1 [ probability: 100% ]
 +----> 107.  vmulps	xmm0, xmm31, xmm0                 ## RESOURCE interference:  ICXPort1 [ probability: 100% ]
 |      108.  vmulps	xmm6, xmm4, xmm6
 |      109.  vaddps	xmm0, xmm0, xmm6
 |      110.  vpandq	xmm6, xmm20, xmm8
 |      111.  vpmullw	xmm6, xmm6, xmm6
 |      112.  vpblendw	xmm6, xmm6, xmm9, 170
 +----> 113.  vcvtdq2ps	xmm6, xmm6                        ## RESOURCE interference:  ICXPort0 [ probability: 100% ]
 |      114.  vmulps	xmm6, xmm27, xmm6
 |      115.  vaddps	xmm0, xmm0, xmm6
 |      116.  vpand	xmm6, xmm8, xmm7
 |      117.  vpmullw	xmm6, xmm6, xmm6
 |      118.  vpblendw	xmm6, xmm6, xmm9, 170
 +----> 119.  vcvtdq2ps	xmm6, xmm6                        ## RESOURCE interference:  ICXPort1 [ probability: 100% ]
 |      120.  vmulps	xmm6, xmm3, xmm6
 |      121.  vaddps	xmm0, xmm0, xmm6
 |      122.  vpsrld	xmm2, xmm2, 24
 +----> 123.  vcvtdq2ps	xmm2, xmm2                        ## RESOURCE interference:  ICXPort1 [ probability: 100% ]
 +----> 124.  vmulps	xmm2, xmm31, xmm2                 ## REGISTER dependency:  xmm2
 |      125.  vpsrld	xmm1, xmm1, 24
 |      126.  vcvtdq2ps	xmm1, xmm1
 |      127.  vmulps	xmm1, xmm4, xmm1
 |      128.  vaddps	xmm1, xmm2, xmm1
 +----> 129.  vpsrld	xmm2, xmm20, 24                   ## RESOURCE interference:  ICXPort0 [ probability: 100% ]
 |      130.  vmovaps	xmm20, xmm22
 |      131.  vmovaps	xmm22, xmm24
 +----> 132.  vcvtdq2ps	xmm2, xmm2                        ## REGISTER dependency:  xmm2
 |      133.  vmulps	xmm2, xmm27, xmm2
 |      134.  vmovaps	xmm27, xmm21
 |      135.  vmovaps	xmm21, xmm23
 |      136.  vmovdqa64	xmm23, xmm19
 +----> 137.  vpsrld	xmm4, xmm7, 24                    ## RESOURCE interference:  ICXPort1 [ probability: 100% ]
 |      138.  vaddps	xmm1, xmm1, xmm2
 |      139.  vmovdqu	xmm7, xmmword ptr [r8 + 4*rbp]
 +----> 140.  vcvtdq2ps	xmm2, xmm4                        ## REGISTER dependency:  xmm4
 |      141.  vmulps	xmm2, xmm3, xmm2
 |      142.  vpshufb	xmm3, xmm7, xmm12
 +----> 143.  vcvtdq2ps	xmm3, xmm3                        ## RESOURCE interference:  ICXPort0 [ probability: 100% ]
 |      144.  vmulps	xmm4, xmm20, xmm5
 |      145.  vaddps	xmm1, xmm1, xmm2
 |      146.  vmulps	xmm5, xmm27, xmm1
 |      147.  vcmpordps	k1, xmm4, xmm4
 |      148.  vmaxps	xmm1 {k1} {z}, xmm9, xmm4
 |      149.  vminps	xmm2, xmm26, xmm1
 +----> 150.  vmulps	xmm3, xmm3, xmm3                  ## REGISTER dependency:  xmm3
 |      151.  vcmpunordps	k1, xmm1, xmm1
 |      152.  vmulps	xmm1, xmm13, xmm5
 |      153.  vaddps	xmm4, xmm1, xmm25
 |      154.  vmulps	xmm1, xmm3, xmm4
 |      155.  vmovaps	xmm2 {k1}, xmm26
 |      156.  vaddps	xmm1, xmm2, xmm1
 |      157.  vpshufb	xmm2, xmm7, xmm11
 |      158.  vmulps	xmm3, xmm21, xmm30
 |      159.  vcvtdq2ps	xmm2, xmm2
 |      160.  vcmpordps	k1, xmm3, xmm3
 |      161.  vmaxps	xmm3 {k1} {z}, xmm9, xmm3
 |      162.  vcmpunordps	k1, xmm3, xmm3
 |      163.  vminps	xmm3, xmm26, xmm3
 |      164.  vmovaps	xmm3 {k1}, xmm26
 |      165.  vmulps	xmm2, xmm2, xmm2
 |      166.  vmulps	xmm2, xmm2, xmm4
 |      167.  vaddps	xmm2, xmm2, xmm3
 |      168.  vpandd	xmm3, xmm7, xmm19
 +----> 169.  vcvtdq2ps	xmm3, xmm3                        ## RESOURCE interference:  ICXPort1 [ probability: 100% ]
 |      170.  vmulps	xmm0, xmm24, xmm0
 |      171.  vcmpordps	k1, xmm0, xmm0
 |      172.  vmaxps	xmm0 {k1} {z}, xmm9, xmm0
 |      173.  vcmpunordps	k1, xmm0, xmm0
 |      174.  vminps	xmm0, xmm26, xmm0
 |      175.  vmovaps	xmm0 {k1}, xmm26
 |      176.  vmulps	xmm3, xmm3, xmm3
 |      177.  vmulps	xmm3, xmm3, xmm4
 |      178.  vaddps	xmm3, xmm3, xmm0
 |      179.  vmovaps	xmm0, xmm1
 |      180.  rsqrtps	xmm0, xmm0
 |      181.  vmulps	xmm1, xmm0, xmm1
 |      182.  vmovaps	xmm0, xmm2
 |      183.  rsqrtps	xmm0, xmm0
 |      184.  vmulps	xmm2, xmm0, xmm2
 |      185.  vmovaps	xmm0, xmm3
 |      186.  rsqrtps	xmm0, xmm0
 |      187.  vmulps	xmm3, xmm0, xmm3
 |      188.  vmovaps	xmm0, xmm1
 |      189.  cvtps2dq	xmm0, xmm0
 |      190.  vmovdqa	xmm1, xmm0
 |      191.  vmovaps	xmm0, xmm2
 |      192.  cvtps2dq	xmm0, xmm0
 |      193.  vmovdqa	xmm2, xmm0
 |      194.  vmovaps	xmm0, xmm3
 |      195.  cvtps2dq	xmm0, xmm0
 |      196.  vpslld	xmm1, xmm1, 16
 |      197.  vpslld	xmm2, xmm2, 8
 |      198.  vpternlogd	xmm2, xmm0, xmm1, 254
 |      199.  vcmpleps	k1, xmm9, xmm15
 |      200.  vcmpleps	k1 {k1}, xmm15, xmm25
 |      201.  vcmpleps	k1 {k1}, xmm9, xmm14
 |      202.  vcmpleps	k1 {k1}, xmm14, xmm25
 +----> 203.  vpsrld	xmm0, xmm7, 24                    ## RESOURCE interference:  ICXPort1 [ probability: 100% ]
 +----> 204.  vcvtdq2ps	xmm0, xmm0                        ## REGISTER dependency:  xmm0
 +----> 205.  vmulps	xmm0, xmm4, xmm0                  ## REGISTER dependency:  xmm0
 |      206.  vmovaps	xmm4, xmm16
 +----> 207.  vaddps	xmm0, xmm5, xmm0                  ## REGISTER dependency:  xmm0
 |      208.  vxorps	xmm5, xmm5, xmm5
 |      209.  vmovaps	xmm6, xmmword ptr [rsp + 64]
 +----> 210.  cvtps2dq	xmm0, xmm0                        ## REGISTER dependency:  xmm0
 +----> 211.  vpslld	xmm0, xmm0, 24                    ## REGISTER dependency:  xmm0
 +----> 212.  vpord	xmm7 {k1}, xmm2, xmm0             ## REGISTER dependency:  xmm0
 |      213.  vmovaps	xmm2, xmmword ptr [rsp + 48]
 +----> 214.  vmovdqu	xmmword ptr [r8 + 4*rbp], xmm7    ## REGISTER dependency:  xmm7
        215.  vaddps	xmm18, xmm18, xmm2


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
 1      4     0.50                        vmulps	xmm0, xmm4, xmm18
 1      4     0.50                        vmulps	xmm1, xmm6, xmm18
 2      10    0.50    *                   vaddps	xmm15, xmm0, xmmword ptr [rsp + 96]
 2      10    0.50    *                   vaddps	xmm14, xmm1, xmmword ptr [rsp + 80]
 1      4     1.00                        vcmpordps	k1, xmm15, xmm15
 1      4     0.50                        vmaxps	xmm0 {k1} {z}, xmm9, xmm15
 1      4     0.50                        vminps	xmm1, xmm25, xmm0
 1      4     1.00                        vcmpunordps	k1, xmm0, xmm0
 1      4     1.00                        vcmpordps	k2, xmm14, xmm14
 1      4     0.50                        vmaxps	xmm0 {k2} {z}, xmm9, xmm14
 1      1     0.33                        vmovaps	xmm1 {k1}, xmm25
 1      4     0.50                        vminps	xmm2, xmm25, xmm0
 1      4     1.00                        vcmpunordps	k1, xmm0, xmm0
 1      1     0.33                        vmovaps	xmm2 {k1}, xmm25
 1      4     0.50                        vmulps	xmm0, xmm28, xmm1
 1      4     0.50                        vmulps	xmm7, xmm17, xmm2
 1      4     0.50                        vcvttps2dq	xmm1, xmm0
 1      4     0.50                        vcvttps2dq	xmm2, xmm7
 1      4     0.50                        vcvtdq2ps	xmm3, xmm1
 1      1     0.50                        vpslld	xmm1, xmm1, 2
 2      10    1.00                        vpmulld	xmm6, xmm29, xmm2
 1      1     0.33                        vpaddd	xmm1, xmm1, xmm6
 1      4     1.00                        vpcmpgtd	k1, xmm1, xmm9
 1      1     0.33                        vpsubd	xmm6, xmm9, xmm1
 1      3     1.00                        vpmovsxdq	ymm6, xmm6
 1      1     0.33                        vpsubq	ymm6, ymm5, ymm6
 1      4     0.50                        vcvtdq2ps	xmm5, xmm2
 1      3     1.00                        vpmovsxdq	ymm6 {k1}, xmm1
 2      3     1.00                        vpextrq	rax, xmm6, 1
 1      4     0.50                        vsubps	xmm3, xmm0, xmm3
 1      2     1.00                        vmovq	rsi, xmm6
 1      3     1.00                        vextracti128	xmm0, ymm6, 1
 2      3     1.00                        vpextrq	rdi, xmm0, 1
 1      1     0.50                        lea	rbx, [rcx + rsi]
 1      5     0.50    *                   vmovd	xmm1, dword ptr [rcx + rsi]
 2      6     1.00    *                   vpinsrd	xmm1, xmm1, dword ptr [rcx + rax], 1
 1      2     1.00                        vmovq	rdx, xmm0
 1      5     0.50    *                   vmovd	xmm0, dword ptr [rcx + rsi + 4]
 2      6     1.00    *                   vpinsrd	xmm1, xmm1, dword ptr [rcx + rdx], 2
 2      6     1.00    *                   vpinsrd	xmm0, xmm0, dword ptr [rcx + rax + 4], 1
 2      6     1.00    *                   vpinsrd	xmm0, xmm0, dword ptr [rcx + rdx + 4], 2
 1      1     0.50                        lea	rsi, [rcx + rax]
 1      5     0.50    *                   vmovd	xmm6, dword ptr [r10 + rbx]
 2      6     1.00    *                   vpinsrd	xmm2, xmm1, dword ptr [rcx + rdi], 3
 2      6     1.00    *                   vpinsrd	xmm6, xmm6, dword ptr [r10 + rsi], 1
 2      6     1.00    *                   vpinsrd	xmm1, xmm0, dword ptr [rcx + rdi + 4], 3
 1      1     0.50                        lea	rax, [rcx + rdx]
 2      6     1.00    *                   vpinsrd	xmm0, xmm6, dword ptr [r10 + rax], 2
 1      4     0.50                        vsubps	xmm5, xmm7, xmm5
 1      1     0.50                        lea	r14, [rcx + rdi]
 1      1     0.33                        vmovaps	xmm24, xmm22
 1      1     0.33                        vmovaps	xmm22, xmm20
 2      6     1.00    *                   vpinsrd	xmm20, xmm0, dword ptr [r10 + r14], 3
 1      1     0.33                        vpand	xmm6, xmm8, xmm2
 1      5     0.50                        vpmullw	xmm10, xmm6, xmm6
 1      1     0.50                        vpsrlw	xmm6, xmm2, 8
 1      5     0.50                        vpmullw	xmm0, xmm6, xmm6
 1      1     0.50                        vpsrld	xmm6, xmm10, 16
 1      1     0.33                        vmovdqa64	xmm19, xmm23
 1      1     0.33                        vmovaps	xmm23, xmm21
 1      1     0.33                        vmovaps	xmm21, xmm27
 1      4     0.50                        vsubps	xmm27, xmm25, xmm3
 1      4     0.50                        vsubps	xmm30, xmm25, xmm5
 1      4     0.50                        vmulps	xmm31, xmm30, xmm27
 1      4     0.50                        vcvtdq2ps	xmm6, xmm6
 1      1     0.33                        vmovaps	xmm16, xmm4
 1      4     0.50                        vmulps	xmm4, xmm3, xmm30
 1      4     0.50                        vmulps	xmm27, xmm5, xmm27
 1      4     0.50                        vmulps	xmm3, xmm5, xmm3
 1      4     0.50                        vmulps	xmm5, xmm31, xmm6
 1      4     0.50                        vmulps	xmm7, xmm4, xmm6
 1      4     0.50                        vaddps	xmm5, xmm5, xmm7
 1      4     0.50                        vmulps	xmm7, xmm27, xmm6
 1      4     0.50                        vaddps	xmm5, xmm7, xmm5
 1      1     0.50                        vpsrlw	xmm7, xmm1, 8
 1      5     0.50                        vpmullw	xmm7, xmm7, xmm7
 1      1     1.00                        vpblendw	xmm0, xmm0, xmm9, 170
 1      4     0.50                        vcvtdq2ps	xmm0, xmm0
 1      1     1.00                        vpblendw	xmm7, xmm7, xmm9, 170
 1      4     0.50                        vcvtdq2ps	xmm7, xmm7
 1      4     0.50                        vmulps	xmm0, xmm31, xmm0
 1      4     0.50                        vmulps	xmm7, xmm4, xmm7
 1      4     0.50                        vaddps	xmm0, xmm0, xmm7
 1      1     0.50                        vpsrlw	xmm7, xmm20, 8
 1      5     0.50                        vpmullw	xmm7, xmm7, xmm7
 1      1     1.00                        vpblendw	xmm7, xmm7, xmm9, 170
 1      4     0.50                        vcvtdq2ps	xmm7, xmm7
 1      4     0.50                        vmulps	xmm7, xmm27, xmm7
 1      4     0.50                        vaddps	xmm0, xmm0, xmm7
 1      5     0.50    *                   vmovd	xmm7, dword ptr [r10 + rbx + 4]
 2      6     1.00    *                   vpinsrd	xmm7, xmm7, dword ptr [r10 + rsi + 4], 1
 2      6     1.00    *                   vpinsrd	xmm7, xmm7, dword ptr [r10 + rax + 4], 2
 2      6     1.00    *                   vpinsrd	xmm7, xmm7, dword ptr [r10 + r14 + 4], 3
 1      4     0.50                        vmulps	xmm6, xmm3, xmm6
 1      4     0.50                        vaddps	xmm5, xmm6, xmm5
 1      1     0.50                        vpsrlw	xmm6, xmm7, 8
 1      5     0.50                        vpmullw	xmm6, xmm6, xmm6
 1      1     1.00                        vpblendw	xmm6, xmm6, xmm9, 170
 1      4     0.50                        vcvtdq2ps	xmm6, xmm6
 1      4     0.50                        vmulps	xmm6, xmm3, xmm6
 1      4     0.50                        vaddps	xmm30, xmm0, xmm6
 1      1     0.33                        vpand	xmm6, xmm8, xmm1
 1      5     0.50                        vpmullw	xmm6, xmm6, xmm6
 1      1     1.00                        vpblendw	xmm0, xmm10, xmm9, 170
 1      4     0.50                        vcvtdq2ps	xmm0, xmm0
 1      1     1.00                        vpblendw	xmm6, xmm6, xmm9, 170
 1      4     0.50                        vcvtdq2ps	xmm6, xmm6
 1      4     0.50                        vmulps	xmm0, xmm31, xmm0
 1      4     0.50                        vmulps	xmm6, xmm4, xmm6
 1      4     0.50                        vaddps	xmm0, xmm0, xmm6
 1      1     0.33                        vpandq	xmm6, xmm20, xmm8
 1      5     0.50                        vpmullw	xmm6, xmm6, xmm6
 1      1     1.00                        vpblendw	xmm6, xmm6, xmm9, 170
 1      4     0.50                        vcvtdq2ps	xmm6, xmm6
 1      4     0.50                        vmulps	xmm6, xmm27, xmm6
 1      4     0.50                        vaddps	xmm0, xmm0, xmm6
 1      1     0.33                        vpand	xmm6, xmm8, xmm7
 1      5     0.50                        vpmullw	xmm6, xmm6, xmm6
 1      1     1.00                        vpblendw	xmm6, xmm6, xmm9, 170
 1      4     0.50                        vcvtdq2ps	xmm6, xmm6
 1      4     0.50                        vmulps	xmm6, xmm3, xmm6
 1      4     0.50                        vaddps	xmm0, xmm0, xmm6
 1      1     0.50                        vpsrld	xmm2, xmm2, 24
 1      4     0.50                        vcvtdq2ps	xmm2, xmm2
 1      4     0.50                        vmulps	xmm2, xmm31, xmm2
 1      1     0.50                        vpsrld	xmm1, xmm1, 24
 1      4     0.50                        vcvtdq2ps	xmm1, xmm1
 1      4     0.50                        vmulps	xmm1, xmm4, xmm1
 1      4     0.50                        vaddps	xmm1, xmm2, xmm1
 1      1     0.50                        vpsrld	xmm2, xmm20, 24
 1      1     0.33                        vmovaps	xmm20, xmm22
 1      1     0.33                        vmovaps	xmm22, xmm24
 1      4     0.50                        vcvtdq2ps	xmm2, xmm2
 1      4     0.50                        vmulps	xmm2, xmm27, xmm2
 1      1     0.33                        vmovaps	xmm27, xmm21
 1      1     0.33                        vmovaps	xmm21, xmm23
 1      1     0.33                        vmovdqa64	xmm23, xmm19
 1      1     0.50                        vpsrld	xmm4, xmm7, 24
 1      4     0.50                        vaddps	xmm1, xmm1, xmm2
 1      6     0.50    *                   vmovdqu	xmm7, xmmword ptr [r8 + 4*rbp]
 1      4     0.50                        vcvtdq2ps	xmm2, xmm4
 1      4     0.50                        vmulps	xmm2, xmm3, xmm2
 1      1     0.50                        vpshufb	xmm3, xmm7, xmm12
 1      4     0.50                        vcvtdq2ps	xmm3, xmm3
 1      4     0.50                        vmulps	xmm4, xmm20, xmm5
 1      4     0.50                        vaddps	xmm1, xmm1, xmm2
 1      4     0.50                        vmulps	xmm5, xmm27, xmm1
 1      4     1.00                        vcmpordps	k1, xmm4, xmm4
 1      4     0.50                        vmaxps	xmm1 {k1} {z}, xmm9, xmm4
 1      4     0.50                        vminps	xmm2, xmm26, xmm1
 1      4     0.50                        vmulps	xmm3, xmm3, xmm3
 1      4     1.00                        vcmpunordps	k1, xmm1, xmm1
 1      4     0.50                        vmulps	xmm1, xmm13, xmm5
 1      4     0.50                        vaddps	xmm4, xmm1, xmm25
 1      4     0.50                        vmulps	xmm1, xmm3, xmm4
 1      1     0.33                        vmovaps	xmm2 {k1}, xmm26
 1      4     0.50                        vaddps	xmm1, xmm2, xmm1
 1      1     0.50                        vpshufb	xmm2, xmm7, xmm11
 1      4     0.50                        vmulps	xmm3, xmm21, xmm30
 1      4     0.50                        vcvtdq2ps	xmm2, xmm2
 1      4     1.00                        vcmpordps	k1, xmm3, xmm3
 1      4     0.50                        vmaxps	xmm3 {k1} {z}, xmm9, xmm3
 1      4     1.00                        vcmpunordps	k1, xmm3, xmm3
 1      4     0.50                        vminps	xmm3, xmm26, xmm3
 1      1     0.33                        vmovaps	xmm3 {k1}, xmm26
 1      4     0.50                        vmulps	xmm2, xmm2, xmm2
 1      4     0.50                        vmulps	xmm2, xmm2, xmm4
 1      4     0.50                        vaddps	xmm2, xmm2, xmm3
 1      1     0.33                        vpandd	xmm3, xmm7, xmm19
 1      4     0.50                        vcvtdq2ps	xmm3, xmm3
 1      4     0.50                        vmulps	xmm0, xmm24, xmm0
 1      4     1.00                        vcmpordps	k1, xmm0, xmm0
 1      4     0.50                        vmaxps	xmm0 {k1} {z}, xmm9, xmm0
 1      4     1.00                        vcmpunordps	k1, xmm0, xmm0
 1      4     0.50                        vminps	xmm0, xmm26, xmm0
 1      1     0.33                        vmovaps	xmm0 {k1}, xmm26
 1      4     0.50                        vmulps	xmm3, xmm3, xmm3
 1      4     0.50                        vmulps	xmm3, xmm3, xmm4
 1      4     0.50                        vaddps	xmm3, xmm3, xmm0
 1      1     0.33                        vmovaps	xmm0, xmm1
 1      4     1.00                        rsqrtps	xmm0, xmm0
 1      4     0.50                        vmulps	xmm1, xmm0, xmm1
 1      1     0.33                        vmovaps	xmm0, xmm2
 1      4     1.00                        rsqrtps	xmm0, xmm0
 1      4     0.50                        vmulps	xmm2, xmm0, xmm2
 1      1     0.33                        vmovaps	xmm0, xmm3
 1      4     1.00                        rsqrtps	xmm0, xmm0
 1      4     0.50                        vmulps	xmm3, xmm0, xmm3
 1      1     0.33                        vmovaps	xmm0, xmm1
 1      4     0.50                        cvtps2dq	xmm0, xmm0
 1      1     0.33                        vmovdqa	xmm1, xmm0
 1      1     0.33                        vmovaps	xmm0, xmm2
 1      4     0.50                        cvtps2dq	xmm0, xmm0
 1      1     0.33                        vmovdqa	xmm2, xmm0
 1      1     0.33                        vmovaps	xmm0, xmm3
 1      4     0.50                        cvtps2dq	xmm0, xmm0
 1      1     0.50                        vpslld	xmm1, xmm1, 16
 1      1     0.50                        vpslld	xmm2, xmm2, 8
 1      1     0.33                        vpternlogd	xmm2, xmm0, xmm1, 254
 1      4     1.00                        vcmpleps	k1, xmm9, xmm15
 1      4     1.00                        vcmpleps	k1 {k1}, xmm15, xmm25
 1      4     1.00                        vcmpleps	k1 {k1}, xmm9, xmm14
 1      4     1.00                        vcmpleps	k1 {k1}, xmm14, xmm25
 1      1     0.50                        vpsrld	xmm0, xmm7, 24
 1      4     0.50                        vcvtdq2ps	xmm0, xmm0
 1      4     0.50                        vmulps	xmm0, xmm4, xmm0
 1      1     0.33                        vmovaps	xmm4, xmm16
 1      4     0.50                        vaddps	xmm0, xmm5, xmm0
 1      0     0.17                        vxorps	xmm5, xmm5, xmm5
 1      6     0.50    *                   vmovaps	xmm6, xmmword ptr [rsp + 64]
 1      4     0.50                        cvtps2dq	xmm0, xmm0
 1      1     0.50                        vpslld	xmm0, xmm0, 24
 1      1     0.33                        vpord	xmm7 {k1}, xmm2, xmm0
 1      6     0.50    *                   vmovaps	xmm2, xmmword ptr [rsp + 48]
 2      1     1.00           *            vmovdqu	xmmword ptr [r8 + 4*rbp], xmm7
 1      4     0.50                        vaddps	xmm18, xmm18, xmm2


```
</details>

<details><summary>Dynamic Dispatch Stall Cycles:</summary>

```
RAT     - Register unavailable:                      0
RCU     - Retire tokens unavailable:                 0
SCHEDQ  - Scheduler full:                            10976  (98.5%)
LQ      - Load queue full:                           0
SQ      - Store queue full:                          0
GROUP   - Static restrictions on the dispatch group: 0
USH     - Uncategorised Structural Hazard:           0


```
</details>

<details><summary>Dispatch Logic - number of cycles where we saw N micro opcodes dispatched:</summary>

```
[# dispatched], [# cycles]
 0,              1454  (13.1%)
 1,              2099  (18.8%)
 2,              3187  (28.6%)
 3,              2895  (26.0%)
 4,              1291  (11.6%)
 5,              200  (1.8%)
 6,              13  (0.1%)


```
</details>

<details><summary>Schedulers - number of cycles where we saw N micro opcodes issued:</summary>

```
[# issued], [# cycles]
 0,          1429  (12.8%)
 1,          1414  (12.7%)
 2,          4001  (35.9%)
 3,          3296  (29.6%)
 4,          899  (8.1%)
 5,          100  (0.9%)

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
 0,           6527  (58.6%)
 1,           1107  (9.9%)
 2,           1204  (10.8%)
 3,           801  (7.2%)
 4,           101  (0.9%)
 5,           200  (1.8%)
 6,           400  (3.6%)
 7,           200  (1.8%)
 14,          100  (0.9%)
 15,          200  (1.8%)
 17,          100  (0.9%)
 22,          199  (1.8%)

```
</details>

<details><summary>Total ROB Entries:                224</summary>

```
Max Used ROB Entries:             124  ( 55.4% )
Average Used ROB Entries per cy:  101  ( 45.1% )


```
</details>

<details><summary>Register File statistics:</summary>

```
Total number of mappings created:    21400
Max number of mappings used:         121


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
 -      -     72.01  71.03  10.50  10.50  1.00   66.96   -     1.00    -      -     

Resource pressure by instruction:
[0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   Instructions:
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm4, xmm18
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm1, xmm6, xmm18
 -      -     0.99   0.01   0.50   0.50    -      -      -      -      -      -     vaddps	xmm15, xmm0, xmmword ptr [rsp + 96]
 -      -     0.01   0.99   0.50   0.50    -      -      -      -      -      -     vaddps	xmm14, xmm1, xmmword ptr [rsp + 80]
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpordps	k1, xmm15, xmm15
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmaxps	xmm0 {k1} {z}, xmm9, xmm15
 -      -      -     1.00    -      -      -      -      -      -      -      -     vminps	xmm1, xmm25, xmm0
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpunordps	k1, xmm0, xmm0
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpordps	k2, xmm14, xmm14
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmaxps	xmm0 {k2} {z}, xmm9, xmm14
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     vmovaps	xmm1 {k1}, xmm25
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vminps	xmm2, xmm25, xmm0
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpunordps	k1, xmm0, xmm0
 -      -     0.01    -      -      -      -     0.99    -      -      -      -     vmovaps	xmm2 {k1}, xmm25
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm28, xmm1
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulps	xmm7, xmm17, xmm2
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vcvttps2dq	xmm1, xmm0
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vcvttps2dq	xmm2, xmm7
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm3, xmm1
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vpslld	xmm1, xmm1, 2
 -      -     1.98   0.02    -      -      -      -      -      -      -      -     vpmulld	xmm6, xmm29, xmm2
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpaddd	xmm1, xmm1, xmm6
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpcmpgtd	k1, xmm1, xmm9
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpsubd	xmm6, xmm9, xmm1
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpmovsxdq	ymm6, xmm6
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpsubq	ymm6, ymm5, ymm6
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm5, xmm2
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpmovsxdq	ymm6 {k1}, xmm1
 -      -     1.00    -      -      -      -     1.00    -      -      -      -     vpextrq	rax, xmm6, 1
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vsubps	xmm3, xmm0, xmm3
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmovq	rsi, xmm6
 -      -      -      -      -      -      -     1.00    -      -      -      -     vextracti128	xmm0, ymm6, 1
 -      -     1.00    -      -      -      -     1.00    -      -      -      -     vpextrq	rdi, xmm0, 1
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	rbx, [rcx + rsi]
 -      -      -      -     0.50   0.50    -      -      -      -      -      -     vmovd	xmm1, dword ptr [rcx + rsi]
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpinsrd	xmm1, xmm1, dword ptr [rcx + rax], 1
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmovq	rdx, xmm0
 -      -      -      -     0.50   0.50    -      -      -      -      -      -     vmovd	xmm0, dword ptr [rcx + rsi + 4]
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpinsrd	xmm1, xmm1, dword ptr [rcx + rdx], 2
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpinsrd	xmm0, xmm0, dword ptr [rcx + rax + 4], 1
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpinsrd	xmm0, xmm0, dword ptr [rcx + rdx + 4], 2
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	rsi, [rcx + rax]
 -      -      -      -     0.50   0.50    -      -      -      -      -      -     vmovd	xmm6, dword ptr [r10 + rbx]
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpinsrd	xmm2, xmm1, dword ptr [rcx + rdi], 3
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpinsrd	xmm6, xmm6, dword ptr [r10 + rsi], 1
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpinsrd	xmm1, xmm0, dword ptr [rcx + rdi + 4], 3
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	rax, [rcx + rdx]
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpinsrd	xmm0, xmm6, dword ptr [r10 + rax], 2
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vsubps	xmm5, xmm7, xmm5
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	r14, [rcx + rdi]
 -      -     0.99    -      -      -      -     0.01    -      -      -      -     vmovaps	xmm24, xmm22
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     vmovaps	xmm22, xmm20
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpinsrd	xmm20, xmm0, dword ptr [r10 + r14], 3
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpand	xmm6, xmm8, xmm2
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpmullw	xmm10, xmm6, xmm6
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpsrlw	xmm6, xmm2, 8
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpmullw	xmm0, xmm6, xmm6
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpsrld	xmm6, xmm10, 16
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmovdqa64	xmm19, xmm23
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     vmovaps	xmm23, xmm21
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmovaps	xmm21, xmm27
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vsubps	xmm27, xmm25, xmm3
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vsubps	xmm30, xmm25, xmm5
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulps	xmm31, xmm30, xmm27
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm6, xmm6
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     vmovaps	xmm16, xmm4
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmulps	xmm4, xmm3, xmm30
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm27, xmm5, xmm27
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmulps	xmm3, xmm5, xmm3
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm5, xmm31, xmm6
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm7, xmm4, xmm6
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm5, xmm5, xmm7
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm7, xmm27, xmm6
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm5, xmm7, xmm5
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpsrlw	xmm7, xmm1, 8
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpmullw	xmm7, xmm7, xmm7
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm0, xmm0, xmm9, 170
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm0, xmm0
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm7, xmm7, xmm9, 170
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm7, xmm7
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm31, xmm0
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm7, xmm4, xmm7
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm0, xmm0, xmm7
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpsrlw	xmm7, xmm20, 8
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpmullw	xmm7, xmm7, xmm7
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm7, xmm7, xmm9, 170
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm7, xmm7
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm7, xmm27, xmm7
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm0, xmm0, xmm7
 -      -      -      -     0.50   0.50    -      -      -      -      -      -     vmovd	xmm7, dword ptr [r10 + rbx + 4]
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpinsrd	xmm7, xmm7, dword ptr [r10 + rsi + 4], 1
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpinsrd	xmm7, xmm7, dword ptr [r10 + rax + 4], 2
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpinsrd	xmm7, xmm7, dword ptr [r10 + r14 + 4], 3
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm6, xmm3, xmm6
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm5, xmm6, xmm5
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpsrlw	xmm6, xmm7, 8
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpmullw	xmm6, xmm6, xmm6
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm6, xmm6, xmm9, 170
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm6, xmm6
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm6, xmm3, xmm6
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm30, xmm0, xmm6
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpand	xmm6, xmm8, xmm1
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpmullw	xmm6, xmm6, xmm6
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm0, xmm10, xmm9, 170
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm0, xmm0
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm6, xmm6, xmm9, 170
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm6, xmm6
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm0, xmm31, xmm0
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm6, xmm4, xmm6
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm0, xmm0, xmm6
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpandq	xmm6, xmm20, xmm8
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpmullw	xmm6, xmm6, xmm6
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm6, xmm6, xmm9, 170
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm6, xmm6
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm6, xmm27, xmm6
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm0, xmm0, xmm6
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpand	xmm6, xmm8, xmm7
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpmullw	xmm6, xmm6, xmm6
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm6, xmm6, xmm9, 170
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm6, xmm6
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm6, xmm3, xmm6
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm0, xmm0, xmm6
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpsrld	xmm2, xmm2, 24
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm2, xmm2
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm2, xmm31, xmm2
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpsrld	xmm1, xmm1, 24
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm1, xmm1
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm1, xmm4, xmm1
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm1, xmm2, xmm1
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpsrld	xmm2, xmm20, 24
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovaps	xmm20, xmm22
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovaps	xmm22, xmm24
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm2, xmm2
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm2, xmm27, xmm2
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovaps	xmm27, xmm21
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovaps	xmm21, xmm23
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovdqa64	xmm23, xmm19
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpsrld	xmm4, xmm7, 24
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm1, xmm1, xmm2
 -      -      -      -     0.50   0.50    -      -      -      -      -      -     vmovdqu	xmm7, xmmword ptr [r8 + 4*rbp]
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm2, xmm4
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm2, xmm3, xmm2
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpshufb	xmm3, xmm7, xmm12
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm3, xmm3
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm4, xmm20, xmm5
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm1, xmm1, xmm2
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm5, xmm27, xmm1
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpordps	k1, xmm4, xmm4
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmaxps	xmm1 {k1} {z}, xmm9, xmm4
 -      -     1.00    -      -      -      -      -      -      -      -      -     vminps	xmm2, xmm26, xmm1
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm3, xmm3, xmm3
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpunordps	k1, xmm1, xmm1
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulps	xmm1, xmm13, xmm5
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vaddps	xmm4, xmm1, xmm25
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmulps	xmm1, xmm3, xmm4
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmovaps	xmm2 {k1}, xmm26
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vaddps	xmm1, xmm2, xmm1
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpshufb	xmm2, xmm7, xmm11
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm3, xmm21, xmm30
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm2, xmm2
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpordps	k1, xmm3, xmm3
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmaxps	xmm3 {k1} {z}, xmm9, xmm3
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpunordps	k1, xmm3, xmm3
 -      -     1.00    -      -      -      -      -      -      -      -      -     vminps	xmm3, xmm26, xmm3
 -      -     0.01    -      -      -      -     0.99    -      -      -      -     vmovaps	xmm3 {k1}, xmm26
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm2, xmm2, xmm2
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulps	xmm2, xmm2, xmm4
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vaddps	xmm2, xmm2, xmm3
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpandd	xmm3, xmm7, xmm19
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm3, xmm3
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm24, xmm0
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpordps	k1, xmm0, xmm0
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmaxps	xmm0 {k1} {z}, xmm9, xmm0
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpunordps	k1, xmm0, xmm0
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vminps	xmm0, xmm26, xmm0
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovaps	xmm0 {k1}, xmm26
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm3, xmm3, xmm3
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmulps	xmm3, xmm3, xmm4
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vaddps	xmm3, xmm3, xmm0
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovaps	xmm0, xmm1
 -      -     1.00    -      -      -      -      -      -      -      -      -     rsqrtps	xmm0, xmm0
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm1, xmm0, xmm1
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmovaps	xmm0, xmm2
 -      -     1.00    -      -      -      -      -      -      -      -      -     rsqrtps	xmm0, xmm0
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm2, xmm0, xmm2
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovaps	xmm0, xmm3
 -      -     1.00    -      -      -      -      -      -      -      -      -     rsqrtps	xmm0, xmm0
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulps	xmm3, xmm0, xmm3
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovaps	xmm0, xmm1
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     cvtps2dq	xmm0, xmm0
 -      -     0.01    -      -      -      -     0.99    -      -      -      -     vmovdqa	xmm1, xmm0
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovaps	xmm0, xmm2
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     cvtps2dq	xmm0, xmm0
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovdqa	xmm2, xmm0
 -      -     0.99    -      -      -      -     0.01    -      -      -      -     vmovaps	xmm0, xmm3
 -      -      -     1.00    -      -      -      -      -      -      -      -     cvtps2dq	xmm0, xmm0
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vpslld	xmm1, xmm1, 16
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vpslld	xmm2, xmm2, 8
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpternlogd	xmm2, xmm0, xmm1, 254
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpleps	k1, xmm9, xmm15
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpleps	k1 {k1}, xmm15, xmm25
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpleps	k1 {k1}, xmm9, xmm14
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpleps	k1 {k1}, xmm14, xmm25
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpsrld	xmm0, xmm7, 24
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm0, xmm0
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm4, xmm0
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovaps	xmm4, xmm16
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vaddps	xmm0, xmm5, xmm0
 -      -      -      -      -      -      -      -      -      -      -      -     vxorps	xmm5, xmm5, xmm5
 -      -      -      -     0.50   0.50    -      -      -      -      -      -     vmovaps	xmm6, xmmword ptr [rsp + 64]
 -      -      -     1.00    -      -      -      -      -      -      -      -     cvtps2dq	xmm0, xmm0
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpslld	xmm0, xmm0, 24
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     vpord	xmm7 {k1}, xmm2, xmm0
 -      -      -      -     0.50   0.50    -      -      -      -      -      -     vmovaps	xmm2, xmmword ptr [rsp + 48]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     vmovdqu	xmmword ptr [r8 + 4*rbp], xmm7
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm18, xmm18, xmm2


```
</details>

<details><summary>Timeline view:</summary>

```
                    0123456789          0123456789          0123456789          0123456789
Index     0123456789          0123456789          0123456789          0123456789          

[0,0]     DeeeeER   .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   vmulps	xmm0, xmm4, xmm18
[0,1]     DeeeeER   .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   vmulps	xmm1, xmm6, xmm18
[0,2]     D=eeeeeeeeeeER .    .    .    .    .    .    .    .    .    .    .    .    .   .   vaddps	xmm15, xmm0, xmmword ptr [rsp + 96]
[0,3]     D=eeeeeeeeeeER .    .    .    .    .    .    .    .    .    .    .    .    .   .   vaddps	xmm14, xmm1, xmmword ptr [rsp + 80]
[0,4]     .D==========eeeeER  .    .    .    .    .    .    .    .    .    .    .    .   .   vcmpordps	k1, xmm15, xmm15
[0,5]     .D==============eeeeER   .    .    .    .    .    .    .    .    .    .    .   .   vmaxps	xmm0 {k1} {z}, xmm9, xmm15
[0,6]     .D==================eeeeER    .    .    .    .    .    .    .    .    .    .   .   vminps	xmm1, xmm25, xmm0
[0,7]     .D==================eeeeER    .    .    .    .    .    .    .    .    .    .   .   vcmpunordps	k1, xmm0, xmm0
[0,8]     .D===========eeeeE-------R    .    .    .    .    .    .    .    .    .    .   .   vcmpordps	k2, xmm14, xmm14
[0,9]     .D===============eeeeE---R    .    .    .    .    .    .    .    .    .    .   .   vmaxps	xmm0 {k2} {z}, xmm9, xmm14
[0,10]    . D=====================eER   .    .    .    .    .    .    .    .    .    .   .   vmovaps	xmm1 {k1}, xmm25
[0,11]    . D==================eeeeER   .    .    .    .    .    .    .    .    .    .   .   vminps	xmm2, xmm25, xmm0
[0,12]    . D==================eeeeER   .    .    .    .    .    .    .    .    .    .   .   vcmpunordps	k1, xmm0, xmm0
[0,13]    . D======================eER  .    .    .    .    .    .    .    .    .    .   .   vmovaps	xmm2 {k1}, xmm25
[0,14]    . D======================eeeeER    .    .    .    .    .    .    .    .    .   .   vmulps	xmm0, xmm28, xmm1
[0,15]    . D=======================eeeeER   .    .    .    .    .    .    .    .    .   .   vmulps	xmm7, xmm17, xmm2
[0,16]    .  D=========================eeeeER.    .    .    .    .    .    .    .    .   .   vcvttps2dq	xmm1, xmm0
[0,17]    .  D==========================eeeeER    .    .    .    .    .    .    .    .   .   vcvttps2dq	xmm2, xmm7
[0,18]    .  D=============================eeeeER .    .    .    .    .    .    .    .   .   vcvtdq2ps	xmm3, xmm1
[0,19]    .  D=============================eE---R .    .    .    .    .    .    .    .   .   vpslld	xmm1, xmm1, 2
[0,20]    .  D==============================eeeeeeeeeeER    .    .    .    .    .    .   .   vpmulld	xmm6, xmm29, xmm2
[0,21]    .   D=======================================eER   .    .    .    .    .    .   .   vpaddd	xmm1, xmm1, xmm6
[0,22]    .   D========================================eeeeER    .    .    .    .    .   .   vpcmpgtd	k1, xmm1, xmm9
[0,23]    .   D========================================eE---R    .    .    .    .    .   .   vpsubd	xmm6, xmm9, xmm1
[0,24]    .   D=========================================eeeER    .    .    .    .    .   .   vpmovsxdq	ymm6, xmm6
[0,25]    .   D============================================eER   .    .    .    .    .   .   vpsubq	ymm6, ymm5, ymm6
[0,26]    .   D=============================eeeeE------------R   .    .    .    .    .   .   vcvtdq2ps	xmm5, xmm2
[0,27]    .    D============================================eeeER.    .    .    .    .   .   vpmovsxdq	ymm6 {k1}, xmm1
[0,28]    .    D===============================================eeeER  .    .    .    .   .   vpextrq	rax, xmm6, 1
[0,29]    .    D===============================eeeeE---------------R  .    .    .    .   .   vsubps	xmm3, xmm0, xmm3
[0,30]    .    D================================================eeER  .    .    .    .   .   vmovq	rsi, xmm6
[0,31]    .    D================================================eeeER .    .    .    .   .   vextracti128	xmm0, ymm6, 1
[0,32]    .    .D==================================================eeeER   .    .    .   .   vpextrq	rdi, xmm0, 1
[0,33]    .    .D=================================================eE---R   .    .    .   .   lea	rbx, [rcx + rsi]
[0,34]    .    .D=================================================eeeeeER  .    .    .   .   vmovd	xmm1, dword ptr [rcx + rsi]
[0,35]    .    .D=================================================eeeeeeER .    .    .   .   vpinsrd	xmm1, xmm1, dword ptr [rcx + rax], 1
[0,36]    .    . D==================================================eeE--R .    .    .   .   vmovq	rdx, xmm0
[0,37]    .    . D=================================================eeeeeER .    .    .   .   vmovd	xmm0, dword ptr [rcx + rsi + 4]
[0,38]    .    . D====================================================eeeeeeER  .    .   .   vpinsrd	xmm1, xmm1, dword ptr [rcx + rdx], 2
[0,39]    .    . D==================================================eeeeeeE--R  .    .   .   vpinsrd	xmm0, xmm0, dword ptr [rcx + rax + 4], 1
[0,40]    .    .  D====================================================eeeeeeER .    .   .   vpinsrd	xmm0, xmm0, dword ptr [rcx + rdx + 4], 2
[0,41]    .    .  D================================================eE---------R .    .   .   lea	rsi, [rcx + rax]
[0,42]    .    .  D================================================eeeeeE-----R .    .   .   vmovd	xmm6, dword ptr [r10 + rbx]
[0,43]    .    .  D=====================================================eeeeeeER.    .   .   vpinsrd	xmm2, xmm1, dword ptr [rcx + rdi], 3
[0,44]    .    .   D=================================================eeeeeeE---R.    .   .   vpinsrd	xmm6, xmm6, dword ptr [r10 + rsi], 1
[0,45]    .    .   D=====================================================eeeeeeER    .   .   vpinsrd	xmm1, xmm0, dword ptr [rcx + rdi + 4], 3
[0,46]    .    .   D==================================================eE--------R    .   .   lea	rax, [rcx + rdx]
[0,47]    .    .    D=====================================================eeeeeeER   .   .   vpinsrd	xmm0, xmm6, dword ptr [r10 + rax], 2
[0,48]    .    .    D===========================eeeeE----------------------------R   .   .   vsubps	xmm5, xmm7, xmm5
[0,49]    .    .    D==================================================eE--------R   .   .   lea	r14, [rcx + rdi]
[0,50]    .    .    DeE----------------------------------------------------------R   .   .   vmovaps	xmm24, xmm22
[0,51]    .    .    DeE----------------------------------------------------------R   .   .   vmovaps	xmm22, xmm20
[0,52]    .    .    .D=====================================================eeeeeeER  .   .   vpinsrd	xmm20, xmm0, dword ptr [r10 + r14], 3
[0,53]    .    .    .D========================================================eE--R  .   .   vpand	xmm6, xmm8, xmm2
[0,54]    .    .    .D=========================================================eeeeeER   .   vpmullw	xmm10, xmm6, xmm6
[0,55]    .    .    .D========================================================eE-----R   .   vpsrlw	xmm6, xmm2, 8
[0,56]    .    .    .D=========================================================eeeeeER   .   vpmullw	xmm0, xmm6, xmm6
[0,57]    .    .    . D=============================================================eER  .   vpsrld	xmm6, xmm10, 16
[0,58]    .    .    . DeE-------------------------------------------------------------R  .   vmovdqa64	xmm19, xmm23
[0,59]    .    .    . DeE-------------------------------------------------------------R  .   vmovaps	xmm23, xmm21
[0,60]    .    .    . D=eE------------------------------------------------------------R  .   vmovaps	xmm21, xmm27
[0,61]    .    .    . D============================eeeeE------------------------------R  .   vsubps	xmm27, xmm25, xmm3
[0,62]    .    .    . D=============================eeeeE-----------------------------R  .   vsubps	xmm30, xmm25, xmm5
[0,63]    .    .    .  D================================eeeeE-------------------------R  .   vmulps	xmm31, xmm30, xmm27
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
0.     10    9.1    0.1    30.6      vmulps	xmm0, xmm4, xmm18
1.     10    10.0   1.0    29.7      vmulps	xmm1, xmm6, xmm18
2.     10    9.2    0.1    25.2      vaddps	xmm15, xmm0, xmmword ptr [rsp + 96]
3.     10    11.0   1.9    22.5      vaddps	xmm14, xmm1, xmmword ptr [rsp + 80]
4.     10    19.1   0.9    20.7      vcmpordps	k1, xmm15, xmm15
5.     10    24.0   0.9    16.2      vmaxps	xmm0 {k1} {z}, xmm9, xmm15
6.     10    26.2   0.0    12.6      vminps	xmm1, xmm25, xmm0
7.     10    26.2   0.0    12.6      vcmpunordps	k1, xmm0, xmm0
8.     10    18.3   0.1    19.6      vcmpordps	k2, xmm14, xmm14
9.     10    22.3   0.0    15.6      vmaxps	xmm0 {k2} {z}, xmm9, xmm14
10.    10    29.2   0.0    11.7      vmovaps	xmm1 {k1}, xmm25
11.    10    25.3   0.0    11.7      vminps	xmm2, xmm25, xmm0
12.    10    24.4   0.0    11.7      vcmpunordps	k1, xmm0, xmm0
13.    10    27.5   0.0    10.8      vmovaps	xmm2 {k1}, xmm25
14.    10    27.5   0.0    8.1       vmulps	xmm0, xmm28, xmm1
15.    10    27.6   0.0    7.2       vmulps	xmm7, xmm17, xmm2
16.    10    31.4   0.9    3.6       vcvttps2dq	xmm1, xmm0
17.    10    31.5   0.9    2.7       vcvttps2dq	xmm2, xmm7
18.    10    34.5   0.0    0.0       vcvtdq2ps	xmm3, xmm1
19.    10    34.5   0.9    2.1       vpslld	xmm1, xmm1, 2
20.    10    34.6   0.0    0.0       vpmulld	xmm6, xmm29, xmm2
21.    10    44.5   0.0    0.0       vpaddd	xmm1, xmm1, xmm6
22.    10    44.6   0.0    0.0       vpcmpgtd	k1, xmm1, xmm9
23.    10    44.6   0.0    3.0       vpsubd	xmm6, xmm9, xmm1
24.    10    44.7   0.0    0.0       vpmovsxdq	ymm6, xmm6
25.    10    47.7   0.0    0.0       vpsubq	ymm6, ymm5, ymm6
26.    10    32.7   0.9    11.1      vcvtdq2ps	xmm5, xmm2
27.    10    47.7   0.0    0.0       vpmovsxdq	ymm6 {k1}, xmm1
28.    10    48.0   0.0    0.0       vpextrq	rax, xmm6, 1
29.    10    32.0   0.0    15.0      vsubps	xmm3, xmm0, xmm3
30.    10    49.0   1.0    0.0       vmovq	rsi, xmm6
31.    10    45.4   1.0    0.0       vextracti128	xmm0, ymm6, 1
32.    10    48.3   0.0    0.0       vpextrq	rdi, xmm0, 1
33.    10    47.3   0.0    3.0       lea	rbx, [rcx + rsi]
34.    10    46.4   0.0    0.0       vmovd	xmm1, dword ptr [rcx + rsi]
35.    10    46.4   0.0    0.0       vpinsrd	xmm1, xmm1, dword ptr [rcx + rax], 1
36.    10    48.3   1.0    2.0       vmovq	rdx, xmm0
37.    10    45.5   1.0    0.0       vmovd	xmm0, dword ptr [rcx + rsi + 4]
38.    10    47.6   0.0    0.0       vpinsrd	xmm1, xmm1, dword ptr [rcx + rdx], 2
39.    10    45.6   1.0    2.0       vpinsrd	xmm0, xmm0, dword ptr [rcx + rax + 4], 1
40.    10    47.6   1.0    0.0       vpinsrd	xmm0, xmm0, dword ptr [rcx + rdx + 4], 2
41.    10    43.6   1.0    9.0       lea	rsi, [rcx + rax]
42.    10    42.7   0.0    5.0       vmovd	xmm6, dword ptr [r10 + rbx]
43.    10    46.8   1.0    0.0       vpinsrd	xmm2, xmm1, dword ptr [rcx + rdi], 3
44.    10    42.8   1.0    3.0       vpinsrd	xmm6, xmm6, dword ptr [r10 + rsi], 1
45.    10    46.8   1.0    0.0       vpinsrd	xmm1, xmm0, dword ptr [rcx + rdi + 4], 3
46.    10    42.9   0.0    8.0       lea	rax, [rcx + rdx]
47.    10    46.8   3.0    0.0       vpinsrd	xmm0, xmm6, dword ptr [r10 + rax], 2
48.    10    21.7   0.0    27.1      vsubps	xmm5, xmm7, xmm5
49.    10    42.9   1.0    8.0       lea	r14, [rcx + rdi]
50.    10    1.9    1.9    49.0      vmovaps	xmm24, xmm22
51.    10    1.9    1.9    49.0      vmovaps	xmm22, xmm20
52.    10    45.9   0.0    0.0       vpinsrd	xmm20, xmm0, dword ptr [r10 + r14], 3
53.    10    48.9   0.0    2.0       vpand	xmm6, xmm8, xmm2
54.    10    49.9   0.0    0.0       vpmullw	xmm10, xmm6, xmm6
55.    10    48.0   0.0    5.0       vpsrlw	xmm6, xmm2, 8
56.    10    49.0   0.0    0.0       vpmullw	xmm0, xmm6, xmm6
57.    10    53.0   0.0    0.0       vpsrld	xmm6, xmm10, 16
58.    10    1.0    1.0    52.0      vmovdqa64	xmm19, xmm23
59.    10    1.9    1.9    50.2      vmovaps	xmm23, xmm21
60.    10    2.0    2.0    50.1      vmovaps	xmm21, xmm27
61.    10    19.1   0.0    30.0      vsubps	xmm27, xmm25, xmm3
62.    10    20.1   0.0    28.1      vsubps	xmm30, xmm25, xmm5
63.    10    24.0   0.0    24.1      vmulps	xmm31, xmm30, xmm27
64.    10    52.1   0.0    0.0       vcvtdq2ps	xmm6, xmm6
65.    10    1.0    1.0    53.2      vmovaps	xmm16, xmm4
66.    10    23.1   0.0    28.1      vmulps	xmm4, xmm3, xmm30
67.    10    21.2   0.0    30.0      vmulps	xmm27, xmm5, xmm27
68.    10    18.2   0.0    32.1      vmulps	xmm3, xmm5, xmm3
69.    10    54.2   0.0    0.0       vmulps	xmm5, xmm31, xmm6
70.    10    53.3   0.0    0.0       vmulps	xmm7, xmm4, xmm6
71.    10    57.3   0.0    0.0       vaddps	xmm5, xmm5, xmm7
72.    10    53.2   1.0    3.0       vmulps	xmm7, xmm27, xmm6
73.    10    60.1   0.0    0.0       vaddps	xmm5, xmm7, xmm5
74.    10    41.9   1.0    20.0      vpsrlw	xmm7, xmm1, 8
75.    10    42.9   0.0    15.0      vpmullw	xmm7, xmm7, xmm7
76.    10    44.9   0.0    16.0      vpblendw	xmm0, xmm0, xmm9, 170
77.    10    45.0   0.0    12.0      vcvtdq2ps	xmm0, xmm0
78.    10    44.8   0.0    14.0      vpblendw	xmm7, xmm7, xmm9, 170
79.    10    45.7   0.0    10.0      vcvtdq2ps	xmm7, xmm7
80.    10    47.8   1.0    7.0       vmulps	xmm0, xmm31, xmm0
81.    10    48.7   0.0    6.0       vmulps	xmm7, xmm4, xmm7
82.    10    51.5   0.0    2.0       vaddps	xmm0, xmm0, xmm7
83.    10    37.4   0.0    19.0      vpsrlw	xmm7, xmm20, 8
84.    10    38.1   0.0    14.0      vpmullw	xmm7, xmm7, xmm7
85.    10    42.2   0.0    13.0      vpblendw	xmm7, xmm7, xmm9, 170
86.    10    43.1   0.0    9.0       vcvtdq2ps	xmm7, xmm7
87.    10    46.2   0.0    5.0       vmulps	xmm7, xmm27, xmm7
88.    10    52.0   0.0    0.0       vaddps	xmm0, xmm0, xmm7
89.    10    19.1   1.0    30.0      vmovd	xmm7, dword ptr [r10 + rbx + 4]
90.    10    25.0   8.0    21.0      vpinsrd	xmm7, xmm7, dword ptr [r10 + rsi + 4], 1
91.    10    24.1   0.0    20.0      vpinsrd	xmm7, xmm7, dword ptr [r10 + rax + 4], 2
92.    10    25.1   0.0    19.0      vpinsrd	xmm7, xmm7, dword ptr [r10 + r14 + 4], 3
93.    10    37.0   2.0    8.0       vmulps	xmm6, xmm3, xmm6
94.    10    46.0   0.0    0.0       vaddps	xmm5, xmm6, xmm5
95.    10    29.0   0.0    20.0      vpsrlw	xmm6, xmm7, 8
96.    10    31.0   1.0    14.0      vpmullw	xmm6, xmm6, xmm6
97.    10    35.0   0.0    13.0      vpblendw	xmm6, xmm6, xmm9, 170
98.    10    35.1   0.0    9.0       vcvtdq2ps	xmm6, xmm6
99.    10    39.1   0.0    5.0       vmulps	xmm6, xmm3, xmm6
100.   10    44.0   0.0    0.0       vaddps	xmm30, xmm0, xmm6
101.   10    19.0   0.0    27.0      vpand	xmm6, xmm8, xmm1
102.   10    17.0   0.0    22.0      vpmullw	xmm6, xmm6, xmm6
103.   10    21.0   1.0    21.0      vpblendw	xmm0, xmm10, xmm9, 170
104.   10    22.0   0.0    17.0      vcvtdq2ps	xmm0, xmm0
105.   10    22.0   3.0    18.0      vpblendw	xmm6, xmm6, xmm9, 170
106.   10    27.0   4.0    10.0      vcvtdq2ps	xmm6, xmm6
107.   10    28.0   4.0    9.0       vmulps	xmm0, xmm31, xmm0
108.   10    30.0   0.0    6.0       vmulps	xmm6, xmm4, xmm6
109.   10    34.0   0.0    2.0       vaddps	xmm0, xmm0, xmm6
110.   10    14.0   0.0    25.0      vpandq	xmm6, xmm20, xmm8
111.   10    15.0   0.0    20.0      vpmullw	xmm6, xmm6, xmm6
112.   10    21.0   2.0    17.0      vpblendw	xmm6, xmm6, xmm9, 170
113.   10    26.0   4.0    9.0       vcvtdq2ps	xmm6, xmm6
114.   10    30.0   0.0    5.0       vmulps	xmm6, xmm27, xmm6
115.   10    36.0   0.0    0.0       vaddps	xmm0, xmm0, xmm6
116.   10    17.0   3.0    21.0      vpand	xmm6, xmm8, xmm7
117.   10    18.0   0.0    16.0      vpmullw	xmm6, xmm6, xmm6
118.   10    22.0   0.0    15.0      vpblendw	xmm6, xmm6, xmm9, 170
119.   10    24.0   1.0    10.0      vcvtdq2ps	xmm6, xmm6
120.   10    27.0   0.0    6.0       vmulps	xmm6, xmm3, xmm6
121.   10    36.0   0.0    0.0       vaddps	xmm0, xmm0, xmm6
122.   10    9.0    5.0    29.0      vpsrld	xmm2, xmm2, 24
123.   10    21.0   12.0   13.0      vcvtdq2ps	xmm2, xmm2
124.   10    24.0   0.0    9.0       vmulps	xmm2, xmm31, xmm2
125.   10    6.0    4.0    29.0      vpsrld	xmm1, xmm1, 24
126.   10    20.0   14.0   11.0      vcvtdq2ps	xmm1, xmm1
127.   10    24.0   0.0    7.0       vmulps	xmm1, xmm4, xmm1
128.   10    28.0   0.0    3.0       vaddps	xmm1, xmm2, xmm1
129.   10    21.0   19.0   12.0      vpsrld	xmm2, xmm20, 24
130.   10    1.0    1.0    32.0      vmovaps	xmm20, xmm22
131.   10    3.0    3.0    30.0      vmovaps	xmm22, xmm24
132.   10    22.0   1.0    7.0       vcvtdq2ps	xmm2, xmm2
133.   10    26.0   0.0    3.0       vmulps	xmm2, xmm27, xmm2
134.   10    3.0    3.0    29.0      vmovaps	xmm27, xmm21
135.   10    9.0    9.0    22.0      vmovaps	xmm21, xmm23
136.   10    11.0   11.0   20.0      vmovdqa64	xmm23, xmm19
137.   10    22.0   19.0   9.0       vpsrld	xmm4, xmm7, 24
138.   10    28.0   0.0    0.0       vaddps	xmm1, xmm1, xmm2
139.   10    1.0    1.0    25.0      vmovdqu	xmm7, xmmword ptr [r8 + 4*rbp]
140.   10    22.0   0.0    6.0       vcvtdq2ps	xmm2, xmm4
141.   10    25.0   0.0    2.0       vmulps	xmm2, xmm3, xmm2
142.   10    11.0   5.0    19.0      vpshufb	xmm3, xmm7, xmm12
143.   10    21.0   9.0    6.0       vcvtdq2ps	xmm3, xmm3
144.   10    22.0   0.0    5.0       vmulps	xmm4, xmm20, xmm5
145.   10    30.0   0.0    0.0       vaddps	xmm1, xmm1, xmm2
146.   10    34.0   0.0    0.0       vmulps	xmm5, xmm27, xmm1
147.   10    25.0   0.0    9.0       vcmpordps	k1, xmm4, xmm4
148.   10    28.0   0.0    5.0       vmaxps	xmm1 {k1} {z}, xmm9, xmm4
149.   10    32.0   0.0    1.0       vminps	xmm2, xmm26, xmm1
150.   10    23.0   0.0    10.0      vmulps	xmm3, xmm3, xmm3
151.   10    31.0   0.0    1.0       vcmpunordps	k1, xmm1, xmm1
152.   10    36.0   0.0    0.0       vmulps	xmm1, xmm13, xmm5
153.   10    40.0   0.0    0.0       vaddps	xmm4, xmm1, xmm25
154.   10    43.0   0.0    0.0       vmulps	xmm1, xmm3, xmm4
155.   10    34.0   0.0    12.0      vmovaps	xmm2 {k1}, xmm26
156.   10    47.0   0.0    0.0       vaddps	xmm1, xmm2, xmm1
157.   10    7.0    6.0    42.0      vpshufb	xmm2, xmm7, xmm11
158.   10    19.0   0.0    27.0      vmulps	xmm3, xmm21, xmm30
159.   10    19.0   11.0   27.0      vcvtdq2ps	xmm2, xmm2
160.   10    22.0   0.0    23.0      vcmpordps	k1, xmm3, xmm3
161.   10    26.0   0.0    19.0      vmaxps	xmm3 {k1} {z}, xmm9, xmm3
162.   10    30.0   0.0    15.0      vcmpunordps	k1, xmm3, xmm3
163.   10    29.0   0.0    15.0      vminps	xmm3, xmm26, xmm3
164.   10    33.0   0.0    14.0      vmovaps	xmm3 {k1}, xmm26
165.   10    21.0   0.0    23.0      vmulps	xmm2, xmm2, xmm2
166.   10    39.0   0.0    4.0       vmulps	xmm2, xmm2, xmm4
167.   10    43.0   0.0    0.0       vaddps	xmm2, xmm2, xmm3
168.   10    5.0    5.0    41.0      vpandd	xmm3, xmm7, xmm19
169.   10    17.0   12.0   25.0      vcvtdq2ps	xmm3, xmm3
170.   10    21.0   0.0    21.0      vmulps	xmm0, xmm24, xmm0
171.   10    26.0   1.0    16.0      vcmpordps	k1, xmm0, xmm0
172.   10    29.0   0.0    12.0      vmaxps	xmm0 {k1} {z}, xmm9, xmm0
173.   10    33.0   0.0    8.0       vcmpunordps	k1, xmm0, xmm0
174.   10    33.0   0.0    8.0       vminps	xmm0, xmm26, xmm0
175.   10    36.0   0.0    7.0       vmovaps	xmm0 {k1}, xmm26
176.   10    20.0   1.0    20.0      vmulps	xmm3, xmm3, xmm3
177.   10    37.0   1.0    3.0       vmulps	xmm3, xmm3, xmm4
178.   10    40.0   0.0    0.0       vaddps	xmm3, xmm3, xmm0
179.   10    43.0   0.0    0.0       vmovaps	xmm0, xmm1
180.   10    44.0   0.0    0.0       rsqrtps	xmm0, xmm0
181.   10    47.0   0.0    0.0       vmulps	xmm1, xmm0, xmm1
182.   10    42.0   0.0    8.0       vmovaps	xmm0, xmm2
183.   10    44.0   1.0    3.0       rsqrtps	xmm0, xmm0
184.   10    47.0   0.0    0.0       vmulps	xmm2, xmm0, xmm2
185.   10    42.0   0.0    8.0       vmovaps	xmm0, xmm3
186.   10    43.0   1.0    3.0       rsqrtps	xmm0, xmm0
187.   10    47.0   0.0    0.0       vmulps	xmm3, xmm0, xmm3
188.   10    48.0   0.0    1.0       vmovaps	xmm0, xmm1
189.   10    49.0   0.0    0.0       cvtps2dq	xmm0, xmm0
190.   10    52.0   0.0    0.0       vmovdqa	xmm1, xmm0
191.   10    48.0   0.0    4.0       vmovaps	xmm0, xmm2
192.   10    48.0   0.0    0.0       cvtps2dq	xmm0, xmm0
193.   10    52.0   0.0    0.0       vmovdqa	xmm2, xmm0
194.   10    47.0   0.0    4.0       vmovaps	xmm0, xmm3
195.   10    48.0   0.0    0.0       cvtps2dq	xmm0, xmm0
196.   10    50.0   0.0    0.0       vpslld	xmm1, xmm1, 16
197.   10    51.0   0.0    0.0       vpslld	xmm2, xmm2, 8
198.   10    51.0   0.0    0.0       vpternlogd	xmm2, xmm0, xmm1, 254
199.   10    1.0    1.0    47.0      vcmpleps	k1, xmm9, xmm15
200.   10    5.0    1.0    42.0      vcmpleps	k1 {k1}, xmm15, xmm25
201.   10    9.0    0.0    38.0      vcmpleps	k1 {k1}, xmm9, xmm14
202.   10    15.0   2.0    32.0      vcmpleps	k1 {k1}, xmm14, xmm25
203.   10    4.0    4.0    45.0      vpsrld	xmm0, xmm7, 24
204.   10    5.0    0.0    41.0      vcvtdq2ps	xmm0, xmm0
205.   10    24.0   1.0    21.0      vmulps	xmm0, xmm4, xmm0
206.   10    1.0    1.0    47.0      vmovaps	xmm4, xmm16
207.   10    27.0   0.0    17.0      vaddps	xmm0, xmm5, xmm0
208.   10    0.0    0.0    48.0      vxorps	xmm5, xmm5, xmm5
209.   10    1.0    1.0    41.0      vmovaps	xmm6, xmmword ptr [rsp + 64]
210.   10    31.0   0.0    13.0      cvtps2dq	xmm0, xmm0
211.   10    34.0   0.0    12.0      vpslld	xmm0, xmm0, 24
212.   10    47.0   0.0    0.0       vpord	xmm7 {k1}, xmm2, xmm0
213.   10    1.0    1.0    41.0      vmovaps	xmm2, xmmword ptr [rsp + 48]
214.   10    48.0   0.0    0.0       vmovdqu	xmmword ptr [r8 + 4*rbp], xmm7
215.   10    6.0    0.0    38.0      vaddps	xmm18, xmm18, xmm2
       10    30.9   1.1    12.7      <total>
```
</details>
</details>

### After masking the initial pixels (earlying out the fillRect tests) 

<details><summary>[0] Code Region - ProcessPixel</summary>

```
Iterations:        100
Instructions:      18600
Total Cycles:      7431
Total uOps:        20200

Dispatch Width:    6
uOps Per Cycle:    2.72
IPC:               2.50
Block RThroughput: 53.5


Cycles with backend pressure increase [ 95.26% ]
Throughput Bottlenecks: 
  Resource Pressure       [ 84.51% ]
  - ICXPort0  [ 71.09% ]
  - ICXPort1  [ 63.09% ]
  - ICXPort2  [ 6.65% ]
  - ICXPort3  [ 6.65% ]
  - ICXPort5  [ 49.60% ]
  - ICXPort6  [ 4.00% ]
  Data Dependencies:      [ 34.96% ]
  - Register Dependencies [ 34.96% ]
  - Memory Dependencies   [ 0.00% ]

```

<details><summary>Critical sequence based on the simulation:</summary>

```

              Instruction                                 Dependency Information
 +----< 143.  vcmpunordps	k2, xmm3, xmm3
 |
 |    < loop carried > 
 |
 |      0.    vpcmpgtd	k2, xmm5, xmm15
 |      1.    vpmovsxdq	ymm7, xmm5
 +----> 2.    vpmovzxdq	ymm7 {k2}, xmm5                   ## RESOURCE interference:  ICXPort5 [ probability: 98% ]
 |      3.    vcvtdq2ps	xmm3, xmm3
 +----> 4.    vpaddq	ymm5, ymm12, ymm7                 ## REGISTER dependency:  ymm7
 +----> 5.    vpextrq	rbp, xmm5, 1                      ## REGISTER dependency:  ymm5
 |      6.    vmovaps	xmm29, xmm18
 |      7.    vsubps	xmm18, xmm0, xmm3
 |      8.    vcvtdq2ps	xmm0, xmm2
 |      9.    vextracti128	xmm2, ymm5, 1
 |      10.   vpextrq	rdx, xmm2, 1
 +----> 11.   vmovq	rdi, xmm5                         ## RESOURCE interference:  ICXPort0 [ probability: 99% ]
 |      12.   vmovd	xmm3, dword ptr [rdi + 4]
 |      13.   vpinsrd	xmm3, xmm3, dword ptr [rbp + 4], 1
 |      14.   vmovq	rsi, xmm2
 |      15.   vpinsrd	xmm2, xmm3, dword ptr [rsi + 4], 2
 |      16.   vsubps	xmm5, xmm1, xmm0
 |      17.   vxorps	xmm0, xmm0, xmm0
 |      18.   vmovd	xmm3, dword ptr [rdi + rax]
 |      19.   vmovaps	xmm27, xmm23
 |      20.   vpinsrd	xmm23, xmm2, dword ptr [rdx + 4], 3
 |      21.   vpinsrd	xmm2, xmm3, dword ptr [rbp + rax], 1
 |      22.   vpinsrd	xmm2, xmm2, dword ptr [rsi + rax], 2
 |      23.   kxnorw	k2, k0, k0
 |      24.   vmovd	xmm3, dword ptr [rdi + rax + 4]
 |      25.   vpinsrd	xmm3, xmm3, dword ptr [rbp + rax + 4], 1
 |      26.   vpinsrd	xmm6, xmm3, dword ptr [rsi + rax + 4], 2
 |      27.   vpinsrd	xmm3, xmm2, dword ptr [rdx + rax], 3
 +----> 28.   vpgatherqd	xmm0 {k2}, xmmword ptr [r11 + ymm7] ## RESOURCE interference:  ICXPort0 [ probability: 99% ]
 +----> 29.   vpand	xmm7, xmm8, xmm0                  ## REGISTER dependency:  xmm0
 |      30.   vpinsrd	xmm24, xmm6, dword ptr [rdx + rax + 4], 3
 +----> 31.   vpmullw	xmm11, xmm7, xmm7                 ## REGISTER dependency:  xmm7
 +----> 32.   vsubps	xmm6, xmm28, xmm18                ## RESOURCE interference:  ICXPort0 [ probability: 98% ]
 |      33.   vsubps	xmm7, xmm28, xmm5
 |      34.   vmovaps	xmm1, xmm19
 |      35.   vpsrld	xmm19, xmm11, 16
 |      36.   vmovaps	xmm25, xmm21
 |      37.   vmulps	xmm21, xmm7, xmm6
 |      38.   vmulps	xmm7, xmm18, xmm7
 |      39.   vmulps	xmm6, xmm5, xmm6
 |      40.   vcvtdq2ps	xmm4, xmm19
 |      41.   vmovaps	xmm19, xmm1
 |      42.   vmulps	xmm5, xmm5, xmm18
 |      43.   vmulps	xmm18, xmm21, xmm4
 |      44.   vmulps	xmm1, xmm7, xmm4
 |      45.   vaddps	xmm1, xmm18, xmm1
 |      46.   vmulps	xmm2, xmm6, xmm4
 |      47.   vaddps	xmm1, xmm2, xmm1
 +----> 48.   vpsrlw	xmm2, xmm0, 8                     ## RESOURCE interference:  ICXPort0 [ probability: 98% ]
 +----> 49.   vpmullw	xmm2, xmm2, xmm2                  ## REGISTER dependency:  xmm2
 |      50.   vmulps	xmm4, xmm5, xmm4
 |      51.   vaddps	xmm18, xmm4, xmm1
 |      52.   vpsrlw	xmm4, xmm23, 8
 |      53.   vpmullw	xmm4, xmm4, xmm4
 |      54.   vpblendw	xmm2, xmm2, xmm15, 170
 |      55.   vcvtdq2ps	xmm2, xmm2
 |      56.   vpblendw	xmm4, xmm4, xmm15, 170
 |      57.   vcvtdq2ps	xmm4, xmm4
 |      58.   vmulps	xmm2, xmm21, xmm2
 |      59.   vmulps	xmm4, xmm7, xmm4
 |      60.   vaddps	xmm2, xmm2, xmm4
 |      61.   vpsrlw	xmm4, xmm3, 8
 +----> 62.   vpmullw	xmm4, xmm4, xmm4                  ## RESOURCE interference:  ICXPort0 [ probability: 1% ]
 +----> 63.   vpblendw	xmm4, xmm4, xmm15, 170            ## REGISTER dependency:  xmm4
 +----> 64.   vcvtdq2ps	xmm4, xmm4                        ## REGISTER dependency:  xmm4
 |      65.   vmulps	xmm4, xmm6, xmm4
 |      66.   vaddps	xmm2, xmm2, xmm4
 |      67.   vpandq	xmm4, xmm23, xmm8
 |      68.   vpmullw	xmm4, xmm4, xmm4
 |      69.   vpblendw	xmm1, xmm11, xmm15, 170
 |      70.   vcvtdq2ps	xmm1, xmm1
 |      71.   vpblendw	xmm4, xmm4, xmm15, 170
 |      72.   vmulps	xmm1, xmm21, xmm1
 |      73.   vcvtdq2ps	xmm4, xmm4
 |      74.   vmulps	xmm4, xmm7, xmm4
 |      75.   vaddps	xmm1, xmm1, xmm4
 |      76.   vpsrlw	xmm4, xmm24, 8
 |      77.   vpmullw	xmm4, xmm4, xmm4
 |      78.   vpblendw	xmm4, xmm4, xmm15, 170
 |      79.   vcvtdq2ps	xmm4, xmm4
 |      80.   vmulps	xmm4, xmm5, xmm4
 |      81.   vaddps	xmm2, xmm2, xmm4
 +----> 82.   vpand	xmm4, xmm8, xmm3                  ## RESOURCE interference:  ICXPort0 [ probability: 98% ]
 +----> 83.   vpmullw	xmm4, xmm4, xmm4                  ## REGISTER dependency:  xmm4
 |      84.   vpblendw	xmm4, xmm4, xmm15, 170
 |      85.   vcvtdq2ps	xmm4, xmm4
 |      86.   vmulps	xmm4, xmm6, xmm4
 |      87.   vaddps	xmm1, xmm1, xmm4
 +----> 88.   vpandq	xmm4, xmm24, xmm8                 ## RESOURCE interference:  ICXPort1 [ probability: 99% ]
 +----> 89.   vpmullw	xmm4, xmm4, xmm4                  ## REGISTER dependency:  xmm4
 |      90.   vpblendw	xmm4, xmm4, xmm15, 170
 |      91.   vcvtdq2ps	xmm4, xmm4
 |      92.   vmulps	xmm4, xmm5, xmm4
 |      93.   vaddps	xmm4, xmm1, xmm4
 +----> 94.   vpsrld	xmm0, xmm0, 24                    ## RESOURCE interference:  ICXPort1 [ probability: 99% ]
 +----> 95.   vcvtdq2ps	xmm0, xmm0                        ## REGISTER dependency:  xmm0
 +----> 96.   vmulps	xmm0, xmm21, xmm0                 ## REGISTER dependency:  xmm0
 |      97.   vmovaps	xmm21, xmm25
 +----> 98.   vpsrld	xmm1, xmm23, 24                   ## RESOURCE interference:  ICXPort0 [ probability: 98% ]
 |      99.   vmovaps	xmm23, xmm27
 +----> 100.  vcvtdq2ps	xmm1, xmm1                        ## REGISTER dependency:  xmm1
 |      101.  vmulps	xmm1, xmm7, xmm1
 |      102.  vaddps	xmm0, xmm0, xmm1
 +----> 103.  vpsrld	xmm1, xmm3, 24                    ## RESOURCE interference:  ICXPort0 [ probability: 99% ]
 +----> 104.  vcvtdq2ps	xmm1, xmm1                        ## REGISTER dependency:  xmm1
 |      105.  vmulps	xmm1, xmm6, xmm1
 |      106.  vaddps	xmm0, xmm0, xmm1
 |      107.  vmovdqu	xmm7, xmmword ptr [rcx + 4*rbx]
 +----> 108.  vpsrld	xmm1, xmm24, 24                   ## RESOURCE interference:  ICXPort0 [ probability: 99% ]
 +----> 109.  vcvtdq2ps	xmm1, xmm1                        ## REGISTER dependency:  xmm1
 +----> 110.  vmulps	xmm1, xmm5, xmm1                  ## REGISTER dependency:  xmm1
 |      111.  vpshufb	xmm3, xmm7, xmm26
 |      112.  vcvtdq2ps	xmm3, xmm3
 +----> 113.  vaddps	xmm0, xmm0, xmm1                  ## REGISTER dependency:  xmm1
 +----> 114.  vmulps	xmm5, xmm27, xmm0                 ## REGISTER dependency:  xmm0
 |      115.  vmulps	xmm0, xmm25, xmm18
 |      116.  vmovaps	xmm18, xmm29
 |      117.  vcmpordps	k2, xmm0, xmm0
 |      118.  vmaxps	xmm0 {k2} {z}, xmm15, xmm0
 |      119.  vminps	xmm1, xmm20, xmm0
 |      120.  vcmpunordps	k2, xmm0, xmm0
 |      121.  vmovaps	xmm1 {k2}, xmm20
 |      122.  vmulps	xmm0, xmm3, xmm3
 +----> 123.  vmulps	xmm3, xmm5, xmm30                 ## REGISTER dependency:  xmm5
 +----> 124.  vaddps	xmm6, xmm3, xmm28                 ## REGISTER dependency:  xmm3
 +----> 125.  vmulps	xmm0, xmm0, xmm6                  ## REGISTER dependency:  xmm6
 +----> 126.  vaddps	xmm1, xmm1, xmm0                  ## REGISTER dependency:  xmm0
 |      127.  vpshufb	xmm0, xmm7, xmm14
 |      128.  vcvtdq2ps	xmm0, xmm0
 |      129.  vmulps	xmm2, xmm29, xmm2
 |      130.  vcmpordps	k2, xmm2, xmm2
 |      131.  vmaxps	xmm2 {k2} {z}, xmm15, xmm2
 |      132.  vcmpunordps	k2, xmm2, xmm2
 |      133.  vminps	xmm2, xmm20, xmm2
 |      134.  vmulps	xmm0, xmm0, xmm0
 |      135.  vmulps	xmm0, xmm0, xmm6
 |      136.  vmovaps	xmm2 {k2}, xmm20
 |      137.  vaddps	xmm2, xmm0, xmm2
 |      138.  vpand	xmm0, xmm13, xmm7
 |      139.  vmulps	xmm3, xmm19, xmm4
 |      140.  vcvtdq2ps	xmm0, xmm0
 |      141.  vcmpordps	k2, xmm3, xmm3
 |      142.  vmaxps	xmm3 {k2} {z}, xmm15, xmm3
 |      143.  vcmpunordps	k2, xmm3, xmm3
 |      144.  vminps	xmm3, xmm20, xmm3
 |      145.  vmovaps	xmm3 {k2}, xmm20
 |      146.  vmulps	xmm0, xmm0, xmm0
 |      147.  vmulps	xmm0, xmm0, xmm6
 |      148.  vaddps	xmm3, xmm0, xmm3
 +----> 149.  vmovaps	xmm0, xmm1                        ## REGISTER dependency:  xmm1
 +----> 150.  rsqrtps	xmm0, xmm0                        ## REGISTER dependency:  xmm0
 |      151.  vmulps	xmm1, xmm0, xmm1
 |      152.  vmovaps	xmm0, xmm2
 +----> 153.  rsqrtps	xmm0, xmm0                        ## RESOURCE interference:  ICXPort0 [ probability: 99% ]
 |      154.  vmulps	xmm2, xmm0, xmm2
 |      155.  vmovaps	xmm0, xmm3
 |      156.  rsqrtps	xmm0, xmm0
 |      157.  vmulps	xmm3, xmm0, xmm3
 |      158.  vmovaps	xmm0, xmm1
 |      159.  cvtps2dq	xmm0, xmm0
 |      160.  vmovdqa	xmm1, xmm0
 |      161.  vmovaps	xmm0, xmm2
 |      162.  cvtps2dq	xmm0, xmm0
 |      163.  vmovdqa	xmm2, xmm0
 |      164.  vmovaps	xmm0, xmm3
 |      165.  cvtps2dq	xmm0, xmm0
 |      166.  vpslld	xmm1, xmm1, 16
 |      167.  vpslld	xmm2, xmm2, 8
 |      168.  vpternlogd	xmm2, xmm0, xmm1, 254
 |      169.  vcmpleps	k1 {k1}, xmm17, xmm28
 |      170.  vcmpleps	k1 {k1}, xmm15, xmm17
 |      171.  vpsrld	xmm0, xmm7, 24
 |      172.  vcvtdq2ps	xmm0, xmm0
 |      173.  vmulps	xmm0, xmm6, xmm0
 |      174.  vaddps	xmm0, xmm5, xmm0
 |      175.  vcmpleps	k1 {k1}, xmm15, xmm16
 |      176.  vcmpleps	k1 {k1}, xmm16, xmm28
 +----> 177.  cvtps2dq	xmm0, xmm0                        ## RESOURCE interference:  ICXPort0 [ probability: 99% ]
 +----> 178.  vpslld	xmm0, xmm0, 24                    ## REGISTER dependency:  xmm0
 +----> 179.  vpord	xmm7 {k1}, xmm2, xmm0             ## REGISTER dependency:  xmm0
 |      180.  vmovaps	xmm5, xmmword ptr [rsp + 80]
 |      181.  vmovaps	xmm3, xmmword ptr [rsp + 96]
 |      182.  vmovaps	xmm2, xmmword ptr [rsp + 112]
 |      183.  vmovdqu	xmmword ptr [rcx + 4*rbx], xmm7
 |      184.  vaddps	xmm22, xmm22, xmm31
 |      185.  kxnorw	k1, k0, k0
 |
 |    < loop carried > 
 |
 +----> 82.   vpand	xmm4, xmm8, xmm3                  ## RESOURCE interference:  ICXPort5 [ probability: 99% ]


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
 1      4     1.00                        vpcmpgtd	k2, xmm5, xmm15
 1      3     1.00                        vpmovsxdq	ymm7, xmm5
 1      3     1.00                        vpmovzxdq	ymm7 {k2}, xmm5
 1      4     0.50                        vcvtdq2ps	xmm3, xmm3
 1      1     0.33                        vpaddq	ymm5, ymm12, ymm7
 2      3     1.00                        vpextrq	rbp, xmm5, 1
 1      1     0.33                        vmovaps	xmm29, xmm18
 1      4     0.50                        vsubps	xmm18, xmm0, xmm3
 1      4     0.50                        vcvtdq2ps	xmm0, xmm2
 1      3     1.00                        vextracti128	xmm2, ymm5, 1
 2      3     1.00                        vpextrq	rdx, xmm2, 1
 1      2     1.00                        vmovq	rdi, xmm5
 1      5     0.50    *                   vmovd	xmm3, dword ptr [rdi + 4]
 2      6     1.00    *                   vpinsrd	xmm3, xmm3, dword ptr [rbp + 4], 1
 1      2     1.00                        vmovq	rsi, xmm2
 2      6     1.00    *                   vpinsrd	xmm2, xmm3, dword ptr [rsi + 4], 2
 1      4     0.50                        vsubps	xmm5, xmm1, xmm0
 1      0     0.17                        vxorps	xmm0, xmm0, xmm0
 1      5     0.50    *                   vmovd	xmm3, dword ptr [rdi + rax]
 1      1     0.33                        vmovaps	xmm27, xmm23
 2      6     1.00    *                   vpinsrd	xmm23, xmm2, dword ptr [rdx + 4], 3
 2      6     1.00    *                   vpinsrd	xmm2, xmm3, dword ptr [rbp + rax], 1
 2      6     1.00    *                   vpinsrd	xmm2, xmm2, dword ptr [rsi + rax], 2
 1      1     1.00                        kxnorw	k2, k0, k0
 1      5     0.50    *                   vmovd	xmm3, dword ptr [rdi + rax + 4]
 2      6     1.00    *                   vpinsrd	xmm3, xmm3, dword ptr [rbp + rax + 4], 1
 2      6     1.00    *                   vpinsrd	xmm6, xmm3, dword ptr [rsi + rax + 4], 2
 2      6     1.00    *                   vpinsrd	xmm3, xmm2, dword ptr [rdx + rax], 3
 5      19    2.00    *                   vpgatherqd	xmm0 {k2}, xmmword ptr [r11 + ymm7]
 1      1     0.33                        vpand	xmm7, xmm8, xmm0
 2      6     1.00    *                   vpinsrd	xmm24, xmm6, dword ptr [rdx + rax + 4], 3
 1      5     0.50                        vpmullw	xmm11, xmm7, xmm7
 1      4     0.50                        vsubps	xmm6, xmm28, xmm18
 1      4     0.50                        vsubps	xmm7, xmm28, xmm5
 1      1     0.33                        vmovaps	xmm1, xmm19
 1      1     0.50                        vpsrld	xmm19, xmm11, 16
 1      1     0.33                        vmovaps	xmm25, xmm21
 1      4     0.50                        vmulps	xmm21, xmm7, xmm6
 1      4     0.50                        vmulps	xmm7, xmm18, xmm7
 1      4     0.50                        vmulps	xmm6, xmm5, xmm6
 1      4     0.50                        vcvtdq2ps	xmm4, xmm19
 1      1     0.33                        vmovaps	xmm19, xmm1
 1      4     0.50                        vmulps	xmm5, xmm5, xmm18
 1      4     0.50                        vmulps	xmm18, xmm21, xmm4
 1      4     0.50                        vmulps	xmm1, xmm7, xmm4
 1      4     0.50                        vaddps	xmm1, xmm18, xmm1
 1      4     0.50                        vmulps	xmm2, xmm6, xmm4
 1      4     0.50                        vaddps	xmm1, xmm2, xmm1
 1      1     0.50                        vpsrlw	xmm2, xmm0, 8
 1      5     0.50                        vpmullw	xmm2, xmm2, xmm2
 1      4     0.50                        vmulps	xmm4, xmm5, xmm4
 1      4     0.50                        vaddps	xmm18, xmm4, xmm1
 1      1     0.50                        vpsrlw	xmm4, xmm23, 8
 1      5     0.50                        vpmullw	xmm4, xmm4, xmm4
 1      1     1.00                        vpblendw	xmm2, xmm2, xmm15, 170
 1      4     0.50                        vcvtdq2ps	xmm2, xmm2
 1      1     1.00                        vpblendw	xmm4, xmm4, xmm15, 170
 1      4     0.50                        vcvtdq2ps	xmm4, xmm4
 1      4     0.50                        vmulps	xmm2, xmm21, xmm2
 1      4     0.50                        vmulps	xmm4, xmm7, xmm4
 1      4     0.50                        vaddps	xmm2, xmm2, xmm4
 1      1     0.50                        vpsrlw	xmm4, xmm3, 8
 1      5     0.50                        vpmullw	xmm4, xmm4, xmm4
 1      1     1.00                        vpblendw	xmm4, xmm4, xmm15, 170
 1      4     0.50                        vcvtdq2ps	xmm4, xmm4
 1      4     0.50                        vmulps	xmm4, xmm6, xmm4
 1      4     0.50                        vaddps	xmm2, xmm2, xmm4
 1      1     0.33                        vpandq	xmm4, xmm23, xmm8
 1      5     0.50                        vpmullw	xmm4, xmm4, xmm4
 1      1     1.00                        vpblendw	xmm1, xmm11, xmm15, 170
 1      4     0.50                        vcvtdq2ps	xmm1, xmm1
 1      1     1.00                        vpblendw	xmm4, xmm4, xmm15, 170
 1      4     0.50                        vmulps	xmm1, xmm21, xmm1
 1      4     0.50                        vcvtdq2ps	xmm4, xmm4
 1      4     0.50                        vmulps	xmm4, xmm7, xmm4
 1      4     0.50                        vaddps	xmm1, xmm1, xmm4
 1      1     0.50                        vpsrlw	xmm4, xmm24, 8
 1      5     0.50                        vpmullw	xmm4, xmm4, xmm4
 1      1     1.00                        vpblendw	xmm4, xmm4, xmm15, 170
 1      4     0.50                        vcvtdq2ps	xmm4, xmm4
 1      4     0.50                        vmulps	xmm4, xmm5, xmm4
 1      4     0.50                        vaddps	xmm2, xmm2, xmm4
 1      1     0.33                        vpand	xmm4, xmm8, xmm3
 1      5     0.50                        vpmullw	xmm4, xmm4, xmm4
 1      1     1.00                        vpblendw	xmm4, xmm4, xmm15, 170
 1      4     0.50                        vcvtdq2ps	xmm4, xmm4
 1      4     0.50                        vmulps	xmm4, xmm6, xmm4
 1      4     0.50                        vaddps	xmm1, xmm1, xmm4
 1      1     0.33                        vpandq	xmm4, xmm24, xmm8
 1      5     0.50                        vpmullw	xmm4, xmm4, xmm4
 1      1     1.00                        vpblendw	xmm4, xmm4, xmm15, 170
 1      4     0.50                        vcvtdq2ps	xmm4, xmm4
 1      4     0.50                        vmulps	xmm4, xmm5, xmm4
 1      4     0.50                        vaddps	xmm4, xmm1, xmm4
 1      1     0.50                        vpsrld	xmm0, xmm0, 24
 1      4     0.50                        vcvtdq2ps	xmm0, xmm0
 1      4     0.50                        vmulps	xmm0, xmm21, xmm0
 1      1     0.33                        vmovaps	xmm21, xmm25
 1      1     0.50                        vpsrld	xmm1, xmm23, 24
 1      1     0.33                        vmovaps	xmm23, xmm27
 1      4     0.50                        vcvtdq2ps	xmm1, xmm1
 1      4     0.50                        vmulps	xmm1, xmm7, xmm1
 1      4     0.50                        vaddps	xmm0, xmm0, xmm1
 1      1     0.50                        vpsrld	xmm1, xmm3, 24
 1      4     0.50                        vcvtdq2ps	xmm1, xmm1
 1      4     0.50                        vmulps	xmm1, xmm6, xmm1
 1      4     0.50                        vaddps	xmm0, xmm0, xmm1
 1      6     0.50    *                   vmovdqu	xmm7, xmmword ptr [rcx + 4*rbx]
 1      1     0.50                        vpsrld	xmm1, xmm24, 24
 1      4     0.50                        vcvtdq2ps	xmm1, xmm1
 1      4     0.50                        vmulps	xmm1, xmm5, xmm1
 1      1     0.50                        vpshufb	xmm3, xmm7, xmm26
 1      4     0.50                        vcvtdq2ps	xmm3, xmm3
 1      4     0.50                        vaddps	xmm0, xmm0, xmm1
 1      4     0.50                        vmulps	xmm5, xmm27, xmm0
 1      4     0.50                        vmulps	xmm0, xmm25, xmm18
 1      1     0.33                        vmovaps	xmm18, xmm29
 1      4     1.00                        vcmpordps	k2, xmm0, xmm0
 1      4     0.50                        vmaxps	xmm0 {k2} {z}, xmm15, xmm0
 1      4     0.50                        vminps	xmm1, xmm20, xmm0
 1      4     1.00                        vcmpunordps	k2, xmm0, xmm0
 1      1     0.33                        vmovaps	xmm1 {k2}, xmm20
 1      4     0.50                        vmulps	xmm0, xmm3, xmm3
 1      4     0.50                        vmulps	xmm3, xmm5, xmm30
 1      4     0.50                        vaddps	xmm6, xmm3, xmm28
 1      4     0.50                        vmulps	xmm0, xmm0, xmm6
 1      4     0.50                        vaddps	xmm1, xmm1, xmm0
 1      1     0.50                        vpshufb	xmm0, xmm7, xmm14
 1      4     0.50                        vcvtdq2ps	xmm0, xmm0
 1      4     0.50                        vmulps	xmm2, xmm29, xmm2
 1      4     1.00                        vcmpordps	k2, xmm2, xmm2
 1      4     0.50                        vmaxps	xmm2 {k2} {z}, xmm15, xmm2
 1      4     1.00                        vcmpunordps	k2, xmm2, xmm2
 1      4     0.50                        vminps	xmm2, xmm20, xmm2
 1      4     0.50                        vmulps	xmm0, xmm0, xmm0
 1      4     0.50                        vmulps	xmm0, xmm0, xmm6
 1      1     0.33                        vmovaps	xmm2 {k2}, xmm20
 1      4     0.50                        vaddps	xmm2, xmm0, xmm2
 1      1     0.33                        vpand	xmm0, xmm13, xmm7
 1      4     0.50                        vmulps	xmm3, xmm19, xmm4
 1      4     0.50                        vcvtdq2ps	xmm0, xmm0
 1      4     1.00                        vcmpordps	k2, xmm3, xmm3
 1      4     0.50                        vmaxps	xmm3 {k2} {z}, xmm15, xmm3
 1      4     1.00                        vcmpunordps	k2, xmm3, xmm3
 1      4     0.50                        vminps	xmm3, xmm20, xmm3
 1      1     0.33                        vmovaps	xmm3 {k2}, xmm20
 1      4     0.50                        vmulps	xmm0, xmm0, xmm0
 1      4     0.50                        vmulps	xmm0, xmm0, xmm6
 1      4     0.50                        vaddps	xmm3, xmm0, xmm3
 1      1     0.33                        vmovaps	xmm0, xmm1
 1      4     1.00                        rsqrtps	xmm0, xmm0
 1      4     0.50                        vmulps	xmm1, xmm0, xmm1
 1      1     0.33                        vmovaps	xmm0, xmm2
 1      4     1.00                        rsqrtps	xmm0, xmm0
 1      4     0.50                        vmulps	xmm2, xmm0, xmm2
 1      1     0.33                        vmovaps	xmm0, xmm3
 1      4     1.00                        rsqrtps	xmm0, xmm0
 1      4     0.50                        vmulps	xmm3, xmm0, xmm3
 1      1     0.33                        vmovaps	xmm0, xmm1
 1      4     0.50                        cvtps2dq	xmm0, xmm0
 1      1     0.33                        vmovdqa	xmm1, xmm0
 1      1     0.33                        vmovaps	xmm0, xmm2
 1      4     0.50                        cvtps2dq	xmm0, xmm0
 1      1     0.33                        vmovdqa	xmm2, xmm0
 1      1     0.33                        vmovaps	xmm0, xmm3
 1      4     0.50                        cvtps2dq	xmm0, xmm0
 1      1     0.50                        vpslld	xmm1, xmm1, 16
 1      1     0.50                        vpslld	xmm2, xmm2, 8
 1      1     0.33                        vpternlogd	xmm2, xmm0, xmm1, 254
 1      4     1.00                        vcmpleps	k1 {k1}, xmm17, xmm28
 1      4     1.00                        vcmpleps	k1 {k1}, xmm15, xmm17
 1      1     0.50                        vpsrld	xmm0, xmm7, 24
 1      4     0.50                        vcvtdq2ps	xmm0, xmm0
 1      4     0.50                        vmulps	xmm0, xmm6, xmm0
 1      4     0.50                        vaddps	xmm0, xmm5, xmm0
 1      4     1.00                        vcmpleps	k1 {k1}, xmm15, xmm16
 1      4     1.00                        vcmpleps	k1 {k1}, xmm16, xmm28
 1      4     0.50                        cvtps2dq	xmm0, xmm0
 1      1     0.50                        vpslld	xmm0, xmm0, 24
 1      1     0.33                        vpord	xmm7 {k1}, xmm2, xmm0
 1      6     0.50    *                   vmovaps	xmm5, xmmword ptr [rsp + 80]
 1      6     0.50    *                   vmovaps	xmm3, xmmword ptr [rsp + 96]
 1      6     0.50    *                   vmovaps	xmm2, xmmword ptr [rsp + 112]
 2      1     1.00           *            vmovdqu	xmmword ptr [rcx + 4*rbx], xmm7
 1      4     0.50                        vaddps	xmm22, xmm22, xmm31
 1      1     1.00                        kxnorw	k1, k0, k0


```
</details>

<details><summary>Dynamic Dispatch Stall Cycles:</summary>

```
RAT     - Register unavailable:                      0
RCU     - Retire tokens unavailable:                 0
SCHEDQ  - Scheduler full:                            7064  (95.1%)
LQ      - Load queue full:                           0
SQ      - Store queue full:                          0
GROUP   - Static restrictions on the dispatch group: 0
USH     - Uncategorised Structural Hazard:           0


```
</details>

<details><summary>Dispatch Logic - number of cycles where we saw N micro opcodes dispatched:</summary>

```
[# dispatched], [# cycles]
 0,              49  (0.7%)
 1,              693  (9.3%)
 2,              2198  (29.6%)
 3,              3482  (46.9%)
 4,              594  (8.0%)
 5,              201  (2.7%)
 6,              214  (2.9%)


```
</details>

<details><summary>Schedulers - number of cycles where we saw N micro opcodes issued:</summary>

```
[# issued], [# cycles]
 0,          15  (0.2%)
 1,          610  (8.2%)
 2,          2321  (31.2%)
 3,          3292  (44.3%)
 4,          993  (13.4%)
 5,          100  (1.3%)
 6,          100  (1.3%)

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
 0,           4517  (60.8%)
 1,           705  (9.5%)
 2,           605  (8.1%)
 3,           303  (4.1%)
 4,           402  (5.4%)
 5,           102  (1.4%)
 6,           99  (1.3%)
 7,           100  (1.3%)
 11,          100  (1.3%)
 12,          99  (1.3%)
 13,          99  (1.3%)
 22,          100  (1.3%)
 25,          1  (0.0%)
 30,          100  (1.3%)
 36,          99  (1.3%)

```
</details>

<details><summary>Total ROB Entries:                224</summary>

```
Max Used ROB Entries:             149  ( 66.5% )
Average Used ROB Entries per cy:  118  ( 52.7% )


```
</details>

<details><summary>Register File statistics:</summary>

```
Total number of mappings created:    18500
Max number of mappings used:         132


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
 -      -     65.02  65.00  9.99   10.01  1.00   49.98  1.00   1.00    -      -     

Resource pressure by instruction:
[0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   Instructions:
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpcmpgtd	k2, xmm5, xmm15
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpmovsxdq	ymm7, xmm5
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpmovzxdq	ymm7 {k2}, xmm5
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm3, xmm3
 -      -     0.01   0.98    -      -      -     0.01    -      -      -      -     vpaddq	ymm5, ymm12, ymm7
 -      -     1.00    -      -      -      -     1.00    -      -      -      -     vpextrq	rbp, xmm5, 1
 -      -     0.02   0.98    -      -      -      -      -      -      -      -     vmovaps	xmm29, xmm18
 -      -     1.00    -      -      -      -      -      -      -      -      -     vsubps	xmm18, xmm0, xmm3
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm0, xmm2
 -      -      -      -      -      -      -     1.00    -      -      -      -     vextracti128	xmm2, ymm5, 1
 -      -     1.00    -      -      -      -     1.00    -      -      -      -     vpextrq	rdx, xmm2, 1
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmovq	rdi, xmm5
 -      -      -      -     0.50   0.50    -      -      -      -      -      -     vmovd	xmm3, dword ptr [rdi + 4]
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpinsrd	xmm3, xmm3, dword ptr [rbp + 4], 1
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmovq	rsi, xmm2
 -      -      -      -     0.51   0.49    -     1.00    -      -      -      -     vpinsrd	xmm2, xmm3, dword ptr [rsi + 4], 2
 -      -     1.00    -      -      -      -      -      -      -      -      -     vsubps	xmm5, xmm1, xmm0
 -      -      -      -      -      -      -      -      -      -      -      -     vxorps	xmm0, xmm0, xmm0
 -      -      -      -     0.50   0.50    -      -      -      -      -      -     vmovd	xmm3, dword ptr [rdi + rax]
 -      -      -     0.02    -      -      -     0.98    -      -      -      -     vmovaps	xmm27, xmm23
 -      -      -      -     0.49   0.51    -     1.00    -      -      -      -     vpinsrd	xmm23, xmm2, dword ptr [rdx + 4], 3
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpinsrd	xmm2, xmm3, dword ptr [rbp + rax], 1
 -      -      -      -     0.51   0.49    -     1.00    -      -      -      -     vpinsrd	xmm2, xmm2, dword ptr [rsi + rax], 2
 -      -     1.00    -      -      -      -      -      -      -      -      -     kxnorw	k2, k0, k0
 -      -      -      -     0.49   0.51    -      -      -      -      -      -     vmovd	xmm3, dword ptr [rdi + rax + 4]
 -      -      -      -     0.49   0.51    -     1.00    -      -      -      -     vpinsrd	xmm3, xmm3, dword ptr [rbp + rax + 4], 1
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpinsrd	xmm6, xmm3, dword ptr [rsi + rax + 4], 2
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpinsrd	xmm3, xmm2, dword ptr [rdx + rax], 3
 -      -     1.00   0.02   2.00   2.00    -     0.98   1.00    -      -      -     vpgatherqd	xmm0 {k2}, xmmword ptr [r11 + ymm7]
 -      -     0.98   0.01    -      -      -     0.01    -      -      -      -     vpand	xmm7, xmm8, xmm0
 -      -      -      -     0.50   0.50    -     1.00    -      -      -      -     vpinsrd	xmm24, xmm6, dword ptr [rdx + rax + 4], 3
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpmullw	xmm11, xmm7, xmm7
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vsubps	xmm6, xmm28, xmm18
 -      -      -     1.00    -      -      -      -      -      -      -      -     vsubps	xmm7, xmm28, xmm5
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     vmovaps	xmm1, xmm19
 -      -     0.02   0.98    -      -      -      -      -      -      -      -     vpsrld	xmm19, xmm11, 16
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmovaps	xmm25, xmm21
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm21, xmm7, xmm6
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm7, xmm18, xmm7
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmulps	xmm6, xmm5, xmm6
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm4, xmm19
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmovaps	xmm19, xmm1
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulps	xmm5, xmm5, xmm18
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulps	xmm18, xmm21, xmm4
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmulps	xmm1, xmm7, xmm4
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vaddps	xmm1, xmm18, xmm1
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulps	xmm2, xmm6, xmm4
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vaddps	xmm1, xmm2, xmm1
 -      -     0.02   0.98    -      -      -      -      -      -      -      -     vpsrlw	xmm2, xmm0, 8
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vpmullw	xmm2, xmm2, xmm2
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmulps	xmm4, xmm5, xmm4
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vaddps	xmm18, xmm4, xmm1
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpsrlw	xmm4, xmm23, 8
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vpmullw	xmm4, xmm4, xmm4
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm2, xmm2, xmm15, 170
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm2, xmm2
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm4, xmm4, xmm15, 170
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm4, xmm4
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulps	xmm2, xmm21, xmm2
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm4, xmm7, xmm4
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vaddps	xmm2, xmm2, xmm4
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vpsrlw	xmm4, xmm3, 8
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vpmullw	xmm4, xmm4, xmm4
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm4, xmm4, xmm15, 170
 -      -     0.98   0.02    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm4, xmm4
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulps	xmm4, xmm6, xmm4
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vaddps	xmm2, xmm2, xmm4
 -      -     0.02    -      -      -      -     0.98    -      -      -      -     vpandq	xmm4, xmm23, xmm8
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpmullw	xmm4, xmm4, xmm4
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm1, xmm11, xmm15, 170
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm1, xmm1
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm4, xmm4, xmm15, 170
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm1, xmm21, xmm1
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm4, xmm4
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm4, xmm7, xmm4
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm1, xmm1, xmm4
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpsrlw	xmm4, xmm24, 8
 -      -     0.98   0.02    -      -      -      -      -      -      -      -     vpmullw	xmm4, xmm4, xmm4
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm4, xmm4, xmm15, 170
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm4, xmm4
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmulps	xmm4, xmm5, xmm4
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vaddps	xmm2, xmm2, xmm4
 -      -     0.99    -      -      -      -     0.01    -      -      -      -     vpand	xmm4, xmm8, xmm3
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpmullw	xmm4, xmm4, xmm4
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm4, xmm4, xmm15, 170
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm4, xmm4
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulps	xmm4, xmm6, xmm4
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm1, xmm1, xmm4
 -      -     0.99    -      -      -      -     0.01    -      -      -      -     vpandq	xmm4, xmm24, xmm8
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vpmullw	xmm4, xmm4, xmm4
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpblendw	xmm4, xmm4, xmm15, 170
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm4, xmm4
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulps	xmm4, xmm5, xmm4
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm4, xmm1, xmm4
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vpsrld	xmm0, xmm0, 24
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm0, xmm0
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm0, xmm21, xmm0
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     vmovaps	xmm21, xmm25
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vpsrld	xmm1, xmm23, 24
 -      -     0.01    -      -      -      -     0.99    -      -      -      -     vmovaps	xmm23, xmm27
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm1, xmm1
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmulps	xmm1, xmm7, xmm1
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm0, xmm0, xmm1
 -      -     0.98   0.02    -      -      -      -      -      -      -      -     vpsrld	xmm1, xmm3, 24
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvtdq2ps	xmm1, xmm1
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm1, xmm6, xmm1
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vaddps	xmm0, xmm0, xmm1
 -      -      -      -     0.50   0.50    -      -      -      -      -      -     vmovdqu	xmm7, xmmword ptr [rcx + 4*rbx]
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vpsrld	xmm1, xmm24, 24
 -      -      -     1.00    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm1, xmm1
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm1, xmm5, xmm1
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpshufb	xmm3, xmm7, xmm26
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm3, xmm3
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm0, xmm0, xmm1
 -      -     0.98   0.02    -      -      -      -      -      -      -      -     vmulps	xmm5, xmm27, xmm0
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm25, xmm18
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovaps	xmm18, xmm29
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpordps	k2, xmm0, xmm0
 -      -     0.98   0.02    -      -      -      -      -      -      -      -     vmaxps	xmm0 {k2} {z}, xmm15, xmm0
 -      -     0.98   0.02    -      -      -      -      -      -      -      -     vminps	xmm1, xmm20, xmm0
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpunordps	k2, xmm0, xmm0
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmovaps	xmm1 {k2}, xmm20
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm0, xmm3, xmm3
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm3, xmm5, xmm30
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vaddps	xmm6, xmm3, xmm28
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm0, xmm0, xmm6
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vaddps	xmm1, xmm1, xmm0
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpshufb	xmm0, xmm7, xmm14
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm0, xmm0
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulps	xmm2, xmm29, xmm2
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpordps	k2, xmm2, xmm2
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmaxps	xmm2 {k2} {z}, xmm15, xmm2
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpunordps	k2, xmm2, xmm2
 -      -     0.02   0.98    -      -      -      -      -      -      -      -     vminps	xmm2, xmm20, xmm2
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm0, xmm0
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm0, xmm6
 -      -     0.01   0.98    -      -      -     0.01    -      -      -      -     vmovaps	xmm2 {k2}, xmm20
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vaddps	xmm2, xmm0, xmm2
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpand	xmm0, xmm13, xmm7
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmulps	xmm3, xmm19, xmm4
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm0, xmm0
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpordps	k2, xmm3, xmm3
 -      -     0.02   0.98    -      -      -      -      -      -      -      -     vmaxps	xmm3 {k2} {z}, xmm15, xmm3
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpunordps	k2, xmm3, xmm3
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vminps	xmm3, xmm20, xmm3
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovaps	xmm3 {k2}, xmm20
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm0, xmm0
 -      -     1.00    -      -      -      -      -      -      -      -      -     vmulps	xmm0, xmm0, xmm6
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vaddps	xmm3, xmm0, xmm3
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     vmovaps	xmm0, xmm1
 -      -     1.00    -      -      -      -      -      -      -      -      -     rsqrtps	xmm0, xmm0
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm1, xmm0, xmm1
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vmovaps	xmm0, xmm2
 -      -     1.00    -      -      -      -      -      -      -      -      -     rsqrtps	xmm0, xmm0
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm2, xmm0, xmm2
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     vmovaps	xmm0, xmm3
 -      -     1.00    -      -      -      -      -      -      -      -      -     rsqrtps	xmm0, xmm0
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulps	xmm3, xmm0, xmm3
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovaps	xmm0, xmm1
 -      -      -     1.00    -      -      -      -      -      -      -      -     cvtps2dq	xmm0, xmm0
 -      -     0.01    -      -      -      -     0.99    -      -      -      -     vmovdqa	xmm1, xmm0
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovaps	xmm0, xmm2
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     cvtps2dq	xmm0, xmm0
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovdqa	xmm2, xmm0
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovaps	xmm0, xmm3
 -      -      -     1.00    -      -      -      -      -      -      -      -     cvtps2dq	xmm0, xmm0
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpslld	xmm1, xmm1, 16
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vpslld	xmm2, xmm2, 8
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpternlogd	xmm2, xmm0, xmm1, 254
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpleps	k1 {k1}, xmm17, xmm28
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpleps	k1 {k1}, xmm15, xmm17
 -      -      -     1.00    -      -      -      -      -      -      -      -     vpsrld	xmm0, xmm7, 24
 -      -     0.98   0.02    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm0, xmm0
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm0, xmm6, xmm0
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vaddps	xmm0, xmm5, xmm0
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpleps	k1 {k1}, xmm15, xmm16
 -      -      -      -      -      -      -     1.00    -      -      -      -     vcmpleps	k1 {k1}, xmm16, xmm28
 -      -      -     1.00    -      -      -      -      -      -      -      -     cvtps2dq	xmm0, xmm0
 -      -     1.00    -      -      -      -      -      -      -      -      -     vpslld	xmm0, xmm0, 24
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     vpord	xmm7 {k1}, xmm2, xmm0
 -      -      -      -     0.50   0.50    -      -      -      -      -      -     vmovaps	xmm5, xmmword ptr [rsp + 80]
 -      -      -      -     0.50   0.50    -      -      -      -      -      -     vmovaps	xmm3, xmmword ptr [rsp + 96]
 -      -      -      -     0.50   0.50    -      -      -      -      -      -     vmovaps	xmm2, xmmword ptr [rsp + 112]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     vmovdqu	xmmword ptr [rcx + 4*rbx], xmm7
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddps	xmm22, xmm22, xmm31
 -      -     1.00    -      -      -      -      -      -      -      -      -     kxnorw	k1, k0, k0


```
</details>

<details><summary>Timeline view:</summary>

```
                    0123456789          0123456789          0123456789          0123456789
Index     0123456789          0123456789          0123456789          0123456789          

[0,0]     DeeeeER   .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   vpcmpgtd	k2, xmm5, xmm15
[0,1]     D=eeeER   .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   vpmovsxdq	ymm7, xmm5
[0,2]     D====eeeER.    .    .    .    .    .    .    .    .    .    .    .    .    .   .   vpmovzxdq	ymm7 {k2}, xmm5
[0,3]     DeeeeE---R.    .    .    .    .    .    .    .    .    .    .    .    .    .   .   vcvtdq2ps	xmm3, xmm3
[0,4]     D=======eER    .    .    .    .    .    .    .    .    .    .    .    .    .   .   vpaddq	ymm5, ymm12, ymm7
[0,5]     .D=======eeeER .    .    .    .    .    .    .    .    .    .    .    .    .   .   vpextrq	rbp, xmm5, 1
[0,6]     .DeE---------R .    .    .    .    .    .    .    .    .    .    .    .    .   .   vmovaps	xmm29, xmm18
[0,7]     .D===eeeeE---R .    .    .    .    .    .    .    .    .    .    .    .    .   .   vsubps	xmm18, xmm0, xmm3
[0,8]     .DeeeeE------R .    .    .    .    .    .    .    .    .    .    .    .    .   .   vcvtdq2ps	xmm0, xmm2
[0,9]     .D========eeeER.    .    .    .    .    .    .    .    .    .    .    .    .   .   vextracti128	xmm2, ymm5, 1
[0,10]    . D==========eeeER  .    .    .    .    .    .    .    .    .    .    .    .   .   vpextrq	rdx, xmm2, 1
[0,11]    . D=======eeE----R  .    .    .    .    .    .    .    .    .    .    .    .   .   vmovq	rdi, xmm5
[0,12]    . D=========eeeeeER .    .    .    .    .    .    .    .    .    .    .    .   .   vmovd	xmm3, dword ptr [rdi + 4]
[0,13]    . D=========eeeeeeER.    .    .    .    .    .    .    .    .    .    .    .   .   vpinsrd	xmm3, xmm3, dword ptr [rbp + 4], 1
[0,14]    .  D==========eeE--R.    .    .    .    .    .    .    .    .    .    .    .   .   vmovq	rsi, xmm2
[0,15]    .  D============eeeeeeER .    .    .    .    .    .    .    .    .    .    .   .   vpinsrd	xmm2, xmm3, dword ptr [rsi + 4], 2
[0,16]    .  D==eeeeE------------R .    .    .    .    .    .    .    .    .    .    .   .   vsubps	xmm5, xmm1, xmm0
[0,17]    .  D-------------------R .    .    .    .    .    .    .    .    .    .    .   .   vxorps	xmm0, xmm0, xmm0
[0,18]    .  D=========eeeeeE----R .    .    .    .    .    .    .    .    .    .    .   .   vmovd	xmm3, dword ptr [rdi + rax]
[0,19]    .   DeE----------------R .    .    .    .    .    .    .    .    .    .    .   .   vmovaps	xmm27, xmm23
[0,20]    .   D============eeeeeeER.    .    .    .    .    .    .    .    .    .    .   .   vpinsrd	xmm23, xmm2, dword ptr [rdx + 4], 3
[0,21]    .   D=========eeeeeeE---R.    .    .    .    .    .    .    .    .    .    .   .   vpinsrd	xmm2, xmm3, dword ptr [rbp + rax], 1
[0,22]    .    D============eeeeeeER    .    .    .    .    .    .    .    .    .    .   .   vpinsrd	xmm2, xmm2, dword ptr [rsi + rax], 2
[0,23]    .    D=eE----------------R    .    .    .    .    .    .    .    .    .    .   .   kxnorw	k2, k0, k0
[0,24]    .    D=======eeeeeE------R    .    .    .    .    .    .    .    .    .    .   .   vmovd	xmm3, dword ptr [rdi + rax + 4]
[0,25]    .    D=========eeeeeeE---R    .    .    .    .    .    .    .    .    .    .   .   vpinsrd	xmm3, xmm3, dword ptr [rbp + rax + 4], 1
[0,26]    .    .D============eeeeeeER   .    .    .    .    .    .    .    .    .    .   .   vpinsrd	xmm6, xmm3, dword ptr [rsi + rax + 4], 2
[0,27]    .    .D=============eeeeeeER  .    .    .    .    .    .    .    .    .    .   .   vpinsrd	xmm3, xmm2, dword ptr [rdx + rax], 3
[0,28]    .    . DeeeeeeeeeeeeeeeeeeeER .    .    .    .    .    .    .    .    .    .   .   vpgatherqd	xmm0 {k2}, xmmword ptr [r11 + ymm7]
[0,29]    .    . D===================eER.    .    .    .    .    .    .    .    .    .   .   vpand	xmm7, xmm8, xmm0
[0,30]    .    .  D============eeeeeeE-R.    .    .    .    .    .    .    .    .    .   .   vpinsrd	xmm24, xmm6, dword ptr [rdx + rax + 4], 3
[0,31]    .    .  D===================eeeeeER.    .    .    .    .    .    .    .    .   .   vpmullw	xmm11, xmm7, xmm7
[0,32]    .    .  DeeeeE--------------------R.    .    .    .    .    .    .    .    .   .   vsubps	xmm6, xmm28, xmm18
[0,33]    .    .  D=eeeeE-------------------R.    .    .    .    .    .    .    .    .   .   vsubps	xmm7, xmm28, xmm5
[0,34]    .    .  D==eE---------------------R.    .    .    .    .    .    .    .    .   .   vmovaps	xmm1, xmm19
[0,35]    .    .   D=======================eER    .    .    .    .    .    .    .    .   .   vpsrld	xmm19, xmm11, 16
[0,36]    .    .   D=eE----------------------R    .    .    .    .    .    .    .    .   .   vmovaps	xmm25, xmm21
[0,37]    .    .   D====eeeeE----------------R    .    .    .    .    .    .    .    .   .   vmulps	xmm21, xmm7, xmm6
[0,38]    .    .   D=====eeeeE---------------R    .    .    .    .    .    .    .    .   .   vmulps	xmm7, xmm18, xmm7
[0,39]    .    .   D===eeeeE-----------------R    .    .    .    .    .    .    .    .   .   vmulps	xmm6, xmm5, xmm6
[0,40]    .    .   D========================eeeeER.    .    .    .    .    .    .    .   .   vcvtdq2ps	xmm4, xmm19
[0,41]    .    .    D=eE-------------------------R.    .    .    .    .    .    .    .   .   vmovaps	xmm19, xmm1
[0,42]    .    .    DeeeeE-----------------------R.    .    .    .    .    .    .    .   .   vmulps	xmm5, xmm5, xmm18
[0,43]    .    .    D===========================eeeeER .    .    .    .    .    .    .   .   vmulps	xmm18, xmm21, xmm4
[0,44]    .    .    D===========================eeeeER .    .    .    .    .    .    .   .   vmulps	xmm1, xmm7, xmm4
[0,45]    .    .    D===============================eeeeER  .    .    .    .    .    .   .   vaddps	xmm1, xmm18, xmm1
[0,46]    .    .    D============================eeeeE---R  .    .    .    .    .    .   .   vmulps	xmm2, xmm6, xmm4
[0,47]    .    .    .D==================================eeeeER   .    .    .    .    .   .   vaddps	xmm1, xmm2, xmm1
[0,48]    .    .    .D===============eE----------------------R   .    .    .    .    .   .   vpsrlw	xmm2, xmm0, 8
[0,49]    .    .    .D================eeeeeE-----------------R   .    .    .    .    .   .   vpmullw	xmm2, xmm2, xmm2
[0,50]    .    .    .D===========================eeeeE-------R   .    .    .    .    .   .   vmulps	xmm4, xmm5, xmm4
[0,51]    .    .    .D======================================eeeeER    .    .    .    .   .   vaddps	xmm18, xmm4, xmm1
[0,52]    .    .    .D===========eE------------------------------R    .    .    .    .   .   vpsrlw	xmm4, xmm23, 8
[0,53]    .    .    . D===========eeeeeE-------------------------R    .    .    .    .   .   vpmullw	xmm4, xmm4, xmm4
[0,54]    .    .    . D====================eE--------------------R    .    .    .    .   .   vpblendw	xmm2, xmm2, xmm15, 170
[0,55]    .    .    . D=====================eeeeE----------------R    .    .    .    .   .   vcvtdq2ps	xmm2, xmm2
[0,56]    .    .    . D================eE------------------------R    .    .    .    .   .   vpblendw	xmm4, xmm4, xmm15, 170
[0,57]    .    .    . D=================eeeeE--------------------R    .    .    .    .   .   vcvtdq2ps	xmm4, xmm4
[0,58]    .    .    . D===========================eeeeE----------R    .    .    .    .   .   vmulps	xmm2, xmm21, xmm2
[0,59]    .    .    .  D=====================eeeeE---------------R    .    .    .    .   .   vmulps	xmm4, xmm7, xmm4
[0,60]    .    .    .  D==============================eeeeE------R    .    .    .    .   .   vaddps	xmm2, xmm2, xmm4
[0,61]    .    .    .  D============eE---------------------------R    .    .    .    .   .   vpsrlw	xmm4, xmm3, 8
[0,62]    .    .    .  D=============eeeeeE----------------------R    .    .    .    .   .   vpmullw	xmm4, xmm4, xmm4
[0,63]    .    .    .  D==================eE---------------------R    .    .    .    .   .   vpblendw	xmm4, xmm4, xmm15, 170
[0,64]    .    .    .  D===================eeeeE-----------------R    .    .    .    .   .   vcvtdq2ps	xmm4, xmm4
[0,65]    .    .    .   D======================eeeeE-------------R    .    .    .    .   .   vmulps	xmm4, xmm6, xmm4
[0,66]    .    .    .   D=================================eeeeE--R    .    .    .    .   .   vaddps	xmm2, xmm2, xmm4
[0,67]    .    .    .   D========eE------------------------------R    .    .    .    .   .   vpandq	xmm4, xmm23, xmm8
[0,68]    .    .    .   D=========eeeeeE-------------------------R    .    .    .    .   .   vpmullw	xmm4, xmm4, xmm4
[0,69]    .    .    .   D===================eE-------------------R    .    .    .    .   .   vpblendw	xmm1, xmm11, xmm15, 170
[0,70]    .    .    .   D====================eeeeE---------------R    .    .    .    .   .   vcvtdq2ps	xmm1, xmm1
[0,71]    .    .    .    D==============eE-----------------------R    .    .    .    .   .   vpblendw	xmm4, xmm4, xmm15, 170
[0,72]    .    .    .    D========================eeeeE----------R    .    .    .    .   .   vmulps	xmm1, xmm21, xmm1
[0,73]    .    .    .    D===============eeeeE-------------------R    .    .    .    .   .   vcvtdq2ps	xmm4, xmm4
[0,74]    .    .    .    D====================eeeeE--------------R    .    .    .    .   .   vmulps	xmm4, xmm7, xmm4
[0,75]    .    .    .    D============================eeeeE------R    .    .    .    .   .   vaddps	xmm1, xmm1, xmm4
[0,76]    .    .    .    D=============eE------------------------R    .    .    .    .   .   vpsrlw	xmm4, xmm24, 8
[0,77]    .    .    .    .D=============eeeeeE-------------------R    .    .    .    .   .   vpmullw	xmm4, xmm4, xmm4
[0,78]    .    .    .    .D==================eE------------------R    .    .    .    .   .   vpblendw	xmm4, xmm4, xmm15, 170
[0,79]    .    .    .    .D===================eeeeE--------------R    .    .    .    .   .   vcvtdq2ps	xmm4, xmm4
[0,80]    .    .    .    .D========================eeeeE---------R    .    .    .    .   .   vmulps	xmm4, xmm5, xmm4
[0,81]    .    .    .    .D===================================eeeeER  .    .    .    .   .   vaddps	xmm2, xmm2, xmm4
[0,82]    .    .    .    .D=========eE-----------------------------R  .    .    .    .   .   vpand	xmm4, xmm8, xmm3
[0,83]    .    .    .    . D===========eeeeeE----------------------R  .    .    .    .   .   vpmullw	xmm4, xmm4, xmm4
[0,84]    .    .    .    . D==================eE-------------------R  .    .    .    .   .   vpblendw	xmm4, xmm4, xmm15, 170
[0,85]    .    .    .    . D===================eeeeE---------------R  .    .    .    .   .   vcvtdq2ps	xmm4, xmm4
[0,86]    .    .    .    . D=======================eeeeE-----------R  .    .    .    .   .   vmulps	xmm4, xmm6, xmm4
[0,87]    .    .    .    . D==============================eeeeE----R  .    .    .    .   .   vaddps	xmm1, xmm1, xmm4
[0,88]    .    .    .    . D==========eE---------------------------R  .    .    .    .   .   vpandq	xmm4, xmm24, xmm8
[0,89]    .    .    .    .  D============eeeeeE--------------------R  .    .    .    .   .   vpmullw	xmm4, xmm4, xmm4
[0,90]    .    .    .    .  D==================eE------------------R  .    .    .    .   .   vpblendw	xmm4, xmm4, xmm15, 170
[0,91]    .    .    .    .  D=======================eeeeE----------R  .    .    .    .   .   vcvtdq2ps	xmm4, xmm4
[0,92]    .    .    .    .  D===========================eeeeE------R  .    .    .    .   .   vmulps	xmm4, xmm5, xmm4
[0,93]    .    .    .    .  D=================================eeeeER  .    .    .    .   .   vaddps	xmm4, xmm1, xmm4
[0,94]    .    .    .    .  D=============eE-----------------------R  .    .    .    .   .   vpsrld	xmm0, xmm0, 24
[0,95]    .    .    .    .   D=======================eeeeE---------R  .    .    .    .   .   vcvtdq2ps	xmm0, xmm0
[0,96]    .    .    .    .   D===========================eeeeE-----R  .    .    .    .   .   vmulps	xmm0, xmm21, xmm0
[0,97]    .    .    .    .    DeE----------------------------------R  .    .    .    .   .   vmovaps	xmm21, xmm25
[0,98]    .    .    .    .    .D===eE------------------------------R  .    .    .    .   .   vpsrld	xmm1, xmm23, 24
[0,99]    .    .    .    .    .DeE---------------------------------R  .    .    .    .   .   vmovaps	xmm23, xmm27
[0,100]   .    .    .    .    . D===eeeeE--------------------------R  .    .    .    .   .   vcvtdq2ps	xmm1, xmm1
[0,101]   .    .    .    .    .  D========eeeeE--------------------R  .    .    .    .   .   vmulps	xmm1, xmm7, xmm1
[0,102]   .    .    .    .    .  D===========================eeeeE-R  .    .    .    .   .   vaddps	xmm0, xmm0, xmm1
[0,103]   .    .    .    .    .   D==================eE------------R  .    .    .    .   .   vpsrld	xmm1, xmm3, 24
[0,104]   .    .    .    .    .   D====================eeeeE-------R  .    .    .    .   .   vcvtdq2ps	xmm1, xmm1
[0,105]   .    .    .    .    .    D=======================eeeeE---R  .    .    .    .   .   vmulps	xmm1, xmm6, xmm1
[0,106]   .    .    .    .    .    .D============================eeeeER    .    .    .   .   vaddps	xmm0, xmm0, xmm1
[0,107]   .    .    .    .    .    .DeeeeeeE--------------------------R    .    .    .   .   vmovdqu	xmm7, xmmword ptr [rcx + 4*rbx]
[0,108]   .    .    .    .    .    .D==================eE-------------R    .    .    .   .   vpsrld	xmm1, xmm24, 24
[0,109]   .    .    .    .    .    . D===================eeeeE--------R    .    .    .   .   vcvtdq2ps	xmm1, xmm1
[0,110]   .    .    .    .    .    . D=======================eeeeE----R    .    .    .   .   vmulps	xmm1, xmm5, xmm1
[0,111]   .    .    .    .    .    . D==========eE--------------------R    .    .    .   .   vpshufb	xmm3, xmm7, xmm26
[0,112]   .    .    .    .    .    . D=====================eeeeE------R    .    .    .   .   vcvtdq2ps	xmm3, xmm3
[0,113]   .    .    .    .    .    .  D==============================eeeeER.    .    .   .   vaddps	xmm0, xmm0, xmm1
[0,114]   .    .    .    .    .    .  D==================================eeeeER .    .   .   vmulps	xmm5, xmm27, xmm0
[0,115]   .    .    .    .    .    .  D=========================eeeeE---------R .    .   .   vmulps	xmm0, xmm25, xmm18
[0,116]   .    .    .    .    .    .   D=eE-----------------------------------R .    .   .   vmovaps	xmm18, xmm29
[0,117]   .    .    .    .    .    .   D============================eeeeE-----R .    .   .   vcmpordps	k2, xmm0, xmm0
[0,118]   .    .    .    .    .    .   D================================eeeeE-R .    .   .   vmaxps	xmm0 {k2} {z}, xmm15, xmm0
[0,119]   .    .    .    .    .    .    D===================================eeeeER   .   .   vminps	xmm1, xmm20, xmm0
[0,120]   .    .    .    .    .    .    D===================================eeeeER   .   .   vcmpunordps	k2, xmm0, xmm0
[0,121]   .    .    .    .    .    .    D=======================================eER  .   .   vmovaps	xmm1 {k2}, xmm20
[0,122]   .    .    .    .    .    .    .D=====================eeeeE--------------R  .   .   vmulps	xmm0, xmm3, xmm3
[0,123]   .    .    .    .    .    .    .D===================================eeeeER  .   .   vmulps	xmm3, xmm5, xmm30
[0,124]   .    .    .    .    .    .    .D=======================================eeeeER  .   vaddps	xmm6, xmm3, xmm28
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
0.     10    5.5    0.2    34.1      vpcmpgtd	k2, xmm5, xmm15
1.     10    5.8    1.3    34.0      vpmovsxdq	ymm7, xmm5
2.     10    11.2   2.4    28.9      vpmovzxdq	ymm7 {k2}, xmm5
3.     10    4.5    0.1    34.5      vcvtdq2ps	xmm3, xmm3
4.     10    13.3   0.0    28.0      vpaddq	ymm5, ymm12, ymm7
5.     10    14.4   0.3    25.0      vpextrq	rbp, xmm5, 1
6.     10    1.1    1.1    40.3      vmovaps	xmm29, xmm18
7.     10    29.1   0.0    8.4       vsubps	xmm18, xmm0, xmm3
8.     10    3.6    0.1    33.9      vcvtdq2ps	xmm0, xmm2
9.     10    14.1   0.9    24.5      vextracti128	xmm2, ymm5, 1
10.    10    17.2   1.1    20.7      vpextrq	rdx, xmm2, 1
11.    10    13.2   1.0    25.7      vmovq	rdi, xmm5
12.    10    14.3   0.0    20.8      vmovd	xmm3, dword ptr [rdi + 4]
13.    10    14.7   0.9    18.7      vpinsrd	xmm3, xmm3, dword ptr [rbp + 4], 1
14.    10    16.3   2.1    20.9      vmovq	rsi, xmm2
15.    10    18.3   0.0    15.3      vpinsrd	xmm2, xmm3, dword ptr [rsi + 4], 2
16.    10    33.6   0.0    1.2       vsubps	xmm5, xmm1, xmm0
17.    10    0.0    0.0    38.8      vxorps	xmm0, xmm0, xmm0
18.    10    14.2   1.8    19.5      vmovd	xmm3, dword ptr [rdi + rax]
19.    10    1.0    1.0    36.6      vmovaps	xmm27, xmm23
20.    10    17.4   0.0    14.4      vpinsrd	xmm23, xmm2, dword ptr [rdx + 4], 3
21.    10    14.5   1.1    17.3      vpinsrd	xmm2, xmm3, dword ptr [rbp + rax], 1
22.    10    18.3   2.0    13.5      vpinsrd	xmm2, xmm2, dword ptr [rsi + rax], 2
23.    10    1.9    1.9    34.0      kxnorw	k2, k0, k0
24.    10    12.2   2.7    18.8      vmovd	xmm3, dword ptr [rdi + rax + 4]
25.    10    13.9   1.6    16.1      vpinsrd	xmm3, xmm3, dword ptr [rbp + rax + 4], 1
26.    10    16.7   2.7    12.5      vpinsrd	xmm6, xmm3, dword ptr [rsi + rax + 4], 2
27.    10    17.6   1.1    11.6      vpinsrd	xmm3, xmm2, dword ptr [rdx + rax], 3
28.    10    6.2    2.7    9.1       vpgatherqd	xmm0 {k2}, xmmword ptr [r11 + ymm7]
29.    10    25.2   0.0    8.2       vpand	xmm7, xmm8, xmm0
30.    10    16.6   1.0    10.8      vpinsrd	xmm24, xmm6, dword ptr [rdx + rax + 4], 3
31.    10    25.2   0.0    3.7       vpmullw	xmm11, xmm7, xmm7
32.    10    24.2   0.8    5.7       vsubps	xmm6, xmm28, xmm18
33.    10    30.7   0.0    1.9       vsubps	xmm7, xmm28, xmm5
34.    10    2.0    2.0    32.8      vmovaps	xmm1, xmm19
35.    10    28.3   0.8    5.6       vpsrld	xmm19, xmm11, 16
36.    10    1.9    1.9    32.0      vmovaps	xmm25, xmm21
37.    10    32.9   0.0    1.6       vmulps	xmm21, xmm7, xmm6
38.    10    32.1   0.1    1.5       vmulps	xmm7, xmm18, xmm7
39.    10    28.3   0.0    5.3       vmulps	xmm6, xmm5, xmm6
40.    10    27.7   0.1    5.5       vcvtdq2ps	xmm4, xmm19
41.    10    1.1    0.9    34.9      vmovaps	xmm19, xmm1
42.    10    28.0   1.0    5.0       vmulps	xmm5, xmm5, xmm18
43.    10    36.1   0.0    0.0       vmulps	xmm18, xmm21, xmm4
44.    10    36.1   0.0    0.0       vmulps	xmm1, xmm7, xmm4
45.    10    39.3   0.0    0.0       vaddps	xmm1, xmm18, xmm1
46.    10    32.6   1.0    6.6       vmulps	xmm2, xmm6, xmm4
47.    10    43.1   0.0    0.0       vaddps	xmm1, xmm2, xmm1
48.    10    19.3   2.4    26.0      vpsrlw	xmm2, xmm0, 8
49.    10    20.4   0.2    20.8      vpmullw	xmm2, xmm2, xmm2
50.    10    31.6   0.1    10.6      vmulps	xmm4, xmm5, xmm4
51.    10    45.4   0.0    0.0       vaddps	xmm18, xmm4, xmm1
52.    10    10.2   0.0    38.1      vpsrlw	xmm4, xmm23, 8
53.    10    10.2   0.0    33.1      vpmullw	xmm4, xmm4, xmm4
54.    10    23.7   0.2    23.6      vpblendw	xmm2, xmm2, xmm15, 170
55.    10    25.5   0.9    18.7      vcvtdq2ps	xmm2, xmm2
56.    10    16.1   1.8    30.3      vpblendw	xmm4, xmm4, xmm15, 170
57.    10    17.1   0.0    26.3      vcvtdq2ps	xmm4, xmm4
58.    10    32.4   1.1    10.9      vmulps	xmm2, xmm21, xmm2
59.    10    31.0   1.0    11.4      vmulps	xmm4, xmm7, xmm4
60.    10    35.5   0.0    6.9       vaddps	xmm2, xmm2, xmm4
61.    10    11.1   0.8    34.2      vpsrlw	xmm4, xmm3, 8
62.    10    11.6   0.4    28.8      vpmullw	xmm4, xmm4, xmm4
63.    10    17.5   1.8    26.0      vpblendw	xmm4, xmm4, xmm15, 170
64.    10    17.8   0.1    21.9      vcvtdq2ps	xmm4, xmm4
65.    10    25.7   1.6    13.9      vmulps	xmm4, xmm6, xmm4
66.    10    36.6   0.0    2.9       vaddps	xmm2, xmm2, xmm4
67.    10    3.6    0.0    38.1      vpandq	xmm4, xmm23, xmm8
68.    10    7.3    2.7    30.4      vpmullw	xmm4, xmm4, xmm4
69.    10    18.6   3.4    23.0      vpblendw	xmm1, xmm11, xmm15, 170
70.    10    19.6   0.8    18.2      vcvtdq2ps	xmm1, xmm1
71.    10    11.4   0.1    29.3      vpblendw	xmm4, xmm4, xmm15, 170
72.    10    27.6   1.9    10.0      vmulps	xmm1, xmm21, xmm1
73.    10    11.5   0.0    25.3      vcvtdq2ps	xmm4, xmm4
74.    10    25.5   1.9    10.4      vmulps	xmm4, xmm7, xmm4
75.    10    29.9   0.0    6.0       vaddps	xmm1, xmm1, xmm4
76.    10    5.5    1.5    32.5      vpsrlw	xmm4, xmm24, 8
77.    10    10.7   4.3    23.2      vpmullw	xmm4, xmm4, xmm4
78.    10    15.6   0.8    21.4      vpblendw	xmm4, xmm4, xmm15, 170
79.    10    16.8   0.2    17.2      vcvtdq2ps	xmm4, xmm4
80.    10    20.1   0.2    13.0      vmulps	xmm4, xmm5, xmm4
81.    10    34.2   0.0    0.0       vaddps	xmm2, xmm2, xmm4
82.    10    10.0   9.0    26.3      vpand	xmm4, xmm8, xmm3
83.    10    11.1   0.2    21.1      vpmullw	xmm4, xmm4, xmm4
84.    10    15.4   0.2    19.9      vpblendw	xmm4, xmm4, xmm15, 170
85.    10    18.2   1.8    14.1      vcvtdq2ps	xmm4, xmm4
86.    10    22.2   0.0    10.1      vmulps	xmm4, xmm6, xmm4
87.    10    28.3   0.0    3.1       vaddps	xmm1, xmm1, xmm4
88.    10    9.2    8.2    25.2      vpandq	xmm4, xmm24, xmm8
89.    10    12.9   2.8    17.4      vpmullw	xmm4, xmm4, xmm4
90.    10    17.1   0.1    16.3      vpblendw	xmm4, xmm4, xmm15, 170
91.    10    20.5   2.4    9.9       vcvtdq2ps	xmm4, xmm4
92.    10    24.5   0.0    5.9       vmulps	xmm4, xmm5, xmm4
93.    10    30.4   0.0    0.0       vaddps	xmm4, xmm1, xmm4
94.    10    11.3   10.4   22.1      vpsrld	xmm0, xmm0, 24
95.    10    15.9   3.7    14.4      vcvtdq2ps	xmm0, xmm0
96.    10    20.0   1.0    9.4       vmulps	xmm0, xmm21, xmm0
97.    10    8.1    8.1    24.2      vmovaps	xmm21, xmm25
98.    10    17.4   17.2   14.8      vpsrld	xmm1, xmm23, 24
99.    10    8.1    8.1    23.2      vmovaps	xmm23, xmm27
100.   10    18.4   1.0    9.8       vcvtdq2ps	xmm1, xmm1
101.   10    22.5   0.2    5.6       vmulps	xmm1, xmm7, xmm1
102.   10    27.1   0.0    0.1       vaddps	xmm0, xmm0, xmm1
103.   10    19.9   19.7   10.2      vpsrld	xmm1, xmm3, 24
104.   10    21.1   0.2    6.0       vcvtdq2ps	xmm1, xmm1
105.   10    24.1   0.0    2.0       vmulps	xmm1, xmm6, xmm1
106.   10    29.9   0.0    0.0       vaddps	xmm0, xmm0, xmm1
107.   10    1.0    1.0    26.9      vmovdqu	xmm7, xmmword ptr [rcx + 4*rbx]
108.   10    19.7   19.6   12.3      vpsrld	xmm1, xmm24, 24
109.   10    21.8   1.2    7.1       vcvtdq2ps	xmm1, xmm1
110.   10    25.8   0.0    3.1       vmulps	xmm1, xmm5, xmm1
111.   10    8.3    2.3    23.6      vpshufb	xmm3, xmm7, xmm26
112.   10    21.1   12.7   6.9       vcvtdq2ps	xmm3, xmm3
113.   10    31.9   0.0    0.0       vaddps	xmm0, xmm0, xmm1
114.   10    35.9   0.0    0.0       vmulps	xmm5, xmm27, xmm0
115.   10    25.1   0.0    9.9       vmulps	xmm0, xmm25, xmm18
116.   10    6.5    6.5    31.4      vmovaps	xmm18, xmm29
117.   10    29.0   0.0    5.9       vcmpordps	k2, xmm0, xmm0
118.   10    33.0   0.0    1.9       vmaxps	xmm0 {k2} {z}, xmm15, xmm0
119.   10    36.0   0.0    0.0       vminps	xmm1, xmm20, xmm0
120.   10    36.0   0.0    0.0       vcmpunordps	k2, xmm0, xmm0
121.   10    40.0   0.0    0.0       vmovaps	xmm1 {k2}, xmm20
122.   10    22.0   0.0    14.0      vmulps	xmm0, xmm3, xmm3
123.   10    36.9   0.0    0.0       vmulps	xmm3, xmm5, xmm30
124.   10    40.9   0.0    0.0       vaddps	xmm6, xmm3, xmm28
125.   10    43.9   0.0    0.0       vmulps	xmm0, xmm0, xmm6
126.   10    47.9   0.0    0.0       vaddps	xmm1, xmm1, xmm0
127.   10    5.3    4.3    45.6      vpshufb	xmm0, xmm7, xmm14
128.   10    17.8   12.5   29.1      vcvtdq2ps	xmm0, xmm0
129.   10    22.1   0.0    24.8      vmulps	xmm2, xmm29, xmm2
130.   10    26.1   0.0    20.8      vcmpordps	k2, xmm2, xmm2
131.   10    29.1   0.0    16.8      vmaxps	xmm2 {k2} {z}, xmm15, xmm2
132.   10    33.1   0.0    12.8      vcmpunordps	k2, xmm2, xmm2
133.   10    33.1   0.0    12.8      vminps	xmm2, xmm20, xmm2
134.   10    19.8   0.0    25.1      vmulps	xmm0, xmm0, xmm0
135.   10    40.9   0.0    4.0       vmulps	xmm0, xmm0, xmm6
136.   10    36.1   0.0    11.8      vmovaps	xmm2 {k2}, xmm20
137.   10    43.9   0.0    0.0       vaddps	xmm2, xmm0, xmm2
138.   10    3.1    3.1    43.8      vpand	xmm0, xmm13, xmm7
139.   10    20.0   0.0    23.9      vmulps	xmm3, xmm19, xmm4
140.   10    17.0   13.9   25.9      vcvtdq2ps	xmm0, xmm0
141.   10    23.1   0.1    19.8      vcmpordps	k2, xmm3, xmm3
142.   10    27.1   0.0    15.8      vmaxps	xmm3 {k2} {z}, xmm15, xmm3
143.   10    30.1   0.0    11.8      vcmpunordps	k2, xmm3, xmm3
144.   10    30.1   0.0    11.8      vminps	xmm3, xmm20, xmm3
145.   10    34.1   0.0    10.8      vmovaps	xmm3 {k2}, xmm20
146.   10    19.0   0.0    21.9      vmulps	xmm0, xmm0, xmm0
147.   10    37.9   1.0    3.0       vmulps	xmm0, xmm0, xmm6
148.   10    41.9   0.0    0.0       vaddps	xmm3, xmm0, xmm3
149.   10    43.9   0.0    0.0       vmovaps	xmm0, xmm1
150.   10    44.9   0.0    0.0       rsqrtps	xmm0, xmm0
151.   10    48.0   0.0    0.0       vmulps	xmm1, xmm0, xmm1
152.   10    42.9   0.0    8.0       vmovaps	xmm0, xmm2
153.   10    44.0   1.0    3.0       rsqrtps	xmm0, xmm0
154.   10    47.9   0.0    0.0       vmulps	xmm2, xmm0, xmm2
155.   10    42.0   0.0    8.0       vmovaps	xmm0, xmm3
156.   10    43.9   1.0    3.0       rsqrtps	xmm0, xmm0
157.   10    47.0   0.0    0.0       vmulps	xmm3, xmm0, xmm3
158.   10    48.9   0.0    1.0       vmovaps	xmm0, xmm1
159.   10    49.0   0.0    0.0       cvtps2dq	xmm0, xmm0
160.   10    52.9   0.0    0.0       vmovdqa	xmm1, xmm0
161.   10    48.0   0.0    4.0       vmovaps	xmm0, xmm2
162.   10    48.9   0.0    0.0       cvtps2dq	xmm0, xmm0
163.   10    52.0   0.0    0.0       vmovdqa	xmm2, xmm0
164.   10    47.9   0.0    4.0       vmovaps	xmm0, xmm3
165.   10    48.0   0.0    0.0       cvtps2dq	xmm0, xmm0
166.   10    50.9   0.0    0.0       vpslld	xmm1, xmm1, 16
167.   10    51.0   0.0    0.0       vpslld	xmm2, xmm2, 8
168.   10    51.9   0.0    0.0       vpternlogd	xmm2, xmm0, xmm1, 254
169.   10    1.0    1.0    47.0      vcmpleps	k1 {k1}, xmm17, xmm28
170.   10    4.9    0.0    43.0      vcmpleps	k1 {k1}, xmm15, xmm17
171.   10    5.9    5.9    44.1      vpsrld	xmm0, xmm7, 24
172.   10    7.0    0.1    40.0      vcvtdq2ps	xmm0, xmm0
173.   10    25.9   1.0    21.0      vmulps	xmm0, xmm6, xmm0
174.   10    29.0   0.0    17.0      vaddps	xmm0, xmm5, xmm0
175.   10    8.8    1.9    37.1      vcmpleps	k1 {k1}, xmm15, xmm16
176.   10    11.9   0.0    33.1      vcmpleps	k1 {k1}, xmm16, xmm28
177.   10    32.9   1.0    12.0      cvtps2dq	xmm0, xmm0
178.   10    36.0   0.0    11.0      vpslld	xmm0, xmm0, 24
179.   10    47.9   0.0    0.0       vpord	xmm7 {k1}, xmm2, xmm0
180.   10    1.0    1.0    41.0      vmovaps	xmm5, xmmword ptr [rsp + 80]
181.   10    1.0    1.0    41.0      vmovaps	xmm3, xmmword ptr [rsp + 96]
182.   10    1.9    1.9    40.0      vmovaps	xmm2, xmmword ptr [rsp + 112]
183.   10    47.0   0.0    0.0       vmovdqu	xmmword ptr [rcx + 4*rbx], xmm7
184.   10    1.2    1.2    42.8      vaddps	xmm22, xmm22, xmm31
185.   10    3.0    3.0    44.0      kxnorw	k1, k0, k0
       10    23.6   1.4    15.5      <total>
```
</details>
</details>


### day 143 
#### before any optimization

<details><summary>[0] Code Region - OutputPlayingSound</summary>

```
Iterations:        100
Instructions:      53200
Total Cycles:      20819
Total uOps:        63500

Dispatch Width:    6
uOps Per Cycle:    3.05
IPC:               2.56
Block RThroughput: 105.8


Cycles with backend pressure increase [ 33.60% ]
Throughput Bottlenecks: 
  Resource Pressure       [ 28.29% ]
  - ICXPort0  [ 18.21% ]
  - ICXPort1  [ 19.15% ]
  - ICXPort2  [ 8.64% ]
  - ICXPort3  [ 8.64% ]
  - ICXPort4  [ 14.37% ]
  - ICXPort5  [ 17.71% ]
  - ICXPort6  [ 19.15% ]
  - ICXPort7  [ 6.72% ]
  Data Dependencies:      [ 22.58% ]
  - Register Dependencies [ 22.58% ]
  - Memory Dependencies   [ 0.00% ]

```

<details><summary>Critical sequence based on the simulation:</summary>

```

              Instruction                                 Dependency Information
        0.    mov	ecx, dword ptr [rdx + 12]
        1.    mov	rax, qword ptr [r10 + 8]
        2.    mov	rdx, qword ptr [r10 + 16]
        3.    lea	r8, [rdx + rax]
        4.    mov	r9d, r8d
        5.    and	r9d, 3
        6.    mov	r15d, 4
        7.    mov	r12d, 4
        8.    sub	r12, r9
        9.    test	r9, r9
        10.   cmove	r12, r9
        11.   lea	rcx, [rdx + 4*rcx]
        12.   add	rcx, r12
        13.   add	r12, r8
        14.   mov	qword ptr [r10 + 16], rcx
        15.   mov	edx, dword ptr [rdi + 12]
        16.   add	rax, rcx
        17.   mov	r8d, eax
        18.   and	r8d, 3
        19.   sub	r15, r8
        20.   test	r8, r8
        21.   cmove	r15, r8
        22.   lea	rcx, [rcx + 4*rdx]
        23.   add	rcx, r15
        24.   mov	qword ptr [rsp + 56], r10
        25.   mov	qword ptr [r10 + 16], rcx
        26.   vcvtusi2ss	xmm0, xmm0, dword ptr [rdi + 8]
        27.   add	r15, rax
        28.   mov	eax, dword ptr [rdi + 12]
        29.   test	rax, rax
        30.   je	.LBB3_17
        31.   xor	ecx, ecx
        32.   cmp	eax, 8
        33.   jb	.LBB3_12
        34.   mov	rdx, r15
        35.   sub	rdx, r12
        36.   cmp	rdx, 256
        37.   jb	.LBB3_12
        38.   cmp	eax, 64
        39.   jae	.LBB3_5
        40.   xor	ecx, ecx
        41.   jmp	.LBB3_9
        42.   lea	rcx, [4*rax]
        43.   and	rcx, -256
        44.   xor	edx, edx
        45.   vxorps	xmm1, xmm1, xmm1
        46.   vmovups	zmmword ptr [r12 + rdx + 192], zmm1
        47.   vmovups	zmmword ptr [r12 + rdx + 128], zmm1
        48.   vmovups	zmmword ptr [r12 + rdx + 64], zmm1
        49.   vmovups	zmmword ptr [r12 + rdx], zmm1
        50.   vmovups	zmmword ptr [r15 + rdx + 192], zmm1
        51.   vmovups	zmmword ptr [r15 + rdx + 128], zmm1
        52.   vmovups	zmmword ptr [r15 + rdx + 64], zmm1
        53.   vmovups	zmmword ptr [r15 + rdx], zmm1
        54.   lea	r8, [rdx + 256]
        55.   mov	rdx, r8
        56.   cmp	rcx, r8
        57.   jne	.LBB3_6
        58.   mov	ecx, eax
        59.   and	ecx, -64
        60.   cmp	rcx, rax
        61.   je	.LBB3_17
        62.   test	al, 56
        63.   je	.LBB3_12
        64.   mov	rdx, rcx
        65.   mov	ecx, eax
        66.   and	ecx, -8
        67.   vxorps	xmm1, xmm1, xmm1
        68.   vmovups	ymmword ptr [r12 + 4*rdx], ymm1
        69.   vmovups	ymmword ptr [r15 + 4*rdx], ymm1
        70.   add	rdx, 8
        71.   cmp	rcx, rdx
        72.   jne	.LBB3_10
        73.   cmp	rcx, rax
        74.   je	.LBB3_17
        75.   mov	rdx, rcx
        76.   not	rdx
        77.   add	rdx, rax
        78.   mov	r8, rax
        79.   and	r8, 3
        80.   je	.LBB3_14
        81.   mov	dword ptr [r12 + 4*rcx], 0
        82.   mov	dword ptr [r15 + 4*rcx], 0
        83.   add	rcx, 1
        84.   add	r8, -1
        85.   jne	.LBB3_13
        86.   cmp	rdx, 3
        87.   jb	.LBB3_17
        88.   lea	rdx, [r15 + 12]
        89.   lea	r8, [r12 + 12]
        90.   mov	dword ptr [r8 + 4*rcx - 12], 0
        91.   mov	dword ptr [rdx + 4*rcx - 12], 0
        92.   mov	dword ptr [r8 + 4*rcx - 8], 0
        93.   mov	dword ptr [rdx + 4*rcx - 8], 0
        94.   mov	dword ptr [r8 + 4*rcx - 4], 0
        95.   mov	dword ptr [rdx + 4*rcx - 4], 0
        96.   mov	dword ptr [r8 + 4*rcx], 0
        97.   mov	dword ptr [rdx + 4*rcx], 0
        98.   add	rcx, 4
        99.   cmp	rax, rcx
        100.  jne	.LBB3_16
        101.  mov	rax, qword ptr [r13 + 15202272]
        102.  test	rax, rax
        103.  je	.LBB3_67
        104.  mov	esi, dword ptr [rdi + 12]
        105.  test	esi, esi
        106.  je	.LBB3_66
        107.  mov	qword ptr [rsp + 32], rdi
 +----< 108.  vmovss	xmm6, dword ptr [rip + .LCPI3_0]
 +----> 109.  vdivss	xmm0, xmm6, xmm0                  ## REGISTER dependency:  xmm6
 |      110.  lea	rcx, [r13 + 15202272]
 |      111.  mov	qword ptr [rsp + 40], rcx
 |      112.  vbroadcastss	xmm7, xmm0
 |      113.  mov	r11b, 1
 |      114.  vpbroadcastd	xmm8, dword ptr [rip + .LCPI3_1]
 |      115.  vpbroadcastd	xmm9, dword ptr [rip + .LCPI3_2]
 |      116.  vxorps	xmm10, xmm10, xmm10
 |      117.  vmovss	xmm11, dword ptr [rip + .LCPI3_3]
 +----> 118.  mov	rbx, rax                          ## RESOURCE interference:  ICXPort0 [ probability: 99% ]
 +----> 119.  test	esi, esi                          ## RESOURCE interference:  ICXPort5 [ probability: 100% ]
 +----> 120.  jne	.LBB3_22                          ## REGISTER dependency:  flags
 |      121.  jmp	.LBB3_20
 |      122.  mov	rax, qword ptr [rax]
 |      123.  test	rax, rax
 |      124.  jne	.LBB3_66
 +----> 125.  jmp	.LBB3_67                          ## RESOURCE interference:  ICXPort0 [ probability: 99% ]
 |      126.  lea	rcx, [rax + 80]
 |      127.  xor	edx, edx
 |      128.  jmp	.LBB3_65
 |      129.  lea	rcx, [rax + 136]
 +----> 130.  mov	edx, 1                            ## RESOURCE interference:  ICXPort6 [ probability: 99% ]
 |      131.  jmp	.LBB3_65
 |      132.  lea	rcx, [rax + 192]
 +----> 133.  mov	edx, 2                            ## RESOURCE interference:  ICXPort5 [ probability: 100% ]
 +----> 134.  imul	rdx, rdx, 56                      ## REGISTER dependency:  edx
 |      135.  mov	byte ptr [rcx], 1
 +----> 136.  mov	r8, qword ptr [rax + rdx + 48]    ## REGISTER dependency:  rdx
 |      137.  add	dword ptr [rax + rdx + 56], 1
 |      138.  lea	r9, [rax + rdx]
 |      139.  add	r9, 32
 |      140.  mov	qword ptr [rax + rdx + 64], r9
 |      141.  mov	qword ptr [rax + rdx + 72], r8
 |      142.  mov	rcx, qword ptr [rax + rdx + 40]
 +----> 143.  add	rcx, r8                           ## REGISTER dependency:  r8
 +----> 144.  mov	r10d, ecx                         ## REGISTER dependency:  rcx
 +----> 145.  and	r10d, 7                           ## REGISTER dependency:  r10d
 |      146.  mov	r11d, 8
 +----> 147.  sub	r11, r10                          ## REGISTER dependency:  r10d
 |      148.  test	r10, r10
 |      149.  cmove	r11, r10
 |      150.  lea	r8, [r8 + r11 + 32]
 |      151.  mov	qword ptr [rax + rdx + 48], r8
 |      152.  mov	qword ptr [r11 + rcx], rbp
 |      153.  mov	eax, dword ptr [rbx + 36]
 |      154.  mov	dword ptr [r11 + rcx + 24], eax
 |      155.  mov	qword ptr [r11 + rcx + 8], r9
 |      156.  mov	rax, qword ptr [rbp + 24]
 |      157.  mov	rdx, qword ptr [rbp + 16]
 |      158.  add	rdx, rax
 |      159.  mov	r8d, edx
 |      160.  and	r8d, 7
 |      161.  mov	r9d, 8
 |      162.  sub	r9, r8
 |      163.  test	r8, r8
 |      164.  cmove	r9, r8
 |      165.  lea	r8, [r11 + rcx]
 |      166.  add	rax, r9
 |      167.  add	rax, 24
 |      168.  add	r9, rdx
 |      169.  mov	qword ptr [rbp + 24], rax
 |      170.  mov	qword ptr [r11 + rcx + 16], r9
 |      171.  mov	byte ptr [r11 + rcx + 28], 2
 |      172.  mov	rax, qword ptr [rbp]
 |      173.  mov	rcx, qword ptr [rax + 288]
 |      174.  lea	rdx, [rip + handmade_asset.LoadSoundWork]
 |      175.  vzeroupper
 |      176.  call	qword ptr [rip + handmade_data.PlatformAddEntry]
 |      177.  mov	r11b, 1
 |      178.  mov	rax, qword ptr [rbx]
 |      179.  test	rax, rax
 |      180.  jne	.LBB3_61
 |      181.  jmp	.LBB3_67
 |      182.  mov	rdi, qword ptr [rsp + 32]
 |      183.  mov	rax, qword ptr [rbx]
 |      184.  test	rax, rax
 |      185.  je	.LBB3_67
 |      186.  mov	esi, dword ptr [rdi + 12]
 |      187.  mov	qword ptr [rsp + 40], rbx
 +----> 188.  mov	rbx, rax                          ## RESOURCE interference:  ICXPort5 [ probability: 99% ]
 |      189.  test	esi, esi
 |      190.  jne	.LBB3_22
 |      191.  jmp	.LBB3_20
 |      192.  sub	esi, ecx
 |      193.  je	.LBB3_20
 |      194.  mov	rcx, qword ptr [rbp + 88]
 +----> 195.  mov	eax, dword ptr [rbx + 36]         ## REGISTER dependency:  rbx
 +----> 196.  mov	rdx, rax                          ## REGISTER dependency:  eax
 |      197.  shl	rdx, 4
 |      198.  mov	rdi, qword ptr [rcx + rdx]
 |      199.  test	rdi, rdi
 |      200.  je	.LBB3_49
 |      201.  mov	rdx, qword ptr [rbp + 72]
 |      202.  lea	rax, [rax + 2*rax]
 |      203.  lea	r14, [rdx + 8*rax]
 |      204.  add	r14, 16
 |      205.  mov	edx, dword ptr [rdx + 8*rax + 16]
 |      206.  test	rdx, rdx
 |      207.  je	.LBB3_35
 |      208.  shl	rdx, 4
 |      209.  xor	eax, eax
 |      210.  lock		cmpxchg	byte ptr [rcx + rdx + 8], r11b
 |      211.  jne	.LBB3_30
 |      212.  mov	rax, qword ptr [rbp]
 |      213.  cmp	byte ptr [rax + 80], 1
 |      214.  jne	.LBB3_31
 +----> 215.  cmp	byte ptr [rax + 136], 1           ## RESOURCE interference:  ICXPort1 [ probability: 99% ]
 |      216.  jne	.LBB3_32
 +----> 217.  cmp	byte ptr [rax + 192], 1           ## RESOURCE interference:  ICXPort0 [ probability: 99% ]
 |      218.  jne	.LBB3_33
 +----> 219.  cmp	byte ptr [rax + 248], 0           ## RESOURCE interference:  ICXPort6 [ probability: 99% ]
 |      220.  jne	.LBB3_35
 |      221.  lea	rcx, [rax + 248]
 |      222.  mov	edx, 3
 |      223.  jmp	.LBB3_34
 |      224.  mov	eax, dword ptr [r14]
 |      225.  mov	rcx, qword ptr [rbp + 88]
 |      226.  shl	rax, 4
 |      227.  mov	byte ptr [rcx + rax + 8], 0
 |      228.  jmp	.LBB3_35
 |      229.  lea	rcx, [rax + 80]
 |      230.  xor	edx, edx
 |      231.  jmp	.LBB3_34
 |      232.  lea	rcx, [rax + 136]
 |      233.  mov	edx, 1
 |      234.  jmp	.LBB3_34
 |      235.  lea	rcx, [rax + 192]
 +----> 236.  mov	edx, 2                            ## RESOURCE interference:  ICXPort5 [ probability: 99% ]
 +----> 237.  imul	rdx, rdx, 56                      ## REGISTER dependency:  edx
 |      238.  mov	byte ptr [rcx], 1
 +----> 239.  mov	r8, qword ptr [rax + rdx + 48]    ## REGISTER dependency:  rdx
 |      240.  add	dword ptr [rax + rdx + 56], 1
 |      241.  lea	r9, [rax + rdx]
 |      242.  add	r9, 32
 |      243.  mov	qword ptr [rax + rdx + 64], r9
 |      244.  mov	qword ptr [rax + rdx + 72], r8
 +----> 245.  mov	rcx, qword ptr [rax + rdx + 40]   ## RESOURCE interference:  ICXPort3 [ probability: 98% ]
 |      246.  add	rcx, r8
 |      247.  mov	r10d, ecx
 |      248.  and	r10d, 7
 |      249.  mov	r11d, 8
 |      250.  sub	r11, r10
 |      251.  test	r10, r10
 |      252.  cmove	r11, r10
 |      253.  lea	r8, [r8 + r11 + 32]
 |      254.  mov	qword ptr [rax + rdx + 48], r8
 |      255.  mov	qword ptr [r11 + rcx], rbp
 |      256.  mov	eax, dword ptr [r14]
 |      257.  mov	dword ptr [r11 + rcx + 24], eax
 |      258.  mov	qword ptr [r11 + rcx + 8], r9
 |      259.  mov	rax, qword ptr [rbp + 24]
 |      260.  mov	rdx, qword ptr [rbp + 16]
 |      261.  add	rdx, rax
 |      262.  mov	r8d, edx
 |      263.  and	r8d, 7
 |      264.  mov	r9d, 8
 |      265.  sub	r9, r8
 |      266.  test	r8, r8
 |      267.  cmove	r9, r8
 |      268.  lea	r8, [r11 + rcx]
 |      269.  add	rax, r9
 |      270.  add	rax, 24
 |      271.  add	r9, rdx
 |      272.  mov	qword ptr [rbp + 24], rax
 |      273.  mov	qword ptr [r11 + rcx + 16], r9
 |      274.  mov	byte ptr [r11 + rcx + 28], 2
 |      275.  mov	rax, qword ptr [rbp]
 |      276.  mov	rcx, qword ptr [rax + 288]
 |      277.  lea	rdx, [rip + handmade_asset.LoadSoundWork]
 |      278.  vzeroupper
 |      279.  call	qword ptr [rip + handmade_data.PlatformAddEntry]
 |      280.  mov	r11b, 1
 |      281.  vmovsd	xmm1, qword ptr [rbx + 8]
 +----> 282.  vmovsd	xmm0, qword ptr [rbx + 16]        ## RESOURCE interference:  ICXPort2 [ probability: 98% ]
 |      283.  vmulps	xmm2, xmm7, xmm0
 +----> 284.  vmovd	xmm0, dword ptr [rbx + 40]        ## RESOURCE interference:  ICXPort2 [ probability: 99% ]
 |      285.  mov	eax, dword ptr [rdi + 16]
 |      286.  vmovdqa	xmm3, xmm9
 +----> 287.  vpternlogd	xmm3, xmm0, xmm8, 248             ## REGISTER dependency:  xmm0
 +----> 288.  vaddss	xmm3, xmm0, xmm3                  ## REGISTER dependency:  xmm3
 +----> 289.  vroundss	xmm3, xmm3, xmm3, 11              ## REGISTER dependency:  xmm3
 |      290.  vcvttss2usi	ecx, xmm3
 |      291.  sub	eax, ecx
 |      292.  vcvtusi2ss	xmm4, xmm17, eax
 |      293.  vmovss	xmm3, dword ptr [rbx + 32]
 |      294.  vdivss	xmm4, xmm4, xmm3
 |      295.  vmovdqa	xmm5, xmm9
 |      296.  vpternlogd	xmm5, xmm4, xmm8, 248
 |      297.  vaddss	xmm4, xmm4, xmm5
 |      298.  vroundss	xmm4, xmm4, xmm4, 11
 |      299.  vcvttss2usi	r8d, xmm4
 |      300.  cmp	esi, r8d
 |      301.  cmovb	r8d, esi
 |      302.  vucomiss	xmm2, xmm10
 |      303.  jne	.LBB3_36
 |      304.  jnp	.LBB3_38
 |      305.  vmovss	xmm4, dword ptr [rbx + 24]
 |      306.  vsubss	xmm4, xmm4, xmm1
 |      307.  vdivss	xmm4, xmm4, xmm2
 |      308.  vaddss	xmm4, xmm11, xmm4
 |      309.  vcvttss2usi	ecx, xmm4
 |      310.  cmp	r8d, ecx
 |      311.  seta	al
 |      312.  cmovae	r8d, ecx
 |      313.  vmovshdup	xmm4, xmm2
 |      314.  vucomiss	xmm4, xmm10
 |      315.  jne	.LBB3_37
 |      316.  jnp	.LBB3_39
 |      317.  vmovss	xmm5, dword ptr [rbx + 28]
 |      318.  vmovshdup	xmm16, xmm1
 |      319.  vsubss	xmm5, xmm5, xmm16
 |      320.  vdivss	xmm4, xmm5, xmm4
 |      321.  vaddss	xmm4, xmm11, xmm4
 |      322.  vcvttss2usi	ecx, xmm4
 |      323.  cmp	r8d, ecx
 |      324.  seta	dl
 |      325.  cmovae	r8d, ecx
 |      326.  mov	ecx, r8d
 |      327.  test	r8d, r8d
 |      328.  jne	.LBB3_40
 |      329.  jmp	.LBB3_42
 |      330.  xor	eax, eax
 |      331.  vmovshdup	xmm4, xmm2
 |      332.  vucomiss	xmm4, xmm10
 |      333.  jne	.LBB3_37
 |      334.  jp	.LBB3_37
 |      335.  xor	edx, edx
 |      336.  mov	ecx, r8d
 |      337.  test	r8d, r8d
 |      338.  je	.LBB3_42
 |      339.  xor	r8d, r8d
 +----> 340.  vroundss	xmm4, xmm0, xmm0, 9               ## RESOURCE interference:  ICXPort0 [ probability: 99% ]
 +----> 341.  vcvttss2si	r9d, xmm4                         ## REGISTER dependency:  xmm4
 |      342.  vcvtusi2ss	xmm4, xmm17, r9d
 |      343.  mov	r10, qword ptr [rdi]
 |      344.  vsubss	xmm4, xmm0, xmm4
 +----> 345.  vmovd	xmm5, dword ptr [r10 + 2*r9]      ## REGISTER dependency:  r9d
 +----> 346.  vpmovsxwd	xmm5, xmm5                        ## REGISTER dependency:  xmm5
 +----> 347.  vcvtdq2ps	xmm5, xmm5                        ## REGISTER dependency:  xmm5
 |      348.  vsubss	xmm16, xmm6, xmm4
 |      349.  vinsertps	xmm4, xmm16, xmm4, 16
 +----> 350.  vmulps	xmm4, xmm4, xmm5                  ## REGISTER dependency:  xmm5
 +----> 351.  vmovshdup	xmm5, xmm4                        ## REGISTER dependency:  xmm4
 |      352.  vmulss	xmm16, xmm1, dword ptr [r13 + 15202288]
 +----> 353.  vaddss	xmm4, xmm4, xmm5                  ## REGISTER dependency:  xmm5
 +----> 354.  vmulss	xmm5, xmm16, xmm4                 ## REGISTER dependency:  xmm4
 |      355.  vaddss	xmm5, xmm5, dword ptr [r12 + 4*r8]
 |      356.  vmovss	dword ptr [r12 + 4*r8], xmm5
 |      357.  vmovshdup	xmm5, xmm1
 |      358.  vmulss	xmm5, xmm5, dword ptr [r13 + 15202292]
 +----> 359.  vmulss	xmm4, xmm5, xmm4                  ## RESOURCE interference:  ICXPort1 [ probability: 99% ]
        360.  vaddss	xmm4, xmm4, dword ptr [r15 + 4*r8]
        361.  vmovss	dword ptr [r15 + 4*r8], xmm4
        362.  vaddps	xmm1, xmm2, xmm1
        363.  vaddss	xmm0, xmm3, xmm0
        364.  add	r8, 1
        365.  cmp	rcx, r8
        366.  jne	.LBB3_41
        367.  vmovlps	qword ptr [rbx + 8], xmm1
        368.  test	al, al
        369.  je	.LBB3_43
        370.  vmovss	xmm1, dword ptr [rbx + 24]
        371.  vmovss	dword ptr [rbx + 8], xmm1
        372.  mov	dword ptr [rbx + 16], 0
        373.  test	dl, dl
        374.  jne	.LBB3_46
        375.  vmovss	dword ptr [rbx + 40], xmm0
        376.  vcvttss2usi	eax, xmm0
        377.  cmp	dword ptr [rdi + 16], eax
        378.  jne	.LBB3_21
        379.  jmp	.LBB3_47
        380.  test	dl, dl
        381.  je	.LBB3_44
        382.  vmovss	xmm1, dword ptr [rbx + 28]
        383.  vmovss	dword ptr [rbx + 12], xmm1
        384.  mov	dword ptr [rbx + 20], 0
        385.  vmovss	dword ptr [rbx + 40], xmm0
        386.  vcvttss2usi	eax, xmm0
        387.  cmp	dword ptr [rdi + 16], eax
        388.  jne	.LBB3_21
        389.  mov	eax, dword ptr [r14]
        390.  test	eax, eax
        391.  je	.LBB3_57
        392.  mov	dword ptr [rbx + 36], eax
        393.  mov	dword ptr [rbx + 40], 0
        394.  jmp	.LBB3_21
        395.  test	rax, rax
        396.  je	.LBB3_20
        397.  xor	eax, eax
        398.  lock		cmpxchg	byte ptr [rcx + rdx + 8], r11b
        399.  mov	rdi, qword ptr [rsp + 32]
        400.  jne	.LBB3_59
        401.  mov	rax, qword ptr [rbp]
        402.  cmp	byte ptr [rax + 80], 1
        403.  jne	.LBB3_62
        404.  cmp	byte ptr [rax + 136], 1
        405.  jne	.LBB3_63
        406.  cmp	byte ptr [rax + 192], 1
        407.  jne	.LBB3_64
        408.  cmp	byte ptr [rax + 248], 0
        409.  jne	.LBB3_60
        410.  lea	rcx, [rax + 248]
        411.  mov	edx, 3
        412.  jmp	.LBB3_65
        413.  mov	rax, qword ptr [rbx]
        414.  mov	rcx, qword ptr [rsp + 40]
        415.  mov	qword ptr [rcx], rax
        416.  mov	rax, qword ptr [r13 + 15202280]
        417.  mov	qword ptr [rbx], rax
        418.  mov	qword ptr [r13 + 15202280], rbx
        419.  mov	rbx, rcx
        420.  jmp	.LBB3_20
        421.  mov	eax, dword ptr [rbx + 36]
        422.  mov	rcx, qword ptr [rbp + 88]
        423.  shl	rax, 4
        424.  mov	byte ptr [rcx + rax + 8], 0
        425.  mov	rax, qword ptr [rbx]
        426.  test	rax, rax
        427.  jne	.LBB3_61
        428.  mov	eax, dword ptr [rdi + 12]
        429.  test	rax, rax
        430.  je	.LBB3_86
        431.  mov	rcx, qword ptr [rdi]
        432.  cmp	eax, 8
        433.  jae	.LBB3_70
        434.  xor	edx, edx
        435.  jmp	.LBB3_81
        436.  lea	rdx, [rcx + 4*rax]
        437.  lea	r8, [r12 + 4*rax]
        438.  cmp	rcx, r8
        439.  setb	r10b
        440.  cmp	rdx, r12
        441.  seta	r11b
        442.  lea	r8, [r15 + 4*rax]
        443.  cmp	rcx, r8
        444.  setb	r8b
        445.  cmp	rdx, r15
        446.  seta	r9b
        447.  xor	edx, edx
        448.  test	r10b, r11b
        449.  jne	.LBB3_81
        450.  and	r8b, r9b
        451.  jne	.LBB3_81
        452.  cmp	eax, 16
        453.  jae	.LBB3_77
        454.  xor	edx, edx
        455.  mov	r8, rdx
        456.  mov	edx, eax
        457.  and	edx, -8
        458.  vbroadcastss	ymm0, dword ptr [rip + .LCPI3_3]
        459.  vaddps	ymm1, ymm0, ymmword ptr [r12 + 4*r8]
        460.  vcvttps2dq	ymm1, ymm1
        461.  vpmovdw	xmm1, ymm1
        462.  vaddps	ymm2, ymm0, ymmword ptr [r15 + 4*r8]
        463.  vcvttps2dq	ymm2, ymm2
        464.  vpmovdw	xmm2, ymm2
        465.  vpunpcklwd	xmm3, xmm1, xmm2
        466.  vpunpckhwd	xmm1, xmm1, xmm2
        467.  vmovdqu	xmmword ptr [rcx + 4*r8 + 16], xmm1
        468.  vmovdqu	xmmword ptr [rcx + 4*r8], xmm3
        469.  add	r8, 8
        470.  cmp	rdx, r8
        471.  jne	.LBB3_75
        472.  cmp	rdx, rax
        473.  jne	.LBB3_81
        474.  jmp	.LBB3_86
        475.  lea	r8, [4*rax]
        476.  movabs	rdx, 17179868928
        477.  or	rdx, 192
        478.  and	rdx, r8
        479.  xor	r8d, r8d
        480.  vbroadcastss	zmm0, dword ptr [rip + .LCPI3_3]
        481.  vmovdqa64	zmm1, zmmword ptr [rip + .LCPI3_4]
        482.  vaddps	zmm2, zmm0, zmmword ptr [r12 + r8]
        483.  vcvttps2dq	zmm2, zmm2
        484.  vpmovdw	ymm2, zmm2
        485.  vaddps	zmm3, zmm0, zmmword ptr [r15 + r8]
        486.  vcvttps2dq	zmm3, zmm3
        487.  vpmovdw	ymm3, zmm3
        488.  vinserti64x4	zmm3, zmm3, ymm3, 1
        489.  vinserti64x4	zmm2, zmm2, ymm2, 1
        490.  vpermt2w	zmm2, zmm1, zmm3
        491.  vmovdqu64	zmmword ptr [rcx + r8], zmm2
        492.  add	r8, 64
        493.  cmp	rdx, r8
        494.  jne	.LBB3_78
        495.  mov	edx, eax
        496.  and	edx, -16
        497.  cmp	rdx, rax
        498.  je	.LBB3_86
        499.  test	al, 8
        500.  jne	.LBB3_74
        501.  mov	r8, rdx
        502.  not	r8
        503.  test	al, 1
        504.  je	.LBB3_83
        505.  vmovss	xmm0, dword ptr [rip + .LCPI3_3]
        506.  vaddss	xmm1, xmm0, dword ptr [r12 + 4*rdx]
        507.  vcvttss2si	r9d, xmm1
        508.  mov	word ptr [rcx + 4*rdx], r9w
        509.  vaddss	xmm0, xmm0, dword ptr [r15 + 4*rdx]
        510.  vcvttss2si	r9d, xmm0
        511.  mov	word ptr [rcx + 4*rdx + 2], r9w
        512.  or	rdx, 1
        513.  add	r8, rax
        514.  je	.LBB3_86
        515.  add	r15, 4
        516.  vmovss	xmm0, dword ptr [rip + .LCPI3_3]
        517.  vaddss	xmm1, xmm0, dword ptr [r12 + 4*rdx]
        518.  vcvttss2si	r8d, xmm1
        519.  mov	word ptr [rcx + 4*rdx], r8w
        520.  vaddss	xmm1, xmm0, dword ptr [r15 + 4*rdx - 4]
        521.  vcvttss2si	r8d, xmm1
        522.  mov	word ptr [rcx + 4*rdx + 2], r8w
        523.  vaddss	xmm1, xmm0, dword ptr [r12 + 4*rdx + 4]
        524.  vcvttss2si	r8d, xmm1
        525.  mov	word ptr [rcx + 4*rdx + 4], r8w
        526.  vaddss	xmm1, xmm0, dword ptr [r15 + 4*rdx]
        527.  vcvttss2si	r8d, xmm1
        528.  mov	word ptr [rcx + 4*rdx + 6], r8w
        529.  add	rdx, 2
        530.  cmp	rax, rdx
        531.  jne	.LBB3_85


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
 1      5     0.50    *                   mov	ecx, dword ptr [rdx + 12]
 1      5     0.50    *                   mov	rax, qword ptr [r10 + 8]
 1      5     0.50    *                   mov	rdx, qword ptr [r10 + 16]
 1      1     0.50                        lea	r8, [rdx + rax]
 1      1     0.25                        mov	r9d, r8d
 1      1     0.25                        and	r9d, 3
 1      1     0.25                        mov	r15d, 4
 1      1     0.25                        mov	r12d, 4
 1      1     0.25                        sub	r12, r9
 1      1     0.25                        test	r9, r9
 1      1     0.50                        cmove	r12, r9
 1      1     0.50                        lea	rcx, [rdx + 4*rcx]
 1      1     0.25                        add	rcx, r12
 1      1     0.25                        add	r12, r8
 1      1     1.00           *            mov	qword ptr [r10 + 16], rcx
 1      5     0.50    *                   mov	edx, dword ptr [rdi + 12]
 1      1     0.25                        add	rax, rcx
 1      1     0.25                        mov	r8d, eax
 1      1     0.25                        and	r8d, 3
 1      1     0.25                        sub	r15, r8
 1      1     0.25                        test	r8, r8
 1      1     0.50                        cmove	r15, r8
 1      1     0.50                        lea	rcx, [rcx + 4*rdx]
 1      1     0.25                        add	rcx, r15
 1      1     1.00           *            mov	qword ptr [rsp + 56], r10
 1      1     1.00           *            mov	qword ptr [r10 + 16], rcx
 2      9     1.00    *                   vcvtusi2ss	xmm0, xmm0, dword ptr [rdi + 8]
 1      1     0.25                        add	r15, rax
 1      5     0.50    *                   mov	eax, dword ptr [rdi + 12]
 1      1     0.25                        test	rax, rax
 1      1     0.50                        je	.LBB3_17
 1      0     0.17                        xor	ecx, ecx
 1      1     0.25                        cmp	eax, 8
 1      1     0.50                        jb	.LBB3_12
 1      1     0.25                        mov	rdx, r15
 1      1     0.25                        sub	rdx, r12
 1      1     0.25                        cmp	rdx, 256
 1      1     0.50                        jb	.LBB3_12
 1      1     0.25                        cmp	eax, 64
 1      1     0.50                        jae	.LBB3_5
 1      0     0.17                        xor	ecx, ecx
 1      1     0.50                        jmp	.LBB3_9
 1      1     0.50                        lea	rcx, [4*rax]
 1      1     0.25                        and	rcx, -256
 1      0     0.17                        xor	edx, edx
 1      0     0.17                        vxorps	xmm1, xmm1, xmm1
 2      1     1.00           *            vmovups	zmmword ptr [r12 + rdx + 192], zmm1
 2      1     1.00           *            vmovups	zmmword ptr [r12 + rdx + 128], zmm1
 2      1     1.00           *            vmovups	zmmword ptr [r12 + rdx + 64], zmm1
 2      1     1.00           *            vmovups	zmmword ptr [r12 + rdx], zmm1
 2      1     1.00           *            vmovups	zmmword ptr [r15 + rdx + 192], zmm1
 2      1     1.00           *            vmovups	zmmword ptr [r15 + rdx + 128], zmm1
 2      1     1.00           *            vmovups	zmmword ptr [r15 + rdx + 64], zmm1
 2      1     1.00           *            vmovups	zmmword ptr [r15 + rdx], zmm1
 1      1     0.50                        lea	r8, [rdx + 256]
 1      1     0.25                        mov	rdx, r8
 1      1     0.25                        cmp	rcx, r8
 1      1     0.50                        jne	.LBB3_6
 1      1     0.25                        mov	ecx, eax
 1      1     0.25                        and	ecx, -64
 1      1     0.25                        cmp	rcx, rax
 1      1     0.50                        je	.LBB3_17
 1      1     0.25                        test	al, 56
 1      1     0.50                        je	.LBB3_12
 1      1     0.25                        mov	rdx, rcx
 1      1     0.25                        mov	ecx, eax
 1      1     0.25                        and	ecx, -8
 1      0     0.17                        vxorps	xmm1, xmm1, xmm1
 2      1     1.00           *            vmovups	ymmword ptr [r12 + 4*rdx], ymm1
 2      1     1.00           *            vmovups	ymmword ptr [r15 + 4*rdx], ymm1
 1      1     0.25                        add	rdx, 8
 1      1     0.25                        cmp	rcx, rdx
 1      1     0.50                        jne	.LBB3_10
 1      1     0.25                        cmp	rcx, rax
 1      1     0.50                        je	.LBB3_17
 1      1     0.25                        mov	rdx, rcx
 1      1     0.25                        not	rdx
 1      1     0.25                        add	rdx, rax
 1      1     0.25                        mov	r8, rax
 1      1     0.25                        and	r8, 3
 1      1     0.50                        je	.LBB3_14
 1      1     1.00           *            mov	dword ptr [r12 + 4*rcx], 0
 1      1     1.00           *            mov	dword ptr [r15 + 4*rcx], 0
 1      1     0.25                        add	rcx, 1
 1      1     0.25                        add	r8, -1
 1      1     0.50                        jne	.LBB3_13
 1      1     0.25                        cmp	rdx, 3
 1      1     0.50                        jb	.LBB3_17
 1      1     0.50                        lea	rdx, [r15 + 12]
 1      1     0.50                        lea	r8, [r12 + 12]
 1      1     1.00           *            mov	dword ptr [r8 + 4*rcx - 12], 0
 1      1     1.00           *            mov	dword ptr [rdx + 4*rcx - 12], 0
 1      1     1.00           *            mov	dword ptr [r8 + 4*rcx - 8], 0
 1      1     1.00           *            mov	dword ptr [rdx + 4*rcx - 8], 0
 1      1     1.00           *            mov	dword ptr [r8 + 4*rcx - 4], 0
 1      1     1.00           *            mov	dword ptr [rdx + 4*rcx - 4], 0
 1      1     1.00           *            mov	dword ptr [r8 + 4*rcx], 0
 1      1     1.00           *            mov	dword ptr [rdx + 4*rcx], 0
 1      1     0.25                        add	rcx, 4
 1      1     0.25                        cmp	rax, rcx
 1      1     0.50                        jne	.LBB3_16
 1      5     0.50    *                   mov	rax, qword ptr [r13 + 15202272]
 1      1     0.25                        test	rax, rax
 1      1     0.50                        je	.LBB3_67
 1      5     0.50    *                   mov	esi, dword ptr [rdi + 12]
 1      1     0.25                        test	esi, esi
 1      1     0.50                        je	.LBB3_66
 1      1     1.00           *            mov	qword ptr [rsp + 32], rdi
 1      5     0.50    *                   vmovss	xmm6, dword ptr [rip + .LCPI3_0]
 1      11    3.00                        vdivss	xmm0, xmm6, xmm0
 1      1     0.50                        lea	rcx, [r13 + 15202272]
 1      1     1.00           *            mov	qword ptr [rsp + 40], rcx
 1      1     0.50                        vbroadcastss	xmm7, xmm0
 1      1     0.25                        mov	r11b, 1
 1      6     0.50    *                   vpbroadcastd	xmm8, dword ptr [rip + .LCPI3_1]
 1      6     0.50    *                   vpbroadcastd	xmm9, dword ptr [rip + .LCPI3_2]
 1      0     0.17                        vxorps	xmm10, xmm10, xmm10
 1      5     0.50    *                   vmovss	xmm11, dword ptr [rip + .LCPI3_3]
 1      1     0.25                        mov	rbx, rax
 1      1     0.25                        test	esi, esi
 1      1     0.50                        jne	.LBB3_22
 1      1     0.50                        jmp	.LBB3_20
 1      5     0.50    *                   mov	rax, qword ptr [rax]
 1      1     0.25                        test	rax, rax
 1      1     0.50                        jne	.LBB3_66
 1      1     0.50                        jmp	.LBB3_67
 1      1     0.50                        lea	rcx, [rax + 80]
 1      0     0.17                        xor	edx, edx
 1      1     0.50                        jmp	.LBB3_65
 1      1     0.50                        lea	rcx, [rax + 136]
 1      1     0.25                        mov	edx, 1
 1      1     0.50                        jmp	.LBB3_65
 1      1     0.50                        lea	rcx, [rax + 192]
 1      1     0.25                        mov	edx, 2
 1      3     1.00                        imul	rdx, rdx, 56
 1      1     1.00           *            mov	byte ptr [rcx], 1
 1      5     0.50    *                   mov	r8, qword ptr [rax + rdx + 48]
 3      7     1.00    *      *            add	dword ptr [rax + rdx + 56], 1
 1      1     0.50                        lea	r9, [rax + rdx]
 1      1     0.25                        add	r9, 32
 1      1     1.00           *            mov	qword ptr [rax + rdx + 64], r9
 1      1     1.00           *            mov	qword ptr [rax + rdx + 72], r8
 1      5     0.50    *                   mov	rcx, qword ptr [rax + rdx + 40]
 1      1     0.25                        add	rcx, r8
 1      1     0.25                        mov	r10d, ecx
 1      1     0.25                        and	r10d, 7
 1      1     0.25                        mov	r11d, 8
 1      1     0.25                        sub	r11, r10
 1      1     0.25                        test	r10, r10
 1      1     0.50                        cmove	r11, r10
 1      1     0.50                        lea	r8, [r8 + r11 + 32]
 1      1     1.00           *            mov	qword ptr [rax + rdx + 48], r8
 1      1     1.00           *            mov	qword ptr [r11 + rcx], rbp
 1      5     0.50    *                   mov	eax, dword ptr [rbx + 36]
 1      1     1.00           *            mov	dword ptr [r11 + rcx + 24], eax
 1      1     1.00           *            mov	qword ptr [r11 + rcx + 8], r9
 1      5     0.50    *                   mov	rax, qword ptr [rbp + 24]
 1      5     0.50    *                   mov	rdx, qword ptr [rbp + 16]
 1      1     0.25                        add	rdx, rax
 1      1     0.25                        mov	r8d, edx
 1      1     0.25                        and	r8d, 7
 1      1     0.25                        mov	r9d, 8
 1      1     0.25                        sub	r9, r8
 1      1     0.25                        test	r8, r8
 1      1     0.50                        cmove	r9, r8
 1      1     0.50                        lea	r8, [r11 + rcx]
 1      1     0.25                        add	rax, r9
 1      1     0.25                        add	rax, 24
 1      1     0.25                        add	r9, rdx
 1      1     1.00           *            mov	qword ptr [rbp + 24], rax
 1      1     1.00           *            mov	qword ptr [r11 + rcx + 16], r9
 1      1     1.00           *            mov	byte ptr [r11 + rcx + 28], 2
 1      5     0.50    *                   mov	rax, qword ptr [rbp]
 1      5     0.50    *                   mov	rcx, qword ptr [rax + 288]
 1      1     0.50                        lea	rdx, [rip + handmade_asset.LoadSoundWork]
 4      0     0.67                  U     vzeroupper
 5      7     1.00    *                   call	qword ptr [rip + handmade_data.PlatformAddEntry]
 1      1     0.25                        mov	r11b, 1
 1      5     0.50    *                   mov	rax, qword ptr [rbx]
 1      1     0.25                        test	rax, rax
 1      1     0.50                        jne	.LBB3_61
 1      1     0.50                        jmp	.LBB3_67
 1      5     0.50    *                   mov	rdi, qword ptr [rsp + 32]
 1      5     0.50    *                   mov	rax, qword ptr [rbx]
 1      1     0.25                        test	rax, rax
 1      1     0.50                        je	.LBB3_67
 1      5     0.50    *                   mov	esi, dword ptr [rdi + 12]
 1      1     1.00           *            mov	qword ptr [rsp + 40], rbx
 1      1     0.25                        mov	rbx, rax
 1      1     0.25                        test	esi, esi
 1      1     0.50                        jne	.LBB3_22
 1      1     0.50                        jmp	.LBB3_20
 1      1     0.25                        sub	esi, ecx
 1      1     0.50                        je	.LBB3_20
 1      5     0.50    *                   mov	rcx, qword ptr [rbp + 88]
 1      5     0.50    *                   mov	eax, dword ptr [rbx + 36]
 1      1     0.25                        mov	rdx, rax
 1      1     0.50                        shl	rdx, 4
 1      5     0.50    *                   mov	rdi, qword ptr [rcx + rdx]
 1      1     0.25                        test	rdi, rdi
 1      1     0.50                        je	.LBB3_49
 1      5     0.50    *                   mov	rdx, qword ptr [rbp + 72]
 1      1     0.50                        lea	rax, [rax + 2*rax]
 1      1     0.50                        lea	r14, [rdx + 8*rax]
 1      1     0.25                        add	r14, 16
 1      5     0.50    *                   mov	edx, dword ptr [rdx + 8*rax + 16]
 1      1     0.25                        test	rdx, rdx
 1      1     0.50                        je	.LBB3_35
 1      1     0.50                        shl	rdx, 4
 1      0     0.17                        xor	eax, eax
 6      8     1.00    *      *            lock		cmpxchg	byte ptr [rcx + rdx + 8], r11b
 1      1     0.50                        jne	.LBB3_30
 1      5     0.50    *                   mov	rax, qword ptr [rbp]
 2      6     0.50    *                   cmp	byte ptr [rax + 80], 1
 1      1     0.50                        jne	.LBB3_31
 2      6     0.50    *                   cmp	byte ptr [rax + 136], 1
 1      1     0.50                        jne	.LBB3_32
 2      6     0.50    *                   cmp	byte ptr [rax + 192], 1
 1      1     0.50                        jne	.LBB3_33
 2      6     0.50    *                   cmp	byte ptr [rax + 248], 0
 1      1     0.50                        jne	.LBB3_35
 1      1     0.50                        lea	rcx, [rax + 248]
 1      1     0.25                        mov	edx, 3
 1      1     0.50                        jmp	.LBB3_34
 1      5     0.50    *                   mov	eax, dword ptr [r14]
 1      5     0.50    *                   mov	rcx, qword ptr [rbp + 88]
 1      1     0.50                        shl	rax, 4
 1      1     1.00           *            mov	byte ptr [rcx + rax + 8], 0
 1      1     0.50                        jmp	.LBB3_35
 1      1     0.50                        lea	rcx, [rax + 80]
 1      0     0.17                        xor	edx, edx
 1      1     0.50                        jmp	.LBB3_34
 1      1     0.50                        lea	rcx, [rax + 136]
 1      1     0.25                        mov	edx, 1
 1      1     0.50                        jmp	.LBB3_34
 1      1     0.50                        lea	rcx, [rax + 192]
 1      1     0.25                        mov	edx, 2
 1      3     1.00                        imul	rdx, rdx, 56
 1      1     1.00           *            mov	byte ptr [rcx], 1
 1      5     0.50    *                   mov	r8, qword ptr [rax + rdx + 48]
 3      7     1.00    *      *            add	dword ptr [rax + rdx + 56], 1
 1      1     0.50                        lea	r9, [rax + rdx]
 1      1     0.25                        add	r9, 32
 1      1     1.00           *            mov	qword ptr [rax + rdx + 64], r9
 1      1     1.00           *            mov	qword ptr [rax + rdx + 72], r8
 1      5     0.50    *                   mov	rcx, qword ptr [rax + rdx + 40]
 1      1     0.25                        add	rcx, r8
 1      1     0.25                        mov	r10d, ecx
 1      1     0.25                        and	r10d, 7
 1      1     0.25                        mov	r11d, 8
 1      1     0.25                        sub	r11, r10
 1      1     0.25                        test	r10, r10
 1      1     0.50                        cmove	r11, r10
 1      1     0.50                        lea	r8, [r8 + r11 + 32]
 1      1     1.00           *            mov	qword ptr [rax + rdx + 48], r8
 1      1     1.00           *            mov	qword ptr [r11 + rcx], rbp
 1      5     0.50    *                   mov	eax, dword ptr [r14]
 1      1     1.00           *            mov	dword ptr [r11 + rcx + 24], eax
 1      1     1.00           *            mov	qword ptr [r11 + rcx + 8], r9
 1      5     0.50    *                   mov	rax, qword ptr [rbp + 24]
 1      5     0.50    *                   mov	rdx, qword ptr [rbp + 16]
 1      1     0.25                        add	rdx, rax
 1      1     0.25                        mov	r8d, edx
 1      1     0.25                        and	r8d, 7
 1      1     0.25                        mov	r9d, 8
 1      1     0.25                        sub	r9, r8
 1      1     0.25                        test	r8, r8
 1      1     0.50                        cmove	r9, r8
 1      1     0.50                        lea	r8, [r11 + rcx]
 1      1     0.25                        add	rax, r9
 1      1     0.25                        add	rax, 24
 1      1     0.25                        add	r9, rdx
 1      1     1.00           *            mov	qword ptr [rbp + 24], rax
 1      1     1.00           *            mov	qword ptr [r11 + rcx + 16], r9
 1      1     1.00           *            mov	byte ptr [r11 + rcx + 28], 2
 1      5     0.50    *                   mov	rax, qword ptr [rbp]
 1      5     0.50    *                   mov	rcx, qword ptr [rax + 288]
 1      1     0.50                        lea	rdx, [rip + handmade_asset.LoadSoundWork]
 4      0     0.67                  U     vzeroupper
 5      7     1.00    *                   call	qword ptr [rip + handmade_data.PlatformAddEntry]
 1      1     0.25                        mov	r11b, 1
 1      5     0.50    *                   vmovsd	xmm1, qword ptr [rbx + 8]
 1      5     0.50    *                   vmovsd	xmm0, qword ptr [rbx + 16]
 1      4     0.50                        vmulps	xmm2, xmm7, xmm0
 1      5     0.50    *                   vmovd	xmm0, dword ptr [rbx + 40]
 1      5     0.50    *                   mov	eax, dword ptr [rdi + 16]
 1      1     0.33                        vmovdqa	xmm3, xmm9
 1      1     0.33                        vpternlogd	xmm3, xmm0, xmm8, 248
 1      4     0.50                        vaddss	xmm3, xmm0, xmm3
 2      8     1.00                        vroundss	xmm3, xmm3, xmm3, 11
 2      6     1.00                        vcvttss2usi	ecx, xmm3
 1      1     0.25                        sub	eax, ecx
 2      5     1.00                        vcvtusi2ss	xmm4, xmm17, eax
 1      5     0.50    *                   vmovss	xmm3, dword ptr [rbx + 32]
 1      11    3.00                        vdivss	xmm4, xmm4, xmm3
 1      1     0.33                        vmovdqa	xmm5, xmm9
 1      1     0.33                        vpternlogd	xmm5, xmm4, xmm8, 248
 1      4     0.50                        vaddss	xmm4, xmm4, xmm5
 2      8     1.00                        vroundss	xmm4, xmm4, xmm4, 11
 2      6     1.00                        vcvttss2usi	r8d, xmm4
 1      1     0.25                        cmp	esi, r8d
 1      1     0.50                        cmovb	r8d, esi
 1      2     1.00                        vucomiss	xmm2, xmm10
 1      1     0.50                        jne	.LBB3_36
 1      1     0.50                        jnp	.LBB3_38
 1      5     0.50    *                   vmovss	xmm4, dword ptr [rbx + 24]
 1      4     0.50                        vsubss	xmm4, xmm4, xmm1
 1      11    3.00                        vdivss	xmm4, xmm4, xmm2
 1      4     0.50                        vaddss	xmm4, xmm11, xmm4
 2      6     1.00                        vcvttss2usi	ecx, xmm4
 1      1     0.25                        cmp	r8d, ecx
 2      2     1.00                        seta	al
 1      1     0.50                        cmovae	r8d, ecx
 1      1     0.50                        vmovshdup	xmm4, xmm2
 1      2     1.00                        vucomiss	xmm4, xmm10
 1      1     0.50                        jne	.LBB3_37
 1      1     0.50                        jnp	.LBB3_39
 1      5     0.50    *                   vmovss	xmm5, dword ptr [rbx + 28]
 1      1     0.50                        vmovshdup	xmm16, xmm1
 1      4     0.50                        vsubss	xmm5, xmm5, xmm16
 1      11    3.00                        vdivss	xmm4, xmm5, xmm4
 1      4     0.50                        vaddss	xmm4, xmm11, xmm4
 2      6     1.00                        vcvttss2usi	ecx, xmm4
 1      1     0.25                        cmp	r8d, ecx
 2      2     1.00                        seta	dl
 1      1     0.50                        cmovae	r8d, ecx
 1      1     0.25                        mov	ecx, r8d
 1      1     0.25                        test	r8d, r8d
 1      1     0.50                        jne	.LBB3_40
 1      1     0.50                        jmp	.LBB3_42
 1      0     0.17                        xor	eax, eax
 1      1     0.50                        vmovshdup	xmm4, xmm2
 1      2     1.00                        vucomiss	xmm4, xmm10
 1      1     0.50                        jne	.LBB3_37
 1      1     0.50                        jp	.LBB3_37
 1      0     0.17                        xor	edx, edx
 1      1     0.25                        mov	ecx, r8d
 1      1     0.25                        test	r8d, r8d
 1      1     0.50                        je	.LBB3_42
 1      0     0.17                        xor	r8d, r8d
 2      8     1.00                        vroundss	xmm4, xmm0, xmm0, 9
 2      6     1.00                        vcvttss2si	r9d, xmm4
 2      5     1.00                        vcvtusi2ss	xmm4, xmm17, r9d
 1      5     0.50    *                   mov	r10, qword ptr [rdi]
 1      4     0.50                        vsubss	xmm4, xmm0, xmm4
 1      5     0.50    *                   vmovd	xmm5, dword ptr [r10 + 2*r9]
 1      1     0.50                        vpmovsxwd	xmm5, xmm5
 1      4     0.50                        vcvtdq2ps	xmm5, xmm5
 1      4     0.50                        vsubss	xmm16, xmm6, xmm4
 1      1     1.00                        vinsertps	xmm4, xmm16, xmm4, 16
 1      4     0.50                        vmulps	xmm4, xmm4, xmm5
 1      1     0.50                        vmovshdup	xmm5, xmm4
 2      9     0.50    *                   vmulss	xmm16, xmm1, dword ptr [r13 + 15202288]
 1      4     0.50                        vaddss	xmm4, xmm4, xmm5
 1      4     0.50                        vmulss	xmm5, xmm16, xmm4
 2      9     0.50    *                   vaddss	xmm5, xmm5, dword ptr [r12 + 4*r8]
 2      1     1.00           *            vmovss	dword ptr [r12 + 4*r8], xmm5
 1      1     0.50                        vmovshdup	xmm5, xmm1
 2      9     0.50    *                   vmulss	xmm5, xmm5, dword ptr [r13 + 15202292]
 1      4     0.50                        vmulss	xmm4, xmm5, xmm4
 2      9     0.50    *                   vaddss	xmm4, xmm4, dword ptr [r15 + 4*r8]
 2      1     1.00           *            vmovss	dword ptr [r15 + 4*r8], xmm4
 1      4     0.50                        vaddps	xmm1, xmm2, xmm1
 1      4     0.50                        vaddss	xmm0, xmm3, xmm0
 1      1     0.25                        add	r8, 1
 1      1     0.25                        cmp	rcx, r8
 1      1     0.50                        jne	.LBB3_41
 2      1     1.00           *            vmovlps	qword ptr [rbx + 8], xmm1
 1      1     0.25                        test	al, al
 1      1     0.50                        je	.LBB3_43
 1      5     0.50    *                   vmovss	xmm1, dword ptr [rbx + 24]
 2      1     1.00           *            vmovss	dword ptr [rbx + 8], xmm1
 1      1     1.00           *            mov	dword ptr [rbx + 16], 0
 1      1     0.25                        test	dl, dl
 1      1     0.50                        jne	.LBB3_46
 2      1     1.00           *            vmovss	dword ptr [rbx + 40], xmm0
 2      6     1.00                        vcvttss2usi	eax, xmm0
 2      6     0.50    *                   cmp	dword ptr [rdi + 16], eax
 1      1     0.50                        jne	.LBB3_21
 1      1     0.50                        jmp	.LBB3_47
 1      1     0.25                        test	dl, dl
 1      1     0.50                        je	.LBB3_44
 1      5     0.50    *                   vmovss	xmm1, dword ptr [rbx + 28]
 2      1     1.00           *            vmovss	dword ptr [rbx + 12], xmm1
 1      1     1.00           *            mov	dword ptr [rbx + 20], 0
 2      1     1.00           *            vmovss	dword ptr [rbx + 40], xmm0
 2      6     1.00                        vcvttss2usi	eax, xmm0
 2      6     0.50    *                   cmp	dword ptr [rdi + 16], eax
 1      1     0.50                        jne	.LBB3_21
 1      5     0.50    *                   mov	eax, dword ptr [r14]
 1      1     0.25                        test	eax, eax
 1      1     0.50                        je	.LBB3_57
 1      1     1.00           *            mov	dword ptr [rbx + 36], eax
 1      1     1.00           *            mov	dword ptr [rbx + 40], 0
 1      1     0.50                        jmp	.LBB3_21
 1      1     0.25                        test	rax, rax
 1      1     0.50                        je	.LBB3_20
 1      0     0.17                        xor	eax, eax
 6      8     1.00    *      *            lock		cmpxchg	byte ptr [rcx + rdx + 8], r11b
 1      5     0.50    *                   mov	rdi, qword ptr [rsp + 32]
 1      1     0.50                        jne	.LBB3_59
 1      5     0.50    *                   mov	rax, qword ptr [rbp]
 2      6     0.50    *                   cmp	byte ptr [rax + 80], 1
 1      1     0.50                        jne	.LBB3_62
 2      6     0.50    *                   cmp	byte ptr [rax + 136], 1
 1      1     0.50                        jne	.LBB3_63
 2      6     0.50    *                   cmp	byte ptr [rax + 192], 1
 1      1     0.50                        jne	.LBB3_64
 2      6     0.50    *                   cmp	byte ptr [rax + 248], 0
 1      1     0.50                        jne	.LBB3_60
 1      1     0.50                        lea	rcx, [rax + 248]
 1      1     0.25                        mov	edx, 3
 1      1     0.50                        jmp	.LBB3_65
 1      5     0.50    *                   mov	rax, qword ptr [rbx]
 1      5     0.50    *                   mov	rcx, qword ptr [rsp + 40]
 1      1     1.00           *            mov	qword ptr [rcx], rax
 1      5     0.50    *                   mov	rax, qword ptr [r13 + 15202280]
 1      1     1.00           *            mov	qword ptr [rbx], rax
 1      1     1.00           *            mov	qword ptr [r13 + 15202280], rbx
 1      1     0.25                        mov	rbx, rcx
 1      1     0.50                        jmp	.LBB3_20
 1      5     0.50    *                   mov	eax, dword ptr [rbx + 36]
 1      5     0.50    *                   mov	rcx, qword ptr [rbp + 88]
 1      1     0.50                        shl	rax, 4
 1      1     1.00           *            mov	byte ptr [rcx + rax + 8], 0
 1      5     0.50    *                   mov	rax, qword ptr [rbx]
 1      1     0.25                        test	rax, rax
 1      1     0.50                        jne	.LBB3_61
 1      5     0.50    *                   mov	eax, dword ptr [rdi + 12]
 1      1     0.25                        test	rax, rax
 1      1     0.50                        je	.LBB3_86
 1      5     0.50    *                   mov	rcx, qword ptr [rdi]
 1      1     0.25                        cmp	eax, 8
 1      1     0.50                        jae	.LBB3_70
 1      0     0.17                        xor	edx, edx
 1      1     0.50                        jmp	.LBB3_81
 1      1     0.50                        lea	rdx, [rcx + 4*rax]
 1      1     0.50                        lea	r8, [r12 + 4*rax]
 1      1     0.25                        cmp	rcx, r8
 1      1     0.50                        setb	r10b
 1      1     0.25                        cmp	rdx, r12
 2      2     1.00                        seta	r11b
 1      1     0.50                        lea	r8, [r15 + 4*rax]
 1      1     0.25                        cmp	rcx, r8
 1      1     0.50                        setb	r8b
 1      1     0.25                        cmp	rdx, r15
 2      2     1.00                        seta	r9b
 1      0     0.17                        xor	edx, edx
 1      1     0.25                        test	r10b, r11b
 1      1     0.50                        jne	.LBB3_81
 1      1     0.25                        and	r8b, r9b
 1      1     0.50                        jne	.LBB3_81
 1      1     0.25                        cmp	eax, 16
 1      1     0.50                        jae	.LBB3_77
 1      0     0.17                        xor	edx, edx
 1      1     0.25                        mov	r8, rdx
 1      1     0.25                        mov	edx, eax
 1      1     0.25                        and	edx, -8
 1      7     0.50    *                   vbroadcastss	ymm0, dword ptr [rip + .LCPI3_3]
 2      11    0.50    *                   vaddps	ymm1, ymm0, ymmword ptr [r12 + 4*r8]
 1      3     0.50                        vcvttps2dq	ymm1, ymm1
 2      4     2.00                        vpmovdw	xmm1, ymm1
 2      11    0.50    *                   vaddps	ymm2, ymm0, ymmword ptr [r15 + 4*r8]
 1      3     0.50                        vcvttps2dq	ymm2, ymm2
 2      4     2.00                        vpmovdw	xmm2, ymm2
 1      1     0.50                        vpunpcklwd	xmm3, xmm1, xmm2
 1      1     0.50                        vpunpckhwd	xmm1, xmm1, xmm2
 2      1     1.00           *            vmovdqu	xmmword ptr [rcx + 4*r8 + 16], xmm1
 2      1     1.00           *            vmovdqu	xmmword ptr [rcx + 4*r8], xmm3
 1      1     0.25                        add	r8, 8
 1      1     0.25                        cmp	rdx, r8
 1      1     0.50                        jne	.LBB3_75
 1      1     0.25                        cmp	rdx, rax
 1      1     0.50                        jne	.LBB3_81
 1      1     0.50                        jmp	.LBB3_86
 1      1     0.50                        lea	r8, [4*rax]
 1      1     0.25                        movabs	rdx, 17179868928
 1      1     0.25                        or	rdx, 192
 1      1     0.25                        and	rdx, r8
 1      0     0.17                        xor	r8d, r8d
 2      8     0.50    *                   vbroadcastss	zmm0, dword ptr [rip + .LCPI3_3]
 2      8     0.50    *                   vmovdqa64	zmm1, zmmword ptr [rip + .LCPI3_4]
 2      11    0.50    *                   vaddps	zmm2, zmm0, zmmword ptr [r12 + r8]
 1      4     0.50                        vcvttps2dq	zmm2, zmm2
 2      4     2.00                        vpmovdw	ymm2, zmm2
 2      11    0.50    *                   vaddps	zmm3, zmm0, zmmword ptr [r15 + r8]
 1      4     0.50                        vcvttps2dq	zmm3, zmm3
 2      4     2.00                        vpmovdw	ymm3, zmm3
 1      3     1.00                        vinserti64x4	zmm3, zmm3, ymm3, 1
 1      3     1.00                        vinserti64x4	zmm2, zmm2, ymm2, 1
 3      7     2.00                        vpermt2w	zmm2, zmm1, zmm3
 2      1     1.00           *            vmovdqu64	zmmword ptr [rcx + r8], zmm2
 1      1     0.25                        add	r8, 64
 1      1     0.25                        cmp	rdx, r8
 1      1     0.50                        jne	.LBB3_78
 1      1     0.25                        mov	edx, eax
 1      1     0.25                        and	edx, -16
 1      1     0.25                        cmp	rdx, rax
 1      1     0.50                        je	.LBB3_86
 1      1     0.25                        test	al, 8
 1      1     0.50                        jne	.LBB3_74
 1      1     0.25                        mov	r8, rdx
 1      1     0.25                        not	r8
 1      1     0.25                        test	al, 1
 1      1     0.50                        je	.LBB3_83
 1      5     0.50    *                   vmovss	xmm0, dword ptr [rip + .LCPI3_3]
 2      9     0.50    *                   vaddss	xmm1, xmm0, dword ptr [r12 + 4*rdx]
 2      6     1.00                        vcvttss2si	r9d, xmm1
 1      1     1.00           *            mov	word ptr [rcx + 4*rdx], r9w
 2      9     0.50    *                   vaddss	xmm0, xmm0, dword ptr [r15 + 4*rdx]
 2      6     1.00                        vcvttss2si	r9d, xmm0
 1      1     1.00           *            mov	word ptr [rcx + 4*rdx + 2], r9w
 1      1     0.25                        or	rdx, 1
 1      1     0.25                        add	r8, rax
 1      1     0.50                        je	.LBB3_86
 1      1     0.25                        add	r15, 4
 1      5     0.50    *                   vmovss	xmm0, dword ptr [rip + .LCPI3_3]
 2      9     0.50    *                   vaddss	xmm1, xmm0, dword ptr [r12 + 4*rdx]
 2      6     1.00                        vcvttss2si	r8d, xmm1
 1      1     1.00           *            mov	word ptr [rcx + 4*rdx], r8w
 2      9     0.50    *                   vaddss	xmm1, xmm0, dword ptr [r15 + 4*rdx - 4]
 2      6     1.00                        vcvttss2si	r8d, xmm1
 1      1     1.00           *            mov	word ptr [rcx + 4*rdx + 2], r8w
 2      9     0.50    *                   vaddss	xmm1, xmm0, dword ptr [r12 + 4*rdx + 4]
 2      6     1.00                        vcvttss2si	r8d, xmm1
 1      1     1.00           *            mov	word ptr [rcx + 4*rdx + 4], r8w
 2      9     0.50    *                   vaddss	xmm1, xmm0, dword ptr [r15 + 4*rdx]
 2      6     1.00                        vcvttss2si	r8d, xmm1
 1      1     1.00           *            mov	word ptr [rcx + 4*rdx + 6], r8w
 1      1     0.25                        add	rdx, 2
 1      1     0.25                        cmp	rax, rdx
 1      1     0.50                        jne	.LBB3_85


```
</details>

<details><summary>Dynamic Dispatch Stall Cycles:</summary>

```
RAT     - Register unavailable:                      0
RCU     - Retire tokens unavailable:                 9289  (44.6%)
SCHEDQ  - Scheduler full:                            1386  (6.7%)
LQ      - Load queue full:                           0
SQ      - Store queue full:                          0
GROUP   - Static restrictions on the dispatch group: 0
USH     - Uncategorised Structural Hazard:           0


```
</details>

<details><summary>Dispatch Logic - number of cycles where we saw N micro opcodes dispatched:</summary>

```
[# dispatched], [# cycles]
 0,              9223  (44.3%)
 2,              201  (1.0%)
 3,              396  (1.9%)
 4,              1392  (6.7%)
 5,              1300  (6.2%)
 6,              8307  (39.9%)


```
</details>

<details><summary>Schedulers - number of cycles where we saw N micro opcodes issued:</summary>

```
[# issued], [# cycles]
 0,          5805  (27.9%)
 1,          1412  (6.8%)
 2,          1509  (7.2%)
 3,          2498  (12.0%)
 4,          2302  (11.1%)
 5,          3793  (18.2%)
 6,          2000  (9.6%)
 7,          996  (4.8%)
 8,          205  (1.0%)
 9,          199  (1.0%)
 10,          100  (0.5%)

```
</details>

<details><summary>Scheduler's queue usage:</summary>

```
[1] Resource name.
[2] Average number of used buffer entries.
[3] Maximum number of used buffer entries.
[4] Total number of buffer entries.

 [1]            [2]        [3]        [4]
ICXPortAny       31         60         60


```
</details>

<details><summary>Retire Control Unit - number of cycles where we saw N instructions retired:</summary>

```
[# retired], [# cycles]
 0,           14698  (70.6%)
 1,           2707  (13.0%)
 2,           408  (2.0%)
 3,           704  (3.4%)
 4,           201  (1.0%)
 5,           301  (1.4%)
 8,           300  (1.4%)
 9,           1  (0.0%)
 10,          300  (1.4%)
 12,          101  (0.5%)
 15,          200  (1.0%)
 16,          100  (0.5%)
 17,          200  (1.0%)
 18,          99  (0.5%)
 21,          99  (0.5%)
 24,          100  (0.5%)
 32,          100  (0.5%)
 83,          1  (0.0%)
 103,          100  (0.5%)
 109,          99  (0.5%)

```
</details>

<details><summary>Total ROB Entries:                224</summary>

```
Max Used ROB Entries:             224  ( 100.0% )
Average Used ROB Entries per cy:  181  ( 80.8% )


```
</details>

<details><summary>Register File statistics:</summary>

```
Total number of mappings created:    45300
Max number of mappings used:         188


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
 -     12.00  113.03 107.00 60.99  61.01  77.00  97.02  95.95  51.00   -      -     

Resource pressure by instruction:
[0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   Instructions:
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	ecx, dword ptr [rdx + 12]
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     mov	rax, qword ptr [r10 + 8]
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	rdx, qword ptr [r10 + 16]
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     lea	r8, [rdx + rax]
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     mov	r9d, r8d
 -      -     1.00    -      -      -      -      -      -      -      -      -     and	r9d, 3
 -      -      -     0.99    -      -      -      -     0.01    -      -      -     mov	r15d, 4
 -      -     0.99    -      -      -      -     0.01    -      -      -      -     mov	r12d, 4
 -      -      -     0.99    -      -      -      -     0.01    -      -      -     sub	r12, r9
 -      -     0.99    -      -      -      -     0.01    -      -      -      -     test	r9, r9
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     cmove	r12, r9
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     lea	rcx, [rdx + 4*rcx]
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     add	rcx, r12
 -      -      -      -      -      -      -     0.99   0.01    -      -      -     add	r12, r8
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [r10 + 16], rcx
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     mov	edx, dword ptr [rdi + 12]
 -      -      -     0.99    -      -      -      -     0.01    -      -      -     add	rax, rcx
 -      -      -     0.99    -      -      -      -     0.01    -      -      -     mov	r8d, eax
 -      -      -      -      -      -      -     0.99   0.01    -      -      -     and	r8d, 3
 -      -      -      -      -      -      -     0.99   0.01    -      -      -     sub	r15, r8
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     test	r8, r8
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     cmove	r15, r8
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     lea	rcx, [rcx + 4*rdx]
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     add	rcx, r15
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rsp + 56], r10
 -      -      -      -     0.98   0.02   1.00    -      -      -      -      -     mov	qword ptr [r10 + 16], rcx
 -      -      -     1.00   0.01   0.99    -      -      -      -      -      -     vcvtusi2ss	xmm0, xmm0, dword ptr [rdi + 8]
 -      -      -      -      -      -      -     0.99   0.01    -      -      -     add	r15, rax
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     mov	eax, dword ptr [rdi + 12]
 -      -      -     0.01    -      -      -      -     0.99    -      -      -     test	rax, rax
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     je	.LBB3_17
 -      -      -      -      -      -      -      -      -      -      -      -     xor	ecx, ecx
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     cmp	eax, 8
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     jb	.LBB3_12
 -      -      -      -      -      -      -     0.99   0.01    -      -      -     mov	rdx, r15
 -      -      -      -      -      -      -     0.99   0.01    -      -      -     sub	rdx, r12
 -      -      -      -      -      -      -     0.99   0.01    -      -      -     cmp	rdx, 256
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     jb	.LBB3_12
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     cmp	eax, 64
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     jae	.LBB3_5
 -      -      -      -      -      -      -      -      -      -      -      -     xor	ecx, ecx
 -      -      -      -      -      -      -      -     1.00    -      -      -     jmp	.LBB3_9
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     lea	rcx, [4*rax]
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     and	rcx, -256
 -      -      -      -      -      -      -      -      -      -      -      -     xor	edx, edx
 -      -      -      -      -      -      -      -      -      -      -      -     vxorps	xmm1, xmm1, xmm1
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     vmovups	zmmword ptr [r12 + rdx + 192], zmm1
 -      -      -      -     0.99   0.01   1.00    -      -      -      -      -     vmovups	zmmword ptr [r12 + rdx + 128], zmm1
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     vmovups	zmmword ptr [r12 + rdx + 64], zmm1
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     vmovups	zmmword ptr [r12 + rdx], zmm1
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     vmovups	zmmword ptr [r15 + rdx + 192], zmm1
 -      -      -      -     0.99   0.01   1.00    -      -      -      -      -     vmovups	zmmword ptr [r15 + rdx + 128], zmm1
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     vmovups	zmmword ptr [r15 + rdx + 64], zmm1
 -      -      -      -      -     0.01   1.00    -      -     0.99    -      -     vmovups	zmmword ptr [r15 + rdx], zmm1
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	r8, [rdx + 256]
 -      -      -      -      -      -      -     0.01   0.99    -      -      -     mov	rdx, r8
 -      -      -     0.01    -      -      -      -     0.99    -      -      -     cmp	rcx, r8
 -      -     1.00    -      -      -      -      -      -      -      -      -     jne	.LBB3_6
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     mov	ecx, eax
 -      -      -      -      -      -      -     0.01   0.99    -      -      -     and	ecx, -64
 -      -      -     0.01    -      -      -      -     0.99    -      -      -     cmp	rcx, rax
 -      -     1.00    -      -      -      -      -      -      -      -      -     je	.LBB3_17
 -      -      -     0.01    -      -      -      -     0.99    -      -      -     test	al, 56
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     je	.LBB3_12
 -      -     1.00    -      -      -      -      -      -      -      -      -     mov	rdx, rcx
 -      -      -      -      -      -      -     1.00    -      -      -      -     mov	ecx, eax
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     and	ecx, -8
 -      -      -      -      -      -      -      -      -      -      -      -     vxorps	xmm1, xmm1, xmm1
 -      -      -      -     0.99   0.01   1.00    -      -      -      -      -     vmovups	ymmword ptr [r12 + 4*rdx], ymm1
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     vmovups	ymmword ptr [r15 + 4*rdx], ymm1
 -      -      -     1.00    -      -      -      -      -      -      -      -     add	rdx, 8
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     cmp	rcx, rdx
 -      -     1.00    -      -      -      -      -      -      -      -      -     jne	.LBB3_10
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     cmp	rcx, rax
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     je	.LBB3_17
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     mov	rdx, rcx
 -      -      -     1.00    -      -      -      -      -      -      -      -     not	rdx
 -      -      -      -      -      -      -     1.00    -      -      -      -     add	rdx, rax
 -      -      -     0.01    -      -      -      -     0.99    -      -      -     mov	r8, rax
 -      -      -      -      -      -      -     0.01   0.99    -      -      -     and	r8, 3
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     je	.LBB3_14
 -      -      -      -     0.98   0.01   1.00    -      -     0.01    -      -     mov	dword ptr [r12 + 4*rcx], 0
 -      -      -      -     0.01    -     1.00    -      -     0.99    -      -     mov	dword ptr [r15 + 4*rcx], 0
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     add	rcx, 1
 -      -      -      -      -      -      -     0.01   0.99    -      -      -     add	r8, -1
 -      -      -      -      -      -      -      -     1.00    -      -      -     jne	.LBB3_13
 -      -     0.01    -      -      -      -     0.99    -      -      -      -     cmp	rdx, 3
 -      -     1.00    -      -      -      -      -      -      -      -      -     jb	.LBB3_17
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	rdx, [r15 + 12]
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	r8, [r12 + 12]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	dword ptr [r8 + 4*rcx - 12], 0
 -      -      -      -      -     0.99   1.00    -      -     0.01    -      -     mov	dword ptr [rdx + 4*rcx - 12], 0
 -      -      -      -     0.01    -     1.00    -      -     0.99    -      -     mov	dword ptr [r8 + 4*rcx - 8], 0
 -      -      -      -      -     0.99   1.00    -      -     0.01    -      -     mov	dword ptr [rdx + 4*rcx - 8], 0
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	dword ptr [r8 + 4*rcx - 4], 0
 -      -      -      -     0.01    -     1.00    -      -     0.99    -      -     mov	dword ptr [rdx + 4*rcx - 4], 0
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	dword ptr [r8 + 4*rcx], 0
 -      -      -      -     0.98   0.01   1.00    -      -     0.01    -      -     mov	dword ptr [rdx + 4*rcx], 0
 -      -     0.99    -      -      -      -     0.01    -      -      -      -     add	rcx, 4
 -      -      -      -      -      -      -     0.99   0.01    -      -      -     cmp	rax, rcx
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     jne	.LBB3_16
 -      -      -      -     0.02   0.98    -      -      -      -      -      -     mov	rax, qword ptr [r13 + 15202272]
 -      -      -     0.01    -      -      -      -     0.99    -      -      -     test	rax, rax
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     je	.LBB3_67
 -      -      -      -     0.98   0.02    -      -      -      -      -      -     mov	esi, dword ptr [rdi + 12]
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     test	esi, esi
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     je	.LBB3_66
 -      -      -      -     0.01    -     1.00    -      -     0.99    -      -     mov	qword ptr [rsp + 32], rdi
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     vmovss	xmm6, dword ptr [rip + .LCPI3_0]
 -     3.00   1.00    -      -      -      -      -      -      -      -      -     vdivss	xmm0, xmm6, xmm0
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     lea	rcx, [r13 + 15202272]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rsp + 40], rcx
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     vbroadcastss	xmm7, xmm0
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     mov	r11b, 1
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     vpbroadcastd	xmm8, dword ptr [rip + .LCPI3_1]
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     vpbroadcastd	xmm9, dword ptr [rip + .LCPI3_2]
 -      -      -      -      -      -      -      -      -      -      -      -     vxorps	xmm10, xmm10, xmm10
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     vmovss	xmm11, dword ptr [rip + .LCPI3_3]
 -      -      -      -      -      -      -     1.00    -      -      -      -     mov	rbx, rax
 -      -      -     1.00    -      -      -      -      -      -      -      -     test	esi, esi
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     jne	.LBB3_22
 -      -      -      -      -      -      -      -     1.00    -      -      -     jmp	.LBB3_20
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     mov	rax, qword ptr [rax]
 -      -      -      -      -      -      -     0.99   0.01    -      -      -     test	rax, rax
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     jne	.LBB3_66
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     jmp	.LBB3_67
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     lea	rcx, [rax + 80]
 -      -      -      -      -      -      -      -      -      -      -      -     xor	edx, edx
 -      -     1.00    -      -      -      -      -      -      -      -      -     jmp	.LBB3_65
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     lea	rcx, [rax + 136]
 -      -      -      -      -      -      -     1.00    -      -      -      -     mov	edx, 1
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     jmp	.LBB3_65
 -      -      -      -      -      -      -     1.00    -      -      -      -     lea	rcx, [rax + 192]
 -      -      -     1.00    -      -      -      -      -      -      -      -     mov	edx, 2
 -      -      -     1.00    -      -      -      -      -      -      -      -     imul	rdx, rdx, 56
 -      -      -      -     0.01    -     1.00    -      -     0.99    -      -     mov	byte ptr [rcx], 1
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	r8, qword ptr [rax + rdx + 48]
 -      -      -     0.99   1.00   0.99   1.00    -     0.01   0.01    -      -     add	dword ptr [rax + rdx + 56], 1
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     lea	r9, [rax + rdx]
 -      -      -      -      -      -      -      -     1.00    -      -      -     add	r9, 32
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rax + rdx + 64], r9
 -      -      -      -     0.99   0.01   1.00    -      -      -      -      -     mov	qword ptr [rax + rdx + 72], r8
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     mov	rcx, qword ptr [rax + rdx + 40]
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     add	rcx, r8
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     mov	r10d, ecx
 -      -      -      -      -      -      -     0.99   0.01    -      -      -     and	r10d, 7
 -      -      -      -      -      -      -     0.01   0.99    -      -      -     mov	r11d, 8
 -      -      -      -      -      -      -     1.00    -      -      -      -     sub	r11, r10
 -      -      -     1.00    -      -      -      -      -      -      -      -     test	r10, r10
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     cmove	r11, r10
 -      -      -      -      -      -      -     1.00    -      -      -      -     lea	r8, [r8 + r11 + 32]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rax + rdx + 48], r8
 -      -      -      -     0.01    -     1.00    -      -     0.99    -      -     mov	qword ptr [r11 + rcx], rbp
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	eax, dword ptr [rbx + 36]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	dword ptr [r11 + rcx + 24], eax
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [r11 + rcx + 8], r9
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     mov	rax, qword ptr [rbp + 24]
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	rdx, qword ptr [rbp + 16]
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     add	rdx, rax
 -      -      -      -      -      -      -     0.01   0.99    -      -      -     mov	r8d, edx
 -      -      -      -      -      -      -     0.99   0.01    -      -      -     and	r8d, 7
 -      -      -     1.00    -      -      -      -      -      -      -      -     mov	r9d, 8
 -      -      -     0.99    -      -      -      -     0.01    -      -      -     sub	r9, r8
 -      -     0.01    -      -      -      -     0.99    -      -      -      -     test	r8, r8
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     cmove	r9, r8
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	r8, [r11 + rcx]
 -      -      -     0.99    -      -      -      -     0.01    -      -      -     add	rax, r9
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     add	rax, 24
 -      -     1.00    -      -      -      -      -      -      -      -      -     add	r9, rdx
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rbp + 24], rax
 -      -      -      -     0.99   0.01   1.00    -      -      -      -      -     mov	qword ptr [r11 + rcx + 16], r9
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	byte ptr [r11 + rcx + 28], 2
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	rax, qword ptr [rbp]
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	rcx, qword ptr [rax + 288]
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     lea	rdx, [rip + handmade_asset.LoadSoundWork]
 -      -      -      -      -      -      -      -      -      -      -      -     vzeroupper
 -      -     0.99    -     1.00   0.99   1.00   0.01   1.00   0.01    -      -     call	qword ptr [rip + handmade_data.PlatformAddEntry]
 -      -     1.00    -      -      -      -      -      -      -      -      -     mov	r11b, 1
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	rax, qword ptr [rbx]
 -      -      -     0.01    -      -      -      -     0.99    -      -      -     test	rax, rax
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     jne	.LBB3_61
 -      -     1.00    -      -      -      -      -      -      -      -      -     jmp	.LBB3_67
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     mov	rdi, qword ptr [rsp + 32]
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	rax, qword ptr [rbx]
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     test	rax, rax
 -      -     1.00    -      -      -      -      -      -      -      -      -     je	.LBB3_67
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	esi, dword ptr [rdi + 12]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rsp + 40], rbx
 -      -      -      -      -      -      -     0.01   0.99    -      -      -     mov	rbx, rax
 -      -      -      -      -      -      -     0.99   0.01    -      -      -     test	esi, esi
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     jne	.LBB3_22
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     jmp	.LBB3_20
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     sub	esi, ecx
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     je	.LBB3_20
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     mov	rcx, qword ptr [rbp + 88]
 -      -      -      -     0.98   0.02    -      -      -      -      -      -     mov	eax, dword ptr [rbx + 36]
 -      -      -     0.99    -      -      -      -     0.01    -      -      -     mov	rdx, rax
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     shl	rdx, 4
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	rdi, qword ptr [rcx + rdx]
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     test	rdi, rdi
 -      -      -      -      -      -      -      -     1.00    -      -      -     je	.LBB3_49
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	rdx, qword ptr [rbp + 72]
 -      -      -      -      -      -      -     1.00    -      -      -      -     lea	rax, [rax + 2*rax]
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     lea	r14, [rdx + 8*rax]
 -      -     0.01    -      -      -      -     0.99    -      -      -      -     add	r14, 16
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	edx, dword ptr [rdx + 8*rax + 16]
 -      -      -      -      -      -      -     1.00    -      -      -      -     test	rdx, rdx
 -      -      -      -      -      -      -      -     1.00    -      -      -     je	.LBB3_35
 -      -      -      -      -      -      -      -     1.00    -      -      -     shl	rdx, 4
 -      -      -      -      -      -      -      -      -      -      -      -     xor	eax, eax
 -      -     0.02    -     0.99   0.01   1.00   1.00   1.98   1.00    -      -     lock		cmpxchg	byte ptr [rcx + rdx + 8], r11b
 -      -      -      -      -      -      -      -     1.00    -      -      -     jne	.LBB3_30
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	rax, qword ptr [rbp]
 -      -      -     0.99   0.99   0.01    -     0.01    -      -      -      -     cmp	byte ptr [rax + 80], 1
 -      -     1.00    -      -      -      -      -      -      -      -      -     jne	.LBB3_31
 -      -     0.99    -     0.02   0.98    -     0.01    -      -      -      -     cmp	byte ptr [rax + 136], 1
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     jne	.LBB3_32
 -      -      -     0.01   0.98   0.02    -      -     0.99    -      -      -     cmp	byte ptr [rax + 192], 1
 -      -     1.00    -      -      -      -      -      -      -      -      -     jne	.LBB3_33
 -      -      -     0.01   0.99   0.01    -     0.99    -      -      -      -     cmp	byte ptr [rax + 248], 0
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     jne	.LBB3_35
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     lea	rcx, [rax + 248]
 -      -      -     0.01    -      -      -      -     0.99    -      -      -     mov	edx, 3
 -      -     1.00    -      -      -      -      -      -      -      -      -     jmp	.LBB3_34
 -      -      -      -     0.02   0.98    -      -      -      -      -      -     mov	eax, dword ptr [r14]
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     mov	rcx, qword ptr [rbp + 88]
 -      -     1.00    -      -      -      -      -      -      -      -      -     shl	rax, 4
 -      -      -      -      -     0.99   1.00    -      -     0.01    -      -     mov	byte ptr [rcx + rax + 8], 0
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     jmp	.LBB3_35
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     lea	rcx, [rax + 80]
 -      -      -      -      -      -      -      -      -      -      -      -     xor	edx, edx
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     jmp	.LBB3_34
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     lea	rcx, [rax + 136]
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     mov	edx, 1
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     jmp	.LBB3_34
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     lea	rcx, [rax + 192]
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     mov	edx, 2
 -      -      -     1.00    -      -      -      -      -      -      -      -     imul	rdx, rdx, 56
 -      -      -      -     0.99    -     1.00    -      -     0.01    -      -     mov	byte ptr [rcx], 1
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	r8, qword ptr [rax + rdx + 48]
 -      -      -     0.01   0.01   0.99   1.00    -     0.99   1.00    -      -     add	dword ptr [rax + rdx + 56], 1
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     lea	r9, [rax + rdx]
 -      -      -      -      -      -      -      -     1.00    -      -      -     add	r9, 32
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rax + rdx + 64], r9
 -      -      -      -      -     1.00   1.00    -      -      -      -      -     mov	qword ptr [rax + rdx + 72], r8
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     mov	rcx, qword ptr [rax + rdx + 40]
 -      -     0.99    -      -      -      -     0.01    -      -      -      -     add	rcx, r8
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     mov	r10d, ecx
 -      -     0.01    -      -      -      -     0.99    -      -      -      -     and	r10d, 7
 -      -     1.00    -      -      -      -      -      -      -      -      -     mov	r11d, 8
 -      -     1.00    -      -      -      -      -      -      -      -      -     sub	r11, r10
 -      -      -      -      -      -      -      -     1.00    -      -      -     test	r10, r10
 -      -     1.00    -      -      -      -      -      -      -      -      -     cmove	r11, r10
 -      -      -      -      -      -      -     1.00    -      -      -      -     lea	r8, [r8 + r11 + 32]
 -      -      -      -     0.99    -     1.00    -      -     0.01    -      -     mov	qword ptr [rax + rdx + 48], r8
 -      -      -      -      -     0.01   1.00    -      -     0.99    -      -     mov	qword ptr [r11 + rcx], rbp
 -      -      -      -     0.98   0.02    -      -      -      -      -      -     mov	eax, dword ptr [r14]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	dword ptr [r11 + rcx + 24], eax
 -      -      -      -      -     0.99   1.00    -      -     0.01    -      -     mov	qword ptr [r11 + rcx + 8], r9
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	rax, qword ptr [rbp + 24]
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     mov	rdx, qword ptr [rbp + 16]
 -      -     1.00    -      -      -      -      -      -      -      -      -     add	rdx, rax
 -      -      -      -      -      -      -     0.99   0.01    -      -      -     mov	r8d, edx
 -      -     0.99    -      -      -      -     0.01    -      -      -      -     and	r8d, 7
 -      -      -      -      -      -      -      -     1.00    -      -      -     mov	r9d, 8
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     sub	r9, r8
 -      -      -      -      -      -      -     0.99   0.01    -      -      -     test	r8, r8
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     cmove	r9, r8
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     lea	r8, [r11 + rcx]
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     add	rax, r9
 -      -      -      -      -      -      -     0.01   0.99    -      -      -     add	rax, 24
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     add	r9, rdx
 -      -      -      -     0.99   0.01   1.00    -      -      -      -      -     mov	qword ptr [rbp + 24], rax
 -      -      -      -     0.01    -     1.00    -      -     0.99    -      -     mov	qword ptr [r11 + rcx + 16], r9
 -      -      -      -      -     0.99   1.00    -      -     0.01    -      -     mov	byte ptr [r11 + rcx + 28], 2
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	rax, qword ptr [rbp]
 -      -      -      -     0.98   0.02    -      -      -      -      -      -     mov	rcx, qword ptr [rax + 288]
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	rdx, [rip + handmade_asset.LoadSoundWork]
 -      -      -      -      -      -      -      -      -      -      -      -     vzeroupper
 -      -      -     0.01   0.99   0.01   1.00   0.99   1.00   1.00    -      -     call	qword ptr [rip + handmade_data.PlatformAddEntry]
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     mov	r11b, 1
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     vmovsd	xmm1, qword ptr [rbx + 8]
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     vmovsd	xmm0, qword ptr [rbx + 16]
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm2, xmm7, xmm0
 -      -      -      -     0.02   0.98    -      -      -      -      -      -     vmovd	xmm0, dword ptr [rbx + 40]
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     mov	eax, dword ptr [rdi + 16]
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     vmovdqa	xmm3, xmm9
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpternlogd	xmm3, xmm0, xmm8, 248
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddss	xmm3, xmm0, xmm3
 -      -     2.00    -      -      -      -      -      -      -      -      -     vroundss	xmm3, xmm3, xmm3, 11
 -      -     0.02   1.98    -      -      -      -      -      -      -      -     vcvttss2usi	ecx, xmm3
 -      -      -      -      -      -      -     1.00    -      -      -      -     sub	eax, ecx
 -      -     1.00    -      -      -      -     1.00    -      -      -      -     vcvtusi2ss	xmm4, xmm17, eax
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     vmovss	xmm3, dword ptr [rbx + 32]
 -     3.00   1.00    -      -      -      -      -      -      -      -      -     vdivss	xmm4, xmm4, xmm3
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmovdqa	xmm5, xmm9
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpternlogd	xmm5, xmm4, xmm8, 248
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddss	xmm4, xmm4, xmm5
 -      -     2.00    -      -      -      -      -      -      -      -      -     vroundss	xmm4, xmm4, xmm4, 11
 -      -     0.02   1.98    -      -      -      -      -      -      -      -     vcvttss2usi	r8d, xmm4
 -      -      -      -      -      -      -      -     1.00    -      -      -     cmp	esi, r8d
 -      -      -      -      -      -      -      -     1.00    -      -      -     cmovb	r8d, esi
 -      -     1.00    -      -      -      -      -      -      -      -      -     vucomiss	xmm2, xmm10
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     jne	.LBB3_36
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     jnp	.LBB3_38
 -      -      -      -     0.02   0.98    -      -      -      -      -      -     vmovss	xmm4, dword ptr [rbx + 24]
 -      -      -     1.00    -      -      -      -      -      -      -      -     vsubss	xmm4, xmm4, xmm1
 -     3.00   1.00    -      -      -      -      -      -      -      -      -     vdivss	xmm4, xmm4, xmm2
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddss	xmm4, xmm11, xmm4
 -      -     2.00    -      -      -      -      -      -      -      -      -     vcvttss2usi	ecx, xmm4
 -      -      -      -      -      -      -     1.00    -      -      -      -     cmp	r8d, ecx
 -      -      -      -      -      -      -      -     2.00    -      -      -     seta	al
 -      -     1.00    -      -      -      -      -      -      -      -      -     cmovae	r8d, ecx
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovshdup	xmm4, xmm2
 -      -     1.00    -      -      -      -      -      -      -      -      -     vucomiss	xmm4, xmm10
 -      -     0.99    -      -      -      -      -     0.01    -      -      -     jne	.LBB3_37
 -      -     0.01    -      -      -      -      -     0.99    -      -      -     jnp	.LBB3_39
 -      -      -      -     0.02   0.98    -      -      -      -      -      -     vmovss	xmm5, dword ptr [rbx + 28]
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     vmovshdup	xmm16, xmm1
 -      -      -     1.00    -      -      -      -      -      -      -      -     vsubss	xmm5, xmm5, xmm16
 -     3.00   1.00    -      -      -      -      -      -      -      -      -     vdivss	xmm4, xmm5, xmm4
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddss	xmm4, xmm11, xmm4
 -      -      -     2.00    -      -      -      -      -      -      -      -     vcvttss2usi	ecx, xmm4
 -      -      -     1.00    -      -      -      -      -      -      -      -     cmp	r8d, ecx
 -      -      -      -      -      -      -      -     2.00    -      -      -     seta	dl
 -      -     1.00    -      -      -      -      -      -      -      -      -     cmovae	r8d, ecx
 -      -      -      -      -      -      -     1.00    -      -      -      -     mov	ecx, r8d
 -      -      -     1.00    -      -      -      -      -      -      -      -     test	r8d, r8d
 -      -      -      -      -      -      -      -     1.00    -      -      -     jne	.LBB3_40
 -      -      -      -      -      -      -      -     1.00    -      -      -     jmp	.LBB3_42
 -      -      -      -      -      -      -      -      -      -      -      -     xor	eax, eax
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmovshdup	xmm4, xmm2
 -      -     1.00    -      -      -      -      -      -      -      -      -     vucomiss	xmm4, xmm10
 -      -      -      -      -      -      -      -     1.00    -      -      -     jne	.LBB3_37
 -      -     1.00    -      -      -      -      -      -      -      -      -     jp	.LBB3_37
 -      -      -      -      -      -      -      -      -      -      -      -     xor	edx, edx
 -      -     1.00    -      -      -      -      -      -      -      -      -     mov	ecx, r8d
 -      -      -      -      -      -      -     1.00    -      -      -      -     test	r8d, r8d
 -      -     1.00    -      -      -      -      -      -      -      -      -     je	.LBB3_42
 -      -      -      -      -      -      -      -      -      -      -      -     xor	r8d, r8d
 -      -      -     2.00    -      -      -      -      -      -      -      -     vroundss	xmm4, xmm0, xmm0, 9
 -      -     1.98   0.02    -      -      -      -      -      -      -      -     vcvttss2si	r9d, xmm4
 -      -      -     1.00    -      -      -     1.00    -      -      -      -     vcvtusi2ss	xmm4, xmm17, r9d
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     mov	r10, qword ptr [rdi]
 -      -      -     1.00    -      -      -      -      -      -      -      -     vsubss	xmm4, xmm0, xmm4
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     vmovd	xmm5, dword ptr [r10 + 2*r9]
 -      -      -      -      -      -      -     1.00    -      -      -      -     vpmovsxwd	xmm5, xmm5
 -      -     0.99   0.01    -      -      -      -      -      -      -      -     vcvtdq2ps	xmm5, xmm5
 -      -     1.00    -      -      -      -      -      -      -      -      -     vsubss	xmm16, xmm6, xmm4
 -      -      -      -      -      -      -     1.00    -      -      -      -     vinsertps	xmm4, xmm16, xmm4, 16
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulps	xmm4, xmm4, xmm5
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     vmovshdup	xmm5, xmm4
 -      -      -     1.00   0.01   0.99    -      -      -      -      -      -     vmulss	xmm16, xmm1, dword ptr [r13 + 15202288]
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddss	xmm4, xmm4, xmm5
 -      -      -     1.00    -      -      -      -      -      -      -      -     vmulss	xmm5, xmm16, xmm4
 -      -     0.99   0.01   0.99   0.01    -      -      -      -      -      -     vaddss	xmm5, xmm5, dword ptr [r12 + 4*r8]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     vmovss	dword ptr [r12 + 4*r8], xmm5
 -      -      -      -      -      -      -     1.00    -      -      -      -     vmovshdup	xmm5, xmm1
 -      -      -     1.00   0.99   0.01    -      -      -      -      -      -     vmulss	xmm5, xmm5, dword ptr [r13 + 15202292]
 -      -     0.01   0.99    -      -      -      -      -      -      -      -     vmulss	xmm4, xmm5, xmm4
 -      -     0.99   0.01   0.01   0.99    -      -      -      -      -      -     vaddss	xmm4, xmm4, dword ptr [r15 + 4*r8]
 -      -      -      -     0.99   0.01   1.00    -      -      -      -      -     vmovss	dword ptr [r15 + 4*r8], xmm4
 -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	xmm1, xmm2, xmm1
 -      -     1.00    -      -      -      -      -      -      -      -      -     vaddss	xmm0, xmm3, xmm0
 -      -      -      -      -      -      -      -     1.00    -      -      -     add	r8, 1
 -      -      -      -      -      -      -     1.00    -      -      -      -     cmp	rcx, r8
 -      -      -      -      -      -      -      -     1.00    -      -      -     jne	.LBB3_41
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     vmovlps	qword ptr [rbx + 8], xmm1
 -      -      -     1.00    -      -      -      -      -      -      -      -     test	al, al
 -      -     1.00    -      -      -      -      -      -      -      -      -     je	.LBB3_43
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     vmovss	xmm1, dword ptr [rbx + 24]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     vmovss	dword ptr [rbx + 8], xmm1
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	dword ptr [rbx + 16], 0
 -      -      -      -      -      -      -     1.00    -      -      -      -     test	dl, dl
 -      -      -      -      -      -      -      -     1.00    -      -      -     jne	.LBB3_46
 -      -      -      -     0.99   0.01   1.00    -      -      -      -      -     vmovss	dword ptr [rbx + 40], xmm0
 -      -      -     2.00    -      -      -      -      -      -      -      -     vcvttss2usi	eax, xmm0
 -      -      -      -     0.01   0.99    -      -     1.00    -      -      -     cmp	dword ptr [rdi + 16], eax
 -      -     1.00    -      -      -      -      -      -      -      -      -     jne	.LBB3_21
 -      -     1.00    -      -      -      -      -      -      -      -      -     jmp	.LBB3_47
 -      -      -      -      -      -      -     1.00    -      -      -      -     test	dl, dl
 -      -     1.00    -      -      -      -      -      -      -      -      -     je	.LBB3_44
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     vmovss	xmm1, dword ptr [rbx + 28]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     vmovss	dword ptr [rbx + 12], xmm1
 -      -      -      -      -     1.00   1.00    -      -      -      -      -     mov	dword ptr [rbx + 20], 0
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     vmovss	dword ptr [rbx + 40], xmm0
 -      -      -     2.00    -      -      -      -      -      -      -      -     vcvttss2usi	eax, xmm0
 -      -      -      -     0.01   0.99    -     1.00    -      -      -      -     cmp	dword ptr [rdi + 16], eax
 -      -      -      -      -      -      -      -     1.00    -      -      -     jne	.LBB3_21
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     mov	eax, dword ptr [r14]
 -      -      -      -      -      -      -     1.00    -      -      -      -     test	eax, eax
 -      -      -      -      -      -      -      -     1.00    -      -      -     je	.LBB3_57
 -      -      -      -     0.99   0.01   1.00    -      -      -      -      -     mov	dword ptr [rbx + 36], eax
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	dword ptr [rbx + 40], 0
 -      -      -      -      -      -      -      -     1.00    -      -      -     jmp	.LBB3_21
 -      -      -     1.00    -      -      -      -      -      -      -      -     test	rax, rax
 -      -     1.00    -      -      -      -      -      -      -      -      -     je	.LBB3_20
 -      -      -      -      -      -      -      -      -      -      -      -     xor	eax, eax
 -      -      -     1.00   0.01   0.99   1.00    -     2.00   1.00    -      -     lock		cmpxchg	byte ptr [rcx + rdx + 8], r11b
 -      -      -      -     1.00    -      -      -      -      -      -      -     mov	rdi, qword ptr [rsp + 32]
 -      -      -      -      -      -      -      -     1.00    -      -      -     jne	.LBB3_59
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	rax, qword ptr [rbp]
 -      -      -      -     0.01   0.99    -     1.00    -      -      -      -     cmp	byte ptr [rax + 80], 1
 -      -     1.00    -      -      -      -      -      -      -      -      -     jne	.LBB3_62
 -      -      -     1.00   0.99   0.01    -      -      -      -      -      -     cmp	byte ptr [rax + 136], 1
 -      -      -      -      -      -      -      -     1.00    -      -      -     jne	.LBB3_63
 -      -      -      -     0.01   0.99    -     1.00    -      -      -      -     cmp	byte ptr [rax + 192], 1
 -      -     1.00    -      -      -      -      -      -      -      -      -     jne	.LBB3_64
 -      -      -     1.00   0.99   0.01    -      -      -      -      -      -     cmp	byte ptr [rax + 248], 0
 -      -      -      -      -      -      -      -     1.00    -      -      -     jne	.LBB3_60
 -      -      -      -      -      -      -     1.00    -      -      -      -     lea	rcx, [rax + 248]
 -      -      -      -      -      -      -     1.00    -      -      -      -     mov	edx, 3
 -      -     1.00    -      -      -      -      -      -      -      -      -     jmp	.LBB3_65
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	rax, qword ptr [rbx]
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     mov	rcx, qword ptr [rsp + 40]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rcx], rax
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     mov	rax, qword ptr [r13 + 15202280]
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [rbx], rax
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	qword ptr [r13 + 15202280], rbx
 -      -     1.00    -      -      -      -      -      -      -      -      -     mov	rbx, rcx
 -      -     1.00    -      -      -      -      -      -      -      -      -     jmp	.LBB3_20
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     mov	eax, dword ptr [rbx + 36]
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	rcx, qword ptr [rbp + 88]
 -      -     1.00    -      -      -      -      -      -      -      -      -     shl	rax, 4
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	byte ptr [rcx + rax + 8], 0
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	rax, qword ptr [rbx]
 -      -      -      -      -      -      -     1.00    -      -      -      -     test	rax, rax
 -      -      -      -      -      -      -      -     1.00    -      -      -     jne	.LBB3_61
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     mov	eax, dword ptr [rdi + 12]
 -      -      -      -      -      -      -      -     1.00    -      -      -     test	rax, rax
 -      -      -      -      -      -      -      -     1.00    -      -      -     je	.LBB3_86
 -      -      -      -     0.01   0.99    -      -      -      -      -      -     mov	rcx, qword ptr [rdi]
 -      -      -     1.00    -      -      -      -      -      -      -      -     cmp	eax, 8
 -      -     1.00    -      -      -      -      -      -      -      -      -     jae	.LBB3_70
 -      -      -      -      -      -      -      -      -      -      -      -     xor	edx, edx
 -      -      -      -      -      -      -      -     1.00    -      -      -     jmp	.LBB3_81
 -      -      -      -      -      -      -     1.00    -      -      -      -     lea	rdx, [rcx + 4*rax]
 -      -      -      -      -      -      -     1.00    -      -      -      -     lea	r8, [r12 + 4*rax]
 -      -      -     1.00    -      -      -      -      -      -      -      -     cmp	rcx, r8
 -      -     1.00    -      -      -      -      -      -      -      -      -     setb	r10b
 -      -      -     1.00    -      -      -      -      -      -      -      -     cmp	rdx, r12
 -      -      -      -      -      -      -      -     2.00    -      -      -     seta	r11b
 -      -      -     1.00    -      -      -      -      -      -      -      -     lea	r8, [r15 + 4*rax]
 -      -      -      -      -      -      -     1.00    -      -      -      -     cmp	rcx, r8
 -      -     1.00    -      -      -      -      -      -      -      -      -     setb	r8b
 -      -      -     1.00    -      -      -      -      -      -      -      -     cmp	rdx, r15
 -      -     2.00    -      -      -      -      -      -      -      -      -     seta	r9b
 -      -      -      -      -      -      -      -      -      -      -      -     xor	edx, edx
 -      -      -      -      -      -      -      -     1.00    -      -      -     test	r10b, r11b
 -      -     1.00    -      -      -      -      -      -      -      -      -     jne	.LBB3_81
 -      -      -      -      -      -      -      -     1.00    -      -      -     and	r8b, r9b
 -      -     1.00    -      -      -      -      -      -      -      -      -     jne	.LBB3_81
 -      -     1.00    -      -      -      -      -      -      -      -      -     cmp	eax, 16
 -      -      -      -      -      -      -      -     1.00    -      -      -     jae	.LBB3_77
 -      -      -      -      -      -      -      -      -      -      -      -     xor	edx, edx
 -      -      -      -      -      -      -     1.00    -      -      -      -     mov	r8, rdx
 -      -      -     1.00    -      -      -      -      -      -      -      -     mov	edx, eax
 -      -      -      -      -      -      -     1.00    -      -      -      -     and	edx, -8
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     vbroadcastss	ymm0, dword ptr [rip + .LCPI3_3]
 -      -      -     1.00   0.01   0.99    -      -      -      -      -      -     vaddps	ymm1, ymm0, ymmword ptr [r12 + 4*r8]
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvttps2dq	ymm1, ymm1
 -      -      -      -      -      -      -     2.00    -      -      -      -     vpmovdw	xmm1, ymm1
 -      -      -     1.00   0.99   0.01    -      -      -      -      -      -     vaddps	ymm2, ymm0, ymmword ptr [r15 + 4*r8]
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvttps2dq	ymm2, ymm2
 -      -      -      -      -      -      -     2.00    -      -      -      -     vpmovdw	xmm2, ymm2
 -      -      -     0.01    -      -      -     0.99    -      -      -      -     vpunpcklwd	xmm3, xmm1, xmm2
 -      -      -     0.99    -      -      -     0.01    -      -      -      -     vpunpckhwd	xmm1, xmm1, xmm2
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     vmovdqu	xmmword ptr [rcx + 4*r8 + 16], xmm1
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     vmovdqu	xmmword ptr [rcx + 4*r8], xmm3
 -      -      -      -      -      -      -     1.00    -      -      -      -     add	r8, 8
 -      -      -      -      -      -      -     1.00    -      -      -      -     cmp	rdx, r8
 -      -     1.00    -      -      -      -      -      -      -      -      -     jne	.LBB3_75
 -      -      -     1.00    -      -      -      -      -      -      -      -     cmp	rdx, rax
 -      -      -      -      -      -      -      -     1.00    -      -      -     jne	.LBB3_81
 -      -     1.00    -      -      -      -      -      -      -      -      -     jmp	.LBB3_86
 -      -      -      -      -      -      -     1.00    -      -      -      -     lea	r8, [4*rax]
 -      -      -     1.00    -      -      -      -      -      -      -      -     movabs	rdx, 17179868928
 -      -      -      -      -      -      -     1.00    -      -      -      -     or	rdx, 192
 -      -      -      -      -      -      -     1.00    -      -      -      -     and	rdx, r8
 -      -      -      -      -      -      -      -      -      -      -      -     xor	r8d, r8d
 -      -      -     1.00   0.01   0.99    -      -      -      -      -      -     vbroadcastss	zmm0, dword ptr [rip + .LCPI3_3]
 -      -      -     1.00   0.99   0.01    -      -      -      -      -      -     vmovdqa64	zmm1, zmmword ptr [rip + .LCPI3_4]
 -      -      -      -     0.01   0.99    -     1.00    -      -      -      -     vaddps	zmm2, zmm0, zmmword ptr [r12 + r8]
 -      -     1.00    -      -      -      -      -      -      -      -      -     vcvttps2dq	zmm2, zmm2
 -      -      -      -      -      -      -     2.00    -      -      -      -     vpmovdw	ymm2, zmm2
 -      -     1.00    -     0.01   0.99    -      -      -      -      -      -     vaddps	zmm3, zmm0, zmmword ptr [r15 + r8]
 -      -     0.01    -      -      -      -     0.99    -      -      -      -     vcvttps2dq	zmm3, zmm3
 -      -      -      -      -      -      -     2.00    -      -      -      -     vpmovdw	ymm3, zmm3
 -      -      -      -      -      -      -     1.00    -      -      -      -     vinserti64x4	zmm3, zmm3, ymm3, 1
 -      -      -      -      -      -      -     1.00    -      -      -      -     vinserti64x4	zmm2, zmm2, ymm2, 1
 -      -     0.99   0.01    -      -      -     2.00    -      -      -      -     vpermt2w	zmm2, zmm1, zmm3
 -      -      -      -      -     0.01   1.00    -      -     0.99    -      -     vmovdqu64	zmmword ptr [rcx + r8], zmm2
 -      -      -      -      -      -      -      -     1.00    -      -      -     add	r8, 64
 -      -      -      -      -      -      -     1.00    -      -      -      -     cmp	rdx, r8
 -      -     1.00    -      -      -      -      -      -      -      -      -     jne	.LBB3_78
 -      -      -     1.00    -      -      -      -      -      -      -      -     mov	edx, eax
 -      -      -      -      -      -      -      -     1.00    -      -      -     and	edx, -16
 -      -      -      -      -      -      -      -     1.00    -      -      -     cmp	rdx, rax
 -      -     1.00    -      -      -      -      -      -      -      -      -     je	.LBB3_86
 -      -      -     1.00    -      -      -      -      -      -      -      -     test	al, 8
 -      -      -      -      -      -      -      -     1.00    -      -      -     jne	.LBB3_74
 -      -      -      -      -      -      -     1.00    -      -      -      -     mov	r8, rdx
 -      -      -      -      -      -      -     1.00    -      -      -      -     not	r8
 -      -      -     1.00    -      -      -      -      -      -      -      -     test	al, 1
 -      -     1.00    -      -      -      -      -      -      -      -      -     je	.LBB3_83
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     vmovss	xmm0, dword ptr [rip + .LCPI3_3]
 -      -      -     1.00   0.01   0.99    -      -      -      -      -      -     vaddss	xmm1, xmm0, dword ptr [r12 + 4*rdx]
 -      -     1.98   0.02    -      -      -      -      -      -      -      -     vcvttss2si	r9d, xmm1
 -      -      -      -     0.01    -     1.00    -      -     0.99    -      -     mov	word ptr [rcx + 4*rdx], r9w
 -      -      -     1.00   0.99   0.01    -      -      -      -      -      -     vaddss	xmm0, xmm0, dword ptr [r15 + 4*rdx]
 -      -     0.02   1.98    -      -      -      -      -      -      -      -     vcvttss2si	r9d, xmm0
 -      -      -      -      -      -     1.00    -      -     1.00    -      -     mov	word ptr [rcx + 4*rdx + 2], r9w
 -      -      -      -      -      -      -      -     1.00    -      -      -     or	rdx, 1
 -      -      -      -      -      -      -     1.00    -      -      -      -     add	r8, rax
 -      -      -      -      -      -      -      -     1.00    -      -      -     je	.LBB3_86
 -      -      -      -      -      -      -      -     1.00    -      -      -     add	r15, 4
 -      -      -      -     0.99   0.01    -      -      -      -      -      -     vmovss	xmm0, dword ptr [rip + .LCPI3_3]
 -      -      -     1.00   0.01   0.99    -      -      -      -      -      -     vaddss	xmm1, xmm0, dword ptr [r12 + 4*rdx]
 -      -     2.00    -      -      -      -      -      -      -      -      -     vcvttss2si	r8d, xmm1
 -      -      -      -      -     1.00   1.00    -      -      -      -      -     mov	word ptr [rcx + 4*rdx], r8w
 -      -      -     1.00   0.99   0.01    -      -      -      -      -      -     vaddss	xmm1, xmm0, dword ptr [r15 + 4*rdx - 4]
 -      -     1.98   0.02    -      -      -      -      -      -      -      -     vcvttss2si	r8d, xmm1
 -      -      -      -     0.01    -     1.00    -      -     0.99    -      -     mov	word ptr [rcx + 4*rdx + 2], r8w
 -      -     1.00    -     0.01   0.99    -      -      -      -      -      -     vaddss	xmm1, xmm0, dword ptr [r12 + 4*rdx + 4]
 -      -     0.02   1.98    -      -      -      -      -      -      -      -     vcvttss2si	r8d, xmm1
 -      -      -      -      -     0.99   1.00    -      -     0.01    -      -     mov	word ptr [rcx + 4*rdx + 4], r8w
 -      -      -     1.00   0.99   0.01    -      -      -      -      -      -     vaddss	xmm1, xmm0, dword ptr [r15 + 4*rdx]
 -      -     1.98   0.02    -      -      -      -      -      -      -      -     vcvttss2si	r8d, xmm1
 -      -      -      -     0.99   0.01   1.00    -      -      -      -      -     mov	word ptr [rcx + 4*rdx + 6], r8w
 -      -      -      -      -      -      -     1.00    -      -      -      -     add	rdx, 2
 -      -      -      -      -      -      -     1.00    -      -      -      -     cmp	rax, rdx
 -      -      -      -      -      -      -      -     1.00    -      -      -     jne	.LBB3_85


```
</details>

<details><summary>Timeline view:</summary>

```
                    0123456789          0123456789          0123456789          0123456789
Index     0123456789          0123456789          0123456789          0123456789          

[0,0]     DeeeeeER  .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   mov	ecx, dword ptr [rdx + 12]
[0,1]     DeeeeeER  .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   mov	rax, qword ptr [r10 + 8]
[0,2]     D=eeeeeER .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   mov	rdx, qword ptr [r10 + 16]
[0,3]     D======eER.    .    .    .    .    .    .    .    .    .    .    .    .    .   .   lea	r8, [rdx + rax]
[0,4]     D=======eER    .    .    .    .    .    .    .    .    .    .    .    .    .   .   mov	r9d, r8d
[0,5]     D========eER   .    .    .    .    .    .    .    .    .    .    .    .    .   .   and	r9d, 3
[0,6]     .DeE-------R   .    .    .    .    .    .    .    .    .    .    .    .    .   .   mov	r15d, 4
[0,7]     .DeE-------R   .    .    .    .    .    .    .    .    .    .    .    .    .   .   mov	r12d, 4
[0,8]     .D========eER  .    .    .    .    .    .    .    .    .    .    .    .    .   .   sub	r12, r9
[0,9]     .D========eER  .    .    .    .    .    .    .    .    .    .    .    .    .   .   test	r9, r9
[0,10]    .D=========eER .    .    .    .    .    .    .    .    .    .    .    .    .   .   cmove	r12, r9
[0,11]    .D=====eE----R .    .    .    .    .    .    .    .    .    .    .    .    .   .   lea	rcx, [rdx + 4*rcx]
[0,12]    . D=========eER.    .    .    .    .    .    .    .    .    .    .    .    .   .   add	rcx, r12
[0,13]    . D=========eER.    .    .    .    .    .    .    .    .    .    .    .    .   .   add	r12, r8
[0,14]    . D==========eER    .    .    .    .    .    .    .    .    .    .    .    .   .   mov	qword ptr [r10 + 16], rcx
[0,15]    . DeeeeeE------R    .    .    .    .    .    .    .    .    .    .    .    .   .   mov	edx, dword ptr [rdi + 12]
[0,16]    . D==========eER    .    .    .    .    .    .    .    .    .    .    .    .   .   add	rax, rcx
[0,17]    . D===========eER   .    .    .    .    .    .    .    .    .    .    .    .   .   mov	r8d, eax
[0,18]    .  D===========eER  .    .    .    .    .    .    .    .    .    .    .    .   .   and	r8d, 3
[0,19]    .  D============eER .    .    .    .    .    .    .    .    .    .    .    .   .   sub	r15, r8
[0,20]    .  D============eER .    .    .    .    .    .    .    .    .    .    .    .   .   test	r8, r8
[0,21]    .  D=============eER.    .    .    .    .    .    .    .    .    .    .    .   .   cmove	r15, r8
[0,22]    .  D=========eE----R.    .    .    .    .    .    .    .    .    .    .    .   .   lea	rcx, [rcx + 4*rdx]
[0,23]    .  D==============eER    .    .    .    .    .    .    .    .    .    .    .   .   add	rcx, r15
[0,24]    .   D=========eE----R    .    .    .    .    .    .    .    .    .    .    .   .   mov	qword ptr [rsp + 56], r10
[0,25]    .   D==============eER   .    .    .    .    .    .    .    .    .    .    .   .   mov	qword ptr [r10 + 16], rcx
[0,26]    .   DeeeeeeeeeE------R   .    .    .    .    .    .    .    .    .    .    .   .   vcvtusi2ss	xmm0, xmm0, dword ptr [rdi + 8]
[0,27]    .   D=============eE-R   .    .    .    .    .    .    .    .    .    .    .   .   add	r15, rax
[0,28]    .   DeeeeeE----------R   .    .    .    .    .    .    .    .    .    .    .   .   mov	eax, dword ptr [rdi + 12]
[0,29]    .    D====eE---------R   .    .    .    .    .    .    .    .    .    .    .   .   test	rax, rax
[0,30]    .    D=====eE--------R   .    .    .    .    .    .    .    .    .    .    .   .   je	.LBB3_17
[0,31]    .    D---------------R   .    .    .    .    .    .    .    .    .    .    .   .   xor	ecx, ecx
[0,32]    .    D====eE---------R   .    .    .    .    .    .    .    .    .    .    .   .   cmp	eax, 8
[0,33]    .    D======eE-------R   .    .    .    .    .    .    .    .    .    .    .   .   jb	.LBB3_12
[0,34]    .    D=============eER   .    .    .    .    .    .    .    .    .    .    .   .   mov	rdx, r15
[0,35]    .    .D=============eER  .    .    .    .    .    .    .    .    .    .    .   .   sub	rdx, r12
[0,36]    .    .D==============eER .    .    .    .    .    .    .    .    .    .    .   .   cmp	rdx, 256
[0,37]    .    .D===============eER.    .    .    .    .    .    .    .    .    .    .   .   jb	.LBB3_12
[0,38]    .    .D====eE-----------R.    .    .    .    .    .    .    .    .    .    .   .   cmp	eax, 64
[0,39]    .    .D======eE---------R.    .    .    .    .    .    .    .    .    .    .   .   jae	.LBB3_5
[0,40]    .    .D-----------------R.    .    .    .    .    .    .    .    .    .    .   .   xor	ecx, ecx
[0,41]    .    . DeE--------------R.    .    .    .    .    .    .    .    .    .    .   .   jmp	.LBB3_9
[0,42]    .    . D===eE-----------R.    .    .    .    .    .    .    .    .    .    .   .   lea	rcx, [4*rax]
[0,43]    .    . D====eE----------R.    .    .    .    .    .    .    .    .    .    .   .   and	rcx, -256
[0,44]    .    . D----------------R.    .    .    .    .    .    .    .    .    .    .   .   xor	edx, edx
[0,45]    .    . D----------------R.    .    .    .    .    .    .    .    .    .    .   .   vxorps	xmm1, xmm1, xmm1
[0,46]    .    .  D===========eE--R.    .    .    .    .    .    .    .    .    .    .   .   vmovups	zmmword ptr [r12 + rdx + 192], zmm1
[0,47]    .    .  D============eE-R.    .    .    .    .    .    .    .    .    .    .   .   vmovups	zmmword ptr [r12 + rdx + 128], zmm1
[0,48]    .    .  D=============eER.    .    .    .    .    .    .    .    .    .    .   .   vmovups	zmmword ptr [r12 + rdx + 64], zmm1
[0,49]    .    .   D=============eER    .    .    .    .    .    .    .    .    .    .   .   vmovups	zmmword ptr [r12 + rdx], zmm1
[0,50]    .    .   D==============eER   .    .    .    .    .    .    .    .    .    .   .   vmovups	zmmword ptr [r15 + rdx + 192], zmm1
[0,51]    .    .   D===============eER  .    .    .    .    .    .    .    .    .    .   .   vmovups	zmmword ptr [r15 + rdx + 128], zmm1
[0,52]    .    .    D===============eER .    .    .    .    .    .    .    .    .    .   .   vmovups	zmmword ptr [r15 + rdx + 64], zmm1
[0,53]    .    .    D================eER.    .    .    .    .    .    .    .    .    .   .   vmovups	zmmword ptr [r15 + rdx], zmm1
[0,54]    .    .    D==eE--------------R.    .    .    .    .    .    .    .    .    .   .   lea	r8, [rdx + 256]
[0,55]    .    .    D===eE-------------R.    .    .    .    .    .    .    .    .    .   .   mov	rdx, r8
[0,56]    .    .    .D==eE-------------R.    .    .    .    .    .    .    .    .    .   .   cmp	rcx, r8
[0,57]    .    .    .D===eE------------R.    .    .    .    .    .    .    .    .    .   .   jne	.LBB3_6
[0,58]    .    .    .D==eE-------------R.    .    .    .    .    .    .    .    .    .   .   mov	ecx, eax
[0,59]    .    .    .D===eE------------R.    .    .    .    .    .    .    .    .    .   .   and	ecx, -64
[0,60]    .    .    .D====eE-----------R.    .    .    .    .    .    .    .    .    .   .   cmp	rcx, rax
[0,61]    .    .    .D=====eE----------R.    .    .    .    .    .    .    .    .    .   .   je	.LBB3_17
[0,62]    .    .    . D==eE------------R.    .    .    .    .    .    .    .    .    .   .   test	al, 56
[0,63]    .    .    . D=====eE---------R.    .    .    .    .    .    .    .    .    .   .   je	.LBB3_12
[0,64]    .    .    . D===eE-----------R.    .    .    .    .    .    .    .    .    .   .   mov	rdx, rcx
[0,65]    .    .    . D====eE----------R.    .    .    .    .    .    .    .    .    .   .   mov	ecx, eax
[0,66]    .    .    . D=====eE---------R.    .    .    .    .    .    .    .    .    .   .   and	ecx, -8
[0,67]    .    .    . D----------------R.    .    .    .    .    .    .    .    .    .   .   vxorps	xmm1, xmm1, xmm1
[0,68]    .    .    .  D==============eER    .    .    .    .    .    .    .    .    .   .   vmovups	ymmword ptr [r12 + 4*rdx], ymm1
[0,69]    .    .    .  D===============eER   .    .    .    .    .    .    .    .    .   .   vmovups	ymmword ptr [r15 + 4*rdx], ymm1
[0,70]    .    .    .  D===eE------------R   .    .    .    .    .    .    .    .    .   .   add	rdx, 8
[0,71]    .    .    .  D=====eE----------R   .    .    .    .    .    .    .    .    .   .   cmp	rcx, rdx
[0,72]    .    .    .   D=====eE---------R   .    .    .    .    .    .    .    .    .   .   jne	.LBB3_10
[0,73]    .    .    .   D====eE----------R   .    .    .    .    .    .    .    .    .   .   cmp	rcx, rax
[0,74]    .    .    .   D======eE--------R   .    .    .    .    .    .    .    .    .   .   je	.LBB3_17
[0,75]    .    .    .   D====eE----------R   .    .    .    .    .    .    .    .    .   .   mov	rdx, rcx
[0,76]    .    .    .   D=====eE---------R   .    .    .    .    .    .    .    .    .   .   not	rdx
[0,77]    .    .    .   D======eE--------R   .    .    .    .    .    .    .    .    .   .   add	rdx, rax
[0,78]    .    .    .    D=====eE--------R   .    .    .    .    .    .    .    .    .   .   mov	r8, rax
[0,79]    .    .    .    D======eE-------R   .    .    .    .    .    .    .    .    .   .   and	r8, 3
[0,80]    .    .    .    D=======eE------R   .    .    .    .    .    .    .    .    .   .   je	.LBB3_14
[0,81]    .    .    .    D==============eER  .    .    .    .    .    .    .    .    .   .   mov	dword ptr [r12 + 4*rcx], 0
[0,82]    .    .    .    D===============eER .    .    .    .    .    .    .    .    .   .   mov	dword ptr [r15 + 4*rcx], 0
[0,83]    .    .    .    D====eE-----------R .    .    .    .    .    .    .    .    .   .   add	rcx, 1
[0,84]    .    .    .    .D======eE--------R .    .    .    .    .    .    .    .    .   .   add	r8, -1
[0,85]    .    .    .    .D=======eE-------R .    .    .    .    .    .    .    .    .   .   jne	.LBB3_13
[0,86]    .    .    .    .D=====eE---------R .    .    .    .    .    .    .    .    .   .   cmp	rdx, 3
[0,87]    .    .    .    .D======eE--------R .    .    .    .    .    .    .    .    .   .   jb	.LBB3_17
[0,88]    .    .    .    .D=====eE---------R .    .    .    .    .    .    .    .    .   .   lea	rdx, [r15 + 12]
[0,89]    .    .    .    .D======eE--------R .    .    .    .    .    .    .    .    .   .   lea	r8, [r12 + 12]
[0,90]    .    .    .    . D==============eER.    .    .    .    .    .    .    .    .   .   mov	dword ptr [r8 + 4*rcx - 12], 0
[0,91]    .    .    .    . D===============eER    .    .    .    .    .    .    .    .   .   mov	dword ptr [rdx + 4*rcx - 12], 0
[0,92]    .    .    .    . D================eER   .    .    .    .    .    .    .    .   .   mov	dword ptr [r8 + 4*rcx - 8], 0
[0,93]    .    .    .    . D=================eER  .    .    .    .    .    .    .    .   .   mov	dword ptr [rdx + 4*rcx - 8], 0
[0,94]    .    .    .    . D==================eER .    .    .    .    .    .    .    .   .   mov	dword ptr [r8 + 4*rcx - 4], 0
[0,95]    .    .    .    . D===================eER.    .    .    .    .    .    .    .   .   mov	dword ptr [rdx + 4*rcx - 4], 0
[0,96]    .    .    .    .  D===================eER    .    .    .    .    .    .    .   .   mov	dword ptr [r8 + 4*rcx], 0
[0,97]    .    .    .    .  D====================eER   .    .    .    .    .    .    .   .   mov	dword ptr [rdx + 4*rcx], 0
[0,98]    .    .    .    .  D=====eE---------------R   .    .    .    .    .    .    .   .   add	rcx, 4
[0,99]    .    .    .    .  D======eE--------------R   .    .    .    .    .    .    .   .   cmp	rax, rcx
[0,100]   .    .    .    .  D=======eE-------------R   .    .    .    .    .    .    .   .   jne	.LBB3_16
[0,101]   .    .    .    .  DeeeeeE----------------R   .    .    .    .    .    .    .   .   mov	rax, qword ptr [r13 + 15202272]
[0,102]   .    .    .    .   D====eE---------------R   .    .    .    .    .    .    .   .   test	rax, rax
[0,103]   .    .    .    .   D=====eE--------------R   .    .    .    .    .    .    .   .   je	.LBB3_67
[0,104]   .    .    .    .   DeeeeeE---------------R   .    .    .    .    .    .    .   .   mov	esi, dword ptr [rdi + 12]
[0,105]   .    .    .    .   D=====eE--------------R   .    .    .    .    .    .    .   .   test	esi, esi
[0,106]   .    .    .    .   D======eE-------------R   .    .    .    .    .    .    .   .   je	.LBB3_66
[0,107]   .    .    .    .   D====================eER  .    .    .    .    .    .    .   .   mov	qword ptr [rsp + 32], rdi
[0,108]   .    .    .    .    DeeeeeE---------------R  .    .    .    .    .    .    .   .   vmovss	xmm6, dword ptr [rip + .LCPI3_0]
[0,109]   .    .    .    .    D======eeeeeeeeeeeE---R  .    .    .    .    .    .    .   .   vdivss	xmm0, xmm6, xmm0
[0,110]   .    .    .    .    D====eE---------------R  .    .    .    .    .    .    .   .   lea	rcx, [r13 + 15202272]
[0,111]   .    .    .    .    D====================eER .    .    .    .    .    .    .   .   mov	qword ptr [rsp + 40], rcx
[0,112]   .    .    .    .    D=================eE---R .    .    .    .    .    .    .   .   vbroadcastss	xmm7, xmm0
[0,113]   .    .    .    .    D===eE-----------------R .    .    .    .    .    .    .   .   mov	r11b, 1
[0,114]   .    .    .    .    .DeeeeeeE--------------R .    .    .    .    .    .    .   .   vpbroadcastd	xmm8, dword ptr [rip + .LCPI3_1]
[0,115]   .    .    .    .    .DeeeeeeE--------------R .    .    .    .    .    .    .   .   vpbroadcastd	xmm9, dword ptr [rip + .LCPI3_2]
[0,116]   .    .    .    .    .D---------------------R .    .    .    .    .    .    .   .   vxorps	xmm10, xmm10, xmm10
[0,117]   .    .    .    .    .D=eeeeeE--------------R .    .    .    .    .    .    .   .   vmovss	xmm11, dword ptr [rip + .LCPI3_3]
[0,118]   .    .    .    .    .D====eE---------------R .    .    .    .    .    .    .   .   mov	rbx, rax
[0,119]   .    .    .    .    .D====eE---------------R .    .    .    .    .    .    .   .   test	esi, esi
[0,120]   .    .    .    .    . D====eE--------------R .    .    .    .    .    .    .   .   jne	.LBB3_22
[0,121]   .    .    .    .    . D=====eE-------------R .    .    .    .    .    .    .   .   jmp	.LBB3_20
[0,122]   .    .    .    .    . D=eeeeeE-------------R .    .    .    .    .    .    .   .   mov	rax, qword ptr [rax]
[0,123]   .    .    .    .    . D======eE------------R .    .    .    .    .    .    .   .   test	rax, rax
[0,124]   .    .    .    .    . D=======eE-----------R .    .    .    .    .    .    .   .   jne	.LBB3_66
[0,125]   .    .    .    .    . D=====eE-------------R .    .    .    .    .    .    .   .   jmp	.LBB3_67
[0,126]   .    .    .    .    .  D=====eE------------R .    .    .    .    .    .    .   .   lea	rcx, [rax + 80]
[0,127]   .    .    .    .    .  D-------------------R .    .    .    .    .    .    .   .   xor	edx, edx
[0,128]   .    .    .    .    .  D=====eE------------R .    .    .    .    .    .    .   .   jmp	.LBB3_65
[0,129]   .    .    .    .    .  D=====eE------------R .    .    .    .    .    .    .   .   lea	rcx, [rax + 136]
[0,130]   .    .    .    .    .  D===eE--------------R .    .    .    .    .    .    .   .   mov	edx, 1
[0,131]   .    .    .    .    .  D======eE-----------R .    .    .    .    .    .    .   .   jmp	.LBB3_65
[0,132]   .    .    .    .    .   D=====eE-----------R .    .    .    .    .    .    .   .   lea	rcx, [rax + 192]
[0,133]   .    .    .    .    .   D==eE--------------R .    .    .    .    .    .    .   .   mov	edx, 2
[0,134]   .    .    .    .    .   D===eeeE-----------R .    .    .    .    .    .    .   .   imul	rdx, rdx, 56
[0,135]   .    .    .    .    .   D=================eER.    .    .    .    .    .    .   .   mov	byte ptr [rcx], 1
[0,136]   .    .    .    .    .   D======eeeeeE-------R.    .    .    .    .    .    .   .   mov	r8, qword ptr [rax + rdx + 48]
[0,137]   .    .    .    .    .    D=================eeeeeeeER   .    .    .    .    .   .   add	dword ptr [rax + rdx + 56], 1
[0,138]   .    .    .    .    .    D=====eE------------------R   .    .    .    .    .   .   lea	r9, [rax + rdx]
[0,139]   .    .    .    .    .    D======eE-----------------R   .    .    .    .    .   .   add	r9, 32
[0,140]   .    .    .    .    .    D==================eE-----R   .    .    .    .    .   .   mov	qword ptr [rax + rdx + 64], r9
[0,141]   .    .    .    .    .    .D==================eE----R   .    .    .    .    .   .   mov	qword ptr [rax + rdx + 72], r8
[0,142]   .    .    .    .    .    .D=====eeeeeE-------------R   .    .    .    .    .   .   mov	rcx, qword ptr [rax + rdx + 40]
[0,143]   .    .    .    .    .    .D==========eE------------R   .    .    .    .    .   .   add	rcx, r8
[0,144]   .    .    .    .    .    .D===========eE-----------R   .    .    .    .    .   .   mov	r10d, ecx
[0,145]   .    .    .    .    .    .D============eE----------R   .    .    .    .    .   .   and	r10d, 7
[0,146]   .    .    .    .    .    .D=eE---------------------R   .    .    .    .    .   .   mov	r11d, 8
[0,147]   .    .    .    .    .    . D============eE---------R   .    .    .    .    .   .   sub	r11, r10
[0,148]   .    .    .    .    .    . D============eE---------R   .    .    .    .    .   .   test	r10, r10
[0,149]   .    .    .    .    .    . D=============eE--------R   .    .    .    .    .   .   cmove	r11, r10
[0,150]   .    .    .    .    .    . D==============eE-------R   .    .    .    .    .   .   lea	r8, [r8 + r11 + 32]
[0,151]   .    .    .    .    .    . D==================eE---R   .    .    .    .    .   .   mov	qword ptr [rax + rdx + 48], r8
[0,152]   .    .    .    .    .    . D===================eE--R   .    .    .    .    .   .   mov	qword ptr [r11 + rcx], rbp
[0,153]   .    .    .    .    .    .  DeeeeeE----------------R   .    .    .    .    .   .   mov	eax, dword ptr [rbx + 36]
[0,154]   .    .    .    .    .    .  D===================eE-R   .    .    .    .    .   .   mov	dword ptr [r11 + rcx + 24], eax
[0,155]   .    .    .    .    .    .  D====================eER   .    .    .    .    .   .   mov	qword ptr [r11 + rcx + 8], r9
[0,156]   .    .    .    .    .    .  DeeeeeE----------------R   .    .    .    .    .   .   mov	rax, qword ptr [rbp + 24]
[0,157]   .    .    .    .    .    .  D=eeeeeE---------------R   .    .    .    .    .   .   mov	rdx, qword ptr [rbp + 16]
[0,158]   .    .    .    .    .    .  D======eE--------------R   .    .    .    .    .   .   add	rdx, rax
[0,159]   .    .    .    .    .    .   D======eE-------------R   .    .    .    .    .   .   mov	r8d, edx
[0,160]   .    .    .    .    .    .   D=======eE------------R   .    .    .    .    .   .   and	r8d, 7
[0,161]   .    .    .    .    .    .   DeE-------------------R   .    .    .    .    .   .   mov	r9d, 8
[0,162]   .    .    .    .    .    .   D========eE-----------R   .    .    .    .    .   .   sub	r9, r8
[0,163]   .    .    .    .    .    .   D========eE-----------R   .    .    .    .    .   .   test	r8, r8
[0,164]   .    .    .    .    .    .   D=========eE----------R   .    .    .    .    .   .   cmove	r9, r8
[0,165]   .    .    .    .    .    .    D===========eE-------R   .    .    .    .    .   .   lea	r8, [r11 + rcx]
[0,166]   .    .    .    .    .    .    D=========eE---------R   .    .    .    .    .   .   add	rax, r9
[0,167]   .    .    .    .    .    .    D==========eE--------R   .    .    .    .    .   .   add	rax, 24
[0,168]   .    .    .    .    .    .    D=========eE---------R   .    .    .    .    .   .   add	r9, rdx
[0,169]   .    .    .    .    .    .    D===================eER  .    .    .    .    .   .   mov	qword ptr [rbp + 24], rax
[0,170]   .    .    .    .    .    .    D====================eER .    .    .    .    .   .   mov	qword ptr [r11 + rcx + 16], r9
[0,171]   .    .    .    .    .    .    .D====================eER.    .    .    .    .   .   mov	byte ptr [r11 + rcx + 28], 2
[0,172]   .    .    .    .    .    .    .DeeeeeE----------------R.    .    .    .    .   .   mov	rax, qword ptr [rbp]
[0,173]   .    .    .    .    .    .    .D=====eeeeeE-----------R.    .    .    .    .   .   mov	rcx, qword ptr [rax + 288]
[0,174]   .    .    .    .    .    .    .DeE--------------------R.    .    .    .    .   .   lea	rdx, [rip + handmade_asset.LoadSoundWork]
[0,175]   .    .    .    .    .    .    . D---------------------R.    .    .    .    .   .   vzeroupper
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
0.     10    1.9    1.0    22.5      mov	ecx, dword ptr [rdx + 12]
1.     10    1.9    1.9    22.5      mov	rax, qword ptr [r10 + 8]
2.     10    2.9    2.9    21.6      mov	rdx, qword ptr [r10 + 16]
3.     10    11.5   3.6    17.1      lea	r8, [rdx + rax]
4.     10    12.5   0.0    16.2      mov	r9d, r8d
5.     10    13.5   0.0    15.3      and	r9d, 3
6.     10    1.0    1.0    26.8      mov	r15d, 4
7.     10    1.0    1.0    26.8      mov	r12d, 4
8.     10    13.5   0.0    14.4      sub	r12, r9
9.     10    13.5   0.0    14.4      test	r9, r9
10.    10    14.5   0.0    13.5      cmove	r12, r9
11.    10    12.3   5.4    15.7      lea	rcx, [rdx + 4*rcx]
12.    10    14.5   0.0    12.6      add	rcx, r12
13.    10    14.5   0.0    12.6      add	r12, r8
14.    10    28.1   0.9    0.0       mov	qword ptr [r10 + 16], rcx
15.    10    1.0    1.0    23.1      mov	edx, dword ptr [rdi + 12]
16.    10    15.5   0.0    12.6      add	rax, rcx
17.    10    16.5   0.0    11.7      mov	r8d, eax
18.    10    16.5   0.0    10.8      and	r8d, 3
19.    10    17.5   0.0    9.9       sub	r15, r8
20.    10    17.5   0.0    9.9       test	r8, r8
21.    10    18.5   0.0    9.0       cmove	r15, r8
22.    10    16.3   1.8    11.2      lea	rcx, [rcx + 4*rdx]
23.    10    19.5   0.0    8.1       add	rcx, r15
24.    10    27.1   1.0    0.4       mov	qword ptr [rsp + 56], r10
25.    10    28.5   0.9    0.0       mov	qword ptr [r10 + 16], rcx
26.    10    1.0    1.0    19.5      vcvtusi2ss	xmm0, xmm0, dword ptr [rdi + 8]
27.    10    18.5   0.0    10.0      add	r15, rax
28.    10    1.0    1.0    23.5      mov	eax, dword ptr [rdi + 12]
29.    10    5.0    0.0    22.5      test	rax, rax
30.    10    6.0    0.0    21.5      je	.LBB3_17
31.    10    0.0    0.0    28.5      xor	ecx, ecx
32.    10    6.8    1.8    20.7      cmp	eax, 8
33.    10    7.9    0.1    19.6      jb	.LBB3_12
34.    10    18.5   0.0    9.0       mov	rdx, r15
35.    10    18.5   0.0    8.1       sub	rdx, r12
36.    10    19.5   0.0    7.2       cmp	rdx, 256
37.    10    20.5   0.0    6.3       jb	.LBB3_12
38.    10    7.7    3.7    19.1      cmp	eax, 64
39.    10    8.8    0.1    18.0      jae	.LBB3_5
40.    10    0.0    0.0    27.8      xor	ecx, ecx
41.    10    1.0    1.0    24.8      jmp	.LBB3_9
42.    10    8.5    5.5    17.3      lea	rcx, [4*rax]
43.    10    9.5    0.0    16.3      and	rcx, -256
44.    10    0.0    0.0    26.8      xor	edx, edx
45.    10    0.0    0.0    26.8      vxorps	xmm1, xmm1, xmm1
46.    10    25.5   1.0    0.2       vmovups	zmmword ptr [r12 + rdx + 192], zmm1
47.    10    26.5   1.0    0.1       vmovups	zmmword ptr [r12 + rdx + 128], zmm1
48.    10    27.5   1.0    0.0       vmovups	zmmword ptr [r12 + rdx + 64], zmm1
49.    10    27.5   1.0    0.0       vmovups	zmmword ptr [r12 + rdx], zmm1
50.    10    28.5   1.0    0.0       vmovups	zmmword ptr [r15 + rdx + 192], zmm1
51.    10    29.5   1.0    0.0       vmovups	zmmword ptr [r15 + rdx + 128], zmm1
52.    10    29.5   1.0    0.0       vmovups	zmmword ptr [r15 + rdx + 64], zmm1
53.    10    30.5   1.0    0.0       vmovups	zmmword ptr [r15 + rdx], zmm1
54.    10    5.7    5.7    24.8      lea	r8, [rdx + 256]
55.    10    6.7    0.0    23.8      mov	rdx, r8
56.    10    6.6    0.0    22.9      cmp	rcx, r8
57.    10    7.6    0.0    21.9      jne	.LBB3_6
58.    10    3.0    3.0    26.5      mov	ecx, eax
59.    10    4.9    0.9    24.6      and	ecx, -64
60.    10    7.7    1.8    21.8      cmp	rcx, rax
61.    10    8.7    0.0    20.8      je	.LBB3_17
62.    10    7.5    7.5    21.0      test	al, 56
63.    10    8.7    0.2    19.8      je	.LBB3_12
64.    10    8.5    3.6    20.0      mov	rdx, rcx
65.    10    9.5    9.5    19.0      mov	ecx, eax
66.    10    10.5   0.0    18.0      and	ecx, -8
67.    10    0.0    0.0    29.5      vxorps	xmm1, xmm1, xmm1
68.    10    28.5   1.0    0.0       vmovups	ymmword ptr [r12 + 4*rdx], ymm1
69.    10    29.5   1.0    0.0       vmovups	ymmword ptr [r15 + 4*rdx], ymm1
70.    10    8.5    0.0    21.0      add	rdx, 8
71.    10    9.6    0.0    19.0      cmp	rcx, rdx
72.    10    10.5   0.0    18.0      jne	.LBB3_10
73.    10    9.5    0.0    19.0      cmp	rcx, rax
74.    10    10.6   0.1    17.9      je	.LBB3_17
75.    10    8.6    0.0    19.0      mov	rdx, rcx
76.    10    10.5   0.9    17.1      not	rdx
77.    10    11.5   0.0    16.1      add	rdx, rax
78.    10    6.9    6.9    20.6      mov	r8, rax
79.    10    7.0    0.0    19.6      and	r8, 3
80.    10    9.8    1.8    16.8      je	.LBB3_14
81.    10    27.6   1.0    0.0       mov	dword ptr [r12 + 4*rcx], 0
82.    10    28.6   1.0    0.0       mov	dword ptr [r15 + 4*rcx], 0
83.    10    7.7    1.0    20.0      add	rcx, 1
84.    10    8.8    1.8    18.8      add	r8, -1
85.    10    9.8    0.0    17.8      jne	.LBB3_13
86.    10    10.5   0.0    17.1      cmp	rdx, 3
87.    10    10.6   0.0    16.1      jb	.LBB3_17
88.    10    8.7    3.0    18.0      lea	rdx, [r15 + 12]
89.    10    9.7    9.7    17.0      lea	r8, [r12 + 12]
90.    10    26.7   1.0    0.0       mov	dword ptr [r8 + 4*rcx - 12], 0
91.    10    27.7   1.0    0.0       mov	dword ptr [rdx + 4*rcx - 12], 0
92.    10    28.7   1.0    0.0       mov	dword ptr [r8 + 4*rcx - 8], 0
93.    10    28.8   1.0    0.0       mov	dword ptr [rdx + 4*rcx - 8], 0
94.    10    29.8   1.0    0.0       mov	dword ptr [r8 + 4*rcx - 4], 0
95.    10    30.8   1.0    0.0       mov	dword ptr [rdx + 4*rcx - 4], 0
96.    10    31.7   1.0    0.0       mov	dword ptr [r8 + 4*rcx], 0
97.    10    31.8   1.0    0.0       mov	dword ptr [rdx + 4*rcx], 0
98.    10    6.9    2.1    24.9      add	rcx, 4
99.    10    7.9    0.0    23.9      cmp	rax, rcx
100.   10    8.9    0.0    22.9      jne	.LBB3_16
101.   10    1.0    1.0    25.9      mov	rax, qword ptr [r13 + 15202272]
102.   10    5.9    0.0    24.9      test	rax, rax
103.   10    6.9    0.0    23.9      je	.LBB3_67
104.   10    1.0    1.0    25.8      mov	esi, dword ptr [rdi + 12]
105.   10    6.0    0.9    23.9      test	esi, esi
106.   10    7.0    0.0    22.9      je	.LBB3_66
107.   10    30.9   1.0    0.0       mov	qword ptr [rsp + 32], rdi
108.   10    1.0    1.0    25.8      vmovss	xmm6, dword ptr [rip + .LCPI3_0]
109.   10    7.9    1.9    12.9      vdivss	xmm0, xmm6, xmm0
110.   10    6.8    6.8    24.0      lea	rcx, [r13 + 15202272]
111.   10    30.9   1.0    0.0       mov	qword ptr [rsp + 40], rcx
112.   10    18.0   0.0    12.9      vbroadcastss	xmm7, xmm0
113.   10    5.8    5.8    25.1      mov	r11b, 1
114.   10    1.0    1.0    24.8      vpbroadcastd	xmm8, dword ptr [rip + .LCPI3_1]
115.   10    1.0    1.0    24.8      vpbroadcastd	xmm9, dword ptr [rip + .LCPI3_2]
116.   10    0.0    0.0    31.8      vxorps	xmm10, xmm10, xmm10
117.   10    1.1    1.1    24.8      vmovss	xmm11, dword ptr [rip + .LCPI3_3]
118.   10    5.9    2.9    24.0      mov	rbx, rax
119.   10    5.9    2.8    24.0      test	esi, esi
120.   10    6.8    0.0    23.0      jne	.LBB3_22
121.   10    6.0    6.0    23.8      jmp	.LBB3_20
122.   10    2.9    0.0    22.9      mov	rax, qword ptr [rax]
123.   10    7.0    0.0    21.9      test	rax, rax
124.   10    8.0    0.0    20.9      jne	.LBB3_66
125.   10    6.0    6.0    22.9      jmp	.LBB3_67
126.   10    6.9    0.0    21.9      lea	rcx, [rax + 80]
127.   10    0.0    0.0    29.8      xor	edx, edx
128.   10    6.9    6.9    21.9      jmp	.LBB3_65
129.   10    6.9    0.9    21.0      lea	rcx, [rax + 136]
130.   10    4.9    4.9    23.0      mov	edx, 1
131.   10    6.1    6.1    21.8      jmp	.LBB3_65
132.   10    7.8    1.9    20.0      lea	rcx, [rax + 192]
133.   10    4.8    4.8    23.0      mov	edx, 2
134.   10    6.7    0.9    19.1      imul	rdx, rdx, 56
135.   10    27.9   1.0    0.0       mov	byte ptr [rcx], 1
136.   10    8.8    0.0    15.1      mov	r8, qword ptr [rax + rdx + 48]
137.   10    28.8   1.0    0.0       add	dword ptr [rax + rdx + 56], 1
138.   10    8.7    0.0    26.1      lea	r9, [rax + rdx]
139.   10    8.8    0.0    25.1      add	r9, 32
140.   10    28.9   1.0    5.0       mov	qword ptr [rax + rdx + 64], r9
141.   10    29.8   1.0    4.0       mov	qword ptr [rax + rdx + 72], r8
142.   10    7.8    0.1    22.0      mov	rcx, qword ptr [rax + rdx + 40]
143.   10    12.8   0.0    21.0      add	rcx, r8
144.   10    13.8   0.0    20.0      mov	r10d, ecx
145.   10    13.9   0.0    19.0      and	r10d, 7
146.   10    3.8    3.8    29.1      mov	r11d, 8
147.   10    14.8   0.0    18.0      sub	r11, r10
148.   10    14.8   0.0    18.0      test	r10, r10
149.   10    15.8   0.0    17.0      cmove	r11, r10
150.   10    16.8   0.0    16.0      lea	r8, [r8 + r11 + 32]
151.   10    28.9   1.0    3.0       mov	qword ptr [rax + rdx + 48], r8
152.   10    29.9   1.0    2.0       mov	qword ptr [r11 + rcx], rbp
153.   10    1.0    0.1    26.8      mov	eax, dword ptr [rbx + 36]
154.   10    30.8   1.0    1.0       mov	dword ptr [r11 + rcx + 24], eax
155.   10    31.8   1.0    0.0       mov	qword ptr [r11 + rcx + 8], r9
156.   10    1.0    1.0    26.8      mov	rax, qword ptr [rbp + 24]
157.   10    1.1    1.1    25.8      mov	rdx, qword ptr [rbp + 16]
158.   10    6.1    0.0    24.8      add	rdx, rax
159.   10    7.0    0.0    23.8      mov	r8d, edx
160.   10    8.0    0.0    22.8      and	r8d, 7
161.   10    2.8    2.8    28.0      mov	r9d, 8
162.   10    9.0    0.0    21.8      sub	r9, r8
163.   10    8.1    0.0    21.8      test	r8, r8
164.   10    9.1    0.0    20.8      cmove	r9, r8
165.   10    13.8   0.0    16.0      lea	r8, [r11 + rcx]
166.   10    10.0   0.0    19.8      add	rax, r9
167.   10    11.0   0.0    18.8      add	rax, 24
168.   10    10.0   0.0    19.8      add	r9, rdx
169.   10    29.9   1.0    0.0       mov	qword ptr [rbp + 24], rax
170.   10    30.9   1.0    0.0       mov	qword ptr [r11 + rcx + 16], r9
171.   10    31.8   1.0    0.0       mov	byte ptr [r11 + rcx + 28], 2
172.   10    1.0    1.0    26.8      mov	rax, qword ptr [rbp]
173.   10    6.0    0.0    21.8      mov	rcx, qword ptr [rax + 288]
174.   10    1.9    1.9    29.9      lea	rdx, [rip + handmade_asset.LoadSoundWork]
175.   10    0.0    0.0    31.8      vzeroupper
176.   10    30.8   30.8   0.0       call	qword ptr [rip + handmade_data.PlatformAddEntry]
177.   10    1.0    1.0    128.8     mov	r11b, 1
178.   10    1.0    1.0    123.8     mov	rax, qword ptr [rbx]
179.   10    6.1    0.1    122.7     test	rax, rax
180.   10    7.1    0.0    121.7     jne	.LBB3_61
181.   10    1.9    1.9    126.9     jmp	.LBB3_67
182.   10    1.0    1.0    123.8     mov	rdi, qword ptr [rsp + 32]
183.   10    2.0    2.0    122.8     mov	rax, qword ptr [rbx]
184.   10    6.0    0.0    121.8     test	rax, rax
185.   10    7.0    0.0    120.8     je	.LBB3_67
186.   10    5.0    0.0    118.8     mov	esi, dword ptr [rdi + 12]
187.   10    29.8   1.0    98.0      mov	qword ptr [rsp + 40], rbx
188.   10    7.1    1.1    120.7     mov	rbx, rax
189.   10    10.0   0.0    117.8     test	esi, esi
190.   10    10.0   0.0    116.8     jne	.LBB3_22
191.   10    1.0    1.0    125.8     jmp	.LBB3_20
192.   10    9.0    0.0    117.8     sub	esi, ecx
193.   10    10.0   0.0    116.8     je	.LBB3_20
194.   10    2.0    2.0    120.8     mov	rcx, qword ptr [rbp + 88]
195.   10    7.1    0.0    115.7     mov	eax, dword ptr [rbx + 36]
196.   10    11.1   0.0    114.7     mov	rdx, rax
197.   10    12.1   0.0    113.7     shl	rdx, 4
198.   10    13.1   0.0    108.7     mov	rdi, qword ptr [rcx + rdx]
199.   10    18.1   0.0    107.7     test	rdi, rdi
200.   10    18.2   0.0    106.7     je	.LBB3_49
201.   10    1.0    1.0    119.9     mov	rdx, qword ptr [rbp + 72]
202.   10    10.1   0.0    114.7     lea	rax, [rax + 2*rax]
203.   10    11.1   0.0    113.7     lea	r14, [rdx + 8*rax]
204.   10    11.2   0.0    112.7     add	r14, 16
205.   10    10.2   0.0    109.7     mov	edx, dword ptr [rdx + 8*rax + 16]
206.   10    15.2   0.0    108.7     test	rdx, rdx
207.   10    16.2   0.0    107.7     je	.LBB3_35
208.   10    15.1   0.0    108.7     shl	rdx, 4
209.   10    0.0    0.0    124.8     xor	eax, eax
210.   10    25.9   0.9    89.9      lock		cmpxchg	byte ptr [rcx + rdx + 8], r11b
211.   10    32.9   0.0    88.9      jne	.LBB3_30
212.   10    1.0    1.0    116.8     mov	rax, qword ptr [rbp]
213.   10    6.0    0.0    110.8     cmp	byte ptr [rax + 80], 1
214.   10    12.0   0.0    109.8     jne	.LBB3_31
215.   10    6.0    1.0    109.8     cmp	byte ptr [rax + 136], 1
216.   10    12.0   0.0    108.8     jne	.LBB3_32
217.   10    6.0    1.0    109.8     cmp	byte ptr [rax + 192], 1
218.   10    12.9   0.9    107.9     jne	.LBB3_33
219.   10    6.0    2.0    108.8     cmp	byte ptr [rax + 248], 0
220.   10    13.8   1.8    106.0     jne	.LBB3_35
221.   10    4.0    0.0    115.8     lea	rcx, [rax + 248]
222.   10    1.0    1.0    118.8     mov	edx, 3
223.   10    1.0    1.0    118.8     jmp	.LBB3_34
224.   10    7.1    0.0    107.7     mov	eax, dword ptr [r14]
225.   10    1.0    1.0    113.8     mov	rcx, qword ptr [rbp + 88]
226.   10    12.2   0.1    106.6     shl	rax, 4
227.   10    23.1   0.9    95.7      mov	byte ptr [rcx + rax + 8], 0
228.   10    1.0    1.0    117.8     jmp	.LBB3_35
229.   10    13.2   0.0    105.6     lea	rcx, [rax + 80]
230.   10    0.0    0.0    118.8     xor	edx, edx
231.   10    2.0    2.0    115.8     jmp	.LBB3_34
232.   10    12.2   0.0    105.6     lea	rcx, [rax + 136]
233.   10    1.0    1.0    116.8     mov	edx, 1
234.   10    2.0    2.0    115.8     jmp	.LBB3_34
235.   10    13.2   1.0    104.6     lea	rcx, [rax + 192]
236.   10    2.9    2.9    113.9     mov	edx, 2
237.   10    4.0    0.1    110.8     imul	rdx, rdx, 56
238.   10    22.2   0.9    94.6      mov	byte ptr [rcx], 1
239.   10    11.2   0.0    101.6     mov	r8, qword ptr [rax + rdx + 48]
240.   10    22.2   1.0    87.6      add	dword ptr [rax + rdx + 56], 1
241.   10    11.2   1.0    104.6     lea	r9, [rax + rdx]
242.   10    12.2   0.0    103.6     add	r9, 32
243.   10    23.2   1.0    92.6      mov	qword ptr [rax + rdx + 64], r9
244.   10    23.2   0.9    91.6      mov	qword ptr [rax + rdx + 72], r8
245.   10    10.1   0.9    100.7     mov	rcx, qword ptr [rax + rdx + 40]
246.   10    15.1   0.0    99.7      add	rcx, r8
247.   10    16.1   0.0    98.7      mov	r10d, ecx
248.   10    17.1   0.0    97.7      and	r10d, 7
249.   10    1.9    1.9    112.9     mov	r11d, 8
250.   10    17.1   0.0    96.7      sub	r11, r10
251.   10    17.1   0.0    96.7      test	r10, r10
252.   10    18.1   0.0    95.7      cmove	r11, r10
253.   10    19.1   0.0    94.7      lea	r8, [r8 + r11 + 32]
254.   10    23.7   0.9    90.1      mov	qword ptr [rax + rdx + 48], r8
255.   10    24.7   1.0    89.1      mov	qword ptr [r11 + rcx], rbp
256.   10    2.0    0.9    106.8     mov	eax, dword ptr [r14]
257.   10    24.7   1.0    88.1      mov	dword ptr [r11 + rcx + 24], eax
258.   10    25.7   1.0    87.1      mov	qword ptr [r11 + rcx + 8], r9
259.   10    2.1    2.1    106.7     mov	rax, qword ptr [rbp + 24]
260.   10    3.1    3.1    105.7     mov	rdx, qword ptr [rbp + 16]
261.   10    8.1    0.0    104.7     add	rdx, rax
262.   10    8.1    0.0    103.7     mov	r8d, edx
263.   10    9.1    0.0    102.7     and	r8d, 7
264.   10    1.0    1.0    110.8     mov	r9d, 8
265.   10    10.1   0.0    101.7     sub	r9, r8
266.   10    10.1   0.0    101.7     test	r8, r8
267.   10    11.1   0.0    100.7     cmove	r9, r8
268.   10    16.2   0.1    94.6      lea	r8, [r11 + rcx]
269.   10    11.1   0.0    99.7      add	rax, r9
270.   10    12.1   0.0    98.7      add	rax, 24
271.   10    11.1   0.0    99.7      add	r9, rdx
272.   10    23.8   1.0    86.1      mov	qword ptr [rbp + 24], rax
273.   10    24.8   1.0    85.1      mov	qword ptr [r11 + rcx + 16], r9
274.   10    25.7   1.0    84.1      mov	byte ptr [r11 + rcx + 28], 2
275.   10    1.9    1.9    103.0     mov	rax, qword ptr [rbp]
276.   10    7.0    0.1    97.9      mov	rcx, qword ptr [rax + 288]
277.   10    1.9    1.9    107.0     lea	rdx, [rip + handmade_asset.LoadSoundWork]
278.   10    0.0    0.0    108.9     vzeroupper
279.   10    21.9   21.9   0.0       call	qword ptr [rip + handmade_data.PlatformAddEntry]
280.   10    1.1    1.1    119.8     mov	r11b, 1
281.   10    1.0    1.0    114.9     vmovsd	xmm1, qword ptr [rbx + 8]
282.   10    1.9    1.9    114.0     vmovsd	xmm0, qword ptr [rbx + 16]
283.   10    7.0    0.1    109.9     vmulps	xmm2, xmm7, xmm0
284.   10    2.0    2.0    113.9     vmovd	xmm0, dword ptr [rbx + 40]
285.   10    3.1    3.1    112.8     mov	eax, dword ptr [rdi + 16]
286.   10    1.9    1.9    118.0     vmovdqa	xmm3, xmm9
287.   10    6.0    0.0    112.9     vpternlogd	xmm3, xmm0, xmm8, 248
288.   10    7.1    0.1    108.8     vaddss	xmm3, xmm0, xmm3
289.   10    11.1   0.0    100.8     vroundss	xmm3, xmm3, xmm3, 11
290.   10    19.1   0.0    94.8      vcvttss2usi	ecx, xmm3
291.   10    24.1   0.0    93.8      sub	eax, ecx
292.   10    25.1   0.0    88.8      vcvtusi2ss	xmm4, xmm17, eax
293.   10    1.2    1.2    112.7     vmovss	xmm3, dword ptr [rbx + 32]
294.   10    30.1   0.0    77.8      vdivss	xmm4, xmm4, xmm3
295.   10    1.1    1.1    116.8     vmovdqa	xmm5, xmm9
296.   10    40.1   0.0    76.8      vpternlogd	xmm5, xmm4, xmm8, 248
297.   10    41.1   0.0    72.8      vaddss	xmm4, xmm4, xmm5
298.   10    45.1   0.0    64.8      vroundss	xmm4, xmm4, xmm4, 11
299.   10    53.1   0.0    58.8      vcvttss2usi	r8d, xmm4
300.   10    58.1   0.0    57.8      cmp	esi, r8d
301.   10    59.1   0.0    56.8      cmovb	r8d, esi
302.   10    7.4    0.4    107.5     vucomiss	xmm2, xmm10
303.   10    10.3   0.9    105.6     jne	.LBB3_36
304.   10    10.3   0.9    105.6     jnp	.LBB3_38
305.   10    1.0    1.0    110.9     vmovss	xmm4, dword ptr [rbx + 24]
306.   10    5.0    0.0    106.9     vsubss	xmm4, xmm4, xmm1
307.   10    10.1   1.1    94.8      vdivss	xmm4, xmm4, xmm2
308.   10    21.1   0.0    90.8      vaddss	xmm4, xmm11, xmm4
309.   10    25.1   0.0    84.8      vcvttss2usi	ecx, xmm4
310.   10    59.1   0.0    55.8      cmp	r8d, ecx
311.   10    59.1   0.0    53.8      seta	al
312.   10    59.1   0.0    54.8      cmovae	r8d, ecx
313.   10    5.9    0.9    108.0     vmovshdup	xmm4, xmm2
314.   10    10.2   3.3    102.7     vucomiss	xmm4, xmm10
315.   10    12.2   0.0    101.7     jne	.LBB3_37
316.   10    12.1   0.9    100.8     jnp	.LBB3_39
317.   10    1.9    1.9    107.0     vmovss	xmm5, dword ptr [rbx + 28]
318.   10    2.1    2.1    110.8     vmovshdup	xmm16, xmm1
319.   10    7.9    1.0    102.0     vsubss	xmm5, xmm5, xmm16
320.   10    12.0   0.1    90.9      vdivss	xmm4, xmm5, xmm4
321.   10    23.0   0.0    86.9      vaddss	xmm4, xmm11, xmm4
322.   10    26.0   0.0    80.9      vcvttss2usi	ecx, xmm4
323.   10    58.1   0.0    53.8      cmp	r8d, ecx
324.   10    59.1   0.0    51.8      seta	dl
325.   10    59.1   0.0    52.8      cmovae	r8d, ecx
326.   10    59.1   0.0    51.8      mov	ecx, r8d
327.   10    59.1   0.0    51.8      test	r8d, r8d
328.   10    60.1   0.0    50.8      jne	.LBB3_40
329.   10    2.8    2.8    108.1     jmp	.LBB3_42
330.   10    0.0    0.0    111.9     xor	eax, eax
331.   10    2.9    0.9    108.0     vmovshdup	xmm4, xmm2
332.   10    7.6    4.7    101.3     vucomiss	xmm4, xmm10
333.   10    10.5   0.9    99.4      jne	.LBB3_37
334.   10    10.5   0.9    99.4      jp	.LBB3_37
335.   10    0.0    0.0    110.9     xor	edx, edx
336.   10    58.1   0.0    51.8      mov	ecx, r8d
337.   10    59.1   1.0    50.8      test	r8d, r8d
338.   10    59.1   0.0    49.8      je	.LBB3_42
339.   10    0.0    0.0    109.9     xor	r8d, r8d
340.   10    1.9    1.9    100.0     vroundss	xmm4, xmm0, xmm0, 9
341.   10    9.9    0.0    94.0      vcvttss2si	r9d, xmm4
342.   10    15.8   0.9    88.1      vcvtusi2ss	xmm4, xmm17, r9d
343.   10    1.0    1.0    102.9     mov	r10, qword ptr [rdi]
344.   10    20.8   0.0    84.1      vsubss	xmm4, xmm0, xmm4
345.   10    14.9   0.0    89.0      vmovd	xmm5, dword ptr [r10 + 2*r9]
346.   10    19.9   0.0    88.0      vpmovsxwd	xmm5, xmm5
347.   10    19.9   0.0    84.0      vcvtdq2ps	xmm5, xmm5
348.   10    23.8   0.0    80.1      vsubss	xmm16, xmm6, xmm4
349.   10    27.8   0.0    79.1      vinsertps	xmm4, xmm16, xmm4, 16
350.   10    28.8   0.0    75.1      vmulps	xmm4, xmm4, xmm5
351.   10    32.8   0.0    74.1      vmovshdup	xmm5, xmm4
352.   10    1.9    1.9    96.0      vmulss	xmm16, xmm1, dword ptr [r13 + 15202288]
353.   10    32.8   0.0    70.1      vaddss	xmm4, xmm4, xmm5
354.   10    36.8   0.0    66.1      vmulss	xmm5, xmm16, xmm4
355.   10    36.9   0.1    61.0      vaddss	xmm5, xmm5, dword ptr [r12 + 4*r8]
356.   10    44.9   0.0    60.0      vmovss	dword ptr [r12 + 4*r8], xmm5
357.   10    1.0    1.0    103.9     vmovshdup	xmm5, xmm1
358.   10    1.9    0.9    95.0      vmulss	xmm5, xmm5, dword ptr [r13 + 15202292]
359.   10    36.9   1.1    65.0      vmulss	xmm4, xmm5, xmm4
360.   10    35.9   0.0    60.0      vaddss	xmm4, xmm4, dword ptr [r15 + 4*r8]
361.   10    1.0    1.0    11.0      vmovss	dword ptr [r15 + 4*r8], xmm4
362.   10    1.0    1.0    8.1       vaddps	xmm1, xmm2, xmm1
363.   10    1.0    1.0    8.1       vaddss	xmm0, xmm3, xmm0
364.   10    1.0    1.0    11.1      add	r8, 1
365.   10    2.0    0.0    10.1      cmp	rcx, r8
366.   10    2.0    0.0    9.1       jne	.LBB3_41
367.   10    4.0    0.0    7.2       vmovlps	qword ptr [rbx + 8], xmm1
368.   10    1.0    1.0    10.2      test	al, al
369.   10    2.0    0.0    9.2       je	.LBB3_43
370.   10    1.0    1.0    6.3       vmovss	xmm1, dword ptr [rbx + 24]
371.   10    5.0    0.0    5.4       vmovss	dword ptr [rbx + 8], xmm1
372.   10    6.0    1.0    4.5       mov	dword ptr [rbx + 16], 0
373.   10    1.0    1.0    9.5       test	dl, dl
374.   10    2.0    0.0    8.5       jne	.LBB3_46
375.   10    6.0    1.0    3.6       vmovss	dword ptr [rbx + 40], xmm0
376.   10    2.0    0.0    2.7       vcvttss2usi	eax, xmm0
377.   10    3.0    0.0    1.8       cmp	dword ptr [rdi + 16], eax
378.   10    8.0    0.0    0.9       jne	.LBB3_21
379.   10    1.0    1.0    7.9       jmp	.LBB3_47
380.   10    1.0    1.0    7.9       test	dl, dl
381.   10    2.0    0.0    6.9       je	.LBB3_44
382.   10    1.0    1.0    3.9       vmovss	xmm1, dword ptr [rbx + 28]
383.   10    5.0    0.0    2.9       vmovss	dword ptr [rbx + 12], xmm1
384.   10    6.0    1.0    1.9       mov	dword ptr [rbx + 20], 0
385.   10    7.0    1.0    0.9       vmovss	dword ptr [rbx + 40], xmm0
386.   10    1.0    1.0    0.9       vcvttss2usi	eax, xmm0
387.   10    2.0    0.0    0.0       cmp	dword ptr [rdi + 16], eax
388.   10    8.0    0.0    0.0       jne	.LBB3_21
389.   10    1.0    1.0    3.0       mov	eax, dword ptr [r14]
390.   10    5.0    0.0    2.0       test	eax, eax
391.   10    6.0    0.0    1.0       je	.LBB3_57
392.   10    6.0    1.0    1.0       mov	dword ptr [rbx + 36], eax
393.   10    7.0    1.0    0.0       mov	dword ptr [rbx + 40], 0
394.   10    1.0    1.0    6.0       jmp	.LBB3_21
395.   10    5.0    0.0    2.0       test	rax, rax
396.   10    5.0    0.0    1.0       je	.LBB3_20
397.   10    0.0    0.0    7.0       xor	eax, eax
398.   10    6.0    1.0    0.0       lock		cmpxchg	byte ptr [rcx + rdx + 8], r11b
399.   10    1.0    1.0    7.0       mov	rdi, qword ptr [rsp + 32]
400.   10    13.0   0.0    0.0       jne	.LBB3_59
401.   10    2.0    2.0    7.0       mov	rax, qword ptr [rbp]
402.   10    7.0    0.0    1.0       cmp	byte ptr [rax + 80], 1
403.   10    13.0   0.0    0.0       jne	.LBB3_62
404.   10    6.0    0.0    1.0       cmp	byte ptr [rax + 136], 1
405.   10    13.0   1.0    0.0       jne	.LBB3_63
406.   10    7.0    1.0    1.0       cmp	byte ptr [rax + 192], 1
407.   10    13.0   0.0    0.0       jne	.LBB3_64
408.   10    6.0    1.0    1.0       cmp	byte ptr [rax + 248], 0
409.   10    13.0   1.0    0.0       jne	.LBB3_60
410.   10    7.0    2.0    6.0       lea	rcx, [rax + 248]
411.   10    1.0    1.0    12.0      mov	edx, 3
412.   10    2.0    2.0    11.0      jmp	.LBB3_65
413.   10    1.0    1.0    7.0       mov	rax, qword ptr [rbx]
414.   10    1.0    1.0    7.0       mov	rcx, qword ptr [rsp + 40]
415.   10    6.0    0.0    6.0       mov	qword ptr [rcx], rax
416.   10    2.0    2.0    6.0       mov	rax, qword ptr [r13 + 15202280]
417.   10    7.0    0.0    5.0       mov	qword ptr [rbx], rax
418.   10    8.0    1.0    4.0       mov	qword ptr [r13 + 15202280], rbx
419.   10    5.0    0.0    6.0       mov	rbx, rcx
420.   10    1.0    1.0    10.0      jmp	.LBB3_20
421.   10    6.0    0.0    1.0       mov	eax, dword ptr [rbx + 36]
422.   10    2.0    2.0    5.0       mov	rcx, qword ptr [rbp + 88]
423.   10    11.0   0.0    0.0       shl	rax, 4
424.   10    12.0   0.0    0.0       mov	byte ptr [rcx + rax + 8], 0
425.   10    5.0    0.0    2.0       mov	rax, qword ptr [rbx]
426.   10    10.0   0.0    1.0       test	rax, rax
427.   10    11.0   0.0    0.0       jne	.LBB3_61
428.   10    1.0    0.0    6.0       mov	eax, dword ptr [rdi + 12]
429.   10    6.0    0.0    5.0       test	rax, rax
430.   10    7.0    0.0    4.0       je	.LBB3_86
431.   10    3.0    3.0    3.0       mov	rcx, qword ptr [rdi]
432.   10    5.0    0.0    5.0       cmp	eax, 8
433.   10    6.0    0.0    4.0       jae	.LBB3_70
434.   10    0.0    0.0    11.0      xor	edx, edx
435.   10    1.0    1.0    9.0       jmp	.LBB3_81
436.   10    8.0    0.0    2.0       lea	rdx, [rcx + 4*rax]
437.   10    4.0    0.0    5.0       lea	r8, [r12 + 4*rax]
438.   10    7.0    0.0    2.0       cmp	rcx, r8
439.   10    9.0    1.0    0.0       setb	r10b
440.   10    8.0    0.0    1.0       cmp	rdx, r12
441.   10    10.0   1.0    0.0       seta	r11b
442.   10    4.0    1.0    6.0       lea	r8, [r15 + 4*rax]
443.   10    8.0    2.0    2.0       cmp	rcx, r8
444.   10    9.0    0.0    1.0       setb	r8b
445.   10    8.0    1.0    2.0       cmp	rdx, r15
446.   10    10.0   1.0    0.0       seta	r9b
447.   10    0.0    0.0    11.0      xor	edx, edx
448.   10    10.0   0.0    0.0       test	r10b, r11b
449.   10    11.0   0.0    0.0       jne	.LBB3_81
450.   10    11.0   0.0    0.0       and	r8b, r9b
451.   10    12.0   0.0    0.0       jne	.LBB3_81
452.   10    2.0    0.0    10.0      cmp	eax, 16
453.   10    11.0   9.0    0.0       jae	.LBB3_77
454.   10    0.0    0.0    12.0      xor	edx, edx
455.   10    2.0    2.0    9.0       mov	r8, rdx
456.   10    3.0    2.0    8.0       mov	edx, eax
457.   10    7.0    3.0    4.0       and	edx, -8
458.   10    1.0    1.0    4.0       vbroadcastss	ymm0, dword ptr [rip + .LCPI3_3]
459.   10    6.0    4.0    0.0       vaddps	ymm1, ymm0, ymmword ptr [r12 + 4*r8]
460.   10    17.0   0.0    0.0       vcvttps2dq	ymm1, ymm1
461.   10    20.0   0.0    0.0       vpmovdw	xmm1, ymm1
462.   10    6.0    5.0    6.0       vaddps	ymm2, ymm0, ymmword ptr [r15 + 4*r8]
463.   10    17.0   0.0    3.0       vcvttps2dq	ymm2, ymm2
464.   10    21.0   1.0    0.0       vpmovdw	xmm2, ymm2
465.   10    25.0   0.0    0.0       vpunpcklwd	xmm3, xmm1, xmm2
466.   10    25.0   1.0    0.0       vpunpckhwd	xmm1, xmm1, xmm2
467.   10    26.0   0.0    0.0       vmovdqu	xmmword ptr [rcx + 4*r8 + 16], xmm1
468.   10    27.0   1.0    0.0       vmovdqu	xmmword ptr [rcx + 4*r8], xmm3
469.   10    5.0    5.0    22.0      add	r8, 8
470.   10    5.0    0.0    21.0      cmp	rdx, r8
471.   10    8.0    2.0    18.0      jne	.LBB3_75
472.   10    5.0    1.0    21.0      cmp	rdx, rax
473.   10    8.0    2.0    18.0      jne	.LBB3_81
474.   10    9.0    9.0    17.0      jmp	.LBB3_86
475.   10    6.0    6.0    20.0      lea	r8, [4*rax]
476.   10    5.0    5.0    20.0      movabs	rdx, 17179868928
477.   10    6.0    0.0    19.0      or	rdx, 192
478.   10    7.0    0.0    18.0      and	rdx, r8
479.   10    0.0    0.0    26.0      xor	r8d, r8d
480.   10    6.0    6.0    12.0      vbroadcastss	zmm0, dword ptr [rip + .LCPI3_3]
481.   10    6.0    6.0    11.0      vmovdqa64	zmm1, zmmword ptr [rip + .LCPI3_4]
482.   10    7.0    1.0    7.0       vaddps	zmm2, zmm0, zmmword ptr [r12 + r8]
483.   10    18.0   0.0    3.0       vcvttps2dq	zmm2, zmm2
484.   10    21.0   0.0    0.0       vpmovdw	ymm2, zmm2
485.   10    7.0    2.0    7.0       vaddps	zmm3, zmm0, zmmword ptr [r15 + r8]
486.   10    18.0   0.0    3.0       vcvttps2dq	zmm3, zmm3
487.   10    22.0   1.0    0.0       vpmovdw	ymm3, zmm3
488.   10    26.0   0.0    0.0       vinserti64x4	zmm3, zmm3, ymm3, 1
489.   10    24.0   0.0    2.0       vinserti64x4	zmm2, zmm2, ymm2, 1
490.   10    28.0   0.0    0.0       vpermt2w	zmm2, zmm1, zmm3
491.   10    35.0   0.0    0.0       vmovdqu64	zmmword ptr [rcx + r8], zmm2
492.   10    4.0    4.0    31.0      add	r8, 64
493.   10    4.0    0.0    30.0      cmp	rdx, r8
494.   10    5.0    0.0    29.0      jne	.LBB3_78
495.   10    3.0    3.0    31.0      mov	edx, eax
496.   10    4.0    0.0    30.0      and	edx, -16
497.   10    5.0    0.0    29.0      cmp	rdx, rax
498.   10    6.0    0.0    28.0      je	.LBB3_86
499.   10    3.0    3.0    30.0      test	al, 8
500.   10    5.0    1.0    28.0      jne	.LBB3_74
501.   10    4.0    0.0    29.0      mov	r8, rdx
502.   10    5.0    0.0    28.0      not	r8
503.   10    4.0    4.0    29.0      test	al, 1
504.   10    6.0    1.0    27.0      je	.LBB3_83
505.   10    1.0    1.0    27.0      vmovss	xmm0, dword ptr [rip + .LCPI3_3]
506.   10    4.0    1.0    20.0      vaddss	xmm1, xmm0, dword ptr [r12 + 4*rdx]
507.   10    13.0   0.0    14.0      vcvttss2si	r9d, xmm1
508.   10    33.0   1.0    0.0       mov	word ptr [rcx + 4*rdx], r9w
509.   10    4.0    2.0    20.0      vaddss	xmm0, xmm0, dword ptr [r15 + 4*rdx]
510.   10    13.0   0.0    14.0      vcvttss2si	r9d, xmm0
511.   10    33.0   1.0    0.0       mov	word ptr [rcx + 4*rdx + 2], r9w
512.   10    4.0    2.0    29.0      or	rdx, 1
513.   10    3.0    0.0    29.0      add	r8, rax
514.   10    5.0    1.0    27.0      je	.LBB3_86
515.   10    4.0    4.0    28.0      add	r15, 4
516.   10    1.0    1.0    27.0      vmovss	xmm0, dword ptr [rip + .LCPI3_3]
517.   10    4.0    0.0    20.0      vaddss	xmm1, xmm0, dword ptr [r12 + 4*rdx]
518.   10    12.0   0.0    14.0      vcvttss2si	r8d, xmm1
519.   10    32.0   1.0    0.0       mov	word ptr [rcx + 4*rdx], r8w
520.   10    4.0    0.0    20.0      vaddss	xmm1, xmm0, dword ptr [r15 + 4*rdx - 4]
521.   10    13.0   1.0    13.0      vcvttss2si	r8d, xmm1
522.   10    32.0   1.0    0.0       mov	word ptr [rcx + 4*rdx + 2], r8w
523.   10    4.0    2.0    20.0      vaddss	xmm1, xmm0, dword ptr [r12 + 4*rdx + 4]
524.   10    12.0   0.0    14.0      vcvttss2si	r8d, xmm1
525.   10    32.0   1.0    0.0       mov	word ptr [rcx + 4*rdx + 4], r8w
526.   10    3.0    1.0    21.0      vaddss	xmm1, xmm0, dword ptr [r15 + 4*rdx]
527.   10    13.0   2.0    13.0      vcvttss2si	r8d, xmm1
528.   10    32.0   1.0    0.0       mov	word ptr [rcx + 4*rdx + 6], r8w
529.   10    1.0    1.0    31.0      add	rdx, 2
530.   10    2.0    0.0    30.0      cmp	rax, rdx
531.   10    3.0    0.0    29.0      jne	.LBB3_85
       10    12.2   1.0    42.2      <total>

```
</details>
</details>
