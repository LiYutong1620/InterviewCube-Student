package com.ruoyi.interview.controller;

import java.util.List;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.interview.domain.InterviewSession;
import com.ruoyi.interview.service.IInterviewSessionService;
import com.ruoyi.interview.utils.StudentDataScopeUtils;
import com.ruoyi.common.utils.poi.ExcelUtil;
import com.ruoyi.common.core.page.TableDataInfo;

/**
 * 模拟面试场次Controller
 * 
 * @author tong
 * @date 2026-09-21
 */
@RestController
@RequestMapping("/interview/session")
public class InterviewSessionController extends BaseController
{
    @Autowired
    private IInterviewSessionService interviewSessionService;

    /**
     * 查询模拟面试场次列表
     */
    @PreAuthorize("@ss.hasPermi('interview:session:list')")
    @GetMapping("/list")
    public TableDataInfo list(InterviewSession interviewSession)
    {
        StudentDataScopeUtils.scopeToCurrentUser(interviewSession);
        startPage();
        List<InterviewSession> list = interviewSessionService.selectInterviewSessionList(interviewSession);
        return getDataTable(list);
    }

    /**
     * 导出模拟面试场次列表
     */
    @PreAuthorize("@ss.hasPermi('interview:session:export')")
    @Log(title = "模拟面试场次", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, InterviewSession interviewSession)
    {
        StudentDataScopeUtils.scopeToCurrentUser(interviewSession);
        List<InterviewSession> list = interviewSessionService.selectInterviewSessionList(interviewSession);
        ExcelUtil<InterviewSession> util = new ExcelUtil<InterviewSession>(InterviewSession.class);
        util.exportExcel(response, list, "模拟面试场次数据");
    }

    /**
     * 获取模拟面试场次详细信息
     */
    @PreAuthorize("@ss.hasPermi('interview:session:query')")
    @GetMapping(value = "/{id}")
    public AjaxResult getInfo(@PathVariable("id") Long id)
    {
        return success(StudentDataScopeUtils.checkOwner(interviewSessionService.selectInterviewSessionById(id), "模拟面试场次"));
    }

    /**
     * 新增模拟面试场次（=「开始面试」）
     * 前端只传 jobProfileId / questionType / totalCount，其余字段由后端生成；
     * 返回生成的场次实体（含 id、sessionNo），前端据此跳到作答页
     */
    @PreAuthorize("@ss.hasPermi('interview:session:add')")
    @Log(title = "模拟面试场次", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody InterviewSession interviewSession)
    {
        StudentDataScopeUtils.bindOwner(interviewSession);
        interviewSessionService.insertInterviewSession(interviewSession);
        return success(interviewSession);
    }

    /**
     * 修改模拟面试场次
     */
    @PreAuthorize("@ss.hasPermi('interview:session:edit')")
    @Log(title = "模拟面试场次", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody InterviewSession interviewSession)
    {
        StudentDataScopeUtils.checkOwner(interviewSessionService.selectInterviewSessionById(interviewSession.getId()), "模拟面试场次");
        return toAjax(interviewSessionService.updateInterviewSession(interviewSession));
    }

    /**
     * 提前结束一场面试（进行中 → 已中断）
     * 作答页的「提前结束」入口；已完成 / 已中断的场次不允许再改
     */
    @PreAuthorize("@ss.hasPermi('interview:session:edit')")
    @Log(title = "模拟面试场次", businessType = BusinessType.UPDATE)
    @PutMapping("/abort/{id}")
    public AjaxResult abort(@PathVariable("id") Long id)
    {
        return success(interviewSessionService.abortInterviewSession(id));
    }

    /**
     * 删除模拟面试场次
     */
    @PreAuthorize("@ss.hasPermi('interview:session:remove')")
    @Log(title = "模拟面试场次", businessType = BusinessType.DELETE)
	@DeleteMapping("/{ids}")
    public AjaxResult remove(@PathVariable Long[] ids)
    {
        for (Long id : ids)
        {
            StudentDataScopeUtils.checkOwner(interviewSessionService.selectInterviewSessionById(id), "模拟面试场次");
        }
        return toAjax(interviewSessionService.deleteInterviewSessionByIds(ids));
    }
}
