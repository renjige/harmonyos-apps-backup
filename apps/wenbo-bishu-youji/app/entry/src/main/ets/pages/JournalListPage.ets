import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { JournalCard } from '../components/escape/JournalCard'
import { JournalItem } from '../models/EscapeModels'
import { AuthService } from '../services/AuthService'
import { EscapeBizService } from '../services/EscapeBizService'
import { EscapeDetailNav } from '../services/EscapeDetailNav'

@Component
export struct JournalListPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State loading: boolean = true
  @State items: JournalItem[] = []
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (!AuthService.isLoggedIn()) {
      this.items = []
      this.loading = false
      return
    }
    this.items = await EscapeBizService.loadJournals()
    this.loading = false
  }

  private newJournal(): void {
    if (!AuthService.requireAuth('create_journal')) {
      this.onRequireAuth()
      return
    }
    EscapeDetailNav.openJournalNew('', '', '')
  }

  build() {
    Column() {
      Row() {
        Text('我的游记')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
        AppButton({
          label: '新建游记',
          onTap: (): void => { this.newJournal() }
        })
        .width(112)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 12, bottom: 8 })

      if (this.loading) {
        AppLoading({ label: '翻开时间线' }).layoutWeight(1)
      } else if (!AuthService.isLoggedIn()) {
        AppEmpty({
          title: '登录后写下旅途',
          description: '游客可以先逛目的地。写游记需要账号。',
          actionLabel: '登录 / 注册',
          onAction: () => this.onRequireAuth()
        }).layoutWeight(1)
      } else if (this.items.length === 0) {
        AppEmpty({
          title: '还没有游记',
          description: '去过凉快的地方之后，把它写下来。',
          actionLabel: '新建游记',
          onAction: () => this.newJournal()
        }).layoutWeight(1)
      } else {
        List() {
          ForEach(this.items, (j: JournalItem) => {
            ListItem() {
              Column({ space: 6 }) {
                if (j.visitDate.length > 0) {
                  Text(j.visitDate)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width('100%')
                }
                JournalCard({ item: j, onTap: () => EscapeDetailNav.openJournal(j.id) })
              }
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 12 })
            }
          }, (j: JournalItem) => j.id)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
