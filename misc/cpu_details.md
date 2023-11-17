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