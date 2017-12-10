CREATE OR REPLACE PROCEDURE SP_SD_AutoReverseRecycle
(
    p_sessionID         VARCHAR2,
    p_REMARK            VARCHAR2,
	p_balType           VARCHAR2,
    p_currOper	        CHAR,
    p_currDept	        CHAR,
    p_retCode           OUT CHAR,
    p_retMsg            OUT VARCHAR2
)
AS
    V_ID           CHAR(18);
    V_CARDNO       CHAR(16);
    V_TRADEMONEY   INT;
    V_TODAY        DATE := SYSDATE;
    V_CARDACCMONEY INT;
    V_CARDTRADENO  CHAR(4);
    v_ex           EXCEPTION;
	V_BALUNITNO		CHAR(8);
	v_TradeID      char(16);
BEGIN
  FOR cur_renewdata IN ( 
      SELECT f0,f1,f2 FROM tmp_common t WHERE f3 = p_sessionID ) LOOP        
      
      V_ID         := cur_renewdata.f0;
      V_CARDNO     := cur_renewdata.f1;
      V_TRADEMONEY := cur_renewdata.f2;
      
      --���¶������ֵд�����˱�
      BEGIN
        UPDATE TF_OUTSUPPLY_ADJUST
        SET    DEALSTATECODE = '3'
        WHERE  ID = V_ID;
      
      IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
          EXCEPTION
            WHEN OTHERS THEN
              p_retCode := 'S094570030';
              p_retMsg  := '���¶������ֵд�����˱�ʧ��';
              ROLLBACK; RETURN;      
      END;
      
      --��ȡ����ʱIC�������к� ,����ǰ����������
      BEGIN
        SELECT CARDACCMONEY   , ONLINECARDTRADENO
        INTO   V_CARDACCMONEY , V_CARDTRADENO
        FROM   TF_F_CARDEWALLETACC
        WHERE  CARDNO = V_CARDNO;
      EXCEPTION
				    WHEN NO_DATA_FOUND THEN
				    p_retCode := 'S094570033';
				    p_retMsg  := 'û�в�ѯ����Ӧ��IC������Ǯ���˻����¼';
				    ROLLBACK; RETURN;
      END;    
    
      --����IC������Ǯ���˻���
      BEGIN
        UPDATE TF_F_CARDEWALLETACC
			SET  CARDACCMONEY = CARDACCMONEY + V_TRADEMONEY,         
		        TOTALSUPPLYTIMES = TOTALSUPPLYTIMES + 1,         
		        TOTALSUPPLYMONEY = TOTALSUPPLYMONEY + V_TRADEMONEY
		    WHERE  CARDNO = V_CARDNO;
      
      IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
          EXCEPTION
            WHEN OTHERS THEN
              p_retCode := 'S094570031';
              p_retMsg  := '����IC������Ǯ���˻���ʧ��';
              ROLLBACK; RETURN;      
      END;
      
      --��¼�������ֵд������̨�˱�
      BEGIN
        INSERT INTO TF_B_OUTSUPPLY_ADJUST(
            ID                             , ADJUSTID     , CARDNO               , 
            ASN            , CARDTRADENO   , CARDTYPECODE , TRADEDATE            ,
            TRADETIME      , TRADEMONEY    , PREMONEY     , PREADJUSTCARDTRADENO ,
            PREADJUSTMONEY , SUPPLYLOCNO   , SAMNO        , POSNO                ,
            STAFFNO        , TAC           , TRADEID      , BANKCARDNO           ,
            TACSTATE       , BATCHNO       , SUPPLYCOMFEE , BALUNITNO            ,
            CALLINGNO      , CORPNO        , DEPARTNO     , DEALTIME             ,
            TRADESTATECODE , DEALSTATECODE , RSRVCHAR2    , OPERATESTAFFNO
       )SELECT 
            TF_B_OUTSUPPLY_ADJUST_SEQ.NEXTVAL , ID           , CARDNO               , 
            ASN            , CARDTRADENO      , CARDTYPECODE , TRADEDATE            ,
            TRADETIME      , TRADEMONEY       , PREMONEY     , V_CARDTRADENO        ,
            V_CARDACCMONEY , SUPPLYLOCNO      , SAMNO        , POSNO                ,
            STAFFNO        , TAC              , TRADEID      , BANKCARDNO           ,
            TACSTATE       , BATCHNO          , SUPPLYCOMFEE , BALUNITNO            ,
            CALLINGNO      , CORPNO           , DEPARTNO     , V_TODAY              ,
            TRADESTATECODE , '2'              , p_REMARK     , p_currOper
      FROM  TF_OUTSUPPLY_ADJUST
      WHERE ID = V_ID;
      IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
          EXCEPTION
            WHEN OTHERS THEN
              p_retCode := 'S094570032';
              p_retMsg  := '��¼�������ֵд������̨�˱�ʧ��';
              ROLLBACK; RETURN;            
      END;
      
	  IF p_balType = '0'  THEN --����Ǵ����̻�������Ԥ�������
		--д��Ԥ����̨��
		
		SELECT BALUNITNO INTO V_BALUNITNO FROM  TF_OUTSUPPLY_ADJUST WHERE ID = V_ID; 
		
		BEGIN
			SP_GetSeq(seq => v_TradeID);
			INSERT INTO TF_B_DEPTACCTRADE                              
						(TRADEID, TRADETYPECODE, DBALUNITNO,                         
						CURRENTMONEY, PREMONEY, NEXTMONEY,                         
						OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME, CANCELTAG)                        
			SELECT   	v_TradeID, '21', P.DBALUNITNO,                         
						- V_TRADEMONEY, P.PREPAY, P.PREPAY - V_TRADEMONEY,                         
						p_currOper, p_currDept, V_TODAY, '0'                      
			FROM        TF_F_DEPTBAL_PREPAY P                        
			WHERE       P.DBALUNITNO = V_BALUNITNO                         
						AND P.ACCSTATECODE = '01';    
		EXCEPTION
			  WHEN OTHERS THEN
				  p_retCode := 'S094570901';
				  p_retMsg  := 'д��Ԥ�������̨��ʧ��';
				  ROLLBACK; RETURN;
		END;
		
		----����Ԥ�������
		BEGIN
	
			UPDATE  TF_F_DEPTBAL_PREPAY P                          
			SET     P.PREPAY = P.PREPAY - V_TRADEMONEY,                          
					P.UPDATESTAFFNO = p_currOper,                          
					P.UPDATETIME = V_TODAY                          
			WHERE   P.DBALUNITNO = V_BALUNITNO                           
					AND P.ACCSTATECODE = '01' AND P.PREPAY - V_TRADEMONEY >= 0;    
			  
			IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;    
		EXCEPTION
			  WHEN OTHERS THEN
				  p_retCode := 'S094570902';
				  p_retMsg  := '����Ԥ�����˻�ʧ�ܣ�����Ԥ�����˻�����Ƿ���';
				  ROLLBACK; RETURN;
		END;
	  
	END IF;
	  
    END LOOP;
     p_retCode := '0000000000';
     p_retMsg  := '';
     COMMIT; RETURN;
END;

/
show errors            