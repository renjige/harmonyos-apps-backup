import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import {
  WardrobeOutfitModel,
  WardrobeLookLogModel,
  WardrobeTipModel,
  WardrobeItemModel
} from '../models/WardrobeModels'
import { WardrobeLocalStore } from '../services/WardrobeLocalStore'
import { WardrobeBizService } from '../services/WardrobeBizService'
import { OutfitEngine } from '../services/OutfitEngine'
import { WardrobeMedia } from '../services/WardrobeMedia'
import { OutfitCard } from '../components/outfit/OutfitCard'

@Component
export struct OutfitPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onRequireAuth?: () => void

  @State weather: string = '晴'
  @State scene: string = '日常'
  @State style: string = '清爽'
  @State currentOutfit: WardrobeOutfitModel = new WardrobeOutfitModel()
  @State isSaved: boolean = false
  @State savedOutfits: WardrobeOutfitModel[] = []
  @State tips: WardrobeTipModel[] = []
  @State toastText: string = ''
  @State showSavedList: boolean = false
  @State selectedTip?: WardrobeTipModel = undefined

  aboutToAppear(): void {
    const prefStyle = AppStorage.get<string>('pref_default_style') || '清爽'
    const prefScene = AppStorage.get<string>('pref_default_scene') || '日常'
    this.style = prefStyle
    this.scene = prefScene

    this.generateNewOutfit()
    this.loadTips()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => {
      this.toastText = ''
    }, 2500)
  }

  private async loadTips(): Promise<void> {
    this.tips = await WardrobeBizService.loadTips()
    this.savedOutfits = WardrobeLocalStore.getSavedOutfits()
  }

  private generateNewOutfit(): void {
    const outfit = OutfitEngine.generateOutfit(this.weather, this.scene, this.style)
    this.currentOutfit = outfit
    this.isSaved = outfit.isSaved
  }

  private handleToggleSave(targetOutfit: WardrobeOutfitModel): void {
    targetOutfit.isSaved = !targetOutfit.isSaved
    this.isSaved = targetOutfit.isSaved
    WardrobeLocalStore.saveOutfit(targetOutfit)
    this.savedOutfits = WardrobeLocalStore.getSavedOutfits()
    this.showToast(this.isSaved ? '搭配已保存至我的收藏' : '已取消保存')
  }

  private handleLogToday(targetOutfit: WardrobeOutfitModel): void {
    const today = new Date().toISOString().slice(0, 10)
    const items: string[] = []
    if (targetOutfit.dressName && targetOutfit.dressName.length > 0) {
      items.push(targetOutfit.dressName)
    } else {
      if (targetOutfit.topName) items.push(targetOutfit.topName)
      if (targetOutfit.bottomName) items.push(targetOutfit.bottomName)
    }
    if (targetOutfit.shoesName) items.push(targetOutfit.shoesName)
    if (targetOutfit.accessoryName) items.push(targetOutfit.accessoryName)

    const log = new WardrobeLookLogModel(
      'log_' + Date.now().toString(36),
      today,
      targetOutfit.id,
      targetOutfit.title,
      items,
      targetOutfit.style,
      targetOutfit.scene,
      '清爽自在'
    )

    WardrobeLocalStore.addLookLog(log)
    this.showToast('已成功记录今日穿搭，已同步至日历')
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          // 1. Top Header
          Row() {
            Column({ space: 2 }) {
              Text('今日穿搭')
                .fontSize(Theme.type.title1)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)

              Text('今天，穿一点喜欢的')
                .fontSize(Theme.type.caption1)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .alignItems(HorizontalAlign.Start)

            Blank()

            // Saved Outfits Toggle Button
            Row({ space: 4 }) {
              AppIcon({ name: 'ai', iconSize: 14, color: Theme.colors().brandPrimary })
              Text(`已收藏 (${this.savedOutfits.length})`)
                .fontSize(Theme.type.caption1)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            }
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .backgroundColor(Theme.isDark() ? '#1C332D' : '#DDF2EB')
            .borderRadius(Theme.radius.pill)
            .onClick(() => { this.showSavedList = true })
          }
          .width('100%')
          .padding({ top: Theme.space.s4 })

          // 2. Filter Selector Bar (Weather / Scene / Style)
          Column({ space: Theme.space.s3 }) {
            // Weather
            Row({ space: 8 }) {
              Text('天气')
                .fontSize(Theme.type.caption1)
                .fontColor(Theme.colors().textTertiary)
                .width(36)

              ForEach(WardrobeMedia.WEATHERS, (w: string) => {
                Row({ space: 4 }) {
                  AppIcon({
                    name: WardrobeMedia.getWeatherIcon(w),
                    iconSize: 12,
                    color: this.weather === w ? '#FFFFFF' : Theme.colors().textSecondary
                  })
                  Text(w)
                    .fontSize(Theme.type.caption1)
                    .fontColor(this.weather === w ? '#FFFFFF' : Theme.colors().textPrimary)
                }
                .padding({ left: 10, right: 10, top: 5, bottom: 5 })
                .backgroundColor(this.weather === w ? Theme.colors().brandPrimary : (Theme.isDark() ? '#22302D' : '#EEF5F2'))
                .borderRadius(Theme.radius.pill)
                .onClick(() => {
                  this.weather = w
                  this.generateNewOutfit()
                })
              }, (w: string) => w)
            }
            .width('100%')

            // Scene
            Row({ space: 8 }) {
              Text('场景')
                .fontSize(Theme.type.caption1)
                .fontColor(Theme.colors().textTertiary)
                .width(36)

              ForEach(WardrobeMedia.SCENES, (sc: string) => {
                Text(sc)
                  .fontSize(Theme.type.caption1)
                  .fontColor(this.scene === sc ? '#FFFFFF' : Theme.colors().textPrimary)
                  .padding({ left: 10, right: 10, top: 5, bottom: 5 })
                  .backgroundColor(this.scene === sc ? Theme.colors().brandSecondary : (Theme.isDark() ? '#22302D' : '#EEF5F2'))
                  .borderRadius(Theme.radius.pill)
                  .onClick(() => {
                    this.scene = sc
                    this.generateNewOutfit()
                  })
              }, (sc: string) => sc)
            }
            .width('100%')

            // Style
            Row({ space: 8 }) {
              Text('风格')
                .fontSize(Theme.type.caption1)
                .fontColor(Theme.colors().textTertiary)
                .width(36)

              ForEach(WardrobeMedia.STYLES, (st: string) => {
                Text(st)
                  .fontSize(Theme.type.caption1)
                  .fontColor(this.style === st ? '#FFFFFF' : Theme.colors().textPrimary)
                  .padding({ left: 10, right: 10, top: 5, bottom: 5 })
                  .backgroundColor(this.style === st ? Theme.colors().brandPrimary : (Theme.isDark() ? '#22302D' : '#EEF5F2'))
                  .borderRadius(Theme.radius.pill)
                  .onClick(() => {
                    this.style = st
                    this.generateNewOutfit()
                  })
              }, (st: string) => st)
            }
            .width('100%')
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .shadow({
            radius: 8,
            color: Theme.isDark() ? 'rgba(0,0,0,0.3)' : 'rgba(10,37,64,0.04)',
            offsetY: 1
          })

          // 3. Main Outfit Card
          OutfitCard({
            outfit: this.currentOutfit,
            onRefresh: () => this.generateNewOutfit(),
            onToggleSave: (o: WardrobeOutfitModel) => this.handleToggleSave(o),
            onLogToday: (o: WardrobeOutfitModel) => this.handleLogToday(o)
          })

          // 4. Styling Inspiration Tips section
          Column({ space: Theme.space.s3 }) {
            Row() {
              Row({ space: 4 }) {
                AppIcon({ name: 'sparkle', iconSize: 16, color: Theme.colors().brandPrimary })
                Text('智慧穿搭小贴士')
                  .fontSize(Theme.type.callout)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              }
              Blank()
              Text('灵感参考')
                .fontSize(Theme.type.caption2)
                .fontColor(Theme.colors().textTertiary)
            }
            .width('100%')

            ForEach(this.tips, (tip: WardrobeTipModel) => {
              Column({ space: 4 }) {
                Row() {
                  Text(tip.title)
                    .fontSize(Theme.type.subheadline)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)

                  Blank()

                  Text(tip.category)
                    .fontSize(Theme.type.caption2)
                    .fontColor(Theme.colors().brandSecondary)
                    .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                    .backgroundColor(Theme.isDark() ? '#1C332D' : '#DDF2EB')
                    .borderRadius(Theme.radius.xs)
                }
                .width('100%')

                Text(tip.summary)
                  .fontSize(Theme.type.caption1)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .lineHeight(18)
              }
              .alignItems(HorizontalAlign.Start)
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(Theme.isDark() ? '#1A2926' : '#F7FAF8')
              .borderRadius(Theme.radius.sm)
              .onClick(() => { this.selectedTip = tip })
            }, (tip: WardrobeTipModel) => tip.id)
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .shadow({
            radius: 12,
            color: Theme.isDark() ? 'rgba(0,0,0,0.3)' : 'rgba(10,37,64,0.05)',
            offsetY: 2
          })
        }
        .padding({
          left: Theme.space.pagePadding,
          right: Theme.space.pagePadding,
          bottom: 40
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfaceBackground)

      // Saved Outfits Overlay
      if (this.showSavedList) {
        Stack({ alignContent: Alignment.Bottom }) {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor(Theme.colors().surfaceMask)
            .onClick(() => { this.showSavedList = false })

          Column({ space: Theme.space.s3 }) {
            Row() {
              Text('已保存的搭配')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)

              Blank()

              Row() {
                AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
              }
              .padding(8)
              .onClick(() => { this.showSavedList = false })
            }
            .width('100%')

            Scroll() {
              Column({ space: Theme.space.s3 }) {
                if (this.savedOutfits.length === 0) {
                  AppEmpty({
                    title: '暂无保存的穿搭',
                    description: '在智慧穿搭卡片点击「保存穿搭」，收藏你心仪的日常搭配。'
                  })
                } else {
                  ForEach(this.savedOutfits, (outfit: WardrobeOutfitModel) => {
                    Column({ space: 4 }) {
                      Row() {
                        Text(outfit.title)
                          .fontSize(Theme.type.subheadline)
                          .fontWeight(FontWeight.Bold)
                          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                        Blank()
                        Text(`${outfit.style} · ${outfit.scene}`)
                          .fontSize(Theme.type.caption2)
                          .fontColor(Theme.colors().brandSecondary)
                      }
                      .width('100%')

                      Text([outfit.topName, outfit.bottomName, outfit.shoesName, outfit.accessoryName].filter((x) => x && x.length > 0).join(' ＋ '))
                        .fontSize(Theme.type.caption1)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    }
                    .alignItems(HorizontalAlign.Start)
                    .width('100%')
                    .padding(Theme.space.s3)
                    .backgroundColor(Theme.isDark() ? '#1A2926' : '#F7FAF8')
                    .borderRadius(Theme.radius.sm)
                    .onClick(() => {
                      this.currentOutfit = outfit
                      this.isSaved = true
                      this.showSavedList = false
                    })
                  }, (outfit: WardrobeOutfitModel) => outfit.id)
                }
              }
              .padding({ bottom: Theme.space.s6 })
            }
            .layoutWeight(1)
          }
          .width('100%')
          .constraintSize({ maxHeight: '75%' })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          .padding(Theme.space.cardPadding)
        }
        .width('100%')
        .height('100%')
      }

      // Tip Detail Dialog Overlay
      if (this.selectedTip) {
        Stack({ alignContent: Alignment.Center }) {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor(Theme.colors().surfaceMask)
            .onClick(() => { this.selectedTip = undefined })

          Column({ space: Theme.space.s3 }) {
            Row() {
              Text(this.selectedTip.title)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .layoutWeight(1)

              Row() {
                AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
              }
              .padding(4)
              .onClick(() => { this.selectedTip = undefined })
            }
            .width('100%')

            Text(this.selectedTip.content)
              .fontSize(Theme.type.callout)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .lineHeight(22)
              .width('100%')

            Row() {
              AppButton({
                label: '我知道了',
                variant: 'primary',
                onTap: () => { this.selectedTip = undefined }
              })
            }
            .width('100%')
            .margin({ top: Theme.space.s2 })
          }
          .width('88%')
          .padding(Theme.space.s6)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .shadow({ radius: 24, color: 'rgba(0,0,0,0.25)', offsetY: 4 })
        }
        .width('100%')
        .height('100%')
      }

      // Toast Notification
      if (this.toastText.length > 0) {
        Column() {
          Row({ space: 8 }) {
            AppIcon({ name: 'check', iconSize: 16, color: '#FFFFFF' })
            Text(this.toastText)
              .fontSize(Theme.type.subheadline)
              .fontColor('#FFFFFF')
          }
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(31,41,39,0.92)')
          .borderRadius(Theme.radius.pill)
          .shadow({ radius: 12, color: 'rgba(0,0,0,0.25)', offsetY: 4 })
        }
        .width('100%')
        .padding({ top: 30 })
        .alignItems(HorizontalAlign.Center)
        .hitTestBehavior(HitTestMode.None)
      }
    }
    .width('100%')
    .height('100%')
  }
}
