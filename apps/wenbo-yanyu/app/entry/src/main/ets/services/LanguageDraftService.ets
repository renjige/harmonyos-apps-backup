import { DraftTemplate } from '../models/LanguageCraftModels'

/** 场景成稿：24 类填空模板（本机，不调用大模型） */
export class LanguageDraftService {
  static templates(): DraftTemplate[] {
    return [
      DraftTemplate.of('email', '工作邮件', '主题或场合', '要说明的事实', '希望对方做什么'),
      DraftTemplate.of('minutes', '会议纪要', '会议名称', '达成的结论', '待办与负责人'),
      DraftTemplate.of('apology', '致歉说明', '对方称呼或角色', '出了什么问题', '补救与时限'),
      DraftTemplate.of('report', '进展汇报', '事项名称', '当前进展', '需要的决策'),
      DraftTemplate.of('leave', '请假申请', '请假日期或时段', '请假事由', '工作交接安排'),
      DraftTemplate.of('thanks', '感谢反馈', '对方称呼', '具体帮助或支持', '后续安排或致谢'),
      DraftTemplate.of('followup', '催办跟进', '跟进事项', '当前卡点或背景', '期望回复时限'),
      DraftTemplate.of('proposal', '方案说明', '方案名称', '背景与目标', '建议动作或收益'),
      DraftTemplate.of('invite', '活动邀请', '活动名称与时间', '地点与议程', '请对方确认事项'),
      DraftTemplate.of('handover', '工作交接', '交接时段', '负责事项清单', '对接人与资料位置'),
      DraftTemplate.of('schedule', '改期通知', '原定安排', '改期原因', '新时间与确认方式'),
      DraftTemplate.of('praise', '绩效反馈', '对象称呼', '具体表现与事实', '改进建议或期望'),
      DraftTemplate.of('literature', '文献笔记', '文献来源', '核心观点', '对本研究的启发'),
      DraftTemplate.of('course', '课程讨论', '讨论主题', '你的论点', '待澄清的问题'),
      DraftTemplate.of('thesis', '论文提纲', '研究问题', '章节结构', '研究方法'),
      DraftTemplate.of('research_sum', '研究摘要', '研究主题', '主要发现', '意义或下一步'),
      DraftTemplate.of('reading', '阅读札记', '书名或章节', '摘录要点', '个人思考与关联'),
      DraftTemplate.of('decline', '婉拒邀请', '活动名称', '无法参加的原因', '替代安排或祝福'),
      DraftTemplate.of('cooperation', '合作洽谈', '合作主题', '我方资源或诉求', '建议下一步'),
      DraftTemplate.of('announcement', '内部通知', '通知主题', '主要内容', '执行要求或截止时间'),
      DraftTemplate.of('weekly', '周报小结', '本周完成事项', '遇到的问题或风险', '下周计划'),
      DraftTemplate.of('client_reply', '客户回复', '客户称呼或项目名', '确认的事实或方案', '下一步与时限'),
      DraftTemplate.of('self_intro', '自我介绍', '身份或背景', '特长或经历', '当前诉求或目标'),
      DraftTemplate.of('book_review', '书评短评', '书名或主题', '评价要点', '推荐给谁')
    ]
  }

  static find(key: string): DraftTemplate {
    const list = LanguageDraftService.templates()
    for (const row of list) {
      if (row.key === key) {
        return row
      }
    }
    return DraftTemplate.of('email', '工作邮件', '主题或场合', '要说明的事实', '希望对方做什么')
  }

  static build(key: string, fieldA: string, fieldB: string, fieldC: string): string {
    const a = fieldA.trim()
    const b = fieldB.trim()
    const c = fieldC.trim()
    if (a.length === 0 || b.length === 0 || c.length === 0) {
      return ''
    }
    if (key === 'minutes') {
      return `【${a}】会议纪要\n一、结论：${b}\n二、待办：${c}\n请各位按节点推进，如有异议请当日反馈。`
    }
    if (key === 'apology') {
      return `${a}您好：\n关于${b}，给您带来不便，深表歉意。我们将${c}。\n再次致歉，谢谢理解。`
    }
    if (key === 'report') {
      return `汇报如下：\n事项：${a}\n当前进展：${b}\n请示：${c}\n请指示是否批准及下一步安排。`
    }
    if (key === 'leave') {
      return `${a}您好：\n因${b}，拟申请请假。工作已安排${c}，请批准。\n谢谢。`
    }
    if (key === 'thanks') {
      return `${a}您好：\n感谢您在${b}方面给予的支持。${c}。\n此致\n谢谢。`
    }
    if (key === 'followup') {
      return `${a}您好：\n现跟进「${b}」。${c}。\n烦请确认进度并回复，谢谢。`
    }
    if (key === 'proposal') {
      return `方案说明：${a}\n背景与目标：${b}\n建议：${c}\n请审阅并反馈是否可行。`
    }
    if (key === 'invite') {
      return `活动邀请：${a}\n地点与议程：${b}\n请您${c}。\n期待您的参与，谢谢。`
    }
    if (key === 'handover') {
      return `工作交接说明（${a}）\n负责事项：${b}\n对接与资料：${c}\n如有疑问请当日联系，谢谢。`
    }
    if (key === 'schedule') {
      return `日程调整通知\n原定：${a}\n原因：${b}\n调整为：${c}\n请确认是否可行，谢谢。`
    }
    if (key === 'praise') {
      return `${a}您好：\n关于近期工作，${b}。建议：${c}。\n期待继续协作，谢谢。`
    }
    if (key === 'literature') {
      return `文献笔记：${a}\n核心观点：${b}\n研究启发：${c}`
    }
    if (key === 'course') {
      return `课程讨论：${a}\n论点：${b}\n待讨论：${c}`
    }
    if (key === 'thesis') {
      return `论文提纲\n研究问题：${a}\n结构：${b}\n方法：${c}`
    }
    if (key === 'research_sum') {
      return `研究摘要\n主题：${a}\n发现：${b}\n意义：${c}`
    }
    if (key === 'reading') {
      return `阅读札记：${a}\n摘录：${b}\n思考：${c}`
    }
    if (key === 'decline') {
      return `关于「${a}」的回复\n因${b}，暂无法参加。${c}。\n谢谢邀请，祝活动顺利。`
    }
    if (key === 'cooperation') {
      return `合作洽谈：${a}\n我方情况：${b}\n建议：${c}\n期待进一步沟通，谢谢。`
    }
    if (key === 'announcement') {
      return `【通知】${a}\n内容：${b}\n要求：${c}\n请按要求执行，谢谢配合。`
    }
    if (key === 'weekly') {
      return `周报小结\n本周完成：${a}\n问题与风险：${b}\n下周计划：${c}\n请审阅，谢谢。`
    }
    if (key === 'client_reply') {
      return `${a}您好：\n关于您咨询的事项，${b}。\n下一步：${c}。\n如有疑问请随时联系，谢谢。`
    }
    if (key === 'self_intro') {
      return `自我介绍\n背景：${a}\n特长与经历：${b}\n当前诉求：${c}`
    }
    if (key === 'book_review') {
      return `《${a}》短评\n评价：${b}\n推荐：${c}`
    }
    return `您好：\n关于「${a}」，${b}。\n烦请${c}。\n此致\n谢谢。`
  }
}
