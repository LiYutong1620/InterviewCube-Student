package com.ruoyi.interview.utils;

import java.awt.Color;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONArray;
import com.lowagie.text.Document;
import com.lowagie.text.DocumentException;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.PageSize;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.pdf.BaseFont;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.interview.domain.InterviewReport;

/**
 * 面试复盘报告 PDF 生成工具
 *
 * @author tong
 */
public final class ReportPdfUtils
{
    private static final String[] DIMENSION_LABELS = { "完整性", "逻辑性", "流畅度", "深度", "自信度" };

    private static final String[] FONT_CANDIDATES = {
            "C:/Windows/Fonts/msyh.ttc,0",
            "C:/Windows/Fonts/simsun.ttc,0",
            "C:/Windows/Fonts/simhei.ttf",
            "/System/Library/Fonts/PingFang.ttc,0",
            "/System/Library/Fonts/STHeiti Light.ttc,0",
            "/usr/share/fonts/truetype/wqy/wqy-zenhei.ttc",
            "/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc,0",
            "/usr/share/fonts/truetype/noto/NotoSansCJK-Regular.ttc,0"
    };

    private ReportPdfUtils()
    {
    }

    /**
     * 根据报告内容生成 PDF 字节流
     *
     * @param report 已生成成功的复盘报告
     * @return PDF 字节
     */
    public static byte[] build(InterviewReport report)
    {
        if (report == null)
        {
            throw new ServiceException("报告不存在");
        }
        try (ByteArrayOutputStream out = new ByteArrayOutputStream())
        {
            Document document = new Document(PageSize.A4, 48, 48, 56, 48);
            PdfWriter.getInstance(document, out);
            document.open();

            BaseFont baseFont = resolveChineseFont();
            Font titleFont = new Font(baseFont, 18, Font.BOLD, Color.DARK_GRAY);
            Font headingFont = new Font(baseFont, 13, Font.BOLD, Color.DARK_GRAY);
            Font bodyFont = new Font(baseFont, 11, Font.NORMAL, Color.DARK_GRAY);
            Font metaFont = new Font(baseFont, 10, Font.NORMAL, Color.GRAY);

            Paragraph title = new Paragraph("面试复盘报告", titleFont);
            title.setAlignment(Element.ALIGN_CENTER);
            title.setSpacingAfter(16f);
            document.add(title);

            document.add(metaLine("报告编号", display(report.getReportNo()), metaFont));
            document.add(metaLine("场次编号", display(report.getSessionNo()), metaFont));
            document.add(metaLine("岗位名称", display(report.getJobName()), metaFont));
            document.add(metaLine("面试时间", formatDate(report.getStartTime()), metaFont));
            document.add(metaLine("生成时间", formatDate(report.getGenerateTime()), metaFont));

            Paragraph scoreTitle = new Paragraph("综合得分", headingFont);
            scoreTitle.setSpacingBefore(18f);
            scoreTitle.setSpacingAfter(8f);
            document.add(scoreTitle);

            Paragraph total = new Paragraph(displayScore(report.getTotalScore()) + " 分", titleFont);
            total.setAlignment(Element.ALIGN_CENTER);
            total.setSpacingAfter(12f);
            document.add(total);

            Paragraph dimTitle = new Paragraph("维度得分", headingFont);
            dimTitle.setSpacingBefore(8f);
            dimTitle.setSpacingAfter(8f);
            document.add(dimTitle);
            document.add(buildScoreTable(report, bodyFont));

            addSection(document, "总体评价", display(report.getSummary()), headingFont, bodyFont);
            addSection(document, "薄弱点", joinWeakPoints(report.getWeakPoints()), headingFont, bodyFont);
            addSection(document, "改进建议", display(report.getSuggest()), headingFont, bodyFont);

            document.close();
            return out.toByteArray();
        }
        catch (ServiceException e)
        {
            throw e;
        }
        catch (Exception e)
        {
            throw new ServiceException("生成 PDF 失败：" + e.getMessage());
        }
    }

    private static PdfPTable buildScoreTable(InterviewReport report, Font font) throws DocumentException
    {
        BigDecimal[] scores = {
                report.getScoreCompleteness(), report.getScoreLogic(), report.getScoreFluency(),
                report.getScoreDepth(), report.getScoreConfidence()
        };
        PdfPTable table = new PdfPTable(2);
        table.setWidthPercentage(100);
        table.setWidths(new float[] { 1.2f, 1f });
        for (int i = 0; i < DIMENSION_LABELS.length; i++)
        {
            table.addCell(cell(DIMENSION_LABELS[i], font));
            table.addCell(cell(displayScore(scores[i]), font));
        }
        return table;
    }

    private static PdfPCell cell(String text, Font font)
    {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setPadding(8f);
        cell.setBorderColor(new Color(220, 223, 230));
        return cell;
    }

    private static void addSection(Document document, String title, String body, Font headingFont, Font bodyFont)
            throws DocumentException
    {
        Paragraph heading = new Paragraph(title, headingFont);
        heading.setSpacingBefore(16f);
        heading.setSpacingAfter(6f);
        document.add(heading);
        Paragraph content = new Paragraph(body, bodyFont);
        content.setLeading(18f);
        document.add(content);
    }

    private static Paragraph metaLine(String label, String value, Font font)
    {
        Paragraph p = new Paragraph(label + "：" + value, font);
        p.setSpacingAfter(3f);
        return p;
    }

    private static String joinWeakPoints(String raw)
    {
        if (StringUtils.isEmpty(raw))
        {
            return "暂无";
        }
        try
        {
            JSONArray array = JSON.parseArray(raw);
            if (array == null || array.isEmpty())
            {
                return "暂无";
            }
            List<String> items = new ArrayList<>();
            for (int i = 0; i < array.size(); i++)
            {
                String item = StringUtils.trim(array.getString(i));
                if (StringUtils.isNotEmpty(item))
                {
                    items.add((i + 1) + ". " + item);
                }
            }
            return items.isEmpty() ? "暂无" : String.join("\n", items);
        }
        catch (Exception e)
        {
            return raw;
        }
    }

    private static String display(String value)
    {
        return StringUtils.isEmpty(value) ? "—" : value;
    }

    private static String displayScore(BigDecimal score)
    {
        return score == null ? "—" : score.stripTrailingZeros().toPlainString();
    }

    private static String formatDate(Date date)
    {
        if (date == null)
        {
            return "—";
        }
        return new SimpleDateFormat("yyyy-MM-dd HH:mm").format(date);
    }

    private static BaseFont resolveChineseFont()
    {
        for (String candidate : FONT_CANDIDATES)
        {
            try
            {
                String path = candidate.contains(",") ? candidate.substring(0, candidate.indexOf(',')) : candidate;
                if (!Files.exists(Path.of(path)) && !new File(path).exists())
                {
                    continue;
                }
                return BaseFont.createFont(candidate, BaseFont.IDENTITY_H, BaseFont.EMBEDDED);
            }
            catch (Exception ignored)
            {
                // try next candidate
            }
        }
        try
        {
            return BaseFont.createFont(BaseFont.HELVETICA, BaseFont.WINANSI, BaseFont.NOT_EMBEDDED);
        }
        catch (Exception e)
        {
            throw new ServiceException("未找到可用字体，无法生成 PDF");
        }
    }
}
