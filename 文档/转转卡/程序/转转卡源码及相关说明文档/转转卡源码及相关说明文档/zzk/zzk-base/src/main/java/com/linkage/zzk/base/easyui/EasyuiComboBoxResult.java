package com.linkage.zzk.base.easyui;

import lombok.Data;

import java.io.Serializable;

/**
 * @author: John
 */
@Data
public class EasyuiComboBoxResult implements Serializable {

    private Long id;

    private String text;

    private boolean selected;

    private String desc;

}
