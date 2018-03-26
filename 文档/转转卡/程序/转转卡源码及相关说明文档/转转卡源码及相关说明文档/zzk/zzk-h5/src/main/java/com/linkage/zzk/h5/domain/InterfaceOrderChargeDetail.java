package com.linkage.zzk.h5.domain;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.io.Serializable;

/**
 * 订单兑换券详情
 *
 * @author: John
 */
@Data
public class InterfaceOrderChargeDetail implements Serializable {

    @JsonProperty("detailNo")
    private String detailNo;

    @JsonProperty("orderNo")
    private String orderNo;

    @JsonProperty("orderState")
    private String orderState;

    @JsonProperty("packageName")
    private String packageName;

    @JsonProperty("funcFee")
    private String funcFee;

    @JsonProperty("paymentState")
    private String paymentState;

}
