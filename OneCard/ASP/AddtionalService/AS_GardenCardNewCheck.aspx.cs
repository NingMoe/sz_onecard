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
using TM;
using PDO.AdditionalService;
using Common;
using System.Text;
using System.Collections.Generic;

// 园林年卡身份审核 wdx 20111116

public partial class ASP_AddtionalService_AS_GardenCardNewCheck : Master.FrontMaster
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        Session["PicData"] = null;
        Session["PicDataOther"] = null;
        // 初始化证件类型



        //ASHelper.initPaperTypeList(context, selPaperType);
        // 初始化查询结果


        UserCardHelper.resetData(gvResult, null);
    }

    // gridview换页处理
    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        Query(hidPaperNo.Value);
    }
    //读卡
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        hfPic.Value = "";
        Session["PicData"] = null;
        picImg.ImageUrl = "";

        //校验卡号有效性

        if (string.IsNullOrEmpty(txtCardno.Text.Trim()))
            context.AddError("A094570238：卡号不能为空", txtCardno);
        else if (Validation.strLen(txtCardno.Text.Trim()) != 16)
            context.AddError("A094570239：卡号必须为16位", txtCardno);
        else if (!Validation.isNum(txtCardno.Text.Trim()))
            context.AddError("A094570240：卡号必须为数字", txtCardno);
        //若无效，则返回

        if (context.hasError())
        {
            return;
        }

        // 查询卡号所属人身份证号
        string paperNo = "";
        string sql = "";
        DataTable selectPaperNoData = new DataTable();
        if (!string.IsNullOrEmpty(txtCardno.Text.Trim()))
        {
            sql = "select PAPERNO from TF_F_CUSTOMERREC t where t.CARDNO = '" + txtCardno.Text.Trim() + "'";
            context.DBOpen("Select");
            selectPaperNoData = context.ExecuteReader(sql);
            if (selectPaperNoData.Rows.Count > 0)
            {
                paperNo = selectPaperNoData.Rows[0]["PAPERNO"].ToString();
            }
        }
        CommonHelper.AESDeEncrypt(selectPaperNoData, new List<string>(new string[] { "CUSTNAME", "CUSTPHONE", "CUSTADDR", "PAPERNO" }));

        //查询开通的园林年卡
        Query(paperNo);

        if (selectPaperNoData.Rows.Count > 0)
        {
            //加入撤销免检身份证号输入框赋值

            txtPaperNoExemption.Text = selectPaperNoData.Rows[0]["PAPERNO"].ToString();
        }

        txtPaperNo.Text = "";
    }
    //读身份证号

    protected void btnReadIDCard_Click(object sender, EventArgs e)
    {
        BtnShowPic_Click(sender, e);
        //校验身份证号有效性

        if (!validation(txtPaperNo))
        {
            return;
        }

        //加入撤销免检身份证号输入框赋值

        txtPaperNoExemption.Text = txtPaperNo.Text.Trim();

        //身份证号加密
        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(txtPaperNo.Text.Trim().Replace("'", ""), ref strBuilder);
        string paperNo = strBuilder.ToString();
        //查询开通的园林年卡
        Query(paperNo);

        txtCardno.Text = "";
    }
    /// <summary>
    /// 查询
    /// </summary>
    /// <param name="paperNo">加密后的身份证号</param>
    protected void Query(string paperNo)
    {
        string sql = "";
        //是否是黑名单
        sql = "select 1 from TF_F_CARDPARKBLACKLIST d where d.paperno = '" + paperNo + "' and usetag = '1'";
        context.DBOpen("Select");
        DataTable isBlackListdata = context.ExecuteReader(sql);
        if (isBlackListdata.Rows.Count > 0)
        {
            //清空列表
            UserCardHelper.resetData(gvResult, null);
            //提示不允许办理园林年卡

            context.AddError("身份信息被列入黑名单不允许办理园林年卡");
            return;
        }
        //查询开通的有效的有园林年卡
        DataTable data = ASHelper.callQuery(context, "QueryPaperIsPark", paperNo);
        if (data == null || data.Rows.Count == 0)
        {
            //如果没有开通园林年卡，查询是否免检
            data = ASHelper.callQuery(context, "QueryPaperIsWhiteList", paperNo);

            if (data == null || data.Rows.Count == 0)//不存在持卡人
            {
                AddMessage("N005030001: 查询结果为空");
                hidPaperNo.Value = "";
            }
            else//持卡人存在但没有开通园林年卡
            {
                AddMessage("未开通有效的园林年卡");
                isMessage = false;
            }
        }



        //解密
        CommonHelper.AESDeEncrypt(data, new List<string>(new string[] { "CUSTNAME", "CUSTPHONE", "CUSTADDR", "PAPERNO" }));

        UserCardHelper.resetData(gvResult, data);

        if (data.Rows.Count > 0)
        {
            //如果查询开关打开，则判断是否允许开卡（加入撤销免检时关闭了查询开关）
            if (isMessage == true)
            {
                //判断是否允许再开卡

                isAllowOpen(data);
            }
            //打开查询开关

            isMessage = true;

            //身份证号隐藏域控件赋值，用于翻页
            StringBuilder strBuilder = new StringBuilder();
            AESHelp.AESEncrypt(data.Rows[0]["PAPERNO"].ToString(), ref strBuilder);
            hidPaperNo.Value = strBuilder.ToString();
        }
    }
    /// <summary>
    /// 判断是否允许再开园林年卡
    /// </summary>
    /// <param name="data">查询结果DATATABLE</param>
    protected void isAllowOpen(DataTable data)
    {
        int count = 0;
        foreach (DataRow row in data.Rows)
        {
            //查询结果任意一条记录在库内的有效期 比 当前日期 >= 31 天

            if (Convert.ToInt32(row["ENDDATE"].ToString()) > Convert.ToInt32(DateTime.Today.AddDays(31).ToString("yyyyMMdd")))
            {
                count++;
            }

        }
        //如果有任意一条记录在库内的有效期比当前日期大一个月，则提示本年度已经办理，不允许再次办理

        if (count > 0)
        {
            context.AddMessage("本年度已经办理，不允许再次办理！");
        }
    }
    protected Boolean validation(TextBox tbPaperNo)
    {
        //校验证件号码
        if (string.IsNullOrEmpty(tbPaperNo.Text.Trim()))
            context.AddError("A094570235：身份证号码不能为空", tbPaperNo);
        else if (!Validation.isCharNum(tbPaperNo.Text.Trim()))
            context.AddError("A094570236：身份证号码必须为英数", tbPaperNo);
        else if (Validation.strLen(tbPaperNo.Text.Trim()) != 18 && Validation.strLen(tbPaperNo.Text.Trim()) != 15)
            context.AddError("A094570237：身份证号码长度必须为18位或15位", tbPaperNo);

        return !context.hasError();
    }

    //判断是否允许再开园林年卡提示开关

    private bool isMessage = true;

    //加入免检
    protected void btnExemption_Click(object sender, EventArgs e)
    {
        //校验身份证号
        if (!validation(txtPaperNoExemption))
        {
            return;
        }
        //身份证号加密
        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(txtPaperNoExemption.Text.Trim().Replace("'", ""), ref strBuilder);
        string sql = "select 1 from TF_F_CARDPARKWHITELIST where PAPERNO = '" + strBuilder.ToString() + "' and usetag='1'";
        context.DBOpen("Select");
        DataTable dataIsBlack = context.ExecuteReader(sql);
        if (dataIsBlack.Rows.Count > 0)
        {
            context.AddError("加入免检的身份证号已经在免检名单中");
            return;
        }

        context.SPOpen();
        context.AddField("P_FUNCCODE").Value = "ADDWHITELIST";
        context.AddField("P_PAPERNO").Value = strBuilder.ToString();
        bool ok = context.ExecuteSP("SP_AS_CARDPARKWHITELIST");
        if (ok)
        {
            try
            {
                SaveMuliPic(txtPaperNoExemption);
            }
            catch
            {
            }

            context.AddMessage("加入免检成功");
            //关闭判断是否允许再开园林年卡提示开关

            isMessage = false;
            //刷新列表
            Query(strBuilder.ToString());
        }

        hfPic.Value = "";
        Session["PicData"] = null;
        picImg.ImageUrl = "";
    }

    //撤销免检
    protected void btnCancelExemption_Click(object sender, EventArgs e)
    {
        //校验身份证号
        if (!validation(txtPaperNoExemption))
        {
            return;
        }
        //身份证号加密
        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(txtPaperNoExemption.Text.Trim().Replace("'", ""), ref strBuilder);

        string sql = "select 1 from TF_F_CARDPARKWHITELIST where PAPERNO = '" + strBuilder.ToString() + "' and usetag='1'";
        context.DBOpen("Select");
        DataTable dataIsBlack = context.ExecuteReader(sql);
        if (dataIsBlack.Rows.Count == 0)
        {
            context.AddError("撤销免检的身份证号不在免检名单中");
            return;
        }

        context.SPOpen();
        context.AddField("P_FUNCCODE").Value = "DELETEWHITELIST";
        context.AddField("P_PAPERNO").Value = strBuilder.ToString();
        bool ok = context.ExecuteSP("SP_AS_CARDPARKWHITELIST");
        if (ok)
        {
            try
            {
                SaveMuliPic(txtPaperNoExemption);
            }
            catch
            {
            }

            context.AddMessage("撤销免检成功");
            //关闭判断是否允许再开园林年卡提示开关

            isMessage = false;
            //刷新列表
            Query(strBuilder.ToString());
        }

        hfPic.Value = "";
        Session["PicData"] = null;
        picImg.ImageUrl = "";
    }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if (e.Row.Cells[4].Text == "是")
            {
                e.Row.Cells[4].CssClass = "green";
            }
            else if(e.Row.Cells[4].Text=="否")
            {
                e.Row.Cells[4].CssClass = "red";
            }

            Image tmp_Image = (Image)e.Row.Cells[5].FindControl("Image1");

            if (!System.Convert.IsDBNull(DataBinder.Eval(e.Row.DataItem, "PICTURE")))
            {
                byte[] pic = (byte[])DataBinder.Eval(e.Row.DataItem, "PICTURE");
                Session["PicDataOther"] = pic;
                tmp_Image.ImageUrl = "../../picture.aspx?picType=1&id=" + DateTime.Now.ToString();
               
            }
        }
    }

    //保存照片
    protected void btnSavePic_Click(object sender, EventArgs e)
    {
        SaveMuliPic(txtPaperNo);
    }

    //显示照片
    protected void BtnShowPic_Click(object sender, EventArgs e)
    {
        Session["PicData"] = null;
        picImg.ImageUrl = "";

        string str = hfPic.Value;

        if (string.IsNullOrEmpty(str))
            return;

        int len = str.Length / 2;
        byte[] pic = new byte[len];
        HexStrToBytes(str, ref pic, len);

        Session["PicData"] = pic;
        picImg.ImageUrl = "../../picture.aspx?id=" + DateTime.Now.ToString();
    }

    int HexStrToBytes(string strSou, ref byte[] BytDes, int bytCount)
    {
        int i;
        int len;
        int HighByte, LowByte;

        len = strSou.Length;
        if (bytCount * 2 < len) len = bytCount * 2;

        if ((len - len / 2 * 2) == 0)
        {
            for (i = 0; i < len; i += 2)
            {
                HighByte = (byte)strSou[i];
                LowByte = (byte)strSou[i + 1];

                if (HighByte > 0x39) HighByte -= 0x37;
                else HighByte -= 0x30;

                if (LowByte > 0x39) LowByte -= 0x37;
                else LowByte -= 0x30;

                BytDes[i / 2] = (byte)((HighByte << 4) | LowByte);
            }
            for (; i < bytCount * 2; i += 2)
            {
                BytDes[i / 2] = 0;
            }
            return (len / 2);
        }
        else
            return 0;
    }

    private void SaveMuliPic(TextBox textbox)
    {
        #region Validate
        //校验身份证号
        if (!validation(textbox))
        {
            return;
        }

        //检验读取二代证照片是否有
        if (hfPic.Value == "")
        {
            context.AddMessage("照片未从二代证中读取出来");
            return;
        }

        #endregion

        string str = hfPic.Value;

        int len = str.Length / 2;
        byte[] pic = new byte[len];
        HexStrToBytes(str, ref pic, len);

        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(textbox.Text.Trim().Replace("'", ""), ref strBuilder);
        string paperNo = strBuilder.ToString();

        context.DBOpen("Select");
        context.AddField(":p_paperNo").Value = paperNo;
        DataTable dt = context.ExecuteReader(@"
                                        SELECT CARDNO 
                                        From TF_F_CUSTOMERREC
                                        WHERE PAPERNO = :p_paperNo
                            ");


        if (dt != null && dt.Rows.Count > 0)
        {
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                SavePic(Convert.ToString(dt.Rows[i][0]), pic);
            }

            context.AddMessage("保存照片成功");
        }
        else
        {
            context.AddError("未查询出身份证对应的卡号");
        }
    }

    private void SavePic(string cardNo, byte[] pic)
    {
        context.DBOpen("Select");
        context.AddField(":p_cardNo").Value = cardNo;
        DataTable dt = context.ExecuteReader(@"
                                        SELECT * 
                                        From TF_F_CARDPARKPHOTO_SZ
                                        WHERE CARDNO = :p_cardNo
                            ");


        string sql = "";
        if (dt.Rows.Count == 0)
        {
            context.DBOpen("Insert");
            sql = "INSERT INTO TF_F_CARDPARKPHOTO_SZ (CARDNO  , PICTURE) VALUES(:p_cardNo, :p_picture)";
        }
        else
        {
            context.DBOpen("Update");
            sql = "Update TF_F_CARDPARKPHOTO_SZ Set PICTURE = :p_picture Where CARDNO = :p_cardNo";

        }

        context.AddField(":p_cardNo", "String").Value = cardNo;
        context.AddField(":p_picture", "Blob").Value = pic;

        context.ExecuteNonQuery(sql);
        context.DBCommit();
    }

}
