package com.linkage.zzk.h5.common.service;

import com.linkage.zzk.h5.domain.*;

import java.util.Map;

/**
 * 接口服务
 *
 * @author: John
 */
public interface InterfaceService {

    /**
     * 订单开通
     *
     * @param params
     * @return
     */
    InterfaceOrderOpenResult orderOpening(Map<String, Object> params);

    /**
     * 订单支付确认
     *
     * @param params
     * @return
     */
    InterfaceResult orderPaymentConfirm(Map<String, Object> params);

    /**
     * 订单状态变更通知
     *
     * @param params
     * @return
     */
    InterfaceOrderStateChangeNoticeResult orderStateChangeNotice(Map<String, Object> params);

    /**
     * 订单查询
     *
     * @param params
     * @return
     */
    InterfaceOrderQueryResult orderQuery(Map<String, Object> params);

    /**
     * 兑换码查询
     *
     * @param params
     * @return
     */
    InterfaceCodeQueryResult codeQuery(Map<String, Object> params);

    /**
     * 地址管理
     *
     * @param params
     * @return
     */
    InterfaceAddressManageResult addressManage(Map<String, Object> params);

    /**
     * 用户信息查询
     *
     * @param params
     * @return
     */
    InterfaceUserIdQueryResult userInfoQuery(Map<String, Object> params);

    /**
     * 根据openId查询用户信息查询
     *
     * @param params
     * @return
     */
    InterfaceUserIdQueryResult openIdQuery(Map<String, Object> params);

}
