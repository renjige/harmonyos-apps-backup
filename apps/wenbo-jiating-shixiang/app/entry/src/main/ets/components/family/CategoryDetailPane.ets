import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { FamilyCategory } from '../../models/FamilyTaskModels'
import { TaskMedia } from '../../services/TaskMedia'
import { CategorySuggest } from '../../services/CategorySuggest'

@Component
export struct CategoryDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: FamilyCategory = new FamilyCategory()
  onAdd: () => void = () => {}
  onClose: () => void = () => {}

  private cover(): string {
    if (this.item.coverKey.length > 0) {
      return this.item.coverKey
    }
    return CategorySuggest.coverKey(this.item.title)
  }

  private bodyText(): string {
    if (this.item.body.length > 0) {
      return this.item.body
    }
    if (this.item.description.length > 0) {
      return this.item.description
    }
    return this.item.summary
  }

  build() {
    Column() {
      Row() {
        AppIcon({ name: 'close', iconSize: 20, color: Theme.colors().brandOnPrimary })
        Blank()
      }
      .width('100%')
      .padding(16)
      .position({ x: 0, y: 0 })
      .zIndex(2)
      .onClick(() => this.onClose())

      Scroll() {
        Column() {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(TaskMedia.cover(this.cover()))
              .width('100%')
              .height(220)
              .objectFit(ImageFit.Cover)
            Column() {
              Text(this.item.title)
                .fontSize(Theme.type.titleM)
                .fontWeight(FontWeight.Bold)
                .fontColor('#F6F1E8')
              Text(this.item.summary)
                .fontSize(Theme.type.bodyS)
                .fontColor('#F6F1E8')
            }
            .width('100%')
            .padding({ left: 20, right: 20, bottom: 20, top: 48 })
            .linearGradient({
              angle: 180,
              colors: [['rgba(26,50,43,0)', 0], ['rgba(26,50,43,0.82)', 1]]
            })
          }
          .clip(true)

          Column({ space: 12 }) {
            Text(this.bodyText())
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
              .padding(16)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
            AppButton({
              label: '添加一件相关事项',
              variant: 'primary',
              onTap: () => this.onAdd()
            })
          }
          .padding({ left: 16, right: 16, top: 16, bottom: Theme.space.s10 })
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
