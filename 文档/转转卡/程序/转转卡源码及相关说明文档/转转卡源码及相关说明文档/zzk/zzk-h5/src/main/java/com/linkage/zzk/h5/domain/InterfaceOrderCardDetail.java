package com.linkage.zzk.h5.domain;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.io.Serializable;

/**
 * 卡订单详情
 *
 * @author: John
 */
@Data
public class InterfaceOrderCardDetail implements Serializable {

    @JsonProperty("detailNo")
    private String detailNo;

    @JsonProperty("orderNo")
    private String orderNo;

    @JsonProperty("orderState")
    private String orderState;

    @JsonProperty("rejectType")
    private String rejectType;

    @JsonProperty("cardNo")
    private String cardNo;

    @JsonProperty("packageName")
    private String packageName;

    @JsonProperty("packageEndTime")
    private String packageEndTime;

    @JsonProperty("activeEndTime")
    private String activeEndTime;

    @JsonProperty("custName")
    private String custName;

    @JsonProperty("paperNo")
    private String paperNo;

    @JsonProperty("custPhone")
    private String custPhone;

    @JsonProperty("fetchCode")
    private String fetchCode;

    @JsonProperty("packageMoney")
    private String packageMoney;

    @JsonProperty("supplyMoney")
    private String supplyMoney;

    @JsonProperty("discountType")
    private String discountType;

    @JsonProperty("chargeNo")
    private String chargeNo;

    @JsonProperty("chargeNoPrice")
    private String chargeNoPrice;

}
