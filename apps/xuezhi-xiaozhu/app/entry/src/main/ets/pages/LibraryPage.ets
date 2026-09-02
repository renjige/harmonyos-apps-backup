import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppError } from '../components/design-system/AppError'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppIcon } from '../components/design-system/AppIcon'
import { CardGridTile } from '../components/cottage/CottageCards'
import { CottageItem } from '../models/CottageModels'
import { CottageBizService } from '../services/CottageBizService'
import { CottageNav } from '../services/CottageNav'

class DomainChip {
  id: string = ''
  label: string = ''
}

@Component
export struct LibraryPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State cards: CottageItem[] = []
  @State domains: CottageItem[] = []
  @State chips: DomainChip[] = []
  @State query: string = ''
  @State filter: string = ''
  @State loading: boolean = true
  @State failed: boolean = false
  @StorageLink('cottageTick') tick: number = 0

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.failed = false
    const domainList = await CottageBizService.loadDomains()
    const cardList = await CottageBizService.loadCards()
    this.domains = domainList
    this.cards = cardList
    const all = new DomainChip()
    all.id = ''
    all.label = '全部'
    const next: DomainChip[] = []
    next.push(all)
    for (const d of domainList) {
      const chip = new DomainChip()
      chip.id = d.category
      chip.label = d.title
      next.push(chip)
    }
    this.chips = next
    this.loading = false
    this.failed = cardList.length === 0
  }

  private visibleCards(): CottageItem[] {
    const out: CottageItem[] = []
    const q = this.query
    for (const c of this.cards) {
      if (this.filter.length > 0 && c.category !== this.filter && c.domain !== this.filter) {
        continue
      }
      if (q.length > 0 && c.title.indexOf(q) < 0 && c.summary.indexOf(q) < 0) {
        continue
      }
      out.push(c)
    }
    return out
  }

  build() {
    Column() {
      AppHeader({ title: '知识库', subtitle: '卡片 · 收藏 · 领域筛选' })
      Column({ space: Theme.space.s3 }) {
        Row({ space: Theme.space.s2 }) {
          AppIcon({ name: 'search', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
          TextInput({ text: this.query, placeholder: '搜索卡片标题或摘要' })
            .layoutWeight(1)
            .backgroundColor(Color.Transparent)
            .onChange((v: string) => { this.query = v })
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.pill)
        .border({ width: 1, color: Theme.colors().strokeHairline })

        Scroll() {
          Row({ space: Theme.space.s2 }) {
            ForEach(this.chips, (chip: DomainChip) => {
              Text(chip.label)
                .fontSize(Theme.type.caption)
                .fontColor(this.filter === chip.id ?
                  Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .backgroundColor(this.filter === chip.id ?
                  Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.filter = chip.id })
            }, (chip: DomainChip) => `chip-${chip.id}`)
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')

        Row() {
          Text('我的收藏夹')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .layoutWeight(1)
          AppIcon({ name: 'bookmark', iconSize: Theme.icon.sm, color: Theme.colors().brandPrimary })
        }
        .width('100%')
        .padding(Theme.space.s3)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
        .onClick((): void => { CottageNav.openFavorites() })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      if (this.loading) {
        Text('加载知识卡片…')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .padding(Theme.space.pageX)
      } else if (this.failed && this.visibleCards().length === 0) {
        AppError({
          title: '知识库暂时打不开',
          message: '请检查网络后重试',
          retryLabel: '重试',
          onRetry: (): void => { void this.reload() }
        })
      } else if (this.visibleCards().length === 0) {
        AppEmpty({ title: '没有匹配的卡片', description: '换个关键词或领域再试试' })
      } else {
        Scroll() {
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
            ForEach(this.visibleCards(), (c: CottageItem) => {
              Column() {
                CardGridTile({
                  title: c.title,
                  summary: c.summary,
                  coverKey: c.coverKey,
                  onOpen: (): void => { CottageNav.openCard(c.id) }
                })
              }
              .width('48%')
              .margin({ bottom: Theme.space.s3 })
            }, (c: CottageItem) => c.id)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10,
            top: Theme.space.s3
          })
          .width('100%')
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
