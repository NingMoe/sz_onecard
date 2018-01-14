using System;
using System.Collections.Generic;
using System.Data;
using System.Reflection;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml;
using Common;
using Master;
using Newtonsoft.Json.Linq;
using PDO.InvoiceTrade;
using TDO.InvoiceTrade;
using TDO.UserManager;
using TM;
using Newtonsoft.Json;

public partial class ASP_InvoiceTrade_IT_PrintOrder : Master.Master
{
    
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            //初始化日期

            txtBeginDate.Text = DateTime.Now.ToString("yyyyMMdd");
            txtEndDate.Text = DateTime.Now.ToString("yyyyMMdd");
            //初始化审核状态

            OrderHelper.selOrderState(context, selApprovalStatus, true);

            //初始化部门

            TMTableModule tmTMTableModule = new TMTableModule();
            TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();
            TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTOutArr = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDEDEPARTIn, typeof(TD_M_INSIDEDEPARTTDO), null, " WHERE USETAG = '1' ORDER BY DEPARTNO");
            ControlDeal.SelectBoxFill(selDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);

            InitStaffList(selStaff, "");//初始化录入员工

            //初始化表头
            initTable();
            //初始化开票项目名称
            string sqlPROJ = "select * from TD_M_INVOICEPROJECT where USETAG='1'";
            TD_M_INVOICEPROJECTTDO ddoTD_M_INVOICEPROJECTTDOIn = new TD_M_INVOICEPROJECTTDO();
            TD_M_INVOICEPROJECTTDO[] ddoTD_M_INVOICEPROJECTTDOOutArr = (TD_M_INVOICEPROJECTTDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_INVOICEPROJECTTDOIn, typeof(TD_M_INVOICEPROJECTTDO), null, sqlPROJ);
            FillDropDownList(ddlProjName1, ddoTD_M_INVOICEPROJECTTDOOutArr, "PROJECTNAME", "PROJECTNAME");
            FillDropDownList(ddlProjName2, ddoTD_M_INVOICEPROJECTTDOOutArr, "PROJECTNAME", "PROJECTNAME");
            FillDropDownList(ddlProjName3, ddoTD_M_INVOICEPROJECTTDOOutArr, "PROJECTNAME", "PROJECTNAME");
            FillDropDownList(ddlProjName4, ddoTD_M_INVOICEPROJECTTDOOutArr, "PROJECTNAME", "PROJECTNAME");
            FillDropDownList(ddlProjName5, ddoTD_M_INVOICEPROJECTTDOOutArr, "PROJECTNAME", "PROJECTNAME");
            txtAmount1.Attributes.Add("OnKeyup", "javascript:return SumInvoiceMoney();");
            txtAmount2.Attributes.Add("OnKeyup", "javascript:return SumInvoiceMoney();");
            txtAmount3.Attributes.Add("OnKeyup", "javascript:return SumInvoiceMoney();");
            txtAmount4.Attributes.Add("OnKeyup", "javascript:return SumInvoiceMoney();");
            txtAmount5.Attributes.Add("OnKeyup", "javascript:return SumInvoiceMoney();");

            detail.Visible = false;
            ckNoTaxFree.Checked = false;
            ckTax.Checked = false;
            hidReaderMoney.Value = "";//读卡器金额
            hidReaderMoney.Value = "";//市民卡B卡卡费
            txtGMF.Enabled = true;
        }
    }
    //初始化员工选项
    private void InitStaffList(DropDownList ddl, string deptNo)
    {
        if (deptNo == "")
        {
            string dBalunitNo = DeptBalunitHelper.GetDbalunitNo(context);
            if (dBalunitNo != "")//add by liuhe20120214添加对代理的权限处理
            {
                context.DBOpen("Select");
                string sql = @"SELECT STAFFNAME,STAFFNO FROM TD_M_INSIDESTAFF 
                             WHERE DIMISSIONTAG ='1' AND  DEPARTNO IN 
                            (SELECT DEPARTNO FROM TD_DEPTBAL_RELATION WHERE DBALUNITNO='" + dBalunitNo + "' AND USETAG='1')";
                DataTable table = context.ExecuteReader(sql);
                GroupCardHelper.fill(ddl, table, true);
                return;
            }
            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";
            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_DIMMISSIONTAG_USEFUL", null);
            ControlDeal.SelectBoxFill(ddl.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
            //ddl.SelectedValue = context.s_UserID;
        }
        else
        {
            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            tdoTD_M_INSIDESTAFFIn.DEPARTNO = deptNo;
            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";
            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_DEPT", null);
            ControlDeal.SelectBoxFill(ddl.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
        }
    }
    protected void selDept_Changed(object sender, EventArgs e)
    {
        InitStaffList(selStaff, selDept.SelectedValue);
    }
    public void initTable()
    {
        lvwInvoice.DataSource = new DataTable();
        lvwInvoice.DataBind();
        lvwInvoice.SelectedIndex = -1;
        lvwInvoice.DataKeyNames = new string[] { "ORDERNO", "ORDERSTATE", "TOTALMONEY", "INVOICETYPE", "GNAME", "CASHGIFTMONEY", "CHARGECARDMONEY", "CUSTOMERACCMONEY", "GARDENCARDMONEY", "RELAXCARDMONEY", "SZTCARDMONEY", "READERMONEY", "ORDERTYPE" };
    }
    private void FillDropDownList(DropDownList control, DDOBase[] data, string label, string value)
    {
        control.Items.Add(new ListItem("---请选择---", ""));
        foreach (DDOBase ddoDDOBase in data)
        {
            control.Items.Add(new ListItem(ddoDDOBase.GetString(label), ddoDDOBase.GetString(value)));
        }
    }
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        detail.Visible = false;
        
        if (!InputValidate())
            return;
        DataTable dt = SPHelper.callQuery("SP_IT_Query", context, "QueryOrder", txtOrderNo.Text.Trim(),txtGroupName.Text.Trim(),txtTotalMoney.Text.Trim(),selApprovalStatus.SelectedValue,selDept.SelectedValue,selStaff.SelectedValue, txtBeginDate.Text.Trim(), txtEndDate.Text.Trim());
        if (dt == null || dt.Rows.Count < 1)
        {
            lvwInvoice.DataSource = new DataTable();
            lvwInvoice.DataBind();
            context.AddError("未查出记录");
            return;
        }
        lvwInvoice.DataSource = dt;
        lvwInvoice.DataBind();
        lvwInvoice.SelectedIndex = -1;
        ClearData();
        txtGMF.Enabled = true;

    }
    private void  ClearData()
    {
        ddlType1.SelectedIndex = 0;
        ddlType2.SelectedIndex = 0;
        ddlType3.SelectedIndex = 0;
        ddlType4.SelectedIndex = 0;
        ddlType5.SelectedIndex = 0;
        selProj1.SelectedIndex = 0;
        selProj2.SelectedIndex = 0;
        selProj3.SelectedIndex = 0;
        selProj4.SelectedIndex = 0;
        selProj5.SelectedIndex = 0;
        txtAmount1.Text = "";
        txtAmount2.Text = "";
        txtAmount3.Text = "";
        txtAmount4.Text = "";
        txtAmount5.Text = "";
        ddlProjName1.SelectedIndex = 0;
        ddlProjName2.SelectedIndex = 0;
        ddlProjName3.SelectedIndex = 0;
        ddlProjName4.SelectedIndex = 0;
        ddlProjName5.SelectedIndex = 0;
        ddlProjName1.Enabled = true;
        ddlProjName2.Enabled = true;
        ddlProjName3.Enabled = true;
        ddlProjName4.Enabled = true;
        ddlProjName5.Enabled = true;
        selProj1.Enabled = true;
        selProj2.Enabled = true;
        selProj3.Enabled = true;
        selProj4.Enabled = true;
        selProj5.Enabled = true;
        txtGMF.Text = "";
        txtEmail.Text = "";
    }
    private bool InputValidate()
    {

        
        //校验单位名称长度
        if (!string.IsNullOrEmpty(txtGroupName.Text.Trim()))
        {
            if (txtGroupName.Text.Trim().Length > 50)
            {
                context.AddError("单位名称长度不能超过50个字符长度");
            }
        }
        if (txtTotalMoney.Text.Trim().Length > 0) //金额不为空时
        {
            if (!Validation.isPrice(txtTotalMoney.Text.Trim()))
            {
                context.AddError("金额输入不正确", txtTotalMoney);
            }
            else if (Convert.ToDecimal(txtTotalMoney.Text.Trim()) <= 0)
            {
                context.AddError("金额必须是正数", txtTotalMoney);
            }
        }
        //对开始日期和结束日期的判断

        UserCardHelper.validateDateRange(context, txtBeginDate, txtEndDate, false);
        return !(context.hasError());

    }
    public void lvwInvoice_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwInvoice.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }
    protected void lvwInvoice_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('lvwInvoice','Select$" + e.Row.RowIndex + "')");
        }
    }
    public void lvwInvoice_SelectedIndexChanged(object sender, EventArgs e)
    {
        detail.Visible = true;
        ckNoTaxFree.Checked = false;
        ckTax.Checked = false;
        double sztChargeMoney = 0.00;//市民卡B卡充值金额
        double specialMoney = 0.00;//专用发票金额
        string freeDetail = "";
        string taxDetail = "";

        //计算免税金额
        if (Convert.ToDouble(getDataKeys("CASHGIFTMONEY")) > 0)
        {
            freeDetail += "利金卡" + Convert.ToDouble(getDataKeys("CASHGIFTMONEY"))+",";
        }
        if (Convert.ToDouble(getDataKeys("CHARGECARDMONEY")) > 0)
        {
            freeDetail += "充值卡" + Convert.ToDouble(getDataKeys("CHARGECARDMONEY")) + ",";
        }
        if (Convert.ToDouble(getDataKeys("CUSTOMERACCMONEY")) > 0)
        {
            freeDetail += "专有账户" + Convert.ToDouble(getDataKeys("CUSTOMERACCMONEY")) + ",";
        }
        if (Convert.ToDouble(getDataKeys("GARDENCARDMONEY")) > 0)
        {
            freeDetail += "园林年卡" + Convert.ToDouble(getDataKeys("GARDENCARDMONEY")) + ",";
        }
        if (Convert.ToDouble(getDataKeys("RELAXCARDMONEY")) > 0)
        {
            freeDetail += "休闲年卡" + Convert.ToDouble(getDataKeys("RELAXCARDMONEY")) + ",";
        }
        //订单录入时设定的开具专用发票金额
        labSpecialInvoice.Text = SumSpecialMoney();

        //计算市民卡B卡充值金额
        if (Convert.ToDouble(getDataKeys("SZTCARDMONEY")) > 0)
        {
            string sqlSzt = "select SUM(TOTALCHARGEMONEY/100.0) TOTALCHARGEMONEY from TF_F_SZTCARDORDER where orderno = '" + getDataKeys("ORDERNO") + "'";
            context.DBOpen("Select");
            DataTable dataSzt = context.ExecuteReader(sqlSzt);
            if (dataSzt.Rows.Count > 0)
            {
                if (Convert.ToDouble(dataSzt.Rows[0]["TOTALCHARGEMONEY"])>0)
                {
                    sztChargeMoney = Convert.ToDouble(dataSzt.Rows[0]["TOTALCHARGEMONEY"]);
                    freeDetail += "市民卡B卡充值" + sztChargeMoney + ",";
                }
                
            }
            if (Convert.ToDouble(getDataKeys("SZTCARDMONEY")) - sztChargeMoney>0)
            {
                taxDetail += "市民卡B卡卡费" + (Convert.ToDouble(getDataKeys("SZTCARDMONEY")) - sztChargeMoney).ToString() + ",";

                hidSZTMoney.Value = (Convert.ToDouble(getDataKeys("SZTCARDMONEY")) - sztChargeMoney - Convert.ToDouble(labSpecialInvoice.Text.Trim())).ToString();
            }
            else
            {
                hidSZTMoney.Value = "0";
            }
        }
        //读卡器
        if (Convert.ToDouble(getDataKeys("READERMONEY")) > 0)
        {
            taxDetail += "读卡器" + Convert.ToDouble(getDataKeys("READERMONEY")) + ",";
        }

       
        //免税金额 :礼金卡，充值卡，专有账户，园林，休闲，市民卡B卡充值
        labTaxFree.Text = (Convert.ToDouble(getDataKeys("CASHGIFTMONEY")) + Convert.ToDouble(getDataKeys("CHARGECARDMONEY")) + Convert.ToDouble(getDataKeys("CUSTOMERACCMONEY")) + Convert.ToDouble(getDataKeys("GARDENCARDMONEY")) + Convert.ToDouble(getDataKeys("RELAXCARDMONEY")) + sztChargeMoney).ToString("0.00");//免税部分订单金额
        //含税金额
        labTax.Text = (Convert.ToDouble(getDataKeys("TOTALMONEY")) - Convert.ToDouble(labTaxFree.Text.Trim())).ToString("0.00");
        //显示已开票金额
        string sql = "select 1 from TF_F_INVOICEORDER where orderno = '" + getDataKeys("ORDERNO") + "' and USETAG='1'";
        context.DBOpen("Select");
        DataTable data = context.ExecuteReader(sql);
        if (data.Rows.Count > 0)
        {
            string sqlMoney = "select SUM(nvl(MONEY,0)/100.0)  MONEY from TF_F_INVOICEORDER where orderno = '" + getDataKeys("ORDERNO") + "' and USETAG='1'";
            DataTable dt = context.ExecuteReader(sqlMoney);
            labMoney.Text = Convert.ToDouble(dt.Rows[0]["MONEY"]).ToString("0.00");//已经开票金额

        }
        else
        {
            labMoney.Text = "0.00";
        }
        //明细
        if (freeDetail!="")
        {
            freeDetail = freeDetail.Substring(0, freeDetail.Length - 1);//免税去除最后一个逗号
        }
        if (taxDetail != "")
        {
            taxDetail = taxDetail.Substring(0, taxDetail.Length - 1);//含税去除最后一个逗号
        }
        labFreeDetail.Text = freeDetail;
        labTaxDetail.Text = taxDetail;
        hidReaderMoney.Value = getDataKeys("READERMONEY").Trim();
        labAllowMoney.Text = (Convert.ToDouble(getDataKeys("TOTALMONEY")) - Convert.ToDouble(labMoney.Text.Trim()) - Convert.ToDouble(labSpecialInvoice.Text.Trim())).ToString("0.00");
        ClearData();
        if (getDataKeys("ORDERTYPE")=="个人")
        {
            txtGMF.Enabled = false;
        }
        else
        {
            txtGMF.Enabled = true;
        }

    }
    private  string SumSpecialMoney()
    {
        double sumMoney = 0.00;
        string sqlSzt = "select t.unitprice/100.0 unitprice,t.count from tf_f_sztcardorder t where orderno = '" + getDataKeys("ORDERNO") + "' and t.istax='1'";
        context.DBOpen("Select");
        DataTable dataSzt = context.ExecuteReader(sqlSzt);
        if (dataSzt.Rows.Count > 0)
        {
            for(int i=0;i<dataSzt.Rows.Count;i++)
            {
                sumMoney += Convert.ToDouble(dataSzt.Rows[i]["unitprice"])*
                            Convert.ToInt32(dataSzt.Rows[i]["count"]);
            }
            return sumMoney.ToString("0.00");
        }
        return sumMoney.ToString("0.00");
    }
    public String getDataKeys(string keysname)
    {
        string value = lvwInvoice.DataKeys[lvwInvoice.SelectedIndex][keysname].ToString();

        return value == "" ? "" : value;
    }
    /// <summary>
    /// 校验开票类型

    /// </summary>
    private void ValidInvoice()
    {
        //发票项目校验
        WebControl[] goods = new WebControl[5] { ddlType1, ddlType2, ddlType3, ddlType4, ddlType5 };
        WebControl[] projs = new WebControl[5] { selProj1, selProj2, selProj3, selProj4, selProj5 };
        WebControl[] fees = new WebControl[5] { txtAmount1, txtAmount2, txtAmount3,txtAmount4, txtAmount5 };
        WebControl[] invoicepro = new WebControl[5] { ddlProjName1, ddlProjName2, ddlProjName3, ddlProjName4, ddlProjName5 };
        if (!validateItem(goods, projs, fees, invoicepro))
        {
                return;
         }
    }

    //判断商品名称是否选择一样
    //private bool ValidateGoods()
    //{
    //    if (ddlType1.SelectedValue != "" && ddlType2.SelectedValue!="")
    //    {
    //       if (ddlType1.SelectedValue == ddlType2.SelectedValue)
    //       {
    //           return false;
    //       }  
    //    }
    //    if (ddlType1.SelectedValue != "" && ddlType3.SelectedValue != "")
    //    {
    //        if (ddlType1.SelectedValue == ddlType3.SelectedValue)
    //        {
    //            return false;
    //        }
    //    }
    //    if (ddlType1.SelectedValue != "" && ddlType4.SelectedValue != "")
    //    {
    //        if (ddlType1.SelectedValue == ddlType4.SelectedValue)
    //        {
    //            return false;
    //        }
    //    }
    //    if (ddlType1.SelectedValue != "" && ddlType5.SelectedValue != "")
    //    {
    //        if (ddlType1.SelectedValue == ddlType5.SelectedValue)
    //        {
    //            return false;
    //        }
    //    }
    //    if (ddlType2.SelectedValue != "" && ddlType3.SelectedValue != "")
    //    {
    //        if (ddlType2.SelectedValue == ddlType3.SelectedValue)
    //        {
    //            return false;
    //        }
    //    }
    //    if (ddlType2.SelectedValue != "" && ddlType4.SelectedValue != "")
    //    {
    //        if (ddlType2.SelectedValue == ddlType4.SelectedValue)
    //        {
    //            return false;
    //        }
    //    }
    //    if (ddlType2.SelectedValue != "" && ddlType5.SelectedValue != "")
    //    {
    //        if (ddlType2.SelectedValue == ddlType5.SelectedValue)
    //        {
    //            return false;
    //        }
    //    }
    //    if (ddlType3.SelectedValue != "" && ddlType4.SelectedValue != "")
    //    {
    //        if (ddlType3.SelectedValue == ddlType4.SelectedValue)
    //        {
    //            return false;
    //        }
    //    }
    //    if (ddlType3.SelectedValue != "" && ddlType5.SelectedValue != "")
    //    {
    //        if (ddlType3.SelectedValue == ddlType5.SelectedValue)
    //        {
    //            return false;
    //        }
    //    }
    //    if (ddlType4.SelectedValue != "" && ddlType5.SelectedValue != "")
    //    {
    //        if (ddlType4.SelectedValue == ddlType5.SelectedValue)
    //        {
    //            return false;
    //        }
    //    }
    //    return true;


    //}

    //判断开票金额
    private void ValidateMoney()
    {
        //判断开票总额是否超出
        double totalmoney = Convert.ToDouble(getDataKeys("TOTALMONEY"));
        double leftmoney = totalmoney - Convert.ToDouble(labMoney.Text.Trim()) - Convert.ToDouble(labSpecialInvoice.Text.Trim());
        if (Convert.ToDouble(labInvoiceMoney.Text.Trim()) > 0)
        {
            if (Convert.ToDouble(labInvoiceMoney.Text.Trim()) > totalmoney)
            {
                context.AddError("开票总额不能超出订单总金额");
            }
            //判断开票金额是否大于订单总金额-已开票金额-专用发票金额
            else if (Convert.ToDouble(labInvoiceMoney.Text.Trim()) > leftmoney)
            {
                context.AddError("开票总额不能超出订单总金额-已开票金额-专用发票金额");
            }
            if (ckNoTaxFree.Checked == true && ckTax.Checked==false)//只勾选开票免税金额时
            {
                if (Convert.ToDouble(labInvoiceMoney.Text.Trim()) > Convert.ToDouble(labTaxFree.Text.Trim()))
                {
                    context.AddError("开票总额不能超出勾选订单金额");
                }
            }
        }
        else
        {
            context.AddError("开票总额不能小于等于0");
        }
       
    }
    //判断所选商品名称是否与订单一致
    private void GoodsCompare()
    {
        double totalmoney = Convert.ToDouble(getDataKeys("TOTALMONEY"));
        

            if (ckNoTaxFree.Checked == true && ckTax.Checked == false)//只勾选免税时验证商品名称是否符合明细
            {
                if (ddlType1.SelectedValue != "")
                {
                    string type = ddlType1.SelectedValue;
                    if (!(labFreeDetail.Text.Trim().Contains(type)))
                    {
                        context.AddError("请选择和订单相应的商品项目", ddlType1);
                    }
                }
                if (ddlType2.SelectedValue != "")
                {
                    string type = ddlType2.SelectedValue;
                    if (!(labFreeDetail.Text.Trim().Contains(type)))
                    {
                        context.AddError("请选择和订单相应的商品项目", ddlType2);
                    }
                }
                if (ddlType3.SelectedValue != "")
                {
                    string type = ddlType3.SelectedValue;
                    if (!(labFreeDetail.Text.Trim().Contains(type)))
                    {
                        context.AddError("请选择和订单相应的商品项目", ddlType3);
                    }
                }
                if (ddlType4.SelectedValue != "")
                {
                    string type = ddlType4.SelectedValue;
                    if (!(labFreeDetail.Text.Trim().Contains(type)))
                    {
                        context.AddError("请选择和订单相应的商品项目", ddlType4);
                    }
                }
                if (ddlType5.SelectedValue != "")
                {
                    string type = ddlType5.SelectedValue;
                    if (!(labFreeDetail.Text.Trim().Contains(type)))
                    {
                            context.AddError("请选择和订单相应的商品项目", ddlType5);
                    }
                }
            }
            if (ckNoTaxFree.Checked == false && ckTax.Checked == true)//只勾选征税时验证商品名称是否符合明细
            {
                
                if (ddlType1.SelectedValue != "")
                {
                    string type = ddlType1.SelectedValue;
                    if (!(labTaxDetail.Text.Trim().Contains(type)))
                    {
                        context.AddError("请选择和订单相应的商品项目", ddlType1);
                    }
                }
                if (ddlType2.SelectedValue != "")
                {
                    string type = ddlType2.SelectedValue;
                    if (!(labTaxDetail.Text.Trim().Contains(type)))
                    {
                        context.AddError("请选择和订单相应的商品项目", ddlType2);
                    }
                }
                if (ddlType3.SelectedValue != "")
                {
                    string type = ddlType3.SelectedValue;
                    if (!(labTaxDetail.Text.Trim().Contains(type)))
                    {
                        context.AddError("请选择和订单相应的商品项目", ddlType3);
                    }
                }
                if (ddlType4.SelectedValue != "")
                {
                    string type = ddlType4.SelectedValue;
                    if (!(labTaxDetail.Text.Trim().Contains(type)))
                    {
                        context.AddError("请选择和订单相应的商品项目", ddlType4);
                    }
                }
                if (ddlType5.SelectedValue != "")
                {
                    string type = ddlType5.SelectedValue;
                    if (!(labTaxDetail.Text.Trim().Contains(type)))
                    {
                        context.AddError("请选择和订单相应的商品项目", ddlType5);
                    }
                }
                if (hidSZTMoney.Value!="")
                {
                  if (!CheckTypeTax())
                  {
                    context.AddError("请填写和含税部分明细相应的市民卡B卡卡费金额");
                  }  
                }
                if (hidReaderMoney.Value != "" && hidReaderMoney.Value != "0")
                {
                  if (!CheckReaderTax())
                  {
                    context.AddError("请填写和含税部分明细相应的读卡器金额");
                  }  
                }
                
            }
            if (ckNoTaxFree.Checked == true && ckTax.Checked == true)//同时勾选免税和征税时验证商品名称是否符合明细
            {
                if (ddlType1.SelectedValue != "")
                {
                    string type = ddlType1.SelectedValue;
                    if (!(labFreeDetail.Text.Trim().Contains(type) || labTaxDetail.Text.Trim().Contains(type)))
                    {
                        context.AddError("请选择和订单相应的商品项目", ddlType1);
                    }
                }
                if (ddlType2.SelectedValue != "")
                {
                    string type = ddlType2.SelectedValue;
                    if (!(labFreeDetail.Text.Trim().Contains(type) || labTaxDetail.Text.Trim().Contains(type)))
                    {
                        context.AddError("请选择和订单相应的商品项目", ddlType2);
                    }
                }
                if (ddlType3.SelectedValue != "")
                {
                    string type = ddlType3.SelectedValue;
                    if (!(labFreeDetail.Text.Trim().Contains(type) || labTaxDetail.Text.Trim().Contains(type)))
                    {
                        context.AddError("请选择和订单相应的商品项目", ddlType3);
                    }
                }
                if (ddlType4.SelectedValue != "")
                {
                    string type = ddlType4.SelectedValue;
                    if (!(labFreeDetail.Text.Trim().Contains(type) || labTaxDetail.Text.Trim().Contains(type)))
                    {
                        context.AddError("请选择和订单相应的商品项目", ddlType4);
                    }
                }
                if (ddlType5.SelectedValue != "")
                {
                    string type = ddlType5.SelectedValue;
                    if (!(labFreeDetail.Text.Trim().Contains(type) || labTaxDetail.Text.Trim().Contains(type)))
                    {
                        context.AddError("请选择和订单相应的商品项目", ddlType5);
                    }
                }
                if (hidSZTMoney.Value != "")
                {
                    if (!CheckTypeTax())
                    {
                        context.AddError("请填写和含税部分明细相应的市民卡B卡卡费金额");
                    }
                }
                if (hidReaderMoney.Value != "" && hidReaderMoney.Value != "0")
                {
                    if (!CheckReaderTax())
                    {
                        context.AddError("请填写和含税部分明细相应的读卡器金额");
                    }
                }
            }
            if (labMoney.Text != "0.00" && ckTax.Checked == true)//已开过票且勾选征税的
            {
                string sql = "select 1 from tf_f_electronicinvoice t where t.orderno = '" + getDataKeys("ORDERNO") + "'and t.usetag='1' and ((t.proj1='市民卡B卡卡费' or t.proj1='读卡器') or (t.proj2='市民卡B卡卡费' or t.proj2='读卡器')or (t.proj3='市民卡B卡卡费' or t.proj3='读卡器')or  (t.proj4='市民卡B卡卡费' or t.proj4='读卡器') or (t.proj5='市民卡B卡卡费' or t.proj5='读卡器'))";
                  context.DBOpen("Select");
                  DataTable data = context.ExecuteReader(sql);
                  if (data.Rows.Count > 0)
                  {
                      if (ddlType1.SelectedValue.Contains("市民卡B卡卡费") || ddlType1.SelectedValue.Contains("读卡器") || ddlType2.SelectedValue.Contains("市民卡B卡卡费") || ddlType2.SelectedValue.Contains("读卡器") || ddlType3.SelectedValue.Contains("市民卡B卡卡费") || ddlType3.SelectedValue.Contains("读卡器") || ddlType4.SelectedValue.Contains("市民卡B卡卡费") || ddlType4.SelectedValue.Contains("读卡器") || ddlType5.SelectedValue.Contains("市民卡B卡卡费") || ddlType5.SelectedValue.Contains("读卡器"))
                      {
                          context.AddError("含税部分订单已经开过票,不可以再次勾选开票",ckTax);
                      }
                  }
            }

    }

   
    private bool CheckTypeTax()
    {

        if (labTaxDetail.Text.Trim().Contains("市民卡B卡卡费"))
        {
            //if (type1 == "市民卡B卡卡费" && money==hidSZTMoney.Value)
            //{
            //    return true;
            //}
            double money = 0.00;
            if (ddlType1.SelectedValue == "市民卡B卡卡费")
            {
                money += Convert.ToDouble(txtAmount1.Text.Trim());
            }
            if (ddlType2.SelectedValue == "市民卡B卡卡费")
            {
                money += Convert.ToDouble(txtAmount2.Text.Trim());
            }
            if (ddlType3.SelectedValue == "市民卡B卡卡费")
            {
                money += Convert.ToDouble(txtAmount3.Text.Trim());
            }
            if (ddlType4.SelectedValue == "市民卡B卡卡费")
            {
                money += Convert.ToDouble(txtAmount4.Text.Trim());
            }
            if (ddlType5.SelectedValue == "市民卡B卡卡费")
            {
                money += Convert.ToDouble(txtAmount5.Text.Trim());
            }
            if (money == Convert.ToDouble(hidSZTMoney.Value))
            {
                return true;
            }

        }
       

        return false;
    }
    private bool CheckReaderTax()
    {
        if (labTaxDetail.Text.Trim().Contains("读卡器"))
        {
            //if (type1 == "读卡器" && money==hidReaderMoney.Value)
            //{
            //    return true;
            //}
            double readermoney = 0.00;
            if (ddlType1.SelectedValue == "读卡器")
            {
                readermoney += Convert.ToDouble(txtAmount1.Text.Trim());
            }
            if (ddlType2.SelectedValue == "读卡器")
            {
                readermoney += Convert.ToDouble(txtAmount2.Text.Trim());
            }
            if (ddlType3.SelectedValue == "读卡器")
            {
                readermoney += Convert.ToDouble(txtAmount3.Text.Trim());
            }
            if (ddlType4.SelectedValue == "读卡器")
            {
                readermoney += Convert.ToDouble(txtAmount4.Text.Trim());
            }
            if (ddlType5.SelectedValue == "读卡器")
            {
                readermoney += Convert.ToDouble(txtAmount5.Text.Trim());
            }
            if (readermoney == Convert.ToDouble(hidReaderMoney.Value))
            {
                return true;
            }

        }
        return false;

    }

    private void TaxCompareMoney()
    {
        if (ckTax.Checked == true)//勾选征税时验证是否一次性开具发票
        {
            double money = 0.00;
            if (ddlType1.SelectedValue == "市民卡B卡卡费" || ddlType1.SelectedValue == "读卡器")
            {
                money += Convert.ToDouble(txtAmount1.Text.Trim());
            }
            if (ddlType2.SelectedValue == "市民卡B卡卡费" || ddlType2.SelectedValue == "读卡器")
            {
                money += Convert.ToDouble(txtAmount2.Text.Trim());
            }
            if (ddlType3.SelectedValue == "市民卡B卡卡费" || ddlType3.SelectedValue == "读卡器")
            {
                money += Convert.ToDouble(txtAmount3.Text.Trim());
            }
            if (ddlType4.SelectedValue == "市民卡B卡卡费" || ddlType4.SelectedValue == "读卡器")
            {
                money += Convert.ToDouble(txtAmount4.Text.Trim());
            }
            if (ddlType5.SelectedValue == "市民卡B卡卡费" || ddlType5.SelectedValue == "读卡器")
            {
                money += Convert.ToDouble(txtAmount5.Text.Trim());
            }
            if (money < Convert.ToDouble(labTax.Text.Trim()) - Convert.ToDouble(labSpecialInvoice.Text.Trim()))
            {
                context.AddError("征税部分订单金额与所开具金额不符,征税部分金额限制一次性开票");
            }
            else if (money > Convert.ToDouble(labTax.Text.Trim()) - Convert.ToDouble(labSpecialInvoice.Text.Trim()))
            {
                context.AddError("征税部分订单金额与所开具金额不符");
            }
        }
    }

    private void GetInvoiceMoney()
    {
        double total = 0;
        if (txtAmount1.Text.ToString()!="")
        {
            total = total + Convert.ToDouble(txtAmount1.Text.ToString());
        }
        if (txtAmount2.Text.ToString() != "")
        {
            total = total + Convert.ToDouble(txtAmount2.Text.ToString());
        }
        if (txtAmount3.Text.ToString() != "")
        {
            total = total + Convert.ToDouble(txtAmount3.Text.ToString());
        }
        if (txtAmount4.Text.ToString() != "")
        {
            total = total + Convert.ToDouble(txtAmount4.Text.ToString());
        }
        if (txtAmount5.Text.ToString() != "")
        {
            total = total + Convert.ToDouble(txtAmount5.Text.ToString());
        }
       
        labInvoiceMoney.Text = total.ToString();
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        
        if (lvwInvoice.SelectedIndex == -1)
        {
            context.AddError("未选择订单");
            return;
        }
        // 开票输入信息校验
        SubmitValidate();
        //if(!ValidateGoods())
        //{
        //    context.AddError("商品名称不允许选择一样的");
        //}
        if (ckNoTaxFree.Checked== false && ckTax.Checked==false )
        {
            context.AddError("未勾选订单明细");
        }
        else if (ckNoTaxFree.Checked == true && labTaxFree.Text=="0.00")
        {
            context.AddError("不可勾选免税部分订单金额为0的部分");
        }
        else if (ckTax.Checked == true && labTax.Text == "0.00")
        {
            context.AddError("不可勾选含税部分订单金额为0的部分");
        }
        GetInvoiceMoney();//计算开票总额
        ValidateMoney();
        if (context.hasError())
        {
            return;
        }
        GoodsCompare();
        TaxCompareMoney();
        
        if (context.hasError())
        {
            return;
        }
        string isFree = "";
        string xsfName = "";//销售方名称
        string bankName = "";
        string bankAccount = "";
        if (Convert.ToDecimal(SumTax())>0 &&(ckTax.Checked==true && ckNoTaxFree.Checked==false))
        {
            isFree = "1";//征税
            xsfName = "苏州市民卡有限公司";//征税时用苏州市民卡有限公司
            bankName = "苏州银行三香路支行";
            bankAccount = "3205010071120167000003";
        }
        else
        {
            isFree = "0";//免税
            xsfName = "苏州市民卡有限公司";//免税时用苏州市民卡有限公司客户备付金
            bankName = "招商银行相城支行";
            bankAccount = "512902397110818";
        }


        //调用电子发票开票接口
        string param = SetupXml(xsfName, bankName, bankAccount);//传入参数 XML格式


        string response = HttpRequestUtility.Post("http://192.168.8.68:5001/dzfp/fpkj", param);

        string xml = response.Replace("\r", "").Replace("\n", "");
        string returncode = "";
        string returnmessage = "";
        string fpqqlsh = "";
        string fpHm = "";
        string fpDm = "";
        string date = "";
        string jym = "";
        string pdfurl = "";
        if (!string.IsNullOrEmpty(xml))
        {
            //SP_IT_OpenInvioceResponse queryResponse = JsonConvert.DeserializeObject<SP_IT_OpenInvioceResponse>(response);
            XmlDocument dom = new XmlDocument();
            try
            {
                dom.LoadXml(xml);
            }
            catch (Exception ex)
            {
                context.AddError(xml);//提示调用接口失败原因
                return;
            }
            //dom.LoadXml(xml);
            XmlNodeList xnList = dom.SelectNodes(@"//xml");
            foreach (XmlNode node in xnList)
            {
                XmlNodeList rsp = node.ChildNodes;
                foreach (XmlNode n in rsp)
                {
                    if (n.Name == "returnCode")
                    {
                        returncode = n.InnerText;
                    }
                    else if (n.Name == "returnMessage")
                    {
                        returnmessage = n.InnerText;
                    }
                    else if (n.Name == "FPQQLSH")
                    {
                        fpqqlsh = n.InnerText;
                    }
                    else if (n.Name == "FP_DM")
                    {
                        fpDm = n.InnerText;
                    }
                    else if (n.Name == "FP_HM")
                    {
                        fpHm = n.InnerText;
                    }
                    else if (n.Name == "KPRQ")
                    {
                        date = n.InnerText;
                    }
                    else if (n.Name == "JYM")
                    {
                        jym = n.InnerText;
                    }
                    else if (n.Name == "PDF_URL")
                    {
                        pdfurl = n.InnerText;
                    }
                }
            }

            //JObject resObject = (JObject)JsonConvert.DeserializeObject(response);
            //string returncode = resObject["returnCode"].ToString();
            //string returnmessage = resObject["returnMessage"].ToString();
            //string fpqqlsh = resObject["FPQQLSH"].ToString();
            //string fpHm = resObject["FP_HM"].ToString();
            //string fpDm = resObject["FP_DM"].ToString();
            //string date = resObject["KPRQ"].ToString();
            //string pdfurl = resObject["PDF_URL"].ToString();
            if (returncode == "0000")//0000:成功
            {
                //记录台帐和开票信息
                context.SPOpen();
                context.AddField("P_TRADEID").Value = fpqqlsh;      //发票请求流水号 queryResponse.FPQQLSH
                context.AddField("P_ORDERNO").Value = getDataKeys("ORDERNO");     //订单号
                context.AddField("P_INVOICENO").Value = fpHm;      //发票号码
                context.AddField("P_VOLUMENO").Value = fpDm;      //发票代码
                context.AddField("P_PDF").Value = pdfurl;         //PDF下载地址
                context.AddField("P_PAYER").Value = getDataKeys("GNAME");
                context.AddField("P_isFree").Value = isFree;//0:免税
                context.AddField("P_payeeName").Value = xsfName;//收款方
                context.AddField("p_taxNo").Value = "9132050874558352XW";     //纳税人识别号
                context.AddField("p_drawer").Value = context.s_UserName;     //开票人

                context.AddField("p_date").Value = date;     //开票日期date.Substring(0, 8)

                context.AddField("p_amount").Value = Convert.ToInt32(Convert.ToDecimal(labInvoiceMoney.Text) * 100);   //开票金额
                context.AddField("p_note").Value = txtRemark.Text.Trim();//附注
                context.AddField("p_proj1").Value = ddlType1.SelectedValue;
                context.AddField("p_fee1").Value = (txtAmount1.Text.Trim() == "") ? 0 : Convert.ToInt32(Convert.ToDecimal(txtAmount1.Text.ToString()) * 100);
                context.AddField("p_proj2").Value = ddlType2.SelectedValue;
                context.AddField("p_fee2").Value = (txtAmount2.Text.Trim() == "") ? 0 : Convert.ToInt32(Convert.ToDecimal(txtAmount2.Text.ToString()) * 100);
                context.AddField("p_proj3").Value = ddlType3.SelectedValue;
                context.AddField("p_fee3").Value = (txtAmount3.Text.Trim() == "") ? 0 : Convert.ToInt32(Convert.ToDecimal(txtAmount3.Text.ToString()) * 100);
                context.AddField("p_proj4").Value = ddlType4.SelectedValue; ;
                context.AddField("p_fee4").Value = (txtAmount4.Text.Trim() == "") ? 0 : Convert.ToInt32(Convert.ToDecimal(txtAmount4.Text.ToString()) * 100);
                context.AddField("p_proj5").Value = ddlType5.SelectedValue; ;
                context.AddField("p_fee5").Value = (txtAmount5.Text.Trim() == "") ? 0 : Convert.ToInt32(Convert.ToDecimal(txtAmount5.Text.ToString()) * 100); ;
                context.AddField("p_bankName").Value = bankName;//苏信开户行
                context.AddField("p_bankAccount").Value = bankAccount;//苏信开户行

                context.AddField("p_validatecode").Value = jym;//验证码
                context.AddField("p_CallingCode").Value = "";//行业代码
                context.AddField("p_CallingName").Value = "";//行业名称


                bool ok = context.ExecuteSP("SP_IT_PrintOrder");
                if (ok)
                {
                    context.AddMessage("订单开票成功！");
                    detail.Visible = false;
                    lvwInvoice.SelectedIndex = -1;
                    hidReaderMoney.Value = "";//读卡器金额
                    hidSZTMoney.Value = "";//市民卡B卡卡费
                    txtEmail.Text = "";
                    txtGMF.Text = "";
                    txtRemark.Text = "";
                    txtGMF.Enabled = true;

                }
            }
            else
            {
                context.AddError(returncode + returnmessage);
            }
        }
        else
        {
            context.AddError("http接口返回值为空");
        }
        //context.SPOpen();
        //context.AddField("P_TRADEID").Value = "SZSMKG20171212161950";      //发票请求流水号
        //context.AddField("P_ORDERNO").Value = getDataKeys("ORDERNO");     //订单号
        //context.AddField("P_INVOICENO").Value = "21078449";      //发票号码
        //context.AddField("P_VOLUMENO").Value = "050003523333";      //发票代码

        ////context.AddField("p_date").Value = DateTime.ParseExact("20171212162233".Substring(0,8), "yyyyMMdd", null);
        //context.AddField("p_date").Value = "20171225152448";//开票日期 
        //context.AddField("P_PDF").Value = "http://dev.fapiao.com:19080/dzfp-wx/pdf/download?request=e5uhf8WETIOMgaa2cCUMtk2ijkA3pJqH5gEV4juzSg-c46D831NQuIMlhdAvFCkWpkR-l1XWw206Uf4EgDDNqA__%5EdhGCdiIIf</PDF_URL><SP_URL>http://testwx.fapiao.com/fpt-wechat/wxaddcard.do?code=%2BaUs%2FiDd4lZo2fl5vltTaZSUrE7MhWc12EO7Yhtilf8IFhAa8APay0VyIeRaf1IUj3GNilk06GBI%0AgMSdzo4NBA%3D%3D";         //PDF下载地址
        //context.AddField("P_PAYER").Value = "个人";
        //context.AddField("P_isFree").Value = "0";//免税
        //context.AddField("P_payeeName").Value = "苏州市民卡有限公司客户备付金";//收款方
        //context.AddField("p_taxNo").Value = "9132050874558352XW";     //纳税人识别号
        //context.AddField("p_drawer").Value = context.s_UserName;     //开票人


        //context.AddField("p_amount").Value = Convert.ToInt32(Convert.ToDecimal(labInvoiceMoney.Text) * 100);    //开票金额
        //context.AddField("p_note").Value = txtRemark.Text.Trim();//附注
        //context.AddField("p_proj1").Value = selProj1.SelectedValue;
        //context.AddField("p_fee1").Value = (txtAmount1.Text.Trim() == "") ? 0 : Convert.ToInt32(Convert.ToDecimal(txtAmount1.Text.ToString()) * 100);
        //context.AddField("p_proj2").Value = selProj2.SelectedValue;
        //context.AddField("p_fee2").Value = (txtAmount2.Text.Trim() == "") ? 0 : Convert.ToInt32(Convert.ToDecimal(txtAmount2.Text.ToString()) * 100);
        //context.AddField("p_proj3").Value = selProj3.SelectedValue;
        //context.AddField("p_fee3").Value = (txtAmount3.Text.Trim() == "") ? 0 : Convert.ToInt32(Convert.ToDecimal(txtAmount3.Text.ToString()) * 100);
        //context.AddField("p_proj4").Value = "";
        //context.AddField("p_fee4").Value = "";
        //context.AddField("p_proj5").Value = "";
        //context.AddField("p_fee5").Value = "";
        //context.AddField("p_bankName").Value = "";//苏信开户行
        //context.AddField("p_bankAccount").Value = "";//苏信开户行

        //context.AddField("p_validatecode").Value = "09712481733021310844";//验证码
        //context.AddField("p_CallingCode").Value = "";//行业代码
        //context.AddField("p_CallingName").Value = "";//行业名称


        //bool ok = context.ExecuteSP("SP_IT_PrintOrder");
        //if (ok)
        //{
        //    context.AddMessage("订单开票成功！");
        //    detail.Visible = false;
        //    lvwInvoice.SelectedIndex = -1;

        //}
    }
    private void SubmitValidate()
    {
        
        string orderstate = getDataKeys("ORDERSTATE").Substring(0, 2);
        if (orderstate != "08")
        {
            context.AddError("订单状态不是完成确认状态，不可开票");
        }
        string invoicetype = getDataKeys("INVOICETYPE");
        if (invoicetype != "电子开票")
        {
            context.AddError("开票方式不是电子开票，不可开票");
        }
        //开票方式校验

        ValidInvoice();


        //对电子邮件进行格式检验
        if (txtEmail.Text.Trim()=="")
        {
            context.AddError("请填写邮箱地址",txtEmail);
        }
        else
        {
            if (Validation.strLen(txtEmail.Text.Trim()) > 30)
            {
                context.AddError("邮件地址过长(不能超过30位)", txtEmail);

            }

            bool ret = Regex.IsMatch(txtEmail.Text.Trim(), @"^([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}" +
                 @"\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\" +
                 @".)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$");
            if (!ret)
            {
                context.AddError("邮件地址格式非法", txtEmail);
            }
        }
        //校验备注
        if (!string.IsNullOrEmpty(txtRemark.Text.Trim()))
        {
            if (Validation.strLen(txtRemark.Text.Trim()) > 200)
                context.AddError("附注不能超过200字符长度", txtRemark);
        }

        //购买方纳税人识别号
        if (getDataKeys("ORDERTYPE") == "单位")
        {
            if (txtGMF.Text.Trim() == "")
            {
             context.AddError("请填写购买方纳税人识别号", txtGMF);
             }
            else if (!Validation.isCharNum(txtGMF.Text.Trim()))
            context.AddError("购买方纳税人识别号必须为英数", txtGMF);
        
        }
        
        
    }


    private string SetupXml(string xsfName,string bankName,string  bankAccount)
    {
        StringBuilder xml = new StringBuilder();

        //报文
        xml.AppendLine("<REQUEST_COMMON_FPKJ class=\"REQUEST_COMMON_FPKJ\">");

        string id = "SZSMKG"+DateTime.Now.ToString("yyyyMMddHHmmss");  //发票请求流水号长度20，流水号前以公司名称前缀
        string type = "0";               //开票类型 0：蓝票          
        string nsrNo = "9132050874558352XW";         //销售方纳税人识别号 :9132050874558352XW  测试：110109500321655
        string saleGroupName = xsfName;  //销售方名称;苏州市民卡有限公司  测试：百旺电子测试2
        string saleGroupAddress = "苏州市人民路3118号、0512-62888688";   //销售方地址电话  必填
        string saleGroupBank = bankName + "、" + bankAccount;   //销售方银行帐号 不必填 苏州银行三香路支行、3205010071120167000003
        string payNo =txtGMF.Text.Trim();              //购买方纳税人识别号 不必填
        string payman = getDataKeys("GNAME");  //购买方名称  必填
        string payAddress = "";         //购买方地址电话 不必填
        string payBank = "";           //购买方银行帐号 不必填
        string payPhoneNo = "";        //购买方手机号 不必填
        string payEmail = txtEmail.Text.Trim();   //购买方邮箱 不必填
        string fptZH = "";             //购买发票通账户 不必填
        string wxOpenId = "";           //微信OpenId 不必填
        string kpPerson = context.s_UserName;  //开票人 必填
        string skPerson = context.s_UserName;         //收款人 不必填
        string fhPerson = "潘琦峰";          //复核人 不必填
        string volumeNo = "";          //原发票代码 不必填
        string invioceNo = "";         //原发票号码 不必填
        string jshj = labInvoiceMoney.Text.Trim();  //价税合计         必填 ：labInvoiceMoney.Text.Trim()
        string hjje = (Convert.ToDouble(labInvoiceMoney.Text.Trim()) - Convert.ToDouble(SumTax())).ToString();              //合计金额 不含税 100  必填 (Convert.ToDouble(labInvoiceMoney.Text.Trim()) - Convert.ToDouble(SumTax())).ToString();              //合计金额 不含税 100  必填
        string hjse = SumTax();            //合计税额 17         必填    SumTax();  
        string kce = "";              //扣除额
        string remark = txtRemark.Text.Trim();        //备注
        string callingName = "0";          //行业类型 0:商业 1:其他     必填

        xml.AppendLine(string.Format("<FPQQLSH>{0}</FPQQLSH>", id));//发票请求流水号
        xml.AppendLine(string.Format("<KPLX>{0}</KPLX>", type));    //开票类型
        xml.AppendLine(string.Format("<BMB_BBH>{0}</BMB_BBH>", ""));    //
        xml.AppendLine(string.Format("<ZSFS>{0}</ZSFS>", "0"));//征税方式 0：普通征税        
        xml.AppendLine(string.Format("<XSF_NSRSBH>{0}</XSF_NSRSBH>", nsrNo));//销售方纳税人识别号
        xml.AppendLine(string.Format("<XSF_MC>{0}</XSF_MC>", saleGroupName));//销售方名称
        xml.AppendLine(string.Format("<XSF_DZDH>{0}</XSF_DZDH>", saleGroupAddress));//销售方地址电话
        xml.AppendLine(string.Format("<XSF_YHZH>{0}</XSF_YHZH>", saleGroupBank));//销售方银行帐号

        xml.AppendLine(string.Format("<GMF_NSRSBH>{0}</GMF_NSRSBH>", payNo));//购买方纳税人识别号
        xml.AppendLine(string.Format("<GMF_MC>{0}</GMF_MC>", payman));//购买方名称
        xml.AppendLine(string.Format("<GMF_DZDH>{0}</GMF_DZDH>", payAddress));//购买方地址电话
        xml.AppendLine(string.Format("<GMF_YHZH>{0}</GMF_YHZH>", payBank));//购买方银行帐号
        xml.AppendLine(string.Format("<GMF_SJH>{0}</GMF_SJH>", payPhoneNo));//购买方手机号
        xml.AppendLine(string.Format("<GMF_DZYX>{0}</GMF_DZYX>", payEmail));//购买方邮箱
        xml.AppendLine(string.Format("<FPT_ZH>{0}</FPT_ZH>", fptZH));//购买发票通账户
        xml.AppendLine(string.Format("<WX_OPENID>{0}</WX_OPENID>", wxOpenId));//微信OpenId
        xml.AppendLine(string.Format("<KPR>{0}</KPR>", kpPerson));//开票人
        xml.AppendLine(string.Format("<SKR>{0}</SKR>", skPerson));//收款人
        xml.AppendLine(string.Format("<FHR>{0}</FHR>", fhPerson));//复核人
        xml.AppendLine(string.Format("<YFP_DM>{0}</YFP_DM>", volumeNo));//原发票代码
        xml.AppendLine(string.Format("<YFP_HM>{0}</YFP_HM>", invioceNo));//原发票号码
        xml.AppendLine(string.Format("<JSHJ>{0}</JSHJ>", jshj));//价税合计
        xml.AppendLine(string.Format("<HJJE>{0}</HJJE>", hjje));//合计金额
        xml.AppendLine(string.Format("<HJSE>{0}</HJSE>", hjse));//合计税额
        xml.AppendLine(string.Format("<KCE>{0}</KCE>", kce));//扣除额
        xml.AppendLine(string.Format("<BZ>{0}</BZ>", remark));//备注
        xml.AppendLine(string.Format("<HYLX>{0}</HYLX>", callingName));//行业类型
        xml.AppendLine(string.Format("<BY1>{0}</BY1>", ""));
        xml.AppendLine(string.Format("<BY2>{0}</BY2>", ""));
        xml.AppendLine(string.Format("<BY3>{0}</BY3>", ""));
        xml.AppendLine(string.Format("<BY4>{0}</BY4>", ""));
        xml.AppendLine(string.Format("<BY5>{0}</BY5>", ""));
        xml.AppendLine(string.Format("<BY6>{0}</BY6>", ""));
        xml.AppendLine(string.Format("<BY7>{0}</BY7>", ""));
        xml.AppendLine(string.Format("<BY8>{0}</BY8>", ""));
        xml.AppendLine(string.Format("<BY9>{0}</BY9>", ""));
        xml.AppendLine(string.Format("<BY10>{0}</BY10>", ""));
        xml.AppendLine(string.Format("<WX_ORDER_ID>{0}</WX_ORDER_ID>", ""));
        xml.AppendLine(string.Format("<WX_APP_ID>{0}</WX_APP_ID>", ""));
        xml.AppendLine(string.Format("<ZFB_UID>{0}</ZFB_UID>", ""));
        xml.AppendLine(string.Format("<TSPZ>{0}</TSPZ>", "00"));
        xml.AppendLine(string.Format("<QJ_ORDER_ID>{0}</QJ_ORDER_ID>", ""));

        xml.AppendLine(string.Format("<COMMON_FPKJ_XMXXS class=\"COMMON_FPKJ_XMXXS\" size=\"{0}\" >", SetNum()));


        StringBuilder xml1 = ProjectXml(xml, ddlType1, ddlProjName1, selProj1, txtAmount1);

        StringBuilder xml2 = ProjectXml(xml1, ddlType2, ddlProjName2, selProj2, txtAmount2);


        StringBuilder xml3 = ProjectXml(xml2, ddlType3, ddlProjName3, selProj3, txtAmount3);

        StringBuilder xml4 = ProjectXml(xml3, ddlType4, ddlProjName4, selProj4, txtAmount4);

        StringBuilder xml5 = ProjectXml(xml4, ddlType5, ddlProjName5, selProj5, txtAmount5);

        //xml.AppendLine("<COMMON_FPKJ_XMXXS class=\"COMMON_FPKJ_XMXXS\" size=\"1\">");
        //xml.AppendLine("<COMMON_FPKJ_XMXX>");
        //xml.AppendLine(string.Format("<FPHXZ>{0}</FPHXZ>", "0"));
        //xml.AppendLine(string.Format("<SPBM>{0}</SPBM>", "1010101050000000000"));
        //xml.AppendLine(string.Format("<ZXBM>{0}</ZXBM>", ""));
        //xml.AppendLine(string.Format("<YHZCBS>{0}</YHZCBS>", ""));
        //xml.AppendLine(string.Format("<LSLBS>{0}</LSLBS>", ""));
        //xml.AppendLine(string.Format("<ZZSTSGL>{0}</ZZSTSGL>", ""));
        //xml.AppendLine(string.Format("<XMMC>{0}</XMMC>", "红高粱"));
        //xml.AppendLine(string.Format("<GGXH>{0}</GGXH>", "500克"));
        //xml.AppendLine(string.Format("<DW>{0}</DW>", ""));
        //xml.AppendLine(string.Format("<XMSL>{0}</XMSL>", "1"));
        //xml.AppendLine(string.Format("<XMDJ>{0}</XMDJ>", "20"));
        //xml.AppendLine(string.Format("<XMJE>{0}</XMJE>", "20"));
        //xml.AppendLine(string.Format("<SL>{0}</SL>", "0.17"));
        //xml.AppendLine(string.Format("<SE>{0}</SE>", "3.4"));
        //xml.AppendLine(string.Format("<BY1>{0}</BY1>", ""));
        //xml.AppendLine(string.Format("<BY2>{0}</BY2>", ""));
        //xml.AppendLine(string.Format("<BY3>{0}</BY3>", ""));
        //xml.AppendLine(string.Format("<BY4>{0}</BY4>", ""));
        //xml.AppendLine(string.Format("<BY5>{0}</BY5>", ""));
        //xml.AppendLine("</COMMON_FPKJ_XMXX>");

        //xml.AppendLine("<COMMON_FPKJ_XMXX>");
        //xml.AppendLine(string.Format("<FPHXZ>{0}</FPHXZ>", "0"));
        //xml.AppendLine(string.Format("<SPBM>{0}</SPBM>", "1010101050000000000"));
        //xml.AppendLine(string.Format("<ZXBM>{0}</ZXBM>", ""));
        //xml.AppendLine(string.Format("<YHZCBS>{0}</YHZCBS>", ""));
        //xml.AppendLine(string.Format("<LSLBS>{0}</LSLBS>", ""));
        //xml.AppendLine(string.Format("<ZZSTSGL>{0}</ZZSTSGL>", ""));
        //xml.AppendLine(string.Format("<XMMC>{0}</XMMC>", "红高粱"));
        //xml.AppendLine(string.Format("<GGXH>{0}</GGXH>", "500克"));
        //xml.AppendLine(string.Format("<DW>{0}</DW>", ""));
        //xml.AppendLine(string.Format("<XMSL>{0}</XMSL>", "1"));
        //xml.AppendLine(string.Format("<XMDJ>{0}</XMDJ>", "20"));
        //xml.AppendLine(string.Format("<XMJE>{0}</XMJE>", "20"));
        //xml.AppendLine(string.Format("<SL>{0}</SL>", "0.17"));
        //xml.AppendLine(string.Format("<SE>{0}</SE>", "3.4"));
        //xml.AppendLine(string.Format("<BY1>{0}</BY1>", ""));
        //xml.AppendLine(string.Format("<BY2>{0}</BY2>", ""));
        //xml.AppendLine(string.Format("<BY3>{0}</BY3>", ""));
        //xml.AppendLine(string.Format("<BY4>{0}</BY4>", ""));
        //xml.AppendLine(string.Format("<BY5>{0}</BY5>", ""));
        //xml.AppendLine("</COMMON_FPKJ_XMXX>");

        //xml.AppendLine("<COMMON_FPKJ_XMXX>");
        //xml.AppendLine(string.Format("<FPHXZ>{0}</FPHXZ>", "0"));
        //xml.AppendLine(string.Format("<SPBM>{0}</SPBM>", "1010101050000000000"));
        //xml.AppendLine(string.Format("<ZXBM>{0}</ZXBM>", ""));
        //xml.AppendLine(string.Format("<YHZCBS>{0}</YHZCBS>", ""));
        //xml.AppendLine(string.Format("<LSLBS>{0}</LSLBS>", ""));
        //xml.AppendLine(string.Format("<ZZSTSGL>{0}</ZZSTSGL>", ""));
        //xml.AppendLine(string.Format("<XMMC>{0}</XMMC>", "红高粱"));
        //xml.AppendLine(string.Format("<GGXH>{0}</GGXH>", "500克"));
        //xml.AppendLine(string.Format("<DW>{0}</DW>", ""));
        //xml.AppendLine(string.Format("<XMSL>{0}</XMSL>", "1"));
        //xml.AppendLine(string.Format("<XMDJ>{0}</XMDJ>", "20"));
        //xml.AppendLine(string.Format("<XMJE>{0}</XMJE>", "20"));
        //xml.AppendLine(string.Format("<SL>{0}</SL>", "0.17"));
        //xml.AppendLine(string.Format("<SE>{0}</SE>", "3.4"));
        //xml.AppendLine(string.Format("<BY1>{0}</BY1>", ""));
        //xml.AppendLine(string.Format("<BY2>{0}</BY2>", ""));
        //xml.AppendLine(string.Format("<BY3>{0}</BY3>", ""));
        //xml.AppendLine(string.Format("<BY4>{0}</BY4>", ""));
        //xml.AppendLine(string.Format("<BY5>{0}</BY5>", ""));
        //xml.AppendLine("</COMMON_FPKJ_XMXX>");

        //xml.AppendLine("<COMMON_FPKJ_XMXX>");
        //xml.AppendLine(string.Format("<FPHXZ>{0}</FPHXZ>", "0"));
        //xml.AppendLine(string.Format("<SPBM>{0}</SPBM>", "1010101050000000000"));
        //xml.AppendLine(string.Format("<ZXBM>{0}</ZXBM>", ""));
        //xml.AppendLine(string.Format("<YHZCBS>{0}</YHZCBS>", ""));
        //xml.AppendLine(string.Format("<LSLBS>{0}</LSLBS>", ""));
        //xml.AppendLine(string.Format("<ZZSTSGL>{0}</ZZSTSGL>", ""));
        //xml.AppendLine(string.Format("<XMMC>{0}</XMMC>", "红高粱"));
        //xml.AppendLine(string.Format("<GGXH>{0}</GGXH>", "500克"));
        //xml.AppendLine(string.Format("<DW>{0}</DW>", ""));
        //xml.AppendLine(string.Format("<XMSL>{0}</XMSL>", "1"));
        //xml.AppendLine(string.Format("<XMDJ>{0}</XMDJ>", "20"));
        //xml.AppendLine(string.Format("<XMJE>{0}</XMJE>", "20"));
        //xml.AppendLine(string.Format("<SL>{0}</SL>", "0.17"));
        //xml.AppendLine(string.Format("<SE>{0}</SE>", "3.4"));
        //xml.AppendLine(string.Format("<BY1>{0}</BY1>", ""));
        //xml.AppendLine(string.Format("<BY2>{0}</BY2>", ""));
        //xml.AppendLine(string.Format("<BY3>{0}</BY3>", ""));
        //xml.AppendLine(string.Format("<BY4>{0}</BY4>", ""));
        //xml.AppendLine(string.Format("<BY5>{0}</BY5>", ""));
        //xml.AppendLine("</COMMON_FPKJ_XMXX>");

        //xml.AppendLine("<COMMON_FPKJ_XMXX>");
        //xml.AppendLine(string.Format("<FPHXZ>{0}</FPHXZ>", "0"));
        //xml.AppendLine(string.Format("<SPBM>{0}</SPBM>", "1010101050000000000"));
        //xml.AppendLine(string.Format("<ZXBM>{0}</ZXBM>", ""));
        //xml.AppendLine(string.Format("<YHZCBS>{0}</YHZCBS>", ""));
        //xml.AppendLine(string.Format("<LSLBS>{0}</LSLBS>", ""));
        //xml.AppendLine(string.Format("<ZZSTSGL>{0}</ZZSTSGL>", ""));
        //xml.AppendLine(string.Format("<XMMC>{0}</XMMC>", "红高粱"));
        //xml.AppendLine(string.Format("<GGXH>{0}</GGXH>", "500克"));
        //xml.AppendLine(string.Format("<DW>{0}</DW>", ""));
        //xml.AppendLine(string.Format("<XMSL>{0}</XMSL>", "1"));
        //xml.AppendLine(string.Format("<XMDJ>{0}</XMDJ>", "20"));
        //xml.AppendLine(string.Format("<XMJE>{0}</XMJE>", "20"));
        //xml.AppendLine(string.Format("<SL>{0}</SL>", "0.17"));
        //xml.AppendLine(string.Format("<SE>{0}</SE>", "3.4"));
        //xml.AppendLine(string.Format("<BY1>{0}</BY1>", ""));
        //xml.AppendLine(string.Format("<BY2>{0}</BY2>", ""));
        //xml.AppendLine(string.Format("<BY3>{0}</BY3>", ""));
        //xml.AppendLine(string.Format("<BY4>{0}</BY4>", ""));
        //xml.AppendLine(string.Format("<BY5>{0}</BY5>", ""));
        //xml.AppendLine("</COMMON_FPKJ_XMXX>");
       
        xml.AppendLine("</COMMON_FPKJ_XMXXS>");
        xml.AppendLine("</REQUEST_COMMON_FPKJ>");

        XmlDocument dom = new XmlDocument();
        dom.LoadXml(xml.ToString());
        byte[] utf8Buf = Encoding.UTF8.GetBytes(xml.ToString());
        byte[] gbkBuf = Encoding.Convert(Encoding.UTF8, Encoding.GetEncoding("gb2312"), utf8Buf);
        string strGB2312 = Encoding.GetEncoding("gb2312").GetString(gbkBuf);
        return strGB2312;
    }
    //项目明细
    private StringBuilder ProjectXml(StringBuilder xml, DropDownList project, DropDownList name, DropDownList content, TextBox money)
    {
        if (project.SelectedValue != "")
        {
            if (project.SelectedValue.Contains("读卡器"))//读卡器
            {
                string smmc = "";
                if (content.SelectedValue!="")
                {
                   smmc = name.SelectedValue  + content.SelectedValue ;//项目名称 
                }
                else
                {
                    smmc = name.SelectedValue;
                }
                
                string spbm = "1090503030000000000";//读卡器商品编码为：1090503030000000000
                string tax = "0.17";
                string xmje = (Convert.ToDouble(getDataKeys("READERMONEY"))/(1+Convert.ToDouble(tax))).ToString("0.00");//项目金额 不含税
                string taxfee = (Convert.ToDouble(getDataKeys("READERMONEY")) - Convert.ToDouble(xmje)).ToString("0.00");//税额
                
                xml.AppendLine("<COMMON_FPKJ_XMXX>");
                xml.AppendLine(string.Format("<FPHXZ>{0}</FPHXZ>", "0"));
                xml.AppendLine(string.Format("<SPBM>{0}</SPBM>", spbm));
                xml.AppendLine(string.Format("<ZXBM>{0}</ZXBM>", ""));
                xml.AppendLine(string.Format("<YHZCBS>{0}</YHZCBS>", ""));//优惠政策标识 0：未使用 1：使用
                xml.AppendLine(string.Format("<LSLBS>{0}</LSLBS>", ""));
                xml.AppendLine(string.Format("<ZZSTSGL>{0}</ZZSTSGL>", ""));
                xml.AppendLine(string.Format("<XMMC>{0}</XMMC>", smmc));
                xml.AppendLine(string.Format("<GGXH>{0}</GGXH>", ""));
                xml.AppendLine(string.Format("<DW>{0}</DW>", ""));
                xml.AppendLine(string.Format("<XMSL>{0}</XMSL>", ""));
                xml.AppendLine(string.Format("<XMDJ>{0}</XMDJ>", ""));
                xml.AppendLine(string.Format("<XMJE>{0}</XMJE>", xmje));
                xml.AppendLine(string.Format("<SL>{0}</SL>", tax));
                xml.AppendLine(string.Format("<SE>{0}</SE>", taxfee));
                xml.AppendLine(string.Format("<BY1>{0}</BY1>", ""));
                xml.AppendLine(string.Format("<BY2>{0}</BY2>", ""));
                xml.AppendLine(string.Format("<BY3>{0}</BY3>", ""));
                xml.AppendLine(string.Format("<BY4>{0}</BY4>", ""));
                xml.AppendLine(string.Format("<BY5>{0}</BY5>", ""));
                xml.AppendLine("</COMMON_FPKJ_XMXX>");
            }
            else if (project.SelectedValue.Contains("市民卡B卡卡费"))
            {
                string sql = "select t.CARDTYPECODE,t.COUNT,t.UNITPRICE/100.0 UNITPRICE,d.datacode,k.GOODSNO from TF_F_SZTCARDORDER t,TD_M_CARDSURFACE k,td_m_tax d where t.CARDTYPECODE=k.cardsurfacecode(+)  and k.taxno=d.taxno(+) and  t.orderno = '" + getDataKeys("ORDERNO") + "'";
                  context.DBOpen("Select");
                  DataTable data = context.ExecuteReader(sql);
                 if (data.Rows.Count > 0)
                 {
                     for (int i = 0; i < data.Rows.Count; i++)
                     {
                         if (data.Rows[i]["CARDTYPECODE"].ToString().Substring(0,2)=="05")//05:利金卡
                         {
                             string smmc = "";
                             if (content.SelectedValue != "")
                             {
                                 smmc = name.SelectedValue + content.SelectedValue;//项目名称 
                             }
                             else
                             {
                                 smmc = name.SelectedValue;
                             }
                             string spbm = "6010000000000000000";//商品编码为：6010000000000000000
                             string xmje =
                                 (Convert.ToDouble(data.Rows[i]["UNITPRICE"].ToString())*
                                  Convert.ToInt32(data.Rows[i]["COUNT"].ToString())).ToString();
                             xml.AppendLine("<COMMON_FPKJ_XMXX>");
                             xml.AppendLine(string.Format("<FPHXZ>{0}</FPHXZ>", "0"));
                             xml.AppendLine(string.Format("<SPBM>{0}</SPBM>", spbm));
                             xml.AppendLine(string.Format("<ZXBM>{0}</ZXBM>", ""));
                             xml.AppendLine(string.Format("<YHZCBS>{0}</YHZCBS>", "1"));//优惠政策标识 0：未使用 1：使用
                             xml.AppendLine(string.Format("<LSLBS>{0}</LSLBS>", "2"));//2：不征收
                             xml.AppendLine(string.Format("<ZZSTSGL>{0}</ZZSTSGL>", "不征税"));
                             xml.AppendLine(string.Format("<XMMC>{0}</XMMC>", smmc));
                             xml.AppendLine(string.Format("<GGXH>{0}</GGXH>", ""));
                             xml.AppendLine(string.Format("<DW>{0}</DW>", ""));
                             xml.AppendLine(string.Format("<XMSL>{0}</XMSL>", ""));
                             xml.AppendLine(string.Format("<XMDJ>{0}</XMDJ>", ""));
                             xml.AppendLine(string.Format("<XMJE>{0}</XMJE>", xmje));
                             xml.AppendLine(string.Format("<SL>{0}</SL>", "0"));
                             xml.AppendLine(string.Format("<SE>{0}</SE>", "0"));
                             xml.AppendLine(string.Format("<BY1>{0}</BY1>", ""));
                             xml.AppendLine(string.Format("<BY2>{0}</BY2>", ""));
                             xml.AppendLine(string.Format("<BY3>{0}</BY3>", ""));
                             xml.AppendLine(string.Format("<BY4>{0}</BY4>", ""));
                             xml.AppendLine(string.Format("<BY5>{0}</BY5>", ""));
                             xml.AppendLine("</COMMON_FPKJ_XMXX>");
                         }
                         else
                         {
                             string smmc = "";
                             if (content.SelectedValue != "")
                             {
                                 smmc = name.SelectedValue + content.SelectedValue;//项目名称 
                             }
                             else
                             {
                                 smmc = name.SelectedValue;
                             }
                             string spbm = data.Rows[i]["GOODSNO"].ToString().Trim();//商品编码为
                             string tax = data.Rows[i]["datacode"].ToString().Trim() ;
                             if (spbm == "" || tax == "")
                             {
                                 //context.AddError("卡面编码为" + data.Rows[i]["CARDTYPECODE"].ToString() + "商品编码为空");
                                 spbm = "3040201030000000000";//如果库里面没配置则默认用0801市民卡B卡标准卡面用的税率及编码
                                 tax = "0.17";
                             }
  
                            
                             string xmje = (Convert.ToDouble(data.Rows[i]["UNITPRICE"].ToString()) *
                                  Convert.ToInt32(data.Rows[i]["COUNT"].ToString()) / (1 + Convert.ToDouble(tax))).ToString("0.00");//项目金额不含税

                             string taxfee = (Convert.ToDouble(data.Rows[i]["UNITPRICE"].ToString()) *
                                  Convert.ToInt32(data.Rows[i]["COUNT"].ToString()) - Convert.ToDouble(xmje)).ToString("0.00");//税额
                             xml.AppendLine("<COMMON_FPKJ_XMXX>");
                             xml.AppendLine(string.Format("<FPHXZ>{0}</FPHXZ>", "0"));
                             xml.AppendLine(string.Format("<SPBM>{0}</SPBM>", spbm));
                             xml.AppendLine(string.Format("<ZXBM>{0}</ZXBM>", ""));
                             xml.AppendLine(string.Format("<YHZCBS>{0}</YHZCBS>", ""));
                             xml.AppendLine(string.Format("<LSLBS>{0}</LSLBS>", ""));
                             xml.AppendLine(string.Format("<ZZSTSGL>{0}</ZZSTSGL>", ""));
                             xml.AppendLine(string.Format("<XMMC>{0}</XMMC>", smmc));
                             xml.AppendLine(string.Format("<GGXH>{0}</GGXH>", ""));
                             xml.AppendLine(string.Format("<DW>{0}</DW>", ""));
                             xml.AppendLine(string.Format("<XMSL>{0}</XMSL>", ""));
                             xml.AppendLine(string.Format("<XMDJ>{0}</XMDJ>", ""));
                             xml.AppendLine(string.Format("<XMJE>{0}</XMJE>", xmje));
                             xml.AppendLine(string.Format("<SL>{0}</SL>", tax));
                             xml.AppendLine(string.Format("<SE>{0}</SE>", taxfee));
                             xml.AppendLine(string.Format("<BY1>{0}</BY1>", ""));
                             xml.AppendLine(string.Format("<BY2>{0}</BY2>", ""));
                             xml.AppendLine(string.Format("<BY3>{0}</BY3>", ""));
                             xml.AppendLine(string.Format("<BY4>{0}</BY4>", ""));
                             xml.AppendLine(string.Format("<BY5>{0}</BY5>", ""));
                             xml.AppendLine("</COMMON_FPKJ_XMXX>");
                         }
                     }
                 }
            }
            else
            {
                string smmc = "";
                if (content.SelectedValue != "")
                {
                    smmc = name.SelectedValue + content.SelectedValue;//项目名称  
                }
                else
                {
                    smmc = name.SelectedValue;
                }
                string spbm = "6010000000000000000";//免税的商品编码为：6010000000000000000
                xml.AppendLine("<COMMON_FPKJ_XMXX>");
                xml.AppendLine(string.Format("<FPHXZ>{0}</FPHXZ>", "0"));
                xml.AppendLine(string.Format("<SPBM>{0}</SPBM>", spbm));
                xml.AppendLine(string.Format("<ZXBM>{0}</ZXBM>", ""));
                xml.AppendLine(string.Format("<YHZCBS>{0}</YHZCBS>", "1"));
                xml.AppendLine(string.Format("<LSLBS>{0}</LSLBS>", "2"));//2：不征收
                xml.AppendLine(string.Format("<ZZSTSGL>{0}</ZZSTSGL>", "不征税"));
                xml.AppendLine(string.Format("<XMMC>{0}</XMMC>", smmc));
                xml.AppendLine(string.Format("<GGXH>{0}</GGXH>", ""));
                xml.AppendLine(string.Format("<DW>{0}</DW>", ""));
                xml.AppendLine(string.Format("<XMSL>{0}</XMSL>", ""));
                xml.AppendLine(string.Format("<XMDJ>{0}</XMDJ>", ""));
                xml.AppendLine(string.Format("<XMJE>{0}</XMJE>", money.Text.Trim()));
                xml.AppendLine(string.Format("<SL>{0}</SL>", "0"));
                xml.AppendLine(string.Format("<SE>{0}</SE>", "0"));
                xml.AppendLine(string.Format("<BY1>{0}</BY1>", ""));
                xml.AppendLine(string.Format("<BY2>{0}</BY2>", ""));
                xml.AppendLine(string.Format("<BY3>{0}</BY3>", ""));
                xml.AppendLine(string.Format("<BY4>{0}</BY4>", ""));
                xml.AppendLine(string.Format("<BY5>{0}</BY5>", ""));
                xml.AppendLine("</COMMON_FPKJ_XMXX>");
            }
        }
        return xml;
    }

    //计算合计税额
     private  string  SumTax()
     {
         double sumTax = 0.00;
         if (ckTax.Checked==true)//已经勾选含税订单明细
         {
             if (labTaxDetail.Text.Trim().Contains("读卡器") && (ddlType1.SelectedValue.Contains("读卡器") || ddlType2.SelectedValue.Contains("读卡器") || ddlType3.SelectedValue.Contains("读卡器") || ddlType4.SelectedValue.Contains("读卡器") || ddlType5.SelectedValue.Contains("读卡器")))//读卡器税率17%
             {
                 sumTax += Convert.ToDouble(getDataKeys("READERMONEY"))-(Convert.ToDouble(getDataKeys("READERMONEY")) / (1 + 0.17));
             }
             if (labTaxDetail.Text.Trim().Contains("市民卡B卡") && (ddlType1.SelectedValue.Contains("市民卡B卡卡费") || ddlType2.SelectedValue.Contains("市民卡B卡卡费") || ddlType3.SelectedValue.Contains("市民卡B卡卡费") || ddlType4.SelectedValue.Contains("市民卡B卡卡费") || ddlType5.SelectedValue.Contains("市民卡B卡卡费")))
             {
                 string sql = "select t.CARDTYPECODE,t.COUNT,t.UNITPRICE/100.0 UNITPRICE,d.datacode from TF_F_SZTCARDORDER t,TD_M_CARDSURFACE k,td_m_tax d where t.CARDTYPECODE=k.cardsurfacecode(+)  and k.taxno=d.taxno(+) and  orderno = '" + getDataKeys("ORDERNO") + "'";
                  context.DBOpen("Select");
                  DataTable data = context.ExecuteReader(sql);
                 if (data.Rows.Count > 0)
                 {
                     for (int i = 0; i < data.Rows.Count;i++ )
                     {
                         if (data.Rows[i]["CARDTYPECODE"].ToString().Substring(0,2) != "05" )//不是利金卡
                         {
                             string tax = data.Rows[i]["datacode"].ToString().Trim();
                             if (tax == "")
                             {
                                //如果库里面没配置则默认用0801市民卡B卡标准卡面用的税率及编码
                                 tax = "0.17";
                                 sumTax += Convert.ToDouble(data.Rows[i]["UNITPRICE"].ToString()) *
                                     Convert.ToDouble(data.Rows[i]["COUNT"].ToString())-(Convert.ToDouble(data.Rows[i]["UNITPRICE"].ToString()) *
                                     Convert.ToDouble(data.Rows[i]["COUNT"].ToString()) / (1+Convert.ToDouble(tax)) );
                             }
                             else
                             {
                                 sumTax += Convert.ToDouble(data.Rows[i]["UNITPRICE"].ToString()) *
                                     Convert.ToDouble(data.Rows[i]["COUNT"].ToString()) - (Convert.ToDouble(data.Rows[i]["UNITPRICE"].ToString()) *
                                      Convert.ToDouble(data.Rows[i]["COUNT"].ToString()) / (1+Convert.ToDouble(data.Rows[i]["datacode"].ToString())));
                                      
                             }

                            
                         }
                     }
                 }
                
             }
         }
         return sumTax.ToString("0.00");
     }

    //开票总项目数
    private  string  SetNum()
    {
        WebControl[] goods = new WebControl[5] { ddlType1, ddlType2, ddlType3, ddlType4, ddlType5 };
        int n = 0;
        for (int i = 0; i < goods.Length; i++)
        {
            string good = getControlValue(goods[i]);
            if (good != "")
            {
                if (good == "市民卡B卡卡费")//市民卡B卡
                {
                    string sql = "select t.CARDTYPECODE from TF_F_SZTCARDORDER t where   t.orderno = '" + getDataKeys("ORDERNO") + "'";
                    context.DBOpen("Select");
                    DataTable data = context.ExecuteReader(sql);
                    if (data.Rows.Count>0)
                    {
                        n = n + data.Rows.Count;
                    }
                }
                else
                {
                    n++;
                }
               
            }
                
        }
        return n.ToString();
    }



    private bool validateItem(WebControl[] goods, WebControl[] wcProjs, WebControl[] wcFees, WebControl[] invoicePros)
    {
        int n = 0;//有效条数
        bool b = true;

        for (int i = 0; i < wcProjs.Length; i++)
        {
            string good = getControlValue(goods[i]);
            //string proj = getControlValue(wcProjs[i]);
            string fee = getControlValue(wcFees[i]);
            string invoiceproj = getControlValue(invoicePros[i]);

            int cnt = getFilledCnt(good, fee, invoiceproj);

            if (cnt == 3)
            {
                if (!Validation.isPrice(fee))
                {
                    context.AddError("A200005050", wcFees[i]);//金额非数字

                    b = false;
                }
                else
                {
                    double dFee = Double.Parse(fee);
                    if (dFee.CompareTo(0) == 0)
                    {
                        context.AddError("A200005051", wcFees[i]);//金额为0
                        b = false;
                    }
                    else
                    {
                        n++;
                    }
                }
            }
            else if (cnt == 2 || cnt == 1)
            {
                context.AddError("商品名称,项目名称及金额需同时存在");//项目与金额须同时存在
                b = false;
            }
        }

        if (!b)
            return false;

        if (n == 0)
        {
            context.AddError("A200005053");//没有有效的条目

            return false;
        }

        return true;
    }
    private string getControlValue(WebControl wc)
    {
        if (wc is TextBox)
            return ((TextBox)wc).Text.Trim();
        else if (wc is DropDownList)
            return ((DropDownList)wc).SelectedValue;
        else
            throw new Exception("unsupported control");
    }
    private int getFilledCnt(string goods, string fee, string invoiceproj)
    {
        int i = 0;
        if (goods != "")
            i++;
        //if (proj != "")
        //    i++;
        if (fee != "")
            i++;
        if (invoiceproj != "")
            i++;
        return i;
    }
    protected void ddlType1_Changed(object sender, EventArgs e)
    {
        if (ddlType1.SelectedValue == "")
        {
            ddlProjName1.Enabled = true;
            ddlProjName1.SelectedIndex = 0;
            selProj1.Enabled = true;
        }
        else if (ddlType1.SelectedValue == "市民卡B卡卡费" || ddlType1.SelectedValue == "读卡器")
        {
            ddlProjName1.SelectedValue = "*软件*苏州市民卡卡片业务系统软件V1.0";
            ddlProjName1.Enabled = false;
            selProj1.Enabled = false;
        }
        else
        {
            ddlProjName1.SelectedValue = "*预付卡销售*";
            ddlProjName1.Enabled = false;
            selProj1.Enabled = true;
        }
    }
    protected void ddlType2_Changed(object sender, EventArgs e)
    {
        if (ddlType2.SelectedValue == "")
        {
            ddlProjName2.Enabled = true;
            ddlProjName2.SelectedIndex = 0;
            selProj2.Enabled = true;
        }
        else if (ddlType2.SelectedValue == "市民卡B卡卡费" || ddlType2.SelectedValue == "读卡器")
        {
            ddlProjName2.SelectedValue = "*软件*苏州市民卡卡片业务系统软件V1.0";
            ddlProjName2.Enabled = false;
            selProj2.Enabled = false;
        }
        else
        {
            ddlProjName2.SelectedValue = "*预付卡销售*";
            ddlProjName2.Enabled = false;
            selProj2.Enabled = true;
        }
    }
    protected void ddlType3_Changed(object sender, EventArgs e)
    {
        if (ddlType3.SelectedValue == "")
        {
            ddlProjName3.Enabled = true;
            ddlProjName3.SelectedIndex = 0;
            selProj3.Enabled = true;
        }
        else if (ddlType3.SelectedValue == "市民卡B卡卡费" || ddlType3.SelectedValue == "读卡器")
        {
            ddlProjName3.SelectedValue = "*软件*苏州市民卡卡片业务系统软件V1.0";
            ddlProjName3.Enabled = false;
            selProj3.Enabled = false;
        }
        else
        {
            ddlProjName3.SelectedValue = "*预付卡销售*";
            ddlProjName3.Enabled = false;
            selProj3.Enabled = true;
        }
    }
    protected void ddlType4_Changed(object sender, EventArgs e)
    {
        if (ddlType4.SelectedValue == "")
        {
            ddlProjName4.Enabled = true;
            ddlProjName4.SelectedIndex = 0;
            selProj4.Enabled = true;
        }
        else if (ddlType4.SelectedValue == "市民卡B卡卡费" || ddlType4.SelectedValue == "读卡器")
        {
            ddlProjName4.SelectedValue = "*软件*苏州市民卡卡片业务系统软件V1.0";
            ddlProjName4.Enabled = false;
            selProj4.Enabled = false;
        }
        else
        {
            ddlProjName4.SelectedValue = "*预付卡销售*";
            ddlProjName4.Enabled = false;
            selProj4.Enabled = true;
        }
    }
    protected void ddlType5_Changed(object sender, EventArgs e)
    {
        if (ddlType5.SelectedValue == "")
        {
            ddlProjName5.Enabled = true;
            ddlProjName5.SelectedIndex = 0;
            selProj5.Enabled = true;
        }
        else if (ddlType5.SelectedValue == "市民卡B卡卡费" || ddlType5.SelectedValue == "读卡器")
        {
            ddlProjName5.SelectedValue = "*软件*苏州市民卡卡片业务系统软件V1.0";
            ddlProjName5.Enabled = false;
            selProj5.Enabled = false;
        }
        else
        {
            ddlProjName5.SelectedValue = "*预付卡销售*";
            ddlProjName5.Enabled = false;
            selProj5.Enabled = true;
        }
    }
   
}