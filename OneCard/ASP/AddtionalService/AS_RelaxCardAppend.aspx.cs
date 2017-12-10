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
using TM;
using PDO.AdditionalService;
using Common;

// 休闲年卡查询/补换卡


public partial class ASP_AddtionalService_AS_RelaxCardAppend : Master.FrontMaster
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        // 初始化查询结果


        UserCardHelper.resetData(gvResult, null);

        // if (!context.s_Debugging) txtCardNo.Attributes["readonly"] = "true";

        setReadOnly(labGardenEndDate, labUsableTimes);
    }

    // gridview换页处理
    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }

    // gridview行数据绑定处理


    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        // 针对数据行，更改日期和时间的显示方式分别为yyyy-mm-dd与hh:mi:ss
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Cells[2].Text = ASHelper.toDateWithHyphen(e.Row.Cells[2].Text);
            e.Row.Cells[3].Text = ASHelper.toTimeWithHyphen(e.Row.Cells[3].Text);
        }
    }

    // 查询前输入校验


    private void QueryValidate()
    {
        // 校验交易起始日期和结束日期


        UserCardHelper.validateDateRange(context, txtFromDate, txtToDate, false);
    }

    // 查询处理
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        QueryValidate();
        if (context.hasError()) return;

        // 从交易数据表中查询


        DataTable data = ASHelper.callQuery(context,
            selType.SelectedValue == "0" ? "XXParkTradesRight" : "XXParkTradesError", txtCardNo.Text,
            txtFromDate.Text, txtToDate.Text);

        UserCardHelper.resetData(gvResult, data);
        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }
    }

    protected void btnReadDb_Click(object sender, EventArgs e)
    {
        Session["PicData"] = null;
        preview_size_fake.Src = "";

        // 读取库内休闲卡相关信息(到期日期，可用次数，开卡次数）
        ASHelper.readRelaxInfo(context, txtCardNo,
            labDbExpDate, labDbUsableTimes, labDbOpenTimes, labUpdateStaff, labUpdateTime, labAccountType);

        //套餐名称
        ASHelper.readPackage(context, txtCardNo.Text, labPackage, hidFuncType);

        // 读取客户信息
        readCustInfo(txtCardNo.Text,
            txtCustName, txtCustBirth,
            selPaperType, txtPaperNo,
            selCustSex, txtCustPhone,
            txtCustPost, txtCustAddr, txtEmail, txtRemark);

        //读取照片信息
        ReadCardPic(txtCardNo.Text);

        //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
        if (!CommonHelper.HasOperPower(context))
        {
            txtPaperNo.Text = CommonHelper.GetPaperNo(txtPaperNo.Text);
            txtCustPhone.Text = CommonHelper.GetCustPhone(txtCustPhone.Text);
            txtCustAddr.Text = CommonHelper.GetCustAddress(txtCustAddr.Text);
        }

        labGardenEndDate.Text = "";
        labUsableTimes.Text = "";
    }

    // 读卡处理
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        Session["PicData"] = null;
        preview_size_fake.Src = "";

        // 读取库内休闲卡相关信息(到期日期，可用次数，开卡次数）
        ASHelper.readRelaxInfo(context, txtCardNo,
            labDbExpDate, labDbUsableTimes, labDbOpenTimes, labUpdateStaff, labUpdateTime, labAccountType);

        //套餐名称
        ASHelper.readPackage(context, txtCardNo.Text, labPackage, hidFuncType);

        // 读取客户信息
        readCustInfo(txtCardNo.Text,
            txtCustName, txtCustBirth,
            selPaperType, txtPaperNo,
            selCustSex, txtCustPhone,
            txtCustPost, txtCustAddr, txtEmail, txtRemark);

        //读取照片信息
        ReadCardPic(txtCardNo.Text);

        //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
        if (!CommonHelper.HasOperPower(context))
        {
            txtPaperNo.Text = CommonHelper.GetPaperNo(txtPaperNo.Text);
            txtCustPhone.Text = CommonHelper.GetCustPhone(txtCustPhone.Text);
            txtCustAddr.Text = CommonHelper.GetCustAddress(txtCustAddr.Text);
        }

        labGardenEndDate.Text = hidParkInfo.Value.Substring(0, 8);
        string times = hidParkInfo.Value.Substring(10, 2);
        labUsableTimes.Text = times == "FF" ? "FF" : "" + Convert.ToInt32(times, 16);

        btnSubmit.Enabled = !context.hasError();

        btnSubmit.Visible = true;


    }

    // 确认对话框确认处理


    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "writeSuccess") // 写卡成功
        {
            AddMessage("D005070002: 惠民休闲年卡前台写卡成功，补写卡成功");
        }
        else if (hidWarning.Value == "writeFail") // 写卡失败
        {
            context.AddError("A00507C001: 惠民休闲年卡前台写卡失败，补写卡失败");
        }

        hidWarning.Value = ""; // 清除警告信息

        if (chkPingzheng.Checked && btnPrintPZ.Enabled)
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "printInvoice();", true);
        }
    }

    // 补写卡提交处理

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        int usableTimes = int.Parse(labDbUsableTimes.Text);

        hidParkInfo.Value = labDbExpDate.Text + hidFuncType.Value + usableTimes.ToString("X2");

        if (hidParkInfo.Value.Trim().Length != 12)
        {
            context.AddError("写卡数据有误");
            return;
        }

        // 调用休闲年卡查询/补换卡存储过程

        SP_AS_RelaxCardAppendPDO pdo = new SP_AS_RelaxCardAppendPDO();

        pdo.cardNo = txtCardNo.Text;
        pdo.asn = hidAsn.Value.Substring(4, 16);
        pdo.operCardNo = context.s_CardID; // 操作员卡
        pdo.terminalNo = "112233445566";   // 目前固定写成112233445566

        // 12位,年月日8位+标志位2位+次数2位


        // 园林年卡的标志位为'01',休闲年卡的标志位为'02'.次数都是16进制.
        // string endDate = ASHelper.toDateWithoutHyphen(labDbExpDate.Text);
        pdo.endDateNum = labDbExpDate.Text + hidFuncType.Value + usableTimes.ToString("X2");
        pdo.packageTypeCode = hidFuncType.Value;
        hidParkInfo.Value = pdo.endDateNum;

        // 执行存储过程
        bool ok = TMStorePModule.Excute(context, pdo);
        btnSubmit.Enabled = false;

        // 执行成功，显示成功消息


        if (ok)
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "startXXPark();", true);
            btnPrintPZ.Enabled = true;

            //ASHelper.preparePingZheng(ptnPingZheng, txtCardNo.Text, txtCustName.Text, "休闲年卡补写卡", "0.00"
            //    , "0.00", "", txtPaperNo.Text, "0.00", "0.00", hidAccRecv.Value, context.s_UserID,
            //    context.s_DepartName,
            //    selPaperType.Text, "0.00", hidAccRecv.Value);
            ASHelper.preparePingZheng(ptnPingZheng, context.s_DepartName, context.s_UserID,
                "惠民休闲年卡补写卡", "",
                "0.00", "0.00", pdo.cardNo, labDbExpDate.Text);
        }

        Session["PicData"] = null;
        preview_size_fake.Src = "";
        ReadCardPic(txtCardNo.Text);
    }


    //读取照片
    private void ReadCardPic(string cardNo)
    {
        byte[] imageData = ReadImage(cardNo);

        if (imageData != null)
        {
            Session["PicData"] = imageData;
            preview_size_fake.Src = "../../picture.aspx?id=" + DateTime.Now.ToString();

        }
        else
        {
            Session["PicData"] = null;
            preview_size_fake.Src = "../../Images/nom.jpg";
        }
    }
    /// <summary>
    /// 读取照片字节流
    /// </summary>
    /// <param name="cardNo">卡号</param>
    /// <returns>字节流</returns>
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

}
