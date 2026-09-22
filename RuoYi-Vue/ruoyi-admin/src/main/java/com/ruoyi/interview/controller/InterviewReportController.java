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
import com.ruoyi.interview.utils.StudentDataScopeUtils;
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
        StudentDataScopeUtils.scopeToCurrentUser(interviewReport);
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
        StudentDataScopeUtils.scopeToCurrentUser(interviewReport);
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
        return success(StudentDataScopeUtils.checkOwner(interviewReportService.selectInterviewReportById(id), "面试复盘报告"));
    }

    /**
     * 新增面试复盘报告
     */
    @PreAuthorize("@ss.hasPermi('interview:report:add')")
    @Log(title = "面试复盘报告", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody InterviewReport interviewReport)
    {
        StudentDataScopeUtils.bindOwner(interviewReport);
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
        StudentDataScopeUtils.checkOwner(interviewReportService.selectInterviewReportById(interviewReport.getId()), "面试复盘报告");
        return toAjax(interviewReportService.updateInterviewReport(interviewReport));
    }

    /**
     * 手工填分（阶段一的演示入口，阶段三换成 AI 自动生成）
     * 只认 sessionId + 五个维度 + 总结 / 薄弱点 / 改进建议；
     * 总分由后端按五维平均算出，report_no / user_id / generate_status / generate_time 也由后端写；
     * 该场次还没有报告壳时先补建，兼容 S4 之前就已完成的场次
     */
    @PreAuthorize("@ss.hasPermi('interview:report:edit')")
    @Log(title = "面试复盘报告", businessType = BusinessType.UPDATE)
    @PostMapping("/fill")
    public AjaxResult fill(@RequestBody InterviewReport interviewReport)
    {
        return success(interviewReportService.fillReport(interviewReport));
    }

    /**
     * 导出 PDF：生成文件并回写 pdf_url，返回最新报告（含下载地址）
     */
    @PreAuthorize("@ss.hasPermi('interview:report:export')")
    @Log(title = "面试复盘报告PDF", businessType = BusinessType.EXPORT)
    @PostMapping("/pdf/{id}")
    public AjaxResult exportPdf(@PathVariable("id") Long id)
    {
        return success(interviewReportService.exportPdf(id));
    }

    /**
     * 删除面试复盘报告
     */
    @PreAuthorize("@ss.hasPermi('interview:report:remove')")
    @Log(title = "面试复盘报告", businessType = BusinessType.DELETE)
	@DeleteMapping("/{ids}")
    public AjaxResult remove(@PathVariable Long[] ids)
    {
        for (Long id : ids)
        {
            StudentDataScopeUtils.checkOwner(interviewReportService.selectInterviewReportById(id), "面试复盘报告");
        }
        return toAjax(interviewReportService.deleteInterviewReportByIds(ids));
    }
}
