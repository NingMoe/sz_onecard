using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Collections.Generic;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using PDO.PersonalBusiness;
using Master;
using Common;
using TM;
using System.IO;

/***************************************************************
 * 功能名: 财务监控_轻轨黑名单下发
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2012/04/18    liuhe			初次编写
 * 2013/08/30    huangzl        功能改造
 ****************************************************************/
public partial class ASP_Warn_WA_SubwayBlackListIssue : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //指定订单类型GridView DataKeyNames
            gvResult.DataKeyNames = new string[] { "LISTTYPECODE", "LISTTYPENAME" };

            //显示列表
            gvResult.DataSource = new DataTable();
            gvResult.DataBind();
            gvResult.SelectedIndex = -1;
            //绑定轨交黑灰名单类型
            ASHelper.initBlackListTypeList(context, dropBlackListTypeQ);
            ASHelper.initBlackListTypeList(context, dropBlackListType);
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
        vars.Add(this.dropBlackListTypeQ.SelectedValue);
        DataTable dt = SPHelper.callWAQuery(context, "QueryLRTBlackList", vars.ToArray());

        UserCardHelper.resetData(gvResult, dt);

        if (checkNoData && dt.Rows.Count == 0)
        {
            context.AddMessage("A002W01005:没有查到数据");
        }

        this.btnBlackDelete.Enabled = false;
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
    protected void btnBlackAdd_Click(object sender, EventArgs e)
    {
        //验证
        ValidateBeforeAdd();
        if (context.hasError())
        {
            return;
        }

        context.SPOpen();
        context.AddField("P_CARDNO").Value = this.txtCardno.Text.Trim();
        context.AddField("P_OVERTIMEMONEY").Value = Convert.ToInt32(Convert.ToDecimal(this.txtMOney.Text) * 100);
        context.AddField("P_REMARK").Value = this.txtRemark.Text.Trim();
        context.AddField("P_LISTTYPECODE").Value = this.dropBlackListType.SelectedValue.Trim();
        bool ok = context.ExecuteSP("SP_WA_LRTBlackListADD");

        if (ok)
        {
            AddMessage("M001W02001:添加黑名单成功");

            clearCustInfo(txtCardno, txtMOney, txtRemark,dropBlackListType,labCreateStaffNo, labCreateTime);

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
        if (!FileUpload1.HasFile)
        {
            context.AddError("A004P01F00: 没有上传任何文件");
            return;
        }
        int len = FileUpload1.FileBytes.Length;

        if (len > 5 * 1024 * 1024) // 5M
        {
            context.AddError("A004P01F02: 上传文件大小不能超过5M");
            return;
        }
        //清空临时表数据
        clearTempTable();
      
        if (Path.GetExtension(FileUpload1.FileName) == ".xls" || Path.GetExtension(FileUpload1.FileName) == ".xlsx")
        {
            LoadExcelFile();
            if (context.hasError())
            {
                return;
            }

            context.SPOpen();
            context.AddField("p_sessionID").Value = Session.SessionID;
            bool ok = context.ExecuteSP("SP_WA_IMPORTBLACKLIST");
            if (ok)
            {
                AddMessage("轻轨黑灰名单批量录入保存成功");
                CreateResultDataBind(false);
            }        
        }
        else
        {
            context.AddError("请导入格式为.xls或.xlsx文件");
        }
    }

    private void clearTempTable()
    {
        //删除临时表数据
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_BLACKLIST");
        //context.ExecuteNonQuery("delete from TMP_BLACKLIST " +
        //   " where F4 = '" + Session.SessionID + "'");
        context.DBCommit();
    }

    /// <summary>
    /// Excel格式文件解析
    /// </summary>
    private void LoadExcelFile()
    {
        if (File.Exists("E:\\excelfile\\" + FileUpload1.FileName))
        {
            File.Delete("E:\\excelfile\\" + FileUpload1.FileName);
        }
        byte[] bytes = FileUpload1.FileBytes;
        using (FileStream f = new FileStream("E:\\excelfile\\" + FileUpload1.FileName, FileMode.OpenOrCreate, FileAccess.ReadWrite))
        {
            f.Write(bytes, 0, bytes.Length);
        }
        DataTable data = OrderHelper.getExcel_info("E:\\excelfile\\" + FileUpload1.FileName);
        if (data != null && data.Rows.Count > 0)
        {
            Hashtable ht = new Hashtable();
            for (int i = 0; i < data.Rows.Count; i++)
            {
                if (data.Rows[i][0].ToString().Trim().Length > 0 || data.Rows[i][1].ToString().Trim().Length > 0
                    && data.Rows[i][2].ToString().Trim().Length > 0 || data.Rows[i][3].ToString().Trim().Length > 0
                  
                    )
                {
                    String[] fields = new String[10];
                    fields[0] = data.Rows[i][0].ToString();
                    
                    //验证卡号是否已经在黑名单中
                    SP_QueryPDO pdo = new SP_QueryPDO("SP_WA_Query");
                    SPHelper.callQuery(pdo, context, "isCardInBlackTab", fields[0]);

                    int count = Convert.ToInt32(pdo.var8);

                    if (count > 0)
                    {
                        context.AddError("A002W01015: 卡号" + fields[0] + "在黑名单中已经存在");
                        //return;
                    }
                    else
                    {
                        fields[1] = data.Rows[i][1].ToString();
                        fields[2] = data.Rows[i][2].ToString();
                        fields[3] = data.Rows[i][3].ToString();
                        dealFileContent(ht, fields, i + 1, i);
                    }
                }
            }
        }
        else
        {
            context.AddError("A004P01F01: 上传文件为空");
        }
        if (!context.hasError())
        {
            context.DBCommit();
        }
        //try
        //{
        //    if (FileUpload1.HasFile && File.Exists("E:\\excelfile\\" + FileUpload1.FileName))
        //    {
        //        File.Delete("E:\\excelfile\\" + FileUpload1.FileName);
        //    }
        //}
        //catch
        //{ 
        //}
    }

    private void dealFileContent(Hashtable ht, String[] fields, int lineCount, int rownum)
    {
        BlackList blacklist = new BlackList();
        blacklist.setCmnContext(context);
        blacklist.setLineCount(lineCount);

        blacklist.CardNO = fields[0].Trim();
        blacklist.ListType=fields[1].Trim();
        blacklist.OverTimeMoney = fields[2].Trim();
        blacklist.Remark = fields[3].Trim();
        insertToTmp(blacklist, rownum);
    }

    private void insertToTmp(BlackList blacklist, int rownum)
    {
        if (!context.hasError())
        {
            context.DBOpen("Insert");
            string insertToTmp = "insert into TMP_BLACKLIST(f0, f1, f2, f3, f4, f5) values('"
                                    + blacklist.CardNO.Trim() + "', '"
                                    + blacklist.ListType.Trim() + "', '"
                                    + blacklist.OverTimeMoney.Trim() + "', '"
                                    + blacklist.Remark.Trim() + "', '"
                                    + Session.SessionID + "', '"
                                    + rownum.ToString() + "')";

            context.ExecuteNonQuery(insertToTmp);
            context.DBCommit();
        }
    }
    /// <summary>
    /// 删除按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnBlackDelete_Click(object sender, EventArgs e)
    {
        //验证
        ValidateBeforeDel();
        if (context.hasError())
        {
            return;
        }

        context.SPOpen();
        context.AddField("P_CARDNO").Value = this.txtCardno.Text.Trim();
        bool ok = context.ExecuteSP("SP_WA_LRTBlackListDEL");

        if (ok)
        {
            AddMessage("M001W02002:删除黑名单成功");

            clearCustInfo(txtCardno, txtMOney, txtRemark, labCreateStaffNo, labCreateTime,dropBlackListType);

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
        this.dropBlackListType.SelectedValue = gvResult.DataKeys[gvResult.SelectedIndex]["LISTTYPECODE"].ToString();
        this.txtRemark.Text = selectRow.Cells[3].Text;
        this.txtMOney.Text = selectRow.Cells[4].Text;
        this.labCreateTime.Text = selectRow.Cells[5].Text;
        this.labCreateStaffNo.Text = selectRow.Cells[6].Text;

        this.btnBlackDelete.Enabled = true;
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
    private void  ValidateBeforeAdd()
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
        SPHelper.callQuery(pdo, context, "isCardInBlackTab", this.txtCardno.Text);
        int count = Convert.ToInt32(pdo.var8);

        if (count > 0)
        {
            context.AddError("A002W01015:此卡号黑名单中已经存在", this.txtCardno);
        }
        #endregion

        //超时金额
        UserCardHelper.validatePrice(context, txtMOney, "A002W01016:超时金额不能为空", "A002W01017:超时金额必须是10.2的格式");
       
        //备注
        if (this.txtRemark.Text.Trim().Length == 0)
        {
            context.AddError("A002W01018:录入原因不能为空", this.txtRemark);
        }
        if (dropBlackListType.SelectedValue == "")
        {
            context.AddError("A002W01021:订单类型不能为空", this.dropBlackListType);
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

    public class BlackList
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
                else if(!Validation.isNum(cardNO))
                {
                    context.AddError("A002W01013: 卡号必须是数字");
                }
            }
        }

        private string overtimeMoney; //超时金额
        /// <summary>
        /// 超时金额
        /// </summary>
        public string OverTimeMoney
        {
            get
            {
                return Convert.ToInt32(Convert.ToDecimal(overtimeMoney) * 100).ToString();
            }
            set
            {
                overtimeMoney = value;
                if (overtimeMoney.Length < 1)
                {
                    context.AddError(" A002W01016:超时金额不能为空");
                }
                UserCardHelper.validatePrice(context, overtimeMoney, "A002W01017:超时金额必须是10.2的格式");
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

        private string listType;//订单类型
        /// <summary>
        /// 订单类型
        /// </summary>
        public string ListType
        {
            get { return listType; }
            set
            {
                listType = value;
                if (listType.Length < 1)
                {
                    context.AddError("A002W01021:订单类型不能为空");
                }
            }
        }

        public void setCmnContext(CmnContext context)
        {
            this.context = context;
        }

        public void setLineCount(int lineCount)
        {
            this.lineCount = lineCount;
        }
    }
}