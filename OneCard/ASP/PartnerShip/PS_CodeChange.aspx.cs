using System;
using System.Data;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using TM;
using Common;

public partial class ASP_PartnerShip_PS_CodeChange : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            //有效标志
            TSHelper.initUseTag(selRegionUseTag);
            TSHelper.initUseTag(selDeliveryUseTAG);
            TSHelper.initUseTag(selAppCallingUseTAG);

            //初始化地区编码下拉列表值
            InitSelREGIONCODE();

            //初始化POS投放模式编码下拉列表值
            InitSelDELIVERYMODE();

            //初始化应用行业编码下拉列表值
            InitSelAPPCALLINGCODE();
        }
    }

    protected void selRegion_changed(object sender, EventArgs e)
    {
        if (selRegion.SelectedValue != "")
        {
            TMTableModule tmTMTableModule = new TMTableModule();

            TD_M_REGIONCODETDO ddoTD_M_REGIONCODEIn = new TD_M_REGIONCODETDO();
            ddoTD_M_REGIONCODEIn.REGIONCODE = selRegion.SelectedValue;

            TD_M_REGIONCODETDO ddoTD_M_REGIONCODEOut = (TD_M_REGIONCODETDO)tmTMTableModule.selByPK(context, ddoTD_M_REGIONCODEIn, typeof(TD_M_REGIONCODETDO), null, "TD_M_REGIONCODE", null);

            if (ddoTD_M_REGIONCODEOut != null)
            {
                txtRegionCode.Text = ddoTD_M_REGIONCODEOut.REGIONCODE;
                txtRegionName.Text = ddoTD_M_REGIONCODEOut.REGIONNAME;
                selRegionUseTag.SelectedIndex = selRegionUseTag.Items.IndexOf(selRegionUseTag.Items.FindByValue(ddoTD_M_REGIONCODEOut.ISUSETAG));

            }
        }
        else
        {
            txtRegionCode.Text = "";
            txtRegionName.Text = "";
            selRegionUseTag.SelectedIndex = 0;
        }
    }

    protected void selDeliveryMode_changed(object sender, EventArgs e)
    {
        if (selDeliveryMode.SelectedValue != "")
        {
            TMTableModule tmTMTableModule = new TMTableModule();

            TD_M_DELIVERYMODECODETDO ddoTD_M_DELIVERYMODECODEIn = new TD_M_DELIVERYMODECODETDO();
            ddoTD_M_DELIVERYMODECODEIn.DELIVERYMODECODE = selDeliveryMode.SelectedValue;

            TD_M_DELIVERYMODECODETDO ddoTD_M_DELIVERYMODECODEOut = (TD_M_DELIVERYMODECODETDO)tmTMTableModule.selByPK(context, ddoTD_M_DELIVERYMODECODEIn, typeof(TD_M_DELIVERYMODECODETDO), null, "TD_M_DELIVERYMODECODE", null);

            if (ddoTD_M_DELIVERYMODECODEOut != null)
            {
                txtDeliveryModeCode.Text = ddoTD_M_DELIVERYMODECODEOut.DELIVERYMODECODE;
                txtDeliveryMode.Text = ddoTD_M_DELIVERYMODECODEOut.DELIVERYMODE;
                selDeliveryUseTAG.SelectedIndex = selDeliveryUseTAG.Items.IndexOf(selDeliveryUseTAG.Items.FindByValue(ddoTD_M_DELIVERYMODECODEOut.ISUSETAG));

            }
        }
        else
        {
            txtDeliveryModeCode.Text = "";
            txtDeliveryMode.Text = "";
            selDeliveryUseTAG.SelectedIndex = 0;
        }
    }

    protected void selAppCalling_changed(object sender, EventArgs e)
    {
        if (selAppCalling.SelectedValue != "")
        {
            TMTableModule tmTMTableModule = new TMTableModule();

            TD_M_APPCALLINGCODETDO ddoTD_M_APPCALLINGCODEIn = new TD_M_APPCALLINGCODETDO();
            ddoTD_M_APPCALLINGCODEIn.APPCALLINGCODE = selAppCalling.SelectedValue;

            TD_M_APPCALLINGCODETDO ddoTD_M_APPCALLINGCODEOut = (TD_M_APPCALLINGCODETDO)tmTMTableModule.selByPK(context, ddoTD_M_APPCALLINGCODEIn, typeof(TD_M_APPCALLINGCODETDO), null, "TD_M_APPCALLINGCODE", null);

            if (ddoTD_M_APPCALLINGCODEOut != null)
            {
                txtAppCallingCode.Text = ddoTD_M_APPCALLINGCODEOut.APPCALLINGCODE;
                txtAppCalling.Text = ddoTD_M_APPCALLINGCODEOut.APPCALLING;
                selAppCallingUseTAG.SelectedIndex = selAppCallingUseTAG.Items.IndexOf(selAppCallingUseTAG.Items.FindByValue(ddoTD_M_APPCALLINGCODEOut.ISUSETAG));

            }
        }
        else
        {
            txtAppCallingCode.Text = "";
            txtAppCalling.Text = "";
            selAppCallingUseTAG.SelectedIndex = 0;
        }
    }

    protected void btnAppCallingAdd_Click(object sender, EventArgs e)
    {
        //对应用行业做检验

        if (!AppCallingValidation())
            return;

        SP_PS_CODEPDO pdo = new SP_PS_CODEPDO();
        pdo.funcCode = "AppCallingCodeAdd";
        pdo.var1 = txtAppCallingCode.Text.Trim().ToUpper();
        pdo.var2 = txtAppCalling.Text.Trim().ToUpper();
        pdo.var5 = selAppCallingUseTAG.SelectedValue;

        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            AddMessage("M008113030");
            clearAppCallingInfo();
            InitSelAPPCALLINGCODE();
        }

 
    }

    protected void btnRegionAdd_Click(object sender, EventArgs e)
    {
        //对地区编码和地区名称做检验

        if (!RegionValidation())
            return;

        SP_PS_CODEPDO pdo = new SP_PS_CODEPDO();
        pdo.funcCode = "RegionCodeAdd";
        pdo.var1 = txtRegionCode.Text.Trim().ToUpper();
        pdo.var2 = txtRegionName.Text.Trim().ToUpper();
        pdo.var5 = selRegionUseTag.SelectedValue;

        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            AddMessage("M008113010");
            cleaRegionInfo();
            InitSelREGIONCODE();
        }
    }

    protected void btnDeliveryAdd_Click(object sender, EventArgs e)
    {
        //对POS投放模式编码和POS投放模式名称做检验

        if (!DeliveryModeValidation())
            return;

        SP_PS_CODEPDO pdo = new SP_PS_CODEPDO();
        pdo.funcCode = "DeliveryModeCodeAdd";
        pdo.var1 = txtDeliveryModeCode.Text.Trim().ToUpper();
        pdo.var2 = txtDeliveryMode.Text.Trim().ToUpper();
        pdo.var5 = selDeliveryUseTAG.SelectedValue;

        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            AddMessage("M008113020");
            clearDeliveryModeInfo();
            InitSelDELIVERYMODE();
        }
    }

    protected void btnRegionModify_Click(object sender, EventArgs e)
    {
        //对地区编码和地区名称做检验

        if (!RegionValidation())
            return;

        if (selRegion.SelectedValue != txtRegionCode.Text.Trim().ToUpper())
        {
            context.AddError("A008113019", txtRegionCode);
            return;
        }

        SP_PS_CODEPDO pdo = new SP_PS_CODEPDO();
        pdo.funcCode = "RegionCodeModify";
        pdo.var1 = txtRegionCode.Text.Trim().ToUpper();
        pdo.var2 = txtRegionName.Text.Trim().ToUpper();
        pdo.var5 = selRegionUseTag.SelectedValue;

        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            AddMessage("M008113011");
            cleaRegionInfo();
            InitSelREGIONCODE();
        }
    }

    protected void btnDeliveryModify_Click(object sender, EventArgs e)
    {
        //对POS投放模式编码和POS投放模式名称做检验

        if (!DeliveryModeValidation())
            return;

        if (selDeliveryMode.SelectedValue != txtDeliveryModeCode.Text.Trim().ToUpper())
        {
            context.AddError("A008113028", txtDeliveryModeCode);
            return;
        }

        SP_PS_CODEPDO pdo = new SP_PS_CODEPDO();
        pdo.funcCode = "DeliveryModeCodeModify";
        pdo.var1 = txtDeliveryModeCode.Text.Trim().ToUpper();
        pdo.var2 = txtDeliveryMode.Text.Trim().ToUpper();
        pdo.var5 = selDeliveryUseTAG.SelectedValue;

        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            AddMessage("M008113021");
            clearDeliveryModeInfo();
            InitSelDELIVERYMODE();
        }
    }

    protected void btnAppCallingModify_Click(object sender, EventArgs e)
    {
        //对应用行业做检验

        if (!AppCallingValidation())
            return;

        if (selAppCalling.SelectedValue != txtAppCallingCode.Text.Trim().ToUpper())
        {
            context.AddError("A008113038",txtAppCallingCode);
            return;
        }

        SP_PS_CODEPDO pdo = new SP_PS_CODEPDO();
        pdo.funcCode = "AppCallingCodeModify";
        pdo.var1 = txtAppCallingCode.Text.Trim().ToUpper();
        pdo.var2 = txtAppCalling.Text.Trim().ToUpper();
        pdo.var5 = selAppCallingUseTAG.SelectedValue;

        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            AddMessage("M008113031");
            clearAppCallingInfo();
            InitSelAPPCALLINGCODE();
        }
    }

    protected void btnRegionDelete_Click(object sender, EventArgs e)
    {
        if (selRegion.SelectedValue == "")
        {
            context.AddError("A008113017", selRegion);

            return;
        }

        SP_PS_CODEPDO pdo = new SP_PS_CODEPDO();
        pdo.funcCode = "RegionCodeDelete";
        pdo.var1 = selRegion.SelectedValue;

        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            AddMessage("M008113012");
            cleaRegionInfo();
            InitSelREGIONCODE();
        }

    }

    protected void btnDeliveryDelete_Click(object sender, EventArgs e)
    {
        if (selDeliveryMode.SelectedValue == "")
        {
            context.AddError("A008113027", selDeliveryMode);
            return;
        }
        SP_PS_CODEPDO pdo = new SP_PS_CODEPDO();
        pdo.funcCode = "DeliveryModeCodeDelete";
        pdo.var1 = selDeliveryMode.SelectedValue;

        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            AddMessage("M008113022");
            clearDeliveryModeInfo();
            InitSelDELIVERYMODE();
        }
    }

    protected void btnAppCallingDelete_Click(object sender, EventArgs e)
    {
        if (selAppCalling.SelectedValue == "")
        {
            context.AddError("A008113037", selAppCalling);
            return;
        }

        SP_PS_CODEPDO pdo = new SP_PS_CODEPDO();
        pdo.funcCode = "AppCallingCodeDelete";
        pdo.var1 = selAppCalling.SelectedValue;

        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            AddMessage("M008113032");
            clearAppCallingInfo();
            InitSelAPPCALLINGCODE();
        }
    }

    private Boolean RegionValidation()
    {
        //对地区编码做长度,字符检验

        if (Validation.strLen(txtRegionCode.Text.Trim()) != 1)
        {
            context.AddError("A008113012", txtRegionCode);
        }

        if (!Validation.isChar(txtRegionCode.Text))
        {
            context.AddError("A008113013", txtRegionCode);
        }

        //对地区名称做非空,长度检验

        if (txtRegionName.Text.Trim() == "")
        {
            context.AddError("A008113014", txtRegionName);
        }

        if (Validation.strLen(txtRegionName.Text.Trim()) > 40)
        {
            context.AddError("A008113015", txtRegionName);
        }

        if (selRegionUseTag.SelectedValue == "")
        {
            context.AddError("A008113016", selRegionUseTag);
        }

        return !(context.hasError());
    }

    private Boolean DeliveryModeValidation()
    {
        //对POS投放模式编码做长度,英数字检验

        if (Validation.strLen(txtDeliveryModeCode.Text.Trim()) != 1)
        {
            context.AddError("A008113022", txtDeliveryModeCode);
        }

        if (!Validation.isCharNum(txtDeliveryModeCode.Text))
        {
            context.AddError("A008113023", txtDeliveryModeCode);
        }

        //对POS投放模式做非空,长度检验

        if (txtDeliveryMode.Text.Trim() == "")
        {
            context.AddError("A008113024", txtDeliveryMode);
        }

        if (Validation.strLen(txtDeliveryMode.Text.Trim()) > 20)
        {
            context.AddError("A008113025", txtDeliveryMode);
        }

        if (selDeliveryUseTAG.SelectedValue == "")
        {
            context.AddError("A008113026", selDeliveryUseTAG);
        }

        return !(context.hasError());
    }

    private Boolean AppCallingValidation()
    {
        //对应用行业编码做长度,英数字检验

        if (Validation.strLen(txtAppCallingCode.Text.Trim()) != 1)
        {
            context.AddError("A008113032", txtAppCallingCode);
        }

        if (!Validation.isNum(txtAppCallingCode.Text))
        {
            context.AddError("A008113033", txtAppCallingCode);
        }

        //对POS投放模式做非空,长度检验

        if (txtAppCalling.Text.Trim() == "")
        {
            context.AddError("A008113034", txtAppCalling);
        }

        if (Validation.strLen(txtAppCalling.Text.Trim()) > 20)
        {
            context.AddError("A008113035", txtAppCalling);
        }

        if (selAppCallingUseTAG.SelectedValue == "")
        {
            context.AddError("A008113036", selAppCallingUseTAG);
        }

        return !(context.hasError());
    }

    //初始化地区编码下拉列表值
    private void InitSelREGIONCODE()
    {
        selRegion.Items.Clear();

        TMTableModule tmTMTableModule = new TMTableModule();

        TD_M_REGIONCODETDO ddoTD_M_REGIONCODEIn = new TD_M_REGIONCODETDO();
        TD_M_REGIONCODETDO[] ddoTD_M_REGIONCODEOutArr = (TD_M_REGIONCODETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_REGIONCODEIn, typeof(TD_M_REGIONCODETDO), "S008113013", "", null);

        ControlDeal.SelectBoxFill(selRegion.Items, ddoTD_M_REGIONCODEOutArr, "REGIONNAME", "REGIONCODE", true);
    }

    //初始化POS投放模式编码下拉列表值
    private void InitSelDELIVERYMODE()
    {
        selDeliveryMode.Items.Clear();

        TMTableModule tmTMTableModule = new TMTableModule();

        TD_M_DELIVERYMODECODETDO ddlTD_M_DELIVERYMODECODEIn = new TD_M_DELIVERYMODECODETDO();
        TD_M_DELIVERYMODECODETDO[] ddoTD_M_DELIVERYMODECODEOutArr = (TD_M_DELIVERYMODECODETDO[])tmTMTableModule.selByPKArr(context, ddlTD_M_DELIVERYMODECODEIn, typeof(TD_M_DELIVERYMODECODETDO), "S008113023", "", null);

        ControlDeal.SelectBoxFill(selDeliveryMode.Items, ddoTD_M_DELIVERYMODECODEOutArr, "DELIVERYMODE", "DELIVERYMODECODE", true);
    }

    //初始化应用行业编码下拉列表值
    private void InitSelAPPCALLINGCODE()
    {
        selAppCalling.Items.Clear();

        TMTableModule tmTMTableModule = new TMTableModule();

        TD_M_APPCALLINGCODETDO ddlTD_M_APPCALLINGCODEIn = new TD_M_APPCALLINGCODETDO();
        TD_M_APPCALLINGCODETDO[] ddoTD_M_APPCALLINGCODEOutArr = (TD_M_APPCALLINGCODETDO[])tmTMTableModule.selByPKArr(context, ddlTD_M_APPCALLINGCODEIn, typeof(TD_M_APPCALLINGCODETDO), "S008113033", "", null);

        ControlDeal.SelectBoxFill(selAppCalling.Items, ddoTD_M_APPCALLINGCODEOutArr, "APPCALLING", "APPCALLINGCODE", true);
    }

    private void cleaRegionInfo()
    {
        selRegionUseTag.SelectedIndex = 0;
        txtRegionCode.Text = "";
        txtRegionName.Text = "";
    }

    private void clearDeliveryModeInfo()
    {
        selDeliveryUseTAG.SelectedIndex = 0;
        txtDeliveryMode.Text = "";
        txtDeliveryModeCode.Text = "";
    }

    private void clearAppCallingInfo()
    {
        selAppCallingUseTAG.SelectedIndex = 0;
        txtAppCalling.Text = "";
        txtAppCallingCode.Text = "";
    }
}