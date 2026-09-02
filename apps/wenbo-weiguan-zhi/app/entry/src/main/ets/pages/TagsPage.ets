import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { MicroEssay, TagCloudItem } from '../models/EssayModels'
import { EssayStore } from '../services/EssayStore'
import { SmartTagService } from '../services/SmartTagService'

@Component
export struct TagsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop reloadToken: number = 0
  @State tags: TagCloudItem[] = []
  @State keyword: string = ''
  @State loading: boolean = true
  @State lastToken: number = -1

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.loading = true
    const essays = await EssayStore.loadAll()
    this.tags = await SmartTagService.buildCloud(essays)
    this.loading = false
  }

  private filteredTags(): TagCloudItem[] {
    const kw = this.keyword.trim()
    if (kw.length === 0) {
      return this.tags
    }
    const out: TagCloudItem[] = []
    for (const t of this.tags) {
      if (t.name.indexOf(kw) >= 0) {
        out.push(t)
      }
    }
    return out
  }

  private fontSizeFor(count: number): number {
    if (count >= 8) {
      return Theme.type.title3
    }
    if (count >= 4) {
      return Theme.type.subhead
    }
    return Theme.type.body
  }

  private selectTag(name: string): void {
    AppStorage.setOrCreate('tagFilter', name)
    AppStorage.setOrCreate('essayTabIndex', 1)
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.cover_tag'))
            .width('100%')
            .height(140)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.lg)
          Column() {
            Blank()
            Text('智慧标签云')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .padding(Theme.space.s4)
              .width('100%')
              .linearGradient({
                angle: 180,
                colors: [['rgba(0,0,0,0)', 0], ['rgba(26,42,58,0.75)', 1]]
              })
          }
          .width('100%')
          .height('100%')
        }
        .width('100%')

        TextInput({ text: this.keyword, placeholder: '搜索标签' })
          .width('100%')
          .height(40)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
          .padding({ left: 12, right: 12 })
          .onChange((v: string) => { this.keyword = v })

        if (this.loading) {
          Text('加载中…')
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        } else if (this.filteredTags().length === 0) {
          AppEmpty({
            title: '暂无标签',
            description: '撰写观察后会智慧提取关键词',
            actionLabel: '',
            onAction: (): void => {}
          })
        } else {
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
            ForEach(this.filteredTags(), (item: TagCloudItem) => {
              Column({ space: 2 }) {
                Text(item.name)
                  .fontSize(this.fontSizeFor(item.count))
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                Text(`${item.count}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textTertiary)
              }
              .padding({ left: 14, right: 14, top: 10, bottom: 10 })
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .border({ width: 1, color: Theme.colors().strokeHairline })
              .margin({ right: 10, bottom: 10 })
              .onClick((): void => { this.selectTag(item.name) })
            }, (item: TagCloudItem) => item.name)
          }
          .width('100%')
        }
      }
      .width('100%')
      .padding(Theme.space.pageX)
      .padding({ bottom: Theme.space.s10 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .edgeEffect(EdgeEffect.Spring)
    .onAppear((): void => {
      void this.load()
    })
  }
}
