import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { InspectGuide, GuideItem } from '../../models/InspectGuide'
import { InspectCatalog, InspectMedia, MaterialCategory } from '../../models/InspectModels'
import { InspectNav } from '../../services/InspectNav'
import { InspectLocalStore } from '../../services/InspectLocalStore'

@Component
export struct GuideOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop category: string = '瓷砖'
  @State current: string = '瓷砖'

  aboutToAppear(): void {
    this.current = this.category.length > 0 ? this.category : '瓷砖'
  }

  private item(): GuideItem {
    return InspectGuide.of(this.current)
  }

  build() {
    Column() {
      Row() {
        Row() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
            .rotate({ angle: 180 })
          Text('返回')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .margin({ left: 2 })
        }
        .height(44)
        .onClick(() => InspectNav.closeExtra())
        Text('品类验收要点')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Blank().width(56)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 8, bottom: 8 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(InspectCatalog.all(), (cat: MaterialCategory) => {
              Text(cat.title)
                .fontSize(Theme.type.caption)
                .fontColor(this.current === cat.title ? Theme.chipFg(true) : Theme.chipFg(false))
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .margin({ right: 8, bottom: 8 })
                .backgroundColor(this.current === cat.title ? Theme.chipBg(true) : Theme.chipBg(false))
                .borderRadius(Theme.radius.pill)
                .onClick(() => { this.current = cat.title })
            }, (cat: MaterialCategory) => cat.id)
          }
          .width('100%')
          Image(InspectMedia.cover(this.item().category))
            .width('100%')
            .height(140)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.card)
          Text(this.item().category)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text(this.item().summary)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          this.point('1', this.item().point1)
          this.point('2', this.item().point2)
          this.point('3', this.item().point3)
          Text(`专项核对：${this.item().extraA}、${this.item().extraB}`)
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          AppButton({
            label: '按此要点开始验收',
            onTap: () => {
              void InspectLocalStore.setDefaultCategory(this.item().category)
              const mode = AppStorage.get<string>('inspectNavMode')
              InspectNav.closeExtra()
              if (mode === undefined || mode.length === 0) {
                InspectNav.openCreate()
              }
            }
          })
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  point(no: string, text: string) {
    Row({ space: 10 }) {
      Text(no)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().brandOnPrimary)
        .width(24)
        .height(24)
        .textAlign(TextAlign.Center)
        .backgroundColor(Theme.colors().brandPrimary)
        .borderRadius(12)
      Text(text)
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .layoutWeight(1)
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .border({ width: 1, color: Theme.colors().strokeStrong })
  }
}
