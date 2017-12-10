using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using TM;
using TDO.ResourceManager;
using TDO.UserManager;
using TDO.BusinessCode;
using Common;
using PDO.PersonalBusiness;
using System.Collections.Generic;

namespace Master
{
    public class FrontMaster : Master
    {
        protected void initFeeItem(GridView gvResult, string tradeTypeCode,
            HiddenField hidDeposit, HiddenField hidCardPost,
            HiddenField hidOtherFee, HiddenField hidAccRecv,
            TextBox txtRealRecv,
            bool computeDeposit, int cardDeposit, int eldCardDeposit)
        {
            // 从费用配置表中读取所有费用

            DataTable data = ASHelper.callQuery(context,
                "ReadFeeItems", tradeTypeCode);

            DataTable dt = new DataTable();
            dt.Columns.Add("FEETYPENAME", typeof(string));
            dt.Columns.Add("BASEFEE", typeof(string));
            Object[] row = null;
            decimal total = 0;

            hidDeposit.Value = "0";
            hidCardPost.Value = "0";
            hidOtherFee.Value = "0";

            int i = 0;
            for (; i < data.Rows.Count; ++i)
            {
                row = data.Rows[i].ItemArray;
                total += (decimal)row[1];     // 合计费用
                if ((string)row[0] == "00") // 押金
                {
                    hidDeposit.Value = "" + ((decimal)row[1]).ToString("n");
                    if (computeDeposit) continue;
                }
                else if ((string)row[0] == "10") // 卡费
                {
                    hidCardPost.Value = "" + ((decimal)row[1]).ToString("n");
                }
                else if ((string)row[0] == "99") // 其他费用
                {
                    hidOtherFee.Value = "" + ((decimal)row[1]).ToString("n");
                }

                dt.Rows.Add((string)row[2], ((decimal)row[1]).ToString("n"));
            }


            if (computeDeposit)
            {
                // 计算退押金
                hidDeposit.Value = (
                    (Convert.ToDouble(hidDeposit.Value)
                    + eldCardDeposit / 100.0 - cardDeposit / 100.0)).ToString("n");
                total += (decimal)(eldCardDeposit / 100.0 - cardDeposit / 100.0);
                dt.Rows.Add("押金", hidDeposit.Value);
            }
            else
            {
                dt.Rows.Add("", "");
            }

            for (; i < 6; ++i)
            {
                dt.Rows.Add("", "");
            }

            txtRealRecv.Text = total.ToString("0");
            hidAccRecv.Value = total.ToString("n");
            dt.Rows.Add("合计应收", txtRealRecv.Text);

            gvResult.DataSource = dt;
            gvResult.DataBind();
        }

        protected void custInfoValidate(TextBox txtCustName, TextBox txtCustBirth,
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
                if (b)
                {
                    valid.beAlpha(txtPaperNo, "A005010007: 证件号码必须是英文或者数字");
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

        protected void readCustInfo(string cardNo,
            Label txtCustName, Label txtCustBirth,
            Label selPaperType, Label txtPaperNo,
            Label selCustSex, Label txtCustPhone,
            Label txtCustPost, Label txtCustAddr, Label txtCustEmail, Label txtRemark)
        {
            readCustInfo(cardNo, txtCustName, txtCustBirth,
                selPaperType, txtPaperNo,
                selCustSex, txtCustPhone,
                txtCustPost, txtCustAddr, txtCustEmail, txtRemark, false);
        }

        protected void readCustInfo(string cardNo,
            Label txtCustName, Label txtCustBirth,
            Label selPaperType, Label txtPaperNo,
            Label selCustSex, Label txtCustPhone,
            Label txtCustPost, Label txtCustAddr, Label txtCustEmail, Label txtRemark, bool ignoreError)
        {
            DataTable data = ASHelper.callQuery(context, "QueryCustInfo", cardNo);

            if (data.Rows.Count == 0)
            {
                if (!ignoreError)context.AddError("A00501A002: 无法读取卡片客户资料");
                return;
            }

            //add by jiangbb 解密
            CommonHelper.AESDeEncrypt(data, new List<string>(new string[] { "CUSTNAME", "CUSTPHONE", "CUSTADDR", "PAPERNO" }));

            Object[] row = data.Rows[0].ItemArray;

            txtCustName.Text = ASHelper.getCellValue(row[0]);
            txtCustBirth.Text = ASHelper.getCellValue(row[1]);
            string paperType = (ASHelper.getCellValue(row[2])).Trim();
            selPaperType.Text = "";
            txtPaperNo.Text = ASHelper.getCellValue(row[3]);
            string sex = (ASHelper.getCellValue(row[4])).Trim();
            selCustSex.Text = sex == "0" ? "男" : sex == "1" ? "女" : "";
            txtCustPhone.Text = ASHelper.getCellValue(row[5]);
            txtCustPost.Text = ASHelper.getCellValue(row[6]);
            txtCustAddr.Text = ASHelper.getCellValue(row[7]);
            txtRemark.Text = ASHelper.getCellValue(row[8]);
            txtCustEmail.Text = ASHelper.getCellValue(row[9]);

            data = ASHelper.callQuery(context, "ReadPaperName", paperType);
            if (data.Rows.Count > 0)
            {
                 selPaperType.Text = (string)data.Rows[0].ItemArray[0];
            }
        }

        protected void clearCustInfo(params WebControl[] vars)
        {
            foreach (WebControl var in vars)
            {
                if (var is TextBox)
                {
                    ((TextBox)var).Text = "";
                }
                else if (var is DropDownList)
                {
                    ((DropDownList)var).SelectedValue = "";
                }
                else if (var is Label)
                {
                    ((Label)var).Text = "";
                }
            }
        }

        protected void readCustInfo(string cardNo,
            TextBox txtCustName, TextBox txtCustBirth,
            DropDownList selPaperType, TextBox txtPaperNo,
            DropDownList selCustSex, TextBox txtCustPhone,
            TextBox txtCustPost, TextBox txtCustAddr, TextBox txtEmail, TextBox txtRemark)
        {
            DataTable data = ASHelper.callQuery(context, "QueryCustInfo", cardNo);

            if (data.Rows.Count == 0)
            {
                context.AddError("A00501A002: 无法读取卡片客户资料");
                return;
            }

            //add by jiangbb 解密
            CommonHelper.AESDeEncrypt(data, new List<string>(new string[] { "CUSTNAME", "CUSTPHONE", "CUSTADDR","PAPERNO" }));

            Object[] row = data.Rows[0].ItemArray;

            txtCustName.Text = ASHelper.getCellValue(row[0]);
            txtCustBirth.Text = ASHelper.getCellValue(row[1]);
            selPaperType.SelectedValue = (ASHelper.getCellValue(row[2])).Trim();
            txtPaperNo.Text = ASHelper.getCellValue(row[3]);
            string sex = (ASHelper.getCellValue(row[4])).Trim();
            selCustSex.SelectedValue = (sex == "0" ? "0" : sex == "1" ? "1" : "");
            txtCustPhone.Text = ASHelper.getCellValue(row[5]);
            txtCustPost.Text = ASHelper.getCellValue(row[6]);
            txtCustAddr.Text = ASHelper.getCellValue(row[7]);
            txtRemark.Text = ASHelper.getCellValue(row[8]);
            txtEmail.Text = ASHelper.getCellValue(row[9]);
        }


        protected void readCardType(string cardNo, Label labCardType)
        {
            DataTable data = ASHelper.callQuery(context,
                "ReadCardTypeByCardNo", cardNo);

            if (data == null || data.Rows.Count == 0)
            {
                context.AddError("未在用户卡库存表中查询出卡片信息或者卡片类型没有配置");
                return;
            }

            labCardType.Text = "" + data.Rows[0].ItemArray[1];
        }

        protected decimal initFeeList(GridView gv, string tradeTypeCode)
        {
            return initFeeList(gv, tradeTypeCode, 8);
        }
        protected decimal initFeeList(GridView gv, string tradeTypeCode, int lines)
        {
            // 初始化费用列表
            DataTable data = ASHelper.callQuery(context, "ReadFeeItems", tradeTypeCode);

            DataTable dt = new DataTable();
            dt.Columns.Add("FEETYPENAME", typeof(string));
            dt.Columns.Add("BASEFEE", typeof(string));
            Object[] row = null;
            decimal total = 0;

            int i = 0;
            for (; i < data.Rows.Count; ++i)
            {
                row = data.Rows[i].ItemArray;
                total += (decimal)row[1];
                dt.Rows.Add((string)row[2], ((decimal)row[1]).ToString("n"));
            }

            for (; i < lines; ++i)
            {
                dt.Rows.Add("", "");
            }

            dt.Rows.Add("合计应收", total.ToString("n"));

            gv.DataSource = dt;
            gv.DataBind();

            return total;
        }

        protected void checkAccountInfo(string cardNo)
        {
            SP_AccCheckPDO pdo = new SP_AccCheckPDO();
            pdo.CARDNO = cardNo;
            TMStorePModule.Excute(context, pdo);
        }

        protected void checkCashGiftAccountInfo(string cardNo)
        {
            SP_CashGiftAccCheckPDO pdo = new SP_CashGiftAccCheckPDO();
            pdo.CARDNO = cardNo;
            TMStorePModule.Excute(context, pdo);
        }


        protected void checkCardState(string cardNo)
        {
            TMTableModule tmTMTableModule = new TMTableModule();

            //从用户卡库存表中读取数据
            TL_R_ICUSERTDO ddoTL_R_ICUSERIn = new TL_R_ICUSERTDO();
            ddoTL_R_ICUSERIn.CARDNO = cardNo;

            TL_R_ICUSERTDO ddoTL_R_ICUSEROut = (TL_R_ICUSERTDO)tmTMTableModule.selByPK(context, ddoTL_R_ICUSERIn, typeof(TL_R_ICUSERTDO), null, "TL_R_ICUSER", null);
            if (ddoTL_R_ICUSEROut == null)
            {
                context.AddError("A001001101");
                return;
            }
            //卡所属部门不是当前操作员所属部门


            if (ddoTL_R_ICUSEROut.ASSIGNEDDEPARTID != context.s_DepartID)
                context.AddError("A001004133");

            else if (ddoTL_R_ICUSEROut.ASSIGNEDSTAFFNO != context.s_UserID)
            {
                //卡库存状态不是出库或分配状态


                if (ddoTL_R_ICUSEROut.RESSTATECODE == "01" || ddoTL_R_ICUSEROut.RESSTATECODE == "05")
                {
                    TD_M_ROLEPOWERTDO ddoTD_M_ROLEPOWERIn = new TD_M_ROLEPOWERTDO();
                    string strSale = " Select POWERCODE From TD_M_ROLEPOWER Where POWERCODE = '201001' And POWERTYPE = '2' And ROLENO IN ( SELECT ROLENO From TD_M_INSIDESTAFFROLE Where STAFFNO ='" + context.s_UserID + "')";
                    DataTable dataSale = tmTMTableModule.selByPKDataTable(context, ddoTD_M_ROLEPOWERIn, null, strSale, 0);

                    if (dataSale.Rows.Count == 0)
                        context.AddError("A001001138");
                }
                else context.AddError("A001004132");
            }
            //卡所属员工为当前操作员工
            else if (ddoTL_R_ICUSEROut.ASSIGNEDSTAFFNO == context.s_UserID)
            {
                //卡库存状态不是分配状态


                if (ddoTL_R_ICUSEROut.RESSTATECODE != "01")
                {
                    if (ddoTL_R_ICUSEROut.RESSTATECODE != "05")
                        context.AddError("A001004132");
                }
            }
        }
    }
}
