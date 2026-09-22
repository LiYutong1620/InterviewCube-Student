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
import com.ruoyi.interview.domain.StudentProfile;
import com.ruoyi.interview.service.IStudentProfileService;
import com.ruoyi.interview.utils.StudentDataScopeUtils;
import com.ruoyi.common.utils.poi.ExcelUtil;
import com.ruoyi.common.core.page.TableDataInfo;

/**
 * 学生档案Controller
 * 
 * @author tong
 * @date 2026-09-21
 */
@RestController
@RequestMapping("/interview/profile")
public class StudentProfileController extends BaseController
{
    @Autowired
    private IStudentProfileService studentProfileService;

    /**
     * 查询学生档案列表
     */
    @PreAuthorize("@ss.hasPermi('interview:profile:list')")
    @GetMapping("/list")
    public TableDataInfo list(StudentProfile studentProfile)
    {
        StudentDataScopeUtils.scopeToCurrentUser(studentProfile);
        startPage();
        List<StudentProfile> list = studentProfileService.selectStudentProfileList(studentProfile);
        return getDataTable(list);
    }

    /**
     * 导出学生档案列表
     */
    @PreAuthorize("@ss.hasPermi('interview:profile:export')")
    @Log(title = "学生档案", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, StudentProfile studentProfile)
    {
        StudentDataScopeUtils.scopeToCurrentUser(studentProfile);
        List<StudentProfile> list = studentProfileService.selectStudentProfileList(studentProfile);
        ExcelUtil<StudentProfile> util = new ExcelUtil<StudentProfile>(StudentProfile.class);
        util.exportExcel(response, list, "学生档案数据");
    }

    /**
     * 获取学生档案详细信息
     */
    @PreAuthorize("@ss.hasPermi('interview:profile:query')")
    @GetMapping(value = "/{id}")
    public AjaxResult getInfo(@PathVariable("id") Long id)
    {
        return success(StudentDataScopeUtils.checkOwner(studentProfileService.selectStudentProfileById(id), "学生档案"));
    }

    /**
     * 新增学生档案
     */
    @PreAuthorize("@ss.hasPermi('interview:profile:add')")
    @Log(title = "学生档案", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody StudentProfile studentProfile)
    {
        StudentDataScopeUtils.bindOwner(studentProfile);
        return toAjax(studentProfileService.insertStudentProfile(studentProfile));
    }

    /**
     * 修改学生档案
     */
    @PreAuthorize("@ss.hasPermi('interview:profile:edit')")
    @Log(title = "学生档案", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody StudentProfile studentProfile)
    {
        StudentDataScopeUtils.checkOwner(studentProfileService.selectStudentProfileById(studentProfile.getId()), "学生档案");
        return toAjax(studentProfileService.updateStudentProfile(studentProfile));
    }

    /**
     * 删除学生档案
     */
    @PreAuthorize("@ss.hasPermi('interview:profile:remove')")
    @Log(title = "学生档案", businessType = BusinessType.DELETE)
	@DeleteMapping("/{ids}")
    public AjaxResult remove(@PathVariable Long[] ids)
    {
        for (Long id : ids)
        {
            StudentDataScopeUtils.checkOwner(studentProfileService.selectStudentProfileById(id), "学生档案");
        }
        return toAjax(studentProfileService.deleteStudentProfileByIds(ids));
    }
}
