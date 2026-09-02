import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppError } from '../components/design-system/AppError'
import { LevelItem, PoemItem } from '../models/PoetryModels'
import { PoetryBizService } from '../services/PoetryBizService'
import { PoetryMedia } from '../services/PoetryMedia'
import { PoetryNav } from '../services/PoetryNav'
import { HuntProgressStore } from '../services/HuntProgressStore'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State poems: PoemItem[] = []
  @State levels: LevelItem[] = []
  @State loading: boolean = true
  @State failed: boolean = false
  @State greeting: string = ''
  @StorageLink('poetryTick') tick: number = 0
  @StorageLink('huntCoins') coins: number = 0
  @StorageLink('huntCleared') cleared: number = 0
  @StorageLink('huntPlaces') places: number = 0

  aboutToAppear(): void {
    this.greeting = HuntProgressStore.greeting()
    void this.reload()
  }

  async reload(): Promise<void> {
    this.loading = true
    this.failed = false
    this.poems = await PoetryBizService.loadPoems()
    this.levels = await PoetryBizService.loadLevels()
    this.loading = false
    this.failed = this.poems.length === 0
  }

  private daily(): PoemItem {
    return PoetryBizService.dailyPoem(this.poems)
  }

  private visibleLevels(): LevelItem[] {
    const out: LevelItem[] = []
    for (const lv of this.levels) {
      if (lv.hidden && !HuntProgressStore.hiddenReady() && !HuntProgressStore.isCleared(lv.id)) {
        continue
      }
      out.push(lv)
    }
    return out
  }

  private nextLevel(): LevelItem {
    const vis = this.visibleLevels()
    for (const lv of vis) {
      if (!HuntProgressStore.isCleared(lv.id)) {
        return lv
      }
    }
    if (vis.length > 0) {
      return vis[0]
    }
    return new LevelItem()
  }

  private startHunt(id: string): void {
    if (id.length === 0) {
      return
    }
    PoetryNav.openHunt(id)
  }

  private rankCount(rank: string): string {
    let total = 0
    let done = 0
    for (const lv of this.levels) {
      if (lv.rankKey !== rank) {
        continue
      }
      total++
      if (HuntProgressStore.isCleared(lv.id)) {
        done++
      }
    }
    return `${done}/${total}`
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Row() {
          Text('诗词寻宝')
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Text(`${this.coins} 诗币`)
            .fontSize(13)
            .fontColor(Theme.colors().brandAccent)
        }
        .width('100%')

        Text(this.greeting)
          .fontSize(14)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')

        Text(PoetryBizService.dailyQuote(this.poems))
          .fontSize(16)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')

        if (this.failed && !this.loading) {
          AppError({
            title: '诗卷暂未展开',
            message: '请检查网络后重试。',
            retryLabel: '重试',
            onRetry: () => { void this.reload() }
          })
        } else if (this.loading && this.poems.length === 0) {
          Text('正在展开今日诗卷…')
            .fontSize(15)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        } else {
          this.DailyCard()
          this.StatRow()
          this.RankBlock()
          this.LevelBlock()
        }
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s5, bottom: Theme.space.s10 })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .align(Alignment.Top)
    .edgeEffect(EdgeEffect.Spring)
  }

  @Builder
  DailyCard() {
    Column() {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(PoetryMedia.cover(this.daily().coverKey.length > 0 ? this.daily().coverKey : 'hero_daily'))
          .width('100%')
          .height(188)
          .objectFit(ImageFit.Cover)
        Column()
          .width('100%')
          .height(188)
          .linearGradient({
            angle: 180,
            colors: [['rgba(26,26,46,0.06)', 0], ['rgba(26,26,46,0.78)', 1]]
          })
        Column({ space: 6 }) {
          Text('今日一诗')
            .fontSize(13)
            .fontColor('#F5F0E8')
          Text(this.daily().title)
            .fontSize(22)
            .fontWeight(FontWeight.Medium)
            .fontColor('#F5F0E8')
          Text(`${this.daily().dynasty} · ${this.daily().author}`)
            .fontSize(13)
            .fontColor('#F5F0E8')
        }
        .padding({ left: 20, right: 20, bottom: 18 })
      }
      .clip(true)
      .borderRadius({ topLeft: 24, topRight: 24 })

      Column({ space: 10 }) {
        Text(this.daily().summary)
          .fontSize(15)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        AppButton({
          label: '进入赏析',
          onTap: () => PoetryNav.openPoem(this.daily().id)
        })
        AppButton({
          label: '开启今日寻宝',
          variant: 'secondary',
          onTap: () => this.startHunt(this.nextLevel().id)
        })
        AppButton({
          label: '学诗匹配',
          variant: 'ghost',
          onTap: () => PoetryNav.setRoute(PoetryNav.MATCH)
        })
      }
      .padding(20)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(24)
    .clip(true)
  }

  @Builder
  StatRow() {
    Row({ space: 10 }) {
      this.MiniStat('已通关', `${this.cleared} 关`)
      this.MiniStat('点亮诗地', `${this.places} 处`)
      this.MiniStat('诗币', `${this.coins}`)
    }
    .width('100%')
  }

  @Builder
  MiniStat(label: string, value: string) {
    Column({ space: 6 }) {
      Text(label)
        .fontSize(12)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
    }
    .layoutWeight(1)
    .padding(14)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(20)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  RankBlock() {
    Text('四境卷轴')
      .fontSize(18)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      .width('100%')
    Row({ space: 8 }) {
      this.RankChip('初窥门径', this.rankCount('beginner'))
      this.RankChip('小有成就', this.rankCount('adept'))
    }
    .width('100%')
    Row({ space: 8 }) {
      this.RankChip('诗林高手', this.rankCount('master'))
      this.RankChip('一代宗师', this.rankCount('grand'))
    }
    .width('100%')
  }

  @Builder
  RankChip(name: string, progress: string) {
    Column({ space: 4 }) {
      Text(name)
        .fontSize(13)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      Text(progress)
        .fontSize(12)
        .fontColor(Theme.colors().brandAccent)
    }
    .layoutWeight(1)
    .padding(12)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(16)
    .border({ width: 1, color: Theme.colors().strokeStrong })
  }

  @Builder
  LevelBlock() {
    Text('闯关目录')
      .fontSize(18)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      .width('100%')
    Column({ space: 10 }) {
      ForEach(this.visibleLevels(), (lv: LevelItem) => {
        Row({ space: 12 }) {
          Column({ space: 4 }) {
            Text(lv.title)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text(HuntProgressStore.isCleared(lv.id) ? '已通关' : lv.summary)
              .fontSize(13)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .maxLines(1)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          Text(HuntProgressStore.isCleared(lv.id) ? '回顾' : '开启')
            .fontSize(13)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding(14)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(18)
        .onClick(() => this.startHunt(lv.id))
      }, (lv: LevelItem) => lv.id)
    }
  }
}
