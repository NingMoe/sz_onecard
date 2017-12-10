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
using Common;
using TM;
using TDO.BusinessCode;
using PDO.AdditionalService;
using Master;
using PDO.PersonalBusiness;
using System.Text;
using System.Collections.Generic;
using System.IO;

// 园林年卡补换卡



public partial class ASP_AddtionalService_AS_GardenCardChange : Master.FrontMaster
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        // 设置可读属性



        if (!context.s_Debugging) txtCardNo.Attributes["readonly"] = "true";

        setReadOnly(txtCardBalance, txtStartDate);

        // 初始化费用列表


        decimal total = initFeeList(gvResult, "36");
        hidAccRecv.Value = total.ToString("n");

        // 初始化旧卡信息查询结果gridview
        UserCardHelper.resetData(gvOldCardInfo, null);
        Session["PicData"] = null;
        tdMsg.Visible = false;//隐藏照片采集提示信息add by youyue20140414
    }

    // 读卡处理
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        btnPrintPZ.Enabled = false;

        #region add by shil 20130909,如果是旅游年卡，则不允许在该页面办理业务
        //验证卡片是否旅游年卡(51)，如果是旅游年卡，则不允许在该页面办理业务


        bool cardTypeOk = CommonHelper.allowCardtype(context, txtCardNo.Text, "5101","5103");
        if (cardTypeOk == false)
        {
            return;
        }
        #endregion

        // 检查帐户信息


        checkAccountInfo(txtCardNo.Text);

        // 检查园林特征值


        checkGardenFeature();

        checkGardenIsInvalid();//判断当前卡是否是是园林账户表中无效的卡 add by youyue 20141229

        // 读取卡片类型
        readCardType(txtCardNo.Text, labCardType);

        //add by jiangbb 2012-10-09  加入判断 旧卡或新卡为市民卡不会修改客户资料 
        if (!context.hasError() && txtCardNo.Text.Substring(4, 2).ToString() == "18")
        {
            context.AddMessage("提示：新卡卡号为市民卡，客户资料不会被修改");
        }

        hidReadCardOK.Value = !context.hasError() && txtCardNo.Text.Length > 0 ? "ok" : "fail";

        //btnUpload.Enabled = hidReadCardOK.Value == "ok"
        //    && gvOldCardInfo.SelectedIndex >= 0;
        btnSubmit.Enabled = hidReadCardOK.Value == "ok"
            && gvOldCardInfo.SelectedIndex >= 0;
    }

    // 对话框确认处理



    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "writeSuccess")  // 写卡成功
        {
            clearCustInfo(txtCardNo, txtCustName, txtCustBirth, selPaperType, txtPaperNo,
                selCustSex, txtCustPhone, txtCustPost, txtCustAddr, txtEmail, txtRemark);
            AddMessage("D005020002: 园林年卡前台写卡成功，补换卡成功");
        }
        else if (hidWarning.Value == "writeFail") // 写卡失败
        {
            context.AddError("A00502C001: 园林年卡前台写卡失败，补换卡失败");
        }

        hidWarning.Value = "";       // 清除警告信息

        if (chkPingzheng.Checked && btnPrintPZ.Enabled)
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "printInvoice();", true);
        }
    }

    // 查询处理
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        // 输入项判断处理（证件号码、旧卡号码、客户姓名）
        // ASHelper.changeCardQueryValidate(context, txtId, txtOldCardNo, txtName);
        // if (context.hasError()) return;

        // 从园林卡资料表中查询
        string strValue = txtCondition.Text;
        if (selQueryType.SelectedValue == "02" || selQueryType.SelectedValue == "03" || selQueryType.SelectedValue == "04")   //证件号码
        {
            StringBuilder strBuilder = new StringBuilder();
            AESHelp.AESEncrypt(strValue, ref strBuilder);
            strValue = strBuilder.ToString();
        }
        DataTable data = ASHelper.callQuery(context, "QueryOldCards", selQueryType.SelectedValue,
            strValue);

        //add by jiangbb 解密
        CommonHelper.AESDeEncrypt(data, new List<string>(new string[] { "CUSTNAME", "CUSTPHONE", "CUSTADDR", "PAPERNO" }));

        if (data == null || data.Rows.Count == 0)
        {
            UserCardHelper.resetData(gvOldCardInfo, data);
            AddMessage("N005030001: 查询结果为空");
        }
        else
        {
            UserCardHelper.resetData(gvOldCardInfo, data);

            gvOldCardInfo.SelectedIndex = 0;
            gvOldCardInfo_SelectedIndexChanged(sender, e);
        }
    }

    // 检查园林卡特征值



    void checkGardenFeature()
    {
        // 从园林卡资料表中检查USETAG值



        DataTable data = ASHelper.callQuery(context, "ParkCardUseTag", txtCardNo.Text);
        if (data.Rows.Count > 0)
        {
            context.AddError("A005020001: 当前卡已经是园林年卡");
        }
    }

    // 旧卡信息查询结果gridview行创建事件



    protected void gvOldCardInfo_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件



            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvOldCardInfo','Select$" + e.Row.RowIndex + "')");
        }
    }

    //没有客户信息查看权则证件号码加*显示
    protected void gvOldCardInfo_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (!CommonHelper.HasOperPower(context))
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                e.Row.Cells[5].Text = CommonHelper.GetPaperNo(e.Row.Cells[5].Text);
            }
        }
    }

    // 旧卡信息查询结果行选择事件
    public void gvOldCardInfo_SelectedIndexChanged(object sender, EventArgs e)
    {
        hidServiceFor.Value = "0";
        preview_size_fake.Src = "";

        // 得到选择行



        GridViewRow selectRow = gvOldCardInfo.SelectedRow;

        // 根据选择行卡号读取用户信息



        readCustInfo(selectRow.Cells[0].Text, txtCustName, txtCustBirth,
            selPaperType, txtPaperNo, selCustSex, txtCustPhone, txtCustPost,
            txtCustAddr, txtEmail, txtRemark);

        readCardPic(selectRow.Cells[0].Text);
        hidForPaperNo.Value = txtPaperNo.Text.Trim();
        hidForPhone.Value = txtCustPhone.Text.Trim();
        hidForAddr.Value = txtCustAddr.Text.Trim();

        //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
        if (!CommonHelper.HasOperPower(context))
        {
            txtPaperNo.Text = CommonHelper.GetPaperNo(txtPaperNo.Text);
            txtCustPhone.Text = CommonHelper.GetCustPhone(txtCustPhone.Text);
            txtCustAddr.Text = CommonHelper.GetCustAddress(txtCustAddr.Text);
        }

        hidEndDate.Value = selectRow.Cells[1].Text;
        hidUsabelTimes.Value = selectRow.Cells[3].Text;

        if (!context.hasError() && gvOldCardInfo.SelectedRow.Cells[0].Text.Substring(4, 2).ToString() == "18")
        {
            context.AddMessage("提示：旧卡卡号为市民卡，客户资料不会被修改");
        }
        //btnUpload.Enabled = !context.hasError() && hidReadCardOK.Value == "ok";
        btnSubmit.Enabled = !context.hasError() && hidReadCardOK.Value == "ok";

        if (selectRow.Cells[1].Text.ToString().CompareTo(DateTime.Now.ToString("yyyyMMdd")) >= 0)
        {
            hidServiceFor.Value = "1";
        }
    }

    // 提交前输入项校验
    private void submitValidate()
    {
        // 用户信息校验
        //custInfoForValidate(txtCustName, txtCustBirth,
        //    selPaperType, txtPaperNo, selCustSex, txtCustPhone, txtCustPost,
        //    txtCustAddr, txtEmail, txtRemark);
    }

    protected void custInfoForValidate(TextBox txtCustName, TextBox txtCustBirth,
            DropDownList selPaperType, TextBox txtPaperNo,
            DropDownList selCustSex, TextBox txtCustPhone,
            TextBox txtCustPost, TextBox txtCustAddr, TextBox txtCustEmail, TextBox txtRemark)
    {
        Validation valid = new Validation(context);
        txtCustName.Text = txtCustName.Text.Trim();
        valid.check(Validation.strLen(txtCustName.Text) <= 50, "A005010001, 客户姓名长度不能超过50", txtCustName);

        bool b = Validation.isEmpty(txtCustBirth);
        if (!b)
        {
            b = valid.fixedLength(txtCustBirth, 8, "A005010002: 出生日期必须为8位");
            if (b)
            {
                valid.beDate(txtCustBirth, "A005010003: 出生日期格式必须是yyyyMMdd");
            }
        }

        b = Validation.isEmpty(txtCustPost);
        if (!b)
        {
            b = valid.fixedLength(txtCustPost, 6, "A005010004: 邮政编码必须为6位");
            if (b)
            {
                valid.beNumber(txtCustPost, "A005010005: 邮政编码必须是数字");
            }
        }

        b = Validation.isEmpty(txtPaperNo);
        if (!b)
        {
            b = valid.check(Validation.strLen(txtPaperNo.Text) <= 20, "A005010006: 证件号码位数必须小于等于20", txtPaperNo);
            //判断是否有客户信息查看权限


            if (CommonHelper.HasOperPower(context) || CommonHelper.GetPaperNo(hidForPaperNo.Value) != txtPaperNo.Text.Trim())
            {
                if (b)
                {
                    valid.beAlpha(txtPaperNo, "A005010007: 证件号码必须是英文或者数字");
                }
            }
        }

        b = Validation.isEmpty(txtCustPhone);
        if (!b)
        {
            b = valid.check(Validation.strLen(txtCustPhone.Text) <= 20, "A005010008: 联系电话位数必须小于等于20", txtCustPhone);
            //if (b)
            //{
            //    valid.beNumber(txtCustPhone, "A005010009: 联系电话必须是数字");
            //}
        }
        b = Validation.isEmpty(txtCustAddr);
        if (!b)
        {
            valid.check(Validation.strLen(txtCustAddr.Text) <= 50, "A005010010: 联系地址位数必须小于等于50", txtCustAddr);
        }

        valid.isEMail(txtCustEmail);

        b = Validation.isEmpty(txtRemark);
        if (!b)
        {
            valid.check(Validation.strLen(txtRemark.Text) <= 100, "A005010011: 备注位数必须小于等于100", txtRemark);
        }
    }


    // 园林年卡补换卡提交处理



    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        // 提交前输入校验



        submitValidate();
        if (context.hasError()) return;

        StringBuilder strBuilder = new StringBuilder();
        // 调用园林年卡补换卡存储过程

        //获取身份证Code
        string paperTypeCode = string.Empty;
        DataTable data = ASHelper.callQuery(context, "ReadPaperCode", selPaperType.Text);
        if (data.Rows.Count > 0)
        {
            paperTypeCode = (string)data.Rows[0].ItemArray[0];
        }
        string oldCardNo = gvOldCardInfo.SelectedRow.Cells[0].Text; //add by jiangbb 2012-06-05
        string newCardNo = txtCardNo.Text;
        string oldCardTimes = gvOldCardInfo.SelectedRow.Cells[3].Text;

        //add by jiangbb 2012-10-17 判断页面上的证件号码、联系电话、联系地址是否修改 并取值


        string custPaperNo = CommonHelper.GetPaperNo(hidForPaperNo.Value) == txtPaperNo.Text.Trim() ? hidForPaperNo.Value : txtPaperNo.Text.Trim();
        string custPhone = CommonHelper.GetCustPhone(hidForPhone.Value) == txtCustPhone.Text.Trim() ? hidForPhone.Value : txtCustPhone.Text.Trim();
        string custAddr = CommonHelper.GetCustAddress(hidForAddr.Value) == txtCustAddr.Text.Trim() ? hidForAddr.Value : txtCustAddr.Text.Trim();
        hidNewCardNo.Value = txtCardNo.Text;
        context.SPOpen();
        context.AddField("p_ID").Value = DealString.GetRecordID(hidTradeNo.Value, hidAsn.Value);
        context.AddField("p_oldCardNo").Value = oldCardNo;
        context.AddField("p_newCardNo").Value = newCardNo;
        context.AddField("p_asn").Value = hidAsn.Value.Substring(4, 16);

        context.AddField("p_operCardNo").Value = context.s_CardID; // 操作员卡
        context.AddField("p_terminalNo").Value = "112233445566";   // 目前固定写成112233445566

        int usableTimes = int.Parse(hidUsabelTimes.Value);

        // 12位,年月日8位+标志位2位+次数2位



        // 园林年卡的标志位为'01',休闲年卡的标志位为'02'.次数都是16进制
        hidParkInfo.Value = hidEndDate.Value + "01" + usableTimes.ToString("X2");
        context.AddField("p_endDateNum").Value = hidParkInfo.Value;

        //加密 ADD BY JIANGBB 2012-04-20
        AESHelp.AESEncrypt(txtCustName.Text, ref strBuilder);
        context.AddField("p_custName").Value = strBuilder.ToString();
        context.AddField("p_custSex").Value = selCustSex.Text == "男" ? "0" : "1";
        context.AddField("p_custBirth").Value = txtCustBirth.Text;
        context.AddField("p_paperType").Value = paperTypeCode;

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(custPaperNo, ref strBuilder);
        context.AddField("p_paperNo").Value = strBuilder.ToString();

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(custAddr, ref strBuilder);
        context.AddField("p_custAddr").Value = strBuilder.ToString();
        context.AddField("p_custPost").Value = txtCustPost.Text;

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(custPhone, ref strBuilder);
        context.AddField("p_custPhone").Value = strBuilder.ToString();
        context.AddField("p_custEmail").Value = txtEmail.Text;
        context.AddField("p_remark").Value = txtRemark.Text;

        //add by jiangbb 2012-08-21 
        context.AddField("P_PASSPAPERNO").Value = custPaperNo; //加密证件号码---2013-05-16 置为明文
        context.AddField("P_PASSCUSTNAME").Value = txtCustName.Text;//加密姓名---2013-05-16 置为明文

        //add by jiangbb 2013-11-14 判断旧卡是否在有效期内，过期的旧卡数据将不会同步给园林 0不同步 1同步
        context.AddField("p_SERVICEFOR").Value = hidServiceFor.Value;

        bool ok = context.ExecuteSP("SP_AS_GardenCardChange");


        txtCardNo.Text = "";
        hidReadCardOK.Value = "fail";
        UserCardHelper.resetData(gvOldCardInfo, null);
        gvOldCardInfo.SelectedIndex = -1;
        //btnUpload.Enabled = false;
        btnSubmit.Enabled = false;

        // 调用成功，显示成功信息



        if (ok)
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "startPark();", true);

            btnPrintPZ.Enabled = true;

            ASHelper.preparePingZheng(ptnPingZheng, oldCardNo, txtCustName.Text, "园林年卡补换卡", "0.00"
                , "0.00", newCardNo, txtPaperNo.Text, "0.00", "0.00", hidAccRecv.Value, context.s_UserID,
                context.s_DepartName,
                selPaperType.Text == "" ? "" : selPaperType.Text, "0.00", hidAccRecv.Value);
        }
        readCardPic(hidNewCardNo.Value);
        hfPic.Value = "";
        Session["PicData"] = null;
        preview_size_fake.Src = "";
        hidNewCardNo.Value = "";
    }
    protected void BtnShowPic_Click(object sender, EventArgs e)
    {
        Session["PicData"] = null;
        preview_size_fake.Src = "";
        string str = hfPic.Value;
        if (string.IsNullOrEmpty(str))
            return;
        int len = str.Length / 2;
        byte[] pic = new byte[len];
        HexStrToBytes(str, ref pic, len);
        Session["PicData"] = pic;
        preview_size_fake.Src = "../../picture.aspx?id=" + DateTime.Now.ToString();
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
    private void readCardPic(string cardNo)
    {
        byte[] imageData = ReadImage(cardNo);
        if (imageData != null)
        {
            Session["PicData"] = imageData;
            preview_size_fake.Src = "../../picture.aspx?id=" + DateTime.Now.ToString();
            tdMsg.Visible = false;//隐藏照片采集提示信息add by youyue20140414
        }
        else
        {
            context.SPOpen();
            context.AddField("p_CARDNO").Value = cardNo;
            context.AddField("p_LENGTH", "String", "output", "16", null);
            bool ok = context.ExecuteSP("SP_AS_SMK_PICTURELENGTH");
            if (ok)
            {
                string length = context.GetFieldValue("p_LENGTH").ToString().Trim();
                if (length != "1")
                {
                    tdMsg.Visible = true;//如果卡管里也不存在用户照片，则提示采集照片提示信息add by youyue20140512
                }
                else
                {
                    tdMsg.Visible = false;
                }
            }
        }
    }
    private byte[] ReadImage(string cardNo)
    {
        string selectSql = "Select PICTURE From TF_F_CARDPARKPHOTO_SZ Where CARDNO=:CARDNO";
        context.DBOpen("Select");
        context.AddField(":CARDNO").Value = cardNo;
        DataTable dt = context.ExecuteReader(selectSql);
        if (dt != null && dt.Rows.Count > 0 && dt.DefaultView[0]["PICTURE"].ToString() != "")
        {
            return (byte[])dt.Rows[0].ItemArray[0];
        }
        return null;
    }
    private void SavePic()
    {

        if (Session["PicData"] == null)
            return;

        //int len = str.Length / 2;
        //byte[] pic = new byte[len];
        //HexStrToBytes(str, ref pic, len);
        context.DBOpen("Select");
        context.AddField(":p_cardNo").Value = txtCardNo.Text.Trim();
        DataTable dt = context.ExecuteReader(@"
                                        SELECT * 
                                        From TF_F_CARDPARKPHOTO_SZ
                                        WHERE CARDNO = :p_cardNo
                            ");
        string sql = "";
        if (dt.Rows.Count == 0)
        {
            context.DBOpen("Insert");
            sql = "INSERT INTO TF_F_CARDPARKPHOTO_SZ (CARDNO  , PICTURE ,OPERATETIME,OPERATEDEPARTID,OPERATESTAFFNO) VALUES(:p_cardNo, :BLOB,:OPERATETIME,:OPERATEDEPARTID,:OPERATESTAFFNO)";
        }
        else
        {
            context.DBOpen("Update");
            sql = "Update TF_F_CARDPARKPHOTO_SZ Set PICTURE = :BLOB,OPERATETIME = :OPERATETIME,OPERATEDEPARTID = :OPERATEDEPARTID,OPERATESTAFFNO = :OPERATESTAFFNO Where CARDNO = :p_cardNo";
        }
        context.AddField(":p_cardNo", "String").Value = txtCardNo.Text.Trim();
        context.AddField(":BLOB", "Blob").Value = Session["PicData"];
        context.AddField(":OPERATETIME", "DateTime").Value = DateTime.Now;
        context.AddField(":OPERATEDEPARTID", "String").Value = context.s_DepartID;
        context.AddField(":OPERATESTAFFNO", "String").Value = context.s_UserID;

        context.ExecuteNonQuery(sql);
        context.DBCommit();
    }
    /// <summary>
    /// 获取图片二进制流文件 add by youyue 20140414
    /// </summary>
    /// <param name="FileUpload1">upload控件</param>
    /// <returns>二进制流</returns>
    private byte[] GetPicture(FileUpload FileUpload1)
    {
        int len = FileUpload1.FileBytes.Length;
        if (len > 1024 * 1024 * 5)
        {
            context.AddError("A094780014：上传文件大于5M,文件上传失败");
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
            }
            else
            {
                context.DBOpen("BatchDML");
                sql = "Update TF_F_CARDPARKPHOTO_SZ Set PICTURE = :BLOB,OPERATETIME = :OPERATETIME,OPERATEDEPARTID = :OPERATEDEPARTID,OPERATESTAFFNO = :OPERATESTAFFNO Where CARDNO = :p_cardNo";

            }

            context.AddField(":p_cardNo", "String").Value = p_cardno;
            context.AddField(":BLOB", "BLOB").Value = buff;
            context.AddField(":OPERATETIME", "DateTime").Value = DateTime.Now;
            context.AddField(":OPERATEDEPARTID", "String").Value = context.s_DepartID;
            context.AddField(":OPERATESTAFFNO", "String").Value = context.s_UserID;

            context.ExecuteNonQuery(sql);
            context.DBCommit();


        }
    }

    //查询新卡是否是园林账户表中无效状态的卡(即通过功能补换页面将旧卡置为无效的卡)
    private void checkGardenIsInvalid()
    {
        // 从园林卡资料表中检查USETAG值是否是0
        DataTable data = ASHelper.callQuery(context, "ParkCardUseIsInvalid", txtCardNo.Text);
        if (data.Rows.Count > 0)
        {
            context.AddError("A005020002: 当前卡已经是园林账户表中无效的卡，不可再次开通");
        }
    }
}
