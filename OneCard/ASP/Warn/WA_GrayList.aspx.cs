using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using Master;
using System.Text;

/***************************************************************
 * 功能名: 财务监控_轻轨灰名单
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2015-06-18   jiangbb         新增
 ****************************************************************/
public partial class ASP_Warn_WA_WA_GrayList : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {

            //显示列表
            gvResult.DataSource = new DataTable();
            gvResult.DataBind();
            gvResult.SelectedIndex = -1;
        }
    }

    /// <summary>
    /// 绑定数据
    /// </summary>
    /// <param name="checkNoData">没有查询结果时是否提示</param>
    private void CreateResultDataBind(bool checkNoData)
    {
        //验证
        ValidateBeforeDataBind();
        if (context.hasError())
        {
            return;
        }

        //查询条件
        List<string> vars = new List<string>();
        vars.Add(this.txtCardNum.Text);
        vars.Add(this.txtStartDate.Text);
        vars.Add(this.txtEndDate.Text);
        DataTable dt = SPHelper.callWAQuery(context, "QueryGrayList", vars.ToArray());

        UserCardHelper.resetData(gvResult, dt);

        if (checkNoData && dt.Rows.Count == 0)
        {
            context.AddMessage("A002W01005:没有查到数据");
        }

        this.btnGrayDelete.Enabled = false;
        this.gvResult.SelectedIndex = -1;
    }

    #region 页面控件事件
    /// <summary>
    /// 查询按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        CreateResultDataBind(true);
    }

    /// <summary>
    /// 添加按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnGrayAdd_Click(object sender, EventArgs e)
    {
        //验证
        ValidateBeforeAdd();
        if (context.hasError())
        {
            return;
        }

        context.SPOpen();
        context.AddField("P_CARDNO").Value = this.txtCardno.Text.Trim();
        context.AddField("P_REMARK").Value = this.txtRemark.Text.Trim();
        bool ok = context.ExecuteSP("SP_WA_GrayListADD");

        if (ok)
        {
            AddMessage("M001W02001:添加黑名单成功");

            clearCustInfo(txtCardno, txtRemark, labCreateTime);

            CreateResultDataBind(false);
        }
    }

    /// <summary>
    /// 批量导入事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnBatchAdd_Click(object sender, EventArgs e)
    {
        //清空临时表数据
        clearTempTable();

        if (Path.GetExtension(FileUpload1.FileName) == ".txt")
        {
            LoadFile();
            if (context.hasError())
            {
                return;
            }

            context.SPOpen();
            context.AddField("p_sessionID").Value = Session.SessionID;
            bool ok = context.ExecuteSP("SP_WA_IMPORTGrayLIST");
            if (ok)
            {
                AddMessage("轻轨灰名单批量录入保存成功");
                CreateResultDataBind(false);
            }
        }
        else
        {
            context.AddError("请导入格式为*.txt文件");
        }
    }

    private void clearTempTable()
    {
        //删除临时表数据
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from tmp_blacklist " +
           " where F0 = '" + Session.SessionID + "'");
        context.DBCommit();
    }

    /// <summary>
    /// txt文件解析
    /// </summary>
    private void LoadFile()
    {
        //导入文件

        if (!FileUpload1.HasFile)
        {
            context.AddError("A008110001");
            return;
        }
        int len = FileUpload1.FileBytes.Length;

        if (len <= 0)
        {
            context.AddError("A008110007:文件内容为空！");
            return;
        }

        if (len > 5 * 1024 * 1024) // 5M
        {
            context.AddError("A008110010");
            return;
        }

        //读取文件
        Stream stream = FileUpload1.FileContent;
        StreamReader reader = new StreamReader(stream, Encoding.GetEncoding("gb2312"));
        string cardno = "";
        int lineCount = 0;
        //循环读取文件所有记录行
        while ((cardno = reader.ReadLine()) != null)
        {
            ++lineCount;
            cardno = cardno.Trim();

            if (cardno.Length > 16)
            {
                context.AddError("第" + lineCount + "行长度为" + cardno.Length + ", 根据格式定义不能超过16位");
            }
            //验证卡号是否已经在黑名单中
            SP_QueryPDO pdo = new SP_QueryPDO("SP_WA_Query");
            SPHelper.callQuery(pdo, context, "isCardInGrayTab", cardno);

            int count = Convert.ToInt32(pdo.var8);

            if (count > 0)
            {
                context.AddError("第" + lineCount + "行A002W01015: 卡号" + cardno + "在灰名单中已经存在");
            }

            if (!context.hasError())
            {
                insertToTmp(cardno);
            }

        }
        if (!context.hasError() && lineCount > 0)
        {
            CreateResultDataBind(false);
            AddMessage("M008110198:灰名单导入成功！");
        }
        else
        {
            context.RollBack();
        }
    }

    private void insertToTmp(string cardno)
    {
        context.DBOpen("Insert");
        string insertToTmp = "insert into tmp_blacklist(f0, f1) values('"
                                + Session.SessionID + "', '"
                                + cardno + "')";

        context.ExecuteNonQuery(insertToTmp);
        context.DBCommit();
    }
    /// <summary>
    /// 删除按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnGrayDelete_Click(object sender, EventArgs e)
    {
        //验证
        ValidateBeforeDel();
        if (context.hasError())
        {
            return;
        }

        context.SPOpen();
        context.AddField("P_CARDNO").Value = this.txtCardno.Text.Trim();
        bool ok = context.ExecuteSP("SP_WA_GrayListDEL");

        if (ok)
        {
            AddMessage("M001W02002:删除黑名单成功");

            clearCustInfo(txtCardno, txtRemark, labCreateStaffNo, labCreateTime);

            CreateResultDataBind(false);
        }
    }

    /// <summary>
    /// 选择按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    public void gvResult_SelectedIndexChanged(object sender, EventArgs e)
    {
        GridViewRow selectRow = gvResult.SelectedRow;

        this.txtCardno.Text = selectRow.Cells[1].Text;
        this.txtRemark.Text = selectRow.Cells[2].Text;
        this.labCreateTime.Text = selectRow.Cells[3].Text;
        this.labCreateStaffNo.Text = selectRow.Cells[4].Text;

        this.btnGrayDelete.Enabled = true;
    }

    /// <summary>
    /// 分页事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }

    #endregion

    #region 提交前的验证
    /// <summary>
    /// 查询前验证查询条件
    /// </summary>
    private void ValidateBeforeDataBind()
    {
        Validation valid = new Validation(context);

        bool b1 = Validation.isEmpty(txtStartDate);
        bool b2 = Validation.isEmpty(txtEndDate);
        DateTime? fromDate = null, toDate = null;

        if (!b1)
        {
            fromDate = valid.beDate(txtStartDate, "A002W01002:开始日期范围起始值格式必须为yyyyMMdd");
        }
        if (!b2)
        {
            toDate = valid.beDate(txtEndDate, "A002W01003:结束日期范围终止值格式必须为yyyyMMdd");
        }

        if (fromDate != null && toDate != null)
        {
            valid.check(fromDate.Value.CompareTo(toDate.Value) <= 0, "开始日期不能大于结束日期");
        }

        if (txtCardNum.Text.Trim().Length > 0)
        {
            valid.fixedLength(txtCardNum, 16, "A002W01012: 卡号长度必须是16位");

            valid.beNumber(txtCardNum, "A002W01013: 卡号必须是数字");
        }
    }

    /// <summary>
    /// 增加前验证控件内容
    /// </summary>
    private void ValidateBeforeAdd()
    {
        #region 验证卡号
        Validation valid = new Validation(context);
        if (txtCardno.Text.Trim().Length > 0)
        {
            valid.fixedLength(txtCardno, 16, "A002W01012: 卡号长度必须是16位");
            valid.beNumber(txtCardno, "A002W01013: 卡号必须是数字");
        }
        else
        {
            context.AddError("A002W01014:卡号不能为空", this.txtCardno);
        }

        //验证卡号是否已经在黑名单中
        SP_QueryPDO pdo = new SP_QueryPDO("SP_WA_Query");
        SPHelper.callQuery(pdo, context, "isCardInGrayTab", this.txtCardno.Text);
        int count = Convert.ToInt32(pdo.var8);

        if (count > 0)
        {
            context.AddError("A002W01099:此卡号灰名单中已经存在", this.txtCardno);
        }
        #endregion


        //备注
        if (this.txtRemark.Text.Trim().Length == 0)
        {
            context.AddError("A002W01018:录入原因不能为空", this.txtRemark);
        }
    }

    /// <summary>
    /// 删除前验证控件内容
    /// </summary>
    private void ValidateBeforeDel()
    {
        if (gvResult.SelectedRow == null)
        {
            context.AddError("A002W01019:没有选择数据记录");
            return;
        }

        if (this.txtCardno.Text != gvResult.SelectedRow.Cells[1].Text)
        {
            context.AddError("A002W01020:所选记录卡号已修改，不可删除");
        }
    }
    #endregion

    public class GrayList
    {
        private CmnContext context;
        private int lineCount;

        private string cardNO; //卡号
        /// <summary>
        /// 卡号
        /// </summary>
        public string CardNO
        {
            get
            {
                return cardNO;
            }
            set
            {
                cardNO = value;

                if (cardNO.Length < 1)
                {
                    context.AddError("A002W01014:卡号不能为空");
                }
                else if (cardNO.Trim().Length != 16)
                {
                    context.AddError("A002W01012: 卡号长度必须是16位");
                }
                else if (!Validation.isNum(cardNO))
                {
                    context.AddError("A002W01013: 卡号必须是数字");
                }
            }
        }

        private string remark;//录入原因
        /// <summary>
        /// 录入原因
        /// </summary>
        public string Remark
        {
            get { return remark; }
            set
            {
                remark = value;
                if (remark.Length < 1)
                {
                    context.AddError("A002W01018:录入原因不能为空");
                }
            }
        }
    }
}