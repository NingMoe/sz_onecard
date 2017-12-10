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
using Common;
using System.Text;
/***************************************************************
 * 功能名: 读卡器出售
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2012/08/21    shil			初次开发
 ****************************************************************/
public partial class ASP_PersonalBusiness_PB_SaleReader : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //绑定JS事件
            txtReader.Attributes["OnBlur"] = "javascript:return Change();";
            txtEndReader.Attributes["OnBlur"] = "javascript:return Change();";
            txtSaleMoney.Attributes["OnChange"] = "javascript:return Change();";
            //设为只读
            setReadOnly(txtReaderNum, txtMoneySum);
            //默认是单个出售
            hidSaleType.Value = "1";

            //从证件类型编码表(TD_M_PAPERTYPE)中读取数据，放入下拉列表中
            ASHelper.initPaperTypeList(context, selPaperType);
            //初始化性别
            ASHelper.initSexList(selCustSex);

            #region 添加对代理营业厅预付款的验证
            if (DeptBalunitHelper.ValdatePrepay(context) == false)
            {
                return;
            }
            #endregion
        }
        //固化单选框
        ScriptManager.RegisterStartupScript(this, this.GetType(), "radioTagScript", "SelectRadioTag();", true);
    }
    /// <summary>
    /// 获取读卡器单价
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Reader_OnTextChanged(object sender, EventArgs e)
    {
        if (Validation.strLen(txtReader.Text.Trim()) == 16 && Validation.isNum(txtReader.Text.Trim()))
        {
            string sql = "SELECT MONEY/100.0 FROM TL_R_READER WHERE SERIALNUMBER = '" + txtReader.Text.Trim() + "'";
            context.DBOpen("Select");
            DataTable data = context.ExecuteReader(sql);
            if (data.Rows.Count != 0)
            {
                txtSaleMoney.Text = data.Rows[0][0].ToString();
            }
        }
    }
    /// <summary>
    /// 提交按钮点击事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        if (hidSaleType.Value == "1")//单个出售
            //输入校验
            if (!SaleValidation()) return;

        if (hidSaleType.Value == "0")//批量出售
            //输入校验
            if (!BatchSaleValidation()) return;

        //校验出售权限
        if (!checkPower()) return;

        #region 添加对代理营业厅预付款的验证,提交前如果扣费后不足最低额度则返回
        int opMoney = 0;
        if (hidSaleType.Value == "1")//单个出售
            opMoney = Convert.ToInt32(Convert.ToDecimal(txtSaleMoney.Text) * 100);
        else
            opMoney = Convert.ToInt32(Convert.ToDecimal(txtSaleMoney.Text) * 100) * Convert.ToInt32(txtReaderNum.Text.Trim());
        if (DeptBalunitHelper.ValdatePrepay(context, opMoney, "2") == false)
            return;
        #endregion

        if (hidSaleType.Value == "1")//单个出售
            //确认读卡器序列号
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Check", "singleSubmitConfirm();", true);
        if (hidSaleType.Value == "0")//批量出售
            //确认读卡器序列号
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Check", "batchSubmitConfirm();", true);

    }
    /// <summary>
    /// 提交存处理
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        #region 添加对代理营业厅预付款的验证,扣费后如果超过最低则提示
        int opMoney = 0;
        if (hidSaleType.Value == "1")//单个出售
            opMoney = Convert.ToInt32(Convert.ToDecimal(txtSaleMoney.Text) * 100);
        else
            opMoney = Convert.ToInt32(Convert.ToDecimal(txtSaleMoney.Text) * 100) * Convert.ToInt32(txtReaderNum.Text.Trim());
        DeptBalunitHelper.ValdatePrepay(context, opMoney, "2");
        #endregion

        context.SPOpen();
        if (hidSaleType.Value == "1")//单个出售
        {
            StringBuilder strBuilder = new StringBuilder();

            context.AddField("p_FUNCCODE").Value = "SINGLESALE";
            context.AddField("P_SERIALNUMBER").Value = txtReader.Text.Trim();
            context.AddField("P_ENDSERIALNUMBER").Value = txtReader.Text.Trim();
            context.AddField("P_READERNUMBER").Value = 1;
            //姓名加密
            AESHelp.AESEncrypt(txtCustName.Text.Trim(), ref strBuilder);
            context.AddField("p_CUSTNAME").Value = strBuilder.ToString();

            context.AddField("p_CUSTSEX").Value = selCustSex.SelectedValue;
            //出生日期
            if (txtCustBirth.Text.Trim() != "")
            {
                String[] arr = (txtCustBirth.Text.Trim()).Split('-');

                String cDate = arr[0] + arr[1] + arr[2];

                context.AddField("p_CUSTBIRTH").Value = cDate;
            }
            else
            {
                context.AddField("p_CUSTBIRTH").Value = txtCustBirth.Text.Trim();
            }
            context.AddField("p_PAPERTYPECODE").Value = selPaperType.SelectedValue;
            //证件号码加密
            AESHelp.AESEncrypt(txtPaperNo.Text.Trim(), ref strBuilder);
            context.AddField("p_PAPERNO").Value = strBuilder.ToString();
            //住址加密
            AESHelp.AESEncrypt(txtCustAddr.Text.Trim(), ref strBuilder);
            context.AddField("p_CUSTADDR").Value = strBuilder.ToString();

            context.AddField("p_CUSTPOST").Value = txtCustPost.Text.Trim();
            //电话加密
            AESHelp.AESEncrypt(txtCustPhone.Text.Trim(), ref strBuilder);
            context.AddField("p_CUSTPHONE").Value = strBuilder.ToString();

            context.AddField("p_CUSTEMAIL").Value = txtEmail.Text.Trim();
            context.AddField("P_REMARK").Value = txtRemark.Text.Trim();
            context.AddField("p_MONEY").Value = Convert.ToInt32(txtSaleMoney.Text.Trim()) * 100;
            context.AddField("p_TRADEID", "String", "output", "16", null);
        }
        else//批量出售
        {
            context.AddField("p_FUNCCODE").Value = "BATCHSALE";
            context.AddField("P_SERIALNUMBER").Value = txtReader.Text.Trim();
            context.AddField("P_ENDSERIALNUMBER").Value = txtEndReader.Text.Trim();
            context.AddField("P_READERNUMBER").Value = txtReaderNum.Text.Trim();
            context.AddField("p_CUSTNAME").Value = "";
            context.AddField("p_CUSTSEX").Value = "";
            context.AddField("p_CUSTBIRTH").Value = "";
            context.AddField("p_PAPERTYPECODE").Value = "";
            context.AddField("p_PAPERNO").Value = "";
            context.AddField("p_CUSTADDR").Value = "";
            context.AddField("p_CUSTPOST").Value = "";
            context.AddField("p_CUSTPHONE").Value = "";
            context.AddField("p_CUSTEMAIL").Value = "";
            context.AddField("P_REMARK").Value = txtBatchRemark.Text.Trim();
            context.AddField("p_MONEY").Value = Convert.ToInt32(txtSaleMoney.Text.Trim()) * 100;
            context.AddField("p_TRADEID", "String", "output", "16", null);
        }

        bool ok = context.ExecuteSP("SP_PB_SALEREADER_COMMIT");
        if (ok)
        {
            AddMessage("出售成功！");
            //获取流水号
            hidTradeid.Value = context.GetFieldValue("p_TRADEID").ToString();
            //读卡器序列号赋值
            hidReaderno.Value = txtReader.Text.Trim();
            hidEndReaderno.Value = hidSaleType.Value == "1" ? "" : txtEndReader.Text.Trim();

            hidReaderNum.Value = hidSaleType.Value == "1" ? "1" : txtReaderNum.Text.Trim();
            //金额赋值
            hidSaleMoney.Value = txtSaleMoney.Text.Trim();
            #region 添加对代理营业厅预付款的验证,扣费后如果超过预警额度则提示
            opMoney = 0;
            if (hidSaleType.Value == "1")//单个出售
                opMoney = Convert.ToInt32(Convert.ToDecimal(txtSaleMoney.Text) * 100);
            else
                opMoney = Convert.ToInt32(Convert.ToDecimal(txtSaleMoney.Text) * 100) * Convert.ToInt32(txtReaderNum.Text.Trim());
            DeptBalunitHelper.ValdatePrepay(context, opMoney, "1");
            #endregion

            btnPrintPZ.Enabled = true;
            //string dealmoney = "";
            //if (hidSaleType.Value == "1")//单个出售
            //{
            //    //证件类型
            //    string paperName = string.Empty;
            //    if (selPaperType.SelectedItem.Text.Contains(":"))
            //    {
            //        paperName = selPaperType.SelectedItem.Text.Substring(selPaperType.SelectedItem.Text.IndexOf(":") + 1, selPaperType.SelectedItem.Text.Length - selPaperType.SelectedItem.Text.IndexOf(":") - 1);
            //    }
            //    else
            //    {
            //        paperName = "";
            //    }

            //    dealmoney = txtSaleMoney.Text.Trim();

            //    //出售打印凭证
            //    ASHelper.preparePingZheng(ptnPingZheng, txtReader.Text, txtCustName.Text, "读卡器出售", dealmoney,
            //            "", "", txtPaperNo.Text, "",
            //            "", dealmoney, context.s_UserID, context.s_DepartName, paperName, "0.00", "");
            //}
            //else//批量出售
            //{
            //    dealmoney = (Convert.ToDecimal(txtSaleMoney.Text.Trim()) * Convert.ToInt32(txtReaderNum.Text.Trim())).ToString();

            //    //出售打印凭证
            //    ASHelper.preparePingZheng(ptnPingZheng, txtReader.Text, txtCustName.Text, "读卡器出售", dealmoney,
            //            "", txtEndReader.Text, txtPaperNo.Text, "",
            //            "", dealmoney, context.s_UserID, context.s_DepartName, "", "0.00", "");
            //}
            //自动打印凭证
            if (chkPingzheng.Checked && btnPrintPZ.Enabled)
            {
                //打印按钮事件
                btnPrintPZ_Click(sender, e);

                //ScriptManager.RegisterStartupScript(
                //    this, this.GetType(), "writeCardScript",
                //    "printInvoice();", true);
            }

            txtReader.Text = "";
            txtCustName.Text = "";
            selCustSex.SelectedValue = "";
            txtCustBirth.Text = "";
            selPaperType.SelectedValue = "";
            txtPaperNo.Text = "";
            txtCustAddr.Text = "";
            txtCustPost.Text = "";
            txtCustPhone.Text = "";
            txtEmail.Text = "";
            txtRemark.Text = "";
            txtSaleMoney.Text = "";
            //批量出售清空
            txtEndReader.Text = "";
            txtReaderNum.Text = "";
            txtMoneySum.Text = "0 * 100 分";
        }
    }

    /// <summary>
    /// 打印
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnPrintPZ_Click(object sender, EventArgs e)
    {
        string totalmoney = (Convert.ToInt32(hidSaleMoney.Value) * Convert.ToInt32(hidReaderNum.Value)).ToString();
        string printhtml = PrintHelper.PrintReader(context, hidTradeid.Value, context.s_DepartName, context.s_UserID,
                                     hidSaleType.Value == "1" ? true : false,
                                     hidSaleType.Value == "1" ? false : true,
                                     hidSaleType.Value == "1" ? "读卡器出售" : "读卡器批量出售", hidReaderno.Value,
                                     hidEndReaderno.Value, "", hidSaleType.Value == "1" ? hidSaleMoney.Value : "", "0",
                                     "", "", hidSaleType.Value == "1" ? "" : "0",
                                     totalmoney + "元");

        printarea.InnerHtml = printhtml;
        //执行打印脚本
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Print", "printdiv('printarea');", true);
    }

    /// <summary>
    /// 输入校验
    /// </summary>
    /// <returns>没有错误时返回true，有错误时返回false</returns>
    private Boolean SaleValidation()
    {
        //读卡器序列号
        if (string.IsNullOrEmpty(txtReader.Text.Trim()))
            context.AddError("A094570210：读卡器序列号不能为空", txtReader);
        else if (Validation.strLen(txtReader.Text.Trim()) != 16)
            context.AddError("A094570211：读卡器序列号长度必须为16位", txtReader);
        else if (!Validation.isNum(txtReader.Text.Trim()))
            context.AddError("A094570212:读卡器序列号必须为数字", txtReader);

        //对用户姓名进行非空、长度检验
        if (txtCustName.Text.Trim() != "")
            //context.AddError("A001001111", txtCustName);
            if (Validation.strLen(txtCustName.Text.Trim()) > 50)
                context.AddError("A001001113", txtCustName);

        //对用户性别进行非空检验
        //if (selCustSex.SelectedValue == "")
        //    context.AddError("A001001116", selCustSex);

        //对证件类型进行非空检验
        //if (selPaperType.SelectedValue == "")
        //    context.AddError("A001001117", selPaperType);

        //对出生日期进行非空、日期格式检验
        String cDate = txtCustBirth.Text.Trim();
        if (cDate != "")
            //context.AddError("A001001114", txtCustBirth);
            if (!Validation.isDate(txtCustBirth.Text.Trim()))
                context.AddError("A001001115", txtCustBirth);

        //对联系电话进行非空、长度、数字检验
        if (txtCustPhone.Text.Trim() != "")
            //context.AddError("A001001124", txtCustPhone);
            if (Validation.strLen(txtCustPhone.Text.Trim()) > 20)
                context.AddError("A001001126", txtCustPhone);
            else if (!Validation.isNum(txtCustPhone.Text.Trim()))
                context.AddError("A001001125", txtCustPhone);

        //对证件号码进行非空、长度、英数字检验
        if (txtPaperNo.Text.Trim() != "")
            //context.AddError("A001001121", txtPaperNo);
            if (!Validation.isCharNum(txtPaperNo.Text.Trim()))
                context.AddError("A001001122", txtPaperNo);
            else if (Validation.strLen(txtPaperNo.Text.Trim()) > 20)
                context.AddError("A001001123", txtPaperNo);

        //对邮政编码进行非空、长度、数字检验
        if (txtCustPost.Text.Trim() != "")
            //context.AddError("A001001118", txtCustPost);
            if (Validation.strLen(txtCustPost.Text.Trim()) != 6)
                context.AddError("A001001120", txtCustPost);
            else if (!Validation.isNum(txtCustPost.Text.Trim()))
                context.AddError("A001001119", txtCustPost);

        //对联系地址进行非空、长度检验
        if (txtCustAddr.Text.Trim() != "")
            //context.AddError("A001001127", txtCustAddr);
            if (Validation.strLen(txtCustAddr.Text.Trim()) > 50)
                context.AddError("A001001128", txtCustAddr);

        //对备注进行长度检验
        if (txtRemark.Text.Trim() != "")
            if (Validation.strLen(txtRemark.Text.Trim()) > 50)
                context.AddError("A001001129", txtRemark);

        //对电子邮件进行格式检验
        if (txtEmail.Text.Trim() != "")
            new Validation(context).isEMail(txtEmail);

        //销售金额
        if (string.IsNullOrEmpty(txtSaleMoney.Text.Trim()))
            context.AddError("A094570213:销售金额不能为空", txtSaleMoney);
        else if (!Validation.isNum(txtSaleMoney.Text.Trim()))
            context.AddError("A094570214:销售金额必须为数字", txtSaleMoney);

        return !context.hasError();
    }
    /// <summary>
    /// 输入校验
    /// </summary>
    /// <returns>没有错误时返回true，有错误时返回false</returns>
    private Boolean BatchSaleValidation()
    {
        //起始读卡器序列号
        if (string.IsNullOrEmpty(txtReader.Text.Trim()))
            context.AddError("A094570225：起始读卡器序列号不能为空", txtReader);
        else if (Validation.strLen(txtReader.Text.Trim()) != 16)
            context.AddError("A094570226：起始读卡器序列号长度必须为16位", txtReader);
        else if (!Validation.isNum(txtReader.Text.Trim()))
            context.AddError("A094570227:起始读卡器序列号必须为数字", txtReader);

        //结束读卡器序列号
        if (string.IsNullOrEmpty(txtEndReader.Text.Trim()))
            context.AddError("A094570228：结束读卡器序列号不能为空", txtEndReader);
        else if (Validation.strLen(txtEndReader.Text.Trim()) != 16)
            context.AddError("A094570229：结束读卡器序列号长度必须为16位", txtEndReader);
        else if (!Validation.isNum(txtEndReader.Text.Trim()))
            context.AddError("A094570230:结束读卡器序列号必须为数字", txtEndReader);

        if (txtReader.Text.Trim().CompareTo(txtEndReader.Text.Trim()) > 0)
            context.AddError("A094570232:读卡器起始序列号不能大于结束序列号", txtReader);

        //销售金额
        if (string.IsNullOrEmpty(txtSaleMoney.Text.Trim()))
            context.AddError("A094570213:销售金额不能为空", txtSaleMoney);
        else if (!Validation.isNum(txtSaleMoney.Text.Trim()))
            context.AddError("A094570214:销售金额必须为数字", txtSaleMoney);

        //对备注进行长度检验
        if (txtBatchRemark.Text.Trim() != "")
            if (Validation.strLen(txtBatchRemark.Text.Trim()) > 50)
                context.AddError("A094570231：备注长度不能大于50个字符长度", txtBatchRemark);

        return !context.hasError();
    }
    /// <summary>
    /// 出售权限校验
    /// </summary>
    /// <returns>拥有出售权限时返回true，否则返回false</returns>
    private Boolean checkPower()
    {
        string sql = "";
        if (hidSaleType.Value == "1")//单个出售
        {
            sql += "SELECT ASSIGNEDDEPARTID FROM TL_R_READER WHERE SERIALNUMBER = '" + txtReader.Text.Trim() + "' AND READERSTATE IN ('1','4')";
            context.DBOpen("Select");
            DataTable data = context.ExecuteReader(sql);

            if (data.Rows.Count == 0)
                //未查询出结果时
                context.AddError("出售读卡器不是出库或回收状态！");
            else
                //比较所属员工和当前员工部门
                if (data.Rows[0][0].ToString() != context.s_DepartID)
                    context.AddError("读卡器所属部门与当前员工部门不符，不允许出售！");
        }
        else//批量出售
        {
            sql += " SELECT ASSIGNEDDEPARTID FROM TL_R_READER " +
                   " WHERE SERIALNUMBER BETWEEN '" + txtReader.Text.Trim() + "' AND '" + txtEndReader.Text.Trim() + "' " +
                   " AND READERSTATE IN ('1','4') GROUP BY ASSIGNEDDEPARTID";
            context.DBOpen("Select");
            DataTable data = context.ExecuteReader(sql);

            if (data.Rows.Count < 1)
                //未查询出结果时
                context.AddError("出售读卡器不是出库或回收状态");
            else if (data.Rows.Count > 1)
                //返回多个部门
                context.AddError("出售的读卡器属于不同的部门！");
            else
                //比较所属员工和当前员工部门
                if (data.Rows[0][0].ToString() != context.s_DepartID)
                    context.AddError("读卡器所属部门与当前员工部门不符，不允许出售！");
        }
        return !context.hasError();
    }
}