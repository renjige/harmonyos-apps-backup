import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { SportChallenge, ChallengeProgress } from '../../models/SportModels'
import { SportAnalytics } from '../../services/SportAnalytics'

@Component
export struct ChallengeListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: SportChallenge = new SportChallenge()
  onTap: () => void = () => {}

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Image($r('app.media.hero_sport_bg'))
        .width('100%')
        .height(140)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.xl)
        .opacity(Theme.isDark() ? 0.10 : 0.22)
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().surfaceCard)
        .opacity(Theme.isDark() ? 0.88 : 0.72)
        .borderRadius(Theme.radius.xl)
      Column({ space: Theme.space.s3 }) {
        Row({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.Center }) {
            Column()
              .width(52)
              .height(52)
              .borderRadius(Theme.radius.lg)
              .linearGradient({ angle: 135, colors: Theme.brandGradient() })
            AppIcon({ name: 'chart', iconSize: Theme.icon.lg, color: '#FFFFFF' })
          }
          .width(52)
          .height(52)

          Column({ space: 4 }) {
            Text(this.item.status === 'done' ? '已完成赛季' : '进行中')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
            Text(this.item.title)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textPrimary)
              .maxLines(1)
            Text(`${this.item.sportType} · ${this.item.startDate} 至 ${this.item.endDate}`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
        }
        .width('100%')

        Stack({ alignContent: Alignment.Start }) {
          Column()
            .width('100%')
            .height(10)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.pill)
          Column()
            .width(`${Math.max(4, this.progressPct())}%`)
            .height(10)
            .linearGradient({ angle: 90, colors: Theme.brandGradient() })
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')

        Text(this.progressLabel())
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
      }
      .width('100%')
      .padding(Theme.space.s5)
    }
    .width('100%')
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .shadow({
      radius: 14,
      color: Theme.isDark() ? 'rgba(0,0,0,0.28)' : 'rgba(26,35,50,0.08)',
      offsetY: 6
    })
    .onClick(() => {
      this.onTap()
    })
  }

  private progressPct(): number {
    const p: ChallengeProgress = SportAnalytics.challengeProgress(this.item)
    return p.sessionPct
  }

  private progressLabel(): string {
    const p: ChallengeProgress = SportAnalytics.challengeProgress(this.item)
    return `已完成 ${p.sessions}/${this.item.targetSessions} 次 · ${p.sessionPct}%`
  }
}
