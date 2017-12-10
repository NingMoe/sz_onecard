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
using System.Collections.Generic;
/***************************************************************
 * 功能名: 读卡器出售返销
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2013/01/28    shil			初次开发
 ****************************************************************/

public partial class ASP_PersonalBusiness_PB_SaleReaderRollBack : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //绑定JS事件
            txtReader.Attributes["OnBlur"] = "javascript:return Change();";
            txtEndReader.Attributes["OnBlur"] = "javascript:return Change();";

            //默认是单个出售
            hidSaleType.Value = "1";
            //设置为只读
            setReadOnly(txtReaderNum, txtSaleMoney, txtMoneySum);
        }

        //固化单选框
        ScriptManager.RegisterStartupScript(this, this.GetType(), "radioTagScript", "SelectRadioTag();", true);
    }

    /// <summary>
    /// 读卡器序列号事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Reader_OnTextChanged(object sender, EventArgs e)
    {
        query();
    }
    /// <summary>
    /// 查询按钮点击事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (hidSaleType.Value == "1")//单个出售
            //输入校验
            if (!SaleValidation()) return;

        if (hidSaleType.Value == "0")//批量出售
            //输入校验
            if (!BatchSaleValidation()) return;

        query();
    }
    /// <summary>
    /// 查询
    /// </summary>
    protected void query()
    {
        if (!(Validation.strLen(txtReader.Text.Trim()) == 16 && Validation.isNum(txtReader.Text.Trim())))
            return;

        if (hidSaleType.Value == "1")//单个出售返销
        {
            //查询个人信息
            queryReaderCustInfo(txtReader.Text.Trim());

            //查询出售记录
            string sql = " SELECT A.TRADEID,A.MONEY FROM TF_B_READER A" +
                         " WHERE A.BEGINSERIALNUMBER = A.ENDSERIALNUMBER " +
                         " AND A.BEGINSERIALNUMBER = '" + txtReader.Text.Trim() + "' and A.CANCELTAG = '0' and A.OPERATETYPECODE = '1A'" +
                         " AND TO_CHAR(A.OPERATETIME,'YYYYMMDD') = '" + System.DateTime.Today.ToString("yyyyMMdd") + "'" +
                         " AND A.OPERATESTAFFNO = '" + context.s_UserID + "'";
            context.DBOpen("Select");
            DataTable data = context.ExecuteReader(sql);
            if (data.Rows.Count != 0)
            {
                txtSaleMoney.Text = (Convert.ToDecimal(data.Rows[0]["MONEY"].ToString()) / 100).ToString("n");

                //返销提交按钮可用
                btnSubmit.Enabled = true;
            }
            else
            {
                context.AddError("未找到当前操作员当天售出记录！");
                return;
            }
        }
        else//批量出售返销
        {
            if (!(Validation.strLen(txtEndReader.Text.Trim()) == 16 && Validation.isNum(txtEndReader.Text.Trim())))
                return;

            //查询出售记录
            string sql = " SELECT A.TRADEID,A.MONEY FROM TF_B_READER A" +
                         " WHERE A.BEGINSERIALNUMBER = '" + txtReader.Text.Trim() + "'" +
                         " AND A.ENDSERIALNUMBER = '" + txtEndReader.Text.Trim() + "'" +
                         " AND A.CANCELTAG = '0' and A.OPERATETYPECODE = '1A'" +
                         " AND TO_CHAR(A.OPERATETIME,'YYYYMMDD') = '" + System.DateTime.Today.ToString("yyyyMMdd") + "'" +
                         " AND A.OPERATESTAFFNO = '" + context.s_UserID + "'";
            context.DBOpen("Select");
            DataTable data = context.ExecuteReader(sql);
            if (data.Rows.Count != 0)
            {
                txtSaleMoney.Text = (Convert.ToDecimal(data.Rows[0]["MONEY"].ToString()) / (100 * Convert.ToInt32(txtReaderNum.Text))).ToString("n");
                //返销提交按钮可用
                btnSubmit.Enabled = true;
            }
            else
            {
                context.AddError("未找到当前操作员当天售出记录！");
                return;
            }

            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Change", "Change();", true);
        }
    }
    /// <summary>
    /// 查询读卡器客户资料
    /// </summary>
    /// <param name="readerno">读卡器序列号</param>
    protected void queryReaderCustInfo(string readerno)
    {
        string sql = " SELECT CUSTNAME,CUSTSEX,CUSTBIRTH,PAPERTYPECODE,PAPERNO,CUSTADDR,CUSTPOST,CUSTPHONE,CUSTEMAIL,REMARK " +
                         " FROM TF_F_READERCUSTREC WHERE USETAG = '1' AND SERIALNUMBER = '" + readerno + "'";
        context.DBOpen("Select");
        DataTable data = context.ExecuteReader(sql);
        if (data.Rows.Count != 0)
        {
            //解密
            CommonHelper.AESDeEncrypt(data, new List<string>(new string[] { "CUSTNAME", "CUSTPHONE", "CUSTADDR", "PAPERNO" }));

            CustName.Text = data.Rows[0]["CUSTNAME"].ToString();
            CustBirthday.Text = data.Rows[0]["CUSTBIRTH"].ToString();
            string papertype = "";
            switch (data.Rows[0]["PAPERTYPECODE"].ToString())
            {
                case "00": 
                    papertype = "身份证";
                    break;
                case "01":
                    papertype = "学生证";
                    break;
                case "02":
                    papertype = "军官证";
                    break;
                case "03":
                    papertype = "驾驶证";
                    break;
                case "04":
                    papertype = "教师证";
                    break;
                case "05":
                    papertype = "护照";
                    break;
                case "06":
                    papertype = "港澳台通行证";
                    break;
                case "99":
                    papertype = "其他";
                    break;
                default:
                    papertype = "";
                    break;
            }
                    
            Papertype.Text = papertype;
            Paperno.Text = data.Rows[0]["PAPERNO"].ToString();
            string sex = data.Rows[0]["CUSTSEX"].ToString();
            Custsex.Text = (sex == "0" ? "男" : sex == "1" ? "女" : "");
            Custphone.Text = data.Rows[0]["CUSTPHONE"].ToString();
            Custpost.Text = data.Rows[0]["CUSTPOST"].ToString();
            Custaddr.Text = data.Rows[0]["CUSTADDR"].ToString();
            Remark.Text = data.Rows[0]["REMARK"].ToString();
            txtEmail.Text = data.Rows[0]["CUSTEMAIL"].ToString();

            //客户信息隐藏显示 201015：客户信息查看权
            if (!CommonHelper.HasOperPower(context))
            {
                Paperno.Text = CommonHelper.GetPaperNo(Paperno.Text);
                Custphone.Text = CommonHelper.GetCustPhone(Custphone.Text);
                Custaddr.Text = CommonHelper.GetCustAddress(Custaddr.Text);
            }
        }
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

        //对备注进行长度检验
        if (txtBatchRemark.Text.Trim() != "")
            if (Validation.strLen(txtBatchRemark.Text.Trim()) > 50)
                context.AddError("A001001129", txtBatchRemark);

        return !context.hasError();
    }
    /// <summary>
    /// 提交按钮点击事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        if (hidSaleType.Value == "1")//单个出售返销
            //输入校验
            if (!SaleValidation()) return;

        if (hidSaleType.Value == "0")//批量出售返销
            //输入校验
            if (!BatchSaleValidation()) return;

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
        context.SPOpen();
        if (hidSaleType.Value == "1")//单个出售返销
        {
            context.AddField("p_FUNCCODE").Value = "SINGLESALEROLLBACK";
            context.AddField("P_SERIALNUMBER").Value = txtReader.Text.Trim();
            context.AddField("P_ENDSERIALNUMBER").Value = txtReader.Text.Trim();
            context.AddField("P_READERNUMBER").Value = 1;
            context.AddField("P_REMARK").Value = "";
            context.AddField("p_MONEY").Value = Convert.ToInt32(Convert.ToDecimal(txtSaleMoney.Text.Trim()) * 100);
            context.AddField("p_TRADEID", "String", "output", "16", null);
        }
        else//批量出售返销
        {
            context.AddField("p_FUNCCODE").Value = "BATCHSALEROLLBACK";
            context.AddField("P_SERIALNUMBER").Value = txtReader.Text.Trim();
            context.AddField("P_ENDSERIALNUMBER").Value = txtEndReader.Text.Trim();
            context.AddField("P_READERNUMBER").Value = txtReaderNum.Text.Trim();
            context.AddField("P_REMARK").Value = txtBatchRemark.Text.Trim();
            context.AddField("p_MONEY").Value = Convert.ToInt32(Convert.ToDecimal(txtSaleMoney.Text.Trim()) * 100);
            context.AddField("p_TRADEID", "String", "output", "16", null);
        }

        bool ok = context.ExecuteSP("SP_PB_SAREADERROLLBACK_COMMIT");
        if (ok)
        {
            string dealmoney = "";
            if (hidSaleType.Value == "1")//单个出售
            {
                dealmoney = txtSaleMoney.Text.Trim();
            }
            else
            {
                dealmoney = (Convert.ToDecimal(txtSaleMoney.Text.Trim()) * Convert.ToInt32(txtReaderNum.Text.Trim())).ToString();
            }
            AddMessage("出售返销成功！退还" + dealmoney + "元。");

            //获取流水号
            hidTradeid.Value = context.GetFieldValue("p_TRADEID").ToString();
            //读卡器序列号赋值
            hidReaderno.Value = txtReader.Text.Trim();
            hidEndReaderno.Value = hidSaleType.Value == "1" ? "" : txtEndReader.Text.Trim();

            hidReaderNum.Value = hidSaleType.Value == "1" ? "1" : txtReaderNum.Text.Trim();
            //金额赋值
            hidSaleMoney.Value = txtSaleMoney.Text.Trim();

            btnPrintPZ.Enabled = true;

            //if (hidSaleType.Value == "1")//单个出售返销
            //{
            //    //准备打印凭证
            //    ASHelper.preparePingZheng(ptnPingZheng, txtReader.Text, CustName.Text, "读卡器出售返销", "-" + dealmoney,
            //            "", "", Paperno.Text, "",
            //            "", "-" + dealmoney, context.s_UserID, context.s_DepartName, Papertype.Text, "0.00", "");
            //}
            //else
            //{
            //    //准备打印凭证
            //    ASHelper.preparePingZheng(ptnPingZheng, txtReader.Text, CustName.Text, "读卡器出售返销", "-" + dealmoney,
            //            "", txtEndReader.Text, Paperno.Text, "",
            //            "", "-" + dealmoney, context.s_UserID, context.s_DepartName, Papertype.Text, "0.00", "");
            //}
            if (chkPingzheng.Checked && btnPrintPZ.Enabled)
            {
                //打印按钮事件
                btnPrintPZ_Click(sender, e);

                //ScriptManager.RegisterStartupScript(
                //    this, this.GetType(), "writeCardScript",
                //    "printInvoice();", true);
            }
            txtReader.Text = "";
            CustName.Text = "";
            CustBirthday.Text = "";
            Papertype.Text = "";
            Paperno.Text = "";
            Custsex.Text = "";
            Custphone.Text = "";
            Custpost.Text = "";
            Custaddr.Text = "";
            txtEmail.Text = "";
            Remark.Text = "";
            txtSaleMoney.Text = "";
            //批量出售清空
            txtEndReader.Text = "";
            txtReaderNum.Text = "";
            txtMoneySum.Text = "0 * 100 分";

            btnSubmit.Enabled = false;
        }
    }

    /// <summary>
    /// 打印
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnPrintPZ_Click(object sender, EventArgs e)
    {
        string totalmoney = (Convert.ToDecimal(hidSaleMoney.Value) * Convert.ToInt32(hidReaderNum.Value)).ToString();
        string printhtml = PrintHelper.PrintReader(context, hidTradeid.Value, context.s_DepartName, context.s_UserID,
                                     hidSaleType.Value == "1" ? true : false,
                                     hidSaleType.Value == "1" ? false : true,
                                     hidSaleType.Value == "1" ? "读卡器出售返销" : "读卡器批量出售返销", hidReaderno.Value,
                                     hidEndReaderno.Value,
                                     "", hidSaleType.Value == "1" ? "-" + hidSaleMoney.Value : "", "0",
                                     "", "", hidSaleType.Value == "1" ? "" : "0",
                                     "-" + totalmoney + "元");

        printarea.InnerHtml = printhtml;
        //执行打印脚本
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Print", "printdiv('printarea');", true);
    }
}