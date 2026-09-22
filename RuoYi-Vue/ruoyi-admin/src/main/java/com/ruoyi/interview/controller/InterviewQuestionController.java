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
import com.ruoyi.interview.domain.InterviewQuestion;
import com.ruoyi.interview.service.IInterviewQuestionService;
import com.ruoyi.interview.utils.StudentDataScopeUtils;
import com.ruoyi.common.utils.poi.ExcelUtil;
import com.ruoyi.common.core.page.TableDataInfo;

/**
 * 面试题目Controller
 * 
 * @author tong
 * @date 2026-09-21
 */
@RestController
@RequestMapping("/interview/question")
public class InterviewQuestionController extends BaseController
{
    @Autowired
    private IInterviewQuestionService interviewQuestionService;

    /**
     * 查询面试题目列表
     */
    @PreAuthorize("@ss.hasPermi('interview:question:list')")
    @GetMapping("/list")
    public TableDataInfo list(InterviewQuestion interviewQuestion)
    {
        StudentDataScopeUtils.scopeToCurrentUser(interviewQuestion);
        startPage();
        List<InterviewQuestion> list = interviewQuestionService.selectInterviewQuestionList(interviewQuestion);
        return getDataTable(list);
    }

    /**
     * 导出面试题目列表
     */
    @PreAuthorize("@ss.hasPermi('interview:question:export')")
    @Log(title = "面试题目", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, InterviewQuestion interviewQuestion)
    {
        StudentDataScopeUtils.scopeToCurrentUser(interviewQuestion);
        List<InterviewQuestion> list = interviewQuestionService.selectInterviewQuestionList(interviewQuestion);
        ExcelUtil<InterviewQuestion> util = new ExcelUtil<InterviewQuestion>(InterviewQuestion.class);
        util.exportExcel(response, list, "面试题目数据");
    }

    /**
     * 获取面试题目详细信息
     */
    @PreAuthorize("@ss.hasPermi('interview:question:query')")
    @GetMapping(value = "/{id}")
    public AjaxResult getInfo(@PathVariable("id") Long id)
    {
        return success(StudentDataScopeUtils.checkOwner(interviewQuestionService.selectInterviewQuestionById(id), "面试题目"));
    }

    /**
     * 新增面试题目
     */
    @PreAuthorize("@ss.hasPermi('interview:question:add')")
    @Log(title = "面试题目", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody InterviewQuestion interviewQuestion)
    {
        StudentDataScopeUtils.bindOwner(interviewQuestion);
        return toAjax(interviewQuestionService.insertInterviewQuestion(interviewQuestion));
    }

    /**
     * 修改面试题目
     */
    @PreAuthorize("@ss.hasPermi('interview:question:edit')")
    @Log(title = "面试题目", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody InterviewQuestion interviewQuestion)
    {
        StudentDataScopeUtils.checkOwner(interviewQuestionService.selectInterviewQuestionById(interviewQuestion.getId()), "面试题目");
        return toAjax(interviewQuestionService.updateInterviewQuestion(interviewQuestion));
    }

    /**
     * 删除面试题目
     */
    @PreAuthorize("@ss.hasPermi('interview:question:remove')")
    @Log(title = "面试题目", businessType = BusinessType.DELETE)
	@DeleteMapping("/{ids}")
    public AjaxResult remove(@PathVariable Long[] ids)
    {
        for (Long id : ids)
        {
            StudentDataScopeUtils.checkOwner(interviewQuestionService.selectInterviewQuestionById(id), "面试题目");
        }
        return toAjax(interviewQuestionService.deleteInterviewQuestionByIds(ids));
    }
}
