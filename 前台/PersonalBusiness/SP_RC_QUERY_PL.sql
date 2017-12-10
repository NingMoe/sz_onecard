CREATE OR REPLACE PROCEDURE SP_RC_QUERY
(                                       P_FUNCCODE VARCHAR2,
                                        P_VAR1     VARCHAR2,
                                        P_VAR2     VARCHAR2,
                                        P_VAR3     VARCHAR2,
                                        P_VAR4     VARCHAR2,
                                        P_VAR5     VARCHAR2,
                                        P_VAR6     VARCHAR2,
                                        P_VAR7     VARCHAR2,
                                        P_VAR8     VARCHAR2,
                                        P_VAR9     VARCHAR2,
                                        P_CURSOR   OUT SYS_REFCURSOR) AS
  V_SQL VARCHAR2(1000);
BEGIN
  IF P_FUNCCODE = 'QureyUserInfoChangeSync' THEN
    OPEN P_CURSOR FOR
      SELECT TRADEID,TRANS_CODE,CITIZEN_CARD_NO,NAME,PAPER_TYPE,PAPER_NO,OLD_NAME,OLD_PAPER_TYPE,OLD_PAPER_NO,CARD_TYPE
        FROM tf_b_sync
        WHERE TRADEID = P_VAR1
         AND CITIZEN_CARD_NO =P_VAR2
         AND SYNCSYSCODE='SZZJG';
         
  ELSIF P_FUNCCODE = 'QueryCardSaleInfoSync' THEN
    OPEN P_CURSOR FOR
       SELECT TRADEID,TRANS_CODE,CITIZEN_CARD_NO,NAME,PAPER_TYPE,PAPER_NO,SEX,CARD_TYPE
        FROM tf_b_sync
        WHERE TRADEID = P_VAR1
         AND CITIZEN_CARD_NO =P_VAR2
         AND SYNCSYSCODE='SZZJG';
         
  ELSIF P_FUNCCODE = 'QueryCardSaleRollbackInfoSync' THEN
    OPEN P_CURSOR FOR
       SELECT TRADEID,TRANS_CODE,CITIZEN_CARD_NO,NAME,PAPER_TYPE,PAPER_NO,CARD_TYPE
        FROM tf_b_sync
        WHERE TRADEID = P_VAR1
         AND CITIZEN_CARD_NO =P_VAR2
         AND SYNCSYSCODE='SZZJG';

  ELSIF P_FUNCCODE = 'QueryCardReturnInfoSync' THEN
    OPEN P_CURSOR FOR
       SELECT TRADEID,TRANS_CODE,CITIZEN_CARD_NO,NAME,PAPER_TYPE,PAPER_NO
        FROM tf_b_sync
       WHERE TRADEID = P_VAR1
         AND CITIZEN_CARD_NO =P_VAR2
         AND SYNCSYSCODE='SZZJG';
         
  ELSIF P_FUNCCODE = 'QueryCardReturnRollbackInfoSync' THEN
    OPEN P_CURSOR FOR
       SELECT TRADEID,TRANS_CODE,CITIZEN_CARD_NO,NAME,PAPER_TYPE,PAPER_NO,CARD_TYPE
        FROM tf_b_sync
       WHERE TRADEID = P_VAR1
         AND CITIZEN_CARD_NO =P_VAR2
         AND SYNCSYSCODE='SZZJG';
    
  ELSIF P_FUNCCODE = 'QueryCardChangeInfoSync' THEN
    OPEN P_CURSOR FOR
       SELECT TRADEID,TRANS_CODE,CITIZEN_CARD_NO,OLD_CARD_NO,NAME,PAPER_TYPE,PAPER_NO
        FROM tf_b_sync
       WHERE TRADEID = P_VAR1
         AND CITIZEN_CARD_NO =P_VAR2
         AND SYNCSYSCODE='SZZJG';
         
  ELSIF P_FUNCCODE = 'QueryCardChangeRollbackInfoSync' THEN
    OPEN P_CURSOR FOR
       SELECT TRADEID,TRANS_CODE,CITIZEN_CARD_NO,OLD_CARD_NO,NAME,PAPER_TYPE,PAPER_NO,CARD_TYPE
        FROM tf_b_sync
       WHERE TRADEID = P_VAR1
         AND CITIZEN_CARD_NO =P_VAR2
         AND SYNCSYSCODE='SZZJG';
         
  ELSIF P_FUNCCODE = 'QureyExceptionSync' THEN
    OPEN P_CURSOR FOR
       SELECT a.TRANS_CODE,a.TRADEID,a.CITIZEN_CARD_NO,a.syncsystradeid,a.NAME,
       (select b.papertypename from td_m_papertype b where a.paper_type=b.papertypecode(+)) NEWPAPERTYPENAME,
       a.paper_no,a.syncerrinfo,a.synctime,a.operatetime, a.old_card_no,a.old_name,
       (select b.papertypename from td_m_papertype b where a.old_paper_type=b.papertypecode(+)) OLDPAPERTYPENAME,a.old_paper_no        
         FROM tf_b_sync a
         WHERE (P_VAR1 IS NULL OR P_VAR1 = TRANS_CODE)
          AND (P_VAR2 IS NULL OR P_VAR2 = NAME)
          AND (P_VAR3 IS NULL OR P_VAR3 = PAPER_TYPE)
          AND (P_VAR4 IS NULL OR P_VAR4 = PAPER_NO)
          AND (P_VAR5 IS NULL OR P_VAR5 = SYNCCODE)
          order by a.OPERATETIME desc,a.synctime desc;
          
  ELSIF P_FUNCCODE = 'QureyExceptionNotSync' THEN
    OPEN P_CURSOR FOR
       SELECT a.TRANS_CODE,a.TRADEID,a.CITIZEN_CARD_NO,a.syncsystradeid,a.NAME,
       (select b.papertypename from td_m_papertype b where a.paper_type=b.papertypecode(+)) NEWPAPERTYPENAME,
       a.paper_no,a.syncerrinfo,a.synctime,a.operatetime,a.old_card_no,a.old_name,
       (select b.papertypename from td_m_papertype b where a.old_paper_type=b.papertypecode(+)) OLDPAPERTYPENAME,a.old_paper_no        
         FROM tf_b_sync a
         WHERE (P_VAR1 IS NULL OR P_VAR1 = TRANS_CODE)
          AND (P_VAR2 IS NULL OR P_VAR2 = NAME)
          AND (P_VAR3 IS NULL OR P_VAR3 = PAPER_TYPE)
          AND (P_VAR4 IS NULL OR P_VAR4 = PAPER_NO)
          AND SYNCCODE IS NULL 
          order by a.OPERATETIME desc,a.synctime desc;

  ELSIF P_FUNCCODE = 'QureySync' THEN
    --根据业务流水号，卡号，同步系统编号 查询同步台帐子表
     OPEN P_CURSOR FOR
      SELECT A.*
        FROM TF_B_SYNC A
       WHERE TRADEID = P_VAR1
         AND CITIZEN_CARD_NO = P_VAR2
         AND SYNCSYSCODE=P_VAR3;
  END IF;
END;
/
show errors