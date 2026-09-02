import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { SectionHeader } from '../components/design-system/SectionHeader'
import { ThoughtCardView } from '../components/box/ThoughtCardView'
import { TagChipRow } from '../components/box/TagChipRow'
import { MetricChipRow } from '../components/box/MetricChipRow'
import { EditorialBannerSwiper } from '../components/box/EditorialBannerSwiper'
import { HomeCapturePane } from '../components/box/HomeCapturePane'
import { ThoughtCard, CatalogItem } from '../models/ThoughtModels'
import { ThoughtStore } from '../services/ThoughtStore'
import { ThoughtBoxBizService } from '../services/ThoughtBoxBizService'
import { ClassifyService } from '../services/ClassifyService'
import { PhotoPickService } from '../services/PhotoPickService'
import { AppContextService } from '../services/AppContextService'
import { DateHelper } from '../services/DateHelper'
import { ImagePathUtil } from '../services/ImagePathUtil'
import { SparkBridge } from '../services/SparkBridge'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('tbReload') @Watch('onReloadChange') tbReload: number = 0
  @StorageLink('tbBreakCount') breakCount: number = 0
  @StorageLink('tbNoteCount') noteCount: number = 0
  @StorageLink('tbOpinionCount') opinionCount: number = 0
  @Prop @Watch('onReloadChange') reloadToken: number = 0
  @Prop @Watch('onTabVisibleChange') tabVisible: boolean = true
  @State draft: string = ''
  @State imagePath: string = ''
  @State cards: ThoughtCard[] = []
  @State pickedCsv: string = ''
  @State shelf: string = '全部'
  @State lexicon: CatalogItem[] = []
  @State toastText: string = ''
  @State query: string = ''
  @State showSearch: boolean = false
  @State filtered: ThoughtCard[] = []
  @State pickTagsCsv: string = '工作,生活,灵感,项目,阅读'
  @State tagEpoch: number = 0
  @State linkedCount: number = 0
  @State linkedCsv: string = ''
  @State metricCsv: string = ''
  onOpenCard: (id: string) => void = (_id: string) => {}
  onOpenThink: () => void = () => {}
  onOpenMap: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onReloadChange(): void {
    void this.reload()
  }

  onTabVisibleChange(): void {
    if (this.tabVisible) {
      void this.reload()
    }
  }

  private async reload(): Promise<void> {
    const all = await ThoughtStore.loadActive()
    if (this.shelf === '全部') {
      this.cards = all
    } else {
      this.cards = await ThoughtStore.byShelf(this.shelf)
    }
    this.lexicon = await ThoughtBoxBizService.loadLexicon()
    await this.reloadPickTags()
    this.linkedCount = await SparkBridge.linkedCount()
    const ids = await SparkBridge.linkedCardIds()
    this.linkedCsv = ids.join(',')
    this.metricCsv =
      `灵感|${this.cards.length}|0;已加工|${this.linkedCount}|0;拆解|${this.breakCount}|0;笔记|${this.noteCount}|0;观点|${this.opinionCount}|0`
  }

  private isLinked(id: string): boolean {
    if (this.linkedCsv.length === 0) {
      return false
    }
    return `,${this.linkedCsv},`.indexOf(`,${id},`) >= 0
  }

  private async reloadPickTags(): Promise<void> {
    const names = await ThoughtStore.pickableTagNames()
    for (const p of await ThoughtBoxBizService.loadTags()) {
      ClassifyService.pushUnique(names, p.title)
    }
    for (const s of ClassifyService.suggest(this.draft, this.lexicon)) {
      ClassifyService.pushUnique(names, s)
    }
    this.pickTagsCsv = names.join(',')
    this.tagEpoch = this.tagEpoch + 1
  }

  private refreshSuggest(): void {
    void this.reloadPickTags()
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
    card.imagePath = ImagePathUtil.normalizeStored(this.imagePath)
    card.shelf = this.shelf === '全部' ? '想法' : this.shelf
    const tags: string[] = []
    const a = this.pickedCsv.split(',')
    for (const p of a) {
      const t = p.trim()
      if (t.length > 0) {
        tags.push(t)
      }
    }
    const b = ClassifyService.suggest(this.draft, this.lexicon)
    for (const t of b) {
      if (t.length > 0) {
        tags.push(t)
      }
    }
    ClassifyService.applyTags(card, tags)
    await ThoughtStore.save(card)
    this.draft = ''
    this.imagePath = ''
    this.pickedCsv = ''
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
      if (PhotoPickService.lastError.length > 0) {
        this.showToast(PhotoPickService.lastError)
      } else {
        this.showToast('未选择图片')
      }
      return
    }
    this.imagePath = path
    this.showToast('已附加图片')
  }

  private async runSearch(): Promise<void> {
    this.filtered = await ThoughtStore.search(this.query)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: 0 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r('app.media.hero_open_box'))
              .width('100%')
              .height(240)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(240)
              .linearGradient({
                angle: 180,
                colors: [
                  ['rgba(15,23,42,0.06)', 0.0],
                  ['rgba(15,23,42,0.42)', 0.45],
                  ['rgba(26,35,50,0.92)', 1.0]
                ]
              })
            Row() {
              Blank()
              Row() {
                AppIcon({ name: 'search', iconSize: Theme.icon.lg, color: Theme.colors().textOnInverse })
              }
              .width(44)
              .height(44)
              .justifyContent(FlexAlign.Center)
              .backgroundColor('rgba(255,255,255,0.16)')
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { this.showSearch = true; void this.runSearch() })
            }
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s6 })
            Column({ space: 6 }) {
              Text('思维匣')
                .fontSize(Theme.type.titleL)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.colors().textOnInverse)
              Text('把碎片想法收进匣子')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textOnInverse)
            }
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 48 })
          }
          .width('100%')
          .height(252)

          Column({ space: Theme.space.section }) {
            HomeCapturePane({
              draft: this.draft,
              imagePath: this.imagePath,
              pickTagsCsv: this.pickTagsCsv,
              pickedCsv: this.pickedCsv,
              tagEpoch: this.tagEpoch,
              onDraftChange: (v: string): void => {
                this.draft = v
                this.refreshSuggest()
              },
              onToggleTag: (name: string): void => { this.togglePick(name) },
              onVoiceHint: (): void => { this.showToast('请使用系统键盘语音，转写后点收进匣子') },
              onPickImage: (): void => { void this.pickImage() },
              onCapture: (): void => { void this.capture() }
            })
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX, top: -36 })

            EditorialBannerSwiper({
              onThink: (): void => { this.onOpenThink() },
              onMap: (): void => { this.onOpenMap() }
            })

            Column({ space: Theme.space.s3 }) {
              SectionHeader({
                title: '匣格链路',
                subtitle: '灵感如何被推进'
              })
              MetricChipRow({ chipsCsv: this.metricCsv })
            }

            Column({ space: Theme.space.s3 }) {
              SectionHeader({
                title: '灵感收藏库',
                subtitle: '按收藏分类浏览已收进的卡片'
              })
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
                  Image($r('app.media.empty_linen'))
                    .width('100%')
                    .height(120)
                    .objectFit(ImageFit.Cover)
                    .borderRadius(Theme.radius.xl)
                  AppEmpty({ title: '匣子还是空的', description: '在上方工作台写下想法，就会出现在这里' })
                }
              } else {
                Column({ space: Theme.space.s3 }) {
                  ForEach(this.cards, (c: ThoughtCard) => {
                    ThoughtCardView({
                      previewText: c.preview(),
                      tagsLabel: c.tagLine(),
                      shelfLabel: c.shelf,
                      timeLabel: DateHelper.formatShort(c.createdAt),
                      imagePath: c.imagePath,
                      linked: this.isLinked(c.id),
                      onOpen: (): void => { this.onOpenCard(c.id) }
                    })
                  }, (c: ThoughtCard) => `${c.id}|${c.updatedAt}|${c.tagsCsv}|${c.shelf}|${c.imagePath}|${this.linkedCsv}`)
                }
              }
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          }
          .width('100%')
          .padding({ top: 0, bottom: 88 })
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.showSearch) {
        this.SearchLayer()
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s6 })
          .zIndex(30)
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
          .fontColor(Theme.colors().textPrimary)
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
              imagePath: c.imagePath,
              onOpen: (): void => {
                this.showSearch = false
                this.onOpenCard(c.id)
              }
            })
          }, (c: ThoughtCard) => `s_${c.id}|${c.updatedAt}|${c.tagsCsv}|${c.imagePath}`)
        }
        .padding({ bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .padding(Theme.space.pageX)
    .backgroundColor(Theme.colors().surfacePage)
    .zIndex(40)
  }
}
