import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { CottageItem } from '../models/CottageModels'
import { CottageBizService } from '../services/CottageBizService'
import { CottageNav } from '../services/CottageNav'

@Component
export struct QaOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State query: string = ''
  @State results: CottageItem[] = []
  @State disclaimer: string = '仅供参考，建议进一步核实。'
  @State searched: boolean = false
  @State loading: boolean = false

  aboutToAppear(): void {
    void this.loadCatalog()
  }

  private async loadCatalog(): Promise<void> {
    this.loading = true
    const list = await CottageBizService.ask('')
    this.results = list
    this.loading = false
  }

  private async runSearch(): Promise<void> {
    this.loading = true
    this.searched = true
    const list = await CottageBizService.ask(this.query)
    this.results = list
    this.loading = false
  }

  private openRelated(item: CottageItem): void {
    CottageNav.closeOverlay()
    if (item.pathId.length > 0) {
      CottageNav.openPath(item.pathId)
    }
  }

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
        .onClick((): void => { CottageNav.closeOverlay() })
        Text('智慧问答')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Column({ space: Theme.space.s3 }) {
        Text(this.disclaimer)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().warning)
          .width('100%')
          .padding(Theme.space.s3)
          .backgroundColor(Theme.colors().warningContainer)
          .borderRadius(Theme.radius.md)

        TextInput({ text: this.query, placeholder: '输入学习中的疑问，例如：什么是变量' })
          .onChange((v: string) => { this.query = v })
          .width('100%')
        AppButton({
          label: '匹配参考解答',
          onTap: (): void => { void this.runSearch() }
        })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      if (this.loading) {
        Text('正在匹配词条…')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .padding(Theme.space.pageX)
      } else if (this.results.length === 0) {
        AppEmpty({
          title: this.searched ? '没有匹配到词条' : '暂无词条',
          description: '可换个关键词，或去学习路径里按课时阅读'
        })
      } else {
        List() {
          ForEach(this.results, (item: CottageItem) => {
            ListItem() {
              Column({ space: Theme.space.s2 }) {
                Text(item.title)
                  .fontSize(Theme.type.subtitleL)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(item.body.length > 0 ? item.body : item.summary)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .lineHeight(24)
                  .width('100%')
                Text(this.disclaimer)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().warning)
                  .width('100%')
                if (item.pathId.length > 0) {
                  AppButton({
                    label: '查看相关路径',
                    variant: 'secondary',
                    onTap: (): void => { this.openRelated(item) }
                  })
                }
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .border({ width: 1, color: Theme.colors().strokeHairline })
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s3
            })
          }, (item: CottageItem) => item.id)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
