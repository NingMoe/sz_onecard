package com.linkage.zzk.base.dao;

import org.springframework.jdbc.core.BatchPreparedStatementSetter;
import org.springframework.jdbc.core.CallableStatementCallback;
import org.springframework.jdbc.core.RowMapper;

import java.util.List;
import java.util.Map;

/**
 * DAO支持接口
 *
 * @author: John
 */
public interface BaseDao {

	/**
	 * 更新数据
	 *
	 * @param sql
	 * @return
	 */
	int update(String sql);

	/**
	 * 更新数据
	 *
	 * @param sql
	 * @param args
	 * @return
	 */
	int update(String sql, Object... args);

	/**
	 * 批量更新
	 *
	 * @param sql
	 * @return
	 */
	int[] batchUpdate(final String... sql);

	/**
	 * 批量更新
	 *
	 * @param sql
	 * @param batchArgs
	 * @return
	 */
	int[] batchUpdate(String sql, List<Object[]> batchArgs);

	/**
	 * 批量更新
	 *
	 * @param sql
	 * @param pss
	 * @return
	 */
	int[] batchUpdate(String sql, final BatchPreparedStatementSetter pss);

	/**
	 * exec方式更新
	 *
	 * @param sql
	 * @param csc
	 * @param <T>
	 * @return
	 */
	<T> T execute(String sql, CallableStatementCallback<T> csc);

	/**
	 * 获取列表
	 *
	 * @param sql
	 * @param args
	 * @param rowMapper
	 * @param <T>
	 * @return
	 */
	<T> List<T> query(String sql, Object[] args, RowMapper<T> rowMapper);

	/**
	 * 获取列表
	 *
	 * @param sql
	 * @param rowMapper
	 * @param args
	 * @param <T>
	 * @return
	 */
	<T> List<T> query(String sql, RowMapper<T> rowMapper, Object... args);

	/**
	 * 获取Map
	 *
	 * @param sql
	 * @param args
	 * @return
	 */
	List<Map<String, Object>> queryForMap(String sql, Object... args);

	/**
	 * 获取对象
	 *
	 * @param sql
	 * @param args
	 * @param rowMapper
	 * @param <T>
	 * @return
	 */
	<T> T queryForObject(String sql, Object[] args, RowMapper<T> rowMapper);

	/**
	 * 获取对象
	 *
	 * @param sql
	 * @param rowMapper
	 * @param args
	 * @param <T>
	 * @return
	 */
	<T> T queryForObject(String sql, RowMapper<T> rowMapper, Object... args);

	/**
	 * 获取单一结果对象
	 *
	 * @param sql
	 * @param args
	 * @param requiredType
	 * @param <T>
	 * @return
	 */
	<T> T queryForObject(String sql, Object[] args, Class<T> requiredType);

	/**
	 * 获取单一结果对象
	 *
	 * @param sql
	 * @param requiredType
	 * @param args
	 * @param <T>
	 * @return
	 */
	<T> T queryForObject(String sql, Class<T> requiredType, Object... args);

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
	<T> Pager<T> queryForPageByPageNo(String sql, Object[] args, RowMapper<T> rowMapper, int pageNo, int pageSize);

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
	<T> Pager<T> queryForPageByIndex(String sql, Object[] args, RowMapper<T> rowMapper, int startIndex, int pageSize);

	/**
	 * 查询插入的自增ID
	 *
	 * @return
	 */
	Long queryMysqlLastAutoId();

}
