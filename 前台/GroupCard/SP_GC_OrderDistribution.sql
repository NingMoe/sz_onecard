CREATE OR REPLACE PROCEDURE SP_GC_OrderDistribution
(

   P_SESSIONID  CHAR,
   P_CURROPER CHAR, --当前操作者
   P_CURRDEPT CHAR  ,
   P_RETCODE  OUT CHAR, --错误编码
   P_RETMSG   OUT VARCHAR2 --错误信息

)
AS
    v_seqNo        CHAR(16);    --流水号
    V_ORDERNO  CHAR(16);        --订单编号
    V_ISRELATED char(1);        --是否关联卡
    V_GETDEPARTMENT CHAR(4) ;   --领卡网点
    V_GETDATE   CHAR(8);           --领卡日期

    V_TODAY           DATE:=SYSDATE;
    V_EX              EXCEPTION;
BEGIN




  FOR V_CUR IN (
      SELECT a.f0, a.f1, a.f2,a.f3
      FROM TMP_ORDER a WHERE a.f4 = P_SESSIONID
    )
  LOOP
    V_ORDERNO := V_CUR.f0;
    V_ISRELATED := V_CUR.f1;
    V_GETDEPARTMENT := V_CUR.f2;
    V_GETDATE := V_CUR.f3;

    --获取流水号
    SP_GetSeq(seq => v_seqNo);


    BEGIN
       UPDATE   TF_F_ORDERFORM
       SET      ISRELATED = V_ISRELATED,
                ORDERSTATE = '03' ,  
                GETDEPARTMENT = V_GETDEPARTMENT,
                GETDATE = V_GETDATE ,
                UPDATEDEPARTNO = P_CURRDEPT,
                UPDATESTAFFNO= P_CURROPER,
                UPDATETIME = V_TODAY
       WHERE    ORDERNO = V_ORDERNO;
       IF SQL%ROWCOUNT != 1 THEN
         RAISE V_EX;
       END IF;
       EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S001002802';
            P_RETMSG := '更新订单表失败' || SQLERRM;
          ROLLBACK;RETURN;
     END;


  --记录订单台帐表
    BEGIN
        INSERT INTO TF_F_ORDERTRADE(
        TRADEID           , ORDERNO                 , ORDERSTATE        , TRADECODE           ,
        GETDEPARTMENT     , GETDATE                 , OPERATEDEPARTNO   , OPERATESTAFFNO      ,
        OPERATETIME    
       
      )VALUES(
        v_seqNo           ,V_ORDERNO                  ,'02'             , '06'                ,
        V_GETDEPARTMENT    ,V_GETDATE                 , P_CURRDEPT     , P_CURROPER      ,
        V_TODAY
      );
    IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
          EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S001002803';
            P_RETMSG  := '记录订单台帐表失败'||SQLERRM;
            ROLLBACK; RETURN;
    END;

  

  END LOOP;

   P_RETCODE := '0000000000';
   P_RETMSG  := '';
   COMMIT; RETURN;
END;
/
show errors;