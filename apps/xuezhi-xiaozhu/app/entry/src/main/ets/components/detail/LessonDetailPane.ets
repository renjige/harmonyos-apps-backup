import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { CottageItem } from '../../models/CottageModels'
import { AuthService } from '../../services/AuthService'
import { CottageBizService } from '../../services/CottageBizService'
import { CottageMedia } from '../../services/CottageMedia'
import { CottageNav } from '../../services/CottageNav'

@Component
export struct LessonDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop entityId: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State lesson: CottageItem = new CottageItem()
  @State loaded: boolean = false
  @State toastText: string = ''
  @State done: boolean = false
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    if (this.entityId.length === 0) {
      this.loaded = false
      return
    }
    const found = await CottageBizService.findLesson(this.entityId)
    if (found === undefined) {
      this.loaded = false
      return
    }
    this.lesson = found
    const uid = AppStorage.get<string>('currentUsername') ?? ''
    const rows = await CottageBizService.loadProgress(uid)
    this.done = false
    for (const row of rows) {
      if (row.lessonId === found.id) {
        this.done = true
        break
      }
    }
    this.loaded = true
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private async markDone(): Promise<void> {
    if (!AuthService.requireAuth('complete_lesson')) {
      this.onRequireAuth()
      return
    }
    const uid = AppStorage.get<string>('currentUsername') ?? ''
    const ok = await CottageBizService.completeLesson(uid, this.lesson)
    if (ok) {
      this.done = true
      CottageNav.bump()
      this.showToast('已记下本课进度')
      return
    }
    this.showToast('记录失败，请稍后重试')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: '课时',
        onClose: (): void => { CottageNav.closeDetail() }
      }) {
        if (!this.loaded) {
          AppEmpty({ title: '课时不存在', description: '请返回路径后重试' })
        } else {
          Scroll() {
            Column({ space: Theme.space.s5 }) {
              Stack({ alignContent: Alignment.BottomStart }) {
                Image(CottageMedia.resource(this.lesson.coverKey.length > 0 ?
                  this.lesson.coverKey : this.lesson.domain))
                  .width('100%')
                  .height(200)
                  .objectFit(ImageFit.Cover)
                Column()
                  .width('100%')
                  .height(200)
                  .linearGradient({
                    angle: 180,
                    colors: [['rgba(18,32,58,0.08)', 0.28], ['rgba(18,32,58,0.80)', 1]]
                  })
                Column({ space: 6 }) {
                  Text(this.lesson.minutes > 0 ? `约 ${this.lesson.minutes} 分钟` : '课时')
                    .fontSize(Theme.type.caption)
                    .fontColor('#F8FAFC')
                  Text(this.lesson.title)
                    .fontSize(Theme.type.title2)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#F8FAFC')
                    .maxLines(3)
                }
                .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
              }
              .width('100%')
              .borderRadius(Theme.radius.md)
              .clip(true)
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

              Column() {
                Text(this.lesson.summary.length > 0 ? this.lesson.summary : this.lesson.subtitle)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .lineHeight(24)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.cardPadding)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

              Text(this.lesson.description.length > 0 ? this.lesson.description : this.lesson.body)
                .fontSize(Theme.type.bodyL)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .lineHeight(28)
                .width('100%')
                .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

              Column({ space: Theme.space.s3 }) {
                AppButton({
                  label: this.done ? '已完成本课' : '标记本课完成',
                  variant: this.done ? 'secondary' : 'primary',
                  onTap: (): void => { void this.markDone() }
                })
                AppButton({
                  label: '返回路径',
                  variant: 'ghost',
                  onTap: (): void => {
                    if (this.lesson.pathId.length > 0) {
                      CottageNav.openPath(this.lesson.pathId)
                    } else {
                      CottageNav.closeDetail()
                    }
                  }
                })
              }
              .padding({
                left: Theme.space.pageX,
                right: Theme.space.pageX,
                bottom: Theme.space.s10
              })
            }
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .align(Alignment.Top)
        }
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 56 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
