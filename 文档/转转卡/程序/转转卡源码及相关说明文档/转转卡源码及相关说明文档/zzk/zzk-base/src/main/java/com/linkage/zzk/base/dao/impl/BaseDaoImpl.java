package com.linkage.zzk.base.dao.impl;

import com.linkage.zzk.base.dao.BaseDao;
import com.linkage.zzk.base.dao.BaseDaoException;
import com.linkage.zzk.base.dao.Pager;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.BatchPreparedStatementSetter;
import org.springframework.jdbc.core.CallableStatementCallback;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import javax.sql.DataSource;
import java.util.List;
import java.util.Map;

/**
 * DAO实现
 *
 * @author: John
 */
@Repository
public class BaseDaoImpl implements BaseDao {

    private final Logger log = LoggerFactory.getLogger(getClass());

    private String logPrefixError = "数据库操作异常:";

    public JdbcTemplate jdbcTemplate;

    public NamedParameterJdbcTemplate namedParameterJdbcTemplate;

    @Autowired
    public void setDataSource(DataSource dataSource) {
        this.jdbcTemplate = new JdbcTemplate(dataSource);
        this.namedParameterJdbcTemplate = new NamedParameterJdbcTemplate(dataSource);
    }

    /**
     * 更新数据
     *
     * @param sql
     * @return
     */
    @Override
    public int update(String sql) {
        int rows = 0;
        try {
            log.info(sql);
            rows = jdbcTemplate.update(sql);
        } catch (Exception e) {
            log.info(logPrefixError + e);
            throw new BaseDaoException(logPrefixError, e);
        }
        return rows;
    }

    /**
     * 更新数据
     *
     * @param sql
     * @param args
     * @return
     */
    @Override
    public int update(String sql, Object... args) {
        int rows = 0;
        try {
            log.info(sql.replaceAll("\\?", "{}"), args);
            log.info("\n");
            rows = jdbcTemplate.update(sql, args);
        } catch (Exception e) {
            log.info(logPrefixError + e);
            throw new BaseDaoException(logPrefixError, e);
        }
        return rows;
    }

    /**
     * 批量更新
     *
     * @param sql
     * @return
     */
    @Override
    public int[] batchUpdate(String... sql) {
        int[] rowsAffected = null;
        try {
            for(int i=0; i<sql.length; i++){
                log.info(sql[i]);
            }
            rowsAffected = jdbcTemplate.batchUpdate(sql);
        } catch (Exception e) {
            log.info(logPrefixError + e);
            throw new BaseDaoException(logPrefixError, e);
        }
        return rowsAffected;
    }

    /**
     * 批量更新
     *
     * @param sql
     * @param batchArgs
     * @return
     */
    @Override
    public int[] batchUpdate(String sql, List<Object[]> batchArgs) {
        int[] rowsAffected = null;
        try {
            log.info(sql);
            rowsAffected = jdbcTemplate.batchUpdate(sql, batchArgs);
        } catch (Exception e) {
            log.info(logPrefixError + e);
            throw new BaseDaoException(logPrefixError, e);
        }
        return rowsAffected;
    }

    /**
     * 批量更新
     *
     * @param sql
     * @param pss
     * @return
     */
    @Override
    public int[] batchUpdate(String sql, BatchPreparedStatementSetter pss) {
        int[] rowsAffected = null;
        try {
            log.info(sql);
            rowsAffected = jdbcTemplate.batchUpdate(sql, pss);
        } catch (Exception e) {
            log.info(logPrefixError + e);
            throw new BaseDaoException(logPrefixError, e);
        }
        return rowsAffected;
    }

    /**
     * exec方式更新
     *
     * @param sql
     * @param csc
     * @return
     */
    @Override
    public <T> T execute(String sql, CallableStatementCallback<T> csc) {
        T t = null;
        try {
            log.info(sql);
            t = jdbcTemplate.execute(sql, csc);
        } catch (Exception e) {
            log.info(logPrefixError + e);
            throw new BaseDaoException(logPrefixError, e);
        }
        return t;
    }

    /**
     * 获取列表
     *
     * @param sql
     * @param args
     * @param rowMapper
     * @return
     */
    @Override
    public <T> List<T> query(String sql, Object[] args, RowMapper<T> rowMapper) {
        List<T> rs = null;
        try {
            log.info(sql.replaceAll("\\?", "{}"), args);
            rs =  jdbcTemplate.query(sql, args, rowMapper);
        } catch (Exception e) {
            log.info(logPrefixError + e);
            throw new BaseDaoException(logPrefixError, e);
        }
        return rs;
    }

    /**
     * 获取列表
     *
     * @param sql
     * @param rowMapper
     * @param args
     * @return
     */
    @Override
    public <T> List<T> query(String sql, RowMapper<T> rowMapper, Object... args) {
        List<T> rs = null;
        try {
            log.info(sql.replaceAll("\\?", "{}"), args);
            rs =  jdbcTemplate.query(sql, rowMapper, args);
        } catch (Exception e) {
            log.info(logPrefixError + e);
            throw new BaseDaoException(logPrefixError, e);
        }
        return rs;
    }

    /**
     * 获取Map
     *
     * @param sql
     * @param args
     * @return
     */
    @Override
    public List<Map<String, Object>> queryForMap(String sql, Object... args) {
        List<Map<String, Object>> rsMap = null;
        try {
            log.info(sql.replaceAll("\\?", "{}"), args);
            rsMap =  jdbcTemplate.queryForList(sql, args);
        } catch (Exception e) {
            log.info(logPrefixError + e);
            throw new BaseDaoException(logPrefixError, e);
        }
        return rsMap;
    }

    /**
     * 获取对象
     *
     * @param sql
     * @param args
     * @param rowMapper
     * @return
     */
    @Override
    public <T> T queryForObject(String sql, Object[] args, RowMapper<T> rowMapper) {
        T result = null;
        try {
            log.info(sql.replaceAll("\\?", "{}"), args);
            result =  jdbcTemplate.queryForObject(sql, args, rowMapper);
        } catch (EmptyResultDataAccessException e) {
            return null;
        } catch (Exception e) {
            log.info(logPrefixError + e);
            throw new BaseDaoException(logPrefixError, e);
        }
        return result;
    }

    /**
     * 获取对象
     *
     * @param sql
     * @param rowMapper
     * @param args
     * @return
     */
    @Override
    public <T> T queryForObject(String sql, RowMapper<T> rowMapper, Object... args) {
        T result = null;
        try {
            log.info(sql.replaceAll("\\?", "{}"), args);
            result =  jdbcTemplate.queryForObject(sql, rowMapper, args);
        } catch (EmptyResultDataAccessException e) {
            return null;
        } catch (Exception e) {
            log.info(logPrefixError + e);
            throw new BaseDaoException(logPrefixError, e);
        }
        return result;
    }

    /**
     * 获取单一结果对象
     *
     * @param sql
     * @param args
     * @param requiredType
     * @return
     */
    @Override
    public <T> T queryForObject(String sql, Object[] args, Class<T> requiredType) {
        T result = null;
        try {
            log.info(sql.replaceAll("\\?", "{}"), args);
            result =  jdbcTemplate.queryForObject(sql, args, requiredType);
        } catch (Exception e) {
            log.info(logPrefixError + e);
            throw new BaseDaoException(logPrefixError, e);
        }
        return result;
    }

    /**
     * 获取单一结果对象
     *
     * @param sql
     * @param requiredType
     * @param args
     * @return
     */
    @Override
    public <T> T queryForObject(String sql, Class<T> requiredType, Object... args) {
        T result = null;
        try {
            log.info(sql.replaceAll("\\?", "{}"), args);
            result =  jdbcTemplate.queryForObject(sql, requiredType, args);
        } catch (Exception e) {
            log.info(logPrefixError + e);
            throw new BaseDaoException(logPrefixError, e);
        }
        return result;
    }

    /**
     * 获取Pager对象，根据翻页页码查询
     *
     * @param sql
     * @param args
     * @param rowMapper
     * @param pageNo
     * @param pageSize
     * @return
     */
    @Override
    public <T> Pager<T> queryForPageByPageNo(String sql, Object[] args, RowMapper<T> rowMapper, int pageNo, int pageSize) {
        List<T> items = null;
        Pager pager = new Pager();
        pager.setPageSize(pageSize);
        pager.setPageNo(pageNo);
        int totalCount = this.queryForObject(Pager.getCountSql(sql), args, Integer.class);
        pager.setTotalCount(totalCount);
        //计算出来的
        int startIndex = pager.getStartIndex();
        items = this.query(Pager.getPageSql(sql, startIndex,  pageSize), args, rowMapper);
        pager.setItems(items);
        return pager;
    }

    /**
     * 获取Pager对象，根据起始位置查询
     *
     * @param sql
     * @param args
     * @param rowMapper
     * @param startIndex
     * @param pageSize
     * @return
     */
    @Override
    public <T> Pager<T> queryForPageByIndex(String sql, Object[] args, RowMapper<T> rowMapper, int startIndex, int pageSize) {
        List<T> items = null;
        Pager pager = new Pager();
        pager.setPageSize(pageSize);
        pager.setStartIndex(startIndex);
        int totalCount = this.queryForObject(Pager.getCountSql(sql), args, Integer.class);
        pager.setTotalCount(totalCount);
        items = this.query(Pager.getPageSql(sql, startIndex, pageSize), args, rowMapper);
        pager.setItems(items);
        return pager;
    }

    /**
     * 查询插入的自增ID
     *
     * @return
     */
    @Override
    public Long queryMysqlLastAutoId() {
        return jdbcTemplate.queryForObject("select last_insert_id()", Long.class);
    }
}
