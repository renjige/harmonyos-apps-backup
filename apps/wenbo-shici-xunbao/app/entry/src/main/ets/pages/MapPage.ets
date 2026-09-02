import { Theme } from '../components/design-system/Theme'
import { AppError } from '../components/design-system/AppError'
import { PlaceItem } from '../models/PoetryModels'
import { PoetryBizService } from '../services/PoetryBizService'
import { PoetryMedia } from '../services/PoetryMedia'
import { PoetryNav } from '../services/PoetryNav'
import { HuntProgressStore } from '../services/HuntProgressStore'

@Component
export struct MapPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State places: PlaceItem[] = []
  @State loading: boolean = true
  @State failed: boolean = false
  @StorageLink('poetryTick') tick: number = 0

  aboutToAppear(): void {
    void this.reload()
  }

  async reload(): Promise<void> {
    this.loading = true
    this.failed = false
    this.places = await PoetryBizService.loadPlaces()
    this.loading = false
    this.failed = this.places.length === 0
  }

  private leftPct(p: PlaceItem): number {
    const x = p.mapX
    if (x < 6) {
      return 6
    }
    if (x > 90) {
      return 90
    }
    return x
  }

  private topPct(p: PlaceItem): number {
    const y = p.mapY
    if (y < 8) {
      return 8
    }
    if (y > 88) {
      return 88
    }
    return y
  }

  build() {
    Column() {
      Text('诗词地图')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .padding({ left: 20, right: 20, top: 16 })
      Text('水墨示意地图，点亮鎏金标记可阅读诗地故事')
        .fontSize(13)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
        .padding({ left: 20, right: 20, bottom: 8 })

      if (this.failed && !this.loading) {
        AppError({
          title: '诗地暂未载入',
          message: '请检查网络后重试。',
          retryLabel: '重试',
          onRetry: () => { void this.reload() }
        })
      } else {
        Stack() {
          Image($r('app.media.hero_map'))
            .width('100%')
            .height(360)
            .objectFit(ImageFit.Cover)
            .borderRadius(20)
          Column()
            .width('100%')
            .height(360)
            .linearGradient({
              angle: 180,
              colors: [['rgba(26,26,46,0.12)', 0], ['rgba(26,26,46,0.28)', 1]]
            })
            .borderRadius(20)
          ForEach(this.places, (p: PlaceItem) => {
            Column() {
              Column()
                .width(HuntProgressStore.isPlaceOn(p.id) ? 14 : 10)
                .height(HuntProgressStore.isPlaceOn(p.id) ? 14 : 10)
                .borderRadius(Theme.radius.pill)
                .backgroundColor(HuntProgressStore.isPlaceOn(p.id) ? '#C9A84C' : '#F5F0E8')
                .border({ width: 1, color: '#1A1A2E' })
              Text(p.title)
                .fontSize(10)
                .fontColor('#F5F0E8')
                .maxLines(1)
            }
            .position({ x: `${this.leftPct(p)}%`, y: `${this.topPct(p)}%` })
            .onClick(() => PoetryNav.openPlace(p.id))
          }, (p: PlaceItem) => p.id)
        }
        .width('100%')
        .height(360)
        .margin({ left: 16, right: 16 })
        .clip(true)
        .borderRadius(20)

        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.places, (p: PlaceItem) => {
              Row() {
                Image(PoetryMedia.cover(p.coverKey))
                  .width(56)
                  .height(56)
                  .borderRadius(12)
                  .objectFit(ImageFit.Cover)
                Column({ space: 4 }) {
                  Text(p.title)
                    .fontSize(16)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .fontWeight(FontWeight.Medium)
                  Text(HuntProgressStore.isPlaceOn(p.id) ? `${p.region} · 已点亮` : `${p.region} · 待点亮`)
                    .fontSize(13)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                .padding({ left: 12 })
              }
              .width('100%')
              .padding(12)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(16)
              .onClick(() => PoetryNav.openPlace(p.id))
            }, (p: PlaceItem) => `row-${p.id}`)
          }
          .padding({ left: 16, right: 16, top: 12, bottom: 32 })
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
