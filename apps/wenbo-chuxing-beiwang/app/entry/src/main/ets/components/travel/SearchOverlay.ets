import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { AppEmpty } from '../design-system/AppEmpty'
import { SearchResultItem } from '../../models/TravelGrowthModels'

@Component
export struct SearchOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop results: SearchResultItem[] = []
  @State keyword: string = ''
  onClose: () => void = () => {}
  onSearch: (keyword: string) => void = () => {}
  onPick: (item: SearchResultItem) => void = () => {}

  aboutToAppear(): void {
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private close(): void {
    AppStorage.setOrCreate('tabBarHidden', false)
    this.onClose()
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Row() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick(() => this.close())
        TextInput({ text: this.keyword, placeholder: '搜索行程、清单、备忘、模板、贴士' })
          .layoutWeight(1)
          .height(44)
          .fontSize(Theme.type.subhead)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.lg)
          .onChange((v: string) => {
            this.keyword = v
            this.onSearch(v)
          })
        Row() {
          AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .padding({ left: 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          if (this.keyword.trim().length === 0) {
            Text('输入关键词搜索全部出行内容')
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
              .padding(Theme.space.s4)
          } else if (this.results.length === 0) {
            AppEmpty({
              title: '未找到相关内容',
              description: '换个关键词，或创建新的行程与备忘',
              actionLabel: '关闭',
              onAction: () => this.close()
            })
          } else {
            ForEach(this.results, (item: SearchResultItem) => {
              Row({ space: Theme.space.s3 }) {
                Column({ space: 4 }) {
                  Text(item.group)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandPrimary)
                  Text(item.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                  Text(item.subtitle)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .maxLines(2)
                    .width('100%')
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
              .onClick(() => this.onPick(item))
            }, (item: SearchResultItem) => `${item.entityType}_${item.id}`)
          }
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
