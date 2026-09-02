import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { PoemListCard } from '../components/courtyard/PoemListCard'
import { HomeChipDef, HomeFilterChip } from '../components/courtyard/HomeFilterChip'
import { CourtyardBizService } from '../services/CourtyardBizService'
import { CourtyardDetailNav } from '../services/CourtyardDetailNav'
import { CourtyardMedia } from '../services/CourtyardMedia'
import { PoemItem } from '../models/CourtyardModels'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '词韵小院'
  @Prop tagline: string = ''
  @State daily: PoemItem = new PoemItem()
  @State poems: PoemItem[] = []
  @State query: string = ''
  @State dynasty: string = ''
  @State form: string = ''
  @State themeFilter: string = ''
  @State loading: boolean = false
  private chips: HomeChipDef[] = HomeChipDef.catalog()
  onOpenMessages: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    const d = await CourtyardBizService.loadDaily()
    if (d !== undefined) {
      this.daily = d
    }
    this.poems = await CourtyardBizService.loadPoems(this.query, this.dynasty, this.form, this.themeFilter)
    this.loading = false
  }

  private async pickRandom(): Promise<void> {
    const row = await CourtyardBizService.loadRandom()
    if (row !== undefined) {
      CourtyardDetailNav.openPoem(row.id)
    }
  }

  private chipSelected(group: string, value: string): boolean {
    if (group === 'all') {
      return this.dynasty.length === 0 && this.form.length === 0 && this.themeFilter.length === 0
    }
    if (group === 'dynasty') {
      return this.dynasty === value
    }
    if (group === 'form') {
      return this.form === value
    }
    return this.themeFilter === value
  }

  private selectChipById(id: string): void {
    const list = this.chips
    for (let i = 0; i < list.length; i++) {
      const row = list[i]
      if (row.id === id) {
        this.selectChip(row.group, row.value)
        return
      }
    }
  }

  private selectChip(group: string, value: string): void {
    if (group === 'all') {
      this.dynasty = ''
      this.form = ''
      this.themeFilter = ''
    } else if (group === 'dynasty') {
      this.dynasty = this.dynasty === value ? '' : value
    } else if (group === 'form') {
      this.form = this.form === value ? '' : value
    } else {
      this.themeFilter = this.themeFilter === value ? '' : value
    }
    void this.reload()
  }

  build() {
    Column() {
      Row() {
        Column({ space: 2 }) {
          Text(this.appName)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text('今日一诗 · 可检索 · 可拾贝')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        Row({ space: 8 }) {
          Column() {
            AppIcon({ name: 'refresh', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { void this.pickRandom() })
          Column() {
            AppIcon({ name: 'message', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onOpenMessages() })
        }
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s4,
        bottom: Theme.space.s2
      })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack() {
            Image(CourtyardMedia.cover(this.daily.coverKey.length > 0 ? this.daily.coverKey : 'hero_courtyard'))
              .width('100%')
              .height(240)
              .objectFit(ImageFit.Cover)
            Column({ space: 6 }) {
              Text('每日一诗')
                .fontSize(Theme.type.caption)
                .fontColor('#F5F0E8')
              Text(this.daily.title.length > 0 ? this.daily.title : '加载中')
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
              Text(this.daily.metaLine())
                .fontSize(Theme.type.bodyS)
                .fontColor('#F5F0E8')
              Text(this.daily.summary)
                .fontSize(Theme.type.bodyM)
                .fontColor('#FFFFFF')
                .maxLines(2)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .linearGradient({
              angle: 180,
              colors: [['rgba(44,24,16,0.05)', 0], ['rgba(44,24,16,0.92)', 1]]
            })
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .borderRadius(Theme.radius.md)
          .clip(true)
          .alignContent(Alignment.BottomStart)
          .onClick((): void => {
            if (this.daily.id.length > 0) {
              CourtyardDetailNav.openPoem(this.daily.id)
            }
          })

          Image($r('app.media.banner_ink'))
            .width('100%')
            .height(120)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.md)
            .onClick((): void => { void this.pickRandom() })

          Image($r('app.media.banner_window'))
            .width('100%')
            .height(120)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.md)
            .onClick((): void => { AppStorage.setOrCreate('switchTab', 2) })

          TextInput({ text: this.query, placeholder: '检索作者、标题、诗句、朝代' })
            .height(44)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.pill)
            .padding({ left: 16, right: 16 })
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .onChange((v: string) => { this.query = v })
            .onSubmit((): void => { void this.reload() })

          Scroll() {
            Row({ space: 8 }) {
              ForEach(this.chips, (c: HomeChipDef) => {
                HomeFilterChip({
                  label: c.label,
                  selected: this.chipSelected(c.group, c.value),
                  onPick: (): void => { this.selectChipById(c.id) }
                })
              }, (c: HomeChipDef) => `${c.id}_${this.dynasty}_${this.form}_${this.themeFilter}`)
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')

          if (this.poems.length === 0 && !this.loading) {
            AppEmpty({ title: '诗库空', description: '下拉或点拾贝再试', actionLabel: '重试', onAction: (): void => { void this.reload() } })
          }
          ForEach(this.poems, (p: PoemItem) => {
            PoemListCard({
              poemId: p.id,
              title: p.title,
              meta: p.metaLine(),
              summary: p.summary,
              coverKey: p.coverKey,
              onOpen: (id: string): void => { CourtyardDetailNav.openPoem(id) }
            })
          }, (p: PoemItem) => p.id)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s8 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
