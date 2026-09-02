import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon, AppIconName } from '../design-system/AppIcon'
import { AppStatCard } from '../design-system/AppStatCard'

/** 首页阅读工坊：打卡入口 + 八个管理场景 */
@Component
export struct HomeStudioGrid {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop streakDays: number = 0
  @Prop checkedToday: boolean = false
  @Prop weekMinutes: number = 0
  onOpenCheckin: () => void = () => {}
  onOpenNotes: () => void = () => {}
  onOpenQuotes: () => void = () => {}
  onOpenReviews: () => void = () => {}
  onOpenInspirations: () => void = () => {}
  onOpenBooklists: () => void = () => {}
  onOpenMonthly: () => void = () => {}
  onOpenReport: () => void = () => {}
  onOpenLamp: () => void = () => {}
  onOpenDialogue: () => void = () => {}
  onOpenStudioPlay: () => void = () => {}
  onOpenBookAsk: () => void = () => {}

  build() {
    Column({ space: Theme.space.s4 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image($r('app.media.checkin_morning'))
          .width('100%')
          .height(148)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.xl)
        Column()
          .width('100%')
          .height(148)
          .linearGradient({
            angle: 180,
            colors: [['rgba(45,90,74,0.08)', 0], ['rgba(45,90,74,0.82)', 1]]
          })
          .borderRadius(Theme.radius.xl)
        Column({ space: 6 }) {
          Text(this.checkedToday ? '今日已打卡' : '每日阅读打卡')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textOnInverse)
          Text(`连续 ${this.streakDays} 天 · 本周 ${this.weekMinutes} 分钟`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textOnInverse)
          AppButton({
            label: this.checkedToday ? '查看打卡' : '立即打卡',
            onTap: (): void => { this.onOpenCheckin() }
          })
        }
        .padding(Theme.space.s5)
        .alignItems(HorizontalAlign.Start)
        .width('100%')
      }
      .width('100%')

      Row({ space: Theme.space.s3 }) {
        AppStatCard({
          label: '连续打卡',
          value: `${this.streakDays}`,
          trend: '天',
          positive: true
        }).layoutWeight(1)
        AppStatCard({
          label: '本周阅读',
          value: `${this.weekMinutes}`,
          trend: '分钟',
          positive: true
        }).layoutWeight(1)
      }
      .width('100%')

      Stack({ alignContent: Alignment.BottomStart }) {
        Image($r('app.media.lamp_session'))
          .width('100%')
          .height(132)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.xl)
        Column()
          .width('100%')
          .height(132)
          .linearGradient({
            angle: 180,
            colors: [['rgba(26,22,18,0.08)', 0], ['rgba(26,22,18,0.78)', 1]]
          })
          .borderRadius(Theme.radius.xl)
        Column({ space: 6 }) {
          Text('灯下共读')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textOnInverse)
          Text('陪读计时结束，必须留下今日一句')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textOnInverse)
          AppButton({
            label: '开始共读',
            onTap: (): void => { this.onOpenLamp() }
          })
        }
        .padding(Theme.space.s5)
        .alignItems(HorizontalAlign.Start)
        .width('100%')
      }
      .width('100%')

      Stack({ alignContent: Alignment.BottomStart }) {
        Image($r('app.media.dialogue_pair'))
          .width('100%')
          .height(132)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.xl)
        Column()
          .width('100%')
          .height(132)
          .linearGradient({
            angle: 180,
            colors: [['rgba(26,22,18,0.08)', 0], ['rgba(26,22,18,0.78)', 1]]
          })
          .borderRadius(Theme.radius.xl)
        Column({ space: 6 }) {
          Text('对读札')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textOnInverse)
          Text('从两句金句出发，写一段对照思考')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textOnInverse)
          AppButton({
            label: '开始对读',
            onTap: (): void => { this.onOpenDialogue() }
          })
        }
        .padding(Theme.space.s5)
        .alignItems(HorizontalAlign.Start)
        .width('100%')
      }
      .width('100%')

      Text('书房管理')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text('书架、笔记、计划等辅助工具；核心差异化见上方三种玩法')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')

      Row({ space: Theme.space.s3 }) {
        this.ActionTile('今日打卡', 'check', (): void => { this.onOpenCheckin() })
        this.ActionTile('阅读札记', 'biz', (): void => { this.onOpenNotes() })
      }
      .width('100%')
      Row({ space: Theme.space.s3 }) {
        this.ActionTile('金句摘录', 'heart', (): void => { this.onOpenQuotes() })
        this.ActionTile('书评记录', 'photo', (): void => { this.onOpenReviews() })
      }
      .width('100%')
      Row({ space: Theme.space.s3 }) {
        this.ActionTile('灵感收藏', 'ai', (): void => { this.onOpenInspirations() })
        this.ActionTile('专题书单', 'book', (): void => { this.onOpenBooklists() })
      }
      .width('100%')
      Row({ space: Theme.space.s3 }) {
        this.ActionTile('月度回顾', 'calendar', (): void => { this.onOpenMonthly() })
        this.ActionTile('阅读统计', 'chart', (): void => { this.onOpenReport() })
      }
      .width('100%')
      Row({ space: Theme.space.s3 }) {
        this.ActionTile('书房玩法', 'ai', (): void => { this.onOpenStudioPlay() })
        this.ActionTile('问书三札', 'biz', (): void => { this.onOpenBookAsk() })
      }
      .width('100%')
      Row({ space: Theme.space.s3 }) {
        this.ActionTile('灯下共读', 'ai', (): void => { this.onOpenLamp() })
        this.ActionTile('对读札', 'heart', (): void => { this.onOpenDialogue() })
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  ActionTile(label: string, icon: string, onTap: () => void) {
    Row({ space: 8 }) {
      AppIcon({
        name: this.iconName(icon),
        iconSize: Theme.icon.sm,
        color: Theme.colors().brandPrimary
      })
      Text(label)
        .fontSize(Theme.type.caption)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
    }
    .layoutWeight(1)
    .padding({ left: 12, right: 12, top: 14, bottom: 14 })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick((): void => { onTap() })
  }

  private iconName(icon: string): AppIconName {
    if (icon === 'check') { return 'check' }
    if (icon === 'biz') { return 'biz' }
    if (icon === 'heart') { return 'heart' }
    if (icon === 'photo') { return 'photo' }
    if (icon === 'ai') { return 'ai' }
    if (icon === 'book') { return 'book' }
    if (icon === 'calendar') { return 'calendar' }
    return 'chart'
  }
}
