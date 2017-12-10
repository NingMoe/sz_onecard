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
using TDO.PersonalTrade;
using TM;
using TDO.BalanceChannel;
using TDO.UserManager;
using PDO.SpecialDeal;

public partial class ASP_SpecialDeal_SD_SpeAdjustAccVoid : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //查询待审核的特殊调账信息
            QueryAdjustAcc();

            //创建临时表
           // createTempTable();

            //清空临时表数据
            clearTempTable();
        }
    }

    private void createTempTable()
    {    //创建临时表
        context.DBOpen("Select");
        context.ExecuteNonQuery("exec SP_SD_SpeAdjustCheckTmp");
    }

    private void clearTempTable()
    {   //清空临时表数据
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_ADJUSTACC_IMP where SessionId='"
            + Session.SessionID + "'");
        context.DBCommit();
    }

    private void QueryAdjustAcc()
    {
        //取得查询结果
        ICollection dataView = QueryResultColl();

        //显示查询结果信息
        gvResult.DataSource = dataView;
        gvResult.DataBind();
    }

    private void showResult()
    {
        //显示调帐信息列表信息
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
    }


    protected void CheckAll(object sender, EventArgs e)
    {
        //全选审核信息记录
        CheckBox cbx = (CheckBox)sender;
        foreach (GridViewRow gvr in gvResult.Rows)
        {
            if (!gvr.Cells[0].Enabled) continue;
            CheckBox ch = (CheckBox)gvr.FindControl("ItemCheckBox");
            ch.Checked = cbx.Checked;
        }
    }


    public ICollection QueryResultColl()
    {
        TMTableModule tmTMTableModule = new TMTableModule();


        //从特殊调帐台帐表(TF_B_SPEADJUSTACC)中读取数据
        TF_B_SPEADJUSTACCTDO tdoSpeAdjAcc = new TF_B_SPEADJUSTACCTDO();

        string strSql = "SELECT " +
                        "tf.CARDNO,tf.CALLINGNO,tno.CALLING CALLINGNAME,tf.CORPNO,tp.CORP CORPNAME,tf.DEPARTNO,tt.DEPART DEPARTNAME, " +
                        "tf.TRADEDATE,tf.TRADETIME,tf.PREMONEY,tf.TRADEMONEY,tf.REFUNDMENT ,tf.STAFFNO, ti.STAFFNAME STAFFNAME, tf.OPERATETIME, " +
                        "(case when ( tf.REASONCODE = '1') then '隔日退货' " +
                        "when ( tf.REASONCODE = '2') then '交易成功,签购单未打印' " +
                        "when ( tf.REASONCODE = '3') then '交易不成功,扣款' " +
                        "when ( tf.REASONCODE = '4') then '多刷金额' " +
                        "when ( tf.REASONCODE = '5') then '其他'  end ) REASONCODE , tf.TRADEID,  tf.CUSTPHONE CUSTPHONE, tf.CUSTNAME CUSTNAME " +
                        "FROM TF_B_SPEADJUSTACC tf, TD_M_CALLINGNO tno, TD_M_CORP tp, TD_M_DEPART tt, TD_M_INSIDESTAFF ti " +
                        "WHERE tf.CALLINGNO = tno.CALLINGNO(+) AND tf.CORPNO = tp.CORPNO(+) AND tf.DEPARTNO = tt.DEPARTNO(+) " +
                        "AND tf.STAFFNO = ti.STAFFNO(+) AND tf.STATECODE = '1' AND tf.TRADETYPECODE = '97'  ";
       
        // strSql += " ORDER BY OPERATETIME ";

        DataTable data = tmTMTableModule.selByPKDataTable(context, tdoSpeAdjAcc, null, strSql, 1000);

        //getNameByCode(data);

        DataView dataView = new DataView(data);
        return dataView;

    }


    private void getNameByCode(DataTable data)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //查询行业,单位,部门信息
        TD_M_CALLINGNOTDO ddoTD_M_CALLINGNOIn = new TD_M_CALLINGNOTDO();
        DataTable dataCalling = tmTMTableModule.selByPKDataTable(context, ddoTD_M_CALLINGNOIn, null, "", null, 0);

        TD_M_CORPTDO ddoTD_M_CORPIn = new TD_M_CORPTDO();
        DataTable dataCorp = tmTMTableModule.selByPKDataTable(context, ddoTD_M_CORPIn, null, "", null, 0);

        TD_M_DEPARTTDO ddoTD_M_DEPARTIn = new TD_M_DEPARTTDO();
        DataTable dataDepart = tmTMTableModule.selByPKDataTable(context, ddoTD_M_DEPARTIn, null, "", null, 0);


        //录入员工信息
        TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
        DataTable dataStuff = tmTMTableModule.selByPKDataTable(context, tdoTD_M_INSIDESTAFFIn, null, "", null, 0);


        DataRow[] dataRows = null;

        data.Columns["CALLINGNAME"].MaxLength = 20;
        data.Columns["CORPNAME"].MaxLength = 20;
        data.Columns["DEPARTNAME"].MaxLength = 40;
        data.Columns["STAFFNAME"].MaxLength = 20;

        //循环读取交易记录信息
        for (int index = 0; index < data.Rows.Count; index++)
        {

            string CallingNO = data.Rows[index]["CALLINGNO"].ToString();
            string CorpNo = data.Rows[index]["CORPNO"].ToString();
            string DepartNo = data.Rows[index]["DEPARTNO"].ToString();
            string StaffNo = data.Rows[index]["STAFFNO"].ToString();

            //显示行业编码对应的行业名称
            if (CallingNO != null && CallingNO.Trim() != "")
            {
                dataRows = dataCalling.Select("CALLINGNO = '" + CallingNO + "'");
                if (dataRows.Length == 1)
                {
                    data.Rows[index]["CALLINGNAME"] = dataRows[0]["CALLING"];
                }
            }

            //显示单位编码对应的单位名称
            if (CorpNo != null && CorpNo.Trim() != "")
            {
                dataRows = dataCorp.Select("CORPNO = '" + CorpNo + "'");
                if (dataRows.Length == 1)
                {
                    data.Rows[index]["CORPNAME"] = dataRows[0]["CORP"];
                }
            }

            //显示部门编码对应的部门名称
            if (DepartNo != null && DepartNo.Trim() != "")
            {
                dataRows = dataDepart.Select("DEPARTNO = '" + DepartNo + "'");
                if (dataRows.Length == 1)
                {
                    data.Rows[index]["DEPARTNAME"] = dataRows[0]["DEPART"];
                }
            }

            //显示录入员工姓名
            if (StaffNo != null && StaffNo.Trim() != "")
            {
                dataRows = dataStuff.Select("STAFFNO = '" + StaffNo + "'");
                if (dataRows.Length == 1)
                {
                    data.Rows[index]["STAFFNAME"] = dataRows[0]["STAFFNAME"];
                }
            }

        }
    }

    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        //分页处理 
        gvResult.PageIndex = e.NewPageIndex;

        QueryAdjustAcc();

    }



    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //单元格从索引0开始
            //显示交易日期,格式为YYYY-MM-dd
            if (e.Row.Cells[9].Text.Length == 8 )
              e.Row.Cells[9].Text = e.Row.Cells[9].Text.Substring(0, 4) + "-" + e.Row.Cells[9].Text.Substring(4, 2) + "-" + e.Row.Cells[9].Text.Substring(6, 2);

            //显示交易时间,格式为hh:mm:ss
            if (e.Row.Cells[10].Text.Length == 6)
              e.Row.Cells[10].Text = e.Row.Cells[10].Text.Substring(0, 2) + ":" + e.Row.Cells[10].Text.Substring(2, 2) + ":" + e.Row.Cells[10].Text.Substring(4, 2);

            //显示交易前金额,交易金额,,退款金额单位为元
            e.Row.Cells[11].Text = (Convert.ToDouble(e.Row.Cells[11].Text) / 100).ToString("0.00");
            e.Row.Cells[12].Text = (Convert.ToDouble(e.Row.Cells[12].Text) / 100).ToString("0.00");

            e.Row.Cells[2].Text = (Convert.ToDouble(e.Row.Cells[2].Text) / 100).ToString("0.00");
        }

        if (e.Row.RowType == DataControlRowType.Header || e.Row.RowType == DataControlRowType.DataRow)
        {
            //隐藏业务流水号
            e.Row.Cells[13].Visible = false;
        }
    }


    private bool RecordIntoTmp()
    {
        //回收记录入临时表
        context.DBOpen("Insert");

        int count = 0;
        foreach (GridViewRow gvr in gvResult.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                ++count;

                //退款金额转换为分为单位的整数
                Double dbl = Convert.ToDouble(gvr.Cells[2].Text) * 100;
                int iRefundMoney = Convert.ToInt32(dbl);
                context.ExecuteNonQuery("insert into TMP_ADJUSTACC_IMP values('"
                    + gvr.Cells[13].Text + "','" + gvr.Cells[1].Text + "'," + iRefundMoney + ",'" + Session.SessionID + "')");
            }
        }

        context.DBCommit();

        // 没有选中任何行，则返回错误
        if (count <= 0)
        {
            context.AddError("A009111001");
            return false;
        }

        return true;
    }


  

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        //清空临时表数据
        clearTempTable();

        //信息插入临时表
        if (!RecordIntoTmp()) return;

        //调用作废的存储过程

        SP_SD_SpeAdjustAccPassVoidPDO pdo = new SP_SD_SpeAdjustAccPassVoidPDO();

        pdo.sessionID = Session.SessionID;

        bool ok = TMStorePModule.Excute(context, pdo);
        if (ok)
        {
            AddMessage("M009111113");
        }

        //清空临时表数据
        clearTempTable();

        //查询待审核的调账信息
        QueryAdjustAcc();
    }

}
