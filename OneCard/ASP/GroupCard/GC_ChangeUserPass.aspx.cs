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
using Master;
using TDO.CardManager;
using TM;
using Common;
using TDO.BusinessCode;
using PDO.GroupCard;
using PDO.PersonalBusiness;

public partial class ASP_GroupCard_GC_ChangeUserPass : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;


        if (!context.s_Debugging) txtCardno.Attributes["readonly"] = "true";

    }


    protected void btnChangeUserPassCardread_Click(object sender, EventArgs e)
    {

        TMTableModule tmTMTableModule = new TMTableModule();

        SP_AccCheckPDO pdo = new SP_AccCheckPDO();
        pdo.CARDNO = txtCardno.Text;
        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            //从集团客户-企服卡对应关系表中读取数据
            TD_GROUP_CARDTDO ddoTD_GROUP_CARDIn = new TD_GROUP_CARDTDO();
            ddoTD_GROUP_CARDIn.CARDNO = txtCardno.Text;

            TD_GROUP_CARDTDO ddoTD_GROUP_CARDOut = (TD_GROUP_CARDTDO)tmTMTableModule.selByPK(context, ddoTD_GROUP_CARDIn, typeof(TD_GROUP_CARDTDO), null, "TD_GROUP_CARD", null);

            if (ddoTD_GROUP_CARDOut == null)
            {
                context.AddError("A001107110");
                return;
            }

            //从企服卡可充值账户表中读取数据
            TF_F_CARDOFFERACCTDO ddoTF_F_CARDOFFERACCIn = new TF_F_CARDOFFERACCTDO();
            ddoTF_F_CARDOFFERACCIn.CARDNO = txtCardno.Text;

            TF_F_CARDOFFERACCTDO ddoTF_F_CARDOFFERACCInOut = (TF_F_CARDOFFERACCTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDOFFERACCIn, typeof(TF_F_CARDOFFERACCTDO), "A001107110", "TF_F_CARDOFFERACC", null);

            if (ddoTF_F_CARDOFFERACCInOut == null)
            {
                context.AddError("A001107110");
                return;
            }

            if (ddoTF_F_CARDOFFERACCInOut.USETAG != "1")
            {
                context.AddError("A001107111");
                return;
            }

            //从集团客户资料表中读取数据
            TD_GROUP_CUSTOMERTDO ddoTD_GROUP_CUSTOMERIn = new TD_GROUP_CUSTOMERTDO();
            ddoTD_GROUP_CUSTOMERIn.CORPCODE = ddoTD_GROUP_CARDOut.CORPNO;
            ddoTD_GROUP_CUSTOMERIn.USETAG = "1";

            TD_GROUP_CUSTOMERTDO ddoTD_GROUP_CUSTOMEROut = (TD_GROUP_CUSTOMERTDO)tmTMTableModule.selByPK(context, ddoTD_GROUP_CUSTOMERIn, typeof(TD_GROUP_CUSTOMERTDO), "A001107110", "TD_GROUP_CUSTOMER_CHANGE", null);

            if (ddoTD_GROUP_CUSTOMEROut == null)
            {
                context.AddError("A004111013");
                return;
            }

            //从持卡人资料表(TF_F_CUSTOMERREC)中读取数据

            TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECIn = new TF_F_CUSTOMERRECTDO();
            ddoTF_F_CUSTOMERRECIn.CARDNO = txtCardno.Text;

            //UPDATE BY JIANGBB 2012-04-19解密
            DDOBase ddoBase = (DDOBase)tmTMTableModule.selByPK(context, ddoTF_F_CUSTOMERRECIn, typeof(TF_F_CUSTOMERRECTDO), null);

            ddoBase = CommonHelper.AESDeEncrypt(ddoBase);
            TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECOut = (TF_F_CUSTOMERRECTDO)ddoBase;
            //TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECOut = (TF_F_CUSTOMERRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CUSTOMERRECIn, typeof(TF_F_CUSTOMERRECTDO), null, "TF_F_CUSTOMERREC", null);

            if (ddoTF_F_CUSTOMERRECOut == null)
            {
                context.AddError("A001107112");
                return;
            }

            //从证件类型编码表(TD_M_PAPERTYPE)中读取数据

            TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEIn = new TD_M_PAPERTYPETDO();
            ddoTD_M_PAPERTYPEIn.PAPERTYPECODE = ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE;

            TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEOut = (TD_M_PAPERTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_PAPERTYPEIn, typeof(TD_M_PAPERTYPETDO), null, "TD_M_PAPERTYPE_DESTROY", null);

            CustName.Text = ddoTF_F_CUSTOMERRECOut.CUSTNAME;
            if (ddoTF_F_CUSTOMERRECOut == null)
            {
                Papertype.Text = "";
            }

            if (ddoTF_F_CUSTOMERRECOut.CUSTSEX == "0")
                Custsex.Text = "男";
            else if (ddoTF_F_CUSTOMERRECOut.CUSTSEX == "1")
                Custsex.Text = "女";
            else Custsex.Text = "";

            if (ddoTF_F_CUSTOMERRECOut.CUSTBIRTH != "")
            {
                String Bdate = ddoTF_F_CUSTOMERRECOut.CUSTBIRTH;
                if (Bdate.Length == 8)
                {
                    CustBirthday.Text = Bdate.Substring(0, 4) + "-" + Bdate.Substring(4, 2) + "-" + Bdate.Substring(6, 2);
                }
                else CustBirthday.Text = Bdate;
            }
            else CustBirthday.Text = ddoTF_F_CUSTOMERRECOut.CUSTBIRTH;

            if (ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE != "")
            {
                Papertype.Text = ddoTD_M_PAPERTYPEOut.PAPERTYPENAME;
            }
            else Papertype.Text = "";

            Paperno.Text = ddoTF_F_CUSTOMERRECOut.PAPERNO;
            Custaddr.Text = ddoTF_F_CUSTOMERRECOut.CUSTADDR;
            Custpost.Text = ddoTF_F_CUSTOMERRECOut.CUSTPOST;
            Custphone.Text = ddoTF_F_CUSTOMERRECOut.CUSTPHONE;
            txtEmail.Text = ddoTF_F_CUSTOMERRECOut.CUSTEMAIL;
            Corpname.Text = ddoTD_GROUP_CUSTOMEROut.CORPNAME;

            //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
            if (!CommonHelper.HasOperPower(context))
            {
                Paperno.Text = CommonHelper.GetPaperNo(Paperno.Text);
                Custphone.Text = CommonHelper.GetCustPhone(Custphone.Text);
                Custaddr.Text = CommonHelper.GetCustAddress(Custaddr.Text);
            }

            btnChangeUserPass.Enabled = true;
        }
    }

    private Boolean ChangePasswordValidation()
    {
        //对原密码进行非空、长度、数字检验

        String strOPwd = txtOPwd.Text.Trim();

        if (strOPwd == "")
            context.AddError("A004111001", txtOPwd);
        else
        {
            int len = Validation.strLen(strOPwd);

            if (Validation.strLen(strOPwd) != 6)
                context.AddError("A004111002", txtOPwd);
            else if (!Validation.isNum(strOPwd))
                context.AddError("A004111003", txtOPwd);

        }

        //对新密码进行非空、长度、英数检验

        String strNPwd = txtNPwd.Text.Trim();
        if (strNPwd == "")
            context.AddError("A004111004", txtNPwd);
        else
        {
            int len = Validation.strLen(strNPwd);

            if (Validation.strLen(strNPwd) != 6)
                context.AddError("A004111005", txtNPwd);
            else if (!Validation.isNum(strNPwd))
                context.AddError("A004111006", txtNPwd);

        }

        //对新密码确认进行非空检验

        String strANPwd = txtANPwd.Text.Trim();

        if (strANPwd == "")
            context.AddError("A004111007", txtANPwd);

        //对原密码与新密码是否一样进行检验

        if (!context.hasError())
        {
            if (strOPwd == strNPwd)
                context.AddError("A004111008", txtANPwd);
        }

        //对新密码与新密码确认是否一样进行检验

        if (!context.hasError())
        {
            if (strNPwd != strANPwd)
                context.AddError("A004111009", txtANPwd);
        }

        if (context.hasError())
            return false;
        else
            return true;
    }

    protected void btnChangeUserPass_Click(object sender, EventArgs e)
    {
        if (!ChangePasswordValidation())
            return;

        if (txtCardno.Text == "")
        {
            context.AddError("A005001100");
            return;
        }

        TMTableModule tmTMTableModule = new TMTableModule();

        //从集团客户-企服卡对应关系表中读取数据
        TD_GROUP_CARDTDO ddoTD_GROUP_CARDIn = new TD_GROUP_CARDTDO();
        ddoTD_GROUP_CARDIn.CARDNO = txtCardno.Text;

        TD_GROUP_CARDTDO ddoTD_GROUP_CARDOut = (TD_GROUP_CARDTDO)tmTMTableModule.selByPK(context, ddoTD_GROUP_CARDIn, typeof(TD_GROUP_CARDTDO),"A001107110", "TD_GROUP_CARD", null);

        SP_GC_ChangeUserPassPDO pdo = new SP_GC_ChangeUserPassPDO();

        pdo.CARDNO = txtCardno.Text;
        pdo.CORPNO = ddoTD_GROUP_CARDOut.CORPNO;
        pdo.OLDPASSWD = DealString.encrypPass(txtOPwd.Text.Trim());
        pdo.NEWPASSWD = DealString.encrypPass(txtNPwd.Text.Trim());

        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            AddMessage("M001111001");
            foreach (Control con in this.Page.Controls)
            {
                ClearControl(con);
            }
            btnChangeUserPass.Enabled = false;
        }

    }

}
