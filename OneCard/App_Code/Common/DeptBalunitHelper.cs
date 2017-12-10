using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using System.Data;
using System.Web;
using Master;
using TDO.UserManager;
using TM;
using TDO.PartnerShip;

/// <summary>
///DeptBalunitHelper 的摘要说明

/// </summary>
public class DeptBalunitHelper
{

    /// <summary>
    /// 验证代理营业厅预付款余额
    /// </summary>
    /// <param name="context"></param>
    /// <returns></returns>
    public static bool ValdatePrepay(CmnContext context)
    {
        return ValdatePrepay(context, 0, "0");
    }
    /// <summary>
    /// 验证代理营业厅预付款余额
    /// </summary>
    /// <param name="context"></param>
    /// <param name="opMoney">操作金额</param>
    /// <param name="opType">验证类型：0全部验证，1只验证预警额度，2只验证最低额度</param>
    /// <returns></returns>
    public static bool ValdatePrepay(CmnContext context, int opMoney, string opType)
    {
        context.DBOpen("Select");
        context.AddField("DEPARTNO").Value = context.s_DepartID;
        string sql = @"SELECT A.DEPTTYPE,A.DBALUNITNO 
                        FROM TF_DEPT_BALUNIT A,TD_DEPTBAL_RELATION B 
                        WHERE  B.DBALUNITNO = A.DBALUNITNO 
                        AND A.USETAG = '1' AND B.USETAG = '1'  AND DEPTTYPE='1'
                        AND B.DEPARTNO = :DEPARTNO";
        DataTable table = context.ExecuteReader(sql);//用于判断是否是代理营业厅

        if (table.Rows.Count == 1)
        {
            TMTableModule tmTMTableModule = new TMTableModule();

            string dbalunitNo = table.Rows[0]["DBALUNITNO"].ToString();

            TF_F_DEPTBAL_PREPAYTDO tdoTF_F_DEPTBAL_PREPAYIn = new TF_F_DEPTBAL_PREPAYTDO();
            tdoTF_F_DEPTBAL_PREPAYIn.DBALUNITNO = dbalunitNo;
            TF_F_DEPTBAL_PREPAYTDO tdoTF_F_DEPTBAL_PREPAYOut = (TF_F_DEPTBAL_PREPAYTDO)tmTMTableModule.selByPK(context, tdoTF_F_DEPTBAL_PREPAYIn, typeof(TF_F_DEPTBAL_PREPAYTDO), null, "TF_F_DEPTBAL_PREPAY", null);
            if (tdoTF_F_DEPTBAL_PREPAYOut == null)
            {
                context.AddError("A001009900:预付款账户不存在");
                return false;
            }
            if (tdoTF_F_DEPTBAL_PREPAYOut.ACCSTATECODE.Equals("02"))//01有效，02无效
            {
                context.AddError("A001009901:预付款账户状态为无效");
                return false;
            }
            if (opType.Equals("0")) //读卡时验证最低额度和预警额度
            {
                //验证最低额度

                if (!ValidLimitLine(dbalunitNo, tdoTF_F_DEPTBAL_PREPAYOut, tmTMTableModule, opMoney, context))
                {
                    context.AddError("预付款余额: " + (tdoTF_F_DEPTBAL_PREPAYOut.PREPAY / 100.0).ToString("n") + "元");
                    return false;
                }
                //验证报警额度
                ValidWarnLine(dbalunitNo, tdoTF_F_DEPTBAL_PREPAYOut, tmTMTableModule, opMoney, context);
            }
            else if (opType.Equals("2"))  //验证最低额度
            {
                //验证最低额度
                if (!ValidLimitLine(dbalunitNo, tdoTF_F_DEPTBAL_PREPAYOut, tmTMTableModule, opMoney, context))
                {
                    //显示预付款余额
                    context.AddError("预付款余额: " + (tdoTF_F_DEPTBAL_PREPAYOut.PREPAY / 100.0).ToString("n") + "元");
                    return false;
                }
                else
                {
                    context.AddMessage("预付款余额: " + (tdoTF_F_DEPTBAL_PREPAYOut.PREPAY / 100.0).ToString("n") + "元");
                }
            }
            else if (opType.Equals("1")) //验证预警额度
            {
                //预警额度
                ValidWarnLine(dbalunitNo, tdoTF_F_DEPTBAL_PREPAYOut, tmTMTableModule, opMoney, context);
                context.AddMessage("预付款余额: " + (tdoTF_F_DEPTBAL_PREPAYOut.PREPAY / 100.0).ToString("n") + "元");
            }
        }
        return true;
    }
    //验证最低额度
    static private bool ValidLimitLine(string dbalunitNo, TF_F_DEPTBAL_PREPAYTDO tdoTF_F_DEPTBAL_PREPAYOut, TMTableModule tmTMTableModule, int opMoney, CmnContext context)
    {
        //最低额度
        TF_DEPT_BALUNITTDO ddoTF_DEPT_BALUNITIn = new TF_DEPT_BALUNITTDO();
        ddoTF_DEPT_BALUNITIn.DBALUNITNO = dbalunitNo;
        TF_DEPT_BALUNITTDO ddoTF_DEPT_BALUNITOut = (TF_DEPT_BALUNITTDO)tmTMTableModule.selByPK(context, ddoTF_DEPT_BALUNITIn, typeof(TF_DEPT_BALUNITTDO), null, "TF_DEPT_BALUNIT", null);

        if (ddoTF_DEPT_BALUNITOut != null)
        {
            int limitLine = Convert.ToInt32(ddoTF_DEPT_BALUNITOut.PREPAYLIMITLINE);
            if (tdoTF_F_DEPTBAL_PREPAYOut.PREPAY - opMoney < limitLine)
            {
                context.AddError("A001009902:预付款余额不足");
                return false;
            }
        }
        return true;
    }
    //验证预警额度
    static private void ValidWarnLine(string dbalunitNo, TF_F_DEPTBAL_PREPAYTDO tdoTF_F_DEPTBAL_PREPAYOut, TMTableModule tmTMTableModule, int opMoney, CmnContext context)
    {
        TF_DEPT_BALUNITTDO ddoTF_DEPT_BALUNITIn = new TF_DEPT_BALUNITTDO();
        ddoTF_DEPT_BALUNITIn.DBALUNITNO = dbalunitNo;
        TF_DEPT_BALUNITTDO ddoTF_DEPT_BALUNITOut = (TF_DEPT_BALUNITTDO)tmTMTableModule.selByPK(context, ddoTF_DEPT_BALUNITIn, typeof(TF_DEPT_BALUNITTDO), null, "TF_DEPT_BALUNIT", null);
        if (ddoTF_DEPT_BALUNITOut != null)
        {
            int warnLine = Convert.ToInt32(ddoTF_DEPT_BALUNITOut.PREPAYWARNLINE);
            if (tdoTF_F_DEPTBAL_PREPAYOut.PREPAY < warnLine)
            {
                context.AddMessage("A001009902:预付款余额已经不足" + (warnLine / 100).ToString("n") + "元，请尽快充值");
            }
        }
    }

    /// <summary>
    /// 初始化营业厅
    /// </summary>
    /// <param name="context"></param>
    /// <param name="selBalUnit">网点结算单元下拉框</param>
    /// <param name="txtBalUnit">网点结算单元查询文本框</param>
    public static void InitDBalUnit(Master.CmnContext context,
        System.Web.UI.WebControls.DropDownList selBalUnit,
        System.Web.UI.WebControls.TextBox txtBalUnit)
    {
        //查询网点类型和结算单元编码
        context.DBOpen("Select");
        context.AddField("DEPARTNO").Value = context.s_DepartID;
        string sql = @"SELECT A.DEPTTYPE,A.DBALUNITNO 
                        FROM TF_DEPT_BALUNIT A,TD_DEPTBAL_RELATION B 
                        WHERE  B.DBALUNITNO = A.DBALUNITNO 
                        AND A.USETAG = '1' AND B.USETAG = '1' 
                        AND B.DEPARTNO = :DEPARTNO";
        DataTable table = context.ExecuteReader(sql);
        if (table != null && table.Rows.Count > 0)
        {//如果是当前用户是代理营业厅用户，无论单元类型是自营还是代理，则都只能显示当前的结算单元
            string dbalUnitNo = table.Rows[0]["DBALUNITNO"].ToString(); 

            context.DBOpen("Select");
            context.AddField("DBALUNITNO").Value = dbalUnitNo;
            sql = @"SELECT DBALUNIT, DBALUNITNO  FROM   TF_DEPT_BALUNIT WHERE  USETAG = '1' AND DBALUNITNO = :DBALUNITNO
                            UNION SELECT DBALUNIT || '(无效)' DBALUNIT, DBALUNITNO  FROM   TF_DEPT_BALUNIT WHERE  USETAG = '0' AND DBALUNITNO = :DBALUNITNO  																												
                            ORDER BY DBALUNITNO";
            table = context.ExecuteReader(sql);
            GroupCardHelper.fill(selBalUnit, table, false);

            txtBalUnit.Visible = false;
        }
        else
        {
            context.DBOpen("Select");
            if (txtBalUnit.Text.Trim().Length > 0)
            {
                string strBalname = txtBalUnit.Text.Trim().Replace('\'', '\"');
                sql = @"SELECT DBALUNIT, DBALUNITNO	FROM TF_DEPT_BALUNIT WHERE  USETAG = '1' AND DBALUNIT LIKE '%" 
                    + strBalname + "%' UNION SELECT DBALUNIT || '(无效)' DBALUNIT, DBALUNITNO FROM TF_DEPT_BALUNIT WHERE  USETAG = '0' AND DBALUNIT LIKE '%" 
                    + strBalname + "%' ORDER BY DBALUNITNO";
            }
            else
            {
                sql = @"SELECT DBALUNIT, DBALUNITNO	FROM TF_DEPT_BALUNIT WHERE  USETAG = '1' 
                    UNION
                    SELECT DBALUNIT || '(无效)' DBALUNIT, DBALUNITNO FROM TF_DEPT_BALUNIT WHERE  USETAG = '0' 
                    ORDER BY DBALUNITNO";
            }
            table = context.ExecuteReader(sql);
            GroupCardHelper.fill(selBalUnit, table, true);
        }
    }

    /// <summary>
    /// 获取当前用户的代理网点结算单元编码 
    /// </summary>
    /// <param name="context"></param>
    /// <returns></returns>
    public static string GetDbalunitNo(Master.CmnContext context)
    {
        string dBalunitNo = "";

        context.DBOpen("Select");
        string sql = @"SELECT A.DEPTTYPE,A.DBALUNITNO 
                        FROM TF_DEPT_BALUNIT A,TD_DEPTBAL_RELATION B 
                        WHERE  B.DBALUNITNO = A.DBALUNITNO 
                        AND A.USETAG = '1' AND B.USETAG = '1'  AND DEPTTYPE='1'
                        AND B.DEPARTNO = '" + context.s_DepartID + "'";
        DataTable table = context.ExecuteReader(sql);

        if (table != null && table.Rows.Count > 0)
        {
            dBalunitNo = table.Rows[0]["DBALUNITNO"].ToString(); //结算单元编码
        }

        return dBalunitNo;
    }

    /// <summary>
    /// 计算代理营业厅对应网点结算单元编码的可领卡价值额度和网点剩余卡价值

    /// </summary>
    /// <param name="context"></param>
    /// <returns></returns>
    public static void SetDeposit(Master.CmnContext context, string dBalunitNo, Label labDeposit, Label labUusablevalue, Label labStockvalue)
    {
        //查询结算单元卡数量

        context.DBOpen("Select");
        string sql1 = @"select count(*) NUM
                        from TL_R_ICUSER a
                        where exists (select * from  TD_DEPTBAL_RELATION b 
                                      where a.assigneddepartid=b.departno 
                                      and b.dbalunitno='" + dBalunitNo + "')";
        sql1 += " and a.RESSTATECODE IN('01','05') ";
        DataTable table1 = context.ExecuteReader(sql1);
        //查询单张卡价值

        context.DBOpen("Select");
        string sql2 = @"SELECT TAGVALUE FROM td_m_tag WHERE TAGCODE = 'USERCARD_MONEY'";
        DataTable table2 = context.ExecuteReader(sql2);

        
        //查询网点的读卡器价值额度 add by youyue 20130926
        context.DBOpen("Select");
        string sql3 = @"select count(*) NUM
                        from TL_R_READER a
                        where exists (select * from  TD_DEPTBAL_RELATION b 
                                      where a.assigneddepartid=b.departno 
                                      and b.dbalunitno='" + dBalunitNo + "')";
        sql3 += " and a.READERSTATE IN('1') ";//出库状态
        DataTable table3 = context.ExecuteReader(sql3);
        //查询读卡器价值
        context.DBOpen("Select");
        string sql4 = @"SELECT TAGVALUE FROM td_m_tag WHERE TAGCODE = 'READER_PRICE '";
        DataTable table4 = context.ExecuteReader(sql4);

        //查询库里手环卡数量  add by youyue20160606
        context.DBOpen("Select");
        sql1 += "and a.cardsurfacecode='2002'";
        DataTable table5 = context.ExecuteReader(sql1);
        if (table1 != null && table1.Rows.Count > 0)
        {
            double deposit = Convert.ToDouble(labDeposit.Text.Trim());
            int cardnum = Convert.ToInt32(table1.Rows[0]["NUM"].ToString());//库里卡总数量(手环加普通卡)
            int cardnum2 = Convert.ToInt32(table5.Rows[0]["NUM"].ToString());//库里手环卡数量
            int cardnum1 = cardnum - cardnum2;//普通卡数量
            double cardmoney = Convert.ToDouble(table2.Rows[0]["TAGVALUE"].ToString()) / 100.0;
            double cardshmoney = 358.00;//单张手环卡价值

            int readernum = Convert.ToInt32(table3.Rows[0]["NUM"].ToString());
            double readermoney = Convert.ToDouble(table4.Rows[0]["TAGVALUE"].ToString()) / 100.0;

            //计算可领卡价值额度，网点剩余卡价值


            double stockvalue = cardnum2 * cardshmoney + cardnum1 * cardmoney + readernum * readermoney;///网点手环卡价值加上普通卡价值加上读卡器的价值额度
            double usablevalue = deposit - stockvalue;
            labUusablevalue.Text = usablevalue.ToString("n");
            labStockvalue.Text = stockvalue.ToString("n");
        }

    }
}
