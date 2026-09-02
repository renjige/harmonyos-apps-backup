import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { DiaryListCard } from '../components/diary/DiaryListCard'
import { DiaryEntry } from '../models/DiaryModels'
import { DiaryStore } from '../services/DiaryStore'
import { DiaryDetailPane } from '../components/diary/DiaryDetailPane'

@Component
export struct TimelinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State entries: DiaryEntry[] = []
  @State loading: boolean = true
  @State detailEntry: DiaryEntry | undefined = undefined
  onOpenReview: () => void = () => {}
  @Prop reloadToken: number = 0
  @State lastToken: number = -1

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.entries = await DiaryStore.loadAll()
    this.loading = false
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text('全部记录')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Row({ space: 4 }) {
            Text('智慧回顾')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().brandPrimary })
          }
          .onClick((): void => { this.onOpenReview() })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4, bottom: Theme.space.s2 })

        if (this.loading) {
          Text('加载中…')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .margin(Theme.space.pageX)
        } else if (this.entries.length === 0) {
          Column({ space: Theme.space.s4 }) {
            Image($r('app.media.empty_timeline'))
              .width('72%')
              .aspectRatio(1)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.lg)
            AppEmpty({
              title: '还没有记录',
              description: '去「记录」页写下第一篇日记吧',
              actionLabel: '',
              onAction: (): void => {}
            })
          }
          .width('100%')
          .padding(Theme.space.pageX)
        } else {
          List({ space: Theme.space.s3 }) {
            ForEach(this.entries, (item: DiaryEntry) => {
              ListItem() {
                DiaryListCard({
                  entry: item,
                  onTap: (): void => { this.detailEntry = item }
                })
              }
            }, (item: DiaryEntry) => item.id)
          }
          .width('100%')
          .layoutWeight(1)
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s8 })
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.detailEntry !== undefined) {
        DiaryDetailPane({
          entry: this.detailEntry,
          onClose: (): void => { this.detailEntry = undefined },
          onDeleted: (): void => {
            this.detailEntry = undefined
            void this.reload()
          }
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
}
