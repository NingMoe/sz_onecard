using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using Master;
using PDO.PersonalBusiness;
using TM;
using System.IO;
/// <summary>
/// 换乘领奖 
/// 董翔 20140416
/// update
/// 20150302 如果中奖卡专有账户已挂失，则领奖卡替换为挂失补账户卡
/// </summary>
public partial class ASP_TransferLottery_TL_Award : Master.Master
{
    /// <summary>
    /// 页面初始化
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            ASHelper.initSexList(selCustsex);
            ASHelper.initPaperTypeList(context, selPapertype);
            //有换乘领奖领充值卡权限时领充值卡选项卡可用
            if (!CommonHelper.HasOperPower(context, "201210"))
            {
                liChargeCard.Visible = false;
            }
            btnPrintPZ.Enabled = false;
            Session["PicDataOther"] = null;//单张导入照片的Session


            //查询用户打印方式 add by youyue 20140722
            string sql = "select PRINTMODE from TD_M_INSIDESTAFFPRINT where STAFFNO = '" + context.s_UserID + "'";
            context.DBOpen("Select");
            DataTable dt = context.ExecuteReader(sql);
            if (dt.Rows.Count == 1 && dt.Rows[0]["PRINTMODE"].ToString().Trim() == "1")
            {
                chkPingzheng.Checked = true;//打印方式是针式打印
            }
            else if (dt.Rows.Count == 1 && dt.Rows[0]["PRINTMODE"].ToString().Trim() == "2")
            {
                chkPingzhengRemin.Checked = true;//打印方式是热敏打印
            }
            else
            {
                chkPingzheng.Checked = true;//如果没有设置则默认是针式打印
            }
        }
        
    }

    /// <summary>
    /// 读卡校验
    /// </summary>
    /// <returns></returns>
    private Boolean ReadCardValidation(TextBox text)
    {
        //对卡号进行非空、长度、数字检验 
        if (text.Text.Trim() == "")
            context.AddError("A001004113", txtCardno);
        else
        {
            if (Validation.strLen(text.Text.Trim()) != 16)
                context.AddError("A001004114", text);
            else if (!Validation.isNum(text.Text.Trim()))
                context.AddError("A001004115", text);
        }

        return !(context.hasError());

    }

    //读卡
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        DataTable dt = null;        //社保卡号转电子钱包卡号
        if (txtCardno.Text.StartsWith("A"))
        {
            dt = SPHelper.callQuery("SP_TL_Query", context, "QUERY_CARDNO", txtCardno.Text);
            if (dt.Rows.Count > 0)
            {
                txtCardno.Text = dt.Rows[0]["CARDNO"].ToString(); 
            }
        }
        //对输入卡号进行检验
        if (!ReadCardValidation(txtCardno))
            return;
        txtCardNoC.Text = "";
        txtCusname.Text = "";
        selPapertype.SelectedIndex = -1;
        txtCustpaperno.Text = "";
        selCustsex.SelectedIndex = -1;
        txtCustphone.Text = "";
        txtChargeCard.Text = "";
        gvResult.SelectedIndex = -1;
        hidBonus.Value = "0";
        hidCardTypeCode.Value = "";
        btnAward.Enabled = false;
        dt = SPHelper.callQuery("SP_TL_Query", context, "QUERY_AWARDS", txtCardno.Text);
        if (dt.Rows.Count > 0)
        { 
            //如果是电子钱包卡号
            if (txtCardno.Text.StartsWith("2150"))
            {
                txtCardNoC.Text = txtCardno.Text; 
            }
            List<String> list = new List<string>();
            list.Add("CUSTNAME");
            CommonHelper.AESDeEncrypt(dt, list);
            if(dt.Rows.Count == 1)
            {
                gvResult.SelectedIndex = 0;
                SelectAward(Convert.ToInt32(dt.Rows[0]["BONUS"]) * 100, dt.Rows[0]["CARDTYPECODE"].ToString(),
                    dt.Rows[0]["CARDNO"].ToString(), dt.Rows[0]["LOTTERYPERIOD"].ToString(), dt.Rows[0]["AWARDSNAME"].ToString(), dt.Rows[0]["TAX"].ToString());
            }  
        }
        else
        {
            context.AddError("该卡没有中奖记录"); 
        }
        gvResult.DataSource = dt;
        gvResult.DataBind();
        btnPrintPZ.Enabled = false;//add by youyue 20140729
    }

 
    /// <summary>
    /// 生成表格
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gvResult_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件 
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResult','Select$" + e.Row.RowIndex + "')");
        }
    }

    /// <summary>
    /// 选择行
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    public void gvResult_SelectedIndexChanged(object sender, EventArgs e)
    {
        GridViewRow row = gvResult.SelectedRow;
        if (row != null)
        {
            SelectAward(Int32.Parse(row.Cells[4].Text.ToString().Trim())* 100,
                row.Cells[1].Text.ToString().Trim() == "电子钱包卡" ? "0" : "1", row.Cells[0].Text.ToString().Trim(), row.Cells[2].Text.ToString().Trim(), row.Cells[3].Text.ToString().Trim(), row.Cells[7].Text.ToString().Trim());  
        }　
    }

    /// <summary>
    /// 选择一条中奖记录
    /// </summary>
    private void SelectAward(int bonus, string cardTypeCode, string cardno, string lotteryPeriod,string awardesName,string tax)
    {
        //查询中奖卡专有账户是否挂失，挂失则替换领奖卡号为挂失补账户卡号
        if (cardTypeCode == "0")
        {
            DataTable dt = SPHelper.callQuery("SP_TL_Query", context, "QUERY_ISBLOCK", cardno);
            if(dt.Rows.Count >0)
            {
                context.AddMessage("该专有账户已挂失补账户，领奖卡号为挂失补账户卡号");
                txtCardNoC.Text = dt.Rows[0]["cardno"].ToString();
            }
        }
        hidBonus.Value = bonus.ToString();
        hidCardTypeCode.Value = cardTypeCode;
        hideCardno.Value = cardno;
        hidLotteryPeriod.Value = lotteryPeriod;
        hideAwardsName.Value = awardesName;// 奖项 add by youyue 20140729
        hidTax.Value = tax;//扣税 add by youyue 
        btnAward.Enabled = true;
    }


    /// <summary>
    /// 领奖信息验证
    /// </summary>
    /// <returns></returns>
    private bool ValidateCharge()
    {
        if (hidAwardType.Value == "0")
        {
            //对输入卡号进行检验
            ReadCardValidation(txtCardNoC);
        }
        else
        {
            //对充值卡卡号校验
            if (string.IsNullOrEmpty(txtChargeCard.Text))
                context.AddError("请输入充值卡号", txtChargeCard);
            else if (txtChargeCard.Text.IndexOf(',', 0) > -1)
            { 
                foreach(string s in txtChargeCard.Text.Split(','))
                {
                    if (string.IsNullOrEmpty(s))
                    {
                        context.AddError("充值卡号不能为空", txtChargeCard);
                        break;
                    }
                    else if (s.Length != 14)
                    {
                        context.AddError("充值卡号:"+ s + "不正确", txtChargeCard);
                        break;
                    }
                    else if (!ChargeCardHelper.validateCardNo(s))
                    {
                        context.AddError("充值卡号:" + s + "不正确", txtChargeCard);
                        break;
                    }
                }
            }
        }
        #region 对用户信息进行验证
        //对用户姓名进行非空、长度检验
        if (txtCusname.Text.Trim() == "")
            context.AddError("A001001111", txtCusname);
        else if (Validation.strLen(txtCusname.Text.Trim()) > 50)
            context.AddError("A001001113", txtCusname);


        //对证件类型进行非空检验
        if (selPapertype.SelectedValue == "")
            context.AddError("A001001117", selPapertype);

        
        //对联系电话进行非空、长度、数字检验  
        if (txtCustphone.Text.Trim() == "")
            context.AddError("A001001126:请输入手机号码", txtCustphone);
        else if (Validation.strLen(txtCustphone.Text.Trim()) > 20)
            context.AddError("A001001126:手机号码长度大于20位", txtCustphone);
        else if (!Validation.isNum(txtCustphone.Text.Trim()))
            context.AddError("A001001125:手机号码不是数字", txtCustphone);
        
         
        //对证件号码进行非空、长度、英数字检验
        if (txtCustpaperno.Text.Trim() == "")
            context.AddError("A001001121", txtCustpaperno);
        else if (!Validation.isCharNum(txtCustpaperno.Text.Trim()))
            context.AddError("A001001122", txtCustpaperno);
        else if (Validation.strLen(txtCustpaperno.Text.Trim()) > 20)
            context.AddError("A001001123", txtCustpaperno); 
        #endregion
        //校验导入单张文件格式及大小 add by youyue 20140724
        Session["PicDataOther"] = null;
        if (FileUpload1.FileName != "")
        {
            string[] strPics = { ".jpg", ".bmp", ".gif", ".jpeg", ".png" };
            int index = Array.IndexOf(strPics, Path.GetExtension(FileUpload1.FileName).ToLower());
            if (index == -1)
            {
                context.AddError("A094780002:上传文件格式必须为jpg|bmp|jpeg|png|gif");
              
            }
           
            int len = FileUpload1.FileBytes.Length;
            if (len > 1024 * 1024 * 1)
            {
                context.AddError("A094780018：上传文件不可大于1M", FileUpload1);
            }
           
            Session["PicDataOther"] = GetPicture(FileUpload1);
        }
    
        return !(context.hasError());
    }

    /// <summary>
    /// 领奖读卡
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnReadCardC_Click(object sender, EventArgs e)
    {
        //对输入卡号进行检验
        if (!ReadCardValidation(txtCardNoC))
            return;
        TMTableModule tmTMTableModule = new TMTableModule();

        //卡账户有效性检验
        SP_AccCheckPDO pdo = new SP_AccCheckPDO();
        pdo.CARDNO = txtCardNoC.Text;

        PDOBase pdoOut;
        bool ok = TMStorePModule.Excute(context, pdo, out pdoOut);

        if (ok == false)
        {
            return;
        }
        DataTable dt = SPHelper.callQuery("SP_TL_Query", context, "QUERY_CUSTOMERINFO", txtCardNoC.Text);
        if (dt.Rows.Count > 0)
        {
            List<String> list = new List<string>();
            list.Add("CUST_NAME");
            list.Add("PAPER_NO");
            list.Add("CUST_PHONE");
            CommonHelper.AESDeEncrypt(dt, list);
            txtCusname.Text = dt.Rows[0]["CUST_NAME"].ToString();
            selPapertype.SelectedValue = dt.Rows[0]["PAPER_TYPE_CODE"].ToString();
            txtCustpaperno.Text = dt.Rows[0]["PAPER_NO"].ToString();
            txtCustphone.Text = dt.Rows[0]["CUST_PHONE"].ToString();
            selCustsex.Text = dt.Rows[0]["CUST_SEX"].ToString();
        }
        else
        {
            txtCusname.Text = "";
            selPapertype.SelectedIndex = -1;
            txtCustpaperno.Text = "";
            txtCustphone.Text = "";
            selCustsex.SelectedIndex = -1;
            context.AddMessage("该卡没有开通专有账户，请输入个人信息以开通专有账户");
        }
        btnPrintPZ.Enabled = false;
    }

    /// <summary>
    /// 领奖
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnAward_Click(object sender, EventArgs e)
    {
        if(hidAwardType.Value == "0")
            ScriptManager.RegisterStartupScript(this, this.GetType(), "initPage",
                  "SelectCharge();mout();", true);
        else
            ScriptManager.RegisterStartupScript(this, this.GetType(), "initPage",
                  "SelectChargeCard();mout();", true);
        //对领奖信息验证进行检验
        if (!ValidateCharge())
            return;

        if (hidAwardType.Value == "0")
        {
            if (AwardCharge())
            {
                context.AddMessage("领奖充值成功");
                btnAward.Enabled = false;
                btnPrintPZ.Enabled = true;//打印凭证add by youyue 20140729
                
            }
        }
        else
        {
            if (AwardChargeCard())
            {
                context.AddMessage("充值卡领奖成功");
                btnAward.Enabled = false;
                btnPrintPZ.Enabled = true;//打印凭证add by youyue 20140729
                
            }
        }
        if (chkPingzheng.Checked && btnPrintPZ.Enabled) //针式打印凭证
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "printInvoice();", true);
        }
        if (chkPingzhengRemin.Checked && btnPrintPZ.Enabled) //add by youyue  增加热敏打印方式
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "printRMInvoice();", true);
        }
    }

    /// <summary>
    /// 领奖充值
    /// </summary>
    /// <returns></returns>
    private bool AwardCharge()
    {
        context.SPOpen();
        context.AddField("P_AWARDCARDNO").Value = txtCardNoC.Text;
        context.AddField("P_LOTTERYPERIOD").Value = hidLotteryPeriod.Value;
        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(txtCusname.Text, ref strBuilder);
        context.AddField("P_CUSTNAME").Value = strBuilder.ToString();
        context.AddField("P_PAPERTYPECODE").Value = selPapertype.SelectedValue;
        AESHelp.AESEncrypt(txtCustpaperno.Text, ref strBuilder);
        context.AddField("P_PAPERNO").Value = strBuilder.ToString();
        context.AddField("P_CUSTSEX").Value = selCustsex.SelectedValue;
        AESHelp.AESEncrypt(txtCustphone.Text, ref strBuilder);
        context.AddField("P_CUSTPHONE").Value = strBuilder.ToString();
        string str1 = "111111"; //初始密码
        StringBuilder szOutput = new System.Text.StringBuilder(256);
        CAEncryption.CAEncrypt(str1, ref szOutput);
        context.AddField("P_PWD").Value = szOutput.ToString(); 
        context.AddField("P_CARDNO").Value = hideCardno.Value;
        context.AddField("P_CARDTYPECODE").Value = hidCardTypeCode.Value;
        context.AddField("P_BONUS").Value = Convert.ToInt32(hidBonus.Value);
        if( context.ExecuteSP("SP_TL_AwardCharge"))
        {
            //导入照片 add by youyue
            if (FileUpload1.FileName != "" && Session["PicDataOther"] != null)
            {
                try
                {
                    UpdateImg(hidLotteryPeriod.Value,hideCardno.Value, hidCardTypeCode.Value);//导入单张照片
                }
                catch
                {
                    context.AddMessage("S00501B013：保存照片失败");
                }
            }
            //准备打印凭证数据 add by youyue 20140729
            ASHelper.prepareTLPingZheng(ptnPingZheng, context.s_DepartName, context.s_UserID,
               "抽奖换乘领奖", hideCardno.Value, txtCardNoC.Text, hideAwardsName.Value, Convert.ToString(Convert.ToInt32(hidBonus.Value) / 100),hidTax.Value,
               txtCusname.Text.Trim(), selPapertype.SelectedItem.Text.Trim().Remove(0,3), txtCustpaperno.Text.Trim(), txtCustphone.Text.Trim());
            //准备热敏打印凭证数据 add by youyue 20140819
            ASHelper.prepareTLRMPingZheng(PrintRMPingZheng, context.s_DepartName, context.s_UserID,
               "抽奖换乘领奖", hideCardno.Value, txtCardNoC.Text, hideAwardsName.Value, Convert.ToString(Convert.ToInt32(hidBonus.Value) / 100), hidTax.Value,
               txtCusname.Text.Trim(), selPapertype.SelectedItem.Text.Trim().Remove(0, 3), txtCustpaperno.Text.Trim(), txtCustphone.Text.Trim());

            txtCusname.Text = "";
            selPapertype.SelectedIndex = -1;
            txtCustpaperno.Text = "";
            txtCustphone.Text = "";
            txtChargeCard.Text = "";
            txtCardNoC.Text = "";
            selCustsex.SelectedIndex = -1; 
            gvResult.DataSource = null;
            gvResult.DataBind();
            Session["PicDataOther"] = null;
            return true;
        }
        else
        {
            Session["PicDataOther"] = null;
            return false;
        }
       
    }

    /// <summary>
    /// 充值卡领奖
    /// </summary>
    /// <returns></returns>
    private bool AwardChargeCard()
    {
        context.SPOpen();
        context.AddField("P_ChargeCard").Value = txtChargeCard.Text;
        context.AddField("P_LOTTERYPERIOD").Value = hidLotteryPeriod.Value;
        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(txtCusname.Text, ref strBuilder);
        context.AddField("P_CUSTNAME").Value = strBuilder.ToString();
        context.AddField("P_PAPERTYPECODE").Value = selPapertype.SelectedValue;
        AESHelp.AESEncrypt(txtCustpaperno.Text, ref strBuilder);
        context.AddField("P_PAPERNO").Value = strBuilder.ToString();
        context.AddField("P_CUSTSEX").Value = selCustsex.SelectedValue;
        AESHelp.AESEncrypt(txtCustphone.Text, ref strBuilder);
        context.AddField("P_CUSTPHONE").Value = strBuilder.ToString();
        context.AddField("P_CARDNO").Value = hideCardno.Value;
        context.AddField("P_CARDTYPECODE").Value = hidCardTypeCode.Value;
        context.AddField("P_BONUS").Value = Convert.ToInt32(hidBonus.Value); 
        if (context.ExecuteSP("SP_TL_AwardChargeCard"))
        {
            //导入照片 add by youyue
            if (FileUpload1.FileName != "")
            {

                try
                {
                    UpdateImg(hidLotteryPeriod.Value, hideCardno.Value, hidCardTypeCode.Value);//导入单张照片
                }
                catch
                {
                    context.AddMessage("S00501B013：保存照片失败");
                }
            }
            //准备打印凭证数据 add by youyue 20140729
            ASHelper.prepareTLPingZheng(ptnPingZheng, context.s_DepartName, context.s_UserID,
               "抽奖换乘领奖", hideCardno.Value, "", hideAwardsName.Value, Convert.ToString(Convert.ToInt32(hidBonus.Value) / 100),hidTax.Value,
               txtCusname.Text.Trim(), selPapertype.SelectedItem.Text.Trim().Remove(0,3), txtCustpaperno.Text.Trim(), txtCustphone.Text.Trim());
            //准备热敏打印凭证数据 add by youyue 20140819
            ASHelper.prepareTLRMPingZheng(PrintRMPingZheng, context.s_DepartName, context.s_UserID,
               "抽奖换乘领奖", hideCardno.Value, "", hideAwardsName.Value, Convert.ToString(Convert.ToInt32(hidBonus.Value) / 100), hidTax.Value,
               txtCusname.Text.Trim(), selPapertype.SelectedItem.Text.Trim().Remove(0, 3), txtCustpaperno.Text.Trim(), txtCustphone.Text.Trim());

            txtCusname.Text = "";
            selPapertype.SelectedIndex = -1;
            txtCustpaperno.Text = "";
            txtCustphone.Text = "";
            txtChargeCard.Text = "";
            txtCardNoC.Text = "";
            selCustsex.SelectedIndex = -1;
            gvResult.DataSource = null;
            gvResult.DataBind();
            Session["PicDataOther"] = null;
            return true;
        }
        else
        {
            Session["PicDataOther"] = null;
            return false;
        }
        
    }
    /// <summary>
    /// 获取图片二进制流文件 add by youyue 20140723
    /// </summary>
    /// <param name="FileUpload1">upload控件</param>
    /// <returns>二进制流</returns>
    private byte[] GetPicture(FileUpload FileUpload1)
    {
        int len = FileUpload1.FileBytes.Length;
        if (len > 1024 * 1024 * 1)
        {
            context.AddError("A094780014：上传文件大于1M,文件上传失败");
            return null;
        }

        System.IO.Stream fileDataStream = FileUpload1.PostedFile.InputStream;

        int fileLength = FileUpload1.PostedFile.ContentLength;

        byte[] fileData = new byte[fileLength];

        fileDataStream.Read(fileData, 0, fileLength);
        fileDataStream.Close();

        return fileData;

    }
    /// <summary>
    /// 导入照片 add by youyue 20140731
    /// </summary>
    /// <param name="lotteryperiod"></param>
    /// <param name="cardno"></param>
    /// <param name="cardtypecode"></param>
    /// <param name="buff"></param>
    private void UpdateImg(string lotteryperiod,string cardno,string cardtypecode)
    {
        if (Session["PicDataOther"] != null)
        {

            context.DBOpen("Select");
            context.AddField(":p_lotteryPeriod").Value = lotteryperiod;
            context.AddField(":p_cardNo").Value = cardno;
            context.AddField(":p_cardTypeCode").Value = cardtypecode;
            DataTable dt = context.ExecuteReader(@"
                                        SELECT * 
                                        From TF_TT_AWARDSPHOTO
                                        WHERE CARDNO = :p_cardNo and LOTTERYPERIOD= :p_lotteryPeriod and CARDTYPECODE= :p_cardTypeCode
                            ");

            string sql = "";
            if (dt.Rows.Count == 0)
            {
                context.DBOpen("BatchDML");
                sql = "INSERT INTO TF_TT_AWARDSPHOTO (LOTTERYPERIOD,CARDNO,CARDTYPECODE,PICTURE) VALUES(:p_lotteryPeriod,:p_cardNo,:p_cardTypeCode,:BLOB)";
            }
            else
            {
                context.DBOpen("BatchDML");
                sql = "Update TF_TT_AWARDSPHOTO Set PICTURE = :BLOB Where LOTTERYPERIOD = :p_lotteryPeriod and CARDNO = :p_cardNo and CARDTYPECODE = :p_cardTypeCode";

            }
            context.AddField(":p_lotteryPeriod", "String").Value = lotteryperiod;
            context.AddField(":p_cardNo", "String").Value = cardno;
            context.AddField(":p_cardTypeCode", "String").Value = cardtypecode;
            context.AddField(":BLOB", "BLOB").Value = Session["PicDataOther"];

            context.ExecuteNonQuery(sql);
            context.DBCommit();


        }
    }
}