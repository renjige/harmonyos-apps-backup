import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { ReadingDetailNav } from '../../services/ReadingDetailNav'

/** 详情数据不存在时仍保留顶栏返回，避免 Overlay 卡死 */
@Component
export struct DetailMissingPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = '详情'
  @Prop emptyTitle: string = '内容不存在'
  @Prop emptyDescription: string = '可能已被删除或网络异常'

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { ReadingDetailNav.close() })
        Text(this.title)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Column() {
        AppEmpty({
          title: this.emptyTitle,
          description: this.emptyDescription,
          actionLabel: '返回',
          onAction: (): void => { ReadingDetailNav.close() }
        })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
