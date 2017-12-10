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

public partial class ASP_EquipmentManagement_EM_StockIn : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            TMTableModule tmTMTableModule = new TMTableModule();
            
            /*  PSAM入库初始化  */

            // 初始化卡片类型
            TD_M_CARDTYPETDO ddoTD_M_CARDTYPETDOIn = new TD_M_CARDTYPETDO();
            TD_M_CARDTYPETDO[] tdoTD_M_CARDTYPETDOOutArr = (TD_M_CARDTYPETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_CARDTYPETDOIn, typeof(TD_M_CARDTYPETDO), null, "TD_M_CARDTYPE", null);
            ControlDeal.SelectBoxFill(selCardType.Items, tdoTD_M_CARDTYPETDOOutArr, "CARDTYPENAME", "CARDTYPECODE", true);

            // 初始化卡厂商
            TD_M_MANUTDO tdoTD_M_MANUTDOIn = new TD_M_MANUTDO();
            TD_M_MANUTDO[] tdoTD_M_MANUTDOOutArr = (TD_M_MANUTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_MANUTDOIn, typeof(TD_M_MANUTDO), null, "TD_M_MANU", null);
            ControlDeal.SelectBoxFill(selManu.Items, tdoTD_M_MANUTDOOutArr, "MANUNAME", "MANUCODE", true);
            
            //初始化COS类型
            TD_M_COSTYPETDO ddoTD_M_COSTYPETDOIn = new TD_M_COSTYPETDO();
            TD_M_COSTYPETDO[] tdoTD_M_COSTYPETDOOutArr = (TD_M_COSTYPETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_COSTYPETDOIn, typeof(TD_M_COSTYPETDO), null, "TD_M_COSTYPE", null);
            ControlDeal.SelectBoxFill(selCosType.Items, tdoTD_M_COSTYPETDOOutArr, "COSTYPE", "COSTYPECODE", true);

            txtFromCardNo.Attributes.Add("OnKeyup", "javascript:return Change();");
            txtToCardNo.Attributes.Add("OnKeyup", "javascript:return Change();");

            /*  POS入库初始化  */

            //初始化POS来源  
            EMHelper.setSource(selEquipSource);

            //初始化POS厂商
            TD_M_POSMANUTDO ddoTD_M_POSMANUTDOIn = new TD_M_POSMANUTDO();
            TD_M_POSMANUTDO[] tdoTD_M_POSMANUTDOOutArr = (TD_M_POSMANUTDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_POSMANUTDOIn, typeof(TD_M_POSMANUTDO), null, "TD_M_POSMANU", null);
            ControlDeal.SelectBoxFill(selEquipManu.Items, tdoTD_M_POSMANUTDOOutArr, "POSMANUNAME", "POSMANUCODE", true);

            //初始化POS型号
            TD_M_POSMODETDO ddoTD_M_POSMODETDOIn = new TD_M_POSMODETDO();
            TD_M_POSMODETDO[] tdoTD_M_POSMODETDOOutArr = (TD_M_POSMODETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_POSMODETDOIn, typeof(TD_M_POSMODETDO), null, "TD_M_POSMODE", null);
            ControlDeal.SelectBoxFill(selEquipMode.Items, tdoTD_M_POSMODETDOOutArr, "POSMODE", "POSMODECODE", true);

            //初始化接触类型
            TD_M_POSTOUCHTYPETDO ddoTD_M_POSTOUCHTYPETDOIn = new TD_M_POSTOUCHTYPETDO();
            TD_M_POSTOUCHTYPETDO[] tdoTD_M_POSTOUCHTYPETDOOutArr = (TD_M_POSTOUCHTYPETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_POSTOUCHTYPETDOIn, typeof(TD_M_POSTOUCHTYPETDO), null, "TD_M_POSTOUCHTYPE", null);
            ControlDeal.SelectBoxFill(selTouchType.Items, tdoTD_M_POSTOUCHTYPETDOOutArr, "TOUCHTYPE", "TOUCHTYPECODE", true);

            //初始化放置类型
            TD_M_POSLAYTYPETDO ddoTD_M_POSLAYTYPETDOIn = new TD_M_POSLAYTYPETDO();
            TD_M_POSLAYTYPETDO[] tdoTD_M_POSLAYTYPETDOOutArr = (TD_M_POSLAYTYPETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_POSLAYTYPETDOIn, typeof(TD_M_POSLAYTYPETDO), null, "TD_M_POSLAYTYPE", null);
            ControlDeal.SelectBoxFill(selLayType.Items, tdoTD_M_POSLAYTYPETDOOutArr, "LAYTYPE", "LAYTYPECODE", true);

            //初始化通信类型
            TD_M_POSCOMMTYPETDO ddoTD_M_POSCOMMTYPETDOIn = new TD_M_POSCOMMTYPETDO();
            TD_M_POSCOMMTYPETDO[] tdoTD_M_POSCOMMTYPETDOOutArr = (TD_M_POSCOMMTYPETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_POSCOMMTYPETDOIn, typeof(TD_M_POSCOMMTYPETDO), null, "TD_M_POSCOMMTYPE", null);
            ControlDeal.SelectBoxFill(selCommType.Items, tdoTD_M_POSCOMMTYPETDOOutArr, "COMMTYPE", "COMMTYPECODE", true);

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
        pdo.cardType = selCardType.SelectedValue;
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

    //POS入库
    protected void btnPos_Click(object sender, EventArgs e)
    {
        //POS入库输入验证
        if (!ValidateForPos())
            return;

        //调用POS入库存储过程
        SP_EM_PosStockInPDO pdo = new SP_EM_PosStockInPDO();
        pdo.posNo = txtEquipNo.Text.Trim();
        pdo.posSort = "00"; //POS
        pdo.posModel = selEquipMode.SelectedValue;
        pdo.touchType = selTouchType.SelectedValue;
        pdo.layType = selLayType.SelectedValue;
        pdo.commType = selCommType.SelectedValue;
        pdo.posPrice = (int)(float.Parse(txtEquipPrice.Text.Trim()) * 100);
        pdo.posManu = selEquipManu.SelectedValue;
        pdo.posSource = selEquipSource.SelectedValue;
        pdo.hardwareNum = txtHardwareNum.Text.Trim();

        bool ok = TMStorePModule.Excute(context, pdo);
        if (ok)
        {
            AddMessage("M006001051");
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
            if (!Validation.isNum(strBeginCardNo.Substring(2)) || !Validation.isCharNum(strBeginCardNo.Substring(0,2)))
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
        string strCardType = selCardType.SelectedValue;
        if (strCardType == "")
            context.AddError("A006001083", selCardType);

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
        if(strAppVersion == "")
            context.AddError("A006001011",txtAppVersion);
        else if(!Validation.isCharNum(strAppVersion))
            context.AddError("A006001012",txtAppVersion);

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

    private bool ValidateForPos()
    {
        //POS编号非空、数字、长度判断
        string strEquipNo = txtEquipNo.Text.Trim();
        if (strEquipNo == "")
            context.AddError("A006001135", txtEquipNo);
        else
        {
            if (!Validation.isNum(strEquipNo))
                context.AddError("A006001136", txtEquipNo);
            if (Validation.strLen(strEquipNo) != 6)
                context.AddError("A006001137", txtEquipNo);
        }

        //POS来源非空
        string strPosSource = selEquipSource.SelectedValue;
        if (strPosSource == "")
            context.AddError("A006001020", selEquipSource);

        //POS厂商非空
        string strEquipManu = selEquipManu.SelectedValue;
        if (strEquipManu == "")
            context.AddError("A006001028", selEquipManu);

        //POS型号非空
        string strEquipMode = selEquipMode.SelectedValue;
        if (strEquipMode == "")
            context.AddError("A006001024", selEquipMode);

        //接触类型非空
        string strTouchType = selTouchType.SelectedValue;
        if (strTouchType == "")
            context.AddError("A006001025", selTouchType);

        //放置类型非空
        string strLayType = selLayType.SelectedValue;
        if (strLayType == "")
            context.AddError("A006001033", selLayType);

        //通信类型非空
        string strCommType = selCommType.SelectedValue;
        if (strCommType == "")
            context.AddError("A006001033", selCommType);

        //硬件序列号非空、英数、长度判断
        string strHardwareNum = txtHardwareNum.Text.Trim();
        if (strHardwareNum == "")
            context.AddError("A006001029", txtHardwareNum);
        else
        {
            if (!Validation.isCharNum(strHardwareNum))
                context.AddError("A006001030", txtHardwareNum);
            if (Validation.strLen(strHardwareNum) > 50)
                context.AddError("A006001031", txtHardwareNum);
        }

        //POS价格非空、数字判断
        string strEquipPrice = txtEquipPrice.Text.Trim();
        if (strEquipPrice == "")
            context.AddError("A006001082", txtEquipPrice);
        else
        {
            if (!Validation.isPrice(strEquipPrice))
                context.AddError("A006001078", txtEquipPrice);
        }

        if (context.hasError())
            return false;
        else
            return true;
    }

}
