import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { StudyTask } from '../../models/StudyModels'
import { StudyStore } from '../../services/StudyStore'

@Component
export struct TaskBoardPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('studyDataEpoch') @Watch('onDataEpoch') studyDataEpoch: number = 0
  @State tasks: StudyTask[] = []
  @State draft: string = ''
  @State toastText: string = ''
  @State confirmId: string = ''
  onClose: () => void = () => {}
  onChanged: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  onDataEpoch(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const list = await StudyStore.loadTasks()
    const copy: StudyTask[] = []
    for (let i = 0; i < list.length; i++) {
      const n = new StudyTask()
      n.id = list[i].id
      n.title = list[i].title
      n.done = list[i].done
      n.createdAt = list[i].createdAt
      copy.push(n)
    }
    this.tasks = copy
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2000)
  }

  private async add(): Promise<void> {
    const title = this.draft.trim()
    if (title.length === 0) {
      this.showToast('请填写待学内容')
      return
    }
    await StudyStore.saveTask(StudyTask.create(title))
    this.draft = ''
    this.onChanged()
    await this.load()
    this.showToast('已加入今日待学')
  }

  private async toggle(item: StudyTask): Promise<void> {
    const next = new StudyTask()
    next.id = item.id
    next.title = item.title
    next.done = !item.done
    next.createdAt = item.createdAt
    await StudyStore.saveTask(next)
    this.onChanged()
    await this.load()
  }

  private async remove(id: string): Promise<void> {
    if (this.confirmId !== id) {
      this.confirmId = id
      this.showToast('再点一次确认删除')
      return
    }
    await StudyStore.deleteTask(id)
    this.confirmId = ''
    this.onChanged()
    await this.load()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row() {
          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          }
          .width(48).height(48).justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Text('今日待学')
            .fontSize(Theme.type.subtitleM)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')

        Scroll() {
          Column({ space: Theme.space.s3 }) {
            Text('把今天要做的事写成清单，做完勾选。和专注时长分开记录。')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Row({ space: 8 }) {
              TextInput({ text: this.draft, placeholder: '例如：复习英语单词 20 个' })
                .layoutWeight(1)
                .height(44)
                .fontColor(Theme.inputInk())
                .placeholderColor(Theme.inputHint())
                .backgroundColor(Theme.inputFill())
                .border({ width: 1, color: '#CBD5E1' })
                .borderRadius(12)
                .onChange((v: string) => { this.draft = v })
              Text('添加')
                .fontSize(Theme.type.body)
                .fontColor('#FFFFFF')
                .padding({ left: 14, right: 14, top: 12, bottom: 12 })
                .backgroundColor('#1A2A4A')
                .borderRadius(14)
                .constraintSize({ minHeight: 44 })
                .onClick((): void => { void this.add() })
            }
            .width('100%')

            if (this.tasks.length === 0) {
              AppEmpty({
                title: '还没有待学项',
                description: '写下一件今天一定要完成的事',
                actionLabel: '添加示例',
                onAction: (): void => {
                  this.draft = '完成一段 25 分钟专注'
                  void this.add()
                }
              })
            } else {
              ForEach(this.tasks, (t: StudyTask) => {
                Row({ space: 10 }) {
                  Text(t.done ? '已完成' : '待完成')
                    .fontSize(Theme.type.caption)
                    .fontColor(t.done ? Theme.colors().success : Theme.colors().textPrimary)
                    .padding({ left: 8, right: 8, top: 6, bottom: 6 })
                    .backgroundColor(t.done ? Theme.colors().successContainer : Theme.colors().surfaceSubtle)
                    .borderRadius(8)
                    .onClick((): void => { void this.toggle(t) })
                  Text(t.done ? `完成 · ${t.title}` : t.title)
                    .fontSize(Theme.type.body)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .layoutWeight(1)
                    .onClick((): void => { void this.toggle(t) })
                  Text('删除')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().danger)
                    .constraintSize({ minHeight: 44 })
                    .onClick((): void => { void this.remove(t.id) })
                }
                .width('100%')
                .padding(12)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(14)
              }, (t: StudyTask) => `${t.id}-${t.done ? '1' : '0'}`)
            }
            AppButton({
              label: '完成并返回',
              variant: 'secondary',
              onTap: (): void => { this.onClose() }
            })
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding(12)
          .backgroundColor('#1A2A4A')
          .borderRadius(12)
          .margin({ top: 16 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
