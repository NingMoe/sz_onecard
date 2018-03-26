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



public partial class ASP_GroupCard_SZ_OrderInput : Master.Master
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
    //发票datatable
    private DataTable InvoiceTable
    {
        set
        {
            ViewState["InvoiceTable"] = value;
        }
        get
        {
            return (DataTable)ViewState["InvoiceTable"];
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

        if (CompanyOrder.Checked == true)//单位订单
        {
            //单位购卡登记校验
            comBuyCardRegValid();
        }
        else//个人订单
        {
            //个人购卡登记校验
            perBuyCardRegValid();
            if (!string.IsNullOrEmpty(FileUpload2.FileName))
            {
                string[] strPics = { ".jpg", ".bmp", ".gif", ".jpeg", ".png" };
                int index = Array.IndexOf(strPics, Path.GetExtension(FileUpload2.FileName).ToLower());
                if (index == -1)
                {
                    context.AddError("A094780004:上传文件格式必须为jpg|bmp|jpeg|png|gif", FileUpload2);
                }
            }
        }
        //校验备注
        if (!string.IsNullOrEmpty(txtRemark.Text.Trim()))
        {
            if (Validation.strLen(txtRemark.Text.Trim()) > 400)
                context.AddError("备注不能超过200字符长度", txtRemark);
        }
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
        if (ValidCashGiftIsNull() && ValidChargeCardIsNull() && ValidSZTIsNull() && ValidLvYouIsNull() && ValidGCIsNull() && ValidReaderIsNull() && ValidGardenCardIsNull() && ValidRelaxCardIsNull())
        {
            context.AddError("利金卡、充值卡、市民卡B卡、旅游年卡、专有账户、读卡器、园林年卡、休闲年卡至少填写一项订单信息");
            return false;
        }
        //if (!ValidCashGiftIsNull() && txtTotalCashGift.Text.Trim().Length > 0 && txtTotalCashGift.Text.Trim() != "0")
        //{
        //    context.AddError("利金卡总金额和购卡明细只能选择一项填写", txtTotalCashGift);
        //    return false;
        //}
        if (!string.IsNullOrEmpty(txtGetDate.Text.Trim()))
        {
            if (!Validation.isDate(txtGetDate.Text.Trim(), "yyyyMMdd"))
                context.AddError("领卡日期格式必须为yyyyMMdd", txtGetDate);
        }
        //开票方式校验
        ValidInvoice();
        if (context.hasError())
        {
            return false;
        }
        //ValidInvoiceNumAndMoney();

        //付款方式校验
        ValidPayType();
        //开票方式校验
        ValidPrintType();
        if (context.hasError())
        {
            return false;
        }
        int len = FileUpload1.FileBytes.Length;
        if (len >1024 * 1024 * 5)
        {
            context.AddError("A094780014：上传文件不可大于5M", FileUpload1);
            return false;
        }
        return true;
    }
    /// <summary>
    /// 单位购卡登记校验
    /// </summary>
    /// <returns></returns>
    protected void comBuyCardRegValid()
    {
        //对单位名称进行长度校验


        if (txtGroup.Text.Trim() == "")
            context.AddError("单位订单单位名称不能为空", txtGroup);
        else if (Validation.strLen(txtGroup.Text.Trim()) > 200)
            context.AddError("单位名称字符长度不能超过200位", txtGroup);

        //对单位证件类型进行非空检验


        if (selComPapertype.SelectedValue == "")
            context.AddError("单位订单单位证件类型不能为空", selComPapertype);

        //对单位证件号码进行非空、长度、英数字检验


        if (txtComPaperno.Text.Trim() == "")
            context.AddError("单位订单单位证件号码不能为空", txtComPaperno);
        else if (Validation.strLen(txtComPaperno.Text.Trim()) > 30)
            context.AddError("单位证件号码程度不能超过30位", txtComPaperno);

        //对单位证件信息的校验

       
            FileUpload1.PostedFile.ContentLength.ToString();

            
            if (!string.IsNullOrEmpty(FileUpload1.FileName))
            {

                string[] strPics = { ".jpg", ".bmp", ".gif", ".jpeg", ".png" };
                int index = Array.IndexOf(strPics, Path.GetExtension(FileUpload1.FileName).ToLower());
                if (index == -1)
                {
                    context.AddError("A094780002:上传文件格式必须为jpg|bmp|jpeg|png|gif", FileUpload1);
                }
            }
            if (!string.IsNullOrEmpty(FileUpload2.FileName))
            {
                string[] strPics = { ".jpg", ".bmp", ".gif", ".jpeg", ".png" };
                int index = Array.IndexOf(strPics, Path.GetExtension(FileUpload2.FileName).ToLower());
                if (index == -1)
                {
                    context.AddError("A094780003:上传文件格式必须为jpg|bmp|jpeg|png|gif", FileUpload2);
                }
            }
           
      

        //对证件有效期的校验

        if (string.IsNullOrEmpty(txtEndDate.Text.Trim()))
        {
            context.AddError("A094781018:证件有效期不能为空", txtEndDate);
        }
        else if (!Validation.isDate(txtEndDate.Text.Trim(), "yyyyMMdd"))
        {
            context.AddError("A094781019:证件有效期格式不正确", txtEndDate);
        }

        //对法人证件号码的校验

        if (!string.IsNullOrEmpty(txtHoldNo.Text.Trim()))
        {
            if (Validation.strLen(txtHoldNo.Text.Trim()) > 30)
            {
                context.AddError("A094781020:法人证件号码不能超过30位");
            }
        }
        //对部门经理进行校验
        if (selStaff.SelectedValue=="")
        {
            context.AddError("部门经理不能为空",selStaff);
        }
        
        //对个人信息进行校验
        perBuyCardRegValid();
    }
    /// <summary>
    /// 个人购卡登记校验
    /// </summary>
    /// <returns></returns>
    protected void perBuyCardRegValid()
    {
        //对联系人姓名进行非空、长度检验
        if (txtName.Text.Trim() == "")
            context.AddError("联系人姓名不能为空", txtName);
        else if (Validation.strLen(txtName.Text.Trim()) > 50)
            context.AddError("联系人姓名字符长度不能大于25", txtName);

        //对证件类型进行非空检验
        if (selPapertype.SelectedValue == "")
            context.AddError("证件类型不能为空", selPapertype);

        //对证件号码进行非空、长度、英数字检验
        if (txtIDCardNo.Text.Trim() == "")
            context.AddError("证件号码不能为空", txtIDCardNo);
        else if (!Validation.isCharNum(txtIDCardNo.Text.Trim()))
            context.AddError("证件号码必须为英数", txtIDCardNo);
        else if (Validation.strLen(txtIDCardNo.Text.Trim()) > 20)
            context.AddError("证件号码长度不能超过20位", txtIDCardNo);
        else if (selPapertype.SelectedValue == "00" && !Validation.isPaperNo(txtIDCardNo.Text.Trim()))
            context.AddError("证件号码验证不通过", txtIDCardNo);

        //对出生日期进行非空、日期格式校验
        if (txtCustbirth.Text.Trim() != "")
            if (!Validation.isDate(txtCustbirth.Text.Trim(), "yyyyMMdd"))
                context.AddError("出生日期不符合规定格式", txtCustbirth);

        //对联系电话进行长度检验
        if (txtPhone.Text.Trim() != "")
            if (Validation.strLen(txtPhone.Text.Trim()) > 20)
                context.AddError("联系电话不能超过20位", txtPhone);

        //对联系地址进行长度检验
        if (txtCustaddr.Text.Trim() != "")
            if (Validation.strLen(txtCustaddr.Text.Trim()) > 200)
                context.AddError("联系地址字符长度不能超过100位", txtCustaddr);

        //对转出银行进行长度检验
        if (txtOutbank.Text.Trim() != "")
            if (Validation.strLen(txtOutbank.Text.Trim()) > 200)
                context.AddError("转出银行字符长度不能超过100位", txtOutbank);

        //对电子邮件进行格式检验
        if (txtEmail.Text.Trim() != "")
            new Validation(context).isEMail(txtEmail);

        //对转出账户进行长度、英数校验
        if (txtOutacct.Text.Trim() != "")
            if (Validation.strLen(txtOutacct.Text.Trim()) > 30)
                context.AddError("转出账户字符长度不能超过30位", txtOutacct);
        //身份证有效期
        if (string.IsNullOrEmpty(txtPaperEndDate.Text.Trim()))
        {
            context.AddError("A094781021:身份证有效期不能为空", txtPaperEndDate);
        }
        else if (!Validation.isDate(txtPaperEndDate.Text.Trim(), "yyyyMMdd"))
        {
            context.AddError("A094781022:身份证有效期格式不正确", txtPaperEndDate);
        }
       
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

            if ( txtCardNum.Text.Trim().Length > 0 || txtCardPrice.Text.Trim().Length > 0 || txtChargeMoney.Text.Trim().Length > 0)
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
                else if (txtCardNum.Text.Trim() != "0" && Convert.ToDecimal(txtChargeMoney.Text.Trim()) % Convert.ToDecimal(txtCardNum.Text.Trim()) != 0)
                {
                    context.AddError("总充值金额必须是数量的整数倍", txtChargeMoney);
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

            if (  txtCardNum.Text.Trim().Length > 0 || txtChargeMoney.Text.Trim().Length > 0)
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
            if ( txtCardNum.Text.Trim().Length > 0  || txtChargeMoney.Text.Trim().Length > 0)
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
                else if (txtCardNum.Text.Trim() != "0" && Convert.ToDecimal(txtChargeMoney.Text.Trim()) % Convert.ToDecimal(txtCardNum.Text.Trim()) != 0)
                {
                    context.AddError("总充值金额必须是数量的整数倍", txtChargeMoney);
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
        if (txtParkOpennum.Text.Trim().Length > 0 )
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
    /// <summary>
    /// 校验开票类型
    /// </summary>
    private void ValidInvoice()
    {
        for (int i = 0; i < gvInvoice.Rows.Count; i++)
        {
            DropDownList selInvoicetype = (DropDownList)gvInvoice.Rows[i].FindControl("selInvoicetype");
            //TextBox txtInvoiceNum = (TextBox)gvInvoice.Rows[i].FindControl("txtInvoiceNum");
            TextBox txtInvoiceMoney = (TextBox)gvInvoice.Rows[i].FindControl("txtInvoiceMoney");

            if (selInvoicetype.SelectedValue == "" && txtInvoiceMoney.Text.Trim().Length == 0)
            {
                context.AddError("请开票内容必须填写", selInvoicetype);
            }
            else
            {
                if (selInvoicetype.SelectedValue == "")
                {
                    context.AddError("请选择发票类型", selInvoicetype);
                }
                //if (txtInvoiceNum.Text.Trim().Length < 1)
                //{
                //    context.AddError("请填写发票数量", txtInvoiceNum);
                //}
                if (txtInvoiceMoney.Text.Trim().Length < 1)
                {
                    context.AddError("请填写发票金额", txtInvoiceMoney);
                }
                else if (!Validation.isPrice(txtInvoiceMoney.Text.Trim()))
                {
                    context.AddError("发票金额格式不正确", txtInvoiceMoney);
                }
            }
            if (context.hasError())
            {
                return;
            }
        }
    }
    /// <summary>
    /// 校验付款方式
    /// </summary>
    private void ValidPayType()
    {
        for (int i = 0; i < chkListPayType.Items.Count; i++)
        {
            if (chkListPayType.Items[i].Selected)
            {
                return;
            }
        }
        context.AddError("请选择付款方式", chkListPayType);
    }
    /// <summary>
    /// 校验开票方式 add by youyue20171113
    /// </summary>
    private void ValidPrintType()
    {
        int j = 0;
        for (int i = 0; i < chkPrintType.Items.Count; i++)
        {
            if (chkPrintType.Items[i].Selected)
            {
                j = j + 1;
               
            }
        }
        if(j<1)
        {
            context.AddError("请选择开票方式", chkPrintType);

        }
        else if (j > 1)
        {
            context.AddError("开票方式只能二选一", chkPrintType);

        }


    }

    #endregion
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;


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
            DataColumn col5 = new DataColumn("SZTTax");
            SZTCardTable.Columns.Add(col1);
            SZTCardTable.Columns.Add(col2);
            SZTCardTable.Columns.Add(col3);
            SZTCardTable.Columns.Add(col4);
            SZTCardTable.Columns.Add(col5);
            DataRow row = SZTCardTable.NewRow();
            row["SZTCardType"] = null;
            row["SZTCardNum"] = null;
            row["SZTCardPrice"] = null;
            row["SZTCardChargeMoney"] = null;
            row["SZTTax"] = null;
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
        //开票表格
        if (InvoiceTable == null)
        {
            InvoiceTable = new DataTable();
            DataColumn col1 = new DataColumn("Invoicetype");
            //DataColumn col2 = new DataColumn("InvoiceNum");
            DataColumn col2 = new DataColumn("InvoiceMoney");
            InvoiceTable.Columns.Add(col1);
            InvoiceTable.Columns.Add(col2);
            //InvoiceTable.Columns.Add(col3);
            DataRow row = InvoiceTable.NewRow();
            row["Invoicetype"] = null;
            //row["InvoiceNum"] = null;
            row["InvoiceMoney"] = null;
            InvoiceTable.Rows.Add(row);
            gvInvoice.DataSource = InvoiceTable;
            gvInvoice.DataBind();
        }

        //初始默认单位订单，性别和出生日期不可用
        selCustsex.Enabled = false;
        txtCustbirth.Enabled = false;

        //初始化经办人
        txtOperator.Text = context.s_UserID + ":" + context.s_UserName;

        //初始化证件类型
        ASHelper.initPaperTypeList(context, selPapertype);

        // 只保留 00身份证，02军官证 ，05护照，06港澳通行证
        //for (int i = 0; i < selPapertype.Items.Count; i++)
        //{
        //    if (selPapertype.Items[i].Value != "00" || selPapertype.Items[i].Value != "02" || selPapertype.Items[i].Value != "05" || selPapertype.Items[i].Value != "06")
        //    {
        //        selPapertype.Items.Remove(selPapertype.Items[i]);
        //    }
        //}


        //初始化单位证件类型
        selComPapertype.Items.Add(new ListItem("---请选择---", ""));
        selComPapertype.Items.Add(new ListItem("01:组织机构代码证", "01"));
        selComPapertype.Items.Add(new ListItem("02:企业营业执照", "02"));
        selComPapertype.Items.Add(new ListItem("03:税务登记证", "03"));

        //初始化性别
        selCustsex.Items.Add(new ListItem("---请选择---", ""));
        selCustsex.Items.Add(new ListItem("0:男", "0"));
        selCustsex.Items.Add(new ListItem("1:女", "1"));

        //初始化领卡网点
        TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();
        TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTOutArr = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDEDEPARTIn, typeof(TD_M_INSIDEDEPARTTDO), null, "");
        ControlDeal.SelectBoxFill(selGetDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);


        tdFileUpload.Attributes.Add("colspan", "3");
        tdShowPicture.Visible = false;//隐藏上传证件信息图片
        tdMsg.Visible = false;

        //隐藏上传经办人证件信息图片 add by youyue 20141105
        tdFileUpload2.Attributes.Add("colspan", "3");
        tdShowPicture2.Visible = false;
        tdMsg2.Visible = false;

        //生成订单号
        //ViewState["orderno"] = GetOrderNo();
        //lblOrderNo.Text = ViewState["orderno"].ToString();
        //加载作废订单
        // 根据条件进行查询
        //DataTable data = GroupCardHelper.callOrderQuery(context, "RejectOrderSelect");
        //if (data != null && data.Rows.Count > 0)
        //{
        //    for (int i = 0; i < data.Rows.Count; i++)
        //    {
        //        selOrderNo.Items.Add(new ListItem(data.Rows[i][0].ToString(), data.Rows[i][0].ToString()));
        //    }
        //}
        //初始化客户经理所在部门
        TMTableModule tmTMTableModule2 = new TMTableModule();
        TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn2 = new TD_M_INSIDEDEPARTTDO();
        TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTOutArr2 = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule2.selByPKArr(context, tdoTD_M_INSIDEDEPARTIn2, typeof(TD_M_INSIDEDEPARTTDO), null, "");
        ControlDeal.SelectBoxFill(selDept.Items, tdoTD_M_INSIDEDEPARTOutArr2, "DEPARTNAME", "DEPARTNO", true);
        selDept.SelectedValue = context.s_DepartID;
        //初始化客户经理
        InitStaffList(selStaff, context.s_DepartID);
        selStaff.SelectedValue = context.s_UserID;//客户经理默认为当前操作员工


    }
    /// <summary>
    /// 点击修改按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnModify_Click(object sender, EventArgs e)
    {
        if (txtOperator.Text.Substring(0, 6) != context.s_UserID)
        {
            context.AddError("非经办人本人不可以修改订单");
            return;
        }
        if (labOrderState.Text.Substring(0, 2) != "01")
        {
            context.AddError("只有录入待审核状态的订单才可以在该页面置为修改状态");
            return;
        }
        context.SPOpen();
        context.AddField("P_FUNCCODE").Value = "SETMODIFY";
        context.AddField("p_ORDERNO").Value = selOrderNo.SelectedValue;
        bool ok = context.ExecuteSP("SP_GC_SETORDERSTATE");
        if (ok)
        {
            context.AddMessage("将订单置为修改状态成功");

            labOrderState.Text = "00:修改中";

            btnModify.Enabled = false;//修改按钮不可用
            btnCancel.Enabled = true;

            btnStockIn.Text = "修改";
        }

        //计算总金额 重新显示
        ShowTotalMoney();
    }
    /// <summary>
    /// 点击作废按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnCancel_Click(object sender, EventArgs e)
    {
        if (txtOperator.Text.Substring(0, 6) != context.s_UserID)
        {
            context.AddError("非经办人本人不可以作废订单");
            return;
        }
        if (labOrderState.Text.Substring(0, 2) != "00")
        {
            context.AddError("只有修改中状态的订单才可以作废");
            return;
        }
        context.SPOpen();
        context.AddField("P_FUNCCODE").Value = "SETCANCEL";
        context.AddField("p_ORDERNO").Value = selOrderNo.SelectedValue;
        bool ok = context.ExecuteSP("SP_GC_SETORDERSTATE");
        if (ok)
        {
            context.AddMessage("订单作废成功");

            labOrderState.Text = "09:作废";

            btnCancel.Enabled = false;//作废按钮不可用
        }

        //计算总金额 重新显示
        ShowTotalMoney();
        tdMsg.Visible = false;
    }
    /// <summary>
    /// 提交新增
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        string outOrderno = "";
        //更新数据源
        UpdateSZTCardTable();
        UpdateInvoiceTable();
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

        //数据插入临时表
        //DONE: 修改旅游卡相关
        OrderHelper.WriteInfoIntoTempTable(context, gvCashGift, gvChargeCard, gvSZTCard, gvLvYou, gvInvoice, chkListPayType, chkPrintType,Session.SessionID);

        context.SPOpen();
        if ((!string.IsNullOrEmpty(labOrderState.Text)) && labOrderState.Text.Substring(0, 2) == "00" && btnStockIn.Text == "修改") //如果是修改中状态
        {
            context.AddField("P_FUNCCODE").Value = "MODIFY";
        }
        else
        {
            context.AddField("P_FUNCCODE").Value = "ADD";
        }
        context.AddField("p_ORDERNO").Value = selOrderNo.SelectedValue;
        context.AddField("P_SESSIONID").Value = Session.SessionID;
        context.AddField("P_ORDERTYPE").Value = CompanyOrder.Checked ? "1" : "2"; //1单位，2个人
        context.AddField("P_INITIATOR").Value = "2"; //1CRM，2业务系统
        context.AddField("P_GROUPNAME").Value = txtGroup.Text.Trim();
        context.AddField("P_COMPANYPAPERTYPE").Value = selComPapertype.SelectedValue;
        context.AddField("P_COMPANYPAPERNO").Value = txtComPaperno.Text.Trim();
        context.AddField("P_COMPANYMANAGERNO").Value = txtHoldNo.Text.Trim();
        context.AddField("P_COMPANYENDTIME").Value = txtEndDate.Text.Trim();
        context.AddField("P_NAME").Value = txtName.Text.Trim();
        context.AddField("P_PHONE").Value = txtPhone.Text.Trim();
        context.AddField("P_IDCARDNO").Value = txtIDCardNo.Text.Trim();
        context.AddField("P_BIRTHDAY").Value = txtCustbirth.Text.Trim();
        context.AddField("P_PAPERTYPE").Value = selPapertype.SelectedValue;
        context.AddField("P_SEX").Value = selCustsex.SelectedValue;
        context.AddField("P_ADDRESS").Value = txtCustaddr.Text.Trim();
        context.AddField("P_EMAIL").Value = txtEmail.Text.Trim();
        context.AddField("P_OUTBANK").Value = txtOutbank.Text.Trim();
        context.AddField("P_OUTACCT").Value = txtOutacct.Text.Trim();
        context.AddField("P_TOTALMONEY", "Int32").Value = GetTotalMoney();
        context.AddField("P_TRANSACTOR").Value = context.s_UserID;//经办人
        context.AddField("P_REMARK").Value = txtRemark.Text.Trim();
        context.AddField("P_MANAGERDEPT").Value = selDept.SelectedValue;//客户经理部门
        context.AddField("P_MANAGER").Value = selStaff.SelectedValue;//客户经理
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
        //开票总金额
        context.AddField("P_INVOICETOTALMONEY", "Int32").Value = labInvoiceMoney.Text.Trim() == "" ? 0 : (int)(Convert.ToDecimal(labInvoiceMoney.Text.Trim()) * 100);

        //领卡网点，领卡日期
        context.AddField("P_GETDEPARTMENT").Value = selGetDept.SelectedValue;
        context.AddField("P_GETDATE").Value = txtGetDate.Text.Trim();

        context.AddField("P_ORDERDATE").Value = DateTime.Now.ToString("yyyyMMdd");
        context.AddField("P_ORDERSEQ").Value = "";
        context.AddField("P_OUTORDERNO", "String", "output", "16", null);
        context.AddField("P_PAPERENDDATE").Value = txtPaperEndDate.Text.Trim();
        bool ok = context.ExecuteSP("SP_GC_ORDERINPUTSUBMIT");
        if (ok)
        {
             outOrderno = context.GetFieldValue("P_OUTORDERNO").ToString();

            //更新单位证件信息入库

            //单位订单购卡
             if (CompanyOrder.Checked)
             {
                 if (FileUpload1.FileName != "" || FileUpload2.FileName != "")     //上传文件不为空
                 {
                     string imgType = string.Empty;
                     string imgType2 = string.Empty;
                     if (FileUpload1.FileName != "")
                     {
                         imgType = "compapermsg";
                     }
                     if (FileUpload2.FileName != "")
                     {
                         imgType2 = "commanagermsg";
                     }
                     if (btnStockIn.Text == "新增" && (!string.IsNullOrEmpty(FileUpload1.FileName) || !string.IsNullOrEmpty(FileUpload2.FileName)))  //新增单位证件信息或单位经办人信息
                     {
                         string queryCompanyno = @"Select a.COMPANYNO
                                                  From TD_M_BUYCARDCOMINFO a,TF_F_COMBUYCARDREG b
                                                  Where a.COMPANYNO=b.COMPANYNO And b.REMARK = '" + outOrderno + "'";

                         context.DBOpen("Select");
                         DataTable data = context.ExecuteReader(queryCompanyno);
                         if (data.Rows.Count > 0)
                         {
                             if (imgType.Equals("compapermsg"))
                             {
                                 UpdateCompanyMsg(data.Rows[0]["COMPANYNO"].ToString(), GetPicture(FileUpload1), imgType);//更新单位证件信息
                             }
                             if (imgType2.Equals("commanagermsg"))
                             {
                                 UpdateCompanyMsg(data.Rows[0]["COMPANYNO"].ToString(), GetPicture(FileUpload2), imgType2);//更新单位经办人信息
                             }

                         }
                     }
                     if (btnStockIn.Text == "修改")  //修改操作才允许修改单位证件信息或单位经办人信息
                     {
                         if (imgType.Equals("compapermsg"))
                         {
                             UpdateCompanyMsg(hidCompanyNo.Value, GetPicture(FileUpload1), imgType);//更新单位证件信息
                         }
                         if (imgType2.Equals("commanagermsg"))
                         {
                             UpdateCompanyMsg(hidCompanyNo.Value, GetPicture(FileUpload2), imgType2);//更新单位经办人信息
                         }

                     }
                 }
             }
             else //个人订单
             {
                 if ( FileUpload2.FileName != "")     //上传经办人信息文件不为空
                 {
                     if (btnStockIn.Text == "新增")  //新增单位经办人信息
                     {
                         UpdatePerMsg(outOrderno, GetPicture(FileUpload2));
                     }
                     if (btnStockIn.Text == "修改")
                     {
                         UpdatePerMsg(hidOrderNo.Value, GetPicture(FileUpload2));
                     }
                 }
             }
            context.AddMessage("订单提交成功");
            btnStockIn.Text = "新增";


            //新增自动审核功能
            string hidApprove = "1";//默认为呈批单
            string sql = "select PAYTYPECODE from TF_F_PAYTYPE where orderno = '" + outOrderno + "'";
            context.DBOpen("Select");
            DataTable dt = context.ExecuteReader(sql);
            if (!(dt.Rows.Count == 1 && dt.Rows[0]["PAYTYPECODE"].ToString() == "4"))
            {
                hidApprove = "0";//不是付款方式只为呈批单的订单
            }
            context.SPOpen();
            context.AddField("P_ORDERNO").Value = outOrderno;
            context.AddField("P_ISAPPROVE").Value = hidApprove;
            bool ok2 = context.ExecuteSP("SP_GC_ORDERAPPROVALAUTO");
            if (ok2)
            {
                context.AddMessage("订单自动审核通过成功");
                if (string.IsNullOrEmpty(labOrderState.Text))
                 {
                    labOrderState.Text = "02:财务审核通过";
                    btnModify.Enabled = false;//修改按钮不可用
                    btnCancel.Enabled = false;
            }
                 }
            else
            {
                context.AddMessage("订单未通过自动审核");
                 if (string.IsNullOrEmpty(labOrderState.Text))
                 {
                    labOrderState.Text = "01:录入待审核";
                    btnModify.Enabled = true;//修改按钮可用
                    btnCancel.Enabled = false;
                 }
            }

           
            tdMsg.Visible = false;
            tdMsg2.Visible = false;
            if (CompanyOrder.Checked)
            {
                if (tdShowPicture.Visible==true)
                {
                    tdFileUpload.Attributes.Add("colspan", "2");
                }
                else
                {
                    tdFileUpload.Attributes.Add("colspan", "3");
                }
                tdFileUpload2.Attributes.Add("colspan", "3");
            }
            else
            {
                tdFileUpload.Attributes.Add("colspan", "3");
                tdFileUpload2.Attributes.Add("colspan", "2");
            }

        }
       
       
        OrderHelper.clearTempInfo(context);

        ShowTotalMoney(); //重新计算所有总计金额
        

    }

    /// <summary>
    /// 获取图片二进制流文件
    /// </summary>
    /// <param name="FileUpload1">upload控件</param>
    /// <returns>二进制流</returns>
    private byte[] GetPicture(FileUpload FileUpload1)
    {
        int len = FileUpload1.FileBytes.Length;
        if (len > 1024 * 1024 * 5)
        {
            context.AddError("A094780014：上传文件大于5M,文件上传失败");
            return null;
        }

        System.IO.Stream fileDataStream = FileUpload1.PostedFile.InputStream;

        int fileLength = FileUpload1.PostedFile.ContentLength;

        byte[] fileData = new byte[fileLength];

        fileDataStream.Read(fileData, 0, fileLength);
        fileDataStream.Close();

        return fileData;
    }

    /// <summary>
    /// 更新单位证件信息或单位经办人信息  add by youyue
    /// </summary>
    /// <param name="p_companyno">单位编码</param>
    /// <param name="buff">图片二进制流文件</param>
    private void UpdateCompanyMsg(string p_companyno, byte[] buff,string imgType)
    {
        if (buff!=null)
        {
            if(imgType.Equals("compapermsg"))//更新单位证件信息
            {
                context.DBOpen("BatchDML");
                context.AddField(":companyno", "String").Value = p_companyno;
                context.AddField(":BLOB", "BLOB").Value = buff;
                string sql = "UPDATE TD_M_BUYCARDCOMINFO SET COMPANYPAPERMSG = :BLOB WHERE COMPANYNO = :companyno";
                context.ExecuteNonQuery(sql);
                context.DBCommit();
            }
            if (imgType.Equals("commanagermsg"))//更新单位经办人信息
            {
                context.DBOpen("BatchDML");
                context.AddField(":companyno", "String").Value = p_companyno;
                context.AddField(":BLOB", "BLOB").Value = buff;
                string sql = "UPDATE TD_M_BUYCARDCOMINFO SET MANAGERMSG = :BLOB WHERE COMPANYNO = :companyno";
                context.ExecuteNonQuery(sql);
                context.DBCommit();
            }
           
        }
    }
    //更新个人订单单位经办人信息
    private void UpdatePerMsg(string orderno, byte[] buff)
    {
        if (buff != null)
        {
            context.DBOpen("BatchDML");
            context.AddField(":orderno", "String").Value = orderno;
            context.AddField(":BLOB", "BLOB").Value = buff;
            string sql = "UPDATE TD_M_BUYCARDPERINFO t SET t.MANAGERMSG = :BLOB WHERE exists (select 1 from TF_F_PERBUYCARDREG a where a.papertype =t.papertype and a.paperno=t.paperno and a.remark=:orderno)";
            context.ExecuteNonQuery(sql);
            context.DBCommit();
        }
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

    //计算开票的总金额
    private int GetInvoiceMoney()
    {
        int total = 0;
        try
        {
            for (int i = 0; i < gvInvoice.Rows.Count; i++)
            {
                TextBox txtInvoice = (TextBox)gvInvoice.Rows[i].FindControl("txtInvoiceMoney");

                int InvoiceMoney = txtInvoice.Text.Trim().Length == 0 ? 0 : (int)(Convert.ToDecimal(txtInvoice.Text.Trim()) * 100);

                total += InvoiceMoney;
            }
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
        int lvyouTotal = GetLvYouMoney();
        int gcTotal = GetGCTotalMoney();
        int readerTotal = GetReaderTotalMoney();
        int gardenCardTotal = GetGardenCardTotalMoney();
        int relaxCardTotal = GetRelaxCardTotalMoney();
        int invoiceMoney = GetInvoiceMoney();
        lblCashGiftTotal.Text = (cashGiftTotal / 100.0).ToString();
        lblChargeCardTotal.Text = (chargeCardTotal / 100.0).ToString();
        lblSztTotal.Text = (sztTotal / 100.0).ToString();
        lblLvYouTotal.Text = (lvyouTotal / 100.0).ToString();
        labReaderMoney.Text = (readerTotal / 100.0).ToString();
        labParkMoney.Text = (gardenCardTotal / 100.0).ToString();
        labXXMoney.Text = (relaxCardTotal / 100.0).ToString();
        txtTotalMoney.Text = ((cashGiftTotal + chargeCardTotal + sztTotal + gcTotal + readerTotal + gardenCardTotal + relaxCardTotal + lvyouTotal) / 100.0).ToString();

        labInvoiceMoney.Text = (invoiceMoney / 100.0).ToString();
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
        row["SZTTax"] = null;
        SZTCardTable.Rows.Add(row);
        gvSZTCard.DataSource = SZTCardTable;
        gvSZTCard.DataBind();
        //绑定是否开具专有发票选项
        for (int i = 0; i < gvSZTCard.Rows.Count; i++)
        {
            CheckBox txtTax = (CheckBox)gvSZTCard.Rows[i].FindControl("chkTax");
            if (SZTCardTable.Rows[i]["SZTTax"].ToString() == "0" ||SZTCardTable.Rows[i]["SZTTax"].ToString() =="")
            {
                txtTax.Checked = false;
            }
            else
            {
                txtTax.Checked = true;
            }
        }

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
            CheckBox txtTax = (CheckBox)gvSZTCard.Rows[i].FindControl("chkTax");
            SZTCardTable.Rows[i]["SZTTax"] = (txtTax.Checked==false)?"0":"1";
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
        //绑定是否开具专有发票选项
        for (int i = 0; i < gvSZTCard.Rows.Count; i++)
        {
            CheckBox txtTax = (CheckBox)gvSZTCard.Rows[i].FindControl("chkTax");
            if (SZTCardTable.Rows[i]["SZTTax"].ToString() == "0" || SZTCardTable.Rows[i]["SZTTax"].ToString() == "")
            {
                txtTax.Checked = false;
            }
            else
            {
                txtTax.Checked = true;
            }
        }
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
            foreach (ListItem li in ddl.Items)
            {
                if (li.Value == "5101")
                {
                    ddl.Items.Remove(li);
                    break;
                }
            }
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

    #region 发票所有表格事件
    protected void btnInvoiceAdd_Click(object sender, EventArgs e)
    {
        //更新 InvoiceTable
        UpdateInvoiceTable();

        DataRow row = InvoiceTable.NewRow();
        row["Invoicetype"] = null;
        //row["InvoiceNum"] = null;
        row["InvoiceMoney"] = null;
        InvoiceTable.Rows.Add(row);
        gvInvoice.DataSource = InvoiceTable;
        gvInvoice.DataBind();

        //计算总金额 重新显示
        ShowTotalMoney();
    }

    private void UpdateInvoiceTable()
    {
        for (int i = 0; i < gvInvoice.Rows.Count; i++)
        {
            DropDownList selInvoicetype = (DropDownList)gvInvoice.Rows[i].FindControl("selInvoicetype");
            InvoiceTable.Rows[i]["Invoicetype"] = selInvoicetype.SelectedValue;
            //TextBox txtInvoiceNum = (TextBox)gvInvoice.Rows[i].FindControl("txtInvoiceNum");
            //InvoiceTable.Rows[i]["InvoiceNum"] = txtInvoiceNum.Text;
            TextBox txtInvoiceMoney = (TextBox)gvInvoice.Rows[i].FindControl("txtInvoiceMoney");
            InvoiceTable.Rows[i]["InvoiceMoney"] = txtInvoiceMoney.Text;
        }
    }

    protected void gvInvoice_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        //更新 InvoiceTable
        UpdateInvoiceTable();
        if (e.CommandName == "delete")
        {
            int index = Convert.ToInt32(e.CommandArgument.ToString());
            InvoiceTable.Rows[index].Delete();
        }
    }
    protected void gvInvoice_RowDeleting(object sender, GridViewDeleteEventArgs e)
    {
        gvInvoice.DataSource = InvoiceTable;
        gvInvoice.DataBind();
        //计算总金额 重新显示
        ShowTotalMoney();
    }
    /// <summary>
    /// 注册行事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gvInvoice_RowCreated(object sender, GridViewRowEventArgs e)
    {
        GridView gv = (GridView)sender;
        if (gv.Rows.Count == 0)
        {
            return;
        }

        DropDownList ddl = (DropDownList)gv.Rows[gv.Rows.Count - 1].FindControl("selInvoicetype");
        if (ddl != null)
        {
            ddl.Items.Add(new ListItem("---请选择---", ""));
            ddl.Items.Add(new ListItem("1:充值", "1"));
            ddl.Items.Add(new ListItem("2:交通费", "2"));
            ddl.Items.Add(new ListItem("3:福利费", "3"));
            ddl.Items.Add(new ListItem("4:通讯费", "4"));
            ddl.Items.Add(new ListItem("5:宣传费", "5"));//changed by youyue 20140630
            ddl.SelectedValue = InvoiceTable.Rows[gv.Rows.Count - 1]["Invoicetype"].ToString();
        }
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
    /// 查询订单号
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnOrderQuery_Click(object sender, EventArgs e)
    {
        selOrderNo.Items.Clear();
        string companyName = txtCompany.Text;
        DataTable data = GroupCardHelper.callOrderQuery(context, "OrderNoSelect",
            companyName, txtContactName.Text.Trim(), selOrderStatus.SelectedValue);
        if (data != null && data.Rows.Count > 0)
        {
            selOrderNo.Items.Add(new ListItem("---请选择---", ""));
            for (int i = 0; i < data.Rows.Count; i++)
            {
                selOrderNo.Items.Add(new ListItem(data.Rows[i][0].ToString() + ":" + data.Rows[i][1].ToString(), data.Rows[i][0].ToString()));
            }
        }
    }

    /// <summary>
    /// 根据订单号查询订单信息
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        
        clearInfo(true);
       
        //获取订单基本信息
        DataTable data = GroupCardHelper.callOrderQuery(context, "OrderInfo", selOrderNo.SelectedValue);
        if (data != null && data.Rows.Count > 0)
        {
            labOrderState.Text = data.Rows[0]["ORDERSTATE"].ToString();
            txtGroup.Text = data.Rows[0]["GROUPNAME"].ToString();
            selGroup.Items.Clear();
            selGroup.Items.Add(new ListItem("---请选择---", ""));
            selGroup.Items.Add(new ListItem(txtGroup.Text.Trim()));
            selGroup.SelectedIndex = 1;
            txtName.Text = data.Rows[0]["NAME"].ToString();
            txtPhone.Text = data.Rows[0]["PHONE"].ToString();
            txtIDCardNo.Text = data.Rows[0]["IDCARDNO"].ToString();
            txtTotalMoney.Text = (Convert.ToInt32(data.Rows[0]["TOTALMONEY"].ToString()) / 100.0).ToString();
            txtRemark.Text = data.Rows[0]["REMARK"].ToString();
            //txtGCNum.Text = data.Rows[0]["GCCOUNT"].ToString();
            //txtCardFee.Text = (Convert.ToInt32(data.Rows[0]["GCUNITPRICE"].ToString()) / 100.0).ToString();
            double customeraccmoney = Convert.ToInt32(data.Rows[0]["CUSTOMERACCMONEY"].ToString()) / 100.0;
            txtGCTotalChargeMoney.Text = customeraccmoney == 0 ? "" : customeraccmoney.ToString();
            selGetDept.SelectedValue = data.Rows[0]["GETDEPARTMENT"].ToString();
            txtGetDate.Text = data.Rows[0]["GETDATE"].ToString();
            string managerDept = data.Rows[0]["MANAGERDEPT"].ToString();//客户经理所在部门
            if (managerDept!="")
            {
                if (isExistDepartment(managerDept) && isExistStaff(managerDept))
                {
                    selDept.SelectedValue = data.Rows[0]["MANAGERDEPT"].ToString();//客户经理所在部门
                    selDept_Changed(sender,e);
                    selStaff.SelectedValue = data.Rows[0]["MANAGER"].ToString();//客户经理
                }
            }
            else
            {
                selDept.SelectedValue = "";
                selStaff.SelectedValue = "";
            }
            
            string queryCustInfo = "";
            string ImgType = string.Empty;
            if (data.Rows[0]["ORDERTYPE"].ToString() == "1")  //单位订单
            {
                selPapertype.Enabled = true;
                txtIDCardNo.Enabled = true;
                queryCustInfo = @"Select a.COMPANYPAPERTYPE,a.COMPANYPAPERNO,a.PAPERTYPE,a.ADDRESS,a.EMAIL,b.OUTBANK,b.OUTACCT,a.COMPANYMANAGERNO,a.COMPANYENDTIME,a.COMPANYNO,nvl2(a.COMPANYPAPERMSG,'1','0') COMPANYPAPERMSG,nvl2(a.MANAGERMSG,'1','0') MANAGERMSG,a.securityvalue/100.0  securityvalue,a.PAPERENDDATE
                              From TD_M_BUYCARDCOMINFO a,TF_F_COMBUYCARDREG b
                              Where a.COMPANYNO=b.COMPANYNO And b.REMARK = '" + selOrderNo.SelectedValue + "'";

                context.DBOpen("Select");
                DataTable queryCustInfodata = context.ExecuteReader(queryCustInfo);
                if (queryCustInfodata.Rows.Count > 0)
                {
                    hidCompanyNo.Value = queryCustInfodata.Rows[0]["COMPANYNO"].ToString();
                    selComPapertype.SelectedValue = queryCustInfodata.Rows[0]["COMPANYPAPERTYPE"].ToString();
                    txtComPaperno.Text = queryCustInfodata.Rows[0]["COMPANYPAPERNO"].ToString();
                    txtEndDate.Text = queryCustInfodata.Rows[0]["COMPANYENDTIME"].ToString();
                    txtHoldNo.Text = queryCustInfodata.Rows[0]["COMPANYMANAGERNO"].ToString();

                    try
                    {
                        selPapertype.SelectedValue = queryCustInfodata.Rows[0]["PAPERTYPE"].ToString();
                    }
                    catch
                    {
                        selPapertype.SelectedIndex = -1;
                    }
                    txtCustaddr.Text = queryCustInfodata.Rows[0]["ADDRESS"].ToString();
                    txtEmail.Text = queryCustInfodata.Rows[0]["EMAIL"].ToString();
                    txtPaperEndDate.Text = queryCustInfodata.Rows[0]["PAPERENDDATE"].ToString();//身份证有效期
                    txtOutbank.Text = queryCustInfodata.Rows[0]["OUTBANK"].ToString();
                    txtOutacct.Text = queryCustInfodata.Rows[0]["OUTACCT"].ToString();
                    txtSecurityValue.Text = queryCustInfodata.Rows[0]["securityvalue"].ToString();//显示安全值
                    tdFileUpload.Attributes.Add("colspan", "2");
                    tdFileUpload2.Attributes.Add("colspan", "2");
                    if (!string.IsNullOrEmpty(txtEndDate.Text))
                    {
                        if (DateTime.ParseExact(txtEndDate.Text.ToString(), "yyyyMMdd", null) < DateTime.Now.AddDays(60))
                        {
                            context.AddMessage("证件有效期不足60天，请尽快更换单位证件信息");
                        }
                    }

                    if (queryCustInfodata.DefaultView[0]["COMPANYPAPERMSG"].ToString() == "1")
                    {
                        DateTime d = new DateTime();
                        ImgType = "compapermsg";
                        preview.Src = "GC_GetPicture.aspx?CompanyNo=" + hidCompanyNo.Value + "&d=" + d.ToString() + "&ImgType=" + ImgType;
                        tdShowPicture.Visible = true;
                        tdMsg.Visible = false;

                    }
                    else
                    {
                        tdShowPicture.Visible = false;
                        tdMsg.Visible = true;
                    }
                    if (queryCustInfodata.DefaultView[0]["MANAGERMSG"].ToString() == "1")
                    {
                        DateTime d = new DateTime();
                        ImgType = "commanagermsg";
                        preview2.Src = "GC_GetPicture.aspx?CompanyNo=" + hidCompanyNo.Value + "&d=" + d.ToString() + "&ImgType=" + ImgType;
                        tdShowPicture2.Visible = true;
                        tdMsg2.Visible = false;
                        
                    }
                    else
                    {
                        tdShowPicture2.Visible = false;
                        tdMsg2.Visible = true;
                    }
                }
                //else
                //{
                //    hidContainMsg.Value = "0";      //无单位证件信息
                //    spnCompanyMsg.Visible = true;
                //}
            }
            else   //个人订单
            {
                hidOrderNo.Value = selOrderNo.SelectedValue;
                tdShowPicture.Visible = false;
                tdMsg.Visible = false;
                tdFileUpload.Attributes.Add("colspan", "3");
                selCustsex.Enabled = true;
                txtCustbirth.Enabled = true;
                selPapertype.Enabled = false;//不允许修改经办人证件类型
                txtIDCardNo.Enabled = false;//不允许修改经办人证件号码
                queryCustInfo = @"Select a.PAPERTYPE,a.BIRTHDAY,a.SEX,a.PHONENO,a.ADDRESS, a.EMAIL,a.securityvalue/100.0 securityvalue,nvl2(a.MANAGERMSG,'1','0') MANAGERMSG,a.PAPERENDDATE
                                  From TD_M_BUYCARDPERINFO a,tf_f_perbuycardreg b
                                  Where a.PAPERTYPE = b.PAPERTYPE
                                  And a.PAPERNO = b.PAPERNO
                                  And b.REMARK = '" + selOrderNo.SelectedValue + "'";

                context.DBOpen("Select");
                DataTable queryCustInfodata = context.ExecuteReader(queryCustInfo);
                if (queryCustInfodata.Rows.Count > 0)
                {
                    selPapertype.SelectedValue = queryCustInfodata.Rows[0]["PAPERTYPE"].ToString();
                    txtCustbirth.Text = queryCustInfodata.Rows[0]["BIRTHDAY"].ToString();
                    selCustsex.SelectedValue = queryCustInfodata.Rows[0]["SEX"].ToString();
                    txtCustaddr.Text = queryCustInfodata.Rows[0]["ADDRESS"].ToString();
                    txtEmail.Text = queryCustInfodata.Rows[0]["EMAIL"].ToString();
                    txtSecurityValue.Text = queryCustInfodata.Rows[0]["securityvalue"].ToString();//显示安全值
                    txtPaperEndDate.Text = queryCustInfodata.Rows[0]["PAPERENDDATE"].ToString();//身份证有效期
                    tdFileUpload2.Attributes.Add("colspan", "2");
                    //个人订单存在经办人信息图片
                    if (queryCustInfodata.Rows[0]["MANAGERMSG"].ToString() == "1")
                    {
                        DateTime d = new DateTime();
                        preview2.Src = "GC_GetPicture.aspx?OrderNo=" + selOrderNo.SelectedValue + "&d=" + d.ToString();
                        tdShowPicture2.Visible = true;
                        tdMsg2.Visible = false;    
                    }
                    else
                    {
                        tdShowPicture2.Visible = false;
                        tdMsg2.Visible = true;
                    }

                }
                
            }

            //txtInvoiceNum.Text = data.Rows[0]["INVOICECOUNT"].ToString();
            //txtInvoiceMoney.Text = (Convert.ToInt32(data.Rows[0]["INVOICETOTALMONEY"].ToString()) / 100.0).ToString();
            //txtTotalCashGift.Text = (Convert.ToInt32(data.Rows[0]["TOTALCHARGECASHGIFT"].ToString()) / 100.0).ToString();

            //订单类型
            if (data.Rows[0]["ORDERTYPE"].ToString() == "1")
            {
                //单位订单
                CompanyOrder.Checked = true;
                Personal.Checked = false;
            }
            else
            {
                //个人订单
                Personal.Checked = true;
                CompanyOrder.Checked = false;
            }

            //默认修改和作废按钮不可用
            btnModify.Enabled = false;
            btnCancel.Enabled = false;

            //根据订单状态设置修改、作废按钮是否可用
            if (labOrderState.Text.Substring(0, 2) == "01")//录入待审核
            {
                //如果是录入待审核订单，可修改
                btnModify.Enabled = true;
            }

            if (labOrderState.Text.Substring(0, 2) == "00")//修改中
            {
                //如果是修改中订单，可作废
                btnCancel.Enabled = true;

                btnStockIn.Text = "修改";
            }
            else
            {
                btnStockIn.Text = "新增";
            }

            //修改状态单位证件信息非必填
            //if (btnStockIn.Text == "修改")
            //{
            //    hidContainMsg.Value = "1";
            //    spnCompanyMsg.Visible = false;
            //}

        }
        //获取利金卡信息
        data = GroupCardHelper.callOrderQuery(context, "CashOrderInfo", selOrderNo.SelectedValue);
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
        data = GroupCardHelper.callOrderQuery(context, "ChargeCardOrderInfo", selOrderNo.SelectedValue);
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
        data = GroupCardHelper.callOrderQuery(context, "SZTCardOrderInfo", selOrderNo.SelectedValue);
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
                dr["SZTTax"] = data.Rows[i]["ISTAX"].ToString();
                SZTCardTable.Rows.Add(dr);
                
            }
            gvSZTCard.DataSource = SZTCardTable;
            gvSZTCard.DataBind();
            for (int i = 0; i < gvSZTCard.Rows.Count; i++)
            {
                CheckBox txtTax = (CheckBox)gvSZTCard.Rows[i].FindControl("chkTax");
                if (data.Rows[i]["ISTAX"].ToString() == "0")
                {
                    txtTax.Checked = false;
                }
                else
                {
                    txtTax.Checked = true;
                }
            }
        }

        //获取旅游卡信息
        data = GroupCardHelper.callOrderQuery(context, "LvYouOrderInfo", selOrderNo.SelectedValue);
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

        //读卡器相关信息
        data = GroupCardHelper.callOrderQuery(context, "ReaderOrderInfo", selOrderNo.SelectedValue);
        if (data.Rows.Count > 0)
        {
            int readernum = Convert.ToInt32(data.Rows[0]["COUNT"].ToString());
            txtReadernum.Text = readernum == 0 ? "" : readernum.ToString();
        }

        //园林年卡相关信息
        data = GroupCardHelper.callOrderQuery(context, "GardenCardOrderInfo", selOrderNo.SelectedValue);
        if (data.Rows.Count > 0)
        {
            int gardencardnum = Convert.ToInt32(data.Rows[0]["COUNT"].ToString());
            txtParkOpennum.Text = gardencardnum == 0 ? "" : gardencardnum.ToString();
        }

        //休闲年卡相关信息
        data = GroupCardHelper.callOrderQuery(context, "RelaxCardOrderInfo", selOrderNo.SelectedValue);
        if (data.Rows.Count > 0)
        {
            int relaxcardnum = Convert.ToInt32(data.Rows[0]["COUNT"].ToString());
            txtXXOpennum.Text = relaxcardnum == 0 ? "" : relaxcardnum.ToString();
        }

        //获取开票信息
        data = GroupCardHelper.callOrderQuery(context, "InvoiceOrderInfo", selOrderNo.SelectedValue);
        if (data != null && data.Rows.Count > 0)
        {
            InvoiceTable.Rows.Clear();
            for (int i = 0; i < data.Rows.Count; i++)
            {
                DataRow dr = InvoiceTable.NewRow();
                dr["Invoicetype"] = data.Rows[i]["INVOICETYPECODE"].ToString();
                //dr["InvoiceNum"] = data.Rows[i]["INVOICENUM"].ToString();
                dr["InvoiceMoney"] = data.Rows[i]["INVOICEMONEY"].ToString();
                InvoiceTable.Rows.Add(dr);
                //chkListInvoice.Items[Convert.ToInt32(data.Rows[i]["INVOICETYPECODE"])].Selected = true;
            }
            gvInvoice.DataSource = InvoiceTable;
            gvInvoice.DataBind();
        }
        //获取支付方式信息
        data = GroupCardHelper.callOrderQuery(context, "PayTypeOrderInfo", selOrderNo.SelectedValue);
        if (data != null && data.Rows.Count > 0)
        {
            for (int i = 0; i < data.Rows.Count; i++)
            {
                chkListPayType.Items[Convert.ToInt32(data.Rows[i]["PAYTYPECODE"])].Selected = true;
            }
        }
        //获取开票方式
        data = GroupCardHelper.callOrderQuery(context, "InvoiceTypeOrderInfo", selOrderNo.SelectedValue);
        if (data != null && data.Rows.Count > 0)
        {
            for (int i = 0; i < data.Rows.Count; i++)
            {
                chkPrintType.Items[Convert.ToInt32(data.Rows[i]["INVOICETYPECODE"])].Selected = true;
            }
        }
        else
        {
            chkPrintType.Items[0].Selected = false;
            chkPrintType.Items[1].Selected = false;
        }
        ShowTotalMoney();
        //ViewState["orderno"] = GetOrderNo();
        //lblOrderNo.Text = ViewState["orderno"].ToString();
     
    }
    /// <summary>
    /// 清除信息
    /// </summary>
    protected void clearInfo(bool isClear)
    {
        if (isClear)
        {
            labOrderState.Text = "";
            txtGroup.Text = "";
            selGroup.Items.Clear();
            tdShowPicture.Visible = false;
            tdMsg.Visible = false;
            tdShowPicture2.Visible = false;
            tdMsg2.Visible = false;
        }
        selComPapertype.SelectedIndex = -1;
        txtComPaperno.Text = "";
        txtName.Text = "";
        txtEndDate.Text = "";
        txtHoldNo.Text = "";
        selCustsex.SelectedIndex = -1;
        selPapertype.SelectedIndex = -1;
        txtIDCardNo.Text = "";
        txtCustbirth.Text = "";
        txtPhone.Text = "";
        txtCustaddr.Text = "";
        txtEmail.Text = "";
        txtOutbank.Text = "";
        txtOutacct.Text = "";

        txtRemark.Text = "";

        
    }

    /// <summary>
    /// 获取订单号
    /// </summary>
    /// <returns></returns>
    //private string GetOrderNo()
    //{
    //    string orderno = "";
    //    context.SPOpen();
    //    context.AddField("p_orderDate").Value = DateTime.Now.ToString("yyyyMMdd");
    //    context.AddField("p_orderSeq", "String", "output", "4", null);
    //    context.ExecuteReader("SP_GC_GetOrderNo");
    //    string orderStr = DateTime.Now.ToString("yyyyMMddHHmmss").Substring(2, 12);
    //    string orderSeq = context.GetFieldValue("p_orderSeq").ToString();
    //    orderno = orderStr + orderSeq;
    //    ViewState["seqno"] = orderSeq;
    //    return orderno;
    //}
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
    protected void queryGroup(object sender, EventArgs e)
    {
        OrderHelper.queryCompany(context, txtGroup, selGroup);

        ValidCompany_Change(sender, e);

        //计算总金额 重新显示
        ShowTotalMoney();
        tdFileUpload.Attributes.Add("colspan", "3");
        tdShowPicture.Visible = false;
        tdMsg.Visible = false;

        tdShowPicture2.Visible = false;
        tdMsg2.Visible = false;
       
    }

    /// <summary>
    /// 校验单位证件信息是否更改
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ValidCompany_Change(object sender, EventArgs e)
    {
        hidCompanyName.Value = "";
        if (btnStockIn.Text == "新增")
        {
            DataTable data = GroupCardHelper.callOrderQuery(context, "ValidCompany", selComPapertype.SelectedValue, txtComPaperno.Text.Trim(), txtGroup.Text.Trim());

            if (data.Rows.Count > 0)
            {
                hidCompanyName.Value = data.Rows[0]["COMPANYNAME"].ToString();
                if (hidCompanyName.Value != txtGroup.Text.Trim())
                {
                    //存在相同的单位证件类型、单位证件号码 但单位名称不同
                    //ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript", "submitCompany();", true);
                    context.AddMessage("持此单位证件类型和证件号码的单位已存在，名称为：" + hidCompanyName.Value + "，与输入的单位名称不一致，如果新增，将替换原单位名称！");
                }
            }
        }
        ShowTotalMoney();
    }
    /// <summary>
    /// 订单信息录入，单位名称下拉选框选择事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void selGroup_Change(object sender, EventArgs e)
    {
        if (selGroup.SelectedItem != null && selGroup.SelectedIndex > 0 && selGroup.SelectedItem.ToString()!=string.Empty)
        {
            txtGroup.Text = selGroup.SelectedItem.ToString();
            DataTable data = GroupCardHelper.callOrderQuery(context, "QueryOrderContactPerson", txtGroup.Text);
            if (data != null && data.Rows.Count > 0)
            {
                selComPapertype.SelectedValue = data.Rows[0]["COMPANYPAPERTYPE"].ToString();
                txtComPaperno.Text = data.Rows[0]["COMPANYPAPERNO"].ToString();
                txtHoldNo.Text = data.Rows[0]["COMPANYMANAGERNO"].ToString();
                txtEndDate.Text = data.Rows[0]["COMPANYENDTIME"].ToString();
                txtName.Text = data.Rows[0]["NAME"].ToString();
                txtPhone.Text = data.Rows[0]["PHONE"].ToString();
                txtIDCardNo.Text = data.Rows[0]["IDCARDNO"].ToString();
                txtPaperEndDate.Text = data.Rows[0]["PAPERENDDATE"].ToString();
                try
                {
                    selPapertype.SelectedValue = data.Rows[0]["PAPERTYPE"].ToString();
                }
                catch 
                {
                    selPapertype.SelectedIndex = -1;
                }
                txtCustaddr.Text = data.Rows[0]["ADDRESS"].ToString();
                txtEmail.Text = data.Rows[0]["EMAIL"].ToString();
                txtOutbank.Text = data.Rows[0]["OUTBANK"].ToString();
                txtOutacct.Text = data.Rows[0]["OUTACCT"].ToString();

                txtSecurityValue.Text = data.Rows[0]["securityvalue"].ToString();//显示安全值 add by youyue

                string companyno = data.Rows[0]["COMPANYNO"].ToString();
                tdShowPicture.Visible = true;//显示图片
                tdShowPicture2.Visible = true;//显示经办人信息图片 add by youyue
                tdFileUpload.Attributes.Add("colspan", "2");
                tdFileUpload2.Attributes.Add("colspan", "2");
                string ImgType = string.Empty;
                //查询验证单位是否已有单位证件信息和经办人信息图片 
                string sql = @"select nvl2(a.COMPANYPAPERMSG,'1','0') COMPANYPAPERMSG, nvl2(a.MANAGERMSG,'1','0') MANAGERMSG
                              From TD_M_BUYCARDCOMINFO a
                              Where a.COMPANYNO = '" + companyno + "'";


                context.DBOpen("Select");
                DataTable hasCompanypaperMSGdata = context.ExecuteReader(sql);
                if (hasCompanypaperMSGdata.Rows.Count > 0)
                {
                    if (hasCompanypaperMSGdata.DefaultView[0]["COMPANYPAPERMSG"].ToString() == "1")//已存在单位证件信息
                    {  
                        DateTime d = new DateTime();
                        ImgType = "compapermsg";
                        preview.Src = "GC_GetPicture.aspx?CompanyNo=" + companyno + "&d=" + d.ToString() + "&ImgType=" + ImgType;//显示单位证件信息扫描件
                        tdMsg.Visible = false; 
                    }
                    else
                    {

                        tdShowPicture.Visible = false;//不显示单位证件信息扫描件
                        tdMsg.Visible = true;
                    }
                    if (hasCompanypaperMSGdata.DefaultView[0]["MANAGERMSG"].ToString() == "1")//已存在经办人信息 add by youyue
                    {
                        DateTime d = new DateTime();
                        ImgType = "commanagermsg";
                        preview2.Src = "GC_GetPicture.aspx?CompanyNo=" + companyno + "&d=" + d.ToString() + "&ImgType=" + ImgType;//显示经办人信息扫描件

                        tdMsg2.Visible = false;
                    }
                    else
                    {

                        tdShowPicture2.Visible = false;//不显示经办人信息扫描件
                        tdMsg2.Visible = true;
                    }

                }
                 
//                if (hasCompanypaperMSGdata.Rows.Count > 0)
//                {
//                    if (hasCompanypaperMSGdata.DefaultView[0]["COMPANYPAPERMSG"].ToString() == "1")
//                    {
//                        hidContainMsg.Value = "1";  //已存在单位证件信息
//                        spnCompanyMsg.Visible = false;
//                    }
//                    else
//                    {
//                        hidContainMsg.Value = "0";  //无单位证件信息
//                        spnCompanyMsg.Visible = true;
//                    }
//                }

                if (!string.IsNullOrEmpty(txtEndDate.Text))
                {
                    if (DateTime.ParseExact(txtEndDate.Text.ToString(), "yyyyMMdd", null)<DateTime.Now.AddDays(60))
                    {
                        context.AddMessage("证件有效期不足60天，请尽快更换单位证件信息");
                    }
                }
            }
            else
            {
                clearInfo(false);
            }
        }
        else
        {
            if(CompanyOrder.Checked == true)
            {
            clearInfo(false);
            }
        }
        //计算总金额 重新显示
        ShowTotalMoney();
    }
    #endregion
    #region 订单类型Radio选择事件
    /// <summary>
    /// 订单类型Radio选择事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void OrderType_Changed(object sender, EventArgs e)
    {
        if (CompanyOrder.Checked)
        {
            selCustsex.SelectedValue = "";
            selCustsex.Enabled = false;
            txtCustbirth.Text = "";
            txtCustbirth.Enabled = false;

            txtGroup.Enabled = true;
            selGroup.Enabled = true;
            selComPapertype.Enabled = true;
            txtComPaperno.Enabled = true;
            txtEndDate.Enabled = true;
            txtHoldNo.Enabled = true;
            txtOutbank.Enabled = true;
            txtOutacct.Enabled = true;
            FileUpload1.Enabled = true;
            spnGroup.Visible = true;
            spnComPapertype.Visible = true;
            spnComPaperno.Visible = true;
            //if (hidContainMsg.Value == "0")
            //{
            //    spnCompanyMsg.Visible = true;
            //}
            //else
            //{
            //    spnCompanyMsg.Visible = false;
            //}
            spnCompanyEndDate.Visible = true;
            
        }
        else
        {
            txtGroup.Text = "";
            txtGroup.Enabled = false;
            selGroup.SelectedValue = "";
            selGroup.Enabled = false;
            selComPapertype.SelectedValue = "";
            selComPapertype.Enabled = false;
            txtComPaperno.Text = "";
            txtComPaperno.Enabled = false;
            txtHoldNo.Text = "";
            txtHoldNo.Enabled = false;
            txtEndDate.Text = "";
            txtEndDate.Enabled = false;
            txtOutbank.Text = "";
            txtOutbank.Enabled = false;
            txtOutacct.Text = "";
            txtOutacct.Enabled = false;

            selCustsex.Enabled = true;
            txtCustbirth.Enabled = true;

            spnGroup.Visible = false;
            spnComPapertype.Visible = false;
            spnComPaperno.Visible = false;
            //spnCompanyMsg.Visible = false;
            spnCompanyEndDate.Visible = false;
            FileUpload1.Enabled = false;
        }
        tdShowPicture.Visible = false;
        tdMsg.Visible = false;
        tdFileUpload.Attributes.Add("colspan", "3");
    }
    #endregion
    private void InitStaffList(DropDownList selStaffno, string deptNo)
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
                GroupCardHelper.fill(selStaffno, table, true);

                return;
            }

            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";

            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_DIMMISSIONTAG_USEFUL", null);
            ControlDeal.SelectBoxFill(selStaffno.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
            selStaffno.SelectedValue = context.s_UserID;
        }
        else
        {
            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            tdoTD_M_INSIDESTAFFIn.DEPARTNO = deptNo;
            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";

            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_DEPT", null);
            ControlDeal.SelectBoxFill(selStaffno.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
        }
    }
    protected void selDept_Changed(object sender, EventArgs e)
    {
        InitStaffList(selStaff, selDept.SelectedValue);
    }
    /// <summary>
    /// 验证是否存在部门
    /// </summary>
    /// <param name="transactor"></param>
    /// <returns></returns>
    private bool isExistDepartment(string depart)
    {
        string query = @"Select a.departno From td_m_insidedepart a Where a.departno='" + depart + "'";
        context.DBOpen("Select");
        DataTable data = context.ExecuteReader(query);
        if (data.Rows.Count > 0)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    private bool isExistStaff(string depart)
    {
        string query = @"Select a.staffno From td_m_insidestaff a Where a.departno='" + depart + "' and a.dimissiontag='1'";
        context.DBOpen("Select");
        DataTable data = context.ExecuteReader(query);
        if (data.Rows.Count > 0)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
}
