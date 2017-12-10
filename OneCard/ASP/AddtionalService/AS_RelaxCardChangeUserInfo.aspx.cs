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
using System.Drawing;
using System.Drawing.Imaging;

/**********************************
 * 休闲卡修改资料
 * 2015-4-24
 * gl
 * 初次编写
 * ********************************/
public partial class ASP_AddtionalService_AS_RelaxCardChangeUserInfo : Master.FrontMaster
{
    #region Page Load
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        hidStaffNo.Value = Session["STAFF"].ToString();
        ScriptManager.RegisterStartupScript(this, this.GetType(), "js",
              "loadWebcam();", true);
        if (Page.IsPostBack) return;

        // 初始化证件类型
        ASHelper.initPaperTypeList(context, selPaperType);
        // 初始化性别
        ASHelper.initSexList(selCustSex);

        Session["PicData"] = null;
        Session["PicDataOther"] = null;

        tdMsg.Visible = false;//隐藏照片采集提示信息add by youyue20140414
    }
    #endregion

    #region EventHandler
    // 读卡处理
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        hfPic.Value = "";
        Session["PicData"] = null;
        //preview_size_fake.Src = "";

        #region add by shil 20130909,如果是旅游年卡，则不允许在该页面办理业务
        //验证卡片是否旅游年卡(51)，如果是旅游年卡，则不允许在该页面办理业务

        bool cardTypeOk = CommonHelper.allowCardtype(context, txtCardNo.Text, "5101", "5103");
        if (cardTypeOk == false)
        {
            return;
        }

        #endregion

        checkGardenIsInvalid();//判断当前卡是否是是园林账户表中无效的卡 add by youyue 20141229

        hidWarning.Value = "";

        // 读取库内休闲卡相关信息(到期日期，可用次数，开卡次数）
        ASHelper.readRelaxOrGardenInfo(context, txtCardNo,
     labRelaxEndDate, labAccountType, labGardenEndDate);

        //休闲套餐名称
        ASHelper.readPackage(context, txtCardNo.Text, labRelaxPackage, hidFuncType);


        // 读取客户资料
        readCustInfo(txtCardNo.Text, txtCustName, txtCustBirth,
            selPaperType, txtPaperNo, selCustSex, txtCustPhone, txtCustPost,
            txtCustAddr, txtEmail, txtRemark);

        //读取照片信息
        readCardPic(txtCardNo.Text);

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

        // 检查黑名单
        checkBlackList();

        labGardenEndDate.Text = hidParkInfo.Value.Substring(0, 8);
        string times = hidParkInfo.Value.Substring(10, 2);
        //labUsableTimes.Text = times == "FF" ? "FF" : "" + Convert.ToInt32(times, 16);

       
        if (context.hasError()) return;

        //add by jiangbb 2012-10-09 市民卡不能修改客户资料
        if (txtCardNo.Text.Substring(4, 2).ToString() == "18")
        {
            context.AddMessage("提示：开卡卡号为市民卡，客户资料不会被修改");
        }

        //判断是否是市民卡，是则不能读二代证和修改姓名、证件类型、证件号码
        if (txtCardNo.Text.Substring(0, 6) == "215018")
        {
            txtReadPaper.Enabled = false;
            txtCustName.Enabled = false;
            selPaperType.Enabled = false;
            txtPaperNo.Enabled = false;
        }
        else
        {
            txtReadPaper.Enabled = true;
            txtCustName.Enabled = true;
            selPaperType.Enabled = true;
            txtPaperNo.Enabled = true;
        }

        btnUpload.Enabled = hidWarning.Value.Length == 0;
        btnUpdate.Enabled = hidWarning.Value.Length == 0;
    }
    // 读数据库处理
    protected void btnReadDb_Click(object sender, EventArgs e)
    {
        hfPic.Value = "";
        Session["PicData"] = null;
        //preview_size_fake.Src = "";

        #region add by shil 20130909,如果是旅游年卡，则不允许在该页面办理业务
        //验证卡片是否旅游年卡(51)，如果是旅游年卡，则不允许在该页面办理业务

        bool cardTypeOk = CommonHelper.allowCardtype(context, txtCardNo.Text, "5101", "5103");
        if (cardTypeOk == false)
        {
            return;
        }

        #endregion

        checkGardenIsInvalid();//判断当前卡是否是是园林账户表中无效的卡 add by youyue 20141229

        hidWarning.Value = "";

        // 读取库内休闲卡相关信息(到期日期，可用次数，开卡次数）
        ASHelper.readRelaxOrGardenInfo(context, txtCardNo,
     labRelaxEndDate, labAccountType, labGardenEndDate);

        //休闲套餐名称
        ASHelper.readPackage(context, txtCardNo.Text, labRelaxPackage, hidFuncType);

        // 读取客户资料
        readCustInfo(txtCardNo.Text, txtCustName, txtCustBirth,
            selPaperType, txtPaperNo, selCustSex, txtCustPhone, txtCustPost,
            txtCustAddr, txtEmail, txtRemark);

        //读取照片信息
        readCardPic(txtCardNo.Text);

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

        // 检查黑名单
        checkBlackList();

        //labGardenEndDate.Text = "";
       // labUsableTimes.Text = "";

        if (context.hasError()) return;

        //add by jiangbb 2012-10-09 市民卡不能修改客户资料
        if (txtCardNo.Text.Substring(4, 2).ToString() == "18")
        {
            context.AddMessage("提示：开卡卡号为市民卡，客户资料不会被修改");
        }

        //判断是否是市民卡，是则不能读二代证和修改姓名、证件类型、证件号码
        if (txtCardNo.Text.Substring(0, 6) == "215018")
        {
            txtReadPaper.Enabled = false;
            txtCustName.Enabled = false;
            selPaperType.Enabled = false;
            txtPaperNo.Enabled = false;
        }
        else
        {
            txtReadPaper.Enabled = true;
            txtCustName.Enabled = true;
            selPaperType.Enabled = true;
            txtPaperNo.Enabled = true;
        }

        btnUpload.Enabled = hidWarning.Value.Length == 0;
        btnUpdate.Enabled = hidWarning.Value.Length == 0;
    }


    protected void btnUpload_Click(object sender, EventArgs e)
    {
        if (FileUpload1.PostedFile.FileName != "")       //导入方式
        {
            System.IO.Stream fileStream = Stream.Null;
            int flag = validateForPicture(FileUpload1, out fileStream);
            if (flag == -1) return;
            //string path = HttpContext.Current.Server.MapPath("../../tmp/test_thu.jpg");
            string path = HttpContext.Current.Server.MapPath("../../tmp/pic_thu_" + Session["STAFF"].ToString() + ".jpg");
            bool bl = GetPicThumbnail(fileStream, path, flag);
            Session["PicData"] = GetPicture(path);
        }

        if (Session["PicData"] == null)
        {
            context.AddError("没有照片信息！");
            return;
        }

        //ValidatePicFormat();
        preview_size_fake.Src = "../../picture.aspx?id=" + DateTime.Now.ToString();
        context.AddMessage("照片已导入，点击提交按钮后生效！");
    }

    // 修改处理
    protected void btnUpdate_Click(object sender, EventArgs e)
    {

        //查询是否有记录在审核中
        DataTable data = ASHelper.callQuery(context, "QueryRelaxCardChangeOldInfo", txtCardNo.Text);
        if (data.Rows.Count > 0)
        {
            context.AddError("营业员" + data.Rows[0][0].ToString() + "于" + data.Rows[0][1].ToString() + "提交的数据正在审核中...");
            return;
        }

        //查询是否有照片记录在审核中
        DataTable dtImage = ASHelper.callQuery(context, "QueryRelaxCardChangeOldImage", txtCardNo.Text);
        if (dtImage.Rows.Count > 0)
        {
            context.AddError("营业员" + dtImage.Rows[0][0].ToString() + "于" + dtImage.Rows[0][1].ToString() + "提交的照片正在审核中...");
            return;
        }

        submitValidate();

        string custPaperNo = CommonHelper.GetPaperNo(hidForPaperNo.Value) == txtPaperNo.Text.Trim() ? hidForPaperNo.Value : txtPaperNo.Text.Trim();
        string custPhone = CommonHelper.GetCustPhone(hidForPhone.Value) == txtCustPhone.Text.Trim() ? hidForPhone.Value : txtCustPhone.Text.Trim();
        string custAddr = CommonHelper.GetCustAddress(hidForAddr.Value) == txtCustAddr.Text.Trim() ? hidForAddr.Value : txtCustAddr.Text.Trim();

        StringBuilder strPaperNoBuilder = new StringBuilder();
        AESHelp.AESEncrypt(custPaperNo, ref strPaperNoBuilder);

        if (context.hasError()) return;


        // 调用惠民休闲年卡修改数据存储过程
        context.SPOpen();
        context.AddField("P_CARDNO").Value = txtCardNo.Text;
        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(txtCustName.Text, ref strBuilder);
        context.AddField("P_CUSTNAME").Value = strBuilder.ToString();
        context.AddField("P_CUSTSEX").Value = selCustSex.SelectedValue;
        context.AddField("P_CUSTBIRTH").Value = txtCustBirth.Text;
        context.AddField("P_PAPERTYPECODE").Value = selPaperType.SelectedValue;

        context.AddField("P_PAPERNO").Value = strPaperNoBuilder.ToString();

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(custAddr, ref strBuilder);
        context.AddField("P_CUSTADDR").Value = strBuilder.ToString();
        context.AddField("P_CUSTPOST").Value = txtCustPost.Text;

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(custPhone, ref strBuilder);
        context.AddField("P_CUSTPHONE").Value = strBuilder.ToString();
        context.AddField("P_CUSTEMAIL").Value = txtEmail.Text;
        context.AddField("P_REMARK").Value = txtRemark.Text;

        // 执行存储过程
        bool ok = context.ExecuteSP("SP_AS_RelaxCardChangeUserInfo");

        btnUpload.Enabled = false;
        btnUpdate.Enabled = false;

        // 执行成功，显示成功消息
        if (ok)
        {
            btnUpdate.Enabled = false;
            context.AddMessage("修改资料成功");

           
            //上传照片
            try
            {
                ValidatePicFormat();
                SavePic();
                readCardPic(txtCardNo.Text);
                context.AddMessage("照片上传成功");
                hidPicType.Value = null;
                Session["PicData"] = null;
            }
            catch
            {
                context.AddMessage("S00501B014：保存照片失败");//系统是否存在照片不做为园林开通/续费的必要条件
            }
        }

        hfPic.Value = "";
        Session["PicData"] = null;
        
        preview_size_fake.Src = "";
        readCardPic(txtCardNo.Text);
    }

    //显示照片
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
    #endregion

    #region Private

    #region 读卡
    // 检查黑名单列表
    private void checkBlackList()
    {
        // 从休闲卡黑名单信息表中查询
        DataTable data = ASHelper.callQuery(context, "XXParkBlackList", txtCardNo.Text);
        if (data.Rows.Count == 0)
        {
            return;
        }
        string levelFlag = (string)data.Rows[0].ItemArray[0];
        if (levelFlag == "0")
        {
            context.AddError("A00501A004: 当前卡片已经存在于黑名单中，禁止修改功能");
        }
        else if (levelFlag == "1")
        {
            hidWarning.Value += HttpUtility.HtmlEncode("当前卡片已经存在于黑名单中;\n");
        }
    }

    //查询新卡是否是园林账户表中无效状态的卡(即通过功能补换页面将旧卡置为无效的卡)
    private void checkGardenIsInvalid()
    {
        // 从园林卡资料表中检查USETAG值是否是0
        DataTable data = ASHelper.callQuery(context, "ParkCardUseIsInvalid", txtCardNo.Text);
        if (data.Rows.Count > 0)
        {
            context.AddError("A005020002: 当前卡已经是园林账户表中无效的卡，不可修改资料");
        }
    }

    #endregion

    #region 提交校验
    // 提交校验
    private void submitValidate()
    {
        // 客户信息校验
        custInfoForValidate(txtCustName, txtCustBirth,
            selPaperType, txtPaperNo, selCustSex, txtCustPhone, txtCustPost,
            txtCustAddr, txtEmail, txtRemark);

        //add by youyue 20140414
        if (!string.IsNullOrEmpty(FileUpload1.FileName))
        {
            string[] strPics = { ".jpg", ".bmp", ".jpeg", ".png" };
         
            int index = Array.IndexOf(strPics, Path.GetExtension(FileUpload1.FileName).ToLower());
            if (index == -1)
            {
                context.AddError("A094780002:上传文件格式必须为jpg|bmp|jpeg|png");
            }
        }
        else
        {
            int len = FileUpload1.FileBytes.Length;
            if (len > 1024 * 1024 * 5)
            {
                context.AddError("A094780018：上传文件不可大于5M", FileUpload1);

            }
        }

    }

    //客户信息校验
    private void custInfoForValidate(TextBox txtCustName, TextBox txtCustBirth,
            DropDownList selPaperType, TextBox txtPaperNo,
            DropDownList selCustSex, TextBox txtCustPhone,
            TextBox txtCustPost, TextBox txtCustAddr, TextBox txtCustEmail, TextBox txtRemark)
    {
        Validation valid = new Validation(context);
        txtCustName.Text = txtCustName.Text.Trim();
        valid.check(Validation.strLen(txtCustName.Text) <= 50, "A005010001, 客户姓名长度不能超过50", txtCustName);
        valid.check(!Validation.isEmpty(txtCustName), "客户姓名不能为空", txtCustName);

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

        if (selPaperType.SelectedValue == "")
        {
            context.AddError("证件类型不能为空", selPaperType);
        }

        b = Validation.isEmpty(txtPaperNo);
        valid.check(!b, "证件号码不能为空", txtPaperNo);
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
        if (selPaperType.SelectedValue=="00" &&!Validation.isPaperNo(txtPaperNo.Text.Trim()))
            context.AddError("证件号码验证不通过", txtPaperNo);

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

    #endregion

    #region 图片处理
    /// <summary>
    /// 图片压缩
    /// </summary>
    /// <param name="sFile">图片原路径</param>
    /// <param name="outPath">图片输出路径</param>
    /// <param name="flag">压缩比例1-100</param>
    /// <returns></returns>
    private bool GetPicThumbnail(Stream fileStream, string outPath, int flag)
    {
        //FileStream fs = new FileStream(FileUpload1.PostedFile.InputStream, FileMode.Open, FileAccess.Read);
        System.Drawing.Image iSource = System.Drawing.Image.FromStream(fileStream);
        //System.Drawing.Image iSource = System.Drawing.Image.FromFile(sFile);
        ImageFormat tFormat = iSource.RawFormat;

        //以下代码为保存图片时，设置压缩质量  
        EncoderParameters ep = new EncoderParameters();
        long[] qy = new long[1];
        qy[0] = flag;//设置压缩的比例1-100  
        EncoderParameter eParam = new EncoderParameter(System.Drawing.Imaging.Encoder.Quality, qy);
        ep.Param[0] = eParam;
        try
        {
            ImageCodecInfo[] arrayICI = ImageCodecInfo.GetImageEncoders();
            ImageCodecInfo jpgICIinfo = null;
            for (int x = 0; x < arrayICI.Length; x++)
            {
                if (arrayICI[x].FormatDescription.Equals("JPEG"))
                {
                    jpgICIinfo = arrayICI[x];
                    break;
                }
            }

            if (jpgICIinfo != null)
            {
                Bitmap map = new Bitmap(iSource.Width, iSource.Height);
                Graphics gra = Graphics.FromImage(map);
                gra.DrawImage(iSource, 0, 0, iSource.Width, iSource.Height);
                iSource.Dispose();
                //gra.Clear(Color.Transparent);
                gra.Dispose();
                map.Save(outPath, jpgICIinfo, ep);
                map.Dispose();
            }
            else
            {
                iSource.Save(outPath, tFormat);
            }
            return true;
        }
        catch
        {
            return false;
        }
        finally
        {
            iSource.Dispose();
            iSource.Dispose();
        }
    }

    /// <summary>
    /// 校验上传图片的大小以及各式
    /// </summary>
    /// <param name="file">FileUpload控件</param>
    /// <returns></returns>
    private int validateForPicture(FileUpload file, out Stream fileStream)
    {

        string[] strPics = { ".jpg", ".bmp", ".jpeg", ".png" };
        fileStream = Stream.Null;
        int index = Array.IndexOf(strPics, Path.GetExtension(FileUpload1.FileName).ToLower());
        if (index == -1)
        {
            context.AddError("A094780002:上传文件格式必须为jpg|bmp|jpeg|png");
            return -1;
        }
        fileStream = file.PostedFile.InputStream;
        int len = file.FileBytes.Length;
        if (len < 1024 * 10)
        {
            context.AddError("A094780014：上传文件不能小于10KB");
        }
        else if (len > 1024 * 1024 * 5)
        {
            context.AddError("A094780014：上传文件不能大于5M");
        }

        //文件大小返回不同压缩等级
        if (len >= 1024 * 500 && len < 1024 * 1024)
        {
            return 30;
        }
        else if (len >= 1024 * 1024 && len < 1024 * 1024 * 2)
        {
            return 10;
        }
        else if (len >= 1024 * 1024 * 2 && len < 1024 * 1024 * 5)
        {
            return 5;
        }
        else if (len >= 1024 * 10 && len < 1024 * 500)
        {
            return 50;
        }
        else
        {
            return -1;
        }
    }
    private int HexStrToBytes(string strSou, ref byte[] BytDes, int bytCount)
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
    /// <summary>
    /// 校验图片格式，并且转换成JPG
    /// </summary>
    private void ValidatePicFormat()
    {
        MemoryStream ms = new MemoryStream((byte[])Session["PicData"]);

        System.Drawing.Image img = System.Drawing.Image.FromStream(ms);

        //判断图片是否是JPG格式
        if (img.RawFormat.Guid != ImageFormat.Jpeg.Guid)
        {
            using (MemoryStream mstream = new MemoryStream())
            {
                Bitmap bit = new Bitmap(img);
                bit.Save(mstream, ImageFormat.Jpeg);
                img.Dispose();
                ms.Dispose();

                Session["PicData"] = mstream.ToArray();
                mstream.Dispose();
            }
        }
    }


    /// <summary>
    /// 从库里读取照片
    /// </summary>
    /// <param name="cardNo"></param>
    private byte[] ReadImage(string cardNo)
    {
        string selectSql = "Select PICTURE From TF_F_CARDPARKPHOTOCHANGE_SZ Where CARDNO=:CARDNO AND STATE='0' ";
        context.DBOpen("Select");
        context.AddField(":CARDNO").Value = cardNo;
        DataTable dt = context.ExecuteReader(selectSql);
        if (dt != null && dt.Rows.Count > 0 && dt.DefaultView[0]["PICTURE"].ToString() != "")
        {
            return (byte[])dt.Rows[0].ItemArray[0];
        }
         selectSql = "Select PICTURE From TF_F_CARDPARKPHOTO_SZ Where CARDNO=:CARDNO";
        context.DBOpen("Select");
        context.AddField(":CARDNO").Value = cardNo;
         dt = context.ExecuteReader(selectSql);
        if (dt != null && dt.Rows.Count > 0 && dt.DefaultView[0]["PICTURE"].ToString() != "")
        {
            return (byte[])dt.Rows[0].ItemArray[0];
        }

        return null;
    }

    /// <summary>
    /// 保存照片至审核表中
    /// </summary>
    private void SavePic()
    {
        if (Session["PicData"] == null)
            return;

        context.DBOpen("Select");
        context.AddField(":p_cardNo").Value = txtCardNo.Text.Trim();
        DataTable dt = context.ExecuteReader(@"
                                        SELECT * 
                                        From TF_F_CARDPARKPHOTOCHANGE_SZ
                                        WHERE CARDNO = :p_cardNo
                            ");
        string sql = "";
        if (dt.Rows.Count == 0)
        {
            context.DBOpen("Insert");
            sql = "INSERT INTO TF_F_CARDPARKPHOTOCHANGE_SZ (CARDNO  , PICTURE ,OPERATETIME,OPERATEDEPARTID,OPERATESTAFFNO,STATE) VALUES(:p_cardNo, :BLOB,:OPERATETIME,:OPERATEDEPARTID,:OPERATESTAFFNO,'0')";
        }
        else
        {
            context.DBOpen("Update");
            sql = "Update TF_F_CARDPARKPHOTOCHANGE_SZ Set PICTURE = :BLOB,OPERATETIME = :OPERATETIME,OPERATEDEPARTID = :OPERATEDEPARTID,OPERATESTAFFNO = :OPERATESTAFFNO,STATE='0' Where CARDNO = :p_cardNo";

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
    private byte[] GetPicture(string path)
    {
        FileStream file = new FileStream(path, FileMode.Open, FileAccess.Read);

        byte[] buffer = new byte[file.Length];
        file.Read(buffer, 0, (int)file.Length);

        file.Dispose();
        FileInfo fi = new FileInfo(path);
        fi.Delete();
        return buffer;

    }


    #endregion

    #endregion
}