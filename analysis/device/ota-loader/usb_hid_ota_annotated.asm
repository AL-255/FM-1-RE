; FM-1 full linear disassembly (JieLi pi32v2)
; base=0x01c0a800 entry=0x01c0a800


;===== FUNC_01c0a800  (called 0x) =====
01c0a800  0516                      mov r5,r0
01c0a802  1616                      mov r6,r1
01c0a804  2716                      mov r7,r2
01c0a80a  0000                      nop
01c0a80c  edffd048c101              mov ssp,#0x1c148d0
01c0a812  eeffd038c101              mov sp,#0x1c138d0
01c0a818  c3ff7003c101              mov r3,#0x1c10370
01c0a81e  4120                      mov r1,#0x0
01c0a820  c2ff60450000              mov r2,#0x4560
01c0a826  a2a2                      lsr r2,r2,0x2
01c0a828  0203                      rep 0x2,r2
01c0a82a  b105                      sw r1,[r3 ++= 4]
01c0a82c  f25d                      jnz r2,0x01c0a828
01c0a82e  c3ff6803c101              mov r3,#0x1c10368
01c0a834  4120                      mov r1,#0x0
01c0a836  c2ff00000000              mov r2,#0x0
01c0a83c  a2a2                      lsr r2,r2,0x2
01c0a83e  0203                      rep 0x2,r2
01c0a840  b105                      sw r1,[r3 ++= 4]
01c0a842  f25d                      jnz r2,0x01c0a83e
01c0a844  5016                      mov r0,r5
01c0a846  6116                      mov r1,r6
01c0a848  7216                      mov r2,r7
01c0a84a  c4ffdcbdc001              mov r4,#0x1c0bddc
01c0a852  8040                      jnz r0,0x01c0a854
01c0a854  8100                      rti
01c0a866  0000                      nop
01c0a868  f79f                      goto 0x01c0a868
01c0a86a  7404                      push {0x4}
01c0a86c  0416                      mov r4,r0
01c0a86e  c0ff5003c101              mov r0,#0x1c10350
01c0a874  4238                      mov r2,#0x18
01c0a876  4116                      mov r1,r4
01c0a878  80ead514                  call 0x01c0d226
01c0a87c  4162                      lw r1,[r4 + 0x8]
01c0a87e  c0ff1c03c101              mov r0,#0x1c1031c
01c0a884  4a34                      mov r2,#0x34
01c0a886  3404                      pop {rets,0x4}
01c0a888  c0eacd14                  goto 0x01c0d226

;===== FUNC_01c0a88c  (called 12x) =====
01c0a88c  c1ff083e0100              mov r1,#0x13e08
01c0a896  9061                      sw r0,[r1 + 0x4]
01c0a89c  1060                      lw r0,[r1 + 0x0]
01c0a8a2  1061                      lw r0,[r1 + 0x4]
01c0a8a4  0017                      uxtb r0,r0
01c0a8a6  8000                      rts

;===== FUNC_01c0a8a8  (called 5x) =====
01c0a8a8  7504                      push {0x5}
01c0a8aa  1216                      mov r2,r1
01c0a8ac  0316                      mov r3,r0
01c0a8ae  2000                      csync
01c0a8b0  6000                      cli
01c0a8b2  c4fffc02c101              mov r4,#0x1c102fc
01c0a8ba  0140                      jz r1,0x01c0a8bc
01c0a8bc  2000                      csync
01c0a8be  b817                      sxth r0,r3
01c0a8c0  c5ff083e0100              mov r5,#0x13e08
01c0a8c8  0050                      jz r0,0x01c0a8ea
01c0a8cc  805f                      jnz r0,0x01c0a90c
01c0a8ce  4021                      mov r0,#0x1
01c0a8d0  40e00101                  movz r0,#0x101
01c0a8d6  0050                      jz r0,0x01c0a8f8
01c0a8dc  6197                      call 0x01c0a88c
01c0a8e0  7f3c                      mov r7,#0xfc
01c0a8e2  6194                      call 0x01c0a88c
01c0a8e4  2016                      mov r0,r2
01c0a8e6  6192                      call 0x01c0a88c
01c0a8e8  40e0fefe                  movz r0,#0xfefe
01c0a8ee  0250                      jz r2,0x01c0a910
01c0a8f0  2000                      csync
01c0a8f2  4060                      lw r0,[r4 + 0x0]
01c0a8f4  f83f                      add r0,#-0x1
01c0a8f6  c060                      sw r0,[r4 + 0x0]
01c0a8fa  0000                      nop
01c0a8fc  6100                      sti
01c0a8fe  2000                      csync
01c0a900  5504                      pop {pc,0x5}

;===== FUNC_01c0a902  (called 19x) =====
01c0a902  c2ff00350100              mov r2,#0x13500
01c0a90c  0144                      jz r1,0x01c0a916
01c0a90e  0307                      lb.z r3,[r0 ++= 2]
01c0a910  a360                      sw r3,[r2 + 0x0]
01c0a916  2000                      csync
01c0a918  2061                      lw r0,[r2 + 0x4]
01c0a91a  8017                      uxth r0,r0
01c0a91c  8000                      rts

;===== FUNC_01c0a91e  (called 2x) =====
01c0a91e  7404                      push {0x4}
01c0a920  c4ff80fdc701              mov r4,#0x1c7fd80
01c0a926  488a                      add r0,r4,#0xa
01c0a928  512e                      mov r1,#0x4e
01c0a92a  718b                      call 0x01c0a902
01c0a92c  0116                      mov r1,r0
01c0a92e  4020                      mov r0,#0x0
01c0a930  0159                      jz r1,0x01c0a964
01c0a932  4a64                      lh.z r2,[r4 + 0x8]
01c0a938  4965                      lh.z r1,[r4 + 0xa]
01c0a93a  c2ffffff0000              mov r2,#0xffff
01c0a946  015a                      jz r1,0x01c0a97c
01c0a948  4a66                      lh.z r2,[r4 + 0xc]
01c0a94e  c2ff7c03c101              mov r2,#0x1c1037c
01c0a954  a960                      sh r1,[r2 + 0x0]
01c0a956  c329                      add r3,#0x9
01c0a958  4021                      mov r0,#0x1
01c0a95c  0043                      jz r0,0x01c0a964
01c0a960  4817                      sxtb r0,r4
01c0a962  a960                      sh r1,[r2 + 0x0]
01c0a964  5404                      pop {pc,0x4}

;===== FUNC_01c0a966  (called 3x) =====
01c0a966  7404                      push {0x4}
01c0a968  0216                      mov r2,r0
01c0a96a  2000                      csync
01c0a96c  6000                      cli
01c0a96e  c3fffc02c101              mov r3,#0x1c102fc
01c0a978  2000                      csync
01c0a97a  a817                      sxth r0,r2
01c0a97c  c4ff083e0100              mov r4,#0x13e08
01c0a984  0050                      jz r0,0x01c0a9a6
01c0a988  804f                      jnz r0,0x01c0a9a8
01c0a98a  4021                      mov r0,#0x1
01c0a98c  40e00101                  movz r0,#0x101
01c0a992  0040                      jz r0,0x01c0a994
01c0a994  a0a8                      lsr r0,r2,0x8
01c0a996  3027                      bitset r0,0x7
01c0a99a  8300                      rte
01c0a99c  bfea76ff                  call 0x01c0a88c
01c0a9a2  7f2c                      mov r7,#0xec
01c0a9a4  bfea72ff                  call 0x01c0a88c
01c0a9a8  503e                      mov r0,#0x5e
01c0a9aa  bfea6fff                  call 0x01c0a88c
01c0a9ae  41e0fefe                  movz r1,#0xfefe
01c0a9b4  0241                      jz r2,0x01c0a9b8
01c0a9b6  2000                      csync
01c0a9b8  3160                      lw r1,[r3 + 0x0]
01c0a9ba  f93f                      add r1,#-0x1
01c0a9bc  b160                      sw r1,[r3 + 0x0]
01c0a9c0  0000                      nop
01c0a9c2  6100                      sti
01c0a9c4  2000                      csync
01c0a9c6  5404                      pop {pc,0x4}

;===== FUNC_01c0a9c8  (called 4x) =====
01c0a9c8  7504                      push {0x5}
01c0a9ca  1216                      mov r2,r1
01c0a9cc  0316                      mov r3,r0
01c0a9ce  2000                      csync
01c0a9d0  6000                      cli
01c0a9d2  c4fffc02c101              mov r4,#0x1c102fc
01c0a9da  0140                      jz r1,0x01c0a9dc
01c0a9dc  2000                      csync
01c0a9de  b817                      sxth r0,r3
01c0a9e0  c5ff083e0100              mov r5,#0x13e08
01c0a9e8  0050                      jz r0,0x01c0aa0a
01c0a9ec  805f                      jnz r0,0x01c0aa2c
01c0a9ee  4021                      mov r0,#0x1
01c0a9f0  40e00101                  movz r0,#0x101
01c0a9f6  0050                      jz r0,0x01c0aa18
01c0a9fc  3026                      bitset r0,0x6
01c0a9fe  bfea45ff                  call 0x01c0a88c
01c0aa04  7f3c                      mov r7,#0xfc
01c0aa06  bfea41ff                  call 0x01c0a88c
01c0aa0a  2016                      mov r0,r2
01c0aa0c  bfea3eff                  call 0x01c0a88c
01c0aa10  40e0fefe                  movz r0,#0xfefe
01c0aa16  0250                      jz r2,0x01c0aa38
01c0aa18  2000                      csync
01c0aa1a  4060                      lw r0,[r4 + 0x0]
01c0aa1c  f83f                      add r0,#-0x1
01c0aa1e  c060                      sw r0,[r4 + 0x0]
01c0aa22  0000                      nop
01c0aa24  6100                      sti
01c0aa26  2000                      csync
01c0aa28  5504                      pop {pc,0x5}

;===== FUNC_01c0aa2a  (called 10x) =====
01c0aa2a  1004                      push rets
01c0aa2c  c2ff00070100              mov r2,#0x10700
01c0aa3a  0116                      mov r1,r0
01c0aa3c  80ea832b                  call 0x01c10146
01c0aa40  c3ff00093d00              mov r3,#0x3d0900
01c0aa48  0003                      rep 0x2,r0
01c0aa4a  101b                      mul r0,r1
01c0aa4c  a062                      sw r0,[r2 + 0x8]
01c0aa52  2060                      lw r0,[r2 + 0x0]
01c0aa56  fd79                      sh r5,[r7 + -0xe]
01c0aa5c  0004                      pop pc

;===== FUNC_01c0aa5e  (called 1x) =====
01c0aa5e  7604                      push {0x6}
01c0aa60  0416                      mov r4,r0
01c0aa64  201a                      lsl r0,r2
01c0aa68  3320                      bitset r3,0x0
01c0aa6c  2051                      jz r0,0x01c0ab10
01c0aa6e  8819                      and r0,r0
01c0aa72  0061                      lw r0,[r0 + 0x4]
01c0aa74  4016                      mov r0,r4
01c0aa76  bfea76ff                  call 0x01c0a966
01c0aa7c  0306                      lh.z r3,[r0 ++= 2]
01c0aa7e  5019                      or r0,r5
01c0aa80  0117                      uxtb r1,r0
01c0aa82  4016                      mov r0,r4
01c0aa84  3604                      pop {rets,0x6}
01c0aa86  8790                      goto 0x01c0a8a8

;===== FUNC_01c0aa88  (called 3x) =====
01c0aa88  7504                      push {0x5}
01c0aa8a  1216                      mov r2,r1
01c0aa8c  0316                      mov r3,r0
01c0aa8e  2000                      csync
01c0aa90  6000                      cli
01c0aa92  c4fffc02c101              mov r4,#0x1c102fc
01c0aa9a  0140                      jz r1,0x01c0aa9c
01c0aa9c  2000                      csync
01c0aa9e  b817                      sxth r0,r3
01c0aaa0  c5ff083e0100              mov r5,#0x13e08
01c0aaa8  0050                      jz r0,0x01c0aaca
01c0aaac  805f                      jnz r0,0x01c0aaec
01c0aaae  4021                      mov r0,#0x1
01c0aab0  40e00101                  movz r0,#0x101
01c0aab6  0050                      jz r0,0x01c0aad8
01c0aabc  3025                      bitset r0,0x5
01c0aabe  bfeae5fe                  call 0x01c0a88c
01c0aac4  7f3c                      mov r7,#0xfc
01c0aac6  bfeae1fe                  call 0x01c0a88c
01c0aaca  2016                      mov r0,r2
01c0aacc  bfeadefe                  call 0x01c0a88c
01c0aad0  40e0fefe                  movz r0,#0xfefe
01c0aad6  0250                      jz r2,0x01c0aaf8
01c0aad8  2000                      csync
01c0aada  4060                      lw r0,[r4 + 0x0]
01c0aadc  f83f                      add r0,#-0x1
01c0aade  c060                      sw r0,[r4 + 0x0]
01c0aae2  0000                      nop
01c0aae4  6100                      sti
01c0aae6  2000                      csync
01c0aae8  5504                      pop {pc,0x5}

;===== FUNC_01c0aaea  (called 2x) =====
01c0aaea  7404                      push {0x4}
01c0aaec  0416                      mov r4,r0
01c0aaee  4031                      mov r0,#0x11
01c0aaf0  793b                      mov r1,#0xfb
01c0aaf2  bfea69ff                  call 0x01c0a9c8
01c0aaf6  4021                      mov r0,#0x1
01c0aaf8  4198                      call 0x01c0aa2a
01c0aafa  4031                      mov r0,#0x11
01c0aafc  793e                      mov r1,#0xfe
01c0aafe  bfea63ff                  call 0x01c0a9c8
01c0ab02  4317                      uxtb r3,r4
01c0ab04  4031                      mov r0,#0x11
01c0ab06  4123                      mov r1,#0x3
01c0ab08  4223                      mov r2,#0x3
01c0ab0a  5189                      call 0x01c0aa5e
01c0ab0c  4021                      mov r0,#0x1
01c0ab0e  418d                      call 0x01c0aa2a
01c0ab10  4031                      mov r0,#0x11
01c0ab12  4121                      mov r1,#0x1
01c0ab14  5199                      call 0x01c0aa88
01c0ab16  4031                      mov r0,#0x11
01c0ab18  4124                      mov r1,#0x4
01c0ab1a  3404                      pop {rets,0x4}
01c0ab1c  d795                      goto 0x01c0aa88
01c0ab1e  c2ff48e2ee01              mov r2,#0x1eee248
01c0ab26  ff23                      add r7,#-0x1d
01c0ab2e  2d03                      rep 0x6,r13
01c0ab30  8000                      rts

;===== FUNC_01c0ab32  (called 2x) =====
01c0ab32  f795                      goto 0x01c0ab1e

;===== FUNC_01c0ab34  (called 1x) =====
01c0ab34  1004                      push rets
01c0ab36  80ea2b2b                  call 0x01c10190
01c0ab3a  c0ff00a8c001              mov r0,#0x1c0a800
01c0ab40  c1ff00ecc701              mov r1,#0x1c7ec00
01c0ab46  7195                      call 0x01c0ab32
01c0ab48  c1ff8ed0c001              mov r1,#0x1c0d08e
01c0ab4e  4021                      mov r0,#0x1
01c0ab50  4220                      mov r2,#0x0
01c0ab54  c0ea6a2b                  goto 0x01c1022c

;===== FUNC_01c0ab58  (called 1x) =====
01c0ab58  c0eac826                  goto 0x01c0f8ec

;===== FUNC_01c0ab5c  (called 1x) =====
01c0ab5c  c1ffc003c101              mov r1,#0x1c103c0
01c0ab62  9862                      sh r0,[r1 + 0x4]
01c0ab64  8000                      rts

;===== FUNC_01c0ab66  (called 3x) =====
01c0ab66  6820                      mov r0,#0xa0
01c0ab68  4124                      mov r1,#0x4
01c0ab6a  4221                      mov r2,#0x1
01c0ab6c  4321                      mov r3,#0x1
01c0ab6e  b797                      goto 0x01c0aa5e

;===== FUNC_01c0ab70  (called 1x) =====
01c0ab70  f79a                      goto 0x01c0ab66

;===== FUNC_01c0ab72  (called 3x) =====
01c0ab72  8060                      sw r0,[r0 + 0x0]
01c0ab74  8061                      sw r0,[r0 + 0x4]
01c0ab76  8000                      rts

;===== FUNC_01c0ab78  (called 2x) =====
01c0ab78  a061                      sw r0,[r2 + 0x4]
01c0ab7a  8260                      sw r2,[r0 + 0x0]
01c0ab7c  8161                      sw r1,[r0 + 0x4]
01c0ab7e  9060                      sw r0,[r1 + 0x0]
01c0ab80  8000                      rts

;===== FUNC_01c0ab82  (called 2x) =====
01c0ab82  1216                      mov r2,r1
01c0ab84  2161                      lw r1,[r2 + 0x4]
01c0ab86  f798                      goto 0x01c0ab78
01c0ab88  7504                      push {0x5}
01c0ab8a  0415                      mov r4_r5,r0_r1
01c0ab8e  0340                      jz r3,0x01c0ab90
01c0ab94  0340                      jz r3,0x01c0ab96
01c0ab9c  4119                      or r1,r4
01c0ab9e  0418                      add r4,r0
01c0aba0  1518                      add r5,r1
01c0aba4  0340                      jz r3,0x01c0aba6
01c0abaa  0000                      nop
01c0abae  0003                      rep 0x2,r0
01c0abb0  619f                      call 0x01c0ab70
01c0abb4  e45f                      jnz r4,0x01c0ab74
01c0abb8  c066                      sw r0,[r4 + 0x18]
01c0abba  619b                      call 0x01c0ab72
01c0abbc  4988                      add r1,r4,#0x8
01c0abbe  1016                      mov r0,r1
01c0abc0  6198                      call 0x01c0ab72
01c0abc2  4890                      add r0,r4,#0x10
01c0abc4  619e                      call 0x01c0ab82
01c0abc6  4016                      mov r0,r4
01c0abc8  5504                      pop {pc,0x5}

;===== FUNC_01c0abca  (called 3x) =====
01c0abca  e79e                      goto 0x01c0ab88

;===== FUNC_01c0abcc  (called 1x) =====
01c0abcc  7404                      push {0x4}
01c0abce  c4ffc003c101              mov r4,#0x1c103c0
01c0abd6  4404                      pop {0x4}
01c0abd8  8047                      jnz r0,0x01c0abe8
01c0abdc  0c47                      lb.z r4,[r0 + 0x7]
01c0abde  41e00008                  movz r1,#0x800
01c0abe2  7193                      call 0x01c0abca
01c0abe6  4504                      pop {0x5}
01c0abe8  5404                      pop {pc,0x4}

;===== FUNC_01c0abea  (called 26x) =====
01c0abea  7504                      push {0x5}
01c0abee  c5ff04300100              mov r5,#0x13004
01c0abf6  d060                      sw r0,[r5 + 0x0]
01c0abf8  2016                      mov r0,r2
01c0abfa  3216                      mov r2,r3
01c0abfc  4316                      mov r3,r4
01c0abfe  3504                      pop {rets,0x5}
01c0ac00  c0eaac27                  goto 0x01c0fb5c
01c0ac06  0100                      idle
01c0ac0a  a21a                      lsr r2,r2
01c0ac12  9480                      goto 0x01c0ae54
01c0ac1c  8000                      rts
01c0ac1e  8000                      rts
01c0ac28  8000                      rts

;===== FUNC_01c0ac2a  (called 7x) =====
01c0ac2a  0116                      mov r1,r0
01c0ac32  90a4                      lsr r0,r1,0x4
01c0ac34  00a2                      lsl r0,r0,0x2
01c0ac36  c1ffc8d5c001              mov r1,#0x1c0d5c8
01c0ac3e  0201                      tbb r2
01c0ac40  8000                      rts

;===== FUNC_01c0ac42  (called 1x) =====
01c0ac42  1004                      push rets
01c0ac44  0216                      mov r2,r0
01c0ac48  9440                      jnz r4,0x01c0ac8a
01c0ac4c  e79b                      goto 0x01c0ac04
01c0ac50  071e                      sub r7,r0,r0
01c0ac52  718b                      call 0x01c0ac2a
01c0ac56  ff4f                      sb r7,[r7 + 0xf]
01c0ac5e  1301                      tbh r3
01c0ac60  0004                      pop pc
01c0ac64  0100                      idle
01c0ac68  a21a                      lsr r2,r2
01c0ac70  9480                      goto 0x01c0aeb2
01c0ac7a  8000                      rts
01c0ac7c  8000                      rts
01c0ac86  8000                      rts

;===== FUNC_01c0ac88  (called 1x) =====
01c0ac88  1004                      push rets
01c0ac8a  0216                      mov r2,r0
01c0ac8e  9440                      jnz r4,0x01c0acd0
01c0ac92  f787                      goto 0x01c0ac62
01c0ac96  071e                      sub r7,r0,r0
01c0ac98  6188                      call 0x01c0ac2a
01c0ac9c  ff4f                      sb r7,[r7 + 0xf]
01c0aca4  1701                      tbh r7
01c0aca6  0004                      pop pc

;===== FUNC_01c0aca8  (called 1x) =====
01c0aca8  1004                      push rets
01c0acaa  6020                      mov r0,#0x80
01c0acac  792f                      mov r1,#0xef
01c0acae  bfea8bfe                  call 0x01c0a9c8
01c0acb2  6020                      mov r0,#0x80
01c0acb4  792f                      mov r1,#0xef
01c0acb6  bfea87fe                  call 0x01c0a9c8
01c0acba  6020                      mov r0,#0x80
01c0acbc  4120                      mov r1,#0x0
01c0acbe  bfeaf3fd                  call 0x01c0a8a8
01c0acc2  6020                      mov r0,#0x80
01c0acc4  412d                      mov r1,#0xd
01c0acc6  bfeaeffd                  call 0x01c0a8a8
01c0acca  6020                      mov r0,#0x80
01c0accc  4130                      mov r1,#0x10
01c0acd0  679b                      goto 0x01c0aa88

;===== FUNC_01c0acd2  (called 21x) =====
01c0acd2  6020                      mov r0,#0x80
01c0acd4  5120                      mov r1,#0x40
01c0acd6  6798                      goto 0x01c0aa88

;===== FUNC_01c0acd8  (called 2x) =====
01c0acd8  c0ff88fdc701              mov r0,#0x1c7fd88
01c0acde  4120                      mov r1,#0x0
01c0ace0  5230                      mov r2,#0x50
01c0ace2  c0ea0113                  goto 0x01c0d2e8

;===== FUNC_01c0ace6  (called 3x) =====
01c0ace6  7504                      push {0x5}
01c0ace8  0416                      mov r4,r0
01c0acea  7196                      call 0x01c0acd8
01c0acec  c5ff80fdc701              mov r5,#0x1c7fd80
01c0acf4  0d5a                      lb.z r5,[r0 + -0x6]
01c0acf6  dc66                      sh r4,[r5 + 0xc]
01c0acf8  d867                      sh r0,[r5 + 0xe]
01c0acfa  588a                      add r0,r5,#0xa
01c0acfc  512e                      mov r1,#0x4e
01c0acfe  bfea00fe                  call 0x01c0a902
01c0ad02  d864                      sh r0,[r5 + 0x8]
01c0ad04  5504                      pop {pc,0x5}

;===== FUNC_01c0ad06  (called 2x) =====
01c0ad06  c0ff7403c101              mov r0,#0x1c10374
01c0ad0c  8060                      sw r0,[r0 + 0x0]
01c0ad0e  8061                      sw r0,[r0 + 0x4]
01c0ad10  8000                      rts

;===== FUNC_01c0ad12  (called 1x) =====
01c0ad12  7504                      push {0x5}
01c0ad14  0416                      mov r4,r0
01c0ad16  4840                      lb.z r0,[r4 + 0x0]
01c0ad1a  1ca0                      qasl r4,r1,0x0
01c0ad1e  4120                      mov r1,#0x0
01c0ad22  bf2f                      bitclr r7,0xf
01c0ad24  0017                      uxtb r0,r0
01c0ad2a  20a4                      lsl r0,r2,0x4
01c0ad30  0484                      goto 0x01c0ad3a
01c0ad34  6130                      mov r1,#0x90
01c0ad38  1da4                      qasl r5,r1,0x4
01c0ad40  4320                      mov r3,#0x0
01c0ad46  2018                      add r0,r2
01c0ad4e  021e                      sub r2,r0,r0
01c0ad50  1018                      add r0,r1
01c0ad52  5504                      pop {pc,0x5}
01c0ad54  c5ff8dd4c001              mov r5,#0x1c0d48d
01c0ad5a  4015                      mov r0_r1,r4_r5
01c0ad5c  80eada12                  call 0x01c0d314
01c0ad60  004a                      jz r0,0x01c0ad76
01c0ad62  5986                      add r1,r5,#0x6
01c0ad64  4016                      mov r0,r4
01c0ad66  80ead512                  call 0x01c0d314
01c0ad6a  0116                      mov r1,r0
01c0ad6c  6035                      mov r0,#0x95
01c0ad70  0000                      nop
01c0ad74  5504                      pop {pc,0x5}
01c0ad76  6034                      mov r0,#0x94
01c0ad78  5504                      pop {pc,0x5}
01c0ad7c  0100                      idle
01c0ad8e  4321                      mov r3,#0x1
01c0ad96  0060                      lw r0,[r0 + 0x0]
01c0ad98  2160                      lw r1,[r2 + 0x0]
01c0ad9e  2160                      lw r1,[r2 + 0x0]
01c0ada0  1019                      or r0,r1
01c0ada2  a060                      sw r0,[r2 + 0x0]
01c0ada4  8000                      rts
01c0adaa  4321                      mov r3,#0x1
01c0adb2  0060                      lw r0,[r0 + 0x0]
01c0adb4  2162                      lw r1,[r2 + 0x8]
01c0adba  2162                      lw r1,[r2 + 0x8]
01c0adbc  1019                      or r0,r1
01c0adbe  a062                      sw r0,[r2 + 0x8]
01c0adc0  8000                      rts

;===== FUNC_01c0adc2  (called 1x) =====
01c0adc2  1004                      push rets
01c0adc4  0216                      mov r2,r0
01c0adc8  9480                      goto 0x01c0b00a
01c0adca  4120                      mov r1,#0x0
01c0adce  e795                      goto 0x01c0ad7a
01c0add2  081e                      sub r0,r0,r1
01c0add4  bfea29ff                  call 0x01c0ac2a
01c0adda  ff4f                      sb r7,[r7 + 0xf]
01c0ade2  0b01                      tbb r11
01c0ade4  0004                      pop pc
01c0ade8  0100                      idle
01c0adfa  4321                      mov r3,#0x1
01c0ae02  0060                      lw r0,[r0 + 0x0]
01c0ae04  2160                      lw r1,[r2 + 0x0]
01c0ae0a  2160                      lw r1,[r2 + 0x0]
01c0ae0c  1019                      or r0,r1
01c0ae0e  a060                      sw r0,[r2 + 0x0]
01c0ae10  8000                      rts
01c0ae16  4321                      mov r3,#0x1
01c0ae1e  0060                      lw r0,[r0 + 0x0]
01c0ae20  2162                      lw r1,[r2 + 0x8]
01c0ae26  2162                      lw r1,[r2 + 0x8]
01c0ae28  1019                      or r0,r1
01c0ae2a  a062                      sw r0,[r2 + 0x8]
01c0ae2c  8000                      rts

;===== FUNC_01c0ae2e  (called 3x) =====
01c0ae2e  1004                      push rets
01c0ae30  1216                      mov r2,r1
01c0ae32  0316                      mov r3,r0
01c0ae36  9440                      jnz r4,0x01c0ae78
01c0ae3a  e795                      goto 0x01c0ade6
01c0ae3e  101e                      sub r0,r1,r0
01c0ae40  bfeaf3fe                  call 0x01c0ac2a
01c0ae4c  4321                      mov r3,#0x1
01c0ae54  0040                      jz r0,0x01c0ae56
01c0ae58  0c01                      tbb r12
01c0ae5a  0004                      pop pc
01c0ae5e  0f01                      tbb r15
01c0ae60  0004                      pop pc
01c0ae64  0100                      idle
01c0ae76  4321                      mov r3,#0x1
01c0ae7e  0060                      lw r0,[r0 + 0x0]
01c0ae80  2160                      lw r1,[r2 + 0x0]
01c0ae86  2160                      lw r1,[r2 + 0x0]
01c0ae88  1019                      or r0,r1
01c0ae8a  a060                      sw r0,[r2 + 0x0]
01c0ae8c  8000                      rts
01c0ae92  4321                      mov r3,#0x1
01c0ae9a  0060                      lw r0,[r0 + 0x0]
01c0ae9c  2162                      lw r1,[r2 + 0x8]
01c0aea2  2162                      lw r1,[r2 + 0x8]
01c0aea4  1019                      or r0,r1
01c0aea6  a062                      sw r0,[r2 + 0x8]
01c0aea8  8000                      rts

;===== FUNC_01c0aeaa  (called 2x) =====
01c0aeaa  7504                      push {0x5}
01c0aeac  1416                      mov r4,r1
01c0aeae  0516                      mov r5,r0
01c0aeb4  4120                      mov r1,#0x0
01c0aeb6  bfea60ff                  call 0x01c0ad7a
01c0aeba  5016                      mov r0,r5
01c0aebc  4116                      mov r1,r4
01c0aebe  3504                      pop {rets,0x5}
01c0aec0  e790                      goto 0x01c0ae62
01c0aec4  131e                      sub r3,r1,r0
01c0aec6  bfeab0fe                  call 0x01c0ac2a
01c0aed0  0f50                      lb.z r7,[r0 + -0x10]
01c0aed2  4221                      mov r2,#0x1
01c0aed8  0445                      jz r4,0x01c0aee4
01c0aedc  0100                      idle
01c0aee0  0001                      tbb r0
01c0aee2  0482                      goto 0x01c0aee8
01c0aee6  0301                      tbb r3
01c0aeea  0b01                      tbb r11
01c0aeec  5504                      pop {pc,0x5}

;===== FUNC_01c0aeee  (called 1x) =====
01c0aeee  1004                      push rets
01c0aef0  0216                      mov r2,r0
01c0aef4  081e                      sub r0,r0,r1
01c0aef6  bfea98fe                  call 0x01c0ac2a
01c0aefc  ff4f                      sb r7,[r7 + 0xf]
01c0af04  1801                      tbh r8
01c0af06  0004                      pop pc

;===== FUNC_01c0af08  (called 1x) =====
01c0af08  1004                      push rets
01c0af0a  0216                      mov r2,r0
01c0af0e  081e                      sub r0,r0,r1
01c0af10  bfea8bfe                  call 0x01c0ac2a
01c0af16  ff4f                      sb r7,[r7 + 0xf]
01c0af1e  1c01                      tbh r12
01c0af20  0004                      pop pc

;===== FUNC_01c0af22  (called 1x) =====
01c0af22  1004                      push rets
01c0af24  c0ff28f0c701              mov r0,#0x1c7f028
01c0af2a  41e08c01                  movz r1,#0x18c
01c0af2e  bfea4cfe                  call 0x01c0abca
01c0af32  c1ffc003c101              mov r1,#0x1c103c0
01c0af38  9066                      sw r0,[r1 + 0x18]
01c0af3a  0004                      pop pc
01c0af3c  0044                      jz r0,0x01c0af46
01c0af40  0040                      jz r0,0x01c0af42
01c0af42  9061                      sw r0,[r1 + 0x4]
01c0af44  8160                      sw r1,[r0 + 0x0]
01c0af46  8000                      rts

;===== FUNC_01c0af48  (called 3x) =====
01c0af48  0216                      mov r2,r0
01c0af4a  1016                      mov r0,r1
01c0af4c  2116                      mov r1,r2
01c0af4e  f796                      goto 0x01c0af3c
01c0af50  7704                      push {0x7}
01c0af52  0316                      mov r3,r0
01c0af54  2000                      csync
01c0af56  6000                      cli
01c0af58  c5fffc02c101              mov r5,#0x1c102fc
01c0af60  0150                      jz r1,0x01c0af82
01c0af62  1894                      add r0,r1,#0x14
01c0af66  0300                      hbkpt
01c0af6c  4120                      mov r1,#0x0
01c0af70  0300                      hbkpt
01c0af72  2116                      mov r1,r2
01c0af74  2000                      csync
01c0af76  2000                      csync
01c0af7a  3462                      lw r4,[r3 + 0x8]
01c0af7c  3888                      add r0,r3,#0x8
01c0af7e  0481                      goto 0x01c0af82
01c0af80  4460                      lw r4,[r4 + 0x0]
01c0af84  0e40                      lb.z r6,[r0 + 0x0]
01c0af86  4762                      lw r7,[r4 + 0x8]
01c0af8a  fa71                      sh r2,[r7 + -0x1e]
01c0af8c  688c                      add r0,r6,#0xc
01c0af90  0a70                      lh.z r2,[r0 + -0x20]
01c0af92  c01d                      add r0,r4,r6
01c0af94  f11f                      sub r1,r7,r6
01c0af96  8162                      sw r1,[r0 + 0x8]
01c0af98  4260                      lw r2,[r4 + 0x0]
01c0af9a  4161                      lw r1,[r4 + 0x4]
01c0af9c  bfeaecfd                  call 0x01c0ab78
01c0afa0  0486                      goto 0x01c0afae
01c0afa2  4020                      mov r0,#0x0
01c0afa4  048f                      goto 0x01c0afc4
01c0afa8  4000                      lockclr
01c0afaa  618e                      call 0x01c0af48
01c0afac  7616                      mov r6,r7
01c0afae  c362                      sw r3,[r4 + 0x8]
01c0afb0  4020                      mov r0,#0x0
01c0afb6  c663                      sw r6,[r4 + 0xc]
01c0afbc  4016                      mov r0,r4
01c0afbe  bfead8fd                  call 0x01c0ab72
01c0afc2  4894                      add r0,r4,#0x14
01c0afc4  2000                      csync
01c0afc6  5160                      lw r1,[r5 + 0x0]
01c0afc8  f93f                      add r1,#-0x1
01c0afca  d160                      sw r1,[r5 + 0x0]
01c0afce  0000                      nop
01c0afd0  6100                      sti
01c0afd2  2000                      csync
01c0afd4  5704                      pop {pc,0x7}

;===== FUNC_01c0afd6  (called 5x) =====
01c0afd6  d79c                      goto 0x01c0af50

;===== FUNC_01c0afd8  (called 2x) =====
01c0afd8  e686                      goto 0x01c0ab66

;===== FUNC_01c0afda  (called 1x) =====
01c0afda  7504                      push {0x5}
01c0afdc  c5ffc003c101              mov r5,#0x1c103c0
01c0afe2  5066                      lw r0,[r5 + 0x18]
01c0afe4  6120                      mov r1,#0x80
01c0afe6  7197                      call 0x01c0afd6
01c0afe8  0416                      mov r4,r0
01c0afea  8445                      jnz r4,0x01c0aff6
01c0afee  0000                      nop
01c0aff2  0003                      rep 0x2,r0
01c0aff4  7191                      call 0x01c0afd8
01c0aff6  d464                      sw r4,[r5 + 0x10]
01c0aff8  5066                      lw r0,[r5 + 0x18]
01c0affa  6120                      mov r1,#0x80
01c0affc  718c                      call 0x01c0afd6
01c0affe  0416                      mov r4,r0
01c0b000  8445                      jnz r4,0x01c0b00c
01c0b004  0000                      nop
01c0b008  0003                      rep 0x2,r0
01c0b00a  7186                      call 0x01c0afd8
01c0b00c  d465                      sw r4,[r5 + 0x14]
01c0b00e  c0ff1203c101              mov r0,#0x1c10312
01c0b014  4121                      mov r1,#0x1
01c0b016  8940                      sb r1,[r0 + 0x0]
01c0b018  5504                      pop {pc,0x5}

;===== FUNC_01c0b01a  (called 1x) =====
01c0b01a  1004                      push rets
01c0b01c  1316                      mov r3,r1
01c0b01e  c1ff1404c101              mov r1,#0x1c10414
01c0b02c  4120                      mov r1,#0x0
01c0b02e  5a28                      mov r2,#0x68
01c0b030  3016                      mov r0,r3
01c0b032  80ea5911                  call 0x01c0d2e8
01c0b036  0004                      pop pc

;===== FUNC_01c0b038  (called 2x) =====
01c0b038  7804                      push {0x8}
01c0b03a  e29f                      add sp,#-0x4
01c0b03c  0816                      mov r8,r0
01c0b03e  4720                      mov r7,#0x0
01c0b044  c1ff32d4c001              mov r1,#0x1c0d432
01c0b04a  4229                      mov r2,#0x9
01c0b04c  4016                      mov r0,r4
01c0b04e  80eaea10                  call 0x01c0d226
01c0b054  1880                      add r0,r1,#0x0
01c0b056  c1ff8403c101              mov r1,#0x1c10384
01c0b05c  0d1c                      add r5,r0,r1
01c0b05e  4e89                      add r6,r4,#0x9
01c0b062  5a37                      mov r2,#0x77
01c0b064  034c                      jz r3,0x01c0b07e
01c0b066  8a80                      add r2,sp,#0x0
01c0b068  8016                      mov r0,r8
01c0b06a  6116                      mov r1,r6
01c0b06c  c300                      call r3
01c0b06e  004e                      jz r0,0x01c0b08c
01c0b070  0618                      add r6,r0
01c0b072  601f                      sub r0,r6,r4
01c0b078  c721                      add r7,#0x1
01c0b07e  601f                      sub r0,r6,r4
01c0b080  c842                      sb r0,[r4 + 0x2]
01c0b082  81a8                      lsr r1,r0,0x8
01c0b084  c943                      sb r1,[r4 + 0x3]
01c0b088  c944                      sb r1,[r4 + 0x4]
01c0b08a  0487                      goto 0x01c0b09a
01c0b08e  0000                      nop
01c0b092  0003                      rep 0x2,r0
01c0b094  bfea67fd                  call 0x01c0ab66
01c0b098  4020                      mov r0,#0x0
01c0b09a  0281                      add sp,#0x4
01c0b09c  5804                      pop {pc,0x8}
01c0b09e  7504                      push {0x5}
01c0b0a0  c3ffc003c101              mov r3,#0x1c103c0
01c0b0aa  014d                      jz r1,0x01c0b0c6
01c0b0ac  1b94                      add r3,r1,#0x14
01c0b0ae  05a2                      lsl r5,r0,0x2
01c0b0b2  0450                      jz r4,0x01c0b0d4
01c0b0b4  3c43                      lb.z r4,[r3 + 0x3]
01c0b0b6  bc22                      bitclr r4,0x2
01c0b0b8  5419                      or r4,r5
01c0b0ba  bc43                      sb r4,[r3 + 0x3]
01c0b0bc  9261                      sw r2,[r1 + 0x4]
01c0b0be  4122                      mov r1,#0x2
01c0b0c2  b940                      sb r1,[r3 + 0x0]
01c0b0c4  5199                      call 0x01c0b038
01c0b0c6  5504                      pop {pc,0x5}

;===== FUNC_01c0b0c8  (called 1x) =====
01c0b0c8  7604                      push {0x6}
01c0b0ca  0416                      mov r4,r0
01c0b0ce  1440                      jz r4,0x01c0b110
01c0b0d0  c6ffc003c101              mov r6,#0x1c103c0
01c0b0d6  851d                      add r5,r0,r6
01c0b0da  ac50                      sb r4,[r2 + -0x10]
01c0b0dc  4120                      mov r1,#0x0
01c0b0de  4234                      mov r2,#0x14
01c0b0e0  80ea0211                  call 0x01c0d2e8
01c0b0e6  d450                      jnz r4,0x01c0b048
01c0b0e8  4120                      mov r1,#0x0
01c0b0ea  4234                      mov r2,#0x14
01c0b0ec  80eafc10                  call 0x01c0d2e8
01c0b0f0  6567                      lw r5,[r6 + 0x1c]
01c0b0f2  854a                      jnz r5,0x01c0b108
01c0b0f4  c5fff4f1c701              mov r5,#0x1c7f1f4
01c0b0fa  4120                      mov r1,#0x0
01c0b0fc  42e0b802                  movz r2,#0x2b8
01c0b100  5016                      mov r0,r5
01c0b102  80eaf110                  call 0x01c0d2e8
01c0b106  e567                      sw r5,[r6 + 0x1c]
01c0b10a  0052                      jz r0,0x01c0b130
01c0b10c  4016                      mov r0,r4
01c0b10e  4185                      call 0x01c0b01a
01c0b112  6267                      lw r2,[r6 + 0x1c]
01c0b116  6822                      mov r0,#0xa2
01c0b118  3604                      pop {rets,0x6}
01c0b11a  e781                      goto 0x01c0b09e

;===== FUNC_01c0b11c  (called 1x) =====
01c0b11c  7504                      push {0x5}
01c0b11e  0416                      mov r4,r0
01c0b120  144b                      jz r4,0x01c0b178
01c0b122  c0ff01600100              mov r0,#0x16001
01c0b128  4120                      mov r1,#0x0
01c0b12e  8940                      sb r1,[r0 + 0x0]
01c0b134  a160                      sw r1,[r2 + 0x0]
01c0b13e  40e0e803                  movz r0,#0x3e8
01c0b142  80ea0528                  call 0x01c10150
01c0b14e  2060                      lw r0,[r2 + 0x0]
01c0b152  fd21                      add r5,#-0x1f
01c0b166  c02d                      add r0,#0xd
01c0b168  c0ffffff0000              mov r0,#0xffff
01c0b170  402b                      mov r0,#0xb
01c0b172  9861                      sh r0,[r1 + 0x2]
01c0b174  9860                      sh r0,[r1 + 0x0]
01c0b176  5504                      pop {pc,0x5}
01c0b178  45a1                      lsl r5,r4,0x1
01c0b17c  9550                      jnz r5,0x01c0b1de
01c0b17e  4121                      mov r1,#0x1
01c0b180  bfea55fe                  call 0x01c0ae2e
01c0b186  9450                      jnz r4,0x01c0b1e8
01c0b188  4121                      mov r1,#0x1
01c0b18a  bfea50fe                  call 0x01c0ae2e
01c0b18e  c0ffacd4c001              mov r0,#0x1c0d4ac
01c0b194  0988                      add r1,r0,#0x8
01c0b1a0  001e                      sub r0,r0,r0
01c0b1a4  801d                      add r0,r0,r6
01c0b1a6  42e0cbbf                  movz r2,#0xbfcb
01c0b1ac  0202                      pfetch [r2]
01c0b1b0  0000                      nop
01c0b1b4  0100                      idle
01c0b1c6  5504                      pop {pc,0x5}
01c0b1cc  2360                      lw r3,[r2 + 0x0]
01c0b1d2  00a8                      lsl r0,r0,0x8
01c0b1d4  c3ff00ffff00              mov r3,#0xffff00
01c0b1da  b019                      not r0,r3
01c0b1dc  1117                      uxtb r1,r1
01c0b1de  1019                      or r0,r1
01c0b1e0  a061                      sw r0,[r2 + 0x4]
01c0b1e2  2000                      csync
01c0b1e4  40e0dfb1                  movz r0,#0xb1df
01c0b1e8  2161                      lw r1,[r2 + 0x4]
01c0b1ea  9917                      sxth r1,r1
01c0b1ee  0200                      bkpt
01c0b1f0  c021                      add r0,#0x1
01c0b1f2  f05a                      jnz r0,0x01c0b1e8
01c0b1f4  8000                      rts

;===== FUNC_01c0b1f6  (called 1x) =====
01c0b1f6  7404                      push {0x4}
01c0b1fc  c0ff01600100              mov r0,#0x16001
01c0b202  5920                      mov r1,#0x60
01c0b204  8940                      sb r1,[r0 + 0x0]
01c0b206  5404                      pop {pc,0x4}
01c0b208  2000                      csync
01c0b20a  6000                      cli
01c0b20c  c4fffc02c101              mov r4,#0x1c102fc
01c0b214  0140                      jz r1,0x01c0b216
01c0b216  2000                      csync
01c0b218  2000                      csync
01c0b21a  4021                      mov r0,#0x1
01c0b21c  5920                      mov r1,#0x60
01c0b21e  6194                      call 0x01c0b1c8
01c0b220  2000                      csync
01c0b222  4060                      lw r0,[r4 + 0x0]
01c0b224  f83f                      add r0,#-0x1
01c0b226  c060                      sw r0,[r4 + 0x0]
01c0b22a  0000                      nop
01c0b22c  6100                      sti
01c0b22e  2000                      csync
01c0b230  5404                      pop {pc,0x4}

;===== FUNC_01c0b232  (called 2x) =====
01c0b232  7404                      push {0x4}
01c0b234  2000                      csync
01c0b236  6000                      cli
01c0b238  c4fffc02c101              mov r4,#0x1c102fc
01c0b240  0140                      jz r1,0x01c0b242
01c0b242  2000                      csync
01c0b244  2000                      csync
01c0b246  0045                      jz r0,0x01c0b252
01c0b248  c0ff0b600100              mov r0,#0x1600b
01c0b24e  8940                      sb r1,[r0 + 0x0]
01c0b250  0482                      goto 0x01c0b256
01c0b252  402b                      mov r0,#0xb
01c0b254  5199                      call 0x01c0b1c8
01c0b256  2000                      csync
01c0b258  4060                      lw r0,[r4 + 0x0]
01c0b25a  f83f                      add r0,#-0x1
01c0b25c  c060                      sw r0,[r4 + 0x0]
01c0b260  0000                      nop
01c0b262  6100                      sti
01c0b264  2000                      csync
01c0b266  5404                      pop {pc,0x4}
01c0b26e  2360                      lw r3,[r2 + 0x0]
01c0b270  4020                      mov r0,#0x0
01c0b276  11a8                      lsl r1,r1,0x8
01c0b278  c3ff00bfff00              mov r3,#0xffbf00
01c0b27e  b119                      not r1,r3
01c0b280  312e                      bitset r1,0xe
01c0b282  a161                      sw r1,[r2 + 0x4]
01c0b284  2000                      csync
01c0b286  41e0dfb1                  movz r1,#0xb1df
01c0b28a  2361                      lw r3,[r2 + 0x4]
01c0b28c  bb17                      sxth r3,r3
01c0b290  0300                      hbkpt
01c0b292  c121                      add r1,#0x1
01c0b294  f15a                      jnz r1,0x01c0b28a
01c0b296  8000                      rts
01c0b298  2061                      lw r0,[r2 + 0x4]
01c0b29a  0017                      uxtb r0,r0
01c0b29c  8000                      rts

;===== FUNC_01c0b29e  (called 2x) =====
01c0b29e  7404                      push {0x4}
01c0b2a0  2000                      csync
01c0b2a2  6000                      cli
01c0b2a4  c4fffc02c101              mov r4,#0x1c102fc
01c0b2ac  0140                      jz r1,0x01c0b2ae
01c0b2ae  2000                      csync
01c0b2b0  2000                      csync
01c0b2b2  0047                      jz r0,0x01c0b2c2
01c0b2b4  c0ff06600100              mov r0,#0x16006
01c0b2ba  0960                      lh.z r1,[r0 + 0x0]
01c0b2bc  4120                      mov r1,#0x0
01c0b2be  8960                      sh r1,[r0 + 0x0]
01c0b2c0  048c                      goto 0x01c0b2da
01c0b2c2  4027                      mov r0,#0x7
01c0b2c4  6191                      call 0x01c0b268
01c0b2c6  4028                      mov r0,#0x8
01c0b2c8  618f                      call 0x01c0b268
01c0b2ca  4027                      mov r0,#0x7
01c0b2cc  4120                      mov r1,#0x0
01c0b2ce  bfea7bff                  call 0x01c0b1c8
01c0b2d2  4028                      mov r0,#0x8
01c0b2d4  4120                      mov r1,#0x0
01c0b2d6  bfea77ff                  call 0x01c0b1c8
01c0b2da  2000                      csync
01c0b2dc  4060                      lw r0,[r4 + 0x0]
01c0b2de  f83f                      add r0,#-0x1
01c0b2e0  c060                      sw r0,[r4 + 0x0]
01c0b2e4  0000                      nop
01c0b2e6  6100                      sti
01c0b2e8  2000                      csync
01c0b2ea  5404                      pop {pc,0x4}

;===== FUNC_01c0b2ec  (called 2x) =====
01c0b2ec  7404                      push {0x4}
01c0b2ee  2000                      csync
01c0b2f0  6000                      cli
01c0b2f2  c4fffc02c101              mov r4,#0x1c102fc
01c0b2fa  0140                      jz r1,0x01c0b2fc
01c0b2fc  2000                      csync
01c0b2fe  2000                      csync
01c0b300  0047                      jz r0,0x01c0b310
01c0b302  c0ff08600100              mov r0,#0x16008
01c0b308  0960                      lh.z r1,[r0 + 0x0]
01c0b30a  4120                      mov r1,#0x0
01c0b30c  8960                      sh r1,[r0 + 0x0]
01c0b30e  048c                      goto 0x01c0b328
01c0b310  4029                      mov r0,#0x9
01c0b312  518a                      call 0x01c0b268
01c0b314  402a                      mov r0,#0xa
01c0b316  5188                      call 0x01c0b268
01c0b318  4029                      mov r0,#0x9
01c0b31a  4120                      mov r1,#0x0
01c0b31c  bfea54ff                  call 0x01c0b1c8
01c0b320  402a                      mov r0,#0xa
01c0b322  4120                      mov r1,#0x0
01c0b324  bfea50ff                  call 0x01c0b1c8
01c0b328  2000                      csync
01c0b32a  4060                      lw r0,[r4 + 0x0]
01c0b32c  f83f                      add r0,#-0x1
01c0b32e  c060                      sw r0,[r4 + 0x0]
01c0b332  0000                      nop
01c0b334  6100                      sti
01c0b336  2000                      csync
01c0b338  5404                      pop {pc,0x4}

;===== FUNC_01c0b33a  (called 1x) =====
01c0b33a  7404                      push {0x4}
01c0b33c  0416                      mov r4,r0
01c0b33e  4120                      mov r1,#0x0
01c0b340  bfea77ff                  call 0x01c0b232
01c0b344  4016                      mov r0,r4
01c0b346  518b                      call 0x01c0b29e
01c0b348  4016                      mov r0,r4
01c0b34a  6190                      call 0x01c0b2ec
01c0b34e  0060                      lw r0,[r0 + 0x0]
01c0b350  4022                      mov r0,#0x2
01c0b354  b41b                      mul r4,r11
01c0b356  40e00008                  movz r0,#0x800
01c0b35c  8c1b                      mul r12,r8
01c0b362  5404                      pop {pc,0x4}

;===== FUNC_01c0b364  (called 9x) =====
01c0b364  7504                      push {0x5}
01c0b366  c3ff1404c101              mov r3,#0x1c10414
01c0b36c  004c                      jz r0,0x01c0b386
01c0b370  3a40                      lb.z r2,[r3 + 0x0]
01c0b372  144f                      jz r4,0x01c0b3d2
01c0b374  0159                      jz r1,0x01c0b3a8
01c0b376  f93f                      add r1,#-0x1
01c0b378  14a3                      lsl r4,r1,0x3
01c0b37a  45e0095a                  movz r5,#0x5a09
01c0b380  4b25                      mov r3,#0x25
01c0b382  2000                      csync
01c0b384  1481                      goto 0x01c0b3c8
01c0b386  c4ffacd4c001              mov r4,#0x1c0d4ac
01c0b38c  014f                      jz r1,0x01c0b3ac
01c0b390  3a50                      lb.z r2,[r3 + -0x10]
01c0b392  055f                      jz r5,0x01c0b3d2
01c0b396  4a40                      lb.z r2,[r4 + 0x0]
01c0b39c  c26f                      sw r2,[r4 + 0x3c]
01c0b39e  2000                      csync
01c0b3a4  826d                      sw r2,[r0 + 0x34]
01c0b3a6  5504                      pop {pc,0x5}
01c0b3a8  c260                      sw r2,[r4 + 0x0]
01c0b3aa  5504                      pop {pc,0x5}
01c0b3b0  9266                      sw r2,[r1 + 0x18]
01c0b3b2  2000                      csync
01c0b3b8  004c                      jz r0,0x01c0b3d2
01c0b3ba  8260                      sw r2,[r0 + 0x0]
01c0b3bc  5504                      pop {pc,0x5}
01c0b3be  f93f                      add r1,#-0x1
01c0b3c0  15a3                      lsl r5,r1,0x3
01c0b3c2  5418                      add r4,r5
01c0b3c4  c268                      sw r2,[r4 + 0x20]
01c0b3c6  2000                      csync
01c0b3cc  c828                      add r0,#0x28
01c0b3d2  5504                      pop {pc,0x5}

;===== FUNC_01c0b3d4  (called 1x) =====
01c0b3d4  7604                      push {0x6}
01c0b3d6  2000                      csync
01c0b3d8  6000                      cli
01c0b3da  c5fffc02c101              mov r5,#0x1c102fc
01c0b3e2  0150                      jz r1,0x01c0b404
01c0b3e4  1416                      mov r4,r1
01c0b3e6  2000                      csync
01c0b3e8  2000                      csync
01c0b3ea  0048                      jz r0,0x01c0b3fc
01c0b3ec  c0ff06600100              mov r0,#0x16006
01c0b3f2  0960                      lh.z r1,[r0 + 0x0]
01c0b3f8  8960                      sh r1,[r0 + 0x0]
01c0b3fa  0494                      goto 0x01c0b424
01c0b3fc  4027                      mov r0,#0x7
01c0b3fe  bfea33ff                  call 0x01c0b268
01c0b404  0064                      lw r0,[r0 + 0x10]
01c0b406  4028                      mov r0,#0x8
01c0b408  bfea2eff                  call 0x01c0b268
01c0b40c  0416                      mov r4,r0
01c0b40e  6117                      uxtb r1,r6
01c0b410  4027                      mov r0,#0x7
01c0b412  bfead9fe                  call 0x01c0b1c8
01c0b416  40a8                      lsl r0,r4,0x8
01c0b418  6019                      or r0,r6
01c0b41e  4028                      mov r0,#0x8
01c0b420  bfead2fe                  call 0x01c0b1c8
01c0b424  2000                      csync
01c0b426  5060                      lw r0,[r5 + 0x0]
01c0b428  f83f                      add r0,#-0x1
01c0b42a  d060                      sw r0,[r5 + 0x0]
01c0b42e  0000                      nop
01c0b430  6100                      sti
01c0b432  2000                      csync
01c0b434  5604                      pop {pc,0x6}

;===== FUNC_01c0b436  (called 1x) =====
01c0b436  7604                      push {0x6}
01c0b438  2000                      csync
01c0b43a  6000                      cli
01c0b43c  c5fffc02c101              mov r5,#0x1c102fc
01c0b444  0150                      jz r1,0x01c0b466
01c0b446  1416                      mov r4,r1
01c0b448  2000                      csync
01c0b44a  2000                      csync
01c0b44c  0048                      jz r0,0x01c0b45e
01c0b44e  c0ff08600100              mov r0,#0x16008
01c0b454  0960                      lh.z r1,[r0 + 0x0]
01c0b45a  8960                      sh r1,[r0 + 0x0]
01c0b45c  0494                      goto 0x01c0b486
01c0b45e  4029                      mov r0,#0x9
01c0b460  bfea02ff                  call 0x01c0b268
01c0b466  0064                      lw r0,[r0 + 0x10]
01c0b468  402a                      mov r0,#0xa
01c0b46a  bfeafdfe                  call 0x01c0b268
01c0b46e  0416                      mov r4,r0
01c0b470  6117                      uxtb r1,r6
01c0b472  4029                      mov r0,#0x9
01c0b474  bfeaa8fe                  call 0x01c0b1c8
01c0b478  40a8                      lsl r0,r4,0x8
01c0b47a  6019                      or r0,r6
01c0b480  402a                      mov r0,#0xa
01c0b482  bfeaa1fe                  call 0x01c0b1c8
01c0b486  2000                      csync
01c0b488  5060                      lw r0,[r5 + 0x0]
01c0b48a  f83f                      add r0,#-0x1
01c0b48c  d060                      sw r0,[r5 + 0x0]
01c0b490  0000                      nop
01c0b492  6100                      sti
01c0b494  2000                      csync
01c0b496  5604                      pop {pc,0x6}
01c0b49a  0060                      lw r0,[r0 + 0x0]
01c0b49c  c2ff74d0c001              mov r2,#0x1c0d074
01c0b4a2  4836                      mov r0,#0x36
01c0b4a4  c2ff66d0c001              mov r2,#0x1c0d066
01c0b4aa  4029                      mov r0,#0x9
01c0b4ac  4123                      mov r1,#0x3
01c0b4ae  c0ea9126                  goto 0x01c101d4

;===== FUNC_01c0b4b2  (called 1x) =====
01c0b4b2  7404                      push {0x4}
01c0b4b4  0416                      mov r4,r0
01c0b4b6  bfea07fe                  call 0x01c0b0c8
01c0b4ba  4016                      mov r0,r4
01c0b4bc  bfea2efe                  call 0x01c0b11c
01c0b4c0  4016                      mov r0,r4
01c0b4c2  bfea98fe                  call 0x01c0b1f6
01c0b4c6  4016                      mov r0,r4
01c0b4c8  bfea37ff                  call 0x01c0b33a
01c0b4cc  c2ffb4f1c701              mov r2,#0x1c7f1b4
01c0b4d2  4120                      mov r1,#0x0
01c0b4d4  4016                      mov r0,r4
01c0b4d6  bfea45ff                  call 0x01c0b364
01c0b4da  4121                      mov r1,#0x1
01c0b4dc  4016                      mov r0,r4
01c0b4de  bfea41ff                  call 0x01c0b364
01c0b4e2  4122                      mov r1,#0x2
01c0b4e4  4016                      mov r0,r4
01c0b4e6  bfea3dff                  call 0x01c0b364
01c0b4ea  4123                      mov r1,#0x3
01c0b4ec  4016                      mov r0,r4
01c0b4ee  bfea39ff                  call 0x01c0b364
01c0b4f2  4124                      mov r1,#0x4
01c0b4f4  4016                      mov r0,r4
01c0b4f6  bfea35ff                  call 0x01c0b364
01c0b4fa  4125                      mov r1,#0x5
01c0b4fc  4016                      mov r0,r4
01c0b4fe  bfea98fe                  call 0x01c0b232
01c0b502  4016                      mov r0,r4
01c0b504  bfeacbfe                  call 0x01c0b29e
01c0b508  4016                      mov r0,r4
01c0b50a  bfeaeffe                  call 0x01c0b2ec
01c0b50e  4120                      mov r1,#0x0
01c0b510  4016                      mov r0,r4
01c0b512  bfea5fff                  call 0x01c0b3d4
01c0b516  4120                      mov r1,#0x0
01c0b518  4016                      mov r0,r4
01c0b51a  418d                      call 0x01c0b436
01c0b51c  4016                      mov r0,r4
01c0b51e  3404                      pop {rets,0x4}
01c0b520  d79b                      goto 0x01c0b498

;===== FUNC_01c0b522  (called 2x) =====
01c0b522  c0ffc003c101              mov r0,#0x1c103c0
01c0b52c  8000                      rts
01c0b52e  c1ffc003c101              mov r1,#0x1c103c0
01c0b53a  0040                      jz r0,0x01c0b53c
01c0b53c  c1ffb8c7c001              mov r1,#0x1c0c7b8
01c0b542  8163                      sw r1,[r0 + 0xc]
01c0b544  8000                      rts
01c0b546  f793                      goto 0x01c0b52e

;===== FUNC_01c0b548  (called 1x) =====
01c0b548  7404                      push {0x4}
01c0b54a  bfeaeafc                  call 0x01c0af22
01c0b54e  c4ff8403c101              mov r4,#0x1c10384
01c0b554  4120                      mov r1,#0x0
01c0b556  4238                      mov r2,#0x18
01c0b558  4016                      mov r0,r4
01c0b55a  80eac50e                  call 0x01c0d2e8
01c0b55e  c0ff6ebfc001              mov r0,#0x1c0bf6e
01c0b564  c060                      sw r0,[r4 + 0x0]
01c0b566  bfea38fd                  call 0x01c0afda
01c0b56a  4020                      mov r0,#0x0
01c0b56c  5182                      call 0x01c0b4b2
01c0b56e  6199                      call 0x01c0b522
01c0b570  3404                      pop {rets,0x4}
01c0b572  f789                      goto 0x01c0b546

;===== FUNC_01c0b574  (called 1x) =====
01c0b574  c1ff7003c101              mov r1,#0x1c10370
01c0b57a  9060                      sw r0,[r1 + 0x0]
01c0b57c  8000                      rts

;===== FUNC_01c0b57e  (called 14x) =====
01c0b57e  1004                      push rets
01c0b580  7199                      call 0x01c0b574
01c0b582  0004                      pop pc

;===== FUNC_01c0b584  (called 3x) =====
01c0b584  4220                      mov r2,#0x0
01c0b586  0484                      goto 0x01c0b590
01c0b588  0307                      lb.z r3,[r0 ++= 2]
01c0b58a  3218                      add r2,r3
01c0b58c  2217                      uxtb r2,r2
01c0b58e  f93f                      add r1,#-0x1
01c0b590  f15b                      jnz r1,0x01c0b588
01c0b592  783f                      mov r0,#0xff
01c0b596  0302                      pfetch [r3]
01c0b598  8000                      rts

;===== FUNC_01c0b59a  (called 1x) =====
01c0b59a  7604                      push {0x6}
01c0b59c  1416                      mov r4,r1
01c0b59e  0516                      mov r5,r0
01c0b5a0  c6ff0c04c101              mov r6,#0x1c1040c
01c0b5a6  024a                      jz r2,0x01c0b5bc
01c0b5a8  4120                      mov r1,#0x0
01c0b5aa  4228                      mov r2,#0x8
01c0b5ac  6016                      mov r0,r6
01c0b5ae  80ea9b0e                  call 0x01c0d2e8
01c0b5b2  e561                      sw r5,[r6 + 0x4]
01c0b5b4  ec61                      sh r4,[r6 + 0x2]
01c0b5b6  4021                      mov r0,#0x1
01c0b5b8  e841                      sb r0,[r6 + 0x1]
01c0b5ba  5604                      pop {pc,0x6}
01c0b5bc  c630                      add r6,#0x10
01c0b5be  4120                      mov r1,#0x0
01c0b5c0  422c                      mov r2,#0xc
01c0b5c2  6016                      mov r0,r6
01c0b5c4  80ea900e                  call 0x01c0d2e8
01c0b5c8  e562                      sw r5,[r6 + 0x8]
01c0b5ca  40a3                      lsl r0,r4,0x3
01c0b5cc  e862                      sh r0,[r6 + 0x4]
01c0b5ce  4021                      mov r0,#0x1
01c0b5d0  e842                      sb r0,[r6 + 0x2]
01c0b5d2  5604                      pop {pc,0x6}

;===== FUNC_01c0b5d4  (called 1x) =====
01c0b5d4  5120                      mov r1,#0x40
01c0b5d6  c0ea850d                  goto 0x01c0d0e4

;===== FUNC_01c0b5da  (called 9x) =====
01c0b5da  0116                      mov r1,r0
01c0b5dc  402e                      mov r0,#0xe
01c0b5de  f694                      goto 0x01c0b1c8

;===== FUNC_01c0b5e0  (called 2x) =====
01c0b5e0  7504                      push {0x5}
01c0b5e2  2000                      csync
01c0b5e4  6000                      cli
01c0b5e6  c5fffc02c101              mov r5,#0x1c102fc
01c0b5ee  0150                      jz r1,0x01c0b610
01c0b5f0  2000                      csync
01c0b5f2  2000                      csync
01c0b5f4  4024                      mov r0,#0x4
01c0b5f6  7191                      call 0x01c0b5da
01c0b5f8  4031                      mov r0,#0x11
01c0b5fa  bfea35fe                  call 0x01c0b268
01c0b5fe  0416                      mov r4,r0
01c0b600  4032                      mov r0,#0x12
01c0b602  bfea31fe                  call 0x01c0b268
01c0b606  2000                      csync
01c0b608  5160                      lw r1,[r5 + 0x0]
01c0b60a  f93f                      add r1,#-0x1
01c0b60c  d160                      sw r1,[r5 + 0x0]
01c0b610  0000                      nop
01c0b612  6100                      sti
01c0b614  00a8                      lsl r0,r0,0x8
01c0b616  4019                      or r0,r4
01c0b618  2000                      csync
01c0b61a  5504                      pop {pc,0x5}

;===== FUNC_01c0b61c  (called 4x) =====
01c0b61c  7504                      push {0x5}
01c0b61e  2416                      mov r4,r2
01c0b620  0048                      jz r0,0x01c0b632
01c0b622  10a4                      lsl r0,r1,0x4
01c0b624  c1ff81b00000              mov r1,#0xb081
01c0b62c  0941                      lb.z r1,[r0 + 0x1]
01c0b62e  2000                      csync
01c0b630  5504                      pop {pc,0x5}
01c0b632  2000                      csync
01c0b634  6000                      cli
01c0b636  c5fffc02c101              mov r5,#0x1c102fc
01c0b63e  0150                      jz r1,0x01c0b660
01c0b640  2000                      csync
01c0b642  2000                      csync
01c0b644  1016                      mov r0,r1
01c0b646  6189                      call 0x01c0b5da
01c0b648  4117                      uxtb r1,r4
01c0b64a  4031                      mov r0,#0x11
01c0b64c  bfeabcfd                  call 0x01c0b1c8
01c0b650  c1a8                      lsr r1,r4,0x8
01c0b652  4032                      mov r0,#0x12
01c0b654  bfeab8fd                  call 0x01c0b1c8
01c0b658  2000                      csync
01c0b65a  5060                      lw r0,[r5 + 0x0]
01c0b65c  f83f                      add r0,#-0x1
01c0b65e  d060                      sw r0,[r5 + 0x0]
01c0b662  0000                      nop
01c0b664  6100                      sti
01c0b666  2000                      csync
01c0b668  5504                      pop {pc,0x5}

;===== FUNC_01c0b66a  (called 2x) =====
01c0b66a  7504                      push {0x5}
01c0b66c  c3ff1404c101              mov r3,#0x1c10414
01c0b674  3a40                      lb.z r2,[r3 + 0x0]
01c0b676  144c                      jz r4,0x01c0b6d0
01c0b678  0049                      jz r0,0x01c0b68c
01c0b67a  0156                      jz r1,0x01c0b6a8
01c0b67c  f93f                      add r1,#-0x1
01c0b67e  14a3                      lsl r4,r1,0x3
01c0b680  45e0085a                  movz r5,#0x5a08
01c0b686  4b25                      mov r3,#0x25
01c0b688  2000                      csync
01c0b68a  049d                      goto 0x01c0b6c6
01c0b68c  c4ffacd4c001              mov r4,#0x1c0d4ac
01c0b692  014c                      jz r1,0x01c0b6ac
01c0b696  4a40                      lb.z r2,[r4 + 0x0]
01c0b69c  c26e                      sw r2,[r4 + 0x38]
01c0b69e  2000                      csync
01c0b6a4  8265                      sw r2,[r0 + 0x14]
01c0b6a6  5504                      pop {pc,0x5}
01c0b6a8  c260                      sw r2,[r4 + 0x0]
01c0b6aa  5504                      pop {pc,0x5}
01c0b6b0  9266                      sw r2,[r1 + 0x18]
01c0b6b2  2000                      csync
01c0b6b8  8260                      sw r2,[r0 + 0x0]
01c0b6ba  5504                      pop {pc,0x5}
01c0b6bc  f93f                      add r1,#-0x1
01c0b6be  15a3                      lsl r5,r1,0x3
01c0b6c0  5418                      add r4,r5
01c0b6c2  c267                      sw r2,[r4 + 0x1c]
01c0b6c4  2000                      csync
01c0b6ca  c028                      add r0,#0x8
01c0b6d0  5504                      pop {pc,0x5}

;===== FUNC_01c0b6d2  (called 1x) =====
01c0b6d2  7c04                      push {0xc}
01c0b6d4  ccffc003c101              mov r12,#0x1c103c0
01c0b6dc  c415                      mov r4_r5,r12_r13
01c0b6de  0a16                      mov r10,r0
01c0b6e0  014d                      jz r1,0x01c0b6fc
01c0b6e4  1495                      goto 0x01c0b750
01c0b6e8  1481                      goto 0x01c0b72c
01c0b6f0  a019                      not r0,r2
01c0b6f2  11a1                      lsl r1,r1,0x1
01c0b6f4  1018                      add r0,r1
01c0b6f8  c800                      call r8
01c0b6fa  0484                      goto 0x01c0b704
01c0b700  0c94                      add r4,r0,#0x14
01c0b702  8814                      clr r8_r9
01c0b704  cbff34180100              mov r11,#0x11834
01c0b70a  45e00240                  movz r5,#0x4002
01c0b714  2d40                      lb.z r5,[r2 + 0x0]
01c0b716  bfea63ff                  call 0x01c0b5e0
01c0b71a  0616                      mov r6,r0
01c0b722  6205                      lw r2,[r6 ++= 4]
01c0b728  6817                      sxtb r0,r6
01c0b730  8060                      sw r0,[r0 + 0x0]
01c0b732  4020                      mov r0,#0x0
01c0b734  4124                      mov r1,#0x4
01c0b736  7216                      mov r2,r7
01c0b738  bfea70ff                  call 0x01c0b61c
01c0b73e  e771                      sw r7,[r6 + -0x3c]
01c0b740  0498                      goto 0x01c0b772
01c0b742  4020                      mov r0,#0x0
01c0b744  4124                      mov r1,#0x4
01c0b746  8216                      mov r2,r8
01c0b748  4190                      call 0x01c0b66a
01c0b74a  9616                      mov r6,r9
01c0b750  a616                      mov r6,r10
01c0b754  b160                      sw r1,[r3 + 0x0]
01c0b756  2000                      csync
01c0b758  bfea42ff                  call 0x01c0b5e0
01c0b75e  0100                      idle
01c0b760  4020                      mov r0,#0x0
01c0b762  4124                      mov r1,#0x4
01c0b764  bfea5aff                  call 0x01c0b61c
01c0b76a  a2a6                      lsr r2,r2,0x6
01c0b770  5c04                      pop {pc,0xc}
01c0b774  0170                      lw r1,[r0 + -0x40]
01c0b776  4020                      mov r0,#0x0
01c0b778  4124                      mov r1,#0x4
01c0b77a  3c04                      pop {rets,0xc}
01c0b77c  a78f                      goto 0x01c0b61c

;===== FUNC_01c0b77e  (called 2x) =====
01c0b77e  7404                      push {0x4}
01c0b780  c4ff1203c101              mov r4,#0x1c10312
01c0b786  4840                      lb.z r0,[r4 + 0x0]
01c0b78a  0a02                      pfetch [r10]
01c0b78c  c0ffc003c101              mov r0,#0x1c103c0
01c0b792  0064                      lw r0,[r0 + 0x10]
01c0b794  bfea1eff                  call 0x01c0b5d4
01c0b798  0043                      jz r0,0x01c0b7a0
01c0b79a  419b                      call 0x01c0b6d2
01c0b79c  4020                      mov r0,#0x0
01c0b79e  c840                      sb r0,[r4 + 0x0]
01c0b7a0  5404                      pop {pc,0x4}

;===== FUNC_01c0b7a2  (called 2x) =====
01c0b7a2  7504                      push {0x5}
01c0b7a4  e29c                      add sp,#-0x10
01c0b7a6  c5ffc003c101              mov r5,#0x1c103c0
01c0b7ac  4321                      mov r3,#0x1
01c0b7ae  db42                      sb r3,[r5 + 0x2]
01c0b7b4  d26a                      sw r2,[r5 + 0x28]
01c0b7b6  4220                      mov r2,#0x0
01c0b7bc  5339                      mov r3,#0x59
01c0b7c2  4b30                      mov r3,#0x30
01c0b7c8  4328                      mov r3,#0x8
01c0b7de  82a8                      lsr r2,r0,0x8
01c0b7e4  82b0                      lsr r2,r0,0x10
01c0b7ea  80b8                      lsr r0,r0,0x18
01c0b7f4  90a8                      lsr r0,r1,0x8
01c0b7fa  90b0                      lsr r0,r1,0x10
01c0b800  8c81                      add r4,sp,#0x1
01c0b802  4886                      add r0,r4,#0x6
01c0b804  4128                      mov r1,#0x8
01c0b806  bfeabdfe                  call 0x01c0b584
01c0b80e  412f                      mov r1,#0xf
01c0b810  4220                      mov r2,#0x0
01c0b812  4016                      mov r0,r4
01c0b814  bfeac1fe                  call 0x01c0b59a
01c0b818  0481                      goto 0x01c0b81c
01c0b81a  5191                      call 0x01c0b77e
01c0b81c  5842                      lb.z r0,[r5 + 0x2]
01c0b81e  f05d                      jnz r0,0x01c0b81a
01c0b820  0284                      add sp,#0x10
01c0b822  5504                      pop {pc,0x5}

;===== FUNC_01c0b824  (called 1x) =====
01c0b824  7504                      push {0x5}
01c0b826  c5ff7003c101              mov r5,#0x1c10370
01c0b82e  5260                      lw r2,[r5 + 0x0]
01c0b830  0316                      mov r3,r0
01c0b832  2016                      mov r0,r2
01c0b834  3216                      mov r2,r3
01c0b836  5195                      call 0x01c0b7a2
01c0b83a  0054                      jz r0,0x01c0b864
01c0b83c  4016                      mov r0,r4
01c0b83e  5504                      pop {pc,0x5}

;===== FUNC_01c0b840  (called 13x) =====
01c0b840  1004                      push rets
01c0b842  1016                      mov r0,r1
01c0b844  2116                      mov r1,r2
01c0b846  718e                      call 0x01c0b824
01c0b848  8017                      uxth r0,r0
01c0b84a  0004                      pop pc

;===== FUNC_01c0b84c  (called 10x) =====
01c0b84c  1004                      push rets
01c0b84e  80eace0c                  call 0x01c0d1ee
01c0b852  0116                      mov r1,r0
01c0b854  4021                      mov r0,#0x1
01c0b858  0000                      nop
01c0b85a  4020                      mov r0,#0x0
01c0b85c  0004                      pop pc

;===== FUNC_01c0b85e  (called 2x) =====
01c0b85e  7404                      push {0x4}
01c0b860  c1ff7e03c101              mov r1,#0x1c1037e
01c0b866  1860                      lh.z r0,[r1 + 0x0]
01c0b868  02a1                      lsl r2,r0,0x1
01c0b86a  c3ffdeef0100              mov r3,#0x1efde
01c0b870  b219                      not r2,r3
01c0b872  83af                      lsr r3,r0,0xf
01c0b874  3219                      or r2,r3
01c0b876  84ab                      lsr r4,r0,0xb
01c0b878  3c19                      xor r4,r3
01c0b87a  44ac                      lsl r4,r4,0xc
01c0b87e  804d                      jnz r0,0x01c0b89a
01c0b880  4219                      or r2,r4
01c0b882  80a4                      lsr r0,r0,0x4
01c0b884  3819                      xor r0,r3
01c0b886  00a5                      lsl r0,r0,0x5
01c0b88a  2000                      csync
01c0b88c  0219                      or r2,r0
01c0b890  9a60                      sh r2,[r1 + 0x0]
01c0b892  5404                      pop {pc,0x4}

;===== FUNC_01c0b894  (called 2x) =====
01c0b894  7404                      push {0x4}
01c0b896  0216                      mov r2,r0
01c0b898  80ea6524                  call 0x01c10166
01c0b89c  c0ff00350100              mov r0,#0x13500
01c0b8a2  8261                      sw r2,[r0 + 0x4]
01c0b8a4  0148                      jz r1,0x01c0b8b6
01c0b8a6  c2ffd015c101              mov r2,#0x1c115d0
01c0b8ac  f93f                      add r1,#-0x1
01c0b8b0  2307                      lb.z r3,[r2 ++= 2]
01c0b8b2  8360                      sw r3,[r0 + 0x0]
01c0b8b4  f45b                      jnz r4,0x01c0b8ac
01c0b8b6  2000                      csync
01c0b8b8  0261                      lw r2,[r0 + 0x4]
01c0b8ba  80ea5d24                  call 0x01c10178
01c0b8be  a017                      uxth r0,r2
01c0b8c0  5404                      pop {pc,0x4}

;===== FUNC_01c0b8c2  (called 15x) =====
01c0b8c2  7d04                      push {0xd}
01c0b8c4  3d16                      mov r13,r3
01c0b8c6  1516                      mov r5,r1
01c0b8c8  0816                      mov r8,r0
01c0b8ca  124c                      jz r2,0x01c0b924
01c0b8ce  2cb0                      qasl r4,r2,0x10
01c0b8d2  ffb3                      qasr r7,r7,0x13
01c0b8d4  c9ff7e03c101              mov r9,#0x1c1037e
01c0b8e8  5940                      lb.z r1,[r5 + 0x0]
01c0b8ea  1819                      xor r0,r1
01c0b8ee  4020                      mov r0,#0x0
01c0b8f0  d840                      sb r0,[r5 + 0x0]
01c0b8f4  0007                      lb.z r0,[r0 ++= 2]
01c0b8f6  c716                      mov r7,r12
01c0b8fa  0e02                      pfetch [r14]
01c0b900  a016                      mov r0,r10
01c0b904  0001                      tbb r0
01c0b906  1016                      mov r0,r1
01c0b908  0e82                      add r6,r0,#0x2
01c0b90a  5c81                      add r4,r5,#0x1
01c0b90c  5188                      call 0x01c0b85e
01c0b90e  4940                      lb.z r1,[r4 + 0x0]
01c0b910  1819                      xor r0,r1
01c0b912  c621                      add r6,#0x1
01c0b914  c007                      sb r0,[r4 ++= 1]
01c0b916  f65a                      jnz r6,0x01c0b90c
01c0b918  7d18                      add r13,r7
01c0b91c  c227                      add r2,#0x7
01c0b91e  a017                      uxth r0,r2
01c0b920  7518                      add r5,r7
01c0b922  e05b                      jnz r0,0x01c0b8da
01c0b924  5d04                      pop {pc,0xd}

;===== FUNC_01c0b926  (called 5x) =====
01c0b926  7704                      push {0x7}
01c0b928  c7ffc003c101              mov r7,#0x1c103c0
01c0b930  783a                      mov r0,#0xfa
01c0b932  2516                      mov r5,r2
01c0b934  1416                      mov r4,r1
01c0b936  0616                      mov r6,r0
01c0b938  4134                      mov r1,#0x14
01c0b93a  3016                      mov r0,r3
01c0b93c  bfea4bfb                  call 0x01c0afd6
01c0b940  004c                      jz r0,0x01c0b95a
01c0b942  8662                      sw r6,[r0 + 0x8]
01c0b944  8563                      sw r5,[r0 + 0xc]
01c0b946  8464                      sw r4,[r0 + 0x10]
01c0b94a  7019                      or r0,r7
01c0b94c  9061                      sw r0,[r1 + 0x4]
01c0b950  9070                      sw r0,[r1 + -0x40]
01c0b952  8160                      sw r1,[r0 + 0x0]
01c0b954  8161                      sw r1,[r0 + 0x4]
01c0b95a  5704                      pop {pc,0x7}

;===== FUNC_01c0b95c  (called 6x) =====
01c0b95c  7904                      push {0x9}
01c0b95e  c7ffc003c101              mov r7,#0x1c103c0
01c0b966  783a                      mov r0,#0xfa
01c0b968  2616                      mov r6,r2
01c0b96a  1416                      mov r4,r1
01c0b96c  0816                      mov r8,r0
01c0b96e  4134                      mov r1,#0x14
01c0b970  3016                      mov r0,r3
01c0b972  bfea30fb                  call 0x01c0afd6
01c0b976  105f                      jz r0,0x01c0b9f6
01c0b978  7116                      mov r1,r7
01c0b984  741a                      lsl r4,r7
01c0b986  1364                      lw r3,[r1 + 0x10]
01c0b988  1563                      lw r5,[r1 + 0xc]
01c0b98a  3518                      add r5,r3
01c0b98e  1250                      jz r2,0x01c0b9f0
01c0b992  6094                      rep 0xe,0x14
01c0b99a  1850                      lb.z r0,[r1 + -0x10]
01c0b99e  2b90                      add r3,r2,#0x10
01c0b9a2  9265                      sw r2,[r1 + 0x14]
01c0b9aa  2085                      rep 0x6,0x5
01c0b9ac  5416                      mov r4,r5
01c0b9ae  0482                      goto 0x01c0b9b4
01c0b9b2  741a                      lsl r4,r7
01c0b9b6  0980                      add r1,r0,#0x0
01c0b9ba  a070                      sw r0,[r2 + -0x40]
01c0b9bc  8464                      sw r4,[r0 + 0x10]
01c0b9be  8663                      sw r6,[r0 + 0xc]
01c0b9c4  8260                      sw r2,[r0 + 0x0]
01c0b9c6  8161                      sw r1,[r0 + 0x4]
01c0b9c8  9060                      sw r0,[r1 + 0x0]
01c0b9ca  5904                      pop {pc,0x9}
01c0b9cc  2164                      lw r1,[r2 + 0x10]
01c0b9d0  0790                      goto 0x01c0b5f2
01c0b9d6  2363                      lw r3,[r2 + 0xc]
01c0b9d8  1318                      add r3,r1
01c0b9dc  0c90                      add r4,r0,#0x10
01c0b9de  161f                      sub r6,r1,r4
01c0b9e2  0980                      add r1,r0,#0x0
01c0b9e6  a070                      sw r0,[r2 + -0x40]
01c0b9e8  8464                      sw r4,[r0 + 0x10]
01c0b9ea  8663                      sw r6,[r0 + 0xc]
01c0b9ec  a061                      sw r0,[r2 + 0x4]
01c0b9ee  8260                      sw r2,[r0 + 0x0]
01c0b9f0  8161                      sw r1,[r0 + 0x4]
01c0b9f6  5904                      pop {pc,0x9}
01c0b9f8  7604                      push {0x6}
01c0b9fa  0416                      mov r4,r0
01c0b9fc  2443                      jz r4,0x01c0ba84
01c0b9fe  437d                      lw r3,[r4 + -0xc]
01c0ba00  2000                      csync
01c0ba02  6000                      cli
01c0ba04  c5fffc02c101              mov r5,#0x1c102fc
01c0ba0c  0150                      jz r1,0x01c0ba2e
01c0ba0e  2000                      csync
01c0ba10  2000                      csync
01c0ba16  bfea97fa                  call 0x01c0af48
01c0ba1a  407e                      lw r0,[r4 + -0x8]
01c0ba1c  c328                      add r3,#0x8
01c0ba20  ec4f                      sb r4,[r6 + 0xf]
01c0ba22  c07d                      sw r0,[r4 + -0xc]
01c0ba24  3216                      mov r2,r3
01c0ba26  2260                      lw r2,[r2 + 0x0]
01c0ba30  2162                      lw r1,[r2 + 0x8]
01c0ba32  2118                      add r1,r2
01c0ba38  049d                      goto 0x01c0ba74
01c0ba3a  3116                      mov r1,r3
01c0ba3c  bfeaa1f8                  call 0x01c0ab82
01c0ba40  0483                      goto 0x01c0ba48
01c0ba42  2161                      lw r1,[r2 + 0x4]
01c0ba44  bfea98f8                  call 0x01c0ab78
01c0ba48  4620                      mov r6,#0x0
01c0ba4a  3416                      mov r4,r3
01c0ba4c  0481                      goto 0x01c0ba50
01c0ba4e  0616                      mov r6,r0
01c0ba50  4460                      lw r4,[r4 + 0x0]
01c0ba54  0f40                      lb.z r7,[r0 + 0x0]
01c0ba56  4016                      mov r0,r4
01c0ba58  765a                      jz r6,0x01c0ba4e
01c0ba5a  6162                      lw r1,[r6 + 0x8]
01c0ba5c  6a1c                      add r2,r6,r1
01c0ba60  f621                      add r6,#-0x3f
01c0ba62  4062                      lw r0,[r4 + 0x8]
01c0ba64  1018                      add r0,r1
01c0ba66  e062                      sw r0,[r6 + 0x8]
01c0ba6a  4000                      lockclr
01c0ba6c  bfea6cfa                  call 0x01c0af48
01c0ba70  6016                      mov r0,r6
01c0ba72  f78d                      goto 0x01c0ba4e
01c0ba74  2000                      csync
01c0ba76  5060                      lw r0,[r5 + 0x0]
01c0ba78  f83f                      add r0,#-0x1
01c0ba7a  d060                      sw r0,[r5 + 0x0]
01c0ba7e  0000                      nop
01c0ba80  6100                      sti
01c0ba82  2000                      csync
01c0ba84  5604                      pop {pc,0x6}

;===== FUNC_01c0ba86  (called 2x) =====
01c0ba86  d798                      goto 0x01c0b9f8

;===== FUNC_01c0ba88  (called 2x) =====
01c0ba88  7404                      push {0x4}
01c0ba8a  c4ffc003c101              mov r4,#0x1c103c0
01c0ba92  4239                      mov r2,#0x19
01c0ba96  0044                      jz r0,0x01c0baa0
01c0ba98  783f                      mov r0,#0xff
01c0ba9a  5404                      pop {pc,0x4}
01c0ba9c  3462                      lw r4,[r3 + 0x8]
01c0ba9e  8460                      sw r4,[r0 + 0x0]
01c0baa0  3063                      lw r0,[r3 + 0xc]
01c0baa2  a060                      sw r0,[r2 + 0x0]
01c0baa4  3064                      lw r0,[r3 + 0x10]
01c0baa6  9060                      sw r0,[r1 + 0x0]
01c0baa8  3061                      lw r0,[r3 + 0x4]
01c0baaa  0045                      jz r0,0x01c0bab6
01c0baac  3160                      lw r1,[r3 + 0x0]
01c0bab0  0040                      jz r0,0x01c0bab2
01c0bab2  9061                      sw r0,[r1 + 0x4]
01c0bab4  8160                      sw r1,[r0 + 0x0]
01c0bab8  b360                      sw r3,[r3 + 0x0]
01c0baba  b361                      sw r3,[r3 + 0x4]
01c0babc  7184                      call 0x01c0ba86
01c0babe  4020                      mov r0,#0x0
01c0bac0  5404                      pop {pc,0x4}

;===== FUNC_01c0bac2  (called 3x) =====
01c0bac2  7804                      push {0x8}
01c0bac4  c4ffc003c101              mov r4,#0x1c103c0
01c0bacc  405a                      jz r0,0x01c0ba02
01c0bace  0119                      or r1,r0
01c0bad0  2119                      or r1,r2
01c0bad2  3616                      mov r6,r3
01c0bad4  8157                      jnz r1,0x01c0bb04
01c0bad6  8656                      jnz r6,0x01c0bb04
01c0bada  a040                      jnz r0,0x01c0bb5c
01c0badc  c014                      clr r8
01c0bae0  3e50                      lb.z r6,[r3 + -0x10]
01c0bae2  5061                      lw r0,[r5 + 0x4]
01c0bae4  0045                      jz r0,0x01c0baf0
01c0bae6  5160                      lw r1,[r5 + 0x0]
01c0baea  0040                      jz r0,0x01c0baec
01c0baec  9061                      sw r0,[r1 + 0x4]
01c0baee  8160                      sw r1,[r0 + 0x0]
01c0baf2  d560                      sw r5,[r5 + 0x0]
01c0baf4  d561                      sw r5,[r5 + 0x4]
01c0baf6  6187                      call 0x01c0ba86
01c0baf8  4016                      mov r0,r4
01c0bafc  025a                      jz r2,0x01c0bb32
01c0bb00  f051                      jnz r0,0x01c0bae4
01c0bb02  148d                      goto 0x01c0bb5e
01c0bb06  a040                      jnz r0,0x01c0bb88
01c0bb08  c014                      clr r8
01c0bb0c  2850                      lb.z r0,[r2 + -0x10]
01c0bb0e  0649                      jz r6,0x01c0bb22
01c0bb10  5163                      lw r1,[r5 + 0xc]
01c0bb12  5064                      lw r0,[r5 + 0x10]
01c0bb14  5a88                      add r2,r5,#0x8
01c0bb16  c600                      call r6
01c0bb18  805c                      jnz r0,0x01c0bb52
01c0bb1a  5560                      lw r5,[r5 + 0x0]
01c0bb1e  f851                      sb r0,[r7 + -0xf]
01c0bb20  049e                      goto 0x01c0bb5e
01c0bb24  441a                      lsl r4,r4
01c0bb2a  231c                      add r3,r2,r0
01c0bb2c  1464                      lw r4,[r1 + 0x10]
01c0bb2e  1563                      lw r5,[r1 + 0xc]
01c0bb32  0440                      jz r4,0x01c0bb34
01c0bb36  0f40                      lb.z r7,[r0 + 0x0]
01c0bb38  5418                      add r4,r5
01c0bb3a  0483                      goto 0x01c0bb42
01c0bb3c  5418                      add r4,r5
01c0bb40  0a40                      lb.z r2,[r0 + 0x0]
01c0bb44  0240                      jz r2,0x01c0bb46
01c0bb4a  1161                      lw r1,[r1 + 0x4]
01c0bb50  0486                      goto 0x01c0bb5e
01c0bb52  0816                      mov r8,r0
01c0bb54  0484                      goto 0x01c0bb5e
01c0bb56  2816                      mov r8,r2
01c0bb58  0482                      goto 0x01c0bb5e
01c0bb5e  8016                      mov r0,r8
01c0bb60  5804                      pop {pc,0x8}

;===== FUNC_01c0bb62  (called 1x) =====
01c0bb62  7704                      push {0x7}
01c0bb64  e29c                      add sp,#-0x10
01c0bb66  888c                      add r0,sp,#0xc
01c0bb68  80ea3b12                  call 0x01c0dfe2
01c0bb6c  0047                      jz r0,0x01c0bb7c
01c0bb6e  80ea431e                  call 0x01c0f7f8
01c0bb72  005f                      jz r0,0x01c0bbb2
01c0bb74  80eab61b                  call 0x01c0f2e4
01c0bb7a  049c                      goto 0x01c0bbb4
01c0bb82  80ea4415                  call 0x01c0e60e
01c0bb86  f053                      jnz r0,0x01c0bb6e
01c0bb8a  c5ff90d5c001              mov r5,#0x1c0d590
01c0bb90  c721                      add r7,#0x1
01c0bb92  4420                      mov r4,#0x0
01c0bb94  074f                      jz r7,0x01c0bbb4
01c0bb96  8e80                      add r6,sp,#0x0
01c0bb9a  7004                      push {0x0}
01c0bb9c  4128                      mov r1,#0x8
01c0bb9e  6216                      mov r2,r6
01c0bba0  bfeafffd                  call 0x01c0b7a2
01c0bba4  4228                      mov r2,#0x8
01c0bba6  6016                      mov r0,r6
01c0bba8  5116                      mov r1,r5
01c0bbaa  80ea200b                  call 0x01c0d1ee
01c0bbae  f050                      jnz r0,0x01c0bb90
01c0bbb0  0481                      goto 0x01c0bbb4
01c0bbb4  4016                      mov r0,r4
01c0bbb6  0284                      add sp,#0x10
01c0bbb8  5704                      pop {pc,0x7}
01c0bbba  80ea2f14                  call 0x01c0e41c
01c0bbbe  e057                      jnz r0,0x01c0bb6e
01c0bbc0  4020                      mov r0,#0x0
01c0bbc4  8888                      add r0,sp,#0x8
01c0bbc6  80eaa515                  call 0x01c0e714
01c0bbcc  011a                      lsl r1,r0
01c0bbce  e04f                      jnz r0,0x01c0bb6e
01c0bbd2  0049                      jz r0,0x01c0bbe6
01c0bbd4  80eaaf18                  call 0x01c0ed36
01c0bbd8  e04a                      jnz r0,0x01c0bb6e
01c0bbda  80eaf119                  call 0x01c0efc0
01c0bbde  e047                      jnz r0,0x01c0bb6e
01c0bbe0  80ea651b                  call 0x01c0f2ae
01c0bbe4  e790                      goto 0x01c0bb86
01c0bbe6  402e                      mov r0,#0xe
01c0bbe8  e782                      goto 0x01c0bb6e

;===== FUNC_01c0bbea  (called 1x) =====
01c0bbea  7404                      push {0x4}
01c0bbec  bfeaacfc                  call 0x01c0b548
01c0bbf0  c4ffc003c101              mov r4,#0x1c103c0
01c0bbf6  0482                      goto 0x01c0bbfc
01c0bbf8  bfeac1fd                  call 0x01c0b77e
01c0bbfc  bfea69f8                  call 0x01c0acd2
01c0bc00  4841                      lb.z r0,[r4 + 0x1]
01c0bc04  f903                      rep 0x20,r9
01c0bc06  518d                      call 0x01c0bb62
01c0bc08  f057                      jnz r0,0x01c0bbf8
01c0bc0a  4020                      mov r0,#0x0
01c0bc0c  c841                      sb r0,[r4 + 0x1]
01c0bc0e  5404                      pop {pc,0x4}

;===== FUNC_01c0bc10  (called 2x) =====
01c0bc10  7504                      push {0x5}
01c0bc12  0416                      mov r4,r0
01c0bc14  bfea77f8                  call 0x01c0ad06
01c0bc18  c1ffa8d1c001              mov r1,#0x1c0d1a8
01c0bc1e  4025                      mov r0,#0x5
01c0bc20  4221                      mov r2,#0x1
01c0bc22  80ea0323                  call 0x01c1022c
01c0bc26  4020                      mov r0,#0x0
01c0bc2c  c021                      add r0,#0x1
01c0bc30  fb17                      sxth r3,r7
01c0bc32  c1ff70d4c001              mov r1,#0x1c0d470
01c0bc40  4320                      mov r3,#0x0
01c0bc42  c5ff00050100              mov r5,#0x10500
01c0bc48  d360                      sw r3,[r5 + 0x0]
01c0bc4a  d361                      sw r3,[r5 + 0x4]
01c0bc4e  805c                      jnz r0,0x01c0bc88
01c0bc50  c3ff00d01213              mov r3,#0x1312d000
01c0bc58  3022                      bitset r0,0x2
01c0bc5a  43e0f401                  movz r3,#0x1f4
01c0bc62  1018                      add r0,r1
01c0bc70  d162                      sw r1,[r5 + 0x8]
01c0bc72  00a4                      lsl r0,r0,0x4
01c0bc76  0050                      jz r0,0x01c0bc98
01c0bc7a  0150                      jz r1,0x01c0bc9c
01c0bc7c  5196                      call 0x01c0bbea
01c0bc80  0140                      jz r1,0x01c0bc82
01c0bc82  c0ff7c03c101              mov r0,#0x1c1037c
01c0bc88  0860                      lh.z r0,[r0 + 0x0]
01c0bc8c  045f                      jz r4,0x01c0bccc
01c0bc8e  c862                      sh r0,[r4 + 0x4]
01c0bc92  0100                      idle
01c0bc94  c0ff1c100500              mov r0,#0x5101c
01c0bc9e  2000                      csync
01c0bca0  6000                      cli
01c0bca2  c0fffc02c101              mov r0,#0x1c102fc
01c0bcaa  0100                      idle
01c0bcac  2000                      csync
01c0bcae  5504                      pop {pc,0x5}

;===== FUNC_01c0bcb0  (called 1x) =====
01c0bcb0  7804                      push {0x8}
01c0bcb2  0516                      mov r5,r0
01c0bcb4  5c82                      add r4,r5,#0x2
01c0bcb6  512e                      mov r1,#0x4e
01c0bcba  5e60                      lh.z r6,[r5 + 0x0]
01c0bcbc  bfea21f6                  call 0x01c0a902
01c0bcc2  0a60                      lh.z r2,[r0 + 0x0]
01c0bcc4  80ea9b0e                  call 0x01c0d9fe
01c0bcca  5e60                      lh.z r6,[r5 + 0x0]
01c0bccc  512e                      mov r1,#0x4e
01c0bcce  bfea18f6                  call 0x01c0a902
01c0bcd2  c014                      clr r8
01c0bcd6  2060                      lw r0,[r2 + 0x0]
01c0bcda  4c50                      lb.z r4,[r4 + -0x10]
01c0bcde  7e60                      lh.z r6,[r7 + 0x0]
01c0bce0  065b                      jz r6,0x01c0bd18
01c0bce2  d530                      add r5,#0x50
01c0bce6  7c61                      lh.z r4,[r7 + 0x2]
01c0bce8  6116                      mov r1,r6
01c0bcea  80ea7e0a                  call 0x01c0d1ea
01c0bcf0  1340                      jz r3,0x01c0bd32
01c0bcf2  7844                      lb.z r0,[r7 + 0x4]
01c0bcf6  0e02                      pfetch [r14]
01c0bcf8  5841                      lb.z r0,[r5 + 0x1]
01c0bcfa  0982                      add r1,r0,#0x2
01c0bd02  6017                      uxtb r0,r6
01c0bd04  1117                      uxtb r1,r1
01c0bd0a  1518                      add r5,r1
01c0bd0e  5a40                      lb.z r2,[r5 + 0x0]
01c0bd12  f203                      rep 0x20,r2
01c0bd16  0250                      jz r2,0x01c0bd38
01c0bd18  8016                      mov r0,r8
01c0bd1a  5804                      pop {pc,0x8}

;===== FUNC_01c0bd1c  (called 1x) =====
01c0bd1c  7404                      push {0x4}
01c0bd1e  c4ffc003c101              mov r4,#0x1c103c0
01c0bd24  4063                      lw r0,[r4 + 0xc]
01c0bd26  8049                      jnz r0,0x01c0bd3a
01c0bd28  c0ff88fdc701              mov r0,#0x1c7fd88
01c0bd2e  6180                      call 0x01c0bcb0
01c0bd30  c063                      sw r0,[r4 + 0xc]
01c0bd34  0040                      jz r0,0x01c0bd36
01c0bd36  4020                      mov r0,#0x0
01c0bd38  5404                      pop {pc,0x4}
01c0bd3a  0840                      lb.z r0,[r0 + 0x0]
01c0bd3c  5404                      pop {pc,0x4}

;===== FUNC_01c0bd3e  (called 1x) =====
01c0bd3e  c0ff40e2ee01              mov r0,#0x1eee240
01c0bd44  0160                      lw r1,[r0 + 0x0]
01c0bd48  0100                      idle
01c0bd4c  e700                      cli r7
01c0bd4e  8000                      rts
01c0bd50  c0ff40e2ee01              mov r0,#0x1eee240
01c0bd56  0160                      lw r1,[r0 + 0x0]
01c0bd5a  0100                      idle
01c0bd5e  e700                      cli r7
01c0bd60  8000                      rts

;===== FUNC_01c0bd62  (called 1x) =====
01c0bd62  1004                      push rets
01c0bd64  718c                      call 0x01c0bd3e
01c0bd66  c1ffffffff01              mov r1,#0x1ffffff
01c0bd6c  4020                      mov r0,#0x0
01c0bd6e  bfeae0f6                  call 0x01c0ab32
01c0bd74  f78d                      goto 0x01c0bd50

;===== FUNC_01c0bd76  (called 2x) =====
01c0bd76  ffeaf6f6                  goto 0x01c0ab66

;===== FUNC_01c0bd7a  (called 1x) =====
01c0bd7a  7404                      push {0x4}
01c0bd7c  618f                      call 0x01c0bd1c
01c0bd7e  805c                      jnz r0,0x01c0bdb8
01c0bd80  c4ffc003c101              mov r4,#0x1c103c0
01c0bd86  4063                      lw r0,[r4 + 0xc]
01c0bd88  8053                      jnz r0,0x01c0bdb0
01c0bd8a  80eada1a                  call 0x01c0f342
01c0bd8e  0050                      jz r0,0x01c0bdb0
01c0bd90  7188                      call 0x01c0bd62
01c0bd92  2000                      csync
01c0bd94  6000                      cli
01c0bd96  c0fffc02c101              mov r0,#0x1c102fc
01c0bd9e  0100                      idle
01c0bda0  2000                      csync
01c0bda2  4020                      mov r0,#0x0
01c0bda4  0483                      goto 0x01c0bdac
01c0bda6  80ea4622                  call 0x01c10236
01c0bdaa  c021                      add r0,#0x1
01c0bdb0  4840                      lb.z r0,[r4 + 0x0]
01c0bdb2  bfea9af6                  call 0x01c0aaea
01c0bdb6  619f                      call 0x01c0bd76
01c0bdb8  5404                      pop {pc,0x4}

;===== FUNC_01c0bdba  (called 1x) =====
01c0bdba  7404                      push {0x4}
01c0bdbc  c4ff80fdc701              mov r4,#0x1c7fd80
01c0bdc2  488a                      add r0,r4,#0xa
01c0bdc4  512e                      mov r1,#0x4e
01c0bdc6  bfea9cf5                  call 0x01c0a902
01c0bdca  0046                      jz r0,0x01c0bdd8
01c0bdcc  4964                      lh.z r1,[r4 + 0x8]
01c0bdd0  0300                      hbkpt
01c0bdd2  4966                      lh.z r1,[r4 + 0xc]
01c0bdd4  4021                      mov r0,#0x1
01c0bdd6  8141                      jnz r1,0x01c0bdda
01c0bdd8  4020                      mov r0,#0x0
01c0bdda  5404                      pop {pc,0x4}
01c0bddc  e29c                      add sp,#-0x10
01c0bdde  6034                      mov r0,#0x94
01c0bde0  4120                      mov r1,#0x0
01c0bde2  4420                      mov r4,#0x0
01c0bde4  bfea60f5                  call 0x01c0a8a8
01c0bdec  bfea97f5                  call 0x01c0a91e
01c0bdf0  4031                      mov r0,#0x11
01c0bdf2  bfeab8f5                  call 0x01c0a966
01c0bdfa  c8ffc003c101              mov r8,#0x1c103c0
01c0be02  8000                      rts
01c0be04  4027                      mov r0,#0x7
01c0be06  bfea70f6                  call 0x01c0aaea
01c0be0a  bfea93f6                  call 0x01c0ab34
01c0be0e  bfeaa3f6                  call 0x01c0ab58
01c0be12  80eaf41d                  call 0x01c0f9fe
01c0be16  c0ff5003c101              mov r0,#0x1c10350
01c0be1c  0866                      lh.z r0,[r0 + 0xc]
01c0be1e  bfea9df6                  call 0x01c0ab5c
01c0be22  bfead3f6                  call 0x01c0abcc
01c0be26  80ea390c                  call 0x01c0d69c
01c0be2a  888c                      add r0,sp,#0xc
01c0be2c  8988                      add r1,sp,#0x8
01c0be2e  80eaf80c                  call 0x01c0d822
01c0be34  0046                      jz r0,0x01c0be42
01c0be36  5832                      mov r0,#0x72
01c0be38  bfea03f7                  call 0x01c0ac42
01c0be3c  5832                      mov r0,#0x72
01c0be3e  bfea23f7                  call 0x01c0ac88
01c0be42  bfea31f7                  call 0x01c0aca8
01c0be46  80eab10d                  call 0x01c0d9ac
01c0be4a  40e0045a                  movz r0,#0x5a04
01c0be4e  bfea4af7                  call 0x01c0ace6
01c0be52  80eafb21                  call 0x01c1024c
01c0be56  bfea56f7                  call 0x01c0ad06
01c0be5a  80ead00d                  call 0x01c0d9fe
01c0be5e  bfea5ef5                  call 0x01c0a91e
01c0be62  0416                      mov r4,r0
01c0be66  7480                      goto 0x01c0c028
01c0be68  c1ff90fdc701              mov r1,#0x1c7fd90
01c0be6e  423b                      mov r2,#0x1b
01c0be70  80ead909                  call 0x01c0d226
01c0be74  80eafe0d                  call 0x01c0da74
01c0be78  1050                      jz r0,0x01c0beda
01c0be7a  4720                      mov r7,#0x0
01c0be7c  c6ffb403c101              mov r6,#0x1c103b4
01c0be82  049f                      goto 0x01c0bec2
01c0be84  5016                      mov r0,r5
01c0be86  bfea9cf7                  call 0x01c0adc2
01c0be8a  4121                      mov r1,#0x1
01c0be8c  5016                      mov r0,r5
01c0be8e  bfeacef7                  call 0x01c0ae2e
01c0be92  70a2                      lsl r0,r7,0x2
01c0be96  0058                      jz r0,0x01c0bec8
01c0be9a  5a06                      lh.z r2,[r5 --= 2]
01c0be9c  4120                      mov r1,#0x0
01c0be9e  bfea04f8                  call 0x01c0aeaa
01c0bea2  5824                      mov r0,#0x64
01c0bea4  bfeac1f5                  call 0x01c0aa2a
01c0beaa  7016                      mov r0,r7
01c0beac  5060                      lw r0,[r5 + 0x0]
01c0beae  bfeafcf7                  call 0x01c0aeaa
01c0beb2  5360                      lw r3,[r5 + 0x0]
01c0beb4  3016                      mov r0,r3
01c0beb6  bfea1af8                  call 0x01c0aeee
01c0beba  3016                      mov r0,r3
01c0bebc  bfea24f8                  call 0x01c0af08
01c0bec0  c721                      add r7,#0x1
01c0bec8  6880                      add r0,r6,#0x0
01c0becc  0a57                      lb.z r2,[r0 + -0x9]
01c0bece  e55a                      jnz r5,0x01c0be84
01c0bed0  0484                      goto 0x01c0beda
01c0bed2  bfea01f7                  call 0x01c0acd8
01c0bed6  bfea4eff                  call 0x01c0bd76
01c0bedc  0d02                      pfetch [r13]
01c0bede  4020                      mov r0,#0x0
01c0bee2  8880                      add r0,sp,#0x0
01c0bee4  bfea94fe                  call 0x01c0bc10
01c0bef0  0b02                      pfetch [r11]
01c0bef2  40e0045a                  movz r0,#0x5a04
01c0bef6  0496                      goto 0x01c0bf24
01c0bef8  4024                      mov r0,#0x4
01c0befc  8880                      add r0,sp,#0x0
01c0befe  bfea87fe                  call 0x01c0bc10
01c0bf06  0302                      pfetch [r3]
01c0bf08  40e0025a                  movz r0,#0x5a02
01c0bf0c  048b                      goto 0x01c0bf24
01c0bf0e  bfea54ff                  call 0x01c0bdba
01c0bf14  0040                      jz r0,0x01c0bf16
01c0bf16  40e0005a                  movz r0,#0x5a00
01c0bf1a  bfeae4f6                  call 0x01c0ace6
01c0bf1e  e799                      goto 0x01c0bed2
01c0bf20  40e0055a                  movz r0,#0x5a05
01c0bf24  bfeadff6                  call 0x01c0ace6
01c0bf28  bfea27ff                  call 0x01c0bd7a
01c0bf2c  e792                      goto 0x01c0bed2

;===== FUNC_01c0bf2e  (called 2x) =====
01c0bf2e  4020                      mov r0,#0x0
01c0bf34  c0ffc003c101              mov r0,#0x1c103c0
01c0bf40  0040                      jz r0,0x01c0bf42
01c0bf42  c820                      add r0,#0x20
01c0bf48  1016                      mov r0,r1
01c0bf4a  8000                      rts

;===== FUNC_01c0bf4c  (called 2x) =====
01c0bf4c  ffea0bf6                  goto 0x01c0ab66

;===== FUNC_01c0bf50  (called 1x) =====
01c0bf50  4020                      mov r0,#0x0
01c0bf56  c0ffc003c101              mov r0,#0x1c103c0
01c0bf62  0040                      jz r0,0x01c0bf64
01c0bf64  c838                      add r0,#0x38
01c0bf6a  1016                      mov r0,r1
01c0bf6c  8000                      rts
01c0bf6e  7704                      push {0x7}
01c0bf70  2416                      mov r4,r2
01c0bf72  1616                      mov r6,r1
01c0bf74  0516                      mov r5,r0
01c0bf76  c7ffbcd4c001              mov r7,#0x1c0d4bc
01c0bf7c  4229                      mov r2,#0x9
01c0bf7e  6015                      mov r0_r1,r6_r7
01c0bf80  80ea5109                  call 0x01c0d226
01c0bf84  4060                      lw r0,[r4 + 0x0]
01c0bf86  e842                      sb r0,[r6 + 0x2]
01c0bf88  6889                      add r0,r6,#0x9
01c0bf8a  7989                      add r1,r7,#0x9
01c0bf8c  4229                      mov r2,#0x9
01c0bf8e  80ea4a09                  call 0x01c0d226
01c0bf92  4060                      lw r0,[r4 + 0x0]
01c0bf94  c021                      add r0,#0x1
01c0bf9a  6892                      add r0,r6,#0x12
01c0bf9e  5770                      lw r7,[r5 + -0x40]
01c0bfa0  4230                      mov r2,#0x10
01c0bfa2  80ea4009                  call 0x01c0d226
01c0bfa6  4060                      lw r0,[r4 + 0x0]
01c0bfa8  c021                      add r0,#0x1
01c0bfb0  2260                      lw r2,[r2 + 0x0]
01c0bfb4  3970                      lh.z r1,[r3 + -0x20]
01c0bfb6  422f                      mov r2,#0xf
01c0bfb8  80ea3509                  call 0x01c0d226
01c0bfbe  3160                      lw r1,[r3 + 0x0]
01c0bfc2  4870                      lh.z r0,[r4 + -0x20]
01c0bfc4  422f                      mov r2,#0xf
01c0bfc6  80ea2e09                  call 0x01c0d226
01c0bfcc  4060                      lw r0,[r4 + 0x0]
01c0bfd0  7770                      lw r7,[r7 + -0x40]
01c0bfd2  423c                      mov r2,#0x1c
01c0bfd4  80ea2709                  call 0x01c0d226
01c0bfda  4160                      lw r1,[r4 + 0x0]
01c0bfdc  c2ff76c0c001              mov r2,#0x1c0c076
01c0bfe2  5185                      call 0x01c0bf2e
01c0bfe6  4260                      lw r2,[r4 + 0x0]
01c0bfee  0000                      nop
01c0bff2  0003                      rep 0x2,r0
01c0bff4  518b                      call 0x01c0bf4c
01c0bff6  4160                      lw r1,[r4 + 0x0]
01c0bff8  c2ff70c2c001              mov r2,#0x1c0c270
01c0bffe  5016                      mov r0,r5
01c0c000  5187                      call 0x01c0bf50
01c0c002  4060                      lw r0,[r4 + 0x0]
01c0c004  0981                      add r1,r0,#0x1
01c0c008  c160                      sw r1,[r4 + 0x0]
01c0c00a  c2ffbec2c001              mov r2,#0x1c0c2be
01c0c010  418e                      call 0x01c0bf2e
01c0c012  4160                      lw r1,[r4 + 0x0]
01c0c01a  0000                      nop
01c0c01e  0003                      rep 0x2,r0
01c0c020  4195                      call 0x01c0bf4c
01c0c022  4060                      lw r0,[r4 + 0x0]
01c0c024  0981                      add r1,r0,#0x1
01c0c026  503c                      mov r0,#0x5c
01c0c028  c160                      sw r1,[r4 + 0x0]
01c0c02a  5704                      pop {pc,0x7}

;===== FUNC_01c0c02c  (called 2x) =====
01c0c02c  8000                      rts

;===== FUNC_01c0c02e  (called 5x) =====
01c0c02e  8941                      sb r1,[r0 + 0x1]
01c0c030  8000                      rts

;===== FUNC_01c0c032  (called 4x) =====
01c0c032  7504                      push {0x5}
01c0c034  035c                      jz r3,0x01c0c06e
01c0c036  4421                      mov r4,#0x1
01c0c038  8c41                      sb r4,[r0 + 0x1]
01c0c03a  1d47                      lb.z r5,[r1 + 0x7]
01c0c03c  1946                      lb.z r1,[r1 + 0x6]
01c0c040  2054                      jz r0,0x01c0c0ea
01c0c042  0461                      lw r4,[r0 + 0x4]
01c0c044  8961                      sh r1,[r0 + 0x2]
01c0c046  8462                      sw r4,[r0 + 0x8]
01c0c048  4520                      mov r5,#0x0
01c0c04c  0083                      rep 0x2,0x3
01c0c04e  8b61                      sh r3,[r0 + 0x2]
01c0c050  3116                      mov r1,r3
01c0c052  4521                      mov r5,#0x1
01c0c056  0551                      jz r5,0x01c0c07a
01c0c05a  0b40                      lb.z r3,[r0 + 0x0]
01c0c05c  9317                      uxth r3,r1
01c0c062  4016                      mov r0,r4
01c0c064  2116                      mov r1,r2
01c0c066  3216                      mov r2,r3
01c0c068  80eadd08                  call 0x01c0d226
01c0c06c  0482                      goto 0x01c0c072
01c0c06e  4420                      mov r4,#0x0
01c0c070  8c41                      sb r4,[r0 + 0x1]
01c0c072  4016                      mov r0,r4
01c0c074  5504                      pop {pc,0x5}
01c0c076  7504                      push {0x5}
01c0c078  0216                      mov r2,r0
01c0c07a  2061                      lw r0,[r2 + 0x4]
01c0c07c  6197                      call 0x01c0c02c
01c0c080  1b41                      lb.z r3,[r1 + 0x1]
01c0c082  0346                      jz r3,0x01c0c090
01c0c088  4421                      mov r4,#0x1
01c0c08c  0916                      mov r9,r0
01c0c08e  048c                      goto 0x01c0c0a8
01c0c094  0485                      goto 0x01c0c0a0
01c0c096  1847                      lb.z r0,[r1 + 0x7]
01c0c098  1b46                      lb.z r3,[r1 + 0x6]
01c0c09e  0346                      jz r3,0x01c0c0ac
01c0c0a0  4123                      mov r1,#0x3
01c0c0a2  2016                      mov r0,r2
01c0c0a4  6184                      call 0x01c0c02e
01c0c0a6  4420                      mov r4,#0x0
01c0c0a8  4016                      mov r0,r4
01c0c0aa  5504                      pop {pc,0x5}
01c0c0b4  4420                      mov r4,#0x0
01c0c0b8  0206                      lh.z r2,[r0 ++= 2]
01c0c0bc  f505                      sw r5,[r7 ++= 4]
01c0c0be  4123                      mov r1,#0x3
01c0c0c0  2016                      mov r0,r2
01c0c0c2  5195                      call 0x01c0c02e
01c0c0c4  4020                      mov r0,#0x0
01c0c0c6  5504                      pop {pc,0x5}
01c0c0c8  4420                      mov r4,#0x0
01c0c0cc  dc40                      sb r4,[r5 + 0x0]
01c0c0ce  4321                      mov r3,#0x1
01c0c0d0  5216                      mov r2,r5
01c0c0d2  518f                      call 0x01c0c032
01c0c0d4  4020                      mov r0,#0x0
01c0c0d6  5504                      pop {pc,0x5}
01c0c0da  0401                      tbb r4
01c0c0dc  8000                      rts

;===== FUNC_01c0c0de  (called 2x) =====
01c0c0de  7504                      push {0x5}
01c0c0e0  13a2                      lsl r3,r1,0x2
01c0c0e6  c81c                      add r0,r4,r3
01c0c0e8  c3ffc003c101              mov r3,#0x1c103c0
01c0c0ee  3018                      add r0,r3
01c0c0f2  ac00                      swi 0x4
01c0c0f8  55a2                      lsl r5,r5,0x2
01c0c0fa  5418                      add r4,r5
01c0c0fc  4318                      add r3,r4
01c0c100  d430                      add r4,#0x50
01c0c102  1917                      sxtb r1,r1
01c0c106  0000                      nop
01c0c108  0316                      mov r3,r0
01c0c10a  4020                      mov r0,#0x0
01c0c10c  b260                      sw r2,[r3 + 0x0]
01c0c10e  5504                      pop {pc,0x5}

;===== FUNC_01c0c110  (called 5x) =====
01c0c110  7504                      push {0x5}
01c0c112  2416                      mov r4,r2
01c0c114  0048                      jz r0,0x01c0c126
01c0c116  10a4                      lsl r0,r1,0x4
01c0c118  c1ff83b00000              mov r1,#0xb083
01c0c120  0941                      lb.z r1,[r0 + 0x1]
01c0c122  2000                      csync
01c0c124  5504                      pop {pc,0x5}
01c0c126  2000                      csync
01c0c128  6000                      cli
01c0c12a  c5fffc02c101              mov r5,#0x1c102fc
01c0c132  0150                      jz r1,0x01c0c154
01c0c134  2000                      csync
01c0c136  2000                      csync
01c0c138  1016                      mov r0,r1
01c0c13a  bfea4efa                  call 0x01c0b5da
01c0c13e  4117                      uxtb r1,r4
01c0c140  4034                      mov r0,#0x14
01c0c142  bfea41f8                  call 0x01c0b1c8
01c0c146  c1a8                      lsr r1,r4,0x8
01c0c148  4035                      mov r0,#0x15
01c0c14a  bfea3df8                  call 0x01c0b1c8
01c0c14e  2000                      csync
01c0c150  5060                      lw r0,[r5 + 0x0]
01c0c152  f83f                      add r0,#-0x1
01c0c154  d060                      sw r0,[r5 + 0x0]
01c0c158  0000                      nop
01c0c15a  6100                      sti
01c0c15c  2000                      csync
01c0c15e  5504                      pop {pc,0x5}

;===== FUNC_01c0c160  (called 2x) =====
01c0c160  7804                      push {0x8}
01c0c162  2616                      mov r6,r2
01c0c164  0415                      mov r4_r5,r0_r1
01c0c166  c7ff1404c101              mov r7,#0x1c10414
01c0c16c  c8fffc02c101              mov r8,#0x1c102fc
01c0c176  bfeaf5f8                  call 0x01c0b364
01c0c17c  7a04                      push {0xa}
01c0c182  d038                      add r0,#0x58
01c0c184  f83c                      add r0,#-0x4
01c0c186  5120                      mov r1,#0x40
01c0c18a  0b15                      mov r10_r11,r0_r1
01c0c18c  1443                      jz r4,0x01c0c1d4
01c0c18e  50a4                      lsl r0,r5,0x4
01c0c190  c1ff82b00000              mov r1,#0xb082
01c0c196  42e0ff03                  movz r2,#0x3ff
01c0c19e  2000                      csync
01c0c1a0  1491                      goto 0x01c0c204
01c0c1a4  0f50                      lb.z r7,[r0 + -0x10]
01c0c1a6  5116                      mov r1,r5
01c0c1a8  bfea5ffa                  call 0x01c0b66a
01c0c1ae  7a04                      push {0xa}
01c0c1b4  d028                      add r0,#0x48
01c0c1b6  f83c                      add r0,#-0x4
01c0c1b8  5120                      mov r1,#0x40
01c0c1bc  0b15                      mov r10_r11,r0_r1
01c0c1be  1451                      jz r4,0x01c0c222
01c0c1c0  50a4                      lsl r0,r5,0x4
01c0c1c2  c1ff80b00000              mov r1,#0xb080
01c0c1c8  42e0ff03                  movz r2,#0x3ff
01c0c1d0  2000                      csync
01c0c1d2  149f                      goto 0x01c0c252
01c0c1d4  2000                      csync
01c0c1d6  6000                      cli
01c0c1da  0180                      call 0x01c0c1dc

;===== FUNC_01c0c1dc  (called 1x) =====
01c0c1dc  2000                      csync
01c0c1de  2000                      csync
01c0c1e0  5016                      mov r0,r5
01c0c1e2  bfeafaf9                  call 0x01c0b5da
01c0c1e6  4033                      mov r0,#0x13
01c0c1e8  41e0ff03                  movz r1,#0x3ff
01c0c1ec  bfeaecf7                  call 0x01c0b1c8
01c0c1f0  2000                      csync
01c0c1f4  8000                      rts
01c0c1f6  f83f                      add r0,#-0x1
01c0c1fa  8100                      rti
01c0c1fe  0000                      nop
01c0c200  6100                      sti
01c0c202  2000                      csync
01c0c204  6230                      mov r2,#0x90
01c0c206  4015                      mov r0_r1,r4_r5
01c0c208  4183                      call 0x01c0c110
01c0c20c  7a04                      push {0xa}
01c0c210  0080                      rep 0x2,0x0
01c0c212  c838                      add r0,#0x38
01c0c214  f83c                      add r0,#-0x4
01c0c218  0b65                      lh.z r3,[r0 + 0xa]
01c0c21a  4015                      mov r0_r1,r4_r5
01c0c21c  3804                      pop {rets,0x8}
01c0c21e  ffea0af9                  goto 0x01c0b436
01c0c222  2000                      csync
01c0c224  6000                      cli
01c0c228  0180                      call 0x01c0c22a

;===== FUNC_01c0c22a  (called 1x) =====
01c0c22a  2000                      csync
01c0c22c  2000                      csync
01c0c22e  5016                      mov r0,r5
01c0c230  bfead3f9                  call 0x01c0b5da
01c0c234  4030                      mov r0,#0x10
01c0c236  41e0ff03                  movz r1,#0x3ff
01c0c23a  bfeac5f7                  call 0x01c0b1c8
01c0c23e  2000                      csync
01c0c242  8000                      rts
01c0c244  f83f                      add r0,#-0x1
01c0c248  8100                      rti
01c0c24c  0000                      nop
01c0c24e  6100                      sti
01c0c250  2000                      csync
01c0c252  5228                      mov r2,#0x48
01c0c254  4015                      mov r0_r1,r4_r5
01c0c256  bfeae1f9                  call 0x01c0b61c
01c0c25a  4015                      mov r0_r1,r4_r5
01c0c25c  3804                      pop {rets,0x8}
01c0c25e  ffeab9f8                  goto 0x01c0b3d4
01c0c264  0040                      jz r0,0x01c0c266
01c0c26e  8000                      rts
01c0c270  7604                      push {0x6}
01c0c274  0701                      tbb r7
01c0c276  bfea2fff                  call 0x01c0c0d8
01c0c27a  c6ffc003c101              mov r6,#0x1c103c0
01c0c282  6564                      lw r5,[r6 + 0x10]
01c0c284  c2ff3ac3c001              mov r2,#0x1c0c33a
01c0c28a  6124                      mov r1,#0x84
01c0c28c  bfea27ff                  call 0x01c0c0de
01c0c290  6124                      mov r1,#0x84
01c0c292  4016                      mov r0,r4
01c0c294  5216                      mov r2,r5
01c0c296  bfea63ff                  call 0x01c0c160
01c0c29a  4016                      mov r0,r4
01c0c29c  7182                      call 0x01c0c262
01c0c2a0  6565                      lw r5,[r6 + 0x14]
01c0c2a2  c2ff38c7c001              mov r2,#0x1c0c738
01c0c2a8  4124                      mov r1,#0x4
01c0c2aa  bfea18ff                  call 0x01c0c0de
01c0c2ae  4124                      mov r1,#0x4
01c0c2b0  4016                      mov r0,r4
01c0c2b2  5216                      mov r2,r5
01c0c2b4  bfea54ff                  call 0x01c0c160
01c0c2b8  4016                      mov r0,r4
01c0c2ba  3604                      pop {rets,0x6}
01c0c2bc  e792                      goto 0x01c0c262
01c0c2be  7504                      push {0x5}
01c0c2c0  0216                      mov r2,r0
01c0c2c4  2061                      lw r0,[r2 + 0x4]
01c0c2c6  bfeab1fe                  call 0x01c0c02c
01c0c2cc  4941                      lb.z r1,[r4 + 0x1]
01c0c2ce  2894                      add r0,r2,#0x14
01c0c2d0  014c                      jz r1,0x01c0c2ea
01c0c2d8  2416                      mov r4,r2
01c0c2da  0840                      lb.z r0,[r0 + 0x0]
01c0c2e2  1b06                      lh.z r3,[r1 --= 2]
01c0c2e8  049c                      goto 0x01c0c322
01c0c2ea  0840                      lb.z r0,[r0 + 0x0]
01c0c2ec  0496                      goto 0x01c0c31a
01c0c2ee  4947                      lb.z r1,[r4 + 0x7]
01c0c2f0  4b46                      lb.z r3,[r4 + 0x6]
01c0c2f6  8351                      jnz r3,0x01c0c31a
01c0c2f8  0840                      lb.z r0,[r0 + 0x0]
01c0c300  0c06                      lh.z r4,[r0 --= 2]
01c0c306  048d                      goto 0x01c0c322
01c0c308  4120                      mov r1,#0x0
01c0c30a  2016                      mov r0,r2
01c0c30c  bfea8ffe                  call 0x01c0c02e
01c0c310  4843                      lb.z r0,[r4 + 0x3]
01c0c312  4942                      lb.z r1,[r4 + 0x2]
01c0c318  0144                      jz r1,0x01c0c322
01c0c31a  4123                      mov r1,#0x3
01c0c31c  2016                      mov r0,r2
01c0c31e  bfea86fe                  call 0x01c0c02e
01c0c322  4020                      mov r0,#0x0
01c0c324  5504                      pop {pc,0x5}
01c0c326  4020                      mov r0,#0x0
01c0c32a  d840                      sb r0,[r5 + 0x0]
01c0c32c  4321                      mov r3,#0x1
01c0c32e  4116                      mov r1,r4
01c0c330  5216                      mov r2,r5
01c0c332  bfea7efe                  call 0x01c0c032
01c0c336  4020                      mov r0,#0x0
01c0c338  5504                      pop {pc,0x5}
01c0c33a  c0ff1203c101              mov r0,#0x1c10312
01c0c340  4121                      mov r1,#0x1
01c0c342  8940                      sb r1,[r0 + 0x0]
01c0c344  8000                      rts

;===== FUNC_01c0c346  (called 2x) =====
01c0c346  7504                      push {0x5}
01c0c348  2000                      csync
01c0c34a  6000                      cli
01c0c34c  c5fffc02c101              mov r5,#0x1c102fc
01c0c354  0150                      jz r1,0x01c0c376
01c0c356  2000                      csync
01c0c358  2000                      csync
01c0c35a  4024                      mov r0,#0x4
01c0c35c  bfea3df9                  call 0x01c0b5da
01c0c360  4034                      mov r0,#0x14
01c0c362  bfea81f7                  call 0x01c0b268
01c0c366  0416                      mov r4,r0
01c0c368  4035                      mov r0,#0x15
01c0c36a  bfea7df7                  call 0x01c0b268
01c0c36e  2000                      csync
01c0c370  5160                      lw r1,[r5 + 0x0]
01c0c372  f93f                      add r1,#-0x1
01c0c374  d160                      sw r1,[r5 + 0x0]
01c0c378  0000                      nop
01c0c37a  6100                      sti
01c0c37c  00a8                      lsl r0,r0,0x8
01c0c37e  4019                      or r0,r4
01c0c380  2000                      csync
01c0c382  5504                      pop {pc,0x5}

;===== FUNC_01c0c384  (called 1x) =====
01c0c384  7e04                      push {0xe}
01c0c386  c9ffc003c101              mov r9,#0x1c103c0
01c0c390  0816                      mov r8,r0
01c0c392  0253                      jz r2,0x01c0c3ba
01c0c396  2406                      lh.z r4,[r2 ++= 2]
01c0c3a0  4ae00100                  movz r10,#0x1
01c0c3a6  0000                      nop
01c0c3a8  2a16                      mov r10,r2
01c0c3aa  5220                      mov r2,#0x40
01c0c3ae  2000                      csync
01c0c3b0  00a1                      lsl r0,r0,0x1
01c0c3b2  1018                      add r0,r1
01c0c3b6  c800                      call r8
01c0c3b8  0485                      goto 0x01c0c3c4
01c0c3c2  c214                      clr r10
01c0c3c4  5620                      mov r6,#0x40
01c0c3c6  cdfffc02c101              mov r13,#0x1c102fc
01c0c3cc  c614                      clr r14
01c0c3d4  78b0                      qasl r0,r7,0x10
01c0c3d6  2000                      csync
01c0c3d8  6000                      cli
01c0c3de  2000                      csync
01c0c3e0  2000                      csync
01c0c3e2  4024                      mov r0,#0x4
01c0c3e4  bfeaf9f8                  call 0x01c0b5da
01c0c3e8  4034                      mov r0,#0x14
01c0c3ea  bfea3df7                  call 0x01c0b268
01c0c3ee  4120                      mov r1,#0x0
01c0c3f4  4036                      mov r0,#0x16
01c0c3f6  bfea37f7                  call 0x01c0b268
01c0c3fa  0416                      mov r4,r0
01c0c3fc  4037                      mov r0,#0x17
01c0c3fe  bfea33f7                  call 0x01c0b268
01c0c402  00a8                      lsl r0,r0,0x8
01c0c406  0014                      clc
01c0c408  2000                      csync
01c0c40c  d000                      goto r0
01c0c40e  f83f                      add r0,#-0x1
01c0c412  d100                      goto r1
01c0c416  0000                      nop
01c0c418  6100                      sti
01c0c41a  2000                      csync
01c0c41c  2156                      jz r1,0x01c0c4ca
01c0c41e  6716                      mov r7,r6
01c0c422  0006                      lh.z r0,[r0 ++= 2]
01c0c424  1716                      mov r7,r1
01c0c426  418f                      call 0x01c0c346
01c0c42a  9415                      mov r4_r5,r8_r9
01c0c42c  0c16                      mov r12,r0
01c0c42e  0153                      jz r1,0x01c0c456
01c0c434  0264                      lw r2,[r0 + 0x10]
01c0c436  0251                      jz r2,0x01c0c45a
01c0c438  0160                      lw r1,[r0 + 0x0]
01c0c43e  006c                      lw r0,[r0 + 0x30]
01c0c440  2018                      add r0,r2
01c0c442  0a84                      add r2,r0,#0x4
01c0c444  4020                      mov r0,#0x0
01c0c446  4124                      mov r1,#0x4
01c0c448  bfea8cf7                  call 0x01c0b364
01c0c44e  9405                      sw r4,[r1 ++= 4]
01c0c452  0444                      jz r4,0x01c0c45c
01c0c454  0497                      goto 0x01c0c484
01c0c456  4420                      mov r4,#0x0
01c0c458  0495                      goto 0x01c0c484
01c0c45a  0260                      lw r2,[r0 + 0x0]
01c0c45c  4020                      mov r0,#0x0
01c0c45e  4124                      mov r1,#0x4
01c0c460  bfea80f7                  call 0x01c0b364
01c0c466  9405                      sw r4,[r1 ++= 4]
01c0c468  046d                      lw r4,[r0 + 0x34]
01c0c46a  048c                      goto 0x01c0c484
01c0c46c  4020                      mov r0,#0x0
01c0c46e  4124                      mov r1,#0x4
01c0c470  bfea78f7                  call 0x01c0b364
01c0c476  9405                      sw r4,[r1 ++= 4]
01c0c47a  0416                      mov r4,r0
01c0c480  1018                      add r0,r1
01c0c482  0c84                      add r4,r0,#0x4
01c0c48e  1050                      jz r0,0x01c0c4f0
01c0c490  4020                      mov r0,#0x0
01c0c492  4124                      mov r1,#0x4
01c0c494  bfea3cfe                  call 0x01c0c110
01c0c49c  2200                      ssync
01c0c49e  8016                      mov r0,r8
01c0c4a0  4116                      mov r1,r4
01c0c4a2  7216                      mov r2,r7
01c0c4a4  80eabf06                  call 0x01c0d226
01c0c4a8  7818                      add r8,r7
01c0c4aa  0481                      goto 0x01c0c4ae
01c0c4ac  c014                      clr r8
01c0c4b4  1050                      jz r0,0x01c0c516
01c0c4b6  4020                      mov r0,#0x0
01c0c4b8  4124                      mov r1,#0x4
01c0c4ba  bfea29fe                  call 0x01c0c110
01c0c4be  ee1f                      sub r6,r6,r7
01c0c4c0  7e18                      add r14,r7
01c0c4c2  c645                      jnz r6,0x01c0c3ce
01c0c4c4  048c                      goto 0x01c0c4de
01c0c4c6  c614                      clr r14
01c0c4c8  048a                      goto 0x01c0c4de
01c0c4ca  bfea3cff                  call 0x01c0c346
01c0c4d0  0670                      lw r6,[r0 + -0x40]
01c0c4d6  4020                      mov r0,#0x0
01c0c4d8  4124                      mov r1,#0x4
01c0c4da  bfea19fe                  call 0x01c0c110
01c0c4de  e016                      mov r0,r14
01c0c4e0  5e04                      pop {pc,0xe}

;===== FUNC_01c0c4e2  (called 6x) =====
01c0c4e2  7704                      push {0x7}
01c0c4e4  c2ffc003c101              mov r2,#0x1c103c0
01c0c4ea  0481                      goto 0x01c0c4ee
01c0c4ec  f93f                      add r1,#-0x1
01c0c4ee  015c                      jz r1,0x01c0c528
01c0c4f2  0307                      lb.z r3,[r0 ++= 2]
01c0c4f6  4c55                      lb.z r4,[r4 + -0xb]
01c0c4f8  bb27                      bitclr r3,0x7
01c0c4fc  4e63                      lh.z r6,[r4 + 0x6]
01c0c4fe  6319                      or r3,r6
01c0c500  c527                      add r5,#0x7
01c0c504  cb63                      sh r3,[r4 + 0x6]
01c0c506  cd40                      sb r5,[r4 + 0x0]
01c0c50e  5c20                      mov r4,#0x60
01c0c510  4d62                      lh.z r5,[r4 + 0x4]
01c0c512  4662                      lw r6,[r4 + 0x8]
01c0c514  5f81                      add r7,r5,#0x1
01c0c516  cf62                      sh r7,[r4 + 0x4]
01c0c51a  6135                      mov r1,#0x95
01c0c51c  4b47                      lb.z r3,[r4 + 0x7]
01c0c51e  cb63                      sh r3,[r4 + 0x6]
01c0c520  4b40                      lb.z r3,[r4 + 0x0]
01c0c522  fb38                      add r3,#-0x8
01c0c524  cb40                      sb r3,[r4 + 0x0]
01c0c526  f782                      goto 0x01c0c4ec
01c0c528  5704                      pop {pc,0x7}

;===== FUNC_01c0c52a  (called 1x) =====
01c0c52a  7604                      push {0x6}
01c0c52c  0416                      mov r4,r0
01c0c530  2818                      add r8,r2
01c0c532  4840                      lb.z r0,[r4 + 0x0]
01c0c538  4844                      lb.z r0,[r4 + 0x4]
01c0c53e  4848                      lb.z r0,[r4 + 0x8]
01c0c544  c6ffc003c101              mov r6,#0x1c103c0
01c0c54c  5c60                      lh.z r4,[r5 + 0x0]
01c0c54e  4120                      mov r1,#0x0
01c0c550  422c                      mov r2,#0xc
01c0c552  5016                      mov r0,r5
01c0c554  80eac806                  call 0x01c0d2e8
01c0c55a  fc62                      sh r4,[r7 + 0x4]
01c0c55c  d062                      sw r0,[r5 + 0x8]
01c0c55e  4882                      add r0,r4,#0x2
01c0c560  4122                      mov r1,#0x2
01c0c562  519f                      call 0x01c0c4e2
01c0c564  4885                      add r0,r4,#0x5
01c0c566  4123                      mov r1,#0x3
01c0c568  519c                      call 0x01c0c4e2
01c0c56a  4889                      add r0,r4,#0x9
01c0c56c  4123                      mov r1,#0x3
01c0c56e  5199                      call 0x01c0c4e2
01c0c570  5062                      lw r0,[r5 + 0x8]
01c0c572  0940                      lb.z r1,[r0 + 0x0]
01c0c574  8146                      jnz r1,0x01c0c582
01c0c576  0841                      lb.z r0,[r0 + 0x1]
01c0c57a  5940                      lb.z r1,[r5 + 0x0]
01c0c57c  4021                      mov r0,#0x1
01c0c580  6d05                      lw r5,[r6 --= 4]
01c0c582  5604                      pop {pc,0x6}

;===== FUNC_01c0c584  (called 1x) =====
01c0c584  7704                      push {0x7}
01c0c586  0416                      mov r4,r0
01c0c588  4844                      lb.z r0,[r4 + 0x4]
01c0c58a  4a43                      lb.z r2,[r4 + 0x3]
01c0c590  4b45                      lb.z r3,[r4 + 0x5]
01c0c596  2887                      add r0,r2,#0x7
01c0c59e  4e42                      lb.z r6,[r4 + 0x2]
01c0c5a0  4d86                      add r5,r4,#0x6
01c0c5a4  0f5f                      lb.z r7,[r0 + -0x1]
01c0c5a6  2116                      mov r1,r2
01c0c5a8  bfeaecf7                  call 0x01c0b584
01c0c5ae  5f70                      lh.z r7,[r5 + -0x20]
01c0c5b2  ef6f                      sh r7,[r6 + 0x1e]
01c0c5b6  5b3e                      mov r3,#0x7e
01c0c5b8  c6ffc003c101              mov r6,#0x1c103c0
01c0c5be  c0ff99d4c001              mov r0,#0x1c0d499
01c0c5c4  0101                      tbb r1
01c0c5c8  5454                      jz r4,0x01c0c532
01c0c5ca  1154                      jz r1,0x01c0c634
01c0c5cc  5454                      jz r4,0x01c0c536
01c0c5ce  5454                      jz r4,0x01c0c538
01c0c5d0  5454                      jz r4,0x01c0c53a
01c0c5d2  5454                      jz r4,0x01c0c53c
01c0c5d4  5454                      jz r4,0x01c0c53e
01c0c5da  5454                      jz r4,0x01c0c544
01c0c5dc  5454                      jz r4,0x01c0c546
01c0c5de  5454                      jz r4,0x01c0c548
01c0c5e0  5454                      jz r4,0x01c0c54a
01c0c5e2  5454                      jz r4,0x01c0c54c
01c0c5e4  5430                      mov r4,#0x50
01c0c5e6  c028                      add r0,#0x8
01c0c5e8  4128                      mov r1,#0x8
01c0c5ea  4220                      mov r2,#0x0
01c0c5ec  3704                      pop {rets,0x7}
01c0c5ee  ffead4f7                  goto 0x01c0b59a
01c0c5f2  403b                      mov r0,#0x1b
01c0c5f6  7460                      lw r4,[r7 + 0x0]
01c0c5f8  c843                      sb r0,[r4 + 0x3]
01c0c5fa  4020                      mov r0,#0x0
01c0c5fc  c844                      sb r0,[r4 + 0x4]
01c0c600  c845                      sb r0,[r4 + 0x5]
01c0c602  423b                      mov r2,#0x1b
01c0c604  80ea0f06                  call 0x01c0d226
01c0c608  413b                      mov r1,#0x1b
01c0c60a  5016                      mov r0,r5
01c0c60c  bfeabaf7                  call 0x01c0b584
01c0c614  4922                      mov r1,#0x22
01c0c616  4220                      mov r2,#0x0
01c0c618  4016                      mov r0,r4
01c0c61a  3704                      pop {rets,0x7}
01c0c61c  ffeabdf7                  goto 0x01c0b59a
01c0c620  d02f                      add r0,#0x4f
01c0c622  412d                      mov r1,#0xd
01c0c624  f782                      goto 0x01c0c5ea
01c0c626  4848                      lb.z r0,[r4 + 0x8]
01c0c628  4947                      lb.z r1,[r4 + 0x7]
01c0c62e  4a49                      lb.z r2,[r4 + 0x9]
01c0c634  4b4a                      lb.z r3,[r4 + 0xa]
01c0c63a  6568                      lw r5,[r6 + 0x20]
01c0c640  484c                      lb.z r0,[r4 + 0xc]
01c0c642  4a4b                      lb.z r2,[r4 + 0xb]
01c0c648  494d                      lb.z r1,[r4 + 0xd]
01c0c64c  2018                      add r0,r2
01c0c64e  6369                      lw r3,[r6 + 0x24]
01c0c654  606a                      lw r0,[r6 + 0x28]
01c0c656  0049                      jz r0,0x01c0c66a
01c0c658  498e                      add r1,r4,#0xe
01c0c65a  80eae405                  call 0x01c0d226
01c0c65e  4020                      mov r0,#0x0
01c0c660  4120                      mov r1,#0x0
01c0c668  0060                      lw r0,[r0 + 0x0]
01c0c66a  4020                      mov r0,#0x0
01c0c66c  e842                      sb r0,[r6 + 0x2]
01c0c66e  5704                      pop {pc,0x7}
01c0c670  7904                      push {0x9}
01c0c672  1416                      mov r4,r1
01c0c674  0516                      mov r5,r0
01c0c676  c9ffc003c101              mov r9,#0x1c103c0
01c0c680  c1ff1303c101              mov r1,#0x1c10313
01c0c686  4226                      mov r2,#0x6
01c0c688  80eab105                  call 0x01c0d1ee
01c0c68c  8049                      jnz r0,0x01c0c6a0

;===== FUNC_01c0c68e  (called 1x) =====
01c0c68e  5847                      lb.z r0,[r5 + 0x7]
01c0c694  5846                      lb.z r0,[r5 + 0x6]
01c0c698  7f40                      lb.z r7,[r7 + 0x0]
01c0c69a  4021                      mov r0,#0x1
01c0c6a6  9e15                      mov r14_r15,r8_r9
01c0c6ac  1019                      or r0,r1
01c0c6ae  2019                      or r0,r2
01c0c6b0  4720                      mov r7,#0x0
01c0c6b4  ff00                      sti r15
01c0c6ba  9d05                      sw r5,[r1 --= 4]
01c0c6bc  c014                      clr r8
01c0c6be  804f                      jnz r0,0x01c0c6de
01c0c6c0  5016                      mov r0,r5
01c0c6c2  4116                      mov r1,r4
01c0c6c4  bfea31ff                  call 0x01c0c52a
01c0c6ca  9d05                      sw r5,[r1 --= 4]
01c0c6ce  0040                      jz r0,0x01c0c6d0
01c0c6d0  c52c                      add r5,#0xc
01c0c6d2  472c                      mov r7,#0xc
01c0c6d4  0484                      goto 0x01c0c6de
01c0c6d8  9d05                      sw r5,[r1 --= 4]
01c0c6da  c724                      add r7,#0x4
01c0c6dc  c524                      add r5,#0x4
01c0c6de  1049                      jz r0,0x01c0c732
01c0c6e0  7017                      uxtb r0,r7
01c0c6e6  5940                      lb.z r1,[r5 + 0x0]
01c0c6ea  fb1f                      sub r3,r7,r7
01c0c6ee  1006                      lh.z r0,[r1 ++= 2]
01c0c6f0  5881                      add r0,r5,#0x1
01c0c6f6  f93b                      add r1,#-0x5
01c0c6f8  1117                      uxtb r1,r1
01c0c6fa  bfeaf2fe                  call 0x01c0c4e2
01c0c700  5c90                      add r4,r5,#0x10
01c0c702  6962                      lh.z r1,[r6 + 0x4]
01c0c704  6062                      lw r0,[r6 + 0x8]
01c0c706  bfea3dff                  call 0x01c0c584
01c0c70c  6180                      call 0x01c0c68e
01c0c70e  f783                      goto 0x01c0c6d6
01c0c712  071e                      sub r7,r0,r0
01c0c718  5881                      add r0,r5,#0x1
01c0c71a  4123                      mov r1,#0x3
01c0c71c  bfeae1fe                  call 0x01c0c4e2
01c0c720  e79a                      goto 0x01c0c6d6
01c0c722  5881                      add r0,r5,#0x1
01c0c724  4121                      mov r1,#0x1
01c0c726  bfeadcfe                  call 0x01c0c4e2
01c0c72a  e795                      goto 0x01c0c6d6
01c0c72c  4020                      mov r0,#0x0
01c0c730  9d05                      sw r5,[r1 --= 4]
01c0c732  7017                      uxtb r0,r7
01c0c734  5904                      pop {pc,0x9}

;===== FUNC_01c0c736  (called 1x) =====
01c0c736  c79c                      goto 0x01c0c670
01c0c738  1004                      push rets
01c0c73a  e290                      add sp,#-0x40
01c0c73c  8880                      add r0,sp,#0x0
01c0c73e  bfea21fe                  call 0x01c0c384
01c0c744  0080                      rep 0x2,0x0
01c0c746  0117                      uxtb r1,r0
01c0c748  8880                      add r0,sp,#0x0
01c0c74a  7195                      call 0x01c0c736
01c0c74c  0290                      add sp,#0x40
01c0c74e  0004                      pop pc

;===== FUNC_01c0c750  (called 1x) =====
01c0c750  7404                      push {0x4}
01c0c754  1a41                      lb.z r2,[r1 + 0x1]
01c0c756  4020                      mov r0,#0x0
01c0c75c  1a43                      lb.z r2,[r1 + 0x3]
01c0c75e  1b42                      lb.z r3,[r1 + 0x2]
01c0c76c  4421                      mov r4,#0x1
01c0c772  c2ff3bd4c001              mov r2,#0x1c0d43b
01c0c778  4332                      mov r3,#0x12
01c0c77a  4016                      mov r0,r4
01c0c77c  bfea59fc                  call 0x01c0c032
01c0c780  4021                      mov r0,#0x1
01c0c782  5404                      pop {pc,0x4}

;===== FUNC_01c0c784  (called 1x) =====
01c0c784  0116                      mov r1,r0
01c0c786  4021                      mov r0,#0x1
01c0c78a  0000                      nop
01c0c78c  4020                      mov r0,#0x0
01c0c78e  8000                      rts

;===== FUNC_01c0c790  (called 1x) =====
01c0c790  1004                      push rets
01c0c792  0216                      mov r2,r0
01c0c798  7195                      call 0x01c0c784
01c0c79a  0116                      mov r1,r0
01c0c79c  4020                      mov r0,#0x0
01c0c79e  8145                      jnz r1,0x01c0c7aa
01c0c7a0  4123                      mov r1,#0x3
01c0c7a2  2016                      mov r0,r2
01c0c7a4  bfea43fc                  call 0x01c0c02e
01c0c7a8  4021                      mov r0,#0x1
01c0c7aa  0004                      pop pc

;===== FUNC_01c0c7ac  (called 1x) =====
01c0c7ac  0116                      mov r1,r0
01c0c7ae  4021                      mov r0,#0x1
01c0c7b2  ff00                      sti r15
01c0c7b4  4020                      mov r0,#0x0
01c0c7b6  8000                      rts
01c0c7b8  1004                      push rets
01c0c7ba  1a40                      lb.z r2,[r1 + 0x0]
01c0c7be  e020                      add r0,#-0x80
01c0c7c2  0606                      lh.z r6,[r0 ++= 2]
01c0c7c8  4220                      mov r2,#0x0
01c0c7ca  834b                      jnz r3,0x01c0c7e2
01c0c7cc  6181                      call 0x01c0c750
01c0c7ce  0488                      goto 0x01c0c7e0
01c0c7d0  1841                      lb.z r0,[r1 + 0x1]
01c0c7d2  718c                      call 0x01c0c7ac
01c0c7d4  0485                      goto 0x01c0c7e0
01c0c7d6  1a45                      lb.z r2,[r1 + 0x5]
01c0c7d8  1944                      lb.z r1,[r1 + 0x4]
01c0c7dc  6024                      mov r0,#0x84
01c0c7de  6198                      call 0x01c0c790
01c0c7e0  0216                      mov r2,r0
01c0c7e2  2016                      mov r0,r2
01c0c7e4  0004                      pop pc

;===== FUNC_01c0c7e6  (called 1x) =====
01c0c7e6  7704                      push {0x7}
01c0c7e8  2000                      csync
01c0c7ea  6000                      cli
01c0c7ec  c7fffc02c101              mov r7,#0x1c102fc
01c0c7f4  0170                      lw r1,[r0 + -0x40]
01c0c7f6  3416                      mov r4,r3
01c0c7f8  2516                      mov r5,r2
01c0c7fa  1616                      mov r6,r1
01c0c7fc  2000                      csync
01c0c7fe  2000                      csync
01c0c800  0050                      jz r0,0x01c0c822
01c0c80a  2000                      csync
01c0c810  1a48                      lb.z r2,[r1 + 0x8]
01c0c812  e260                      sw r2,[r6 + 0x0]
01c0c814  1a60                      lh.z r2,[r1 + 0x0]
01c0c816  d260                      sw r2,[r5 + 0x0]
01c0c818  1961                      lh.z r1,[r1 + 0x2]
01c0c81a  c160                      sw r1,[r4 + 0x0]
01c0c820  0498                      goto 0x01c0c852
01c0c822  4026                      mov r0,#0x6
01c0c824  bfea20f5                  call 0x01c0b268
01c0c828  e060                      sw r0,[r6 + 0x0]
01c0c82a  4022                      mov r0,#0x2
01c0c82c  bfea1cf5                  call 0x01c0b268
01c0c830  0616                      mov r6,r0
01c0c832  4023                      mov r0,#0x3
01c0c834  bfea18f5                  call 0x01c0b268
01c0c838  00a8                      lsl r0,r0,0x8
01c0c83a  6019                      or r0,r6
01c0c83c  d060                      sw r0,[r5 + 0x0]
01c0c83e  4024                      mov r0,#0x4
01c0c840  bfea12f5                  call 0x01c0b268
01c0c844  0516                      mov r5,r0
01c0c846  4025                      mov r0,#0x5
01c0c848  bfea0ef5                  call 0x01c0b268
01c0c84c  00a8                      lsl r0,r0,0x8
01c0c84e  5019                      or r0,r5
01c0c850  c060                      sw r0,[r4 + 0x0]
01c0c852  2000                      csync
01c0c854  7060                      lw r0,[r7 + 0x0]
01c0c856  f83f                      add r0,#-0x1
01c0c858  f060                      sw r0,[r7 + 0x0]
01c0c85c  0000                      nop
01c0c85e  6100                      sti
01c0c860  2000                      csync
01c0c862  5704                      pop {pc,0x7}

;===== FUNC_01c0c864  (called 1x) =====
01c0c864  7704                      push {0x7}
01c0c866  2000                      csync
01c0c868  6000                      cli
01c0c86a  c7fffc02c101              mov r7,#0x1c102fc
01c0c872  0170                      lw r1,[r0 + -0x40]
01c0c874  3416                      mov r4,r3
01c0c876  2516                      mov r5,r2
01c0c878  1616                      mov r6,r1
01c0c87a  2000                      csync
01c0c87c  2000                      csync
01c0c87e  0049                      jz r0,0x01c0c892
01c0c880  c0ff06600100              mov r0,#0x16006
01c0c886  0945                      lb.z r1,[r0 + 0x5]
01c0c888  e160                      sw r1,[r6 + 0x0]
01c0c88a  0960                      lh.z r1,[r0 + 0x0]
01c0c88c  d160                      sw r1,[r5 + 0x0]
01c0c88e  0861                      lh.z r0,[r0 + 0x2]
01c0c890  0497                      goto 0x01c0c8c0
01c0c892  402b                      mov r0,#0xb
01c0c894  bfeae8f4                  call 0x01c0b268
01c0c898  e060                      sw r0,[r6 + 0x0]
01c0c89a  4027                      mov r0,#0x7
01c0c89c  bfeae4f4                  call 0x01c0b268
01c0c8a0  0616                      mov r6,r0
01c0c8a2  4028                      mov r0,#0x8
01c0c8a4  bfeae0f4                  call 0x01c0b268
01c0c8a8  00a8                      lsl r0,r0,0x8
01c0c8aa  6019                      or r0,r6
01c0c8ac  d060                      sw r0,[r5 + 0x0]
01c0c8ae  4029                      mov r0,#0x9
01c0c8b0  bfeadaf4                  call 0x01c0b268
01c0c8b4  0516                      mov r5,r0
01c0c8b6  402a                      mov r0,#0xa
01c0c8b8  bfead6f4                  call 0x01c0b268
01c0c8bc  00a8                      lsl r0,r0,0x8
01c0c8be  5019                      or r0,r5
01c0c8c0  c060                      sw r0,[r4 + 0x0]
01c0c8c2  2000                      csync
01c0c8c4  7060                      lw r0,[r7 + 0x0]
01c0c8c6  f83f                      add r0,#-0x1
01c0c8c8  f060                      sw r0,[r7 + 0x0]
01c0c8cc  0000                      nop
01c0c8ce  6100                      sti
01c0c8d0  2000                      csync
01c0c8d2  5704                      pop {pc,0x7}

;===== FUNC_01c0c8d4  (called 4x) =====
01c0c8d4  7404                      push {0x4}
01c0c8d8  0080                      rep 0x2,0x0
01c0c8de  8940                      sb r1,[r0 + 0x0]
01c0c8e0  5404                      pop {pc,0x4}
01c0c8e2  2000                      csync
01c0c8e4  6000                      cli
01c0c8e6  c4fffc02c101              mov r4,#0x1c102fc
01c0c8ee  0140                      jz r1,0x01c0c8f0
01c0c8f0  2000                      csync
01c0c8f2  2000                      csync
01c0c8f4  4020                      mov r0,#0x0
01c0c8f6  bfea67f4                  call 0x01c0b1c8
01c0c8fa  2000                      csync
01c0c8fc  4060                      lw r0,[r4 + 0x0]
01c0c8fe  f83f                      add r0,#-0x1
01c0c900  c060                      sw r0,[r4 + 0x0]
01c0c904  0000                      nop
01c0c906  6100                      sti
01c0c908  2000                      csync
01c0c90a  5404                      pop {pc,0x4}

;===== FUNC_01c0c90c  (called 1x) =====
01c0c90c  7604                      push {0x6}
01c0c90e  c5ffc003c101              mov r5,#0x1c103c0
01c0c918  0416                      mov r4,r0
01c0c91a  4022                      mov r0,#0x2
01c0c91e  1401                      tbh r4
01c0c926  0200                      bkpt
01c0c92c  4120                      mov r1,#0x0
01c0c930  0401                      tbb r4
01c0c932  c940                      sb r1,[r4 + 0x0]
01c0c934  618f                      call 0x01c0c8d4
01c0c938  5804                      pop {pc,0x8}
01c0c93a  004e                      jz r0,0x01c0c958
01c0c93c  462e                      mov r6,#0xe
01c0c93e  0483                      goto 0x01c0c946
01c0c942  5804                      pop {pc,0x8}
01c0c944  c621                      add r6,#0x1
01c0c94c  0080                      rep 0x2,0x0
01c0c950  4016                      mov r0,r4
01c0c952  c200                      call r2
01c0c956  f427                      add r4,#-0x39
01c0c958  5604                      pop {pc,0x6}

;===== FUNC_01c0c95a  (called 3x) =====
01c0c95a  7404                      push {0x4}
01c0c95c  0046                      jz r0,0x01c0c96a
01c0c95e  2200                      ssync
01c0c960  c0ff02610100              mov r0,#0x16102
01c0c966  0860                      lh.z r0,[r0 + 0x0]
01c0c968  5404                      pop {pc,0x4}
01c0c96a  2000                      csync
01c0c96c  6000                      cli
01c0c96e  c4fffc02c101              mov r4,#0x1c102fc
01c0c976  0140                      jz r1,0x01c0c978
01c0c978  2000                      csync
01c0c97a  2000                      csync
01c0c97c  4020                      mov r0,#0x0
01c0c97e  bfea2cf6                  call 0x01c0b5da
01c0c982  4031                      mov r0,#0x11
01c0c984  bfea70f4                  call 0x01c0b268
01c0c988  2000                      csync
01c0c98a  4160                      lw r1,[r4 + 0x0]
01c0c98c  f93f                      add r1,#-0x1
01c0c98e  c160                      sw r1,[r4 + 0x0]
01c0c992  0000                      nop
01c0c994  6100                      sti
01c0c996  2000                      csync
01c0c998  5404                      pop {pc,0x4}

;===== FUNC_01c0c99a  (called 4x) =====
01c0c99a  7504                      push {0x5}
01c0c99c  1416                      mov r4,r1
01c0c99e  0046                      jz r0,0x01c0c9ac
01c0c9a0  c0ff02610100              mov r0,#0x16102
01c0c9a6  8c60                      sh r4,[r0 + 0x0]
01c0c9a8  2000                      csync
01c0c9aa  5504                      pop {pc,0x5}
01c0c9ac  2000                      csync
01c0c9ae  6000                      cli
01c0c9b0  c5fffc02c101              mov r5,#0x1c102fc
01c0c9b8  0150                      jz r1,0x01c0c9da
01c0c9ba  2000                      csync
01c0c9bc  2000                      csync
01c0c9be  4020                      mov r0,#0x0
01c0c9c0  bfea0bf6                  call 0x01c0b5da
01c0c9c4  4031                      mov r0,#0x11
01c0c9c6  4116                      mov r1,r4
01c0c9c8  bfeafef3                  call 0x01c0b1c8
01c0c9cc  2000                      csync
01c0c9ce  5060                      lw r0,[r5 + 0x0]
01c0c9d0  f83f                      add r0,#-0x1
01c0c9d2  d060                      sw r0,[r5 + 0x0]
01c0c9d6  0000                      nop
01c0c9d8  6100                      sti
01c0c9da  2000                      csync
01c0c9dc  5504                      pop {pc,0x5}

;===== FUNC_01c0c9de  (called 1x) =====
01c0c9de  c1ff0003c101              mov r1,#0x1c10300
01c0c9e4  4232                      mov r2,#0x12
01c0c9e6  c0ea1e04                  goto 0x01c0d226

;===== FUNC_01c0c9ea  (called 1x) =====
01c0c9ea  c1ffc0d3c001              mov r1,#0x1c0d3c0
01c0c9f0  4224                      mov r2,#0x4
01c0c9f2  c0ea1804                  goto 0x01c0d226

;===== FUNC_01c0c9f6  (called 1x) =====
01c0c9f6  c1ffc4d3c001              mov r1,#0x1c0d3c4
01c0c9fc  4a22                      mov r2,#0x22
01c0c9fe  c0ea1204                  goto 0x01c0d226

;===== FUNC_01c0ca02  (called 1x) =====
01c0ca02  c1ff08d4c001              mov r1,#0x1c0d408
01c0ca08  4a2a                      mov r2,#0x2a
01c0ca0a  c0ea0c04                  goto 0x01c0d226

;===== FUNC_01c0ca0e  (called 1x) =====
01c0ca0e  c1ffe6d3c001              mov r1,#0x1c0d3e6
01c0ca14  4a22                      mov r2,#0x22
01c0ca16  c0ea0604                  goto 0x01c0d226
01c0ca1c  0080                      rep 0x2,0x0
01c0ca1e  1893                      add r0,r1,#0x13
01c0ca22  8c1b                      mul r12,r8
01c0ca28  8000                      rts

;===== FUNC_01c0ca2a  (called 1x) =====
01c0ca2a  5128                      mov r1,#0x48
01c0ca2c  d796                      goto 0x01c0c99a

;===== FUNC_01c0ca2e  (called 1x) =====
01c0ca2e  5120                      mov r1,#0x40
01c0ca30  d794                      goto 0x01c0c99a

;===== FUNC_01c0ca32  (called 1x) =====
01c0ca32  412a                      mov r1,#0xa
01c0ca34  d792                      goto 0x01c0c99a
01c0ca36  7604                      push {0x6}
01c0ca38  0416                      mov r4,r0
01c0ca40  0401                      tbb r4
01c0ca42  5016                      mov r0,r5
01c0ca44  418a                      call 0x01c0c95a
01c0ca4a  4e61                      lh.z r6,[r4 + 0x2]
01c0ca4c  164d                      jz r6,0x01c0caa8
01c0ca50  4000                      lockclr
01c0ca52  5620                      mov r6,#0x40
01c0ca54  4162                      lw r1,[r4 + 0x8]
01c0ca56  8551                      jnz r5,0x01c0ca7a
01c0ca58  c0ff1404c101              mov r0,#0x1c10414
01c0ca60  0a05                      lw r2,[r0 --= 4]
01c0ca62  0054                      jz r0,0x01c0ca8c
01c0ca66  0060                      lw r0,[r0 + 0x0]
01c0ca68  80eadd03                  call 0x01c0d226
01c0ca6c  c0ffacd4c001              mov r0,#0x1c0d4ac
01c0ca74  0a05                      lw r2,[r0 --= 4]
01c0ca76  8662                      sw r6,[r0 + 0x8]
01c0ca78  0489                      goto 0x01c0ca8c
01c0ca7c  0060                      lw r0,[r0 + 0x0]
01c0ca7e  c2ff20600100              mov r2,#0x16020
01c0ca84  1307                      lb.z r3,[r1 ++= 2]
01c0ca86  c021                      add r0,#0x1
01c0ca88  ab40                      sb r3,[r2 + 0x0]
01c0ca8a  f05c                      jnz r0,0x01c0ca84
01c0ca8e  0846                      lb.z r0,[r0 + 0x6]
01c0ca90  4861                      lh.z r0,[r4 + 0x2]
01c0ca92  801f                      sub r0,r0,r6
01c0ca96  c861                      sh r0,[r4 + 0x2]
01c0ca98  8143                      jnz r1,0x01c0caa0
01c0ca9e  0044                      jz r0,0x01c0caa8
01c0caa0  4122                      mov r1,#0x2
01c0caa2  5016                      mov r0,r5
01c0caa4  3604                      pop {rets,0x6}
01c0caa6  b799                      goto 0x01c0c99a
01c0caa8  5016                      mov r0,r5
01c0caaa  6183                      call 0x01c0ca32
01c0caac  4020                      mov r0,#0x0
01c0caae  c841                      sb r0,[r4 + 0x1]
01c0cab0  5604                      pop {pc,0x6}

;===== FUNC_01c0cab2  (called 1x) =====
01c0cab2  7a04                      push {0xa}
01c0cab4  c7ffc003c101              mov r7,#0x1c103c0
01c0cabe  0416                      mov r4,r0
01c0cac2  1440                      jz r4,0x01c0cb04
01c0cacc  a300                      swi 0x3
01c0cad0  0401                      tbb r4
01c0cad6  4023                      mov r0,#0x3
01c0cada  1401                      tbh r4
01c0cade  4940                      lb.z r1,[r4 + 0x0]
01c0cae0  bfeaf8fe                  call 0x01c0c8d4
01c0cae6  a300                      swi 0x3
01c0cae8  b821                      bitclr r0,0x1
01c0caec  a300                      swi 0x3
01c0caee  5016                      mov r0,r5
01c0caf0  bfea33ff                  call 0x01c0c95a
01c0caf4  0616                      mov r6,r0
01c0cafe  4841                      lb.z r0,[r4 + 0x1]
01c0cb04  3d02                      flushinv [r13]
01c0cb06  01a1                      lsl r1,r0,0x1
01c0cb0a  0140                      jz r1,0x01c0cb0c
01c0cb0c  1101                      tbh r1
01c0cb10  3602                      flushinv [r6]
01c0cb14  3902                      flushinv [r9]
01c0cb1a  0160                      lw r1,[r0 + 0x0]
01c0cb1c  3102                      flushinv [r1]
01c0cb20  a300                      swi 0x3
01c0cb24  0401                      tbb r4
01c0cb26  4264                      lw r2,[r4 + 0x10]
01c0cb2a  e200                      cli r2
01c0cb2e  7804                      push {0x8}
01c0cb30  0998                      add r1,r0,#0x18
01c0cb32  4016                      mov r0,r4
01c0cb34  c200                      call r2
01c0cb38  c841                      sb r0,[r4 + 0x1]
01c0cb40  d900                      goto r9
01c0cb42  5a04                      pop {pc,0xa}
01c0cb44  4120                      mov r1,#0x0
01c0cb46  4620                      mov r6,#0x0
01c0cb48  5016                      mov r0,r5
01c0cb4a  bfea26ff                  call 0x01c0c99a
01c0cb4e  4841                      lb.z r0,[r4 + 0x1]
01c0cb54  1502                      iflush [r5]
01c0cb56  ce41                      sb r6,[r4 + 0x1]
01c0cb58  5a04                      pop {pc,0xa}
01c0cb5a  6120                      mov r1,#0x80
01c0cb5c  5016                      mov r0,r5
01c0cb5e  bfea1cff                  call 0x01c0c99a
01c0cb64  0140                      jz r1,0x01c0cb66
01c0cb66  4841                      lb.z r0,[r4 + 0x1]
01c0cb6e  0160                      lw r1,[r0 + 0x0]
01c0cb70  0702                      pfetch [r7]
01c0cb72  4020                      mov r0,#0x0
01c0cb7a  0050                      jz r0,0x01c0cb9c
01c0cb7c  0102                      pfetch [r1]
01c0cb7e  4120                      mov r1,#0x0
01c0cb80  bfeaa8fe                  call 0x01c0c8d4
01c0cb8c  5a04                      pop {pc,0xa}
01c0cb8e  4020                      mov r0,#0x0
01c0cb90  c841                      sb r0,[r4 + 0x1]
01c0cb94  0160                      lw r1,[r0 + 0x0]
01c0cb9a  a300                      swi 0x3
01c0cba0  85a2                      lsr r5,r0,0x2
01c0cba2  1898                      add r0,r1,#0x18
01c0cba6  0802                      pfetch [r8]
01c0cbaa  7415                      mov r4_r5,r6_r7
01c0cbac  1146                      jz r1,0x01c0cbfa
01c0cbae  1160                      lw r1,[r1 + 0x0]
01c0cbb0  4228                      mov r2,#0x8
01c0cbb2  80ea3803                  call 0x01c0d226
01c0cbb6  1481                      goto 0x01c0cbfa
01c0cbb8  2000                      csync
01c0cbba  6000                      cli
01c0cbbc  c1fffc02c101              mov r1,#0x1c102fc
01c0cbc6  2000                      csync
01c0cbc8  2000                      csync
01c0cbcc  b48b                      goto 0x01c0cea4
01c0cbd0  008e                      rep 0x2,0xe
01c0cbd2  2000                      csync
01c0cbd4  4320                      mov r3,#0x0
01c0cbd8  2088                      rep 0x6,0x8
01c0cbda  6a40                      lb.z r2,[r6 + 0x0]
01c0cbe0  c321                      add r3,#0x1
01c0cbe8  008e                      rep 0x2,0xe
01c0cbea  2000                      csync
01c0cbec  1060                      lw r0,[r1 + 0x0]
01c0cbee  f83f                      add r0,#-0x1
01c0cbf0  9060                      sw r0,[r1 + 0x0]
01c0cbf4  0000                      nop
01c0cbf6  6100                      sti
01c0cbf8  2000                      csync
01c0cc00  1801                      tbh r8
01c0cc02  4223                      mov r2,#0x3
01c0cc0a  e000                      cli r0
01c0cc0c  4263                      lw r2,[r4 + 0xc]
01c0cc0e  0245                      jz r2,0x01c0cc1a
01c0cc10  4016                      mov r0,r4
01c0cc12  c200                      call r2
01c0cc16  0000                      nop
01c0cc1c  0150                      jz r1,0x01c0cc3e
01c0cc28  0060                      lw r0,[r0 + 0x0]
01c0cc2e  7804                      push {0x8}
01c0cc30  0994                      add r1,r0,#0x14
01c0cc32  1b45                      lb.z r3,[r1 + 0x5]
01c0cc3c  a300                      swi 0x3
01c0cc40  0401                      tbb r4
01c0cc42  4661                      lw r6,[r4 + 0x4]
01c0cc44  37a1                      lsl r7,r3,0x1
01c0cc4a  1701                      tbh r7
01c0cc58  b600                      testset b[r6]
01c0cc5c  c600                      call r6
01c0cc5e  d100                      goto r1
01c0cc62  a000                      swi 0x0
01c0cc66  0200                      bkpt
01c0cc68  0c01                      tbb r12
01c0cc6a  4020                      mov r0,#0x0
01c0cc6c  e840                      sb r0,[r6 + 0x0]
01c0cc6e  e841                      sb r0,[r6 + 0x1]
01c0cc72  a300                      swi 0x3
01c0cc76  0140                      jz r1,0x01c0cc78
01c0cc78  4022                      mov r0,#0x2
01c0cc7a  e840                      sb r0,[r6 + 0x0]
01c0cc7c  4322                      mov r3,#0x2
01c0cc7e  9498                      goto 0x01c0cef0
01c0cc82  7804                      push {0x8}
01c0cc84  0998                      add r1,r0,#0x18
01c0cc86  1b45                      lb.z r3,[r1 + 0x5]
01c0cc88  1a44                      lb.z r2,[r1 + 0x4]
01c0cc8e  1841                      lb.z r0,[r1 + 0x1]
01c0cc94  1052                      jz r0,0x01c0ccfa
01c0cc98  4406                      lh.z r4,[r4 ++= 2]
01c0cc9c  0100                      idle
01c0cca2  a000                      swi 0x0
01c0ccac  1842                      lb.z r0,[r1 + 0x2]
01c0ccb0  0000                      nop
01c0ccb6  a300                      swi 0x3
01c0ccba  0401                      tbb r4
01c0ccbe  fe3a                      add r6,#-0x6
01c0ccc0  6220                      mov r2,#0x80
01c0ccc2  6116                      mov r1,r6
01c0ccc4  bfea24fa                  call 0x01c0c110
01c0ccc8  7886                      add r0,r7,#0x6
01c0ccca  749d                      goto 0x01c0cec6
01c0ccce  7804                      push {0x8}
01c0ccd8  1001                      tbh r0
01c0ccdc  2000                      csync
01c0cce6  0901                      tbb r9
01c0cce8  0998                      add r1,r0,#0x18
01c0ccea  4016                      mov r0,r4
01c0ccec  c200                      call r2
01c0ccee  8485                      goto 0x01c0cefa
01c0ccf0  4020                      mov r0,#0x0
01c0ccf2  c841                      sb r0,[r4 + 0x1]
01c0ccf4  5016                      mov r0,r5
01c0ccf6  3a04                      pop {rets,0xa}
01c0ccf8  4798                      goto 0x01c0ca2a
01c0ccfc  a000                      swi 0x0
01c0cd02  4261                      lw r2,[r4 + 0x4]
01c0cd0a  f706                      sh r7,[r7 ++= 2]
01c0cd0e  b900                      testset b[r9]
01c0cd10  4020                      mov r0,#0x0
01c0cd12  a840                      sb r0,[r2 + 0x0]
01c0cd14  a841                      sb r0,[r2 + 0x1]
01c0cd1e  7864                      lh.z r0,[r7 + 0x8]
01c0cd20  4493                      goto 0x01c0ce48
01c0cd24  a000                      swi 0x0
01c0cd30  e406                      sh r4,[r6 ++= 2]
01c0cd34  a600                      swi 0x6
01c0cd36  648b                      goto 0x01c0cece
01c0cd38  5016                      mov r0,r5
01c0cd3a  3a04                      pop {rets,0xa}
01c0cd3c  3798                      goto 0x01c0ca2e
01c0cd3e  1946                      lb.z r1,[r1 + 0x6]
01c0cd56  d106                      sh r1,[r5 ++= 2]
01c0cd58  4120                      mov r1,#0x0
01c0cd5e  b820                      bitclr r0,0x0
01c0cd62  a300                      swi 0x3
01c0cd64  648a                      goto 0x01c0cefa
01c0cd66  1946                      lb.z r1,[r1 + 0x6]
01c0cd7a  bf06                      sh r7,[r3 --= 2]
01c0cd7c  4120                      mov r1,#0x0
01c0cd82  3020                      bitset r0,0x0
01c0cd86  a300                      swi 0x3
01c0cd88  5498                      goto 0x01c0cefa
01c0cd92  1e46                      lb.z r6,[r1 + 0x6]
01c0cd98  1a49                      lb.z r2,[r1 + 0x9]
01c0cd9a  1b48                      lb.z r3,[r1 + 0x8]
01c0cda0  8346                      jnz r3,0x01c0cdae
01c0cda2  1a4b                      lb.z r2,[r1 + 0xb]
01c0cda4  194a                      lb.z r1,[r1 + 0xa]
01c0cdac  ea00                      cli r10
01c0cdae  ce40                      sb r6,[r4 + 0x0]
01c0cdb0  4024                      mov r0,#0x4
01c0cdb6  549a                      goto 0x01c0cf2c
01c0cdb8  1b47                      lb.z r3,[r1 + 0x7]
01c0cdba  1846                      lb.z r0,[r1 + 0x6]
01c0cdc0  81a8                      lsr r1,r0,0x8
01c0cdc4  6206                      lh.z r2,[r6 ++= 2]
01c0cdc8  6b04                      push {rets,0xb}
01c0cdce  6016                      mov r0,r6
01c0cdd0  bfea05fe                  call 0x01c0c9de
01c0cdd4  4332                      mov r3,#0x12
01c0cdd6  448c                      goto 0x01c0cef0
01c0cdda  a000                      swi 0x0
01c0cdde  5104                      pop {pc,0x1}
01c0cde0  4121                      mov r1,#0x1
01c0cde6  4120                      mov r1,#0x0
01c0cde8  e940                      sb r1,[r6 + 0x0]
01c0cdea  4321                      mov r3,#0x1
01c0cdec  4481                      goto 0x01c0cef0
01c0cdee  1849                      lb.z r0,[r1 + 0x9]
01c0cdf0  1b48                      lb.z r3,[r1 + 0x8]
01c0cdf6  a345                      jnz r3,0x01c0ce82
01c0cdf8  184b                      lb.z r0,[r1 + 0xb]
01c0cdfa  1b4a                      lb.z r3,[r1 + 0xa]
01c0ce00  a340                      jnz r3,0x01c0ce82
01c0ce02  1840                      lb.z r0,[r1 + 0x0]
01c0ce06  3d04                      pop {rets,0xd}
01c0ce08  1846                      lb.z r0,[r1 + 0x6]
01c0ce0e  9059                      jnz r0,0x01c0ce82
01c0ce10  4020                      mov r0,#0x0
01c0ce16  4023                      mov r0,#0x3
01c0ce1a  9840                      sb r0,[r1 + 0x0]
01c0ce1c  4121                      mov r1,#0x1
01c0ce1e  bfeafcfd                  call 0x01c0ca1a
01c0ce22  4122                      mov r1,#0x2
01c0ce24  2016                      mov r0,r2
01c0ce26  bfeaf8fd                  call 0x01c0ca1a
01c0ce2a  4123                      mov r1,#0x3
01c0ce2c  2016                      mov r0,r2
01c0ce2e  bfeaf4fd                  call 0x01c0ca1a
01c0ce32  4124                      mov r1,#0x4
01c0ce34  2016                      mov r0,r2
01c0ce36  bfeaf0fd                  call 0x01c0ca1a
01c0ce3a  249f                      goto 0x01c0cefa
01c0ce3c  4020                      mov r0,#0x0
01c0ce3e  a840                      sb r0,[r2 + 0x0]
01c0ce40  a841                      sb r0,[r2 + 0x1]
01c0ce42  7864                      lh.z r0,[r7 + 0x8]
01c0ce4a  0206                      lh.z r2,[r0 ++= 2]
01c0ce4e  0040                      jz r0,0x01c0ce50
01c0ce50  4021                      mov r0,#0x1
01c0ce52  a840                      sb r0,[r2 + 0x0]
01c0ce54  4322                      mov r3,#0x2
01c0ce56  4016                      mov r0,r4
01c0ce58  248e                      goto 0x01c0cef6
01c0ce5a  4320                      mov r3,#0x0
01c0ce5c  7986                      add r1,r7,#0x6
01c0ce5e  7888                      add r0,r7,#0x8
01c0ce60  2a17                      sxtb r2,r2
01c0ce68  0000                      nop
01c0ce6a  1016                      mov r0,r1
01c0ce6c  0960                      lh.z r1,[r0 + 0x0]
01c0ce70  1016                      mov r0,r1
01c0ce72  8960                      sh r1,[r0 + 0x0]
01c0ce74  2482                      goto 0x01c0cefa
01c0ce78  a000                      swi 0x0
01c0ce7a  f83e                      add r0,#-0x2
01c0ce7c  0017                      uxtb r0,r0
01c0ce80  3c06                      lh.z r4,[r3 --= 2]
01c0ce82  4023                      mov r0,#0x3
01c0ce88  2484                      goto 0x01c0cf12
01c0ce90  0d06                      lh.z r5,[r0 --= 2]
01c0ce92  0001                      tbb r0
01c0ce98  6016                      mov r0,r6
01c0ce9a  bfeaa6fd                  call 0x01c0c9ea
01c0ce9e  1486                      goto 0x01c0ceec
01c0cea0  2016                      mov r0,r2
01c0cea2  6116                      mov r1,r6
01c0cea4  bfeac8f0                  call 0x01c0b038
01c0cea8  0316                      mov r3,r0
01c0ceaa  1481                      goto 0x01c0ceee
01c0ceb0  4023                      mov r0,#0x3
01c0ceb6  4020                      mov r0,#0x0
01c0ceb8  e840                      sb r0,[r6 + 0x0]
01c0ceba  0498                      goto 0x01c0ceec
01c0cebc  5220                      mov r2,#0x40
01c0cebe  6116                      mov r1,r6
01c0cec0  bfeaacf3                  call 0x01c0b61c
01c0cec4  7888                      add r0,r7,#0x8
01c0cec6  0960                      lh.z r1,[r0 + 0x0]
01c0ceca  1316                      mov r3,r1
01c0cecc  8960                      sh r1,[r0 + 0x0]
01c0cece  4020                      mov r0,#0x0
01c0ced4  1486                      goto 0x01c0cf22
01c0ced6  6016                      mov r0,r6
01c0ced8  bfea8dfd                  call 0x01c0c9f6
01c0cedc  0487                      goto 0x01c0ceec
01c0cede  6016                      mov r0,r6
01c0cee0  bfea8ffd                  call 0x01c0ca02
01c0cee4  0483                      goto 0x01c0ceec
01c0cee6  6016                      mov r0,r6
01c0cee8  bfea91fd                  call 0x01c0ca0e
01c0ceec  6b40                      lb.z r3,[r6 + 0x0]
01c0ceee  0345                      jz r3,0x01c0cefa
01c0cef0  4016                      mov r0,r4
01c0cef2  8116                      mov r1,r8
01c0cef4  6216                      mov r2,r6
01c0cef6  bfea9cf8                  call 0x01c0c032
01c0cf02  0001                      tbb r0
01c0cf04  0f03                      rep 0x2,r15
01c0cf06  0307                      lb.z r3,[r0 ++= 2]
01c0cf0a  5016                      mov r0,r5
01c0cf0c  bfea8ffd                  call 0x01c0ca2e
01c0cf10  1490                      goto 0x01c0cf72
01c0cf12  4020                      mov r0,#0x0
01c0cf18  5920                      mov r1,#0x60
01c0cf1a  5016                      mov r0,r5
01c0cf1c  bfea3dfd                  call 0x01c0c99a
01c0cf20  1488                      goto 0x01c0cf72
01c0cf22  5016                      mov r0,r5
01c0cf24  bfea81fd                  call 0x01c0ca2a
01c0cf28  1484                      goto 0x01c0cf72
01c0cf2a  4e40                      lb.z r6,[r4 + 0x0]
01c0cf2c  855d                      jnz r5,0x01c0cf68
01c0cf2e  4020                      mov r0,#0x0
01c0cf30  5920                      mov r1,#0x60
01c0cf32  bfea32fd                  call 0x01c0c99a
01c0cf36  4020                      mov r0,#0x0
01c0cf38  bfea0ffd                  call 0x01c0c95a
01c0cf40  c0ffacd4c001              mov r0,#0x1c0d4ac
01c0cf48  0a15                      mov r10_r11,r0_r1
01c0cf4a  1260                      lw r2,[r1 + 0x0]
01c0cf4e  402b                      mov r0,#0xb
01c0cf52  c028                      add r0,#0x8
01c0cf56  0a05                      lw r2,[r0 --= 4]
01c0cf58  41e00c09                  movz r1,#0x90c
01c0cf5e  0001                      tbb r0
01c0cf60  4020                      mov r0,#0x0
01c0cf62  6116                      mov r1,r6
01c0cf64  bfeab6fc                  call 0x01c0c8d4
01c0cf6a  a300                      swi 0x3
01c0cf6c  b821                      bitclr r0,0x1
01c0cf70  a300                      swi 0x3
01c0cf78  0302                      pfetch [r3]
01c0cf7a  4016                      mov r0,r4
01c0cf7c  3a04                      pop {rets,0xa}
01c0cf7e  a69b                      goto 0x01c0ca36
01c0cf80  5a04                      pop {pc,0xa}
01c0cf82  ce40                      sb r6,[r4 + 0x0]
01c0cf84  4120                      mov r1,#0x0
01c0cf8a  3021                      bitset r0,0x1
01c0cf8e  a300                      swi 0x3
01c0cf90  d794                      goto 0x01c0cefa
01c0cf92  4020                      mov r0,#0x0
01c0cf98  4024                      mov r0,#0x4
01c0cf9a  9840                      sb r0,[r1 + 0x0]
01c0cf9c  d78e                      goto 0x01c0cefa

;===== FUNC_01c0cf9e  (called 2x) =====
01c0cf9e  7904                      push {0x9}
01c0cfa0  e29a                      add sp,#-0x18
01c0cfa2  0516                      mov r5,r0
01c0cfa4  2200                      ssync
01c0cfa6  8994                      add r1,sp,#0x14
01c0cfa8  8a8c                      add r2,sp,#0xc
01c0cfaa  8b84                      add r3,sp,#0x4
01c0cfac  bfea1bfc                  call 0x01c0c7e6
01c0cfb0  8990                      add r1,sp,#0x10
01c0cfb2  8a88                      add r2,sp,#0x8
01c0cfb4  8b80                      add r3,sp,#0x0
01c0cfb6  5016                      mov r0,r5
01c0cfb8  bfea54fc                  call 0x01c0c864
01c0cfbc  bfeab1f2                  call 0x01c0b522
01c0cfce  3270                      lw r2,[r3 + -0x40]
01c0cfd6  4262                      lw r2,[r4 + 0x8]
01c0cfe0  0440                      jz r4,0x01c0cfe2
01c0cfe2  9016                      mov r0,r9
01c0cfe4  bfea92fc                  call 0x01c0c90c
01c0cfe8  c4ffc003c101              mov r4,#0x1c103c0
01c0cff4  1450                      jz r4,0x01c0d056
01c0cff6  4018                      add r0,r4
01c0cffc  0244                      jz r2,0x01c0d006
01c0cffe  4120                      mov r1,#0x0
01c0d000  9016                      mov r0,r9
01c0d002  c200                      call r2
01c0d004  0483                      goto 0x01c0d00c
01c0d006  9016                      mov r0,r9
01c0d008  bfea53fd                  call 0x01c0cab2
01c0d00e  1450                      jz r4,0x01c0d070
01c0d012  0084                      rep 0x2,0x4
01c0d018  4020                      mov r0,#0x0
01c0d01a  0481                      goto 0x01c0d01e
01c0d01c  5016                      mov r0,r5
01c0d022  0d81                      add r5,r0,#0x1
01c0d026  7215                      mov r2_r3,r6_r7
01c0d028  7159                      jz r1,0x01c0d01c
01c0d02c  4a20                      mov r2,#0x20
01c0d030  0080                      rep 0x2,0x0
01c0d032  9016                      mov r0,r9
01c0d034  5116                      mov r1,r5
01c0d036  c200                      call r2
01c0d038  f791                      goto 0x01c0d01c
01c0d03c  b080                      rep 0x18,0x0
01c0d03e  4020                      mov r0,#0x0
01c0d040  0481                      goto 0x01c0d044
01c0d042  5016                      mov r0,r5
01c0d048  0d81                      add r5,r0,#0x1
01c0d04c  6215                      mov r2_r3,r6_r7
01c0d04e  7159                      jz r1,0x01c0d042
01c0d052  7a20                      mov r2,#0xe0
01c0d056  0080                      rep 0x2,0x0
01c0d058  9016                      mov r0,r9
01c0d05a  5116                      mov r1,r5
01c0d05c  c200                      call r2
01c0d05e  f791                      goto 0x01c0d042
01c0d060  2000                      csync
01c0d062  0286                      add sp,#0x18
01c0d064  5904                      pop {pc,0x9}
01c0d068  6004                      push {rets,0x0}
01c0d06a  4020                      mov r0,#0x0
01c0d06c  4198                      call 0x01c0cf9e
01c0d06e  4004                      pop {0x0}
01c0d072  8100                      rti
01c0d076  6004                      push {rets,0x0}
01c0d078  4021                      mov r0,#0x1
01c0d07a  4191                      call 0x01c0cf9e
01c0d07c  4004                      pop {0x0}
01c0d080  8100                      rti
01c0d082  8000                      rts
01c0d08c  8000                      rts
01c0d092  0300                      hbkpt
01c0d096  0003                      rep 0x2,r0
01c0d09a  0000                      nop
01c0d0a8  c0ff7cf0ee01              mov r0,#0x1eef07c
01c0d0b0  ff03                      rep 0x20,r15
01c0d0c2  0060                      lw r0,[r0 + 0x0]
01c0d0c8  0060                      lw r0,[r0 + 0x0]
01c0d0ca  0060                      lw r0,[r0 + 0x0]
01c0d0d0  1061                      lw r0,[r1 + 0x4]
01c0d0d2  0163                      lw r1,[r0 + 0xc]
01c0d0d4  0162                      lw r1,[r0 + 0x8]
01c0d0d6  0161                      lw r1,[r0 + 0x4]
01c0d0d8  0060                      lw r0,[r0 + 0x0]
01c0d0da  6194                      call 0x01c0d084
01c0d0de  0300                      hbkpt
01c0d0e2  8100                      rti
01c0d0e4  7a04                      push {0xa}
01c0d0e6  caffc003c101              mov r10,#0x1c103c0
01c0d0ee  ae45                      sb r6,[r2 + 0x5]
01c0d0f0  4320                      mov r3,#0x0
01c0d0f2  2443                      jz r4,0x01c0d17a
01c0d0f6  0702                      pfetch [r7]
01c0d0f8  4324                      mov r3,#0x4
01c0d0fa  8b40                      sb r3,[r0 + 0x0]
01c0d0fc  7b30                      mov r3,#0xf0
01c0d0fe  8b41                      sb r3,[r0 + 0x1]
01c0d100  4322                      mov r3,#0x2
01c0d106  49e00400                  movz r9,#0x4
01c0d10a  c014                      clr r8
01c0d10c  048d                      goto 0x01c0d128
01c0d110  5ca0                      qasl r4,r5,0x0
01c0d112  2c46                      lb.z r4,[r2 + 0x6]
01c0d114  bc27                      bitclr r4,0x7
01c0d118  0143                      jz r1,0x01c0d120
01c0d11a  2c63                      lh.z r4,[r2 + 0x6]
01c0d11c  c4a7                      lsr r4,r4,0x7
01c0d11e  ac63                      sh r4,[r2 + 0x6]
01c0d120  2c40                      lb.z r4,[r2 + 0x0]
01c0d122  fc39                      add r4,#-0x7
01c0d124  ac40                      sb r4,[r2 + 0x0]
01c0d126  c321                      add r3,#0x1
01c0d12e  0340                      jz r3,0x01c0d130
01c0d132  0193                      call 0x01c0d15a
01c0d134  c321                      add r3,#0x1
01c0d138  ac65                      sh r4,[r2 + 0xa]
01c0d140  a076                      sw r0,[r2 + -0x28]
01c0d142  0750                      jz r7,0x01c0d164
01c0d146  5ca0                      qasl r4,r5,0x0
01c0d148  5462                      lw r4,[r5 + 0x8]
01c0d14a  4a81                      add r2,r4,#0x1
01c0d14c  d262                      sw r2,[r5 + 0x8]
01c0d14e  4a40                      lb.z r2,[r4 + 0x0]
01c0d152  5c63                      lh.z r4,[r5 + 0x6]
01c0d154  4219                      or r2,r4
01c0d158  f87f                      sh r0,[r7 + -0x2]

;===== FUNC_01c0d15a  (called 1x) =====
01c0d15a  da63                      sh r2,[r5 + 0x6]
01c0d15c  da62                      sh r2,[r5 + 0x4]
01c0d15e  6a88                      add r2,r6,#0x8
01c0d160  da40                      sb r2,[r5 + 0x0]
01c0d162  f782                      goto 0x01c0d128
01c0d164  064c                      jz r6,0x01c0d17e
01c0d16a  ba27                      bitclr r2,0x7
01c0d172  ac85                      add r4,sp,#0x25
01c0d174  c321                      add r3,#0x1
01c0d176  e798                      goto 0x01c0d128
01c0d178  3116                      mov r1,r3
01c0d17a  3017                      uxtb r0,r3
01c0d17c  5a04                      pop {pc,0xa}
01c0d17e  7937                      mov r1,#0xf7
01c0d192  0141                      jz r1,0x01c0d196
01c0d194  3981                      add r1,r3,#0x1
01c0d196  4420                      mov r4,#0x0
01c0d198  1316                      mov r3,r1
01c0d1a0  4020                      mov r0,#0x0
01c0d1a4  ae05                      sw r6,[r2 --= 4]
01c0d1a6  f789                      goto 0x01c0d17a
01c0d1b0  0000                      nop
01c0d1b4  0003                      rep 0x2,r0
01c0d1b6  c0ff00050100              mov r0,#0x10500
01c0d1c0  c0ffc003c101              mov r0,#0x1c103c0
01c0d1c6  016e                      lw r1,[r0 + 0x38]
01c0d1c8  c121                      add r1,#0x1
01c0d1ca  816e                      sw r1,[r0 + 0x38]
01c0d1ce  0100                      idle
01c0d1d0  026d                      lw r2,[r0 + 0x34]
01c0d1d4  0000                      nop
01c0d1dc  fa00                      sti r10
01c0d1e0  0000                      nop
01c0d1e8  8100                      rti

;===== FUNC_01c0d1ea  (called 1x) =====
01c0d1ea  ffea8aeb                  goto 0x01c0a902

;===== FUNC_01c0d1ee  (called 21x) =====
01c0d1ee  7404                      push {0x4}
01c0d1fe  0251                      jz r2,0x01c0d222
01c0d200  1307                      lb.z r3,[r1 ++= 2]
01c0d202  0407                      lb.z r4,[r0 ++= 2]
01c0d204  fa3f                      add r2,#-0x1
01c0d208  fa41                      sb r2,[r7 + 0x1]
01c0d20a  c81e                      sub r0,r4,r3
01c0d20c  5404                      pop {pc,0x4}
01c0d20e  fa3c                      add r2,#-0x4
01c0d210  c124                      add r1,#0x4
01c0d212  c024                      add r0,#0x4
01c0d218  1360                      lw r3,[r1 + 0x0]
01c0d21a  0460                      lw r4,[r0 + 0x0]
01c0d21e  f741                      jnz r7,0x01c0d1e2
01c0d220  f78e                      goto 0x01c0d1fe
01c0d222  4020                      mov r0,#0x0
01c0d224  5404                      pop {pc,0x4}

;===== FUNC_01c0d226  (called 42x) =====
01c0d226  7604                      push {0x6}
01c0d22c  931c                      add r3,r1,r2
01c0d232  0316                      mov r3,r0
01c0d240  0446                      jz r4,0x01c0d24e
01c0d244  0440                      jz r4,0x01c0d246
01c0d246  a21f                      sub r2,r2,r6
01c0d248  1603                      rep 0x4,r6
01c0d24a  1607                      lb.z r6,[r1 ++= 2]
01c0d24c  b607                      sb r6,[r3 ++= 1]
01c0d24e  5c19                      xor r4,r5
01c0d250  a5a2                      lsr r5,r2,0x2
01c0d252  844a                      jnz r4,0x01c0d268
01c0d254  1503                      rep 0x4,r5
01c0d256  1605                      lw r6,[r1 ++= 4]
01c0d258  b605                      sw r6,[r3 ++= 4]
01c0d25a  f55c                      jnz r5,0x01c0d254
01c0d260  1203                      rep 0x4,r2
01c0d262  1207                      lb.z r2,[r1 ++= 2]
01c0d264  b207                      sb r2,[r3 ++= 1]
01c0d266  5604                      pop {pc,0x6}
01c0d268  a503                      rep 0x16,r5
01c0d26a  1607                      lb.z r6,[r1 ++= 2]
01c0d26c  1407                      lb.z r4,[r1 ++= 2]
01c0d270  2044                      jz r0,0x01c0d2fa
01c0d272  1407                      lb.z r4,[r1 ++= 2]
01c0d276  2048                      jz r0,0x01c0d308
01c0d278  1407                      lb.z r4,[r1 ++= 2]
01c0d27c  204c                      jz r0,0x01c0d316
01c0d27e  b605                      sw r6,[r3 ++= 4]
01c0d280  f553                      jnz r5,0x01c0d268
01c0d282  f78c                      goto 0x01c0d25c
01c0d284  831c                      add r3,r0,r2
01c0d286  911c                      add r1,r1,r2
01c0d294  0447                      jz r4,0x01c0d2a4
01c0d296  221f                      sub r2,r2,r4
01c0d298  4616                      mov r6,r4
01c0d29a  3603                      rep 0x8,r6
01c0d29e  1f6f                      lh.z r7,[r1 + 0x1e]
01c0d2a2  3f6f                      lh.z r7,[r3 + 0x1e]
01c0d2a4  5c19                      xor r4,r5
01c0d2a6  a5a2                      lsr r5,r2,0x2
01c0d2a8  844e                      jnz r4,0x01c0d2c6
01c0d2aa  3503                      rep 0x8,r5
01c0d2ae  1e6f                      lh.z r6,[r1 + 0x1e]
01c0d2b2  3f6f                      lh.z r7,[r3 + 0x1e]
01c0d2b4  f55a                      jnz r5,0x01c0d2aa
01c0d2ba  3203                      rep 0x8,r2
01c0d2be  1f6f                      lh.z r7,[r1 + 0x1e]
01c0d2c2  3f6f                      lh.z r7,[r3 + 0x1e]
01c0d2c4  5604                      pop {pc,0x6}
01c0d2c6  f93f                      add r1,#-0x1
01c0d2c8  b503                      rep 0x18,r5
01c0d2ca  1e07                      lb.z r6,[r1 --= 1]
01c0d2cc  66b8                      lsl r6,r6,0x18
01c0d2ce  1c07                      lb.z r4,[r1 --= 1]
01c0d2d2  2048                      jz r0,0x01c0d364
01c0d2d4  1c07                      lb.z r4,[r1 --= 1]
01c0d2d8  2044                      jz r0,0x01c0d362
01c0d2da  1c07                      lb.z r4,[r1 --= 1]
01c0d2dc  4619                      or r6,r4
01c0d2e0  3f6f                      lh.z r7,[r3 + 0x1e]
01c0d2e2  f552                      jnz r5,0x01c0d2c8
01c0d2e4  1981                      add r1,r1,#0x1
01c0d2e6  f787                      goto 0x01c0d2b6

;===== FUNC_01c0d2e8  (called 17x) =====
01c0d2e8  7404                      push {0x4}
01c0d2ea  0316                      mov r3,r0
01c0d2ec  0252                      jz r2,0x01c0d312
01c0d2f0  0340                      jz r3,0x01c0d2f2
01c0d2f6  b107                      sb r1,[r3 ++= 1]
01c0d2f8  f799                      goto 0x01c0d2ec
01c0d2fa  a4a2                      lsr r4,r2,0x2
01c0d302  4018                      add r0,r4
01c0d304  0403                      rep 0x2,r4
01c0d306  b105                      sw r1,[r3 ++= 4]
01c0d308  f45d                      jnz r4,0x01c0d304
01c0d30e  0203                      rep 0x2,r2
01c0d310  b107                      sb r1,[r3 ++= 1]
01c0d312  5404                      pop {pc,0x4}

;===== FUNC_01c0d314  (called 5x) =====
01c0d314  7704                      push {0x7}
01c0d318  0300                      hbkpt
01c0d31a  044b                      jz r4,0x01c0d332
01c0d31e  0440                      jz r4,0x01c0d320
01c0d320  0a40                      lb.z r2,[r0 + 0x0]
01c0d322  2241                      jz r2,0x01c0d3a6
01c0d324  1b40                      lb.z r3,[r1 + 0x0]
01c0d328  3f20                      bittgl r7,0x0
01c0d32a  0881                      add r0,r0,#0x1
01c0d32c  1981                      add r1,r1,#0x1
01c0d336  c6fffffefefe              mov r6,#0xfefefeff
01c0d342  0260                      lw r2,[r0 + 0x0]
01c0d344  1360                      lw r3,[r1 + 0x0]
01c0d34a  1416                      mov r4,r1
01c0d34c  a11d                      add r1,r2,r6
01c0d358  0261                      lw r2,[r0 + 0x4]
01c0d35a  4561                      lw r5,[r4 + 0x4]
01c0d35c  4984                      add r1,r4,#0x4
01c0d35e  0884                      add r0,r0,#0x4
01c0d360  1416                      mov r4,r1
01c0d364  f321                      add r3,#-0x3f
01c0d366  0497                      goto 0x01c0d396
01c0d368  1416                      mov r4,r1
01c0d36a  0260                      lw r2,[r0 + 0x0]
01c0d36c  4307                      lb.z r3,[r4 ++= 2]
01c0d36e  4507                      lb.z r5,[r4 ++= 2]
01c0d372  2054                      jz r0,0x01c0d41c
01c0d374  4507                      lb.z r5,[r4 ++= 2]
01c0d378  2058                      jz r0,0x01c0d42a
01c0d37a  4507                      lb.z r5,[r4 ++= 2]
01c0d37e  205c                      jz r0,0x01c0d438
01c0d384  a51d                      add r5,r2,r6
01c0d388  5352                      jz r3,0x01c0d2ee
01c0d38c  8053                      jnz r0,0x01c0d3b4
01c0d390  0884                      add r0,r0,#0x4
01c0d392  1984                      add r1,r1,#0x4
01c0d394  f789                      goto 0x01c0d368
01c0d396  0a40                      lb.z r2,[r0 + 0x0]
01c0d398  0246                      jz r2,0x01c0d3a6
01c0d39a  1c40                      lb.z r4,[r1 + 0x0]
01c0d3a0  0881                      add r0,r0,#0x1
01c0d3a2  1981                      add r1,r1,#0x1
01c0d3a4  f798                      goto 0x01c0d396
01c0d3a6  4220                      mov r2,#0x0
01c0d3a8  1316                      mov r3,r1
01c0d3aa  3840                      lb.z r0,[r3 + 0x0]
01c0d3ac  201e                      sub r0,r2,r0
01c0d3ae  5704                      pop {pc,0x7}
01c0d3b0  4020                      mov r0,#0x0
01c0d3b2  5704                      pop {pc,0x7}

;===== FUNC_01c0d3b4  (called 8x) =====
01c0d3b4  0116                      mov r1,r0
01c0d3b6  1207                      lb.z r2,[r1 ++= 2]
01c0d3b8  f25e                      jnz r2,0x01c0d3b6
01c0d3ba  f93f                      add r1,#-0x1
01c0d3bc  101e                      sub r0,r1,r0
01c0d3be  8000                      rts
01c0d3c0  0403                      rep 0x2,r4
01c0d3c4  2203                      rep 0x6,r2
01c0d3d0  2000                      csync
01c0d3e6  2203                      rep 0x6,r2
01c0d408  2a03                      rep 0x6,r10
01c0d410  2000                      csync
01c0d424  2000                      csync
01c0d432  0902                      pfetch [r9]
01c0d434  0000                      nop
01c0d436  0001                      tbb r0
01c0d438  0080                      rep 0x2,0x0
01c0d43c  0355                      jz r3,0x01c0d468
01c0d43e  0053                      jz r0,0x01c0d466
01c0d440  0042                      jz r0,0x01c0d446
01c0d444  004d                      jz r0,0x01c0d460
01c0d446  0069                      lw r0,[r0 + 0x24]
01c0d448  0064                      lw r0,[r0 + 0x10]
01c0d44a  0069                      lw r0,[r0 + 0x24]
01c0d44c  0000                      nop
01c0d44e  0000                      nop
01c0d450  0000                      nop
01c0d452  0000                      nop
01c0d454  0000                      nop
01c0d456  0000                      nop
01c0d45c  0000                      nop
01c0d45e  0000                      nop
01c0d460  0000                      nop
01c0d462  0000                      nop
01c0d468  0000                      nop
01c0d46a  0000                      nop
01c0d46c  0000                      nop
01c0d46e  0000                      nop
01c0d470  564d                      jz r6,0x01c0d3cc
01c0d472  0042                      jz r0,0x01c0d478
01c0d474  5449                      jz r4,0x01c0d3c8
01c0d478  5554                      jz r5,0x01c0d3e2
01c0d47a  5458                      jz r4,0x01c0d3ec
01c0d47c  0055                      jz r0,0x01c0d4a8
01c0d47e  5442                      jz r4,0x01c0d3c4
01c0d482  2e62                      lh.z r6,[r2 + 0x4]
01c0d484  696e                      lh.z r1,[r6 + 0x1c]
01c0d486  0066                      lw r0,[r0 + 0x18]
01c0d488  6c61                      lh.z r4,[r6 + 0x2]
01c0d48a  7368                      lw r3,[r7 + 0x20]
01c0d48c  0055                      jz r0,0x01c0d4b8
01c0d48e  5342                      jz r3,0x01c0d3d4
01c0d490  4450                      jz r4,0x01c0d3b2
01c0d492  0055                      jz r0,0x01c0d4be
01c0d494  5342                      jz r3,0x01c0d3da
01c0d496  444d                      jz r4,0x01c0d3b2
01c0d498  0000                      nop
01c0d49c  0100                      idle
01c0d49e  0000                      nop
01c0d4a0  ff00                      sti r15
01c0d4a4  0100                      idle
01c0d4a6  0001                      tbb r0
01c0d4a8  fe00                      sti r14
01c0d4aa  0000                      nop
01c0d4ac  0018                      add r0,r0
01c0d4ae  0100                      idle
01c0d4b0  0000                      nop
01c0d4b2  0000                      nop
01c0d4b8  0000                      nop
01c0d4ba  0000                      nop
01c0d4be  0000                      nop
01c0d4c0  0001                      tbb r0
01c0d4c2  0100                      idle
01c0d4c8  0001                      tbb r0
01c0d4cc  0101                      tbb r1
01c0d4ce  0000                      nop
01c0d4d0  0000                      nop
01c0d4d2  0000                      nop
01c0d4d4  0000                      nop
01c0d4d6  0000                      nop
01c0d4dc  0000                      nop
01c0d4de  0000                      nop
01c0d4e0  0000                      nop
01c0d4e2  0000                      nop
01c0d4e8  0059                      jz r0,0x01c0d51c
01c0d4ea  1206                      lh.z r2,[r1 ++= 2]
01c0d4ec  0000                      nop
01c0d4ee  0000                      nop
01c0d4f0  0000                      nop
01c0d4f2  0000                      nop
01c0d4f4  ff06                      sh r7,[r7 --= 2]
01c0d4f6  2402                      flush [r4]
01c0d4f8  0101                      tbb r1
01c0d4fc  2403                      rep 0x6,r4
01c0d4fe  0202                      pfetch [r2]
01c0d500  0101                      tbb r1
01c0d502  0100                      idle
01c0d506  0301                      tbb r3
01c0d508  0801                      tbb r8
01c0d50a  0701                      tbb r7
01c0d50c  0006                      lh.z r0,[r0 ++= 2]
01c0d50e  2402                      flush [r4]
01c0d510  0207                      lb.z r2,[r0 ++= 2]
01c0d516  0002                      pfetch [r0]
01c0d518  0103                      rep 0x2,r1
01c0d51a  0000                      nop
01c0d51e  0100                      idle
01c0d520  0141                      jz r1,0x01c0d524
01c0d522  0000                      nop
01c0d524  0401                      tbb r4
01c0d526  0502                      pfetch [r5]
01c0d528  0603                      rep 0x2,r6
01c0d534  0584                      goto 0x01c0d93e
01c0d536  0240                      jz r2,0x01c0d538
01c0d538  0000                      nop
01c0d53a  0000                      nop
01c0d53e  0101                      tbb r1
01c0d544  0240                      jz r2,0x01c0d546
01c0d546  0000                      nop
01c0d548  0000                      nop
01c0d54c  0101                      tbb r1
01c0d54e  0100                      idle
01c0d550  0100                      idle
01c0d552  0000                      nop
01c0d554  0200                      bkpt
01c0d556  0000                      nop
01c0d55a  0000                      nop
01c0d55e  0000                      nop
01c0d562  0000                      nop
01c0d564  2000                      csync
01c0d566  0000                      nop
01c0d568  4000                      lockclr
01c0d56a  0000                      nop
01c0d56c  8000                      rts
01c0d56e  0000                      nop
01c0d570  0001                      tbb r0
01c0d572  0000                      nop
01c0d574  0002                      pfetch [r0]
01c0d576  0000                      nop
01c0d578  0004                      pop pc
01c0d57a  0000                      nop
01c0d57e  0000                      nop
01c0d582  0000                      nop
01c0d586  0000                      nop
01c0d588  0040                      jz r0,0x01c0d58a
01c0d58a  0000                      nop
01c0d58c  0080                      rep 0x2,0x0
01c0d58e  0000                      nop
01c0d590  7375                      lw r3,[r7 + -0x2c]
01c0d592  6363                      lw r3,[r6 + 0xc]
01c0d594  6573                      lw r5,[r6 + -0x34]
01c0d598  5550                      jz r5,0x01c0d4fa
01c0d59a  4441                      jz r4,0x01c0d49e
01c0d59c  5445                      jz r4,0x01c0d4e8
01c0d59e  5f4a                      lb.z r7,[r5 + 0xa]
01c0d5a0  554d                      jz r5,0x01c0d4fc
01c0d5a4  504f                      jz r0,0x01c0d504
01c0d5a6  5745                      jz r7,0x01c0d4f2
01c0d5a8  525f                      jz r2,0x01c0d528
01c0d5aa  5049                      jz r0,0x01c0d4fe
01c0d5ae  6366                      lw r3,[r6 + 0x18]
01c0d5b0  675f                      jz r7,0x01c0d570
01c0d5b2  746f                      lw r4,[r7 + 0x3c]
01c0d5b4  6f6c                      lh.z r7,[r6 + 0x18]
01c0d5b6  2e62                      lh.z r6,[r2 + 0x4]
01c0d5b8  696e                      lh.z r1,[r6 + 0x1c]
01c0d5ba  0066                      lw r0,[r0 + 0x18]
01c0d5bc  6c61                      lh.z r4,[r6 + 0x2]
01c0d5be  7368                      lw r3,[r7 + 0x20]
01c0d5c0  2e62                      lh.z r6,[r2 + 0x4]
01c0d5c2  696e                      lh.z r1,[r6 + 0x1c]
01c0d5c4  0000                      nop
01c0d5c6  0000                      nop
01c0d5c8  0000                      nop
01c0d5cc  4000                      lockclr
01c0d5d0  8000                      rts
01c0d5d4  c000                      call r0
01c0d5d8  0001                      tbb r0
01c0d5e8  6170                      lw r1,[r6 + -0x40]
01c0d5ea  705f                      jz r0,0x01c0d5ea
01c0d5ec  6469                      lw r4,[r6 + 0x24]
01c0d5ee  725f                      jz r2,0x01c0d5ee
01c0d5f0  6865                      lh.z r0,[r6 + 0xa]
01c0d5f2  6164                      lw r1,[r6 + 0x10]
01c0d5f4  0000                      nop
01c0d5f6  0000                      nop
01c0d5f8  0000                      nop
01c0d5fa  0000                      nop
01c0d5fe  0000                      nop
01c0d600  0000                      nop
01c0d602  0100                      idle
01c0d604  7562                      lw r5,[r7 + 0x8]
01c0d606  6f6f                      lh.z r7,[r6 + 0x1e]
01c0d608  742e                      mov r4,#0xce
01c0d60a  626f                      lw r2,[r6 + 0x3c]
01c0d60c  6f74                      lh.z r7,[r6 + -0x18]
01c0d60e  0069                      lw r0,[r0 + 0x24]
01c0d610  7364                      lw r3,[r7 + 0x10]
01c0d612  5f63                      lh.z r7,[r5 + 0x6]
01c0d614  6f6e                      lh.z r7,[r6 + 0x1c]
01c0d616  6669                      lw r6,[r6 + 0x24]
01c0d618  672e                      mov r7,#0x8e
01c0d61a  696e                      lh.z r1,[r6 + 0x1c]
01c0d61e  564d                      jz r6,0x01c0d57a
01c0d620  0000                      nop

;===== FUNC_01c0d622  (called 25x) =====
01c0d622  7504                      push {0x5}
01c0d624  0516                      mov r5,r0
01c0d626  0552                      jz r5,0x01c0d64c
01c0d628  5c82                      add r4,r5,#0x2
01c0d62a  413e                      mov r1,#0x1e
01c0d62c  4016                      mov r0,r4
01c0d62e  bfea68e9                  call 0x01c0a902
01c0d634  5a60                      lh.z r2,[r5 + 0x0]
01c0d63c  4020                      mov r0,#0x0
01c0d63e  8145                      jnz r1,0x01c0d64a
01c0d640  4960                      lh.z r1,[r4 + 0x0]
01c0d646  0000                      nop
01c0d648  4020                      mov r0,#0x0
01c0d64a  5504                      pop {pc,0x5}
01c0d64e  5504                      pop {pc,0x5}

;===== FUNC_01c0d650  (called 1x) =====
01c0d650  7404                      push {0x4}
01c0d652  e297                      add sp,#-0x24
01c0d654  c0ff7002c101              mov r0,#0x1c10270
01c0d65a  0060                      lw r0,[r0 + 0x0]
01c0d65c  4420                      mov r4,#0x0
01c0d660  6000                      cli
01c0d664  c0ffffff0000              mov r0,#0xffff
01c0d66a  8a84                      add r2,sp,#0x4
01c0d66c  4b20                      mov r3,#0x20
01c0d66e  bfeabcea                  call 0x01c0abea
01c0d678  c2ffcc12c101              mov r2,#0x1c112cc
01c0d67e  a060                      sw r0,[r2 + 0x0]
01c0d680  90a8                      lsr r0,r1,0x8
01c0d682  c021                      add r0,#0x1
01c0d684  0017                      uxtb r0,r0
01c0d686  11a4                      lsl r1,r1,0x4
01c0d688  c130                      add r1,#0x10
01c0d68c  7f1e                      sub r7,r7,r1
01c0d68e  1018                      add r0,r1
01c0d690  c1ffd012c101              mov r1,#0x1c112d0
01c0d696  9860                      sh r0,[r1 + 0x0]
01c0d698  0289                      add sp,#0x24
01c0d69a  5404                      pop {pc,0x4}

;===== FUNC_01c0d69c  (called 2x) =====
01c0d69c  7d04                      push {0xd}
01c0d69e  e297                      add sp,#-0x24
01c0d6a0  c514                      clr r13
01c0d6a2  ccfff8d5c001              mov r12,#0x1c0d5f8
01c0d6a8  c4ffffff0000              mov r4,#0xffff
01c0d6ae  caff7002c101              mov r10,#0x1c10270
01c0d6b4  cbffd812c101              mov r11,#0x1c112d8
01c0d6ba  c8ffd912c101              mov r8,#0x1c112d9
01c0d6c0  c9ffd412c101              mov r9,#0x1c112d4
01c0d6c6  4720                      mov r7,#0x0
01c0d6ca  ca57                      sb r2,[r4 + -0x9]
01c0d6ce  2050                      jz r0,0x01c0d770
01c0d6d0  8e84                      add r6,sp,#0x4
01c0d6d2  4b20                      mov r3,#0x20
01c0d6d8  4016                      mov r0,r4
01c0d6da  6216                      mov r2,r6
01c0d6dc  bfea85ea                  call 0x01c0abea
01c0d6e0  6016                      mov r0,r6
01c0d6e2  419f                      call 0x01c0d622
01c0d6e4  804b                      jnz r0,0x01c0d6fc
01c0d6e6  8e84                      add r6,sp,#0x4
01c0d6e8  4b20                      mov r3,#0x20
01c0d6ee  4015                      mov r0_r1,r4_r5
01c0d6f0  6216                      mov r2,r6
01c0d6f2  bfea7aea                  call 0x01c0abea
01c0d6f6  6016                      mov r0,r6
01c0d6f8  4194                      call 0x01c0d622
01c0d6fa  0050                      jz r0,0x01c0d71c
01c0d6fc  c721                      add r7,#0x1
01c0d700  e307                      sb r3,[r6 ++= 1]
01c0d704  00a0                      lsl r0,r0,0x0
01c0d706  4030                      mov r0,#0x10
01c0d70a  009a                      rep 0x2,0x1a
01c0d70e  b000                      testset b[r0]
01c0d710  402b                      mov r0,#0xb
01c0d714  8000                      rts
01c0d716  bfea26ea                  call 0x01c0ab66
01c0d71a  0494                      goto 0x01c0d744
01c0d728  a150                      jnz r1,0x01c0d7ca
01c0d72c  b000                      testset b[r0]
01c0d736  c0ffdc12c101              mov r0,#0x1c112dc
01c0d73c  8984                      add r1,sp,#0x4
01c0d73e  4a20                      mov r2,#0x20
01c0d740  bfea71fd                  call 0x01c0d226
01c0d746  b000                      testset b[r0]
01c0d74a  0180                      call 0x01c0d74c

;===== FUNC_01c0d74c  (called 1x) =====
01c0d74c  c0ff7502c101              mov r0,#0x1c10275
01c0d752  4121                      mov r1,#0x1
01c0d754  8940                      sb r1,[r0 + 0x0]
01c0d756  bfea7bff                  call 0x01c0d650
01c0d75a  c0ffd012c101              mov r0,#0x1c112d0
01c0d760  0860                      lh.z r0,[r0 + 0x0]
01c0d762  0289                      add sp,#0x24
01c0d764  5d04                      pop {pc,0xd}

;===== FUNC_01c0d766  (called 3x) =====
01c0d766  7804                      push {0x8}
01c0d768  a286                      add sp,#-0x168
01c0d76a  1816                      mov r8,r1
01c0d76c  0516                      mov r5,r0
01c0d76e  c888                      add r0,sp,#0x48
01c0d770  4120                      mov r1,#0x0
01c0d772  42e00001                  movz r2,#0x100
01c0d776  4620                      mov r6,#0x0
01c0d778  bfeab6fd                  call 0x01c0d2e8
01c0d77c  c4ff7002c101              mov r4,#0x1c10270
01c0d782  4060                      lw r0,[r4 + 0x0]
01c0d786  4000                      lockclr
01c0d78a  c0ffffff0000              mov r0,#0xffff
01c0d792  4871                      lh.z r0,[r4 + -0x1e]
01c0d794  4b20                      mov r3,#0x20
01c0d796  7216                      mov r2,r7
01c0d798  bfea27ea                  call 0x01c0abea
01c0d79c  7016                      mov r0,r7
01c0d79e  bfea40ff                  call 0x01c0d622
01c0d7a2  905c                      jnz r0,0x01c0d81c
01c0d7a6  5021                      mov r0,#0x41
01c0d7ac  4060                      lw r0,[r4 + 0x0]
01c0d7b2  0118                      add r1,r0
01c0d7b4  c888                      add r0,sp,#0x48
01c0d7b6  4320                      mov r3,#0x0
01c0d7b8  4420                      mov r4,#0x0
01c0d7ba  80ea0d12                  call 0x01c0fbd8
01c0d7c0  4740                      jz r7,0x01c0d6c2
01c0d7c2  4f22                      mov r7,#0x22
01c0d7c4  0483                      goto 0x01c0d7cc
01c0d7ca  071d                      add r7,r0,r4
01c0d7cc  c888                      add r0,sp,#0x48
01c0d7ce  891d                      add r1,r0,r7
01c0d7d0  c887                      add r0,sp,#0x47
01c0d7d2  4221                      mov r2,#0x1
01c0d7d4  bfea27fd                  call 0x01c0d226
01c0d7dc  005e                      jz r0,0x01c0d81a
01c0d7e2  c888                      add r0,sp,#0x48
01c0d7e4  7018                      add r0,r7
01c0d7e6  0981                      add r1,r0,#0x1
01c0d7e8  8e87                      add r6,sp,#0x7
01c0d7ea  5220                      mov r2,#0x40
01c0d7ec  6016                      mov r0,r6
01c0d7ee  bfea1afd                  call 0x01c0d226
01c0d7f2  6016                      mov r0,r6
01c0d7f4  bfeadefd                  call 0x01c0d3b4
01c0d7f8  7018                      add r0,r7
01c0d7fa  0c82                      add r4,r0,#0x2
01c0d7fc  6016                      mov r0,r6
01c0d7fe  5116                      mov r1,r5
01c0d800  bfea88fd                  call 0x01c0d314
01c0d804  f040                      jnz r0,0x01c0d7c6
01c0d808  4720                      mov r7,#0x0
01c0d80a  c888                      add r0,sp,#0x48
01c0d80c  011d                      add r1,r0,r4
01c0d80e  8016                      mov r0,r8
01c0d810  bfea09fd                  call 0x01c0d226
01c0d816  4760                      lw r7,[r4 + 0x0]
01c0d818  0481                      goto 0x01c0d81c
01c0d81a  4620                      mov r6,#0x0
01c0d81c  6016                      mov r0,r6
01c0d81e  429a                      add sp,#0x168
01c0d820  5804                      pop {pc,0x8}

;===== FUNC_01c0d822  (called 1x) =====
01c0d822  7504                      push {0x5}
01c0d824  1416                      mov r4,r1
01c0d826  0116                      mov r1,r0
01c0d828  c5ff78d4c001              mov r5,#0x1c0d478
01c0d82e  5016                      mov r0,r5
01c0d830  419a                      call 0x01c0d766
01c0d832  5885                      add r0,r5,#0x5
01c0d834  4116                      mov r1,r4
01c0d836  3504                      pop {rets,0x5}
01c0d838  c796                      goto 0x01c0d766

;===== FUNC_01c0d83a  (called 4x) =====
01c0d83a  7a04                      push {0xa}
01c0d83c  e297                      add sp,#-0x24
01c0d83e  c1ff7002c101              mov r1,#0x1c10270
01c0d846  1160                      lw r1,[r1 + 0x0]
01c0d848  c2ffcc12c101              mov r2,#0x1c112cc
01c0d84e  2260                      lw r2,[r2 + 0x0]
01c0d850  c3ffc003c101              mov r3,#0x1c103c0
01c0d858  3490                      goto 0x01c0d93a
01c0d85c  2081                      rep 0x6,0x1
01c0d85e  bfea38ea                  call 0x01c0acd2
01c0d862  8c84                      add r4,sp,#0x4
01c0d864  4ae0ffff                  movz r10,#0xffff
01c0d868  4e20                      mov r6,#0x20
01c0d86a  048e                      goto 0x01c0d888
01c0d86c  484c                      lb.z r0,[r4 + 0xc]
01c0d872  5262                      lw r2,[r5 + 0x8]
01c0d874  0246                      jz r2,0x01c0d882
01c0d876  5161                      lw r1,[r5 + 0x4]
01c0d878  8884                      add r0,sp,#0x4
01c0d87a  c200                      call r2
01c0d87e  d060                      sw r0,[r5 + 0x0]
01c0d880  8051                      jnz r0,0x01c0d8a4
01c0d882  4867                      lh.z r0,[r4 + 0xe]
01c0d884  8050                      jnz r0,0x01c0d8a6
01c0d886  ce20                      add r6,#0x20
01c0d88a  8016                      mov r0,r8
01c0d88e  8f84                      add r7,sp,#0x4
01c0d890  4b20                      mov r3,#0x20
01c0d892  9016                      mov r0,r9
01c0d894  7216                      mov r2,r7
01c0d896  bfeaa8e9                  call 0x01c0abea
01c0d89a  7016                      mov r0,r7
01c0d89c  bfeac1fe                  call 0x01c0d622
01c0d8a0  7045                      jz r0,0x01c0d86c
01c0d8a2  0481                      goto 0x01c0d8a6
01c0d8a4  0a16                      mov r10,r0
01c0d8a6  a016                      mov r0,r10
01c0d8a8  0289                      add sp,#0x24
01c0d8aa  5a04                      pop {pc,0xa}

;===== FUNC_01c0d8ac  (called 3x) =====
01c0d8ac  7904                      push {0x9}
01c0d8ae  e296                      add sp,#-0x28
01c0d8b0  c6ff70d4c001              mov r6,#0x1c0d470
01c0d8b8  6407                      lb.z r4,[r6 ++= 2]
01c0d8bc  6c26                      mov r4,#0xa6
01c0d8c4  8884                      add r0,sp,#0x4
01c0d8c6  5199                      call 0x01c0d83a
01c0d8c8  0981                      add r1,r0,#0x1
01c0d8ca  c4ffd015c101              mov r4,#0x1c115d0
01c0d8d2  5204                      pop {pc,0x2}
01c0d8d6  6806                      lh.z r0,[r6 --= 2]
01c0d8da  6026                      mov r0,#0x86
01c0d8e2  4520                      mov r5,#0x0
01c0d8e6  889c                      add r0,sp,#0x1c
01c0d8ea  c0ff84f6c001              mov r0,#0x1c0f684
01c0d8f2  8890                      add r0,sp,#0x10
01c0d8f4  5182                      call 0x01c0d83a
01c0d8f8  1c80                      add r4,r1,#0x0
01c0d8fa  c0ff7002c101              mov r0,#0x1c10270
01c0d902  0160                      lw r1,[r0 + 0x0]
01c0d904  c0ffffff0000              mov r0,#0xffff
01c0d90a  4b20                      mov r3,#0x20
01c0d90e  bfea6ce9                  call 0x01c0abea
01c0d912  4016                      mov r0,r4
01c0d914  bfea85fe                  call 0x01c0d622
01c0d918  a046                      jnz r0,0x01c0d9a6
01c0d91a  80eaa211                  call 0x01c0fc62
01c0d920  494d                      lb.z r1,[r4 + 0xd]
01c0d922  1016                      mov r0,r1
01c0d926  0100                      idle
01c0d928  4020                      mov r0,#0x0
01c0d92a  00a8                      lsl r0,r0,0x8
01c0d92c  47e00010                  movz r7,#0x1000
01c0d934  0716                      mov r7,r0
01c0d93a  005c                      jz r0,0x01c0d974
01c0d93c  49e04154                  movz r9,#0x5441
01c0d940  bfeac7e9                  call 0x01c0acd2
01c0d946  006f                      lw r0,[r0 + 0x3c]
01c0d948  5230                      mov r2,#0x50
01c0d94a  4015                      mov r0_r1,r4_r5
01c0d94c  80ea5011                  call 0x01c0fbf0
01c0d950  4882                      add r0,r4,#0x2
01c0d952  512e                      mov r1,#0x4e
01c0d954  bfead5e7                  call 0x01c0a902
01c0d958  004a                      jz r0,0x01c0d96e
01c0d95a  4960                      lh.z r1,[r4 + 0x0]
01c0d960  4861                      lh.z r0,[r4 + 0x2]
01c0d966  0300                      hbkpt
01c0d968  4863                      lh.z r0,[r4 + 0x6]
01c0d96e  ee1f                      sub r6,r6,r7
01c0d972  e681                      goto 0x01c0d4f6
01c0d974  4520                      mov r5,#0x0
01c0d976  0497                      goto 0x01c0d9a6
01c0d97c  5230                      mov r2,#0x50
01c0d97e  4015                      mov r0_r1,r4_r5
01c0d980  80ea3611                  call 0x01c0fbf0
01c0d984  4882                      add r0,r4,#0x2
01c0d986  512e                      mov r1,#0x4e
01c0d988  bfeabbe7                  call 0x01c0a902
01c0d98c  5043                      jz r0,0x01c0d8d4
01c0d98e  4960                      lh.z r1,[r4 + 0x0]
01c0d994  4861                      lh.z r0,[r4 + 0x2]
01c0d99e  4154                      jz r1,0x01c0d8c8
01c0d9a0  4863                      lh.z r0,[r4 + 0x6]
01c0d9a6  5016                      mov r0,r5
01c0d9a8  028a                      add sp,#0x28
01c0d9aa  5904                      pop {pc,0x9}

;===== FUNC_01c0d9ac  (called 1x) =====
01c0d9ac  7604                      push {0x6}
01c0d9ae  c5ff80fdc701              mov r5,#0x1c7fd80
01c0d9b4  5c8a                      add r4,r5,#0xa
01c0d9b6  512e                      mov r1,#0x4e
01c0d9b8  4016                      mov r0,r4
01c0d9ba  bfeaa2e7                  call 0x01c0a902
01c0d9be  004c                      jz r0,0x01c0d9d8
01c0d9c0  5964                      lh.z r1,[r5 + 0x8]
01c0d9c6  bfea71ff                  call 0x01c0d8ac
01c0d9ca  0116                      mov r1,r0
01c0d9ce  0080                      rep 0x2,0x0
01c0d9d0  5888                      add r0,r5,#0x8
01c0d9d2  5230                      mov r2,#0x50
01c0d9d4  80ea0c11                  call 0x01c0fbf0
01c0d9da  5e64                      lh.z r6,[r5 + 0x8]
01c0d9dc  512e                      mov r1,#0x4e
01c0d9de  bfea90e7                  call 0x01c0a902
01c0d9e2  0116                      mov r1,r0
01c0d9e4  4020                      mov r0,#0x0
01c0d9e8  0960                      lh.z r1,[r0 + 0x0]
01c0d9ec  0a5a                      lb.z r2,[r0 + -0x6]
01c0d9ee  5965                      lh.z r1,[r5 + 0xa]
01c0d9f0  402c                      mov r0,#0xc
01c0d9f4  0002                      pfetch [r0]
01c0d9f6  4020                      mov r0,#0x0
01c0d9f8  5018                      add r0,r5
01c0d9fa  006c                      lw r0,[r0 + 0x30]
01c0d9fc  5604                      pop {pc,0x6}

;===== FUNC_01c0d9fe  (called 2x) =====
01c0d9fe  7504                      push {0x5}
01c0da00  bfea54ff                  call 0x01c0d8ac
01c0da04  0116                      mov r1,r0
01c0da06  1144                      jz r1,0x01c0da50
01c0da08  c4ffd015c101              mov r4,#0x1c115d0
01c0da0e  5a30                      mov r2,#0x70
01c0da10  4016                      mov r0,r4
01c0da12  80eaed10                  call 0x01c0fbf0
01c0da16  4016                      mov r0,r4
01c0da18  0506                      lh.z r5,[r0 ++= 2]
01c0da1a  512e                      mov r1,#0x4e
01c0da1c  bfea71e7                  call 0x01c0a902
01c0da22  1650                      jz r6,0x01c0da84
01c0da24  c5ff88fdc701              mov r5,#0x1c7fd88
01c0da2a  5230                      mov r2,#0x50
01c0da2c  5016                      mov r0,r5
01c0da2e  4116                      mov r1,r4
01c0da30  bfeaf9fb                  call 0x01c0d226
01c0da36  5050                      jz r0,0x01c0d998
01c0da3a  5040                      jz r0,0x01c0d97c
01c0da3c  4a20                      mov r2,#0x20
01c0da3e  bfeaf2fb                  call 0x01c0d226
01c0da42  5988                      add r1,r5,#0x8
01c0da44  c0ffc002c101              mov r0,#0x1c102c0
01c0da4a  4a20                      mov r2,#0x20
01c0da4c  bfeaebfb                  call 0x01c0d226
01c0da50  5504                      pop {pc,0x5}

;===== FUNC_01c0da52  (called 2x) =====
01c0da52  7404                      push {0x4}
01c0da54  0416                      mov r4,r0
01c0da56  bfeaadfc                  call 0x01c0d3b4
01c0da5a  4120                      mov r1,#0x0
01c0da5c  1217                      uxtb r2,r1
01c0da64  4022                      mov r0,#0x2
01c0da66  c121                      add r1,#0x1
01c0da6a  f8bf                      qasr r0,r7,0x1f
01c0da6c  0481                      goto 0x01c0da70
01c0da6e  4120                      mov r1,#0x0
01c0da70  1017                      uxtb r0,r1
01c0da72  5404                      pop {pc,0x4}

;===== FUNC_01c0da74  (called 1x) =====
01c0da74  7804                      push {0x8}
01c0da76  e298                      add sp,#-0x20
01c0da78  8980                      add r1,sp,#0x0
01c0da7a  4420                      mov r4,#0x0
01c0da7c  1016                      mov r0,r1
01c0da7e  009f                      rep 0x2,0x1f
01c0da80  8407                      sb r4,[r0 ++= 1]
01c0da82  c0ffa4d5c001              mov r0,#0x1c0d5a4
01c0da88  bfea6dfe                  call 0x01c0d766
01c0da8c  005d                      jz r0,0x01c0dac8
01c0da8e  4620                      mov r6,#0x0
01c0da90  8d80                      add r5,sp,#0x0
01c0da92  c7ff2804c101              mov r7,#0x1c10428
01c0da98  c8ffb403c101              mov r8,#0x1c103b4
01c0da9e  5016                      mov r0,r5
01c0daa0  bfea37e9                  call 0x01c0ad12
01c0daa6  7b06                      lh.z r3,[r7 --= 2]
01c0daa8  5016                      mov r0,r5
01c0daaa  6193                      call 0x01c0da52
01c0daac  4421                      mov r4,#0x1
01c0daae  004c                      jz r0,0x01c0dac8
01c0dab0  0518                      add r5,r0
01c0dab2  5841                      lb.z r0,[r5 + 0x1]
01c0dab4  f030                      add r0,#-0x30
01c0daba  5016                      mov r0,r5
01c0dabc  618a                      call 0x01c0da52
01c0dabe  0044                      jz r0,0x01c0dac8
01c0dac0  c621                      add r6,#0x1
01c0dac2  0518                      add r5,r0
01c0dac6  eb07                      sb r3,[r6 --= 1]
01c0dac8  4016                      mov r0,r4
01c0daca  0288                      add sp,#0x20
01c0dacc  5804                      pop {pc,0x8}

;===== FUNC_01c0dace  (called 5x) =====
01c0dace  1004                      push rets
01c0dad0  0316                      mov r3,r0
01c0dad2  1016                      mov r0,r1
01c0dad4  bfea53ed                  call 0x01c0b57e
01c0dad8  a217                      uxth r2,r2
01c0dada  4020                      mov r0,#0x0
01c0dadc  3116                      mov r1,r3
01c0dae0  ffeaaeee                  goto 0x01c0b840
01c0dae6  0080                      rep 0x2,0x0
01c0dae8  c2ffb002c101              mov r2,#0x1c102b0
01c0daee  2260                      lw r2,[r2 + 0x0]
01c0daf0  8260                      sw r2,[r0 + 0x0]
01c0daf4  0080                      rep 0x2,0x0
01c0daf6  c0ffb402c101              mov r0,#0x1c102b4
01c0dafc  0060                      lw r0,[r0 + 0x0]
01c0dafe  9060                      sw r0,[r1 + 0x0]
01c0db00  8000                      rts

;===== FUNC_01c0db02  (called 1x) =====
01c0db02  c2ffd012c101              mov r2,#0x1c112d0
01c0db08  2a60                      lh.z r2,[r2 + 0x0]
01c0db0c  0080                      rep 0x2,0x0
01c0db0e  c3ff7002c101              mov r3,#0x1c10270
01c0db14  3360                      lw r3,[r3 + 0x0]
01c0db16  8360                      sw r3,[r0 + 0x0]
01c0db1a  0040                      jz r0,0x01c0db1c
01c0db1c  20ac                      lsl r0,r2,0xc
01c0db1e  9060                      sw r0,[r1 + 0x0]
01c0db20  8000                      rts

;===== FUNC_01c0db22  (called 5x) =====
01c0db22  7a04                      push {0xa}
01c0db24  c3ff7002c101              mov r3,#0x1c10270
01c0db2c  3660                      lw r6,[r3 + 0x0]
01c0db30  5004                      pop {pc,0x0}
01c0db32  2716                      mov r7,r2
01c0db34  8047                      jnz r0,0x01c0db44
01c0db36  8746                      jnz r7,0x01c0db44
01c0db3a  804d                      jnz r0,0x01c0db56
01c0db3e  0060                      lw r0,[r0 + 0x0]
01c0db40  45e00010                  movz r5,#0x1000
01c0db44  80ea3611                  call 0x01c0fdb4
01c0db4a  0040                      jz r0,0x01c0db4c
01c0db4c  4021                      mov r0,#0x1
01c0db4e  80ea8d10                  call 0x01c0fc6c
01c0db52  c9ff7402c101              mov r9,#0x1c10274
01c0db5e  006e                      lw r0,[r0 + 0x38]
01c0db60  c8ffd015c101              mov r8,#0x1c115d0
01c0db68  3402                      flushinv [r4]
01c0db6a  42e00002                  movz r2,#0x200
01c0db6e  8016                      mov r0,r8
01c0db70  a116                      mov r1,r10
01c0db72  80ea3d10                  call 0x01c0fbf0
01c0db76  41e00002                  movz r1,#0x200
01c0db7a  8016                      mov r0,r8
01c0db7c  bfeac1e6                  call 0x01c0a902
01c0db80  41e0a17f                  movz r1,#0x7fa1
01c0db86  2200                      ssync
01c0db88  4621                      mov r6,#0x1
01c0db8c  0000                      nop
01c0db8e  7616                      mov r6,r7
01c0db90  1744                      jz r7,0x01c0dbda
01c0db98  2002                      flush [r0]
01c0db9a  501d                      add r0,r5,r4
01c0dba0  42e00002                  movz r2,#0x200
01c0dba4  8016                      mov r0,r8
01c0dba6  80ea2310                  call 0x01c0fbf0
01c0dbaa  41e00002                  movz r1,#0x200
01c0dbae  8016                      mov r0,r8
01c0dbb0  bfeaa7e6                  call 0x01c0a902
01c0dbb4  41e0a17f                  movz r1,#0x7fa1
01c0dbb8  4621                      mov r6,#0x1
01c0dbbe  42e00002                  movz r2,#0x200
01c0dbc2  8016                      mov r0,r8
01c0dbc4  a116                      mov r1,r10
01c0dbc6  80ea1a11                  call 0x01c0fdfe
01c0dbca  048c                      goto 0x01c0dbe4
01c0dbcc  4022                      mov r0,#0x2
01c0dbd2  4621                      mov r6,#0x1
01c0dbd6  0000                      nop
01c0dbd8  7616                      mov r6,r7
01c0dbda  8644                      jnz r6,0x01c0dbe4
01c0dbe2  0402                      pfetch [r4]
01c0dbe4  4015                      mov r0_r1,r4_r5
01c0dbe6  019e                      call 0x01c0dc24
01c0dbec  005a                      jz r0,0x01c0dc22
01c0dbf0  0160                      lw r1,[r0 + 0x0]
01c0dbf2  8057                      jnz r0,0x01c0dc22
01c0dbf4  42e00002                  movz r2,#0x200
01c0dbf8  8016                      mov r0,r8
01c0dbfa  a116                      mov r1,r10
01c0dbfc  80eaf80f                  call 0x01c0fbf0
01c0dc00  41e00002                  movz r1,#0x200
01c0dc04  8016                      mov r0,r8
01c0dc06  bfea7ce6                  call 0x01c0a902
01c0dc0a  41e0a17f                  movz r1,#0x7fa1
01c0dc12  501d                      add r0,r5,r4
01c0dc18  42e00002                  movz r2,#0x200
01c0dc1c  8016                      mov r0,r8
01c0dc1e  80eaee10                  call 0x01c0fdfe
01c0dc22  5a04                      pop {pc,0xa}

;===== FUNC_01c0dc24  (called 6x) =====
01c0dc24  7d04                      push {0xd}
01c0dc26  e29c                      add sp,#-0x10
01c0dc28  1616                      mov r6,r1
01c0dc2a  0416                      mov r4,r0
01c0dc2e  4c98                      add r4,r4,#0x18
01c0dc34  8880                      add r0,sp,#0x0
01c0dc36  4230                      mov r2,#0x10
01c0dc38  9116                      mov r1,r9
01c0dc3a  bfea48ff                  call 0x01c0dace
01c0dc3e  c8ff7502c101              mov r8,#0x1c10275
01c0dc46  8000                      rts
01c0dc4a  0f90                      add r7,r0,#0x10
01c0dc4c  005b                      jz r0,0x01c0dc84
01c0dc54  1044                      jz r0,0x01c0dc9e
01c0dc56  0056                      jz r0,0x01c0dc84
01c0dc5c  0751                      jz r7,0x01c0dc80
01c0dc5e  4021                      mov r0,#0x1
01c0dc60  0516                      mov r5,r0
01c0dc62  bfea36e8                  call 0x01c0acd2
01c0dc66  4023                      mov r0,#0x3
01c0dc68  4116                      mov r1,r4
01c0dc6a  80eafe10                  call 0x01c0fe6a
01c0dc70  006f                      lw r0,[r0 + 0x3c]
01c0dc74  0041                      jz r0,0x01c0dc78
01c0dc78  0300                      hbkpt
01c0dc7a  5881                      add r0,r5,#0x1
01c0dc7e  f051                      jnz r0,0x01c0dc62
01c0dc82  01a0                      lsl r1,r0,0x0
01c0dc86  806d                      sw r0,[r0 + 0x34]
01c0dc90  10a0                      lsl r0,r1,0x0
01c0dc92  0552                      jz r5,0x01c0dcb8
01c0dc94  4021                      mov r0,#0x1
01c0dc96  0716                      mov r7,r0
01c0dc98  bfea1be8                  call 0x01c0acd2
01c0dc9c  4022                      mov r0,#0x2
01c0dc9e  4116                      mov r1,r4
01c0dca0  80eae310                  call 0x01c0fe6a
01c0dca6  0060                      lw r0,[r0 + 0x0]
01c0dcaa  0040                      jz r0,0x01c0dcac
01c0dcae  806d                      sw r0,[r0 + 0x34]
01c0dcb0  0300                      hbkpt
01c0dcb2  7881                      add r0,r7,#0x1
01c0dcb6  ef71                      sh r7,[r6 + -0x1e]
01c0dcba  8000                      rts
01c0dcbe  1066                      lw r0,[r1 + 0x18]
01c0dcc4  0048                      jz r0,0x01c0dcd6
01c0dcc6  4021                      mov r0,#0x1
01c0dcca  ff00                      sti r15
01c0dccc  4020                      mov r0,#0x0
01c0dcd0  1064                      lw r0,[r1 + 0x10]
01c0dcd2  171c                      add r7,r1,r0
01c0dcd4  0488                      goto 0x01c0dce6
01c0dcd6  4720                      mov r7,#0x0
01c0dcd8  41e0ff0f                  movz r1,#0xfff
01c0dcdc  4021                      mov r0,#0x1
01c0dce0  0001                      tbb r0
01c0dce2  4020                      mov r0,#0x0
01c0dce4  0a18                      add r10,r0
01c0dcec  c0b1                      lsr r0,r4,0x11
01c0dcee  4520                      mov r5,#0x0
01c0dcf0  4de00500                  movz r13,#0x5
01c0dcf4  4616                      mov r6,r4
01c0dcf6  bfeaece7                  call 0x01c0acd2
01c0dcfa  4021                      mov r0,#0x1
01c0dcfc  6116                      mov r1,r6
01c0dcfe  80eab410                  call 0x01c0fe6a
01c0dd0a  501e                      sub r0,r5,r0
01c0dd0c  8045                      jnz r0,0x01c0dd18
01c0dd0e  8880                      add r0,sp,#0x0
01c0dd10  4230                      mov r2,#0x10
01c0dd12  9116                      mov r1,r9
01c0dd14  bfeadbfe                  call 0x01c0dace
01c0dd18  c521                      add r5,#0x1
01c0dd1c  806b                      sw r0,[r0 + 0x2c]
01c0dd22  b418                      add r4,r11
01c0dd2a  acb0                      qasr r4,r2,0x10
01c0dd2c  4520                      mov r5,#0x0
01c0dd2e  4ce00500                  movz r12,#0x5
01c0dd32  4616                      mov r6,r4
01c0dd34  bfeacde7                  call 0x01c0acd2
01c0dd38  4022                      mov r0,#0x2
01c0dd3a  6116                      mov r1,r6
01c0dd3c  80ea9510                  call 0x01c0fe6a
01c0dd48  501e                      sub r0,r5,r0
01c0dd4a  8045                      jnz r0,0x01c0dd56
01c0dd4c  8880                      add r0,sp,#0x0
01c0dd4e  4230                      mov r2,#0x10
01c0dd50  9116                      mov r1,r9
01c0dd52  bfeabcfe                  call 0x01c0dace
01c0dd56  c521                      add r5,#0x1
01c0dd5a  0060                      lw r0,[r0 + 0x0]
01c0dd5e  eaa1                      qasr r2,r6,0x1
01c0dd60  b418                      add r4,r11
01c0dd64  8000                      rts
01c0dd66  004b                      jz r0,0x01c0dd7e
01c0dd68  074a                      jz r7,0x01c0dd7e
01c0dd6a  bfeab2e7                  call 0x01c0acd2
01c0dd6e  4023                      mov r0,#0x3
01c0dd70  4116                      mov r1,r4
01c0dd72  80ea7a10                  call 0x01c0fe6a
01c0dd78  0041                      jz r0,0x01c0dd7c
01c0dd7e  0284                      add sp,#0x10
01c0dd80  5d04                      pop {pc,0xd}

;===== FUNC_01c0dd82  (called 2x) =====
01c0dd82  7804                      push {0x8}
01c0dd84  2416                      mov r4,r2
01c0dd86  1616                      mov r6,r1
01c0dd88  0516                      mov r5,r0
01c0dd8a  4116                      mov r1,r4
01c0dd8c  bfea4aff                  call 0x01c0dc24
01c0dd90  c0ff7502c101              mov r0,#0x1c10275
01c0dd9a  0940                      lb.z r1,[r0 + 0x0]
01c0dd9c  c019                      not r0,r4
01c0dd9e  c7a9                      lsr r7,r4,0x9
01c0dda0  c4ffd015c101              mov r4,#0x1c115d0
01c0dda6  015a                      jz r1,0x01c0dddc
01c0dda8  4121                      mov r1,#0x1
01c0ddae  005b                      jz r0,0x01c0dde6
01c0ddb2  7980                      add r1,r7,#0x0
01c0ddb6  8016                      mov r0,r8
01c0ddb8  42e00001                  movz r2,#0x100
01c0ddbc  4016                      mov r0,r4
01c0ddbe  80ea170f                  call 0x01c0fbf0
01c0ddc2  8217                      uxth r2,r0
01c0ddc4  124f                      jz r2,0x01c0de24
01c0ddc6  c0ffffff0000              mov r0,#0xffff
01c0ddd2  8015                      mov r0_r1,r8_r9
01c0ddd4  4016                      mov r0,r4
01c0ddd6  80ea1210                  call 0x01c0fdfe
01c0ddda  0485                      goto 0x01c0dde6
01c0dddc  4121                      mov r1,#0x1
01c0dde0  0000                      nop
01c0dde2  0116                      mov r1,r0
01c0dde4  1718                      add r7,r1
01c0dde6  70a9                      lsl r0,r7,0x9
01c0dde8  611c                      add r1,r6,r0
01c0ddec  001e                      sub r0,r0,r0
01c0ddee  5018                      add r0,r5
01c0ddf4  c8ffffff0000              mov r8,#0xffff
01c0ddfa  bfea6ae7                  call 0x01c0acd2
01c0ddfe  42e00002                  movz r2,#0x200
01c0de02  4016                      mov r0,r4
01c0de04  6116                      mov r1,r6
01c0de06  80eaf30e                  call 0x01c0fbf0
01c0de0a  8217                      uxth r2,r0
01c0de0c  024b                      jz r2,0x01c0de24
01c0de12  4015                      mov r0_r1,r4_r5
01c0de14  80eaf30f                  call 0x01c0fdfe
01c0de1a  006e                      lw r0,[r0 + 0x38]
01c0de1e  005e                      jz r0,0x01c0de5c
01c0de22  ebff58047f04              mov icfg,#0x47f0458
01c0de28  e28a                      add sp,#-0x58
01c0de2a  0716                      mov r7,r0
01c0de2c  4020                      mov r0,#0x0
01c0de2e  c414                      clr r12
01c0de30  80ea1c0f                  call 0x01c0fc6c
01c0de34  c0ffffff0000              mov r0,#0xffff
01c0de3a  c8ffd015c101              mov r8,#0x1c115d0
01c0de40  4b20                      mov r3,#0x20
01c0de46  7116                      mov r1,r7
01c0de48  8216                      mov r2,r8
01c0de4a  bfeacee6                  call 0x01c0abea
01c0de4e  8016                      mov r0,r8
01c0de50  bfeae7fb                  call 0x01c0d622
01c0de54  4433                      mov r4,#0x13
01c0de58  be00                      testset b[r14]
01c0de5a  bfea3ae7                  call 0x01c0acd2
01c0de60  2070                      lw r0,[r2 + -0x40]
01c0de62  cbffffff0000              mov r11,#0xffff
01c0de68  caff04d6c001              mov r10,#0x1c0d604
01c0de6e  c9ff0fd6c001              mov r9,#0x1c0d60f
01c0de74  c614                      clr r14
01c0de76  4b20                      mov r3,#0x20
01c0de7c  b016                      mov r0,r11
01c0de7e  6116                      mov r1,r6
01c0de80  8216                      mov r2,r8
01c0de82  bfeab2e6                  call 0x01c0abea
01c0de86  8016                      mov r0,r8
01c0de88  bfeacbfb                  call 0x01c0d622
01c0de8c  9044                      jnz r0,0x01c0ded6
01c0de90  1080                      rep 0x4,0x0
01c0de92  422b                      mov r2,#0xb
01c0de94  5016                      mov r0,r5
01c0de96  a116                      mov r1,r10
01c0de98  bfead8ec                  call 0x01c0b84c
01c0de9c  0048                      jz r0,0x01c0deae
01c0de9e  a898                      add r0,sp,#0x38
01c0dea0  4a20                      mov r2,#0x20
01c0dea2  8116                      mov r1,r8
01c0dea4  bfeabff9                  call 0x01c0d226
01c0deaa  01e0048d                  movl r1,#0x8d04
01c0deae  422f                      mov r2,#0xf
01c0deb0  5016                      mov r0,r5
01c0deb2  9116                      mov r1,r9
01c0deb4  bfeacaec                  call 0x01c0b84c
01c0deb8  0047                      jz r0,0x01c0dec8
01c0deba  8898                      add r0,sp,#0x18
01c0debc  4a20                      mov r2,#0x20
01c0debe  8116                      mov r1,r8
01c0dec0  bfeab1f9                  call 0x01c0d226
01c0dec6  02e060e1                  movl r2,#0xe160
01c0deca  03e0ce20                  movl r3,#0x20ce
01c0ded0  d207                      sb r2,[r5 ++= 1]
01c0ded2  4620                      mov r6,#0x0
01c0ded4  0481                      goto 0x01c0ded8
01c0ded6  4633                      mov r6,#0x13
01c0deda  1b02                      iflush [r11]
01c0dee6  8d98                      add r5,sp,#0x18
01c0dee8  4424                      mov r4,#0x4
01c0def2  7118                      add r1,r7
01c0def4  8217                      uxth r2,r0
01c0def6  8016                      mov r0,r8
01c0def8  80ea7a0e                  call 0x01c0fbf0
01c0defe  5162                      lw r1,[r5 + 0x8]
01c0df00  bfeaffe4                  call 0x01c0a902
01c0df0a  0001                      tbb r0
01c0df0c  4623                      mov r6,#0x3
01c0df0e  6416                      mov r4,r6
01c0df10  3482                      goto 0x01c0dfd6
01c0df16  891d                      add r1,r0,r7
01c0df18  c9ffffff0000              mov r9,#0xffff
01c0df1e  4330                      mov r3,#0x10
01c0df22  01b0                      lsl r1,r0,0x10
01c0df24  9016                      mov r0,r9
01c0df26  8216                      mov r2,r8
01c0df28  bfea5fe6                  call 0x01c0abea
01c0df2c  412e                      mov r1,#0xe
01c0df2e  8016                      mov r0,r8
01c0df30  bfeae7e4                  call 0x01c0a902
01c0df38  ad98                      add r5,sp,#0x38
01c0df3a  4421                      mov r4,#0x1
01c0df44  8888                      add r0,sp,#0x8
01c0df46  4230                      mov r2,#0x10
01c0df48  bfea6df9                  call 0x01c0d226
01c0df4e  0a40                      lb.z r2,[r0 + 0x0]
01c0df50  145c                      jz r4,0x01c0dfca
01c0df52  5061                      lw r0,[r5 + 0x4]
01c0df56  0e1c                      add r6,r0,r1
01c0df58  4520                      mov r5,#0x0
01c0df5a  7c16                      mov r12,r7
01c0df5c  e91d                      add r1,r6,r7
01c0df5e  4a16                      mov r10,r4
01c0df64  4ae00010                  movz r10,#0x1000
01c0df6a  40a0                      lsl r0,r4,0x0
01c0df6c  8016                      mov r0,r8
01c0df6e  f216                      mov r2,r15
01c0df70  80ea3e0e                  call 0x01c0fbf0
01c0df74  c0ff7e03c101              mov r0,#0x1c1037e
01c0df7c  0190                      call 0x01c0df9e
01c0df7e  8d16                      mov r13,r8
01c0df80  a716                      mov r7,r10
01c0df84  0802                      pfetch [r8]
01c0df88  8000                      rts
01c0df8e  ff3f                      add r7,#-0x1
01c0df92  d100                      goto r1
01c0df94  074e                      jz r7,0x01c0dfb2
01c0df96  bfea62ec                  call 0x01c0b85e

;===== FUNC_01c0df9e  (called 1x) =====
01c0df9e  1819                      xor r0,r1
01c0dfa2  d100                      goto r1
01c0dfa8  c0ff7e03c101              mov r0,#0x1c1037e
01c0dfb0  0090                      rep 0x2,0x10
01c0dfb4  40b0                      lsl r0,r4,0x10
01c0dfb6  f116                      mov r1,r15
01c0dfb8  bfea6cec                  call 0x01c0b894
01c0dfbc  0b16                      mov r11,r0
01c0dfbe  a618                      add r6,r10
01c0dfc2  424a                      jz r2,0x01c0ded8
01c0dfc4  4521                      mov r5,#0x1
01c0dfc6  c716                      mov r7,r12
01c0dfc8  e448                      jnz r4,0x01c0df5a
01c0dfce  4422                      mov r4,#0x2
01c0dfd4  83b1                      lsr r3,r0,0x11
01c0dfd6  4021                      mov r0,#0x1
01c0dfd8  80ea480e                  call 0x01c0fc6c
01c0dfdc  4017                      uxtb r0,r4
01c0dfde  0296                      add sp,#0x58
01c0dfe0  5f04                      pop {pc,0xf}

;===== FUNC_01c0dfe2  (called 1x) =====
01c0dfe2  7f04                      push {0xf}
01c0dfe4  e289                      add sp,#-0x5c
01c0dfe6  c6ff7002c101              mov r6,#0x1c10270
01c0dfee  6560                      lw r5,[r6 + 0x0]
01c0dff0  bfea54fb                  call 0x01c0d69c
01c0dff4  c7ffd012c101              mov r7,#0x1c112d0
01c0dffa  7860                      lh.z r0,[r7 + 0x0]
01c0dffc  c1ffcc12c101              mov r1,#0x1c112cc
01c0e002  1260                      lw r2,[r1 + 0x0]
01c0e004  c9ffd812c101              mov r9,#0x1c112d8
01c0e00a  1252                      jz r2,0x01c0e070
01c0e00c  00ac                      lsl r0,r0,0xc
01c0e010  2f50                      lb.z r7,[r2 + -0x10]
01c0e014  804b                      jnz r0,0x01c0e02c
01c0e018  805b                      jnz r0,0x01c0e050
01c0e01e  805d                      jnz r0,0x01c0e05a
01c0e022  8546                      jnz r5,0x01c0e030
01c0e024  4516                      mov r5,r4
01c0e026  4420                      mov r4,#0x0
01c0e028  0485                      goto 0x01c0e034
01c0e02a  45e00010                  movz r5,#0x1000
01c0e02e  0482                      goto 0x01c0e034
01c0e030  4420                      mov r4,#0x0
01c0e032  4520                      mov r5,#0x0
01c0e034  5016                      mov r0,r5
01c0e036  4116                      mov r1,r4
01c0e038  bfeaa3fe                  call 0x01c0dd82
01c0e03c  5016                      mov r0,r5
01c0e03e  bfeaf2fe                  call 0x01c0de26
01c0e042  4de00800                  movz r13,#0x8
01c0e048  0000                      nop
01c0e04c  7860                      lh.z r0,[r7 + 0x0]
01c0e04e  c1ff7502c101              mov r1,#0x1c10275
01c0e054  1940                      lb.z r1,[r1 + 0x0]
01c0e056  00ac                      lsl r0,r0,0xc
01c0e058  e060                      sw r0,[r6 + 0x0]
01c0e05a  0146                      jz r1,0x01c0e068
01c0e062  0202                      pfetch [r2]
01c0e064  4023                      mov r0,#0x3
01c0e066  0481                      goto 0x01c0e06a
01c0e068  4022                      mov r0,#0x2
01c0e06a  4116                      mov r1,r4
01c0e06c  80eafd0e                  call 0x01c0fe6a
01c0e070  c0fffc12c101              mov r0,#0x1c112fc
01c0e076  4120                      mov r1,#0x0
01c0e078  5230                      mov r2,#0x50
01c0e07a  bfea35f9                  call 0x01c0d2e8
01c0e07e  4020                      mov r0,#0x0
01c0e080  bfea7dea                  call 0x01c0b57e
01c0e084  c9ffd015c101              mov r9,#0x1c115d0
01c0e08a  42e00002                  movz r2,#0x200
01c0e08e  9116                      mov r1,r9
01c0e090  bfead6eb                  call 0x01c0b840
01c0e094  c4ffffff0000              mov r4,#0xffff
01c0e09a  4de00e00                  movz r13,#0xe
01c0e0a0  0004                      pop pc
01c0e0a4  40e00002                  movz r0,#0x200
01c0e0a8  bfea69ea                  call 0x01c0b57e
01c0e0ae  0092                      rep 0x2,0x12
01c0e0b0  4020                      mov r0,#0x0
01c0e0b2  42e00002                  movz r2,#0x200
01c0e0b6  bfeac3eb                  call 0x01c0b840
01c0e0bc  0004                      pop pc
01c0e0c0  5120                      mov r1,#0x40
01c0e0c6  5220                      mov r2,#0x40
01c0e0c8  4320                      mov r3,#0x0
01c0e0ca  9116                      mov r1,r9
01c0e0cc  bfeaf9eb                  call 0x01c0b8c2
01c0e0d2  0290                      add sp,#0x40
01c0e0d4  493e                      mov r1,#0x3e
01c0e0d6  bfea14e4                  call 0x01c0a902
01c0e0de  4de00100                  movz r13,#0x1
01c0e0e6  1901                      tbh r9
01c0e0ea  98a0                      qasr r0,r1,0x0
01c0e0ec  cbff4c13c101              mov r11,#0x1c1134c
01c0e0f4  00a0                      lsl r0,r0,0x0
01c0e0f6  0801                      tbb r8
01c0e0fa  0d80                      add r5,r0,#0x0
01c0e0fc  4021                      mov r0,#0x1
01c0e0fe  6530                      mov r5,#0x90
01c0e100  5630                      mov r6,#0x50
01c0e10e  5230                      mov r2,#0x50
01c0e110  4320                      mov r3,#0x0
01c0e112  4016                      mov r0,r4
01c0e114  bfead5eb                  call 0x01c0b8c2
01c0e11a  805d                      jnz r0,0x01c0e156
01c0e11e  d530                      add r5,#0x50
01c0e120  7881                      add r0,r7,#0x1
01c0e124  ee71                      sh r6,[r6 + -0x1e]
01c0e126  4120                      mov r1,#0x0
01c0e128  42e0e001                  movz r2,#0x1e0
01c0e12c  c014                      clr r8
01c0e12e  b016                      mov r0,r11
01c0e130  bfeadaf8                  call 0x01c0d2e8
01c0e136  4090                      rep 0xa,0x10
01c0e138  c9ff82d4c001              mov r9,#0x1c0d482
01c0e13e  c314                      clr r11
01c0e140  4520                      mov r5,#0x0
01c0e144  4ce006e1                  movz r12,#0xe106
01c0e148  4040                      jz r0,0x01c0e04a
01c0e14a  c414                      clr r12
01c0e154  4720                      mov r7,#0x0
01c0e156  cdff7c02c101              mov r13,#0x1c1027c
01c0e160  6016                      mov r0,r6
01c0e162  bfead7f8                  call 0x01c0d314
01c0e166  0046                      jz r0,0x01c0e174
01c0e168  c721                      add r7,#0x1
01c0e170  f503                      rep 0x20,r5
01c0e172  0486                      goto 0x01c0e180
01c0e182  0590                      goto 0x01c0e5a4
01c0e184  4225                      mov r2,#0x5
01c0e186  6016                      mov r0,r6
01c0e188  bfea31f8                  call 0x01c0d1ee
01c0e18c  805d                      jnz r0,0x01c0e1c8
01c0e18e  6016                      mov r0,r6
01c0e190  bfea10f9                  call 0x01c0d3b4
01c0e196  fc00                      sti r12
01c0e198  0017                      uxtb r0,r0
01c0e19a  4018                      add r0,r4
01c0e19c  d020                      add r0,#0x40
01c0e19e  4224                      mov r2,#0x4
01c0e1a0  9116                      mov r1,r9
01c0e1a2  bfea24f8                  call 0x01c0d1ee
01c0e1a6  8050                      jnz r0,0x01c0e1c8
01c0e1aa  2080                      rep 0x6,0x0
01c0e1b4  c1ff4c13c101              mov r1,#0x1c1134c
01c0e1ba  1018                      add r0,r1
01c0e1bc  5230                      mov r2,#0x50
01c0e1be  4116                      mov r1,r4
01c0e1c0  bfea31f8                  call 0x01c0d226
01c0e1c6  0180                      call 0x01c0e1c8
01c0e1ca  505c                      jz r0,0x01c0e144
01c0e1ce  01b0                      lsl r1,r0,0x10
01c0e1d2  40b0                      lsl r0,r4,0x10
01c0e1d4  d430                      add r4,#0x50
01c0e1de  8560                      sw r5,[r0 + 0x0]
01c0e1e0  c6ffd015c101              mov r6,#0x1c115d0
01c0e1e6  c1ffd012c101              mov r1,#0x1c112d0
01c0e1ec  c2ffd812c101              mov r2,#0x1c112d8
01c0e1f6  c0ffd912c101              mov r0,#0x1c112d9
01c0e1fc  0840                      lb.z r0,[r0 + 0x0]
01c0e200  2840                      lb.z r0,[r2 + 0x0]
01c0e208  1860                      lh.z r0,[r1 + 0x0]
01c0e214  2080                      rep 0x6,0x0
01c0e21a  49e02000                  movz r9,#0x20
01c0e21e  cbffffff0000              mov r11,#0xffff
01c0e224  ceffe8d5c001              mov r14,#0x1c0d5e8
01c0e22c  5080                      rep 0xc,0x0
01c0e22e  c1ff4c13c101              mov r1,#0x1c1134c
01c0e234  1018                      add r0,r1
01c0e238  0062                      lw r0,[r0 + 0x8]
01c0e23a  bfeaa0e9                  call 0x01c0b57e
01c0e23e  4020                      mov r0,#0x0
01c0e240  42e00002                  movz r2,#0x200
01c0e244  6116                      mov r1,r6
01c0e246  bfeafbea                  call 0x01c0b840
01c0e24a  4420                      mov r4,#0x0
01c0e24c  c714                      clr r15
01c0e24e  4720                      mov r7,#0x0
01c0e250  c414                      clr r12
01c0e252  4a20                      mov r2,#0x20
01c0e254  4320                      mov r3,#0x0
01c0e258  0190                      call 0x01c0e27a
01c0e25a  b016                      mov r0,r11
01c0e25c  6116                      mov r1,r6
01c0e25e  bfea30eb                  call 0x01c0b8c2
01c0e26a  2060                      lw r0,[r2 + 0x0]
01c0e26c  4a20                      mov r2,#0x20
01c0e26e  4320                      mov r3,#0x0
01c0e272  0190                      call 0x01c0e294
01c0e274  b016                      mov r0,r11
01c0e276  5116                      mov r1,r5
01c0e278  bfea23eb                  call 0x01c0b8c2
01c0e27c  4ce00100                  movz r12,#0x1
01c0e280  6f16                      mov r15,r6
01c0e282  6716                      mov r7,r6
01c0e284  5616                      mov r6,r5
01c0e286  6890                      add r0,r6,#0x10
01c0e288  422d                      mov r2,#0xd
01c0e28a  e116                      mov r1,r14
01c0e28c  bfeaaff7                  call 0x01c0d1ee
01c0e290  6a16                      mov r10,r6

;===== FUNC_01c0e294  (called 1x) =====
01c0e294  0000                      nop
01c0e296  4a16                      mov r10,r4
01c0e2a0  ce20                      add r6,#0x20
01c0e2a2  a416                      mov r4,r10
01c0e2a6  d521                      add r5,#0x41
01c0e2a8  7016                      mov r0,r7
01c0e2aa  bfeabaf9                  call 0x01c0d622
01c0e2ae  9055                      jnz r0,0x01c0e31a
01c0e2b0  a016                      mov r0,r10
01c0e2b2  bfeab6f9                  call 0x01c0d622
01c0e2b6  9051                      jnz r0,0x01c0e31a
01c0e2ba  fc00                      sti r12
01c0e2c4  fd00                      sti r13
01c0e2d8  4861                      lh.z r0,[r4 + 0x2]
01c0e2da  01a4                      lsl r1,r0,0x4
01c0e2dc  c130                      add r1,#0x10
01c0e2e0  7f1e                      sub r7,r7,r1
01c0e2e2  80a8                      lsr r0,r0,0x8
01c0e2e4  c021                      add r0,#0x1
01c0e2e6  0017                      uxtb r0,r0
01c0e2f0  4062                      lw r0,[r4 + 0x8]
01c0e2f8  0180                      call 0x01c0e2fa
01c0e2fc  c6ffd015c101              mov r6,#0x1c115d0
01c0e306  0489                      goto 0x01c0e31a
01c0e308  4120                      mov r1,#0x0
01c0e30a  42e0e001                  movz r2,#0x1e0
01c0e30e  c514                      clr r13
01c0e310  b016                      mov r0,r11
01c0e312  bfeae9f7                  call 0x01c0d2e8
01c0e31e  0297                      add sp,#0x5c
01c0e320  5f04                      pop {pc,0xf}
01c0e322  5230                      mov r2,#0x50
01c0e324  c5fffc12c101              mov r5,#0x1c112fc
01c0e32e  bfea7af7                  call 0x01c0d226
01c0e336  0060                      lw r0,[r0 + 0x0]
01c0e338  c4ff7002c101              mov r4,#0x1c10270
01c0e340  ecff4df00b00              mov usp,#0xbf04d
01c0e346  5062                      lw r0,[r5 + 0x8]
01c0e348  7048                      jz r0,0x01c0e31a
01c0e34a  5163                      lw r1,[r5 + 0xc]
01c0e34c  7146                      jz r1,0x01c0e31a
01c0e34e  bfea16e9                  call 0x01c0b57e
01c0e352  c514                      clr r13
01c0e354  a99c                      add r1,sp,#0x3c
01c0e356  4020                      mov r0,#0x0
01c0e358  4a20                      mov r2,#0x20
01c0e35a  4d20                      mov r5,#0x20
01c0e35c  bfea70ea                  call 0x01c0b840
01c0e362  4160                      lw r1,[r4 + 0x0]
01c0e364  8c9c                      add r4,sp,#0x1c
01c0e366  4b20                      mov r3,#0x20
01c0e36c  4216                      mov r2,r4
01c0e36e  bfea3ce4                  call 0x01c0abea
01c0e372  4016                      mov r0,r4
01c0e374  bfea55f9                  call 0x01c0d622
01c0e378  e050                      jnz r0,0x01c0e31a
01c0e37e  899c                      add r1,sp,#0x1c
01c0e380  4a20                      mov r2,#0x20
01c0e382  4320                      mov r3,#0x0
01c0e384  4420                      mov r4,#0x0
01c0e386  bfea9cea                  call 0x01c0b8c2
01c0e38a  a89c                      add r0,sp,#0x3c
01c0e38c  0984                      add r1,r0,#0x4
01c0e38e  4024                      mov r0,#0x4
01c0e398  c421                      add r4,#0x1
01c0e39a  f83f                      add r0,#-0x1
01c0e3a2  ff00                      sti r15
01c0e3a6  889c                      add r0,sp,#0x1c
01c0e3a8  c024                      add r0,#0x4
01c0e3aa  4224                      mov r2,#0x4
01c0e3ac  bfea1ff7                  call 0x01c0d1ee
01c0e3b0  4de01900                  movz r13,#0x19
01c0e3b4  d052                      jnz r0,0x01c0e31a
01c0e3b6  a89c                      add r0,sp,#0x3c
01c0e3b8  0990                      add r1,r0,#0x10
01c0e3ba  4220                      mov r2,#0x0
01c0e3bc  4030                      mov r0,#0x10
01c0e3c6  c221                      add r2,#0x1
01c0e3c8  f83f                      add r0,#-0x1
01c0e3cc  f821                      add r0,#-0x1f
01c0e3d0  ff00                      sti r15
01c0e3d4  889c                      add r0,sp,#0x1c
01c0e3d6  c030                      add r0,#0x10
01c0e3d8  4230                      mov r2,#0x10
01c0e3da  bfea08f7                  call 0x01c0d1ee
01c0e3de  0d16                      mov r13,r0
01c0e3e2  0000                      nop
01c0e3e4  4de01900                  movz r13,#0x19
01c0e3e8  c798                      goto 0x01c0e31a
01c0e3ea  c514                      clr r13
01c0e3ec  c796                      goto 0x01c0e31a

;===== FUNC_01c0e3ee  (called 2x) =====
01c0e3ee  c2ffd012c101              mov r2,#0x1c112d0
01c0e3f4  2a60                      lh.z r2,[r2 + 0x0]
01c0e3f8  1002                      iflush [r0]
01c0e3fa  024f                      jz r2,0x01c0e41a
01c0e3fc  c2ffd412c101              mov r2,#0x1c112d4
01c0e404  2260                      lw r2,[r2 + 0x0]
01c0e40a  a017                      uxth r0,r2
01c0e40e  0080                      rep 0x2,0x0
01c0e410  c0ff7402c101              mov r0,#0x1c10274
01c0e416  4121                      mov r1,#0x1
01c0e418  8940                      sb r1,[r0 + 0x0]
01c0e41a  8000                      rts

;===== FUNC_01c0e41c  (called 1x) =====
01c0e41c  7f04                      push {0xf}
01c0e41e  e28f                      add sp,#-0x44
01c0e420  c0fffc12c101              mov r0,#0x1c112fc
01c0e426  0062                      lw r0,[r0 + 0x8]
01c0e428  bfeaa9e8                  call 0x01c0b57e
01c0e42c  c4ffd015c101              mov r4,#0x1c115d0
01c0e432  4020                      mov r0,#0x0
01c0e434  42e00002                  movz r2,#0x200
01c0e438  c714                      clr r15
01c0e43a  4116                      mov r1,r4
01c0e43c  bfea00ea                  call 0x01c0b840
01c0e440  4ee02000                  movz r14,#0x20
01c0e444  c5ffffff0000              mov r5,#0xffff
01c0e44a  4a20                      mov r2,#0x20
01c0e44c  4320                      mov r3,#0x0
01c0e450  01e05016                  movl r1,#0x1650
01c0e454  4116                      mov r1,r4
01c0e456  bfea34ea                  call 0x01c0b8c2
01c0e45a  c0ff2c15c101              mov r0,#0x1c1152c
01c0e460  4a20                      mov r2,#0x20
01c0e462  4116                      mov r1,r4
01c0e464  bfeadff6                  call 0x01c0d226
01c0e46a  2040                      jz r0,0x01c0e4ec
01c0e46c  4be00400                  movz r11,#0x4
01c0e470  c4ffe8d5c001              mov r4,#0x1c0d5e8
01c0e476  cdff4c15c101              mov r13,#0x1c1154c
01c0e47c  c9ff0fd6c001              mov r9,#0x1c0d60f
01c0e482  ccff6c15c101              mov r12,#0x1c1156c
01c0e488  c214                      clr r10
01c0e48a  c014                      clr r8
01c0e48c  4a20                      mov r2,#0x20
01c0e48e  4320                      mov r3,#0x0
01c0e492  01e05016                  movl r1,#0x1650
01c0e496  7116                      mov r1,r7
01c0e498  bfea13ea                  call 0x01c0b8c2
01c0e49c  7e90                      add r6,r7,#0x10
01c0e49e  422d                      mov r2,#0xd
01c0e4a0  6016                      mov r0,r6
01c0e4a2  4116                      mov r1,r4
01c0e4a4  bfead2e9                  call 0x01c0b84c
01c0e4a8  0047                      jz r0,0x01c0e4b8
01c0e4aa  4a20                      mov r2,#0x20
01c0e4ac  d016                      mov r0,r13
01c0e4ae  7116                      mov r1,r7
01c0e4b0  bfeab9f6                  call 0x01c0d226
01c0e4b4  7a16                      mov r10,r7
01c0e4b6  049d                      goto 0x01c0e4f2
01c0e4b8  422f                      mov r2,#0xf
01c0e4ba  6016                      mov r0,r6
01c0e4bc  9116                      mov r1,r9
01c0e4be  bfeac5e9                  call 0x01c0b84c
01c0e4c2  0047                      jz r0,0x01c0e4d2
01c0e4c4  4a20                      mov r2,#0x20
01c0e4c6  c016                      mov r0,r12
01c0e4c8  7116                      mov r1,r7
01c0e4ca  bfeaacf6                  call 0x01c0d226
01c0e4ce  7816                      mov r8,r7
01c0e4d0  0490                      goto 0x01c0e4f2
01c0e4d2  422b                      mov r2,#0xb
01c0e4d4  6016                      mov r0,r6
01c0e4d6  c1ff04d6c001              mov r1,#0x1c0d604
01c0e4dc  bfeab6e9                  call 0x01c0b84c
01c0e4e0  0048                      jz r0,0x01c0e4f2
01c0e4e2  4a20                      mov r2,#0x20
01c0e4e4  c0ff8c15c101              mov r0,#0x1c1158c
01c0e4ea  7116                      mov r1,r7
01c0e4ec  bfea9bf6                  call 0x01c0d226
01c0e4f0  7f16                      mov r15,r7
01c0e4f4  ffbf                      qasr r7,r7,0x1f
01c0e4f8  40b0                      lsl r0,r4,0x10
01c0e4fa  cf20                      add r7,#0x20
01c0e4fc  e047                      jnz r0,0x01c0e48c
01c0e4fe  4ce00b00                  movz r12,#0xb
01c0e504  8000                      rts
01c0e510  d400                      goto r4
01c0e512  c1fffc12c101              mov r1,#0x1c112fc
01c0e518  1162                      lw r1,[r1 + 0x8]
01c0e51a  1018                      add r0,r1
01c0e51c  bfea2fe8                  call 0x01c0b57e
01c0e520  4020                      mov r0,#0x0
01c0e522  42e00002                  movz r2,#0x200
01c0e526  c114                      clr r9
01c0e528  ceffd015c101              mov r14,#0x1c115d0
01c0e52e  e116                      mov r1,r14
01c0e530  bfea86e9                  call 0x01c0b840
01c0e534  8c84                      add r4,sp,#0x4
01c0e536  4a20                      mov r2,#0x20
01c0e538  48e02000                  movz r8,#0x20
01c0e53c  4016                      mov r0,r4
01c0e53e  e116                      mov r1,r14
01c0e540  bfea71f6                  call 0x01c0d226
01c0e544  c5ffc003c101              mov r5,#0x1c103c0
01c0e54c  5862                      lh.z r0,[r5 + 0x4]
01c0e54e  4a20                      mov r2,#0x20
01c0e550  4320                      mov r3,#0x0
01c0e554  0180                      call 0x01c0e556

;===== FUNC_01c0e556  (called 1x) =====
01c0e556  bfeab4e9                  call 0x01c0b8c2
01c0e55c  0240                      jz r2,0x01c0e55e
01c0e55e  413e                      mov r1,#0x1e
01c0e560  bfeacfe1                  call 0x01c0a902
01c0e56a  5c62                      lh.z r4,[r5 + 0x4]
01c0e56c  c2ff7402c101              mov r2,#0x1c10274
01c0e574  2090                      rep 0x6,0x10
01c0e578  0000                      nop
01c0e57a  4ce00c00                  movz r12,#0xc
01c0e586  caff1ed6c001              mov r10,#0x1c0d61e
01c0e58c  cbff73d4c001              mov r11,#0x1c0d473
01c0e592  4720                      mov r7,#0x0
01c0e596  701e                      sub r0,r7,r0
01c0e598  ad84                      add r5,sp,#0x24
01c0e59a  4a20                      mov r2,#0x20
01c0e59c  5016                      mov r0,r5
01c0e59e  bfea42f6                  call 0x01c0d226
01c0e5a2  4a20                      mov r2,#0x20
01c0e5a6  0180                      call 0x01c0e5a8

;===== FUNC_01c0e5a8  (called 1x) =====
01c0e5a8  4015                      mov r0_r1,r4_r5
01c0e5aa  7316                      mov r3,r7
01c0e5ac  bfea89e9                  call 0x01c0b8c2
01c0e5b0  4223                      mov r2,#0x3
01c0e5b2  6016                      mov r0,r6
01c0e5b4  a116                      mov r1,r10
01c0e5b6  bfea1af6                  call 0x01c0d1ee
01c0e5bc  0000                      nop
01c0e5c0  d490                      goto 0x01c0e922
01c0e5c2  4225                      mov r2,#0x5
01c0e5c4  6016                      mov r0,r6
01c0e5c6  b116                      mov r1,r11
01c0e5c8  bfea11f6                  call 0x01c0d1ee
01c0e5cc  0045                      jz r0,0x01c0e5d8
01c0e5ce  cf20                      add r7,#0x20
01c0e5d2  e0ff8214048d              mov reti,#0x8d041482
01c0e5dc  4321                      mov r3,#0x1
01c0e5de  4220                      mov r2,#0x0
01c0e5e2  0300                      hbkpt
01c0e5e8  d400                      goto r4
01c0e5ea  bfea00ff                  call 0x01c0e3ee
01c0e5f0  d420                      add r4,#0x40
01c0e5f2  80eadf0b                  call 0x01c0fdb4
01c0e5f6  0347                      jz r3,0x01c0e606
01c0e5f8  0046                      jz r0,0x01c0e606
01c0e5fa  9016                      mov r0,r9
01c0e5fc  80eabc0c                  call 0x01c0ff78
01c0e600  2016                      mov r0,r2
01c0e602  80eabe0c                  call 0x01c0ff82
01c0e60a  0291                      add sp,#0x44
01c0e60c  5f04                      pop {pc,0xf}

;===== FUNC_01c0e60e  (called 1x) =====
01c0e60e  7804                      push {0x8}
01c0e610  0416                      mov r4,r0
01c0e616  4620                      mov r6,#0x0
01c0e618  48e00100                  movz r8,#0x1
01c0e61c  c7ff7c02c101              mov r7,#0x1c1027c
01c0e624  8016                      mov r0,r8
01c0e62a  7a84                      add r2,r7,#0x4
01c0e62c  4020                      mov r0,#0x0
01c0e636  c021                      add r0,#0x1
01c0e63a  f905                      sw r1,[r7 --= 4]
01c0e63c  4020                      mov r0,#0x0
01c0e63e  0017                      uxtb r0,r0
01c0e644  8d1d                      add r5,r0,r7
01c0e646  5164                      lw r1,[r5 + 0x10]
01c0e648  0144                      jz r1,0x01c0e652
01c0e64a  5016                      mov r0,r5
01c0e64c  c100                      call r1
01c0e64e  0116                      mov r1,r0
01c0e650  8147                      jnz r1,0x01c0e660
01c0e652  c621                      add r6,#0x1
01c0e656  e541                      jnz r5,0x01c0e5da
01c0e658  4020                      mov r0,#0x0
01c0e65a  5804                      pop {pc,0x8}
01c0e65c  4035                      mov r0,#0x15
01c0e65e  5804                      pop {pc,0x8}
01c0e660  402c                      mov r0,#0xc
01c0e66a  5804                      pop {pc,0x8}

;===== FUNC_01c0e66c  (called 1x) =====
01c0e66c  7904                      push {0x9}
01c0e66e  c2ff7002c101              mov r2,#0x1c10270
01c0e676  2660                      lw r6,[r2 + 0x0]
01c0e678  0516                      mov r5,r0
01c0e67e  c9ffb002c101              mov r9,#0x1c102b0
01c0e684  0648                      jz r6,0x01c0e696
01c0e688  806b                      sw r0,[r0 + 0x2c]
01c0e68e  806d                      sw r0,[r0 + 0x34]
01c0e690  0200                      bkpt
01c0e692  0483                      goto 0x01c0e69a
01c0e694  4020                      mov r0,#0x0
01c0e69a  c0ffd012c101              mov r0,#0x1c112d0
01c0e6a0  0860                      lh.z r0,[r0 + 0x0]
01c0e6a2  5260                      lw r2,[r5 + 0x0]
01c0e6a4  c7fffc12c101              mov r7,#0x1c112fc
01c0e6aa  04ac                      lsl r4,r0,0xc
01c0e6ae  7162                      lw r1,[r7 + 0x8]
01c0e6b2  7363                      lw r3,[r7 + 0xc]
01c0e6b4  b21e                      sub r2,r3,r2
01c0e6b6  bfea36e9                  call 0x01c0b926
01c0e6ba  80ea7b0b                  call 0x01c0fdb4
01c0e6be  0047                      jz r0,0x01c0e6ce
01c0e6c2  0000                      nop
01c0e6c4  4420                      mov r4,#0x0
01c0e6c6  c01d                      add r0,r4,r6
01c0e6cc  0482                      goto 0x01c0e6d2
01c0e6d2  5260                      lw r2,[r5 + 0x0]
01c0e6d4  7162                      lw r1,[r7 + 0x8]
01c0e6d6  c3ffb402c101              mov r3,#0x1c102b4
01c0e6dc  b260                      sw r2,[r3 + 0x0]
01c0e6de  bfea22e9                  call 0x01c0b926
01c0e6e2  c0ffcc12c101              mov r0,#0x1c112cc
01c0e6e8  0060                      lw r0,[r0 + 0x0]
01c0e6ea  c1ff7502c101              mov r1,#0x1c10275
01c0e6f2  1a40                      lb.z r2,[r1 + 0x0]
01c0e6f4  0248                      jz r2,0x01c0e706
01c0e6f6  c0ffd812c101              mov r0,#0x1c112d8
01c0e6fc  0840                      lb.z r0,[r0 + 0x0]
01c0e700  0202                      pfetch [r2]
01c0e702  4023                      mov r0,#0x3
01c0e704  0481                      goto 0x01c0e708
01c0e706  4022                      mov r0,#0x2
01c0e708  80eaaf0b                  call 0x01c0fe6a
01c0e70c  7063                      lw r0,[r7 + 0xc]
01c0e710  8100                      rti
01c0e712  5904                      pop {pc,0x9}

;===== FUNC_01c0e714  (called 1x) =====
01c0e714  7f04                      push {0xf}
01c0e716  c29e                      add sp,#-0x88
01c0e718  c7ff7002c101              mov r7,#0x1c10270
01c0e720  7080                      rep 0x10,0x0
01c0e722  4620                      mov r6,#0x0
01c0e726  8660                      sw r6,[r0 + 0x0]
01c0e728  caffc003c101              mov r10,#0x1c103c0
01c0e730  90a0                      lsr r0,r1,0x0
01c0e732  4120                      mov r1,#0x0
01c0e734  423c                      mov r2,#0x1c
01c0e736  5016                      mov r0,r5
01c0e738  bfead6f5                  call 0x01c0d2e8
01c0e73e  0002                      pfetch [r0]
01c0e740  d560                      sw r5,[r5 + 0x0]
01c0e742  d561                      sw r5,[r5 + 0x4]
01c0e744  5888                      add r0,r5,#0x8
01c0e746  d062                      sw r0,[r5 + 0x8]
01c0e748  d063                      sw r0,[r5 + 0xc]
01c0e74a  5890                      add r0,r5,#0x10
01c0e74c  d064                      sw r0,[r5 + 0x10]
01c0e750  6c50                      lb.z r4,[r6 + -0x10]
01c0e752  d065                      sw r0,[r5 + 0x14]
01c0e754  bfea39e2                  call 0x01c0abca
01c0e758  d066                      sw r0,[r5 + 0x18]
01c0e75c  7560                      lw r5,[r7 + 0x0]
01c0e75e  c0ffd012c101              mov r0,#0x1c112d0
01c0e764  0960                      lh.z r1,[r0 + 0x0]
01c0e766  0860                      lh.z r0,[r0 + 0x0]
01c0e768  c4ff4c15c101              mov r4,#0x1c1154c
01c0e772  2802                      flush [r8]
01c0e776  2050                      jz r0,0x01c0e818
01c0e77a  c0ffffff0000              mov r0,#0xffff
01c0e780  c9ffd015c101              mov r9,#0x1c115d0
01c0e786  4b20                      mov r3,#0x20
01c0e788  9216                      mov r2,r9
01c0e78a  bfea2ee2                  call 0x01c0abea
01c0e78e  c1ff8c15c101              mov r1,#0x1c1158c
01c0e794  4a20                      mov r2,#0x20
01c0e796  9016                      mov r0,r9
01c0e798  bfea29f5                  call 0x01c0d1ee
01c0e79e  0000                      nop
01c0e7a0  1102                      iflush [r1]
01c0e7a4  4050                      jz r0,0x01c0e6c6
01c0e7a8  c0ffffff0000              mov r0,#0xffff
01c0e7ae  4b20                      mov r3,#0x20
01c0e7b0  9216                      mov r2,r9
01c0e7b2  bfea1ae2                  call 0x01c0abea
01c0e7b6  c1ff6c15c101              mov r1,#0x1c1156c
01c0e7bc  4a20                      mov r2,#0x20
01c0e7be  9016                      mov r0,r9
01c0e7c0  bfea15f5                  call 0x01c0d1ee
01c0e7c6  0000                      nop
01c0e7cc  6050                      jz r0,0x01c0e76e
01c0e7d0  c0ffffff0000              mov r0,#0xffff
01c0e7d6  4b20                      mov r3,#0x20
01c0e7d8  9216                      mov r2,r9
01c0e7da  bfea06e2                  call 0x01c0abea
01c0e7e2  4161                      lw r1,[r4 + 0x4]
01c0e7e6  0001                      tbb r0
01c0e7ec  0980                      add r1,r0,#0x0
01c0e7f2  c1ffcc12c101              mov r1,#0x1c112cc
01c0e7fa  1160                      lw r1,[r1 + 0x0]
01c0e7fc  ccfffc12c101              mov r12,#0x1c112fc
01c0e804  c820                      add r0,#0x20
01c0e80a  7360                      lw r3,[r7 + 0x0]
01c0e816  2000                      csync
01c0e81e  c7ffd025c101              mov r7,#0x1c125d0
01c0e824  4120                      mov r1,#0x0
01c0e82e  e416                      mov r4,r14
01c0e830  1516                      mov r5,r1
01c0e832  bfea4ee2                  call 0x01c0acd2
01c0e83e  4b20                      mov r3,#0x20
01c0e844  bfead1e1                  call 0x01c0abea
01c0e848  9016                      mov r0,r9
01c0e84a  bfeaeaf6                  call 0x01c0d622
01c0e850  0000                      nop
01c0e856  1f40                      lb.z r7,[r1 + 0x0]
01c0e85c  1f40                      lb.z r7,[r1 + 0x0]
01c0e860  406f                      lw r0,[r4 + 0x3c]
01c0e862  0717                      uxtb r7,r0
01c0e864  e81f                      sub r0,r6,r7
01c0e866  bfea8ae6                  call 0x01c0b57e
01c0e86a  cd88                      add r5,sp,#0x48
01c0e86c  4020                      mov r0,#0x0
01c0e86e  4a20                      mov r2,#0x20
01c0e870  5116                      mov r1,r5
01c0e872  bfeae5e7                  call 0x01c0b840
01c0e878  40e0b4e0                  movz r0,#0xe0b4
01c0e87c  e237                      add r2,#-0x69
01c0e87e  4a20                      mov r2,#0x20
01c0e882  0180                      call 0x01c0e884

;===== FUNC_01c0e884  (called 1x) =====
01c0e884  d016                      mov r0,r13
01c0e886  5116                      mov r1,r5
01c0e888  bfea1be8                  call 0x01c0b8c2
01c0e88c  d91d                      add r1,r5,r7
01c0e890  2070                      lw r0,[r2 + -0x40]
01c0e892  c7ffd025c101              mov r7,#0x1c125d0
01c0e898  7016                      mov r0,r7
01c0e89a  5216                      mov r2,r5
01c0e89c  bfeac3f4                  call 0x01c0d226
01c0e8a0  0485                      goto 0x01c0e8ac
01c0e8a4  406f                      lw r0,[r4 + 0x3c]
01c0e8a6  4520                      mov r5,#0x0
01c0e8aa  40e05517                  movz r0,#0x1755
01c0e8ae  d01d                      add r0,r5,r6
01c0e8b0  bfea65e6                  call 0x01c0b57e
01c0e8b4  de1d                      add r6,r5,r7
01c0e8b6  4020                      mov r0,#0x0
01c0e8b8  4a20                      mov r2,#0x20
01c0e8ba  6116                      mov r1,r6
01c0e8bc  bfeac0e7                  call 0x01c0b840
01c0e8c2  503e                      mov r0,#0x5e
01c0e8c4  4a20                      mov r2,#0x20
01c0e8c8  0180                      call 0x01c0e8ca

;===== FUNC_01c0e8ca  (called 1x) =====
01c0e8ca  d016                      mov r0,r13
01c0e8cc  6116                      mov r1,r6
01c0e8ce  bfeaf8e7                  call 0x01c0b8c2
01c0e8d2  7016                      mov r0,r7
01c0e8d4  bfeaa5f6                  call 0x01c0d622
01c0e8da  0000                      nop
01c0e8e0  7562                      lw r5,[r7 + 0x8]
01c0e8e2  4a20                      mov r2,#0x20
01c0e8e4  7116                      mov r1,r7
01c0e8e6  bfea82f4                  call 0x01c0d1ee
01c0e8f2  0000                      nop
01c0e8f6  c0ffd812c101              mov r0,#0x1c112d8
01c0e8fc  0840                      lb.z r0,[r0 + 0x0]
01c0e8fe  0116                      mov r1,r0
01c0e902  0100                      idle
01c0e904  4120                      mov r1,#0x0
01c0e906  11a8                      lsl r1,r1,0x8
01c0e908  42e00010                  movz r2,#0x1000
01c0e90c  c7ff7002c101              mov r7,#0x1c10270
01c0e916  1216                      mov r2,r1
01c0e918  7160                      lw r1,[r7 + 0x0]
01c0e91a  c0ffcc12c101              mov r0,#0x1c112cc
01c0e924  0560                      lw r5,[r0 + 0x0]
01c0e92e  801f                      sub r0,r0,r6
01c0e932  f830                      add r0,#-0x10
01c0e936  9c60                      sh r4,[r1 + 0x0]
01c0e93a  c830                      add r0,#0x30
01c0e93e  f060                      sw r0,[r7 + 0x0]
01c0e942  f806                      sh r0,[r7 --= 2]
01c0e946  ff2f                      add r7,#-0x11
01c0e94a  1260                      lw r2,[r1 + 0x0]
01c0e94e  501e                      sub r0,r5,r0
01c0e950  3118                      add r1,r3
01c0e954  3c80                      add r4,r3,#0x0
01c0e958  1218                      add r2,r1
01c0e95a  911f                      sub r1,r1,r6
01c0e95c  801f                      sub r0,r0,r6
01c0e960  bfeafce7                  call 0x01c0b95c
01c0e964  7060                      lw r0,[r7 + 0x0]
01c0e966  c1ffcc12c101              mov r1,#0x1c112cc
01c0e96c  1160                      lw r1,[r1 + 0x0]
01c0e970  c820                      add r0,#0x20
01c0e972  c7ffd025c101              mov r7,#0x1c125d0
01c0e97a  7362                      lw r3,[r7 + 0x8]
01c0e97c  2e1c                      add r6,r2,r1
01c0e97e  6e1f                      sub r6,r6,r5
01c0e982  e263                      sw r2,[r6 + 0xc]
01c0e988  1de06518                  movh r13,#0x1865
01c0e992  cc20                      add r4,#0x20
01c0e994  4d1c                      add r5,r4,r1
01c0e99a  c01c                      add r0,r4,r2
01c0e9a2  1f60                      lh.z r7,[r1 + 0x0]
01c0e9a4  e888                      add r0,sp,#0x68
01c0e9a6  1018                      add r0,r1
01c0e9b4  2080                      rep 0x6,0x0
01c0e9b8  9416                      mov r4,r9
01c0e9bc  a490                      goto 0x01c0ec5e
01c0e9be  101e                      sub r0,r1,r0
01c0e9c0  f820                      add r0,#-0x20
01c0e9c8  2000                      csync
01c0e9cc  c08a                      rep 0x1a,0xa
01c0e9ce  bfea80e1                  call 0x01c0acd2
01c0e9d4  c01e                      sub r0,r4,r2
01c0e9d6  4d16                      mov r13,r4
01c0e9da  2040                      jz r0,0x01c0ea5c
01c0e9dc  4b20                      mov r3,#0x20
01c0e9e0  0180                      call 0x01c0e9e2

;===== FUNC_01c0e9e2  (called 1x) =====
01c0e9e2  9016                      mov r0,r9
01c0e9e4  b216                      mov r2,r11
01c0e9e6  bfea00e1                  call 0x01c0abea
01c0e9ea  b016                      mov r0,r11
01c0e9ec  bfea19f6                  call 0x01c0d622
01c0e9f2  bf00                      testset b[r15]
01c0e9f6  005e                      jz r0,0x01c0ea34
01c0e9fe  bfeabee5                  call 0x01c0b57e
01c0ea02  ec88                      add r4,sp,#0x68
01c0ea04  4020                      mov r0,#0x0
01c0ea06  4a20                      mov r2,#0x20
01c0ea08  4116                      mov r1,r4
01c0ea0a  bfea19e7                  call 0x01c0b840
01c0ea10  503a                      mov r0,#0x5a
01c0ea12  4a20                      mov r2,#0x20
01c0ea14  4be02000                  movz r11,#0x20
01c0ea1a  01b0                      lsl r1,r0,0x10
01c0ea1c  9016                      mov r0,r9
01c0ea1e  4116                      mov r1,r4
01c0ea20  bfea4fe7                  call 0x01c0b8c2
01c0ea26  2070                      lw r0,[r2 + -0x40]
01c0ea2c  4216                      mov r2,r4
01c0ea2e  bfeafaf3                  call 0x01c0d226
01c0ea32  0483                      goto 0x01c0ea3a
01c0ea34  4420                      mov r4,#0x0
01c0ea36  4be02000                  movz r11,#0x20
01c0ea3a  7616                      mov r6,r7
01c0ea3e  c01f                      sub r0,r4,r6
01c0ea40  4717                      uxtb r7,r4
01c0ea42  981d                      add r0,r1,r7
01c0ea44  bfea9be5                  call 0x01c0b57e
01c0ea4a  2060                      lw r0,[r2 + 0x0]
01c0ea4c  751d                      add r5,r7,r4
01c0ea4e  4020                      mov r0,#0x0
01c0ea50  4a20                      mov r2,#0x20
01c0ea52  5116                      mov r1,r5
01c0ea54  bfeaf4e6                  call 0x01c0b840
01c0ea5c  4a20                      mov r2,#0x20
01c0ea60  01b0                      lsl r1,r0,0x10
01c0ea62  9016                      mov r0,r9
01c0ea64  5116                      mov r1,r5
01c0ea66  bfea2ce7                  call 0x01c0b8c2
01c0ea6a  4016                      mov r0,r4
01c0ea6c  bfead9f5                  call 0x01c0d622
01c0ea70  48e02000                  movz r8,#0x20
01c0ea80  6716                      mov r7,r6
01c0ea8a  c1ffb802c101              mov r1,#0x1c102b8
01c0ea90  4221                      mov r2,#0x1
01c0ea92  9a40                      sb r2,[r1 + 0x0]
01c0ea9a  3070                      lw r0,[r3 + -0x40]
01c0ea9c  4223                      mov r2,#0x3
01c0ea9e  c0ff70d4c001              mov r0,#0x1c0d470
01c0eaa4  bfeaa3f3                  call 0x01c0d1ee
01c0eaa8  1042                      jz r0,0x01c0eaee
01c0eaae  c1ffd812c101              mov r1,#0x1c112d8
01c0eab8  1940                      lb.z r1,[r1 + 0x0]
01c0eaba  1216                      mov r2,r1
01c0eabe  0100                      idle
01c0eac0  4220                      mov r2,#0x0
01c0eac2  23a8                      lsl r3,r2,0x8
01c0eac4  42e00010                  movz r2,#0x1000
01c0eacc  3216                      mov r2,r3
01c0ead0  ff2f                      add r7,#-0x11
01c0ead2  736a                      lw r3,[r7 + 0x28]
01c0ead6  1240                      jz r2,0x01c0eb18
01c0eada  001f                      sub r0,r0,r4
01c0eadc  0118                      add r1,r0
01c0eade  2318                      add r3,r2
01c0eae0  4318                      add r3,r4
01c0eae2  fb3f                      add r3,#-0x1
01c0eae8  b219                      not r2,r3
01c0eaea  bfea37e7                  call 0x01c0b95c
01c0eaee  d416                      mov r4,r13
01c0eafa  20a0                      lsl r0,r2,0x0
01c0eb04  4be00100                  movz r11,#0x1
01c0eb08  caffc003c101              mov r10,#0x1c103c0
01c0eb0e  ccfffc12c101              mov r12,#0x1c112fc
01c0eb18  4916                      mov r9,r4
01c0eb20  1ce02487                  movh r12,#0x8724
01c0eb2c  c7ffd025c101              mov r7,#0x1c125d0
01c0eb32  149c                      goto 0x01c0ebac
01c0eb34  c7ffd025c101              mov r7,#0x1c125d0
01c0eb3c  0100                      idle
01c0eb3e  7c60                      lh.z r4,[r7 + 0x0]
01c0eb42  9050                      jnz r0,0x01c0eba4
01c0eb46  3550                      jz r5,0x01c0ec28
01c0eb48  c4ffb802c101              mov r4,#0x1c102b8
01c0eb50  40b0                      lsl r0,r4,0x10
01c0eb58  ff2f                      add r7,#-0x11
01c0eb5c  3240                      jz r2,0x01c0ec1e
01c0eb5e  001f                      sub r0,r0,r4
01c0eb60  0118                      add r1,r0
01c0eb62  5318                      add r3,r5
01c0eb64  4318                      add r3,r4
01c0eb6a  b219                      not r2,r3
01c0eb6c  bfeaf6e6                  call 0x01c0b95c
01c0eb70  1480                      goto 0x01c0ebb2
01c0eb72  caffc003c101              mov r10,#0x1c103c0
01c0eb78  ccfffc12c101              mov r12,#0x1c112fc
01c0eb82  48e02000                  movz r8,#0x20
01c0eb86  d916                      mov r9,r13
01c0eb8c  048c                      goto 0x01c0eba6
01c0eb8e  caffc003c101              mov r10,#0x1c103c0
01c0eb94  ccfffc12c101              mov r12,#0x1c112fc
01c0eb9e  d916                      mov r9,r13
01c0eba4  6716                      mov r7,r6
01c0eba8  1ce00324                  movh r12,#0x2403
01c0ebac  4be00100                  movz r11,#0x1
01c0ebb0  934c                      jnz r3,0x01c0ec0a
01c0ebba  2118                      add r1,r2
01c0ebbe  0000                      nop
01c0ebc2  1482                      goto 0x01c0ec08
01c0ebc4  4061                      lw r0,[r4 + 0x4]
01c0ebc8  c884                      add r0,sp,#0x44
01c0ebca  d116                      mov r1,r13
01c0ebcc  bfea4efd                  call 0x01c0e66c
01c0ebd0  462d                      mov r6,#0xd
01c0ebd4  d000                      goto r0
01c0ebd6  c1ffac02c101              mov r1,#0x1c102ac
01c0ebdc  9060                      sw r0,[r1 + 0x0]
01c0ebe0  0040                      jz r0,0x01c0ebe2
01c0ebe2  c0ffbc02c101              mov r0,#0x1c102bc
01c0ebea  0000                      nop
01c0ebec  6016                      mov r0,r6
01c0ebee  2282                      add sp,#0x88
01c0ebf0  5f04                      pop {pc,0xf}
01c0ebf8  0880                      add r0,r0,#0x0
01c0ebfa  4320                      mov r3,#0x0
01c0ebfc  c6ffb802c101              mov r6,#0x1c102b8
01c0ec02  048f                      goto 0x01c0ec22
01c0ec04  4be0ff00                  movz r11,#0xff
01c0ec08  4320                      mov r3,#0x0
01c0ec10  0880                      add r0,r0,#0x0
01c0ec12  c6ffb802c101              mov r6,#0x1c102b8
01c0ec1a  20b0                      lsl r0,r2,0x10
01c0ec1c  8414                      clr r4_r5
01c0ec20  0902                      pfetch [r9]
01c0ec22  c0ffcc12c101              mov r0,#0x1c112cc
01c0ec2a  0100                      idle
01c0ec2c  0460                      lw r4,[r0 + 0x0]
01c0ec30  cc00                      call r12
01c0ec32  051f                      sub r5,r0,r4
01c0ec34  0351                      jz r3,0x01c0ec58
01c0ec3c  4021                      mov r0,#0x1
01c0ec3e  e840                      sb r0,[r6 + 0x0]
01c0ec42  c800                      call r8
01c0ec46  5118                      add r1,r5
01c0ec4c  391e                      sub r1,r3,r1
01c0ec4e  0118                      add r1,r0
01c0ec50  3016                      mov r0,r3
01c0ec52  bfea83e6                  call 0x01c0b95c
01c0ec56  1484                      goto 0x01c0eca0
01c0ec58  6840                      lb.z r0,[r6 + 0x0]
01c0ec5a  0057                      jz r0,0x01c0ec8a
01c0ec5c  c0ffd812c101              mov r0,#0x1c112d8
01c0ec62  0840                      lb.z r0,[r0 + 0x0]
01c0ec64  0116                      mov r1,r0
01c0ec68  0100                      idle
01c0ec6a  4120                      mov r1,#0x0
01c0ec6c  11a8                      lsl r1,r1,0x8
01c0ec6e  42e00010                  movz r2,#0x1000
01c0ec76  1216                      mov r2,r1
01c0ec7a  5018                      add r0,r5
01c0ec7c  801e                      sub r0,r0,r2
01c0ec80  501f                      sub r0,r5,r4
01c0ec82  911e                      sub r1,r1,r2
01c0ec84  bfea6ae6                  call 0x01c0b95c
01c0ec88  048b                      goto 0x01c0eca0
01c0ec8a  4220                      mov r2,#0x0
01c0ec8c  ea40                      sb r2,[r6 + 0x0]
01c0ec90  ffb0                      qasr r7,r7,0x10
01c0ec94  80ea8e08                  call 0x01c0fdb4
01c0ec9a  0000                      nop
01c0ec9c  4be0ffff                  movz r11,#0xffff
01c0eca0  6840                      lb.z r0,[r6 + 0x0]
01c0eca2  0052                      jz r0,0x01c0ecc8
01c0eca4  c0ffd812c101              mov r0,#0x1c112d8
01c0ecaa  0840                      lb.z r0,[r0 + 0x0]
01c0ecac  0116                      mov r1,r0
01c0ecb0  0100                      idle
01c0ecb2  4120                      mov r1,#0x0
01c0ecb4  11a8                      lsl r1,r1,0x8
01c0ecb6  42e00010                  movz r2,#0x1000
01c0ecbe  1216                      mov r2,r1
01c0ecc4  bfea4ae6                  call 0x01c0b95c
01c0ecc8  b216                      mov r2,r11
01c0ecca  80ea7308                  call 0x01c0fdb4
01c0ecce  0047                      jz r0,0x01c0ecde
01c0ecd0  6840                      lb.z r0,[r6 + 0x0]
01c0ecd6  4021                      mov r0,#0x1
01c0ecd8  4020                      mov r0,#0x0
01c0ecda  80ea5709                  call 0x01c0ff8c
01c0ecde  2017                      uxtb r0,r2
01c0ece6  d150                      jnz r1,0x01c0ec48
01c0ece8  6840                      lb.z r0,[r6 + 0x0]
01c0ecea  0057                      jz r0,0x01c0ed1a
01c0ecec  a016                      mov r0,r10
01c0ecf0  021a                      lsl r2,r0
01c0ecf6  4020                      mov r0,#0x0
01c0ecfa  a0a0                      lsr r0,r2,0x0
01c0ecfc  1263                      lw r2,[r1 + 0xc]
01c0ed00  1160                      lw r1,[r1 + 0x0]
01c0ed06  0487                      goto 0x01c0ed16
01c0ed08  80ea5408                  call 0x01c0fdb4
01c0ed10  462e                      mov r6,#0xe
01c0ed12  a79f                      goto 0x01c0ebd2
01c0ed14  4020                      mov r0,#0x0
01c0ed18  d100                      goto r1
01c0ed1a  4620                      mov r6,#0x0
01c0ed2c  4118                      add r1,r4
01c0ed2e  5216                      mov r2,r5
01c0ed30  bfeaf9e5                  call 0x01c0b926
01c0ed34  a78e                      goto 0x01c0ebd2

;===== FUNC_01c0ed36  (called 2x) =====
01c0ed36  7f04                      push {0xf}
01c0ed38  e297                      add sp,#-0x24
01c0ed3a  c0ff7402c101              mov r0,#0x1c10274
01c0ed40  0840                      lb.z r0,[r0 + 0x0]
01c0ed44  0080                      rep 0x2,0x0
01c0ed46  8014                      clr r0_r1
01c0ed48  4220                      mov r2,#0x0
01c0ed4a  bfeaeaf6                  call 0x01c0db22
01c0ed4e  8888                      add r0,sp,#0x8
01c0ed50  8984                      add r1,sp,#0x4
01c0ed52  8a80                      add r2,sp,#0x0
01c0ed54  bfea98e6                  call 0x01c0ba88
01c0ed58  cbffb802c101              mov r11,#0x1c102b8
01c0ed60  ff00                      sti r15
01c0ed62  1701                      tbh r7
01c0ed68  caffd015c101              mov r10,#0x1c115d0
01c0ed6e  cfffffff0000              mov r15,#0xffff
01c0ed74  cdffbc02c101              mov r13,#0x1c102bc
01c0ed7a  2498                      goto 0x01c0ee2c
01c0ed7c  52ac                      lsl r2,r5,0xc
01c0ed7e  80ea1908                  call 0x01c0fdb4
01c0ed82  0045                      jz r0,0x01c0ed8e
01c0ed84  c0ff7002c101              mov r0,#0x1c10270
01c0ed8a  8260                      sw r2,[r0 + 0x0]
01c0ed8c  749b                      goto 0x01c0ef84
01c0ed90  804b                      jnz r0,0x01c0eda8
01c0ed92  c0ffffffff0f              mov r0,#0xfffffff
01c0ed9a  2300                      btbclr
01c0ed9e  7024                      mov r0,#0xc4
01c0edac  4716                      mov r7,r4
01c0edae  4420                      mov r4,#0x0
01c0edb0  0499                      goto 0x01c0ede4
01c0edb2  c0ff7002c101              mov r0,#0x1c10270
01c0edbc  0160                      lw r1,[r0 + 0x0]
01c0edc2  c0ff7502c101              mov r0,#0x1c10275
01c0edc8  0840                      lb.z r0,[r0 + 0x0]
01c0edca  104c                      jz r0,0x01c0ee24
01c0edcc  c0ffd812c101              mov r0,#0x1c112d8
01c0edd2  0840                      lb.z r0,[r0 + 0x0]
01c0edd6  2602                      flush [r6]
01c0edd8  4023                      mov r0,#0x3
01c0edda  80ea4608                  call 0x01c0fe6a
01c0edde  0482                      goto 0x01c0ede4
01c0ede0  4420                      mov r4,#0x0
01c0ede2  4720                      mov r7,#0x0
01c0ede4  7016                      mov r0,r7
01c0ede6  4116                      mov r1,r4
01c0ede8  9216                      mov r2,r9
01c0edea  bfeacaf7                  call 0x01c0dd82
01c0edee  7016                      mov r0,r7
01c0edf0  bfea19f8                  call 0x01c0de26
01c0edf6  de00                      goto r14
01c0edf8  c0ff7502c101              mov r0,#0x1c10275
01c0edfe  0840                      lb.z r0,[r0 + 0x0]
01c0ee00  0048                      jz r0,0x01c0ee12
01c0ee02  c0ffd812c101              mov r0,#0x1c112d8
01c0ee08  0840                      lb.z r0,[r0 + 0x0]
01c0ee0c  0202                      pfetch [r2]
01c0ee0e  4023                      mov r0,#0x3
01c0ee10  0481                      goto 0x01c0ee14
01c0ee12  4022                      mov r0,#0x2
01c0ee14  4116                      mov r1,r4
01c0ee16  80ea2808                  call 0x01c0fe6a
01c0ee1a  c0ff7002c101              mov r0,#0x1c10270
01c0ee20  8760                      sw r7,[r0 + 0x0]
01c0ee22  5490                      goto 0x01c0ef84
01c0ee24  4022                      mov r0,#0x2
01c0ee26  80ea2008                  call 0x01c0fe6a
01c0ee2a  e79c                      goto 0x01c0ede4
01c0ee2e  0090                      rep 0x2,0x10
01c0ee34  b000                      testset b[r0]
01c0ee38  0048                      jz r0,0x01c0ee4a
01c0ee3a  8014                      clr r0_r1
01c0ee3c  4220                      mov r2,#0x0
01c0ee3e  c3ffa6f6c001              mov r3,#0x1c0f6a6
01c0ee44  bfea3de6                  call 0x01c0bac2
01c0ee48  0484                      goto 0x01c0ee52
01c0ee4a  7016                      mov r0,r7
01c0ee4c  9116                      mov r1,r9
01c0ee4e  bfeae9f6                  call 0x01c0dc24
01c0ee52  c0ff7502c101              mov r0,#0x1c10275
01c0ee5c  0940                      lb.z r1,[r0 + 0x0]
01c0ee66  0159                      jz r1,0x01c0ee9a
01c0ee68  4121                      mov r1,#0x1
01c0ee6e  005a                      jz r0,0x01c0eea4
01c0ee72  e950                      sb r1,[r6 + -0x10]
01c0ee74  501d                      add r0,r5,r4
01c0ee76  bfea82e3                  call 0x01c0b57e
01c0ee7a  4020                      mov r0,#0x0
01c0ee7c  42e00001                  movz r2,#0x100
01c0ee80  a116                      mov r1,r10
01c0ee82  bfeadde4                  call 0x01c0b840
01c0ee86  0216                      mov r2,r0
01c0ee90  d91d                      add r1,r5,r7
01c0ee92  a016                      mov r0,r10
01c0ee94  80eab307                  call 0x01c0fdfe
01c0ee98  0485                      goto 0x01c0eea4
01c0ee9a  4121                      mov r1,#0x1
01c0ee9e  0000                      nop
01c0eea0  0116                      mov r1,r0
01c0eea2  1e18                      add r14,r1
01c0eea4  888c                      add r0,sp,#0xc
01c0eea6  4120                      mov r1,#0x0
01c0eea8  4238                      mov r2,#0x18
01c0eeaa  bfea1df2                  call 0x01c0d2e8
01c0eeb0  0da0                      qasl r5,r0,0x0
01c0eeb2  c0ffd025c101              mov r0,#0x1c125d0
01c0eeba  cd00                      call r13
01c0eebe  e900                      cli r9
01c0eec6  7068                      lw r0,[r7 + 0x20]
01c0eeca  4058                      jz r0,0x01c0edfc
01c0eecc  bfea01df                  call 0x01c0acd2
01c0eed4  40e00002                  movz r0,#0x200
01c0eed8  0146                      jz r1,0x01c0eee6
01c0eeda  0216                      mov r2,r0
01c0eedc  4320                      mov r3,#0x0
01c0eede  5016                      mov r0,r5
01c0eee0  6116                      mov r1,r6
01c0eee2  bfeaeee5                  call 0x01c0bac2
01c0eee6  8217                      uxth r2,r0
01c0eee8  0251                      jz r2,0x01c0ef0c
01c0eeea  5016                      mov r0,r5
01c0eeec  bfea47e3                  call 0x01c0b57e
01c0eef0  4020                      mov r0,#0x0
01c0eef2  a116                      mov r1,r10
01c0eef4  bfeaa4e4                  call 0x01c0b840
01c0eef8  0516                      mov r5,r0
01c0eefa  254d                      jz r5,0x01c0ef96
01c0eefe  4b50                      lb.z r3,[r4 + -0x10]
01c0ef00  a016                      mov r0,r10
01c0ef02  6116                      mov r1,r6
01c0ef04  5216                      mov r2,r5
01c0ef06  80ea7a07                  call 0x01c0fdfe
01c0ef0a  0481                      goto 0x01c0ef0e
01c0ef0c  4520                      mov r5,#0x0
01c0ef14  008e                      rep 0x2,0xe
01c0ef1a  0746                      jz r7,0x01c0ef28
01c0ef1e  807b                      sw r0,[r0 + -0x14]
01c0ef20  0300                      hbkpt
01c0ef24  807d                      sw r0,[r0 + -0xc]
01c0ef28  c0ff4c15c101              mov r0,#0x1c1154c
01c0ef2e  0061                      lw r0,[r0 + 0x4]
01c0ef34  c0ffd012c101              mov r0,#0x1c112d0
01c0ef3c  0d60                      lh.z r5,[r0 + 0x0]
01c0ef3e  bfea72f7                  call 0x01c0de26
01c0ef44  1b01                      tbh r11
01c0ef46  7016                      mov r0,r7
01c0ef48  4116                      mov r1,r4
01c0ef4a  9216                      mov r2,r9
01c0ef4c  bfeaebe4                  call 0x01c0b926
01c0ef50  0499                      goto 0x01c0ef84
01c0ef52  c0ffc003c101              mov r0,#0x1c103c0
01c0ef5c  4134                      mov r1,#0x14
01c0ef5e  bfea3ae0                  call 0x01c0afd6
01c0ef62  0050                      jz r0,0x01c0ef84
01c0ef64  8762                      sw r7,[r0 + 0x8]
01c0ef68  0d90                      add r5,r0,#0x10
01c0ef6a  c1ffc003c101              mov r1,#0x1c103c0
01c0ef70  1216                      mov r2,r1
01c0ef74  2819                      xor r0,r2
01c0ef76  9061                      sw r0,[r1 + 0x4]
01c0ef7c  8160                      sw r1,[r0 + 0x0]
01c0ef7e  8161                      sw r1,[r0 + 0x4]
01c0ef84  8888                      add r0,sp,#0x8
01c0ef86  8984                      add r1,sp,#0x4
01c0ef88  8a80                      add r2,sp,#0x0
01c0ef8a  bfea7de5                  call 0x01c0ba88
01c0ef92  4420                      mov r4,#0x0
01c0ef94  0481                      goto 0x01c0ef98
01c0ef96  442e                      mov r4,#0xe
01c0ef9a  b000                      testset b[r0]
01c0ef9e  0040                      jz r0,0x01c0efa0
01c0efa0  4020                      mov r0,#0x0
01c0efa4  b000                      testset b[r0]
01c0efa6  8014                      clr r0_r1
01c0efa8  8214                      clr r2_r3
01c0efaa  bfea8ae5                  call 0x01c0bac2
01c0efae  4016                      mov r0,r4
01c0efb0  0289                      add sp,#0x24
01c0efb2  5f04                      pop {pc,0xf}
01c0efb4  c0ff7002c101              mov r0,#0x1c10270
01c0efba  8760                      sw r7,[r0 + 0x0]
01c0efbc  4428                      mov r4,#0x8
01c0efbe  f78c                      goto 0x01c0ef98

;===== FUNC_01c0efc0  (called 2x) =====
01c0efc0  7f04                      push {0xf}
01c0efc2  c299                      add sp,#-0x9c
01c0efc4  4021                      mov r0,#0x1
01c0efc6  80ea5106                  call 0x01c0fc6c
01c0efca  c0ffac02c101              mov r0,#0x1c102ac
01c0efd0  0060                      lw r0,[r0 + 0x0]
01c0efd4  0000                      nop
01c0efd8  c8ff7002c101              mov r8,#0x1c10270
01c0efe0  80a0                      lsr r0,r0,0x0
01c0efe2  c314                      clr r11
01c0efe4  c0ffffff0000              mov r0,#0xffff
01c0efea  c9ffd015c101              mov r9,#0x1c115d0
01c0eff0  4b20                      mov r3,#0x20
01c0eff4  01b0                      lsl r1,r0,0x10
01c0eff6  a116                      mov r1,r10
01c0eff8  9216                      mov r2,r9
01c0effa  bfeaf6dd                  call 0x01c0abea
01c0effe  9016                      mov r0,r9
01c0f000  bfea0ff3                  call 0x01c0d622
01c0f004  4de01300                  movz r13,#0x13
01c0f00a  0000                      nop
01c0f00e  bfea60de                  call 0x01c0acd2
01c0f014  20a0                      lsl r0,r2,0x0
01c0f016  c7ffffff0000              mov r7,#0xffff
01c0f01c  c4ffe8d5c001              mov r4,#0x1c0d5e8
01c0f022  ceffcc12c101              mov r14,#0x1c112cc
01c0f028  4b20                      mov r3,#0x20
01c0f02c  01b0                      lsl r1,r0,0x10
01c0f02e  7016                      mov r0,r7
01c0f030  6116                      mov r1,r6
01c0f032  9216                      mov r2,r9
01c0f034  bfead9dd                  call 0x01c0abea
01c0f038  9016                      mov r0,r9
01c0f03a  bfeaf2f2                  call 0x01c0d622
01c0f040  0000                      nop
01c0f042  1901                      tbh r9
01c0f046  1090                      rep 0x4,0x10
01c0f048  422d                      mov r2,#0xd
01c0f04a  4116                      mov r1,r4
01c0f04c  bfeafee3                  call 0x01c0b84c
01c0f052  0040                      jz r0,0x01c0f054
01c0f05a  e100                      cli r1
01c0f060  ce20                      add r6,#0x20
01c0f062  7042                      jz r0,0x01c0f028
01c0f066  e000                      cli r0
01c0f06e  05a0                      lsl r5,r0,0x0
01c0f07c  c0ffc003c101              mov r0,#0x1c103c0
01c0f086  c5ffd025c101              mov r5,#0x1c125d0
01c0f08c  c4ffac15c101              mov r4,#0x1c115ac
01c0f092  a616                      mov r6,r10
01c0f098  4b20                      mov r3,#0x20
01c0f09e  c016                      mov r0,r12
01c0f0a0  6116                      mov r1,r6
01c0f0a2  5216                      mov r2,r5
01c0f0a4  bfeaa1dd                  call 0x01c0abea
01c0f0a8  5016                      mov r0,r5
01c0f0aa  bfeabaf2                  call 0x01c0d622
01c0f0ae  1052                      jz r0,0x01c0f114
01c0f0b2  e000                      cli r0
01c0f0ba  1018                      add r0,r1
01c0f0be  e500                      cli r5
01c0f0c0  a890                      add r0,sp,#0x30
01c0f0c2  0116                      mov r1,r0
01c0f0c4  4720                      mov r7,#0x0
01c0f0c6  0087                      rep 0x2,0x7
01c0f0c8  9705                      sw r7,[r1 ++= 4]
01c0f0ca  4a20                      mov r2,#0x20
01c0f0cc  4116                      mov r1,r4
01c0f0ce  bfea8ef0                  call 0x01c0d1ee
01c0f0d4  d800                      goto r8
01c0f0d6  c890                      add r0,sp,#0x50
01c0f0d8  0116                      mov r1,r0
01c0f0da  0087                      rep 0x2,0x7
01c0f0dc  9705                      sw r7,[r1 ++= 4]
01c0f0de  4a20                      mov r2,#0x20
01c0f0e0  4116                      mov r1,r4
01c0f0e2  bfea84f0                  call 0x01c0d1ee
01c0f0e6  0116                      mov r1,r0
01c0f0ea  0000                      nop
01c0f0ec  4116                      mov r1,r4
01c0f0ee  4a20                      mov r2,#0x20
01c0f0f0  5016                      mov r0,r5
01c0f0f2  bfea98f0                  call 0x01c0d226
01c0f0f6  4a20                      mov r2,#0x20
01c0f0f8  4320                      mov r3,#0x0
01c0f0fa  4820                      mov r0,#0x20
01c0f100  5116                      mov r1,r5
01c0f102  bfeadee3                  call 0x01c0b8c2
01c0f106  5016                      mov r0,r5
01c0f108  bfea8bf2                  call 0x01c0d622
01c0f10c  48e00100                  movz r8,#0x1
01c0f112  bb00                      testset b[r11]
01c0f116  5062                      lw r0,[r5 + 0x8]
01c0f11a  5c50                      lb.z r4,[r5 + -0x10]
01c0f11c  ce20                      add r6,#0x20
01c0f12a  c214                      clr r10
01c0f12c  df16                      mov r15,r13
01c0f12e  4420                      mov r4,#0x0
01c0f130  e716                      mov r7,r14
01c0f136  47e00010                  movz r7,#0x1000
01c0f13a  bfeacadd                  call 0x01c0acd2
01c0f142  9016                      mov r0,r9
01c0f144  6116                      mov r1,r6
01c0f146  7216                      mov r2,r7
01c0f148  80ea5205                  call 0x01c0fbf0
01c0f14c  0488                      goto 0x01c0f15e
01c0f152  c016                      mov r0,r12
01c0f154  6116                      mov r1,r6
01c0f156  9216                      mov r2,r9
01c0f158  7316                      mov r3,r7
01c0f15a  bfea46dd                  call 0x01c0abea
01c0f15e  c017                      uxth r0,r4
01c0f160  f117                      uxth r1,r7
01c0f162  bfea97e3                  call 0x01c0b894
01c0f166  7a18                      add r10,r7
01c0f168  0416                      mov r4,r0
01c0f16c  00aa                      lsl r0,r0,0xa
01c0f174  41e00001                  movz r1,#0x100
01c0f178  422a                      mov r2,#0xa
01c0f17a  bfeaa8f4                  call 0x01c0dace
01c0f17e  c214                      clr r10
01c0f180  7f18                      add r15,r7
01c0f186  7618                      add r6,r7
01c0f18c  0482                      goto 0x01c0f192
01c0f18e  4420                      mov r4,#0x0
01c0f190  df16                      mov r15,r13
01c0f194  0000                      nop
01c0f196  df16                      mov r15,r13
01c0f198  c5ffd025c101              mov r5,#0x1c125d0
01c0f1a0  5861                      lh.z r0,[r5 + 0x2]
01c0f1ae  b000                      testset b[r0]
01c0f1b2  0ca0                      qasl r4,r0,0x0
01c0f1b4  c4ffac15c101              mov r4,#0x1c115ac
01c0f1be  e890                      add r0,sp,#0x70
01c0f1c0  c014                      clr r8
01c0f1c2  0116                      mov r1,r0
01c0f1c4  1087                      rep 0x4,0x7
01c0f1c8  1580                      goto 0x01c0f60a
01c0f1ca  4a20                      mov r2,#0x20
01c0f1cc  4116                      mov r1,r4
01c0f1ce  bfea0ef0                  call 0x01c0d1ee
01c0f1d4  0000                      nop
01c0f1d6  4016                      mov r0,r4
01c0f1d8  4a20                      mov r2,#0x20
01c0f1da  a116                      mov r1,r10
01c0f1dc  80ea0f06                  call 0x01c0fdfe
01c0f1e0  8890                      add r0,sp,#0x10
01c0f1e2  0116                      mov r1,r0
01c0f1e4  1087                      rep 0x4,0x7
01c0f1e8  1580                      goto 0x01c0f62a
01c0f1ea  4a20                      mov r2,#0x20
01c0f1ec  4116                      mov r1,r4
01c0f1ee  bfeafeef                  call 0x01c0d1ee
01c0f1f4  0000                      nop
01c0f1f6  4016                      mov r0,r4
01c0f1f8  4120                      mov r1,#0x0
01c0f1fa  4a20                      mov r2,#0x20
01c0f1fc  bfea74f0                  call 0x01c0d2e8
01c0f200  0485                      goto 0x01c0f20c
01c0f204  0ca0                      qasl r4,r0,0x0
01c0f206  c4ffac15c101              mov r4,#0x1c115ac
01c0f20c  5867                      lh.z r0,[r5 + 0xe]
01c0f214  844b                      jnz r4,0x01c0f22c
01c0f216  c0ffd012c101              mov r0,#0x1c112d0
01c0f21c  0860                      lh.z r0,[r0 + 0x0]
01c0f222  4420                      mov r4,#0x0
01c0f224  c0ffb002c101              mov r0,#0x1c102b0
01c0f22a  0460                      lw r4,[r0 + 0x0]
01c0f22c  80eac205                  call 0x01c0fdb4
01c0f230  c514                      clr r13
01c0f232  1041                      jz r0,0x01c0f276
01c0f234  4016                      mov r0,r4
01c0f236  bfeaf6f5                  call 0x01c0de26
01c0f23a  005d                      jz r0,0x01c0f276
01c0f23c  c0ff4c15c101              mov r0,#0x1c1154c
01c0f242  0261                      lw r2,[r0 + 0x4]
01c0f244  c0fffc12c101              mov r0,#0x1c112fc
01c0f24c  0162                      lw r1,[r0 + 0x8]
01c0f24e  bfea6ae3                  call 0x01c0b926
01c0f252  4020                      mov r0,#0x0
01c0f254  80ea9a06                  call 0x01c0ff8c
01c0f258  80ea0805                  call 0x01c0fc6c
01c0f25c  bfea6bfd                  call 0x01c0ed36
01c0f260  0d16                      mov r13,r0
01c0f262  4021                      mov r0,#0x1
01c0f264  80ea0205                  call 0x01c0fc6c
01c0f26c  bfeaa8fe                  call 0x01c0efc0
01c0f270  0d16                      mov r13,r0
01c0f272  0481                      goto 0x01c0f276
01c0f274  c514                      clr r13
01c0f276  d016                      mov r0,r13
01c0f278  2287                      add sp,#0x9c
01c0f27a  5f04                      pop {pc,0xf}
01c0f27c  4de01400                  movz r13,#0x14
01c0f282  0ca0                      qasl r4,r0,0x0
01c0f284  0482                      goto 0x01c0f28a
01c0f286  4de00b00                  movz r13,#0xb
01c0f28a  c0ff7502c101              mov r0,#0x1c10275
01c0f290  0840                      lb.z r0,[r0 + 0x0]
01c0f292  0048                      jz r0,0x01c0f2a4
01c0f294  c0ffd812c101              mov r0,#0x1c112d8
01c0f29a  0840                      lb.z r0,[r0 + 0x0]
01c0f29e  0202                      pfetch [r2]
01c0f2a0  4023                      mov r0,#0x3
01c0f2a2  0481                      goto 0x01c0f2a6
01c0f2a4  4022                      mov r0,#0x2
01c0f2a6  a116                      mov r1,r10
01c0f2a8  80eadf05                  call 0x01c0fe6a
01c0f2ac  f784                      goto 0x01c0f276

;===== FUNC_01c0f2ae  (called 1x) =====
01c0f2ae  1004                      push rets
01c0f2b0  e29d                      add sp,#-0xc
01c0f2b2  80ea7f05                  call 0x01c0fdb4
01c0f2b6  0046                      jz r0,0x01c0f2c4
01c0f2b8  4020                      mov r0,#0x0
01c0f2ba  80ea6706                  call 0x01c0ff8c
01c0f2be  4021                      mov r0,#0x1
01c0f2c0  80ead404                  call 0x01c0fc6c
01c0f2c4  c0ff5cd4c001              mov r0,#0x1c0d45c
01c0f2ca  0162                      lw r1,[r0 + 0x8]
01c0f2d6  8880                      add r0,sp,#0x0
01c0f2d8  bfeaaff2                  call 0x01c0d83a
01c0f2de  0000                      nop
01c0f2e0  0283                      add sp,#0xc
01c0f2e2  0004                      pop pc

;===== FUNC_01c0f2e4  (called 1x) =====
01c0f2e4  7504                      push {0x5}
01c0f2e6  e297                      add sp,#-0x24
01c0f2e8  c0ffc003c101              mov r0,#0x1c103c0
01c0f2ee  c1ffcc12c101              mov r1,#0x1c112cc
01c0f2f4  1160                      lw r1,[r1 + 0x0]
01c0f2f6  c2ff7002c101              mov r2,#0x1c10270
01c0f2fc  2260                      lw r2,[r2 + 0x0]
01c0f2fe  4520                      mov r5,#0x0
01c0f302  0862                      lh.z r0,[r0 + 0x4]
01c0f304  8c84                      add r4,sp,#0x4
01c0f306  4b20                      mov r3,#0x20
01c0f30c  bfea6ddc                  call 0x01c0abea
01c0f310  4016                      mov r0,r4
01c0f312  bfea86f1                  call 0x01c0d622
01c0f316  8053                      jnz r0,0x01c0f33e
01c0f318  bfeac8f2                  call 0x01c0d8ac
01c0f31c  0416                      mov r4,r0
01c0f31e  044f                      jz r4,0x01c0f33e
01c0f320  c5ffd015c101              mov r5,#0x1c115d0
01c0f326  5230                      mov r2,#0x50
01c0f328  5016                      mov r0,r5
01c0f32a  4116                      mov r1,r4
01c0f32c  80ea6004                  call 0x01c0fbf0
01c0f330  4020                      mov r0,#0x0
01c0f334  d860                      sh r0,[r5 + 0x0]
01c0f336  4222                      mov r2,#0x2
01c0f338  4116                      mov r1,r4
01c0f33a  80ea6005                  call 0x01c0fdfe
01c0f33e  0289                      add sp,#0x24
01c0f340  5504                      pop {pc,0x5}

;===== FUNC_01c0f342  (called 1x) =====
01c0f342  1004                      push rets
01c0f344  e29f                      add sp,#-0x4
01c0f346  c0ff98d5c001              mov r0,#0x1c0d598
01c0f34c  8980                      add r1,sp,#0x0
01c0f34e  bfea0af2                  call 0x01c0d766
01c0f354  0000                      nop
01c0f358  0281                      add sp,#0x4
01c0f35a  0004                      pop pc
01c0f35c  7f04                      push {0xf}
01c0f35e  c293                      add sp,#-0xb4
01c0f362  0763                      lw r7,[r0 + 0xc]
01c0f364  ccff7002c101              mov r12,#0x1c10270
01c0f36c  c090                      rep 0x1a,0x10
01c0f36e  caffc003c101              mov r10,#0x1c103c0
01c0f376  a480                      goto 0x01c0f5f8
01c0f378  0062                      lw r0,[r0 + 0x8]
01c0f37a  bfea00e1                  call 0x01c0b57e
01c0f37e  7516                      mov r5,r7
01c0f384  45e00010                  movz r5,#0x1000
01c0f388  bfeaa3dc                  call 0x01c0acd2
01c0f38c  4620                      mov r6,#0x0
01c0f38e  cfffd025c101              mov r15,#0x1c125d0
01c0f396  601f                      sub r0,r6,r4
01c0f398  5416                      mov r4,r5
01c0f39c  0002                      pfetch [r0]
01c0f39e  44e00002                  movz r4,#0x200
01c0f3a2  c217                      uxth r2,r4
01c0f3a4  4020                      mov r0,#0x0
01c0f3a6  bfea4be2                  call 0x01c0b840
01c0f3aa  551f                      sub r5,r5,r4
01c0f3ac  4618                      add r6,r4
01c0f3ae  f552                      jnz r5,0x01c0f394
01c0f3b2  b830                      bitclr r0,0x10
01c0f3b4  4820                      mov r0,#0x20
01c0f3ba  8016                      mov r0,r8
01c0f3bc  f116                      mov r1,r15
01c0f3be  bfea80e2                  call 0x01c0b8c2
01c0f3c2  f016                      mov r0,r15
01c0f3c4  bfea2df1                  call 0x01c0d622
01c0f3ca  0043                      jz r0,0x01c0f3d2
01c0f3cc  7016                      mov r0,r7
01c0f3ce  228d                      add sp,#0xb4
01c0f3d0  5f04                      pop {pc,0xf}
01c0f3d2  c0ff50d4c001              mov r0,#0x1c0d450
01c0f3d8  0162                      lw r1,[r0 + 0x8]
01c0f3e2  4920                      mov r1,#0x20
01c0f3e4  4020                      mov r0,#0x0
01c0f3e8  c888                      add r0,sp,#0x48
01c0f3ec  c0ff84f6c001              mov r0,#0x1c0f684
01c0f3f4  a89c                      add r0,sp,#0x3c
01c0f3f6  bfea20f2                  call 0x01c0d83a
01c0f3fc  a300                      swi 0x3
01c0f406  e2ff80260032              mov retx,#0x32002680
01c0f40e  0002                      pfetch [r0]
01c0f412  a898                      add r0,sp,#0x38
01c0f414  4224                      mov r2,#0x4
01c0f418  80eaea03                  call 0x01c0fbf0
01c0f41e  b040                      jnz r0,0x01c0f4e0
01c0f422  a4b0                      lsr r4,r2,0x10
01c0f428  c214                      clr r10
01c0f42a  c0ffffff0000              mov r0,#0xffff
01c0f432  9450                      jnz r4,0x01c0f494
01c0f434  4b20                      mov r3,#0x20
01c0f438  01a0                      lsl r1,r0,0x0
01c0f43a  c116                      mov r1,r12
01c0f43c  5216                      mov r2,r5
01c0f43e  bfead4db                  call 0x01c0abea
01c0f442  5016                      mov r0,r5
01c0f444  bfeaedf0                  call 0x01c0d622
01c0f448  b05b                      jnz r0,0x01c0f540
01c0f44a  bfea42dc                  call 0x01c0acd2
01c0f452  e894                      add r0,sp,#0x74
01c0f458  ceffffff0000              mov r14,#0xffff
01c0f45e  c5ffe8d5c001              mov r5,#0x1c0d5e8
01c0f464  ef94                      add r7,sp,#0x74
01c0f466  4b20                      mov r3,#0x20
01c0f46a  01a0                      lsl r1,r0,0x0
01c0f46c  e016                      mov r0,r14
01c0f46e  6116                      mov r1,r6
01c0f470  7216                      mov r2,r7
01c0f472  bfeabadb                  call 0x01c0abea
01c0f476  7016                      mov r0,r7
01c0f478  bfead3f0                  call 0x01c0d622
01c0f47c  b041                      jnz r0,0x01c0f540
01c0f47e  422d                      mov r2,#0xd
01c0f480  d016                      mov r0,r13
01c0f482  5116                      mov r1,r5
01c0f484  bfeae2e1                  call 0x01c0b84c
01c0f488  ce20                      add r6,#0x20
01c0f48a  704c                      jz r0,0x01c0f464
01c0f48e  bfea20dc                  call 0x01c0acd2
01c0f492  4620                      mov r6,#0x0
01c0f498  ef94                      add r7,sp,#0x74
01c0f49a  4b20                      mov r3,#0x20
01c0f49c  b016                      mov r0,r11
01c0f49e  c116                      mov r1,r12
01c0f4a0  7216                      mov r2,r7
01c0f4a2  bfeaa2db                  call 0x01c0abea
01c0f4a6  7016                      mov r0,r7
01c0f4a8  bfeabbf0                  call 0x01c0d622
01c0f4ac  a049                      jnz r0,0x01c0f540
01c0f4b0  54a0                      lsl r4,r5,0x0
01c0f4b2  e894                      add r0,sp,#0x74
01c0f4b6  10a0                      lsl r0,r1,0x0
01c0f4bc  4016                      mov r0,r4
01c0f4be  bfea79ef                  call 0x01c0d3b4
01c0f4c2  0217                      uxtb r2,r0
01c0f4c4  4016                      mov r0,r4
01c0f4c6  d116                      mov r1,r13
01c0f4c8  bfeac0e1                  call 0x01c0b84c
01c0f4ce  c700                      call r7
01c0f4d2  084c                      lb.z r0,[r0 + 0xc]
01c0f4d6  0300                      hbkpt
01c0f4d8  2300                      btbclr
01c0f4da  bfeafadb                  call 0x01c0acd2
01c0f4e0  2060                      lw r0,[r2 + 0x0]
01c0f4e8  cd94                      add r5,sp,#0x54
01c0f4ea  4b20                      mov r3,#0x20
01c0f4f0  6116                      mov r1,r6
01c0f4f2  5216                      mov r2,r5
01c0f4f4  bfea79db                  call 0x01c0abea
01c0f4f8  5016                      mov r0,r5
01c0f4fa  bfea92f0                  call 0x01c0d622
01c0f4fe  9040                      jnz r0,0x01c0f540
01c0f500  4016                      mov r0,r4
01c0f502  bfea57ef                  call 0x01c0d3b4
01c0f506  0217                      uxtb r2,r0
01c0f508  4016                      mov r0,r4
01c0f50a  e116                      mov r1,r14
01c0f50c  bfea9ee1                  call 0x01c0b84c
01c0f510  805b                      jnz r0,0x01c0f548
01c0f514  ae00                      swi 0x6
01c0f516  cf20                      add r7,#0x20
01c0f518  ce20                      add r6,#0x20
01c0f51a  7046                      jz r0,0x01c0f4e8
01c0f522  0062                      lw r0,[r0 + 0x8]
01c0f524  0618                      add r6,r0
01c0f52a  ed94                      add r5,sp,#0x74
01c0f52c  4b20                      mov r3,#0x20
01c0f52e  b016                      mov r0,r11
01c0f530  c116                      mov r1,r12
01c0f532  5216                      mov r2,r5
01c0f534  bfea59db                  call 0x01c0abea
01c0f538  5016                      mov r0,r5
01c0f53a  bfea72f0                  call 0x01c0d622
01c0f53e  505e                      jz r0,0x01c0f4bc
01c0f542  a784                      goto 0x01c0f3cc
01c0f546  a782                      goto 0x01c0f3cc
01c0f54c  001c                      add r0,r0,r0
01c0f54e  c0ffcc12c101              mov r0,#0x1c112cc
01c0f558  0060                      lw r0,[r0 + 0x0]
01c0f55a  201e                      sub r0,r2,r0
01c0f55c  c9ffd015c101              mov r9,#0x1c115d0
01c0f568  8016                      mov r0,r8
01c0f56a  9216                      mov r2,r9
01c0f56c  bfea3ddb                  call 0x01c0abea
01c0f572  90a0                      lsr r0,r1,0x0
01c0f576  04a0                      lsl r4,r0,0x0
01c0f588  42e00010                  movz r2,#0x1000
01c0f58c  9016                      mov r0,r9
01c0f590  80ea2e03                  call 0x01c0fbf0
01c0f596  f052                      jnz r0,0x01c0f57c
01c0f598  5884                      add r0,r5,#0x4
01c0f5ac  0490                      goto 0x01c0f5ce
01c0f5bc  29a0                      qasl r1,r2,0x0
01c0f5c0  2080                      rep 0x6,0x0
01c0f5c2  ae8c                      add r6,sp,#0x2c
01c0f5c8  01a1                      lsl r1,r0,0x1
01c0f5ca  bfea82db                  call 0x01c0acd2
01c0f5ce  1545                      jz r5,0x01c0f61a
01c0f5d0  4ae0fcff                  movz r10,#0xfffc
01c0f5d4  a88c                      add r0,sp,#0x2c
01c0f5d6  899e                      add r1,sp,#0x1e
01c0f5d8  8a9c                      add r2,sp,#0x1c
01c0f5da  80ea1b01                  call 0x01c0f814
01c0f5e2  0000                      nop
01c0f5e8  1c50                      lb.z r4,[r1 + -0x10]
01c0f5f2  a880                      add r0,sp,#0x20
01c0f5f4  80ea2f01                  call 0x01c0f856
01c0f5fa  0000                      nop
01c0f5fe  5884                      add r0,r5,#0x4
01c0f600  a98c                      add r1,sp,#0x2c
01c0f608  0660                      lw r6,[r0 + 0x0]
01c0f60c  a215                      mov r2_r3,r10_r11
01c0f60e  6062                      lw r0,[r6 + 0x8]
01c0f610  1018                      add r0,r1
01c0f612  e062                      sw r0,[r6 + 0x8]
01c0f614  e05f                      jnz r0,0x01c0f5d4
01c0f618  88a0                      qasr r0,r0,0x0
01c0f61c  0002                      pfetch [r0]
01c0f620  f016                      mov r0,r15
01c0f622  6116                      mov r1,r6
01c0f624  80eae402                  call 0x01c0fbf0
01c0f632  0080                      rep 0x2,0x0
01c0f634  6016                      mov r0,r6
01c0f636  4116                      mov r1,r4
01c0f638  bfead9f6                  call 0x01c0e3ee
01c0f63c  c5ff7402c101              mov r5,#0x1c10274
01c0f642  5840                      lb.z r0,[r5 + 0x0]
01c0f644  004e                      jz r0,0x01c0f662
01c0f646  8014                      clr r0_r1
01c0f648  4220                      mov r2,#0x0
01c0f64a  4720                      mov r7,#0x0
01c0f64c  bfea69f2                  call 0x01c0db22
01c0f650  4221                      mov r2,#0x1
01c0f652  6016                      mov r0,r6
01c0f654  4116                      mov r1,r4
01c0f656  bfea64f2                  call 0x01c0db22
01c0f65a  df40                      sb r7,[r5 + 0x0]
01c0f65c  0486                      goto 0x01c0f66a
01c0f65e  7061                      lw r0,[r7 + 0x4]
01c0f660  b794                      goto 0x01c0f54a
01c0f662  6016                      mov r0,r6
01c0f664  4116                      mov r1,r4
01c0f666  bfeaddf2                  call 0x01c0dc24
01c0f66a  42e00002                  movz r2,#0x200
01c0f66e  f016                      mov r0,r15
01c0f670  6116                      mov r1,r6
01c0f672  80eac403                  call 0x01c0fdfe
01c0f67a  a216                      mov r2,r10
01c0f67c  80eabf03                  call 0x01c0fdfe
01c0f680  4720                      mov r7,#0x0
01c0f682  5784                      goto 0x01c0f3cc
01c0f684  7504                      push {0x5}
01c0f686  1416                      mov r4,r1
01c0f68a  4262                      lw r2,[r4 + 0x8]
01c0f68c  5990                      add r1,r5,#0x10
01c0f68e  2016                      mov r0,r2
01c0f690  bfea40ee                  call 0x01c0d314
01c0f694  0116                      mov r1,r0
01c0f696  4020                      mov r0,#0x0
01c0f698  8145                      jnz r1,0x01c0f6a4
01c0f69a  5061                      lw r0,[r5 + 0x4]
01c0f69c  c060                      sw r0,[r4 + 0x0]
01c0f69e  5062                      lw r0,[r5 + 0x8]
01c0f6a0  c061                      sw r0,[r4 + 0x4]
01c0f6a2  4021                      mov r0,#0x1
01c0f6a4  5504                      pop {pc,0x5}
01c0f6a6  7704                      push {0x7}
01c0f6a8  c2fffc12c101              mov r2,#0x1c112fc
01c0f6b0  2362                      lw r3,[r2 + 0x8]
01c0f6b2  c6ff7002c101              mov r6,#0x1c10270
01c0f6ba  6260                      lw r2,[r6 + 0x0]
01c0f6bc  841c                      add r4,r0,r2
01c0f6be  80ea7903                  call 0x01c0fdb4
01c0f6c2  c7ffcc12c101              mov r7,#0x1c112cc
01c0f6c8  0048                      jz r0,0x01c0f6da
01c0f6ca  7060                      lw r0,[r7 + 0x0]
01c0f6cc  2018                      add r0,r2
01c0f6d0  0014                      clc
01c0f6d2  4021                      mov r0,#0x1
01c0f6d4  4020                      mov r0,#0x0
01c0f6d6  80eac902                  call 0x01c0fc6c
01c0f6da  4015                      mov r0_r1,r4_r5
01c0f6dc  bfeaa2f2                  call 0x01c0dc24
01c0f6e0  80ea6803                  call 0x01c0fdb4
01c0f6e4  0048                      jz r0,0x01c0f6f6
01c0f6e6  6060                      lw r0,[r6 + 0x0]
01c0f6e8  7160                      lw r1,[r7 + 0x0]
01c0f6ea  1018                      add r0,r1
01c0f6ee  0044                      jz r0,0x01c0f6f8
01c0f6f0  4021                      mov r0,#0x1
01c0f6f2  80eabb02                  call 0x01c0fc6c
01c0f6f6  4020                      mov r0,#0x0
01c0f6f8  5704                      pop {pc,0x7}
01c0f6fa  7704                      push {0x7}
01c0f6fc  0416                      mov r4,r0
01c0f6fe  484d                      lb.z r0,[r4 + 0xd]
01c0f700  c6ff70d4c001              mov r6,#0x1c0d470
01c0f708  0300                      hbkpt
01c0f70c  6d83                      add r5,r6,#0x3
01c0f70e  5016                      mov r0,r5
01c0f710  bfea50ee                  call 0x01c0d3b4
01c0f714  0216                      mov r2,r0
01c0f716  4990                      add r1,r4,#0x10
01c0f718  5016                      mov r0,r5
01c0f71a  bfea68ed                  call 0x01c0d1ee
01c0f71e  a053                      jnz r0,0x01c0f7c6
01c0f720  4062                      lw r0,[r4 + 0x8]
01c0f728  c5ffd015c101              mov r5,#0x1c115d0
01c0f72e  4120                      mov r1,#0x0
01c0f730  42e00010                  movz r2,#0x1000
01c0f734  5016                      mov r0,r5
01c0f736  bfead7ed                  call 0x01c0d2e8
01c0f73a  c0ffd412c101              mov r0,#0x1c112d4
01c0f740  0260                      lw r2,[r0 + 0x0]
01c0f742  4062                      lw r0,[r4 + 0x8]
01c0f746  4361                      lw r3,[r4 + 0x4]
01c0f74c  9457                      jnz r4,0x01c0f7bc
01c0f74e  0318                      add r3,r0
01c0f752  3420                      bitset r4,0x0
01c0f758  1493                      goto 0x01c0f7c0
01c0f75c  4562                      lw r5,[r4 + 0x8]
01c0f75e  bfea29ee                  call 0x01c0d3b4
01c0f762  0216                      mov r2,r0
01c0f764  4f90                      add r7,r4,#0x10
01c0f766  6015                      mov r0_r1,r6_r7
01c0f768  bfea41ed                  call 0x01c0d1ee
01c0f76c  8052                      jnz r0,0x01c0f792
01c0f76e  c0ffd812c101              mov r0,#0x1c112d8
01c0f774  0840                      lb.z r0,[r0 + 0x0]
01c0f776  0116                      mov r1,r0
01c0f77a  0100                      idle
01c0f77c  4120                      mov r1,#0x0
01c0f77e  12a8                      lsl r2,r1,0x8
01c0f780  41e00010                  movz r1,#0x1000
01c0f788  2116                      mov r1,r2
01c0f78c  0001                      tbb r0
01c0f78e  5116                      mov r1,r5
01c0f790  5d1e                      sub r5,r5,r1
01c0f792  c623                      add r6,#0x3
01c0f794  6016                      mov r0,r6
01c0f796  bfea0dee                  call 0x01c0d3b4
01c0f79a  0216                      mov r2,r0
01c0f79c  6015                      mov r0_r1,r6_r7
01c0f79e  bfea26ed                  call 0x01c0d1ee
01c0f7a2  4161                      lw r1,[r4 + 0x4]
01c0f7a4  0045                      jz r0,0x01c0f7b0
01c0f7a6  1016                      mov r0,r1
01c0f7a8  5116                      mov r1,r5
01c0f7aa  bfea3bf2                  call 0x01c0dc24
01c0f7ae  048b                      goto 0x01c0f7c6
01c0f7b0  4221                      mov r2,#0x1
01c0f7b2  1016                      mov r0,r1
01c0f7b4  5116                      mov r1,r5
01c0f7b6  bfeab4f1                  call 0x01c0db22
01c0f7ba  0485                      goto 0x01c0f7c6
01c0f7c0  5016                      mov r0,r5
01c0f7c2  80ea1c03                  call 0x01c0fdfe
01c0f7c6  4020                      mov r0,#0x0
01c0f7c8  5704                      pop {pc,0x7}
01c0f7ca  7404                      push {0x4}
01c0f7cc  0416                      mov r4,r0
01c0f7ce  4890                      add r0,r4,#0x10
01c0f7d0  c1ff70d4c001              mov r1,#0x1c0d470
01c0f7d6  4223                      mov r2,#0x3
01c0f7d8  bfea38e0                  call 0x01c0b84c
01c0f7de  0060                      lw r0,[r0 + 0x0]
01c0f7e0  4262                      lw r2,[r4 + 0x8]
01c0f7e2  4161                      lw r1,[r4 + 0x4]
01c0f7e4  4120                      mov r1,#0x0
01c0f7e6  4220                      mov r2,#0x0
01c0f7e8  281c                      add r0,r2,r1
01c0f7ec  0000                      nop
01c0f7ee  2016                      mov r0,r2
01c0f7f2  0000                      nop
01c0f7f4  1016                      mov r0,r1
01c0f7f6  5404                      pop {pc,0x4}
01c0f7fc  4020                      mov r0,#0x0
01c0f802  c2ff07483a00              mov r2,#0x3a4807
01c0f80e  0000                      nop
01c0f810  4021                      mov r0,#0x1
01c0f812  8000                      rts

;===== FUNC_01c0f814  (called 1x) =====
01c0f814  7604                      push {0x6}
01c0f816  0316                      mov r3,r0
01c0f81a  035c                      jz r3,0x01c0f854
01c0f81c  3360                      lw r3,[r3 + 0x0]
01c0f81e  035a                      jz r3,0x01c0f854
01c0f820  3843                      lb.z r0,[r3 + 0x3]
01c0f822  3c42                      lb.z r4,[r3 + 0x2]
01c0f828  3d41                      lb.z r5,[r3 + 0x1]
01c0f82a  3e40                      lb.z r6,[r3 + 0x0]
01c0f82e  2054                      jz r0,0x01c0f8d8
01c0f832  4048                      jz r0,0x01c0f744
01c0f836  3064                      lw r0,[r3 + 0x10]
01c0f838  9860                      sh r0,[r1 + 0x0]
01c0f83a  3843                      lb.z r0,[r3 + 0x3]
01c0f83c  3942                      lb.z r1,[r3 + 0x2]
01c0f842  3c41                      lb.z r4,[r3 + 0x1]
01c0f844  3b40                      lb.z r3,[r3 + 0x0]
01c0f848  2044                      jz r0,0x01c0f8d2
01c0f84c  4018                      add r0,r4
01c0f84e  b0b4                      lsr r0,r3,0x14
01c0f850  a860                      sh r0,[r2 + 0x0]
01c0f852  4020                      mov r0,#0x0
01c0f854  5604                      pop {pc,0x6}

;===== FUNC_01c0f856  (called 1x) =====
01c0f856  7c04                      push {0xc}
01c0f858  2815                      mov r8_r9,r2_r3
01c0f85a  1c16                      mov r12,r1
01c0f85c  0416                      mov r4,r0
01c0f85e  1453                      jz r4,0x01c0f8c6
01c0f864  4062                      lw r0,[r4 + 0x8]
01c0f866  2040                      jz r0,0x01c0f8e8
01c0f868  4520                      mov r5,#0x0
01c0f86a  c314                      clr r11
01c0f86c  4060                      lw r0,[r4 + 0x0]
01c0f86e  0f1d                      add r7,r0,r5
01c0f870  7843                      lb.z r0,[r7 + 0x3]
01c0f872  7942                      lb.z r1,[r7 + 0x2]
01c0f878  7a41                      lb.z r2,[r7 + 0x1]
01c0f87a  7b40                      lb.z r3,[r7 + 0x0]
01c0f882  4018                      add r0,r4
01c0f884  7884                      add r0,r7,#0x4
01c0f886  b1b4                      lsr r1,r3,0x14
01c0f888  bfea3bd8                  call 0x01c0a902
01c0f88c  7a43                      lb.z r2,[r7 + 0x3]
01c0f88e  7b42                      lb.z r3,[r7 + 0x2]
01c0f894  7e41                      lb.z r6,[r7 + 0x1]
01c0f89a  7940                      lb.z r1,[r7 + 0x0]
01c0f89e  2064                      lw r0,[r2 + 0x10]
01c0f8a2  4038                      mov r0,#0x18
01c0f8a4  1217                      uxtb r2,r1
01c0f8a8  0000                      nop
01c0f8aa  4be0fbff                  movz r11,#0xfffb
01c0f8b6  92b4                      lsr r2,r1,0x14
01c0f8ba  4062                      lw r0,[r4 + 0x8]
01c0f8bc  c224                      add r2,#0x4
01c0f8be  a517                      uxth r5,r2
01c0f8c2  d451                      jnz r4,0x01c0f826
01c0f8c4  0484                      goto 0x01c0f8ce
01c0f8c6  4ae0ffff                  movz r10,#0xffff
01c0f8ca  048e                      goto 0x01c0f8e8
01c0f8cc  4062                      lw r0,[r4 + 0x8]
01c0f8d0  0b50                      lb.z r3,[r0 + -0x10]
01c0f8d2  90b4                      lsr r0,r1,0x14
01c0f8d4  4ae0fcff                  movz r10,#0xfffc
01c0f8da  0690                      goto 0x01c0f0fc
01c0f8dc  0a84                      add r2,r0,#0x4
01c0f8de  7016                      mov r0,r7
01c0f8e0  8116                      mov r1,r8
01c0f8e2  bfeaa0ec                  call 0x01c0d226
01c0f8e6  ba16                      mov r10,r11
01c0f8e8  a016                      mov r0,r10
01c0f8ea  5c04                      pop {pc,0xc}
01c0f8ec  7404                      push {0x4}
01c0f8ee  e29f                      add sp,#-0x4
01c0f8f0  80ea6f03                  call 0x01c0ffd2
01c0f8f4  c0fff802c101              mov r0,#0x1c102f8
01c0f8fa  4121                      mov r1,#0x1
01c0f8fc  8940                      sb r1,[r0 + 0x0]
01c0f8fe  4020                      mov r0,#0x0
01c0f900  4420                      mov r4,#0x0
01c0f902  80ea5603                  call 0x01c0ffb2
01c0f906  682b                      mov r0,#0xab
01c0f908  80eab903                  call 0x01c1007e
01c0f90c  783f                      mov r0,#0xff
01c0f90e  80eab603                  call 0x01c1007e
01c0f912  783f                      mov r0,#0xff
01c0f914  80eab303                  call 0x01c1007e
01c0f918  783f                      mov r0,#0xff
01c0f91a  80eab003                  call 0x01c1007e
01c0f91e  80eab903                  call 0x01c10094
01c0f922  4021                      mov r0,#0x1
01c0f924  80ea4503                  call 0x01c0ffb2
01c0f928  8881                      add r0,sp,#0x1
01c0f92a  4120                      mov r1,#0x0
01c0f92c  4223                      mov r2,#0x3
01c0f92e  bfeadbec                  call 0x01c0d2e8
01c0f932  4020                      mov r0,#0x0
01c0f934  80ea3d03                  call 0x01c0ffb2
01c0f938  603f                      mov r0,#0x9f
01c0f93a  80eaa003                  call 0x01c1007e
01c0f93e  80eaa903                  call 0x01c10094
01c0f942  8981                      add r1,sp,#0x1
01c0f948  c421                      add r4,#0x1
01c0f94c  f807                      sb r0,[r7 --= 1]
01c0f94e  4021                      mov r0,#0x1
01c0f950  4421                      mov r4,#0x1
01c0f952  80ea2e03                  call 0x01c0ffb2
01c0f958  0100                      idle
01c0f962  00b0                      lsl r0,r0,0x10
01c0f968  2019                      or r0,r2
01c0f96a  c1ffcc15c101              mov r1,#0x1c115cc
01c0f972  f02f                      add r0,#-0x31
01c0f974  9060                      sw r0,[r1 + 0x0]
01c0f976  c0fff402c101              mov r0,#0x1c102f4
01c0f980  4216                      mov r2,r4
01c0f982  24a1                      lsl r4,r2,0x1
01c0f988  21b1                      lsl r1,r2,0x11
01c0f98a  8160                      sw r1,[r0 + 0x0]
01c0f98e  8017                      uxth r0,r0
01c0f992  4020                      mov r0,#0x0
01c0f994  80ea0d03                  call 0x01c0ffb2
01c0f998  6837                      mov r0,#0xb7
01c0f99a  80ea7003                  call 0x01c1007e
01c0f99e  4021                      mov r0,#0x1
01c0f9a0  4421                      mov r4,#0x1
01c0f9a2  80ea0603                  call 0x01c0ffb2
01c0f9a6  c0ffe002c101              mov r0,#0x1c102e0
01c0f9ac  8c40                      sb r4,[r0 + 0x0]
01c0f9ae  0482                      goto 0x01c0f9b4
01c0f9b4  0281                      add sp,#0x4
01c0f9b6  5404                      pop {pc,0x4}

;===== FUNC_01c0f9b8  (called 4x) =====
01c0f9b8  1004                      push rets
01c0f9ba  4020                      mov r0,#0x0
01c0f9bc  80eaf902                  call 0x01c0ffb2
01c0f9c0  4026                      mov r0,#0x6
01c0f9c2  80ea5c03                  call 0x01c1007e
01c0f9c6  4021                      mov r0,#0x1
01c0f9ca  c0eaf202                  goto 0x01c0ffb2

;===== FUNC_01c0f9ce  (called 3x) =====
01c0f9ce  7504                      push {0x5}
01c0f9d0  c5ffff8fc7c6              mov r5,#0xc6c78fff
01c0f9d6  4020                      mov r0,#0x0
01c0f9d8  80eaeb02                  call 0x01c0ffb2
01c0f9dc  4025                      mov r0,#0x5
01c0f9de  80ea4e03                  call 0x01c1007e
01c0f9e2  80ea5703                  call 0x01c10094
01c0f9e6  0416                      mov r4,r0
01c0f9e8  4021                      mov r0,#0x1
01c0f9ea  80eae202                  call 0x01c0ffb2
01c0f9f2  5824                      mov r0,#0x64
01c0f9f4  bfea19d8                  call 0x01c0aa2a
01c0f9f8  c521                      add r5,#0x1
01c0f9fa  f54d                      jnz r5,0x01c0f9d6
01c0f9fc  5504                      pop {pc,0x5}

;===== FUNC_01c0f9fe  (called 1x) =====
01c0f9fe  7504                      push {0x5}
01c0fa00  4020                      mov r0,#0x0
01c0fa02  80ead602                  call 0x01c0ffb2
01c0fa06  4025                      mov r0,#0x5
01c0fa08  80ea3903                  call 0x01c1007e
01c0fa0c  80ea4203                  call 0x01c10094
01c0fa10  0416                      mov r4,r0
01c0fa12  4021                      mov r0,#0x1
01c0fa14  80eacd02                  call 0x01c0ffb2
01c0fa18  4020                      mov r0,#0x0
01c0fa1a  80eaca02                  call 0x01c0ffb2
01c0fa1e  4835                      mov r0,#0x35
01c0fa20  80ea2d03                  call 0x01c1007e
01c0fa24  80ea3603                  call 0x01c10094
01c0fa28  0516                      mov r5,r0
01c0fa2a  4021                      mov r0,#0x1
01c0fa2c  80eac102                  call 0x01c0ffb2
01c0fa32  5004                      pop {pc,0x0}
01c0fa34  104b                      jz r0,0x01c0fa8c
01c0fa36  6180                      call 0x01c0f9b8
01c0fa38  4020                      mov r0,#0x0
01c0fa3a  80eaba02                  call 0x01c0ffb2
01c0fa3e  4025                      mov r0,#0x5
01c0fa40  80ea1d03                  call 0x01c1007e
01c0fa44  80ea2603                  call 0x01c10094
01c0fa48  0416                      mov r4,r0
01c0fa4a  4021                      mov r0,#0x1
01c0fa4c  80eab102                  call 0x01c0ffb2
01c0fa50  4020                      mov r0,#0x0
01c0fa52  80eaae02                  call 0x01c0ffb2
01c0fa56  4835                      mov r0,#0x35
01c0fa58  80ea1103                  call 0x01c1007e
01c0fa5c  80ea1a03                  call 0x01c10094
01c0fa60  0516                      mov r5,r0
01c0fa62  4021                      mov r0,#0x1
01c0fa64  80eaa502                  call 0x01c0ffb2
01c0fa68  4020                      mov r0,#0x0
01c0fa6a  80eaa202                  call 0x01c0ffb2
01c0fa6e  4021                      mov r0,#0x1
01c0fa70  80ea0503                  call 0x01c1007e
01c0fa76  7c40                      lb.z r4,[r7 + 0x0]
01c0fa78  80ea0103                  call 0x01c1007e
01c0fa7e  7c50                      lb.z r4,[r7 + -0x10]
01c0fa80  80eafd02                  call 0x01c1007e
01c0fa84  4021                      mov r0,#0x1
01c0fa86  80ea9402                  call 0x01c0ffb2
01c0fa8a  5181                      call 0x01c0f9ce
01c0fa8c  5504                      pop {pc,0x5}

;===== FUNC_01c0fa8e  (called 4x) =====
01c0fa8e  1004                      push rets
01c0fa90  c1ffe002c101              mov r1,#0x1c102e0
01c0fa98  1940                      lb.z r1,[r1 + 0x0]
01c0fa9c  0040                      jz r0,0x01c0fa9e
01c0fa9e  a0b8                      lsr r0,r2,0x18
01c0faa0  80eaed02                  call 0x01c1007e
01c0faa8  80eae902                  call 0x01c1007e
01c0fab0  80eae502                  call 0x01c1007e
01c0fab4  2017                      uxtb r0,r2
01c0fab8  c0eae102                  goto 0x01c1007e

;===== FUNC_01c0fabc  (called 9x) =====
01c0fabc  7804                      push {0x8}
01c0fabe  c4fff802c101              mov r4,#0x1c102f8
01c0fac6  4d40                      lb.z r5,[r4 + 0x0]
01c0fac8  2416                      mov r4,r2
01c0faca  1716                      mov r7,r1
01c0facc  0816                      mov r8,r0
01c0face  0553                      jz r5,0x01c0faf6
01c0fad0  4020                      mov r0,#0x0
01c0fad2  80ea6e02                  call 0x01c0ffb2
01c0fad6  4023                      mov r0,#0x3
01c0fad8  80ead102                  call 0x01c1007e
01c0fadc  7016                      mov r0,r7
01c0fade  6197                      call 0x01c0fa8e
01c0fae0  8016                      mov r0,r8
01c0fae2  4116                      mov r1,r4
01c0fae4  0643                      jz r6,0x01c0faec
01c0fae6  80eae302                  call 0x01c100b0
01c0faea  0482                      goto 0x01c0faf0
01c0faec  80ea0f03                  call 0x01c1010e
01c0faf0  4021                      mov r0,#0x1
01c0faf2  80ea5e02                  call 0x01c0ffb2
01c0faf6  4016                      mov r0,r4
01c0faf8  5804                      pop {pc,0x8}

;===== FUNC_01c0fafa  (called 1x) =====
01c0fafa  7804                      push {0x8}
01c0fafc  e290                      add sp,#-0x40
01c0fafe  2716                      mov r7,r2
01c0fb00  1616                      mov r6,r1
01c0fb02  0416                      mov r4,r0
01c0fb04  8880                      add r0,sp,#0x0
01c0fb06  c03f                      add r0,#0x1f
01c0fb10  f217                      uxth r2,r7
01c0fb12  4321                      mov r3,#0x1
01c0fb14  5016                      mov r0,r5
01c0fb16  6192                      call 0x01c0fabc
01c0fb18  4015                      mov r0_r1,r4_r5
01c0fb1a  7216                      mov r2,r7
01c0fb1c  bfea83eb                  call 0x01c0d226
01c0fb20  049b                      goto 0x01c0fb58
01c0fb24  1f70                      lh.z r7,[r1 + -0x20]
01c0fb2a  1f70                      lh.z r7,[r1 + -0x20]
01c0fb2e  7278                      lw r2,[r7 + -0x20]
01c0fb30  f217                      uxth r2,r7
01c0fb32  4321                      mov r3,#0x1
01c0fb34  4016                      mov r0,r4
01c0fb36  6182                      call 0x01c0fabc
01c0fb38  f11d                      add r1,r7,r6
01c0fb3c  4080                      rep 0xa,0x0
01c0fb3e  4321                      mov r3,#0x1
01c0fb40  5016                      mov r0,r5
01c0fb42  519c                      call 0x01c0fabc
01c0fb44  c81d                      add r0,r4,r7
01c0fb46  5116                      mov r1,r5
01c0fb48  8216                      mov r2,r8
01c0fb4a  bfea6ceb                  call 0x01c0d226
01c0fb4e  0484                      goto 0x01c0fb58
01c0fb50  f217                      uxth r2,r7
01c0fb52  4321                      mov r3,#0x1
01c0fb54  4016                      mov r0,r4
01c0fb56  5192                      call 0x01c0fabc
01c0fb58  0290                      add sp,#0x40
01c0fb5a  5804                      pop {pc,0x8}
01c0fb5c  7a04                      push {0xa}
01c0fb5e  e298                      add sp,#-0x20
01c0fb60  3816                      mov r8,r3
01c0fb62  2516                      mov r5,r2
01c0fb64  1616                      mov r6,r1
01c0fb66  0916                      mov r9,r0
01c0fb68  caffc003c101              mov r10,#0x1c103c0
01c0fb70  1f60                      lh.z r7,[r1 + 0x0]
01c0fb76  1f60                      lh.z r7,[r1 + 0x0]
01c0fb7a  04a0                      lsl r4,r0,0x0
01c0fb7c  e91f                      sub r1,r6,r7
01c0fb7e  981e                      sub r0,r1,r3
01c0fb80  80a2                      lsr r0,r0,0x2
01c0fb86  8c80                      add r4,sp,#0x0
01c0fb88  4a20                      mov r2,#0x20
01c0fb8a  4321                      mov r3,#0x1
01c0fb8c  4016                      mov r0,r4
01c0fb8e  4196                      call 0x01c0fabc
01c0fb90  c91d                      add r1,r4,r7
01c0fb94  2070                      lw r0,[r2 + -0x40]
01c0fb96  9016                      mov r0,r9
01c0fb98  4216                      mov r2,r4
01c0fb9a  bfea44eb                  call 0x01c0d226
01c0fb9e  5016                      mov r0,r5
01c0fba2  0005                      lw r0,[r0 ++= 4]
01c0fba4  4016                      mov r0,r4
01c0fba6  551e                      sub r5,r5,r0
01c0fba8  0481                      goto 0x01c0fbac
01c0fbaa  4420                      mov r4,#0x0
01c0fbac  0553                      jz r5,0x01c0fbd4
01c0fbb0  04a0                      lsl r4,r0,0x0
01c0fbb2  c11d                      add r1,r4,r6
01c0fbb8  82a2                      lsr r2,r0,0x2
01c0fbc2  5716                      mov r7,r5
01c0fbc6  2000                      csync
01c0fbc8  4f20                      mov r7,#0x20
01c0fbca  7216                      mov r2,r7
01c0fbcc  4196                      call 0x01c0fafa
01c0fbce  dd1f                      sub r5,r5,r7
01c0fbd0  7418                      add r4,r7
01c0fbd2  f54d                      jnz r5,0x01c0fbae
01c0fbd4  0288                      add sp,#0x20
01c0fbd6  5a04                      pop {pc,0xa}

;===== FUNC_01c0fbd8  (called 1x) =====
01c0fbd8  7404                      push {0x4}
01c0fbda  4421                      mov r4,#0x1
01c0fbde  0000                      nop
01c0fbe0  3416                      mov r4,r3
01c0fbe2  43a1                      lsl r3,r4,0x1
01c0fbe4  c4ffc003c101              mov r4,#0x1c103c0
01c0fbea  c36f                      sw r3,[r4 + 0x3c]
01c0fbec  3404                      pop {rets,0x4}
01c0fbee  c785                      goto 0x01c0fafa

;===== FUNC_01c0fbf0  (called 16x) =====
01c0fbf0  7904                      push {0x9}
01c0fbf2  e290                      add sp,#-0x40
01c0fbf4  2716                      mov r7,r2
01c0fbf6  1616                      mov r6,r1
01c0fbf8  0416                      mov r4,r0
01c0fbfa  8880                      add r0,sp,#0x0
01c0fbfc  c03f                      add r0,#0x1f
01c0fc06  4320                      mov r3,#0x0
01c0fc08  5016                      mov r0,r5
01c0fc0a  bfea57ff                  call 0x01c0fabc
01c0fc0e  0616                      mov r6,r0
01c0fc10  4015                      mov r0_r1,r4_r5
01c0fc12  7216                      mov r2,r7
01c0fc14  bfea07eb                  call 0x01c0d226
01c0fc18  1481                      goto 0x01c0fc5c
01c0fc1c  1f70                      lh.z r7,[r1 + -0x20]
01c0fc22  1f70                      lh.z r7,[r1 + -0x20]
01c0fc26  7278                      lw r2,[r7 + -0x20]
01c0fc28  f217                      uxth r2,r7
01c0fc2a  4320                      mov r3,#0x0
01c0fc2c  4016                      mov r0,r4
01c0fc2e  bfea45ff                  call 0x01c0fabc
01c0fc32  0916                      mov r9,r0
01c0fc34  f11d                      add r1,r7,r6
01c0fc38  4080                      rep 0xa,0x0
01c0fc3a  4320                      mov r3,#0x0
01c0fc3c  5016                      mov r0,r5
01c0fc3e  bfea3dff                  call 0x01c0fabc
01c0fc42  0616                      mov r6,r0
01c0fc44  c81d                      add r0,r4,r7
01c0fc46  5116                      mov r1,r5
01c0fc48  8216                      mov r2,r8
01c0fc4a  bfeaecea                  call 0x01c0d226
01c0fc4e  9618                      add r6,r9
01c0fc50  0485                      goto 0x01c0fc5c
01c0fc52  4320                      mov r3,#0x0
01c0fc54  4016                      mov r0,r4
01c0fc56  bfea31ff                  call 0x01c0fabc
01c0fc5a  0616                      mov r6,r0
01c0fc5c  6016                      mov r0,r6
01c0fc5e  0290                      add sp,#0x40
01c0fc60  5904                      pop {pc,0x9}

;===== FUNC_01c0fc62  (called 1x) =====
01c0fc62  c0fff402c101              mov r0,#0x1c102f4
01c0fc68  0060                      lw r0,[r0 + 0x0]
01c0fc6a  8000                      rts

;===== FUNC_01c0fc6c  (called 11x) =====
01c0fc6c  7404                      push {0x4}
01c0fc6e  c1ffcc15c101              mov r1,#0x1c115cc
01c0fc76  1160                      lw r1,[r1 + 0x0]
01c0fc78  c2ffedcda1ff              mov r2,#0xffa1cded
01c0fc7e  2118                      add r1,r2
01c0fc84  4020                      mov r0,#0x0
01c0fc86  80ea9401                  call 0x01c0ffb2
01c0fc8a  4836                      mov r0,#0x36
01c0fc8c  80eaf701                  call 0x01c1007e
01c0fc90  4021                      mov r0,#0x1
01c0fc92  80ea8e01                  call 0x01c0ffb2
01c0fc96  4034                      mov r0,#0x14
01c0fc98  bfeac7d6                  call 0x01c0aa2a
01c0fc9c  4020                      mov r0,#0x0
01c0fc9e  80ea8801                  call 0x01c0ffb2
01c0fca2  7037                      mov r0,#0xd7
01c0fca4  80eaeb01                  call 0x01c1007e
01c0fca8  4021                      mov r0,#0x1
01c0fcaa  80ea8201                  call 0x01c0ffb2
01c0fcae  4034                      mov r0,#0x14
01c0fcb0  bfeabbd6                  call 0x01c0aa2a
01c0fcb4  4020                      mov r0,#0x0
01c0fcb6  80ea7c01                  call 0x01c0ffb2
01c0fcba  6820                      mov r0,#0xa0
01c0fcbc  80eadf01                  call 0x01c1007e
01c0fcc0  4021                      mov r0,#0x1
01c0fcc2  80ea7601                  call 0x01c0ffb2
01c0fcc6  4034                      mov r0,#0x14
01c0fcc8  bfeaafd6                  call 0x01c0aa2a
01c0fccc  4020                      mov r0,#0x0
01c0fcce  80ea7001                  call 0x01c0ffb2
01c0fcd2  402f                      mov r0,#0xf
01c0fcd4  80ead301                  call 0x01c1007e
01c0fcd8  4020                      mov r0,#0x0
01c0fcda  80ead001                  call 0x01c1007e
01c0fcde  4020                      mov r0,#0x0
01c0fce0  80eacd01                  call 0x01c1007e
01c0fce4  4022                      mov r0,#0x2
01c0fce6  80eaca01                  call 0x01c1007e
01c0fcee  4020                      mov r0,#0x0
01c0fcf0  5830                      mov r0,#0x70
01c0fcf2  80eac401                  call 0x01c1007e
01c0fcf6  4021                      mov r0,#0x1
01c0fcf8  80ea5b01                  call 0x01c0ffb2
01c0fcfc  4034                      mov r0,#0x14
01c0fcfe  bfea94d6                  call 0x01c0aa2a
01c0fd02  4020                      mov r0,#0x0
01c0fd04  80ea5501                  call 0x01c0ffb2
01c0fd08  4038                      mov r0,#0x18
01c0fd0a  80eab801                  call 0x01c1007e
01c0fd0e  4021                      mov r0,#0x1
01c0fd10  80ea4f01                  call 0x01c0ffb2
01c0fd14  4034                      mov r0,#0x14
01c0fd16  bfea88d6                  call 0x01c0aa2a
01c0fd1a  5404                      pop {pc,0x4}

;===== FUNC_01c0fd1c  (called 2x) =====
01c0fd1c  7c04                      push {0xc}
01c0fd1e  e29c                      add sp,#-0x10
01c0fd20  1b16                      mov r11,r1
01c0fd22  0816                      mov r8,r0
01c0fd24  2145                      jz r1,0x01c0fdb0
01c0fd26  8414                      clr r4_r5
01c0fd28  49e00500                  movz r9,#0x5
01c0fd2c  4ae0ff0f                  movz r10,#0xfff
01c0fd32  b274                      sw r2,[r3 + -0x30]
01c0fd36  4068                      lw r0,[r4 + 0x20]
01c0fd38  bfeacbd7                  call 0x01c0acd2
01c0fd3e  807b                      sw r0,[r0 + -0x14]
01c0fd42  e017                      uxth r0,r6
01c0fd44  8044                      jnz r0,0x01c0fd4e
01c0fd46  7738                      mov r7,#0xd8
01c0fd4c  0491                      goto 0x01c0fd70
01c0fd50  807d                      sw r0,[r0 + -0xc]
01c0fd58  8044                      jnz r0,0x01c0fd62
01c0fd5a  4f20                      mov r7,#0x20
01c0fd5c  4ce00010                  movz r12,#0x1000
01c0fd60  0487                      goto 0x01c0fd70
01c0fd66  6017                      uxtb r0,r6
01c0fd68  9043                      jnz r0,0x01c0fdb0
01c0fd6a  6721                      mov r7,#0x81
01c0fd6c  4ce00001                  movz r12,#0x100
01c0fd70  bfea22fe                  call 0x01c0f9b8
01c0fd74  4020                      mov r0,#0x0
01c0fd76  80ea1c01                  call 0x01c0ffb2
01c0fd7a  7016                      mov r0,r7
01c0fd7c  80ea7f01                  call 0x01c1007e
01c0fd80  6016                      mov r0,r6
01c0fd82  bfea84fe                  call 0x01c0fa8e
01c0fd86  4021                      mov r0,#0x1
01c0fd88  80ea1301                  call 0x01c0ffb2
01c0fd8c  5017                      uxtb r0,r5
01c0fd90  0019                      or r0,r0
01c0fd96  0f1e                      sub r7,r0,r1
01c0fd98  bfea19fe                  call 0x01c0f9ce
01c0fd9c  8745                      jnz r7,0x01c0fda8
01c0fd9e  e1ac                      lsr r1,r6,0xc
01c0fda0  8880                      add r0,sp,#0x0
01c0fda2  4230                      mov r2,#0x10
01c0fda4  bfea93ee                  call 0x01c0dace
01c0fda8  c418                      add r4,r12
01c0fdaa  c521                      add r5,#0x1
01c0fdae  c041                      jnz r0,0x01c0fcb2
01c0fdb0  0284                      add sp,#0x10
01c0fdb2  5c04                      pop {pc,0xc}

;===== FUNC_01c0fdb4  (called 11x) =====
01c0fdb4  c0ffcc15c101              mov r0,#0x1c115cc
01c0fdba  0060                      lw r0,[r0 + 0x0]
01c0fdbc  c1ffedcda1ff              mov r1,#0xffa1cded
01c0fdc2  0118                      add r1,r0
01c0fdc4  4021                      mov r0,#0x1
01c0fdc8  0200                      bkpt
01c0fdca  4020                      mov r0,#0x0
01c0fdcc  8000                      rts

;===== FUNC_01c0fdce  (called 3x) =====
01c0fdce  7604                      push {0x6}
01c0fdd0  2416                      mov r4,r2
01c0fdd2  1516                      mov r5,r1
01c0fdd4  0616                      mov r6,r0
01c0fdd6  bfeaeffd                  call 0x01c0f9b8
01c0fdda  4020                      mov r0,#0x0
01c0fddc  80eae900                  call 0x01c0ffb2
01c0fde0  4022                      mov r0,#0x2
01c0fde2  80ea4c01                  call 0x01c1007e
01c0fde6  5016                      mov r0,r5
01c0fde8  bfea51fe                  call 0x01c0fa8e
01c0fdec  c117                      uxth r1,r4
01c0fdee  6016                      mov r0,r6
01c0fdf0  80ea9b01                  call 0x01c1012a
01c0fdf4  4021                      mov r0,#0x1
01c0fdf6  80eadc00                  call 0x01c0ffb2
01c0fdfa  3604                      pop {rets,0x6}
01c0fdfc  f688                      goto 0x01c0f9ce

;===== FUNC_01c0fdfe  (called 11x) =====
01c0fdfe  7804                      push {0x8}
01c0fe00  1516                      mov r5,r1
01c0fe04  2050                      jz r0,0x01c0fea6
01c0fe08  808f                      rep 0x12,0xf
01c0fe0a  2416                      mov r4,r2
01c0fe0c  0616                      mov r6,r0
01c0fe10  2a70                      lh.z r2,[r2 + -0x20]
01c0fe12  7216                      mov r2,r7
01c0fe14  619c                      call 0x01c0fdce
01c0fe16  e81d                      add r0,r6,r7
01c0fe18  791d                      add r1,r7,r5
01c0fe1a  cf1f                      sub r7,r4,r7
01c0fe1c  42e00001                  movz r2,#0x100
01c0fe22  0001                      tbb r0
01c0fe24  7216                      mov r2,r7
01c0fe26  6193                      call 0x01c0fdce
01c0fe2a  1c02                      iflush [r12]
01c0fe2e  0052                      jz r0,0x01c0fe54
01c0fe32  0258                      jz r2,0x01c0fe64
01c0fe36  008f                      rep 0x2,0xf
01c0fe38  0618                      add r6,r0
01c0fe42  0416                      mov r4,r0
01c0fe44  42e00001                  movz r2,#0x100
01c0fe4a  0001                      tbb r0
01c0fe4c  4216                      mov r2,r4
01c0fe4e  6016                      mov r0,r6
01c0fe50  5116                      mov r1,r5
01c0fe52  519d                      call 0x01c0fdce
01c0fe56  004f                      jz r0,0x01c0fe76
01c0fe5a  0051                      jz r0,0x01c0fe7e
01c0fe5e  0061                      lw r0,[r0 + 0x4]
01c0fe64  5804                      pop {pc,0x8}
01c0fe66  3804                      pop {rets,0x8}
01c0fe68  d792                      goto 0x01c0fdce

;===== FUNC_01c0fe6a  (called 11x) =====
01c0fe6a  7704                      push {0x7}
01c0fe6c  e29c                      add sp,#-0x10
01c0fe6e  c2ffec02c101              mov r2,#0x1c102ec
01c0fe76  2a40                      lb.z r2,[r2 + 0x0]
01c0fe78  2248                      jz r2,0x01c0ff0a
01c0fe7a  c1ffcc15c101              mov r1,#0x1c115cc
01c0fe80  1160                      lw r1,[r1 + 0x0]
01c0fe82  c2ffedcda1ff              mov r2,#0xffa1cded
01c0fe88  2118                      add r1,r2
01c0fe8c  3e02                      flushinv [r14]
01c0fe8e  c0ffed02c101              mov r0,#0x1c102ed
01c0fe94  0940                      lb.z r1,[r0 + 0x0]
01c0fe96  b14e                      jnz r1,0x01c0ff74
01c0fe98  4121                      mov r1,#0x1
01c0fe9a  8940                      sb r1,[r0 + 0x0]
01c0fe9c  888c                      add r0,sp,#0xc
01c0fe9e  8988                      add r1,sp,#0x8
01c0fea0  bfea20ee                  call 0x01c0dae4
01c0fea4  8884                      add r0,sp,#0x4
01c0fea6  8980                      add r1,sp,#0x0
01c0fea8  bfea2bee                  call 0x01c0db02
01c0feac  4020                      mov r0,#0x0
01c0feae  bfeaddfe                  call 0x01c0fc6c
01c0feb8  8245                      jnz r2,0x01c0fec4
01c0febe  804d                      jnz r0,0x01c0feda
01c0fec0  0118                      add r1,r0
01c0fec2  4020                      mov r0,#0x0
01c0fec4  bfea2aff                  call 0x01c0fd1c
01c0fec8  c0ffe402c101              mov r0,#0x1c102e4
01c0fece  0460                      lw r4,[r0 + 0x0]
01c0fed0  c0fff402c101              mov r0,#0x1c102f4
01c0fed6  0660                      lw r6,[r0 + 0x0]
01c0fedc  4021                      mov r0,#0x1
01c0fede  bfeac5fe                  call 0x01c0fc6c
01c0fee2  781d                      add r0,r7,r5
01c0fee6  0060                      lw r0,[r0 + 0x0]
01c0feea  0000                      nop
01c0feec  4116                      mov r1,r4
01c0feee  191f                      sub r1,r1,r5
01c0fef0  bfea14ff                  call 0x01c0fd1c
01c0fef4  c0ffe802c101              mov r0,#0x1c102e8
01c0fefa  0060                      lw r0,[r0 + 0x0]
01c0fefc  105b                      jz r0,0x01c0ff74
01c0fefe  41e00010                  movz r1,#0x1000
01c0ff02  4221                      mov r2,#0x1
01c0ff04  bfea0dee                  call 0x01c0db22
01c0ff08  1495                      goto 0x01c0ff74
01c0ff0c  0d06                      lh.z r5,[r0 --= 2]
01c0ff12  7527                      mov r5,#0xc7
01c0ff16  1c02                      iflush [r12]
01c0ff18  c017                      uxth r0,r4
01c0ff1a  7538                      mov r5,#0xd8
01c0ff1c  0059                      jz r0,0x01c0ff50
01c0ff20  0000                      nop
01c0ff24  0003                      rep 0x2,r0
01c0ff26  0492                      goto 0x01c0ff4c
01c0ff28  6521                      mov r5,#0x81
01c0ff2c  ff40                      sb r7,[r7 + 0x0]
01c0ff32  0000                      nop
01c0ff36  0003                      rep 0x2,r0
01c0ff38  0489                      goto 0x01c0ff4c
01c0ff3a  40e0ff0f                  movz r0,#0xfff
01c0ff3e  4d20                      mov r5,#0x20
01c0ff46  0000                      nop
01c0ff4a  0003                      rep 0x2,r0
01c0ff4c  bfea0bd6                  call 0x01c0ab66
01c0ff50  bfea32fd                  call 0x01c0f9b8
01c0ff54  4020                      mov r0,#0x0
01c0ff56  80ea2c00                  call 0x01c0ffb2
01c0ff5a  5016                      mov r0,r5
01c0ff5c  80ea8f00                  call 0x01c1007e
01c0ff62  c740                      jnz r7,0x01c0fe64
01c0ff64  4016                      mov r0,r4
01c0ff66  bfea92fd                  call 0x01c0fa8e
01c0ff6a  4021                      mov r0,#0x1
01c0ff6c  80ea2100                  call 0x01c0ffb2
01c0ff70  bfea2dfd                  call 0x01c0f9ce
01c0ff74  0284                      add sp,#0x10
01c0ff76  5704                      pop {pc,0x7}

;===== FUNC_01c0ff78  (called 1x) =====
01c0ff78  c1ffe402c101              mov r1,#0x1c102e4
01c0ff7e  9060                      sw r0,[r1 + 0x0]
01c0ff80  8000                      rts

;===== FUNC_01c0ff82  (called 1x) =====
01c0ff82  c1ffe802c101              mov r1,#0x1c102e8
01c0ff88  9060                      sw r0,[r1 + 0x0]
01c0ff8a  8000                      rts

;===== FUNC_01c0ff8c  (called 3x) =====
01c0ff8c  c1ffec02c101              mov r1,#0x1c102ec
01c0ff92  9840                      sb r0,[r1 + 0x0]
01c0ff94  8000                      rts

;===== FUNC_01c0ff96  (called 1x) =====
01c0ff96  1004                      push rets
01c0ff98  402f                      mov r0,#0xf
01c0ff9a  4130                      mov r1,#0x10
01c0ff9c  bfea74d5                  call 0x01c0aa88
01c0ffa0  402f                      mov r0,#0xf
01c0ffa2  4122                      mov r1,#0x2
01c0ffa4  bfea70d5                  call 0x01c0aa88
01c0ffa8  402f                      mov r0,#0xf
01c0ffaa  4128                      mov r1,#0x8
01c0ffae  ffea6bd5                  goto 0x01c0aa88

;===== FUNC_01c0ffb2  (called 38x) =====
01c0ffb2  c1ffc0000500              mov r1,#0x500c0
01c0ffbc  1260                      lw r2,[r1 + 0x0]
01c0ffc2  3220                      bitset r2,0x0
01c0ffc6  0000                      nop
01c0ffc8  3216                      mov r2,r3
01c0ffca  9260                      sw r2,[r1 + 0x0]
01c0ffcc  402a                      mov r0,#0xa
01c0ffce  c0eabf00                  goto 0x01c10150

;===== FUNC_01c0ffd2  (called 1x) =====
01c0ffd2  7404                      push {0x4}
01c0ffd4  4434                      mov r4,#0x14
01c0ffd6  40e0e803                  movz r0,#0x3e8
01c0ffda  bfea26d5                  call 0x01c0aa2a
01c0ffe2  c0ff00020400              mov r0,#0x40200
01c0ffea  0000                      nop
01c0ffee  8e4b                      sb r6,[r0 + 0xb]
01c0fff2  2840                      lb.z r0,[r2 + 0x0]
01c0fff6  0240                      jz r2,0x01c0fff8
01c0fff8  c0ff1c100500              mov r0,#0x5101c
01c10000  0200                      bkpt
01c10004  2000                      csync
01c10006  6187                      call 0x01c0ff96
01c10008  c0ffc0000500              mov r0,#0x500c0
01c10010  0100                      idle
01c10014  0100                      idle
01c10018  0100                      idle
01c1001c  0100                      idle
01c10034  2000                      csync
01c10038  2000                      csync
01c1003c  2000                      csync
01c10040  2000                      csync
01c10044  0200                      bkpt
01c10048  0200                      bkpt
01c1004c  0200                      bkpt
01c10070  804c                      jnz r0,0x01c1008a
01c10074  0140                      jz r1,0x01c10076
01c10076  4021                      mov r0,#0x1
01c10078  419c                      call 0x01c0ffb2
01c1007a  4060                      lw r0,[r4 + 0x0]
01c1007c  5404                      pop {pc,0x4}
01c10080  8e1b                      mul r14,r8
01c10084  801d                      add r0,r0,r6
01c10086  9062                      sw r0,[r1 + 0x8]
01c10088  1060                      lw r0,[r1 + 0x0]
01c1008c  fd79                      sh r5,[r7 + -0xe]
01c10090  801c                      add r0,r0,r2
01c10092  8000                      rts
01c1009e  ff00                      sti r15
01c100a0  0160                      lw r1,[r0 + 0x0]
01c100a4  fd79                      sh r5,[r7 + -0xe]
01c100aa  0062                      lw r0,[r0 + 0x8]
01c100ac  0017                      uxtb r0,r0
01c100ae  8000                      rts

;===== FUNC_01c100b0  (called 1x) =====
01c100b0  7704                      push {0x7}
01c100bc  402e                      mov r0,#0xe
01c100be  c4ffc003c101              mov r4,#0x1c103c0
01c100c8  476f                      lw r7,[r4 + 0x3c]
01c100ce  4520                      mov r5,#0x0
01c100d0  4622                      mov r6,#0x2
01c100d4  0302                      pfetch [r3]
01c100d6  0488                      goto 0x01c100e8
01c100da  4054                      jz r0,0x01c10004
01c100dc  b562                      sw r5,[r3 + 0x8]
01c100e2  3560                      lw r5,[r3 + 0x0]
01c100e6  8050                      jnz r0,0x01c10108
01c100e8  b660                      sw r6,[r3 + 0x0]
01c100ec  4c43                      lb.z r4,[r4 + 0x3]
01c100f0  0240                      jz r2,0x01c100f2
01c100f8  0040                      jz r0,0x01c100fa
01c100fa  a063                      sw r0,[r2 + 0xc]
01c100fc  a164                      sw r1,[r2 + 0x10]
01c100fe  2060                      lw r0,[r2 + 0x0]
01c10102  fd79                      sh r5,[r7 + -0xe]
01c1010c  5704                      pop {pc,0x7}
01c10118  402e                      mov r0,#0xe
01c1011a  a063                      sw r0,[r2 + 0xc]
01c1011c  a164                      sw r1,[r2 + 0x10]
01c1011e  2060                      lw r0,[r2 + 0x0]
01c10122  fd79                      sh r5,[r7 + -0xe]
01c10128  8000                      rts
01c10134  402e                      mov r0,#0xe
01c10136  a063                      sw r0,[r2 + 0xc]
01c10138  a164                      sw r1,[r2 + 0x10]
01c1013a  2060                      lw r0,[r2 + 0x0]
01c1013e  fd79                      sh r5,[r7 + -0xe]
01c10144  8000                      rts

;===== FUNC_01c10146  (called 1x) =====
01c10146  c0ff1c03c101              mov r0,#0x1c1031c
01c1014c  0061                      lw r0,[r0 + 0x4]
01c1014e  8000                      rts

;===== FUNC_01c10150  (called 1x) =====
01c10150  e29f                      add sp,#-0x4
01c10154  0481                      goto 0x01c10158
01c10156  0000                      nop
01c10160  f05a                      jnz r0,0x01c10156
01c10162  0281                      add sp,#0x4
01c10164  8000                      rts

;===== FUNC_01c10166  (called 1x) =====
01c10166  2000                      csync
01c10168  6000                      cli
01c1016a  c0fffc02c101              mov r0,#0x1c102fc
01c10172  0100                      idle
01c10174  2000                      csync
01c10176  8000                      rts

;===== FUNC_01c10178  (called 1x) =====
01c10178  2000                      csync
01c1017a  c0fffc02c101              mov r0,#0x1c102fc
01c10180  0160                      lw r1,[r0 + 0x0]
01c10182  f93f                      add r1,#-0x1
01c10184  8160                      sw r1,[r0 + 0x0]
01c10188  0000                      nop
01c1018a  6100                      sti
01c1018c  2000                      csync
01c1018e  8000                      rts

;===== FUNC_01c10190  (called 1x) =====
01c10190  6000                      cli
01c10192  4020                      mov r0,#0x0
01c10194  c1ff00f1ee01              mov r1,#0x1eef100
01c1019e  4320                      mov r3,#0x0
01c101a2  1b03                      rep 0x4,r11
01c101a6  2b03                      rep 0x6,r11
01c101a8  c321                      add r3,#0x1
01c101ac  f941                      sb r1,[r7 + 0x1]
01c101ae  4021                      mov r0,#0x1
01c101b0  c1ff00fec701              mov r1,#0x1c7fe00
01c101b6  4220                      mov r2,#0x0
01c101bc  c021                      add r0,#0x1
01c101c0  fb41                      sb r3,[r7 + 0x1]
01c101c2  4020                      mov r0,#0x0
01c101c4  c1ffa8f1ee01              mov r1,#0x1eef1a8
01c101ca  9060                      sw r0,[r1 + 0x0]
01c101d0  6100                      sti
01c101d2  8000                      rts
01c101d4  7504                      push {0x5}
01c101d6  c3ff00fec701              mov r3,#0x1c7fe00
01c101de  3b20                      bittgl r3,0x0
01c101e0  2000                      csync
01c101e2  6000                      cli
01c101e4  c2fffc02c101              mov r2,#0x1c102fc
01c101ee  03a2                      lsl r3,r0,0x2
01c101f0  80a3                      lsr r0,r0,0x3
01c101f2  c4ff00f1ee01              mov r4,#0x1eef100
01c101fa  1401                      tbh r4
01c101fc  2000                      csync
01c10202  4060                      lw r0,[r4 + 0x0]
01c10204  452f                      mov r5,#0xf
01c10206  351a                      lsl r5,r3
01c1020a  0305                      lw r3,[r0 ++= 4]
01c1020c  11a1                      lsl r1,r1,0x1
01c10212  3120                      bitset r1,0x0
01c10214  311a                      lsl r1,r3
01c10216  1019                      or r0,r1
01c10218  c060                      sw r0,[r4 + 0x0]
01c1021a  2000                      csync
01c1021c  2060                      lw r0,[r2 + 0x0]
01c1021e  f83f                      add r0,#-0x1
01c10220  a060                      sw r0,[r2 + 0x0]
01c10224  0000                      nop
01c10226  6100                      sti
01c10228  2000                      csync
01c1022a  5504                      pop {pc,0x5}

;===== FUNC_01c1022c  (called 1x) =====
01c1022c  1316                      mov r3,r1
01c1022e  0017                      uxtb r0,r0
01c10230  2117                      uxtb r1,r2
01c10232  3216                      mov r2,r3
01c10234  e78f                      goto 0x01c101d4

;===== FUNC_01c10236  (called 1x) =====
01c10236  c1ff00f1ee01              mov r1,#0x1eef100
01c1023c  4220                      mov r2,#0x0
01c1024a  8000                      rts

;===== FUNC_01c1024c  (called 1x) =====
01c1024c  7404                      push {0x4}
01c1024e  6034                      mov r0,#0x94
01c10250  bfea89d3                  call 0x01c0a966
01c10254  0416                      mov r4,r0
01c1025c  0140                      jz r1,0x01c1025e
01c1025e  6034                      mov r0,#0x94
01c10260  bfea22d3                  call 0x01c0a8a8
01c10264  6034                      mov r0,#0x94
01c10266  4116                      mov r1,r4
01c10268  bfea1ed3                  call 0x01c0a8a8
01c1026c  5404                      pop {pc,0x4}
01c1026e  0000                      nop
01c10270  0000                      nop
01c10272  0000                      nop
01c10274  0000                      nop
01c10276  0000                      nop
01c10278  0000                      nop
01c1027a  0000                      nop
01c10280  0100                      idle
01c10282  0000                      nop
01c10284  0000                      nop
01c10286  0000                      nop
01c10288  0000                      nop
01c1028a  0000                      nop
01c10292  0000                      nop
01c1029c  0000                      nop
01c1029e  0000                      nop
01c102a0  0000                      nop
01c102a2  0000                      nop
01c102a4  0000                      nop
01c102a6  0000                      nop
01c102a8  0000                      nop
01c102aa  0000                      nop
01c102ac  0000                      nop
01c102ae  0000                      nop
01c102b0  0000                      nop
01c102b2  0000                      nop
01c102b4  0000                      nop
01c102b6  0000                      nop
01c102b8  0000                      nop
01c102ba  0000                      nop
01c102bc  0000                      nop
01c102be  0000                      nop
01c102c2  2e75                      lh.z r6,[r2 + -0x16]
01c102c4  6677                      lw r6,[r6 + -0x24]
01c102c6  0000                      nop
01c102c8  0000                      nop
01c102ca  0000                      nop
01c102cc  0000                      nop
01c102ce  0000                      nop
01c102d0  0000                      nop
01c102d2  0000                      nop
01c102d4  0000                      nop
01c102d6  0000                      nop
01c102d8  0000                      nop
01c102da  0000                      nop
01c102dc  0000                      nop
01c102de  0000                      nop
01c102e0  0000                      nop
01c102e2  0000                      nop
01c102e4  0000                      nop
01c102e6  0000                      nop
01c102e8  0000                      nop
01c102ea  0000                      nop
01c102ec  0100                      idle
01c102ee  0000                      nop
01c102f0  0000                      nop
01c102f2  0000                      nop
01c102f4  0000                      nop
01c102f6  0000                      nop
01c102f8  0000                      nop
01c102fa  0000                      nop
01c102fc  0000                      nop
01c102fe  0000                      nop
01c10300  1201                      tbh r2
01c10302  0002                      pfetch [r0]
01c10304  0000                      nop
01c10306  0040                      jz r0,0x01c10308
01c10308  4a4d                      lb.z r2,[r4 + 0xd]
01c1030a  5541                      jz r5,0x01c1024e
01c1030c  0001                      tbb r0
01c1030e  0102                      pfetch [r1]
01c10310  0001                      tbb r0
01c10314  f022                      add r0,#-0x3e
01c10316  2407                      lb.z r4,[r2 ++= 2]
01c10318  357d                      lw r5,[r3 + -0xc]
01c1031a  f700                      sti r7
