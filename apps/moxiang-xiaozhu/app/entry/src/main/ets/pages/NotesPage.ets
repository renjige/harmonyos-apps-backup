import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppButton } from '../components/design-system/AppButton'
import { UserRecordItem } from '../models/InkModels'
import { InkBizService } from '../services/InkBizService'
import { InkDetailNav } from '../services/InkDetailNav'
import { AuthService } from '../services/AuthService'

@Component
export struct NotesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  @State items: UserRecordItem[] = []
  @State loading: boolean = true

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
    this.items = await InkBizService.loadNotes()
    this.loading = false
  }

  private createNote(): void {
    if (!AuthService.requireAuth('create_note')) {
      this.onRequireAuth()
      return
    }
    InkDetailNav.openEditor('note', '')
  }

  build() {
    Column() {
      Row() {
        Text('墨迹笔记')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        AppButton({
          label: '新建',
          variant: 'secondary',
          onTap: (): void => { this.createNote() }
        })
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s3
      })

      if (!AuthService.isLoggedIn()) {
        AppEmpty({
          title: '登录后写下墨迹',
          description: '游客可先去首页读今日书摘。',
          actionLabel: '去登录',
          onAction: (): void => { this.onRequireAuth() }
        })
      } else if (this.loading) {
        AppEmpty({ title: '正在铺开墨迹…', description: '' })
      } else if (this.items.length === 0) {
        AppEmpty({
          title: '还没有墨迹',
          description: '读完书摘后，把感受写在这里。',
          actionLabel: '写一条',
          onAction: (): void => { this.createNote() }
        })
      } else {
        List() {
          ForEach(this.items, (n: UserRecordItem) => {
            ListItem() {
              Column({ space: 6 }) {
                Text(n.title)
                  .fontSize(Theme.type.subtitleM)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(n.previewLine())
                  .fontSize(Theme.type.footnote)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .maxLines(2)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.card)
              .onClick((): void => { InkDetailNav.openNote(n.id) })
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s3
            })
          }, (n: UserRecordItem) => n.id)
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
