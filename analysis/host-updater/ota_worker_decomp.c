/* FUN_14000e720 @ 14000e720 */

void FUN_14000e720(QObject *param_1)

{
  QMessageLogger *this;
  QDebug *this_00;
  QDebug local_res10 [24];
  QMessageLogger local_28 [32];

  this = (QMessageLogger *)QMessageLogger::QMessageLogger(local_28,(char *)0x0,0,(char *)0x0);
  this_00 = (QDebug *)QMessageLogger::debug(this);
  QDebug::operator<<(this_00,"OtaUpgradeWorker::startUpgrade() called");
  QDebug::~QDebug(local_res10);
  FUN_14000d750(param_1);
  return;
}


/* FUN_14000d750 @ 14000d750 */

/* WARNING: Function: __security_check_cookie replaced with injection: security_check_cookie */

void FUN_14000d750(QObject *param_1)

{
  longlong lVar1;
  QMessageLogger *pQVar2;
  QDebug *pQVar3;
  ulonglong uVar4;
  QString *pQVar5;
  char cVar6;
  undefined1 auStackY_128 [32];
  QDebug local_f8 [8];
  uint local_f0 [2];
  QDebug local_e8 [8];
  uint local_e0 [2];
  QString local_d8 [24];
  uint local_c0;
  QChar local_bc [2];
  QChar local_ba [2];
  QChar local_b8 [2];
  QChar local_b6 [2];
  QChar local_b4 [2];
  QChar local_b2 [2];
  QMessageLogger local_b0 [32];
  QMessageLogger local_90 [32];
  QDebug local_70 [8];
  QDebug local_68 [8];
  QString local_60 [24];
  QString local_48 [24];
  undefined4 local_30;
  undefined2 local_2c;
  ulonglong local_28;

  local_28 = DAT_14013adc0 ^ (ulonglong)auStackY_128;
  pQVar2 = (QMessageLogger *)QMessageLogger::QMessageLogger(local_90,(char *)0x0,0,(char *)0x0);
  pQVar3 = (QDebug *)QMessageLogger::debug(pQVar2);
  QDebug::operator<<(pQVar3,"OTA upgrade process started in worker thread");
  QDebug::~QDebug(local_e8);
  local_30 = 0x352422f0;
  local_2c = 0xf77f;
  cVar6 = '\0';
  if (*(int *)(param_1 + 0x48) == 2) {
    pQVar2 = (QMessageLogger *)QMessageLogger::QMessageLogger(local_90,(char *)0x0,0,(char *)0x0);
    pQVar3 = (QDebug *)QMessageLogger::debug(pQVar2);
    QDebug::operator<<(pQVar3,"Device already in OTA mode, waiting for device to be ready");
    QDebug::~QDebug(local_e8);
    FUN_140008e90(3000);
    cVar6 = '\0';
    pQVar2 = (QMessageLogger *)QMessageLogger::QMessageLogger(local_90,(char *)0x0,0,(char *)0x0);
    pQVar3 = (QDebug *)QMessageLogger::debug(pQVar2);
    QDebug::operator<<(pQVar3,"Sending upgrade mode command (second step - upgrade)");
  }
  else {
    pQVar2 = (QMessageLogger *)QMessageLogger::QMessageLogger(local_90,(char *)0x0,0,(char *)0x0);
    pQVar3 = (QDebug *)QMessageLogger::debug(pQVar2);
    QDebug::operator<<(pQVar3,"Sending upgrade mode command (first step - verification)");
  }
  QDebug::~QDebug(local_e8);
  if ((*(longlong *)(param_1 + 0x40) == 0) ||
     (uVar4 = thunk_FUN_140018360(*(longlong *)(param_1 + 0x40),&local_30,6,cVar6),
     (char)uVar4 == '\0')) {
    pQVar2 = (QMessageLogger *)QMessageLogger::QMessageLogger(local_b0,(char *)0x0,0,(char *)0x0);
    pQVar3 = (QDebug *)QMessageLogger::debug(pQVar2);
    QDebug::operator<<(pQVar3,"Failed to send upgrade mode command");
    QDebug::~QDebug(local_f8);
    QString::QString(local_d8,&DAT_140021970);
    FUN_14001a5a0(param_1,local_d8);
  }
  else {
    pQVar2 = (QMessageLogger *)QMessageLogger::QMessageLogger(local_90,(char *)0x0,0,(char *)0x0);
    pQVar3 = (QDebug *)QMessageLogger::debug(pQVar2);
    QDebug::operator<<(pQVar3,"Upgrade mode command sent successfully");
    QDebug::~QDebug(local_e8);
    local_e0[0] = 0;
    local_f0[0] = 0;
    local_c0 = 0;
    pQVar2 = (QMessageLogger *)QMessageLogger::QMessageLogger(local_90,(char *)0x0,0,(char *)0x0);
    pQVar3 = (QDebug *)QMessageLogger::debug(pQVar2);
    QDebug::operator<<(pQVar3,"Sleeping before reading requests");
    QDebug::~QDebug(local_e8);
    FUN_140008e90(2000);
    pQVar2 = (QMessageLogger *)QMessageLogger::QMessageLogger(local_90,(char *)0x0,0,(char *)0x0);
    pQVar3 = (QDebug *)QMessageLogger::debug(pQVar2);
    pQVar5 = (QString *)QString::QString(local_d8,"Processing request #%1");
    QChar::QChar(local_bc,L' ');
    pQVar5 = (QString *)QString::arg(pQVar5,local_60);
    QDebug::operator<<(pQVar3,pQVar5);
    QString::~QString(local_60);
    QString::~QString(local_d8);
    QDebug::~QDebug(local_e8);
    lVar1 = *(longlong *)(param_1 + 0x40);
    while ((lVar1 != 0 &&
           (uVar4 = FUN_140016c90(lVar1,local_e0,local_f0,&local_c0), (char)uVar4 != '\0'))) {
      pQVar2 = (QMessageLogger *)QMessageLogger::QMessageLogger(local_b0,(char *)0x0,0,(char *)0x0);
      pQVar3 = (QDebug *)QMessageLogger::debug(pQVar2);
      pQVar5 = (QString *)
               QString::QString((QString *)local_90,
                                "Request received - FlashType: %1, Address: 0x%2, Length: %3");
      QChar::QChar(local_ba,L' ');
      pQVar5 = (QString *)QString::arg(pQVar5,local_48,local_e0[0],0);
      QChar::QChar(local_b8,0x30);
      pQVar5 = (QString *)QString::arg(pQVar5,local_60,local_f0[0]);
      QChar::QChar(local_b6,L' ');
      pQVar5 = (QString *)QString::arg(pQVar5,local_d8);
      QDebug::operator<<(pQVar3,pQVar5);
      QString::~QString(local_d8);
      QString::~QString(local_60);
      QString::~QString(local_48);
      QString::~QString((QString *)local_90);
      QDebug::~QDebug(local_70);
      lVar1 = *(longlong *)(param_1 + 0x10);
      if ((lVar1 == 0) || (*(int *)(param_1 + 0x18) == 0)) {
        pQVar2 = (QMessageLogger *)
                 QMessageLogger::QMessageLogger(local_b0,(char *)0x0,0,(char *)0x0);
        pQVar3 = (QDebug *)QMessageLogger::debug(pQVar2);
        QDebug::operator<<(pQVar3,"ERROR: OTA data is null or empty");
        QDebug::~QDebug(local_f8);
        QString::QString(local_d8,"OTA data is invalid!");
        FUN_14001a5a0(param_1,local_d8);
        goto LAB_14000e1be;
      }
      uVar4 = (ulonglong)local_f0[0];
      if (local_f0[0] == 0xe0000000) {
        pQVar2 = (QMessageLogger *)
                 QMessageLogger::QMessageLogger(local_b0,(char *)0x0,0,(char *)0x0);
        pQVar3 = (QDebug *)QMessageLogger::debug(pQVar2);
        QDebug::operator<<(pQVar3,"Verification completed signal received");
        QDebug::~QDebug(local_f8);
        FUN_140017a30(*(longlong *)(param_1 + 0x40),(char)local_e0[0],"success",local_f0[0],8);
        pQVar2 = (QMessageLogger *)
                 QMessageLogger::QMessageLogger(local_b0,(char *)0x0,0,(char *)0x0);
        pQVar3 = (QDebug *)QMessageLogger::debug(pQVar2);
        QDebug::operator<<(pQVar3,"Sent verification success response");
        QDebug::~QDebug(local_f8);
        FUN_140008e90(3000);
        if (*(int *)(param_1 + 0x48) != 2) {
          pQVar2 = (QMessageLogger *)
                   QMessageLogger::QMessageLogger(local_b0,(char *)0x0,0,(char *)0x0);
          pQVar3 = (QDebug *)QMessageLogger::debug(pQVar2);
          QDebug::operator<<(pQVar3,
                             "First step (verification) completed, device will enter OTA mode");
          QDebug::~QDebug(local_f8);
          QString::QString(local_d8,"");
          FUN_14001a4d0(param_1,6,local_d8);
          QString::~QString(local_d8);
          FUN_14001a5d0(param_1);
          pQVar2 = (QMessageLogger *)
                   QMessageLogger::QMessageLogger(local_b0,(char *)0x0,0,(char *)0x0);
          pQVar3 = (QDebug *)QMessageLogger::debug(pQVar2);
          QDebug::operator<<(pQVar3,"Refreshing device info and waiting for device reconnection");
          QDebug::~QDebug(local_f8);
          QString::QString(local_d8,"");
          FUN_14001a4d0(param_1,5,local_d8);
          QString::~QString(local_d8);
          pQVar2 = (QMessageLogger *)
                   QMessageLogger::QMessageLogger(local_b0,(char *)0x0,0,(char *)0x0);
          pQVar3 = (QDebug *)QMessageLogger::debug(pQVar2);
          QDebug::operator<<(pQVar3,
                             "OTA verification process completed successfully, thread will exit normally"
                            );
          QDebug::~QDebug(local_f8);
          return;
        }
        pQVar2 = (QMessageLogger *)
                 QMessageLogger::QMessageLogger(local_b0,(char *)0x0,0,(char *)0x0);
        pQVar3 = (QDebug *)QMessageLogger::debug(pQVar2);
        QDebug::operator<<(pQVar3,"Already in updating state, verification completed");
        QDebug::~QDebug(local_f8);
        return;
      }
      if (local_f0[0] == 0xf0000000) {
        pQVar2 = (QMessageLogger *)
                 QMessageLogger::QMessageLogger(local_b0,(char *)0x0,0,(char *)0x0);
        pQVar3 = (QDebug *)QMessageLogger::debug(pQVar2);
        QDebug::operator<<(pQVar3,"Upgrade completed signal received");
        QDebug::~QDebug(local_f8);
        FUN_140017a30(*(longlong *)(param_1 + 0x40),(char)local_e0[0],"success",local_f0[0],8);
        QString::QString(local_d8,"");
        FUN_14001a4d0(param_1,4,local_d8);
        QString::~QString(local_d8);
        QString::QString(local_d8,&DAT_140021d50);
        FUN_14001a4d0(param_1,1,local_d8);
        QString::~QString(local_d8);
        pQVar2 = (QMessageLogger *)
                 QMessageLogger::QMessageLogger(local_b0,(char *)0x0,0,(char *)0x0);
        pQVar3 = (QDebug *)QMessageLogger::debug(pQVar2);
        QDebug::operator<<(pQVar3,"OTA upgrade process completed successfully");
        QDebug::~QDebug(local_f8);
        FUN_14001a580(param_1);
        return;
      }
      pQVar2 = (QMessageLogger *)QMessageLogger::QMessageLogger(local_b0,(char *)0x0,0,(char *)0x0);
      pQVar3 = (QDebug *)QMessageLogger::debug(pQVar2);
      pQVar5 = (QString *)
               QString::QString(local_d8,"Sending data to device - Address: 0x%1, Length: %2");
      QChar::QChar(local_b4,0x30);
      pQVar5 = (QString *)QString::arg(pQVar5,local_48,local_f0[0],8);
      QChar::QChar(local_b2,L' ');
      pQVar5 = (QString *)QString::arg(pQVar5,local_90,local_c0,0);
      QDebug::operator<<(pQVar3,pQVar5);
      QString::~QString((QString *)local_90);
      QString::~QString(local_48);
      QString::~QString(local_d8);
      QDebug::~QDebug(local_68);
      FUN_140017a30(*(longlong *)(param_1 + 0x40),(char)local_e0[0],(void *)(lVar1 + uVar4),
                    local_f0[0],local_c0);
      pQVar2 = (QMessageLogger *)QMessageLogger::QMessageLogger(local_b0,(char *)0x0,0,(char *)0x0);
      pQVar3 = (QDebug *)QMessageLogger::debug(pQVar2);
      QDebug::operator<<(pQVar3,"Data sent successfully");
      QDebug::~QDebug(local_f8);
      pQVar2 = (QMessageLogger *)QMessageLogger::QMessageLogger(local_90,(char *)0x0,0,(char *)0x0);
      pQVar3 = (QDebug *)QMessageLogger::debug(pQVar2);
      pQVar5 = (QString *)QString::QString(local_d8,"Processing request #%1");
      QChar::QChar(local_bc,L' ');
      pQVar5 = (QString *)QString::arg(pQVar5,local_60);
      QDebug::operator<<(pQVar3,pQVar5);
      QString::~QString(local_60);
      QString::~QString(local_d8);
      QDebug::~QDebug(local_e8);
      lVar1 = *(longlong *)(param_1 + 0x40);
    }
    pQVar2 = (QMessageLogger *)QMessageLogger::QMessageLogger(local_b0,(char *)0x0,0,(char *)0x0);
    pQVar3 = (QDebug *)QMessageLogger::debug(pQVar2);
    QDebug::operator<<(pQVar3,"Failed to get lower device request");
    QDebug::~QDebug(local_f8);
    if (*(int *)(param_1 + 0x48) == 1) {
      QString::QString(local_d8,&DAT_140021a50);
      FUN_14001a5a0(param_1,local_d8);
    }
    else {
      QString::QString(local_d8,&DAT_140021ad0);
      FUN_14001a5a0(param_1,local_d8);
    }
    QString::~QString(local_d8);
    QString::QString(local_d8,"");
    FUN_14001a4d0(param_1,4,local_d8);
  }
LAB_14000e1be:
  QString::~QString(local_d8);
  return;
}


/* FUN_14000e2e0 @ 14000e2e0 */

void FUN_14000e2e0(QObject *param_1)

{
  bool bVar1;
  QMessageLogger *pQVar2;
  QDebug *pQVar3;
  ulonglong uVar4;
  QString *pQVar5;
  undefined2 *puVar6;
  undefined8 uVar7;
  char *pcVar8;
  ulonglong uVar9;
  uint uVar10;
  uint uVar11;
  int iVar12;
  ulonglong uVar13;
  QDebug local_res8 [8];
  QChar local_res10 [8];
  QDebug local_res18 [8];
  __int64 local_b8;
  char *local_b0;
  QMessageLogger local_98 [32];
  QString local_78 [24];
  QMessageLogger local_60 [40];
  
  pQVar2 = (QMessageLogger *)QMessageLogger::QMessageLogger(local_98,(char *)0x0,0,(char *)0x0);
  pQVar3 = (QDebug *)QMessageLogger::debug(pQVar2);
  QDebug::operator<<(pQVar3,"PresetUpdateWorker::startUpdate() called");
  QDebug::~QDebug(local_res8);
  if ((*(longlong *)(param_1 + 0x28) == 0) ||
     (bVar1 = QByteArray::isEmpty((QByteArray *)(param_1 + 0x10)), bVar1)) {
    local_b8 = QByteArrayView::lengthHelperCharArray(&DAT_140021e28,0x2b);
    local_b0 = QByteArrayView::castHelper(&DAT_140021e28);
    uVar7 = QString::fromUtf8(local_98,&local_b8);
    FUN_14001a550(param_1,uVar7);
  }
  else {
    uVar4 = QByteArray::size((QByteArray *)(param_1 + 0x10));
    uVar9 = uVar4 >> 0xc & 0xfffff;
    uVar13 = (ulonglong)((int)uVar9 + 1);
    if ((uVar4 & 0xfff) == 0) {
      uVar13 = uVar9;
    }
    pQVar2 = (QMessageLogger *)QMessageLogger::QMessageLogger(local_60,(char *)0x0,0,(char *)0x0);
    pQVar3 = (QDebug *)QMessageLogger::debug(pQVar2);
    pQVar5 = (QString *)QString::QString((QString *)local_98,"Preset erase: dataLen=%1, sectors=%2")
    ;
    puVar6 = (undefined2 *)QChar::QChar((QChar *)local_res8,L' ');
    pQVar5 = (QString *)QString::arg(pQVar5,local_78,uVar4 & 0xffffffff,0,10,*puVar6);
    puVar6 = (undefined2 *)QChar::QChar(local_res10,L' ');
    pQVar5 = (QString *)QString::arg(pQVar5,&local_b8,uVar13,0,10,*puVar6);
    QDebug::operator<<(pQVar3,pQVar5);
    QString::~QString((QString *)&local_b8);
    QString::~QString(local_78);
    QString::~QString((QString *)local_98);
    QDebug::~QDebug(local_res18);
    uVar10 = 0;
    if ((uint)uVar13 != 0) {
      iVar12 = 0;
      uVar11 = 0x32;
      do {
        uVar7 = FUN_140016ac0(*(longlong *)(param_1 + 0x28),5,iVar12);
        if ((char)uVar7 == '\0') {
          pQVar2 = (QMessageLogger *)
                   QMessageLogger::QMessageLogger(local_60,(char *)0x0,0,(char *)0x0);
          pQVar3 = (QDebug *)QMessageLogger::debug(pQVar2);
          pQVar5 = (QString *)QString::QString(local_78,"Preset erase failed at addr 0x%1");
          puVar6 = (undefined2 *)QChar::QChar((QChar *)local_res8,0x30);
          pQVar5 = (QString *)QString::arg(pQVar5,local_98,iVar12,8,0x10,*puVar6);
          QDebug::operator<<(pQVar3,pQVar5);
          QString::~QString((QString *)local_98);
          QString::~QString(local_78);
          QDebug::~QDebug((QDebug *)local_res10);
          local_b8 = QByteArrayView::lengthHelperCharArray(&DAT_140021ea8,0x1e);
          local_b0 = QByteArrayView::castHelper(&DAT_140021ea8);
          uVar7 = QString::fromUtf8(local_98,&local_b8);
          FUN_14001a550(param_1,uVar7);
          goto LAB_14000e6fb;
        }
        FUN_14001a030(param_1,(int)(uVar11 / uVar13));
        uVar10 = uVar10 + 1;
        iVar12 = iVar12 + 0x1000;
        uVar11 = uVar11 + 0x32;
      } while (uVar10 < (uint)uVar13);
    }
    pQVar2 = (QMessageLogger *)QMessageLogger::QMessageLogger(local_60,(char *)0x0,0,(char *)0x0);
    pQVar3 = (QDebug *)QMessageLogger::debug(pQVar2);
    QDebug::operator<<(pQVar3,"Preset erase done, start writing");
    QDebug::~QDebug(local_res8);
    pcVar8 = QByteArray::constData((QByteArray *)(param_1 + 0x10));
    uVar7 = FUN_140016b10(*(longlong *)(param_1 + 0x28),5,0,pcVar8,(uint)uVar4,(QObject *)0x0);
    if ((char)uVar7 != '\0') {
      FUN_14001a030(param_1,100);
      pQVar2 = (QMessageLogger *)QMessageLogger::QMessageLogger(local_60,(char *)0x0,0,(char *)0x0);
      pQVar3 = (QDebug *)QMessageLogger::debug(pQVar2);
      QDebug::operator<<(pQVar3,"Preset update completed successfully");
      QDebug::~QDebug(local_res8);
      FUN_14001a530(param_1);
      return;
    }
    pQVar2 = (QMessageLogger *)QMessageLogger::QMessageLogger(local_60,(char *)0x0,0,(char *)0x0);
    pQVar3 = (QDebug *)QMessageLogger::debug(pQVar2);
    QDebug::operator<<(pQVar3,"Preset write failed");
    QDebug::~QDebug(local_res8);
    local_b8 = QByteArrayView::lengthHelperCharArray(&DAT_140021f08,0x1e);
    local_b0 = QByteArrayView::castHelper(&DAT_140021f08);
    uVar7 = QString::fromUtf8(local_98,&local_b8);
    FUN_14001a550(param_1,uVar7);
  }
LAB_14000e6fb:
  QString::~QString((QString *)local_98);
  return;
}


/* FUN_140010770 @ 140010770 */

void FUN_140010770(int param_1,void *param_2)

{
  longlong *plVar1;
  longlong lVar2;
  QWidget *pQVar3;
  QString *pQVar4;
  __int64 local_58;
  char *local_50;
  QString local_38 [24];
  QString local_20 [24];
  
  if (param_1 == 0) {
    if (param_2 != (void *)0x0) {
      free(param_2);
    }
  }
  else if (param_1 == 1) {
    QString::QString(local_38,"INFO");
    QString::QString((QString *)&local_58,"Preset update completed successfully");
    FUN_140011330((QString *)&local_58,local_38);
    QString::~QString((QString *)&local_58);
    QString::~QString(local_38);
    *(undefined1 *)(*(longlong *)((longlong)param_2 + 0x10) + 0xf8) = 0;
    plVar1 = *(longlong **)(*(longlong *)((longlong)param_2 + 0x10) + 0x80);
    if (plVar1 != (longlong *)0x0) {
      (**(code **)(*plVar1 + 0x58))(plVar1,0);
    }
    lVar2 = *(longlong *)((longlong)param_2 + 0x10);
    local_58 = QByteArrayView::lengthHelperCharArray(&DAT_140025480,0x26);
    local_50 = QByteArrayView::castHelper(&DAT_140025480);
    pQVar4 = (QString *)QString::fromUtf8(local_20,&local_58);
    pQVar3 = *(QWidget **)(lVar2 + 0x78);
    if (pQVar3 != (QWidget *)0x0) {
      pQVar4 = (QString *)QString::QString(local_38,pQVar4);
      FUN_140013ed0(pQVar3,1,pQVar4);
    }
    QString::~QString(local_20);
    FUN_1400158a0(*(longlong *)((longlong)param_2 + 0x10));
    return;
  }
  return;
}


/* FUN_1400108b0 @ 1400108b0 */

void FUN_1400108b0(int param_1,void *param_2)

{
  longlong *plVar1;
  longlong lVar2;
  QWidget *pQVar3;
  QString *pQVar4;
  QString local_38 [24];
  QString local_20 [24];
  
  if (param_1 == 0) {
    if (param_2 != (void *)0x0) {
      free(param_2);
      return;
    }
  }
  else if (param_1 == 1) {
    QString::QString(local_20,"INFO");
    QString::QString(local_38,"Second step (upgrade) completed successfully");
    FUN_140011330(local_38,local_20);
    QString::~QString(local_38);
    QString::~QString(local_20);
    *(undefined4 *)(*(longlong *)((longlong)param_2 + 0x10) + 0xa0) = 0;
    *(undefined1 *)(*(longlong *)((longlong)param_2 + 0x10) + 0x115) = 0;
    plVar1 = *(longlong **)(*(longlong *)((longlong)param_2 + 0x10) + 0x80);
    if (plVar1 != (longlong *)0x0) {
      (**(code **)(*plVar1 + 0x58))(plVar1,0);
    }
    lVar2 = *(longlong *)((longlong)param_2 + 0x10);
    QString::QString(local_20,&DAT_140021d50);
    pQVar3 = *(QWidget **)(lVar2 + 0x78);
    if (pQVar3 != (QWidget *)0x0) {
      pQVar4 = (QString *)QString::QString(local_38,local_20);
      FUN_140013ed0(pQVar3,1,pQVar4);
    }
    QString::~QString(local_20);
    return;
  }
  return;
}


/* FUN_1400123a0 @ 1400123a0 */

void FUN_1400123a0(QObject *param_1,uint param_2,int param_3)

{
  QObject *pQVar1;
  undefined4 uVar2;
  int iVar3;
  QString *pQVar4;
  undefined2 *puVar5;
  char *pcVar6;
  QChar local_res8 [8];
  QChar local_res10 [8];
  QChar local_res18 [16];
  undefined2 uVar8;
  undefined4 uVar7;
  undefined2 uVar9;
  QString local_108 [24];
  QString local_f0 [24];
  QString local_d8 [24];
  undefined8 local_c0;
  int local_b8;
  QString local_b0 [24];
  QString local_98 [24];
  QString local_80 [24];
  QString local_68 [24];
  QString local_50 [24];
  
  thunk_FUN_140018250(*(longlong *)(param_1 + 0x48));
  QString::QString(local_68,"DEBUG");
  pQVar4 = (QString *)QString::QString(local_b0,"Probing ports %1/%2 ...");
  puVar5 = (undefined2 *)QChar::QChar(local_res10,L' ');
  pQVar4 = (QString *)QString::arg(pQVar4,local_50,param_2,0,10,*puVar5);
  puVar5 = (undefined2 *)QChar::QChar(local_res18,L' ');
  pQVar4 = (QString *)QString::arg(pQVar4,local_108,param_3,0,10,*puVar5);
  FUN_140011330(pQVar4,local_68);
  QString::~QString(local_108);
  QString::~QString(local_50);
  QString::~QString(local_b0);
  QString::~QString(local_68);
  uVar2 = FUN_140011b50((longlong)param_1,param_3 << 0x10 | param_2 & 0xffff,1,1000,0x9c4);
  QString::QString(local_108,"DEBUG");
  pQVar4 = (QString *)QString::QString(local_f0,"Probe ports %1/%2 returned: %3");
  puVar5 = (undefined2 *)QChar::QChar(local_res10,L' ');
  pQVar4 = (QString *)QString::arg(pQVar4,local_98,param_2,0,10,*puVar5);
  puVar5 = (undefined2 *)QChar::QChar(local_res18,L' ');
  uVar8 = 0;
  pQVar4 = (QString *)QString::arg(pQVar4,local_50,param_3,0,10,*puVar5);
  puVar5 = (undefined2 *)QChar::QChar(local_res8,L' ');
  uVar9 = *puVar5;
  pcVar6 = "no-response";
  if ((char)uVar2 != '\0') {
    pcVar6 = "OK";
  }
  QString::QString(local_68,pcVar6);
  uVar7 = CONCAT22(uVar8,uVar9);
  pQVar4 = (QString *)QString::arg(pQVar4,local_b0,local_68,0,uVar7);
  uVar9 = (undefined2)((uint)uVar7 >> 0x10);
  FUN_140011330(pQVar4,local_108);
  QString::~QString(local_b0);
  QString::~QString(local_68);
  QString::~QString(local_50);
  QString::~QString(local_98);
  QString::~QString(local_f0);
  QString::~QString(local_108);
  if ((char)uVar2 == '\0') {
    QString::QString(local_108,"DEBUG");
    pQVar4 = (QString *)
             QString::QString(local_b0,"Not a target device on ports %1/%2 (no handshake response)")
    ;
    puVar5 = (undefined2 *)QChar::QChar(local_res10,L' ');
    pQVar4 = (QString *)QString::arg(pQVar4,local_98,param_2,0,10,*puVar5);
    puVar5 = (undefined2 *)QChar::QChar(local_res18,L' ');
    pQVar4 = (QString *)QString::arg(pQVar4,local_f0,param_3,0,10,*puVar5);
    FUN_140011330(pQVar4,local_108);
    QString::~QString(local_f0);
    QString::~QString(local_98);
    QString::~QString(local_b0);
    pQVar4 = local_108;
    goto LAB_140012a11;
  }
  QString::QString(local_80,(QString *)(*(longlong *)(param_1 + 0x48) + 0x2caa0));
  QString::QString(local_108,"INFO");
  pQVar4 = (QString *)QString::QString(local_98,"Connected to device: %1");
  puVar5 = (undefined2 *)QChar::QChar(local_res10,L' ');
  uVar2 = CONCAT22(uVar9,*puVar5);
  pQVar4 = (QString *)QString::arg(pQVar4,local_f0,local_80,0,uVar2);
  uVar9 = (undefined2)((uint)uVar2 >> 0x10);
  FUN_140011330(pQVar4,local_108);
  QString::~QString(local_f0);
  QString::~QString(local_98);
  QString::~QString(local_108);
  QString::QString(local_d8);
  local_c0 = CONCAT44(param_2,*(undefined4 *)(*(longlong *)(param_1 + 0x48) + 0x2cab8));
  local_b8 = param_3;
  pQVar4 = (QString *)QString::left(local_80,(__int64)local_f0);
  QString::QString(local_108,"OTA-");
  iVar3 = QString::compare(pQVar4,local_108,0);
  QString::~QString(local_108);
  QString::~QString(local_f0);
  pQVar1 = param_1 + 0x88;
  if (iVar3 == 0) {
    pQVar4 = (QString *)QString::mid(local_80,(__int64)local_f0,4);
    QString::operator=(local_d8,pQVar4);
    QString::~QString(local_f0);
    *(undefined4 *)(param_1 + 0xa0) = 2;
    FUN_14000e7d0((longlong *)pQVar1,*(longlong *)(param_1 + 0x98),local_d8);
    if ((*(int **)pQVar1 == (int *)0x0) || (1 < **(int **)pQVar1)) {
      FUN_140012a30((longlong *)pQVar1,0,0,(undefined8 *)0x0);
    }
    if (param_1[0x115] != (QObject)0x0) {
      QString::QString(local_108,"WARNING");
      pQVar4 = (QString *)
               QString::QString(local_f0,"Upgrade is already in progress, skipping duplicate start")
      ;
      FUN_140011330(pQVar4,local_108);
      QString::~QString(local_f0);
      goto LAB_1400129ed;
    }
    QString::QString(local_108,"INFO");
    pQVar4 = (QString *)QString::QString(local_f0,"Device in OTA mode, continuing upgrade process");
    FUN_140011330(pQVar4,local_108);
    QString::~QString(local_f0);
    QString::~QString(local_108);
    FUN_140014150(param_1,'\x01');
  }
  else {
    QString::operator=(local_d8,local_80);
    FUN_14000e7d0((longlong *)pQVar1,*(longlong *)(param_1 + 0x98),local_d8);
    if ((*(int **)pQVar1 == (int *)0x0) || (1 < **(int **)pQVar1)) {
      FUN_140012a30((longlong *)pQVar1,0,0,(undefined8 *)0x0);
    }
    QString::QString(local_108,"INFO");
    pQVar4 = (QString *)QString::QString(local_b0,"Device connected successfully: %1, Version: %2");
    puVar5 = (undefined2 *)QChar::QChar(local_res10,L' ');
    pQVar4 = (QString *)QString::arg(pQVar4,local_98,local_d8,0,CONCAT22(uVar9,*puVar5));
    puVar5 = (undefined2 *)QChar::QChar(local_res18,L' ');
    pQVar4 = (QString *)QString::arg(pQVar4,local_f0,local_c0 & 0xffffffff,0,10,*puVar5);
    FUN_140011330(pQVar4,local_108);
    QString::~QString(local_f0);
    QString::~QString(local_98);
    QString::~QString(local_b0);
LAB_1400129ed:
    QString::~QString(local_108);
    thunk_FUN_140018250(*(longlong *)(param_1 + 0x48));
  }
  QString::~QString(local_d8);
  pQVar4 = local_80;
LAB_140012a11:
  QString::~QString(pQVar4);
  return;
}


/* FUN_14000e780 @ 14000e780 */

undefined8 FUN_14000e780(longlong *param_1,undefined8 param_2,undefined8 param_3)

{
  byte bVar1;

  bVar1 = FUN_140016e10(*param_1,*(uint *)(param_1 + 4),CONCAT71((int7)((ulonglong)param_3 >> 8),1),
                        *(int *)((longlong)param_1 + 0x24),(int)param_1[5]);
  LOCK();
  *(uint *)param_1[2] = (uint)bVar1;
  UNLOCK();
  _Cnd_do_broadcast_at_thread_exit();
  FUN_14000f8d0((longlong)param_1);
  free(param_1);
  return 0;
}


/* FUN_140011b50 @ 140011b50 */

undefined4
FUN_140011b50(longlong param_1,undefined4 param_2,undefined4 param_3,undefined4 param_4,uint param_5
             )

{
  int *piVar1;
  longlong *plVar2;
  int iVar3;
  longlong *plVar4;
  longlong lVar5;
  longlong lVar6;
  longlong lVar7;
  QString *pQVar8;
  undefined2 *puVar9;
  longlong *plVar10;
  ulonglong uVar11;
  undefined4 uVar12;
  longlong lVar13;
  longlong *plVar14;
  longlong *local_res8;
  QChar local_res10 [8];
  undefined8 local_e8;
  undefined8 uStack_e0;
  longlong *local_c8;
  longlong *local_c0;
  longlong *local_b0;
  undefined4 local_a8;
  undefined4 uStack_a4;
  uint uStack_a0;
  uint uStack_9c;
  longlong local_88;
  longlong *plStack_80;
  longlong *local_78;
  longlong *plStack_70;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  longlong local_58;
  longlong *local_50;
  longlong *local_48;
  longlong *local_40;
  
  local_b0 = (longlong *)(param_1 + 0x48);
  if (*(longlong *)(param_1 + 0x50) != 0) {
    LOCK();
    piVar1 = (int *)(*(longlong *)(param_1 + 0x50) + 8);
    *piVar1 = *piVar1 + 1;
    UNLOCK();
  }
  lVar5 = *local_b0;
  plVar14 = *(longlong **)(param_1 + 0x50);
  local_c8 = plVar14;
  local_58 = lVar5;
  local_50 = plVar14;
  plVar4 = (longlong *)FUN_14001ae9c(0x18);
  *plVar4 = 0;
  plVar4[1] = 0;
  *(undefined4 *)(plVar4 + 1) = 1;
  *(undefined4 *)((longlong)plVar4 + 0xc) = 1;
  *plVar4 = (longlong)std::_Ref_count_obj2<std::atomic<int>_>::vftable;
  local_78 = plVar4 + 2;
  *(undefined4 *)local_78 = 0xffffffff;
  if (plVar14 != (longlong *)0x0) {
    LOCK();
    *(int *)(plVar14 + 1) = (int)plVar14[1] + 1;
    UNLOCK();
  }
  LOCK();
  *(int *)(plVar4 + 1) = (int)plVar4[1] + 1;
  UNLOCK();
  local_res8 = plVar4;
  local_88 = lVar5;
  plStack_80 = plVar14;
  plStack_70 = plVar4;
  local_68 = param_2;
  local_64 = param_3;
  local_60 = param_4;
  local_48 = local_78;
  local_40 = plVar4;
  local_res8 = (longlong *)FUN_14001ae9c(0x30);
  *local_res8 = lVar5;
  local_res8[1] = (longlong)plVar14;
  local_88 = 0;
  plStack_80 = (longlong *)0x0;
  local_res8[2] = (longlong)(plVar4 + 2);
  local_res8[3] = (longlong)plVar4;
  local_78 = (longlong *)0x0;
  plStack_70 = (longlong *)0x0;
  *(undefined4 *)(local_res8 + 4) = param_2;
  *(undefined4 *)((longlong)local_res8 + 0x24) = param_3;
  *(undefined4 *)(local_res8 + 5) = param_4;
  local_e8 = _beginthreadex((void *)0x0,0,FUN_14000e780,local_res8,0,(uint *)&uStack_e0);
  if (local_e8 == 0) {
    uStack_e0 = (ulonglong)uStack_e0._4_4_ << 0x20;
                    /* WARNING: Subroutine does not return */
    std::_Throw_Cpp_error(6);
  }
  if ((uint)uStack_e0 != 0) {
    local_e8._4_4_ = (undefined4)(local_e8 >> 0x20);
    local_a8 = (undefined4)local_e8;
    uStack_a4 = local_e8._4_4_;
    uStack_a0 = (uint)uStack_e0;
    uStack_9c = uStack_e0._4_4_;
    iVar3 = _Thrd_detach(&local_a8);
    if (iVar3 == 0) {
      local_e8 = 0;
      uStack_e0 = 0;
      FUN_140011640((longlong *)&local_res8);
      if ((int)plVar4[2] == -1) {
        do {
          plVar10 = local_res8;
          lVar5 = _Query_perf_frequency();
          lVar6 = _Query_perf_counter();
          if (lVar5 == 10000000) {
            lVar6 = lVar6 * 100;
          }
          else {
            if (lVar5 == 24000000) {
              lVar5 = lVar6 + SUB168(SEXT816(-0x4d0b03f86b6f730d) * SEXT816(lVar6),8);
              lVar7 = (lVar5 >> 0x18) - (lVar5 >> 0x3f);
              lVar5 = (lVar6 + lVar7 * -24000000) * 1000000000;
              lVar5 = SUB168(SEXT816(-0x4d0b03f86b6f730d) * SEXT816(lVar5),8) + lVar5;
              lVar6 = (lVar5 >> 0x18) - (lVar5 >> 0x3f);
            }
            else {
              lVar7 = lVar6 / lVar5;
              lVar6 = ((lVar6 % lVar5) * 1000000000) / lVar5;
            }
            lVar6 = lVar6 + lVar7 * 1000000000;
          }
          plVar14 = local_c8;
          if ((longlong)(ulonglong)param_5 <= (lVar6 - (longlong)plVar10) / 1000000) break;
          FUN_140011640(&local_e8);
          if ((longlong)local_e8 < 0x7fffffffff67697f) {
            lVar5 = local_e8 + 10000000;
          }
          else {
            lVar5 = 0x7fffffffffffffff;
          }
          while( true ) {
            lVar6 = _Query_perf_frequency();
            lVar7 = _Query_perf_counter();
            if (lVar6 == 10000000) {
              lVar7 = lVar7 * 100;
            }
            else {
              if (lVar6 == 24000000) {
                lVar6 = lVar7 + SUB168(SEXT816(-0x4d0b03f86b6f730d) * SEXT816(lVar7),8);
                lVar13 = (lVar6 >> 0x18) - (lVar6 >> 0x3f);
                lVar6 = (lVar7 + lVar13 * -24000000) * 1000000000;
                lVar6 = lVar6 + SUB168(SEXT816(-0x4d0b03f86b6f730d) * SEXT816(lVar6),8);
                lVar7 = (lVar6 >> 0x18) - (lVar6 >> 0x3f);
              }
              else {
                lVar13 = lVar7 / lVar6;
                lVar7 = ((lVar7 % lVar6) * 1000000000) / lVar6;
              }
              lVar7 = lVar7 + lVar13 * 1000000000;
            }
            if (lVar5 <= lVar7) break;
            lVar7 = lVar5 - lVar7;
            if (lVar7 < 0x4e94914f0001) {
              uVar11 = lVar7 / 1000000;
              if ((longlong)(uVar11 * 1000000) < lVar7) {
                uVar11 = (ulonglong)((int)uVar11 + 1);
              }
              Sleep((DWORD)uVar11);
            }
            else {
              Sleep(86400000);
            }
          }
          plVar14 = local_c8;
        } while ((int)plVar4[2] == -1);
      }
      if ((int)plVar4[2] == 1) {
        uVar12 = 1;
      }
      else {
        if ((int)plVar4[2] != 0) {
          QString::QString((QString *)&local_a8,"ERROR");
          pQVar8 = (QString *)
                   QString::QString((QString *)&local_e8,
                                    "USB open timed out after %1ms (port WinMM open blocked); recreating connection"
                                   );
          puVar9 = (undefined2 *)QChar::QChar(local_res10,L' ');
          pQVar8 = (QString *)QString::arg(pQVar8,&local_c8,param_5,0,10,*puVar9);
          FUN_140011330(pQVar8,(QString *)&local_a8);
          QString::~QString((QString *)&local_c8);
          QString::~QString((QString *)&local_e8);
          QString::~QString((QString *)&local_a8);
          plVar10 = (longlong *)FUN_14001ae9c(0x2cad0);
          *plVar10 = 0;
          plVar10[1] = 0;
          *(undefined4 *)(plVar10 + 1) = 1;
          *(undefined4 *)((longlong)plVar10 + 0xc) = 1;
          *plVar10 = (longlong)std::_Ref_count_obj2<CUSBConnect>::vftable;
          local_res8 = plVar10;
          FUN_1400169a0(plVar10 + 2);
          local_c8 = plVar10 + 2;
          local_c0 = plVar10;
          FUN_14000fe20(local_b0,&local_c8);
          plVar10 = local_c0;
          if (local_c0 != (longlong *)0x0) {
            LOCK();
            plVar2 = local_c0 + 1;
            lVar5 = *plVar2;
            *(int *)plVar2 = (int)*plVar2 + -1;
            UNLOCK();
            if ((int)lVar5 == 1) {
              (**(code **)*local_c0)(local_c0);
              LOCK();
              piVar1 = (int *)((longlong)plVar10 + 0xc);
              iVar3 = *piVar1;
              *piVar1 = *piVar1 + -1;
              UNLOCK();
              if (iVar3 == 1) {
                (**(code **)(*plVar10 + 8))(plVar10);
              }
            }
          }
        }
        uVar12 = 0;
      }
      LOCK();
      plVar10 = plVar4 + 1;
      lVar5 = *plVar10;
      *(int *)plVar10 = (int)*plVar10 + -1;
      UNLOCK();
      if ((int)lVar5 == 1) {
        (**(code **)*plVar4)(plVar4);
        LOCK();
        piVar1 = (int *)((longlong)plVar4 + 0xc);
        iVar3 = *piVar1;
        *piVar1 = *piVar1 + -1;
        UNLOCK();
        if (iVar3 == 1) {
          (**(code **)(*plVar4 + 8))(plVar4);
        }
      }
      if (plVar14 != (longlong *)0x0) {
        LOCK();
        plVar4 = plVar14 + 1;
        lVar5 = *plVar4;
        *(int *)plVar4 = (int)*plVar4 + -1;
        UNLOCK();
        if ((int)lVar5 == 1) {
          (**(code **)*plVar14)(plVar14);
          LOCK();
          piVar1 = (int *)((longlong)plVar14 + 0xc);
          iVar3 = *piVar1;
          *piVar1 = *piVar1 + -1;
          UNLOCK();
          if (iVar3 == 1) {
            (**(code **)(*plVar14 + 8))(plVar14);
          }
        }
      }
      return uVar12;
    }
  }
                    /* WARNING: Subroutine does not return */
  std::_Throw_Cpp_error(1);
}


/* FUN_1400169a0 @ 1400169a0 */

undefined8 * FUN_1400169a0(undefined8 *param_1)

{
  FUN_140017f80(param_1);
  param_1[0x1912] = CCriticalSection::vftable;
  QString::QString((QString *)(param_1 + 0x5954));
  *(undefined4 *)((longlong)param_1 + 0x2cabc) = 0x400;
  return param_1;
}


/* FUN_140016c90 @ 140016c90 */

ulonglong FUN_140016c90(longlong param_1,uint *param_2,undefined4 *param_3,undefined4 *param_4)

{
  bool bVar1;
  ulonglong uVar2;
  QMessageLogger *pQVar3;
  ulonglong extraout_RAX;
  ulonglong extraout_RAX_00;
  uint local_res8;
  int local_48 [2];
  QMessageLogger local_40 [40];
  
  local_48[0] = 0;
  uVar2 = FUN_140018060(param_1,param_1 + 0xc898,0xf,local_48,8000);
  if ((char)uVar2 != '\0') {
    if (*(char *)(param_1 + 0xc89a) == '0') {
      if (local_48[0] != 0xf) {
        uVar2 = FUN_140008d80("Data length error,need %d bytes,got %d bytes");
        return uVar2 & 0xffffffffffffff00;
      }
      local_res8 = (uint)*(uint3 *)(param_1 + 0xc89b);
      bVar1 = FUN_140017cb0(param_1,(char *)(param_1 + 0xc89e),local_res8,
                            *(byte *)((ulonglong)(local_res8 + 6) + 0xc898 + param_1));
      if (bVar1) {
        *param_2 = (uint)*(byte *)(param_1 + 0xc89e);
        *param_3 = *(undefined4 *)(param_1 + 0xc89f);
        *param_4 = 0;
        *(undefined2 *)param_4 = *(undefined2 *)(param_1 + 0xc8a3);
        *(undefined1 *)((longlong)param_4 + 2) = *(undefined1 *)(param_1 + 0xc8a5);
        uVar2 = 1;
      }
      else {
        pQVar3 = (QMessageLogger *)
                 QMessageLogger::QMessageLogger(local_40,(char *)0x0,0,(char *)0x0);
        QMessageLogger::debug(pQVar3,"get_upload_responds::Checksum error!\n");
        uVar2 = extraout_RAX_00 & 0xffffffffffffff00;
      }
      return uVar2;
    }
    pQVar3 = (QMessageLogger *)QMessageLogger::QMessageLogger(local_40,(char *)0x0,0,(char *)0x0);
    QMessageLogger::debug(pQVar3,"get_upload_responds::Data type not 0x30!\n");
    uVar2 = extraout_RAX;
  }
  return uVar2 & 0xffffffffffffff00;
}


/* FUN_140016e10 @ 140016e10 */

/* WARNING: Function: __security_check_cookie replaced with injection: security_check_cookie */

char FUN_140016e10(longlong param_1,uint param_2,undefined8 param_3,int param_4,undefined4 param_5)

{
  QChar *pQVar1;
  ulonglong uVar2;
  void *pvVar3;
  undefined8 ******_Src;
  void *_Size;
  int iVar4;
  long lVar5;
  int iVar6;
  QString *pQVar7;
  ulonglong uVar8;
  undefined8 uVar9;
  undefined1 (*pauVar10) [32];
  undefined8 *******pppppppuVar11;
  undefined1 (*pauVar12) [32];
  undefined1 (*pauVar13) [32];
  int *piVar14;
  void *pvVar15;
  char *pcVar16;
  void *pvVar17;
  int iVar18;
  ulonglong uVar19;
  size_t sVar20;
  char cVar21;
  ulonglong uVar22;
  uint uVar23;
  undefined8 *******pppppppuVar24;
  undefined1 auStackY_198 [32];
  QChar local_158 [8];
  void *local_150;
  ulonglong local_148;
  undefined1 (*local_140) [32];
  QChar local_138 [8];
  longlong local_130;
  QString local_128 [24];
  QString local_110 [24];
  QString local_f8 [24];
  longlong local_e0;
  undefined1 (*local_d8) [32];
  undefined8 uStack_d0;
  size_t local_c8;
  ulonglong local_c0;
  undefined8 ******local_b8;
  undefined8 uStack_b0;
  void *local_a8;
  void *local_a0;
  undefined1 (*local_98) [32];
  undefined8 uStack_90;
  ulonglong local_88;
  ulonglong uStack_80;
  undefined8 local_78;
  undefined8 uStack_70;
  ulonglong local_68;
  ulonglong uStack_60;
  ulonglong local_40;

  local_40 = DAT_14013adc0 ^ (ulonglong)auStackY_198;
  local_150 = (void *)CONCAT44(local_150._4_4_,param_5);
  uVar22 = 0;
  local_130 = param_1;
  local_e0 = param_1;
  QString::QString(local_110,"DEBUG");
  pQVar7 = (QString *)
           QString::QString((QString *)&local_78,"  open(): calling M_usb.open(idx=0x%1) ...");
  QChar::QChar(local_158,L' ');
  pQVar7 = (QString *)QString::arg(pQVar7,local_128,param_2,0);
  FUN_140011330(pQVar7,local_110);
  QString::~QString(local_128);
  QString::~QString((QString *)&local_78);
  QString::~QString(local_110);
  uVar8 = FUN_140018280(param_1,(ulonglong)param_2,1);
  QString::QString(local_128,"DEBUG");
  pQVar7 = (QString *)QString::QString(local_f8,"  open(): M_usb.open returned %1");
  QChar::QChar(local_158,L' ');
  pcVar16 = "false";
  if ((char)uVar8 != '\0') {
    pcVar16 = "true";
  }
  QString::QString(local_110,pcVar16);
  pQVar7 = (QString *)QString::arg(pQVar7,&local_78);
  FUN_140011330(pQVar7,local_128);
  QString::~QString((QString *)&local_78);
  QString::~QString(local_110);
  QString::~QString(local_f8);
  QString::~QString(local_128);
  if ((char)uVar8 == '\0') goto LAB_1400179d0;
  if (1 < param_4) {
    FUN_140008e90(0x96);
  }
  iVar4 = 1;
  if (0 < param_4) {
    iVar4 = param_4;
  }
  uStack_d0 = 0;
  local_c8 = 0;
  local_c0 = 0xf;
  local_d8 = (undefined1 (*) [32])0x0;
  uStack_b0 = 0;
  local_a8 = (void *)0x0;
  pvVar17 = (void *)0xf;
  local_a0 = (void *)0xf;
  local_b8 = (undefined8 *******)0x0;
  uVar8 = uVar22;
  while (iVar18 = (int)uVar8, iVar18 < iVar4) {
    QString::QString(local_128,"DEBUG");
    pQVar7 = (QString *)
             QString::QString(local_110,"  open(): handshake query attempt %1, timeout=%2ms ...");
    QChar::QChar(local_158,L' ');
    uVar23 = iVar18 + 1;
    pQVar7 = (QString *)QString::arg(pQVar7,&local_78,uVar23);
    QChar::QChar(local_138,L' ');
    pQVar7 = (QString *)QString::arg(pQVar7,local_f8,(ulonglong)local_150 & 0xffffffff);
    FUN_140011330(pQVar7,local_128);
    QString::~QString(local_f8);
    QString::~QString((QString *)&local_78);
    QString::~QString(local_110);
    QString::~QString(local_128);
    uVar8 = FUN_140017f20(param_1,0x11);
    if ((char)uVar8 != '\0') {
      uVar9 = FUN_140017d20(param_1,0x11,(longlong)&local_78,0x22,(uint *)&local_140,(int)local_150)
      ;
      if ((char)uVar9 != '\0') {
        local_c8 = 0;
        pauVar13 = (undefined1 (*) [32])&local_d8;
        if (0xf < local_c0) {
          pauVar13 = local_d8;
        }
        (*pauVar13)[0] = '\0';
        goto LAB_1400171d0;
      }
    }
    QString::QString(local_128,"DEBUG");
    pQVar7 = (QString *)
             QString::QString((QString *)&local_78,
                              "  open(): handshake query attempt %1 got no valid response");
    QChar::QChar((QChar *)&local_148,L' ');
    pQVar7 = (QString *)QString::arg(pQVar7,local_f8);
    FUN_140011330(pQVar7,local_128);
    QString::~QString(local_f8);
    QString::~QString((QString *)&local_78);
    QString::~QString(local_128);
    if ((int)uVar23 < iVar4) {
      iVar6 = 2;
      if (iVar18 < 3) {
        iVar6 = iVar18;
      }
      FUN_140008e90(*(uint *)(&DAT_140025ba0 + (longlong)iVar6 * 4));
    }
    uVar8 = (ulonglong)uVar23;
  }
  cVar21 = '\0';
  pppppppuVar11 = (undefined8 *******)local_b8;
  goto LAB_14001792c;
LAB_1400171d0:
  do {
    uVar8 = local_c0;
    sVar20 = local_c8;
    local_158[0] = *(QChar *)((longlong)&local_78 + uVar22 + 6);
    if (local_c8 < local_c0) {
      pauVar13 = (undefined1 (*) [32])&local_d8;
      if (0xf < local_c0) {
        pauVar13 = local_d8;
      }
      pQVar1 = (QChar *)(*pauVar13 + local_c8);
      local_c8 = local_c8 + 1;
      *pQVar1 = local_158[0];
      (*pauVar13)[sVar20 + 1] = '\0';
    }
    else {
      if (local_c8 == 0x7fffffffffffffff) goto LAB_140017a29;
      uVar19 = local_c8 + 1 | 0xf;
      if (uVar19 < 0x8000000000000000) {
        if (0x7fffffffffffffff - (local_c0 >> 1) < local_c0) {
          uVar19 = 0x7fffffffffffffff;
        }
        else {
          uVar2 = local_c0 + (local_c0 >> 1);
          if (uVar19 < uVar2) {
            uVar19 = uVar2;
          }
        }
      }
      else {
        uVar19 = 0x7fffffffffffffff;
      }
      pauVar10 = (undefined1 (*) [32])FUN_1400076d0(uVar19 + 1);
      pauVar13 = local_d8;
      local_c8 = sVar20 + 1;
      local_c0 = uVar19;
      if (uVar8 < 0x10) {
        memcpy(pauVar10,&local_d8,sVar20);
        *(QChar *)(*pauVar10 + sVar20) = local_158[0];
        (*pauVar10)[sVar20 + 1] = '\0';
        local_d8 = pauVar10;
      }
      else {
        memcpy(pauVar10,local_d8,sVar20);
        *(QChar *)(*pauVar10 + sVar20) = local_158[0];
        (*pauVar10)[sVar20 + 1] = '\0';
        pauVar12 = pauVar13;
        if ((0xfff < uVar8 + 1) &&
           (pauVar12 = *(undefined1 (**) [32])(pauVar13[-1] + 0x18),
           (char *)0x1f < (char *)((longlong)pauVar13 + (-8 - (longlong)pauVar12))))
        goto LAB_1400174e5;
        free(pauVar12);
        local_d8 = pauVar10;
      }
    }
    uVar22 = uVar22 + 1;
  } while ((longlong)uVar22 < 0x19);
  local_a8 = (void *)0x0;
  local_b8 = (undefined8 ******)((ulonglong)local_b8 & 0xffffffffffffff00);
  local_148 = 8;
  pvVar15 = local_a0;
  do {
    _Size = local_a8;
    _Src = local_b8;
    cVar21 = *(char *)((longlong)&local_78 + local_148 + 6) + '0';
    if (local_a8 < pvVar15) {
      pppppppuVar11 = &local_b8;
      if ((void *)0xf < pvVar15) {
        pppppppuVar11 = (undefined8 *******)local_b8;
      }
      pcVar16 = (char *)((longlong)pppppppuVar11 + (longlong)local_a8);
      local_a8 = (void *)((longlong)local_a8 + 1);
      *pcVar16 = cVar21;
      *(undefined1 *)((longlong)pppppppuVar11 + 1 + (longlong)_Size) = 0;
      pvVar17 = local_a0;
    }
    else {
      if (local_a8 == (void *)0x7fffffffffffffff) goto LAB_140017a29;
      pvVar17 = (void *)((longlong)local_a8 + 1U | 0xf);
      if (pvVar17 < (void *)0x8000000000000000) {
        if ((void *)(0x7fffffffffffffff - ((ulonglong)pvVar15 >> 1)) < pvVar15) {
          pvVar17 = (void *)0x7fffffffffffffff;
        }
        else {
          pvVar3 = (void *)((longlong)pvVar15 + ((ulonglong)pvVar15 >> 1));
          if (pvVar17 < pvVar3) {
            pvVar17 = pvVar3;
          }
        }
      }
      else {
        pvVar17 = (void *)0x7fffffffffffffff;
      }
      local_150 = pvVar15;
      pppppppuVar11 = (undefined8 *******)FUN_1400076d0((longlong)pvVar17 + 1);
      local_a8 = (void *)((longlong)_Size + 1);
      local_a0 = pvVar17;
      if (local_150 < (void *)0x10) {
        memcpy(pppppppuVar11,&local_b8,(size_t)_Size);
        *(char *)((longlong)_Size + (longlong)pppppppuVar11) = cVar21;
        *(undefined1 *)((longlong)_Size + 1 + (longlong)pppppppuVar11) = 0;
        local_b8 = pppppppuVar11;
      }
      else {
        memcpy(pppppppuVar11,_Src,(size_t)_Size);
        *(char *)((longlong)_Size + (longlong)pppppppuVar11) = cVar21;
        *(undefined1 *)((longlong)_Size + 1 + (longlong)pppppppuVar11) = 0;
        pppppppuVar24 = (undefined8 *******)_Src;
        if ((0xfff < (longlong)local_150 + 1U) &&
           (pppppppuVar24 = (undefined8 *******)_Src[-1],
           0x1f < (ulonglong)((longlong)_Src + (-8 - (longlong)pppppppuVar24)))) {
LAB_1400174e5:
                    /* WARNING: Subroutine does not return */
          _invoke_watson((wchar_t *)0x0,(wchar_t *)0x0,(wchar_t *)0x0,0,0);
        }
        free(pppppppuVar24);
        local_b8 = pppppppuVar11;
      }
    }
    pppppppuVar11 = (undefined8 *******)local_b8;
    local_148 = local_148 + 1;
    pvVar15 = pvVar17;
  } while ((longlong)local_148 < 0x1c);
  pauVar13 = (undefined1 (*) [32])&local_d8;
  if (0xf < local_c0) {
    pauVar13 = local_d8;
  }
  if ((local_c8 == 0) ||
     (pauVar10 = (undefined1 (*) [32])(*pauVar13 + local_c8),
     pauVar12 = thunk_FUN_14001abd0(pauVar13,pauVar10,(undefined1 (*) [16])&DAT_140025c40,1),
     pauVar12 == pauVar10)) {
    iVar4 = -1;
  }
  else {
    iVar4 = (int)pauVar12 - (int)pauVar13;
  }
  if (iVar4 == -1) {
    cVar21 = '\x01';
    param_1 = local_130;
  }
  else {
    local_78 = (void *)0x0;
    uStack_70 = 0;
    local_68 = 0;
    uStack_60 = 0;
    uVar8 = (ulonglong)iVar4;
    uVar22 = uVar8;
    if (local_c8 < uVar8) {
      uVar22 = local_c8;
    }
    local_140 = (undefined1 (*) [32])&local_d8;
    if (0xf < local_c0) {
      local_140 = local_d8;
    }
    local_148 = uVar8;
    if (0x7fffffffffffffff < uVar22) {
                    /* WARNING: Subroutine does not return */
      FUN_1400087e0();
    }
    if (uVar22 < 0x10) {
      uStack_60 = 0xf;
      local_68 = uVar22;
      memcpy(&local_78,local_140,uVar22);
      *(undefined1 *)((longlong)&local_78 + uVar22) = 0;
    }
    else {
      uVar8 = uVar22 | 0xf;
      if (uVar8 < 0x8000000000000000) {
        if (uVar8 < 0x16) {
          uVar8 = 0x16;
        }
      }
      else {
        uVar8 = 0x7fffffffffffffff;
      }
      local_150 = (void *)FUN_1400076d0(uVar8 + 1);
      local_78 = local_150;
      local_68 = uVar22;
      uStack_60 = uVar8;
      memcpy(local_150,local_140,uVar22);
      *(undefined1 *)((longlong)local_150 + uVar22) = 0;
      uVar8 = local_148;
    }
    pQVar7 = (QString *)
             QString::fromStdString
                       ((basic_string<char,std::char_traits<char>,std::allocator<char>_> *)local_f8)
    ;
    QString::operator=((QString *)(local_130 + 0x2caa0),pQVar7);
    QString::~QString(local_f8);
    if (0xf < uStack_60) {
      pvVar15 = local_78;
      if ((0xfff < uStack_60 + 1) &&
         (pvVar15 = *(void **)((longlong)local_78 + -8),
         0x1f < (ulonglong)((longlong)local_78 + (-8 - (longlong)pvVar15)))) {
                    /* WARNING: Subroutine does not return */
        _invoke_watson((wchar_t *)0x0,(wchar_t *)0x0,(wchar_t *)0x0,0,0);
      }
      free(pvVar15);
    }
    uVar8 = uVar8 + 1;
    local_98 = (undefined1 (*) [32])0x0;
    uStack_90 = 0;
    local_88 = 0;
    uStack_80 = 0;
    if (local_c8 < uVar8) {
      FUN_140016a90();
LAB_140017a0a:
                    /* WARNING: Subroutine does not return */
      FUN_1400087e0();
    }
    sVar20 = local_c8;
    if (local_c8 - uVar8 < local_c8) {
      sVar20 = local_c8 - uVar8;
    }
    pauVar13 = (undefined1 (*) [32])&local_d8;
    if (0xf < local_c0) {
      pauVar13 = local_d8;
    }
    local_140 = (undefined1 (*) [32])(*pauVar13 + uVar8);
    if (0x7fffffffffffffff < sVar20) goto LAB_140017a0a;
    if (sVar20 < 0x10) {
      uStack_80 = 0xf;
      local_88 = sVar20;
      memcpy(&local_98,local_140,sVar20);
      *(undefined1 *)((longlong)&local_98 + sVar20) = 0;
    }
    else {
      uVar22 = sVar20 | 0xf;
      uVar8 = 0x7fffffffffffffff;
      if ((uVar22 < 0x8000000000000000) && (uVar8 = uVar22, uVar22 < 0x16)) {
        uVar8 = 0x16;
      }
      pauVar13 = (undefined1 (*) [32])FUN_1400076d0(uVar8 + 1);
      local_98 = pauVar13;
      local_88 = sVar20;
      uStack_80 = uVar8;
      memcpy(pauVar13,local_140,sVar20);
      (*pauVar13)[sVar20] = '\0';
    }
    piVar14 = _errno();
    pauVar13 = (undefined1 (*) [32])&local_98;
    if (0xf < uStack_80) {
      pauVar13 = local_98;
    }
    *piVar14 = 0;
    lVar5 = strtol((char *)pauVar13,(char **)&local_140,10);
    param_1 = local_130;
    if (pauVar13 == local_140) {
      std::_Xinvalid_argument("invalid stoi argument");
LAB_140017a1c:
      std::_Xout_of_range("stoi argument out of range");
LAB_140017a29:
                    /* WARNING: Subroutine does not return */
      FUN_1400087e0();
    }
    if (*piVar14 == 0x22) goto LAB_140017a1c;
    *(long *)(local_130 + 0x2cab8) = lVar5;
    if (0xf < uStack_80) {
      pauVar13 = local_98;
      if ((0xfff < uStack_80 + 1) &&
         (pauVar13 = *(undefined1 (**) [32])(local_98[-1] + 0x18),
         (char *)0x1f < (char *)((longlong)local_98 + (-8 - (longlong)pauVar13)))) {
                    /* WARNING: Subroutine does not return */
        _invoke_watson((wchar_t *)0x0,(wchar_t *)0x0,(wchar_t *)0x0,0,0);
      }
      free(pauVar13);
    }
    cVar21 = '\x01';
  }
LAB_14001792c:
  if ((void *)0xf < pvVar17) {
    pppppppuVar24 = pppppppuVar11;
    if ((0xfff < (longlong)pvVar17 + 1U) &&
       (pppppppuVar24 = (undefined8 *******)pppppppuVar11[-1],
       0x1f < (ulonglong)((longlong)pppppppuVar11 + (-8 - (longlong)pppppppuVar24)))) {
                    /* WARNING: Subroutine does not return */
      _invoke_watson((wchar_t *)0x0,(wchar_t *)0x0,(wchar_t *)0x0,0,0);
    }
    free(pppppppuVar24);
  }
  if (0xf < local_c0) {
    pauVar13 = local_d8;
    if ((0xfff < local_c0 + 1) &&
       (pauVar13 = *(undefined1 (**) [32])((longlong)local_d8[-1] + 0x18),
       (char *)0x1f < (char *)((longlong)local_d8 + (-8 - (longlong)pauVar13)))) {
                    /* WARNING: Subroutine does not return */
      _invoke_watson((wchar_t *)0x0,(wchar_t *)0x0,(wchar_t *)0x0,0,0);
    }
    free(pauVar13);
  }
  if (cVar21 != '\0') {
    return cVar21;
  }
LAB_1400179d0:
  FUN_140018250(param_1);
  return '\0';
}


/* FUN_140017a30 @ 140017a30 */

ulonglong FUN_140017a30(longlong param_1,undefined1 param_2,void *param_3,undefined4 param_4,
                       uint param_5)

{
  undefined4 extraout_var;
  ulonglong uVar1;
  uint local_res8 [2];
  
  local_res8[0] =
       FUN_140017b20(param_1,(undefined2 *)(param_1 + 0x1c898),param_2,param_4,param_3,param_5);
  if (local_res8[0] != 0) {
    uVar1 = FUN_140018140(param_1,(byte *)(param_1 + 0x1c898),local_res8[0],local_res8,'\x01');
    return uVar1;
  }
  return CONCAT44(extraout_var,local_res8[0]) & 0xffffffffffffff00;
}


/* FUN_140017b20 @ 140017b20 */

int FUN_140017b20(undefined8 param_1,undefined2 *param_2,undefined1 param_3,undefined4 param_4,
                 void *param_5,uint param_6)

{
  char cVar1;
  int iVar2;
  byte bVar3;
  char *pcVar4;
  byte *pbVar5;
  undefined1 uStackX_1a;
  
  *param_2 = DAT_14013a000;
  *(undefined1 *)(param_2 + 1) = 0x30;
  *(short *)((longlong)param_2 + 3) = (short)(param_6 + 8);
  uStackX_1a = (undefined1)(param_6 + 8 >> 0x10);
  *(undefined1 *)((longlong)param_2 + 5) = uStackX_1a;
  *(undefined1 *)(param_2 + 3) = param_3;
  *(undefined4 *)((longlong)param_2 + 7) = param_4;
  *(short *)((longlong)param_2 + 0xb) = (short)param_6;
  *(undefined1 *)((longlong)param_2 + 0xd) = param_6._2_1_;
  memcpy(param_2 + 7,param_5,(ulonglong)param_6);
  pbVar5 = (byte *)((longlong)(param_2 + 7) + (ulonglong)param_6);
  pcVar4 = (char *)(param_2 + 3);
  iVar2 = ((int)pbVar5 - (int)param_2) + -6;
  if (iVar2 != 0) {
    bVar3 = 0;
    do {
      cVar1 = *pcVar4;
      pcVar4 = pcVar4 + 1;
      bVar3 = bVar3 + cVar1;
      iVar2 = iVar2 + -1;
    } while (iVar2 != 0);
    *pbVar5 = ~bVar3;
    pbVar5 = (byte *)(ulonglong)((int)pbVar5 + 1);
  }
  return (int)pbVar5 - (int)param_2;
}


/* FUN_140017cb0 @ 140017cb0 */

bool FUN_140017cb0(undefined8 param_1,char *param_2,int param_3,byte param_4)

{
  char cVar1;
  byte bVar2;
  
  if (param_3 == 0) {
    return true;
  }
  bVar2 = 0;
  do {
    cVar1 = *param_2;
    param_2 = param_2 + 1;
    bVar2 = bVar2 + cVar1;
    param_3 = param_3 + -1;
  } while (param_3 != 0);
  if ((byte)~bVar2 != param_4) {
    FUN_140008d80("Checksum error,calc=%.2X, got=%.2X");
  }
  return param_4 == (byte)~bVar2;
}


/* FUN_140018060 @ 140018060 */

/* WARNING: Function: __security_check_cookie replaced with injection: security_check_cookie */

ulonglong FUN_140018060(longlong param_1,longlong param_2,uint param_3,int *param_4,int param_5)

{
  uint uVar1;
  ulonglong uVar2;
  longlong *plVar3;
  longlong *extraout_RAX;
  void *_Memory;
  undefined1 auStackY_78 [32];
  void *local_40 [3];
  ulonglong local_28;
  ulonglong local_20;
  
  local_20 = DAT_14013adc0 ^ (ulonglong)auStackY_78;
  uVar1 = *(uint *)(param_1 + 0xc868);
  plVar3 = (longlong *)(ulonglong)uVar1;
  if (uVar1 != 3) {
    uVar2 = (ulonglong)(uVar1 - 1);
    if (uVar1 - 1 < 2) {
      uVar2 = FUN_1400088d0(param_1 + 0x10,param_2,param_3,param_5);
      *param_4 = (int)uVar2;
    }
    if (*param_4 != 0) {
      return CONCAT71((int7)(uVar2 >> 8),1);
    }
    FUN_140009890(local_40,(undefined8 *)(param_1 + 0xc840));
    plVar3 = FUN_14000a9a0((longlong *)(param_1 + 0xc870),(longlong *)local_40);
    if (0xf < local_28) {
      _Memory = local_40[0];
      if ((0xfff < local_28 + 1) &&
         (_Memory = *(void **)((longlong)local_40[0] + -8),
         0x1f < (ulonglong)((longlong)local_40[0] + (-8 - (longlong)_Memory)))) {
                    /* WARNING: Subroutine does not return */
        _invoke_watson((wchar_t *)0x0,(wchar_t *)0x0,(wchar_t *)0x0,0,0);
      }
      free(_Memory);
      plVar3 = extraout_RAX;
    }
  }
  return (ulonglong)plVar3 & 0xffffffffffffff00;
}


/* FUN_140018140 @ 140018140 */

/* WARNING: Function: __security_check_cookie replaced with injection: security_check_cookie */

ulonglong FUN_140018140(longlong param_1,byte *param_2,uint param_3,uint *param_4,char param_5)

{
  uint uVar1;
  longlong *plVar2;
  ulonglong uVar3;
  undefined4 extraout_var;
  longlong *extraout_RAX;
  void *_Memory;
  undefined1 auStackY_88 [32];
  void *local_50 [3];
  ulonglong local_38;
  longlong *local_30;
  
  plVar2 = (longlong *)(DAT_14013adc0 ^ (ulonglong)auStackY_88);
  if (*(int *)(param_1 + 0xc868) != 3) {
    local_30 = plVar2;
    if (param_5 != '\0') {
      FUN_140008800(param_1 + 0x10);
    }
    uVar1 = *(uint *)(param_1 + 0xc868);
    uVar3 = (ulonglong)uVar1;
    if ((uVar1 == 1) || (uVar1 == 2)) {
      uVar1 = FUN_140008b50((undefined1 *)(param_1 + 0x10),param_2,param_3);
      uVar3 = CONCAT44(extraout_var,uVar1);
      *param_4 = uVar1;
    }
    if (*param_4 == param_3) {
      return CONCAT71((int7)(uVar3 >> 8),1);
    }
    FUN_140009890(local_50,(undefined8 *)(param_1 + 0xc840));
    plVar2 = FUN_14000a9a0((longlong *)(param_1 + 0xc870),(longlong *)local_50);
    if (0xf < local_38) {
      _Memory = local_50[0];
      if ((0xfff < local_38 + 1) &&
         (_Memory = *(void **)((longlong)local_50[0] + -8),
         0x1f < (ulonglong)((longlong)local_50[0] + (-8 - (longlong)_Memory)))) {
                    /* WARNING: Subroutine does not return */
        _invoke_watson((wchar_t *)0x0,(wchar_t *)0x0,(wchar_t *)0x0,0,0);
      }
      free(_Memory);
      plVar2 = extraout_RAX;
    }
  }
  return (ulonglong)plVar2 & 0xffffffffffffff00;
}


/* FUN_140018250 @ 140018250 */

void FUN_140018250(longlong param_1)

{
  FUN_140008810(param_1 + 0x10);
  *(undefined4 *)(param_1 + 0xc868) = 3;
  return;
}


/* FUN_140018360 @ 140018360 */

/* WARNING: Function: __security_check_cookie replaced with injection: security_check_cookie */

ulonglong FUN_140018360(longlong param_1,void *param_2,uint param_3,char param_4)

{
  uint uVar1;
  uint uVar2;
  longlong *plVar3;
  ulonglong uVar4;
  undefined4 extraout_var;
  longlong *extraout_RAX;
  void *_Memory;
  undefined1 auStackY_88 [32];
  void *local_50 [3];
  ulonglong local_38;
  longlong *local_30;
  
  plVar3 = (longlong *)(DAT_14013adc0 ^ (ulonglong)auStackY_88);
  if (*(int *)(param_1 + 0xc868) != 3) {
    uVar2 = 0;
    local_30 = plVar3;
    if (param_4 != '\0') {
      FUN_140008800(param_1 + 0x10);
    }
    uVar1 = *(uint *)(param_1 + 0xc868);
    uVar4 = (ulonglong)uVar1;
    if ((uVar1 == 1) || (uVar1 == 2)) {
      uVar2 = FUN_140008b70((void *)(param_1 + 0x10),param_2,param_3);
      uVar4 = CONCAT44(extraout_var,uVar2);
    }
    if (uVar2 == param_3) {
      return CONCAT71((int7)(uVar4 >> 8),1);
    }
    FUN_140009890(local_50,(undefined8 *)(param_1 + 0xc840));
    plVar3 = FUN_14000a9a0((longlong *)(param_1 + 0xc870),(longlong *)local_50);
    if (0xf < local_38) {
      _Memory = local_50[0];
      if ((0xfff < local_38 + 1) &&
         (_Memory = *(void **)((longlong)local_50[0] + -8),
         0x1f < (ulonglong)((longlong)local_50[0] + (-8 - (longlong)_Memory)))) {
                    /* WARNING: Subroutine does not return */
        _invoke_watson((wchar_t *)0x0,(wchar_t *)0x0,(wchar_t *)0x0,0,0);
      }
      free(_Memory);
      plVar3 = extraout_RAX;
    }
  }
  return (ulonglong)plVar3 & 0xffffffffffffff00;
}
