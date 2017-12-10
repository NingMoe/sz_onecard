CREATE OR REPLACE PROCEDURE SP_AS_TravelCardNew_BAT
(
    p_ID                char,  --记录流水号
    p_cardNo            char,  --卡号
    p_cardTradeNo       char,  --联机交易序号
    p_asn               char,  --应用序列号
    p_tradeFee          int,  --代开功能费
	p_openTime      char,  --开卡日期
	P_endTime      char,  --卡有效期

    p_operCardNo        char,  --操作员卡号    没有填空值
    p_terminalNo        char,  --终端编码      默认值 112233445566
    p_oldEndDateNum     char,  --卡片资料变更  没有填空值
    p_endDateNum        char,  --卡片资料变更  没有填空值

    p_custName          varchar2,  --姓名    没有填空值
    p_custSex           varchar2,  --性别    没有填空值
    p_custBirth         varchar2,  --出生日期  没有填空值
    p_paperType         varchar2,  --证件类型编码  没有填空值
    p_paperNo           varchar2,  --证件号码  没有填空值
    p_custAddr          varchar2,  --联系地址  没有填空值
    p_custPost          varchar2,  --邮政编码  没有填空值
    p_custPhone         varchar2,  --联系电话  没有填空值
    p_custEmail         varchar2,  --电子邮件  没有填空值
    p_remark            varchar2,  --备注  没有填空值
    p_currOper          char,    --操作员工号
    p_currDept          char,    --操作部门号

	p_usetag      varchar2,  --前后台传入参数标识(前台传入1，后台传入2)

    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_ex                exception;
BEGIN
  BEGIN
  SP_AS_TravelCardNew(p_ID,p_cardNo,p_cardTradeNo,p_asn,p_tradeFee,p_openTime,P_endTime,
            p_operCardNo,p_terminalNo,p_oldEndDateNum,p_endDateNum,
            p_custName,p_custSex,p_custBirth,p_paperType,p_paperNo,p_custAddr,
            p_custPost,p_custPhone,p_custEmail,p_remark,p_currOper,p_currDept,
            p_usetag,p_retCode,p_retMsg);
  IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
  EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK; RETURN;
  END;
  p_retCode := '0000000000'; p_retMsg  := 'OK';
  COMMIT; RETURN;
END;
/
show errors