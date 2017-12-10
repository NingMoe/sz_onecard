CREATE OR REPLACE PROCEDURE SP_SSO_CHECKUSER
(
    p_funcCode   varchar2,
    p_var1       varchar2,
    p_var2       varchar2,
    p_var3       varchar2,
    p_var4       varchar2,
    p_var5       varchar2,
    p_var6       varchar2,
    p_var7       varchar2,
    p_var8       varchar2,
    p_var9       varchar2,
    p_cursor out SYS_REFCURSOR
)
AS
V_TODAY DATE := SYSDATE;
BEGIN

   --1) 校验用户名密码
   IF p_funcCode = 'CheckStaff' THEN
    BEGIN
        open p_cursor for
        SELECT   DIMISSIONTAG,OPERCARDNO,STAFFNO,LAST_ACTIVE_TIME,SYSNAME,'OK' SMKCHECK
        FROM TD_M_INSIDESTAFF_VIEW  s
        WHERE STAFFNO = p_var1  AND OPERCARDPWD = p_var3;
    EXCEPTION
    WHEN OTHERS THEN
        open p_cursor for
        SELECT   DIMISSIONTAG,OPERCARDNO,STAFFNO,LAST_ACTIVE_TIME,'onecard' SYSNAME,'ERROR' SMKCHECK
        FROM TD_M_INSIDESTAFF  s
        WHERE STAFFNO = p_var1  AND OPERCARDPWD = p_var3;
    END;
	
	ELSIF p_funcCode = 'CheckStaffInAdmin' THEN--add by liuhe20120928 电子钱包系统添加admin页面登录限制
    BEGIN
        open p_cursor for
        SELECT   DIMISSIONTAG,OPERCARDNO,STAFFNO,LAST_ACTIVE_TIME,SYSNAME,'OK' SMKCHECK
        FROM TD_M_INSIDESTAFF_VIEW  s
        WHERE STAFFNO = p_var1  AND OPERCARDPWD = p_var3
				AND (S.SYSNAME<>'onecard' OR (S.STAFFNO IN (SELECT STAFFNO FROM TD_M_ADMINLOGCONFIG)));
    EXCEPTION
    WHEN OTHERS THEN
        open p_cursor for
        SELECT   DIMISSIONTAG,OPERCARDNO,STAFFNO,LAST_ACTIVE_TIME,'onecard' SYSNAME,'ERROR' SMKCHECK
        FROM TD_M_INSIDESTAFF  s
        WHERE STAFFNO = p_var1  AND OPERCARDPWD = p_var3
				AND S.STAFFNO IN (SELECT STAFFNO FROM TD_M_ADMINLOGCONFIG);
    END;
	--2）校验登录限制
	ELSIF p_funcCode = 'CheckStaffLogin' THEN
    BEGIN
		open p_cursor for
			SELECT LAST_ACTIVE_TIME,SYSNAME,'OK' SMKCHECK
			FROM TD_M_INSIDESTAFF_VIEW s
			WHERE s.STAFFNO = p_var1 AND OPERCARDNO = p_var2 AND OPERCARDPWD = p_var3
			AND DIMISSIONTAG = '1'
			AND (
			EXISTS (SELECT 1 FROM TD_M_INSIDESTAFFLOGIN_VIEW l WHERE STAFFNO = s.STAFFNO
					 AND SYSNAME = s.SYSNAME
			        AND VALIDTAG = '1'
			        AND (IPADDR is null OR IPADDR = p_var4)
			        AND (STARTDATE is null OR to_Date(STARTDATE,'YYYYMMDD') < SYSDATE )
			        AND (ENDDATE is null OR to_Date(ENDDATE,'YYYYMMDD') > SYSDATE )
			        AND (STARTTIME is null
			            OR TO_DATE(TO_CHAR(SYSDATE,'yyyy-mm-dd') ||' '|| STARTTIME,
			            'yyyy-mm-dd hh24:mi:ss') < SYSDATE )
			        AND (ENDTIME is null
			            OR TO_DATE(TO_CHAR(SYSDATE,'yyyy-mm-dd') ||' '|| ENDTIME,
			            'yyyy-mm-dd hh24:mi:ss') > SYSDATE ))
			OR
			NOT EXISTS (SELECT 1 FROM TD_M_INSIDESTAFFLOGIN_VIEW l WHERE STAFFNO = s.staffno
			           AND SYSNAME = s.SYSNAME  AND VALIDTAG = '1')
			);
    EXCEPTION
    WHEN OTHERS THEN
      open p_cursor for
			SELECT LAST_ACTIVE_TIME,'onecard' SYSNAME,'ERROR' SMKCHECK
			FROM TD_M_INSIDESTAFF s
			WHERE s.STAFFNO = p_var1 AND OPERCARDNO = p_var2 AND OPERCARDPWD = p_var3
			AND DIMISSIONTAG = '1'
			AND (
			EXISTS (SELECT 1 FROM TD_M_INSIDESTAFFLOGIN l WHERE STAFFNO = s.STAFFNO
			        AND VALIDTAG = '1'
			        AND (IPADDR is null OR IPADDR = p_var4)
			        AND (STARTDATE is null OR to_Date(STARTDATE,'YYYYMMDD') < SYSDATE )
			        AND (ENDDATE is null OR to_Date(ENDDATE,'YYYYMMDD') > SYSDATE )
			        AND (STARTTIME is null
			            OR TO_DATE(TO_CHAR(SYSDATE,'yyyy-mm-dd') ||' '|| STARTTIME,
			            'yyyy-mm-dd hh24:mi:ss') < SYSDATE )
			        AND (ENDTIME is null
			            OR TO_DATE(TO_CHAR(SYSDATE,'yyyy-mm-dd') ||' '|| ENDTIME,
			            'yyyy-mm-dd hh24:mi:ss') > SYSDATE ))
			OR
			NOT EXISTS (SELECT 1 FROM TD_M_INSIDESTAFFLOGIN l WHERE STAFFNO = s.staffno
			            AND VALIDTAG = '1')
			);
    END;
  END IF;
END;



/
show error;