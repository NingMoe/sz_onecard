package com.linkage.zzk.h5.common.conf;

import com.linkage.zzk.h5.common.weixin.AccessToken;
import com.linkage.zzk.h5.common.weixin.JSApiTicket;

import java.io.IOException;
import java.util.Properties;

/**
 * 应用配置属性文件支持
 *
 * @author: John
 */
public class AppConfig {

    private static Properties prop = new Properties();

    static {
        try {
            prop.load(AppConfig.class.getResourceAsStream("/config/conf-h5.properties"));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /**
     * session key
     */
    public static final String SESSION_KEY = "ZZK_SESSION";

    /**
     * 站点域名
     */
    public static final String DOMAIN_URL = prop.getProperty("domain.url");
    public static final String DOMAIN_URL2 = prop.getProperty("domain.url2");

    /**
     * Session超时时间
     */
    public static final long SESSION_TIMEOUT = Long.parseLong(prop.getProperty("session.timeout"));

    /**
     * 用户ID加密密钥
     */
    public static final String USER_SECRET = prop.getProperty("user.secret");

    /**
     * 文件存储路径
     */
    public static final String FILE_PATH = prop.getProperty("file.path");

    /**
     * 文件访问路径
     */
    public static final String FILE_URL = prop.getProperty("file.url");

    /**
     * 渠道ID
     */
    public static final String INTERFACE_CHANNELCODE = prop.getProperty("interface.channelcode");

    /**
     * 接口签名密钥
     */
    public static final String INTERFACE_SIGNSECRET = prop.getProperty("interface.signsecret");

    /**
     * 接口主机地址
     */
    public static final String INTERFACE_HOST = prop.getProperty("interface.host");

    /**
     * 订单开通
     */
    public static final String INTERFACE_ORDEROPENING = INTERFACE_HOST + prop.getProperty("interface.orderopening");

    /**
     * 订单支付确认
     */
    public static final String INTERFACE_ORDERPAYMENTCONFIRM = INTERFACE_HOST + prop.getProperty("interface.orderpaymentconfirm");

    /**
     * 订单状态变更
     */
    public static final String INTERFACE_ORDERSTATECHANGENOTICE = INTERFACE_HOST + prop.getProperty("interface.orderstatechangenotice");

    /**
     * 订单查询
     */
    public static final String INTERFACE_ORDERINQURY = INTERFACE_HOST + prop.getProperty("interface.orderinqury");

    /**
     * 兑换码查询
     */
    public static final String INTERFACE_REDEEMCODEINQURY = INTERFACE_HOST + prop.getProperty("interface.redeemcodeinqury");

    /**
     * 地址管理
     */
    public static final String INTERFACE_MANAGECUSTADRESSINFOR = INTERFACE_HOST + prop.getProperty("interface.managecustadressinfor");

    /**
     * 用户信息查询
     */
    public static final String INTERFACE_USERINFOQUERY = INTERFACE_HOST + prop.getProperty("interface.userIdQuery");

    /**
     * 用户信息查询
     */
    public static final String INTERFACE_OPENIDQUERY = INTERFACE_HOST + prop.getProperty("interface.openIdQuery");

    /**
     * 支付宝支付相关配置
     */
    public static final String ALIPAY_APPID = prop.getProperty("pay.alipay.app_id");
    public static final String ALIPAY_PRIVATE_KEY = prop.getProperty("pay.alipay.app_private_key");
    public static final String ALIPAY_PUBLIC_KEY = prop.getProperty("pay.alipay.alipay_public_key");
    public static final String ALIPAY_URL = prop.getProperty("pay.alipay.url");
    public static final String ALIPAY_ORDER_METHOD = prop.getProperty("pay.alipay.order_method");
    public static final String ALIPAY_ORDERQUERY_METHOD = prop.getProperty("pay.alipay.orderquery_method");
    public static final String ALIPAY_RETURN_URL = prop.getProperty("pay.alipay.return_url");
    public static final String ALIPAY_NOTIFY_URL = prop.getProperty("pay.alipay.notify_url");

    /**
     * 微信支付相关配置
     */
    public static final String TEN_APPID = prop.getProperty("pay.ten.appid");
    public static final String TEN_MCH_ID = prop.getProperty("pay.ten.mch_id");
    public static final String TEN_APIKEY = prop.getProperty("pay.ten.apikey");
    public static final String TEN_OUTIP = prop.getProperty("pay.ten.outip");
    public static final String TEN_WAPURL = prop.getProperty("pay.ten.wapurl");
    public static final String TEN_UNIFIEDORDER_URL = prop.getProperty("pay.ten.unifiedorder_url");
    public static final String TEN_ORDERQUERY_URL = prop.getProperty("pay.ten.orderquery_url");
    public static final String TEN_RETURN_URL = prop.getProperty("pay.ten.return_url");
    public static final String TEN_NOTIFY_URL = prop.getProperty("pay.ten.notify_url");

    /**
     * 微信公众号
     */
    public static AccessToken accessToken;
    public static JSApiTicket apiTicket;
    public static final String WEIXIN_MP_APPID = prop.getProperty("weixin.mp.appid");
    public static final String WEIXIN_MP_APPSECRET = prop.getProperty("weixin.mp.appsecret");
    public static final String WEIXIN_MP_TOKEN_URL = prop.getProperty("weixin.mp.token_url");
    public static final String WEIXIN_MP_GETTICKET_URL = prop.getProperty("weixin.mp.getticket_url");
    public static final String WEIXIN_MP_OAUTH2_URL = prop.getProperty("weixin.mp.oauth2_url");
    public static final String WEIXIN_MP_ACCESSTOKEN_URL = prop.getProperty("weixin.mp.accesstoken_url");
    public static final String WEIXIN_MP_SMKLOGIN_URL = prop.getProperty("weixin.mp.smklogin_url");
}
