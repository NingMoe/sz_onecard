
--根据订单号 更新联系人、联系电话、身份证号  create by Yin 20120726

create or replace procedure SP_GC_ORDERINFOUPDATE
(
			 p_ORDERNO      char,
       P_NAME         varchar2,
       P_PHONE        varchar2,
       P_IDCARDNO     varchar2,
       
       p_currOper     char,           -- Current Operator
       p_currDept     char,           -- Curretn Operator's Department
       p_retCode      out char,       -- Return Code
       p_retMsg       out varchar2    -- Return Message
)
AS
       v_today         date;
       v_ex            EXCEPTION;
       V_SEQ           char(16);
BEGIN
   v_today := sysdate;
   
   --插入历史表
   Begin
        SP_GETSEQ(SEQ => V_SEQ);
        insert into TF_F_ORDERCUSTOMER_HIS 
        (
            TRADEID,
            ORDERNO,
            OLDNAME,
            OLDPHONE,
            OLDIDCARDNO,
            NEWNAME,
            NEWIDCARDNO,
            NEWPHONE,
            UPDATEDEPARTNO,
            UPDATESTAFFNO,
            UPDATETIME 
        )
        select 
           V_SEQ,
           ORDERNO,
           name,
           phone,
           idcardno,
           P_NAME,
           P_IDCARDNO,
           P_PHONE,
           p_currDept,
           p_currOper,
           v_today
           from TF_F_ORDERFORM where orderno = p_ORDERNO;
           EXCEPTION
            WHEN OTHERS THEN
              P_RETCODE := 'S094390050';
              P_RETMSG := '写入客户资料历史表失败' || SQLERRM;
              ROLLBACK;
              RETURN; 
   end;
   
   BEGIN
        --插入订单主表
         update TF_F_ORDERFORM tf
         set tf.name = P_NAME,
         tf.phone = P_PHONE,
         tf.idcardno = P_IDCARDNO,
         tf.updatedepartno = p_currDept,
         tf.updatestaffno = p_currOper,
         tf.updatetime = v_today
         where tf.orderno = p_ORDERNO;
                  
         exception when others then
         p_retCode := 'S001002302';
         p_retMsg := '更新订单表失败'|| SQLERRM ;
         rollback; 
         return;
  END;  
  
  
  
   
    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;

/ 
show errors;


