import { ScenarioCategory, WritingScenario } from '../models/LanguageCraftModels'
import { LanguageEngineService } from './LanguageEngineService'

/** 创作场景目录 — 24 类覆盖职场 / 学术 / 研究 / 生活 */
export class LanguageScenarioService {
  static categories(): ScenarioCategory[] {
    return [
      ScenarioCategory.of('all', '全部'),
      ScenarioCategory.of('work', '职场'),
      ScenarioCategory.of('study', '学术'),
      ScenarioCategory.of('research', '研究'),
      ScenarioCategory.of('life', '生活')
    ]
  }

  static all(): WritingScenario[] {
    return [
      WritingScenario.of('work_email', '工作邮件', '对外沟通 · 称呼成稿', 'work', 'email', 'email',
        '那个就是想跟你说一下，然后这次方案其实挺急的，感觉你能不能帮忙看一下，尽快给个回复谢谢哈。'),
      WritingScenario.of('meeting_minutes', '会议纪要', '会后整理 · 结论待办', 'work', 'minutes', 'minutes',
        '然后我们就是开了个会，那个进度其实挺慢的，感觉下周能不能赶紧把材料整一下，谢谢哈。'),
      WritingScenario.of('progress_report', '进展汇报', '向上同步 · 请示决策', 'work', 'report', 'report',
        '项目这边其实还行吧，就是预算那边还没批，你看能不能帮忙催一下，大概这周五前要。'),
      WritingScenario.of('leave_request', '请假申请', '事由 + 时段 + 交接', 'work', 'leave', 'leave',
        '我明天想请个假，家里有点事，你看行不行，工作我会跟小李交接。'),
      WritingScenario.of('thanks_note', '感谢反馈', '致谢 + 具体帮助', 'work', 'thanks', 'thanks',
        '上次你帮我改那个材料真的帮大忙了，特别谢谢哈，下次请你吃饭。'),
      WritingScenario.of('follow_up', '催办跟进', '事项 + 时限 + 请求', 'work', 'followup', 'followup',
        '那个方案你那边看得怎么样了，我们这边挺急的，能不能今天下班前给个回复。'),
      WritingScenario.of('proposal', '方案说明', '背景 + 方案 + 收益', 'work', 'proposal', 'report',
        '我们想做一个用户反馈收集，其实挺简单的，就是加个表单，你看能不能排进这迭代。'),
      WritingScenario.of('event_invite', '活动邀请', '时间地点 + 议程', 'work', 'invite', 'email',
        '下周三想搞个分享会，你能来吗，大概下午三点，在会议室 A。'),
      WritingScenario.of('handover', '工作交接', '事项清单 + 联系人', 'work', 'handover', 'report',
        '我下周要出差，那个客户对接和周报你先帮忙看着，有问题找王姐，材料在共享盘。'),
      WritingScenario.of('schedule_change', '改期通知', '原时间 + 新时间 + 确认', 'work', 'schedule', 'email',
        '那个会能不能改到周四下午，周三临时有事，你看大家方不方便，不行就线上。'),
      WritingScenario.of('praise_feedback', '绩效反馈', '事实 + 亮点 + 建议', 'work', 'praise', 'report',
        '这季度你那个项目做得挺好的，就是文档可以再规范一点，下次注意节点同步。'),
      WritingScenario.of('cooperation', '合作洽谈', '合作点 + 诉求 + 下一步', 'work', 'cooperation', 'email',
        '我们这边有个联合活动想法，想跟你们资源互换一下，你看有没有兴趣聊聊。'),
      WritingScenario.of('literature_note', '文献笔记', '来源 + 观点 + 启发', 'study', 'literature', 'academic',
        '这篇论文主要就是说城市更新要兼顾社区参与，然后方法是用问卷加访谈，感觉对我们课题挺有参考。'),
      WritingScenario.of('course_discussion', '课程讨论', '论点 + 论据 + 疑问', 'study', 'course', 'academic',
        '我觉得作者那个结论有点跳，样本量好像也不够，然后跟第三讲的理论是不是有点矛盾。'),
      WritingScenario.of('thesis_outline', '论文提纲', '问题 + 结构 + 方法', 'study', 'thesis', 'academic',
        '我想写数字经济对传统行业的影响，大概分背景、案例、对策三章，方法用文献分析加访谈。'),
      WritingScenario.of('research_summary', '研究摘要', '问题 + 发现 + 意义', 'research', 'research_sum', 'academic',
        '这次调研发现用户最在意的是响应速度，然后价格敏感度反而没那么高，对后续产品策略挺重要。'),
      WritingScenario.of('reading_reflection', '阅读札记', '摘录 + 思考 + 关联', 'research', 'reading', 'note',
        '书里提到「慢思考」和决策偏差的关系，联想到我们上次讨论的调研问卷设计，可能要多设对照组。'),
      WritingScenario.of('invitation_decline', '婉拒邀请', '感谢 + 原因 + 替代', 'life', 'decline', 'email',
        '谢谢邀请哈，那天实在安排不开，下次有机会一定参加，你们玩得开心。'),
      WritingScenario.of('customer_reply', '客户回复', '确认 + 方案 + 下一步', 'work', 'client_reply', 'email',
        '客户问交付时间，那个其实我们也挺急的，感觉大概下周能弄好，你看行不行，有问题随时说哈。'),
      WritingScenario.of('weekly_report', '周报小结', '本周完成 + 下周计划', 'work', 'weekly', 'report',
        '这周主要就是把需求文档整了一下，然后跟设计对了两次，下周打算开始开发，就是测试资源还没定。'),
      WritingScenario.of('self_intro', '自我介绍', '背景 + 特长 + 诉求', 'study', 'self_intro', 'academic',
        '我是做产品方向的，之前主要搞过教育和工具类，然后这次想多了解一下用户研究这块。'),
      WritingScenario.of('debate_rebuttal', '讨论回应', '观点 + 论据 + 回应', 'study', 'course', 'academic',
        '我不太同意刚才那个说法，因为样本只覆盖了一线城市，然后跟我们的调研结果也不太一样。'),
      WritingScenario.of('field_note', '田野观察', '场景 + 发现 + 疑问', 'research', 'research_sum', 'note',
        '今天在访谈里注意到用户反复提到「等待焦虑」，然后他们会反复刷新页面，这个跟我们的假设不太一样。'),
      WritingScenario.of('book_review', '书评短评', '主题 + 评价 + 推荐', 'life', 'reading', 'note',
        '这本书讲习惯养成，例子挺多的，就是理论部分有点散，适合入门读，推荐给做自我管理的同学。')
    ]
  }

  static byCategory(categoryKey: string): WritingScenario[] {
    if (categoryKey === 'all' || categoryKey.length === 0) {
      return LanguageScenarioService.all()
    }
    const out: WritingScenario[] = []
    for (const row of LanguageScenarioService.all()) {
      if (row.category === categoryKey) {
        out.push(row)
      }
    }
    return out
  }

  static find(key: string): WritingScenario | undefined {
    for (const row of LanguageScenarioService.all()) {
      if (row.key === key) {
        return row
      }
    }
    return undefined
  }

  static demoScenario(): WritingScenario {
    return LanguageScenarioService.all()[0]
  }

  static oralDemoText(): string {
    return LanguageEngineService.oralSample()
  }
}
