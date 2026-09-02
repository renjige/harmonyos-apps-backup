import { Theme } from '../components/design-system/Theme'
import { AppNavBar } from '../components/design-system/AppNavBar'
import { AppListRow } from '../components/design-system/AppListRow'
import { AppButton } from '../components/design-system/AppButton'
import { UserPrefsService } from '../services/UserPrefsService'
import { BrowseRecord } from '../models/ZhukeModels'
import { AppEmpty } from '../components/design-system/AppEmpty'

@Component
export struct HistoryPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: BrowseRecord[] = []
  onBack: () => void = () => {}
  onOpenItem: (type: string, id: string) => void = (_type: string, _id: string) => {}

  aboutToAppear(): void {
    this.reload()
  }

  private reload(): void {
    this.items = UserPrefsService.history()
  }

  build() {
    Column() {
      AppNavBar({ title: '浏览记录', onBack: () => this.onBack() })

      if (this.items.length === 0) {
        AppEmpty({ title: '暂无浏览记录', description: '浏览内容后将在此显示' }).layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Column() {
              ForEach(this.items, (r: BrowseRecord, index: number) => {
                AppListRow({
                  title: r.title,
                  subtitle: r.viewedAt,
                  showDivider: index < this.items.length - 1,
                  onTap: () => this.onOpenItem(r.type, r.id)
                })
              }, (r: BrowseRecord) => `${r.type}:${r.id}:${r.viewedAt}`)
            }
            .padding({ left: Theme.space.s3, right: Theme.space.s3 })
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)

            AppButton({
              label: '清空浏览记录',
              variant: 'ghost',
              onTap: () => {
                UserPrefsService.clearHistory()
                this.reload()
              }
            })
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s8
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
