using System;
using System.Collections;
using System.Data;
using System.IO;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
/***************************************************************
 * 功能名: 资源管理市民卡订购单查询
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2012/11/21   董翔			初次开发
 ****************************************************************/
public partial class ASP_ResourceManage_RM_QuerySMKOrder : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            gvResultUseCard.DataSource = new DataTable();
            gvResultUseCard.DataBind();
            init_Page();
            gvResultUseCard.DataKeyNames =
               new string[] { "CARDORDERID","ORDERTYPE","ORDERFILENAME", "MANUNAME", "MANUFILECODE", "BATCHNO", "BATCHDATE", 
                    "CARDNUM", "BEGINCARDNO", "ENDCARDNO", "ORDERTIME", "ORDERSTAFF","EXAMTIME","EXAMSTAFF","REMARK",
                    "STATE" };
        }
    }

    /// <summary>
    /// 页面初始化
    /// </summary>
    protected void init_Page()
    {
        //初始化日期
        DateTime date = new DateTime();
        date = DateTime.Today;
        txtStartDate.Text = date.AddMonths(-1).ToString("yyyyMMdd");
        txtEndDate.Text = DateTime.Today.ToString("yyyyMMdd");
        txtOrderID.Text = "DG";
        btnDownload.Enabled = false;
    }

    #region 全选列表
    /// <summary>
    /// 选择或取消所有复选框
    /// </summary>
    protected void CheckAll(object sender, EventArgs e)
    {
        //全选信息记录
        CheckBox cbx = (CheckBox)sender;
        GridView gv = gvResultUseCard;
        foreach (GridViewRow gvr in gv.Rows)
        {
            if (!gvr.Cells[1].Enabled) continue;
            CheckBox ch = (CheckBox)gvr.FindControl("ItemCheckBox");
            ch.Checked = cbx.Checked;
        }
    }
    #endregion

    /// <summary>
    /// 查询按钮点击事件
    /// </summary>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (!queryValidation())
            return;
        bindUseCard();//查询用户卡
    }
    /// <summary>
    /// 用户卡GridView绑定数据源
    /// </summary>
    protected void bindUseCard()
    {
        //用户卡
        gvResultUseCard.DataSource = queryUseCard();
        gvResultUseCard.DataBind();
        gvResultUseCard.SelectedIndex = -1;
    }

    /// <summary>
    /// 查询用户卡订购单
    /// </summary>
    /// <returns></returns>
    protected ICollection queryUseCard()
    {
        //查询用户卡
        //订购单号如果为DG时，默认为未输入订购单号
        string cardOrderID = "";
        if (txtOrderID.Text.Trim() != "DG")
            cardOrderID = txtOrderID.Text.Trim();
        
        DataTable data = ResourceManageHelper.callQuery(context, "SMKOrderQuery", txtStartDate.Text.Trim(), txtEndDate.Text.Trim(),
                                               selExamState.SelectedValue.Trim(), cardOrderID.Trim(), selCardOrderType.SelectedValue);
        if (data.Rows.Count == 0)
        {
            ResourceManageHelper.resetData(gvResultUseCard, data);
            context.AddMessage("没有查询出任何记录");
            btnDownload.Enabled = false;
            return null;
        }
        return new DataView(data);
    }

    /// <summary>
    /// 查询输入校验
    /// </summary>
    /// <returns>没有错误返回true,存在错误则返回false</returns>
    protected Boolean queryValidation()
    {
        //校验日期
        ResourceManageHelper.checkDate(context, txtStartDate, txtEndDate, "A095470102", "A095470103", "A095470104");

        //校验订购单号
        if (!string.IsNullOrEmpty(txtOrderID.Text.Trim()) && txtOrderID.Text.Trim() != "DG")
        {
            if (Validation.strLen(txtOrderID.Text.Trim()) != 18)
                context.AddError("A095470137：订购单号必须为18位", txtOrderID);
            if (!Validation.isCharNum(txtOrderID.Text.Trim()))
                context.AddError("A095470138：订购单必须为英数", txtOrderID);
        }

        return !context.hasError();
    }

    /// <summary>
    /// 下载按钮点击事件
    /// </summary>
    protected void btnDownload_Click(object sender, EventArgs e)
    {
        context.DBOpen("StorePro");
        context.AddField("P_CARDORDERID").Value = gvResultUseCard.DataKeys[gvResultUseCard.SelectedIndex]["CARDORDERID"].ToString();
        //下载次数+1
        bool ok = context.ExecuteSP("SP_RM_DOWNLOADSMKORDER");
        if (ok)
        {
            //生成文件
            string path = Server.MapPath(Request.ApplicationPath + "\\file\\");
            string filename = gvResultUseCard.DataKeys[gvResultUseCard.SelectedIndex]["ORDERFILENAME"].ToString();
            if (!Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }
            FileInfo fi = new FileInfo(path + filename);
            if (fi.Exists)
            {
                fi.Delete();
            }
            string strFile = DateTime.Now.ToString("yyyyMMdd") + "," + gvResultUseCard.DataKeys[gvResultUseCard.SelectedIndex]["BATCHNO"].ToString() + ","
                    + gvResultUseCard.DataKeys[gvResultUseCard.SelectedIndex]["CARDNUM"].ToString() + "," + gvResultUseCard.DataKeys[gvResultUseCard.SelectedIndex]["MANUFILECODE"].ToString()
                    + ",SX," + gvResultUseCard.DataKeys[gvResultUseCard.SelectedIndex]["BEGINCARDNO"].ToString() + "," + gvResultUseCard.DataKeys[gvResultUseCard.SelectedIndex]["ENDCARDNO"].ToString();
            File.AppendAllText(path + filename, strFile.ToString(), Encoding.GetEncoding("GBK"));
            fi = new FileInfo(path + filename);
            //下载文件
            HttpResponse contextResponse = HttpContext.Current.Response;
            contextResponse.Clear();
            contextResponse.Buffer = true;
            contextResponse.Charset = "GBK";
            contextResponse.AppendHeader("Content-Disposition", String.Format("attachment;filename={0}", filename));
            contextResponse.AppendHeader("Content-Length", fi.Length.ToString());
            contextResponse.ContentEncoding = Encoding.Default;
            contextResponse.ContentType = "text/plain";
            contextResponse.WriteFile(fi.FullName);
            contextResponse.Flush();
            //删除文件
            fi.Delete();
            contextResponse.End();
        }
    }


    #region GridView事件
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            ResourceManageHelper.ClearRowDataBound(e);
        }
    }
    protected void gvResultUseCard_RowCreated(object sender, GridViewRowEventArgs e)
    {
        //注册行单击事件
        if (e.Row.RowType == DataControlRowType.DataRow)
        {

            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResultUseCard','Select$" + e.Row.RowIndex + "')");
        }
    }

    //选择行事件
    public void gvResult_SelectedIndexChanged(object sender, EventArgs e)
    {
        txtCardOrderID.Text = getDataKeys("CARDORDERID");
        txtOrderType.Text = getDataKeys("ORDERTYPE").Substring(getDataKeys("ORDERTYPE").IndexOf(":") + 1);
        txtExamState.Text = getDataKeys("STATE").Substring(getDataKeys("STATE").IndexOf(":") + 1);
        txtOrderFileName.Text = getDataKeys("ORDERFILENAME");
        txtFromCardNo.Text = getDataKeys("BEGINCARDNO");
        txtToCardNo.Text = getDataKeys("ENDCARDNO");
        txtCardSum.Text = getDataKeys("CARDNUM");
        txtProducer.Text = getDataKeys("MANUNAME").Substring(getDataKeys("MANUNAME").IndexOf(":") + 1); ;
        txtBatchNo.Text = getDataKeys("BATCHNO");
        txtBatchDate.Text = getDataKeys("BATCHDATE");
        txtOrderStaff.Text = getDataKeys("ORDERSTAFF").Substring(getDataKeys("ORDERSTAFF").IndexOf(":") + 1);
        txtOrderTime.Text = getDataKeys("ORDERTIME");
        txtReMark.Text = getDataKeys("REMARK");
        if (txtExamState.Text == "审核通过")
        {
            btnDownload.Enabled = true;
        }
        else
        {
            btnDownload.Enabled = false;
        }
    }
    //获取关键字的值
    public String getDataKeys(string keysname)
    {
        GridView gv = gvResultUseCard;
        return gv.DataKeys[gv.SelectedIndex][keysname].ToString();
    }
    //翻页事件
    protected void gvResult_Page(object sender, GridViewPageEventArgs e)
    {
        GridView gv = gvResultUseCard; 
        gv.PageIndex = e.NewPageIndex;
        bindUseCard();
    }
    #endregion
}