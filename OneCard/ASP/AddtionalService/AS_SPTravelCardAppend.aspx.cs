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
using Master;
using PDO.AdditionalService;
using Common;

/**********************************
 * 世乒旅游卡查询/补写卡
 * 2015-3-30
 * gl
 * 初次编写
 * ********************************/
public partial class ASP_AddtionalService_AS_SPTravelCardAppend : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;
        // 初始化查询结果
        UserCardHelper.resetData(gvResult, null);
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
            e.Row.Cells[3].Text = ASHelper.toDateWithHyphen(e.Row.Cells[3].Text);
            e.Row.Cells[4].Text = ASHelper.toTimeWithHyphen(e.Row.Cells[4].Text);
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
            selType.SelectedValue == "0" ? "SPTravelTradesRight" : "SPTravelTradesError", txtCardno.Text,
            txtFromDate.Text, txtToDate.Text);

        UserCardHelper.resetData(gvResult, data);
        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }
    }

    protected void btnReadDb_Click(object sender, EventArgs e)
    {
        // 读取客户信息
        readCustInfo(txtCardno.Text,
            txtCustName, txtCustBirth,
            selPaperType, txtPaperNo,
            selCustSex, txtCustPhone,
            txtCustPost, txtCustAddr, txtEmail, txtRemark);

        //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
        if (!CommonHelper.HasOperPower(context))
        {
            txtPaperNo.Text = CommonHelper.GetPaperNo(txtPaperNo.Text);
            txtCustPhone.Text = CommonHelper.GetCustPhone(txtCustPhone.Text);
            txtCustAddr.Text = CommonHelper.GetCustAddress(txtCustAddr.Text);
        }

       
        //读旧卡景点标志
        //从最近的一条记录中读,没有写默认值
        DataTable data = ASHelper.callQuery(context, "SPTravelTradesRight", txtCardno.Text);
        if (data.Rows.Count > 0)
        {
            hiddenShiPingTag.Value = data.Rows[0]["TRAVELSIGN"].ToString();
        }
        else
        {
            hiddenShiPingTag.Value = "";//默认值
        }

        //从套餐表里面读线路
        DataTable dt = ASHelper.callQuery(context, "QUERYSPTRAVELCARDINFOS", txtCardno.Text);
        if (dt.Rows.Count == 0)
        {
            context.AddError("当前卡未开通世乒旅游卡");
            ScriptManager1.SetFocus(btnReadCard);
            return;
        }
        if (dt.Rows[0]["PACKAGETYPECODE"].ToString() == "01")
        {
            labDbOpenLines.Text = "东线A";
            if (hiddenShiPingTag.Value == "")
            {
                hiddenShiPingTag.Value = "15053101010101FFFFFF";
            }
        }
        else if (dt.Rows[0]["PACKAGETYPECODE"].ToString() == "02")
        {
            labDbOpenLines.Text = "西线B";
            if (hiddenShiPingTag.Value == "")
            {
                hiddenShiPingTag.Value = "150531FFFFFFFF010101";
            }
        }
        else if (dt.Rows[0]["PACKAGETYPECODE"].ToString() == "03")
        {
            labDbOpenLines.Text = "东线A和西线B";
            if (hiddenShiPingTag.Value == "")
            {
                hiddenShiPingTag.Value = "15053101010101010101";
            }
        }

        labCardSign.Text = hiddenShiPingTag.Value; //卡内标志
        labEndDate.Text = dt.Rows[0]["ENDDATE"].ToString().Substring(0, 4) + "-" + dt.Rows[0]["ENDDATE"].ToString().Substring(4, 2) + "-" + dt.Rows[0]["ENDDATE"].ToString().Substring(6, 2);
        labUpdateStaff.Text = dt.Rows[0]["staffname"].ToString();
        labUpdateTime.Text = Convert.ToDateTime(dt.Rows[0]["UPDATETIME"]).ToString("yyyy-MM-dd");
    }    

    // 读卡处理
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        // 读取客户信息
        readCustInfo(txtCardno.Text,
            txtCustName, txtCustBirth,
            selPaperType, txtPaperNo,
            selCustSex, txtCustPhone,
            txtCustPost, txtCustAddr, txtEmail, txtRemark);

        //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
        if (!CommonHelper.HasOperPower(context))
        {
            txtPaperNo.Text = CommonHelper.GetPaperNo(txtPaperNo.Text);
            txtCustPhone.Text = CommonHelper.GetCustPhone(txtCustPhone.Text);
            txtCustAddr.Text = CommonHelper.GetCustAddress(txtCustAddr.Text);
        }
        DataTable dt = ASHelper.callQuery(context, "QUERYSPTRAVELCARDINFOS", txtCardno.Text);
        if (dt.Rows.Count == 0)
        {
            context.AddError("当前卡不是世乒旅游卡");
            ScriptManager1.SetFocus(btnReadCard);
            return;
        }
        if (dt.Rows[0]["PACKAGETYPECODE"].ToString() == "01")
        {
            labDbOpenLines.Text = "东线A";
        }
        else if (dt.Rows[0]["PACKAGETYPECODE"].ToString() == "02")
        {
            labDbOpenLines.Text = "西线B";
        }
        else if (dt.Rows[0]["PACKAGETYPECODE"].ToString() == "03")
        {
            labDbOpenLines.Text = "东线A和西线B";
        }
        labCardSign.Text = hiddenShiPingTag.Value; //卡内标志
        labEndDate.Text = dt.Rows[0]["ENDDATE"].ToString().Substring(0, 4) + "-" + dt.Rows[0]["ENDDATE"].ToString().Substring(4, 2) + "-" + dt.Rows[0]["ENDDATE"].ToString().Substring(6, 2);
        labUpdateStaff.Text = dt.Rows[0]["staffname"].ToString();
        labUpdateTime.Text = Convert.ToDateTime(dt.Rows[0]["UPDATETIME"]).ToString("yyyy-MM-dd");
    }
}