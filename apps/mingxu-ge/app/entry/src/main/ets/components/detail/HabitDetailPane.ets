import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { XuHabitItem } from '../../models/XuModels'
import { XuDateHelper } from '../../models/XuModels'
import { XuLocalStore } from '../../services/XuLocalStore'
import { XuDetailNav } from '../../services/XuDetailNav'
import { XuMedia } from '../../services/XuMedia'
import { XuConfirmDialog } from '../xu/XuConfirmDialog'
import { XuBizService } from '../../services/XuBizService'

@Component
export struct HabitDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onIdChange') habitId: string = ''
  @State item: XuHabitItem = new XuHabitItem()
  @State confirmDel: boolean = false
  onChanged: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const found = await XuLocalStore.findHabit(this.habitId)
    if (found !== undefined) {
      this.item = found
    }
  }

  private async toggle(): Promise<void> {
    const next = await XuLocalStore.toggleHabit(this.item.id, XuDateHelper.todayKey())
    if (next !== undefined) {
      // 新实例赋值，避免 @State 同引用字段变更不刷新
      const copy = new XuHabitItem()
      copy.id = next.id
      copy.title = next.title
      copy.remark = next.remark
      copy.streak = next.streak
      copy.lastCheck = next.lastCheck
      copy.createdAt = next.createdAt
      this.item = copy
      void XuBizService.syncHabit(next)
      this.onChanged()
    }
  }

  private async doDelete(): Promise<void> {
    await XuLocalStore.deleteHabit(this.item.id)
    this.confirmDel = false
    this.onChanged()
    XuDetailNav.closeHabit()
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(XuMedia.habit())
              .width('100%')
              .height(180)
              .objectFit(ImageFit.Cover)
            Column() {
              Text('习惯')
                .fontSize(Theme.type.caption)
                .fontColor('#FFFFFF')
              Text(this.item.title)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .padding(Theme.space.s4)
            .linearGradient({
              angle: 180,
              colors: [['rgba(26,42,58,0)', 0], ['rgba(26,42,58,0.82)', 1]]
            })
          }
          .width('100%')
          .borderRadius(Theme.radius.xl)
          .clip(true)

          Text(`连续打卡 ${this.item.streak} 天`)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandAccent)
            .width('100%')

          AppCard({ title: '说明' }) {
            Text(this.item.remark.length > 0 ? this.item.remark : '未填写说明。坚持比完美更重要。')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
          }

          Column({ space: Theme.space.s3 }) {
            AppButton({
              label: this.item.checkedToday(XuDateHelper.todayKey()) ? '取消今日打卡' : '完成今日打卡',
              onTap: (): void => { void this.toggle() }
            })
            AppButton({
              label: '编辑习惯',
              variant: 'secondary',
              onTap: (): void => { XuDetailNav.openHabitEditor(this.item.id) }
            })
            AppButton({
              label: '删除习惯',
              variant: 'danger',
              onTap: (): void => { this.confirmDel = true }
            })
          }
          .width('100%')
          .padding({ bottom: Theme.space.s10 })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
        .width('100%')
      }
      .layoutWeight(1)

      if (this.confirmDel) {
        XuConfirmDialog({
          title: '删除这个习惯？',
          message: '连续记录将一并清除。',
          onConfirm: (): void => { void this.doDelete() },
          onCancel: (): void => { this.confirmDel = false }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
