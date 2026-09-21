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
import com.ruoyi.interview.domain.QuestionBank;
import com.ruoyi.interview.service.IQuestionBankService;
import com.ruoyi.common.utils.poi.ExcelUtil;
import com.ruoyi.common.core.page.TableDataInfo;

/**
 * 题库题目Controller
 * 
 * @author tong
 * @date 2026-09-21
 */
@RestController
@RequestMapping("/interview/bank")
public class QuestionBankController extends BaseController
{
    @Autowired
    private IQuestionBankService questionBankService;

    /**
     * 查询题库题目列表
     */
    @PreAuthorize("@ss.hasPermi('interview:bank:list')")
    @GetMapping("/list")
    public TableDataInfo list(QuestionBank questionBank)
    {
        startPage();
        List<QuestionBank> list = questionBankService.selectQuestionBankList(questionBank);
        return getDataTable(list);
    }

    /**
     * 导出题库题目列表
     */
    @PreAuthorize("@ss.hasPermi('interview:bank:export')")
    @Log(title = "题库题目", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, QuestionBank questionBank)
    {
        List<QuestionBank> list = questionBankService.selectQuestionBankList(questionBank);
        ExcelUtil<QuestionBank> util = new ExcelUtil<QuestionBank>(QuestionBank.class);
        util.exportExcel(response, list, "题库题目数据");
    }

    /**
     * 获取题库题目详细信息
     */
    @PreAuthorize("@ss.hasPermi('interview:bank:query')")
    @GetMapping(value = "/{id}")
    public AjaxResult getInfo(@PathVariable("id") Long id)
    {
        return success(questionBankService.selectQuestionBankById(id));
    }

    /**
     * 新增题库题目
     */
    @PreAuthorize("@ss.hasPermi('interview:bank:add')")
    @Log(title = "题库题目", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody QuestionBank questionBank)
    {
        return toAjax(questionBankService.insertQuestionBank(questionBank));
    }

    /**
     * 修改题库题目
     */
    @PreAuthorize("@ss.hasPermi('interview:bank:edit')")
    @Log(title = "题库题目", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody QuestionBank questionBank)
    {
        return toAjax(questionBankService.updateQuestionBank(questionBank));
    }

    /**
     * 删除题库题目
     */
    @PreAuthorize("@ss.hasPermi('interview:bank:remove')")
    @Log(title = "题库题目", businessType = BusinessType.DELETE)
	@DeleteMapping("/{ids}")
    public AjaxResult remove(@PathVariable Long[] ids)
    {
        return toAjax(questionBankService.deleteQuestionBankByIds(ids));
    }
}
