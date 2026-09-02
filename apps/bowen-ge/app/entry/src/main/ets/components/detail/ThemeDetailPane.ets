import { ThemeSpace, FeedItem } from '../../models/BowenModels'
import { BowenStore } from '../../services/BowenStore'
import { BowenQuery } from '../../services/BowenQuery'
import { BowenNav } from '../../services/BowenNav'
import { BowenMedia } from '../../services/BowenMedia'
import { FeedCardFromItem } from '../archive/FeedCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppCard } from '../design-system/AppCard'
import { Theme } from '../design-system/Theme'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct ThemeDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('bowenDataRev') bowenDataRev: number = 0
  @Prop itemId: string = ''
  @State item: ThemeSpace = new ThemeSpace()
  @State linked: FeedItem[] = []
  @State confirmDelete: boolean = false
  @State count: number = 0

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const t = await BowenStore.findTheme(this.itemId)
    if (t !== undefined) {
      this.item = t
    }
    this.linked = await BowenQuery.linkedToTheme(this.itemId)
    this.count = this.linked.length
  }

  private openItem(it: FeedItem): void {
    if (it.kind === 'reading') {
      BowenNav.openReading(it.id)
      return
    }
    if (it.kind === 'card') {
      BowenNav.openCard(it.id)
      return
    }
    if (it.kind === 'spark') {
      BowenNav.openSpark(it.id)
      return
    }
    BowenNav.openThought(it.id)
  }

  private async doDelete(): Promise<void> {
    await BowenStore.deleteTheme(this.item.id)
    this.confirmDelete = false
    BowenNav.closeDetails()
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(BowenMedia.coverTheme())
              .width('100%')
              .height(200)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(88)
              .linearGradient({
                angle: 180,
                colors: [['rgba(18,38,47,0)', 0], ['rgba(18,38,47,0.78)', 1]]
              })
            Column({ space: 4 }) {
              Text(`${this.count} 条关联 · ${DateHelper.displayDateFromTs(this.item.updatedAt)}`)
                .fontSize(Theme.type.caption)
                .fontColor('#F6F1E8')
              Text(this.item.title)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Bold)
                .fontColor('#F6F1E8')
            }
            .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
          }
          .clip(true)
          .borderRadius(Theme.radius.md)

          AppCard({ title: '专题说明', variant: 'plain' }) {
            Text(this.item.summary.length > 0 ? this.item.summary : '还没有写专题说明。')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textSecondary)
          }

          Text('关联内容')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')

          if (this.linked.length === 0) {
            AppEmpty({ title: '专题还是空的', description: '在思考或阅读里把内容挂到这个专题' })
          } else {
            ForEach(this.linked, (it: FeedItem) => {
              FeedCardFromItem({ item: it, onTap: (): void => { this.openItem(it) } })
            }, (it: FeedItem) => it.id)
          }

          AppButton({ label: '编辑专题', variant: 'primary', onTap: (): void => { BowenNav.openEditor('theme', this.item.id) } })
          AppButton({ label: '删除专题', variant: 'danger', onTap: (): void => { this.confirmDelete = true } })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10, top: Theme.space.s2 })
      }
      .layoutWeight(1)

      if (this.confirmDelete) {
        Column({ space: Theme.space.s3 }) {
          Text('删除专题不会删除其中的内容，只会解除关联。')
            .fontColor(Theme.colors().textPrimary)
          AppButton({ label: '确认删除', variant: 'danger', onTap: (): void => { void this.doDelete() } })
          AppButton({ label: '取消', variant: 'secondary', onTap: (): void => { this.confirmDelete = false } })
        }
        .padding(Theme.space.s5)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
        .margin({ left: 24, right: 24, bottom: 40 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
