import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppDatePickerField } from '../components/design-system/AppDatePickerField'
import { EssayListCard } from '../components/essay/EssayListCard'
import { EssayDetailPane } from '../components/essay/EssayDetailPane'
import { EssayEditorSheet } from '../components/essay/EssayEditorSheet'
import { MicroEssay, SenseOption, TagCloudItem } from '../models/EssayModels'
import { EssayStore } from '../services/EssayStore'
import { DateHelper } from '../services/DateHelper'
import { SmartTagService } from '../services/SmartTagService'

@Component
export struct TimelinePage {
  @Prop reloadToken: number = 0
  @StorageLink('essayFontScale') fontScale: number = 1
  @StorageLink('tagFilter') tagFilter: string = ''
  @StorageLink('essayDataEpoch') @Watch('onEpoch') dataEpoch: number = 0
  @StorageLink('themeEpoch') themeEpoch: number = 0
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
  @State lastEpoch: number = -1
  @State senseFilter: string = ''
  @State sortNewest: boolean = true
  @State kindFilter: string = ''
  private senses: SenseOption[] = SenseOption.all()

  aboutToAppear(): void {
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

  private openNew(): void {
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
          Column({ space: 2 }) {
            Text('观察档案')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textPrimary)
            Text('五感卡 · 对照 · 专题练习产出')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          Text(`${this.filtered.length} 篇`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s4,
          bottom: Theme.space.s2
        })

        Scroll() {
          Column() {
            Row({ space: Theme.space.s2 }) {
              TextInput({ text: this.keyword, placeholder: '搜索标题或正文' })
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
              .onClick((): void => { this.openNew() })
            }
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })

            Flex({ wrap: FlexWrap.Wrap }) {
              this.KindChip('全部', '')
              this.KindChip('五感卡', 'card')
              this.KindChip('对照', 'contrast')
              this.KindChip('自由', 'free')
            }
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s1 })

            Flex({ wrap: FlexWrap.Wrap }) {
              Text('全部')
                .fontSize(Theme.type.bodyS)
                .fontColor(this.senseFilter.length === 0 ? '#FFFFFF' : Theme.colors().textPrimary)
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .backgroundColor(this.senseFilter.length === 0 ? '#1A2A3A' : Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
                .margin({ right: 8, bottom: 8 })
                .onClick((): void => {
                  this.senseFilter = ''
                  this.applyFilter()
                })
              ForEach(this.senses, (s: SenseOption) => {
                Text(s.label)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.senseFilter === s.key ? '#FFFFFF' : Theme.colors().textPrimary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .backgroundColor(this.senseFilter === s.key ? '#1A2A3A' : Theme.colors().brandPrimaryContainer)
                  .borderRadius(Theme.radius.pill)
                  .margin({ right: 8, bottom: 8 })
                  .onClick((): void => {
                    this.senseFilter = this.senseFilter === s.key ? '' : s.key
                    this.applyFilter()
                  })
              }, (s: SenseOption) => s.key)
            }
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

            if (this.topTags().length > 0) {
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.topTags(), (item: TagCloudItem) => {
                  Text(`${item.name} ${item.count}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.tagFilter === item.name ? '#FFFFFF' : Theme.colors().brandPrimary)
                    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                    .backgroundColor(this.tagFilter === item.name ? '#1A2A3A' : Theme.colors().brandPrimaryContainer)
                    .borderRadius(Theme.radius.pill)
                    .margin({ right: 8, bottom: 8 })
                    .onClick((): void => {
                      AppStorage.setOrCreate('tagFilter', this.tagFilter === item.name ? '' : item.name)
                      this.applyFilter()
                    })
                }, (item: TagCloudItem) => item.name)
              }
              .width('100%')
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s1 })
            }

            Row({ space: Theme.space.s2 }) {
              Text('今日')
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().brandPrimary)
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.setToday() })
              Text('近7日')
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().brandPrimary)
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.setWeek() })
              Text(this.onlyFav ? '珍藏中' : '只看珍藏')
                .fontSize(Theme.type.bodyS)
                .fontColor(this.onlyFav ? '#FFFFFF' : Theme.colors().brandPrimary)
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .backgroundColor(this.onlyFav ? '#1A2A3A' : Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => {
                  this.onlyFav = !this.onlyFav
                  this.applyFilter()
                })
              Text(this.sortNewest ? '最新' : '最早')
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textPrimary)
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => {
                  this.sortNewest = !this.sortNewest
                  this.applyFilter()
                })
              Text('清除')
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textSecondary)
                .onClick((): void => { this.clearDates() })
            }
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })

            Column({ space: Theme.space.s2 }) {
              AppDatePickerField({
                label: '起始日期',
                value: this.dateFrom,
                placeholder: '起始（含当天）',
                minDaysFromToday: -3650,
                maxDaysFromToday: 1,
                onChange: (v: string): void => {
                  this.dateFrom = v
                  this.applyFilter()
                }
              })
              AppDatePickerField({
                label: '结束日期',
                value: this.dateTo,
                placeholder: '结束（含当天）',
                minDaysFromToday: -3650,
                maxDaysFromToday: 1,
                onChange: (v: string): void => {
                  this.dateTo = v
                  this.applyFilter()
                }
              })
            }
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })

            if (this.loading) {
              Text('加载中…')
                .fontColor(Theme.colors().textSecondary)
                .padding({ left: Theme.space.pageX })
            } else if (this.filtered.length === 0) {
              AppEmpty({
                title: this.essays.length === 0 ? '还没有观察' : '没有匹配的观察',
                description: this.essays.length === 0 ? '点右上角 + 写下第一条' : '试试清除筛选',
                actionLabel: this.essays.length === 0 ? '写第一条' : '清除筛选',
                onAction: (): void => {
                  if (this.essays.length === 0) {
                    this.openNew()
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
                }, (item: MicroEssay) => `${item.id}_${item.updatedAt}_${item.favorite}`)
              }
              .width('100%')
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
            }
            Blank().height(Theme.space.s10)
          }
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
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
          onDeleted: (): void => {
            this.detailId = ''
            void this.reload()
          },
          onChanged: (): void => { void this.reload() },
          onOpenRelated: (id: string): void => { this.detailId = id }
        })
      }
      if (this.showEditor) {
        EssayEditorSheet({
          essayId: this.editingId,
          fontScale: this.fontScale,
          openAsCard: this.editingId.length === 0,
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
    .onAppear((): void => {
      if (this.dataEpoch !== this.lastEpoch || this.reloadToken >= 0) {
        this.lastEpoch = this.dataEpoch
        void this.reload()
      }
    })
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
      .onClick((): void => {
        this.kindFilter = key
        this.applyFilter()
      })
  }
}
