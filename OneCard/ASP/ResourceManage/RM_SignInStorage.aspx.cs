using System;
using System.Data;
using System.Collections;
using System.Web.UI;
using Master;
using Common;
using PDO.UserCard;
using System.IO;
/***************************************************************
 * 功能名: 资源管理签收入库
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2012/07/26    shil			初次开发
 * 
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2015/09/09    youyue			增加导入卡号文件的方式提交入库
 ****************************************************************/
public partial class ASP_ResourceManage_RM_SignInStorage : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            hidCardType.Value = "usecard";
            //初始化列表
            showNonDataGridView();
        }

        //固化标签
        ResourceManageHelper.selectTab(this, this.GetType(), hidCardType);
    }
    /// <summary>
    /// 初始化列表
    /// </summary>
    private void showNonDataGridView()
    {
        gvResultUseCard.DataSource = new DataTable();
        gvResultUseCard.DataBind();
        gvResultChargeCard.DataSource = new DataTable();
        gvResultChargeCard.DataBind();
    }
    /// <summary>
    /// 查询按钮点击事件
    /// </summary>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //查询校验
        if (!queryValidation())
            return;

        if (hidCardType.Value == "usecard")
            queryUseCardOrder();//查询用户卡
        else
            queryChargeCardOrder();//查询充值卡
    }
    /// <summary>
    /// 查询用户卡订购单，页面显示订购单详细信息
    /// </summary>
    protected void queryUseCardOrder()
    {
        string queryOrderID = "SELECT CARDORDERID,APPLYORDERID FROM TF_F_CARDORDER WHERE (:CARDNO BETWEEN BEGINCARDNO AND ENDCARDNO) AND CARDORDERSTATE IN('1','3','4') AND USETAG = '1'";
        context.DBOpen("Select");
        context.AddField(":CARDNO").Value = txtCardno.Text.Trim();
        DataTable OrderIDdata = context.ExecuteReader(queryOrderID);
        if (OrderIDdata.Rows.Count != 0)
        {
            //查询需求单
            DataTable ApplyOrderdata = ResourceManageHelper.callQuery(context, "QuerySignInUseCardSApplyORDER", OrderIDdata.Rows[0]["APPLYORDERID"].ToString());
            if (ApplyOrderdata.Rows.Count != 0)
            {
                txtCardOrderID.Text = ApplyOrderdata.Rows[0]["APPLYORDERID"].ToString();
                txtOrderType.Text = ApplyOrderdata.Rows[0]["ORDERTYPE"].ToString().Substring(ApplyOrderdata.Rows[0]["ORDERTYPE"].ToString().IndexOf(":") + 1);
                txtCardType.Text = ApplyOrderdata.Rows[0]["CARDTYPE"].ToString().Substring(ApplyOrderdata.Rows[0]["CARDTYPE"].ToString().IndexOf(":") + 1);
                txtCardFace.Text = ApplyOrderdata.Rows[0]["CARDFACE"].ToString().Substring(ApplyOrderdata.Rows[0]["CARDFACE"].ToString().IndexOf(":") + 1);
                txtCardName.Text = ApplyOrderdata.Rows[0]["CARDNAME"].ToString();
                txtCardSum.Text = ApplyOrderdata.Rows[0]["CARDNUM"].ToString();
                txtDate.Text = ApplyOrderdata.Rows[0]["REQUIREDATE"].ToString();
                txtLatelyDate.Text = ApplyOrderdata.Rows[0]["LATELYDATE"].ToString();
                txtAlreadyArriveNum.Text = ApplyOrderdata.Rows[0]["ALREADYARRIVENUM"].ToString();
                txtReturnNum.Text = ApplyOrderdata.Rows[0]["RETURNCARDNUM"].ToString();
                txtOrderStaff.Text = ApplyOrderdata.Rows[0]["ORDERSTAFF"].ToString().Substring(ApplyOrderdata.Rows[0]["ORDERSTAFF"].ToString().IndexOf(":") + 1);
                txtOrderTime.Text = ApplyOrderdata.Rows[0]["ORDERTIME"].ToString();
                txtRemark.Text = ApplyOrderdata.Rows[0]["REMARK"].ToString();
            }
            else
            {
                context.AddError("未找到卡号所属需求单！");
                return;
            }

            //查询订购单
            DataTable CardOrderdata = ResourceManageHelper.callQuery(context, "QuerySignInUseCardSORDER", OrderIDdata.Rows[0]["APPLYORDERID"].ToString());
            //绑定Gridview
            gvResultUseCard.DataSource = CardOrderdata;
            gvResultUseCard.DataBind();
        }
        else
        {
            context.AddError("未找到卡号所属订购单！");
			//清空
            clear();
            return;
        }
    }
    /// <summary>
    /// 查询充值卡订购单，页面显示订购单详细信息
    /// </summary>
    protected void queryChargeCardOrder()
    {
        string queryOrderID = "SELECT CARDORDERID,APPLYORDERID FROM TF_F_CARDORDER WHERE (:CARDNO BETWEEN BEGINCARDNO AND ENDCARDNO) AND CARDORDERSTATE IN('1','3','4') AND USETAG = '1'";
        context.DBOpen("Select");
        context.AddField(":CARDNO").Value = txtCardno.Text.Trim();
        DataTable OrderIDdata = context.ExecuteReader(queryOrderID);

        if (OrderIDdata.Rows.Count != 0)
        {
            //查询需求单
            DataTable ApplyOrderdata = ResourceManageHelper.callQuery(context, "QuerySignInChargeCardSApplyORDER", OrderIDdata.Rows[0]["APPLYORDERID"].ToString());

            if (ApplyOrderdata.Rows.Count != 0)
            {
                txtChargeCardOrderID.Text = ApplyOrderdata.Rows[0]["APPLYORDERID"].ToString();
                txtChargeApplyType.Text = ApplyOrderdata.Rows[0]["ORDERTYPE"].ToString().Substring(ApplyOrderdata.Rows[0]["ORDERTYPE"].ToString().IndexOf(":") + 1);
                txtCardValue.Text = ApplyOrderdata.Rows[0]["VALUECODE"].ToString().Substring(ApplyOrderdata.Rows[0]["VALUECODE"].ToString().IndexOf(":") + 1);
                txtChargeCardNum.Text = ApplyOrderdata.Rows[0]["CARDNUM"].ToString();
                txtChargeDate.Text = ApplyOrderdata.Rows[0]["REQUIREDATE"].ToString();
                txtChargeLatelyDate.Text = ApplyOrderdata.Rows[0]["LATELYDATE"].ToString();
                txtChargeAlreadyArriveNum.Text = ApplyOrderdata.Rows[0]["ALREADYARRIVENUM"].ToString();
                txtChargeReturnNum.Text = ApplyOrderdata.Rows[0]["RETURNCARDNUM"].ToString();
                txtChargeOrderStaff.Text = ApplyOrderdata.Rows[0]["ORDERSTAFF"].ToString().Substring(ApplyOrderdata.Rows[0]["ORDERSTAFF"].ToString().IndexOf(":") + 1);
                txtChargeOrderTime.Text = ApplyOrderdata.Rows[0]["ORDERTIME"].ToString();
                txtChargeRemark.Text = ApplyOrderdata.Rows[0]["REMARK"].ToString();
            }
            else
            {
                context.AddError("未找到卡号所属需求单！");
                return;
            }
            //查询订购单
            DataTable CardOrderdata = ResourceManageHelper.callQuery(context, "QuerySignInChargeCardSORDER", OrderIDdata.Rows[0]["APPLYORDERID"].ToString());
            //绑定Gridview
            gvResultChargeCard.DataSource = CardOrderdata;
            gvResultChargeCard.DataBind();
        }
        else
        {
            context.AddError("未找到卡号所属订购单！");
			//清空
            clear();
            return;
        }
    }
    /// <summary>
	/// 清空
    /// </summary>
    protected void clear()
    {
        if (hidCardType.Value == "usecard")
        {
            //清空用户卡记录
            txtCardOrderID.Text = "";
            txtOrderType.Text = "";
            txtCardType.Text = "";
            txtCardFace.Text = "";
            txtCardName.Text = "";
            txtCardSum.Text = "";
            txtDate.Text = "";
            txtLatelyDate.Text = "";
            txtAlreadyArriveNum.Text = "";
            txtReturnNum.Text = "";
            txtOrderStaff.Text = "";
            txtOrderTime.Text = "";
            txtRemark.Text = "";

            gvResultUseCard.DataSource = new DataTable();
            gvResultUseCard.DataBind();
        }
        else
        {
            //清空充值卡记录
            txtChargeCardOrderID.Text = "";
            txtChargeApplyType.Text = "";
            txtCardValue.Text = "";
            txtChargeCardNum.Text = "";
            txtChargeDate.Text = "";
            txtChargeLatelyDate.Text = "";
            txtChargeAlreadyArriveNum.Text = "";
            txtChargeReturnNum.Text = "";
            txtChargeOrderStaff.Text = "";
            txtChargeOrderTime.Text = "";
            txtChargeRemark.Text = "";

            gvResultChargeCard.DataSource = new DataTable();
            gvResultChargeCard.DataBind();
        }
    }
    /// <summary>
    /// 提交按钮点击事件
    /// </summary>
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        //校验
        if (!supplyValidation())
            return;

        context.SPOpen();
        context.AddField("P_BEGINCARDNO").Value = txtFromCardNo.Text.Trim();
        context.AddField("P_ENDCARDNO").Value = txtToCardNo.Text.Trim();
        context.AddField("P_seqNo", "String", "output", "16", null);
        if (hidCardType.Value == "usecard")
            context.AddField("P_SIGNTYPE").Value = "0"; //用户卡
        else
            context.AddField("P_SIGNTYPE").Value = "1"; //充值卡

        bool ok = context.ExecuteSP("SP_RM_SIGNINSTORAGE");

        if (ok)
        {
            String seqNo = "" + context.GetFieldValue("P_seqNo"); ViewState["seqNo"] = seqNo;
            AddMessage("入库成功");
            if (chkOrder.Checked)
            {
                string printhtml = "";
                if (hidCardType.Value == "usecard") //用户卡
                {
                    string cardmanu = "";
                    string cardsurfacename = "";
                    //查询出卡片厂商
                    SP_UC_QueryPDO pdo = new SP_UC_QueryPDO();
                    pdo.funcCode = "CardInfoQuery";
                    pdo.var1 = txtFromCardNo.Text.Trim();
                    pdo.var2 = txtFromCardNo.Text.Trim();
                    StoreProScene storePro = new StoreProScene();
                    DataTable data = storePro.Execute(context, pdo);
                    if (data != null && data.Rows.Count > 0)
                    {
                        cardmanu = data.Rows[0]["MANUNAME"].ToString(); ViewState["cardmanu"] = cardmanu;
                        cardsurfacename = data.Rows[0]["CARDSURFACENAME"].ToString(); ViewState["cardsurfacename"] = cardsurfacename;
                    }
                    long quantity = Convert.ToInt64(txtToCardNo.Text.Trim()) - Convert.ToInt64(txtFromCardNo.Text.Trim()) + 1; ViewState["quantity"] = cardmanu;
                    printhtml = RMPrintHelper.GetUseCardSignInStoragePrintText(seqNo, cardmanu, cardsurfacename, quantity.ToString(), context.s_DepartName, context.s_UserName);
                }
                else //充值卡
                {
                    string cardvalue = "";
                    DataTable data = ChargeCardHelper.callQuery(context, "F6", txtFromCardNo.Text, txtFromCardNo.Text.Trim());
                    if (data != null && data.Rows.Count > 0)
                    {
                        cardvalue = data.Rows[0]["面值"].ToString(); ViewState["cardvalue"] = cardvalue;
                    }
                    long quantity = Convert.ToInt64(txtToCardNo.Text.Substring(6, 8)) - Convert.ToInt64(txtFromCardNo.Text.Substring(6, 8)) + 1; ViewState["ccquantity"] = quantity;
                    printhtml = RMPrintHelper.GetChargeCardSignInStoragePrintText(seqNo, cardvalue, quantity.ToString(), context.s_DepartName, context.s_UserName);
                }
                printarea.InnerHtml = printhtml;
                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Print", "printOrderdiv('printarea');", true);
            }
            txtFromCardNo.Text = "";
            txtToCardNo.Text = "";
        }
       
    }

    protected void btnPrint_Click(object sender, EventArgs e)
    {
        string printhtml = "";
        //用户卡
        if (hidCardType.Value == "usecard")
        {
            if (ViewState["seqNo"] != null && ViewState["cardmanu"] != null && ViewState["cardsurfacename"] != null && ViewState["quantity"] != null)
            {
                string seqNo = ViewState["seqNo"].ToString();
                string cardmanu = ViewState["cardmanu"].ToString();
                string cardsurfacename = ViewState["cardsurfacename"].ToString();
                string quantity = ViewState["quantity"].ToString();
                printhtml = RMPrintHelper.GetUseCardSignInStoragePrintText(seqNo, cardmanu, cardsurfacename, quantity.ToString(), context.s_DepartName, context.s_UserName);
            }
            else
            {
                context.AddError("没有要打印的入库单");
                return;
            }
        }
        else
        {
            if (ViewState["seqNo"] != null && ViewState["cardvalue"] != null && ViewState["ccquantity"] != null)
            {
                string seqNo = ViewState["seqNo"].ToString();
                string cardvalue = ViewState["cardvalue"].ToString();
                string ccquantity = ViewState["ccquantity"].ToString();
                printhtml = RMPrintHelper.GetChargeCardSignInStoragePrintText(seqNo, cardvalue, ccquantity.ToString(), context.s_DepartName, context.s_UserName);
            }
            else
            {
                context.AddError("没有要打印的入库单");
            }
        }
        printarea.InnerHtml = printhtml;
        //执行打印脚本
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Print", "printOrderdiv('printarea');", true);
    }

    /// <summary>
    /// 查询输入校验
    /// </summary>
    /// <returns>没有错误返回true,存在错误则返回false</returns>
    protected Boolean queryValidation()
    {
        if (hidCardType.Value == "usecard")//用户卡
        {
            //校验卡号
            if (string.IsNullOrEmpty(txtCardno.Text.Trim()))
                context.AddError("A095470144：卡号不能为空", txtCardno);
            else if (Validation.strLen(txtCardno.Text.Trim()) != 16)
                context.AddError("A095470145：卡号必须为16位", txtCardno);
            else if (!Validation.isNum(txtCardno.Text.Trim()))
                context.AddError("A095470146：卡号必须为数字", txtCardno);
        }
        else//充值卡
        {
            //校验卡号
            if (string.IsNullOrEmpty(txtCardno.Text.Trim()))
                context.AddError("A095470147：充值卡卡号不能为空", txtCardno);
            else if (Validation.strLen(txtCardno.Text.Trim()) != 14)
                context.AddError("A095470148：充值卡卡号必须为14位", txtCardno);
            else
                ChargeCardHelper.validateCardNo(context, txtCardno, "A095470149:卡号不符合充值卡卡号格式");
        }

        return !context.hasError();
    }
    /// <summary>
    /// 提交输入校验
    /// </summary>
    /// <returns>没有错误返回true,存在错误则返回false</returns>
    protected Boolean supplyValidation()
    {
        if (hidCardType.Value == "usecard")
        {
           
            // 对起始卡号和结束卡号进行校验
            ResourceManageHelper.validateUseCardNoRange(context, txtFromCardNo, txtToCardNo, true, true);
        }
        else
        {
            
                // 检查起始卡号和终止卡号的格式（非空、14位、英数）
             ResourceManageHelper.validateChargeCardNoRange(context, txtFromCardNo, txtFromCardNo, true);
            
        }

        return !context.hasError();
    }
    /// <summary>
    /// 增加导入卡号文件的方式提交入库，文件格式为单卡号字段 add by youyue20150908
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnUpload_Click(object sender, EventArgs e)
    {
       GroupCardHelper.uploadFileValidate(context,FileUpload1);
        if (context.hasError()) return;
        // 首先清空临时表

        clearTempTable();
        if (Path.GetExtension(FileUpload1.FileName) == ".xls" || Path.GetExtension(FileUpload1.FileName) == ".xlsx")
        {
            LoadExcelFile();

        }
        else
        {
            context.AddError("导入文件格式必须为.xls或.xlsx");
        }
        if (!context.hasError())
        {
            context.SPOpen();
            context.AddField("P_SESSIONID").Value = Session.SessionID;
            context.AddField("P_seqNo", "String", "output", "16", null);
            context.AddField("P_OUTCARDNO", "String", "output", "16", null);
            context.AddField("P_CARDNUM", "Int32", "output", "32", null);
            if (hidCardType.Value == "usecard")
                context.AddField("P_SIGNTYPE").Value = "0"; //用户卡
            else
                context.AddField("P_SIGNTYPE").Value = "1"; //充值卡

            bool ok = context.ExecuteSP("SP_RM_SIGNINSTORAGEBATCH");
            if (ok)
            {
                string  seqNo = "" + context.GetFieldValue("P_seqNo");
                ViewState["seqNo"] = seqNo;
                string fromCardNo = "" + context.GetFieldValue("P_OUTCARDNO");
                long totalnum = Convert.ToInt64(context.GetFieldValue("P_CARDNUM"));

                AddMessage("文件入库成功");
                if (chkOrder.Checked)
                {
                    string printhtml = "";
                    if (hidCardType.Value == "usecard") //用户卡
                    {
                        string cardmanu = "";
                        string cardsurfacename = "";
                        //查询出卡片厂商
                        SP_UC_QueryPDO pdo = new SP_UC_QueryPDO();
                        pdo.funcCode = "CardInfoQuery";
                        pdo.var1 = fromCardNo.Trim();
                        pdo.var2 = fromCardNo.Trim();
                        StoreProScene storePro = new StoreProScene();
                        DataTable data = storePro.Execute(context, pdo);
                        if (data != null && data.Rows.Count > 0)
                        {
                            cardmanu = data.Rows[0]["MANUNAME"].ToString();
                            ViewState["cardmanu"] = cardmanu;
                            cardsurfacename = data.Rows[0]["CARDSURFACENAME"].ToString(); 
                            ViewState["cardsurfacename"] = cardsurfacename;
                        }
                        ViewState["quantity"] = totalnum;
                        printhtml = RMPrintHelper.GetUseCardSignInStoragePrintText(seqNo, cardmanu, cardsurfacename, totalnum.ToString(), context.s_DepartName, context.s_UserName);
                    }
                    else //充值卡
                    {
                        string cardvalue = "";
                        DataTable data = ChargeCardHelper.callQuery(context, "F6", fromCardNo.Trim(), fromCardNo.Trim());
                        if (data != null && data.Rows.Count > 0)
                        {
                            cardvalue = data.Rows[0]["面值"].ToString(); 
                            ViewState["cardvalue"] = cardvalue;
                        }
                        ViewState["ccquantity"] = totalnum;
                        printhtml = RMPrintHelper.GetChargeCardSignInStoragePrintText(seqNo, cardvalue, totalnum.ToString(), context.s_DepartName, context.s_UserName);
                    }
                    printarea.InnerHtml = printhtml;
                    ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Print", "printOrderdiv('printarea');", true);
                }
            }
        }
        
    }
    /// <summary>
    /// 导入Excel格式的制卡文件
    /// </summary>
    public void LoadExcelFile()
    {
        string type = hidCardType.Value;//用户卡还是充值卡
        if (File.Exists("D:\\excelfile\\" + FileUpload1.FileName))
        {
            File.Delete("D:\\excelfile\\" + FileUpload1.FileName);
        }
        byte[] bytes = FileUpload1.FileBytes;
        using (FileStream f = new FileStream("D:\\excelfile\\" + FileUpload1.FileName, FileMode.OpenOrCreate, FileAccess.ReadWrite))
        {
            f.Write(bytes, 0, bytes.Length);
        }
        DataTable data = OrderHelper.getExcel_info("D:\\excelfile\\" + FileUpload1.FileName);
        if (data != null && data.Rows.Count > 0)
        {
            if (data.Columns.Count != 1)
            {
                context.AddError("字段数目根据制卡格式定义必须为1");
                return;
            }
            Hashtable ht = new Hashtable();
            for (int i = 0; i < data.Rows.Count; i++)
            {
                if (data.Rows[i][0].ToString().Trim().Length > 0 )
                {
                    String[] fields = new String[1];
                    fields[0] = data.Rows[i][0].ToString();
                    dealFileContent(ht, fields, i + 1, type);
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
        else
        {
            context.RollBack();
        }
        try
        {
            if (FileUpload1.HasFile && File.Exists("D:\\excelfile\\" + FileUpload1.FileName))
            {
                File.Delete("D:\\excelfile\\" + FileUpload1.FileName);
            }
        }
        catch
        { }
        
    }

    //读取上传文件,并插入数据库临时表中
    private void dealFileContent(Hashtable ht, String[] fields, int lineCount, string type)
    {
        String cardNo = fields[0].Trim();
        if(type== "usecard")
        {
            //校验卡号
            if (string.IsNullOrEmpty(cardNo))
                context.AddError("A095470154：导入文件的第" + lineCount + "行用户卡卡号不能为空");
            else if (Validation.strLen(cardNo) != 16)
                context.AddError("A095470155：导入文件的第" + lineCount + "行用户卡卡号必须为16位");
            else if (!Validation.isNum(cardNo))
                context.AddError("A095470156：导入文件的第" + lineCount + "行用户卡卡号必须为数字");
        }
        else
        {
            if (string.IsNullOrEmpty(cardNo))
                context.AddError("A095470157：导入文件的第" + lineCount + "行充值卡卡号不能为空");
            else if (Validation.strLen(cardNo) != 14)
                context.AddError("A095470158：导入文件的第" + lineCount + "行充值卡卡号必须为14位");
            else if((!ChargeCardHelper.validateCardNo(cardNo)))
                context.AddError("A095470149:导入文件的第" + lineCount + "行卡号不符合充值卡卡号格式");
               
        }
        if (!context.hasError())
        {
            context.DBOpen("Insert");
            context.ExecuteNonQuery(@"insert into TMP_COMMON(f0,f1) 
            values('" + Session.SessionID + "', '" + cardNo + "')");
        }
        
    }
    /// <summary>
    /// 清空临时表
    /// </summary>
    private void clearTempTable()
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_COMMON where f0='" + Session.SessionID + "'");
        context.DBCommit();
    }



  
    
}