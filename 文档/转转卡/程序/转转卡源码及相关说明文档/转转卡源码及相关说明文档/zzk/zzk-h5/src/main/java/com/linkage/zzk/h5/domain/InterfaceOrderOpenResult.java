package com.linkage.zzk.h5.domain;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.util.List;

/**
 * 订单开通响应结果
 *
 * @author: John
 */
@Data
public class InterfaceOrderOpenResult extends InterfaceResult {

    @JsonProperty("orderTrade")
    private String orderTrade;

    @JsonProperty("orderDetail")
    private List<InterfaceOrderOpenDetail> orderDetailList;

}
