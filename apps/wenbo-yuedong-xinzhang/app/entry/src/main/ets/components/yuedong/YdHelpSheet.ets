import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from '../detail/DetailShell'
import { YdDetailNav } from '../../services/YdDetailNav'

@Component
export struct YdHelpSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0

  build() {
    DetailShell({
      title: '使用指南',
      onClose: (): void => { YdDetailNav.closeHelp() },
      body: (): void => { this.Body() }
    })
  }

  @Builder
  Body() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        this.Section('1. 开启人生篇章', '在「篇章」或首页开启 7/14/30 天篇章，选择职场跃升、备考冲刺等主题。每章有明确起止日期。')
        this.Section('2. 今日执行', '在「今日」添加任务，按工作/学习/生活分类；勾选完成时可记录投入分钟，写入时间账。')
        this.Section('3. 章末复盘收官', '到期后在篇章详情写至少 20 字复盘，点击「写完并收官」。收官后「我的-已收官章」与「成长-跃动指数」会即时更新。')
        this.Section('4. 长期目标', '在「目标」创建里程碑目标，逐项勾选；全部完成后自动归档至「已达成」。')
        this.Section('5. 成长洞察', '「成长」提供日/周/月/年统计、时间轴、热力图、12 枚徽章与多维度导出，非简单备忘录。')
        this.Section('6. 数据说明', '完成率 = 今日已完成任务 ÷ 今日总任务；跃动指数综合完成率、连续天数、目标进度与收官篇章；数据存于本机。')
        AppButton({
          label: '知道了',
          onTap: (): void => { YdDetailNav.closeHelp() }
        })
      }
      .width('100%')
      .padding(Theme.space.pageX)
      .padding({ bottom: Theme.space.s10 })
    }
  }

  @Builder
  Section(title: string, body: string) {
    Column({ space: Theme.space.s2 }) {
      Text(title)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text(body)
        .fontSize(Theme.type.bodyS)
        .fontColor(Theme.colors().textSecondary)
        .lineHeight(20)
        .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .alignItems(HorizontalAlign.Start)
  }
}
