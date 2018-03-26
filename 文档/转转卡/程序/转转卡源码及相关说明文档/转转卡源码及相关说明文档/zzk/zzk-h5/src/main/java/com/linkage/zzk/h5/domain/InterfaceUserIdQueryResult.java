package com.linkage.zzk.h5.domain;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

/**
 * 用户信息查询结果
 *
 * @author: John
 */
@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class InterfaceUserIdQueryResult extends InterfaceResult {

    @JsonProperty("userid")
    private String userId;

}
