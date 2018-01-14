using System;
using System.Data;
using System.IO;
using System.Net;
using System.Text;
using System.Web;
using System.Web.UI.WebControls;
using System.Xml;
using Common;
using System.Diagnostics;
using TDO.UserManager;

public partial class ASP_InvoiceTrade_IT_QueryElectronic : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            //初始化日期

            txtBeginDate.Text = DateTime.Now.ToString("yyyyMMdd");
            txtEndDate.Text = DateTime.Now.ToString("yyyyMMdd");
            //初始化表头

            initTable();
            if (HasOperPower("201008"))//全部网点主管
            {
                //初始化部门



                //TMTableModule tmTMTableModule = new TMTableModule();
                //TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();
                //TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTOutArr = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDEDEPARTIn, typeof(TD_M_INSIDEDEPARTTDO), null, " WHERE USETAG = '1' ORDER BY DEPARTNO");
                //ControlDeal.SelectBoxFill(selDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);
                FIHelper.selectDept(context, selDept, true);
                selDept.SelectedValue = context.s_DepartID;
                InitStaffList(context.s_DepartID);
                selStaff.SelectedValue = context.s_UserID;
            }
            else if (HasOperPower("201007"))//网点主管
            {
                selDept.Items.Add(new ListItem(context.s_DepartID + ":" + context.s_DepartName, context.s_DepartID));
                selDept.SelectedValue = context.s_DepartID;
                selDept.Enabled = false;

                InitStaffList(context.s_DepartID);
                selStaff.SelectedValue = context.s_UserID;
            }
            else if (HasOperPower("201009"))//代理全网点主管 add by liuhe20120214添加对代理的权限处理
            {
                context.DBOpen("Select");
                string dBalunitNo = DeptBalunitHelper.GetDbalunitNo(context);
                string sql = @"SELECT  D.DEPARTNAME,D.DEPARTNO FROM TD_DEPTBAL_RELATION R,TD_M_INSIDEDEPART D 
                            WHERE R.DEPARTNO=D.DEPARTNO AND R.DBALUNITNO='" + dBalunitNo + "' AND R.USETAG='1'";
                DataTable table = context.ExecuteReader(sql);
                GroupCardHelper.fill(selDept, table, true);

                selDept.SelectedValue = context.s_DepartID;
                InitStaffList(context.s_DepartID);
                selStaff.SelectedValue = context.s_UserID;
            }
            else if (HasOperPower("201010"))//代理网点主管
            {
                selDept.Items.Add(new ListItem(context.s_DepartID + ":" + context.s_DepartName, context.s_DepartID));
                selDept.SelectedValue = context.s_DepartID;
                selDept.Enabled = false;

                InitStaffList(context.s_DepartID);
                selStaff.SelectedValue = context.s_UserID;
            }
            else//网点营业员
            {
                selDept.Items.Add(new ListItem(context.s_DepartID + ":" + context.s_DepartName, context.s_DepartID));
                selDept.SelectedValue = context.s_DepartID;
                selDept.Enabled = false;

                selStaff.Items.Add(new ListItem(context.s_UserID + ":" + context.s_UserName, context.s_UserID));
                selStaff.SelectedValue = context.s_UserID;
                selStaff.Enabled = false;
            }

        }
    }
    public void initTable()
    {
        lvwInvoice.DataSource = new DataTable();
        lvwInvoice.DataBind();
        lvwInvoice.SelectedIndex = -1;
        lvwInvoice.DataKeyNames = new string[] { "INVOICENO", "VOLUMENO", "NAME", "TRADEFEE", "TYPE", "ISSK" };
    }

    private bool HasOperPower(string powerCode)
    {
        //TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_ROLEPOWERTDO ddoTD_M_ROLEPOWERIn = new TD_M_ROLEPOWERTDO();
        string strSupply = " Select POWERCODE From TD_M_ROLEPOWER Where POWERCODE = '" + powerCode + "' And ROLENO IN ( SELECT ROLENO From TD_M_INSIDESTAFFROLE Where STAFFNO ='" + context.s_UserID + "')";
        DataTable dataSupply = tm.selByPKDataTable(context, ddoTD_M_ROLEPOWERIn, null, strSupply, 0);
        if (dataSupply.Rows.Count > 0)
            return true;
        else
            return false;
    }

    private void InitStaffList(string deptNo)
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
                GroupCardHelper.fill(selStaff, table, true);

                return;
            }

            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";

            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_DIMMISSIONTAG_USEFUL", null);
            ControlDeal.SelectBoxFill(selStaff.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
            selStaff.SelectedValue = context.s_UserID;
        }
        else
        {
            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            tdoTD_M_INSIDESTAFFIn.DEPARTNO = deptNo;
            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";

            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_DEPT", null);
            ControlDeal.SelectBoxFill(selStaff.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
        }
    }

    protected void selDept_Changed(object sender, EventArgs e)
    {
        InitStaffList(selDept.SelectedValue);
    }
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (!InputValidate())
            return;
        DataTable dt = SPHelper.callQuery("SP_IT_Query", context, "QueryElectronic", txtBeginCardNo.Text.Trim(), txtOrderNo.Text.Trim(), txtGroupName.Text.Trim(), txtBeginDate.Text.Trim(), txtEndDate.Text.Trim(), txtInvoiceNo.Text.Trim(), selStaff.SelectedValue, selDept.SelectedValue);
        if (dt == null || dt.Rows.Count < 1)
        {
            lvwInvoice.DataSource = new DataTable();
            lvwInvoice.DataBind();
            context.AddError("未查出记录");
            return;
        }
        lvwInvoice.DataSource = dt;
        lvwInvoice.DataBind();
    }
    private bool InputValidate()
    {

        DateTime? dateEff = null, dateExp = null;

        string strBeginDate = txtBeginDate.Text.Trim();
        string strEndDate = txtEndDate.Text.Trim();
        //对起始日期非空, 格式的校验

        if (strBeginDate == "")
        {
            context.AddError("A002P01013", txtBeginDate);
        }
        else if (!Validation.isDate(strBeginDate, "yyyyMMdd"))
        {
            context.AddError("日期格式不符合YYYYMMDD", txtBeginDate);
        }
        else
        {
            dateEff = DateTime.ParseExact(strBeginDate, "yyyyMMdd", null);
        }


        //对终止日期非空, 格式的校验

        if (strEndDate == "")
        {
            context.AddError("A002P01015", txtEndDate);
        }

        else if (!Validation.isDate(strEndDate, "yyyyMMdd"))
        {
            context.AddError("日期格式不符合YYYYMMDD", txtEndDate);
        }
        else
        {
            dateExp = DateTime.ParseExact(strEndDate, "yyyyMMdd", null);
        }

        //起始日期不能大于终止日期
        if (dateEff != null && dateExp != null && dateEff.Value.CompareTo(dateExp.Value) > 0)
            context.AddError("A200007032");

        if (context.hasError())
            return false;
        else
            return true;

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
        string sql = "select PDFURL from TF_F_ELECTRONICINVOICE t where t.invoiceno = '" + getDataKeys("INVOICENO") + "'and t.volumeno='" + getDataKeys("VOLUMENO") + "'";
        context.DBOpen("Select");
        DataTable data = context.ExecuteReader(sql);
        if (data.Rows.Count > 0)
        {
            if (data.Rows[0]["PDFURL"].ToString() != string.Empty)
            {
                string url = data.Rows[0]["PDFURL"].ToString();
                labDownload.Text = "<a href='" + url.ToString() + "'>下载PDF</a>";
            }
        }
        

    }
    public String getDataKeys(string keysname)
    {
        string value = lvwInvoice.DataKeys[lvwInvoice.SelectedIndex][keysname].ToString();

        return value == "" ? "" : value;
    }
    //红冲
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        if (lvwInvoice.SelectedIndex == -1)
        {
            context.AddError("未选择数据");
            return;
        }
        //调用红冲发票接口
        string param = SetupHCXml();
        string response = HttpRequestUtility.Post("http://192.168.8.68:5001/dzfp/kshc", param);
        string xml = response.Replace("\r", "").Replace("\n", "");
        string returncode = "";
        string returnmessage = "";
        string fpqqlsh = "";
        string fpHm = "";
        string fpDm = "";
        string date = "";
        string pdfurl = "";
        string jym = "";
        if (!string.IsNullOrEmpty(response))
        {
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
                    else if (n.Name == "PDF_URL")
                    {
                        pdfurl = n.InnerText;
                    }
                    else if (n.Name == "JYM")
                    {
                        jym = n.InnerText;
                    }
                }
            }

            //SP_IT_OpenInvioceResponse queryResponse = JsonConvert.DeserializeObject<SP_IT_OpenInvioceResponse>(response);
            if (returncode == "0000")//0000:成功
            {
                //记录台帐和开票信息
                context.SPOpen();
                context.AddField("P_TRADEID").Value = fpqqlsh;      //发票请求流水号
                context.AddField("p_oldNo").Value = getDataKeys("INVOICENO");    //原发票号码
                context.AddField("p_oldVolumn").Value = getDataKeys("VOLUMENO");     //原发票代码
                context.AddField("p_newNo").Value = fpHm;      //发票号码
                context.AddField("p_newVolumn").Value = fpDm;      //发票代码

                context.AddField("P_TYPE").Value = getDataKeys("TYPE");//0:普通开票 1：订单开票
                context.AddField("P_NAME").Value = getDataKeys("NAME");//如果是普通开票则传CARDNO，订单开票传ORDERNO
                context.AddField("P_MONEY").Value = Convert.ToInt32(Convert.ToDecimal(getDataKeys("TRADEFEE")) * 100);

                context.AddField("p_drawer").Value = context.s_UserName;     //开票人
                context.AddField("p_date").Value = date;      //开票日期
                context.AddField("P_PDF").Value = pdfurl;

                context.AddField("p_validatecode").Value = jym;//验证码

                context.AddField("P_payeeName").Value = "苏州市民卡有限公司";//收款方                

                context.AddField("p_bankName").Value = "苏州银行三香路支行";//苏信开户行名称
                context.AddField("p_bankAccount").Value = "3205010071120167000003";//苏信开户行

                bool ok = context.ExecuteSP("SP_IT_ElectronicReverse");
                if (ok)
                {
                    context.AddMessage("红冲发票成功！");

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
       

    }
    //下载PDF
    protected void btnDownloadPdf_Click(object sender, EventArgs e)
    {
        if (lvwInvoice.SelectedIndex == -1)
        {
            context.AddError("未选择数据");
            return;
        }

        //调用接口查询PDF下载地址

        //string t = SetupPDFJson();
        string sql = "select PDFURL from TF_F_ELECTRONICINVOICE t where t.invoiceno = '" + getDataKeys("INVOICENO") + "'and t.volumeno='" + getDataKeys("VOLUMENO") + "'";
        context.DBOpen("Select");
        DataTable data = context.ExecuteReader(sql);
        if (data.Rows.Count > 0)
        {
            if (data.Rows[0]["PDFURL"].ToString()!=string.Empty)
            {
                string url = data.Rows[0]["PDFURL"].ToString();
                //string fileName = getDataKeys("INVOICENO") + "_" + getDataKeys("VOLUMENO");
                //DownloadFile(fileName, url);
                //System.Diagnostics.Process p = new System.Diagnostics.Process();
                //p.StartInfo.UseShellExecute = true;
                //p.StartInfo.FileName = url;
                //p.Start();
                //return;
                //System.Diagnostics.Process.Start("IExplore.exe",url);//打开链接
                Response.Redirect(url,true);
                
            }
            else
            {
                context.AddError("数据库中无PDF地址");
                return;
            }
        }
        else
        {
            context.AddError("无发票信息");
            return;
        }

    }

    /// <summary>
    /// 组装发票快速红冲请求报文
    /// </summary>
    /// <param name="id">发票请求流水号</param>
    /// <param name="nsrNo">销售方纳税人识别号</param>
    /// <param name="saleGroupName">销售方名称</param>
    /// <param name="invoiceNo">发票号</param>
    /// <param name="volumeNo">发票卷号</param>
    /// <returns></returns>
    private string SetupHCXml()
    {
        StringBuilder xml = new StringBuilder();

        //报文
        xml.AppendLine("<REQUEST_COMMON_FPKSHC class=\"REQUEST_COMMON_FPKSHC\">");
        string nsrNo = "";
        string isSK = getDataKeys("ISSK");
        string saleGroupName = "";
        if (isSK=="1")//1:省卡
        {
            nsrNo = "91320508MA1MT3CH0H";
            saleGroupName = "苏州城慧通商务咨询服务有限公司";
        }
        else
        {
            nsrNo = "9132050874558352XW";//小额
            saleGroupName = "苏州市民卡有限公司";
        }

        string id = "SZSMHC" + DateTime.Now.ToString("yyyyMMddHHmmss"); ;  //发票请求流水号
        //string nsrNo = "9132050874558352XW";         //销售方纳税人识别号:9132050874558352XW 测试:110109500321655
       // string saleGroupName = "苏州市民卡有限公司";   //销售方名称:苏州市民卡有限公司客户备付金  测试:旺电子测试2
        string invoiceNo = getDataKeys("INVOICENO");  //发票号码
        string volumeNo = getDataKeys("VOLUMENO");    //发票代码

        xml.AppendLine(string.Format("<FPQQLSH>{0}</FPQQLSH>", id));
        xml.AppendLine(string.Format("<XSF_NSRSBH>{0}</XSF_NSRSBH>", nsrNo));
        xml.AppendLine(string.Format("<XSF_MC>{0}</XSF_MC>", saleGroupName));
        xml.AppendLine(string.Format("<YFP_DM>{0}</YFP_DM>", volumeNo));
        xml.AppendLine(string.Format("<YFP_HM>{0}</YFP_HM>", invoiceNo));
        xml.AppendLine(string.Format("<ISSK>{0}</ISSK>", isSK));

        xml.AppendLine("</REQUEST_COMMON_FPKSHC>");

        XmlDocument dom = new XmlDocument();
        dom.LoadXml(xml.ToString());
        byte[] utf8Buf = Encoding.UTF8.GetBytes(xml.ToString());
        byte[] gbkBuf = Encoding.Convert(Encoding.UTF8, Encoding.GetEncoding("gb2312"), utf8Buf);
        string strGB2312 = Encoding.GetEncoding("gb2312").GetString(gbkBuf);
        return strGB2312;
    }

   


    // 发票下载地址查询请求报文
    //private string SetupPDFXml()
    //{
    //    StringBuilder xml = new StringBuilder();

    //    //报文
    //    xml.AppendLine("<REQUEST_COMMON_FPXZDZCX class=\"REQUEST_COMMON_FPXZDZCX\">");
    //    string nsrNo = "9132050874558352XW";           //销售方纳税人识别号
    //    string id = getDataKeys("ID");                 //发票请求流水号
    //    string invoiceNo = getDataKeys("INVOICENO");   //原发票号码
    //    string volumeNo = getDataKeys("VOLUMENO");     //原发票代码

    //    xml.AppendLine(string.Format("<NSRSBH>{0}</NSRSBH>", nsrNo));
    //    xml.AppendLine(string.Format("<FPQQLSH>{0}</FPQQLSH>", id));
    //    xml.AppendLine(string.Format("<YFP_DM>{0}</YFP_DM>", volumeNo));
    //    xml.AppendLine(string.Format("<YFP_HM>{0}</YFP_HM>", invoiceNo));

    //    xml.AppendLine("</REQUEST_COMMON_FPXZDZCX>");

    //    XmlDocument dom = new XmlDocument();
    //    dom.LoadXml(xml.ToString());
    //    byte[] utf8Buf = Encoding.UTF8.GetBytes(xml.ToString());
    //    byte[] gbkBuf = Encoding.Convert(Encoding.UTF8, Encoding.GetEncoding("gb2312"), utf8Buf);
    //    string strGB2312 = Encoding.GetEncoding("gb2312").GetString(gbkBuf);
    //    return strGB2312;
    //}



    //public void DownloadFile(string fileName, string filePath)
    //{
        
    //    try
    //    {
    //        string url = "http:" + filePath.Replace("\\", "/");

    //        HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);
    //        WebResponse response = request.GetResponse();
    //        Stream stream = response.GetResponseStream();

    //        StreamReader reader = new StreamReader(stream, Encoding.GetEncoding("UTF-8"));
    //        string ttt = reader.ReadToEnd();
    //        byte[] bytes = Encoding.UTF8.GetBytes(ttt);
    //        stream.Read(bytes, 0, bytes.Length);
    //        stream.Close();
    //        Response.ContentType = "application/octet-stream";
    //        //通知浏览器下载文件而不是打开  
    //        Response.AddHeader("Content-Disposition", "attachment;filename=" + HttpUtility.UrlEncode(fileName, System.Text.Encoding.UTF8));
    //        Response.BinaryWrite(bytes);
    //        Response.Flush();
    //        Response.End();

    //    }
    //    catch (Exception ex)
    //    {
    //        context.AddError("下载文件失败" + ex);
    //    }
    //}
}