import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { AtlasKind, DailyTheme, ExploreQuest, FieldRecord, TagPreset } from '../models/FieldModels'
import { FieldStore } from '../services/FieldStore'
import { GewuDetailNav } from '../services/GewuDetailNav'
import { GewuMedia } from '../services/GewuMedia'
import { DateHelper } from '../services/DateHelper'

@Component
export struct RecordPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State records: FieldRecord[] = []
  @State visible: FieldRecord[] = []
  @State quests: ExploreQuest[] = []
  @State keyword: string = ''
  @State atlasFilter: string = 'all'
  @State tagFilter: string = ''
  @State themeLine: string = ''
  @StorageLink('recordDateFilter') @Watch('onDateFilter') recordDateFilter: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  onDateFilter(): void {
    this.applyFilter()
  }

  private async reload(): Promise<void> {
    this.themeLine = DailyTheme.today()
    this.records = await FieldStore.loadRecords()
    this.quests = await FieldStore.todayQuests()
    this.applyFilter()
  }

  private applyFilter(): void {
    const q = this.keyword.trim()
    const out: FieldRecord[] = []
    for (const r of this.records) {
      if (this.recordDateFilter.length > 0 && r.dateKey !== this.recordDateFilter) {
        continue
      }
      if (this.atlasFilter !== 'all' && r.atlasKind !== this.atlasFilter) {
        continue
      }
      if (this.tagFilter.length > 0 && r.tags.indexOf(this.tagFilter) < 0) {
        continue
      }
      if (q.length > 0 && r.title.indexOf(q) < 0 && r.body.indexOf(q) < 0 && r.atlasKind.indexOf(q) < 0) {
        continue
      }
      out.push(r)
    }
    this.visible = out
  }

  private goPickFromAtlas(): void {
    AppStorage.setOrCreate('folioListMode', 'all')
    AppStorage.setOrCreate('folioAtlasFilter', 'all')
    AppStorage.setOrCreate('switchTabIndex', 1)
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        Text('格物观察札')
          .fontSize(22)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s5 })
        Text('关联图鉴条目的观察笔记，非空白自由记事')
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })
        if (this.recordDateFilter.length > 0) {
          Text(`正在看 ${this.recordDateFilter} 的记录（点此清除日期）`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandPrimary)
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })
            .onClick((): void => { AppStorage.setOrCreate('recordDateFilter', '') })
        }

        Scroll() {
          Column({ space: Theme.space.s3 }) {
            Column({ space: 6 }) {
              Text('今日探索方向')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
              Text(this.themeLine)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
                .lineHeight(22)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .padding(14)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(16)

            Text('探索任务')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.quests, (q: ExploreQuest) => {
              Row({ space: Theme.space.s2 }) {
                AppIcon({
                  name: q.done ? 'check' : 'empty',
                  iconSize: Theme.icon.sm,
                  color: q.done ? Theme.colors().success : Theme.colors().textTertiary
                })
                Column({ space: 2 }) {
                  Text(q.title)
                    .fontSize(Theme.type.bodyS)
                    .fontColor(Theme.colors().textPrimary)
                  Text(q.hint)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textTertiary)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')
              .padding(10)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(12)
              .onClick((): void => {
                if (q.id === 'read') {
                  AppStorage.setOrCreate('switchTabIndex', 0)
                } else if (q.id === 'record') {
                  this.goPickFromAtlas()
                } else if (q.id === 'collect') {
                  AppStorage.setOrCreate('folioListMode', 'favorite')
                  AppStorage.setOrCreate('switchTabIndex', 1)
                } else if (q.id === 'plant') {
                  AppStorage.setOrCreate('folioAtlasFilter', '植物图鉴')
                  AppStorage.setOrCreate('folioListMode', 'all')
                  AppStorage.setOrCreate('switchTabIndex', 1)
                }
              })
            }, (q: ExploreQuest) => q.id)

            TextInput({ text: this.keyword, placeholder: '按名称、分类或正文搜索' })
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textTertiary)
              .caretColor(Theme.colors().brandPrimary)
              .backgroundColor(Theme.colors().surfaceCard)
              .onChange((v: string): void => {
                this.keyword = v
                this.applyFilter()
              })

            Scroll() {
              Row({ space: 8 }) {
                Text('全部图鉴')
                  .fontSize(12)
                  .fontColor(this.atlasFilter === 'all' ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .backgroundColor(this.atlasFilter === 'all' ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => {
                    this.atlasFilter = 'all'
                    this.applyFilter()
                  })
                ForEach(AtlasKind.all(), (k: string) => {
                  Text(k)
                    .fontSize(12)
                    .fontColor(this.atlasFilter === k ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                    .backgroundColor(this.atlasFilter === k ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                    .borderRadius(Theme.radius.pill)
                    .onClick((): void => {
                      this.atlasFilter = k
                      this.applyFilter()
                    })
                }, (k: string) => k)
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')

            Scroll() {
              Row({ space: 8 }) {
                Text('全部标签')
                  .fontSize(12)
                  .fontColor(this.tagFilter.length === 0 ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .backgroundColor(this.tagFilter.length === 0 ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => {
                    this.tagFilter = ''
                    this.applyFilter()
                  })
                ForEach(TagPreset.all(), (t: string) => {
                  Text(t)
                    .fontSize(12)
                    .fontColor(this.tagFilter === t ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                    .backgroundColor(this.tagFilter === t ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                    .borderRadius(Theme.radius.pill)
                    .onClick((): void => {
                      this.tagFilter = this.tagFilter === t ? '' : t
                      this.applyFilter()
                    })
                }, (t: string) => t)
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')

            if (this.visible.length === 0) {
              AppEmpty({
                title: this.records.length === 0 ? '还没有观察札' : '没有匹配的观察札',
                description: this.records.length === 0 ?
                  '请从图鉴选一物，用观察模板写下发现（非空白自由记事）' : '换个图鉴分类或清空搜索',
                actionLabel: '去图鉴选物',
                onAction: (): void => { this.goPickFromAtlas() }
              })
            } else {
              ForEach(this.visible, (r: FieldRecord) => {
                Row({ space: Theme.space.s3 }) {
                  Image(GewuMedia.coverResource(r.coverKey))
                    .width(64)
                    .height(64)
                    .objectFit(ImageFit.Cover)
                    .borderRadius(12)
                  Column({ space: 4 }) {
                    Text(r.title)
                      .fontSize(Theme.type.subhead)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(Theme.colors().textPrimary)
                    Text(`${r.atlasKind} · ${DateHelper.displayShort(r.dateKey)}`)
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().textSecondary)
                    Text(r.preview())
                      .fontSize(Theme.type.bodyS)
                      .fontColor(Theme.colors().textTertiary)
                      .maxLines(2)
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                }
                .width('100%')
                .padding(12)
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(16)
                .onClick((): void => { GewuDetailNav.openRecord(r.id) })
              }, (r: FieldRecord) => r.id)
            }
            Row().height(this.bottomInset + 56)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }
        .layoutWeight(1)
        .width('100%')
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')

      Column() {
        AppIcon({ name: 'book', iconSize: Theme.icon.xl, color: '#FFFFFF' })
      }
      .width(56)
      .height(56)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimary)
      .borderRadius(Theme.radius.pill)
      .margin({ right: 20, bottom: this.bottomInset + 8 })
      .onClick((): void => { this.goPickFromAtlas() })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
