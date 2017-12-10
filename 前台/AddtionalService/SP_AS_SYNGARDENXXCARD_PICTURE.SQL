CREATE OR REPLACE PROCEDURE SP_AS_SYNGARDENXXCARD_PICTURE
(
       
       P_CHANNELTYPECODE    CHAR ,--用于区分不同景点	    
       P_RETCODE     OUT    VARCHAR2,
       P_RETMSG      OUT    VARCHAR2
      
)
AS
BEGIN
     --  Step-1 将待同步数据置为临时状态3
	 --  表结构做了修改，结合景点编码同步数据，处理字段只保留DEALTYPE，更新数据用乐园的景点做更新
     BEGIN
         UPDATE TF_B_GARDENXXCARD
         SET DEALTYPE = '3' WHERE DEALTYPE in('0','3')
         AND CHANNELTYPECODE = P_CHANNELTYPECODE;
     EXCEPTION WHEN OTHERS THEN
         p_RETCODE:= 'S00901B004';
         p_RETMSG := '更新同步休闲年卡数据表状态失败';
         ROLLBACK;RETURN;
     END;

     -- Step-2 从卡管同步照片至电子钱包
     BEGIN
         INSERT INTO TF_F_CARDPARKPHOTO_SZ(CARDNO, PICTURE,OPERATETIME,OPERATESTAFFNO,OPERATEDEPARTID)
         SELECT CARDNO, PICTURE, SYSDATE, '030000','0003'
         FROM TF_F_RESIDENTCARD@WWW.SMK.COM
         WHERE CARDNO IN
         (
               SELECT CARDNO
               FROM TF_B_GARDENXXCARD
               WHERE DEALTYPE = '3' AND CHANNELTYPECODE = P_CHANNELTYPECODE
               AND SUBSTR(CARDNO, 5, 2) = '18' --仅需同步A卡
               AND CARDNO NOT IN
               (
                   SELECT CARDNO
                   FROM TF_F_CARDPARKPHOTO_SZ
               )
         );
     EXCEPTION WHEN OTHERS THEN
         p_RETCODE:= 'S00901B005';
         p_RETMSG := '插入照片同步表失败'||SQLERRM;
         ROLLBACK;RETURN;
     END;

     -- Step-3 去除照片为空的记录
     BEGIN
        DELETE FROM TF_F_CARDPARKPHOTO_SZ
        WHERE PICTURE IS NULL;
     EXCEPTION WHEN OTHERS THEN
         p_RETCODE:= 'S00901B006';
         p_RETMSG := '删除照片同步表失败'||SQLERRM;
         ROLLBACK;RETURN;
     END;

     p_RETCODE:= '0000000000';
     p_RETMSG := 'OK';
     COMMIT;
END;
/
SHOW ERRORS