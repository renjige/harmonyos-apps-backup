import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { SearchHit } from '../models/LifeGrowthModels'
import { LifeTag } from '../models/LifeHubModels'
import { LifeGrowthService } from '../services/LifeGrowthService'
import { LifeHubStore } from '../services/LifeHubStore'
import { LifeHubNav } from '../services/LifeHubNav'
import { JournalDetailNav } from '../services/JournalDetailNav'

class KindChip {
  id: string = ''
  label: string = ''

  constructor(id: string, label: string) {
    this.id = id
    this.label = label
  }
}

@Component
export struct SearchHubPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('currentUsername') currentUsername: string = ''
  @State query: string = ''
  @State kind: string = ''
  @State tag: string = ''
  @State hits: SearchHit[] = []
  @State tags: LifeTag[] = []
  @State searched: boolean = false
  private kinds: KindChip[] = [
    new KindChip('', '全部'),
    new KindChip('diary', '笺语'),
    new KindChip('todo', '待办'),
    new KindChip('habit', '习惯'),
    new KindChip('plan', '计划'),
    new KindChip('fav', '收藏')
  ]

  aboutToAppear(): void {
    void this.boot()
  }

  private async boot(): Promise<void> {
    this.tags = await LifeHubStore.loadTags()
    await this.runSearch()
  }

  private async runSearch(): Promise<void> {
    this.hits = await LifeGrowthService.searchAll(this.currentUsername, this.query, this.kind, this.tag)
    this.searched = true
  }

  private open(hit: SearchHit): void {
    if (hit.kind === 'diary') {
      JournalDetailNav.openDiary(hit.refId)
      return
    }
    if (hit.kind === 'todo') {
      LifeHubNav.open('todos', true)
      return
    }
    if (hit.kind === 'habit') {
      LifeHubNav.open('habits', true)
      return
    }
    if (hit.kind === 'plan') {
      LifeHubNav.open('plans', true)
      return
    }
    LifeHubNav.close()
    AppStorage.setOrCreate('pendingOpenFavorites', 1)
  }

  private kindLabel(kind: string): string {
    if (kind === 'diary') {
      return '笺语'
    }
    if (kind === 'todo') {
      return '待办'
    }
    if (kind === 'habit') {
      return '习惯'
    }
    if (kind === 'plan') {
      return '计划'
    }
    return '收藏'
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
        .onClick((): void => { LifeHubNav.backOrClose() })
        Column({ space: 2 }) {
          Text('全文检索')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text('笺语、待办、习惯、计划与收藏')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Column({ space: Theme.space.s3 }) {
        Row({ space: Theme.space.s2 }) {
          TextInput({ text: this.query, placeholder: '输入关键词，可留空只看分类' })
            .layoutWeight(1)
            .height(44)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .onChange((v: string) => { this.query = v })
          Column() {
            AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().brandOnPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.lg)
          .onClick((): void => { void this.runSearch() })
        }
        .width('100%')

        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.kinds, (c: KindChip) => {
            Text(c.label)
              .fontSize(Theme.type.caption)
              .fontColor(this.kind === c.id ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .backgroundColor(this.kind === c.id ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.pill)
              .margin({ right: 8, bottom: 8 })
              .onClick((): void => {
                this.kind = c.id
                void this.runSearch()
              })
          }, (c: KindChip) => `k_${c.id}`)
        }
        .width('100%')

        Flex({ wrap: FlexWrap.Wrap }) {
          Text('全部标签')
            .fontSize(Theme.type.caption)
            .fontColor(this.tag.length === 0 ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .backgroundColor(this.tag.length === 0 ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.pill)
            .margin({ right: 8, bottom: 8 })
            .onClick((): void => {
              this.tag = ''
              void this.runSearch()
            })
          ForEach(this.tags, (t: LifeTag) => {
            Text(t.name)
              .fontSize(Theme.type.caption)
              .fontColor(this.tag === t.name ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .backgroundColor(this.tag === t.name ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              .margin({ right: 8, bottom: 8 })
              .onClick((): void => {
                this.tag = t.name
                void this.runSearch()
              })
          }, (t: LifeTag) => t.id)
        }
        .width('100%')
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      if (this.searched && this.hits.length === 0) {
        Column() {
          AppEmpty({
            title: '没有匹配的内容',
            description: '换个词，或改成「全部」再试。写下的笺语和待办都会出现在这里。',
            actionLabel: '',
            onAction: (): void => {}
          })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.hits, (hit: SearchHit) => {
              Column({ space: 4 }) {
                Text(`${this.kindLabel(hit.kind)} · ${hit.title}`)
                  .fontSize(Theme.type.subhead)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(hit.subtitle)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .alignItems(HorizontalAlign.Start)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .onClick((): void => { this.open(hit) })
            }, (hit: SearchHit) => hit.id)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
