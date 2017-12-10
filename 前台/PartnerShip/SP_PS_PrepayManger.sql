CREATE OR REPLACE PROCEDURE SP_PS_PrepayManger
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
    V_PREPAY          INT                        ;
    
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
	      V_SEQ           , '11'             , P_DBALUNITNO , P_MONEY        ,
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
    SELECT PREPAY INTO V_PREPAY FROM TF_F_DEPTBAL_PREPAY WHERE DBALUNITNO = P_DBALUNITNO;
    --���֧��������Ԥ�����������ʾ����
    IF P_MONEY > V_PREPAY THEN
        P_RETCODE := 'S008905002';
        P_RETMSG  := '֧�����ܴ���Ԥ�������';
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
	      V_SEQ           , '12'             , P_DBALUNITNO , P_MONEY        ,
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