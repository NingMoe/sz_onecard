package com.linkage.zzk.h5.common.service.impl;

import com.linkage.zzk.base.util.DigestUtil;
import com.linkage.zzk.base.util.HttpClientUtil;
import com.linkage.zzk.base.util.JsonUtil;
import com.linkage.zzk.base.util.StringUtil;
import com.linkage.zzk.h5.common.service.InterfaceService;
import com.linkage.zzk.h5.common.conf.AppConfig;
import com.linkage.zzk.h5.domain.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;

/**
 * 接口服务实现
 *
 * @author: John
 */
@Service
public class InterfaceServiceImpl implements InterfaceService {

    private final Logger logger = LoggerFactory.getLogger(getClass());

    HttpClientUtil httpClient = new HttpClientUtil();

    /**
     * 订单开通
     *
     * @return
     */
    @Override
    public InterfaceOrderOpenResult orderOpening(Map<String, Object> params) {
        return JsonUtil.fromJson(
                httpClient.post(AppConfig.INTERFACE_ORDEROPENING, appendSign(params)),
                InterfaceOrderOpenResult.class
        );
    }

    /**
     * 订单支付确认
     *
     * @param params
     * @return
     */
    @Override
    public InterfaceResult orderPaymentConfirm(Map<String, Object> params) {
        return JsonUtil.fromJson(
                httpClient.post(AppConfig.INTERFACE_ORDERPAYMENTCONFIRM, appendSign(params)),
                InterfaceResult.class
        );
    }

    /**
     * 订单状态变更通知
     *
     * @param params
     * @return
     */
    @Override
    public InterfaceOrderStateChangeNoticeResult orderStateChangeNotice(Map<String, Object> params) {
        return JsonUtil.fromJson(
                httpClient.post(AppConfig.INTERFACE_ORDERSTATECHANGENOTICE, appendSign(params)),
                InterfaceOrderStateChangeNoticeResult.class
        );
    }

    /**
     * 订单查询
     *
     * @param params
     * @return
     */
    @Override
    public InterfaceOrderQueryResult orderQuery(Map<String, Object> params) {
        return JsonUtil.fromJson(
                new HttpClientUtil().post(AppConfig.INTERFACE_ORDERINQURY, appendSign(params)),
                InterfaceOrderQueryResult.class
        );
    }

    /**
     * 兑换码查询
     *
     * @param params
     * @return
     */
    @Override
    public InterfaceCodeQueryResult codeQuery(Map<String, Object> params) {
        return JsonUtil.fromJson(
                httpClient.post(AppConfig.INTERFACE_REDEEMCODEINQURY, appendSign(params)),
                InterfaceCodeQueryResult.class
        );
    }

    /**
     * 地址管理
     *
     * @param params
     * @return
     */
    @Override
    public InterfaceAddressManageResult addressManage(Map<String, Object> params) {
        return JsonUtil.fromJson(
                httpClient.post(AppConfig.INTERFACE_MANAGECUSTADRESSINFOR, appendSign(params)),
                InterfaceAddressManageResult.class
        );
    }

    /**
     * 用户信息查询
     *
     * @param params
     * @return
     */
    @Override
    public InterfaceUserIdQueryResult userInfoQuery(Map<String, Object> params) {
        return JsonUtil.fromJson(
                httpClient.post(AppConfig.INTERFACE_USERINFOQUERY, appendSign(params)),
                InterfaceUserIdQueryResult.class
        );
    }

    /**
     * 根据openId查询用户信息查询
     *
     * @param params
     * @return
     */
    @Override
    public InterfaceUserIdQueryResult openIdQuery(Map<String, Object> params) {
        return JsonUtil.fromJson(
                httpClient.post(AppConfig.INTERFACE_OPENIDQUERY, appendSign(params)),
                InterfaceUserIdQueryResult.class
        );
    }

    /**
     * 请求参数追加签名
     *
     * @param params
     * @return
     */
    private String appendSign(Map<String, Object> params) {
        //添加公共参数
        params.put("channelCode", AppConfig.INTERFACE_CHANNELCODE);

        //筛选需要参与签名的参数
        List<String> signParams = new ArrayList<>();
        for (String key : params.keySet()) {
            Object value = params.get(key);
            if (!"DETAILREQLIST".equalsIgnoreCase(key) && value != null && StringUtil.isNotBlank(value.toString())) {
                signParams.add((key + "=" + value).toUpperCase());
            }
        }

        //排序
        Collections.sort(signParams);

        //拼接参数，并追加密钥
        StringBuffer sb = new StringBuffer();
        for (int i = 0; i < signParams.size(); i++) {
            sb.append(i == 0 ? signParams.get(i) : "&" + signParams.get(i));
        }
        sb.append("&CHANNELKEY=" + AppConfig.INTERFACE_SIGNSECRET);

        logger.info("参与签名参数：" + sb.toString());

        //MD5加密
        String token = DigestUtil.md5(sb.toString()).toUpperCase();

        params.put("token", token);
        return JsonUtil.toJson(params);
    }

}
