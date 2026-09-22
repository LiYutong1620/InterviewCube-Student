package com.ruoyi.interview.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.domain.model.LoginUser;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.framework.web.service.TokenService;
import com.ruoyi.system.service.ISysUserService;

/**
 * 学生端个人中心
 *
 * 资料展示 / 编辑走既有 interview:profile 与 system/user/profile；
 * 本控制器只提供学生自助注销账号能力。
 *
 * @author tong
 */
@RestController
@RequestMapping("/interview/mine")
public class StudentMineController extends BaseController
{
    @Autowired
    private ISysUserService userService;

    @Autowired
    private TokenService tokenService;

    /**
     * 注销当前登录账号（软删除），不可注销超级管理员
     */
    @PreAuthorize("@ss.hasPermi('interview:mine:list')")
    @Log(title = "学生账号注销", businessType = BusinessType.DELETE)
    @DeleteMapping("/cancel")
    public AjaxResult cancel()
    {
        LoginUser loginUser = getLoginUser();
        Long userId = loginUser.getUserId();
        if (SecurityUtils.isAdmin(userId))
        {
            throw new ServiceException("超级管理员不允许注销");
        }
        userService.deleteUserById(userId);
        tokenService.delLoginUser(loginUser.getToken());
        return success("账号已注销");
    }
}
