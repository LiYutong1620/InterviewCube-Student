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
import com.ruoyi.interview.domain.InterviewQa;
import com.ruoyi.interview.service.IInterviewQaService;
import com.ruoyi.interview.utils.StudentDataScopeUtils;
import com.ruoyi.common.utils.poi.ExcelUtil;
import com.ruoyi.common.core.page.TableDataInfo;

/**
 * 面试问答Controller
 * 
 * @author tong
 * @date 2026-09-21
 */
@RestController
@RequestMapping("/interview/qa")
public class InterviewQaController extends BaseController
{
    @Autowired
    private IInterviewQaService interviewQaService;

    /**
     * 查询面试问答列表
     */
    @PreAuthorize("@ss.hasPermi('interview:qa:list')")
    @GetMapping("/list")
    public TableDataInfo list(InterviewQa interviewQa)
    {
        StudentDataScopeUtils.scopeToCurrentUser(interviewQa);
        startPage();
        List<InterviewQa> list = interviewQaService.selectInterviewQaList(interviewQa);
        return getDataTable(list);
    }

    /**
     * 导出面试问答列表
     */
    @PreAuthorize("@ss.hasPermi('interview:qa:export')")
    @Log(title = "面试问答", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, InterviewQa interviewQa)
    {
        StudentDataScopeUtils.scopeToCurrentUser(interviewQa);
        List<InterviewQa> list = interviewQaService.selectInterviewQaList(interviewQa);
        ExcelUtil<InterviewQa> util = new ExcelUtil<InterviewQa>(InterviewQa.class);
        util.exportExcel(response, list, "面试问答数据");
    }

    /**
     * 获取面试问答详细信息
     */
    @PreAuthorize("@ss.hasPermi('interview:qa:query')")
    @GetMapping(value = "/{id}")
    public AjaxResult getInfo(@PathVariable("id") Long id)
    {
        return success(StudentDataScopeUtils.checkOwner(interviewQaService.selectInterviewQaById(id), "面试问答"));
    }

    /**
     * 新增面试问答
     */
    @PreAuthorize("@ss.hasPermi('interview:qa:add')")
    @Log(title = "面试问答", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody InterviewQa interviewQa)
    {
        StudentDataScopeUtils.bindOwner(interviewQa);
        return toAjax(interviewQaService.insertInterviewQa(interviewQa));
    }

    /**
     * 修改面试问答
     */
    @PreAuthorize("@ss.hasPermi('interview:qa:edit')")
    @Log(title = "面试问答", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody InterviewQa interviewQa)
    {
        StudentDataScopeUtils.checkOwner(interviewQaService.selectInterviewQaById(interviewQa.getId()), "面试问答");
        return toAjax(interviewQaService.updateInterviewQa(interviewQa));
    }

    /**
     * 删除面试问答
     */
    @PreAuthorize("@ss.hasPermi('interview:qa:remove')")
    @Log(title = "面试问答", businessType = BusinessType.DELETE)
	@DeleteMapping("/{ids}")
    public AjaxResult remove(@PathVariable Long[] ids)
    {
        for (Long id : ids)
        {
            StudentDataScopeUtils.checkOwner(interviewQaService.selectInterviewQaById(id), "面试问答");
        }
        return toAjax(interviewQaService.deleteInterviewQaByIds(ids));
    }
}
