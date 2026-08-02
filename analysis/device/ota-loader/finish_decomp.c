/* address: 01c0bb62 */

/* WARNING: Control flow encountered bad instruction data */

void ota_finish_gate(void)

{
  int iVar1;
  BADSPACEBASE *in_sp;
  undefined1 auStack_4 [4];
  
  iVar1 = func_0x01c0dfe2(auStack_4);
  if (iVar1 == 0) {
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  }
  iVar1 = func_0x01c0f7f8();
  if (iVar1 != 0) {
    func_0x01c0f2e4();
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  }
                    /* WARNING: Bad instruction - Truncating control flow here */
  halt_baddata();
}


/* address: 01c0bc10 */

/* WARNING: Control flow encountered bad instruction data */

void updata_mode(void)

{
  func_0x01c0ad06();
  func_0x01c1022c(5,0x1c0d1a8,1);
                    /* WARNING: Bad instruction - Truncating control flow here */
  halt_baddata();
}


/* address: 01c0bd7a */

/* WARNING: Control flow encountered bad instruction data */

void chip_restart(void)

{
  int iVar1;
  undefined1 *puVar2;
  
  iVar1 = func_0x01c0bd1c();
  if (iVar1 == 0) {
    puVar2 = (undefined1 *)0x1c103c0;
    if ((iRam01c103cc == 0) && (iVar1 = func_0x01c0f342(), iVar1 != 0)) {
      func_0x01c0bd62();
      CoreSynchronize();
      DisableInterrupts();
                    /* WARNING: Bad instruction - Truncating control flow here */
      halt_baddata();
    }
    func_0x01c0aaea(*puVar2);
    func_0x01c0bd76();
  }
  return;
}


/* address: 01c0bdba */

/* WARNING: Control flow encountered bad instruction data */

undefined4 updata_check_updata_result(void)

{
  int iVar1;
  
  iVar1 = func_0x01c0a902(0x1c7fd8a,0x4e);
  if (iVar1 != 0) {
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  }
  return 0;
}


/* address: 01c0bddc */

/* WARNING: Control flow encountered bad instruction data */

void uboot_main(void)

{
  func_0x01c0a8a8(0x94,0);
                    /* WARNING: Bad instruction - Truncating control flow here */
  halt_baddata();
}


/* address: 01c0dfe2 */

/* WARNING: Control flow encountered bad instruction data */

void inspect_update_headers(void)

{
                    /* WARNING: Bad instruction - Truncating control flow here */
  halt_baddata();
}


/* address: 01c0f7f8 */

/* WARNING: Control flow encountered bad instruction data */

void is_fatal_update_error(void)

{
                    /* WARNING: Bad instruction - Truncating control flow here */
  halt_baddata();
}


/* address: 01c0f2e4 */

/* WARNING: Control flow encountered bad instruction data */

void handle_fatal_update_error(void)

{
                    /* WARNING: Bad instruction - Truncating control flow here */
  halt_baddata();
}


/* address: 01c0e60e */

/* WARNING: Control flow encountered bad instruction data */

void run_partition_callbacks(void)

{
                    /* WARNING: Bad instruction - Truncating control flow here */
  halt_baddata();
}


/* address: 01c0e41c */

/* WARNING: Control flow encountered bad instruction data */

void validate_required_file_heads(void)

{
  func_0x01c0b57e(uRam01c11304);
  func_0x01c0b840(0,0x1c115d0,0x200);
                    /* WARNING: Bad instruction - Truncating control flow here */
  halt_baddata();
}


/* address: 01c0e714 */

/* WARNING: Control flow encountered bad instruction data */

void verify_and_plan_update(void)

{
                    /* WARNING: Bad instruction - Truncating control flow here */
  halt_baddata();
}


/* address: 01c0ed36 */

/* WARNING: Control flow encountered bad instruction data */

void prepare_flash_regions(void)

{
                    /* WARNING: Bad instruction - Truncating control flow here */
  halt_baddata();
}


/* address: 01c0efc0 */

/* WARNING: Control flow encountered bad instruction data */

void write_update_regions(void)

{
  func_0x01c0fc6c(1);
                    /* WARNING: Bad instruction - Truncating control flow here */
  halt_baddata();
}


/* address: 01c0f2ae */

/* WARNING: Control flow encountered bad instruction data */

void finalize_update_metadata(void)

{
  int iVar1;
  
  iVar1 = func_0x01c0fdb4();
  if (iVar1 != 0) {
    func_0x01c0ff8c(0);
    func_0x01c0fc6c(1);
  }
                    /* WARNING: Bad instruction - Truncating control flow here */
  halt_baddata();
}


/* address: 01c0b7a2 */

/* WARNING: Control flow encountered bad instruction data */

void transport_read_request(void)

{
  uRam01c103c2 = 1;
                    /* WARNING: Bad instruction - Truncating control flow here */
  halt_baddata();
}


/* address: 01c0d1ee */

/* WARNING: Control flow encountered bad instruction data */

void memcmp_exact(void)

{
                    /* WARNING: Bad instruction - Truncating control flow here */
  halt_baddata();
}


