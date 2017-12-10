create or replace procedure SP_PS_BALUNITDETAILADD
(
    p_BALUNITNO       char,
    p_currOper        char,
    p_currDept        char,
    p_retCode     out char, -- Return Code
    p_retMsg      out varchar2  -- Return Message
)
as
    v_BALUNITNO char(8);
    v_STATECODE char(8);
    v_seqNo     char(16);
    v_CURRENTTIME date := sysdate;

BEGIN
    FOR cur_renewdata IN (
		SELECT f0 FROM TMP_COMMON
		) 
    LOOP
        BEGIN
            SELECT BALUNITNO, STATECODE INTO v_BALUNITNO, v_STATECODE
            FROM TF_UNITE_BALUNIT
            WHERE DETAILNO = cur_renewdata.f0 AND rownum = 1 ORDER BY UPDATETIME DESC;
        
            
            IF v_STATECODE = '0' and v_BALUNITNO != p_BALUNITNO THEN
            --存在已注销关系,且合帐结算单元不同
                merge INTO TF_UNITE_BALUNIT
                using       dual
                on          (BALUNITNO = p_BALUNITNO and DETAILNO = cur_renewdata.f0)
                WHEN MATCHED THEN
                    update set STATECODE = '1',
                               UPDATESTAFFNO = p_currOper,
                               UPDATETIME = v_CURRENTTIME
                WHEN NOT MATCHED THEN
                INSERT 
                    (BALUNITNO, DETAILNO, STATECODE, UPDATESTAFFNO, UPDATETIME)
                VALUES
                    (p_BALUNITNO, cur_renewdata.f0, '1', p_currOper, v_CURRENTTIME);
                    
                IF  SQL%ROWCOUNT != 1 THEN
                    raise_application_error(-30101, '更新结算单元对应关系失败' );
    		    END IF;
                    
            elsif v_STATECODE = '0' and v_BALUNITNO = p_BALUNITNO THEN
            --存在已注销关系,且合帐结算单元相同
                UPDATE TF_UNITE_BALUNIT
                SET    STATECODE = '1'
                WHERE  BALUNITNO = p_BALUNITNO and DETAILNO = cur_renewdata.f0;
                
                IF  SQL%ROWCOUNT != 1 THEN
                    raise_application_error(-30101, '更新结算单元对应关系失败' );
    		    END IF;
    		    
            elsif v_STATECODE = '2' and v_BALUNITNO != p_BALUNITNO THEN
            --存在待注销关系,且合帐结算单元不同
                merge INTO TF_UNITE_BALUNIT
                using   dual
                on      (BALUNITNO = p_BALUNITNO and DETAILNO = cur_renewdata.f0)
                WHEN MATCHED THEN
                    update set STATECODE = '1',
                               UPDATESTAFFNO = p_currOper,
                               UPDATETIME = v_CURRENTTIME
                WHEN NOT MATCHED THEN
                INSERT 
                    (BALUNITNO, DETAILNO, STATECODE, UPDATESTAFFNO, UPDATETIME)
                VALUES
                    (p_BALUNITNO, cur_renewdata.f0, '3', p_currOper, v_CURRENTTIME);
                    
                IF  SQL%ROWCOUNT != 1 THEN
                    raise_application_error(-30101, '更新结算单元对应关系失败' );
    		    END IF;
    		    
             elsif v_STATECODE = '2' and v_BALUNITNO = p_BALUNITNO THEN
             --存在待注销关系,且合帐结算单元相同
                UPDATE TF_UNITE_BALUNIT
                SET    STATECODE = '1'
                WHERE  BALUNITNO = p_BALUNITNO and DETAILNO = cur_renewdata.f0;
                
                IF  SQL%ROWCOUNT != 1 THEN
                    raise_application_error(-30101, '更新结算单元对应关系失败' );
    		    END IF;
            END IF;
        EXCEPTION WHEN NO_DATA_FOUND THEN
        --不存在对应关系
            INSERT INTO TF_UNITE_BALUNIT
                    (BALUNITNO, DETAILNO, STATECODE, UPDATESTAFFNO, UPDATETIME)
            VALUES
                    (p_BALUNITNO, cur_renewdata.f0, '1', p_currOper, v_CURRENTTIME);
        END;
        
        SP_GetSeq(seq => v_seqNo);
        
        BEGIN
            INSERT INTO TF_B_ASSOCIATETRADE  
              (TRADEID, TRADETYPECODE, ASSOCIATECODE, OPERATESTAFFNO,OPERATEDEPARTID, OPERATETIME)  
            VALUES
              (v_seqNo, '60', cur_renewdata.f0, p_currOper, p_currDept, v_CURRENTTIME );  

        EXCEPTION
          WHEN OTHERS THEN
            p_retCode := 'S008103004';
            p_retMsg  := '';
            ROLLBACK; RETURN;
        END;
    
    END LOOP;
    

	p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;

EXCEPTION WHEN OTHERS THEN
    p_retCode := SQLCODE;
    p_retMsg  := SQLERRM;
    ROLLBACK; RETURN;
END;
/

show errors