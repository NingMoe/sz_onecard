package com.linkage.zzk.h5.domain;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.util.List;

/**
 * 订单查询响应结果
 *
 * @author: John
 */
@Data
public class InterfaceOrderQueryResult extends InterfaceResult {

    @JsonProperty("orderList")
    private List<InterfaceOrderQueryDetail> orderList;

}
