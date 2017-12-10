CREATE OR REPLACE PROCEDURE SP_RM_GETRESOURCEAPPLYSUBMIT   --��Դ��������ҳ��
(
  P_USEWAY               VARCHAR2  ,  --��;
  P_RESOURCECODE         CHAR      ,  --��Դ����
  P_ATTRIBUTE1           VARCHAR2  ,  --��Դ����
  P_ATTRIBUTE2           VARCHAR2  ,
  P_ATTRIBUTE3           VARCHAR2  ,
  P_ATTRIBUTE4           VARCHAR2  ,
  P_ATTRIBUTE5           VARCHAR2  ,
  P_ATTRIBUTE6           VARCHAR2  ,
  P_APPLYGETNUM          INT       ,   --��������
  P_REMARK               VARCHAR2  ,   --��ע
  p_currOper             char      ,
  P_CURRDEPT             Char      ,
  p_retCode              out char     ,  -- Return Code
  p_retMsg               out varchar2    -- Return Message
)
AS
    v_seqNo             CHAR(16)       ;
    V_GETORDERID        CHAR(18)       ;
    V_EX                EXCEPTION      ;
    V_TODAY             DATE := SYSDATE;
    v_insnum             INT;
    v_usenum             INT;

BEGIN


  --��ȡ��ˮ��
  SP_GetSeq(seq => v_seqNo);

  V_GETORDERID :='LY'||v_seqNo;
  
  --�ж����������Ƿ���ڿ������
  SELECT INSNUM,USENUM INTO v_insnum,v_usenum FROM  TL_R_RESOURCESUM A WHERE A.RESOURCECODE = P_RESOURCECODE;
		IF v_insnum < v_usenum OR v_insnum-v_usenum< P_APPLYGETNUM THEN
			P_RETCODE := 'A094780195';
			P_RETMSG  := '�������������������';
			ROLLBACK; RETURN;
		END IF;


  --��¼��Դ���õ���
  BEGIN
    INSERT INTO  TF_F_GETRESOURCEORDER(
    GETORDERID      ,ORDERSTATE        ,USETAG            ,USEWAY             ,RESOURCECODE      ,
    ATTRIBUTE1      ,ATTRIBUTE2        ,ATTRIBUTE3        ,ATTRIBUTE4         ,ATTRIBUTE5        ,
    ATTRIBUTE6      ,APPLYGETNUM       ,AGREEGETNUM       ,ALREADYGETNUM      ,LATELYGETDATE     ,
    GETSTAFFNO      ,ORDERTIME         ,ORDERSTAFFNO      ,EXAMTIME           ,EXAMSTAFFNO       ,
    PRINTCOUNT      ,REMARK                                                                      )
VALUES(
    V_GETORDERID    ,'0'               ,'1'               ,P_USEWAY            ,P_RESOURCECODE    ,
    P_ATTRIBUTE1    ,P_ATTRIBUTE2      ,P_ATTRIBUTE3      ,P_ATTRIBUTE4        ,P_ATTRIBUTE5      ,
    P_ATTRIBUTE6    , P_APPLYGETNUM    ,NULL              , 0                  ,NULL             ,
    NULL            ,V_TODAY           ,p_currOper        , NULL               ,NULL             ,
    0               ,P_REMARK );
    IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
      WHEN OTHERS THEN
          p_retCode := 'SR01002701';
          p_retMsg  := '��¼��Դ���õ���'|| SQLERRM;
          ROLLBACK; RETURN;
  END;

SP_GetSeq(seq => v_seqNo);

  --��¼��Դ���ݹ���̨�˱�
  BEGIN
    INSERT INTO TF_B_RESOURCEORDERMANAGE(
        TRADEID           , ORDERTYPECODE           , ORDERID           , OPERATETYPECODE     ,
        ORDERDEMAND       , MAINTAINREASON          , RESOURCECODE      , ATTRIBUTE1          ,
        ATTRIBUTE2        , ATTRIBUTE3              , ATTRIBUTE4        , ATTRIBUTE5          ,
        ATTRIBUTE6        , RESOURCENUM             , REQUIREDATE       , LATELYDATE          ,
      ALREADYORDERNUM   ,ALREADYARRIVENUM         , APPLYGETNUM       , AGREEGETNUM         ,
      ALREADYGETNUM     , LATELYGETDATE           , GETSTAFFNO        , OPERATETIME         ,
      OPERATESTAFFNO
    )VALUES  (
        v_seqNo           ,  '03'                  , V_GETORDERID      , '02'                ,
        NULL              , NULL                   , P_RESOURCECODE    , P_ATTRIBUTE1        ,
        P_ATTRIBUTE2      ,P_ATTRIBUTE3            , P_ATTRIBUTE4      , P_ATTRIBUTE5        ,
        P_ATTRIBUTE6      ,NULL                    , NULL              , NULL                ,
        0                 ,NULL                    , P_APPLYGETNUM     , NULL                ,
        0                 , NULL                   , NULL              , V_TODAY             ,
      P_CURROPER )     ;
    IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
      WHEN OTHERS THEN
          p_retCode := 'SR01002702';
          p_retMsg  := '��¼��Դ���ݹ���̨�˱�'|| SQLERRM;
          ROLLBACK; RETURN;
  END;



  p_retCode := '0000000000';
  p_retMsg  := '�ɹ�';
  COMMIT; RETURN;
END;
/
SHOW ERROR;
