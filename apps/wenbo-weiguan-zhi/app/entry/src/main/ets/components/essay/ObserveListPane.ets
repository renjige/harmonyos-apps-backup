import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { EssayListCard } from './EssayListCard'
import { EssayDetailPane } from './EssayDetailPane'
import { EssayEditorSheet } from './EssayEditorSheet'
import { MicroEssay, SenseOption, TagCloudItem } from '../../models/EssayModels'
import { EssayStore } from '../../services/EssayStore'
import { DateHelper } from '../../services/DateHelper'
import { SmartTagService } from '../../services/SmartTagService'

/** 二级：搜索 / 筛选 / 全量列表（不在 Tab 首屏暴露，避免「日记列表」印象） */
@Component
export struct ObserveListPane {
  @Prop initialKindFilter: string = ''
  @StorageLink('essayFontScale') fontScale: number = 1
  @StorageLink('tagFilter') tagFilter: string = ''
  @StorageLink('essayDataEpoch') @Watch('onEpoch') dataEpoch: number = 0
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}

  @State essays: MicroEssay[] = []
  @State filtered: MicroEssay[] = []
  @State tags: TagCloudItem[] = []
  @State loading: boolean = true
  @State keyword: string = ''
  @State dateFrom: string = ''
  @State dateTo: string = ''
  @State onlyFav: boolean = false
  @State detailId: string = ''
  @State showEditor: boolean = false
  @State editingId: string = ''
  @State senseFilter: string = ''
  @State sortNewest: boolean = true
  @State kindFilter: string = ''
  private senses: SenseOption[] = SenseOption.all()

  aboutToAppear(): void {
    this.kindFilter = this.initialKindFilter
    void this.reload()
  }

  onEpoch(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.essays = await EssayStore.loadAll()
    this.tags = await SmartTagService.buildCloud(this.essays)
    this.applyFilter()
    this.loading = false
  }

  private applyFilter(): void {
    const kw = this.keyword.trim().toLowerCase()
    const from = DateHelper.normalizeKey(this.dateFrom)
    const to = DateHelper.normalizeKey(this.dateTo)
    const next: MicroEssay[] = []
    for (const e of this.essays) {
      if (this.tagFilter.length > 0 && !e.tagList().includes(this.tagFilter)) {
        continue
      }
      if (this.onlyFav && !e.favorite) {
        continue
      }
      if (this.senseFilter.length > 0 && e.senseKey !== this.senseFilter) {
        continue
      }
      if (this.kindFilter.length > 0) {
        if (this.kindFilter === 'contrast') {
          if (e.kind !== 'contrast' && e.tagsCsv.indexOf('对照') < 0) {
            continue
          }
        } else if (e.kind !== this.kindFilter) {
          continue
        }
      }
      if (from.length > 0 && e.dateKey < from) {
        continue
      }
      if (to.length > 0 && e.dateKey > to) {
        continue
      }
      if (kw.length > 0) {
        const hay = `${e.title} ${MicroEssay.stripMarkup(e.body)}`.toLowerCase()
        if (hay.indexOf(kw) < 0) {
          continue
        }
      }
      next.push(e)
    }
    if (this.sortNewest) {
      next.sort((a, b) => b.updatedAt - a.updatedAt)
    } else {
      next.sort((a, b) => a.updatedAt - b.updatedAt)
    }
    this.filtered = next
  }

  private setToday(): void {
    const t = DateHelper.todayKey()
    this.dateFrom = t
    this.dateTo = t
    this.applyFilter()
  }

  private setWeek(): void {
    const t = DateHelper.todayKey()
    this.dateFrom = DateHelper.addDaysKey(t, -6)
    this.dateTo = t
    this.applyFilter()
  }

  private clearDates(): void {
    this.dateFrom = ''
    this.dateTo = ''
    this.onlyFav = false
    this.senseFilter = ''
    this.kindFilter = ''
    AppStorage.setOrCreate('tagFilter', '')
    this.applyFilter()
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

  private topTags(): TagCloudItem[] {
    const out: TagCloudItem[] = []
    const max = this.tags.length < 8 ? this.tags.length : 8
    for (let i = 0; i < max; i++) {
      out.push(this.tags[i])
    }
    return out
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text('返回')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().brandPrimary)
            .onClick((): void => { this.onClose() })
          Blank()
          Text('全部观察')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
          Blank()
          Text(`${this.filtered.length}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
        .width('100%')
        .padding(Theme.space.pageX)

        Scroll() {
          Column() {
            Row({ space: Theme.space.s2 }) {
              TextInput({ text: this.keyword, placeholder: '搜索观察内容' })
                .layoutWeight(1)
                .height(40)
                .backgroundColor(Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .padding({ left: 12, right: 12 })
                .onChange((v: string) => {
                  this.keyword = v
                  this.applyFilter()
                })
              Row() {
                AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.colors().brandOnPrimary })
              }
              .width(44)
              .height(44)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(Theme.colors().brandPrimary)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { this.openNewCard() })
            }
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })

            Flex({ wrap: FlexWrap.Wrap }) {
              this.KindChip('全部', '')
              this.KindChip('五感卡', 'card')
              this.KindChip('对照', 'contrast')
              this.KindChip('拓展', 'free')
            }
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s1 })

            if (this.loading) {
              Text('加载中…').fontColor(Theme.colors().textSecondary).padding({ left: Theme.space.pageX })
            } else if (this.filtered.length === 0) {
              AppEmpty({
                title: this.essays.length === 0 ? '还没有观察' : '没有匹配的观察',
                description: '从五感观察卡或对照观察开始',
                actionLabel: this.essays.length === 0 ? '写观察卡' : '清除筛选',
                onAction: (): void => {
                  if (this.essays.length === 0) {
                    this.openNewCard()
                  } else {
                    this.clearDates()
                  }
                }
              })
            } else {
              Column({ space: Theme.space.s3 }) {
                ForEach(this.filtered, (item: MicroEssay) => {
                  EssayListCard({
                    essay: item,
                    fontScale: this.fontScale,
                    onTap: (): void => { this.detailId = item.id }
                  })
                }, (item: MicroEssay) => `${item.id}_${item.updatedAt}`)
              }
              .width('100%')
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
            }
            Blank().height(Theme.space.s10)
          }
          .width('100%')
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.detailId.length > 0) {
        EssayDetailPane({
          essayId: this.detailId,
          fontScale: this.fontScale,
          onClose: (): void => { this.detailId = '' },
          onEdit: (): void => { this.openEdit(this.detailId) },
          onDeleted: (): void => { this.detailId = ''; void this.reload() },
          onChanged: (): void => { void this.reload() },
          onOpenRelated: (id: string): void => { this.detailId = id }
        })
      }
      if (this.showEditor) {
        EssayEditorSheet({
          essayId: this.editingId,
          fontScale: this.fontScale,
          openAsCard: this.editingId.length === 0,
          onClose: (): void => { this.showEditor = false; void this.reload() },
          onSaved: (): void => { this.showEditor = false; void this.reload() }
        })
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(45)
    .onAppear((): void => { AppStorage.setOrCreate('tabBarHidden', true) })
    .onDisAppear((): void => { AppStorage.setOrCreate('tabBarHidden', false) })
  }

  @Builder
  KindChip(label: string, key: string) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.kindFilter === key ? '#FFFFFF' : Theme.colors().textPrimary)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor(this.kindFilter === key ? '#1A2A3A' : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .margin({ right: 8, bottom: 8 })
      .onClick((): void => { this.kindFilter = key; this.applyFilter() })
  }
}
