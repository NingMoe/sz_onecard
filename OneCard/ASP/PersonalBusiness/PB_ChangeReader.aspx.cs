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
using System.Collections.Generic;
/***************************************************************
 * 功能名: 读卡器更换
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2012/08/22    shil			初次开发
 ****************************************************************/
public partial class ASP_PersonalBusiness_PB_ChangeReader : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //默认为收费更换
            hidChangeType.Value = "1";

            #region 添加对代理营业厅预付款的验证
            if (DeptBalunitHelper.ValdatePrepay(context) == false)
            {
                return;
            }
            #endregion
        }
    }
    /// <summary>
    /// 获取旧读卡器信息
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void OldReader_OnTextChanged(object sender, EventArgs e)
    {
        if (Validation.strLen(txtOldReaderNo.Text.Trim()) == 16 && Validation.isNum(txtOldReaderNo.Text.Trim()))
        {
            string sql = "SELECT SALETIME,READERSTATE FROM TL_R_READER WHERE SERIALNUMBER = '" + txtOldReaderNo.Text.Trim() + "'";
            context.DBOpen("Select");
            DataTable data = context.ExecuteReader(sql);
            if (data.Rows.Count != 0)
            {
                labSellTime.Text = data.Rows[0]["SALETIME"].ToString();
                switch (data.Rows[0]["READERSTATE"].ToString())
                {
                    case "0":
                        labOState.Text = "入库";
                        break;
                    case "1":
                        labOState.Text = "入库";
                        break;
                    case "2":
                        labOState.Text = "售出";
                        break;
                    case "3":
                        labOState.Text = "更换回收";
                        break;
                    default:
                        labOState.Text = "";
                        break;
                }
            }
        }
        //查询用户信息
        queryReaderCustInfo(txtOldReaderNo.Text.Trim());
    }
    /// <summary>
    /// 获取读卡器单价
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Reader_OnTextChanged(object sender, EventArgs e)
    {
        if (hidChangeType.Value == "1")//收费更换
        {
            if (Validation.strLen(txtReaderNo.Text.Trim()) == 16 && Validation.isNum(txtReaderNo.Text.Trim()))
            {
                string sql = "SELECT MONEY/100.0 FROM TL_R_READER WHERE SERIALNUMBER = '" + txtReaderNo.Text.Trim() + "'";
                context.DBOpen("Select");
                DataTable data = context.ExecuteReader(sql);
                if (data.Rows.Count != 0)
                {
                    txtSaleMoney.Text = data.Rows[0][0].ToString();
                }
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
        //输入校验
        if (!SubmitValidation()) return;

        //校验出售权限
        if (!checkPower()) return;

        #region 添加对代理营业厅预付款的验证,提交前如果扣费后不足最低额度则返回
        int opMoney = Convert.ToInt32(Convert.ToDecimal(txtSaleMoney.Text) * 100);
        if (DeptBalunitHelper.ValdatePrepay(context, opMoney, "2") == false)
            return;
        #endregion

        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Check", "submitConfirm();", true);
    }
    /// <summary>
    /// 提交存处理
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        context.SPOpen();
        context.AddField("P_OLDSERIALNUMBER").Value = txtOldReaderNo.Text.Trim();
        context.AddField("P_SERIALNUMBER").Value = txtReaderNo.Text.Trim();
        context.AddField("p_MONEY").Value = (Convert.ToInt32(txtSaleMoney.Text.Trim()) * 100).ToString();
        context.AddField("p_REMARK").Value = txtRemark.Text.Trim();
        context.AddField("p_TRADEID", "String", "output", "16", null);

        bool ok = context.ExecuteSP("SP_PB_CHANGEREADER");
        if (ok)
        {
            AddMessage("更换成功！");
            //准备打印凭证
            //获取流水号
            hidTradeid.Value = context.GetFieldValue("p_TRADEID").ToString();
            //读卡器序列号赋值
            hidOldReaderno.Value = txtOldReaderNo.Text.Trim();
            hidNewReaderno.Value = txtReaderNo.Text.Trim();
            //金额赋值
            hidSaleMoney.Value = txtSaleMoney.Text.Trim();
            //ASHelper.preparePingZheng(ptnPingZheng, txtOldReaderNo.Text, "", "读卡器更换", txtSaleMoney.Text,
            //        "", txtReaderNo.Text, "", "",
            //        "", txtSaleMoney.Text, context.s_UserID, context.s_DepartName, "", "0.00", "");


            #region 添加对代理营业厅预付款的验证,扣费后如果超过预警额度则提示
            int opMoney = Convert.ToInt32(Convert.ToDecimal(txtSaleMoney.Text) * 100);
            DeptBalunitHelper.ValdatePrepay(context, opMoney, "1");
            #endregion

            //按钮有效
            btnPrintPZ.Enabled = true;

            if (chkPingzheng.Checked && btnPrintPZ.Enabled)
            {
                //打印按钮事件
                btnPrintPZ_Click(sender, e);

                //ScriptManager.RegisterStartupScript(
                //    this, this.GetType(), "writeCardScript",
                //    "printInvoice();", true);
            }

            txtOldReaderNo.Text = "";
            txtReaderNo.Text = "";
            txtSaleMoney.Text = "";
            txtRemark.Text = "";

        }
    }

    /// <summary>
    /// 打印
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnPrintPZ_Click(object sender, EventArgs e)
    {
        string printhtml = PrintHelper.PrintReader(context, hidTradeid.Value, context.s_DepartName, context.s_UserID, true, false,
                                     "读卡器更换", hidOldReaderno.Value, hidNewReaderno.Value,
                                     "", "0", "0","", hidSaleMoney.Value, "0", "");

        printarea.InnerHtml = printhtml;
        //执行打印脚本
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Print", "printdiv('printarea');", true);
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
            //证件类型
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
    private Boolean SubmitValidation()
    {
        //旧读卡器序列号
        if (string.IsNullOrEmpty(txtOldReaderNo.Text.Trim()))
            context.AddError("A094570215：旧读卡器序列号不能为空", txtOldReaderNo);
        else if (Validation.strLen(txtOldReaderNo.Text.Trim()) != 16)
            context.AddError("A094570216：旧读卡器序列号长度必须为16位", txtOldReaderNo);
        else if (!Validation.isNum(txtOldReaderNo.Text.Trim()))
            context.AddError("A094570217：旧读卡器序列号必须为数字", txtOldReaderNo);

        //新读卡器序列号
        if (string.IsNullOrEmpty(txtReaderNo.Text.Trim()))
            context.AddError("A094570218：新读卡器序列号不能为空", txtReaderNo);
        else if (Validation.strLen(txtReaderNo.Text.Trim()) != 16)
            context.AddError("A094570219：新读卡器序列号长度必须为16位", txtReaderNo);
        else if (!Validation.isNum(txtReaderNo.Text.Trim()))
            context.AddError("A094570220：新读卡器序列号必须为数字", txtReaderNo);

        if (hidChangeType.Value == "1")//收费更换
        {
            if (txtSaleMoney.Text.Trim() == "0" || string.IsNullOrEmpty(txtSaleMoney.Text.Trim()))
                context.AddError("A094570221:收费更换的更换金额不能为空和零", txtSaleMoney);
            else if (!Validation.isNum(txtSaleMoney.Text.Trim()))
                context.AddError("A094570222:更换金额必须为数字", txtSaleMoney);
        }
        else
            if (txtSaleMoney.Text.Trim() != "0")
                context.AddError("A094570223:免费更换的更换金额必须为零", txtSaleMoney);

        //对备注进行长度检验
        if (txtRemark.Text.Trim() != "")
            if (Validation.strLen(txtRemark.Text.Trim()) > 50)
                context.AddError("A094570224:备注长度不能超过50位", txtRemark);

        return !context.hasError();
    }
    /// <summary>
    /// 出售权限校验
    /// </summary>
    /// <returns>拥有读卡器出售权限时返回true，否则返回false</returns>
    private Boolean checkPower()
    {
        string sql = "";
        sql += "SELECT ASSIGNEDDEPARTID FROM TL_R_READER WHERE SERIALNUMBER = '" + txtReaderNo.Text.Trim() + "' AND READERSTATE IN ('1','4')";
        context.DBOpen("Select");
        DataTable data = context.ExecuteReader(sql);

        if (data.Rows.Count == 0)
            //未查询出结果时
            context.AddError("更换的读卡器不是出库或回收状态！");
        else
            //比较所属员工和当前员工部门
            if (data.Rows[0][0].ToString() != context.s_DepartID)
                context.AddError("新读卡器所属部门与当前员工部门不符，不允许更换！");

        return !context.hasError();
    }
}