import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { CatalogItem } from '../../models/KagModels'
import { KagBizService } from '../../services/KagBizService'
import { KagMedia } from '../../services/KagMedia'
import { KagNav } from '../../services/KagNav'
import { DetailShell } from './DetailShell'

@Component
export struct CatalogListOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop kind: string = 'theme'
  @State items: CatalogItem[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  private title(): string {
    if (this.kind === 'hall') {
      return '展厅风格'
    }
    if (this.kind === 'milestone') {
      return '成长里程碑'
    }
    if (this.kind === 'guide') {
      return '珍藏指南'
    }
    return '策展主题'
  }

  private async reload(): Promise<void> {
    if (this.kind === 'hall') {
      this.items = await KagBizService.loadHalls()
      return
    }
    if (this.kind === 'milestone') {
      this.items = await KagBizService.loadMilestones()
      return
    }
    if (this.kind === 'guide') {
      this.items = await KagBizService.loadGuides()
      return
    }
    this.items = await KagBizService.loadThemes()
  }

  build() {
    DetailShell({
      title: this.title(),
      onBack: () => KagNav.close()
    }) {
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          ForEach(this.items, (item: CatalogItem) => {
            Row({ space: 12 }) {
              Image(KagMedia.cover(item.coverKey))
                .width(88)
                .height(72)
                .objectFit(ImageFit.Cover)
                .borderRadius(10)
              Column({ space: 4 }) {
                Text(item.title)
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(item.summary)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .maxLines(2)
                  .width('100%')
              }
              .layoutWeight(1)
            }
            .width('100%')
            .padding(10)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick(() => KagNav.open(this.kind, item.id))
          }, (item: CatalogItem) => item.id)
          AppButton({
            label: '关闭',
            variant: 'ghost',
            onTap: () => KagNav.close()
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
  }
}
