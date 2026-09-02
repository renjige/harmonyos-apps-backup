import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { JournalCard } from '../components/wander/JournalCard'
import { JournalItem } from '../models/WanderModels'
import { WanderDetailNav } from '../services/WanderDetailNav'
import { WanderLocalStore } from '../services/WanderLocalStore'

@Component
export struct JournalListPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State items: JournalItem[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await WanderLocalStore.loadJournals()
  }

  private preview(it: JournalItem): string {
    if (it.body.length <= 42) {
      return it.body
    }
    return `${it.body.substring(0, 42)}…`
  }

  build() {
    Column() {
      Row() {
        Text('手记')
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

      if (this.items.length === 0) {
        Column() {
          AppEmpty({
            title: '还没有写下沿途',
            description: '走完一段路，回来留一句就好。',
            actionLabel: '写一篇',
            onAction: (): void => WanderDetailNav.openJournalNew('', '', '')
          })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 12 }) {
          ForEach(this.items, (it: JournalItem) => {
            ListItem() {
              JournalCard({
                title: it.title,
                place: it.place,
                mood: it.mood,
                dateLabel: it.dateLabel,
                preview: this.preview(it),
                onTap: (): void => WanderDetailNav.openJournal(it.id)
              })
            }
          }, (it: JournalItem) => it.id)
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
  }
}
