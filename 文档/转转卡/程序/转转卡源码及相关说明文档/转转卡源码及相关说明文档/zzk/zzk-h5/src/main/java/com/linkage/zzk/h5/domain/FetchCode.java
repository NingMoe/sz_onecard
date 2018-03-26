package com.linkage.zzk.h5.domain;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.io.Serializable;

/**
 * @author: John
 */
@Data
@AllArgsConstructor
public class FetchCode implements Serializable {

    private String custName;

    private String fetchCode;

}
