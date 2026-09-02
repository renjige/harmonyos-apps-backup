import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { WrongItem } from '../../models/MathModels'

@Component
export struct WrongBookOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop items: WrongItem[] = []
  onClose: () => void = () => {}
  onRetryOne: (item: WrongItem) => void = (_item: WrongItem) => {}
  onRetryAll: () => void = () => {}

  build() {
    Column() {
      Row() {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.onClose())
        Text('我的错题')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Blank().width(44)
      }
      .width('100%')
      .padding({ left: Theme.space.s2, right: Theme.space.s2, top: Theme.space.s2 })

      if (this.items.length === 0) {
        Column() {
          AppEmpty({
            title: '太棒啦！',
            description: '目前没有需要复习的题目'
          })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .width('100%')
      } else {
        List() {
          ForEach(this.items, (item: WrongItem) => {
            ListItem() {
              Column({ space: Theme.space.s3 }) {
                Text(item.expression)
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(`上次答案：${item.userAnswer}`)
                  .fontSize(Theme.type.footnote)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
                Text(`正确答案：${item.correctAnswer}`)
                  .fontSize(Theme.type.footnote)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                AppButton({
                  label: '再算一次',
                  variant: 'secondary',
                  onTap: () => this.onRetryOne(item)
                })
              }
              .width('100%')
              .padding(Theme.space.s5)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
              .margin({ bottom: Theme.space.s3 })
            }
          }, (item: WrongItem) => item.id)
        }
        .layoutWeight(1)
        .padding({ left: Theme.space.s5, right: Theme.space.s5, top: Theme.space.s3 })
        .scrollBar(BarState.Off)
        Column() {
          AppButton({ label: '全部再算一次', onTap: () => this.onRetryAll() })
        }
        .padding({ left: Theme.space.s5, right: Theme.space.s5, bottom: Theme.space.s7 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
