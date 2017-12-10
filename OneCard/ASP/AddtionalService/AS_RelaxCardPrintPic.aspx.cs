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
using TDO.BusinessCode;
using Common;
using TM;
using System.Text;
using System.IO;
using PDO.PersonalBusiness;
using Master;


/// <summary>
/// 休闲年卡--打印照片
/// 董翔  20150423
/// </summary>
public partial class ASP_AS_RelaxCardPrintPic : Master.FrontMaster
{
    /// <summary>
    /// 初始化
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Page_Load(object sender, EventArgs e)
    {
        ScriptManager.RegisterStartupScript(this, this.GetType(), "js",
               "loadWebcam();", true);

        if (Page.IsPostBack) return;
         

        // 设置可读属性 
        if (!context.s_Debugging) txtCardno.Attributes["readonly"] = "true";

        btnPrint.Enabled = false;
        btnShowWebCam.Enabled = false;
        hidStaffno.Value = Session["staff"].ToString();


    }

    /// <summary>
    /// 读卡事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        hidCardno.Value = "";
        hidIsCapture.Value = "0";
        btnShowWebCam.Enabled = false;
        DataTable data = ASHelper.callQuery(context, "ReadXXParkInfo", txtCardno.Text);
        if (data.Rows.Count == 1)
        {
            hidAccountType.Value = data.Rows[0]["ACCOUNTTYPE"].ToString() ;
        }
        else
        {
            hidAccountType.Value = ""; 
        }

        // 读取客户信息
        readCustInfo(txtCardno.Text,
            txtCustName, txtCustBirth,
            selPaperType, txtPaperNo,
            selCustSex, txtCustPhone,
            txtCustPost, txtCustAddr, txtEmail, txtRemark);

        //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
        if (!CommonHelper.HasOperPower(context))
        {
            txtPaperNo.Text = CommonHelper.GetPaperNo(txtPaperNo.Text);
            txtCustPhone.Text = CommonHelper.GetCustPhone(txtCustPhone.Text);
            txtCustAddr.Text = CommonHelper.GetCustAddress(txtCustAddr.Text);
        }


        rdoPrintTemplate1.Checked = false;
        rdoPrintTemplate2.Checked = false;
        rdoPrintTemplate3.Checked = false;
        rdoPrintTemplate4.Checked = false;
        rdoPrintTemplate5.Checked = false;
        rdoPrintTemplate6.Checked = false;
        btnPrint.Enabled = false;

        if (context.hasError()) return;

        hidCardno.Value = txtCardno.Text; 
        if (hidAccountType.Value == "线上开通")
            btnShowWebCam.Enabled = false;
        else
            btnShowWebCam.Enabled = true;
       
        string selectSql = "Select count(1) From TF_F_CARDPARKPHOTO_SZ Where cardno=:cardno";
        context.DBOpen("Select");
        context.AddField(":cardno").Value = txtCardno.Text;
        DataTable dt = context.ExecuteReader(selectSql);
        if (dt != null && dt.Rows.Count == 1)
        {
            imgCustomerPic.Src = string.Format("AS_RelaxCardGetPic.aspx?cardno={0}&time={1}", txtCardno.Text, System.DateTime.Now.ToString("yyyyMMddhhmmss"));
            imgPrint.Src = string.Format("AS_RelaxCardGetPic.aspx?cardno={0}&time={1}", txtCardno.Text, System.DateTime.Now.ToString("yyyyMMddhhmmss"));
        }
        else
        {
            context.AddError("该卡没有照片数据，请先采集照片");
        }
        btnPrint.Enabled = !context.hasError();
       
    }

    /// <summary>
    /// 保存照片
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSaveImg_Click(object sender, EventArgs e)
    {
        if (hidCardno.Value != "" && hidIsCapture.Value == "1") 
        {
            hidIsCapture.Value = "0";
            string file_photo = HttpContext.Current.Server.MapPath("../../tmp/printImg" + Session["staff"].ToString() + ".jpg");
            FileStream file = new FileStream(file_photo, FileMode.Open, FileAccess.Read);
            byte[] buffer = new byte[file.Length];
            file.Read(buffer, 0, (int)file.Length);
            file.Dispose();
            UpdateParkImg(txtCardno.Text, buffer);
            Sync(); 
            context.AddMessage("照片保存成功");
            hidCardno.Value = "";
            rdoPrintTemplate1.Checked = false;
            rdoPrintTemplate2.Checked = false;
            rdoPrintTemplate3.Checked = false;
            rdoPrintTemplate4.Checked = false;
            rdoPrintTemplate5.Checked = false;
            rdoPrintTemplate6.Checked = false;
            btnPrint.Enabled = false;
        }
    }

    /// <summary>
    /// 导入或更新照片
    /// </summary>
    /// <param name="p_cardno">cardno</param>
    /// <param name="buff">图片二进制流文件</param>
    private void UpdateParkImg(string p_cardno, byte[] buff)
    {
        if (buff != null)
        {
            context.DBOpen("Select");
            context.AddField(":p_cardNo").Value = p_cardno;
            DataTable dt = context.ExecuteReader(@"
                                        SELECT * 
                                        From TF_F_CARDPARKPHOTO_SZ
                                        WHERE CARDNO = :p_cardNo
                            ");

            string sql = "";
            if (dt.Rows.Count == 0)
            {
                context.DBOpen("BatchDML");
                sql = "INSERT INTO TF_F_CARDPARKPHOTO_SZ (CARDNO  , PICTURE ,OPERATETIME,OPERATEDEPARTID,OPERATESTAFFNO) VALUES(:p_cardNo, :BLOB,:OPERATETIME,:OPERATEDEPARTID,:OPERATESTAFFNO)";
                context.AddField(":p_cardNo", "String").Value = p_cardno;
                context.AddField(":BLOB", "BLOB").Value = buff;
                context.AddField(":OPERATETIME", "DateTime").Value = DateTime.Now;
                context.AddField(":OPERATEDEPARTID", "String").Value = context.s_DepartID;
                context.AddField(":OPERATESTAFFNO", "String").Value = context.s_UserID;
                context.ExecuteNonQuery(sql);
                context.DBCommit(); 
            }
            else
            {
                context.DBOpen("BatchDML");
                sql = "INSERT INTO TB_F_CARDPARKPHOTO_SZ (CARDNO,PICTURE,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME) SELECT CARDNO,PICTURE,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME FROM TF_F_CARDPARKPHOTO_SZ WHERE CARDNO = :p_cardNo";
                context.AddField(":p_cardNo", "String").Value = p_cardno; 
                context.ExecuteNonQuery(sql);
                context.DBCommit(); 
                context.DBOpen("BatchDML");
                sql = "Update TF_F_CARDPARKPHOTO_SZ Set PICTURE = :BLOB,OPERATETIME = :OPERATETIME,OPERATEDEPARTID = :OPERATEDEPARTID,OPERATESTAFFNO = :OPERATESTAFFNO Where CARDNO = :p_cardNo";
                context.AddField(":p_cardNo", "String").Value = p_cardno;
                context.AddField(":BLOB", "BLOB").Value = buff;
                context.AddField(":OPERATETIME", "DateTime").Value = DateTime.Now;
                context.AddField(":OPERATEDEPARTID", "String").Value = context.s_DepartID;
                context.AddField(":OPERATESTAFFNO", "String").Value = context.s_UserID;
                context.ExecuteNonQuery(sql);
                context.DBCommit(); 
            
            }
           

        }
    }

    private bool Sync()
    {
        // 调用惠民休闲年卡开卡存储过过程
        context.SPOpen();
        context.AddField("p_cardNo").Value = txtCardno.Text;
        context.AddField("p_asn").Value = hiddenAsn.Value.Substring(4, 16);
        context.AddField("p_paperType").Value = "00";
        StringBuilder strPaperNoBuilder = new StringBuilder();
        AESHelp.AESEncrypt(txtPaperNo.Text, ref strPaperNoBuilder);
        context.AddField("p_paperNo").Value = strPaperNoBuilder.ToString(); 
        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(txtCustName.Text, ref strBuilder);
        context.AddField("p_custName").Value = strBuilder.ToString();
        context.AddField("p_endDate");
        context.AddField("p_Times", "Int32");
        context.AddField("p_TradeType").Value = "4";
        context.AddField("p_CardTime", "DateTime");
        context.AddField("p_oldCardNo");
        context.AddField("p_Rsrv1");
        context.AddField("p_tradeId");
        context.AddField("p_packagetype");
        context.AddField("p_isoffline");
        context.AddField("p_cityCode").Value = "2150";  //add by jiangbb 2015-11-25
        // 执行存储过程
        bool ok = context.ExecuteSP("SP_AS_SynGardenXXCard");
        context.DBCommit();
        return ok; 
    }

    
}