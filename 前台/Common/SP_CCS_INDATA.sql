create or replace procedure SP_CCS_INDATA
(
    p_TASKID    char ,
    p_filePath  varchar2,
    p_retCode      out char,       -- Return Code
    p_retMsg       out varchar2    -- Return Message
)
AS
    v_ex           exception ;
    v_startcardno  char(14) ;
    v_endcardno    char(14);
	V_NUM			INT;
	V_CARDNUM		INT;
BEGIN
        -- 1�� 
        BEGIN
          UPDATE TD_M_SERVICESET
          SET TASKDESC = '��ǰ����' || p_TASKID || '��ʼ���';

          IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
          EXCEPTION WHEN OTHERS THEN
              p_retCode := 'S009000001'; p_retMsg := '���·������ò�����ʧ��' || SQLERRM;
              ROLLBACK; RETURN;
        END;
        
		V_NUM:=0;
        -- 2��
        BEGIN
            FOR cur_data IN
            (
                SELECT * FROM TMP_XFC_INITCARD TMP
                WHERE TMP.TASKID = p_TASKID
            )
            LOOP
                BEGIN
                    INSERT INTO TD_XFC_INITCARD (XFCARDNO, NEW_PASSWD,YEAR, BATCHNO, VALUECODE, CORPCODE, CARDSTATECODE, PRODUCETIME, PRODUCESTAFFNO, ENDDATE)
                    VALUES (cur_data.xfcardno, cur_data.new_passwd, cur_data.year, cur_data.batchno, cur_data.valuecode, cur_data.corpcode,
                      cur_data.cardstatecode, cur_data.producetime, cur_data.producestaffno, cur_data.enddate);
					V_NUM:=V_NUM+1;
                  exception when others then
                    p_retCode := 'S009000003';
                    p_retMsg := '�����ֵ���˻���ʧ��'|| SQLERRM ;
                    rollback; return;
                END;
            END LOOP;
        END;
	--�ж��Ƿ�һ��
	SELECT CARDNUM	INTO V_CARDNUM
	FROM TF_F_MAKECARDTASK
	WHERE TASKID = p_TASKID;
	
	IF(V_CARDNUM<>V_NUM) THEN
		p_retCode := 'A009000010'; p_retMsg := 'TD_XFC_INITCARD����Ŀ�����Ϊ:'||V_NUM||';Ӧ����:'||V_CARDNUM;
        ROLLBACK; RETURN;
	END IF;
      -- 3) UPDATE THE TASK
      BEGIN
          UPDATE TF_F_MAKECARDTASK
          SET TASKSTATE = '2',
              TASKENDTIME = sysdate,
              FILEPATH = p_filePath
          WHERE TASKID = p_TASKID;
            
          IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
      EXCEPTION WHEN OTHERS THEN
          p_retCode := 'S009000002'; p_retMsg := '�����ƿ������ʧ��' || SQLERRM;
          ROLLBACK; RETURN;
      END;
      
      -- 4) Delete 
      BEGIN
          SELECT T.STARTCARDNO,T.ENDCARDNO INTO v_startcardno,  v_endcardno
          FROM TF_F_MAKECARDTASK T
          WHERE T.TASKID = p_TASKID;

          DELETE FROM td_m_chargecardno_exclude D
          WHERE D.CARDNO >= v_startcardno And D.CARDNO <= v_endcardno;
            
      EXCEPTION WHEN OTHERS THEN
          p_retCode := 'S009000004'; p_retMsg := 'ɾ�����ر�ʧ��' || SQLERRM;
          ROLLBACK; RETURN;
      END;
      
      -- 5��
      BEGIN
        UPDATE TD_M_SERVICESET
        SET TASKDESC = '��ǰ����' || p_TASKID || '������';

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S009000001'; p_retMsg := '���·������ò�����ʧ��' || SQLERRM;
            ROLLBACK; RETURN;
      END;

    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;
/
show errors