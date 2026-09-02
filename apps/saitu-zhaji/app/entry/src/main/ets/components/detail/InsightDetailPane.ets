import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { SavedInsight } from '../../models/SaituModels'
import { DateHelper } from '../../services/DateHelper'
import { SaituTrackStore } from '../../services/SaituTrackStore'
import { SaituDetailNav } from '../../services/SaituDetailNav'
import { pasteboard } from '@kit.BasicServicesKit'

@Component
export struct InsightDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onInsightIdChange') insightId: string = ''
  onChanged: () => void = () => {}
  @State item: SavedInsight = new SavedInsight()
  @State confirmDelete: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onInsightIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const found = await SaituTrackStore.findInsight(this.insightId)
    if (found !== undefined) {
      this.item = found
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private async copyBody(): Promise<void> {
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.item.body)
      const board = pasteboard.getSystemPasteboard()
      await board.setData(data)
      this.showToast('小结已复制，可粘贴到备忘录或分享')
    } catch {
      this.showToast('复制失败')
    }
  }

  private async remove(): Promise<void> {
    await SaituTrackStore.deleteInsight(this.item.id)
    this.confirmDelete = false
    this.onChanged()
    SaituDetailNav.closeInsight()
  }

  @Builder
  bodyContent() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.empty_trail'))
            .width('100%')
            .height(160)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(160)
            .linearGradient({
              angle: 180,
              colors: [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0.55)', 1]]
            })
          Text(this.item.periodKind === 'month' ? '月度成长小结' : '周度成长小结')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .padding(Theme.space.s4)
        }
        .width('100%')
        .borderRadius(Theme.radius.lg)
        .clip(true)

        Text(this.item.periodLabel)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textSecondary)
        Text(`保存于 ${DateHelper.displayDateTime(this.item.createdAt)}`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
        Text(this.item.body)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textPrimary)
          .lineHeight(24)
          .width('100%')

        AppButton({ label: '复制小结', variant: 'primary', onTap: (): void => { void this.copyBody() } })
        AppButton({ label: '删除小结', variant: 'danger', onTap: (): void => { this.confirmDelete = true } })
        Blank().height(Theme.space.s10)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
    }
    .scrollBar(BarState.Off)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: '成长小结',
        onClose: (): void => SaituDetailNav.closeInsight(),
        body: (): void => this.bodyContent()
      })
      if (this.confirmDelete) {
        Column({ space: Theme.space.s4 }) {
          Text('确认删除这份成长小结？')
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
