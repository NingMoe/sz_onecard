package com.linkage.zzk.base.dao;

import java.io.Serializable;
import java.text.MessageFormat;
import java.util.List;

/**
 * 分页支持
 *
 * @author :John
 */
public class Pager<T> implements Serializable {
	
	private static final long serialVersionUID = 2673424168985342838L;

	/**
	 * 默认每页几条数据
	 */
	private static int DEFAULT_PAGE_SIZE = 10;

	/**
	 * 总共几条数据
	 */
	private int totalCount;

	/**
	 * 查询起始位置
	 */
	private int startIndex;

	/**
	 * 每页几条数据
	 */
	private int pageSize;

	/**
	 * 每页数据
	 */
	private List<T> items;

	/**
	 * Mysql实现
	 */
	private final static String	FIRST_PAGE_SQL = "select * from ( {0} ) John limit {1}";
	private final static String	PAGING_SQL = "select * from ( {0} ) John limit {1},{2}";

//	/**
//	 * Oracle实现
//	 */
//	private final static String	FIRST_PAGE_SQL = "select * from ( {0} ) where rownum <= {1}";
//	private final static String	PAGING_SQL = "select * from ( select John.*, rownum r from ( {0} ) John ) where r<= {1} and r > {2}";

	/**
	 * 构造器
	 */
	public Pager() {
		this(DEFAULT_PAGE_SIZE);
	}

	/**
	 * 构造器
	 *
	 * @param pageSize   每页几条数据
	 */
	public Pager(int pageSize) {
		this.startIndex = 0;
		if (pageSize < 1) {
			this.pageSize = DEFAULT_PAGE_SIZE;
		} else {
			this.pageSize = pageSize;
		}
	}

	/**
	 * 构造器
	 *
	 * @param startIndex 查询起始位置
	 * @param totalCount 总共几条数据
	 * @param pageSize   每页几条数据
	 */
	public Pager(int startIndex, int totalCount, int pageSize) {
		this.startIndex = startIndex;
		this.totalCount = totalCount;
		this.pageSize = pageSize;
		if (this.pageSize <= 0) {
			this.pageSize = DEFAULT_PAGE_SIZE;
		}
	}

	/**
	 * 设置查询起始位置
	 *
	 * @param startIndex
	 */
	public void setStartIndex(int startIndex) {
		this.startIndex = startIndex;
	}

	/**
	 * 设置每页几条数据
	 *
	 * @param pageSize
	 */
	public void setPageSize(int pageSize) {
		this.pageSize = pageSize;
	}

	/**
	 * 获取总记录数
	 *
	 * @return
	 */
	public int getTotalCount() {
		return totalCount;
	}

	/**
	 * 获取查询最后位置
	 *
	 * @return
	 */
	public int getEndIndex() {
		int endIndex = getStartIndex() + pageSize;
		if (endIndex > totalCount) {
			return totalCount;
		} else {
			return endIndex;
		}
	}

	/**
	 * 获取查询起始位置
	 *
	 * @return
	 */
	public int getStartIndex() {
		if (startIndex > totalCount) {
			return totalCount;
		} else if (startIndex < 0) {
			return 0;
		} else {
			return startIndex;
		}
	}

	/**
	 * 获取下一个查询起始位置
	 *
	 * @return
	 */
	public int getNextIndex() {
		int[] nextStartIndexes = getNextStartIndexes();
		if (nextStartIndexes == null) {
			return getTotalCount();
		} else {
			return nextStartIndexes[0];
		}
	}

	public int getPreviousIndex() {
		int[] previousIndexes = getPreviousStartIndexes();
		if (previousIndexes == null) {
			return getStartIndex();
		} else {
			return previousIndexes[previousIndexes.length - 1];
		}
	}

	public int[] getNextStartIndexes() {
		int index = getEndIndex();
		if (index == totalCount) {
			return null;
		}
		int count = (totalCount - index) / pageSize;
		if ((totalCount - index) % pageSize > 0) {
			count++;
		}
		int result[] = new int[count];
		for (int i = 0; i < count; i++) {
			result[i] = index;
			index += pageSize;
		}
		return result;
	}

	public int[] getPreviousStartIndexes() {
		int index = getStartIndex();
		if (index == 0) {
			return null;
		}
		int count = index / pageSize;
		if (index % pageSize > 0) {
			count++;
		}
		int result[] = new int[count];
		for (int i = count - 1; i > 0; i--) {
			index -= pageSize;
			result[i] = index;
		}
		return result;
	}

	/**
	 * 获取每页几条数据
	 *
	 * @return
	 */
	public int getPageSize() {
		return pageSize;
	}

	/**
	 * 设置总记录数
	 *
	 * @param totalCount
	 */
	public void setTotalCount(int totalCount) {
		this.totalCount = totalCount;
		validate();
	}

	/**
	 * 校验页面参数
	 */
	private void validate() {
		if (startIndex > totalCount) {
			int i = getTotalCount() % pageSize;
			startIndex = totalCount - i;
		}
		if (startIndex < 0) {
			startIndex = 0;
		}
	}

	/**
	 * 获取总页数
	 *
	 * @return
	 */
	public int getPageCount() {
		int pages = getTotalCount() / pageSize;
		int i = getTotalCount() % pageSize;
		if (i > 0) {
			pages++;
		}
		if (getTotalCount() == 0) {
			pages = 1;
		}
		return pages;
	}

	/**
	 * 获取当前页数
	 *
	 * @return
	 */
	public int getPageNo() {
		int pageNo = startIndex / pageSize;
		return pageNo + 1;
	}

	/**
	 * 获取上一页数
	 *
	 * @return
	 */
	public int getPagePre() {
		return getPageNo() - 1;
	}

	/**
	 * 获取上一页数
	 *
	 * @return
	 */
	public int getPageNext() {
		int page = getPageNo() + 1;
		if (page > getPageCount()) {
			return getPageCount();
		} else {
			return page;
		}
	}

	/**
	 * 设置页数
	 *
	 * @param pageNo
	 */
	public void setPageNo(int pageNo) {
		if (pageNo < 1) {
			startIndex = 0;
		} else {
			startIndex = (pageNo - 1) * pageSize;
		}
	}

	/**
	 * 设置当前页对象列表
	 *
	 * @param items
	 */
	public void setItems(List<T> items) {
		this.items = items;
	}

	/**
	 * 获取当前页对象列表
	 *
	 * @return
	 */
	public List<T> getItems() {
		return items;
	}

	/**
	 * 获取查询总记录SQL脚本
	 *
	 * @param sql
	 * @return
	 */
	public static String getCountSql(String sql) {
		return "select count(*) from ("+sql+") John";
	}

	/**
	 * 获取查询翻页记录SQL脚本
	 *
	 * @param sql
	 * @param startIndex
	 * @param pageSize
	 * @return
	 */
	public static String getPageSql(String sql, int startIndex, int pageSize) {
		if (startIndex < 0){
			startIndex = 0;
		}
		if (pageSize < 0){
			pageSize = DEFAULT_PAGE_SIZE;
		}
		if (startIndex == 0) {
			return MessageFormat.format(FIRST_PAGE_SQL, new Object[] { sql, String.valueOf(pageSize) });
		} else {
//			//Oracle
//			return MessageFormat.format(PAGING_SQL, new Object[] { sql, String.valueOf(startIndex + pageSize), String.valueOf(startIndex)});

			//Mysql
			return MessageFormat.format(PAGING_SQL, new Object[] { sql, String.valueOf(startIndex), String.valueOf(pageSize)});
		}
	}
}
