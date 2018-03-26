package com.linkage.zzk.h5.domain;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

/**
 * 兑换码查询响应结果
 *
 * @author: John
 */
@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class InterfaceCodeQueryResult extends InterfaceResult {

    @JsonProperty("useTag")
    private String useTag;

    @JsonProperty("value")
    private String value;

    @JsonProperty("endDate")
    private String endDate;

    @JsonProperty("xfcCardNo")
    private String xfcCardNo;

}
