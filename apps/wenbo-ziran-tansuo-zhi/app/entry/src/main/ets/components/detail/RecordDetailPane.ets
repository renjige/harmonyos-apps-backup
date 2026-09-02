import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { ExploreRecord } from '../../models/ExploreRecordModels'
import { ExploreRecordStore } from '../../services/ExploreRecordStore'
import { NqDetailNav } from '../../services/NqDetailNav'
import { NqMedia } from '../../services/NqMedia'

@Component
export struct RecordDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRecordIdChange') recordId: string = ''
  @Prop @Watch('onRecordIdChange') refreshToken: number = 0
  @State item: ExploreRecord | undefined = undefined
  @State loading: boolean = true
  @State confirmDelete: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRecordIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.item = await ExploreRecordStore.findById(this.recordId)
    this.loading = false
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => {
      this.toastText = ''
    }, 2200)
  }

  private edit(): void {
    NqDetailNav.openRecordEditor(this.recordId)
  }

  private async remove(): Promise<void> {
    if (!this.confirmDelete) {
      this.confirmDelete = true
      this.showToast('再点一次确认删除')
      return
    }
    await ExploreRecordStore.remove(this.recordId)
    NqDetailNav.close()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      if (this.loading) {
        Column() {
          AppLoading({ label: '打开记录' })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.item === undefined) {
        DetailShell({ title: '探索记录', onClose: () => NqDetailNav.close() }) {
          AppEmpty({ title: '记录不存在' })
        }
      } else {
        DetailShell({ title: this.item.title, contentKey: this.recordId, onClose: () => NqDetailNav.close() }) {
          this.Body()
        }
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s8 })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  Body() {
    Column({ space: Theme.space.s4 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(NqMedia.resource('empty_trail'))
          .width('100%')
          .height(180)
          .objectFit(ImageFit.Cover)
        Column()
          .width('100%')
          .height(90)
          .linearGradient({
            angle: 180,
            colors: [['rgba(26,26,26,0)', 0], ['rgba(26,26,26,0.86)', 1]]
          })
        Column({ space: 4 }) {
          Text(this.item !== undefined ? this.item.date : '')
            .fontSize(Theme.type.caption)
            .fontColor('#F5F0E8')
          Text(this.item !== undefined ? this.item.title : '')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 16 })
      }
      .width('100%')
      .height(180)

      Column({ space: 8 }) {
        if (this.item !== undefined && this.item.location.length > 0) {
          Text(`地点  ${this.item.location}`)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        if (this.item !== undefined && this.item.weather.length > 0) {
          Text(`天气  ${this.item.weather}`)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandAccent)
            .width('100%')
        }
        if (this.item !== undefined && (this.item.lat !== 0 || this.item.lng !== 0)) {
          Text(`坐标  ${this.item.lat.toFixed(4)}, ${this.item.lng.toFixed(4)}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
        }
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')

      Column({ space: 8 }) {
        Text('记录正文')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text(this.item !== undefined && this.item.body.length > 0 ? this.item.body : '暂无正文')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      .padding(Theme.space.s4)
      .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
      .width('auto')

      Column({ space: Theme.space.s3 }) {
        AppButton({ label: '编辑记录', onTap: (): void => this.edit() })
        AppButton({
          label: this.confirmDelete ? '确认删除' : '删除记录',
          variant: 'danger',
          onTap: (): void => { void this.remove() }
        })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
    .width('100%')
  }
}
