import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { MoveListCard } from '../components/tuce/MoveListCard'
import { MoveItem } from '../models/TuceModels'
import { MoveLibrary } from '../services/MoveLibrary'
import { TuceStore } from '../services/TuceStore'
import { TuceMedia } from '../services/TuceMedia'
import { TuceNav } from '../services/TuceNav'
import { AppIcon } from '../components/design-system/AppIcon'

@Component
export struct CatalogPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('tuceReload') @Watch('onReload') reloadToken: number = 0
  @State category: string = '热身'
  @State moves: MoveItem[] = []
  @State cats: string[] = []
  @State mode: number = 0
  @State query: string = ''
  @State favIds: string[] = []

  aboutToAppear(): void {
    void this.init()
  }

  onReload(): void {
    void this.init()
  }

  private async init(): Promise<void> {
    this.cats = MoveLibrary.categories()
    this.favIds = await TuceStore.favIds()
    this.applyFilter()
  }

  private pick(cat: string): void {
    this.category = cat
    this.mode = 0
    this.applyFilter()
  }

  private applyFilter(): void {
    let list: MoveItem[] = []
    if (this.mode === 1) {
      for (const id of this.favIds) {
        const m = MoveLibrary.find(id)
        if (m !== undefined) {
          list.push(m)
        }
      }
    } else {
      list = MoveLibrary.byCategory(this.category)
    }
    if (this.query.length > 0) {
      const q = this.query.trim()
      const filtered: MoveItem[] = []
      for (const m of list) {
        if (m.name.indexOf(q) >= 0 || m.bodyPart.indexOf(q) >= 0) {
          filtered.push(m)
        }
      }
      list = filtered
    }
    this.moves = list
  }

  build() {
    Column() {
      AppHeader({ title: '运动图鉴', subtitle: `${MoveLibrary.all().length} 个动作 · 收藏后可编排方案` })
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          Row({ space: Theme.space.s2 }) {
            Row({ space: Theme.space.s2 }) {
              AppIcon({ name: 'search', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
              TextInput({ text: this.query, placeholder: '搜索动作或部位' })
                .layoutWeight(1)
                .backgroundColor('transparent')
                .onChange((v: string): void => {
                  this.query = v
                  this.applyFilter()
                })
            }
            .layoutWeight(1)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.pill)
          }
          .width('100%')

          Row({ space: Theme.space.s2 }) {
            Text('分类浏览')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.mode === 0 ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
              .padding({ left: 14, right: 14, top: 8, bottom: 8 })
              .backgroundColor(this.mode === 0 ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { this.mode = 0; this.applyFilter() })
            Text(`我的收藏 (${this.favIds.length})`)
              .fontSize(Theme.type.bodyS)
              .fontColor(this.mode === 1 ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
              .padding({ left: 14, right: 14, top: 8, bottom: 8 })
              .backgroundColor(this.mode === 1 ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { void this.showFavs() })
          }
          .width('100%')

          if (this.mode === 0) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(TuceMedia.cover(MoveLibrary.coverKeyOf(this.category)))
                .width('100%')
                .height(160)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.lg)
              Column({ space: 4 }) {
                Text(this.category)
                  .fontSize(Theme.type.title2)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                Text(`${this.moves.length} 个动作可练`)
                  .fontSize(Theme.type.caption)
                  .fontColor('#FFFFFF')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .linearGradient({
                angle: 180,
                colors: [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0.75)', 1]]
              })
            }
            .width('100%')
            .height(160)

            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.cats, (c: string) => {
                Text(c)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.category === c ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                  .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                  .margin({ right: 8, bottom: 8 })
                  .backgroundColor(this.category === c ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { this.pick(c) })
              }, (c: string) => c)
            }
            .width('100%')
          }

          ForEach(this.moves, (m: MoveItem) => {
            MoveListCard({
              moveId: m.id,
              name: m.name,
              meta: `${m.bodyPart} · ${m.level} · ${m.minutes} 分钟`,
              coverKey: m.coverKey
            })
          }, (m: MoveItem) => m.id)

          if (this.moves.length === 0) {
            Text(this.mode === 1 ? '还没有收藏，点进动作详情即可收藏' : '没有匹配的动作')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
              .textAlign(TextAlign.Center)
              .padding(Theme.space.s6)
          }
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  private async showFavs(): Promise<void> {
    this.mode = 1
    this.favIds = await TuceStore.favIds()
    this.applyFilter()
  }
}
