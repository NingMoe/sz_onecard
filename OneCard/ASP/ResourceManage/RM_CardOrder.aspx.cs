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
/***************************************************************
 * 功能名: 资源管理卡片下单
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2012/07/20    shil			初次开发
 ****************************************************************/
public partial class ASP_ResourceManage_RM_CardOrder : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //绑定JS，起始卡号，结束卡号失去焦点事件
            txtFromCardNo.Attributes["OnBlur"] = "javascript:return Change();";
            txtToCardNo.Attributes["OnBlur"] = "javascript:return Change();";
            txtFromChargeCardno.Attributes["OnBlur"] = "javascript:return Change();";
            txtToChargeCardno.Attributes["OnBlur"] = "javascript:return Change();";
            //绑定用户卡GridView关键字名称
            gvUseCardOrder.DataKeyNames =
                new string[] { "APPLYORDERID", "ORDERTYPE", "CARDTYPE", "CARDFACE", "CARDSAMPLECODE", "CARDNAME", "WAY", 
                    "CARDNUM", "REQUIREDATE", "ORDERDEMAND", "ALREADYORDERNUM", "ORDERTIME", "ORDERSTAFF", "REMARK" };
            //绑定充值卡GridView关键字名称
            gvChargeCardOrder.DataKeyNames =
                new string[] { "APPLYORDERID", "VALUECODE", "CARDNUM", "REQUIREDATE", "ORDERDEMAND", 
                               "ALREADYORDERNUM", "ORDERTIME", "ORDERSTAFF", "REMARK" };
            //绑定卡号段GridView关键字名称
            gvResult.DataKeyNames =
                new string[] { "startcardno", "endcardno", "cardnum" };

            hidCardType.Value = "usecard";

            //初始化页面
            init_Page();
            //初始化列表
            showNonDataGridView();
            showOrderNonDataGridView();
        }

        //固化标签
        ResourceManageHelper.selectTab(this, this.GetType(), hidCardType);
    }
    /// <summary>
    /// 页面初始化
    /// </summary>
    protected void init_Page()
    {
        //设置只读控件
        setReadOnly(txtCardType, txtCardSampleCode, txtDate, txtCardSum, txtCardValue, txtChargeCardDate, txtChargeCardNum);

        //初始化日期
        DateTime date = new DateTime();
        date = DateTime.Today;
        txtStartDate.Text = date.AddMonths(-1).ToString("yyyyMMdd");
        txtEndDate.Text = DateTime.Today.ToString("yyyyMMdd");
        txtApplyOrderID.Text = "XQ";
       
        //从COS类型编码表(TD_M_COSTYPE)中读取数据，放入下拉列表中

        UserCardHelper.selectCosType(context, selCosType, false);

        //从厂商编码表(TD_M_MANU)中读取数据，放入下拉列表中

        UserCardHelper.selectManu(context, selProducer, true);

        //从IC卡卡面编码表(TD_M_CARDSURFACE)中读取数据，放入下拉列表中

        UserCardHelper.selectCardFace(context, selFaceType, true);

        //从IC卡芯片类型编码表(TD_M_CARDCHIPTYPE)中读取数据，放入下拉列表中

        UserCardHelper.selectChipType(context, selChipType, true);

        //从充值卡卡片厂商编码表（TP_XFC_CORP）读取数据，放入下拉列表
        string query = @"Select CORPNAME,CORPCODE  FROM TP_XFC_CORP order by CORPCODE ";

        context.DBOpen("Select");
        DataTable dataTable = context.ExecuteReader(query);
        if (dataTable.Rows.Count == 0)
        {
            return;
        }
        ddlProducer.Items.Add(new ListItem("---请选择---", ""));
        Object[] itemArray;
        ListItem li;
        for (int i = 0; i < dataTable.Rows.Count; ++i)
        {
            itemArray = dataTable.Rows[i].ItemArray;
            li = new ListItem("" + itemArray[1] + ":" + itemArray[0], (String)itemArray[1]);
            ddlProducer.Items.Add(li);
        }
       

    }
    #region 查询
    /// <summary>
    /// 查询按钮点击事件
    /// </summary>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //查询校验
        if (!queryValidation())
            return;

        if (hidCardType.Value == "usecard")
            bindUseCard();//查询用户卡
        else
            bindChargeCard();//查询充值卡
    }
    /// <summary>
    /// 用户卡GridView绑定数据源
    /// </summary>
    protected void bindUseCard()
    {
        //用户卡
        gvUseCardOrder.DataSource = queryUseCard();
        gvUseCardOrder.DataBind();
        gvUseCardOrder.SelectedIndex = -1;
    }
    /// <summary>
    /// 充值卡GridView绑定数据源
    /// </summary>
    protected void bindChargeCard()
    {
        //充值卡
        gvChargeCardOrder.DataSource = queryChargeCard();
        gvChargeCardOrder.DataBind();
        gvChargeCardOrder.SelectedIndex = -1;
    }
    /// <summary>
    /// 查询用户卡需求单
    /// </summary>
    /// <returns></returns>
    protected ICollection queryUseCard()
    {
        //查询用户卡，需求单号如果为XQ时，默认为未输入需求单号
        string applyOrderID = "";
        if (txtApplyOrderID.Text.Trim() != "XQ")
            applyOrderID = txtApplyOrderID.Text.Trim();
        DataTable data = ResourceManageHelper.callQuery(context, "queryUseCardApplyOrder", applyOrderID,
                                                        txtStartDate.Text.Trim(), txtEndDate.Text.Trim());
        if (data.Rows.Count == 0)
        {
            ResourceManageHelper.resetData(gvUseCardOrder, data);
            context.AddMessage("没有查询出任何记录");
            return null;
        }
        return new DataView(data);
    }
    /// <summary>
    /// 查询充值卡需求单
    /// </summary>
    /// <returns></returns>
    protected ICollection queryChargeCard()
    {
        //查询充值卡，需求单号如果为XQ时，默认为未输入需求单号
        string applyOrderID = "";
        if (txtApplyOrderID.Text.Trim() != "XQ")
            applyOrderID = txtApplyOrderID.Text.Trim();
        DataTable data = ResourceManageHelper.callQuery(context, "queryChargeCardApplyOrder", applyOrderID,
                                                        txtStartDate.Text.Trim(), txtEndDate.Text.Trim());
        if (data.Rows.Count == 0)
        {
            ResourceManageHelper.resetData(gvChargeCardOrder, data);
            context.AddMessage("没有查询出任何记录");
            return null;
        }
        return new DataView(data);
    }
    #endregion
    #region 校验
    /// <summary>
    /// 查询输入校验
    /// </summary>
    /// <returns>没有错误返回true,存在错误则返回false</returns>
    protected Boolean queryValidation()
    {
        //校验需求单号
        if (!string.IsNullOrEmpty(txtApplyOrderID.Text.Trim()) && txtApplyOrderID.Text.Trim() != "XQ")
        {
            if (Validation.strLen(txtApplyOrderID.Text.Trim()) != 18)
                context.AddError("A095470100：需求单号必须为18位", txtApplyOrderID);
            if (!Validation.isCharNum(txtApplyOrderID.Text.Trim()))
                context.AddError("A095470101：需求单必须为英数", txtApplyOrderID);
        }
        //校验日期
        ResourceManageHelper.checkDate(context, txtStartDate, txtEndDate, "A095470102", "A095470103", "A095470104");

        return !context.hasError();
    }
    /// <summary>
    /// 申请输入校验
    /// </summary>
    /// <returns>没有错误返回true,存在错误则返回false</returns>
    protected Boolean supplyValidation()
    {
        if (hidCardType.Value == "usecard")//用户卡
        {
            //卡面类型
            if (string.IsNullOrEmpty(selFaceType.SelectedValue))
                context.AddError("A095470116：请选择用户卡卡面类型", selFaceType);

            // 对起始卡号和结束卡号进行校验
            ResourceManageHelper.validateUseCardNoRange(context, txtFromCardNo, txtToCardNo, true, true);

            if (!context.hasError())
            {
                //起始卡号
                if (!txtFromCardNo.Text.Trim().Substring(0, 8).Equals("2150" + selFaceType.SelectedValue))
                    context.AddError("A095470132：起始卡号开头八位必须为2150+卡面类型编码", txtFromCardNo);
                else if (!isCardnoInSection(txtFromCardNo.Text.Trim().Substring(8, 8), selFaceType.SelectedValue.Substring(0, 2)))
                    context.AddError("A095470133：起始卡号后八位不在卡号段允许范围内", txtFromCardNo);

                //结束卡号
                if (!txtToCardNo.Text.Trim().Substring(0, 8).Equals("2150" + selFaceType.SelectedValue))
                    context.AddError("A095470134：结束卡号开头八位必须为2150+卡面类型编码", txtToCardNo);
                else if (!isCardnoInSection(txtToCardNo.Text.Trim().Substring(8, 8), selFaceType.SelectedValue.Substring(0, 2)))
                    context.AddError("A095470135：结束卡号后八位不在卡号段允许范围内", txtToCardNo);
            }
            //芯片类型
            if (string.IsNullOrEmpty(selChipType.SelectedValue))
                context.AddError("A095470198：芯片类型不能为空", selChipType);

            //卡片厂商
            if (string.IsNullOrEmpty(selProducer.SelectedValue))
                context.AddError("A095470199：卡片厂商不能为空", selProducer);

            //应用版本
            if (string.IsNullOrEmpty(txtAppVersion.Text.Trim()))
                context.AddError("A095470123：应用版本不能为空", txtAppVersion);
            else if (!Validation.isCharNum(txtAppVersion.Text.Trim()))
                context.AddError("A095470124:应用版本号必须为英数", txtAppVersion);

            //校验日期
            if (string.IsNullOrEmpty(txtEffDate.Text.Trim()))
                context.AddError("A095470187：起始有效日期不能为空", txtEffDate);
            if (string.IsNullOrEmpty(txtExpDate.Text.Trim()))
                context.AddError("A095470188：结束有效日期不能为空", txtExpDate);
            ResourceManageHelper.checkDate(context, txtEffDate, txtExpDate, "A095470125", "A095470126", "A095470127");

            //备注
            if (!string.IsNullOrEmpty(txtReMark.Text.Trim()))
                if (Validation.strLen(txtReMark.Text.Trim()) > 50)
                    context.AddError("A095470128:备注长度不能超过50位", txtReMark);

            //预留号段不可配置
            int fromCardNo = Convert.ToInt32(txtFromCardNo.Text.Trim().Substring(8, 8));
            int toCardNo = Convert.ToInt32(txtToCardNo.Text.Trim().Substring(8, 8));

            if ((30000801 <= fromCardNo && fromCardNo <= 39999999) || ((30000801 <= toCardNo && toCardNo <= 39999999)) || (fromCardNo <= 30000801 && 39999999 <= toCardNo))
                context.AddError("30000801到39999999为苏州市民卡预留号段，不允许配置");

            if ((60000001 <= fromCardNo && fromCardNo <= 79999999) || ((60000001 <= toCardNo && toCardNo <= 79999999)) || (fromCardNo <= 60000001 && 79999999 <= toCardNo))
                context.AddError("60000001到79999999为张家港市民卡预留号段，不允许配置");
        }
        else //充值卡
        {
            // 检查起始卡号和终止卡号的格式（非空、14位、英数）
            ResourceManageHelper.validateChargeCardNoRange(context, txtFromChargeCardno, txtToChargeCardno, true);

            // 检查充值卡是否都有相同的面值
            
            //DataTable data = ChargeCardHelper.callQuery(context, "F1", txtFromChargeCardno.Text, txtToChargeCardno.Text);
            //if (data.Rows.Count != 1)
            //{
            //    context.AddError("A007P01211: 位于起始卡号和终止卡号之间的充值卡不具有相同面值或卡片不在库，请重新选择起讫卡号");
            //}
            //else
            //{
            //    if (!data.Rows[0][0].ToString().ToLower().Equals(getChargeCardDataKeys("VALUECODE").Substring(0, 1).ToLower()))
            //        context.AddError("A095470186:下单充值卡面值与申请单申请的充值卡面值不一致!");
            //}
            if (txtFromChargeCardno.Text.Trim().ToString() != "" && txtToChargeCardno.Text.Trim().ToString() != "")
            {
                string startcardno = txtFromChargeCardno.Text;
                string endcardno = txtToChargeCardno.Text;
                if (startcardno.Substring(0, 6) != endcardno.Substring(0, 6))
                {
                    context.AddError("A007P01211: 起始卡号和终止卡号前六位必须相同");
                }
                else if(startcardno.Substring(4, 1) !=txtCardValue.Text.Trim().Substring(0, 1))
                {
                    context.AddError("A007P01212: 起始卡号和终止卡号的对应面值不正确");
                }
                else if (startcardno.Substring(5, 1) != ddlProducer.SelectedValue)
                {
                    context.AddError("A007P01213: 起始卡号和终止卡号的对应卡片厂商不正确，请重新选择卡片厂商");
                }
            }
            //卡片厂商
            if (string.IsNullOrEmpty(ddlProducer.SelectedValue))
                context.AddError("A095470199：卡片厂商不能为空", ddlProducer);
            //备注
            if (!string.IsNullOrEmpty(txtChargeReMark.Text.Trim()))
                if (Validation.strLen(txtChargeReMark.Text.Trim()) > 50)
                    context.AddError("A095470131:备注长度不能超过50位", txtChargeReMark);

            //批次号
            if (string.IsNullOrEmpty(txtBATCHNO.Text.Trim()))
                context.AddError("A095470124：批次号不能为空", txtBATCHNO);
            else if (!Validation.isCharNum(txtBATCHNO.Text.Trim()))
                context.AddError("A095470125:批次号必须为英数", txtBATCHNO);
            else if (txtBATCHNO.Text.Trim().Length<2)
                context.AddError("A095470126:批次号长度必须为2位", txtBATCHNO);
            //订购数量
            if (int.Parse(txtChargeCardNum.Text) > int.Parse(getChargeCardDataKeys("CARDNUM")))
            {
                context.AddError("A095470130:订购数量不能大于下单数量");
            }
            if (int.Parse(txtChargeCardNum.Text)==0)
            {
                context.AddError("A095470131:订购数量不可为0");
            }
           
            //校验日期
            if (string.IsNullOrEmpty(txtEffectiveDate.Text.Trim()))
                context.AddError("A095470189：有效日期不能为空", txtEffectiveDate);
            else if (!Validation.isDate(txtEffectiveDate.Text.Trim(), "yyyyMMdd"))
                context.AddError("A095470190：有效日期格式必须为yyyyMMdd", txtDate);
        }

        return !context.hasError();
    }
    /// <summary>
    /// 校验输入的卡号是否在允许的号段范围内
    /// </summary>
    /// <returns>在范围内返回true,不在则返回false</returns>
    protected Boolean isCardnoInSection(string cardno, string cardtypecode)
    {
        string queryIsCardnoInSection = "SELECT 1 FROM TD_M_CARDNOCONFIG WHERE CARDTYPECODE = :CARDTYPECODE AND :CARDNO BETWEEN BEGINCARDNO AND ENDCARDNO";
        context.DBOpen("Select");
        context.AddField(":CARDTYPECODE").Value = cardtypecode;
        context.AddField(":CARDNO").Value = cardno;
        DataTable isCardnoInSectionData = context.ExecuteReader(queryIsCardnoInSection);

        if (isCardnoInSectionData.Rows.Count == 0)
        {
            return false;
        }
        return true;
    }
    #endregion
    #region 提交
    /// <summary>
    /// 提交按钮点击事件
    /// </summary>
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        //提交校验
        if (!supplyValidation())
            return;

        //定义变量，用作存储过程输入参数
        string cardordertype = "";     //订购单类型
        string applyorderid = "";      //需求单号
        string cardtypecode = "";      //卡片类型编码
        string cardfacetypecode = "";  //卡面类型编码
        string cardsamplecode = "";    //卡样编码
        string cardname = "";          //卡片名称
        string cardfaceaffirmway = ""; //卡面确认方式
        string cardvalue = "";         //面值
        string cardnum = "";           //卡片数量
        string requiredate = "";       //要求到货日期
        string begincardno = "";       //开始卡号
        string endcardno = "";         //结束卡号
        string cardchiptypecode = "";  //芯片类型编码
        string costypecode = "";       //COS类型编码
        string manutypecode = "";      //卡片厂商编码
        string appverno = "";          //应用版本号
        string validbegindate = "";    //有效起始日期
        string validenddate = "";      //有效结束日期
        string remark = "";

        if (hidCardType.Value == "usecard")//如果是用户卡
        {
            applyorderid = getUseCardDataKeys("APPLYORDERID");
            cardordertype = getUseCardDataKeys("ORDERTYPE").Substring(0, 2);
            cardtypecode = selFaceType.SelectedValue.Substring(0, 2);
            cardfacetypecode = selFaceType.SelectedValue;
            ViewState["facetypename"] = selFaceType.SelectedItem.Text; //卡面类型名称
            cardsamplecode = txtCardSampleCode.Text.Trim();
            if (cardsamplecode.Trim() != "")
            {
                ViewState["cardsamplecode"] = cardsamplecode; //存在卡样的时候，保存卡样
            }
            if (cardordertype == "02") //用户卡新制卡片
            {
                cardname = getUseCardDataKeys("CARDNAME");
                cardfaceaffirmway = getUseCardDataKeys("WAY").Substring(0, 1);
                if (cardsamplecode.Trim() == "") //不存在卡样的时候 保存卡片名称
                {
                    ViewState["cardsamplecode"] = cardname;
                }
            }
            cardnum = txtCardSum.Text.Trim();
            ViewState["cardnum"] = cardnum;         //保存卡片数量
            requiredate = txtDate.Text.Trim();
            ViewState["requiredate"] = requiredate; //保存要求到货日期
            begincardno = txtFromCardNo.Text.Trim();
            ViewState["begincardno"] = begincardno; //保存起始卡号
            endcardno = txtToCardNo.Text.Trim();
            ViewState["endcardno"] = endcardno;     //保存结束卡号
            cardchiptypecode = selChipType.SelectedValue;
            costypecode = selCosType.SelectedValue;
            manutypecode = selProducer.SelectedValue;
            appverno = txtAppVersion.Text.Trim();
            validbegindate = txtEffDate.Text.Trim();
            validenddate = txtExpDate.Text.Trim();
            remark = txtReMark.Text.Trim();
            ViewState["remark"] = remark;        //保存备注
        }
        else //如果是充值卡
        {
            applyorderid = getChargeCardDataKeys("APPLYORDERID");
            cardordertype = "03"; //充值卡
            cardvalue = txtCardValue.Text.Trim().Substring(0, 1);
            ViewState["cardvalue"] = txtCardValue.Text.Trim(); //保存充值卡面额
            requiredate = txtChargeCardDate.Text.Trim();
            ViewState["requiredate"] = requiredate;            //保存要求到货日期
            begincardno = txtFromChargeCardno.Text.Trim();
            ViewState["begincardno"] = begincardno;            //保存起始卡号
            endcardno = txtToChargeCardno.Text.Trim();
            ViewState["endcardno"] = endcardno;                //保存结束卡号
            cardnum = txtChargeCardNum.Text.Trim();
            ViewState["cardnum"] = cardnum;                    //保存卡片数量
            remark = txtChargeReMark.Text.Trim();
            ViewState["remark"] = remark;                      //保存备注
            manutypecode = ddlProducer.SelectedValue;          //制卡厂商
            appverno = txtBATCHNO.Text.Trim();                   //批次号
            validenddate = txtEffectiveDate.Text.Trim();             //有效日期
        }

        //参数赋值
        context.SPOpen();
        context.AddField("P_CARDORDERTYPE").Value = cardordertype;
        context.AddField("P_APPLYORDERID").Value = applyorderid;
        context.AddField("P_CARDTYPECODE").Value = cardtypecode;
        context.AddField("P_CARDSURFACECODE").Value = cardfacetypecode;
        context.AddField("P_CARDSAMPLECODE").Value = cardsamplecode;
        context.AddField("P_CARDNAME").Value = cardname;
        context.AddField("P_CARDFACEAFFIRMWAY").Value = cardfaceaffirmway;
        context.AddField("P_VALUECODE").Value = cardvalue;
        context.AddField("P_CARDNUM").Value = cardnum;
        context.AddField("P_REQUIREDATE").Value = requiredate;
        context.AddField("P_BEGINCARDNO").Value = begincardno;
        context.AddField("P_ENDCARDNO").Value = endcardno;
        context.AddField("P_CARDCHIPTYPECODE").Value = cardchiptypecode;
        context.AddField("P_COSTYPECODE").Value = costypecode;
        context.AddField("P_MANUTYPECODE").Value = manutypecode;
        context.AddField("P_APPVERNO").Value = appverno;
        context.AddField("P_VALIDBEGINDATE").Value = validbegindate;
        context.AddField("P_VALIDENDDATE").Value = validenddate;     
        context.AddField("P_REMARK").Value = remark;

        context.AddField("P_ORDERID", "String", "output", "18", null);

        bool ok = context.ExecuteSP("SP_RM_CARDORDER");

        if (ok)
        {
            AddMessage("下单成功");
            ViewState["applyorderid"] = "" + context.GetFieldValue("P_ORDERID");
            //打印
            if (chkOrder.Checked)
            {
                string printHtml = "";
                if (hidCardType.Value == "usecard")   //如果是用户卡
                {
                    if (cardsamplecode == "")
                    {
                        cardsamplecode = cardname;
                    }
                    printHtml = RMPrintHelper.GetCardOrderPrintText(context, ViewState["applyorderid"].ToString(),
                        selFaceType.SelectedItem.Text, cardsamplecode, cardnum, begincardno, endcardno, requiredate, remark);
                }
                else  //充值卡
                {
                    printHtml = RMPrintHelper.GetChargeCardOrderPrintText(context, ViewState["applyorderid"].ToString(),
                        txtCardValue.Text.Trim(), cardnum, begincardno, endcardno, requiredate, remark);
                }
                printarea.InnerHtml = printHtml;
                //执行打印脚本
                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Print", "printOrderdiv('printarea');", true);
            }
            //清空
            clear();
            //更新列表
            if (hidCardType.Value == "usecard")
                bindUseCard();
            else
                bindChargeCard();

            btnSubmit.Enabled = false;
            btnPrint.Enabled = true;
        }
    }



    /// <summary>
    /// 清空输入项
    /// </summary>
    protected void clear()
    {
        txtCardType.Text = "";            //卡片类型
        selFaceType.SelectedValue = "";   //卡面类型
        txtCardSampleCode.Text = "";      //卡样编码
        txtDate.Text = "";                //要求到货日期
        txtFromCardNo.Text = "";          //起始卡号
        txtToCardNo.Text = "";            //结束卡号
        txtCardSum.Text = "";             //卡片数量
        selChipType.SelectedValue = "01"; //芯片类型
        selCosType.SelectedValue = "01";  //COS类型
        txtEffDate.Text = "";             //起始有效日期
        txtExpDate.Text = "";             //结束有效日期
        selProducer.SelectedValue = "01"; //卡片厂商
        txtReMark.Text = "";              //备注
        txtAppVersion.Text = "";          //应用版本

        txtCardValue.Text = "";         //面值
        txtChargeCardDate.Text = "";     //要求到货日期
        txtFromChargeCardno.Text = "";  //起始卡号
        txtToChargeCardno.Text = "";    //结束卡号
        txtChargeCardNum.Text = "";     //卡片数量
        txtChargeReMark.Text = "";      //备注
        ddlProducer.SelectedValue = ""; //卡片厂商
        txtBATCHNO.Text = "";           //批次号
        txtEffectiveDate.Text = "";     //有效日期
        selFaceType.Enabled = false;//卡面类型选框不可用
        //清空卡号段列表
        ResourceManageHelper.resetData(gvResult, null);
    }
    #endregion

    /// <summary>
    /// 打印按钮点击事件
    /// </summary>
    protected void btnPrint_Click(object sender, EventArgs e)
    {
        string applyorderid ="";
        string cardnum = "";
        string requiredate = "";
        string begincardno = "";
        string endcardno = "";
        string remark = "";
        string printHtml = "";
        if (hidCardType.Value == "usecard") //如果是用户卡
        {
            applyorderid = ViewState["applyorderid"].ToString();
            string facetypename = ViewState["facetypename"].ToString();
            string cardsamplecode = ViewState["cardsamplecode"].ToString();
            cardnum = ViewState["cardnum"].ToString();
            requiredate = ViewState["requiredate"].ToString();
            begincardno = ViewState["begincardno"].ToString();
            endcardno = ViewState["endcardno"].ToString();
            remark = ViewState["remark"].ToString();
            printHtml = RMPrintHelper.GetCardOrderPrintText(context, applyorderid, facetypename,
                        cardsamplecode, cardnum, begincardno, endcardno, requiredate, remark);
        }
        else
        {
            applyorderid = ViewState["applyorderid"].ToString();
            string cardvalue = ViewState["cardvalue"].ToString();
            cardnum = ViewState["cardnum"].ToString();
            requiredate = ViewState["requiredate"].ToString();
            begincardno = ViewState["begincardno"].ToString();
            endcardno = ViewState["endcardno"].ToString();
            remark = ViewState["remark"].ToString();
            printHtml = RMPrintHelper.GetChargeCardOrderPrintText(context, applyorderid, cardvalue, cardnum, begincardno, endcardno, requiredate, remark);
        }
        printarea.InnerHtml = printHtml;
        //执行打印脚本
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Print", "printOrderdiv('printarea');", true);
    }

    /// <summary>
    /// 初始化列表
    /// </summary>
    private void showOrderNonDataGridView()
    {
        gvUseCardOrder.DataSource = new DataTable();
        gvUseCardOrder.DataBind();
        gvChargeCardOrder.DataSource = new DataTable();
        gvChargeCardOrder.DataBind();
    }
    /// <summary>
    /// 初始化列表
    /// </summary>
    private void showNonDataGridView()
    {
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
    }
    /// <summary>
    /// 卡面类型变更事件，查询该卡面所属卡类型的卡号段
    /// </summary>
    public void selFaceType_Change(object sender, EventArgs e)
    {
        //查询卡号段
        Int32 cardnum = Convert.ToInt32(getUseCardDataKeys("CARDNUM")) - Convert.ToInt32(getUseCardDataKeys("ALREADYORDERNUM"));
        setCardnoSection(selFaceType.SelectedValue.Substring(0, 2), cardnum, sender, e);
    }

    #region 用户卡gridview事件
    protected void gvUseCardOrder_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件

            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvUseCardOrder','Select$" + e.Row.RowIndex + "')");
        }
    }
    //用户卡Gridview选择行
    public void gvUseCardOrder_SelectedIndexChanged(object sender, EventArgs e)
    {
        txtCardType.Text = getUseCardDataKeys("CARDTYPE");
        string cardfacecode = "";
        if (getUseCardDataKeys("ORDERTYPE").Substring(0, 2) == "01")
        {
            //如果制卡类型是01：存货补货，获取卡面类型，初始化卡号段
            cardfacecode = getUseCardDataKeys("CARDFACE").Substring(0, 4);
            //卡面类型赋值
            selFaceType.SelectedValue = cardfacecode;
            //查询卡号段
            Int32 cardnum = Convert.ToInt32(getUseCardDataKeys("CARDNUM")) - Convert.ToInt32(getUseCardDataKeys("ALREADYORDERNUM"));
            setCardnoSection(getUseCardDataKeys("CARDFACE").Substring(0, 2), cardnum, sender, e);
            selFaceType.Enabled = false;//卡面类型选框不可用
        }
        else
        {
            //如果制卡类型是02：新制卡片，需要选择卡面类型
            //清空卡号段列表
            ResourceManageHelper.resetData(gvResult, null);
            selFaceType.Enabled = true;
        }

        //卡面类型赋值
        selFaceType.SelectedValue = cardfacecode;
        //卡样编码赋值
        txtCardSampleCode.Text = getUseCardDataKeys("CARDSAMPLECODE");
        //要求到货日期赋值
        txtDate.Text = getUseCardDataKeys("REQUIREDATE");

        btnSubmit.Enabled = true;
    }
    //用户卡翻页事件
    protected void gvUseCardOrder_Page(object sender, GridViewPageEventArgs e)
    {
        gvUseCardOrder.PageIndex = e.NewPageIndex;
        bindUseCard();
    }
    //获取关键字的值
    public String getUseCardDataKeys(string keysname)
    {
        return gvUseCardOrder.DataKeys[gvUseCardOrder.SelectedIndex][keysname].ToString();
    }
    #endregion
    #region 充值卡gridview事件
    protected void gvChargeCardOrder_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件

            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvChargeCardOrder','Select$" + e.Row.RowIndex + "')");
        }
    }
    //充值卡Gridview选择事件
    public void gvChargeCardOrder_SelectedIndexChanged(object sender, EventArgs e)
    {
        txtCardValue.Text = getChargeCardDataKeys("VALUECODE");
        txtChargeCardDate.Text = getChargeCardDataKeys("REQUIREDATE");
        txtChargeCardNum.Text = getChargeCardDataKeys("CARDNUM");
        btnSubmit.Enabled = true;
        ddlProducer.SelectedValue = "";
        txtFromChargeCardno.Text = string.Empty;
        txtToChargeCardno.Text = string.Empty;
        txtBATCHNO.Text = string.Empty;
        //TextBox1.Text = string.Empty;
        txtChargeReMark.Text = string.Empty;
   
    }
    //充值卡翻页事件
    protected void gvChargeCardOrder_Page(object sender, GridViewPageEventArgs e)
    {
        gvChargeCardOrder.PageIndex = e.NewPageIndex;
        bindChargeCard();
    }
    //获取关键字的值
    public String getChargeCardDataKeys(string keysname)
    {
        return gvChargeCardOrder.DataKeys[gvChargeCardOrder.SelectedIndex][keysname].ToString();
    }
    #endregion
    #region 卡号段gridview事件
    protected void gvResult_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件

            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResult','Select$" + e.Row.RowIndex + "')");
        }
    }
    //卡号段Gridview选择事件
    public void gvResult_SelectedIndexChanged(object sender, EventArgs e)
    {
        string beginCardno = ""; //定义起始卡号
        string endCardno = ""; //定义结束卡号

        //起始卡号为2150+卡面类型编码+分配的卡号
        beginCardno = "2150" + selFaceType.SelectedValue + getDataKeys("startcardno");
        //未下订购单数量等于订购数量-已订购数量
        Int64 cardnum = Convert.ToInt32(getUseCardDataKeys("CARDNUM")) - Convert.ToInt32(getUseCardDataKeys("ALREADYORDERNUM"));
        //结束卡号根据起始卡号和卡片数量计算得出
        if (Convert.ToInt64(getDataKeys("cardnum")) >= cardnum)
            //当选择的号段数量大于订单要求数量时，按照订单要求计算结束卡号
            endCardno = (Convert.ToInt64(beginCardno) + cardnum - 1).ToString();
        else
            //当选择的号段数量小于订单要求数量时，按照号段数量计算结束卡号
            endCardno = (Convert.ToInt64(beginCardno) + Convert.ToInt64(getDataKeys("cardnum")) - 1).ToString();

        //起始卡号和结束卡号赋值
        txtFromCardNo.Text = beginCardno;
        txtToCardNo.Text = endCardno;

        //调用JS，计算卡片数量
        ScriptManager.RegisterStartupScript(this, this.GetType(), "cardnumchange", "Change();", true);
    }
    //获取关键字的值
    public String getDataKeys(string keysname)
    {
        return gvResult.DataKeys[gvResult.SelectedIndex][keysname].ToString();
    }
    #endregion
    //onRowDataBound公共事件
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            ResourceManageHelper.ClearRowDataBound(e);
        }
    }

    #region 配置卡号段
    /// <summary>
    /// 查询卡类型所属卡号段，并自动匹配生成卡号
    /// </summary>
    /// <param name="cardtypecode">卡类型编码</param>
    /// <param name="cardnum">卡片数量</param>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    /// <returns></returns>
    protected void setCardnoSection(string cardtypecode, Int32 cardnum, object sender, EventArgs e)
    {
        //清空卡号段列表
        ResourceManageHelper.resetData(gvResult, null);

        //string sql = "";
        //sql += " select min(t.cardno) startcardno , " + //最小卡号
        //       "        max(t.cardno) endcardno , " + //最大卡号
        //       "       (max(t.cardno) - min(t.cardno) +1) cardnum " +
        //       " from  (select n.cardno  " +
        //       "        from tf_f_cardnoconfig n " +
        //       "        where n.cardtypecode = '" + cardtypecode + "' " +
        //       "        and   not exists (select 1 from TD_M_CARDNO_EXCLUDE b where substr(b.cardno,-8) = n.cardno ) " + //排除排重表中已有卡号
        //       "        and   not exists (select 1 from tl_r_icuser a where substr(a.cardno,0,4) = '2150'and substr(a.cardno,-8) = n.cardno ) " + //排除卡库存表中已有卡号
        //       "        order by n.cardno) t " +
        //       " group by t.cardno - rownum ";

        //string excutesql = "select re.startcardno , re.endcardno , re.cardnum from ( " + sql + " ) re where re.cardnum > 9999 order by re.cardnum desc";

        string excutesql = "select startcardno , endcardno , cardnum from  TF_F_CARDORDER_EXCLUDE  where cardtypecode = '" + cardtypecode + "' and cardnum > 19 order by cardnum desc";

        context.DBOpen("Select");
        DataTable CardNoData = context.ExecuteReader(excutesql);
       
        if (CardNoData.Rows.Count == 0)
        {
            context.AddError("该卡类型没有可用的卡号段");
            return;
        }
        
        DataTable selectRowData = new DataTable();

        gvResult.DataSource = CardNoData;
        selectRowData = CardNoData;
        gvResult.DataBind();

        
        //选择行数
        int selectIndex = -1;
        //自动选中第一个号段中号数量大于要求卡片数量的行
        for (int i = 0; i < selectRowData.Rows.Count; ++i)
        {
            if (Convert.ToInt32(selectRowData.Rows[i][2]) < cardnum)
            {
                selectIndex = i - 1;
                break;
            }
            //如果到最后一行也没有小于订购数量的号段数量，则选中最后一行
            if (i == selectRowData.Rows.Count - 1)
            {
                selectIndex = i;
                break;
            }
        }
        gvResult.SelectedIndex = selectIndex;
        if (selectIndex != -1)
            //调用gvResult列表选中事件
            gvResult_SelectedIndexChanged(sender, e);

    }
    #endregion

    /// <summary>
    /// 选择厂家自动生成充值卡卡号段 add by youyue 20130715
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ddlProducer_change(object sender, EventArgs e)
    {
        if (ddlProducer.SelectedValue != "" && txtCardValue.Text.Trim()!="")
        { 
            string year = DateTime.Today.Year.ToString().Substring(2,2);
            string value = txtCardValue.Text.Trim().Substring(0, 1);
            DataTable dt = ResourceManageHelper.callQuery(context, "queryMaxCardNo", ddlProducer.SelectedValue, year, value);//获取充值卡账户表和排重表中相应年份，厂家，面值对应的最大卡号   
            string newCardno = dt.Rows[0][0].ToString();
            DataTable dtData = ResourceManageHelper.callQuery(context, "queryMaxCardNo2");
            string k = "00000000"+(int.Parse(dtData.Rows[0].ItemArray[0].ToString())+1).ToString();
            string cardnumber = k.Remove(0,k.Length-8);//8位自增 add by youyue
            if (dt.Rows.Count > 0 && newCardno != "")
            {

                string batchno = newCardno.Substring(2, 2);//相应年份，厂家，面值对应的最大批次号
                hidBatchno.Value = batchno;
                string number = "";
                if (int.Parse(batchno) == 99) //如果相应年份，厂家，面值对应的最大批次号已经为99
                {
                    context.AddError("A095470127:库中对应的卡号段批次号已经为99，不可再生成充值卡卡号段");
                    return;
                }
                else
                {
                    if (int.Parse(batchno).ToString().Length < 2)
                    {
                        number = ("00" + (int.Parse(batchno) + 1).ToString()).Substring(1, 2);
                    }
                    else
                    {
                        number = ("00" + (int.Parse(batchno) + 1).ToString()).Substring(2, 2);
                    }

                    txtBATCHNO.Text = number;//自动填写批次号（不可修改）
                    string startcardno = year + txtBATCHNO.Text + value + ddlProducer.SelectedValue + cardnumber;//cardnumber是自增后8位
                    int num =int.Parse(txtChargeCardNum.Text.Trim());
                    string p = "00000000" + (int.Parse(cardnumber) + num-1).ToString();
                    string endnum = year + txtBATCHNO.Text + value + ddlProducer.SelectedValue + p.Remove(0,p.Length-8);
                    txtFromChargeCardno.Text = startcardno;
                    txtToChargeCardno.Text = endnum;
                }
            }
            else
            {
                txtBATCHNO.Text = "01";//默认批次号为01
                string startcardno = year + txtBATCHNO.Text + value + ddlProducer.SelectedValue + cardnumber;
                int num = int.Parse(txtChargeCardNum.Text.Trim());
                string p = "00000000" + (int.Parse(cardnumber) + num-1).ToString();
                string endnum = year + txtBATCHNO.Text + value + ddlProducer.SelectedValue + p.Remove(0, p.Length - 8);
                txtFromChargeCardno.Text = startcardno;
                txtToChargeCardno.Text = endnum;
            }
        }
    }
}