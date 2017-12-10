using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using TDO.ResourceManager;
using TDO.UserManager;
using TM;
using TDO.CardManager;
using PDO.PersonalBusiness;
using Master;
using Common;
using TDO.BusinessCode;



public partial class ASP_ResourceManage_RM_StaffSignIn : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            if (!context.s_Debugging) txtCardno.Attributes["readonly"] = "true";
            setReadOnly(LabAsn, RESSTATE, LabCardtype, sDate, eDate, cMoney);
            
        }
        btnSubmit.Enabled = false;
    }
    /// <summary>
    /// 读卡事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        clearCustInfo(LabAsn,LabCardtype,RESSTATE,sDate,eDate,cMoney,txtCusname,txtCustbirth,txtPapertype,txtCustpaperno,txtCustsex,txtCustphone,txtCustpost,txtCustaddr,txtEmail);
        btnReadCardProcess();
    }
    protected void btnReadCardProcess()
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        ////卡账户有效性检验

        //SP_AccCheckPDO pdo = new SP_AccCheckPDO();
        //pdo.CARDNO = txtCardno.Text;
        //bool ok = TMStorePModule.Excute(context, pdo);

        //if (ok)
        //{
            //从IC卡类型编码表(TD_M_CARDTYPE)中读取数据


            TD_M_CARDTYPETDO ddoTD_M_CARDTYPEIn = new TD_M_CARDTYPETDO();
            ddoTD_M_CARDTYPEIn.CARDTYPECODE = hiddenLabCardtype.Value;
            if (hiddenLabCardtype.Value != "08" && hiddenLabCardtype.Value != "09")//不是市民卡B卡则提示错误不允许签到
            {
                context.AddError("A001107113:此卡不是市民卡B卡");
                return;
            }

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
            cMoney.Text = ((Convert.ToDecimal(hiddencMoney.Value)) / (Convert.ToDecimal(100))).ToString("0.00");
            txtCusname.Text = ddoTF_F_CUSTOMERRECOut.CUSTNAME;

            //检验卡片是否已经启用

            if (String.Compare(hiddensDate.Value, DateTime.Today.ToString("yyyyMMdd")) > 0)
            {
                context.AddError("卡片尚未启用");
                return;
            }

            //性别显示
            if (ddoTF_F_CUSTOMERRECOut.CUSTSEX == "0")
                txtCustsex.Text = "男";
            else if (ddoTF_F_CUSTOMERRECOut.CUSTSEX == "1")
                txtCustsex.Text = "女";
            else txtCustsex.Text = "";

            //出生日期显示
            if (ddoTF_F_CUSTOMERRECOut.CUSTBIRTH != "")
            {
                String Bdate = ddoTF_F_CUSTOMERRECOut.CUSTBIRTH;
                if (Bdate.Length == 8)
                {
                    txtCustbirth.Text = Bdate.Substring(0, 4) + "-" + Bdate.Substring(4, 2) + "-" + Bdate.Substring(6, 2);
                }
                else txtCustbirth.Text = Bdate;
            }
            else txtCustbirth.Text = ddoTF_F_CUSTOMERRECOut.CUSTBIRTH;

            //证件类型显示
            if (ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE != "")
            {
                txtPapertype.Text = ddoTD_M_PAPERTYPEOut.PAPERTYPENAME;
            }
            else txtPapertype.Text = ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE;

            txtCustpaperno.Text = ddoTF_F_CUSTOMERRECOut.PAPERNO;
            txtCustaddr.Text = ddoTF_F_CUSTOMERRECOut.CUSTADDR;
            txtCustpost.Text = ddoTF_F_CUSTOMERRECOut.CUSTPOST;
            txtCustphone.Text = ddoTF_F_CUSTOMERRECOut.CUSTPHONE;
            txtEmail.Text = ddoTF_F_CUSTOMERRECOut.CUSTEMAIL;

            btnSubmit.Enabled = true;
            

        //}
    }
    /// <summary>
    /// 提交事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        if (txtCardno.Text.ToString() == string.Empty || txtCusname.Text.ToString() == string.Empty)
        {
            context.AddError("A001002103：请读卡");
            return;
        }
        if(context.hasError())
        {
            return;
        }
        context.SPOpen();
        context.AddField("P_CARDNO").Value = txtCardno.Text.Trim();//卡号
        context.AddField("P_STAFFNAME").Value = txtCusname.Text.Trim();//签到员工姓名
        bool ok = context.ExecuteSP("SP_RM_OTHER_STAFFSIGNIN");
        if (ok)
        {
             AddMessage("提交成功");
        }
    }
    
}