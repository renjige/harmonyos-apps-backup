import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { ObserveMethodCards } from '../components/essay/ObserveMethodCards'
import { ObserveKindSection } from '../components/essay/ObserveKindSection'
import { ObserveListPane } from '../components/essay/ObserveListPane'
import { ObserveDifferentiatorBanner } from '../components/essay/ObserveDifferentiatorBanner'
import { EssayDetailPane } from '../components/essay/EssayDetailPane'
import { EssayEditorSheet } from '../components/essay/EssayEditorSheet'
import { ContrastPane } from '../components/essay/ContrastPane'
import { ThemeListPane } from '../components/essay/ThemeListPane'
import { ThemeEditorSheet } from '../components/essay/ThemeEditorSheet'
import { MicroEssay } from '../models/EssayModels'
import { ObserveTheme } from '../models/GrowthModels'
import { EssayStore } from '../services/EssayStore'
import { GrowthStore } from '../services/GrowthStore'

/**
 * Tab「练习」— 方法驱动入口 + 分类归档预览。
 * 首屏不出现全量文本列表，降低 3.7「简易记录/日记」误判。
 */
@Component
export struct PracticeTabPage {
  @Prop @Watch('onReloadToken') reloadToken: number = 0
  @StorageLink('essayFontScale') fontScale: number = 1
  @StorageLink('essayDataEpoch') @Watch('onEpoch') dataEpoch: number = 0
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('openObserveList') @Watch('onOpenListFlag') openObserveList: number = 0

  @State cardItems: MicroEssay[] = []
  @State contrastItems: MicroEssay[] = []
  @State cardCount: number = 0
  @State contrastCount: number = 0
  @State freeCount: number = 0
  @State totalCount: number = 0
  @State themeTitle: string = ''
  @State showList: boolean = false
  @State listKind: string = ''
  @State detailId: string = ''
  @State showEditor: boolean = false
  @State editingId: string = ''
  @State showContrast: boolean = false
  @State showThemes: boolean = false
  @State showThemeEdit: boolean = false

  aboutToAppear(): void {
    void this.reload()
    this.consumeOpenList()
  }

  onOpenListFlag(): void {
    this.consumeOpenList()
  }

  private consumeOpenList(): void {
    if (this.openObserveList > 0) {
      const kind = AppStorage.get<string>('openObserveListKind') ?? ''
      this.listKind = kind.length > 0 ? kind : ''
      this.showList = true
      AppStorage.setOrCreate('openObserveList', 0)
    }
  }

  onEpoch(): void {
    void this.reload()
  }

  onReloadToken(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const all = await EssayStore.loadAll()
    this.totalCount = all.length
    const cards: MicroEssay[] = []
    const contrasts: MicroEssay[] = []
    let cardN = 0
    let contrastN = 0
    let freeN = 0
    for (const it of all) {
      const isContrast = it.kind === 'contrast' || it.tagsCsv.indexOf('对照') >= 0
      if (isContrast) {
        contrastN++
        if (contrasts.length < 2) {
          contrasts.push(it)
        }
      } else if (it.kind === 'card') {
        cardN++
        if (cards.length < 2) {
          cards.push(it)
        }
      } else {
        freeN++
      }
    }
    this.cardCount = cardN
    this.contrastCount = contrastN
    this.freeCount = freeN
    this.cardItems = cards
    this.contrastItems = contrasts
    const active: ObserveTheme | undefined = await GrowthStore.activeTheme()
    this.themeTitle = active !== undefined ? active.title : ''
  }

  private openThemeEntry(): void {
    if (this.themeTitle.length > 0) {
      this.showThemes = true
    } else {
      this.showThemeEdit = true
    }
  }

  private openList(kind: string): void {
    this.listKind = kind
    this.showList = true
  }

  private openNewCard(): void {
    this.editingId = ''
    this.showEditor = true
  }

  private openEdit(id: string): void {
    this.editingId = id
    this.showEditor = true
    this.detailId = ''
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Column({ space: 4 }) {
            Text('观察练习')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Text('方法入口 · 分类预览 · 全量列表在二级页')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandAccent)
              .width('100%')
          }
          .width('100%')
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            top: Theme.space.s4
          })

          ObserveDifferentiatorBanner()
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

          ObserveMethodCards({
            onCard: (): void => { this.openNewCard() },
            onContrast: (): void => { this.showContrast = true },
            onTheme: (): void => { this.openThemeEntry() },
            onAlbum: (): void => { AppStorage.setOrCreate('essayTabIndex', 3) }
          })

          if (this.totalCount === 0) {
            AppEmpty({
              title: '还没有观察练习',
              description: '从五感观察卡开始，或用对照观察看见两次的不同',
              actionLabel: '写第一张五感卡',
              onAction: (): void => { this.openNewCard() }
            })
          } else {
            ObserveKindSection({
              title: '五感观察卡',
              subtitle: '结构化观察练习',
              count: this.cardCount,
              accent: '#1A2A3A',
              items: this.cardItems,
              fontScale: this.fontScale,
              primaryLabel: '写一张',
              onPrimary: (): void => { this.openNewCard() },
              onViewAll: (): void => { this.openList('card') },
              onOpen: (id: string): void => { this.detailId = id }
            })
            ObserveKindSection({
              title: '对照观察',
              subtitle: '并排重读 · 写差异',
              count: this.contrastCount,
              accent: '#2D4A5E',
              items: this.contrastItems,
              fontScale: this.fontScale,
              primaryLabel: '开始对照',
              onPrimary: (): void => { this.showContrast = true },
              onViewAll: (): void => { this.openList('contrast') },
              onOpen: (id: string): void => { this.detailId = id }
            })
            Row({ space: Theme.space.s3 }) {
              Column({ space: 4 }) {
                Text('全部观察')
                  .fontSize(Theme.type.body)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                Text(`${this.totalCount} 篇 · 搜索与筛选`)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .onClick((): void => { this.openList('') })
            }
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          }
          Blank().height(Theme.space.s10)
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.showList) {
        ObserveListPane({
          initialKindFilter: this.listKind,
          onClose: (): void => { this.showList = false }
        })
      }
      if (this.detailId.length > 0) {
        EssayDetailPane({
          essayId: this.detailId,
          fontScale: this.fontScale,
          onClose: (): void => { this.detailId = '' },
          onEdit: (): void => { this.openEdit(this.detailId) },
          onDeleted: (): void => {
            this.detailId = ''
            void this.reload()
          },
          onChanged: (): void => { void this.reload() },
          onOpenRelated: (id: string): void => { this.detailId = id }
        })
      }
      if (this.showContrast) {
        ContrastPane({
          onClose: (): void => { this.showContrast = false },
          onSaved: (): void => {
            this.showContrast = false
            void this.reload()
          }
        })
      }
      if (this.showThemes) {
        ThemeListPane({
          onClose: (): void => { this.showThemes = false },
          onCreate: (): void => {
            this.showThemeEdit = true
          },
          onOpenEssay: (id: string): void => {
            this.showThemes = false
            this.detailId = id
          }
        })
      }
      if (this.showThemeEdit) {
        ThemeEditorSheet({
          themeId: '',
          onClose: (): void => { this.showThemeEdit = false },
          onSaved: (): void => {
            this.showThemeEdit = false
            this.showThemes = false
            void this.reload()
          }
        })
      }
      if (this.showEditor) {
        EssayEditorSheet({
          essayId: this.editingId,
          fontScale: this.fontScale,
          openAsCard: true,
          onClose: (): void => {
            this.showEditor = false
            void this.reload()
          },
          onSaved: (): void => {
            this.showEditor = false
            void this.reload()
          }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
