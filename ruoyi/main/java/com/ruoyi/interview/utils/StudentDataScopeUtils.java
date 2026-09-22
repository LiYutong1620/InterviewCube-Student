package com.ruoyi.interview.utils;

import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.interview.domain.UserOwned;

/**
 * 学生数据归属工具
 * 学生端数据隔离的统一入口：普通学生只能查/改/删自己的数据，拥有全量权限的角色不受限制
 *
 * 两道防线：
 *   ① 记录级 —— scopeToCurrentUser / bindOwner / checkOwner，管「能不能碰这条记录」，在 Controller 层调用；
 *   ② 字段级 —— requireManage，管「能不能直接调通用写接口」，在 Service 层调用。
 *
 * @author tong
 * @date 2026-09-22
 */
public class StudentDataScopeUtils
{
    /**
     * 查看全部学生数据的权限标识
     * 只分配给后台管理角色，不分配给「学生」角色；
     * 超级管理员由若依自动授予 *:*:*，无需显式分配即可通过
     */
    public static final String PERMI_DATA_ALL = "interview:data:all";

    /**
     * 正常状态值（与 CHAR(1) 状态列的注释「0正常 1停用」一致）
     */
    public static final String STATUS_NORMAL = "0";

    private StudentDataScopeUtils()
    {
    }

    /**
     * 当前登录用户是否可以查看与操作全部学生数据
     *
     * @return 结果
     */
    public static boolean canViewAll()
    {
        return SecurityUtils.hasPermi(PERMI_DATA_ALL);
    }

    /**
     * 共享资源（如题库 question_bank）的可见状态判断
     * 这类表没有 user_id，不参与归属隔离，靠 status 控制学生可见性：
     * 没有全量数据权限时只可见「正常」的数据，停用的记录对学生不可见
     *
     * @param status 记录状态值，记录不存在时可传 null
     * @return 当前登录用户是否可见
     */
    public static boolean canViewStatus(String status)
    {
        return canViewAll() || STATUS_NORMAL.equals(status);
    }

    /**
     * 获取当前登录用户ID
     * 始终返回真实用户ID，用于写入数据归属，不受全量权限影响
     *
     * @return 当前登录用户ID
     */
    public static Long currentUserId()
    {
        return SecurityUtils.getUserId();
    }

    /**
     * 获取数据隔离范围
     * 拥有全量权限时返回 null 表示不限制范围，否则返回本人用户ID
     *
     * @return 数据隔离范围
     */
    public static Long scopeUserId()
    {
        return canViewAll() ? null : SecurityUtils.getUserId();
    }

    /**
     * 新增：强制把数据归属写为当前登录用户（不信任前端传参）
     *
     * @param record 实体对象
     * @return 传入的实体对象，便于链式调用
     */
    public static <T extends UserOwned> T bindOwner(T record)
    {
        record.setUserId(currentUserId());
        return record;
    }

    /**
     * 列表/导出：把查询范围限定为当前登录用户（拥有全量权限时不限制）
     *
     * @param query 查询条件对象
     * @return 传入的查询条件对象，便于链式调用
     */
    public static <T extends UserOwned> T scopeToCurrentUser(T query)
    {
        query.setUserId(scopeUserId());
        return query;
    }

    /**
     * 详情/修改/删除：校验数据归属，记录不存在或不属于当前登录用户时抛出异常
     * 拥有全量权限（超级管理员、后台管理角色）时跳过归属校验
     *
     * @param record 数据库中查询出的记录，可为 null
     * @param label  业务名称，用于拼接提示语
     * @return 校验通过的记录
     */
    public static <T extends UserOwned> T checkOwner(T record, String label)
    {
        if (record == null)
        {
            throw new ServiceException("数据不存在或已删除");
        }
        if (!canViewAll() && !currentUserId().equals(record.getUserId()))
        {
            throw new ServiceException("无权操作或查看该" + label + "数据");
        }
        return record;
    }

    /**
     * 通用写接口的闸门（字段级防线的唯一入口）
     *
     * 通用 CRUD 端点（POST / PUT / DELETE /interview/xxx）是给后台端做完整维护用的，字段没有白名单 ——
     * 学生调它就能绕过业务入口改系统字段，例如：
     *   · PUT /interview/session  改 status='2'          → 造出「已完成但没有复盘报告」的脏状态
     *   · PUT /interview/qa       改 score / ai_comment  → 阶段三接入 AI 后等于伪造评分
     *   · PUT /interview/report   改 total_score         → 自定分数
     * 若依的权限点粒度做不到「同一权限点、不同字段」，所以这道闸门只能放在 Service 层。
     *
     * 学生自己的数据请走业务入口：开始面试 / 作答提交 / 提前结束 / 手工填分。
     * 拥有全量权限（interview:data:all）的角色即后台侧，不受限制。
     *
     * @param label 业务名称，用于拼接提示语
     */
    public static void requireManage(String label)
    {
        if (!canViewAll())
        {
            throw new ServiceException(label + "不支持直接编辑，请通过对应页面的业务入口操作");
        }
    }
}
