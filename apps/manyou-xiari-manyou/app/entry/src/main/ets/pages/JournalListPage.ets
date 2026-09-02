import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { JournalCard } from '../components/wander/JournalCard'
import { JournalItem } from '../models/WanderModels'
import { WanderDetailNav } from '../services/WanderDetailNav'
import { WanderLocalStore } from '../services/WanderLocalStore'

class JournalListRow {
  kind: string = 'item'
  groupLabel: string = ''
  item: JournalItem = new JournalItem()
}

@Component
export struct JournalListPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State rows: JournalListRow[] = []
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const groups = WanderLocalStore.groupJournalsByMonth(await WanderLocalStore.loadJournals())
    const next: JournalListRow[] = []
    for (const g of groups) {
      const head = new JournalListRow()
      head.kind = 'header'
      head.groupLabel = g.label
      next.push(head)
      for (const it of g.items) {
        const row = new JournalListRow()
        row.kind = 'item'
        row.item = it
        next.push(row)
      }
    }
    this.rows = next
  }

  private preview(it: JournalItem): string {
    if (it.body.length <= 42) {
      return it.body
    }
    return `${it.body.substring(0, 42)}…`
  }

  private async deleteItem(id: string): Promise<void> {
    await WanderLocalStore.removeJournal(id)
    WanderLocalStore.notifyDataChanged()
    this.toastText = '已删除这条记录'
    setTimeout(() => { this.toastText = '' }, 2200)
    await this.reload()
  }

  private isEmpty(): boolean {
    for (const r of this.rows) {
      if (r.kind === 'item') {
        return false
      }
    }
    return true
  }

  private rowKey(r: JournalListRow): string {
    if (r.kind === 'header') {
      return `h_${r.groupLabel}`
    }
    return r.item.id
  }

  @Builder
  DeleteAction(id: string) {
    Row() {
      Text('删除')
        .fontSize(Theme.type.subhead)
        .fontColor(Theme.colors().brandOnPrimary)
    }
    .width(72)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Theme.colors().danger)
    .onClick((): void => { void this.deleteItem(id) })
  }

  @Builder
  ListRow(r: JournalListRow) {
    if (r.kind === 'header') {
      ListItem() {
        Text(r.groupLabel)
          .fontSize(Theme.type.caption)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
          .padding({ top: 8, bottom: 4 })
      }
    } else {
      ListItem() {
        JournalCard({
          title: r.item.title,
          place: r.item.place,
          mood: r.item.mood,
          dateLabel: r.item.dateLabel,
          preview: this.preview(r.item),
          photoUri: r.item.photoUri,
          coverKey: r.item.coverKey,
          onTap: (): void => WanderDetailNav.openJournal(r.item.id)
        })
      }
      .swipeAction({
        end: {
          actionAreaDistance: 72,
          builder: () => {
            this.DeleteAction(r.item.id)
          }
        }
      })
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row() {
          Text('漫游记录')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
          AppButton({
            label: '新建',
            variant: 'secondary',
            onTap: (): void => WanderDetailNav.openJournalNew('', '', '')
          }).width(88)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 12, bottom: 8 })

        if (this.isEmpty()) {
          Column() {
            AppEmpty({
              title: '还没有写下沿途',
              description: '走完一段路，回来留一句就好。',
              actionLabel: '写一条记录',
              onAction: (): void => WanderDetailNav.openJournalNew('', '', '')
            })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          List({ space: 12 }) {
            ForEach(this.rows, (r: JournalListRow) => {
              this.ListRow(r)
            }, (r: JournalListRow) => this.rowKey(r))
          }
          .width('100%')
          .layoutWeight(1)
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 16 })
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 56 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
