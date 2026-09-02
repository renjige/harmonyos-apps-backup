import { Theme } from '../design-system/Theme'
import { AppIcon, AppIconName } from '../design-system/AppIcon'
import { SolidButton } from '../design-system/SolidButton'
import { ExperiencePackService } from '../../services/ExperiencePackService'
import { ProfileStore } from '../../services/ProfileStore'
import { DataRefresh } from '../../services/DataRefresh'

@Component
export struct FeatureTourOverlay {
  onDismiss: () => void = () => {}
  @State loading: boolean = false
  @State toast: string = ''

  private async dismiss(): Promise<void> {
    const profile = ProfileStore.get()
    profile.featureTourSeen = 1
    await ProfileStore.save(profile)
    AppStorage.setOrCreate('mainTabIndex', 1)
    this.onDismiss()
  }

  private async loadPack(): Promise<void> {
    if (this.loading) {
      return
    }
    this.loading = true
    const added = await ExperiencePackService.load()
    this.loading = false
    if (added) {
      DataRefresh.bump()
      this.toast = '已加载体验内容（挑战/图鉴/笔记/目标），均可编辑或删除'
      setTimeout((): void => {
        AppStorage.setOrCreate('mainTabIndex', 1)
        void this.dismiss()
      }, 1600)
      return
    }
    this.toast = '体验内容已存在，可直接浏览各 Tab'
    setTimeout((): void => { this.toast = '' }, 2400)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(15,23,42,0.55)')
        .onClick((): void => { void this.dismiss() })

      Column({ space: Theme.space.s3 }) {
        Text('训练拾趣 · 运动玩法导览')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text('跟练计时、随机玩法、呼吸放松、周运动剧本、图鉴挑战与成长报告——覆盖多种运动生活场景。')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .lineHeight(22)
              .width('100%')

            this.CapRow('ai', '今天玩什么', '随机抽取 10 种运动玩法')
            this.CapRow('refresh', '呼吸放松', '4-7-8 节奏引导，独立放松模块')
            this.CapRow('sparkle', '动作跟练', '选动作逐步计时跟练')
            this.CapRow('calendar', '周运动剧本', '周一～周日安排不同玩法')
            this.CapRow('home', '生活场景', '晨起/工间/晚间等 6 种一键场景')
            this.CapRow('sparkle', '发现', '动作图鉴五专区 + 挑战馆')
            this.CapRow('chart', '成长', '月度报告、热力日历、成就徽章')
            this.CapRow('message', '运动笔记', '心得、感悟与小技巧')
            this.CapRow('user', '我的', '统计、主题皮肤、导出与设置')

            Text('可选：加载【体验】示例（挑战/图鉴/笔记/目标），不含他人数据，均可删除。')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .lineHeight(18)
              .width('100%')
              .padding({ bottom: Theme.space.s2 })
          }
          .width('100%')
        }
        .layoutWeight(1)
        .width('100%')
        .scrollBar(BarState.Auto)
        .edgeEffect(EdgeEffect.Spring)

        SolidButton({
          label: this.loading ? '加载中…' : '一键加载体验内容',
          tone: 'secondary',
          onTap: (): void => { void this.loadPack() }
        })
        SolidButton({
          label: '进入玩法中心',
          tone: 'primary',
          onTap: (): void => { void this.dismiss() }
        })
      }
      .width('100%')
      .height('82%')
      .padding(Theme.space.s5)
      .margin({ left: 20, right: 20, top: 36 })
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)
      .border({ width: 1, color: Theme.colors().strokeHairline })

      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(15,23,42,0.88)')
          .borderRadius(Theme.radius.pill)
          .margin({ top: 56 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(50)
  }

  @Builder
  CapRow(icon: AppIconName, title: string, desc: string) {
    Row({ space: Theme.space.s3 }) {
      Column() {
        AppIcon({ name: icon, iconSize: Theme.icon.lg, color: Theme.colors().brandPrimary })
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.md)

      Column({ space: 2 }) {
        Text(title)
          .fontSize(Theme.type.body)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        Text(desc)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
  }
}
