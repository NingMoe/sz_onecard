using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web.UI;
using Common;
using DataExchange;
using Master;
using PDO.PersonalBusiness;
using TDO.BusinessCode;
using TDO.CardManager;
using TDO.ResourceManager;
using TM;

public partial class ASP_PersonalBusiness_PB_ChangeUserInfo : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            btnReadCard.Attributes["onclick"] = "javascript:readCard()";
            LabAsn.Attributes["readonly"] = "true";
            LabCardtype.Attributes["readonly"] = "true";
            sDate.Attributes["readonly"] = "true";
            eDate.Attributes["readonly"] = "true";
            cMoney.Attributes["readonly"] = "true";

            ASHelper.initSexList(selCustsex);
            initLoad(sender, e);
        }
    }

    protected void initLoad(object sender, EventArgs e)
    {
        //从证件类型编码表(TD_M_PAPERTYPE)中读取数据，放入下拉列表中

        ASHelper.initPaperTypeList(context, selPapertype);
    }

    private Boolean ChangeUserInfoDBreadValidation()
    {
        //对卡号进行非空、长度、数字检验

        if (txtCardno.Text.Trim() == "")
            context.AddError("A001004113", txtCardno);
        else
        {
            if (Validation.strLen(txtCardno.Text.Trim()) != 16)
                context.AddError("A001004114", txtCardno);
            else if (!Validation.isNum(txtCardno.Text.Trim()))
                context.AddError("A001004115", txtCardno);
        }

        return !(context.hasError());

    }

    private Boolean ChangeUserInfoValidation()
    {
        //对用户姓名进行长度检验

        if (txtCusname.Text.Trim() != "")
            if (Validation.strLen(txtCusname.Text.Trim()) > 50)
                context.AddError("A001001113", txtCusname);

        //对出生日期进行日期格式检验

        String cDate = txtCustbirth.Text.Trim();
        if (cDate != "")
            if (!Validation.isDate(txtCustbirth.Text.Trim()))
                context.AddError("A001001115", txtCustbirth);

        //对联系电话进行长度检验

        if (txtCustphone.Text.Trim() != "")
        {
            if (Validation.strLen(txtCustphone.Text.Trim()) > 20)
                context.AddError("A001001126", txtCustphone);
            //判断是否有客户信息查看权限
            if (CommonHelper.HasOperPower(context) || CommonHelper.GetPaperNo(hidForPaperNo.Value) != txtCustpaperno.Text.Trim())
            {
                if (!Validation.isNum(txtCustphone.Text.Trim()))
                    context.AddError("A001001125", txtCustphone);
            }
        }

        //对证件号码进行长度、英数字检验

        if (txtCustpaperno.Text.Trim() != "")
        {
            //判断是否有客户信息查看权限
            if (CommonHelper.HasOperPower(context) || CommonHelper.GetPaperNo(hidForPaperNo.Value) != txtCustpaperno.Text.Trim())
            {
                if (!Validation.isCharNum(txtCustpaperno.Text.Trim()))
                    context.AddError("A001001122", txtCustpaperno);
            }
            if (Validation.strLen(txtCustpaperno.Text.Trim()) > 20)
                context.AddError("A001001123", txtCustpaperno);
            if (selPapertype.SelectedValue=="00" && !Validation.isPaperNo(txtCustpaperno.Text.Trim()))
                context.AddError("A001001130:证件号码验证不通过", txtCustpaperno);
        }

        //对邮政编码进行长度、数字检验

        if (txtCustpost.Text.Trim() != "")
            if (Validation.strLen(txtCustpost.Text.Trim()) != 6)
                context.AddError("A001001120", txtCustpost);
            else if (!Validation.isNum(txtCustpost.Text.Trim()))
                context.AddError("A001001119", txtCustpost);

        //对联系地址进行长度检验

        if (txtCustaddr.Text.Trim() != "")
            if (Validation.strLen(txtCustaddr.Text.Trim()) > 50)
                context.AddError("A001001128", txtCustaddr);

        //对电子邮件进行格式检验

        if (txtEmail.Text.Trim() != "")
            new Validation(context).isEMail(txtEmail);

        //对备注进行长度检验

        if (txtRemark.Text.Trim() != "")
            if (Validation.strLen(txtRemark.Text.Trim()) > 50)
                context.AddError("A001001129", txtRemark);

        return !(context.hasError());

    }

    protected void btnChangeUserInfoDBread_Click(object sender, EventArgs e)
    {        
        //对输入卡号进行检验
        if (!ChangeUserInfoDBreadValidation())
            return;

        //add by jiangbb 2012-10-09 市民卡不能修改客户资料
        if (txtCardno.Text.Substring(4, 2).ToString() == "18")
        {
            context.AddError("提示：卡号为市民卡，不可修改客户资料");
            return;
        }
        //验证卡片是否旅游年卡(51)，如果是旅游年卡，则不允许在该页面修改资料
        bool cardTypeOk = CommonHelper.allowCardtype(context, txtCardno.Text, "5101");
        if (cardTypeOk == false)
        {
            return;
        }

        DataTable dt = ASHelper.callQuery(context, "ReadXXParkInfo", txtCardno.Text);
        if (dt.Rows.Count > 0)
        {
            //如果办过休闲年卡,查询到期时间
            //
            DataTable data = ASHelper.callQuery(context, "XXParkCardEndDate", txtCardno.Text);
            Object[] row = data.Rows[0].ItemArray;
            String today = DateTime.Now.ToString("yyyyMMdd");
            //如果未到到期时间,则不允许在此页面修改资料
            if (((string)row[0]).CompareTo(today) > 0)
            {
                context.AddError("提示: 休闲年卡不允许在此页面修改资料");
                return;
            }
        }
        dt = ASHelper.callQuery(context, "ReadParkInfo", txtCardno.Text);
        if (dt.Rows.Count > 0)
        {
            DataTable data = ASHelper.callQuery(context, "ParkCardEndDate", txtCardno.Text);
            Object[] row = data.Rows[0].ItemArray;

            String today = DateTime.Now.ToString("yyyyMMdd");
            if (((string)row[0]).CompareTo(today) > 0)
            {
                context.AddError("提示: 园林年卡不允许在此页面修改资料");
                return;
            }
        }

        TMTableModule tmTMTableModule = new TMTableModule();

        //卡账户有效性检验

        SP_AccCheckPDO pdo = new SP_AccCheckPDO();
        pdo.CARDNO = txtCardno.Text;
        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            //从持卡人资料表(TF_F_CUSTOMERREC)中读取数据
            btnChangeUserInfo.Enabled = true;

            TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECIn = new TF_F_CUSTOMERRECTDO();
            ddoTF_F_CUSTOMERRECIn.CARDNO = txtCardno.Text.Trim();

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

            //从卡资料表(TF_F_CARDREC)中读取数据


            TF_F_CARDRECTDO ddoTF_F_CARDRECIn = new TF_F_CARDRECTDO();
            ddoTF_F_CARDRECIn.CARDNO = txtCardno.Text.Trim();

            TF_F_CARDRECTDO ddoTF_F_CARDRECOut = (TF_F_CARDRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDRECIn, typeof(TF_F_CARDRECTDO), null);

            //从IC卡电子钱包帐户表(TF_F_CARDEWALLETACC)中读取数据


            TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCIn = new TF_F_CARDEWALLETACCTDO();
            ddoTF_F_CARDEWALLETACCIn.CARDNO = txtCardno.Text.Trim();

            TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCOut = (TF_F_CARDEWALLETACCTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDEWALLETACCIn, typeof(TF_F_CARDEWALLETACCTDO), null);

            //从IC卡类型编码表(TD_M_CARDTYPE)中读取数据


            TD_M_CARDTYPETDO ddoTD_M_CARDTYPEIn = new TD_M_CARDTYPETDO();
            ddoTD_M_CARDTYPEIn.CARDTYPECODE = ddoTF_F_CARDRECOut.CARDTYPECODE;

            TD_M_CARDTYPETDO ddoTD_M_CARDTYPEOut = (TD_M_CARDTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_CARDTYPEIn, typeof(TD_M_CARDTYPETDO), null, "TD_M_CARDTYPE_CHUSER", null);

            //从证件类型编码表(TD_M_PAPERTYPE)中读取数据


            TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEIn = new TD_M_PAPERTYPETDO();
            ddoTD_M_PAPERTYPEIn.PAPERTYPECODE = ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE;

            TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEOut = (TD_M_PAPERTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_PAPERTYPEIn, typeof(TD_M_PAPERTYPETDO), null, "");

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

            //给页面各显示项附值


            LabAsn.Text = ddoTF_F_CARDRECOut.ASN;
            LabCardtype.Text = ddoTD_M_CARDTYPEOut.CARDTYPENAME;
            sDate.Text = ddoTF_F_CARDRECOut.SELLTIME.ToString("yyyy-MM-dd");

            String Vdate = ddoTF_F_CARDRECOut.VALIDENDDATE;
            eDate.Text = Vdate.Substring(0, 4) + "-" + Vdate.Substring(4, 2) + "-" + Vdate.Substring(6, 2);

            Double cardMoney = Convert.ToDouble(ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY);
            cMoney.Text = (cardMoney / 100).ToString("0.00");
            txtCusname.Text = ddoTF_F_CUSTOMERRECOut.CUSTNAME;
            selCustsex.SelectedValue = ddoTF_F_CUSTOMERRECOut.CUSTSEX;
            //出生日期赋值

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
            //证件类型赋值

            if (ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE != "")
            {
                selPapertype.SelectedValue = ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE;
            }
            else selPapertype.Text = ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE;


            txtCustpaperno.Text = ddoTF_F_CUSTOMERRECOut.PAPERNO;
            txtCustaddr.Text = ddoTF_F_CUSTOMERRECOut.CUSTADDR;
            txtCustpost.Text = ddoTF_F_CUSTOMERRECOut.CUSTPOST;
            txtCustphone.Text = ddoTF_F_CUSTOMERRECOut.CUSTPHONE;
            txtEmail.Text = ddoTF_F_CUSTOMERRECOut.CUSTEMAIL;
            txtRemark.Text = ddoTF_F_CUSTOMERRECOut.REMARK;

            //查询卡片开通功能并显示
            PBHelper.openFunc(context, openFunc, txtCardno.Text.Trim());
        }


        hidForPaperNo.Value = txtCustpaperno.Text.Trim();
        hidForPhone.Value = txtCustphone.Text.Trim();
        hidForAddr.Value = txtCustaddr.Text.Trim();

        //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
        if (!CommonHelper.HasOperPower(context))
        {
            txtCustpaperno.Text = CommonHelper.GetPaperNo(txtCustpaperno.Text);
            txtCustphone.Text = CommonHelper.GetCustPhone(txtCustphone.Text);
            txtCustaddr.Text = CommonHelper.GetCustAddress(txtCustaddr.Text);
        }
    }

    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        btnChangeUserInfo.Enabled = false;

        //add by jiangbb 2012-10-09 市民卡不能修改客户资料
        if (txtCardno.Text.Substring(4, 2).ToString() == "18")
        {
            context.AddError("提示：卡号为市民卡，不可修改客户资料");
            return;
        }

        //验证卡片是否旅游年卡(51)，如果是旅游年卡，则不允许在该页面修改资料
        bool cardTypeOk = CommonHelper.allowCardtype(context, txtCardno.Text, "5101");
        if (cardTypeOk == false)
        {
            return;
        }

        DataTable dt = ASHelper.callQuery(context, "ReadXXParkInfo", txtCardno.Text);
        if (dt.Rows.Count > 0)
        {
            //如果办过休闲年卡,查询到期时间
            //
            DataTable data = ASHelper.callQuery(context, "XXParkCardEndDate", txtCardno.Text);
            Object[] row = data.Rows[0].ItemArray;
            String today = DateTime.Now.ToString("yyyyMMdd");
            //如果未到到期时间,则不允许在此页面修改资料
            if (((string)row[0]).CompareTo(today) > 0)
            {
                context.AddError("提示: 休闲年卡不允许在此页面修改资料");
                return;
            }
        }
        dt = ASHelper.callQuery(context, "ReadParkInfo", txtCardno.Text);
        if (dt.Rows.Count > 0)
        {
            DataTable data = ASHelper.callQuery(context, "ParkCardEndDate", txtCardno.Text);
            Object[] row = data.Rows[0].ItemArray;

            String today = DateTime.Now.ToString("yyyyMMdd");
            if (((string)row[0]).CompareTo(today) > 0)
            {
                context.AddError("提示: 园林年卡不允许在此页面修改资料");
                return;
            }
        }

        TMTableModule tmTMTableModule = new TMTableModule();

        //卡账户有效性检验

        SP_AccCheckPDO pdo = new SP_AccCheckPDO();
        pdo.CARDNO = txtCardno.Text;
        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            //从持卡人资料表(TF_F_CUSTOMERREC)中读取数据
            btnChangeUserInfo.Enabled = true;


            TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECIn = new TF_F_CUSTOMERRECTDO();
            ddoTF_F_CUSTOMERRECIn.CARDNO = txtCardno.Text.Trim();

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
            //从证件类型编码表(TD_M_PAPERTYPE)中读取数据


            TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEIn = new TD_M_PAPERTYPETDO();
            ddoTD_M_PAPERTYPEIn.PAPERTYPECODE = ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE;

            TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEOut = (TD_M_PAPERTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_PAPERTYPEIn, typeof(TD_M_PAPERTYPETDO), null, "");

            //从IC卡类型编码表(TD_M_CARDTYPE)中读取数据


            TD_M_CARDTYPETDO ddoTD_M_CARDTYPEIn = new TD_M_CARDTYPETDO();
            ddoTD_M_CARDTYPEIn.CARDTYPECODE = hiddenLabCardtype.Value;

            TD_M_CARDTYPETDO ddoTD_M_CARDTYPEOut = (TD_M_CARDTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_CARDTYPEIn, typeof(TD_M_CARDTYPETDO), null, "TD_M_CARDTYPE_CHUSER", null);

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

            //给页面各显示项附值

            LabAsn.Text = hiddenAsn.Value.Substring(4, 16);
            LabCardtype.Text = ddoTD_M_CARDTYPEOut.CARDTYPENAME;
            sDate.Text = hiddensDate.Value.Substring(0, 4) + "-" + hiddensDate.Value.Substring(4, 2) + "-" + hiddensDate.Value.Substring(6, 2);
            eDate.Text = hiddeneDate.Value.Substring(0, 4) + "-" + hiddeneDate.Value.Substring(4, 2) + "-" + hiddeneDate.Value.Substring(6, 2);
            cMoney.Text = ((Convert.ToDouble(hiddencMoney.Value)) / 100).ToString("0.00");

            txtCusname.Text = ddoTF_F_CUSTOMERRECOut.CUSTNAME;
            selCustsex.SelectedValue = ddoTF_F_CUSTOMERRECOut.CUSTSEX;
            //出生日期赋值

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
            //证件类型赋值

            if (ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE != "")
            {
                selPapertype.SelectedValue = ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE;
            }
            else selPapertype.Text = ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE;

            txtCustpaperno.Text = ddoTF_F_CUSTOMERRECOut.PAPERNO;
            txtCustaddr.Text = ddoTF_F_CUSTOMERRECOut.CUSTADDR;
            txtCustpost.Text = ddoTF_F_CUSTOMERRECOut.CUSTPOST;
            txtCustphone.Text = ddoTF_F_CUSTOMERRECOut.CUSTPHONE;
            txtEmail.Text = ddoTF_F_CUSTOMERRECOut.CUSTEMAIL;
            txtRemark.Text = ddoTF_F_CUSTOMERRECOut.REMARK;

            //查询卡片开通功能并显示
            PBHelper.openFunc(context, openFunc, txtCardno.Text.Trim());
        }


        hidForPaperNo.Value = txtCustpaperno.Text.Trim();
        hidForPhone.Value = txtCustphone.Text.Trim();
        hidForAddr.Value = txtCustaddr.Text.Trim();

        //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
        if (!CommonHelper.HasOperPower(context))
        {
            txtCustpaperno.Text = CommonHelper.GetPaperNo(txtCustpaperno.Text);
            txtCustphone.Text = CommonHelper.GetCustPhone(txtCustphone.Text);
            txtCustaddr.Text = CommonHelper.GetCustAddress(txtCustaddr.Text);
        }
    }

    protected void btnChangeUserInfo_Click(object sender, EventArgs e)
    {
        btnChangeUserInfo.Enabled = false;

        //对输入项进行检验

        if (!ChangeUserInfoValidation())
            return;

        //add by jiangbb 2012-10-09 市民卡不能修改客户资料
        if (txtCardno.Text.Substring(4, 2).ToString() == "18")
        {
            context.AddError("提示：卡号为市民卡，不可修改客户资料");
            return;
        }
        //验证卡片是否旅游年卡(51)，如果是旅游年卡，则不允许在该页面修改资料
        bool cardTypeOk = CommonHelper.allowCardtype(context, txtCardno.Text, "5101");
        if (cardTypeOk == false)
        {
            return;
        }

        //add by jiangbb 2012-10-17 判断页面上的证件号码、联系电话、联系地址是否修改 并取值
        string custPaperNo = CommonHelper.GetPaperNo(hidForPaperNo.Value) == txtCustpaperno.Text.Trim() ? hidForPaperNo.Value : txtCustpaperno.Text.Trim();
        string custPhone = CommonHelper.GetCustPhone(hidForPhone.Value) == txtCustphone.Text.Trim() ? hidForPhone.Value : txtCustphone.Text.Trim();
        string custAddr = CommonHelper.GetCustAddress(hidForAddr.Value) == txtCustaddr.Text.Trim() ? hidForAddr.Value : txtCustaddr.Text.Trim();

        StringBuilder strBuilder = new StringBuilder();
        SP_PB_ChangeUserInfoPDO pdo = new SP_PB_ChangeUserInfoPDO();
        //存储过程赋值

        pdo.CARDNO = txtCardno.Text.Trim();
        pdo.CUSTNAME = txtCusname.Text.Trim();

        //字段加密 ADD BY JIANGBB 2012-04-19
        AESHelp.AESEncrypt(pdo.CUSTNAME, ref strBuilder);
        pdo.CUSTNAME = strBuilder.ToString();

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(custAddr, ref strBuilder);
        pdo.CUSTADDR = strBuilder.ToString();

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(custPhone, ref strBuilder);
        pdo.CUSTPHONE = strBuilder.ToString();

        pdo.CUSTSEX = selCustsex.SelectedValue;

        if (txtCustbirth.Text.Trim() != "")
        {
            String[] arr = (txtCustbirth.Text.Trim()).Split('-');

            String cDate = arr[0] + arr[1] + arr[2];

            pdo.CUSTBIRTH = cDate;
        }

        else
        {
            pdo.CUSTBIRTH = txtCustbirth.Text.Trim();
        }


        pdo.PAPERTYPECODE = selPapertype.SelectedValue;

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(custPaperNo, ref strBuilder);

        pdo.PAPERNO = strBuilder.ToString();
        pdo.CUSTPOST = txtCustpost.Text.Trim();
        pdo.CUSTEMAIL = txtEmail.Text.Trim();
        pdo.REMARK = txtRemark.Text.Trim();
        pdo.TRADETYPECODE = "29";

        PDOBase pdoOut;
        bool ok = TMStorePModule.Excute(context, pdo, out pdoOut);

        if (ok)
        {
            AddMessage("M001011001");

            if (pdo.CARDNO.Substring(0, 6) == "215061")
            {
                string tradeID = ((SP_PB_ChangeUserInfoPDO)pdoOut).TRADEID;
                string syncCardID = pdo.CARDNO.ToString();
                string[] parm = new string[2];
                parm[0] = tradeID;
                parm[1] = syncCardID;
                DataTable syncData = SPHelper.callQuery("SP_RC_QUERY", context, "QureyUserInfoChangeSync", parm);
              
                //姓名，证件号码解密
                CommonHelper.AESDeEncrypt(syncData, new List<string>(new string[] { "NAME", "PAPER_NO", "OLD_NAME", "OLD_PAPER_NO" }));
                //新证件类型转换
                string npaperType = syncData.Rows[0]["PAPER_TYPE"].ToString();
                switch (npaperType)
                {
                    case "00": syncData.Rows[0]["PAPER_TYPE"] = "0"; break;//身份证
                    case "01": syncData.Rows[0]["PAPER_TYPE"] = "8"; break;//学生证（其它）
                    case "02": syncData.Rows[0]["PAPER_TYPE"] = "6"; break;//军官证
                    case "05": syncData.Rows[0]["PAPER_TYPE"] = "2"; break;//护照
                    case "06": syncData.Rows[0]["PAPER_TYPE"] = "3"; break;//港澳居民来往内地通行证
                    case "07": syncData.Rows[0]["PAPER_TYPE"] = "1"; break;//户口簿
                    case "08": syncData.Rows[0]["PAPER_TYPE"] = "8"; break;//武警证（其它）
                    case "09": syncData.Rows[0]["PAPER_TYPE"] = "4"; break;//台湾同胞来往内地通行证
                    case "99": syncData.Rows[0]["PAPER_TYPE"] = "8"; break;//其它类型证件
                    default: break;
                }
                //旧证件类型转换
                string opaperType = syncData.Rows[0]["OLD_PAPER_TYPE"].ToString();
                switch (opaperType)
                {
                    case "00": syncData.Rows[0]["OLD_PAPER_TYPE"] = "0"; break;
                    case "01": syncData.Rows[0]["OLD_PAPER_TYPE"] = "8"; break;
                    case "02": syncData.Rows[0]["OLD_PAPER_TYPE"] = "6"; break;
                    case "05": syncData.Rows[0]["OLD_PAPER_TYPE"] = "2"; break;
                    case "06": syncData.Rows[0]["OLD_PAPER_TYPE"] = "3"; break;
                    case "07": syncData.Rows[0]["OLD_PAPER_TYPE"] = "1"; break;
                    case "08": syncData.Rows[0]["OLD_PAPER_TYPE"] = "8"; break;
                    case "09": syncData.Rows[0]["OLD_PAPER_TYPE"] = "4"; break;
                    case "99": syncData.Rows[0]["OLD_PAPER_TYPE"] = "8"; break;
                    default: break;
                }
                
                //调用后台接口
                SyncRequest syncRequest;
                bool sync = DataExchangeHelp.ParseFormDataTable(syncData, tradeID, out syncRequest);
                if (sync == true)
                {
                    SyncRequest syncResponse;
                    string msg;
                    bool succ = DataExchangeHelp.Sync(syncRequest, out syncResponse, out msg);
                    if (!succ)
                    {
                        context.AddError("调用接口失败:" + msg);
                    }
                    else
                    {
                        context.AddMessage("调用接口成功!");
                    }
                }
                else
                {
                    context.AddError("调用接口转换错误!");
                }
            }

            clearCustInfo(txtCusname, txtCustbirth, selPapertype, txtCustpaperno, selCustsex, txtCustphone,
                txtCustpost, txtCustaddr, txtEmail, txtRemark);
            foreach (Control con in this.Page.Controls)
            {
                ClearControl(con);
            }
            //initLoad(sender, e);
        }
    }


}
