CREATE OR REPLACE PROCEDURE SP_PS_BalDepositManger
(
    P_FUNCCODE        VARCHAR2 ,  --���ܱ���
    P_MONEY           INT      ,  --�������
    P_CHMONEY         VARCHAR2 ,  --��д���
    P_REMARK          VARCHAR2 ,  --��ע
    P_DBALUNITNO      VARCHAR2 ,  --������㵥Ԫ����
    P_CURROPER        CHAR     ,
    P_CURRDEPT        CHAR     ,
    P_RETCODE     OUT CHAR     ,
    P_RETMSG      OUT VARCHAR2
)
AS
    V_FUNCCODE        VARCHAR2(16) := P_FUNCCODE ;
    V_TODAY           DATE         := SYSDATE    ;
    V_SEQ             VARCHAR2(16)               ;
    V_EX              EXCEPTION                  ;
    V_USABLEVALUE     INT                        ;
    V_DEPOSIT       int;
    v_cardnum       int;
    V_CARDPRICE     int;
    
BEGIN
	--����
	IF V_FUNCCODE = 'INCOME' THEN  
	BEGIN
		SP_GETSEQ(SEQ => V_SEQ); --��ȡҵ����ˮ��
		--��¼Ԥ���֤��ҵ��̨����˱�
		INSERT INTO TF_B_DEPTACC_EXAM(
		    ID              , TRADETYPECODE    , DBALUNITNO   , CURRENTMONEY   ,
		    CHINESEMONEY    ,
		    OPERATESTAFFNO  , OPERATEDEPARTID  , OPERATETIME  , STATECODE      ,
		    REMARK
	 )VALUES(
	      V_SEQ           , '01'             , P_DBALUNITNO , P_MONEY        ,
	      P_CHMONEY       ,
	      P_CURROPER      , P_CURRDEPT       , V_TODAY      , '1'            ,
	      P_REMARK
	      );
    EXCEPTION WHEN OTHERS THEN
        P_RETCODE := 'S008905011';
        P_RETMSG  := '��¼Ԥ���֤��ҵ��̨����˱�'||SQLERRM;
        ROLLBACK;RETURN;
  END;		
  END IF;
  
	--֧��
	IF V_FUNCCODE = 'PAY' THEN  
	  --�����Ƿ��֧�����
	  --��ȡ���п�
    select count(*) into v_cardnum from TL_R_ICUSER a
    where exists (select * from  TD_DEPTBAL_RELATION b where a.assigneddepartid=b.departno and b.dbalunitno = P_DBALUNITNO)
    and a.RESSTATECODE IN('01','05');
    --��ȡ�û�����ֵ
    SELECT TAGVALUE INTO V_CARDPRICE FROM TD_M_TAG WHERE TAGCODE='USERCARD_MONEY'; 
    --��ȡ��֤�����
    SELECT DEPOSIT INTO V_DEPOSIT FROM TF_F_DEPTBAL_DEPOSIT WHERE ACCSTATECODE='01' AND DBALUNITNO = P_DBALUNITNO; 
    --������쿨��ֵ���
    V_USABLEVALUE := V_DEPOSIT - v_cardnum*V_CARDPRICE;
    --���֧��������Ԥ�����������ʾ����
    IF P_MONEY > V_USABLEVALUE THEN
        P_RETCODE := 'S008905004';
        P_RETMSG  := '֧�����ܴ��ڿ��쿨��ֵ���';
        ROLLBACK;RETURN; 
    ELSE--���֧��������Ԥ���������ִ��		
    BEGIN
		SP_GETSEQ(SEQ => V_SEQ); --��ȡҵ����ˮ��
		--��¼Ԥ���֤��ҵ��̨����˱�
		INSERT INTO TF_B_DEPTACC_EXAM(
		    ID              , TRADETYPECODE    , DBALUNITNO   , CURRENTMONEY   ,
		    CHINESEMONEY    ,
		    OPERATESTAFFNO  , OPERATEDEPARTID  , OPERATETIME  , STATECODE      ,
		    REMARK
	 )VALUES(
	      V_SEQ           , '02'             , P_DBALUNITNO , P_MONEY        ,
	      P_CHMONEY       ,
	      P_CURROPER      , P_CURRDEPT       , V_TODAY      , '1'            ,
	      P_REMARK
	      );
    EXCEPTION WHEN OTHERS THEN
        P_RETCODE := 'S008905011';
        P_RETMSG  := '��¼Ԥ���֤��ҵ��̨����˱�'||SQLERRM;
        ROLLBACK;RETURN;
    END;	  	
    END IF;
  END IF;  
     p_retCode := '0000000000'; p_retMsg  := '�ɹ�';
     commit; return;
END;   

/
show errors 