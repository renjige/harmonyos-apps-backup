import { WritingWorkflow } from '../models/LanguageCraftModels'
import { LanguageEngineService } from './LanguageEngineService'

/** 一键创作工作流 — 审核可点的完整体验路径 */
export class LanguageWorkflowService {
  static all(): WritingWorkflow[] {
    return [
      WritingWorkflow.of('wf_email', '口语 → 正式邮件', '载入样例并四风格对照',
        LanguageEngineService.oralSample(), 'email', 'formal'),
      WritingWorkflow.of('wf_minutes', '口水 → 结构化纪要', '会议口语改书面纪要',
        '然后我们就是开了个会，那个进度其实挺慢的，感觉下周能不能赶紧把材料整一下，谢谢哈。',
        'minutes', 'formal'),
      WritingWorkflow.of('wf_brief', '长段 → 简洁要点', '拆成可执行列表',
        LanguageEngineService.summarySample(), 'general', 'brief'),
      WritingWorkflow.of('wf_follow', '模糊催办 → 明确请求', '对象 + 动作 + 时限',
        '那个材料你看得咋样了，我们这边挺急的，能不能今天给个回复谢谢哈。',
        'followup', 'formal'),
      WritingWorkflow.of('wf_research', '研究笔记 → 汇报', '调研口语改汇报体',
        '这次调研发现用户最在意的是响应速度，然后价格敏感度反而没那么高，对后续产品策略挺重要。',
        'report', 'full'),
      WritingWorkflow.of('wf_thanks', '口语致谢 → 感谢信', '正式致谢结构',
        '上次你帮我改那个材料真的帮大忙了，特别谢谢哈，下次请你吃饭。',
        'thanks', 'warm'),
      WritingWorkflow.of('wf_academic', '课程讨论 → 学术表达', '论点论据书面化',
        '我觉得作者那个结论有点跳，样本量好像也不够，然后跟第三讲的理论是不是有点矛盾。',
        'academic', 'formal'),
      WritingWorkflow.of('wf_leave', '口语请假 → 申请函', '事由时段交接齐全',
        '我明天想请个假，家里有点事，你看行不行，工作我会跟同事交接一下。',
        'leave', 'formal'),
      WritingWorkflow.of('wf_weekly', '周报口语 → 汇报体', '本周/下周结构化',
        '这周主要就是把需求文档整了一下，然后跟设计对了两次，下周打算开始开发，就是测试资源还没定。',
        'report', 'full'),
      WritingWorkflow.of('wf_customer', '客户沟通 → 正式回复', '确认事项 + 时限',
        '客户问交付时间，那个其实我们也挺急的，感觉大概下周能弄好，你看行不行，有问题随时说哈。',
        'email', 'formal'),
      WritingWorkflow.of('wf_field', '田野笔记 → 研究摘要', '观察发现书面化',
        '今天在访谈里注意到用户反复提到「等待焦虑」，然后他们会反复刷新页面，这个跟我们的假设不太一样。',
        'note', 'full')
    ]
  }

  static find(key: string): WritingWorkflow | undefined {
    for (const row of LanguageWorkflowService.all()) {
      if (row.key === key) {
        return row
      }
    }
    return undefined
  }
}
