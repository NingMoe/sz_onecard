package com.linkage.zzk.base.easyui;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.AllArgsConstructor;
import lombok.Data;

import java.util.List;

/**
 * @author: John
 */
@Data
@AllArgsConstructor
public class EasyuiDataGridResult<T> {

    private int total;

    private List<T> rows;

    public String toJson() {
        try {
            return new ObjectMapper().writeValueAsString(this);
        } catch (JsonProcessingException e) {
            e.printStackTrace();
            return null;
        }
    }

}
