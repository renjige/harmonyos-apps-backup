import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { ExploreTask, ExploreStore } from '../../services/ExploreStore'
import { PavilionDetailNav } from '../../services/PavilionDetailNav'
import { PavilionTime } from '../../models/PavilionModels'

@Component
export struct TasksPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State tasks: ExploreTask[] = []
  @State toastText: string = ''

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  private reload(): void {
    this.tasks = ExploreStore.todayTasks()
  }

  private async toggle(id: string): Promise<void> {
    await ExploreStore.toggleTask(id)
    this.reload()
    this.toastText = '探索进度已更新'
    setTimeout((): void => { this.toastText = '' }, 1800)
  }

  private doneCount(): number {
    let n = 0
    for (const t of this.tasks) {
      if (t.done) {
        n++
      }
    }
    return n
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: '趣味挑战任务',
        onClose: (): void => { PavilionDetailNav.close() }
      }) {
        if (this.tasks.length === 0) {
          AppEmpty({ title: '今日任务尚未生成', description: '返回后重新打开本页。' })
        } else {
          Column({ space: Theme.space.s3 }) {
            Text(`${PavilionTime.todayKey()}  ·  已完成 ${this.doneCount()} / ${this.tasks.length}`)
              .fontSize(14)
              .fontColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
              .width('100%')
            ForEach(this.tasks, (t: ExploreTask) => {
              Row({ space: 12 }) {
                Text(t.done ? '已完成' : '待探索')
                  .fontSize(12)
                  .fontColor(t.done ? Theme.colors().success : Theme.brandInk(this.themeEpoch, this.darkModeOn))
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .backgroundColor(Theme.brandBox(this.themeEpoch, this.darkModeOn))
                  .borderRadius(8)
                Text(t.title)
                  .fontSize(16)
                  .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
                  .layoutWeight(1)
              }
              .width('100%')
              .padding(14)
              .backgroundColor(Theme.cardBg(this.themeEpoch, this.darkModeOn))
              .borderRadius(12)
              .onClick((): void => { void this.toggle(t.id) })
            }, (t: ExploreTask) => t.id)
            Text('点按即可勾选完成。今日三件事：发现一个生活技巧、学习一个冷知识、阅读一个趣味故事。只保存在本机。')
              .fontSize(12)
              .fontColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
              .width('100%')
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
          .width('100%')
        }
      }
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(12)
          .fontColor('#FFFFFF')
          .padding(10)
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(20)
          .margin({ top: 56 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
