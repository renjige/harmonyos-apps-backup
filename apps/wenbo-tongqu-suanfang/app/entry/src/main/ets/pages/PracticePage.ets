import { Theme } from '../components/design-system/Theme'
import { ModeListCard } from '../components/math/ModeListCard'
import { CatalogItem, FilterChip } from '../models/MathModels'
import { MathBizService } from '../services/MathBizService'
import { MathCatalog } from '../services/MathCatalog'
import { MathDetailNav } from '../services/MathDetailNav'
import { MathLocalStore } from '../services/MathLocalStore'

@Component
export struct PracticePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('mathHomeTick') @Watch('onHomeTickChange') dataTick: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State modes: CatalogItem[] = []
  @State challenges: CatalogItem[] = []
  @State tips: CatalogItem[] = []
  @State wrongCount: number = 0
  @State favCount: number = 0
  @State keyword: string = ''
  @State hits: CatalogItem[] = []
  @State filterId: string = 'all'
  @State chips: FilterChip[] = []
  onOpenWrong: () => void = () => {}
  onOpenFav: () => void = () => {}
  onOpenTable: () => void = () => {}
  onOpenCustom: () => void = () => {}
  onOpenPack: () => void = () => {}

  aboutToAppear(): void {
    this.chips = PracticePage.filterChips()
    this.modes = MathCatalog.modes()
    this.challenges = MathCatalog.challenges()
    this.tips = MathCatalog.tips()
    this.wrongCount = MathLocalStore.snapshot().wrongs.length
    this.favCount = MathLocalStore.snapshot().favorites.length
    void this.reload()
  }

  onHomeTickChange(): void {
    this.wrongCount = MathLocalStore.snapshot().wrongs.length
    this.favCount = MathLocalStore.snapshot().favorites.length
  }

  onRefreshTokenChange(): void {
    this.wrongCount = MathLocalStore.snapshot().wrongs.length
    this.favCount = MathLocalStore.snapshot().favorites.length
    void this.reload()
  }

  private async reload(): Promise<void> {
    const modeList = await MathBizService.loadModes()
    if (modeList.length >= MathCatalog.modes().length) {
      this.modes = modeList
    } else {
      this.modes = MathCatalog.modes()
    }
    const chList = await MathBizService.loadChallenges()
    if (chList.length >= MathCatalog.challenges().length) {
      this.challenges = chList
    } else {
      this.challenges = MathCatalog.challenges()
    }
    const tipList = await MathBizService.loadTips()
    if (tipList.length >= MathCatalog.tips().length) {
      this.tips = tipList
    } else {
      this.tips = MathCatalog.tips()
    }
  }

  private sectionModes(key: string): CatalogItem[] {
    const out: CatalogItem[] = []
    for (const item of this.modes) {
      const section = item.rule.length > 0 ? item.rule : 'basic'
      if (section === key) {
        out.push(item)
      }
    }
    out.sort((a, b) => a.sortOrder - b.sortOrder)
    return out
  }

  private static pushChip(out: FilterChip[], id: string, label: string): void {
    const c = new FilterChip()
    c.id = id
    c.label = label
    out.push(c)
  }

  private static filterChips(): FilterChip[] {
    const out: FilterChip[] = []
    PracticePage.pushChip(out, 'all', '全部')
    PracticePage.pushChip(out, 'age', '年龄')
    PracticePage.pushChip(out, 'game', '趣味')
    PracticePage.pushChip(out, 'basic', '基础')
    PracticePage.pushChip(out, 'sense', '数感')
    PracticePage.pushChip(out, 'life', '生活')
    return out
  }

  private showSection(key: string): boolean {
    return this.filterId === 'all' || this.filterId === key
  }

  private openItem(item: CatalogItem): void {
    if (item.id.indexOf('km_tip') === 0) {
      MathDetailNav.open('tip', item.id)
      return
    }
    if (item.id.indexOf('km_ch') === 0) {
      MathDetailNav.open('challenge', item.id)
      return
    }
    MathDetailNav.open('mode', item.id)
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Text('练习')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
          .padding({ top: Theme.space.s2 })

        TextInput({ text: this.keyword, placeholder: '搜索题型、知识卡片或闯关' })
          .width('100%')
          .height(44)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .placeholderColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .padding({ left: Theme.space.s4, right: Theme.space.s4 })
          .onChange((v: string) => {
            this.keyword = v
            this.hits = v.trim().length > 0 ? MathCatalog.searchItems(v) : []
          })

        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.chips, (c: FilterChip) => {
            Text(c.label)
              .fontSize(Theme.type.caption)
              .fontColor(this.filterId === c.id ? '#FFFFFF' : Theme.colors().textPrimary)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .margin({ right: 8, bottom: 8 })
              .backgroundColor(this.filterId === c.id ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.pill)
              .onClick(() => { this.filterId = c.id })
          }, (c: FilterChip) => c.id)
        }
        .width('100%')

        Row({ space: Theme.space.s3 }) {
          this.entry('家长出题', '自己写算式', () => this.onOpenCustom())
          this.entry('我的题单', '组合题型练', () => this.onOpenPack())
        }
        .width('100%')

        if (this.hits.length > 0) {
          this.sectionBlock('搜索结果', this.hits)
        }

        Column({ space: Theme.space.s2 }) {
          Text('九九口诀表')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text('先看 1～9 的口诀，点一行只练这一句')
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s5)
        .alignItems(HorizontalAlign.Start)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .onClick(() => this.onOpenTable())

        if (this.showSection('age')) {
          this.sectionBlock('年龄阶段', this.sectionModes('age'))
        }
        if (this.showSection('game')) {
          this.sectionBlock('趣味数学', this.sectionModes('game'))
        }
        if (this.showSection('basic')) {
          this.sectionBlock('基础运算', this.sectionModes('basic'))
        }
        if (this.showSection('sense')) {
          this.sectionBlock('数感与规律', this.sectionModes('sense'))
        }
        if (this.showSection('life')) {
          this.sectionBlock('生活应用', this.sectionModes('life'))
        }
        if (this.filterId === 'all') {
          this.sectionBlock('年级路径', this.sectionModes('grade'))
          this.sectionBlock('技巧练习', this.sectionModes('skill'))
          this.sectionBlock('进阶练习', this.sectionModes('advance'))
        }

        Column({ space: Theme.space.s3 }) {
          Text('闯关挑战')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          ForEach(this.challenges, (item: CatalogItem) => {
            ModeListCard({
              item: item,
              locked: MathBizService.challengeLocked(item.id),
              onTap: () => MathDetailNav.open('challenge', item.id)
            })
          }, (item: CatalogItem) => item.id)
        }
        .width('100%')

        Column({ space: Theme.space.s3 }) {
          Text('知识卡片')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          ForEach(this.tips, (item: CatalogItem) => {
            ModeListCard({
              item: item,
              onTap: () => MathDetailNav.open('tip', item.id)
            })
          }, (item: CatalogItem) => item.id)
        }
        .width('100%')

        Column({ space: Theme.space.s2 }) {
          Text('错题小本')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text(this.wrongCount > 0 ? `有 ${this.wrongCount} 题可以再算一次` : '太棒啦！目前没有需要复习的题目')
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s5)
        .alignItems(HorizontalAlign.Start)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .onClick(() => this.onOpenWrong())

        Column({ space: Theme.space.s2 }) {
          Text('数学收藏夹')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text(this.favCount > 0 ? `有 ${this.favCount} 题收藏，点这里复习` : '答题页可收藏重点题目')
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s5)
        .alignItems(HorizontalAlign.Start)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .onClick(() => this.onOpenFav())
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        bottom: Theme.space.s10
      })
      .constraintSize({ maxWidth: 720 })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  sectionBlock(title: string, items: CatalogItem[]) {
    if (items.length > 0) {
      Column({ space: Theme.space.s3 }) {
        Text(title)
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        ForEach(items, (item: CatalogItem) => {
          ModeListCard({
            item: item,
            onTap: () => this.openItem(item)
          })
        }, (item: CatalogItem) => item.id)
      }
      .width('100%')
    }
  }

  @Builder
  entry(title: string, hint: string, tap: () => void) {
    Column({ space: Theme.space.s1 }) {
      Text(title)
        .fontSize(Theme.type.subtitleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(hint)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
    }
    .layoutWeight(1)
    .padding(Theme.space.s4)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .onClick(tap)
  }
}
