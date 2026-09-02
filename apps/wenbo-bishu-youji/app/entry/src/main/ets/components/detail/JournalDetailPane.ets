import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { JournalItem } from '../../models/EscapeModels'
import { EscapeBizService } from '../../services/EscapeBizService'
import { EscapeDetailNav } from '../../services/EscapeDetailNav'
import { EscapeMedia } from '../../services/EscapeMedia'

@Component
export struct JournalDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onJournalIdChange') journalId: string = ''
  @Prop @Watch('onJournalIdChange') refreshToken: number = 0
  @State item: JournalItem | undefined = undefined
  @State loading: boolean = true
  @State confirmDelete: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onJournalIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.item = await EscapeBizService.findJournal(this.journalId)
    this.loading = false
  }

  private current(): JournalItem {
    if (this.item !== undefined) {
      return this.item
    }
    return new JournalItem()
  }

  private async remove(): Promise<void> {
    if (!this.confirmDelete) {
      this.confirmDelete = true
      this.toastText = '再点一次确认删除这篇游记'
      setTimeout(() => {
        this.toastText = ''
      }, 2200)
      return
    }
    const ok = await EscapeBizService.deleteJournal(this.journalId)
    if (ok) {
      EscapeDetailNav.close()
      return
    }
    this.toastText = '删除失败，请稍后重试'
    setTimeout(() => {
      this.toastText = ''
    }, 2200)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      if (this.loading) {
        Column() {
          AppLoading({ label: '打开游记' })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.item === undefined) {
        DetailShell({ title: '游记', onClose: () => EscapeDetailNav.close() }) {
          AppEmpty({ title: '这篇游记不见了', actionLabel: '返回', onAction: () => EscapeDetailNav.close() })
        }
      } else {
        DetailShell({ title: '我的游记', contentKey: this.current().id, onClose: () => EscapeDetailNav.close() }) {
          this.Body()
        }
      }
      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  Body() {
    Column({ space: Theme.space.s4 }) {
      if (this.current().coverKey.length > 0) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(EscapeMedia.resource(this.current().coverKey))
            .width('100%')
            .height(200)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(90)
            .linearGradient({
              angle: 180,
              colors: [['rgba(15,23,42,0)', 0], ['rgba(15,23,42,0.7)', 1]]
            })
          Text(this.current().title)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor('#F8FAFC')
            .padding(16)
        }
        .width('100%')
        .height(200)
        .borderRadius(Theme.radius.lg)
        .clip(true)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
      } else {
        Text(this.current().title)
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          .width('100%')
      }

      Column({ space: 6 }) {
        Text(`${this.current().placeLabel} · ${this.current().visitDate}`)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .width('100%')
        Text(this.current().body)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .alignItems(HorizontalAlign.Start)

      Column() {
        AppButton({
          label: this.confirmDelete ? '再点一次确认删除' : '删除这篇游记',
          variant: 'danger',
          onTap: (): void => { void this.remove() }
        })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
    }
    .width('100%')
  }
}
