import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppCard } from '../components/design-system/AppCard'
import { ArtworkItem, CatalogItem } from '../models/KagModels'
import { KagBizService } from '../services/KagBizService'
import { KagMedia } from '../services/KagMedia'
import { KagNav } from '../services/KagNav'
import { AuthService } from '../services/AuthService'

@Component
export struct GalleryPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('kagTick') @Watch('onTick') tick: number = 0
  @StorageLink('kagChildId') childId: string = ''
  @State halls: CatalogItem[] = []
  @State works: ArtworkItem[] = []
  @State selectedHallId: string = ''
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onTick(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.halls = await KagBizService.loadHalls()
    this.works = await KagBizService.loadWorks(this.childId, '', '')
    if (this.selectedHallId.length === 0) {
      for (const h of this.halls) {
        this.selectedHallId = h.id
        break
      }
    }
  }

  private currentHall(): CatalogItem {
    for (const h of this.halls) {
      if (h.id === this.selectedHallId) {
        return h
      }
    }
    for (const h of this.halls) {
      return h
    }
    const empty = new CatalogItem()
    empty.title = '数字画廊'
    empty.coverKey = 'hall_warm'
    empty.summary = '登录并珍藏作品后，墙面会被你的画填满。'
    return empty
  }

  private tryShare(): void {
    const first = KagBizService.firstWork(this.works)
    if (first === undefined) {
      return
    }
    if (!AuthService.requireAuth('share_exhibition')) {
      this.onRequireAuth()
      return
    }
    KagNav.open('share', first.id)
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Row() {
          Text('数字画廊')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
          AppButton({
            label: '分享海报',
            variant: 'secondary',
            onTap: () => this.tryShare()
          })
        }
        .width('100%')

        Stack({ alignContent: Alignment.BottomStart }) {
          Image(KagMedia.cover(this.currentHall().coverKey))
            .width('100%')
            .height(200)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.lg)
          Column()
            .width('100%')
            .height(200)
            .borderRadius(Theme.radius.lg)
            .linearGradient({
              angle: 180,
              colors: [[0x00000000, 0.2], [0xD91C1410, 1.0]]
            })
          Column({ space: 6 }) {
            Text(this.currentHall().title)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFF8F3')
              .width('100%')
            Text(this.currentHall().summary)
              .fontSize(Theme.type.caption)
              .fontColor('#FFF8F3')
              .width('100%')
          }
          .padding(Theme.space.s4)
        }
        .width('100%')
        .height(200)
        .clip(true)
        .onClick(() => {
          if (this.currentHall().id.length > 0) {
            KagNav.open('hall', this.currentHall().id)
          }
        })

        Scroll() {
          Row({ space: Theme.space.s2 }) {
            ForEach(this.halls, (h: CatalogItem) => {
              Text(h.title)
                .fontSize(Theme.type.caption)
                .fontColor(this.selectedHallId === h.id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .backgroundColor(this.selectedHallId === h.id ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.pill)
                .onClick(() => {
                  this.selectedHallId = h.id
                })
            }, (h: CatalogItem) => h.id)
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')

        Text('墙面陈列')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')

        if (this.works.length === 0) {
          Text('先去时间线珍藏至少一幅作品，墙面才会亮起来。游客可点开展厅风格了解光线气质。')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        } else {
          Scroll() {
            Row({ space: Theme.space.s3 }) {
              ForEach(this.works, (w: ArtworkItem) => {
                Column({ space: 6 }) {
                  if (w.imageFile.length > 0) {
                    Image(w.imageFile)
                      .width(160)
                      .height(200)
                      .objectFit(ImageFit.Cover)
                      .borderRadius(6)
                      .shadow({ radius: 12, color: 'rgba(45,32,24,0.28)', offsetY: 6 })
                  } else {
                    Image(KagMedia.cover(w.coverKey))
                      .width(160)
                      .height(200)
                      .objectFit(ImageFit.Cover)
                      .borderRadius(6)
                      .shadow({ radius: 12, color: 'rgba(45,32,24,0.28)', offsetY: 6 })
                  }
                  Text(w.title)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width(160)
                    .maxLines(1)
                }
                .onClick(() => KagNav.open('work', w.id))
              }, (w: ArtworkItem) => w.id)
            }
            .padding({ left: 4, right: 4, top: 8, bottom: 16 })
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')
        }

        AppCard({ title: '智慧策展' }) {
          Column({ space: 8 }) {
            Text('用几道选择题，得到画册主题与展厅风格建议。纯规则模板，不含生成式对话。')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            AppButton({
              label: '开始策展问卷',
              variant: 'primary',
              onTap: () => KagNav.openBare('curate')
            })
          }
        }

        Text('策展主题')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        this.HintRow('去看主题详情', 'theme')
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s10
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  HintRow(label: string, kind: string) {
    AppButton({
      label: label,
      variant: 'ghost',
      onTap: () => KagNav.openBare('themes')
    })
  }
}
