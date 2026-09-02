import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { RecipeItem, TermItem, TipItem } from '../models/SolarModels'
import { SolarRecipesBizService } from '../services/SolarRecipesBizService'
import { SolarDetailNav } from '../services/SolarDetailNav'
import { SolarMedia } from '../services/SolarMedia'
import { SolarTermUtil } from '../services/SolarTermUtil'
import { HomeTipsRow } from '../components/recipe/HomeTipsRow'
import { CategoryEmojiUtil } from '../utils/CategoryEmojiUtil'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '节气食谱'
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State currentTerm: TermItem | undefined = undefined
  @State recommends: RecipeItem[] = []
  @State tips: TipItem[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    const termId = SolarTermUtil.currentTermId()
    this.currentTerm = await SolarRecipesBizService.findTerm(termId)
    this.recommends = await SolarRecipesBizService.todayRecommendations(3)
    this.tips = await SolarRecipesBizService.loadTips(termId)
    if (this.tips.length === 0) {
      const allTips = await SolarRecipesBizService.loadTips()
      const sliced: TipItem[] = []
      for (let i = 0; i < allTips.length && i < 4; i++) {
        sliced.push(allTips[i])
      }
      this.tips = sliced
    }
    this.loading = false
  }

  private termTitle(): string {
    if (this.currentTerm !== undefined) {
      return this.currentTerm.title
    }
    return SolarTermUtil.currentTermName()
  }

  build() {
    Column() {
      if (this.loading) {
        AppLoading({ label: '正在准备今日食养' })
      } else if (this.recommends.length === 0) {
        AppEmpty({
          title: '暂无食谱',
          description: '请检查网络后重试',
          actionLabel: '重试',
          emojiMark: '🍲',
          iconName: 'book',
          onAction: (): void => { void this.reload() }
        })
      } else {
        Scroll() {
          Column({ space: Theme.space.s5 }) {
            this.PageHeader()
            this.Hero()
            this.TermCard()
            this.RecommendSection()
            if (this.tips.length > 0) {
              HomeTipsRow({ tips: this.tips })
            }
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            top: Theme.space.s4,
            bottom: Theme.space.s10
          })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  PageHeader() {
    Row({ space: Theme.space.s3 }) {
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width(44)
          .height(44)
          .linearGradient({
            angle: 135,
            colors: [[Theme.colors().brandPrimary, 0], [Theme.colors().brandAccent, 1]]
          })
          .borderRadius(14)
        AppIcon({ name: 'sparkle', iconSize: Theme.icon.md, color: Theme.colors().brandOnPrimary })
      }
      Column({ space: 2 }) {
        Text(`${CategoryEmojiUtil.weekdayMark()} 今日食养`)
          .fontSize(Theme.type.overline)
          .fontColor(Theme.colors().brandAccent)
        Text(CategoryEmojiUtil.dietHint())
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
  }

  @Builder
  Hero() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image($r('app.media.hero_bg'))
        .width('100%')
        .height(180)
        .objectFit(ImageFit.Cover)
      Column()
        .width('100%')
        .height(100)
        .linearGradient({ direction: GradientDirection.Bottom, colors: [['#00000000', 0], ['#CC2C2420', 1]] })
      Column({ space: 4 }) {
        Text(this.appName)
          .fontSize(Theme.type.title1)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
        Text('顺应二十四节气，智慧规划每日食养')
          .fontSize(Theme.type.subhead)
          .fontColor('#FFFFFF')
      }
      .padding({ left: 16, right: 16, bottom: 16 })
      .width('100%')
    }
    .clip(true)
    .borderRadius(Theme.radius.md)
    .width('100%')
  }

  @Builder
  TermCard() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text('🌿 当前节气')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('查看日历')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick(() => {
            AppStorage.setOrCreate('switchTabIndex', 2)
          })
      }
      .width('100%')

      if (this.currentTerm !== undefined) {
        Row({ space: Theme.space.s3 }) {
          Image(SolarMedia.resource(this.currentTerm.coverKey))
            .width(72)
            .height(72)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.sm)
          Column({ space: 4 }) {
            Text(this.termTitle())
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text(`${CategoryEmojiUtil.markForSolarTerm(this.termTitle())} ${this.currentTerm.dateRange}`)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            Text(this.currentTerm.summary)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .maxLines(2)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
        }
        .width('100%')
        .onClick(() => SolarDetailNav.openTerm(this.currentTerm!.id))
      }
    }
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .width('100%')
  }

  @Builder
  RecommendSection() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text('🍲 今日推荐')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('全部食谱')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick(() => {
            AppStorage.setOrCreate('librarySolarTermId', SolarTermUtil.currentTermId())
            AppStorage.setOrCreate('switchTabIndex', 1)
          })
      }
      .width('100%')

      ForEach(this.recommends, (r: RecipeItem) => {
        Row({ space: Theme.space.s3 }) {
          Image(SolarMedia.resource(r.coverKey))
            .width(88)
            .height(88)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.sm)
          Column({ space: 6 }) {
            Text(r.title)
              .fontSize(Theme.type.subtitleM)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .maxLines(1)
            Text(r.summary)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .maxLines(2)
            Text(`${CategoryEmojiUtil.markForEffect(r.effect)} ${r.effect} · ${r.cookingTime}分钟`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandAccent)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding(Theme.space.s3)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.sm)
        .onClick(() => SolarDetailNav.openRecipe(r.id))
      }, (r: RecipeItem) => r.id)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
