CREATE OR REPLACE PROCEDURE SP_PB_TRANSITBALANCEUPDATEOLD
(
  P_NEWCARDNO  CHAR,
  P_NEWCARDNOS VARCHAR2,
  p_TRADEID    CHAR,
  p_CURRENTTIME DATE,
  p_retCode         out char, -- Return Code
  p_retMsg          out varchar2  -- Return Message
)
AS
V_COUNT         NUMBER;  
V_OLDCARDNO     CHAR(16);
V_OLDCARDACCMONEY NUMBER;  
V_NEWCARDNOS    VARCHAR2(200);
v_OPERATETIME   DATE;
v_CHANGESPAN    NUMBER;  
v_ex                  exception;
BEGIN
    v_newcardnos:=P_NEWCARDNOS||','||P_NEWCARDNO;
    SELECT TAGVALUE INTO v_CHANGESPAN FROM TD_M_TAG WHERE TAGCODE='PB_TBCHANGE_SPAN';      
  	--1）查询换卡的旧卡信息
    SELECT COUNT(*) INTO V_COUNT
    FROM TF_B_TRADE a,TF_F_CARDEWALLETACC b WHERE a.CARDNO =P_NEWCARDNO AND 
    a.TRADETYPECODE IN ('03','73','74','75','7C','E3') AND b.CARDNO = a.OLDCARDNO AND a.CANCELTAG = '0' 
    AND not exists (select 1 from tf_b_trade c where c.cardno = a.oldcardno and c.tradetypecode = '5C' and c.canceltag='0');
    IF V_COUNT=0 THEN
      BEGIN
        SELECT COUNT(*) INTO V_COUNT FROM TF_B_TRADE a,TF_F_CARDEWALLETACC b,TF_B_TRADE c WHERE a.CARDNO = P_NEWCARDNO
                     AND a.TRADETYPECODE IN ('03','73','74','75','7C','E3') 
                     AND b.CARDNO = a.OLDCARDNO 
                     AND a.CANCELTAG = '0'
                     AND a.OLDCARDNO = c.CARDNO
                     AND c.TRADETYPECODE = '5C' 
                     AND c.CANCELTAG = '0';
        IF V_COUNT=0 THEN
            RETURN;
        ELSE
           SELECT a.OLDCARDNO, (case  when a.reasoncode in('14','15') then b.CARDACCMONEY else c.OLDCARDMONEY end ) CARDACCMONEY,(case 
                                 when c.REASONCODE in('12','13') then TO_DATE(TO_CHAR(c.OPERATETIME,'YYYYMMDD'),'YYYYMMDD')-7
                                  else c.OPERATETIME
                                 end) OPERATETIME
            INTO V_OLDCARDNO,V_OLDCARDACCMONEY,V_OPERATETIME
                     FROM TF_B_TRADE a,TF_F_CARDEWALLETACC b,TF_B_TRADE c WHERE a.CARDNO = P_NEWCARDNO
                     AND a.TRADETYPECODE IN ('03','73','74','75','7C','E3') 
                     AND b.CARDNO = a.OLDCARDNO 
                     AND a.CANCELTAG = '0'
                     AND a.OLDCARDNO = c.CARDNO
                     AND c.TRADETYPECODE = '5C' 
                     AND c.CANCELTAG = '0';
        END IF;
      END;
    ELSE
      BEGIN
         SELECT a.OLDCARDNO,b.CARDACCMONEY,a.OPERATETIME INTO V_OLDCARDNO,V_OLDCARDACCMONEY,V_OPERATETIME
        FROM TF_B_TRADE a,TF_F_CARDEWALLETACC b WHERE a.CARDNO =P_NEWCARDNO AND 
        a.TRADETYPECODE IN ('03','73','74','75','7C','E3') AND b.CARDNO = a.OLDCARDNO AND a.CANCELTAG = '0' 
        AND not exists (select 1 from tf_b_trade c where c.cardno = a.oldcardno and c.tradetypecode = '5C' and c.canceltag='0');
      END;
    END IF;

    --2）查询转值是否限制
    SELECT COUNT(*) INTO V_COUNT FROM TF_B_TRANSITLIMIT WHERE CARDNO = V_OLDCARDNO AND STATE = '0';
    IF V_COUNT=0 THEN
       BEGIN
         SELECT  COUNT(*) INTO V_COUNT FROM TF_B_TRADE WHERE INSTR(','||(select substr(v_newcardnos,2,length(v_newcardnos)-1) from dual)||',' , ','||CARDNO||',')>0 AND OLDCARDNO = V_OLDCARDNO AND TRADETYPECODE = '04' AND CANCELTAG = '0';
                  
       END;
    END IF;
    --3)如果无转值记录
    IF V_COUNT=0 THEN
       --a)超过7天                            
       IF v_OPERATETIME+v_CHANGESPAN<=sysdate THEN
         --)更新旧卡账户
          BEGIN
            UPDATE TF_F_CARDEWALLETACC
                SET  USETAG = '0',
                      CARDACCMONEY=0,
                      TOTALCONSUMEMONEY=TOTALCONSUMEMONEY+V_OLDCARDACCMONEY,
                      TOTALCONSUMETIMES=TOTALCONSUMETIMES+1
                WHERE  CARDNO = v_OLDCARDNO;

            IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    p_retCode := 'S00100AB01';
                    p_retMsg  := 'Error occurred while Updating wallet usetag of old card' || SQLERRM;
                    ROLLBACK; RETURN;
            END;
             
         --)记录旧卡余额变动表
          BEGIN
            SP_PB_INSERTBALANCETRADE(p_TRADEID,v_OLDCARDNO,'04','',
            V_OLDCARDACCMONEY,-V_OLDCARDACCMONEY,0,p_CURRENTTIME,p_retCode,p_retMsg);
          
           IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
            EXCEPTION
            WHEN OTHERS THEN
              ROLLBACK; RETURN;
          END; 
          
          --)记录新旧卡关系表
          BEGIN
          INSERT INTO TF_TRANSITBALANCE_TRADE(TRADEID,NEWCARDNO,OLDCARDNO,TRADEMONEY)
          VALUES(p_TRADEID,P_NEWCARDNO,V_OLDCARDNO,V_OLDCARDACCMONEY);
           IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
              EXCEPTION
                    WHEN OTHERS THEN
                        p_retCode := 'S001002113';
                        p_retMsg  := 'Unable to insert TF_TRANSITBALANCE_TRADE information' || SQLERRM;
                        ROLLBACK; RETURN;
              END;
           --）继续调上级换卡
            SP_PB_TRANSITBALANCEUPDATEOLD(V_OLDCARDNO,v_newcardnos,p_TRADEID,p_CURRENTTIME,p_retCode,p_retMsg);  
       ELSE
         --b)未超过7天返回
         p_retCode := 'S0010AB021';
         p_retMsg  := 'has not to transtibalance day' || SQLERRM;
         ROLLBACK;RETURN;
       END IF;  
    ELSE
      SP_PB_TRANSITBALANCEUPDATEOLD(V_OLDCARDNO,v_newcardnos,p_TRADEID,p_CURRENTTIME,p_retCode,p_retMsg);
    END IF;
    p_retCode:='0000000000';
    p_retMsg:='OK';
     RETURN;
END ;
/