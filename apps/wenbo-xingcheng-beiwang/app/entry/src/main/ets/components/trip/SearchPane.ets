import { Theme } from '../design-system/Theme'
import { AppNavBar } from '../design-system/AppNavBar'
import { AppEmpty } from '../design-system/AppEmpty'
import { TripListCard } from './TripListCard'
import { TripItem } from '../../models/TripModels'
import { TripStore } from '../../services/TripStore'
import { TripNav } from '../../services/TripNav'

@Component
export struct SearchPane {
  @State query: string = ''
  @State hits: TripItem[] = []
  @StorageLink('darkModeOn') darkModeOn: boolean = false

  aboutToAppear(): void {
    this.runSearch()
  }

  private runSearch(): void {
    const q = this.query.trim()
    const out: TripItem[] = []
    for (const t of TripStore.allTrips()) {
      if (q.length === 0) {
        out.push(t)
      } else if (t.title.indexOf(q) >= 0 || t.location.indexOf(q) >= 0) {
        out.push(t)
      }
    }
    this.hits = out
  }

  build() {
    Column() {
      AppNavBar({
        title: '搜索行程',
        onBack: (): void => { TripNav.closeSearch() }
      })
      TextInput({ text: this.query, placeholder: '名称或地点' })
        .height(48)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 12 })
        .fontColor(Theme.palette(this.darkModeOn).textPrimary)
        .placeholderColor(Theme.palette(this.darkModeOn).textTertiary)
        .caretColor(Theme.palette(this.darkModeOn).brandPrimary)
        .backgroundColor(Theme.palette(this.darkModeOn).surfaceCard)
        .borderRadius(Theme.radius.sm)
        .padding({ left: 14, right: 14 })
        .onChange((v: string) => {
          this.query = v
          this.runSearch()
        })
      if (this.hits.length === 0) {
        AppEmpty({
          title: '没有找到行程',
          description: this.query.length > 0 ? '换个关键词试试。' : '还没有可搜索的行程。'
        })
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.hits, (t: TripItem) => {
              TripListCard({
                trip: t,
                onTap: (): void => {
                  TripNav.closeSearch()
                  TripNav.openDetail(t.id)
                }
              })
            }, (t: TripItem) => t.id)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.palette(this.darkModeOn).surfacePage)
  }
}
