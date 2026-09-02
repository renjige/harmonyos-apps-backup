import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { CampBizService } from '../../services/CampBizService'
import { CampDetailNav } from '../../services/CampDetailNav'
import { CampMedia } from '../../services/CampMedia'
import { CatalogItem } from '../../models/CampModels'
import { DetailShell } from './DetailShell'

@Component
export struct JournalDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onIdChange') itemId: string = ''
  @Prop @Watch('onIdChange') refreshToken: number = 0
  @State item: CatalogItem | undefined = undefined
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.item = await CampBizService.findJournal(this.itemId)
    this.loading = false
  }

  private async remove(): Promise<void> {
    if (this.item === undefined) {
      return
    }
    const ok = await CampBizService.remove('journals', this.item.id)
    if (ok) {
      CampDetailNav.close()
    }
  }

  build() {
    if (this.loading) {
      Column() {
        AppLoading({ label: '打开记录' })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    } else if (this.item === undefined) {
      DetailShell({ title: '记录', onClose: () => CampDetailNav.close() }) {
        AppEmpty({ title: '记录不存在', actionLabel: '返回', onAction: () => CampDetailNav.close() })
      }
    } else {
      DetailShell({ title: this.item.title, onClose: () => CampDetailNav.close() }) {
        Column({ space: Theme.space.s4 }) {
          Image(CampMedia.resource(this.item.coverKey.length > 0 ? this.item.coverKey : 'hero_camp_night'))
            .width('100%')
            .height(200)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.card)
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
          Text(`${this.item.days} 夜`)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .padding({ left: Theme.space.pageX })
            .width('100%')
          Text(this.item.body)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
            .width('100%')
          AppButton({
            label: '删除这条记录',
            variant: 'danger',
            onTap: () => { void this.remove() }
          }).margin({ left: Theme.space.pageX, right: Theme.space.pageX })
        }
      }
    }
  }
}
