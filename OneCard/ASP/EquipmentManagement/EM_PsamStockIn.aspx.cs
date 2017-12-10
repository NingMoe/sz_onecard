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
using TDO.ResourceManager;
using PDO.EquipmentManagement;
using TDO.CardManager;

public partial class ASP_EquipmentManagement_EM_PsamStockIn : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            TMTableModule tmTMTableModule = new TMTableModule();

            /*  PSAM入库初始化  */

            // 初始化卡片类型
            //TD_M_CARDTYPETDO ddoTD_M_CARDTYPETDOIn = new TD_M_CARDTYPETDO();
            //TD_M_CARDTYPETDO[] tdoTD_M_CARDTYPETDOOutArr = (TD_M_CARDTYPETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_CARDTYPETDOIn, typeof(TD_M_CARDTYPETDO), null, "TD_M_CARDTYPE", null);
            //ControlDeal.SelectBoxFill(selCardType.Items, tdoTD_M_CARDTYPETDOOutArr, "CARDTYPENAME", "CARDTYPECODE", true);

            // 初始化卡厂商
            TD_M_MANUTDO tdoTD_M_MANUTDOIn = new TD_M_MANUTDO();
            TD_M_MANUTDO[] tdoTD_M_MANUTDOOutArr = (TD_M_MANUTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_MANUTDOIn, typeof(TD_M_MANUTDO), null, "TD_M_MANU", null);
            ControlDeal.SelectBoxFillWithCode(selManu.Items, tdoTD_M_MANUTDOOutArr,
                "MANUNAME", "MANUCODE", true);

            //初始化COS类型
            TD_M_COSTYPETDO ddoTD_M_COSTYPETDOIn = new TD_M_COSTYPETDO();
            TD_M_COSTYPETDO[] tdoTD_M_COSTYPETDOOutArr = (TD_M_COSTYPETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_COSTYPETDOIn, typeof(TD_M_COSTYPETDO), null, "TD_M_COSTYPE", null);
            ControlDeal.SelectBoxFillWithCode(selCosType.Items, tdoTD_M_COSTYPETDOOutArr,
               "COSTYPE", "COSTYPECODE", true);

            txtFromCardNo.Attributes.Add("OnKeyup", "javascript:return Change();");
            txtToCardNo.Attributes.Add("OnKeyup", "javascript:return Change();");
        }
    }

    //PSAM卡入库

    protected void btnPsam_Click(object sender, EventArgs e)
    {
        //PSAM入库输入验证
        if (!ValidateForPsam())
            return;

        string strBeginCardNo = txtFromCardNo.Text.Trim();
        string strEndCardNo = txtToCardNo.Text.Trim();
        string prefix = strBeginCardNo.Substring(0, 2);
        long firstNo = long.Parse(strBeginCardNo.Substring(2));
        long endNo = long.Parse(strEndCardNo.Substring(2));
        int amount = (int)(endNo - firstNo + 1);

        //调用PSAM入库存储过程
        SP_EM_PsamStockInPDO pdo = new SP_EM_PsamStockInPDO();
        pdo.prefix = prefix;
        pdo.firstNo = firstNo;
        pdo.amount = amount;
        pdo.length = 12;
        pdo.cardKind = "00";  //PSAM卡
        pdo.cosType = selCosType.SelectedValue;
        pdo.appVersion = txtAppVersion.Text.Trim();
        pdo.cardType = txtCardType.Text.Trim();
        pdo.cardPrice = (int)(float.Parse(txtCardPrice.Text.Trim()) * 100);
        pdo.cardManu = selManu.SelectedValue;
        pdo.validBeginDate = convertDateFormat(txtFromDate.Text.Trim());
        pdo.validEndDate = convertDateFormat(txtToDate.Text.Trim());

        bool ok = TMStorePModule.Excute(context, pdo);
        if (ok)
        {
            AddMessage("M006001050");
        }
    }

    private string convertDateFormat(string strDate)
    {
        return strDate.Replace("-", "");
    }

    private bool ValidateForPsam()
    {
        //起始卡号判断：非空、长度12、数字

        string strBeginCardNo = txtFromCardNo.Text.Trim();
        if (strBeginCardNo == "")
            context.AddError("A006001002", txtFromCardNo);
        else
        {
            if (Validation.strLen(strBeginCardNo) != 12)
                context.AddError("A006001003", txtFromCardNo);
            if (!Validation.isNum(strBeginCardNo.Substring(2)) || !Validation.isCharNum(strBeginCardNo.Substring(0, 2)))
                context.AddError("A006001004", txtFromCardNo);
        }

        //终止卡号：非空、长度12
        string strEndCardNo = txtToCardNo.Text.Trim();
        if (strEndCardNo == "")
            context.AddError("A006001005", txtToCardNo);
        else
        {
            if (Validation.strLen(strEndCardNo) != 12)
                context.AddError("A006001006", txtToCardNo);

            //后10位为数字，前两位为英数

            if (!Validation.isNum(strEndCardNo.Substring(2)) || !Validation.isCharNum(strEndCardNo.Substring(0, 2)))
                context.AddError("A006001007", txtToCardNo);
            else if (Validation.isNum(strBeginCardNo.Substring(2)))
            {
                //终止卡号不小于起始卡号、批量入库数量小于10000
                long iBeginCardNo = long.Parse(strBeginCardNo.Substring(2));
                long iEndCardNo = long.Parse(strEndCardNo.Substring(2));
                long n = iEndCardNo - iBeginCardNo + 1;
                if (n < 0)
                    context.AddError("A006001008", txtToCardNo);
                else if (n > 10000)
                    context.AddError("A006001032", txtToCardNo);
            }
        }

        //起始卡号与终止卡号前两位必须一致

        if (strBeginCardNo != "" && strEndCardNo != "")
        {
            if (strBeginCardNo.Substring(0, 2) != strEndCardNo.Substring(0, 2))
                context.AddError("A006001038", txtToCardNo);
        }

        //卡片厂商非空
        string strCardManu = selManu.SelectedValue;
        if (strCardManu == "")
            context.AddError("A006001010", selManu);

        //COS类型非空
        string strCosType = selCosType.SelectedValue;
        if (strCosType == "")
            context.AddError("A006001009", selCosType);

        //卡片类型非空
        string strCardType = txtCardType.Text.Trim();
        if (Validation.strLen(strCardType) > 2)
            context.AddError("A006001083", txtCardType);

        //起始有效期非空

        string strValidBeginDate = txtFromDate.Text.Trim();
        if (strValidBeginDate == "")
            context.AddError("A006001013", txtFromDate);
        else
        {   //验证日期格式
            if (!Validation.isDate(strValidBeginDate, "yyyy-MM-dd"))
                context.AddError("A006001014", txtFromDate);

        }

        //终止有效期非空

        string strValidEndDate = txtToDate.Text.Trim();
        if (strValidEndDate == "")
            context.AddError("A006001016", txtToDate);
        else
        {   //验证日期格式
            if (!Validation.isDate(strValidEndDate, "yyyy-MM-dd"))
                context.AddError("A006001017", txtToDate);
            else if (Validation.isDate(strValidBeginDate, "yyyy-MM-dd"))
            {
                DateTime beginDate = DateTime.ParseExact(strValidBeginDate, "yyyy-MM-dd", null);
                DateTime endDate = DateTime.ParseExact(strValidEndDate, "yyyy-MM-dd", null);
                //起始日期小于终止日期
                if (beginDate.CompareTo(endDate) > 0)
                    context.AddError("A006001019", txtToDate);

            }
        }

        //应用版本非空、且为英数

        string strAppVersion = txtAppVersion.Text.Trim();
        if (strAppVersion == "")
            context.AddError("A006001011", txtAppVersion);
        else if (!Validation.isCharNum(strAppVersion))
            context.AddError("A006001012", txtAppVersion);

        //卡片单价非空、数字

        string strCardPrice = txtCardPrice.Text.Trim();
        if (strCardPrice == "")
            context.AddError("A006001080", txtCardPrice);
        else
        {
            if (!Validation.isPrice(strCardPrice))
                context.AddError("A006001074", txtCardPrice);
        }

        if (context.hasError())
            return false;
        else
            return true;

    }
}