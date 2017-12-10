using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Collections.Generic;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using Master;
using Common;
using TM;
using TDO.ResourceManager;
using TDO.CardManager;
using PDO.UserCard;
using TDO.UserManager;
using TDO.BusinessCode;
using System.IO;
/**********************************
 * 订单卡更换
 * 2013-5-23
 * shil
 * 初次编写
 * ********************************/
public partial class ASP_GroupCard_GC_OrderCardChange : Master.Master
{
    #region 初始化全局变量
    //利金卡datatable
    private DataTable CashGiftTable
    {
        set
        {
            ViewState["CashGiftTable"] = value;
        }
        get
        {
            return (DataTable)ViewState["CashGiftTable"];
        }
    }
    //充值卡datatable
    private DataTable ChargeCardTable
    {
        set
        {
            ViewState["ChargeCardTable"] = value;
        }
        get
        {
            return (DataTable)ViewState["ChargeCardTable"];
        }
    }
    //市民卡B卡datatable
    private DataTable SZTCardTable
    {
        set
        {
            ViewState["SZTCardTable"] = value;
        }
        get
        {
            return (DataTable)ViewState["SZTCardTable"];
        }
    }
    //旅游卡datatable
    private DataTable LvYouTable
    {
        set
        {
            ViewState["LvYouTable"] = value;
        }
        get
        {
            return (DataTable)ViewState["LvYouTable"];
        }
    }
    #endregion
    #region 有效性校验
    /// <summary>
    /// 输入有效性校验
    /// </summary>
    /// <returns></returns>
    private bool SubmitValidate()
    {
        Validation valid = new Validation(context);

        if (context.hasError())
        {
            return false;
        }

        //校验利金卡
        ValidCashGiftInput(valid);
        if (context.hasError())
        {
            return false;
        }

        //校验充值卡
        ValidChargeCardInput(valid);
        if (context.hasError())
        {
            return false;
        }

        //校验市民卡B卡
        ValidSztCARD();
        if (context.hasError())
        {
            return false;
        }

        //校验旅游卡

        ValidLvYou();
        if (context.hasError())
        {
            return false;
        }
        //校验企服卡                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
        ValidGroupCardInput();
        if (context.hasError())
        {
            return false;
        }
        //校验读卡器
        ValidReaderInput();
        if (context.hasError())
        {
            return false;
        }
        //校验园林年卡
        ValidGardenCardInput();
        if (context.hasError())
        {
            return false;
        }
        //校验休闲年卡
        ValidRelaxCardInput();
        if (context.hasError())
        {
            return false;
        }
        //验证是否有未填写的项
        if (ValidCashGiftIsNull() && ValidChargeCardIsNull() && ValidSZTIsNull() && ValidGCIsNull() && ValidReaderIsNull() && ValidGardenCardIsNull() && ValidRelaxCardIsNull())
        {
            context.AddError("利金卡、充值卡、市民卡B卡、专有账户、读卡器、园林年卡、休闲年卡至少填写一项订单信息");
            return false;
        }
        //验证总金额是否一致
        if (Convert.ToInt32(txtTotalMoney.Text.Trim()) * 100 != Convert.ToInt32(getDataKeys("TOTALMONEY")) * 100)
        {
            context.AddError("变更后的订单总金额必须与变更前一致，为"+getDataKeys("TOTALMONEY")+"元");
            return false;
        }

        return true;
    }
    #region 验证各卡类型输入信息是否为空
    /// <summary>
    /// 验证礼金卡是否全为空 返回True表示输入全为空
    /// </summary>
    /// <returns></returns>
    private bool ValidCashGiftIsNull()
    {
        for (int i = 0; i < gvCashGift.Rows.Count; i++)
        {
            TextBox txtValue = (TextBox)gvCashGift.Rows[i].FindControl("txtCashGiftValue");
            TextBox txtNum = (TextBox)gvCashGift.Rows[i].FindControl("txtCashGiftNum");
            if (txtValue.Text.Trim().Length > 0 || txtNum.Text.Trim().Length > 0)
            {
                return false;
            }
        }

        return true;
    }
    /// <summary>
    /// 验证充值卡是否全为空 返回True表示全为空
    /// </summary>
    /// <returns></returns>
    private bool ValidChargeCardIsNull()
    {
        for (int i = 0; i < gvChargeCard.Rows.Count; i++)
        {
            DropDownList selChargeCardValue = (DropDownList)gvChargeCard.Rows[i].FindControl("selChargeCardValue");
            TextBox txtNum = (TextBox)gvChargeCard.Rows[i].FindControl("txtChargeCardNum");
            //TextBox txtFromCardNo = (TextBox)gvChargeCard.Rows[i].FindControl("txtFromCardNo");
            //TextBox txtToCardNo = (TextBox)gvChargeCard.Rows[i].FindControl("txtToCardNo");
            if (selChargeCardValue.SelectedValue != "" || txtNum.Text.Trim().Length > 0)
            {
                return false;
            }
        }
        return true;
    }
    /// <summary>
    /// 验证市民卡B卡是否全为空 返回True表示全为空
    /// </summary>
    /// <returns></returns>
    private bool ValidSZTIsNull()
    {
        for (int i = 0; i < gvSZTCard.Rows.Count; i++)
        {
            DropDownList selCardtype = (DropDownList)gvSZTCard.Rows[i].FindControl("selSZTCardtype");
            TextBox txtCardNum = (TextBox)gvSZTCard.Rows[i].FindControl("txtSZTCardNum");
            TextBox txtCardPrice = (TextBox)gvSZTCard.Rows[i].FindControl("txtSZTCardPrice");
            TextBox txtChargeMoney = (TextBox)gvSZTCard.Rows[i].FindControl("txtSZTCardChargeMoney");

            if (selCardtype.SelectedValue != "" || txtCardNum.Text.Trim().Length > 0 || txtCardPrice.Text.Trim().Length > 0 || txtChargeMoney.Text.Trim().Length > 0)
            {
                return false;
            }
        }
        return true;
    }

    /// <summary>
    /// 验证旅游卡是否全为空 返回True表示全为空
    /// </summary>
    /// <returns></returns>
    private bool ValidLvYouIsNull()
    {
        for (int i = 0; i < gvLvYou.Rows.Count; i++)
        {
            TextBox txtCardNum = (TextBox)gvLvYou.Rows[i].FindControl("txtLvYouNum");
            TextBox txtCardPrice = (TextBox)gvLvYou.Rows[i].FindControl("txtLvYouPrice");
            TextBox txtChargeMoney = (TextBox)gvLvYou.Rows[i].FindControl("txtLvYouChargeMoney");

            if (txtCardNum.Text.Trim().Length > 0 || txtCardPrice.Text.Trim().Length > 0 || txtChargeMoney.Text.Trim().Length > 0)
            {
                return false;
            }
        }
        return true;
    }

    /// <summary>
    /// 验证专有账户是否为空 返回True表示全为空
    /// </summary>
    /// <returns></returns>
    private bool ValidGCIsNull()
    {
        if (txtGCTotalChargeMoney.Text.Trim().Length < 1)
        {
            return true;
        }
        else if (Convert.ToDecimal(txtGCTotalChargeMoney.Text.Trim()) <= 0)
        {
            return true;
        }
        return false;
    }
    /// <summary>
    /// 验证读卡器是否为空 返回True表示全为空
    /// </summary>
    /// <returns></returns>
    private bool ValidReaderIsNull()
    {
        if (txtReadernum.Text.Trim().Length < 1)
        {
            return true;
        }
        else if (Convert.ToDecimal(txtReadernum.Text.Trim()) <= 0)
        {
            return true;
        }
        return false;
    }
    /// <summary>
    /// 验证园林年卡是否为空 返回True表示全为空
    /// </summary>
    /// <returns></returns>
    private bool ValidGardenCardIsNull()
    {
        if (txtParkOpennum.Text.Trim().Length < 1)
        {
            return true;
        }
        else if (Convert.ToDecimal(txtParkOpennum.Text.Trim()) <= 0)
        {
            return true;
        }
        return false;
    }
    /// <summary>
    /// 验证休闲年卡是否为空 返回True表示全为空
    /// </summary>
    /// <returns></returns>
    private bool ValidRelaxCardIsNull()
    {
        if (txtXXOpennum.Text.Trim().Length < 1)
        {
            return true;
        }
        else if (Convert.ToDecimal(txtXXOpennum.Text.Trim()) <= 0)
        {
            return true;
        }
        return false;
    }
    #endregion

    /// <summary>
    /// 验证利金卡输入是否合法
    /// </summary>
    /// <param name="valid"></param>
    private void ValidCashGiftInput(Validation valid)
    {
        List<string> CashGiftValue = new List<string>();
        for (int i = 0; i < gvCashGift.Rows.Count; i++)
        {
            TextBox txtValue = (TextBox)gvCashGift.Rows[i].FindControl("txtCashGiftValue");
            TextBox txtNum = (TextBox)gvCashGift.Rows[i].FindControl("txtCashGiftNum");
            if (txtValue.Text.Trim().Length > 0 || txtNum.Text.Trim().Length > 0)
            {
                if (txtValue.Text.Trim().Length > 0)
                {
                    if (!Validation.isPrice(txtValue.Text))
                    {
                        context.AddError("面额输入不正确", txtValue);
                    }
                    else if (Convert.ToDecimal(txtValue.Text.Trim()) <= 0)
                    {
                        context.AddError("面额必须是正数", txtValue);
                    }
                    else
                    {
                        //判断是否有相同面额利金卡
                        if (!CashGiftValue.Contains(txtValue.Text))
                        {
                            CashGiftValue.Add(txtValue.Text);
                        }
                    }
                    //校验数量
                    if (txtNum.Text.Trim().Length < 1)
                    {
                        context.AddError("请输入购卡数量", txtNum);
                    }
                    else
                    {
                        if (!Validation.isNum(txtNum.Text))
                        {
                            context.AddError("购卡数量请输入数字", txtNum);
                        }
                        else if (Convert.ToDecimal(txtNum.Text.Trim()) <= 0)
                        {
                            context.AddError("购卡数量必须是正数", txtNum);
                        }
                    }
                }
                else
                {
                    context.AddError("请输入面额", txtValue);
                }
            }
        }

        if (CashGiftValue.Count < gvCashGift.Rows.Count && CashGiftValue.Count > 0)
        {
            context.AddError("不允许在一个订单中重复录入相同面额的利金卡");
        }
        //if (txtTotalCashGift.Text.Trim().Length > 0)
        //{
        //    if (!Validation.isPrice(txtTotalCashGift.Text.Trim()))
        //    {
        //        context.AddError("利金卡总充值金额必须是正数", txtTotalCashGift);
        //    }
        //}
    }

    /// <summary>
    /// 验证充值卡输入是否合法
    /// </summary>
    private void ValidChargeCardInput(Validation valid)
    {
        List<string> ChargeCardValue = new List<string>();
        for (int i = 0; i < gvChargeCard.Rows.Count; i++)
        {
            DropDownList selChargeCardValue = (DropDownList)gvChargeCard.Rows[i].FindControl("selChargeCardValue");
            TextBox txtNum = (TextBox)gvChargeCard.Rows[i].FindControl("txtChargeCardNum");
            //TextBox txtFromCardNo = (TextBox)gvChargeCard.Rows[i].FindControl("txtFromCardNo");
            //TextBox txtToCardNo = (TextBox)gvChargeCard.Rows[i].FindControl("txtToCardNo");

            if (selChargeCardValue.SelectedValue != "" || txtNum.Text.Trim().Length > 0)
            {
                if (selChargeCardValue.SelectedValue == "")
                {
                    context.AddError("面额不能为空", selChargeCardValue);
                }
                else
                {
                    //判断是否有相同面额充值卡
                    if (!ChargeCardValue.Contains(selChargeCardValue.SelectedValue))
                    {
                        ChargeCardValue.Add(selChargeCardValue.SelectedValue);
                    }
                }

                if (txtNum.Text.Trim().Length < 1)
                {
                    context.AddError("购卡数量不能为空", txtNum);
                }
                else
                {
                    if (!Validation.isNum(txtNum.Text.Trim()))
                    {
                        context.AddError("购卡数量必须为数字", txtNum);
                    }
                    else if (Convert.ToDecimal(txtNum.Text.Trim()) <= 0)
                    {
                        context.AddError("购卡数量必须是正数", txtNum);
                    }
                }
            }
        }
        if (ChargeCardValue.Count < gvChargeCard.Rows.Count && ChargeCardValue.Count > 0)
        {
            context.AddError("不允许在一个订单中重复录入相同面额的充值卡");
        }
    }
    /// <summary>
    /// 验证市民卡B卡输入是否合法
    /// </summary>
    private void ValidSztCARD()
    {
        List<string> SZTCardValue = new List<string>();
        for (int i = 0; i < gvSZTCard.Rows.Count; i++)
        {
            DropDownList selCardtype = (DropDownList)gvSZTCard.Rows[i].FindControl("selSZTCardtype");
            TextBox txtCardNum = (TextBox)gvSZTCard.Rows[i].FindControl("txtSZTCardNum");
            TextBox txtCardPrice = (TextBox)gvSZTCard.Rows[i].FindControl("txtSZTCardPrice");
            TextBox txtChargeMoney = (TextBox)gvSZTCard.Rows[i].FindControl("txtSZTCardChargeMoney");

            if (selCardtype.SelectedValue != "" || txtCardNum.Text.Trim().Length > 0 || txtCardPrice.Text.Trim().Length > 0 || txtChargeMoney.Text.Trim().Length > 0)
            {
                if (selCardtype.SelectedValue == "")
                {
                    context.AddError("请选择卡类型", selCardtype);
                }
                else
                {
                    //判断是否有相同面额充值卡
                    if (!SZTCardValue.Contains(selCardtype.SelectedValue))
                    {
                        SZTCardValue.Add(selCardtype.SelectedValue);
                    }
                }
                if (txtCardNum.Text.Trim().Length < 1)
                {
                    context.AddError("请填写购卡数量", txtCardNum);
                }
                if (txtCardPrice.Text.Trim().Length < 1)
                {
                    context.AddError("请填写单价", txtCardPrice);
                }
                if (txtChargeMoney.Text.Trim().Length < 1)
                {
                    context.AddError("请填写总充值金额", txtChargeMoney);
                }
                if (context.hasError())
                {
                    return;
                }
            }
            if (selCardtype.SelectedValue != "" || txtCardNum.Text.Trim().Length > 0 || txtCardPrice.Text.Trim().Length > 0 || txtChargeMoney.Text.Trim().Length > 0)
            {
                if (!Validation.isNum(txtCardNum.Text.Trim()))
                {
                    context.AddError("数量只能写数字", txtCardNum);
                }
                else if (Convert.ToDecimal(txtCardNum.Text.Trim()) < 0)
                {
                    context.AddError("数量必须是正数", txtCardNum);
                }
                if (!Validation.isPrice(txtCardPrice.Text.Trim()))
                {
                    context.AddError("单价格式不正确", txtCardPrice);
                }
                if (!Validation.isPrice(txtChargeMoney.Text.Trim()))
                {
                    context.AddError("总充值金额格式不正确", txtChargeMoney);
                }
                else if (Convert.ToDecimal(txtChargeMoney.Text.Trim()) < 0)
                {
                    context.AddError("总充值金额必须是正数", txtChargeMoney);
                }
            }
        }
        if (SZTCardValue.Count < gvSZTCard.Rows.Count && SZTCardValue.Count > 0)
        {
            context.AddError("不允许在一个订单中重复录入相同卡类型的市民卡B卡");
        }
    }

    /// <summary>
    /// 验证旅游卡输入是否合法

    /// </summary>
    private void ValidLvYou()
    {
        List<string> LvYouValue = new List<string>();
        for (int i = 0; i < gvLvYou.Rows.Count; i++)
        {
            TextBox txtCardNum = (TextBox)gvLvYou.Rows[i].FindControl("txtLvYouNum");
            TextBox txtCardPrice = (TextBox)gvLvYou.Rows[i].FindControl("txtLvYouPrice");
            TextBox txtChargeMoney = (TextBox)gvLvYou.Rows[i].FindControl("txtLvYouChargeMoney");

            if (txtCardNum.Text.Trim().Length > 0 || txtCardPrice.Text.Trim().Length > 0 || txtChargeMoney.Text.Trim().Length > 0)
            {

                if (txtCardNum.Text.Trim().Length < 1)
                {
                    context.AddError("请填写购卡数量", txtCardNum);
                }
                if (txtCardPrice.Text.Trim().Length < 1)
                {
                    context.AddError("请填写单价", txtCardPrice);
                }
                if (txtChargeMoney.Text.Trim().Length < 1)
                {
                    context.AddError("请填写总充值金额", txtChargeMoney);
                }
                if (context.hasError())
                {
                    return;
                }
            }
            if (txtCardNum.Text.Trim().Length > 0 || txtCardPrice.Text.Trim().Length > 0 || txtChargeMoney.Text.Trim().Length > 0)
            {
                if (!Validation.isNum(txtCardNum.Text.Trim()))
                {
                    context.AddError("数量只能写数字", txtCardNum);
                }
                else if (Convert.ToDecimal(txtCardNum.Text.Trim()) < 0)
                {
                    context.AddError("数量必须是正数", txtCardNum);
                }
                if (!Validation.isPrice(txtCardPrice.Text.Trim()))
                {
                    context.AddError("单价格式不正确", txtCardPrice);
                }
                if (!Validation.isPrice(txtChargeMoney.Text.Trim()))
                {
                    context.AddError("总充值金额格式不正确", txtChargeMoney);
                }
                else if (Convert.ToDecimal(txtChargeMoney.Text.Trim()) < 0)
                {
                    context.AddError("总充值金额必须是正数", txtChargeMoney);
                }
            }
        }

    }

    /// <summary>
    /// 校验专有账户输入是否合法
    /// </summary>
    private void ValidGroupCardInput()
    {
        //if (txtGCTotalChargeMoney.Text.Trim().Length > 0)
        //{
        //    if (txtGCTotalChargeMoney.Text.Trim().Length < 1)
        //    {
        //        context.AddError("请填写总充值金额", txtGCTotalChargeMoney);
        //    }
        //}
        if (txtGCTotalChargeMoney.Text.Trim().Length > 0)
        {
            //if (!Validation.isNum(txtGCNum.Text.Trim()))
            //{
            //    context.AddError("企服卡卡片数量必须是数字", txtGCNum);
            //}
            //if (!Validation.isPrice(txtCardFee.Text.Trim()))
            //{
            //    context.AddError("企服卡工本费格式不正确", txtGCNum);
            //}
            if (!Validation.isPrice(txtGCTotalChargeMoney.Text.Trim()))
            {
                context.AddError("专有账户总充值金额格式不正确", txtGCTotalChargeMoney);
            }
            if (txtGCTotalChargeMoney.Text.Trim() == "0")
            {
                context.AddError("专有账户总充值金额不能为0", txtGCTotalChargeMoney);
            }
        }
    }
    /// <summary>
    /// 校验读卡器输入是否合法
    /// </summary>
    private void ValidReaderInput()
    {
        if (txtReadernum.Text.Trim().Length > 0)
        {
            if (string.IsNullOrEmpty(txtReaderPrice.Text.Trim()))
            {
                context.AddError("读卡器数量不为空时，读卡器单价必须填写", txtReaderPrice);
            }

            if (!Validation.isNum(txtReadernum.Text.Trim()))
            {
                context.AddError("读卡器数量必须为数字", txtReadernum);
            }

            if (!Validation.isPrice(txtReaderPrice.Text.Trim()))
            {
                context.AddError("读卡器单价格式不正确", txtReaderPrice);
            }
        }
    }
    /// <summary>
    /// 校验园林年卡输入是否合法
    /// </summary>
    private void ValidGardenCardInput()
    {
        if (txtParkOpennum.Text.Trim().Length > 0)
        {
            if (string.IsNullOrEmpty(txtParkOpenPrice.Text.Trim()))
            {
                context.AddError("园林年卡数量不为空时，园林年卡单价必须填写", txtParkOpenPrice);
            }
            if (!Validation.isNum(txtParkOpennum.Text.Trim()))
            {
                context.AddError("园林年卡数量必须为数字", txtParkOpennum);
            }
            if (!Validation.isPrice(txtParkOpenPrice.Text.Trim()))
            {
                context.AddError("园林年卡单价格式不正确", txtParkOpenPrice);
            }
        }
    }
    /// <summary>
    /// 校验休闲年卡输入是否合法
    /// </summary>
    private void ValidRelaxCardInput()
    {
        if (txtXXOpennum.Text.Trim().Length > 0)
        {
            if (string.IsNullOrEmpty(txtXXPrice.Text.Trim()))
            {
                context.AddError("休闲年卡数量不为空时，休闲年卡单价必须填写", txtXXPrice);
            }
            if (!Validation.isNum(txtXXOpennum.Text.Trim()))
            {
                context.AddError("休闲年卡数量必须为数字", txtXXOpennum);
            }

            if (!Validation.isPrice(txtXXPrice.Text.Trim()))
            {
                context.AddError("休闲年卡单价格式不正确", txtXXPrice);
            }
        }
    }
    #endregion
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "showdivPost", "ShowIsRelated();", true);
            return; 
        }

        //初始化旅游卡押金卡费
        //从前台业务交易费用表中读取售卡费用数据
        TMTableModule tmTMTableModule = new TMTableModule();

        TD_M_TRADEFEETDO ddoTD_M_TRADEFEETDOIn = new TD_M_TRADEFEETDO();
        ddoTD_M_TRADEFEETDOIn.TRADETYPECODE = "7H";

        TD_M_TRADEFEETDO[] ddoTD_M_TRADEFEEOutArr = (TD_M_TRADEFEETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_TRADEFEETDOIn, typeof(TD_M_TRADEFEETDO), "S001001137", "TD_M_TRADEFEE", null);
        Decimal lvYouPrice = 0;
        for (int i = 0; i < ddoTD_M_TRADEFEEOutArr.Length; i++)
        {
            //"00"为卡押金
            if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "00")
                lvYouPrice += Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE);
            //"03"为手续费
            else if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "03")
                lvYouPrice += Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE);
        }
        hiddenLvYouPrice.Value = (lvYouPrice / 100).ToString("0.00");


        //利金卡表格
        if (CashGiftTable == null)
        {
            CashGiftTable = new DataTable();
            DataColumn col1 = new DataColumn("CashGiftValue");
            DataColumn col2 = new DataColumn("CashGiftNum");
            CashGiftTable.Columns.Add(col1);
            CashGiftTable.Columns.Add(col2);
            DataRow row = CashGiftTable.NewRow();
            row["CashGiftValue"] = null;
            row["CashGiftNum"] = null;
            CashGiftTable.Rows.Add(row);
            gvCashGift.DataSource = CashGiftTable;
            gvCashGift.DataBind();
        }
        //充值卡表格
        if (ChargeCardTable == null)
        {
            ChargeCardTable = new DataTable();
            DataColumn col1 = new DataColumn("ChargeCardValue");
            DataColumn col2 = new DataColumn("ChargeCardNum");
            //DataColumn col3 = new DataColumn("FromCardNo");
            //DataColumn col4 = new DataColumn("ToCardNo");
            ChargeCardTable.Columns.Add(col1);
            ChargeCardTable.Columns.Add(col2);
            //ChargeCardTable.Columns.Add(col3);
            //ChargeCardTable.Columns.Add(col4);
            DataRow row = ChargeCardTable.NewRow();
            row["ChargeCardValue"] = null;
            row["ChargeCardNum"] = null;
            //row["FromCardNo"] = null;
            //row["ToCardNo"] = null;
            ChargeCardTable.Rows.Add(row);
            gvChargeCard.DataSource = ChargeCardTable;
            gvChargeCard.DataBind();
        }
        //市民卡B卡表格
        if (SZTCardTable == null)
        {
            SZTCardTable = new DataTable();
            DataColumn col1 = new DataColumn("SZTCardType");
            DataColumn col2 = new DataColumn("SZTCardNum");
            DataColumn col3 = new DataColumn("SZTCardPrice");
            DataColumn col4 = new DataColumn("SZTCardChargeMoney");
            SZTCardTable.Columns.Add(col1);
            SZTCardTable.Columns.Add(col2);
            SZTCardTable.Columns.Add(col3);
            SZTCardTable.Columns.Add(col4);
            DataRow row = SZTCardTable.NewRow();
            row["SZTCardType"] = null;
            row["SZTCardNum"] = null;
            row["SZTCardPrice"] = null;
            row["SZTCardChargeMoney"] = null;
            SZTCardTable.Rows.Add(row);
            gvSZTCard.DataSource = SZTCardTable;
            gvSZTCard.DataBind();
        }
        //旅游卡表格

        if (LvYouTable == null)
        {
            LvYouTable = new DataTable();
            DataColumn col1 = new DataColumn("LvYouNum");
            DataColumn col2 = new DataColumn("LvYouPrice");
            DataColumn col3 = new DataColumn("LvYouChargeMoney");
            LvYouTable.Columns.Add(col1);
            LvYouTable.Columns.Add(col2);
            LvYouTable.Columns.Add(col3);
            DataRow row = LvYouTable.NewRow();
            row["LvYouNum"] = null;
            row["LvYouPrice"] = hiddenLvYouPrice.Value;
            row["LvYouChargeMoney"] = null;
            LvYouTable.Rows.Add(row);
            gvLvYou.DataSource = LvYouTable;
            gvLvYou.DataBind();
        }
        //初始化部门
         TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();
        TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTOutArr = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDEDEPARTIn, typeof(TD_M_INSIDEDEPARTTDO), null, " WHERE USETAG = '1' ORDER BY DEPARTNO");
        ControlDeal.SelectBoxFill(selDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);
        InitStaffList(context.s_DepartID);

        //初始化订单表
        gvOrderList.DataSource = new DataTable();
        gvOrderList.DataBind();

        gvOrderList.DataKeyNames = new string[] { "ORDERNO", "GROUPNAME", "NAME", "PHONE", "IDCARDNO", "TOTALMONEY", 
            "TRANSACTOR", "INPUTTIME", "FINANCEAPPROVERNO", "FINANCEAPPROVERTIME", "ISRELATED","ORDERSTATE" ,"CASHGIFTMONEY",
            "CHARGECARDMONEY","SZTCARDMONEY","LVYOUMONEY","CUSTOMERACCMONEY","CUSTOMERACCHASMONEY","READERMONEY","GARDENCARDMONEY","RELAXCARDMONEY"};
    }

    protected void selDept_Changed(object sender, EventArgs e)
    {
        InitStaffList(selDept.SelectedValue);
    }

    private void InitStaffList(string deptNo)
    {
        if (deptNo == "")
        {
            string dBalunitNo = DeptBalunitHelper.GetDbalunitNo(context);
            if (dBalunitNo != "")//add by liuhe20120214添加对代理的权限处理
            {
                context.DBOpen("Select");
                string sql = @"SELECT STAFFNAME,STAFFNO FROM TD_M_INSIDESTAFF 
                             WHERE DIMISSIONTAG ='1' AND  DEPARTNO IN 
                            (SELECT DEPARTNO FROM TD_DEPTBAL_RELATION WHERE DBALUNITNO='" + dBalunitNo + "' AND USETAG='1')";
                DataTable table = context.ExecuteReader(sql);
                GroupCardHelper.fill(selStaff, table, true);
                return;
            }
            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";
            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_DIMMISSIONTAG_USEFUL", null);
            ControlDeal.SelectBoxFill(selStaff.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
            selStaff.SelectedValue = context.s_UserID;
        }
        else
        {
            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            tdoTD_M_INSIDESTAFFIn.DEPARTNO = deptNo;
            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";
            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_DEPT", null);
            ControlDeal.SelectBoxFill(selStaff.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
        }
    }

    #region 查询单位信息
    //查询单位名称
    protected void queryCompany(object sender, EventArgs e)
    {
        OrderHelper.queryCompany(context, txtCompany, selCompany);

        //计算总金额 重新显示
        ShowTotalMoney();
    }

    protected void selCompany_Change(object sender, EventArgs e)
    {
        txtCompany.Text = selCompany.SelectedItem.ToString();

        //计算总金额 重新显示
        ShowTotalMoney();
    }
    #endregion

    /// <summary>
    /// 查询验证
    /// </summary>
    /// <returns></returns>
    private bool ValidInput()
    {
        //校验单位名称长度
        if (!string.IsNullOrEmpty(txtCompany.Text.Trim()))
        {
            if (txtCompany.Text.Trim().Length > 50)
            {
                context.AddError("单位名称长度不能超过50个字符长度");
            }
        }
        //校验联系人长度
        if (!string.IsNullOrEmpty(txtName.Text.Trim()))
        {
            if (txtName.Text.Trim().Length > 50)
            {
                context.AddError("联系人长度不能超过25个字符长度");
            }
        }

        if (txtQueryMoney.Text.Trim().Length > 0) //金额不为空时
        {
            if (!Validation.isPrice(txtQueryMoney.Text.Trim()))
            {
                context.AddError("A094391334:金额输入不正确", txtQueryMoney);
            }
            else if (Convert.ToDecimal(txtQueryMoney.Text.Trim()) <= 0)
            {
                context.AddError("A094391335:金额必须是正数", txtQueryMoney);
            }
        }
        if (txtName.Text.Trim().Length > 10)
        {
            context.AddError("A094391336:联系人长度不超过8位", txtName);
        }
        //对开始日期和结束日期的判断
        UserCardHelper.validateDateRange(context, txtFromDate, txtToDate, false);
        return !(context.hasError());
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (!ValidInput())
        {
            return;
        }
        string groupName = txtCompany.Text.Trim();
        string name = txtName.Text.Trim();
        string staff = "";
        if (selStaff.SelectedIndex > 0)
        {
            staff = selStaff.SelectedValue;
        }
        string money = "";
        if (txtQueryMoney.Text.Trim().Length > 0)
        {
            money = (Convert.ToDecimal(txtQueryMoney.Text.Trim()) * 100).ToString();
        }
        string fromDate = txtFromDate.Text.Trim();
        string endDate = txtToDate.Text.Trim();

        DataTable dt = GroupCardHelper.callOrderQuery(context, "QueryOrderForCardChange", groupName, name, staff, money, fromDate, endDate, selDept.SelectedValue, context.s_DepartID);
        if (dt == null || dt.Rows.Count < 1)
        {
            gvOrderList.DataSource = new DataTable();
            gvOrderList.DataBind();
            context.AddError("A094391337:未查出领用完成的记录");
            return;
        }
        gvOrderList.DataSource = dt;
        gvOrderList.DataBind();
    }

    protected void gvOrderList_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvOrderList','Select$" + e.Row.RowIndex + "')");
        }
    }
    /// <summary>
    /// 提交新增
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        //更新数据源
        UpdateSZTCardTable();
        UpdateCashGiftTable();
        UpdateChargeCardTable();
        UpdateLvYouTable();

        ShowTotalMoney();

        // 输入校验
        bool pass = SubmitValidate();
        if (!pass)
        {
            return;
        }

        //DataTable dt = GetSztInfo();

        GridView gvInvoice = new GridView();
        CheckBoxList chkListPayType = new CheckBoxList();
        //数据插入临时表
        OrderHelper.WriteInfoIntoTempTable(context, gvCashGift, gvChargeCard, gvSZTCard,gvLvYou, gvInvoice, chkListPayType, Session.SessionID);
        context.SPOpen();
        context.AddField("p_ORDERNO").Value = getDataKeys("ORDERNO");
        context.AddField("P_SESSIONID").Value = Session.SessionID;
        context.AddField("P_TOTALMONEY", "Int32").Value = GetTotalMoney();

        context.AddField("P_READERNUM", "Int32").Value = txtReadernum.Text.Trim() == "" ? 0 : Convert.ToInt32(txtReadernum.Text.Trim());
        context.AddField("P_READERPRICE", "Int32").Value = txtReaderPrice.Text.Trim() == "" ? 0 : (int)(Convert.ToDecimal(txtReaderPrice.Text.Trim()) * 100);
        context.AddField("P_GARDENCARDNUM", "Int32").Value = txtParkOpennum.Text.Trim() == "" ? 0 : Convert.ToInt32(txtParkOpennum.Text.Trim());
        context.AddField("P_GARDENCARDPRICE", "Int32").Value = txtParkOpenPrice.Text.Trim() == "" ? 0 : (int)(Convert.ToDecimal(txtParkOpenPrice.Text.Trim()) * 100);
        context.AddField("P_RELAXCARDNUM", "Int32").Value = txtXXOpennum.Text.Trim() == "" ? 0 : Convert.ToInt32(txtXXOpennum.Text.Trim());
        context.AddField("P_RELAXCARDPRICE", "Int32").Value = txtXXPrice.Text.Trim() == "" ? 0 : (int)(Convert.ToDecimal(txtXXPrice.Text.Trim()) * 100);

        //利金卡总金额
        context.AddField("P_CASHGIFTMONEY", "Int32").Value = lblCashGiftTotal.Text.Trim() == "" ? 0 : (int)(Convert.ToDecimal(lblCashGiftTotal.Text.Trim()) * 100);
        //充值卡总金额
        context.AddField("P_CHARGECARDMONEY", "Int32").Value = lblChargeCardTotal.Text.Trim() == "" ? 0 : (int)(Convert.ToDecimal(lblChargeCardTotal.Text.Trim()) * 100);
        //市民卡B卡总金额
        context.AddField("P_SZTCARDMONEY", "Int32").Value = lblSztTotal.Text.Trim() == "" ? 0 : (int)(Convert.ToDecimal(lblSztTotal.Text.Trim()) * 100);
        //旅游卡总金额
        context.AddField("P_LVYOUMONEY", "Int32").Value = lblLvYouTotal.Text.Trim() == "" ? 0 : (int)(Convert.ToDecimal(lblLvYouTotal.Text.Trim()) * 100);
        //专有账户总充值金额
        context.AddField("P_CUSTOMERACCMONEY", "Int32").Value = txtGCTotalChargeMoney.Text.Trim() == "" ? 0 : (int)(Convert.ToDecimal(txtGCTotalChargeMoney.Text.Trim()) * 100);
        //读卡器总金额
        context.AddField("P_READERMONEY", "Int32").Value = labReaderMoney.Text.Trim() == "" ? 0 : (int)(Convert.ToDecimal(labReaderMoney.Text.Trim()) * 100);
        //园林年卡总金额
        context.AddField("P_GARDENCARDMONEY", "Int32").Value = labParkMoney.Text.Trim() == "" ? 0 : (int)(Convert.ToDecimal(labParkMoney.Text.Trim()) * 100);
        //休闲年卡总金额
        context.AddField("P_RELAXCARDMONEY", "Int32").Value = labXXMoney.Text.Trim() == "" ? 0 : (int)(Convert.ToDecimal(labXXMoney.Text.Trim()) * 100);
        context.AddField("P_ISRELATED").Value = Relate.Checked ? "1" : "0";
        bool ok = context.ExecuteSP("SP_GC_ORDERCARDCHANGE");
        if (ok)
        {
            context.AddMessage("订单卡更换成功");
        }

        //清空临时表
        OrderHelper.clearTempInfo(context);

        ShowTotalMoney(); //重新计算所有总计金额
    }

    #region 计算金额
    /// <summary>
    /// 重新计算所有利金卡的总金额
    /// </summary>
    /// <returns></returns>
    private int GetCashGiftTotalMoney()
    {
        int total = 0;
        try
        {
            //汇总利金卡总金额
            for (int i = 0; i < gvCashGift.Rows.Count; i++)
            {
                TextBox txtValue = (TextBox)gvCashGift.Rows[i].FindControl("txtCashGiftValue");
                TextBox txtNum = (TextBox)gvCashGift.Rows[i].FindControl("txtCashGiftNum");
                int value = txtValue.Text.Trim().Length == 0 ? 0 : (int)(Convert.ToDecimal(txtValue.Text.Trim()) * 100);
                int num = txtNum.Text.Trim().Length == 0 ? 0 : Convert.ToInt32(txtNum.Text.Trim());

                total += value * num;

            }
        }
        catch
        {
            return 0;
        }
        return total;
    }
    /// <summary>
    /// 重新计算所有充值卡的金额
    /// </summary>
    /// <returns></returns>
    private int GetChargeCardTotalMoney()
    {
        int total = 0;
        try
        {
            //汇总充值卡总金额
            for (int i = 0; i < gvChargeCard.Rows.Count; i++)
            {
                DropDownList selChargeCardValue = (DropDownList)gvChargeCard.Rows[i].FindControl("selChargeCardValue");
                TextBox txtNum = (TextBox)gvChargeCard.Rows[i].FindControl("txtChargeCardNum");
                string ChargeCardValue = selChargeCardValue.SelectedItem.ToString();
                int value = 0;
                if (selChargeCardValue.SelectedValue != "")
                {
                    value = Convert.ToInt32(ChargeCardValue.Substring(2, ChargeCardValue.Length - 2)) * 100;
                }
                int num = txtNum.Text.Trim().Length == 0 ? 0 : Convert.ToInt32(txtNum.Text.Trim());

                total += value * num;
            }
        }
        catch
        {
            return 0;
        }
        return total;
    }
    //计算苏州通卡的总金额
    private int GetSZTCardMoney()
    {
        int total = 0;
        try
        {
            for (int i = 0; i < gvSZTCard.Rows.Count; i++)
            {
                DropDownList selSZTCardtype = (DropDownList)gvSZTCard.Rows[i].FindControl("selSZTCardtype");
                TextBox txtCardNum = (TextBox)gvSZTCard.Rows[i].FindControl("txtSZTCardNum");
                TextBox txtCardPrice = (TextBox)gvSZTCard.Rows[i].FindControl("txtSZTCardPrice");
                TextBox txtChargeMoney = (TextBox)gvSZTCard.Rows[i].FindControl("txtSZTCardChargeMoney");

                int num = txtCardNum.Text.Trim().Length == 0 ? 0 : Convert.ToInt32(txtCardNum.Text.Trim());
                int price = txtCardPrice.Text.Trim().Length == 0 ? 0 : (int)(Convert.ToDecimal(txtCardPrice.Text.Trim()) * 100);
                int chargemoney = txtChargeMoney.Text.Trim().Length == 0 ? 0 : (int)(Convert.ToDecimal(txtChargeMoney.Text.Trim()) * 100);

                total += num * price + chargemoney;
            }
        }
        catch
        {
            return 0;
        }
        return total;
    }

    //计算旅游的总金额

    private int GetLvYouMoney()
    {
        int total = 0;
        try
        {
            for (int i = 0; i < gvLvYou.Rows.Count; i++)
            {
                TextBox txtCardNum = (TextBox)gvLvYou.Rows[i].FindControl("txtLvYouNum");
                TextBox txtCardPrice = (TextBox)gvLvYou.Rows[i].FindControl("txtLvYouPrice");
                TextBox txtChargeMoney = (TextBox)gvLvYou.Rows[i].FindControl("txtLvYouChargeMoney");

                int num = txtCardNum.Text.Trim().Length == 0 ? 0 : Convert.ToInt32(txtCardNum.Text.Trim());
                int price = txtCardPrice.Text.Trim().Length == 0 ? 0 : (int)(Convert.ToDecimal(txtCardPrice.Text.Trim()) * 100);
                int chargemoney = txtChargeMoney.Text.Trim().Length == 0 ? 0 : (int)(Convert.ToDecimal(txtChargeMoney.Text.Trim()) * 100);

                total += num * price + chargemoney;
            }
        }
        catch
        {
            return 0;
        }
        return total;
    }

    //专有账户金额
    private int GetGCTotalMoney()
    {
        int total = 0;
        try
        {
            int gcTotalChargeMoney = txtGCTotalChargeMoney.Text.Trim().Length == 0 ? 0 : (int)(Convert.ToDecimal(txtGCTotalChargeMoney.Text.Trim()) * 100);
            total += gcTotalChargeMoney;
        }
        catch
        {
            return 0;
        }
        return total;
    }

    //读卡器总金额
    private int GetReaderTotalMoney()
    {
        int total = 0;
        try
        {
            int readerPrice = txtReaderPrice.Text.Trim().Length == 0 ? 0 : (int)(Convert.ToDecimal(txtReaderPrice.Text.Trim()) * 100);
            int readernum = txtReadernum.Text.Trim().Length == 0 ? 0 : Convert.ToInt32(txtReadernum.Text.Trim());
            total += readerPrice * readernum;
        }
        catch
        {
            return 0;
        }
        return total;
    }

    //园林年卡总金额
    private int GetGardenCardTotalMoney()
    {
        int total = 0;
        try
        {
            int gardenCardPrice = txtParkOpenPrice.Text.Trim().Length == 0 ? 0 : (int)(Convert.ToDecimal(txtParkOpenPrice.Text.Trim()) * 100);
            int gardenCardnum = txtParkOpennum.Text.Trim().Length == 0 ? 0 : Convert.ToInt32(txtParkOpennum.Text.Trim());
            total += gardenCardPrice * gardenCardnum;
        }
        catch
        {
            return 0;
        }
        return total;
    }

    //休闲年卡总金额
    private int GetRelaxCardTotalMoney()
    {
        int total = 0;
        try
        {
            int relaxCardPrice = txtXXPrice.Text.Trim().Length == 0 ? 0 : (int)(Convert.ToDecimal(txtXXPrice.Text.Trim()) * 100);
            int relaxCardnum = txtXXOpennum.Text.Trim().Length == 0 ? 0 : Convert.ToInt32(txtXXOpennum.Text.Trim());
            total += relaxCardPrice * relaxCardnum;
        }
        catch
        {
            return 0;
        }
        return total;
    }

    /// <summary>
    /// 计算所有的金额
    /// </summary>
    /// <returns></returns>
    private int GetTotalMoney()
    {
        int cashGiftTotal = GetCashGiftTotalMoney();
        int chargeCardTotal = GetChargeCardTotalMoney();
        int sztTotal = GetSZTCardMoney();
        int lvyouTotal = GetLvYouMoney();
        int gcToal = GetGCTotalMoney();
        int readerTotal = GetReaderTotalMoney();
        int gardenCardTotal = GetGardenCardTotalMoney();
        int relaxCardTotal = GetRelaxCardTotalMoney();

        return cashGiftTotal + chargeCardTotal + sztTotal + gcToal + readerTotal + gardenCardTotal + relaxCardTotal + lvyouTotal;
    }
    #endregion

    /// <summary>
    /// 显示总计金额
    /// </summary>
    private void ShowTotalMoney()
    {
        int cashGiftTotal = GetCashGiftTotalMoney();
        int chargeCardTotal = GetChargeCardTotalMoney();
        int sztTotal = GetSZTCardMoney();
        int gcTotal = GetGCTotalMoney();
        int readerTotal = GetReaderTotalMoney();
        int gardenCardTotal = GetGardenCardTotalMoney();
        int relaxCardTotal = GetRelaxCardTotalMoney();
        int lvyouTotal = GetLvYouMoney();
        lblCashGiftTotal.Text = (cashGiftTotal / 100.0).ToString();
        lblChargeCardTotal.Text = (chargeCardTotal / 100.0).ToString();
        lblSztTotal.Text = (sztTotal / 100.0).ToString();
        lblLvYouTotal.Text = (lvyouTotal / 100.0).ToString();
        labReaderMoney.Text = (readerTotal / 100.0).ToString();
        labParkMoney.Text = (gardenCardTotal / 100.0).ToString();
        labXXMoney.Text = (relaxCardTotal / 100.0).ToString();
        txtTotalMoney.Text = ((cashGiftTotal + chargeCardTotal + sztTotal + gcTotal + readerTotal + gardenCardTotal + relaxCardTotal + lvyouTotal) / 100.0).ToString();

    }
    #region 市民卡B卡所有表格事件
    protected void btnSZTCardAdd_Click(object sender, EventArgs e)
    {
        //更新 SZTCardTable
        UpdateSZTCardTable();

        DataRow row = SZTCardTable.NewRow();
        row["SZTCardType"] = null;
        row["SZTCardNum"] = null;
        row["SZTCardPrice"] = null;
        row["SZTCardChargeMoney"] = null;
        SZTCardTable.Rows.Add(row);
        gvSZTCard.DataSource = SZTCardTable;
        gvSZTCard.DataBind();

        ////计算总金额 重新显示
        ShowTotalMoney();
    }

    private void UpdateSZTCardTable()
    {
        for (int i = 0; i < gvSZTCard.Rows.Count; i++)
        {
            DropDownList selCardtype = (DropDownList)gvSZTCard.Rows[i].FindControl("selSZTCardtype");
            SZTCardTable.Rows[i]["SZTCardType"] = selCardtype.SelectedValue;
            TextBox txtCardNum = (TextBox)gvSZTCard.Rows[i].FindControl("txtSZTCardNum");
            SZTCardTable.Rows[i]["SZTCardNum"] = txtCardNum.Text;
            TextBox txtCardPrice = (TextBox)gvSZTCard.Rows[i].FindControl("txtSZTCardPrice");
            SZTCardTable.Rows[i]["SZTCardPrice"] = txtCardPrice.Text;
            TextBox txtChargeMoney = (TextBox)gvSZTCard.Rows[i].FindControl("txtSZTCardChargeMoney");
            SZTCardTable.Rows[i]["SZTCardChargeMoney"] = txtChargeMoney.Text;
        }
    }

    protected void gvSZTCard_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        //更新SZTCardTable
        UpdateSZTCardTable();
        if (e.CommandName == "delete")
        {
            int index = Convert.ToInt32(e.CommandArgument.ToString());
            SZTCardTable.Rows[index].Delete();
        }
    }
    protected void gvSZTCard_RowDeleting(object sender, GridViewDeleteEventArgs e)
    {
        gvSZTCard.DataSource = SZTCardTable;
        gvSZTCard.DataBind();
        ShowTotalMoney();
    }
    /// <summary>
    /// 注册
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gvSZTCard_RowCreated(object sender, GridViewRowEventArgs e)
    {
        GridView gv = (GridView)sender;
        if (gv.Rows.Count == 0)
        {
            return;
        }

        DropDownList ddl = (DropDownList)gv.Rows[gv.Rows.Count - 1].FindControl("selSZTCardtype");
        if (ddl != null && ddl.SelectedValue == "")
        {
            ResourceManageHelper.selectCardFace(context, ddl, true, "");
        }
        ddl.SelectedValue = SZTCardTable.Rows[gv.Rows.Count - 1]["SZTCardType"].ToString();
        //计算总金额 重新显示
        //ShowTotalMoney();
    }
    #endregion
    #region 旅游卡所有表格事件

    protected void btnLvYouAdd_Click(object sender, EventArgs e)
    {
        //更新 LvYouTable
        UpdateLvYouTable();

        DataRow row = LvYouTable.NewRow();
        row["LvYouNum"] = null;
        row["LvYouPrice"] = hiddenLvYouPrice.Value;
        row["LvYouChargeMoney"] = null;
        LvYouTable.Rows.Add(row);
        gvLvYou.DataSource = LvYouTable;
        gvLvYou.DataBind();

        ////计算总金额 重新显示
        ShowTotalMoney();
    }

    private void UpdateLvYouTable()
    {
        for (int i = 0; i < gvLvYou.Rows.Count; i++)
        {
            TextBox txtCardNum = (TextBox)gvLvYou.Rows[i].FindControl("txtLvYouNum");
            LvYouTable.Rows[i]["LvYouNum"] = txtCardNum.Text;
            TextBox txtCardPrice = (TextBox)gvLvYou.Rows[i].FindControl("txtLvYouPrice");
            LvYouTable.Rows[i]["LvYouPrice"] = txtCardPrice.Text;
            TextBox txtChargeMoney = (TextBox)gvLvYou.Rows[i].FindControl("txtLvYouChargeMoney");
            LvYouTable.Rows[i]["LvYouChargeMoney"] = txtChargeMoney.Text;
        }
    }

    protected void gvLvYou_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        //更新LvYouTable
        UpdateLvYouTable();
        if (e.CommandName == "delete")
        {
            int index = Convert.ToInt32(e.CommandArgument.ToString());
            LvYouTable.Rows[index].Delete();
        }
    }
    protected void gvLvYou_RowDeleting(object sender, GridViewDeleteEventArgs e)
    {
        gvLvYou.DataSource = LvYouTable;
        gvLvYou.DataBind();
        ShowTotalMoney();
    }
    /// <summary>
    /// 注册
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gvLvYou_RowCreated(object sender, GridViewRowEventArgs e)
    {
        GridView gv = (GridView)sender;
        if (gv.Rows.Count == 0)
        {
            return;
        }


        //计算总金额 重新显示
        //ShowTotalMoney();
    }
    #endregion
    #region 利金卡表格所有事件
    protected void btnCashGiftAdd_Click(object sender, EventArgs e)
    {
        //更新 CashGiftTable
        UpdateCashGiftTable();

        DataRow row = CashGiftTable.NewRow();
        row["CashGiftValue"] = null;
        row["CashGiftNum"] = null;
        CashGiftTable.Rows.Add(row);
        gvCashGift.DataSource = CashGiftTable;
        gvCashGift.DataBind();

        //计算总金额 重新显示
        ShowTotalMoney();
    }

    private void UpdateCashGiftTable()
    {
        for (int i = 0; i < gvCashGift.Rows.Count; i++)
        {
            TextBox txtValue = (TextBox)gvCashGift.Rows[i].FindControl("txtCashGiftValue");
            CashGiftTable.Rows[i]["CashGiftValue"] = txtValue.Text;
            TextBox txtNum = (TextBox)gvCashGift.Rows[i].FindControl("txtCashGiftNum");
            CashGiftTable.Rows[i]["CashGiftNum"] = txtNum.Text;
        }
    }

    protected void gvCashGift_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        //更新CashGiftTable
        UpdateCashGiftTable();
        if (e.CommandName == "delete")
        {
            int index = Convert.ToInt32(e.CommandArgument.ToString());
            CashGiftTable.Rows[index].Delete();
        }
    }
    protected void gvCashGift_RowDeleting(object sender, GridViewDeleteEventArgs e)
    {
        gvCashGift.DataSource = CashGiftTable;
        gvCashGift.DataBind();
        ShowTotalMoney();
    }
    #endregion
    #region 充值卡表格所有事件
    protected void btnChargeCardAdd_Click(object sender, EventArgs e)
    {
        //更新 CashGiftTable
        UpdateChargeCardTable();

        DataRow row = ChargeCardTable.NewRow();
        row["ChargeCardValue"] = null;
        row["ChargeCardNum"] = null;
        //row["FromCardNo"] = null;
        //row["ToCardNo"] = null;
        ChargeCardTable.Rows.Add(row);
        gvChargeCard.DataSource = ChargeCardTable;
        gvChargeCard.DataBind();

        ShowTotalMoney();
    }
    private void UpdateChargeCardTable()
    {
        for (int i = 0; i < gvChargeCard.Rows.Count; i++)
        {
            DropDownList selChargeCardValue = (DropDownList)gvChargeCard.Rows[i].FindControl("selChargeCardValue");
            ChargeCardTable.Rows[i]["ChargeCardValue"] = selChargeCardValue.SelectedValue;
            TextBox txtNum = (TextBox)gvChargeCard.Rows[i].FindControl("txtChargeCardNum");
            ChargeCardTable.Rows[i]["ChargeCardNum"] = txtNum.Text;
        }
    }
    protected void gvChargeCard_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        //更新CashGiftTable
        UpdateChargeCardTable();
        if (e.CommandName == "delete")
        {
            int index = Convert.ToInt32(e.CommandArgument.ToString());
            ChargeCardTable.Rows[index].Delete();
        }
    }
    protected void gvChargeCard_RowDeleting(object sender, GridViewDeleteEventArgs e)
    {
        gvChargeCard.DataSource = ChargeCardTable;
        gvChargeCard.DataBind();
        ShowTotalMoney();
    }
    /// <summary>
    /// 注册行事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gvChargeCard_RowCreated(object sender, GridViewRowEventArgs e)
    {
        GridView gv = (GridView)sender;
        if (gv.Rows.Count == 0)
        {
            return;
        }

        DropDownList ddl = (DropDownList)gv.Rows[gv.Rows.Count - 1].FindControl("selChargeCardValue");
        if (ddl != null)
        {
            //初始化面值
            string sql = "";
            sql = "select VALUECODE ,MONEY/100.0 MONEY from TP_XFC_CARDVALUE ";
            context.DBOpen("Select");
            DataTable data = context.ExecuteReader(sql);
            ddl.Items.Add(new ListItem("---请选择---", ""));
            for (int i = 0; i < data.Rows.Count; i++)
            {
                ddl.Items.Add(new ListItem(data.Rows[i]["VALUECODE"].ToString() + ":" + data.Rows[i]["MONEY"].ToString(), data.Rows[i]["VALUECODE"].ToString()));
            }
            ddl.SelectedValue = ChargeCardTable.Rows[gv.Rows.Count - 1]["ChargeCardValue"].ToString();
        }

        //计算总金额 重新显示
        //ShowTotalMoney();
    }
    #endregion

    /// <summary>
    /// 根据订单号查询订单信息
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gvOrderList_SelectedIndexChanged(object sender, EventArgs e)
    {
        divInfo.InnerHtml = GetOrderMakeOrComfirmHtml(getDataKeys("ORDERNO"), getDataKeys("GROUPNAME"), getDataKeys("NAME"),
            getDataKeys("TOTALMONEY"), getDataKeys("ORDERSTATE"), getDataKeys("INPUTTIME"),
            (Convert.ToDecimal(getDataKeys("CASHGIFTMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("SZTCARDMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("LVYOUMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("CHARGECARDMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("CUSTOMERACCMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("CUSTOMERACCHASMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("READERMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("GARDENCARDMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("RELAXCARDMONEY")) / 100).ToString());

        ScriptManager.RegisterStartupScript(this, this.GetType(), "showdiv", "ShowIsRelated();", true);

        //获取利金卡信息
        DataTable data = GroupCardHelper.callOrderQuery(context, "CashOrderInfo", getDataKeys("ORDERNO"));
        if (data != null && data.Rows.Count > 0)
        {
            CashGiftTable.Rows.Clear();
            for (int i = 0; i < data.Rows.Count; i++)
            {
                DataRow dr = CashGiftTable.NewRow();
                dr["CashGiftValue"] = (Convert.ToInt32(data.Rows[i]["VALUE"].ToString()) / 100.0).ToString();
                dr["CashGiftNum"] = data.Rows[i]["COUNT"].ToString();
                CashGiftTable.Rows.Add(dr);
            }
            gvCashGift.DataSource = CashGiftTable;
            gvCashGift.DataBind();
        }
        //获取充值卡信息
        data = GroupCardHelper.callOrderQuery(context, "ChargeCardOrderInfo", getDataKeys("ORDERNO"));
        if (data != null && data.Rows.Count > 0)
        {
            ChargeCardTable.Rows.Clear();
            for (int i = 0; i < data.Rows.Count; i++)
            {
                DataRow dr = ChargeCardTable.NewRow();
                dr["ChargeCardValue"] = data.Rows[i]["VALUECODE"].ToString();
                dr["ChargeCardNum"] = data.Rows[i]["COUNT"].ToString();
                //dr["FromCardNo"] = data.Rows[i]["FROMCARDNO"].ToString();
                //dr["ToCardNo"] = data.Rows[i]["TOCARDNO"].ToString();
                ChargeCardTable.Rows.Add(dr);
            }
            gvChargeCard.DataSource = ChargeCardTable;
            gvChargeCard.DataBind();
        }
        //获取苏州通卡信息
        data = GroupCardHelper.callOrderQuery(context, "SZTCardOrderInfo", getDataKeys("ORDERNO"));
        if (data != null && data.Rows.Count > 0)
        {
            SZTCardTable.Rows.Clear();
            for (int i = 0; i < data.Rows.Count; i++)
            {
                DataRow dr = SZTCardTable.NewRow();
                dr["SZTCardType"] = data.Rows[i]["CARDTYPECODE"].ToString();
                dr["SZTCardNum"] = data.Rows[i]["COUNT"].ToString();
                dr["SZTCardPrice"] = (Convert.ToInt32(data.Rows[i]["UNITPRICE"].ToString()) / 100.0).ToString();
                dr["SZTCardChargeMoney"] = (Convert.ToInt32(data.Rows[i]["TOTALCHARGEMONEY"].ToString()) / 100.0).ToString();
                SZTCardTable.Rows.Add(dr);
            }
            gvSZTCard.DataSource = SZTCardTable;
            gvSZTCard.DataBind();
        }
        //获取旅游卡信息
        data = GroupCardHelper.callOrderQuery(context, "LvYouOrderInfo", getDataKeys("ORDERNO"));
        if (data != null && data.Rows.Count > 0)
        {
            LvYouTable.Rows.Clear();
            for (int i = 0; i < data.Rows.Count; i++)
            {
                DataRow dr = LvYouTable.NewRow();
                dr["LvYouNum"] = data.Rows[i]["COUNT"].ToString();
                dr["LvYouPrice"] = (Convert.ToInt32(data.Rows[i]["UNITPRICE"].ToString()) / 100.0).ToString();
                dr["LvYouChargeMoney"] = (Convert.ToInt32(data.Rows[i]["TOTALCHARGEMONEY"].ToString()) / 100.0).ToString();
                LvYouTable.Rows.Add(dr);
            }
            gvLvYou.DataSource = LvYouTable;
            gvLvYou.DataBind();
        }

        //专有账户相关信息
        data = GroupCardHelper.callOrderQuery(context, "CustomerAccOrderInfo", getDataKeys("ORDERNO"));
        if (data.Rows.Count > 0)
        {
            double customeraccmoney = Convert.ToInt32(data.Rows[0]["CUSTOMERACCMONEY"].ToString()) / 100.0;
            txtGCTotalChargeMoney.Text = customeraccmoney == 0 ? "" : customeraccmoney.ToString();
        }

        //读卡器相关信息
        data = GroupCardHelper.callOrderQuery(context, "ReaderOrderInfo", getDataKeys("ORDERNO"));
        if (data.Rows.Count > 0)
        {
            int readernum = Convert.ToInt32(data.Rows[0]["COUNT"].ToString());
            txtReadernum.Text = readernum == 0 ? "" : readernum.ToString();
        }

        //园林年卡相关信息
        data = GroupCardHelper.callOrderQuery(context, "GardenCardOrderInfo", getDataKeys("ORDERNO"));
        if (data.Rows.Count > 0)
        {
            int gardencardnum = Convert.ToInt32(data.Rows[0]["COUNT"].ToString());
            txtParkOpennum.Text = gardencardnum == 0 ? "" : gardencardnum.ToString();
        }

        //休闲年卡相关信息
        data = GroupCardHelper.callOrderQuery(context, "RelaxCardOrderInfo", getDataKeys("ORDERNO"));
        if (data.Rows.Count > 0)
        {
            int relaxcardnum = Convert.ToInt32(data.Rows[0]["COUNT"].ToString());
            txtXXOpennum.Text = relaxcardnum == 0 ? "" : relaxcardnum.ToString();
        }
        
        ShowTotalMoney();
        //ViewState["orderno"] = GetOrderNo();
        //lblOrderNo.Text = ViewState["orderno"].ToString();
    }

    public String getDataKeys(String keysname)
    {
        return gvOrderList.DataKeys[gvOrderList.SelectedIndex][keysname].ToString();
    }
    #region 订单详细信息HTML
    public string GetOrderMakeOrComfirmHtml(string orderno, string groupName, string name,
        string totalMoney, string orderstate, string inputtime, string cashgiftmoney, string sztcardmoney, string lvyoumoney,
        string chargecardmoney, string customeraccmoney, string customeracchasmoney, string readermoney,
        string gardenCardmoney, string relaxCardmoney)
    {
        string CashGiftInfoHtml = GetOrderCashGiftInfoHtml(orderno);
        string SZTCardInfoHtml = GetOrderSZTCardInfoHtml(orderno);
        string LvYouInfoHtml = GetOrderLvYouInfoHtml(orderno);
        string ChargeCardInfoHtml = GetOrderChargeCardInfoHtml(orderno);
        string ReaderInfoHtml = GetOrderReaderInfoHtml(orderno);
        string GardenCardInfoHtml = GetOrderGardenCardInfoHtml(orderno);
        string RelaxCardInfoHtml = GetOrderRelaxCardInfoHtml(orderno);
        string CustomerAccHtml = "";
        if (!string.IsNullOrEmpty(customeraccmoney))
        {
            CustomerAccHtml += "<tr><td colspan = '10'><hr></td></tr>";
            CustomerAccHtml += string.Format(@"<tr height=23px>
                                            <td style='text-align:right'>专有账户充值总金额:</td>
		                                    <td> {0} </td>
		                                    <td style='text-align:right'>已充值金额:</td>
		                                    <td> {1} </td>
		                                    <td style='text-align:right'>未充值金额:</td>
		                                    <td> {2} </td>
		                                    <td style='text-align:right'></td>
		                                    <td></td>
		                                    <td style='text-align:right'></td>
		                                    <td></td>
                                        </tr>", customeraccmoney, customeracchasmoney,
                                              (Convert.ToDecimal(customeraccmoney) - Convert.ToDecimal(customeracchasmoney)).ToString());
        }
        string html = string.Format(@"<table border=0px cellpadding=0 cellspacing=0 width='100%' align='center' style='border-style:solid' class='data'>
	                                     <tr height=23px>
		                                    <td style='text-align:right' width ='12%'>单位名称:</td>
		                                    <td width ='18%'> {0} </td>
		                                    <td style='text-align:right' width ='10%'>联系人:</td>
		                                    <td width ='6%'> {1} </td>
		                                    <td style='text-align:right' width ='10%'>订单总金额:</td>
		                                    <td width ='6%'> {2}元 </td>
		                                    <td style='text-align:right' width ='10%'>订单状态:</td>
		                                    <td width ='8%'> {3} </td>
		                                    <td style='text-align:right' width ='10%'>录入时间:</td>
		                                    <td width ='10%'> {4} </td>
	                                     </tr>
                                         <tr height=23px>
		                                    <td style='text-align:right'>利金卡总金额:</td>
		                                    <td> {5} </td>
		                                    <td style='text-align:right'>苏州通卡总金额:</td>
		                                    <td> {6} </td>
                                            <td style='text-align:right'>旅游卡总金额:</td>
		                                    <td> {6} </td>
		                                    <td style='text-align:right'>充值卡总金额:</td>
		                                    <td> {7} </td>
		                                    <td style='text-align:right'>专有账户总金额:</td>
		                                    <td> {8} </td>
	                                     </tr>
                                         <tr height=23px>
                                             <td style='text-align:right'>读卡器总金额</td>
		                                    <td> {13} </td>
		                                    <td style='text-align:right'>园林年卡总金额:</td>
		                                    <td> {14} </td>
		                                    <td style='text-align:right'>休闲年卡总金额:</td>
		                                    <td> {15} </td>
		                                    <td style='text-align:right'></td>
		                                    <td></td>
		                                    <td style='text-align:right'></td>
		                                    <td></td>
	                                     </tr>
                                            {9}
                                            {10}
                                            {19}
                                            {11}
                                            {12}
                                            {16}
                                            {17}
                                            {18}
                                    </table>", groupName, name, totalMoney, orderstate, inputtime, cashgiftmoney, sztcardmoney, chargecardmoney, customeraccmoney,
                                             CashGiftInfoHtml, SZTCardInfoHtml, ChargeCardInfoHtml, CustomerAccHtml, readermoney, gardenCardmoney, relaxCardmoney,
                                             ReaderInfoHtml, GardenCardInfoHtml, RelaxCardInfoHtml, LvYouInfoHtml);
        return html;
    }
     
    public string GetOrderLvYouInfoHtml(string orderno)
    {
        //获取旅游卡信息
        DataTable data = GroupCardHelper.callOrderQuery(context, "LvYouOrderInfo", orderno);
        string html = "";
        if (data != null && data.Rows.Count > 0)
        { 
            string LvYouType = "";
            string ordernum = "";
            string haveMakenum = "";
            string leftnum = "";
            string chargemoney = "";
            html += "<tr><td colspan = '10'><hr></td></tr>";
            for (int i = 0; i < data.Rows.Count; i++)
            {
                LvYouType = data.Rows[i]["CARDTYPECODE"].ToString() + ":" + data.Rows[i]["CARDSURFACENAME"].ToString();
                 ordernum = data.Rows[i]["COUNT"].ToString();
                haveMakenum = (Convert.ToInt32(data.Rows[i]["COUNT"].ToString()) - Convert.ToInt32(data.Rows[i]["LEFTQTY"].ToString())).ToString();
                leftnum = data.Rows[i]["LEFTQTY"].ToString();
                //单张充值金额
                if (ordernum.Trim() == "0")
                {
                    chargemoney = "0";
                }
                else
                {
                    chargemoney = (Convert.ToInt32(data.Rows[i]["TOTALCHARGEMONEY"].ToString()) / Convert.ToInt32(ordernum) / 100.0).ToString();
                }
                html += string.Format(@"<tr height=23px>
                                            <td style='text-align:right'>旅游卡:</td>
		                                    <td> {0} </td>
		                                    <td style='text-align:right'>订购数量:</td>
		                                    <td> {1} </td>
		                                    <td style='text-align:right'>已制卡数量:</td>
		                                    <td> {2} </td>
		                                    <td style='text-align:right'>剩余数量:</td>
		                                    <td> {3} </td>
		                                    <td style='text-align:right'>充值金额</td>
		                                    <td> {4} </td>
                                        </tr>", LvYouType, ordernum, haveMakenum, leftnum, chargemoney);
            }
        }
        return html;
    }

    public string GetOrderCashGiftInfoHtml(string orderno)
    {
        //获取利金卡信息
        DataTable data = GroupCardHelper.callOrderQuery(context, "CashOrderInfo", orderno);
        string html = "";
        if (data != null && data.Rows.Count > 0)
        {
            string cashGiftType = "";
            string ordernum = "";
            string haveMakenum = "";
            string leftnum = "";
            html += "<tr><td colspan = '10'><hr></td></tr>";
            for (int i = 0; i < data.Rows.Count; i++)
            {
                cashGiftType = (Convert.ToInt32(data.Rows[i]["VALUE"].ToString()) / 100).ToString();
                ordernum = data.Rows[i]["COUNT"].ToString();
                haveMakenum = (Convert.ToInt32(data.Rows[i]["COUNT"].ToString()) - Convert.ToInt32(data.Rows[i]["LEFTQTY"].ToString())).ToString();
                leftnum = data.Rows[i]["LEFTQTY"].ToString();
                html += string.Format(@"<tr height=23px>
                                            <td style='text-align:right'>利金卡类型:</td>
		                                    <td> {0} </td>
		                                    <td style='text-align:right'>订购数量:</td>
		                                    <td> {1} </td>
		                                    <td style='text-align:right'>已制卡数量:</td>
		                                    <td> {2} </td>
		                                    <td style='text-align:right'>剩余数量:</td>
		                                    <td> {3} </td>
		                                    <td style='text-align:right'></td>
		                                    <td></td>
                                        </tr>", cashGiftType, ordernum, haveMakenum, leftnum);
            }
        }
        return html;
    }
    public string GetOrderSZTCardInfoHtml(string orderno)
    {
        //获取市民卡B卡信息
        DataTable data = GroupCardHelper.callOrderQuery(context, "SZTCardOrderInfo", orderno);
        string html = "";
        if (data != null && data.Rows.Count > 0)
        {
            string SZTType = "";
            string ordernum = "";
            string haveMakenum = "";
            string leftnum = "";
            string chargemoney = "";
            html += "<tr><td colspan = '10'><hr></td></tr>";
            for (int i = 0; i < data.Rows.Count; i++)
            {
                SZTType = data.Rows[i]["CARDTYPECODE"].ToString() + ":" + data.Rows[i]["CARDSURFACENAME"].ToString();

                ordernum = data.Rows[i]["COUNT"].ToString();
                haveMakenum = (Convert.ToInt32(data.Rows[i]["COUNT"].ToString()) - Convert.ToInt32(data.Rows[i]["LEFTQTY"].ToString())).ToString();
                leftnum = data.Rows[i]["LEFTQTY"].ToString();
                //单张充值金额
                if (ordernum.Trim() == "0")
                {
                    chargemoney = "0";
                }
                else
                {
                    chargemoney = (Convert.ToInt32(data.Rows[i]["TOTALCHARGEMONEY"].ToString()) / Convert.ToInt32(ordernum) / 100.0).ToString();
                }
                html += string.Format(@"<tr height=23px>
                                            <td style='text-align:right'>市民卡B卡类型:</td>
		                                    <td> {0} </td>
		                                    <td style='text-align:right'>订购数量:</td>
		                                    <td> {1} </td>
		                                    <td style='text-align:right'>已制卡数量:</td>
		                                    <td> {2} </td>
		                                    <td style='text-align:right'>剩余数量:</td>
		                                    <td> {3} </td>
		                                    <td style='text-align:right'>充值金额</td>
		                                    <td> {4} </td>
                                        </tr>", SZTType, ordernum, haveMakenum, leftnum, chargemoney);
            }
        }
        return html;
    }
    public string GetOrderChargeCardInfoHtml(string orderno)
    {
        //获取充值卡信息
        DataTable data = GroupCardHelper.callOrderQuery(context, "ChargeCardOrderInfo", orderno);
        string html = "";
        if (data != null && data.Rows.Count > 0)
        {
            string chargeCardType = "";
            string ordernum = "";
            string haveMakenum = "";
            string leftnum = "";
            html += "<tr><td colspan = '10'><hr></td></tr>";
            for (int i = 0; i < data.Rows.Count; i++)
            {
                chargeCardType = data.Rows[i]["VALUECODE"].ToString() + ":" + data.Rows[i]["VALUENAME"].ToString();
                ordernum = data.Rows[i]["COUNT"].ToString();
                haveMakenum = (Convert.ToInt32(data.Rows[i]["COUNT"].ToString()) - Convert.ToInt32(data.Rows[i]["LEFTQTY"].ToString())).ToString();
                leftnum = data.Rows[i]["LEFTQTY"].ToString();
                html += string.Format(@"<tr height=23px>
                                            <td style='text-align:right'>充值卡类型:</td>
		                                    <td> {0} </td>
		                                    <td style='text-align:right'>订购数量:</td>
		                                    <td> {1} </td>
		                                    <td style='text-align:right'>已制卡数量:</td>
		                                    <td> {2} </td>
		                                    <td style='text-align:right'>剩余数量:</td>
		                                    <td> {3} </td>
		                                    <td style='text-align:right'></td>
		                                    <td></td>
                                        </tr>", chargeCardType, ordernum, haveMakenum, leftnum);
            }
        }

        return html;
    }
    public string GetOrderReaderInfoHtml(string orderno)
    {
        //获取读卡器信息
        DataTable data = GroupCardHelper.callOrderQuery(context, "ReaderOrderInfo", orderno);
        string html = "";
        if (data != null && data.Rows.Count > 0)
        {
            string ordernum = "";
            string orderprice = "";
            string haveMakenum = "";
            string leftnum = "";
            html += "<tr><td colspan = '10'><hr></td></tr>";
            for (int i = 0; i < data.Rows.Count; i++)
            {
                ordernum = data.Rows[i]["COUNT"].ToString();
                orderprice = (Convert.ToInt32(data.Rows[i]["VALUE"].ToString()) / 100.0).ToString();
                haveMakenum = (Convert.ToInt32(data.Rows[i]["COUNT"].ToString()) - Convert.ToInt32(data.Rows[i]["LEFTQTY"].ToString())).ToString();
                leftnum = data.Rows[i]["LEFTQTY"].ToString();
                html += string.Format(@"<tr height=23px>
                                            <td style='text-align:right'>读卡器订购数量:</td>
		                                    <td> {0} </td>
		                                    <td style='text-align:right'>单价:</td>
		                                    <td> {1} </td>
		                                    <td style='text-align:right'>已关联数量:</td>
		                                    <td> {2} </td>
		                                    <td style='text-align:right'>剩余数量:</td>
		                                    <td> {3} </td>
		                                    <td style='text-align:right'></td>
		                                    <td></td>
                                        </tr>", ordernum, orderprice, haveMakenum, leftnum);
            }
        }

        return html;
    }
    public string GetOrderGardenCardInfoHtml(string orderno)
    {
        //获取园林年卡信息
        DataTable data = GroupCardHelper.callOrderQuery(context, "GardenCardOrderInfo", orderno);
        string html = "";
        if (data != null && data.Rows.Count > 0)
        {
            string ordernum = "";
            string orderprice = "";
            html += "<tr><td colspan = '10'><hr></td></tr>";
            for (int i = 0; i < data.Rows.Count; i++)
            {
                ordernum = data.Rows[i]["COUNT"].ToString();
                orderprice = (Convert.ToInt32(data.Rows[i]["VALUE"].ToString()) / 100.0).ToString();
                html += string.Format(@"<tr height=23px>
                                            <td style='text-align:right'>园林年卡订购数量:</td>
		                                    <td> {0} </td>
		                                    <td style='text-align:right'>单价:</td>
		                                    <td> {1} </td>
		                                    <td style='text-align:right'></td>
		                                    <td></td>
		                                    <td style='text-align:right'></td>
		                                    <td></td>
		                                    <td style='text-align:right'></td>
		                                    <td></td>
                                        </tr>", ordernum, orderprice);
            }
        }

        return html;
    }
    public string GetOrderRelaxCardInfoHtml(string orderno)
    {
        //获取休闲年卡信息
        DataTable data = GroupCardHelper.callOrderQuery(context, "RelaxCardOrderInfo", orderno);
        string html = "";
        if (data != null && data.Rows.Count > 0)
        {
            string ordernum = "";
            string orderprice = "";
            html += "<tr><td colspan = '10'><hr></td></tr>";
            for (int i = 0; i < data.Rows.Count; i++)
            {
                ordernum = data.Rows[i]["COUNT"].ToString();
                orderprice = (Convert.ToInt32(data.Rows[i]["VALUE"].ToString()) / 100.0).ToString();
                html += string.Format(@"<tr height=23px>
                                            <td style='text-align:right'>休闲年卡订购数量:</td>
		                                    <td> {0} </td>
		                                    <td style='text-align:right'>单价:</td>
		                                    <td> {1} </td>
		                                    <td style='text-align:right'></td>
		                                    <td></td>
		                                    <td style='text-align:right'></td>
		                                    <td></td>
		                                    <td style='text-align:right'></td>
		                                    <td></td>
                                        </tr>", ordernum, orderprice);
            }
        }

        return html;
    }
    #endregion
}