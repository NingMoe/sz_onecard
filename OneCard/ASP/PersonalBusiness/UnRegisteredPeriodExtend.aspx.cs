using System;
using System.Text;
using System.Collections;
using System.Web.UI;
using TM;
using TDO.CardManager;
using TDO.BusinessCode;
using Common;
using PDO.PersonalBusiness;
using TDO.ResourceManager;
using Master;
using TDO.UserManager;
using System.Data;
using System.Web.UI.WebControls;
using System.Diagnostics;

public partial class ASP_PersonalBusiness_UnRegisteredPeriodExtend : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            setReadOnly(LabAsn, LabCardtype, sDate, eDate, cMoney, RESSTATE, sellTime);

            if (!context.s_Debugging) setReadOnly(txtCardno);
            //下拉框初始化
            ListItem item1 = new ListItem("5年", "5");
            ListItem item2 = new ListItem("3年", "3");
            ListItem item3 = new ListItem("1年", "1");
            selExtendYear.Items.Add(item1);
            selExtendYear.Items.Add(item2);
            selExtendYear.Items.Add(item3);

            ScriptManager2.SetFocus(btnReadCard);
        }
    }

    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        btnSupply.Enabled = false;
        btnReadCardProcess();
        if (context.hasError())
        {
            ScriptManager2.SetFocus(btnReadCard);
            return;
        }
    }

    protected void btnReadCardProcess()
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        //卡账户有效性检验
        SP_AccCheckPDO pdo = new SP_AccCheckPDO();
        pdo.CARDNO = txtCardno.Text;
        PDOBase pdoOut;
        bool ok = TMStorePModule.Excute(context, pdo, out pdoOut);

        if (ok)
        {
            //从IC卡类型编码表(TD_M_CARDTYPE)中读取数据
            TD_M_CARDTYPETDO ddoTD_M_CARDTYPEIn = new TD_M_CARDTYPETDO();
            ddoTD_M_CARDTYPEIn.CARDTYPECODE = hiddenLabCardtype.Value;

            TD_M_CARDTYPETDO ddoTD_M_CARDTYPEOut = (TD_M_CARDTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_CARDTYPEIn, typeof(TD_M_CARDTYPETDO), null, "TD_M_CARDTYPE_CHUSER", null);

            //从持卡人资料表(TF_F_CUSTOMERREC)中读取数据
            TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECIn = new TF_F_CUSTOMERRECTDO();
            ddoTF_F_CUSTOMERRECIn.CARDNO = txtCardno.Text;

            //UPDATE BY JIANGBB 2012-04-19解密
            DDOBase ddoBase = (DDOBase)tmTMTableModule.selByPK(context, ddoTF_F_CUSTOMERRECIn, typeof(TF_F_CUSTOMERRECTDO), null);

            ddoBase = CommonHelper.AESDeEncrypt(ddoBase);
            TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECOut = (TF_F_CUSTOMERRECTDO)ddoBase;
            //TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECOut = (TF_F_CUSTOMERRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CUSTOMERRECIn, typeof(TF_F_CUSTOMERRECTDO), null);

            if (ddoTF_F_CUSTOMERRECOut == null)
            {
                context.AddError("A001107112");
                return;
            }

            //for test -- begin
            if (!string.IsNullOrEmpty(ddoTF_F_CUSTOMERRECOut.PAPERNO) || !string.IsNullOrEmpty(ddoTF_F_CUSTOMERRECOut.CUSTNAME))//表示此卡是记名卡
            {
                context.AddError("此卡是记名卡，请确认！");
                return;
            }
            //for test -- end


            //从用户卡库存表(TL_R_ICUSER)中读取数据
            TL_R_ICUSERTDO ddoTL_R_ICUSERIn = new TL_R_ICUSERTDO();
            ddoTL_R_ICUSERIn.CARDNO = txtCardno.Text;

            TL_R_ICUSERTDO ddoTL_R_ICUSEROut = (TL_R_ICUSERTDO)tmTMTableModule.selByPK(context, ddoTL_R_ICUSERIn, typeof(TL_R_ICUSERTDO), null, "TL_R_ICUSER", null);

            if (ddoTL_R_ICUSEROut == null)
            {
                context.AddError("A001001101");
                return;
            }

            //从资源状态编码表中读取数据
            TD_M_RESOURCESTATETDO ddoTD_M_RESOURCESTATEIn = new TD_M_RESOURCESTATETDO();
            ddoTD_M_RESOURCESTATEIn.RESSTATECODE = ddoTL_R_ICUSEROut.RESSTATECODE;

            TD_M_RESOURCESTATETDO ddoTD_M_RESOURCESTATEOut = (TD_M_RESOURCESTATETDO)tmTMTableModule.selByPK(context, ddoTD_M_RESOURCESTATEIn, typeof(TD_M_RESOURCESTATETDO), null, "TD_M_RESOURCESTATE", null);

            if (ddoTD_M_RESOURCESTATEOut == null)
                RESSTATE.Text = ddoTL_R_ICUSEROut.RESSTATECODE;
            else
                RESSTATE.Text = ddoTD_M_RESOURCESTATEOut.RESSTATE;

            //从证件类型编码表(TD_M_PAPERTYPE)中读取数据


            TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEIn = new TD_M_PAPERTYPETDO();
            ddoTD_M_PAPERTYPEIn.PAPERTYPECODE = ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE;

            TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEOut = (TD_M_PAPERTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_PAPERTYPEIn, typeof(TD_M_PAPERTYPETDO), null, "TD_M_PAPERTYPE_DESTROY", null);

            //给页面显示项赋值


            LabAsn.Text = hiddenAsn.Value.Substring(4, 16);
            LabCardtype.Text = ddoTD_M_CARDTYPEOut.CARDTYPENAME;
            sDate.Text = ASHelper.toDateWithHyphen(hiddensDate.Value);
            eDate.Text = ASHelper.toDateWithHyphen(hiddeneDate.Value);
            if (hiddeneDate.Value == "99991231")
            {
                eDate.Text = "无有效期";
            }
            cMoney.Text = ((Convert.ToDecimal(hiddencMoney.Value)) / (Convert.ToDecimal(100))).ToString("0.00");

            //检验卡片是否已经启用


            if (String.Compare(hiddensDate.Value, DateTime.Today.ToString("yyyyMMdd")) > 0)
            {
                context.AddError("卡片尚未启用");
                return;
            }

            TF_F_CARDRECTDO ddoTF_F_CARDRECIn = new TF_F_CARDRECTDO();
            ddoTF_F_CARDRECIn.CARDNO = txtCardno.Text;

            TF_F_CARDRECTDO ddoTF_F_CARDRECOut = (TF_F_CARDRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDRECIn, typeof(TF_F_CARDRECTDO), null);
            sellTime.Text = ddoTF_F_CARDRECOut.SELLTIME.ToString("yyyy-MM-dd");
            CommonHelper.readCardJiMingState(context, txtCardno.Text, hidIsJiMing);
            //查询卡片开通功能并显示
            PBHelper.openFunc(context, openFunc, txtCardno.Text);

            bool IsOpenMonth = false;
            string openFuncStr = "本卡为";
            foreach (object list in openFunc.List)
            {
                if (list.ToString() == "学生月票")
                {
                    openFuncStr += "学生月票、";
                    IsOpenMonth = true;
                }
                if (list.ToString() == "老人月票")
                {
                    openFuncStr += "老人月票、";
                    IsOpenMonth = true;
                }
                if (list.ToString() == "高龄卡")
                {
                    openFuncStr += "高龄卡、";
                    IsOpenMonth = true;
                }
                if (list.ToString() == "残疾人月票")
                {
                    openFuncStr += "残疾人月票、";
                    IsOpenMonth = true;
                }
                if (list.ToString() == "张家港残疾人月票")
                {
                    openFuncStr += "张家港残疾人月票、";
                    IsOpenMonth = true;
                }
                if (list.ToString() == "张家港老年人月票")
                {
                    openFuncStr += "张家港老年人月票、";
                    IsOpenMonth = true;
                }
                if (list.ToString() == "张家港公交员工卡")
                {
                    openFuncStr += "张家港公交员工卡、";
                    IsOpenMonth = true;
                }
            }
            if (IsOpenMonth == true)
            {
                openFuncStr = openFuncStr.TrimEnd(new char[] { '、' });

                ScriptManager.RegisterStartupScript(this, this.GetType(), "AdjustScript", "submitConfirm('" + openFuncStr + "');", true);
            }

            btnSupply.Enabled = true;
            btnPrintPZ.Enabled = false;
        }
        else if (pdoOut.retCode == "A001107199")
        {//验证如果是黑名单卡，锁卡
            this.LockBlackCard(txtCardno.Text);
            this.hidLockBlackCardFlag.Value = "yes";
        }
    }

    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "yes")
        {
            btnSupply.Enabled = true;
        }
        else if (hidWarning.Value == "writeSuccess")
        {
            AddMessage("前台写卡成功");
            btnPrintPZ.Enabled = true;
            btnSupply.Enabled = false;
            //如果是自动打印凭证，接着打印
            buildPingZhengContent();
            if (chkPingzheng.Checked)
            {
                ScriptManager.RegisterStartupScript(
                    this, this.GetType(), "writeCardScript",
                    "printInvoice();", true);
            }
        }
        else if (hidWarning.Value == "writeFail")
        {
            context.AddError("前台写卡失败");
        }
    }

    protected void btnSupply_Click(object sender, EventArgs e)
    {
        string availableDateStr = "";
        string orignHiddeneDate = hiddeneDate.Value;
        string extendYear = selExtendYear.Text;
        if (string.IsNullOrEmpty(extendYear) || string.IsNullOrEmpty(orignHiddeneDate) || orignHiddeneDate == "99991231")
        {
            return;
        }
        DateTime orignDt = new DateTime(Convert.ToInt32(orignHiddeneDate.Substring(0,4)), Convert.ToInt32(orignHiddeneDate.Substring(4,2)), Convert.ToInt32(orignHiddeneDate.Substring(6,2)));
        orignDt = orignDt.AddYears(Convert.ToInt32(extendYear));
        availableDateStr = orignDt.ToString("yyyyMMdd");

        hidModiEndDate.Value = availableDateStr;
        ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCard", "writeCardPeriodExtend();", true);
    }

    private void buildPingZhengContent()
    {
        ASHelper.preparePingZheng(ptnPingZheng, hiddentxtCardno.Value, "",
                "取消有效期", "0", "", "", "", "", "", "0", context.s_UserName, "取消有效期", "", "", "");
    }
}
