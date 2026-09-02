import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { JianListCard } from '../components/jian/JianListCard'
import { JianDetailPane } from '../components/jian/JianDetailPane'
import { JianWritePane } from '../components/jian/JianWritePane'
import { JianEntry } from '../models/JianModels'
import { WisdomQuote } from '../models/JianModels'
import { DateHelper } from '../services/DateHelper'
import { JianStore } from '../services/JianStore'
import { WisdomService } from '../services/WisdomService'

class ViewModeItem {
  id: string = ''
  label: string = ''

  constructor(id: string, label: string) {
    this.id = id
    this.label = label
  }
}

@Component
export struct TimelinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State entries: JianEntry[] = []
  @State filtered: JianEntry[] = []
  @State loading: boolean = true
  @State detailEntry: JianEntry | undefined = undefined
  @State showWrite: boolean = false
  @State viewMode: string = 'week'
  @State dailyQuote: WisdomQuote = new WisdomQuote()
  @Prop reloadToken: number = 0
  @State lastToken: number = -1
  private modes: ViewModeItem[] = [
    new ViewModeItem('day', '日'),
    new ViewModeItem('week', '周'),
    new ViewModeItem('month', '月')
  ]

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.entries = await JianStore.loadAll()
    this.dailyQuote = await WisdomService.dailyQuote()
    this.applyFilter()
    this.loading = false
  }

  private applyFilter(): void {
    const today = DateHelper.todayKey()
    const out: JianEntry[] = []
    if (this.viewMode === 'day') {
      for (const it of this.entries) {
        if (it.dateKey === today) {
          out.push(it)
        }
      }
    } else if (this.viewMode === 'week') {
      const start = DateHelper.shiftKey(today, -6)
      for (const it of this.entries) {
        if (it.dateKey >= start && it.dateKey <= today) {
          out.push(it)
        }
      }
    } else {
      const parts = today.split('-')
      const prefix = `${parts[0]}-${parts[1]}`
      for (const it of this.entries) {
        if (it.dateKey.indexOf(prefix) === 0) {
          out.push(it)
        }
      }
    }
    this.filtered = out
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      List({ space: Theme.space.s3 }) {
        ListItem() {
          this.HeroHeader()
        }

        if (this.loading) {
          ListItem() {
            Text('加载中…')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
              .padding({ top: Theme.space.s2, bottom: Theme.space.s4 })
          }
        } else if (this.filtered.length === 0) {
          ListItem() {
            Column({ space: Theme.space.s4 }) {
              Image($r('app.media.empty_timeline'))
                .width('100%')
                .height(168)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.lg)
              Column({ space: Theme.space.s2 }) {
                Text('时间轴尚空')
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                Text('点击下方按钮，写下你的第一页笺记')
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .lineHeight(22)
                  .textAlign(TextAlign.Center)
              }
              .width('100%')
              .padding({ left: Theme.space.s4, right: Theme.space.s4 })
              AppButton({
                label: '写一笺',
                variant: 'primary',
                onTap: (): void => { this.showWrite = true }
              })
            }
            .width('100%')
            .padding({ top: Theme.space.s2, bottom: Theme.space.s10 })
            .alignItems(HorizontalAlign.Center)
          }
        } else {
          ForEach(this.filtered, (item: JianEntry) => {
            ListItem() {
              JianListCard({
                entry: item,
                onTap: (): void => { this.detailEntry = item }
              })
            }
          }, (item: JianEntry) => item.id)
        }
      }
      .width('100%')
      .height('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      Row() {
        AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.colors().textOnInverse })
      }
      .width(56)
      .height(56)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimary)
      .borderRadius(Theme.radius.pill)
      .shadow({ radius: 16, color: 'rgba(139,107,77,0.35)', offsetY: 4 })
      .margin({ right: Theme.space.pageX, bottom: Theme.space.s4 })
      .onClick((): void => { this.showWrite = true })

      if (this.detailEntry !== undefined) {
        JianDetailPane({
          entry: this.detailEntry,
          onClose: (): void => { this.detailEntry = undefined },
          onChanged: (): void => {
            this.detailEntry = undefined
            void this.reload()
          }
        })
      }

      if (this.showWrite) {
        JianWritePane({
          onClose: (): void => { this.showWrite = false },
          onSaved: (): void => { void this.reload() }
        })
      }
    }
    .width('100%')
    .height('100%')
    .onAppear((): void => {
      if (this.reloadToken !== this.lastToken) {
        this.lastToken = this.reloadToken
        void this.reload()
      }
    })
  }

  @Builder
  HeroHeader() {
    Column({ space: Theme.space.s3 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image($r('app.media.hero_paper_bg'))
          .width('100%')
          .height(120)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.lg)
        Column({ space: 4 }) {
          Text('纸间光阴')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Text(this.dailyQuote.text)
            .fontSize(Theme.type.bodyS)
            .fontColor('#FFFFFF')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')
        .padding(Theme.space.s4)
        .borderRadius(Theme.radius.lg)
        .linearGradient({
          angle: 180,
          colors: [['rgba(0,0,0,0)', 0], ['rgba(61,61,61,0.75)', 1]]
        })
      }
      .width('100%')

      Row({ space: Theme.space.s2 }) {
        ForEach(this.modes, (m: ViewModeItem) => {
          Text(m.label)
            .fontSize(Theme.type.bodyS)
            .fontColor(this.viewMode === m.id ?
              Theme.colors().brandPrimary : Theme.colors().textSecondary)
            .padding({ left: 14, right: 14, top: 6, bottom: 6 })
            .backgroundColor(this.viewMode === m.id ?
              Theme.colors().brandPrimaryContainer : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => {
              this.viewMode = m.id
              this.applyFilter()
            })
        }, (m: ViewModeItem) => m.id)
      }
      .width('100%')
    }
    .width('100%')
    .padding({ top: Theme.space.s3, bottom: Theme.space.s2 })
  }
}
