import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { ThoughtCardView } from '../components/box/ThoughtCardView'
import { TagChipRow } from '../components/box/TagChipRow'
import { ThoughtCard, CatalogItem } from '../models/ThoughtModels'
import { ThoughtStore } from '../services/ThoughtStore'
import { ThoughtBoxBizService } from '../services/ThoughtBoxBizService'
import { ClassifyService } from '../services/ClassifyService'
import { PhotoPickService } from '../services/PhotoPickService'
import { AppContextService } from '../services/AppContextService'
import { BoxMedia } from '../services/BoxMedia'
import { DateHelper } from '../services/DateHelper'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('tbReload') @Watch('onReloadChange') tbReload: number = 0
  @Prop @Watch('onReloadChange') reloadToken: number = 0
  @State draft: string = ''
  @State imagePath: string = ''
  @State cards: ThoughtCard[] = []
  @State suggestions: string = ''
  @State pickedCsv: string = ''
  @State shelf: string = '全部'
  @State lexicon: CatalogItem[] = []
  @State toastText: string = ''
  @State query: string = ''
  @State showSearch: boolean = false
  @State filtered: ThoughtCard[] = []
  onOpenCard: (id: string) => void = (_id: string) => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onReloadChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const all = await ThoughtStore.loadActive()
    if (this.shelf === '全部') {
      this.cards = all
    } else {
      this.cards = await ThoughtStore.byShelf(this.shelf)
    }
    this.lexicon = await ThoughtBoxBizService.loadLexicon()
    this.refreshSuggest()
  }

  private refreshSuggest(): void {
    this.suggestions = ClassifyService.suggest(this.draft, this.lexicon).join(',')
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private togglePick(name: string): void {
    const now: string[] = []
    const parts = this.pickedCsv.split(',')
    let removed = false
    for (const p of parts) {
      const t = p.trim()
      if (t.length === 0) {
        continue
      }
      if (t === name) {
        removed = true
      } else {
        now.push(t)
      }
    }
    if (!removed) {
      now.push(name)
    }
    this.pickedCsv = now.join(',')
  }

  private async capture(): Promise<void> {
    const body = this.draft.trim()
    if (body.length === 0) {
      this.showToast('先写下一句想法')
      return
    }
    const card = ThoughtCard.createNew(body)
    card.imagePath = this.imagePath
    card.shelf = this.shelf === '全部' ? '想法' : this.shelf
    const tags: string[] = []
    const a = this.pickedCsv.split(',')
    for (const p of a) {
      const t = p.trim()
      if (t.length > 0) {
        tags.push(t)
      }
    }
    const b = this.suggestions.split(',')
    for (const p of b) {
      const t = p.trim()
      if (t.length > 0) {
        tags.push(t)
      }
    }
    ClassifyService.applyTags(card, tags)
    await ThoughtStore.save(card)
    this.draft = ''
    this.imagePath = ''
    this.pickedCsv = ''
    this.suggestions = ''
    await this.reload()
    this.showToast('已收进匣子')
  }

  private async pickImage(): Promise<void> {
    const ctx = AppContextService.getContext()
    if (ctx === null) {
      this.showToast('无法打开相册')
      return
    }
    const path = await PhotoPickService.pickOneImage(ctx)
    if (path.length === 0) {
      this.showToast('未选择图片')
      return
    }
    this.imagePath = path
    this.showToast('已附加图片')
  }

  private async runSearch(): Promise<void> {
    this.filtered = await ThoughtStore.search(this.query)
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text('思维匣')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Row() {
            AppIcon({ name: 'search', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.showSearch = true; void this.runSearch() })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(BoxMedia.resource('hero_open_box'))
                .width('100%')
                .height(168)
                .objectFit(ImageFit.Cover)
              Column() {
                Text('思想的容器')
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                Text('把碎片收进匣子')
                  .fontSize(Theme.type.footnote)
                  .fontColor('#FFFFFF')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .linearGradient({
                angle: 180,
                colors: [['rgba(0,0,0,0)', 0], ['rgba(26,35,50,0.82)', 1]]
              })
            }
            .width('100%')
            .height(168)
            .clip(true)
            .borderRadius(Theme.radius.lg)

            Column({ space: Theme.space.s3 }) {
              TextArea({ text: this.draft, placeholder: '此刻在想什么？' })
                .height(88)
                .backgroundColor(Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.md)
                .onChange((v: string) => {
                  this.draft = v
                  this.refreshSuggest()
                })
              TagChipRow({
                namesCsv: this.suggestions.length > 0 ? this.suggestions : '工作,生活,灵感,项目',
                selectedCsv: this.pickedCsv,
                onToggle: (name: string): void => { this.togglePick(name) }
              })
              Row({ space: Theme.space.s2 }) {
                Text('智慧语音')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandPrimary)
                  .padding({ left: 10, right: 10, top: 8, bottom: 8 })
                  .borderRadius(Theme.radius.pill)
                  .backgroundColor(Theme.colors().brandPrimaryContainer)
                  .onClick((): void => { this.showToast('请使用系统键盘语音，转写后点记下') })
                Text('图片')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandPrimary)
                  .padding({ left: 10, right: 10, top: 8, bottom: 8 })
                  .borderRadius(Theme.radius.pill)
                  .backgroundColor(Theme.colors().brandPrimaryContainer)
                  .onClick((): void => { void this.pickImage() })
                Blank()
                Text(this.imagePath.length > 0 ? '记下 · 已附图' : '记下')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().brandOnPrimary)
                  .padding({ left: 18, right: 18, top: 8, bottom: 8 })
                  .backgroundColor(Theme.colors().brandAccent)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { void this.capture() })
              }
              .width('100%')
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)

            Text('灵感收藏库')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            TagChipRow({
              namesCsv: '全部,创意,计划,想法,观点',
              selectedCsv: this.shelf,
              onToggle: (name: string): void => {
                this.shelf = name
                void this.reload()
              }
            })

            if (this.cards.length === 0) {
              Column({ space: Theme.space.s3 }) {
                Image(BoxMedia.resource('empty_linen'))
                  .width('100%')
                  .height(120)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(Theme.radius.md)
                AppEmpty({ title: '匣子还是空的', description: '写下此刻的想法，就会出现在这里' })
              }
            } else {
              ForEach(this.cards, (c: ThoughtCard) => {
                ThoughtCardView({
                  previewText: c.preview(),
                  tagsLabel: c.tagLine(),
                  shelfLabel: c.shelf,
                  timeLabel: DateHelper.formatShort(c.createdAt),
                  onOpen: (): void => { this.onOpenCard(c.id) }
                })
              }, (c: ThoughtCard) => `${c.id}|${c.updatedAt}|${c.tagsCsv}|${c.shelf}`)
            }
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s8 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.On)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.showSearch) {
        this.SearchLayer()
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textOnInverse)
          .padding(12)
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.md)
          .margin({ top: 56 })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  SearchLayer() {
    Column() {
      Row() {
        Text('搜索')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
        Text('关闭')
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { this.showSearch = false })
      }
      .width('100%')
      TextInput({ text: this.query, placeholder: '按关键词搜索卡片' })
        .height(44)
        .onChange((v: string) => {
          this.query = v
          void this.runSearch()
        })
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          ForEach(this.filtered, (c: ThoughtCard) => {
            ThoughtCardView({
              previewText: c.preview(),
              tagsLabel: c.tagLine(),
              shelfLabel: c.shelf,
              timeLabel: DateHelper.formatShort(c.createdAt),
              onOpen: (): void => {
                this.showSearch = false
                this.onOpenCard(c.id)
              }
            })
          }, (c: ThoughtCard) => `s_${c.id}|${c.updatedAt}|${c.tagsCsv}`)
        }
        .padding({ bottom: Theme.space.s8 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .padding(Theme.space.pageX)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
