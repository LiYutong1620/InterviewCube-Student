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
import com.ruoyi.interview.domain.StudentJobProfile;
import com.ruoyi.interview.service.IStudentJobProfileService;
import com.ruoyi.interview.utils.StudentDataScopeUtils;
import com.ruoyi.common.utils.poi.ExcelUtil;
import com.ruoyi.common.core.page.TableDataInfo;

/**
 * 学生岗位画像Controller
 * 
 * @author tong
 * @date 2026-09-21
 */
@RestController
@RequestMapping("/interview/jobprofile")
public class StudentJobProfileController extends BaseController
{
    @Autowired
    private IStudentJobProfileService studentJobProfileService;

    /**
     * 查询学生岗位画像列表
     */
    @PreAuthorize("@ss.hasPermi('interview:jobprofile:list')")
    @GetMapping("/list")
    public TableDataInfo list(StudentJobProfile studentJobProfile)
    {
        StudentDataScopeUtils.scopeToCurrentUser(studentJobProfile);
        startPage();
        List<StudentJobProfile> list = studentJobProfileService.selectStudentJobProfileList(studentJobProfile);
        return getDataTable(list);
    }

    /**
     * 导出学生岗位画像列表
     */
    @PreAuthorize("@ss.hasPermi('interview:jobprofile:export')")
    @Log(title = "学生岗位画像", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, StudentJobProfile studentJobProfile)
    {
        StudentDataScopeUtils.scopeToCurrentUser(studentJobProfile);
        List<StudentJobProfile> list = studentJobProfileService.selectStudentJobProfileList(studentJobProfile);
        ExcelUtil<StudentJobProfile> util = new ExcelUtil<StudentJobProfile>(StudentJobProfile.class);
        util.exportExcel(response, list, "学生岗位画像数据");
    }

    /**
     * 获取学生岗位画像详细信息
     */
    @PreAuthorize("@ss.hasPermi('interview:jobprofile:query')")
    @GetMapping(value = "/{id}")
    public AjaxResult getInfo(@PathVariable("id") Long id)
    {
        return success(StudentDataScopeUtils.checkOwner(studentJobProfileService.selectStudentJobProfileById(id), "学生岗位画像"));
    }

    /**
     * 新增学生岗位画像
     */
    @PreAuthorize("@ss.hasPermi('interview:jobprofile:add')")
    @Log(title = "学生岗位画像", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody StudentJobProfile studentJobProfile)
    {
        StudentDataScopeUtils.bindOwner(studentJobProfile);
        return toAjax(studentJobProfileService.insertStudentJobProfile(studentJobProfile));
    }

    /**
     * 修改学生岗位画像
     */
    @PreAuthorize("@ss.hasPermi('interview:jobprofile:edit')")
    @Log(title = "学生岗位画像", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody StudentJobProfile studentJobProfile)
    {
        StudentDataScopeUtils.checkOwner(studentJobProfileService.selectStudentJobProfileById(studentJobProfile.getId()), "学生岗位画像");
        return toAjax(studentJobProfileService.updateStudentJobProfile(studentJobProfile));
    }

    /**
     * 删除学生岗位画像
     */
    @PreAuthorize("@ss.hasPermi('interview:jobprofile:remove')")
    @Log(title = "学生岗位画像", businessType = BusinessType.DELETE)
	@DeleteMapping("/{ids}")
    public AjaxResult remove(@PathVariable Long[] ids)
    {
        for (Long id : ids)
        {
            StudentDataScopeUtils.checkOwner(studentJobProfileService.selectStudentJobProfileById(id), "学生岗位画像");
        }
        return toAjax(studentJobProfileService.deleteStudentJobProfileByIds(ids));
    }
}
