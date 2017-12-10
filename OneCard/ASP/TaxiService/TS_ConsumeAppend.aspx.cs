using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using Common;
using TM;
using PDO.TaxiService;

public partial class ASP_TaxiService_TS_ConsumeAppend : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            hidDriverStafffNo.Value = "";

            //初始化现金支付
            TSHelper.initPayType(selPayMoney);

            btnConsumeAppend.Enabled = false;

        }


    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        ClearTaxiDriverInfo();
        ClearAppendInfo();

        //对司机工号进行非空、长度、数字检验
        string strDriverSfaffNo = txtDriverStaffNo.Text.Trim();

        if (strDriverSfaffNo == "")
            context.AddError("A003100001", txtDriverStaffNo);
        else if (!Validation.isNum(strDriverSfaffNo))
            context.AddError("A003100002", txtDriverStaffNo);
        else if (Validation.strLen(strDriverSfaffNo) != 6)
            context.AddError("A003100003", txtDriverStaffNo);
       
        if (context.hasError())
            return;

        hidDriverStafffNo.Value = strDriverSfaffNo;

        QueryDriverInfo();
        
    }


    private void QueryDriverInfo()
    {
        //查询司机工号对应的信息
        String sql = "SELECT staff.CARNO,bal.BANKACCNO,bal.BANKCODE," +
                     "staff.STAFFNAME,staff.STAFFSEX,staff.STAFFPHONE," +
                     "staff.STAFFMOBILE,staff.STAFFPAPERTYPECODE," +
                     "staff.STAFFPAPERNO,staff.STAFFPOST,staff.DIMISSIONTAG," +
                     "staff.STAFFADDR,staff.STAFFEMAIL," +
                     "bal.CORPNO,bal.DEPARTNO,staff.POSID," +
                     "staff.COLLECTCARDNO,staff.COLLECTCARDPWD,staff.OPERCARDNO,staff.STAFFNO,bal.BALUNITNO " +
                     "FROM TD_M_CALLINGSTAFF staff,TF_TRADE_BALUNIT bal ";
  
        ArrayList list = new ArrayList();

        list.Add("staff.STAFFNO = bal.CALLINGSTAFFNO");
        list.Add("staff.CALLINGNO = '02'");
        list.Add("bal.BALUNITTYPECODE = '03'");
        if (hidDriverStafffNo.Value != "" )
            list.Add("bal.CALLINGSTAFFNO  = '" + hidDriverStafffNo.Value + "' ");

        // if (hidCardNo.Value != "")
        //    list.Add("staff.COLLECTCARDNO  = '" + hidCardNo.Value + "' ");

        sql +=  DealString.ListToWhereStr(list);


        TMTableModule tm = new TMTableModule();
        DataTable data = null;
        data = tm.selByPKDataTable(context, sql, 0);
        if (data == null || data.Rows.Count == 0) // 无记录
        {
            context.AddError("A003101012");
        }
        else
        {
            //界面显示司机商户信息
            Object[] row = data.Rows[0].ItemArray;
            labCardNo.Text = getCellValue(row[18]);
            txtDriverStaffNo.Text = getCellValue(row[19]);

            labCarNo.Text = getCellValue(row[0]);
            labBankAccount.Text = getCellValue(row[1]);

            hidBankCode.Value = getCellValue(row[2]);

            // strBankCode = getCellValue(row[2]);
            labStaffName.Text = getCellValue(row[3]);

            if (getCellValue(row[4]).Trim() != "")
              labStaffSex.Text = getCellValue(row[4]) == "0" ? "男" : "女";

            labContactPhone.Text = getCellValue(row[5]);
            labCarPhone.Text = getCellValue(row[6]);

            hidPaperTypeNo.Value = getCellValue(row[7]);

            labPaperNo.Text = getCellValue(row[8]);
            labPostCode.Text = getCellValue(row[9]);

            if (getCellValue(row[10]).Trim() != "")
                labDimssionTag.Text = getCellValue(row[10]) == "1" ? "在职" : "离职";

            labContactAddr.Text = getCellValue(row[11]);
            labEmailAddr.Text = getCellValue(row[12]);

            hidCorpNo.Value = getCellValue(row[13]);
            hidDepartNo.Value = getCellValue(row[14]);

            labPosID.Text = getCellValue(row[15]);
            labCollectCardNo.Text = getCellValue(row[16]);
            labCollectCardPass.Text = getCellValue(row[17]);

            //hidBalUnitNo.Value = getCellValue(row[20]);
            //查询银行,单位,部门,证件类型名称
            QueryNameByCode(hidBankCode.Value, hidCorpNo.Value, hidDepartNo.Value, hidPaperTypeNo.Value);

        }
    }


    private string getCellValue(Object obj)
    {
        return (obj == DBNull.Value ? "" : (string)obj);
    }

    private void QueryNameByCode(string strBankCode, string strCorpNo, string strDepartNo, string strPaperTypeNo)
    {
        TMTableModule tm = new TMTableModule();
        DataTable data = null;

        //查询银行代码对应的银行名称
        string bankSql = "select BANK from TD_M_BANK where BANKCODE ='" + strBankCode + "'";

        data = tm.selByPKDataTable(context, bankSql, 0);
        if (data == null || data.Rows.Count == 0) // 无记录
        {
            context.AddError("A003101013");
        }
        else
        {
            Object[] row = data.Rows[0].ItemArray;
            labHouseBank.Text = getCellValue(row[0]);
        }

        //查询单位代码对应的单位名称
        string corpSql = "select CORP from TD_M_CORP where CORPNO ='" + strCorpNo + "'";

        data = tm.selByPKDataTable(context, corpSql, 0);
        if (data == null || data.Rows.Count == 0) // 无记录
        {
            context.AddError("A003101014");
        }
        else
        {
            Object[] row = data.Rows[0].ItemArray;
            labUnitName.Text = getCellValue(row[0]);
        }

        //查询部门代码对应的部门名称
        string departSql = "select DEPART from TD_M_DEPART where DEPARTNO ='" + strDepartNo + "'";

        data = tm.selByPKDataTable(context, departSql, 0);
        if (data == null || data.Rows.Count == 0) // 无记录
        {
            labDeptName.Text = "";
        }
        else
        {
            Object[] row = data.Rows[0].ItemArray;
            labDeptName.Text = getCellValue(row[0]);
        }

        //查询证件类型代码对应的证件类型名称
        string paperTypeSql = "select PAPERTYPENAME from TD_M_PAPERTYPE where PAPERTYPECODE ='" + strPaperTypeNo + "'";

        data = tm.selByPKDataTable(context, paperTypeSql, 0);
        if (data == null || data.Rows.Count == 0) // 无记录
        {
            context.AddError("A003101016");
        }
        else
        {
            Object[] row = data.Rows[0].ItemArray;
            labPaperType.Text = getCellValue(row[0]);
        }



    }

    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        //查询库中司机信息
        ClearTaxiDriverInfo();
        ClearAppendInfo();

        hidDriverStafffNo.Value = txtDriverStaffNo.Text.Trim();
        QueryDriverInfo();
    }

    protected Boolean ValidAppendInfo()
    {
        //检测输入票据信息1--ASN号
        //对ASN非空,数字,长度的校验
        string strAsnNo = txtAppend01.Text.Trim();

        if (strAsnNo == "")
            context.AddError("A003106007", txtAppend01);

        else if (!Validation.isNum(strAsnNo))
            context.AddError("A003106008", txtAppend01);

        else if (Validation.strLen(strAsnNo) != 16)
            context.AddError("A003106009", txtAppend01);

        hidAppend01Ext.Value = strAsnNo;


        //检测输入票据信息2--交易日期(10), 交易前金额(6)
        //交易日期(10) 格式为 yyMMddHHmm
        string strAppend02 = txtAppend02.Text.Trim();
        string strAppend02Front10 = "";
        string strAppend02Back6 = "";

        if (strAppend02 == "")
            context.AddError("A003106010", txtAppend02);

        else if (!Validation.isNum(strAppend02))
        {
            context.AddError("A003106047", txtAppend02);//
        }

        else if (Validation.strLen(strAppend02) != 16)
        {
            context.AddError("A003106012", txtAppend02);
        }


        else
        {
            strAppend02Front10 = strAppend02.Substring(0, 10);
            strAppend02Back6 = strAppend02.Substring(10, 6);

            if (!Validation.isDate(strAppend02Front10, "yyMMddHHmm"))
            {
                context.AddError("A003106011", txtAppend02);
            }
        }

        hidAppend02Ext.Value = strAppend02;

        //检测输入票据信息3-交易后金额(6),交易金额(6),终端交易号前(4)位
        string strAppend03 = txtAppend03.Text.Trim();
        string strAppend03Front6 = "";
        string strAppend03Middle6 = "";
        string strAppend03Last4 = "";

        if (strAppend03 == "")
            context.AddError("A003106013", txtAppend03);

        else if (!Validation.isNum(strAppend03))
            context.AddError("A003106048", txtAppend03);//

        else if (Validation.strLen(strAppend03) != 16)
            context.AddError("A003106015", txtAppend03);
        else
        {
            strAppend03Front6 = strAppend03.Substring(0, 6);
            strAppend03Middle6 = strAppend03.Substring(6, 6);
            strAppend03Last4 = strAppend03.Substring(12, 4);
        }

        hidAppend03Ext.Value = strAppend03;

        //检测输入票据信息4--终端交易号后(4)位,卡片交易号(4),终端编码(8)
        string strAppend04 = txtAppend04.Text.Trim();

        if (strAppend04 == "")
            context.AddError("A003106016", txtAppend04);

        else if (!Validation.isCharNum(strAppend04))
            context.AddError("A003106049", txtAppend04);//

        else if (Validation.strLen(strAppend04) != 16)
            context.AddError("A003106018", txtAppend04);

        hidAppend04Ext.Value = strAppend04;


        ////终端交易号后(4)位英数字的校验
        //else if (!Validation.isCharNum(strAppend04.Substring(0,4)))
        //    context.AddError("A003106035");

        ////卡片交易号(4)数字的校验
        //else if(!Validation.isNum(strAppend04.Substring(4,4)))
        //    context.AddError("A003106036");

        ////终端编码(8)英数字的校验
        //else if (!Validation.isCharNum(strAppend04.Substring(8, 8)))
        //    context.AddError("A003106037");


        //检测输入票据信息5--TAC码
        string strAppend05 = txtAppend05.Text.Trim();

        if (strAppend05 == "")
            context.AddError("A003106019", txtAppend05);

        else if (!Validation.isCharNum(strAppend05))
            context.AddError("A003106034", txtAppend05);

        else if (Validation.strLen(strAppend05) != 8)
            context.AddError("A003106020", txtAppend05);

        hidAppend05Ext.Value = strAppend05;

         //检测输入票据信息6--员工编号
        string strAppend06 = txtAppend06.Text.Trim();

        if (strAppend06 == "")
            context.AddError("A003106021", txtAppend06);

        else if (!Validation.isNum(strAppend06))
            context.AddError("A003106050", txtAppend06);//

        else if (Validation.strLen(strAppend06) != 6)
            context.AddError("A003106022", txtAppend06);


        //else if (strAppend06 != hidDriverStafffNo.Value)
        //    context.AddError("A003106030");

        hidAppend06Ext.Value = strAppend06;
        if(!context.hasError())
        {
            labAsnNo.Text = strAsnNo;

            hiddTradeDate.Value = strAppend02Front10;
            labTradeDate.Text = "20" + strAppend02Front10.Substring(0, 2) + "-" + strAppend02Front10.Substring(2, 2) + "-" + strAppend02Front10.Substring(4, 2);

            labPreMoney.Text = strAppend02Back6;
            hiddPreMoney.Value = strAppend02Back6;
            labPreMoney.Text = (Convert.ToDouble(labPreMoney.Text) / 100).ToString("0.00");

            labResMoney.Text = strAppend03Front6;
            labResMoney.Text = (Convert.ToDouble(labResMoney.Text) / 100).ToString("0.00");

            labTradeMoney.Text = strAppend03Middle6;
            hiddTradeMoney.Value = strAppend03Middle6;
            labTradeMoney.Text = (Convert.ToDouble(labTradeMoney.Text) / 100).ToString("0.00");
        

            hidPosTradeNo.Value = strAppend03.Substring(12, 4);

            labTradePos.Text = hidPosTradeNo.Value + strAppend04.Substring(0, 4);
            labCardTradeNo.Text = strAppend04.Substring(4, 4);
            labPsam.Text = "0200" + strAppend04.Substring(8, 8);

            labTac.Text = strAppend05;
            labStaffNo.Text = strAppend06;

            return true;
        }

        return false;
    }

    protected void MoneyPay_Select(object sender, EventArgs e)
    {
        //选择了现金支付方式且录入票据信息正确时,补录按钮启用
        if(selPayMoney.SelectedValue != "" && ValidAppendInfo())
            btnConsumeAppend.Enabled = true;
        else
            ClearAppendInfo();
    }


    protected bool GetDriverBalUnitNo()
    {

        String sql = "SELECT BALUNITNO, CORPNO, DEPARTNO FROM TF_TRADE_BALUNIT";

        ArrayList list = new ArrayList();
        list.Add("BALUNITTYPECODE = '03'");
        list.Add("CALLINGNO = '02'");
        list.Add("CALLINGSTAFFNO = '" + labStaffNo.Text + "'");

        sql += DealString.ListToWhereStr(list);

        TMTableModule tm = new TMTableModule();
        DataTable data = null;
        data = tm.selByPKDataTable(context, sql, 0);
        if (data == null || data.Rows.Count == 0) 
        {
            ClearAppendInfo();
            context.AddError("A003106437", txtAppend06);// 无记录
            return false;
         
        }
        else
        {
            Object[] row = data.Rows[0].ItemArray;
            hidBalUnitNo.Value = getCellValue(row[0]);
            hidCorpNo.Value = getCellValue(row[1]);
            hidDepartNo.Value = getCellValue(row[2]);
        }
        return true;
    }


    protected void btnConsumeAppend_Click(object sender, EventArgs e)
    {

         //验证显示的补录信息是否与输入票据框一致
         if (ValidationInputAndShowFalse()) return;

         //取得司机工号对应的结算单元编码
         if(!GetDriverBalUnitNo()) return;

         //调用补录的存储过程
         SP_TS_ConsumeAppendPDO pdo = new SP_TS_ConsumeAppendPDO();

         pdo.IDENTIFYNO   = DealString.GetRecordID(hiddTradeDate.Value.Trim(), labPsam.Text.Trim(), labTac.Text.Trim());
         pdo.ASN          = labAsnNo.Text;        
         pdo.CARDTRADENO  = labCardTradeNo.Text;
         pdo.SAMNO        = labPsam.Text;
         pdo.POSTRADENO   = labTradePos.Text;
         pdo.TRADEDATE    = labTradeDate.Text.Replace("-","");
         pdo.TRADETIME    = hiddTradeDate.Value.Substring(6, 4) + "00";
         pdo.PREMONEY     = Convert.ToInt32(hiddPreMoney.Value);
         pdo.TRADEMONEY   = Convert.ToInt32(hiddTradeMoney.Value);
         pdo.BALUNITNO    = hidBalUnitNo.Value;
         pdo.CALLINGNO    = "02";    //出租行业
         pdo.CORPNO       = hidCorpNo.Value;
         pdo.DEPARTNO     = hidDepartNo.Value;
         pdo.CALLINGSTAFFNO = labStaffNo.Text;
         pdo.TAC            = labTac.Text;
         pdo.DEALSTATECODE  = selPayMoney.SelectedValue;

         bool ok = TMStorePModule.Excute(context, pdo);
         if (ok)
         {
             AddMessage("M003106113");

             txtAppend01.Text = "";
             txtAppend02.Text = "";
             txtAppend03.Text = "";
             txtAppend04.Text = "";
             txtAppend05.Text = "";
             txtAppend06.Text = "";

             btnConsumeAppend.Enabled = false;
         }
       
         ClearAppendInfo();

    }


    private void ClearAppendInfo()
    {
    
        labAsnNo.Text = "";

        labTradeDate.Text = "";
        labPreMoney.Text = "";

        labResMoney.Text = "";
        labTradeMoney.Text = "";

        hidPosTradeNo.Value = "";

        labTradePos.Text ="";
        labCardTradeNo.Text = "";
        labPsam.Text = "";

        labTac.Text = "";
        labStaffNo.Text = "";

        selPayMoney.SelectedValue = "";

        btnConsumeAppend.Enabled = false;

    }


    private void ClearTaxiDriverInfo()
    {
         //hidDriverStafffNo.Value  ="";      
         labCardNo.Text = ""; 
         labCarNo.Text = "" ;   
         labHouseBank.Text = "" ;  
         hidBankCode.Value  =""; 
         labBankAccount.Text = "" ;    
         labStaffName.Text = "";   

         labStaffSex.Text = "";   
         labContactPhone.Text = "";    
         labCarPhone.Text = "" ;    
         labPaperType.Text = "" ;  
         hidPaperTypeNo.Value  ="" ;
         labPaperNo.Text = "" ;     
         labUnitName.Text = "" ;  
         hidCorpNo.Value  ="" ;
         labDeptName.Text = "" ;  
         hidDepartNo.Value  ="" ;
         labPosID.Text = "";   
         labPostCode.Text = ""  ;   
         labEmailAddr.Text = ""   ;
         labContactAddr.Text = ""  ;      
         labCollectCardNo.Text = "" ;      
         labCollectCardPass.Text = "" ;
         labDimssionTag.Text = "";  
    }


    private bool ValidationInputAndShowFalse()
    {
        if ( hidAppend01Ext.Value != txtAppend01.Text.Trim() ||
             hidAppend02Ext.Value != txtAppend02.Text.Trim() ||
             hidAppend03Ext.Value != txtAppend03.Text.Trim() ||
             hidAppend04Ext.Value != txtAppend04.Text.Trim() ||
             hidAppend05Ext.Value != txtAppend05.Text.Trim() ||
             hidAppend06Ext.Value != txtAppend06.Text.Trim()
           )
        {
            ClearAppendInfo();
            context.AddError("A003106438");
            return true;
        }

        return false; 
    }

}
