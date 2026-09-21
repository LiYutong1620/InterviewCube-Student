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
import com.ruoyi.interview.domain.InterviewReport;
import com.ruoyi.interview.service.IInterviewReportService;
import com.ruoyi.common.utils.poi.ExcelUtil;
import com.ruoyi.common.core.page.TableDataInfo;

/**
 * 面试复盘报告Controller
 * 
 * @author tong
 * @date 2026-09-21
 */
@RestController
@RequestMapping("/interview/report")
public class InterviewReportController extends BaseController
{
    @Autowired
    private IInterviewReportService interviewReportService;

    /**
     * 查询面试复盘报告列表
     */
    @PreAuthorize("@ss.hasPermi('interview:report:list')")
    @GetMapping("/list")
    public TableDataInfo list(InterviewReport interviewReport)
    {
        startPage();
        List<InterviewReport> list = interviewReportService.selectInterviewReportList(interviewReport);
        return getDataTable(list);
    }

    /**
     * 导出面试复盘报告列表
     */
    @PreAuthorize("@ss.hasPermi('interview:report:export')")
    @Log(title = "面试复盘报告", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, InterviewReport interviewReport)
    {
        List<InterviewReport> list = interviewReportService.selectInterviewReportList(interviewReport);
        ExcelUtil<InterviewReport> util = new ExcelUtil<InterviewReport>(InterviewReport.class);
        util.exportExcel(response, list, "面试复盘报告数据");
    }

    /**
     * 获取面试复盘报告详细信息
     */
    @PreAuthorize("@ss.hasPermi('interview:report:query')")
    @GetMapping(value = "/{id}")
    public AjaxResult getInfo(@PathVariable("id") Long id)
    {
        return success(interviewReportService.selectInterviewReportById(id));
    }

    /**
     * 新增面试复盘报告
     */
    @PreAuthorize("@ss.hasPermi('interview:report:add')")
    @Log(title = "面试复盘报告", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody InterviewReport interviewReport)
    {
        return toAjax(interviewReportService.insertInterviewReport(interviewReport));
    }

    /**
     * 修改面试复盘报告
     */
    @PreAuthorize("@ss.hasPermi('interview:report:edit')")
    @Log(title = "面试复盘报告", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody InterviewReport interviewReport)
    {
        return toAjax(interviewReportService.updateInterviewReport(interviewReport));
    }

    /**
     * 删除面试复盘报告
     */
    @PreAuthorize("@ss.hasPermi('interview:report:remove')")
    @Log(title = "面试复盘报告", businessType = BusinessType.DELETE)
	@DeleteMapping("/{ids}")
    public AjaxResult remove(@PathVariable Long[] ids)
    {
        return toAjax(interviewReportService.deleteInterviewReportByIds(ids));
    }
}
