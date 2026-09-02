import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AlbumItem, ArtworkItem } from '../../models/KagModels'
import { KagBizService } from '../../services/KagBizService'
import { KagMedia } from '../../services/KagMedia'
import { KagNav } from '../../services/KagNav'
import { DetailShell } from './DetailShell'

@Component
export struct AlbumDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: AlbumItem = new AlbumItem()
  @State works: ArtworkItem[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.works = await KagBizService.loadWorks(this.item.childId, '', this.item.id)
  }

  private async removeAlbum(): Promise<void> {
    const ok = await KagBizService.deleteAlbum(this.item.id)
    if (ok) {
      KagNav.bump()
      KagNav.close()
    }
  }

  build() {
    DetailShell({
      title: this.item.title,
      onBack: () => KagNav.close()
    }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(KagMedia.cover(this.item.coverKey))
              .width('100%')
              .height(200)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(200)
              .linearGradient({
                angle: 180,
                colors: [[0x00000000, 0.2], [0xE64A2A1C, 1.0]]
              })
            Text(this.item.title)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFF8F3')
              .padding({
                left: Theme.space.pageX,
                right: Theme.space.pageX,
                bottom: Theme.space.s4
              })
          }
          .width('100%')
          .height(200)
          .clip(true)

          Column({ space: Theme.space.s4 }) {
            AppCard({ title: '这本画册' }) {
              Text(this.item.summary.length > 0 ? this.item.summary : '还没有简介。')
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
            }
            Text(`作品 ${this.works.length} 幅`)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            if (this.works.length === 0) {
              AppEmpty({
                title: '画册还是空的',
                description: '打开作品详情，点「加入画册」。',
                actionLabel: '去时间线',
                onAction: () => {
                  KagNav.close()
                  AppStorage.setOrCreate('mainTab', 0)
                }
              })
            } else {
              ForEach(this.works, (w: ArtworkItem) => {
                Row({ space: 12 }) {
                  if (w.imageFile.length > 0) {
                    Image(w.imageFile)
                      .width(72)
                      .height(72)
                      .objectFit(ImageFit.Cover)
                      .borderRadius(8)
                  } else {
                    Image(KagMedia.cover(w.coverKey))
                      .width(72)
                      .height(72)
                      .objectFit(ImageFit.Cover)
                      .borderRadius(8)
                  }
                  Column({ space: 4 }) {
                    Text(w.title)
                      .fontSize(Theme.type.subhead)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                      .width('100%')
                    Text(w.createdOn)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                      .width('100%')
                  }
                  .layoutWeight(1)
                }
                .width('100%')
                .onClick(() => KagNav.open('work', w.id))
              }, (w: ArtworkItem) => w.id)
            }
            AppButton({
              label: '删除这本画册',
              variant: 'ghost',
              onTap: () => {
                void this.removeAlbum()
              }
            })
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
      }
      .layoutWeight(1)
    }
  }
}
