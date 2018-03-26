package com.linkage.zzk.h5.domain;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.util.List;


/**
 * 地址管理响应结果
 *
 * @author: John
 */
@Data
public class InterfaceAddressManageResult extends InterfaceResult {

    @JsonProperty("addressInforList")
    private List<InterfaceAddressDetail> addressList;

}
