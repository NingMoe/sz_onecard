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
using TDO.BalanceChannel;
using Common;
using TM;
using TDO.BusinessCode;

public partial class ASP_TaxiService_TS_DriverInfoQuery : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            TMTableModule tmTMTableModule = new TMTableModule();

            // 单位编码
            TD_M_CORPTDO tdoTD_M_CORPIn = new TD_M_CORPTDO();
            tdoTD_M_CORPIn.CALLINGNO = "02"; // 出租行业
            TD_M_CORPTDO[] tdoTD_M_CORPOutArr = (TD_M_CORPTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_CORPIn, typeof(TD_M_CORPTDO), "S003100114", "TD_M_CORPCALLUSAGE", null);
            ControlDeal.SelectBoxFill(selUnitName.Items, tdoTD_M_CORPOutArr, "CORP", "CORPNO", true);

            //设置司机信息列表表头
            lvwTaxiDriverInfo.DataSource = new DataTable();
            lvwTaxiDriverInfo.DataBind();
        
        }
    }


    public void lvwTaxiDriverInfo_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwTaxiDriverInfo.PageIndex = e.NewPageIndex;

        btnQuery_Click(sender, e);
    }


 

    //protected void btnReadCard_Click(object sender, EventArgs e)
    //{
    //    //txtCardNo.Text = hidCardNo.Value;
    //}

   private void ValidateQueryInput()
   {
       Validation valid = new Validation(context);

       //采集卡号非空时,数字,长度的检测
       if (txtCardNo.Text.Trim()!="")
       {
           if (Validation.strLen(txtCardNo.Text.Trim()) != 16)
               context.AddError("A003100048", txtCardNo);

           else if (!Validation.isNum(txtCardNo.Text.Trim()))
               context.AddError("A003100029", txtCardNo);
       }

       //对司机工号进行非空时, 长度、数字检验
       if (txtDriverStaffNo.Text.Trim() !="" )
       {
           if (Validation.strLen(txtDriverStaffNo.Text.Trim()) != 6)
               context.AddError("A003100003", txtDriverStaffNo);

           else if (!Validation.isNum(txtDriverStaffNo.Text.Trim()))
               context.AddError("A003100002", txtDriverStaffNo);
       }
     
       //员工姓名
       if(txtDriverName.Text.Trim() != "" )
       {
           if (Validation.strLen(txtDriverName.Text.Trim()) > 20 )
               context.AddError("A003100039", txtDriverName);
       }

       //联系电话
       if (txtDriverPhone.Text.Trim() != "" )
       {
           if (Validation.strLen(txtDriverPhone.Text.Trim()) > 20)
               context.AddError("A003100040", txtDriverPhone);
       }

       // 证件号码非空时,英数字,长度的检测
       if (txtPaperNo.Text.Trim() != "" )
       {
           if (Validation.strLen(txtPaperNo.Text.Trim()) > 20)
               context.AddError("A003100042", txtPaperNo);

           else if (!Validation.isCharNum(txtPaperNo.Text.Trim()))
               context.AddError("A003100020", txtPaperNo);
       
       }

       //车号非空时,长度,英数字的检测
       if (txtCarNo.Text.Trim() != "")
       {
           if (Validation.strLen(txtCarNo.Text.Trim()) != 5 )
               context.AddError("A003100037", txtCarNo);

           else if (!Validation.isCharNum(txtCarNo.Text.Trim()))
               context.AddError("A003100049", txtCarNo);
       }
   }


   protected void btnQuery_Click(object sender, EventArgs e)
   {
       ValidateQueryInput();
       if (context.hasError()) return;

       //查询司机信息
       lvwTaxiDriverInfo.DataSource = CreateTaxiDriverDataSource();
       lvwTaxiDriverInfo.DataBind();

       //ClearTaxiDriverQueryInput();


   }

   protected void selUnitName_SelectedIndexChanged(object sender, EventArgs e)
   {
       //选择单位后,初始化该单位下的部门信息

       if (selUnitName.SelectedValue == "")
       {
           selDeptName.Items.Clear();
           return;
       }

       TMTableModule tmTMTableModule = new TMTableModule();
       //从部门编码表(TD_M_CDEPART)中读取数据，放入下拉列表中

       TD_M_DEPARTTDO tdoTD_M_DEPARTIn = new TD_M_DEPARTTDO();
       tdoTD_M_DEPARTIn.CORPNO = selUnitName.SelectedValue;

       TD_M_DEPARTTDO[] tdoTD_M_DEPARTOutArr = (TD_M_DEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_DEPARTIn, typeof(TD_M_DEPARTTDO), null, "TD_M_DEPARTUSAGE", null);
       ControlDeal.SelectBoxFill(selDeptName.Items, tdoTD_M_DEPARTOutArr, "DEPART", "DEPARTNO", true);
   }




   private ICollection CreateTaxiDriverDataSource()
   {
       TMTableModule tmTMTableModule = new TMTableModule();

       //查询单位信息
       TD_M_CORPTDO ddoTD_M_CORPIn = new TD_M_CORPTDO();
       DataTable dataCorp = tmTMTableModule.selByPKDataTable(context, ddoTD_M_CORPIn, null, "TD_M_CORPUSAGE", null, 0);

       //查询部门信息
       TD_M_DEPARTTDO ddoTD_M_DEPARTIn = new TD_M_DEPARTTDO();
       DataTable dataDepart = tmTMTableModule.selByPKDataTable(context, ddoTD_M_DEPARTIn, null, "TD_M_DEPARTALLUSAGE", null, 0);

       //查询证件类型
       TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEIn = new TD_M_PAPERTYPETDO();
       DataTable datePaperType = tmTMTableModule.selByPKDataTable(context, ddoTD_M_PAPERTYPEIn, null, "", null,0);

       TD_M_CALLINGSTAFFTDO ddoTD_M_CALLINGSTAFFIn = new TD_M_CALLINGSTAFFTDO();
       string strSql = "SELECT calling.STAFFNO,calling.OPERCARDNO,calling.STAFFNAME,calling.STAFFSEX," +
                    "calling.STAFFPHONE,calling.STAFFPAPERTYPECODE,calling.STAFFPAPERNO,bal.CORPNO," +
                    "'' CORPNAME, '' DEPARTNAME,bal.DEPARTNO,calling.STAFFPOST,calling.STAFFADDR," +
                    "calling.STAFFEMAIL,calling.STAFFMOBILE,calling.DIMISSIONTAG,calling.CARNO," +
                    "calling.POSID,calling.COLLECTCARDNO, calling.COLLECTCARDPWD, '' PAPERTYPENAME " +
                    "FROM TD_M_CALLINGSTAFF calling, TF_TRADE_BALUNIT bal";					

       ArrayList list = new ArrayList();
       list.Add(" calling.STAFFNO =  bal.CALLINGSTAFFNO	");
       list.Add(" calling.CALLINGNO = '02' ");
       list.Add(" bal.BALUNITTYPECODE = '03' ");

       if( txtCardNo.Text.Trim() != "" )
           list.Add(" calling.COLLECTCARDNO = '" + txtCardNo.Text.Trim() + "'");

       if (txtDriverStaffNo.Text.Trim() != "")
           list.Add(" calling.STAFFNO ='" + txtDriverStaffNo.Text.Trim() + "'");

       if(txtDriverName.Text.Trim() != "" )
           list.Add(" calling.STAFFNAME ='" + txtDriverName.Text.Trim() + "'");

       if(txtDriverPhone.Text.Trim() != "" )
           list.Add(" calling.STAFFPHONE ='" + txtDriverPhone.Text.Trim() +
               "' OR calling.STAFFMOBILE ='" + txtDriverPhone.Text.Trim() + "'");

       if( selUnitName.SelectedValue != "")
           list.Add(" bal.CORPNO = '" + selUnitName.SelectedValue + "'");

       if(selDeptName.SelectedValue != "" )
           list.Add(" bal.DEPARTNO = '" + selDeptName.SelectedValue + "'");

      

	   if(txtPaperNo.Text.Trim() != "" )
           list.Add(" calling.STAFFPAPERNO = '" + txtPaperNo.Text.Trim() + "'");

       if(txtCarNo.Text.Trim() != "")
           list.Add(" calling.CARNO = '" + txtCarNo.Text.Trim() + "'");
         
       strSql += DealString.ListToWhereStr(list);

       //strSql += " order by calling.STAFFNO ";


       DataTable data = tmTMTableModule.selByPKDataTable(context, ddoTD_M_CALLINGSTAFFIn, null, strSql, 1000);

       DataRow[] dataRows = null;

       data.Columns["CORPNAME"].MaxLength = 20;
       data.Columns["DEPARTNAME"].MaxLength = 40;
       data.Columns["PAPERTYPENAME"].MaxLength = 20;

       //循环读取司机信息记录
        for (int index = 0; index < data.Rows.Count; index++)
        {

            string CorpNo = data.Rows[index]["CORPNO"].ToString();
            string DepartNo = data.Rows[index]["DEPARTNO"].ToString();
            string PaperTypeNo = data.Rows[index]["STAFFPAPERTYPECODE"].ToString();
  
            //取得单位编码对应的单位名称
            if (CorpNo != null && CorpNo.Trim() != "")
            {
                dataRows = dataCorp.Select("CORPNO = '" + CorpNo + "'");
                if (dataRows.Length == 1)
                {
                    data.Rows[index]["CORPNAME"] = dataRows[0]["CORP"];
                }
            }

            //取得部门编码对应的部门名称
            if (DepartNo != null && DepartNo.Trim() != "")
            {
                dataRows = dataDepart.Select("DEPARTNO = '" + DepartNo + "'");
                if (dataRows.Length == 1)
                {
                    data.Rows[index]["DEPARTNAME"] = dataRows[0]["DEPART"];
                }
            }

            //取得证件类型编码对应的证件类型名称
            if (PaperTypeNo != null && PaperTypeNo.Trim() != "")
            {
                dataRows = datePaperType.Select("PAPERTYPECODE = '" + PaperTypeNo + "'");
                if (dataRows.Length == 1)
                {
                    data.Rows[index]["PAPERTYPENAME"] = dataRows[0]["PAPERTYPENAME"];
                }
            }
        }

        DataView dataView = new DataView(data);
        return dataView;
   }

   protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
   {
       if (e.Row.RowType == DataControlRowType.DataRow)
       {
          //显示性别
           if (e.Row.Cells[3].Text.Trim() == "0")
           {
               e.Row.Cells[3].Text = "男";
           }
           else if (e.Row.Cells[3].Text.Trim() == "1")
           {
               e.Row.Cells[3].Text = "女";
           }
         
            
          //显示离职标志
           if (e.Row.Cells[11].Text.Trim() == "1")
           {
               e.Row.Cells[11].Text = "在职";
           }
           else if (e.Row.Cells[11].Text.Trim() == "0")
           {
                 e.Row.Cells[11].Text = "离职";
           }
        }
    }


   private void ClearTaxiDriverQueryInput()
   {
      txtCardNo.Text = "";
      selUnitName.SelectedValue = "";
      selDeptName.SelectedValue = "";
      txtDriverStaffNo.Text = "";
      txtDriverName.Text = "";
      txtDriverPhone.Text = "";
      txtPaperNo.Text = "";
      txtCarNo.Text = "";
   }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        //保存当前查询出的司机信息
        ExportGridView(lvwTaxiDriverInfo);
    }


}
