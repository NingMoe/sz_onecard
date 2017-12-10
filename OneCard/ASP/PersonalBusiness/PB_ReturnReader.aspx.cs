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
 * 功能名: 读卡器退货
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2013/04/05    shil			初次开发
 ****************************************************************/

public partial class ASP_PersonalBusiness_PB_ReturnReader : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack)
        {
            return;
        }

        //设置为只读
        setReadOnly(txtSaleMoney);
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
        //查询校验
        if (!SaleValidation()) return;

        query();
    }
    /// <summary>
    /// 查询
    /// </summary>
    protected void query()
    {
        if (!(Validation.strLen(txtReader.Text.Trim()) == 16 && Validation.isNum(txtReader.Text.Trim())))
            return;


        //查询个人信息
        queryReaderCustInfo(txtReader.Text.Trim());

        //查询出售记录
        string sql = "  SELECT MONEY/READERNUMBER MONEY FROM " +
                        "(SELECT A.MONEY,A.READERNUMBER FROM TF_B_READER A" +
                        " WHERE A.CANCELTAG = '0' and A.OPERATETYPECODE = '1A' " +
                        " AND ('" + txtReader.Text.Trim() + "' BETWEEN A.BEGINSERIALNUMBER AND A.ENDSERIALNUMBER) " +
                        " ORDER BY OPERATETIME DESC)" +
                        " WHERE ROWNUM = 1";
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
            context.AddError("未找到该读卡器！");
            return;
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
    /// 提交按钮点击事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        //输入校验
        if (!SaleValidation()) return;

        //确认读卡器序列号
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Check", "singleSubmitConfirm();", true);
    }
    /// <summary>
    /// 提交存处理
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        context.SPOpen();

        context.AddField("P_SERIALNUMBER").Value = txtReader.Text.Trim();
        context.AddField("P_READERNUMBER").Value = 1;
        context.AddField("p_MONEY").Value = Convert.ToInt32(Convert.ToDecimal(txtSaleMoney.Text.Trim()) * 100);
        context.AddField("p_TRADEID", "String", "output", "16", null);

        bool ok = context.ExecuteSP("SP_PB_RETURNREADER");
        if (ok)
        {
            AddMessage("退货" + txtReader.Text.Trim() + "成功！退还" + txtSaleMoney.Text.Trim() + "元。");

            btnPrintPZ.Enabled = true;

            //准备打印凭证
            //获取流水号
            hidTradeid.Value = context.GetFieldValue("p_TRADEID").ToString();
            //读卡器序列号赋值
            hidReaderno.Value = txtReader.Text.Trim();
            //金额赋值
            hidSaleMoney.Value = "-" + txtSaleMoney.Text.Trim();

            if (chkPingzheng.Checked && btnPrintPZ.Enabled)
            {
                //打印按钮事件
                btnPrintPZ_Click(sender, e);
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
        string printhtml = PrintHelper.PrintReader(context, hidTradeid.Value, context.s_DepartName, context.s_UserID, false, false, "读卡器退货",
                                                   hidReaderno.Value, "", "", hidSaleMoney.Value, "0", "", "", "","");

        printarea.InnerHtml = printhtml;
        //执行打印脚本
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Print", "printdiv('printarea');", true);
    }
}