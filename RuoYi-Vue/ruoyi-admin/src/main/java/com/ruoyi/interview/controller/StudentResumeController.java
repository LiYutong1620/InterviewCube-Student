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
import com.ruoyi.interview.domain.StudentResume;
import com.ruoyi.interview.service.IStudentResumeService;
import com.ruoyi.interview.utils.StudentDataScopeUtils;
import com.ruoyi.common.utils.poi.ExcelUtil;
import com.ruoyi.common.core.page.TableDataInfo;

/**
 * 学生简历Controller
 * 
 * @author tong
 * @date 2026-09-21
 */
@RestController
@RequestMapping("/interview/resume")
public class StudentResumeController extends BaseController
{
    @Autowired
    private IStudentResumeService studentResumeService;

    /**
     * 查询学生简历列表
     */
    @PreAuthorize("@ss.hasPermi('interview:resume:list')")
    @GetMapping("/list")
    public TableDataInfo list(StudentResume studentResume)
    {
        StudentDataScopeUtils.scopeToCurrentUser(studentResume);
        startPage();
        List<StudentResume> list = studentResumeService.selectStudentResumeList(studentResume);
        return getDataTable(list);
    }

    /**
     * 导出学生简历列表
     */
    @PreAuthorize("@ss.hasPermi('interview:resume:export')")
    @Log(title = "学生简历", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, StudentResume studentResume)
    {
        StudentDataScopeUtils.scopeToCurrentUser(studentResume);
        List<StudentResume> list = studentResumeService.selectStudentResumeList(studentResume);
        ExcelUtil<StudentResume> util = new ExcelUtil<StudentResume>(StudentResume.class);
        util.exportExcel(response, list, "学生简历数据");
    }

    /**
     * 获取学生简历详细信息
     */
    @PreAuthorize("@ss.hasPermi('interview:resume:query')")
    @GetMapping(value = "/{id}")
    public AjaxResult getInfo(@PathVariable("id") Long id)
    {
        return success(StudentDataScopeUtils.checkOwner(studentResumeService.selectStudentResumeById(id), "学生简历"));
    }

    /**
     * 新增学生简历
     */
    @PreAuthorize("@ss.hasPermi('interview:resume:add')")
    @Log(title = "学生简历", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody StudentResume studentResume)
    {
        StudentDataScopeUtils.bindOwner(studentResume);
        return toAjax(studentResumeService.insertStudentResume(studentResume));
    }

    /**
     * 修改学生简历
     */
    @PreAuthorize("@ss.hasPermi('interview:resume:edit')")
    @Log(title = "学生简历", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody StudentResume studentResume)
    {
        StudentDataScopeUtils.checkOwner(studentResumeService.selectStudentResumeById(studentResume.getId()), "学生简历");
        return toAjax(studentResumeService.updateStudentResume(studentResume));
    }

    /**
     * 删除学生简历
     */
    @PreAuthorize("@ss.hasPermi('interview:resume:remove')")
    @Log(title = "学生简历", businessType = BusinessType.DELETE)
	@DeleteMapping("/{ids}")
    public AjaxResult remove(@PathVariable Long[] ids)
    {
        for (Long id : ids)
        {
            StudentDataScopeUtils.checkOwner(studentResumeService.selectStudentResumeById(id), "学生简历");
        }
        return toAjax(studentResumeService.deleteStudentResumeByIds(ids));
    }
}
