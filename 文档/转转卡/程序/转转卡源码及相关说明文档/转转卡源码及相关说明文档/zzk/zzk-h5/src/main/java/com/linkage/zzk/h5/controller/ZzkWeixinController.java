package com.linkage.zzk.h5.controller;

import com.linkage.zzk.base.session.CookieSession;
import com.linkage.zzk.base.util.HttpClientUtil;
import com.linkage.zzk.base.util.JsonUtil;
import com.linkage.zzk.base.util.RandomUtil;
import com.linkage.zzk.base.util.StringUtil;
import com.linkage.zzk.h5.common.conf.AppConfig;
import com.linkage.zzk.h5.common.service.InterfaceService;
import com.linkage.zzk.h5.common.weixin.AccessToken;
import com.linkage.zzk.h5.common.weixin.JSApiTicket;
import com.linkage.zzk.h5.common.weixin.UserAccessToken;
import com.linkage.zzk.h5.common.weixin.WXBizMsgCrypt;
import com.linkage.zzk.h5.domain.InterfaceUserIdQueryResult;
import com.linkage.zzk.h5.service.ZzkService;
import org.apache.commons.collections4.map.HashedMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.client.RestTemplate;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Map;

/**
 * 微信公众号
 *
 * @author: John
 */
@Controller
@RequestMapping("/zzk/wx")
public class ZzkWeixinController {

    private final Logger logger = LoggerFactory.getLogger(getClass());

    @Autowired
    private ZzkService zzkService;

    @Autowired
    private InterfaceService interfaceService;

    /**
     * 公众号入口
     *
     * @param request
     * @return
     */
    @RequestMapping(value = "/index")
    public String index(HttpServletRequest request, HttpServletResponse response) {

        //获取access_token，本地缓存
        AccessToken accessToken = AppConfig.accessToken;
        if (accessToken == null || accessToken.isExpires()) {
            String mpAccessToken = new HttpClientUtil().get(
                    AppConfig.WEIXIN_MP_TOKEN_URL
                            .replace("APPID", AppConfig.WEIXIN_MP_APPID)
                            .replace("APPSECRET", AppConfig.WEIXIN_MP_APPSECRET)
            );
            logger.info(mpAccessToken);
            if (StringUtil.isNotBlank(mpAccessToken)) {
                accessToken = JsonUtil.fromJson(mpAccessToken, AccessToken.class);
                if (accessToken != null) {
                    accessToken.setCreateTime(System.currentTimeMillis());
                    AppConfig.accessToken = accessToken;
                }
            }
        }

        //获取jsapi_ticket，本地缓存
        JSApiTicket apiTicket = AppConfig.apiTicket;
        if (accessToken != null && !accessToken.isExpires() && (apiTicket == null || apiTicket.isExpires())) {
            String jsApiTicket = new HttpClientUtil().get(
                    AppConfig.WEIXIN_MP_GETTICKET_URL.replace("ACCESS_TOKEN", accessToken.getAccessToken())
            );
            logger.info(jsApiTicket);
            apiTicket = JsonUtil.fromJson(jsApiTicket, JSApiTicket.class);
            if (apiTicket != null) {
                apiTicket.setCreateTime(System.currentTimeMillis());
                AppConfig.apiTicket = apiTicket;
            }
        }

        //获取OAuth2授权code
        String code = request.getParameter("code");
        if (StringUtil.isBlank(code)) {
            try {
                String authorizeUrl = AppConfig.WEIXIN_MP_OAUTH2_URL
                        .replace("APPID", AppConfig.WEIXIN_MP_APPID)
                        .replace("REDIRECT_URI", AppConfig.DOMAIN_URL2 + "/zzk/wx/index")
                        .replace("SCOPE", "snsapi_base")
                        .replace("STATE", RandomUtil.randomChars(8));
                logger.info(authorizeUrl);
                return "redirect:" + authorizeUrl;
            } catch (Exception e) {
                logger.error("编码异常", e);
            }
        }

        //获取OAuth2用户授权access_token、openid等
        String accessTokenResponse = new HttpClientUtil().post(AppConfig.WEIXIN_MP_ACCESSTOKEN_URL
                .replace("APPID", AppConfig.WEIXIN_MP_APPID)
                .replace("SECRET", AppConfig.WEIXIN_MP_APPSECRET)
                .replace("CODE", code), new HashMap<String, Object>());
        logger.info(accessTokenResponse);
        UserAccessToken userAccessToken = JsonUtil.fromJson(accessTokenResponse, UserAccessToken.class);

        //根据openId调用接口获取userId
        if (StringUtil.isNotBlank(userAccessToken.getOpenId())) {
            logger.info("openId=" + userAccessToken.getOpenId());
            CookieSession cookieSession = new CookieSession(request, AppConfig.SESSION_KEY);
            cookieSession.put("openId", userAccessToken.getOpenId());
            cookieSession.flush(response);

            Map<String, Object> params = new HashMap<>();
            params.put("openid", userAccessToken.getOpenId());
            InterfaceUserIdQueryResult interfaceUserIdQueryResult = interfaceService.openIdQuery(params);
            if (interfaceUserIdQueryResult != null && "0000".equals(interfaceUserIdQueryResult.getRespCode())) {
                String userId = interfaceUserIdQueryResult.getUserId();
                if (StringUtil.isNotBlank(userId)) {
                    cookieSession.put("userId", userId);
                    cookieSession.flush(response);
                    return "redirect:" + AppConfig.DOMAIN_URL2 + "/zzk/index";
                }
            }
        }
        return "redirect:" + AppConfig.WEIXIN_MP_SMKLOGIN_URL.replace("BACKURL", AppConfig.DOMAIN_URL2 + "/zzk/wx/login/callback");
    }

    /**
     * 市民卡登录回调
     *
     * @param request
     * @return
     */
    @RequestMapping(value = "/login/callback")
    public String loginCallback(HttpServletRequest request, HttpServletResponse response) {
        String uasuuid = request.getParameter("userId");
        logger.info("市民卡登录回调：uas_uuid=" + uasuuid);
        if (StringUtil.isNotBlank(uasuuid)) {

            CookieSession cookieSession = new CookieSession(request, AppConfig.SESSION_KEY);
            String openId = cookieSession.get("openId");

            //查询用户信息
            Map<String, Object> params = new HashedMap<>();
            params.put("openid", openId);
            params.put("uas_uuid", uasuuid);
            InterfaceUserIdQueryResult interfaceUserIdQueryResult = interfaceService.userInfoQuery(params);
            if (interfaceUserIdQueryResult != null && "0000".equals(interfaceUserIdQueryResult.getRespCode())) {
                String userId = interfaceUserIdQueryResult.getUserId();
                logger.info("接口返回用户信息：userId=" + userId);
                if (StringUtil.isNotBlank(userId)) {
                    cookieSession.put("userId", userId);
                    cookieSession.flush(response);
                    return "redirect:" + AppConfig.DOMAIN_URL2 + "/zzk/index";
                }
            }
        }
        return null;
    }

//    /**
//     * 公众号菜单入口，暂不用
//     *
//     * @param request
//     * @return
//     */
//    @RequestMapping(value = "/menu")
//    public String menu(HttpServletRequest request, HttpServletResponse response) {
//
//        String code = request.getParameter("code");
//        String menuId = request.getParameter("menuId");
//
//        //获取code
//        if (StringUtil.isBlank(code)) {
//            try {
//                String authorizeUrl = AppConfig.WEIXIN_MP_OAUTH2_URL
//                        .replace("APPID", AppConfig.WEIXIN_MP_APPID)
//                        .replace("REDIRECT_URI", URLEncoder.encode(AppConfig.DOMAIN_URL + "/zzk/wx/menu?menuId=" + menuId, "UTF-8"))
//                        .replace("SCOPE", "snsapi_base")
//                        .replace("STATE", RandomUtil.randomChars(8));
//                return "redirect:" + authorizeUrl;
//            } catch (UnsupportedEncodingException e) {
//                logger.error("编码异常", e);
//            }
//        }
//
//        //获取用户accessToken
//        UserAccessToken userAccessToken = new RestTemplate().getForObject(AppConfig.WEIXIN_MP_ACCESSTOKEN_URL
//                        .replace("APPID", AppConfig.WEIXIN_MP_APPID)
//                        .replace("SECRET", AppConfig.WEIXIN_MP_APPSECRET)
//                        .replace("CODE", code),
//                UserAccessToken.class);
//
//        //根据openId调用接口获取userId
//        if (StringUtil.isNotBlank(userAccessToken.getOpenId())) {
//            String userId = "1"; //TODO 查询接口
//            CookieSession cookieSession = new CookieSession(request, AppConfig.SESSION_KEY);
//            cookieSession.put("openId", userAccessToken.getOpenId());
//            cookieSession.put("userId", userId);
//            cookieSession.flush(response);
//            if (StringUtil.isNotBlank(userId)) {
//                return "redirect:/zzk/index"; //根据menuId获取菜单地址，转转卡暂时只有一个入口菜单，此处直接跳首页
//            }
//
//            String redirectUrl = null; //TODO 菜单对应地址
//            try {
//                if (StringUtil.isNotBlank(redirectUrl)) {
//                    redirectUrl = URLEncoder.encode("", "UTF-8");
//                }
//            } catch (UnsupportedEncodingException e) {
//                logger.error("编码异常", e);
//            }
//            return "redirect:/zzk/login?redirectUrl=" + redirectUrl;
//        }
//
//        //其它异常
//        return null;
//    }
//
//    /**
//     * 微信公众平台接入时，微信主动调用，此接口验证通过后接入成功，才能进行后续接口调用
//     *
//     * @param request
//     * @param response
//     * @return
//     */
//    @RequestMapping("/verifyurl")
//    public @ResponseBody String verifyURL(HttpServletRequest request, HttpServletResponse response) {
//
//        String signature = request.getParameter("signature");
//        String timestamp = request.getParameter("timestamp");
//        String nonce = request.getParameter("nonce");
//        String echostr = request.getParameter("echostr");
//
//        try {
//            return new WXBizMsgCrypt(AppConfig.WEIXIN_MP_TOKEN, AppConfig.WEIXIN_MP_AESKEY, AppConfig.WEIXIN_MP_APPID)
//                    .VerifyURL(signature, timestamp, nonce, echostr);
//        } catch (Exception e) {
//            logger.error("微信公众号接入异常", e);
//        }
//        return null;
//    }

}
