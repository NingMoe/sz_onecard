using Common;
using Master;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using NPOI.HSSF.UserModel;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;
using TDO.BalanceChannel;
using TDO.BalanceParameter;
using TM;
public partial class ASP_Financial_FI_ZZCardConsumerReport : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {

            gvResult.DataSource = new DataTable();
            gvResult.DataBind();
        }
    }


    #region private

    #region selectContorl
    private string GetTableCellValue(TableCell cell)
    {
        string s = cell.Text.Trim();
        if (s == "&nbsp;" || s == "")
            return "0";
        return s;
    }
    // 查询输入校验处理
    private void validate()
    {
        Validation valid = new Validation(context);
        if (!string.IsNullOrEmpty(txtCardNo.Text))
        {
            if (Validation.strLen(txtCardNo.Text) != 16)
                context.AddError("A009100109", txtCardNo);
            else if (!Validation.isNum(txtCardNo.Text))
                context.AddError("A009100110", txtCardNo);
        }
    }

    private void InitCorp(DropDownList origindwls, DropDownList extdwls, String sqlCondition)
    {
        // 从单位编码表(TD_M_CORP)中读取数据，放入增加,修改区域中单位信息下拉列表中

        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_CORPTDO tdoTD_M_CORPIn = new TD_M_CORPTDO();
        tdoTD_M_CORPIn.CALLINGNO = origindwls.SelectedValue;

        TD_M_CORPTDO[] tdoTD_M_CORPOutArr = (TD_M_CORPTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_CORPIn, typeof(TD_M_CORPTDO), null, sqlCondition, null);
        ControlDeal.SelectBoxFillWithCode(extdwls.Items, tdoTD_M_CORPOutArr, "CORP", "CORPNO", true);
    }

    private void InitDepart(DropDownList origindwls, DropDownList extdwls, String sqlCondition)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        //从部门编码表(TD_M_CDEPART)中读取数据，放入下拉列表中


        TD_M_DEPARTTDO tdoTD_M_DEPARTIn = new TD_M_DEPARTTDO();
        tdoTD_M_DEPARTIn.CORPNO = origindwls.SelectedValue;

        TD_M_DEPARTTDO[] tdoTD_M_DEPARTOutArr = (TD_M_DEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_DEPARTIn, typeof(TD_M_DEPARTTDO), null, sqlCondition, null);
        ControlDeal.SelectBoxFillWithCode(extdwls.Items, tdoTD_M_DEPARTOutArr, "DEPART", "DEPARTNO", true);
    }

    private void InitBalUnit(string balType, DropDownList dwls)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        TF_TRADE_BALUNITTDO tdoTF_TRADE_BALUNITIn = new TF_TRADE_BALUNITTDO();
        TF_TRADE_BALUNITTDO[] tdoTF_TRADE_BALUNITOutArr = null;

        //查询选定行业下的结算单元
        if (balType == "00")
        {
            tdoTF_TRADE_BALUNITIn.CALLINGNO = dwls.SelectedValue;
            tdoTF_TRADE_BALUNITOutArr = (TF_TRADE_BALUNITTDO[])tmTMTableModule.selByPKArr(context, tdoTF_TRADE_BALUNITIn, typeof(TF_TRADE_BALUNITTDO), null, "TF_TRADE_BALUNITALL_BYCALLING", null);
        }

        //查询选定单位下的结算单元
        else if (balType == "01")
        {
            tdoTF_TRADE_BALUNITIn.CALLINGNO = selCalling.SelectedValue;
            tdoTF_TRADE_BALUNITIn.CORPNO = dwls.SelectedValue;
            tdoTF_TRADE_BALUNITOutArr = (TF_TRADE_BALUNITTDO[])tmTMTableModule.selByPKArr(context, tdoTF_TRADE_BALUNITIn, typeof(TF_TRADE_BALUNITTDO), null, "TF_TRADE_BALUNITALL_BYCORP", null);
        }

        //查询选定部门下的结算单元
        else if (balType == "02")
        {
            tdoTF_TRADE_BALUNITIn.CALLINGNO = selCalling.SelectedValue;
            tdoTF_TRADE_BALUNITIn.CORPNO = selCorp.SelectedValue;
            tdoTF_TRADE_BALUNITIn.DEPARTNO = dwls.SelectedValue;
            tdoTF_TRADE_BALUNITOutArr = (TF_TRADE_BALUNITTDO[])tmTMTableModule.selByPKArr(context, tdoTF_TRADE_BALUNITIn, typeof(TF_TRADE_BALUNITTDO), null, "TF_TRADE_BALUNITALL_BYDEPART", null);
        }

        ControlDeal.SelectBoxFill(selBalUint.Items, tdoTF_TRADE_BALUNITOutArr, "BALUNIT", "BALUNITNO", true);
    }


    #endregion

    #region queryData

    private Dictionary<string, string> DeclarePost()
    {
        Dictionary<string, string> postData = new Dictionary<string, string>();
        postData.Add("channelCode", "ONECARD");
        postData.Add("cardNo", txtCardNo.Text);
        postData.Add("callNo", selCalling.SelectedValue);
        postData.Add("corpNo", selCorp.SelectedValue);
        postData.Add("departNo", selDepart.SelectedValue);
        postData.Add("balunitNo", selBalUint.SelectedValue);

        return postData;
    }

    private DataTable initEmptyDataTable()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("TRADETYPE", typeof(string));//业务类型
        dt.Columns.Add("CARDNO", typeof(string));//卡号
        dt.Columns.Add("OPERATETIME", typeof(string));//操作时间
        dt.Columns.Add("OPERATEDEPARTID", typeof(string));//操作部门号
        dt.Columns.Add("OPERATESTAFFNO", typeof(string));//操作员工号
        dt.Columns.Add("POSNO", typeof(string));//POS编号
        dt.Columns.Add("PSAMNO", typeof(string));//PSAM编号

        dt.Columns["TRADETYPE"].MaxLength = 10000;
        dt.Columns["CARDNO"].MaxLength = 10000;
        dt.Columns["OPERATETIME"].MaxLength = 10000;
        dt.Columns["OPERATEDEPARTID"].MaxLength = 10000;
        dt.Columns["STAFFNO"].MaxLength = 10000;
        dt.Columns["POSNO"].MaxLength = 10000;
        dt.Columns["PSAMNO"].MaxLength = 10000;

        return dt;
    }

    private DataTable fillDataTable(HttpHelper.TradeType tradetype, Dictionary<string, string> postData)
    {
        string jsonResponse = HttpHelper.ZZPostRequest(tradetype, postData);
        //解析json
        DataTable dt = initEmptyDataTable();
        JObject deserObject = (JObject)JsonConvert.DeserializeObject(jsonResponse);
        string code = "";
        string message = "";
        foreach (JProperty itemProperty in deserObject.Properties())
        {
            string propertyName = itemProperty.Name;
            if (propertyName == "respCode")
            {
                code = itemProperty.Value.ToString();
            }
            else if (propertyName == "respDesc")
            {
                message = itemProperty.Value.ToString();
            }
            else if (propertyName == "tradeColl")
            {
                if (itemProperty.Value == null)
                {
                    context.AddMessage("查询结果为空");
                    return null;
                }
            }
        }

        if (code == "0000") //表示成功
        {
            foreach (JProperty itemProperty in deserObject.Properties())
            {
                string propertyName = itemProperty.Name;
                if (propertyName == "tradeColl")
                {
                    //DataTable赋值
                    JArray detailArray = new JArray();
                    try
                    {
                        detailArray = (JArray)itemProperty.Value;
                    }
                    catch (Exception)
                    {
                        context.AddMessage("查询结果为空");
                        return new DataTable();
                    }
                    foreach (JObject subItem in detailArray)
                    {
                        DataRow newRow = dt.NewRow();
                        foreach (JProperty subItemJProperty in subItem.Properties())
                        {
                            newRow[subItemJProperty.Name] = subItemJProperty.Value.ToString();
                        }
                        dt.Rows.Add(newRow);
                    }
                }
            }
        }
        else
        {
            context.AddError(message);
        }
        return dt;
    }
    #endregion

    #endregion

    #region protected

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (gvResult.ShowFooter && e.Row.RowType == DataControlRowType.DataRow)
        {

        }
    }

    protected void selCalling_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选择查询的行业名称后,初始化单位名称,初始化结算单元名称


        selCorp.Items.Clear();
        selDepart.Items.Clear();
        selBalUint.Items.Clear();

        InitCorp(selCalling, selCorp, "TD_M_CORPCALLUSAGE");

        //初始化结算单元(属于选择行业)名称下拉列表值

        InitBalUnit("00", selCalling);

    }
    protected void selCorp_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选择查询的单位名称后,初始化部门名称,初始化结算单元名称


        //选定单位后,设置部门下拉列表数据
        if (selCorp.SelectedValue == "")
        {
            selDepart.Items.Clear();
            InitBalUnit("00", selCalling);
            return;
        }

        //初始化单位下的部门信息

        InitDepart(selCorp, selDepart, "TD_M_DEPARTUSAGE");

        //初始化结算单元(属于选择单位)名称下拉列表值

        InitBalUnit("01", selCorp);


    }
    protected void selDepart_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选择查询的部门名称后,初始化结算单元名称


        //选定单位后,设置部门下拉列表数据
        if (selDepart.SelectedValue == "")
        {
            InitBalUnit("01", selCorp);
            return;
        }

        //初始化结算单元(属于选择部门)名称下拉列表值

        InitBalUnit("02", selDepart);

    }

    // 查询处理
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        validate();
        if (context.hasError()) return;

        DataTable data = fillDataTable(HttpHelper.TradeType.ZZOrderCardQuery, DeclarePost());
        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }

        UserCardHelper.resetData(gvResult, data);
    }


    protected void btnExport_Click(object sender, EventArgs e)
    {
        if (gvResult.Rows.Count > 0)
        {
            ExportGridView(gvResult);
        }
        else
        {
            context.AddMessage("查询结果为空，不能导出");
        }
    }

    #endregion
}
