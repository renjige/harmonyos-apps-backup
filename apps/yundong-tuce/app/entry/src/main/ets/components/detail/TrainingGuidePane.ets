import { Theme } from '../design-system/Theme'

class GuideArticle {
  title: string = ''
  body: string = ''
}

@Component
export struct TrainingGuidePane {
  @StorageLink('themeEpoch') themeEpoch: number = 0

  private articles(): GuideArticle[] {
    const out: GuideArticle[] = []
    const defs: string[][] = [
      ['热身为什么要 5 分钟', '心率缓慢上升、关节滑液分泌，降低受伤风险。建议开合跳或高抬腿后再进入主训练。'],
      ['组间休息怎么定', '力量训练 30–60 秒，有氧循环 15–30 秒。可在「编排方案」里设置休息秒数。'],
      ['如何判断完成度', '日志里的完成感 1–5 分：3 分表示按计划完成，4–5 分表示状态上佳。'],
      ['连续打卡的意义', '连续天数反映习惯养成，不必追求高强度；低强度恢复日也算有效训练。'],
      ['拉伸放在何时', '动态拉伸在训练前，静态拉伸在训练后 5–10 分钟，避免冷肌肉大幅度牵拉。'],
      ['核心训练要点', '平板、死虫等动作保持肋骨下沉、呼吸顺畅，质量优先于时长。'],
      ['收藏夹怎么用', '把常用动作收入收藏夹或自定义收藏夹，可快速编排成周期计划。'],
      ['知识卡复习法', '从动作详情保存知识卡，赛前 3 分钟浏览要点与注意事项。'],
      ['跟练模式怎么用', '精选课详情点「开始跟练」，逐步完成动作并自动组间休息，结束后一键写入日志。'],
      ['体能自测推荐课表', '成长页「体能自测」4 题生成推荐课，按目标/场景/水平匹配 12 套精选课。'],
      ['训练周报分享', '「训练周报」汇总本周次数、连续天与下一步建议，可复制分享。'],
      ['场景课怎么选', '居家/办公室/户外/跑后/HIIT/新手 7 类场景，每类 1–3 套现成序列。'],
      ['动作对比编排', '图鉴或成长页打开「动作对比」，对照部位与难度再编排方案。'],
      ['周期计划配合', '保存方案后开 7/14/21/30 日计划，跟练或打卡推进每日进度。'],
      ['恢复日怎么练', '选「跑后放松」或「睡前舒缓」课，低强度仍计入连续打卡。']
    ]
    for (const row of defs) {
      const a = new GuideArticle()
      a.title = row[0]
      a.body = row[1]
      out.push(a)
    }
    return out
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s3 }) {
        Text('训练百科')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text('围绕动作、计划与恢复的小知识，帮助把记录变成可坚持的训练习惯。')
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        ForEach(this.articles(), (a: GuideArticle, idx: number) => {
          Column({ space: 6 }) {
            Text(`${idx + 1}. ${a.title}`)
              .fontSize(Theme.type.body)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(a.body)
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .lineHeight(22)
              .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
        }, (a: GuideArticle, idx: number) => `guide_${idx}`)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
    }
    .width('100%')
    .height('100%')
  }
}
