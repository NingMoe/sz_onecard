using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using PDO.AdditionalService;
using TM;
using Common;

// 亲子补换卡
//modify by jiangbb 2015-04-20 开通方式


public partial class ASP_AddtionalService_AS_AffectCardChange : Master.FrontMaster
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        // 设置可读属性


        if (!context.s_Debugging) txtCardNo.Attributes["readonly"] = "true";

        setReadOnly(txtCardBalance, txtStartDate);


        //初始化套餐类型
        ASHelper.initPackageTypeList(context, selPackageType);

        // 初始化费用列表


        decimal total = initFeeList(gvResult, "33");
        hidAccRecv.Value = total.ToString("n");

        // 初始化旧卡信息查询结果gridview
        UserCardHelper.resetData(gvOldCardInfo, null);

    }

    // 读卡处理
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        btnPrintPZ.Enabled = false;
        preview_size_fake.Src = "";

        #region add by shil 20130909,如果是旅游年卡，则不允许在该页面办理业务
        //验证卡片是否旅游年卡(51)，如果是旅游年卡，则不允许在该页面办理业务

        bool cardTypeOk = CommonHelper.allowCardtype(context, txtCardNo.Text, "5101", "5103");
        if (cardTypeOk == false)
        {
            return;
        }
        #endregion

        // 检查帐户信息


        checkAccountInfo(txtCardNo.Text);

        // 检查惠民亲子卡特征

        checkRelaxFeature();

        checkGardenIsInvalid();//判断当前卡是否是是园林账户表中无效的卡 add by youyue 20141229

        checkParkIsInvalid();

        // 读取卡片类型
        readCardType(txtCardNo.Text, labCardType);

        //add by jiangbb 2012-10-09  加入判断 旧卡或新卡为市民卡不会修改客户资料 
        if (!context.hasError() && txtCardNo.Text.Substring(4, 2).ToString() == "18")
        {
            context.AddMessage("提示：新卡卡号为市民卡，客户资料不会被修改");
        }

        hidReadCardOK.Value = !context.hasError() && txtCardNo.Text.Length > 0 ? "ok" : "fail";

        btnSubmit.Enabled = hidReadCardOK.Value == "ok"
            && gvOldCardInfo.SelectedIndex >= 0;

    }

    // 对话框确认处理

    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "writeSuccess")  // 写卡成功
        {
            clearCustInfo(txtCardNo, txtCustName, txtCustBirth, selPaperType, txtPaperNo,
               selCustSex, txtCustPhone, txtCustPost, txtCustAddr, txtEmail, txtRemark);

            AddMessage("D005060003: 惠民亲子卡前台写卡成功，补换卡成功");
        }
        else if (hidWarning.Value == "writeFail") // 写卡失败
        {
            context.AddError("A00506C001: 惠民亲子卡前台写卡失败，补换卡失败");
        }

        hidWarning.Value = "";  // 清除警告信息
        if (chkPingzheng.Checked && btnPrintPZ.Enabled)
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "printInvoice();", true);
        }
    }

    // 查询处理
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        // 输入项判断处理（证件号码、旧卡号码、客户姓名）
        // ASHelper.changeCardQueryValidate(context, txtId, txtOldCardNo, txtName);
        // if (context.hasError()) return;

        // 从休闲卡资料表中查询
        string strValue = txtCondition.Text;
        if (selQueryType.SelectedValue == "02" || selQueryType.SelectedValue == "03" || selQueryType.SelectedValue == "04")   //证件号码
        {
            StringBuilder strBuilder = new StringBuilder();
            AESHelp.AESEncrypt(strValue, ref strBuilder);
            strValue = strBuilder.ToString();
        }
        DataTable data = ASHelper.callQuery(context, "XXQueryOldCards", selQueryType.SelectedValue,
            strValue);


        if (data == null || data.Rows.Count == 0)
        {
            UserCardHelper.resetData(gvOldCardInfo, data);
            AddMessage("N005030001: 查询结果为空");
        }
        else
        {
            //add by jiangbb 解密
            CommonHelper.AESDeEncrypt(data, new List<string>(new string[] { "CUSTNAME", "CUSTPHONE", "CUSTADDR", "PAPERNO" }));

            UserCardHelper.resetData(gvOldCardInfo, data);

            gvOldCardInfo.SelectedIndex = 0;
            gvOldCardInfo_SelectedIndexChanged(sender, e);
        }
    }

    // 检查休闲卡特征值


    void checkRelaxFeature()
    {
        // 从休闲卡资料表中检查USETAG值


        DataTable data = ASHelper.callQuery(context, "XXParkCardUseTag", txtCardNo.Text);
        if (data.Rows.Count > 0)
        {
            context.AddError("A005060001: 当前卡已经是惠民亲子卡");
        }
    }

    // 旧卡信息查询结果gridview行创建事件


    protected void gvOldCardInfo_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件


            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvOldCardInfo','Select$" + e.Row.RowIndex + "')");
        }
    }

    //没有客户信息查看权则证件号码加*显示
    protected void gvOldCardInfo_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (!CommonHelper.HasOperPower(context))
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                e.Row.Cells[5].Text = CommonHelper.GetPaperNo(e.Row.Cells[5].Text);
            }
        }
    }

    // 旧卡信息查询结果行选择事件
    public void gvOldCardInfo_SelectedIndexChanged(object sender, EventArgs e)
    {
        hidServiceFor.Value = "0";

        // 得到选择行


        GridViewRow selectRow = gvOldCardInfo.SelectedRow;

        // 根据选择行卡号读取用户信息


        readCustInfo(selectRow.Cells[0].Text, txtCustName, txtCustBirth,
            selPaperType, txtPaperNo, selCustSex, txtCustPhone, txtCustPost,
            txtCustAddr, txtEmail, txtRemark);

        readCardPic(selectRow.Cells[0].Text);

        hidForPaperNo.Value = txtPaperNo.Text.Trim();
        hidForPhone.Value = txtCustPhone.Text.Trim();
        hidForAddr.Value = txtCustAddr.Text.Trim();

        //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
        if (!CommonHelper.HasOperPower(context))
        {
            txtPaperNo.Text = CommonHelper.GetPaperNo(txtPaperNo.Text);
            txtCustPhone.Text = CommonHelper.GetCustPhone(txtCustPhone.Text);
            txtCustAddr.Text = CommonHelper.GetCustAddress(txtCustAddr.Text);
        }

        DataTable data = ASHelper.callQuery(context, "QueryAffectPackage", selectRow.Cells[0].Text);

        if (data != null && data.Rows.Count > 0)
        {
            selPackageType.SelectedValue = data.Rows[0][0].ToString();
        }

        hidEndDate.Value = selectRow.Cells[1].Text;
        hidUsabelTimes.Value = selectRow.Cells[3].Text;

        //读取账户类型
        ASHelper.readAccountType(context, selectRow.Cells[0].Text, labAccountType);

        if (!context.hasError() && gvOldCardInfo.SelectedRow.Cells[0].Text.Substring(4, 2).ToString() == "18")
        {
            context.AddMessage("提示：旧卡卡号为市民卡，客户资料不会被修改");
        }
        btnSubmit.Enabled = !context.hasError() && hidReadCardOK.Value == "ok";

        if (selectRow.Cells[1].Text.ToString().CompareTo(DateTime.Now.ToString("yyyyMMdd")) >= 0)
        {
            hidServiceFor.Value = "1";
        }
    }

    // 提交前输入项校验
    private void submitValidate()
    {

        if (selPackageType.SelectedValue == "")
        {
            context.AddError("套餐类型不能为空", selPackageType);
        }
    }

    private void custInfoForValidate(TextBox txtCustName, TextBox txtCustBirth,
            DropDownList selPaperType, TextBox txtPaperNo,
            DropDownList selCustSex, TextBox txtCustPhone,
            TextBox txtCustPost, TextBox txtCustAddr, TextBox txtCustEmail, TextBox txtRemark)
    {
        Validation valid = new Validation(context);
        txtCustName.Text = txtCustName.Text.Trim();
        valid.check(Validation.strLen(txtCustName.Text) <= 50, "A005010001, 客户姓名长度不能超过50", txtCustName);
        valid.check(!Validation.isEmpty(txtCustName), "客户姓名不能为空", txtCustName);

        bool b = Validation.isEmpty(txtCustBirth);
        if (!b)
        {
            b = valid.fixedLength(txtCustBirth, 8, "A005010002: 出生日期必须为8位");
            if (b)
            {
                valid.beDate(txtCustBirth, "A005010003: 出生日期格式必须是yyyyMMdd");
            }
        }

        b = Validation.isEmpty(txtCustPost);
        if (!b)
        {
            b = valid.fixedLength(txtCustPost, 6, "A005010004: 邮政编码必须为6位");
            if (b)
            {
                valid.beNumber(txtCustPost, "A005010005: 邮政编码必须是数字");
            }
        }

        if (selPaperType.SelectedValue == "")
        {
            context.AddError("证件类型不能为空", selPaperType);
        }

        b = Validation.isEmpty(txtPaperNo);
        valid.check(!b, "证件号码不能为空", txtPaperNo);

        if (!b)
        {
            b = valid.check(Validation.strLen(txtPaperNo.Text) <= 20, "A005010006: 证件号码位数必须小于等于20", txtPaperNo);
            //判断是否有客户信息查看权限

            if (CommonHelper.HasOperPower(context) || CommonHelper.GetPaperNo(hidForPaperNo.Value) != txtPaperNo.Text.Trim())
            {
                if (b)
                {
                    valid.beAlpha(txtPaperNo, "A005010007: 证件号码必须是英文或者数字");
                }
            }
        }

        b = Validation.isEmpty(txtCustPhone);
        if (!b)
        {
            b = valid.check(Validation.strLen(txtCustPhone.Text) <= 20, "A005010008: 联系电话位数必须小于等于20", txtCustPhone);
            //if (b)
            //{
            //    valid.beNumber(txtCustPhone, "A005010009: 联系电话必须是数字");
            //}
        }
        b = Validation.isEmpty(txtCustAddr);
        if (!b)
        {
            valid.check(Validation.strLen(txtCustAddr.Text) <= 50, "A005010010: 联系地址位数必须小于等于50", txtCustAddr);
        }

        valid.isEMail(txtCustEmail);

        b = Validation.isEmpty(txtRemark);
        if (!b)
        {
            valid.check(Validation.strLen(txtRemark.Text) <= 100, "A005010011: 备注位数必须小于等于100", txtRemark);
        }
    }

    // 休闲年卡补换卡提交处理


    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        // 提交前输入校验


        submitValidate();
        if (context.hasError()) return;

        int usableTimes = int.Parse(hidUsabelTimes.Value);

        hidParkInfo.Value = hidEndDate.Value + selPackageType.SelectedValue + usableTimes.ToString("X2");

        if (hidParkInfo.Value.Trim().Length != 12)
        {
            context.AddError("写卡数据有误");
            return;
        }

        //获取身份证Code
        string paperTypeCode = string.Empty;
        DataTable data = ASHelper.callQuery(context, "ReadPaperCode", selPaperType.Text);
        if (data.Rows.Count > 0)
        {
            paperTypeCode = (string)data.Rows[0].ItemArray[0];
        }

        //add by jiangbb 2012-10-17 判断页面上的证件号码、联系电话、联系地址是否修改 并取值

        string custPaperNo = CommonHelper.GetPaperNo(hidForPaperNo.Value) == txtPaperNo.Text.Trim() ? hidForPaperNo.Value : txtPaperNo.Text.Trim();
        string custPhone = CommonHelper.GetCustPhone(hidForPhone.Value) == txtCustPhone.Text.Trim() ? hidForPhone.Value : txtCustPhone.Text.Trim();
        string custAddr = CommonHelper.GetCustAddress(hidForAddr.Value) == txtCustAddr.Text.Trim() ? hidForAddr.Value : txtCustAddr.Text.Trim();

        StringBuilder strBuilder = new StringBuilder();
        // 调用休闲年卡补换卡存储过程

        hidNewCardNo.Value = txtCardNo.Text;
        //获取卡有效期限

        context.DBOpen("Select");
        string sql = @" SELECT ENDDATE  FROM TF_F_CARDXXPARKACC_SZ WHERE CARDNO = '" + gvOldCardInfo.SelectedRow.Cells[0].Text + "'";
        DataTable table = context.ExecuteReader(sql);
        string cardUseEndTime = Convert.ToString(table.Rows[0][0]);

        context.SPOpen();
        string id = DealString.GetRecordID(hidTradeNo.Value, hidAsn.Value);
        context.AddField("p_ID").Value = id;
        context.AddField("P_OLDCARDNO").Value = gvOldCardInfo.SelectedRow.Cells[0].Text;
        context.AddField("P_NEWCARDNO").Value = txtCardNo.Text;
        context.AddField("P_ASN").Value = hidAsn.Value.Substring(4, 16);
        context.AddField("P_OPERCARDNO").Value = context.s_CardID; // 操作员卡
        context.AddField("P_TERMINALNO").Value = "112233445566";   // 目前固定写成112233445566
        context.AddField("P_ENDDATENUM").Value = hidEndDate.Value + selPackageType.SelectedValue + usableTimes.ToString("X2");
        context.AddField("P_PACKAGETYPECODE").Value = selPackageType.SelectedValue;

        AESHelp.AESEncrypt(txtCustName.Text, ref strBuilder);
        context.AddField("P_CUSTNAME").Value = strBuilder.ToString();
        context.AddField("P_CUSTSEX").Value = selCustSex.Text == "男" ? "0" : "1";
        context.AddField("P_CUSTBIRTH").Value = txtCustBirth.Text;
        context.AddField("P_PAPERTYPE").Value = paperTypeCode;
        AESHelp.AESEncrypt(custPaperNo, ref strBuilder);
        context.AddField("P_PAPERNO").Value = strBuilder.ToString();
        AESHelp.AESEncrypt(custAddr, ref strBuilder);
        context.AddField("P_CUSTADDR").Value = strBuilder.ToString();
        context.AddField("P_CUSTPOST").Value = txtCustPost.Text;
        AESHelp.AESEncrypt(custPhone, ref strBuilder);
        context.AddField("P_CUSTPHONE").Value = strBuilder.ToString();
        context.AddField("P_CUSTEMAIL").Value = txtEmail.Text;
        context.AddField("P_REMARK").Value = txtRemark.Text;
        context.AddField("P_PASSPAPERNO").Value = custPaperNo;
        context.AddField("P_PASSCUSTNAME").Value = txtCustName.Text;    //明文姓名
        context.AddField("P_SERVICEFOR").Value = hidServiceFor.Value;   //是否同步休闲标识位 0不同步 1同步
        context.AddField("p_CITYCODE").Value = "2150";


        // 执行存储过程
        bool ok = context.ExecuteSP("SP_AS_AffectCardChange");
        txtCardNo.Text = "";
        UserCardHelper.resetData(gvOldCardInfo, null);
        gvOldCardInfo.SelectedIndex = -1;
        hidReadCardOK.Value = "fail";
        btnSubmit.Enabled = false;

        // 调用成功，显示成功信息


        if (ok)
        {
            context.AddMessage("补换卡成功！");

            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "startXXPark();", true);

            btnPrintPZ.Enabled = true;

            ASHelper.preparePingZheng(ptnPingZheng, context.s_DepartName, context.s_UserID,
                    "惠民亲子卡补换卡", id,
                    hidAccRecv.Value, "0.00", hidNewCardNo.Value, cardUseEndTime);
        }
        readCardPic(hidNewCardNo.Value);

        hfPic.Value = "";
        Session["PicData"] = null;
        preview_size_fake.Src = "";
        hidNewCardNo.Value = "";
    }

    //显示照片
    protected void BtnShowPic_Click(object sender, EventArgs e)
    {
        preview_size_fake.Src = "";

        string str = hfPic.Value;

        if (string.IsNullOrEmpty(str))
            return;

        int len = str.Length / 2;
        byte[] pic = new byte[len];
        HexStrToBytes(str, ref pic, len);

        preview_size_fake.Src = "../../picture.aspx?id=" + DateTime.Now.ToString();
    }

    int HexStrToBytes(string strSou, ref byte[] BytDes, int bytCount)
    {
        int i;
        int len;
        int HighByte, LowByte;

        len = strSou.Length;
        if (bytCount * 2 < len) len = bytCount * 2;

        if ((len - len / 2 * 2) == 0)
        {
            for (i = 0; i < len; i += 2)
            {
                HighByte = (byte)strSou[i];
                LowByte = (byte)strSou[i + 1];

                if (HighByte > 0x39) HighByte -= 0x37;
                else HighByte -= 0x30;

                if (LowByte > 0x39) LowByte -= 0x37;
                else LowByte -= 0x30;

                BytDes[i / 2] = (byte)((HighByte << 4) | LowByte);
            }
            for (; i < bytCount * 2; i += 2)
            {
                BytDes[i / 2] = 0;
            }
            return (len / 2);
        }
        else
            return 0;
    }

    private void readCardPic(string cardNo)
    {
        byte[] imageData = ReadImage(cardNo);

        if (imageData != null)
        {
            Session["PicData"] = imageData;
            preview_size_fake.Src = "../../picture.aspx?id=" + DateTime.Now.ToString();

        }
        else
        {
            context.SPOpen();
            context.AddField("p_CARDNO").Value = cardNo;
            context.AddField("p_LENGTH", "String", "output", "16", null);
            bool ok = context.ExecuteSP("SP_AS_SMK_PICTURELENGTH");
            {
                string length = context.GetFieldValue("p_LENGTH").ToString().Trim();

            }
        }
    }

    private byte[] ReadImage(string cardNo)
    {
        string selectSql = "Select PICTURE From TF_F_CARDPARKPHOTO_SZ Where CARDNO=:CARDNO";
        context.DBOpen("Select");
        context.AddField(":CARDNO").Value = cardNo;
        DataTable dt = context.ExecuteReader(selectSql);
        if (dt != null && dt.Rows.Count > 0 && dt.DefaultView[0]["PICTURE"].ToString() != "")
        {
            return (byte[])dt.Rows[0].ItemArray[0];
        }

        return null;
    }



    //查询新卡是否是园林账户表中无效状态的卡(即通过功能补换页面将旧卡置为无效的卡)
    private void checkGardenIsInvalid()
    {
        // 从园林卡资料表中检查USETAG值是否是0
        DataTable data = ASHelper.callQuery(context, "RelaxCardUseIsInvalid", txtCardNo.Text);
        if (data.Rows.Count > 0)
        {
            context.AddError("A005020002: 当前卡已经是园林账户表中无效的卡，不可再次开通");
        }
    }

    //查询新卡是否是有效的休闲年卡
    private void checkParkIsInvalid()
    {
        // 从休闲卡资料表中检查USETAG值是否是0
        DataTable data = ASHelper.callQuery(context, "ParkCardInfo", txtCardNo.Text);
        if (data.Rows.Count != 0)
        {
            string packageTypeCode = data.Rows[0][0].ToString();
            string endDate = data.Rows[0][1].ToString();
            if ((packageTypeCode != "E1" && packageTypeCode != "E2") &&
                DateTime.ParseExact(endDate, "yyyyMMdd", null) > DateTime.ParseExact(DateTime.Now.ToString("yyyyMMdd"), "yyyyMMdd", null))
            {
                context.AddError("A005020003:当前卡片已经是有效的休闲年卡，且未到期，不可再次开通亲子卡");
            }
        }
    }
}
