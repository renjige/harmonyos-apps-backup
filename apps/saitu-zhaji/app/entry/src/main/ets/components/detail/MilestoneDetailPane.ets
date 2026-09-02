import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { Journey, JourneyMilestone } from '../../models/SaituModels'
import { DateHelper } from '../../services/DateHelper'
import { SaituLocalStore } from '../../services/SaituLocalStore'
import { SaituTrackStore } from '../../services/SaituTrackStore'
import { SaituDetailNav } from '../../services/SaituDetailNav'

@Component
export struct MilestoneDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onMilestoneIdChange') milestoneId: string = ''
  onChanged: () => void = () => {}
  @State item: JourneyMilestone = new JourneyMilestone()
  @State journeyName: string = ''
  @State confirmDelete: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onMilestoneIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const found = await SaituTrackStore.findMilestone(this.milestoneId)
    if (found !== undefined) {
      this.item = found
      const j: Journey | undefined = await SaituLocalStore.findJourney(found.journeyId)
      this.journeyName = j !== undefined ? j.name : '未归属旅途'
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private async toggleDone(): Promise<void> {
    this.item.done = !this.item.done
    await SaituTrackStore.saveMilestone(this.item)
    this.onChanged()
    this.showToast(this.item.done ? '节点已达成，看板进度已更新' : '已改回进行中')
  }

  private async remove(): Promise<void> {
    await SaituTrackStore.deleteMilestone(this.item.id)
    this.confirmDelete = false
    this.onChanged()
    SaituDetailNav.closeMilestone()
  }

  @Builder
  bodyContent() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.hero_ambient'))
            .width('100%')
            .height(180)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(180)
            .linearGradient({
              angle: 180,
              colors: [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0.58)', 1]]
            })
          Column({ space: 6 }) {
            Text(this.item.statusLabel())
              .fontSize(Theme.type.caption)
              .fontColor('#FFFFFF')
            Text(this.item.title)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
          }
          .padding(Theme.space.s4)
        }
        .width('100%')
        .borderRadius(Theme.radius.lg)
        .clip(true)

        Column({ space: Theme.space.s2 }) {
          Text(`旅途 · ${this.journeyName}`)
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().brandPrimary)
          Text(this.item.dueDate.length > 0 ? `目标日期 ${this.item.dueDate}` : '未设目标日期')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
          Text(`创建于 ${DateHelper.displayDateTime(this.item.createdAt)}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
        }
        .width('100%')
        .padding(Theme.space.cardPadding)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .alignItems(HorizontalAlign.Start)

        Text(this.item.note.length > 0 ? this.item.note : '暂无节点说明。可编辑补充达成标准。')
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textPrimary)
          .lineHeight(24)
          .width('100%')

        AppButton({
          label: this.item.done ? '撤销达成' : '标记达成',
          variant: 'primary',
          onTap: (): void => { void this.toggleDone() }
        })
        AppButton({
          label: '编辑节点',
          variant: 'secondary',
          onTap: (): void => SaituDetailNav.openMilestoneEditor(this.item.id, this.item.journeyId)
        })
        AppButton({
          label: '删除节点',
          variant: 'danger',
          onTap: (): void => { this.confirmDelete = true }
        })
        Blank().height(Theme.space.s10)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
    }
    .scrollBar(BarState.Off)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: '赛途节点',
        onClose: (): void => SaituDetailNav.closeMilestone(),
        body: (): void => this.bodyContent()
      })
      if (this.confirmDelete) {
        Column({ space: Theme.space.s4 }) {
          Text('确认删除该节点？进度会同步回退。')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textPrimary)
          Row({ space: Theme.space.s3 }) {
            AppButton({ label: '取消', variant: 'secondary', onTap: (): void => { this.confirmDelete = false } })
            AppButton({ label: '删除', variant: 'danger', onTap: (): void => { void this.remove() } })
          }
        }
        .width('80%')
        .padding(Theme.space.s6)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .margin({ top: 180 })
      }
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().surfaceInverse)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s8 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
