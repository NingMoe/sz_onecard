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
 * 功能名: 读卡器查询
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2013/01/28    shil            初次开发
 ****************************************************************/

public partial class ASP_PersonalBusiness_PB_QueryReader : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        //绑定卡号段GridView关键字名称
        gvResult.DataKeyNames =
            new string[] { "SERIALNUMBER", "SALETIME", "DEPARTNAME", "STAFFNAME", "READERSTATE", "CUSTNAME", "CUSTSEX", 
                "CUSTBIRTH", "PAPERTYPECODE", "PAPERNO", "CUSTADDR", "CUSTPOST","CUSTPHONE","CUSTEMAIL","REMARK" };

        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;
    }
    /// <summary>
    /// 查询按钮点击事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //校验输入有效性
        if (!queryValidation()) return;

        string sql = "";
        string readerno = txtReaderNo.Text.Trim();
        string startdate = txtStartDate.Text.Trim();
        string enddate = txtEndDate.Text.Trim();
        sql = "select  a.SERIALNUMBER , a.SALETIME , c.STAFFNAME , d.DEPARTNAME    , " +
             "         decode(a.READERSTATE,'0','入库','1','出库','2','售出','3','更换回收',a.READERSTATE) READERSTATE," +
             "         b.CUSTNAME     , b.CUSTSEX  , b.CUSTBIRTH , b.PAPERTYPECODE , b.PAPERNO     ,  " +
             "         b.CUSTADDR     , b.CUSTPOST , b.CUSTPHONE , b.CUSTEMAIL     , b.REMARK         " +
             " from   TL_R_READER a,TF_F_READERCUSTREC b,TD_M_INSIDESTAFF c,TD_M_INSIDEDEPART d       " +
             " where  a.SERIALNUMBER =b.SERIALNUMBER(+)                                               " +
             " and    a.SALESTAFFNO = c.STAFFNO(+)                                                    " +
             " and    c.DEPARTNO = d.DEPARTNO                                                         " +
             " and    ('" + readerno + "' is null or '" + readerno + "' = '' or a.SERIALNUMBER = '" + readerno + "')" +
             " and    ('" + startdate + "' is null or '" + readerno + "' = '' or a.SALETIME >= to_date('" + startdate + "'||'000000','yyyymmddhh24miss'))" +
             " and    ('" + enddate + "' is null or '" + readerno + "' = '' or a.SALETIME <= to_date('" + enddate + "'||'235959','yyyymmddhh24miss')) ";
        context.DBOpen("Select");
        DataTable data = context.ExecuteReader(sql);

        if (data.Rows.Count < 1)
        {
            context.AddError("未找到相应的读卡器信息");
            return;
        }
        //解密
        CommonHelper.AESDeEncrypt(data, new List<string>(new string[] { "CUSTNAME", "CUSTPHONE", "CUSTADDR", "PAPERNO" }));

        gvResult.DataSource = data;
        gvResult.DataBind();
    }
    /// <summary>
    /// 输入校验
    /// </summary>
    /// <returns>没有错误时返回true，有错误时返回false</returns>
    private Boolean queryValidation()
    {
        //读卡器序列号
        if (!string.IsNullOrEmpty(txtReaderNo.Text.Trim()))
        {
            if (Validation.strLen(txtReaderNo.Text.Trim()) != 16)
                context.AddError("A094570211：读卡器序列号长度必须为16位", txtReaderNo);
            else if (!Validation.isNum(txtReaderNo.Text.Trim()))
                context.AddError("A094570212:读卡器序列号必须为数字", txtReaderNo);
        }

        //校验日期
        ResourceManageHelper.checkDate(context, txtStartDate, txtEndDate, "A095470102", "A095470103", "A095470104");

        return !context.hasError();
    }
    //onRowDataBound公共事件
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.Header
            || e.Row.RowType == DataControlRowType.DataRow)
        {
            //隐藏个人信息部分
            e.Row.Cells[6].Visible = false;
            e.Row.Cells[7].Visible = false;
            e.Row.Cells[8].Visible = false;
            e.Row.Cells[9].Visible = false;
            e.Row.Cells[10].Visible = false;
            e.Row.Cells[11].Visible = false;
            e.Row.Cells[12].Visible = false;
            e.Row.Cells[13].Visible = false;
            e.Row.Cells[14].Visible = false;
        }
    }
    //获取关键字的值
    public String getDataKeys(string keysname)
    {
        return gvResult.DataKeys[gvResult.SelectedIndex][keysname].ToString();
    }
    //卡号段Gridview选择事件
    public void gvResult_SelectedIndexChanged(object sender, EventArgs e)
    {
        CustName.Text = getDataKeys("CUSTNAME");
        CustBirthday.Text = getDataKeys("CUSTBIRTH");
        Papertype.Text = getDataKeys("PAPERTYPECODE");
        Paperno.Text = getDataKeys("PAPERNO");
        Custsex.Text = getDataKeys("CUSTSEX");
        Custphone.Text = getDataKeys("CUSTPHONE");
        Custpost.Text = getDataKeys("CUSTPOST");
        Custaddr.Text = getDataKeys("CUSTADDR");
        txtEmail.Text = getDataKeys("CUSTEMAIL");
        Remark.Text = getDataKeys("REMARK");
    }
    protected void gvResult_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件

            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResult','Select$" + e.Row.RowIndex + "')");
        }
    }
    protected void gvResult_Page(object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }
}