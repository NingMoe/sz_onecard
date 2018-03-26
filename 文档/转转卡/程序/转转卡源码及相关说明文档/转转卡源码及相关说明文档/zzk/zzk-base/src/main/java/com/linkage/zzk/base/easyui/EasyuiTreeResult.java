package com.linkage.zzk.base.easyui;

import lombok.Data;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/**
 * @author: John
 */
@Data
public class EasyuiTreeResult implements Serializable {

    private Long id;

    private String text;

    private Long parentId;

    private List<EasyuiTreeResult> children = new ArrayList<EasyuiTreeResult>();

}
