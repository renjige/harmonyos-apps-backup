import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { MinePage } from './MinePage'
import { FreeDrawOverlay } from '../components/drawing/FreeDrawOverlay'
import { StickerPlayOverlay } from '../components/drawing/StickerPlayOverlay'
import { WorkshopOverlay } from '../components/drawing/WorkshopOverlay'
import { GalleryOverlay } from '../components/drawing/GalleryOverlay'
import { StarRewardOverlay } from '../components/drawing/StarRewardOverlay'
import { StepsGuideOverlay } from '../components/drawing/StepsGuideOverlay'

class TabDef {
  index: number = 0
  icon: AppIconName = 'home'
  label: string = ''

  static all(): TabDef[] {
    const out: TabDef[] = []
    const t0 = new TabDef(); t0.index = 0; t0.icon = 'home'; t0.label = '画室'; out.push(t0)
    const t1 = new TabDef(); t1.index = 1; t1.icon = 'user'; t1.label = '我的'; out.push(t1)
    return out
  }
}

@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State showFreeDraw: boolean = false
  @State showSticker: boolean = false
  @State showWorkshop: boolean = false
  @State showGallery: boolean = false
  @State showSteps: boolean = false
  @State showStars: boolean = false
  @State galleryTick: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false

  private tabs: TabDef[] = TabDef.all()

  private hideBar(hidden: boolean): void {
    AppStorage.setOrCreate('tabBarHidden', hidden)
  }

  private onSaved(): void {
    this.showStars = true
    this.galleryTick += 1
  }

  build() {
    Stack() {
      Column() {
        Column() {
          if (this.current === 0) {
            HomePage({
              onOpenFreeDraw: () => { this.showFreeDraw = true; this.hideBar(true) },
              onOpenSticker: (): void => { this.showSticker = true; this.hideBar(true) },
              onOpenWorkshop: () => { this.showWorkshop = true; this.hideBar(true) },
              onOpenGallery: () => { this.showGallery = true; this.hideBar(true) },
              onOpenSteps: () => { this.showSteps = true; this.hideBar(true) }
            })
          } else {
            MinePage({ refreshToken: this.galleryTick })
          }
        }
        .layoutWeight(1)
        .width('100%')

        if (!this.tabBarHidden) {
          Row() {
            ForEach(this.tabs, (tab: TabDef) => {
              Column({ space: Theme.space.s1 }) {
                AppIcon({ name: tab.icon, iconSize: 24, color: this.current === tab.index ? Theme.colors().brandPrimary : Theme.colors().textSecondary })
                Text(tab.label)
                  .fontSize(12)
                  .fontColor(this.current === tab.index ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
              }
              .layoutWeight(1)
              .height(56)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(this.current === tab.index ? Theme.colors().brandPrimaryContainer : Color.Transparent)
              .borderRadius(Theme.radius.lg)
              .onClick(() => { this.current = tab.index })
            })
          }
          .width('92%')
          .padding(Theme.space.s2)
          .margin({ bottom: Theme.space.s4 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          .shadow({ radius: 12, color: 'rgba(74,74,74,0.08)', offsetY: -4, offsetX: 0 })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.showFreeDraw) {
        FreeDrawOverlay({
          visible: true,
          onClose: (): void => { this.showFreeDraw = false; this.hideBar(false) },
          onSaved: (): void => { this.onSaved() }
        })
          .width('100%')
          .height('100%')
      }

      if (this.showSticker) {
        StickerPlayOverlay({
          visible: true,
          onClose: (): void => { this.showSticker = false; this.hideBar(false) },
          onSaved: (): void => { this.onSaved() }
        })
          .width('100%')
          .height('100%')
      }

      if (this.showWorkshop) {
        WorkshopOverlay({
          visible: true,
          onClose: (): void => { this.showWorkshop = false; this.hideBar(false) },
          onSaved: (): void => { this.onSaved() }
        })
          .width('100%')
          .height('100%')
      }

      if (this.showGallery) {
        GalleryOverlay({
          visible: true,
          onClose: (): void => { this.showGallery = false; this.hideBar(false) }
        })
          .width('100%')
          .height('100%')
      }

      if (this.showSteps) {
        StepsGuideOverlay({
          visible: true,
          onClose: (): void => { this.showSteps = false; this.hideBar(false) }
        })
          .width('100%')
          .height('100%')
      }

      if (this.showStars) {
        StarRewardOverlay({
          visible: true,
          onClose: (): void => { this.showStars = false }
        })
          .width('100%')
          .height('100%')
      }
    }
    .width('100%')
    .height('100%')
  }
}
