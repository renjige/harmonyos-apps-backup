import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { EssayListCard } from './EssayListCard'
import { ObserveTheme } from '../../models/GrowthModels'
import { MicroEssay, SenseOption } from '../../models/EssayModels'
import { EssayStore } from '../../services/EssayStore'
import { GrowthStore } from '../../services/GrowthStore'

@Component
export struct ThemeListPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('essayFontScale') fontScale: number = 1
  @StorageLink('essayDataEpoch') @Watch('onData') dataEpoch: number = 0
  onClose: () => void = () => {}
  onCreate: () => void = () => {}
  onOpenEssay: (id: string) => void = () => {}

  @State themes: ObserveTheme[] = []
  @State essays: MicroEssay[] = []
  @State selectedId: string = ''
  @State progressText: string = ''
  @State confirmDelete: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onData(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.essays = await EssayStore.loadAll()
    this.themes = await GrowthStore.loadThemes()
    if (this.selectedId.length > 0) {
      this.refreshProgress()
    }
  }

  private selected(): ObserveTheme | undefined {
    for (const t of this.themes) {
      if (t.id === this.selectedId) {
        return t
      }
    }
    return undefined
  }

  private themeEssays(): MicroEssay[] {
    const t = this.selected()
    if (t === undefined) {
      return []
    }
    const out: MicroEssay[] = []
    for (const it of this.essays) {
      if (GrowthStore.essayCountsForTheme(t, it)) {
        out.push(it)
      }
    }
    return out
  }

  private selectedTitle(): string {
    const t = this.selected()
    if (t === undefined) {
      return ''
    }
    return t.title
  }

  private progressLine(item: ObserveTheme): string {
    const n = GrowthStore.themeProgress(item, this.essays)
    const st = item.status === 'done' ? '已完成' : '进行中'
    return `${n} / ${item.targetCount} · ${st} · ${SenseOption.labelOf(item.senseKey)}`
  }

  private refreshProgress(): void {
    const t = this.selected()
    if (t === undefined) {
      this.progressText = ''
      return
    }
    const n = GrowthStore.themeProgress(t, this.essays)
    const pct = t.targetCount > 0 ? Math.round(n * 100 / t.targetCount) : 0
    const cap = pct > 100 ? 100 : pct
    this.progressText = `${n} / ${t.targetCount} · ${cap}% · ${SenseOption.labelOf(t.senseKey)}`
  }

  private openTheme(id: string): void {
    this.selectedId = id
    this.confirmDelete = false
    this.refreshProgress()
  }

  private async archiveSelected(): Promise<void> {
    const t = this.selected()
    if (t === undefined) {
      return
    }
    if (!this.confirmDelete) {
      this.confirmDelete = true
      return
    }
    await GrowthStore.deleteTheme(t.id)
    this.selectedId = ''
    this.confirmDelete = false
    await this.reload()
  }

  build() {
    Column() {
      Row() {
        Text(this.selectedId.length > 0 ? '专题详情' : '观察专题')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Blank()
        if (this.selectedId.length > 0) {
          Text('返回列表')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().brandPrimary)
            .onClick((): void => { this.selectedId = '' })
        } else {
          Text('关闭')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().brandPrimary)
            .onClick((): void => { this.onClose() })
        }
      }
      .width('100%')
      .padding(Theme.space.pageX)

      if (this.selectedId.length === 0) {
        Text('给自己定一个感官目标，写满篇数即完成。')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
          .padding({ left: Theme.space.pageX, bottom: Theme.space.s3 })
        Text('新建专题')
          .fontSize(Theme.type.body)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .textAlign(TextAlign.Center)
          .width('90%')
          .padding({ top: 12, bottom: 12 })
          .backgroundColor('#1A2A3A')
          .borderRadius(Theme.radius.md)
          .margin({ left: Theme.space.pageX, bottom: Theme.space.s3 })
          .onClick((): void => { this.onCreate() })
        if (this.themes.length === 0) {
          AppEmpty({
            title: '还没有观察专题',
            description: '例如「这个月只写气味」，目标 5 篇',
            actionLabel: '新建专题',
            onAction: (): void => { this.onCreate() }
          })
        } else {
          Scroll() {
            Column({ space: Theme.space.s3 }) {
              ForEach(this.themes, (item: ObserveTheme) => {
                Column({ space: 4 }) {
                  Text(item.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                  Text(this.progressLine(item))
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .width('100%')
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.md)
                .onClick((): void => { this.openTheme(item.id) })
              }, (item: ObserveTheme) => item.id)
              Blank().height(Theme.space.s8)
            }
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          }
          .layoutWeight(1)
        }
      } else {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.banner_micro'))
            .width('100%')
            .height(120)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.md)
          Column() {
            Blank()
            Column({ space: 4 }) {
              Text(this.selectedTitle())
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
                .width('100%')
              Text(this.progressText)
                .fontSize(Theme.type.caption)
                .fontColor('#FFFFFF')
                .width('100%')
            }
            .width('100%')
            .padding(Theme.space.s4)
            .linearGradient({
              angle: 180,
              colors: [['rgba(0,0,0,0)', 0], ['rgba(26,42,58,0.82)', 1]]
            })
          }
          .width('100%')
          .height(120)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.themeEssays(), (item: MicroEssay) => {
              EssayListCard({
                essay: item,
                fontScale: this.fontScale,
                onTap: (): void => { this.onOpenEssay(item.id) }
              })
            }, (item: MicroEssay) => item.id)
            if (this.themeEssays().length === 0) {
              AppEmpty({
                title: '这个专题还没有观察',
                description: '用对应感官写一篇，进度会立刻增加',
                actionLabel: '',
                onAction: (): void => {}
              })
            }
            Text(this.confirmDelete ? '再点一次删除专题' : '删除此专题')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
              .textAlign(TextAlign.Center)
              .padding({ top: 8, bottom: 16 })
              .onClick((): void => { void this.archiveSelected() })
            Blank().height(Theme.space.s8)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .zIndex(40)
    .onAppear((): void => { AppStorage.setOrCreate('tabBarHidden', true) })
    .onDisAppear((): void => { AppStorage.setOrCreate('tabBarHidden', false) })
  }
}
