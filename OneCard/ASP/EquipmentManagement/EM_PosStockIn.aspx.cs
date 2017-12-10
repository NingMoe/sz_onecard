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
//using TDO.CardManager;

public partial class ASP_EquipmentManagement_EM_PosStockIn : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            TMTableModule tmTMTableModule = new TMTableModule();

            /*  POS入库初始化  */

            //初始化POS来源  
            EMHelper.setSource(selEquipSource);

            //初始化POS厂商
            TD_M_POSMANUTDO ddoTD_M_POSMANUTDOIn = new TD_M_POSMANUTDO();
            TD_M_POSMANUTDO[] tdoTD_M_POSMANUTDOOutArr = (TD_M_POSMANUTDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_POSMANUTDOIn, typeof(TD_M_POSMANUTDO), null, "TD_M_POSMANU", null);
            ControlDeal.SelectBoxFillWithCode(selEquipManu.Items, tdoTD_M_POSMANUTDOOutArr,
                "POSMANUNAME", "POSMANUCODE", true);

            //初始化POS型号
            TD_M_POSMODETDO ddoTD_M_POSMODETDOIn = new TD_M_POSMODETDO();
            TD_M_POSMODETDO[] tdoTD_M_POSMODETDOOutArr = (TD_M_POSMODETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_POSMODETDOIn, typeof(TD_M_POSMODETDO), null, "TD_M_POSMODE", null);
            ControlDeal.SelectBoxFillWithCode(selEquipMode.Items, tdoTD_M_POSMODETDOOutArr,
                "POSMODE", "POSMODECODE", true);

            //初始化接触类型
            TD_M_POSTOUCHTYPETDO ddoTD_M_POSTOUCHTYPETDOIn = new TD_M_POSTOUCHTYPETDO();
            TD_M_POSTOUCHTYPETDO[] tdoTD_M_POSTOUCHTYPETDOOutArr = (TD_M_POSTOUCHTYPETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_POSTOUCHTYPETDOIn, typeof(TD_M_POSTOUCHTYPETDO), null, "TD_M_POSTOUCHTYPE", null);
            ControlDeal.SelectBoxFillWithCode(selTouchType.Items, tdoTD_M_POSTOUCHTYPETDOOutArr,
                "TOUCHTYPE", "TOUCHTYPECODE", true);

            //初始化放置类型
            TD_M_POSLAYTYPETDO ddoTD_M_POSLAYTYPETDOIn = new TD_M_POSLAYTYPETDO();
            TD_M_POSLAYTYPETDO[] tdoTD_M_POSLAYTYPETDOOutArr = (TD_M_POSLAYTYPETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_POSLAYTYPETDOIn, typeof(TD_M_POSLAYTYPETDO), null, "TD_M_POSLAYTYPE", null);
            ControlDeal.SelectBoxFillWithCode(selLayType.Items, tdoTD_M_POSLAYTYPETDOOutArr,
                "LAYTYPE", "LAYTYPECODE", true);

            //初始化通信类型
            TD_M_POSCOMMTYPETDO ddoTD_M_POSCOMMTYPETDOIn = new TD_M_POSCOMMTYPETDO();
            TD_M_POSCOMMTYPETDO[] tdoTD_M_POSCOMMTYPETDOOutArr = (TD_M_POSCOMMTYPETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_POSCOMMTYPETDOIn, typeof(TD_M_POSCOMMTYPETDO), null, "TD_M_POSCOMMTYPE", null);
            ControlDeal.SelectBoxFillWithCode(selCommType.Items, tdoTD_M_POSCOMMTYPETDOOutArr,
                "COMMTYPE", "COMMTYPECODE", true);
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