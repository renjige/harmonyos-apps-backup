import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { RecordItem } from '../../models/RoadModels'
import { RoadBizService } from '../../services/RoadBizService'
import { RoadDetailNav } from '../../services/RoadDetailNav'
import { RoadMedia } from '../../services/RoadMedia'

@Component
export struct JournalDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onJournalIdChange') journalId: string = ''
  @Prop @Watch('onJournalIdChange') refreshToken: number = 0
  @State item: RecordItem | undefined = undefined
  @State loading: boolean = true
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onJournalIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.item = await RoadBizService.findJournal(this.journalId)
    this.loading = false
  }

  private async remove(): Promise<void> {
    const ok = await RoadBizService.deleteJournal(this.journalId)
    if (ok) {
      RoadDetailNav.close()
      return
    }
    this.toastText = '删除失败，请稍后重试'
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      if (this.loading) {
        AppLoading({ label: '打开手账' })
      } else if (this.item === undefined) {
        DetailShell({ title: '手账', onClose: (): void => { RoadDetailNav.close() } }) {
          AppEmpty({ title: '手账不存在', description: '返回记录页再试' })
        }
      } else {
        this.Body(this.item as RecordItem)
      }
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.subhead)
          .fontColor('#FFFFFF')
          .backgroundColor('rgba(20,61,40,0.92)')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .borderRadius(Theme.radius.pill)
          .margin({ top: 12 })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  Body(item: RecordItem) {
    DetailShell({ title: item.title, contentKey: item.id, onClose: (): void => { RoadDetailNav.close() } }) {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(RoadMedia.resource(item.coverKey.length > 0 ? item.coverKey : 'empty_journal'))
            .width('100%')
            .height(200)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(88)
            .linearGradient({
              angle: 180,
              colors: [['rgba(20,61,40,0)', 0.0], ['rgba(20,61,40,0.78)', 1.0]]
            })
          Text(item.title)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .padding({ left: 16, bottom: 16 })
        }
        .width('100%')
        .clip(true)
        .borderRadius(Theme.radius.lg)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

        Text(item.placeLabel.length > 0 ? item.placeLabel : '未标记地点')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          .width('100%')

        Column() {
          AppCard() {
            Column({ space: 8 }) {
              Text('观察摘要')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              Text(item.summary.length > 0 ? item.summary : item.body)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
            }
            .alignItems(HorizontalAlign.Start)
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Text(item.body)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .lineHeight(24)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        AppButton({
          label: '删除这条手账',
          variant: 'ghost',
          onTap: (): void => { void this.remove() }
        })
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 16 })
      }
      .width('100%')
    }
  }
}
