import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { NoteItem } from '../models/TravelModels'
import { TravelService } from '../services/TravelService'
import { AuthService } from '../services/AuthService'

@Component
export struct NotesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State notes: NoteItem[] = []
  @State loading: boolean = false
  @Prop embedded: boolean = false
  @Prop @Watch('onEpochChange') dataEpoch: number = 0
  onCreate: () => void = () => {}
  onRequireAuth: () => void = () => {}
  onChanged: () => void = () => {}
  onEditItem: (item: NoteItem) => void = () => {}
  onDeleteItem: (item: NoteItem) => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  onEpochChange(): void {
    void this.load(true)
  }

  private async load(silent: boolean = false): Promise<void> {
    if (!silent) {
      this.loading = true
    }
    try {
      this.notes = await TravelService.notes()
    } catch {
      this.notes = []
    }
    this.loading = false
  }

  private confirmDelete(note: NoteItem): void {
    AlertDialog.show({
      title: '删除备忘',
      message: `确定删除「${note.title}」？`,
      primaryButton: {
        value: '删除',
        action: (): void => { this.onDeleteItem(note) }
      },
      secondaryButton: { value: '取消', action: (): void => {} }
    })
  }

  build() {
    if (this.embedded) {
      this.ListBody()
    } else {
      Column() {
        AppHeader({ title: '旅途备忘', subtitle: '记录交通、住宿、集合点与同行事项' })
        Scroll() {
          this.ListBody()
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

  @Builder
  ListBody() {
    Column({ space: Theme.space.s3 }) {
          AppButton({ label: '写一条备忘', onTap: () => {
            if (!AuthService.isLoggedIn()) {
              this.onRequireAuth()
              return
            }
            this.onCreate()
          } })
          if (this.loading) {
            LoadingProgress()
              .width(32)
              .height(32)
              .color(Theme.colors().brandPrimary)
          }
          if (this.notes.length === 0 && !this.loading) {
            AppEmpty({
              title: '还没有备忘',
              description: '记下酒店地址、集合时间、备用路线或同行伙伴电话',
              actionLabel: '立即记录',
              onAction: () => {
                if (!AuthService.isLoggedIn()) {
                  this.onRequireAuth()
                  return
                }
                this.onCreate()
              }
            })
          } else {
            ForEach(this.notes, (note: NoteItem) => {
              Column({ space: 8 }) {
                Row() {
                  Text(note.title)
                    .fontSize(Theme.type.subtitleM)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .layoutWeight(1)
                  Text('编辑')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandPrimary)
                    .margin({ right: 12 })
                    .onClick(() => this.onEditItem(note))
                  Text('删除')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().danger)
                    .onClick(() => this.confirmDelete(note))
                }
                .width('100%')
                Text(note.body.length > 0 ? note.body : '未填写正文')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .alignItems(HorizontalAlign.Start)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
              .onClick(() => this.onEditItem(note))
            }, (note: NoteItem) => note.id)
          }
    }
    .width('100%')
    .padding({
      left: Theme.space.pageX,
      right: Theme.space.pageX,
      bottom: this.embedded ? Theme.space.s4 : Theme.space.s10
    })
  }
}
