package com.linkage.zzk.h5.common.utils;

import com.linkage.zzk.base.util.RandomUtil;

import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * 订单号生成
 *
 * @author: John
 */
public class OrderNoUtil {

    private static final String ORDER_PRE = "ORD";
    private static final String CARD_ORDER_PRE = "CRD";
    private static final String DHJ_ORDER_PRE = "DHQ";

    private static final String FORMAT = "yyyyMMddHHmmss";

    /**
     * 22位订单号
     *
     * @return
     */
    public static String getOrderNo() {
        return ORDER_PRE + new SimpleDateFormat(FORMAT).format(new Date()) + RandomUtil.random(5);
    }

    /**
     * 22位卡子订单号
     *
     * @return
     */
    public static String getCardOrderNo() {
        return CARD_ORDER_PRE + new SimpleDateFormat(FORMAT).format(new Date()) + RandomUtil.random(5);
    }

    /**
     * 22位兑换券子订单号
     *
     * @return
     */
    public static String getDHJOrderNo() {
        return DHJ_ORDER_PRE + new SimpleDateFormat(FORMAT).format(new Date()) + RandomUtil.random(5);
    }

}
