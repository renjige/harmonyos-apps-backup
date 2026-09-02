import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { MicroGoalItem } from '../models/MicroGoalModels'
import { StepBizService } from '../services/StepBizService'

@Component
export struct JournalPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: MicroGoalItem[] = []
  @State keyword: string = ''
  @State loading: boolean = true
  @StorageLink('accessToken') accessToken: string = ''
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  async reload(): Promise<void> {
    this.loading = true
    if (this.accessToken.length === 0) {
      this.items = []
      this.loading = false
      return
    }
    this.items = await StepBizService.loadJournal(this.keyword.trim())
    this.loading = false
  }

  private preview(note: string): string {
    if (note.length <= 20) {
      return note
    }
    return `${note.substring(0, 20)}…`
  }

  build() {
    Column({ space: Theme.space.s4 }) {
      Row({ space: Theme.space.s2 }) {
        AppIcon({ name: 'search', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
        TextInput({ text: this.keyword, placeholder: '搜索感悟或目标' })
          .layoutWeight(1)
          .onChange((v: string) => {
            this.keyword = v
          })
        Text('搜索')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick(() => {
            void this.reload()
          })
      }
      .width('100%')
      .padding(Theme.space.s3)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)

      if (this.accessToken.length === 0) {
        AppEmpty({
          title: '登录后查看成长日记',
          description: '完成微目标并记录感悟后将在此展示',
          actionLabel: '去登录',
          onAction: () => {
            this.onRequireAuth()
          }
        })
      } else if (this.loading) {
        Text('加载中…')
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      } else if (this.items.length === 0) {
        Column() {
          Image($r('app.media.ambient_empty'))
            .width('100%')
            .height(140)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.lg)
          AppEmpty({
            title: '还没有记录',
            description: '完成微目标并写下感悟，开始你的第一步吧',
            actionLabel: '刷新',
            onAction: () => {
              void this.reload()
            }
          })
        }
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.items, (it: MicroGoalItem) => {
              Column({ space: 6 }) {
                Row() {
                  Text(it.goalDate)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  Blank()
                  Text(it.title)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                }
                .width('100%')
                Text(this.preview(it.note))
                  .fontSize(Theme.type.subhead)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
              .border({ width: 1, color: Theme.colors().strokeHairline })
            }, (it: MicroGoalItem) => it.id)
          }
          .padding({ bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .padding(Theme.space.pageX)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
