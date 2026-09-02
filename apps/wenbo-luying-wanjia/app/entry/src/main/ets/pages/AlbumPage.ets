import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { DetailShell } from '../components/detail/DetailShell'
import { CatalogItem } from '../models/CampModels'
import { CampBizService } from '../services/CampBizService'
import { CampDetailNav } from '../services/CampDetailNav'
import { CampMedia } from '../services/CampMedia'

@Component
export struct AlbumPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State items: CatalogItem[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.items = await CampBizService.loadMine('journals')
    this.loading = false
  }

  build() {
    DetailShell({ title: '回忆相册', onClose: () => CampDetailNav.close() }) {
      Column({ space: 12 }) {
        if (this.loading) {
          AppLoading({ label: '整理过夜照片' })
        } else if (this.items.length === 0) {
          AppEmpty({
            title: '相册还是空的',
            description: '写下露营记录后，封面会按时间排在这里。',
            actionLabel: '返回',
            onAction: (): void => CampDetailNav.close()
          })
        } else {
          ForEach(this.items, (j: CatalogItem) => {
            Column({ space: 8 }) {
              Image(CampMedia.resource(j.coverKey.length > 0 ? j.coverKey : 'hero_camp_night'))
                .width('100%')
                .height(180)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.card)
              Text(j.title)
                .fontSize(Theme.type.subtitleM)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text(j.startAt.length > 0 ? j.startAt : j.summary)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }
            .width('100%')
            .onClick(() => CampDetailNav.openJournal(j.id))
          }, (j: CatalogItem) => j.id)
        }
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
  }
}
