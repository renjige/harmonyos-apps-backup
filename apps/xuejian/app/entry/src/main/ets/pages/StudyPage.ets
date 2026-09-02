import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { SymbolCover } from '../components/design-system/SymbolVisual'
import { KnowledgeCardItem, StudyNote, CatalogItem } from '../models/StudyModels'
import { StudyStore } from '../services/StudyStore'
import { StudyMedia } from '../services/StudyMedia'
import { StudyBizService } from '../services/StudyBizService'
import { CategoryEmojiUtil } from '../utils/CategoryEmojiUtil'

@Component
export struct StudyPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('studyDataEpoch') @Watch('onDataEpoch') studyDataEpoch: number = 0
  @Prop @Watch('onReloadTokenChange') reloadToken: number = 0
  @State notes: StudyNote[] = []
  @State cards: KnowledgeCardItem[] = []
  @State categories: CatalogItem[] = []
  @State filter: string = '全部'
  @State query: string = ''
  onOpenFocus: () => void = () => {}
  onOpenNote: (id: string) => void = (_id: string) => {}
  onNewNote: () => void = () => {}
  onOpenCard: (id: string) => void = (_id: string) => {}
  onNewCard: () => void = () => {}
  onOpenReview: () => void = () => {}
  onOpenCategory: (item: CatalogItem) => void = (_item: CatalogItem) => {}

  aboutToAppear(): void {
    void this.load()
  }

  onReloadTokenChange(): void {
    void this.load()
  }

  onDataEpoch(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.notes = await StudyStore.loadNotes()
    this.cards = await StudyStore.loadCards()
    this.categories = await StudyBizService.loadCategories()
  }

  private visibleNotes(): StudyNote[] {
    const q = this.query.trim()
    if (q.length === 0) {
      return this.notes
    }
    const out: StudyNote[] = []
    for (const n of this.notes) {
      if (n.title.indexOf(q) >= 0 || n.body.indexOf(q) >= 0 || n.tags.indexOf(q) >= 0) {
        out.push(n)
      }
    }
    return out
  }

  private cats(): string[] {
    const out: string[] = ['全部']
    for (const c of this.categories) {
      out.push(c.title)
    }
    if (out.length === 1) {
      out.push('数学', '英语', '编程', '职场', '其他')
    }
    return out
  }

  private filteredCards(): KnowledgeCardItem[] {
    if (this.filter === '全部') {
      return this.cards
    }
    const out: KnowledgeCardItem[] = []
    for (const c of this.cards) {
      if (c.category === this.filter) {
        out.push(c)
      }
    }
    return out
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Row() {
          Column({ space: 4 }) {
            Text('学习')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text('⏱ 计时 · 笔记 · 卡片')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }
        .width('100%')

        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.banner_focus'))
            .width('100%')
            .height(132)
            .objectFit(ImageFit.Cover)
          Column() {
            Blank()
            Row() {
              Text('进入专注倒计时')
                .fontSize(Theme.type.subtitleS)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
                .layoutWeight(1)
              AppIcon({ name: 'clock', iconSize: 22, color: '#FFFFFF' })
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor('#CC1A2A4A')
          }
          .width('100%')
          .height(132)
        }
        .width('100%')
        .height(132)
        .borderRadius(Theme.radius.lg)
        .clip(true)
        .onClick((): void => { this.onOpenFocus() })

        Text('学科分类')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        if (this.categories.length === 0) {
          Text('联网后可浏览数学、英语、编程等分类，并按分类整理卡片。')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.bodyMuted())
            .width('100%')
        } else {
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.categories, (cat: CatalogItem) => {
              Column({ space: 6 }) {
                Image(StudyMedia.resource(cat.coverKey))
                  .width(72)
                  .height(72)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(12)
                Text(cat.title)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textPrimary)
                  .maxLines(1)
              }
              .width('30%')
              .margin(4)
              .padding(8)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(12)
              .onClick((): void => { this.onOpenCategory(cat) })
            }, (cat: CatalogItem) => cat.id)
          }
          .width('100%')
        }

        Row() {
          Text('学习笔记')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
          Text('＋ 写笔记')
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .constraintSize({ minHeight: 44 })
            .onClick((): void => { this.onNewNote() })
        }
        .width('100%')

        TextInput({ text: this.query, placeholder: '搜索笔记标题或正文' })
          .width('100%')
          .height(44)
          .fontColor(Theme.inputInk())
          .placeholderColor(Theme.inputHint())
          .backgroundColor(Theme.inputFill())
          .border({ width: 1, color: '#CBD5E1' })
          .borderRadius(12)
          .onChange((v: string) => { this.query = v })

        if (this.visibleNotes().length === 0) {
          AppEmpty({
            title: '还没有笔记',
            description: '记下今天最想记住的一句',
            actionLabel: '写一条',
            onAction: (): void => { this.onNewNote() }
          })
        } else {
          ForEach(this.visibleNotes(), (n: StudyNote) => {
            Row({ space: 12 }) {
              Image(StudyMedia.resource(n.coverKey))
                .width(64)
                .height(64)
                .objectFit(ImageFit.Cover)
                .borderRadius(10)
              Column({ space: 4 }) {
                Text(n.title)
                  .fontSize(Theme.type.subtitleS)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                Text(n.preview())
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .maxLines(2)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              AppIcon({ name: 'chevron', iconSize: 16, color: Theme.colors().textTertiary })
            }
            .width('100%')
            .padding(12)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick((): void => { this.onOpenNote(n.id) })
          }, (n: StudyNote) => n.id)
        }

        Row() {
          Text('知识卡片')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
          Text('随机复习')
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .margin({ right: 12 })
            .constraintSize({ minHeight: 44 })
            .onClick((): void => { this.onOpenReview() })
          Text('＋ 卡片')
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .constraintSize({ minHeight: 44 })
            .onClick((): void => { this.onNewCard() })
        }
        .width('100%')

        Scroll() {
          Row({ space: 8 }) {
            ForEach(this.cats(), (c: string) => {
              Text(c === '全部' ? '📚 全部' : CategoryEmojiUtil.chipLabel(c))
                .fontSize(Theme.type.caption)
                .fontColor(this.filter === c ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .backgroundColor(this.filter === c ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
                .borderRadius(16)
                .constraintSize({ minHeight: 40 })
                .onClick((): void => { this.filter = c })
            }, (c: string) => c)
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')

        if (this.filteredCards().length === 0) {
          AppEmpty({
            title: '没有卡片',
            description: '按分类整理一个术语或方法',
            actionLabel: '新建卡片',
            onAction: (): void => { this.onNewCard() }
          })
        } else {
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
            ForEach(this.filteredCards(), (c: KnowledgeCardItem) => {
              Column({ space: 8 }) {
                SymbolCover({ category: c.category, tileSize: 56 })
                Text(c.title)
                  .fontSize(Theme.type.bodyS)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .maxLines(2)
                Text(c.isMastered() ? '已掌握' : '需复习')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
              .width('46%')
              .padding(12)
              .margin({ right: '2%', bottom: 10 })
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .alignItems(HorizontalAlign.Start)
              .onClick((): void => { this.onOpenCard(c.id) })
            }, (c: KnowledgeCardItem) => `${c.id}-${c.mastery}-${c.updatedAt}`)
          }
          .width('100%')
        }
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s8
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
