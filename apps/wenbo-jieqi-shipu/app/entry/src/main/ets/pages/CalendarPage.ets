import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { TermItem } from '../models/SolarModels'
import { SolarRecipesBizService } from '../services/SolarRecipesBizService'
import { SolarDetailNav } from '../services/SolarDetailNav'
import { SolarMedia } from '../services/SolarMedia'
import { SolarTermUtil } from '../services/SolarTermUtil'
import { CategoryEmojiUtil } from '../utils/CategoryEmojiUtil'
import { AppIcon } from '../components/design-system/AppIcon'

@Component
export struct CalendarPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State terms: TermItem[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.terms = await SolarRecipesBizService.loadTerms()
    this.loading = false
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Row({ space: Theme.space.s3 }) {
        Stack({ alignContent: Alignment.Center }) {
          Column()
            .width(40)
            .height(40)
            .linearGradient({
              angle: 135,
              colors: [[Theme.colors().brandAccent, 0], [Theme.colors().brandPrimary, 1]]
            })
            .borderRadius(12)
          AppIcon({ name: 'calendar', iconSize: Theme.icon.sm, color: Theme.colors().brandOnPrimary })
        }
        Column({ space: 2 }) {
          Text('📅 节气日历')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text(`当前：${SolarTermUtil.currentTermName()} · ${CategoryEmojiUtil.dietHint()}`)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

      Image($r('app.media.banner_03'))
        .width('100%')
        .height(72)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.md)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

      if (this.loading) {
        AppLoading({ label: '正在加载二十四节气' })
      } else if (this.terms.length === 0) {
        AppEmpty({
          title: '暂无节气数据',
          description: '请检查网络后重试',
          actionLabel: '重试',
          emojiMark: '📅',
          iconName: 'calendar',
          onAction: (): void => { void this.reload() }
        })
      } else {
        Grid() {
          ForEach(this.terms, (t: TermItem) => {
            GridItem() {
              this.TermCell(t)
            }
          }, (t: TermItem) => t.id)
        }
        .columnsTemplate('1fr 1fr 1fr')
        .columnsGap(10)
        .rowsGap(10)
        .layoutWeight(1)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s8 })
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  TermCell(t: TermItem) {
    Column({ space: 6 }) {
      Stack({ alignContent: Alignment.TopEnd }) {
        Image(SolarMedia.resource(t.coverKey))
          .width('100%')
          .height(72)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.sm)
        if (SolarTermUtil.isCurrentTerm(t.id)) {
          Text('今')
            .fontSize(10)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .margin({ top: 4, right: 4 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
      }
      .width('100%')

      Text(t.title)
        .fontSize(Theme.type.subtitleS)
        .fontWeight(SolarTermUtil.isCurrentTerm(t.id) ? FontWeight.Bold : FontWeight.Medium)
        .fontColor(SolarTermUtil.isCurrentTerm(t.id) ? Theme.colors().brandPrimary : Theme.colors().textPrimary)
        .maxLines(1)
      Text(`${CategoryEmojiUtil.markForSolarTerm(t.title)} ${t.dateRange}`)
        .fontSize(10)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .maxLines(1)
    }
    .padding(8)
    .backgroundColor(SolarTermUtil.isCurrentTerm(t.id) ? Theme.colors().brandPrimaryContainer : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .border({
      width: SolarTermUtil.isCurrentTerm(t.id) ? 2 : 1,
      color: SolarTermUtil.isCurrentTerm(t.id) ? Theme.colors().brandPrimary : Theme.colors().strokeHairline
    })
    .onClick(() => SolarDetailNav.openTerm(t.id))
  }
}
