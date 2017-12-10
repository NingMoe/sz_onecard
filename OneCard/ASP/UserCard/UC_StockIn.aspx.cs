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
using TM;
using TDO.ResourceManager;
using TDO.CardManager;
using PDO.UserCard;
using PDO.PersonalBusiness;

// 用户卡入库处理

public partial class ASP_UserCard_UC_StockIn : Master.Master
{
    // 输入项校验

    private void SubmitValidate()
    {
        Validation valid = new Validation(context);

        // 对起始卡号和结束卡号进行校验
        UserCardHelper.validateCardNoRange(context, txtFromCardNo, txtToCardNo);

        //对卡片单价进行非空、数字检验

        UserCardHelper.validatePrice(context, txtUnitPrice, "A002P01009: 卡片单价不能为空", "A002P01010: 卡片单价必须是10.2的格式");

        //对应用版本进行非空、英数字检验

        UserCardHelper.validateAlpha(context, txtAppVersion, "A002P01011: 应用版本不能为空", "A002P01012: 应用版本必须为英文或者数字");

        // 对有效日期范围进行非空、格式校验

        UserCardHelper.validateDateRange(context, txtEffDate, txtExpDate);
    }

    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;
        
        txtFromCardNo.Attributes["OnBlur"]   = "javascript:return Change();";
        txtToCardNo.Attributes  ["OnBlur"]   = "javascript:return Change();";
        txtUnitPrice.Attributes ["OnChange"] = "javascript:return Change();";
        
        setReadOnly(txtCardSum, txtTotal, txtCardType, txtFaceType);

        //从COS类型编码表(TD_M_COSTYPE)中读取数据，放入下拉列表中

        UserCardHelper.selectCosType(context, selCosType, false);

        //从IC卡类型编码表(TD_M_CARDTYPE)中读取数据，放入下拉列表中

        //UserCardHelper.selectCardType(context, selCardType, false);

        //从厂商编码表(TD_M_MANU)中读取数据，放入下拉列表中

        UserCardHelper.selectManu(context, selProducer, false);

        //从IC卡卡面编码表(TD_M_CARDSURFACE)中读取数据，放入下拉列表中

        //UserCardHelper.selectCardFace(context, selFaceType, false);

        //从IC卡芯片类型编码表(TD_M_CARDCHIPTYPE)中读取数据，放入下拉列表中

        UserCardHelper.selectChipType(context, selChipType, false);
    }
    protected void txtToCardNo_Changed(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        UserCardHelper.validateCardNoRange(context, txtFromCardNo, txtToCardNo);
        if (context.hasError()) return;

        TD_M_CARDTYPETDO ddoTD_M_CARDTYPEIn = new TD_M_CARDTYPETDO();
        ddoTD_M_CARDTYPEIn.CARDTYPECODE = txtToCardNo.Text.Substring(4, 2);
        TD_M_CARDTYPETDO ddoTD_M_CARDTYPEOut = (TD_M_CARDTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_CARDTYPEIn, typeof(TD_M_CARDTYPETDO), null, "TD_M_CARDTYPE_CHUSER", null);
        if (ddoTD_M_CARDTYPEOut == null)
        {
            context.AddError("S002P01I02");
            return;
        }
        txtCardType.Text = ddoTD_M_CARDTYPEOut.CARDTYPENAME;

        TD_M_CARDSURFACETDO ddoTD_M_CARDSURFACEIn = new TD_M_CARDSURFACETDO();
        ddoTD_M_CARDSURFACEIn.CARDSURFACECODE = txtToCardNo.Text.Substring(4, 4);
        TD_M_CARDSURFACETDO ddoTD_M_CARDSURFACEOut = (TD_M_CARDSURFACETDO)tmTMTableModule.selByPK(context, ddoTD_M_CARDSURFACEIn, typeof(TD_M_CARDSURFACETDO), null, "TD_M_CARDSURFACE_CODE", null);
        if (ddoTD_M_CARDSURFACEOut == null)
        {
            context.AddError("S002P01I04");
            return;
        }
        txtFaceType.Text = ddoTD_M_CARDSURFACEOut.CARDSURFACENAME;

    }
    // 入库处理
    protected void btnStockIn_Click(object sender, EventArgs e)
    {

        //添加对市民卡的验证
        SP_SmkCheckPDO smkpdo = new SP_SmkCheckPDO();
        smkpdo.CARDNO = txtFromCardNo.Text;
        bool smkFromCard = TMStorePModule.Excute(context, smkpdo);

        smkpdo.CARDNO = txtToCardNo.Text;
        bool smkToCard = TMStorePModule.Excute(context, smkpdo);
        if (smkFromCard == false||smkToCard==false)
        {
            context.AddError("A006010006");
            return;
        }

        // 输入校验
        SubmitValidate();
        if (context.hasError()) return;

        // 调用入库存储过程
        SP_UC_StockInPDO pdo = new SP_UC_StockInPDO();
        pdo.fromCardNo = txtFromCardNo.Text;                // 起始卡号
        pdo.toCardNo = txtToCardNo.Text;                    // 结束卡号
        pdo.cosType = selCosType.SelectedValue;             // COS类型
        pdo.unitPrice = Validation.getPrice(txtUnitPrice);  // 单价
        pdo.faceType = txtToCardNo.Text.Substring(4, 4);    // 卡面类型
        pdo.cardType = txtToCardNo.Text.Substring(4, 2);    // 卡片类型
        pdo.chipType = selChipType.SelectedValue;           // 芯片类型
        pdo.producer = selProducer.SelectedValue;           // 生产厂商
        pdo.appVersion = txtAppVersion.Text;                // 应用版本号

        pdo.effDate = txtEffDate.Text;                      // 起始有效期

        pdo.expDate = txtExpDate.Text;                      // 结束有效期


        bool ok = TMStorePModule.Excute(context, pdo);

        if(ok) AddMessage("D002P01000: 入库成功");
    }
}
